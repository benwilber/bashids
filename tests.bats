
@test "encode: empty" {
    run ./bashids -e
    [[ $status == 1 ]]
    [[ "$output" == "error: nothing to encode" ]]
}

@test "encode: default salt" {
    run ./bashids -e 1 2 3
    [[ "$output" == "o2fXhV" ]]
}

@test "encode: single number" {
    run ./bashids -e 12345
    [[ "$output" == "j0gW" ]]
    run ./bashids -e 1
    [[ "$output" == "jR" ]]
    run ./bashids -e 22
    [[ "$output" == "Lw" ]]
    run ./bashids -e 333
    [[ "$output" == "Z0E" ]]
    run ./bashids -e 9999
    [[ "$output" == "w0rR" ]]
}

@test "encode: zero hash" {
    run ./bashids -e 0
    [[ "$output" == "gY" ]]
    run ./bashids -e 100
    [[ "$output" == "g56" ]]
}

@test "encode: multiple numbers" {
    run ./bashids -e 683 94108 123 5
    [[ "$output" == "vJvi7On9cXGtD" ]]
    run ./bashids -e 1 2 3
    [[ "$output" == "o2fXhV" ]]
    run ./bashids -e 2 4 6
    [[ "$output" == "xGhmsW" ]]
    run ./bashids -e 99 25
    [[ "$output" == "3lKfD" ]]
    
}

@test "encode: salt" {
    run ./bashids -e -s "Arbitrary string" 683 94108 123 5
    [[ "$output" == "QWyf8yboH7KT2" ]]
    run ./bashids -e -s "Arbitrary string" 1 2 3
    [[ "$output" == "neHrCa" ]]
    run ./bashids -e -s "Arbitrary string" 2 4 6
    [[ "$output" == "LRCgf2" ]]
    run ./bashids -e -s "Arbitrary string" 99 25
    [[ "$output" == "JOMh1" ]]
}

@test "encode: alphabet" {
    run ./bashids -e -a '!''"''#%&'"'"',-/0123456789:;<=>ABCDEFGHIJKLMNOPQRSTUVWXYZ_`abcdefghijklmnopqrstuvwxyz~' 2839 12 32 5
    [[ "$output" == "_nJUNTVU3" ]]
    run ./bashids -e -a '!''"''#%&'"'"',-/0123456789:;<=>ABCDEFGHIJKLMNOPQRSTUVWXYZ_`abcdefghijklmnopqrstuvwxyz~' 1 2 3
    [[ "$output" == "7xfYh2" ]]
    run ./bashids -e -a '!''"''#%&'"'"',-/0123456789:;<=>ABCDEFGHIJKLMNOPQRSTUVWXYZ_`abcdefghijklmnopqrstuvwxyz~' 23832
    [[ "$output" == "Z6R>" ]]
    run ./bashids -e -a '!''"''#%&'"'"',-/0123456789:;<=>ABCDEFGHIJKLMNOPQRSTUVWXYZ_`abcdefghijklmnopqrstuvwxyz~' 99 25
    [[ "$output" == "AYyIB" ]]
}

@test "encode: minimum length" {
    run ./bashids -e -l 25 7452 2967 21401
    [[ "$output" == "pO3K69b86jzc6krI416enr2B5" ]]
    run ./bashids -e -l 25 1 2 3
    [[ "$output" == "gyOwl4B97bo2fXhVaDR0Znjrq" ]]
    run ./bashids -e -l 25 6097
    [[ "$output" == "Nz7x3VXyMYerRmWeOBQn6LlRG" ]]
    run ./bashids -e -l 25 99 25
    [[ "$output" == "k91nqP3RBe3lKfDaLJrvy8XjV" ]]
}

@test "encode: all parameters" {
    run ./bashids -e -s "arbitrary salt" -l 16 -a "abcdefghijklmnopqrstuvwxyz" 7452 2967 21401
    [[ "$output" == "wygqxeunkatjgkrw" ]]
    run ./bashids -e -s "arbitrary salt" -l 16 -a "abcdefghijklmnopqrstuvwxyz" 1 2 3
    [[ "$output" == "pnovxlaxuriowydb" ]]
    run ./bashids -e -s "arbitrary salt" -l 16 -a "abcdefghijklmnopqrstuvwxyz" 60125
    [[ "$output" == "jkbgxljrjxmlaonp" ]]
    run ./bashids -e -s "arbitrary salt" -l 16 -a "abcdefghijklmnopqrstuvwxyz" 99 25
    [[ "$output" == "erdjpwrgouoxlvbx" ]]
}

@test "encode: alphabet without standard separators" {
    run ./bashids -e -a "abdegjklmnopqrvwxyzABDEGJKLMNOPQRVWXYZ1234567890" 7452 2967 21401
    [[ "$output" == "X50Yg6VPoAO4" ]]
    run ./bashids -e -a "abdegjklmnopqrvwxyzABDEGJKLMNOPQRVWXYZ1234567890" 1 2 3
    [[ "$output" == "GAbDdR" ]]
    run ./bashids -e -a "abdegjklmnopqrvwxyzABDEGJKLMNOPQRVWXYZ1234567890" 60125
    [[ "$output" == "5NMPD" ]]
    run ./bashids -e -a "abdegjklmnopqrvwxyzABDEGJKLMNOPQRVWXYZ1234567890" 99 25
    [[ "$output" == "yGya5" ]]
}

