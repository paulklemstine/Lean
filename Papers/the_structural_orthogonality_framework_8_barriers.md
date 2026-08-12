# Computational Evidence — Structural Orthogonality Framework

All numbers below were produced by exact rational arithmetic inside Lean
(`#eval` with `ℚ`), not by floating-point scripts, so they are reproducible
from the definitions given here.  They are *evidence*, not proof: the proved
statements are in `Catalog/Probability/*.lean`.

## 1. Setup: near-equal-`N` bands of semiprimes

For a window `[lo, hi)` we enumerate all pairs `(p, q)` with `3 < p < q`, both
prime, and `lo ≤ p·q < hi`.  This is the "size band" of the near-equal-`N`
test.  We report the **squared Pearson correlation** `R²` (computed exactly in
`ℚ`) between an invariant and the smaller factor `p`.

Enumeration and statistics used:

```lean
def primesUpTo (n : ℕ) : List ℕ := (List.range n).filter Nat.Prime

def semis (lo hi : ℕ) : List (ℕ × ℕ) :=
  let small := primesUpTo (Nat.sqrt hi + 1)
  let big := primesUpTo (hi / 4 + 1)
  small.flatMap (fun p => if 3 < p then big.filterMap (fun q =>
      if p < q ∧ lo ≤ p*q ∧ p*q < hi then some (p,q) else none) else [])

def corrQ (xs ys : List ℚ) : ℚ :=      -- squared correlation, exact
  let n : ℚ := xs.length
  let ex := xs.sum / n; let ey := ys.sum / n
  let cov := ((xs.zip ys).map (fun z => (z.1 - ex)*(z.2 - ey))).sum / n
  let vx := (xs.map (fun x => (x-ex)^2)).sum / n
  let vy := (ys.map (fun y => (y-ey)^2)).sum / n
  if vx = 0 ∨ vy = 0 then 0 else cov^2 / (vx*vy)
```

## 2. Results: `R²` of an invariant against the smaller factor `p`

| band `[lo,hi)` | #semiprimes | `N` | `N mod 7` | `N mod 60` | `⌊√N⌋` | digit sum of `N` | `φ(N)` | `σ₁(N)` |
|---|---|---|---|---|---|---|---|---|
| `[10000,10400)` | 58 | 0.00077 | 0.0168 | — | 0.00019 | — | 0.534 | 0.570 |
| `[20000,20400)` | 57 | 0.00285 | 0.0574 | 0.0180 | 0.0146 | 0.0058 | 0.526 | 0.524 |
| `[40000,40400)` | 61 | 0.0594 | 0.0019 | 0.0089 | 0.000000 | 0.00012 | 0.413 | 0.398 |

(`—` = not evaluated in that band.  `N mod 12` in the first band gave
`R² = 203/5461377 ≈ 3.7·10⁻⁵`.)

**Reading.**  Every invariant on the left of the table is a *structured*
function of `N` alone and its `R²` against `p` is in the range `10⁻⁶ … 6·10⁻²`
— indistinguishable from noise at these sample sizes.  The two invariants on
the right, `φ(N)` and `σ₁(N)`, have `R² ≈ 0.4 … 0.57`: they *do* carry the
factorization, and indeed the proved theorems
`factor_recovery_from_totient_nat` / `factor_recovery_from_sigma` recover `p`
and `q` from them in closed form.  This is the dichotomy the Lean files prove:
*constant / uninformative, or circular / already-factoring.*

## 3. Constancy check (constant side of the dichotomy)

On the band `[40000,40400)` (61 semiprimes):

```
#eval ((S.map (fun z => (Nat.divisors (z.1*z.2)).card)).dedup,
       (S.map (fun z => (Nat.primeFactors (z.1*z.2)).card)).dedup)
-- ([4], [2])
```

i.e. the divisor count is `4` and the number of distinct prime factors is `2`
for every sampled semiprime — the computational shadow of the proved theorems
`tau_semiprime`, `omega_semiprime`, `moebius_semiprime`.

## 4. Recovery formula, worked instance

`N = 3127 = 53 · 59`, `φ(N) = 3016`:

```
s = N + 1 - φ(N) = 112,  d = s² - 4N = 12544 - 12508 = 36 = 6²,
(s - √d)/2 = 53,  (s + √d)/2 = 59.
#eval → (53, 59, 3016, 112, 36)
```

matching `FactoringLab.recovery_from_sum` exactly.

## 5. Counterexample hunt

* **Universal claim tested**: "an `N`-only invariant has zero covariance with
  `p`."  This is **false as stated across bands**, and we found the smallest
  witness by hand and *proved* it in Lean: on the population `{6, 15}` with the
  invariant `g(N) = N`, the covariance with `Nat.minFac` is exactly `9/4`
  (`FactoringLab.cov_pos_counterexample`).  This is why the proved theorem
  carries the constant-band-mean hypothesis, and why the hypothesis-free
  version is the Cauchy–Schwarz bound
  `cov² ≤ Var(g∘n)·Var(band means)`.
* **Universal claim tested**: "the smaller factor is not a function of `N`."
  Also **false**: `Nat.minFac` is such a function
  (`FactoringLab.smaller_factor_is_N_only`).  The barriers are therefore
  structural, not information-theoretic — this is recorded explicitly in
  `Catalog/Probability/BarrierBoundary.lean`.

## 6. OEIS

No new integer sequence is produced by this work; the sequences appearing
(semiprimes A001358, `φ`, `σ₁`, `τ`, `μ`) are classical and were used only as
inputs.

