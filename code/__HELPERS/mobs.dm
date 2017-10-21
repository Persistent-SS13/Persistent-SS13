proc/random_underwear(gender, species = "Human")
	var/list/pick_list = list()
	switch(gender)
		if(MALE)	pick_list = underwear_m
		if(FEMALE)	pick_list = underwear_f
		else		pick_list = underwear_list
	return pick_species_allowed_underwear(pick_list, species)

proc/random_undershirt(gender, species = "Human")
	var/list/pick_list = list()
	switch(gender)
		if(MALE)	pick_list = undershirt_m
		if(FEMALE)	pick_list = undershirt_f
		else		pick_list = undershirt_list
	return pick_species_allowed_underwear(pick_list, species)

proc/random_socks(gender, species = "Human")
	var/list/pick_list = list()
	switch(gender)
		if(MALE)	pick_list = socks_m
		if(FEMALE)	pick_list = socks_f
		else		pick_list = socks_list
	return pick_species_allowed_underwear(pick_list, species)

proc/pick_species_allowed_underwear(list/all_picks, species)
	var/list/valid_picks = list()
	for(var/test in all_picks)
		var/datum/sprite_accessory/S = all_picks[test]
		if(!(species in S.species_allowed))
			continue
		valid_picks += test

	if(!valid_picks.len) valid_picks += "Nude"

	return pick(valid_picks)

proc/random_hair_style(var/gender, species = "Human")
	var/h_style = "Bald"

	var/list/valid_hairstyles = list()
	for(var/hairstyle in hair_styles_list)
		var/datum/sprite_accessory/S = hair_styles_list[hairstyle]
		if(gender == MALE && S.gender == FEMALE)
			continue
		if(gender == FEMALE && S.gender == MALE)
			continue
		if( !(species in S.species_allowed))
			continue

		valid_hairstyles[hairstyle] = hair_styles_list[hairstyle]

	if(valid_hairstyles.len)
		h_style = pick(valid_hairstyles)

		return h_style

proc/GetOppositeDir(var/dir)
	switch(dir)
		if(NORTH)     return SOUTH
		if(SOUTH)     return NORTH
		if(EAST)      return WEST
		if(WEST)      return EAST
		if(SOUTHWEST) return NORTHEAST
		if(NORTHWEST) return SOUTHEAST
		if(NORTHEAST) return SOUTHWEST
		if(SOUTHEAST) return NORTHWEST
	return 0

proc/random_facial_hair_style(var/gender, species = "Human")
	var/f_style = "Shaved"

	var/list/valid_facialhairstyles = list()
	for(var/facialhairstyle in facial_hair_styles_list)
		var/datum/sprite_accessory/S = facial_hair_styles_list[facialhairstyle]
		if(gender == MALE && S.gender == FEMALE)
			continue
		if(gender == FEMALE && S.gender == MALE)
			continue
		if( !(species in S.species_allowed))
			continue

		valid_facialhairstyles[facialhairstyle] = facial_hair_styles_list[facialhairstyle]

	if(valid_facialhairstyles.len)
		f_style = pick(valid_facialhairstyles)

		return f_style

proc/random_name(gender, species = "Human")

	var/datum/species/current_species
	if(species)
		current_species = all_species[species]

	if(!current_species || current_species.name == "Human")
		if(gender==FEMALE)
			return capitalize(pick(first_names_female)) + " " + capitalize(pick(last_names))
		else
			return capitalize(pick(first_names_male)) + " " + capitalize(pick(last_names))
	else
		return current_species.get_random_name(gender)

proc/random_skin_tone(species = "Human")
	if(species == "Human" || species == "Drask")
		switch(pick(60;"caucasian", 15;"afroamerican", 10;"african", 10;"latino", 5;"albino"))
			if("caucasian")		. = -10
			if("afroamerican")	. = -115
			if("african")		. = -165
			if("latino")		. = -55
			if("albino")		. = 34
			else				. = rand(-185, 34)
		return min(max(. + rand(-25, 25), -185), 34)
	else if(species == "Vox")
		. = rand(1, 6)
		return .

