/datum/job_objective/department
	var/department_flag = 0
	var/bonus_payment = 0
	var/over_time = 0   				// Is it too late to complete the objective?
	var/bonus_objective = 0				// some objectives need to track 2 objectives
	
/datum/job_objective/department/security
/datum/job_objective/department/New()
/datum/job_objective/department/proc/calculate_basepay()
/datum/job_objective/department/proc/calculate_pay(var/perfecthealth, var/datum/mind/M)

/////////////////////////////////////////////////////////////////////////////////////////
// SECURITY
/////////////////////////////////////////////////////////////////////////////////////////
	
/datum/job_objective/department/security/maintain_order
	completion_payment = 5
	per_unit = 1
	department_flag = SECURITY
	
/datum/job_objective/department/security/maintain_order/get_description()
	var/desc = "Prevent illegal activity from becoming excessive. Watch out for crime alerts and respond as appropriate."
	if (completed)
		desc += " (Station remained safe for the duration of the shift.)"
	else if(over_time)
		desc += " (The station has been overrun with villany and the shift has to end early.)"
	return desc
	
/datum/job_objective/department/security/maintain_order/calculate_basepay(var/datum/mind/M)
	var/pay = min(max(startingplayers * 25, 1500), 4000)
	var/rank = M.ranks["medical"]
	if (M.assigned_job.flag == HOS)
		rank = 5
	pay = round((pay / 6 - rank), 1)
	return pay
	
	
/datum/job_objective/department/security/maintain_order/calculate_pay(var/perfecthealth, var/datum/mind/M)
	var/pay = min(max(startingplayers * 25, 1500), 4000)
	var/rank = M.ranks["medical"]
	if (M.assigned_job.flag == HOS)
		rank = 5
	pay += (perfecthealth * 10)	
	pay = round((pay / 6 - rank), 1)
	return pay	
	
		
/datum/job_objective/department/security/maintain_order/check_for_completion()

/////////////////////////////////////////////////////////////////////////////////////////
	