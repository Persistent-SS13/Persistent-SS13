/////////////////////////////////////////////////////////////////////////////////////////
// Research
/////////////////////////////////////////////////////////////////////////////////////////

// MAXIMUM SCIENCE
/datum/job_objective/further_research
	completion_payment = 5
	per_unit = 1

/datum/job_objective/further_research/get_description()
	var/desc = "Research tech levels, and have cargo ship them to centcomm."
	desc += "([units_completed] completed.)"
	return desc

/datum/job_objective/maximize_research/check_for_completion()
	for(var/tech in shuttle_master.techLevels)
		if(shuttle_master.techLevels[tech] > 0)
			return 1
	return 0

/////////////////////////////////////////////////////////////////////////////////////////
// Robotics
/////////////////////////////////////////////////////////////////////////////////////////

//Cyborgs
/datum/job_objective/make_cyborg
	completion_payment = 100
	per_unit = 1

/datum/job_objective/make_cyborg/get_description()
	var/desc = "Make a cyborg."
	desc += "([units_completed] created.)"
	return desc



//RIPLEY's
/datum/job_objective/make_ripley
	completion_payment = 600
	per_unit = 1

/datum/job_objective/make_ripley/get_description()
	var/desc = "Make a Ripley or Firefighter."
	desc += "([units_completed] created.)"
	return desc
	
	
/////////////////////////////////////////////////////////////////////////////////////////
	
/datum/job_objective/department/science/improve_research
	completion_payment = 5
	per_unit = 1
	department_flag = SCIENCE
	
/datum/job_objective/department/science/improve_research/get_description()
	var/desc = "Improve research and stock the station with improved components and equipment. Depart the station along with the majority of the crew, you will recieve a bonus for every crewmember that is extracted in perfect health."
	if (completed)
		desc += " (All crewmembers extracted. [units_completed] of the crew departed in perfect health.)"
	else if(over_time)
		desc += " (Failed to extract every innocent crewmember, pay has been garnished)"
	return desc
	
/datum/job_objective/department/science/improve_research/calculate_basepay(var/datum/mind/M)
	var/pay = max(min(startingplayers * 25, 1500), 4000)
	var/rank = M.ranks["science"]
	if (M.assigned_job.flag == RD)
		rank = 5
	pay = round((pay / (6 - rank)), 1)
	return pay
	
	
/datum/job_objective/department/science/improve_research/calculate_pay(var/perfecthealth, var/datum/mind/M)
	var/pay = max(min(startingplayers * 25, 1500), 4000)
	var/rank = M.ranks["science"]
	if (M.assigned_job.flag == RD)
		rank = 5
	pay += (perfecthealth * 10)	
	pay = round((pay / (6 - rank)), 1)
	return pay	
	
			
