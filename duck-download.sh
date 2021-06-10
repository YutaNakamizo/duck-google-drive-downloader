#!/bin/sh

# recursive function for a folder
operateFolder () {
  scriptpath=$1
  username=$2
  drivepath=$3
  if [ ! $(echo "$drivepath" | rev | cut -c 1) = "/" ] ; then
    drivepath="$drivepath/"
  fi
  localpath=$4
  if [ ! $(echo "$localpath" | rev | cut -c 1) = "/" ]; then
    localpath="$localpath/"
  fi

  echo "\nFetching items in \"$drivepath\" to \"$localpath\" as \"$username\"...\n"

  # download files in this folder
  duck --parallel 8 -e overwrite -y -u "$username" --download "$drivepath*.*" "$localpath"
  
  # get items -> remove color -> remove empty line -> reduce fields => handle each item
  duck -q -y -u "$username" -L "$drivepath" | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})*)?m//g" | tail -n +2 | cut -f 1,4 | while read line; do
    # get item name
    name=`echo $line | cut -c 5-`
    if [ `echo $line | cut -b 1` = "d" ]; then # This item was a folder.
      #echo "Folder $name (skip)"
      # get items in the folder recursively
      eval "$scriptpath" "\"$username\"" "\"$drivepath$name/\"" "\"$localpath$name/\""
    #else # This item was a file.
      # download the file
      #duck -y -u "$username" --download "$drivepath$name" "$localpath"
    fi
  done
    
  exit 0
}

if [ $1 = "--help" -o $1 = "-h" ]; then
  echo "duck-download <username> <drive path> <local path>\n"
else
  operateFolder "$0" "$1" "$2" "$3"
fi

