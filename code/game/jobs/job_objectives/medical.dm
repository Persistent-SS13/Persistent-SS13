/datum/job_objective/department/medical/extract_crewmembers
	completion_payment = 5
	per_unit = 1
	department_flag = MEDICAL
	
/datum/job_objective/department/medical/extract_crewmembers/get_description()
	var/desc = "Extract all innocent crewmembers dead or alive. You will recieve a bonus for every crewmember in perfect health. Depart the station along with the majority of the crew, you will recieve a bonus for every crewmember that is extracted in perfect health."
	if (completed)
		desc += " (All crewmembers extracted. [units_completed] of the crew departed in perfect health.)"
	else if(over_time)
		desc += " (Failed to extract every innocent crewmember, pay has been garnished)"
	return desc
	
/datum/job_objective/department/medical/extract_crewmembers/calculate_basepay(var/datum/mind/M)
	var/pay = max(min(startingplayers * 25, 1500), 4000)
	var/rank = M.ranks["medical"]
	if (M.assigned_job.flag == CMO)
		rank = 5
	pay = round((pay / (6 - rank)), 1)
	return pay
	
	
/datum/job_objective/department/medical/extract_crewmembers/calculate_pay(var/perfecthealth, var/datum/mind/M)
	var/pay = max(min(startingplayers * 25, 1500), 4000)
	var/rank = M.ranks["medical"]
	if (M.assigned_job.flag == CMO)
		rank = 5
	pay += (perfecthealth * 10)	
	pay = round((pay / (6 - rank)), 1)
	return pay	
	
		
/datum/job_objective/department/medical/extract_crewmembers/check_for_completion()
	
	//for(var/tech in shuttle_master.techLevels)
	//	if(shuttle_master.techLevels[tech] > 0)
	//		return 1
	//return 0

/////////////////////////////////////////////////////////////////////////////////////////
	