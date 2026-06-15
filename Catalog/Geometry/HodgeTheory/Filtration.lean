/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# The Hodge Filtration as a Complete Invariant of a Weight-Two Hodge Structure

This file develops the **Hodge filtration / Hodge bigrading duality** for weight-two
rational Hodge structures, extending the catalog object `HodgeStructureWeightTwo`
(in `Catalog/Geometry/HodgeTheory/Defs.lean`).

Because this project's library is compiled file-by-file (each file imports only `Mathlib`),
the parent structure `HodgeStructureWeightTwo` and the embedding `complexifyEmbed` from
`Catalog/Geometry/HodgeTheory/Defs.lean` are reproduced verbatim below so that this file is
self-contained; the new content is the conjugation-aware structure and the filtration theory.

A pure Hodge structure can be described in two dual languages:

* the **decomposition** language — the bigrading `V_ℂ = H²⁰ ⊕ H¹¹ ⊕ H⁰²`;
* the **filtration** language — the decreasing *Hodge filtration*
  `F² ⊆ F¹ ⊆ F⁰ = V_ℂ` with `Fᵖ = ⊕_{i ≥ p} H^{i,2-i}`.

The central representation/duality theorem (`recover_H11`,
`filtration_determines_decomposition`) is that the filtration `F•`, *together with the
complex conjugation* coming from the real/rational structure, recovers the entire
bigrading via the **opposition** (Hodge-symmetry) formulae
`H^{p,q} = Fᵖ ∩ conj(F^q)`. Consequently the Hodge filtration is a *complete
invariant*: two Hodge structures with the same conjugation and the same filtration are
equal. This is the linear-algebraic shadow of the degeneration of the
Hodge-to-de Rham spectral sequence at `E₁`.

## Main definitions

* `HodgeStructureWeightTwoConj V` — a weight-two Hodge structure whose three pieces form
  a genuine internal direct sum and which is equipped with a conjugate-linear involution
  `conj` (complex conjugation) satisfying Hodge symmetry `conj H²⁰ = H⁰²`, `conj H¹¹ = H¹¹`.
* `HodgeStructureWeightTwoConj.F` — the decreasing Hodge filtration `F⁰ ⊇ F¹ ⊇ F²`.
* `HodgeStructureWeightTwoConj.conjMap` — the image of a subspace under conjugation.

## Main results

* `F_antitone` — `F` is a decreasing filtration.
* `conj_H02`, `conjF1_eq`, `conjF2_eq` — values of conjugation on the pieces and the
  filtration steps.
* `opposition` — the opposition relations: `F²` is complementary to `conj F¹`, and `F¹`
  is complementary to `conj F²` (`Fᵖ ⊕ conj F^{k-p+1} = V_ℂ`).
* `recover_H11` — the middle piece is reconstructed as `H¹¹ = F¹ ∩ conj F¹`.
* `filtration_determines_decomposition` — the Hodge filtration together with
  conjugation is a complete invariant of the Hodge structure.
-/

noncomputable section

open scoped TensorProduct
open Submodule

/-- The natural ℚ-linear embedding `V → ℂ ⊗[ℚ] V` sending `v ↦ 1 ⊗ v`.
(Reproduced from `Catalog/Geometry/HodgeTheory/Defs.lean`.) -/
def complexifyEmbed (V : Type*) [AddCommGroup V] [Module ℚ V] :
    V →ₗ[ℚ] (ℂ ⊗[ℚ] V) :=
  TensorProduct.mk ℚ ℂ V 1

/-- A weight-2 rational Hodge structure (reproduced from
`Catalog/Geometry/HodgeTheory/Defs.lean`): a decomposition of the complexification
`V_ℂ = H²⁰ ⊕ H¹¹ ⊕ H⁰²` whose pieces span and are pairwise independent. -/
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

