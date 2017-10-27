var/global/datum/mine_controller/mineController
/datum/mine_controller
	var/conglo_mined = 0
	var/tantiline_mined = 0
	var/plasma_mined = 0
	var/orichilum_mined = 0
	var/last_conglo_spawn = 0
	var/last_tantiline_spawn = 0
	var/last_plasma_spawn = 0
	var/last_orichilum_spawn = 0
	var/pulls = 0
	var/bodies = 0
	var/reactions = 0
	var/current_state = 1
	var/last_state = 1
	var/aggro_multiplier = 1
	var/new_state
	var/next_change = 0
	var/next_event = 0
	var/area/mine/explored/target_area
	var/last_aggression = 0
	var/last_pull_spawn = 0
var/global/datum/mine_controller/mineController/New()
	target_area = locate(/area/mine/explored)
	
	
/datum/mine_controller/proc/calculate_nextevent()
	switch(current_state)
		if(1)
			if(prob(33))
				for(var/turf/simulated/floor/plating/airless/asteroid/hole/holeturf in target_area)
					holeturf.visible_message("The hole suddenly collapses into itself")
					holeturf.ChangeTurf(/turf/simulated/floor/plating/airless/asteroid, keep_icon = FALSE)
					break
			return rand(600, 1200)
		if(2)
			for(var/mob/M in player_list)
				if(M.z == 5)
					if(prob(33))
						switch(pick(1,2))
							if(1)
								to_chat(M, "<span class='danger'>The ground lightly trembles beneath your feet..</span>")
								M.playsound_local(M.loc, pick('sound/effects/earthquake_short.wav','sound/effects/earthquake_short2.wav'), 30, 0)
								shake_camera(M, 5, 1)
							if(2)
								to_chat(M, pick("You feel a sudden sense of dread..", "You feel shame.. but you cant tell why.."))
								M.playsound_local(M.loc, pick('sound/ambience/ambigen5.ogg','sound/ambience/ambigen4.ogg'), 50, 0)
			return rand(450, 600)
		if(3)
			var/spawns = 1
			for(var/mob/M in player_list)
				if(M.z == 5)
					if(prob(66))
						switch(pick(1,2,3))
							if(1)
								to_chat(M, "<span class='danger'>The ground angrily trembles beneath your feet..</span>")
								spawn(10)
									var/used = M.use_stamina(5, 2)
									to_chat(M, "-[used] WILL")
								M.playsound_local(M.loc, pick('sound/effects/earthquake_short.wav','sound/effects/earthquake_short2.wav'), 50, 0)
								shake_camera(M, 10, 2)
							if(2)
								to_chat(M, pick("A whisper in your ear.. you turn your head but there's nothing..", "Being on this asteroid is making you depressed.."))
								M.playsound_local(M.loc, pick('sound/ambience/ambigen5.ogg','sound/ambience/ambigen4.ogg'), 50, 0)
								spawn(10)
									var/used = M.use_stamina(15, 2)
									to_chat(M, "-[used] WILL")
							if(3)
								if(spawns)
									spawns--
									spawn_petraspider(M.loc)
								else
									to_chat(M, pick("A whisper in your ear.. you turn your head but there's nothing..", "Being on this asteroid is making you depressed.."))
									M.playsound_local(M.loc, pick('sound/ambience/ambigen5.ogg','sound/ambience/ambigen4.ogg'), 50, 0)
									spawn(10)
										var/used = M.use_stamina(15, 2)
										to_chat(M, "-[used] WILL")
			return rand(200, 300)
		if(4)
			if(prob(66))
				var/spawns = 2
				for(var/mob/living/M in player_list)
					if(M.z == 5)
						switch(pick(1,2,3))
							if(1)
								shake_camera(M, 25, 3)
								to_chat(M, "<span class='userdanger'>The asteroid rattles under you, you struggle to maintain balance!</span>")
								if(!prob(M.get_stat(3)*10))
									M.fall(1)
								spawn(10)
									var/used = M.use_stamina(10, 2)
									to_chat(M, "-[used] WILL")
								M.playsound_local(M.loc, pick('sound/effects/earthquake_short.wav','sound/effects/earthquake_short2.wav'), 70, 0)
								
							if(2)
								if(M.focusloss>100)
									to_chat(M, pick("<span class='userdanger>You can hear it! It's calling to you! You feel a clarity like you've never felt before~</span>", "<span class='userdanger>It's just one voice now.. It's so clear, it's blissfull</span>"))
									M.hallucination += 50
									spawn(10)
										var/used = M.use_stamina(10, 2)
										to_chat(M, "-[used] WILL")
								else if(M.focusloss>70)
									to_chat(M, pick("<span class='userdanger>You want off of this asteroid, NOW! You cant contain your dread!</span>", "<span class='userdanger>The voices! You dont want to understand!</span>"))
									spawn(10)
										var/used = M.use_stamina(25, 2)
										to_chat(M, "-[used] WILL")
								else
									to_chat(M, pick("<span class='userdanger>Voices layered over themselves.. You struggle to block out the noise!</span>", "<span class='userdanger>You've got to steel yourself against these terrors!</span>"))
									spawn(10)
										var/used = M.use_stamina(25, 2)
										to_chat(M, "-[used] WILL")
								M.playsound_local(M.loc, pick('sound/effects/yewbic_amb1.wav', 'sound/effects/yewbic_amb2.wav', 'sound/effects/yewbic_amb3.wav', 'sound/effects/yewbic_amb4.wav'), 50, 0)
							if(3)
								if(spawns)
									spawns--
									spawn_vindictagolem(M.loc)
								else
									if(M.focusloss>100)
										to_chat(M, pick("<span class='userdanger>You can hear it! It's calling to you! You feel a clarity like you've never felt before~</span>", "<span class='userdanger>It's just one voice now.. It's so clear, it's blissfull</span>"))
										M.hallucination += 50
										spawn(10)
											var/used = M.use_stamina(10, 2)
											to_chat(M, "-[used] WILL")
									else if(M.focusloss>70)
										to_chat(M, pick("<span class='userdanger>You want off of this asteroid, NOW! You cant contain your dread!</span>", "<span class='userdanger>The voices! You dont want to understand!</span>"))
										spawn(10)
											var/used = M.use_stamina(25, 2)
											to_chat(M, "-[used] WILL")
									else
										to_chat(M, pick("<span class='userdanger>Voices layered over themselves.. You struggle to block out the noise!</span>", "<span class='userdanger>You've got to steel yourself against these terrors!</span>"))
										spawn(10)
											var/used = M.use_stamina(25, 2)
											to_chat(M, "-[used] WILL")
									M.playsound_local(M.loc, pick('sound/effects/yewbic_amb1.wav', 'sound/effects/yewbic_amb2.wav', 'sound/effects/yewbic_amb3.wav', 'sound/effects/yewbic_amb4.wav'), 50, 0)
			return rand(100, 200)
		if(5)
			if(prob(66))
				var/spawns = 3
				for(var/mob/living/M in player_list)
					if(M.z == 5)
						switch(pick(1,2,3))
							if(1)
								shake_camera(M, 25, 3)
								to_chat(M, "<span class='userdanger'>The asteroid rattles under you, you struggle to maintain balance!</span>")
								if(!prob(M.get_stat(3)*10))
									M.fall(1)
								spawn(10)
									var/used = M.use_stamina(10, 2)
									to_chat(M, "-[used] WILL")
								M.playsound_local(M.loc, pick('sound/effects/earthquake_short.wav','sound/effects/earthquake_short2.wav'), 70, 0)
								
							if(2)
								if(M.focusloss>100)
									to_chat(M, pick("<span class='userdanger>You can hear it! It's calling to you! You feel a clarity like you've never felt before~</span>", "<span class='userdanger>It's just one voice now.. It's so clear, it's blissfull</span>"))
									M.hallucination += 50
									spawn(10)
										var/used = M.use_stamina(10, 2)
										to_chat(M, "-[used] WILL")
								else if(M.focusloss>70)
									to_chat(M, pick("<span class='userdanger>You want off this asteroid, NOW! You cant contain your dread!</span>", "<span class='userdanger>The voices! You dont want to understand!</span>"))
									spawn(10)
										var/used = M.use_stamina(25, 2)
										to_chat(M, "-[used] WILL")
								else
									to_chat(M, pick("<span class='userdanger>Voices layered over themselves.. You struggle to block out the noise!</span>", "<span class='userdanger>You've got to steel yourself against these terrors!</span>"))
									spawn(10)
										var/used = M.use_stamina(25, 2)
										to_chat(M, "-[used] WILL")
								M.playsound_local(M.loc, pick('sound/effects/yewbic_amb1.wav', 'sound/effects/yewbic_amb2.wav', 'sound/effects/yewbic_amb3.wav', 'sound/effects/yewbic_amb4.wav'), 50, 0)
							if(3)
								if(spawns)
									spawns--
									spawn_vindictagolem(M.loc)
								else
									if(M.focusloss>100)
										to_chat(M, pick("<span class='userdanger>You can hear it! It's calling to you! You feel a clarity like you've never felt before~</span>", "<span class='userdanger>It's just one voice now.. It's so clear, it's blissfull</span>"))
										M.hallucination += 50
										spawn(10)
											var/used = M.use_stamina(10, 2)
											to_chat(M, "-[used] WILL")
									else if(M.focusloss>70)
										to_chat(M, pick("<span class='userdanger>You want off this asteroid, NOW! You cant contain your dread!</span>", "<span class='userdanger>The voices! You dont want to understand!</span>"))
										spawn(10)
											var/used = M.use_stamina(25, 2)
											to_chat(M, "-[used] WILL")
									else
										to_chat(M, pick("<span class='userdanger>Voices layered over themselves.. You struggle to block out the noise!</span>", "<span class='userdanger>You've got to steel yourself against these terrors!</span>"))
										spawn(10)
											var/used = M.use_stamina(25, 2)
											to_chat(M, "-[used] WILL")
									M.playsound_local(M.loc, pick('sound/effects/yewbic_amb1.wav', 'sound/effects/yewbic_amb2.wav', 'sound/effects/yewbic_amb3.wav', 'sound/effects/yewbic_amb4.wav'), 50, 0)
			return rand(100, 150)
