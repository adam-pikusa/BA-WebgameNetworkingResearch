# portability

Be warned!
This project was not designed to be run anywhere else than on my home server.
Many paths and local IP addresses have to be changed for it to work somewhere else.

# scripts

Scripts are meant to be executed from the directory they reside in.

The scripts depend on the following environment variables:
    %godot43% -> should resolve to godot version [Godot_v4.3-stable_win64.exe]
    %godot42% -> should resolve to godot version [Godot_v4.2.2-stable_win64.exe]

Before build.sh can be run on the server, 
the files have to be hosted using the host_files.bat script.