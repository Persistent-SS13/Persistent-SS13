//Keeps track of the time for the ID console. Having it as a global variable prevents people from dismantling/reassembling it to
//increase the slots of many jobs.
var/global/obj/machinery/computer/employee_control/employee_control_terminal
/obj/machinery/computer/employee_control
	name = "Employment Requests Console"
	desc = "Terminal for accepting or denying promotions, demotions and certifcation changes."
	icon_keyboard = "id_key"
	icon_screen = "id"
	req_access = list(access_cent_specops)
	circuit = /obj/item/weapon/circuitboard/card/centcom
	light_color = LIGHT_COLOR_LIGHTBLUE
	var/obj/item/weapon/card/id/scan = null
	var/printing = null
	var/list/requests = list()
	var/datum/employment_request/current
	var/obj/item/weapon/paper/selected_doc
	map_storage_saved_vars = "density;icon_state;dir;name;pixel_x;pixel_y;requests"
/obj/machinery/computer/employee_control/New()
	..()
	employee_control_terminal = src
/obj/machinery/computer/employee_control/attack_hand(mob/user as mob)
	ui_interact(user)

/datum/employment_request
	var/name_target = ""
	var/name_sender = ""
	var/change_rank = 0 // 1 = promotion, 2 = demotion
	var/department = ""
	var/rank = 0
	var/change_cert = 0 // 1 = add cert, 2 = remove cert
	var/cert_uid = ""
	var/list/attached_documents = list()
	map_storage_saved_vars = "name_target;name_sender;change_rank;department;rank;change_cert;cert_uid;attached_documents"
/datum/employment_request/proc/approve()
	var/datum/data/record/record
	var/active = 0
	if(data_core.gen_byname[name_target])
		active = 1
		record = data_core.gen_byname[name_target]
	if(!record)
		for(var/datum/data/record/R in data_core.general)
			if(R.fields["name"] == name_target || name_target == R.fields["fingerprint"])
				record = R
			else
				//Foreach continue //goto(3229)
	if(!record)
		record = map_storage.Load_Records(name_target, 1)
		data_core.general += record
	if(!record)
		message_admins("record not found for request target:[name_target]")
		return
	if(change_cert == 1)
		var/found_duplicate = 0
		for(var/datum/cert/job in record.fields["certs"])
			if(job.uid == cert_uid)
				found_duplicate = 1
				break
		if(found_duplicate)
			message_admins("trying to add a cert that employee already has employee_control")
			return
		else
			record.fields["certs"] |= job_master.GetCert(cert_uid)
			record.fields["cert_uid"] = cert_uid
	if(change_cert == 2)
		for(var/datum/cert/job in record.fields["certs"])
			if(job.uid == cert_uid)
				record.fields["certs"] -= job
				if(record.fields["cert_uid"] == job.uid)
					record.fields["cert_uid"] = "intern"
				break
	if(change_rank)
		record.fields["rank_list"][department] = rank
	if(active)
		var/datum/mind/mind = data_core.get_mind(record)
		data_core.check_changes(mind)
		
/obj/machinery/computer/employee_control/proc/format_requests()
	var/list/formatted = list()
	var/ind = 0
	for(var/datum/employment_request/request in requests)
		ind++
		var/action = ""
		var/cert_title = ""
		var/button_name = ""
		if(request.change_rank == 1) // [name_sender] requests a [action] for [name_target]
			action = "promotion"
		if(request.change_rank == 2)
			action = "demotion"
		if(request.change_cert == 1)
			action = "new certification"
		if(request.change_cert == 2)
			action = "certification removal"
		if(request.change_cert)
			var/datum/cert/job = job_master.GetCert(request.cert_uid)
			button_name = "[request.name_sender] requests a [action] ([job.title]) for [request.name_target]."
		else
			button_name = "[request.name_sender] requests a [action] to rank [request.rank] in [request.department] for [request.name_target]."
		formatted.Add(list(list(
			"button_name" = button_name,
			"ind" = ind)))

	return formatted
