#!/bin/bash
# usage : <path to p40pktcodegen.sh> <p4-source> <std {p4-14, p4-16}> <destination directory path> [-d] [-scapy] [-lua] [-moongen] [-pcpp]

usage(){
    echo "Usage: p4-pktcodegen.sh [-h|--help] [-p4 <path to p4 source>] [-json <path to json description>] [--std {p4-14|p4-16}] [-o <path to destination dir>] [--scapy] [--wireshark] [--moongen] [--pcpp] [--debug]"
    exit $1
}
# if no arguments are specified then show usage
if ([[ "$#" == "0" ]]); then
    usage 0
fi

JSON_DETECT=false
OUT_DETECT=false
SCAPY=false
WIRESHARK=false
MOONGEN=false
PCAPPLUSPLUS=false
DEBUG_MODE=false
STANDARD="p4-14"

while test $# -gt 0; do
    case "$1" in
        -h|--help)
            usage 0
            ;;
        -p4)
            shift
            if test $# -gt 0; then
                P4_SOURCE=$(realpath $1)
                shift    
            else
                echo "P4 source not found"
                usage 1
            fi
            ;;
        -json)
            shift
            if test $# -gt 0; then
                JSON_DETECT=true
                JSONSOURCE=$(realpath $1)
                shift    
            else
                echo "JSON source not found"
                usage 1
            fi
            ;;
        -o)
            shift
            if test $# -gt 0; then
                OUT_DETECT=true
                OUTPUT=$1
                shift    
            else
                echo "output flag given but directory not specified"
                usage 1
            fi
            ;;
        --std)
            shift
            if test $# -gt 0; then
                STANDARD=$1
                shift    
            else
                echo "Standard flag given, but standard not specified, use p4-14 OR p4-16"
                usage 2
            fi
            ;;
        --scapy)
            shift
            SCAPY=true
            ;;    
        --wireshark)
            shift
            WIRESHARK=true
            ;;
        --moongen)
            shift
            MOONGEN=true
            ;;
        --pcpp)
            shift
            PCAPPLUSPLUS=true
            ;;
        --debug)
            shift
            DEBUG_MODE=true
            ;;
        *)
            break
            ;;  
    esac
done


if [ "$JSON_DETECT" = false ]; then
    # creates a temp folder with timestamp to hold json script and compiled binaries
    foldername="`date +%Y%m%d%H%M%S`";
    foldername="tempfolder_$foldername"
    mkdir $foldername
    cd $foldername

    # p4 source compilation
    echo -e "----------------------------------\nCompiling p4 source ..."
    p4c-bm2-ss --std $standard -o alpha.json $source_path > /dev/null 2>&1
    if [ $? != "0" ]; then
        echo "Compilation with p4c-bm2-ss failed...trying with p4c"
        p4c -S --std $standard $source_path > /dev/null 2>&1
        if [ $? != "0" ]; then
            echo "Compilation with p4c failed.. exiting"
            cd ..
            rm -r $foldername
            exit 3
        else
            echo "Compilation successful with p4c"
        fi

    else
        echo "Compilation successful with p4c-bm2-ss"
    fi
    echo -e "------------------------------------\n"
    
    JSONSOURCE=$(find . -name "*.json" -type f)
    JSONSOURCE=$(realpath $JSONSOURCE)
    cd ..
    if ([ "$OUT_DETECT" = false ]);then
        OUTPUT=$(dirname "$P4_SOURCE")
        echo -e "Using the directory of source as default destination directory\n"
    fi
else
    if ([ "$OUT_DETECT" = false ]);then
        OUTPUT=$(dirname "$JSONSOURCE")
        echo -e "Using the directory of source as default destination directory\n"
    fi

fi

# DIR stores the path to p4-pktcodegen script, this is required for calling backend scripts
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" 

TARGET_SPEC=0
# running backend scripts
if [[ "$SCAPY" = true ]];then
    temp="$OUTPUT/scapy"
    echo "Running Scapy backend script for $1"
    TARGET_SPEC=1
    mkdir -p $temp
    python $DIR/src/GenTrafficScapy.py $JSONSOURCE $temp $DEBUG_MODE
    echo -e "------------------------------------\n"
fi
if [[ "$WIRESHARK" = true ]];then
    temp="$OUTPUT/lua_dissector"
    echo "Running Lua dissector backend script for $1"
    TARGET_SPEC=1
    mkdir -p $temp
    python $DIR/src/DissectTrafficLua.py $JSONSOURCE $temp $DEBUG_MODE
    echo -e "------------------------------------\n"
fi
if [[ "$MOONGEN" = true ]];then
    temp="$OUTPUT/moongen"
    echo "Running MoonGen backend script for $1"
    TARGET_SPEC=1
    mkdir -p $temp
    python $DIR/src/GenTrafficMoonGen.py $JSONSOURCE $temp $DEBUG_MODE
    echo -e "------------------------------------\n"
fi
if [[ "$PCAPPLUSPLUS" = true ]];then
    temp="$OUTPUT/pcapplusplus"
    echo "Running PcapPlusPlus backend script for $1"
    TARGET_SPEC=1
    mkdir -p $temp
    python $DIR/src/DissectTrafficPcap.py $JSONSOURCE $temp $DEBUG_MODE
    echo -e "------------------------------------\n"
fi
if (("$TARGET_SPEC"!=1)); then
    echo "No target specified"
    usage 3
fi

if [[ "$JSON_DETECT" = false ]]; then
    rm -rf $foldername
fi