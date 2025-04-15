set -xe

if ! [ -e rpcs3 ]
then
	git clone --recurse-submodules https://github.com/RPCS3/rpcs3.git
fi

cd rpcs3

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
	-G Ninja

ninja
