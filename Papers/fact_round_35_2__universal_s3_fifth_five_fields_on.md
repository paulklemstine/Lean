# Computational Evidence — FIVE-FIELDS-ONE-LAW (fifth field `x³ - 4x + 1`, disc 229)

**Status of this file.** The tables below come from a short Python exploration script
(reproduced at the end). They are **not** machine-verified. The claims they point to are
proved in Lean, for **all** primes, in

* `Catalog/Combinatorics/S3CubicConductor229.lean` (the arithmetic of the cubic), and
* `Catalog/Combinatorics/S3TypeChannelLaw.lean` (the exact information law).

The only finite facts checked inside Lean are the ones in `same_class_different_type`:
`461 ≡ 3 (mod 229)`, no root mod 3, and the roots 162, 368, 392 mod 461. These are
checked with `decide`.

## 1. Small cases: roots of `x³ - 4x + 1` mod p

| p | 2 | 3 | 5 | 7 | 11 | 13 | 17 | 19 | 23 | 29 | 31 | 37 | 41 | 43 | 47 | 53 |
|---|---|---|---|---|----|----|----|----|----|----|----|----|----|----|----|----|
| #roots | 1 | 0 | 0 | 1 | 0 | 1 | 0 | 0 | 1 | 1 | 1 | 3 | 1 | 0 | 1 | 3 |

Every prime in this table with exactly one root is a quadratic non-residue mod 229. All
the others (0 or 3 roots) are residues. The Lean theorem `existsUnique_root_iff_conductor`
proves this for every prime `p ∉ {2, 229}`.

## 2. Counterexample hunt for the conductor law

Over all 4203 primes `p < 40000`:

| f | D | #0 roots | #1 root | #3 roots | #2 roots | violations of "1 root ⇔ (disc/p) = −1" |
|---|---|---|---|---|---|---|
| x³ − 4x + 1 | 229 | 1398 (0.333) | 2134 (0.508) | 670 (0.159) | 1 (p = 229 only) | **0** |
| x³ − x − 1 | 23 | 1408 (0.335) | 2109 (0.502) | 685 (0.163) | 1 (p = 23 only) | **0** |

The Chebotarev densities are 1/3, 1/2 and 1/6, and the observed frequencies match them. A
root count of exactly 2 happens only at the ramified prime. This matches `third_root_ne`,
which says the root count is never 2 when `229 ≠ 0`.

## 3. The 1.0078 excess is a finite-sample bias

These are plug-in estimates of `I(p mod D ; T)` over primes `p ≤ N`. "MM" is the
Miller–Madow bias estimate `(cells − rows − cols + 1)/(2n ln 2)`.

| D | N | n | plug-in I | MM bias | corrected |
|---|---|---|---|---|---|
| 229 | 5 000 | 668 | 1.1462 | 0.0691 | 1.0771 |
| 229 | 10 000 | 1228 | 1.0583 | 0.0576 | 1.0007 |
| 229 | 20 000 | 2261 | 1.0295 | 0.0351 | 0.9944 |
| 229 | 40 000 | 4202 | 1.0142 | 0.0192 | 0.9949 |
| 23 | 40 000 | 4202 | 1.0002 | 0.0015 | 0.9986 |

The excess over 1 bit falls roughly like `1/n` and is about the size of the Miller–Madow
correction. The reported `I = 1.0078` is consistent with the exact value, **one bit**,
which is proved in Lean (`typeChannel_229_eq_one`). The bias at D = 229 is larger than at
D = 23 because the contingency table has about 10 times as many cells
(228 classes vs 22).

## 4. OEIS

The sequence of primes at which `x³ − 4x + 1` has exactly one root (2, 7, 13, 23, 29, 31,
41, 47, …) is, by the conductor law, the sequence of primes that are non-residues mod 229
(plus p = 2). This was not checked against the OEIS in this cycle.

## Script

```python
import math
from collections import Counter
N=40000
sieve=bytearray([1])*(N+1); sieve[0]=sieve[1]=0
for i in range(2,int(N**.5)+1):
    if sieve[i]: sieve[i*i::i]=bytearray(len(sieve[i*i::i]))
primes=[p for p in range(2,N+1) if sieve[p]]
def roots(p,a,b): return sum(1 for x in range(p) if (x*x*x+a*x+b)%p==0)
def leg(a,p):
    a%=p
    return 0 if a==0 else (1 if pow(a,(p-1)//2,p)==1 else -1)
def MI(pairs):
    n=len(pairs); J=Counter(pairs); A=Counter(x for x,_ in pairs); B=Counter(y for _,y in pairs)
    return sum(c/n*math.log2(c*n/(A[x]*B[y])) for (x,y),c in J.items())
for (a,b,D,disc) in [(-4,1,229,229),(-1,-1,23,-23)]:
    T={p:roots(p,a,b) for p in primes}
    viol=sum(1 for p in primes if p not in (2,D) and (T[p]==1)!=(leg(disc,p)==-1))
    print(D, Counter(T.values()), viol)
    for M in [5000,10000,20000,40000]:
        pairs=[(p%D,T[p]) for p in primes if p<=M and p!=D]
        print(M, len(pairs), MI(pairs))
```
