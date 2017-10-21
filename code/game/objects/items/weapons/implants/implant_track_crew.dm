/obj/item/weapon/implant/crewtracker
	name = "Employee Implant"
	desc = "Standard issue, every crewmember should have one of these."
	icon = 'icons/obj/radio.dmi'
	icon_state = "beacon"
	activated = 0
	var/id = 1
	var/tracking = 1
	var/processing = 0
	implant_loc = "brain"
/obj/item/weapon/implant/crewtracker/New()
	..()
	tracked_crewimplants += src

/obj/item/weapon/implant/crewtracker/Destroy()
	tracked_crewimplants -= src
	return ..()

/obj/item/weapon/implant/crewtracker/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b>Standard Nanotransen Employee Implant<BR>
				<b>Life:</b>Protected inside brain.<BR>
				<b>Important Notes:</b> None<BR>
				<HR>
				<b>Implant Details:</b> <BR>
				<b>Function:</b> Continuously transmits data to Centcom and the crew monitors around the station. Allows medical staff to recover your brain in most circumstances.<BR>
				<b>Special Features:</b><BR>
				<i>Neuro-Safe</i>- Specialized shell absorbs excess voltages self-destructing the chip if
				a malfunction occurs thereby securing safety of subject. The implant will melt and
				disintegrate into bio-safe elements.<BR>
				<b>Integrity:</b> N/A<HR>
				Implant Specifics:<BR>"}
	return dat


/obj/item/weapon/implant/crewtracker/implant(mob/source)
	var/obj/item/weapon/implant/imp_e = locate(src.type) in source
	if(imp_e && imp_e != src)
		src.visible_message("<span class='danger'>The implanter indicates that [source.name] already has this implant!</span>")
		return 0
	activated = 1
	if(..())
		return 1
	return 0
	
	
/obj/item/weapon/implant/crewtracker/activate()
	if(processing)
		return
	if(src && imp_in)
		processing = 1
		if(src.tracking)
			if(alert(imp_in,"Are you sure you want to disable your employee tracker implant? You will be taking your safety into your own hands!","Warning!","Yes","No") == "Yes")
				tracking = 0
				icon_state = "beacon-off"
				to_chat(imp_in,"You disable your tracking implant and will no longer appear on the crew monitor")
				var/datum/action/act = actions[1]
				act.UpdateButtonIcon()
		else
			tracking = 1
			icon_state = "beacon"
			to_chat(imp_in,"You enable your employee tracking implant, your health and location will be reported on the crew monitor.")
			var/datum/action/act = actions[1]
			act.UpdateButtonIcon()
		processing = 0
/obj/item/weapon/implanter/crewtracker
	name = "implanter (employee implant)"

/obj/item/weapon/implanter/crewtracker/New()
	if (!imp)
		imp = new /obj/item/weapon/implant/crewtracker(src)
	..()