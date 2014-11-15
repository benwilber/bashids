#!/usr/bin/env bash


_is_uint() {
    [[ "$1" =~ ^[0-9]+$ ]]
}

_split() {
    local IFS=$2
    for i in $1; do
        echo "$i"
    done
}

_indexof() {
    local i=${1%%"$2"*}
    echo ${#i}
}

_ordinal() {
    printf "%d" "'$1"
}

_ceil() {
    echo $(( $(( $1 + $2 - 1 )) / $2 ))
}

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
            return
        fi
    done
}

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

_index_from_ratio() {
    _ceil $1 $2
}

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

_encrypt() {
    local values=$1 # Array
    local salt="$2"
    local min_length="$3"
    local alphabet="$4"
    local separators="$5"
    local guards="$6"

    local len_alphabet=${#alphabet}
    local len_separaters=${#separators}
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

_decrypt() {
    local hashid="$1"
    local salt="$2"
    local alphabet="$3"
    local separators="$4"
    local guards="$5"
}
