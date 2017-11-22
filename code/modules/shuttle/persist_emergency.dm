/obj/machinery/computer/emergency_shuttle
	name = "emergency shuttle console"
	desc = "For shuttle control."
	icon_screen = "shuttle"
	icon_keyboard = "tech_key"
	var/auth_need = 3
	var/list/authorized = list()
	var/captain_confirm = 0
	var/second_confirm = 0
	
/obj/machinery/computer/emergency_shuttle/attackby(obj/W, mob/user, params)
	if(stat & (BROKEN|NOPOWER))
		return
	if(!user)
		return
	if(!user.mind || !user.mind.assigned_job)
		return
	if(user.mind.assigned_job.uid == "captain" || user.mind.assigned_job.uid == "hop")
		attack_hand(user)
		return
	else
		to_chat(user, "Your access level is not high enough. ")
		return
		
					
/obj/machinery/computer/emergency_shuttle/attack_hand(mob/user as mob)
	ui_interact(user)



/obj/machinery/computer/emergency_shuttle/ui_interact(mob/user, ui_key="main", var/datum/nanoui/ui = null, var/force_open = 1)
	if(!user.mind || !shuttle_master)
		return
	user.set_machine(src)
	var/data[0]
	data["crewmembers"] = crew_repository.health_data(T)
	data["src"] = "\ref[src]"
	data["shuttle_mode"] = shuttle_master.emergency.mode
	data["is_captain"] = (user.mind.assigned_job.uid == "captain")
	data["cap_confirmed"] = captain_confirm
	data["sec_confirmed"] = second_confirm
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "emergency_control.tmpl", src.name, 775, 700)
		ui.set_initial_data(data)
		ui.open()
		
/obj/machinery/computer/emergency_shuttle/Topic(href, href_list)

	switch(href_list["choice"])
		if("confirm_departure_cap")
			if(usr && shuttle_master.emergency.mode == SHUTTLE_IDLE && usr.mind && usr.mind.assigned_job && usr.mind.assigned_job.uid == "captain")
				captain_confirm = 1
				if(captain_confirm && second_confirm)
					captain_confirm = 0
					second_confirm = 0
					shuttle_master.emergency.request_send()
					for(var/obj/machinery/door/airlock/A in airlocks)
						if(A.id_tag == "emergency_away")
							spawn(-1)
								if(A.locked)
									A.unlock()
								A.req_access = list()
							

		if("confirm_departure_sec")
			if(usr && shuttle_master.emergency.mode == SHUTTLE_IDLE && usr.mind && usr.mind.assigned_job && usr.mind.assigned_job.uid == "hop")
				second_confirm = 1
				if(captain_confirm && second_confirm)
					captain_confirm = 0
					second_confirm = 0
					shuttle_master.emergency.request_send()
					for(var/obj/machinery/door/airlock/A in airlocks)
						if(A.id_tag == "emergency_away")
							spawn(-1)
								if(A.locked)
									A.unlock()
								A.req_access = list()
		if("cancel_departure_cap")
			if(usr && shuttle_master.emergency.mode == SHUTTLE_IDLE && usr.mind && usr.mind.assigned_job && usr.mind.assigned_job.uid == "captain")
				captain_confirm = 0
		if("cancel_departure_sec")
			if(usr && shuttle_master.emergency.mode == SHUTTLE_IDLE && usr.mind && usr.mind.assigned_job && usr.mind.assigned_job.uid == "hop")
				second_confirm = 0
		if("cancel_departure")
			if(usr && shuttle_master.emergency.mode == SHUTTLE_BOARDING && usr.mind && usr.mind.assigned_job && usr.mind.assigned_job.uid == "captain")
				shuttle_master.emergency.mode = SHUTTLE_IDLE
				shuttle_master.emergency.timer = 0
		if("depart")
			if(usr && shuttle_master.emergency.mode == SHUTTLE_WAITING && usr.mind && usr.mind.assigned_job && usr.mind.assigned_job.uid == "captain")		
				//now move the actual emergency shuttle to its transit dock
				for(var/area/shuttle/escape/E in world)
					E << 'sound/effects/hyperspace_begin.ogg'
				shuttle_master.emergency.mode = SHUTTLE_DELAY
				shuttle_master.emergency.timer = world.time
	nanomanager.update_uis(src)
	
