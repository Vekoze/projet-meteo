#!/bin/sh

( : crontab -l ; echo "*/5 * * * * $HOME/project.sh") | crontab -
( crontab -l ; echo "59 23 * * * $HOME/generate_report.sh") | crontab -
