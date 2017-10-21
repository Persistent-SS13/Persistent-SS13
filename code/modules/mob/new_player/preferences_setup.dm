
//these will handle the stuff
proc
	get_input(wait = 100 as num,mob/U,Message,Title,Default,Type,list/List)
		var/prompts/input/Input = new
		var/Option
		if(wait) spawn(wait) if(!Option) del Input
		Option = Input.option(U,Message,Title,Default,Type,List)
		return Option
	get_alert(wait = 100 as num,mob/U,Message,Title,Button1,Button2,Button3)
		var/prompts/alert/Alert = new
		var/Option
		if(wait) spawn(wait) if(!Option) del Alert
		Option = Alert.option(U,Message,Title,Button1,Button2,Button3)
		return Option
prompts
	input
		proc/option(mob/U,Message="",Title="",Default="",Type,list/List)
			switch(Type)
				if("text") return input(U,Message,Title,Default) as text
				if("text|null") return input(U,Message,Title,Default) as text|null
				if("password") return input(U,Message,Title,Default) as password
				if("password|null") return input(U,Message,Title,Default) as password|null
				if("command_text") return input(U,Message,Title,Default) as command_text
				if("command_text|null") return input(U,Message,Title,Default) as command_text|null
				if("icon") return input(U,Message,Title,Default) as icon
				if("icon|null") return input(U,Message,Title,Default) as icon|null
				if("sound") return input(U,Message,Title,Default) as sound
				if("sound|null") return input(U,Message,Title,Default) as sound|null
				if("num") return input(U,Message,Title,Default) as num
				if("num|null") return input(U,Message,Title,Default) as num|null
				if("message") return input(U,Message,Title,Default) as message
				if("message|null") return input(U,Message,Title,Default) as message|null
				if("mob") return input(U,Message,Title,Default) as mob in List
				if("obj") return input(U,Message,Title,Default) as obj in List
				if("turf") return input(U,Message,Title,Default) as turf in List
				if("area") return input(U,Message,Title,Default) as area in List
				if("color") return input(U,Message , Title, Default) as color|null
				else return input(U,Message,Title,Default) in List
	alert
		proc/option(mob/U,Message,Title,Button1="Ok",Button2,Button3)
			return alert(U,Message,Title,Button1,Button2,Button3)
//to use them
mob/verb
    AlertWindow()
        var/alert = get_alert(20,usr,"2 sec for user to respond","title","Yes","No")
        if(alert=="Yes")
            world<<"yay it's yes"
    InputWindow()
        var/input = get_input(20,usr,"2 sec for user to type name","title","default text","text")
        world<<input


/datum/preferences
	//The mob should have a gender you want before running this proc. Will run fine without H
/datum/preferences/proc/random_character(gender_override)
	if(gender_override)
		gender = gender_override
	else
		gender = pick(MALE, FEMALE)
	underwear = "Nude"
	undershirt = "Nude"
	
	if(species in list("Human", "Drask"))
		s_tone = random_skin_tone()
	h_style = random_hair_style(gender, species)
	f_style = random_facial_hair_style(gender, species)
	if(species == "Human" || species == "Unathi" || species == "Tajaran" || species == "Skrell" || species == "Machine" || species == "Vulpkanin")
		randomize_hair_color("hair")
	randomize_hair_color("facial")
	randomize_eyes_color()
	if(species == "Unathi" || species == "Tajaran" || species == "Skrell" || species == "Vulpkanin")
		randomize_skin_color()
	age = rand(21,45)

	if(gender == MALE)
		var/obj/ob = pick(male_underwear)
		preview_model.underwear = ob
		underwear = ob.name
	else
		var/obj/ob = pick(female_underwear)
		preview_model.underwear = ob
		underwear = ob.name
	if(gender == MALE)
		var/obj/shirt = pick(undershirts)
		preview_model.undershirt = shirt
		undershirt = shirt.name
	else
		var/obj/shirt = pick(female_undershirts)
		preview_model.undershirt = shirt
		undershirt = shirt.name
	var/obj/pack = pick(backbaglist)
	preview_model.back = pack
	backbag = pack.name
	var/obj/suit = pick(underlist)
	preview_model.w_uniform = suit
	jumpsuit = suit.name
	

