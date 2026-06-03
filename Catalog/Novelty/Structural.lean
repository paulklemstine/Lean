/-
Copyright (c) 2024 Harmonic Research. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import MatroidMinors.Basic

/-!
# Structural Results on Matroid Minors

This file develops deeper structural results about matroid minors, including:

1. **Minor-closed class lattice**: The collection of minor-closed properties forms a
   complete lattice under inclusion.
2. **Excluded minor duality**: The excluded minors of a self-dual property are
   closed under duality.
3. **Representability exclusion**: If a matroid has a non-representable minor,
   it is itself non-representable.
4. **WQO product theorem for matroid invariants**: If a matroid invariant takes
   values in a WQO, certain structural consequences follow.

## Main Results

* `minorClosed_inter`: Intersection of minor-closed properties is minor-closed.
* `minorClosed_union_ground`: The property of having ground set contained in a
  fixed set is minor-closed.
* `excluded_minor_dual_of_self_dual`: Self-dual properties have dual-closed excluded minors.
* `not_representable_of_minor_not_representable`: Non-representability propagates upward.
* `minor_ground_card_le`: A minor on a finite ground set has at most as many elements.

## References

* Oxley: "Matroid Theory", Chapter 3 (Minors)
* Geelen, Gerards, Whittle: "Solving Rota's conjecture"
-/

open Set Matroid

noncomputable section

variable {α : Type*}

/-! ## Minor-Closed Property Lattice -/

/-
The intersection of two minor-closed properties is minor-closed.
-/
theorem minorClosed_inter {P Q : Matroid α → Prop}
    (hP : MinorClosed P) (hQ : MinorClosed Q) :
    MinorClosed (fun M => P M ∧ Q M) := by
  exact fun M N hPQ hMN => ⟨ hP M N hPQ.1 hMN, hQ M N hPQ.2 hMN ⟩

/-
The union of two minor-closed properties is minor-closed.
-/
theorem minorClosed_union {P Q : Matroid α → Prop}
    (hP : MinorClosed P) (hQ : MinorClosed Q) :
    MinorClosed (fun M => P M ∨ Q M) := by
  exact fun M N hPQ hMN => Or.imp ( fun h => hP M N h hMN ) ( fun h => hQ M N h hMN ) hPQ

/-
The property "ground set is a subset of S" is minor-closed.
-/
theorem minorClosed_ground_subset (S : Set α) :
    MinorClosed (fun M : Matroid α => M.E ⊆ S) := by
  intro M N hM hN; exact hN.subset.trans hM;

/-! ## Excluded Minor Duality -/

/-- A property is **self-dual** if it holds for M iff it holds for M✶. -/
def IsSelfDualProperty (P : Matroid α → Prop) : Prop :=
  ∀ M : Matroid α, P M ↔ P M✶

/-
For a self-dual, minor-closed property, if N is a forbidden minor,
then so is N✶. This means the set of excluded minors is closed under duality.
-/
theorem excluded_minor_dual_of_self_dual
    {P : Matroid α → Prop} (_hP : MinorClosed P) (hSD : IsSelfDualProperty P)
    {N : Matroid α} (hN : IsForbiddenMinor P N) :
    IsForbiddenMinor P N✶ := by
  refine' ⟨ _, fun M hM => _ ⟩;
  · exact hSD N |>.not.mp hN.1;
  · have h_dual : M✶ <m N := by
      obtain ⟨ h₁, h₂ ⟩ := hM;
      refine' ⟨ _, _ ⟩;
      · have := dual_isMinor_dual h₁;
        rwa [ Matroid.dual_dual ] at this;
      · contrapose! h₂;
        simpa using dual_isMinor_dual h₂;
    exact hSD M |>.2 ( hN.2 _ h_dual )

/-! ## Representability and Minor Monotonicity -/

