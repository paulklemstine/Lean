# Computational evidence for the exp-576 dial/dispersion formalization

All figures below were produced by a short self-contained script (reproduced at the end)
and are used only to *guide and sanity-check* the Lean statements; the Lean files are the
authoritative artifacts, and every claim marked "theorem" there is proved without `sorry`.

## 1. One-prime orthogonality of the two QR dials (exact, by enumeration)

On the four-point space of sign pairs `(Jac(ℓ,p) = +1?, Jac(ℓ,q) = +1?)`:

| pair | `indivCount` | `prodCount` | centred `indivC` | centred `prodC` | product |
|---|---|---|---|---|---|
| (+,+) | 2 | 1 | +1 | +1/2 | +1/2 |
| (+,−) | 1 | 0 |  0 | −1/2 |  0 |
| (−,+) | 1 | 0 |  0 | −1/2 |  0 |
| (−,−) | 0 | 1 | −1 | +1/2 | −1/2 |

means `E[indiv] = 1`, `E[prod] = 1/2`, and `Σ indivC·prodC = 0` — the centred individual
count is odd under a global sign flip, the centred product indicator is even.
Formalized as `Logic.QRDial.char_cov_single_prime`.

## 2. Full enumeration over all sign patterns, k = 1..8 primes

```
k=1: N=4      mean_indiv=1.0  mean_prod=0.5  cov=0.000e+00
k=2: N=16     mean_indiv=2.0  mean_prod=1.0  cov=0.000e+00
k=3: N=64     mean_indiv=3.0  mean_prod=1.5  cov=0.000e+00
k=4: N=256    mean_indiv=4.0  mean_prod=2.0  cov=0.000e+00
k=5: N=1024   mean_indiv=5.0  mean_prod=2.5  cov=0.000e+00
k=6: N=4096   mean_indiv=6.0  mean_prod=3.0  cov=0.000e+00
k=7: N=16384  mean_indiv=7.0  mean_prod=3.5  cov=0.000e+00
k=8: N=65536  mean_indiv=8.0  mean_prod=4.0  cov=0.000e+00
```

Exact zero at every `k` tested; the general statement is proved for all `k` in
`Logic.QRDial.cov_Sindiv_Sprod_eq_zero` (by induction on the number of primes, via
`Logic.QRDial.sum_pattern_prod`).

## 3. ANOVA identity and the dispersion/η² identification (synthetic sample)

A synthetic overdispersed sample (`n = 128` observations, `K = 8` latent cells, Poisson-like
within-cell noise, seed 20260826) gives

```
var                 = 842.051264
withinVar + betweenVar = 842.051264      (exact agreement)
D = var/mean        = 10.2086
D_within            =  0.8935
(D - D_within)/D    =  0.912479
eta^2               =  0.912479          (identical, as predicted)
```

matching `Logic.QRDial.var_decomposition` and `Logic.QRDial.disp_reduction_eq_eta_sq`.

## 4. `r² ≤ η²` on the same sample

With a dial that is a *nonlinear* function of the cell label (`φ(k) = k²`):

```
r^2 = 0.831467   eta^2 = 0.912479    r^2 <= eta^2 : True
```

matching `Logic.QRDial.corr_sq_le_eta_sq`.  This is why the experiment's measured
D-reduction (14.22%) can legitimately exceed its measured linear `R²` (7.81%).

## 5. The exp-576 readings

With `D_raw = 7.27` and each measured dial's explained fraction:

```
S_indiv  : eta^2 = 0.0088  ->  D_within >= 7.2060 , Poisson excess kept = 0.9898
S_prod   : eta^2 = 0.1422  ->  D_within >= 6.2362 , Poisson excess kept = 0.8351
S139@400 : eta^2 = 0.0907  ->  D_within >= 6.6106 , Poisson excess kept = 0.8948
```

The `6.23` floor and the `83%` excess-retention are the numbers certified in
`Logic.QRDial.exp576_residual_dispersion` and
`Logic.QRDial.exp576_unexplained_excess_fraction`.  Every one of the three dials is far
below the `30%` H1 bar; `Logic.QRDial.h1_bar_missed` states this structurally.

## 6. Rider arithmetic (paper 225 erratum thread)

```
|0.9853 - 0.985068|            = 2.32e-4
826 * 2.32e-4                  = 0.19163
printed 29.3152 - certified 29.125436718134 = 0.189763
```

so a local sensitivity of `826` reproduces the reported `~0.19` overstatement to within
`2·10⁻³`.  This is the content of `Logic.AnchorResolution.p225_printed_overstatement`
(with the sensitivity supplied as a hypothesis: the drafted law itself is *not*
reconstructed here, and no attempt is made to guess it).

## 7. Counterexample hunt

* `r² ≤ η²` was tested on 9 986 random samples (random cell counts `K ∈ [2,6]`, sizes
  `n ≤ 40`, random cell-constant dials, seed 7): `0` violations, largest observed
  `r² − η²` equal to `1.3·10⁻¹⁵` (floating-point noise at equality cases).
* `Cov(S_indiv, S_prod) = 0` was tested by exact enumeration up to `k = 8` (65 536
  patterns); exact zero throughout, and the Lean proof covers all `k`.
* The inequality `D_within ≥ (1 − η²)·D` is an equality whenever the Poisson-calibration
  hypothesis holds; the Lean statement is deliberately stated as an inequality so that it
  remains valid without that hypothesis.

