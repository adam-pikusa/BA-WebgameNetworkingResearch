API=http://172.19.0.10:7890/api

curl -X POST ${API}/debug/reset

printf "server testing\n"

curl -X GET ${API}/servers
curl -X POST ${API}/servers/main
curl -X GET ${API}/servers
curl -X POST ${API}/servers/secondary
curl -X GET ${API}/servers

printf "\n\nclient testing\n"

curl -X GET ${API}/clients/main
curl -X POST ${API}/clients/main/p1/1
curl -X GET ${API}/clients/main
curl -X POST ${API}/clients/main/p2/2
curl -X GET ${API}/clients/main
curl -X GET ${API}/clients/main/p1

printf "\n\njoin request testing\n"

curl -X GET ${API}/join-requests/main
curl -X POST ${API}/join-requests/main/p3 \
    -d '{"join":"request","connection":"data"}' \
    -H 'Content-Type: application/json' 
curl -X POST ${API}/join-requests/main/p3 \
    -d '{"join":"request","connection":"data"}' \
    -H 'Content-Type: application/json'
curl -X POST ${API}/join-requests/main/p4 \
    -d '{"join":"request","connection":"data"}' \
    -H 'Content-Type: application/json' 
curl -X GET ${API}/join-requests/main

printf "\n\njoin responses testing\n"

curl -X GET ${API}/join-responses/main/p1
curl -X POST ${API}/join-responses/main/p1 \
    -d '{"join":"response","connection":"data"}' \
    -H 'Content-Type: application/json'
curl -X GET ${API}/join-responses/main/p1

printf "\n\nmessages testing\n"

curl -X GET ${API}/messages/main/p1/server
curl -X GET ${API}/messages/main/p1/client

curl -X POST ${API}/messages/main/p1/server/srvmsg1 -d 'srv msg content 1'
printf "server posted srvmsg1\n"
curl -X GET ${API}/messages/main/p1/server
curl -X GET ${API}/messages/main/p1/client

curl -X POST ${API}/messages/main/p1/client/cltmsg1 -d 'clt msg content 1'
printf "client posted cltmsg1\n"
curl -X GET ${API}/messages/main/p1/server
curl -X GET ${API}/messages/main/p1/client

curl -X POST ${API}/messages/main/p1/client/cltnewmsg1 -d 'clt msg content 1'
curl -X POST ${API}/messages/main/p1/client/cltnewmsg2 -d 'clt msg content 2'
printf "client posted cltnewmsg1 & cltnewmsg2\n"
curl -X GET ${API}/messages/main/p1/server
curl -X GET ${API}/messages/main/p1/client

printf "\n\nstate debug testing\n"

curl -X GET ${API}/debug/state/main
curl -X POST ${API}/debug/state/main -d '{"client":"p1","tick":100,"state":"asdasdasda"}'
printf "p1 added state at tick 100\n"
curl -X GET ${API}/debug/state/main
curl -X POST ${API}/debug/state/main -d '{"client":"p2","tick":100,"state":"asdasdasda"}'
curl -X POST ${API}/debug/state/main -d '{"client":"p3","tick":100,"state":"asdasdasdb"}'
printf "p2 and p3 added states at tick 100\n"
curl -X GET ${API}/debug/state/main
