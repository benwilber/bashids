#!/usr/bin/env bash
#
# Pure bash implementation of the hashid algorithm
# from http://hashids.org/
#
# Ben Wilber (benwilber@gmail.com)
# https://github.com/benwilber/bashids
#
set -e

# Default alphabet used for building hashids
ALPHABET="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"

# Default minimum length of a hashid
MIN_LENGTH=0

# Default salt is empty string
DEFAULT_SALT=""

# Internal options
RATIO_SEPARATORS=3.5
RATIO_GUARDS=12

# Shared variable to store return values.
# We use this instead of capturing outputs
# via subshells.
__RETURN=

# Splits a string into parts at multiple characters
_split() {
    __RETURN=()
    local IFS=$2
    for i in $1; do
        __RETURN+=("$i")
    done
}

# Integer index of substr
_indexof() {
    local i="${1%%"$2"*}"
    if (( "${#i}" == "${#1}" )); then
        __RETURN=-1
    else
        __RETURN=${#i}
    fi
}

# Convert an ascii char to integer ordinal value
_ordinal() {
    printf -v __RETURN "%d" "'$1"
}

# ceil function
_ceil() {
    local fixed=${2%.*}
    local decimal=${2#*.}
    local scale=${#decimal}
    local factor=$(( 10 ** scale))
    local number=$(( fixed * factor + decimal ))
    __RETURN=$(( ( $1 * factor + number - factor ) / number  ))
}

# Hashes `number` using the given `alphabet` sequence
_hash() {
    local number="$1"
    local alphabet="$2"

    local hashed=""
    local len_alphabet="${#alphabet}"

    while true; do
        hashed="${alphabet:$(( number % len_alphabet )):1}${hashed}"
        number=$(( number / len_alphabet ))
        if (( number == 0 )); then
            __RETURN="$hashed"
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
    local len_hash="${#hashed}"
    local len_alphabet="${#alphabet}"

    for ((i=0; i < len_hash; i++)); do
        char="${hashed:$i:1}"
        _indexof "$alphabet" "$char"
        if (( __RETURN == -1 )); then
            echo "error: invalid hashid" >&2
            exit 1
        fi
        let number+=$(( __RETURN * len_alphabet ** $(( len_hash - i - 1)) ))
    done

    __RETURN="$number"
}

# Reorders `string` according to `salt`
_reorder() {
    local string="$1"
    local salt="$2"

    if (( ${#salt} == 0 )); then
        __RETURN="$string"
        return
    fi

    local i=$(( ${#string} - 1 ))
    local j
    local index=0
    local integer_sum=0
    local temp
    local trailer
    
    while (( i > 0 )); do
        index=$(( index % ${#salt} ))
        _ordinal "${salt:$index:1}"
        let integer_sum+=$__RETURN
        j=$(( $(( __RETURN + index + integer_sum )) % i ))

        temp="${string:$j:1}"
        trailer=""
        if (( j + 1 < ${#string} )); then
            trailer="${string:$(( j + 1 ))}"
        fi

        string="${string:0:$j}${string:$i:1}${trailer}"
        string="${string:0:$i}${temp}${string:$(( i + 1 ))}"

        i=$(( i - 1 ))
        let index+=1
    done

    __RETURN="$string"
}

# Ensures the minimal hash length
_ensure_length() {
    local encoded="$1"
    local min_length="$2"
    local alphabet="$3"
    local guards="$4"
    local values_hash="$5"

    local len_guards="${#guards}"
    _ordinal "${encoded:0:1}"
    local guard_index=$(( $(( values_hash + __RETURN )) % len_guards ))
    encoded="${guards:${guard_index}:1}${encoded}"

    if (( "${#encoded}" < min_length )); then
        _ordinal "${encoded:2:1}"
        guard_index=$(( $(( values_hash + __RETURN )) % len_guards ))
        encoded="${encoded}${guards:${guard_index}:1}"
    fi

    local len_alphabet="${#alphabet}"
    local split_at=$(( len_alphabet / 2 ))
    local excess
    local from_index
    local encoded_len

    while (( "${#encoded}" < min_length )); do
        _reorder "$alphabet" "$alphabet" > /dev/null
        alphabet="$__RETURN"
        encoded="${alphabet:${split_at}}${encoded}${alphabet:0:${split_at}}"

        encoded_len="${#encoded}"
        excess=$(( encoded_len - min_length ))
        if (( excess > 0)); then
            from_index=$(( excess / 2 ))
            encoded="${encoded:${from_index}:${min_length}}"
        fi
    done

    __RETURN="$encoded"
}

# Helper function that does the hash building without argument checks
_encode() {
    local values=($1)
    local salt="$2"
    local min_length="$3"
    local alphabet="$4"
    local separators="$5"
    local guards="$6"

    local len_alphabet="${#alphabet}"
    local len_separators="${#separators}"
    local values_hash=0
    local hashed

    for ((i=0; i < ${#values[@]}; i++)); do
        hashed=$(( ${values[$i]} % $(( i + 100 )) ))
        if (( hashed > 0 )); then
            let values_hash+=$hashed
        fi
    done

    local encoded="${alphabet:$(( values_hash % len_alphabet )):1}"
    local lottery="$encoded"

    local last
    local value
    local alphabet_salt
    for (( i=0; i < ${#values[@]}; i++ )); do
        value=${values[$i]}
        alphabet_salt="${lottery}${salt}${alphabet}"
        alphabet_salt="${alphabet_salt:0:${len_alphabet}}"
        _reorder "$alphabet" "$alphabet_salt"
        alphabet="$__RETURN"
        _hash "$value" "$alphabet"
        last="$__RETURN"
        encoded="${encoded}${last}"
        _ordinal "${last:0:1}"
        value=$(( value % $(( __RETURN + i )) ))
        encoded="${encoded}${separators:$(( value % len_separators )):1}"
    done

    encoded="${encoded:0:$(( ${#encoded} - 1 ))}"

    if (( ${#encoded} >= min_length )); then
        echo "$encoded"
    else
        _ensure_length "$encoded" "$min_length" "$alphabet" "$guards" "$values_hash"
        echo "$__RETURN"
    fi
}

# Helper function that restores the values encoded in a hashid without
# argument checks
_decode() {
    local hashid="$1"
    local salt="$2"
    local alphabet="$3"
    local separators="$4"
    local guards="$5"
    local alphabet_salt

    _split "$hashid" "$guards"
    if (( 2 <= ${#__RETURN[@]} && ${#__RETURN[@]} <= 3 )); then
        hashid="${__RETURN[1]}"
    else
        hashid="${__RETURN[0]}"
    fi

    if [[ -z $hashid ]]; then
        return
    fi

    local lottery_char=${hashid:0:1}
    hashid=${hashid:1}

    local part
    local unhashed

    _split "$hashid" "$separators"
    for part in "${__RETURN[@]}"; do
        alphabet_salt="${lottery_char}${salt}${alphabet}"
        alphabet_salt="${alphabet_salt:0:${#alphabet}}"
        _reorder "$alphabet" "$alphabet_salt"
        alphabet="$__RETURN"
        _unhash "$part" "$alphabet"
        unhashed="$__RETURN"
        if [[ "$unhashed" ]]; then
            echo "$unhashed"
        fi
    done
}

# Figures out the the `alphabet`, `seperators`, and `guards`
_getparams() {
    local salt="$1"
    local min_length="$2"
    local alphabet="$3"

    local seps="cfhistuCFHISTU"
    local separators=""
    for ((i=0; i < "${#seps}"; i++)); do
        _indexof "$alphabet" "${seps:$i:1}"
        if (( __RETURN >= 0 )); then
            separators="${separators}${seps:$i:1}"
        fi
    done

    local _alphabet
    local x
    for ((i=0; i < "${#alphabet}"; i++ )); do
        x="${alphabet:$i:1}"
        _indexof "$alphabet" "$x"
        local ret1=$__RETURN
        _indexof "$separators" "$x"
        local ret2=$__RETURN
        if (( ret1 == i )) && (( ret2 == -1 )); then
            _alphabet="${_alphabet}${x}"
        fi
    done
    alphabet="$_alphabet"

    local len_alphabet="${#alphabet}"
    local len_separators="${#separators}"


    if (( len_alphabet + len_separators < 16 )); then
        echo "error: alphabet must contain at least 16 unique characters" >&2
        exit 1
    fi

    _reorder "$separators" "$salt"
    separators="$__RETURN"
    _ceil "$len_alphabet" "$RATIO_SEPARATORS"
    local min_seperators="$__RETURN"

    if [[ -z "$separators" ]] || (( len_separators < min_seperators )); then
        if (( min_seperators == 1 )); then
            min_seperators=2
        fi

        if (( min_seperators > len_separators )); then
            local split_at=$(( min_seperators - len_separators ))
            separators="${separators}${alphabet:0:${split_at}}"
            alphabet="${alphabet:${split_at}}"
            len_alphabet="${#alphabet}"
        fi
    fi

    _reorder "$alphabet" "$salt"
    alphabet="$__RETURN"
    _ceil "$len_alphabet" "$RATIO_GUARDS"
    local num_guards=$__RETURN
    if (( len_alphabet < 3 )); then
        guards="${separators:0:${num_guards}}"
        separators="${separators:${num_guards}}"
    else
        guards="${alphabet:0:${num_guards}}"
        alphabet="${alphabet:${num_guards}}"
    fi

    __RETURN=("$alphabet" "$separators" "$guards")
}

# Verify that we're only dealing with unsigned ints
_verify_integers() {
    if ! [[ "$1" =~ ^[0-9\ ]+$ ]]; then
        echo "error: only unsigned integers are supported" >&2
        exit 1
    fi
}

# Hashids encode function
encode() {
    local salt
    local min_length
    local alphabet

    local OPTIND=0
    while getopts "s:a:l:" opt; do
        case $opt in
            s) salt="$OPTARG";;
            a) alphabet="$OPTARG";;
            l) min_length="$OPTARG";;
        esac
    done

    shift $(( OPTIND - 1 ))

    _getparams "$salt" "$min_length" "$alphabet"
    local params=("${__RETURN[@]}")
    alphabet="${params[0]}"
    local separators="${params[1]}"
    local guards="${params[2]}"

    if [[ -z "$*" ]]; then
        echo "error: nothing to encode" >& 2
        exit 1
    fi

    _verify_integers "$*"
    _encode "$*" "$salt" "$min_length" "$alphabet" "$separators" "$guards"
}

# Hashids decode function
decode() {
    local hashid
    local min_length
    local salt
    local alphabet

    local OPTIND=0
    while getopts "s:a:l:" opt; do
        case $opt in
            s) salt="$OPTARG";;
            a) alphabet="$OPTARG";;
            l) min_length="$OPTARG";;
        esac
    done
    shift $(( OPTIND - 1 ))

    local hashid="$1"

    if [[ -z "$hashid" ]]; then
        echo "error: hashid required" >&2
        exit 1
    fi

    _getparams "$salt" "$min_length" "$alphabet"
    local params=("${__RETURN[@]}")
    alphabet="${params[0]}"
    local separators="${params[1]}"
    local guards="${params[2]}"

    _decode "$hashid" "$salt" "$alphabet" "$separators" "$guards"
}

# Print usage and exit
usage() {
    local scriptname="${0##*/}"
cat <<- EOF
usage: $scriptname (-e|-d) [-s SALT -l MIN_LENGTH -a ALPHABET] (hashid|ints)
    -e <encode>
    -d <decode>
    -s SALT (default: "$DEFAULT_SALT")
    -l MIN_LENGTH (default: $MIN_LENGTH)
    -a ALPHABET (default: $ALPHABET)
    -h <help>

Example:

  Encoding:
  $ $scriptname -e -s MySalt 25 46 57
  1liJyCK1

  Decoding:
  $ $scriptname -d -s MySalt 1liJyCK1
  25
  46
  57

EOF
exit 0
}

# Main entrypoint
main() {
    local mode
    local salt="$DEFAULT_SALT"
    local min_length="$MIN_LENGTH"
    local alphabet="$ALPHABET"

    local OPTIND=0
    while getopts "s:l:a:edh" opt; do
        case $opt in
            s) salt="$OPTARG";;
            l) min_length="$OPTARG";;
            a) alphabet="$OPTARG";;
            e) mode="encode";;
            d) mode="decode";;
            h) usage;;
            *) echo "error: unknown option $opt" >&2; exit 1;;
        esac
    done

    if (( OPTIND == 1 )); then
        usage
    fi

    shift $(( OPTIND - 1 ))

    if [[ -z "$mode" ]]; then
        echo "error: need a mode.  either -e (encode) or -d (decode)" >&2
        exit 1
    fi

    case "$mode" in
        encode) encode -s "$salt" -a "$alphabet" -l "$min_length" "$@";;
        decode) decode -s "$salt" -a "$alphabet" -l "$min_length" "$@";;
    esac
}

main "${@}"
