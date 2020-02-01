#!/bin/bash

./fmt.sh && \
git add -A && \
git commit -m "default-commit-message" && \
git push origin master
