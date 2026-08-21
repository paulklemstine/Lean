# Computational Evidence — Harmonic Measure on the Berggren Tree Boundary

All numbers below were produced with `#eval` inside the project's Lean 4 / Mathlib toolchain
(floating point for the transcendental quantities, exact `ℤ` arithmetic for the triples).
They are *evidence*, not proof; every claim that survived is proved without `sorry` in
`Catalog/Bridges/Berggren*.lean`.

## 1. The tree and its boundary

Berggren's three moves applied to `(3,4,5)`:

```
level 1 : (5,12,13), (21,20,29), (15,8,17)
```

Every node has exactly three children and no node repeats, so level `n` has `3^n` nodes:

```
n        : 0  1  2  3   4   5    6    7
#level n : 1  3  9  27  81  243  729  2187      (OEIS A000244, powers of 3)
```

This is the combinatorial content of "the boundary is the 3-adic Cantor set": infinite
descending paths ↔ infinite words over a 3-letter alphabet. Formalized as
`Bdry := ℕ → Fin 3` and proved to be a Cantor space in `BerggrenBoundaryCantor.lean`
(`berggren_boundary_is_cantor`: nonempty, compact, second countable, totally disconnected,
perfect).

Sanity check at depth 4: all 81 triples satisfy `a² + b² = c²` and `gcd(a,b) = 1` — `true`.

## 2. Growth of the hypotenuse along the tree (silver ratio)

Maximal and minimal hypotenuse at each level:

```
n              : 0   1    2     3      4       5
max hypotenuse : 5   29   169   985    5741    33461      (NSW numbers, OEIS A001653)
min hypotenuse : 5   13   25    41     61      85
```

* `max` satisfies `a(n) = 6a(n-1) − a(n-2)`, so `max(n+1)/max(n) → 3 + 2√2 = (1+√2)² ≈ 5.8284`.
  Numerically `33461/5741 = 5.82843…`. This is the *silver* growth exponent already recorded
  in the catalog.
* `min` fits `2n² + 6n + 5 = (n+1)² + (n+2)²` exactly on the range computed — polynomial, i.e.
  the "slow" branch of the tree has zero exponential speed.

Consequence used in `BerggrenWalkDrift.lean`: the walk's expected hyperbolic displacement per
step must lie strictly between the slow and the fast branch, which is exactly the shape of the
proved sandwich `p₂·log 2 ≤ E[dist]/n ≤ log(1+√2) + O(1/n)`.

## 3. Entropy and dimension of the harmonic measure

`H(p) = −Σ pᵢ log pᵢ`, `dim = H(p)/log 3`:

```
p                    H(p)        H(p)/log 3
(1/3,1/3,1/3)        1.098612    1.000000     (= log 3, maximum)
(1/2,1/4,1/4)        1.039721    0.946395
(0.8,0.1,0.1)        0.639032    0.581672
(0.98,0.01,0.01)     0.111902    0.101858
```

Consistent with the proved statements `shannon_le_log_three`, `shannon_eq_log_three_iff`
(equality **iff** the walk is fair) and `dim_lt_one_of_ne_uniform`.

**Exact level-`n` surprisal identity.** Summing `μ(cyl) · (−log μ(cyl))` over all `3^n`
depth-`n` cylinders for `p = (1/2,1/4,1/4)`:

```
n : 1        2        3        5
Σ : 1.039721 2.079442 3.119162 5.198604
nH: 1.039721 2.079442 3.119162 5.198604
```

Agreement to all printed digits for every `n` tested; total cylinder mass at depth 4 is
`1.000000`. This is the theorem `expected_surprisal`.

## 4. Counterexample hunt

* **Non-Bernoulli harmonic measure?** None exists: the search is closed by the proved
  uniqueness statement `existsUnique_harmonic` (a harmonic probability measure is determined on
  every cylinder by induction on depth, and cylinders generate the σ-algebra). The "if false"
  branch of the mission hypothesis is therefore ruled out.
* **Silver-ratio spectral gap?** `log(1+√2) = 0.881374`, while the transfer operator on
  locally constant observables was found to have spectrum `{0,1}` for *every* weight vector.
  Since `0 < 0.881374 < 1`, no locally constant eigenfunction can have this eigenvalue. This
  numerical observation became the *refutation* `log_silver_not_eigenvalue`: the conjectured
  silver-ratio spectral gap is **false**; the true gap is `1`.
* **Do different weights give the same measure?** No: the asymptotic frequency of a letter
  along a typical ray recovers its probability (strong law of large numbers), so distinct
  weight vectors are separated. This became `bernoulli_mutuallySingular` /
  `bernoulli_injective`.
* `log 2 = 0.693147 < log(1+√2) = 0.881374`, so the drift sandwich in
  `BerggrenWalkDrift.lean` is non-vacuous (lower bound strictly below the upper bound
  whenever `p₂ < 1`).

## 5. Addendum — the exponential separation rate

Testing the empirical frequency of one Berggren move against a threshold `u` separates two
walks at the binary relative entropy rate `klBer u s = u log(u/s) + (1-u) log((1-u)/(1-s))`.
Representative values, for the natural threshold `u = (p + q)/2` used in
`chernoff_separation_of_lt`:

| p (letter prob. under P) | q (under Q) | u = (p+q)/2 | klBer u q | klBer u p |
|---|---|---|---|---|
| 1/2 | 1/3 | 5/12 | ≈ 0.01508 | ≈ 0.01395 |
| 2/3 | 1/3 | 1/2 | ≈ 0.05889 | ≈ 0.05889 |
| 0.9 | 0.1 | 0.5 | ≈ 0.51083 | ≈ 0.51083 |

These are ordinary numerical evaluations of the formula, not machine-checked identities; what
*is* machine-checked is the qualitative input they illustrate, namely `klBer_pos` (strict
positivity of the rate off the diagonal, proved from `log x < x - 1`), together with the
sanity instance `0 < klBer (1/2) (1/3)` verified in
`Catalog/Bridges/BerggrenChernoffSeparation.lean`. The separating constant produced by the
theorem is `c = min (klBer u q) (klBer u p)`, symmetric in the middle row above because the
threshold sits exactly halfway between symmetric probabilities.


## Addendum (final cycle): Bhattacharyya coefficients and the entropy–metric gap

Numerical evaluations (floating point, *not* machine-checked; the Lean theorems state the
inequalities in exact form):

| `P` | `Q` | `β = ∑ₐ √(pₐqₐ)` | `−2 log β` (separation speed limit) |
|---|---|---|---|
| `(1/3,1/3,1/3)` | `(1/2,1/4,1/4)` | `0.98560` | `0.02901` |
| `(1/3,1/3,1/3)` | `(0.6,0.2,0.2)` | `0.96361` | `0.07413` |

For comparison, the single-letter Chernoff constants produced by `chernoff_separation` on the
same pairs — `klBer` at the midpoint tilt — are `0.01508` and `0.03801`: strictly inside the
Bhattacharyya bracket, as expected, so the two proved bounds genuinely bracket the cutoff rate
rather than coinciding.

Entropy versus metric exponent: `log 3 ≈ 1.09861`, `2 log(1+√2) = log(3+2√2) ≈ 1.76275`, ratio
`≈ 0.62324`.  This is the numerical content of `hypDim_le_max`, and it is comfortably below the
proved rational bound `2/3` of `hypDim_le_two_thirds`, whose exact input `3³ = 27 ≤ (1+√2)⁴ =
17 + 12√2 ≈ 33.97` is verified in Lean.