-- !-- Lab Notebook -- !--
-- Hypothesis: A weight-2 Hodge structure is determined by its Hodge filtration F•
--   together with complex conjugation, via the opposition relations H^{p,q} = Fᵖ ∩ conj(F^q).
-- Result: Proved (recover_H11, filtration_determines_decomposition). The reconstruction of
--   the middle piece H¹¹ = F¹ ⊓ conj F¹ is a pure modular-lattice identity once one knows
--   the three pieces form an internal direct sum (hdir02) and conjugation respects the bigrading.
-- Insight: The catalog object `HodgeStructureWeightTwo` only required *pairwise* trivial
--   intersection, which is strictly weaker than an internal direct sum (three lines in a plane!).
--   Reconstruction genuinely needs the direct-sum hypotheses `hdir20/hdir11/hdir02`, which is
--   exactly the geometric content that the Hodge decomposition is a direct sum.
-- Failure analysis: An earlier plan tried to derive reconstruction from `hIndep` (pairwise)
--   alone; this is false in general, so the strengthened structure was introduced.
-- !-- Lab Notebook -- !--

/-- A weight-two rational Hodge structure that forms a genuine internal direct sum and is
equipped with complex conjugation (a conjugate-linear involution on the complexification)
satisfying Hodge symmetry.

This extends `HodgeStructureWeightTwo` (which only records a spanning, pairwise-independent
triple) with:
* the genuine **direct-sum** conditions `hdir20/hdir11/hdir02` (each piece meets the join of
  the other two trivially), and
* the **conjugation** `conj`, a `starRingEnd ℂ`-semilinear involution swapping `H²⁰ ↔ H⁰²`
  and fixing `H¹¹` (Hodge symmetry `H^{p,q} = conj H^{q,p}`). -/
structure HodgeStructureWeightTwoConj (V : Type*) [AddCommGroup V] [Module ℚ V]
    [FiniteDimensional ℚ V] extends HodgeStructureWeightTwo V where
  /-- `H²⁰` meets the join of the other two pieces trivially (internal direct sum). -/
  hdir20 : H20 ⊓ (H11 ⊔ H02) = ⊥
  /-- `H¹¹` meets the join of the other two pieces trivially (internal direct sum). -/
  hdir11 : H11 ⊓ (H20 ⊔ H02) = ⊥
  /-- `H⁰²` meets the join of the other two pieces trivially (internal direct sum). -/
  hdir02 : H02 ⊓ (H20 ⊔ H11) = ⊥
  /-- Complex conjugation on the complexification: a conjugate-linear automorphism. -/
  conj : (ℂ ⊗[ℚ] V) ≃ₛₗ[starRingEnd ℂ] (ℂ ⊗[ℚ] V)
  /-- Conjugation is an involution. -/
  conj_invol : ∀ x, conj (conj x) = x
  /-- Hodge symmetry: conjugation sends the `(2,0)`-part to the `(0,2)`-part. -/
  conj_H20 : H20.map conj.toLinearMap = H02
  /-- Hodge symmetry: conjugation preserves the `(1,1)`-part. -/
  conj_H11 : H11.map conj.toLinearMap = H11

namespace HodgeStructureWeightTwoConj

variable {V : Type*} [AddCommGroup V] [Module ℚ V] [FiniteDimensional ℚ V]
variable (HC : HodgeStructureWeightTwoConj V)

/-- The image of a subspace under complex conjugation. -/
def conjMap (S : Submodule ℂ (ℂ ⊗[ℚ] V)) : Submodule ℂ (ℂ ⊗[ℚ] V) :=
  S.map HC.conj.toLinearMap

/-- The decreasing **Hodge filtration** `F⁰ = V_ℂ ⊇ F¹ = H²⁰ ⊕ H¹¹ ⊇ F² = H²⁰`.
For `p ≥ 3` we set `Fᵖ = ⊥`. -/
def F : ℕ → Submodule ℂ (ℂ ⊗[ℚ] V)
  | 0 => ⊤
  | 1 => HC.H20 ⊔ HC.H11
  | 2 => HC.H20
  | _ => ⊥

