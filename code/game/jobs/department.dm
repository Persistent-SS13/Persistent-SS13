/datum/department
	var/department_flag = 0
	var/list/players = list()		//should be everyone in the department
	var/list/objectives = list() 	//list of all objectives for the department
	var/datum/money_account/account
	var/name = ""
	var/datum/mind/leader
	var/conglo_amount = 0
	var/tantiline_amount = 0
	var/plasma_amount = 0
	var/orichilum_amount = 0
	map_storage_saved_vars = "conglo_amount;tantiline_amount;plasma_amount;orichilum_amount;account"
	var/account_name
/datum/department/New()
	account = department_accounts[account_name]
/datum/department/after_load()
	department_accounts[account_name] = account
/////////////////////////////////////////////////////////////////////////////////////////
// MEDICAL
/////////////////////////////////////////////////////////////////////////////////////////
	
//LETS DO THIS
/datum/department/medical
	department_flag = MEDICAL
	name = "Medical Department"
	objectives = list(new /datum/job_objective/department/medical/extract_crewmembers)
	account_name = "Medical"
/datum/department/security
	department_flag = SECURITY
	name = "Station Security"
	account_name = "Security"
/datum/department/cargo
	department_flag = CARGO
	name = "Cargo Department"
	account_name = "Cargo"
/datum/department/science
	department_flag = SCIENCE
	name = "Science Department"
	account_name = "Science"
/datum/department/engineering
	department_flag = ENGINEERING
	name = "Engineering Department"
	account_name = "Engineering"
/datum/department/command
	department_flag = COMMAND
	name = "Command Staff"
	account_name = "Command"
/datum/department/civilian
	department_flag = SUPPORT
	name = "Civilians"
	account_name = "Civilian"