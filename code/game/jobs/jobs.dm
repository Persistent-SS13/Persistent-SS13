
var/const/ENGINEERING		=(1<<0)

var/const/CHIEF				=(1<<0)
var/const/ENGINEER			=(1<<1)
var/const/ATMOSTECH			=(1<<2)


var/const/MEDICAL			=(1<<1)

var/const/CMO				=(1<<0)
var/const/CHEMIST			=(1<<1)
var/const/DOCTOR			=(1<<2)
var/const/PSYCHIATRIST		=(1<<3)
var/const/PARAMEDIC			=(1<<4)


var/const/SUPPORT			=(1<<2)

var/const/CIVILIAN			=(1<<0)
var/const/BARTENDER			=(1<<1)
var/const/BOTANIST			=(1<<2)
var/const/CHEF				=(1<<3)
var/const/JANITOR			=(1<<4)
var/const/LIBRARIAN			=(1<<5)
var/const/LAWYER			=(1<<6)
var/const/CHAPLAIN			=(1<<7)
var/const/CLOWN				=(1<<8)
var/const/MIME				=(1<<9)


var/const/SCIENCE			=(1<<3)

var/const/RD				=(1<<0)
var/const/SCIENTIST			=(1<<1)
var/const/GENETICIST		=(1<<2)
var/const/VIROLOGIST		=(1<<3)
var/const/ROBOTICIST		=(1<<4)


var/const/SECURITY			=(1<<4)

var/const/HOS				=(1<<0)
var/const/WARDEN			=(1<<1)
var/const/DETECTIVE			=(1<<2)
var/const/OFFICER			=(1<<3)
var/const/AI				=(1<<4)
var/const/CYBORG			=(1<<5)
var/const/CENTCOM			=(1<<6)

var/const/COMMAND			=(1<<5)

var/const/CAPTAIN			=(1<<0)
var/const/HOP				=(1<<1)


var/const/CARGO				=(1<<6)

var/const/QUARTERMASTER		=(1<<0)
var/const/CARGOTECH			=(1<<1)
var/const/MINER				=(1<<2)



var/const/KARMA				=(1<<7)

var/const/NANO				=(1<<0)
var/const/BLUESHIELD		=(1<<1)
var/const/BARBER			=(1<<3)
var/const/MECHANIC			=(1<<4)
var/const/BRIGDOC			=(1<<5)
var/const/JUDGE				=(1<<6)
var/const/PILOT				=(1<<7)

var/const/ENGSEC = 0
var/const/MEDSCI = 0
var/list/department_datums = list()
var/list/all_certs = list()
var/list/certs_by_uid = list()
var/startingplayers = 0

var/list/assistant_occupations = list(
)


var/list/command_positions = list(
	"Captain",
	"Head of Personnel",
	"Head of Security",
	"Chief Engineer",
	"Research Director",
	"Chief Medical Officer"
)

// 	"Chief Engineer",
var/list/engineering_positions = list(
	"Station Engineer",
	"Life Support Specialist",
	"Mechanic"
)

// 	"Chief Medical Officer",
var/list/medical_positions = list(
	"Medical Doctor",
	"Geneticist",
	"Psychiatrist",
	"Chemist",
	"Virologist",
	"Paramedic"
)
// 	"Chief Medical Officer",
var/list/science_positions = list(
	"Scientist",
	"Geneticist",	//Part of both medical and science
	"Roboticist",
)

//BS12 EDIT
var/list/support_positions = list(
	"Bartender",
	"Botanist",
	"Chef",
	"Janitor",
	"Librarian",
	"Quartermaster",
	"Cargo Technician",
	"Shaft Miner",
	"Internal Affairs Agent",
	"Chaplain",
	"Clown",
	"Mime",
	"Barber",
	"Magistrate",
	"Nanotrasen Representative",
	"Blueshield"
)
//	"Head of Personnel",
//	"Quartermaster",

var/list/supply_positions = list(
	"Cargo Technician",
	"Shaft Miner"
)

var/list/service_positions = support_positions - supply_positions + list("Head of Personnel")

// 	"Head of Security",
var/list/security_positions = list(
	"Warden",
	"Detective",
	"Security Officer",
	"Brig Physician",
	"Security Pod Pilot"
)


