#!/bin/bash
# sets the OpenAI API key as an environment variable (required for all API endpoints)
# MUST RUN THIS SCRIPT USING FOLLOWING COMMAND:    source ./set_api_key.sh
# running ./set_api_key.sh will set the env var in a subshell, which is bad juju

# set script variables
num_failed=5
num_total_steps=5
python_installed=0
env_installed=0
env_activated=0
depend_installed=0
success_msg="\e[32m[SUCCESS]\e[0m"
failure_msg="\e[31m[FAILURE]\e[0m"
warning_msg="\e[93m[WARNING]\e[0m"

# CHECK PYTHON INSTALLATION
# This project will not work without having Python 3 installed.
# The exact version of Python should not matter, any 3.x should work.
python_version=$(python3 --version)
if [[ $python_version == "Python 3."* ]]; then
	# extract version number from output string
	py_version_num_long=${python_version:7}
	IFS="."
	py_version_split=($py_version_num_long)
	unset IFS
	py_version_num_short="${py_version_split[0]}.${py_version_split[1]}"
	echo -e "$success_msg Python $py_version_num_short already installed"
	num_failed=$(($num_failed-1))
	python_installed=1
else
	echo -e "$failure_msg Python not installed. Download here: https://www.python.org/downloads/"
fi

# INSTALL VIRTUAL ENV
# Virtual environments are used to isolate where dependencies are
# installed. It is recommended to use the venv module to create virtual envs.
if [[ $python_installed -eq 1 ]]; then
	# if virtual env already exists
	if [[ -d env ]]; then
		echo -e "$success_msg Env directory already exists."
		num_failed=$(($num_failed-1))
		env_installed=1
	else
		python3 -m venv env
		if [[ -d env ]]; then 
			echo -e "$success_msg Env directory has been created successfully."
			num_failed=$(($num_failed-1))
			env_installed=1
		else
			echo -e "$failure_msg Env directory creation failed."
		fi
	fi
else
	echo -e "$failure_msg Python not installed. Unable to create virtual env."
fi

# ACTIVATE VIRTUAL ENV
# Virtual environments must be activated before they can be used.
if [[ $env_installed -eq 1 ]]; then
	# if virtual env is already active
	if [[ $VIRTUAL_ENV ]]; then
		echo -e "$success_msg Virtual env already active."
		num_failed=$(($num_failed-1))
		env_activated=1
	else
		source env/bin/activate
		if [[ -z $VIRTUAL_ENV ]]; then
			echo -e "$failure_msg Virtual environment not active!"
		else
			echo -e "$success_msg Virtual env has been activated successfully."
			num_failed=$(($num_failed-1))
			env_activated=1
		fi
	fi
else
	echo -e "$failure_msg Virtual env does not exist. Unable to activate virtual env."
fi

# INSTALL DEPENDENCIES
# Project dependencies are installed from a requirements.txt file
# A newly-installed virtual env should have 7 directories in
# ./env/
if [[ $env_activated -eq 1 ]]; then
	default_installed_packages=7
	actual_installed_packages=$(ls env/lib/python$py_version_num_short/site-packages/ | wc -l)
	if [[ actual_installed_packages -gt default_installed_packages ]]; then
		echo -e "$success_msg Dependencies were already installed."
		num_failed=$(($num_failed-1))
	else
		python3 -m pip install -q -r requirements.txt
		echo -e "$success_msg All dependencies have been installed."
		num_failed=$(($num_failed-1))
	fi
else
	echo -e "$failure_msg Env not activated. Unable to install dependencies."
fi

# API KEY
# API key is required for interfacing with any OpenAI endpoints
# API keys always start with "sk" and are 51 characters in length
# for security, the API key is stored as an env variable and accessed in
# the python script using os.getent('api_key')

# check if api_key.txt file exists
if [[ -f api_key.txt ]]; then
	echo -e "$success_msg File api_key.txt already exists."
else
	touch api_key.txt
	echo -e "$success_msg File api_key.txt has been created."
fi

# validate API key
api_text_value=$(cat api_key.txt)
if [[ ${user_key:0:2} -eq "sk" && ${#api_key} -eq 51 ]]; then
	echo -e "$success_msg API key already exists as env variable."
	num_failed=$(($num_failed-1))
	if [[ $api_key != $api_text_value ]]; then
		echo $api_key > api_key.txt
		echo -e "$warning_msg File api_key.txt updated to match env variable value."
	fi
# check if API key already exists in api_key.txt file
elif [[ ${api_text_value:0:2} -eq "sk" && ${#api_text_value} -eq 51 ]]; then
	export api_key=$api_text_value
	echo -e "$success_msg API key found in api_key.txt."
	num_failed=$(($num_failed-1))
# if no API key, set new API key
else
	read -p "$warning_msg No API key found. Enter new key (https://beta.openai.com/account/api-keys): " user_key
	# validate API key
	if [[ ${user_key:0:2} == "sk" && ${#user_key} -eq 51 ]]; then
		# export key value as environment variable
		export api_key=$user_key
		echo $api_key > api_key.txt
		# provide response message for user feedback
		echo -e "$success_msg OpenAI API key is now available in current environment"
		num_failed=$(($num_failed-1))
	# error if API key is not valid
	else
		echo -e "$failure_msg API key not valid! Must be 51 characters and start with \"sk\""
	fi
fi
