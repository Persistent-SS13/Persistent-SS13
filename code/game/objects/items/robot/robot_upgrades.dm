// robot_upgrades.dm
// Contains various borg upgrades.

/obj/item/borg/chassis_mod
	name = "Chassis Mod."
	desc = "Insert this into a cyborg to allow it to change its appearance."
	icon = 'icons/obj/module.dmi'
	icon_state = "mainboard"
	var/req_module = 1
	var/module_type = null
	var/chassis_type = null
	
/obj/item/borg/chassis_mod/proc/action(mob/living/silicon/robot/R)
	if(R.chassis_mod && istype(R.chassis_mod, /obj/item/borg/chassis_mod))
		to_chat(R, "Chassis mod slot already filled!")
		to_chat(usr, "There's already an installed chassis mod!")
		return 0
	R.chassis_mod = src
	return 1
	
/obj/item/borg/chassis_mod/service/waitress
	name = "Service Chassis: Waitress"
	module_type = /obj/item/weapon/robot_module/butler
	chassis_type = "Service"
	
/obj/item/borg/chassis_mod/service/bro
	name = "Service Chassis: Brobot"
	module_type = /obj/item/weapon/robot_module/butler
	chassis_type = "Brobot"
	
/obj/item/borg/chassis_mod/service/fountainbot
	name = "Service Chassis: Fountain-head"
	module_type = /obj/item/weapon/robot_module/butler
	chassis_type = "toiletbot"

/obj/item/borg/chassis_mod/service/poshbot
	name = "Service Chassis: Poshbot"
	module_type = /obj/item/weapon/robot_module/butler
	chassis_type = "maximillion"
	
/obj/item/borg/chassis_mod/service/waiterbot
	name = "Service Chassis: Waiter"
	module_type = /obj/item/weapon/robot_module/butler
	chassis_type = "Service2"
	
/obj/item/borg/chassis_mod/mining/standingsteve
	name = "Mining Chassis: Standing Steve"
	module_type = /obj/item/weapon/robot_module/miner
	chassis_type = "Service2"	
	
/obj/item/borg/chassis_mod/mining/minerbipedal
	name = "Mining Chassis: Bipedal Miner"
	module_type = /obj/item/weapon/robot_module/miner
	chassis_type = "Miner_old"	
	
/obj/item/borg/chassis_mod/mining/advancedminer
	name = "Mining Chassis: Advanced Miner"
	module_type = /obj/item/weapon/robot_module/miner
	chassis_type = "droid-miner"	
	
/obj/item/borg/chassis_mod/mining/treadhead
	name = "Mining Chassis: Treadhead Miner"
	module_type = /obj/item/weapon/robot_module/miner
	chassis_type = "Miner"	
	
/obj/item/borg/chassis_mod/medical/bipedmedic
	name = "Medical Chassis: Bipedal Medical Cyborg"
	module_type = /obj/item/weapon/robot_module/medical
	chassis_type = "Medbot"	

/obj/item/borg/chassis_mod/medical/surgicalbot
	name = "Medical Chassis: Surgical Cyborg"
	module_type = /obj/item/weapon/robot_module/medical
	chassis_type = "Medbot"	
	
/obj/item/borg/chassis_mod/medical/advancedmedic
	name = "Medical Chassis: Advanced Medical Cyborg"
	module_type = /obj/item/weapon/robot_module/medical
	chassis_type = "droid-medical"	
	
/obj/item/borg/chassis_mod/medical/doctorneedles
	name = "Medical Chassis: Doctor Needles"
	module_type = /obj/item/weapon/robot_module/medical
	chassis_type = "medicalrobot"
	
/obj/item/borg/chassis_mod/security/bipedalsecurity
	name = "Security Chassis: Bipedal Security Cyborg"
	module_type = /obj/item/weapon/robot_module/security
	chassis_type = "secborg"
	
/obj/item/borg/chassis_mod/security/redknight
	name = "Security Chassis: Red Knight Cyborg Model"
	module_type = /obj/item/weapon/robot_module/security
	chassis_type = "Security"

/obj/item/borg/chassis_mod/security/protector
	name = "Security Chassis: Protector Cyborg Model"
	module_type = /obj/item/weapon/robot_module/security
	chassis_type = "securityrobot"
	
/obj/item/borg/chassis_mod/security/bloodhound
	name = "Security Chassis: Bloodhound Cyborg Model"
	module_type = /obj/item/weapon/robot_module/security
	chassis_type = "bloodhound"
	
/obj/item/borg/chassis_mod/engineering/bipedalengineer
	name = "Engineering Chassis: Bipedal Engineering Cyborg"
	module_type = /obj/item/weapon/robot_module/engineering
	chassis_type = "Engineering"
	
