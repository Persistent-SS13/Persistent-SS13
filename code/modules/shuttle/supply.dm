#define ORDER_SCREEN_WIDTH 625 //width of order computer interaction window
#define ORDER_SCREEN_HEIGHT 580 //height of order computer interaction window
#define SUPPLY_SCREEN_WIDTH 625 //width of supply computer interaction window
#define SUPPLY_SCREEN_HEIGHT 620 //height of supply computer interaction window

/obj/item/weapon/paper/manifest
	name = "supply manifest"
	var/erroneous = 0
	var/points = 0
	var/ordernumber = 0

/obj/docking_port/mobile/supply
	name = "supply shuttle"
	id = "supply"
	callTime = 1200

	dir = 8
	travelDir = 90
	width = 12
	dwidth = 5
	height = 7
	roundstart_move = "supply_away"

/obj/docking_port/mobile/supply/register()
	if(!..())
		return 0
	shuttle_master.supply = src
	return 1

/obj/docking_port/mobile/supply/canMove()
	if(is_station_level(z))
		return forbidden_atoms_check(areaInstance)
	return ..()

/obj/docking_port/mobile/supply/request(obj/docking_port/stationary/S)
	if(mode != SHUTTLE_IDLE)
		return 2
	return ..()

/obj/docking_port/mobile/supply/dock()
	. = ..()
	if(.)	return .

	buy()
	sell()

/obj/docking_port/mobile/supply/proc/buy()
	if(!is_station_level(z))		//we only buy when we are -at- the station
		return 1

	if(!shuttle_master.shoppinglist.len)
		return 2

	var/list/emptyTurfs = list()
	for(var/turf/simulated/T in areaInstance)
		if(T.density)
			continue

		var/contcount
		for(var/atom/A in T.contents)
			if(istype(A,/atom/movable/lighting_overlay))
				continue
			if(istype(A,/obj/machinery/light))
				continue //hacky but whatever, shuttles need three spots each for this shit
			if(!A.simulated)
				continue
			contcount++

		if(contcount)
			continue

		emptyTurfs += T

	for(var/datum/supply_order/SO in shuttle_master.shoppinglist)
		if(!SO.object)
			throw EXCEPTION("Supply Order [SO] has no object associated with it.")
			continue

		var/turf/T = pick_n_take(emptyTurfs)		//turf we will place it in
		if(!T)
			shuttle_master.shoppinglist.Cut(1, shuttle_master.shoppinglist.Find(SO))
			return

		var/errors = 0
	//	if(prob(5))
	//		errors |= MANIFEST_ERROR_COUNT
	//	if(prob(5))
	//		errors |= MANIFEST_ERROR_NAME
	//	if(prob(5))
	//		errors |= MANIFEST_ERROR_ITEM
		SO.createObject(T, errors)

	shuttle_master.shoppinglist.Cut()

/obj/docking_port/mobile/supply/proc/sell()
	if(z != level_name_to_num(CENTCOMM))		//we only sell when we are -at- centcomm
		return 1

	var/plasma_count = 0
	var/intel_count = 0
	var/crate_count = 0

	var/msg = ""
	var/pointsEarned

	for(var/atom/movable/MA in areaInstance)
		if(MA.anchored)	continue
		shuttle_master.sold_atoms += " [MA.name]"

		// Must be in a crate (or a critter crate)!
		if(istype(MA,/obj/structure/closet/crate) || istype(MA,/obj/structure/closet/critter))
			shuttle_master.sold_atoms += ":"
			if(!MA.contents.len)
				shuttle_master.sold_atoms += " (empty)"
			++crate_count

			var/find_slip = 1
			for(var/thing in MA)
				// Sell manifests
				shuttle_master.sold_atoms += " [thing:name]"
				if(find_slip && istype(thing,/obj/item/weapon/paper/manifest))
					var/obj/item/weapon/paper/manifest/slip = thing
					// TODO: Check for a signature, too.
					if(slip.stamped && slip.stamped.len) //yes, the clown stamp will work. clown is the highest authority on the station, it makes sense
						// Did they mark it as erroneous?
						var/denied = 0
						for(var/i=1,i<=slip.stamped.len,i++)
							if(slip.stamped[i] == /obj/item/weapon/stamp/denied)
								denied = 1
						if(slip.erroneous && denied) // Caught a mistake by Centcom (IDEA: maybe Centcom rarely gets offended by this)
							pointsEarned = slip.points - shuttle_master.points_per_crate
							shuttle_master.points += pointsEarned // For now, give a full refund for paying attention (minus the crate cost)
							msg += "<span class='good'>+[pointsEarned]</span>: Station correctly denied package [slip.ordernumber]: "
							if(slip.erroneous & MANIFEST_ERROR_NAME)
								msg += "Destination station incorrect. "
							else if(slip.erroneous & MANIFEST_ERROR_COUNT)
								msg += "Packages incorrectly counted. "
							else if(slip.erroneous & MANIFEST_ERROR_ITEM)
								msg += "Package incomplete. "
							msg += "Points refunded.<br>"
						else if(!slip.erroneous && !denied) // Approving a proper order awards the relatively tiny points_per_slip
							shuttle_master.points += shuttle_master.points_per_slip
							msg += "<span class='good'>+[shuttle_master.points_per_slip]</span>: Package [slip.ordernumber] accorded.<br>"
						else // You done goofed.
							if(slip.erroneous)
								msg += "<span class='good'>+0</span>: Station approved package [slip.ordernumber] despite error: "
								if(slip.erroneous & MANIFEST_ERROR_NAME)
									msg += "Destination station incorrect."
								else if(slip.erroneous & MANIFEST_ERROR_COUNT)
									msg += "Packages incorrectly counted."
								else if(slip.erroneous & MANIFEST_ERROR_ITEM)
									msg += "We found unshipped items on our dock."
								msg += "  Be more vigilant.<br>"
							else
								pointsEarned = round(shuttle_master.points_per_crate - slip.points)
								shuttle_master.points += pointsEarned
								msg += "<span class='bad'>[pointsEarned]</span>: Station denied package [slip.ordernumber]. Our records show no fault on our part.<br>"
						find_slip = 0
					continue

				// Sell plasma
				if(istype(thing, /obj/item/stack/sheet/mineral/plasma))
					var/obj/item/stack/sheet/mineral/plasma/P = thing
					plasma_count += P.amount

				// Sell syndicate intel
				if(istype(thing, /obj/item/documents/syndicate))
					++intel_count

				// Sell tech levels
				if(istype(thing, /obj/item/weapon/disk/tech_disk))
					var/obj/item/weapon/disk/tech_disk/disk = thing
					if(!disk.stored) continue
					var/datum/tech/tech = disk.stored

					var/cost = tech.getCost(shuttle_master.techLevels[tech.id])
					if(cost)
						shuttle_master.techLevels[tech.id] = tech.level
						shuttle_master.points += cost
						for(var/mob/M in player_list)
							if(M.mind)
								for(var/datum/job_objective/further_research/objective in M.mind.job_objectives)
									objective.unit_completed(cost)
						msg += "<span class='good'>+[cost]</span>: [tech.name] - new data.<br>"

				// Sell max reliablity designs
				if(istype(thing, /obj/item/weapon/disk/design_disk))
					var/obj/item/weapon/disk/design_disk/disk = thing
					if(!disk.blueprint) continue
					var/datum/design/design = disk.blueprint
					if(design.id in shuttle_master.researchDesigns) continue

					if(initial(design.reliability) < 100 && design.reliability >= 100)
						// Maxed out reliability designs only.
						shuttle_master.points += shuttle_master.points_per_design
						shuttle_master.researchDesigns += design.id
						msg += "<span class='good'>+[shuttle_master.points_per_design]</span>: Reliable [design.name] design.<br>"

				// Sell exotic plants
				if(istype(thing, /obj/item/seeds))
					var/obj/item/seeds/S = thing
					if(S.seed.get_trait(TRAIT_RARITY) == 0) // Mundane species
						msg += "<span class='bad'>+0</span>: We don't need samples of mundane species \"[capitalize(S.seed.seed_name)]\".<br>"
					else if(shuttle_master.discoveredPlants[S.type]) // This species has already been sent to CentComm
						var/potDiff = S.seed.get_trait(TRAIT_POTENCY) - shuttle_master.discoveredPlants[S.type] // Compare it to the previous best
						if(potDiff > 0) // This sample is better
							shuttle_master.discoveredPlants[S.type] = S.seed.get_trait(TRAIT_POTENCY)
							msg += "<span class='good'>+[potDiff]</span>: New sample of \"[capitalize(S.seed.seed_name)]\" is superior. Good work.<br>"
							shuttle_master.points += potDiff
						else // This sample is worthless
							msg += "<span class='bad'>+0</span>: New sample of \"[capitalize(S.seed.seed_name)]\" is not more potent than existing sample ([shuttle_master.discoveredPlants[S.type]] potency).<br>"
					else // This is a new discovery!
						shuttle_master.discoveredPlants[S.type] = S.seed.get_trait(TRAIT_POTENCY)
						msg += "<span class='good'>+[S.seed.get_trait(TRAIT_RARITY)]</span>: New species discovered: \"[capitalize(S.seed.seed_name)]\". Excellent work.<br>"
						shuttle_master.points += S.seed.get_trait(TRAIT_RARITY) // That's right, no bonus for potency.  Send a crappy sample first to "show improvement" later
		qdel(MA)
		shuttle_master.sold_atoms += "."

	if(plasma_count > 0)
		pointsEarned = round(plasma_count * shuttle_master.points_per_plasma)
		msg += "<span class='good'>+[pointsEarned]</span>: Received [plasma_count] unit(s) of exotic material.<br>"
		shuttle_master.points += pointsEarned

	if(intel_count > 0)
		pointsEarned = round(intel_count * shuttle_master.points_per_intel)
		msg += "<span class='good'>+[pointsEarned]</span>: Received [intel_count] article(s) of enemy intelligence.<br>"
		shuttle_master.points += pointsEarned

	if(crate_count > 0)
		pointsEarned = round(crate_count * shuttle_master.points_per_crate)
		msg += "<span class='good'>+[pointsEarned]</span>: Received [crate_count] crate(s).<br>"
		shuttle_master.points += pointsEarned

	shuttle_master.centcom_message = msg

