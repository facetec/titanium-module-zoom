**Limited Support Notice**
--------------------------
This plugin, bindings, and sample code are meant for example purposes only.  This example will no longer run out of the box from this Github project.  This project is intended to be reference code for how you can integrate ZoOm as a native plugin in the Appcelerator/Titanium ecosystem.  This example is based on an earlier version of ZoOm (6.5.0) from mid-2018 that is no longer support and the APIs have changed (please see https://dev.zoomlogin.com/zoomsdk/#/ for latest version information).

If you are familiar with Appcelerator/Titanium and Native Modules in these ecosystems, this plugin and the sample provided is 90% of the work to get ZoOm working in your Appcelerator/Titanium app.  The remaining work is in updating the bindings to our latest released Native iOS and Android libraries (7.0.0)+, which can be downloaded here - https://dev.zoomlogin.com/zoomsdk/#/downloads.

Hopefully this is enough to get you going!

If you have any more technical questions please feel free to contact us at support@zoomlogin.com
------------------------------
**End Limited Support Notice**

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
