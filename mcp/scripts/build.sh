#!/bin/bash
mkdir -p bin
go build -o bin/rad-calc main.go
echo "Compiled to bin/rad-calc"
