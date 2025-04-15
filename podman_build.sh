set -xe

IMAGE_TAG="rpcs3_workspace"
DOCKER_FILE="DockerFile"

if [ "$REBUILD_IMAGE" == "true" ]
then
	podman image rm -f "$IMAGE_TAG"
fi

if ! podman image exists "$IMAGE_TAG"
then
	podman image build -f "$DOCKER_FILE" -t "$IMAGE_TAG"
fi

XDGR=""
if [ -n "$XDG_RUNTIME_DIR" ]
then
	XDGR="$XDGR --tmpfs $XDG_RUNTIME_DIR"
	XDGR="$XDGR --env XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR"
fi

XORG=""
if [ -n "$DISPLAY" ]
then
	XORG="$XORG --env DISPLAY=$DISPLAY"
fi
if [ -e /tmp/.X11-unix ]
then
	XORG="$XORG -v /tmp/.X11-unix:/tmp/.X11-unix"
fi
if [ -n "$XAUTHORITY" ] && [ -e "$XAUTHORITY" ]
then
	XORG="$XORG -v $XAUTHORITY:$XAUTHORITY:ro"
	XORG="$XORG --env XAUTHORITY=$XAUTHORITY"
fi

DRI=""
if [ -e /dev/dri ]
then
	DRI="$DRI -v /dev/dri:/dev/dri"
fi
if [ -n "$(ls /dev/nvi*)" ]
then
	for f in /dev/nvi*
	do
		DRI="$DRI -v $f:$f"
	done
fi

PULSE=""
pulse_socket_path="$XDG_RUNTIME_DIR/pulse/native"
if [ -S $pulse_socket_path ]
then
	PULSE="$PULSE -v $pulse_socket_path:$pulse_socket_path"
fi

INPUT=""
if [ -e /dev/input ]
then
	INPUT="$INPUT -v /dev/input:/dev/input"
fi
if [ -e /dev/bus/usb ]
then
	INPUT="$INPUT -v /dev/bus/usb:/dev/bus/usb"
fi

RUN=${RUN:-false}
CLEAN_BUILD=${CLEAN_BUILD:-false}

create_directory_if_not_exists () {
	if ! [ -e "$1" ]
	then
		mkdir -p "$1"
	fi
}

create_directory_if_not_exists home_dir
create_directory_if_not_exists software

podman run \
	--rm -it \
	--ipc host \
	--net host \
	$XDGR \
	$XORG \
	$DRI \
	$PULSE \
	$INPUT \
	-v ./:/work_dir \
	-v ./podman_build.sh:/work_dir/podman_build.sh:ro \
	-v ./build.sh:/work_dir/build.sh:ro \
	-w /work_dir \
	--env RUN=$RUN \
	--env CLEAN_BUILD=$CLEAN_BUILD \
	-v ./home_dir:/home_dir \
	-v ./software:/software:ro \
	--env HOME=/home_dir \
	$IMAGE_TAG \
	bash ./build.sh
