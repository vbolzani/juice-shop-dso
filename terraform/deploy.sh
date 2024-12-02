#!/bin/bash

docker stop juiceshop || true
docker rm juiceshop || true
docker pull vbolzanifg/juice-shop-dso:latest
docker run -d --name juiceshop -p 3000:3000 vbolzanifg/juice-shop-dso:latest