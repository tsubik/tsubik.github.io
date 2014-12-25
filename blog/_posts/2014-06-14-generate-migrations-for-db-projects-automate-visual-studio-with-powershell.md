--- 
layout: post
title: "Generate migrations for DB projects - automate Visual Studio with powershell"
tags: ["Powershell Cmdlet",".NET","Visual Studio","Database"]
date: 2014-06-14
author: "Tomasz Subik"
permalink: /blog/generate-migrations-for-db-projects-automate-visual-studio-with-powershell/
---

Recently I was working on providing database migrations solution for a quite large .NET learning management system. It was a shame that there was nothing to automate process of updating production databases and everything must have been done manually. We are using custom ORM solution, VS Database project to keep database schemas in source control and factories to populate databases with static and some test data. Schemas are large - contain hundreds of tables, views and thousand of stored procedures which is why when I was looking for database migrations solution a good maintaining of updating changes in procedures was a must. 

<!--more-->

Solution
--------

I managed to find only one which satisfied these needs - [roundhouse](https://github.com/chucknorris/roundhouse). Unfortunately, there were some problems in applying roundhouse to this project but maybe a detailed migration process is a topic for another post. There were, in short, some changes to be made in rh library and I didn't like its way of creating database which was "get initial schema and run all migrations". I preferred to create a "fresh" database directly from schema which would support database project and that's why I am using both roundhouse (to apply migrations and changes in views/stored procs/functions - and in general keeping database in specific version) and database project (to keep schema in source control and creating database from schema). 

Process of development requires creating differential scripts besides applying changes in database project. Diff scripts do not need to store changes in stored procedures/views/functions because roundhouse ensures that. So, a developer can now update database project directly using designers  in visual studio and save generated diff update script as a new migration. To apply changes to databases he needs to use roundhouse. But manually creating a script with specific name every few minutes is boring and it is therefore first on the list to automate this process.

What we need is to perform a few simple steps.

1.  Change schema in database project.
2.  Compare database project with database on the developer server. Using schema compare tool we can ignore specific object types e.g. stored procedures/views/functions and save comparison as comparison profile in scmp file.
3.  Generate script with changes and save it to migration folder with specific name eg. with format like YYYYMMddhhmmss_MIGRATION_NAME.sql  

Unfortunately, there is no way, or I cannot find one, to compare database project with database using a command line tool where I could provide a list of types of objects to ignore. That's why I create powershell script running commands inside Visual Studio.

<script src="https://gist.github.com/tsubik/34d2d80e90a924fc718c.js"></script>

To create migration you must have solution with database project opened.
Running script will add migration file to your solution (do not mess around in editor while script is running).

![Migration file added to solution](/images/blog/migration_file.jpg)

Examples:

<code>
PM> .\AddMigration.ps1 –n MigrationName 
</code>

For other database project in solution
 
<code>
PM> .\AddMigration.ps1 –n MigrationName –p NotDefaultDatabaseProject 
</code>

To generate only empty file for migration

<code>
PM> .\AddMigrations.ps1 –n MigrationName –of
</code>

This solution is not ideal mainly because is too slow, but it is working and is better than manually doing this.