/datum/preferences/proc/randomize_hair_color(var/target = "hair")
	if(prob (75) && target == "facial") // Chance to inherit hair color
		r_facial = r_hair
		g_facial = g_hair
		b_facial = b_hair
		return

	var/red
	var/green
	var/blue

	var/col = pick ("blonde", "black", "chestnut", "copper", "brown", "wheat", "old", "punk")
	switch(col)
		if("blonde")
			red = 255
			green = 255
			blue = 0
		if("black")
			red = 0
			green = 0
			blue = 0
		if("chestnut")
			red = 153
			green = 102
			blue = 51
		if("copper")
			red = 255
			green = 153
			blue = 0
		if("brown")
			red = 102
			green = 51
			blue = 0
		if("wheat")
			red = 255
			green = 255
			blue = 153
		if("old")
			red = rand (100, 255)
			green = red
			blue = red
		if("punk")
			red = rand (0, 255)
			green = rand (0, 255)
			blue = rand (0, 255)

	red = max(min(red + rand (-25, 25), 255), 0)
	green = max(min(green + rand (-25, 25), 255), 0)
	blue = max(min(blue + rand (-25, 25), 255), 0)

	switch(target)
		if("hair")
			r_hair = red
			g_hair = green
			b_hair = blue
		if("facial")
			r_facial = red
			g_facial = green
			b_facial = blue

/datum/preferences/proc/randomize_eyes_color()
	var/red
	var/green
	var/blue

	var/col = pick ("black", "grey", "brown", "chestnut", "blue", "lightblue", "green", "albino")
	switch(col)
		if("black")
			red = 0
			green = 0
			blue = 0
		if("grey")
			red = rand (100, 200)
			green = red
			blue = red
		if("brown")
			red = 102
			green = 51
			blue = 0
		if("chestnut")
			red = 153
			green = 102
			blue = 0
		if("blue")
			red = 51
			green = 102
			blue = 204
		if("lightblue")
			red = 102
			green = 204
			blue = 255
		if("green")
			red = 0
			green = 102
			blue = 0
		if("albino")
			red = rand (200, 255)
			green = rand (0, 150)
			blue = rand (0, 150)

	red = max(min(red + rand (-25, 25), 255), 0)
	green = max(min(green + rand (-25, 25), 255), 0)
	blue = max(min(blue + rand (-25, 25), 255), 0)

	r_eyes = red
	g_eyes = green
	b_eyes = blue

/datum/preferences/proc/randomize_skin_color()
	var/red
	var/green
	var/blue

	var/col = pick ("black", "grey", "brown", "chestnut", "blue", "lightblue", "green", "albino")
	switch(col)
		if("black")
			red = 0
			green = 0
			blue = 0
		if("grey")
			red = rand (100, 200)
			green = red
			blue = red
		if("brown")
			red = 102
			green = 51
			blue = 0
		if("chestnut")
			red = 153
			green = 102
			blue = 0
		if("blue")
			red = 51
			green = 102
			blue = 204
		if("lightblue")
			red = 102
			green = 204
			blue = 255
		if("green")
			red = 0
			green = 102
			blue = 0
		if("albino")
			red = rand (200, 255)
			green = rand (0, 150)
			blue = rand (0, 150)

	red = max(min(red + rand (-25, 25), 255), 0)
	green = max(min(green + rand (-25, 25), 255), 0)
	blue = max(min(blue + rand (-25, 25), 255), 0)

	r_skin = red
	g_skin = green
	b_skin = blue


/datum/preferences/proc/create_spawnicons(client/C)		//seriously. This is horrendous.
	preview_icons = new/list(max_save_slots)
	minds_list = new/list(max_save_slots)
	slot = 0
	for(var/i=1, i<=max_save_slots, i++)
		slot++
		var/mob/H = load_mind(C, 0, 0, 1, 1)
		if(!H)
			continue
		var/mobmind = H.mind
		if(H.loc)
			H = H.loc
		var/icon/flaticon = getFlatIcon(H)
		var/icon/flat = icon('icons/effects/effects.dmi', "icon_state"="nothing") 
		if(gender == "female" && istype(H, /mob/living/carbon/human))
			flaticon.Scale(30,32)
			flat.Blend(flaticon, ICON_OVERLAY, 2)
			flaticon = flat
		preview_icons[i] = flaticon
		minds_list[i] = mobmind
	return preview_icons
