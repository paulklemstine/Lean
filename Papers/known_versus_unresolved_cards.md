# Computational Evidence — Known versus unresolved cards

All numbers below were produced by exhaustive enumeration in Lean 4 (`#eval` over
`Equiv.Perm (Fin u)`, over all label functions `X → Bool`, and over all
`X → ZMod k`), i.e. by exact rational arithmetic, not by sampling. They were
computed *before* the corresponding theorems were proved and are reproduced here
as the Lab Notes of the experimental stage. Every claim listed here is now also
a machine-checked theorem in `Catalog/MachineLearning/KnownUnresolvedCards/`;
where a row is marked "theorem", the general statement is proved, not merely
observed.

## 1. Blind pass: total hits summed over all shuffles

`hits g σ = #{i : σ i = g i}`, summed over all `σ ∈ Perm (Fin u)`.

| `u` | strategy `g` | `∑_σ hits g σ` | `u!` | mean |
|----|---------------|----------------|------|------|
| 3 | `id` (injective) | 6 | 6 | 1 |
| 3 | `i ↦ i+1` (injective) | 6 | 6 | 1 |
| 3 | `i ↦ 2` (constant) | 6 | 6 | 1 |
| 4 | `id` | 24 | 24 | 1 |
| 5 | `i ↦ 3` if `i = 0` else `i` (non-injective) | 120 | 120 | 1 |

The mean is **exactly 1 for every strategy tried**, injective or not. This is
`sum_hits_eq_card_perm` (theorem, all `g`, all nonempty `α`). The sequence
`∑_σ hits = u!` is A000142; the refined distribution of the number of fixed
points is A008290.

## 2. Second moments: the mean is strategy-invariant, the variance is not

| `u` | strategy | `∑_σ hits²` | `2·u!` | variance |
|----|-----------|-------------|--------|----------|
| 4 | `id` | 48 | 48 | 1 |
| 5 | `id` | 240 | 240 | 1 |
| 5 | `i ↦ 1` (constant) | 120 | 240 | **0** |
| 4 | `[0,0,1,2]` | 44 | 48 | `5/6` |
| 5 | `[0,0,0,1,1]` | 192 | 240 | `3/5` |

A constant strategy scores exactly `1` with probability one. So the first moment
carries no information about the strategy while the second moment does:
`sum_hits_sq_eq_two_mul`, `Var_hits_injective`, `Var_hits_const`,
`mean_invariant_variance_not` (theorems).

The two non-injective rows suggested — and we then proved — the exact
**collision formula** `Var = D / (u(u-1))`, where `D` is the number of ordered
slot pairs receiving *distinct* calls: `10/(4·3) = 5/6` and `12/(5·4) = 3/5`,
matching the enumeration exactly (`sum_hits_sq_collision`, `Var_hits_collision`,
theorems).

## 3. Fair odds versus unit scoring

Total score of the unresolved block of size `u = 5`, averaged over all `120`
shuffles, with payout `w` on a hit and `l` on a miss:

| `(w, l)` | strategy | mean total |
|----------|----------|-----------|
| `(4, -1)` = fair odds | `id` | `0` |
| `(4, -1)` | constant `0` | `0` |
| `(1, 0)` = unit scoring | any | `1` |

Master formula `E = (w - l) + l·u` (`expected_deckScore`, theorem): it vanishes
iff `w = l(1-u)`, which for `l = -1` is exactly `w = u - 1`
(`fair_odds_iff`, theorem). Under unit scoring the unresolved block is worth
`+1` — one card, independent of `u`: this is the whole of the apparent "edge of
uncertainty", and it is an artefact of mispricing.

## 4. Feedback changes everything (except the fair-odds value)

Brute force over all `u!` shuffles, with the feedback strategy "call the
smallest card not yet seen":

| `u` | exact mean hits | `H_u` |
|----|------------------|-------|
| 1 | `1` | `1` |
| 2 | `3/2` | `3/2` |
| 3 | `11/6` | `11/6` |
| 4 | `25/12` | `25/12` |
| 5 | `137/60` | `137/60` |

Exact agreement with the harmonic numbers (A001008/A002805) —
`expScore_hits_eq_harmonic` (theorem). Contrast with row 1: blind = `1`,
informed = `H_u → ∞`. Yet at stagewise fair odds the informed game is still
worth exactly `0` (`expScore_fair_eq_zero`, theorem).

## 5. No Free Lunch, brute force

`X = Fin 3`, training set `T = {0, 1}`, uniform target `f : X → Bool`
(8 targets), score `+1/-1` per point.

| learner on the unseen point `2` | mean total score | `|T|` |
|--------------------------------|------------------|-------|
| always predict `false` | `2` | 2 |
| predict `f 0 && f 1` (uses training labels only) | `2` | 2 |
| **peek**: predict `f 2` | `3` | 2 |

So the conclusion is exactly `|T|` for every legitimate learner, and the
"depends only on the training labels" hypothesis is load-bearing
(`no_free_lunch_expected_score`, `training_dependence_is_necessary`, theorems).

`k`-ary check: `X = Fin 2`, `T = {0}`, labels in `ZMod 3`, fair odds `2 : -1`,
learner predicting `f 0` at the unseen point: mean total `= 2 = (k-1)·|T|`
(`no_free_lunch_kary_expected_score`, theorem).

## 6. Counterexample hunt

* Searched for a blind strategy on `u ≤ 5` with mean hits `≠ 1`: none exists
  (all `u!`-summed totals equal `u!`, over injective, constant and
  non-injective strategies). Consistent with the theorem, which covers *all*
  functions `g : α → α`.
* Searched for a scoring `(w, l)` other than `w = l(1-u)` with zero mean: none;
  the master formula is affine in `w` and `l`, so the zero set is exactly a
  hyperplane. The naive `(1, 0)` scoring is *not* on it, which is why the naive
  count shows a spurious `+1`.
* The doubling system was tested as an adversarial counterexample to
  "no edge": it wins with probability `1 - 2^{-n}` (e.g. `31/32` at `n = 5`) yet
  its expected gain is `0` (`prob_doubling_wins`, `E_doublingGain`, theorems).
  A high win *rate* is not an edge.
