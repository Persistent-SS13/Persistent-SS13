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

// Easy format for cargo list
// containername = [] sets a name for your container, which is not needed most of the time because items already come with a default "containername" defined in the item's header, while containertype = [] sets the type of container, which also tends to be defined in the item's header
// count = [] will set the amount of sheets/items if the object is stackable
// The variables above can be put directly into the following fromat if the object(s) being ordered require it
// 
// Format below:
//  /datum/supply_item//
//	    name = ""
//	    contains = list()
//	    cost = 100
//	    desc = "."
// 
// Example, explanations in [brackets]:
//  /datum/supply_item/materials [the category this cargo order is under]/metal [this bit here does not matter, just give it a normal name with no spaces]
//	    name = "Metal" [name that shows up in the cargo menu]
//	    contains = list(/obj/item/stack/sheet/metal) [the object being ordered, can be found by right-clicking on an object, clicking "variables", the path will be in the upper right corner]
//	    amount = 50 [how many items, only works if item is stackable, if you are ordering multiple items that are not stackable, look at the next example]
//	    cost = 200 [price]
//	    containertype = /obj/structure/closet/crate/secure/large [type of container, preferably one under /secure/ so it can be locked]
//	    desc = "50 sheets of metal." [description shown in the cargo menu]
//
// Example for ordering multiple items:
//  /datum/supply_item/engineering/solars
//	    name = "Solar Panel Crate"
//	    contains = list(/obj/item/solar_assembly,
//					    /obj/item/solar_assembly,
//					    /obj/item/solar_assembly,
//					    /obj/item/solar_assembly,
//					    /obj/item/solar_assembly,
//					    /obj/item/solar_assembly)
//	    cost = 200
//	    desc = "5 solar panels."
//
// As shown above, to order multiple items, just leave a comma at the end of each object being ordered and press "enter", last object should end in a ")"
// The objects do not have to be the same, you can order different items under one cargo order, as long as the requirements I said above are met

var/const/supply_profession = 1
var/const/supply_headgear = 2
var/const/supply_clothing = 3
var/const/supply_accessories = 4
var/const/supply_robotics = 5
var/const/supply_department = 6
var/const/supply_materials = 7
var/const/supply_engineering = 8
var/const/supply_misc = 9
var/list/all_supply_lists = list(supply_profession, supply_headgear, supply_clothing, supply_accessories, supply_robotics, supply_department, supply_engineering, supply_materials, supply_misc)

/proc/get_supply_lists_name(var/cat)
	switch(cat)
		if(1)
			return "Job Equipment Packs"
		if(2)
			return "Headgear"
		if(3)
			return "Clothing"
		if(4)
			return "Shoes & Accessories"
		if(5)
			return "Robotics"
		if(6)
			return "Department Supplies"
		if(7)
			return "Refined Materials"
		if(8)
			return "Engineering"
		if(9)
			return "Miscellaneous"

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
	containertype = /obj/structure/closet/secure_closet/engineering_personal
	containername = "Engineering Trainee Equipment"
	desc = "Everything an Engineering Trainee needs."
	authentication = list("chief", "captain", "hop")
/datum/supply_item/profession/engineeringfemale
	name = "Engineering Trainee Equipment - Female"
	contains = list(/obj/item/clothing/head/hardhat,
					/obj/item/clothing/under/rank/engineer/skirt,
					/obj/item/clothing/shoes/workboots,
					/obj/item/weapon/storage/belt/utility/full,
					/obj/item/weapon/storage/backpack/industrial,
					/obj/item/device/radio/headset/headset_eng) // /obj/item/weapon/cartidge/engineering
	cost = 150
	containertype = /obj/structure/closet/secure_closet/engineering_personal
	containername = "Engineering Trainee Equipment"
	desc = "Everything an Engineering Trainee needs."
	authentication = list("chief", "captain", "hop")
/datum/supply_item/profession/atmostech
	name = "Atmospheric Technician Equipment"
	contains = list(/obj/item/clothing/under/rank/atmospheric_technician,
					/obj/item/clothing/shoes/workboots,
					/obj/item/clothing/suit/hooded/wintercoat/engineering/atmos,
					/obj/item/clothing/suit/fire/atmos,
					/obj/item/clothing/head/hardhat/atmos,
					/obj/item/weapon/storage/belt/utility/atmostech,
					/obj/item/weapon/storage/backpack/industrial,
					/obj/item/device/radio/headset/headset_eng) // /obj/item/weapon/cartidge/engineering
	cost = 500
	containertype = /obj/structure/closet/secure_closet/atmos_personal
	containername = "Atmospheric Technician Equipment"
	desc = "Everything an Atmos Tech needs."
	authentication = list("chief", "captain", "hop")
/datum/supply_item/profession/atmostechfemale
	name = "Atmospheric Technician Equipment - Female"
	contains = list(/obj/item/clothing/under/rank/atmospheric_technician/skirt,
					/obj/item/clothing/shoes/workboots,
					/obj/item/clothing/suit/hooded/wintercoat/engineering/atmos,
					/obj/item/clothing/suit/fire/atmos,
					/obj/item/clothing/head/hardhat/atmos,
					/obj/item/weapon/storage/belt/utility/atmostech,
					/obj/item/weapon/storage/backpack/industrial,
					/obj/item/device/radio/headset/headset_eng) // /obj/item/weapon/cartidge/engineering
	cost = 500
	containertype = /obj/structure/closet/secure_closet/atmos_personal
	containername = "Atmospheric Technician Equipment"
	desc = "Everything an Atmos Tech needs."
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
	contains = list(/obj/item/clothing/under/rank/security,
					/obj/item/clothing/shoes/jackboots,
					/obj/item/weapon/melee/baton,
					/obj/item/weapon/stock_parts/cell/crap,
					/obj/item/weapon/restraints/handcuffs/cable/zipties,
					/obj/item/taperoll/police,
					/obj/item/weapon/book/manual/security_space_law,
					/obj/item/weapon/storage/backpack/security,
					/obj/item/device/radio/headset/headset_sec/alt) // /obj/item/weapon/cartidge/engineering
	cost = 350
	containertype = /obj/structure/closet/secure_closet/security
	containername = "Security Cadet Equipment"
	desc = "Everything a Security Cadet needs."
	authentication = list("hos", "captain", "hop")
/datum/supply_item/profession/securityfemale
	name = "Security Cadet Equipment - Female"
	contains = list(/obj/item/clothing/under/rank/security/skirt,
					/obj/item/clothing/shoes/jackboots,
					/obj/item/weapon/melee/baton,
					/obj/item/weapon/stock_parts/cell/crap,
					/obj/item/weapon/restraints/handcuffs/cable/zipties,
					/obj/item/taperoll/police,
					/obj/item/weapon/book/manual/security_space_law,
					/obj/item/weapon/storage/backpack/security,
					/obj/item/device/radio/headset/headset_sec/alt) // /obj/item/weapon/cartidge/engineering
	cost = 350
	containertype = /obj/structure/closet/secure_closet/security
	containername = "Security Cadet Equipment"
	desc = "Everything a Security Cadet needs."
	authentication = list("hos", "captain", "hop")
