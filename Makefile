#
# Makefile
# 
# Things should be fairly strightforward. Use the following to do stuff:
#
# make = Display a welcome message
# make install = Install the files
# make clean = Display a message telling you to use distclean
# make distclean = Remove all installed files
#


# ----------------------------------------------------------------
# Define phony targets
# ----------------------------------------------------------------
.PHONY : all \
		 clean \
		 distclean \
		 install \
		 copy \
		 test \
		 install-pianobar \
		 install-sublime3 \
		 install-X \
		 copy-pianobar \
		 copy-sublime3 \
		 copy-X


# ----------------------------------------------------------------
# Default action
# ----------------------------------------------------------------
all :
	@echo "Use 'make install' to install"
	@echo "Check with 'make -n install' to see what will be installed"
	@echo "The following optional packages are also available:"
	@echo " - 'make install-pianobar'"
	@echo " - 'make install-sublime3'"
	@echo " - 'make install-X'"
	@echo "Use 'make copy' to copy existing config to the repo"


# ----------------------------------------------------------------
# Just print a message so we don't accidentally delete stuff
# ----------------------------------------------------------------
clean :
	@echo "Use make distclean to clean"
	@echo "Check with make -n distclean to see what will be removed"
	@echo "The following optional packages are also available to clean:"
	@echo " - 'make clean-pianobar'"
	@echo " - 'make clean-sublime3'"
	@echo " - 'make clean-X'"


# ----------------------------------------------------------------
# Actually delete everything we have installed
# ----------------------------------------------------------------
distclean : 
#	Bash
	rm -f "$(HOME)"/.bashrc
	rm -f "$(HOME)"/.bash_bash_profile
	rm -f "$(HOME)"/.bash_logout
	rm -Rf "$(HOME)"/.bash.d

#	Git
	rm -f "$(HOME)"/.gitconfig

