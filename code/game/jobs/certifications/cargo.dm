//Cargo

/datum/cert/cargo_tech
	title = "Cargo Technician"
	flag = CARGOTECH
	department_flag = CARGO
	uid = "cargotech"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the quartermaster"
	selection_color = "#dddddd"
	idtype = /obj/item/weapon/card/id/supply
	access = list(access_maint_tunnels, access_mailsorting, access_cargo, access_cargo_bot, access_qm, access_mint, access_mining, access_mining_station, access_mineral_storeroom)
	minimal_access = list(access_maint_tunnels, access_cargo, access_cargo_bot, access_mailsorting, access_mineral_storeroom)
	is_default = 1

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		switch(H.backbag)
			if(2) H.equip_or_collect(new /obj/item/weapon/storage/backpack(H), slot_back)
			if(3) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel_norm(H), slot_back)
			if(4) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		H.equip_or_collect(new /obj/item/device/radio/headset/headset_cargo(H), slot_l_ear)
		H.equip_or_collect(new /obj/item/clothing/under/rank/cargotech(H), slot_w_uniform)
		H.equip_or_collect(new /obj/item/clothing/shoes/black(H), slot_shoes)
		H.equip_or_collect(new /obj/item/device/pda/cargo(H), slot_wear_pda)
		if(H.backbag == 1)
			H.equip_or_collect(new /obj/item/weapon/storage/box/survival(H), slot_r_hand)
		else
			H.equip_or_collect(new /obj/item/weapon/storage/box/survival(H.back), slot_in_backpack)
		return 1



/datum/cert/mining
	title = "Shaft Miner"
	flag = MINER
	uid = "miner"
	department_flag = CARGO
	total_positions = 3
	spawn_positions = 3
	supervisors = "the quartermaster"
	selection_color = "#dddddd"
	idtype = /obj/item/weapon/card/id/supply
	access = list(access_maint_tunnels, access_mailsorting, access_cargo, access_cargo_bot, access_qm, access_mint, access_mining, access_mining_station, access_mineral_storeroom)
	minimal_access = list(access_mining, access_mint, access_mining_station, access_mailsorting, access_maint_tunnels, access_mineral_storeroom)
	alt_titles = list("Spelunker")

	equip(var/mob/living/carbon/human/H)
		if(!H)
			return 0
		H.equip_or_collect(new /obj/item/device/radio/headset/headset_cargo/mining(H), slot_l_ear)
		switch(H.backbag)
			if(2)
				H.equip_or_collect(new /obj/item/weapon/storage/backpack/industrial(H), slot_back)
			if(3)
				H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel_eng(H), slot_back)
			if(4)
				H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		H.equip_or_collect(new /obj/item/clothing/under/rank/miner(H), slot_w_uniform)
		H.equip_or_collect(new /obj/item/clothing/gloves/fingerless(H), slot_gloves)
		H.equip_or_collect(new /obj/item/device/pda/shaftminer(H), slot_wear_pda)
		H.equip_or_collect(new /obj/item/clothing/shoes/workboots(H), slot_shoes)
		H.equip_or_collect(new /obj/item/weapon/reagent_containers/food/pill/patch/styptic(H), slot_l_store)
		H.equip_or_collect(new /obj/item/device/flashlight/seclite(H), slot_r_store)
		H.equip_or_collect(new /obj/item/weapon/storage/box/survival_mining(H.back), slot_in_backpack)
		H.equip_or_collect(new /obj/item/weapon/mining_voucher(H.back), slot_in_backpack)
		H.equip_or_collect(new /obj/item/weapon/storage/bag/ore(H.back), slot_in_backpack)
		return 1

/datum/cert/qm
	title = "Quartermaster"
	flag = QUARTERMASTER
	uid = "quartermaster"
	department_flag = CARGO
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#dddddd"
	idtype = /obj/item/weapon/card/id/supply
	access = list(access_maint_tunnels, access_mailsorting, access_cargo, access_cargo_bot, access_qm, access_mint, access_mining, access_mining_station, access_mineral_storeroom)
	minimal_access = list(access_maint_tunnels, access_mailsorting, access_cargo, access_cargo_bot, access_qm, access_mint, access_mining, access_mining_station, access_mineral_storeroom)


	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		switch(H.backbag)
			if(2) H.equip_or_collect(new /obj/item/weapon/storage/backpack(H), slot_back)
			if(3) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel_norm(H), slot_back)
			if(4) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		H.equip_or_collect(new /obj/item/device/radio/headset/headset_cargo(H), slot_l_ear)
		H.equip_or_collect(new /obj/item/clothing/under/rank/cargo(H), slot_w_uniform)
		H.equip_or_collect(new /obj/item/clothing/shoes/brown(H), slot_shoes)
		H.equip_or_collect(new /obj/item/device/pda/quartermaster(H), slot_wear_pda)
		H.equip_or_collect(new /obj/item/clothing/glasses/sunglasses(H), slot_glasses)
		H.equip_or_collect(new /obj/item/weapon/clipboard(H), slot_l_hand)
		if(H.backbag == 1)
			H.equip_or_collect(new /obj/item/weapon/storage/box/survival(H), slot_r_hand)
		else
			H.equip_or_collect(new /obj/item/weapon/storage/box/survival(H.back), slot_in_backpack)
		return 1


