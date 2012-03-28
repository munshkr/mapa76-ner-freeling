Mapa76 NER module with FreeLing
===============================

A temporary repo for testing [FreeLing](http://nlp.lsi.upc.edu/freeling/) NER
module with [Mapa76](https://github.com/mapa76/alegato) data.


FreeLing
--------

### Download ###

This has been tested on *FreeLing 3.0a1* only. Because this is an alpha
release, there are no binary packages available. You can download the source
[here](http://devel.cpl.upc.edu/freeling/downloads/16) and compile it.

### Compile and Install ###

For compiling the source, you need the `libboost` and `libicu` libraries. On
Debian / Ubuntu machines, you can run:

    # apt-get install libboost-dev libboost-filesystem libboost-program-options libboost-regex libicu-dev

Then, just execute `./configure`, `make` and `make install` as usual.

### Disable retokenization ###

You must disable retokenization in the `tagger` and `dictionary` modules in the
spanish configuration file. Edit `/usr/local/share/freeling/es.cfg` and add the
following entries:

    RetokContractions=no
    TaggerRetokenize=no


Usage
-----

Install all gem dependencies with Bundler:

    $ bundle install 

Then, run the `analyze.rb` script to start Sinatra.

    $ bundle exec ruby analyze.rb

