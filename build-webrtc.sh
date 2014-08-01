#!/bin/bash

# gclient can be found here:
# git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git

# don't forget to add gclient to path environment variable:
# export PATH=$PATH:/path/to/depot_tools

fail() {
    echo "*** webrtc build failed"
    exit 1
}

set_environment() {
    export GYP_DEFINES="build_with_libjingle=1 build_with_chromium=0 libjingle_objc=0"
    export GYP_GENERATORS="ninja"
    export GYP_CROSSCOMPILE=1
}

set_environment_for_arm() {
    set_environment
    export GYP_DEFINES="$GYP_DEFINES OS=android"
    export GYP_GENERATOR_FLAGS="$GYP_GENERATOR_FLAGS output_dir=out_arm"
}

set_environment_for_x86() {
   set_environment
   export GYP_DEFINES="$GYP_DEFINES OS=android target_arch=ia32"
   export GYP_GENERATOR_FLAGS="$GYP_GENERATOR_FLAGS output_dir=out_x86"
}

build_arm() {
    echo "-- building webrtc/arm"
    pushd trunk || fail
    set_environment_for_arm || fail
	gclient sync --force || fail
    gclient runhooks --force || fail
    ninja -C out_arm/Debug libjingle_peerconnection_so || fail
	ninja -C out_arm/Release libjingle_peerconnection_so || fail
    pushd out_arm/Release || fail
    #strip -S -x -o libWebRTC-armv7-stripped.a -r libWebRTC-armv7.a
    popd
    popd
    echo "-- webrtc/arm has been sucessfully built"
}

build_x86() {
    echo "-- building webrtc/x86"
    pushd trunk || fail
    set_environment_for_x86 || fail
	gclient sync --force || fail
    gclient runhooks --force || fail
    ninja -C out_x86/Debug libjingle_peerconnection_so || fail
	ninja -C out_x86/Release libjingle_peerconnection_so || fail
    pushd out_x86/Release || fail
    #mv libWebRTC-ia32-stripped.a libWebRTC-ia32.a
    popd
    popd
    echo "-- webrtc/x86 has been sucessfully built"
}

create_framework() {
    echo "-- creating webrtc framework"
    echo "-- webrtc framework created"
}

installdepottools() {
which gclient >/dev/null
if [ $? -ne 0 ]; 
then
	git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
	export PATH=`pwd`/depot_tools:"$PATH"
fi
}

installdepottools


gclient sync --nohooks
pushd trunk
source ./build/android/envsetup.sh
popd
build_arm
build_x86

