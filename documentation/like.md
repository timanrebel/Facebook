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
* `type`: Specify the type of button you want. Possible values are: `standard`, `button`, `boxCount`
