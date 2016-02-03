--- 
layout: post
title: "Sass with ASP.NET MVC 4 - Twitter Bootstrap example"
tags: ["twitter","aspnet","sass","mvc"]
date: 2013-01-05
author: "Tomasz Subik"
permalink: /blog/sass-with-aspnet-mvc4-twitter-bootstrap-example/
---

Many times if I look at css stylesheets of middle and big systems it just makes me cry. Total chaos, code repetition, basically too much css. That's why css preprocessors were invented. In the .NET world the most popular right now is Less. However, for a long time there is another player on the market - [Sass][Sass]. <!--more-->And that is what this post will be about - Sass along with asp.net (no matter mvc or not). If anyone doesn't know what Sass is, [check it out][Sass]. In a nutshell it is CSS preprocessor giving you much more power to create your stylesheets (nesting, mixing, variables, etc.). Blablabla... anyway in many comparisons to less, sass is the winner, but you will choose whichever you like more.
There are some posts over the Internet describing how to use Sass with asp.net, but I want to show you how I'm using it and what I am avoiding.

Pre-requirements
----------------

Simple list what do we need to start playing around Sass:

- Sass preprocessor engine
- VS syntax highlight
- something for debugging in the browser

What I am using:

- [Compass][Compass] which using Sass as a preprocessor. You need to [install ruby][Ruby_For_Windows] envoirement and then simple using your favorite console shell
<code>gem install compass</code>
- For syntax highlighting I am using [Web Essentials][Web_Essentials] - I highly recommend this extension. Sass support is a new feature there and soon will be much better.
- For development, debugging - Chrome development tools (for firefox users - [FireSass][FireSass])

Ok. So what I am avoiding:

- Mindscape Web Workbench. Why??
	- It's too heavy
	- "Go Pro" everywhere. I'm sick of it. Want to comment a line in your .scss file using VS's shortcut - "commenting is only in pro version" - WTF? Are you kidding me?
	- It using compass so.. do not rely on some commercial tools, when it is soo simple to use what they are using. 
- That's it

I recommend installing stuff I am using, but if you do not want install ruby and compass manually and you are "console hater" you can start with Web Workbench (it is using compass so ruby will be installed anyway).

Let's rock - basic app
----------------

You have everything set up, so let's play.
We don't want to build solution from scratch that's why we will use twitter bootstrap nuget package.

First steps.

1. Create new empty MVC 4 project.
2. Install packages.

<noscript><pre>
	PM> Install-Package twitter.bootstrap.mvc4
	PM> Install-Package twitter.bootstrap.mvc4.sample
</pre></noscript>
<script src="https://gist.github.com/4457378.js?file=install_packages"> </script> 

That's it. Fire up application and see what we got so far.

![ASP.NET MVC 4 with Twitter Bootstrap and Sass](/images/blog/twitter_sass1.png "ASP.NET MVC 4 with Twitter Bootstrap and Sass")

Now our application is using standard css stylesheets. Our goal is to replace them with a Sass files.

Sass goodness
---------

I found out a nice [port from Less to Sass bootstrap][sass_twitter_bootstrap]. Nice job guys! Sure we gonna use it.

If you have git, simple clone the repo, if you don't... [install git][Git_For_Windows] :]. Fine, if you don't, just download zipped repo.

Next steps.

1. Delete all css files in Content folder.
2. Create Content\Sass\Twitter directory and copy there all files from lib directory of cloned sass twitter port.
3. Initialize compass project. Open console in root folder of web application.
<code>
	compass init
</code>
That will set up default compass project configuration. We need to change it a little bit.
So now:

1. Delete sass and stylesheet folder created in root path.
2. Edit config.rb file
	<noscript><pre>
		# Set this to the root of your project when deployed:
		http_path = "/"
		css_dir = "Content"
		sass_dir = "Content/sass"
		images_dir = "Content/images"
		javascripts_dir = "javascripts"
	</pre></noscript>
	<script src="https://gist.github.com/4457378.js?file=config.rb"> </script> 

3. Add application.scss file to Content/sass directory
	<noscript><pre>
		@import "compass/reset";
		@import "twitter/bootstrap";
		@import "twitter/responsive";
	</pre></noscript>
	<script src="https://gist.github.com/4457378.js?file=application_v1.scss"> </script> 

So we are using one of compass built-in stylesheet (reset), main twitter bootstrap and reponsive stylesheet.

Let's compile ours stylesheets
<code>compass compile</code>
Now in Content directory we have all needed stylesheets.

Update application layouts to use application.css from Content directory.

delete followings
<noscript><pre>
<![CDATA[
	<link href="@Styles.Url("~/content/css")" rel="stylesheet"/>
	<link href="@Styles.Url("~/Content/css-responsive")" rel="stylesheet" type="text/css" />
]]>
</pre></noscript>
<script src="https://gist.github.com/4457378.js?file=layout_1.html"> </script> 


add only application.css
<noscript><pre>
<![CDATA[
	<link href="@Styles.Url("~/Content/application.css")" rel="stylesheet" type="text/css" />
]]>
</pre></noscript>
<script src="https://gist.github.com/4457378.js?file=layout_2.html"> </script> 

Run application to check out if everything is working as it should.

Playground
------------------

