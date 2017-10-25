
/****************************************************
					WOUNDS
****************************************************/
/datum/wound
	map_storage_saved_vars = "current_stage;damage;bleed_timer;bandaged;clamped;salved;disinfected;amount;internal;surgery_treated;splinted"
	// number representing the current stage
	var/current_stage = 0

	// description of the wound
	var/desc = "wound" //default in case something borks

	// amount of damage this wound causes
	var/damage = 0
	// ticks of bleeding left.
	var/bleed_timer = 0
	// amount of damage the current wound type requires(less means we need to apply the next healing stage)
	var/min_damage = 0

	// is the wound bandaged?
	var/bandaged = 0
	// Similar to bandaged, but works differently
	var/clamped = 0
	// is the wound salved?
	var/salved = 0
	// is the wound disinfected?
	var/disinfected = 0
	var/created = 0
	// number of wounds of this type
	var/amount = 1
	// amount of germs in the wound
	var/germ_level = 0

	/*  These are defined by the wound type and should not be changed */

	// stages such as "cut", "deep cut", etc.
	var/list/stages
	// internal wounds can only be fixed through surgery
	var/internal = 0
	// maximum stage at which bleeding should still happen. Beyond this stage bleeding is prevented.
	var/max_bleeding_stage = 0
	// one of CUT, BRUISE, BURN
	var/damage_type = CUT
	// whether this wound needs a bandage/salve to heal at all
	// the maximum amount of damage that this wound can have and still autoheal
	var/autoheal_cutoff = 15
	// PERSISTANT EDIT!!
	// whether a wound can be healed by simple means or if it needs treatment and time to heal
	var/simpleheal = 1
	// whether the wound HAS an appropriate upgrade
	var/upgradeable = 0
	// the path of the upgrade
	var/upgrade_type
	// whether the wound has been treated with surgery to accelerate healing
	var/surgery_treated = 0
	// wounds gotta have custom wound effects, cmon!
	var/opening_desc_visible = "the wound widens with a nasty ripping noise." // Context "On your [name], [W.opening_desc_visible]"
	var/opening_desc_audible = "You hear a nasty ripping noise, as if flesh is being torn apart." // used in visible_message
	// is the wound splinted? (used for fractures and bruises)
	var/splinted = 0

	// helper lists
	var/tmp/list/desc_list = list()
	var/tmp/list/damage_list = list()

	New(var/damage)

		created = world.time

		// reading from a list("stage" = damage) is pretty difficult, so build two separate
		// lists from them instead
		for(var/V in stages)
			desc_list += V
			damage_list += stages[V]

		src.damage = damage

		// initialize with the appropriate stage
		src.init_stage(damage)

		bleed_timer += damage

	// returns 1 if there's a next stage, 0 otherwise
	proc/init_stage(var/initial_damage)
		current_stage = stages.len

		while(src.current_stage > 1 && src.damage_list[current_stage-1] <= initial_damage / src.amount)
			src.current_stage--

		src.min_damage = damage_list[current_stage]
		src.desc = desc_list[current_stage]

	// the amount of damage per wound
	proc/wound_damage()
		return src.damage / src.amount

	proc/can_autoheal()
		if(src.wound_damage() <= autoheal_cutoff)
			return 1

		return is_treated()

	// checks whether the wound has been appropriately treated
	proc/is_treated()
		if(damage_type == CUT)
			return bandaged
		else if(damage_type == BRUISE)
			return splinted
		else if(damage_type == BURN)
			return salved

	// Checks whether other other can be merged into src.
	proc/can_merge(var/datum/wound/other)
		if(other.type != src.type) return 0
		if(other.current_stage != src.current_stage) return 0
		if(other.damage_type != src.damage_type) return 0
		if(!(other.can_autoheal()) != !(src.can_autoheal())) return 0
		if(!(other.bandaged) != !(src.bandaged)) return 0
		if(!(other.clamped) != !(src.clamped)) return 0
		if(!(other.salved) != !(src.salved)) return 0
		if(!(other.disinfected) != !(src.disinfected)) return 0
		//if(other.germ_level != src.germ_level) return 0
		return 1

	proc/merge_wound(var/datum/wound/other)
		src.damage += other.damage
		src.amount += other.amount
		src.bleed_timer += other.bleed_timer
		src.germ_level = max(src.germ_level, other.germ_level)
		src.created = max(src.created, other.created)	//take the newer created time

	// checks if wound is considered open for external infections
	// untreated cuts (and bleeding bruises) and burns are possibly infectable, chance higher if wound is bigger
	proc/infection_check()
		if(damage < 10)	//small cuts, tiny bruises, and moderate burns shouldn't be infectable.
			return 0
		if(is_treated() && damage < 25)	//anything less than a flesh wound (or equivalent) isn't infectable if treated properly
			return 0
		if(disinfected)
			germ_level = 0	//reset this, just in case
			return 0

		if(damage_type == BRUISE && !bleeding()) //bruises only infectable if bleeding
			return 0

		var/dam_coef = round(damage/10)
		switch(damage_type)
			if(BRUISE)
				return prob(dam_coef*5)
			if(BURN)
				return prob(dam_coef*10)
			if(CUT)
				return prob(dam_coef*20)

		return 0

	// heal the given amount of damage, and if the given amount of damage was more
	// than what needed to be healed, return how much heal was left
	// set @heals_internal to also heal internal organ damage
	proc/heal_damage(amount, heals_internal = 0, autoheal = 0)			
		if(src.internal && !heals_internal)
			// heal nothing
			return amount
		// persistant edit starts here
		// if the wound cant be healed by simple means
		if(!autoheal && !simpleheal) // a simple form of healing is being attempted for a wound only healable over time
			return amount
			
		// persistant edit ends here
		var/healed_damage = min(src.damage, amount)
		amount -= healed_damage
		src.damage -= healed_damage

		while(src.wound_damage() < damage_list[current_stage] && current_stage < src.desc_list.len)
			current_stage++
		desc = desc_list[current_stage]
		src.min_damage = damage_list[current_stage]

		// return amount of healing still leftover, can be used for other wounds
		return amount

	// opens the wound again
	proc/open_wound(damage)
		src.damage += damage
		bleed_timer += damage
		var/max_wound_damage = (src.damage_list[1] + 10)
		if(internal) // internal bleeding doesnt use this system
			max_wound_damage = INFINITY
		// if the damage is greater than what it should be.. upgrade the wound
		if(src.damage >= max_wound_damage)
			if(upgradeable && upgrade_type)
				var/datum/wound/Wo = new upgrade_type(src.damage)
				Wo.damage = src.damage
				Wo.bleed_timer = bleed_timer
				return Wo

		while(src.current_stage > 1 && src.damage_list[current_stage-1] <= src.damage / src.amount)
			src.current_stage--

		src.desc = desc_list[current_stage]
		src.min_damage = damage_list[current_stage]

	// returns whether this wound can absorb the given amount of damage.
	// this will prevent large amounts of damage being trapped in less severe wound types
	proc/can_worsen(damage_type, damage)
		if(src.damage_type != damage_type)
			return 0	//incompatible damage types

		if(src.amount > 1)
			return 0

		//with 1.5*, a shallow cut will be able to carry at most 30 damage,
		//37.5 for a deep cut
		//52.5 for a flesh wound, etc.
		var/max_wound_damage = 1.5*src.damage_list[1]
		if(src.damage + damage > max_wound_damage)
			return 0

		return 1
	proc/can_worsen_new(damage_type, damage)
		if(src.damage_type != damage_type)
			return 0	//incompatible damage types

	// this amount buisness is the stupidest thing
	// it will have to be dealt with

	//	if(src.amount > 1)
	//		return 0

	// wounds will get worse until they reach max damage and grow into a larger wound
	//	var/max_wound_damage = 1.5*src.damage_list[1]
	//	if(src.damage + damage > max_wound_damage)
	//		return 0

		return 1



	proc/bleeding()
		if(src.internal)
			return 0	// internal wounds don't bleed in the sense of this function

		if(current_stage > max_bleeding_stage)
			return 0

		if(bandaged||clamped)
			return 0

		if(wound_damage() <= 30 && bleed_timer <= 0)
			return 0	//Bleed timer has run out. Wounds with more than 30 damage don't stop bleeding on their own.

		return (damage_type == BRUISE && wound_damage() >= 20 || damage_type == CUT && wound_damage() >= 5)

