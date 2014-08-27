### Login button

The Facebook SDK for iOS provides prebuilt UI components that you can use to log people in and out of your app. In order to authenticate the user, these controls make a call to the user's Facebook app or will fall back to using a web dialog if the user does not have a Facebook app installed. (More info: https://developers.facebook.com/docs/facebook-login/ios/v2.1)

You can easily create a login button by calling:

```
    var facebook = require('rebel.facebook');
    facebook.createLoginButton({
        readPermission: ['public_profile', 'email'],
        width: 280,
        height: 50
    });
```

`readPermissions` can also be set afterwards.

Clicking on the Login button will start the login process and will be handled the same way as described in [Login with Facebook](authentication.md). Just listen to the login event:

```
    function onLogin(evt) {
        // Do something on login
    }

    facebook.addEventListener('login', onLogin);
```

## Dialogs
### Share Dialog
The Share dialog works by making a one-line call to the SDK that configures the content to share, does an app switch to the native Facebook for iOS app, and returns to your app once people have shared. The Share Dialog requires that the user has the native Facebook for iOS app installed on their device.

#### shareStatus(Object args)
#### shareLink(Object args)
#### shareOpenGraphAction(Object args)