/datum/mine_controller/proc/calculate_nextstage()
	if(!target_area)
		message_admins("target_area method 1 failed")
		target_area = locate(/area/mine/explored)
	if(!target_area)
		message_admins("target_area method 2 failed")
		var/turf/simulated/T = locate(180,90,5)
		target_area = T.loc
	var/aggression = (last_aggression - (last_aggression/3))
	aggression += (conglo_mined)
	aggression += (tantiline_mined*1.5)
	aggression += (plasma_mined*2)
	aggression += (orichilum_mined*3)
	aggression += (pulls/5)
	aggression += (bodies)
	aggression += reactions
	aggression = aggression*aggro_multiplier
	last_aggression = aggression
	message_admins("calculate_nextstage() aggression: [aggression]")
	if(current_state == 1)
		if(aggression >= 5)
			current_state++
			new_state = 1
	else if(current_state == 2)
		if(aggression >= 7)
			current_state++ 
			new_state = 1
		if(aggression <= 3)
			current_state--
			new_state = 1
	else if(current_state == 3)
		if(aggression >= 10)
			current_state++
			new_state = 1
		if(aggression <= 3)
			current_state--
			new_state = 1
	else if(current_state == 4)
		if(aggression >= 15)
			current_state++
			new_state = 1
		if(aggression <= 5)
			current_state--
			new_state = 1
	else if(current_state == 5)
		if(aggression <= 10)
			current_state--
			new_state = 1
	handle_change()
	conglo_mined = 0
	tantiline_mined = 0
	plasma_mined = 0
	orichilum_mined = 0
	last_conglo_spawn = 0
	last_tantiline_spawn = 0
	last_plasma_spawn = 0
	last_orichilum_spawn = 0
	last_pull_spawn = 0
	pulls = 0
	bodies = 0
	reactions = 0

	
