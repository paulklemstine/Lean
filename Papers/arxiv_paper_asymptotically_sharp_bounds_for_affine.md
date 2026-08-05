# Computational Evidence

All computations below were run inside Lean 4 (`#eval`) using the same definitions as the
formal development in `Catalog/Applications/AffineSubspaceStats/AffineStats.lean`, so the
numbers refer exactly to the formalised model:

* `Vec n = Fin n → ZMod 2` is `𝔽₂ⁿ`;
* a random affine `d`-cube is `y ↦ c + ∑ᵢ yᵢ vᵢ` for `(c, v₀, …, v_{d-1})` uniform in
  `Vec n × (Fin d → Vec n)`;
* `cnt A c v = #{y ∈ 𝔽₂^d : c + ∑ yᵢ vᵢ ∈ A}`.

The parameter space has `2^{n(d+1)}` elements, so all quantities are exact rationals with
denominator a power of two.

## 1. Maximum odd-intersection probability

`oddCount n d A = #{(c,v) : cnt A c v is odd}`, maximised over all `A ⊆ 𝔽₂ⁿ`.

| n | d | max over A of oddCount | parameter space | max probability |
|---|---|------------------------|-----------------|-----------------|
| 2 | 1 | 8                      | 16              | **1/2**         |
| 2 | 2 | 24                     | 64              | 3/8             |

Observations that guided the formalisation:

* the value never exceeds `1/2` — this became the main theorem
  `AffineStats.oddProb_le_half`;
* for `n = 2, d = 1` the value `1/2` is attained exactly, while for `n = 2, d = 2` it is
  strictly smaller (3/8 < 1/2). The second fact was turned into the formal statement
  `AffineStats.maxOddProb_dim2_lt_half`, proved by kernel evaluation (`decide`), showing
  that `1/2` is a genuine `n → ∞` limit and not a finite-`n` maximum.

## 2. Hyperplane construction

With `A = {x ∈ 𝔽₂³ : x₀ = 0}` and `d = 2`:

```
#{(c,v) : cnt A c v = 2} = 384 ,  parameter space = 512 ,  ratio = 3/4 = 1 - 2^{-2}
```

This matched the prediction `P[|F ∩ A| = 2^{d-1}] = 1 - 2^{-d}` exactly and became the
theorem `AffineStats.hyperplane_flatProb` (proved for all `n, d`, not just this instance).
Note `3/4 > 1/2`: this is the computational origin of the "contrarian" corollary
`AffineStats.exists_flatProb_gt_half`, which shows the parity bound `≤ 1/2` fails for even
`s`.

## 3. Counterexample hunt

* *Claim tested:* "`P[|F ∩ A| = s] ≤ 1/2` for every `s`." **Refuted** by the hyperplane
  data above (`s = 2^{d-1}`, probability `1 - 2^{-d} > 1/2` for `d ≥ 2`); formalised as
  `exists_flatProb_gt_half`.
* *Claim tested:* "`P[|F ∩ A| odd] ≤ 1/2`." No counterexample found in the exhaustive
  searches over all `2^{2^n}` subsets for `(n,d) ∈ {(2,1),(2,2)}`; subsequently proved in
  general.
* *Claim tested:* "the bound `1/2` is attained for some finite `n`, `d ≥ 2`." Refuted at
  `(n,d) = (2,2)` (maximum `3/8`); formalised as `maxOddProb_dim2_lt_half`.

## 3b. The codimension-`m` construction (added in the follow-up work)

Exploratory `#eval`s of `flatProb n d (codimSub n hmn) (2^(d-m))` against the conjectured
exact value `∏_{i<m} (1 - 2^{i-d})`:

| n | d | m | computed probability | `∏_{i<m}(1 - 2^{i-d})` |
|---|---|---|----------------------|------------------------|
| 3 | 2 | 1 | 3/4                  | 3/4                    |
| 4 | 2 | 2 | 3/8                  | 3/8                    |
| 3 | 3 | 1 | 7/8                  | 7/8                    |

A union of two parallel flats (`m = 2`, `|S| = 2`, `d = 2`, `n = 4`) gave `3/4` for the
statistic `s = 2`, as predicted by `cnt_unionFlats`.

These computations motivated, and agree with, the theorems
`AffineStats.flatProb_codimSub_prod` (exact value, all `n ≥ m`, `d ≥ m`) and
`AffineStats.unionFlats_flatProb_ge` (union of parallel flats), both of which are proved in
Lean, so the table above is only an illustration of the proved statements.

## 3c. The random construction for `s = 1` (added in the follow-up work)

For `s = 1` the natural construction is a random set containing each point with probability
`p`; a `d`-flat has `2^d` points, so the probability of a single hit is
`2^d p (1-p)^{2^d - 1}`, maximised at `p = 2^{-d}` with value `(1 - 2^{-d})^{2^d-1}`.
Comparing this with the exact value `∏_{i<d}(1 - 2^{i-d})` of the algebraic
(codimension-`d` subspace) construction:

| `d` | random `(1-2^{-d})^{2^d-1}` | algebraic `∏_{i<d}(1-2^{i-d})` |
|---|---|---|
| 1 | 1/2 = 0.5 | 1/2 = 0.5 |
| 2 | 27/64 ≈ 0.4219 | 3/8 = 0.375 |
| 3 | 823543/2097152 ≈ 0.3927 | 21/64 ≈ 0.3281 |
| 4 | ≈ 0.3798 | ≈ 0.3076 |

The random values decrease to `e^{-1} ≈ 0.3679`, the algebraic ones to
`∏_{t≥1}(1-2^{-t}) ≈ 0.2887`.  These `#eval`s motivated the file
`Catalog/Applications/AffineSubspaceStats/RandomConstruction.lean`, where the random
construction is realised as an averaging argument over colourings `g : 𝔽₂ⁿ → Fin (m+1)`
(`p = 1/(m+1)`) and the bound `λ*(d,1) ≥ (1-2^{-d})^{2^d-1}` is proved
(`exists_flatProb_one_ge`, `exists_flatProb_one_ge_opt`, `maxFlatProb_one_ge_limit`),
together with the strict comparison `27/64 > 3/8` at `d = 2` (`random_beats_codimSub`) and
the limit `→ e^{-1}` (`tendsto_randomBound_exp`).  All four statements are Lean-proved, so
the table only illustrates them.

## 4. OEIS

No integer sequence of independent interest arose; the observed counts
(`8, 24, 384, …`) are of the form `2^a·3^b` tied to the specific parameters and were not
searched further.

## Status of the evidence

Items 1–3 are *exploratory* computations. The claims that survived them are all backed by
`sorry`-free Lean proofs in `AffineStats.lean`; in addition the `(n,d) = (2,2)`
non-attainment claim is itself verified inside Lean by kernel evaluation (`decide`, not
`native_decide`).
