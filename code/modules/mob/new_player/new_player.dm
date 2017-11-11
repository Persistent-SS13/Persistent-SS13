//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

/mob/new_player
	var/ready = 0
	var/spawning = 0//Referenced when you want to delete the new_player later on in the code.
	var/totalPlayers = 0		 //Player counts for the Lobby tab
	var/totalPlayersReady = 0
	universal_speak = 1

	invisibility = 101

	density = 0
	stat = 2
	canmove = 0

	anchored = 1	//  don't get pushed around

/mob/new_player/New()
	mob_list += src

/mob/new_player/verb/new_player_panel()
	set src = usr
	new_player_panel_proc()

						
						
/mob/new_player/proc/CharSelect(mob/user, var/funct)
	var/DBQuery/query = dbcon.NewQuery("SELECT slot,real_name,current_status FROM [format_table_name("characters")] WHERE ckey='[user.ckey]' ORDER BY slot")
//	output += "<p><a href='byond://?src=\ref[src];observe=1'>Observe</A></p>"
	var/dat = "<body>"
	dat += "<tt><center>"
	switch(funct)
		if(1)
			dat += "<b>Select the character to load.</b><hr>"
		if(2)
			dat += "<b>Select the character to delete.</b><hr>"
	var/name
	var/c_status
	for(var/i=1, i<=client.prefs.max_save_slots, i++)
		if(!query.Execute())
			var/err = query.ErrorMsg()
			log_game("SQL ERROR during character slot loading. Error : \[[err]\]\n")
			message_admins("SQL ERROR during character slot loading. Error : \[[err]\]\n")
			return
		while(query.NextRow())
			if(i==text2num(query.item[1]))
				if(query.item[3] == "dead")
					name =  query.item[2] + " (DEAD)"
					c_status = "dead"
				else if(query.item[3] == "lost")
					name =  query.item[2] + " (M.I.A)"
					c_status = "lost"
				else
					name =  query.item[2]

		if(!name)	
			name = "Open Slot"
			dat += "<a href='byond://?src=\ref[src];chooseinvalid=1;funct=[funct]'>[name]</a><br>"
		else if(funct == 2)
			dat += "<a href='byond://?src=\ref[src];choosecharacter=1;num=[i];funct=[funct]'>[name]</a><br>"
		else if(c_status == "dead")
			dat += "<a href='byond://?src=\ref[src];changeslotdead=1;num=[i];funct=[funct]'>[name]</a><br>"
		else if(c_status == "lost")
			dat += "<a href='byond://?src=\ref[src];changeslotlost=1;num=[i];funct=[funct]'>[name]</a><br>"		
		else 
			dat += "<a href='byond://?src=\ref[src];choosecharacter=1;num=[i];funct=[funct]'>[name]</a><br>"			
		name = null
		c_status = null
	dat += "<hr>"
	dat += "<a href='byond://?src=\ref[src];closechar=1'>Close</a><br>"
	dat += "</center></tt>"
//		user << browse(dat, "window=saves;size=300x390")
	var/datum/browser/popup = new(user, "saves", "<div align='center'>Character Saves</div>", 300, 390)
	popup.set_content(dat)
	popup.open(0)
	
