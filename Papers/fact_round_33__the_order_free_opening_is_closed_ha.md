# Computational Evidence — Round 33 (order-free triangle)

All numbers below come from a short Python script (reproduced at the end), run on 2026-10-19.
These are exploratory checks; the Lean file `Catalog/Bridges/OrderFreeTriangle.lean` is
what proves the claims.

## 1. Order-constrained optimum: grid search vs the proved formula
The cost exponent is `max(a, b, 1/2 - a/2 - b)` with the constraint `b ≤ ω` (order exponent `ω`).
Grid search over `[0,1]^2` with step `1/600`:

| ω | grid optimum | `max(1/5,(1-2ω)/3)` |
|---|---|---|
| 0.0000 | 0.33333 | 0.33333 |
| 0.0500 | 0.30000 | 0.30000 |
| 0.1000 | 0.26667 | 0.26667 |
| 0.1500 | 0.23333 | 0.23333 |
| 0.2000 | 0.20000 | 0.20000 |
| 0.2500 | 0.20000 | 0.20000 |
| 0.3333 | 0.20000 | 0.20000 |
| 1.0000 | 0.20000 | 0.20000 |

The value stops changing at `ω = 1/5`: past that point a larger order does not lower the
optimum. Lean: `order_constrained_lower`, `order_constrained_attained`, `orderValue_eq_fifth_iff`.

## 2. Prop 4.3 running time with polylog factors
`T(r,m) = (√N/(√r·m) + r)·L⁴ + m·L²` with `L = log₂N`, minimised on a log-grid of `(r,m)`
around the predicted optimum. Ratio to `F = N^{1/5}L^{16/5}`:

| N | min T / F |
|---|---|
| 2^40 | 2.8717 |
| 2^64 | 2.8717 |
| 2^128 | 2.8717 |
| 2^256 | 2.8717 |

The ratio is the same at every size and lies inside the proved window `[1, 3]`
(`harveyTime_lower`, `harveyTime_attained`, `free_order_optimum_pinned`).

## 3. Large-Euler-gap split
Test: every pair of distinct primes `3 ≤ p, q < 200` with `(p-1) | (q-1)`, and every base
`2 ≤ x < 30` with `p ∤ x`: 2987 cases. In all of them `p | x^{N-1} - 1`, and in all 2657
cases with `q ∤ x^{N-1} - 1` the value `gcd(x^{N-1}-1, N)` was exactly `p`. **0 counterexamples.**
Lean: `euler_gap_collapse`, `euler_gap_gcd_split`.

## OEIS
No integer sequence comes up here (the objects are real exponents), so there was nothing to look up.

## Script
```python
import math
def cost(a,b): return max(a,b,0.5-a/2-b)
G=[i/600 for i in range(0,601)]
for w in [0.0,0.05,0.1,0.15,0.2,0.25,1/3,1.0]:
    best=min(cost(a,b) for a in G for b in G if b<=w+1e-12)
    print(w,best,max(0.2,(1-2*w)/3))
for bits in [40,64,128,256]:
    N=2.0**bits; L=bits; F=N**0.2*L**3.2; best=float('inf')
    for i in range(-60,61):
      r=N**0.2*L**-0.8*2**(i/10)
      for j in range(-60,61):
        m=N**0.2*L**1.2*2**(j/10)
        best=min(best,(math.sqrt(N)/(math.sqrt(r)*m)+r)*L**4+m*L**2)
    print(bits,best/F)
def isprime(n): return n>1 and all(n%d for d in range(2,int(n**.5)+1))
P=[p for p in range(3,200) if isprime(p)]
cnt=split=viol=0
for p in P:
  for q in P:
    if q!=p and (q-1)%(p-1)==0:
      N=p*q
      for x in range(2,30):
        if x%p==0: continue
        cnt+=1; y=pow(x,N-1,N)-1
        if pow(x,N-1,p)!=1: viol+=1
        if y%q!=0:
          g=math.gcd(y,N); split+=(g==p); viol+=(g!=p)
print(cnt,split,viol)
```
