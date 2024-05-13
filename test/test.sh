#!/bin/bash
MAIN=Test
BUILD_ARGS="-L pbuflib -p src -m $MAIN -D analyzer-optimize"
OUT=pbuftest

if [ -z "$1" ]; then
	echo -e "Please select a target:\n- js\n- hl\n- cpp\n- cs\n- java\n- python"
	read -p 'Target? ' intarget
else
	intarget=$1
fi

case "$intarget" in
	"js")
		haxe $BUILD_ARGS --js out/$OUT.js
		node "out/$OUT.js"
		;;
	"hl")
		haxe $BUILD_ARGS --hl out/$OUT.hl
		hl "out/$OUT.hl"
		;;
	"cpp")
		haxe $BUILD_ARGS --cpp out/cpp
		out/cpp/$MAIN.exe
		;;
	"cs")
		haxe $BUILD_ARGS --cs out/cs
		out/cs/bin/$MAIN.exe
		;;
	"java")
		haxe $BUILD_ARGS --java out/java
		java -jar "out/java/$MAIN.jar"
		;;
	"python")
		haxe $BUILD_ARGS --python out/$OUT.py
		python "out/$OUT.py"
		;;
	"lua")
		haxe $BUILD_ARGS --lua out/$OUT.lua
		lua "out/$OUT.lua"
		;;
	*)
		echo "Invalid target '$intarget'"
		;;
esac