/proc/forbidden_atoms_check(atom/A)
	var/list/blacklist = list(
		/mob/living,
		/obj/effect/blob,
		/obj/effect/spider/spiderling,
		/obj/item/weapon/disk/nuclear,
		/obj/machinery/nuclearbomb,
		/obj/item/device/radio/beacon,
		/obj/machinery/the_singularitygen,
		/obj/singularity,
		/obj/machinery/teleport/station,
		/obj/machinery/teleport/hub,
		/obj/machinery/telepad,
		/obj/machinery/clonepod
	)
	if(A)
		if(is_type_in_list(A, blacklist))
			return 1
		for(var/thing in A)
			if(.(thing))
				return 1

	return 0

/********************
    SUPPLY ORDER
 ********************/
/datum/supply_order
	var/ordernum
	var/datum/supply_item/object = null
	var/orderedby = null
	var/datum/money_account/account
	var/paid = 0 // use to override when the account is charged
	var/orderedbyRank
	var/comment = null
	var/crates
	var/department = 0 // when this is set the access of the crate will be set to the appropriate department
/datum/controller/process/shuttle/proc/generateSupplyOrder(packId, _orderedby, _orderedbyRank, _comment, _crates)
	if(!packId)
		return
	var/datum/supply_item/P = supply_packs["[packId]"]
	if(!P)
		return

	var/datum/supply_order/O = new()
	O.ordernum = ordernum++
	O.object = P
	O.orderedby = _orderedby
	O.orderedbyRank = _orderedbyRank
	O.comment = _comment
	O.crates = _crates

	requestlist += O

	return O

/datum/supply_order/proc/generateRequisition(atom/_loc)
	if(!object)
		return

	var/obj/item/weapon/paper/reqform = new /obj/item/weapon/paper(_loc)
	playsound(_loc, "sound/goonstation/machines/printer_thermal.ogg", 50, 1)
	reqform.name = "Requisition Form - [crates] '[object.name]' for [orderedby]"
	reqform.info += "<h3>[station_name] Supply Requisition Form</h3><hr>"
	reqform.info += "INDEX: #[shuttle_master.ordernum]<br>"
	reqform.info += "REQUESTED BY: [orderedby]<br>"
	reqform.info += "RANK: [orderedbyRank]<br>"
	reqform.info += "REASON: [comment]<br>"
	reqform.info += "SUPPLY CRATE TYPE: [object.name]<br>"
	reqform.info += "NUMBER OF CRATES: [crates]<br>"
	reqform.info += "ACCESS RESTRICTION: [object.access ? get_access_desc(object.access) : "None"]<br>"
	reqform.info += "CONTENTS:<br>"
	reqform.info += object.manifest
	reqform.info += "<hr>"
	reqform.info += "STAMP BELOW TO APPROVE THIS REQUISITION:<br>"

	reqform.update_icon()	//Fix for appearing blank when printed.

	return reqform

