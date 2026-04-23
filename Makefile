all: .default

configs = $(wildcard config/*/*)
home_configs = $(patsubst config/%, ${HOME}/.config/%, $(configs))

rc = $(wildcard dot_*)
home_rc = $(patsubst dot_%,${HOME}/.%,$(rc))

local = $(wildcard local/*/*)
home_local = $(patsubst %,${HOME}/.%,$(local))

$(home_configs): ${HOME}/.config/%: config/%
	@mkdir -p $(@D)
	ln -f $< $@

$(home_local): ${HOME}/.local/%: local/%
	@mkdir -p $(@D)
	ln -f $< $@

$(home_rc): ${HOME}/.%: dot_%
	ln -f $< $@

.default: ${home_configs} ${home_rc} ${home_local}
