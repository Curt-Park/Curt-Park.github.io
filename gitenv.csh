#!/bin/csh -f

RUBY_VERSION="2.3.1"

source ~/.rvm/scripts/rvm
type rvm | head -n 1
rvm use --default $RUBY_VERSION
bundle install
