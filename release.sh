#!/bin/sh
#
# Create release tarballs/zip for 64-bit linux, BSD and Plan9 + 64-bit ARM + raspberry pi 2/3 + Windows
#
name=algernon
version=$(grep -i version main.go | head -1 | cut -d' ' -f4 | cut -d'"' -f1)
echo 'Compiling...'
export GOARCH=amd64
echo '* Linux'
GOOS=linux go build -o $name.linux
echo '* Linux static w/ upx'
CGO_ENABLED=0 GOOS=linux go build -v -trimpath -ldflags "-s" -a -o $name.linux_static
upx $name.linux_static
echo '* Plan9'
GOOS=plan9 go build -o $name.plan9
echo '* macOS'
GOOS=darwin go build -o $name.macos
echo '* FreeBSD'
GOOS=freebsd go build -o $name.freebsd
echo '* NetBSD'
GOOS=netbsd go build -o $name.netbsd
echo '* OpenBSD'
GOOS=openbsd go build -o $name.openbsd
echo '* Windows'
GOOS=windows go build -o $name.exe
echo '* Linux ARM64'
GOOS=linux GOARCH=arm64 go build -o $name.linux_arm64
echo '* RPI 2/3'
GOOS=linux GOARCH=arm GOARM=6 go build -o $name.rpi

# Compress the Windows release
echo "Compressing $name-$version.zip"
mkdir "$name-$version"
cp $name.exe LICENSE "$name-$version/"
zip -q -r "$name-$version.zip" "$name-$version/"
rm -r "$name-$version"
rm $name.exe

# Compress the Linux releases with xz
for p in linux linux_arm64 rpi linux_static; do
  echo "Compressing $name-$version.$p.tar.xz"
  mkdir "$name-$version-$p"
  cp $name.$p LICENSE "$name-$version-$p/"
  tar Jcf "$name-$version-$p.tar.xz" "$name-$version-$p/"
  rm -r "$name-$version-$p"
  rm $name.$p
done

# Compress the other tarballs with gz
for p in macos freebsd netbsd openbsd plan9; do
  echo "Compressing $name-$version.$p.tar.gz"
  mkdir "$name-$version-$p"
  #cp $name.1 "$name-$version-$p/"
  #gzip "$name-$version-$p/$name.1"
  cp $name.$p LICENSE "$name-$version-$p/"
  tar zcf "$name-$version-$p.tar.gz" "$name-$version-$p/"
  rm -r "$name-$version-$p"
  rm $name.$p
done