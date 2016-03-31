/client/verb/ooc(msg as text)
	set name = "OOC" //Gave this shit a shorter name so you only have to time out "ooc" rather than "ooc message" to use it --NeoFite
	set category = "OOC"

	if(!mob)	return

	msg = copytext(sanitize(msg), 1, MAX_MESSAGE_LEN)
	if(!msg)	return

	if(!(prefs.chat_toggles & CHAT_OOC))
		src << "<span class='danger'>You have OOC muted.</span>"
		return

	if(oocmuted(ckey))
		src << "<span class='danger'><big><b>No way for you, dick.</b></big></span>"
		return

	if(!holder)
		if(!ooc_allowed)
			src << "<span class='danger'>OOC is globally muted.</span>"
			return
		if(!dooc_allowed && (mob.stat == DEAD))
			usr << "<span class='danger'>OOC for dead mobs has been turned off.</span>"
			return
		if(prefs.muted & MUTE_OOC)
			src << "<span class='danger'>You cannot use OOC (muted).</span>"
			return
		if(handle_spam_prevention(msg,MUTE_OOC))
			return

	log_ooc("[mob.name]/[key] : [msg]")

	var/keyname = key
	var/donator_icon = ""

	msg = emoji_parse(msg)
	msg = kappa_parse(msg)
	if(is_donator(key) && !holder.fakekey)
		donator_icon = "<img class=icon src=\ref['icons/donator.dmi'] iconstate='[key]'>"
	if(holder)
		if(holder.fakekey && is_donator(holder.fakekey))
			donator_icon = "<img class=icon src=\ref['icons/donator.dmi'] iconstate='[holder.fakekey]'>"



	for(var/client/C in clients)
		if(C.prefs.chat_toggles & CHAT_OOC)
			if(holder)
				if(!holder.fakekey || C.holder)
					if(check_rights_for(src, R_ADMIN))
						C << "<font color=[config.allow_admin_ooccolor ? prefs.ooccolor :"#b82e00" ]><b><span class='prefix'>OOC: [donator_icon]</span> <EM>[keyname][holder.fakekey ? "/([holder.fakekey])" : ""]:</EM> <span class='message'>[msg]</span></b></font>"
					else
						C << "<span class='adminobserverooc'><span class='prefix'>OOC:[donator_icon]</span> <EM>[keyname][holder.fakekey ? "/([holder.fakekey])" : ""]:</EM> <span class='message'>[msg]</span></span>"
				else
					C << "<font color='[normal_ooc_colour]'><span class='ooc'><span class='prefix'>OOC:[donator_icon]</span> <EM>[holder.fakekey ? holder.fakekey : key]:</EM> <span class='message'>[msg]</span></span></font>"
			else
				C << "<font color='[normal_ooc_colour]'><span class='ooc'><span class='prefix'>OOC:[donator_icon]</span <EM>[keyname]:</EM> <span class='message'>[msg]</span></span></font>"

/proc/toggle_ooc()
	ooc_allowed = !( ooc_allowed )
	if (ooc_allowed)
		world << "<B>The OOC channel has been globally enabled!</B>"
	else
		world << "<B>The OOC channel has been globally disabled!</B>"

/proc/auto_toggle_ooc(var/on)
	if(!config.ooc_during_round && ooc_allowed != on)
		toggle_ooc()

var/global/normal_ooc_colour = "#002eb8"

/client/verb/colorooc()
	set name = "Set Your OOC Color"
	set category = "Preferences"

	if(!holder || check_rights_for(src, R_ADMIN))
		return

	var/new_ooccolor = input(src, "Please select your OOC color.", "OOC color", prefs.ooccolor) as color|null
	if(new_ooccolor)
		prefs.ooccolor = sanitize_ooccolor(new_ooccolor)
		prefs.save_preferences()
	return

//Checks admin notice
/client/verb/admin_notice()
	set name = "Adminnotice"
	set category = "Admin"
	set desc ="Check the admin notice if it has been set"

	if(admin_notice)
		src << "<span class='boldnotice'>Admin Notice:</span>\n \t [admin_notice]"
	else
		src << "<span class='notice'>There are no admin notices at the moment.</span>"

/client/verb/motd()
	set name = "MOTD"
	set category = "OOC"
	set desc ="Check the Message of the Day"

	if(join_motd)
		src << sanitize_russian("<div class=\"motd\">[join_motd]</div>")
	else
		src << "<span class='notice'>The Message of the Day has not been set.</span>"

/client/proc/self_notes()
	set name = "View Admin Notes"
	set category = "OOC"
	set desc = "View the notes that admins have written about you"

	if(!config.see_own_notes)
		usr << "<span class='notice'>Sorry, that function is not enabled on this server.</span>"
		return

	see_own_notes()

// DOUNTs from Shepherds Mom
/proc/is_donator(var/key as text)
	if(key in donator_icons)
		return 1
	return 0