/obj/machinery/computer/emergency_shuttle/emag_act(mob/user)


/obj/docking_port/mobile/emergency
	name = "emergency shuttle"
	id = "emergency"

	dwidth = 9
	width = 22
	height = 11
	dir = 4
	travelDir = 0
	roundstart_move = "emergency_away"
	var/sound_played = 0 //If the launch sound has been sent to all players on the shuttle itself

	var/datum/announcement/priority/emergency_shuttle_docked = new(0, new_sound = sound('sound/AI/shuttledock.ogg'))
	var/datum/announcement/priority/emergency_shuttle_called = new(0, new_sound = sound('sound/AI/shuttlecalled.ogg'))
	var/datum/announcement/priority/emergency_shuttle_recalled = new(0, new_sound = sound('sound/AI/shuttlerecalled.ogg'))
	var/datum/announcement/priority/transfer_shuttle_boarding = new(0)

/obj/docking_port/mobile/emergency/register()
	if(!..())
		return 0 //shuttle master not initialized

	shuttle_master.emergency = src
	return 1

/obj/docking_port/mobile/emergency/timeLeft(divisor)
	if(divisor <= 0)
		divisor = 10
	if(!timer)
		return round(shuttle_master.emergencyCallTime/divisor, 1)

	var/dtime = world.time - timer
	switch(mode)
		if(SHUTTLE_ESCAPE)
			dtime = max(shuttle_master.emergencyEscapeTime - dtime, 0)
		if(SHUTTLE_DOCKED)
			dtime = max(shuttle_master.emergencyDockTime - dtime, 0)
		if(SHUTTLE_DELAY)
			dtime = max(shuttle_master.transferDelayTime - dtime, 0)
		if(SHUTTLE_ARRIVED)
			dtime = max(shuttle_master.transferWaitTime - dtime, 0)
		if(SHUTTLE_BOARDING)
			dtime = max(shuttle_master.transferBoardTime - dtime, 0)
		if(SHUTTLE_TRANSITTO)
			dtime = max(shuttle_master.emergencyEscapeTime - dtime, 0)
		if(SHUTTLE_RETURNING)
			dtime = max(shuttle_master.transferFastTime - dtime, 0)
		if(SHUTTLE_DEPDELAY)
			dtime = max(shuttle_master.transferDelayTime - dtime, 0)
		if(SHUTTLE_DELAY2)
			dtime = max(shuttle_master.transferDelayTime - dtime, 0)
		if(SHUTTLE_CALLED)
			dtime = max(shuttle_master.transferCallTime - dtime, 0)
		if(SHUTTLE_TRAVELING)
			dtime = max(shuttle_master.emergencyEscapeTime - dtime, 0)
		if(SHUTTLE_DELAY3)
			dtime = max(shuttle_master.transferDelayTime - dtime, 0)
		if(SHUTTLE_ENDING)
			dtime = max(shuttle_master.transferBoardTime - dtime, 0)	
		else
			dtime = max(shuttle_master.emergencyCallTime - dtime, 0)
	return round(dtime/divisor, 1)

