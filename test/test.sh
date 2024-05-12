#!/bin/bash
BUILD_ARGS="-L pbuflib -p src -m Test -D analyzer-optimize"

if [ -z "$1" ]; then
	echo -e "Please select a target:\n- js\n- hl\n- cpp\n- cs\n- java\n- python"
	read -p 'Target? ' intarget
else
	intarget=$1
fi

case "$intarget" in
	"js")
		haxe $BUILD_ARGS --js out/pbuftest.js
		node "out/pbuftest.js"
		;;
	"hl")
		haxe $BUILD_ARGS --hl out/pbuftest.hl
		hl "out/pbuftest.hl"
		;;
	"cpp")
		haxe $BUILD_ARGS --cpp out/cpp
		out/cpp/Test.exe
		;;
	"cs")
		haxe $BUILD_ARGS --cs out/cs
		out/cs/bin/Test.exe
		;;
	"java")
		haxe $BUILD_ARGS --java out/java
		java -jar "out/java/Test.jar"
		;;
	"python")
		haxe $BUILD_ARGS --python out/pbuftest.py
		python "out/pbuftest.py"
		;;
	"lua")
		haxe $BUILD_ARGS --lua out/pbuftest.lua
		lua "out/pbuftest.lua"
		;;
	*)
		echo "Invalid target '$intarget'"
		;;
esac