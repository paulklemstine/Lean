# II — Is `20/27` optimal? Choosing the base `g` instead of sampling it uniformly

**Round 50 exp, `baseg`. Working dir `factor-scratch/r50exp/baseg/`. No paper, no issue, no commit.**

---

## Verdict in one line

**No, `20/27` is not optimal.** Choosing `g` with **Jacobi `(g/n) = −1`** — computable from `n`
alone in `O(log n)`, no factoring — raises the per-attempt rate from **`20/27 = 0.7407` to
`8/9 = 0.8889`** exactly, and end-to-end Stange from **`0.773` to `0.877`** on fresh
semiprimes (McNemar `p ≈ 0.001`). **And `8/9` is optimal:** the unimplementable oracle that
knows `s_p` and `s_q` separately reaches only `0.8963`, so the whole remaining lever is
**0.0074** and it is unclosable without factoring.

This is the sharpest idea in the brief ("this has never been tried"), and it works.

---

## 1. The mechanism (G1)

Stange's step succeeds iff

```
k_p != k_q ,      k_p = v2(ord_p g).
```

Put `a = s_p = v₂(p−1)`, `b = s_q = v₂(q−1)`, and **`lam_p = a − k_p`**. For a uniform `g` the
law of `lam` is the campaign's own `v2dist` read backwards:

```
P(lam = i) = 2^-(i+1)   (0 <= i <= a-1),      P(lam = a) = 2^-a.      [mass exactly 1]
```

This is the same law the programme already trusts, relabelled — **no new assumption**. It is
verified here by *full enumeration over every* `g ∈ [1,p)` *for s = 1,2,3,4,7*, matching to 4
decimals (`laws.py`, and the enumeration in the transcript).

**The structural fact that opens the lever** — verified by enumeration on 896 non-residues
across 6 primes, 0 mismatches (`measure.py` T2):

```
lam = 0   <=>   g is a QUADRATIC NON-RESIDUE mod p   <=>   (g/p) = -1
```

Therefore

```
(g/n) = (g/p)(g/q) = (-1)^(lam_p + lam_q) ,
```

so **`Jacobi(g/n) = −1` forces exactly one of `lam_p, lam_q` to be 0** — without revealing
which. That is the whole trick: force *disagreement* without knowing which factor is which.

Measured on 4500 samples: `(lam_p==0, lam_q==0)` took the values `{(T,F),(F,T)}` and nothing
else. Exactly one side is a non-residue, never both, never neither.

### G1's answer: the reachable family

For a uniform `g` the law is the Haar measure on `(Z/p)*`, so **every reachable non-uniform
choice is a pushforward of that measure through a condition computable from `n`**. The only
such 2-adic condition is the Jacobi symbol. So the reachable family is exactly

| rule | rate |
|---|---|
| uniform `g` (the campaign baseline) | `20/27 = 0.740741` |
| `Jacobi(g/n) = +1` | `8/15 = 0.533333` |
| **`Jacobi(g/n) = −1`** | **`8/9 = 0.888889`** |

There is no finer handle: pinning `lam_p = 0` *individually* needs `(g/p)`, i.e. needs `p`.

---

## 2. Exact rates, and why `8/9`

Under `Jacobi = −1`, one branch has `lam_p = 0`, so `k_p = a` **exactly**; the other has
`lam_q ≥ 1`, so `k_q = b − lam_q`. Success is `lam_q ≠ b − a`, and
`P(lam_q = m | lam_q ≥ 1) = 2^-m` for `1 ≤ m ≤ b−1`. Hence

```
SUCC_jac(a,b) = 1 - (1/2)[ 2^-(b-a)·1{b>a} + 2^-(a-b)·1{a>b} ],
```

which is **exactly 1 when `a = b`** and `1 − 2^-(|a−b|+1)/2` off the diagonal. Averaging over
`s ~ Geom(1/2)`:

```
E[FAIL] = 2 · Σ_{b≥2} 4^-b (1 - 2^-(b-1)) = 2(1/12 - 1/28) = 1/9   =>   SUCC = 8/9.
```

Confirmed three ways: exact rational enumeration, the hand derivation above, and measurement.
The closed form was **cross-checked against `laws.py` cell-by-cell for `a,b ≤ 19`: zero
disagreements.**