/mob/new_player/proc/CharSelectNew(mob/user, var/funct)
	var/dat = "<body>"
	dat += "<tt><center>"
	switch(funct)
		if(1)
			dat += "<b>Select the character to load.</b><hr>"
		if(2)
			dat += "<b>Select the character to delete.</b><hr>"
		if(3)
			dat += "<b>Select the character to load.</b><hr>"
	var/name = ""
	var/c_status = ""
	var/image/ico
	var/energy_cred = 0
	dat += "<table width='100%'>"
	if (!client || !client.prefs)
		return
	if(!client.prefs.preview_icons || !client.prefs.preview_icons.len || !client.prefs.minds_list || !client.prefs.minds_list.len)
		client.prefs.create_spawnicons(client)	
	for(var/i=1, i<=client.prefs.max_save_slots, i++)
		ico = client.prefs.preview_icons[i]
		var/datum/mind/tempmind = client.prefs.minds_list[i]
		if(tempmind)
			name = tempmind.current.real_name
			if(tempmind.initial_account)
				energy_cred = tempmind.initial_account.money
			if(ico)
				user << browse_rsc(ico, "selecticon[i].png")
			else
				message_admins("DEBUG THIS! No spawnicon found for [client.ckey] slot: [i]")
		
		dat += "<tr>"
		dat += "<td>"
		dat += "<center>"
		var/heightt = 128
		var/widthh = 128
		if(!name)	
			name = "Open Slot"
			dat += "<a href='byond://?src=\ref[src];chooseinvalid=1;funct=[funct]'>[name]</a><br>"
		else if(funct == 2)
			dat += "<a href='byond://?src=\ref[src];choosecharacter=1;num=[i];funct=[funct]'>[name]</a><br>"
			dat += "<img src=selecticon[i].png height=[heightt] width=[widthh]><br>"
			dat += "<font color='green'><b>ENERGY CREDS: [energy_cred]</b></font><br>"
		else if(c_status == "dead")
			dat += "<a href='byond://?src=\ref[src];changeslotdead=1;num=[i];funct=[funct]'>[name]</a><br>"
			dat += "<img src=selecticon[i].png height=[heightt] width=[widthh]><br>"
			dat += "<font color='green'><b>ENERGY CREDS: [energy_cred]</b></font><br>"
		else if(c_status == "lost")
			dat += "<a href='byond://?src=\ref[src];changeslotlost=1;num=[i];funct=[funct]'>[name]</a><br>"	
			dat += "<img src=selecticon[i].png height=[heightt] width=[widthh]><br>"			
			dat += "<font color='green'><b>ENERGY CREDS: [energy_cred]</b></font><br>"
		else 
			dat += "<a href='byond://?src=\ref[src];choosecharacter=1;num=[i];funct=[funct]'>[name]</a><br>"	
			dat += "<img src=selecticon[i].png height=[heightt] width=[widthh]><br>"	
			dat += "<font color='green'><b>ENERGY CREDS: [energy_cred]</b></font><br>"
		dat += "<hr>"
		name = null
		c_status = null
		energy_cred = null
		dat += "</center>"
		dat += "</td>"
		dat += "</tr>"
			
	dat += "</table>"		
	dat += "<hr>"
	dat += "<a href='byond://?src=\ref[src];closechar=1'>Close</a><br>"
	dat += "</center></tt>"
	//		user << browse(dat, "window=saves;size=300x390")
	var/datum/browser/popup = new(user, "saves", "<div align='center'>Character Saves</div>", 300, 700)
	popup.set_content(dat)
	popup.open(0)
		

	
	
	
/mob/new_player/proc/new_player_panel_proc()
	var/output = "<center><p><a href='byond://?src=\ref[src];create_character=1'>Create New Character</A><br /></p>" //<i>[real_name]</i>

	if(!ticker || ticker.current_state <= GAME_STATE_PREGAME)
		if(!ready)	output += "<p><a href='byond://?src=\ref[src];readychoose=1'>Declare Ready</A></p>"
		else	output += "<p><b>You are ready</b> (<a href='byond://?src=\ref[src];readychoose=1'>Cancel</A>)</p>"

	else
		output += "<p><a href='byond://?src=\ref[src];manifest=1'>View the Crew Manifest</A></p>"
		output += "<p><a href='byond://?src=\ref[src];late_join=1'>Join Game!</A></p>"
	output += "<p><a href='byond://?src=\ref[src];delete=1'>Delete a Character</A></p>"
	output += "<p><a href='byond://?src=\ref[src];observe=1'>Observe</A></p>"

	if(!IsGuestKey(src.key))
		establish_db_connection()

		if(dbcon.IsConnected())
			var/isadmin = 0
			if(src.client && src.client.holder)
				isadmin = 1
			var/DBQuery/query = dbcon.NewQuery("SELECT id FROM [format_table_name("poll_question")] WHERE [(isadmin ? "" : "adminonly = false AND")] Now() BETWEEN starttime AND endtime AND id NOT IN (SELECT pollid FROM [format_table_name("poll_vote")] WHERE ckey = \"[ckey]\") AND id NOT IN (SELECT pollid FROM [format_table_name("poll_textreply")] WHERE ckey = \"[ckey]\")")
			query.Execute()
			var/newpoll = 0
			while(query.NextRow())
				newpoll = 1
				break

			if(newpoll)
				output += "<p><b><a href='byond://?src=\ref[src];showpoll=1'>Show Player Polls</A> (NEW!)</b></p>"
			else
				output += "<p><a href='byond://?src=\ref[src];showpoll=1'>Show Player Polls</A></p>"

	output += "</center>"

	var/datum/browser/popup = new(src, "playersetup", "<div align='center'>New Player Options</div>", 220, 290)
	popup.set_window_options("can_close=0")
	popup.set_content(output)
	popup.open(0)
	return

	
	
	
	
