---
layout: post
title: "Make your Ember.js web app more progressive - part 2: Offline caching"
tags: ["ember", "progressive", "mobile-friendly", "offline-mode"]
date: 2016-06-16
author: "Tomasz Subik"
permalink: /blog/make-your-emberjs-web-app-more-progressive-part-2-offline-caching
---

This is the second part of the series about making your ember app more mobile friendly,
more progressive. [The first part][first-post] was about adding Home Screen icons,
Splashscreen, and controlling app shell display on mobile devices. This time, I want to
write more about offline assets caching.

<!--more-->

## Offline caching - quick recap

Offline caching is on the market for many years, and browsers, of course, can cache pages
and assets too, but this mechanism cannot be reliable as a browser can throw out cache at
any point. The main point of all this hassle is for you to be able to visit the application site
subsequent time without Internet connection. There is an [ApplicationCache interface][app-cache-beginners]
to tackle this problem, but it is obsolete now, and you had to [mind many gotchas][app-cache-douchebag] along the way of using it.
The new way utilizes [service workers][service-workers] to achieve the same goal.

## What is a service worker?

In the nutshell, service worker is a JavaScript script which runs in a separate thread in the browser.
There is a standardized API designed to allow communication between your web application and its
service workers. I strongly encourage you to look up for more information about this concept.
Here are a few things you could achieve using those scripts:

* [offline caching][offline-caching]
* [background syncing][background-syncing]
* [push notifications][push-api]
* [geo-fencing][geo-fencing] (I'd love to make a post about it in the future)

In this particular post I'm writing about the first case, but stay tuned to my blog,
the moar stuff about service workers is coming ;).

So, back to offline support, comparing to mentioned ApplicationCache, [Service Worker API][service-workers] is a way more complicated,
but also a way more powerful. The main difference is a flexibility that is given to us, we can
programmatically control which assets and how will be cached.

## How to use Service worker with Cache API

Before I go any further, it is worth to mention that your application must be served over HTTPS. This is
a requirement for service workers to work :).

I will shuffle with some code so you can get a general idea.

### Register service worker

First you have to register it.

{% highlight javascript %}

if ("serviceWorker" in navigator) {
      navigator.serviceWorker.register("sw.js").then(function(reg) {
    console.log("Service worker registered");
  }).catch(function(error) {
    // registration failed
    console.log("Registration failed with " + error);
  });
};
}

{% endhighlight %}

### Service worker lifecycle

Service workers have two lifecycle events you can attach to: [install][install-event], [activate][activate-event]
and another [fetch event][fetch-event] that we will be using to serve cached assets.

### Add things to cache

Part of the Service Worker API is a [Cache Interface][cache-interface] which provides
a storage mechanism for your assets. You are responsible for handling cache updates/purge/etc.

Here is a simple example how we could use install event to cache your assets.

{% highlight javascript %}

self.addEventListener("install", (event) => {
  // wait until promise resolved/rejected
  event.waitUntil(
    // use cache store called v1
    caches.open("v1").then((cache) => {
      // Cache all these urls
      return cache.addAll([
        '/',
        '/index.html',
        '/css/index.css',
        '/js/index.js',
        '/img/image.png',
      ]);
    })
  );
});

{% endhighlight %}

### Fetch things from cache

As we have something cached, we would like to use it somehow when the user visits
our application subsequent time. [FetchEvent][fetch-event] is dedicated to doing that. You can modify
the response to requests in any way you want using `respondWith` method, so it's
basically a proxy to all requests.

{% highlight javascript %}

self.addEventListener("fetch", (event) => {
  event.respondWith(
    // Return cached file if it exists
    caches.match(event.request).catch(() => {
      // no match found then fetch response from the network
      // at this stage you could also store following request's response
      // in the cache to prevent making round-trips to the network
      return fetch(event.request);
    });
  );
});

{% endhighlight %}

### What about updates?

What if your service worker script changes? Simply, the new version of service worker is installed in the
background, but it could be not active yet. It is only activated when there are no longer any pages
loaded that are still using the old version. That's why it is a good practice to use a different
cache store for the new version, let's say "v2". You should get rid of the old cache in ["activate" lifecycle
event][activate-event] when the new service worker takes control.

{% highlight javascript %}

