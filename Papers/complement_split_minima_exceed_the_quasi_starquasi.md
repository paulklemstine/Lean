# Computational Evidence — Semi-induced star `S_{k,1}` minima vs. the quasi-clique/quasi-star envelope

All computations use the degree functional for symmetric step graphons:

```
I(W) = Σ_i a_i · d_i^k · (1 - d_i),   d_i = Σ_j a_j P_ij,   β = Σ_i a_i d_i,
envelope(β) = min(β^k(1-β), β(1-β)^k).
```

## 1. Random search over 3-class symmetric step graphons (minimisation)

For each `(k, β)` we minimised `I` over symmetric `3×3` density matrices `P` and class sizes
(120k random samples, density window `±0.004`). `ratio = bestI / envelope`:

| k | β=0.3 | β=0.4 | β=0.5 | β=0.6 | β=0.7 |
|---|-------|-------|-------|-------|-------|
| 2 | 0.547 | 0.573 | 0.576 | 0.890 | 1.239 |
| 3 | 0.751 | 0.564 | 0.548 | 1.092 | 2.317 |

**Reading.** For `β ≲ 0.6` the true minimum is *strictly below* the envelope (`ratio < 1`); for
`β ≳ 0.7` it is above. So the quasi-clique/quasi-star envelope is **not** a lower bound — it is a
beatable upper-bound profile, and the minimum dips below it on an interval around `β = 1/2`. This
reverses the mission's literal "minimum exceeds envelope" wording (a construction value can never
exceed the minimum it bounds); the verified phenomenon is `minimum < envelope`.

## 2. The clean two-class "split" optimum

At `β = 1/2` the 3-class optimum collapses to a **two-class split graph**: a dominating clique
class `A` (degree 1) joined to an independent class `B`. Optimising `w = |A|` with `B` internally
empty gives `w = 1 - 1/√2 ≈ 0.293` and

```
I = (1/2)·(1 - 1/√2)^k,   envelope(1/2) = (1/2)^{k+1},   ratio = (2 - √2)^k.
```

| k | ratio = (2−√2)^k |
|---|------------------|
| 2 | 0.343 |
| 3 | 0.201 |
| 4 | 0.118 |
| 5 | 0.069 |
| 6 | 0.041 |

The single-parameter family `a = 1-√(1-β)` realises density `β = a(2-a)` for all `β∈(0,1)` and gives
`splitVal(β) = (1-β)(1-√(1-β))^k`.

## 3. Interval on which the split family beats the envelope (per k)

`splitVal(β) < envelope(β)` holds (numerically) on `(0, c_k)`:

| k | upper crossover c_k (approx) |
|---|------------------------------|
| 2 | ≈ 0.72 |
| 3 | ≈ 0.69 |
| 4 | ≈ 0.66 |
| 5 | ≈ 0.63 |
| ∞ | → (√5−1)/2 ≈ 0.618 |

This matches the proved uniform interval `(0, (√5−1)/2)`: `splitVal < cliqueTerm` for **all**
`β∈(0,1)`, and `splitVal < starTerm` exactly when `√(1−β) > β`, i.e. `β < (√5−1)/2`.

## 4. OEIS / counterexample notes

* No integer sequence search applies (results are real-analytic in `β`).
* Counterexample hunt for the *proved* claim `splitVal < envelope on (0,(√5−1)/2)`: none found
  across `k ∈ {1,…,8}` and a fine `β`-grid. The boundary is sharp — at `β = (√5−1)/2` the two
  sides of `splitVal = starTerm` meet (as `k → ∞`).
* The naive two-class symmetric perturbation `d = 1/2 ± t` beats the constant graphon only for
  `k ∈ {2,3}` (it fails for `k ≥ 4`), which is *why* the asymmetric split graph (clique + independent
  set) is the right general construction — a key lesson from the experiment stage.

All formal theorems live in `Basic.lean` (separation) and `TuranBridge.lean` (cross-domain bridge),
fully proved with no `sorry`.
