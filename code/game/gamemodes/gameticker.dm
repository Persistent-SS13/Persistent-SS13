var/global/datum/controller/gameticker/ticker
var/round_start_time = 0

/datum/controller/gameticker
	var/const/restart_timeout = 50
	var/current_state = GAME_STATE_PREGAME

	var/hide_mode = 0 // leave here at 0 ! setup() will take care of it when needed for Secret mode -walter0o
	var/datum/game_mode/mode = null
	var/event_time = null
	var/event = 0

	var/login_music // music played in pregame lobby

	var/list/datum/mind/minds = list()//The people in the game. Used for objective tracking.

	var/Bible_icon_state	// icon_state the chaplain has chosen for his bible
	var/Bible_item_state	// item_state the chaplain has chosen for his bible
	var/Bible_name			// name of the bible
	var/Bible_deity_name

	var/random_players = 0 	// if set to nonzero, ALL players who latejoin or declare-ready join will have random appearances/genders

	var/list/syndicate_coalition = list() // list of traitor-compatible factions
	var/list/factions = list()			  // list of all factions
	var/list/availablefactions = list()	  // list of factions with openings

	var/pregame_timeleft = 0

	var/delay_end = 0	//if set to nonzero, the round will not restart on it's own

	var/triai = 0//Global holder for Triumvirate
	var/initialtpass = 0 //holder for inital autotransfer vote timer

	var/obj/screen/cinematic = null			//used for station explosion cinematic

	var/round_end_announced = 0 // Spam Prevention. Announce round end only once.

/datum/controller/gameticker/proc/pregame()
	login_music = pick(\
	'sound/music/THUNDERDOME.ogg',\
	'sound/music/space.ogg',\
	'sound/music/Title1.ogg',\
	'sound/music/Title2.ogg',\
	'sound/music/Title3.ogg',)
	do
		pregame_timeleft = 180
		to_chat(world, "<B><FONT color='blue'>Welcome to the pre-game lobby!</FONT></B>")
		to_chat(world, "Please, setup your character and select ready. Game will start in [pregame_timeleft] seconds")
		while(current_state == GAME_STATE_PREGAME)
			sleep(10)
			if(going)
				pregame_timeleft--

			if(pregame_timeleft <= 0)
				current_state = GAME_STATE_SETTING_UP
	while(!setup())

/datum/controller/gameticker/proc/votetimer()
	var/timerbuffer = 0
	if(initialtpass == 0)
		timerbuffer = config.vote_autotransfer_initial
	else
		timerbuffer = config.vote_autotransfer_interval
	spawn(timerbuffer)
		vote.autotransfer()
		initialtpass = 1
		votetimer()

/datum/controller/gameticker/proc/show_info(mob/recipient)
	var/output = "<B>PERSISTENT SS13<HR></B>"
	output += "This is an alpha version of a space station 13 script that saves the characters AND the station betwen round!.<br><br>"
	output += "The character saving is nearly 100% complete and many of the elements that are needed for multi round ss13 (promotions, basic cash economy) are already in place.<br><br>"
	output += "Now I'm working on redoing all the departments so that they fit better with persistence and especially so they incorperate the new stats and exp system.<br><br>"
	output += "In a future build all the departments will start out very empty with only the most basic supplies and machines to start out and they will gradually develop.<br><br>"
	output += "The first department im reworking is cargo which is why many of cargos features are broken/half finished.<br><br>"
	output += "Im conducting limited public testing now because im intrested in bugtesting, stesstesting and feature feedback on what I have done so far.<br><br>"
	output += "If you had feedback or questions you should contact me either on  <a href='https://discord.gg/CA696Vc'>Discord</a> or <a href='http://steamcommunity.com/id/RawLerb/'>Steam</a>.<br><br>"
	output += "Bugs can be reports by using the adminhelp command (in chat)<br><br>"
	output += "Just by loading a character you are helping me stress test, if you play around with the new features (such as they are), that helps me test.<br><br>"
	output += "People should try customizing both their characters and the station as much as possible..<br><br>"
	output += "Try to have the most unusual department and character when the round ends, "
	output += "and.. please, REPORT ALL BUGS TO THE <a href='https://discord.gg/CA696Vc'>DISCHORD</a>"
	recipient << browse(output,"window=persistinfo;size=550x600")