/obj/item/borg/chassis_mod/engineering/antique
	name = "Engineering Chassis: Outdated Engineer"
	module_type = /obj/item/weapon/robot_module/engineering
	chassis_type = "engineerrobot"
	
/obj/item/borg/chassis_mod/engineering/landmate
	name = "Engineering Chassis: Landmate Model"
	module_type = /obj/item/weapon/robot_module/engineering
	chassis_type = "landmate"
	
/obj/item/borg/chassis_mod/janitor/bipedaljanitor
	name = "Janitor Chassis: Bipedal Janitor Cyborg"
	module_type = /obj/item/weapon/robot_module/janitor
	chassis_type = "JanBot2"
	
/obj/item/borg/chassis_mod/janitor/buckethead
	name = "Janitor Chassis: Bucket-head Janitor"
	module_type = /obj/item/weapon/robot_module/janitor
	chassis_type = "janitorrobot"
	
/obj/item/borg/chassis_mod/janitor/mopgearrex
	name = "Janitor Chassis: MOP GEAR R.E.X"
	module_type = /obj/item/weapon/robot_module/janitor
	chassis_type = "mopgearrex"
	
/obj/item/borg/module_chip
	name = "cyborg module."
	desc = "Contains tools and objects that a cyborg can access."
	icon = 'icons/obj/module.dmi'
	icon_state = "cyborg_upgrade3"
	var/installed = 0
	var/module_type = null
	var/default_icon = null
	var/obj/item/weapon/robot_module/stored_module = null // used when the module gets unloaded and reloaded, preserving a single instance of /robot_module/ per chip each round

/obj/item/borg/module_chip/proc/action(mob/living/silicon/robot/R)
	if(R.installed_module && istype(R.installed_module, /obj/item/borg/module_chip))
		to_chat(R, "Module mounting error! Module slot already filled!")
		to_chat(usr, "There's already an installed module!")
		return 0	
	R.installed_module = src
	installed = 1
	return 1
	
/obj/item/borg/module_chip/medical
	name = "Medical Module."
	desc = "Contains tools and supplies for a medical cyborg."
	module_type = /obj/item/weapon/robot_module/medical
	default_icon = "robotMedi"
/obj/item/borg/module_chip/security
	name = "Security Module."
	desc = "Contains tools and supplies for a security cyborg."
	module_type = /obj/item/weapon/robot_module/security
	default_icon = "robotSecy"
/obj/item/borg/module_chip/service
	name = "Service Module."
	desc = "Contains tools and supplies for a service cyborg."
	module_type = /obj/item/weapon/robot_module/butler
	default_icon = "robotServ"
/obj/item/borg/module_chip/mining
	name = "Mining Module."
	desc = "Contains tools and supplies for a mining cyborg."
	module_type = /obj/item/weapon/robot_module/miner
	default_icon = "robotMine"
/obj/item/borg/module_chip/engineering
	name = "Engineering Module."
	desc = "Contains tools and supplies for an engineering cyborg."
	module_type = /obj/item/weapon/robot_module/engineering
	default_icon = "robotEngi"
/obj/item/borg/module_chip/janitor
	name = "Service Module."
	desc = "Contains tools and supplies for a service cyborg."
	module_type = /obj/item/weapon/robot_module/janitor
	default_icon = "robotJani"
/obj/item/borg/upgrade
	name = "borg upgrade module."
	desc = "Protected by FRM."
	icon = 'icons/obj/module.dmi'
	icon_state = "cyborg_upgrade"
	var/locked = 0
	var/installed = 0
	var/require_module = 0
	var/module_type = null

/obj/item/borg/upgrade/proc/action(mob/living/silicon/robot/R)
	if(R.stat == DEAD)
		to_chat(usr, "<span class='notice'>[src] will not function on a deceased cyborg.</span>")
		return 1
	if(module_type && !istype(R.module, module_type))
		to_chat(R, "Upgrade mounting error!  No suitable hardpoint detected!")
		to_chat(usr, "There's no mounting point for the module!")
		return 1

/obj/item/borg/upgrade/reset
	name = "cyborg module reset board"
	desc = "Used to reset a cyborg's module. Destroys any other upgrades applied to the cyborg."
	icon_state = "cyborg_upgrade1"
	require_module = 1

/obj/item/borg/upgrade/reset/action(mob/living/silicon/robot/R)
	if(..())
		return

	R.notify_ai(2)

	R.uneq_all()
	R.hands.icon_state = "nomod"
	R.icon_state = "robot"
	qdel(R.module)
	R.module = null

	R.camera.network.Remove(list("Engineering", "Medical", "Mining Outpost"))
	R.rename_character(R.real_name, R.get_default_name("Default"))
	R.languages = list()
	R.speech_synthesizer_langs = list()

	R.update_icons()
	R.update_headlamp()

	R.speed = 0 // Remove upgrades.
	R.ionpulse = 0
	R.magpulse = 0
	R.add_language("Robot Talk", 1)

	R.status_flags |= CANPUSH

	return 1

