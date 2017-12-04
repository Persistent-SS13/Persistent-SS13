#define AUTOLATHE_MAIN_MENU       1
#define AUTOLATHE_CATEGORY_MENU   2
#define AUTOLATHE_SEARCH_MENU     3

/obj/machinery/mineral/conglo_smelter
	name = "conglo processing unit"
	desc = "It processes conglo and plasma into a variety of useful materials"
	icon_state = "conglo_smelter"
	icon = 'icons/obj/machines/mining_machines.dmi'
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
	var/list/categories = list()
	var/progress = 0
	output_dir = EAST
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
	FillCategories()
/obj/machinery/mineral/conglo_smelter/after_load()
	LinkDepartment()
	..()
/obj/machinery/mineral/conglo_smelter/proc/LinkDepartment()
	var/area/A = src.myArea
	if(istype(A, /area/quartermaster))
		linked_department = get_department_datum(CARGO)
	else
		linked_department = get_department_datum(CARGO)
	// add custom mining department code here?
/obj/machinery/mineral/conglo_smelter/proc/FillCategories()
	for(var/type in subtypesof(/datum/mineral_recipe))
		categories += new type()
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

	var/datum/browser/popup = new(user, "smelter", name, 800, 800)
	popup.set_content(dat)
	popup.open()

	return

/obj/machinery/mineral/conglo_smelter/attackby(obj/item/O, mob/user, params)
	if(busy)
		to_chat(user, "<span class=\"alert\">The smelter is busy. Please wait for completion of previous operation.</span>")
		return 1

	if(default_deconstruction_screwdriver(user, "autolathe_t", "autolathe", O))
		updateUsrDialog()
		return

	if(exchange_parts(user, O))
		return

	if(panel_open)
		if(istype(O, /obj/item/weapon/crowbar))
			default_deconstruction_crowbar(user, O)
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
	if(href_list["outputdir"])
		output_dir = text2num(href_list["outputdir"])
	if(href_list["make"])
		var/ind = href_list["make"]
		
		//multiplier checks : only stacks can have one and its value is 1, 10 ,25 or max_multiplier
		var/multiplier = text2num(href_list["multiplier"])

		if((queue.len+1)<queue_max_len)
			add_to_queue(ind,multiplier)
		else
			to_chat(usr, "\red The smelter queue is full!")
			
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

	src.updateUsrDialog()

	return
/obj/machinery/mineral/conglo_smelter/proc/add_to_queue(D,var/multiplier)
	if(!istype(queue))
		queue = list()
	queue.Add(list(list(categories[text2num(D)],multiplier)))
	return queue.len

/obj/machinery/mineral/conglo_smelter/RefreshParts()
	/**
	var/tot_rating = 0
	prod_coeff = 0
	for(var/obj/item/weapon/stock_parts/matter_bin/MB in component_parts)
		tot_rating += MB.rating
	tot_rating *= 25000
	materials.max_amount = tot_rating * 3
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		prod_coeff += M.rating - 1
	**/
/obj/machinery/mineral/conglo_smelter/proc/get_coeff(var/datum/mineral_recipe/D)
	var/coeff = prod_coeff//stacks are unaffected by production coefficient
	return coeff

/obj/machinery/mineral/conglo_smelter/proc/build_item(var/datum/mineral_recipe/D, var/multiplier)
	desc = initial(desc)+"\nIt's outputting \a [D.name]."
	var/power = max(2000, (D.conglo_required+D.plasma_required)*multiplier/5)
	if(can_build(D,multiplier))
		use_power(power)
		linked_department.conglo_amount -= D.conglo_required
		linked_department.plasma_amount -= D.plasma_required
		updateUsrDialog()
		var/obj/item/S = new D.refined_type(loc)
		sleep(10)
		if(S)
			step(S,output_dir)
	desc = initial(desc)

/obj/machinery/mineral/conglo_smelter/process()
	if(queue && queue.len)
		process_queue()
		if(icon_state != "conglo_smelter_on")
			icon_state = "conglo_smelter_on"
	else
		if(icon_state != "conglo_smelter")
			icon_state = "conglo_smelter"
		
