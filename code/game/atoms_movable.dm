/atom/movable
	layer = 3
	appearance_flags = TILE_BOUND
	var/tmp/last_move = null
	var/tmp/anchored = 0
	// var/elevation = 2    - not used anywhere
	var/tmp/move_speed = 10
	var/tmp/l_move_time = 1
	var/tmp/throwing = 0
	var/tmp/thrower
	var/tmp/turf/throw_source = null
	var/tmp/throw_speed = 2
	var/tmp/throw_range = 7
	var/tmp/no_spin_thrown = 0 //set this to 1 if you don't want an item that you throw to spin, no matter what. -Fox
	var/tmp/moved_recently = 0
	var/tmp/mob/pulledby = null
	var/tmp/mob/pulledby_helper = null
	var/tmp/inertia_dir = 0
	var/tmp/being_used = 0 // Used for stat_actions, most things should only be able to be used once
	var/tmp/w_class = 1
	var/tmp/area/areaMaster
	var/tmp/alt_w_class = 0
	
	var/tmp/relative_grit = 0
	var/tmp/recalc_relative = 1
	var/tmp/last_weight = 0
	
	var/tmp/auto_init = 1
	var/load_datums = 1
/atom/movable/New()
	. = ..()
	areaMaster = get_area_master(src)

	// If you're wondering what goofery this is, this is for things that need the environment
	// around them set up - like `air_update_turf` and the like
	if((ticker && ticker.current_state == GAME_STATE_PLAYING))
		attempt_init()

/atom/movable/Destroy()
	for(var/atom/movable/AM in contents)
		qdel(AM)
	loc = null
	if(pulledby)
		if(pulledby.pulling == src)
			pulledby.pulling = null
		pulledby = null
	if(pulledby_helper)
		if(pulledby_helper.pulling_helper == src)
			pulledby_helper.pulling_helper = null
		pulledby_helper = null
	return ..()

// used to provide a good interface for the init delay system to step in
// and we don't need to call `get_turf` until the game's started
// at which point object creations are a fair toss more seldom
/atom/movable/proc/attempt_init()
	var/turf/T = get_turf(src)
	if(T && space_manager.is_zlevel_dirty(T.z))
		space_manager.postpone_init(T.z, src)
	else if(auto_init)
		initialize()


/atom/movable/proc/initialize()
	return

// Used in shuttle movement and AI eye stuff.
// Primarily used to notify objects being moved by a shuttle/bluespace fuckup.
/atom/movable/proc/setLoc(var/T, var/teleported=0)
	loc = T

/atom/movable/Move(atom/newloc, direct = 0)
	if(!loc || !newloc) return 0
	var/atom/oldloc = loc

	if(pulledby_helper && get_dist(src, pulledby_helper) > 1)
		pulledby_helper.stop_pulling()
	if(loc != newloc)
		if(!(direct & (direct - 1))) //Cardinal move
			. = ..()
		else //Diagonal move, split it into cardinal moves
			if(direct & 1)
				if(direct & 4)
					if(step(src, NORTH))
						. = step(src, EAST)
					else if(step(src, EAST))
						. = step(src, NORTH)
				else if(direct & 8)
					if(step(src, NORTH))
						. = step(src, WEST)
					else if(step(src, WEST))
						. = step(src, NORTH)
			else if(direct & 2)
				if(direct & 4)
					if(step(src, SOUTH))
						. = step(src, EAST)
					else if(step(src, EAST))
						. = step(src, SOUTH)
				else if(direct & 8)
					if(step(src, SOUTH))
						. = step(src, WEST)
					else if(step(src, WEST))
						. = step(src, SOUTH)

	if(!loc || (loc == oldloc && oldloc != newloc))
		last_move = 0
		return

	if(pulledby_helper)
		pulledby_helper.Move(oldloc, get_dir(pulledby_helper, oldloc))
		
	last_move = direct
	src.move_speed = world.time - src.l_move_time
	src.l_move_time = world.time

	
	
	spawn(5)	// Causes space drifting. /tg/station has no concept of speed, we just use 5
		if(loc && direct && last_move == direct)
			if(loc == newloc) //Remove this check and people can accelerate. Not opening that can of worms just yet.
				newtonian_move(last_move)

	if(. && buckled_mob && !handle_buckled_mob_movement(loc, direct)) //movement failed due to buckled mob
		. = 0