/mob/new_player/Stat()
	if((!ticker) || ticker.current_state == GAME_STATE_PREGAME)
		statpanel("Lobby") // First tab during pre-game.
	..()

	statpanel("Status")
	if(client.statpanel == "Status" && ticker)
		if(ticker.current_state != GAME_STATE_PREGAME)
			stat(null, "Station Time: [worldtime2text()]")
	statpanel("Lobby")
	if(client.statpanel=="Lobby" && ticker)
		if(ticker.hide_mode)
			stat("Game Mode:", "Secret")
		else
			if(ticker.hide_mode == 0)
				stat("Game Mode:", "[master_mode]") // Old setting for showing the game mode
			else
				stat("Game Mode: ", "Secret")

		if((ticker.current_state == GAME_STATE_PREGAME) && going)
			stat("Time To Start:", ticker.pregame_timeleft)
		if((ticker.current_state == GAME_STATE_PREGAME) && !going)
			stat("Time To Start:", "DELAYED")

		if(ticker.current_state == GAME_STATE_PREGAME)
			stat("Players:", "[totalPlayers]")
			if(check_rights(R_ADMIN, 0, src))
				stat("Players Ready:", "[totalPlayersReady]")
			totalPlayers = 0
			totalPlayersReady = 0
			for(var/mob/new_player/player in player_list)
				if(check_rights(R_ADMIN, 0, src))
					stat("[player.key]", (player.ready)?("(Playing)"):(null))
				totalPlayers++
				if(player.ready)
					totalPlayersReady++