/obj/machinery/mineral/conglo_smelter/proc/process_queue()
	var/datum/mineral_recipe/D = queue[1][1]
	var/multiplier = queue[1][2]
	if(!D)
		remove_from_queue(1)
		if(queue.len)
			return process_queue()
		else
			return
	if(stat&(NOPOWER|BROKEN))
		return 0
	if(!can_build(D,1))
		visible_message("[bicon(src)] <b>\The [src]</b> beeps, \"Not enough resources. [D.name] processing terminated.\"")
		remove_from_queue(1)
		return 0

	var/req_progress = D.time
	progress++
	if(progress >= req_progress)
		if(multiplier > 1)
			queue[1][2] = (multiplier-1)
			updateUsrDialog()
		else
			remove_from_queue(1)
		build_item(D,1)
		progress = 0		
		
	//visible_message("[bicon(src)] <b>\The [src]</b> beeps, \"Queue processing finished successfully.\"")

/obj/machinery/mineral/conglo_smelter/proc/remove_from_queue(index)
	if(!isnum(index) || !istype(queue) || (index<1 || index>queue.len))
		return 0
	queue.Cut(index,++index)
	updateUsrDialog()
	return 1

	
/obj/machinery/mineral/conglo_smelter/proc/can_build(var/datum/mineral_recipe/D,var/multiplier=1, var/temp_conglo, var/temp_plasma)
	if(!linked_department)
		return 0
	var/coeff = 1
	var/conglo_amount = linked_department.conglo_amount
	var/plasma_amount = linked_department.plasma_amount
	if(temp_conglo)
		conglo_amount = temp_conglo
	if(temp_plasma)
		plasma_amount = temp_plasma
	if(D.conglo_required && (conglo_amount < (multiplier*D.conglo_required / coeff)))
		return 0
	if(D.plasma_required && (plasma_amount < (multiplier*D.plasma_required / coeff)))
		return 0
	return 1

/obj/machinery/mineral/conglo_smelter/proc/get_processing_line()
	var/datum/mineral_recipe/D = being_built[1]
	var/multiplier = being_built[2]
	var/is_stack = (multiplier>1)
	var/output = "PROCESSING: [initial(D.name)][is_stack?" (x[multiplier])":null]"
	return output

/obj/machinery/mineral/conglo_smelter/proc/get_design_cost_as_list(var/datum/mineral_recipe/D,var/multiplier=1)
	var/list/OutputList = list(0,0)
	var/coeff = 1
	if(D.conglo_required)
		OutputList[1] = (D.conglo_required / coeff)*multiplier
	if(D.plasma_required)
		OutputList[2] = (D.plasma_required / coeff)*multiplier
	return OutputList
	
/obj/machinery/mineral/conglo_smelter/proc/get_queue()
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
		var/datum/mineral_recipe/D
		var/temp_conglo = linked_department.conglo_amount
		var/temp_plasma = linked_department.plasma_amount
		for(var/list/L in queue)
			i++
			D = L[1]
			var/multiplier = L[2]
			var/list/LL = get_design_cost_as_list(D,multiplier)
			var/is_stack = (multiplier>1)
			output += "<li[!can_build(D,multiplier,temp_conglo,temp_plasma)?" style='color: #f00;'":null]>[initial(D.name)][is_stack?" (x[multiplier])":null] - [i>1?"<a href='?src=\ref[src];queue_move=-1;index=[i]' class='arrow'>&uarr;</a>":null] [i<queue.len?"<a href='?src=\ref[src];queue_move=+1;index=[i]' class='arrow'>&darr;</a>":null] <a href='?src=\ref[src];remove_from_queue=[i]'>Remove</a></li>"
			temp_conglo = max(temp_conglo-LL[1],1)
			temp_plasma = max(temp_plasma-LL[2],1)

		output += "</ol>"
		output += "<a href='?src=\ref[src];clear_queue=1'>Clear queue</a>"
	output += "</div></td>"
	return output