/atom/movable/proc/calculate_movedelay()
	if(!pulledby) return 0
	var/relative = get_relative_grit()
	if(relative > 10 || relative < 0)
		return 0
	var/minus = relative*0.5
	return max(6 - minus, 0)
/atom/movable/proc/get_relative_grit()
	if(!recalc_relative && (get_weight() == last_weight))
		return relative_grit
	if(pulledby)
		last_weight = get_weight()
		if(last_weight < 4)
			relative_grit = 11
			recalc_relative = 0
			return 11
		var/tally = 5 // all creatures get a base 5 to pull
		tally += pulledby.get_stat(1)
		if(pulledby_helper)
			tally += 3
			tally += pulledby_helper.get_stat(1)
		message_admins("GET_RELATIVE_GRIT! [tally - last_weight]")
		relative_grit = tally-last_weight
		recalc_relative = 0
		return relative_grit
	else
		return -10
	
/atom/movable/proc/calculate_pushmovedelay(var/mob/puller)
	var/relative = get_relative_pushgrit(puller)
	if(relative > 10 || relative < 0)
		return 0
	var/minus = relative*0.5
	return max(6 - minus, 0)
	
	
/atom/movable/proc/get_relative_pushgrit(var/mob/puller)
	if(puller)
		last_weight = get_weight()
		if(last_weight < 4)
			relative_grit = 11
			return 11
		var/tally = 5 // all creatures get a base 5 to pull
		tally += puller.get_stat(1)
		relative_grit = tally-last_weight
		return relative_grit
	else
		return -10

/atom/movable/proc/get_move_able()
	var/relative = get_relative_grit()
	if(relative<0)
		return 0
	else
		return 1
		
/atom/movable/proc/get_push_able(var/mob/puller)
	var/relative = get_relative_pushgrit(puller)
	if(relative<0)
		return 0
	else
		return 1
/atom/movable/proc/affect_pushstamina(var/mob/puller)
	if(!puller) return
	var/relative = get_relative_pushgrit(puller)
	
	if(relative>10)
		return 0
	else
		var/fort = puller.get_stat(2)
		if(istype(puller, /mob/living/carbon))
			if(istype(puller.loc, /obj/mecha))
				var/obj/mecha/M = puller.loc
				M.cell.charge -= ((max(((10-relative)*8)-fort*32, 0)))
				if(puller.last_autoemote < world.time && relative < 2)
					if(prob(5))
						puller.visible_message("The [M] has its hydraulic systems grind and strain as it struggles to push [src].")
						puller.last_autoemote = world.time + 300
				else if(puller.last_autoemote < world.time && relative < 5)
					if(prob(5))
						puller.visible_message("The [M] makes a few odd clacking sounds as its systems reconfigure to push [src].")
						puller.last_autoemote = world.time + 300
				else if(puller.last_autoemote < world.time)
					if(prob(5))
						puller.visible_message("The [M] seems only slightly affected by pushing [src].")
						puller.last_autoemote = world.time + 300
			else
				var/mob/living/carbon/M = puller
				M.adjustStaminaLoss(max(((10-relative)/4)-fort*0.10, 0))
				if(puller.last_autoemote < world.time && relative < 2)
					if(prob(5))
						
						switch(pick(1,2,3))
							if(1)
								puller.visible_message("[M] makes a long groaning noise as they struggle to move [src].")
							if(2)
								puller.visible_message("[M] takes a deep breath before struggling to push [src] along.")
							if(3)
								puller.visible_message("[M] seems like they can barely move [src].")
						puller.last_autoemote = world.time + 300
						
				else if(puller.last_autoemote < world.time && relative < 5)
					if(prob(5))
						
						switch(pick(1,2,3))
							if(1)
								puller.visible_message("[M]'s breath becomes shorter as they move [src].")
							if(2)
								puller.visible_message("[M] grunts as they push [src] along.")
							if(3)
								puller.visible_message("[M] seems like they are mildly strained moving [src].")
						puller.last_autoemote = world.time + 300
				else if(puller.last_autoemote < world.time)
					if(prob(5))
						
						puller.visible_message("[M] only lets pushing [src] slow them down slightly.")
						puller.last_autoemote = world.time + 300
		else if(istype(puller, /mob/living/silicon/robot))
			var/mob/living/silicon/robot/M = puller
			M.cell.charge -= ((max(((10-relative)*8)-fort*32, 0)))
			if(puller.last_autoemote < world.time && relative < 2)
				if(prob(5))
					var/the = ""
					if(!ismob(src))
						the = "the "
					puller.visible_message("[M] has its hydraulic systems grind and strain as it struggles to push [src].")
					puller.last_autoemote = world.time + 300
					
			else if(puller.last_autoemote < world.time && relative < 5)
				if(prob(5))
					var/the = ""
					if(!ismob(src))
						the = "the "
					puller.visible_message("[M] makes a few odd clacking sounds as its systems reconfigure to push [src].")
					puller.last_autoemote = world.time + 300
			else if(puller.last_autoemote < world.time)
				if(prob(5))
					var/the = ""
					if(!ismob(src))
						the = "the "
					puller.visible_message("[M] seems only slightly affected by pushing [src].")
					puller.last_autoemote = world.time + 300
		else
			return 0

