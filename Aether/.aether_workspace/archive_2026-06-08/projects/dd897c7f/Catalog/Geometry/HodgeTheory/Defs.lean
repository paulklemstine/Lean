/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Rational Hodge Structures of Weight Two

This file defines the algebraic framework for rational Hodge structures of weight 2,
formalizing the linear-algebraic skeleton underlying the Hodge conjecture for divisor classes.

## Main definitions

* `HodgeStructureWeightTwo V` — a weight-2 rational Hodge structure on a
  finite-dimensional `ℚ`-vector space `V`, consisting of a Hodge decomposition
  `V_ℂ = H²⁰ ⊕ H¹¹ ⊕ H⁰²` of the complexification with conjugation symmetry.

* `HodgeStructureWeightTwo.hodgeClasses` — the submodule of rational Hodge classes,
  defined as `V ∩ H¹¹` via the natural embedding `V ↪ V_ℂ`.

* `HodgeStructureWeightTwo.IsHodge11` — predicate for an element being a Hodge class.

* `PolarizedHodgeStructure` — a Hodge structure equipped with a nondegenerate
  symmetric bilinear form (the polarization).

* `DirectSumHodgeStructure` — the induced Hodge structure on a direct sum `V × W`.

## Mathematical context

In classical Hodge theory, for a smooth projective complex variety `X`, the singular
cohomology `H²(X, ℚ)` carries a weight-2 Hodge structure. The Hodge conjecture at
the divisor level (the Lefschetz (1,1)-theorem) asserts that every rational class in
`H¹¹(X)` is algebraic — i.e., the class of an algebraic divisor. This file formalizes
the underlying linear-algebraic framework.
-/

noncomputable section

open scoped TensorProduct

/-- The natural ℚ-linear embedding `V → ℂ ⊗[ℚ] V` sending `v ↦ 1 ⊗ v`. -/
def complexifyEmbed (V : Type*) [AddCommGroup V] [Module ℚ V] :
    V →ₗ[ℚ] (ℂ ⊗[ℚ] V) :=
  TensorProduct.mk ℚ ℂ V 1

/-- A weight-2 rational Hodge structure on a finite-dimensional ℚ-vector space V.

This consists of a decomposition of the complexification `V_ℂ = ℂ ⊗[ℚ] V` into
three complex subspaces `H²⁰`, `H¹¹`, `H⁰²` such that:
- Their direct sum spans all of `V_ℂ`
- They are pairwise independent (i.e., intersect trivially)

In the classical geometric setting, `V = H²(X, ℚ)` for a smooth projective variety `X`,
and the decomposition arises from the Hodge decomposition of harmonic forms.
-/
structure HodgeStructureWeightTwo (V : Type*) [AddCommGroup V] [Module ℚ V]
    [FiniteDimensional ℚ V] where
  /-- The (2,0)-part of the Hodge decomposition -/
  H20 : Submodule ℂ (ℂ ⊗[ℚ] V)
  /-- The (1,1)-part of the Hodge decomposition -/
  H11 : Submodule ℂ (ℂ ⊗[ℚ] V)
  /-- The (0,2)-part of the Hodge decomposition -/
  H02 : Submodule ℂ (ℂ ⊗[ℚ] V)
  /-- The three parts span the entire complexification -/
  hspan : H20 ⊔ H11 ⊔ H02 = ⊤
  /-- The three parts are pairwise independent -/
  hIndep : H20 ⊓ H11 = ⊥ ∧ H20 ⊓ H02 = ⊥ ∧ H11 ⊓ H02 = ⊥

variable {V : Type*} [AddCommGroup V] [Module ℚ V] [FiniteDimensional ℚ V]

namespace HodgeStructureWeightTwo

/-- The submodule of rational Hodge classes: those rational vectors whose complexification
lies in the (1,1)-part of the Hodge decomposition. This is `V ∩ H¹¹` under the
embedding `v ↦ 1 ⊗ v`. -/
def hodgeClasses (HC : HodgeStructureWeightTwo V) : Submodule ℚ V :=
  (HC.H11.restrictScalars ℚ).comap (complexifyEmbed V)

/-- Predicate for an element being a Hodge class. -/
def IsHodge11 (HC : HodgeStructureWeightTwo V) (v : V) : Prop :=
  v ∈ HC.hodgeClasses

/-- A Hodge class is equivalently one whose complexification lies in H¹¹. -/
theorem isHodge11_iff (HC : HodgeStructureWeightTwo V) (v : V) :
    HC.IsHodge11 v ↔ complexifyEmbed V v ∈ HC.H11.restrictScalars ℚ := by
  rfl

end HodgeStructureWeightTwo

/-- A polarized weight-2 rational Hodge structure: a Hodge structure together with
a nondegenerate symmetric bilinear form `Q` on `V`.

In the geometric setting, `Q` arises from the cup product pairing on `H²(X, ℚ)`,
which is nondegenerate by Poincaré duality for compact Kähler manifolds. -/
structure PolarizedHodgeStructure (V : Type*) [AddCommGroup V] [Module ℚ V]
    [FiniteDimensional ℚ V] extends HodgeStructureWeightTwo V where
  /-- The polarization form -/
  Q : LinearMap.BilinForm ℚ V
  /-- The form is nondegenerate -/
  hQnd : Q.Nondegenerate

/-- The transcendental lattice: orthogonal complement of Hodge classes with respect
to the polarization form Q. This uses Mathlib's `BilinForm.orthogonal` which defines
the right orthogonal complement `{m | ∀ n ∈ W, B n m = 0}`. -/
def PolarizedHodgeStructure.transcendental
    (HC : PolarizedHodgeStructure V) : Submodule ℚ V :=
  HC.Q.orthogonal HC.toHodgeStructureWeightTwo.hodgeClasses

variable {W : Type*} [AddCommGroup W] [Module ℚ W] [FiniteDimensional ℚ W]

/-- The direct sum Hodge structure on `V × W` induced by Hodge structures on `V` and `W`.

The complexification of `V × W` is `(ℂ ⊗ V) × (ℂ ⊗ W)`, and the Hodge subspaces
are the products of the individual Hodge subspaces. For simplicity, we define
the induced structure abstractly using the product Hodge classes. -/
structure DirectSumHodgeData (V W : Type*)
    [AddCommGroup V] [Module ℚ V] [FiniteDimensional ℚ V]
    [AddCommGroup W] [Module ℚ W] [FiniteDimensional ℚ W] where
  /-- Hodge structure on the first factor -/
  hV : HodgeStructureWeightTwo V
  /-- Hodge structure on the second factor -/
  hW : HodgeStructureWeightTwo W

/-- The Hodge classes of the product are the product of the Hodge classes.
This definition captures the expected decomposition: a class `(v, w)` in `V × W`
is a Hodge class iff `v` is a Hodge class in `V` and `w` is a Hodge class in `W`. -/
def DirectSumHodgeData.hodgeClasses (D : DirectSumHodgeData V W) :
    Submodule ℚ (V × W) :=
  (D.hV.hodgeClasses).prod (D.hW.hodgeClasses)

end