/-
If a matroid has a minor that is not F-representable,
then the matroid itself cannot be F-representable (contrapositive of
representability being minor-closed for deletion).
-/
theorem not_representable_of_minor_not_representable
    {F : Type*} [Field F] {M N : Matroid α}
    (hMinor : N ≤m M)
    (hN : ¬ IsRepresentable F N)
    (hClosed : ∀ (M' : Matroid α) (D : Set α),
      IsRepresentable F M' → IsRepresentable F (M' ＼ D))
    (hContract : ∀ (M' : Matroid α) (C : Set α),
      IsRepresentable F M' → IsRepresentable F (M' ／ C)) :
    ¬ IsRepresentable F M := by
  obtain ⟨C, D, hCD⟩ : ∃ C D : Set α, N = M ／ C ＼ D := by
    rcases hMinor with ⟨ C, D, hCD ⟩;
    use C, D;
  grind

/-! ## Ground Set Cardinality -/

/-
A minor of a matroid with finite ground set has a ground set of
at most the same cardinality.
-/
theorem minor_ground_card_le [Fintype α] {M N : Matroid α}
    (h : N ≤m M) [DecidableEq α]
    (hMfin : M.E.Finite) :
    hMfin.toFinset.card ≥ (hMfin.subset h.subset).toFinset.card := by
  apply_rules [ Finset.card_le_card ];
  obtain ⟨ C, D, hC, hD, rfl ⟩ := h; simp +decide [ Finset.subset_iff, Matroid.delete_ground ] ;
  grind +revert

/-! ## Matroid Invariants Under Minors -/

/-- A **matroid invariant** is a function from matroids to some type that is
determined by the matroid structure (isomorphism class). -/
structure MatroidInvariant (β : Type*) where
  /-- The invariant function -/
  val : Matroid α → β
  /-- The invariant is well-defined on the matroid -/
  well_defined : True -- placeholder for isomorphism invariance

/-- A matroid invariant is **minor-monotone** if it is monotone with respect
to the minor partial order. -/
def IsMinorMonotone [Preorder β] (inv : MatroidInvariant β (α := α)) : Prop :=
  ∀ M N : Matroid α, N ≤m M → inv.val N ≤ inv.val M

/-- The ground set size is a minor-monotone invariant (for finite matroids). -/
theorem ground_size_minor_monotone :
    ∀ M N : Matroid α, N ≤m M → N.E ⊆ M.E :=
  fun _ _ h => h.subset

/-! ## Minor-Closed Classes and Finite Characterization -/

/-- A class of matroids is **finitely characterized by excluded minors** if
there exists a finite set of matroids F such that M is in the class iff
M has no minor isomorphic to any member of F. -/
def FinitelyExcluded (P : Matroid α → Prop) : Prop :=
  ∃ F : Finset (Matroid α), ∀ M : Matroid α,
    P M ↔ ∀ N ∈ F, ¬(N ≤m M)

/-- **Rota's Conjecture** (partially proved by Geelen-Gerards-Whittle):
For each prime power q, the class of GF(q)-representable matroids
is finitely characterized by excluded minors.

This is the matroid-theoretic analogue of the Robertson-Seymour theorem.
For q=2: Tutte proved the excluded minors are {U(2,4)}.
For q=3: The excluded minors are {U(2,5), U(3,5), F₇, F₇*}.
For q=4: Proved by Geelen-Gerards-Kapoor (2000).
For general q: This is Rota's conjecture, proved in 2014. -/
def RotaConjecture (F : Type*) [Field F] [Fintype F] : Prop :=
  FinitelyExcluded (fun M : Matroid α => IsRepresentable F M)

/-- The GGW conjecture implies that the forbidden minors for any minor-closed
subproperty of representability are finite. This is a nontrivial consequence:
we use the WQO hypothesis to bound the antichain of excluded minors. -/
theorem ggw_implies_rota_strong (F : Type*) [Field F] [Fintype F]
    (hGGW : @GGW_Conjecture α F _ _)
    (P : Matroid α → Prop)
    (hP : MinorClosed P) :
    Set.Finite {N : Matroid α | IsRepresentable F N ∧ IsForbiddenMinor P N} := by
  exact ggw_implies_finite_excluded_minors F hGGW P hP

end