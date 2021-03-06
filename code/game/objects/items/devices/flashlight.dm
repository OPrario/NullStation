/obj/item/device/flashlight
	name = "flashlight"
	desc = "A hand-held emergency light."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "flashlight"
	item_state = "flashlight"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/flashlights_n_lamps.dmi', "right_hand" = 'icons/mob/in-hand/right/flashlights_n_lamps.dmi')
	origin_tech = Tc_ENGINEERING + "=1"
	w_class = W_CLASS_SMALL
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BELT
	starting_materials = list(MAT_IRON = 50, MAT_GLASS = 20)
	w_type = RECYK_ELECTRONIC
	melt_temperature = MELTPOINT_STEEL // Assuming big beefy fucking maglite.
	action_button_name = "Toggle Light"
	var/on = 0
	var/brightness_on = 4 //luminosity when on
	var/has_sound = 1 //The CLICK sound when turning on/off
	var/sound_on = 'sound/items/flashlight_on.ogg'
	var/sound_off = 'sound/items/flashlight_off.ogg'

/obj/item/device/flashlight/initialize()
	..()
	if(on)
		icon_state = "[initial(icon_state)]-on"
		set_light(brightness_on)
	else
		icon_state = initial(icon_state)
		set_light(0)

/obj/item/device/flashlight/proc/update_brightness(var/mob/user = null, var/playsound = 1)
	if(on)
		icon_state = "[initial(icon_state)]-on"
		set_light(brightness_on)
		if(playsound && has_sound)
			if(get_turf(src))
				playsound(get_turf(src), sound_on, 50, 1)
	else
		icon_state = initial(icon_state)
		set_light(0)
		if(playsound && has_sound)
			playsound(get_turf(src), sound_off, 50, 1)

/obj/item/device/flashlight/attack_self(mob/user)
	if(!isturf(user.loc))
		to_chat(user, "You cannot turn the light on while in this [user.loc].")//To prevent some lighting anomalities.

		return 0
	on = !on
	update_brightness(user)
	return 1


/obj/item/device/flashlight/attack(mob/living/M as mob, mob/living/user as mob)
	add_fingerprint(user)
	if(on && user.zone_sel.selecting == "eyes")

		if((clumsy_check(user) || user.getBrainLoss() >= 60) && prob(50))	//too dumb to use flashlight properly
			return ..()	//just hit them in the head

		if (!user.dexterity_check())
			to_chat(user, "<span class='notice'>You don't have the dexterity to do this!</span>")
			return

		var/mob/living/carbon/human/H = M	//mob has protective eyewear
		if(istype(M, /mob/living/carbon/human))
			var/obj/item/eye_protection = H.get_body_part_coverage(EYES)
			if(eye_protection)
				to_chat(user, "<span class='notice'>You're going to need to remove their [eye_protection] first.</span>")
				return

		if(M == user)	//they're using it on themselves
			if(!M.blinded)
				M.flash_eyes(visual = 1)
				M.visible_message("<span class='notice'>[M] directs [src] to \his eyes.</span>", \
									 "<span class='notice'>You wave the light in front of your eyes! Trippy!</span>")
			else
				M.visible_message("<span class='notice'>[M] directs [src] to \his eyes.</span>", \
									 "<span class='notice'>You wave the light in front of your eyes.</span>")
			return

		user.visible_message("<span class='notice'>[user] directs [src] to [M]'s eyes.</span>", \
							 "<span class='notice'>You direct [src] to [M]'s eyes.</span>")

		if(istype(M, /mob/living/carbon/human) || istype(M, /mob/living/carbon/monkey))	//robots and aliens are unaffected
			if(M.stat == DEAD || M.sdisabilities & BLIND)	//mob is dead or fully blind
				to_chat(user, "<span class='notice'>[M] pupils does not react to the light!</span>")
			else if(M_XRAY in M.mutations)	//mob has X-RAY vision
				M.flash_eyes(visual = 1)
				to_chat(user, "<span class='notice'>[M] pupils give an eerie glow!</span>")
			else	//they're okay!
				if(!M.blinded)
					M.flash_eyes(visual = 1)
					to_chat(user, "<span class='notice'>[M]'s pupils narrow.</span>")
	else
		return ..()

/obj/item/device/flashlight/pen
	name = "penlight"
	desc = "A pen-sized light, used by medical staff."
	icon_state = "penlight"
	item_state = ""
	flags = FPRINT
	siemens_coefficient = 1
	brightness_on = 2
	has_sound = 0

/obj/item/device/flashlight/tactical
	name = "tactical light"
	desc = "A compact, helmet-mounted flashlight attachment."
	icon_state = "tacticoollight"
	item_state = ""

// the desk lamps are a bit special
/obj/item/device/flashlight/lamp
	name = "desk lamp"
	desc = "A desk lamp with an adjustable mount."
	icon_state = "lamp"
	item_state = "lamp"
	brightness_on = 5
	w_class = W_CLASS_LARGE
	flags = FPRINT
	siemens_coefficient = 1
	starting_materials = null
	on = 1

/obj/item/device/flashlight/lamp/cultify()
	new /obj/structure/cult/pylon(loc)
	qdel(src)