#	GNUPG
	rm -f "$(HOME)"/.gnupg/*.conf

#	Nano
	rm -f "$(HOME)"/.nanorc

#	History
	rm -f "$(HOME)"/.history
	rm -f "$(HOME)"/.recently_used
	rm -f "$(HOME)"/.mysql_history
	rm -f "$(HOME)"/.bash_history
	rm -f "$(HOME)"/.python_history
	rm -f "$(HOME)"/.sqlite_history

#	Shell
	rm -f "$(HOME)"/.profile
	rm -Rf "$(HOME)"/.profile.d

#	SSH
	rm -f "$(HOME)"/.ssh/config

#	Tmux
	rm -f "$(HOME)"/.tmux.conf


# ----------------------------------------------------------------
# Optional Cleans
# ----------------------------------------------------------------
clean-sublime3 : 
	rm -f "$(HOME)"/.config/sublime-text-3/Packages/User/Preferences.sublime-settings


clean-pianobar : 
	rm -Rf "$(HOME)"/.config/pianobar


clean-X : 
	rm -f "$(HOME)"/.xinitrc
	rm -f "$(HOME)"/.xscreensaver
	rm -f "$(HOME)"/.config/xfce4/terminal/darkglow.jpg
	rm -f "$(HOME)"/.config/xfce4/terminal/terminalrc


# ----------------------------------------------------------------
# Actually install all the core configuration files
# ----------------------------------------------------------------
install : test
#	Bash
	@install -m 0755 -d -- "$(HOME)"/.bashrc.d
	@install -m 0644 -- bash/bashrc "$(HOME)"/.bashrc
	@install -m 0644 -- bash/bashrc.d/* "$(HOME)"/.bashrc.d
	@install -m 0644 -- bash/bash_profile "$(HOME)"/.bash_profile
	@install -m 0644 -- bash/bash_logout "$(HOME)"/.bash_logout

#	Git
	@install -m 0644 -- git/gitconfig "$(HOME)"/.gitconfig

# 	GNUPG
	@install -m 0700 -d -- "$(HOME)"/.gnupg
	@install -m 0600 -- gnupg/*.conf "$(HOME)"/.gnupg

# 	History
	@ln -sf /dev/null "$(HOME)"/.history
	@ln -sf /dev/null "$(HOME)"/.recently_used
	@ln -sf /dev/null "$(HOME)"/.mysql_history
	@ln -sf /dev/null "$(HOME)"/.python_history
	@ln -sf /dev/null "$(HOME)"/.sqlite_history
	@ln -sf /dev/null "$(HOME)"/.bash_history

# 	Nano
	@install -m 0644 -- nano/nanorc "$(HOME)"/.nanorc

# 	Shell
	@install -m 0755 -d -- "$(HOME)"/.profile.d
	@install -m 0644 -- sh/profile "$(HOME)"/.profile
	@install -m 0644 -- sh/profile.d/* "$(HOME)"/.profile.d

# 	SSH
	@install -m 0700 -d -- "$(HOME)"/.ssh
	@install -m 0600 -- ssh/config "$(HOME)"/.ssh/config

# 	Tmux
	@install -m 0644 -- tmux/tmux.conf "$(HOME)"/.tmux.conf

# ----------------------------------------------------------------
# Test scripts
# ----------------------------------------------------------------
test : 
#	Shell
	@for sh in sh/* sh/profile.d/* ; do \
		if [ -f "$$sh" ] && ! sh -n "$$sh" ; then \
			exit 1 ; \
		fi \
	done

#	Bash
	@for bash in bash/* bash/bashrc.d/* ; do \
		if [ -f "$$bash" ] && ! bash -n "$$bash" ; then \
			exit 1 ; \
		fi \
	done

# ----------------------------------------------------------------
# Optional Installs
# ----------------------------------------------------------------

install-pianobar :
	@install -m 0755 -d -- "$(HOME)"/.config/pianobar
	@install -m 0644 -- pianobar/config "$(HOME)"/.config/pianobar/config
	@install -m 0755 -- pianobar/eventcmd "$(HOME)"/.config/pianobar/eventcmd

install-sublime3 :
	@install -m 0755 -d -- "$(HOME)"/.config/sublime-text-3/Packages/User/
	@install -m 0644 -- sublime3/Preferences.sublime-settings "$(HOME)"/.config/sublime-text-3/Packages/User/Preferences.sublime-settings

install-X :
	@install -m 0755 -d -- "$(HOME)"/.config/xfce4/terminal/
	@install -m 0644 -- X/xinitrc "$(HOME)"/.xinitrc
	@install -m 0644 -- X/xscreensaver "$(HOME)"/.xscreensaver
	@install -m 0644 -- X/xfce4/darkglow.jpg "$(HOME)"/.config/xfce4/terminal/darkglow.jpg
	@install -m 0644 -- X/xfce4/terminalrc "$(HOME)"/.config/xfce4/terminal/terminalrc

# ----------------------------------------------------------------
# Copy existing config to the repo
# ----------------------------------------------------------------
copy : 
#	Bash
	@install -m 0644 -- "$(HOME)"/.bashrc bash/bashrc
	@install -m 0644 -- "$(HOME)"/.bashrc.d/* bash/bashrc.d
	@install -m 0644 -- "$(HOME)"/.bash_profile bash/bash_profile 
	@install -m 0644 -- "$(HOME)"/.bash_logout bash/bash_logout

#	Git
	@install -m 0644 -- "$(HOME)"/.gitconfig git/gitconfig

# 	GNUPG
	@install -m 0600 -- "$(HOME)"/.gnupg/*.conf gnupg

# 	Nano
	@install -m 0644 -- "$(HOME)"/.nanorc nano/nanorc

# 	Shell
	@install -m 0644 -- "$(HOME)"/.profile sh/profile
	@install -m 0644 -- "$(HOME)"/.profile.d/* sh/profile.d

# 	SSH
	@install -m 0600 -- "$(HOME)"/.ssh/config ssh/config

# 	Tmux
	@install -m 0644 -- "$(HOME)"/.tmux.conf tmux/tmux.conf

# ----------------------------------------------------------------
# Optional Copies
# ----------------------------------------------------------------

copy-pianobar :
	@install -m 0644 -- "$(HOME)"/.config/pianobar/config pianobar/config
	@install -m 0755 -- "$(HOME)"/.config/pianobar/eventcmd pianobar/eventcmd

copy-sublime3 :
	@install -m 0644 -- "$(HOME)"/.config/sublime-text-3/Packages/User/Preferences.sublime-settings sublime3/Preferences.sublime-settings

copy-X :
	@install -m 0644 -- "$(HOME)"/.xinitrc X/xinitrc
	@install -m 0644 -- "$(HOME)"/.xscreensaver X/xscreensaver
	@install -m 0644 -- "$(HOME)"/.config/xfce4/terminal/terminalrc X/xfce4/terminalrc
