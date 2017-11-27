

var/list/preferences_datums = list()

var/global/list/special_role_times = list( //minimum age (in days) for accounts to play these roles
	ROLE_PAI = 0,
	ROLE_POSIBRAIN = 0,
	ROLE_GUARDIAN = 0,
	ROLE_TRAITOR = 7,
	ROLE_CHANGELING = 14,
	ROLE_SHADOWLING = 14,
	ROLE_WIZARD = 14,
	ROLE_REV = 14,
	ROLE_VAMPIRE = 14,
	ROLE_BLOB = 14,
	ROLE_REVENANT = 14,
	ROLE_OPERATIVE = 21,
	ROLE_CULTIST = 21,
	ROLE_RAIDER = 21,
	ROLE_ALIEN = 21,
	ROLE_DEMON = 21,
	ROLE_SENTIENT = 21,
// 	ROLE_GANG = 21,
	ROLE_BORER = 21,
	ROLE_NINJA = 21,
	ROLE_MUTINEER = 21,
	ROLE_MALF = 30,
	ROLE_ABDUCTOR = 30,
)

/proc/player_old_enough_antag(client/C, role)
	if(available_in_days_antag(C, role) == 0)
		return 1	//Available in 0 days = available right now = player is old enough to play.
	return 0

/proc/available_in_days_antag(client/C, role)
	if(!C)
		return 0
	if(!role)
		return 0
	if(!config.use_age_restriction_for_antags)
		return 0
	if(!isnum(C.player_age))
		return 0 //This is only a number if the db connection is established, otherwise it is text: "Requires database", meaning these restrictions cannot be enforced
	var/minimal_player_age_antag = special_role_times[num2text(role)]
	if(!isnum(minimal_player_age_antag))
		return 0

	return max(0, minimal_player_age_antag - C.player_age)

/proc/check_client_age(client/C, var/days) // If days isn't provided, returns the age of the client. If it is provided, it returns the days until the player_age is equal to or greater than the days variable
	if(!days)
		return C.player_age
	else
		return max(0, days - C.player_age)
	return 0

//used for alternate_option
#define GET_RANDOM_JOB 0
#define BE_CIVILIAN 1
#define RETURN_TO_LOBBY 2

#define MAX_SAVE_SLOTS 3 // Save slots for regular players
#define MAX_SAVE_SLOTS_MEMBER 3 // Save slots for BYOND members

#define MAX_GEAR_COST config.max_loadout_points

#define TAB_CHAR 0
#define TAB_GAME 1
#define TAB_GEAR 2

#define STAT_GRIT 1
#define STAT_FORTITUDE 2
#define STAT_REFLEX 3
#define STAT_CREATIVITY 4
#define STAT_FOCUS 5
/datum/preferences
	//doohickeys for savefiles
//	var/path
	var/default_slot = 1				//Holder so it doesn't default to slot 1, rather the last one used
//	var/savefile_version = 0
	var/max_save_slots = MAX_SAVE_SLOTS

	//non-preference stuff
	var/warns = 0
	var/muted = 0
	var/last_ip
	var/last_id

	//game-preferences
	var/lastchangelog = ""				//Saved changlog filesize to detect if there was a change
	var/ooccolor = "#b82e00"
	var/be_special = list()				//Special role selection
	var/UI_style = "Midnight"
	var/nanoui_fancy = FALSE
	var/toggles = TOGGLES_DEFAULT
	var/sound = SOUND_DEFAULT
	var/show_ghostitem_attack = TRUE
	var/UI_style_color = "#ffffff"
	var/UI_style_alpha = 255


	//character preferences
	var/real_name = ""						//our character's name
	var/be_random_name = 0				//whether we are a random name every round
	var/gender = MALE					//gender of character (well duh)
	var/age = 30						//age of character
	var/spawnpoint = "Arrivals Shuttle" //where this character will spawn (0-2).
	var/b_type = "A+"					//blood type (not-chooseable)
	var/underwear = 0					//underwear type
	var/undershirt = 0					//undershirt type
	var/socks = "Nude"					//socks type
	var/backbag = 2						//backpack type
	var/ha_style = "None"				//Head accessory style
	var/r_headacc = 0					//Head accessory colour
	var/g_headacc = 0					//Head accessory colour
	var/b_headacc = 0					//Head accessory colour
	var/m_style = "None"				//Marking style
	var/r_markings = 0					//Marking colour
	var/g_markings = 0					//Marking colour
	var/b_markings = 0					//Marking colour
	var/h_style = "Bald"				//Hair type
	var/r_hair = 0						//Hair color
	var/g_hair = 0						//Hair color
	var/b_hair = 0						//Hair color
	var/f_style = "Shaved"				//Face hair type
	var/r_facial = 0					//Face hair color
	var/g_facial = 0					//Face hair color
	var/b_facial = 0					//Face hair color
	var/s_tone = 0						//Skin tone
	var/r_skin = 0						//Skin color
	var/g_skin = 0						//Skin color
	var/b_skin = 0						//Skin color
	var/r_eyes = 0						//Eye color  
	var/g_eyes = 0						//Eye color
	var/b_eyes = 0						//Eye color
	var/species = "Human"
	var/language = "None"				//Secondary language
	var/current_status = null					//Char dead or lost?
	var/body_accessory = "None"
	var/account = list()
	var/energy_creds = 0
	var/speciesprefs = 0//I hate having to do this, I really do (Using this for oldvox code, making names universal I guess
	var/cert_whitelist = null
	var/slot_w_uniform_pref = 0
	var/slot_wear_suit_pref = 0
	var/slot_shoes_pref = ""
	var/slot_gloves_pref = 0
	var/slot_l_ear_pref = 0
	var/slot_glasses_pref = 0
	var/slot_wear_mask_pref = 0
	var/slot_head_pref = 0
	var/slot_belt_pref = 0
	var/slot_r_store_pref = 0
	var/slot_l_store_pref = 0
	var/slot_back_pref = 0
	var/slot_wear_id_pref = 0
	var/slot_wear_pda_pref = 0
	var/slot_handcuffed_pref = 0
	var/slot_s_store_pref = 0
	var/slot_legcuffed_pref = 0
	var/slot_r_ear_pref = 0
	var/slot_r_hand_pref = 0
	var/slot_l_hand_pref = 0
	var/slot_underwear_pref = 0
	var/slot_undershirt_pref = 0
	var/list/brain = list()
	var/storage = 0

	var/primary_cert = null
	var/list/certs = list()
	var/cert_title = null
	var/list/department_ranks = list()
	var/faction = ""
	var/list/UI
	var/list/SE
	var/list/SE_structure
	var/current_body = 0
	var/body_type = 0 // 1 = human 2 = MMI 3 = robot
	var/mob/living/carbon/human/preview_model
	var/nameChose = 0
	var/list/male_underwear = list()
	var/list/female_underwear = list()
	var/list/undershirts = list()
	var/list/female_undershirts = list()
	var/list/backbaglist = list()
	var/list/underlist = list()
	var/jumpsuit = "None"
	var/show_under = 0 // toggle this to have the characters underwear show
	var/prompts/input/inp = 0
	var/create_menu = 1 // this controls the character creation menu
	var/stat_Grit = 0
	var/stat_Fortitude = 0
	var/stat_Reflex = 0
	var/stat_Creativity = 0
	var/stat_Focus = 0
	var/stats_left = 0
	var/ambition = 0 // 1 - wealth, 2 - recreation, 3 - power
		//Mob preview
	var/icon/preview_icon = null
	var/icon/preview_icon_front = null
	var/icon/preview_icon_side = null
	var/list/preview_icons[]
	var/list/minds_list[]
		//Jobs, uses bitflags
	var/job_support_high = 0
	var/job_support_med = 0
	var/job_support_low = 0

	var/job_medsci_high = 0
	var/job_medsci_med = 0
	var/job_medsci_low = 0

	var/job_engsec_high = 0
	var/job_engsec_med = 0
	var/job_engsec_low = 0

	var/job_karma_high = 0
	var/job_karma_med = 0
	var/job_karma_low = 0

	var/job_flags = list()
	var/job_primary = ""

	//Keeps track of preferrence for not getting any wanted jobs
	var/alternate_option = 0

	// maps each organ to either null(intact), "cyborg" or "amputated"
	// will probably not be able to do this for head and torso ;)
	var/list/organ_data = list()
	var/list/rlimb_data = list()





	var/list/player_alt_titles = new()		// the default name of a job like "Medical Doctor"
//	var/accent = "en-us"
//	var/voice = "m1"
//	var/pitch = 50
//	var/talkspeed = 175
	var/flavor_text = ""
	var/med_record = ""
	var/sec_record = ""
	var/gen_record = ""
	var/disabilities = 0
	var/slot = 0
	var/nanotrasen_relation = "Neutral"

	// 0 = character settings, 1 = game preferences
	var/current_tab = TAB_CHAR

		// OOC Metadata:
	var/metadata = ""
	var/slot_name = ""

	// Whether or not to use randomized character slots
	var/randomslot = 0

	// jukebox volume
	var/volume = 100

	// BYOND membership
	var/unlock_content = 0

	//Gear stuff
	var/list/gear = list()
	var/gear_tab = "General"

/datum/preferences/New(client/C)
	b_type = pick(4;"O-", 36;"O+", 3;"A-", 28;"A+", 1;"B-", 20;"B+", 1;"AB-", 5;"AB+")
	male_underwear += new /obj/item/clothing/underwear/blackspeedo()
	male_underwear += new /obj/item/clothing/underwear/blackboxers()
	male_underwear += new /obj/item/clothing/underwear/greyspeedo()
	male_underwear += new /obj/item/clothing/underwear/greyboxers()
	female_underwear += new /obj/item/clothing/underwear/black_bra()
	female_underwear += new /obj/item/clothing/underwear/red_bra()
	female_underwear += new /obj/item/clothing/underwear/white_bra()
	female_underwear += new /obj/item/clothing/underwear/black_nightgown()
	undershirts += new /obj/item/clothing/undershirt/black()
	undershirts += new /obj/item/clothing/undershirt/blue()
	undershirts += new /obj/item/clothing/undershirt/green()
	undershirts += new /obj/item/clothing/undershirt/lovent()
	female_undershirts += new /obj/item/clothing/undershirt/tankdarkblack()
	female_undershirts += new /obj/item/clothing/undershirt/tankshortred()
	female_undershirts += new /obj/item/clothing/undershirt/tankshortwhite()
	backbaglist += new /obj/item/weapon/storage/backpack()
	backbaglist += new /obj/item/weapon/storage/backpack/satchel()
	backbaglist += new /obj/item/weapon/storage/backpack/duffel()
	underlist += new /obj/item/clothing/under/color/lightblue()
	underlist += new /obj/item/clothing/under/color/aqua()
	underlist += new /obj/item/clothing/under/color/blue()
	underlist += new /obj/item/clothing/under/color/grey()
	underlist += new /obj/item/clothing/under/color/lightgreen()
	underlist += new /obj/item/clothing/under/color/lightbrown()
	if(istype(C))
		if(!IsGuestKey(C.key))
			unlock_content = C.IsByondMember()
			if(unlock_content)
				max_save_slots = MAX_SAVE_SLOTS_MEMBER
	var/loaded_preferences_successfully = load_preferences(C)
	if(loaded_preferences_successfully)
		return
	else
		save_preferences(C)
		return
	// populate underwear lists
	
	
/datum/preferences/proc/color_square(r, g, b)
	return "<span style='font-face: fixedsys; background-color: #[num2hex(r, 2)][num2hex(g, 2)][num2hex(b, 2)]; color: #[num2hex(r, 2)][num2hex(g, 2)][num2hex(b, 2)]'>___</span>"

/datum/preferences/proc/SlotSelect(mob/user)
	var/DBQuery/query = dbcon.NewQuery("SELECT slot,real_name FROM [format_table_name("character")] WHERE ckey='[user.ckey]' ORDER BY slot")

	var/dat = "<body>"
	dat += "<tt><center>"
	dat += "<b>Select the slot to save to</b><hr>"
	var/name

	for(var/i=1, i<=max_save_slots, i++)
		if(!query.Execute())
			var/err = query.ErrorMsg()
			log_game("SQL ERROR during character slot loading. Error : \[[err]\]\n")
			message_admins("SQL ERROR during character slot loading. Error : \[[err]\]\n")
			return
		while(query.NextRow())
			if(i==text2num(query.item[1]))
				name =  query.item[2]
		if(!name)
			name = "Open Slot"
			dat += "<a href='?_src_=prefs;preference=chooseslot;num=[i];'>[name]</a><br>"
		else
			dat += "<a href='?_src_=prefs;preference=chooseinvalid;num=[i];'>[name]</a><br>"
		name = null

	dat += "<hr>"
	dat += "<a href='byond://?src=\ref[user];preference=close_load_dialog'>Close</a><br>"
	dat += "</center></tt>"
//		user << browse(dat, "window=saves;size=300x390")
	var/datum/browser/popup = new(user, "saves", "<div align='center'>Character Saves</div>", 300, 390)
	popup.set_content(dat)
	popup.open(0)


/datum/preferences/proc/CharSelect(mob/user)
	var/DBQuery/query = dbcon.NewQuery("SELECT slot,real_name FROM [format_table_name("characters")] WHERE ckey='[user.ckey]' ORDER BY slot")

	var/dat = "<body>"
	dat += "<tt><center>"
	dat += "<b>Select the character to load.</b><hr>"
	var/name
	var/c_status
	for(var/i=1, i<=max_save_slots, i++)
		if(!query.Execute())
			var/err = query.ErrorMsg()
			log_game("SQL ERROR during character slot loading. Error : \[[err]\]\n")
			message_admins("SQL ERROR during character slot loading. Error : \[[err]\]\n")
			return
		while(query.NextRow())
			if(i==text2num(query.item[1]))
				if(query.item[3] == "dead")
					name =  query.item[2] + " (DEAD)"
					c_status = "dead"
				else if(query.item[3] == "lost")
					name =  query.item[2] + " (M.I.A)"
					c_status = "lost"
				else
					name =  query.item[2]

		if(!name)
			name = "Open Slot"
			dat += "<a href='?_src_=prefs;preference=choosecharinvalid;num=[i];'>[name]</a><br>"
		else if(c_status == "dead")
			dat += "<a href='?_src_=prefs;preference=changeslotdead;num=[i];'>[name]</a><br>"
		else if(c_status == "lost")
			dat += "<a href='?_src_=prefs;preference=changeslotlost;num=[i];'>[name]</a><br>"
		else
			dat += "<a href='?_src_=prefs;preference=choosechar;num=[i];'>[name]</a><br>"
		name = null
		c_status = null
	dat += "<hr>"
	dat += "<a href='byond://?src=\ref[user];preference=close_load_dialog'>Close</a><br>"
	dat += "</center></tt>"
//		user << browse(dat, "window=saves;size=300x390")
	var/datum/browser/popup = new(user, "saves", "<div align='center'>Character Saves</div>", 300, 390)
	popup.set_content(dat)
	popup.open(0)
