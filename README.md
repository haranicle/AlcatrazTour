![AlcatrazTour](https://github.com/haranicle/AlcatrazTour/raw/master/images/title.png)

An iOS app which shows Xcode plugins ranking.

## Screen Shots

![ss1](https://github.com/haranicle/AlcatrazTour/raw/master/images/list_ss.png)  
  
![ss1](https://github.com/haranicle/AlcatrazTour/raw/master/images/detail_ss.png)

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
