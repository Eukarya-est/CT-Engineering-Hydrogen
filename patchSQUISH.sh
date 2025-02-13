#!/bin/bash

password="password"

#Init
function init {
    START_TIME=$SECONDS
    #Execution Date
    echo -n "[" $(date) "]"
    echo ""
    # Input a directory name that exists a Squish-framework install file
    read -p "Enter your (/usr/g/xuser/)diretory (with a Squish-framework install file): " Installer
    # Select the Supervision version that a user want
    read -p "Select the Supervision version ([1]:v3.0.2 / [2]:v2.1.3 / [0]:None): " Version
    # Show the path of the Squish-framework install file
    ls /usr/g/xuser/${Installer}/Xsquish-framework*.noarch.rpm
    # Validate the path of the Squish-framework install file
     # Case1: the Squish-framework install file does NOT exist
    if [ "$?" != "0" ]; then
        echo "Please check your directory."
        exit
     # Case2: Save the path
    else
        framework="/usr/g/xuser/${Installer}/Xsquish-framework*.noarch.rpm"
    fi
    # Validate the Supervision version a user selected
     # Case1: A user does NOT input the number ranged
    if [ "$Version" != "0" ] && [ "$Version" != "1" ] && [ "$Version" != "2" ]; then
        echo "Invalid the Supervision version."
        exit
     # Case2: Save the number that means Supervision version a user selceted
    else
        SupervisionVer=${Version}
    fi

    main
    fin
}

# Main
function main {
    # Each Package will be installing with this order.
    installList=( automaton carbon-engine curo-py3.6 seven Xsquish-installation Xsquish-framework syssquish-scripts seven-squish-api Supervision )
    # Installprocess
    # Installing the packages in the install list
    for i in ${installList[*]}; do
        # Case1: Seven
        if [ "$i" = "Seven" ]; then
            installSeven $i
        # Case2: X Squish-framework
        elif [ "$i" = "Xsquish-framework" ]; then
            installXsquishFramework $i
        # Case3: Sys Squish-scripts
        elif [ "$i" = "syssquish-scripts" ]; then
            installSysSquishScripts $i
        # Case4: Supervision
        elif [ "$i" = "Supervision" ]; then
            installSupervision $i
        # Case5: the others
        else
            installProcess $i
        fi
    done
    rm /usr/g/xuser/myconfig/options
}

# Fin
function fin {
    # Calculating the patch duration time
    ELAPSED_TIME=$(($SECONDS - $START_TIME))
    echo "["$(date +%T)"] The SQUISH patch process has finished. (duration: $(($ELAPSED_TIME/60)) min $(($ELAPSED_TIME%60)) sec)"
}

# Verify the installing work
function verify {
    # Case1: Removing a package is successful
    if [ "$?" == "0" ]; then
        echo "["$(date +%T)"] The ${2} was installed successfully."
    # Case2: Removing a package is failed
    else
        # Calculating the patch duration time
        ELAPSED_TIME=$(($SECONDS - $START_TIME))
        echo "["$(date +%T)"] The ${2} installation failed. exit code: ${1} (duration: $(($ELAPSED_TIME/60)) min $(($ELAPSED_TIME%60)) sec)"
        exit ${1}
    fi
}

# Install
function installProcess { 
    rpm -qa | grep ${1}
    # Case: The package is installed already
    if [ "$?" == "0" ]; then
        echo "["$(date +%T)"] The ${1} is installed already. Thus, reintsalling ${1}. "
        echo "$password" | sudo -S carrier remove ${1}
    fi
    echo "["$(date +%T)"] Installing the ${1}"
    echo "$password" | sudo -S carrier install --no-clean ${1}
    verify $? "${1}"
}

# Install Seven
function installSeven {
    which ${1}
    # Case: The Seven is installed already
    if [ "$?" == "0" ]; then
        echo "["$(date +%T)"] The ${1} is installed already. Thus, reintsalling ${1}."
        echo "$password" | sudo -S carrier remove --clean-deps ${1}
    fi
    echo "["$(date +%T)"] Installing the ${1}"
    echo "$password" | sudo -S carrier install --no-clean ${1}
    verify $? "${1}"
}


# Install Squish-Framework
function installXsquishFramework {
    rpm -qa | grep ${1}
    # Case: The XSquish-framework is installed already
    if [ "$?" == "0" ]; then
        echo "["$(date +%T)"] the ${1} is installed already. Thus, reintsalling ${1}."
        echo "$password" | sudo -S carrier remove ${1}
    fi
    echo "["$(date +%T)"] Installing the ${1}"
    echo "$password" | sudo -S rpm -ihv $framework
    verify $? "${1}"
}

# Install Sys-Squish-Scripts
function installSysSquishScripts {
    rpm -qa | grep ${1}
    # Case: The Sys Squish-scripts is installed already
    if [ "$?" == "0" ]; then
        echo "["$(date +%T)"] the ${1} is installed already. Thus, reintsalling ${1}."
        echo "$password" | sudo -S carrier remove ${1}
    fi
    echo "["$(date +%T)"] Installing the ${1}"
    echo "$password" | sudo -S carrier install --no-clean --stage testflight ${1}
    verify $? "${1}"
}

# Install Supervision
function installSupervision {
    which ${1}
    # Case: The Supervision is installed already
    if [ "$?" == "0" ]; then
        echo "["$(date +%T)"] the Supervision is installed already. Thus, reintsalling ${1}."
        echo "$password" | sudo -S carrier remove ${1}
    fi
    # Case'1': Installing the recent version Supervision
    if [ ${SupervisionVer} == 1 ]; then
        echo "["$(date +%T)"] installing ${1}"
        echo "$password" | sudo -S carrier install --no-clean ${1}
        verify $? "${1}"
    # Case'2': Installing the 2.1.3 version Supervision   
    elif [ ${SupervisionVer} == 2 ]; then
        echo "["$(date +%T)"] Installing the ${1}"
        echo "$password" | sudo -S carrier install --no-clean ${1}=2.1.3
        verify $? "${1}"
    # Case'0': Not Installing the any Supervision     
    else
        echo "Not installing the ${1}"
    fi
}

init

