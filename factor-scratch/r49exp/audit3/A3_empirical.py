import random
from sympy import primerange
from collections import Counter
from math import log2

# ---- TEST 1: law of s = v2(p-1) over primes. NOTE says P(s=j)=2^-(j+1); correct is 2^-j.
# At the TIGHTEST case: j=1 (half of all primes). 2^-2=0.25 vs 2^-1=0.50.
primes=list(primerange(3, 3000000))
print(f"primes: {len(primes)}")
c=Counter(int(log2(p-1)) - (1 if (p-1)%4==0 else 0) for p in [])
def v2(n):
    e=0
    while n%2==0: n//=2; e+=1
    return e
s=Counter(v2(p-1) for p in primes)
print(" s   count        P(s)      2^-j      2^-(j+1)")
for j in range(1,8):
    P=s[j]/len(primes)
    print(f" {j}  {s[j]:8d}  {P:.6f}   {2**-j:.6f}   {2**-(j+1):.6f}   {'<- NOTE WRONG' if abs(P-2**-(j+1))<abs(P-2**-j) else ''}")
print(f"\n TOTAL P(s) over j=1..7 = {sum(s[j] for j in range(1,8))/len(primes):.6f}  (a probability law must total 1.0)")
print(f" NOTE law sums to {sum(2**-(j+1) for j in range(1,8)):.6f} over the same range -> MASS DEFICIT")
