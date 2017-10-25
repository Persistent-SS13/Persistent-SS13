/datum/preferences/proc/load_preferences(client/C)

	var/DBQuery/query = dbcon.NewQuery({"SELECT
					ooccolor,
					UI_style,
					UI_style_color,
					UI_style_alpha,
					be_role,
					default_slot,
					toggles,
					sound,
					randomslot,
					volume,
					nanoui_fancy,
					show_ghostitem_attack,
					lastchangelog
					FROM [format_table_name("player")]
					WHERE ckey='[C.ckey]'"}
					)

	if(!query.Execute())
		var/err = query.ErrorMsg()
		log_game("SQL ERROR during loading player preferences. Error : \[[err]\]\n")
		message_admins("SQL ERROR during loading player preferences. Error : \[[err]\]\n")
		return


	//general preferences
	while(query.NextRow())
		ooccolor = query.item[1]
		UI_style = query.item[2]
		UI_style_color = query.item[3]
		UI_style_alpha = text2num(query.item[4])
		be_special = params2list(query.item[5])
		default_slot = text2num(query.item[6])
		toggles = text2num(query.item[7])
		sound = text2num(query.item[8])
		randomslot = text2num(query.item[9])
		volume = text2num(query.item[10])
		nanoui_fancy = text2num(query.item[11])
		show_ghostitem_attack = text2num(query.item[12])
		lastchangelog = query.item[13]

	//Sanitize
	ooccolor		= sanitize_hexcolor(ooccolor, initial(ooccolor))
	UI_style		= sanitize_inlist(UI_style, list("White", "Midnight"), initial(UI_style))
	default_slot	= sanitize_integer(default_slot, 1, max_save_slots, initial(default_slot))
	toggles			= sanitize_integer(toggles, 0, 65535, initial(toggles))
	sound			= sanitize_integer(sound, 0, 65535, initial(sound))
	UI_style_color	= sanitize_hexcolor(UI_style_color, initial(UI_style_color))
	UI_style_alpha	= sanitize_integer(UI_style_alpha, 0, 255, initial(UI_style_alpha))
	randomslot		= sanitize_integer(randomslot, 0, 1, initial(randomslot))
	volume			= sanitize_integer(volume, 0, 100, initial(volume))
	nanoui_fancy	= sanitize_integer(nanoui_fancy, 0, 1, initial(nanoui_fancy))
	show_ghostitem_attack = sanitize_integer(show_ghostitem_attack, 0, 1, initial(show_ghostitem_attack))
	lastchangelog	= sanitize_text(lastchangelog, initial(lastchangelog))
	return 1

/datum/preferences/proc/save_preferences(client/C)

	// Might as well scrub out any malformed be_special list entries while we're here
	for(var/role in be_special)
		if(!(role in special_roles))
			log_to_dd("[C.key] had a malformed role entry: '[role]'. Removing!")
			be_special -= role

	var/DBQuery/query = dbcon.NewQuery({"UPDATE [format_table_name("player")]
				SET
					ooccolor='[ooccolor]',
					UI_style='[UI_style]',
					UI_style_color='[UI_style_color]',
					UI_style_alpha='[UI_style_alpha]',
					be_role='[list2params(sql_sanitize_text_list(be_special))]',
					default_slot='[default_slot]',
					toggles='[toggles]',
					sound='[sound]',
					randomslot='[randomslot]',
					volume='[volume]',
					nanoui_fancy='[nanoui_fancy]',
					show_ghostitem_attack='[show_ghostitem_attack]',
					lastchangelog='[lastchangelog]'
					WHERE ckey='[C.ckey]'"}
					)

	if(!query.Execute())
		var/err = query.ErrorMsg()
		log_game("SQL ERROR during saving player preferences. Error : \[[err]\]\n")
		message_admins("SQL ERROR during saving player preferences. Error : \[[err]\]\n")
		return
	return 1


/datum/preferences/proc/check_mind(client/C, var/num)
	num = text2num(num)
	slot = num
	var/DBQuery/query = dbcon.NewQuery({"SELECT
					real_name
					FROM [format_table_name("character")] WHERE ckey='[C.ckey]' AND slot='[num]'"})
	if(!query.Execute())
		var/err = query.ErrorMsg()
		log_game("SQL ERROR during check_mind Error : \[[err]\]\n")
		message_admins("SQL ERROR during check_mind Error : \[[err]\]\n")
		return
	while(query.NextRow())
		return 1
	return 0
	
/datum/preferences/proc/load_mind(client/C, datum/mind/mind, var/firstTime = 0, var/nocontents = 0, var/transfer = 0)
	return map_storage.Load_Char(C.key, slot, mind, transfer)
	if(!slot)	slot = default_slot
	message_admins("load_mind ran [C.ckey] slot:[slot] nocontents:[firstTime]")
	slot = sanitize_integer(slot, 1, max_save_slots, initial(default_slot))
	if(slot != default_slot)
		default_slot = slot
		var/DBQuery/firstquery = dbcon.NewQuery("UPDATE [format_table_name("player")] SET default_slot=[slot] WHERE ckey='[C.ckey]'")
		firstquery.Execute()
	
	// Let's not have this explode if you sneeze on the DB
	var/DBQuery/query = dbcon.NewQuery({"SELECT
					OOC_Notes,
					real_name,
					gender,
					age,
					species,
					language,
					b_type,
					flavor_text,
					med_record,
					sec_record,
					gen_record,
					nanotrasen_relation,
					current_status,
					energy_creds,
					account,
					certifications,
					primary_cert,
					cert_title,
					department_ranks,
					faction,
					SE,
					UI,
					SE_structure,
					body,
					body_type,
					stat_Grit,
					stat_Fortitude,
					stat_Reflex,
					stat_Creativity,
					stat_Focus,
					ambition
					FROM [format_table_name("character")] WHERE ckey='[C.ckey]' AND slot='[slot]'"})
	if(!query.Execute())
		var/err = query.ErrorMsg()
		log_game("SQL ERROR during load_mind Error : \[[err]\]\n")
		message_admins("SQL ERROR during load_mind Error : \[[err]\]\n")
		return
	var/found = 0
	var/body_num = 0
	var/body_type = 0
	while(query.NextRow())
		found = 1
		metadata = query.item[1]
		real_name = query.item[2]
		gender = query.item[3]
		age = text2num(query.item[4])
		species = query.item[5]
		language = query.item[6]
		b_type = query.item[7]
		flavor_text = query.item[8]
		med_record = query.item[9]
		sec_record = query.item[10]
		gen_record = query.item[11]
		nanotrasen_relation = query.item[12]
		current_status = query.item[13]
		energy_creds = text2num(query.item[14])
		account = params2list(query.item[15])
		certs = params2list(query.item[16])
		primary_cert = query.item[17]
		cert_title = query.item[18]
		department_ranks = params2list(query.item[19])
		faction = query.item[20]
		SE = ParamExplode(query.item[21], "&", DNA_SE_LENGTH)
		UI = ParamExplode(query.item[22], "&", DNA_UI_LENGTH)
		SE_structure = ParamExplode(replacetext(query.item[23], "%2f", "/"), "&", DNA_SE_LENGTH)
		body_num = text2num(query.item[24])
		body_type = text2num(query.item[25])
		stat_Grit = text2num(query.item[26])
		stat_Fortitude = text2num(query.item[27])
		stat_Reflex = text2num(query.item[28])
		stat_Creativity = text2num(query.item[29])
		stat_Focus = text2num(query.item[30])
		ambition = text2num(query.item[31])
	if(!found)
		return
	metadata = sanitize_text(metadata, initial(metadata))
	real_name = reject_bad_name(real_name)
	if(isnull(species)) species = "Human"
	if(isnull(language)) language = "None"
	if(isnull(nanotrasen_relation)) nanotrasen_relation = initial(nanotrasen_relation)
	if(!real_name) real_name = random_name(gender,species)
	gender			= sanitize_gender(gender)
	age				= sanitize_integer(age, AGE_MIN, AGE_MAX, initial(age))
	b_type			= sanitize_text(b_type, initial(b_type))
	var/mob/living/char
	if(body_type == 1)	// HUMANOID BODIES
		char = load_body(C, body_num, nocontents)
	if(body_type == 2)
		char = load_brain(C, body_num, nocontents)
	if(body_type == 3)
		char = load_robot(C, body_num, nocontents)
	if(body_type == 4)
		char = load_spiderbot(C, body_num, nocontents)
	if(!char)
		message_admins("load_mind char not found! slot:[slot] body:[body_num] bodytype:[body_type]")
	char.age = age
	char.add_language(language)
	char.real_name = real_name
	char.name = real_name
	char.flavor_text = flavor_text
	if(char.dna)
		char.dna.real_name = real_name
		char.dna.b_type = b_type
	if(mind)
		mind.char_slot = slot
		mind.stat_Grit = stat_Grit
		mind.stat_Fortitude = stat_Fortitude
		mind.stat_Reflex = stat_Reflex
		mind.stat_Creativity = stat_Creativity
		mind.stat_Focus = stat_Focus
		mind.ambition = ambition
		mind.account = account
		mind.energy_creds = energy_creds
		mind.cert_title = cert_title
		mind.default_slot = default_slot
		mind.ranks = department_ranks
		mind.faction_uid = faction
		mind.primary_cert = job_master.GetCert(primary_cert)
		if(job_master)
			mind.certs = list()
			for(var/x in certs)
				var/datum/cert/c = job_master.GetCert(x)
				mind.certs += c
	if(transfer)
		mind.transfer_to(char)
		char.mind.assigned_role = mind.primary_cert.uid
	if(istype(char.loc, /obj))
		var/obj/holding = char.loc
		if(istype(holding.loc, /obj))
			return holding.loc
		return holding
	return char


/datum/preferences/proc/delete_mind(client/C)
	if(!slot)
		return
	var/DBQuery/firstquery = dbcon.NewQuery("SELECT body_type, body FROM [format_table_name("character")] WHERE ckey='[C.ckey]' AND slot='[slot]'")
	firstquery.Execute()
	while(firstquery.NextRow())
		var/body_num = firstquery.item[2]
		var/body_type = text2num(firstquery.item[1])
		if(body_type == 1)
			delete_body(C, body_num)
		if(body_type == 2)
			delete_brain(C, body_num)
		if(body_type == 3)
			delete_robot(C, body_num)
		if(body_type == 4)
			delete_spiderbot(C, body_num)
	var/DBQuery/query = dbcon.NewQuery({"DELETE FROM [format_table_name("character")] WHERE ckey='[C.ckey]' AND slot='[slot]'"})
	create_single_spawnicon(C, slot)
	if(!query.Execute())
		message_admins("Failed to delete!")

	return 1

/datum/preferences/proc/load_item(client/C, var/uid, var/nocontents = 0)
	// Let's not have this explode if you sneeze on the DB
	uid = text2num(uid)
	if (uid == 0)
		return
	var/DBQuery/query = dbcon.NewQuery({"SELECT
					path,
					name,
					contents,
					icon_state,
					charge,
					SE,
					UI,
					SE_structure,
					UE,
					b_type,
					species,
					reagents,
					gas_mixture
				 	FROM [format_table_name("items")] WHERE id='[uid]'"})
	if(!query.Execute())
		var/err = query.ErrorMsg()
		log_game("SQL ERROR during load_item Error : \[[err]\]\n")
		message_admins("SQL ERROR during load_item Error : \[[err]\]\n")
		return

	while(query.NextRow())
		var/path = query.item[1]
		var/name = query.item[2]
		var/contents = params2list(query.item[3])
		var/icon_state = query.item[4]
		
		var/obj/o = new path()
		o.name = name
		o.icon_state = icon_state
		var/datum/gas_mixture/air = load_gasmixture(C, query.item[13])
		o.air_contents = air
		if(o.reagents)
			o.reagents.clear_reagents()
			var/list/reagents = params2list(query.item[12])
			if(reagents && !isemptylist(reagents))
				for(var/x in reagents)
					var/datum/reagent/reag = load_reagent(C, x)
					if(reag)
						reag.holder = o.reagents
						o.reagents.reagent_list += reag
				o.reagents.update_total()
		if(istype(o, /obj/item/organ))			
			var/obj/item/organ/organ = o
			var/datum/species/S = all_species[query.item[11]]
			organ.species = S
			organ.dna = new /datum/dna()
			var/list/tempSE = ParamExplode(query.item[6], "&", DNA_SE_LENGTH)
			var/list/tempUI = ParamExplode(query.item[7], "&", DNA_UI_LENGTH)
			var/list/tempSE_structure = ParamExplode(replacetext(query.item[8], "%2f", "/"), "&", DNA_SE_LENGTH)
			var/UE = query.item[9]
			var/b_type = query.item[10]
			organ.dna.b_type = b_type
			organ.dna.unique_enzymes = UE
			var/ind = 0
			if(!isemptylist(tempSE))
				var/list/form_SE = new /list(DNA_SE_LENGTH)
				for(var/x in tempSE)
					ind++
					form_SE[ind] = text2num(x)
				organ.dna.SE = form_SE.Copy()
			if(!isemptylist(tempUI))
				var/list/form_UI = new/list(DNA_UI_LENGTH)
				ind = 0
				for(var/x in tempUI)
					ind++
					form_UI[ind] = text2num(x)
				organ.dna.UI = form_UI.Copy()
			if(!isemptylist(tempSE_structure))
				ind = 0
				for(var/type in tempSE_structure)
					ind++
					if(type && type != "0")
						var/datum/dna/gene/gene = new type()
						organ.dna.SE_structure[ind] = gene
					else
						organ.dna.SE_structure[ind] = 0
			if(istype(o, /obj/item/organ/external/head))
				var/obj/item/organ/external/head/He = o
				var/DBQuery/headquery = dbcon.NewQuery({"SELECT
								hair_rgb,
								facial_rgb,
								hacc_rgb,
								h_style,
								f_style,
								ha_style
								FROM [format_table_name("items")] WHERE id='[uid]'"})
				if(!headquery.Execute())
					var/err = query.ErrorMsg()
					log_game("SQL ERROR during load_item Error : \[[err]\]\n")
					message_admins("SQL ERROR during load_item Error : \[[err]\]\n")
					return
				while(headquery.NextRow())
					var/list/hair_rgb = ParamExplode(headquery.item[1], "&", 3)
					var/list/facial_rgb = ParamExplode(headquery.item[2], "&", 3)
					var/list/hacc_rgb = ParamExplode(headquery.item[3], "&", 3)
					He.r_hair = hair_rgb[1]
					He.g_hair = hair_rgb[2]
					He.b_hair = hair_rgb[3]
					He.r_facial = facial_rgb[1]
					He.g_facial = facial_rgb[2]
					He.b_facial = facial_rgb[3]
					He.r_headacc = hacc_rgb[1]
					He.g_headacc = hacc_rgb[2]
					He.b_headacc = hacc_rgb[3]
					He.h_style = headquery.item[4]
					He.f_style = headquery.item[5]
					He.ha_style = headquery.item[6]
			if(istype(o, /obj/item/organ/external))
				var/obj/item/organ/external/Ex = o
				Ex.icon_state = null
				Ex.icon_name = icon_state
				Ex.sync_colour_to_dna()
				Ex.icon = Ex.get_icon()
		if(!nocontents)
			o.contents = list()
			for(var/p in contents)
				o.contents += load_item(C, p)
			if(istype(o, /obj/item/weapon/stock_parts/cell))
				var/obj/item/weapon/stock_parts/cell/cell = o
				cell.charge = text2num(query.item[5])
			
				
		return o

	log_game("ITEM NOT FOUND [uid]")
	message_admins("ITEM NOT FOUND [uid] ")
	return

/datum/preferences/proc/delete_item(client/C, var/uid)
	uid = text2num(uid)
	if (uid == 0)
		return
	var/DBQuery/query = dbcon.NewQuery({"SELECT
					contents, reagents, gas_mixture
				 	FROM [format_table_name("items")] WHERE id='[uid]'"})
	if(!query.Execute())
		var/err = query.ErrorMsg()
		log_game("SQL ERROR during delete_item loading. Error : \[[err]\]\n")
		message_admins("SQL ERROR during delete_item loading. Error : \[[err]\]\n")
		return

	while(query.NextRow())
		var/contents = params2list(query.item[1])
		var/reagents = params2list(query.item[2])
		delete_gasmixture(C, query.item[3])
		for(var/p in contents)
			delete_item(C, p)
		for(var/x in reagents)
			delete_reagent(C, x)
		qdel(reagents)
		qdel(contents)
		var/DBQuery/secondquery = dbcon.NewQuery("DELETE FROM [format_table_name("items")] WHERE id = '[uid]'")
		if(!secondquery.Execute())
			var/err = query.ErrorMsg()
			log_game("SQL ERROR during delete_item loading. Error : \[[err]\]\n")
			message_admins("SQL ERROR during delete_item loading. Error : \[[err]\]\n")
			return


/datum/preferences/proc/load_securityrecord(client/C, var/uid, var/name)

	name = sql_sanitize_text(name)
	if(!name)
		return 0
	var/DBQuery/query = dbcon.NewQuery({"SELECT
					sec_record
				 	FROM [format_table_name("character")] WHERE real_name='[name]'"})
	if(!query.Execute())
		var/err = query.ErrorMsg()
		log_game("SQL ERROR during security record loading. Error : \[[err]\]\n")
		message_admins("SQL ERROR during security record loading. Error : \[[err]\]\n")
		return
	var/found = 0
	var/sec_num = 0
	while(query.NextRow())
		sec_num = text2num(query.item[1])
		found = 1
	if(found)
		var/DBQuery/secondquery = dbcon.NewQuery({"SELECT
			criminal_status, minor_crimes, major_crimes,
			notes, log
			FROM [format_table_name("securityrecords")] WHERE id='[sec_num]'"})
		if(!secondquery.Execute())
			var/err = query.ErrorMsg()
			log_game("SQL ERROR during security record loading. Error : \[[err]\]\n")
			message_admins("SQL ERROR during security record loading. Error : \[[err]\]\n")
			return
		while(query.NextRow())
			var/list/data = list()
			data["criminal_status"] = query.item[1]
			data["minor_crimes"] = params2list(query.item[2])
			data["major_crimes"] = params2list(query.item[3])
			data["notes"] = params2list(query.item[4])
			data["log"] = params2list(query.item[5])
			return data
	log_game("SECREC NOT FOUND [uid]")
	message_admins("SECREC NOT FOUND [uid] ")
	return

/datum/preferences/proc/save_gasmixture(client/C, var/datum/gas_mixture/gas)
	var/carbon = gas.carbon_dioxide
	var/nitrogen = gas.nitrogen
	var/oxygen = gas.oxygen
	var/toxins = gas.toxins
	var/volume = gas.volume
	var/list/trace_gas = list()
	for(var/datum/gas/trace in gas.trace_gases)
		trace_gas[trace.type] = trace.moles
	var/params_trace = list2params(trace_gas)
	var/DBQuery/query = dbcon.NewQuery({"
					INSERT INTO [format_table_name("gasses")] (carbon, nitrogen, oxygen, toxins, trace_gas, volume)

					VALUES
									('[carbon]', '[nitrogen]', '[oxygen]', '[toxins]', '[params_trace]', '[volume]')
					"}
					)
	var/DBQuery/secondquery = dbcon.NewQuery({"
					SELECT LAST_INSERT_ID() FROM [format_table_name("gasses")]
					"}
					)

	if(!query.Execute())
		var/err = query.ErrorMsg()
		log_game("SQL ERROR during save_gasmixture: \[[err]\]\n")
		message_admins("SQL ERROR during save_gasmixture : \[[err]\]\n")
		return
	if(!secondquery.Execute())
		var/err = secondquery.ErrorMsg()
		log_game("SQL ERROR during save_gasmixture : \[[err]\]\n")
		message_admins("SQL ERROR during save_gasmixture : \[[err]\]\n")
		return

	while(secondquery.NextRow())
		var/id = secondquery.item[1]
		return text2num(id)

	return 0

/datum/preferences/proc/load_gasmixture(client/C, var/uid)
	uid = text2num(uid)
	if (uid == 0 || !uid)
		return
	var/DBQuery/query = dbcon.NewQuery({"SELECT
					carbon,
					nitrogen,
					oxygen,
					toxins,
					trace_gas,
					volume
				 	FROM [format_table_name("gasses")] WHERE id='[uid]'"})
	if(!query.Execute())
		var/err = query.ErrorMsg()
		log_game("SQL ERROR during load_gasmixture Error : \[[err]\]\n")
		message_admins("SQL ERROR during load_gasmixture Error : \[[err]\]\n")
		return
	while(query.NextRow())
		
		var/datum/gas_mixture/air_contents = new /datum/gas_mixture()
		air_contents.carbon_dioxide = text2num(query.item[1])
		air_contents.nitrogen = text2num(query.item[2])
		air_contents.oxygen = text2num(query.item[3])
		air_contents.toxins = text2num(query.item[4])
		air_contents.volume = text2num(query.item[6])
		air_contents.temperature = 293.15
		var/list/tracelist = params2list(query.item[5])
		for(var/x in tracelist)
			var/datum/gas/temp = new x()
			if(temp)
				temp.moles = text2num(tracelist[x])
				air_contents.trace_gases += temp
			else
				message_admins("TRACE GAS CREATION FAILED")
		return air_contents
	log_game("GAS NOT FOUND [uid]")
	message_admins("GAS NOT FOUND [uid] ")
	return


/datum/preferences/proc/delete_gasmixture(client/C, var/uid)
	uid = text2num(uid)
	var/DBQuery/secondquery = dbcon.NewQuery("DELETE FROM [format_table_name("gasses")] WHERE id = '[uid]'")
	if(!secondquery.Execute())
		var/err = secondquery.ErrorMsg()
		log_game("SQL ERROR during delete_gasmixture loading. Error : \[[err]\]\n")
		message_admins("SQL ERROR during delete_gasmixture loading. Error : \[[err]\]\n")
		return
	return 1
	
	
/datum/preferences/proc/save_reagent(client/C, var/datum/reagent/reagent)
	var/path = reagent.type
	var/volume = reagent.volume
	var/DBQuery/query = dbcon.NewQuery({"
					INSERT INTO [format_table_name("reagents")] (path, volume)

					VALUES
									('[path]', '[volume]')
					"}
					)
	var/DBQuery/secondquery = dbcon.NewQuery({"
					SELECT LAST_INSERT_ID() FROM [format_table_name("reagents")]
					"}
					)

	if(!query.Execute())
		var/err = query.ErrorMsg()
		log_game("SQL ERROR during save_reagent: \[[err]\]\n")
		message_admins("SQL ERROR during save_reagent : \[[err]\]\n")
		return
	if(!secondquery.Execute())
		var/err = secondquery.ErrorMsg()
		log_game("SQL ERROR during save_reagent : \[[err]\]\n")
		message_admins("SQL ERROR during save_reagent : \[[err]\]\n")
		return

	while(secondquery.NextRow())
		var/id = secondquery.item[1]
		return text2num(id)

	return 0

/datum/preferences/proc/load_reagent(client/C, var/uid)
	uid = text2num(uid)
	if (uid == 0 || !uid)
		return
	var/DBQuery/query = dbcon.NewQuery({"SELECT
					path,
					volume
				 	FROM [format_table_name("reagents")] WHERE id='[uid]'"})
	if(!query.Execute())
		var/err = query.ErrorMsg()
		log_game("SQL ERROR during load_reagent Error : \[[err]\]\n")
		message_admins("SQL ERROR during load_reagent Error : \[[err]\]\n")
		return
	while(query.NextRow())
		var/path = query.item[1]
		var/volume = text2num(query.item[2])
		var/datum/reagent/temp = new path()
		if(temp)
			temp.volume = volume
			return temp
		else
			message_admins("failed to load reagent")
			return
			
	log_game("REAGENT NOT FOUND [uid]")
	message_admins("REAGENT NOT FOUND [uid] ")
	return


/datum/preferences/proc/delete_reagent(client/C, var/uid)
	uid = text2num(uid)
	var/DBQuery/secondquery = dbcon.NewQuery("DELETE FROM [format_table_name("reagents")] WHERE id = '[uid]'")
	if(!secondquery.Execute())
		var/err = secondquery.ErrorMsg()
		log_game("SQL ERROR during delete_reagent loading. Error : \[[err]\]\n")
		message_admins("SQL ERROR during delete_reagent loading. Error : \[[err]\]\n")
		return
	return 1
	
	

/datum/preferences/proc/save_robotcomponent(client/C, var/datum/robot_component/obb)
	var/path = obb.wrapped.type
	var/toggled = obb.toggled
	var/brute_damage = obb.brute_damage
	var/electronics_damage = obb.electronics_damage
	var/charge = 0
	if(istype(obb.wrapped, /obj/item/weapon/stock_parts/cell))
		var/obj/item/weapon/stock_parts/cell/cell = obb.wrapped
		charge = cell.charge
	var/DBQuery/query = dbcon.NewQuery({"
					INSERT INTO [format_table_name("robotcomponents")] (path, brute_damage, electronics_damage, toggled, charge)

					VALUES
									('[path]', '[brute_damage]', '[electronics_damage]', '[toggled]','[charge]')
					"}
					)
	var/DBQuery/secondquery = dbcon.NewQuery({"
					SELECT LAST_INSERT_ID() FROM [format_table_name("robotcomponents")]
					"}
					)

	if(!query.Execute())
		var/err = query.ErrorMsg()
		log_game("SQL ERROR during COMPONENT SAVING : \[[err]\]\n")
		message_admins("SQL ERROR during COMPONENT SAVING : \[[err]\]\n")
		return
	if(!secondquery.Execute())
		var/err = secondquery.ErrorMsg()
		log_game("SQL ERROR during COMPONENT SAVING : \[[err]\]\n")
		message_admins("SQL ERROR during COMPONENT SAVING : \[[err]\]\n")
		return

	while(secondquery.NextRow())
		var/id = secondquery.item[1]
		return text2num(id)

	return 0

/datum/preferences/proc/load_robotcomponent(client/C, var/uid)
	uid = text2num(uid)
	if (uid == 0 || !uid)
		return
	var/DBQuery/query = dbcon.NewQuery({"SELECT
					path,
					brute_damage,
					electronics_damage,
					toggled,
					charge
				 	FROM [format_table_name("robotcomponents")] WHERE id='[uid]'"})
	if(!query.Execute())
		var/err = query.ErrorMsg()
		log_game("SQL ERROR during load_robotcomponent Error : \[[err]\]\n")
		message_admins("SQL ERROR during load_robotcomponent Error : \[[err]\]\n")
		return

	while(query.NextRow())
		var/path = query.item[1]
		var/brute_damage = text2num(query.item[2])
		var/electronics_damage = text2num(query.item[3])
		var/toggled = text2num(query.item[4])
		var/charge = text2num(query.item[5])
		var/obj/temp = new path()
		if(temp)
			if(istype(temp, /obj/item/weapon/stock_parts/cell))
				var/obj/item/weapon/stock_parts/cell/cell = temp
				var/datum/robot_component/comp = new cell.datum_type()
				comp.wrapped = cell
				comp.component_name = cell.component_name
				cell.charge = charge
				comp.toggled = toggled
				cell.brute = brute_damage
				cell.burn = electronics_damage
				return comp
			else if(istype(temp, /obj/item/robot_parts/robot_component))
				var/obj/item/robot_parts/robot_component/ob = temp
				var/datum/robot_component/comp = new ob.datum_type()
				comp.wrapped = ob
				comp.component_name = ob.component_name
				comp.toggled = toggled
				comp.brute_damage = brute_damage
				comp.electronics_damage = electronics_damage
				return comp
			else if(istype(temp , /obj/item/broken_device))
				var/datum/robot_component/comp = new /datum/robot_component/broken()
				comp.wrapped = temp
				return comp
		else
			message_admins("failed to load robo organ")
			return


	log_game("ROBOT COMPONENT NOT FOUND [uid]")
	message_admins("ROBOT COMPONENT NOT FOUND [uid] ")
	return


/datum/preferences/proc/delete_robotcomponent(client/C, var/uid)
	uid = text2num(uid)
	var/DBQuery/secondquery = dbcon.NewQuery("DELETE FROM [format_table_name("robotcomponents")] WHERE id = '[uid]'")
	if(!secondquery.Execute())
		var/err = secondquery.ErrorMsg()
		log_game("SQL ERROR during character slot loading. Error : \[[err]\]\n")
		message_admins("SQL ERROR during character slot loading. Error : \[[err]\]\n")
		return
	return 1
	
	
/datum/preferences/proc/save_spiderbot(client/C, var/mob/living/simple_animal/spiderbot/H)

	var/health = H.health
	var/mmi = save_item(C, H.mmi)
	var/held_item = save_item(C, H.held_item)
	var/DBQuery/query = dbcon.NewQuery({"
					INSERT INTO [format_table_name("spiderbots")] (health, mmi, held_item)

					VALUES
									('[health]', '[mmi]', '[held_item]')
					"}
					)
	var/DBQuery/secondquery = dbcon.NewQuery({"
					SELECT LAST_INSERT_ID() FROM [format_table_name("spiderbots")]
					"}
					)

	if(!query.Execute())
		var/err = query.ErrorMsg()
		log_game("SQL ERROR during save_spiderbot : \[[err]\]\n")
		message_admins("SQL ERROR during save_spiderbot : \[[err]\]\n")
		return
	if(!secondquery.Execute())
		var/err = secondquery.ErrorMsg()
		log_game("SQL ERROR during save_spiderbot : \[[err]\]\n")
		message_admins("SQL ERROR during save_spiderbot : \[[err]\]\n")
		return

	while(secondquery.NextRow())
		var/id = secondquery.item[1]
		return text2num(id)

	return 0

/datum/preferences/proc/delete_spiderbot(client/C, var/uid)
	uid = text2num(uid)
	var/DBQuery/query = dbcon.NewQuery({"SELECT
					mmi, held_item
				 	FROM [format_table_name("spiderbots")] WHERE id='[uid]'"})
	if(!query.Execute())
		var/err = query.ErrorMsg()
		log_game("SQL ERROR during delete_spiderbot Error : \[[err]\]\n")
		message_admins("SQL ERROR during delete_spiderbot Error : \[[err]\]\n")
		return

	while(query.NextRow())
		delete_item(C, query.item[1])
		delete_item(C, query.item[2])
	var/DBQuery/secondquery = dbcon.NewQuery("DELETE FROM [format_table_name("spiderbots")] WHERE id = '[uid]'")
	if(!secondquery.Execute())
		var/err = secondquery.ErrorMsg()
		log_game("SQL ERROR during delete_spiderbot Error : \[[err]\]\n")
		message_admins("SQL ERROR during delete_spiderbot Error : \[[err]\]\n")
		return
	return 1


/datum/preferences/proc/load_spiderbot(client/C, var/uid, var/nocontents = 0)
	uid = text2num(uid)
	if (uid == 0)
		return
	var/DBQuery/query = dbcon.NewQuery({"SELECT
					health,
					mmi,
					held_item					
				 	FROM [format_table_name("spiderbots")] WHERE id='[uid]'"})
	if(!query.Execute())
		var/err = query.ErrorMsg()
		log_game("SQL ERROR during load_spiderbot Error : \[[err]\]\n")
		message_admins("SQL ERROR during load_spiderbot Error : \[[err]\]\n")
		return
	while(query.NextRow())
		var/mob/living/simple_animal/spiderbot/H = new()
		H.health = text2num(query.item[1])
		H.mmi = load_item(C, query.item[2])
		if(H.mmi)
			H.icon_state = "spiderbot-chassis-mmi"
			H.icon_living = "spiderbot-chassis-mmi"
			for(var/obj/item/organ/internal/brain/x in H.mmi.contents)
				if(x.dna)
					H.dna = x.dna.Clone()
					break
		H.held_item = load_item(C, query.item[3])
		return H
	log_game("spiderbot not found [uid]")
	message_admins("spiderbot NOT FOUND [uid] ")
	return

	
	
/datum/preferences/proc/save_brain(client/C, var/mob/living/carbon/brain/H)
	var/holder = 0
	var/mech = 0
	var/head = 0
	if(H.container)
		holder = save_item(C, H.container)
		if(istype(H.loc, /obj/mecha))
			mech = save_mech(C, H.loc)
	else
		if(istype(H.loc, /obj))
			holder = save_item(C, H.loc)
			var/obj/temp = H.loc.loc
			if(istype(temp, /obj/item/organ/external/head))
				message_admins("SAVING HEAD")
				temp.contents -= H.loc
				head = save_item(C, temp)
				temp.contents |= H.loc
	var/DBQuery/query = dbcon.NewQuery({"
					INSERT INTO [format_table_name("brains")] (holder, mech, head)

					VALUES
									('[holder]', '[mech]', '[head]')
					"}
					)
	var/DBQuery/secondquery = dbcon.NewQuery({"
					SELECT LAST_INSERT_ID() FROM [format_table_name("brains")]
					"}
					)
	if(!query.Execute())
		var/err = query.ErrorMsg()
		log_game("SQL ERROR during save_brain : \[[err]\]\n")
		message_admins("SQL ERROR during save_brain : \[[err]\]\n")
		return
	if(!secondquery.Execute())
		var/err = secondquery.ErrorMsg()
		log_game("SQL ERROR during save_brain : \[[err]\]\n")
		message_admins("SQL ERROR during save_brain : \[[err]\]\n")
		return

	while(secondquery.NextRow())
		var/id = secondquery.item[1]
		return text2num(id)

	return 0

/datum/preferences/proc/delete_brain(client/C, var/uid)
	uid = text2num(uid)
	var/DBQuery/query = dbcon.NewQuery({"SELECT
					holder, mech, head
				 	FROM [format_table_name("brains")] WHERE id='[uid]'"})
	if(!query.Execute())
		var/err = query.ErrorMsg()
		log_game("SQL ERROR during delete_brain Error : \[[err]\]\n")
		message_admins("SQL ERROR during delete_brain Error : \[[err]\]\n")
		return

	while(query.NextRow())
		delete_item(C, query.item[1])
		delete_mech(C, query.item[2])
		delete_item(C, query.item[3])
	var/DBQuery/secondquery = dbcon.NewQuery("DELETE FROM [format_table_name("brains")] WHERE id = '[uid]'")
	if(!secondquery.Execute())
		var/err = secondquery.ErrorMsg()
		log_game("SQL ERROR during delete_spiderbot Error : \[[err]\]\n")
		message_admins("SQL ERROR during delete_spiderbot Error : \[[err]\]\n")
		return
	return 1


/datum/preferences/proc/load_brain(client/C, var/uid, var/nocontents = 0)
	uid = text2num(uid)
	if (uid == 0)
		return
	var/DBQuery/query = dbcon.NewQuery({"SELECT
					holder,
					mech,
					head
				 	FROM [format_table_name("brains")] WHERE id='[uid]'"})
	if(!query.Execute())
		var/err = query.ErrorMsg()
		log_game("SQL ERROR during load_brain Error : \[[err]\]\n")
		message_admins("SQL ERROR during load_brain Error : \[[err]\]\n")
		return
	while(query.NextRow())
		var/mob/living/carbon/brain/H = new()
		var/obj/holder = load_item(C, query.item[1])
		var/obj/item/organ/internal/brain/physical_brain
		if(istype(holder, /obj/item/device/mmi))
			H.container = holder 
			var/obj/item/device/mmi/mmi = H.container
			mmi.brainmob = H
			var/obj/mecha/mech = load_mech(C, query.item[2])
			if(mech)
				mech.mmi_moved_inside(mmi, null, 1)
			else
				H.loc = holder
			for(var/obj/item/organ/internal/brain/x in H.contents)
				physical_brain = x
				break
		else
			H.loc = holder
			physical_brain = holder
			physical_brain.brainmob = H
			var/obj/head = load_item(C, query.item[3])
			if(head)
				head.transform = matrix(0, -10, MATRIX_TRANSLATE)
				physical_brain.loc = head
		var/mob/living/carbon/human/temp = new()
		temp.deleting = 1
		temp.real_name = real_name
		H.dna = new /datum/dna()
		H.dna.ready_dna(temp)
		qdel(temp)
		if(!nocontents)
			var/ind = 0
			if(!isemptylist(SE))
				var/list/form_SE = new /list(DNA_SE_LENGTH)
				for(var/x in SE)
					ind++
					form_SE[ind] = text2num(x)
				H.dna.SE = form_SE.Copy()
			if(!isemptylist(UI))
				var/list/form_UI = new/list(DNA_UI_LENGTH)
				ind = 0
				for(var/x in UI)
					ind++
					form_UI[ind] = text2num(x)
				H.dna.UI = form_UI.Copy()
			if(!isemptylist(SE_structure))
				ind = 0
				for(var/type in SE_structure)
					ind++
					if(type && type != "0")
						var/datum/dna/gene/gene = new type()
						H.dna.SE_structure[ind] = gene
					else
						H.dna.SE_structure[ind] = 0
			if(physical_brain)
				physical_brain.dna = H.dna.Clone()
		return H
	log_game("brain not found [uid]")
	message_admins("brain NOT FOUND [uid] ")
	return	

/datum/preferences/proc/save_mech(client/C, var/obj/mecha/H)
	var/path = H.type
	var/health = H.health
	var/cell = save_item(C, H.cell)
	var/list/equipmentlist = list()
	var/list/cargolist = list()
	for(var/obj/x in H.equipment)
		equipmentlist |= save_item(C, x)
	for(var/obj/x in H.cargo)
		cargolist |= save_item(C, x)
	var/icon_state = H.icon_state
	var/equipmentparam = list2params(equipmentlist)
	var/cargoparam = list2params(cargolist)
	var/DBQuery/query = dbcon.NewQuery({"
					INSERT INTO [format_table_name("mechs")] (path, health, cell, equipment, cargo, icon_state)

					VALUES
									('[path]', '[health]', '[cell]', '[equipmentparam]', '[cargoparam]', '[icon_state]')
					"}
					)
	var/DBQuery/secondquery = dbcon.NewQuery({"
					SELECT LAST_INSERT_ID() FROM [format_table_name("mechs")]
					"}
					)

	if(!query.Execute())
		var/err = query.ErrorMsg()
		log_game("SQL ERROR during save_mech: \[[err]\]\n")
		message_admins("SQL ERROR during save_mech : \[[err]\]\n")
		return
	if(!secondquery.Execute())
		var/err = secondquery.ErrorMsg()
		log_game("SQL ERROR during save_mech : \[[err]\]\n")
		message_admins("SQL ERROR during save_mech : \[[err]\]\n")
		return

	while(secondquery.NextRow())
		var/id = secondquery.item[1]
		return text2num(id)

	return 0

/datum/preferences/proc/delete_mech(client/C, var/uid)
	uid = text2num(uid)
	var/DBQuery/query = dbcon.NewQuery({"SELECT
					cell, equipment, cargo
				 	FROM [format_table_name("mechs")] WHERE id='[uid]'"})
	if(!query.Execute())
		var/err = query.ErrorMsg()
		log_game("SQL ERROR during delete_mech Error : \[[err]\]\n")
		message_admins("SQL ERROR during delete_mech Error : \[[err]\]\n")
		return

	while(query.NextRow())
		delete_item(C, query.item[1])
		var/list/equipmentlist = params2list(query.item[2])
		var/list/cargolist = params2list(query.item[3])
		if(equipmentlist && !isemptylist(equipmentlist))
			for(var/x in equipmentlist)
				delete_item(C, x)
		if(cargolist && !isemptylist(cargolist))
			for(var/x in cargolist)
				delete_item(C, x)
	var/DBQuery/secondquery = dbcon.NewQuery("DELETE FROM [format_table_name("mechs")] WHERE id = '[uid]'")
	if(!secondquery.Execute())
		var/err = secondquery.ErrorMsg()
		log_game("SQL ERROR during delete_mech Error : \[[err]\]\n")
		message_admins("SQL ERROR during delete_mech Error : \[[err]\]\n")
		return

	return 1

/datum/preferences/proc/load_mech(client/C, var/uid, var/nocontents = 0)
	uid = text2num(uid)
	if (uid == 0)
		return
	var/DBQuery/query = dbcon.NewQuery({"SELECT
					path,
					health,
					cell,
					equipment,
					cargo,
					icon_state
				 	FROM [format_table_name("mechs")] WHERE id='[uid]'"})
	if(!query.Execute())
		var/err = query.ErrorMsg()
		log_game("SQL ERROR during load_mech : \[[err]\]\n")
		message_admins("SQL ERROR during load_mech. Error : \[[err]\]\n")
		return

	while(query.NextRow())
		var/path = query.item[1]
		var/obj/mecha/H = new path()
		H.health = text2num(query.item[2])
		H.icon_state = query.item[6]
		if(!nocontents)
			H.cell = load_item(C, query.item[3])
			H.cargo = list()
			H.equipment = list()
			var/list/equipmentlist = params2list(query.item[4])
			var/list/cargolist = params2list(query.item[5])
			for(var/x in equipmentlist)
				var/obj/item/mecha_parts/mecha_equipment/eq = load_item(C, x)
				eq.attach(H)
			for(var/x in cargolist)
				H.cargo |= load_item(C, x)
			H.cell = load_item(C, query.item[3])
		message_admins("loaded mech...")
		return H

	log_game("MECHA NOT FOUND [uid]")
	message_admins("MECHA NOT FOUND [uid] ")
	return
		
/datum/preferences/proc/save_organ(client/C, var/obj/item/organ/external/obb, var/save_needed = 0)
	var/list/wounds = list()
	for(var/datum/wound/W in obb.wounds)
		wounds |= save_wound(C, W)
	var/path = obb.type
	var/woundlist = list2params(wounds)
	var/tempSE = list()
	var/tempUI = list()
	var/tempSE_structure = list()
	var/UE = 0
	var/tspecies = ""
	if(obb.dna && save_needed)
		UE = obb.dna.unique_enzymes
		tspecies = obb.species.name
		tempSE = obb.dna.SE
		tempUI = obb.dna.UI
		var/ind = 0
		tempSE_structure = new /list(DNA_SE_LENGTH)
		for(var/x in obb.dna.SE_structure)
			ind++
			if(istype(x, /datum/dna/gene))
				var/datum/dna/gene/gene = x
				tempSE_structure[ind] = gene.type
			else
				tempSE_structure[ind] = 0
	var/paramSE = list2params(tempSE)
	var/paramUI = list2params(tempUI)
	var/paramStruc = list2params(tempSE_structure)
	var/DBQuery/query = dbcon.NewQuery({"
					INSERT INTO [format_table_name("organs")] (path, wounds, SE, UI, SE_structure, UE, species)

					VALUES
									('[path]', '[woundlist]', '[paramSE]', '[paramUI]', '[paramStruc]', '[UE]', '[tspecies]')
					"}
					)
	var/DBQuery/secondquery = dbcon.NewQuery({"
					SELECT LAST_INSERT_ID() FROM [format_table_name("organs")]
					"}
					)

	if(!query.Execute())
		var/err = query.ErrorMsg()
		log_game("SQL ERROR during ORGAN SAVING : \[[err]\]\n")
		message_admins("SQL ERROR during ORGAN SAVING : \[[err]\]\n")
		return
	if(!secondquery.Execute())
		var/err = secondquery.ErrorMsg()
		log_game("SQL ERROR during ORGAN SAVING : \[[err]\]\n")
		message_admins("SQL ERROR during ORGAN SAVING : \[[err]\]\n")
		return

	while(secondquery.NextRow())
		var/id = secondquery.item[1]
		return text2num(id)

	return 0

/datum/preferences/proc/delete_organ(client/C, var/uid)
	uid = text2num(uid)
	var/DBQuery/query = dbcon.NewQuery({"SELECT
					wounds
				 	FROM [format_table_name("organs")] WHERE id='[uid]'"})
	if(!query.Execute())
		var/err = query.ErrorMsg()
		log_game("SQL ERROR during delete_organ Error : \[[err]\]\n")
		message_admins("SQL ERROR during delete_organ Error : \[[err]\]\n")
		return

	while(query.NextRow())

		var/list/woundlist = params2list(query.item[1])
		if(woundlist && !isemptylist(woundlist))
			for(var/x in woundlist)
				delete_wound(C, x)
	var/DBQuery/secondquery = dbcon.NewQuery("DELETE FROM [format_table_name("organs")] WHERE id = '[uid]'")
	if(!secondquery.Execute())
		var/err = secondquery.ErrorMsg()
		log_game("SQL ERROR during delete_organ Error : \[[err]\]\n")
		message_admins("SQL ERROR during delete_organ Error : \[[err]\]\n")
		return

	return 1

/datum/preferences/proc/load_organ(client/C, var/uid, var/nocontents = 0)
	uid = text2num(uid)
	if (uid == 0)
		return
	var/DBQuery/query = dbcon.NewQuery({"SELECT
					path,
					wounds,
					SE,
					UI,
					SE_structure,
					UE,
					species
				 	FROM [format_table_name("organs")] WHERE id='[uid]'"})
	if(!query.Execute())
		var/err = query.ErrorMsg()
		log_game("SQL ERROR during organ loading. Error : \[[err]\]\n")
		message_admins("SQL ERROR during organ loading. Error : \[[err]\]\n")
		return

	while(query.NextRow())
		var/path = query.item[1]
		var/list/wounds = params2list(query.item[2])
		var/list/woundlist = list()
		var/obj/item/organ/external/org = new path()
		if(org)
			if(!nocontents)
				for(var/x in wounds)
					org.wounds |= load_wound(C, x)
			var/UE = query.item[6]
			if(!UE || UE == "0")
			else
				org.dna = new /datum/dna()
				var/list/tempSE = ParamExplode(query.item[3], "&", DNA_SE_LENGTH)
				var/list/tempUI = ParamExplode(query.item[4], "&", DNA_UI_LENGTH)
				var/list/tempSE_structure = ParamExplode(replacetext(query.item[5], "%2f", "/"), "&", DNA_SE_LENGTH)
				org.dna.unique_enzymes = UE
				var/datum/species/S = all_species[query.item[7]]
				org.species = S
				var/ind = 0
				if(!isemptylist(tempSE))
					var/list/form_SE = new /list(DNA_SE_LENGTH)
					for(var/r in tempSE)
						ind++
						form_SE[ind] = text2num(r)
					org.dna.SE = form_SE.Copy()
				if(!isemptylist(tempUI))
					var/list/form_UI = new/list(DNA_UI_LENGTH)
					ind = 0
					for(var/r in tempUI)
						ind++
						form_UI[ind] = text2num(r)
					org.dna.UI = form_UI.Copy()
				if(!isemptylist(tempSE_structure))
					ind = 0
					for(var/type in tempSE_structure)
						ind++
						if(type && type != "0")
							var/datum/dna/gene/gene = new type()
							org.dna.SE_structure[ind] = gene
						else
							org.dna.SE_structure[ind] = 0
			return org
		else
			message_admins("failed to load organ")
			return

	log_game("ORGAN NOT FOUND [uid]")
	message_admins("ORGAN NOT FOUND [uid] ")
	return

/datum/preferences/proc/save_internalorgan(client/C, var/obj/item/organ/internal/obb, var/save_needed = 0)
	var/path = obb.type
	var/damage = obb.damage
	var/list/tempSE = list()
	var/list/tempUI = list()
	var/list/tempSE_structure =list()
	var/UE = 0
	if(obb.dna && save_needed)
		UE = obb.dna.unique_enzymes
		tempSE = obb.dna.SE
		tempUI = obb.dna.UI
		var/ind = 0
		tempSE_structure = new /list(DNA_SE_LENGTH)
		for(var/x in obb.dna.SE_structure)
			ind++
			if(istype(x, /datum/dna/gene))
				var/datum/dna/gene/gene = x
				tempSE_structure[ind] = gene.type
			else
				tempSE_structure[ind] = 0
	var/paramSE = list2params(tempSE)
	var/paramUI = list2params(tempUI)
	var/paramStruc = list2params(tempSE_structure)
	var/DBQuery/query = dbcon.NewQuery({"
					INSERT INTO [format_table_name("internalorgans")] (path, damage, SE, UI, SE_structure, UE)

					VALUES
									('[path]', '[damage]', '[paramSE]', '[paramUI]', '[paramStruc]', '[UE]')
					"}
					)
	var/DBQuery/secondquery = dbcon.NewQuery({"
					SELECT LAST_INSERT_ID() FROM [format_table_name("internalorgans")]
					"}
					)

	if(!query.Execute())
		var/err = query.ErrorMsg()
		log_game("SQL ERROR during INTERNAL ORGAN SAVING : \[[err]\]\n")
		message_admins("SQL ERROR during INTERNAL ORGAN SAVING : \[[err]\]\n")
		return
	if(!secondquery.Execute())
		var/err = secondquery.ErrorMsg()
		log_game("SQL ERROR during ORGAN SAVING : \[[err]\]\n")
		message_admins("SQL ERROR during INTERNAL ORGAN SAVING : \[[err]\]\n")
		return

	while(secondquery.NextRow())
		var/id = secondquery.item[1]
		return text2num(id)

	return 0

/datum/preferences/proc/delete_internalorgan(client/C, var/uid)
	uid = text2num(uid)
	var/DBQuery/secondquery = dbcon.NewQuery("DELETE FROM [format_table_name("internalorgans")] WHERE id = '[uid]'")
	if(!secondquery.Execute())
		var/err = secondquery.ErrorMsg()
		log_game("SQL ERROR during character slot loading. Error : \[[err]\]\n")
		message_admins("SQL ERROR during character slot loading. Error : \[[err]\]\n")
		return

	return 1



/datum/preferences/proc/load_internalorgan(client/C, var/uid)
	uid = text2num(uid)
	if (uid == 0)
		return
	var/DBQuery/query = dbcon.NewQuery({"SELECT
					path,
					damage,
					SE,
					UI,
					SE_structure,
					UE
				 	FROM [format_table_name("internalorgans")] WHERE id='[uid]'"})
	if(!query.Execute())
		var/err = query.ErrorMsg()
		log_game("SQL ERROR during internal organ loading. Error : \[[err]\]\n")
		message_admins("SQL ERROR during internal organ loading. Error : \[[err]\]\n")
		return

	while(query.NextRow())
		var/path = query.item[1]
		var/damage = text2num(query.item[2])
		var/obj/item/organ/internal/org = new path()
		var/UE = query.item[6]
		if(org)
			org.damage = damage
			if(!(!UE || UE == "0"))
				org.dna = new /datum/dna()
				var/list/tempSE = ParamExplode(query.item[3], "&", DNA_SE_LENGTH)
				var/list/tempUI = ParamExplode(query.item[4], "&", DNA_UI_LENGTH)
				var/list/tempSE_structure = ParamExplode(replacetext(query.item[5], "%2f", "/"), "&", DNA_SE_LENGTH)
				org.dna.unique_enzymes = UE
				var/ind = 0
				if(!isemptylist(tempSE))
					var/list/form_SE = new /list(DNA_SE_LENGTH)
					for(var/r in tempSE)
						ind++
						form_SE[ind] = text2num(r)
					org.dna.SE = form_SE.Copy()
				if(!isemptylist(tempUI))
					var/list/form_UI = new/list(DNA_UI_LENGTH)
					ind = 0
					for(var/r in tempUI)
						ind++
						form_UI[ind] = text2num(r)
					org.dna.UI = form_UI.Copy()
				if(!isemptylist(tempSE_structure))
					ind = 0
					for(var/type in tempSE_structure)
						ind++
						if(type && type != "0")
							var/datum/dna/gene/gene = new type()
							org.dna.SE_structure[ind] = gene
						else
							org.dna.SE_structure[ind] = 0
			return org
		else
			message_admins("failed to load internal organ")
			return


	log_game("INTERNAL ORGAN NOT FOUND [uid]")
	message_admins("INTERNAL ORGAN NOT FOUND [uid] ")
	return

/datum/preferences/proc/save_wound(client/C, var/datum/wound/obb)
	var/path = obb.type
	var/damage = obb.damage
	var/treated = obb.is_treated()
	var/surgery_treated = obb.surgery_treated
	var/internal = obb.internal
	var/DBQuery/query = dbcon.NewQuery({"
					INSERT INTO [format_table_name("wounds")] (path, damage, basic_treatment, surgery_treatment, internal_bleeding)

					VALUES
									('[path]', '[damage]', '[treated]', '[surgery_treated]', '[internal]')
					"}
					)
	var/DBQuery/secondquery = dbcon.NewQuery({"
					SELECT LAST_INSERT_ID() FROM [format_table_name("wounds")]
					"}
					)

	if(!query.Execute())
		var/err = query.ErrorMsg()
		log_game("SQL ERROR during WOUND SAVING : \[[err]\]\n")
		message_admins("SQL ERROR during WOUND SAVING : \[[err]\]\n")
		return
	if(!secondquery.Execute())
		var/err = secondquery.ErrorMsg()
		log_game("SQL ERROR during WOUND SAVING : \[[err]\]\n")
		message_admins("SQL ERROR during WOUND SAVING : \[[err]\]\n")
		return

	while(secondquery.NextRow())
		var/id = secondquery.item[1]
		return text2num(id)

	return 0

/datum/preferences/proc/delete_wound(client/C, var/uid)
	uid = text2num(uid)
	var/DBQuery/secondquery = dbcon.NewQuery("DELETE FROM [format_table_name("wounds")] WHERE id = '[uid]'")
	if(!secondquery.Execute())
		var/err = secondquery.ErrorMsg()
		log_game("SQL ERROR during character slot loading. Error : \[[err]\]\n")
		message_admins("SQL ERROR during character slot loading. Error : \[[err]\]\n")
		return

	return 1

/datum/preferences/proc/load_wound(client/C, var/uid)
	uid = text2num(uid)
	if (uid == 0)
		return
	var/DBQuery/query = dbcon.NewQuery({"SELECT
					path,
					damage,
					basic_treatment,
					surgery_treatment,
					internal_bleeding
				 	FROM [format_table_name("wounds")] WHERE id='[uid]'"})
	if(!query.Execute())
		var/err = query.ErrorMsg()
		log_game("SQL ERROR during wound loading. Error : \[[err]\]\n")
		message_admins("SQL ERROR during wound loading. Error : \[[err]\]\n")
		return

	while(query.NextRow())
		var/path = query.item[1]
		var/damage = text2num(query.item[2])
		var/basic_treatment = text2num(query.item[3])
		var/surgery_treatment = text2num(query.item[4])
		var/internal = text2num(query.item[5])
		var/datum/wound/wo = new path()
		if(wo)
			wo.damage = damage
			if(basic_treatment)
				if(wo.damage_type == CUT)
					wo.bandaged = 1
				else if(wo.damage_type == BURN)
					wo.salved = 1
				else if(wo.damage_type == BRUISE)
					wo.splinted = 1
			if(surgery_treatment)
				wo.surgery_treated = 1
			if(internal)
				wo.internal = 1
			return wo
		else
			message_admins("failed to load wound")
			return


	log_game("WOUND NOT FOUND [uid]")
	message_admins("WOUND NOT FOUND [uid] ")
	return

/datum/preferences/proc/save_item(client/C, var/obj/item/obb)
	var/list/content = list()
	if (!istype(obb, /obj/) || !obb.save_obj)
		return
	var/path = obb.type
	var/name = sql_sanitize_text(obb.name)
	var/icon_state = obb.icon_state
	var/charge = 0
	var/list/tempSE = list()
	var/list/tempUI = list()
	var/UE = ""
	var/list/tempSE_structure = list()
	var/b_type = ""
	var/list/hair_rgb = new/list(3)
	var/list/facial_rgb = new/list(3)
	var/list/hacc_rgb = new/list(3)
	var/th_style = ""
	var/tf_style = ""
	var/tha_style = ""
	var/species = ""
	var/list/reagents = list()
	var/gas_mixture = 0
	if(obb.reagents)
		for(var/datum/reagent/x in obb.reagents.reagent_list)
			reagents |= save_reagent(C, x)
	if(obb.air_contents)
		gas_mixture = save_gasmixture(C, obb.air_contents) 
	if(istype(obb, /obj/item/organ))
		var/obj/item/organ/org = obb
		if(istype(obb, /obj/item/organ/external))
			var/obj/item/organ/external/orgn = obb	
			icon_state = orgn.icon_name
		if(org.dna)
			tempSE = org.dna.SE
			tempUI = org.dna.UI
			UE = org.dna.unique_enzymes
			b_type = org.dna.b_type
			var/ind = 0
			tempSE_structure = new /list(DNA_SE_LENGTH)
			for(var/x in org.dna.SE_structure)
				ind++
				if(istype(x, /datum/dna/gene))
					var/datum/dna/gene/gene = x
					tempSE_structure[ind] = gene.type
				else
					tempSE_structure[ind] = 0
		if(org.species)
			species = org.species.name
		else
			species = "Human"
		if(istype(obb, /obj/item/organ/external/head))
			var/obj/item/organ/external/head/He = obb
			for(var/obj/item/organ/internal/brain/x in He.contents)
				if(x && x.brainmob && x.brainmob.mind && x.brainmob.mind.active)
					return 0 // heads with active brains dont save, instead saving as the head owners character
			hair_rgb[1] = He.r_hair
			hair_rgb[2] = He.g_hair
			hair_rgb[3] = He.b_hair
			facial_rgb[1] = He.r_facial
			facial_rgb[2] = He.g_facial
			facial_rgb[3] = He.b_facial
			th_style = He.h_style
			tf_style = He.f_style
			tha_style = He.ha_style
			hacc_rgb[1] = He.r_headacc
			hacc_rgb[2] = He.g_headacc
			hacc_rgb[3] = He.b_headacc
	var/paramSE = list2params(tempSE)
	var/paramUI = list2params(tempUI)
	var/paramStruc = list2params(tempSE_structure)
	var/paramH_rgb = list2params(hair_rgb)
	var/paramF_rgb = list2params(facial_rgb)
	var/paramHa_rgb = list2params(hacc_rgb)
	var/paramreagent = list2params(reagents)
	if(istype(obb, /obj/item/weapon/stock_parts/cell))
		var/obj/item/weapon/stock_parts/cell/cell = obb
		charge = cell.charge
	for(var/obj/item/pa in obb.contents)
		var/tempint = save_item(C, pa)
		content += tempint	
	var/list/contentlist = list2params(content)
	var/DBQuery/query = dbcon.NewQuery({"
					INSERT INTO [format_table_name("items")] (path, name, contents, icon_state, charge, SE, UI, SE_structure, UE, b_type, hair_rgb, facial_rgb, hacc_rgb, h_style, f_style, ha_style, species, reagents, gas_mixture)

					VALUES
									('[path]', '[name]', '[contentlist]', '[icon_state]', '[charge]', '[paramSE]', '[paramUI]', '[paramStruc]', '[UE]', '[b_type]', '[paramH_rgb]', '[paramF_rgb]', '[paramHa_rgb]', '[th_style]', '[tf_style]', '[tha_style]', '[species]', '[paramreagent]', '[gas_mixture]')
					"}
					)
	var/DBQuery/secondquery = dbcon.NewQuery({"
					SELECT LAST_INSERT_ID() FROM [format_table_name("items")]
					"}
					)

	if(!query.Execute())
		var/err = query.ErrorMsg()
		log_game("SQL ERROR during ITEM SAVING : \[[err]\]\n")
		message_admins("SQL ERROR during ITEM SAVING : \[[err]\]\n")
		return
	if(!secondquery.Execute())
		var/err = secondquery.ErrorMsg()
		log_game("SQL ERROR during ITEM SAVING : \[[err]\]\n")
		message_admins("SQL ERROR during ITEM SAVING : \[[err]\]\n")
		return

	while(secondquery.NextRow())
		var/id = secondquery.item[1]
		return text2num(id)

	return 0




/datum/preferences/proc/delete_inventory(client/C)

	var/slot = default_slot
	if(!slot)	slot = default_slot
	slot = sanitize_integer(slot, 1, max_save_slots, initial(default_slot))


	// Let's not have this explode if you sneeze on the DB
	var/DBQuery/query = dbcon.NewQuery({"SELECT
					slot_w_uniform, slot_wear_suit,
					slot_shoes, slot_gloves, slot_l_ear,
					slot_glasses, slot_wear_mask, slot_head,
					slot_belt, slot_r_store, slot_l_store,
					slot_back, slot_wear_id, slot_wear_pda, slot_l_hand,
					slot_r_hand, slot_s_store, brain
				 	FROM [format_table_name("inventory")] WHERE ckey='[C.ckey]' AND slot='[slot]'"})
	if(!query.Execute())
		var/err = query.ErrorMsg()
		log_game("SQL ERROR during character slot loading. Error : \[[err]\]\n")
		message_admins("SQL ERROR during character slot loading. Error : \[[err]\]\n")
		return

	while(query.NextRow())
		delete_item(C, query.item[1])
		delete_item(C, query.item[2])
		delete_item(C, query.item[3])
		delete_item(C, query.item[4])
		delete_item(C, query.item[5])
		delete_item(C, query.item[6])
		delete_item(C, query.item[7])
		delete_item(C, query.item[8])
		delete_item(C, query.item[9])
		delete_item(C, query.item[10])
		delete_item(C, query.item[11])
		delete_item(C, query.item[12])
		delete_item(C, query.item[13])
		delete_item(C, query.item[14])
		delete_item(C, query.item[15])
		delete_item(C, query.item[16])
		delete_item(C, query.item[17])
		var/list/brainlist = params2list(query.item[18])
		if(brainlist && !isemptylist(brainlist))
			for(var/x in brainlist)
				delete_item(C, x)
	reset_inventory()
	return 1

/datum/preferences/proc/reset_inventory()
	slot_w_uniform_pref = 0
	slot_wear_suit_pref = 0
	slot_shoes_pref = 0
	slot_gloves_pref = 0
	slot_l_ear_pref = 0
	slot_glasses_pref = 0
	slot_wear_mask_pref = 0
	slot_head_pref = 0
	slot_belt_pref = 0
	slot_r_store_pref = 0
	slot_l_store_pref = 0
	slot_back_pref = 0
	slot_wear_id_pref = 0
	slot_wear_pda_pref = 0
	slot_l_hand_pref = 0
	slot_r_hand_pref = 0
	slot_s_store_pref = 0
	brain = list()
	SE = null
	UI = null
	SE_structure = null
	current_body = 0
	body_type = 0
	
/datum/preferences/proc/load_inventory(client/C, var/mob/living/carbon/human/H, var/nohands = 0, var/nocontents = 0)

	var/slot = default_slot
	if(!slot)	slot = default_slot
	slot = sanitize_integer(slot, 1, max_save_slots, initial(default_slot))


	// Let's not have this explode if you sneeze on the DB
	var/DBQuery/query = dbcon.NewQuery({"SELECT
					slot_w_uniform, slot_wear_suit,
					slot_shoes, slot_gloves, slot_l_ear,
					slot_glasses, slot_wear_mask, slot_head,
					slot_belt, slot_r_store, slot_l_store,
					slot_back, slot_wear_id, slot_wear_pda, slot_l_hand,
					slot_r_hand, slot_s_store, brain
				 	FROM [format_table_name("inventory")] WHERE ckey='[C.ckey]' AND slot='[slot]'"})
	if(!query.Execute())
		var/err = query.ErrorMsg()
		log_game("SQL ERROR during character slot loading. Error : \[[err]\]\n")
		message_admins("SQL ERROR during character slot loading. Error : \[[err]\]\n")
		return

	while(query.NextRow())
		var/obj/temp
		if (!nohands)
			temp = load_item(C, query.item[15], nocontents)
			if(istype(temp, /obj/))
				H.equip_or_collect(temp, slot_l_hand)
			temp = load_item(C, query.item[16], nocontents)
			if(istype(temp, /obj/))
				H.equip_or_collect(temp, slot_r_hand)
		temp = load_item(C, query.item[1], nocontents)
		if(istype(temp, /obj/))
			H.equip_to_slot_or_del(temp, slot_w_uniform)
		temp = load_item(C, query.item[2], nocontents)
		if(istype(temp, /obj/))
			H.equip_to_slot_or_del(temp, slot_wear_suit)
		temp = load_item(C, query.item[3], nocontents)
		if(istype(temp, /obj/))
			H.equip_or_collect(temp, slot_shoes)
		temp = load_item(C, query.item[4], nocontents)
		if(istype(temp, /obj/))
			H.equip_or_collect(temp, slot_gloves)
		temp = load_item(C, query.item[5], nocontents)
		if(istype(temp, /obj/))
			H.equip_or_collect(temp, slot_l_ear)
		temp = load_item(C, query.item[6], nocontents)
		if(istype(temp, /obj/))
			H.equip_or_collect(temp, slot_glasses)
		temp = load_item(C, query.item[7], nocontents)
		if(istype(temp, /obj/))
			H.equip_or_collect(temp, slot_wear_mask)
		temp = load_item(C, query.item[8], nocontents)
		if(istype(temp, /obj/))
			H.equip_or_collect(temp, slot_head)
		temp = load_item(C, query.item[9], nocontents)
		if(istype(temp, /obj/))
			H.equip_or_collect(temp, slot_belt)
		temp = load_item(C, query.item[10], nocontents)
		if(istype(temp, /obj/))
			H.equip_or_collect(temp, slot_r_store)
		temp = load_item(C, query.item[11], nocontents)
		if(istype(temp, /obj/))
			H.equip_or_collect(temp, slot_l_store)
		temp = load_item(C, query.item[12], nocontents)
		if(istype(temp, /obj/))
			H.equip_or_collect(temp, slot_back)
		temp = load_item(C, query.item[13], nocontents)
		if(istype(temp, /obj/))
			H.equip_or_collect(temp, slot_wear_id)
		temp = load_item(C, query.item[14], nocontents)
		if(istype(temp, /obj/))
			H.equip_or_collect(temp, slot_wear_pda)
		temp = load_item(C, query.item[17], nocontents)
		if(istype(temp, /obj/))
			H.equip_or_collect(temp, slot_s_store)
		if(!nohands)
			brain = params2list(query.item[18])

			if(!isemptylist(brain))
				var/obj/item/weapon/implant/I
				for(var/x in brain)
					I = load_item(C, x, nocontents)
					if(istype(I))
						I.implant(H)

/datum/preferences/proc/save_inventory(client/C)
	var/brainlist
	if(!isemptylist(brain))
		brainlist = list2params(brain)

	var/DBQuery/firstquery = dbcon.NewQuery("SELECT slot FROM [format_table_name("inventory")] WHERE ckey='[C.ckey]' ORDER BY slot")
	firstquery.Execute()
	while(firstquery.NextRow())
		if(text2num(firstquery.item[1]) == default_slot)
			var/DBQuery/query = dbcon.NewQuery({"UPDATE [format_table_name("inventory")] SET real_name='[sql_sanitize_text(real_name)]',
												slot_w_uniform='[slot_w_uniform_pref]',
												slot_wear_suit='[slot_wear_suit_pref]',
												slot_shoes='[slot_shoes_pref]',
												slot_gloves='[slot_gloves_pref]',
												slot_l_ear='[slot_l_ear_pref]',
												slot_glasses='[slot_glasses_pref]',
												slot_wear_mask='[slot_wear_mask_pref]',
												slot_head='[slot_head_pref]',
												slot_belt='[slot_belt_pref]',
												slot_r_store='[slot_r_store_pref]',
												slot_l_store='[slot_l_store_pref]',
												slot_back='[slot_back_pref]',
												slot_wear_id='[slot_wear_id_pref]',
												slot_wear_pda='[slot_wear_pda_pref]',
												slot_l_hand='[slot_l_hand_pref]',
												slot_r_hand='[slot_r_hand_pref]',
												slot_s_store='[slot_s_store_pref]',
												brain='[brainlist]'
												WHERE ckey='[C.ckey]'
												AND slot='[default_slot]'"}
												)

			if(!query.Execute())
				var/err = query.ErrorMsg()
				log_game("SQL ERROR during character slot saving. Error : \[[err]\]\n")
				message_admins("SQL ERROR during character slot saving. Error : \[[err]\]\n")
				return
			return 1

	var/DBQuery/query = dbcon.NewQuery({"
					INSERT INTO [format_table_name("inventory")] (ckey, slot, real_name, slot_w_uniform, slot_wear_suit,
											slot_shoes, slot_gloves, slot_l_ear,
											slot_glasses, slot_wear_mask, slot_head,
											slot_belt, slot_r_store, slot_l_store,
											slot_back, slot_wear_id, slot_wear_pda, slot_l_hand,
											slot_r_hand, slot_s_store, brain)

					VALUES
											('[C.ckey]', '[default_slot]', '[sql_sanitize_text(real_name)]', '[slot_w_uniform_pref]','[slot_wear_suit_pref]',
											'[slot_shoes_pref]', '[slot_gloves_pref]', '[slot_l_ear_pref]',
											'[slot_glasses_pref]', '[slot_wear_mask_pref]', '[slot_head_pref]',
											'[slot_belt_pref]', '[slot_r_store_pref]', '[slot_l_store_pref]',
											'[slot_back_pref]', '[slot_wear_id_pref]', '[slot_wear_pda_pref]', '[slot_l_hand_pref]',
											'[slot_r_hand_pref]', '[slot_s_store_pref]', '[brainlist]')

					"}
					)

	if(!query.Execute())
		var/err = query.ErrorMsg()
		log_game("SQL ERROR during character slot saving. Error : \[[err]\]\n")
		message_admins("SQL ERROR during character slot saving. Error : \[[err]\]\n")
		return
	return 1

/datum/preferences/proc/save_robot(client/C, var/mob/living/silicon/robot/H)
	if(H)
		var/list/components = list()
		for(var/V in H.components)
			var/datum/robot_component/Co = H.components[V]
			components |= save_robotcomponent(C, Co)
		var/module_state_1 = 0
		var/module_state_2 = 0
		var/module_state_3 = 0
		var/chassis_mod = 0
		var/chassis_toggled = 0
		var/list/module_contents = list()
		var/module_enabled = 0
		var/module_chip = 0
		if(H.installed_module)
			module_chip = save_item(C, H.installed_module)
			if(H.module)
				if(H.module_state_1)
					module_state_1 = save_item(C, H.module_state_1)
				if(H.module_state_2)
					module_state_2 = save_item(C, H.module_state_2)
				if(H.module_state_3)
					module_state_3 = save_item(C, H.module_state_3)
				for(var/obj/obb in H.module.contents)
					module_contents |= save_item(C, obb)
				module_enabled = 1
			else
				module_enabled = 0
				for(var/obj/obb in H.installed_module.contents)
					module_contents |= save_item(C, obb)
		if(H.chassis_mod)
			chassis_mod = save_item(C, H.chassis_mod)
			chassis_toggled = H.chassis_mod_toggled
		var/mod_params = list2params(module_contents)
		var/comp_params = list2params(components)
		var/DBQuery/query = dbcon.NewQuery({"
					INSERT INTO [format_table_name("robots")] (module_state_1, module_state_2, module_state_3, chassis_mod, chassis_toggled, module_contents, module_enabled, module_chip, components)

					VALUES
									('[module_state_1]', '[module_state_2]', '[module_state_3]', '[chassis_mod]', '[chassis_toggled]', '[mod_params]', '[module_enabled]', '[module_chip]', '[comp_params]')
					"}
					)
		var/DBQuery/secondquery = dbcon.NewQuery({"
					SELECT LAST_INSERT_ID() FROM [format_table_name("robots")]
					"}
					)

		if(!query.Execute())
			var/err = query.ErrorMsg()
			log_game("SQL ERROR during ITEM SAVING : \[[err]\]\n")
			message_admins("SQL ERROR during ITEM SAVING : \[[err]\]\n")
			return
		if(!secondquery.Execute())
			var/err = secondquery.ErrorMsg()
			log_game("SQL ERROR during ITEM SAVING : \[[err]\]\n")
			message_admins("SQL ERROR during ITEM SAVING : \[[err]\]\n")
			return

		while(secondquery.NextRow())
			var/id = secondquery.item[1]
			return text2num(id)

		return 0

	else
		return

/datum/preferences/proc/load_robot(client/C, var/uid, var/nocontents = 0)
	// Let's not have this explode if you sneeze on the DB
	uid = text2num(uid)
	if (uid == 0)
		return
	var/DBQuery/query = dbcon.NewQuery({"SELECT
					module_state_1,
					module_state_2,
					module_state_3,
					chassis_mod,
					chassis_toggled,
					module_contents,
					module_enabled,
					module_chip,
					components,
					mmi
				 	FROM [format_table_name("robots")] WHERE id='[uid]'"})
	if(!query.Execute())
		var/err = query.ErrorMsg()
		log_game("SQL ERROR during robot loading. Error : \[[err]\]\n")
		message_admins("SQL ERROR during robot loading. Error : \[[err]\]\n")
		return

	var/mob/living/silicon/robot/H = new(loaded = 1)
	while(query.NextRow())
		var/list/module_list
		if(!nocontents)
			H.module_state_1 = load_item(C, query.item[1])
			H.module_state_2 = load_item(C, query.item[2])
			H.module_state_3 = load_item(C, query.item[3])
			module_list = params2list(query.item[6])
			var/list/components = params2list(query.item[9])
			for(var/x in components)
				var/datum/robot_component/comp = load_robotcomponent(C, x)
				if(comp)
					comp.installed = 1
					H.components[comp.component_name] = comp
					H.contents |= comp.wrapped
					if(istype(comp.wrapped, /obj/item/weapon/stock_parts/cell))
						H.cell = comp.wrapped
		var/module_enabled = text2num(query.item[7])
		H.installed_module = load_item(C, query.item[8])
		if(H.installed_module)
			H.installed_module.installed = 1
			if(module_enabled)
				H.module = new H.installed_module.module_type()
				H.icon_state = H.installed_module.default_icon
			else
				if(!nocontents)
					for(var/x in module_list)
						H.installed_module.contents |= load_item(C, x)
		H.chassis_mod = load_item(C, query.item[4])
		var/chassis_toggled = text2num(query.item[5])
		if(H.chassis_mod)
			if(chassis_toggled)
				H.icon_state = H.chassis_mod.chassis_type
		var/obj/item/device/mmi = load_item(C, query.item[6])
		mmi.loc = H
		H.mmi = mmi
		return H
	log_game("ITEM NOT FOUND [uid]")
	message_admins("ITEM NOT FOUND [uid] ")
	return


/datum/preferences/proc/delete_robot(client/C, var/uid)
	uid = text2num(uid)
	message_admins("attempting to delete body [uid]")
	var/DBQuery/query = dbcon.NewQuery({"SELECT
					module_state_1,
					module_state_2,
					module_state_3,
					chassis_mod,
					module_contents,
					module_chip,
					components,
					mmi
				 	FROM [format_table_name("robots")] WHERE id='[uid]'"})
	if(!query.Execute())
		var/err = query.ErrorMsg()
		log_game("SQL ERROR during delete_robot Error : \[[err]\]\n")
		message_admins("SQL ERROR during delete_robot Error : \[[err]\]\n")
		return

	while(query.NextRow())
		delete_item(C, query.item[1])
		delete_item(C, query.item[2])
		delete_item(C, query.item[3])
		delete_item(C, query.item[4])
		var/list/contentslist = params2list(query.item[5])
		for(var/x in contentslist)
			delete_item(C, x)
		delete_item(C, query.item[6])
		var/list/componentslist = params2list(query.item[7])
		for(var/x in componentslist)
			delete_robotcomponent(C, x)
		
	var/DBQuery/secondquery = dbcon.NewQuery("DELETE FROM [format_table_name("robots")] WHERE id = '[uid]'")
	if(!secondquery.Execute())
		var/err = secondquery.ErrorMsg()
		log_game("SQL ERROR during delete_robot Error : \[[err]\]\n")
		message_admins("SQL ERROR during delete_robot Error : \[[err]\]\n")
		return
	return 1

	
/datum/preferences/proc/save_mind(client/C, var/datum/mind/H, var/mob/living/carbon/human/Firstbod)
	return map_storage.Save_Char(C, H, Firstbod, H.char_slot)
	var/current = 0
	var/ckey
	if(H)
		if(H.current && H.current.ckey && !Firstbod)
			real_name = H.current.real_name
			slot = H.char_slot
			ckey = H.current.ckey
			stat_Grit = H.stat_Grit
			stat_Fortitude = H.stat_Fortitude
			stat_Reflex = H.stat_Reflex
			stat_Creativity = H.stat_Creativity
			stat_Focus = H.stat_Focus
			ambition = H.ambition
			if(istype(H.current, /mob/living/carbon/human))
				body_type = 1
				current = save_body(C, H.current)
			else if(istype(H.current, /mob/living/carbon/brain/))
				body_type = 2
				current = save_brain(C, H.current)
			else if(istype(H.current, /mob/living/silicon/robot/))
				body_type = 3
				current = save_robot(C, H.current)
			else if(istype(H.current, /mob/living/simple_animal/spiderbot))
				body_type = 4
				current = save_spiderbot(C, H.current)
			else
				message_admins("Unhandled save operation! [H.current]")
				return
		else if(Firstbod)
			ckey = C.ckey
			body_type = 1
		//	copyto_body(C, Firstbod)
			current = save_body(C, Firstbod)
			current_status = "alive"
		else
			message_admins("No current for [H]")
			return
		if(istype(H.initial_account) && !Firstbod)
			account["pin"] = H.initial_account.remote_access_pin
			account["num"] = H.initial_account.account_number
			energy_creds = H.initial_account.money

		if(H.certs && !Firstbod)
			certs = list()
			for(var/datum/cert/c in H.certs)
				certs += c.uid

		if(H.primary_cert && !Firstbod)
			primary_cert = H.primary_cert.uid

		if(H.cert_title && !Firstbod)
			cert_title = H.cert_title

		if(H.ranks  && !Firstbod)
			department_ranks = H.ranks

		if(H.faction && !Firstbod)
			faction = H.faction.faction_uid
		else
			faction = ""
	else
		message_admins("Failed saving! No mind!")
		return
	var/playertitlelist
	var/accountlist
	var/rankslist
	var/certlist
	var/SElist
	var/UIlist
	var/SEstructurelist
	if(account && !isemptylist(account))
		accountlist = list2params(account)
	if(player_alt_titles && !isemptylist(player_alt_titles))
		playertitlelist = list2params(player_alt_titles)
	if(certs && !isemptylist(certs))
		certlist = list2params(certs)
	if(department_ranks && !isemptylist(department_ranks))
		rankslist = list2params(department_ranks)
	if(SE && !isemptylist(SE))
		SElist = list2params(SE)
	if(UI && !isemptylist(UI))
		UIlist = list2params(UI)
	if(SE_structure && !isemptylist(SE_structure))
		SEstructurelist = list2params(SE_structure)
	var/DBQuery/firstquery = dbcon.NewQuery("SELECT slot, body, body_type FROM [format_table_name("character")] WHERE ckey='[ckey]' ORDER BY slot")
	firstquery.Execute()
	while(firstquery.NextRow())
		if(text2num(firstquery.item[1]) == slot)
			var/body_num = firstquery.item[2]
			var/body_t = text2num(firstquery.item[3])
			if(body_t == 1)
				delete_body(C, body_num)
			else if(body_t == 2)
				delete_brain(C, body_num)
			else if(body_t == 3)
				delete_robot(C, body_num)
			else if(body_t == 4)
				delete_spiderbot(C, body_num)
			var/DBQuery/query = dbcon.NewQuery({"UPDATE [format_table_name("character")] SET
												OOC_Notes='[sql_sanitize_text(metadata)]',
												real_name='[real_name]',
												gender='[gender]',
												age='[age]',
												species='[sql_sanitize_text(species)]',
												language='[sql_sanitize_text(language)]',
												b_type='[b_type]',
												flavor_text='[sql_sanitize_text(html_decode(flavor_text))]',
												med_record='[sql_sanitize_text(html_decode(med_record))]',
												sec_record='[sql_sanitize_text(html_decode(sec_record))]',
												gen_record='[sql_sanitize_text(html_decode(gen_record))]',
												nanotrasen_relation='[nanotrasen_relation]',
												current_status='[current_status]',
												energy_creds='[energy_creds]',
												account='[accountlist]',
												certifications='[certlist]',
												primary_cert='[sql_sanitize_text(primary_cert)]',
												cert_title='[sql_sanitize_text(cert_title)]',
												department_ranks='[rankslist]',
												faction='[faction]',
												UI='[UIlist]',
												SE='[SElist]',
												SE_structure='[SEstructurelist]',
												body='[current]',
												body_type='[body_type]',
												stat_Grit='[stat_Grit]',
												stat_Fortitude='[stat_Fortitude]',
												stat_Reflex='[stat_Reflex]',
												stat_Creativity='[stat_Creativity]',
												stat_Focus='[stat_Focus]',
												ambition='[ambition]'
												WHERE ckey='[ckey]'
												AND slot='[slot]'"}
												)

			if(!query.Execute())
				var/err = query.ErrorMsg()
				log_game("SQL ERROR during character slot DEBUG!! saving. Error : \[[err]\]\n")
				message_admins("SQL ERROR during character slot DEBUG !! saving. Error : \[[err]\]\n")
				return
			return 1

	var/DBQuery/query = dbcon.NewQuery({"
			INSERT INTO [format_table_name("character")] (ckey, slot, OOC_Notes, real_name, gender,
									age, species, language,
									b_type, flavor_text,
									med_record, sec_record, gen_record,
									nanotrasen_relation, current_status, energy_creds, account,
									certifications, primary_cert, cert_title, department_ranks, faction,
									UI, SE, SE_structure,
									body, body_type, stat_Grit, stat_Fortitude, stat_Reflex, stat_Creativity, stat_Focus, ambition)

			VALUES
									('[ckey]', '[default_slot]', '[sql_sanitize_text(metadata)]', '[sql_sanitize_text(real_name)]', '[gender]',
									'[age]', '[sql_sanitize_text(species)]', '[sql_sanitize_text(language)]',
									'[b_type]', '[sql_sanitize_text(html_encode(flavor_text))]',
									'[sql_sanitize_text(html_encode(med_record))]', '[sql_sanitize_text(html_encode(sec_record))]', '[sql_sanitize_text(html_encode(gen_record))]',
									'[nanotrasen_relation]', '[current_status]', '[energy_creds]', '[accountlist]',
									'[certlist]', '[sql_sanitize_text(primary_cert)]', '[sql_sanitize_text(cert_title)]', '[rankslist]', '[faction]',
									'[UIlist]', '[SElist]', '[SEstructurelist]', 
									'[current]', '[body_type]',
									'[stat_Grit]', '[stat_Fortitude]', '[stat_Reflex]', '[stat_Creativity]', '[stat_Focus]', '[ambition]')
			"})

	if(!query.Execute())
		var/err = query.ErrorMsg()
		log_game("SQL ERROR during character slot saving. Error : \[[err]\]\n")
		message_admins("SQL ERROR during character slot saving. Error : \[[err]\]\n")
		return
	return 1



/datum/preferences/proc/delete_body(client/C, var/uid)
	uid = text2num(uid)
	message_admins("attempting to delete body [uid]")
	var/DBQuery/query = dbcon.NewQuery({"SELECT
					slot_w_uniform, slot_wear_suit,
					slot_shoes, slot_gloves, slot_l_ear, slot_r_ear,
					slot_glasses, slot_wear_mask, slot_head,
					slot_belt, slot_r_store, slot_l_store,
					slot_back, slot_wear_id, slot_wear_pda, slot_l_hand,
					slot_r_hand, slot_s_store, implants, organs, internal_organs
				 	FROM [format_table_name("bodies")] WHERE id='[uid]'"})
	if(!query.Execute())
		var/err = query.ErrorMsg()
		log_game("SQL ERROR during delete_body 1 loading. Error : \[[err]\]\n")
		message_admins("SQL ERROR during delete_body 1  Error : \[[err]\]\n")
		return

	while(query.NextRow())
		delete_item(C, query.item[1])
		delete_item(C, query.item[2])
		delete_item(C, query.item[3])
		delete_item(C, query.item[4])
		delete_item(C, query.item[5])
		delete_item(C, query.item[6])
		delete_item(C, query.item[7])
		delete_item(C, query.item[8])
		delete_item(C, query.item[9])
		delete_item(C, query.item[10])
		delete_item(C, query.item[11])
		delete_item(C, query.item[12])
		delete_item(C, query.item[13])
		delete_item(C, query.item[14])
		delete_item(C, query.item[15])
		delete_item(C, query.item[16])
		delete_item(C, query.item[17])
		delete_item(C, query.item[18])
		var/list/brainlist = params2list(query.item[19])
		if(brainlist && !isemptylist(brainlist))
			for(var/x in brainlist)
				delete_item(C, x)
		var/list/organlist = params2list(query.item[20])
		if(organlist && !isemptylist(organlist))
			for(var/x in organlist)
				delete_organ(C, x)
		var/list/internalorganlist = params2list(query.item[21])
		if(internalorganlist && !isemptylist(internalorganlist))
			for(var/x in internalorganlist)
				delete_internalorgan(C, x)
	var/DBQuery/secondquery = dbcon.NewQuery("DELETE FROM [format_table_name("bodies")] WHERE id = '[uid]'")
	if(!secondquery.Execute())
		var/err = secondquery.ErrorMsg()
		log_game("SQL ERROR during delete_body 2 Error : \[[err]\]\n")
		message_admins("SQL ERROR during delete_body 2 Error : \[[err]\]\n")
		return


	return 1

/datum/preferences/proc/copyto_body(client/C, var/mob/living/carbon/human/character) // copies the appearanec to a body for initial dna creation
	character.dna.real_name = real_name
	character.flavor_text = flavor_text
	character.age = age
	character.b_type = b_type
	character.r_eyes = r_eyes
	character.g_eyes = g_eyes
	character.b_eyes = b_eyes
	var/datum/species/S = all_species[species]
	character.change_species(species, null, 0, 1) 
	//Head-specific
	var/obj/item/organ/external/head/H = character.get_organ("head")
	if(H)
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
		
	character.dna.ready_dna(character, flatten_SE = 1)
	character.dna.ResetUIFrom(character)
	message_admins("[character.dna.UI[7]]")
	character.change_gender(gender)
	
/datum/preferences/proc/load_body(client/C, var/uid, var/nocontents = 0)
	uid = text2num(uid)
	if (uid == 0)
		return
	// Let's not have this explode if you sneeze on the DB
	var/undershirt_num = 0
	var/underwear_num = 0
	var/list/implants
	var/list/organs
	var/list/internalorgans
	var/DBQuery/query = dbcon.NewQuery({"SELECT
					real_name,
					gender,
					age,
					species,
					language,
					hair_red,
					hair_green,
					hair_blue,
					facial_red,
					facial_green,
					facial_blue,
					skin_tone,
					skin_red,
					skin_green,
					skin_blue,
					markings_red,
					markings_green,
					markings_blue,
					head_accessory_red,
					head_accessory_green,
					head_accessory_blue,
					hair_style_name,
					facial_style_name,
					marking_style_name,
					head_accessory_style_name,
					eyes_red,
					eyes_green,
					eyes_blue,
					underwear,
					undershirt,
					b_type,
					flavor_text,
					socks,
					body_accessory,
					SE,
					UI,
					SE_structure,
					slot_w_uniform,
					slot_wear_suit,
					slot_shoes,
					slot_gloves,
					slot_l_ear,
					slot_r_ear,
					slot_glasses,
					slot_wear_mask,
					slot_head,
					slot_belt,
					slot_r_store,
					slot_l_store,
					slot_back,
					slot_wear_id,
					slot_wear_pda,
					slot_l_hand,
					slot_r_hand,
					slot_s_store,
					implants,
					organs,
					internal_organs,
					mech
				 	FROM [format_table_name("bodies")] WHERE id='[uid]'"})
	if(!query.Execute())
		var/err = query.ErrorMsg()
		log_game("SQL ERROR during body  loading. Error : \[[err]\]\n")
		message_admins("SQL ERROR body loading. Error : \[[err]\]\n")
		return
	var/mech = 0
	while(query.NextRow())
		real_name = query.item[1]
		gender = query.item[2]
		age = text2num(query.item[3])
		species = query.item[4]
		language = query.item[5]
		r_hair = text2num(query.item[6])
		g_hair = text2num(query.item[7])
		b_hair = text2num(query.item[8])
		r_facial = text2num(query.item[9])
		g_facial = text2num(query.item[10])
		b_facial = text2num(query.item[11])
		s_tone = text2num(query.item[12])
		r_skin = text2num(query.item[13])
		g_skin = text2num(query.item[14])
		b_skin = text2num(query.item[15])
		r_markings = text2num(query.item[16])
		g_markings = text2num(query.item[17])
		b_markings = text2num(query.item[18])
		r_headacc = text2num(query.item[19])
		g_headacc = text2num(query.item[20])
		b_headacc = text2num(query.item[21])
		h_style = query.item[22]
		f_style = query.item[23]
		m_style = query.item[24]
		ha_style = query.item[25]
		r_eyes = text2num(query.item[26])
		g_eyes = text2num(query.item[27])
		b_eyes = text2num(query.item[28])
		underwear_num = query.item[29]
		undershirt_num = query.item[30]
		b_type = query.item[31]
		flavor_text = query.item[32]
		socks = query.item[33]
		body_accessory = query.item[34]
		SE = ParamExplode(query.item[35], "&", DNA_SE_LENGTH)
		UI = ParamExplode(query.item[36], "&", DNA_UI_LENGTH)
		SE_structure = ParamExplode(replacetext(query.item[37], "%2f", "/"), "&", DNA_SE_LENGTH)
		slot_w_uniform_pref = (query.item[38])
		slot_wear_suit_pref =(query.item[39])
		slot_shoes_pref = (query.item[40])
		slot_gloves_pref = (query.item[41])
		slot_l_ear_pref = (query.item[42])
		slot_r_ear_pref = (query.item[43])
		slot_glasses_pref = (query.item[44])
		slot_wear_mask_pref = (query.item[45])
		slot_head_pref = (query.item[46])
		slot_belt_pref = (query.item[47])
		slot_r_store_pref = (query.item[48])
		slot_l_store_pref = (query.item[49])
		slot_back_pref = (query.item[50])
		slot_wear_id_pref = (query.item[51])
		slot_wear_pda_pref = (query.item[52])
		slot_l_hand_pref = (query.item[53])
		slot_r_hand_pref = (query.item[54])
		slot_s_store_pref = (query.item[55])
		implants = params2list(query.item[56])
		organs = params2list(query.item[57])
		internalorgans = params2list(query.item[58])
		
		mech = text2num(query.item[59])
	metadata		= sanitize_text(metadata, initial(metadata))
	real_name		= reject_bad_name(real_name)
	if(isnull(species)) species = "Human"
	if(isnull(language)) language = "None"
	if(!real_name) real_name = random_name(gender,species)
	gender			= sanitize_gender(gender)
	age				= sanitize_integer(age, AGE_MIN, AGE_MAX, initial(age))
	r_hair			= sanitize_integer(r_hair, 0, 255, initial(r_hair))
	g_hair			= sanitize_integer(g_hair, 0, 255, initial(g_hair))
	b_hair			= sanitize_integer(b_hair, 0, 255, initial(b_hair))
	r_facial		= sanitize_integer(r_facial, 0, 255, initial(r_facial))
	g_facial		= sanitize_integer(g_facial, 0, 255, initial(g_facial))
	b_facial		= sanitize_integer(b_facial, 0, 255, initial(b_facial))
	s_tone			= sanitize_integer(s_tone, -185, 34, initial(s_tone))
	r_skin			= sanitize_integer(r_skin, 0, 255, initial(r_skin))
	g_skin			= sanitize_integer(g_skin, 0, 255, initial(g_skin))
	b_skin			= sanitize_integer(b_skin, 0, 255, initial(b_skin))
	r_markings		= sanitize_integer(r_markings, 0, 255, initial(r_markings))
	g_markings		= sanitize_integer(g_markings, 0, 255, initial(g_markings))
	b_markings		= sanitize_integer(b_markings, 0, 255, initial(b_markings))
	r_headacc		= sanitize_integer(r_headacc, 0, 255, initial(r_headacc))
	g_headacc		= sanitize_integer(g_headacc, 0, 255, initial(g_headacc))
	b_headacc		= sanitize_integer(b_headacc, 0, 255, initial(b_headacc))
//	h_style			= sanitize_inlist(h_style, hair_styles_list, initial(h_style))
//	f_style			= sanitize_inlist(f_style, facial_hair_styles_list, initial(f_style))
//	m_style			= sanitize_inlist(m_style, marking_styles_list, initial(m_style))
//	ha_style		= sanitize_inlist(ha_style, head_accessory_styles_list, initial(ha_style))
	r_eyes			= sanitize_integer(r_eyes, 0, 255, initial(r_eyes))
	g_eyes			= sanitize_integer(g_eyes, 0, 255, initial(g_eyes))
	b_eyes			= sanitize_integer(b_eyes, 0, 255, initial(b_eyes))
//	underwear		= sanitize_text(underwear, initial(underwear))
//	undershirt		= sanitize_text(undershirt, initial(undershirt))
	b_type			= sanitize_text(b_type, initial(b_type))
	socks			= sanitize_text(socks, initial(socks))
//	body_accessory	= sanitize_text(body_accessory, initial(body_accessory))
	var/mob/living/carbon/human/character = new()
	var/datum/species/S = all_species[species]
	character.deleting = 1
	character.change_species(species, null, 0, 1) // Yell at me if this causes everything to melt
	character.dna.ready_dna(character)
	for(var/obj/item/organ/internal/iorgan in character.internal_organs)
		iorgan.remove(character, 1)
	for(var/obj/item/organ/organ in character.contents)
		if(organ in character.organs)
			qdel(organ)
	character.deleting = 0
	character.organs = list()
	character.internal_organs = list()
	character.organs_by_name = list()
	if(organs && !isemptylist(organs))
		for(var/x in organs)
			var/obj/item/organ/external/O = load_organ(C, x, nocontents)
			if(O)
				O.children = list()
				if(istype(O, /obj/item/organ/external/chest))
					character.organs_by_name["chest"] = O
				else if(istype(O, /obj/item/organ/external/groin))
					character.organs_by_name["groin"] = O
				else if(istype(O, /obj/item/organ/external/arm/right))
					character.organs_by_name["r_arm"] = O
				else if(istype(O, /obj/item/organ/external/arm))
					character.organs_by_name["l_arm"] = O
				else if(istype(O, /obj/item/organ/external/leg/right))
					character.organs_by_name["r_leg"] = O
				else if(istype(O, /obj/item/organ/external/leg))
					character.organs_by_name["l_leg"] = O
				else if(istype(O, /obj/item/organ/external/foot/right))
					character.organs_by_name["r_foot"] = O
				else if(istype(O, /obj/item/organ/external/foot))
					character.organs_by_name["l_foot"] = O
				else if(istype(O, /obj/item/organ/external/hand/right))
					character.organs_by_name["r_hand"] = O
				else if(istype(O, /obj/item/organ/external/hand))
					character.organs_by_name["l_hand"] = O
				else if(istype(O, /obj/item/organ/external/head))
					character.organs_by_name["head"] = O
				character.organs |= O
				O.loc = character
				O.owner = character
				if(!O.dna || (O.dna.unique_enzymes == character.dna.unique_enzymes))
					O.species = character.species
	if(internalorgans && !isemptylist(internalorgans))
		for(var/x in internalorgans)
			var/obj/item/organ/internal/O = load_internalorgan(C, x)
			if(O)
				O.insert(character)
	for(var/obj/item/organ/external/O in character.organs)
		if(istype(O, /obj/item/organ/external/chest)) continue
		var/obj/item/organ/external/Org = character.get_organ(O.parent_organ)
		if(Org)
			O.parent = Org
			Org.children |= O
	character.add_language(language)

	character.real_name = real_name
	character.dna.real_name = real_name
	character.name = character.real_name

	character.flavor_text = flavor_text
	character.med_record = med_record
	character.sec_record = sec_record
	character.gen_record = gen_record
	character.age = age
	character.b_type = b_type
	character.r_eyes = r_eyes
	character.g_eyes = g_eyes
	character.b_eyes = b_eyes
	//Head-specific
	var/obj/item/organ/external/head/H = character.get_organ("head")
	if(H)
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
	//	character.underwear = underwear
	//	character.undershirt = undershirt
	//	character.socks = socks

	var/obj/temp = load_item(C, slot_w_uniform_pref, nocontents)
	if(temp)
		character.equip_or_collect(temp, slot_w_uniform)
	temp = load_item(C, slot_wear_suit_pref, nocontents)
	if(temp)
		character.equip_or_collect(temp, slot_wear_suit)
	temp = load_item(C, slot_shoes_pref, nocontents)
	if(temp)
		character.equip_or_collect(temp, slot_shoes)
	temp = load_item(C, slot_gloves_pref, nocontents)
	if(temp)
		character.equip_or_collect(temp, slot_gloves)
	temp = load_item(C, slot_l_ear_pref, nocontents)
	if(temp)
		character.equip_or_collect(temp, slot_l_ear)
	temp = load_item(C, slot_r_ear_pref, nocontents)
	if(temp)
		character.equip_or_collect(temp, slot_r_ear)
	temp = load_item(C, slot_glasses_pref, nocontents)
	if(temp)
		character.equip_or_collect(temp, slot_glasses)
	temp = load_item(C, slot_wear_mask_pref, nocontents)
	if(temp)
		character.equip_or_collect(temp, slot_wear_mask)
	temp = load_item(C, slot_head_pref, nocontents)
	if(temp)
		character.equip_or_collect(temp, slot_head)
	temp = load_item(C, slot_belt_pref, nocontents)
	if(temp)
		character.equip_or_collect(temp, slot_belt)
	temp = load_item(C, slot_r_store_pref, nocontents)
	if(temp)
		character.equip_or_collect(temp, slot_r_store)
	temp = load_item(C, slot_l_store_pref, nocontents)
	if(temp)
		character.equip_or_collect(temp, slot_l_store)
	temp = load_item(C, slot_back_pref, nocontents)
	if(temp)
		character.equip_or_collect(temp, slot_back)
	temp = load_item(C, slot_wear_id_pref, nocontents)
	if(temp)
		character.equip_or_collect(temp, slot_wear_id)
	temp = load_item(C, slot_wear_pda_pref, nocontents)
	if(temp)
		character.equip_or_collect(temp, slot_wear_pda)
	temp = load_item(C, slot_l_hand_pref, nocontents)
	if(!nocontents)
		if(temp)
			character.equip_or_collect(temp, slot_l_hand)
		temp = load_item(C, slot_r_hand_pref, nocontents)
		if(temp)
			character.equip_or_collect(temp, slot_r_hand)
	temp = load_item(C, slot_s_store_pref, nocontents)
	if(temp)
		character.equip_or_collect(temp, slot_s_store)
	temp = load_item(C, underwear_num, nocontents)
	if(temp)
		character.equip_or_collect(temp, slot_underwear)
	temp = load_item(C, undershirt_num, nocontents)
	if(temp)
		character.equip_or_collect(temp, slot_undershirt)
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
	if(character.gender in list(PLURAL, NEUTER))
		if(isliving(src)) //Ghosts get neuter by default
			message_admins("[key_name_admin(character)] has spawned with their gender as plural or neuter. Please notify coders.")
			character.change_gender(MALE)

	
	character.change_gender(gender, 0, 1)
	character.prev_gender = "male"
	if(!nocontents)
		var/ind = 0
		if(!isemptylist(SE))
			var/list/form_SE = new /list(DNA_SE_LENGTH)
			for(var/x in SE)
				ind++
				form_SE[ind] = text2num(x)
			character.dna.SE = form_SE.Copy()
		if(!isemptylist(UI))
			var/list/form_UI = new/list(DNA_UI_LENGTH)
			ind = 0
			for(var/x in UI)
				ind++
				form_UI[ind] = text2num(x)
			character.dna.UI = form_UI.Copy()
		if(!isemptylist(SE_structure))
			ind = 0
			for(var/type in SE_structure)
				ind++
				if(type && type != "0")
					var/datum/dna/gene/gene = new type()
					character.dna.SE_structure[ind] = gene
				else
					character.dna.SE_structure[ind] = 0
	domutcheck(character)
	character.sync_organ_dna(assimilate=0)
	character.UpdateAppearance()

	// Do the initial caching of the player's body icons.
	character.force_update_limbs()
	character.update_eyes()
	character.regenerate_icons()
	if(mech)
		var/obj/mecha/holder = load_mech(C, mech, nocontents)
		holder.moved_inside(character, 1)

	return character

/datum/preferences/proc/save_body(client/C, var/mob/living/carbon/human/H, var/create_dna = 0) // SAVES HUMANOID BODIES
	SE = new /list(DNA_SE_LENGTH)
	UI = new /list(DNA_UI_LENGTH)
	SE_structure = new /list(DNA_SE_LENGTH)

	var/turf/location = get_turf(H.loc)
	var/mech = 0
	if(istype(H.loc, /obj/mecha))
		mech = save_mech(C, H.loc)
	current_status = "alive"		// FIX THIS!

	var/obj/item/organ/external/head/He = H.get_organ("head")
	if(He)
		r_hair = He.r_hair
		g_hair = He.g_hair
		b_hair = He.b_hair
		r_facial = He.r_facial
		g_facial = He.g_facial
		b_facial = He.b_facial
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
	species = H.species.name
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
	var/list/implants = list()
	check_inv(H)
	implants = brain
	var/list/internal_organs = list() //This will hold all the internal organs
	var/list/organs = list()
	for(var/obj/item/organ/internal/I in H.internal_organs)
		if(!I.dna || I.dna.unique_enzymes == H.dna.unique_enzymes)
			internal_organs |= save_internalorgan(C,I) 
		else
			internal_organs |= save_internalorgan(C,I,1)
	for(var/obj/item/organ/external/I in H.organs)
		if(!I.dna || I.dna.unique_enzymes == H.dna.unique_enzymes)
			organs |= save_organ(C,I)
		else
			organs |= save_organ(C,I,1)
	var/UE = H.dna.unique_enzymes
	SE = H.dna.SE
	UI = H.dna.UI
	var/ind = 0
	for(var/x in H.dna.SE_structure)
		ind++
		if(istype(x, /datum/dna/gene))
			var/datum/dna/gene/gene = x
			SE_structure[ind] = gene.type
		else
			SE_structure[ind] = 0
	var/SElist
	var/UIlist
	var/SEstructurelist
	var/implantlist
	var/organlist
	var/internalorganlist
	if(SE && !isemptylist(SE))
		SElist = list2params(SE)
	if(UI && !isemptylist(UI))
		UIlist = list2params(UI)
	if(SE_structure && !isemptylist(SE_structure))
		SEstructurelist = list2params(SE_structure)
	if(implants && !isemptylist(implants))
		implantlist = list2params(implants)
	if(internal_organs && !isemptylist(internal_organs))
		internalorganlist = list2params(internal_organs)
	if(organs && !isemptylist(organs))
		organlist = list2params(organs)
	var/DBQuery/query = dbcon.NewQuery({"
					INSERT INTO [format_table_name("bodies")] (real_name, gender,
											age, species, language,
											hair_red, hair_green, hair_blue,
											facial_red, facial_green, facial_blue,
											skin_tone, skin_red, skin_green, skin_blue,
											markings_red, markings_green, markings_blue,
											head_accessory_red, head_accessory_green, head_accessory_blue,
											hair_style_name, facial_style_name, marking_style_name, head_accessory_style_name,
											eyes_red, eyes_green, eyes_blue,
											underwear, undershirt, b_type, flavor_text,
											socks, body_accessory, UI, SE, SE_structure,
											slot_w_uniform, slot_wear_suit,
											slot_shoes, slot_gloves, slot_l_ear,
											slot_glasses, slot_wear_mask, slot_head,
											slot_belt, slot_r_store, slot_l_store,
											slot_back, slot_wear_id, slot_wear_pda, slot_l_hand,
											slot_r_hand, slot_s_store,
											implants, organs, internal_organs, mech, UE)

					VALUES
											('[sql_sanitize_text(real_name)]', '[gender]',
											'[age]', '[sql_sanitize_text(species)]', '[sql_sanitize_text(language)]',
											'[r_hair]', '[g_hair]', '[b_hair]',
											'[r_facial]', '[g_facial]', '[b_facial]',
											'[s_tone]', '[r_skin]', '[g_skin]', '[b_skin]',
											'[r_markings]', '[g_markings]', '[b_markings]',
											'[r_headacc]', '[g_headacc]', '[b_headacc]',
											'[sql_sanitize_text(h_style)]', '[sql_sanitize_text(f_style)]', '[sql_sanitize_text(m_style)]', '[sql_sanitize_text(ha_style)]',
											'[r_eyes]', '[g_eyes]', '[b_eyes]',
											'[slot_underwear_pref]', '[slot_undershirt_pref]', '[b_type]',
											'[sql_sanitize_text(html_encode(flavor_text))]',
											'[socks]', '[body_accessory]', '[UIlist]', '[SElist]', '[SEstructurelist]',
											'[slot_w_uniform_pref]','[slot_wear_suit_pref]',
											'[slot_shoes_pref]', '[slot_gloves_pref]', '[slot_l_ear_pref]',
											'[slot_glasses_pref]', '[slot_wear_mask_pref]', '[slot_head_pref]',
											'[slot_belt_pref]', '[slot_r_store_pref]', '[slot_l_store_pref]',
											'[slot_back_pref]', '[slot_wear_id_pref]', '[slot_wear_pda_pref]', '[slot_l_hand_pref]',
											'[slot_r_hand_pref]', '[slot_s_store_pref]',
											'[implantlist]', '[organlist]', '[internalorganlist]', '[mech]', '[UE]')
					"}
					)
	var/DBQuery/secondquery = dbcon.NewQuery({"
				SELECT LAST_INSERT_ID() FROM [format_table_name("bodies")]
				"}
				)

	if(!query.Execute())
		var/err = query.ErrorMsg()
		log_game("SQL ERROR during BODY SAVING : \[[err]\]\n")
		message_admins("SQL ERROR during BODY SAVING : \[[err]\]\n")
		return
	if(!secondquery.Execute())
		var/err = secondquery.ErrorMsg()
		log_game("SQL ERROR during BODY SAVING : \[[err]\]\n")
		message_admins("SQL ERROR during BODY SAVING : \[[err]\]\n")
		return
	while(secondquery.NextRow())
		var/id = secondquery.item[1]
		return text2num(id)

	return 0

/datum/preferences/proc/save_character(client/C)
	var/organlist
	var/rlimblist
	var/playertitlelist
	var/accountlist
	var/rankslist
	var/certlist
	var/SElist
	var/UIlist
	var/SEstructurelist
	if(account && !isemptylist(account))
		accountlist = list2params(account)
	if(organ_data &&!isemptylist(organ_data))
		organlist = list2params(organ_data)
	if(rlimb_data && !isemptylist(rlimb_data))
		rlimblist = list2params(rlimb_data)
	if(player_alt_titles && !isemptylist(player_alt_titles))
		playertitlelist = list2params(player_alt_titles)
	if(certs && !isemptylist(certs))
		certlist = list2params(certs)
	if(department_ranks && !isemptylist(department_ranks))
		rankslist = list2params(department_ranks)
	if(SE && !isemptylist(SE))
		SElist = list2params(SE)
	if(UI && !isemptylist(UI))
		UIlist = list2params(UI)
	if(SE_structure && !isemptylist(SE_structure))
		SEstructurelist = list2params(SE_structure)
	var/DBQuery/firstquery = dbcon.NewQuery("SELECT slot FROM [format_table_name("characters")] WHERE ckey='[C.ckey]' ORDER BY slot")
	firstquery.Execute()
	while(firstquery.NextRow())
		if(text2num(firstquery.item[1]) == default_slot)
			var/DBQuery/query = dbcon.NewQuery({"UPDATE [format_table_name("characters")] SET OOC_Notes='[sql_sanitize_text(metadata)]',
												real_name='[sql_sanitize_text(real_name)]',
												name_is_always_random='[be_random_name]',
												gender='[gender]',
												age='[age]',
												species='[sql_sanitize_text(species)]',
												language='[sql_sanitize_text(language)]',
												hair_red='[r_hair]',
												hair_green='[g_hair]',
												hair_blue='[b_hair]',
												facial_red='[r_facial]',
												facial_green='[g_facial]',
												facial_blue='[b_facial]',
												skin_tone='[s_tone]',
												skin_red='[r_skin]',
												skin_green='[g_skin]',
												skin_blue='[b_skin]',
												markings_red='[r_markings]',
												markings_green='[g_markings]',
												markings_blue='[b_markings]',
												head_accessory_red='[r_headacc]',
												head_accessory_green='[g_headacc]',
												head_accessory_blue='[b_headacc]',
												hair_style_name='[sql_sanitize_text(h_style)]',
												facial_style_name='[sql_sanitize_text(f_style)]',
												marking_style_name='[sql_sanitize_text(m_style)]',
												head_accessory_style_name='[sql_sanitize_text(ha_style)]',
												eyes_red='[r_eyes]',
												eyes_green='[g_eyes]',
												eyes_blue='[b_eyes]',
												underwear='[underwear]',
												undershirt='[undershirt]',
												backbag='[backbag]',
												b_type='[b_type]',
												alternate_option='[alternate_option]',
												job_support_high='[job_support_high]',
												job_support_med='[job_support_med]',
												job_support_low='[job_support_low]',
												job_medsci_high='[job_medsci_high]',
												job_medsci_med='[job_medsci_med]',
												job_medsci_low='[job_medsci_low]',
												job_engsec_high='[job_engsec_high]',
												job_engsec_med='[job_engsec_med]',
												job_engsec_low='[job_engsec_low]',
												job_karma_high='[job_karma_high]',
												job_karma_med='[job_karma_med]',
												job_karma_low='[job_karma_low]',
												flavor_text='[sql_sanitize_text(html_decode(flavor_text))]',
												med_record='[sql_sanitize_text(html_decode(med_record))]',
												sec_record='[sql_sanitize_text(html_decode(sec_record))]',
												gen_record='[sql_sanitize_text(html_decode(gen_record))]',
												player_alt_titles='[playertitlelist]',
												disabilities='[disabilities]',
												organ_data='[organlist]',
												rlimb_data='[rlimblist]',
												nanotrasen_relation='[nanotrasen_relation]',
												speciesprefs='[speciesprefs]',
												socks='[socks]',
												body_accessory='[body_accessory]',
												current_status='[current_status]',
												energy_creds='[energy_creds]',
												account='[accountlist]',
												certifications='[certlist]',
												primary_cert='[sql_sanitize_text(primary_cert)]',
												cert_title='[sql_sanitize_text(cert_title)]',
												department_ranks='[rankslist]',
												faction='[faction]',
												UI='[UIlist]',
												SE='[SElist]',
												SE_structure='[SEstructurelist]'
												WHERE ckey='[C.ckey]'
												AND slot='[default_slot]'"}
												)

			if(!query.Execute())
				var/err = query.ErrorMsg()
				log_game("SQL ERROR during character slot saving. Error : \[[err]\]\n")
				message_admins("SQL ERROR during character slot saving. Error : \[[err]\]\n")
				return
			return 1

	var/DBQuery/query = dbcon.NewQuery({"
					INSERT INTO [format_table_name("characters")] (ckey, slot, OOC_Notes, real_name, name_is_always_random, gender,
											age, species, language,
											hair_red, hair_green, hair_blue,
											facial_red, facial_green, facial_blue,
											skin_tone, skin_red, skin_green, skin_blue,
											markings_red, markings_green, markings_blue,
											head_accessory_red, head_accessory_green, head_accessory_blue,
											hair_style_name, facial_style_name, marking_style_name, head_accessory_style_name,
											eyes_red, eyes_green, eyes_blue,
											underwear, undershirt,
											backbag, b_type, alternate_option,
											job_support_high, job_support_med, job_support_low,
											job_medsci_high, job_medsci_med, job_medsci_low,
											job_engsec_high, job_engsec_med, job_engsec_low,
											job_karma_high, job_karma_med, job_karma_low,
											flavor_text, med_record, sec_record, gen_record,
											player_alt_titles,
											disabilities, organ_data, rlimb_data, nanotrasen_relation, speciesprefs,
											socks, body_accessory, current_status, energy_creds, account, certifications, primary_cert, cert_title, department_ranks, faction, UI, SE, SE_structure)

					VALUES
											('[C.ckey]', '[default_slot]', '[sql_sanitize_text(metadata)]', '[sql_sanitize_text(real_name)]', '[be_random_name]','[gender]',
											'[age]', '[sql_sanitize_text(species)]', '[sql_sanitize_text(language)]',
											'[r_hair]', '[g_hair]', '[b_hair]',
											'[r_facial]', '[g_facial]', '[b_facial]',
											'[s_tone]', '[r_skin]', '[g_skin]', '[b_skin]',
											'[r_markings]', '[g_markings]', '[b_markings]',
											'[r_headacc]', '[g_headacc]', '[b_headacc]',
											'[sql_sanitize_text(h_style)]', '[sql_sanitize_text(f_style)]', '[sql_sanitize_text(m_style)]', '[sql_sanitize_text(ha_style)]',
											'[r_eyes]', '[g_eyes]', '[b_eyes]',
											'[underwear]', '[undershirt]',
											'[backbag]', '[b_type]', '[alternate_option]',
											'[job_support_high]', '[job_support_med]', '[job_support_low]',
											'[job_medsci_high]', '[job_medsci_med]', '[job_medsci_low]',
											'[job_engsec_high]', '[job_engsec_med]', '[job_engsec_low]',
											'[job_karma_high]', '[job_karma_med]', '[job_karma_low]',
											'[sql_sanitize_text(html_encode(flavor_text))]', '[sql_sanitize_text(html_encode(med_record))]', '[sql_sanitize_text(html_encode(sec_record))]', '[sql_sanitize_text(html_encode(gen_record))]',
											'[playertitlelist]',
											'[disabilities]', '[organlist]', '[rlimblist]', '[nanotrasen_relation]', '[speciesprefs]',
											'[socks]', '[body_accessory]', '[current_status]', '[energy_creds]', '[accountlist]', '[certlist]', '[sql_sanitize_text(primary_cert)]', '[sql_sanitize_text(cert_title)]', '[rankslist]', '[faction]',
											'[UIlist]', '[SElist]', '[SEstructurelist]')

"}
)

	if(!query.Execute())
		var/err = query.ErrorMsg()
		log_game("SQL ERROR during character slot saving. Error : \[[err]\]\n")
		message_admins("SQL ERROR during character slot saving. Error : \[[err]\]\n")
		return
	return 1



/*

/datum/preferences/proc/random_character(client/C)
	var/DBQuery/query = dbcon.NewQuery("SELECT slot FROM [format_table_name("characters")] WHERE ckey='[C.ckey]' ORDER BY slot")

	while(query.NextRow())
	var/list/saves = list()
	for(var/i=1, i<=MAX_SAVE_SLOTS, i++)
		if(i==text2num(query.item[1]))
			saves += i

	if(!saves.len)
		load_character(C)
		return 0
	load_character(C,pick(saves))
	return 1*/

/datum/preferences/proc/SetChangelog(client/C,hash)
	lastchangelog=hash
	winset(C, "rpane.changelog", "background-color=none;font-style=")
	var/DBQuery/query = dbcon.NewQuery("UPDATE [format_table_name("player")] SET lastchangelog='[lastchangelog]' WHERE ckey='[C.ckey]'")
	if(!query.Execute())
		var/err = query.ErrorMsg()
		log_game("SQL ERROR during lastchangelog updating. Error : \[[err]\]\n")
		message_admins("SQL ERROR during lastchangelog updating. Error : \[[err]\]\n")
		to_chat(C, "Couldn't update your last seen changelog, please try again later.")
		return
	return 1
/proc/ParamExplode(text,sep, var/length = 0)
	var/list/l[length]
	var/pos = findtext( text, sep )
	var/ind = 0
	while( pos )
		ind += 1
		l += "**unique**"
		if (copytext( text, 1, pos ) == "0" || text2num(copytext( text, 1, pos )))
			l[ind] = text2num(copytext( text, 1, pos ))
		else
			l[ind] = copytext( text, 1, pos )
		text = copytext( text, pos+1 )
		pos = findtext( text, sep )
	ind += 1
	if(text == "0" || text2num(text))
		l[ind] = text2num(text)
	else
		l[ind] = text
	return l