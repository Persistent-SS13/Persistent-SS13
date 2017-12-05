proc/sql_report_karma(var/mob/spender, var/mob/receiver)
	var/sqlspendername = sanitizeSQL(spender.name)
	var/sqlspenderkey = spender.key
	var/sqlreceivername = sanitizeSQL(receiver.name)
	var/sqlreceiverkey = receiver.key
	var/sqlreceiverrole = "None"
	var/sqlreceiverspecial = "None"

	var/sqlspenderip = spender.client.address

	if(receiver.mind)
		if(receiver.mind.special_role)
			sqlreceiverspecial = sanitizeSQL(receiver.mind.special_role)
		if(receiver.mind.assigned_role)
			sqlreceiverrole = sanitizeSQL(receiver.mind.assigned_role)

	if(!dbcon.IsConnected())
		log_game("SQL ERROR during karma logging. Failed to connect.")
	else
		var/sqltime = time2text(world.realtime, "YYYY-MM-DD hh:mm:ss")
		var/DBQuery/query = dbcon.NewQuery("INSERT INTO [format_table_name("karma")] (spendername, spenderkey, receivername, receiverkey, receiverrole, receiverspecial, spenderip, time) VALUES ('[sqlspendername]', '[sqlspenderkey]', '[sqlreceivername]', '[sqlreceiverkey]', '[sqlreceiverrole]', '[sqlreceiverspecial]', '[sqlspenderip]', '[sqltime]')")
		if(!query.Execute())
			var/err = query.ErrorMsg()
			log_game("SQL ERROR during karma logging. Error : \[[err]\]\n")


		query = dbcon.NewQuery("SELECT * FROM [format_table_name("karmatotals")] WHERE byondkey='[receiver.key]'")
		query.Execute()

		var/karma
		var/id
		while(query.NextRow())
			id = query.item[1]
			karma = text2num(query.item[3])
		if(karma == null)
			karma = 1
			query = dbcon.NewQuery("INSERT INTO [format_table_name("karmatotals")] (byondkey, karma) VALUES ('[receiver.key]', [karma])")
			if(!query.Execute())
				var/err = query.ErrorMsg()
				log_game("SQL ERROR during karmatotal logging (adding new key). Error : \[[err]\]\n")
		else
			karma += 1
			query = dbcon.NewQuery("UPDATE [format_table_name("karmatotals")] SET karma=[karma] WHERE id=[id]")
			if(!query.Execute())
				var/err = query.ErrorMsg()
				log_game("SQL ERROR during karmatotal logging (updating existing entry). Error : \[[err]\]\n")


var/list/karma_spenders = list()

// Returns 1 if mob can give karma at all; if not, tells them why
/mob/proc/can_give_karma()
	return 0

// Returns 1 if mob can give karma to M; if not, tells them why
/mob/proc/can_give_karma_to_mob(mob/M)
	return 0
	

/mob/verb/spend_karma_list()
	set name = "Award Karma"
	set desc = "Let the gods know whether someone's been nice. Can only be used once per round."
	set category = "Special Verbs"

	return 0

/mob/verb/spend_karma(var/mob/M)
	set name = "Award Karma to Player"
	set desc = "Let the gods know whether someone's been nice. Can only be used once per round."
	set category = "Special Verbs"

	return 0
/client/verb/check_karma()
	set name = "Check Karma"
	set category = "Special Verbs"
	set desc = "Reports how much karma you have accrued."
	return 0

/client/proc/verify_karma()
	var/currentkarma=0
	return 0

/client/verb/karmashop()
	set name = "karmashop"
	set desc = "Spend your hard-earned karma here"
	set hidden = 1
	return

