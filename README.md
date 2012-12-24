Nickserver
==================================

Nickserver is the opposite of a key server. A key server allows you to lookup
keys, and the UIDs associated with a particular key. A nickserver allows you
to query a particular 'nick' (e.g. username@example.org) and get back relevant
public key information for that nick.

Nickserver has the following properties:

* Written in Ruby, licensed GPLv3
* Lightweight and scalable
* Uses asynchronous network IO for both server and client connections (via EventMachine)
* Attempts to reply to queries using four different methods:
  * Cached key in CouchDB (coming soon)
  * Webfinger (coming soon)
  * DNS (maybe?)
  * HKP keyserver pool (https://hkps.pool.sks-keyservers.net)

Why Nickserver?
----------------------------------

Why bother writing Nickserver instead of just using the existing HKP keyservers?

* Keyservers are fundamentally different: Nickserver is a registry of 1:1
  mapping from nick (uid) to public key. Keyservers are directories of public
  keys, which happen to have some uid information in the subkeys, but there is
  no way to query for an exact uid.

* Support clients: the goal is to provide clients with a cloud-based method of
  rapidly and easily converting nicks to keys. Client code can stay simple by
  pushing more of the work to the server.

* Enhancements over keyservers: the goal with Nickserver is to support future
  enhancements like webfinger, DNS key lookup, mail-back verification, network
  perspective, and fast distribution of short lived keys.

* Scalable: the goal is for a service that can handle many simultaneous
  requests very quickly with low memory consumption.

API
==================================

You query the nickserver via HTTP. The API is very minimal at the moment:

    curl -X GET hostname:6425/key/<uid>

Returns the OpenPGP public key for uid.

Installation
==================================

You have three fine options for installing nickserver:

Install the gem:

    $ gem install nickserver

Install from source:

    $ git clone git://leap.se/nickserver
    $ cd nickserver
    $ rake build
    $ rake install

Install for development:

    $ git clone git://leap.se/nickserver
    $ cd nickserver
    $ bundle

Usage
==================================

None yet, just a bunch of unit tests.

    rake test