/-
!-- comment -- !--
`F` is decreasing: each step is contained in the previous one, by definition and `le_sup_left`.
!-- comment -- !--

The Hodge filtration is a decreasing (antitone) filtration.
-/
theorem F_antitone : Antitone HC.F := by
  intro n m hnm;
  induction' m with m ih generalizing n;
  · aesop;
  · rcases hnm with ( rfl | hnm );
    · rfl;
    · rcases m with ( _ | _ | _ | m ) <;> simp_all +decide [ HodgeStructureWeightTwoConj.F ]

/-
!-- comment -- !--
Apply conjugation to `conj_H20` and use the involution `conj_invol` to flip it around.
!-- comment -- !--

Hodge symmetry, conjugate form: conjugation sends the `(0,2)`-part to the `(2,0)`-part.
-/
theorem conj_H02 : HC.H02.map HC.conj.toLinearMap = HC.H20 := by
  rw [ ←HC.conj_H20 ];
  rw [ ← Submodule.map_comp ];
  convert Submodule.map_id HC.H20;
  ext; simp +decide [ HC.conj_invol ] ;

/-
!-- comment -- !--
`conj` distributes over `⊔` (`Submodule.map_sup`); then substitute `conj_H20`, `conj_H11`.
!-- comment -- !--

The conjugate of `F¹ = H²⁰ ⊕ H¹¹` is `H⁰² ⊕ H¹¹`.
-/
theorem conjF1_eq : HC.conjMap (HC.F 1) = HC.H02 ⊔ HC.H11 := by
  rw [ HodgeStructureWeightTwoConj.F, HodgeStructureWeightTwoConj.conjMap ];
  rw [ ← HC.conj_H20, ← HC.conj_H11 ];
  rw [ ← Submodule.map_sup ];
  rw [ HC.conj_H11 ]

/-- The conjugate of `F² = H²⁰` is `H⁰²`. -/
theorem conjF2_eq : HC.conjMap (HC.F 2) = HC.H02 := HC.conj_H20

/-
!-- comment -- !--
Opposition: codisjointness is `hspan` reordered; disjointness is `hdir20` (resp. `hdir02`).
This is the linear-algebraic form of `Fᵖ ⊕ conj F^{k-p+1} = V_ℂ`.
!-- comment -- !--

**Opposition relations.** The Hodge filtration is *opposed* to its conjugate:
`F² ⊕ conj F¹ = V_ℂ` and `F¹ ⊕ conj F² = V_ℂ`.
-/
theorem opposition :
    IsCompl (HC.F 2) (HC.conjMap (HC.F 1)) ∧ IsCompl (HC.F 1) (HC.conjMap (HC.F 2)) := by
  constructor;
  · refine' ⟨ _, _ ⟩;
    · rw [ disjoint_iff ];
      convert HC.hdir20 using 1;
      rw [ HodgeStructureWeightTwoConj.conjF1_eq ];
      rw [ sup_comm, HodgeStructureWeightTwoConj.F ];
    · rw [ codisjoint_iff ];
      convert HC.hspan using 1;
      rw [ sup_comm, HC.conjF1_eq ];
      rw [ show HC.F 2 = HC.H20 from rfl ] ; ac_rfl;
  · refine' ⟨ _, _ ⟩;
    · simp +decide [ HC.conjF2_eq, disjoint_iff ];
      rw [ ← inf_comm, ← HC.hdir02 ];
      rfl;
    · convert codisjoint_iff.mpr _;
      convert HC.hspan using 1;
      exact congr_arg₂ ( · ⊔ · ) rfl ( conjF2_eq HC )