/datum/supply_order/proc/createObject(atom/_loc, errors=0)
	if(!object)
		return
	if(object.cost && !paid)
		if(!account || account.holding < object.cost)
			message_admins("SUPPLY SHUTTLE ORDER HAS INSUFFICENT HELD FUNDS IN ACCOUNT [account.owner_name]")
			return
		if(!account.chargehold(object.cost, station_account, "Supply Order", "Cargo Department", 0, "Station Account"))
			message_admins("SUPPLY SHUTTLE ORDER HAS INSUFFICENT HELD FUNDS IN ACCOUNT [account.owner_name]")
			return
	// send a portion to the cargo budget
		var/cut = round(object.cost / 3)
		station_account.charge(cut, department_accounts["Cargo"], "Supply Order", "Cargo Department", 0, "Station Cargo Division")
	//create the crate
	var/obj/Crate = new object.containertype(_loc)
	var/department_str = ""
	if(object.access)
		Crate:req_access = list(text2num(object.access))
	if(department)
		if(!Crate.req_access)
			Crate.req_access = list()
		switch(department)
			if(CARGO)
				department_str = "Cargo"
				Crate.name = "[object.containername] (Cargo Department)"
				Crate.req_access += access_cargo
			if(SECURITY)
				department_str = "Security"
				Crate.name = "[object.containername] (Security Department)"
				Crate.req_access += access_security
			if(COMMAND)
				department_str = "Command"
				Crate.name = "[object.containername] (Command Department)"
				Crate.req_access += access_hop
			if(MEDICAL)
				department_str = "Medical"
				Crate.name = "[object.containername] (Medical Department)"
				Crate.req_access += access_medical
			if(SCIENCE)
				department_str = "Science"
				Crate.name = "[object.containername] (Science Department)"
				Crate.req_access += access_research
			if(ENGINEERING)
				department_str = "Engineering"
				Crate.name = "[object.containername] (Engineering Department)"
				Crate.req_access += access_engine
	else if(object.personal)
		Crate.req_personal += "[orderedby]"
		Crate.name = "[object.containername] [orderedby ? "([orderedby])":"" ]"
	//create the manifest slip
	var/obj/item/weapon/paper/manifest/slip = new /obj/item/weapon/paper/manifest()
	slip.erroneous = errors
	slip.points = object.cost
	slip.ordernumber = ordernum

	var/stationName = (errors & MANIFEST_ERROR_NAME) ? new_station_name() : station_name()
	var/packagesAmt = shuttle_master.shoppinglist.len + ((errors & MANIFEST_ERROR_COUNT) ? rand(1,2) : 0)

	slip.name = "Shipping Manifest - '[object.name]' for [orderedby]"
	slip.info = "<h3>[command_name()] Shipping Manifest</h3><hr><br>"
	slip.info +="Order: [object.name]<br>"	//#[ordernum]
	slip.info +="Destination: [stationName]<br>"
	slip.info +="Cost: [slip.points]<br>"
	if(!department)
		slip.info +="Purchased By: [orderedby]<br>"
		slip.info +="Rank: [orderedbyRank]<br>"
	else
		slip.info +="Ordered By: [orderedby]<br>"
		slip.info +="Rank: [orderedbyRank]<br>"
		slip.info +="For Department: [department_str]<br>"
	//	slip.info +="Reason: [comment]<br>"
	//	slip.info +="Supply Crate Type: <br>"
	//	slip.info +="Access Restriction: [object.access ? get_access_desc(object.access) : "None"]<br>"
	slip.info +="Time of arrival: [time2text(world.timeofday, "hh:mm.ss")]<br>"
	//	slip.info +="[packagesAmt] PACKAGES IN THIS SHIPMENT<br>"
	slip.info +="CONTENTS:<br><ul>"

	//we now create the actual contents
	var/list/contains
	contains = object.contains

	for(var/typepath in contains)
		if(!typepath)	continue
		var/atom/A = new typepath(Crate)
		if(object.amount && A.vars.Find("amount") && A:amount)
			A:amount = object.amount
		slip.info += "<li>[A.name]</li>"	//add the item to the manifest (even if it was misplaced)

	if(istype(Crate, /obj/structure/closet/critter)) // critter crates do not actually spawn mobs yet and have no contains var, but the manifest still needs to list them
		var/obj/structure/closet/critter/CritCrate = Crate
		if(CritCrate.content_mob)
			var/mob/crittername = CritCrate.content_mob
			slip.info += "<li>[initial(crittername.name)]</li>"
	//manifest finalisation
	slip.info += "</ul><br>"
	slip.info += "CONTENTS VERIFIED BY CENTCOM SUPPLY DEPT. DELIVER TO [uppertext(orderedby)]<hr>" // And now this is actually meaningful. PERSISTANT EDIT! NO LONGER MEANINGFUL
	slip.loc = Crate
	if(istype(Crate, /obj/structure/closet/crate))
		var/obj/structure/closet/crate/CR = Crate
		CR.manifest = slip
		CR.update_icon()
		CR.announce_beacons = object.announce_beacons.Copy()
	if(istype(Crate, /obj/structure/largecrate))
		var/obj/structure/largecrate/LC = Crate
		LC.manifest = slip
		LC.update_icon()

	return Crate


