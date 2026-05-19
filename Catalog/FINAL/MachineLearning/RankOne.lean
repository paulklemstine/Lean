import Mathlib
import FormalHodge.Basic

/-!
# Rank-One Uniqueness for Hodge Classes

## Main results

* `hodgeClasses_rank_one_unique`: If the Picard rank is 1, then any two nonzero
  Hodge classes are rational multiples of each other.
* `polarization_class_spans_hodgeClasses`: Under Picard rank 1, a nonzero Hodge class
  spans the entire Hodge class submodule.
* `picard_rank_one_all_hodge_classes_are_multiples`: Equivalent reformulation.

These are purely linear-algebraic consequences of having a 1-dimensional ℚ-subspace.
The Hodge-theoretic content is entirely in the *definition* of the subspace.
-/

noncomputable section

open scoped TensorProduct

variable {V : Type*} [AddCommGroup V] [Module ℚ V] [FiniteDimensional ℚ V]

/-! ## General lemma: rank-1 submodules have proportional elements -/

/-
In a one-dimensional submodule over a field, any two nonzero elements are
    scalar multiples of each other.
-/
theorem Submodule.exists_rat_smul_of_finrank_one {W : Submodule ℚ V}
    (hdim : Module.finrank ℚ W = 1)
    {x y : V} (hx : x ∈ W) (hy : y ∈ W) (hx0 : x ≠ 0) (hy0 : y ≠ 0) :
    ∃ q : ℚ, q ≠ 0 ∧ y = q • x := by
  have h_basis : ∀ w ∈ W, ∃ q : ℚ, w = q • x := by
    have h_basis : Submodule.span ℚ {x} = W := by
      refine' Submodule.eq_of_le_of_finrank_eq _ _;
      · exact Submodule.span_le.mpr ( Set.singleton_subset_iff.mpr hx );
      · rw [ hdim, finrank_span_singleton ] ; aesop;
    exact fun w hw => by rw [ ← h_basis ] at hw; exact Submodule.mem_span_singleton.mp hw |> fun ⟨ q, hq ⟩ => ⟨ q, hq.symm ⟩ ;
  exact Exists.elim ( h_basis y hy ) fun q hq => ⟨ q, by aesop_cat, hq ⟩

/-
A one-dimensional submodule is spanned by any nonzero element.
-/
theorem Submodule.span_singleton_eq_of_finrank_one {W : Submodule ℚ V}
    (hdim : Module.finrank ℚ W = 1)
    {x : V} (hx : x ∈ W) (hx0 : x ≠ 0) :
    W = Submodule.span ℚ ({x} : Set V) := by
  have h_subspace : Module.finrank ℚ (ℚ ∙ x) = 1 := by
    rw [ finrank_span_singleton hx0 ];
  have := Submodule.eq_of_le_of_finrank_eq ( show ℚ ∙ x ≤ W from Submodule.span_le.mpr ( Set.singleton_subset_iff.mpr hx ) );
  exact Eq.symm ( this ( h_subspace.trans hdim.symm ) )

/-! ## Theorem A1: Rank-one uniqueness -/

/-- **Theorem A1 (Rank-one uniqueness).** If the Picard rank of a weight-2 Hodge structure
is 1, then any two nonzero Hodge classes are rational multiples of each other. -/
theorem hodgeClasses_rank_one_unique
    (HD : WeightTwoHodgeData V)
    (hdim : Module.finrank ℚ (HodgeClasses HD) = 1)
    {x y : V}
    (hx : x ∈ HodgeClasses HD) (hy : y ∈ HodgeClasses HD)
    (hx0 : x ≠ 0) (hy0 : y ≠ 0) :
    ∃ q : ℚ, q ≠ 0 ∧ y = q • x :=
  Submodule.exists_rat_smul_of_finrank_one hdim hx hy hx0 hy0

/-! ## Theorem A2: Polarization class spans Hodge classes -/

/-- **Theorem A2 (Polarization class spans).** If ω is a nonzero Hodge class and the
Picard rank is 1, then the Hodge classes equal ℚ·ω. -/
theorem polarization_class_spans_hodgeClasses
    (HD : WeightTwoHodgeData V)
    (ω : V)
    (hω : ω ∈ HodgeClasses HD)
    (hω0 : ω ≠ 0)
    (hdim : Module.finrank ℚ (HodgeClasses HD) = 1) :
    HodgeClasses HD = Submodule.span ℚ ({ω} : Set V) :=
  Submodule.span_singleton_eq_of_finrank_one hdim hω hω0

/-! ## Equivalent reformulation -/

/-- **Picard rank one implies all Hodge classes are multiples.** -/
theorem picard_rank_one_all_hodge_classes_are_multiples
    (HD : WeightTwoHodgeData V)
    (hρ : Module.finrank ℚ (HodgeClasses HD) = 1) :
    ∀ x ∈ HodgeClasses HD, ∀ y ∈ HodgeClasses HD,
      x ≠ 0 → y ≠ 0 → ∃ q : ℚ, q ≠ 0 ∧ y = q • x := by
  intro x hx y hy hx0 hy0
  exact hodgeClasses_rank_one_unique HD hρ hx hy hx0 hy0

end