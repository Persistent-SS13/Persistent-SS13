/mob/living
	see_invisible = SEE_INVISIBLE_LIVING

	//Health and life related vars
	var/maxHealth = 100 //Maximum health that should be possible.
	var/health = 100 	//A mob's health

	//persistance
	var/mind_storage = list() // this stores implants so they can be saved and transferred into the brain
	var/seen = list() // this stores what has been shown to the mob so that you cant flood someones chat with descriptions
	
	var/stamina_acting = 0 // used when punishing players for over-pushing stamina!
	var/stamina_notified = 0 // used to warn players about pushing stamina
	
	var/will_acting = 0 // used for making players go crazy with stress
	var/will_notified = 0 // used to warn players
	//
	//Damage related vars, NOTE: THESE SHOULD ONLY BE MODIFIED BY PROCS
	var/bruteloss = 0	//Brutal damage caused by brute force (punching, being clubbed by a toolbox ect... this also accounts for pressure damage)
	var/oxyloss = 0	//Oxygen depravation damage (no air in lungs)
	var/toxloss = 0	//Toxic damage caused by being poisoned or radiated
	var/fireloss = 0	//Burn damage caused by being way too hot, too cold or burnt.
	var/cloneloss = 0	//Damage caused by being cloned or ejected from the cloner early. slimes also deal cloneloss damage to victims
	var/brainloss = 0	//'Retardation' damage caused by someone hitting you in the head with a bible or being infected with brainrot.
	var/staminaloss = 0 //Stamina damage, or exhaustion. You recover it slowly naturally, and are stunned if it gets too high. Holodeck and hallucinations deal this.
	var/focusloss = 0 // PERSISTANT EDIT! focus damage for mental exhaustian (i know i think or two about that)
	
	var/hallucination = 0 //Directly affects how long a mob will hallucinate for


	var/last_special = 0 //Used by the resist verb, likely used to prevent players from bypassing next_move by logging in/out.

	//Allows mobs to move through dense areas without restriction. For instance, in space or out of holder objects.
	var/incorporeal_move = 0 //0 is off, 1 is normal, 2 is for ninjas.

	var/now_pushing = null

	var/atom/movable/cameraFollow = null

	var/on_fire = 0 //The "Are we on fire?" var
	var/fire_stacks = 0 //Tracks how many stacks of fire we have on, max is usually 20

	var/update_slimes = 1
	var/implanting = 0 //Used for the mind-slave implant
	var/silent = 0 		//Can't talk. Value goes down every life proc. //NOTE TO FUTURE CODERS: DO NOT INITIALIZE NUMERICAL VARS AS NULL OR I WILL MURDER YOU.
	var/floating = 0
	var/nightvision = 0

	var/bloodcrawl = 0 //0 No blood crawling, 1 blood crawling, 2 blood crawling+mob devour
	var/holder = null //The holder for blood crawling

	var/ventcrawler = 0 //0 No vent crawling, 1 vent crawling in the nude, 2 vent crawling always
	var/list/icon/pipes_shown = list()
	var/last_played_vent

	var/step_count = 0

	var/list/butcher_results = null

	var/list/weather_immunities = list()

	var/list/surgeries = list()	//a list of surgery datums. generally empty, they're added when the player wants them.

	var/gene_stability = DEFAULT_GENE_STABILITY

	