/datum/supply_order/proc/createObjectOld(atom/_loc, errors=0)
	if(!object)
		return

	//create the crate
	var/atom/Crate = new object.containertype(_loc)
	Crate.name = "[object.containername] [comment ? "([comment])":"" ]"
	if(object.access)
		Crate:req_access = list(text2num(object.access))
	//create the manifest slip
	var/obj/item/weapon/paper/manifest/slip = new /obj/item/weapon/paper/manifest()
	slip.erroneous = errors
	slip.points = object.cost
	slip.ordernumber = ordernum

	var/stationName = (errors & MANIFEST_ERROR_NAME) ? new_station_name() : station_name()
	var/packagesAmt = shuttle_master.shoppinglist.len + ((errors & MANIFEST_ERROR_COUNT) ? rand(1,2) : 0)

	slip.name = "Shipping Manifest - '[object.name]' for [orderedby]"
	slip.info = "<h3>[command_name()] Shipping Manifest</h3><hr><br>"
	slip.info +="Order: #[ordernum]<br>"
	slip.info +="Destination: [stationName]<br>"
	slip.info +="Requested By: [orderedby]<br>"
	slip.info +="Rank: [orderedbyRank]<br>"
	slip.info +="Reason: [comment]<br>"
	slip.info +="Supply Crate Type: [object.name]<br>"
	slip.info +="Access Restriction: [object.access ? get_access_desc(object.access) : "None"]<br>"
	slip.info +="[packagesAmt] PACKAGES IN THIS SHIPMENT<br>"
	slip.info +="CONTENTS:<br><ul>"

	//we now create the actual contents
	var/list/contains
	if(istype(object, /datum/supply_packs/misc/randomised))
		var/datum/supply_packs/misc/randomised/SO = object
		contains = list()
		if(object.contains.len)
			for(var/j=1, j<=SO.num_contained, j++)
				contains += pick(object.contains)
	else
		contains = object.contains

	for(var/typepath in contains)
		if(!typepath)	continue
		var/atom/A = new typepath(Crate)
		if(object.amount && A.vars.Find("amount") && A:amount)
			A:amount = object.amount
		slip.info += "<li>[A.name]</li>"	//add the item to the manifest (even if it was misplaced)

	if(istype(Crate, /obj/structure/closet/critter)) // critter crates do not actually spawn mobs yet and have no contains var, but the manifest still needs to list them
		var/obj/structure/closet/critter/CritCrate = Crate
		if(CritCrate.content_mob)
			var/mob/crittername = CritCrate.content_mob
			slip.info += "<li>[initial(crittername.name)]</li>"

	if((errors & MANIFEST_ERROR_ITEM))
		//secure and large crates cannot lose items
		if(findtext("[object.containertype]", "/secure/") || findtext("[object.containertype]","/largecrate/"))
			errors &= ~MANIFEST_ERROR_ITEM
		else
			var/lostAmt = max(round(Crate.contents.len/10), 1)
			//lose some of the items
			while(--lostAmt >= 0)
				qdel(pick(Crate.contents))

	//manifest finalisation
	slip.info += "</ul><br>"
	slip.info += "CHECK CONTENTS AND STAMP BELOW THE LINE TO CONFIRM RECEIPT OF GOODS<hr>" // And now this is actually meaningful.
	slip.loc = Crate
	if(istype(Crate, /obj/structure/closet/crate))
		var/obj/structure/closet/crate/CR = Crate
		CR.manifest = slip
		CR.update_icon()
		CR.announce_beacons = object.announce_beacons.Copy()
	if(istype(Crate, /obj/structure/largecrate))
		var/obj/structure/largecrate/LC = Crate
		LC.manifest = slip
		LC.update_icon()

	return Crate

/***************************
    ORDER/REQUESTS CONSOLE
 **************************/
/obj/machinery/computer/supplycomp
	name = "Supply Shuttle Console"
	desc = "Used to order supplies."
	icon_screen = "supply"
	req_access = list(access_cargo)
	circuit = /obj/item/weapon/circuitboard/supplycomp
	var/temp = null
	var/reqtime = 0
	var/hacked = 0
	var/can_order_contraband = 0
	var/last_viewed_group = "categories"
	var/datum/supply_item/content_pack
	var/list/pending = list() // used to store invoices when they call back to the computer. format pending[invoice_obj] = supply_item

/obj/machinery/computer/ordercomp
	name = "Supply Ordering Console"
	desc = "Used to order supplies from cargo staff."
	icon = 'icons/obj/computer.dmi'
	icon_screen = "request"
	circuit = /obj/item/weapon/circuitboard/ordercomp
	var/reqtime = 0
	var/last_viewed_group = "categories"
	var/datum/supply_item/content_pack
	var/list/recent = list() // used to store recent invoice prints and restrict them, format recent["real_name"] = world_time + 100
	var/list/pending = list() // used to store invoices when they call ack to the computer. format pending[invoice_obj] = supply_item
/obj/machinery/computer/ordercomp/attack_ai(var/mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/ordercomp/attack_hand(var/mob/user as mob)
	ui_interact(user)

/obj/machinery/computer/ordercomp/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null)
	var/data[0]
	data["last_viewed_group"] = last_viewed_group

	var/category_list[0]
	for(var/category in all_supply_lists)
		category_list.Add(list(list("name" = get_supply_lists_name(category), "category" = category)))
	data["categories"] = category_list

	var/cat = text2num(last_viewed_group)
	var/packs_list[0]
	for(var/set_name in shuttle_master.supply_packs)
		var/datum/supply_item/pack = shuttle_master.supply_packs[set_name]
		if(!pack.contraband && !pack.hidden && pack.group == cat)
			// 0/1 after the pack name (set_name) is a boolean for ordering multiple crates
			packs_list.Add(list(list("name" = pack.name, "amount" = pack.amount, "cost" = pack.cost, "command1" = list("doorder" = "[set_name]0"), "command2" = list("doorder" = "[set_name]1"), "command3" = list("contents" = set_name))))

	data["supply_packs"] = packs_list
	if(content_pack)
		var/pack_name = sanitize(content_pack.name)
		data["contents_name"] = pack_name
		data["contents"] = content_pack.manifest
		data["contents_desc"] = content_pack.desc
		data["contents_access"] = content_pack.access ? get_access_desc(content_pack.access) : "None"

	var/requests_list[0]
	for(var/set_name in shuttle_master.requestlist)
		var/datum/supply_order/SO = set_name
		if(SO)
			// Check if the user owns the request, so they can cancel requests
			var/obj/item/weapon/card/id/I = user.get_id_card()
			var/owned = 0
			if(I && SO.orderedby == I.registered_name)
				owned = 1
			requests_list.Add(list(list("ordernum" = SO.ordernum, "supply_type" = SO.object.name, "orderedby" = SO.orderedby, "owned" = owned, "command1" = list("rreq" = SO.ordernum))))
	data["requests"] = requests_list

	var/orders_list[0]
	for(var/set_name in shuttle_master.shoppinglist)
		var/datum/supply_order/SO = set_name
		if(SO)
			orders_list.Add(list(list("ordernum" = SO.ordernum, "supply_type" = SO.object.name, "orderedby" = SO.orderedby)))
	data["orders"] = orders_list

	data["points"] = round(shuttle_master.points)
	data["send"] = list("send" = 1)

	data["moving"] = shuttle_master.supply.mode != SHUTTLE_IDLE
	data["at_station"] = shuttle_master.supply.getDockedId() == "supply_home"
	data["timeleft"] = shuttle_master.supply.timeLeft(600)

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data)
	if(!ui)
		ui = new(user, src, ui_key, "order_console.tmpl", name, ORDER_SCREEN_WIDTH, ORDER_SCREEN_HEIGHT)
		ui.set_initial_data(data)
		ui.open()

