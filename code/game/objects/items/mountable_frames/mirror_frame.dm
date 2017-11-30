/obj/item/mounted/frame/mirror_frame
	name = "mirror"
	desc = "A mirror, just secure to the wall."
	icon_state = "mirror_frame"
	item_state = "syringe_kit"
	materials = list(MAT_METAL=1000, MAT_GLASS=8000)
	mount_reqs = list("simfloor", "nospace")


/obj/item/mounted/frame/mirror_frame/do_build(turf/on_wall, mob/user)
	new /obj/structure/mirror(get_turf(src), get_dir(on_wall, user), 1)
	qdel(src)