/datum/supply_item/profession/securityofficer
	name = "Security Officer Equipment"
	contains = list(/obj/item/clothing/under/rank/security,
					/obj/item/clothing/suit/armor/vest/security,
					/obj/item/clothing/head/helmet,
					/obj/item/clothing/glasses/hud/security,
					/obj/item/clothing/shoes/jackboots,
					/obj/item/weapon/storage/belt/security/sec,
					/obj/item/weapon/gun/energy/gun/advtaser,
					/obj/item/weapon/melee/baton/loaded,
					/obj/item/weapon/restraints/handcuffs,
					/obj/item/device/flash,
					/obj/item/weapon/reagent_containers/spray/pepper,
					/obj/item/taperoll/police,
					/obj/item/weapon/book/manual/security_space_law,
					/obj/item/weapon/storage/backpack/security,
					/obj/item/device/radio/headset/headset_sec/alt) // /obj/item/weapon/cartidge/engineering
	cost = 700
	containertype = /obj/structure/closet/secure_closet/security
	containername = "Security Officer Equipment"
	desc = "Everything a Security Officer needs."
	authentication = list("hos", "captain", "hop")
/datum/supply_item/profession/securityofficerfemale
	name = "Security Officer Equipment - Female"
	contains = list(/obj/item/clothing/under/rank/security/skirt,
					/obj/item/clothing/suit/armor/vest/security,
					/obj/item/clothing/head/helmet,
					/obj/item/clothing/glasses/hud/security,
					/obj/item/clothing/shoes/jackboots,
					/obj/item/weapon/storage/belt/security/sec,
					/obj/item/weapon/gun/energy/gun/advtaser,
					/obj/item/weapon/melee/baton/loaded,
					/obj/item/weapon/restraints/handcuffs,
					/obj/item/device/flash,
					/obj/item/weapon/reagent_containers/spray/pepper,
					/obj/item/taperoll/police,
					/obj/item/weapon/book/manual/security_space_law,
					/obj/item/weapon/storage/backpack/security,
					/obj/item/device/radio/headset/headset_sec/alt) // /obj/item/weapon/cartidge/engineering
	cost = 700
	containertype = /obj/structure/closet/secure_closet/security
	containername = "Security Officer Equipment"
	desc = "Everything a Security Officer needs."
	authentication = list("hos", "captain", "hop")
/datum/supply_item/profession/securitycorporal
	name = "Security Corporal Equipment"
	contains = list(/obj/item/clothing/under/rank/security/corp,
					/obj/item/clothing/suit/armor/vest/security,
					/obj/item/clothing/head/helmet,
					/obj/item/clothing/glasses/hud/security/sunglasses,
					/obj/item/clothing/head/beret/sec,
					/obj/item/clothing/shoes/jackboots,
					/obj/item/weapon/storage/belt/security/sec,
					/obj/item/clothing/suit/armor/secjacket,
					/obj/item/clothing/suit/hooded/wintercoat/security,
					/obj/item/weapon/gun/energy/gun/advtaser,
					/obj/item/weapon/melee/baton/loaded,
					/obj/item/weapon/stock_parts/cell,
					/obj/item/weapon/restraints/handcuffs,
					/obj/item/device/flash,
					/obj/item/weapon/reagent_containers/spray/pepper,
					/obj/item/taperoll/police,
					/obj/item/weapon/book/manual/security_space_law/black,
					/obj/item/weapon/storage/backpack/security,
					/obj/item/device/radio/headset/headset_sec) // /obj/item/weapon/cartidge/engineering
	cost = 1000
	containertype = /obj/structure/closet/secure_closet/security
	containername = "Security Corporal Equipment"
	desc = "Everything a Security Corporal needs."
	authentication = list("hos", "captain", "hop")
/datum/supply_item/profession/detective
	name = "Detective Equipment"
	contains = list(/obj/item/clothing/under/det,
					/obj/item/clothing/suit/armor/vest/det_suit,
					/obj/item/clothing/suit/storage/det_suit,
					/obj/item/clothing/head/det_hat,
					/obj/item/clothing/shoes/brown,
					/obj/item/clothing/accessory/black,
					/obj/item/clothing/accessory/holster/armpit,
					/obj/item/clothing/glasses/hud/security/sunglasses,
					/obj/item/weapon/gun/projectile/revolver/detective,
					/obj/item/weapon/restraints/handcuffs,
					/obj/item/device/detective_scanner,
					/obj/item/taperoll/police,
					/obj/item/weapon/book/manual/security_space_law,
					/obj/item/weapon/storage/backpack/security,
					/obj/item/device/radio/headset/headset_sec/alt) // /obj/item/weapon/cartidge/engineering
	cost = 700
	containertype = /obj/structure/closet/secure_closet/security
	containername = "Detective Equipment"
	desc = "Everything a Detective needs."
	authentication = list("hos", "captain", "hop")
/datum/supply_item/profession/medical
	name = "Medical Intern Equipment"
	contains = list(/obj/item/clothing/under/rank/medical,
					/obj/item/weapon/storage/backpack/medic,
					/obj/item/device/radio/headset/headset_med) // /obj/item/weapon/cartidge/engineering
	cost = 100
	containertype = /obj/structure/closet/secure_closet/medical3
	containername = "Medical Intern Equipment"
	desc = "Everything a Medical Intern needs."
	authentication = list("cmo", "captain", "hop")
/datum/supply_item/profession/medicalfemale
	name = "Medical Intern Equipment - Female"
	contains = list(/obj/item/clothing/under/rank/medical/skirt,
					/obj/item/weapon/storage/backpack/medic,
					/obj/item/device/radio/headset/headset_med) // /obj/item/weapon/cartidge/engineering
	cost = 100
	containertype = /obj/structure/closet/secure_closet/medical3
	containername = "Medical Intern Equipment"
	desc = "Everything a Medical Intern needs."
	authentication = list("cmo", "captain", "hop")
/datum/supply_item/profession/nurse
	name = "Nurse Equipment"
	contains = list(/obj/item/clothing/under/rank/nurse,
					/obj/item/clothing/under/rank/nursesuit,
					/obj/item/clothing/head/nursehat,
					/obj/item/weapon/storage/backpack/medic,
					/obj/item/device/radio/headset/headset_med) // /obj/item/weapon/cartidge/engineering
	cost = 100
	containertype = /obj/structure/closet/secure_closet/medical3
	containername = "Nurse Equipment"
	desc = "Everything a Nurse needs. A mostly male-dominated profession."
	authentication = list("cmo", "captain", "hop")