proc/skintone2racedescription(tone, species = "Human")
	if(species == "Human")
		switch(tone)
			if(30 to INFINITY)		return "albino"
			if(20 to 30)			return "pale"
			if(5 to 15)				return "light skinned"
			if(-10 to 5)			return "white"
			if(-25 to -10)			return "tan"
			if(-45 to -25)			return "darker skinned"
			if(-65 to -45)			return "brown"
			if(-INFINITY to -65)	return "black"
			else					return "unknown"
	else if(species == "Vox")
		switch(tone)
			if(2)					return "dark green"
			if(3)					return "brown"
			if(4)					return "gray"
			if(5)					return "emerald"
			if(6)					return "azure"
			else					return "green"
	else
		return "unknown"

proc/age2agedescription(age)
	switch(age)
		if(0 to 1)			return "infant"
		if(1 to 3)			return "toddler"
		if(3 to 13)			return "child"
		if(13 to 19)		return "teenager"
		if(19 to 30)		return "young adult"
		if(30 to 45)		return "adult"
		if(45 to 60)		return "middle-aged"
		if(60 to 70)		return "aging"
		if(70 to INFINITY)	return "elderly"
		else				return "unknown"


/*
Proc for attack log creation, because really why not
1 argument is the actor
2 argument is the target of action
3 is the description of action(like punched, throwed, or any other verb)
4 is the tool with which the action was made(usually item)
5 is additional information, anything that needs to be added
6 is whether the attack should be logged to the log file and shown to admins
*/

proc/add_logs(mob/target, mob/user, what_done, var/object=null, var/addition=null, var/admin=1) //Victim : Attacker : what they did : what they did it with : extra notes
	var/list/ignore=list("shaked","CPRed","grabbed","punched")
	if(!user)
		return
	if(ismob(user))
		user.attack_log += text("\[[time_stamp()]\] <font color='red'>Has [what_done] [key_name(target)][object ? " with [object]" : " "][addition]</font>")
	if(ismob(target))
		target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been [what_done] by [key_name(user)][object ? " with [object]" : " "][addition]</font>")
	if(admin)
		log_attack("<font color='red'>[key_name(user)] [what_done] [key_name(target)][object ? " with [object]" : " "][addition]</font>")
	if(istype(target) && (target.client || target.player_logged))
		if(what_done in ignore) return
		if(target == user)return
		if(!admin) return
		msg_admin_attack("[key_name_admin(user)] [what_done] [key_name_admin(target)][object ? " with [object]" : " "][addition]")

/proc/do_mob(var/mob/user, var/mob/target, var/time = 30, var/uninterruptible = 0, progress = 1)
	if(!user || !target)
		return 0
	var/user_loc = user.loc

	var/drifting = 0
	if(!user.Process_Spacemove(0) && user.inertia_dir)
		drifting = 1

	var/target_loc = target.loc

	var/holding = user.get_active_hand()
	var/datum/progressbar/progbar
	if(progress)
		progbar = new(user, time, target)

	var/endtime = world.time+time
	var/starttime = world.time
	. = 1
	while(world.time < endtime)
		sleep(1)
		if(progress)
			progbar.update(world.time - starttime)
		if(!user || !target)
			. = 0
			break
		if(uninterruptible)
			continue

		if(drifting && !user.inertia_dir)
			drifting = 0
			user_loc = user.loc

		if((!drifting && user.loc != user_loc) || target.loc != target_loc || user.get_active_hand() != holding || user.incapacitated() || user.lying )
			. = 0
			break
	if(progress)
		qdel(progbar)

