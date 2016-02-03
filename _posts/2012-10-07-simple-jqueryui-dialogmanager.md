--- 
layout: post
title: "Simple jQueryUI DialogManager"
tags: ["javascript","jQuery"]
date: 2012-10-07
author: "Tomasz Subik"
permalink: /blog/simple-jqueryui-dialogmanager/
---

Recently I've been working on structuring and refactoring javascript code in a middle size application. There are many modal popups, you know popup invoking popup and so on. Many of them were just created on div elements which already exist in the html markup. I thought that it would be a better idea to create these kinds of div elements only if I want to show a dialog using them. The next thing I'd like to achieve is to use default configuration for created dialogs. Also, I want my div element destroyed after closing the dialog.

<!--more-->

Ok. Enough talking. Show me the code.

<noscript><pre>
;(function(w){
    var DialogManager = (function(){

        function DialogManager(){
            this.dialogIdx= 1;    
        };
        DialogManager.prototype.createDialog = function(options){
            var defaults = {
                modal: true,
                resizeable: false,
                autoOpen: false,
                //removing dialog after close
                close: function () {
                    $(this).remove();
                }
            };
            var id = 'dialogId' + this.dialogIdx;
            
            $box = $('#' + id);
            if (!$box.length) {
                $box = $('<div id="' + id + '"></div>').hide().appendTo('body');
                this.dialogIdx++;
            }
            $box.dialog($.extend({}, defaults, options));
            return $box;
        };

        return DialogManager;
    })();
    w.DialogManager = new DialogManager;

})(window);
</pre></noscript>
<script src="https://gist.github.com/3849685.js?file=dialogmanager.js"> </script> 

And usage.

<noscript><pre>
var dialog = DialogManager.createDialog({minWidth: 400, title: 'Set some title'});
dialog.html('Here is the content');
dialog.dialog('open');
</pre></noscript>
<script src="https://gist.github.com/3849685.js?file=usage.js"> </script> 

