#!/bin/sh

( : crontab -l ; echo "*/5 * * * * ./project.sh") | crontab -
( crontab -l ; echo "59 23 * * * ./generate_report.sh") | crontab -
