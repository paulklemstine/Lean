/-
# Weight-one rational Hodge structures: basic definitions

`Catalog/Geometry/Endomorphisms.lean` imports `Geometry.HodgeTheory.Defs` and uses three
notions from it — the data of a weight-one Hodge structure, the notion of a Hodge substructure,
and simplicity.  The module was missing from this checkout (the sibling file
`HodgeTheory_Defs.lean` is empty), so this file supplies exactly those three definitions, in
their standard form, so that the Schur-lemma results of `Endomorphisms.lean` compile against a
faithful notion rather than a placeholder.

A weight-one rational Hodge structure on a `ℚ`-vector space `V` is a decomposition of the
complexification `ℂ ⊗[ℚ] V` into two complementary `ℂ`-subspaces `H^{1,0}` and `H^{0,1}`.  A
rational subspace `S ⊆ V` is a *Hodge substructure* when its complexification is compatible with
that decomposition, i.e. is the sum of its intersections with the two pieces; the structure is
*simple* when the only Hodge substructures are `⊥` and `⊤`.
-/
import Mathlib

noncomputable section

open scoped TensorProduct

/-- The data of a weight-one Hodge structure on the rational vector space `V`: a decomposition
of the complexification `ℂ ⊗[ℚ] V` into two complementary `ℂ`-subspaces. -/
structure WeightOneHodgeData (V : Type*) [AddCommGroup V] [Module ℚ V] where
  /-- The `(1,0)` part of the complexification. -/
  H10 : Submodule ℂ (ℂ ⊗[ℚ] V)
  /-- The `(0,1)` part of the complexification. -/
  H01 : Submodule ℂ (ℂ ⊗[ℚ] V)
  /-- The two parts are complementary: `ℂ ⊗ V = H^{1,0} ⊕ H^{0,1}`. -/
  isCompl : IsCompl H10 H01

/-- The complexification `ℂ ⊗[ℚ] S ⊆ ℂ ⊗[ℚ] V` of a rational subspace `S ⊆ V`. -/
def complexifySubmodule {V : Type*} [AddCommGroup V] [Module ℚ V] (S : Submodule ℚ V) :
    Submodule ℂ (ℂ ⊗[ℚ] V) :=
  Submodule.span ℂ (Set.range fun s : S => (1 : ℂ) ⊗ₜ[ℚ] (s : V))

/-- A rational subspace is a *Hodge substructure* when its complexification is the sum of its
intersections with the two Hodge pieces, i.e. when it inherits the Hodge decomposition. -/
def IsHodgeSubstructure {V : Type*} [AddCommGroup V] [Module ℚ V]
    (HD : WeightOneHodgeData V) (S : Submodule ℚ V) : Prop :=
  complexifySubmodule S = (complexifySubmodule S ⊓ HD.H10) ⊔ (complexifySubmodule S ⊓ HD.H01)

/-- A weight-one Hodge structure is *simple* when its only Hodge substructures are the trivial
ones. -/
def IsSimpleHodgeStructure {V : Type*} [AddCommGroup V] [Module ℚ V]
    (HD : WeightOneHodgeData V) : Prop :=
  ∀ S : Submodule ℚ V, IsHodgeSubstructure HD S → S = ⊥ ∨ S = ⊤

/-- The zero subspace is a Hodge substructure of any weight-one Hodge structure. -/
theorem isHodgeSubstructure_bot {V : Type*} [AddCommGroup V] [Module ℚ V]
    (HD : WeightOneHodgeData V) : IsHodgeSubstructure HD (⊥ : Submodule ℚ V) := by
  have hbot : complexifySubmodule (⊥ : Submodule ℚ V) = (⊥ : Submodule ℂ (ℂ ⊗[ℚ] V)) := by
    rw [complexifySubmodule, Submodule.span_eq_bot]
    rintro x ⟨s, rfl⟩
    have hs : (s : V) = 0 := Submodule.mem_bot ℚ |>.mp s.2
    simp [hs]
  rw [IsHodgeSubstructure, hbot]
  simp

end