this.addEventListener("activate", function(event) {
  var cacheWhitelist = ["v2"];

  event.waitUntil(
    caches.keys().then(function(keyList) {
      return Promise.all(keyList.map(function(key) {
        if (cacheWhitelist.indexOf(key) === -1) {
          return caches.delete(key);
        }
      }));
    })
  );
});

{% endhighlight %}

### Some helpers

Above examples were framework agnostic and should give you some basic understanding of the whole idea.
And what's more, there are some tools to simplify the process like [sw-toolbox][sw-toolbox] which provides caching
strategies and [sw-precache][sw-precache] util to generate `service-worker.js` that precaches resources for you.

## How to start offline caching in Ember.js app

You may think, finally some Ember stuff but I feel compelled to made above introduction.
Anyway, as in [the first post][first-part] I will be using [SplittyPie][splittypie] application as
an example. Until complete offline support is not finished, the working example is served [here][splittypie-offline]

### Broccoli Service Worker

There is a great [service worker generator][broccoli-serviceworker] which will ease our process a lot.

{% highlight shell %}

ember install broccoli-serviceworker

{% endhighlight %}

What this does is generate `service-worker.js` and add service worker register code to your `index.html`.
It uses mentioned [sw-toolbox][sw-toolbox] library which helps with various caching strategies.

In order to enable this addon, add some configuration into `app/config/environment.js` file.

{% highlight javascript %}

ENV.serviceWorker = {
    enabled: true,
    debug: true,
};

{% endhighlight %}

By default, it will add all Ember app resources (files in `dist` folder) as precached assets using
cache first strategy. Available cache strategies are described [here][broccoli-serviceworker-cache-strategies].

In many applications, that could be the last step, although I had to make some further adjustments.

I'm using google fonts fetched directly from google CDNs and "history" location type.

See my current setup below.

{% highlight javascript %}

ENV.serviceWorker: {
    enabled: true,
    debug: true,
    precacheURLs: [
        "/app.html",
    ],
    fastestURLs: [
        { route: "/(.*)", method: "get", options: { origin: "https://fonts.gstatic.com" } },
        { route: "/css", method: "get", options: { origin: "https://fonts.googleapis.com" } },
    ],
    fallback: [
        "/(.*) /app.html",
    ],
},

{% endhighlight %}

I'm using different preloader page for other than index page requests (app.html just showing "Loading Splittypie..."),
that's why the need of pre-cache this page and fallback if a user is offline. Additionally, you can see
caching Google fonts using "fastest strategy". About cache strategies you can read on
[sw-toolbox documentation][sw-toolbox-api].

## What's next?

Unfortunately, my [SplittyPie][splittypie] still doesn't work without internet connection as
I'm using firebase as a data layer. That's why the next part is going to be about an offline data access
and synchronization.

[first-post]: https://tsubik.com/blog/make-your-emberjs-web-app-more-progressive-part-1
[app-cache-beginners]: http://www.html5rocks.com/en/tutorials/appcache/beginner
[app-cache-douchebag]: http://alistapart.com/article/application-cache-is-a-douchebag
[service-workers]: https://developer.mozilla.org/en-US/docs/Web/API/Service_Worker_API
[offline-caching]: https://developer.mozilla.org/en-US/docs/Web/API/Service_Worker_API/Using_Service_Workers
[background-syncing]: https://wicg.github.io/BackgroundSync/spec
[push-api]: https://www.w3.org/TR/push-api
[geo-fencing]: https://www.w3.org/TR/geofencing
[install-event]: https://developer.mozilla.org/en-US/docs/Web/API/InstallEvent
[activate-event]: https://developer.mozilla.org/en-US/docs/Web/API/ExtendableEvent
[fetch-event]: https://developer.mozilla.org/en-US/docs/Web/API/FetchEvent
[cache-interface]: https://developer.mozilla.org/en-US/docs/Web/API/Cache
[sw-toolbox]: https://github.com/GoogleChrome/sw-toolbox
[sw-precache]: https://github.com/GoogleChrome/sw-precache
[splittypie]: https://splittypie.com
[splittypie-offline]: https://splittypie-offline.firebaseapp.com
[broccoli-serviceworker]: https://github.com/jkleinsc/broccoli-serviceworker
[broccoli-serviceworker-cache-strategies]: https://github.com/jkleinsc/broccoli-serviceworker#routing-options
[sw-toolbox-api]: https://googlechrome.github.io/sw-toolbox/docs/master/tutorial-api