Before you start doing anything using Sass I recommend get familiar with its features - [Sass tutorial][sass_tutorial]. After that we can play around.

I changed "sing-up" page.

Move inline style from \_BootstrapLayout.empty.cshtml layout into application.scss

<noscript><pre>
body {
	padding-top: 40px;
	padding-bottom: 40px;
	background-color: #f5f5f5;
}
.form-signin {
	max-width: 300px;
	padding: 19px 29px 29px;
	margin: 0 auto 20px;
	background-color: #fff;
	border: 1px solid #e5e5e5;
	-webkit-border-radius: 5px;
	   -moz-border-radius: 5px;
	        border-radius: 5px;
	-webkit-box-shadow: 0 1px 2px rgba(0,0,0,.05);
	   -moz-box-shadow: 0 1px 2px rgba(0,0,0,.05);
	        box-shadow: 0 1px 2px rgba(0,0,0,.05);
}
.form-signin .form-signin-heading,
.form-signin .checkbox {
	margin-bottom: 10px;
}
.form-signin input[type="text"],
.form-signin input[type="password"] {
	font-size: 16px;
	height: auto;
	margin-bottom: 15px;
	padding: 7px 9px;
}
</pre></noscript>
<script src="https://gist.github.com/4457378.js?file=application.css"> </script> 

Now change it a little bit using sass features (I'm using variables from twitter bootstrap here) and import twitter bootstrap and compass default reset stylesheet.
<noscript><pre>
@import "compass/reset";
@import "twitter/bootstrap";
body
{
    padding-top: 40px;
    padding-bottom: 40px;
    background-color: $white;
}
.form-signin
{
    max-width: 300px;
    padding: 19px 29px 29px;
    margin: 0 auto 20px;
    background-color: $formActionsBackground;
    border: 1px solid $inputBorder;
    @include border-radius($baseBorderRadius);
    @include box-shadow(inset 0 1px 2px rgba(0,0,0,.05));
    .form-signin-heading, .checkbox
    {
        margin-bottom: 10px;
    }
    input[type="text"], input[type="password"]
    {
        font-size: 16px;
        height: auto;
        margin-bottom: 15px;
        padding: 7px 9px;
    }
}   
@import "twitter/responsive";
</pre></noscript>
<script src="https://gist.github.com/4457378.js?file=application_v2.scss"> </script> 

It will change a little design, but... so what. In this little example I show you usage of variables, mixins and nestings. 

I don't want to create sass tutorial here, just do what you want, experiment.

Debugging sass
-----------------

There is something that everyone hates in every code generating languages like coffeescript, typescript, less and sass - troubles with debugging. Browser shows you some errors in specific line of code which have nothing to do with your original development files.

You can find some solutions to this problem.

For chrome browser (24+) there is for now an experiment sass support feature. Obtain how to use it - [http://benfrain.com/add-sass-compass-debug-info-for-chrome-web-developer-tools/][Chrome_Sass]

For firefox you have [FireSass extension][FireSass]. You will find instructions on how to use it on [http://nex-3.com/posts/92-firesass-bridges-the-gap-between-sass-and-firebug][Firefox_Sass]

This solutions requires adding two config lines to config.rb file
<noscript><pre>
	sass_options = {:debug_info => true}
	output_style = :expanded
</pre></noscript>
<script src="https://gist.github.com/4457378.js?file=config_v2.rb"> </script> 

Sass compiling improvements
-----------------

At the end some tips how to improve stylesheet generation.

Just type in the console

<code>compass watch</code>

And now everytime if you change something in your sass files, the compass will notice this and your stylesheets will be recompiled.

You can also execute <code class="inline">compass compile</code> after your project compilation adding this to the end of the project file
<noscript><pre>
<Target Name="AfterCompile" Condition=" '$(Configuration)' == 'Release' ">
    <Exec Command="compass compile" />
    <ItemGroup>
        <Content Include="Styles\*.css" />
    </ItemGroup>
</Target>
</pre></noscript>
<script src="https://gist.github.com/4457378.js?file=project.xml"> </script> 

Full solution
-----------------

You can find end solution on [github][Full_solution]. That's it, for futher reading I recommend [The Sass Way][The_Sass_Way]

[Sass]: http://sass-lang.com
[Compass]: http://compass-style.org
[Web_Essentials]: http://visualstudiogallery.msdn.microsoft.com/07d54d12-7133-4e15-becb-6f451ea3bea6
[FireSass]: https://addons.mozilla.org/pl/firefox/addon/firesass-for-firebug
[Ruby_For_Windows]: http://rubyinstaller.org/
[sass_twitter_bootstrap]: https://github.com/jlong/sass-twitter-bootstrap
[Git_For_Windows]: http://msysgit.github.com
[sass_tutorial]: http://sass-lang.com/tutorial.html
[Debug_info_chrome]: http://benfrain.com/add-sass-compass-debug-info-for-chrome-web-developer-tools
[Full_solution]: https://github.com/tsubik/aspnet_twitter_sass
[Firefox_Sass]: http://nex-3.com/posts/92-firesass-bridges-the-gap-between-sass-and-firebug
[Chrome_Sass]: http://benfrain.com/add-sass-compass-debug-info-for-chrome-web-developer-tools
[The_Sass_Way]: http://thesassway.com