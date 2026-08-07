# Computational Evidence

All numbers below were produced by `#eval` inside Lean 4 (Float arithmetic) before the
corresponding theorems were formalized. They are exploratory data, not verification; the
verified statements are the Lean theorems in `Catalog/MachineLearning/TransformerUniversality/`.

## 1. Softmax lookup vs. the exact finite selector

Setup: `X = Fin 4`, value table `f = (0, 1, 2, 3)`, bound `M = 3`, one-hot keys, so the score
gap is `γ = 1` and the theoretical bound of `softmaxLookup_error_le` is
`2·M·(N−1)·exp(−β) = 18·exp(−β)`.

| score scale β | measured max error over x | proved bound 18·e^(−β) |
|---|---|---|
| 1  | 1.049266 | 6.621830 |
| 2  | 0.577531 | 2.436035 |
| 5  | 0.039627 | 0.121283 |
| 10 | 0.000272 | 0.000817 |
| 20 | ~0       | ~0       |

The bound is valid in every row and loose by a factor ≈ 3–6, consistent with the crude
`|v_j − v_{i₀}| ≤ 2M` step in the proof.

Explicit ε-scale from `softmaxLookup_eps_approximation` for ε = 0.01:
`log((2·M·(N−1)+1)/ε) = log(1900) ≈ 7.5496`. Measured error at β = 7.55 is `0.003152`,
below the proved bound `0.009470 < ε`. The predicted scale is therefore admissible and not
far from necessary — the error at β = 7.55 is already within a factor 3 of ε.

## 2. Resolution of a quantized lookup table (separation theorem)

Setup: midpoint quantizer with `N` cells on `[0,1]`, values `(a + 1/2)/N`; error measured on a
grid of 2001 points.

| N | measured sup error | proved lower bound 1/(2N) |
|---|---|---|
| 1 | 0.500000 | 0.500000 |
| 2 | 0.250000 | 0.250000 |
| 3 | 0.166667 | 0.166667 |
| 4 | 0.125000 | 0.125000 |
| 5 | 0.100000 | 0.100000 |
| 6 | 0.083333 | 0.083333 |

The measured optimum coincides with `1/(2N)` in every case. This is exactly the tightness
statement later proved as `FiniteLookupSeparation.optimal_quantizer_error` (an `IsLeast`
claim), and it is what motivated proving the matching construction rather than only the lower
bound.

**Counterexample hunt.** We looked for a quantizer/value pair beating `1/(2N)` by perturbing
cell boundaries and cell values for `N ≤ 6`; no configuration improved on the midpoint rule,
consistent with the pigeonhole argument (any `N`-cell model identifies two of the `N+1` grid
points `k/N`, which are `1/N` apart).

## 3. Head complexity

Small rank experiments motivated `HeadComplexity.minHeads_eq_finrank`: for
`f : Fin 3 → (Fin 2 → ℝ)` with rows `(1,0), (0,1), (1,1)` the span of the outputs is
2-dimensional, so two heads suffice although the catalog construction would use three. The
general statement (minimal heads = rank of the value table) was then proved, together with the
two extreme cases (`linear independence ⇒ |X| heads necessary`, `rank one ⇒ one head`).

## 4. No OEIS sequence

No integer sequence arises in this development; the quantities involved (`log(1/ε)` score
scales, `1/(2N)` resolutions, matrix ranks) are analytic or linear-algebraic, so an OEIS
lookup is not applicable.

---

# Cycle 2 evidence

*Exploratory `#eval` data, not verification; the theorems themselves are proved in Lean.*

## 5. Two-key softmax against the identity on `[0,1]`

The head used in `SoftmaxResolution.two_key_softmax_approx_identity` evaluates to
`(x+ε)/(1+2ε)`. Absolute errors `|(x+ε)/(1+2ε) − x|` on the grid `x = 0, ¼, ½, ¾, 1`:

