Nickserver
==================================

Nickserver is a server running the Nicknym protocol. This daemon can be run by
service providers in order to support Nicknym.

Nicknym is a protocol to map user nicknames to public keys. With Nicknym, the
user is able to think solely in terms of nickname, while still being able to
communicate with a high degree of security (confidentiality, integrity, and
authenticity). Essentially, Nicknym is a system for binding human-memorable
nicknames to a cryptographic key via automatic discovery and automatic
validation.

For more information, see https://leap.se/nicknym

About nickserver:

* Written in Ruby 2.1, licensed GPLv3
* Lightweight and scalable (high concurrency, reasonable latency)
* Uses asynchronous network IO for both server and client connections
  (via Celluloid IO)

API
==================================

You send requests to nickserver via HTTP. The API is very minimal:

    curl -X POST -d address=alice@domain.org https://nicknym.domain.org:6425

The response consists of a JSON document with fields for the selected
public key corresponding to the address.

For more details, see https://leap.se/nicknym

Requirements
==================================

* Ruby (tested with 2.1.5)
* CouchDB

Installation
==================================

Install prerequisites

    $ sudo apt-get install ruby-dev libssl-dev

Note: libssl-dev must be installed before installing the gem EventMachine,
otherwise the gem will get built without TLS support.

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

Configuration
==================================

Nickserver loads the configuration files `config/default.yml` and
`/etc/nickserver.yml`, if it exists. See `config/default.yml` for the
available options.

The default HKP host is set to https://hkps.pool.sks-keyservers.net. The CA
for this pool is available here https://sks-keyservers.net/sks-keyservers.netCA.pem

Usage
==================================

    Usage: nickserver [OPTION] COMMAND

    where COMMAND is one of:
      start         start an instance of the application
      stop          stop all instances of the application
      restart       stop all instances and restart them afterwards
      status        show status (PID) of application instances
      version       print version and exit

    where OPTION is one of:
      --verbose     log more

Running Tests
==================================

To run the test suite, run:

    rake

The tests that actually make real network calls are enabled by default. To only run local, do this:

    ONLY_LOCAL=true rake
