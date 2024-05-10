#!/bin/bash

print_help() {
	echo "Usage: $0 [OPTIONS]"
	echo "Options:"
	echo "	-u, --users		Display a list of users and their home directories sorted alphabetically."
	echo "	-p, --processes		Display a list of running proccesses sorted by their IDs."
	echo "	-h, --help		Display help message and exit."
	echo "	-l PATH, --log PATH	Redirect output to a file specified by PATH."
	echo "	-e PATH, --errors PATH	Redirect errors to a file specified by PATH."
	exit 0
}

display_users() {
	getent passwd | cut -d: -f1,6 | sort
}

display_processes() {
	ps -eo pid,cmd --sort=pid
}

redirect_output() {
	local path="$1"
	if [ -n "$path" ]; then
		exec > "$path"
	else
		echo "Error: Missing argument for output redirection." >&2
		exit 1
	fi
}

redirect_errors() {
	local path="$1"
        if [ -n "$path" ]; then
                exec 2> "$path"
        else
                echo "Error: Missing argument for output redirection." >&2
                exit 1
        fi
}

if [ $# -eq 0 ]; then
	echo "Error: No arguments provided. Use -h or --help for usage." >&2
	exit 1
fi

while getopts "uphl:e:-:" opt; do
	case $opt in
		u )
			display_users
			;;
		p )
			display_processes
			;;
		h )
			print_help
			;;
		l )
			shift
			redirect_output "$OPTARG"
			;;
		e )
			shift
			redirect_errors "$OPTARG"
			;;
		 - )
                        case "${OPTARG}" in
                                users )
                                        display_users
                                        ;;
                                processes )
                                        display_processes
                                        ;;
                                help )
                                        print_help
                                        ;;
                                log )
                                        shift
                                        redirect_output "$1"
                                        ;;
                                errors )
                                        shift
                                        redirect_errors "$1"
                                        ;;
                                *)
                                        echo "Error: Invalid option: --$OPTARG" >&2
                                        exit 1
                                        ;;
                                esac;;


		\? )
			echo "Error: Invalid option: -$OPTARG" >&2
			exit 1
			;;
		: )
			echo "Error: Option -&OPTARG requires an argument." >&2
			exit 1
			;;
	esac
done

shift $((OPTIND -1))
