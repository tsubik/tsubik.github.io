---
layout: post
title: "Make your Ember.js web app more progressive - part 3: Offline data"
tags: ["ember", "progressive", "mobile-friendly", "offline-mode", "offline-data"]
date: 2016-07-14
author: "Tomasz Subik"
permalink: /blog/make-your-emberjs-web-app-more-progressive-part-3-offline-data
image: splittypie-data-sync.png
---

There are times when you have a limited access to the network, whether you are on a trip around the
world not willing to spend lavishly on roaming services, or on a train with internet connection
breaking all the time. This is the third part of the series how to make your application accessible
in those moments. The previous part was about caching application assets, so you don't need a network
access to run an application consecutive time. Today, another important aspect, so without further ado,
please enjoy, guide how to keep your data offline.

<!--more-->

Firstly, I want to quickly toss a few tips and approaches that I found on the internet in
terms of offline data. Every application is different hence there is no single solution for this problem.

## Read-only data

I think this scenario is fairly easy. All you need to do is to cache your data and come up with some
invalidation mechanism. There is [a clone of hacker news][react-hn], capable of working without
the internet connection and [showed recently by Addy Osmani on Google IO conference][addy-osmani-talk].
They are using firebase so it's not the simplest case as you have to deal with real-time
updates as well. Although, in a simpler scenario if you have a REST API you could just cache
your requests as any other assets using service worker as I described in the previous
part of this series. For example using [sw-toolbox][sw-toolbox].

{% highlight javascript %}

