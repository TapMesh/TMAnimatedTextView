# TMAnimatedTextView

![](https://github.com/TapMesh/TMAnimatedTextView/blob/master/TMAnimatedTextView.gif)

Summary
-------

TMAnimatedTextView is a UITextView subclass that allows animating NSTextAttachment attachments. UITextView allows adding images as an attachment but they are static and cannot be animated. This class:

* allows you to define custom animations for each attachment
* informs a delegate of changes to each attachment's lifecycle (additions, deletions)
* informs a delegate of interactions with the attachment (touches)
* automatically expands up to handle the size of the attachment image

Instructions
------------

With CocoaPods add the following to your Podfile.

    pod 'TMAnimatedTextView'

Alternatively, you can add the TMAnimatedTextView.h and TMAnimatedTextView.m files to your project.

Storyboard Setup
----------------

TMAnimatedTextView works well with storyboards.

1. Add a UITextView to your storyboard
2. Change the Class to a TMAnimatedTextView
3. Set a height constraint on the TMAnimatedTextView component (this is used to handle the component expansion when adding images)
4. Have your controller implement the TMAnimatedTextViewDelegate protocol (all methods are optional)
5. Connect your view controller to the animatedTextViewDelegate outlet on the component

Demo
----

A demo application is included that utilizes TMAnimatedTextView and includes custom animations for when the attachment is added as well as when the attachment is touched. This demo also shows how to set up the constraints for the component.