/obj/machinery/computer/ordercomp/proc/create_invoice(var/datum/mind/user)
	var/mob/body = user.current
	if(!content_pack)
		return
	if(recent && recent.Find(user.name))
		if(world.time < recent[user.name])
			to_chat(body, "<b>[src]</b>'s monitor flashes, \'[round((world.time - reqtime)/10)] seconds remaining until another requisition form may be printed.\'")
			return 1
	recent[user.name] = world.time + 150
	var/obj/item/device/invoice/invoice = new()
	invoice.created_for = user
	invoice.payment_type = 2 // -- 1 = pay immidietley, 2 = pay on delivery (used for when ordering through the cargo shuttle)
	invoice.cost = content_pack.cost // set through creator
	invoice.invoice_desc = content_pack.desc // set through creator
	invoice.title = "NT SUPPLY INVOICE" // set through creater, format -- CENTCOM CARGO DEPARTMENT INVOICE
	invoice.connected = src // -- set through creator, Passes to the connected machine when the invoice is paid for
	invoice.authentication = list()
	invoice.name = "[content_pack.name] ([body.name])"
	for(var/x in content_pack.authentication)
		invoice.authentication += x
	pending[invoice] = content_pack
	playsound(loc, "sound/goonstation/machines/printer_thermal.ogg", 50, 1)
	invoice.loc = loc
	content_pack = null
	last_viewed_group = "categories"
	nanomanager.update_uis(src)
/obj/machinery/computer/ordercomp/handle_invoice_confirm(var/obj/item/device/invoice/invoice, var/datum/money_account/account)
	var/datum/supply_item/P = pending[invoice]
	if(!P)
		message_admins("No item found for invoice")
		return
	var/datum/supply_order/O = new()
	O.ordernum = 1
	O.object = P
	O.orderedby = invoice.created_for.name
	var/current_rank = invoice.created_for.ranks[to_strings(invoice.created_for.assigned_job.department_flag)]
	if(invoice.created_for.assigned_job)
		O.orderedbyRank = "[invoice.created_for.assigned_job.title] ([current_rank])"
	else
		O.orderedbyRank = "None."
	O.comment = "Ordered by [invoice.created_for.name]"
	O.crates = 1
	O.account = account
	shuttle_master.shoppinglist += O

	return 1

/obj/machinery/computer/ordercomp/Topic(href, href_list)
	if(..())
		return 1
	if(href_list["create_invoice"])
		if(!content_pack)
			message_admins("trying to create invoice without content_pack")
			return 0
		create_invoice(usr.mind)
	if(href_list["doorder"])
		if(world.time < reqtime)
			visible_message("<b>[src]</b>'s monitor flashes, \"[round((world.time - reqtime)/10)] seconds remaining until another requisition form may be printed.\"")
			nanomanager.update_uis(src)
			return 1

		var/index = copytext(href_list["doorder"], 1, lentext(href_list["doorder"])) //text2num(copytext(href_list["doorder"], 1))
		var/datum/supply_item/P = shuttle_master.supply_packs[index]
		if(!istype(P))
			return 1
		var/crates = 1
		var/timeout = world.time + 600
		var/reason = input(usr,"Reason:","Why do you require this item?","") as null|text
		if(world.time > timeout || !reason || ..())
			return 1
		reason = sanitize(copytext(reason, 1, MAX_MESSAGE_LEN))

		var/idname = "*None Provided*"
		var/idrank = "*None Provided*"
		if(ishuman(usr))
			var/mob/living/carbon/human/H = usr
			idname = H.get_authentification_name()
			idrank = H.get_assignment()
		else if(issilicon(usr))
			idname = usr.real_name

		reqtime = (world.time + 5) % 1e5

		//make our supply_order datums
		for(var/i = 1; i <= crates; i++)
			var/datum/supply_order/O = shuttle_master.generateSupplyOrder(index, idname, idrank, reason, crates)
			if(!O)	return
			if(i == 1)
				O.generateRequisition(loc)

	else if(href_list["rreq"])
		var/ordernum = text2num(href_list["rreq"])
		var/obj/item/weapon/card/id/I = usr.get_id_card()
		for(var/i=1, i<=shuttle_master.requestlist.len, i++)
			var/datum/supply_order/SO = shuttle_master.requestlist[i]
			if(SO.ordernum == ordernum && (I && SO.orderedby == I.registered_name))
				shuttle_master.requestlist.Cut(i,i+1)
				break

	else if(href_list["last_viewed_group"])
		content_pack = null
		last_viewed_group = text2num(href_list["last_viewed_group"])

	else if(href_list["contents"])
		var/topic = href_list["contents"]
		if(topic == 1)
			content_pack = null
		else
			var/datum/supply_item/P = shuttle_master.supply_packs[topic]
			content_pack = P

	add_fingerprint(usr)
	nanomanager.update_uis(src)
	return 1

/obj/machinery/computer/supplycomp/attackby(obj/W, mob/user, params)
	if(istype(W, /obj/item/weapon/card/id))
		if(!content_pack)
			to_chat(user, "Please select an item first.")
			return 0
		var/obj/item/weapon/card/id/id = W
		if(!id.assigned_mind)
			to_chat(user, "There's no valid identity associated to this ID.")
			return 0
		if(!content_pack)
			return 0
		return create_invoice(id.assigned_mind, 1)
	else if(istype(W, /obj/item/device/pda))
		if(!content_pack)
			to_chat(user, "Please select an item first.")
			return 0
		var/obj/item/device/pda/pda = W
		if(!pda.id || !pda.id.assigned_mind)
			to_chat(user, "There is no valid ID in the PDA.")
			return
		return create_invoice(pda.id.assigned_mind, 1)
	else
		..()

/obj/machinery/computer/ordercomp/attackby(obj/W, mob/user, params)
	if(istype(W, /obj/item/weapon/card/id))
		if(!content_pack)
			ui_interact(user)
			return 1
		var/obj/item/weapon/card/id/id = W
		if(!id.assigned_mind)
			to_chat("There's no valid identity associated to this ID.")
			return 0
		if(!content_pack)
			return 0
		return create_invoice(id.assigned_mind)
	else if(istype(W, /obj/item/device/pda))
		if(!content_pack)
			ui_interact(user)
			return 1
		var/obj/item/device/pda/pda = W
		if(!pda.id || !pda.id.assigned_mind)
			to_chat(user, "There is no valid ID in the PDA.")
			return
		return create_invoice(pda.id.assigned_mind)
	else
		..()

