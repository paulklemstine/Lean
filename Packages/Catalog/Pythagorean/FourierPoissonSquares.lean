/-
# Quadratic residue sets are never Poisson (except trivially)

The residue sets that govern the classical theory of Pythagorean triples — the squares
modulo `n` — are the natural test case for the converse of Poisson summation proved in
`Catalog.Pythagorean.FourierPoissonConverse`.  They are almost never subgroups, so by the
classification they never satisfy an exact Poisson summation formula, and the gap theorem
turns this qualitative failure into an explicit numerical lower bound.

Main results:

* `FourierFA.squaresF` : the set of squares in `ZMod n`.
* `FourierFA.poissonSet_squaresF_two`, `FourierFA.not_poissonSet_squaresF_three` …
  `FourierFA.not_poissonSet_squaresF_eight` : the squares mod `n` form a Poisson set for
  `n = 1, 2` and fail to for `3 ≤ n ≤ 8`.
* `FourierFA.closureF_squares_zmod8` : the squares mod `8` generate all of `ZMod 8`.
* `FourierFA.poisson_gap_squares_zmod8` : a **quantitative** failure — some Dirac delta
  supported on the squares mod `8` has Poisson defect of modulus at least `5`.  So the error
  in any attempted Poisson-type formula over the quadratic residues mod `8` is of the same
  order as the group itself, not a small perturbation.
-/

import Mathlib
import Pythagorean.FourierPoissonLattice

open Finset Fintype ComplexConjugate
open scoped Classical

namespace FourierFA

/-- The set of squares in `ZMod n`. -/
def squaresF (n : ℕ) [NeZero n] : Finset (ZMod n) := Finset.univ.image (fun a => a ^ 2)

/-- Modulo `2` every residue is a square, so the squares form a (trivial) Poisson set. -/
theorem poissonSet_squaresF_two : PoissonSet (squaresF 2) := by
  rw [poissonSet_iff_comb]
  refine Or.inr ⟨by decide, by decide⟩

theorem poissonSet_squaresF_one : PoissonSet (squaresF 1) := by
  rw [poissonSet_iff_comb]
  refine Or.inr ⟨by decide, by decide⟩

theorem not_poissonSet_squaresF_three : ¬ PoissonSet (squaresF 3) := by
  rw [poissonSet_iff_comb]
  intro h
  rcases h with h | ⟨-, hsub⟩
  · revert h; decide
  · have := hsub 0 (by decide) 1 (by decide)
    revert this; decide

theorem not_poissonSet_squaresF_four : ¬ PoissonSet (squaresF 4) := by
  rw [poissonSet_iff_comb]
  intro h
  rcases h with h | ⟨-, hsub⟩
  · revert h; decide
  · have := hsub 0 (by decide) 1 (by decide)
    revert this; decide

theorem not_poissonSet_squaresF_five : ¬ PoissonSet (squaresF 5) := by
  rw [poissonSet_iff_comb]
  intro h
  rcases h with h | ⟨-, hsub⟩
  · revert h; decide
  · have := hsub 1 (by decide) 4 (by decide)
    revert this; decide

theorem not_poissonSet_squaresF_six : ¬ PoissonSet (squaresF 6) := by
  rw [poissonSet_iff_comb]
  intro h
  rcases h with h | ⟨-, hsub⟩
  · revert h; decide
  · have := hsub 3 (by decide) 4 (by decide)
    revert this; decide

theorem not_poissonSet_squaresF_seven : ¬ PoissonSet (squaresF 7) := by
  rw [poissonSet_iff_comb]
  intro h
  rcases h with h | ⟨-, hsub⟩
  · revert h; decide
  · have := hsub 1 (by decide) 2 (by decide)
    revert this; decide

theorem not_poissonSet_squaresF_eight : ¬ PoissonSet (squaresF 8) := by
  rw [poissonSet_iff_comb]
  intro h
  rcases h with h | ⟨-, hsub⟩
  · revert h; decide
  · have := hsub 1 (by decide) 4 (by decide)
    revert this; decide

/-! ## A quantitative failure for the squares mod `8` -/

/-- The squares mod `8` are `{0, 1, 4}`. -/
theorem squaresF_eight : squaresF 8 = ({0, 1, 4} : Finset (ZMod 8)) := by decide

/-- Since `1` is a square, the squares mod `8` generate the whole group. -/
theorem closureF_squares_zmod8 : closureF ({0, 1, 4} : Finset (ZMod 8)) = Finset.univ := by
  refine Finset.eq_univ_iff_forall.2 fun x => ?_
  have h1 : (1 : ZMod 8) ∈ closureS ({0, 1, 4} : Finset (ZMod 8)) :=
    AddSubgroup.subset_closure (by simp)
  have hx : x = (x.val : ℕ) • (1 : ZMod 8) := by
    rw [nsmul_eq_mul, mul_one, ZMod.natCast_val, ZMod.cast_id]
  rw [mem_closureF, hx]
  exact AddSubgroup.nsmul_mem _ h1 _

/-- **Quantitative failure of Poisson summation over the quadratic residues mod `8`.**
Some Dirac delta supported on `{0,1,4}` has Poisson defect of modulus at least `5 = 8 - 3`. -/
theorem poisson_gap_squares_zmod8 :
    ∃ y₀ ∈ ({0, 1, 4} : Finset (ZMod 8)),
      (5 : ℝ) ≤ ‖poissonDefect ({0, 1, 4} : Finset (ZMod 8)) (delta y₀)‖ := by
  have hne : ({0, 1, 4} : Finset (ZMod 8)) ≠ closureF ({0, 1, 4} : Finset (ZMod 8)) := by
    rw [closureF_squares_zmod8]
    decide
  obtain ⟨y, hy, hb⟩ := poisson_gap ⟨0, by decide⟩ hne
  refine ⟨y, hy, le_trans (le_of_eq ?_) hb⟩
  rw [closureF_squares_zmod8]
  have h8 : (Finset.univ : Finset (ZMod 8)).card = 8 := by decide
  have h3 : ({0, 1, 4} : Finset (ZMod 8)).card = 3 := by decide
  rw [h8, h3]
  norm_num

end FourierFA