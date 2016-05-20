---
layout: post
title: "Setup ESLint for your Ember project"
tags: ["ember", "eslint"]
date: 2016-05-20
author: "Tomasz Subik"
permalink: /blog/setup-eslint-for-your-ember-project
---

I haven't posted anything for months, and I want to change that soon.
But, as my time is limited recently I want to start small. Just a quick tip for today.
I have been struggling with some obstacles when switching from jshint to eslint in my Ember projects,
whether due to updated Ember library, cli, or some other not so well documented changes.
However, now it seems to be a really easy job to do.

<!--more-->

## Just a few quick steps

Which are:

* uninstall <code class="inline">ember-cli-jshint</code>
* <code class="inline">ember install ember-cli-eslint</code>
* that's it. You can start configuring
* if you want to use plugins <code class="inline">npm install eslint-plugin-import --save-dev</code>

## My configuration

My go for configuration for ember projects is based on <code class="inline">airbnb-base</code> style guides.
You will also need to install a couple more things.

{% highlight bash %}

  npm install eslint-config-airbnb-base --save-dev
  npm install eslint-plugin-import --save-dev
  npm install eslint-plugin-babel --save-dev
  npm install babel-eslint --save-dev

{% endhighlight %}

And my entire <code class="inline">.eslintrc</code> file

{% highlight json %}

{
  "extends": "airbnb-base",

  "env": {
    "browser": true,
    "es6": true,
    "node": true
  },

  "parser": "babel-eslint",

  "plugins": [
    "babel"
  ],

  "rules": {
    "quotes": [2, "double", "avoid-escape"],
    "indent": [2, 4],
    "func-names": 0,
    "no-use-before-define": [2, "nofunc"],
    "prefer-arrow-callback": 0,
    "prefer-rest-params": 0,
    "new-cap": 0,
    "babel/new-cap": 1,
    "import/no-unresolved": 0,
    "no-underscore-dangle": 0
  }
}

{% endhighlight %}

I hope some of you find this post helpful.
