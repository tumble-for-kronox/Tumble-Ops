#!/bin/bash

cd ../backend
helm template tumble-backend . --values=values.yaml -n development > tumble-backend.yml && kubectl apply -f tumble-backend.yml