/obj/machinery/mineral/conglo_smelter/proc/main_win(mob/user)
	var/dat = "<table style='width:100%'><tr>"
	dat += "<td valign='top' style='margin-right: 300px'>"
	dat += "<div class='statusDisplay'><h3>Conglo Processing Menu:</h3><br>"
	
	dat += "<b>Conglo ore:</b> [linked_department.conglo_amount] m<sup>3</sup><br>"
	dat += "<b>Plasma gas:</b> [linked_department.plasma_amount] m<sup>3</sup><br>"
	dat += "<b>Output Direction:</b> [dir2text(output_dir)]"
	dat += "<a href='?src=\ref[src];outputdir=[WEST]'>WEST</a>"
	dat += "<a href='?src=\ref[src];outputdir=[NORTH]'>NORTH</a>"
	dat += "<a href='?src=\ref[src];outputdir=[SOUTH]'>SOUTH</a>"
	dat += "<a href='?src=\ref[src];outputdir=[EAST]'>EAST</a>"
	dat += "<br>"
	dat += "<hr>"
	var/line_length = 1
	dat += "<table style='width:100%' align='center'><tr>"

	for(var/i in 1 to categories.len)
		var/datum/mineral_recipe/C = categories[i]
		dat += "<br><br>"
		if(disabled || !can_build(C))
			dat += "<span class='linkOff'>[C.name]</span>"
		else
			dat += "<a href='?src=\ref[src];make=[i];multiplier=1'>[C.name]</a>"
			
			var/max_multiplier = min(50, C.conglo_required ?round(linked_department.conglo_amount/C.conglo_required):INFINITY,C.plasma_required?round(linked_department.plasma_amount/C.plasma_required):INFINITY)
			if(max_multiplier>10 && !disabled)
				dat += " <a href='?src=\ref[src];make=[i];multiplier=10'>x10</a>"
			if(max_multiplier>25 && !disabled)
				dat += " <a href='?src=\ref[src];make=[i];multiplier=25'>x25</a>"
			if(max_multiplier > 0 && !disabled)
				dat += " <a href='?src=\ref[src];make=[i];multiplier=[max_multiplier]'>x[max_multiplier]</a>"
		dat += get_design_cost(C)
		if(line_length > 2)
			dat += "</tr><tr>"
			line_length = 1

		line_length++

	dat += "</tr></table></div>"
	dat += "</td>"
	dat += get_queue()
	dat += "</tr></table>"
	return dat
/obj/machinery/mineral/conglo_smelter/proc/get_design_cost(var/datum/mineral_recipe/D)
	var/coeff = 1
	var/dat
	if(D.conglo_required)
		dat += "[D.conglo_required / coeff]  m<sup>3</sup> Conglo"
	if(D.plasma_required)
		dat += " | [D.plasma_required / coeff] m<sup>3</sup> Plasma"
	dat += " (/ Unit)"
	return dat

/datum/mineral_recipe
	var/conglo_required = 0
	var/plasma_required = 0
	var/refined_type = null
	var/name = ""
	var/time = 3
/datum/mineral_recipe/metal
	name = "Metal Sheet"
	conglo_required = 1
	refined_type = /obj/item/stack/sheet/metal
/datum/mineral_recipe/glass
	name = "Glass Pane"
	conglo_required = 1
	refined_type = /obj/item/stack/sheet/glass
/datum/mineral_recipe/plasma
	name = "Solid Plasma Alloy"
	conglo_required = 2
	plasma_required = 4
	refined_type = /obj/item/stack/sheet/mineral/plasma
	time = 5
/datum/mineral_recipe/plasmaglass
	name = "Plasma Glass Pane"
	conglo_required = 2
	plasma_required = 3
	refined_type = /obj/item/stack/sheet/plasmaglass
	time = 4
/datum/mineral_recipe/reinforcedglass
	name = "Reinforced Glass Pane"
	conglo_required = 2
	plasma_required = 1
	refined_type = /obj/item/stack/sheet/rglass
	time = 4
/datum/mineral_recipe/plasteel
	name = "Plasteel Sheet"
	conglo_required = 3
	plasma_required = 3
	refined_type = /obj/item/stack/sheet/plasteel
	time = 4
/datum/mineral_recipe/uranium
	name = "Uranium Sheet"
	conglo_required = 3
	plasma_required = 2
	refined_type = /obj/item/stack/sheet/mineral/uranium
	time = 4
/datum/mineral_recipe/silver
	name = "Silver Bar"
	conglo_required = 2
	plasma_required = 1
	refined_type = /obj/item/stack/sheet/mineral/silver
	time = 4
/datum/mineral_recipe/gold
	name = "Gold Bar"
	conglo_required = 3
	plasma_required = 1
	refined_type = /obj/item/stack/sheet/mineral/gold
	time = 4
/datum/mineral_recipe/diamond
	name = "Refined Diamond"
	conglo_required = 3
	plasma_required = 2
	refined_type = /obj/item/stack/sheet/mineral/diamond
	time = 5