/datum/controller/gameticker/proc/setup()
	// PERSISTANT EDITS
	setup_department_datums()
	setup_faction_datums()
	setup_cert_datums()
	//
	//Create and announce mode
	if(master_mode=="secret")
		src.hide_mode = 1
	var/list/datum/game_mode/runnable_modes
	if((master_mode=="random") || (master_mode=="secret"))
		runnable_modes = config.get_runnable_modes()
		if(runnable_modes.len==0)
			current_state = GAME_STATE_PREGAME
			to_chat(world, "<B>Unable to choose playable game mode.</B> Reverting to pre-game lobby.")
			return 0
		if(secret_force_mode != "secret")
			var/datum/game_mode/M = config.pick_mode(secret_force_mode)
			if(M.can_start())
				src.mode = config.pick_mode(secret_force_mode)
		job_master.ResetOccupations()
		if(!src.mode)
			src.mode = pickweight(runnable_modes)
		if(src.mode)
			var/mtype = src.mode.type
			src.mode = new mtype
	else
		src.mode = config.pick_mode(master_mode)
	if(!src.mode.can_start())
		to_chat(world, "<B>Unable to start [mode.name].</B> Not enough players, [mode.required_players] players needed. Reverting to pre-game lobby.")
		mode = null
		current_state = GAME_STATE_PREGAME
		job_master.ResetOccupations()
		return 0

	//Configure mode and assign player to special mode stuff
	src.mode.pre_pre_setup()
	var/can_continue
	can_continue = src.mode.pre_setup()//Setup special modes
	job_master.DividePersistant() //Distribute jobs
	// 	job_master.DivideOccupations() //Distribute jobs
	
	
	if(!can_continue)
		qdel(mode)
		current_state = GAME_STATE_PREGAME
		to_chat(world, "<B>Error setting up [master_mode].</B> Reverting to pre-game lobby.")
		job_master.ResetOccupations()
		return 0

	if(hide_mode)
		var/list/modes = new
		for(var/datum/game_mode/M in runnable_modes)
			modes+=M.name
		modes = sortList(modes)
		to_chat(world, "<B>The current game mode is - Secret!</B>")
		to_chat(world, "<B>Possibilities:</B> [english_list(modes)]")
	else
		src.mode.announce()
	spawn(0)
		create_characters() //Create player characters and transfer them
		collect_minds()
		equip_characters_persistant()
		setup_faction_members()
		
		data_core.manifest()
		current_state = GAME_STATE_PLAYING

		callHook("roundstart")

	//here to initialize the random events nicely at round start
	setup_economy()

	//shuttle_controller.setup_shuttle_docks()
	spawn(0)//Forking here so we dont have to wait for this to finish
		mineController = new()
		mode.post_setup()
		//Cleanup some stuff
		for(var/obj/effect/landmark/start/S in landmarks_list)
			//Deleting Startpoints but we need the ai point to AI-ize people later
			if(S.name != "AI")
				qdel(S)
		var/tantilineamount = round((tantilinelocs.len/1.5))
		var/congloamount = round((conglolocs.len/1.5))
		var/plasmaamount = round((plasmalocs.len/1.5))
		var/orichilumamount = round((orichilumlocs.len/1.5))
		var/list/grabbag = list()
		if(orichilumlocs && orichilumlocs.len > 2)
			grabbag += pick_n_take(orichilumlocs)
			grabbag += pick_n_take(orichilumlocs)
			grabbag += pick_n_take(orichilumlocs)
		if(grabbag.len)
			for(var/i=1,i<=3,i++)
				var/turf/Te = pick_n_take(grabbag)
				var/turf/simulated/floor/plating/airless/asteroid/cave/caveturf = new(Te)
			for(var/i=1,i<=tantilineamount,i++)
				var/turf/Te = pick_n_take(tantilinelocs)
				var/ores = 1
				if(prob(50))
					ores += 1
				if(prob(25))
					ores += 1
				var/list/updateturf = list()
				var/list/spiralturfs = spiral_range_turfs(2, Te)
				shuffle(spiralturfs)
				for(var/turf/T in spiralturfs)
					if((prob(60)) && (!( (T.x == (Te.x-2)) || (T.x == (Te.x+2)) ) && ( (T.y == (Te.y-2)) || (T.y == (Te.y+2)) )))
						if(ores)
							T.ChangeTurf(/turf/simulated/floor/plating/airless/asteroid/ore)
							var/turf/simulated/floor/plating/airless/asteroid/ore/oreturf = T
							updateturf += T
							oreturf.oretype = "tantiline"
						else
							T.ChangeTurf(/turf/simulated/floor/plating/airless/asteroid)
							updateturf += T
				for(var/turf/T in updateturf)
					T.updateMineralOverlays()
			for(var/i=1,i<=congloamount,i++)
				var/turf/Te = pick_n_take(conglolocs)
				var/ores = 2
				if(prob(50))
					ores += 1
				if(prob(25))
					ores += 1
				var/list/updateturf = list()
				var/list/spiralturfs = spiral_range_turfs(2, Te)
				shuffle(spiralturfs)
				for(var/turf/T in spiralturfs)
					if((prob(60)) && (!( (T.x == (Te.x-2)) || (T.x == (Te.x+2)) ) && ( (T.y == (Te.y-2)) || (T.y == (Te.y+2)) )))
						if(ores)
							T.ChangeTurf(/turf/simulated/floor/plating/airless/asteroid/ore)
							var/turf/simulated/floor/plating/airless/asteroid/ore/oreturf = T
							updateturf += oreturf
							oreturf.oretype = "conglo"
							oreturf.resource_remaining = rand(5, 20)
							ores--
						else
							T.ChangeTurf(/turf/simulated/floor/plating/airless/asteroid)
							updateturf += T
				for(var/turf/T in updateturf)
					T.updateMineralOverlays()
			for(var/i=1,i<=plasmaamount,i++)
				var/turf/Te = pick_n_take(plasmalocs)
				var/ores = 1
				if(prob(50))
					ores += 1
				if(prob(25))
					ores += 1
				var/list/updateturf = list()
				var/list/spiralturfs = spiral_range_turfs(2, Te)
				shuffle(spiralturfs)
				for(var/turf/T in spiralturfs)
					if((prob(60)) && (!( (T.x == (Te.x-2)) || (T.x == (Te.x+2)) ) && ( (T.y == (Te.y-2)) || (T.y == (Te.y+2)) )))
						if(ores)
							T.ChangeTurf(/turf/simulated/floor/plating/airless/asteroid/ore)
							var/turf/simulated/floor/plating/airless/asteroid/ore/oreturf = T
							updateturf += oreturf
							oreturf.oretype = "plasma"
							oreturf.resource_remaining = rand(5, 20)
							ores--
						else
							T.ChangeTurf(/turf/simulated/floor/plating/airless/asteroid)
							updateturf += T
				for(var/turf/T in updateturf)
					T.updateMineralOverlays()
			for(var/i=1,i<=orichilumamount,i++)
				var/turf/Te = pick_n_take(orichilumlocs)
				var/ores = 1
				if(prob(50))
					ores += 1
				if(prob(25))
					ores += 1
				var/list/updateturf = list()
				var/list/spiralturfs = spiral_range_turfs(2, Te)
				shuffle(spiralturfs)
				for(var/turf/T in spiralturfs)
					if((prob(60)) && (!( (T.x == (Te.x-2)) || (T.x == (Te.x+2)) ) && ( (T.y == (Te.y-2)) || (T.y == (Te.y+2)) )))
						if(ores)
							T.ChangeTurf(/turf/simulated/floor/plating/airless/asteroid/ore)
							var/turf/simulated/floor/plating/airless/asteroid/ore/oreturf = T
							updateturf += oreturf
							oreturf.oretype = "orichilum"
							oreturf.resource_remaining = rand(5, 20)
							ores--
						else
							T.ChangeTurf(/turf/simulated/floor/plating/airless/asteroid)
							updateturf += T
				for(var/turf/T in updateturf)
					T.updateMineralOverlays()
			grabbag += conglolocs
			grabbag += tantilinelocs
			grabbag += plasmalocs
			grabbag += orichilumlocs
			var/remaining = round(grabbag.len/1.5)
			for(var/i=1,i<=remaining,i++)
				var/list/updateturf = list()
				var/turf/Te = pick_n_take(grabbag)
				var/list/spiralturfs = spiral_range_turfs(2, Te) // FAKE ORE POCKETS CREATED HERE
				for(var/turf/T in spiralturfs)
					if((prob(60)) && (!( (T.x == (Te.x-2)) || (T.x == (Te.x+2)) ) && ( (T.y == (Te.y-2)) || (T.y == (Te.y+2)) )))
						T.ChangeTurf(/turf/simulated/floor/plating/airless/asteroid)
						updateturf += T
				for(var/turf/T in updateturf)
					T.updateMineralOverlays()
			message_admins("ORE GENERATION COMPLETE!")
			message_admins("tantiline:[tantilineamount]")
			message_admins("conglo:[congloamount]")
			message_admins("plasma:[plasmaamount]")
			message_admins("orichilum:[orichilumamount]")
			
			
		// take care of random spesspod spawning
		var/list/obj/effect/landmark/spacepod/random/L = list()
		for(var/obj/effect/landmark/spacepod/random/SS in landmarks_list)
			if(istype(SS))
				L += SS
		if(L.len)
			var/obj/effect/landmark/spacepod/random/S = pick(L)
			new /obj/spacepod/random(S.loc)
			for(var/obj/effect/landmark/spacepod/random/R in L)
				qdel(R)

		to_chat(world, "<FONT color='blue'><B>Enjoy the game!</B></FONT>")
		world << sound('sound/AI/welcome.ogg')// Skie

		if(holiday_master.holidays)
			to_chat(world, "<font color='blue'>and...</font>")
			for(var/holidayname in holiday_master.holidays)
				var/datum/holiday/holiday = holiday_master.holidays[holidayname]
				to_chat(world, "<h4>[holiday.greet()]</h4>")

	spawn(0) // Forking dynamic room selection
		var/list/area/dynamic/source/available_source_candidates = subtypesof(/area/dynamic/source)
		var/list/area/dynamic/destination/available_destination_candidates = subtypesof(/area/dynamic/destination)

		for(var/area/dynamic/destination/current_destination_candidate in available_destination_candidates)
			var/area/dynamic/destination/current_destination = locate(current_destination_candidate)

			if(!current_destination)
				continue

			if(current_destination.match_width == 0 || current_destination.match_height == 0)
				message_admins("Dynamic area destination '[current_destination.name]' does not have its size requirements set.")
				continue

			var/list/area/dynamic/source/candidate_source_areas = new /list(0)
			for(var/area/dynamic/source/candidate_source_area in available_source_candidates)
				var/area/dynamic/source/candidate_source = locate(candidate_source_area)

				if(!candidate_source)
					continue

				if(candidate_source.match_tag != current_destination.match_tag)
					continue

				if(candidate_source.match_width != current_destination.match_width || \
					candidate_source.match_height != current_destination.match_height)
					continue

				candidate_source_areas += candidate_source

			if(candidate_source_areas.len == 0)
				message_admins("Failed to find a matching source for dynamic area: [current_destination.name]")
				continue

			var/area/dynamic/source/selected_source = pick(candidate_source_areas)
			available_source_candidates -= selected_source

			selected_source.copy_contents_to(current_destination, 0)

			if(current_destination.enable_lights || selected_source.enable_lights)
				current_destination.power_light = 1
			else
				current_destination.power_light = 0
			current_destination.power_change()

	//start_events() //handles random events and space dust.
	//new random event system is handled from the MC.

	var/admins_number = 0
	for(var/client/C)
		if(C.holder)
			admins_number++
	if(admins_number == 0)
		send2adminirc("Round has started with no admins online.")
	auto_toggle_ooc(0) // Turn it off
	round_start_time = world.time

	/* DONE THROUGH PROCESS SCHEDULER
	supply_controller.process() 		//Start the supply shuttle regenerating points -- TLE
	master_controller.process()		//Start master_controller.process()
	lighting_controller.process()	//Start processing DynamicAreaLighting updates
	*/

	processScheduler.start()
	spawn(100)
		for(var/obj/machinery/power/apc/apc in world)
			apc.update()
		
	
	if(config.sql_enabled)
		spawn(3000)
			statistic_cycle() // Polls population totals regularly and stores them in an SQL DB

	votetimer()

	for(var/mob/M in mob_list)
		if(istype(M,/mob/new_player))
			var/mob/new_player/N = M
			N.new_player_panel_proc()

	return 1
