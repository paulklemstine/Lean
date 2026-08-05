# Computational evidence

Exploratory numerics carried out **before** the Lean formalization, to test the
conjectures about the rotated Laplacian / periodicity ratio.  These computations
are floating-point explorations only and are **not** machine-verified; every
statement that we claim as a result is proved in Lean in
`Computation/RotatedLaplacianPeriodicity.lean` and
`Computation/RotatedLaplacianQuantization.lean`.

Setting: a weighted digraph `w`, rotation `ω = e^{2πi/p}`,

* rotated energy `E_p(x) = Σ_{u,v} w(u,v) ‖x_v − ω x_u‖²`,
* volume `vol(x) = Σ_v (deg_in + deg_out)(v) ‖x_v‖²`,
* periodicity ratio `β_p = min { E_p(x)/vol(x) : x_v ∈ {0} ∪ μ_p, x ≠ 0 }`
  (exhaustive search over all such vectors).

## 1. Periodicity ratio of small digraphs

| digraph (unit weights)              | β₂      | β₃      | β₄      | β₆      |
|-------------------------------------|---------|---------|---------|---------|
| directed 4-cycle `C₄`               | 0       | 0.3333  | 0       | 0.25    |
| directed 6-cycle `C₆`               | 0       | 0       | 0.2     | 0       |
| `C₄` + chord `0→2`                  | 0.4     | 0.25    | 0.2     | 0.3     |
| `C₆` + chord `0→2` of weight `0.05` | 0.01653 | 0.0124  | 0.20398 | 0.00413 |

Observations, all of which became theorems:

* `β_p = 0` exactly for the divisors `p` of the period (4 for `C₄`, 6 for `C₆`;
  the chorded graphs have period 1, all `β_p > 0`).  Formalized as
  `exists_zero_energy_phase_iff`, with divisor- and lcm-closure
  (`exists_zero_energy_phase_of_dvd`, `exists_zero_energy_phase_lcm`).
* `β₂ = 0` for `C₄` although the period is `4`: this is the counterexample to the
  bold converse "zero `p`-ratio ⟹ period `= p`" (`not_period_eq_of_zero_energy`).
* All ratios observed are `≤ 2`, matching `rotEnergy_le_two_mul_vol`.
* Perturbing a periodic graph by a small chord gives a small positive ratio
  (last row): "nearly periodic" is a genuine intermediate regime for weights
  below `1`.

## 2. Quantization: minimum energy over *full-support* phase vectors

`rootGap p = 4 sin²(π/p)`: `4, 3, 2, 1.382, 1, 0.753, 0.5858` for `p = 2..8`.

| digraph (unit weights) | p | min E_p over full-support phase vectors | rootGap p |
|---|---|---|---|
| `C₄` | 2 | 0 | 4 |
| `C₄` | 3 | 3.0 | 3 |
| `C₄` | 4 | 0 | 2 |
| `C₄` | 5 | 1.382 | 1.382 |
| `C₆` | 2 | 0 | 4 |
| `C₆` | 3 | 0 | 3 |
| `C₆` | 4 | 4.0 | 2 |
| `C₄`+chord | 2 | 4.0 | 4 |
| `C₄`+chord | 3 | 3.0 | 3 |
| `C₄`+chord | 4 | 2.0 | 2 |
| `K₃` (both directions) | 2 | 8.0 | 4 |
| `K₃` | 3 | 9.0 | 3 |

In every instance the minimum is either exactly `0` or `≥ rootGap p`, and the
bound is attained in several cases (`C₄` at `p = 3, 5`; `C₄`+chord at
`p = 2, 3, 4`).  This dichotomy is the content of
`rotEnergy_eq_zero_or_rootGap_le`, and the sharpness above shows the constant
`rootGap p` cannot be improved.

## 3. Counterexample hunt

* Searched for a unit-weight digraph on ≤ 4 vertices with `0 < min E_p <
  rootGap p`: none found (consistent with the quantization theorem).
* Searched for a violation of `β_p ≤ 2`: none found.
* Scaling all weights by `t > 0` scales the energy by `t`, so the *unnormalized*
  dichotomy fails without the "nonzero weights `≥ 1`" hypothesis; this is
  formalized as `exists_small_positive_rotEnergy`.
* No relevant integer sequence arises, so no OEIS entry applies.