/datum/preferences/proc/create_single_spawnicon(client/C, var/_slot)
	if(!preview_icons || !preview_icons.len || !minds_list || !minds_list.len)
		create_spawnicons(C)
		return
	slot = _slot
	var/atom/movable/H = load_mind(C, 0, 0, 1, 1)
	var/icon/flaticon = getFlatIcon(H)
	var/icon/flat = icon('icons/effects/effects.dmi', "icon_state"="nothing") 
	if(gender == "female" && istype(H, /mob/living/carbon/human))
		flaticon.Scale(30,32)
		flat.Blend(flaticon, ICON_OVERLAY, 2)
		flaticon = flat
	preview_icons[_slot] = flaticon
	if(istype(H, /mob))
		var/mob/mobbie = H
		minds_list[_slot] = mobbie.mind
	else
		var/obj/obbie = H
		message_admins("obbie found!")
		for(var/mob/mobbie in obbie.contents)
			message_admins("")
			minds_list[_slot] = mobbie.mind
			break
	return

/datum/preferences/proc/update_preview_icon_new(var/full_reset = 0)		//seriously. This is horrendous.
	qdel(preview_icon_front)
	qdel(preview_icon_side)
	qdel(preview_icon)
	if(!preview_model || full_reset)
		if(!preview_model)
			ambition = 0
			stats_left = 4
			stat_Grit = 0
			stat_Fortitude = 0
			stat_Reflex = 0
			stat_Creativity = 0
			stat_Focus = 0
			nameChose = 0
			create_menu = 1
			real_name = ""
			preview_model = new()
			preview_model.shoes = new /obj/item/clothing/shoes/black()
			random_character()
		body_accessory = "None"
		var/datum/species/S = all_species[species]
		preview_model.deleting = 1
		preview_model.change_species(species, null, 0, 1)
		preview_model.dna.ready_dna(preview_model)
		preview_model.deleting = 0
		preview_model.b_type = b_type
		preview_model.r_eyes = r_eyes
		preview_model.g_eyes = g_eyes
		preview_model.b_eyes = b_eyes
		//Head-specific
		var/obj/item/organ/external/head/H = preview_model.get_organ("head")
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

		preview_model.r_skin = r_skin
		preview_model.g_skin = g_skin
		preview_model.b_skin = b_skin

		preview_model.s_tone = s_tone

		H.r_headacc = r_headacc
		H.g_headacc = g_headacc
		H.b_headacc = b_headacc
		H.ha_style = ha_style
		preview_model.r_markings = r_markings
		preview_model.g_markings = g_markings
		preview_model.b_markings = b_markings
		preview_model.m_style = m_style

		if(body_accessory)
			preview_model.body_accessory = body_accessory_by_name["[body_accessory]"]
		if(preview_model.gender in list(PLURAL, NEUTER))
			if(isliving(src)) //Ghosts get neuter by default
				message_admins("preview_model has spawned with their gender as plural or neuter. Please notify coders.")
				preview_model.change_gender(MALE)
		preview_model.change_gender(gender, 0, 1)
		preview_model.prev_gender = "male"
	if(show_under)
		var/obj/obb = preview_model.w_uniform
		preview_model.w_uniform = null
		preview_model.regenerate_icons()
		preview_model.w_uniform = obb
		show_under = 0
	else
		preview_model.regenerate_icons()
	var/icon/flatsouth = getFlatIcon(preview_model, SOUTH)
	var/icon/flatwest = getFlatIcon(preview_model, WEST)
	if(gender == "female")
		var/icon/flat1 = icon('icons/effects/effects.dmi', "icon_state"="nothing")
		var/icon/flat2 = icon('icons/effects/effects.dmi', "icon_state"="nothing")
		flatsouth.Scale(30,32)
		flatwest.Scale(30,32)
		flat1.Blend(flatsouth, ICON_OVERLAY, 2)
		flat2.Blend(flatwest, ICON_OVERLAY, 2)
		flatsouth = flat1
		flatwest = flat2
	preview_icon_front = new(flatsouth)
	preview_icon_side = new(flatwest)

