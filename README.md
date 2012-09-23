Tagfu - Cucumber Tag Manipulation
=================================

Description
-----------

Tagfu is a command line utility for manipulating tags in Cucumber feature files

With Tagfu, you can easily add, update, delete specific tags or delete all tags from Cucumber feature files.
Tagfu can operate on a specific feature file or on all the feature files within a specified folder structure.

Features
--------

- Manipulate tags for a specific feature file or all the feature files within a specified folder
- Add one or multiple tags at the feature level
- Update existing tags
- Delete specific tags
- Delete all tags 

Installation
------------

`gem install tagfu`

Synopsis
--------

Access the command line help

`tagfu --help`

Add tags to the Cucumber feature file(s)

`tagfu -p . -a wip,smoke`
`tagfu -p . -a @wip,@smoke`

Update tags in Cucumber feature file(s)

`tagfu -p story.feature -u wip,smoke`
`tagfu --path story.feature --update @wip,@smoke`

Delete tags in Cucumber feature file(s)

`tagfu --path /usr/home/jdoe/project/features --delete wip,hacky` 

Delete all tags from Cucumber feature file(s)

`tagfu --path . --delete-all`

Bugs
----

Report bugs at [the Github page](https://github.com/).


Copyright
---------

Copyright 2012 by [Avinash Padmanabhan](http://eveningsamurai.wordpress.com) under the MIT license (see the LICENSE file).
