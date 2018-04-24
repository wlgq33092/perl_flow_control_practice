#! /bin/sh

echo "this is a test, with arg $1, name $2"
sleep $1
path="../test/$2"
echo "1" > $path
