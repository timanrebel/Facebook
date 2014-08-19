var facebook = require('rebel.facebook');

// open a single window
var win = Ti.UI.createWindow({
	backgroundColor: 'white'
});

var button = Ti.UI.createButton({
	title: 'Login with Facebook'
});
button.addEventListener('click', onClick);

win.add(label);
win.open();

function onClick(evt) {
	facebook.authorize(['public_profile', 'email'], function(fbEvent) {

		if(fbEvent.success) {
			Ti.API.info(fbEvent.accessTokenData);

			facebook.requestNewPublishPermissions(['publish_actions'], facebook.audienceFriends, function(writeEvt) {
				Ti.API.info(writeEvt);
			});
		}
		else if(fbEvent.cancelled) {

		}
		else if(fbEvent.error) {

		}
	});
}
