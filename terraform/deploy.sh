#!/bin/bash

docker stop juiceshop || true
# docker pull vbolzani/juice-shop-dso:latest
docker run -d --name juiceshop -p 3000:3000 vbolzani/juice-shop-dso:latest