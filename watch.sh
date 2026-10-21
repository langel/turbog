#!/bin/bash
onchange -p 250 './**/*.asm' './chr/*.chr' -- sh -c 'echo compiling && ./pceas turbog.asm && echo launching && cmd.exe /C start turbog.pce'
# https://www.npmjs.com/package/onchange?activeTab=readme