/datum/supply_item/profession/doctor
	name = "Doctor Equipment"
	contains = list(/obj/item/clothing/under/rank/medical,
					/obj/item/clothing/suit/storage/labcoat,
					/obj/item/clothing/shoes/white,
					/obj/item/clothing/suit/hooded/wintercoat/medical,
					/obj/item/clothing/gloves/color/latex,
					/obj/item/clothing/mask/breath/medical,
					/obj/item/weapon/storage/firstaid/regular,
					/obj/item/weapon/storage/backpack/satchel_med,
					/obj/item/device/radio/headset/headset_med) // /obj/item/weapon/cartidge/engineering
	cost = 500
	containertype = /obj/structure/closet/secure_closet/medical3
	containername = "Doctor Equipment"
	desc = "Everything a Doctor needs."
	authentication = list("cmo", "captain", "hop")
/datum/supply_item/profession/doctorfemale
	name = "Doctor Equipment - Female"
	contains = list(/obj/item/clothing/under/rank/medical/skirt,
					/obj/item/clothing/suit/storage/labcoat,
					/obj/item/clothing/shoes/white,
					/obj/item/clothing/suit/hooded/wintercoat/medical,
					/obj/item/clothing/gloves/color/latex,
					/obj/item/clothing/mask/breath/medical,
					/obj/item/weapon/storage/firstaid/regular,
					/obj/item/weapon/storage/backpack/satchel_med,
					/obj/item/device/radio/headset/headset_med) // /obj/item/weapon/cartidge/engineering
	cost = 500
	containertype = /obj/structure/closet/secure_closet/medical3
	containername = "Doctor Equipment"
	desc = "Everything a Doctor needs."
	authentication = list("cmo", "captain", "hop")
/datum/supply_item/profession/chemist
	name = "Chemist Equipment"
	contains = list(/obj/item/clothing/under/rank/medical,
					/obj/item/clothing/suit/storage/labcoat/chemist,
					/obj/item/clothing/glasses/science,
					/obj/item/weapon/storage/bag/chemistry,
					/obj/item/weapon/storage/backpack/satchel_chem,
					/obj/item/device/radio/headset/headset_med) // /obj/item/weapon/cartidge/engineering
	cost = 300
	containertype = /obj/structure/closet/secure_closet/medical3
	containername = "Chemist Equipment"
	desc = "Everything a Chemist needs."
	authentication = list("cmo", "captain", "hop")
/datum/supply_item/profession/chemistfemale
	name = "Chemist Equipment - Female"
	contains = list(/obj/item/clothing/under/rank/medical/skirt,
					/obj/item/clothing/suit/storage/labcoat/chemist,
					/obj/item/clothing/glasses/science,
					/obj/item/weapon/storage/bag/chemistry,
					/obj/item/weapon/storage/backpack/satchel_chem,
					/obj/item/device/radio/headset/headset_med) // /obj/item/weapon/cartidge/engineering
	cost = 300
	containertype = /obj/structure/closet/secure_closet/medical3
	containername = "Chemist Equipment"
	desc = "Everything a Chemist needs."
	authentication = list("cmo", "captain", "hop")
/datum/supply_item/profession/scienceintern
	name = "Science Intern Equipment"
	contains = list(/obj/item/clothing/under/rank/scientist,
					/obj/item/weapon/storage/backpack/science,
					/obj/item/device/radio/headset/headset_sci) // /obj/item/weapon/cartidge/engineering
	cost = 100
	containertype = /obj/structure/closet/secure_closet/scientist
	containername = "Science Intern Equipment"
	desc = "Everything a Science Intern needs."
	authentication = list("rd", "captain", "hop")
/datum/supply_item/profession/scienceinternfemale
	name = "Science Intern Equipment - Female"
	contains = list(/obj/item/clothing/under/rank/scientist/skirt,
					/obj/item/weapon/storage/backpack/science,
					/obj/item/device/radio/headset/headset_sci) // /obj/item/weapon/cartidge/engineering
	cost = 100
	containertype = /obj/structure/closet/secure_closet/scientist
	containername = "Science Intern Equipment"
	desc = "Everything a Science Intern needs."
	authentication = list("rd", "captain", "hop")
/datum/supply_item/profession/scientist
	name = "Scientist Equipment"
	contains = list(/obj/item/clothing/under/rank/scientist,
					/obj/item/clothing/suit/storage/labcoat/science,
					/obj/item/clothing/suit/hooded/wintercoat/science,
					/obj/item/clothing/glasses/science,
					/obj/item/weapon/storage/backpack/satchel_tox,
					/obj/item/device/radio/headset/headset_sci) // /obj/item/weapon/cartidge/engineering
	cost = 400
	containertype = /obj/structure/closet/secure_closet/scientist
	containername = "Scientist Equipment"
	desc = "Everything a Scientist needs."
	authentication = list("rd", "captain", "hop")
/datum/supply_item/profession/scientistfemale
	name = "Scientist Equipment - Female"
	contains = list(/obj/item/clothing/under/rank/scientist/skirt,
					/obj/item/clothing/suit/storage/labcoat/science,
					/obj/item/clothing/suit/hooded/wintercoat/science,
					/obj/item/clothing/glasses/science,
					/obj/item/weapon/storage/backpack/satchel_tox,
					/obj/item/device/radio/headset/headset_sci) // /obj/item/weapon/cartidge/engineering
	cost = 400
	containertype = /obj/structure/closet/secure_closet/scientist
	containername = "Scientist Equipment"
	desc = "Everything a Scientist needs."
	authentication = list("rd", "captain", "hop")
/datum/supply_item/profession/roboticist
	name = "Roboticist Equipment"
	contains = list(/obj/item/clothing/under/rank/roboticist,
					/obj/item/clothing/suit/storage/labcoat/fluff/aeneas_rinil,
					/obj/item/weapon/storage/belt/utility/full/multitool,
					/obj/item/clothing/glasses/hud/diagnostic,
					/obj/item/weapon/storage/backpack/satchel_tox,
					/obj/item/device/radio/headset/headset_sci) // /obj/item/weapon/cartidge/engineering
	cost = 400
	containertype = /obj/structure/closet/secure_closet/scientist
	containername = "Roboticist Equipment"
	desc = "Everything a Roboticist needs."
	authentication = list("rd", "captain", "hop")
/datum/supply_item/profession/roboticistfemale
	name = "Roboticist Equipment - Female"
	contains = list(/obj/item/clothing/under/rank/roboticist/skirt,
					/obj/item/clothing/suit/storage/labcoat/fluff/aeneas_rinil,
					/obj/item/weapon/storage/belt/utility/full/multitool,
					/obj/item/clothing/glasses/hud/diagnostic,
					/obj/item/weapon/storage/backpack/satchel_tox,
					/obj/item/device/radio/headset/headset_sci) // /obj/item/weapon/cartidge/engineering
	cost = 400
	containertype = /obj/structure/closet/secure_closet/scientist
	containername = "Roboticist Equipment"
	desc = "Everything a Roboticist needs."
	authentication = list("rd", "captain", "hop")


