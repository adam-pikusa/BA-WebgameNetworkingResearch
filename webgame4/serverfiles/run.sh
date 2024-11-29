#!/bin/bash
for server in "b" "c" "d" 
do
    (cd servers/$server && ./webgame4_server.arm64 &>> log.txt) &
done

docker-compose up

# Executing this script will run certain servers in the background.
# HINT:
# Servers running in the background 
# can be brought to the foreground 
# with the command "fg".
