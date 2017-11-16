
/**********************Ore box**************************/

/obj/structure/ore_box
	icon = 'icons/obj/mining.dmi'
	icon_state = "orebox"
	name = "solid ore box"
	desc = "A heavy metal box, which can be filled with solid ore types."
	density = 1
	pressure_resistance = 5*ONE_ATMOSPHERE
	var/conglo_amount = 0
	var/orichilum_amount = 0
	var/maximum = 10
	w_class = 4
	var/health = 3
	
/obj/structure/ore_box/Move()
	..()
	if(mineController && get_area(src) == mineController.target_area)
		mineController.handle_pull(loc)
	
/obj/structure/ore_box/proc/add_ore(var/t, var/amount = 1) // if t == 1 conglo will go up, if t == 2 oricihlum will go up instead
	if(!t)
		return
	var/total = conglo_amount+orichilum_amount
	if((total + amount) > maximum)
		return 0
	else
		switch(t)
			if(1)
				conglo_amount += amount
			if(2)
				orichilum_amount += amount
	if((total + amount) >= maximum)
		icon_state = "[initial(icon_state)]b"
	else
		icon_state = initial(icon_state)
	return 1
/obj/structure/ore_box/attackby(obj/item/weapon/W as obj, mob/user as mob, params)

	if(istype(W, /obj/item/weapon/shovel))
		var/list/possible = list()
		if(conglo_amount) possible += "conglo"
		if(orichilum_amount) possible += "orichilum"
		if(!possible.len) return
		var/piletype = /obj/structure/orepile
		var/chose = pick(possible)
		var/obj/structure/orepile/pile
		user.visible_message("[user] begins shoveling [chose] out of the box...")
		switch(do_after_stat(user, delay = 100, needhand = 1, target = src, progress = 1, action_name = "shovel the [chose]", 
				auto_emote = 1, stat_used = 1, minimum = 0, maximum = 8, maxed_delay = 40, progressive_failure = 0, 
				minimum_probability = 70, help_able = 0, help_ratio = 1, stamina_use = 1, stamina_used = 15, 
				progressive_stamina = 1, attempt_cost = 5, stamina_use_fail = 0.5, sound_file = 'sound/effects/tong_pickup.ogg'))
			if(1)
				if(chose == "conglo")
					piletype = /obj/structure/orepile/conglo
					conglo_amount--
				else if(chose == "orichilum")
					piletype = /obj/structure/orepile/orichilum
					orichilum_amount--
				for(var/obj/structure/orepile/orep in range(1, loc))
					pile = orep
					break
				if(!pile)
					var/d = pick(cardinal)
					var/turf/T = get_step(loc, d)
					pile = new piletype(T)
				else
					pile.amount += 1
					pile.update()
		return
	
/obj/structure/ore_box/attack_animal(var/mob/living/simple_animal/M)//No more buckling hostile mobs to chairs to render them immobile forever
	if(M.environment_smash)
		new /obj/item/stack/sheet/metal(src.loc)
		qdel(src)
	else
		health--
		healthcheck()
		return

// test health for brokenness
/obj/structure/ore_box/proc/healthcheck()
	if(health <= 0)
		var/placed = 0
		if(conglo_amount)
			placed = 1
			var/obj/structure/orepile/conglo/conglo = new(loc)
			conglo.amount = conglo_amount
			conglo.update()
		if(orichilum_amount)
			var/obj/structure/orepile/orichilum/orichilum
			if(placed)
				var/d = pick(cardinal)
				var/turf/T = get_step(loc, d)
				orichilum = new(T)
			else
				orichilum = new(loc)
			orichilum.amount = orichilum_amount
			orichilum.update()
		playsound(src.loc, 'sound/effects/meteorimpact.ogg', 100, 1)
		new /obj/item/stack/sheet/metal(src.loc)
		qdel(src)
	return
/obj/structure/ore_box/proc/update()
	var/total = conglo_amount+orichilum_amount
	if(total >= maximum)
		icon_state = "[initial(icon_state)]b"
	else
		icon_state = initial(icon_state)
	return 1
/obj/structure/ore_box/get_weight()
	var/conglo_weight = (conglo_amount * 1)
	var/orichilum_weight = (orichilum_amount * 1)
	return (w_class + conglo_weight + orichilum_weight)
		
/obj/structure/ore_box/attack_hand(mob/user as mob)
	examine(user)
	
/obj/structure/ore_box/ex_act(severity, target)
	if(prob(100 / severity) && severity < 3)
		for(var/obj/x in contents)
			qdel(x)
		qdel(src) //nothing but ores can get inside unless its a bug and ores just return nothing on ex_act, not point in calling it on them

/obj/structure/ore_box/examine(mob/user)
	..()
	if(conglo_amount)
		to_chat(user, "There is [conglo_amount] units of conglo ore inside.")
	if(orichilum_amount)
		to_chat(user, "There is [orichilum_amount] units of conglo ore inside.")
	
