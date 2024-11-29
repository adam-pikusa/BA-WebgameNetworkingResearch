REM the server depends on this file server to be run, so that it can fetch files

start cmd /c python -m http.server 8080 -d temp