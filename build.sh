set -xe

if ! [ -e rpcs3 ]
then
	git clone --recurse-submodules https://github.com/RPCS3/rpcs3.git
fi

cd rpcs3

if [ "$WORKSPACE" == true ]
then
	bash -l
	exit 0
fi

if [ "$RUN" == "true" ]
then
	BIN_PATH=$(realpath build/bin/rpcs3)
	if ! [ -e "$BIN_PATH" ]
	then
		echo please first build rpcs3
		exit 1
	fi

	export SDL_HAPTIC_LG4FF_SPRING=100
	export SDL_HAPTIC_LG4FF_DAMPER=100
	export SDL_HAPTIC_LG4FF_FRICTION=100
	export LD_LIBRARY_PATH="/work_dir/sdl_test:$LD_LIBRARY_PATH"

	#gdb -ex 'run' "$BIN_PATH"
	"$BIN_PATH"

	exit 0
fi

if [ "$CLEAN_BUILD" == "true" ]
then
	rm -r build
fi
mkdir -p build
cd build
cmake .. \
	-DUSE_SYSTEM_FFMPEG=ON \
	-DUSE_SDL=ON \
	-DUSE_SYSTEM_SDL=ON \
	-DOpenGL_GL_PREFERENCE=LEGACY \
	-G Ninja

ninja
