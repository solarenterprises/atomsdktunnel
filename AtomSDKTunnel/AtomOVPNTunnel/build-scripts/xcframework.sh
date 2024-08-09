#!/bin/bash

set -eux

# Clean LZ4
xcodebuild -project AtomOVPNTunnel/AtomOVPNTunnel.xcodeproj -configuration Release -target LZ4 -sdk iphonesimulator clean
xcodebuild -project AtomOVPNTunnel/AtomOVPNTunnel.xcodeproj -configuration Release -target LZ4 -sdk iphoneos clean

# Clean mbedTLS
xcodebuild -project AtomOVPNTunnel/AtomOVPNTunnel.xcodeproj -configuration Release -target mbedTLS -sdk iphonesimulator clean
xcodebuild -project AtomOVPNTunnel/AtomOVPNTunnel.xcodeproj -configuration Release -target mbedTLS -sdk iphoneos clean

# Clean OpenVPNClient
xcodebuild -project AtomOVPNTunnel/AtomOVPNTunnel.xcodeproj -configuration Release -target OpenVPNClient -sdk iphonesimulator clean
xcodebuild -project AtomOVPNTunnel/AtomOVPNTunnel.xcodeproj -configuration Release -target OpenVPNClient -sdk iphoneos clean

# Clean AtomOVPNTunnel
xcodebuild -project AtomOVPNTunnel/AtomOVPNTunnel.xcodeproj -configuration Release -target AtomOVPNTunnel -sdk iphonesimulator clean
xcodebuild -project AtomOVPNTunnel/AtomOVPNTunnel.xcodeproj -configuration Release -target AtomOVPNTunnel -sdk iphoneos clean

# then I build the simulator and device version of the framework

