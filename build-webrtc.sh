#!/bin/bash

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

build() {
    echo "-- building webrtc/$1"
    pushd trunk || fail
    set_environment_for_$1 || fail
	gclient sync --force || fail
    gclient runhooks --force || fail
    ninja -C out_$1/Debug libjingle_peerconnection_so libjingle_peerconnection.jar || fail
	ninja -C out_$1/Release libjingle_peerconnection_so libjingle_peerconnection.jar || fail
    ../$1_strip -s out_$1/Release/libjingle_peerconnection_so.so
    pushd out_$1/Release || fail
    popd
    popd
    echo "-- webrtc/$1 has been sucessfully built"
}

prerequisites() {
    export PATH=`pwd`/depot_tools:"$PATH"
    which gclient >/dev/null
    if [ $? -ne 0 ]; 
    then
	   git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
	   export PATH=`pwd`/depot_tools:"$PATH"
    fi
    gclient sync --nohooks
    pushd trunk
    source ./build/android/envsetup.sh
    popd
}

pushtogit() {
    REVISION = `grep -Po '(?<=@)[^\"]+' .gclient`
    git add repo/*    
    git commit -m 'webrtc revision: $REVISION'
    git push origin master
}

prerequisites

build arm
build x86

make

pushtogit



