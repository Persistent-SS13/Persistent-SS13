/datum/controller/process/headselect/setup()
	name = "head selector"
	schedule_interval = 100 // every 10 seconds

/proc/check_role(var/uid)
	for(var/datum/mind/M in ticker.minds)
		if(!M.assigned_job || !M.current)
			continue
		if(M.assigned_job.uid == uid)
			return 1
	return 0
/proc/clear_alert_all(var/alert_type)
	for(var/datum/mind/M in ticker.minds)
		if(!M.current) continue
		M.current.clear_alert(alert_type)
/proc/clear_all_foundalerts(var/datum/mind/M)
	if(!M || !M.current) return
	M.current.clear_alert("need_cap")
	M.current.clear_alert("need_hop")
	M.current.clear_alert("need_cmo")
	M.current.clear_alert("need_ce")
	M.current.clear_alert("need_hos")
	M.current.clear_alert("need_rd")
	M.current.clear_alert("need_qm")
/datum/controller/process/headselect/doWork()
			
	var/found_cap = 0
	var/found_hop = 0
	var/found_hos = 0
	var/found_cmo = 0
	var/found_qm = 0
	var/found_ce = 0
	var/found_rd = 0
	
	var/highest_rank = 3
	var/highest_rank_security = 3
	var/highest_rank_medical = 3
	var/highest_rank_cargo = 3
	var/highest_rank_engineering = 3
	var/highest_rank_science = 3
	
	var/list/potential_command = list()
	var/list/potential_medical = list()
	var/list/potential_cargo = list()
	var/list/potential_engineering = list()
	var/list/potential_science = list()
	var/list/potential_security = list()
	data_core.manifest_recs = list()
	for(var/datum/mind/M in ticker.minds)
		if(!M.assigned_job)
			continue
		var/current_dep = M.assigned_job.department_flag
		var/current_rank = text2num(M.ranks[to_strings(M.assigned_job.department_flag)])
	
		
		if(M.assigned_job.uid == "captain")
			if(!M.current || !istype(M.current, /mob/living/carbon/human) || M.current.stat == 2)
				M.assigned_job = M.primary_cert
				change_certification(M, M.primary_cert)
			else
				found_cap = 1
		if(M.assigned_job.uid == "hop")
			if(!M.current || !istype(M.current, /mob/living/carbon/human) || M.current.stat == 2)
				M.assigned_job = M.primary_cert
				change_certification(M, M.primary_cert)
			else
				found_hop = 1
		if(M.assigned_job.uid == "chief")
			if(!M.current || !istype(M.current, /mob/living/carbon/human) || M.current.stat == 2)
				M.assigned_job = M.primary_cert
				change_certification(M, M.primary_cert)
			else
				found_ce = 1
		if(M.assigned_job.uid == "cmo")
			if(!M.current || !istype(M.current, /mob/living/carbon/human) || M.current.stat == 2)
				M.assigned_job = M.primary_cert
				change_certification(M, M.primary_cert)
			else
				found_cmo = 1
		if(M.assigned_job.uid == "hos")
			if(!M.current || !istype(M.current, /mob/living/carbon/human) || M.current.stat == 2)
				M.assigned_job = M.primary_cert
				change_certification(M, M.primary_cert)
			else
				found_hos = 1
		if(M.assigned_job.uid == "quartermaster")
			if(!M.current || !istype(M.current, /mob/living/carbon/human) || M.current.stat == 2)
				M.assigned_job = M.primary_cert
				change_certification(M, M.primary_cert)
			else
				found_qm = 1
		if(M.assigned_job.uid == "rd")
			if(!M.current || !istype(M.current, /mob/living/carbon/human) || M.current.stat == 2)
				M.assigned_job = M.primary_cert
				change_certification(M, M.primary_cert)
			else
				found_rd = 1
		if(M.current)
			var/datum/data/record/G = data_core.gen_byname[M.current.real_name]
			if(!G)
				message_admins("No record found for [M.current.real_name] xyz: [M.current.x],[M.current.y],[M.current.z]")
			else
				var/obj/item/weapon/implant/crewtracker/Imp
				for(var/obj/item/weapon/implant/crewtracker/I in M.current.contents)
					Imp = I
					break
				if(Imp && Imp.tracking)
					data_core.manifest_recs |= G
				else
					clear_all_foundalerts(M)
					if(M.assigned_job != M.primary_cert)
						message_admins("disabiling cert")
						M.assigned_job = M.primary_cert
						change_certification(M, M.primary_cert)
					continue
					
		if(!M.current || !istype(M.current, /mob/living/carbon/human) || M.current.stat == 2 || M.assigned_job.head_position)
			clear_all_foundalerts(M)
			continue
					
		if(!found_cap || !found_hop)
			if(current_rank > highest_rank)
				highest_rank = current_rank
				potential_command = list(M)
			else if(current_rank == highest_rank)
				potential_command += M
		if(!found_ce && current_dep == ENGINEERING)
			if(current_rank > highest_rank_engineering)
				highest_rank_engineering = current_rank
				potential_engineering = list(M)
			else if(current_rank == highest_rank_engineering)
				potential_engineering += M
		if(!found_cmo && current_dep == MEDICAL)
			if(current_rank > highest_rank_medical)
				highest_rank_medical = current_rank
				potential_medical = list(M)
			else if(current_rank == highest_rank_medical)
				potential_medical += M
		if(!found_hos && current_dep == SECURITY)
			if(current_rank > highest_rank_security)
				highest_rank_security = current_rank
				potential_security = list(M)
			else if(current_rank == highest_rank_security)
				potential_security += M
		if(!found_hos && current_dep == CARGO)
			if(current_rank > highest_rank_cargo)
				highest_rank_cargo = current_rank
				potential_cargo = list(M)
			else if(current_rank == highest_rank_cargo)
				potential_cargo += M
		if(!found_rd && current_dep == SCIENCE)
			if(current_rank > highest_rank_science)
				highest_rank_science = current_rank
				potential_science = list(M)
			else if(current_rank == highest_rank_science)
				potential_science += M
	for(var/datum/mind/M in ticker.minds)
		if(!M.current) continue
		if(!found_cap && (M in potential_command))
			M.current.throw_alert("need_cap", /obj/screen/alert/need_cap)
		else
			M.current.clear_alert("need_cap")
		if(!found_hop && (M in potential_command))
			M.current.throw_alert("need_hop", /obj/screen/alert/need_hop)
		else
			M.current.clear_alert("need_hop")
		if(!found_hos && (M in potential_security))
			M.current.throw_alert("need_hos", /obj/screen/alert/need_hos)
		else
			M.current.clear_alert("need_hos")
		if(!found_qm && (M in potential_cargo))
			M.current.throw_alert("need_qm", /obj/screen/alert/need_qm)
		else
			M.current.clear_alert("need_qm")
		if(!found_cmo && (M in potential_medical))
			M.current.throw_alert("need_cmo", /obj/screen/alert/need_cmo)
		else
			M.current.clear_alert("need_cmo")
		if(!found_rd && (M in potential_science))
			M.current.throw_alert("need_rd", /obj/screen/alert/need_rd)
		else
			M.current.clear_alert("need_rd")
		if(!found_ce && (M in potential_engineering))
			M.current.throw_alert("need_ce", /obj/screen/alert/need_ce)
		else
			M.current.clear_alert("need_ce")