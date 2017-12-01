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
		ride_check(M)
/datum/riding/proc/ride_check(mob/living/M)
	return TRUE

/datum/riding/proc/force_dismount(mob/living/M)
	ridden.unbuckle_mob(M)

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
		Unbuckle(user)
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

/datum/riding/proc/Unbuckle(mob/living/M)
	ridden.unbuckle_mob(M)

//Mech riding woo!
/datum/riding/mecha
	keytype = null

/datum/riding/mecha/ride_check(mob/user)
	if(user.incapacitated())
		to_chat(user, "<span class='userdanger'>You fall off of [ridden]!</span>")
		Unbuckle(user)
		return
			
	if(ishuman(user))
		var/mob/living/carbon/human/carbonuser = user
		var/obj/item/organ/external/l_hand = carbonuser.get_organ("l_hand")
		var/obj/item/organ/external/r_hand = carbonuser.get_organ("r_hand")
		if((!l_hand || (l_hand.status & ORGAN_DESTROYED)) || (!r_hand || (r_hand.status & ORGAN_DESTROYED)))
			Unbuckle(user)
			to_chat(user, "<span class='userdanger'>You can't grab onto [ridden] with no hands!</span>")
			return
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
	riding_datum.unequip_buckle_inhands(M)
	riding_datum.restore_position(M)
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

/datum/riding/proc/unequip_buckle_inhands(mob/living/carbon/user)
	for(var/obj/item/riding_offhand/O in user.contents)
		if(O.ridden != ridden)
			CRASH("RIDING OFFHAND ON WRONG MOB")
			continue
		if(O.selfdeleting)
			continue
		else
			qdel(O)
	return TRUE

/obj/item/riding_offhand
	name = "offhand"
	icon = 'icons/obj/weapons.dmi'
	icon_state = "offhand"
	w_class = 2
	flags = ABSTRACT | NOBLUDGEON
	burn_state = LAVA_PROOF | FIRE_PROOF
	var/mob/living/carbon/rider
	var/mob/living/ridden
	var/selfdeleting = FALSE

/obj/item/riding_offhand/dropped()
	selfdeleting = TRUE
	ridden.unbuckle_mob(rider)
	qdel(src)
		
/obj/item/riding_offhand/equipped()
	if(loc != rider)
		selfdeleting = TRUE
		Destroy()


/obj/item/riding_offhand/Destroy()
	if(selfdeleting)
		if(rider in ridden.buckled_mob)
			ridden.unbuckle_mob(rider)
			qdel(src)
	. = ..()