var/list/civilian_positions = list(
	"Civilian",
	"Unassigned Intern"
)

var/list/nonhuman_positions = list(
	"AI",
	"Cyborg",
	"Drone",
	"pAI"
)

var/list/whitelisted_positions = list(
	"Blueshield",
	"Nanotrasen Representative",
	"Barber",
	"Mechanic",
	"Brig Physician",
	"Magistrate",
	"Security Pod Pilot",
)

/proc/get_department_jobs(var/a)
	var/list/job_list = list()
	for (var/datum/cert/job in get_cert_datums())
		if(job.department_flag == a)
			job_list += job

	return job_list

/proc/setup_cert_datums()
	all_certs = get_cert_datums()
	certs_by_uid = list()
	for(var/datum/cert/J in all_certs)
		certs_by_uid["[J.uid]"] = J
		
/proc/setup_department_datums()
	if(!department_datums || !department_datums.len)
		department_datums = list()
		department_datums += new /datum/department/medical 
		department_datums += new /datum/department/security 
		department_datums += new /datum/department/cargo 
		department_datums += new /datum/department/science 
		department_datums += new /datum/department/civilian 
		department_datums += new /datum/department/command
		department_datums += new /datum/department/engineering
	
	
/proc/get_department_datum(var/a)
	var/x = 1
	switch(a)
		if(MEDICAL)
			x = 1
		if(SECURITY)
			x = 2
		if(CARGO)
			x = 3
		if(SCIENCE)
			x = 4
		if(SUPPORT)
			x = 5
		if(COMMAND)
			x = 6
		if(ENGINEERING)
			x = 7
	return department_datums[x]

	
/proc/get_department_promotions(var/a, var/datum/cert/job = null)
	var/list/promotions = 0
	if (istype(job) && (istype(job.promotion_override)))
		return job.promotion_override
	switch(a)
		if(MEDICAL)
			promotions = list(
			"Medical Intern",
			"Resident Physician",
			"Medical Doctor",
			"Attending Physician"
			)
		if(ENGINEERING)
			promotions = list(
			"Engineer Trainee",
			"Apprentice Engineer",
			"Journeyman Engineer",
			"Master Engineer"
			)
		if(CARGO)
			promotions = list(
			"Cargo Rookie",
			"Cargo Technician",
			"Supply Technician",
			"Supply Officer"
			)	
		if(SUPPORT)
			return 0
		if(SCIENCE)
			promotions = list(
			"Science Intern",
			"Scientist",
			"Researcher",
			"Professor"
			)		
		if(SECURITY)
			promotions = list(
			"Security Cadet",
			"Security Officer",
			"Security Corporal",
			"Security Sergeant"
			)	
		if(COMMAND)
			return 0
	return promotions
	

/proc/get_default_title(var/a, var/datum/cert/job, var/need_default = 0)
	var/list/promotions = 0
	if (!istype(job))
		return "ERROR"
	if(text2num(a))
		a = text2num(a)
	if(!job.is_default && !need_default)
		if (istype(job.promotion_override) && (job.promotion_override.len >= a))
			return job.promotion_override[a]
		return job.title		
		
	var/dept = job.department_flag
	switch(dept)
		if(MEDICAL)
			promotions = list(
			"Medical Intern",
			"Resident Physician",
			"Medical Doctor",
			"Attending Physician"
			)
		if(ENGINEERING)
			promotions = list(
			"Engineer Trainee",
			"Apprentice Engineer",
			"Journeyman Engineer",
			"Master Engineer"
			)
		if(CARGO)
			promotions = list(
			"Cargo Rookie",
			"Cargo Technician",
			"Supply Technician",
			"Supply Officer"
			)	
		if(SUPPORT)
			return job.title
		if(SCIENCE)
			promotions = list(
			"Science Intern",
			"Scientist",
			"Researcher",
			"Professor"
			)		
		if(SECURITY)
			promotions = list(
			"Security Cadet",
			"Security Officer",
			"Security Corporal",
			"Security Sergeant"
			)	
		if(COMMAND)
			return job.title
	if (istype(promotions) && (promotions.len >= a))
		return promotions[a]
	return job.title
	
	

