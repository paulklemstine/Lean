# Computational evidence for the positional-stratum measure framework

All numbers below were produced by small exploratory scripts *before* formalisation.
Everything that is asserted as a result in the Lean files is proved there; the tables here
are evidence that guided the statements, not a substitute for the proofs.
Where a row is also machine-checked in Lean, the corresponding theorem is named.

## 1. Identification of the certified law

The recorded anchor values pin the closed form uniquely.  Writing
`D(μ,P) = μ·P + (1−μ)·(1−P)` and `S = 1/D`:

| μ | P | `S(μ,P)` | recorded value | Lean theorem |
|---|---|---|---|---|
| 0.02 | 0.985 (rounded) | 29.069767… | 29.0698 | `erratum_rounded_value` |
| 0.02 | 0.9853 (stored `P̂`) | 29.315197… | 29.3152 | `erratum_row_value` |
| 0.05 | 0.85 | 5.405405… = 200/37 | 5.4054 | `descending_adversary_undercuts` |
| 0.052 | 0.85 | 5.364807… | 5.365 (adversary) | `descending_adversary_undercuts` |
| 0.115 | 0.87 | 4.649000… | 4.649 (stale prose locus) | `stale_locus_value` |

Interpretation of `D`: it is the *agreement probability* of two independent Bernoulli
draws with parameters `μ` and `P`.  This reading is what makes the composition result
(§4) provable in one line of probability, and it is formalised algebraically as
`coupling_slack_identity`.

The erratum is therefore reproduced exactly: `29.0698` is the certified law at the
**rounded** `P = 0.985`, while the stored `P̂ = 0.9853` gives `29.3152`.  Exact rationals:
`1000000/34400` and `10000000/341120`.

## 2. Feasibility is unaffected by the rounding

`1/S = D = μP + (1−μ)(1−P)`, so `μ ≤ 1/S ⟺ (1−P)(1−2μ) ≥ 0`.  For every locus with
`μ ≤ 1/2` this holds for *all* `P`, so no re-reading of `P̂` can flip the verdict.
Checked numerically on a 200×200 grid over `(μ,P) ∈ (0,1/2]×(0,1)`: 0 violations.
Formalised as `feasibility_mu_le_inv_certifiedValue`, applied to the anchor in
`erratum_feasibility_unaffected`.

## 3. Value-universality off uniform cells

Booked (uniform-within-cell) prediction for a head stratum of size `m` in `M` slots:
`bookedEC = P(m+1)/2 + (1−P)(m + (M−m+1)/2)`.

Sweep, `M = 64`, `m = 8`, `P ~ U(0.5, 0.99)`, 4000 draws per placement, weights placed at
the two extreme atoms of each cell:

| placement | violation rate (true value > booked value) | max ratio |
|---|---|---|
| head (atoms at 1 and m+1) | 1.000 | 4.46 |
| mid | 1.000 | 1.12 |
| tail (atoms at m and M) | 0.000 | — |

The head placement violates the booked law systematically, and the ratio is *not* bounded
by any constant: taking `M = 2m`, `P = 1 − 1/m` gives true cost `2` against booked cost
`(m+3)/2`, i.e. ratio `(m+3)/4 → ∞`.  This is the content of `value_universality_fails`,
which is proved for an arbitrary bound `B`.  The tail placement never violates it, which
is what suggested the two-sided envelope of §5.

## 4. Composition

Random search over `(μ₁,P₁,μ₂,P₂) ∈ (0,1)^4`, 200 000 draws: **no** instance with
`S(μ₁μ₂, P₁P₂) > S(μ₁,P₁)·S(μ₂,P₂)`; equality never observed in the interior.
Example gap: `S(1/4, 9/10) = 10/3` versus `S(1/2,9/10)·S(1/2,1) = 4`.
Formalised as `certifiedValue_strict_submultiplicative` (strict on the open box) and
`certifiedValue_not_multiplicative` (the numeric witness).

## 5. Envelope

For fixed bookings `(m, M, P)` the extreme atom placements give
`min EC = P·1 + (1−P)(m+1)` and `max EC = P·m + (1−P)·M`; 10 000 random weights honouring
the bookings all fell inside, and the booked prediction fell inside in every case with
`m + 1 ≤ M`.  Formalised as `EC_envelope`, `headWitness_attains_lower`,
`tailWitness_attains_upper`, `bookedEC_mem_envelope`.

## 6. Canonical kernel

`∫₁^R ½ r^{−3/2} dr = 1 − R^{−1/2}` checked numerically at `R = 2, 4, 10, 100`
(agreement to 1e−9), and the capture curve `(1 − R^{−1/2})/(1 − R_max^{−1/2})` is exactly
linear in the balance coordinate.  A uniform prior on `[1,4]` gives capture `1/3` at
`R = 2` against the canonical `2 − √2 ≈ 0.5858`, so the linearity characterisation has
content.  Formalised as `canonical_integral`, `captureProb_linear`,
`kernel_unique_of_capture_law`, `capture_curve_not_linear_of_uniform`.

## 7. No OEIS entry

No integer sequence arises in this framework — all objects are real-valued cost and
probability functionals — so no OEIS search applies.