/obj/docking_port/mobile/emergency/request(obj/docking_port/stationary/S, coefficient=1, area/signalOrigin, reason, redAlert)
	shuttle_master.emergencyCallTime = initial(shuttle_master.emergencyCallTime) * coefficient
	if(redAlert)	
		switch(mode)
			if(SHUTTLE_CALLED)
				mode = SHUTTLE_TRAVELING
				timer = world.time
				for(var/area/shuttle/escape/E in world)
					E << 'sound/effects/hyperspace_begin.ogg'
				priority_announcement.Announce("The Departure Shuttle has departed early to reflect the increased state of emergency. It will arrive at the station in [timeLeft(600)] minutes.")
				mode = SHUTTLE_DELAY2
			if(SHUTTLE_IDLE)
				mode = SHUTTLE_TRAVELING
				timer = world.time
				for(var/area/shuttle/escape/E in world)
					E << 'sound/effects/hyperspace_begin.ogg'
				priority_announcement.Announce("The Departure Shuttle has departed early to reflect the increased state of emergency. It will arrive at the station in [timeLeft(600)] minutes.")
				mode = SHUTTLE_DELAY2
			if(SHUTTLE_RETURNED)
				mode = SHUTTLE_TRAVELING
				timer = world.time
				for(var/area/shuttle/escape/E in world)
					E << 'sound/effects/hyperspace_begin.ogg'
				priority_announcement.Announce("The Departure Shuttle has been called under a state of emergency; It has departed Centcom and will arrive at the station in [timeLeft(600)] minutes.")
				mode = SHUTTLE_DELAY2
			else
				return
	else
		switch(mode)
			if(SHUTTLE_RETURNED)	
				mode = SHUTTLE_CALLED
				timer = world.time
				priority_announcement.Announce("The Departure Shuttle has been called. It will depart Centcom in [timeLeft(600)] minutes. After it departs Centcom it will not be available for recall.")
			if(SHUTTLE_IDLE)	
				mode = SHUTTLE_CALLED
				timer = world.time
				priority_announcement.Announce("The Departure Shuttle has been called. It will depart Centcom in [timeLeft(600)] minutes. After it departs Centcom it will not be available for recall.")
			if(SHUTTLE_CALLED)
				if(world.time < timer)	//this is just failsafe
					timer = world.time

	
/obj/docking_port/mobile/emergency/proc/request_send()
	switch(mode)
		if(SHUTTLE_IDLE)
			mode = SHUTTLE_BOARDING
			timer = world.time
		else
			return
	transfer_shuttle_boarding.Announce("The departure shuttle is now boarding at Centcom. You have [timeLeft(600)] minute to board before the Captain has the option to launch.")
			
	
	
/obj/docking_port/mobile/emergency/cancel(area/signalOrigin)
	if(mode != SHUTTLE_CALL)
		return

	timer = world.time - timeLeft(1)
	mode = SHUTTLE_RECALL

	if(prob(70))
		shuttle_master.emergencyLastCallLoc = signalOrigin
	else
		shuttle_master.emergencyLastCallLoc = null
	emergency_shuttle_recalled.Announce("The emergency shuttle has been recalled.[shuttle_master.emergencyLastCallLoc ? " Recall signal traced. Results can be viewed on any communications console." : "" ]")

/*
/obj/docking_port/mobile/emergency/findTransitDock()
	. = shuttle_master.getDock("emergency_transit")
	if(.)	return .
	return ..()
*/