---

## 7. Cycle-2 checks (adaptive, counting and dichotomy extensions)

* **Adaptive strategies.**  The barrier for decision trees is *uniform in tree
  size*: no numerical search is possible against it, since the bound
  `Σ (bandMean − Y)² ≤ Σ (tree − Y)²` holds for every band-measurable tree.
  The sharpness check is a two-point population inside a single band
  (`Ω = {0,1}`, `Y = (0,1)`): the non-band-measurable strategy "output `Y`"
  achieves error `0` against the band-mean error `1/2`, and this is proved in
  Lean (`FactoringLab.adaptive_barrier_fails_without_bandMeasurable`).
* **Counting barrier, small case.**  For `X = 40` the semiprime pairs with
  `p < q` and `pq ≤ 40` include `(3,5), (3,7), (5,7)` (proved by decision:
  `FactoringLab.semiprimePairs_forty_card_ge`), while the proved bound for a
  degree-`1` polynomial is `1 · (⌊√40⌋ + 1) = 7`; the bound only becomes
  binding for larger `X`, as expected from `π(√X)` growth.
* **Quadratic dichotomy, worked instance.**  For `F(r) = r² + r`
  (`a = 1, b = 1, c = 0`) and `N = pq`, the degeneracy test is
  `ac = 0` and `abN + bc = N ≠ 0`, so the invariant is on the *recovery* side:
  `s = (T − N² − N)/N` with `T = F(p)F(q)`.  For `p = 53`, `q = 59`
  (`N = 3127`): `T = 53·54·59·60 = 10 131 480`,
  `(T − N² − N)/N = (10 131 480 − 9 778 129 − 3 127)/3127 = 112 = p + q`,
  matching `FactoringLab.quadratic_multiplicative_dichotomy`.
* **Symmetric reduction, worked instance.**  For the same `F` and pair,
  reduction of `X² + X` modulo `(X − 53)(X − 59)` gives `B X + A` with
  `B = s + 1 = 113`, `A = −N = −3127`; then `A² + A B s + B² N =
  9 778 129 − 3 127·113·112 + 113²·3 127 = 10 131 480 = T`, matching
  `FactoringLab.symmetric_reduction_identity`.
* **Counterexample hunt (cycle 2).**  No counterexample was found to any
  cycle-2 statement; the two hypotheses that cannot be dropped
  (band-measurability in the adaptive barrier, nondegeneracy `ac ≠ 0 ∨
  abN + bc ≠ 0` in the quadratic dichotomy) are each accompanied by a proved
  boundary result.

## Cycle 3 evidence

* **Generic reduction, worked instance.**  For `F = X² + 1` the generic
  reduction over `ℤ[N][s]` gives `A_F = 1 − N`, `B_F = s`, hence the universal
  polynomial `Ψ_F = (1 − N)² + s²`.  At the semiprime `15 = 3 · 5` (`s = 8`)
  this predicts `F(3)F(5) = 10 · 26 = 260 = 196 + 64`, which is proved in Lean
  as `FactoringLab.symSpec_example` (with the closed form
  `FactoringLab.symSpec_sq_add_one`).  The candidate polynomial of the recovery
  branch is `Ψ_F(·,15) − 260 = s² − 64`, whose root `s = 8` is the hidden sum
  (`FactoringLab.symSpec_example_candidate`); its degree `2` sits inside the
  proved bound `2 deg F = 4`.
* **Both branches are populated.**  `F = X` gives `Ψ_X = N`, constant in `s`:
  the invariant is `N`-only for every modulus (`FactoringLab.symSpec_X`).
  `F = X + c` with `c ≠ 0` gives `Ψ = c s + (c² + N)`, of degree `1`: one
  candidate sum, i.e. immediate recovery (`FactoringLab.symSpec_X_add_C`).
  So the dichotomy of `FactoringLab.general_degree_dichotomy` is not vacuous on
  either side.
* **Randomization check.**  On a two-point population `Ω = {0,1}` inside one
  band with `Y = (0,1)`, the band mean is `1/2` on both points and the
  band-conditional error is `1/2`.  Any mixture of the two constant strategies
  "output `0`" and "output `1`" with weights `(w, 1−w)` has risk
  `w·1 + (1−w)·1 = 1 > 1/2`, and its mean predictor `w·0 + (1−w)·1` has risk
  `w² + (1−w)²  ≥ 1/2`: the mixture is strictly worse than its own mean
  predictor unless `w ∈ {0,1}`, exactly as the proved identity
  `FactoringLab.mix_sq_error_decomposition` requires (the gap is the
  randomization variance `w(1−w)·2`).
* **Quantization check.**  With the same population but band means
  `(0.2, 0.8)` in two different bands, a one-value palette `V = {v}` incurs
  quantization error `(v−0.2)² + (v−0.8)²  ≥ 0.18 > 0`, minimized at `v = 0.5`;
  a two-value palette `{0.2, 0.8}` incurs `0`.  This is the tradeoff isolated
  by `FactoringLab.quantized_barrier` and `FactoringLab.quantErr_pos`: only the
  palette size, never the depth of the strategy, can reduce the excess error.
* **Counterexample hunt (cycle 3).**  No counterexample was found to any
  cycle-3 statement.  The two hypotheses that cannot be dropped are the
  weight normalization `Σ w = 1` (without it the bias–variance identity fails
  outright) and nonemptiness of the palette; both appear explicitly in the
  formal statements.
