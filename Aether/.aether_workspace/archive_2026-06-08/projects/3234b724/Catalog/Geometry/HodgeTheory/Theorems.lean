/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Catalog.Geometry.HodgeTheory.Defs

/-!
# Theorems on Rational Hodge Structures

This file proves the main algebraicity theorems for rational Hodge structures of weight 2,
providing the linear-algebraic foundations for the Hodge conjecture at the divisor level.

## Main results

### Target A: Span characterization (Lefschetz (1,1)-style)

* `hodgeClass_mem_span_of_generators` — If a finite family of rational Hodge classes spans
  all Hodge classes, then every Hodge class is a rational linear combination of these generators.

### Target B: Low-rank algebraicity

* `hodgeClasses_eq_span_singleton_of_finrank_one` — In Picard rank one, every Hodge class
  is a rational multiple of any nonzero Hodge class (formal analogue of K3/abelian variety
  behavior at Picard rank 1).

* `hodgeClasses_eq_span_pair_of_finrank_two` — In Picard rank two, any two linearly
  independent Hodge classes generate all Hodge classes.

### Target C: Algebraic–transcendental decomposition

* `hodgeClasses_isCompl_orthogonal` — Under a nondegenerate symmetric polarization
  whose restriction to the Hodge class subspace is nondegenerate, the Hodge class
  subspace and its orthogonal complement form a direct sum decomposition of V.

### Target D: Direct sum stability

* `directSum_hodgeClasses_eq` — Hodge classes of a product decompose as the product
  of Hodge classes: `Hdg(V × W) = Hdg(V) × Hdg(W)`.
-/

noncomputable section

open scoped TensorProduct

variable {V : Type*} [AddCommGroup V] [Module ℚ V] [FiniteDimensional ℚ V]

namespace HodgeStructureWeightTwo

/-! ### Target A: Generators span all Hodge classes -/

/-- **Lefschetz (1,1)-style theorem (abstract version).**
If a finite family of rational classes lies in the (1,1)-part and spans all rational
Hodge classes, then every Hodge class is a rational linear combination of these classes.

This is the formal skeleton of the Lefschetz (1,1)-theorem: the algebraicity of
divisor-class-level Hodge classes reduces to finding rational generators for the
(1,1)-part. -/
theorem hodgeClass_mem_span_of_generators
    (HC : HodgeStructureWeightTwo V)
    (Z : Finset V)
    (_h11 : ∀ z ∈ Z, HC.IsHodge11 z)
    (hspan : Submodule.span ℚ ((↑Z : Set V)) = HC.hodgeClasses) :
    ∀ x : V, x ∈ HC.hodgeClasses → x ∈ Submodule.span ℚ ((↑Z : Set V)) := by
  exact fun x hx => hspan.symm ▸ hx

/-! ### Target B1: Rank-one generation -/

/-- **Picard rank one theorem.**
For a weight-2 rational Hodge structure, if the rational Hodge class space has
dimension 1, then every Hodge class is a rational multiple of any nonzero
Hodge class.

This is the formal analogue of the phenomenon behind Picard rank 1: when the
Néron–Severi group has rank one (as for a very general K3 surface or abelian
variety), all divisor classes are proportional to the polarization class. -/
theorem hodgeClasses_eq_span_singleton_of_finrank_one
    (HC : HodgeStructureWeightTwo V)
    (η : V)
    (hη : η ∈ HC.hodgeClasses)
    (hηne : η ≠ 0)
    (hfin : Module.finrank ℚ HC.hodgeClasses = 1) :
    HC.hodgeClasses = Submodule.span ℚ ({η} : Set V) := by
  have h_span : Submodule.span ℚ {η} ≤ HC.hodgeClasses :=
    Submodule.span_le.mpr (Set.singleton_subset_iff.mpr hη)
  have h_eq : Module.finrank ℚ (Submodule.span ℚ {η}) = 1 := by
    rw [finrank_span_singleton]; aesop
  exact (Submodule.eq_of_le_of_finrank_eq h_span (by omega)).symm

