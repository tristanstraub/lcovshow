#!/bin/sh
// 2>/dev/null; exec "`dirname "$0"`/node" "$0" "$@"
require('coffee-script/register');
require('lcovshow/src/lcovshow').main();
