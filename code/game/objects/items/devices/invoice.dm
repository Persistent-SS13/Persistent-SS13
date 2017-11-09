/obj/item/device/invoice
	name = "Invoice" // set through creator
	desc = "An invoice with a built in card scanner." // set through creator
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "invoice"
	item_state = "paper"
	w_class = 1
	var/datum/mind/created_for // set through creator
	var/payment_type = 1 // -- 1 = pay immidietley, 2 = pay on delivery (used for when ordering through the cargo shuttle) 
	var/cost = 0 // set through creator
	var/invoice_desc = "" // set through creator
	var/title = "" // set through creater, format -- CENTCOM CARGO DEPARTMENT INVOICE
	var/obj/machinery/connected // -- set through creator, Passes to the connected machine when the invoice is paid for
	var/list/authentication // set through creator, format -- authentication += list("uid" = "[certuid]", "name" = "[certtitle]")
	var/datum/money_account/destination // set through creator, used only if paying immidietley
	var/authenticated = 0
	var/paid = 0
	var/paidname = ""
	var/department = 0
	var/department_name
	should_save = 0
/obj/item/device/invoice/New()
	authentication = list()
	..()
	
/obj/item/device/invoice/proc/confirmdept(mob/user)
	if(!authenticated && authentication.len)
		to_chat(user, "This invoice needs to be authorized.")
		return 0
	if(paid)
		return 0
	if(user.mind.assigned_job.department_flag != department && user.mind.assigned_job.department_flag != COMMAND)
		message_admins("[user.name] attempting to pay for a department invoice & not in their department")
		return 0
	if(user.mind.allocated < cost && !user.mind.assigned_job.head_position)
	//	message_admins("[user.name] attempting to pay for a department invoice they cannot afford")
		to_chat(user, "You do not have enough funds allocated to make the payment.")
		return 0
	var/datum/money_account/account = department_accounts[department_name]
	if(!account)
		message_admins("No department found for flag [department_name]")
		return 0
	if(account.money < cost)
		to_chat(user, "There's not enough cash in the department account")
		return 0
	if(payment_type == 2)
		account.hold(cost)
	else
		account.charge(cost, destination, name, "Invoice slip", 0, destination.owner_name)
	if(!user.mind.assigned_job.head_position)
		user.mind.allocated -= cost
	if(connected)
		paid = 1
		paidname = account.owner_name
		return connected.handle_invoice_confirm(src, account)
	else
		paid = 1
		paidname = account.owner_name
		message_admins("invoice confirmed without connected machine")
		return 1

	
/obj/item/device/invoice/proc/confirm(mob/user, var/datum/money_account/account,  var/swiped = 0)
	if(!authenticated && authentication.len)
		to_chat(user, "This invoice needs to be authorized.")
		return 0
	if(paid)
		return 0
	if(!swiped || account.security_level == 2 || account != user.mind.initial_account)
		var/attempt_pin = input(user, "Enter pin code", "Invoice transaction") as num
		if(attempt_pin != account.remote_access_pin)
			to_chat(user, "Incorrect Pin.")
			return 0
	if(account.money < cost)
		to_chat(user, "Insufficent funds in this account.")
		return 0
	if(payment_type == 2)
		account.hold(cost)
	else
		account.charge(cost, destination, name, "Invoice slip", 0, destination ? destination.owner_name : null)
	if(connected)
		paid = 1
		paidname = account.owner_name
		return connected.handle_invoice_confirm(src, account)
	else
		paid = 1
		paidname = account.owner_name
		message_admins("invoice confirmed without connected machine")
		return
		
/obj/item/device/invoice/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	if(department)
		return // department invoices not paid through cards
	if(istype(W, /obj/item/weapon/card/id))
		if(paid)
			to_chat(user, "The invoice is already paid.")
			return
		if(!authenticated)
			to_chat(user, "The invoice is not authenticated")
			return
		var/obj/item/weapon/card/id/id = W
		var/datum/money_account/account = src.get_card_account(id)
		if(!account)
			to_chat(user, "This card has no account associated with it.")
			return
		confirm(user, account, 1)
	else if(istype(W, /obj/item/device/pda))
		if(paid)
			to_chat(user, "The invoice is already paid.")
			return
		if(!authenticated)
			to_chat(user, "The invoice is not authenticated")
			return
		var/obj/item/device/pda/pda = W
		if(!pda.id)
			to_chat(user, "There is no ID in the PDA.")
			return
		var/obj/item/weapon/card/id/id = pda.id
		var/datum/money_account/account = src.get_card_account(id)
		if(!account)
			to_chat(user, "This card has no account associated with it.")
			return
		confirm(user, account, 1)
	else
		return
		
	

/obj/item/device/invoice/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	var/is_owner
	var/data[0]
	if (created_for)
		is_owner = (user.mind.name == created_for.name)
		data["owner"] = created_for.name
	else
		is_owner = 1
	data["paidname"] = paidname
	data["is_owner"] = is_owner
	data["title"] = title
	data["desc"] = invoice_desc
	data["cost"] = cost
	data["paid"] = paid
	data["department"] = department
	data["departmentname"] = department_name
	if(department)
		if(usr.mind.assigned_job && (usr.mind.assigned_job.department_flag == department || usr.mind.assigned_job.department_flag == COMMAND))
			data["ismember"] = 1
	if(authentication.len)
		data["authenticated"] = authenticated
		data["authreq"] = 1
		var/list/tempauth[0]
		for(var/x in authentication)
			var/datum/cert/job = certs_by_uid[x]
			tempauth.Add(list(list("title" = job.title)))
		data["auther"] = tempauth
		if(user.mind.assigned_job)
			var/authable = 0
			if(!authenticated)
				for(var/x in authentication)
					if (x == user.mind.assigned_job.uid)
						authable = 1
						break
				data["authable"] = authable
	else
		data["authenticated"] = 1
	if(created_for)
		data["owner"] = created_for.name
	// update the ui if it exists, returns null if no ui is passed/found
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "invoice.tmpl", "Invoice", 400, 700, state = inventory_state)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()


/obj/item/device/invoice/attack_self(mob/user)
	ui_interact(user)


// The purchasing code.
/obj/item/device/invoice/Topic(href, href_list)
	if(usr.stat || usr.restrained())
		return 1

	if(!( istype(usr, /mob/living/carbon/human)))
		return 1
	if((usr.contents.Find(src.loc) || (in_range(src.loc, usr) && istype(src.loc.loc, /turf))))
		usr.set_machine(src)
		if(..(href, href_list))
			return 1
		else if(href_list["confirmed"] == "1")
			if(!authenticated && authentication.len)
				return 0
			confirm(usr, usr.mind.initial_account)
			playsound(src, 'sound/machines/synth_yes.ogg', 50, 1)
		else if(href_list["authed"] == "1")
			if(usr.mind.assigned_job.uid in authentication)
				authenticated = 1
				playsound(src, 'sound/machines/chime.ogg', 50, 1)
		else if(href_list["confdept"] == "1")
			if(usr.mind.assigned_job.department_flag == department || usr.mind.assigned_job.department_flag == COMMAND)
				if(usr.mind.allocated > cost || usr.mind.assigned_job.head_position)
					if(confirmdept(usr))
						playsound(src, 'sound/machines/synth_yes.ogg', 50, 1)
				else
					to_chat(usr, "You dont have enough funds allocated to afford that.")
			else
				to_chat(usr, "You are not a part of that department")
	nanomanager.update_uis(src)
	return 1
