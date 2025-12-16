#!/usr/bin/env bash
cd "$(dirname "$0")"

#Build Zip

mkdir -p ./build
zip -r ./build/BrainEvilDarkWorld.lovr ./ -x "./lovr/**" -x "./build/**" -x "./.git/**" -x "*.DS_Store" -x "./.vscode/**"

#Make Windows exe

cp -R ./lovr/lovr/ ./build/BrainEvilDarkWorld/
cat ./build/BrainEvilDarkWorld/lovr.exe ./build/BrainEvilDarkWorld.lovr > ./build/BrainEvilDarkWorld/BrainEvilDarkWorld.exe
rm ./build/BrainEvilDarkWorld/lovr.exe

#Make Windows Zip

cd ./build/
zip -r ./BrainEvilDarkWorld_win64.zip ./BrainEvilDarkWorld/
cd ../

#Clean

rm -r ./build/BrainEvilDarkWorld/