/-
!-- comment -- !--
Reconstruction of the middle piece: `(H20⊔H11) ⊓ (H02⊔H11) = H11` by the modular law
(`sup_inf_assoc_of_le`) using the direct-sum hypothesis `hdir02 : H02 ⊓ (H20 ⊔ H11) = ⊥`.
!-- comment -- !--

**Reconstruction of the `(1,1)`-part.** The middle Hodge piece is recovered from the
filtration and its conjugate: `H¹¹ = F¹ ∩ conj F¹`. This is the opposition formula
`H^{p,q} = Fᵖ ∩ conj F^q` in the case `p = q = 1`.
-/
theorem recover_H11 : HC.F 1 ⊓ HC.conjMap (HC.F 1) = HC.H11 := by
  -- Apply the modular law: since $H11 \leq H11 \⊔ H20$, we have $(H11 \⊔ H02) \⊔ (H11 \⊔ H20) = H11 \⊔ (H02 \⊔ (H11 \⊔ H20))$.
  have h_modular : (HC.H11 ⊔ HC.H02) ⊓ (HC.H11 ⊔ HC.H20) = HC.H11 ⊔ (HC.H02 ⊓ (HC.H11 ⊔ HC.H20)) := by
    rw [ ← sup_inf_assoc_of_le _ ( le_sup_left : HC.H11 ≤ HC.H11 ⊔ HC.H20 ) ];
  convert h_modular using 1;
  · convert inf_comm _ _ using 2;
    · rw [ HodgeStructureWeightTwoConj.conjF1_eq, sup_comm ];
    · exact sup_comm _ _;
  · have := HC.hdir02;
    simp_all +decide [ sup_comm, inf_comm ]

/-
!-- comment -- !--
Complete invariant: H20 = F², H02 = conj F², H11 = F¹ ⊓ conj F¹, so equal filtrations and
equal conjugations force equal bigradings. Combines `conjF2_eq` and `recover_H11`.
!-- comment -- !--

**The Hodge filtration is a complete invariant.** If two weight-two Hodge structures
(with conjugation) have the same complex conjugation and the same Hodge filtration, then
they have the same Hodge decomposition.
-/
theorem filtration_determines_decomposition
    (HC₁ HC₂ : HodgeStructureWeightTwoConj V)
    (hconj : HC₁.conj = HC₂.conj)
    (hF1 : HC₁.F 1 = HC₂.F 1) (hF2 : HC₁.F 2 = HC₂.F 2) :
    HC₁.H20 = HC₂.H20 ∧ HC₁.H11 = HC₂.H11 ∧ HC₁.H02 = HC₂.H02 := by
  refine' ⟨ _, _, _ ⟩;
  · convert hF2 using 1;
  · rw [ ← HC₁.recover_H11, ← HC₂.recover_H11, hF1 ];
    unfold HodgeStructureWeightTwoConj.conjMap; aesop;
  · rw [ ← HC₁.conjF2_eq, ← HC₂.conjF2_eq ];
    unfold HodgeStructureWeightTwoConj.conjMap; aesop;

/-
**Non-vacuity.** The theory is inhabited: the trivial (zero) module carries a
weight-two Hodge structure with conjugation. Hence the universally quantified results above
are not vacuous.
-/
theorem nonempty_of_trivial : Nonempty (HodgeStructureWeightTwoConj (Fin 0 → ℚ)) := by
  constructor;
  constructor;
  rotate_left;
  rotate_left;
  rotate_left;
  rotate_left;
  rotate_left;
  rotate_left;
  exact ⟨ ⊥, ⊥, ⊥, by simp +decide, by simp +decide ⟩;
  refine' { Equiv.ofBijective ( fun x => 0 ) ⟨ fun x => _, fun x => _ ⟩ with .. } <;> simp +decide;
  all_goals norm_num [ Submodule.eq_bot_iff ];
  · exact fun y => Subsingleton.elim _ _;
  · exact Subsingleton.elim _ _;
  · exact fun x => Subsingleton.elim _ _

end HodgeStructureWeightTwoConj

end