/**********************Light************************/

//this item is intended to give the effect of entering the mine, so that light gradually fades
/obj/effect/light_emitter
	name = "Light-emtter"
	anchored = 1
	unacidable = 1
	light_range = 8

/**********************Miner Lockers**************************/

/obj/structure/closet/wardrobe/miner
	name = "mining wardrobe"
	icon_state = "mixed"
	icon_closed = "mixed"

/obj/structure/closet/wardrobe/miner/New()
	..()
	contents = list()
	new /obj/item/weapon/storage/backpack/duffel(src)
	new /obj/item/weapon/storage/backpack/industrial(src)
	new /obj/item/weapon/storage/backpack/satchel_eng(src)
	new /obj/item/clothing/under/rank/miner(src)
	new /obj/item/clothing/under/rank/miner(src)
	new /obj/item/clothing/under/rank/miner(src)
	new /obj/item/clothing/shoes/workboots(src)
	new /obj/item/clothing/shoes/workboots(src)
	new /obj/item/clothing/shoes/workboots(src)
	new /obj/item/clothing/gloves/fingerless(src)
	new /obj/item/clothing/gloves/fingerless(src)
	new /obj/item/clothing/gloves/fingerless(src)

/obj/structure/closet/secure_closet/miner
	name = "miner's equipment"
	icon_state = "miningsec1"
	icon_closed = "miningsec"
	icon_locked = "miningsec1"
	icon_opened = "miningsecopen"
	icon_broken = "miningsecbroken"
	icon_off = "miningsecoff"
	req_access = list(access_mining)

/obj/structure/closet/secure_closet/miner/New()
	..()
	new /obj/item/weapon/shovel(src)
	new /obj/item/weapon/pickaxe(src)
	new /obj/item/device/radio/headset/headset_cargo/mining(src)
	new /obj/item/device/mineral_scanner(src)
	new /obj/item/clothing/glasses/meson(src)

/**********************Shuttle Computer**************************/

/obj/machinery/computer/shuttle/mining
	name = "Mining Shuttle Console"
	desc = "Used to call and send the mining shuttle."
	circuit = /obj/item/weapon/circuitboard/mining_shuttle
	shuttleId = "mining"
	possible_destinations = "mining_home;mining_away"

/******************************Lantern*******************************/

/obj/item/device/flashlight/lantern
	name = "lantern"
	icon_state = "lantern"
	desc = "A mining lantern."
	brightness_on = 6			// luminosity when on

/*****************************Pickaxe********************************/

/obj/item/weapon/pickaxe
	name = "pickaxe"
	icon = 'icons/obj/items.dmi'
	icon_state = "pickaxe"
	flags = CONDUCT
	slot_flags = SLOT_BELT
	force = 15.0
	throwforce = 10.0
	item_state = "pickaxe"
	w_class = 4
	materials = list(MAT_METAL=2000) //one sheet, but where can you make them?
	var/digspeed = 40 //moving the delay to an item var so R&D can make improved picks. --NEO
	origin_tech = "materials=1;engineering=1"
	attack_verb = list("hit", "pierced", "sliced", "attacked")
	var/list/digsound = list('sound/effects/picaxe1.ogg','sound/effects/picaxe2.ogg','sound/effects/picaxe3.ogg')
	var/drill_verb = "picking"
	sharp = 1
	edge = 1
	var/excavation_amount = 100

/obj/item/weapon/pickaxe/proc/playDigSound()
		playsound(src, ,20,1)

/obj/item/weapon/pickaxe/silver
	name = "silver-plated pickaxe"
	icon_state = "spickaxe"
	item_state = "spickaxe"
	digspeed = 30 //mines faster than a normal pickaxe, bought from mining vendor
	origin_tech = "materials=3;engineering=2"
	desc = "A silver-plated pickaxe that mines slightly faster than standard-issue."

/obj/item/weapon/pickaxe/diamond
	name = "diamond-tipped pickaxe"
	icon_state = "dpickaxe"
	item_state = "dpickaxe"
	digspeed = 20 //mines twice as fast as a normal pickaxe, bought from mining vendor
	origin_tech = "materials=4;engineering=3"
	desc = "A pickaxe with a diamond pick head. Extremely robust at cracking rock walls and digging up dirt."

