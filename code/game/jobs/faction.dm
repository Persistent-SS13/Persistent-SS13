var/list/code_phrases = list() // holds the responses so that no 2 factions use the same response.. they can still have the same signal though
var/list/code_names = list()
var/list/factions = list()

/proc/setup_faction_datums()
	factions = list()
	factions += new /datum/faction/syndicate

/proc/get_faction_datum(var/x) // feed this the faction uid
	switch(x)
		if("syndicate")
			return factions[1]
	return 0
	
/proc/generate_codename()
	var/prefix
	var/body
	var/codename
	
	prefix = pick(list("Alpha", "Beta", "Gamma", "Delta", "Epsilon", "Zeta", "Eta", "Theta", "Iota", "Lambda", "Mu", "Nu", "Xi", "Omicron", "Pi", "Rho", "Sigma", "Upsilon", "Phi", "Chi", "Psi", "Omega", "Red", "Blue", "Green", "Yellow", "Orange", "Purple", "Black", "White", "Grey", "Special"))	
	body = pick(list("Star", "Sun", "Moon", "Mars", "Venus", "Terra", "Gaia", "Jupiter", "Centauri", "Liberty", "Zen", "Truth", "Govern", "Neptune", "Status", "Niner", "Info", "Ego", "Sixty","Goose", "Wolf", "Snake", "Frog", "Render", "Seven", "One", "Two", "Three"))
	codename = (prefix + " " + body)
	if (codename in code_phrases)
		return generate_codename()
	else
		code_names += codename
		return codename
/proc/generate_codephrase()		
	var/func = pick("location", "person", "finance", "person", "location")
	var/trigger
	var/response
	switch(func)
		if("location")
			trigger = pick("Where is the nearest plasma conduit?", "Where is the nearest bathroom?", "Have you seen the new chapel?", "Have you seen the bar?", "Where is the nearest ATM?", "Do you want to come with me to the library?", "Where is arrivals?", "Where is the holodeck?")
			response = pick("Ask me in five minutes", "Ask me in twenty minutes", "Ask me tommorow", "Ask a clown", "Ask a mime", "Who do you think I am?", "Where are we right now?", "Ask the janitor", "I'm up to my neck in paperwork", "I'm too busy for that right now")
		if("person")
			var/firstname = pick("Terry", "Morris", "Griff", "Brian", "Bryce", "Moncia", "Donald", "Natalie", "Alvin", "Barbara", "Dalila", "Erick", "Gil", "Henriette", "Ivo", "Juliette", "Kiko", "Lorena", "Manuel", "Octave", "Raymond", "Velma", "Amanda", "Boris", "Cristina", "Doug", "Elida", "Fredo", "Simon", "Trudy")
			var/lastname = pick("Smith", "Johnson", "Williams", "Brown", "Jones", "Miller", "Davis", "Garcia", "Rodriguez", "Wilson", "Martinez", "Anderson", "Taylor", "Thomas", "Hernandez", "Moore", "Martin", "Jackson", "Thompson", "White", "Lopez", "Faulkner", "O'Brien", "Foster", "Grace", "Phillip", "Abdullah", "Bailey", "Brock", "Brown", "Greene") 
			var/name = (firstname + " " + lastname)
			trigger = pick("Have you heard about [name]?", "Have you seen [name]?", "Is [name] on the manifest?", "I thought I saw [name] in this department", "I thought I saw [name] in this section", "Where's [name]? He owes me money!")
			response = pick("I haven't seen [name] since yesterday", "I haven't seen [name] for a week", "I don't think so.. I know [name] very well.", "I would know, [name] is a good friend of mine.")
		if("finance")
			trigger = pick("Can you loan me 500 creds? I need a drink.", "Can you loan me 1500 creds? I need a doctor", "Can you give me 50 creds?", "Can you give me 100 creds?", "I need 200 creds.")
			response = pick("I need the creds for my sick mother.", "I need the creds for my new uniform", "I'm saving for a new hat.", "Ask a clown.", "Ask a mime.", "Will you follow me to the ATM?")
	if (response in code_phrases)
		return generate_code_phrase()
	else
		var/list/returnlist = list()
		code_phrases += response
		returnlist[trigger] = response
		return returnlist
	
/datum/faction
	var/faction_uid = 0
	var/list/members = list()	//should be everyone in the faction
	var/join_message = ""
	var/default_objects = 0 // a generic message to faction members when they dont have any objectives
	var/list/contract_items = 0
	var/list/objectives_list = 0
	var/list/current_objectives = 0
	var/uses_codenames = 0
	var/uses_codephrase = 0
	var/list/codephrase = list()
	var/name = ""
/datum/faction/New()
	if(uses_codephrase)
		get_codephrase()
	players = list()
/datum/faction/proc/get_codephrase()
	codephrase = generate_codephrase()
	
/datum/faction/proc/add_member(var/datum/mind/M)
	return 0
	
	
//LETS DO THIS
/datum/faction/syndicate
	faction_uid = "syndicate"
	name = "The Syndicate"
	objectives_list = list()
	current_objectives = list()
	uses_codenames = 1
	uses_codephrase = 1
	codephrase = list()
	join_message = "Welcome to the Syndicate. We are a collection of people intrested in ending the monopoly that Nanotransen has established over the terran economy. You should speak to your recruiter for more information about your new life."

	
	
/datum/faction/syndicate/add_member(var/datum/mind/M)
	if(istype(M))
		M.faction = src
		M.codename = generate_codename()
		
		for (var/obj/item/device/uplink/hidden/syndie/imp in world_syndicateuplinks)
			if(imp)
				if(istype(imp.loc, /obj/item))
					var/obj/it = imp.loc
					if(istype(it.loc, /mob/))
						var/mob/tmob = it.loc
						to_chat(tmob, "<b>**Your Syndicate Implant buzzes**</b> <br>Welcome <b>[M.name]</b> to the Syndicate. <br><br>They can now be referred to as <b>[M.codename]</b> in matters of secrecy. <br>Make sure they are instructed in the disiplines of a syndicate operative.")					
						
	else
		return 0	
	
	