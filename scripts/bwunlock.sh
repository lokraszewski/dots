#!/usr/bin/env bash

if [[ -z "${BW_SESSION:-}" ]]; then
  export BW_SESSION=$(bw unlock --raw)
fi