/atom/movable/proc/affect_stamina()
	if(!pulledby) return
	var/relative = get_relative_grit()
	
	if(relative>10)
		return 0
	else
		var/helped = 0
		var/fort = pulledby.get_stat(2)
		var/fort_helper = 0
		if(pulledby_helper)
			helped = 1
			fort_helper = pulledby_helper.get_stat(2)
		if(!helped)
			if(istype(pulledby, /mob/living/carbon))
				if(istype(pulledby.loc, /obj/mecha))
					var/obj/mecha/M = pulledby.loc
					M.cell.charge -= ((max(((10-relative)*8)-fort*32, 0)))
					if(pulledby.last_autoemote < world.time && relative < 2)
						if(prob(5))
							pulledby.visible_message("The [M] has its hydraulic systems grind and strain as it struggles to pull [src].")
							pulledby.last_autoemote = world.time + 300
					else if(pulledby.last_autoemote < world.time && relative < 5)
						if(prob(5))
							pulledby.visible_message("The [M] makes a few odd clacking sounds as its systems reconfigure to pull [src].")
							pulledby.last_autoemote = world.time + 300
					else if(pulledby.last_autoemote < world.time)
						if(prob(5))
							pulledby.visible_message("The [M] seems only slightly affected by pulling [src].")
							pulledby.last_autoemote = world.time + 300
				else
					var/mob/living/carbon/M = pulledby
					M.adjustStaminaLoss(max(((10-relative)/4)-fort*0.20, 0))
					if(pulledby.last_autoemote < world.time && relative < 2)
						if(prob(5))
							
							switch(pick(1,2,3))
								if(1)
									pulledby.visible_message("[M] makes a long groaning noise as they struggle to move [src].")
								if(2)
									pulledby.visible_message("[M] takes a deep breath before struggling to yank [src] along.")
								if(3)
									pulledby.visible_message("[M] seems like they can barely move [src].")
							pulledby.last_autoemote = world.time + 300
							
					else if(pulledby.last_autoemote < world.time && relative < 5)
						if(prob(5))
							
							switch(pick(1,2,3))
								if(1)
									pulledby.visible_message("[M]'s breath becomes shorter as they move [src].")
								if(2)
									pulledby.visible_message("[M] grunts as they pull [src] along.")
								if(3)
									pulledby.visible_message("[M] seems like they are mildly strained moving [src].")
							pulledby.last_autoemote = world.time + 300
					else if(pulledby.last_autoemote < world.time)
						if(prob(5))
							
							pulledby.visible_message("[M] only lets pulling [src] slow them down slightly.")
							pulledby.last_autoemote = world.time + 300
			else if(istype(pulledby, /mob/living/silicon/robot))
				var/mob/living/silicon/robot/M = pulledby
				M.cell.charge -= ((max(((10-relative)*8)-fort*32, 0)))
				if(pulledby.last_autoemote < world.time && relative < 2)
					if(prob(5))
						var/the = ""
						if(!ismob(src))
							the = "the "
						pulledby.visible_message("[M] has its hydraulic systems grind and strain as it struggles to pull [src].")
						pulledby.last_autoemote = world.time + 300
						
				else if(pulledby.last_autoemote < world.time && relative < 5)
					if(prob(5))
						var/the = ""
						if(!ismob(src))
							the = "the "
						pulledby.visible_message("[M] makes a few odd clacking sounds as its systems reconfigure to pull [src].")
						pulledby.last_autoemote = world.time + 300
				else if(pulledby.last_autoemote < world.time)
					if(prob(5))
						var/the = ""
						if(!ismob(src))
							the = "the "
						pulledby.visible_message("[M] seems only slightly affected by pulling [src].")
						pulledby.last_autoemote = world.time + 300
			else
				return 0
		else
			if(istype(pulledby, /mob/living/carbon))
				if(istype(pulledby.loc, /obj/mecha))
					var/obj/mecha/M = pulledby.loc
					M.cell.charge -= ((max(((10-relative)*8)-fort*32, 0)))
					if(pulledby.last_autoemote < world.time && relative < 2)
						if(prob(5))
							pulledby.visible_message("Even with assistance the [M] has its hydraulic systems grind and strain as it struggles to pull [src].")
							pulledby.last_autoemote = world.time + 300
					else if(pulledby.last_autoemote < world.time && relative < 5)
						if(prob(5))
							pulledby.visible_message("With assistance the [M] still makes a few odd clacking sounds as its systems reconfigure to pull [src].")
							pulledby.last_autoemote = world.time + 300
					else if(pulledby.last_autoemote < world.time)
						if(prob(5))
							pulledby.visible_message("With assistance the [M] seems only slightly affected by pulling [src].")
							pulledby.last_autoemote = world.time + 300
				else
					var/mob/living/carbon/M = pulledby
					M.adjustStaminaLoss(max(((10-relative)/4)-fort*0.20, 0))
					if(pulledby.last_autoemote < world.time && relative < 2)
						if(prob(5))
							pulledby.visible_message("Even with assistance [M] seems like they can barely move [src].")
							pulledby.last_autoemote = world.time + 300
					else if(pulledby.last_autoemote < world.time && relative < 5)
						if(prob(5))
							pulledby.visible_message("[M] and their helper seem like they are mildly strained moving [src].")
							pulledby.last_autoemote = world.time + 300
					else if(pulledby.last_autoemote < world.time)
						if(prob(5))
							pulledby.visible_message("With assistance, [M] only lets pulling [src] slow them down slightly.")
							pulledby.last_autoemote = world.time + 300
			else if(istype(pulledby, /mob/living/silicon/robot))
				var/mob/living/silicon/robot/M = pulledby
				M.cell.charge -= ((max(((10-relative)*8)-fort*32, 0)))
				if(pulledby.last_autoemote < world.time && relative < 2)
					if(prob(5))
						pulledby.visible_message("Even with assistance, [M] has its hydraulic systems grind and strain as it struggles to pull [src].")
						pulledby.last_autoemote = world.time + 300
				else if(pulledby.last_autoemote < world.time && relative < 5)
					if(prob(5))
						pulledby.visible_message("With assistance, [M] still makes a few odd clacking sounds as its systems reconfigure to pull [src].")
						pulledby.last_autoemote = world.time + 300
				else if(pulledby.last_autoemote < world.time)
					if(prob(5))
						pulledby.visible_message("With assistance, [M] seems only slightly affected by pulling [src].")
						pulledby.last_autoemote = world.time + 300
			if(istype(pulledby_helper, /mob/living/carbon))
				if(istype(pulledby_helper.loc, /obj/mecha))
					var/obj/mecha/M = pulledby_helper.loc
					M.cell.charge -= ((max(((10-relative)*3)-fort_helper*2, 0)))
				else
					var/mob/living/carbon/M = pulledby_helper
					M.adjustStaminaLoss(max(((10-relative)/4)-fort_helper*0.20, 0))
				
			else if(istype(pulledby_helper, /mob/living/silicon/robot))
				var/mob/living/silicon/robot/M = pulledby_helper
				M.cell.charge -= ((max(((10-relative)*3)-fort_helper*2, 0)))
				
