#!/bin/bash

start=$(date "+%s.%N")

# -------------------------- INFO --------------------------

function basic () {
	proceed=false
	echo "Metagoofeel v2.2 ( github.com/ivan-sincek/metagoofeel )"
	echo ""
	echo "--- Crawl ---"
	echo "Usage:   ./metagoofeel.sh -d domain              [-r recursion]"
	echo "Example: ./metagoofeel.sh -d https://example.com [-r 20       ]"
	echo ""
	echo "--- Crawl and download ---"
	echo "Usage:   ./metagoofeel.sh -d domain              -k keyword [-r recursion]"
	echo "Example: ./metagoofeel.sh -d https://example.com -k all     [-r 20       ]"
	echo ""
	echo "--- Download from a file ---"
	echo "Usage:   ./metagoofeel.sh -f file                 -k keyword"
	echo "Example: ./metagoofeel.sh -f metagoofeel_urls.txt -k pdf"
}

function advanced () {
	basic
	echo ""
	echo "DESCRIPTION"
	echo "    Crawl through an entire website and download specific or all files"
	echo "DOMAIN"
	echo "    Domain you want to crawl"
	echo "    -d <domain> - https://example.com | https://192.168.1.10 | etc."
	echo "KEYWORD"
	echo "    Keyword to download only specific files"
	echo "    Use 'all' to download all files"
	echo "    -k <keyword> - pdf | js | png | all | etc."
	echo "RECURSION"
	echo "    Maximum recursion depth"
	echo "    Use '0' for infinite"
	echo "    Default: 10"
	echo "    -r <recursion> - 0 | 5 | etc."
	echo "FILE"
	echo "    File with [already crawled] URLs"
	echo "    -f <file> - metagoofeel_urls.txt | etc."
}

# -------------------- VALIDATION BEGIN --------------------

# my own validation algorithm

proceed=true

# $1 (required) - message
function echo_error () {
	echo "ERROR: ${1}" 1>&2
}

# $1 (required) - message
# $2 (required) - help
function error () {
	proceed=false
	echo_error "${1}"
	if [[ $2 == true ]]; then
		echo "Use -h for basic and --help for advanced info" 1>&2
	fi
}

declare -A args=([domain]="" [keyword]="" [recursion]="" [file]="")

# $1 (required) - key
# $2 (required) - value
function validate () {
	if [[ ! -z $2 ]]; then
		if [[ $1 == "-d" && -z ${args[domain]} ]]; then
			args[domain]=$2
		elif [[ $1 == "-k" && -z ${args[keyword]} ]]; then
			args[keyword]=$2
		elif [[ $1 == "-r" && -z ${args[recursion]} ]]; then
			args[recursion]=$2
			if [[ ! ( ${args[recursion]} =~ ^[0-9]+$ ) ]]; then
				error "Recursion depth must be numeric"
			fi
		elif [[ $1 == "-f" && -z ${args[file]} ]]; then
			args[file]=$2
			if [[ ! -f ${args[file]} ]]; then
				error "File does not exists"
			elif [[ ! -r ${args[file]} ]]; then
				error "File does not have read permission"
			elif [[ ! -s ${args[file]} ]]; then
				error "File is empty"
			fi
		fi
	fi
}

# $1 (required) - argc
# $2 (required) - args
function check() {
	local argc=$1
	local -n args_ref=$2
	local count=0
	for key in ${!args_ref[@]}; do
		if [[ ! -z ${args_ref[$key]} ]]; then
			count=$((count + 1))
		fi
	done
	echo $((argc - count == argc / 2))
}