#
#
## LZ4
#xcodebuild -project AtomOVPNTunnel.xcodeproj -scheme LZ4 -configuration Release -destination 'generic/platform=iOS' -archivePath ./build/Release/LZ4-iOS.xcarchive ENABLE_BITCODE=YES BITCODE_GENERATION_MODE=bitcode OTHER_CFLAGS=-fembed-bitcode BUILD_LIBRARY_FOR_DISTRIBUTION=YES SKIP_INSTALL=NO archive
#
#xcodebuild -project AtomOVPNTunnel.xcodeproj -scheme LZ4 -configuration Release -destination 'generic/platform=iOS Simulator' -archivePath ./build/Release/LZ4-Simulator.xcarchive ENABLE_BITCODE=YES BITCODE_GENERATION_MODE=bitcode OTHER_CFLAGS=-fembed-bitcode BUILD_LIBRARY_FOR_DISTRIBUTION=YES SKIP_INSTALL=NO archive
#
#xcodebuild -project AtomOVPNTunnel.xcodeproj -scheme LZ4 -configuration Release -destination 'generic/platform=macOS' -archivePath ./build/Release/LZ4-macOS.xcarchive BUILD_LIBRARY_FOR_DISTRIBUTION=YES SKIP_INSTALL=NO archive
#
#
## mbedTLS
#xcodebuild -project AtomOVPNTunnel.xcodeproj -scheme mbedTLS -configuration Release -destination 'generic/platform=iOS' -archivePath ./build/Release/mbedTLS-iOS.xcarchive ENABLE_BITCODE=YES BITCODE_GENERATION_MODE=bitcode OTHER_CFLAGS=-fembed-bitcode BUILD_LIBRARY_FOR_DISTRIBUTION=YES SKIP_INSTALL=NO archive
#
#xcodebuild -project AtomOVPNTunnel.xcodeproj -scheme mbedTLS -configuration Release -destination 'generic/platform=iOS Simulator' -archivePath ./build/Release/mbedTLS-Simulator.xcarchive ENABLE_BITCODE=YES BITCODE_GENERATION_MODE=bitcode OTHER_CFLAGS=-fembed-bitcode BUILD_LIBRARY_FOR_DISTRIBUTION=YES SKIP_INSTALL=NO archive
#
#xcodebuild -project AtomOVPNTunnel.xcodeproj -scheme mbedTLS -configuration Release -destination 'generic/platform=macOS' -archivePath ./build/Release/mbedTLS-macOS.xcarchive BUILD_LIBRARY_FOR_DISTRIBUTION=YES SKIP_INSTALL=NO archive
#
## OpenVPNClient
#xcodebuild -project AtomOVPNTunnel.xcodeproj -scheme OpenVPNClient -configuration Release -destination 'generic/platform=iOS' -archivePath ./build/Release/OpenVPNClient-iOS.xcarchive ENABLE_BITCODE=YES BITCODE_GENERATION_MODE=bitcode OTHER_CFLAGS=-fembed-bitcode BUILD_LIBRARY_FOR_DISTRIBUTION=YES SKIP_INSTALL=NO archive
#
#xcodebuild -project AtomOVPNTunnel.xcodeproj -scheme OpenVPNClient -configuration Release -destination 'generic/platform=iOS Simulator' -archivePath ./build/Release/OpenVPNClient-Simulator.xcarchive ENABLE_BITCODE=YES BITCODE_GENERATION_MODE=bitcode OTHER_CFLAGS=-fembed-bitcode BUILD_LIBRARY_FOR_DISTRIBUTION=YES SKIP_INSTALL=NO archive
#
#xcodebuild -project AtomOVPNTunnel.xcodeproj -scheme OpenVPNClient -configuration Release -destination 'generic/platform=macOS' -archivePath ./build/Release/OpenVPNClient-macOS.xcarchive BUILD_LIBRARY_FOR_DISTRIBUTION=YES SKIP_INSTALL=NO archive
#
#
## AtomOVPNTunnel
#xcodebuild -project AtomOVPNTunnel.xcodeproj -scheme AtomOVPNTunnel -configuration Release -destination 'generic/platform=iOS' -archivePath ./build/Release/AtomOVPNTunnel-iOS.xcarchive ENABLE_BITCODE=YES BITCODE_GENERATION_MODE=bitcode OTHER_CFLAGS=-fembed-bitcode BUILD_LIBRARY_FOR_DISTRIBUTION=YES SKIP_INSTALL=NO archive
#
#xcodebuild -project AtomOVPNTunnel.xcodeproj -scheme AtomOVPNTunnel -configuration Release -destination 'generic/platform=iOS Simulator' -archivePath ./build/Release/AtomOVPNTunnel-Simulator.xcarchive ENABLE_BITCODE=YES BITCODE_GENERATION_MODE=bitcode OTHER_CFLAGS=-fembed-bitcode BUILD_LIBRARY_FOR_DISTRIBUTION=YES SKIP_INSTALL=NO archive
#
#xcodebuild -project AtomOVPNTunnel.xcodeproj -scheme AtomOVPNTunnel -configuration Release -destination 'generic/platform=macOS' -archivePath ./build/Release/AtomOVPNTunnel-macOS.xcarchive BUILD_LIBRARY_FOR_DISTRIBUTION=YES SKIP_INSTALL=NO archive
#
## Now create XCFramework
#
## LZ4
#xcodebuild -create-xcframework -framework build/Release/LZ4-iOS.xcarchive/Products/Library/Frameworks/LZ4.framework -framework build/Release/LZ4-Simulator.xcarchive/Products/Library/Frameworks/LZ4.framework -framework build/Release/LZ4-macOS.xcarchive/Products/Library/Frameworks/LZ4.framework -output build/AtomSDKTunnel/LZ4.xcframework
#
##mbedTLS
#xcodebuild -create-xcframework -framework build/Release/mbedTLS-iOS.xcarchive/Products/Library/Frameworks/mbedTLS.framework -framework build/Release/mbedTLS-Simulator.xcarchive/Products/Library/Frameworks/mbedTLS.framework -framework build/Release/mbedTLS-macOS.xcarchive/Products/Library/Frameworks/mbedTLS.framework -output build/AtomSDKTunnel/mbedTLS.xcframework
#
##OpenVPNClient
#xcodebuild -create-xcframework -framework build/Release/OpenVPNClient-iOS.xcarchive/Products/Library/Frameworks/OpenVPNClient.framework -framework build/Release/OpenVPNClient-Simulator.xcarchive/Products/Library/Frameworks/OpenVPNClient.framework -framework build/Release/OpenVPNClient-macOS.xcarchive/Products/Library/Frameworks/OpenVPNClient.framework -output build/AtomSDKTunnel/OpenVPNClient.xcframework
#
##AtomOVPNTunnel
#xcodebuild -create-xcframework -framework build/Release/AtomOVPNTunnel-iOS.xcarchive/Products/Library/Frameworks/AtomOVPNTunnel.framework -framework build/Release/AtomOVPNTunnel-Simulator.xcarchive/Products/Library/Frameworks/AtomOVPNTunnel.framework -framework build/Release/AtomOVPNTunnel-macOS.xcarchive/Products/Library/Frameworks/AtomOVPNTunnel.framework -output build/AtomSDKTunnel/AtomOVPNTunnel.xcframework
