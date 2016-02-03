--- 
layout: post
title: "Port your cordova multi-platform hybrid app to Windows Phone 8.1"
tags: ["cordova","phonegap","ionic", "windows phone"]
date: 2014-09-27
author: "Tomasz Subik"
permalink: /blog/port-your-cordova-multi-platform-hybrid-app-to-windows-phone-8.1/
---

Apache Cordova team announced official support for Windows Phone 8.1 platform in [version 3.6.3](http://cordova.apache.org/announcements/2014/09/22/cordova-361.html). Is it end of the agony for developers wanting to port their hybrid applications to Microsoft phone platform? I have some ionic application so let's find out.

<!--more-->

##Adding platform

```
cordova platform add windows
```

Why windows? Because of the support for some thing called 'Universal App', which means you can develop app once and run it on Windows 8, Windows 8.1 and Windows Phone 8.1. If you look at the created solution, there are few projects targeting different platforms and the common codebase.

![Universal App structure](/images/blog/universalapp_structure.png)

First thought - "Great I will have Windows desktop app also with some little efforts". Let's run the app on emulator (be aware of special switches between target platforms --phone --win)

```
cordova run windows -- --phone
```

And... **It is not working :(**. App crashes after open, I did not know what happened.

##Visual Studio for rescue

Running application from Visual Studio will show us what actually happens

>0x800c001c - JavaScript runtime error: Unable to add dynamic content. A script attempted to inject dynamic content, or elements previously modified dynamically, that might be unsafe. For example, using the innerHTML property to add script or malformed HTML will generate this exception. Use the htoStaticHTML method to filter dynamic content, or explicitly create elements and attributes with a method such as createElement.  For more information, see [http://go.microsoft.com/fwlink/?LinkID=247104](http://go.microsoft.com/fwlink/?LinkID=247104).

What!? Following link from error message you find out about automatic script filtering, manipulating DOM in 'secure way' and much more. That means jquery - doesn't works, angularjs - doesn't works, ionic - doesn't works, your code - probably doesn't work. You have to change all 'insecure' parts of libraries code due to get them works. But there are many more restrictions developing WinJS applications and right now If you want to create app this way you will have to follow Microsoft rules. So I gave up for now and I am looking forward to better days using Universal App.

[UPDATED: 2014-10-07] There is a small javascript shim library named [winstore-jscompat](https://github.com/MsopenTech/winstore-jscompat) created by [MSOpenTech team](http://msopentech.com/). It is nice workaround to injecting dynamic content restriction issue, but I still have some problems with ionic lib.

##So what now?

Another approach which I prefer and **it is working for my Ionic application** is using old wp8 platform.

```
cordova platform add wp8
```

Then follow these few steps:

- Retarget to Windows Phone 8.1. Open solution in visual studio, project properties.![VS retarget](/images/blog/vs_retarget.png)
- If you are not using Cordova 3.6.3 change all "execScript" to "eval" for the cordovalib
- Replace XHRHelper.cs with [this one](https://gist.github.com/tsubik/17598d9e142a6876a300) (I found it out somewhere on the web)

That's it! Now you can run emulator from Visual Studio and application works. It might not look like the same as on other devices you have to adapt it to IE11 :/.