/obj/docking_port/mobile/emergency/check()
	if(!timer)
		return

	var/time_left = timeLeft(1)
	switch(mode)
		if(SHUTTLE_BOARDING)
			if(time_left <= 0)
				mode = SHUTTLE_WAITING
				priority_announcement.Announce("The Departure shuttle is ready for launch, please strap in and wait for the Captain to launch the shuttle.")
				timer = 0
		if(SHUTTLE_TRANSITTO)
			if(time_left <= 0)
				if(dock(shuttle_master.getDock("emergency_home")))
					setTimer(20)
					return
				mode = SHUTTLE_ARRIVED
				timer = world.time
				priority_announcement.Announce("The Departure shuttle has docked with the station. You have [timeLeft(600)] minutes to exit the shuttle or you will be returned to CENTCOM without pay.")
				for(var/area/shuttle/escape/E in world)
					E << 'sound/effects/hyperspace_end.ogg'
			
		if(SHUTTLE_DELAY)
			if(time_left <= 0)
				for(var/area/shuttle/escape/E in world)
					E << 'sound/effects/hyperspace_progress.ogg'
				enterTransit()
				mode = SHUTTLE_TRANSITTO
				timer = world.time
				priority_announcement.Announce("The Departure shuttle has left CENTCOM. Any crewmembers that do not board the shuttle will forfeit their pay! Estimate approximately [timeLeft(600)] minutes until the shuttle arrives at the station. As soon as the shuttle docks, the CENTCOM teleporter will triangulate and unlock.")
				
		if(SHUTTLE_ARRIVED)
			if(time_left <= 0)
				for(var/area/shuttle/escape/E in world)
					E << 'sound/effects/hyperspace_begin.ogg'
				mode = SHUTTLE_DEPDELAY
				timer = world.time
		if(SHUTTLE_DEPDELAY)
			if(time_left <= 0)
				for(var/area/shuttle/escape/E in world)
					E << 'sound/effects/hyperspace_progress.ogg'
				enterTransit()
				mode = SHUTTLE_RETURNING
				timer = world.time
		if(SHUTTLE_RETURNING)
			if(time_left <= 0)
				if(dock(shuttle_master.getDock("emergency_away")))
					setTimer(20)
					return
				mode = SHUTTLE_RETURNED
				timer = 0
				for(var/area/shuttle/escape/E in world)
					E << 'sound/effects/hyperspace_end.ogg'
		if(SHUTTLE_DELAY2)
			if(time_left <= 0)
				for(var/area/shuttle/escape/E in world)
					E << 'sound/effects/hyperspace_progress.ogg'
				enterTransit()
				mode = SHUTTLE_TRAVELING
				timer = world.time
		if(SHUTTLE_TRAVELING)
			if(time_left <= 0)
				if(dock(shuttle_master.getDock("emergency_home")))
					setTimer(20)
					return
				mode = SHUTTLE_DOCKED
				timer = world.time
				priority_announcement.Announce("The Departure shuttle has docked with the station. Any crewmembers that do not board the shuttle will forfeit their pay! The shuttle will depart in approximately [timeLeft(600)] minutes unless the Captain or Head of Personnel delays it.")
				for(var/area/shuttle/escape/E in world)
					E << 'sound/effects/hyperspace_end.ogg'
		if(SHUTTLE_CALLED)
			if(time_left <= 0)
				for(var/area/shuttle/escape/E in world)
					E << 'sound/effects/hyperspace_begin.ogg'
				timer = world.time
				mode = SHUTTLE_TRAVELING
				priority_announcement.Announce("The Departure shuttle has left Centcom. The shuttle will arrive in approximately [timeLeft(600)] minutes. Begin departure procedures immediately.")
				mode = SHUTTLE_DELAY2
				
					
		if(SHUTTLE_IDLE)
			if(time_left <= 0)
				return
		if(SHUTTLE_RECALL)
			if(time_left <= 0)
				mode = SHUTTLE_IDLE
				timer = 0
		if(SHUTTLE_CALL)
			if(time_left <= 0)
				//move emergency shuttle to station
				if(dock(shuttle_master.getDock("emergency_home")))
					setTimer(20)
					return
				mode = SHUTTLE_DOCKED
				timer = world.time
				send2irc("Server", "The Emergency Shuttle has docked with the station.")
				emergency_shuttle_docked.Announce("The Emergency Shuttle has docked with the station. You have [timeLeft(600)] minutes to board the Emergency Shuttle.")

		if(SHUTTLE_DOCKED)

		//	if(time_left <= 0 && shuttle_master.emergencyNoEscape)
		//		priority_announcement.Announce("Hostile environment detected. Departure has been postponed indefinitely pending conflict resolution.")
		//		sound_played = 0
		//		mode = SHUTTLE_STRANDED

				
			if(time_left <= 0) //  && !shuttle_master.emergencyNoEscape
				for(var/area/shuttle/escape/E in world)
					E << 'sound/effects/hyperspace_begin.ogg'
				mode = SHUTTLE_DELAY3
				timer = world.time
			
			
			
		if(SHUTTLE_ESCAPE)
			if(time_left <= 0)
				//move each escape pod to its corresponding escape dock
				for(var/obj/docking_port/mobile/pod/M in shuttle_master.mobile)
					M.dock(shuttle_master.getDock("[M.id]_away"))
				// unlock doors at centcom	
				for(var/obj/machinery/door/airlock/A in airlocks)
					if(A.id_tag == "pod_access")
						spawn(-1)
							if(A.locked)
								A.unlock()
							A.req_access = list()
				//now move the actual emergency shuttle to centcomm
				for(var/area/shuttle/escape/E in world)
					E << 'sound/effects/hyperspace_end.ogg'
				dock(shuttle_master.getDock("emergency_away"))
				mode = SHUTTLE_ENDING
				timer = world.time
				open_dock()
				priority_announcement.Announce("The Departure Shuttle has arrived at Centcom. Active crewmembers will have [time_left] minute before you are forced into the habitat ring to rest before your next deployment.")
				spawn(0)
					for(var/datum/mind/employee in ticker.minds)
						if(!employee.current) continue
						var/map_storage/map_storage = new("SS13")
						map_storage.Save_Char(null, employee, null, employee.char_slot)	
						to_chat(employee.current, "<b>Your character has been saved.</b>")
					ticker.savestation()

		if(SHUTTLE_ENDING)
			if(time_left <= 0)
				mode = SHUTTLE_ENDGAME
				timer = 0
			
		if(SHUTTLE_DELAY3)
			if(time_left <= 0)
				//move each escape pod to its corresponding transit dock
				for(var/obj/docking_port/mobile/pod/M in shuttle_master.mobile)
					if(is_station_level(M.z)) //Will not launch from the mine/planet
						M.enterTransit()
				//now move the actual emergency shuttle to its transit dock
				for(var/area/shuttle/escape/E in world)
					E << 'sound/effects/hyperspace_progress.ogg'
				enterTransit()
				mode = SHUTTLE_ESCAPE
				timer = world.time
				priority_announcement.Announce("The Departure Shuttle has left the station. Estimate [timeLeft(600)] minutes until the shuttle docks at Central Command.")
				spawn(50)
					ticker.mode.populate_department_lists()
					ticker.mode.process_all_tasks()
