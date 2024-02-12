#!/bin/bash

cleanup() {
    echo "### done"
}

# Directory of this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Defaults: Directory for the virtual environment
VENV_DIR="$SCRIPT_DIR/venv"

# Setup the virtual environment
if [[ ! -d "$VENV_DIR" ]]; then
    # Create the virtual environment
    echo "# Setting up python env in folder $VENV_DIR"
    PYTHON="$(which python3)"
    if [[ -z "$PYTHON" ]]; then
        PYTHON="$(which python)"
    fi
    if [[ -z "$PYTHON" ]]; then
        echo "Could not find a Python installation, please install Python 3."
        exit 1
    fi
    if ! ($PYTHON -V 2>&1 | grep "Python 3" > /dev/null); then
        echo "Executing \"$PYTHON\" does not run Python 3, please make sure that python3 or python on your PATH points to Python 3"
        exit 1
    fi
    if ! ($PYTHON -c "import venv" &> /dev/null); then
        echo "Python 3 module \"venv\" was not found."
        exit 1
    fi
    $PYTHON -m venv "$VENV_DIR"
    if [[ $? != 0 ]]; then
        echo "Creating the virtual environment in $VENV_DIR failed."
        exit 1
    fi
    echo "# Activate venv and install pynrfjprog and intelhex"
    source "$VENV_DIR/bin/activate"
    pip install --upgrade pip
    pip install pynrfjprog && pip install intelhex
    if [[ $? != 0 ]]; then
        echo "Could not install Python 3 module pynrfjprog in $VENV_DIR";
        exit 1
    fi
else
    source "$VENV_DIR/bin/activate"
fi

# Call flash_nrf.py. Errors from here on are critical
set -e
trap cleanup INT TERM EXIT
echo "### Executing python script ###"
python3 "$(dirname "$0")"/check_nrf.py"/
echo "### Python script finished  ###"