/datum/mine_controller/proc/handle_change()
	if(new_state)
		new_state = 0
		switch(current_state)
			if(1)
				target_area.areamusic = list(new /datum/music_file/silence_01(), new /datum/music_file/silence_02(), new /datum/music_file/silence_03())
				target_area.musicType = 3
				for(var/mob/M in player_list)
					if(M.z == 5)
						M << 'sound/ambience/ambicha2.ogg'
						if(M.client && M.client.last_music != target_area.musicType && get_area(M) == target_area)
							M.client.handle_ambient_music(pick(target_area.areamusic))
							M.client.last_music = target_area.musicType	
						to_chat(M, "<span class='userdanger'>[pick("An aura of mild calmness spreads over the asteroid. You feel less urgency, more hope..", "Your mind feels quieter.. You no longer feel any guilt.", "A quietness permeates your mind... A fading peace and an end to the greed.")]</span>" )
			if(2)
				target_area.areamusic = list(new /datum/music_file/silence_01(), new /datum/music_file/silence_02(), new /datum/music_file/silence_03())
				target_area.musicType = 3
				for(var/mob/M in player_list)
					if(M.z == 5)
						M.playsound_local(M.loc, pick('sound/effects/earthquake_short.wav','sound/effects/earthquake_short2.wav'), 30, 0)
						M << 'sound/ambience/ambigen5.ogg'
						shake_camera(M, 5, 2)
						if(M.client && M.client.last_music != target_area.musicType && get_area(M) == target_area)
							M.client.handle_ambient_music(pick(target_area.areamusic))
							M.client.last_music = target_area.musicType
						to_chat(M, "<span class='warning'>The ground trembles</span>" )
						to_chat(M, "<span class='userdanger'>[pick("The asteroid is playing tricks on your mind.. You feel a huge sense of dread.", "You feel mentally nauseous; Your mind swims with a thousand half-thoughts.", "The asteroid plays cruel tricks on your mind. it makes you think strange thoughts..")]</span>" )
			if(3)
				target_area.areamusic = list(new /datum/music_file/amb_01(), new /datum/music_file/amb_02())
				target_area.musicType = 4
				for(var/mob/M in player_list)
					if(M.z == 5)
						M.playsound_local(M.loc, pick('sound/effects/earthquake_short.wav','sound/effects/earthquake_short2.wav'), 70, 0)
						M << 'sound/ambience/ambigen11.ogg'
						shake_camera(M, 20, 2)
						if(M.client && M.client.last_music != target_area.musicType && get_area(M) == target_area)
							M.client.handle_ambient_music(pick(target_area.areamusic))
							M.client.last_music = target_area.musicType
						to_chat(M, "<span class='userdanger'>The ground trembles</span>" )
						to_chat(M, "<span class='userdanger'>[pick("The astral-sounds become impossible to ignore. Voices? Or perhaps.. memories.", "You feel yourself trying to understand what the asteroid is doing to you.. Or is it whats been done to it?", "The voices melt away ignorance; leaving guilt and sorrow in equal measure to fester in your mind, but no understanding..")]</span>" )
			if(4)
				target_area.areamusic = list(new /datum/music_file/action_03(), new /datum/music_file/action_04())
				target_area.musicType = 5
				for(var/mob/M in player_list)
					if(M.z == 5)
						M.playsound_local(M.loc, pick('sound/effects/earthquake_short.wav','sound/effects/earthquake_short2.wav'), 90, 0)
						M << 'sound/ambience/yewbic_ambience.wav'
						shake_camera(M, 30, 3)
						if(M.client && M.client.last_music != target_area.musicType && get_area(M) == target_area)
							M.client.handle_ambient_music(pick(target_area.areamusic))
							M.client.last_music = target_area.musicType
						to_chat(M, "<span class='userdanger'>[pick("The noises raise to a level where you can no longer hear yourself think! You struggle to maintin focus!", "These sounds.. You've never heard anything like it and you cant stand it anymore!", "The invading voices become searing daggers through your soul! You're being driven mad by this celestial body!")]</span>" )
						to_chat(M, "<span class='userdanger'>The ground quakes with fury, the rocks scream as they grind together.</span>" )
			if(5)
				target_area.areamusic = list(new /datum/music_file/action_01(), new /datum/music_file/action_02())
				target_area.musicType = 6
				for(var/mob/M in player_list)
					if(M.z == 5)
						M.playsound_local(M.loc, pick('sound/effects/earthquake_short.wav','sound/effects/earthquake_short2.wav'), 100, 0)
						M << 'sound/ambience/yewbic_ambience2.wav'
						shake_camera(M, 40, 5)
						if(!prob(M.get_stat(3)*10))
							M.fall(1)
						if(M.client && M.client.last_music != target_area.musicType && get_area(M) == target_area)
							M.client.handle_ambient_music(pick(target_area.areamusic))
							M.client.last_music = target_area.musicType
						to_chat(M, "<span class='userdanger'>[pick("'..--YOU'VE RUINED US! YOU ARE DEFINED BY YOUR SINS! YOUR GREED CONDEMS US ALL!'", "'..--A TERRIBLE SCOURGE; THAT ALL OF CREATION WILL REJECT YOU! FLORA WILL WILT AND DIE AND ANIMALS WILL TURN FERAL RATHER THAN NOURISH YOU!'", "'..--ONLY HOPE FOR LIFE WILL BE WITHIN MY DEATH! A TESTAMENT TO YOUR PARASITIC NATURE! YOU'VE DOOMED YOURELVES! YOU WILL LIVE ONLY TO SUFFER!'")]</span>" )
						to_chat(M, "<span class='userdanger'>The ground quakes as the asteroid screams itself apart. The conditions are near apocalyptic.</span>" )
