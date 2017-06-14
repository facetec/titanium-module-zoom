Introduction
---------
The Zoom module for Appcelerator Titanium provides access to the native Android and iOS version of  FaceTec's ZoOm SDK - 3D Face Login + TrueLiveness.  The latest versions of this module can be found under [releases](https://github.com/facetec/titanium-module-zoom/releases).

Getting Started
---------
For more details on how to install the modules, see the [Appcelerator documentation](http://docs.appcelerator.com/platform/latest/#!/guide/Using_a_Module).  If you do not yet have a Zoom SDK app token, register for [developer access](https://dev.zoomlogin.com/).  For an example of how to use the module, see this [example script](https://github.com/facetec/titanium-module-zoom/blob/master/example/app.js) in this repository.

iOS Tips
---------
In order for ZoOm to access the camera, your app must add an *NSCameraUsageDescription* entry to to the ios plist.  To achieve this, add the following to your app:

```
tiapp.xml

...
<ios>
    <plist>
        <dict>
            ...
            <key>NSCameraUsageDescription</key>
            <string>Secure Authentication with ZoOm</string>
        </dict>
    </plist>
</ios>
```

Limitations
----------
Currently, these modules only support basic ZoOm enrollment and login.  There is no support for muli-factor authentication or UI customization.
