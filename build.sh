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
