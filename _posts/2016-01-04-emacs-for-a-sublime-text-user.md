---
layout: post
title: "Emacs for a Sublime Text user"
tags: ["emacs", "sublime", "texteditor"]
date: 2016-01-04
author: "Tomasz Subik"
permalink: /blog/emacs-for-a-sublime-text-user/
---

A few weeks ago I decided to switch most of my development work to Emacs. Let me say it upfront, I don’t want to take a part in any "holy war" around which text editor is best or whatever. I just want to share my experience here, how did that switch look like from the standpoint of a 'typical’ Sublime Text user.

<!--more-->

I still think that Sublime Text is a magnificent piece of software, it’s beautiful, it’s pretty damn fast, well-configured out of the box, and so on. So you may ask me: Why did you decide to make a switch? To cut a long story short, I just wanted to try something else, something way different that will broaden my perspective. Maybe I will return to Sublime in about a month or two, who knows. I have no intentions to make "why to switch" and "why Emacs" the main topic of this entry and my only goal is to pinpoint what I have missed from Sublime after few weeks of using Emacs and what can I do about it.

> Update [24.05.2016]: I've finally set up with [Emacs prelude][emacs-prelude]. After few months of using it,
I could highly recommend it for anyone whether you are a newbie or more experienced Emacs user. Emacs prelude comes with many great packages and features configured out of the box. What's more, it is easy to customize. Here is the [repo][emacs-prelude-config]
where I store my prelude personal configuration.

## Autocomplete

This is pretty straightforward, install package named [auto-complete][auto-complete]. I’m using the default configuration.

{% highlight lisp %}
(ac-config-default)
{% endhighlight %}

## Multiple cursors

There is [multiple-cursors][multiple-cursors] for that. It’s pretty awesome. You need to bring up your own keybindings.

{% highlight lisp %}
(require 'multiple-cursors)
(global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines)
(global-set-key (kbd "C->") 'mc/mark-next-like-this)
(global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
(global-set-key (kbd "C-c C-<") 'mc/mark-all-like-this)
{% endhighlight %}

## Smart parenthesis

I love Sublime auto pairing brackets, parenthesis and guess what? There is a package for this in Emacs too. It’s called [smartparens][smartparens] and actually, it gives you much more than just inserting pairs. There is also wrapping, unwrapping, rewrapping, expanding, etc. If you want to use that package everywhere, put this into your config.

{% highlight lisp %}
(require 'smartparens-config)
(smartparens-global-mode)
{% endhighlight %}

## Navigation tree

Quick directory tree when I can look at my project structure or swiftly manipulate with files is a must-have feature of code editor for me. Unfortunately, Emacs doesn’t have anything like that out of the box, but there are some solutions online. My go for is [neotree][neotree] package.

{% highlight lisp %}
(global-set-key [f8] 'neotree-toggle)
{% endhighlight %}

## Project scope

There is no such thing as "Open Project" (or directory) in Emacs but I really like to have some functionalities working in project scope like: opening files, searching in files, project directory tree. [Projectile][projectile] package is a salvage here. The list of features is enormous, but the most important for me are like:

* switching projects
* integration with neotree (switching project causes changing root in neotree, great:)
* go to any file from the project(like Ctrl+P in Sublime)
* search in project files with ag package (this is really cool)

## Fuzzy matching

Of course, fuzzy matching has always been a killer feature for Sublime. Once you taste it, you will never live without it. Emacs is using ido completion system by default. You can go for other like helm or grizzly, but I decided to put ido on steroids with available packages and configuration. You can just enable ido flex matching, but I followed a more advised path which is installing [flx-ido][flx-ido] package along with [ido-vertical-mode][ido-vertical-mode] for more clarity.

{% highlight lisp %}
(require 'flx-ido)
(ido-mode 1)[flx-ido]
(ido-everywhere 1)
(flx-ido-mode 1)
(ido-vertical-mode 1)
;; disable ido faces to see flx highlights.
(setq ido-enable-flex-matching t)
(setq ido-use-faces nil)
{% endhighlight %}

To enable flex matching in Emacs command interface (M-x) I installed [smex][smex] package and adjusted key bindings.

{% highlight lisp %}
(global-set-key (kbd "M-x") 'smex)
(global-set-key (kbd "M-X") 'smex-major-mode-commands)
;; This is your old M-x.
(global-set-key (kbd "C-c C-c M-x") 'execute-extended-command)
{% endhighlight %}

I consider myself as an Emacs Noob so I guess above list will be appended in time and also please correct me if I wrote some gibberish here.

[emacs-prelude]: https://github.com/bbatsov/prelude
[emacs-prelude-config]: https://github.com/tsubik/emacs-prelude-personal
[auto-complete]: https://github.com/auto-complete/auto-complete
[multiple-cursors]: https://github.com/magnars/multiple-cursors.el
[smartparens]: https://github.com/Fuco1/smartparens
[neotree]: https://github.com/jaypei/emacs-neotree
[projectile]: http://batsov.com/projectile/
[ag]: https://github.com/Wilfred/ag.el
[flx-ido]: https://github.com/lewang/flx
[ido-vertical-mode]: https://github.com/creichert/ido-vertical-mode.el
[smex]: https://github.com/nonsequitur/smex
