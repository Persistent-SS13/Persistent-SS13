var/global/list/sec_recs_tosave[0] // ANY EDITS TO A SECURITY RECORD CAUSE IT TO BE PLACED IN HERE. CHANGES STORED UNTIL THE END OF THE ROUND WHEN IT GETS COMMITED TO THE DB
/obj/machinery/computer/security_records
	name = "Security Record Terminal"
	desc = "Used to view and edit personnel's security records."
	icon_keyboard = "security_key"
	icon_screen = "security"
	req_one_access = list(access_security, access_forensics_lockers)
	circuit = /obj/item/weapon/circuitboard/secure_data
	light_color = LIGHT_COLOR_LIGHTBLUE
	var/obj/item/weapon/card/id/scan = null
	var/mode = 0.0
	var/printing = null
	var/current_function = 0
	var/failed_search = 0 // TURNS to 1 when a search fails
	var/searched = 0 // TURNS to 1 when a search happens
	var/search_name // this is the name they searched for
	var/list/minor_crime
	var/minor_num = 0
	var/list/major_crime
	var/major_num = 0
	var/list/note
	var/note_num = 0
	var/list/logs
	var/logs_num = 0
	var/crim_stat = ""
	var/view_minor = 0
	var/view_major = 0
	var/view_note = 0
	var/view_logs = 0
	var/add_minor = 0
	var/add_major = 0
	var/add_note = 0
	var/change_status = 0
	var/edit_minor = 0
	var/edit_major = 0
	var/edit_note = 0
	var/entry = 0
	var/view_entry = "" // this carries the entry for editing
	var/selected_entry = 0 // this carries the number that the entry is in the list
	var/list/secdata // this holds the record to be saved (changes are commited to this)
/obj/machinery/computer/security_records/proc/is_authenticated(var/mob/user)
	if(user.can_admin_interact())
		return 1
	if(scan)
		return check_access(scan)
	return 0


/obj/machinery/computer/security_records/proc/format_record(list/data)
	crim_stat = data["criminal_status"]
	if(!crim_stat)
		crim_stat = "None"
	var/list/minor_crimes = data["minor_crimes"]
	if(!minor_crimes)
		minor_crimes = list()
	var/list/major_crimes = data["major_crimes"]
	if(!major_crimes)
		major_crimes = list()
	var/list/notes = data["notes"]
	if(!notes)
		notes = list()
	var/list/log = data["log"]
	if(!log)
		log = list()
	var/list/formatted = list()
	var/entrynum = 0
	
	for(var/entry in minor_crimes)
		entrynum++
		formatted.Add(list(list(
			"entry" = entry,
			"num" = entrynum)))
	minor_crime = formatted.Copy()
	minor_num = entrynum
	formatted = list()
	entry_num = 0
	
	for(var/entry in major_crimes)
		entrynum++
		formatted.Add(list(list(
			"entry" = entry,
			"num" = entrynum)))
	major_crime = formatted.Copy()
	major_num = entry_num
	formatted = list()
	entry_num = 0
	
	for(var/entry in notes)
		entrynum++
		formatted.Add(list(list(
			"entry" = entry,
			"num" = entrynum)))
	note = formatted.Copy()
	note_num = entry_num
	formatted = list()
	entry_num = 0
	
	for(var/entry in log)
		entrynum++
		formatted.Add(list(list(
			"entry" = entry,
			"num" = entrynum)))
	logs = formatted.Copy()
	logs_num = entry_num

/obj/machinery/computer/security_records/proc/reset_menu()
	view_minor = 0
	view_major = 0
	view_note = 0
	view_logs = 0
	change_status = 0
	edit_minor = 0
	edit_major = 0
	edit_note = 0
	edit_logs = 0
	view_entry = ""
	selected_entry = 0
/obj/machinery/computer/security_records/verb/eject_id()
	set category = null
	set name = "Eject ID Card"
	set src in oview(1)

	if(!usr || usr.stat || usr.lying)	return

	if(scan)
		to_chat(usr, "You remove \the [scan] from \the [src].")
		scan.loc = get_turf(src)
		if(!usr.get_active_hand())
			usr.put_in_hands(scan)
		scan = null
	else if(modify)
		to_chat(usr, "You remove \the [modify] from \the [src].")
		modify.loc = get_turf(src)
		if(!usr.get_active_hand())
			usr.put_in_hands(modify)
		modify = null
	else
		to_chat(usr, "There is nothing to remove from the console.")
	return

/obj/machinery/computer/security_records/attackby(obj/item/weapon/card/id/id_card, mob/user, params)
	if(!istype(id_card))
		return ..()
	if(scan)
		to_chat(user, "There is already a card in the machine.")
		
	else if(access_security in id_card.access)
		user.drop_item()
		id_card.loc = src
		scan = id_card
	else
		to_chat(user, "The card is rejected by the machine for insufficient access ")
	nanomanager.update_uis(src)
	attack_hand(user)

