bashids
=======

Pure Bash implementation of the `hashid` algorithm from [Hashids.org](http://hashids.org/)

## Usage
```bash
$ bashids -h
usage: bashids (-e|-d) [-s SALT -l MIN_LENGTH -a ALPHABET]  (hashid|ints)
    -e <encode>
    -d <decode>
    -s SALT (default: "")
    -l MIN_LENGTH (default: 0)
    -a ALPHABET (default: abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890)
    -h <help>
```
###Encoding
```bash
$ bashids -e -s MySalt 25 46 57
1liJyCK1
```
###Decoding
```bash
$ bashids -d -s MySalt 1liJyCK1
25
46
57
```
## Tests
`bashids` uses the [bats](https://github.com/sstephenson/bats) BASH testing framework for tests.
###Running tests
```bash
$ bats ./tests.bats 
 ✓ encode: empty
 ✓ encode: default salt
 ✓ encode: single number
 ✓ encode: multiple numbers
 ✓ encode: salt
 ✓ encode: alphabet
 ✓ encode: minimum length
 ✓ encode: all parameters
 ✓ encode: alphabet without standard separators
 ✓ encode: alphabet with two standard separators
 ✓ encode: negative numbers
 ✓ encode: float numbers
 ✓ decode: empty
 ✓ decode: default salt
 ✓ decode: single number
 ✓ decode: multiple numbers
 ✓ decode: salt
 ✓ decode: alphabet
 ✓ decode: minimum length
 ✓ decode: all parameters
 ✓ decode: invalid hash
 ✓ decode: alphabet without standard separators
 ✓ decode: alphabet with two standard separators

23 tests, 0 failures
```