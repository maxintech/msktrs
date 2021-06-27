#!/bin/bash
set -e

export APP_ENV="${APP_ENV:-default}"

ruby collect.rb
rackup --host 0.0.0.0 msktrs.ru 