#!/bin/bash
# repo_url: https://github.com/cangulo-templates/bash-scripts-and-functions
# repo_version: 0.0.1

export FONT_RED='\033[0;31m'
export FONT_GREEN='\033[0;32m'
export FONT_YELLOW='\033[1;33m'
export FONT_WHITE='\033[1;37m'
export FONT_BLUE='\033[0;34m'
export FONT_BLUE_LIGHT='\033[1;34m'
export FONT_NC='\033[0m' # No Color

logTitle() {
    echo -e "${FONT_BLUE}${@}${FONT_NC}"
}
export logTitle

logSuccess() {
    echo -e "${FONT_GREEN}${@}${FONT_NC}"
}
export logSuccess

logWarning() {
    echo -e "${FONT_YELLOW}${@}${FONT_NC}"
}
export logWarning

logError() {
    echo -e "${FONT_RED}${@}${FONT_NC}"
}
export logError

logParameter() {
    param_name=$1
    param_value="${@:2}"
    echo -e "${FONT_WHITE}\t$param_name -> ${FONT_BLUE_LIGHT}$param_value${FONT_NC}"
}
export logParameter
