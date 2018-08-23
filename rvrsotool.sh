#!/bin/bash

function recurse_dir {
    bin=$1;
    cur_path=$(pwd);
    for f in *;
    do
        if [[ -f "${f}" ]]; then
            IFS=$'\n';
            ilibs=$(otool -L "$cur_path/${f}" | sed -n 's/^    \(.*\) (compatibility version.*$/\1/p');
            libs=$"";
            if [ $? -ne 0 ] || [ -z ${libs+x} ]; then
                :
            else
                echo "${f}"
            fi
            for lib in $libs
            do
                if [[ "$lib" == "$bin" ]]; then
                    printf "$cur_path/$bin"
                fi
            done
        fi
    done
    for d in *;
    do
        if [[ -d "${d}" ]]; then
            cd "${d}";
            if [ $? -eq 0 ]; then
                recurse_dir "$bin"
                cd ..
            fi
        fi
    done
}

orig_IFS=IFS;
if [ $# -eq 0 ] || [ $# -gt 2 ]; then
    echo "usage: [options: -r] [path]";
    echo "    -r    recursively search through all directories";
    echo "Please provide full path as argument to path";
elif [ $# -eq 1 ]; then
    IFS=':'; bin_path=$1; appended_path=$"$PATH:/usr/lib";
    for path in $appended_path
    do
        (contents=$(ls $path);
        IFS=$'\n';
        for bin in $contents
        do
            libs=$(otool -L "$path/$bin" | sed -n 's/^    \(.*\) (compatiblity version.*$/\1/p')
            if [ -z ${libs+x} ]
            then
                :
            else
                echo "$bin"
            fi
            for lib in $libs
            do
                if [[ "$lib" == "$bin_path" ]]; then
                    printf "$path/$bin"
                fi
            done
        done)
    done
elif [ $# -eq 2 ] && [ "$1" == "-r" ]; then
    cd "/";
    recurse_dir "$2";
fi
IFS=$orig_IFS