/mob/new_player/Topic(href, href_list[])

	if(href_list["choice"])
		client.prefs.Topic(href, href_list)
		return 0
	if(href_list["choice_slot"])
		client.prefs.Topic(href, href_list)
		return 0
	var/func = 0
	if(!client)	return 0

	if(href_list["show_preferences"])
		client.prefs.ShowChoices(src)
		return 1

	if(href_list["create_character"])
		if(!client.prefs.preview_model)
			client.prefs.species = "Human"
			client.prefs.organ_data = list()
			client.prefs.rlimb_data = list()
			client.prefs.primary_cert = "intern"
			client.prefs.certs = null
			client.prefs.cert_title = null
			client.prefs.current_status = ""
			client.prefs.reset_inventory()		//let's create a random character then - rather than a fat, bald and naked man.
			client.prefs.real_name = random_name(client.prefs.gender,client.prefs.species)
		client.prefs.CharacterCreateProc(src)
		return 1
	if(href_list["closechar"])		
		close_load_dialog(src)	
	
	if(href_list["chooseinvalid"])
		func = text2num(href_list["funct"])
		switch(func)
			if(1)
				to_chat(src, "<span class='userdanger'>Character slot empty! Create character before proceeding.</span>")
			if(2)		
				to_chat(src, "<span class='userdanger'>Character slot empty! Create character before proceeding.</span>")		

	if(href_list["changeslotdead"])
		to_chat(src, "<span class='userdanger'>Character dead! Secure cloning or select a different character.</span>")
		
	if(href_list["changeslotlost"])
		to_chat(src, "<span class='userdanger'>Character is M.I.A! Recovery unlikely, select a different character.</span>")
								
	if(href_list["choosecharacter"])
		if(client.prefs.preview_model)
			client.prefs.preview_model.deleting = 1
			qdel(client.prefs.preview_model)
			client.prefs.preview_model = null
		func = text2num(href_list["funct"])
		switch(func)
			if(1)// load char
				client.prefs.slot = text2num(href_list["num"])
				ready = 1				
				close_load_dialog(src)
				new_player_panel_proc()
			if(2) // delete char
				client.prefs.slot = text2num(href_list["num"]) 
				client.prefs.delete_mind(client)
				new_player_panel_proc()
			if(3)// load char late
				client.prefs.slot = text2num(href_list["num"])
				AttemptLateSpawnPersistant(client.prefs.primary_cert)			
				close_load_dialog(src)
				
			//	var/DBQuery/query = dbcon.NewQuery({"UPDATE [format_table_name("characters")] SET OOC_Notes='[sql_sanitize_text(metadata)]',
				
				
	if(href_list["ready"])
		ready = !ready
		new_player_panel_proc()
		
	if(href_list["readychoose"])
		if(client.prefs.preview_model)
			client.prefs.preview_model.deleting = 1
			qdel(client.prefs.preview_model)
			client.prefs.preview_model = null
		if (!ready)
			CharSelectNew(src, 1)
			return 1
		else
			ready = !ready
			new_player_panel_proc()
		
	if(href_list["delete"])
		if(client.prefs.preview_model)
			client.prefs.preview_model.deleting = 1
			qdel(client.prefs.preview_model)
			client.prefs.preview_model = null
		CharSelectNew(src, 2)
		return 1


	if(href_list["refresh"])
		src << browse(null, "window=playersetup") //closes the player setup window
		new_player_panel_proc()

	if(href_list["observe"])
		/**
		if(alert(src,"Are you sure you wish to observe? You cannot normally join the round after doing this!","Player Setup","Yes","No") == "Yes")
			if(!client)	return 1
			var/mob/dead/observer/observer = new()
			src << browse(null, "window=playersetup")
			spawning = 1
			src << sound(null, repeat = 0, wait = 0, volume = 85, channel = 1)// MAD JAMS cant last forever yo


			observer.started_as_observer = 1
			close_spawn_windows()
			var/obj/O = locate("landmark*Observer-Start")
			to_chat(src, "\blue Now teleporting.")
			observer.loc = O.loc
			observer.timeofdeath = world.time // Set the time of death so that the respawn timer works correctly.
			client.prefs.update_preview_icon_new()
			observer.icon = client.prefs.preview_icon_front
			observer.alpha = 127

			if(client.prefs.be_random_name)
				client.prefs.real_name = random_name(client.prefs.gender,client.prefs.species)
			observer.real_name = client.prefs.real_name
			observer.name = observer.real_name
			if(!client.holder && !config.antag_hud_allowed)           // For new ghosts we remove the verb from even showing up if it's not allowed.
				observer.verbs -= /mob/dead/observer/verb/toggle_antagHUD        // Poor guys, don't know what they are missing!
			observer.key = key
			respawnable_list += observer
			qdel(src)
			return 1
		**/
	if(href_list["late_join"])
		if(client.prefs.preview_model)
			client.prefs.preview_model.deleting = 1
			qdel(client.prefs.preview_model)
			client.prefs.preview_model = null
		if(!ticker || ticker.current_state != GAME_STATE_PLAYING)
			to_chat(usr, "\red The round is either not ready, or has already finished...")
			return

		CharSelectNew(src, 3)

	if(href_list["manifest"])
		ViewManifest()

	if(href_list["SelectedJob"])

		if(!enter_allowed)
			to_chat(usr, "\blue There is an administrative lock on entering the game!")
			return

		if(client.prefs.species in whitelisted_species)
			if(!is_alien_whitelisted(src, client.prefs.species) && config.usealienwhitelist)
				to_chat(src, alert("You are currently not whitelisted to play [client.prefs.species]."))
				return 0

		AttemptLateSpawn(href_list["SelectedJob"],client.prefs.spawnpoint)
		return

	if(!ready && href_list["preference"])
		if(client)
			client.prefs.process_link(src, href_list)
	else if(!href_list["late_join"])
		new_player_panel()

	if(href_list["showpoll"])

		handle_player_polling()
		return

	if(href_list["pollid"])

		var/pollid = href_list["pollid"]
		if(istext(pollid))
			pollid = text2num(pollid)
		if(isnum(pollid))
			src.poll_player(pollid)
		return

	if(href_list["votepollid"] && href_list["votetype"])
		var/pollid = text2num(href_list["votepollid"])
		var/votetype = href_list["votetype"]
		switch(votetype)
			if("OPTION")
				var/optionid = text2num(href_list["voteoptionid"])
				vote_on_poll(pollid, optionid)
			if("TEXT")
				var/replytext = href_list["replytext"]
				log_text_poll_reply(pollid, replytext)
			if("NUMVAL")
				var/id_min = text2num(href_list["minid"])
				var/id_max = text2num(href_list["maxid"])

				if( (id_max - id_min) > 100 )	//Basic exploit prevention
					to_chat(usr, "The option ID difference is too big. Please contact administration or the database admin.")
					return

				for(var/optionid = id_min; optionid <= id_max; optionid++)
					if(!isnull(href_list["o[optionid]"]))	//Test if this optionid was replied to
						var/rating
						if(href_list["o[optionid]"] == "abstain")
							rating = null
						else
							rating = text2num(href_list["o[optionid]"])
							if(!isnum(rating))
								return

						vote_on_numval_poll(pollid, optionid, rating)
			if("MULTICHOICE")
				var/id_min = text2num(href_list["minoptionid"])
				var/id_max = text2num(href_list["maxoptionid"])

				if( (id_max - id_min) > 100 )	//Basic exploit prevention
					to_chat(usr, "The option ID difference is too big. Please contact administration or the database admin.")
					return

				for(var/optionid = id_min; optionid <= id_max; optionid++)
					if(!isnull(href_list["option_[optionid]"]))	//Test if this optionid was selected
						vote_on_poll(pollid, optionid, 1)

	
	