/obj/item/weapon/pickaxe/drill
	name = "mining drill"
	icon_state = "handdrill"
	item_state = "jackhammer"
	digspeed = 25 //available from roundstart, faster than a pickaxe.
	digsound = list('sound/weapons/drill.ogg')
	hitsound = 'sound/weapons/drill.ogg'
	origin_tech = "materials=2;powerstorage=3;engineering=2"
	desc = "An electric mining drill for the especially scrawny."

/obj/item/weapon/pickaxe/drill/cyborg
	name = "cyborg mining drill"
	desc = "An integrated electric mining drill."
	flags = NODROP

/obj/item/weapon/pickaxe/drill/diamonddrill
	name = "diamond-tipped mining drill"
	icon_state = "diamonddrill"
	digspeed = 10
	origin_tech = "materials=6;powerstorage=4;engineering=5"
	desc = "Yours is the drill that will pierce the heavens!"

/obj/item/weapon/pickaxe/diamonddrill/traitor //Pocket-sized traitor diamond drill.
	name = "supermatter drill"
	icon_state = "smdrill"
	origin_tech = "materials=6;powerstorage=4;engineering=5;syndicate=3"
	desc = "Microscopic supermatter crystals cover the head of this tiny drill."
	w_class = 2

/obj/item/weapon/pickaxe/drill/cyborg/diamond //This is the BORG version!
	name = "diamond-tipped cyborg mining drill" //To inherit the NODROP flag, and easier to change borg specific drill mechanics.
	icon_state = "diamonddrill"
	digspeed = 10

/obj/item/weapon/pickaxe/drill/jackhammer
	name = "sonic jackhammer"
	icon_state = "jackhammer"
	item_state = "jackhammer"
	digspeed = 5 //the epitome of powertools. extremely fast mining, laughs at puny walls
	origin_tech = "materials=3;powerstorage=2;engineering=2"
	digsound = list('sound/weapons/sonic_jackhammer.ogg')
	hitsound = 'sound/weapons/sonic_jackhammer.ogg'
	desc = "Cracks rocks with sonic blasts, and doubles as a demolition power tool for smashing walls."

/obj/item/weapon/pickaxe/silver
	name = "silver pickaxe"
	icon_state = "spickaxe"
	item_state = "spickaxe"
	digspeed = 30
	origin_tech = "materials=3"
	desc = "This makes no metallurgic sense."

/obj/item/weapon/pickaxe/gold
	name = "golden pickaxe"
	icon_state = "gpickaxe"
	item_state = "gpickaxe"
	digspeed = 20
	origin_tech = "materials=4"
	desc = "This makes no metallurgic sense."
/*****************************Shovel********************************/

/obj/item/weapon/shovel
	name = "shovel"
	desc = "A large tool for digging and moving dirt."
	icon = 'icons/obj/items.dmi'
	icon_state = "shovel"
	flags = CONDUCT
	slot_flags = SLOT_BELT
	force = 8.0
	throwforce = 4.0
	item_state = "shovel"
	w_class = 3
	materials = list(MAT_METAL=50)
	origin_tech = "materials=1;engineering=1"
	attack_verb = list("bashed", "bludgeoned", "thrashed", "whacked")

/obj/item/weapon/shovel/spade
	name = "spade"
	desc = "A small tool for digging and moving dirt."
	icon_state = "spade"
	item_state = "spade"
	force = 5.0
	throwforce = 7.0
	w_class = 2


/**********************Mining car (Crate like thing, not the rail car)**************************/

/obj/structure/closet/crate/miningcar
	desc = "A mining car. This one doesn't work on rails, but has to be dragged."
	name = "mining car (not for rails)"
	icon = 'icons/obj/storage.dmi'
	icon_state = "miningcar"
	density = 1
	icon_opened = "miningcaropen"
	icon_closed = "miningcar"

/*********************Mob Capsule*************************/

/obj/item/device/mobcapsule
	name = "lazarus capsule"
	desc = "It allows you to store and deploy lazarus-injected creatures easier."
	icon = 'icons/obj/mobcap.dmi'
	icon_state = "mobcap0"
	w_class = 1
	throw_range = 20
	var/mob/living/simple_animal/captured = null
	var/colorindex = 0

/obj/item/device/mobcapsule/Destroy()
	if(captured)
		qdel(captured)
		captured = null
	return ..()

/obj/item/device/mobcapsule/attack(var/atom/A, mob/user, prox_flag)
	if(!istype(A, /mob/living/simple_animal) || isbot(A))
		return ..()
	capture(A, user)
	return 1

