cd webgame4
%godot43% --headless --export-debug "Server"
%godot43% --headless --export-debug "Client"
cd ..

tar.exe -acf temp/webgame4.zip -C export_html *
tar.exe -acf temp/webgame4server.zip -C export_server *