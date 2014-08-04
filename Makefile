REVISION:= `grep -Po '(?<=@)[^\"]+' .gclient`
WEBRTC_PATH=

.PHONY: all clean

all: repo

clean:
	@rm -Rf ${CURDIR}/repo

repo:
	@mvn deploy:deploy-file -Dversion=${REVISION} -DpomFile=webrtc_pom/libjingle_peerconnection_so.pom.xml -Dfile=trunk/out_arm/Release/libjingle_peerconnection_so.so -Durl=file://${CURDIR}/repo -DcreateChecksum=true -Dclassifier=armeabi
	@mvn deploy:deploy-file -Dversion=${REVISION} -DpomFile=webrtc_pom/libjingle_peerconnection.pom.xml -Dfile=trunk/out_arm/Release/libjingle_peerconnection.jar -Durl=file://${CURDIR}/repo -DcreateChecksum=true
	@mvn deploy:deploy-file -Dversion=${REVISION} -DpomFile=webrtc_pom/libjingle_peerconnection_so.pom.xml -Dfile=trunk/out_x86/Release/libjingle_peerconnection_so.so -Durl=file://${CURDIR}/repo -DcreateChecksum=true -Dclassifier=x86