/mob/new_player/proc/IsJobAvailable(rank)
	var/datum/job/job = job_master.GetJob(rank)
	if(!job)	return 0
	if(!job.is_position_available()) return 0
	if(jobban_isbanned(src,rank))	return 0
	if(!is_job_whitelisted(src, rank))	 return 0
	if(!job.player_old_enough(src.client))	return 0
	if(job.admin_only && !(check_rights(R_ADMIN, 0))) return 0

	if(config.assistantlimit)
		if(job.title == "Civilian")
			var/count = 0
			var/datum/job/officer = job_master.GetJob("Security Officer")
			var/datum/job/warden = job_master.GetJob("Warden")
			var/datum/job/hos = job_master.GetJob("Head of Security")
			count += (officer.current_positions + warden.current_positions + hos.current_positions)
			if(job.current_positions > (config.assistantratio * count))
				if(count >= 5) // if theres more than 5 security on the station just let assistants join regardless, they should be able to handle the tide
					return 1
				return 0
	return 1

/mob/new_player/proc/IsAdminJob(rank)
	var/datum/cert/job = job_master.GetCert(rank)
	if(job.admin_only)
		return 1
	else
		return 0

/mob/new_player/proc/IsERTSpawnJob(rank)
	var/datum/job/job = job_master.GetJob(rank)
	if(job.spawn_ert)
		return 1
	else
		return 0

/mob/new_player/proc/AttemptLateSpawn(rank,var/spawning_at)
	if(src != usr)
		return 0
	if(!ticker || ticker.current_state != GAME_STATE_PLAYING)
		to_chat(usr, "\red The round is either not ready, or has already finished...")
		return 0
	if(!enter_allowed)
		to_chat(usr, "\blue There is an administrative lock on entering the game!")
		return 0
	if(!IsJobAvailable(rank))
		to_chat(src, alert("[rank] is not available. Please try another."))
		return 0

	job_master.AssignRole(src, rank, 1)

	var/character = create_character()	//creates the human and transfers vars and mind
	var/mob/living/mobbie
	var/obj/objie
	if(istype(character, /mob/living))
		mobbie = character
	else if(istype(character, /obj))
		objie = character
		for(var/mob/M in objie.contents)
			mobbie = M
			break

//	character = job_master.EquipRank(character, rank, 1)					//equips the human
//	EquipCustomItems(character)

	// AIs don't need a spawnpoint, they must spawn at an empty core
//	if(character.mind.assigned_role == "AI")

//		character = character.AIize(move=0) // AIize the character, but don't move them yet

		// IsJobAvailable for AI checks that there is an empty core available in this list
//		var/obj/structure/AIcore/deactivated/C = empty_playable_ai_cores[1]
//		empty_playable_ai_cores -= C

//		character.loc = C.loc

//		AnnounceCyborg(character, rank, "has been downloaded to the empty core in \the [get_area(character)]")
//		ticker.mode.latespawn(character)

//		qdel(C)
//		qdel(src)
//		return

	//Find our spawning point.
	var/join_message
	var/datum/spawnpoint/S
	
	if(objie)
		if(IsAdminJob(rank))
			if(IsERTSpawnJob(rank))
				objie.loc = pick(ertdirector)
			else
				objie.loc = pick(aroomwarp)
			join_message = "has arrived"
		else
			if(spawning_at)
				S = spawntypes[spawning_at]
			if(S && istype(S))
				if(S.check_job_spawning(rank))
					objie.loc = pick(S.turfs)
					join_message = S.msg
				else
					to_chat(objie, "Your chosen spawnpoint ([S.display_name]) is unavailable for your chosen job. Spawning you at the Arrivals shuttle instead.")
					objie.loc = pick(latejoin)
					join_message = "has arrived on the station"
			else
				objie.loc = pick(latejoin)
				join_message = "has arrived on the station"
	else if(mobbie)
		if(IsAdminJob(rank))
			if(IsERTSpawnJob(rank))
				mobbie.loc = pick(ertdirector)
			else
				mobbie.loc = pick(aroomwarp)
			join_message = "has arrived"
		else
			if(spawning_at)
				S = spawntypes[spawning_at]
			if(S && istype(S))
				if(S.check_job_spawning(rank))
					mobbie.loc = pick(S.turfs)
					join_message = S.msg
				else
					to_chat(mobbie, "Your chosen spawnpoint ([S.display_name]) is unavailable for your chosen job. Spawning you at the Arrivals shuttle instead.")
					mobbie.loc = pick(latejoin)
					join_message = "has arrived on the station"
			else
				mobbie.loc = pick(latejoin)
				join_message = "has arrived on the station"
				
