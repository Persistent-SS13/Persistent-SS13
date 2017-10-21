// Disposal bin
// Holds items for disposal into pipe system
// Draws air from turf, gradually charges internal reservoir
// Once full (~1 atm), uses air resv to flush items into the pipes
// Automatically recharges air (unless off), will flush when ready if pre-set
// Can hold items and human size things, no other draggables
// Toilets are a type of disposal bin for small objects only and work on magic. By magic, I mean torque rotation
#define SEND_PRESSURE 0.05*ONE_ATMOSPHERE

/obj/machinery/resourceintake
	name = "Multi-resource intake"
	desc = "An intake capable of recieving raw solids, liquids or gasses."
	icon = 'icons/obj/pipes/disposal.dmi'
	icon_state = "intake-re"
	anchored = 1
	density = 1
	on_blueprints = FALSE
	var/obj/structure/resourcepipe/trunk/trunk = null // the attached pipe trunk
	active_power_usage = 600
	idle_power_usage = 100

/obj/machinery/resourceintake/New()
	..()
	trunk_check()

/obj/machinery/resourceintake/proc/trunk_check()
	trunk = locate() in src.loc
	if(!trunk)
	else
/obj/machinery/resourceintake/Destroy()
	if(trunk)
		trunk.linked = null
	return ..()

/obj/machinery/resourceintake/initialize()
	..()
	trunk_check()

