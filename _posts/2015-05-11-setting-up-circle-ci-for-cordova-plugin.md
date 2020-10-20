---
layout: post
title: "Setting up Circle CI for Cordova plugin"
tags: ["cordova","circle-ci", "continuous integration", "testing"]
date: 2015-05-11
author: "Tomasz Subik"
permalink: /blog/setting-up-circle-ci-for-cordova-plugin/
---

Recently, I have been struggling with setting up a continuous development server for my Cordova plugin
([cordova-plugin-geofence](https://github.com/cowbell/cordova-plugin-geofence)).
I had been already using [Travis](https://travis-ci.org/) to kick off tests in iOS environment
for some time, but android also had been screaming for attention long enough.
I decided to go for [Circle CI](https://circleci.com/) as my android tests savior.
Anyway, not everything went so smooth, that's why I've felt compelled to share my solution with you guys.

<!--more-->

## Testing Cordova plugin

What I want to say at first, is that testing a Cordova plugin is not that trivial.
Especially if you have to support many versions of various operating systems.
It is impossible to test on every device, and every system, but it is necessary to support some at least.
What I needed, was a nice green badge in my github readme file which will tell people straight up that the plugin should work fine.
Another thing was the ability to have a quick glance at new pull requests if they are not breaking anything.
I've been testing using [cordova-plugin-test-framework](https://github.com/apache/cordova-plugin-test-framework)
for some time and I think this is a good solution if you don't want to write tests using native platform language.
It allows you to write functional tests with the use of [jasmine](http://jasmine.github.io/)
and also a manual set of tests. I don't want to digress here much, so testing Cordova plugins could be a topic for a new blog post.
What I want is to concentrate mostly on CI setup here.

## Circle CI

All you have to do to start using [Circle CI](https://circleci.com/) is: register,
hook up with your github account and set up circle.yml config file in your repository.
Sounds like a piece of cake, and if you have been using [Travis](https://travis-ci.org/) before,
the configuration is very similar.

I had found a few Cordova plugins which are using Circle CI and I was trying to just
quickly adjust the configuration for my needs. After experimenting I came up with <code class="inline">circle.yml</code>file like this:

{% highlight yaml %}
machine:
  environment:
    ANDROID_NDK_HOME: $ANDROID_NDK
    NODE_ENV: test
    PATH: $PATH:$HOME/$CIRCLE_PROJECT_REPONAME/node_modules/.bin
dependencies:
  override:
    - npm install
test:
  pre:
    - echo y | android update sdk --no-ui --all --filter "addon-google_apis-google-22, sys-img-armeabi-v7a-addon-google_apis-google-22"
    - android create avd --force -n test -t "Google Inc.:Google APIs:22" --abi armeabi-v7a --tag google_apis
    - emulator -avd test -no-audio -no-window:
        background: true
        parallel: true
    - circle-android wait-for-boot
  override:
    - cordova-paramedic --platform android --plugin .
{% endhighlight %}

## Notes

I would like to notice a few things here:

- I don't like to install npm packages globally, I always want to get the right version of
package specified in <code class="inline">packages.json</code> that's why I've extended
{% highlight yaml %}
PATH: $PATH:$HOME/$CIRCLE_PROJECT_REPONAME/node_modules/.bin
{% endhighlight %}
- My plugin is using Google Play Services. On Circle CI there is no preinstalled `avd` along
with Google Play Services, in that case you should install needed sdk and add new `avd` by yourself.

{% highlight yaml %}
- echo y | android update sdk --no-ui --all --filter "addon-google_apis-google-22, sys-img-armeabi-v7a-addon-google_apis-google-22"
- android create avd --force -n test -t "Google Inc.:Google APIs:22" --abi armeabi-v7a --tag google_apis
{% endhighlight %}

Then just kick off your `avd` in the emulator

{% highlight yaml %}
- emulator -avd test -no-audio -no-window:
    background: true
    parallel: true
- circle-android wait-for-boot
{% endhighlight %}

- I am running tests using [cordova-paramedic](https://github.com/purplecabbage/cordova-paramedic)
and as I said before, "how to test" - that's the topic for a separate post.

That's it! Happy testing.
