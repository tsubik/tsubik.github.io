--- 
layout: post
title: "Setting up Circle CI for cordova plugin"
tags: ["cordova","circle-ci", "continuous integration", "testing"]
date: 2015-05-11
author: "Tomasz Subik"
permalink: /blog/setting-up-circle-ci-for-cordova-plugin/
---

Recently, I was struggling with setting up continuous development for my [cordova geofence plugin](https://github.com/cowbell/cordova-plugin-geofence). For android version I had chosen [Circle CI](https://circleci.com/). I had a few problems with this and just want to share with my solution.

<!--more-->

##Testing cordova plugin

Basically testing cordova plugin is not an easy task, especially if you support few platforms and versions of operating system. It is impossible to test on every device and every system but it is good to have something. What I want was a nice green badge on github which informs people that plugin works and also I want to have quick glance if new pull requests are not breaking anything. I've been testing using [cordova plugin test framework](https://github.com/apache/cordova-plugin-test-framework) for some time and I think this is good solution if you don't want to write tests in native platform languages, just to have functional and/or manual set of tests. Testing cordova plugins could be a topic for a new blog post, here I will concentrate only on CI.

##Circle CI

All you need to do to start using circle CI is register, hook up with your github account and set up circle.yml config file in your repository. Easy, and if you have been using CI like [Travis](https://travis-ci.org/) before configuration is very similar.

I had found some plugins which are using circle CI and I was trying to just quickly adjust configuration for my needs. After experimenting I've ended up with<code class="inline">circle.yml</code>file like this:

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

##Notes

I would like to notice a few things:

- I don't like to install npm packages globally, I always want to get package of version specified in<code class="inline">packages.json</code>that's why I've extended
{% highlight yaml %}
PATH: $PATH:$HOME/$CIRCLE_PROJECT_REPONAME/node_modules/.bin
{% endhighlight %}
- My plugin is using Google Play Services, there is no preinstalled avd on circle CI with google play services, that's why you should install needed sdk and add new avd by yourself.

{% highlight yaml %}
- echo y | android update sdk --no-ui --all --filter "addon-google_apis-google-22, sys-img-armeabi-v7a-addon-google_apis-google-22"
- android create avd --force -n test -t "Google Inc.:Google APIs:22" --abi armeabi-v7a --tag google_apis
{% endhighlight %}

Then just run your avd in emulator

{% highlight yaml %}
- emulator -avd test -no-audio -no-window:
    background: true
    parallel: true
- circle-android wait-for-boot
{% endhighlight %}

- I am running tests using cordova-paramedic and as I said before, "how to test" that should be a separate post.

That's it! Happy testing.
