/obj/item/mounted/frame/barsign_frame
	name = "bar sign frame"
	desc = "Used to build bar signs, just secure to the wall."
	icon_state = "barsign"
	item_state = "syringe_kit"
	materials = list(MAT_METAL=28000, MAT_GLASS=16000)
	mount_reqs = list("simfloor", "nospace")


/obj/item/mounted/frame/barsign_frame/do_build(turf/on_wall, mob/user)
	new /obj/structure/sign/barsign(get_step(user.loc, user.dir))
	qdel(src)

/obj/item/mounted/frame/barsign_frame/try_build(turf/on_wall, mob/user)
	if(..())
		var/turf/T = get_turf(get_step(on_wall, EAST))
		if(istype(T, /turf/simulated/wall))
			return 1
		else
			to_chat(user, "<span class='rose'>[src] requires two walls.</span>")
			return