// Previously known as Crossed()
// This is automatically called when something enters your square
/atom/movable/Crossed(atom/movable/AM)
	return

/atom/movable/Bump(var/atom/A as mob|obj|turf|area, sendBump)
	if(src.throwing)
		src.throw_impact(A)

	if(A && sendBump)
		A.last_bumped = world.time
		A.Bumped(src)
	else
		..()

/atom/movable/proc/forceMove(atom/destination)
	var/turf/old_loc = loc
	loc = destination

	if(old_loc)
		old_loc.Exited(src, destination)
		for(var/atom/movable/AM in old_loc)
			AM.Uncrossed(src)

	if(destination)
		destination.Entered(src)
		for(var/atom/movable/AM in destination)
			AM.Crossed(src)

		if(isturf(destination) && opacity)
			var/turf/new_loc = destination
			new_loc.reconsider_lights()

	if(isturf(old_loc) && opacity)
		old_loc.reconsider_lights()

	for(var/datum/light_source/L in light_sources)
		L.source_atom.update_light()

	return 1

//called when src is thrown into hit_atom
/atom/movable/proc/throw_impact(atom/hit_atom, var/speed)
	if(istype(hit_atom,/mob/living))
		var/mob/living/M = hit_atom
		M.hitby(src,speed)

	else if(isobj(hit_atom))
		var/obj/O = hit_atom
		if(!O.anchored && O.w_class < 3)
			step(O, src.dir)
		O.hitby(src,speed)

	else if(isturf(hit_atom))
		src.throwing = 0
		var/turf/T = hit_atom
		if(T.density)
			spawn(2)
				step(src, turn(src.dir, 180))
			if(istype(src,/mob/living))
				var/mob/living/M = src
				M.turf_collision(T, speed)