/obj/machinery/resourceintake/attackby(var/obj/item/I, var/mob/user, params)
	if(stat & BROKEN || !I || !user)
		return

	src.add_fingerprint(user)
	if(istype(I,/obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/W = I
		if(W.remove_fuel(0,user))
			// check if anything changed over 2 seconds
			to_chat(user, "You begin slicing [src]..")
			switch(do_after_stat(user, delay = 50, needhand = 1, target = src, progress = 1, action_name = "slice the resource intake out of position", auto_emote = 1, stat_used = 3, minimum = 2, maximum = 8, maxed_delay = 20, progressive_failure = 1, minimum_probability = 70, help_able = 0, help_ratio = 1, stamina_use = 2, stamina_used = 5, progressive_stamina = 1, attempt_cost = 5, stamina_use_fail = 1, sound_file = 'sound/items/Welder2.ogg'))
				if(2)
					to_chat("You couldn't quite get [src] sliced out.")
				if(1)
					to_chat("You finish taking [src] out of position.")
					var/obj/structure/resourceconstruct/C = new (src.loc)
					C.ptype = 4
					src.transfer_fingerprints_to(C)
					C.dir = dir
					C.density = 0
					C.anchored = 1
					C.update()
					qdel(src)
				if(0)
					to_chat(user, "You must stay still while welding the pipe.")
		else
			to_chat(user, "You need more welding fuel to complete this task.")
			return
	if(!I)	return

	return


/obj/machinery/resourceintake/singularity_pull(S, current_size)
	if(current_size >= STAGE_FIVE)
		qdel(src)

		
/obj/machinery/resourceoutput
	name = "Multi-resource output"
	desc = "An output capable of filling adjacent resource containers in all four directions."
	icon = 'icons/obj/pipes/disposal.dmi'
	icon_state = "outlet-re"
	anchored = 1
	density = 1
	on_blueprints = FALSE
	var/obj/structure/resourcepipe/trunk/trunk = null // the attached pipe trunk
	active_power_usage = 600
	idle_power_usage = 100
/obj/machinery/resourceoutput/process()
	if(trunk && trunk.contents.len)
		var/obj/structure/oregroup/H = trunk.contents[1]
		ore_call(H)

/obj/machinery/resourceoutput/New()
	..()
	trunk_check()

/obj/machinery/resourceoutput/proc/ore_call(var/obj/structure/oregroup/target)
	if(!target)
		return
	switch(target.oretype)
		if("conglo")
			for(var/obj/structure/ore_box/borebox in range(1,loc))
				if(borebox.add_ore())
					qdel(target)
					return
		if("plasma")
			for(var/obj/structure/plasma_canister/bcan in range(1,loc))
				if(bcan.add_ore())
					qdel(target)
					return
		if("tantiline")
			for(var/obj/structure/pressure_tank/btank in range(1,loc))
				if(btank.add_ore())
					qdel(target)
					return
		if("orichilum")
			for(var/obj/structure/ore_box/borebox in range(1,loc))
				if(borebox.add_ore(2,1))
					qdel(target)
					return
/obj/machinery/resourceoutput/proc/trunk_check()
	trunk = locate() in src.loc
	if(!trunk)
	else
		trunk.linked = src	// link the pipe trunk to self

/obj/machinery/resourceoutput/Destroy()
	if(trunk)
		trunk.linked = null
	return ..()

/obj/machinery/resourceoutput/initialize()
	..()
	trunk_check()

/obj/machinery/resourceoutput/attackby(var/obj/item/I, var/mob/user, params)
	if(stat & BROKEN || !I || !user)
		return
	src.add_fingerprint(user)
	if(istype(I,/obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/W = I
		if(W.remove_fuel(0,user))
			// check if anything changed over 2 seconds
			var/turf/uloc = user.loc
			var/atom/wloc = W.loc
			to_chat(user, "You begin slicing [src]..")
			switch(do_after_stat(user, delay = 50, needhand = 1, target = src, progress = 1, action_name = "slice [src] out of position", auto_emote = 1, stat_used = 3, minimum = 2, maximum = 8, maxed_delay = 20, progressive_failure = 1, minimum_probability = 70, help_able = 0, help_ratio = 1, stamina_use = 2, stamina_used = 5, progressive_stamina = 1, attempt_cost = 5, stamina_use_fail = 1, sound_file = 'sound/items/Welder2.ogg'))
				if(2)
					to_chat("You couldn't quite get [src] sliced out.")
				if(1)
					to_chat("You finish taking [src] out of position.")
					var/obj/structure/resourceconstruct/C = new (src.loc)
					C.ptype = 3
					src.transfer_fingerprints_to(C)
					C.dir = dir
					C.density = 0
					C.anchored = 1
					C.update()
					qdel(src)
				if(0)
					to_chat(user, "You must stay still while welding the pipe.")
		else
			to_chat(user, "You need more welding fuel to complete this task.")
			return
	if(!I)	return
	..()


/obj/machinery/resourceoutput/singularity_pull(S, current_size)
	if(current_size >= STAGE_FIVE)
		qdel(src)

		
// virtual ore object
// travels through pipes in lieu of actual ore/liquid/gas
// contents will be the 

/obj/structure/oregroup
	invisibility = 101
	var/oretype = "" // plasma conglo tantiline orichilum
	var/obj/structure/resourcepipe/holder
	var/count = 1 // when this counts down to zero, the ore will attempt to move down the pipeline
	// find the turf which should contain the next pipe
/obj/structure/oregroup/New(var/obj/structure/resourcepipe/start)
	if(!start)
		qdel(src)
		return
	loc = start
	holder = start
	dir=holder.dir
	processing_objects += src
	
/obj/structure/oregroup/process()
	if(count < 0)
		count--
	else
		count = initial(count)
		if(istype(holder, /obj/structure/resourcepipe/trunk/))
			var/obj/structure/resourcepipe/trunk/trunk = holder
			if(trunk.linked)
				if(istype(trunk.linked, /obj/machinery/resourceoutput))
					var/obj/machinery/resourceoutput/output = trunk.linked
					return
				else
					var/findir = holder.nextdir(dir)
					dir=findir
					var/turf/T = get_step(loc,findir)
					if(!findpipe(T))
						spill()
					return
			else
				spill()
			return
		if(istype(holder, /obj/structure/resourcepipe/))
			var/findir = holder.nextdir(dir)
			var/turf/T = get_step(loc,findir)
			var/oldir = dir
			dir = findir
			switch(findpipe(T))
				if(0)
					spill()
				if(2)
					dir=oldir
		else
			spill()
		return
/obj/structure/oregroup/proc/spill(var/destroy = 0)
	var/turf/simulated/T = get_step(loc,dir)
	if(destroy)
		T = loc.loc
	switch(oretype)
		if("conglo")
			var/obj/structure/orepile/conglo/orepile = new(T)
		if("plasma")
			T.atmos_spawn_air(SPAWN_TOXINS, 50)
		if("tantiline")
			var/obj/structure/puddle/tantiline/puddle = new(T)
		if("orichilum")
			var/obj/structure/orepile/orichilum/orepile = new(T)
	holder.icon_state = holder.icon_initial
	qdel(src)
	return
/obj/structure/oregroup/proc/findpipe(var/turf/T)
	if(!T)
		return 0

	var/fdir = turn(dir, 180)	// flip the movement direction
	for(var/obj/structure/resourcepipe/P in T)
		if(fdir & P.dpdir)		// find pipe direction mask that matches flipped dir
			if(P.contents.len) // occupied pipe, skip movement
				message_admins("occupied pipe found!")
				return 2
			holder.icon_state = holder.icon_initial
			holder = P
			loc = P
			if(!istype(holder, /obj/structure/resourcepipe/trunk))
				holder.icon_state = "[holder.icon_initial][oretype]"
			return 1
	// if no matching pipe, return null
	return 0
	
// Resource Pipes

/obj/structure/resourcepipe
	icon = 'icons/obj/pipes/disposal.dmi'
	name = "resource pipe"
	desc = "A multi-resource pipe."
	anchored = 1
	density = 0
	var/dpdir = 0
	dir = 0				// dir will contain dominant direction for junction pipes
	var/health = 10 	// health points 0-10
	layer = 3			// slightly lower than wires and other pipes
	var/icon_initial	// initial icon state on map

	// new pipe, set the icon_state as on map
/obj/structure/resourcepipe/New()
	..()
	icon_initial = icon_state


// pipe is deleted
// ensure if holder is present, it is expelled
/obj/structure/resourcepipe/Destroy()
	var/obj/structure/oregroup/H = locate() in src
	if(H)
		// holder was present
		H.spill(1)
	return ..()

/obj/structure/resourcepipe/singularity_pull(S, current_size)
	if(current_size >= STAGE_FIVE)
		qdel(src)

// returns the direction of the next pipe object, given the entrance dir
// by default, returns the bitmask of remaining directions
/obj/structure/resourcepipe/proc/nextdir(var/fromdir)
	return dpdir & (~turn(fromdir, 180))


// pipe affected by explosion
/obj/structure/resourcepipe/ex_act(severity)

	switch(severity)
		if(1.0)
			return
		if(2.0)
			health -= rand(5,15)
			healthcheck()
			return
		if(3.0)
			health -= rand(0,15)
			healthcheck()
			return

/obj/structure/resourcepipe/attack_animal(var/mob/living/simple_animal/M)//No more buckling hostile mobs to chairs to render them immobile forever
	if(M.environment_smash)
		new /obj/item/stack/sheet/metal(src.loc)
		qdel(src)
	else
		health--
		healthcheck()
		return

// test health for brokenness
/obj/structure/resourcepipe/proc/healthcheck()
	if(health <= 0)
		var/obj/structure/resourcepipe/broken/broke = new(loc)
		broke.icon_state = "[icon_state]broke"
		broke.dir = dir
		for(var/obj/structure/oregroup/ore in contents)
			ore.spill(1)
		qdel(src)
	return
	
/obj/structure

//attack by item
//weldingtool: unfasten and convert to obj/disposalconstruct

/obj/structure/resourcepipe/attackby(var/obj/item/I, var/mob/user, params)

	var/turf/T = src.loc
	src.add_fingerprint(user)
	if(istype(I, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/W = I

		if(W.remove_fuel(0,user))
			// check if anything changed over 2 seconds
			to_chat(user, "Slicing the resource pipe.")
			switch(do_after_stat(user, delay = 50, needhand = 1, target = src, progress = 1, action_name = "slice [src] out of position", auto_emote = 1, stat_used = 3, minimum = 2, maximum = 8, maxed_delay = 20, progressive_failure = 1, minimum_probability = 70, help_able = 0, help_ratio = 1, stamina_use = 2, stamina_used = 2, progressive_stamina = 1, attempt_cost = 5, stamina_use_fail = 1, sound_file = 'sound/items/Welder2.ogg'))
				if(1)
					welded()
				if(0)
					to_chat(user, "You must stay still while welding the pipe.")
				if(2)
					to_chat(user, "You couldn't quite manage to remove [src].")
		else
			to_chat(user, "You need more welding fuel to cut the pipe.")
			return
	..()
// called when pipe is cut with welder
/obj/structure/resourcepipe/proc/welded()

	var/obj/structure/resourceconstruct/C = new (src.loc)
	switch(icon_initial)
		if("pipe-re")
			C.ptype = 0
		if("pipe-cre")
			C.ptype = 1
	src.transfer_fingerprints_to(C)
	C.dir = dir
	C.density = 0
	C.anchored = 1
	C.update()

	qdel(src)

/obj/structure/resourcepipe/segment/New()
	..()
	if(icon_state == "pipe-s")
		dpdir = dir | turn(dir, 180)
	else
		dpdir = dir | turn(dir, -90)




//a trunk joining to a disposal bin or outlet on the same turf
/obj/structure/resourcepipe/trunk
	icon_state = "pipe-t"
	var/obj/linked 	// the linked obj/machinery/disposal or obj/disposaloutlet

/obj/structure/resourcepipe/trunk/New()
	..()
	dpdir = dir
	spawn(1)
		getlinked()

	return
/obj/structure/resourcepipe/trunk/Destroy()
	if(linked)
		linked:trunk = null
	..()
/obj/structure/resourcepipe/trunk/proc/getlinked()
	linked = null
	var/obj/machinery/resourceintake/D = locate() in src.loc
	if(D)
		linked = D
		if(!D.trunk)
			D.trunk = src
	var/obj/machinery/resourceoutput/C = locate() in src.loc
	if(C)
		linked = C
		if(!C.trunk)
			C.trunk = src
	return

	// Override attackby so we disallow trunkremoval when somethings ontop
/obj/structure/resourcepipe/trunk/attackby(var/obj/item/I, var/mob/user, params)
	if(linked)
		return
	..()
/obj/structure/resourcepipe/trunk/nextdir(var/fromdir)
	return dir

/obj/structure/resourcepipe/trunk/healthcheck()
	if(health <= 0)
		if(linked)
			linked:trunk = null
	..()
// a broken pipe
/obj/structure/resourcepipe/broken
	icon_state = "pipe-rebroke"
	dpdir = 0		// broken pipes have dpdir=0 so they're not found as 'real' pipes
					// i.e. will be treated as an empty turf
	desc = "A broken piece of resource pipe."

	New()
		..()
		return

	// called when welded
	// for broken pipe, remove and turn into scrap

	welded()
//		var/obj/item/scrap/S = new(src.loc)
//		S.set_components(200,0,0)
		qdel(src)


// test health for brokenness
/obj/structure/resourcepipe/broken/healthcheck()
	return

/obj/structure/orepile
	icon = 'icons/obj/flora/rocks.dmi'
	name = "resource pipe"
	desc = "A pile of nondescript resource."
	anchored = 1
	density = 0
	var/amount = 1
	icon_state = "pile3"
	var/oretype = ""
	layer = 3.1
/obj/structure/orepile/New(loc)
	..()
	if(istype(loc, /turf))
		var/turf/T = loc
		for(var/obj/structure/orepile/orepile in T.contents)
			if(orepile == src) continue
			if(orepile.oretype == oretype)
				orepile.amount++
				orepile.update()
				qdel(src)
	
	
/obj/structure/orepile/attackby(var/obj/item/I, var/mob/user, params)
	src.add_fingerprint(user)
	if(istype(I, /obj/item/weapon/shovel))
		var/obj/structure/ore_box/orebox
		for(var/obj/structure/ore_box/oreb in range(1,user.loc))
			orebox = oreb
			break
		if(!orebox)
			to_chat(user, "You have to have an orebox adjacent to yourself to shovel this into.")
			return
		else
			user.visible_message("[user] begins shoveling the [oretype] into the box...")
			switch(do_after_stat(user, delay = 100, needhand = 1, target = src, progress = 1, action_name = "shovel the [oretype]", 
					auto_emote = 1, stat_used = 1, minimum = 0, maximum = 8, maxed_delay = 40, progressive_failure = 0, 
					minimum_probability = 70, help_able = 0, help_ratio = 1, stamina_use = 1, stamina_used = 15, 
					progressive_stamina = 1, attempt_cost = 5, stamina_use_fail = 0.5, sound_file = 'sound/effects/tong_pickup.ogg'))
				if(1)		
					switch(oretype)
						if("conglo")
							orebox.conglo_amount += 1
						if("orichilum")
							orebox.orichilum_amount += 1	
					to_chat(user, "You shovel the [oretype] into the box.")
					amount -= 1
					update()
		return
	else
		return
/obj/structure/orepile/proc/update()
	density = 0
	if(amount < 1)
		qdel(src)
	if(amount < 3)
		icon_state = "pile3"
	else if(amount < 5)
		icon_state = "pile2"
	else
		density = 1
		icon_state = "pile1"
	if(amount > 7)
		spread()
/obj/structure/orepile/proc/spread()
	amount--
	var/list/dirs = cardinal.Copy()
	var/pdir = pick_n_take(dirs)
	var/turf/T = get_step(loc, pdir)
	var/turfcheck = 0
	while((!turfcheck || T.density) && dirs.len)
		pdir = pick_n_take(dirs)
		T = get_step(loc, pdir)
		if(!T.density)
			turfcheck = 1
			for(var/obj/o in T.contents)
				if(o.type == type) continue
				if(o.density)
					turfcheck = 0
					break
	if(!T || T.density || !turfcheck)
		return
	var/obj/structure/orepile/target = new type(T)
	return
	
/obj/structure/orepile/conglo
	name = "conglo ore pile"
	desc = "A pile of conglo ore."
	oretype = "conglo"
/obj/structure/orepile/orichilum
	name = "orichilum ore pile"
	desc = "A pile of orichilum."
	icon_state = "rpile3"
	oretype = "orichilum"
/obj/structure/orepile/orichilum/update()
	if(amount < 1)
		qdel(src)
	if(amount < 3)
		icon_state = "rpile3"
	else if(amount < 5)
		icon_state = "rpile2"
	else
		icon_state = "rpile1"
	if(amount > 7)
		spread()	
	
/obj/structure/puddle
	icon = 'icons/obj/watercloset.dmi'
	name = "puddle"
	desc = "A puddle of nondescript substance."
	anchored = 1
	density = 0
	var/amount = 1
	icon_state = "puddle-alt"
	var/evap = 0 // when evap reaches 80 the amount goes down by 1 automatically.. to prevent too much water! the engine cant handle it!
	
/obj/structure/puddle/New(loc)
	..()
	processing_objects += src
	if(istype(loc, /turf))
		var/turf/T = loc
		for(var/obj/structure/puddle/puddle in T.contents)
			if(puddle == src) continue
			if(puddle.type == type)
				puddle.amount++
				puddle.update()
				qdel(src)

/obj/structure/puddle/process()
	evap++
	if(evap >= 80)
		amount--
		update()
		evap = 0

/obj/structure/puddle/proc/update()
	overlays = list()
	if(amount < 1)
		qdel(src)
	if(amount > 1)
		overlays += image(icon, src, icon_state)
	if(amount > 2)
		overlays += image(icon, src, icon_state)
	if(amount > 3)
		spread()

/obj/structure/puddle/proc/spread()
	amount--
	var/list/dirs = cardinal.Copy()
	var/pdir = pick_n_take(dirs)
	var/turf/T = get_step(loc, pdir)
	var/turfcheck = 0
	while((T.density || !turfcheck) && dirs.len)
		pdir = pick_n_take(dirs)
		T = get_step(loc, pdir)
		if(!T.density)
			turfcheck = 1
			for(var/obj/o in T.contents)
				if(o.density)
					turfcheck = 0
					break
	if(!T || T.density || !turfcheck)
		return
	var/obj/structure/puddle/target = new type(T)
	return

/obj/structure/puddle/tantiline
	name = "tantiline puddle"
	desc = "A puddle of dangerous tantiline."
	anchored = 1
	density = 0
	amount = 1
	icon_state = "tantiline-puddle"
	var/react_evap = 0 // when react_evap reaches 5 the amount goes down by one... the tantiline is boiling away