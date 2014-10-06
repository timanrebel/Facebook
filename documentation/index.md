# Facebook Module

This module is work in progress and it's API is not yet stable.
That is, backwards incompatible changes might still be pushed.

## Quick Start

### Get it [![gitTio](http://gitt.io/badge.png)](http://gitt.io/component/rebel.facebook)
Download the latest zip file from [Releases](https://github.com/timanrebel/Facebook/releases) and consult the [Titanium Documentation](http://docs.appcelerator.com/titanium/latest/#!/guide/Using_a_Module) on how install it, or simply use the [gitTio CLI](http://gitt.io/cli):

`$ gittio install rebel.facebook`

## Accessing the Facebook Module

To access this module from JavaScript, you would do the following:

`var facebook = require('rebel.facebook');`


The facebook variable is a reference to the Module object.

## Reference

The documentation is split up in the following sections:

* [Login with Facebook](authentication.md)
* [Dialogs and UI controls](dialogs.md)
* [Like button](like.md)
* [App Events](appEvents.md)
* [Graph API](graphApi.md)

## Changelog

* [1.0.6](https://github.com/timanrebel/Facebook/releases/tag/1.0.6) Added support for the new native Like button
* [1.0.4](https://github.com/timanrebel/Facebook/releases/tag/1.0.4) Added support for Login button, rewrote internal structure and re-added login/logout events
* [1.0.2](https://github.com/timanrebel/Facebook/releases/tag/1.0.2) Support for first Graph API call and Share Dialog
* [1.0.1](https://github.com/timanrebel/Facebook/releases/tag/1.0.1) Support for App Events
* [1.0.0](https://github.com/timanrebel/Facebook/releases/tag/1.0.0) Initial working version with only Facebook login

## Author

Timan Rebel

## License

The MIT License (MIT)

Copyright (c) 2014 Timan Rebel

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