/proc/do_after(mob/user, delay, needhand = 1, atom/target = null, progress = 1)
	if(!user)
		return 0
	var/atom/Tloc = null
	if(target)
		Tloc = target.loc

	var/atom/Uloc = user.loc

	var/drifting = 0
	if(!user.Process_Spacemove(0) && user.inertia_dir)
		drifting = 1

	var/holding = user.get_active_hand()

	var/holdingnull = 1 //User's hand started out empty, check for an empty hand
	if(holding)
		holdingnull = 0 //Users hand started holding something, check to see if it's still holding that

	var/datum/progressbar/progbar
	if(progress)
		progbar = new(user, delay, target)

	var/endtime = world.time + delay
	var/starttime = world.time
	. = 1
	while(world.time < endtime)
		sleep(1)
		if(progress)
			progbar.update(world.time - starttime)

		if(drifting && !user.inertia_dir)
			drifting = 0
			Uloc = user.loc

		if(!user || user.stat || user.weakened || user.stunned  || (!drifting && user.loc != Uloc))
			. = 0
			break

		if(Tloc && (!target || Tloc != target.loc))
			. = 0
			break

		if(needhand)
			//This might seem like an odd check, but you can still need a hand even when it's empty
			//i.e the hand is used to pull some item/tool out of the construction
			if(!holdingnull)
				if(!holding)
					. = 0
					break
			if(user.get_active_hand() != holding)
				. = 0
				break
	if(progress)
		qdel(progbar)
		
///////////////////////////////////////		
///////////do_after_autoemote///////////////
// helper for do_after_stat		
/proc/do_after_autoemote(mob/user, var/stat_used, var/difference, var/action_name)
	switch(stat_used)
		if(1 to 2)// grit and fortitude
			switch(difference)
				if(6 to INFINITY)
					switch(pick(1,2,3))
						if(1)
							user.visible_message("[user] struggles and strains to [action_name].")
						if(2)
							user.visible_message("[user] groans with effort as they [action_name].")
						if(3)
							user.visible_message("[user] takes deep breaths as they struggle to [action_name].")
				if(2 to 6)
					switch(pick(1,2,3))
						if(1)
							user.visible_message("[user] moderately strains to [action_name].")
						if(2)
							user.visible_message("[user] makes a quiet grunt as they [action_name].")
						if(3)
							user.visible_message("[user] seems only slighly fatigued as they [action_name].")
				if(-INFINITY to 2)
					switch(pick(1,2,3))
						if(1)
							user.visible_message("[user] continues to effortlessly [action_name].")
						if(2)
							user.visible_message("[user] proceeds to [action_name] without much visible effort.")
						if(3)
							user.visible_message("[user] proceeds to [action_name] with an impressive display of [stat_used == 1 ? "grit" : "fortitude"].")
		if(3)// reflex
			switch(difference)
				if(6 to INFINITY)
					switch(pick(1,2,3))
						if(1)
							user.visible_message("[user] seems to lack the agility to [action_name] efficently.")
						if(2)
							user.visible_message("[user] struggles to [action_name], constantly having to stop and start over.")
						if(3)
							user.visible_message("[user] looks very frustrated as they [action_name] without having sufficent reflexes.")
				if(2 to 6)
					switch(pick(1,2,3))
						if(1)
							user.visible_message("[user] slowly and capably continues to [action_name].")
						if(2)
							user.visible_message("[user] intensely focuses as they [action_name], demonstrating passable agility.")
						if(3)
							user.visible_message("[user] carefully continues to [action_name] with only moderate difficulty.")
				if(-INFINITY to 2)
					switch(pick(1,2,3))
						if(1)
							user.visible_message("[user] continues to quickly [action_name].")
						if(2)
							user.visible_message("[user] proceeds to deftly [action_name].")
						if(3)
							user.visible_message("[user] ably continues to [action_name].")
		if(4 to 5)// creativity and focus
			switch(difference)
				if(6 to INFINITY)
					switch(pick(1,2,3))
						if(1)
							user.visible_message("[user] is visibly frustrated while trying to [action_name].")
						if(2)
							user.visible_message("[user] struggles to maintain focus as they [action_name].")
						if(3)
							user.visible_message("[user] looks stumped and frustrated as they [action_name].")
				if(2 to 6)
					switch(pick(1,2,3))
						if(1)
							user.visible_message("[user] intensely focuses on trying to [action_name] and seems to be making slow, steady progress.")
						if(2)
							user.visible_message("[user] murmers to themselves as they [action_name], demonstrating sufficent [stat_used == 4 ? "creativity" : "focus"].")
						if(3)
							user.visible_message("[user] seems moderately puzzled as they [action_name].")
				if(-INFINITY to 2)
					switch(pick(1,2,3))
						if(1)
							user.visible_message("[user] seems quite adept at [action_name].")
						if(2)
							user.visible_message("[user] proceeds to [action_name] very efficiently.")
						if(3)
							user.visible_message("[user] ably continues to [action_name].")
