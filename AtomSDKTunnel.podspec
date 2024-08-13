Pod::Spec.new do |spec|
spec.name         = "AtomSDKTunnel"
spec.version      = "4.0.0"
spec.summary      = "OPENVPN Client AtomSDKTunnel work with AtomSDK"

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!
spec.description  = <<-DESC
OPENVPN Client AtomSDKTunnel works with AtomSDK
                 DESC

spec.homepage     = "https://github.com/AtomSDK/atomsdk-demo-ios"
# spec.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"


# ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
#
#  Licensing your code is important. See https://choosealicense.com for more info.
#  CocoaPods will detect a license file if there is a named LICENSE*
#  Popular ones are 'MIT', 'BSD' and 'Apache License, Version 2.0'.
#

spec.license      = { :type => "MIT", :file => "LICENSE.txt" }
# spec.license      = { :type => "MIT", :file => "FILE_LICENSE" }


# ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
#
#  Specify the authors of the library, with email addresses. Email addresses
#  of the authors are extracted from the SCM log. E.g. $ git log. CocoaPods also
#  accepts just a name if you'd rather not provide an email address.
#
#  Specify a social_media_url where others can refer to, for example a twitter
#  profile URL.
#

spec.author             = { "Atom By Secure" => "developer@atomapi.com" }

# ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
#
#  If this Pod runs only on iOS or OS X, then specify the platform and
#  the deployment target. You can optionally include the target after the platform.
#

# spec.platform     = :ios
# spec.platform     = :ios, "5.0"

#  When using multiple platforms
# spec.ios.deployment_target = "5.0"
# spec.osx.deployment_target = "10.7"
# spec.watchos.deployment_target = "2.0"
# spec.tvos.deployment_target = "9.0"

spec.ios.deployment_target = "12.0"
spec.osx.deployment_target = "10.15"
spec.tvos.deployment_target = "17.0"



# ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
#
#  Specify the location from where the source should be retrieved.
#  Supports git, hg, bzr, svn and HTTP.
#

#spec.source            = { :http => 'https://secure.com/atom/downloads/sdk/ios/5.0.3/AtomSDKTunnel.zip' }
#spec.source            = { :http => 'file:' + __dir__ + '/build/AtomSDKTunnel/AtomSDKTunnel.zip' }

spec.source            = { :http => 'https://sdk-prod-a230-v1.s3.fastoverrack.com/sdk/ios/atomsdk/tunnel/4.0.0/AtomSDKTunnel.zip' }
spec.vendored_frameworks = 'AtomSDKTunnel.xcframework', 'AtomOVPNTunnel.xcframework',
                            'OpenVPNClient.xcframework', 'LZ4.xcframework', 'mbedTLS.xcframework'

# ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
#
#  A list of resources included with the Pod. These are copied into the
#  target bundle with a build phase script. Anything else will be cleaned.
#  You can preserve files from being cleaned, please don't preserve
#  non-essential files like tests, examples and documentation.
#

# spec.resource  = "icon.png"
# spec.resources = "Resources/*.png"


end

