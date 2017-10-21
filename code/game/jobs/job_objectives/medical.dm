/datum/job_objective/department
	var/department_flag = 0
	var/bonus_payment = 0
	var/over_time = 0   				// Is it too late to complete the objective?
	var/bonus_objective = 0				// some objectives need to track 2 objectives
	
/datum/job_objective/department/medical
/datum/job_objective/department/New()


/datum/job_objective/department/medical/proc/calculate_pay()

/datum/job_objective/department/medical/proc/calculate_basepay()


/////////////////////////////////////////////////////////////////////////////////////////
// MEDICAL
/////////////////////////////////////////////////////////////////////////////////////////
	
//LETS DO THIS
/datum/job_objective/department/medical/extract_crewmembers
	completion_payment = 5
	per_unit = 1
	department_flag = MEDICAL
	
/datum/job_objective/department/medical/extract_crewmembers/get_description()
	var/desc = "Extract all innocent crewmembers dead or alive. You will recieve a bonus for every crewmember in perfect health."
	if (completed)
		desc += " (All crewmembers extracted. [units_completed] of the crew departed in perfect health.)"
	else if(over_time)
		desc += " (Failed to extract every innocent crewmember, pay has been garnished)"
	return desc
	
/datum/job_objective/department/medical/extract_crewmembers/calculate_basepay(var/datum/mind/M)
	var/pay = min(max(startingplayers * 25, 1500), 4000)
	var/rank = M.ranks["medical"]
	if (M.assigned_job.flag == CMO)
		rank = 5
	pay = round((pay / 6 - rank), 1)
	return pay
	
	
/datum/job_objective/department/medical/extract_crewmembers/calculate_pay(var/perfecthealth, var/datum/mind/M)
	var/pay = min(max(startingplayers * 25, 1500), 4000)
	var/rank = M.ranks["medical"]
	if (M.assigned_job.flag == CMO)
		rank = 5
	pay += (perfecthealth * 10)	
	pay = round((pay / 6 - rank), 1)
	return pay	
	
		
/datum/job_objective/department/medical/extract_crewmembers/check_for_completion()
	
	//for(var/tech in shuttle_master.techLevels)
	//	if(shuttle_master.techLevels[tech] > 0)
	//		return 1
	//return 0

/////////////////////////////////////////////////////////////////////////////////////////
	