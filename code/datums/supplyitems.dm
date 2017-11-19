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
var/const/supply_headgear = 2
var/const/supply_clothing = 3
var/const/supply_accessories = 4
var/const/supply_robotics = 5
var/const/supply_medical = 6
var/const/supply_materials = 7
var/const/supply_engineering = 8
var/const/supply_misc = 9
var/list/all_supply_lists = list(supply_profession, supply_headgear, supply_clothing, supply_accessories, supply_robotics, supply_medical, supply_engineering, supply_materials, supply_misc)

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
			return "Medical Supplies"
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
/datum/supply_item/headgear/fakesunglasses
	name = "Cheap sunglasses"
	contains = list(/obj/item/clothing/glasses/sunglasses/fake)
	cost = 50
	desc = "Cheap plastic sunglasses."
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
/datum/supply_item/headgear/
	name = ""
	contains = list(/obj/item/clothing/)
	cost = 100
	desc = "."
/datum/supply_item/headgear/
	name = ""
	contains = list(/obj/item/clothing/)
	cost = 100
	desc = "."
/datum/supply_item/headgear/
	name = ""
	contains = list(/obj/item/clothing/)
	cost = 100
	desc = "."
/datum/supply_item/headgear/
	name = ""
	contains = list(/obj/item/clothing/)
	cost = 100
	desc = "."

	
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
/datum/supply_item/clothing/laceup
	name = "Laceup Shoes"
	contains = list(/obj/item/clothing/shoes/laceup)
	cost = 90
	desc = "A freshly polished pair of laceup shoes."
/datum/supply_item/clothing/blackshoes
	name = "Black Shoes"
	contains = list(/obj/item/clothing/shoes/black)
	cost = 50
	desc = "A simple pair of black shoes."
/datum/supply_item/clothing/sandals
	name = "Sandals"
	contains = list(/obj/item/clothing/shoes/sandal)
	cost = 60
	desc = "A pair of simple wooden sandals."
/datum/supply_item/clothing/fingerlessgloves
	name = "Fingerless Gloves"
	contains = list(/obj/item/clothing/gloves/fingerless)
	cost = 60
	desc = "A pair of gloves cut off at the fingertips."
/datum/supply_item/clothing/fannypack
	name = "Fannypack"
	contains = list(/obj/item/weapon/storage/belt/fannypack)
	cost = 60
	desc = "A brown fannypack."
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
/datum/supply_item/clothing/
	name = ""
	contains = list(/obj/item/clothing/suit/)
	cost = 100
	desc = "."
/datum/supply_item/clothing/
	name = ""
	contains = list(/obj/item/clothing/suit/)
	cost = 100
	desc = "."
/datum/supply_item/clothing/
	name = ""
	contains = list(/obj/item/clothing/)
	cost = 100
	desc = "."

	
/datum/supply_item/accessories	// Section header - use these to set default supply group and crate type for sections
	name = "HEADER"				// Use "HEADER" to denote section headers, this is needed for the supply computers to filter them
	containertype = /obj/structure/closet/secure_closet
	group = 4
	containername = "Clothing Order"
/datum/supply_item/clothing/redscarf
	name = "Red Scarf"
	contains = list(/obj/item/clothing/accessory/scarf/red)
	cost = 75
	desc = "A stylish red scarf."
/datum/supply_item/clothing/greencarf
	name = "Green Scarf"
	contains = list(/obj/item/clothing/accessory/scarf/green)
	cost = 75
	desc = "A stylish green scarf."
/datum/supply_item/clothing/darkbluescarf
	name = "Dark Blue Scarf"
	contains = list(/obj/item/clothing/accessory/scarf/darkblue)
	cost = 75
	desc = "A stylish blue scarf."
/datum/supply_item/clothing/stripedredscarf
	name = "Striped Red Scarf"
	contains = list(/obj/item/clothing/accessory/stripedredscarf)
	cost = 75
	desc = "A stylish striped red scarf."
/datum/supply_item/clothing/waistcoat
	name = "Black Waistcoat"
	contains = list(/obj/item/clothing/accessory/waistcoat)
	cost = 75
	desc = "A spiffy black waistcoat."

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

/datum/supply_item/medical
	name = "HEADER"				// Use "HEADER" to denote section headers, this is needed for the supply computers to filter them
	containertype = /obj/structure/closet/crate/secure
	group = 6
	containername = "Medical Supplies"