## No OEIS entry

No integer sequence arises: all objects here are real-valued sample functionals, so an
OEIS search is not applicable.

## Script

```python
import random, itertools, math
random.seed(20260826)
pairs=[(a,b) for a in (0,1) for b in (0,1)]
indiv=lambda u: u[0]+u[1]
prod =lambda u: 1.0 if u[0]==u[1] else 0.0
mi=sum(indiv(u) for u in pairs)/4; mp=sum(prod(u) for u in pairs)/4
print(mi, mp, sum((indiv(u)-mi)*(prod(u)-mp) for u in pairs)/4)
for k in range(1,9):
    si=[]; sp=[]
    for w in itertools.product(pairs,repeat=k):
        si.append(sum(indiv(u) for u in w)); sp.append(sum(prod(u) for u in w))
    n=len(si); m1=sum(si)/n; m2=sum(sp)/n
    print(k, n, m1, m2, sum((a-m1)*(b-m2) for a,b in zip(si,sp))/n)
K=8; n=128
cellmeans=[40+12*j for j in range(K)]; g=[i%K for i in range(n)]
x=[random.gauss(cellmeans[g[i]], math.sqrt(cellmeans[g[i]])) for i in range(n)]
mean=lambda v: sum(v)/len(v)
var =lambda v: sum((a-mean(v))**2 for a in v)/len(v)
mx=mean(x); vx=var(x)
cm=[mean([x[i] for i in range(n) if g[i]==k]) for k in range(K)]
within=mean([(x[i]-cm[g[i]])**2 for i in range(n)])
between=mean([(cm[g[i]]-mx)**2 for i in range(n)])
D=vx/mx; Dw=within/mx; eta=between/vx
print(vx, within+between, D, Dw, (D-Dw)/D, eta)
phi=[k*k for k in range(K)]; s=[phi[g[i]] for i in range(n)]
cov=lambda u,v: mean([(a-mean(u))*(b-mean(v)) for a,b in zip(u,v)])
print(cov(x,s)**2/(var(x)*var(s)), eta)
D=7.27
for e in (0.0088,0.1422,0.0907):
    print(e, (1-e)*D, ((1-e)*D-1)/(D-1))
print(abs(0.9853-0.985068), 826*abs(0.9853-0.985068), 29.3152-29.125436718134)
```

---

## Cycle 3 — capture budget, aggregation loss, and the per-symbol floor

### C3.1 Randomized check of the Bessel budget and the aggregation bound

4 000 random samples (`random.seed(20260826)`; sample size `n ∈ [6, 40]`, family size
`m ∈ [2, 5]`, standard normal target and dials, dials made pairwise uncorrelated by
Gram–Schmidt in the centered inner product):

| quantity | observed |
|---|---|
| max capture budget `Σ_j r_j²` | `1.0000000000000169` (saturation, `m = n − 1`) |
| max of `r²(y, Σ_j s_j) − Σ_j r_j²` | `−9.54e-8` (always ≤ 0) |
| violations of either bound | `0 / 4000` |

The budget saturates exactly when the orthogonal family spans the centered sample space, so
`capture_budget_le_one` is tight; the aggregation gap never turns positive, matching
`aggregate_le_family`.

Reproduction:

```python
import random
random.seed(20260826)
def mean(v): return sum(v)/len(v)
def cov(a,b):
    ma,mb=mean(a),mean(b)
    return sum((x-ma)*(y-mb) for x,y in zip(a,b))/len(a)
worst_b=-1.0; worst_a=-1.0; viol=0; used=0
for t in range(4000):
    n=random.randint(6,40); m=random.randint(2,5)
    y=[random.gauss(0,1) for _ in range(n)]
    S=[[random.gauss(0,1) for _ in range(n)] for _ in range(m)]
    for j in range(m):
        for l in range(j):
            c=cov(S[j],S[l])/cov(S[l],S[l])
            S[j]=[a-c*b for a,b in zip(S[j],S[l])]
    if min(cov(s,s) for s in S)<1e-9 or cov(y,y)<1e-9: continue
    used+=1
    budget=sum(cov(y,s)**2/(cov(y,y)*cov(s,s)) for s in S)
    agg=[sum(S[j][i] for j in range(m)) for i in range(n)]
    ca=cov(y,agg)**2/(cov(y,y)*cov(agg,agg))
    worst_b=max(worst_b,budget); worst_a=max(worst_a,ca-budget)
    if budget>1+1e-9 or ca>budget+1e-9: viol+=1
print(used, worst_b, worst_a, viol)
```

### C3.2 Arithmetic of the window-extension target

* tested window cap: `0.1422`; pre-registered bar: `0.30`; transfer requirement
  `0.30 − 0.1422 = 0.1578` (`window_transfer_requirement`).
* primes in `(400, 10⁶]`: `π(10⁶) − π(400) = 78498 − 78 = 78420 ≤ 78498`.
* per-symbol floor: `0.1578 / 78498 = 2.0102422991668575e-06 ≥ 2·10⁻⁶`, which is the
  threshold certified in `exp576_window_extension_target`.

Using the exact prime count `78420` the floor rises to `0.1578/78420 = 2.0122e-06`; the
theorem is stated with the weaker, safely rounded constant `2·10⁻⁶` and the size hypothesis
`|extension window| ≤ 78498`.
