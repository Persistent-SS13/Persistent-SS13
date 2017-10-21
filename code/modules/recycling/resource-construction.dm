// Disposal pipe construction
// This is the pipe that you drag around, not the attached ones.

/obj/structure/resourceconstruct

	name = "resource pipe segment"
	desc = "A huge pipe segment used for constructing mining systems."
	icon = 'icons/obj/pipes/disposal.dmi'
	icon_state = "conpipe-re"
	anchored = 0
	density = 0
	pressure_resistance = 5*ONE_ATMOSPHERE
	level = 2
	var/ptype = 0
	var/health = 3
	// 0=straight, 1=bent, 2=trunk, 3=intake, 4=output

	var/dpdir = 0	// directions as disposalpipe
	var/base_state = "pipe-re"

	// update iconstate and dpdir due to dir and type
/obj/structure/resourceconstruct/proc/update()
	var/flip = turn(dir, 180)
	var/right = turn(dir, -90)

	switch(ptype)
		if(0)
			base_state = "pipe-re"
			dpdir = dir | flip
		if(1)
			base_state = "pipe-cre"
			dpdir = dir | right
		if(2)
			base_state = "pipe-t"
			dpdir = dir
		if(3)
			base_state = "intake-re"
		if(4)
			base_state = "outlet-re"
	icon_state = "con[base_state]"


// flip and rotate verbs
/obj/structure/resourceconstruct/verb/rotate()
	set name = "Rotate Pipe"
	set src in view(1)

	if(usr.stat)
		return

	if(anchored)
		to_chat(usr, "You must unfasten the pipe before rotating it.")
		return

	dir = turn(dir, -90)

/obj/structure/resourceconstruct/verb/flip()
	set name = "Flip Pipe"
	set src in view(1)
	if(usr.stat)
		return
	if(anchored)
		to_chat(usr, "You must unfasten the pipe before flipping it.")
		return

	dir = turn(dir, 180)

// returns the type path of disposalpipe corresponding to this item dtype
/obj/structure/resourceconstruct/proc/dpipetype()
	switch(ptype)
		if(0,1)
			return /obj/structure/resourcepipe/segment
		if(2)
			return /obj/structure/resourcepipe/trunk
		if(3)
			return /obj/machinery/resourceintake
		if(4)
			return /obj/machinery/resourceoutput
	return


/obj/structure/resourceconstruct/attack_animal(var/mob/living/simple_animal/M)
	if(M.environment_smash)
		new /obj/item/stack/sheet/metal(src.loc)
		qdel(src)
	else
		health--
		healthcheck()
		return

// test health for brokenness
/obj/structure/resourceconstruct/proc/healthcheck()
	if(health <= 0)
		new /obj/item/stack/sheet/metal(src.loc)
		qdel(src)
	return
	

// attackby item
// wrench: (un)anchor
// weldingtool: convert to real pipe

/obj/structure/resourceconstruct/attackby(var/obj/item/I, var/mob/user, params)
	var/nicetype = "pipe"
	var/ispipe = 0 // Indicates if we should change the level of this pipe
	src.add_fingerprint(user)
	switch(ptype)
		if(2)
			nicetype = "resource trunk"
			ispipe = 1
		if(3)
			nicetype = "resource input"
		if(4)
			nicetype = "resource output"
		else
			nicetype = "pipe"
			ispipe = 1

	var/turf/T = src.loc
	var/obj/structure/resourcepipe/CP = locate() in T
	if(ptype==3 || ptype == 4) // Disposal or outlet
		if(CP) // There's something there
			if(!istype(CP,/obj/structure/resourcepipe/trunk))
				to_chat(user, "The [nicetype] requires a trunk underneath it in order to work.")
				return
		else // Nothing under, fuck.
			to_chat(user, "The [nicetype] requires a trunk underneath it in order to work.")
			return
	else
		if(CP)
			update()
			var/pdir = CP.dpdir
			if(istype(CP, /obj/structure/resourcepipe/broken))
				pdir = CP.dir
			if(pdir & dpdir)
				to_chat(user, "There is already a [nicetype] at that location.")
				return


	if(istype(I, /obj/item/weapon/wrench))
		switch(do_after_stat(user, 50, needhand = 1, target = src, progress = 1, action_name = "[anchored ? "un" : ""]wrench [src] to the floor", auto_emote = 1, stat_used = 3, minimum = 2, maximum = 8, maxed_delay = 20, progressive_failure = 0, minimum_probability = 70, help_able = 0, help_ratio = 1, stamina_use = 2, stamina_used = 5, progressive_stamina = 1, attempt_cost = 5, stamina_use_fail = 1.5, sound_file = 'sound/items/Ratchet.ogg'))
			if(1)
				to_chat(user, "<span class='notice'>You've [anchored ? "un" : ""]anchored [name].</span>")
				anchored = !anchored
				playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
				return 1
			if(2)
				to_chat(user, "<span class='notice'>You dont have good enough reflexes to anchor this.</span>")
		update()

	else if(istype(I, /obj/item/weapon/weldingtool))
		if(anchored)
			var/obj/item/weapon/weldingtool/W = I
			if(W.remove_fuel(0,user))
				to_chat(user, "Welding the [nicetype] in place.")
				switch(do_after_stat(user, delay = 50, needhand = 1, target = src, progress = 1, action_name = "slice the [nicetype] out of position", auto_emote = 1, stat_used = 3, minimum = 2, maximum = 8, maxed_delay = 20, progressive_failure = 1, minimum_probability = 70, help_able = 0, help_ratio = 1, stamina_use = 2, stamina_used = 5, progressive_stamina = 1, attempt_cost = 5, stamina_use_fail = 1, sound_file = 'sound/items/Welder2.ogg'))
					if(2)
						to_chat(user, "You couldn't quite get [src] welded into place.")
					if(1)
						if(!src || !W.isOn()) return
						to_chat(user, "The [nicetype] has been welded in place!")
						update() // TODO: Make this neat
						if(ispipe) // Pipe
							var/pipetype = dpipetype()
							var/obj/structure/resourcepipe/P = new pipetype(src.loc)
							src.transfer_fingerprints_to(P)
							P.icon_initial = base_state
							P.icon_state = base_state
							P.dir = dir
							P.dpdir = dpdir
							P.update_icon()
						else if(ptype==3) // resource intake
							var/obj/machinery/resourceintake/P = new /obj/machinery/resourceintake(src.loc)
							src.transfer_fingerprints_to(P)
							var/obj/structure/resourcepipe/trunk/Trunk = CP
							Trunk.linked = P
							P.trunk = Trunk
						else if(ptype==4) // resource output
							var/obj/machinery/resourceoutput/P = new /obj/machinery/resourceoutput(src.loc)
							src.transfer_fingerprints_to(P)
							var/obj/structure/resourcepipe/trunk/Trunk = CP
							Trunk.linked = P
							P.trunk = Trunk
						qdel(src)
						return
					if(0)
						to_chat(user, "You must remain still when welding.")
			else
				to_chat(user, "You need more welding fuel to complete this task.")
				return
		else
			to_chat(user, "You need to attach it to the ground first!")
			return
