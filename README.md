Nickserver
==================================

Nickserver is a server running the Nicknym protocol. This daemon can be run by service providers in order to support Nicknym.

Nicknym is a protocol to map user nicknames to public keys. With Nicknym, the user is able to think solely in terms of nickname, while still being able to communicate with a high degree of security (confidentiality, integrity, and authenticity). Essentially, Nicknym is a system for binding human-memorable nicknames to a cryptographic key via automatic discovery and automatic validation.

For more information, see https://leap.se/nicknym

About nickserver:

* Written in Ruby 1.9, licensed GPLv3
* Lightweight and scalable (high concurrency, reasonable latency)
* Uses asynchronous network IO for both server and client connections (via EventMachine)

API
==================================

You query the nickserver via HTTP. The API is very minimal:

    curl -X POST -d address=alice@domain.org https://nicknym.domain.org:6425

The response consists of a signed JSON document with fields for the available public keys corresponding to the address.

For more details, see https://leap.se/nicknym

Requirements
==================================

Ruby 1.9
CouchDB

Installation
==================================

You have three fine options for installing nickserver:

Install from source:

    $ git clone git://leap.se/nickserver
    $ cd nickserver
    $ rake build
    $ rake install

Install for development:

    $ git clone git://leap.se/nickserver
    $ cd nickserver
    $ bundle
    $ rake test

Usage
==================================

    Usage: nickserver <command> <options> -- <application options>

    * where <command> is one of:
      start         start an instance of the application
      stop          stop all instances of the application
      restart       stop all instances and restart them afterwards
      reload        send a SIGHUP to all instances of the application
      run           start the application and stay on top
      zap           set the application to a stopped state
      status        show status (PID) of application instances

    * and where <options> may contain several of the following:

        -t, --ontop                      Stay on top (does not daemonize)
        -f, --force                      Force operation
        -n, --no_wait                    Do not wait for processes to stop

    Common options:
        -h, --help                       Show this message
            --version                    Show version
