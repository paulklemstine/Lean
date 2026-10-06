# Computational evidence — degree-nine rung, \(K=\mathbb{Q}(\zeta_{19})^+\)

**Status:** the numbers in sections 1–4 come from a standalone pure-Python script (reproduced
in section 6). They are exploratory evidence and **are not Lean-verified**. Every *exact* law
listed is proved separately in Lean (see the theorem names). The Lean proofs do not depend on
this script.

## 1. Splitting-type densities (primes \(p<4.3\cdot10^6\), \(p\neq 19\): 302,823 primes)

Type \(f(p)\) = order of \(p\) in \((\mathbb{Z}/19)^\times/\{\pm1\}\) = `orderOf (p²)`.

| f | count | empirical | predicted \(\varphi(f)/9\) (Lean: `degreeNine_density_*`) |
|---|------:|---------:|------:|
| 1 | 33,699 | 0.11128 | 1/9 = 0.11111 |
| 3 | 67,301 | 0.22225 | 2/9 = 0.22222 |
| 9 | 201,823 | 0.66647 | 6/9 = 0.66667 |

The empirical entropy over these primes is 1.22487 bits. The exact value is
\(H(T)=\tfrac43\log_2 3-\tfrac89 = 1.224394\ldots\) bits (Lean: `degreeNine_entropy`, and
`degreeNine_entropy_bits` proves \(1.22439<H/\log 2<1.22441\)).

## 2. Factor-pattern cross-check (first 400 odd unramified primes)

Minimal polynomial of \(2\cos(2\pi/19)\):
\(x^9+x^8-8x^7-7x^6+21x^5+15x^4-20x^3-10x^2+5x+1\).
A distinct-degree factorisation over \(\mathbb{F}_p\), implemented independently in pure Python,
gives the pattern \([f^{9/f}]\) for **400/400** primes. On the same primes, the fixed-root
readout against the type gives `{(nr=9, f=1): 43, (nr=0, f=3): 86, (nr=0, f=9): 271}`. Types 3
and 9 both have nr = 0, so nr cannot tell them apart. Lean proves this:
`card_fixed_translation`, `minimalPeriod_translation` and
`degreeNine_fixedRoot_not_determines`.

## 3. Ladder table (exact totient distributions)

| ℓ | m | type law \(\varphi(d)/m\) | H bits | nr lossless? (Lean: `fixedRoot_determines_iff`) |
|---|---|---|---|---|
| 5 | 2 | 1/2, 1/2 | 1.0000 | yes (prime) |
| 7 | 3 | 1/3, 2/3 | 0.9183 | yes |
| 11 | 5 | 1/5, 4/5 | 0.7219 | yes |
| 13 | 6 | 1/6,1/6,1/3,1/3 | 1.9183 = 1 + 0.9183 | no |
| 17 | 8 | 1/8,1/8,1/4,1/2 | 1.7500 | no |
| 19 | 9 | 1/9, 2/9, 6/9 | 1.2244 | **no** |
| 23 | 11 | 1/11, 10/11 | 0.4395 | yes |
| 31 | 15 | … | 1.6402 = 0.9183 + 0.7219 | no |
| 37 | 18 | … | 2.2244 = 1 + 1.2244 | no |

The additivity pattern (6 = 2·3, 15 = 3·5, 18 = 2·9) suggested `totientEntropy_mul`, which is
now proved in Lean. The rung for 37 is exactly one bit above the rung for 19
(`degreeEighteen_entropy`).

**Correction to the ladder narrative.** The fixed-root readout already loses information at
degrees 4, 6 and 8, not first at degree 9. In general it loses information exactly when the
degree is composite.

## 4. Semiprime readouts (exact enumeration over \((\mathbb{Z}/19)^\times\times(\mathbb{Z}/19)^\times\), uniform)