/obj/item/device/mobcapsule/proc/capture(var/mob/target, var/mob/U as mob)
	var/mob/living/simple_animal/T = target
	if(captured)
		to_chat(U, "<span class='notice'>Capture failed!</span>: The capsule already has a mob registered to it!")
	else
		if(istype(T) && "neutral" in T.faction)
			T.forceMove(src)
			T.name = "[U.name]'s [initial(T.name)]"
			T.cancel_camera()
			name = "Lazarus Capsule: [initial(T.name)]"
			to_chat(U, "<span class='notice'>You placed a [T.name] inside the Lazarus Capsule!</span>")
			captured = T
		else
			to_chat(U, "You can't capture that mob!")

/obj/item/device/mobcapsule/throw_impact(atom/A, mob/user)
	..()
	if(captured)
		dump_contents(user)

/obj/item/device/mobcapsule/proc/dump_contents(mob/user)
	if(captured)
		captured.forceMove(get_turf(src))
		if(captured.client)
			captured.client.eye = captured.client.mob
			captured.client.perspective = MOB_PERSPECTIVE
		captured = null

/obj/item/device/mobcapsule/attack_self(mob/user)
	colorindex += 1
	if(colorindex >= 6)
		colorindex = 0
	icon_state = "mobcap[colorindex]"
	update_icon()

//Fans
/obj/structure/fans
	icon = 'icons/obj/lavaland/survival_pod.dmi'
	icon_state = "fans"
	name = "environmental regulation system"
	desc = "A large machine releasing a constant gust of air."
	anchored = 1
	density = 1
	var/arbitraryatmosblockingvar = 1
	var/buildstacktype = /obj/item/stack/sheet/metal
	var/buildstackamount = 5

/obj/structure/fans/proc/deconstruct()
	if(buildstacktype)
		new buildstacktype(loc, buildstackamount)
	qdel(src)

/obj/structure/fans/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/weapon/wrench))
		playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
		user.visible_message("<span class='warning'>[user] disassembles the fan.</span>", \
							 "<span class='notice'>You start to disassemble the fan...</span>", "You hear clanking and banging noises.")
		if(do_after(user, 20, target = src))
			deconstruct()
			return ..()

/obj/structure/fans/tiny
	name = "tiny fan"
	desc = "A tiny fan, releasing a thin gust of air."
	layer = TURF_LAYER+0.1
	density = 0
	icon_state = "fan_tiny"
	buildstackamount = 2

/obj/structure/fans/New(loc)
	..()
	air_update_turf(1)

/obj/structure/fans/Destroy()
	arbitraryatmosblockingvar = 0
	air_update_turf(1)
	return ..()

/obj/structure/fans/CanAtmosPass(turf/T)

	return !arbitraryatmosblockingvar
	
// PERSISTANT EDIT!!

/obj/machinery/auger
	name = "electro-pneumatic surface auger"
	desc = "A large verticle auger mounted on a circular steel frame."
	icon = 'icons/obj/mining_drill.dmi'
	icon_state = "mining_drill"
	var/active = 0
	var/progress = 0
	anchored = 0
	var/obj/item/weapon/stock_parts/cell/cell
	var/output_dir = SOUTH
	density = 1
	layer = 20		//to go over ores
	w_class = 10
	var/datum/progressbar/progbar
	var/mining_speed = 7 // number of ticks to take..
	var/broken = 0	// once science gets done, this'll be replaced with component handling
	var/health = 5
	var/maxhealth = 5
/obj/machinery/auger/Move()
	..()
	if(mineController && get_area(src) == mineController.target_area)
		mineController.handle_pull(loc)
/obj/machinery/auger/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	user.set_machine(src)
	var/data[0]
	data["src"] = "\ref[src]"
	var/over_turf = istype(loc, /turf/simulated/floor/plating/airless/asteroid)
	data["over_turf"] = over_turf
	if(over_turf)
		if(istype(loc, /turf/simulated/floor/plating/airless/asteroid/ore))
			var/turf/simulated/floor/plating/airless/asteroid/ore/ore_turf = loc
			data["over_ore"] = ore_turf.oretype
			data["remaining"] = ore_turf.resource_remaining
	data["anchored"] = anchored
	data["unanchorable"] = (anchored && !active)
	data["active"] = active
	data["maintenance"] = panel_open
	data["malfunction"] = broken
	data["warning"] = (maxhealth/3 > health)
	data["health"] = health
	data["maxhealth"] = maxhealth
	data["can_activate"] = (!broken && !active && !panel_open && anchored && over_turf)
	switch(output_dir)
		if(1)
			data["output_dir"] = "North"
		if(2)
			data["output_dir"] = "South"
		if(8)
			data["output_dir"] = "West"
		if(4)
			data["output_dir"] = "East"
	data["direction"] = output_dir
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "auger.tmpl", src.name, 450, 450, state = physical_state)
		ui.set_initial_data(data)
		ui.open()