| ε | x=0 | x=¼ | x=½ | x=¾ | x=1 | proved bound |
|---|---|---|---|---|---|---|
| 0.5 | 0.2500 | 0.1250 | 0 | 0.1250 | 0.2500 | 0.5 |
| 0.1 | 0.0833 | 0.0417 | 0 | 0.0417 | 0.0833 | 0.1 |
| 0.01 | 0.0098 | 0.0049 | 0 | 0.0049 | 0.0098 | 0.01 |

The measured maximum is `ε/(1+2ε)`, comfortably below the proved bound `ε`, and it tends to
`0` with **two** keys only. The corresponding hard two-cell lookup cannot go below
`1/(2·2) = 0.25` (computed in cycle 1 and re-proved by pigeonhole in
`SoftmaxResolution.hardHead_error_ge`). This is the numerical content of the refutation of the
conjectured `Ω(1/N)` softmax resolution barrier.

## 6. Distance from a singular matrix to the identity

For `n = 2, 3, 4` the centering matrix `C = 1 − (1/n)J` has every entry at distance exactly
`1/n` from the identity (`0.5, 0.333…, 0.25`). This is what suggested that `1/n` is not merely
a lower bound but the exact value. Both halves are now theorems: the lower bound is
`LowRankQuantitative.exists_entry_far_from_one` and the matching example makes
`LowRankQuantitative.entrywise_distance_to_identity_eq` an exact value.

---

# Cycle 3 evidence

*Exploratory numerical data, not verification; the theorems themselves are proved in Lean.*

## 7. The affine-score two-key head against the identity on `[0,1]`

The tuned head of `AffineScoreTwoKey.idHead` is `1/2 + (2/a)·tanh(a(x−1/2)/2)`: scores
`a·x − a/2` and `0`, values `1/2 ± 2/a`. Maximum absolute error over the grid
`x = 0, 0.1, 0.25, 0.5, 0.75, 0.9, 1`, against the proved bound `a²/96` (which is also the
asymptotic prediction, from `tanh u = u − u³/3 + O(u⁵)` and `|u| ≤ a/4`):

| score scale `a` | measured max error | proved bound `a²/96` |
|---|---|---|
| 2.00 | 0.037883 | 0.041667 |
| 1.00 | 0.010163 | 0.010417 |
| 0.50 | 0.002588 | 0.002604 |
| 0.25 | 0.000650 | 0.000651 |
| 0.10 | 0.000104 | 0.000104 |

The measured errors track the proved bound to three digits — the bound `a²/96` is the exact
leading order, because `AffineScoreTwoKey.abs_tanh_sub_le_cube` gives the sharp cubic estimate
`|tanh u − u| ≤ |u|³/3`. The important
qualitative fact is that the error tends to `0` with **two affine-score keys**, which is what
refutes the conjectured affine barrier. The price appears in the value column: the amplitude
`4/a` is `2, 4, 8, 16, 40` in the five rows above, i.e. amplitude × score scale ≡ 4 — exactly
the value that `AffineScoreTwoKey.amplitude_times_scale_ge` proves to be a lower bound (up to
the factor `1 − 2ε`) and that `amplitude_law_is_sharp` proves to be attained.

## 8. Entrywise versus spectral distance to the selection pattern

For the centering matrix `C = 1 − (1/n)J` the entrywise distance to the identity is `1/n`
(`0.5, 0.333…, 0.25` for `n = 2, 3, 4`), but the *spectral* distance is `‖J/n‖ = 1` for every
`n`, since `J/n` is a rank-one orthogonal projection. The two norms therefore give different
resource statements, and it is the dimension-free one that survives `n → ∞`. This observation
is what suggested `OperatorNormObstruction.spectral_distance_to_scaled_identity`, where the
value is proved to be exactly `β`, and it corrects the guess (recorded as next-cycle
sub-conjecture 3 of cycle 2) that the operator-norm bound would again carry a `1/d` factor.
