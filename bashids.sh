#!/usr/bin/env bash
#
# Pure bash implementation of the hashid algorithm
# from http://hashids.org/
#
# Ben Wilber (benwilber@gmail.com)
# https://github.com/benwilber/bashids
#

ALPHABET="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
RATIO_SEPARATORS=4
RATIO_GUARDS=12

# Returns whether a value is an unsigned integer
_is_uint() {
    [[ "$1" =~ ^[0-9]+$ ]]
}

# Splits a string into parts at multiple characters
_split() {
    local IFS=$2
    for i in $1; do
        echo "$i"
    done
}

# Integer index of substr
_indexof() {
    local i=${1%%"$2"*}
    if (( ${#i} == ${#1} )); then
        echo -1
    else
        echo ${#i}
    fi
}

# Convert and ascii char to integer ordinal value
_ordinal() {
    printf "%d" "'$1"
}

# ceil function
_ceil() {
    echo $(( $(( $1 + $2 - 1 )) / $2 ))
}

# Hashes `number` using the given `alphabet` sequence
_hash() {
    local number="$1"
    local alphabet="$2"

    local hashed=""
    local len_alphabet=${#alphabet}

    while true; do
        hashed="${alphabet:$(( $number % $len_alphabet )):1}${hashed}"
        number=$(( $number / $len_alphabet ))
        if (( $number == 0 )); then
            echo "$hashed"
            break
        fi
    done
}

# Restores a number tuple from hashed using the given `alphabet` index
_unhash() {
    local hashed="$1"
    local alphabet="$2"

    local char
    local number=0
    local position
    local len_hash=${#hashed}
    local len_alphabet=${#alphabet}

    for ((i=0; i < $len_hash; i++)); do
        char=${hashed:$i:1}
        position=$(_indexof "$alphabet" "$char")
        let number+=$(( $position * $len_alphabet ** $(( $len_hash - $i - 1))))
    done

    echo $number
}

# Reorders `string` according to `salt`
_reorder() {
    local string="$1"
    local salt="$2"

    if (( ${#salt} == 0 )); then
        echo "$string"
        return
    fi

    local i=$((${#string} - 1))
    local index=0
    local integer_sum=0
    local salt_index
    local temp
    local trailer

    while (( $i > 0)); do
        index=$(( $index % ${#salt} ))
        integer=$(_ordinal ${salt:$index:1})
        let integer_sum+=$integer
        j=$(( $(( $integer + $index + $integer_sum )) % $i ))

        temp=${string:$j:1}
        trailer=""
        if (( $j + 1 < ${#string} )); then
            trailer=${string:$(( $j + 1 ))}
        fi

        string=${string:0:$j}${string:$i:1}${trailer}
        string=${string:0:$i}${temp}${string:$(( $i + 1 ))}

        let i-=1
        let index+=1
    done

    echo "$string"

}

# Returns the ceiled ratio of two numbers as int
_index_from_ratio() {
    _ceil $1 $2
}

# Ensures the minimal hash length
_ensure_length() {
    local encoded="$1"
    local min_length="$2"
    local alphabet="$3"
    local guards="$4"
    local values_hash="$5"

    local len_guards=${#guards}
    local guard_index=$(( $(( $values_hash + $(_ordinal ${encoded:0:1}) )) % $len_guards ))
    encoded="${guards:${guard_index}:1}${encoded}"

    if (( ${#encoded} < $min_length )); then
        guard_index=$(( $(( $values_hash + $(_ordinal ${encoded:2:1}) )) % $len_guards ))
        encoded="${encoded}${guards:${guard_index}:1}"
    fi

    local split_at=$(( ${#alphabet} / 2 ))
    local excess
    local from_index

    while (( ${#encoded} < $min_length )); do
        alphabet=$(_reorder $alphabet $alphabet)
        encoded="${alphabet:${split_at}}${encoded}${alphabet:${split_at}}"
        excess=$(( ${#encoded} - $min_length ))
        if (( $excess > 0)); then
            from_index=$(( excess / 2 ))
            encoded="${encoded:${from_index}:$(( $from_index + $min_length ))}"
        fi
    done

    echo "$encoded"
}

# Helper function that does the hash building without argument checks
_encrypt() {
    local values=($1) # Array

    local salt="$2"
    local min_length="$3"
    local alphabet="$4"
    local separators="$5"
    local guards="$6"

    local len_alphabet=${#alphabet}
    local len_separators=${#separators}
    local values_hash=0

    for ((i=0; i < ${#values[@]}; i++)); do
        let values_hash+=$(( ${values[$i]} % $(( $i + 100 )) ))
    done

    local encoded=${alphabet:$(( $values_hash % $len_alphabet )):1}
    local lottery=$encoded

    local last
    local value
    local alphabet_salt
    for (( i=0; i < ${#values[@]}; i++ )); do
        value=${values[$i]}
        alphabet_salt="${lottery}${salt}${alphabet}"
        alphabet_salt="${alphabet_salt:0:${len_alphabet}}"
        alphabet=$(_reorder $alphabet $alphabet_salt)
        last=$(_hash $value $alphabet)
        encoded="${encoded}${last}"
        value=$(( $value % $(( $(_ordinal ${last:0:1}) + 1 )) ))
        encoded="${encoded}${separators:$(( $value % $len_separators )):1}"
    done

    encoded="${encoded:0:$(( ${#encoded} - 1 ))}"

    if (( ${#encoded} >= $min_length )); then
        echo "$encoded"
    else
        echo "$(_ensure_length $encoded $min_length $alphabet $guards $values_hash)"
    fi
}

# Helper method that restores the values encoded in a hashid without
# argument checks
_decrypt() {
    local hashid="$1"
    local salt="$2"
    local alphabet="$3"
    local separators="$4"
    local guards="$5"

    local part
    local parts=()
    for part in $(_split $hashid $guards); do
        parts+=($part)
    done

    if (( 2 <= ${#parts[@]} <= 3 )); then
        hashid=${parts[1]}
    else
        hashid=${parts[2]}
    fi

    if ! $hashid; then
        return
    fi

    local lottery_char=${hashid:0:1}
    hashid=${hashid:1}

    for part in $(_split $hashid $separators); do
        alphabet_salt="${lottery_char}${salt}${alphabet}"
        alphabet_salt="${alphabet_salt:0:${#alphabet}}"
        alphabet="$(_reorder $alphabet $alphabet_salt)"
        echo $(_unhash $part $alphabet)
    done
}

_getparams() {
    local salt="$1"
    local min_length="$2"
    local alphabet="$3"

    local seps="cfhistuCFHISTU"
    local separators=""
    for ((i=0; i < ${#seps}; i++)); do
        if (( $(_indexof $alphabet ${seps:$i:1}) >= 0 )); then
            separators="${separators}${seps:$i:1}"
        fi
    done

    local _alphabet
    local x
    for ((i=0; i < ${#alphabet}; i++ )); do
        x=${alphabet:$i:1}
        if (( $(_indexof $alphabet $x) == $i )) && (( $(_indexof $separators $x) == -1 )); then
            _alphabet="${_alphabet}${x}"
        fi
    done
    alphabet="$_alphabet"

    local len_alphabet=${#alphabet}
    local len_separators=${#separators}


    if (( $len_alphabet + $len_separators < 16 )); then
        echo "error: alphabet must contain at least 16 unique characters" >&2
        exit 1
    fi

    separators=$(_reorder $separators $salt)
    local min_seperators=$(_index_from_ratio $len_alphabet $RATIO_SEPARATORS)

    if [[ -z "$separators" ]] || (( $len_separators < $min_seperators )); then
        if (( $min_seperators == 1 )); then
            min_seperators=2
        fi

        if (( $min_seperators > $len_separators )); then
            local split_at=$(( $min_seperators - $len_separators ))
            separators="${separators}${alphabet:0:${split_at}}"
            alphabet="${alphabet:${split_at}}"
            len_alphabet=${#alphabet}
        fi
    fi

    alphabet=$(_reorder $alphabet $salt)
    local num_guards=$(_index_from_ratio $len_alphabet $RATIO_GUARDS)
    if (( $len_alphabet < 3 )); then
        guards=${separators:0:${num_guards}}
        separators=${separators:${num_guards}}
    else
        guards=${alphabet:0:${num_guards}}
        alphabet=${alphabet:${num_guards}}
    fi

    echo "$alphabet" "$separators" "$guards"
}


encrypt() {

    local salt
    local min_length=2
    local alphabet=$ALPHABET

    local OPTIND=0
    while getopts "s:a:" opt; do
        case $opt in
            s) salt="$OPTARG";;
            a) alphabet="$OPTARG";;
        esac
    done

    if [[ -z $salt ]]; then
        echo "error: salt is required.  in fact, it's the whole point" >&2
        exit 1
    fi

    shift $(( $OPTIND - 1 ))

    local params=$(_getparams $salt $min_length $alphabet)
    alphabet=${params[0]}
    local separators=${params[1]}
    local guards=${params[2]}

    _encrypt "$*" $salt $min_length $alphabet $separators $guards
}

decrypt() {

    local salt
    local hashid
    local min_length=2
    local alphabet=$ALPHABET

    local OPTIND=0
    while getopts "s:l:a:" opt; do
        case $opt in
            s) salt="$OPTARG";;
        esac
    done
    shift $(( $OPTIND - 1 ))

    local hashid="$1"

    if [[ -z $salt ]]; then
        echo "error: salt is required.  in fact, it's the whole point" >&2
        exit 1
    fi

    if [[ -z $hashid ]]; then
        echo "error: hashid required" >&2
        exit 1
    fi

    local params=$(_getparams $salt $min_length $alphabet)
    alphabet=${params[0]}
    local separators=${params[1]}
    local guards=${params[2]}

    _decrypt $hashid $salt $alphabet $separators $guards
}

hashid=$(encrypt -s mysalt 34 25 256)
echo $hashid
numbers=$(decrypt -s mysalt $hashid)
echo "$numbers"