/** WOUND DEFINITIONS **/

//Note that the MINIMUM damage before a wound can be applied should correspond to
//the damage amount for the stage with the same name as the wound.
//e.g. /datum/wound/cut/deep should only be applied for 15 damage and up,
//because in it's stages list, "deep cut" = 15.
/proc/get_wound_type(var/type = CUT, var/damage)
	switch(type)
		if(CUT)
			switch(damage)
				if(70 to INFINITY)
					return /datum/wound/cut/massive
				if(50 to 70)
					return /datum/wound/cut/gaping
				if(25 to 50)
					return /datum/wound/cut/flesh
				if(15 to 25)
					return /datum/wound/cut/deep
				if(0 to 15)
					return /datum/wound/cut/small
		if(BRUISE)
			switch(damage)
				if(60 to INFINITY)
					return /datum/wound/fracture
				if(0 to 60)
					return /datum/wound/bruise
		if(BURN)
			switch(damage)
				if(50 to INFINITY)
					return /datum/wound/burn/carbonised
				if(40 to 50)
					return /datum/wound/burn/deep
				if(30 to 40)
					return /datum/wound/burn/severe
				if(15 to 30)
					return /datum/wound/burn/large
				if(0 to 15)
					return /datum/wound/burn/moderate
	return null //no wound

