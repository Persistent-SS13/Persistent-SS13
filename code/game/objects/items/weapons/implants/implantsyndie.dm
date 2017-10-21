/obj/item/weapon/implant/uplink/syndie
	name = "syndicate hidden implant"
	desc = "Transmits info to syndicate operatives."
	icon = 'icons/obj/radio.dmi'
	icon_state = "syn_cypherkey"
	origin_tech = "materials=2;magnets=4;programming=4;biotech=4;syndicate=8;bluespace=5"
	var/obj/item/device/uplink/hidden/syndie/faction_uplink = null

/obj/item/weapon/implant/uplink/syndie/New()
	faction_uplink = new(src)
	..()

/obj/item/weapon/implant/uplink/syndie/implant(mob/source)
	if(..())
		return 1
	return 0

/obj/item/weapon/implant/uplink/syndie/activate()
	if(!faction_uplink)
		for(var/obj/item/device/uplink/hidden/syndie/temp in src.contents)
			if(istype(temp))
				faction_uplink = temp
				break
	if(faction_uplink)
		faction_uplink.check_trigger(imp_in)


/obj/item/weapon/implanter/uplink/syndie
	name = "implanter (Network)"

/obj/item/weapon/implanter/uplink/syndie/New()
	imp = new /obj/item/weapon/implant/uplink/syndie(src)
	..()