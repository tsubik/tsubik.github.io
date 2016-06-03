---
layout: post
title: "Make your Ember.js web app more progressive - part 1"
tags: ["ember", "progressive", "mobile-friendly"]
date: 2016-06-03
author: "Tomasz Subik"
permalink: /blog/make-your-emberjs-web-app-more-progressive-part-1
---

Anyone who follows the latest trends in front-end technologies probably came across the term
"Progressive Web Apps". It's not a new concept, but [the latest Google I/O conference][google-io-conference]
shed new light on it and gather some extra technologies and libraries which could help you to make apps more
"progressive". I want to show you how with a little effort you could start applying those concepts.
This is the first part of the series in which I will show you some enhancements, you could pick up.

<!--more-->

## What are progressive web apps?

Ok, Man, but "Progressive Web App" what does it mean, actually? I don't want to give you a long song and dance about
the definition or terminology. You could easily find it for example [here][google-progressive-web-apps].
Or better, I strongly encourage you to watch [a great presentation][addy-osmani-presentation] by [Addy Osmani][addy-osmani]
hosted on [the latest Google I/O conference][google-io-conference]. Frankly, that was my motivation to give a more throughout
glance into this stuff, and I'm sure that many of you will find it as much interesting as I did.
In the nutshell, Progressive Web Apps concept is about making your App much more mobile friendly,
almost like a native app (responsiveness, push notifications, device capabilities, splash screens, offline support, etc.).

## Splittypie goes progressive

I've got a working application which I've felt is a great candidate to play with "progressive" concepts around.
It's called [Splittypie][splittypie] and it is an easy expense splitter. The app is written in
Ember.js and source code is available [here][splittypie-source]. It is already mobile friendly
to some extent, it's responsive, looks like a mobile app on mobile devices, it also has nice
mobile friendly drawer ;). I will continuously try to add Progressive Web App
enhancements on [offline support branch][offline-support-branch] and publish new version [here][splittypie-offline].

## Home screen launcher, Splash screen, fullscreen mode

This is very easy thing to do. Unfortunately, it doesn't completely work on all major browsers and mobile OSes yet.

### Android way

Create manifest.json file, in ember app, put it into /public folder. Manifest file contains
some crucial information like app name, display orientation, start_url, icons, splash screen.
You could create it manually or search for manifest file generator. I've used [this one][manifest-generator].

You also need to inform the browser in your index.html about manifest file.

{% highlight html %}

<link rel="manifest" href="manifest.json">

{% endhighlight %}

And here is mine manifest file (for clarity, I omit the rest of icons)

{% highlight json %}

{
  "name": "Splittypie - Split expenses with ease",
  "short_name": "Splittypie",
  "theme_color": "#ffffff",
  "background_color": "#ffffff",
  "display": "standalone",
  "orientation": "portrait",
  "start_url": "/",
  "icons": [
    {
      "src": "assets/icons/icon-72x72.png",
      "sizes": "72x72",
      "type": "image/png"
    },
    {
      "src": "assets/icons/icon-96x96.png",
      "sizes": "96x96",
      "type": "image/png"
    }
    ... omiting the rest of icons
  ]
}

{% endhighlight %}

If you are using assets fingerprinting don't forget to exclude your icons (or hook up manifest.json file
into your assets pipeline somehow)

{% highlight js %}

const app = new EmberApp(defaults, {
    fingerprint: {
        exclude: ["assets/icons/"],
        enabled: (env === "production" || env === "staging"),
    },
});

{% endhighlight %}

And now, on your android device using Google Chrome's function "Add to Home Screen" function you can
add a shortcut to your application. Great thing is that not only you have the application with your
chosen icon on home screen, but also you have very basic splash screen and you got rid of
the annoying address bar (you can preserve it if you like). Your app looks more like a native one now.

