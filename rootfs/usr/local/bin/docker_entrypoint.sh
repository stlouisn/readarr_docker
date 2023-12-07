#!/bin/bash

#=========================================================================================

# Fix user and group ownerships for '/config'
chown -R readarr:readarr /config

# Delete PID if it exists
if
    [ -e "/config/readarr.pid" ]
then
    rm -f /config/readarr.pid
fi

#=========================================================================================

# Start readarr in console mode
exec gosu readarr \
    /Readarr/Readarr -nobrowser -data=/config
