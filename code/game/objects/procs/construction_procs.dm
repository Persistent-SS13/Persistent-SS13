/*
Stats are:

STAT_GRIT = 1
STAT_FORTITUDE = 2
STAT_REFLEX = 3
STAT_CREATIVITY = 4
STAT_FOCUS = 5
*/

/obj/proc/actWrench(mob/user, obj/item/weapon/wrench/W, time = 20, skill = 0, message)
	if(istype(W))
		playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
		if(skill == 0)
			if(message)
				to_chat(user, "span class='notice'>[message]</span>")
			if(do_after(user, time, target = src))
				return 1
		else
			if(message)
				to_chat(user, "span class='notice'>[message]</span>")
			switch(do_after_stat(user, time, target = src, stat_used = skill))
				if(1)
					return 1
				if(2)
					to_chat(user, "<span class='notice'>You are not skilled enough to do this.</span>")

/obj/proc/actScrewdriver(mob/user, obj/item/weapon/screwdriver/W, time = 20, skill = 0, message)
	if(istype(W))
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
		if(skill == 0)
			if(message)
				to_chat(user, "span class='notice'>[message]</span>")
			if(do_after(user, time, target = src))
				return 1
		else
			if(message)
				to_chat(user, "span class='notice'>[message]</span>")
			switch(do_after_stat(user, time, target = src, stat_used = skill))
				if(1)
					return 1
				if(2)
					to_chat(user, "<span class='notice'>You are not skilled enough to do this.</span>")

/obj/proc/actCrowbar(mob/user, obj/item/weapon/crowbar/W, time = 20, skill = 0, message)
	if(istype(W))
		playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
		if(skill == 0)
			if(message)
				to_chat(user, "<span class='notice'>[message]</span>")
			if(do_after(user, time, target = src))
				return 1
		else
			if(message)
				to_chat(user, "<span class='notice'>[message]</span>")
			switch(do_after_stat(user, time, target = src, stat_used = skill))
				if(1)
					return 1
				if(2)
					to_chat(user, "<span class='notice'>You are not skilled enough to do this.</span>")

/obj/proc/actWirecutter(mob/user, obj/item/weapon/wirecutters/W, time = 20, skill = 0, message)
	if(istype(W))
		playsound(src.loc, 'sound/items/Wirecutter.ogg', 50, 1)
		if(skill == 0)
			if(message)
				to_chat(user, "span class='notice'>[message]</span>")
			if(do_after(user, time, target = src))
				return 1
		else
			if(message)
				to_chat(user, "span class='notice'>[message]</span>")
			switch(do_after_stat(user, time, target = src, stat_used = skill))
				if(1)
					return 1
				if(2)
					to_chat(user, "<span class='notice'>You are not skilled enough to do this.</span>")

/obj/proc/actWire(mob/user, obj/item/stack/cable_coil/W, time = 20, skill = 0, message)
	if(istype(W))
		playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
		if(skill == 0)
			if(message)
				to_chat(user, "span class='notice'>[message]</span>")
			if(do_after(user, time, target = src))
				return 1
		else
			if(message)
				to_chat(user, "span class='notice'>[message]</span>")
			switch(do_after_stat(user, time, target = src, stat_used = skill))
				if(1)
					return 1
				if(2)
					to_chat(user, "<span class='notice'>You are not skilled enough to do this.</span>")

/obj/proc/actWeld(mob/user, obj/item/weapon/weldingtool/W, time = 20, skill = 5, message = "You start welding \the [name].")
	if(istype(W))
		if(W.remove_fuel(0,user))
			playsound(src.loc, 'sound/items/Welder2.ogg', 50, 1)
			if(time && message)
				to_chat(user, "<span class='notice'>[message]</span>")
			if(skill == 0)
				if(do_after(user, time, target = src))
					return 1
			else
				switch(do_after_stat(user, time, target = src, stat_used = skill))
					if(1)
						return 1
					if(2)
						to_chat(user, "<span class='notice'>You are not skilled enough to do this.</span>")

/obj/proc/fastenWrench(mob/user, obj/item/weapon/wrench/W, time = 20, skill = 3)
	if(istype(W))
		if(skill == 0)
			if(time)
				to_chat(user, "<span class='notice'>Now [anchored ? "un" : ""]securing [name].</span>")
				playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
			if(do_after(user, time, target = src))
				to_chat(user, "<span class='notice'>You've [anchored ? "un" : ""]secured [name].</span>")
				anchored = !anchored
				playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
				return 1

		else
			if(time)
				to_chat(user, "<span class='notice'>Now [anchored ? "un" : ""]securing [name].</span>")
				playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
			switch(do_after_stat(user, time, target = src, stat_used = skill))
				if(1)
					to_chat(user, "<span class='notice'>You've [anchored ? "un" : ""]secured [name].</span>")
					anchored = !anchored
					playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
					return 1
				if(2)
					to_chat(user, "<span class='notice'>You dont have good enough reflexes to anchor this.</span>")

/obj/proc/dirFastenWrench(mob/user, obj/item/weapon/wrench/W, time = 20, skill = 3)
	if(istype(W))
		if(!anchored)
			dir = text2dir(input(user, "Select direction.", "Direction", "South") in list( "NORTH", "SOUTH", "EAST", "WEST"))
		if(skill == 0)
			if(time)
				to_chat(user, "<span class='notice'>Now [anchored ? "un" : ""]securing [name].</span>")
				playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
			if(do_after(user, time, target = src))
				to_chat(user, "<span class='notice'>You've [anchored ? "un" : ""]secured [name].</span>")
				anchored = !anchored
				playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
				return 1

		else
			if(time)
				to_chat(user, "<span class='notice'>Now [anchored ? "un" : ""]securing [name].</span>")
				playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
			switch(do_after_stat(user, time, target = src, stat_used = skill))
				if(1)
					to_chat(user, "<span class='notice'>You've [anchored ? "un" : ""]secured [name].</span>")
					anchored = !anchored
					playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
					return 1
				if(2)
					to_chat(user, "<span class='notice'>You dont have good enough reflexes to anchor this.</span>")

