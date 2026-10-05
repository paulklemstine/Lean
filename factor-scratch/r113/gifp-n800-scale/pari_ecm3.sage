import time, sys
# Parse PARI factor matrix by explicit (row,col) indexing, with a PRIME CONTROL.
p = pari(2^300 * 7919 + 1)
f = p.factor(1)
print("raw repr:", f, "| nrows:", f.nrows(), "| ncols:", f.ncols())
for i in range(f.nrows()):
    print("  row",i,"base=",ZZ(f[i,0]).nbits(),"bits  exp=",f[i,1])