/datum/supply_item/medical/firstaidkit
	name = "First-Aid Kit"
	contains = list(/obj/item/weapon/storage/firstaid/regular)
	cost = 100
	desc = "Regular first-aid kit."
/datum/supply_item/medical/bulkfirstaid
	name = "Bulk Medkit Crate"
	contains = list(/obj/item/weapon/storage/firstaid/fire,
					/obj/item/weapon/storage/firstaid/toxin,
					/obj/item/weapon/storage/firstaid/brute,
					/obj/item/weapon/storage/firstaid/o2)
	cost = 500
	containertype = /obj/structure/closet/crate/secure/large
	containername = "Bulk Medkit Crate"
	desc = "Contains a burn, toxin, brute, and oxygen medkit."
	authentication = list("cmo", "captain", "hop")

/datum/supply_item/materials
	name = "HEADER"				// Use "HEADER" to denote section headers, this is needed for the supply computers to filter them
	containertype = /obj/structure/closet/crate/secure/large/reinforced
	group = 7
/datum/supply_item/materials/metal
	name = "Metal"
	contains = list(/obj/item/stack/sheet/metal)
	amount = 50
	cost = 200
	containertype = /obj/structure/closet/crate/secure/large
	desc = "50 sheets of metal."
/datum/supply_item/materials/glass
	name = "Glass"
	contains = list(/obj/item/stack/sheet/glass)
	amount = 50
	cost = 180
	containertype = /obj/structure/closet/crate/secure/large
	desc = "50 sheets of glass."
/datum/supply_item/materials/plastic
	name = "Plastic"
	contains = list(/obj/item/stack/sheet/mineral/plastic)
	amount = 50
	cost = 120
	containertype = /obj/structure/closet/crate/secure/large
	desc = "50 sheets of plastic."
/datum/supply_item/materials/plasteel
	name = "Plasteel"
	contains = list(/obj/item/stack/sheet/plasteel)
	amount = 50
	cost = 400
	containertype = /obj/structure/closet/crate/secure/large/reinforced
	desc = "50 sheets of plasteel."
/datum/supply_item/materials/plasteel
	name = "Plasma"
	contains = list(/obj/item/stack/sheet/mineral/plasma)
	amount = 50
	cost = 500
	containertype = /obj/structure/closet/crate/secure/large/reinforced
	desc = "50 sheets of plasma."
/datum/supply_item/materials/silver
	name = "Silver"
	contains = list(/obj/item/stack/sheet/mineral/silver)
	amount = 50
	cost = 1000
	containertype = /obj/structure/closet/crate/secure/large/reinforced
	desc = "50 sheets of silver."
/datum/supply_item/materials/gold
	name = "Gold"
	contains = list(/obj/item/stack/sheet/mineral/gold)
	amount = 50
	cost = 3000
	containertype = /obj/structure/closet/crate/secure/large/reinforced
	desc = "50 sheets of gold."
/datum/supply_item/materials/uranium
	name = "Uranium"
	contains = list(/obj/item/stack/sheet/mineral/uranium)
	amount = 50
	cost = 5000
	containertype = /obj/structure/closet/crate/secure/large/reinforced
	desc = "50 sheets of uranium."
/datum/supply_item/materials/diamond
	name = "Diamond"
	contains = list(/obj/item/stack/sheet/mineral/diamond)
	amount = 50
	cost = 10000
	containertype = /obj/structure/closet/crate/secure/large/reinforced
	desc = "50 beautiful diamonds."

/datum/supply_item/engineering
	name = "HEADER"				// Use "HEADER" to denote section headers, this is needed for the supply computers to filter them
	containertype = /obj/structure/closet/crate/secure/plasma
	group = 8
	containername = "Engineering Order"
/datum/supply_item/clothing/
	name = ""
	contains = list(/obj/item/clothing/suit/)
	cost = 100
	desc = "."
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
					/obj/item/solar_assembly)
	cost = 200
	desc = "20 solar panels."
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
/datum/supply_item/misc/spacecleaner
	name = "Space Cleaner"
	contains = list(/obj/item/weapon/reagent_containers/spray/cleaner)
	cost = 120
	desc = "A bottle of Space Cleaner."
/datum/supply_item/misc/janicart
	name = "Janicart"
	contains = list(/obj/vehicle/janicart,
					/obj/item/key/janitor)
	cost = 1000
	desc = "A pimpin' ride. Key included."