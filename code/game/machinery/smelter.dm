#define AUTOLATHE_MAIN_MENU       1
#define AUTOLATHE_CATEGORY_MENU   2
#define AUTOLATHE_SEARCH_MENU     3

/obj/machinery/mineral/conglo_smelter
	name = "conglo processing unit"
	desc = "It processes conglo and plasma into a variety of useful materials"
	icon_state = "autol"
	density = 1

	var/operating = 0.0
	var/list/queue = list()
	var/queue_max_len = 12
	var/turf/BuildTurf
	anchored = 1.0
	var/list/L = list()
	var/list/LL = list()
	var/hacked = 0
	var/disabled = 0
	var/shocked = 0
	var/hack_wire
	var/disable_wire
	var/shock_wire
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 100
	var/busy = 0
	var/prod_coeff
	var/list/being_built = list()
	var/datum/department/linked_department
	
/obj/machinery/mineral/conglo_smelter/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/autolathe(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	RefreshParts()
	LinkDepartment()
/obj/machinery/mineral/mineral_depository/proc/LinkDepartment()
	var/area/A = src.myArea
	if(istype(A, /area/quartermaster))
		linked_department = get_department_datum(CARGO)
	// add custom mining department code here?
	
/obj/machinery/mineral/conglo_smelter/Destroy()
	return ..()

/obj/machinery/mineral/conglo_smelter/interact(mob/user)
	if(shocked && !(stat & NOPOWER))
		shock(user,50)

	user.set_machine(src)
	var/dat

	if(panel_open)
	
	else
		dat = main_win(user)

	var/datum/browser/popup = new(user, "smelter", name, 800, 500)
	popup.set_content(dat)
	popup.open()

	return

/obj/machinery/mineral/conglo_smelter/attackby(obj/item/O, mob/user, params)
	if(busy)
		to_chat(user, "<span class=\"alert\">The autolathe is busy. Please wait for completion of previous operation.</span>")
		return 1

	if(default_deconstruction_screwdriver(user, "autolathe_t", "autolathe", O))
		updateUsrDialog()
		return

	if(exchange_parts(user, O))
		return

	if(panel_open)
		if(istype(O, /obj/item/weapon/crowbar))
			default_deconstruction_crowbar(O)
			return 1
		else
			attack_hand(user)
			return 1
	if(stat)
		return 1
	src.updateUsrDialog()

/obj/machinery/mineral/conglo_smelter/attack_ghost(mob/user)
	interact(user)

/obj/machinery/mineral/conglo_smelter/attack_hand(mob/user)
	if(..(user, 0))
		return
	interact(user)

/obj/machinery/mineral/conglo_smelter/Topic(href, href_list)
	if(..())
		return 1

	if(href_list["menu"])
		screen = text2num(href_list["menu"])

	if(href_list["category"])
		selected_category = href_list["category"]

	if(href_list["make"])
		BuildTurf = loc

		/////////////////
		//href protection
		var/datum/design/design_last_ordered
		design_last_ordered = files.FindDesignByID(href_list["make"]) //check if it's a valid design
		if(!design_last_ordered)
			return
		if(!(design_last_ordered.build_type & AUTOLATHE))
			return

		//multiplier checks : only stacks can have one and its value is 1, 10 ,25 or max_multiplier
		var/multiplier = text2num(href_list["multiplier"])
		var/max_multiplier = min(design_last_ordered.maxstack, design_last_ordered.materials[MAT_METAL] ?round(materials.amount(MAT_METAL)/design_last_ordered.materials[MAT_METAL]):INFINITY,design_last_ordered.materials[MAT_GLASS]?round(materials.amount(MAT_GLASS)/design_last_ordered.materials[MAT_GLASS]):INFINITY)
		var/is_stack = ispath(design_last_ordered.build_path, /obj/item/stack)

		if(!is_stack && (multiplier > 1))
			return
		if(!(multiplier in list(1,10,25,max_multiplier))) //"enough materials ?" is checked in the build proc
			return
		/////////////////

		if((queue.len+1)<queue_max_len)
			add_to_queue(design_last_ordered,multiplier)
		else
			to_chat(usr, "\red The autolathe queue is full!")
		if(!busy)
			busy = 1
			process_queue()
			busy = 0

	if(href_list["remove_from_queue"])
		var/index = text2num(href_list["remove_from_queue"])
		if(isnum(index) && IsInRange(index,1,queue.len))
			remove_from_queue(index)
	if(href_list["queue_move"] && href_list["index"])
		var/index = text2num(href_list["index"])
		var/new_index = index + text2num(href_list["queue_move"])
		if(isnum(index) && isnum(new_index))
			if(IsInRange(new_index,1,queue.len))
				queue.Swap(index,new_index)
	if(href_list["clear_queue"])
		queue = list()
	if(href_list["search"])
		matching_designs.Cut()

		for(var/datum/design/D in files.known_designs)
			if(findtext(D.name,href_list["to_search"]))
				matching_designs.Add(D)


	src.updateUsrDialog()

	return

/obj/machinery/mineral/conglo_smelter/RefreshParts()
	var/tot_rating = 0
	prod_coeff = 0
	for(var/obj/item/weapon/stock_parts/matter_bin/MB in component_parts)
		tot_rating += MB.rating
	tot_rating *= 25000
	materials.max_amount = tot_rating * 3
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		prod_coeff += M.rating - 1

/obj/machinery/mineral/conglo_smelter/proc/get_coeff(var/datum/design/D)
	var/coeff = (ispath(D.build_path,/obj/item/stack) ? 1 : 2 ** prod_coeff)//stacks are unaffected by production coefficient
	return coeff

/obj/machinery/mineral/conglo_smelter/proc/build_item(var/datum/design/D, var/multiplier)
	desc = initial(desc)+"\nIt's building \a [initial(D.name)]."
	var/is_stack = ispath(D.build_path, /obj/item/stack)
	var/coeff = get_coeff(D)
	var/metal_cost = D.materials[MAT_METAL]
	var/glass_cost = D.materials[MAT_GLASS]
	var/power = max(2000, (metal_cost+glass_cost)*multiplier/5)
	if(can_build(D,multiplier))
		being_built = list(D,multiplier)
		use_power(power)
		icon_state = "autolathe"
		flick("autolathe_n",src)
		if(is_stack)
			var/list/materials_used = list(MAT_METAL=metal_cost*multiplier, MAT_GLASS=glass_cost*multiplier)
			materials.use_amount(materials_used)
		else
			var/list/materials_used = list(MAT_METAL=metal_cost/coeff, MAT_GLASS=glass_cost/coeff)
			materials.use_amount(materials_used)
		updateUsrDialog()
		sleep(32/coeff)
		if(is_stack)
			var/obj/item/stack/S = new D.build_path(BuildTurf)
			S.amount = multiplier
		else
			var/obj/item/new_item = new D.build_path(BuildTurf)
			new_item.materials[MAT_METAL] /= coeff
			new_item.materials[MAT_GLASS] /= coeff
	updateUsrDialog()
	desc = initial(desc)

/obj/machinery/mineral/conglo_smelter/can_build(var/datum/design/D,var/multiplier=1,var/custom_metal,var/custom_glass)
	var/coeff = get_coeff(D)

	var/metal_amount = materials.amount(MAT_METAL)
	if(custom_metal)
		metal_amount = custom_metal
	var/glass_amount = materials.amount(MAT_GLASS)
	if(custom_glass)
		glass_amount = custom_glass

	if(D.materials[MAT_METAL] && (metal_amount < (multiplier*D.materials[MAT_METAL] / coeff)))
		return 0
	if(D.materials[MAT_GLASS] && (glass_amount < (multiplier*D.materials[MAT_GLASS] / coeff)))
		return 0
	return 1

/obj/machinery/autolathe/proc/get_design_cost_as_list(var/datum/design/D,var/multiplier=1)
	var/list/OutputList = list(0,0)
	var/coeff = get_coeff(D)
	if(D.materials[MAT_METAL])
		OutputList[1] = (D.materials[MAT_METAL] / coeff)*multiplier
	if(D.materials[MAT_GLASS])
		OutputList[2] = (D.materials[MAT_GLASS] / coeff)*multiplier
	return OutputList

/obj/machinery/autolathe/proc/get_processing_line()
	var/datum/design/D = being_built[1]
	var/multiplier = being_built[2]
	var/is_stack = (multiplier>1)
	var/output = "PROCESSING: [initial(D.name)][is_stack?" (x[multiplier])":null]"
	return output

/obj/machinery/autolathe/proc/get_queue()
	var/temp_metal = materials.amount(MAT_METAL)
	var/temp_glass = materials.amount(MAT_GLASS)
	var/output = "<td valign='top' style='width: 300px'>"
	output += "<div class='statusDisplay'>"
	output += "<b>Queue contains:</b>"
	if(!istype(queue) || !queue.len)
		if(being_built.len)
			output += "<ol><li>"
			output += get_processing_line()
			output += "</li></ol>"
		else
			output += "<br>Nothing"
	else
		output += "<ol>"
		if(being_built.len)
			output += "<li>"
			output += get_processing_line()
			output += "</li>"
		var/i = 0
		var/datum/design/D
		for(var/list/L in queue)
			i++
			D = L[1]
			var/multiplier = L[2]
			var/list/LL = get_design_cost_as_list(D,multiplier)
			var/is_stack = (multiplier>1)
			output += "<li[!can_build(D,multiplier,temp_metal,temp_glass)?" style='color: #f00;'":null]>[initial(D.name)][is_stack?" (x[multiplier])":null] - [i>1?"<a href='?src=\ref[src];queue_move=-1;index=[i]' class='arrow'>&uarr;</a>":null] [i<queue.len?"<a href='?src=\ref[src];queue_move=+1;index=[i]' class='arrow'>&darr;</a>":null] <a href='?src=\ref[src];remove_from_queue=[i]'>Remove</a></li>"
			temp_metal = max(temp_metal-LL[1],1)
			temp_glass = max(temp_glass-LL[2],1)

		output += "</ol>"
		output += "<a href='?src=\ref[src];clear_queue=1'>Clear queue</a>"
	output += "</div></td>"
	return output

/obj/machinery/autolathe/proc/add_to_queue(D,var/multiplier)
	if(!istype(queue))
		queue = list()
	if(D)
		queue.Add(list(list(D,multiplier)))
	return queue.len

/obj/machinery/autolathe/proc/remove_from_queue(index)
	if(!isnum(index) || !istype(queue) || (index<1 || index>queue.len))
		return 0
	queue.Cut(index,++index)
	return 1

/obj/machinery/autolathe/proc/process_queue()
	var/datum/design/D = queue[1][1]
	var/multiplier = queue[1][2]
	if(!D)
		remove_from_queue(1)
		if(queue.len)
			return process_queue()
		else
			return
	while(D)
		if(stat&(NOPOWER|BROKEN))
			being_built = new /list()
			return 0
		if(!can_build(D,multiplier))
			visible_message("[bicon(src)] <b>\The [src]</b> beeps, \"Not enough resources. Queue processing terminated.\"")
			queue = list()
			being_built = new /list()
			return 0

		remove_from_queue(1)
		build_item(D,multiplier)
		D = listgetindex(listgetindex(queue, 1),1)
		multiplier = listgetindex(listgetindex(queue,1),2)
	being_built = new /list()
	//visible_message("[bicon(src)] <b>\The [src]</b> beeps, \"Queue processing finished successfully.\"")

/obj/machinery/mineral/conglo_smelter/proc/main_win(mob/user)
	var/dat = "<table style='width:100%'><tr>"
	dat += "<td valign='top' style='margin-right: 300px'>"
	dat += "<div class='statusDisplay'><h3>Conglo Smelter Menu:</h3><br>"
	dat += "<b>Conglo amount:</b> [linked_department.conglo_amount] cm<sup>3</sup><br>"
	dat += "<b>Plasma amount:</b> [linked_department.plama_amount] cm<sup>3</sup><br>"

	var/line_length = 1
	dat += "<table style='width:100%' align='center'><tr>"

	for(var/C in categories)
		if(line_length > 2
			dat += "</tr><tr>"
			line_length = 1

		dat += "<td><A href='?src=\ref[src];category=[C];menu=[AUTOLATHE_CATEGORY_MENU]'>[C]</A></td>"
		line_length++

	dat += "</tr></table></div>"
	dat += "</td>"
	dat += get_queue()
	dat += "</tr></table>"
	return dat


/obj/machinery/autolathe/proc/get_design_cost(var/datum/design/D)
	var/coeff = get_coeff(D)
	var/dat
	if(D.materials[MAT_METAL])
		dat += "[D.materials[MAT_METAL] / coeff] metal "
	if(D.materials[MAT_GLASS])
		dat += "[D.materials[MAT_GLASS] / coeff] glass "
	return dat

/obj/machinery/autolathe/proc/adjust_hacked(var/hack)
	hacked = hack

	if(hack)
		for(var/datum/design/D in files.possible_designs)
			if((D.build_type & AUTOLATHE) && ("hacked" in D.category))
				files.known_designs += D
	else
		for(var/datum/design/D in files.known_designs)
			if("hacked" in D.category)
				files.known_designs -= D
/datum/mineral_recipe
	var/conglo_required = 0
	var/plasma_required = 0
	var/refined_type = null
/datum/mineral_recipe/