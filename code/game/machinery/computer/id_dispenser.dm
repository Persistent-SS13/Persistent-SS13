/obj/machinery/id_dispenser
	name = "Identification Card Dispenser"
	desc = "You can use this machine to dispense yourself a new I.D card."
	icon = 'icons/obj/vending.dmi'
	icon_state = "id_disp" // MAKE THIS ICON!
	var/max_relative_positions = 30 //30%: Seems reasonable, limit of 6 @ 20 players
	var/list/opened_positions = list();
	layer = 2.9
	anchored = 1
	density = 1
	// Power
	use_power = 1
	idle_power_usage = 10

	
/obj/machinery/id_dispenser/proc/copyMecha(var/mob/living/H)
	if(!H || !H.mind)
		return 0
	var/obj/mecha/mech = H.loc
	var/list/certs = list()
	var/datum/cert/job = H.mind.assigned_job
	if (!istype(job, /datum/cert))
		message_admins("[H.name] assigned_job not proper type")
		return 0
	for(var/access in job.get_access())
		mech.operation_req_access += access
	for(var/datum/cert/J in H.mind.certs)
		if(J.department_flag == job.department_flag)
			certs += J
	for(var/datum/cert/Jo2 in certs)
		for (var/access in Jo2.get_access())
			mech.operation_req_access += access
	to_chat(H, "Your acceses have been copied into your mecha. Exit the mecha if you need a printed ID.")
	return 1

	
	
/obj/machinery/id_dispenser/proc/spawnIdRobo(var/mob/living/silicon/robot/H)
	if(!H || !H.mind)
		return 0
	var/list/certs = list()
	var/obj/item/weapon/card/id/C = null
	var/datum/cert/job = H.mind.assigned_job
	for(var/datum/cert/J in H.mind.certs)
		if(J.department_flag == job.department_flag)
			certs += J
	if (istype(job, /datum/cert))
		C = new job.idtype(H)		
	else
		message_admins("[H.name] assigned_job not proper type")
		return 0
		
	var/list/acceses = list()
	for(var/access in job.get_access())
		acceses += access
	for(var/datum/cert/Jo2 in certs)
		for (var/access in Jo2.get_access())
			if (!(access in acceses))
				acceses += access
	if(H.mind.spawned_id)
		H.mind.spawned_id.visible_message("[H.mind.spawned_id] begins to dissolve rapidly")
		qdel(H.mind.spawned_id)
	if(C)
		C.access = acceses
		C.registered_name = H.real_name
		C.rank = job
		C.assignment = get_default_title(H.mind.ranks[to_strings(job.department_flag)], job)
		C.sex = capitalize(H.gender)
		C.age = H.age
		C.name = "[C.registered_name]'s ID Card ([C.assignment])"
		C.photo = get_id_photo(H)
		C.assigned_mind = H.mind
		H.mind.spawned_id = C
		//put the player's account number onto the ID
		if(H.mind && H.mind.initial_account)
			C.associated_account_number = H.mind.initial_account.account_number		
		if(!H.module_state_4.id)
			C.forceMove(H.module_state_4)
			H.module_state_4.id = C
			H.module_state_4.owner = C.registered_name
			H.module_state_4.ownjob = C.assignment
			H.module_state_4.ownrank = C.rank
			H.module_state_4.name = "PDA-[H.module_state_4.owner] ([H.module_state_4.ownjob])"
		else
			C.loc = loc
	return 1

/obj/machinery/id_dispenser/proc/spawnId(var/mob/living/carbon/human/H)
	if(!H || !H.mind)
		return 0
	var/list/certs = list()
	var/obj/item/weapon/card/id/C = null
	var/datum/cert/job = H.mind.assigned_job
	for(var/datum/cert/J in H.mind.certs)
		if(J.department_flag == job.department_flag)
			certs += J
	if (istype(job, /datum/cert))
		C = new job.idtype(H)		
	else
		message_admins("[H.name] assigned_job not proper type")
		return 0
		
	var/list/acceses = list()
	for(var/access in job.get_access())
		acceses += access
	for(var/datum/cert/Jo2 in certs)
		for (var/access in Jo2.get_access())
			if (!(access in acceses))
				acceses += access
	if(H.mind.spawned_id)
		H.mind.spawned_id.visible_message("[H.mind.spawned_id] begins to dissolve rapidly")
		qdel(H.mind.spawned_id)
	if(C)
		C.access = acceses
		C.registered_name = H.real_name
		C.rank = job
		
		C.assignment = get_default_title(H.mind.ranks[to_strings(job.department_flag)], job)
		C.sex = capitalize(H.gender)
		C.age = H.age
		C.name = "[C.registered_name]'s ID Card ([C.assignment])"
		C.photo = get_id_photo(H)
		C.assigned_mind = H.mind
		H.mind.spawned_id = C
		//put the player's account number onto the ID
		if(H.mind && H.mind.initial_account)
			C.associated_account_number = H.mind.initial_account.account_number		
		if(!H.get_active_hand())
			H.put_in_hands(C)
		else
			C.loc = loc
	return 1		
	
/obj/machinery/id_dispenser/attackby(obj/item/ob, mob/user, params)
	nanomanager.update_uis(src)
	attack_hand(user)

/obj/machinery/id_dispenser/attack_ai(var/mob/user as mob)
	return attack_hand(user)

/obj/machinery/id_dispenser/attack_hand(mob/user as mob)
	if(..())
		return
	if(stat & (NOPOWER|BROKEN))
		return

	ui_interact(user)

/obj/machinery/id_dispenser/ui_interact(mob/user, ui_key="main", var/datum/nanoui/ui = null, var/force_open = 1)
	user.set_machine(src)

	var/data[0]
	data["src"] = "\ref[src]"
	data["station_name"] = station_name()
	data["user_name"] = user.name
	if(user.mind.assigned_job)
		data["cert_name"] = user.mind.assigned_job.title
		data["found"] = 1
	else
		data["found"] = 0
		
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "id_dispenser.tmpl", src.name, 440, 600)
		ui.set_initial_data(data)
		ui.open()

/obj/machinery/id_dispenser/Topic(href, href_list)
	if(..())
		return 1
	switch(href_list["choice"])
		if("print_id")
			if(istype(usr.loc, /obj/mecha))
				copyMecha(usr)
			else if(istype(usr, /mob/living/carbon/human))
				spawnId(usr)
				playsound(loc, "sound/goonstation/machines/printer_dotmatrix.ogg", 50, 1)
			else if(istype(usr, /mob/living/silicon/robot))
				spawnIdRobo(usr)
				playsound(loc, "sound/goonstation/machines/printer_dotmatrix.ogg", 50, 1)
			nanomanager.close_uis(src)
		if("close")
			nanomanager.close_uis(src)

	return 1