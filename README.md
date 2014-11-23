bashids
=======

Pure Bash implementation of the `hashid` algorithm from [Hashids.org](http://hashids.org/)

### Usage
```
$ bashids -h
usage: bashids (-e|-d) -s SALT [-l MIN_LENGTH -a ALPHABET] (hashid|ints)
    -e <encrypt>
    -d <decrypt>
    -s SALT
    -l MIN_LENGTH (default: 2)
    -a ALPHABET (default: abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890)
    -h <help>

Example:

  Encryption:
  $ bashids -e -s MySalt 25 46 57
  1liJyCK1

  Decryption:
  $ bashids -d -s MySalt 1liJyCK1
  25
  46
  57

```