/datum/preferences/Topic(href, href_list)
	var/mob/user = usr
	if(href_list["choice"])
		switch(href_list["choice"])
			if("cert")
				var/list/ch = list()
				var/list/nam = list()
				for(var/Co in subtypesof(/datum/cert))
					var/datum/cert/C = new Co()
					if (C.uid == "intern")
						ch[C.title] = C.uid
						nam += C.title
						nam += "Cancel"
						continue
					for(var/id in cert_whitelist)
						if (C.uid == id)
							nam += C.title
							ch[C.title] = C.uid
				if (!isemptylist(nam))
					var/choo = "Intern"
					if(inp) del inp
					inp = new()
					var/new_cert = inp.option(usr,"Pick your starting position","Character Creation","Cancel","",nam)//input("Pick your starting role. Access to additional starts can be gained through experience", "Character Generation", "intern") as anything in nam
					if (new_cert == "Cancel")
						return 0
					primary_cert = ch[inp] // WEW LADS
					CharacterCreateProc(user, 1)
				else
					primary_cert = "intern"
				
			if("choose_name")
				if(inp) del inp
				inp = new()
				var/t_name = inp.option(usr,"Choose your character's name","Character Creation",null,"text")//var/raw_name = input(user, "Choose your character's name:", "New Character") as text|null
				if(!isnull(t_name)) // Check to ensure that the user entered text (rather than cancel.)
					var/new_name = reject_bad_name(t_name, min_length = 5)
					var/found = 0
					if(new_name)
						if(found)
							to_chat(user, "<font color='red'>Invalid name. A character with that name already exists.</font>")
							nameChose = 2
						else
							real_name = new_name
							nameChose = 1
						CharacterCreateProc(user, 1)
					else
						to_chat(user, "<font color='red'>Invalid name. Your name should be at least 5 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z, -, ' and .</font>")
		
			if("randomize_name")
				real_name = random_name(gender,"Human") // Persistant edit. Human names for now...
				nameChose = 1
				CharacterCreateProc(user, 1)
			if("toggle_gender")
				if(gender == MALE)
					gender = FEMALE
				else
					gender = MALE
				preview_model.change_gender(gender)
				var/obj/item/organ/external/head/H = preview_model.get_organ("head")
				h_style = random_hair_style(gender, species)
				f_style = random_facial_hair_style(gender, species)
				if(H)	
					H.h_style = h_style
					H.f_style = f_style
				if(gender == MALE)
					var/obj/ob = pick(male_underwear)
					preview_model.underwear = ob
					underwear = ob.name
					var/obj/obb = pick(undershirts)
					preview_model.undershirt = obb
					undershirt = obb.name
				else
					var/obj/ob = pick(female_underwear)
					preview_model.underwear = ob
					underwear = ob.name
					var/obj/obb = pick(female_undershirts)
					preview_model.undershirt = obb
					undershirt = obb.name
				CharacterCreateProc(user, 1)
			if("choose_age")
				if(inp) del inp
				inp = new()
				var/new_age = inp.option(usr,"Choose your character's age","Character Creation",null,"num|null")
				if(new_age)
					age = max(min( round(text2num(new_age)), AGE_MAX),AGE_MIN)
					CharacterCreateProc(user, 1)
			if("choose_species")
				var/list/new_species = list("Human", "Tajaran", "Skrell", "Unathi", "Diona", "Vulpkanin")
				var/prev_species = species

				if(config.usealienwhitelist) //If we're using the whitelist, make sure to check it!
					for(var/S in whitelisted_species)
						if(is_alien_whitelisted(user,S))
							new_species += S
				else //Not using the whitelist? Aliens for everyone!
					new_species += whitelisted_species

				if(inp) del inp
				inp = new()
				var/t_species = inp.option(usr,"Choose your character's species","Character Creation",null,"",new_species)//species = input("Please select a species", "Character Generation", null) in new_species
				if(t_species)
					species = t_species
				if(prev_species != species)
					//grab one of the valid hair styles for the newly chosen species
					var/list/valid_hairstyles = list()
					for(var/hairstyle in hair_styles_list)
						var/datum/sprite_accessory/S = hair_styles_list[hairstyle]
						if(gender == MALE && S.gender == FEMALE)
							continue
						if(gender == FEMALE && S.gender == MALE)
							continue
						if(!(species in S.species_allowed))
							continue

						valid_hairstyles[hairstyle] = hair_styles_list[hairstyle]

					if(valid_hairstyles.len)
						h_style = pick(valid_hairstyles)
						
					else
						//this shouldn't happen
						h_style = hair_styles_list["Bald"]

					//grab one of the valid facial hair styles for the newly chosen species
					var/list/valid_facialhairstyles = list()
					for(var/facialhairstyle in facial_hair_styles_list)
						var/datum/sprite_accessory/S = facial_hair_styles_list[facialhairstyle]
						if(gender == MALE && S.gender == FEMALE)
							continue
						if(gender == FEMALE && S.gender == MALE)
							continue
						if(!(species in S.species_allowed))
							continue

						valid_facialhairstyles[facialhairstyle] = facial_hair_styles_list[facialhairstyle]

					if(valid_facialhairstyles.len)
						f_style = pick(valid_facialhairstyles)
					else
						//this shouldn't happen
						f_style = facial_hair_styles_list["Shaved"]

					//reset hair colour and skin colour
					r_hair = 0//hex2num(copytext(new_hair, 2, 4))
					g_hair = 0//hex2num(copytext(new_hair, 4, 6))
					b_hair = 0//hex2num(copytext(new_hair, 6, 8))

					s_tone = 0

					if(!(species in list("Unathi", "Tajaran", "Skrell", "Slime People", "Vulpkanin", "Machine")))
						r_skin = 0
						g_skin = 0
						b_skin = 0

					
					ha_style = "None" // No Vulp ears on Unathi
					m_style = "None" // No Unathi markings on Tajara
					body_accessory = "None" //no vulptail on humans damnit
					update_preview_icon_new(1)
					CharacterCreateProc(user, 1)
			if("randomize_appearance")
				random_character(gender)
				update_preview_icon_new(1)
				CharacterCreateProc(user, 1)
			if("choose_hastyle")
				if(species in list("Unathi", "Vulpkanin", "Tajaran", "Machine")) //Species with head accessories.
					var/list/valid_head_accessory_styles = list()
					for(var/head_accessory_style in head_accessory_styles_list)
						var/datum/sprite_accessory/H = head_accessory_styles_list[head_accessory_style]
						if(!(species in H.species_allowed))
							continue
						valid_head_accessory_styles[head_accessory_style] = head_accessory_styles_list[head_accessory_style]
					if(inp) del inp
					inp = new()
					var/new_head_accessory_style = inp.option(usr,"Choose your character's head accessory","Character Creation",null,"", valid_head_accessory_styles)//var/new_head_accessory_style = input(user, "Choose the style of your character's head accessory:", "Character Preference") as null|anything in valid_head_accessory_styles
					if(new_head_accessory_style)
						ha_style = new_head_accessory_style
						var/obj/item/organ/external/head/H = preview_model.get_organ("head")
						if(H)
							H.ha_style = ha_style
						CharacterCreateProc(user, 1)
						

			if("choose_hacolor")
				if(species in list("Unathi", "Vulpkanin", "Tajaran", "Machine")) //Species with head accessories.
					var/input = "Choose the colour of your character's head accessory:"
					if(inp) del inp
					inp = new()
					var/new_head_accessory = inp.option(usr,input,"Character Creation",null,"color")//var/new_head_accessory = input(user, input, "Character Preference", rgb(r_headacc, g_headacc, b_headacc)) as color|null
					if(new_head_accessory)
						r_headacc = hex2num(copytext(new_head_accessory, 2, 4))
						g_headacc = hex2num(copytext(new_head_accessory, 4, 6))
						b_headacc = hex2num(copytext(new_head_accessory, 6, 8))
						var/obj/item/organ/external/head/H = preview_model.get_organ("head")
						if(H)
							H.r_headacc = r_headacc
							H.g_headacc = g_headacc
							H.b_headacc = b_headacc
						CharacterCreateProc(user, 1)
			if("choose_mcolor")
				if(species in list("Unathi", "Vulpkanin", "Tajaran", "Machine")) //Species with markings.
					var/input = "Choose the colour of your character's markings:"
					if(inp) del inp
					inp = new()
					var/new_markings = inp.option(usr,input,"Character Creation",null,"color")//var/new_markings = input(user, input, "Character Preference", rgb(r_markings, g_markings, b_markings)) as color|null
					if(new_markings)
						r_markings = hex2num(copytext(new_markings, 2, 4))
						g_markings = hex2num(copytext(new_markings, 4, 6))
						b_markings = hex2num(copytext(new_markings, 6, 8))
						preview_model.r_markings = r_markings
						preview_model.g_markings = g_markings
						preview_model.b_markings = b_markings
						CharacterCreateProc(user, 1)
						
			if("choose_mstyle")
				if(species in list("Unathi", "Vulpkanin", "Tajaran", "Machine")) //Species with markings.
					var/list/valid_markings = list()
					for(var/markingstyle in marking_styles_list)
						var/datum/sprite_accessory/M = marking_styles_list[markingstyle]
						if(!(species in M.species_allowed))
							continue

						if(species == "Machine") //Species that can use prosthetic heads.
							var/obj/item/organ/external/head/H = new()
							if(!rlimb_data["head"]) //Handle situations where the head is default.
								H.model = "Morpheus Cyberkinetics"
							else
								H.model = rlimb_data["head"]
							var/datum/robolimb/robohead = all_robolimbs[H.model]
							if(robohead.is_monitor && M.name != "None") //If the character can have prosthetic heads and they have the default Morpheus head (or another monitor-head), no optic markings.
								continue
							else if(!robohead.is_monitor && M.name != "None") //Otherwise, if they DON'T have the default head and the head's not a monitor but the head's not in the style's list of allowed models, skip.
								if(!(robohead.company in M.models_allowed))
									continue

						valid_markings[markingstyle] = marking_styles_list[markingstyle]

					if(inp) del inp
					inp = new()
					var/new_marking_style = inp.option(usr,"Choose your character's body markings","Character Creation",null,"", valid_markings)//var/new_marking_style = input(user, "Choose the style of your character's markings:", "Character Preference", m_style) as null|anything in valid_markings
					if(new_marking_style)
						m_style = new_marking_style
						preview_model.m_style = m_style
						CharacterCreateProc(user, 1)
			if("choose_hcolor")
				if(species in list("Human", "Unathi", "Tajaran", "Skrell", "Machine", "Vulpkanin", "Vox"))
					var/input = "Choose your character's hair colour:"
					if(inp) del inp
					inp = new()
					var/new_hair = inp.option(usr,input,"Character Creation",null,"color")//var/new_hair = input(user, input, "Character Preference", rgb(r_hair, g_hair, b_hair)) as color|null
					if(new_hair)
						r_hair = hex2num(copytext(new_hair, 2, 4))
						g_hair = hex2num(copytext(new_hair, 4, 6))
						b_hair = hex2num(copytext(new_hair, 6, 8))
						var/obj/item/organ/external/head/H = preview_model.get_organ("head")
						if(H)
							H.r_hair = r_hair
							H.g_hair = g_hair
							H.b_hair = b_hair
						CharacterCreateProc(user, 1)
			if("choose_hstyle")
				var/list/valid_hairstyles = list()
				var/list/ordered_hairstyles = list()
				if(gender == MALE)
					ordered_hairstyles |= hair_styles_male_list
					ordered_hairstyles |= hair_styles_neutral_list
					ordered_hairstyles |= hair_styles_female_list
				else
					ordered_hairstyles |= hair_styles_female_list
					ordered_hairstyles |= hair_styles_neutral_list
					ordered_hairstyles |= hair_styles_male_list
				for(var/hairstyle in ordered_hairstyles)
					var/datum/sprite_accessory/S = hair_styles_list[hairstyle]
					if(species == "Machine") //Species that can use prosthetic heads.
						var/obj/item/organ/external/head/H = new()
						if(S.name == "Bald")
							valid_hairstyles[hairstyle] = S
						if(!rlimb_data["head"]) //Handle situations where the head is default.
							H.model = "Morpheus Cyberkinetics"
						else
							H.model = rlimb_data["head"]
						var/datum/robolimb/robohead = all_robolimbs[H.model]
						if(species in S.species_allowed)
							if(robohead.is_monitor && (robohead.company in S.models_allowed)) //If the Machine character has the default Morpheus screen head or another screen head
																													   //and said head is in the hair style's allowed models list...
								valid_hairstyles[hairstyle] = S //Allow them to select the hairstyle.
							continue
						else
							if(robohead.is_monitor) //Monitors (incl. the default morpheus head) cannot have wigs (human hairstyles).
								continue
							else if(!robohead.is_monitor && ("Human" in S.species_allowed))
								valid_hairstyles[hairstyle] = S
							continue
					else
						if(!(species in S.species_allowed))
							continue

						valid_hairstyles[hairstyle] = S

				if(inp) del inp
				inp = new()
				var/new_h_style = inp.option(usr,"Choose your character's hair style","Character Creation",null,"", valid_hairstyles)//var/new_h_style = input(user, "Choose your character's hair style:", "Character Preference") as null|anything in valid_hairstyles
				if(new_h_style)
					h_style = new_h_style
					var/obj/item/organ/external/head/H = preview_model.get_organ("head")
					if(H)
						H.h_style = h_style
					CharacterCreateProc(user, 1)
			if("choose_fcolor")
				if(species in list("Human", "Unathi", "Tajaran", "Skrell", "Machine", "Vulpkanin", "Vox"))
					if(inp) del inp
					inp = new()
					var/new_facial = inp.option(usr,"Choose your character's facial-hair colour","Character Creation",null,"color")//var/new_facial = input(user, "Choose your character's facial-hair colour:", "Character Preference", rgb(r_facial, g_facial, b_facial)) as color|null
					if(new_facial)
						r_facial = hex2num(copytext(new_facial, 2, 4))
						g_facial = hex2num(copytext(new_facial, 4, 6))
						b_facial = hex2num(copytext(new_facial, 6, 8))
						var/obj/item/organ/external/head/H = preview_model.get_organ("head")
						if(H)
							H.r_facial = r_facial
							H.g_facial = g_facial
							H.b_facial = b_facial
						CharacterCreateProc(user, 1)
			if("choose_fstyle")
				var/list/valid_facialhairstyles = list()
				for(var/facialhairstyle in facial_hair_styles_list)
					var/datum/sprite_accessory/S = facial_hair_styles_list[facialhairstyle]
					if(S.name == "Shaved")
						valid_facialhairstyles[facialhairstyle] = S
					if(gender == MALE && S.gender == FEMALE)
						continue
					if(gender == FEMALE && S.gender == MALE)
						continue
					if(species == "Machine") //Species that can use prosthetic heads.
						var/obj/item/organ/external/head/H = new()
						if(!rlimb_data["head"]) //Handle situations where the head is default.
							H.model = "Morpheus Cyberkinetics"
						else
							H.model = rlimb_data["head"]
						var/datum/robolimb/robohead = all_robolimbs[H.model]
						if(species in S.species_allowed)
							if(robohead.is_monitor) //If the Machine character has the default Morpheus screen head or another screen head and they're allowed to have the style, let them have it.
								valid_facialhairstyles[facialhairstyle] = S
							continue
						else
							if(robohead.is_monitor) //Monitors (incl. the default morpheus head) cannot have wigs (human facial hairstyles).
								continue
							else if(!robohead.is_monitor && ("Human" in S.species_allowed))
								valid_facialhairstyles[facialhairstyle] = S
							continue
					else
						if(!(species in S.species_allowed))
							continue

					valid_facialhairstyles[facialhairstyle] = facial_hair_styles_list[facialhairstyle]

				if(inp) del inp
				inp = new()
				var/new_f_style = inp.option(usr,"Choose your character's facial hair style","Character Creation",null,"", valid_facialhairstyles)//var/new_f_style = input(user, "Choose your character's facial-hair style:", "Character Preference")  as null|anything in valid_facialhairstyles
				if(new_f_style)
					f_style = new_f_style
					var/obj/item/organ/external/head/H = preview_model.get_organ("head")
					if(H)
						H.f_style = f_style
					CharacterCreateProc(user, 1)
			if("choose_ecolor")
				if(inp) del inp
				inp = new()
				var/new_eyes= inp.option(usr,"Choose your character's eye color","Character Creation",null,"color")//var/new_eyes = input(user, "Choose your character's eye colour:", "Character Preference", rgb(r_eyes, g_eyes, b_eyes)) as color|null
				if(new_eyes)
					r_eyes = hex2num(copytext(new_eyes, 2, 4))
					g_eyes = hex2num(copytext(new_eyes, 4, 6))
					b_eyes = hex2num(copytext(new_eyes, 6, 8))
					preview_model.r_eyes = r_eyes
					preview_model.g_eyes = g_eyes
					preview_model.b_eyes = b_eyes
					CharacterCreateProc(user, 1)
			if("choose_stone")
				if(species == "Human" || species == "Drask")
					if(inp) del inp
					inp = new()
					var/new_s_tone = inp.option(usr,"Choose your character's skin-tone:\n(Light 1 - 220 Dark)","Character Creation",null,"num|null")//var/new_s_tone = input(user, "Choose your character's skin-tone:\n(Light 1 - 220 Dark)", "Character Preference")  as num|null
					if(new_s_tone)
						s_tone = 35 - max(min(round(new_s_tone), 220), 1)
					preview_model.s_tone = s_tone
					CharacterCreateProc(user, 1)
				else if(species == "Vox")
					if(inp) del inp
					inp = new()
					var/skin_c = inp.option(usr,"Choose your Vox's skin color:\n(1 = Default Green, 2 = Dark Green, 3 = Brown, 4 = Grey, \n5 = Emerald, 6 = Azure)","Character Creation",null,"num|null")//var/skin_c = input(user, "Choose your Vox's skin color:\n(1 = Default Green, 2 = Dark Green, 3 = Brown, 4 = Grey, \n5 = Emerald, 6 = Azure)", "Character Preference") as num|null
					if(skin_c)
						s_tone = max(min(round(skin_c), 6), 1)
					preview_model.s_tone = s_tone
					CharacterCreateProc(user, 1)
			if("choose_scolor")
				if((species in list("Unathi", "Tajaran", "Skrell", "Slime People", "Vulpkanin", "Machine")) || body_accessory_by_species[species] || check_rights(R_ADMIN, 0, user))
					if(inp) del inp
					inp = new()
					var/new_skin = inp.option(usr,"Choose your character's skin color","Character Creation",null,"color")//var/new_skin = input(user, "Choose your character's skin colour: ", "Character Preference", rgb(r_skin, g_skin, b_skin)) as color|null
					if(new_skin)
						r_skin = hex2num(copytext(new_skin, 2, 4))
						g_skin = hex2num(copytext(new_skin, 4, 6))
						b_skin = hex2num(copytext(new_skin, 6, 8))
						preview_model.r_skin = r_skin
						preview_model.g_skin = g_skin
						preview_model.b_skin = b_skin
					CharacterCreateProc(user, 1)
			if("choose_bacc")
				var/list/possible_body_accessories = list()
				if(check_rights(R_ADMIN, 1, user))
					possible_body_accessories = body_accessory_by_name.Copy()
				else
					for(var/B in body_accessory_by_name)
						var/datum/body_accessory/accessory = body_accessory_by_name[B]
						if(!istype(accessory))
							possible_body_accessories += "None" //the only null entry should be the "None" option
							continue
						if(species in accessory.allowed_species)
							possible_body_accessories += B

				if(inp) del inp
				inp = new()
				var/new_body_accessory = inp.option(usr,"Choose your character's body accessory","Character Creation",null,"", possible_body_accessories)//var/new_body_accessory = input(user, "Choose your body accessory:", "Character Preference") as null|anything in possible_body_accessories
				if(new_body_accessory)
					body_accessory = new_body_accessory		
					preview_model.body_accessory = body_accessory_by_name["[body_accessory]"]
					CharacterCreateProc(user, 1)
			if("choose_flavortext")
				if(inp) del inp
				inp = new()
				var/msg = inp.option(usr,"Set additional text that shows when players 'examine' your character. This can be changed at any time.","Character Creation",html_decode(flavor_text),"text")//var/msg = input(usr,"Set the flavor text in your 'examine' verb. This can also be used for OOC notes and preferences!","Flavor Text",html_decode(flavor_text)) as message

				if(msg != null)
					msg = copytext(msg, 1, MAX_MESSAGE_LEN)
					msg = html_encode(msg)

					flavor_text = msg
					CharacterCreateProc(user, 1)
			if("choose_underwear")
				var/list/underwear_options = list()
				if(gender == MALE)
					for(var/obj/ob in male_underwear)
						underwear_options += ob.name
				else
					for(var/obj/ob in female_underwear)
						underwear_options += ob.name
				
				if(inp) del inp
				inp = new()
				var/new_underwear = inp.option(usr,"Choose your character's starting underwear","Character Creation",null,"", underwear_options)//var/new_underwear = input(user, "Choose your character's underwear:", "Character Preference")  as null|anything in underwear_options
				if(new_underwear)
					if(gender == MALE)
						for(var/obj/ob in male_underwear)
							if(ob.name == new_underwear)
								preview_model.underwear = ob
								break
					else
						for(var/obj/ob in female_underwear)
							if(ob.name == new_underwear)
								preview_model.underwear = ob
								break
					underwear = new_underwear
					show_under = 1
					CharacterCreateProc(user, 1)
			if("choose_undershirt")
				var/list/undershirt_list = list()
				for(var/obj/ob in undershirts)
					undershirt_list += ob.name
				if(gender == FEMALE)
				for(var/obj/ob in female_undershirts)
					undershirt_list += ob.name	
				undershirt_list += "None"
				if(inp) del inp
				inp = new()
				var/new_undershirt = inp.option(usr,"Choose your character's starting undershirt","Character Creation",null,"", undershirt_list)//new_undershirt = input(user, "Choose your character's undershirt:", "Character Preference") as null|anything in undershirt_list
				if(new_undershirt)
					if(new_undershirt != "None")
						var/list/final_list = list()
						if(gender == FEMALE)
							final_list |= female_undershirts
						final_list |= undershirts
						for(var/obj/ob in final_list)
							if(ob.name == new_undershirt)
								preview_model.undershirt = ob
								break
					else
						preview_model.undershirt = null
					undershirt = new_undershirt
					show_under = 1
					CharacterCreateProc(user, 1)
			if("choose_backpack")
				var/list/backpack_list = list()
				for(var/obj/ob in backbaglist)
					backpack_list += ob.name
				if(inp) del inp
				inp = new()
				var/new_backbag = inp.option(usr,"Choose your character's starting style of bag","Character Creation",null,"", backpack_list)//var/new_backbag = input(user, "Choose your character's style of bag:", "Character Preference")  as null|anything in backpack_list
				if(new_backbag)
					for(var/obj/ob in backbaglist)
						if(ob.name == new_backbag)
							preview_model.back = ob
							break
					backbag = new_backbag
					CharacterCreateProc(user, 1)
			if("choose_jumpsuit")
				var/list/jumpsuit_list = list()
				for(var/obj/ob in underlist)
					jumpsuit_list += ob.name
				if(inp) del inp
				inp = new()
				var/new_jumpsuit = inp.option(usr,"Choose your character's starting jumpsuit","Character Creation",null,"", jumpsuit_list)//var/new_jumpsuit = input(user, "Choose your character's jumpsuit:", "Character Preference")  as null|anything in jumpsuit_list
				if(new_jumpsuit)
					for(var/obj/ob in underlist)
						if(ob.name == new_jumpsuit)
							preview_model.w_uniform = ob
							break
					jumpsuit = new_jumpsuit
					CharacterCreateProc(user, 1)
			if("choose_stats")
				if(!nameChose)
					return 0 // this shouldnt happen...
				create_menu = 2
				CharacterCreateProc(user, 1)
			if("decrease_grit")
				if(stat_Grit)
					stat_Grit--
					stats_left++
					CharacterCreateProc(user)
			if("increase_grit")
				if(stats_left)
					stats_left--
					stat_Grit++
					CharacterCreateProc(user)
			if("decrease_fortitude")
				if(stat_Fortitude)
					stat_Fortitude--
					stats_left++
					CharacterCreateProc(user)
			if("increase_fortitude")
				if(stats_left)
					stats_left--
					stat_Fortitude++
					CharacterCreateProc(user)
			if("decrease_reflex")
				if(stat_Reflex)
					stat_Reflex--
					stats_left++
					CharacterCreateProc(user)
			if("increase_reflex")
				if(stats_left)
					stats_left--
					stat_Reflex++
					CharacterCreateProc(user)
			if("decrease_creativity")
				if(stat_Creativity)
					stat_Creativity--
					stats_left++
					CharacterCreateProc(user)
			if("increase_creativity")
				if(stats_left)
					stats_left--
					stat_Creativity++
					CharacterCreateProc(user)
			if("decrease_focus")
				if(stat_Focus)
					stat_Focus--
					stats_left++
					CharacterCreateProc(user)
			if("increase_focus")
				if(stats_left)
					stats_left--
					stat_Focus++
					CharacterCreateProc(user)
			if("choose_appearance")
				create_menu = 1
				CharacterCreateProc(user, 1)
			if("choose_finish")
				if(stats_left) // this shouldnt happen...
					return 
				create_menu = 3
				CharacterCreateProc(user, 1)
			if("choose_wealth")
				ambition = 1
				CharacterCreateProc(user, 1)
			if("choose_leisure")
				ambition = 2
				CharacterCreateProc(user, 1)
			if("choose_power")
				ambition = 3
				CharacterCreateProc(user, 1)
			if("finish_character")
				slot_interact(user)
				return 1
	if(href_list["choice_slot"])
		default_slot = text2num(href_list["choice_slot"])
		slot = default_slot
		var/mob/living/carbon/human/Hu = preview_model
		Hu.real_name = real_name
		Hu.dna.real_name = real_name
		Hu.dna.ready_dna(Hu, flatten_SE = 1)
		Hu.dna.ResetUIFrom(Hu)
		Hu.sync_organ_dna(assimilate=1)
		var/datum/mind/mind = new()
		if (species=="Plasmaman")
			// Unequip existing suits and hats.
			Hu.unEquip(Hu.wear_suit)
			Hu.unEquip(Hu.head)
			Hu.unEquip(Hu.wear_mask)
			Hu.equip_or_collect(new /obj/item/clothing/mask/breath(Hu), slot_wear_mask)
			var/suit=/obj/item/clothing/suit/space/eva/plasmaman
			var/helm=/obj/item/clothing/head/helmet/space/eva/plasmaman
			var/tank_slot = slot_s_store
			var/tank_slot_name = "suit storage"
			Hu.equip_or_collect(new suit(Hu), slot_wear_suit)
			Hu.equip_or_collect(new helm(Hu), slot_head)
			Hu.equip_or_collect(new/obj/item/weapon/tank/plasma/plasmaman(Hu), tank_slot) // Bigger plasma tank from Raggy.
			Hu.equip_or_collect(new /obj/item/weapon/plasmensuit_cartridge(Hu), slot_in_backpack)
			Hu.equip_or_collect(new /obj/item/weapon/plasmensuit_cartridge(Hu), slot_in_backpack)
		if (species=="Vox")
			Hu.unEquip(Hu.wear_mask)
			Hu.unEquip(Hu.l_hand)
			Hu.equip_or_collect(new /obj/item/clothing/mask/breath/vox(Hu), slot_wear_mask)
			var/tank_pref = Hu.client.prefs.speciesprefs
			if(tank_pref)//Diseasel, here you go
				Hu.equip_or_collect(new /obj/item/weapon/tank/nitrogen(Hu), slot_l_hand)
			else
				Hu.equip_or_collect(new /obj/item/weapon/tank/emergency_oxygen/vox(Hu), slot_l_hand)
			to_chat(Hu, "<span class='notice'>You are now running on nitrogen internals from the [Hu.l_hand] in your hand. Your species finds oxygen toxic, so you must breathe nitrogen only.</span>")
			Hu.internal = Hu.l_hand
			Hu.update_internals_hud_icon(1)
		Hu.equip_or_collect(new /obj/item/device/radio/headset, slot_r_ear)
		Hu.equip_or_collect(new /obj/item/device/pda, slot_wear_pda)
		var/obj/item/weapon/implant/crewtracker/implant = new()
		mind.primary_cert = job_master.GetCert("intern")
		implant.loc = Hu
		var/list/ranks = get_standard_departments()
		mind.ranks = list()
		for(var/a in ranks)
			var/stringrank = to_strings(a)
			mind.ranks[stringrank] = 1
		mind.initial_account = create_account(real_name, 500)
		mind.stat_Grit = stat_Grit
		mind.stat_Fortitude = stat_Fortitude
		mind.stat_Reflex = stat_Reflex
		mind.stat_Creativity = stat_Creativity
		mind.stat_Focus = stat_Focus
		mind.char_slot = slot
		mind.name = real_name
		
		map_storage.Save_Char(user.client,mind,Hu, slot)
		create_single_spawnicon(user.client, slot)
		slot_interact(user,close = 1)
		ui_interact(user,close = 1)
		return 1
		
	return 0
