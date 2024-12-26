NAME=qemu-arm
IMAGE=lcharles060/$(NAME):armbian
CONTAINER=$(NAME)-run

main:
	cat Makefile

dbuild:
	docker build . --tag $(IMAGE)

dpush:
	docker push $(IMAGE)

dpull:
	docker pull $(IMAGE)

BIOS=/path/to/u-boot.bin
BOOT=/path/to/system.img.qcow2
drun:
	docker run -it -e BOOT=/system.img.qcow2 -e BIOS=/u-boot.bin -v $(BOOT):/system.img.qcow2 -v $(BIOS):/u-boot.bin --rm -p 8006:8006 --device=/dev/kvm --device=/dev/net/tun --cap-add NET_ADMIN $(IMAGE)

denter:
	docker exec -it $(CONTAINER) /bin/bash

dclean:
	docker rm -f $(CONTAINER)

dpurge:
	docker image rm -f $(IMAGE) 


# log 
# https://paste.armbian.com/obiweciqey

# qemu arm64 image are WIP/CSC

# use qemu for build container arm64 compatible
# this is the image