/datum/mine_controller/proc/handle_pull(var/turf/T)
	pulls++
	if(pulls-last_pull_spawn > 10 && prob((pulls-last_pull_spawn)*2))
		last_pull_spawn = pulls
		switch(current_state)
			if(1 to 2)
				spawn_petraspider(T)
			if(3)
				if(prob(33))
					spawn_petraspider(T)
				else
					spawn_petraspider(T)
				
/datum/mine_controller/proc/mine_conglo(var/turf/T)
	conglo_mined++
	if(conglo_mined-last_conglo_spawn > 2 && prob((conglo_mined-last_conglo_spawn)*20))
		last_conglo_spawn = conglo_mined
		spawn_petraspider(T)

/datum/mine_controller/proc/spawn_vindictagolem(var/turf/T)
	var/spawnsize = 1
	switch(current_state)
		if(2)
			spawnsize = rand(1,2)
		if(3)
			spawnsize = rand(2,3)
		if(4)
			spawnsize = rand(3,4)
		if(5)
			spawnsize = rand(4,5)
	T.visible_message("<span class='userdanger'>You feel a cruel heat just before the vindictagolems materialize!</span>")
	for(var/turf/simulated/floor/plating/airless/asteroid/asteroidturf in shuffle(orange(T, 4)))
		new /mob/living/simple_animal/hostile/asteroid/vindictagolem(loc = T)
		spawnsize--
		if(!spawnsize)
			return
