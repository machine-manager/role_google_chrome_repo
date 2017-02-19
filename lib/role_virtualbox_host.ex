alias Converge.Util

defmodule RoleVirtualboxHost do
	require Util
	Util.declare_external_resources("files")

	def role(_tags \\ []) do
		%{
			desired_packages: ["virtualbox-5.1"],
			apt_keys:         [Util.content("files/apt_keys/2980AECF Oracle Corporation (VirtualBox archive signing key).txt")],
			apt_sources:      ["deb http://download.virtualbox.org/virtualbox/debian xenial contrib"],
		}
	end
end
