import math
from math import gcd

def li(x, n=200000):
    # integral_2^x dt/log t  by Simpson on [2,x]
    a, b = 2.0, float(x)
    if n % 2: n += 1
    h = (b-a)/n
    s = 1/math.log(a) + 1/math.log(b)
    for i in range(1, n):
        t = a + i*h
        s += (4 if i % 2 else 2)/math.log(t)
    return s*h/3

def sieve(N):
    bs = bytearray([1])*(N+1)
    bs[0]=bs[1]=0
    for p in range(2,int(N**0.5)+1):
        if bs[p]:
            bs[p*p::p] = bytearray(len(bs[p*p::p]))
    return bs

N = 1<<24
bs = sieve(N)
mods = [3,4,5,7,8,11,31]
scales = [1<<20, 1<<22, 1<<24]
counts = {m: {x: {} for x in scales} for m in mods}
for m in mods:
    classes = [a for a in range(m) if gcd(a,m)==1]
    for x in scales:
        c = {a:0 for a in classes}
        counts[m][x] = c
# single pass
prim = [(m,[a for a in range(m) if gcd(a,m)==1]) for m in mods]
for p in range(2, N+1):
    if bs[p]:
        for m,_ in prim:
            r = p % m
            for x in scales:
                if p <= x:
                    d = counts[m][x]
                    if r in d: d[r]+=1

print("x, m, phi(m), Li(x)/phi, maxreldev, worstclass")
res={}
for x in scales:
    for m in mods:
        d = counts[m][x]
        phi = len(d)
        target = li(x)/phi
        devs = {a: (d[a]-target)/target for a in d}
        worst = max(devs, key=lambda a: abs(devs[a]))
        res[(x,m)] = (max(abs(v) for v in devs.values()), worst)
        print(f"2^{int(math.log2(x))}, {m}, {phi}, {target:.1f}, {max(abs(v) for v in devs.values()):.6f}, {worst}  counts={d}")
print()
print("worst-class stability across scales:")
for m in mods:
    print(m, [res[(x,m)][1] for x in scales], "maxdev:", [round(res[(x,m)][0],6) for x in scales])
