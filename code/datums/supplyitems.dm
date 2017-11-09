//SUPPLY PACKS
//NOTE: only secure crate types use the access var (and are lockable)
//NOTE: hidden packs only show up when the computer has been hacked.
//ANOTHER NOTE: Contraband is obtainable through modified supplycomp circuitboards.
//BIG NOTE: Don't add living things to crates, that's bad, it will break the shuttle.
//NEW NOTE: Do NOT set the price of any crates below 7 points. Doing so allows infinite points.

// Supply Groups
//	var/const/supply_emergency 	= 1
//	var/const/supply_security 	= 2
//	var/const/supply_engineer	= 3
//	var/const/supply_medical	= 4
//	var/const/supply_science	= 5
//	var/const/supply_organic	= 6
//	var/const/supply_materials 	= 7
//	var/const/supply_misc		= 8
//	var/const/supply_vend		= 9

var/const/supply_profession = 1
var/const/supply_clothing = 2
var/const/supply_
var/list/all_supply_lists = list(supply_profession, supply_clothing, )

/proc/get_supply_lists_name(var/cat)
	switch(cat)
		if(1)
			return "Job Equipment Packs"
		if(2)
			return "Clothing"
		if(3)
			return "Engineering"
		if(4)
			return "Medical"
		if(5)
			return "Science"
		if(6)
			return "Food and Livestock"
		if(7)
			return "Raw Materials"
		if(8)
			return "Miscellaneous"
		if(9)
			return "Vending"

/datum/supply_item // A REWORK OF SUPPLY PACKS THAT SPECALIZE IN HAVING VERY FEW ITEMS
	var/name = null
	var/list/contains = list()
	var/manifest = ""
	var/amount = null
	var/cost = null
	var/containertype = /obj/structure/closet/crate
	var/containername = null
	var/access = null
	var/hidden = 0
	var/contraband = 0
	var/group = supply_misc
	var/list/announce_beacons = list() // Particular beacons that we'll notify the relevant department when we reach
	var/personal = 1 // THIS LOCKS CRATES SO THAT ONLY THE ORDERER CAN OPEN THEM
	var/desc = ""
	var/list/authentication = list()
/datum/supply_item/New()
	manifest += "<ul>"
	for(var/path in contains)
		if(!path)	continue
		var/atom/movable/AM = path
		manifest += "<li>[initial(AM.name)]</li>"
	manifest += "</ul>"

////// Use the sections to keep things tidy please /Malkevin

//////////////////////////////////////////////////////////////////////////////
//////////////////////////// JOB EQUIPMENT CRATES ///////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_item/profession	// Section header - use these to set default supply group and crate type for sections
	name = "HEADER"				// Use "HEADER" to denote section headers, this is needed for the supply computers to filter them
	containertype = /obj/structure/closet/crate/internals
	group = 1


/datum/supply_item/profession/engineering
	name = "Engineering Trainee Equipment"
	contains = list(/obj/item/clothing/head/hardhat,
					/obj/item/clothing/under/rank/engineer,
					/obj/item/clothing/shoes/workboots,
					/obj/item/weapon/storage/belt/utility/full,
					/obj/item/weapon/storage/backpack/industrial,
					/obj/item/device/radio/headset/headset_eng) // /obj/item/weapon/cartidge/engineering
	cost = 150
	containertype = /obj/structure/closet/crate/secure/plasma
	containername = "Engineering Trainee Equipment"
	desc = "Everything an Engineer Trainee needs."
	authentication = list("chief", "captain", "hop")
/datum/supply_item/profession/cargo
	name = "Cargo Rookie Equipment"
	contains = list(/obj/item/clothing/under/rank/cargotech,
					/obj/item/device/radio/headset/headset_cargo) // /obj/item/weapon/cartidge/engineering
	cost = 50
	containertype = /obj/structure/closet/crate/secure/plasma
	containername = "Cargo Rookie Equipment"
	desc = "Everything a Cargo Rookie needs."
	authentication = list("quartermaster", "captain", "hop")
/datum/supply_item/profession/miner
	name = "Shaft Miner Equipment"
	contains = list(/obj/item/clothing/under/rank/miner,
					/obj/item/clothing/shoes/workboots,
					/obj/item/weapon/storage/belt/utility/full,
					/obj/item/weapon/storage/backpack/industrial,
					/obj/item/device/flashlight/lantern,
					/obj/item/device/radio/headset/headset_cargo) // /obj/item/weapon/cartidge/engineering
	cost = 150
	containertype = /obj/structure/closet/crate/secure/plasma
	containername = "Shaft Miner Equipment"
	desc = "Basic Shaft Miner equipment."
	authentication = list("quartermaster", "captain", "hop")
/datum/supply_item/profession/security
	name = "Security Cadet Equipment"
	contains = list(/obj/item/weapon/melee/baton, 
					/obj/item/clothing/under/rank/security,
					/obj/item/clothing/shoes/jackboots,
					/obj/item/weapon/storage/backpack/security,
					/obj/item/weapon/stock_parts/cell/crap,
					/obj/item/device/radio/headset/headset_sec) // /obj/item/weapon/cartidge/engineering
	cost = 300
	containertype = /obj/structure/closet/crate/secure/plasma
	containername = "Security Cadet Equipment"
	desc = "Everything a Security Cadet needs."
	authentication = list("hos", "captain", "hop")
/datum/supply_item/profession/medical
	name = "Medical Intern Equipment"
	contains = list(/obj/item/clothing/under/rank/medical,
					/obj/item/clothing/mask/surgical,
					/obj/item/weapon/storage/backpack/medic,
					/obj/item/device/radio/headset/headset_med) // /obj/item/weapon/cartidge/engineering
	cost = 125
	containertype = /obj/structure/closet/crate/secure/plasma
	containername = "Medical Intern Equipment"
	desc = "Everything a Medical Intern needs."
	authentication = list("cmo", "captain", "hop")
/datum/supply_item/profession/science
	name = "Science Intern Equipment"
	contains = list(/obj/item/clothing/under/rank/scientist,
					/obj/item/weapon/storage/backpack/science,
					/obj/item/device/radio/headset/headset_sci) // /obj/item/weapon/cartidge/engineering
	cost = 100
	containertype = /obj/structure/closet/crate/secure/plasma
	containername = "Science Intern Equipment"
	desc = "Everything a Science Intern needs."
	authentication = list("rd", "captain", "hop")

/datum/supply_item/clothing	// Section header - use these to set default supply group and crate type for sections
	name = "HEADER"				// Use "HEADER" to denote section headers, this is needed for the supply computers to filter them
	containertype = /obj/structure/closet/crate/secure/plasma
	group = 2

	