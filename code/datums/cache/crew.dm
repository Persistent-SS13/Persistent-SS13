var/global/datum/repository/crew/crew_repository = new()

/datum/repository/crew/New()
	cache_data = list()
	..()

/datum/repository/crew/proc/health_data(var/turf/T)
	var/list/crewmembers = list()
	if(!T)
		return crewmembers

	var/z_level = "[T.z]"
	var/datum/cache_entry/cache_entry = cache_data[z_level]
	if(!cache_entry)
		cache_entry = new/datum/cache_entry
		cache_data[z_level] = cache_entry

	if(world.time < cache_entry.timestamp)
		return cache_entry.data

	var/tracked = scan()
	for(var/mob/living/H in tracked)

		var/turf/pos = get_turf(H)
		if(H && istype(H) && (pos))
			if(istype(H, /mob/living/))
				var/list/crewmemberData = list("dead"=0, "oxy"=-1, "tox"=-1, "fire"=-1, "brute"=-1, "area"="", "x"=-1, "y"=-1, "ref" = "\ref[H]", "state"="")
				if(!H)
					continue
				if(istype(H, /mob/living/silicon/robot))
					var/mob/living/silicon/robot/R = H
					if(R.cell)
						if(R.cell.charge == 0)
							crewmemberData["charge"] = "None"
						else if(R.cell.charge <= (R.cell.maxcharge / 4))
							crewmemberData["charge"] = "Low"
						else
							crewmemberData["charge"] = "Charged"
					crewmemberData["state"] = "Cyborg"
					crewmemberData["name"] = H.get_assumed_name()
				//	crewmemberData["rank"] = H.get_authentification_rank(if_no_id="Unknown", if_no_job="No Job")
					if(H.mind && H.mind.assigned_job)
						crewmemberData["assignment"] = H.mind.assigned_job.title
					else
						crewmemberData["assignment"] = ""
					crewmemberData["dead"] = H.stat > UNCONSCIOUS
					crewmemberData["oxy"] = round(H.getOxyLoss(), 1)
					crewmemberData["tox"] = round(H.getToxLoss(), 1)
					crewmemberData["fire"] = round(H.getFireLoss(), 1)
					crewmemberData["brute"] = round(H.getBruteLoss(), 1)
					if(pos.z == 2)
						crewmemberData["area"] = "Centcom"
					if(pos.z == 5)
						crewmemberData["area"] = "The Asteroid"
						crewmemberData["x"] = pos.x
						crewmemberData["y"] = pos.y
					else
						var/area/A = get_area(H)
						crewmemberData["area"] = sanitize(A.name)
						crewmemberData["x"] = pos.x
						crewmemberData["y"] = pos.y
						
				if(istype(H, /mob/living/carbon/brain))
					var/mob/living/carbon/brain/B = H
					crewmemberData["state"] = "Brain"
					crewmemberData["name"] = H.get_assumed_name()
					if(H.mind && H.mind.assigned_job)
						crewmemberData["assignment"] = H.mind.assigned_job.title
					else
						crewmemberData["assignment"] = ""
					crewmemberData["dead"] = 1
					if(pos.z == 2)
						crewmemberData["area"] = "Centcom"
					else if(pos.z == 5)
						crewmemberData["area"] = "The Asteroid"
						crewmemberData["x"] = pos.x
						crewmemberData["y"] = pos.y
					else
						var/area/A = get_area(H)
						crewmemberData["area"] = sanitize(A.name)
						crewmemberData["x"] = pos.x
						crewmemberData["y"] = pos.y
					
				if(istype(H, /mob/living/carbon/human))
					var/mob/living/carbon/human/Hu = H
					crewmemberData["state"] = "Humanoid"
					crewmemberData["name"] = H.get_assumed_name()
				//	crewmemberData["rank"] = H.get_authentification_rank(if_no_id="Unknown", if_no_job="No Job")
					if(H.mind && H.mind.assigned_job)
						crewmemberData["assignment"] = H.mind.assigned_job.title
					else
						crewmemberData["assignment"] = "Unassigned"
					crewmemberData["dead"] = H.stat > UNCONSCIOUS
					crewmemberData["oxy"] = round(H.getOxyLoss(), 1)
					crewmemberData["tox"] = round(H.getToxLoss(), 1)
					crewmemberData["fire"] = round(H.getFireLoss(), 1)
					crewmemberData["brute"] = round(H.getBruteLoss(), 1)
					if(pos.z == 2)
						crewmemberData["area"] = "Centcom"
					if(pos.z == 5)
						crewmemberData["area"] = "The Asteroid"
						crewmemberData["x"] = pos.x
						crewmemberData["y"] = pos.y
					else
						var/area/A = get_area(H)
						crewmemberData["area"] = sanitize(A.name)
						crewmemberData["x"] = pos.x
						crewmemberData["y"] = pos.y
						
				crewmembers[++crewmembers.len] = crewmemberData

	crewmembers = sortByKey(crewmembers, "name")
	cache_entry.timestamp = world.time + 5 SECONDS
	cache_entry.data = crewmembers

	return crewmembers

/datum/repository/crew/proc/old_scan()
	var/list/tracked = list()
	for(var/mob/living/carbon/human/H in mob_list)
		if(!H.mind)
			continue
		if(istype(H.w_uniform, /obj/item/clothing/under))
			var/obj/item/clothing/under/C = H.w_uniform
			if(C.has_sensor)
				tracked |= C
	return tracked

/datum/repository/crew/proc/scan()
	var/list/tracked = list()
	for(var/obj/item/weapon/implant/crewtracker/I in tracked_crewimplants)
		if(I.imp_in && I.tracking)
			tracked |= I.imp_in
	return tracked
