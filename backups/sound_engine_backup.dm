/*
                SOUND ENGINE
--------------------------------------------

This engine lets you use sounds with relative ease.
Supports location-sounds which updates as you move in/out, fading in/out that way.
Two Music Channels reserved for background music. (1 and 3) Channels 2 and 4 reserved for Fading.
Fading in/out from Music channels when they change.

---------------------------------------------
    Sound Engine programmed by Fushimi
            Skype: live:fushimi_1
---------------------------------------------
*/
// Uncomment next line to debug the sound engine.
// #define SE_DEBUG

// ASSOCIATION OF MUSIC CHANNELS
#define MUSIC_CHANNELS_ASSOC list("1" = 2, "2" = 1, "3" = 4, "4" = 3)

// BEGIN RESERVED CHANNELS FOR BACKGROUND MUSIC.

#define MUSIC_CHANNEL_1 1024
#define MUSIC_CHANNEL_2 1023
#define MUSIC_CHANNEL_3 1022
#define MUSIC_CHANNEL_4 1021

// END OF RESERVED CHANNELS
#if DM_VERSION < 400
    #error This compiler is outdated. Please upgrade to atleast BYOND 4.0
#else
client
    var/tmp
        sound_channels[1]        // Initializes a list with a single null index.
        music_channels[4]        // List of 4 channels. (4 channels is more than enough for background music)
        music_playing[2]         // Can play two songs at the same time. (In four channels, two channels for music, two for fades.

    proc/musicChannel(sound/sound, channel, replace=0)
        if(channel == MUSIC_CHANNEL_1 || channel == MUSIC_CHANNEL_2)
			/**
			var/i = music_playing[1]
            if(i)
                music_channels[(i==1 ? 2 : 1)] = "\ref[sound]"
            else if(isnull(music_channels[1]))
                music_channels[1] = "\ref[sound]"
                . = 1
            else if(isnull(music_channels[2]))
                music_channels[2] = "\ref[sound]"
                . = 2
            if(!.)
                . = 1
			**/
            music_channels[channel] = "\ref[sound]"
            . = channel
        if(channel == MUSIC_CHANNEL_3 || channel == MUSIC_CHANNEL_4)
            var/i = music_playing[2]
            if(i)
                music_channels[(i==3 ? 4 : 3)] = "\ref[sound]"
            else if(isnull(music_channels[3]))
                music_channels[3] = "\ref[sound]"
                . = 3
            else if(isnull(music_channels[4]))
                music_channels[4] = "\ref[sound]"
                . = 4
            if(!.)
                . = i

    proc/firstChannel(sound/sound)                      // Searches for the first channel available and returns after properly setting it.
        if(sound_channels.len==1 && isnull(sound_channels[1]))    // If len is 1 and the index is null, we just use it and early escape.
            sound_channels[1] = "\ref[sound]"                // Un-nullify the index by placing a reference to the sound datum.\
                                                         (No usage as of now, but you have track of sounds a player has playing by checking this list.
            return 1                                 // Does not return true, but the index, keep in mind.

        for(var/i in 1 to sound_channels.len)                // If theres more than one index, iterate list until an available spot is found.
            if(isnull(sound_channels[i]))
                sound_channels[i] = "\ref[sound]"
                return i                                // Store a reference to the sound in the _channels list, and return the available channel.

        . = ++sound_channels.len                                // If no _channels are available on the list, expand the list appropiately for the new sound.
        sound_channels[sound_channels.len] = "\ref[sound]"      // Also sets the default return value to the newly created index, and stores a reference\
                                                                of sound into the index so we can keep track. (If needed)
                                                        // The engine does never de-reference this list, it is just so it is not null.
                                                        // I could just put a TRUE there, but a reference is better if we want to manually\
                                                        //  modify the /sound:
                                                        // var/sound/_sound = locate(_channel[index])
                                                        // _sound.volume = 50
                                                        // _sound.status |= SOUND_UPDATE
                                                        // usr << _sound

/sound
    var/tmp
        timesToRepeat = null
        range = 0
        die = FALSE

    proc
        update(client/client, atom/location, interval = 10, altitude_var = "layer", needsChannel = FALSE)
            ASSERT(client)                                                          // CRASH if no client.
            if(needsChannel == TRUE)                                                // If a channel was not assigned, assign one.
                                                                                    // channels are automatically assigned ONLY for repeated sounds.
                src.channel = (client.firstChannel(src) * 10)                 // Leaves the first 10 channels available for dynamic, unrepeated sounds.
            #ifdef SE_DEBUG
                world<<"[src.channel*10] channel"
            #endif
            if(location && location!=client)                                        // This part sets the distance from within the sound will be heard by the player.
            #ifdef SE_DEBUG
                world<<"[src.x], [src.y], [src.z]"
            #endif
//              src.falloff = src.range
                src.x = location.x - client.mob.x
                var/sy = location.y - client.mob.y
                var/sz = location.vars[altitude_var] - client.mob.vars[altitude_var]
                src.y = (sy + sz) * 0.70710678118655
                src.z = (sy - sz) * 0.70710678118655
            #ifdef SE_DEBUG
                world<<"[src.x], [src.y], [src.z]  - [src.channel]"
            #endif
            if(src.die || src.repeat)
                if(src.die || get_dist(client.mob, location) > src.range*2)
                    client << sound(null,0, wait = 1, channel = src.channel)      // Stops playing the sound in THIS channel. (Other's systems just stops ALL sounds)
                    client.sound_channels[(src.channel/10)] = null
                #ifdef SE_DEBUG
                    world<<"[src.channel*10] channel"
                #endif
                    if((src.channel/10) == client.sound_channels.len)
                        client.sound_channels.len--
                    del src

            src.status |= SOUND_UPDATE
            client << src
            if(src.repeat)  spawn(interval)
                src.update(client, location, interval, altitude_var, FALSE)
            #ifdef SE_DEBUG
                world<<"called update([client], [location], [interval])"
            #endif
            if(!isnull(src.timesToRepeat))
                if(!timesToRepeat--)
                    src.repeat = 0
                    src.timesToRepeat = null
                    src.die = TRUE

/*
Do not pass a value for repeat times unless you actually want it to repeat X times. (0 enables it too.)
*/
proc/_SoundEngine(sound, atom/location, range=1, channel=-1, volume=100, repeat=0, repeat_times=null, interval=10, falloff=range, environment=-1, frequency=0, altitude_var="layer")//BaseRange=10
    if(channel == null)
        channel = -1

    if(!sound) return null

    var/sound/S = null
    var/list/playersToSend = list()
/*
    if(ismob(location))
        if(hasvar(location, "client"))
            playersToSend.Add(location:client)*/

// Still need a better way to do this.

    for(var/mob/M in hearers(range*2, location))
        if(M.client)
            playersToSend.Add(M.client)


    for(var/i in 1 to playersToSend.len step 1)
        var client/client = playersToSend[i]
        if(!client)continue

        S = sound(sound)

        S.channel = channel
        S.frequency = frequency
        S.environment = environment
        S.volume = volume
        S.repeat = repeat
        S.range = range
        S.timesToRepeat = repeat_times
        S.falloff = falloff             // This will let you specify ranges and falloff separately.\
                                            (By default falloff = range | The passed range is multiplied by 2 to get the real range.)\
                                            So range = 5 = falloff = 5 = real_range = 10 where real_range = range*2
    #ifdef SE_DEBUG
        world<<"calling update()"       // Debugging messages just to know where I am at when testing.
    #endif

        spawn S.update(client, location, interval, altitude_var, (repeat ? TRUE : FALSE))       // Updates once, and if needed, recursively updates until out of range.

    return S


proc/_MusicEngine(sound, client/client, channel=MUSIC_CHANNEL_1, pause=0, repeat=0, wait=0, volume=40, instant = 0, time = 20, increments = 10)
    if(!client)
        return null
	if(!sound)
		sound = 'sound/effects/silence.ogg'
	// channel = client.musicChannel(sound, client, 0)
    var sound/S = sound(sound)
    channel = client.musicChannel(S, channel, 0)
    var sound/_fade = null

    var channel_to_fade = MUSIC_CHANNELS_ASSOC["[channel]"]

    if(!isnull(client.music_channels[channel_to_fade]))             // We fade the sound
        message_admins("attempting to fade music")
        _fade = locate(client.music_channels[channel_to_fade])
        if(_fade)
            pause = (pause==1 ? SOUND_PAUSED : (pause==2 ? SOUND_MUTE : 0))

    if(instant)
        pause = 0
        wait = 0

    S.channel = channel
    S.status = (pause ? (SOUND_PAUSED | SOUND_UPDATE) : 0) | (SOUND_UPDATE)
    S.repeat = repeat
    S.wait = wait
    if(instant || !_fade)
        S.volume = volume
    else if(_fade)
        S.volume = 0

    client << S

    if(_fade && !instant)
        var d = _fade.volume / increments
        var inc = d
        time = time / increments

        spawn
            for(var/i = 0; i < increments; i++)
                _fade.volume -= d
                if(!S.volume)
                    S.status = 0
                S.volume += inc

                _fade.status |= SOUND_UPDATE
                S.status |= SOUND_UPDATE
                client << _fade
                client << S
                sleep(time)

            S.volume = volume
            S.status |= SOUND_UPDATE
            client << S
            del(_fade)

    return S

#endif

