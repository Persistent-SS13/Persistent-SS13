/datum/riding
	var/next_vehicle_move = 0 //used for move delays
	var/vehicle_move_delay = 2 //tick delay between movements, lower = faster, higher = slower
	var/keytype = null
	var/atom/movable/ridden = null
	var/slowed = FALSE
	var/slowvalue = 1

/datum/riding/New(atom/movable/_ridden)
	ridden = _ridden

/datum/riding/Destroy()
	ridden = null
	return ..()


/datum/riding/proc/on_vehicle_move()
	for(var/mob/living/M in ridden.buckled_mob)
		handle_ride(M)

/datum/riding/proc/force_dismount(mob/living/M)
	restore_position(M)
	ridden.unbuckle_mob(M)
	var/turf/target = get_edge_target_turf(ridden, ridden.dir)
	var/turf/targetm = get_step(get_turf(ridden), ridden.dir)
	M.Move(targetm)
	M.visible_message("<span class='warning'>[M] is thrown clear of [ridden]!</span>")
	M.throw_at(target, 14, 5, ridden)
	M.Weaken(3)

/datum/riding/proc/handle_vehicle_offsets(mob/living/buckled_mob)
	if(ridden.buckled_mob)
		if(ridden.dir == NORTH)
			buckled_mob.pixel_x = 0
			buckled_mob.pixel_y = 0
			buckled_mob.layer = MOB_LAYER
		if(ridden.dir == SOUTH)
			buckled_mob.pixel_x = 0
			buckled_mob.pixel_y = 0
			buckled_mob.layer = MOB_LAYER - 0.1
		if(ridden.dir == EAST)
			buckled_mob.pixel_x = 0
			buckled_mob.pixel_y = 0
			buckled_mob.layer = MOB_LAYER - 0.1
		if(ridden.dir == WEST)
			buckled_mob.pixel_x = 0
			buckled_mob.pixel_y = 0
			buckled_mob.layer = MOB_LAYER - 0.1
		
		



//KEYS
/datum/riding/proc/keycheck(mob/user)
	if(keytype)
		if(istype(user.l_hand, keytype) || istype(user.r_hand, keytype))
			return TRUE
	else
		return TRUE
	return FALSE

//BUCKLE HOOKS
/datum/riding/proc/restore_position(mob/living/buckled_mob)
	if(istype(buckled_mob))
		buckled_mob.pixel_x = 0
		buckled_mob.pixel_y = 0

//MOVEMENT
/datum/riding/proc/handle_ride(mob/user, direction)
	if(user.incapacitated())
		to_chat(user, "<span class='userdanger'>You fall off of [ridden]!</span>")
		ridden.unbuckle_mob(user)
		return

	if(world.time < next_vehicle_move)
		return
	next_vehicle_move = world.time + vehicle_move_delay
	if(keycheck(user))
		to_chat(viewers(src), "<span class='notice'>It sees when to check offsets</span>")
		if(!ridden.Process_Spacemove(direction) || !isturf(ridden.loc))
			return
		step(ridden, direction)

	else
		to_chat(user, "<span class='notice'>You'll need the keys in one of your hands to drive \the [ridden.name].</span>")

//Mech riding woo!
/datum/riding/mecha
	keytype = null
			
/datum/riding/mecha/handle_vehicle_offsets(mob/living/M)
	if(ridden.buckled_mob)
		ridden.buckled_mob.dir=ridden.dir
		if(ridden.buckled_mob.dir == NORTH)
			ridden.buckled_mob.pixel_x = 8
			ridden.buckled_mob.pixel_y = 10
			ridden.buckled_mob.layer = 4.1
		if(ridden.buckled_mob.dir == SOUTH)
			ridden.buckled_mob.pixel_x = -8
			ridden.buckled_mob.pixel_y = 10
			ridden.buckled_mob.layer = 3.9
		if(ridden.buckled_mob.dir == EAST)
			ridden.buckled_mob.pixel_x = -9
			ridden.buckled_mob.pixel_y = 10
			ridden.buckled_mob.layer = 3.9
		if(ridden.buckled_mob.dir == WEST)
			ridden.buckled_mob.pixel_x = 9
			ridden.buckled_mob.pixel_y = 10
			ridden.buckled_mob.layer = 3.9
					
/datum/riding/mecha/force_dismount(mob/living/M)
	restore_position(M)
	ridden.unbuckle_mob(M)
	var/turf/target = get_edge_target_turf(ridden, ridden.dir)
	var/turf/targetm = get_step(get_turf(ridden), ridden.dir)
	M.Move(targetm)
	M.visible_message("<span class='warning'>[M] is thrown clear of [ridden]!</span>")
	M.throw_at(target, 14, 5, ridden)
	M.Weaken(3)

/datum/riding/proc/equip_buckle_inhands(mob/living/carbon/human/user)
	var/obj/item/riding_offhand/inhand = new /obj/item/riding_offhand(user)
	inhand.rider = user
	inhand.ridden = ridden
	if((!user.hand && user.l_hand == null)||(user.hand && user.r_hand != null))
		user.equip_or_collect(inhand, slot_l_hand)
		return TRUE
	else if((user.hand && user.r_hand==null)||(!user.hand && user.l_hand!=null))
		user.equip_or_collect(inhand, slot_r_hand)
		return TRUE
	return FALSE

/obj/item/riding_offhand
	name = "offhand"
	icon = 'icons/obj/weapons.dmi'
	icon_state = "offhand"
	w_class = 2
	flags = NOBLUDGEON | ABSTRACT
	burn_state = LAVA_PROOF | FIRE_PROOF
	var/mob/living/carbon/rider
	var/mob/living/ridden
	var/selfdeleting = FALSE
	
/obj/item/riding_offhand/attackby()
	return

/obj/item/riding_offhand/dropped()
	selfdeleting = TRUE
	ridden.unbuckle_mob(rider)
	qdel(src)
	
/obj/item/riding_offhand/equipped(mob/user)
	if(!user.on_ride)
		user.unEquip(src)	


/obj/item/riding_offhand/Destroy()
	if(selfdeleting)
		if(rider in ridden.buckled_mob)
			ridden.unbuckle_mob(rider)
			qdel(src)
	. = ..()