### Where the gain lives — and where it costs

| cell | uniform | `jac=−1` | Δ |
|---|---|---|---|
| (1,1) | 0.5000 | **1.0000** | **+0.5000** |
| (2,2) | 0.6250 | **1.0000** | **+0.3750** |
| (3,3) | 0.6562 | **1.0000** | **+0.3438** |
| (2,3) | 0.8125 | 0.7500 | −0.0625 |
| (3,4) | 0.8281 | 0.7500 | −0.0781 |
| (1,2) | 0.7500 | 0.7500 | 0.0000 |

**The strategy helps on the diagonal and *loses* off it.** It wins overall because `P(a=b)=1/3`
carries huge gains (uniform scores only ~0.5–0.67 there) against bounded losses `≤ 1/4`
elsewhere. **Stating this matters** — anyone quoting `8/9` without the per-cell table would be
hiding a real regression on 2/3 of the weight.

---

## 3. G3 — survives contact with real instances

### 3a. The order step: 300 fresh 26-bit semiprimes × 200 `g`-trials (N = 60 000 per rule)

| strategy | hits | rate | 95% CI | vs 20/27 | z |
|---|---|---|---|---|---|
| uniform (baseline) | 44438 | **0.7406** | [0.7371, 0.7441] | −0.0001 | **−0.06** |
| **`jac_neg`** | 53009 | **0.8835** | [0.8809, 0.8860] | **+0.1427** | **+79.79** |
| `jac_pos` | 35635 | 0.5939 | [0.5900, 0.5978] | −0.1468 | −82.07 |
| `fixed2` | 42200 | 0.7033 | [0.6997, 0.7070] | −0.0374 | −20.91 |
| `fixed3` | 44600 | 0.7433 | [0.7398, 0.7468] | +0.0026 | +1.45 |
| `fixed5` | 44000 | 0.7333 | [0.7298, 0.7369] | −0.0074 | −4.14 |
| square | 31301 | 0.5217 | [0.5177, 0.5257] | −0.2191 | −122.44 |

The uniform row sits on `20/27` at **−0.06σ** — the null reproduces.

### 3b. THE MANDATORY 2-ADIC CONTROL (per modulus, each against *its own* cell)

Not one pooled number is quoted without this. **Every cell matches its own prediction**;
worst `|z|` = 1.97 (uniform) and 3.35 (`jac_neg`) at N = 200 per cell, which is what multiple
testing over 36 cells should produce.

| a,b | v₂(n−1) | N_mod | unif pred | unif obs | z | jac pred | jac obs | z |
|---|---|---|---|---|---|---|---|---|
| 1,1 | 4 | 74 | 0.5000 | 0.5024 | +0.59 | **1.0000** | **1.0000** | n/a (14800/14800) |
| 1,2 | 1 | 37 | 0.7500 | 0.7486 | −0.27 | 0.7500 | 0.7474 | −0.51 |
| 2,2 | 3 | 19 | 0.6250 | 0.6263 | +0.17 | **1.0000** | **1.0000** | n/a (3800/3800) |
| 3,3 | 5 | 4 | 0.6562 | 0.6613 | +0.30 | **1.0000** | **1.0000** | n/a (800/800) |
| 3,4 | 3 | 4 | 0.8281 | 0.8325 | +0.33 | 0.7500 | 0.7412 | −0.57 |
| 4,4 | 5 | 3 | 0.6641 | 0.6833 | +1.00 | **1.0000** | **1.0000** | n/a (600/600) |

Per-modulus predictions span **[0.5000, 0.9980]** for uniform and **[0.7500, 1.0000]** for
`jac_neg` — *wider than the effect being claimed*, which is precisely why a pooled rate alone
would have been untrustworthy. The diagonal cells came back at **14800/14800, 3800/3800,
800/800, 600/600 — literally every trial**, exactly as `SUCC_jac(a,a) = 1` predicts.

### 3c. END-TO-END: does it actually factor more? (300 fresh 2²⁰ moduli, BB=50, c=10)

| base | factors found | rate | 95% CI |
|---|---|---|---|
| uniform (baseline) | 232/300 | **0.7733** | [0.723, 0.817] |
| **Jacobi = −1** | **263/300** | **0.8767** | [0.835, 0.909] |