/datum/preferences/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 0, var/close = 0)
	var/data[0]
	if(!close)
		data["nameChose"] = nameChose
		data["name"] = real_name
		data["gender"] = capitalize(gender)
		data["age"] = age
		data["species"] = species
		if(species in list("Unathi", "Vulpkanin", "Tajaran", "Machine")) //Species that have head accessories.
			data["headacc"] = 1
			if(species == "Unathi")
				data["headaccname"] = "Horns"
			else
				data["headaccname"] = "Head Accessories"
			data["ha_style"] = ha_style
			data["hacolorsquare"] = color_square(r_headacc, g_headacc, b_headacc)
		if(species in list("Unathi", "Vulpkanin", "Tajaran", "Machine")) //Species that have body markings.
			data["bodymark"] = 1
			data["m_style"] = m_style
			data["mcolorsquare"] = color_square(r_markings, g_markings, b_markings)
		data["h_style"] = h_style
		data["hcolorsquare"] = color_square(r_hair, g_hair, b_hair)
		data["f_style"] = f_style
		data["fcolorsquare"] = color_square(r_facial, g_facial, b_facial)
		if(species != "Machine")
			data["eyecolor"] = 1
			data["ecolorsquare"] = color_square(r_eyes, g_eyes, b_eyes)
		if((species in list("Unathi", "Tajaran", "Skrell", "Slime People", "Vulpkanin", "Machine")) || body_accessory_by_species[species])//  || check_rights(R_ADMIN, 0, user)
			data["skincolor"] = 1
			data["scolorsquare"] = color_square(r_skin, g_skin, b_skin)
		if(species in list("Human", "Drask", "Vox"))
			data["skintone"] = 1
			data["stone"] = species == "Vox" ? "[s_tone]" : "[-s_tone + 35]/220"
		if(body_accessory_by_species[species] || check_rights(R_ADMIN, 0, user))
			data["body_accessory"] = 1
			data["bacc_style"] = body_accessory
		data["underwear"] = underwear
		data["undershirt"] = undershirt
		data["backpack"] = backbag
		data["jumpsuit"] = jumpsuit
		data["cert"] = get_cert_title()
		data["flavortext"] = TextPreview(flavor_text)
		data["create_menu"] = create_menu
		data["stats_left"] = stats_left
		data["grit"] = stat_Grit
		data["true_grit"] = preview_model.species.stat_Grit + stat_Grit
		
		data["fortitude"] = stat_Fortitude
		data["true_fortitude"] = preview_model.species.stat_Fortitude + stat_Fortitude
		
		data["reflex"] = stat_Reflex
		data["true_reflex"] = preview_model.species.stat_Reflex + stat_Reflex
		
		data["creativity"] = stat_Creativity
		data["true_creativity"] = preview_model.species.stat_Creativity + stat_Creativity
		
		data["focus"] = stat_Focus
		data["true_focus"] = preview_model.species.stat_Focus + stat_Focus
		var/ambit = ""
		switch(ambition)
			if(1)
				ambit = "Wealth"
			if(2)
				ambit = "Recreation"
			if(3)
				ambit = "Power"
		data["ambition"] = ambit
		data["ambitionChose"] = (ambition > 0)
		// the ui does not exist, so we'll create a new() one
		// for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
	ui = new(user, user, ui_key, "character_creation.tmpl", "Register New Employee", 685, 750, state = default_state)
	// when the ui is first opened this is the data it will use
	ui.set_initial_data(data)
	// open the new ui window
	if(!close)
		ui.open()
	else
		ui.close()


/datum/preferences/proc/slot_interact(mob/user, ui_key = "select", var/datum/nanoui/ui = null, var/force_open = 0, var/close = 0)
	var/data[0]
	if(!close)
		var/list/formatted = list()
		if(!minds_list || !minds_list.len)
			create_spawnicons(user.client)
		for(var/i=1, i<=max_save_slots, i++)
			var/datum/mind/mind = minds_list[i]
			var/name
			var/open = 0
			if(mind)		
				name = mind.current.real_name
			if(!name)
				name = "Open Slot"
				open = 1
			formatted.Add(list(list(
				"name" = name,
				"open" = open,
				"index" = i)))
			
		data["slots"] = formatted
	
	ui = new(user, user, ui_key, "slot_select.tmpl", "Select Slot", 300, 390, state = default_state)
	// when the ui is first opened this is the data it will use
	ui.set_initial_data(data)
	// open the new ui window
	if(!close)
		ui.open()
	else
		ui.close()
		

/datum/preferences/proc/CharacterCreateProc(mob/user, var/force = 0)
	if(!user || !user.client)
		return
	update_preview_icon_new()
	user << browse_rsc(preview_icon_front, "previewicon.png")
	user << browse_rsc(preview_icon_side, "previewicon2.png")
	return ui_interact(user, force_open = force)