/datum/supply_item/headgear	// Section header - use these to set default supply group and crate type for sections
	name = "HEADER"				// Use "HEADER" to denote section headers, this is needed for the supply computers to filter them
	containertype = /obj/structure/closet/secure_closet
	group = 2
	containername = "Clothing Order"
/datum/supply_item/headgear/glasses
	name = "Prescription Glasses"
	contains = list(/obj/item/clothing/glasses/regular)
	cost = 50
	desc = "A pair of perscription glasses. The perscription is universal."
/datum/supply_item/headgear/glasseshipster
	name = "Hipster Glasses"
	contains = list(/obj/item/clothing/glasses/regular/hipster)
	cost = 50
	desc = "Hispter glasses. Very hip."
/datum/supply_item/headgear/threedglasses
	name = "3D Glasses"
	contains = list(/obj/item/clothing/glasses/threedglasses)
	cost = 50
	desc = "A souvenier from a past era."
/datum/supply_item/headgear/gglasses
	name = "Green Glasses"
	contains = list(/obj/item/clothing/glasses/gglasses)
	cost = 50
	desc = "Glasses, but green."
/datum/supply_item/headgear/fakesunglasses
	name = "Cheap Sunglasses"
	contains = list(/obj/item/clothing/glasses/sunglasses/fake)
	cost = 30
	desc = "Cheap plastic sunglasses."
/datum/supply_item/headgear/sunglasses
	name = "Sunglasses"
	contains = list(/obj/item/clothing/glasses/sunglasses)
	cost = 50
	desc = "Perfect for wearing indoors."
/datum/supply_item/headgear/largesunglasses
	name = "Large Sunglasses"
	contains = list(/obj/item/clothing/glasses/sunglasses/big)
	cost = 75
	desc = "Guaranteed UV protection, even against a supernova."
/datum/supply_item/headgear/sombrero
	name = "Sombrero"
	contains = list(/obj/item/clothing/head/sombrero)
	cost = 75
	desc = "An authentic mexican sombrero."
/datum/supply_item/headgear/tophat
	name = "Sturdy Top Hat"
	contains = list(/obj/item/clothing/head/that)
	cost = 75
	desc = "It's an amish looking top hat."
/datum/supply_item/headgear/fedora
	name = "Fedora"
	contains = list(/obj/item/clothing/head/fedora)
	cost = 75
	desc = "A black fedora, cool people only."
/datum/supply_item/headgear/monocle
	name = "Monocle"
	contains = list(/obj/item/clothing/glasses/monocle)
	cost = 50
	desc = "Dapper!"
/datum/supply_item/headgear/justice
	name = "Justice Helmet"
	contains = list(/obj/item/clothing/head/helmet/justice/escape)
	cost = 75
	desc = "Weee-ooo weee-ooo."
	
/datum/supply_item/clothing	// Section header - use these to set default supply group and crate type for sections
	name = "HEADER"				// Use "HEADER" to denote section headers, this is needed for the supply computers to filter them
	containertype = /obj/structure/closet/secure_closet
	group = 3
	containername = "Clothing Order"
/datum/supply_item/clothing/navysuit
	name = "Navy Suit"
	contains = list(/obj/item/clothing/under/suit_jacket/navy)
	cost = 260
	desc = "A navy suit and red tie, intended for the stations finest."
/datum/supply_item/clothing/kilt
	name = "Kilt"
	contains = list(/obj/item/clothing/under/kilt)
	cost = 200
	desc = "Noo peeking!"
/datum/supply_item/clothing/overalls
	name = "Laborer's Overalls"
	contains = list(/obj/item/clothing/under/overalls)
	cost = 160
	desc = "Generic clothes for the generic proletariat."
/datum/supply_item/clothing/jeans
	name = "Jeans and T-shirt"
	contains = list(/obj/item/clothing/under/pants/jeans, /obj/item/clothing/undershirt/white)
	cost = 180
	desc = "A pair of tough blue jeans and a fresh white t-shirt"
/datum/supply_item/clothing/miljacket
	name = "Olive Military Jacket"
	contains = list(/obj/item/clothing/suit/jacket/miljacket)
	cost = 200
	desc = "A canvas jacket styled after military garb."
/datum/supply_item/clothing/miljacketwhite
	name = "White Military Jacket"
	contains = list(/obj/item/clothing/suit/jacket/miljacket/white)
	cost = 200
	desc = "A white canvas jacket styled after military garb."
/datum/supply_item/clothing/miljacketdesert
	name = "Desert Military Jacket"
	contains = list(/obj/item/clothing/suit/jacket/miljacket/desert)
	cost = 200
	desc = "A desert canvas jacket styled after military garb."
/datum/supply_item/clothing/miljacketnavy
	name = "Navy Military Jacket"
	contains = list(/obj/item/clothing/suit/jacket/miljacket/navy)
	cost = 200
	desc = "A navy canvas jacket styled after military garb."
/datum/supply_item/clothing/sundress
	name = "Sundress"
	contains = list(/obj/item/clothing/under/sundress)
	cost = 200
	desc = "A flowery sundress."
/datum/supply_item/clothing/stripeddress
	name = "Striped Dress"
	contains = list(/obj/item/clothing/under/stripeddress)
	cost = 200
	desc = "A fashionable dress."
/datum/supply_item/clothing/sailordress
	name = "Sailor Dress"
	contains = list(/obj/item/clothing/under/sailordress)
	cost = 220
	desc = "A dress styled after the formal uniform of a sailor."
/datum/supply_item/clothing/jacket
	name = "Bomber Jacket"
	contains = list(/obj/item/clothing/suit/jacket)
	cost = 200
	desc = "A brown bomber jacket."
/datum/supply_item/clothing/redeveninggown
	name = "Red Evening Gown"
	contains = list(/obj/item/clothing/under/redeveninggown)
	cost = 230
	desc = "A fancy red dress for the elegant stationeer."
/datum/supply_item/clothing/blacktango
	name = "Black Tango Dress"
	contains = list(/obj/item/clothing/under/blacktango)
	cost = 230
	desc = "A black dress filled with latin fire."
/datum/supply_item/clothing/poncho
	name = "Poncho"
	contains = list(/obj/item/clothing/suit/poncho)
	cost = 150
	desc = "An authentic mexican poncho."
/datum/supply_item/clothing/blacktrenchcoat
	name = "Black Trench Coat"
	contains = list(/obj/item/clothing/suit/blacktrenchcoat)
	cost = 200
	desc = "Stylish black trench coat."
/datum/supply_item/clothing/browntrenchcoat
	name = "Brown Trench Coat"
	contains = list(/obj/item/clothing/suit/browntrenchcoat)
	cost = 200
	desc = "Stylish brown trench coat."
