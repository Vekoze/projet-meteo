#!/bin/sh

# ': crontal -l' gets all cronjobs but doesn't print 'no crontab for <user>' if empty
( : crontab -l ; echo "*/5 * * * * $HOME/project.sh") | crontab -
( crontab -l ; echo "0 * * * * $HOME/generate_pdf.sh") | crontab -