/obj/item/borg/upgrade/rename
	name = "cyborg reclassification board"
	desc = "Used to rename a cyborg."
	icon_state = "cyborg_upgrade1"
	var/heldname = "default name"

/obj/item/borg/upgrade/rename/attack_self(mob/user)
	heldname = stripped_input(user, "Enter new robot name", "Cyborg Reclassification", heldname, MAX_NAME_LEN)

/obj/item/borg/upgrade/rename/action(var/mob/living/silicon/robot/R)
	if(..())
		return
	R.notify_ai(3, R.name, heldname)
	R.name = heldname
	R.custom_name = heldname
	//	R.real_name = heldname

	return 1

/obj/item/borg/upgrade/restart
	name = "cyborg emergency reboot module"
	desc = "Used to force a reboot of a disabled-but-repaired cyborg, bringing it back online."
	icon_state = "cyborg_upgrade1"

/obj/item/borg/upgrade/restart/action(mob/living/silicon/robot/R)
	if(R.health < 0)
		to_chat(usr, "<span class='warning'>You have to repair the cyborg before using this module!</span>")
		return 0

	if(!R.key)
		for(var/mob/dead/observer/ghost in player_list)
			if(ghost.mind && ghost.mind.current == R)
				R.key = ghost.key

	R.stat = CONSCIOUS
	dead_mob_list -= R //please never forget this ever kthx
	living_mob_list += R
	R.notify_ai(1)

	return 1


/obj/item/borg/upgrade/vtec
	name = "robotic VTEC Module"
	desc = "Used to kick in a robot's VTEC systems, increasing their speed."
	icon_state = "cyborg_upgrade2"
	require_module = 1

/obj/item/borg/upgrade/vtec/action(var/mob/living/silicon/robot/R)
	if(..())
		return
	if(R.speed < 0)
		to_chat(R, "<span class='notice'>A VTEC unit is already installed!</span>")
		to_chat(usr, "<span class='notice'>There's no room for another VTEC unit!</span>")
		return

	R.speed = -1 // Gotta go fast.

	return 1

/obj/item/borg/upgrade/disablercooler
	name = "cyborg rapid disabler cooling module"
	desc = "Used to cool a mounted disabler, increasing the potential current in it and thus its recharge rate."
	icon_state = "cyborg_upgrade3"
	require_module = 1
	module_type = /obj/item/weapon/robot_module/security

/obj/item/borg/upgrade/disablercooler/action(mob/living/silicon/robot/R)
	if(..())
		return

	var/obj/item/weapon/gun/energy/disabler/cyborg/T = locate() in R.module.modules
	if(!T)
		to_chat(usr, "<span class='notice'>There's no disabler in this unit!</span>")
		return
	if(T.charge_delay <= 2)
		to_chat(R, "<span class='notice'>A cooling unit is already installed!</span>")
		to_chat(usr, "<span class='notice'>There's no room for another cooling unit!</span>")
		return

	T.charge_delay = max(2 , T.charge_delay - 4)

	return 1

/obj/item/borg/upgrade/thrusters
	name = "ion thruster upgrade"
	desc = "A energy-operated thruster system for cyborgs."
	icon_state = "cyborg_upgrade3"

/obj/item/borg/upgrade/thrusters/action(mob/living/silicon/robot/R)
	if(..())
		return

	if(R.ionpulse)
		to_chat(usr, "<span class='notice'>This unit already has ion thrusters installed!</span>")
		return

	R.ionpulse = 1
	return 1

/obj/item/borg/upgrade/ddrill
	name = "mining cyborg diamond drill"
	desc = "A diamond drill replacement for the mining module's standard drill."
	icon_state = "cyborg_upgrade3"
	require_module = 1
	module_type = /obj/item/weapon/robot_module/miner

/obj/item/borg/upgrade/ddrill/action(mob/living/silicon/robot/R)
	if(..())
		return

	for(var/obj/item/weapon/pickaxe/drill/cyborg/D in R.module.modules)
		qdel(D)
	for(var/obj/item/weapon/shovel/S in R.module.modules)
		qdel(S)

	R.module.modules += new /obj/item/weapon/pickaxe/drill/cyborg/diamond(R.module)
	R.module.rebuild()

	return 1

/obj/item/borg/upgrade/soh
	name = "mining cyborg satchel of holding"
	desc = "A satchel of holding replacement for mining cyborg's ore satchel module."
	icon_state = "cyborg_upgrade3"
	require_module = 1
	module_type = /obj/item/weapon/robot_module/miner

