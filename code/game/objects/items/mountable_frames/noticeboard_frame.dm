/obj/item/mounted/frame/noticeboard_frame
	name = "noticeboard"
	desc = "A notice board, just secure to the wall."
	icon_state = "noticeboard_frame"
	item_state = "syringe_kit"
	mount_reqs = list("simfloor", "nospace")

/obj/item/mounted/frame/noticeboard_frame/attackby(obj/item/weapon/W, mob/user)

	if(actWrench(user, W, time = 0))
		new /obj/item/stack/sheet/wood(src.loc, 3)
		qdel(src)
		return
	..()

/obj/item/mounted/frame/noticeboard_frame/do_build(turf/on_wall, mob/user)
	new /obj/structure/noticeboard(get_turf(src), get_dir(on_wall, user), 1)
	qdel(src)
