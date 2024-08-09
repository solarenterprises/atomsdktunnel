#!/bin/bash

set -eux
#cd "AtomOVPNTunnel"

AtomOVPNTunnelProject='AtomOVPNTunnel/AtomOVPNTunnel.xcodeproj'
AtomSDKTunnelProject='AtomSDKTunnel.xcodeproj'
AtomSDKTunnelTargetiOS='AtomSDKTunnel iOS'

rm -f -R "build"


# Clean AtomSDKTunnel
xcodebuild -project $AtomSDKTunnelProject -configuration Release -target "$AtomSDKTunnelTargetiOS" -sdk iphonesimulator clean
xcodebuild -project $AtomSDKTunnelProject -configuration Release -target "$AtomSDKTunnelTargetiOS" -sdk iphoneos clean
xcodebuild -project $AtomSDKTunnelProject -configuration Release -target "$AtomSDKTunnelTargetiOS" -sdk appletvsimulator clean
xcodebuild -project $AtomSDKTunnelProject -configuration Release -target "$AtomSDKTunnelTargetiOS" -sdk appletvos clean

# Clean LZ4
xcodebuild -project $AtomOVPNTunnelProject -configuration Release -target LZ4 -sdk iphonesimulator clean
xcodebuild -project $AtomOVPNTunnelProject -configuration Release -target LZ4 -sdk iphoneos clean
xcodebuild -project $AtomOVPNTunnelProject -configuration Release -target LZ4 -sdk appletvsimulator clean
xcodebuild -project $AtomOVPNTunnelProject -configuration Release -target LZ4 -sdk appletvos clean

# Clean mbedTLS
xcodebuild -project $AtomOVPNTunnelProject -configuration Release -target mbedTLS -sdk iphonesimulator clean
xcodebuild -project $AtomOVPNTunnelProject -configuration Release -target mbedTLS -sdk iphoneos clean
xcodebuild -project $AtomOVPNTunnelProject -configuration Release -target mbedTLS -sdk appletvsimulator clean
xcodebuild -project $AtomOVPNTunnelProject -configuration Release -target mbedTLS -sdk appletvos clean

# Clean OpenVPNClient
xcodebuild -project $AtomOVPNTunnelProject -configuration Release -target OpenVPNClient -sdk iphonesimulator clean
xcodebuild -project $AtomOVPNTunnelProject -configuration Release -target OpenVPNClient -sdk iphoneos clean
xcodebuild -project $AtomOVPNTunnelProject -configuration Release -target OpenVPNClient -sdk appletvsimulator clean
xcodebuild -project $AtomOVPNTunnelProject -configuration Release -target OpenVPNClient -sdk appletvos clean

# Clean AtomOVPNTunnel
xcodebuild -project $AtomOVPNTunnelProject -configuration Release -target AtomOVPNTunnel -sdk iphonesimulator clean
xcodebuild -project $AtomOVPNTunnelProject -configuration Release -target AtomOVPNTunnel -sdk iphoneos clean
xcodebuild -project $AtomOVPNTunnelProject -configuration Release -target AtomOVPNTunnel -sdk appletvsimulator clean
xcodebuild -project $AtomOVPNTunnelProject -configuration Release -target AtomOVPNTunnel -sdk appletvos clean

# then I build the simulator and device version of the framework

# AtomSDKTunnel
xcodebuild -project $AtomSDKTunnelProject -scheme "$AtomSDKTunnelTargetiOS" -configuration Release -destination 'generic/platform=iOS' -archivePath ./build/Release/AtomSDKTunnel-iOS.xcarchive ENABLE_BITCODE=YES BITCODE_GENERATION_MODE=bitcode OTHER_CFLAGS=-fembed-bitcode BUILD_LIBRARY_FOR_DISTRIBUTION=YES SKIP_INSTALL=NO archive

xcodebuild -project $AtomSDKTunnelProject -scheme "$AtomSDKTunnelTargetiOS" -configuration Release -destination 'generic/platform=iOS Simulator' -archivePath ./build/Release/AtomSDKTunnel-Simulator.xcarchive ENABLE_BITCODE=YES BITCODE_GENERATION_MODE=bitcode OTHER_CFLAGS=-fembed-bitcode BUILD_LIBRARY_FOR_DISTRIBUTION=YES SKIP_INSTALL=NO archive

xcodebuild -project $AtomSDKTunnelProject -scheme "$AtomSDKTunnelTargetiOS" -configuration Release -destination 'generic/platform=tvOS' -archivePath ./build/Release/AtomSDKTunnel-tvOS.xcarchive ENABLE_BITCODE=YES BITCODE_GENERATION_MODE=bitcode OTHER_CFLAGS=-fembed-bitcode BUILD_LIBRARY_FOR_DISTRIBUTION=YES SKIP_INSTALL=NO archive

