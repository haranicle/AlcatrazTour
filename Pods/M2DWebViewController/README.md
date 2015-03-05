# M2DWebViewController

[![CI Status](http://img.shields.io/travis/Akira Matsuda/M2DWebViewController.svg?style=flat)](https://travis-ci.org/Akira Matsuda/M2DWebViewController)
[![Version](https://img.shields.io/cocoapods/v/M2DWebViewController.svg?style=flat)](http://cocoadocs.org/docsets/M2DWebViewController)
[![License](https://img.shields.io/cocoapods/l/M2DWebViewController.svg?style=flat)](http://cocoadocs.org/docsets/M2DWebViewController)
[![Platform](https://img.shields.io/cocoapods/p/M2DWebViewController.svg?style=flat)](http://cocoadocs.org/docsets/M2DWebViewController)


![](https://raw.github.com/0x0c/M2DWebViewController/master/images/1.png)
![](https://raw.github.com/0x0c/M2DWebViewController/master/images/2.png)
![](https://raw.github.com/0x0c/M2DWebViewController/master/images/3.png)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

Try this

	M2DWebViewController *viewController = [[M2DWebViewController alloc] initWithURL:[NSURL URLWithString:@"https://github.com/0x0c/M2DWebViewController"] type:M2DWebViewTypeUIKit];

or this

	M2DWebViewController *viewController = [[M2DWebViewController alloc] initWithURL:[NSURL URLWithString:@"https://github.com/0x0c/M2DWebViewController"] type:M2DWebViewTypeUIKit];
	__weak typeof(viewController) bviewcontroller = viewController;
	viewController.actionButtonPressedHandler = ^(NSString *pageTitle, NSURL *url){
		UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[pageTitle, url] applicationActivities:@[]];
		[bviewcontroller presentViewController:activityViewController animated:YES completion:^{
		}];
	};

If you want to use WebKit on iOS8, try this.

	M2DWebViewController *viewController = [[M2DWebViewController alloc] initWithURL:[NSURL URLWithString:@"https://github.com/0x0c/M2DWebViewController"] type:M2DWebViewTypeWebKit];


## Requirements
iOS7 or later.

## Installation

M2DWebViewController is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "M2DWebViewController"

## Author

Akira Matsuda, akira.m.itachi@gmail.com

## License

M2DWebViewController is available under the MIT license. See the LICENSE file for more info.