/obj/item/borg/upgrade/soh/action(mob/living/silicon/robot/R)
	if(..())
		return

	for(var/obj/item/weapon/storage/bag/ore/cyborg/S in R.module.modules)
		qdel(S)

	R.module.modules += new /obj/item/weapon/storage/bag/ore/holding(R.module)
	R.module.rebuild()

	return 1

/obj/item/borg/upgrade/hyperka
	name = "mining cyborg hyper-kinetic accelerator"
	desc = "A satchel of holding replacement for mining cyborg's ore satchel module."
	icon_state = "cyborg_upgrade3"
	require_module = 1
	module_type = /obj/item/weapon/robot_module/miner

/obj/item/borg/upgrade/hyperka/action(mob/living/silicon/robot/R)
	if(..())
		return

	for(var/obj/item/weapon/gun/energy/kinetic_accelerator/cyborg/H in R.module.modules)
		qdel(H)

	R.module.modules += new /obj/item/weapon/gun/energy/kinetic_accelerator/hyper/cyborg(R.module)
	R.module.rebuild()

	return 1

/obj/item/borg/upgrade/syndicate
	name = "illegal equipment module"
	desc = "Unlocks the hidden, deadlier functions of a cyborg"
	icon_state = "cyborg_upgrade3"
	require_module = 1

/obj/item/borg/upgrade/syndicate/action(mob/living/silicon/robot/R)
	if(..())
		return

	if(R.emagged)
		return

	R.emagged = 1

	return 1

/obj/item/borg/upgrade/selfrepair
	name = "self-repair module"
	desc = "This module will repair the cyborg over time."
	icon_state = "cyborg_upgrade5"
	require_module = 1
	var/repair_amount = -1
	var/repair_tick = 1
	var/msg_cooldown = 0
	var/on = 0
	var/powercost = 10
	var/mob/living/silicon/robot/cyborg

/obj/item/borg/upgrade/selfrepair/action(mob/living/silicon/robot/R)
	if(..())
		return

	var/obj/item/borg/upgrade/selfrepair/U = locate() in R
	if(U)
		to_chat(usr, "<span class='warning'>This unit is already equipped with a self-repair module.</span>")
		return 0

	cyborg = R
	icon_state = "selfrepair_off"
	var/datum/action/A = new /datum/action/item_action/toggle(src)
	A.Grant(R)
	return 1

/obj/item/borg/upgrade/selfrepair/Destroy()
	cyborg = null
	processing_objects -= src
	on = 0
	return ..()

/obj/item/borg/upgrade/selfrepair/ui_action_click()
	on = !on
	if(on)
		to_chat(cyborg, "<span class='notice'>You activate the self-repair module.</span>")
		processing_objects |= src
	else
		to_chat(cyborg, "<span class='notice'>You deactivate the self-repair module.</span>")
		processing_objects -= src
	update_icon()

/obj/item/borg/upgrade/selfrepair/update_icon()
	if(cyborg)
		icon_state = "selfrepair_[on ? "on" : "off"]"
		for(var/X in actions)
			var/datum/action/A = X
			A.UpdateButtonIcon()
	else
		icon_state = "cyborg_upgrade5"

/obj/item/borg/upgrade/selfrepair/proc/deactivate()
	processing_objects -= src
	on = 0
	update_icon()

/obj/item/borg/upgrade/selfrepair/process()
	if(!repair_tick)
		repair_tick = 1
		return

	if(cyborg && (cyborg.stat != DEAD) && on)
		if(!cyborg.cell)
			to_chat(cyborg, "<span class='warning'>Self-repair module deactivated. Please, insert the power cell.</span>")
			deactivate()
			return

		if(cyborg.cell.charge < powercost * 2)
			to_chat(cyborg, "<span class='warning'>Self-repair module deactivated. Please recharge.</span>")
			deactivate()
			return

		if(cyborg.health < cyborg.maxHealth)
			if(cyborg.health < 0)
				repair_amount = -2.5
				powercost = 30
			else
				repair_amount = -1
				powercost = 10
			cyborg.adjustBruteLoss(repair_amount)
			cyborg.adjustFireLoss(repair_amount)
			cyborg.updatehealth()
			cyborg.cell.use(powercost)
		else
			cyborg.cell.use(5)
		repair_tick = 0

		if((world.time - 2000) > msg_cooldown )
			var/msgmode = "standby"
			if(cyborg.health < 0)
				msgmode = "critical"
			else if(cyborg.health < cyborg.maxHealth)
				msgmode = "normal"
			to_chat(cyborg, "<span class='notice'>Self-repair is active in <span class='boldnotice'>[msgmode]</span> mode.</span>")
			msg_cooldown = world.time
	else
		deactivate()