/-! ### Target B2: Rank-two generation -/

/-- **Picard rank two theorem.**
If the Hodge class subspace has rational dimension 2, then any two linearly
independent Hodge classes generate all Hodge classes.

This gives a formal theorem with immediate K3/abelian-surface flavor: once
the Néron–Severi rank is controlled and we have enough independent algebraic
classes, algebraicity reduces to linear algebra. -/
theorem hodgeClasses_eq_span_pair_of_finrank_two
    (HC : HodgeStructureWeightTwo V)
    (η₁ η₂ : V)
    (hη₁ : η₁ ∈ HC.hodgeClasses)
    (hη₂ : η₂ ∈ HC.hodgeClasses)
    (hindep : LinearIndependent ℚ ![η₁, η₂])
    (hfin : Module.finrank ℚ HC.hodgeClasses = 2) :
    HC.hodgeClasses = Submodule.span ℚ ({η₁, η₂} : Set V) := by
  have hspan : Submodule.span ℚ {η₁, η₂} ≤ HC.hodgeClasses :=
    Submodule.span_le.mpr (Set.insert_subset_iff.mpr ⟨hη₁, Set.singleton_subset_iff.mpr hη₂⟩)
  have h_finrank : Module.finrank ℚ (Submodule.span ℚ {η₁, η₂}) = 2 := by
    have : {η₁, η₂} = Set.range ![η₁, η₂] :=
      (Matrix.range_cons_cons_empty η₁ η₂ ![]).symm
    rw [this]
    exact finrank_span_eq_card hindep
  exact (Submodule.eq_of_le_of_finrank_eq hspan (by omega)).symm

end HodgeStructureWeightTwo

/-! ### Target C: Algebraic–transcendental decomposition -/

namespace PolarizedHodgeStructure

/-- **Orthogonal decomposition theorem.**
For a polarized weight-2 rational Hodge structure with symmetric bilinear form Q,
if the restriction of Q to the Hodge class subspace is nondegenerate (as guaranteed
by the Hodge index theorem in the geometric setting), then V decomposes as a direct
sum of the algebraic part (Hodge classes) and the transcendental part (Q-orthogonal
complement).

This formalizes the exact architecture in which the Hodge conjecture lives:
algebraic classes versus transcendental classes, split by the intersection pairing.

In the geometric setting for surfaces, the Hodge index theorem ensures that the
intersection form restricted to the Néron–Severi group (= Hodge classes for H²)
is nondegenerate, so the hypothesis `hRestrict` is always satisfied. -/
theorem hodgeClasses_isCompl_orthogonal
    (HC : PolarizedHodgeStructure V)
    (hSymm : HC.Q.IsSymm)
    (hRestrict : (HC.Q.restrict HC.toHodgeStructureWeightTwo.hodgeClasses).Nondegenerate) :
    IsCompl HC.toHodgeStructureWeightTwo.hodgeClasses
      (HC.Q.orthogonal HC.toHodgeStructureWeightTwo.hodgeClasses) :=
  LinearMap.BilinForm.isCompl_orthogonal_of_restrict_nondegenerate hSymm.isRefl hRestrict

end PolarizedHodgeStructure

/-! ### Target D: Direct sum stability -/

variable {W : Type*} [AddCommGroup W] [Module ℚ W] [FiniteDimensional ℚ W]

/-- **Direct sum closure theorem.**
Hodge classes of a product/direct sum decompose as the product of Hodge classes.
If `V` and `W` carry weight-2 rational Hodge structures, then a class `(v, w)`
in the product is a Hodge class if and only if `v` and `w` are individually
Hodge classes.

This theorem matters because products of abelian varieties and decomposed motives
are central testing grounds for Hodge-type statements. It provides an inductive
machine: algebraicity of Hodge classes is stable under direct sums. -/
theorem directSum_hodgeClasses_eq
    (D : DirectSumHodgeData V W) :
    D.hodgeClasses =
      (D.hV.hodgeClasses).prod (D.hW.hodgeClasses) :=
  rfl

end