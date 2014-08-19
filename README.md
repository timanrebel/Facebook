Facebook
==============

Appcelerator Titanium module wrapping the latest version of the Facebook iOS SDK. Based upon the work of @appcelerator-modules and @mokesmoes.

Currently only login with Facebook and App Events are implemented.

This module is work in progress and it's API is not yet stable. That is, backwards incompatible changes might still be pushed.

## Login with Facebook

The Facebook SDK and thus the Facebook module reads its configuration settings from the tiapp.xml file. In the _iOS_ section, add:

```
<ios>
        <plist>
            <dict>
                <key>CFBundleURLTypes</key>
                <array>
                    <dict>
                        <key>CFBundleURLName</key>
                        <string>[Ti appId (com.domain.app)]</string>
                        <key>CFBundleURLSchemes</key>
                        <array>
                            <string>fb[FB appId]</string>
                            <string>fb[FB appId][suffix]</string>
                        </array>
                    </dict>
                </array>
                <key>FacebookAppID</key>
                <string>[FB appId]</string>
                <key>FacebookDisplayName</key>
                <string>[FB appName]]</string>
                <key>FacebookUrlSchemeSuffix</key>
                <string>[suffix]</string>
            </dict>
        </plist>
    </ios>
```

### Properties
#### uid (string)
The user id of the loggedin Facebook user
#### isLoggedIn (bool)
Boolean whether the user is loggedin and authorized
#### canShare (bool)
Boolean whether the user can share content via the Share Dialog
#### permissions (array)
An array containing the granted permissions
#### accessTokenData (object)
Object containing the access token data:
* accessToken
* permissions
* declinedPermissions
* expirationDate
* refreshDate
* permissionsRefreshDate
* appID
* userID


### Functions
#### authorize(Array permissions, function callback)

To login with facebook call the `authorize` function with an array of the (read) permission you'd like to request and a callback function to be called upon completion.

The callback function will receive the following arguments:

* success (bool)
* cancelled (bool)
* error (object)
* accessTokenData (object)

#### logout()

Logs out the authorized Facebook user

#### requestNewPublishPermissions(Array permissions, int audience, function callback)

Request publish (write) permissions from Facebook.

Audience is one of the following:
* facebook.audienceNone
* facebook.audienceOnlyMe
* facebook.audienceFriends
* facebook.audienceEveryone

#### requestNewReadPermissions(Array permissions, function callback)

Request extra read permissions from Facebook

#### logEvent(String eventName)

Log custom App Event

#### logPurchase(long amount, String currency)

Log purchase
