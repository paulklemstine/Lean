# Computational evidence — rescaling law for window saturation scales

All quantities below refer to the objects formalised in
`Catalog/Combinatorics/WindowSaturationExponentDial.lean`:

* `dial α i = i^{-α}` — the exponent dial (α = 0 uniform, α = 1/2 sqrt, α = 1 harmonic);
* `ess w B = (∑_{i≤B} w i)² / (∑_{i≤B} w i²)` — the effective window size;
* on the uniform orthonormal window model of size `m`, the catalog score of
  `WindowSaturationMatchedFilter` satisfies `R²(w, B) = ess w B / m`
  (theorem `uniformModel_R2`), so `R²` and `ess` differ by the fixed factor `m`;
* `satScale w θ` — the least window edge with `ess w B ≥ θ`.

For the dial, `ess (dial α) B = P_α(B)² / P_{2α}(B)` with `P_β(B) = ∑_{i=1}^B i^{-β}`.

The numbers in this file were produced by direct floating-point evaluation of
those sums. **They are exploratory only and are not machine-verified.** The
verified statements are the Lean theorems cited alongside; every proved band
below is a Lean theorem with no `sorry`.

## 1. The score table on the stored window edges

`R²` column uses `m = 800` (the largest stored window).

| B   | `ess (dial ½) B` | `R²(½,B)` | proved band (Lean)      | `ess (dial 1) B` | `R²(1,B)` | proved band (Lean) |
|-----|------------------|-----------|--------------------------|------------------|-----------|---------------------|
| 50  | 36.145           | 0.0452    | `≥ 7`   (`sqrt_table`)   | 12.456           | 0.0156    | `≤ 49`  (`harmonic_table`) |
| 100 | 66.618           | 0.0833    | `≥ 12`  (`sqrt_table`)   | 16.458           | 0.0206    | `≤ 64`  (`harmonic_table`) |
| 200 | 122.732          | 0.1534    | `≥ 22`  (`sqrt_table`)   | 21.069           | 0.0263    | `≤ 81`  (`harmonic_table`) |
| 400 | 226.369          | 0.2830    | `≥ 40`  (`sqrt_table`)   | 26.280           | 0.0329    | `≤ 100` (`harmonic_level_at_400`) |
| 800 | 418.435          | 0.5230    | `≥ 72`  (`sqrt_table`)   | 32.088           | 0.0401    | `≤ 121` (`harmonic_table`) |

Every measured value lies inside the proved band. The qualitative reading:
across a factor 16 in the window edge, the harmonic score rises by a factor
`2.6` (logarithmically, `∼ (log B)²`) while the sqrt score rises by a factor
`11.6` (essentially linearly, `∼ B / log B`). The two dials are not related by
any window-independent constant, so a saturation edge measured on one of them
cannot be reused for the other.

## 2. Fitted saturation exponents versus the predicted `1/(2-2α)`

`satScale (dial α) θ` computed exactly (binary search on the monotone `ess`,
sums truncated at `4·10⁶`), with the local log–log slope
`log(B*(θ₂)/B*(θ₁)) / log(θ₂/θ₁)`:

| θ    | `B*_{3/4}(θ)` | slope | `B*_{1/2}(θ)` | slope |
|------|---------------|-------|---------------|-------|
| 16   | 31            | —     | 20            | —     |
| 64   | 260           | 1.534 | 96            | 1.132 |
| 256  | 2807          | 1.716 | 460           | 1.130 |
| 1024 | 35895         | 1.838 | 2184          | 1.124 |
| 4096 | 508745        | 1.913 | 10188         | 1.111 |

* **α = 3/4.** Predicted exponent `1/(2-2α) = 2`. The fitted slope rises
  monotonically `1.53 → 1.91` towards `2`; the deficit is the finite-size
  correction `P_{3/4}(B) = 4B^{1/4} + ζ(3/4) + o(1)` with `ζ(3/4) ≈ -1.46`.
  The proved bracket is `(θ/16)² ≤ B*_{3/4}(θ) ≤ (3θ)² + 1`
  (`rescaling_law_three_quarters`); at θ = 4096 that reads
  `6.55·10⁴ ≤ 5.09·10⁵ ≤ 1.51·10⁸`, so the measured scale sits inside the
  proved bracket.
* **α = 1/2.** Predicted exponent `1/(2-2α) = 1`. The fitted slope is *never*
  `1`: it hovers at `1.11–1.13`, and `1 + 1/ln θ` equals `1.12` at θ = 4096 —
  exactly the `θ log θ` law. This is the numerical face of
  `sqrt_dial_no_uniform_window_bound`: the linear law fails by a logarithm, so
  no uniform constant works.

## 3. The harmonic dial is exponential, not polynomial

| θ  | `B*_1(θ)` | `log₂ B*_1(θ)` | `√θ` | ratio |
|----|-----------|----------------|------|-------|
| 4  | 6         | 2.58           | 2    | 1.29  |
| 9  | 25        | 4.64           | 3    | 1.55  |
| 16 | 93        | 6.54           | 4    | 1.63  |
| 25 | 340       | 8.41           | 5    | 1.68  |
| 36 | 1232      | 10.27          | 6    | 1.71  |

`log₂ B*_1(θ)` is linear in `√θ` with slope tending to
`√(ζ(2))/ln 2 = 1.851`, i.e. `B*_1(θ) = e^{Θ(√θ)}`. This is the `α → 1`
degeneration of the exponent `1/(2-2α) → ∞`, and it is the content of
`harmonic_needs_exponential_window` (`(1+k)² < θ ⟹ B > 2^k`).

## 4. Counterexample hunt

* *Is `ess` monotone in `B` for arbitrary positive weights?* No. With
  `w = (ε, ε, …, ε, 1)` a single heavy last column collapses the effective
  window size (e.g. `w = (0.01, 0.01, 1)`: `ess(2) = 2`, `ess(3) = 1.04`).
  This is why `ess_mono` is proved *for antitone weights only* — the dial is
  antitone, and the hypothesis is load-bearing rather than cosmetic.
* *Is the Cauchy–Schwarz bound `ess ≤ B` ever attained by a nonuniform dial?*
  Not in the sample: equality held only for constant weights, matching
  `ess_const` (α = 0) and the strict loss for α > 0.
* *Does a single window-independent constant transport the harmonic edge to the
  sqrt edge?* No: the ratio `B*_{1/2}(θ)/B*_1(θ)` computed at
  θ = 4, 9, 16, 25, 36 is `0.833, 0.440, 0.215, 0.097, 0.041` — it is not bounded
  away from `0`, since the harmonic scale is exponential and the sqrt scale is
  near-linear. Only the *level* `θ` transports (that is exactly
  `transport_level_from_harmonic` followed by `transport_to_alpha`).

## 5. OEIS

No integer sequence arises: all quantities here are real-valued power sums.
The dyadic bounds `1 + k/2 ≤ P_1(2^k) ≤ 1 + k` used in the Lean development are
the classical Oresme brackets for harmonic numbers; the associated integer data
(numerators of `H_n`, A001008) is not used by any statement.
