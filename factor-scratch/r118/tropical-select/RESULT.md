# RESULT — F1 applied: tropical/p-adic size as an NFS polynomial-selection criterion

Round 118, `factor-scratch/r118/tropical-select/`.
**Status: the naive tropical criterion is REFUTED, and the refutation is a lesson about
conditioning.** The classical predictor is confirmed with a controlled measurement.

## 1. The question

The catalog formalises tropical algebra and the Newton–tropical bridge
(`Catalog/Cryptography/TropicalAlgebra`, `Newtontropicalbridge`). NFS polynomial selection
picks `φ(x) ∈ ℤ[x]` with small coefficients and good root properties; the classical
(Kleinjung) criterion is an affine size/skewness combination. Tropicalising the problem
replaces the coefficient *size* by its p-adic *valuation*, which is what controls the
smoothness of the values `v = a + bθ`. Test: does the tropical score beat the classical one
at predicting the thing that actually matters?

## 2. Setup (ground-truthed, so the payoff is computable)

`N = p·q` with `p` 50-bit, `q` 52-bit, factors known to us. For each `(d, m)` build the
classical **base-`m` polynomial** `φ(x) = Σ c_i x^i` with `φ(m) = N`, so `θ = m` is a root
mod `N`, and measure the **true payoff**: the `B`-smoothness rate of `v = (a + b·m) mod N`
over `|a|, |b| < 2^24`, `B = 2^14`, 120 trials per candidate, fixed seed. 52 candidates
(`d = 3..6`, `m` over ±6 bits either side of `N^{1/d}`).

Criteria compared: `ℓ₂(φ)`, `max|c_i|`, skewness ratio, and the tropical score
`Σ v_p(c_i)` for `p = 2, 3`.

## 3. Result

**Pooled correlations with the measured smoothness rate:**

```
ℓ₂ size        r = -0.2284
max coefficient r = -0.2213
skewness        r = -0.3351
tropical v2     r = +0.5057     <- largest magnitude
tropical v3     r = +0.4240
```

**But the ranking the criteria would choose is wrong for the tropical ones:**

```
ℓ₂ picks d=6, m~2^10 -> actual rate 0.2167   (the true best)
skewness picks d=5, m~2^16 -> 0.0750
tropical v2 picks d=3, m~2^34 -> 0.0000     (the true WORST)
tropical v3 picks d=4, m~2^19 -> 0.0250
```

The tropical score has the *largest* pooled correlation yet picks the *worst* polynomial,
because the correlation is **positive**: minimising it is exactly backwards. That is the
signature of a spurious correlation, and the control confirms it:

```
POOLED            trop v2 r = +0.5057   |m| r = -0.8127
d=3 (n=13)        trop v2 r = -0.0582   |m| r = -0.5647
d=4 (n=13)        trop v2 r = +0.1549   |m| r = -0.5207
d=5 (n=13)        trop v2 r = +0.4262   |m| r = -0.8399
d=6 (n=13)        trop v2 r = +0.2617   |m| r = -0.8770
```

Conditioned on degree, `Σ v_2(c_i)` collapses from `+0.51` to `−0.06 … +0.43` **and flips
sign across degrees**, while the base size `|m|` stays strongly negative
(`−0.52 … −0.88`, pooled `−0.81`). So the pooled tropical correlation was measuring the
*degree* (higher `d` ⇒ more coefficients ⇒ higher digit-valuation sum, and higher `d` ⇒
better payoff), not the smoothness.

## 4. Findings

1. **The naive p-adic digit size is not a selection criterion.** Minimising
   `Σ v_p(c_i)` picks the worst polynomial in the family. The base-`m` digits are
   essentially uniform in `[0, m)`, so their 2-adic valuations carry almost no information
   about the value size `a + b·m`; the pooled `+0.51` is the degree in disguise.
2. **The classical driver is confirmed under control:** base size `|m|` predicts the payoff
   at `r ≈ −0.8`, consistently across every degree. Smaller base ⇒ smaller values ⇒
   smoother. This is the classical result, re-measured here with the conditioning done.
3. **Residue of interest, honestly flagged:** within a degree the tropical score *is*
   positively correlated at `d = 5, 6` (`+0.43, +0.26`) but not at `d = 3, 4`. That is
   weak, sign-inconsistent, and could itself be collinear with something else (e.g. the
   digit count interacting with `m`). **Not evidence for the tropical criterion.**
4. **What the catalog's tropical work would actually buy is not this.** The tropical
   content of polynomial selection lies in the **Newton polygon** of `φ` (the monomial
   support and its reduction), not in the p-adic valuations of essentially random
   base-`m` digits. That experiment — comparing candidate *supports* rather than
   coefficient-size statistics — has not been run and is the honest next step.

## 5. Reproduce

```
cd /home/raver1975/lean/factor-scratch/r118/tropical-select
/home/raver1975/sage_mamba/envs/sage/bin/sage sel.sage        # criteria + pooled correlations
/home/raver1975/sage_mamba/envs/sage/bin/sage control2.sage    # conditioning control
```

## 6. Traps

1. `primes(2, 2^20)` with Sage Integers per value would have been ~30 s per candidate × 52;
   the smoothness test was rewritten in Python ints with a precomputed prime list.
2. The first version's payoff proxy was a placeholder that did not evaluate `a + bθ` at all.
   The real measurement needs `θ = m` from the base-`m` construction, which is why `N`'s
   factors are generated and known: `m` is a root mod `N` **by construction**.
3. `QQ(good, trials)` is not valid in this Sage.
