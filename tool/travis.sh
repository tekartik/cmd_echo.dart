#!/bin/bash

# Fast fail the script on failures.
set -e

dartanalyzer --fatal-warnings  --fatal-infos .

pub run test -p vm