/proc/fix_all_apcs()
	for(var/obj/machinery/power/apc/apc in world)
		apc.update()
	//Plus it provides an easy way to make cinematics for other events. Just use this as a template :)
//Plus it provides an easy way to make cinematics for other events. Just use this as a template
/datum/controller/gameticker/proc/station_explosion_cinematic(station_missed = 0, override = null)
	if(cinematic)
		return	//already a cinematic in progress!

	auto_toggle_ooc(1) // Turn it on
	//initialise our cinematic screen object
	cinematic = new /obj/screen(src)
	cinematic.icon = 'icons/effects/station_explosion.dmi'
	cinematic.icon_state = "station_intact"
	cinematic.layer = 21
	cinematic.mouse_opacity = 0
	cinematic.screen_loc = "1,0"

	var/obj/structure/stool/bed/temp_buckle = new(src)
	if(station_missed)
		for(var/mob/M in mob_list)
			M.buckled = temp_buckle				//buckles the mob so it can't do anything
			if(M.client)
				M.client.screen += cinematic	//show every client the cinematic
	else	//nuke kills everyone on z-level 1 to prevent "hurr-durr I survived"
		for(var/mob/M in mob_list)
			M.buckled = temp_buckle
			if(M.client)
				M.client.screen += cinematic
			if(M.stat != DEAD)
				var/turf/T = get_turf(M)
				if(T && is_station_level(T.z))
					M.death(0) //no mercy

	//Now animate the cinematic
	switch(station_missed)
		if(1)	//nuke was nearby but (mostly) missed
			if(mode && !override)
				override = mode.name
			switch(override)
				if("nuclear emergency") //Nuke wasn't on station when it blew up
					flick("intro_nuke", cinematic)
					sleep(35)
					world << sound('sound/effects/explosionfar.ogg')
					flick("station_intact_fade_red", cinematic)
					cinematic.icon_state = "summary_nukefail"
				if("fake") //The round isn't over, we're just freaking people out for fun
					flick("intro_nuke", cinematic)
					sleep(35)
					world << sound('sound/items/bikehorn.ogg')
					flick("summary_selfdes", cinematic)
				else
					flick("intro_nuke", cinematic)
					sleep(35)
					world << sound('sound/effects/explosionfar.ogg')


		if(2)	//nuke was nowhere nearby	//TODO: a really distant explosion animation
			sleep(50)
			world << sound('sound/effects/explosionfar.ogg')
		else	//station was destroyed
			if(mode && !override)
				override = mode.name
			switch(override)
				if("nuclear emergency") //Nuke Ops successfully bombed the station
					flick("intro_nuke", cinematic)
					sleep(35)
					flick("station_explode_fade_red", cinematic)
					world << sound('sound/effects/explosionfar.ogg')
					cinematic.icon_state = "summary_nukewin"
				if("AI malfunction") //Malf (screen,explosion,summary)
					flick("intro_malf", cinematic)
					sleep(76)
					flick("station_explode_fade_red", cinematic)
					world << sound('sound/effects/explosionfar.ogg')
					cinematic.icon_state = "summary_malf"
				if("blob") //Station nuked (nuke,explosion,summary)
					flick("intro_nuke", cinematic)
					sleep(35)
					flick("station_explode_fade_red", cinematic)
					world << sound('sound/effects/explosionfar.ogg')
					cinematic.icon_state = "summary_selfdes"
				else //Station nuked (nuke,explosion,summary)
					flick("intro_nuke", cinematic)
					sleep(35)
					flick("station_explode_fade_red", cinematic)
					world << sound('sound/effects/explosionfar.ogg')
					cinematic.icon_state = "summary_selfdes"
	//If its actually the end of the round, wait for it to end.
	//Otherwise if its a verb it will continue on afterwards.
	spawn(300)
		if(cinematic)
			qdel(cinematic)		//end the cinematic
			cinematic = null
		if(temp_buckle)
			qdel(temp_buckle)	//release everybody



