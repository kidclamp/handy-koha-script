#! /bin/bash
# To help setup koha testing docker for easy use
sudo apt update
sudo apt install locate libcarp-always-perl
sudo updatedb

cat custom.sql | sudo koha-mysql kohadev
perl /kohadevbox/koha/handy/setup.pl
