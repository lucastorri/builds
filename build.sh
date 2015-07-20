#!/bin/bash

script_dir=`cd $(dirname "$0"); pwd`

builds_dir=$script_dir/builds
known_builds_dir=$script_dir/.known-builds
auto_commit=${BUILDS_AUTO_COMMIT:=false}
failed=false

ADDED_LABEL="added"
UPDATED_LABEL="updated"
REMOVED_LABEL="removed"


run() {
	/Users/lucastorri/Projects/go/src/github.com/soundcloud/pipeline-generator/ppl-example $1 "$builds_dir/$2"
}

error() {
	failed=true
	echo -e "\033[31m$@\033[0m"
}

success() {
	echo -e "\033[32m$@\033[0m"
}

hash() {
	md5 -q "$1"
}

changed_files() {
	while read -r f; do 
		if [[ `cat "$known_builds_dir/$f"` != `hash "$builds_dir/$f"` ]]; then
			echo $f
		fi
	done
}

builds() {
	updated_builds=`comm -12 <(ls $builds_dir | sort) <(ls $known_builds_dir | sort) | changed_files | xargs -I BUILD echo "$UPDATED_LABEL:BUILD"`
	new_builds=`comm -23 <(ls $builds_dir | sort) <(ls $known_builds_dir | sort) | xargs -I BUILD echo "$ADDED_LABEL:BUILD"`
	removed_builds=`comm -13 <(ls $builds_dir | sort) <(ls $known_builds_dir | sort) | xargs -I BUILD echo "$REMOVED_LABEL:BUILD"`

	echo $new_builds
	echo $updated_builds
	echo $removed_builds
}


add() {
	run create $1
	if [[ "$?" == "0" ]]; then
		hash "$builds_dir/$1" > "$known_builds_dir/$1"
		success "$1 successfully added"
	else
		error "Could not add $1"
	fi
}

update() {
	run update $1
	if [[ "$?" == "0" ]]; then
		hash "$builds_dir/$1" > "$known_builds_dir/$1"
		success "$1 successfully updated"
	else 
		error "Could not update $1"
	fi
}

remove() {
	run delete $1
	if [[ "$?" == "0" ]]; then
		rm "$known_builds_dir/$1"
		success "$1 successfully removed"
	else
		error "Could not remove $1"
	fi
}

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