Paired: **Δ = +0.1033, t = +3.34** on 299 df. **McNemar χ² = 10.80, p ≈ 0.0010**
(60 moduli won only by jac, 29 only by uniform) — the correct test for paired binary outcomes.

**Harness validation:** the uniform baseline reproduces `K_stange.md`'s kill test almost
exactly — **46/60 = 0.767** at N = 60 vs the recorded **0.767**. The pipeline is faithful.

The per-class split is the cleanest confirmation of the mechanism in the whole note:

| class | N_mod | uniform | jac |
|---|---|---|---|
| **diagonal `a==b`** | 94 | 50/94 = 0.5319 | **94/94 = 1.0000** |
| off-diagonal | 206 | 182/206 = 0.8835 | 169/206 = 0.8204 |

**The end-to-end gain is entirely the diagonal, and it is total there** — 94/94. Off-diagonal
it is slightly *worse*, exactly as the per-cell theory says. A pooled +0.10 with no per-cell
table would have looked like a modest generic win; it is actually a very large win on 1/3 of
the moduli and a small loss on the other 2/3.

**The order step is a hard ceiling** — verified: given a genuine multiple `M` of `ord_n(g)`,
`factor_from_multiple` succeeded in **0 of 173** cases with `k_p == k_q`. So no amount of extra
work in the Q-kernel step can rescue those, and raising the order-step rate can only help.

### Cost

`Jacobi(g,n)` is `O(log n)` bit operations; rejection sampling costs **E[2] draws**. A Stange
attempt already spends `b+c` relation-findings plus a rational nullspace over ℚ. **Free by
comparison, and it touches nothing else** — same relation-finder, same kernel, same algebra.

---

## 4. G4 — the honest verdict, with the two claims kept apart

The brief is explicit that conflating these is the programme's signature error, so they are
stated separately.

### VERSION A — "no `g` beats 8/9" — **FALSE, and I am not claiming it.**

Over *all* `g` the supremum is **1**, attained: hand the algorithm `p` and `q` and choose `g`
with `k_p = 0`, `k_q = s_q`. Success is certain. Any optimality claim over all `g` is
refuted by an oracle.

### VERSION B — "no `g` computable from `n` without factoring beats 8/9" — **this is the claim,
and it holds.**

**Argument.** Any condition on `g` computable from `n` is a function of `g`'s residue class in
`(Z/nZ)*`. The 2-adic value of `k_p` is which 2-power subgroup `g` lands in. Separating
`lam_p = 0` from `lam_q = 0` **requires knowing which prime is which**, and any test that
distinguishes them computes a non-trivial factor — the Jacobi symbol is exactly the maximal
such object, being the *product*, hence symmetric under `p ↔ q`, hence powerless here. So the
reachable family is the three rules of §1, and `8/9` is its max.

**Strength claimed:** this is an argument about polytime-without-factoring, not a theorem
about every model of computation. A rule depending on the *ordering* of `p` and `q` is not
excluded by symmetry alone — but computing one requires knowing the ordering, i.e. factoring.

**And the bound is tight, empirically.** The **oracle** — which picks `argmax` per cell and
therefore *knows `a` and `b` separately, i.e. knows the factors* — was measured on the same
250 fresh semiprimes:

| rule | rate | vs `jac_neg` | z |
|---|---|---|---|
| uniform | 0.7558 | −0.1408 | −80.11 |
| **`jac_neg`** | **0.8966** | — | — |
| v-policy (`v₂(n−1)`-aware) | 0.8962 | −0.0004 | −0.23 |
| **ORACLE (unimplementable)** | **0.9032** | **+0.0066** | +3.75 |

Exact values: oracle `0.896296…` vs `8/9 = 0.888889…`, a gap of **0.0074 (0.83% relative)**.

**So: the last lever on the choice of `g` is 0.0074 wide, and it is exactly the part that
requires knowing the factors.** A `v₂(n−1)`-aware policy is implementable (`v=1` ⟹ `a≠b`
certainly; `v≥7` ⟹ `a=b` certainly on 6000 fresh moduli) but measures **0.8962 vs 0.8966** —
indistinguishable, `z = −0.23`. **Not worth the code.**