@test "encode: alphabet with two standard separators" {
    run ./bashids -e -a "abdegjklmnopqrvwxyzABDEGJKLMNOPQRVWXYZ1234567890uC" 7452 2967 21401
    [[ "$output" == "GJNNmKYzbPBw" ]]
    run ./bashids -e -a "abdegjklmnopqrvwxyzABDEGJKLMNOPQRVWXYZ1234567890uC" 1 2 3
    [[ "$output" == "DQCXa4" ]]
    run ./bashids -e -a "abdegjklmnopqrvwxyzABDEGJKLMNOPQRVWXYZ1234567890uC" 60125
    [[ "$output" == "38V1D" ]]
    run ./bashids -e -a "abdegjklmnopqrvwxyzABDEGJKLMNOPQRVWXYZ1234567890uC" 99 25
    [[ "$output" == "373az" ]]
}

@test "encode: negative numbers" {
    run ./bashids -e 1 -2 3
    [[ $status == 1 ]]
    [[ "$output" == "error: only unsigned integers are supported" ]]
}

@test "encode: float numbers" {
    run ./bashids -e 1 2.5 3
    [[ $status == 1 ]]
    [[ "$output" == "error: only unsigned integers are supported" ]]
}

@test "decode: empty" {
    run ./bashids -d
    [[ $status  ==  1 ]]
    [[ "$output" == "error: hashid required" ]]
}

@test "decode: default salt" {
    run ./bashids -d o2fXhV
    [[ "${lines[0]}" == 1 ]]
    [[ "${lines[1]}" == 2 ]]
    [[ "${lines[2]}" == 3 ]]
}

@test "decode: single number" {
    run ./bashids -d j0gW
    [[ "$output" == 12345 ]]
    run ./bashids -d jR
    [[ "$output" == 1 ]]
    run ./bashids -d Lw
    [[ "$output" == 22 ]]
    run ./bashids -d Z0E
    [[ "$output" == 333 ]]
    run ./bashids -d w0rR
    [[ "$output" == 9999 ]]
}

@test "decode: multiple numbers" {
    run ./bashids -d vJvi7On9cXGtD
    [[ "${lines[0]}" ==  683 ]]
    [[ "${lines[1]}" ==  94108 ]]
    [[ "${lines[2]}" ==  123 ]]
    [[ "${lines[3]}" ==  5 ]]
    run ./bashids -d o2fXhV
    [[ "${lines[0]}" ==  1 ]]
    [[ "${lines[1]}" ==  2 ]]
    [[ "${lines[2]}" ==  3 ]]
    run ./bashids -d xGhmsW
    [[ "${lines[0]}" ==  2 ]]
    [[ "${lines[1]}" ==  4 ]]
    [[ "${lines[2]}" ==  6 ]]
    run ./bashids -d 3lKfD
    [[ "${lines[0]}" ==  99 ]]
    [[ "${lines[1]}" ==  25 ]]
}

@test "decode: salt" {
    run ./bashids -d -s "Arbitrary string" QWyf8yboH7KT2
    [[ "${lines[0]}" == 683 ]]
    [[ "${lines[1]}" == 94108 ]]
    [[ "${lines[2]}" == 123 ]]
    [[ "${lines[3]}" == 5 ]]
    run ./bashids -d -s "Arbitrary string" neHrCa
    [[ "${lines[0]}" == 1 ]]
    [[ "${lines[1]}" == 2 ]]
    [[ "${lines[2]}" == 3 ]]
    run ./bashids -d -s "Arbitrary string" LRCgf2
    [[ "${lines[0]}" == 2 ]]
    [[ "${lines[1]}" == 4 ]]
    [[ "${lines[2]}" == 6 ]]
    run ./bashids -d -s "Arbitrary string" JOMh1
    [[ "${lines[0]}" == 99 ]]
    [[ "${lines[1]}" == 25 ]]
}

@test "decode: alphabet" {
    run ./bashids -d -a '!''"''#%&'"'"',-/0123456789:;<=>ABCDEFGHIJKLMNOPQRSTUVWXYZ_`abcdefghijklmnopqrstuvwxyz~' _nJUNTVU3
    [[ "${lines[0]}" == 2839 ]]
    [[ "${lines[1]}" == 12 ]]
    [[ "${lines[2]}" == 32 ]]
    [[ "${lines[3]}" == 5 ]]
    run ./bashids -d -a '!''"''#%&'"'"',-/0123456789:;<=>ABCDEFGHIJKLMNOPQRSTUVWXYZ_`abcdefghijklmnopqrstuvwxyz~' 7xfYh2
    [[ "${lines[0]}" == 1 ]]
    [[ "${lines[1]}" == 2 ]]
    [[ "${lines[2]}" == 3 ]]
    run ./bashids -d -a '!''"''#%&'"'"',-/0123456789:;<=>ABCDEFGHIJKLMNOPQRSTUVWXYZ_`abcdefghijklmnopqrstuvwxyz~' "Z6R>"
    [[ "${lines[0]}" == 23832 ]]
    run ./bashids -d -a '!''"''#%&'"'"',-/0123456789:;<=>ABCDEFGHIJKLMNOPQRSTUVWXYZ_`abcdefghijklmnopqrstuvwxyz~' AYyIB
    [[ "${lines[0]}" == 99 ]]
    [[ "${lines[1]}" == 25 ]]
}