xcodebuild -project $AtomSDKTunnelProject -scheme "$AtomSDKTunnelTargetiOS" -configuration Release -destination 'generic/platform=tvOS Simulator' -archivePath ./build/Release/AtomSDKTunnel-tvOS-Simulator.xcarchive ENABLE_BITCODE=YES BITCODE_GENERATION_MODE=bitcode OTHER_CFLAGS=-fembed-bitcode BUILD_LIBRARY_FOR_DISTRIBUTION=YES SKIP_INSTALL=NO archive

xcodebuild -project $AtomSDKTunnelProject -scheme 'AtomSDKTunnel macOS' -configuration Release -destination 'generic/platform=macOS' -archivePath ./build/Release/AtomSDKTunnel-macOS.xcarchive BUILD_LIBRARY_FOR_DISTRIBUTION=YES SKIP_INSTALL=NO archive



xcodebuild -create-xcframework -framework build/Release/AtomSDKTunnel-iOS.xcarchive/Products/Library/Frameworks/LZ4.framework -framework build/Release/AtomSDKTunnel-macOS.xcarchive/Products/Library/Frameworks/LZ4.framework -framework build/Release/AtomSDKTunnel-Simulator.xcarchive/Products/Library/Frameworks/LZ4.framework -framework build/Release/AtomSDKTunnel-tvOS-Simulator.xcarchive/Products/Library/Frameworks/LZ4.framework -framework build/Release/AtomSDKTunnel-tvOS.xcarchive/Products/Library/Frameworks/LZ4.framework -output build/AtomSDKTunnel/LZ4.xcframework


xcodebuild -create-xcframework -framework build/Release/AtomSDKTunnel-iOS.xcarchive/Products/Library/Frameworks/mbedTLS.framework -framework build/Release/AtomSDKTunnel-macOS.xcarchive/Products/Library/Frameworks/mbedTLS.framework -framework build/Release/AtomSDKTunnel-Simulator.xcarchive/Products/Library/Frameworks/mbedTLS.framework -framework build/Release/AtomSDKTunnel-tvOS-Simulator.xcarchive/Products/Library/Frameworks/mbedTLS.framework -framework build/Release/AtomSDKTunnel-tvOS.xcarchive/Products/Library/Frameworks/mbedTLS.framework -output build/AtomSDKTunnel/mbedTLS.xcframework


xcodebuild -create-xcframework -framework build/Release/AtomSDKTunnel-iOS.xcarchive/Products/Library/Frameworks/OpenVPNClient.framework -framework build/Release/AtomSDKTunnel-macOS.xcarchive/Products/Library/Frameworks/OpenVPNClient.framework -framework build/Release/AtomSDKTunnel-Simulator.xcarchive/Products/Library/Frameworks/OpenVPNClient.framework -framework build/Release/AtomSDKTunnel-tvOS-Simulator.xcarchive/Products/Library/Frameworks/OpenVPNClient.framework -framework build/Release/AtomSDKTunnel-tvOS.xcarchive/Products/Library/Frameworks/OpenVPNClient.framework  -output build/AtomSDKTunnel/OpenVPNClient.xcframework



xcodebuild -create-xcframework -framework build/Release/AtomSDKTunnel-iOS.xcarchive/Products/Library/Frameworks/AtomOVPNTunnel.framework -framework build/Release/AtomSDKTunnel-macOS.xcarchive/Products/Library/Frameworks/AtomOVPNTunnel.framework -framework build/Release/AtomSDKTunnel-Simulator.xcarchive/Products/Library/Frameworks/AtomOVPNTunnel.framework -framework build/Release/AtomSDKTunnel-tvOS-Simulator.xcarchive/Products/Library/Frameworks/AtomOVPNTunnel.framework -framework build/Release/AtomSDKTunnel-tvOS.xcarchive/Products/Library/Frameworks/AtomOVPNTunnel.framework  -output build/AtomSDKTunnel/AtomOVPNTunnel.xcframework



xcodebuild -create-xcframework -framework build/Release/AtomSDKTunnel-iOS.xcarchive/Products/Library/Frameworks/AtomSDKTunnel.framework -framework build/Release/AtomSDKTunnel-macOS.xcarchive/Products/Library/Frameworks/AtomSDKTunnel.framework -framework build/Release/AtomSDKTunnel-Simulator.xcarchive/Products/Library/Frameworks/AtomSDKTunnel.framework -framework build/Release/AtomSDKTunnel-tvOS-Simulator.xcarchive/Products/Library/Frameworks/AtomSDKTunnel.framework -framework build/Release/AtomSDKTunnel-tvOS.xcarchive/Products/Library/Frameworks/AtomSDKTunnel.framework  -output build/AtomSDKTunnel/AtomSDKTunnel.xcframework

open ./
