/-
Copyright (c) 2026. Released under Apache 2.0 license.
-/
import Novelty.WeightMonodromyFormality
import Novelty.WeightMonodromyCohomologyAlgebra

/-!
# Consistency and independence of the purity hypothesis

Companion to `Catalog/Novelty/WeightMonodromyFormality.lean`.  The formality theorem there is
conditional on purity of the weight grading (the algebraic content of the weight-monodromy
conjecture).  Two explicit examples show that this hypothesis is neither vacuous nor automatic.

* `diagonalDGA` : the group algebra `k[ℤ]`, bigraded by `n ↦ (n, n)` with zero differential, is
  a weight-graded dg-algebra which **is** pure (`diagonalDGA_isWeightPure`) and has non-trivial
  cohomology in every degree (`diagonalDGA_nontrivial_cohomology`).  So the hypotheses of
  `formality_of_weight_purity` are satisfiable by objects with non-zero cohomology algebra.

* `squareDGA` : the group algebra `k[ℤ × ℤ]`, bigraded by the identity with zero differential,
  is a weight-graded dg-algebra which is **not** pure (`squareDGA_not_isWeightPure`): it carries
  cohomology in bidegrees off the diagonal.  So purity is a genuine restriction.
-/

namespace WeightMonodromy

namespace Examples

open AddMonoidAlgebra

variable (k : Type*) [Field k]

/-! ### A pure example: `k[ℤ]` concentrated on the diagonal -/

/-- The diagonal embedding `ℤ → ℤ × ℤ`, used to place `k[ℤ]` on the diagonal
`weight = degree`. -/
def diagHom : ℤ →+ (ℤ × ℤ) where
  toFun n := (n, n)
  map_zero' := rfl
  map_add' := by intros; simp

/-- `k[ℤ]` bigraded by `n ↦ (n, n)`. -/
noncomputable def diagGrading : ℤ × ℤ → Submodule k (AddMonoidAlgebra k ℤ) :=
  AddMonoidAlgebra.gradeBy k ⇑diagHom

noncomputable instance : GradedAlgebra (diagGrading k) :=
  AddMonoidAlgebra.gradeBy.gradedAlgebra diagHom

/-- Off the diagonal the grading is zero. -/
lemma diagGrading_offDiag {n w : ℤ} (h : n ≠ w) {a : AddMonoidAlgebra k ℤ}
    (ha : a ∈ diagGrading k (n, w)) : a = 0 := by
  rw [diagGrading, AddMonoidAlgebra.mem_gradeBy_iff] at ha
  have hemp : (a.support : Set ℤ) = ∅ := by
    refine Set.eq_empty_of_subset_empty (ha.trans ?_)
    intro x hx
    simp only [Set.mem_preimage, Set.mem_singleton_iff] at hx
    have hxn : x = n ∧ x = w := by simpa [diagHom, Prod.ext_iff] using hx
    exact absurd (hxn.1 ▸ hxn.2) h
  simpa using Finsupp.support_eq_empty.mp (by exact_mod_cast hemp)

/-- The zero differential makes `k[ℤ]` (diagonally bigraded) a weight-graded dg-algebra. -/
noncomputable def diagonalDGA : WeightedDGA (diagGrading k) where
  d := 0
  sgn := fun _ => 1
  sgn_ne_zero := fun _ => one_ne_zero
  d_mem := by intro i a _; simp
  d_comp_d := by intro a; simp
  leibniz := by intro n w a b _; simp

/-- The diagonal example is pure: there is nothing off the diagonal to obstruct purity. -/
theorem diagonalDGA_isWeightPure : IsWeightPure (diagonalDGA k) := by
  intro n w hne a ha _
  refine ⟨0, Submodule.zero_mem _, ?_⟩
  have : a = 0 := diagGrading_offDiag k hne ha
  simp [diagonalDGA, this]

/-- Purity therefore produces a strict formality zig-zag for this example. -/
noncomputable def diagonalDGA_formality : StrictFormalityData (diagonalDGA k) :=
  formality_of_weight_purity (diagonalDGA k) (diagonalDGA_isWeightPure k)

/-- The example is not degenerate: in every degree `n` it has a cohomology class which is not a
coboundary, namely the group-like element `X^n`. -/
theorem diagonalDGA_nontrivial_cohomology (n : ℤ) :
    ∃ a : AddMonoidAlgebra k ℤ, a ∈ diagAlg (diagonalDGA k) ∧ a ≠ 0 ∧
      (diagonalDGA k).d a = 0 ∧ ∀ c, a ≠ (diagonalDGA k).d c := by
  refine ⟨Finsupp.single n 1, ?_, ?_, by simp [diagonalDGA], ?_⟩
  · refine mem_diagAlg (diagonalDGA k) (n := n) ?_ (by simp [diagonalDGA])
    rw [diagGrading, AddMonoidAlgebra.mem_gradeBy_iff]
    intro x hx
    have : x = n := by simpa using Finsupp.support_single_subset hx
    simp [this, diagHom]
  · exact Finsupp.single_ne_zero.mpr one_ne_zero
  · intro c hc
    have : (Finsupp.single n (1 : k)) = 0 := by simpa [diagonalDGA] using hc
    exact (Finsupp.single_ne_zero.mpr one_ne_zero) this

/-! ### A non-pure example: `k[ℤ × ℤ]` with the tautological bigrading -/

/-- `k[ℤ × ℤ]` bigraded by the identity: degree and weight are independent. -/
noncomputable def squareGrading : ℤ × ℤ → Submodule k (AddMonoidAlgebra k (ℤ × ℤ)) :=
  AddMonoidAlgebra.gradeBy k ⇑(AddMonoidHom.id (ℤ × ℤ))

noncomputable instance : GradedAlgebra (squareGrading k) :=
  AddMonoidAlgebra.gradeBy.gradedAlgebra (AddMonoidHom.id (ℤ × ℤ))

/-- The zero differential on `k[ℤ × ℤ]`. -/
noncomputable def squareDGA : WeightedDGA (squareGrading k) where
  d := 0
  sgn := fun _ => 1
  sgn_ne_zero := fun _ => one_ne_zero
  d_mem := by intro i a _; simp
  d_comp_d := by intro a; simp
  leibniz := by intro n w a b _; simp

/-- Purity fails for the tautologically bigraded group algebra: the class of `X^{(0,1)}` lives
in bidegree `(0, 1)`, off the diagonal, and is not a coboundary.  Hence the purity hypothesis of
`formality_of_weight_purity` is a genuine restriction, not a theorem. -/
theorem squareDGA_not_isWeightPure : ¬ IsWeightPure (squareDGA k) := by
  intro hpure
  have hmem : (Finsupp.single ((0 : ℤ), (1 : ℤ)) (1 : k)) ∈ squareGrading k (0, 1) := by
    rw [squareGrading, AddMonoidAlgebra.mem_gradeBy_iff]
    intro x hx
    have : x = ((0 : ℤ), (1 : ℤ)) := by simpa using Finsupp.support_single_subset hx
    simp [this]
  obtain ⟨c, -, hc⟩ := hpure 0 1 (by norm_num) _ hmem (by simp [squareDGA])
  have : (Finsupp.single ((0 : ℤ), (1 : ℤ)) (1 : k)) = 0 := by
    simpa [squareDGA] using hc.symm
  exact (Finsupp.single_ne_zero.mpr one_ne_zero) this

end Examples

end WeightMonodromy