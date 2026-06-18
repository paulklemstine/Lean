# FUTURE DIRECTIONS — The Aperiodic Monotile (Hat Spectrum)

All work lives in `Catalog/Geometry/AperiodicMonotile.lean`. Two research cycles were
run on top of the original algebraic core; every theorem below is fully verified
(0 sorries, only `propext`/`Classical.choice`/`Quot.sound`).

## What was proved this round

**Cycle 2 — spectrum geometry, Pell traces, rational-parameter aperiodicity**
* `edgeLength_sq_diff` : `a(t)² - b(t)² = 2(2t - 1)`.
* `edgeRatio_reflect`  : hat↔turtle duality `r(1-t)·r(t) = 1`.
* `edge_a_gt_b_iff`, `edgeRatio_gt_one_iff` : sharp `r(t) > 1 ↔ t > 1/2`.
* `hatTrace_closed_form` : `tr(n) = λⁿ + λ̄ⁿ`; `hatTrace_pos`, `hatTrace_strictMono`.
* `expansion_factor_sq_eq` (`λ² = 7 + 4√3`), `expansion_factor_sq_minpoly` (`x² - 14x + 1`).
* `irrational_rat_affine_sqrt3`, `rationalize_den_ne_zero`.
* **Headline** `edgeRatio_irrational_of_rational_param` and
  `edgeRatio_sub_one_irrational_of_rational_param` : the edge ratio is irrational for
  every rational `t ≠ 1/2`, discharging the algebraic core of the aperiodicity conjecture
  on a dense set of parameters.

**Cycle 3 — promoted conjectures**
* `reflect_involutive`, `reflect_fixed_iff`, `defect_reflect` (reflection symmetry, Conj 5).
* `hatTrace_double` : Lucas doubling `tr(2n) = tr(n)² - 2` (Conj 2).
* `hatTrace_ratio_tendsto` : `tr(n+1)/tr(n) → λ`, exact exponential growth rate (Conj 3).
* `expansion_conjugate_lt_one`.

**Cycle 4 — the Pell-unit hierarchy (Conjecture E core)**
* `hatPell`, `hatPow_eq` : `λ^k = a_k + b_k√3` with explicit integer coordinates.
* `hatPell_norm` : `a_k² - 3 b_k² = 1`, so every `λ^k` is a norm-1 unit of `ℤ[√3]`
  and each `(a_k, b_k)` solves the Pell equation `a² - 3b² = 1`.

---

## Open conjectures for the next cycle

The following are precise, falsifiable, and reachable with the existing
`ℤ[√3]` / substitution-matrix machinery.

### Conjecture A — Irrationality on the full quadratic field `ℚ(√3)`

**Statement.** For `p.t = a + b√3` with `a b : ℚ` and `p.t ≠ 1/2`, `edgeRatio p` is
irrational. This strictly generalizes `edgeRatio_irrational_of_rational_param` (the
`b = 0` case).

**Why plausible.** The rationalization `(u+v√3)/(v+u√3) = (c + d√3)` now has
`c, d ∈ ℚ(√3)`; the `√3`-component is a ratio of two `ℤ[√3]`-elements and irrationality
reduces to a norm-form non-vanishing in `ℤ[√3]` (which has class number 1).

**Test.** `edgeRatio_irrational_of_quadratic_param (a b : ℚ) (hp : p.t = a + b*√3) …`.

### Conjecture B — Lucas addition law and strong divisibility

**Statement.** `tr(m+n) + tr(m-n) = tr(m)·tr(n)` for `m ≥ n`, and consequently
`tr(m) ∣ tr(n)` whenever the index ratio is odd; more generally
`gcd(tr m, tr n)` is a `tr`-value indexed by a gcd-type function of `m, n`.

**Why plausible.** `tr` is the Lucas `V`-sequence for `(P,Q) = (4,1)`; `hatTrace_double`
is the `m = n` instance. The general identity is immediate from `hatTrace_closed_form`
plus `λλ̄ = 1`.

**Test.** `hatTrace_addsub : tr(m+n) + tr(m-n) = tr m * tr n`, then divisibility corollaries.

### Conjecture C — Perron–Frobenius spectrum of the substitution matrix

**Statement.** The 4×4 hat substitution matrix `hatSubstitutionSystem.substMatrix` has
characteristic polynomial divisible by `x² - 4x + 1`, so its leading eigenvalue is exactly
`hatExpansionFactor = 2 + √3`; the per-step tile-count ratio converges to `λ`.

**Why plausible.** The transfer matrix governing supertile growth has `λ` as its
Perron root by construction (this is the source of `area_growth_rate`). The
`hatTrace_ratio_tendsto` result is the scalar shadow of this; lifting it to the matrix
needs `Matrix.charpoly` of the explicit `!![…]` matrix.

**Test.** Compute `(hatSubstitutionSystem.substMatrix.map (Int.cast)).charpoly` and show
`(2 + √3)` is a root; relate to `expansion_factor_minimal_poly`.

### Conjecture D — Effective non-periodicity certificate

**Statement.** Strengthen `irrational_expansion_unbounded_periods` to an explicit escape
rate: for any `v ≠ 0` and scale `R`, the inflated period `λⁿ‖v‖` exceeds `R` for all
`n ≥ ⌈logb λ (R/‖v‖)⌉ + 1`, giving a finite "no period below scale R" certificate.

**Why plausible.** `geom_growth_unbounded` already gives existence with `λ > 1` explicit;
the bound is just `n > logb λ (R/‖v‖)`, constructive because `λ` is concrete.

**Test.** `period_escape_bound (R : ℝ) (hR : 0 < R) (hv : v ≠ 0) : ∃ N, ∀ n ≥ N, λ^n*‖v‖ > R`
with `N` given by the ceiling formula.

### Conjecture E — A two-parameter `ℤ[√3]`-unit hierarchy of expansion factors

**Statement.** For each `k ≥ 1`, `λ^k = u_k + w_k√3` with `u_k, w_k ∈ ℤ`, `u_k² - 3 w_k² = 1`
(a Pell solution), and `λ^k` is the expansion factor of the `k`-fold composed substitution;
all `λ^k` are irrational units of `ℤ[√3]` of norm 1, and `tr(kn)` is the trace sequence of
the inflated system.

**Why plausible.** `expansion_conjugate_product` gives `λλ̄ = 1` (norm 1); powers stay units.
`hatTrace_closed_form` already realizes `u_k = tr(k)/2`-type data. The Pell identity
`u_k² - 3 w_k² = 1` follows from `N(λ) = 1` and multiplicativity of the norm.

**Status.** *Core proved this cycle* (`hatPow_eq`, `hatPell_norm`). Remaining: relate the
`hatPell` coordinates to `hatTrace` (`tr k = 2 * a_k`) and show `λ^k` is the expansion factor
of the `k`-fold composed substitution system.