@test "decode: minimum length" {
    run ./bashids -d -l 25 pO3K69b86jzc6krI416enr2B5
    [[ "${lines[0]}" == 7452 ]]
    [[ "${lines[1]}" == 2967 ]]
    [[ "${lines[2]}" == 21401 ]]
    run ./bashids -d -l 25 gyOwl4B97bo2fXhVaDR0Znjrq
    [[ "${lines[0]}" == 1 ]]
    [[ "${lines[1]}" == 2 ]]
    [[ "${lines[2]}" == 3 ]]
    run ./bashids -d -l 25 Nz7x3VXyMYerRmWeOBQn6LlRG
    [[ "${lines[0]}" == 6097 ]]
    run ./bashids -d -l 25 k91nqP3RBe3lKfDaLJrvy8XjV
    [[ "${lines[0]}" == 99 ]]
    [[ "${lines[1]}" == 25 ]]
}

@test "decode: all parameters" {
    run ./bashids -d -s "arbitrary salt" -l 16 -a abcdefghijklmnopqrstuvwxyz wygqxeunkatjgkrw
    [[ "${lines[0]}" == 7452 ]]
    [[ "${lines[1]}" == 2967 ]]
    [[ "${lines[2]}" == 21401 ]]
    run ./bashids -d -s "arbitrary salt" -l 16 -a abcdefghijklmnopqrstuvwxyz pnovxlaxuriowydb
    [[ "${lines[0]}" == 1 ]]
    [[ "${lines[1]}" == 2 ]]
    [[ "${lines[2]}" == 3 ]]
    run ./bashids -d -s "arbitrary salt" -l 16 -a abcdefghijklmnopqrstuvwxyz jkbgxljrjxmlaonp
    [[ "${lines[0]}" == 60125 ]]
    run ./bashids -d -s "arbitrary salt" -l 16 -a abcdefghijklmnopqrstuvwxyz erdjpwrgouoxlvbx
    [[ "${lines[0]}" == 99 ]]
    [[ "${lines[1]}" == 25 ]]
}

@test "decode: invalid hash" {
    run ./bashids -d -a abcdefghijklmnop qrstuvwxyz
    [[ $status == 1 ]]
    [[ "$output" == "error: invalid hashid" ]]
}

@test "decode: alphabet without standard separators" {
    run ./bashids -d -a abdegjklmnopqrvwxyzABDEGJKLMNOPQRVWXYZ1234567890 X50Yg6VPoAO4
    [[ "${lines[0]}" == 7452 ]]
    [[ "${lines[1]}" == 2967 ]]
    [[ "${lines[2]}" == 21401 ]]
    run ./bashids -d -a abdegjklmnopqrvwxyzABDEGJKLMNOPQRVWXYZ1234567890 GAbDdR
    [[ "${lines[0]}" == 1 ]]
    [[ "${lines[1]}" == 2 ]]
    [[ "${lines[2]}" == 3 ]]
    run ./bashids -d -a abdegjklmnopqrvwxyzABDEGJKLMNOPQRVWXYZ1234567890 5NMPD
    [[ "${lines[0]}" == 60125 ]]
    run ./bashids -d -a abdegjklmnopqrvwxyzABDEGJKLMNOPQRVWXYZ1234567890 yGya5
    [[ "${lines[0]}" == 99 ]]
    [[ "${lines[1]}" == 25 ]]
}

@test "decode: alphabet with two standard separators" {
    run ./bashids -d -a abdegjklmnopqrvwxyzABDEGJKLMNOPQRVWXYZ1234567890uC GJNNmKYzbPBw
    [[ "${lines[0]}" == 7452 ]]
    [[ "${lines[1]}" == 2967 ]]
    [[ "${lines[2]}" == 21401 ]]
    run ./bashids -d -a abdegjklmnopqrvwxyzABDEGJKLMNOPQRVWXYZ1234567890uC DQCXa4
    [[ "${lines[0]}" == 1 ]]
    [[ "${lines[1]}" == 2 ]]
    [[ "${lines[2]}" == 3 ]]
    run ./bashids -d -a abdegjklmnopqrvwxyzABDEGJKLMNOPQRVWXYZ1234567890uC 38V1D
    [[ "${lines[0]}" == 60125 ]]
    run ./bashids -d -a abdegjklmnopqrvwxyzABDEGJKLMNOPQRVWXYZ1234567890uC 373az
    [[ "${lines[0]}" == 99 ]]
    [[ "${lines[1]}" == 25 ]]
}
