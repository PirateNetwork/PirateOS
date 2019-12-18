#!/bin/bash
FILE=/home/linux/firstboot.txt
if [[ -f "$FILE" ]]; then
    
else
    chfn -f "HODL" linux
    zenity --error
    echo "yes" > /home/linux/firstboot.txt
fi

exec bash