//Called whenever an object moves and by mobs when they attempt to move themselves through space
//And when an object or action applies a force on src, see newtonian_move() below
//Return 0 to have src start/keep drifting in a no-grav area and 1 to stop/not start drifting
//Mobs should return 1 if they should be able to move of their own volition, see client/Move() in mob_movement.dm
//movement_dir == 0 when stopping or any dir when trying to move
/atom/movable/proc/Process_Spacemove(var/movement_dir = 0)
	if(has_gravity(src))
		return 1

	if(pulledby)
		return 1

	if(locate(/obj/structure/lattice) in range(1, get_turf(src))) //Not realistic but makes pushing things in space easier
		return 1

	return 0
	
/atom/movable/proc/get_weight()
	if(alt_w_class) return alt_w_class
	return w_class
	 
/atom/movable/proc/newtonian_move(direction) //Only moves the object if it's under no gravity

	if(!loc || Process_Spacemove(0))
		inertia_dir = 0
		return 0

	inertia_dir = direction
	if(!direction)
		return 1

	var/old_dir = dir
	. = step(src, direction)
	dir = old_dir

//decided whether a movable atom being thrown can pass through the turf it is in.
/atom/movable/proc/hit_check(var/speed)
	if(src.throwing)
		for(var/atom/A in get_turf(src))
			if(A == src) continue
			if(istype(A,/mob/living))
				if(A:lying) continue
				src.throw_impact(A,speed)
			if(isobj(A))
				if(A.density && !A.throwpass)	// **TODO: Better behaviour for windows which are dense, but shouldn't always stop movement
					src.throw_impact(A,speed)

