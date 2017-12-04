//wip wip wup
/obj/structure/mirror
	name = "mirror"
	desc = "Mirror mirror on the wall, who's the most robust of them all?"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "mirror"
	density = 0
	anchored = 1
	var/shattered = 0
	var/list/ui_users = list()
	var/state = 0


/obj/structure/mirror/New(loc, dir, building)
	..()

	if(loc)
		src.loc = loc

	if(dir)
		src.dir = dir

	if(building)
		state = 3
		pixel_x = (dir & 3)? 0 : (dir == 4 ? -24 : 24)
		pixel_y = (dir & 3)? (dir ==1 ? -28 : 28) : 0


/obj/structure/mirror/attack_hand(mob/user as mob)
	if(state != 0)
		to_chat(user, "<span class='notice'>You need to secure the mirror first</span>")
		return
	if(shattered)	return

	if(ishuman(user))
		var/datum/nano_module/appearance_changer/AC = ui_users[user]
		if(!AC)
			AC = new(src, user)
			AC.name = "SalonPro Nano-Mirror&trade;"
			AC.flags = APPEARANCE_ALL_BODY
			ui_users[user] = AC
		AC.ui_interact(user)

/obj/structure/mirror/proc/shatter()
	if(shattered)	return
	shattered = 1
	icon_state = "mirror_broke"
	playsound(src, "shatter", 70, 1)
	desc = "Oh no, seven years of bad luck!"


/obj/structure/mirror/bullet_act(var/obj/item/projectile/Proj)
	if(prob(Proj.damage * 2))
		if(!shattered)
			shatter()
		else
			playsound(src, 'sound/effects/hit_on_shattered_glass.ogg', 70, 1)
	..()


/obj/structure/mirror/attackby(obj/item/I as obj, mob/living/user as mob, params)
	if(actScrewdriver(user, I, time = 0, skill = 0))
		switch(state)
			if(0)
				state = 1
				to_chat(user, "<span class='notice'>You unfasten the [name]'s screws.</span>")
			if(1)
				state = 0
				to_chat(user, "<span class='notice'>You fasten the [name]'s screws.</span>")
			if(2)
				state = 3
				to_chat(user, "<span class='notice'>You unfasten the [name]'s screws.</span>")
			if(3)
				state = 2
				to_chat(user, "<span class='notice'>You fasten the [name]'s screws.</span>")
		return
	if(state == 3 && actWrench(user, I, time = 10, skill = 0))
		to_chat(user, "<span class='notice'>You disassemble the [name].</span>")
		if(!shattered)
			new /obj/item/mounted/frame/mirror_frame(user.loc)
		qdel(src)
		return
	if((state == 1 || state == 2) && actCrowbar(user, I, time = 10, skill = 0))
		switch(state)
			if(1)
				state = 2
				to_chat(user, "<span class='notice'>You pry the [name] out of its frame.</span>")
			if(2)
				state = 1
				to_chat(user, "<span class='notice'>You pry the [name] into its frame.</span>")
		return

	user.do_attack_animation(src)
	if(shattered)
		playsound(src.loc, 'sound/effects/hit_on_shattered_glass.ogg', 70, 1)
		return

	if(prob(I.force * 2))
		visible_message("<span class='warning'>[user] smashes [src] with [I]!</span>")
		shatter()
	else
		visible_message("<span class='warning'>[user] hits [src] with [I]!</span>")
		playsound(src.loc, 'sound/effects/Glasshit.ogg', 70, 1)


/obj/structure/mirror/attack_alien(mob/living/user as mob)
	if(islarva(user)) return
	user.do_attack_animation(src)
	if(shattered)
		playsound(src.loc, 'sound/effects/hit_on_shattered_glass.ogg', 70, 1)
		return
	user.visible_message("<span class='danger'>[user] smashes [src]!</span>")
	shatter()


/obj/structure/mirror/attack_animal(mob/living/user as mob)
	if(!isanimal(user)) return
	var/mob/living/simple_animal/M = user
	if(M.melee_damage_upper <= 0) return
	M.do_attack_animation(src)
	if(shattered)
		playsound(src.loc, 'sound/effects/hit_on_shattered_glass.ogg', 70, 1)
		return
	user.visible_message("<span class='danger'>[user] smashes [src]!</span>")
	shatter()


/obj/structure/mirror/attack_slime(mob/living/user as mob)
	var/mob/living/carbon/slime/S = user
	if(!S.is_adult)
		return
	user.do_attack_animation(src)
	if(shattered)
		playsound(src.loc, 'sound/effects/hit_on_shattered_glass.ogg', 70, 1)
		return
	user.visible_message("<span class='danger'>[user] smashes [src]!</span>")
	shatter()