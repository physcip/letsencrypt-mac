# dehydrated support scripts for OS X Server

[dehydrated](https://github.com/lukas2511/dehydrated) (formerly [letsencrypt.sh](https://github.com/lukas2511/letsencrypt.sh)) is a nice and simple client for obtaining free SSL certificates from [Let's Encrypt](https://letsencrypt.org).
This repository contains a wrapper script which automatically pulls the host names from configured SSL websites in OS X Server, requests the appropriate certificates, and calls a hook that imports them into Keychain and sets the OS X Server to use them.

## Requirements
This script has been developed and tested on
- OS X 10.11.4 through 10.13.3
- Server.app 5.1 through 5.5

Older versions might work too, but have not been tested.

## Using
In Server.app, go to the _Websites_ section and create a new web site for each domain name you intend to use.
If you want multiple domains to point to the same web site, you can add these under _Additional Domains_.
Set the port number to 443 and choose the self-signed certificate that has been created by OS X Server.

Now execute `run.sh` from this repository with sudo rights.
