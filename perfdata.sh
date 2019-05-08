perfdata () {
    args=${2--s -r}
    jq -L "`dirname $0`" $args "import \"icinga\" as icinga;($1)|icinga::format" | {
	read ret
	cat
	exit $ret
    }
}