/datum/controller/gameticker/proc/create_characters()
	for(var/mob/new_player/player in player_list)
		if(player.ready)
			show_info(player)
			var/atom/movable/x = player.create_character()
			if(x)
				x.loc = pick(latejoin)
				qdel(player)


/datum/controller/gameticker/proc/collect_minds()
	for(var/mob/living/player in player_list)
		if(player.mind)
			ticker.minds += player.mind


/datum/controller/gameticker/proc/equip_characters()
	var/captainless=1
	for(var/mob/living/player in player_list)
		if(player && player.mind && player.mind.assigned_role)
			if(player.mind.assigned_role == "Captain")
				captainless=0
			if(player.mind.assigned_role != "MODE")
				job_master.EquipRankPersistant(player, player.mind.primary_cert.uid, 0)
				EquipCustomItems(player)
	if(captainless)
		for(var/mob/M in player_list)
			if(!istype(M,/mob/new_player))
				to_chat(M, "Captainship not forced on anyone.")

/datum/controller/gameticker/proc/setup_faction_members()
	for(var/mob/living/carbon/human/player in player_list)
		if(player && player.mind.faction_uid)
			var/datum/faction/f = get_faction_datum(player.mind.faction_uid)
			if(f)
				if(f.uses_codenames)
					player.mind.codename = generate_codename()
				player.mind.faction = f
				f.members += player.mind
