.PHONY : all \
		 clean \
		 distclean \
		 clean-bash \
		 clean-git \
		 clean-gnupg \
		 clean-history \
		 clean-nano \
		 clean-pianobar \
		 clean-sh \
		 clean-ssh \
		 clean-tmux \
		 install \
		 install-bash \
		 install-git \
		 install-gnupg \
		 install-history \
		 install-nano \
		 install-pianobar \
		 install-sh \
		 test \
		 test-bash \
		 test-sh

all :
	@echo "Sup"

clean :
	@echo "Use distclean to clean"
	@echo "Check with make -n distclean to see what will be removed"

distclean : clean-bash \
			clean-git \
			clean-gnupg \
			clean-history \
			clean-nano \
			clean-pianobar \
			clean-sh \
			clean-ssh \
			clean-tmux

clean-bash :
	rm -f "$(HOME)"/.bashrc
	rm -f "$(HOME)"/.bash_bash_profile
	rm -f "$(HOME)"/.bash_logout
	rm -Rf "$(HOME)"/.bash.d

clean-git :
	rm -f "$(HOME)"/.gitconfig

clean-gnupg :
	rm -f "$(HOME)"/.gnupg/*.conf

clean-nano :
	rm -f "$(HOME)"/.nanorc

clean-pianobar :
	rm -Rf "$(HOME)"/.config/pianobar

clean-history :
	rm -f "$(HOME)"/.history
	rm -f "$(HOME)"/.recently_used
	rm -f "$(HOME)"/.mysql_history
	rm -f "$(HOME)"/.bash_history

clean-sh :
	rm -f "$(HOME)"/.profile
	rm -Rf "$(HOME)"/.profile.d

clean-ssh :
	rm -f "$(HOME)"/.ssh/config

clean-tmux :
	rm -f "$(HOME)"/.tmux.conf

install : install-bash \
		  install-git \
		  install-gnupg \
		  install-history \
		  install-nano \
		  install-pianobar \
		  install-sh \
		  install-ssh \
		  install-tmux

install-bash : test-bash
	install -m 0755 -d -- "$(HOME)"/.bashrc.d
	install -m 0644 -- bash/bashrc "$(HOME)"/.bashrc
	install -m 0644 -- bash/bashrc.d/* "$(HOME)"/.bashrc.d
	install -m 0644 -- bash/bash_profile "$(HOME)"/.bash_profile
	install -m 0644 -- bash/bash_logout "$(HOME)"/.bash_logout

install-git :
	install -m 0644 -- git/gitconfig "$(HOME)"/.gitconfig

install-gnupg :
	install -m 0700 -d -- "$(HOME)"/.gnupg
	install -m 0600 -- gnupg/*.conf "$(HOME)"/.gnupg

install-history :
	ln -sfn /dev/null "$(HOME)"/.history
	ln -sfn /dev/null "$(HOME)"/.recently_used
	ln -sfn /dev/null "$(HOME)"/.mysql_history
	ln -sfn /dev/null "$(HOME)"/.bash_history

install-nano :
	install -m 0644 -- nano/nanorc "$(HOME)"/.nanorc

install-pianobar :
	install -m 0755 -d -- "$(HOME)"/.config/pianobar
	install -m 0644 -- pianobar/config "$(HOME)"/.config/pianobar/config
	install -m 0755 -- pianobar/eventcmd "$(HOME)"/.config/pianobar/eventcmd

install-sh : test-sh
	install -m 0755 -d -- "$(HOME)"/.profile.d
	install -m 0644 -- sh/profile "$(HOME)"/.profile
	install -m 0644 -- sh/profile.d/* "$(HOME)"/.profile.d

install-ssh :
	install -m 0700 -d -- "$(HOME)"/.ssh
	install -m 0600 -- ssh/config "$(HOME)"/.ssh/config

install-tmux :
	install -m 0644 -- tmux/tmux.conf "$(HOME)"/.tmux.conf

test : test-bash test-sh

test-bash :
	@for bash in bash/* bash/bashrc.d/* ; do \
		if [ -f "$$bash" ] && ! bash -n "$$bash" ; then \
			exit 1 ; \
		fi \
	done
	@echo "All bash(1) scripts parsed successfully."

test-sh :
	@for sh in sh/* sh/profile.d/* ; do \
		if [ -f "$$sh" ] && ! sh -n "$$sh" ; then \
			exit 1 ; \
		fi \
	done
	@echo "All sh(1) scripts parsed successfully."
