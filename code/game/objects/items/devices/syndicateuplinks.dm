//This could either be split into the proper DM files or placed somewhere else all together, but it'll do for now -Nodrak

/*

A list of items and costs is stored under the datum of every game mode, alongside the number of crystals, and the welcoming message.

*/

var/list/world_syndicateuplinks = list()


// HIDDEN UPLINK - Can be stored in anything but the host item has to have a trigger for it.
/* How to create an uplink in 3 easy steps!

 1. All obj/item 's have a hidden_uplink var. By default it's null. Give the item one with "new(src)", it must be in it's contents. Feel free to add "uses".

 2. Code in the triggers. Use check_trigger for this, I recommend closing the item's menu with "usr << browse(null, "window=windowname") if it returns true.
 The var/value is the value that will be compared with the var/target. If they are equal it will activate the menu.

 3. If you want the menu to stay until the users locks his uplink, add an active_uplink_check(mob/user as mob) in your interact/attack_hand proc.
 Then check if it's true, if true return. This will stop the normal menu appearing and will instead show the uplink menu.
*/




/obj/item/device/uplink/hidden/syndie
	name = "syndicate hidden uplink"
	desc = "There is something wrong if you're examining this."

	var/menu = 0
// The hidden uplink MUST be inside an obj/item's contents.
/obj/item/device/uplink/hidden/syndie/New()
	spawn(2)
		if(!istype(src.loc, /obj/item))
			qdel(src)
	world_syndicateuplinks += src





/obj/item/device/uplink/hidden/syndie/proc/format_faction_list(var/datum/faction/fac)
	var/list/formatted = list()
	for(var/datum/mind/M in fac.members)
		var/datum/department/department = get_department_datum(M.assigned_job.department_flag)
		formatted.Add(list(list(
			"codename" = M.codename ? M.codename : "Unknown",
			"department" = department.name,
			"status" = M.on_assignment ? "On Assignment" : "Laying low")))
	return formatted


/obj/item/device/uplink/hidden/syndie/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	var/title = "Syndicate Network Implant"
	var/datum/faction/syndicate = get_faction_datum("syndicate")
	var/data[0]
	var/codephrase = "*UKNOWN*"
	var/response = "*UNKNOWN*"
	if (!isemptylist(syndicate.codephrase))
		codephrase = syndicate.codephrase[1]
		response = syndicate.codephrase[syndicate.codephrase[1]]
	data["name"] = user.name
	data["menu"] = menu
	data["codephrase"] = codephrase
	data["response"] = response
	data["codename"] = user.mind.codename
	data["members"] = format_faction_list(syndicate)
	data["isactive"] = user.mind.on_assignment
	// update the ui if it exists, returns null if no ui is passed/found
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "syndieuplink.tmpl", title, 700, 600, state = inventory_state)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()


// Interaction code. Gathers a list of items purchasable from the paren't uplink and displays it. It also adds a lock button.
/obj/item/device/uplink/hidden/interact(mob/user)
	ui_interact(user)

/obj/item/device/uplink/hidden/syndie/Topic(href, href_list)
	if(usr.stat || usr.restrained())
		return 1

	if(!( istype(usr, /mob/living/carbon/human)))
		return 1
	var/mob/user = usr
	var/datum/nanoui/ui = nanomanager.get_open_ui(user, src, "main")
	if((usr.contents.Find(src.loc) || (in_range(src.loc, usr) && istype(src.loc.loc, /turf))))
		usr.set_machine(src)

		if(href_list["lock"])
			toggle()
			ui.close()
			return 1
		if(href_list["return"])
			nanoui_menu = round(nanoui_menu/10)
			update_nano_data()
		if(href_list["menu"])
			menu = text2num(href_list["menu"])

	nanomanager.update_uis(src)
	return 1
