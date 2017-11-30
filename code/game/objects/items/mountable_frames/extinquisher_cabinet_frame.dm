/obj/item/mounted/frame/extinguisher_cabinet_frame
	name = "extinguisher cabinet frame"
	desc = "Used to build extinguisher cabinets, just secure to the wall."
	icon_state = "extinguisher_cabinet"
	item_state = "syringe_kit"
	materials = list(MAT_METAL=10000, MAT_GLASS=2000)
	mount_reqs = list("simfloor", "nospace")


/obj/item/mounted/frame/extinguisher_cabinet_frame/do_build(turf/on_wall, mob/user)
	var/obj/structure/extinguisher_cabinet/E = new(get_step(user.loc, user.dir))
	E.has_extinguisher = null
	qdel(src)
