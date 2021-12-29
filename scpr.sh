#!/bin/bash
# Author MrLaki5

# Check if number of args is valid
if [[ $# != 2 ]]; then
    echo "scpr: Invalid input"
    echo "exoected input: scpr <host dir to copy> <receiver ip>:<receiver path>"
    exit 1
fi

# Load receiver addr and path
receiver_arr=(${2//:/ }) 

# Load receiver password
read -s -p "Receiver ssh password: " password
echo

# TODO: see if paths exist

# Go through all directories in sender dir
for sender_dir in $(find $1 -type d | sort); do
    # Get relative path of dir in respect to root of sending dir
    sender_dir_relative=$(realpath --relative-to=$1/.. $sender_dir)

    # Create directory on receiver
    if [ "${password}" == "" ] ; then
        ssh ${receiver_arr[0]} "mkdir ${receiver_arr[1]}/${sender_dir_relative} 2> /dev/null"
    else
        sshpass -p ${password} ssh ${receiver_arr[0]} "mkdir ${receiver_arr[1]}/${sender_dir_relative} 2> /dev/null"
    fi

    # Go through all files in directory
    for sender_file in $(find ${sender_dir} -maxdepth 1 -type f); do
        # Get relative path of file in respect to root of sending dir
        sender_file_relative=$(realpath --relative-to=$1/.. $sender_file)

        # Check hash sum of remote file
        remote_hash=""
        if [ "${password}" == "" ] ; then 
            remote_hash=($(ssh ${receiver_arr[0]} "sha256sum ${receiver_arr[1]}/${sender_file_relative} 2> /dev/null"))
        else
            remote_hash=($(sshpass -p ${password} ssh ${receiver_arr[0]} "sha256sum ${receiver_arr[1]}/${sender_file_relative} 2> /dev/null"))
        fi
        
        # Check hash sum of local file
        host_hash=($(sha256sum ${sender_file} 2> /dev/null))

        # Check if hashes are not equal
        if [[ "${remote_hash[0]}" != "${host_hash[0]}" ]]; then
            # If hashes are not equal copy file to remote
            echo "Sending new version of file: ${sender_file}"
            if [ "${password}" == "" ] ; then
                scp ${sender_file} ${receiver_arr[0]}:${receiver_arr[1]}/${sender_file_relative}
            else
                sshpass -p ${password} scp ${sender_file} ${receiver_arr[0]}:${receiver_arr[1]}/${sender_file_relative}
            fi
        else
            echo "Skipping file ${sender_file}"
        fi
    done
done