/obj/machinery/auger/process()
	if(!active)
		return
	progress++
	if(progress >= mining_speed)
		if(do_mine())
			var/turf/simulated/floor/plating/airless/asteroid/ore/ore_turf = loc
			if(mineController)
				switch(ore_turf.oretype)
					if("conglo")
						mineController.mine_conglo(loc)
					if("tantiline")
						mineController.mine_tantiline(loc)
					if("plasma")
						mineController.mine_plasma(loc)
					if("orichilum")
						mineController.mine_orichilum(loc)
			playsound(src.loc, 'sound/machines/synth_yes.ogg', 75, 1)
			
			ore_turf.resource_remaining--
			if(!ore_turf.resource_remaining)
				src.visible_message("[src] slowly begins to spin down to a complete stop.")
				playsound(src.loc, 'sound/effects/engine_stop.wav', 100, 0)
				active = 0
				progress = 0
				icon_state = "mining_drill"
				overlays = list()
				if(progbar)
					qdel(progbar)
			nanomanager.update_uis(src)
		else
			playsound(src.loc, 'sound/machines/synth_no.ogg', 75, 0)
		nanomanager.update_uis(src)
		if(progbar)
			progbar.update(progress)
		nanomanager.update_uis(src)
	else if(!(progress % 2))
		if(progbar)
			progbar.update(progress)
		spawn(10)
			playsound(src.loc, 'sound/effects/auger_bang.wav', 100, 0)
		flick("mining_drill_active2", src)
		nanomanager.update_uis(src)
/obj/machinery/auger/proc/do_mine()
	if(istype(loc, /turf/simulated/floor/plating/airless/asteroid/ore))
		var/turf/simulated/floor/plating/airless/asteroid/ore/ore_turf = loc
		if(!ore_turf.resource_remaining)
			progress = 0
			return 
		var/turf/dest = get_step(loc, output_dir)
		for(var/obj/machinery/resourceintake/intake in dest)
			if(intake.trunk)
				if(intake.trunk.contents.len)
					progress = 0
					return null
				else
					var/obj/structure/oregroup/ore = new(intake.trunk)
					ore.oretype = ore_turf.oretype
					progress = 0
					return 1
			else
				return spill(ore_turf.oretype)
		for(var/obj/structure/resourcepipe/trunk/P in dest)
			if(istype(P))
				if(P.contents.len)
					progress = 0
					return null
				else
					var/obj/structure/oregroup/ore = new(P)
					ore.oretype = ore_turf.oretype
					progress = 0
					return 1
		progress = 0
		var/turf/T = dest
		switch(ore_turf.oretype)
			if("conglo")
				for(var/obj/structure/ore_box/oreb in T.contents)
					if(oreb.add_ore(1,1))
						return 1
			if("plasma")
				for(var/obj/structure/plasma_canister/plasmac in T.contents)
					if(plasmac.add_ore())
						return 1
			if("tantiline")
				for(var/obj/structure/pressure_tank/tankt in T.contents)					
					if(tankt.add_ore())
						return 1
			if("orichilum")
				for(var/obj/structure/ore_box/oreb in T.contents)
					if(oreb.add_ore(2,1))
						return 1
		return spill(ore_turf.oretype)
	else
		progress = 0
		return 0
/obj/machinery/auger/proc/spill(var/oretype)
	var/turf/simulated/T = get_step(loc,output_dir)
	if(T.density)
		return
	switch(oretype)
		if("conglo")
			var/obj/structure/orepile/conglo/orepile = new(T)
		if("plasma")
			T.atmos_spawn_air(SPAWN_TOXINS, 50)
		if("tantiline")
			var/obj/structure/puddle/tantiline/puddle = new(T)
		if("orichilum")
			var/obj/structure/orepile/orichilum/orepile = new(T)

	return 1
	