/datum/supply_item/clothing/pirateblack
	name = "Black Pirate Coat"
	contains = list(/obj/item/clothing/suit/pirate_black)
	cost = 100
	desc = "A black pirate coat, matey!"
/datum/supply_item/clothing/piratebrown
	name = "Brown Pirate Coat"
	contains = list(/obj/item/clothing/suit/pirate_brown)
	cost = 100
	desc = "A brown pirate coat, matey!"
/datum/supply_item/clothing/blue
	name = "Blue Hoodie"
	contains = list(/obj/item/clothing/suit/hooded/hoodie/blue)
	cost = 100
	desc = "A blue hoodie."
/datum/supply_item/clothing/mit
	name = "Martian Institute of Technology Hoodie"
	contains = list(/obj/item/clothing/suit/hooded/hoodie/mit)
	cost = 100
	desc = "A black Martian Institute of Technology hoodie."
/datum/supply_item/clothing/cut
	name = "Caanan University of Technology Hoodie"
	contains = list(/obj/item/clothing/suit/hooded/hoodie/cut)
	cost = 100
	desc = "A gray Caanan University of Technology Hoodie."
/datum/supply_item/clothing/lam
	name = "Lunar Academy of Medicine Hoodie"
	contains = list(/obj/item/clothing/suit/hooded/hoodie/lam)
	cost = 100
	desc = "A gray Lunar Academy of Medicine hoodie."
/datum/supply_item/clothing/nt
	name = "Nanotrasen Hoodie"
	contains = list(/obj/item/clothing/suit/hooded/hoodie/nt)
	cost = 100
	desc = "A blue Nanotrasen hoodie."
/datum/supply_item/clothing/tp
	name = "Tharsis Polytech Hoodie"
	contains = list(/obj/item/clothing/suit/hooded/hoodie/tp)
	cost = 100
	desc = "A dark Tharsis Polytech hoodie."
/datum/supply_item/clothing/wintercoat
	name = "Winter Coat"
	contains = list(/obj/item/clothing/suit/hooded/wintercoat)
	cost = 100
	desc = "Very warm."
/datum/supply_item/clothing/justice
	name = "Justice Suit"
	contains = list(/obj/item/clothing/suit/justice)
	cost = 100
	desc = "Be a real law man."
/datum/supply_item/clothing/psysuit
	name = "Psysuit"
	contains = list(/obj/item/clothing/under/psysuit)
	cost = 100
	desc = "A gray, mysterious undersuit."
/datum/supply_item/clothing/pilot
	name = "Pilot Jacket"
	contains = list(/obj/item/clothing/suit/jacket/pilot)
	cost = 100
	desc = "Black bomber jacket."
/datum/supply_item/clothing/pilot
	name = "Leather Jacket"
	contains = list(/obj/item/clothing/suit/jacket/pilot)
	cost = 100
	desc = "Tunnel Snakes rule!"

	
/datum/supply_item/accessories	// Section header - use these to set default supply group and crate type for sections
	name = "HEADER"				// Use "HEADER" to denote section headers, this is needed for the supply computers to filter them
	containertype = /obj/structure/closet/secure_closet
	group = 4
	containername = "Clothing Order"
/datum/supply_item/accessories/redscarf
	name = "Red Scarf"
	contains = list(/obj/item/clothing/accessory/scarf/red)
	cost = 75
	desc = "A stylish red scarf."
/datum/supply_item/accessories/greenscarf
	name = "Green Scarf"
	contains = list(/obj/item/clothing/accessory/scarf/green)
	cost = 75
	desc = "A stylish green scarf."
/datum/supply_item/accessories/darkbluescarf
	name = "Dark Blue Scarf"
	contains = list(/obj/item/clothing/accessory/scarf/darkblue)
	cost = 75
	desc = "A stylish blue scarf."
/datum/supply_item/accessories/purplescarf
	name = "Purple Scarf"
	contains = list(/obj/item/clothing/accessory/scarf/purple)
	cost = 75
	desc = "A stylish purple scarf."
/datum/supply_item/accessories/yellowscarf
	name = "Yellow Scarf"
	contains = list(/obj/item/clothing/accessory/scarf/yellow)
	cost = 75
	desc = "A stylish yellow scarf."
/datum/supply_item/accessories/orangescarf
	name = "Orange Scarf"
	contains = list(/obj/item/clothing/accessory/scarf/orange)
	cost = 75
	desc = "A stylish orange scarf."
/datum/supply_item/accessories/lightbluescarf
	name = "Light Blue Scarf"
	contains = list(/obj/item/clothing/accessory/scarf/lightblue)
	cost = 75
	desc = "A stylish light blue scarf."
/datum/supply_item/accessories/stripedredscarf
	name = "Striped Red Scarf"
	contains = list(/obj/item/clothing/accessory/stripedredscarf)
	cost = 75
	desc = "A stylish striped red scarf."
/datum/supply_item/accessories/waistcoat
	name = "Black Waistcoat"
	contains = list(/obj/item/clothing/accessory/waistcoat)
	cost = 75
	desc = "A spiffy black waistcoat."
/datum/supply_item/accessories/laceup
	name = "Laceup Shoes"
	contains = list(/obj/item/clothing/shoes/laceup)
	cost = 75
	desc = "A freshly polished pair of laceup shoes."
/datum/supply_item/accessories/blackshoes
	name = "Black Shoes"
	contains = list(/obj/item/clothing/shoes/black)
	cost = 75
	desc = "A simple pair of black shoes."
/datum/supply_item/accessories/sandals
	name = "Sandals"
	contains = list(/obj/item/clothing/shoes/sandal)
	cost = 75
	desc = "A pair of simple wooden sandals."
/datum/supply_item/accessories/fingerlessgloves
	name = "Fingerless Gloves"
	contains = list(/obj/item/clothing/gloves/fingerless)
	cost = 50
	desc = "A pair of gloves cut off at the fingertips."
/datum/supply_item/accessories/fannypack
	name = "Fannypack"
	contains = list(/obj/item/weapon/storage/belt/fannypack)
	cost = 100
	desc = "A brown fannypack."

/datum/supply_item/robotics
	name = "HEADER"				// Use "HEADER" to denote section headers, this is needed for the supply computers to filter them
	containertype = /obj/structure/closet/crate/secure/plasma
	group = 5
	containername = "Robotics Order"

/datum/supply_item/robotics/janitor_module
	name = "Module Chip (Janitor)"
	contains = list(/obj/item/borg/module_chip/janitor)
	cost = 90
	desc = "A chip containing everything a janitorial cyborg needs."
/datum/supply_item/robotics/bipedaljanitor
	name = "Bipedal Janitor Chassis Mod (Janitor)"
	contains = list(/obj/item/borg/chassis_mod/janitor/bipedaljanitor)
	cost = 120
	desc = "A chip to change the cyborgs appearance. This one can only be used with janitor modules"
