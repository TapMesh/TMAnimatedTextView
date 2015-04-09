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
  s.license      = "Apache License, Version 2.0"
  s.author             = { "bobwieler" => "bob.wieler@tapmesh.com" }
  s.social_media_url   = "http://twitter.com/bobwieler"
  s.platform     = :ios
  s.source       = { :git => "https://github.com/TapMesh/TMAnimatedTextView.git", :tag => s.version.to_s }
  s.source_files  = "TMAnimatedTextView", "TMAnimatedTextView/**/*.{h,m}"
  s.requires_arc = true

end