![android-splittypie-icon](/images/blog/android-splittypie-icon.png "Home Screen Icon")
![android-splash-screen](/images/blog/android-splash-screen.png "Android Splash Screen")
![android-splittypie-screen](/images/blog/android-splittypie-screen.png "Android Splittypie Screen")

[Here][google-homescreen-detailed] you can find more detailed information.

### Web App Install Banners

But, there is a better way to encourage your users to add an application to the home screen.
It is a Chrome feature and it's called ["Web App Install Banners"][web-app-install-banners].

<p class="text-center">
  <img src="/images/blog/android-web-install-banner.png" alt="Android Web Install Banner" />
</p>

There are few requirements to enable this feature like:

- You must have a web app manifest file with short_name, start_url, at least 144x144 image/png icon set,
- you must have a service worker registered, it could be empty <code class="inline">service-worker.js</code>
file with simple registration as follows

{% highlight js %}
<script>
  navigator.serviceWorker.register("service-worker.js", { scope: "./" })
    .then(function(res) {
      console.log("registered service worker");
    })
    .catch(function(error) {
      console.error("error... ");
      console.error(error);
    });
</script>
{% endhighlight %}

- your app is served over HTTPS
- the user has visited your site at least twice, with some time between visits (I think that time
changed and it's currently a day).

For testing you can force the banner to appear by setting the
chrome://flags/#bypass-app-banner-engagement-checks flag.
Anyway, with this flag enabled, it looks like the banner keeps appearing every time I visit the website.

Note that above requirements may change over time.

### iOS way

Adding application launcher to the Home Screen is also possible on iOS devices (through Safari of course).
In this case, you don't need to create any manifest files, you only need to add a few links to proper icons and
meta tags to document's head element.

{% highlight html %}

<link rel="apple-touch-icon" href="assets/icons/ios/icon-60x60.png">
<link rel="apple-touch-icon" sizes="76x76" href="assets/icons/ios/icon-76x76.png">
<link rel="apple-touch-icon" sizes="120x120" href="assets/icons/ios/icon-120x120.png">
<link rel="apple-touch-icon" sizes="152x152" href="assets/icons/ios/icon-152x152.png">

<!-- Unfortunately this doesn't work on iOS9 ugh, wtf apple? -->
<link rel="apple-touch-startup-image" href="assets/icons/ios/startup.png">

<meta name="apple-mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-status-bar-style" content="black">

{% endhighlight %}

Just follow [the official guidelines][ios-home-screen].

## Conclusions

A Progressive Web App uses modern web capabilities to deliver a native app-like user experience.
You can start small and make your app more mobile friendly today. There are a lot of great articles
about Progressive Web Apps out there, you can start with [Addy Osmani's article][addy-blog-post].
I know, I barely scratch the surface in this post. The next part will be dedicated to assets caching.
I hope, I'll find time to write it soon.

[google-io-conference]: https://events.google.com/io2016
[google-progressive-web-apps]: https://developers.google.com/web/progressive-web-apps
[addy-osmani-presentation]: https://www.youtube.com/watch?v=srdKq0DckXQ
[addy-osmani]: https://addyosmani.com
[splittypie]: https://splittypie.com
[splittypie-source]: https://github.com/cowbell/splittypie
[offline-support-branch]: https://github.com/cowbell/splittypie/tree/offline-support
[splittypie-offline]: https://splittypie-offline.firebaseapp.com
[google-homescreen-detailed]: https://developer.chrome.com/multidevice/android/installtohomescreen
[manifest-generator]: https://app-manifest.firebaseapp.com
[web-app-install-banners]: https://developers.google.com/web/updates/2015/03/increasing-engagement-with-app-install-banners-in-chrome-for-android
[ios-home-screen]: https://developer.apple.com/library/ios/documentation/AppleApplications/Reference/SafariWebContent/ConfiguringWebApplications/ConfiguringWebApplications.html
[addy-blog-post]: https://addyosmani.com/blog/getting-started-with-progressive-web-apps