/** CUTS **/
/datum/wound/cut/small
	// Minor cuts have max_bleeding_stage set to the stage that bears the wound type's name.
	// The major cut types have the max_bleeding_stage set to the clot stage (which is accordingly given the "blood soaked" descriptor).
	max_bleeding_stage = 3
	stages = list("ugly ripped cut" = 20, "ripped cut" = 10, "cut" = 5, "healing cut" = 2, "small scab" = 0)
	damage_type = CUT
	upgradeable = 1
	upgrade_type = /datum/wound/cut/deep
	opening_desc_visible = "you get a deep cut."		// thould be unused
/datum/wound/cut/deep
	max_bleeding_stage = 3
	stages = list("ugly deep ripped cut" = 25, "deep ripped cut" = 20, "deep cut" = 15, "clotted cut" = 8, "scab" = 2, "fresh skin" = 0)
	damage_type = CUT
	upgradeable = 1
	upgrade_type = /datum/wound/cut/flesh
	opening_desc_visible = "a cut drives deep into your flesh!"
/datum/wound/cut/flesh
	max_bleeding_stage = 3
	stages = list("ugly ripped flesh wound" = 35, "ugly flesh wound" = 30, "flesh wound" = 25, "blood soaked clot" = 15, "large scab" = 5, "fresh skin" = 0)
	damage_type = CUT
	upgradeable = 1
	upgrade_type = /datum/wound/cut/gaping
	opening_desc_visible = "your cut expands into a flesh wound!"
/datum/wound/cut/gaping
	max_bleeding_stage = 3
	stages = list("large gaping wound" = 50, "gaping wound" = 40, "flesh wound = 25", "blood soaked clot" = 15, "small angry scar" = 5, "small straight scar" = 0)
	damage_type = CUT
	upgradeable = 1
	upgrade_type = /datum/wound/cut/massive
	opening_desc_visible = "you feel the gaping wound, and the blood flowing freely."
	simpleheal = 0
/datum/wound/cut/massive
	max_bleeding_stage = 4
	stages = list("terrible gash" = 80, "massive gash" = 50, "big gaping wound" = 50, "flesh wound" = 35, "massive blood soaked clot" = 25, "massive angry scar" = 10,  "massive jagged scar" = 0)
	damage_type = CUT
	opening_desc_visible = "your gash becomes massive and you struggle to focus!"
	simpleheal = 0
/** BRUISES **/
/datum/wound/bruise
	stages = list("huge bruise" = 50, "large bruise" = 30,
				  "moderate bruise" = 20, "small bruise" = 10, "tiny bruise" = 5)
	//	max_bleeding_stage = 3 //for our purposes.. bruises shouldnt bleed
	autoheal_cutoff = 200 // BRUISES ALWAYS AUTO HEAL
	damage_type = BRUISE
	upgrade_type = /datum/wound/fracture
	upgradeable = 1