if [[ $# == 0 ]]; then
	advanced
elif [[ $# == 1 ]]; then
	if [[ $1 == "-h" ]]; then
		basic
	elif [[ $1 == "--help" ]]; then
		advanced
	else
		error "Incorrect usage" true
	fi
elif [[ $(($# % 2)) -eq 0 && $# -le $((${#args[@]} * 2)) ]]; then
	for key in $(seq 1 2 $#); do
		val=$((key + 1))
		validate "${!key}" "${!val}"
	done
	if [[ -z ${args[domain]} && -z ${args[file]} || ( ! -z ${args[domain]} || ! -z ${args[recursion]} ) && ! -z ${args[file]} || $(check $# args) -eq false ]]; then
		error "Missing a mandatory option (-d) and/or optional (-k, -r)"
		error "Missing a mandatory option (-f, -k)" true
	fi
else
	error "Incorrect usage" true
fi

# --------------------- VALIDATION END ---------------------

# ----------------------- TASK BEGIN -----------------------

# $1 (required) - message
function timestamp () {
	echo "${1} -- $(date "+%H:%M:%S %m-%d-%Y")"
}

function interrupt () {
	echo ""
	echo "[Interrupted]"
}

# $1 (required) - domain
# $2 (required) - output
# $3 (optional) - recursion
function crawl () {
	echo "All crawled URLs will be saved in '${2}'"
	echo "You can tail the crawling progress with 'tail -f ${2}'"
	echo "Press CTRL + C to stop early"
	timestamp "Crawling has started"
	wget "${1}" -e robots=off -nv --spider --random-wait -nd --no-cache -r -l "${3}:-10" -o "${2}"
	timestamp "Crawling has ended  "
	grep -Po '(?<=URL\:\ )[^\s]+(?=\ 200\ OK)' "${2}" | sort -u -o "${2}"
	echo "Total URLs crawled: $(cat "${2}" | grep -Po '[^\s]+' | wc -l)"
}

downloading=true

function interrupt_download () {
	downloading=false
	interrupt
}

# $1 (required) - keyword
# $2 (required) - input
function download () {
	local count=0
	local directory="metagoofeel_$(echo "${1}" | sed "s/[[:space:]]/_/g;s/\//_/g")"
	echo "All downloaded files will be saved in '/${directory}/'"
	echo "Press CTRL + C to stop early"
	timestamp "Downloading has started"
	for url in $(cat "${2}" | grep -Po '[^\s]+'); do
		if [[ $downloading == false ]]; then
			break
		fi
		if [[ $1 == "all" || $(echo "${url}" | grep -i "${1}") ]]; then
			if [[ $(wget "${url}" -e robots=off -nv -nc -nd --no-cache -P "${directory}" 2>&1) ]]; then
				echo "${url}"
				count=$((count + 1))
			fi
		fi
	done
	timestamp "Downloading has ended  "
	echo "Total files downloaded: ${count}"
}

if [[ $proceed == true ]]; then
	echo "########################################################################"
	echo "#                                                                      #"
	echo "#                           Metagoofeel v2.2                           #"
	echo "#                                  by Ivan Sincek                      #"
	echo "#                                                                      #"
	echo "# Crawl through an entire website and download specific or all files.  #"
	echo "# GitHub repository at github.com/ivan-sincek/metagoofeel.             #"
	echo "#                                                                      #"
	echo "########################################################################"
	if [[ ! -z ${args[file]} ]]; then
		trap interrupt_download INT
		download "${args[keyword]}" "${args[file]}"
		trap INT
	else
		output="metagoofeel_urls.txt"
		input="yes"
		if [[ -f $output ]]; then
			echo "Output file '${output}' already exists"
			read -p "Overwrite the output file (yes): " input
			echo ""
		fi
		if [[ $input == "yes" ]]; then
			trap interrupt INT
			crawl "${args[domain]}" "${output}" "${args[recursion]}"
			trap INT
			if [[ ! -z ${args[keyword]} ]]; then
				echo ""
				read -p "Start downloading (yes): " input
				if [[ $input == "yes" ]]; then
					echo ""
					trap interrupt_download INT
					download "${args[keyword]}" "${output}"
					trap INT
				fi
			fi
		fi
	fi
	end=$(date "+%s.%N")
	runtime=$(echo "${end} - ${start}" | bc -l)
	echo ""
	echo "Script has finished in ${runtime}"
fi

# ------------------------ TASK END ------------------------
