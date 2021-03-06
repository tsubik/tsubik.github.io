---
layout: post
title: "Keep your files in VS project included. Fast and elegant solution"
tags: ["Powershell Cmdlet",".NET","Visual Studio"]
date: 2012-09-22
author: "Tomasz Subik"
permalink: /blog/keep-your-files-in-vs-project-included-fast-and-elegant-solution/
---

In the previous article, I wrote a [simple PowerShell script](/blog/powershell-script-to-bring-your-publish-to-the-next-level/)
to find all of the potentially missing file references from my Visual Studio project files, but there were a couple issues with it.

<!--more-->

I realized, however, that the script has some performance issues. For a larger solution, it took quite
a few seconds to get the work done. So, I thought it would be much better to write some
kind of library for this job. The fact is, I do not want to write some external tools like a desktop application.
I want to keep it simple. Simple like… installing the additional modules by [nuget](http://nuget.org/).
Oh yeah, so just type some fancy command in the package manager console and let it be done.

Sounds perfect!

## Powershell cmdlet

You can write your custom command extension for PowerShell called [cmdlet](https://docs.microsoft.com/en-us/powershell/scripting/developer/cmdlet/cmdlet-overview?view=powershell-7).
So I wrote one to meet my requirements.
This is not a place for a tutorial *"How to create custom cmdlet"* that's why if you want to know
about it [here you have a few hints](http://community.bartdesmet.net/blogs/bart/archive/2008/02/03/easy-windows-powershell-cmdlet-development-and-debugging.aspx) about creating and dubugging cmdlets.

## VSpniff

Let’s focus on my tool. I called it [VSpniff](https://github.com/tsubik/VSpniff) – a shortcut from Visual Studio project not included files finder. You can download the tool from [here](https://github.com/tsubik/VSpniff). There is also instruction on how to get the tool work in your Visual Studio package manager console.

## Finding missing files references

Ok. How does this works?

Let's assume we have excluded files in the project

![excluded files](/images/blog/vspniff_01.png "Excluded files")

They could be accidentally excluded by a bad merge, for example, and we may not even know about it.
After installing [VSpniff](https://github.com/tsubik/VSpniff) you could use it to avoid such a situation. Just type in the PM console

<noscript><pre>
PM> Find-MissingFiles
</pre></noscript>
<script src="https://gist.github.com/3766167.js?file=vspniff_command"> </script>

And here we go

![missing files listed](/images/blog/vspniff_02.png "Missing files listed")

All the missing files listed.

## Configuration

If we do not want to look for, let's say, `.png` files in the Images folder, just add a config.vspniff file to the Images directory.

<noscript><pre>
mode: append
excludedExtensions: png
</pre></noscript>
<script src="https://gist.github.com/3766167.js?file=vspniff_config"> </script>

Run the tool once again and here we go

![missing files listed 2](/images/blog/vspniff_03.png "Missing files listed 2")

Configuration file must have .vspniff extension.

There is a default configuration and looks like that

<noscript><pre>
mode: override
excludedExtensions: user, csproj, aps, pch, vspscc, vssscc, ncb, suo, tlb, tlh, bak, log, lib
excludedDirs: bin, obj
</pre></noscript>
<script src="https://gist.github.com/3766167.js?file=vspniff_default_config"> </script>

I'm going to explain more in details.

<noscript><pre>
#Mode - it is the way that the module will treat your options
# append - it will append your options to current options context
# override - in this and subdirs will only take this file options (unless in subdirs are also some config files)
#excludedExtensions - files with these extensions will not be listed as missing files
#excludedDirs - program will not be looking in these locations for missing files
</pre></noscript>
<script src="https://gist.github.com/3766167.js?file=vspniff_config_description"> </script>

This is it. I hope you will find this tool useful and it will help you avoid many bugs.
