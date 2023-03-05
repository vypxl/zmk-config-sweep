SWEEP=$(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))
KEEB=$(SWEEP)/../..
ZMK=$(KEEB)/zmk
ZMK_APP=$(ZMK)/app

.DEFAULT_GOAL := flashleft

container:
	docker start zmk > /dev/null

left: container
	docker exec zmk sh -c 'cd /workspaces/zmk/app && west build -d build/left -b nice_nano_v2 -- -DSHIELD=cradio_left -DZMK_CONFIG=/workspaces/zmk-config/sweep/config'
	docker exec zmk sh -c 'chown thomas:thomas /workspaces/zmk/app/build/left/zephyr/zmk.uf2'
	cp $(ZMK_APP)/build/left/zephyr/zmk.uf2 $(SWEEP)/build/left.uf2

right: container
	docker exec zmk sh -c 'cd /workspaces/zmk/app && west build -d build/right -b nice_nano_v2 -- -DSHIELD=cradio_right -DZMK_CONFIG=/workspaces/zmk-config/sweep/config'
	docker exec zmk sh -c 'chown thomas:thomas /workspaces/zmk/app/build/right/zephyr/zmk.uf2'
	cp $(ZMK_APP)/build/right/zephyr/zmk.uf2 $(SWEEP)/build/right.uf2

wait:
	@echo "Waiting for the keyboard to be reset..."
	@while [ ! -d /run/media/${USER}/NICENANO ]; do sleep 1; done

flashleft: left wait
	cp $(SWEEP)/build/left.uf2 /run/media/${USER}/NICENANO/

flashright: right wait
	cp $(SWEEP)/build/right.uf2 /run/media/${USER}/NICENANO/

stop:
	docker stop zmk

build: left right
