# Computational evidence — SD-WALL-TEST (paper 102 thread)

All numbers below come from an exploratory script (plain floating point, 200 label shuffles,
`random.seed(0)`); they are **exploration, not verification**.  The verified statements are the
Lean theorems in `Catalog/Computation/FactorBlindness*.lean`, which build with no `sorry`.

## Setup

Population: the first 63 primes in `(50, 2000)`, all `n = 3906` ordered pairs `(p,q)` with
`p ≠ q`.  Label: the which-factor bit `p < q` (label entropy exactly `1.0000` bits).
Views tested:

| view | definition |
|---|---|
| product view | `N mod 713` where `N = p·q` |
| `(s,d)` hint view | `(p+q, |p−q|)` |
| joint residue labels | `((p+q) mod 3, (p·q) mod 3)` |

## 1. Observed readings against a 200-shuffle permutation null

| view | observed | null mean | null sd | z | distinct values |
|---|---|---|---|---|---|
| product (`N mod 713`) | 0.0000 | 0.1363 | 0.0070 | −19.50 | 639 |
| `(s,d)` hint view | 0.0000 | 0.4990 | 0.0116 | −43.13 | 1953 |
| joint residue labels | 0.0000 | 0.0004 | 0.0004 | −1.05 | 3 |

Every observed reading is **exactly zero**, which is the prediction of
`galoisBlind_zero_leakage` / `swapClosed_mutualInfo_eq_zero`: all three views are symmetric
functions of the pair, and the population is swap-closed and off-diagonal.  The permutation
null sits strictly *above* the observation in every case — the shuffled surrogate destroys the
involution and picks up plug-in inflation.  This is the sign of the effect that the reported
`z`-scores measure; nothing in the null is evidence of leakage.

## 2. Collision statistics and the sandwich

| view | distinct `d` | collisions | `collide/n` | `2(n−d)/n` bound | max fiber | `(1/n)∑ f log₂ f` |
|---|---|---|---|---|---|---|
| product | 639 | 3906 | 1.0000 | 1.6728 | 16 | 2.7660 |
| `(s,d)` | 1953 | 3906 | 1.0000 | 1.0000 | 2 | 1.0000 |
| residues | 3 | 3906 | 1.0000 | 1.9985 | 1984 | 10.4400 |

Three things to note, each matching a theorem:

* `collisionCount = n` for every symmetric view on this population — predicted exactly by
  `swapClosed_collisionCount_eq`, because the swap involution puts `i` and `σ i` in the same
  fiber.  The sandwich `hintedView_sandwich` is therefore *vacuous* here, and the exact-zero
  wall applies instead: the two regimes are complementary
  (`blindness_sparsity_dichotomy`).
* `2(n−d)/n` is an upper bound for `collide/n` in every row
  (`collisionCount_le_two_mul_excess`); the `(s,d)` row shows it is attained.
* The `(s,d)` view has **max fiber size 2** — it is injective on unordered pairs — so
  `pair_view_reading_within_one_bit` applies: any labelled sample seen through it must read
  within one bit of the label entropy, whatever the label alphabet.  This is the explanation
  of a reported `4.56` bits against a label entropy of `4.60`.

## 3. Counterexample hunt

* Is a positive plug-in reading ever evidence of dependence in this regime?  No counterexample
  to the sandwich was found; instead the extreme case is a theorem
  (`collision_bound_is_attained`): a constant view has `collisionCount = n` and loses the whole
  label entropy.
* Is the three-view reading ordering of the reported table monotone under refinement?  It is
  not — the joint-residue reading is *below* the product-view reading while neither refines
  the other — which is consistent with `hint_refinement_monotone`, since the joint-residue view
  is not a refinement of the product view.  Where the views really are nested, monotonicity is
  forced.

## 4. Sequences

No integer sequence worth an OEIS lookup arises: the counts here (`3906`, `1953`, `639`) are
artefacts of the chosen prime window, not of a combinatorial rule.
