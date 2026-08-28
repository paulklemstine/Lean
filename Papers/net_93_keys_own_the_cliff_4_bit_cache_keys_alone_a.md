# Computational evidence for the NET-93 formalisation

All numbers below are small, directly checkable calculations that were used to
pin down the constants appearing in the Lean statements. Every claim that ends
up in a theorem is proved in Lean by exact arithmetic (`norm_num`, `nlinarith`,
`interval_cases`); the tables here only document how the constants were chosen.
Nothing in this file is itself a verification.

## 1. The collision damage constant `1/4`

`key_collision_damage` builds a two-position cache in which the quantiser maps
two distinct keys `a ≠ b` to one code, and uses the query `2/(a-b)` so that the
exact logit gap is exactly `2`.

| quantity | value |
|---|---|
| exact read-out `exp 2 / (exp 2 + 1)` | 0.880797… |
| quantised read-out (tie) | 0.5 |
| damage | 0.380797… |
| constant proved in Lean | `1/4` (uses only `exp 2 ≥ 3`) |

The proof deliberately weakens `0.3808` to `1/4` so that the only analytic input
is `2 + 1 ≤ exp 2`.

## 2. The bit-budget table (exact rationals)

`damage A bK bV = A/2^bK + 1/2^bV`, amplification `A = 16`, budget `bK+bV = 12`:

| bK | bV | damage |
|---|---|---|
| 0 | 12 | 16.000244 |
| 2 | 10 | 4.000977 |
| 4 | 8 | 1.003906 |
| 5 | 7 | 0.507813 |
| 6 | 6 | 0.265625 |
| 7 | 5 | 0.156250 |
| **8** | **4** | **0.125000** |
| 9 | 3 | 0.156250 |
| 10 | 2 | 0.265625 |
| 12 | 0 | 1.003906 |

The minimum is unique at K8/V4, and the symmetric K6/V6 split costs 2.125× more
at the same average of 6 bits. Both facts are theorems
(`k8v4_optimal`, `k8v4_beats_symmetric`); the reversed split K4/V8 is worse by a
factor above 8 (`k4v8_much_worse`). Also note the `13×` factor first guessed for
that last statement is **false** (1.625 > 1.0039) — it was corrected to `8×`
before formalisation.

## 3. Key term versus value term in the proved bound

Proved bound (`attn_kv_from_cache_resolution`), with `B = 1`:
`(exp(2·‖q‖₁·δ_K) − 1) · B + δ_V`, `δ_b = 2^{-b}`.

| ‖q‖₁ | bits | key term `exp(2η)−1` | value term `2^{-b}` | ratio |
|---|---|---|---|---|
| 16 | 4 | 6.389 | 0.0625 | 1.0e2 |
| 16 | 8 | 0.1331 | 0.0039 | 3.4e1 |
| 64 | 4 | 2.98e3 | 0.0625 | 4.8e4 |
| 64 | 8 | 0.6487 | 0.0039 | 1.7e2 |
| 256 | 4 | 7.9e13 | 0.0625 | 1.3e15 |
| 256 | 8 | 6.389 | 0.0039 | 1.6e3 |

At the plausible operating point `‖q‖₁ ≈ 64` the guaranteed key/value damage
ratio at 4 bits is `≈ 5·10⁴`, the same order as the `≈ 2.1·10⁵` ratio reported
in the NET-93 arms. This is the reason the reference scale `‖q‖₁ = 64`, `R = 1`,
`m = 1` was chosen for `eight_bits_safe_at_scale` /
`four_bits_destroy_the_decision`.

## 4. Counterexample hunt

* *Is a value codebook ever as damaging as a key codebook?* No: any perturbation
  of the values of size `δ` is provably absorbed with damage `≤ δ`
  (`attn_value_perturbation_le`), so no counterexample exists. The hunt instead
  produced the sharpness example `attn_value_perturbation_sharp`, where the
  constant `1` is attained.
* *Can a cleverer 4-bit codebook (scale + offset, or nonuniform) avoid the key
  collapse?* No: `no_codebook_rescues_keys` shows the failure depends only on the
  codebook's cardinality. This matches the empirical ranking, where `q4_1`
  (scale + offset) is marginally worse than raw `q4_0`.
* *Does the `2` in the margin criterion have slack?* No: it is exactly the
  constant in `strictTop_of_margin`, whose sharpness is already established in
  `Novelty/KVDecisionDissociation.lean` (`margin_factor_two_is_sharp`).

## 5. No OEIS entry

No integer sequence arises in this thread; the objects are perturbation bounds
and a discrete bit allocation, so an OEIS search is not applicable.
