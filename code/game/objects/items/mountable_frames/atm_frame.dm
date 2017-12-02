/obj/item/mounted/frame/atm_frame
	name = "atm"
	desc = "An ATM, just secure to the wall."
	icon_state = "atm_frame"
	item_state = "syringe_kit"
	materials = list(MAT_METAL=80000, MAT_GLASS=4000)
	mount_reqs = list("simfloor", "nospace")

/obj/item/mounted/frame/atm_frame/do_build(turf/on_wall, mob/user)
	new /obj/machinery/atm(get_turf(src), get_dir(on_wall, user), 1)
	qdel(src)
