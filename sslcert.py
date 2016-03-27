#!/usr/bin/python

import sys
import os
import objc

framework='/Applications/Server.app/Contents/ServerRoot/System/Library/PrivateFrameworks/ServerFoundation.framework'
objc.loadBundle("ServerFoundation", globals(), framework)

config = XSWebConfig.alloc().init()
config.readAndReturnError_(None)

changes = False

for host in config.customVirtualHosts():
	if host.serverName() == sys.argv[1] and host.sslCertificateIdentifier():
		print host.serverName(), host.sslCertificateIdentifier()
		if not os.path.exists(os.path.join("/etc/certificates", sys.argv[2]) + ".cert.pem"):
			raise Exception("Certificate does not exist")
		if not host.sslCertificateIdentifier() == sys.argv[2]:
			host.setSslCertificateIdentifier_(sys.argv[2])
			changes = True

if changes:
	config.synchronizeAndReturnError_(None)
