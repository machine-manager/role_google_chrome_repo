alias Converge.Util

defmodule RoleWine do
	require Util
	Util.declare_external_resources("files")

	def role(_tags \\ []) do
		wine_packages = [
			"wine-staging",
			"winehq-staging", # to set up wine-staging as the default wine (/usr/bin/wine)
			"winetricks",     # note that we have a newer version in custom-packages
		]
		%{
			desired_packages: wine_packages,
			apt_keys:         [content("files/apt_keys/77C899CB Launchpad PPA for Wine.txt")],
			apt_sources:      ["deb http://ppa.launchpad.net/wine/wine-builds/ubuntu xenial main"],
		}
	end
end