/obj/docking_port/mobile/emergency/proc/open_dock();
/*
	for(var/obj/machinery/door/poddoor/shuttledock/D in airlocks)
		var/turf/T = get_step(D, D.checkdir)
		if(!istype(T,/turf/space))
			spawn(0)
				D.open()
*/ //Leaving this here incase someone decides to port -tg-'s escape shuttle stuff:
// This basically opens a big-ass row of blast doors when the shuttle arrives at centcom
/obj/docking_port/mobile/pod
	name = "escape pod"
	id = "pod"

	dwidth = 1
	width = 3
	height = 4

/obj/docking_port/mobile/pod/New()
	..()
	if(id == "pod")
		WARNING("[type] id has not been changed from the default. Use the id convention \"pod1\" \"pod2\" etc.")

/obj/docking_port/mobile/pod/cancel()
	return

/*
	findTransitDock()
		. = shuttle_master.getDock("[id]_transit")
		if(.)	return .
		return ..()
*/

/obj/machinery/computer/shuttle/pod
	name = "pod control computer"
	admin_controlled = 1
	shuttleId = "pod"
	possible_destinations = "pod_asteroid"
	icon = 'icons/obj/terminals.dmi'
	icon_state = "dorm_available"
	density = 0

/obj/machinery/computer/shuttle/pod/update_icon()
	return

/obj/machinery/computer/shuttle/pod/emag_act(mob/user as mob)
	to_chat(user, "<span class='warning'> Access requirements overridden. The pod may now be launched manually at any time.</span>")
	admin_controlled = 0
	icon_state = "dorm_emag"

/obj/docking_port/stationary/random
	name = "escape pod"
	id = "pod"
	dwidth = 1
	width = 3
	height = 4
	var/target_area = /area/mine/unexplored

/obj/docking_port/stationary/random/initialize()
	..()
	var/list/turfs = get_area_turfs(target_area)
	var/turf/T = pick(turfs)
	src.loc = T