//	character.lastarea = get_area(loc)
	// Moving wheelchair if they have one
//	if(character.buckled && istype(character.buckled, /obj/structure/stool/bed/chair/wheelchair))
//		character.buckled.loc = character.loc
//		character.buckled.dir = character.dir

//	ticker.mode.latespawn(character)
	if(istype(character, /mob/living))
		data_core.manifest_inject(character)
		AnnounceArrival(character, rank, join_message)
		
//	ticker.minds += character.mind//Cyborgs and AIs handle this in the transform proc.	//TODO!!!!! ~Carn
	
//	callHook("latespawn", list(character))


	qdel(src)

	
/mob/new_player/proc/AttemptLateSpawnPersistant(rank,var/spawning_at)
	spawn(5)
		if(src != usr)
			return 0
		if(!ticker || ticker.current_state != GAME_STATE_PLAYING)
			to_chat(usr, "\red The round is either not ready, or has already finished...")
			return 0
		if(!enter_allowed)
			to_chat(usr, "\blue There is an administrative lock on entering the game!")
			return 0
		ticker.show_info(src)
		//	job_master.AssignPersistantRole(src, rank, 1)
		spawn(0)
			var/character = create_character()	//creates the human and transfers vars and mind
			var/mob/living/mobbie
			var/obj/objie
			if(istype(character, /mob/living))
				mobbie = character
			else if(istype(character, /obj))
				objie = character
				for(var/mob/living/M in objie.contents)
					if(M.mind)
						mobbie = M
						break	
			//Find our spawning point.
			var/join_message
			var/datum/spawnpoint/S
			if(objie)
				objie.loc = pick(latejoin)
				join_message = "has arrived on the station"
			else if(mobbie)
				mobbie.loc = pick(latejoin)
				join_message = "has arrived on the station"
			if(mobbie && mobbie.mind && !mobbie.mind.primary_cert)
				message_admins("NO PRIMARY CERT AFTER LOADING!!")
				mobbie.mind.primary_cert = job_master.GetCert("intern")
			if(mobbie && mobbie.mind && mobbie.mind.primary_cert)
				rank = mobbie.mind.primary_cert.uid
				job_master.EquipRankPersistant(mobbie, rank, 1)
				data_core.manifest_inject(mobbie)
				ticker.minds += mobbie.mind//Cyborgs and AIs handle this in the transform proc.	//TODO!!!!! ~Carn
				AnnounceArrival(mobbie, rank, join_message)
				callHook("latespawn", list(mobbie))
			qdel(src)

	
	
	
	

/mob/new_player/proc/AnnounceArrival(var/mob/living/carbon/human/character, var/rank, var/join_message)
	if(ticker.current_state == GAME_STATE_PLAYING)
		var/ailist[] = list()
		for(var/mob/living/silicon/ai/A in living_mob_list)
			ailist += A
		if(ailist.len)
			var/mob/living/silicon/ai/announcer = pick(ailist)
			if(character.mind)
				if((character.mind.assigned_role != "Cyborg") && (character.mind.special_role != "MODE"))
					if(character.mind.role_alt_title)
						rank = character.mind.role_alt_title
					var/arrivalmessage = announcer.arrivalmsg
					arrivalmessage = replacetext(arrivalmessage,"$name",character.real_name)
					arrivalmessage = replacetext(arrivalmessage,"$rank",rank ? "[rank]" : "visitor")
					arrivalmessage = replacetext(arrivalmessage,"$species",character.species.name)
					arrivalmessage = replacetext(arrivalmessage,"$age",num2text(character.age))
					arrivalmessage = replacetext(arrivalmessage,"$gender",character.gender == FEMALE ? "Female" : "Male")
					announcer.say(";[arrivalmessage]")
		else
			if(character.mind)
				if((character.mind.assigned_role != "Cyborg") && (character.mind.special_role != "MODE"))
					if(character.mind.role_alt_title)
						rank = character.mind.role_alt_title
					global_announcer.autosay("[character.real_name],[rank ? " [rank]," : " visitor," ] [join_message ? join_message : "has arrived on the station"].", "Arrivals Announcement Computer")

