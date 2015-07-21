#!/bin/bash

script_dir="$(source `dirname "$0"`)/lib.sh"


for entry in `builds`; do
	IFS=':' read -a entry_array <<< "$entry"
	action=${entry_array[0]}
	build=${entry_array[1]}

	case "$action" in 
		"$ADDED_LABEL")
			add $build
			;;
		"$UPDATED_LABEL")
			update $build
			;;
		"$REMOVED_LABEL")
			remove $build
			;;
	esac
done

if $auto_commit; then
	git add .
	git commit -m "build event on $(date)"
	git push
fi

if $failed; then
	exit 1
fi
