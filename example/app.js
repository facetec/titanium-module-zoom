var zoom = require('com.facetec.ti.zoom');

var appToken = "ENTER_YOUR_APP_TOKEN"; 
var userId = "myUserId";
var encryptionSecret = "myUserEncryptionSecret";

// open a single window
var win = Ti.UI.createWindow({
    backgroundColor:'white'
});

var container = Ti.UI.createView({layout: "vertical", height: Ti.UI.SIZE}); 

var enrollButton = Ti.UI.createButton({title: "Enroll", enabled: false});
enrollButton.addEventListener("click", startEnrollment);

var authButton = Ti.UI.createButton({title: "Authenticate", enabled: false});
authButton.addEventListener("click", startAuthentication);

var versionStr = "Zoom SDK v" + zoom.version;

container.add(enrollButton);
container.add(authButton);
container.add(Ti.UI.createLabel({text: versionStr, top: "20dp", font: {fontSize: "10sp"}})); 
win.add(container);
win.open();

function onInitialize(result) {
    if (result.successful) {
        enrollButton.enabled = true;
        authButton.enabled = true;
    }
    else {
        alert("Initialize failed: " + result.status);
    }
}

function startEnrollment() {
    zoom.enroll(userId, encryptionSecret, function(result) {
        alert("Enrollment result: " + JSON.stringify(result));
    });
}

function startAuthentication() {
    if (zoom.isUserEnrolled(userId)) {
        zoom.authenticate(userId, encryptionSecret, function(result) {
            alert("Auth result: " + JSON.stringify(result));
        });
    }
    else {
        alert("User isn't enrolled.");
    }
}

try {
    zoom.initialize(appToken, onInitialize);
}
catch (e) {
    alert ("Init error: " + e.message);
}