/obj/machinery/computer/supplycomp/attack_ai(var/mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/supplycomp/attack_hand(var/mob/user as mob)
	if(!allowed(user) && !isobserver(user))
		to_chat(user, "<span class='warning'>Access denied.</span>")
		return 1

	post_signal("supply")
	ui_interact(user)
	return

/obj/machinery/computer/supplycomp/emag_act(user as mob)
	if(!hacked)
		to_chat(user, "<span class='notice'>Special supplies unlocked.</span>")
		hacked = 1
		return

/obj/machinery/computer/supplycomp/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null)
	// data to send to ui
	var/data[0]
	data["last_viewed_group"] = last_viewed_group

	var/category_list[0]
	for(var/category in all_supply_lists)
		category_list.Add(list(list("name" = get_supply_lists_name(category), "category" = category)))
	data["categories"] = category_list

	var/cat = text2num(last_viewed_group)
	var/packs_list[0]
	for(var/set_name in shuttle_master.supply_packs)
		var/datum/supply_item/pack = shuttle_master.supply_packs[set_name]
		if((pack.hidden && src.hacked) || (pack.contraband && src.can_order_contraband) || (!pack.contraband && !pack.hidden))
			if(pack.group == cat)
				// 0/1 after the pack name (set_name) is a boolean for ordering multiple crates
				packs_list.Add(list(list("name" = pack.name, "amount" = pack.amount, "cost" = pack.cost, "command1" = list("doorder" = "[set_name]0"), "command2" = list("doorder" = "[set_name]1"), "command3" = list("contents" = set_name))))

	data["supply_packs"] = packs_list
	if(content_pack)
		var/pack_name = sanitize(content_pack.name)
		data["contents_name"] = pack_name
		data["contents"] = content_pack.manifest
		data["contents_access"] = content_pack.access ? get_access_desc(content_pack.access) : "None"
		data["contents_desc"] = content_pack.desc

	var/requests_list[0]
	for(var/set_name in shuttle_master.requestlist)
		var/datum/supply_order/SO = set_name
		if(SO)
			if(!SO.comment)
				SO.comment = "No comment."
			requests_list.Add(list(list("ordernum" = SO.ordernum, "supply_type" = SO.object.name, "orderedby" = SO.orderedby, "comment" = SO.comment, "command1" = list("confirmorder" = SO.ordernum), "command2" = list("rreq" = SO.ordernum))))
	data["requests"] = requests_list

	var/orders_list[0]
	for(var/set_name in shuttle_master.shoppinglist)
		var/datum/supply_order/SO = set_name
		if(SO)
			orders_list.Add(list(list("ordernum" = SO.ordernum, "supply_type" = SO.object.name, "orderedby" = SO.orderedby, "comment" = SO.comment)))
	data["orders"] = orders_list

	data["canapprove"] = (shuttle_master.supply.getDockedId() == "supply_away") && !(shuttle_master.supply.mode != SHUTTLE_IDLE)
	var/datum/money_account/dep_acc = department_accounts["Cargo"]
	if(dep_acc)
		data["points"] = dep_acc.money
		if(user.mind.assigned_job && user.mind.assigned_job.uid == "quartermaster")
			data["allocated"] = dep_acc.money
		else if(!user.mind.assigned_job || user.mind.assigned_job.department_flag != CARGO)
			data["allocated"] = 0
		else
			data["allocated"] = user.mind.allocated
	else
		message_admins("department account not found: cargo")
	data["send"] = list("send" = 1)
	data["message"] = shuttle_master.centcom_message ? shuttle_master.centcom_message : "Remember to stamp and send back the supply manifests."

	data["moving"] = shuttle_master.supply.mode != SHUTTLE_IDLE
	data["at_station"] = shuttle_master.supply.getDockedId() == "supply_home"
	data["timeleft"] = shuttle_master.supply.timeLeft(600)
	data["can_launch"] = !shuttle_master.supply.canMove()


	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data)
	if(!ui)
		ui = new(user, src, ui_key, "supply_console.tmpl", name, SUPPLY_SCREEN_WIDTH, SUPPLY_SCREEN_HEIGHT)
		ui.set_initial_data(data)
		ui.open()

/obj/machinery/computer/supplycomp/proc/is_authorized(user)
	if(allowed(user))
		return 1

	if(isobserver(user) && check_rights(R_ADMIN, 0))
		return 1

	return 0

/obj/machinery/computer/supplycomp/handle_invoice_confirm(var/obj/item/device/invoice/invoice, var/datum/money_account/account)
	var/datum/supply_item/P = pending[invoice]
	if(!P)
		message_admins("No item found for invoice")
		return
	var/datum/supply_order/O = new()
	O.ordernum = 1
	O.object = P
	O.orderedby = invoice.created_for.name
	var/current_rank = invoice.created_for.ranks[to_strings(invoice.created_for.assigned_job.department_flag)]
	if(invoice.created_for.assigned_job)
		O.orderedbyRank = "[invoice.created_for.assigned_job.title] ([current_rank])"
	else
		O.orderedbyRank = "None."
	if(invoice.department)
		O.department = invoice.department
	O.comment = "Ordered by [invoice.created_for.name]"
	O.crates = 1
	O.account = account
	shuttle_master.shoppinglist += O

	return 1


/obj/machinery/computer/supplycomp/proc/create_invoice(var/datum/mind/user, var/swiped = 0)
	var/mob/body = user.current
	if(!content_pack)
		return
	var/obj/item/device/invoice/invoice = new()
	if(!swiped)
		invoice.department = CARGO
		invoice.department_name = "Cargo"
	invoice.created_for = user
	invoice.payment_type = 2
	invoice.cost = content_pack.cost // set through creator
	invoice.invoice_desc = content_pack.desc // set through creator
	invoice.title = "NT SUPPLY INVOICE" // set through creater, format -- CENTCOM CARGO DEPARTMENT INVOICE
	invoice.connected = src // -- set through creator, Passes to the connected machine when the invoice is paid for
	invoice.authentication = list()
	invoice.name = "[content_pack.name] ([body.name])"
	for(var/x in content_pack.authentication)
		invoice.authentication += x
	pending[invoice] = content_pack
	playsound(loc, "sound/goonstation/machines/printer_thermal.ogg", 50, 1)
	invoice.loc = loc
	content_pack = null
	last_viewed_group = "categories"

/obj/machinery/computer/supplycomp/Topic(href, href_list)
	if(..())
		return 1

	if(!is_authorized(usr))
		return 1

	if(!shuttle_master)
		log_to_dd("## ERROR: The shuttle_master controller datum is missing somehow.")
		return 1

	if(href_list["send"])
		if(shuttle_master.supply.canMove())
			to_chat(usr, "<span class='warning'>For safety reasons the automated supply shuttle cannot transport live organisms, classified nuclear weaponry or homing beacons.</span>")
		else if(shuttle_master.supply.getDockedId() == "supply_home")
			shuttle_master.toggleShuttle("supply", "supply_home", "supply_away", 1)
			investigate_log("[key_name(usr)] has sent the supply shuttle away. Remaining points: [shuttle_master.points]. Shuttle contents: [shuttle_master.sold_atoms]", "cargo")
		else if(!shuttle_master.supply.request(shuttle_master.getDock("supply_home")))
			post_signal("supply")

	else if(href_list["create_invoice"])
		if(!content_pack)
			message_admins("trying to create invoice without content_pack")
			return 0
		create_invoice(usr.mind)

	else if(href_list["last_viewed_group"])
		content_pack = null
		last_viewed_group = text2num(href_list["last_viewed_group"])

	else if(href_list["contents"])
		var/topic = href_list["contents"]
		if(topic == 1)
			content_pack = null
		else
			var/datum/supply_item/P = shuttle_master.supply_packs[topic]
			content_pack = P

	add_fingerprint(usr)
	nanomanager.update_uis(src)
	return 1

