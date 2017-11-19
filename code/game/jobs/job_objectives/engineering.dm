/datum/job_objective/department/engineering/power_station
	completion_payment = 5
	per_unit = 1
	department_flag = ENGINEERING
	
/datum/job_objective/department/engineering/power_station/get_description()
	var/desc = "Keep the station powered and repaired. Complete construction assignments issued by command. Depart the station along with the majority of the crew, you will recieve a bonus for every crewmember that is extracted in perfect health."
	if (completed)
		desc += " (All crewmembers extracted. [units_completed] of the crew departed in perfect health.)"
	else if(over_time)
		desc += " (Failed to extract every innocent crewmember, pay has been garnished)"
	return desc
	
/datum/job_objective/department/engineering/power_station/calculate_basepay(var/datum/mind/M)
	var/pay = max(min(startingplayers * 25, 1500), 4000)
	var/rank = M.ranks["engineering"]
	if (M.assigned_job.flag == CHIEF)
		rank = 5
	pay = round((pay / (6 - rank)), 1)
	return pay
	
	
/datum/job_objective/department/engineering/power_station/calculate_pay(var/perfecthealth, var/datum/mind/M)
	var/pay = max(min(startingplayers * 25, 1500), 4000)
	var/rank = M.ranks["engineering"]
	if (M.assigned_job.flag == CHIEF)
		rank = 5
	pay += (perfecthealth * 10)	
	pay = round((pay / (6 - rank)), 1)
	return pay	
	