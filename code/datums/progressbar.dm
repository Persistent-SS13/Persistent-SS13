/datum/progressbar
	var/goal = 1
	var/image/bar
	var/shown = 0
	var/mob/user
	var/client/client
	var/clientless = 0
	var/atom/targ
/datum/progressbar/New(mob/User, goal_number, atom/target)
	. = ..()
	if(!istype(target))
		EXCEPTION("Invalid target given")
	if(goal_number)
		goal = goal_number
	bar = image('icons/effects/progessbar.dmi', target, "prog_bar_0")
	bar.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
	bar.pixel_y = 32
	user = User
	if(user)
		client = user.client
	else
		clientless = 1
		targ = target
		target.overlays += bar

/datum/progressbar/proc/update(progress)
//	to_chat(world, "Update [progress] - [goal] - [(progress / goal)] - [((progress / goal) * 100)] - [round(((progress / goal) * 100), 5)]")
	if((!user || !user.client) && !clientless)
		shown = 0
		return
	if((!clientless) && user.client != client)
		if(client)
			client.images -= bar
		if(user.client)
			user.client.images += bar

	progress = Clamp(progress, 0, goal)
	bar.icon_state = "prog_bar_[round(((progress / goal) * 100), 5)]"
	if(!shown && !clientless)
		user.client.images += bar
		shown = 1
	else if(targ)
		targ.overlays = list()
		targ.overlays += bar
/datum/progressbar/Destroy()
	if(client)
		client.images -= bar
	else if(clientless && targ)
		targ.overlays = list()
	qdel(bar)
	. = ..()