/atom/movable/proc/throw_at(atom/target, range, speed, thrower, no_spin)
	if(!target || !src || (flags & NODROP))
		return 0
	//use a modified version of Bresenham's algorithm to get from the atom's current position to that of the target

	src.throwing = 1
	src.thrower = thrower
	src.throw_source = get_turf(src)	//store the origin turf
	if(target.allow_spin) // turns out 1000+ spinning objects being thrown at the singularity creates lag - Iamgoofball
		if(!no_spin_thrown && !no_spin)
			SpinAnimation(5, 1)
	var/dist_x = abs(target.x - src.x)
	var/dist_y = abs(target.y - src.y)

	var/dx
	if(target.x > src.x)
		dx = EAST
	else
		dx = WEST

	var/dy
	if(target.y > src.y)
		dy = NORTH
	else
		dy = SOUTH
	var/dist_travelled = 0
	var/dist_since_sleep = 0
	var/area/a = get_area(src.loc)
	if(dist_x > dist_y)
		var/error = dist_x/2 - dist_y
		while(src && target &&((((src.x < target.x && dx == EAST) || (src.x > target.x && dx == WEST)) && dist_travelled < range) || (a && a.has_gravity == 0)  || istype(src.loc, /turf/space)) && src.throwing && istype(src.loc, /turf))
			// only stop when we've gone the whole distance (or max throw range) and are on a non-space tile, or hit something, or hit the end of the map, or someone picks it up
			if(error < 0)
				var/atom/step = get_step(src, dy)
				if(!step) // going off the edge of the map makes get_step return null, don't let things go off the edge
					break
				src.Move(step, get_dir(loc, step))
				hit_check(speed)
				error += dist_x
				dist_travelled++
				dist_since_sleep++
				if(dist_since_sleep >= speed)
					dist_since_sleep = 0
					sleep(1)
			else
				var/atom/step = get_step(src, dx)
				if(!step) // going off the edge of the map makes get_step return null, don't let things go off the edge
					break
				src.Move(step)
				hit_check(speed)
				error -= dist_y
				dist_travelled++
				dist_since_sleep++
				if(dist_since_sleep >= speed)
					dist_since_sleep = 0
					sleep(1)
			a = get_area(src.loc)
	else
		var/error = dist_y/2 - dist_x
		while(src && target &&((((src.y < target.y && dy == NORTH) || (src.y > target.y && dy == SOUTH)) && dist_travelled < range) || (a && a.has_gravity == 0)  || istype(src.loc, /turf/space)) && src.throwing && istype(src.loc, /turf))
			// only stop when we've gone the whole distance (or max throw range) and are on a non-space tile, or hit something, or hit the end of the map, or someone picks it up
			if(error < 0)
				var/atom/step = get_step(src, dx)
				if(!step) // going off the edge of the map makes get_step return null, don't let things go off the edge
					break
				src.Move(step)
				hit_check(speed)
				error += dist_y
				dist_travelled++
				dist_since_sleep++
				if(dist_since_sleep >= speed)
					dist_since_sleep = 0
					sleep(1)
			else
				var/atom/step = get_step(src, dy)
				if(!step) // going off the edge of the map makes get_step return null, don't let things go off the edge
					break
				src.Move(step)
				hit_check(speed)
				error -= dist_x
				dist_travelled++
				dist_since_sleep++
				if(dist_since_sleep >= speed)
					dist_since_sleep = 0
					sleep(1)

			a = get_area(src.loc)

	//done throwing, either because it hit something or it finished moving
	if(isobj(src)) src.throw_impact(get_turf(src),speed)
	src.throwing = 0
	src.thrower = null
	src.throw_source = null


//Overlays
/atom/movable/overlay
	var/atom/master = null
	anchored = 1

/atom/movable/overlay/New()
	verbs.Cut()
	return

/atom/movable/overlay/attackby(a, b, c)
	if(src.master)
		return src.master.attackby(a, b, c)
	return


/atom/movable/overlay/attack_hand(a, b, c)
	if(src.master)
		return src.master.attack_hand(a, b, c)
	return


/atom/movable/proc/water_act(var/volume, var/temperature, var/source) //amount of water acting : temperature of water in kelvin : object that called it (for shennagins)
	return 1

/atom/movable/proc/handle_buckled_mob_movement(newloc,direct)
	if(!buckled_mob.Move(newloc, direct))
		loc = buckled_mob.loc
		last_move = buckled_mob.last_move
		inertia_dir = last_move
		buckled_mob.inertia_dir = last_move
		return 0
	return 1

/atom/movable/CanPass(atom/movable/mover, turf/target, height=1.5)
	if(buckled_mob == mover)
		return 1
	return ..()
