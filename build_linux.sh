#!/usr/bin/env bash
cd "$(dirname "$0")"

#Build Zip

mkdir -p ./build
zip -r ./build/BrainEvilDarkWorld.lovr ./ -x "./lovr/**" -x "./build/**" -x "./.git/**" -x "*.DS_Store" -x "./.vscode/**"

#Make Linux exe

7zz x ./lovr/lovr-x86_64.AppImage -o./build/BrainEvilDarkWorld/
cat ./build/BrainEvilDarkWorld/lovr ./build/BrainEvilDarkWorld.lovr > ./build/BrainEvilDarkWorld/BrainEvilDarkWorld
chmod +x ./build/BrainEvilDarkWorld/BrainEvilDarkWorld
rm ./build/BrainEvilDarkWorld/lovr

#Clean inside Linux folder

rm ./build/BrainEvilDarkWorld/.DirIcon
rm ./build/BrainEvilDarkWorld/AppRun
rm ./build/BrainEvilDarkWorld/lovr.desktop
rm ./build/BrainEvilDarkWorld/logo.svg

#Make Linux Zip

cd ./build/
zip -r ./BrainEvilDarkWorld_linux64.zip ./BrainEvilDarkWorld/
cd ../

#Clean

rm -r ./build/BrainEvilDarkWorld/