/datum/wound/fracture
	stages = list("compound fracture" = 60, "fracture" = 40, "partial fracture" = 30, "small fracture" = 20,
				  "recovering fracture" = 10, "recovered fracture" = 5, "scar tissue" = 0)
	//	max_bleeding_stage = 3 // only cuts should bleed maybe
	autoheal_cutoff = 20
	damage_type = BRUISE
	simpleheal = 0
	opening_desc_visible = "you feel a bone fracture and an intense pain surges through you."
	opening_desc_audible = "You hear the sickening sound of shattering bones."
/** BURNS **/
/datum/wound/burn/moderate
	stages = list("ripped burn" = 10, "moderate burn" = 5, "healing moderate burn" = 2, "fresh skin" = 0)
	damage_type = BURN
	upgradeable = 1
	upgrade_type = /datum/wound/burn/large
	opening_desc_visible = "the burn worsens."		// thould be unused
	opening_desc_audible = "You hear a nasty burning sound, there's a terrible smell of burning flesh." // should be unused for starting wounds (cant worsen to this)
/datum/wound/burn/large
	stages = list("ripped large burn" = 20, "large burn" = 15, "healing large burn" = 5, "fresh skin" = 0)
	damage_type = BURN
	upgradeable = 1
	upgrade_type = /datum/wound/burn/severe
	opening_desc_visible = "the burn worsens into a large red mark."
	opening_desc_audible = "You hear a nasty burning sound, there's a terrible smell of burning flesh."
/datum/wound/burn/severe
	stages = list("ripped severe burn" = 35, "severe burn" = 30, "healing severe burn" = 10, "burn scar" = 0)
	damage_type = BURN
	upgradeable = 1
	upgrade_type = /datum/wound/burn/deep
	opening_desc_visible = "the flesh turns bright red as the burning continues."
	opening_desc_audible = "You hear a nasty burning sound, there's a terrible smell of burning flesh."
/datum/wound/burn/deep
	stages = list("ripped deep burn" = 45, "deep burn" = 40, "healing deep burn" = 15,  "large burn scar" = 0)
	damage_type = BURN
	upgradeable = 1
	upgrade_type = /datum/wound/burn/carbonised
	simpleheal = 0
	opening_desc_visible = "the burning continues, penetrating deep into the flesh and damaging nerves."
	opening_desc_audible = "You hear a nasty burning sound, there's a terrible smell of burning flesh."
/datum/wound/burn/carbonised
	stages = list("severly carbonised area" = 70, "carbonised area" = 60, "healing carbonised area" = 20, "massive burn scar" = 0)
	damage_type = BURN
	opening_desc_visible = "flesh blackens as it begins to entirely carbonise."
	opening_desc_audible = "You hear a nasty burning sound, there's a terrible smell of burning flesh."
	simpleheal = 0
/** INTERNAL BLEEDING **/
/datum/wound/internal_bleeding
	internal = 1
	stages = list("severed artery" = 30, "cut artery" = 20, "damaged artery" = 10, "bruised artery" = 5)
	autoheal_cutoff = 5
	max_bleeding_stage = 4	//all stages bleed. It's called internal bleeding after all.


/** EXTERNAL ORGAN LOSS **/
/datum/wound/lost_limb

/datum/wound/lost_limb/New(var/obj/item/organ/external/lost_limb, var/losstype, var/clean)
	if(!lost_limb)
		return 1
	var/damage_amt = lost_limb.max_damage
	if(clean) damage_amt /= 2

	switch(losstype)
		if(DROPLIMB_EDGE, DROPLIMB_BLUNT)
			damage_type = CUT
			max_bleeding_stage = 3 //clotted stump and above can bleed.
			stages = list(
				"ripped stump" = damage_amt*1.3,
				"bloody stump" = damage_amt,
				"clotted stump" = damage_amt*0.5,
				"scarred stump" = 0
				)
		if(DROPLIMB_BURN)
			damage_type = BURN
			stages = list(
				"ripped charred stump" = damage_amt*1.3,
				"charred stump" = damage_amt,
				"scarred stump" = damage_amt*0.5,
				"scarred stump" = 0
				)

	..(damage_amt)

/datum/wound/lost_limb/can_merge(var/datum/wound/other)
	return 0 //cannot be merged