| quantity | exact enumeration (script) | reported | Lean |
|---|---|---|---|
| \(I(N \bmod 19;\ \text{unordered type pair})\) | **0.526502** bits | "law 0.5302", measured 0.5330 | — (not formalised) |
| which-factor extra | 0 (to 7e-15) | 0.00053 | **exactly 0**: `which_factor_extra_zero` |
| split-count \(I(N;\#\text{split})\) | 0.073775 bits | 0.0746 | closed form: `degreeNine_splitCount` |
| OR-dial \(I_s(9)\) = `semiprimeDial 9` | 0.006036 bits | "Is(9) ≈ 0.0746" | `semiprimeDial_eq` |
| \(I(p;\text{nr}) = H(1/9,8/9)\) | 0.503258 bits | — | `degreeNine_fixedRoot_info` |

**Discrepancies found:**
1. Under the uniform Chebotarev model, the exact law for the pair statistic is 0.52650 bits,
   not 0.5302. The measured 0.5330 lies above both values, which suggests finite-sample bias.
   The reported "law" may have used a different (empirical) weighting.
2. In the catalog's notation, `semiprimeDial 9` (the OR-fork dial) is 0.0060 bits, so the
   claim "split-count 0.0746 ≈ Is(9)" holds only if "Is" refers to the split-count dial. The
   exact relation, proved in Lean, is
   \(I(N;\#\text{split}) = I_s(n) + \eta(1/n^2)+\eta(2(n-1)/n^2)-\eta((2n-1)/n^2)\).
3. The script finds that the C₉-level model and the full \(N \bmod 19\) model give identical
   values (thickening). This is proved in Lean for single primes (`ladder_square_pins`), but
   not for the semiprime observable.

## 5. Counterexample hunt

- Density law \(\#\{g:\operatorname{ord}(g^2)=d\}=2\varphi(d)\): checked for every odd prime
  \(\ell\le 37\). No counterexample, as expected, since the law is proved in Lean for all
  cyclic groups of even order.
- Fixed-root dichotomy: lossless exactly for \(m\in\{1\}\cup\text{primes}\). No counterexample
  for \(m\le 18\).

## 6. Script (pure Python, runs in ~1 s)

```python
import math, cmath
from collections import Counter
# minimal polynomial of 2cos(2pi/19)
coef=[1.0]
for j in range(1,10):
    r=2*math.cos(2*math.pi*j/19)
    new=[0.0]*(len(coef)+1)
    for i,c in enumerate(coef):
        new[i]+=c; new[i+1]-=c*r
    coef=new
f=[round(c) for c in coef]  # highest degree first
print("minpoly coeffs (deg 9 -> 0):",f)
def T(p):
    s=p*p%19
    for k in (1,3,9):
        if pow(s,k,19)==1: return k
# poly utils mod p, lists low->high
def trim(a):
    while a and a[-1]==0: a.pop()
    return a
def pmod(a,m,p):
    a=a[:]; inv=pow(m[-1],p-2,p)
    while len(a)>=len(m):
        c=a[-1]*inv%p; sh=len(a)-len(m)
        for i in range(len(m)): a[sh+i]=(a[sh+i]-c*m[i])%p
        trim(a)
    return a
def pmul(a,b,p):
    r=[0]*(len(a)+len(b)-1) if a and b else []
    for i,x in enumerate(a):
        for j,y in enumerate(b): r[i+j]=(r[i+j]+x*y)%p
    return trim(r)
def ppow(base,e,m,p):
    r=[1]; b=pmod(base,m,p)
    while e:
        if e&1: r=pmod(pmul(r,b,p),m,p)
        b=pmod(pmul(b,b,p),m,p); e>>=1
    return r
def pgcd(a,b,p):
    a=trim(a[:]); b=trim(b[:])
    while b: a,b=b,pmod(a,b,p)
    return a
def pattern(p):
    F=trim([c%p for c in reversed(f)])
    pat=[]; h=[0,1]; g=F
    for k in range(1,10):
        h=ppow(h,p,g,p) if len(g)>1 else h
        d=[(x - (1 if i==1 else 0))%p for i,x in enumerate(h+[0]*(2-len(h)))] if True else None
        hx=h[:]+[0]*max(0,2-len(h)); hx[1]=(hx[1]-1)%p; trim(hx)
        G=pgcd(g,hx,p) if hx else g
        deg=len(G)-1
        if deg>0:
            pat+= [k]*(deg//k)
            # divide g by G
            q=[];  # polynomial division
            a=g[:]; inv=pow(G[-1],p-2,p); qq=[0]*(len(a)-len(G)+1)
            while len(a)>=len(G):
                c=a[-1]*inv%p; sh=len(a)-len(G); qq[sh]=c
                for i in range(len(G)): a[sh+i]=(a[sh+i]-c*G[i])%p
                trim(a)
            g=trim(qq); h=pmod(h,g,p) if len(g)>1 else h
        if len(g)<=1: break
    return sorted(pat)
# primes
N=4300000
sieve=bytearray([1])*(N+1); sieve[0]=sieve[1]=0
for i in range(2,int(N**.5)+1):
    if sieve[i]: sieve[i*i::i]=bytearray(len(range(i*i,N+1,i)))
primes=[i for i in range(2,N+1) if sieve[i] and i!=19]
c=Counter(T(p) for p in primes)
n=len(primes)
print("unramified primes <",N,":",n)
for k in (1,3,9): print(" f=%d: count %d density %.5f predicted %.5f"%(k,c[k],c[k]/n,{1:1/9,3:2/9,9:6/9}[k]))
H=-sum(v/n*math.log2(v/n) for v in c.values())
print(" empirical H(T) bits %.5f  exact (4/3)log2(3)-8/9 = %.5f"%(H,4/3*math.log2(3)-8/9))
ok=0; bad=[]
small=[p for p in primes if p>2][:400]
for p in small:
    pat=pattern(p); k=T(p)
    if pat==[k]*(9//k): ok+=1
    else: bad.append((p,pat,k))
print("factor-pattern crosscheck: %d/400 agree; mismatches:"%ok, bad[:5])
nr=Counter((T(p)==1, T(p)) for p in small)
print("fixed-root readout vs type on the 400 primes:", dict(nr))
# ladder table
print("ladder: l, m, densities, H bits, nr lossless?")
def isprime(m): return m>1 and all(m%d for d in range(2,int(m**.5)+1))
for l in (5,7,11,13,17,19,23,29,31,37):
    m=(l-1)//2
    ds=[d for d in range(1,m+1) if m%d==0]
    phi=lambda d: sum(1 for k in range(1,d+1) if math.gcd(k,d)==1)
    dens={d:phi(d)/m for d in ds}
    Hb=-sum(v*math.log2(v) for v in dens.values())
    print(" ",l,m,{d:round(v,4) for d,v in dens.items()},round(Hb,4), m==1 or isprime(m))
# semiprime exact enumeration
def I(pairs):
    n=len(pairs);X=Counter(a for a,b in pairs);Y=Counter(b for a,b in pairs);J=Counter(pairs)
    H=lambda C:-sum(c/n*math.log2(c/n) for c in C.values())
    return H(X)+H(Y)-H(J)
G=range(1,19); P=[(p,q) for p in G for q in G]
print('I(N;unordered pair)',I([(p*q%19,tuple(sorted((T(p),T(q))))) for p,q in P]))
print('which-factor extra',I([(p*q%19,(T(p),T(q))) for p,q in P])-I([(p*q%19,tuple(sorted((T(p),T(q))))) for p,q in P]))
print('I(N;splitcount)',I([(p*q%19,(T(p)==1)+(T(q)==1)) for p,q in P]))
print('I(N;splitOR)',I([(p*q%19,(T(p)==1) or (T(q)==1)) for p,q in P]))
```
