#!/usr/bin/env python3
"""SELF-TESTS for e7_audit.py primitives. Run before any measurement."""
import math, sys
from e7_audit import P, is_smooth, oddpart, bitlen, fisher_two_sided, wilson

fails = []
def check(name, cond, extra=""):
    print(("PASS " if cond else "FAIL ") + name + ("  " + str(extra) if extra else ""))
    if not cond:
        fails.append(name)

# 1. is_smooth at the TIGHTEST case (earned rule: test tightest, not representative)
check("is_smooth(12,2)", is_smooth(12,2) is False)
check("is_smooth(8,2)", is_smooth(8,2) is True)
check("is_smooth(2,2)", is_smooth(2,2) is True)
check("is_smooth(1,1000)", is_smooth(1,1000) is True)
check("is_smooth(0,1000)", is_smooth(0,1000) is True)
check("is_smooth(997,1000)", is_smooth(997,1000) is True)
check("is_smooth(1009,1000)", is_smooth(1009,1000) is False)
check("is_smooth(1009*1013,1000)", is_smooth(1009*1013,1000) is False)
check("is_smooth(1009*1013,1013)", is_smooth(1009*1013,1013) is True)
# cross-check against sympy
from sympy import factorint, isprime
bad=0
for n in range(2, 4000):
    B=17
    mine=is_smooth(n,B)
    ref = max(factorint(n).keys())<=B
    if mine!=ref: bad+=1
check("is_smooth == max(factorint)<=B for n<4000, B=17", bad==0, f"{bad} mismatches")
bad=0
for n in range(2,400):
    B=5; mine=is_smooth(n,B); ref=max(factorint(n).keys())<=B
    if mine!=ref: bad+=1
check("is_smooth tight B=5 n<400", bad==0, f"{bad} mismatches")

# 2. oddpart
check("oddpart(8)", oddpart(8)==1)
check("oddpart(12)", oddpart(12)==3)
check("oddpart(45)", oddpart(45)==45)

# 3. PARI class number: KNOWN VALUES (tightest case = the extreme discriminants)
for D, h in [(-3,1),(-4,1),(-7,1),(-11,1),(-19,1),(-43,1),(-67,1),(-163,1),
             (-15,2),(-20,2),(-24,2),(-35,2),(-51,2),(-52,2),(-88,2),(-91,2),
             (-115,2),(-123,2),(-148,2),(-187,2),(-232,2),(-235,2),(-267,2),
             (-403,2),(-427,2),(-163,1)]:
    got=int(P.qfbclassno(D))
    check(f"qfbclassno({D})=={h}", got==h, f"got {got}")

# 4. h(-q) is ODD for q = 3 mod 4 prime  (the Cohen-Lenstra parity advantage)
odd=0; tot=0
for q in [7,11,19,43,67,163,23,31,47,59,71,79,83,103,107,127,131,139,151,167]:
    if q%4==3 and P.isprime(q):
        tot+=1; odd += (int(P.qfbclassno(-q))%2==1)
check("h(-q) odd for all 20 primes q=3 mod 4", odd==tot, f"{odd}/{tot}")

# 5. ellcard sanity: #E(F_p) must satisfy Hasse |N-(p+1)|<=2 sqrt(p)
import random
rng=random.Random(7)
bad=0
for _ in range(200):
    p=int(P(rng.randrange(10**7,10**8)))|1
    if not P.isprime(p): continue
    a=rng.randrange(0,p); b=rng.randrange(0,p)
    if (4*a*a*a+27*b*b)%p==0: continue
    E=P.ellinit([0,0,0,a,b],p); Nc=int(P.ellcard(E))
    if abs(Nc-(p+1))>2*math.sqrt(p)+1: bad+=1
check("Hasse holds for 200 random curves", bad==0, f"{bad} violations")

# 6. EC order parity is ~50/50, NOT always odd (the confound)
ev=0; tot=0
for _ in range(400):
    p=int(P(rng.randrange(10**7,10**8)))|1
    if not P.isprime(p): continue
    a=rng.randrange(0,p); b=rng.randrange(0,p)
    if (4*a*a*a+27*b*b)%p==0: continue
    Nc=int(P.ellcard(P.ellinit([0,0,0,a,b],p)))
    tot+=1; ev += (Nc%2==0)
check("EC orders even in a real fraction (not 0)", 0.30 < ev/tot < 0.70, f"{ev}/{tot} even")

# 7. fisher + wilson
check("fisher(10,25,10,25) ~ 1", abs(fisher_two_sided(10,25,10,25)-1.0)<1e-9, fisher_two_sided(10,25,10,25))
f=fisher_two_sided(10,25,8,25); check("fisher(10,25,8,25) > 0.3", f>0.3, f)
lo,hi=wilson(10,25); check("wilson(10,25) contains 0.4", lo<0.4<hi, (lo,hi))

print()
print("FAILURES:", fails if fails else "none")
sys.exit(1 if fails else 0)