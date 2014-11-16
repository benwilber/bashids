
@test "alphabet too small" {
    ./bashids -e -s salt -a abcabc 1 2 3
    [ "$status" -eq 1 ]
}