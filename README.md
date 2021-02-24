uuk1. Install CocoaPods if you haven't do so:

    $ sudo gem install cocoapods

2. Update pod libraries:

    $ pod install

3. Open project file `Tech Face.xcworkspace`, not the `xcodeproj` file

4. On left panel, select `Tech Face`, under TARGETS select `Tech Face`

5. Change Bundle identifier to include your reversed domain name.

6. Change the Signing Team to your Apple Developer account.

7. Locate `Server.m` in the project, change the URL in `serverURL` function to your Laravel server host.

8. Select `Generic iOS Deivce` then build.

If you are unable to build for simulator (which will also affect Storyboard), select `Pods` from left side bar.

PROJECT > Pods > Architectures > Build Active Architecture Only > make sure it's NO for both Debug and Release
