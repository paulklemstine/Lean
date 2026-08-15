# Computational Evidence — NET-26 / EOS-WIDTH-DISTRIBUTION-SHIFT

All numbers below are either (a) reported experimental data from the NET-26
round, or (b) arithmetic that is *re-checked inside Lean* in
`Catalog/Tropical/NeuralNetworks/EOSWidthDistributionShift.lean`.  Nothing here
is claimed as verified unless it is backed by a Lean declaration that builds
without `sorry`; the Lean-backed items are named.

## 1. The two accuracy samples (input data)

Accuracies in basis points (units of `10⁻⁴`), plain `n = 5` carry task,
`GRUCell(384 → 192)`, learned `E`-dimensional EOS zero-padded to 384.

| regime | sample | Lean name |
|---|---|---|
| `E = 20` (12 arms) | 9990, 9990, 9990, 7440, 1240, 580, 310, 260, 170, 110, 60, 50 | `e20Bp` |
| `E ≥ 28` (20 arms) | 10000 × 20 | `robustBp` |

## 2. Small-case calculations (all re-derived in Lean)

| quantity | value | Lean declaration |
|---|---|---|
| clean cures at `E = 20` (threshold 0.9) | 3 of 12 | `e20_tail_cure`, `cure_rate_E20` |
| clean cures at `E ≥ 28` | 20 of 20 | `robust_tail_cure`, `cure_rate_robust` |
| empirical cure rate `E = 20` | `1/4` | `cure_rate_E20` |
| median of the `E = 20` sample | `0.0445` | `e20_median` |
| tail-fraction dominance `∀ t` | `F̄₂₀(t) ≤ F̄₂₈(t)` | `tail_dominance` |
| strict dominance at the cure level | `3/12 < 20/20` | `tail_dominance_strict` |

## 3. Counterexample hunt against the "sharp threshold" claim

The universal claim under test is: *there is a width `E₀` such that an arm cures
iff its EOS width is at least `E₀`.*  A counterexample needs two arms of equal
width with opposite outcomes.  The `E = 20` sample supplies one immediately:
`(E = 20, acc = 0.9990)` cures, `(E = 20, acc = 0.0170)` does not.

This is formalised — not merely asserted — as `no_sharp_boundary`
(`¬ SharpBoundary net26Arms`), with the reusable general form
`no_sharp_boundary_of_split`.  The sharp-boundary reading of NET-25 is therefore
refuted deterministically, without any probabilistic modelling.

## 4. Likelihood arithmetic

Under the null "a single cure probability `p` governs both regimes", the
likelihood of the pooled data (3/12 and 20/20) is `C(12,3)·p²³(1−p)⁹`.

* maximiser: `p̂ = 23/32 = 0.71875`;
* maximised kernel: `(23/32)²³·(9/32)⁹ ≈ 5.5 × 10⁻⁹`;
* two-regime alternative kernel: `(1/4)³·(3/4)⁹·1²⁰ ≈ 1.17 × 10⁻³`;
* likelihood ratio: `≈ 4.7 × 10⁻⁶`.

Lean-verified consequence (uniformly in `p ∈ [0,1]`, no numerical optimisation
assumed): `homogeneous_null_rejected`,
`100000·p²³(1−p)⁹ ≤ (1/4)³(3/4)⁹·1²⁰`, proved from `binomial_kernel_max`, which
in turn comes from the exponential form of weighted AM–GM `pow_le_scaled_exp`
(`a ≤ c·exp(a/c − 1)`).

One-sided confidence for the robust regime: `p ≤ 0.86 ⇒ p²⁰ < 0.05`
(`robust_regime_confidence`), i.e. `20/20` excludes any cure probability at or
below `0.86` at the 5% level.

## 5. Model-side computation

The tropical model predicts the qualitative shape of the data without fitting:

* `separable_eosOf_iff` — a block-supported (width `E ≤ D`) boundary token is
  separable from the digit atoms iff `maxᵢ cᵢ > 0`, a seed-dependent event;
* `margin_bound_sharp` — the best achievable margin in that regime is exactly
  `maxᵢ cᵢ` (so the bound of `margin_le_of_no_exclusive_dim` is attained);
* `separable_eosVec_of_gt` — one exclusive dimension makes separability
  unconditional, for every seed;
* `signSeed_cureProb` — a two-seed `±1` model gives fragile cure probability
  exactly `1/2`: strictly interior, like the empirical `3/12`.

No OEIS sequence is involved: the objects here are accuracy samples and
max-plus margins, not integer sequences.

## 6. Depth (progressive-unroll) evidence

Reported unroll curve for a fragile arm: `n = 5 : 1.0000`, `n = 6 : 0.9556`,
`n = 7 : 0.1445`, `n = 8 : 0.0166` — a smooth collapse, with column-clustered
errors, rather than a cliff.  The model-side counterpart is proved in
`Catalog/Tropical/NeuralNetworks/EOSWidthDepthPropagation.lean`:
`mplusApply_shift` / `mplusIter_shift` (no amplification of a bounded gap at any
depth), `depth_uniform_ambiguity` (the fragile boundary trajectory stays within
`maxᵢ cᵢ` of the all-digit trajectory at every depth) and
`exclusive_dim_persists` (the robust regime keeps its exclusive dimension at
every depth).
