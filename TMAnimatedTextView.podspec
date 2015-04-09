Pod::Spec.new do |s|
  s.name         = "TMAnimatedTextView"
  s.version      = "1.0.0"
  s.summary      = "A UITextView subclass that allows animating NSTextAttachment attachments."

  s.description  = <<-DESC
                   The basic UITextView allows you to attach images however it does not allow you to 
                   animate each individual attachment in the text view. This component allows you to 
                   add an image attachment and animate that attachment.
                   DESC

  s.homepage     = "https://github.com/TapMesh/TMAnimatedTextView"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"
  s.license      = "Apache License, Version 2.0"
  s.author             = { "bobwieler" => "bob.wieler@tapmesh.com" }
  s.social_media_url   = "http://twitter.com/bobwieler"
  s.platform     = :ios, "7.1"
  s.source       = { :git => "https://github.com/TapMesh/TMAnimatedTextView.git", :tag => s.version.to_s }

  s.source_files  = "Classes", "Classes/**/*.{h,m}"
  s.exclude_files = "Classes/Exclude"

  # s.public_header_files = "Classes/**/*.h"


  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  A list of resources included with the Pod. These are copied into the
  #  target bundle with a build phase script. Anything else will be cleaned.
  #  You can preserve files from being cleaned, please don't preserve
  #  non-essential files like tests, examples and documentation.
  #

  # s.resource  = "icon.png"
  # s.resources = "Resources/*.png"

  # s.preserve_paths = "FilesToSave", "MoreFilesToSave"


  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Link your library with frameworks, or libraries. Libraries do not include
  #  the lib prefix of their name.
  #

  # s.framework  = "SomeFramework"
  # s.frameworks = "SomeFramework", "AnotherFramework"

  # s.library   = "iconv"
  # s.libraries = "iconv", "xml2"


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If your library depends on compiler flags you can set them in the xcconfig hash
  #  where they will only apply to your library. If you depend on other Podspecs
  #  you can include multiple dependencies to ensure it works.

  # s.requires_arc = true

  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # s.dependency "JSONKit", "~> 1.4"

end