/obj/machinery/computer/supplycomp/proc/post_signal(var/command)
	var/datum/radio_frequency/frequency = radio_controller.return_frequency(1435)

	if(!frequency) return

	var/datum/signal/status_signal = new
	status_signal.source = src
	status_signal.transmission_method = 1
	status_signal.data["command"] = command

	frequency.post_signal(src, status_signal)


// MINI DEPARTMENT SUPPLY COMP

/obj/machinery/computer/minisupplycomp
	name = "Department Supply Console"
	desc = "Used to order supplies on department accounts.."
	icon_screen = "supply"
	req_access = list(access_cargo)
	circuit = /obj/item/weapon/circuitboard/minisupplycomp
	var/temp = null
	var/reqtime = 0
	var/hacked = 0
	var/can_order_contraband = 0
	var/last_viewed_group = "categories"
	var/datum/supply_item/content_pack
	var/list/pending = list() // used to store invoices when they call back to the computer. format pending[invoice_obj] = supply_item
	var/datum/department/linked_department
/obj/machinery/computer/minisupplycomp/New()
	..()
	var/area/A = src.myArea
	if(istype(A, /area/quartermaster))
		linked_department = get_department_datum(CARGO)
		req_access = list(access_cargo)
	if(istype(A, /area/toxins))
		linked_department = get_department_datum(SCIENCE)
		req_access = list(access_tox)
	if(istype(A, /area/security))
		linked_department = get_department_datum(SECURITY)
		req_access = list(access_security)
	if(istype(A, /area/medical))
		linked_department = get_department_datum(MEDICAL)
		req_access = list(access_medical)
	if(istype(A, /area/engine))
		linked_department = get_department_datum(ENGINEERING)
		req_access = list(access_engine)
	if(istype(A, /area/bridge))
		linked_department = get_department_datum(COMMAND)
		req_access = list(access_hop)
/obj/machinery/computer/minisupplycomp/attack_ai(var/mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/minisupplycomp/attack_hand(var/mob/user as mob)
	if(!allowed(user) && !isobserver(user))
		to_chat(user, "<span class='warning'>Access denied.</span>")
		return 1
	if(!linked_department)
		to_chat(user, "<span class='warning'>No department found. Position terminal inside valid department.</span>")
		return 1
	post_signal("supply")
	ui_interact(user)
	return

/obj/machinery/computer/minisupplycomp/emag_act(user as mob)
	if(!hacked)
		to_chat(user, "<span class='notice'>Special supplies unlocked.</span>")
		hacked = 1
		return

/obj/machinery/computer/minisupplycomp/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null)
	// data to send to ui
	var/data[0]
	data["last_viewed_group"] = last_viewed_group

	var/category_list[0]
	for(var/category in all_supply_lists)
		category_list.Add(list(list("name" = get_supply_lists_name(category), "category" = category)))
	data["categories"] = category_list

	var/cat = text2num(last_viewed_group)
	var/packs_list[0]
	for(var/set_name in shuttle_master.supply_packs)
		var/datum/supply_item/pack = shuttle_master.supply_packs[set_name]
		if((pack.hidden && src.hacked) || (pack.contraband && src.can_order_contraband) || (!pack.contraband && !pack.hidden))
			if(pack.group == cat)
				// 0/1 after the pack name (set_name) is a boolean for ordering multiple crates
				packs_list.Add(list(list("name" = pack.name, "amount" = pack.amount, "cost" = pack.cost, "command1" = list("doorder" = "[set_name]0"), "command2" = list("doorder" = "[set_name]1"), "command3" = list("contents" = set_name))))

	data["supply_packs"] = packs_list
	if(content_pack)
		var/pack_name = sanitize(content_pack.name)
		data["contents_name"] = pack_name
		data["contents"] = content_pack.manifest
		data["contents_access"] = content_pack.access ? get_access_desc(content_pack.access) : "None"
		data["contents_desc"] = content_pack.desc

	var/requests_list[0]
	for(var/set_name in shuttle_master.requestlist)
		var/datum/supply_order/SO = set_name
		if(SO)
			if(!SO.comment)
				SO.comment = "No comment."
			requests_list.Add(list(list("ordernum" = SO.ordernum, "supply_type" = SO.object.name, "orderedby" = SO.orderedby, "comment" = SO.comment, "command1" = list("confirmorder" = SO.ordernum), "command2" = list("rreq" = SO.ordernum))))
	data["requests"] = requests_list

	var/orders_list[0]
	for(var/set_name in shuttle_master.shoppinglist)
		var/datum/supply_order/SO = set_name
		if(SO)
			orders_list.Add(list(list("ordernum" = SO.ordernum, "supply_type" = SO.object.name, "orderedby" = SO.orderedby, "comment" = SO.comment)))
	data["orders"] = orders_list

	data["canapprove"] = (shuttle_master.supply.getDockedId() == "supply_away") && !(shuttle_master.supply.mode != SHUTTLE_IDLE)
	var/datum/money_account/dep_acc = linked_department.account
	if(dep_acc)
		data["points"] = dep_acc.money
		if(user.mind.assigned_job && user.mind.assigned_job.uid == "quartermaster")
			data["allocated"] = dep_acc.money
		else if(!user.mind.assigned_job || user.mind.assigned_job.department_flag != CARGO)
			data["allocated"] = 0
		else
			data["allocated"] = user.mind.allocated
	else
		message_admins("department account not found: [src]")
	data["send"] = list("send" = 1)
	data["message"] = shuttle_master.centcom_message ? shuttle_master.centcom_message : "Remember to stamp and send back the supply manifests."

	data["moving"] = shuttle_master.supply.mode != SHUTTLE_IDLE
	data["at_station"] = shuttle_master.supply.getDockedId() == "supply_home"
	data["timeleft"] = shuttle_master.supply.timeLeft(600)
	data["can_launch"] = !shuttle_master.supply.canMove()


	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data)
	if(!ui)
		ui = new(user, src, ui_key, "mini_supply_console.tmpl", name, SUPPLY_SCREEN_WIDTH, SUPPLY_SCREEN_HEIGHT)
		ui.set_initial_data(data)
		ui.open()

/obj/machinery/computer/minisupplycomp/proc/is_authorized(user)
	if(allowed(user))
		return 1

	if(isobserver(user) && check_rights(R_ADMIN, 0))
		return 1

	return 0

