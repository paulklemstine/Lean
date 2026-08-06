# Computational evidence: integrated information of tensor network states

All numbers below were produced with an exact-rational script (Gaussian
elimination over `ℚ` for ranks; closed-form eigenvalues for rank-≤2 density
matrices) before the Lean formalization was written.  They are *evidence*, not
verification: the verified statements are the Lean theorems in
`Catalog/Novelty/IITTensorNetwork*.lean`.

## Setting

A pure state of a chain of `n` sites with local dimension `d` is a function
`ψ : (Fin n → Fin d) → ℂ`.  Cutting the chain after site `l` gives a coefficient
matrix `M_l`, whose rank is the Schmidt rank across the cut.  For a pure state,

`I(A : B) = S(ρ_A) + S(ρ_B) = 2 S(ρ_A)`,  `ρ_A = M_l M_lᴴ`,

and integrated information is `Φ = min over cuts of I(A : B)`.

## 1. Random matrix product states with bond dimension `χ = 2`, `d = 2`

Local tensors with entries drawn uniformly from `{-3,…,3}`, boundary vectors
`(1,0)` and `(1,1)`.

| n | cut l | Schmidt rank | S(ρ_A) | I(A:B) = 2S | bound 2·log 2 |
|---|-------|--------------|--------|-------------|----------------|
| 2 | 1 | 2 | 0.028614 | 0.057228 | 1.386294 |
| 3 | 1 | 1 | 0.000000 | 0.000000 | 1.386294 |
| 3 | 2 | 2 | 0.052077 | 0.104155 | 1.386294 |
| 4 | 1 | 2 | 0.290206 | 0.580411 | 1.386294 |
| 4 | 2 | 2 | 0.253888 | 0.507776 | 1.386294 |
| 4 | 3 | 2 | 0.421659 | 0.843319 | 1.386294 |
| 5 | 1 | 2 | 0.171137 | 0.342274 | 1.386294 |
| 5 | 2 | 2 | 0.053439 | 0.106877 | 1.386294 |
| 5 | 3 | 2 | 0.195430 | 0.390860 | 1.386294 |
| 5 | 4 | 2 | 0.262986 | 0.525972 | 1.386294 |

Observations, all of which became theorems:

* the Schmidt rank never exceeds the bond dimension `2`
  (`schmidtRank_mpsCutMatrix_le`);
* the mutual information never exceeds `2 log 2 = log 4`
  (`mutualInformation_mps_bondDim_two_le`);
* whenever the Schmidt rank is `1` the mutual information is exactly `0`
  (`mutualInformation_eq_zero_iff_schmidtRank_eq_one`), so such an MPS has
  `Φ = 0` — it is *reducible* in the sense of IIT;
* the bound `2 log 2` is not attained by a generic bond-`2` MPS: the Schmidt
  spectrum must be flat.

## 2. GHZ chain states (bond dimension = local dimension = Schmidt rank)

`ψ(s) = d^(-1/2)` if `s` is constant, `0` otherwise.

| n | d | cut l | Schmidt rank | I(A:B) | 2·log d |
|---|---|-------|--------------|--------|---------|
| 2 | 2 | 1 | 2 | 1.386294 | 1.386294 |
| 2 | 3 | 1 | 3 | 2.197225 | 2.197225 |
| 3 | 2 | 1,2 | 2 | 1.386294 | 1.386294 |
| 3 | 3 | 1,2 | 3 | 2.197225 | 2.197225 |
| 4 | 2 | 1,2,3 | 2 | 1.386294 | 1.386294 |
| 4 | 3 | 1,2,3 | 3 | 2.197225 | 2.197225 |

Every cut gives the same value, so the minimum over cuts (i.e. `Φ`) equals
`2 log d`, and for `d = 2` (bond dimension two) `Φ = 2 log 2 = log 4`, exactly
twice the logarithm of the Schmidt rank `2`.  This is `phi_ghz` and
`phi_ghz_qubits` in Lean.

## 3. Counterexample hunt

The naive reading "Φ equals the Schmidt rank" is false as stated (Φ is a real
number, the Schmidt rank an integer), and even "Φ = 2 log(Schmidt rank)" fails
for generic states: line 1 of Table 1 has Schmidt rank `2` but
`I(A:B) = 0.057 ≠ 1.386`.  The correct statements, which we prove, are the
inequality `Φ ≤ 2 log(Schmidt rank at any cut) ≤ 2 log χ` together with
saturation exactly at a flat Schmidt spectrum (maximally entangled cuts), of
which GHZ is the canonical example.

No counterexample to any formalized statement was found.

## 3b. The unbalanced GHZ family `c|0⋯0⟩ + s|1⋯1⟩`

This one-parameter family (bond dimension `2`, Schmidt rank `2` at every cut for
`c, s ≠ 0`) separates `Φ` from the rank data at every chain length.  Its mutual
information is the same at every cut, so `Φ = 2 H₂(c²)`:

| c² | H₂(c²) | Φ = 2 H₂(c²) | cap 2 log 2 |
|-----|--------|--------------|-------------|
| 0.01 | 0.056002 | 0.112003 | 1.386294 |
| 0.10 | 0.325083 | 0.650166 | 1.386294 |
| 0.25 | 0.562335 | 1.124670 | 1.386294 |
| 0.40 | 0.673012 | 1.346023 | 1.386294 |
| 0.50 | 0.693147 | 1.386294 | 1.386294 |
| 0.60 | 0.673012 | 1.346023 | 1.386294 |
| 0.90 | 0.325083 | 0.650166 | 1.386294 |

