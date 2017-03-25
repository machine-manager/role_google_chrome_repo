alias Converge.{Util, All, FilePresent, FileMissing}

defmodule RoleGoogleChromeRepo do
	require Util
	Util.declare_external_resources("files")

	def role(_tags \\ []) do
		# We don't install any particular Chrome package here because there are
		# three to choose from: google-chrome-{stable,beta,unstable}
		etc_default_files =
			%All{units: [
				# Google Chrome installs symlinks at /etc/cron.daily/google-chrome*;
				# these scripts function as a little configuration manager that re-adds
				# apt keys and apt sources if they are missing (e.g. after an Ubuntu
				# upgrade).  Make these scripts no-ops to prevent them from re-adding
				# the obsolete 7FAC5991 key to apt's trusted keys, and to stop them
				# from mucking with /etc/apt/sources.list.d/
				#
				# Do this before installing Chrome, to prevent the cron.daily scripts
				# from being run at install time.
				%FilePresent{path: "/etc/default/google-chrome",          content: "exit 0\n", mode: 0o644},
				%FilePresent{path: "/etc/default/google-chrome-beta",     content: "exit 0\n", mode: 0o644},
				%FilePresent{path: "/etc/default/google-chrome-unstable", content: "exit 0\n", mode: 0o644},
			]}
		%{
			apt_keys:         [Util.content("files/apt_keys/D38B4796 Google Inc. (Linux Packages Signing Authority).txt")],
			apt_sources:      ["deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main"],
			pre_install_unit: etc_default_files,
			post_install_unit: %All{units: [
				# The scripts in /etc/cron.daily/ are already no-op'ed by the /etc/default/google-chrome-*
				# files, but delete them anyway because we don't need them.  Note that
				# they will re-appear after every Chrome upgrade.  (We can't set them to
				# blank chattr +i'ed files because that breaks upgrades.)
				%FileMissing{path: "/etc/cron.daily/google-chrome"},
				%FileMissing{path: "/etc/cron.daily/google-chrome-beta"},
				%FileMissing{path: "/etc/cron.daily/google-chrome-unstable"},

				# Do this in post_install_unit as well because if e.g. google-chrome-unstable
				# is being purged, apt will remove /etc/cron.daily/google-chrome-unstable and
				# cause a converge failure.
				etc_default_files,
			]},
		}
	end
end