/mob/new_player/proc/AnnounceCyborg(var/mob/living/character, var/rank, var/join_message)
	if(ticker.current_state == GAME_STATE_PLAYING)
		var/ailist[] = list()
		for(var/mob/living/silicon/ai/A in living_mob_list)
			ailist += A
		if(ailist.len)
			var/mob/living/silicon/ai/announcer = pick(ailist)
			if(character.mind)
				if((character.mind.special_role != "MODE"))
					var/arrivalmessage = "A new[rank ? " [rank]" : " visitor" ] [join_message ? join_message : "has arrived on the station"]."
					announcer.say(";[arrivalmessage]")
		else
			if(character.mind)
				if((character.mind.special_role != "MODE"))
					// can't use their name here, since cyborg namepicking is done post-spawn, so we'll just say "A new Cyborg has arrived"/"A new Android has arrived"/etc.
					global_announcer.autosay("A new[rank ? " [rank]" : " visitor" ] [join_message ? join_message : "has arrived on the station"].", "Arrivals Announcement Computer")

/mob/new_player/proc/LateChoices()
	var/mills = world.time // 1/10 of a second, not real milliseconds but whatever
	//var/secs = ((mills % 36000) % 600) / 10 //Not really needed, but I'll leave it here for refrence.. or something
	var/mins = (mills % 36000) / 600
	var/hours = mills / 36000

	var/dat = "<html><body><center>"
	dat += "Round Duration: [round(hours)]h [round(mins)]m<br>"

	if(shuttle_master.emergency.mode >= SHUTTLE_ESCAPE)
		dat += "<font color='red'><b>The station has been evacuated.</b></font><br>"
	else if(shuttle_master.emergency.mode >= SHUTTLE_CALL)
		dat += "<font color='red'>The station is currently undergoing evacuation procedures.</font><br>"

	dat += "Choose from the following open positions:<br><br>"

	var/list/activePlayers = list()
	var/list/categorizedJobs = list(
		"Command" = list(jobs = list(), titles = command_positions, color = "#aac1ee"),
		"Engineering" = list(jobs = list(), titles = engineering_positions, color = "#ffd699"),
		"Security" = list(jobs = list(), titles = security_positions, color = "#ff9999"),
		"Miscellaneous" = list(jobs = list(), titles = list(), color = "#ffffff", colBreak = 1),
		"Synthetic" = list(jobs = list(), titles = nonhuman_positions, color = "#ccffcc"),
		"Support / Service" = list(jobs = list(), titles = service_positions, color = "#cccccc"),
		"Medical" = list(jobs = list(), titles = medical_positions, color = "#99ffe6", colBreak = 1),
		"Science" = list(jobs = list(), titles = science_positions, color = "#e6b3e6"),
		"Supply" = list(jobs = list(), titles = supply_positions, color = "#ead4ae"),
		)
	for(var/datum/job/job in job_master.occupations)
		if(job && IsJobAvailable(job.title))
			activePlayers[job] = 0
			var/categorized = 0
			// Only players with the job assigned and AFK for less than 10 minutes count as active
			for(var/mob/M in player_list) if(M.mind && M.client && M.mind.assigned_role == job.title && M.client.inactivity <= 10 MINUTES)
				activePlayers[job]++
			for(var/jobcat in categorizedJobs)
				var/list/jobs = categorizedJobs[jobcat]["jobs"]
				if(job.title in categorizedJobs[jobcat]["titles"])
					categorized = 1
					if(jobcat == "Command") // Put captain at top of command jobs
						if(job.title == "Captain")
							jobs.Insert(1, job)
						else
							jobs += job
					else // Put heads at top of non-command jobs
						if(job.title in command_positions)
							jobs.Insert(1, job)
						else
							jobs += job
			if(!categorized)
				categorizedJobs["Miscellaneous"]["jobs"] += job

	dat += "<table><tr><td valign='top'>"
	for(var/jobcat in categorizedJobs)
		if(categorizedJobs[jobcat]["colBreak"])
			dat += "</td><td valign='top'>"
		if(length(categorizedJobs[jobcat]["jobs"]) < 1)
			continue
		var/color = categorizedJobs[jobcat]["color"]
		dat += "<fieldset style='border: 2px solid [color]; display: inline'>"
		dat += "<legend align='center' style='color: [color]'>[jobcat]</legend>"
		for(var/datum/job/job in categorizedJobs[jobcat]["jobs"])
			dat += "<a href='byond://?src=\ref[src];SelectedJob=[job.title]'>[job.title] ([job.current_positions]) (Active: [activePlayers[job]])</a><br>"
		dat += "</fieldset><br>"

	dat += "</td></tr></table></center>"
	// Removing the old window method but leaving it here for reference