/datum/controller/gameticker/proc/equip_characters_persistant()
	for(var/mob/living/player in player_list)
		if(player && player.mind && player.mind.assigned_role)
			if(player.mind.assigned_role != "MODE")
				if(!player.mind.primary_cert)
					player.mind.primary_cert = job_master.GetCert("intern")
				job_master.EquipRankPersistant(player, player.mind.primary_cert.uid, 0)

								
				
/datum/controller/gameticker/proc/process()
	if(current_state != GAME_STATE_PLAYING)
		return 0

	mode.process()
	mode.process_job_tasks()

	//emergency_shuttle.process() DONE THROUGH PROCESS SCHEDULER
	if(mineController && mineController.next_event <= world.time)
		var/delay = mineController.calculate_nextevent()
		mineController.next_event = (world.time + delay)
	if(mineController && mineController.next_change <= world.time)
		mineController.calculate_nextstage()
		mineController.next_change = (world.time + rand(600, 1200))
		
	var/game_finished = shuttle_master.emergency.mode == SHUTTLE_ENDGAME || mode.station_was_nuked
	if(config.continuous_rounds)
		mode.check_finished() // some modes contain var-changing code in here, so call even if we don't uses result
	else
	//	game_finished |= mode.check_finished()
		mode.check_finished()
		
	if(!mode.explosion_in_progress && game_finished)
		current_state = GAME_STATE_FINISHED
		
		auto_toggle_ooc(1) // Turn it on
		spawn
			declare_completion()

		spawn(50)
			callHook("roundend")

			if(mode.station_was_nuked)
				world.Reboot("Station destroyed by Nuclear Device.", "end_proper", "nuke")
			else
				world.Reboot("Round ended.", "end_proper", "proper completion")

	return 1

