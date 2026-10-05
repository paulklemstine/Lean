# Baseline for the Coppersmith n/4-wall harness: same instance sizes.
import random, time, sys
sys.path.insert(0,'/home/raver1975/lean/Experiments/UMWWindow')
from coppersmith_lattice import gen_prime
from sympy import factorint
print("Coppersmith harness instances: n = 48, 64, 80 -> p,q of n/2 bits")
print("%-6s %-6s %-14s %-10s %s" % ("n","p bits","factorint_s","correct","VERIFIED"))
for n in [48, 64, 80]:
    while True:
        p = gen_prime(n//2); q = gen_prime(n//2); N = p*q
        if 2**(n-1) <= N < 2**n: break
    t=time.time(); f=factorint(N); el=time.time()-t
    ok = sorted(f.keys())==sorted([p,q]) and p*q==N
    print("%-6d %-6d %-14.4f %-10s %s" % (n, p.bit_length(), el, ok, all(N%k==0 for k in f)))
