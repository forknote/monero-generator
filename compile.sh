#! /usr/bin/env bash


# Bash script for change coin files

# Exit immediately if an error occurs, or if an undeclared variable is used
set -o errexit


[ "$OSTYPE" != "win"* ] || die "Windows is not supported"


# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.


while getopts "c:z" opt; do
    case "$opt" in
    c)  COMPILE_ARGS=${OPTARG}
        ;;
    z)  archive=1
    esac
done
archive=${archive:-0}

shift $((OPTIND-1))

cd ${NEW_COIN_PATH}

# Compile!
if [[ "$OSTYPE" == "msys" ]]; then
	cmake -G "Visual Studio 12 Win64" "..\.."
	msbuild.exe Bytecoin.sln /property:Configuration=Release ${COMPILE_ARGS}
else
	make release-static
fi

if [[ $? == "0" ]]; then
	echo "Compilation successful"
fi

# Move and zip binaries
if [[ $archive == "1" ]]; then
	BUILD_PATH="${WORK_FOLDERS_PATH}/builds"
	ALL_BUILD_FILES="${__CONFIG_core_CRYPTONOTE_NAME}-all-files"

	rm -rf ${BUILD_PATH}/${ALL_BUILD_FILES}
	mkdir -p ${BUILD_PATH}/${ALL_BUILD_FILES}
	cp -R ${NEW_COIN_PATH}/build/release/bin/ ${BUILD_PATH}/${ALL_BUILD_FILES}/
	if [[ " ${__CONFIG_extensions_text} " == *"multiply.json"* ]]; then
		git clone https://github.com/forknote/configs.git ${BUILD_PATH}/${ALL_BUILD_FILES}/configs
		rm -rf ${BUILD_PATH}/${ALL_BUILD_FILES}/configs/.git
		rm -rf ${BUILD_PATH}/${ALL_BUILD_FILES}/configs/.gitignore
	fi

	rm -rf "${NEW_COIN_PATH}/build"
fi
