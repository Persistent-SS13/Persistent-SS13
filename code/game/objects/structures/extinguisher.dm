/obj/structure/extinguisher_cabinet
	name = "extinguisher cabinet"
	desc = "A small wall mounted cabinet designed to hold a fire extinguisher."
	icon = 'icons/obj/closet.dmi'
	icon_state = "extinguisher_closed"
	anchored = 1
	density = 0
	var/obj/item/weapon/extinguisher/has_extinguisher = new/obj/item/weapon/extinguisher
	var/opened = 0

	map_storage_saved_vars = "density;icon_state;dir;name;pixel_x;pixel_y;req_access_txt;req_personal;opened;has_extinguisher"


/obj/structure/extinguisher_cabinet/New(loc, dir, building)
	..()

	if(loc)
		src.loc = loc

	if(dir)
		src.dir = dir

	if(building)
		has_extinguisher = null
		pixel_x = (dir & 3)? 0 : (dir == 4 ? -24 : 24)
		pixel_y = (dir & 3)? (dir ==1 ? -32 : 32) : 0


/obj/structure/extinguisher_cabinet/attackby(obj/item/O, mob/user, params)
	if(isrobot(user) || isalien(user))
		return
	if(istype(O, /obj/item/weapon/extinguisher))
		if(!has_extinguisher && opened)
			user.drop_item(O)
			contents += O
			has_extinguisher = O
			to_chat(user, "<span class='notice'>You place [O] in [src].</span>")
		else
			opened = !opened
	else
		opened = !opened
	if(iswelder(O))
		if(opened)
			to_chat(user, "<span class='notice'>Open the [src] first.</span>")
			return
		if(!opened)
			if(has_extinguisher)
				to_chat(user, "<span class='notice'>Remove the [has_extinguisher] first.</span>")
				return
			else
				if(actWeld(user, O, time = 20, message = "You start removing the [src] from the wall."))
					to_chat(user, "<span class='notice'>You remove the [src] from the wall.</span>")
					new /obj/item/mounted/frame/extinguisher_cabinet_frame(src.loc)
					qdel(src)
					return

	update_icon()


/obj/structure/extinguisher_cabinet/attack_hand(mob/user)
	if(isrobot(user) || isalien(user))
		return
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/organ/external/temp = H.organs_by_name["r_hand"]
		if(user.hand)
			temp = H.organs_by_name["l_hand"]
		if(temp && !temp.is_usable())
			to_chat(user, "<span class='notice'>You try to move your [temp.name], but cannot!")
			return
	if(has_extinguisher)
		user.put_in_hands(has_extinguisher)
		to_chat(user, "<span class='notice'>You take [has_extinguisher] from [src].</span>")
		has_extinguisher = null
		opened = 1
	else
		opened = !opened
	update_icon()

/obj/structure/extinguisher_cabinet/attack_tk(mob/user)
	if(has_extinguisher)
		has_extinguisher.loc = loc
		to_chat(user, "<span class='notice'>You telekinetically remove [has_extinguisher] from [src].</span>")
		has_extinguisher = null
		opened = 1
	else
		opened = !opened
	update_icon()


/obj/structure/extinguisher_cabinet/update_icon()
	if(!opened)
		icon_state = "extinguisher_closed"
		return
	if(has_extinguisher)
		if(istype(has_extinguisher, /obj/item/weapon/extinguisher/mini))
			icon_state = "extinguisher_mini"
		else
			icon_state = "extinguisher_full"
	else
		icon_state = "extinguisher_empty"