///////////////////////////////////////		
///////////do_after_stat///////////////
//	based on do_after
// user = the person doing the action
// delay = the maximum delay the action takes
// needhand = whether the characters primary selected hand is relevant
// target = the obj or mob the action is being done to
// progress = whether to display the progress bar
// action_name = a description of the action that fits the back end of a sentence EX. You start to [action_name] action_name = "swing a pickaxe" action_name = "unscrew the maintenence panel"
// auto_emote = whether the action should trigger autoemote (EG. "[user] struggles while [action_name]"). requires a maximum
// stat_used = which stat is being used
// minimum = what is the minimum stat required to sucessfully complete the action
// maximum = the stat required to complete the stat as quickly as possible, if left 0 then the normal delay will always be usd
// maxed_delay = the shortest possible time to complete the action given a stat that reaches the maximum, if null the action will always use the same delay
// progressive_failure = if 1 the action will succeed based on a probability where a stat at maximum is 100% chance and a stat at minimum gives the [minimum_probability]% chance. if 0 the action will always succeed if the minimum stat requirement is reached
// minimum_probabilty = the probability used if progreessive failure is on and the stat is at minimum. probability will progressively increase to 100% as the stat increases to maximum
// help_able = whether mobs adjacent to the target with their intent set to help will be able to assist the action and add their own stats to the equation (multipled by help_ratio)
// help_ratio = the ratio that the helper mobs stats will be added. usually between 1 and 0
// stamina_use = if 1 physical stamina will be used, if 2 mental stamina will be used if 0 no stamina will be used
// stamina_used = how much stamina is used (if any)
// progressive_stamina = if 1 then the mob will have stamina_use * the difference between minimum and maximum that their stat falls in + 1 (if your stat is max or greater than only stamina_used*1 will be subtracted)
// attempt_cost = stamina used as soon as the player attempts the action
// stamina_use_fail = a multiplier applied to the amount of stamina used on fail. 0 will use no stamina if the action fails, 1 will use the normal amount and 2 will double the amount of stamina used on failure.
// a sound to be played (at 40 volume) when the progress starts
/proc/do_after_stat(mob/user, delay, needhand = 1, atom/target = null, progress = 1, var/action_name = "doing an action.", var/auto_emote = 0, var/stat_used = 3, var/minimum = 0, var/maximum = 0, var/maxed_delay, var/progressive_failure = 0, var/minimum_probability = 50, var/help_able = 0, var/help_ratio = 1, var/stamina_use = 0, var/stamina_used = 0, var/progressive_stamina, var/attempt_cost = 0, var/stamina_use_fail = 0, var/sound_file) // PERSISTANT EDIT! STAT QUERIES
	if(!user)
		return 0
	if(user.doing_action)
		to_chat(user, "You are already doing something. Move away to cancel your current action.")
		return 0
	var/atom/Tloc = null
	if(target)
		Tloc = target.loc

	var/atom/Uloc = user.loc

	var/drifting = 0
	if(!user.Process_Spacemove(0) && user.inertia_dir)
		drifting = 1

	var/holding = user.get_active_hand()

	var/holdingnull = 1 //User's hand started out empty, check for an empty hand
	if(holding)
		holdingnull = 0 //Users hand started holding something, check to see if it's still holding that

	var/final_delay
	var/helperless_delay
	var/stat_value = user.get_stat(stat_used)
	var/user_stat_value = stat_value
	var/helper_value = 0
	var/Hloc
	var/mob/helper
	var/using_helper = 0
	var/stamina_use_user = 0
	var/stamina_use_helper = 0
	if(stamina_use)
		if(progressive_stamina)
			if(stat_value >= maximum)
				if(!user.check_stamina(stamina_used+attempt_cost, stamina_use))
					to_chat(user,"You feel too [stamina_use == 2 ? "mentally" : "physically"] exhausted to do that.")
					return 0
				stamina_use_user = stamina_used
			else
				var/difference = (maximum - minimum)
				var/stat_diff = max(stat_value - minimum, 0)
				var/multiplier = (max(difference - stat_diff, 0) + 1)
				if(!user.check_stamina((stamina_used*multiplier)+attempt_cost, stamina_use))
					to_chat(user,"You feel too exhausted to do that.")
					return 0
				stamina_use_user = (stamina_used*multiplier)
		else
			if(!user.check_stamina(stamina_used+attempt_cost, stamina_use))
				to_chat(user,"You feel too exhausted to do that.")
				return 0
			stamina_use_user = stamina_used
	if(Tloc && help_able)
		for(var/mob/M in range(2, Tloc))
			if(M == user || M.stat || M.weakened || M.stunned || M.doing_action)
				continue
			else
				var/temp_val = M.get_stat(stat_used)
				if(temp_val > helper_value)
					if(stamina_use)
						if(progressive_stamina)
							if(stat_value >= maximum)
								if(!M.check_stamina(stamina_used, stamina_use))
									continue
								stamina_use_helper = stamina_used
							else
								var/difference = (maximum - minimum)
								var/stat_diff = max((M.get_stat(stat_used) + stat_value) - minimum, 0)
								var/multiplier = (max(difference - stat_diff, 0) + 1)
								if(!user.check_stamina(stamina_used*multiplier, stamina_use))
									continue
								stamina_use_helper = (stamina_used*multiplier)/2
						else
							if(!user.check_stamina(stamina_used, stamina_use))
								continue
							stamina_use_helper = stamina_used
					helper_value = temp_val
					helper = M
	
	if(helper)
		using_helper = 1
		helper_value = user.get_stat(stat_used) * help_ratio
		stat_value += helper_value
		Hloc = helper.loc
	
	if(maximum && maxed_delay)
		if(stat_value >= maximum)
			final_delay = maxed_delay
		else if((stat_value <= minimum))
			final_delay = delay
		else
			var/diff = maximum - minimum
			var/delay_diff = delay - maxed_delay
			var/divide
			if(!diff <= 0)
				divide = (delay_diff / diff)
			if(divide)
				var/stat_diff = stat_value - minimum
				var/minus = (divide * stat_diff)
				final_delay = delay - minus
			else
				final_delay = delay
		if(helper)
			if(user_stat_value >= maximum)
				helperless_delay = maxed_delay
			else if((user_stat_value <= minimum))
				helperless_delay = delay
			else
				var/diff = maximum - minimum
				var/delay_diff = delay - maxed_delay
				var/divide
				if(!diff <= 0)
					divide = (delay_diff / diff)
				if(divide)
					var/stat_diff = user_stat_value - minimum
					var/minus = (divide * stat_diff)
					helperless_delay = delay - minus
				else
					helperless_delay = delay
		else
			helperless_delay = final_delay
	else
		final_delay = delay
		helperless_delay = delay
	var/helperless_return
	var/final_prob = 0
	to_chat(user, "You begin doing a [get_stat_name(stat_used)]-based action. Remain still [needhand ? "and dont switch hands" : ""] to continue.")
	if(minimum)
		if(progressive_failure)
			if(stat_value < minimum)
				. = 2
			else	
				var/diff = maximum - minimum
				var/prob_diff = 100 - minimum_probability
				if(prob_diff <= 0)
					. = 1
				else
					var/part = prob_diff / diff
					var/stat_diff = stat_value - minimum
					final_prob = (stat_diff * part) + minimum_probability
					message_admins("stat_value : [stat_value] stat_diff : [stat_diff] final_prob : [final_prob]")
					var/final = prob(final_prob)
					if(!final) final = 2
					. = final			
		else
			if(stat_value < minimum)
				. = 2
			else
				. = 1
		if(helper)
			if(progressive_failure)
				if(user_stat_value < minimum)
					helperless_return = 2
				else	
					var/diff = maximum - minimum
					var/prob_diff = 100 - minimum_probability
					if(prob_diff <= 0)
						helperless_return = 1
					else
						var/part = prob_diff / diff
						var/stat_diff = user_stat_value - minimum
						final_prob = stat_diff * part
						var/final = prob(final_prob)
						if(!final) final = 2
						helperless_return = final			
			else
				if(user_stat_value < minimum)
					helperless_return = 2
				else
					helperless_return = 1
		else
			helperless_return = .
	else
		. = 1
		helperless_return = .
	var/datum/progressbar/progbar
	var/datum/progressbar/helperprogbar
	var/difference = final_delay - helperless_delay
	var/endtime = world.time + final_delay
	var/helperlessendtime = world.time + helperless_delay
	var/starttime = world.time
	user.doing_action = 1
	if(progress)
		progbar = new(user, final_delay, user)
		if(helper)
			helperprogbar = new(helper, final_delay, helper)
	if(helper)
		to_chat(helper, "You start assisting [user.name] in [action_name]. Move away to stop assisting.")
		helper.doing_action = 1
	var/attempt_actual = user.use_stamina(attempt_cost, stamina_use)
	if(sound_file)
		if(istype(target, /turf/))
			playsound(target, sound_file, 80, 1)
		else
			playsound(target.loc, sound_file, 40, 1)
	while(world.time < endtime)
		sleep(1)
		if(progress)
			progbar.update(world.time - starttime)
		if(helperprogbar)
			helperprogbar.update(world.time - starttime)
		if(drifting && !user.inertia_dir)
			drifting = 0
			Uloc = user.loc

		if(!user || user.stat || user.weakened || user.stunned  || (!drifting && user.loc != Uloc))
			if(helper)
				helper.doing_action = 0
				if(user.stat || user.weakened || user.stunned)
					to_chat(helper, "[user.name] can no longer continue so you stop assisting them.")
				else if(user)
					to_chat(helper, "[user.name] has moved away so you stop assisting them.")
			user.doing_action = 0
			. = 0
			break
		if(Tloc && (!target || Tloc != target.loc))
			. = 0
			break
		if(using_helper)
			if(!helper || helper.stat || helper.weakened || helper.stunned  || helper.loc != Hloc)	
				endtime += difference
				starttime += difference
				. = helperless_return
				if(helperprogbar)
					qdel(helperprogbar)
				using_helper = 0
				to_chat(user, "You are no longer being helped.")
				if(helper)
					helper.doing_action = 0
					to_chat(helper, "You are no longer helping [user]")
				helper = null	
				
		if(needhand)
			//This might seem like an odd check, but you can still need a hand even when it's empty
			//i.e the hand is used to pull some item/tool out of the construction
			if(!holdingnull)
				if(!holding)
					if(helper)
						helper.doing_action = 0
						to_chat(helper, "[user.name] has stopped and so you stop assisting them.")
					user.doing_action = 0
					. = 0
					break
			if(user.get_active_hand() != holding)
				if(helper)
					helper.doing_action = 0
					to_chat(helper, "[user.name] has stopped and so you stop assisting them.")
				user.doing_action = 0
				. = 0
				break
		if(auto_emote)
			if(user.last_autoemote < world.time && prob(1))
				do_after_autoemote(user, stat_used, (maximum - stat_value), action_name)
				user.last_autoemote = world.time + 300
	user.doing_action = 0
	if(helper)
		helper.doing_action = 0
	var/actual_used = 0
	if(. == 2)
		actual_used = user.use_stamina(stamina_use_user*stamina_use_fail, stamina_use)
		if(progressive_failure && maximum)
			to_chat(user,"You fail the [get_stat_name(stat_used)] action. You had a [final_prob] chance to succeed.")
		else
			to_chat(user,"You fail the [get_stat_name(stat_used)] action. You need to get your [get_stat_name(stat_used)] stat higher!")
	else if(. == 1)
		to_chat(user, "You successfully complete the [get_stat_name(stat_used)] action.")
		actual_used = user.use_stamina(stamina_use_user, stamina_use)
	if(stamina_use)
		to_chat(user, "You used [actual_used+attempt_actual] [stamina_use == 2 ? "will" : "stamina"].")
	if(stamina_use_helper && helper)
		if(. == 2)
			helper.use_stamina(stamina_use_helper*stamina_use_fail, stamina_use)
			to_chat(helper,"Your combined efforts fail to complete the [get_stat_name(stat_used)] action.")
		else if(. == 1)
			helper.use_stamina(stamina_use_helper, stamina_use)
			to_chat(helper, "You help to successfully complete the [get_stat_name(stat_used)] action.")
			
	message_admins("do_after_stat: User: [user], Stat: [get_stat_name(stat_used)] Return: [.], Stamina Type:[stamina_use], Stamina Used: [stamina_use_user+attempt_cost]")
	if(progress)
		qdel(progbar)
	if(helperprogbar)
		qdel(helperprogbar)