/datum/controller/gameticker/proc/getfactionbyname(var/name)
	for(var/datum/faction/F in factions)
		if(F.name == name)
			return F

/datum/controller/gameticker/proc/karmareminder()
	for(var/mob/living/player in player_list)

		if(player.client)
			if(player.client.karma_spent == 0)
				if(player.client.prefs && !(player.client.prefs.toggles & DISABLE_KARMA_REMINDER))
					var/dat
					dat += {"<html><head><title>Karma Reminder</title></head><body><h1><B>Karma Reminder</B></h1><br>
					You have not yet spent your karma for the round, surely there is a player who was worthy of receiving<br>
					your reward? Look under 'Special Verbs' for the 'Award Karma' button, and use it once a round for best results!</table></body></html>"}
					player << browse(dat, "window=karmareminder;size=400x300")


/datum/controller/gameticker/proc/declare_completion()

	nologevent = 0 //end of round murder and shenanigans are legal; there's no need to jam up attack logs past this point.
	//Round statistics report
	var/datum/station_state/end_state = new /datum/station_state()
	end_state.count()
	var/station_integrity = min(round( 100.0 *  start_state.score(end_state), 0.1), 100.0)

	to_chat(world, "<BR>[TAB]Shift Duration: <B>[round(ROUND_TIME / 36000)]:[add_zero("[ROUND_TIME / 600 % 60]", 2)]:[ROUND_TIME / 100 % 6][ROUND_TIME / 100 % 10]</B>")
	to_chat(world, "<BR>[TAB]Station Integrity: <B>[mode.station_was_nuked ? "<font color='red'>Destroyed</font>" : "[station_integrity]%"]</B>")
	to_chat(world, "<BR>")

	//Silicon laws report
	for(var/mob/living/silicon/ai/aiPlayer in mob_list)
		if(aiPlayer.stat != 2)
			to_chat(world, "<b>[aiPlayer.name] (Played by: [aiPlayer.key])'s laws at the end of the game were:</b>")
		else
			to_chat(world, "<b>[aiPlayer.name] (Played by: [aiPlayer.key])'s laws when it was deactivated were:</b>")
		aiPlayer.show_laws(1)

		if(aiPlayer.connected_robots.len)
			var/robolist = "<b>The AI's loyal minions were:</b> "
			for(var/mob/living/silicon/robot/robo in aiPlayer.connected_robots)
				robolist += "[robo.name][robo.stat?" (Deactivated) (Played by: [robo.key]), ":" (Played by: [robo.key]), "]"
			to_chat(world, "[robolist]")

	var/dronecount = 0

	for(var/mob/living/silicon/robot/robo in mob_list)

		if(istype(robo,/mob/living/silicon/robot/drone))
			dronecount++
			continue

		if(!robo.connected_ai)
			if(robo.stat != 2)
				to_chat(world, "<b>[robo.name] (Played by: [robo.key]) survived as an AI-less borg! Its laws were:</b>")
			else
				to_chat(world, "<b>[robo.name] (Played by: [robo.key]) was unable to survive the rigors of being a cyborg without an AI. Its laws were:</b>")

			if(robo) //How the hell do we lose robo between here and the world messages directly above this?
				robo.laws.show_laws(world)

	if(dronecount)
		to_chat(world, "<b>There [dronecount>1 ? "were" : "was"] [dronecount] industrious maintenance [dronecount>1 ? "drones" : "drone"] this round.")

	mode.declare_completion()//To declare normal completion.
	mode.populate_department_lists()
	mode.process_medical_tasks()
	for(var/datum/mind/employee in minds)
		if(!employee.current) continue
		var/datum/preferences/prefs = new()
		prefs.save_mind(null, employee)	
		to_chat(employee.current, "<b>Your character has been saved.</b>")
	
	//calls auto_declare_completion_* for all modes
	for(var/handler in typesof(/datum/game_mode/proc))
		if(findtext("[handler]","auto_declare_completion_"))
			call(mode, handler)()
	
	//Ask the event manager to print round end information
	event_manager.RoundEnd()

	return 1


/datum/controller/gameticker/proc/saveworld(var/chosen)
	map_storage = new()
	fdel("[chosen].sav")
	var/savefile/W = new("[chosen].sav")
	var/list/to_save = list()
	switch(chosen)
		if("Cargo")
			to_save += typesof(/area/quartermaster)
		if("Security")
			to_save += typesof(/area/security)
		if("Engineering")
			to_save += typesof(/area/engine)
			to_save -= /area/engine/gravitygenerator
		if("Medical")
			to_save += typesof(/area/medical)
		if("Science")
			to_save += typesof(/area/toxins)
		if("Bridge")
			to_save += typesof(/area/bridge)
			to_save += typesof(/area/crew_quarters/captain)
			to_save += typesof(/area/turret_protected/ai_upload)
		if("Hallways")
			to_save += typesof(/area/hallway)
		if("Maintenence")
			to_save += typesof(/area/maintenance)
		if("Quarters")
			to_save += typesof(/area/crew_quarters)
			to_save -= /area/crew_quarters/captain
	map_storage.Save(W, to_save)
	
/datum/controller/gameticker/proc/loadworld(var/chosen)
	map_storage = new()
	if(fexists("[chosen].sav"))
		sleep(1)
		var/savefile/W = new("[chosen].sav")
		map_storage.Load(W)
		
/datum/controller/gameticker/proc/savestation()
	var/watch = start_watch()
	to_chat(world, "<FONT color='blue'><B>SAVING THE STATION! THIS USUALLY TAKES UNDER 10 SECONDS</B></FONT>")
	sleep(20)
	var/started = 0
	if(processScheduler.isRunning)
		started = 1
		processScheduler.stop()
	map_storage.Save_World(the_station_areas)
	if(started)
		processScheduler.start()
	log_startup_progress("	Saved the station in [stop_watch(watch)]s.")
	return 1
	
/datum/controller/gameticker/proc/loadstation()
	var/watch = start_watch()
	var/started = 0
	if(processScheduler.isRunning)
		started = 1
		processScheduler.stop()
	log_startup_progress("Starting station load...")
	sleep(5)
	map_storage.Load_World(the_station_areas)
	if(started)
		processScheduler.start()
	log_startup_progress("	Loaded the station in [stop_watch(watch)]s.")
	return 1
	
/datum/controller/gameticker/proc/loadhalf()
	var/watch = start_watch()
	log_startup_progress("Starting station load...")
	var/all_saved = list("Cargo", "Security", "Engineering", "Medical", "Science", "Bridge")
	for(var/x in all_saved)
		loadworld(x)
	log_startup_progress("	Loaded the station in [stop_watch(watch)]s.")
	return 1
	
/datum/controller/gameticker/proc/loadhalf2()
	to_chat(world, "<FONT color='blue'><B>LOADING THE STATION! PLEASE BE PATIENT</B></FONT>")
	var/watch = start_watch()
	log_startup_progress("Starting station load...")
	var/all_saved = list("Hallways", "Maintenence", "Quarters")
	for(var/x in all_saved)
		loadworld(x)
	master_controller.setup_objects()
	log_startup_progress("	Loaded the station in [stop_watch(watch)]s.")
	return 1
	