/obj/machinery/computer/employee_control/proc/format_current(var/datum/employment_request/request)
	var/action = 0
	var/button_name = ""
	if(request.change_rank == 1) // [name_sender] requests a [action] for [name_target]
		action = "promotion"
	if(request.change_rank == 2)
		action = "demotion"
	if(request.change_cert == 1)
		action = "new certification"
	if(request.change_cert == 2)
		action = "certification removal"
	if(!action)
		message_admins("request without action! format_current employment_control")
	if(request.change_cert)
		var/datum/cert/job = job_master.GetCert(request.cert_uid)
		button_name = "[request.name_sender] requests a [action] ([job.title]) for [request.name_target]."
	else
		button_name = "[request.name_sender] requests a [action] to rank [request.rank] in [request.department] for [request.name_target]."
	return button_name
/obj/machinery/computer/employee_control/proc/format_documents(var/datum/employment_request/request)
	var/list/formatted = list()
	var/ind = 0
	for(var/obj/item/weapon/paper/P in request.attached_documents)
		ind++
		formatted.Add(list(list(
			"title" = P.name,
			"ind" = ind)))
	return formatted

/obj/machinery/computer/employee_control/ui_interact(mob/user, ui_key="main", var/datum/nanoui/ui = null, var/force_open = 1)
	if(!is_admin(user)) return
	user.set_machine(src)
	var/mode = 0
	var/data[0]
	data["src"] = "\ref[src]"
	
	if(selected_doc)
		mode = 3
		data["title"] = selected_doc.name
		data["content"] = selected_doc.info
	else if(current)
		mode = 2
		data["title"] = format_current(current)
		data["documents"] = format_documents(current)
	else
		mode = 1
		data["requests"] = format_requests()
	data["mode"] = mode
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "employee_control.tmpl", src.name, 775, 700, state = admin_state)
		ui.set_initial_data(data)
		ui.open()

/obj/machinery/computer/employee_control/Topic(href, href_list)
	if(..())
		return 1
	if(!is_admin(usr))
		return
	switch(href_list["choice"])
		if("view_request")
			var/ind = text2num(href_list["ind"])
			current = requests[ind]
			nanomanager.update_uis(src)
		if("back_current")
			current = null
			selected_doc = null
			nanomanager.update_uis(src)
		if("back_document")
			selected_doc = null
			nanomanager.update_uis(src)
		if("view_document")
			var/ind = text2num(href_list["ind"])
			selected_doc = current.attached_documents[ind]
			nanomanager.update_uis(src)
		if("approve")
			if(alert(usr,"Are you sure you want to APPROVE the request? You should review all submitted paperwork before ACCEPTING this request.","Warning!","Yes","No") == "Yes")
				if(current)
					current.approve()
					requests -= current
					current = null
					nanomanager.update_uis(src)
		if("deny")
			if(alert(usr,"Are you sure you want to DENY the request? You should review all submitted paperwork before DECLINING this request.","Warning!","Yes","No") == "Yes")
				requests -= current
				current = null
				nanomanager.update_uis(src)
		if("print")
			print(selected_doc)
	return 1

/obj/machinery/computer/employee_control/proc/print(var/obj/item/weapon/paper/copy)
	playsound(loc, "sound/goonstation/machines/printer_dotmatrix.ogg", 50, 1)
	sleep(50)
	var/obj/item/weapon/paper/c = new /obj/item/weapon/paper (loc)
	c.info = copy.info
	c.name = copy.name // -- Doohl
	c.fields = copy.fields
	c.stamps = copy.stamps
	c.stamped = copy.stamped
	c.ico = copy.ico
	c.offset_x = copy.offset_x
	c.offset_y = copy.offset_y
	var/list/temp_overlays = copy.overlays       //Iterates through stamps
	var/image/img                                //and puts a matching
	for(var/j = 1, j <= temp_overlays.len, j++) //gray overlay onto the copy
		if(copy.ico.len)
			if(findtext(copy.ico[j], "cap") || findtext(copy.ico[j], "cent"))
				img = image('icons/obj/bureaucracy.dmi', "paper_stamp-circle")
			else if(findtext(copy.ico[j], "deny"))
				img = image('icons/obj/bureaucracy.dmi', "paper_stamp-x")
			else
				img = image('icons/obj/bureaucracy.dmi', "paper_stamp-dots")
			img.pixel_x = copy.offset_x[j]
			img.pixel_y = copy.offset_y[j]
			c.overlays += img
	c.updateinfolinks()
	return c
