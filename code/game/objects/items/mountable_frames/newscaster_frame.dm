/obj/item/mounted/frame/newscaster_frame
	name = "newscaster frame"
	desc = "Used to build newscasters, just secure to the wall."
	icon_state = "newscaster"
	item_state = "syringe_kit"
	materials = list(MAT_METAL=14000, MAT_GLASS=8000)
	mount_reqs = list("simfloor", "nospace")

/obj/item/mounted/frame/newscaster_frame/do_build(turf/on_wall, mob/user)
	new /obj/machinery/newscaster(get_turf(src), get_dir(on_wall, user), 1)
	qdel(src)