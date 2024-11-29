rm -r static/*

curl http://192.168.0.72:8080/webgame4server.zip -o server/webgame4server.zip
curl http://192.168.0.72:8080/webgame4.zip -o static/webgame4.zip

cd server 
    unzip -o webgame4server.zip
    rm -f webgame4server.zip
    chmod 777 webgame4_server.arm64
cd ..

for server in "b" "c" "d" 
do
    ln -fs ../../server/libwebrtc_native.linux.template_debug.arm64.so servers/$server/libwebrtc_native.linux.template_debug.arm64.so
    ln -fs ../../server/webgame4_server.arm64 servers/$server/webgame4_server.arm64
done

cd static 
    unzip -o webgame4.zip
    rm -f webgame4.zip

    echo "compressing files..."
    gzip -9kf *

cd ..