/obj/machinery/computer/minisupplycomp/handle_invoice_confirm(var/obj/item/device/invoice/invoice, var/datum/money_account/account)
	var/datum/supply_item/P = pending[invoice]
	if(!P)
		message_admins("No item found for invoice")
		return
	var/datum/supply_order/O = new()
	O.ordernum = 1
	O.object = P
	O.orderedby = invoice.created_for.name
	var/current_rank = invoice.created_for.ranks[to_strings(invoice.created_for.assigned_job.department_flag)]
	if(invoice.created_for.assigned_job)
		O.orderedbyRank = "[invoice.created_for.assigned_job.title] ([current_rank])"
	else
		O.orderedbyRank = "None."
	if(invoice.department)
		O.department = invoice.department
	O.comment = "Ordered by [invoice.created_for.name]"
	O.crates = 1
	O.account = account
	shuttle_master.shoppinglist += O

	return 1


/obj/machinery/computer/minisupplycomp/proc/create_invoice(var/datum/mind/user, var/swiped = 0)
	if(!linked_department)
		return 0
	var/mob/body = user.current
	if(!content_pack)
		return
	var/obj/item/device/invoice/invoice = new()
	if(!swiped)
		invoice.department = linked_department.department_flag
		invoice.department_name = linked_department.name
	invoice.created_for = user
	invoice.payment_type = 2
	invoice.cost = content_pack.cost // set through creator
	invoice.invoice_desc = content_pack.desc // set through creator
	invoice.title = "NT SUPPLY INVOICE" // set through creater, format -- CENTCOM CARGO DEPARTMENT INVOICE
	invoice.connected = src // -- set through creator, Passes to the connected machine when the invoice is paid for
	invoice.authentication = list()
	invoice.name = "[content_pack.name] ([body.name])"
	for(var/x in content_pack.authentication)
		invoice.authentication += x
	pending[invoice] = content_pack
	playsound(loc, "sound/goonstation/machines/printer_thermal.ogg", 50, 1)
	invoice.loc = loc
	content_pack = null
	last_viewed_group = "categories"

/obj/machinery/computer/minisupplycomp/Topic(href, href_list)
	if(..())
		return 1

	if(!is_authorized(usr))
		return 1

	if(!shuttle_master)
		log_to_dd("## ERROR: The shuttle_master controller datum is missing somehow.")
		return 1

	if(href_list["create_invoice"])
		if(!content_pack)
			message_admins("trying to create invoice without content_pack")
			return 0
		create_invoice(usr.mind)

	else if(href_list["last_viewed_group"])
		content_pack = null
		last_viewed_group = text2num(href_list["last_viewed_group"])

	else if(href_list["contents"])
		var/topic = href_list["contents"]
		if(topic == 1)
			content_pack = null
		else
			var/datum/supply_item/P = shuttle_master.supply_packs[topic]
			content_pack = P

	add_fingerprint(usr)
	nanomanager.update_uis(src)
	return 1

/obj/machinery/computer/minisupplycomp/proc/post_signal(var/command)
	var/datum/radio_frequency/frequency = radio_controller.return_frequency(1435)

	if(!frequency) return

	var/datum/signal/status_signal = new
	status_signal.source = src
	status_signal.transmission_method = 1
	status_signal.data["command"] = command

	frequency.post_signal(src, status_signal)












/**********
    MISC
 **********/
/area/supply/station
	name = "Supply Shuttle"
	icon_state = "shuttle3"
	requires_power = 0

/area/supply/dock
	name = "Supply Shuttle"
	icon_state = "shuttle3"
	requires_power = 0

/obj/structure/plasticflaps
	name = "\improper plastic flaps"
	desc = "Completely impassable - or are they?"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "plasticflaps"
	density = 0
	anchored = 1
	layer = 4
	var/list/mobs_can_pass = list(
		/mob/living/carbon/slime,
		/mob/living/simple_animal/mouse,
		/mob/living/silicon/robot/drone,
		/mob/living/simple_animal/bot/mulebot
		)

/obj/structure/plasticflaps/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob, params)
	if(istype(W, /obj/item/weapon/wrench))
		to_chat(user, "<span class='notice'>You've [anchored ? "un" : ""]anchored [name].</span>")
		playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
		anchored = !anchored
		return
	else if(iswirecutter(W))
		to_chat(user, "<span class='notice'>You deconstruct [name].")
		playsound(get_turf(src), 'sound/items/Wirecutter.ogg', 50, 1)
		new /obj/item/stack/sheet/mineral/plastic(src.loc, 5)
		qdel(src)
		return
	else
		..()
/obj/structure/plasticflaps/CanPass(atom/A, turf/T)
	if(istype(A) && A.checkpass(PASSGLASS))
		return prob(60)

	var/obj/structure/stool/bed/B = A
	if(istype(A, /obj/structure/stool/bed) && B.buckled_mob)//if it's a bed/chair and someone is buckled, it will not pass
		return 0

	if(istype(A, /obj/structure/closet/cardboard))
		var/obj/structure/closet/cardboard/C = A
		if(C.move_delay)
			return 0

	if(istype(A, /obj/vehicle))	//no vehicles
		return 0

	var/mob/living/M = A
	if(istype(M))
		if(M.lying)				// THIS ALLOWS HUMANS TO PASS FLAPS BY LIEING DOWN
			return ..()
		for(var/mob_type in mobs_can_pass)
			if(istype(A, mob_type))
				return ..()
		if(istype(A, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = M
			if(H.species.is_small)
				return ..()
		return 0

	return ..()


/obj/structure/plasticflaps/CanAStarPass(ID, to_dir, caller)
	if(istype(caller, /mob/living))
		for(var/mob_type in mobs_can_pass)
			if(istype(caller, mob_type))
				return 1

		var/mob/living/M = caller
		if(!M.ventcrawler && !M.small)
			return 0
	return 1

/obj/structure/plasticflaps/ex_act(severity)
	switch(severity)
		if(1)
			qdel(src)
		if(2)
			if(prob(50))
				qdel(src)
		if(3)
			if(prob(5))
				qdel(src)

/obj/structure/plasticflaps/mining //A specific type for mining that doesn't allow airflow because of them damn crates
	name = "\improper Airtight plastic flaps"
	desc = "Heavy duty, airtight, plastic flaps."

/obj/structure/plasticflaps/mining/initialize()
	air_update_turf(1)
	..()

/obj/structure/plasticflaps/mining/Destroy()
	air_update_turf(1)
	return ..()

/obj/structure/plasticflaps/mining/CanAtmosPass(turf/T)
	return 0

#undef ORDER_SCREEN_WIDTH
#undef ORDER_SCREEN_HEIGHT
#undef SUPPLY_SCREEN_WIDTH
#undef SUPPLY_SCREEN_HEIGHT
