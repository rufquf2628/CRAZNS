#!/bin/bash
cat /dev/null > /var/log/syslog &&
tail -f /var/log/syslog