/datum/mine_controller/proc/spawn_petraspider(var/turf/T)
	for(var/turf/simulated/floor/plating/airless/asteroid/hole/exturf in shuffle(orange(T, 4)))
		exturf.spawner.aggro = 1
		exturf.visible_message("<span class='userdanger'>More petraspiders spill out of the hole, they look hostile!</span>")
		switch(current_state)
			if(1)
				exturf.spawner.spawn_size += rand(1,2)
			if(2)
				exturf.spawner.spawn_size += rand(2,3)
			if(3)
				exturf.spawner.spawn_size += rand(3,4)
			if(4 to 5)
				exturf.spawner.spawn_size += 5		
		return
	for(var/turf/simulated/floor/plating/airless/asteroid/asteroidturf in shuffle(orange(T, 4)))
		if(istype(asteroidturf, /turf/simulated/floor/plating/airless/asteroid/ore)) continue
		if(istype(asteroidturf, /turf/simulated/floor/plating/airless/asteroid/hole)) continue
		var/skip = 0
		for(var/obj/ob in asteroidturf.contents)
			if(istype(ob, /obj/effect)) continue
			skip = 1
			break
		if(skip) continue
		asteroidturf.visible_message("<span class='userdanger'>The ground quakes as vile petraspiders break through the rocky ground and begin to file out!</span>")
		asteroidturf.ChangeTurf(/turf/simulated/floor/plating/airless/asteroid/hole, keep_icon = FALSE)
		var/turf/simulated/floor/plating/airless/asteroid/hole/holeturf = asteroidturf
		for(var/mob/M in view(holeturf))
			if(M.client)
				shake_camera(M, 10, 2)
		if(!holeturf) return
		spawn(10)
			switch(current_state)
				if(1 to 2)
					holeturf.spawner.spawn_size = rand(2,4)
				if(3)
					holeturf.spawner.spawn_size = rand(3,5)
				if(4 to 5)
					holeturf.spawner.spawn_size = rand(4,6)
		break
	
