#!/bin/bash

ProccessorsList="$(dirname $(realpath "$0"))/ProcessList.txt"
if ! test -f $ProccessorsList;then
	touch $ProccessorsList
	echo "Created: $ProccessorsList"
fi

ProccessorsListContents=$(cat $ProccessorsList)
LogDirectory="$(dirname $(realpath "$0"))/Logs"

if ! test -d $LogDirectory;then
	mkdir $LogDirectory
fi


declare -A Running
for process in $ProccessorsListContents;do
	Running["$process"]=false
done

Procceses=$(ps -eo cmd)
while read -r line; do
	for process in "${!Running[@]}";do
		if [[ "$line" == *"$process"* ]] && [[ ${Running["$process"]} != true ]]; then
			Running["$process"]=true
			break
		fi
	done
done <<< "$Procceses"

for key in ${!Running[@]};do
	value=${Running["$key"]}
	basename=$(basename $key)

	if [[ $value == false ]];then
		if [[ "$(command -v $key)" != "" ]];then
			"$key" > "$LogDirectory/${basename%.*}.log" &
			echo "Started $key up again"
		else
			echo "ERROR: Couldnt find executable: $key"
		fi
	fi
done
