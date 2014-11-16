bashids
=======

Pure Bash implementation of the `hashid` algorithm from [Hashids.org](http://hashids.org/)

### Usage
#### Encryption
```
bashids -e -s My-Super-Long-Secret 25 36 47
```
Output
```
kws4c7k
```
#### Decryption
```
bashids -d -s My-Super-Long-Secret kws4c7k
```
```
25
36
47
```