/datum/mine_controller/proc/mine_tantiline(var/turf/T)
	tantiline_mined++
	if(prob((tantiline_mined-last_tantiline_spawn)*5))
		last_conglo_spawn = conglo_mined
		spawn_petraspider(T)
	
/datum/mine_controller/proc/mine_plasma(var/turf/T)
	plasma_mined++
	if(prob((plasma_mined-last_plasma_spawn)*5))
		last_plasma_spawn = plasma_mined
		spawn_petraspider(T)

/datum/mine_controller/proc/mine_orichilum(var/turf/T)
	orichilum_mined++
	if(prob((orichilum_mined-last_orichilum_spawn)*5))
		last_orichilum_spawn = orichilum_mined
		spawn_petraspider(T)

		
/**********************Mine areas*************************/

/area/mine
	icon_state = "mining"

/area/mine/explored
	name = "Mine"
	icon_state = "explored"
	music = null
	ambientsounds = list('sound/ambience/ambimine.ogg')
	musicType = 3
	areamusic = list(new /datum/music_file/silence_01(), new /datum/music_file/silence_02(), new /datum/music_file/silence_03())
	

/area/mine/unexplored
	name = "Mine (unexplored)"
	icon_state = "unexplored"
	music = null
	always_unpowered = 1
	requires_power = 1
	poweralm = 0
	power_environ = 0
	power_equip = 0
	power_light = 0
	ambientsounds = list('sound/ambience/ambimine.ogg')
	
	
/area/mine/lobby
	name = "Mining Station"

/area/mine/storage
	name = "Mining Station Storage"

/area/mine/production
	name = "Mining Station Starboard Wing"
	icon_state = "mining_production"

/area/mine/abandoned
	name = "Abandoned Mining Station"

/area/mine/living_quarters
	name = "Mining Station Port Wing"
	icon_state = "mining_living"

/area/mine/eva
	name = "Mining Station EVA"
	icon_state = "mining_eva"

/area/mine/maintenance
	name = "Mining Station Communications"

/area/mine/cafeteria
	name = "Mining Station Cafeteria"

/area/mine/hydroponics
	name = "Mining Station Hydroponics"

/area/mine/sleeper
	name = "Mining Station Emergency Sleeper"

/area/mine/north_outpost
	name = "North Mining Outpost"

/area/mine/west_outpost
	name = "West Mining Outpost"

/area/mine/podbay
	name = "Mining Podbay"