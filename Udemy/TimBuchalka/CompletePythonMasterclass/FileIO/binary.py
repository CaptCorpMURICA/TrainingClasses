"""
    Author:         CaptCorpMURICA
    File:           binary.py
    Creation Date:  10/19/2018, 4:13 PM
    Description:    Learn how to read and write binary files
"""

with open("binary", 'bw') as bin_file:
    for i in range(17):
        bin_file.write(bytes([i]))

# Complete the same task but with one less line of code.
# with open("binary", 'bw') as bin_file:
#     bin_file.write(bytes(range(17)))

with open("binary", 'br') as binFile:
    for b in binFile:
        print(b)

print("=" * 50)

# It's very important to understand how the binary data is structured.
# Writing a variable as 'little' and reading it as 'big' does not produce the same results.

a = 65534       # FF FE
b = 65535       # FF FF
c = 65536       # 00 01 00 00
x = 2998302     # 00 2D C0 1E

with open("binary2", 'bw') as bin_file:
    bin_file.write(a.to_bytes(2, 'big'))
    bin_file.write(b.to_bytes(2, 'big'))
    bin_file.write(c.to_bytes(4, 'big'))
    bin_file.write(x.to_bytes(4, 'big'))
    bin_file.write(x.to_bytes(4, 'little'))

with open("binary2", 'br') as bin_file:
    e = int.from_bytes(bin_file.read(2), 'big')
    print(e)
    f = int.from_bytes(bin_file.read(2), 'big')
    print(f)
    g = int.from_bytes(bin_file.read(4), 'big')
    print(g)
    h = int.from_bytes(bin_file.read(4), 'big')
    print(h)
    i = int.from_bytes(bin_file.read(4), 'big')
    print(i)
