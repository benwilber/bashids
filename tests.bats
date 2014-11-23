
@test "encrypt: alphabet too small" {
    run ./bashids -e -s salt -a abcabc 1 2 3
    [[ $status == 1 ]]
    [[ "$output" == "error: alphabet must contain at least 16 unique characters" ]]
}

@test "encrypy: no salt" {
    run ./bashids -e 1 2 3
    [[ $status == 1 ]]
    [[ "$output" == "error: salt (-s) required" ]]
}

@test "encrypt: nothing to hash" {
    run ./bashids -e -s salt
    [[ $status == 1 ]]
    [[ "$output" == "error: nothing to hash" ]]
}

@test "encrypt: single number" {
    run ./bashids -e -s salt 1
    [[ $status == 0 ]]
    [[ "$output" == "XG" ]]

    run ./bashids -e -s salt 12345
    [[ $status == 0 ]]
    [[ "$output" == "X4j1" ]]
}

@test "encrypt: multiple numbers" {
    run ./bashids -e -s salt 1 2 3
    [[ $status == 0 ]]
    [[ "$output" == "JWiouV" ]]

    run ./bashids -e -s salt 683 94108 123 5
    [[ $status == 0 ]]
    [[ "$output" == "1eMToyKzsRAfO" ]]
}

@test "encrypt: salt with spaces" {
    run ./bashids -e -s "salt with spaces" 683 94108 123 5
    [[ $status == 0 ]]
    [[ "$output" == "BdQH67Zyhodtg" ]]
}

@test "encrypt: custom alphabet" {
    run ./bashids -e -s salt -a "132759qeupafgGhlZZXxCvVbnM" 2839 12 32 5
    [[ $status == 0 ]]
    [[ "$output" == "G5leh7hMGfv" ]]
}

@test "encrypt: minimum length" {
    run ./bashids -e -s salt -l 20 2839 12 32 5
    [[ $status == 0 ]]
    [[ "$output" == "G5leh7hMGfv" ]]
}

@test "decrypt: single number" {
    run ./bashids -d -s salt XG
    [[ $status == 0 ]]
    [[ "$output" == "1" ]]  

    run ./bashids -d -s salt X4j1
    [[ $status == 0 ]]
    [[ "$output" == "12345" ]]
}

@test "decrypt: multiple numbers" {
    run ./bashids -d -s salt JWiouV
    [[ $status == 0 ]]
    [[ ${lines[0]} == 1 ]]
    [[ ${lines[1]} == 2 ]]
    [[ ${lines[2]} == 3 ]]
}




