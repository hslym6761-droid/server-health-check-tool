#!/usr/bin/env bash
#
#server_health_check.sh
#
#a devops capstone project script to check the health of multible remote servers via SSH
#
#Using : ./server_check.sh -f <server_list_file> -u <remote_user>
#


#--- strict mode ---
#set -e : exit immediately if any command fails
#set -u : exit if an undefined variable is used
#set -o pipefail : if any command in a pipline fails , treat the hole pipline as failed
set -euo pipefail


#  --- global constants ---
#  temporary file that will be deleted after the script end
LOG_FILE=$(mktemp /tmp/server_health.XXXXX)
readonly LOG_FILE


# --- function definition ---
# log an informational message to both screen and log file 
log_info() {
	echo "[INFO] $1 " | tee -a "$LOG_FILE"
}

#log an error message to screen and stderr and log file
log_error() {
	echo "[ERROR] $1 " | tee -a "$LOG_FILE" >&2
}


#print script usage 
print_usage() {
	echo " usage : $0 -f <server_list_file> -u <remote_user> "
	echo "    -f : the file that contain the list of servers "
	echo "    -u : the remote ssh user to connect as "
	echo "    -h : display the help message "
}

# this function will cleanup after the script
cleanup() {
	echo " cleaning up the temporary log file : $LOG_FILE "
	rm -f "$LOG_FILE"
}


# trap is the "hook" . we tell it :
# " whenever this script exits for any reason (EXIT) , or receive INT/TERM signals , call the cleanup function "
trap cleanup EXIT INT TERM
echo " script started , log file created at : $LOG_FILE "


#this function perform the actual health check on a remote server
check_server() {
	local server="$1"
	local user="$2"

	log_info " --- checking the server : $server ---"
	#use an SSH her-document to send a batch of commands in one connection
	ssh -n -o ConnecTimeout=5 "${user}@${server}" << 'EOF'
#uptime check
echo "--- system uptime --- "
uptime


#disk check (root partition)
echo " disk usage of root partition "
df -h / | awk 'NR==2 {print "used : " , $5 , " (" , $3 , "/" , $2 , ")"}'

#memory check
echo "memory usage "
free -m | awk 'NR=2 {printf "used : %sMB / total : %sMB (%.2f%%)\n" , $3 , $2 , ($3/$2)*100}'

#security check 
echo "security check "
AUTH_LOG="/var/log/auth.log"
if [[ -f "$AUTH_LOG" ]] ; then
count=$(grep -c "Failed password" "$AUTH_LOG")
echo " failed ssh attempts : $count"
else
echo "failed ssh attempts : auth log not found"
fi
EOF
	log_info "--- finished check : $server ---"
}


#main function of the script
main() {
	local server_file=""
	local remote_user=""
	#---argument passing using "getops---
	while getops ":f:u:h" opt ; do
		case "$opt" in
			f)
				server_file="$OPTARG"
				;;
			u)
				remote_user="$OPTARG"
				;;
			h)
				print_usage
				exit 0 
				;;
			\?) #invalid flag
				log_error "invalid option : $OPTARG "
				print_usage
				exit 1
				;;
			:)#missing value
				log_error "requir an argument"
				print_usage
				exit 1
				;;
		esac
	done


	#----input validation ----
	