//		src << browse(dat, "window=latechoices;size=300x640;can_close=1")
	// Added the new browser window method
	var/datum/browser/popup = new(src, "latechoices", "Choose Profession", 900, 600)
	popup.add_stylesheet("playeroptions", 'html/browser/playeroptions.css')
	popup.add_script("delay_interactivity", 'html/browser/delay_interactivity.js')
	popup.set_content(dat)
	popup.open(0) // 0 is passed to open so that it doesn't use the onclose() proc

/mob/new_player/proc/create_character()
	spawning = 1
	close_spawn_windows()

	check_prefs_are_sane()
	
	message_admins("create_character ran!")
//	if(ticker.random_players)
	//	client.prefs.random_character()
	//	client.prefs.real_name = random_name(client.prefs.gender)

	src << sound(null, repeat = 0, wait = 0, volume = 85, channel = 1)// MAD JAMS cant last forever yo

	
	if(mind)
		mind.active = 1
		mind.current = src
		mind.key = key
		var/atom/movable/H = map_storage.Load_Char(ckey, client.prefs.slot, mind, 1)
		return H
	else
		mind = new()
		mind.active = 1
		mind.current = src
		mind.key = key
		var/atom/movable/H = map_storage.Load_Char(ckey, client.prefs.slot, mind, 1)
		return H
	message_admins("create_character FAILED!!")
	return 0
	
// This is to check that the player only has preferences set that they're supposed to
/mob/new_player/proc/check_prefs_are_sane()
	var/datum/species/chosen_species
	if(client.prefs.species)
		chosen_species = all_species[client.prefs.species]
	if(!(chosen_species && (is_species_whitelisted(chosen_species) || has_admin_rights())))
		// Have to recheck admin due to no usr at roundstart. Latejoins are fine though.
		log_debug("[src] had species [client.prefs.species], though they weren't supposed to. Setting to Human.")
		client.prefs.species = "Human"

	var/datum/language/chosen_language
	if(client.prefs.language)
		chosen_language = all_languages[client.prefs.language]
	if((chosen_language == null && client.prefs.language != "None") || (chosen_language && chosen_language.flags & RESTRICTED))
		log_debug("[src] had language [client.prefs.language], though they weren't supposed to. Setting to None.")
		client.prefs.language = "None"

/mob/new_player/proc/ViewManifest()
	var/dat = "<html><body>"
	dat += "<h4>Crew Manifest</h4>"
	dat += data_core.get_manifest(OOC = 1)

	src << browse(dat, "window=manifest;size=370x420;can_close=1")

/mob/new_player/Move()
	return 0


/mob/new_player/proc/close_spawn_windows()
	src << browse(null, "window=latechoices") //closes late choices window
	src << browse(null, "window=playersetup") //closes the player setup window
	src << browse(null, "window=preferences") //closes job selection
	src << browse(null, "window=mob_occupation")
	src << browse(null, "window=latechoices") //closes late job selection


/mob/new_player/proc/has_admin_rights()
	return check_rights(R_ADMIN, 0, src)

/mob/new_player/proc/is_species_whitelisted(datum/species/S)
	if(!S) return 1
	return is_alien_whitelisted(src, S.name) || !config.usealienwhitelist || !(S.flags & IS_WHITELISTED)

/mob/new_player/get_species()
	var/datum/species/chosen_species
	if(client.prefs.species)
		chosen_species = all_species[client.prefs.species]

	if(!chosen_species)
		return "Human"

	if(is_species_whitelisted(chosen_species) || has_admin_rights())
		return chosen_species.name

	return "Human"

/mob/new_player/get_gender()
	if(!client || !client.prefs) ..()
	return client.prefs.gender

/mob/new_player/is_ready()
	return ready && ..()

/mob/new_player/proc/close_load_dialog(mob/user)
	user << browse(null, "window=saves")
	