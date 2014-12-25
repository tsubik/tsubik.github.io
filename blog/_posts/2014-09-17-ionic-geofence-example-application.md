--- 
layout: post
title: "Ionic geofence example application"
tags: ["Ionic","angularjs","javascript", "mobile"]
date: 2014-09-17
author: "Tomasz Subik"
permalink: /blog/ionic-geofence-example-application/
---

For some month or two I left the .NET world and spent more time exploring new horizons, especially mobile development stuff. I had an idea of mobile application and now have time to make it come true. After initial research I decided to build a hybrid application which means the whole thing runs inside WebView component on the device. That approach allows me to use javascript with [angularjs](https://angularjs.org/). The last thing I needed was some CSS/JS framework to manage visual layer and friend of my came with help suggesting to look at [ionic](http://ionicframework.com/). 

<!--more-->

##[Ionic](http://ionicframework.com/)

What is ionic? 

> Ionic is a powerful HTML5 native app development framework that helps you build native-feeling mobile apps all with web technologies like HTML, CSS, and Javascript.
> 
>Ionic is focused mainly on the look and feel, and UI interaction of your app. That means we aren't a replacement for PhoneGap or your favorite Javascript framework. Instead, Ionic simply fits in well with these projects in order to simplify one big part of your app: the front end
>
>Ionic currently requires AngularJS in order to work at its full potential

Ionic is develop by company [drifty](http://drifty.com/) and as they claim they are well founded so you do not have to worry it will be gone within a few months.

##About the example app

Why example? Because I am in the middle of development and there is nothing good to show in context of original application that why I decided to create sample project that will show one of the features which is geofencing.

##Geofencing

Geofencing is a simple idea of creating and monitoring virtual perimeter for a real world geographic area. Geofence could be any shaped area: rectangular, circural, polygon, everything depends on implementation. Geofencing could be used to set an alarm if someone enter/exit monitored region or dwell within for certain time. It could be useful to notify user about promotions, cool places around or simply to remind to do groceries when the store is nearby. 

##Geofencing on mobile devices

Currently as I know, geofences are implemented on mainstream smartphone platforms on the market - Android (via [Google Play Location Services](https://developer.android.com/google/play-services/location.html)), IOS (via [Core Location Framework](https://developer.apple.com/library/ios/documentation/CoreLocation/Reference/CoreLocation_Framework/_index.html)) and Windows Phone 8.1. 

I decided to build my application in hybrid way but geofences are implemented on the platform native layer that why there is a need to use special [cordova](http://cordova.apache.org/) plugin which will be bridge between my javascript application code and native libraries.

##Cordova geofence plugin

I was looking for a plugin to manage geofences but could not find anything interesting that is why I came up with my own [cordova geofence plugin](https://github.com/tsubik/cordova-plugin-geofence) which have some nice features:

* set, remove geofence (of course :))
* geofences persist after device reboot - no need to start an app, geofences are monitored instantly after device rebooting
* notifications - when you click on notification your app will be started, you can also pass some data to app to for example open specific page
* and much more coming soon

As I am writing this I only support Android platform but IOS and WP 8.1 will be supported soon.

##Example app

For the sake of simplicity after long introduction I want to show just couple of screenshots with short description.

![Ionic geofence application](https://cloud.githubusercontent.com/assets/1286444/4302807/604c7c5e-3e5e-11e4-87df-99b22abffdc8.jpg)

The app is build with [angularjs](https://angularjs.org/) and [Ionic framework](http://ionicframework.com/) and have some nice features:

*  add, remove circular geofences with radius, notification text and transition type
*  using leaflet open street map by [angular leaflet directive](https://github.com/tombatossals/angular-leaflet-directive)
*  application notify I you enter/exit monitored geofence
*  if you click on notification app will start and go to the details of triggered geofence. 

[Check it out on the github](https://github.com/tsubik/ionic-geofence). Instruction and how to install application are also there.