/datum/supply_item/robotics/buckethead
	name = "Buckethead Chassis Mod (Janitor)"
	contains = list(/obj/item/borg/chassis_mod/janitor/buckethead)
	cost = 120
	desc = "A chip to change the cyborgs appearance. This one can only be used with janitor modules"
/datum/supply_item/robotics/mopgearrex
	name = "MOP GEAR REX Chassis Mod (Janitor)"
	contains = list(/obj/item/borg/chassis_mod/janitor/mopgearrex)
	cost = 120
	desc = "A chip to change the cyborgs appearance. This one can only be used with janitor modules"

/datum/supply_item/robotics/mining_module
	name = "Module Chip (Miner)"
	contains = list(/obj/item/borg/module_chip/mining)
	cost = 150
	desc = "A chip containing everything a mining cyborg needs."

/datum/supply_item/robotics/standingsteve
	name = "Standing Steve Chassis Mod (Miner)"
	contains = list(/obj/item/borg/chassis_mod/mining/standingsteve)
	cost = 120
	desc = "A chip to change the cyborgs appearance. This one can only be used with miner modules"
/datum/supply_item/robotics/minerbipedal
	name = "Bipedal Miner Chassis Mod (Miner)"
	contains = list(/obj/item/borg/chassis_mod/mining/minerbipedal)
	cost = 120
	desc = "A chip to change the cyborgs appearance. This one can only be used with miner modules"
/datum/supply_item/robotics/advancedminer
	name = "Advanced Miner Chassis Mod (Miner)"
	contains = list(/obj/item/borg/chassis_mod/mining/advancedminer)
	cost = 120
	desc = "A chip to change the cyborgs appearance. This one can only be used with miner modules"
/datum/supply_item/robotics/treadhead
	name = "Treadhead Chassis Mod (Miner)"
	contains = list(/obj/item/borg/chassis_mod/mining/treadhead)
	cost = 120
	desc = "A chip to change the cyborgs appearance. This one can only be used with miner modules"

/datum/supply_item/robotics/medical_module
	name = "Module Chip (Medic)"
	contains = list(/obj/item/borg/module_chip/medical)
	cost = 150
	desc = "A chip containing everything a medical cyborg needs."
/datum/supply_item/robotics/medicbipedal
	name = "Bipedal Medic Chassis Mod (Medic)"
	contains = list(/obj/item/borg/chassis_mod/medical/bipedmedic)
	cost = 120
	desc = "A chip to change the cyborgs appearance. This one can only be used with medic modules"
/datum/supply_item/robotics/surgicalbot
	name = "Surgicalbot Chassis Mod (Medic)"
	contains = list(/obj/item/borg/chassis_mod/medical/surgicalbot)
	cost = 120
	desc = "A chip to change the cyborgs appearance. This one can only be used with medic modules"
/datum/supply_item/robotics/advancedmedic
	name = "Advanced Medic Chassis Mod (Medic)"
	contains = list(/obj/item/borg/chassis_mod/medical/advancedmedic)
	cost = 120
	desc = "A chip to change the cyborgs appearance. This one can only be used with medic modules"
/datum/supply_item/robotics/doctorneedles
	name = "Doctor Needles Chassis Mod (Medic)"
	contains = list(/obj/item/borg/chassis_mod/medical/doctorneedles)
	cost = 120
	desc = "A chip to change the cyborgs appearance. This one can only be used with medic modules"

/datum/supply_item/robotics/engineering_module
	name = "Module Chip (Engineer)"
	contains = list(/obj/item/borg/module_chip/engineering)
	cost = 150
	desc = "A chip containing everything an engineer cyborg needs."

/datum/supply_item/robotics/bipedalengineer
	name = "Bipedal Engineer Chassis Mod (Engineer)"
	contains = list(/obj/item/borg/chassis_mod/engineering/bipedalengineer)
	cost = 120
	desc = "A chip to change the cyborgs appearance. This one can only be used with engineer modules"
/datum/supply_item/robotics/antique
	name = "Antique Engineer Chassis Mod (Engineer)"
	contains = list(/obj/item/borg/chassis_mod/engineering/antique)
	cost = 120
	desc = "A chip to change the cyborgs appearance. This one can only be used with engineer modules."
/datum/supply_item/robotics/landmate
	name = "Landmate Chassis Mod (Engineer)"
	contains = list(/obj/item/borg/chassis_mod/engineering/landmate)
	cost = 120
	desc = "A chip to change the cyborgs appearance. This one can only be used with engineer modules."

/datum/supply_item/robotics/security_module
	name = "Module Chip (Security)"
	contains = list(/obj/item/borg/module_chip/security)
	cost = 150
	desc = "A chip containing everything an engineer cyborg needs."

/datum/supply_item/robotics/bipedalsecurity
	name = "Bipedal Security Chassis Mod (Security)"
	contains = list(/obj/item/borg/chassis_mod/security/bipedalsecurity)
	cost = 120
	desc = "A chip to change the cyborgs appearance. This one can only be used with security modules."
/datum/supply_item/robotics/redknight
	name = "Red Knight Chassis Mod (Security)"
	contains = list(/obj/item/borg/chassis_mod/security/redknight)
	cost = 120
	desc = "A chip to change the cyborgs appearance. This one can only be used with security modules."

/datum/supply_item/robotics/bloodhound
	name = "Bloodhound Chassis Mod (Security)"
	contains = list(/obj/item/borg/chassis_mod/security/bloodhound)
	cost = 120
	desc = "A chip to change the cyborgs appearance. This one can only be used with security modules."
/datum/supply_item/robotics/service_module
	name = "Module Chip (Service)"
	contains = list(/obj/item/borg/module_chip/service)
	cost = 150
	desc = "A chip containing everything a service cyborg needs."
/datum/supply_item/robotics/waitress
	name = "Waitress Chassis Mod (Service)"
	contains = list(/obj/item/borg/chassis_mod/service/waitress)
	cost = 120
	desc = "A chip to change the cyborgs appearance. This one can only be used with service modules."
/datum/supply_item/robotics/bro
	name = "Bro-bot Chassis Mod (Service)"
	contains = list(/obj/item/borg/chassis_mod/service/bro)
	cost = 120
	desc = "A chip to change the cyborgs appearance. This one can only be used with service modules."
/datum/supply_item/robotics/fountainbot
	name = "Fountain-bot Chassis Mod (Service)"
	contains = list(/obj/item/borg/chassis_mod/service/fountainbot)
	cost = 120
	desc = "A chip to change the cyborgs appearance. This one can only be used with service modules."
/datum/supply_item/robotics/poshbot
	name = "Posh-bot Chassis Mod (Service)"
	contains = list(/obj/item/borg/chassis_mod/service/poshbot)
	cost = 120
	desc = "A chip to change the cyborgs appearance. This one can only be used with service modules."