// Match URLs that begin with https://api.example.com
toolbox.router.get(/^https://api.example.com\//, apiHandler);

{% endhighlight %}

## Read-write data

This scenario is a way complicated. You have to store new data locally then merge it and
resolve conflicts when going online. Also, this is my scenario, in plus, I have to deal
with real-time updates from Firebase. I've done some research about helpful libraries and solutions,
so I want to share this with you. However, I eventually come up with a custom solution
which is inspired by what I found.

### General ways to sync data

I don't know exactly how many ways of data syncing are there, but lets look at two of them.

1. First way is just saving data offline and then merging the whole dataset or some part of it with the
online database. This approach needs to use some indicator like `modifiedAt` date for the conflict resolution.
Mind that you cannot just destroy a record, remove it completely, but instead set a `deleted` flag.
2. Another one doesn't need any `modifiedAt` date indicator or `deleted` flag. You store to the
offline store as well but also preserve a queue of operations to be performed on the online store.
If you are online you can execute them immediately, if not just save them to the local store.

Personally, I chose the second one, but before I present my solution lets go through some existing libraries out there.

### PouchDB-CouchDB

This looks like the quickest way to create an offline app. On the client side you store data
in local [pouchDB][pouchDB] instance and then sync changes with CouchDB server using internal replication
and [conflict resolution][couchDB-conflict] algorithm. There is a great Ember.js open source project out
there using this method called [HospitalRun][hospitalrun] and
[some tutorial about creating offline web app in Ember.js][tutorial-couchDB].

### Orbit.js

There is a library called [Orbit.js][orbit.js] and [ember-orbit][ember-orbit] wrapper. Frankly,
I haven't tried it in a real application, but it looks very promising. Unfortunately,
it is not documented well. Here is a short description from their readme.

> Orbit is a library for coordinating access to data sources and keeping their contents synchronized.
> Orbit provides a foundation for building advanced features in client-side applications such
> as offline operation, maintenance and synchronization of local caches, undo / redo stacks and ad hoc editing contexts.

### [Ember-sync][ember-sync], [ember-fryctoria][ember-fryctoria], [ember-data-offline][ember-data-offline]

Unfortunately, those libraries are not compatible with the newest Ember Data version.
But you can tease out some good ideas from them and I recommend to check them out.
All of them are using deferred jobs which have to be run on online store approach.
In my application, I'm using some not standard ways to store data like embedded records
and adapters like emberfire. My schema is not very complicated, just a few models,
that's why I thought the quickest way would be to implement synchronization from scratch.

### Firebase offline support

As I'm using firebase the most convenient way would be using firebase offline support. However,
currently, firebase offline support for Javascript API is limited to the session.
It stores cache in memory storage and it goes away when the user ends the current session.
Although, I think it's only a matter of time before they come with full offline support in
Javascript API (actually, those capabilities are available for iOS and Android APIs).

### SplittyPie offline data

For those who don't know what is [SplittyPie][splittypie], just a quick retrospection.
[SplittyPie][splittypie] is a simple application to keep track of your, for example, trip expenses.
I think this app would be a perfect example of offline-first application, as during trips
you could encounter network issues many times. That's why I'm making the whole series about it.

As I already wrote, my solution is based on deferred commands approach.
I have two stores, the main one is offline store hooked up with IndexedDB by [localforage adapter][localforage-adapter].
The second one is an online store with [emberfire adapter][emberfire] and this one is solely used for data synchronization.

here is how it looks like from a broad perspective.

![splittypie-data-sync](/images/blog/splittypie-data-sync.png "SplittyPie Data Sync Diagram")

Ember data stores have `serializerFor` and `adapterFor` methods overridden because I store adapters and
serializers for online/offline store in different directories.

{% highlight javascript %}

import DS from "ember-data";

const { Store } = DS;

export default Store.extend({
    adapter: "offline/application",

    serializerFor(modelName) {
        return this._super(`offline/${modelName}`);
    },

    adapterFor(modelName) {
        return this._super(`offline/${modelName}`);
    },
});

{% endhighlight %}

The second store is similar just changing a directory for adapters and serializers to `online`.

When storing offline I wanted to have similar to firebase's id generator.
I came across [this script][firebase-offline-id-generator] and just tweaked it to meet my ESLint rules.
I had to update offline adapter to use this generator.

{% highlight javascript %}

import LFAdapter from "ember-localforage-adapter/adapters/localforage";
import generateUniqueId from "splittypie/utils/generate-unique-id";

export default LFAdapter.extend({
    generateIdForRecord: generateUniqueId,
});

{% endhighlight %}

I also added a new layer which I use to CRUD operations in my application and I called it `repositories`.
Each model has its own repository which is responsible not only for persisting records to a store
but also enqueuing jobs to perform on the online store.

Here is an example of `save` method from such repository.

{% highlight javascript %}

save(event) {
    const operation = event.get("isNew") ? "createEvent" : "updateEvent";

    return event.save().then((record) => {
        const payload = record.serialize({ includeId: true });

        delete payload.transactions;

        this.get("syncQueue").enqueue(operation, payload);

        return record;
    });
}

{% endhighlight %}

Ok. so when to synchronize. It's totally up to you, but it's better not to be out of sync for too long.
As I'm using firebase on my server side then on any real-time value change I'm synchronizing
that change into my offline store. Another time is when the user was offline and goes online.
I'm using navigator event to obtain that. Here is a quick `connection` service for observing that.

{% highlight javascript %}

import Ember from "ember";

const {
    computed: { equal },
    Service,
} = Ember;

export default Service.extend({
    state: "offline",
    isOnline: equal("state", "online"),
    isOffline: equal("state", "offline"),

    init() {
        this._super(...arguments);
        this.set("state", window.navigator.onLine ? "online" : "offline");
        this._onOfflineHandler = () => {
            this.set("state", "offline");
        };
        this._onOnlineHandler = () => {
            this.set("state", "online");
        };

        window.addEventListener("offline", this._onOfflineHandler);
        window.addEventListener("online", this._onOnlineHandler);
    },

    destroy() {
        window.removeEventListener("offline", this._onOfflineHandler);
        window.removeEventListener("online", this._onOnlineHandler);
        this._super(...arguments);
    },
});

{% endhighlight %}

The responsibility for synchronization lays on another service called `syncer` and here is the core method.

{% highlight javascript %}

syncOnline() {
    debug("Starting full sync");
    this.set("isSyncing", true);
    return this._reloadOnlineStore()
        .then(this._flushSyncQueue.bind(this))
        .then(this._updateOfflineStore.bind(this))
        .finally(() => {
            debug("Full sync has been completed");
            this.set("isSyncing", false);
            this.trigger("syncCompleted");
        });
},

{% endhighlight %}

### Conflict resolution

In my case, the offline version always wins the conflict as I'm loading online store at first place and then
executing stored commands in strict order on this store. I realize there might be some edge cases
showing up in the future.

## Conclusions

That concludes this blog post. To see more related code to this topic check out
[SplittyPie github repository][splittypie-repository] (currently [offline-support branch][splittypie-offline-support]).
Also, if you are more interested in offline first concept, [here is the real mine of knowledge][offline-first].
I think the next post will be about [Web Push Notifications][push-api], not sure yet.
Stay sync!

[react-hn]: https://github.com/insin/react-hn
[addy-osmani-talk]: https://www.youtube.com/watch?v=srdKq0DckXQ
[sw-toolbox]:https://github.com/GoogleChrome/sw-toolbox
[couchDB-conflict]: http://guide.couchdb.org/draft/conflicts.html
[hospitalrun]: https://github.com/HospitalRun/hospitalrun-frontend
[tutorial-couchDB]: https://teamgaslight.com/blog/offline-web-applications-with-couchdb-pouchdb-and-ember-cli
[pouchDB]: https://pouchdb.com
[orbit.js]: https://github.com/orbitjs/orbit.js
[ember-orbit]: https://github.com/orbitjs/ember-orbit
[ember-sync]: https://github.com/kurko/ember-sync
[ember-fryctoria]: https://github.com/poetic/ember-fryctoria
[ember-data-offline]: https://github.com/api-hogs/ember-data-offline
[splittypie]: https://splittypie.com
[firebase-offline-id-generator]: https://gist.github.com/mikelehen/3596a30bd69384624c11
[localforage-adapter]: https://github.com/genkgo/ember-localforage-adapter
[emberfire]: https://github.com/firebase/emberfire
[splittypie-repository]: https://github.com/cowbell/splittypie
[splittypie-offline-support]: https://github.com/cowbell/splittypie/tree/offline-support
[offline-first]:https://github.com/pazguille/offline-first
[push-api]: https://developer.mozilla.org/en-US/docs/Web/API/Push_API
