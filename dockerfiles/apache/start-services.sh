#!/bin/bash


# Reload Apache configuration
service apache2 reload

# Start Apache in the foreground
apache2ctl -D FOREGROUND