/client/proc/karmashopmenu()
	var/dat = "<html><body><center>"
	dat += "<a href='?src=\ref[src];karmashop=tab;tab=0' [karma_tab == 0 ? "class='linkOn'" : ""]>Job Unlocks</a>"
	dat += "<a href='?src=\ref[src];karmashop=tab;tab=1' [karma_tab == 1 ? "class='linkOn'" : ""]>Species Unlocks</a>"
	dat += "<a href='?src=\ref[src];karmashop=tab;tab=2' [karma_tab == 2 ? "class='linkOn'" : ""]>Karma Refunds</a>"
	dat += "</center>"
	dat += "<HR>"

	switch(karma_tab)
		if(0) // Job Unlocks
			dat += {"
			<a href='?src=\ref[src];karmashop=shop;KarmaBuy=1'>Unlock Barber -- 5KP</a><br>
			<a href='?src=\ref[src];karmashop=shop;KarmaBuy=2'>Unlock Brig Physician -- 5KP</a><br>
			<a href='?src=\ref[src];karmashop=shop;KarmaBuy=3'>Unlock Nanotrasen Representative -- 30KP</a><br>
			<a href='?src=\ref[src];karmashop=shop;KarmaBuy=5'>Unlock Blueshield -- 30KP</a><br>
			<a href='?src=\ref[src];karmashop=shop;KarmaBuy=9'>Unlock Security Pod Pilot -- 30KP</a><br>
			<a href='?src=\ref[src];karmashop=shop;KarmaBuy=6'>Unlock Mechanic -- 30KP</a><br>
			<a href='?src=\ref[src];karmashop=shop;KarmaBuy=7'>Unlock Magistrate -- 45KP</a><br>
			"}

		if(1) // Species Unlocks
			dat += {"
			<a href='?src=\ref[src];karmashop=shop;KarmaBuy2=1'>Unlock Machine People -- 15KP</a><br>
			<a href='?src=\ref[src];karmashop=shop;KarmaBuy2=2'>Unlock Kidan -- 30KP</a><br>
			<a href='?src=\ref[src];karmashop=shop;KarmaBuy2=3'>Unlock Grey -- 30KP</a><br>
			<a href='?src=\ref[src];karmashop=shop;KarmaBuy2=7'>Unlock Drask -- 30KP</a><br>
			<a href='?src=\ref[src];karmashop=shop;KarmaBuy2=4'>Unlock Vox -- 45KP</a><br>
			<a href='?src=\ref[src];karmashop=shop;KarmaBuy2=5'>Unlock Slime People -- 45KP</a><br>
			<a href='?src=\ref[src];karmashop=shop;KarmaBuy2=6'>Unlock Plasmaman -- 100KP</a><br>
			"}

		if(2) // Karma Refunds
			var/list/refundable = list()
			var/list/purchased = checkpurchased()
			if("Tajaran Ambassador" in purchased)
				refundable += "Tajaran Ambassador"
				dat += "<a href='?src=\ref[src];karmashop=shop;KarmaRefund=Tajaran Ambassador;KarmaRefundType=job;KarmaRefundCost=30'>Refund Tajaran Ambassador -- 30KP</a><br>"
			if("Unathi Ambassador" in purchased)
				refundable += "Unathi Ambassador"
				dat += "<a href='?src=\ref[src];karmashop=shop;KarmaRefund=Unathi Ambassador;KarmaRefundType=job;KarmaRefundCost=30'>Refund Unathi Ambassador -- 30KP</a><br>"
			if("Skrell Ambassador" in purchased)
				refundable += "Skrell Ambassador"
				dat += "<a href='?src=\ref[src];karmashop=shop;KarmaRefund=Skrell Ambassador;KarmaRefundType=job;KarmaRefundCost=30'>Refund Skrell Ambassador -- 30KP</a><br>"
			if("Diona Ambassador" in purchased)
				refundable += "Diona Ambassador"
				dat += "<a href='?src=\ref[src];karmashop=shop;KarmaRefund=Diona Ambassador;KarmaRefundType=job;KarmaRefundCost=30'>Refund Diona Ambassador -- 30KP</a><br>"
			if("Kidan Ambassador" in purchased)
				refundable += "Kidan Ambassador"
				dat += "<a href='?src=\ref[src];karmashop=shop;KarmaRefund=Kidan Ambassador;KarmaRefundType=job;KarmaRefundCost=30'>Refund Kidan Ambassador -- 30KP</a><br>"
			if("Slime People Ambassador" in purchased)
				refundable += "Slime People Ambassador"
				dat += "<a href='?src=\ref[src];karmashop=shop;KarmaRefund=Slime People Ambassador;KarmaRefundType=job;KarmaRefundCost=30'>Refund Slime People Ambassador -- 30KP</a><br>"
			if("Grey Ambassador" in purchased)
				refundable += "Grey Ambassador"
				dat += "<a href='?src=\ref[src];karmashop=shop;KarmaRefund=Grey Ambassador;KarmaRefundType=job;KarmaRefundCost=30'>Refund Grey Ambassador -- 30KP</a><br>"
			if("Vox Ambassador" in purchased)
				refundable += "Vox Ambassador"
				dat += "<a href='?src=\ref[src];karmashop=shop;KarmaRefund=Vox Ambassador;KarmaRefundType=job;KarmaRefundCost=30'>Refund Vox Ambassador -- 30KP</a><br>"
			if("Customs Officer" in purchased)
				refundable += "Customs Officer"
				dat += "<a href='?src=\ref[src];karmashop=shop;KarmaRefund=Customs Officer;KarmaRefundType=job;KarmaRefundCost=30'>Refund Customs Officer -- 30KP</a><br>"
			if("Nanotrasen Recruiter" in purchased)
				refundable += "Nanotrasen Recruiter"
				dat += "<a href='?src=\ref[src];karmashop=shop;KarmaRefund=Nanotrasen Recruiter;KarmaRefundType=job;KarmaRefundCost=10'>Refund Nanotrasen Recruiter -- 10KP</a><br>"

			if(!refundable.len)
				dat += "You do not have any refundable karma purchases.<br>"

	dat += "<br><B>PLEASE NOTE THAT PEOPLE WHO TRY TO GAME THE KARMA SYSTEM WILL END UP ON THE WALL OF SHAME. THIS INCLUDES BUT IS NOT LIMITED TO TRADES, OOC KARMA BEGGING, CODE EXPLOITS, ETC.</B>"
	dat += "</center></body></html>"

	var/datum/browser/popup = new(usr, "karmashop", "<div align='center'>Karma Shop</div>", 400, 400)
	popup.set_content(dat)
	popup.open(0)
	return

/client/proc/DB_job_unlock(var/job,var/cost)
	var/DBQuery/query = dbcon.NewQuery("SELECT * FROM [format_table_name("whitelist")] WHERE ckey='[usr.key]'")
	query.Execute()

	var/dbjob
	var/dbckey
	while(query.NextRow())
		dbckey = query.item[2]
		dbjob = query.item[3]
	if(!dbckey)
		query = dbcon.NewQuery("INSERT INTO [format_table_name("whitelist")] (ckey, job) VALUES ('[usr.key]','[job]')")
		if(!query.Execute())
			var/err = query.ErrorMsg()
			log_game("SQL ERROR during whitelist logging (adding new key). Error: \[[err]\]\n")
			message_admins("SQL ERROR during whitelist logging (adding new key). Error: \[[err]\]\n")
			return
		else
			to_chat(usr, "You have unlocked [job].")
			message_admins("[key_name(usr)] has unlocked [job].")
			karmacharge(cost)

	if(dbckey)
		var/list/joblist = splittext(dbjob,",")
		if(!(job in joblist))
			joblist += job
			var/newjoblist = jointext(joblist,",")
			query = dbcon.NewQuery("UPDATE [format_table_name("whitelist")] SET job='[newjoblist]' WHERE ckey='[dbckey]'")
			if(!query.Execute())
				var/err = query.ErrorMsg()
				log_game("SQL ERROR during whitelist logging (updating existing entry). Error : \[[err]\]\n")
				message_admins("SQL ERROR during whitelist logging (updating existing entry). Error : \[[err]\]\n")
				return
			else
				to_chat(usr, "You have unlocked [job].")
				message_admins("[key_name(usr)] has unlocked [job].")
				karmacharge(cost)
		else
			to_chat(usr, "You already have this job unlocked!")
			return

/client/proc/DB_species_unlock(var/species,var/cost)
	var/DBQuery/query = dbcon.NewQuery("SELECT * FROM [format_table_name("whitelist")] WHERE ckey='[usr.key]'")
	query.Execute()

	var/dbspecies
	var/dbckey
	while(query.NextRow())
		dbckey = query.item[2]
		dbspecies = query.item[4]
	if(!dbckey)
		query = dbcon.NewQuery("INSERT INTO [format_table_name("whitelist")] (ckey, species) VALUES ('[usr.key]','[species]')")
		if(!query.Execute())
			var/err = query.ErrorMsg()
			log_game("SQL ERROR during whitelist logging (adding new key). Error : \[[err]\]\n")
			message_admins("SQL ERROR during whitelist logging (adding new key). Error : \[[err]\]\n")
			return
		else
			to_chat(usr, "You have unlocked [species].")
			message_admins("[key_name(usr)] has unlocked [species].")
			karmacharge(cost)

	if(dbckey)
		var/list/specieslist = splittext(dbspecies,",")
		if(!(species in specieslist))
			specieslist += species
			var/newspecieslist = jointext(specieslist,",")
			query = dbcon.NewQuery("UPDATE [format_table_name("whitelist")] SET species='[newspecieslist]' WHERE ckey='[dbckey]'")
			if(!query.Execute())
				var/err = query.ErrorMsg()
				log_game("SQL ERROR during whitelist logging (updating existing entry). Error: \[[err]\]\n")
				message_admins("SQL ERROR during whitelist logging (updating existing entry). Error: \[[err]\]\n")
				return
			else
				to_chat(usr, "You have unlocked [species].")
				message_admins("[key_name(usr)] has unlocked [species].")
				karmacharge(cost)
		else
			to_chat(usr, "You already have this species unlocked!")
			return

/client/proc/karmacharge(var/cost,var/refund = 0)
	var/DBQuery/query = dbcon.NewQuery("SELECT * FROM [format_table_name("karmatotals")] WHERE byondkey='[usr.key]'")
	query.Execute()

	while(query.NextRow())
		var/spent = text2num(query.item[4])
		if(refund)
			spent -= cost
		else
			spent += cost
		query = dbcon.NewQuery("UPDATE [format_table_name("karmatotals")] SET karmaspent=[spent] WHERE byondkey='[usr.key]'")
		if(!query.Execute())
			var/err = query.ErrorMsg()
			log_game("SQL ERROR during karmaspent updating (updating existing entry). Error: \[[err]\]\n")
			message_admins("SQL ERROR during karmaspent updating (updating existing entry). Error: \[[err]\]\n")
			return
		else
			to_chat(usr, "You have been [refund ? "refunded" : "charged"] [cost] karma.")
			message_admins("[key_name(usr)] has been [refund ? "refunded" : "charged"] [cost] karma.")
			return

/client/proc/karmarefund(var/type,var/name,var/cost)
	if(name == "Tajaran Ambassador")
		cost = 30
	else if(name == "Unathi Ambassador")
		cost = 30
	else if(name == "Skrell Ambassador")
		cost = 30
	else if(name == "Diona Ambassador")
		cost = 30
	else if(name == "Kidan Ambassador")
		cost = 30
	else if(name == "Slime People Ambassador")
		cost = 30
	else if(name == "Grey Ambassador")
		cost = 30
	else if(name == "Vox Ambassador")
		cost = 30
	else if(name == "Customs Officer")
		cost = 30
	else if(name == "Nanotrasen Recruiter")
		cost = 10
	else
		to_chat(usr, "\red That job is not refundable.")
		return

	var/DBQuery/query = dbcon.NewQuery("SELECT * FROM [format_table_name("whitelist")] WHERE ckey='[usr.key]'")
	query.Execute()

	var/dbjob
	var/dbspecies
	var/dbckey
	while(query.NextRow())
		dbckey = query.item[2]
		dbjob = query.item[3]
		dbspecies = query.item[4]

	if(dbckey)
		var/list/typelist = list()
		if(type == "job")
			typelist = splittext(dbjob,",")
		else if(type == "species")
			typelist = splittext(dbspecies,",")
		else
			to_chat(usr, "\red Type [type] is not a valid column.")

		if(name in typelist)
			typelist -= name
			var/newtypelist = jointext(typelist,",")
			query = dbcon.NewQuery("UPDATE [format_table_name("whitelist")] SET [type]='[newtypelist]' WHERE ckey='[dbckey]'")
			if(!query.Execute())
				var/err = query.ErrorMsg()
				log_game("SQL ERROR during whitelist logging (updating existing entry). Error: \[[err]\]\n")
				message_admins("SQL ERROR during whitelist logging (updating existing entry). Error: \[[err]\]\n")
				return
			else
				to_chat(usr, "You have been refunded [cost] karma for [type] [name].")
				message_admins("[key_name(usr)] has been refunded [cost] karma for [type] [name].")
				karmacharge(text2num(cost),1)
		else
			to_chat(usr, "\red You have not bought [name].")

	else
		to_chat(usr, "\red Your ckey ([dbckey]) was not found.")

/client/proc/checkpurchased(var/name = null) // If the first parameter is null, return a full list of purchases
	var/DBQuery/query = dbcon.NewQuery("SELECT * FROM [format_table_name("whitelist")] WHERE ckey='[usr.key]'")
	query.Execute()

	var/dbjob
	var/dbspecies
	var/dbckey
	while(query.NextRow())
		dbckey = query.item[2]
		dbjob = query.item[3]
		dbspecies = query.item[4]

	if(dbckey)
		var/list/joblist = splittext(dbjob,",")
		var/list/specieslist = splittext(dbspecies,",")
		var/list/combinedlist = joblist + specieslist
		if(name)
			if(name in combinedlist)
				return 1
			else
				return 0
		else
			return combinedlist
	else
		return 0