// green-shaded desk lamp
/obj/item/device/flashlight/lamp/green
	desc = "A classic green-shaded desk lamp."
	icon_state = "lampgreen"
	item_state = "lampgreen"
	brightness_on = 5


/obj/item/device/flashlight/lamp/verb/toggle_light()
	set name = "Toggle light"
	set category = "Object"
	set src in oview(1)

	if(!usr.stat)
		attack_self(usr)

// FLARES

/obj/item/device/flashlight/flare
	name = "flare"
	desc = "A red Nanotrasen issued flare. There are instructions on the side, it reads 'pull cord, make light'."
	w_class = W_CLASS_SMALL
	brightness_on = 4 // Pretty bright.
	light_power = 2.5
	icon_state = "flare"
	item_state = "flare"
	action_button_name = null //just pull it manually, neckbeard.
	sound_on = "sound/items/flare_on.ogg"
	sound_off = ""
	var/fuel = 0
	var/on_damage = 7
	var/produce_heat = 1500
	var/H_color = ""

	light_color = LIGHT_COLOR_FLARE

/obj/item/device/flashlight/flare/is_hot()
	return on * produce_heat

/obj/item/device/flashlight/flare/New()
	fuel = rand(300, 500) // Sorry for changing this so much but I keep under-estimating how long X number of ticks last in seconds.
	..()

/obj/item/device/flashlight/flare/process()
	var/turf/pos = get_turf(src)
	if(pos)
		pos.hotspot_expose(produce_heat, 5,surfaces=istype(loc,/turf))
	fuel = max(fuel - 1, 0)
	if(!fuel || !on)
		turn_off()
		if(!fuel)
			icon_state = "[initial(icon_state)]-empty"
		processing_objects -= src

/obj/item/device/flashlight/flare/proc/turn_off()
	on = 0
	src.force = initial(src.force)
	src.damtype = initial(src.damtype)
	item_state = "[initial(item_state)][on]"
	if(ismob(loc))
		var/mob/U = loc
		update_brightness(U)
	else
		update_brightness()

/obj/item/device/flashlight/flare/attack_self(mob/user)

	// Usual checks
	if(!fuel)
		to_chat(user, "<span class='notice'>It's out of fuel.</span>")
		return
	if(on)
		return
	// All good, turn it on.
	user.visible_message("<span class='notice'>[user] activates the flare.</span>", "<span class='notice'>You pull the cord on the flare, activating it!</span>")
	Light(user)

/obj/item/device/flashlight/flare/proc/Light(var/mob/user as mob)
	if(user && !isturf(user.loc))
		to_chat(user, "You cannot turn the light on while in this [user.loc].") //To prevent some lighting anomalities.
		return 0

	on = TRUE
	force = on_damage
	damtype = "fire"

	item_state = "[item_state][on]"

	processing_objects += src
	if(user)
		update_brightness(user)
	else
		update_brightness()

	update_icon()

/obj/item/device/flashlight/flare/ever_bright/New()
	. = ..()
	fuel = INFINITY
	Light()


// TORCHS

/obj/item/device/flashlight/flare/torch
	name = "torch"
	desc = "An old fashioned way to produce light."
	w_class = W_CLASS_LARGE

	icon_state = "torch"
	item_state = "torch"

	sound_on = 'sound/items/torch_light.ogg'
	sound_off = 'sound/items/torch_snuff.ogg'

	light_color = LIGHT_COLOR_FIRE

	force = 6
	on_damage = 12

	produce_heat = 10000

//	var/maxfuel = 1000

/obj/item/device/flashlight/flare/torch/attack_self()
	return

/obj/item/device/flashlight/flare/torch/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if(W.is_hot())
		user.visible_message("<span class='notice'>[user] lights [src] with [W].</span>", "<span class='notice'>You light [src] with [W].</span>")
		Light()

// SLIME LAMP
/obj/item/device/flashlight/lamp/slime
	name = "slime lamp"
	desc = "A lamp powered by a slime core. You can adjust its brightness by touching it."
	icon_state = "slimelamp"
	item_state = ""
	origin_tech = Tc_BIOTECH + "=3"
	light_color = LIGHT_COLOR_SLIME_LAMP
	on = 0
	luminosity = 2
	has_sound = 0
	var/brightness_max = 6
	var/brightness_min = 2

/obj/item/device/flashlight/lamp/slime/initialize()
	..()
	if(on)
		icon_state = "[initial(icon_state)]-on"
		set_light(brightness_max)
	else
		icon_state = initial(icon_state)
		set_light(brightness_min)

/obj/item/device/flashlight/lamp/slime/proc/slime_brightness(var/mob/user = null)
	if(on)
		icon_state = "[initial(icon_state)]-on"
		set_light(brightness_max)
	else
		icon_state = initial(icon_state)
		set_light(brightness_min)

/obj/item/device/flashlight/lamp/slime/attack_self(mob/user)
	if(!isturf(user.loc))
		to_chat(user, "You cannot turn the light on while in this [user.loc].")
		return 0
	on = !on
	slime_brightness(user)
	return 1