// Hello I am a proc full of snowflake species checks how are you
/datum/preferences/proc/ShowChoices(mob/user)
	if(!user || !user.client)
		return
	var/dat = ""
	dat += "<HR>"
		// General Preferences
	dat += "<table><tr><td width='340px' height='300px' valign='top'>"
	dat += "<h2>General Settings</h2>"
	dat += "<b>Fancy NanoUI:</b> <a href='?_src_=prefs;preference=nanoui'>[(nanoui_fancy) ? "Yes" : "No"]</a><br>"
	dat += "<b>Ghost-Item Attack Animation:</b> <a href='?_src_=prefs;preference=ghost_att_anim'>[(show_ghostitem_attack) ? "Yes" : "No"]</a><br>"
	dat += "<b>Custom UI settings:</b><br>"
	dat += " - <b>UI Style:</b> <a href='?_src_=prefs;preference=ui'><b>[UI_style]</b></a><br>"
	dat += " - <b>Color:</b> <a href='?_src_=prefs;preference=UIcolor'><b>[UI_style_color]</b></a> <table style='display:inline;' bgcolor='[UI_style_color]'<tr><td>__</td></tr></table><br>"
	dat += " - <b>Alpha (transparency):</b> <a href='?_src_=prefs;preference=UIalpha'><b>[UI_style_alpha]</b></a><br>"
	dat += "<br>"
	dat += "<b>Play admin midis:</b> <a href='?_src_=prefs;preference=hear_midis'><b>[(sound & SOUND_MIDI) ? "Yes" : "No"]</b></a><br>"
	dat += "<b>Play lobby music:</b> <a href='?_src_=prefs;preference=lobby_music'><b>[(sound & SOUND_LOBBY) ? "Yes" : "No"]</b></a><br>"
	if(user.client.holder)
		dat += "<b>Adminhelp sound:</b> "
		dat += "<a href='?_src_=prefs;preference=hear_adminhelps'><b>[(sound & SOUND_ADMINHELP)?"On":"Off"]</b></a><br>"

	if(check_rights(R_ADMIN,0))
		dat += "<b>OOC:</b> <span style='border: 1px solid #161616; background-color: [ooccolor ? ooccolor : normal_ooc_colour];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=ooccolor;task=input'><b>Change</b></a><br>"
	if(config.allow_Metadata)
		dat += "<b>OOC notes:</b> <a href='?_src_=prefs;preference=metadata;task=input'><b>Edit</b></a><br>"
	if(unlock_content)
		dat += "<b>BYOND Membership Publicity:</b> <a href='?_src_=prefs;preference=publicity'><b>[(toggles & MEMBER_PUBLIC) ? "Public" : "Hidden"]</b></a><br>"
	dat += "<b>Ghost ears:</b> <a href='?_src_=prefs;preference=ghost_ears'><b>[(toggles & CHAT_GHOSTEARS) ? "Nearest Creatures" : "All Speech"]</b></a><br>"
	dat += "<b>Ghost sight:</b> <a href='?_src_=prefs;preference=ghost_sight'><b>[(toggles & CHAT_GHOSTSIGHT) ? "Nearest Creatures" : "All Emotes"]</b></a><br>"
	dat += "<b>Ghost radio:</b> <a href='?_src_=prefs;preference=ghost_radio'><b>[(toggles & CHAT_GHOSTRADIO) ? "Nearest Speakers" : "All Chatter"]</b></a><br>"

	dat += "</td><td width='300px' height='300px' valign='top'>"
//	dat += "<h2>Special Role Settings</h2>"
//	if(jobban_isbanned(user, "Syndicate"))
//		dat += "<b>You are banned from special roles.</b>"
//		be_special = list()
//	else
	//	for(var/i in special_roles)
	//		if(jobban_isbanned(user, i))
	//			dat += "<b>Be [capitalize(i)]:</b> <font color=red><b> \[BANNED]</b></font><br>"
	//		else if(!player_old_enough_antag(user.client,i))
	//			var/available_in_days_antag = available_in_days_antag(user.client,i)
	//			dat += "<b>Be [capitalize(i)]:</b> <font color=red><b> \[IN [(available_in_days_antag)] DAYS]</b></font><br>"
	//		else
	//			dat += "<b>Be [capitalize(i)]:</b> <a href='?_src_=prefs;preference=be_special;role=[i]'><b>[(i in src.be_special) ? "Yes" : "No"]</b></a><br>"
	dat += "</td></tr></table>"

	dat += "<hr><center>"
	if(!IsGuestKey(user.key))
		dat += "<a href='?_src_=prefs;preference=save'>Save Setup</a> - "
	dat += "<a href='?_src_=prefs;preference=reset_all'>Reset Setup</a>"
	dat += "</center>"

	var/datum/browser/popup = new(user, "preferences", "<div align='center'>Game Preferences</div>", 820, 640)
	popup.set_content(dat)
	popup.open(0)


/datum/preferences/proc/get_gear_metadata(var/datum/gear/G)
	. = gear[G.display_name]
	if(!.)
		. = list()
		gear[G.display_name] = .

/datum/preferences/proc/get_tweak_metadata(var/datum/gear/G, var/datum/gear_tweak/tweak)
	var/list/metadata = get_gear_metadata(G)
	. = metadata["[tweak]"]
	if(!.)
		. = tweak.get_default()
		metadata["[tweak]"] = .

/datum/preferences/proc/set_tweak_metadata(var/datum/gear/G, var/datum/gear_tweak/tweak, var/new_metadata)
	var/list/metadata = get_gear_metadata(G)
	metadata["[tweak]"] = new_metadata


/datum/preferences/proc/SetChoices(mob/user, limit = 12, list/splitJobs = list("Civilian","Research Director","AI","Bartender"), width = 760, height = 790)
	if(!job_master)
		return

	//limit 	 - The amount of jobs allowed per column. Defaults to 17 to make it look nice.
	//splitJobs - Allows you split the table by job. You can make different tables for each department by including their heads. Defaults to CE to make it look nice.
	//width	 - Screen' width. Defaults to 550 to make it look nice.
	//height 	 - Screen's height. Defaults to 500 to make it look nice.


	var/HTML = "<body>"
	HTML += "<tt><center>"
	HTML += "<b>Choose occupation chances</b><br>Unavailable occupations are crossed out.<br><br>"
	HTML += "<center><a href='?_src_=prefs;preference=job;task=close'>\[Done\]</a></center><br>" // Easier to press up here.
	HTML += "<div align='center'>Left-click to raise an occupation preference, right-click to lower it.<br></div>"
	HTML += "<script type='text/javascript'>function setJobPrefRedirect(level, rank) { window.location.href='?_src_=prefs;preference=job;task=setJobLevel;level=' + level + ';text=' + encodeURIComponent(rank); return false; }</script>"
	HTML += "<table width='100%' cellpadding='1' cellspacing='0'><tr><td width='20%'>" // Table within a table for alignment, also allows you to easily add more colomns.
	HTML += "<table width='100%' cellpadding='1' cellspacing='0'>"
	var/index = -1

	//The job before the current job. I only use this to get the previous jobs color when I'm filling in blank rows.
	var/datum/job/lastJob
	if(!job_master)		return
	for(var/datum/job/job in job_master.occupations)

		if(job.admin_only)
			continue

		index += 1
		if((index >= limit) || (job.title in splitJobs))
			if((index < limit) && (lastJob != null))
				//If the cells were broken up by a job in the splitJob list then it will fill in the rest of the cells with
				//the last job's selection color. Creating a rather nice effect.
				for(var/i = 0, i < (limit - index), i += 1)
					HTML += "<tr bgcolor='[lastJob.selection_color]'><td width='60%' align='right'>&nbsp</td><td>&nbsp</td></tr>"
			HTML += "</table></td><td width='20%'><table width='100%' cellpadding='1' cellspacing='0'>"
			index = 0

		HTML += "<tr bgcolor='[job.selection_color]'><td width='60%' align='right'>"
		var/rank = job.title
		lastJob = job
		if(!is_job_whitelisted(user, rank))
			HTML += "<font color=red>[rank]</font></td><td><font color=red><b> \[KARMA]</b></font></td></tr>"
			continue
		if(jobban_isbanned(user, rank))
			HTML += "<del>[rank]</del></td><td><b> \[BANNED]</b></td></tr>"
			continue
		if(!job.player_old_enough(user.client))
			var/available_in_days = job.available_in_days(user.client)
			HTML += "<del>[rank]</del></td><td> \[IN [(available_in_days)] DAYS]</td></tr>"
			continue
		if((job_support_low & CIVILIAN) && (rank != "Civilian"))
			HTML += "<font color=orange>[rank]</font></td><td></td></tr>"
			continue
		if((rank in command_positions) || (rank == "AI"))//Bold head jobs
			HTML += "<b><span class='dark'>[rank]</span></b>"
		else
			HTML += "<span class='dark'>[rank]</span>"

		HTML += "</td><td width='40%'>"

		var/prefLevelLabel = "ERROR"
		var/prefLevelColor = "pink"
		var/prefUpperLevel = -1 // level to assign on left click
		var/prefLowerLevel = -1 // level to assign on right click

		if(GetJobDepartment(job, 1) & job.flag)
			prefLevelLabel = "High"
			prefLevelColor = "slateblue"
			prefUpperLevel = 4
			prefLowerLevel = 2
		else if(GetJobDepartment(job, 2) & job.flag)
			prefLevelLabel = "Medium"
			prefLevelColor = "green"
			prefUpperLevel = 1
			prefLowerLevel = 3
		else if(GetJobDepartment(job, 3) & job.flag)
			prefLevelLabel = "Low"
			prefLevelColor = "orange"
			prefUpperLevel = 2
			prefLowerLevel = 4
		else
			prefLevelLabel = "NEVER"
			prefLevelColor = "red"
			prefUpperLevel = 3
			prefLowerLevel = 1


		HTML += "<a class='white' href='?_src_=prefs;preference=job;task=setJobLevel;level=[prefUpperLevel];text=[rank]' oncontextmenu='javascript:return setJobPrefRedirect([prefLowerLevel], \"[rank]\");'>"

//			HTML += "<a href='?_src_=prefs;preference=job;task=input;text=[rank]'>"

		if(rank == "Civilian")//Civilian is special
			if(job_support_low & CIVILIAN)
				HTML += " <font color=green>\[Yes]</font></a>"
			else
				HTML += " <font color=red>\[No]</font></a>"
			if(job.alt_titles)
				HTML += "<br><b><a class='white' href=\"byond://?src=\ref[user];preference=job;task=alt_title;job=\ref[job]\">\[[GetPlayerAltTitle(job)]\]</a></b></td></tr>"
			HTML += "</td></tr>"
			continue
/*
		if(GetJobDepartment(job, 1) & job.flag)
			HTML += " <font color=blue>\[High]</font>"
		else if(GetJobDepartment(job, 2) & job.flag)
			HTML += " <font color=green>\[Medium]</font>"
		else if(GetJobDepartment(job, 3) & job.flag)
			HTML += " <font color=orange>\[Low]</font>"
		else
			HTML += " <font color=red>\[NEVER]</font>"
			*/
		HTML += "<font color=[prefLevelColor]>[prefLevelLabel]</font></a>"

		if(job.alt_titles)
			HTML += "<br><b><a class='white' href=\"byond://?src=\ref[user];preference=job;task=alt_title;job=\ref[job]\">\[[GetPlayerAltTitle(job)]\]</a></b></td></tr>"


		HTML += "</td></tr>"

	for(var/i = 1, i < (limit - index), i += 1) // Finish the column so it is even
		HTML += "<tr bgcolor='[lastJob.selection_color]'><td width='60%' align='right'>&nbsp</td><td>&nbsp</td></tr>"

	HTML += "</td'></tr></table>"

	HTML += "</center></table>"

	switch(alternate_option)
		if(GET_RANDOM_JOB)
			HTML += "<center><br><u><a href='?_src_=prefs;preference=job;task=random'><font color=white>Get random job if preferences unavailable</font></a></u></center><br>"
		if(BE_CIVILIAN)
			HTML += "<center><br><u><a href='?_src_=prefs;preference=job;task=random'><font color=white>Be a civilian if preferences unavailable</font></a></u></center><br>"
		if(RETURN_TO_LOBBY)
			HTML += "<center><br><u><a href='?_src_=prefs;preference=job;task=random'><font color=white>Return to lobby if preferences unavailable</font></a></u></center><br>"

	HTML += "<center><a href='?_src_=prefs;preference=job;task=reset'>\[Reset\]</a></center>"
	HTML += "</tt>"

	user << browse(null, "window=preferences")
//		user << browse(HTML, "window=mob_occupation;size=[width]x[height]")
	var/datum/browser/popup = new(user, "mob_occupation", "<div align='center'>Occupation Preferences</div>", width, height)
	popup.set_window_options("can_close=0")
	popup.set_content(HTML)
	popup.open(0)
	return

/datum/preferences/proc/SetJobPreferenceLevel(var/datum/job/job, var/level)
	if(!job)
		return 0

	if(level == 1) // to high
		// remove any other job(s) set to high
		job_support_med |= job_support_high
		job_engsec_med |= job_engsec_high
		job_medsci_med |= job_medsci_high
		job_karma_med |= job_karma_high
		job_support_high = 0
		job_engsec_high = 0
		job_medsci_high = 0
		job_karma_high = 0

	if(job.department_flag == SUPPORT)
		job_support_low &= ~job.flag
		job_support_med &= ~job.flag
		job_support_high &= ~job.flag

		switch(level)
			if(1)
				job_support_high |= job.flag
			if(2)
				job_support_med |= job.flag
			if(3)
				job_support_low |= job.flag

		return 1
	else if(job.department_flag == ENGSEC)
		job_engsec_low &= ~job.flag
		job_engsec_med &= ~job.flag
		job_engsec_high &= ~job.flag

		switch(level)
			if(1)
				job_engsec_high |= job.flag
			if(2)
				job_engsec_med |= job.flag
			if(3)
				job_engsec_low |= job.flag

		return 1
	else if(job.department_flag == MEDSCI)
		job_medsci_low &= ~job.flag
		job_medsci_med &= ~job.flag
		job_medsci_high &= ~job.flag

		switch(level)
			if(1)
				job_medsci_high |= job.flag
			if(2)
				job_medsci_med |= job.flag
			if(3)
				job_medsci_low |= job.flag

		return 1
	else if(job.department_flag == KARMA)
		job_karma_low &= ~job.flag
		job_karma_med &= ~job.flag
		job_karma_high &= ~job.flag

		switch(level)
			if(1)
				job_karma_high |= job.flag
			if(2)
				job_karma_med |= job.flag
			if(3)
				job_karma_low |= job.flag

		return 1

	return 0

/datum/preferences/proc/UpdateJobPreference(mob/user, role, desiredLvl)
	var/datum/job/job = job_master.GetJob(role)

	if(!job)
		user << browse(null, "window=mob_occupation")
		CharacterCreateProc(user)
		return

	if(!isnum(desiredLvl))
		to_chat(user, "\red UpdateJobPreference - desired level was not a number. Please notify coders!")
		CharacterCreateProc(user)
		return

	if(role == "Civilian")
		if(job_support_low & job.flag)
			job_support_low &= ~job.flag
		else
			job_support_low |= job.flag
		SetChoices(user)
		return 1

	SetJobPreferenceLevel(job, desiredLvl)
	SetChoices(user)

	return 1

/datum/preferences/proc/ShowDisabilityState(mob/user,flag,label)
	if(flag==DISABILITY_FLAG_FAT && species!=("Human" || "Tajaran" || "Grey"))
		return "<li><i>[species] cannot be fat.</i></li>"
	return "<li><b>[label]:</b> <a href=\"?_src_=prefs;task=input;preference=disabilities;disability=[flag]\">[disabilities & flag ? "Yes" : "No"]</a></li>"

