/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The Price of Universality X: small cases and finite verification

Research thread *Compression Beyond the Pigeonhole Bound*, Phase A.

Lab notes for `Cryptography.UniversalRedundancyLibrary` and
`Cryptography.UniversalRedundancyMultiplicative`: a concrete four-model pool on
a three-letter alphabet, with exactly computed prices, together with a
kernel-checked finite verification (over all `16 × 16` pairs of libraries) of
the marginal value formula and of submodularity in an integer-scaled copy of the
same pool.

The pool is

| model | `p(a₀)` | `p(a₁)` | `p(a₂)` |
|-------|---------|---------|---------|
| `0`   | `1/2`   | `1/4`   | `1/4`   |
| `1`   | `1/4`   | `1/2`   | `1/4`   |
| `2`   | `1/3`   | `1/3`   | `1/3`   |
| `3`   | `0`     | `0`     | `1`     |

with exact Shtarkov sums `C{0} = 1`, `C{0,1} = 5/4`, `C{0,3} = 7/4`,
`C{0,1,3} = 2`; note `C{0,1,2} = 4/3 < C{0,3}`, i.e. the *uniform* model `2` is
nearly worthless next to `0` and `1`, whereas the degenerate model `3` is worth
`3/4` — a numerical illustration of "the marginal value of a model is the mass
on which it beats the incumbent envelope".

## Main results

* `SmallCases.prob_sum_one` — the pool consists of genuine sources;
* `SmallCases.shtarkov_singleton`, `SmallCases.shtarkov_zero_one`,
  `SmallCases.shtarkov_zero_three` — exact prices;
* `SmallCases.marginal_three_pos`, `SmallCases.marginal_three_value` — model `3`
  strictly earns its place, with marginal value exactly `3/4`;
* `SmallCases.marginal_formula_check`, `SmallCases.submodular_check` — finite
  kernel-checked verification over all pairs of libraries.

## Application keywords

universal compression, Shtarkov sum, submodularity, finite verification
-/

import Cryptography.UniversalRedundancyMultiplicative

open Finset Real

namespace UniversalRedundancy

namespace SmallCases

/-! ## A four-model pool on a three-letter alphabet -/

/-- The integer-scaled pool: `12 ·` the probabilities. -/
def scaled : Fin 4 → Fin 3 → ℤ
  | 0 => ![6, 3, 3]
  | 1 => ![3, 6, 3]
  | 2 => ![4, 4, 4]
  | 3 => ![0, 0, 12]

/-- The pool of four candidate models. -/
noncomputable def pool (i : Fin 4) (x : Fin 3) : ℝ := (scaled i x : ℝ) / 12

lemma pool_nonneg : ∀ i x, 0 ≤ pool i x := by
  intro i x
  fin_cases i <;> fin_cases x <;> norm_num [pool, scaled]

lemma prob_sum_one : ∀ i, ∑ x, pool i x = 1 := by
  intro i
  fin_cases i <;>
    simp [pool, scaled, Fin.sum_univ_three] <;> norm_num

/-! ## Exact prices of small libraries -/

lemma envelope_pair (i j : Fin 4) (x : Fin 3) :
    Library.envelope pool {i, j} x = max (pool i x) (pool j x) := by
  rw [show ({i, j} : Finset (Fin 4)) = insert i {j} from rfl, Library.envelope_insert,
    show ({j} : Finset (Fin 4)) = insert j ∅ from rfl, Library.envelope_insert]
  congr 1
  exact max_eq_left (by simpa using pool_nonneg j x)

/-- `C{0,1} = 5/4`: two "skewed" models overlap a lot, so the second is cheap. -/
theorem shtarkov_zero_one : Library.shtarkov pool {0, 1} = 5 / 4 := by
  rw [Library.shtarkov, Finset.sum_congr rfl fun x _ => envelope_pair 0 1 x]
  simp [Fin.sum_univ_three, pool, scaled]
  norm_num

/-- `C{0,3} = 7/4`: the degenerate model is worth `3/4` on top of model `0`. -/
theorem shtarkov_zero_three : Library.shtarkov pool {0, 3} = 7 / 4 := by
  rw [Library.shtarkov, Finset.sum_congr rfl fun x _ => envelope_pair 0 3 x]
  simp [Fin.sum_univ_three, pool, scaled]
  norm_num

/-- `C{0} = 1`: a single source needs no universality. -/
theorem shtarkov_singleton (i : Fin 4) : Library.shtarkov pool {i} = 1 := by
  have := Library.shtarkov_pair (P := pool) (hP0 := pool_nonneg) (hP1 := prob_sum_one) i i
  rw [show ({i, i} : Finset (Fin 4)) = {i} from by simp] at this
  rw [this, totalVariation]
  simp

/-- **A genuinely new model strictly raises the price.**  Model `3` (a point
mass on the last letter) beats the envelope of the library `{0}` there, so it
strictly increases the price of universality: `1 → 7/4`. -/
theorem marginal_three_pos :
    Library.shtarkov pool {0} < Library.shtarkov pool (insert 3 {0}) := by
  rw [Library.shtarkov_lt_insert_iff]
  refine ⟨2, ?_⟩
  rw [show ({0} : Finset (Fin 4)) = insert 0 ∅ from rfl, Library.envelope_insert]
  simp [pool, scaled]
  norm_num

/-- The exact marginal value of the degenerate model over `{0}` is `3/4` bits'
worth of Shtarkov mass. -/
theorem marginal_three_value :
    Library.shtarkov pool (insert 3 {0}) - Library.shtarkov pool {0} = 3 / 4 := by
  rw [show (insert 3 {0} : Finset (Fin 4)) = {0, 3} from by decide,
    shtarkov_zero_three, shtarkov_singleton]
  norm_num

/-! ## Finite kernel-checked verification

The following two statements verify, over *all* `16 × 16` pairs of libraries in
the integer-scaled copy of the pool, the marginal value formula
(`Library.shtarkov_insert_sub`) and additive submodularity
(`Library.shtarkov_submodular`).  They are decided by the kernel, and provide an
independent finite check of the general proofs. -/

/-- Integer-scaled envelope. -/
def envScaled (A : Finset (Fin 4)) (x : Fin 3) : ℤ := A.fold max 0 fun i => scaled i x

/-- Integer-scaled Shtarkov sum (`12 ·` the real one). -/
def priceScaled (A : Finset (Fin 4)) : ℤ := ∑ x, envScaled A x

set_option maxRecDepth 100000 in
/-- Finite check of the marginal value formula on all `16 · 4` insertions. -/
theorem marginal_formula_check :
    ∀ A : Finset (Fin 4), ∀ j, priceScaled (insert j A) - priceScaled A
      = ∑ x, max (scaled j x - envScaled A x) 0 := by
  decide

set_option maxRecDepth 100000 in
/-- Finite check of submodularity on all `16 × 16` pairs of libraries. -/
theorem submodular_check :
    ∀ A B : Finset (Fin 4),
      priceScaled (A ∪ B) + priceScaled (A ∩ B) ≤ priceScaled A + priceScaled B := by
  decide

set_option maxRecDepth 100000 in
/-- Finite check of diminishing returns on all nested pairs. -/
theorem diminishing_check :
    ∀ A B : Finset (Fin 4), A ⊆ B → ∀ j,
      priceScaled (insert j B) - priceScaled B
        ≤ priceScaled (insert j A) - priceScaled A := by
  decide

end SmallCases

end UniversalRedundancy