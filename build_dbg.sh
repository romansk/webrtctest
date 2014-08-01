#!/bin/bash

# gclient can be found here:
# git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git

# don't forget to add gclient to path environment variable:
# export PATH=$PATH:/path/to/depot_tools

CONFIGURATION=Debug

fail() {
    echo "*** webrtc build failed"
    exit 1
}

set_environment() {
    export GYP_DEFINES="build_with_libjingle=1 build_with_chromium=0 libjingle_objc=1"
    export GYP_GENERATORS="ninja"
    export GYP_CROSSCOMPILE=1
}

set_environment_for_device() {
    set_environment
    export GYP_DEFINES="$GYP_DEFINES OS=android target_arch=armv7"
    export GYP_GENERATOR_FLAGS="$GYP_GENERATOR_FLAGS output_dir=out_android"
}

set_environment_for_x86() {
   set_environment
   export GYP_DEFINES="$GYP_DEFINES OS=android target_arch=ia32"
   export GYP_GENERATOR_FLAGS="$GYP_GENERATOR_FLAGS output_dir=out_x86"
}

build_device() {
    echo "-- building webrtc/device"
    pushd trunk || fail
    set_environment_for_device
    gclient runhooks || fail
    ninja -C out_ios/$CONFIGURATION-android libjingle_peerconnection_so || fail
    pushd out_android/$CONFIGURATION-android || fail
    #strip -S -x -o libWebRTC-armv7-stripped.a -r libWebRTC-armv7.a
    #mv libWebRTC-armv7-stripped.a libWebRTC-armv7.a
    popd
    popd
    echo "-- webrtc/device has been sucessfully built"
}

build_x86() {
    echo "-- building webrtc/x86"
    pushd trunk || fail
    set_environment_for_x86
    gclient runhooks || fail
    ninja -C out_x86/$CONFIGURATION libjingle_peerconnection_so || fail
    pushd out_x86/$CONFIGURATION || fail
    #mv libWebRTC-ia32-stripped.a libWebRTC-ia32.a
    popd
    popd
    echo "-- webrtc/x86 has been sucessfully built"
}

create_framework() {
    echo "-- creating webrtc framework"
    echo "-- webrtc framework created"
}

gclient sync || fail
build_x86