/proc/admin_mob_info(mob/M, mob/user = usr)
	if(!ismob(M))
		to_chat(user, "This can only be used on instances of type /mob")
		return

	var/location_description = ""
	var/special_role_description = ""
	var/health_description = ""
	var/gender_description = ""
	var/turf/T = get_turf(M)

	//Location
	if(isturf(T))
		if(isarea(T.loc))
			location_description = "([M.loc == T ? "at coordinates " : "in [M.loc] at coordinates "] [T.x], [T.y], [T.z] in area <b>[T.loc]</b>)"
		else
			location_description = "([M.loc == T ? "at coordinates " : "in [M.loc] at coordinates "] [T.x], [T.y], [T.z])"

	//Job + antagonist
	if(M.mind)
		special_role_description = "Role: <b>[M.mind.assigned_role]</b>; Antagonist: <font color='red'><b>[M.mind.special_role]</b></font>; Has been rev: [(M.mind.has_been_rev)?"Yes":"No"]"
	else
		special_role_description = "Role: <i>Mind datum missing</i> Antagonist: <i>Mind datum missing</i>; Has been rev: <i>Mind datum missing</i>;"

	//Health
	if(isliving(M))
		var/mob/living/L = M
		var/status
		switch(M.stat)
			if(CONSCIOUS) 
				status = "Alive"
			if(UNCONSCIOUS)
				status = "<font color='orange'><b>Unconscious</b></font>"
			if(DEAD)
				status = "<font color='red'><b>Dead</b></font>"
		health_description = "Status = [status]"
		health_description += "<BR>Oxy: [L.getOxyLoss()] - Tox: [L.getToxLoss()] - Fire: [L.getFireLoss()] - Brute: [L.getBruteLoss()] - Clone: [L.getCloneLoss()] - Brain: [L.getBrainLoss()]"
	else
		health_description = "This mob type has no health to speak of."

	//Gener
	switch(M.gender)
		if(MALE, FEMALE)
			gender_description = "[M.gender]"
		else
			gender_description = "<font color='red'><b>[M.gender]</b></font>"

	to_chat(user, "<b>Info about [M.name]:</b> ")
	to_chat(user, "Mob type = [M.type]; Gender = [gender_description] Damage = [health_description]")
	to_chat(user, "Name = <b>[M.name]</b>; Real_name = [M.real_name]; Mind_name = [M.mind?"[M.mind.name]":""]; Key = <b>[M.key]</b>;")
	to_chat(user, "Location = [location_description];")
	to_chat(user, "[special_role_description]")
	to_chat(user, "(<a href='?src=\ref[usr];priv_msg=\ref[M]'>PM</a>) (<A HREF='?src=\ref[src];adminplayeropts=\ref[M]'>PP</A>) (<A HREF='?_src_=vars;Vars=\ref[M]'>VV</A>) (<A HREF='?src=\ref[src];subtlemessage=\ref[M]'>SM</A>) (<A HREF='?src=\ref[src];adminplayerobservefollow=\ref[M]'>FLW</A>) (<A HREF='?src=\ref[src];secretsadmin=check_antagonist'>CA</A>)")

// Gets the first mob contained in an atom, and warns the user if there's not exactly one
/proc/get_mob_in_atom_with_warning(atom/A, mob/user = usr)
	if(!istype(A))
		return null
	if(ismob(A))
		return A

	. = null
	for(var/mob/M in A)
		if(!.)
			. = M
		else
			to_chat(user, "<span class='warning'>Multiple mobs in [A], using first mob found...</span>")
			break
	if(!.)
		to_chat(user, "<span class='warning'>No mob located in [A].</span>")