/datum/supply_item/robotics/waiterbot
	name = "Waiter-bot Chassis Mod (Service)"
	contains = list(/obj/item/borg/chassis_mod/service/waiterbot)
	cost = 120
	desc = "A chip to change the cyborgs appearance. This one can only be used with service modules."

/datum/supply_item/department
	name = "HEADER"				// Use "HEADER" to denote section headers, this is needed for the supply computers to filter them
	containertype = /obj/structure/closet/crate/secure
	group = 6
/datum/supply_item/department/bulkfirstaid
	name = "Bulk Medkit Crate"
	contains = list(/obj/item/weapon/storage/firstaid/fire,
					/obj/item/weapon/storage/firstaid/toxin,
					/obj/item/weapon/storage/firstaid/brute,
					/obj/item/weapon/storage/firstaid/o2,
					/obj/item/weapon/storage/firstaid/fire,
					/obj/item/weapon/storage/firstaid/toxin,
					/obj/item/weapon/storage/firstaid/brute,
					/obj/item/weapon/storage/firstaid/o2,
					/obj/item/weapon/storage/firstaid/fire,
					/obj/item/weapon/storage/firstaid/toxin,
					/obj/item/weapon/storage/firstaid/brute,
					/obj/item/weapon/storage/firstaid/o2,
					/obj/item/weapon/storage/firstaid/fire,
					/obj/item/weapon/storage/firstaid/toxin,
					/obj/item/weapon/storage/firstaid/brute,
					/obj/item/weapon/storage/firstaid/o2,
					/obj/item/weapon/storage/firstaid/fire,
					/obj/item/weapon/storage/firstaid/toxin,
					/obj/item/weapon/storage/firstaid/brute,
					/obj/item/weapon/storage/firstaid/o2)
	cost = 2500
	containertype = /obj/structure/closet/crate/secure/large
	containername = "Bulk Medkit Crate"
	desc = "Contains 5 burn, toxin, brute, and oxygen medkits."
	authentication = list("cmo", "captain", "hop")
/datum/supply_item/department/bulktaser
	name = "Hybrid Tasers"
	contains = list(/obj/item/weapon/gun/energy/gun/advtaser,
					/obj/item/weapon/gun/energy/gun/advtaser,
					/obj/item/weapon/gun/energy/gun/advtaser,
					/obj/item/weapon/gun/energy/gun/advtaser,
					/obj/item/weapon/gun/energy/gun/advtaser,
					/obj/item/weapon/gun/energy/gun/advtaser,
					/obj/item/weapon/gun/energy/gun/advtaser,
					/obj/item/weapon/gun/energy/gun/advtaser,
					/obj/item/weapon/gun/energy/gun/advtaser,
					/obj/item/weapon/gun/energy/gun/advtaser)
	cost = 10000
	containertype = /obj/structure/closet/crate/secure/gear
	containername = "Hybrid Taser Crate"
	desc = "Shipment of 10 hybrid tasers."
	authentication = list("hos", "captain", "hop")
/datum/supply_item/department/bulkenergy
	name = "Energy Weapons"
	contains = list(/obj/item/weapon/gun/energy/gun,
					/obj/item/weapon/gun/energy/gun,
					/obj/item/weapon/gun/energy/gun,
					/obj/item/weapon/gun/energy/gun,
					/obj/item/weapon/gun/energy/gun,
					/obj/item/weapon/gun/energy/gun,
					/obj/item/weapon/gun/energy/gun,
					/obj/item/weapon/gun/energy/gun,
					/obj/item/weapon/gun/energy/gun,
					/obj/item/weapon/gun/energy/gun)
	cost = 15000
	containertype = /obj/structure/closet/crate/secure/gear
	containername = "Energy Gun Crate"
	desc = "Shipment of 10 energy guns."
	authentication = list("hos", "captain", "hop")

/datum/supply_item/materials
	name = "HEADER"				// Use "HEADER" to denote section headers, this is needed for the supply computers to filter them
	containertype = /obj/structure/closet/crate/secure/large/reinforced
	group = 7
/datum/supply_item/materials/plastic
	name = "Plastic"
	contains = list(/obj/item/stack/sheet/mineral/plastic)
	amount = 5
	cost = 120
	containertype = /obj/structure/closet/crate/secure
	containername = "Shipment of Plastic"
	desc = "5 sheets of plastic."
/datum/supply_item/materials/plasteel
	name = "Plasteel"
	contains = list(/obj/item/stack/sheet/plasteel)
	amount = 50
	cost = 800
	containertype = /obj/structure/closet/crate/secure/large/reinforced
	containername = "Shipment of Plasteel"
	desc = "50 sheets of plasteel."
/datum/supply_item/materials/silver
	name = "Silver"
	contains = list(/obj/item/stack/sheet/mineral/silver)
	amount = 50
	cost = 2000
	containertype = /obj/structure/closet/crate/secure/large/reinforced
	containername = "Shipment of Silver"
	desc = "50 sheets of silver."
/datum/supply_item/materials/gold
	name = "Gold"
	contains = list(/obj/item/stack/sheet/mineral/gold)
	amount = 50
	cost = 6000
	containertype = /obj/structure/closet/crate/secure/large/reinforced
	containername = "Shipment of Gold"
	desc = "50 sheets of gold."
/datum/supply_item/materials/uranium
	name = "Uranium"
	contains = list(/obj/item/stack/sheet/mineral/uranium)
	amount = 50
	cost = 10000
	containertype = /obj/structure/closet/crate/secure/large/reinforced
	containername = "Shipment of Uranium"
	desc = "50 sheets of uranium."
/datum/supply_item/materials/diamond
	name = "Diamond"
	contains = list(/obj/item/stack/sheet/mineral/diamond)
	amount = 50
	cost = 20000
	containertype = /obj/structure/closet/crate/secure/large/reinforced
	containername = "Shipment of Diamonds"
	desc = "50 beautiful diamonds."

/datum/supply_item/engineering
	name = "HEADER"				// Use "HEADER" to denote section headers, this is needed for the supply computers to filter them
	containertype = /obj/structure/closet/crate/secure/plasma
	group = 8
	containername = "Engineering Order"
/datum/supply_item/engineering/solars
	name = "Solar Panel Crate"
	contains = list(/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/machinery/power/tracker)
	containername = "Solar Panel Crate"
	cost = 800
	desc = "20 solar panels. Tracker included."
/datum/supply_item/engineering/radiationsuit
	name = "Radiation Suit"
	contains = list(/obj/item/clothing/suit/radiation,
					/obj/item/clothing/head/radiation)
	containername = "Radiation Suit"
	cost = 500
	desc = "Set of protective gear for irradiated environments."