/obj/machinery/auger/Topic(href, href_list)
	if(..())
		return 1
	switch(href_list["choice"])
		if("auger_off")
			if(broken) return 0
			src.visible_message("[src] slowly begins to spin down to a complete stop.")
			playsound(src.loc, 'sound/effects/engine_stop.wav', 100, 0)
			active = 0
			progress = 0
			icon_state = "mining_drill"
			overlays = list()
			if(progbar)
				qdel(progbar)
		if("auger_on")
			if(!active && !panel_open && anchored && istype(loc, /turf/simulated/floor/plating/airless/asteroid))
				if(broken)
					to_chat(usr, "[src] is not functional.")
					return 0
				active = 1
				icon_state = "mining_drill_active"
				if(!progbar)
					progbar = new(null, mining_speed, src)
				src.visible_message("[src] roars to life and begins boaring into the ground.")
				playsound(src.loc, 'sound/effects/engine_start.wav', 100, 0)
		if("anchor_on")
			anchored = 1
			playsound(src.loc, 'sound/effects/stolen/silo-clamps-on.ogg', 100, 1)
			
		if("anchor_off")
			if(!active)
				anchored = 0
				playsound(src.loc, 'sound/effects/stolen/silo-clamps-off.ogg', 100, 1)
		if("direction")
			var/c_dir = text2num(href_list["dir"])
			output_dir = c_dir
		if("close")
			nanomanager.close_uis(src)
	//nanomanager.update_uis(src)
	return 1
/obj/machinery/auger/attack_hand(mob/user as mob)
	ui_interact(user)
/obj/machinery/auger/attackby(obj/item/O, mob/user, params)
	if(stat)
		return 1
	if(active)
		to_chat(user, "<span class=\"alert\">The auger must be inactive before you can perform maintenance.</span>")
		return 1

	if(!active && default_deconstruction_screwdriver(user, "mining_drill_m", "mining_drill", O))
		active = 0
		updateUsrDialog()
		return
	else if(active && istype(O, /obj/item/weapon/screwdriver))
		to_chat(user, "<span class=\"alert\">The auger must be inactive before you can perform maintenance.</span>")
		return 1
	if(istype(O, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/W = O
		if(W.welding)
			if(!panel_open)
				to_chat(user, "<span class=\"alert\">The maintenance panel must be open before repairing [src].</span>")
				return 1
			if(health >= maxhealth)
				to_chat(user, "<span class=\"alert\">The chassis does not need any repairs.</span>")
				return 1
			var/points_to_repair
			if(user.get_stat(3) >= 5)
				points_to_repair = pick(2,3)
			else
				points_to_repair = pick(1,2)
			if(points_to_repair+health > maxhealth)
				points_to_repair -= ((points_to_repair+health)-maxhealth)
			switch(do_after_stat(user, delay = 50, needhand = 1, target = src, progress = 1, action_name = "repair the damages on [src]", 
				auto_emote = 1, stat_used = 3, minimum = 2, maximum = 8, maxed_delay = 20, progressive_failure = 1, minimum_probability = 70, help_able = 0, 
				help_ratio = 1, stamina_use = 2, stamina_used = 2, progressive_stamina = 1, attempt_cost = 5, stamina_use_fail = 1, sound_file = 'sound/items/Welder2.ogg'))
				if(1)
					to_chat(user, "You fix [points_to_repair] points of damage on [src].")
					health += points_to_repair
					check_health()
				if(2)
					to_chat(user, "You don't manage to fix any of the damages, just waste welder fuel.")
		nanomanager.update_uis(src)			
		return 0
	if(exchange_parts(user, O))
		return

	if(panel_open)
		if(istype(O, /obj/item/weapon/crowbar))
			return 1// INSERT COMPONENT REMOVAL HERE...
	
	..()
/obj/machinery/auger/attack_animal(var/mob/living/simple_animal/M)//No more buckling hostile mobs to chairs to render them immobile forever
	if(M.environment_smash)
		new /obj/item/stack/sheet/metal(src.loc)	// full auger components coming out here?
		qdel(src)
	else
		if(health)
			health--
			check_health()
/obj/machinery/auger/proc/check_health()
	if(health < 1 && !broken)
		broken = 1
		src.visible_message("[src] suddenly makes a loud crunching noise, it has been critically damaged.")
		active = 0
		progress = 0
		icon_state = "mining_drill"
		if(progbar)
			qdel(progbar)
		overlays = list()
		var/image/I = image(icon = 'icons/effects/effects.dmi', icon_state = "smoke_plume")
		overlays += I
	if(health > 3 && broken)
		src.visible_message("[src] seems like it's been made operable again.")
		broken = 0
		overlays = list()
	if(health < 0)
		health = 0
	nanomanager.update_uis(src)