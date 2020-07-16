#!/bin/bash

kubectl port-forward -n logging svc/kibana-kibana 5601:5601 &
