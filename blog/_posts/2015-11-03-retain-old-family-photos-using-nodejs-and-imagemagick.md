--- 
layout: post
title: "Retain old family photos using Node.js and ImageMagick"
tags: ["nodejs", "javascript", "imagemagick", "bash"]
date: 2015-11-03
author: "Tomasz Subik"
permalink: /blog/retain-old-family-photos-using-nodejs-and-imagemagick
---

Last weekend I decided to push forward an idea which had wrapped around my mind for a long long time. My family (I guess as almost everyone's) has a lot of photos, notes, documents, etc. A lot of memories, packed into albums, envelopes, frames or hidden somewhere between books on the bookshelf. Pictures fade or simply lose quality over time. That's why I decided to scan them, but as there are a lot of them I wanted to automate the process as much as I can.

<!--more-->

## Manual Process

The process is simple and can be broken down into following steps:

1. Insert a few pictures into a scanner. I want to scan multiple pictures at once to make the whole process faster.
2. Scan using<code class="inline">Scan To File</code>button directly to connected computer.
3. Let the script make the rest, so go to the step 1.

## The Script

1. Watch scanner output directory.
2. If a new image, use ImageMagick to crop multiple images from it and then deskew them if needed. Move results to different watched folder for further processing.
3. Convert images to jpegs and move to output directory.
4. Preserve scan somewhere just in case.

Sounds easy, right? Ok, maybe except cropping images and deskewing part, but thanks to<code class="inline">the Google</code>I found a glut of [useful ImageMagick scripts][fred_scripts]. Those scripts are free, but only for non-commercial use, so mind your intentions. Of course, you have to have ImageMagick installed in the first place.

## Gimmie Some Code

There is<code class="inline">Node.js</code>mentioned in the title of this post, so Yes... I feel compelled to show some code ;). Here is script code.

{% highlight javascript %}
processArgs();
checkArgs();
checkDirs();
processImagesDir(imagesDir);

chokidar.watch(path.join(imagesDir, "*.pnm"), {depth: 0}).on("add", multicrop);
chokidar.watch(path.join(croppedDir, "*.pnm"), {depth: 0}).on("add", convertToJpg);

process.on("exit", exitHandler.bind(null, {cleanUp: true}));
process.on("SIGINT", exitHandler.bind(null, {exit: true}));
process.on("uncaughtException", exitHandler.bind(null, {exit: true}));
{% endhighlight %}

Default node<code class="inline">fs.watch</code>method gave me a big headache, that's why I decided to go for [chokidar lib][chokidar].

The most important part is the usage of [multicrop script][multicrop]. You can always modify parameters if you are not pleased with results.

{% highlight javascript %}
var outputFile = path.join(tempDir, path.basename(file));

exec("./multicrop -u 1 -d 50 -b white " + file + " " + outputFile, function (error) {
    if (error) {
        throw new Error("Error while multi cropping: " + error);
    } else {
        var processedFile = path.join(processedDir, path.basename(file));

        exec("mv " + file + " " + processedFile);
        exec("mv " + tempDir + "/* " + croppedDir);
    }
});
{% endhighlight %}

Conversion to<code class="inline">.jpg</code>is pretty straightforward.

{% highlight javascript %}
var outputFile = path.join(outputDir, path.basename(file, ".pnm")) + ".jpg";

exec("convert -quality 90 " + file + " " + outputFile, function (error) {
    if (error) {
        throw new Error("Error while converting to jpeg: " + error);
    } else {
        exec("rm " + file);
    }
});
{% endhighlight %}

You can find [full project on Github][repository].

## Results

I am pretty happy with results. Of course, I need to rotate pictures accordingly later.

![results](/images/blog/multicrop_pictures.jpg "Results")

## Post Production

Sometimes I need to discard a few of result pictures because of additional "subpictures" extracted from the original one. There is an option for the multi-crop script to discard images smaller than a given size. You have to be careful scanning small pictures, though.

I found [Google Photos][google_photos] pretty robust for simple post production, including applying automatic filters and deskewing if the script doesn't work perfectly.

## Things to do

Port to Windows. I have windows machine somewhere ;]. I will update this post after it is done.

## Conclusions

I find this approach pretty fast and good enough according to my needs. Maybe You Guys know a better and also FREE way? Let me know in the comments.

[fred_scripts]: http://www.fmwconcepts.com/imagemagick/
[chokidar]: https://github.com/paulmillr/chokidar
[multicrop]: http://www.fmwconcepts.com/imagemagick/multicrop/index.php
[repository]: https://github.com/tsubik/family_photos
[google_photos]: https://photos.google.com/
