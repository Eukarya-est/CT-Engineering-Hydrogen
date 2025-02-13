#!/bin/bash

password="password"

#Init
function init {
    START_TIME=$SECONDS
    # Execution Date
    echo -n "[" $(date) "]"
    echo ""

    main
    fin
}

# Main
function main {
    # Each package will be removing with this order.
    removeList=( seven carbon-engine automaton xsquish-framework xsquish-installation curo-py3.6 curo-cmdrunner-py3.6 curo-drive-py3.6 supervision )
    # Each package will be checking with this order.
    checkList=( seven carbon-engine automaton squish curo supervision )
    # Remove process
    for i in ${removeList[*]}; do
        if [ "$i" = "seven" ] || [ "$i" = " carbon-engine" ] || [ "$i" = "automaton" ]; then
            # Case1 : carrier remove ...
            remove_w_carrier $i
        else
            # Case2 : rpm -e ...
            remove_w_RPM $i
        fi
    done
}

# Remove List Check
function finalCheck {
    # If grep results are NOT exist, FIN_CONUT--
    if [ "$?" == "1" ]; then
        FIN_COUNT=$((${2} - ${3}))
    fi
}


# Fin
function fin {
    FIN_COUNT=${#checkList[*]};
    ONE=1;
    echo "["$(date +%T)"] Waits for several seconds..."
    #Final Check
    for j in ${checkList[*]}; do
        rpm -qa | grep $j
        finalCheck $? $FIN_COUNT $ONE
    done
    # Calculating the unpatch duration time
    ELAPSED_TIME=$(($SECONDS - $START_TIME))
    if [ $FIN_COUNT == 0 ]; then
        echo "["$(date +%T)"] The SQUISH unpatch process has finished completely. (duration: $(($ELAPSED_TIME/60)) min $(($ELAPSED_TIME%60)) sec)"
    else
        echo "["$(date +%T)"] The SQUISH unpatch process has finished. (duration: $(($ELAPSED_TIME/60)) min $(($ELAPSED_TIME%60)) sec)"
    fi   
}

# Verify the removing work
function verify {
    # Case1: Removing a package is successful
    if [ "$?" == "0" ]; then
        echo "["$(date +%T)"] The ${2} was removed successfully."
    # Case2: Removing a package is failed 
    else
        # Calculating unpatch duration time
        ELAPSED_TIME=$(($SECONDS - $START_TIME))
        echo "["$(date +%T)"] The ${2} Removal failed. exit code: ${1} (duration: $(($ELAPSED_TIME/60)) min $(($ELAPSED_TIME%60)) sec)"
        exit ${1}
    fi
}

# Remove process with the carrier
function remove_w_carrier {
    rpm -qa | grep ${1}
    # Case1 : The package does NOT exist
    if [ "$?" == "1" ]; then
        echo "["$(date +%T)"] The ${1} does NOT exist."
    # Case2 : Removing the package
    else
        echo "["$(date +%T)"] Removing the ${1}."
        echo "$password" | sudo -S carrier remove --clean-deps ${1}
        verify $? "${1}"
    fi
}

# Remove process with the rpm
function remove_w_RPM {
    grep=$(rpm -qa | grep ${1})
    rpm -qa | grep ${1}
    # Case1 : The package does NOT exist
    if [ "$?" == "1" ]; then
        echo "["$(date +%T)"] The ${1} does NOT exist."
    # Case2 : Removing the package
    else
        echo "["$(date +%T)"] Removing the ${1}."
        echo "$password" | sudo -S rpm -e $grep
        verify $? "${1}"
    fi
}

init

