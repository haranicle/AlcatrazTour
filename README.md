![AlcatrazTour](./images/title.png)

An iOS app which shows Xcode plugins ranking.

[![appstore](./images/Download_on_the_App_Store_Badge_US-UK_135x40.svg)](https://itunes.apple.com/us/app/alcatraztour/id973816100?mt=8)

## Screen Shots

![ss1](./images/list_ss.png) ![ss1](./images/detail_ss.png)

## Requirements

* iOS 8.0 or later

## How to build?

1. Create a new app [here](https://github.com/settings/applications/new).
2. Get consumerKey and consumerSecret.
3. Write below to SecretConstants.swift. 

  ```
  let GithubKey =
  [
      "consumerKey": "yourConsumerKey",
      "consumerSecret": "yourConsumerSecret"
  ]
  ```
  
4. Open AlcatrazTour.xcworkspace with Xcode and build.
