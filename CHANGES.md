### version 0.10.0

* fix filedescriptor leak by terminating celluloid actors
* handle domains without A-record
* send empty json object on 404 rather than nil
* remote nicknym is on port 6425
* use user:password@ prefix in http basic auth
* require at least ruby 2.1
* Add systemd service unit file
* Restart nickserver automatically from systemd

### version 0.9.0

* isolate http adapter
* seperate EM-Server from generic server
* replace EM with celluloid based server and http client
* implement key lookup by fingerprint from hkp servers
* support for lookup from other keyservers
* use gitlab ci
* handle network errors properly
* separate logging from stdout
* support ruby version 2.3 in addition to 2.1

### version 0.8.0

duplicate of version 0.3.0 to catch up with leap platform version scheme

### version 0.3.0

* ruby version 2.1.5
* use travis CI
* bind nickserver only to localhost
* `hkp_ca_file` config option

### version 0.2.2

* move the config file location from /etc/leap/nickserver.yml to /etc/nickserver.yml
