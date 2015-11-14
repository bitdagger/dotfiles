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
		 test \
		 install-pianobar \
		 install-sublime3


# ----------------------------------------------------------------
# Default action
# ----------------------------------------------------------------
all :
	@echo "Use 'make install' to install"
	@echo "Check with 'make -n install' to see what will be installed"
	@echo "The following optional packages are also available:"
	@echo " - 'make install-pianobar'"
	@echo " - 'make install-sublime3'"


# ----------------------------------------------------------------
# Just print a message so we don't accidentally delete stuff
# ----------------------------------------------------------------
clean :
	@echo "Use make distclean to clean"
	@echo "Check with make -n distclean to see what will be removed"


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

#	Pianobar
	rm -Rf "$(HOME)"/.config/pianobar

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

#	Sublime3
#	This one is annoying because of the deep directory structure, but we 
#	might want to keep Sublime installed and just remove the config...
	rm -f "$(HOME)"/.config/sublime-text-3/Packages/User/Preferences.sublime-settings

#	Tmux
	rm -f "$(HOME)"/.tmux.conf


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
