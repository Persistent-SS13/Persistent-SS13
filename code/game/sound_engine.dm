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
            var/i = music_playing[1]
            if(i)
                music_channels[(i==1 ? 2 : 1)] = sound
            else if(isnull(music_channels[1]))
                music_channels[1] = sound
                . = 1
            else if(isnull(music_channels[2]))
                music_channels[2] = sound
                . = 2
            if(!.)
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
                . = channel

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


proc/_MusicEngine(sound, client/client, channel=MUSIC_CHANNEL_1, pause=0, repeat=0, wait=0, volume=15, instant = 0, time = 20, increments = 10)
    if(!client)
        return null
    if(!sound)
        sound = 'sound/effects/silence.mid'
    var sound/S = sound(sound)
    channel = client.musicChannel(S, channel, 0)
    var sound/_fade = null

    var channel_to_fade = MUSIC_CHANNELS_ASSOC["[channel]"]
    if(!isnull(client.music_channels[channel_to_fade]))             // We fade the sound
        _fade = client.music_channels[channel_to_fade]
        if(_fade)
            pause = (pause==1 ? SOUND_PAUSED : (pause==2 ? SOUND_MUTE : 0))
    if(instant)
        pause = 0
        wait = 0
    S.channel = channel
    S.status = (pause ? (SOUND_PAUSED | SOUND_UPDATE) : 0) | (SOUND_UPDATE)
    if(_fade)
        S.status = 0
    S.repeat = repeat
    S.wait = wait
    if(instant || !_fade)
        S.volume = volume
    else if(_fade)
        S.volume = 0

    client << S

    if(_fade && !instant)
        message_admins("attempting to fade..")
        var d = _fade.volume / increments
        var inc = d
        time = time / increments

        spawn(0)
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


/*
// The new debugging verb. Just modify the soundfiles, or the verb itself. There are 4 phases on the tests.
// 1: Does calls to the new SoundEngine and the Old to the rate of _calls value. (20 calls minimum, I usually test with 1200-2000).
// 2: Places a sound in a random location around you in order to check if distance of sound is perceptible.
// 3: Places a sound in repeat mode in a random turf around you, walk around it to check for fading in/out effects. Run away from it (range+1) for it to be deleted.
// 4: Places three sounds in repeat mode in random spots around you. By moving around you will notice how fading in/out from one sound to another happens.
//      This one is a bit harder to notice as some sounds are louder than others, try to find different sounds that plays at the same volume (Soundfile's not /sound volume)
// At the very end, it outputs the length of your _channels list (which is always 1 as minimum) and also if it is null (Always null if no sound is being played)

mob/verb
    Test_Sound_Engine_Stats()
        set category = "Debug"
        if(alert(usr, "Enable your profiler before proceeding.\n Do you want to proceed now?","Proceed","Yes","No")=="Yes")
            var/_calls = max(10, input(usr, "How many calls to each proc do you want to perform?") as num)
            while(_calls--)
                spawn
                    _SoundEngine('SFX/AttackSwish1.wav', usr, range=5)
                    src.SoundEngine('SFX/AttackSwish1.wav',5)
                sleep(0.5)

            alert(usr, "Okay, now check the profiler and look for both, mob/proc/SoundEngine and /proc/_SoundEngine and compare them.\n Now when you are ready hit ok and we will proceed with the test.")
            alert(usr, "The next test is to ensure that the falloff of the sound works as expected. You will hear a slash coming from various locations.")
            _calls = 20
            var/turf/location
            while(_calls--)

                do
                    location = locate(usr.x - rand(-7,7), usr.y - rand(-7,7), usr.z)
                while(isnull(location))

                location.overlays += icon('target1.dmi', "marker")
                var app = location.overlays[location.overlays.len]
                _SoundEngine('SFX/AttackSwish1.wav', location, range=5)
                sleep(15)
                location.overlays.Remove(app)
            alert(usr, "The next check will play a repeated sound on a turf, so you can walk around and see if sound updates.")
            var/sound/_sound = _SoundEngine('SFX/RasCharge.wav', location, range=5, repeat=1)     // _SoundEngine also returns the sound it used for you to manipulate it if needed!
                                                                                                    // However special care must be put.
            while(_sound)
                sleep(50)
            alert(usr, "In the next phase of the testing stage, you will hear three sounds repeteadly at the same time and different locations.")
            _sound = _SoundEngine('SFX/RasCharge.wav', locate(usr.x - rand(-7,7), usr.y - rand(-7,7), usr.z) || location, range=5,repeat=1,falloff=2)
            var/sound/_sound2 = _SoundEngine('SFX/FluteDNote.wav', locate(usr.x - rand(-7,7), usr.y - rand(-7,7), usr.z) || location, range=5,repeat=1,falloff=2)
            var/sound/_sound3 = _SoundEngine('SFX/GuitarFNote.wav', locate(usr.x - rand(-7,7), usr.y - rand(-7,7), usr.z) || location, range=5,repeat=1,falloff=2)
            while(_sound || _sound2 || _sound3)
                sleep(50)

            alert(usr, "Your _channels' len is: [usr.client._channels.len]")

*/


#endif