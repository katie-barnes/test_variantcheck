FROM ubuntu:20.04

RUN apt-get update && \
    apt-get install -y \
    python3 \
    bcftools && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /variant_checker