**Net: the search for a better `g` is closed.** Uniform `g` was leaving 20% on the table;
`Jacobi = −1` collects all of it that is collectable; the remaining 0.0074 is not collectable
without factoring `n`, which is the thing we were trying to avoid.

---

## 5. What I got wrong on the way (kept, because the controls caught it)

1. **`lam` ≠ `k` off the diagonal — the worst one.** My first scorer compared `lam_p != lam_q`.
   Success is `k_p != k_q`, and `k = s − lam`, so the two agree **only when `a == b`**. The
   visible symptom was a *perfect* **12000/12000** for `jac_neg` — an impossibly clean result
   that the per-cell control exposed immediately. Pinned by regression test T6, which
   demonstrates the two scorers disagreeing on 47/200 trials of a `(1,2)` cell.
2. **The mandatory 2-adic control fired at `z = −18.5`** on my first honest uniform sampler.
   It was *my* harness (`k` vs `lam`), but it is exactly the failure the control exists for: I
   would otherwise have reported a refutation of the campaign's own constant.
3. **`stange.gen_semiprime` returns `(n, p, q)`, not `(p, q, n)`.** Unpacking it the other way
   silently produced 13-bit moduli and made the entire end-to-end run read **0/40** for both
   arms. Fixed with an `assert p*q == n`.
4. **A bucket aggregate divided by one modulus' trial count**, printing a "rate" of `1.99`.
   The data were fine (198/200); the report was not.
5. **`policy.py` scored the diagonal with the jac payoff in *both* branches**, so "best action"
   could never leave uniform. Rebuilt independently from the two cell functions.
6. **A `z`-score against a predicted probability of exactly 1 is undefined** (zero variance).
   Reported as `n/a`, not as 0 and not as ∞.

Self-tests are written to return the null where the null is correct: an honest uniform
sampler is **not** flagged (`z = −1.11`), a deliberately biased one **is** (`z = +4.06`), and
the real `jac_neg` sampler is flagged at `z = +19.25` — so the detector is non-vacuous in both
directions. All rational laws assert **mass exactly 1** with no renormalisation anywhere, the
defect that let a factor-2 error survive in round 48; truncation error is bounded by the
dropped tail mass and reported, never silent.

---

## 6. Limits of this result

- **All measurements are at small `n`** (≤ 2²⁶ for the order step, 2²⁰ end-to-end). The rate
  constants are properties of `(Z/p)*` and are **size-independent**, so the prediction does not
  extrapolate downward in difficulty — but the *end-to-end* number does: at 2²⁰ the Q-kernel
  step is nearly free, and at 10²⁰+ it will bind first and mask part of this gain.
- **The end-to-end gain (+0.103, p ≈ 0.001) is smaller than the order-step gain (+0.148)**,
  because the Q-kernel step (`h > 1`, `K_stange.md`) is a second, independent ceiling. Both
  matter; fixing one does not fix the other.
- **`fixed2/3/5` and `square` are measured against the WRONG null** and are reported as such:
  a fixed base is not uniform mod `p`, so the geometric law — and hence 20/27 — does not apply.
  They lose regardless, but the `z` column is not a significance test for them.
- **The v-policy's exact rate is not determined here**; only its measured equivalence to
  `jac_neg` (`z = −0.23`).

## 7. Files

| file | what |
|---|---|
| `laws.py` | exact rational 2-adic laws, the three cell rates, 8 self-tests incl. injection |
| `measure.py` | order-step measurement, 6 self-tests incl. the `lam`/`k` regression |
| `optimal.py` | G4, Versions A and B kept apart |
| `policy_verify.py` | cell-aware policy + the oracle bound, exact and measured |
| `policy.py` | the `v₂(n−1)` analysis (superseded by `policy_verify.py`; see defect 5) |
| `e2e.py` | end-to-end `stange.alg22`, imported read-only from `r48/exp/stange/` |
| `measure_out.json`, `e2e_out.json` | raw data |

Reproduce: `python3 laws.py` · `python3 measure.py --selftest` · `python3 measure.py 300 200 26`
· `python3 optimal.py` · `python3 policy_verify.py` · `python3 e2e.py 300 50 10 20`