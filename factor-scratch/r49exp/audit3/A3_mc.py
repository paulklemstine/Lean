import random
from sympy import primerange
from math import log2
random.seed(20261003)

primes=list(primerange(1009, 4_000_000))
print(f"pool: {len(primes)} primes")
N=400000
hits=0
for _ in range(N):
    p,q=random.sample(primes,2)
    gp=gq=None
    # order via sympy
    from sympy.ntheory import n_order
    a=random.randrange(2,p); b=random.randrange(2,q)
    op=n_order(a,p); oq=n_order(b,q)
    if (op & -op) != (oq & -oq): hits+=1
rate=hits/N
print(f"MC rate = {rate:.6f}  ({hits}/{N})")
print(f"20/27    = {20/27:.6f}")
print(f"5/27     = {5/27:.6f}   <- what the NOTE's stated law literally predicts")
sig=(rate-20/27)/ ( (20/27*(1-20/27)/N) **0.5 )
print(f"z vs 20/27 = {sig:+.2f} sigma")
sig5=(rate-5/27)/((20/27*(1-20/27)/N)**0.5)
print(f"z vs 5/27  = {sig5:+.2f} sigma")
