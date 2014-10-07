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

#### Properties
* `readPermission`: The read permission to request from Facebook
* `publishPermissions` The publish permission to request from Facebook
* `defaultAudience` The default audience when posting to Facebook. Possible values are: `facebook.audienceNone`, `facebook.audienceOnlyMe`, `facebook.audienceFriends` or `facebook.audienceEveryone`.

### Like button

The Like button is the quickest way for people to share content with their friends. A single click on the Like button will 'like' pieces of content from your app and share them on Facebook.

The Like button can be used to like a Facebook Page or any Open Graph object and can be referenced by URL or ID.

More info: https://developers.facebook.com/docs/ios/like-button

You can easily create a like button by calling:

```
    var facebook = require('rebel.facebook');
    var button = facebook.createLikeButton({
        objectID: 'https://github.com/timanrebel/Facebook',
        width: 280,
        height: 50
    });

    win.add(button);
```

#### Properties
* `objectID`: The url or ID to like on Facebook
* `color`: Sets the color of the text.
* `style`: Specify the type of button you want. Possible values: `standard`, `button`, `boxCount`. Default: `standard`
* `align`: The text alignment of the social sentence. Possible values: `left`, `center`, `left`. Default: `left`
* `auxiliaryPosition`: The position for the auxiliary view for the receiver. (the like count). Possible values: `top`, `inline`, `bottom`. Default: `inline`
* `soundEnabled`: If `true`, a sound is played when the receiver is toggled. Default: `true`


## Dialogs
### Share Dialog
The Share dialog works by making a one-line call to the SDK that configures the content to share, does an app switch to the native Facebook for iOS app, and returns to your app once people have shared. The Share Dialog requires that the user has the native Facebook for iOS app installed on their device.

#### void shareStatus(Object args)
#### void shareLink(Object args)
#### void shareOpenGraphAction(Object args)

### Messenger Dialog

Share via Facebook Messenger

#### bool canMessage()

Returns true when the app can share links or Open Graph actions via Facebook Messenger

#### void messageLink(Object args)
* `url` URL of the link to share
* `title`
* `caption`
* `picture` URL of the image to add to the link

Share a link via Facebook Messenger.