/datum/preferences/proc/SetDisabilities(mob/user)
	var/HTML = "<body>"

	// AUTOFIXED BY fix_string_idiocy.py
	// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\client\preferences.dm:474: HTML += "<tt><center>"
	HTML += {"<tt><center>
		<b>Choose disabilities</b><ul>"}
	// END AUTOFIX
	HTML += ShowDisabilityState(user,DISABILITY_FLAG_NEARSIGHTED,"Needs Glasses")
	HTML += ShowDisabilityState(user,DISABILITY_FLAG_FAT,"Obese")
	HTML += ShowDisabilityState(user,DISABILITY_FLAG_EPILEPTIC,"Seizures")
	HTML += ShowDisabilityState(user,DISABILITY_FLAG_DEAF,"Deaf")
	HTML += ShowDisabilityState(user,DISABILITY_FLAG_BLIND,"Blind")
	HTML += ShowDisabilityState(user,DISABILITY_FLAG_MUTE,"Mute")


	// AUTOFIXED BY fix_string_idiocy.py
	// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\client\preferences.dm:481: HTML += "</ul>"
	HTML += {"</ul>
		<a href=\"?_src_=prefs;task=close;preference=disabilities\">\[Done\]</a>
		<a href=\"?_src_=prefs;task=reset;preference=disabilities\">\[Reset\]</a>
		</center></tt>"}
	// END AUTOFIX
	user << browse(null, "window=preferences")
	user << browse(HTML, "window=disabil;size=350x300")
	return

/datum/preferences/proc/SetRecords(mob/user)
	var/HTML = "<body>"
	HTML += "<tt><center>"
	HTML += "<b>Set Character Records</b><br>"

	HTML += "<a href=\"byond://?src=\ref[user];preference=records;task=med_record\">Medical Records</a><br>"

	if(lentext(med_record) <= 40)
		HTML += "[med_record]"
	else
		HTML += "[copytext(med_record, 1, 37)]..."

	HTML += "<br><br><a href=\"byond://?src=\ref[user];preference=records;task=gen_record\">Employment Records</a><br>"

	if(lentext(gen_record) <= 40)
		HTML += "[gen_record]"
	else
		HTML += "[copytext(gen_record, 1, 37)]..."

	HTML += "<br><br><a href=\"byond://?src=\ref[user];preference=records;task=sec_record\">Security Records</a><br>"

	if(lentext(sec_record) <= 40)
		HTML += "[sec_record]<br>"
	else
		HTML += "[copytext(sec_record, 1, 37)]...<br>"

	HTML += "<br>"
	HTML += "<a href=\"byond://?src=\ref[user];preference=records;records=-1\">\[Done\]</a>"
	HTML += "</center></tt>"

	user << browse(null, "window=preferences")
	user << browse(HTML, "window=records;size=350x300")
	return

/datum/preferences/proc/GetPlayerAltTitle(datum/job/job)
	return player_alt_titles.Find(job.title) > 0 \
		? player_alt_titles[job.title] \
		: job.title

/datum/preferences/proc/SetPlayerAltTitle(datum/job/job, new_title)
	// remove existing entry
	if(player_alt_titles.Find(job.title))
		player_alt_titles -= job.title
	// add one if it's not default
	if(job.title != new_title)
		player_alt_titles[job.title] = new_title

/datum/preferences/proc/SetJob(mob/user, role)
	var/datum/job/job = job_master.GetJob(role)
	if(!job)
		user << browse(null, "window=mob_occupation")
		CharacterCreateProc(user)
		return

	if(role == "Civilian")
		if(job_support_low & job.flag)
			job_support_low &= ~job.flag
		else
			job_support_low |= job.flag
		SetChoices(user)
		return 1

	if(GetJobDepartment(job, 1) & job.flag)
		SetJobDepartment(job, 1)
	else if(GetJobDepartment(job, 2) & job.flag)
		SetJobDepartment(job, 2)
	else if(GetJobDepartment(job, 3) & job.flag)
		SetJobDepartment(job, 3)
	else//job = Never
		SetJobDepartment(job, 4)

	SetChoices(user)
	return 1

/datum/preferences/proc/ResetJobs()
	job_support_high = 0
	job_support_med = 0
	job_support_low = 0

	job_medsci_high = 0
	job_medsci_med = 0
	job_medsci_low = 0

	job_engsec_high = 0
	job_engsec_med = 0
	job_engsec_low = 0

	job_karma_high = 0
	job_karma_med = 0
	job_karma_low = 0


/datum/preferences/proc/GetJobDepartment(var/datum/job/job, var/level)
	if(!job || !level)	return 0
	switch(job.department_flag)
		if(SUPPORT)
			switch(level)
				if(1)
					return job_support_high
				if(2)
					return job_support_med
				if(3)
					return job_support_low
		if(MEDSCI)
			switch(level)
				if(1)
					return job_medsci_high
				if(2)
					return job_medsci_med
				if(3)
					return job_medsci_low
		if(ENGSEC)
			switch(level)
				if(1)
					return job_engsec_high
				if(2)
					return job_engsec_med
				if(3)
					return job_engsec_low
		if(KARMA)
			switch(level)
				if(1)
					return job_karma_high
				if(2)
					return job_karma_med
				if(3)
					return job_karma_low
	return 0

/datum/preferences/proc/SetJobDepartment(var/datum/job/job, var/level)
	if(!job || !level)	return 0
	switch(level)
		if(1)//Only one of these should ever be active at once so clear them all here
			job_support_high = 0
			job_medsci_high = 0
			job_engsec_high = 0
			job_karma_high = 0
			return 1
		if(2)//Set current highs to med, then reset them
			job_support_med |= job_support_high
			job_medsci_med |= job_medsci_high
			job_engsec_med |= job_engsec_high
			job_karma_med |= job_karma_high
			job_support_high = 0
			job_medsci_high = 0
			job_engsec_high = 0
			job_karma_high = 0

	switch(job.department_flag)
		if(SUPPORT)
			switch(level)
				if(2)
					job_support_high = job.flag
					job_support_med &= ~job.flag
				if(3)
					job_support_med |= job.flag
					job_support_low &= ~job.flag
				else
					job_support_low |= job.flag
		if(MEDSCI)
			switch(level)
				if(2)
					job_medsci_high = job.flag
					job_medsci_med &= ~job.flag
				if(3)
					job_medsci_med |= job.flag
					job_medsci_low &= ~job.flag
				else
					job_medsci_low |= job.flag
		if(ENGSEC)
			switch(level)
				if(2)
					job_engsec_high = job.flag
					job_engsec_med &= ~job.flag
				if(3)
					job_engsec_med |= job.flag
					job_engsec_low &= ~job.flag
				else
					job_engsec_low |= job.flag
		if(KARMA)
			switch(level)
				if(2)
					job_karma_high = job.flag
					job_karma_med &= ~job.flag
				if(3)
					job_karma_med |= job.flag
					job_karma_low &= ~job.flag
				else
					job_karma_low |= job.flag
	return 1

/datum/preferences/proc/process_link(mob/user, list/href_list)
	if(!user)	return

	if(href_list["preference"] == "job")
		switch(href_list["task"])
			if("close")
				user << browse(null, "window=mob_occupation")
				CharacterCreateProc(user)
			if("reset")
				ResetJobs()
				SetChoices(user)
			if("random")
				if(alternate_option == GET_RANDOM_JOB || alternate_option == BE_CIVILIAN)
					alternate_option += 1
				else if(alternate_option == RETURN_TO_LOBBY)
					alternate_option = 0
				else
					return 0
				SetChoices(user)
			if("alt_title")
				var/datum/job/job = locate(href_list["job"])
				if(job)
					var/choices = list(job.title) + job.alt_titles
					var/choice = input("Pick a title for [job.title].", "Character Generation", GetPlayerAltTitle(job)) as anything in choices | null
					if(choice)
						SetPlayerAltTitle(job, choice)
						SetChoices(user)
			if("input")
				SetJob(user, href_list["text"])
			if("setJobLevel")
				UpdateJobPreference(user, href_list["text"], text2num(href_list["level"]))
			else
				SetChoices(user)
		return 1

	if(href_list["preference"] == "cert")
		switch(href_list["task"])
			if("select")
				var/list/ch = list()
				var/list/nam = list()
				for(var/Co in subtypesof(/datum/cert))
					var/datum/cert/C = new Co()
					if (C.uid == "intern")
						ch[C.title] = C.uid
						nam += C.title
						nam += "Cancel"
						continue
					for(var/id in cert_whitelist)
						if (C.uid == id)
							nam += C.title
							ch[C.title] = C.uid
				if (!isemptylist(nam))
					var/choo = "Intern"
					choo = input("Pick your starting role. Access to additional starts can be gained through experience", "Character Generation", "intern") as anything in nam
					if (choo == "Cancel")
						return 1
					primary_cert = ch[choo] // CHOO CHOO PERSISTANT TRAIN IS COMING TO STATION
				else
					primary_cert = "intern"
		CharacterCreateProc(user)
		return 1


	else if(href_list["preference"] == "disabilities")

		switch(href_list["task"])
			if("close")
				user << browse(null, "window=disabil")
				CharacterCreateProc(user)
			if("reset")
				disabilities=0
				SetDisabilities(user)
			if("input")
				var/dflag=text2num(href_list["disability"])
				if(dflag >= 0)
					if(!(dflag==DISABILITY_FLAG_FAT && species!=("Human" || "Tajaran" || "Grey")))
						disabilities ^= text2num(href_list["disability"]) //MAGIC
				SetDisabilities(user)
			else
				SetDisabilities(user)
		return 1

	else if(href_list["preference"] == "records")
		if(text2num(href_list["record"]) >= 1)
			SetRecords(user)
			return
		else
			user << browse(null, "window=records")
		if(href_list["task"] == "med_record")
			var/medmsg = input(usr,"Set your medical notes here.","Medical Records",html_decode(med_record)) as message

			if(medmsg != null)
				medmsg = copytext(medmsg, 1, MAX_PAPER_MESSAGE_LEN)
				medmsg = html_encode(medmsg)

				med_record = medmsg
				SetRecords(user)

		if(href_list["task"] == "sec_record")
			var/secmsg = input(usr,"Set your security notes here.","Security Records",html_decode(sec_record)) as message

			if(secmsg != null)
				secmsg = copytext(secmsg, 1, MAX_PAPER_MESSAGE_LEN)
				secmsg = html_encode(secmsg)

				sec_record = secmsg
				SetRecords(user)
		if(href_list["task"] == "gen_record")
			var/genmsg = input(usr,"Set your employment notes here.","Employment Records",html_decode(gen_record)) as message

			if(genmsg != null)
				genmsg = copytext(genmsg, 1, MAX_PAPER_MESSAGE_LEN)
				genmsg = html_encode(genmsg)

				gen_record = genmsg
				SetRecords(user)

	if(href_list["preference"] == "gear")
		if(href_list["toggle_gear"])
			var/datum/gear/TG = gear_datums[href_list["toggle_gear"]]
			if(TG.display_name in gear)
				gear -= TG.display_name
			else
				var/total_cost = 0
				var/list/type_blacklist = list()
				for(var/gear_name in gear)
					var/datum/gear/G = gear_datums[gear_name]
					if(istype(G))
						if(!G.subtype_cost_overlap)
							if(G.subtype_path in type_blacklist)
								continue
							type_blacklist += G.subtype_path
						total_cost += G.cost

				if((total_cost + TG.cost) <= MAX_GEAR_COST)
					gear += TG.display_name

		else if(href_list["gear"] && href_list["tweak"])
			var/datum/gear/gear = gear_datums[href_list["gear"]]
			var/datum/gear_tweak/tweak = locate(href_list["tweak"])
			if(!tweak || !istype(gear) || !(tweak in gear.gear_tweaks))
				return
			var/metadata = tweak.get_metadata(user, get_tweak_metadata(gear, tweak))
			if(!metadata || !CanUseTopic(user))
				return
			set_tweak_metadata(gear, tweak, metadata)
		else if(href_list["select_category"])
			gear_tab = href_list["select_category"]
		else if(href_list["clear_loadout"])
			gear.Cut()

		CharacterCreateProc(user)
		return

	switch(href_list["task"])
		if("random")
			switch(href_list["preference"])
				if("name")
					real_name = random_name(gender,species)
				if("age")
					age = rand(AGE_MIN, AGE_MAX)
				if("hair")
					if(species in list("Human", "Unathi", "Tajaran", "Skrell", "Machine", "Wryn", "Vulpkanin", "Vox"))
						r_hair = rand(0,255)
						g_hair = rand(0,255)
						b_hair = rand(0,255)
				if("h_style")
					h_style = random_hair_style(gender, species)
				if("facial")
					if(species in list("Human", "Unathi", "Tajaran", "Skrell", "Machine", "Wryn", "Vulpkanin", "Vox"))
						r_facial = rand(0,255)
						g_facial = rand(0,255)
						b_facial = rand(0,255)
				if("f_style")
					f_style = random_facial_hair_style(gender, species)
				if("underwear")
					underwear = random_underwear(gender)
					CharacterCreateProc(user)
				if("undershirt")
					undershirt = random_undershirt(gender)
					CharacterCreateProc(user)
				if("socks")
					socks = random_socks(gender)
					CharacterCreateProc(user)
				if("eyes")
					r_eyes = rand(0,255)
					g_eyes = rand(0,255)
					b_eyes = rand(0,255)
				if("s_tone")
					if(species in list("Human", "Drask", "Vox"))
						s_tone = random_skin_tone()
				if("s_color")
					if(species in list("Unathi", "Tajaran", "Skrell", "Slime People", "Wryn", "Vulpkanin", "Machine"))
						r_skin = rand(0,255)
						g_skin = rand(0,255)
						b_skin = rand(0,255)
				if("bag")
					backbag = rand(1,4)
				/*if("skin_style")
					h_style = random_skin_style(gender)*/
				if("all")
					random_character()
		if("input")
			switch(href_list["preference"])
				if("name")
					var/raw_name = input(user, "Choose your character's name:", "Character Preference") as text|null
					if(!isnull(raw_name)) // Check to ensure that the user entered text (rather than cancel.)
						var/new_name = reject_bad_name(raw_name)
						if(new_name)
							real_name = new_name
						else
							to_chat(user, "<font color='red'>Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z, -, ' and .</font>")


				if("altname")
					var/raw_name = input(user, "Choose your character's name:", "Character Preference") as text|null
					if(!isnull(raw_name)) // Check to ensure that the user entered text (rather than cancel.)
						var/new_name = reject_bad_name(raw_name)
						if(new_name)
							real_name = new_name
						else
							to_chat(user, "<font color='red'>Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z, -, ' and .</font>")


				if("age")
					var/new_age = input(user, "Choose your character's age:\n([AGE_MIN]-[AGE_MAX])", "Character Preference") as num|null
					if(new_age)
						age = max(min( round(text2num(new_age)), AGE_MAX),AGE_MIN)
				if("species")

					var/list/new_species = list("Human", "Tajaran", "Skrell", "Unathi", "Diona", "Vulpkanin")
					var/prev_species = species
//						var/whitelisted = 0

					if(config.usealienwhitelist) //If we're using the whitelist, make sure to check it!
						for(var/S in whitelisted_species)
							if(is_alien_whitelisted(user,S))
								new_species += S
//									whitelisted = 1
//							if(!whitelisted)
//								alert(user, "You cannot change your species as you need to be whitelisted. If you wish to be whitelisted contact an admin in-game, on the forums, or on IRC.")
					else //Not using the whitelist? Aliens for everyone!
						new_species += whitelisted_species

					species = input("Please select a species", "Character Generation", null) in new_species

					if(prev_species != species)
						//grab one of the valid hair styles for the newly chosen species
						var/list/valid_hairstyles = list()
						for(var/hairstyle in hair_styles_list)
							var/datum/sprite_accessory/S = hair_styles_list[hairstyle]
							if(gender == MALE && S.gender == FEMALE)
								continue
							if(gender == FEMALE && S.gender == MALE)
								continue
							if(!(species in S.species_allowed))
								continue

							valid_hairstyles[hairstyle] = hair_styles_list[hairstyle]

						if(valid_hairstyles.len)
							h_style = pick(valid_hairstyles)
						else
							//this shouldn't happen
							h_style = hair_styles_list["Bald"]

						//grab one of the valid facial hair styles for the newly chosen species
						var/list/valid_facialhairstyles = list()
						for(var/facialhairstyle in facial_hair_styles_list)
							var/datum/sprite_accessory/S = facial_hair_styles_list[facialhairstyle]
							if(gender == MALE && S.gender == FEMALE)
								continue
							if(gender == FEMALE && S.gender == MALE)
								continue
							if(!(species in S.species_allowed))
								continue

							valid_facialhairstyles[facialhairstyle] = facial_hair_styles_list[facialhairstyle]

						if(valid_facialhairstyles.len)
							f_style = pick(valid_facialhairstyles)
						else
							//this shouldn't happen
							f_style = facial_hair_styles_list["Shaved"]

						// Don't wear another species' underwear!
						var/datum/sprite_accessory/S = underwear_list[underwear]
						if(!S || !(species in S.species_allowed))
							underwear = random_underwear(gender, species)

						S = undershirt_list[undershirt]
						if(!S || !(species in S.species_allowed))
							undershirt = random_undershirt(gender, species)

						S = socks_list[socks]
						if(!S || !(species in S.species_allowed))
							socks = random_socks(gender, species)

						//reset hair colour and skin colour
						r_hair = 0//hex2num(copytext(new_hair, 2, 4))
						g_hair = 0//hex2num(copytext(new_hair, 4, 6))
						b_hair = 0//hex2num(copytext(new_hair, 6, 8))

						s_tone = 0

						if(!(species in list("Unathi", "Tajaran", "Skrell", "Slime People", "Vulpkanin", "Machine")))
							r_skin = 0
							g_skin = 0
							b_skin = 0

						ha_style = "None" // No Vulp ears on Unathi
						m_style = "None" // No Unathi markings on Tajara

						body_accessory = null //no vulptail on humans damnit

						//Reset prosthetics.
						organ_data = list()
						rlimb_data = list()
				if("speciesprefs")//oldvox code
					speciesprefs = !speciesprefs

				if("language")
//						var/languages_available
					var/list/new_languages = list("None")
/*
					if(config.usealienwhitelist)
						for(var/L in all_languages)
							var/datum/language/lang = all_languages[L]
							if((!(lang.flags & RESTRICTED)) && (is_alien_whitelisted(user, L)||(!( lang.flags & WHITELISTED ))))
								new_languages += lang
								languages_available = 1

						if(!(languages_available))
							alert(user, "There are not currently any available secondary languages.")
					else
*/
					for(var/L in all_languages)
						var/datum/language/lang = all_languages[L]
						if(!(lang.flags & RESTRICTED))
							new_languages += lang.name

					language = input("Please select a secondary language", "Character Generation", null) in new_languages

				if("metadata")
					var/new_metadata = input(user, "Enter any information you'd like others to see, such as Roleplay-preferences:", "Game Preference" , metadata)  as message|null
					if(new_metadata)
						metadata = sanitize(copytext(new_metadata,1,MAX_MESSAGE_LEN))

				if("b_type")
					var/new_b_type = input(user, "Choose your character's blood-type:", "Character Preference") as null|anything in list( "A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-" )
					if(new_b_type)
						b_type = new_b_type

				if("hair")
					if(species in list("Human", "Unathi", "Tajaran", "Skrell", "Machine", "Vulpkanin", "Vox"))
						var/input = "Choose your character's hair colour:"
						var/new_hair = input(user, input, "Character Preference", rgb(r_hair, g_hair, b_hair)) as color|null
						if(new_hair)
							r_hair = hex2num(copytext(new_hair, 2, 4))
							g_hair = hex2num(copytext(new_hair, 4, 6))
							b_hair = hex2num(copytext(new_hair, 6, 8))

				if("h_style")
					var/list/valid_hairstyles = list()
					for(var/hairstyle in hair_styles_list)
						var/datum/sprite_accessory/S = hair_styles_list[hairstyle]
						if(species == "Machine") //Species that can use prosthetic heads.
							var/obj/item/organ/external/head/H = new()
							if(S.name == "Bald")
								valid_hairstyles[hairstyle] = S
							if(!rlimb_data["head"]) //Handle situations where the head is default.
								H.model = "Morpheus Cyberkinetics"
							else
								H.model = rlimb_data["head"]
							var/datum/robolimb/robohead = all_robolimbs[H.model]
							if(species in S.species_allowed)
								if(robohead.is_monitor && (robohead.company in S.models_allowed)) //If the Machine character has the default Morpheus screen head or another screen head
																														   //and said head is in the hair style's allowed models list...
									valid_hairstyles[hairstyle] = S //Allow them to select the hairstyle.
								continue
							else
								if(robohead.is_monitor) //Monitors (incl. the default morpheus head) cannot have wigs (human hairstyles).
									continue
								else if(!robohead.is_monitor && ("Human" in S.species_allowed))
									valid_hairstyles[hairstyle] = S
								continue
						else
							if(!(species in S.species_allowed))
								continue

							valid_hairstyles[hairstyle] = S

					var/new_h_style = input(user, "Choose your character's hair style:", "Character Preference") as null|anything in valid_hairstyles
					if(new_h_style)
						h_style = new_h_style

				if("headaccessory")
					if(species in list("Unathi", "Vulpkanin", "Tajaran", "Machine")) //Species with head accessories.
						var/input = "Choose the colour of your your character's head accessory:"
						var/new_head_accessory = input(user, input, "Character Preference", rgb(r_headacc, g_headacc, b_headacc)) as color|null
						if(new_head_accessory)
							r_headacc = hex2num(copytext(new_head_accessory, 2, 4))
							g_headacc = hex2num(copytext(new_head_accessory, 4, 6))
							b_headacc = hex2num(copytext(new_head_accessory, 6, 8))

				if("ha_style")
					if(species in list("Unathi", "Vulpkanin", "Tajaran", "Machine")) //Species with head accessories.
						var/list/valid_head_accessory_styles = list()
						for(var/head_accessory_style in head_accessory_styles_list)
							var/datum/sprite_accessory/H = head_accessory_styles_list[head_accessory_style]
							if(!(species in H.species_allowed))
								continue

							valid_head_accessory_styles[head_accessory_style] = head_accessory_styles_list[head_accessory_style]

						var/new_head_accessory_style = input(user, "Choose the style of your character's head accessory:", "Character Preference") as null|anything in valid_head_accessory_styles
						if(new_head_accessory_style)
							ha_style = new_head_accessory_style

				if("markings")
					if(species in list("Unathi", "Vulpkanin", "Tajaran", "Machine")) //Species with markings.
						var/input = "Choose the colour of your your character's markings:"
						var/new_markings = input(user, input, "Character Preference", rgb(r_markings, g_markings, b_markings)) as color|null
						if(new_markings)
							r_markings = hex2num(copytext(new_markings, 2, 4))
							g_markings = hex2num(copytext(new_markings, 4, 6))
							b_markings = hex2num(copytext(new_markings, 6, 8))

				if("m_style")
					if(species in list("Unathi", "Vulpkanin", "Tajaran", "Machine")) //Species with markings.
						var/list/valid_markings = list()
						for(var/markingstyle in marking_styles_list)
							var/datum/sprite_accessory/M = marking_styles_list[markingstyle]
							if(!(species in M.species_allowed))
								continue

							if(species == "Machine") //Species that can use prosthetic heads.
								var/obj/item/organ/external/head/H = new()
								if(!rlimb_data["head"]) //Handle situations where the head is default.
									H.model = "Morpheus Cyberkinetics"
								else
									H.model = rlimb_data["head"]
								var/datum/robolimb/robohead = all_robolimbs[H.model]
								if(robohead.is_monitor && M.name != "None") //If the character can have prosthetic heads and they have the default Morpheus head (or another monitor-head), no optic markings.
									continue
								else if(!robohead.is_monitor && M.name != "None") //Otherwise, if they DON'T have the default head and the head's not a monitor but the head's not in the style's list of allowed models, skip.
									if(!(robohead.company in M.models_allowed))
										continue

							valid_markings[markingstyle] = marking_styles_list[markingstyle]

						var/new_marking_style = input(user, "Choose the style of your character's markings:", "Character Preference", m_style) as null|anything in valid_markings
						if(new_marking_style)
							m_style = new_marking_style

				if("body_accessory")
					var/list/possible_body_accessories = list()
					if(check_rights(R_ADMIN, 1, user))
						possible_body_accessories = body_accessory_by_name.Copy()
					else
						for(var/B in body_accessory_by_name)
							var/datum/body_accessory/accessory = body_accessory_by_name[B]
							if(!istype(accessory))
								possible_body_accessories += "None" //the only null entry should be the "None" option
								continue
							if(species in accessory.allowed_species)
								possible_body_accessories += B

					var/new_body_accessory = input(user, "Choose your body accessory:", "Character Preference") as null|anything in possible_body_accessories
					if(new_body_accessory)
						body_accessory = (new_body_accessory == "None") ? null : new_body_accessory

				if("facial")
					if(species in list("Human", "Unathi", "Tajaran", "Skrell", "Machine", "Vulpkanin", "Vox"))
						var/new_facial = input(user, "Choose your character's facial-hair colour:", "Character Preference", rgb(r_facial, g_facial, b_facial)) as color|null
						if(new_facial)
							r_facial = hex2num(copytext(new_facial, 2, 4))
							g_facial = hex2num(copytext(new_facial, 4, 6))
							b_facial = hex2num(copytext(new_facial, 6, 8))

				if("f_style")
					var/list/valid_facialhairstyles = list()
					for(var/facialhairstyle in facial_hair_styles_list)
						var/datum/sprite_accessory/S = facial_hair_styles_list[facialhairstyle]
						if(S.name == "Shaved")
							valid_facialhairstyles[facialhairstyle] = S
						if(gender == MALE && S.gender == FEMALE)
							continue
						if(gender == FEMALE && S.gender == MALE)
							continue
						if(species == "Machine") //Species that can use prosthetic heads.
							var/obj/item/organ/external/head/H = new()
							if(!rlimb_data["head"]) //Handle situations where the head is default.
								H.model = "Morpheus Cyberkinetics"
							else
								H.model = rlimb_data["head"]
							var/datum/robolimb/robohead = all_robolimbs[H.model]
							if(species in S.species_allowed)
								if(robohead.is_monitor) //If the Machine character has the default Morpheus screen head or another screen head and they're allowed to have the style, let them have it.
									valid_facialhairstyles[facialhairstyle] = S
								continue
							else
								if(robohead.is_monitor) //Monitors (incl. the default morpheus head) cannot have wigs (human facial hairstyles).
									continue
								else if(!robohead.is_monitor && ("Human" in S.species_allowed))
									valid_facialhairstyles[facialhairstyle] = S
								continue
						else
							if(!(species in S.species_allowed))
								continue

						valid_facialhairstyles[facialhairstyle] = facial_hair_styles_list[facialhairstyle]

					var/new_f_style = input(user, "Choose your character's facial-hair style:", "Character Preference")  as null|anything in valid_facialhairstyles
					if(new_f_style)
						f_style = new_f_style

				if("underwear")
					var/list/underwear_options
					if(gender == MALE)
						underwear_options = underwear_m
					else
						underwear_options = underwear_f

					var/new_underwear = input(user, "Choose your character's underwear:", "Character Preference")  as null|anything in underwear_options
					if(new_underwear)
						underwear = new_underwear
					CharacterCreateProc(user)

				if("undershirt")
					var/new_undershirt
					if(gender == MALE)
						new_undershirt = input(user, "Choose your character's undershirt:", "Character Preference") as null|anything in undershirt_m
					else
						new_undershirt = input(user, "Choose your character's undershirt:", "Character Preference") as null|anything in undershirt_f
					if(new_undershirt)
						undershirt = new_undershirt
					CharacterCreateProc(user)

				if("socks")
					var/list/valid_sockstyles = list()
					for(var/sockstyle in socks_list)
						var/datum/sprite_accessory/S = socks_list[sockstyle]
						if(gender == MALE && S.gender == FEMALE)
							continue
						if(gender == FEMALE && S.gender == MALE)
							continue
						if(!(species in S.species_allowed))
							continue
						valid_sockstyles[sockstyle] = socks_list[sockstyle]
					var/new_socks = input(user, "Choose your character's socks:", "Character Preference")  as null|anything in valid_sockstyles
					CharacterCreateProc(user)
					if(new_socks)
						socks = new_socks

				if("eyes")
					var/new_eyes = input(user, "Choose your character's eye colour:", "Character Preference", rgb(r_eyes, g_eyes, b_eyes)) as color|null
					if(new_eyes)
						r_eyes = hex2num(copytext(new_eyes, 2, 4))
						g_eyes = hex2num(copytext(new_eyes, 4, 6))
						b_eyes = hex2num(copytext(new_eyes, 6, 8))

				if("s_tone")
					if(species == "Human" || species == "Drask")
						var/new_s_tone = input(user, "Choose your character's skin-tone:\n(Light 1 - 220 Dark)", "Character Preference")  as num|null
						if(new_s_tone)
							s_tone = 35 - max(min(round(new_s_tone), 220), 1)
					else if(species == "Vox")
						var/skin_c = input(user, "Choose your Vox's skin color:\n(1 = Default Green, 2 = Dark Green, 3 = Brown, 4 = Grey, \n5 = Emerald, 6 = Azure)", "Character Preference") as num|null
						if(skin_c)
							s_tone = max(min(round(skin_c), 6), 1)

				if("skin")
					if((species in list("Unathi", "Tajaran", "Skrell", "Slime People", "Vulpkanin", "Machine")) || body_accessory_by_species[species] || check_rights(R_ADMIN, 0, user))
						var/new_skin = input(user, "Choose your character's skin colour: ", "Character Preference", rgb(r_skin, g_skin, b_skin)) as color|null
						if(new_skin)
							r_skin = hex2num(copytext(new_skin, 2, 4))
							g_skin = hex2num(copytext(new_skin, 4, 6))
							b_skin = hex2num(copytext(new_skin, 6, 8))
				if("ooccolor")
					var/new_ooccolor = input(user, "Choose your OOC colour:", "Game Preference", ooccolor) as color|null
					if(new_ooccolor)
						ooccolor = new_ooccolor

				if("bag")
					var/new_backbag = input(user, "Choose your character's style of bag:", "Character Preference")  as null|anything in backbaglist
					if(new_backbag)
						backbag = backbaglist.Find(new_backbag)

				if("nt_relation")
					var/new_relation = input(user, "Choose your relation to NT. Note that this represents what others can find out about your character by researching your background, not what your character actually thinks.", "Character Preference")  as null|anything in list("Loyal", "Supportive", "Neutral", "Skeptical", "Opposed")
					if(new_relation)
						nanotrasen_relation = new_relation

				if("flavor_text")
					var/msg = input(usr,"Set the flavor text in your 'examine' verb. This can also be used for OOC notes and preferences!","Flavor Text",html_decode(flavor_text)) as message

					if(msg != null)
						msg = copytext(msg, 1, MAX_MESSAGE_LEN)
						msg = html_encode(msg)

						flavor_text = msg

				if("limbs")
					var/valid_limbs = list("Left Leg", "Right Leg", "Left Arm", "Right Arm", "Left Foot", "Right Foot", "Left Hand", "Right Hand")
					if(species == "Machine")
						valid_limbs = list("Torso", "Lower Body", "Head", "Left Leg", "Right Leg", "Left Arm", "Right Arm", "Left Foot", "Right Foot", "Left Hand", "Right Hand")
					var/limb_name = input(user, "Which limb do you want to change?") as null|anything in valid_limbs
					if(!limb_name) return

					var/limb = null
					var/second_limb = null // if you try to change the arm, the hand should also change
					var/third_limb = null  // if you try to unchange the hand, the arm should also change
					var/valid_limb_states = list("Normal", "Amputated", "Prosthesis")
					var/no_amputate = 0

					switch(limb_name)
						if("Torso")
							limb = "chest"
							second_limb = "groin"
							no_amputate = 1
						if("Lower Body")
							limb = "groin"
							no_amputate = 1
						if("Head")
							limb = "head"
							no_amputate = 1
						if("Left Leg")
							limb = "l_leg"
							second_limb = "l_foot"
						if("Right Leg")
							limb = "r_leg"
							second_limb = "r_foot"
						if("Left Arm")
							limb = "l_arm"
							second_limb = "l_hand"
						if("Right Arm")
							limb = "r_arm"
							second_limb = "r_hand"
						if("Left Foot")
							limb = "l_foot"
							if(species != "Machine")
								third_limb = "l_leg"
						if("Right Foot")
							limb = "r_foot"
							if(species != "Machine")
								third_limb = "r_leg"
						if("Left Hand")
							limb = "l_hand"
							if(species != "Machine")
								third_limb = "l_arm"
						if("Right Hand")
							limb = "r_hand"
							if(species != "Machine")
								third_limb = "r_arm"

					var/new_state = input(user, "What state do you wish the limb to be in?") as null|anything in valid_limb_states
					if(!new_state) return

					switch(new_state)
						if("Normal")
							if(limb == "head")
								m_style = "None"
								h_style = random_hair_style(gender, species)
								f_style = facial_hair_styles_list["Shaved"]
							organ_data[limb] = null
							rlimb_data[limb] = null
							if(third_limb)
								organ_data[third_limb] = null
								rlimb_data[third_limb] = null
						if("Amputated")
							if(!no_amputate)
								organ_data[limb] = "amputated"
								rlimb_data[limb] = null
								if(second_limb)
									organ_data[second_limb] = "amputated"
									rlimb_data[second_limb] = null
						if("Prosthesis")
							var/choice
							var/subchoice
							var/datum/robolimb/R = new()
							var/in_model
							var/robolimb_companies = list()
							for(var/limb_type in typesof(/datum/robolimb)) //This loop populates a list of companies that offer the limb the user selected previously as one of their cybernetic products.
								R = new limb_type()
								if(!R.unavailable_at_chargen && (limb in R.parts) && R.has_subtypes) //Ensures users can only choose companies that offer the parts they want, that singular models get added to the list as well companies that offer more than one model, and...
									robolimb_companies[R.company] = R //List only main brands that have the parts we're looking for.
							R = new() //Re-initialize R.

							choice = input(user, "Which manufacturer do you wish to use for this limb?") as null|anything in robolimb_companies //Choose from a list of companies that offer the part the user wants.
							if(!choice)
								return
							R.company = choice
							R = all_robolimbs[R.company]
							if(R.has_subtypes == 1) //If the company the user selected provides more than just one base model, lets handle it.
								var/list/robolimb_models = list()
								for(var/limb_type in typesof(R)) //Handling the different models of parts that manufacturers can provide.
									var/datum/robolimb/L = new limb_type()
									if(limb in L.parts) //Make sure that only models that provide the parts the user needs populate the list.
										robolimb_models[L.company] = L
										if(robolimb_models.len == 1) //If there's only one model available in the list, autoselect it to avoid having to bother the user with a dialog that provides only one option.
											subchoice = L.company //If there ends up being more than one model populating the list, subchoice will be overwritten later anyway, so this isn't a problem.
										if(second_limb in L.parts) //If the child limb of the limb the user selected is also present in the model's parts list, state it's been found so the second limb can be set later.
											in_model = 1
								if(robolimb_models.len > 1) //If there's more than one model in the list that can provide the part the user wants, let them choose.
									subchoice = input(user, "Which model of [choice] [limb_name] do you wish to use?") as null|anything in robolimb_models
								if(subchoice)
									choice = subchoice
							if(limb == "head")
								ha_style = "None"
								h_style = hair_styles_list["Bald"]
								f_style = facial_hair_styles_list["Shaved"]
								m_style = "None"
							rlimb_data[limb] = choice
							organ_data[limb] = "cyborg"
							if(second_limb)
								if(subchoice)
									if(in_model)
										rlimb_data[second_limb] = choice
										organ_data[second_limb] = "cyborg"
								else
									rlimb_data[second_limb] = choice
									organ_data[second_limb] = "cyborg"

				if("organs")
					var/organ_name = input(user, "Which internal function do you want to change?") as null|anything in list("Heart", "Eyes")
					if(!organ_name) return

					var/organ = null
					switch(organ_name)
						if("Heart")
							organ = "heart"
						if("Eyes")
							organ = "eyes"

					var/new_state = input(user, "What state do you wish the organ to be in?") as null|anything in list("Normal","Assisted","Mechanical")
					if(!new_state) return

					switch(new_state)
						if("Normal")
							organ_data[organ] = null
						if("Assisted")
							organ_data[organ] = "assisted"
						if("Mechanical")
							organ_data[organ] = "mechanical"

/*
				if("skin_style")
					var/skin_style_name = input(user, "Select a new skin style") as null|anything in list("default1", "default2", "default3")
					if(!skin_style_name) return
*/

/*					if("spawnpoint")
					var/list/spawnkeys = list()
					for(var/S in spawntypes)
						spawnkeys += S
					var/choice = input(user, "Where would you like to spawn when latejoining?") as null|anything in spawnkeys
					if(!choice || !spawntypes[choice])
						spawnpoint = "Arrivals Shuttle"
						return
					spawnpoint = choice */

		else
			switch(href_list["preference"])
				if("publicity")
					if(unlock_content)
						toggles ^= MEMBER_PUBLIC
					ShowChoices(usr)
					return 1

				if("gender")
					if(gender == MALE)
						gender = FEMALE
					else
						gender = MALE
					underwear = random_underwear(gender)

				if("hear_adminhelps")
					sound ^= SOUND_ADMINHELP
					ShowChoices(usr)
					return 1

				if("ui")
					switch(UI_style)
						if("Midnight")
							UI_style = "Plasmafire"
						if("Plasmafire")
							UI_style = "Retro"
						if("Retro")
							UI_style = "Slimecore"
						if("Slimecore")
							UI_style = "Operative"
						if("Operative")
							UI_style = "White"
						else
							UI_style = "Midnight"

					if(ishuman(usr)) //mid-round preference changes, for aesthetics
						var/mob/living/carbon/human/H = usr
						H.remake_hud()
					ShowChoices(usr)
					return 1
				if("nanoui")
					nanoui_fancy = !nanoui_fancy
					ShowChoices(usr)
					return 1

				if("ghost_att_anim")
					show_ghostitem_attack = !show_ghostitem_attack
					ShowChoices(usr)
					return 1

				if("UIcolor")
					var/UI_style_color_new = input(user, "Choose your UI color, dark colors are not recommended!", UI_style_color) as color|null
					if(!UI_style_color_new) return
					UI_style_color = UI_style_color_new

					if(ishuman(usr)) //mid-round preference changes, for aesthetics
						var/mob/living/carbon/human/H = usr
						H.remake_hud()
					ShowChoices(usr)
					return 1

				if("UIalpha")
					var/UI_style_alpha_new = input(user, "Select a new alpha(transparence) parameter for UI, between 50 and 255", UI_style_alpha) as num
					if(!UI_style_alpha_new | !(UI_style_alpha_new <= 255 && UI_style_alpha_new >= 50)) return
					UI_style_alpha = UI_style_alpha_new

					if(ishuman(usr)) //mid-round preference changes, for aesthetics
						var/mob/living/carbon/human/H = usr
						H.remake_hud()
					ShowChoices(usr)
					return 1
				if("be_special")
					var/r = href_list["role"]
					if(!(r in special_roles))
						var/cleaned_r = sql_sanitize_text(r)
						if(r != cleaned_r) // up to no good
							message_admins("[user] attempted an href exploit! (This could have possibly lead to a \"Bobby Tables\" exploit, so they're probably up to no good). String: [r] ID: [last_id] IP: [last_ip]")
							to_chat(user, "<span class='userdanger'>Stop right there, criminal scum</span>")
					else
						be_special ^= r
					ShowChoices(usr)
					return 1
				if("name")
					be_random_name = !be_random_name

				if("randomslot")
					randomslot = !randomslot
					ShowChoices(usr)
					return 1
				if("hear_midis")
					sound ^= SOUND_MIDI
					ShowChoices(usr)
					return 1
				if("lobby_music")
					sound ^= SOUND_LOBBY
					if(sound & SOUND_LOBBY)
						user << sound(ticker.login_music, repeat = 0, wait = 0, volume = 85, channel = 1)
					else
						user << sound(null, repeat = 0, wait = 0, volume = 85, channel = 1)
					ShowChoices(usr)
					return 1

				if("ghost_ears")
					toggles ^= CHAT_GHOSTEARS
					ShowChoices(usr)
					return 1

				if("ghost_sight")
					toggles ^= CHAT_GHOSTSIGHT
					ShowChoices(usr)
					return 1

				if("ghost_radio")
					toggles ^= CHAT_GHOSTRADIO
					ShowChoices(usr)
					return 1

				if("ghost_radio")
					toggles ^= CHAT_GHOSTRADIO
					ShowChoices(usr)
					return 1

				if("save")
					save_preferences(user)
					close_preferences(user)
					return 1

				if("confirmchar")
					SlotSelect(user)
					return 1
				if("cancelchar")
					close_character_dialog(user)
					return 1
				if("reload")
					load_preferences(user)
					ShowChoices(usr)
					return 1
				if("open_load_dialog")
					if(!IsGuestKey(user.key))
						open_load_dialog(user)
						return 1

				if("close_load_dialog")
					close_load_dialog(user)

				if("changeslot")
					if(!check_mind(user,text2num(href_list["num"])))
						random_character()
						real_name = random_name(gender)
						save_character(user)
					close_load_dialog(user)
				if("changeslotdead")
					to_chat(user, "<span class='userdanger'>The chosen character is dead, you must choose another or purchase cloning.</span>")
					close_load_dialog(user)
					return 1
				if("changeslotlost")
					to_chat(user, "<span class='userdanger'>The chosen character is M.I.A, presumably unrecoverable.</span>")
					close_load_dialog(user)
					return 1
				if("choosechar")
					if(!check_mind(user,text2num(href_list["num"])))
						to_chat(user, "<span class='userdanger'>Character unable to load, contact developer.</span>")
						return
					slot = text2num(href_list["num"])
					close_load_dialog(user)
					return 1
				if("choosecharinvalid")
					to_chat(user, "<span class='userdanger'>No character in that slot.</span>")
					close_load_dialog(user)
					return 1
				if("chooseslot")
					return 1
				if("chooseinvalid")
					to_chat(user, "<span class='userdanger'>Character slot occupied! Choose an open slot or delete a character through the lobby screen.</span>")

				if("tab")
					if(href_list["tab"])
						current_tab = text2num(href_list["tab"])

//	CharacterCreateProc(user)
	return 0

/datum/preferences/proc/setup_newinv(var/user, var/uid = "")
	SE = new /list(DNA_SE_LENGTH)
	UI = new /list(DNA_UI_LENGTH)
	SE_structure = new /list(DNA_SE_LENGTH)
	var/mob/living/carbon/human/H = new /mob/living/carbon/human/()
	copy_2(H)
	switch(backbag)
		if(2) H.equip_or_collect(new /obj/item/weapon/storage/backpack(H), slot_back)
		if(3) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel_norm(H), slot_back)
		if(4) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
	H.equip_or_collect(new /obj/item/clothing/under/color/grey(H), slot_w_uniform)
	H.equip_or_collect(new /obj/item/clothing/shoes/black(H), slot_shoes)
	var/ind = 0
	H.dna.ready_dna(H, flatten_SE = 0)
	for(var/x in H.dna.SE)
		ind += 1
		SE[ind] = H.dna.SE[ind]
	ind = 0
	for(var/x in H.dna.UI)
		ind += 1
		UI[ind] = H.dna.UI[ind]
	ind = 0
	for(var/x in H.dna.SE_structure)
		ind += 1
		if(istype(H.dna.SE_structure[ind], /datum/dna/gene))
			var/datum/dna/gene/gene = H.dna.SE_structure[ind]
			SE_structure[ind] = "[gene.type]"
		else
			SE_structure[ind] = 0
	return H

/datum/preferences/proc/copy_2(mob/living/carbon/human/character)
	var/datum/species/S = all_species[species]
	character.change_species(species) // Yell at me if this causes everything to melt
	if(be_random_name)
		real_name = random_name(gender,species)

	if(config.humans_need_surnames)
		var/firstspace = findtext(real_name, " ")
		var/name_length = length(real_name)
		if(!firstspace)	//we need a surname
			real_name += " [pick(last_names)]"
		else if(firstspace == name_length)
			real_name += "[pick(last_names)]"

	character.add_language(language)

	character.real_name = real_name
	character.dna.real_name = real_name
	character.name = character.real_name

	character.flavor_text = flavor_text
	character.med_record = med_record
	character.sec_record = sec_record
	character.gen_record = gen_record

	character.change_gender(gender)
	character.age = age
	character.b_type = b_type

	character.r_eyes = r_eyes
	character.g_eyes = g_eyes
	character.b_eyes = b_eyes

	//Head-specific
	var/obj/item/organ/external/head/H = character.get_organ("head")
	H.r_hair = r_hair
	H.g_hair = g_hair
	H.b_hair = b_hair

	H.r_facial = r_facial
	H.g_facial = g_facial
	H.b_facial = b_facial

	H.h_style = h_style
	H.f_style = f_style
	//End of head-specific.

	character.r_skin = r_skin
	character.g_skin = g_skin
	character.b_skin = b_skin

	character.s_tone = s_tone

	// Destroy/cyborgize organs
	for(var/name in organ_data)

		var/status = organ_data[name]
		var/obj/item/organ/external/O = character.organs_by_name[name]
		if(O)
			if(status == "amputated")
				character.organs_by_name[O.limb_name] = null
				character.organs -= O
				if(O.children) // This might need to become recursive.
					for(var/obj/item/organ/external/child in O.children)
						character.organs_by_name[child.limb_name] = null
						character.organs -= child

			else if(status == "cyborg")
				if(rlimb_data[name])
					O.robotize(rlimb_data[name])
				else
					O.robotize()
		else
			var/obj/item/organ/internal/I = character.get_int_organ_tag(name)
			if(I)
				if(status == "assisted")
					I.mechassist()
				else if(status == "mechanical")
					I.robotize()

	character.dna.b_type = b_type
	if(disabilities & DISABILITY_FLAG_FAT && character.species.flags & CAN_BE_FAT)
		character.dna.SetSEState(FATBLOCK,1,1)
		character.mutations += FAT
		character.mutations += OBESITY
		character.overeatduration = 600

	if(disabilities & DISABILITY_FLAG_NEARSIGHTED)
		character.dna.SetSEState(GLASSESBLOCK,1,1)
		character.disabilities|=NEARSIGHTED

	if(disabilities & DISABILITY_FLAG_EPILEPTIC)
		character.dna.SetSEState(EPILEPSYBLOCK,1,1)
		character.disabilities|=EPILEPSY

	if(disabilities & DISABILITY_FLAG_DEAF)
		character.dna.SetSEState(DEAFBLOCK,1,1)
		character.disabilities|=DEAF

	if(disabilities & DISABILITY_FLAG_BLIND)
		character.dna.SetSEState(BLINDBLOCK,1,1)
		character.disabilities|=BLIND

	if(disabilities & DISABILITY_FLAG_MUTE)
		character.dna.SetSEState(MUTEBLOCK,1,1)
		character.disabilities |= MUTE

	S.handle_dna(character)

	if(character.dna.dirtySE)
		character.dna.UpdateSE()
	domutcheck(character)

	// Wheelchair necessary?
	var/obj/item/organ/external/l_foot = character.get_organ("l_foot")
	var/obj/item/organ/external/r_foot = character.get_organ("r_foot")
	if((!l_foot || l_foot.status & ORGAN_DESTROYED) && (!r_foot || r_foot.status & ORGAN_DESTROYED))
		var/obj/structure/stool/bed/chair/wheelchair/W = new /obj/structure/stool/bed/chair/wheelchair (character.loc)
		character.buckled = W
		character.update_canmove()
		W.dir = character.dir
		W.buckled_mob = character
		W.add_fingerprint(character)

	character.underwear = underwear
	character.undershirt = undershirt
	character.socks = socks

	if(character.species.bodyflags & HAS_HEAD_ACCESSORY)
		H.r_headacc = r_headacc
		H.g_headacc = g_headacc
		H.b_headacc = b_headacc
		H.ha_style = ha_style
	if(character.species.bodyflags & HAS_MARKINGS)
		character.r_markings = r_markings
		character.g_markings = g_markings
		character.b_markings = b_markings
		character.m_style = m_style

	if(body_accessory)
		character.body_accessory = body_accessory_by_name["[body_accessory]"]

	if(backbag > 4 || backbag < 1)
		backbag = 1 //Same as above
	character.backbag = backbag

	//Debugging report to track down a bug, which randomly assigned the plural gender to people.
	if(character.gender in list(PLURAL, NEUTER))
		if(isliving(src)) //Ghosts get neuter by default
			message_admins("[key_name_admin(character)] has spawned with their gender as plural or neuter. Please notify coders.")
			character.change_gender(MALE)

	character.dna.ready_dna(character, flatten_SE = 0)
	character.sync_organ_dna(assimilate=1)
	character.UpdateAppearance()

	// Do the initial caching of the player's body icons.
	character.force_update_limbs()
	character.update_eyes()
	character.regenerate_icons()

/datum/preferences/proc/setup_ranks()
	var/list/ranks = get_standard_departments()
	department_ranks = list()
	for(var/a in ranks)
		var/stringrank = to_strings(a)
		department_ranks += list("[stringrank]" = 1)

/datum/preferences/proc/copy_to(mob/living/carbon/human/character, var/firstTime = 0)
	var/datum/species/S = all_species[species]
	character.change_species(species) // Yell at me if this causes everything to melt

	character.add_language(language)

	character.real_name = real_name
	character.dna.real_name = real_name
	character.name = character.real_name

	character.flavor_text = flavor_text
	character.med_record = med_record
	character.sec_record = sec_record
	character.gen_record = gen_record

	character.change_gender(gender)
	character.age = age
	character.b_type = b_type
	character.r_eyes = r_eyes
	character.g_eyes = g_eyes
	character.b_eyes = b_eyes

	//Head-specific
	var/obj/item/organ/external/head/H = character.get_organ("head")
	H.r_hair = r_hair
	H.g_hair = g_hair
	H.b_hair = b_hair

	H.r_facial = r_facial
	H.g_facial = g_facial
	H.b_facial = b_facial

	H.h_style = h_style
	H.f_style = f_style
	//End of head-specific.

	character.r_skin = r_skin
	character.g_skin = g_skin
	character.b_skin = b_skin

	character.s_tone = s_tone
	character.underwear = underwear
	character.undershirt = undershirt
	character.socks = socks

	if(character.species.bodyflags & HAS_HEAD_ACCESSORY)
		H.r_headacc = r_headacc
		H.g_headacc = g_headacc
		H.b_headacc = b_headacc
		H.ha_style = ha_style
	if(character.species.bodyflags & HAS_MARKINGS)
		character.r_markings = r_markings
		character.g_markings = g_markings
		character.b_markings = b_markings
		character.m_style = m_style

	if(body_accessory)
		character.body_accessory = body_accessory_by_name["[body_accessory]"]

	if(backbag > 4 || backbag < 1)
		backbag = 1 //Same as above
	character.backbag = backbag

	//Debugging report to track down a bug, which randomly assigned the plural gender to people.
	if(character.gender in list(PLURAL, NEUTER))
		if(isliving(src)) //Ghosts get neuter by default
			message_admins("[key_name_admin(character)] has spawned with their gender as plural or neuter. Please notify coders.")
			character.change_gender(MALE)

	character.dna.ready_dna(character, flatten_SE = firstTime)
	character.sync_organ_dna(assimilate=1)
	character.UpdateAppearance()

	// Do the initial caching of the player's body icons.
	character.force_update_limbs()
	character.update_eyes()
	character.regenerate_icons()



/datum/preferences/proc/check_inv(var/mob/living/carbon/human/H) // gets the inventory for a humanoid body
	var/obj/temp
	brain = list()
	for(var/obj/item/weapon/implant/I in H.contents)
		if(I && I.implanted)
			brain += save_item(src, I)


	temp = H.get_item_by_slot(slot_w_uniform)
	if (istype(temp, /obj/))
		slot_w_uniform_pref = save_item(src, temp)
	else
		slot_w_uniform_pref = 0
	temp = H.get_item_by_slot(slot_wear_suit)
	if (istype(temp, /obj/))
		slot_wear_suit_pref = save_item(src, temp)
	else
		slot_wear_suit_pref = 0
	temp = H.get_item_by_slot(slot_shoes)
	if (istype(temp, /obj/))
		slot_shoes_pref = save_item(src, temp)
	else
		slot_shoes_pref = 0
	temp = H.get_item_by_slot(slot_gloves)
	if (istype(temp, /obj/))
		slot_gloves_pref = save_item(src, temp)
	else
		slot_gloves_pref = 0
	temp = H.get_item_by_slot(slot_l_ear)
	if (istype(temp, /obj/))
		slot_l_ear_pref = save_item(src, temp)
	else
		slot_l_ear_pref = 0
	temp = H.get_item_by_slot(slot_glasses)
	if (istype(temp, /obj/))
		slot_glasses_pref = save_item(src, temp)
	else
		slot_glasses_pref = 0
	temp = H.get_item_by_slot(slot_wear_mask)
	if (istype(temp, /obj/))
		slot_wear_mask_pref = save_item(src, temp)
	else
		slot_wear_mask_pref = 0
	temp = H.get_item_by_slot(slot_head)
	if (istype(temp, /obj/))
		slot_head_pref = save_item(src, temp)
	else
		slot_head_pref = 0
	temp = H.get_item_by_slot(slot_belt)
	if (istype(temp, /obj/))
		slot_belt_pref = save_item(src, temp)
	else
		slot_belt_pref = 0
	temp = H.get_item_by_slot(slot_r_store)
	if (istype(temp, /obj/))
		slot_r_store_pref = save_item(src, temp)
	else
		slot_r_store_pref = 0
	temp = H.get_item_by_slot(slot_l_store)
	if (istype(temp, /obj/))
		slot_l_store_pref = save_item(src, temp)
	else
		slot_l_store_pref = 0
	temp = H.get_item_by_slot(slot_back)
	if (istype(temp, /obj/))
		slot_back_pref = save_item(src, temp)
	else
		slot_back_pref = 0
	temp = H.get_item_by_slot(slot_wear_id)
	if (istype(temp, /obj/))
		slot_wear_id_pref = save_item(src, temp)
	else
		slot_wear_id_pref = 0
	temp = H.get_item_by_slot(slot_wear_pda)
	if (istype(temp, /obj/))
		slot_wear_pda_pref = save_item(src, temp)
	else
		slot_wear_pda_pref = 0
	temp = H.get_item_by_slot(slot_handcuffed)
	if (istype(temp, /obj/))
		slot_handcuffed_pref = save_item(src, temp)
	else
		slot_handcuffed_pref = 0
	temp = H.get_item_by_slot(slot_s_store)
	if (istype(temp, /obj/))
		slot_s_store_pref = save_item(src, temp)
	else
		slot_s_store_pref = 0
	temp = H.get_item_by_slot(slot_legcuffed)
	if (istype(temp, /obj/))
		slot_legcuffed_pref = save_item(src, temp)
	else
		slot_legcuffed_pref = 0
	temp = H.get_item_by_slot(slot_r_ear)
	if (istype(temp, /obj/))
		slot_r_ear_pref = save_item(src, temp)
	else
		slot_r_ear_pref = 0
	temp = H.get_item_by_slot(slot_r_hand)
	if (istype(temp, /obj/))
		slot_r_hand_pref = save_item(src, temp)
	else
		slot_r_hand_pref = 0
	temp = H.get_item_by_slot(slot_l_hand)
	if (istype(temp, /obj/))
		slot_l_hand_pref = save_item(src, temp)
	else
		slot_l_hand_pref = 0
	temp = H.get_item_by_slot(slot_underwear)
	if (istype(temp, /obj/))
		slot_underwear_pref = save_item(src, temp)
	else
		slot_underwear_pref = 0
	temp = H.get_item_by_slot(slot_undershirt)
	if (istype(temp, /obj/))
		slot_undershirt_pref = save_item(src, temp)
	else
		slot_undershirt_pref = 0
	temp = null
	qdel(temp)



/datum/preferences/proc/check_robot(var/mob/living/silicon/robot/H) // SAVES CYBORG BODIES


/datum/preferences/proc/check_body(var/mob/living/carbon/human/H) // SAVES HUMANOID BODIES
	SE = new /list(DNA_SE_LENGTH)
	UI = new /list(DNA_UI_LENGTH)
	SE_structure = new /list(DNA_SE_LENGTH)
	var/turf/location = get_turf(H.loc)
	if(!location)
		current_status = "lost"
	if(location.loc.type == shuttle_master.emergency.areaInstance.type)
		if(H.stat != DEAD)
			current_status = "alive"
		else
			current_status = "dead"

	else
		switch(location.loc.type)
			if(/area/shuttle/escape_pod1/centcom, /area/shuttle/escape_pod2/centcom, /area/shuttle/escape_pod3/centcom, /area/shuttle/escape_pod5/centcom, /area/centcom, /area/shuttle/transport1, /area/shuttle/administration/centcom/, /area/shuttle/specops/centcom)
				if(H.stat != DEAD)
					current_status = "alive"
				else
					current_status = "dead"
			else
				current_status = "lost"

	if(istype(H.dna))
		message_admins("FOUND DNA")
		var/ind = 0
		for(var/x in H.dna.SE)
			ind += 1
			SE[ind] = H.dna.SE[ind]
		ind = 0
		for(var/x in H.dna.UI)
			ind += 1
			UI[ind] = H.dna.UI[ind]
		ind = 0
		for(var/x in H.dna.SE_structure)
			ind += 1
			if(istype(H.dna.SE_structure[ind], /datum/dna/gene))
				var/datum/dna/gene/gene = H.dna.SE_structure[ind]
				SE_structure[ind] = "[gene.type]"
			else
				SE_structure[ind] = 0

	else
		SE = null
		UI = null
		SE_structure = null
		message_admins("No DNA found for [H]")

	var/obj/item/organ/external/head/He = H.get_organ("head")
	if(He)
		r_hair = He.r_hair
		g_hair = He.g_hair
		b_hair = He.b_hair
		r_facial = He.r_facial
		g_facial = He.g_facial
		r_facial = He.b_facial
		h_style = He.h_style
		f_style	= He.f_style
		ha_style = He.ha_style
		r_headacc = He.r_headacc
		g_headacc = He.g_headacc
		b_headacc = He.b_headacc
	else
		r_hair = 1
		g_hair = 1
		b_hair = 1
		r_facial = 1
		g_facial = 1
		b_facial = 1
		h_style = "Bald"
		f_style	= "Shaved"
		ha_style = "None"
		r_headacc = 1
		g_headacc = 1
		b_headacc = 1
	gender = H.gender
	age = H.age
	r_eyes = H.r_eyes
	g_eyes = H.g_eyes
	b_eyes = H.b_eyes
	r_skin = H.r_skin
	g_skin = H.g_skin
	b_skin = H.b_skin
	m_style = H.m_style
	r_markings = H.r_markings
	g_markings = H.g_markings
	b_markings = H.b_markings
	flavor_text = H.flavor_text
	b_type = H.b_type
	// implants left in the body need to save here
	// a wound system for each organ should be implemented
	// disease saving
	//
	check_inv(H)

	var/list/types_of_int_organs = list() //This will hold all the types of organs in the mob before rejuvenation.
	for(var/obj/item/organ/internal/I in H.internal_organs)
		types_of_int_organs |= I.type //Compiling the list of organ types. It is possible for organs to be missing from this list if they are absent from the mob.

	//Replacing lost limbs with the species default.
	var/mob/living/carbon/human/temp_holder
	for(var/limb_type in H.species.has_limbs)
		var/obj/item/organ/external/org = H.get_organ(limb_type)
		if (!org || org.is_stump())
			organ_data[limb_type] = "amputated"

		else if(org.status & ORGAN_ROBOT)

			organ_data[limb_type] = "cyborg"

		else if(org.species == H.species)

			organ_data[limb_type] = null

		else
			organ_data[limb_type] = "[org.species]"


	//Replacing lost organs with the species default.
	temp_holder = new /mob/living/carbon/human()
	for(var/index in H.species.has_organ)
		var/organ = H.species.has_organ[index]
		if(!(organ in types_of_int_organs))	//If the mob is missing this particular organ...
			var/obj/item/organ/internal/I = new organ(temp_holder) //Create the organ inside our holder so we can check it before implantation.
			if(H.get_organ_slot(I.slot)) //Check to see if the user already has an organ in the slot the 'missing organ' belongs to. If they do, skip implantation.
				organ_data[index] = I.species	//In an example, this will prevent duplication of the mob's eyes if the mob is a Human and they have Nucleation eyes, since,
										//while the organ in the eyes slot may not be listed in the mob's species' organs definition, it is still viable and fits in the appropriate organ slot.
			else
				organ_data[index] = "amputated"
		else
			organ_data[index] = null



/datum/preferences/proc/check_char(var/mob/living/carbon/human/H) // checks for changes before saving the char
	SE = new /list(DNA_SE_LENGTH)
	UI = new /list(DNA_UI_LENGTH)
	SE_structure = new /list(DNA_SE_LENGTH)
	var/turf/location = get_turf(H.loc)
	if(!location)
		current_status = "lost"

	if(location.loc.type == shuttle_master.emergency.areaInstance.type) //didn't work in the switch for some reason
		if(H.stat != DEAD)
			current_status = "alive"
		else
			current_status = "dead"

	else
		switch(location.loc.type)
			if(/area/shuttle/escape_pod1/centcom, /area/shuttle/escape_pod2/centcom, /area/shuttle/escape_pod3/centcom, /area/shuttle/escape_pod5/centcom, /area/centcom, /area/shuttle/transport1, /area/shuttle/administration/centcom/, /area/shuttle/specops/centcom)
				if(H.stat != DEAD)
					current_status = "alive"
				else
					current_status = "dead"
			else
				current_status = "lost"

	if(istype(H.dna))
		message_admins("FOUND DNA")
		var/ind = 0
		for(var/x in H.dna.SE)
			ind += 1
			SE[ind] = H.dna.SE[ind]
		ind = 0
		for(var/x in H.dna.UI)
			ind += 1
			UI[ind] = H.dna.UI[ind]
		ind = 0
		for(var/x in H.dna.SE_structure)
			ind += 1
			if(istype(H.dna.SE_structure[ind], /datum/dna/gene))
				var/datum/dna/gene/gene = H.dna.SE_structure[ind]
				SE_structure[ind] = "[gene.type]"
			else
				SE_structure[ind] = 0

	else
		SE = null
		UI = null
		SE_structure = null

	if(H.mind)
		if(istype(H.mind.initial_account))
			account["pin"] = H.mind.initial_account.remote_access_pin
			account["num"] = H.mind.initial_account.account_number
			energy_creds = H.mind.initial_account.money

		if(H.mind.certs)
			certs = list()
			for(var/datum/cert/c in H.mind.certs)
				certs += c.uid

		if(H.mind.assigned_job)
			primary_cert = H.mind.assigned_job.uid

		if(H.mind.cert_title)
			cert_title = H.mind.cert_title

		if(H.mind.ranks)
			department_ranks = H.mind.ranks
		if(H.mind.faction)
			faction = H.mind.faction.faction_uid
		else
			faction = ""

	check_inv(H)

	var/list/types_of_int_organs = list() //This will hold all the types of organs in the mob before rejuvenation.
	for(var/obj/item/organ/internal/I in H.internal_organs)
		types_of_int_organs |= I.type //Compiling the list of organ types. It is possible for organs to be missing from this list if they are absent from the mob.

	//Replacing lost limbs with the species default.
	var/mob/living/carbon/human/temp_holder
	for(var/limb_type in H.species.has_limbs)
		var/obj/item/organ/external/org = H.get_organ(limb_type)
		if (!org || org.is_stump())
			organ_data[limb_type] = "amputated"

		else if(org.status & ORGAN_ROBOT)

			organ_data[limb_type] = "cyborg"

		else if(org.species == H.species)

			organ_data[limb_type] = null

		else
			organ_data[limb_type] = "[org.species]"


	//Replacing lost organs with the species default.
	temp_holder = new /mob/living/carbon/human()
	for(var/index in H.species.has_organ)
		var/organ = H.species.has_organ[index]
		if(!(organ in types_of_int_organs))	//If the mob is missing this particular organ...
			var/obj/item/organ/internal/I = new organ(temp_holder) //Create the organ inside our holder so we can check it before implantation.
			if(H.get_organ_slot(I.slot)) //Check to see if the user already has an organ in the slot the 'missing organ' belongs to. If they do, skip implantation.
				organ_data[index] = I.species	//In an example, this will prevent duplication of the mob's eyes if the mob is a Human and they have Nucleation eyes, since,
										//while the organ in the eyes slot may not be listed in the mob's species' organs definition, it is still viable and fits in the appropriate organ slot.
			else
				organ_data[index] = "amputated"
		else
			organ_data[index] = null

/datum/preferences/proc/open_load_dialog(mob/user)

	var/DBQuery/query = dbcon.NewQuery("SELECT slot,real_name,current_status FROM [format_table_name("characters")] WHERE ckey='[user.ckey]' ORDER BY slot")

	var/dat = "<body>"
	dat += "<tt><center>"
	dat += "<b>Select a character slot to load</b><hr>"
	var/name
	var/c_status = ""
	for(var/i=1, i<=max_save_slots, i++)
		if(!query.Execute())
			var/err = query.ErrorMsg()
			log_game("SQL ERROR during character slot loading. Error : \[[err]\]\n")
			message_admins("SQL ERROR during character slot loading. Error : \[[err]\]\n")
			return
		while(query.NextRow())
			if(i==text2num(query.item[1]))
				if(query.item[3] == "dead")
					name =  query.item[2] + " (DEAD)"
					c_status = "dead"
				else if(query.item[3] == "lost")
					name =  query.item[2] + " (M.I.A)"
					c_status = "lost"
				else
					name =  query.item[2]

		if(!name)	name = "Character[i]"
		if(i==default_slot)
			name = "<b>[name]</b>"
		if(c_status == "dead")
			dat += "<a href='?_src_=prefs;preference=changeslotdead;num=[i];'>[name]</a><br>"
		else if(c_status == "lost")
			dat += "<a href='?_src_=prefs;preference=changeslotlost;num=[i];'>[name]</a><br>"
		else
			dat += "<a href='?_src_=prefs;preference=changeslot;num=[i];'>[name]</a><br>"
		name = null
		c_status = ""
	dat += "<hr>"
	dat += "<a href='byond://?src=\ref[user];preference=close_load_dialog'>Close</a><br>"
	dat += "</center></tt>"
//		user << browse(dat, "window=saves;size=300x390")
	var/datum/browser/popup = new(user, "saves", "<div align='center'>Character Saves</div>", 300, 390)
	popup.set_content(dat)
	popup.open(0)

/datum/preferences/proc/close_load_dialog(mob/user)
	user << browse(null, "window=saves")


/datum/preferences/proc/close_character_dialog(mob/user)
	user << browse(null, "window=charactersetup")

/datum/preferences/proc/close_preferences(mob/user)
	user << browse(null, "window=preferences")
/datum/preferences/proc/create_account()
	energy_creds = 500
	account["pin"] = rand(1111, 9999)
	account["num"] = rand(111111, 999999)

/datum/preferences/proc/get_cert_title()
	if (primary_cert == "intern")
		var/datum/cert/intern/aa = new /datum/cert/intern()
		return aa.title
	for(var/Co in subtypesof(/datum/cert))
		var/datum/cert/C = new Co()
		if(primary_cert == C.uid)
			return C.title
	return "ERROR! CERT NOT FOUND!"