/datum/supply_item/engineering/engihardsuits
	name = "Bulk Engineering Hardsuit Order"
	contains = list(/obj/item/clothing/suit/space/rig/engineering,
					/obj/item/clothing/suit/space/rig/engineering,
					/obj/item/clothing/suit/space/rig/engineering,
					/obj/item/clothing/suit/space/rig/engineering,
					/obj/item/clothing/suit/space/rig/engineering,
					/obj/item/clothing/suit/space/rig/engineering,
					/obj/item/clothing/suit/space/rig/engineering,
					/obj/item/clothing/suit/space/rig/engineering,
					/obj/item/clothing/suit/space/rig/engineering,
					/obj/item/clothing/suit/space/rig/engineering,
					/obj/item/clothing/head/helmet/space/rig/engineering,
					/obj/item/clothing/head/helmet/space/rig/engineering,
					/obj/item/clothing/head/helmet/space/rig/engineering,
					/obj/item/clothing/head/helmet/space/rig/engineering,
					/obj/item/clothing/head/helmet/space/rig/engineering,
					/obj/item/clothing/head/helmet/space/rig/engineering,
					/obj/item/clothing/head/helmet/space/rig/engineering,
					/obj/item/clothing/head/helmet/space/rig/engineering,
					/obj/item/clothing/head/helmet/space/rig/engineering,
					/obj/item/clothing/head/helmet/space/rig/engineering)
	containername = "Engineering Hardsuits - Bulk Order"
	cost = 10000
	desc = "10 engineering hardsuits with helmets."
/datum/supply_item/engineering/atmoshardsuits
	name = "Bulk Atmospheric Hardsuit Order"
	contains = list(/obj/item/clothing/suit/space/rig/atmos,
					/obj/item/clothing/suit/space/rig/atmos,
					/obj/item/clothing/suit/space/rig/atmos,
					/obj/item/clothing/suit/space/rig/atmos,
					/obj/item/clothing/suit/space/rig/atmos,
					/obj/item/clothing/suit/space/rig/atmos,
					/obj/item/clothing/suit/space/rig/atmos,
					/obj/item/clothing/suit/space/rig/atmos,
					/obj/item/clothing/suit/space/rig/atmos,
					/obj/item/clothing/suit/space/rig/atmos,
					/obj/item/clothing/head/helmet/space/rig/atmos,
					/obj/item/clothing/head/helmet/space/rig/atmos,
					/obj/item/clothing/head/helmet/space/rig/atmos,
					/obj/item/clothing/head/helmet/space/rig/atmos,
					/obj/item/clothing/head/helmet/space/rig/atmos,
					/obj/item/clothing/head/helmet/space/rig/atmos,
					/obj/item/clothing/head/helmet/space/rig/atmos,
					/obj/item/clothing/head/helmet/space/rig/atmos,
					/obj/item/clothing/head/helmet/space/rig/atmos,
					/obj/item/clothing/head/helmet/space/rig/atmos)
	containername = "Atmospheric Hardsuits - Bulk Order"
	cost = 10000
	desc = "10 atmospheric hardsuits with helmets."
/datum/supply_item/engineering/fueltank
	name = "Fuel Tank"
	contains = list(/obj/structure/reagent_dispensers/fueltank)
	cost = 400
	desc = "Good old fashioned fossil fuels."
/datum/supply_item/engineering/oxygen
	name = "Canister (O2)"
	containertype = /obj/machinery/portable_atmospherics/canister/oxygen
	cost = 150
	desc = "A canister filled with oxygen."
	containername = "Canister (O2)"
/datum/supply_item/engineering/nitrogen
	name = "Canister (N2)"
	containertype = /obj/machinery/portable_atmospherics/canister/nitrogen
	cost = 150
	desc = "A canister filled with nitrogen."
	containername = "Canister (N2)"
/datum/supply_item/engineering/carbondioxide
	name = "Canister (CO2)"
	containertype = /obj/machinery/portable_atmospherics/canister/carbon_dioxide
	cost = 150
	desc = "A canister filled with carbon dioxide."
	containername = "Canister (CO2)"

/datum/supply_item/misc
	name = "HEADER"				// Use "HEADER" to denote section headers, this is needed for the supply computers to filter them
	containertype = /obj/structure/closet/crate/secure
	group = 9
	containername = "Miscellaneous Crate"
/datum/supply_item/misc/firstaidkit
	name = "First-Aid Kit"
	contains = list(/obj/item/weapon/storage/firstaid/regular)
	cost = 100
	desc = "Regular first-aid kit."
/datum/supply_item/misc/spacecleaner
	name = "Space Cleaner"
	contains = list(/obj/item/weapon/reagent_containers/spray/cleaner)
	cost = 120
	desc = "A bottle of Space Cleaner."
/datum/supply_item/misc/noslip
	name = "High Traction Tiles"
	contains = list(/obj/item/stack/tile/noslip/loaded)
	cost = 700
	desc = "20 high-traction tiles."
/datum/supply_item/misc/janicart
	name = "Janicart"
	contains = list(/obj/vehicle/janicart,
					/obj/item/key/janitor)
	cost = 1000
	desc = "A pimpin' ride. Key included."
/datum/supply_item/misc/beekeeper
	name = "Bee Keeping Kit"
	contains = list(/obj/item/clothing/head/beekeeper_head,
					/obj/item/clothing/suit/beekeeper_suit,
					/obj/item/queen_bee)
	cost = 500
	desc = "A beekeeper suit and queen bee. Buzz!"
/datum/supply_item/misc/bedsheetpack
    name = "Bedsheet Variety Pack"
    contains = list(/obj/item/weapon/bedsheet,
					/obj/item/weapon/bedsheet/blue,
					/obj/item/weapon/bedsheet/green,
					/obj/item/weapon/bedsheet/orange,
					/obj/item/weapon/bedsheet/purple,
					/obj/item/weapon/bedsheet/red,
					/obj/item/weapon/bedsheet/yellow,
					/obj/item/weapon/bedsheet/brown,
					/obj/item/weapon/bedsheet/rainbow)
    cost = 300
    desc = "A variety of bedsheets."
/datum/supply_item/misc/wizardpack
    name = "Wizard Pack"
    contains = list(/obj/item/clothing/suit/wizrobe/fake,
					/obj/item/clothing/head/wizard/fake,
					/obj/item/weapon/twohanded/staff,
					/obj/item/toy/character/wizard,
					/obj/item/toy/figure/wizard,
					/obj/item/flag/wiz,
					/obj/item/weapon/bedsheet/wiz)
    cost = 600
    desc = "Everything a LARP nerd needs."
/datum/supply_item/misc/witchpack
    name = "Witch Pack"
    contains = list(/obj/item/clothing/suit/wizrobe/marisa/fake,
					/obj/item/clothing/head/wizard/marisa/fake,
					/obj/item/weapon/twohanded/staff/broom)
    cost = 300											// Cheaper because there is less stuff.
    desc = "A witch can be just as good as a wizard in the arcane arts!"


