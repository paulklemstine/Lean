# Computational Evidence — marginal value and submodularity of the Shtarkov sum

All computations below were performed inside Lean with exact arithmetic
(rationals / integers), before and while the general theorems were proved.
The **kernel-checked** items are the ones that also appear as theorems in
`Catalog/Cryptography/UniversalRedundancySmallCases.lean`
(`marginal_formula_check`, `submodular_check`, `diminishing_check`); the ones
labelled *evaluated* were run through Lean's evaluator only and are recorded
here as exploratory data.

## 1. The test pool

Four candidate models on a three-letter alphabet `X = {a₀,a₁,a₂}`:

| model | `p(a₀)` | `p(a₁)` | `p(a₂)` |
|-------|---------|---------|---------|
| `0`   | `1/2`   | `1/4`   | `1/4`   |
| `1`   | `1/4`   | `1/2`   | `1/4`   |
| `2`   | `1/3`   | `1/3`   | `1/3`   |
| `3`   | `0`     | `0`     | `1`     |

Library price `C(A) = ∑ₓ maxᵢ∈A pᵢ(x)` (with `C(∅) = 0`).

## 2. Exact prices of all 16 libraries (evaluated, exact ℚ)

| `A` | `C(A)` | `A` | `C(A)` |
|-----|--------|-----|--------|
| `∅` | `0` | `{0,3}` | `7/4` |
| `{0}` | `1` | `{1,2}` | `7/6` |
| `{1}` | `1` | `{1,3}` | `7/4` |
| `{2}` | `1` | `{2,3}` | `5/3` |
| `{3}` | `1` | `{0,1,2}` | `4/3` |
| `{0,1}` | `5/4` | `{0,1,3}` | `2` |
| `{0,2}` | `7/6` | `{0,2,3}` | `11/6` |
| | | `{1,2,3}` | `11/6` |
| | | `{0,1,2,3}` | `2` |

Observations that shaped the theory:

* every singleton has `C = 1` — the price of universality vanishes exactly on
  degenerate (one-source) libraries, matching `shtarkovSum_eq_one_iff`;
* the *uniform* model `2` is nearly worthless next to `{0,1}`
  (`C{0,1} = 5/4 → C{0,1,2} = 4/3`, marginal `1/12`), while the degenerate model
  `3` is worth `3/4` on top of `{0}` — precisely the "mass on which the new
  model beats the incumbent envelope";
* `C{0,1,2,3} = C{0,1,3} = 2`: model `2` is *free* once `{0,1,3}` is present,
  i.e. it is pointwise dominated by the envelope — the equality case of
  `shtarkovSum_addSource_eq_iff`.

## 3. Universal checks on the pool

Scaled to integers (`12 ×` probabilities) so that the kernel can decide them:

| claim | quantifier range | result |
|-------|------------------|--------|
| `C(A ∪ {j}) − C(A) = ∑ₓ (pⱼ(x) − env_A(x))⁺` | all `16 · 4` insertions | **true** (kernel) |
| `C(A ∪ B) + C(A ∩ B) ≤ C(A) + C(B)` | all `16 × 16` pairs | **true** (kernel) |
| `A ⊆ B → C(B∪{j}) − C(B) ≤ C(A∪{j}) − C(A)` | all nested pairs, all `j` | **true** (kernel) |
| `C(A ∪ B) · C(A ∩ B) ≤ C(A) · C(B)` | all `16 × 16` pairs (ℚ) | **true** (evaluated) |

No counterexample was found to any of the four claims; all four are now theorems
(`Library.shtarkov_insert_sub`, `Library.shtarkov_submodular`,
`Library.shtarkov_diminishing`, `Library.shtarkov_mul_submodular`).

## 4. Counterexample hunt: the bit-level statement

The additive and multiplicative forms survive unconditionally, but the
*logarithmic* form does **not**.  Searching pairs with empty intersection
immediately produces a failure: two point masses on distinct letters give

`C({p}) = C({q}) = 1`, `C({p,q}) = 2`, `C(∅) = 0`,

so in bits `log₂ 2 + log₂ 0 = 1 + (−∞)`, and a real-valued implementation that
truncates `log 0` to `0` reads `1 ≤ 0`, which is false.  This boundary is
formalised as `Library.price_not_submodular_of_disjoint`, and the guarded
statement `Library.price_submodular` carries the hypothesis `C(A ∩ B) > 0`.

## 5. Greedy behaviour on the pool

Optimal libraries by size: `1 → 1`, `2 → 7/4` (`{0,3}` or `{1,3}`),
`3 → 2` (`{0,1,3}`).  The greedy run starts from a tie among the singletons
(all worth `1`), then adds model `3` (marginal `3/4`, the largest available),
reaching `7/4` — the exact optimum at size `2` — and then reaches `2` at size
`3`.  Greedy is optimal on this pool, comfortably inside the proved
`(1 − 1/e)` guarantee (`Library.greedy_one_sub_inv_exp_le`).

## 6. OEIS

No integer sequence arises: the objects here are real-valued set functions on
model libraries, and the small-case values (`1, 5/4, 7/6, 7/4, 4/3, 2, …`) are
pool-dependent rationals rather than a canonical sequence.  No OEIS search was
therefore applicable.