The `c² = 1/2` row is the GHZ/Bell value, the only one saturating the cap.  All
of this is now proved in Lean: `phi_weightedGhz`,
`phi_unbalancedGhz_eq_two_mul_binEntropy`, `phi_unbalancedGhz_lt_two_log_two`
and `schmidtRank_chainCutMatrix_weightedGhz` in
`Catalog/Novelty/IITTensorNetworkWeightedGHZ.lean`.

Numerical values of `2 H₂(1/n)`, the integrated information of the `n`-qubit W
state: `1.273028 (n=3)`, `1.124670 (n=4)`, `1.000805 (n=5)`, `0.650166 (n=10)`,
`0.112003 (n=100)`.  The exact identity `Φ(W_n) = 2 H₂(1/n)` is proved in Lean
(`phi_wState` in `Catalog/Novelty/IITTensorNetworkWState.lean`), as is the
strict inequality `Φ(W_n) < Φ(GHZ_n) = 2 log 2` for `n ≥ 3`
(`phi_wState_lt_phi_ghz`); the monotonicity in `n` and the asymptotics
`2 H₂(1/n) ~ (2 log n)/n` remain unformalized conjectures.

## 4. OEIS

No integer sequence beyond the Schmidt ranks themselves (`1, 2, 3, …`, the
bond dimension) arises here; no OEIS entry is relevant.

## Script

```python
import math, random
from fractions import Fraction as F

def matmul(A,B):
    n,k,m=len(A),len(B),len(B[0])
    return [[sum(A[i][t]*B[t][j] for t in range(k)) for j in range(m)] for i in range(n)]

def rank(M):
    M=[row[:] for row in M]; rows=len(M); cols=len(M[0]); r=0
    for c in range(cols):
        piv=None
        for i in range(r,rows):
            if M[i][c]!=0: piv=i;break
        if piv is None: continue
        M[r],M[piv]=M[piv],M[r]
        pv=M[r][c]; M[r]=[x/pv for x in M[r]]
        for i in range(rows):
            if i!=r and M[i][c]!=0:
                f=M[i][c]; M[i]=[a-f*b for a,b in zip(M[i],M[r])]
        r+=1
    return r

def configs(k,d):
    out=[()]
    for _ in range(k): out=[c+(x,) for c in out for x in range(d)]
    return out

def mps_cut(A,n,d,chi,l,vL,vR):
    rows=[]
    for f in configs(l,d):
        row=[]
        for g in configs(n-l,d):
            s=f+g
            P=[[F(1) if a==b else F(0) for b in range(chi)] for a in range(chi)]
            for i in range(n): P=matmul(P,A[i][s[i]])
            row.append(sum(vL[a]*P[a][b]*vR[b] for a in range(chi) for b in range(chi)))
        rows.append(row)
    return rows

def entropy_rank2(M,tot):
    n=len(M)
    rho=[[sum(M[i][k]*M[j][k] for k in range(len(M[0])))/tot for j in range(n)] for i in range(n)]
    tr2=sum(rho[i][j]*rho[j][i] for i in range(n) for j in range(n))
    disc=max(2*float(tr2)-1,0.0)
    lp=(1+math.sqrt(disc))/2; lm=(1-math.sqrt(disc))/2
    h=lambda x: 0.0 if x<=1e-15 else -x*math.log(x)
    return h(lp)+h(lm)
```

## Addendum: W-state decay and the `Φ` spectrum at bond dimension two

All entries of the table below are instances of statements that are now **proved
in Lean** (`Catalog/Novelty/IITTensorNetworkWStateAsymptotics.lean`): the exact
value `Φ(W_n) = 2 H₂(1/n)` (`phi_wState`), the two-sided estimate
`2 log n / n ≤ Φ(W_n) ≤ 2 (log n + 1)/n` (`phi_wState_lower_bound`,
`phi_wState_upper_bound`), strict monotonicity in `n` (`phi_wState_strictAnti`),
and the limits `Φ(W_n) → 0`, `n Φ(W_n)/(2 log n) → 1` (`phi_wState_tendsto_zero`,
`phi_wState_asymptotics`).  The numbers themselves are ordinary floating-point
evaluations, given only for illustration.

| n | Φ(W_n) = 2H₂(1/n) | lower bound 2 log n / n | upper bound 2(log n + 1)/n | n·Φ/(2 log n) |
|---|---|---|---|---|
| 2 | 1.386294 | 0.693147 | 1.693147 | 2.000000 |
| 3 | 1.273028 | 0.732408 | 1.399075 | 1.738140 |
| 4 | 1.124670 | 0.693147 | 1.193147 | 1.622556 |
| 5 | 1.000805 | 0.643775 | 1.043775 | 1.554588 |
| 10 | 0.650166 | 0.460517 | 0.660517 | 1.411817 |
| 50 | 0.196078 | 0.156481 | 0.196481 | 1.253049 |
| 100 | 0.112003 | 0.092103 | 0.112103 | 1.216058 |
| 1000 | 0.015815 | 0.013816 | 0.015816 | 1.144692 |

The convergence of the last column to `1` is slow (the correction is of order
`1/log n`), which is exactly what the proof predicts: the error term
`(n-1) log(n/(n-1))` lies in `[0,1]` and is divided by `log n`.

Note also that the Schmidt rank and the bond dimension of `W_n` are `2` at every
cut for every `n` (`schmidtRank_chainCutMatrix_wState`), so the whole table is a
single family of states with frozen rank data and `Φ` ranging over a sequence
that converges to `0`.

For two-qubit states the picture is complete: `Φ` ranges over exactly the
interval `[0, 2 log 2] = [0, 1.386294…]` as the Schmidt parameter `c²` sweeps
`[0, 1/2]` (`phi_range_qubitPair` in
`Catalog/Novelty/IITTensorNetworkPhiSpectrum.lean`).
