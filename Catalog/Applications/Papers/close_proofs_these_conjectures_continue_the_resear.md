# Computational Evidence

Evidence supporting the two theorems proved this cycle. All rank computations below
are over a field `K` with `V` the standard finite-dimensional coordinate space; they
were used to choose the witnesses before formalization.

## 1. Single-endomorphism rank profile is strictly-decreasing-then-flat

Take the nilpotent Jordan block `J` of size `d` (ones on the super-diagonal). The
ranks of its powers are:

| n           | 0 | 1   | 2   | … | d-1 | d | d+1 | … |
|-------------|---|-----|-----|---|-----|---|-----|---|
| rank(Jⁿ)    | d | d-1 | d-2 | … | 1   | 0 | 0   | … |

The profile decreases by exactly `1` at each step until it hits `0`, then is flat —
matching `rank_pow_strictAnti_until_stable` and `range_pow_stable`. The diagonalizable
extreme `g = 1` gives the all-flat profile `d, d, d, …` (always the "stable" branch).
These two extremes confirm both disjuncts of the dichotomy are realized.

## 2. The stream counterexample (the 2D witness)

Stream maps over `K²`:

* `A = projA = [[1,0],[0,0]]`  (rank 1),
* `f 1 = id`,
* `B = projB = [[0,0],[0,1]]`  (rank 1).

Composite ranks of `compFrom f 0 n` (the product `f(n-1) ∘ ⋯ ∘ f 0`):

| n                | 0 | 1 | 2 | 3 |
|------------------|---|---|---|---|
| map              | id| A | id∘A = A | B∘A |
| `B·A` (matrix)   |   |   |   | `[[0,0],[0,1]]·[[1,0],[0,0]] = 0` |
| rank             | 2 | 1 | 1 | 0 |

So the rank sequence is `2, 1, 1, 0`: a genuine **plateau** at `1` across the step
`1 → 2`, followed by a **strict drop** to `0` at `2 → 3`. This is exactly
`stream_rank_plateau_then_drop`, and it is impossible for a single endomorphism by
Section 1.

## 3. Counterexample hunt / robustness

* Replacing `f 1 = id` by any invertible map keeps `rk₁ = rk₂` and the drop persists,
  so the phenomenon is not an artifact of the identity.
* Making the stream *constant* (`f ≡ A`) collapses the composites to powers `Aⁿ`
  (this is `compFrom_const`), and the profile becomes `2, 1, 1, 1, …` — flat after the
  first drop, i.e. the rigidity returns. This is the computational seed for
  Conjecture 3 in `FUTURE_DIRECTIONS.md`.

No counterexample to the *single-endomorphism* rigidity was found in a sweep of random
`2×2`–`4×4` rational matrices (ranks of powers were always strictly-decreasing-then-flat),
consistent with the proved theorem.
