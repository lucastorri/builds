

script_dir=`cd $(dirname "$0"); pwd`

builds_dir=$script_dir/builds
known_builds_dir=$script_dir/.known-builds
auto_commit=${BUILDS_AUTO_COMMIT:=false}

ADDED_LABEL="added"
UPDATED_LABEL="updated"
REMOVED_LABEL="removed"

PIPELINE_CMD="echo"


error() {
	echo -e "\033[31m$@\033[0m"
}

success() {
	echo -e "\033[32m$@\033[0m"
}

hash() {
	md5 -q "$1"
}

file_changed() {
	while read -r f; do 
		if [[ `cat "$known_builds_dir/$f"` != `hash "$builds_dir/$f"` ]]; then
			echo $f
		fi
	done
}

builds() {
	new_builds=`comm -23 <(ls $builds_dir | sort) <(ls $known_builds_dir | sort) | xargs -I BUILD echo "$ADDED_LABEL:BUILD"`
	updated_builds=`comm -12 <(ls $builds_dir | sort) <(ls $known_builds_dir | sort) | file_changed | xargs -I BUILD echo "$UPDATED_LABEL:BUILD"`
	removed_builds=`comm -13 <(ls $builds_dir | sort) <(ls $known_builds_dir | sort) | xargs -I BUILD echo "$REMOVED_LABEL:BUILD"`

	echo $new_builds
	echo $updated_builds
	echo $removed_builds
}


add() {
	$PIPELINE_CMD create $1
	if [[ "$?" == "0" ]]; then
		hash "$builds_dir/$1" > "$known_builds_dir/$1"
	else
		error "Could not add $1"
	fi
}

update() {
	$PIPELINE_CMD update $1
	if [[ "$?" == "0" ]]; then
		hash "$builds_dir/$1" > "$known_builds_dir/$1"
	else 
		error "Could not update $1"
	fi
}

remove() {
	$PIPELINE_CMD delete $1
	if [[ "$?" == "0" ]]; then
		rm "$known_builds_dir/$1"
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
