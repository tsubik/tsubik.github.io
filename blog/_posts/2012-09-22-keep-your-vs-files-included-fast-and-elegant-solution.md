--- 
layout: post
title: "Keep your files in VS project included. Fast and elegant solution"
tags: ["Powershell Cmdlet",".NET","Visual Studio"]
date: 2012-09-22
author: "Tomasz Subik"
permalink: /blog/keep-your-files-in-vs-project-included-fast-and-elegant-solution/
---

In the previous article I wrote a [simple powershell script](/blog/powershell-script-to-bring-your-publish-to-the-next-level/) to find all of the potentially missing file
references from my Visual Studio project files.

I realized, however, that the script has some performance issues. For a large solution, it takes quite a few seconds to get the work done.  So, I thought it would be much better to write some kind of library for this job. The fact is, I do not want to write some external tools like desktop application. I want to keep it simple. Simple like… installing the additional modules by [nuget](http://nuget.org/). Oh yeah, so just type some fancy command in package manager console and let it be done.


<!--more-->

Sounds perfect!

Powershell cmdlet
-----------------

You can write your custom command extension for powershell, it is called “cmdlet”.
So I wrote one to meet my requirements. 
This is not a place for a tutorial "How to create custom cmdlet" that's why if you want to know about it [here you go some some hints](http://community.bartdesmet.net/blogs/bart/archive/2008/02/03/easy-windows-powershell-cmdlet-development-and-debugging.aspx) about creating and dubugging cmdlets. 

VSpniff
-------

Let’s focus on my tool. I called it [VSpniff](https://github.com/tsubik/VSpniff) – shortcut from Visual Studio project not included files finder. You can download the tool from [here](https://github.com/tsubik/VSpniff). There is also an instruction how to get the tool work in your Visual Studio package manager console.

Finding missing files references
--------------------------------
Ok. So how does this works? Let’s simply assume we have some excluded files in project

![excluded files](/images/blog/vspniff_01.png "Excluded files")

They could be accidentally excluded by bad merge or something and we may not even know about it.
After installing [VSpniff](https://github.com/tsubik/VSpniff) you could use it to avoid such situations. Just type in the PM console

<noscript><pre>
PM> Find-MissingFiles
</pre></noscript>
<script src="https://gist.github.com/3766167.js?file=vspniff_command"> </script>

And here we go

![missing files listed](/images/blog/vspniff_02.png "Missing files listed")

All the missing files listed.

Configuration
------------------

Ok. Let assume we do not want to look for .png files in the Images folder  ;]. To do that, just add a config.vspniff file to the Images directory.

<noscript><pre>
mode: append
excludedExtensions: png
</pre></noscript>
<script src="https://gist.github.com/3766167.js?file=vspniff_config"> </script>

Run the tool once again and here we go

![missing files listed 2](/images/blog/vspniff_03.png "Missing files listed 2")

Configuration file must have .vspniff extension.

There is a default configuration in the box (hard coded) to avoid the need of adding any
configuration files.
This default configuration looks like that

<noscript><pre>
mode: override
excludedExtensions: user, csproj, aps, pch, vspscc, vssscc, ncb, suo, tlb, tlh, bak, log, lib
excludedDirs: bin, obj
</pre></noscript>
<script src="https://gist.github.com/3766167.js?file=vspniff_default_config"> </script>

Ok. So what does it mean?

<noscript><pre>
#Mode - it is the way that the module will treat your options
# append - it will append your options to current options context
# override - in this and subdirs will only take this file options (unless in subdirs are also some config files)
#excludedExtensions - files with these extensions will not be listed as missing files
#excludedDirs - program will not be looking in these locations for missing files
</pre></noscript>
<script src="https://gist.github.com/3766167.js?file=vspniff_config_description"> </script>

This is it. I hope you will enjoy using this tool and it helps you avoid many bugs.

Peace.
 
