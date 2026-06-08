/-
Copyright (c) 2024 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Aristotle (Harmonic)
-/
import Mathlib

/-!
# Matroid Minors and the Robertson-Seymour Conjecture for Representable Matroids

This file develops the theory of matroid minors, minor-closed properties, and their
characterization by forbidden minors. We formalize:

1. **Minor-closed predicates** and the notion of excluded minors
2. **The dual-minor correspondence**: duality commutes with the minor relation
3. **WQO implies finite forbidden minor characterization**: the key structural theorem
4. **Antichain finiteness** from well-quasi-ordering

## Main Results

* `MatroidMinor.dual_isMinor_dual` — if N ≤m M then N✶ ≤m M✶
* `MatroidMinor.excluded_minors_antichain` — excluded minors form an antichain
* `MatroidMinor.wqo_implies_finite_antichains` — WQO implies all antichains are finite
* `MatroidMinor.dual_minor_closed` — duality preserves minor-closure

## References

* Robertson, N. and Seymour, P.D., "Graph Minors. XX. Wagner's conjecture", JCTB 2004
* Geelen, J., Gerards, B., Whittle, G., "Solving Rota's Conjecture", Notices AMS 2014
-/

open Set Matroid

noncomputable section

namespace MatroidMinor

variable {α : Type*}

/-! ## Minor-Closed Predicates -/

/-- A predicate on matroids is **minor-closed** if whenever `M` satisfies the predicate
and `N` is a minor of `M`, then `N` also satisfies the predicate. -/
def IsMinorClosed (P : Matroid α → Prop) : Prop :=
  ∀ ⦃M N : Matroid α⦄, P M → N ≤m M → P N

/-- An **excluded minor** for a minor-closed property `P` is a matroid that does not
satisfy `P`, but every proper minor does satisfy `P`. -/
def IsExcludedMinor (P : Matroid α → Prop) (M : Matroid α) : Prop :=
  ¬ P M ∧ ∀ ⦃N : Matroid α⦄, N <m M → P N

/-! ## Dual-Minor Correspondence -/

/-
**Dual-Minor Theorem**: If `N` is a minor of `M`, then `N✶` is a minor of `M✶`.
This is a fundamental result in matroid theory showing that duality commutes with
the minor relation.

The proof uses the fact that `(M ／ C ＼ D)✶ = M✶ ＼ C ／ D`, so if `N = M ／ C ＼ D`,
then `N✶ = M✶ ＼ C ／ D`, which is also a minor of `M✶` (obtained by deleting `C`
then contracting `D`).
-/
theorem dual_isMinor_dual {M N : Matroid α} (h : N ≤m M) :
    N✶ ≤m M✶ := by
  obtain ⟨C, D, hN⟩ : ∃ C D, N = M ／ C ＼ D := by
    grind +suggestions;
  grind +suggestions

/-
Taking duals preserves the minor relation in both directions: `N✶ ≤m M✶ ↔ N ≤m M`.
-/
theorem dual_isMinor_iff {M N : Matroid α} :
    N✶ ≤m M✶ ↔ N ≤m M := by
  constructor <;> intro h <;> have := dual_isMinor_dual h <;> simp_all +decide

/-! ## Antichain Theory -/

/-- An **antichain** in the minor order is a set of matroids where no one is a proper
minor of any other. -/
def IsMinorAntichain (S : Set (Matroid α)) : Prop :=
  ∀ M ∈ S, ∀ N ∈ S, M ≤m N → M = N

/-
The set of excluded minors for a minor-closed property forms an antichain
in the minor order. If two excluded minors were comparable (one a minor of the other),
the smaller one would satisfy the property (by the excluded minor condition on the larger),
contradicting it being an excluded minor.
-/
theorem excluded_minors_antichain (P : Matroid α → Prop) (_hP : IsMinorClosed P) :
    IsMinorAntichain {M | IsExcludedMinor P M} := by
  intro M hM N hN hMN
  by_contra hMN_ne
  exact hM.1 (hN.2 ⟨hMN, fun h => hMN_ne (IsMinor.antisymm hMN h)⟩)

/-! ## Well-Quasi-Ordering and Finite Antichains -/

/-- A class of matroids is **well-quasi-ordered** by the minor relation if every infinite
sequence contains a pair where one is a minor of the other. -/
def IsMinorWQO (S : Set (Matroid α)) : Prop :=
  ∀ (f : ℕ → Matroid α), (∀ n, f n ∈ S) →
    ∃ i j, i < j ∧ f i ≤m f j

/-
**Key Structural Theorem**: In a well-quasi-ordered class, every antichain is finite.
This is the fundamental fact that connects WQO to the finite forbidden minor property.

The proof is by contraposition: if an antichain were infinite, we could extract an
infinite sequence of distinct elements, violating the WQO property.
-/
theorem wqo_implies_finite_antichains
    {S : Set (Matroid α)}
    (hWQO : IsMinorWQO S) :
    ∀ (A : Set (Matroid α)), A ⊆ S → IsMinorAntichain A → A.Finite := by
  intro A hA hA';
  by_contra h_inf;
  -- Since A is infinite, we can extract a sequence f : ℕ → Matroid α with all distinct elements in A.
  obtain ⟨f, hf⟩ : ∃ f : ℕ → Matroid α, Function.Injective f ∧ ∀ n, f n ∈ A := by
    have := Set.Infinite.to_subtype h_inf;
    have := this.natEmbedding;
    exact ⟨ _, Subtype.val_injective.comp this.injective, fun n => this n |>.2 ⟩;
  obtain ⟨ i, j, hij, h ⟩ := hWQO f fun n => hA ( hf.2 n ) ; have := hA' ( f i ) ( hf.2 i ) ( f j ) ( hf.2 j ) h ; exact hij.ne ( hf.1 this ) ;

/-- **Corollary**: If a WQO class has a minor-closed subproperty, the number of excluded
minors within the class is finite. -/
theorem wqo_finite_excluded_minors
    {S : Set (Matroid α)}
    (hWQO : IsMinorWQO S)
    (P : Matroid α → Prop) (hP : IsMinorClosed P)
    (hExcl : ∀ M, IsExcludedMinor P M → M ∈ S) :
    {M | IsExcludedMinor P M}.Finite := by
  exact wqo_implies_finite_antichains hWQO _ (fun M hM => hExcl M hM)
    (excluded_minors_antichain P hP)

/-! ## Minor-Closed Property of Duality -/

/-
If `P` is minor-closed, then so is the dual property `fun M => P M✶`.
-/
theorem dual_minor_closed (P : Matroid α → Prop) (hP : IsMinorClosed P) :
    IsMinorClosed (fun M => P M✶) := by
  intro M N h₁ h₂;
  exact hP h₁ ( dual_isMinor_dual h₂ )

/-! ## Ground Set Properties -/

/-
A strict minor has a strictly smaller ground set (for finite matroids).
-/
theorem strict_minor_ground_ssubset {M N : Matroid α} (h : N <m M) (_hfin : M.E.Finite) :
    N.E ⊂ M.E :=
  IsStrictMinor.ssubset h

end MatroidMinor

end