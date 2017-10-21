//This could either be split into the proper DM files or placed somewhere else all together, but it'll do for now -Nodrak

/*

A list of items and costs is stored under the datum of every game mode, alongside the number of crystals, and the welcoming message.

*/


/obj/item/device/contract
	name = "Contract"
	desc = "A generic contract."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "contract"
	item_state = "contract"
	w_class = 1
	var/datum/mind/created_for
	var/contractdesc = "This is a generic contract. Only BLANK should be able to see this"
	var/contractname = "Generic Contract"
	var/isevil = 0
	var/factionuid = ""
	var/burner = 0
	var/list/contractitems
/obj/item/device/contract/New()
	..()
	
/*
	NANO UI FOR UPLINK WOOP WOOP
*/


/obj/item/device/contract/proc/confirm(var/mob/user)
	var/turf/floor
	if(!istype(user, /mob/))
		return 0
	if(!user.mind)
		return 0
	if(!locs || isemptylist(locs))
		return 0
	floor = locs[1]
	if(factionuid)
		var/datum/faction/tfac = get_faction_datum(factionuid)
		tfac.add_member(user.mind)

	if(contractitems && !isemptylist(contractitems))
		var/obj/temp1 = contractitems[1]
		if(contractitems.len == 1)
			to_chat(user, "The contract ejects an [temp1.name].")
		else
			to_chat(user, "The contract ejects a few items including an [temp1.name].")
		for (var/obj/ob in contractitems)
			if(istype(ob))
				floor.contents += ob

	if(burner)
		to_chat(user, "As soon as the contract registers the confirmation it fizzles into ashes.")
	else
		to_chat(user, "As soon as the contract registers the confirmation it beeps 'FILE ME!'.")
	if(burner)
		qdel(src)

	return 1

/obj/item/device/contract/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	var/title = "Official Contract"
	var/is_owner
	if (user.mind && created_for)
		is_owner = (user.mind.name == created_for.name)
	else
		is_owner = 0
	var/data[0]
	data["is_owner"] = is_owner
	data["title"] = contractname
	data["desc"] = contractdesc
	data["syndie"] = isevil
	if(created_for)
		data["owner"] = created_for.name
	// update the ui if it exists, returns null if no ui is passed/found
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "contract.tmpl", title, 700, 600, state = inventory_state)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()


/obj/item/device/contract/attack_self(mob/user)
	ui_interact(user)


// The purchasing code.
/obj/item/device/contract/Topic(href, href_list)
	if(usr.stat || usr.restrained())
		return 1

	if(!( istype(usr, /mob/living/carbon/human)))
		return 1
	var/mob/user = usr

	if((usr.contents.Find(src.loc) || (in_range(src.loc, usr) && istype(src.loc.loc, /turf))))
		usr.set_machine(src)
		if(..(href, href_list))
			return 1
		else if(href_list["confirmed"] == "1")
			return confirm(usr)
	nanomanager.update_uis(src)
	return 1


/obj/item/device/contract/syndie
	name = "Unlabeled Contract"
	desc = "A contract that can only be viewed by the intended recipient, how mysterious."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "contract"
	item_state = "contract"
	w_class = 1
	contractdesc = "Your recent activities have demonstrated a hostility to Nanotransen."

	contractname = "Offer to join the Syndicate"
	isevil = 1
	factionuid = "syndicate"
	burner = 1
/obj/item/device/contract/syndie/New()
	..()
	contractitems = list()
	contractitems += new /obj/item/weapon/implanter/uplink/syndie()
	contractdesc += "<br>We are an organisation devoted to breaking the monopoly Nanotransen has on the terran economy,<br>and gaining equality and freedom for all humanoids."
	contractdesc += "<br><br> Join us and you will be paid for completing our contracts<br>and exporting things to our personal cargo dock."
	contractdesc += "<br><br> You are free to refuse our offer, <br>however if you tell security about this contract we will no longer respect your right to live. <br><br>"