/**********************LIQUID PRESSURE TANK**************************/

/obj/structure/pressure_tank
	icon = 'icons/obj/mining.dmi'
	icon_state = "pressure-tank"
	name = "liquid multi-pressure tank"
	desc = "An advanced system of pressure tanks meant to prevent raw tantiline from reacting. For safety purposes, it can only be loaded and unloaded by mining equipment. Avoid breaching container at all costs."
	density = 1
	pressure_resistance = 5*ONE_ATMOSPHERE
	var/tantiline_amount = 0
	var/maximum = 10
	w_class = 4
	var/health = 3
	
/obj/structure/pressure_tank/Move()
	..()
	if(mineController && get_area(src) == mineController.target_area)
		mineController.handle_pull(loc)
	
/obj/structure/pressure_tank/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	..()

/obj/structure/pressure_tank/ex_act(severity, target)
	if(prob(100 / severity) && severity < 3)
		for(var/obj/x in contents)
			qdel(x)
		qdel(src) // this has to be dealt with.

/obj/structure/pressure_tank/proc/add_ore(var/t = 1, var/amount = 1)
	var/total = tantiline_amount
	if((total + amount) > maximum)
		return 0
	else
		switch(t)
			if(1)
				tantiline_amount += amount
	if((total + amount) >= maximum)
		icon_state = "[initial(icon_state)]b"
	else
		icon_state = initial(icon_state)
	return 1
/obj/structure/pressure_tank/examine(mob/user)
	..()
	if(tantiline_amount)
		to_chat(user, "There is [tantiline_amount] units of tantiline inside.")

/obj/structure/pressure_tank/get_weight()
	var/tantiline_weight = (tantiline_amount * 1)
	return (w_class + tantiline_weight)
	
/obj/structure/pressure_tank/attack_animal(var/mob/living/simple_animal/M)//No more buckling hostile mobs to chairs to render them immobile forever
	if(M.environment_smash)
		new /obj/item/stack/sheet/metal(src.loc)
		qdel(src)
	else
		health--
		healthcheck()
		return

// test health for brokenness
/obj/structure/pressure_tank/proc/healthcheck()
	if(health <= 0)
		if(tantiline_amount)
			var/obj/structure/puddle/tantiline/puddle = new(loc)
			puddle.amount = tantiline_amount
			puddle.update()
		playsound(src.loc, 'sound/effects/meteorimpact.ogg', 100, 1)
		new /obj/item/stack/sheet/metal(src.loc)
		qdel(src)
	return
/**********************GAS CANNISTER**************************/		

/obj/structure/plasma_canister
	icon = 'icons/obj/mining.dmi'
	icon_state = "plasma-canister"
	name = "plasma-gas canister"
	desc = "A canister with a heavy suction seal meant to be loaded with gas particles by mining equipment without spilling even a few molecules into the air. Avoid breaching canister at all costs."
	density = 1
	pressure_resistance = 5*ONE_ATMOSPHERE
	var/plasma_amount = 0
	var/maximum = 10
	w_class = 4
	var/health = 3

	
/obj/structure/plasma_canister/Move()
	..()
	if(mineController && get_area(src) == mineController.target_area)
		mineController.handle_pull(loc)
	
/obj/structure/plasma_canister/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	..()

/obj/structure/plasma_canister/ex_act(severity, target)
	if(prob(100 / severity) && severity < 3)
		for(var/obj/x in contents)
			qdel(x)
		qdel(src) // this has to be dealt with.
/obj/structure/plasma_canister/proc/add_ore(var/t = 1, var/amount = 1)
	var/total = plasma_amount
	if((total + amount) > maximum)
		return 0
	else
		switch(t)
			if(1)
				plasma_amount += amount
	if((total + amount) >= maximum)
		icon_state = "[initial(icon_state)]b"
	else
		icon_state = initial(icon_state)
	return 1
/obj/structure/plasma_canister/examine(mob/user)
	..()
	if(plasma_amount)
		to_chat(user, "There is [plasma_amount] units of plasma gas inside.")
	
/obj/structure/plasma_canister/get_weight()
	var/plasma_weight = (plasma_amount * 1)
	return (w_class + plasma_weight)
	
/obj/structure/plasma_canister/attack_animal(var/mob/living/simple_animal/M)//No more buckling hostile mobs to chairs to render them immobile forever
	if(M.environment_smash)
		new /obj/item/stack/sheet/metal(src.loc)
		qdel(src)
	else
		health--
		healthcheck()
		return

// test health for brokenness
/obj/structure/plasma_canister/proc/healthcheck()
	if(health <= 0)
		if(plasma_amount)
			if(istype(loc, /turf/simulated))
				var/turf/simulated/T = loc
				T.atmos_spawn_air(SPAWN_TOXINS, 50*plasma_amount)
		playsound(src.loc, 'sound/effects/meteorimpact.ogg', 100, 1)
		new /obj/item/stack/sheet/metal(src.loc)
		qdel(src)
	return