/obj/machinery/computer/security_records/attack_ai(var/mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/security_records/attack_hand(mob/user as mob)
	if(..())
		return
	if(stat & (NOPOWER|BROKEN))
		return

	ui_interact(user)

/obj/machinery/computer/security_records/ui_interact(mob/user, ui_key="main", var/datum/nanoui/ui = null, var/force_open = 1)
	user.set_machine(src)

	var/data[0]
	data["src"] = "\ref[src]"
	data["station_name"] = station_name()
	data["mode"] = mode
	data["printing"] = printing
	data["scan_name"] = scan ? scan.name : "-----"
	data["authenticated"] = is_authenticated(user)
	data["current_function"] = current_function
	data["failed_search"] = failed_search
	data["search_name"] = search_name
	data["searched"] = searched
	data["view_minor"] = view_minor
	data["view_major"] = view_major
	data["view_note"] = view_note
	data["view_logs"] = view_logs
	data["change_status"] = change_status
	data["edit_minor"] = edit_minor
	data["edit_major"] = edit_major
	data["edit_note"] = edit_note
	data["edit_logs"] = edit_logs
	data["view_entry"] = view_entry
	data["add_minor"] = add_minor
	data["add_major"] = add_major
	data["add_note"] = add_note
	if(searched)
		data["minor_crime"] = minor_crime
		data["minor_num"] = minor_num
		data["major_crime"] = major_crime
		data["major_num"] = major_num
		data["note"] = note
		data["note_num"] = note_num
		data["logs"] = logs
		data["logs_num"] = logs_num
		data["crim_stat"] = crim_stat
	else
		data["minor_crime"] = ""
		data["minor_num"] = 0
		data["major_crime"] = ""
		data["major_num"] = 0
		data["note"] = ""
		data["note_num"] = 0
		data["logs"] = ""
		data["logs_num"] = 0
		data["crim_stat"] = ""

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "security_records.tmpl", src.name, 775, 700)
		ui.set_initial_data(data)
		ui.open()

/obj/machinery/computer/security_records/Topic(href, href_list)
	if(..())
		return 1

	switch(href_list["choice"])
		
		if("search")
			
			search_name = href_list["search_field"]
			if(sec_recs_tosave.Find(search_name))
				secdata = sec_recs_tosave[search_name]
			else	
				secdata = usr.client.prefs.load_security_record(search_name)
				if(secdata)
					sec_recs_tosave[search_name] = secdata
			searched = 1
			if(secdata)
				format_record(secdata)
				failed_search = 0
			else
				failed_search = 1
		if("add_minor")
			reset_menu()
			add_minor = 1
			nanomanager.update_uis(src)
		if("add_major")
			reset_menu()
			add_major = 1
			nanomanager.update_uis(src)
		if("add_note")
			reset_menu()
			add_note = 1
			nanomanager.update_uis(src)
		if("view_minor")
			reset_menu()
			view_minor = 1
			nanomanager.update_uis(src)
		if("view_major")
			reset_menu()
			view_major = 1
			nanomanager.update_uis(src)
		if("view_note")
			reset_menu()
			view_note = 1
			nanomanager.update_uis(src)
		if("view_logs")
			reset_menu()
			view_logs = 1
			nanomanager.update_uis(src)
		if("edit_minor")
			selected_entry = text2num(href_list["entry_num"])
			if(!selected_entry)
				return
			var/list/minor_data = secdata["minor_crimes"]
			view_entry = minor_data[selected_entry]
			reset_menu()
			edit_minor = 1
			nanomanager.update_uis(src)
		if("edit_major")
			reset_menu()
			edit_major = 1
			nanomanager.update_uis(src)		
		if("edit_note")
			reset_menu()
			edit_note = 1
			nanomanager.update_uis(src)	
		if("edit_logs")
			reset_menu()
			edit_logs = 1
			nanomanager.update_uis(src)	
		if("reset_menu")
			reset_menu()
			nanomanager.update_uis(src)
		if("submit_minor_edit")
			var/addend = sanitize(href_list["submitted"])
			var/list/minor_data = secdata["minor_crimes"]
			minor_data[selected_entry] = (view_entry + " || " + addend + " -- addition made by " + scan.name + " (" + worldtime2text() + ")")
			secdata["minor_crimes"] = minor_data
			format_record(secdata)
			reset_menu()
			view_minor = 1
			nanomanager.update_uis(src)	
		if("submit_minor")
			var/entry = sanitize(href_list["submitted"])
			var/list/minor_data = secdata["minor_crimes"]
			minor_data += (entry + " -- entry made by " + scan.name + " (" + worldtime2text() + ")")
			secdata["minor_crimes"] = minor_data
			format_record(secdata)
			reset_menu()
			view_minor = 1
			nanomanager.update_uis(src)
		if("scan")
			if(scan)
				if(ishuman(usr))
					scan.loc = usr.loc
					if(!usr.get_active_hand())
						usr.put_in_hands(scan)
					scan = null
				else
					scan.loc = src.loc
					scan = null
			else
				var/obj/item/I = usr.get_active_hand()
				if(istype(I, /obj/item/weapon/card/id))
					usr.drop_item()
					I.loc = src
					scan = I

		if("mode")
			mode = text2num(href_list["mode_target"])

		if("print")
			if(!printing)
				printing = 1
				playsound(loc, "sound/goonstation/machines/printer_dotmatrix.ogg", 50, 1)
				spawn(50)
					printing = null
					nanomanager.update_uis(src)

					var/obj/item/weapon/paper/P = new(loc)
					if(mode == 2)
						P.name = text("crew manifest ([])", worldtime2text())
						P.info = {"<h4>Crew Manifest</h4>
							<br>
							[data_core ? data_core.get_manifest(0) : ""]
						"}
					else if(modify && !mode)
						P.name = "access report"
						P.info = {"<h4>Access Report</h4>
							<u>Prepared By:</u> [scan && scan.registered_name ? scan.registered_name : "Unknown"]<br>
							<u>For:</u> [modify.registered_name ? modify.registered_name : "Unregistered"]<br>
							<hr>
							<u>Assignment:</u> [modify.assignment]<br>
							<u>Account Number:</u> #[modify.associated_account_number]<br>
							<u>Blood Type:</u> [modify.blood_type]<br><br>
							<u>Access:</u><div style="margin-left:1em">
						"}

						var/first = 1
						for(var/A in modify.access)
							P.info += "[first ? "" : ", "][get_access_desc(A)]"
							first = 0
						P.info += "</div>"

	return 1

