/datum/department
	var/department_flag = 0
	var/list/players = list()		//should be everyone in the department
	var/list/objectives = list() 	//list of all objectives for the department
	var/name = ""
	var/datum/mind/leader
	var/conglo_amount = 0
	var/tantiline_amount = 0
	var/plasma_amount = 0
	var/orichilum_amount = 0
	
/////////////////////////////////////////////////////////////////////////////////////////
// MEDICAL
/////////////////////////////////////////////////////////////////////////////////////////
	
//LETS DO THIS
/datum/department/medical
	department_flag = MEDICAL
	name = "Medical Department"
	objectives = list(new /datum/job_objective/department/medical/extract_crewmembers)
	
/datum/department/security
	department_flag = SECURITY
	name = "Station Security"
	
/datum/department/cargo
	department_flag = CARGO
	name = "Cargo Department"
	
/datum/department/science
	department_flag = SCIENCE
	name = "Science Department"
	
/datum/department/engineering
	department_flag = ENGINEERING
	name = "Engineering Department"
		
/datum/department/command
	department_flag = COMMAND
	name = "Command Staff"
	
/datum/department/civilian
	department_flag = SUPPORT
	name = "Civilians"
	