/proc/change_certification(var/datum/mind/M, var/datum/cert/J)
	var/alt_title = M.role_alt_title
	if (J.uid == "intern")
		to_chat(M.current, "<B>You have been unassigned from your department!</B>")
		to_chat(M.current, "<b>Try to get assigned to a different department or gain a civilian certification. If this was done without your consent or proper cause you can appeal it to Nanotrasen senior staff.</b>")		
	else
		var/display_name = get_default_title(M.ranks[to_strings(J.department_flag)], J)
		to_chat(M.current, "<B>You have been reassigned to [alt_title ? alt_title : display_name].</B>")
		to_chat(M.current, "<b>As an [alt_title ? alt_title : display_name] you answer directly to [J.supervisors]. Work with your colleagues to complete your quota and get paid!</b>")
	if(M.spawned_id)
		M.spawned_id.access |= J.get_access()
		M.spawned_id.rank = J
		M.spawned_id.assignment = get_default_title(M.ranks[to_strings(J.department_flag)], J)
		M.spawned_id.name = "[M.spawned_id.registered_name]'s ID Card ([M.spawned_id.assignment])"

	var/datum/department/department = get_department_datum(J.department_flag)	
	var/objcount = 1
	data_core.manifest_modify(M.current.real_name, M.spawned_id.assignment, J.title)
	for(var/datum/job_objective/department/jeb in department.objectives)
		to_chat(M.current, "<b><LI><B>Task #[objcount]</B>: [jeb.get_description()]</LI>")
		objcount += 1

						
						
/proc/notify_promotion(var/datum/mind/M, var/datum/cert/J, var/a)
	var/P
	if (istype(J.promotion_override) && (J.promotion_override.len >= a))
		P = J.promotion_override[a]
	else
		P = get_default_title(a, J, 1)
	to_chat(M.current, "<B>Congratulations, you've been promoted to [P]</B>")
	to_chat(M.current, "<b>Enjoy the additional respect from your colleagues, as well as a 20% bonus in pay for successfully completing your quota, effective immediately.</b>")



/proc/notify_demotion(var/datum/mind/M, var/datum/cert/J, var/a)
	var/P
	if (istype(J.promotion_override) && (J.promotion_override.len >= a))
		P = J.promotion_override[a]
	else
		P = get_default_title(a, J, 1)
	to_chat(M.current, "<B>You have been demoted to [P]</B>")
	to_chat(M.current, "<b>You could try to appeal the demotion with an Internal Affairs agent, a Nanotransen official, or simply do you job better next time.</b>")


/proc/get_standard_departments()
	var/list/departments = list(
	MEDICAL,
	ENGINEERING,
	CARGO,
	SCIENCE,
	SECURITY
	)
	return departments

/proc/to_bitflags(var/a)
	switch(a)
		if("medical")
			return MEDICAL
		if("science")
			return SCIENCE
		if("cargo")
			return CARGO
		if("support")
			return SUPPORT
		if("security")
			return SECURITY
		if("command")
			return COMMAND
		if("engineering")
			return ENGINEERING
/proc/to_strings(var/a)
	switch(a)
		if(MEDICAL)
			return "medical"
		if(SCIENCE)
			return "science"
		if(CARGO)
			return "cargo"
		if(SUPPORT)
			return "support"
		if(SECURITY)
			return "security"
		if(COMMAND)
			return "command"
		if(ENGINEERING)
			return "engineering"
/proc/guest_jobbans(var/job)
	return (job in whitelisted_positions)

/proc/get_job_datums()
	var/list/occupations = list()
	var/list/all_jobs = typesof(/datum/job)

	for(var/A in all_jobs)
		var/datum/job/job = new A()
		if(!job)	continue
		occupations += job

	return occupations

/proc/get_cert_datums()
	var/list/occupations = list()
	var/list/all_jobs = typesof(/datum/cert)

	for(var/A in all_jobs)
		var/datum/cert/job = new A()
		if(!job)	continue
		occupations += job

	return occupations
	
	
/proc/get_alternate_titles(var/job)
	var/list/jobs = get_job_datums()
	var/list/titles = list()

	for(var/datum/job/J in jobs)
		if(!J)	continue
		if(J.title == job)
			titles = J.alt_titles

	return titles

