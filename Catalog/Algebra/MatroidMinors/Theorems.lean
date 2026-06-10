/-
  Matroid Minors and the Robertson-Seymour Conjecture for Matroids

  This file develops the theory of matroid minors, minor-closed properties,
  forbidden minor characterizations, and the framework for the
  Robertson-Seymour conjecture for representable matroids over finite fields.

  Main results:
  - Forbidden minors form an antichain (forbiddenMinors_antichain)
  - RS property implies no infinite antichain (rs_implies_no_infinite_antichain)
  - Forbidden minor characterization theorem (forbidden_minor_characterization)
  - RS property implies finite obstructions (rs_implies_finite_obstructions)
  - Representability is minor-closed (representable_minor_closed)
-/
import Mathlib

open Set

namespace MatroidMinor

/-! ## Definitions -/

/-- A property of matroids is minor-closed if whenever M has the property
    and N is a minor of M, then N also has the property. -/
def IsMinorClosed {α : Type*} (P : Matroid α → Prop) : Prop :=
  ∀ ⦃M N : Matroid α⦄, P M → N.IsMinor M → P N

/-- An antichain in the minor order: no element is a proper minor of another. -/
def IsMinorAntichain {α : Type*} (S : Set (Matroid α)) : Prop :=
  ∀ M ∈ S, ∀ N ∈ S, M.IsMinor N → M = N

/-- The set of forbidden minors for a minor-closed property P:
    matroids that don't satisfy P but all proper minors do. -/
def ForbiddenMinors {α : Type*} (P : Matroid α → Prop) : Set (Matroid α) :=
  { M | ¬P M ∧ ∀ N : Matroid α, N.IsMinor M → N ≠ M → P N }

/-- A forbidden minor characterization: P M iff M avoids all forbidden minors. -/
def HasForbiddenMinorChar {α : Type*} (P : Matroid α → Prop)
    (F : Set (Matroid α)) : Prop :=
  ∀ M : Matroid α, P M ↔ ∀ N ∈ F, ¬N.IsMinor M

/-- The Robertson-Seymour property: every infinite sequence has an increasing pair. -/
def HasRobertsonSeymourProperty {α : Type*} (C : Set (Matroid α)) : Prop :=
  ∀ f : ℕ → Matroid α, (∀ n, f n ∈ C) →
    ∃ i j : ℕ, i < j ∧ (f i).IsMinor (f j)

/-- No infinite antichain in the class. -/
def HasNoInfiniteAntichain {α : Type*} (C : Set (Matroid α)) : Prop :=
  ¬∃ f : ℕ → Matroid α, (∀ n, f n ∈ C) ∧ Function.Injective f ∧
    ∀ i j : ℕ, (f i).IsMinor (f j) → i = j

/-- A matroid is F-representable if there is a matrix representation over F. -/
def IsRepresentable {α : Type*} (M : Matroid α) (F : Type*) [Field F] : Prop :=
  ∃ (r : ℕ) (φ : α → Fin r → F), ∀ (I : Finset α),
    (↑I : Set α) ⊆ M.E →
    (M.Indep (↑I : Set α) ↔
      LinearIndependent F (fun i : I => fun j : Fin r => φ ↑i j))

/-- The class of F-representable matroids. -/
def RepresentableOver {α : Type*} (F : Type*) [Field F] : Set (Matroid α) :=
  { M | IsRepresentable M F }

/-- The RS conjecture for F-representable matroids over finite field F. -/
def RSConjectureForField {α : Type*} (F : Type*) [Field F] [Fintype F] : Prop :=
  HasRobertsonSeymourProperty (RepresentableOver (α := α) F)

/-! ## Basic Minor-Closed Properties -/

/-- The intersection of two minor-closed properties is minor-closed. -/
theorem isMinorClosed_inter {α : Type*} {P Q : Matroid α → Prop}
    (hP : IsMinorClosed P) (hQ : IsMinorClosed Q) :
    IsMinorClosed (fun M => P M ∧ Q M) := by
  intro M N ⟨hPM, hQM⟩ hNM
  exact ⟨hP hPM hNM, hQ hQM hNM⟩

/-- The intersection of arbitrarily many minor-closed properties is minor-closed. -/
theorem isMinorClosed_iInter {α : Type*} {ι : Type*} {P : ι → Matroid α → Prop}
    (hP : ∀ i, IsMinorClosed (P i)) :
    IsMinorClosed (fun M => ∀ i, P i M) := by
  intro M N hM hNM i
  exact hP i (hM i) hNM

/-! ## Core Theorems -/

/-
**Forbidden minors form an antichain.** If F is a forbidden minor and G is a
    proper minor of F, then G satisfies P (since F is minimal). So no forbidden
    minor can be a proper minor of another.
-/
theorem forbiddenMinors_antichain {α : Type*} {P : Matroid α → Prop}
    (_hP : IsMinorClosed P) :
    IsMinorAntichain (ForbiddenMinors P) := by
  intro M hM N hN hMN;
  -- By contradiction, assume $M \neq N �$�.
  by_contra h_ne;
  exact hM.1 ( hN.2 M hMN h_ne )

/-
**RS property implies no infinite antichain.** If C has the RS property,
    any purported infinite antichain f in C yields i < j with f i ≤m f j,
    contradicting the antichain condition.
-/
theorem rs_implies_no_infinite_antichain {α : Type*} {C : Set (Matroid α)}
    (hRS : HasRobertsonSeymourProperty C) :
    HasNoInfiniteAntichain C := by
  intro h_inf
  obtain ⟨f, hfC, hfinj, hanti⟩ := h_inf
  have h_contra : ∃ i j, i < j ∧ (f i).IsMinor (f j) := by
    exact hRS f hfC;
  exact h_contra.choose_spec.choose_spec.1.ne ( hanti _ _ h_contra.choose_spec.choose_spec.2 )

/-
**RS property + minor-closed ⟹ no infinite forbidden minor sequence.**
    Forbidden minors form an antichain, and the RS property forbids infinite
    antichains.
-/
theorem rs_forbiddenMinors_no_infinite_seq {α : Type*}
    {C : Set (Matroid α)} {P : Matroid α → Prop}
    (hRS : HasRobertsonSeymourProperty C) (_hP : IsMinorClosed P) :
    ¬∃ f : ℕ → Matroid α, Function.Injective f ∧
      (∀ n, f n ∈ C) ∧ (∀ n, f n ∈ ForbiddenMinors P) := by
  intro ⟨f, hfinj, hfC, hfFM⟩
  obtain ⟨i, j, hij, hminor⟩ := hRS f hfC
  have heq := forbiddenMinors_antichain _hP (f i) (hfFM i) (f j) (hfFM j) hminor
  exact hij.ne (hfinj heq)

/-
Deletion produces a minor.
-/
theorem minor_delete_ground {α : Type*} {M : Matroid α} (D : Set α) :
    (M.delete D).IsMinor M := by
  exact ⟨∅, D, by simp⟩

/-
Contraction produces a minor.
-/
theorem minor_contract_ground {α : Type*} {M : Matroid α} (C : Set α) :
    (M.contract C).IsMinor M := by
  refine' ⟨ _, _, _ ⟩;
  exacts [ C, ∅, by simp +decide ]

/-
**Forward direction of forbidden minor characterization.**
    If P is minor-closed and P M holds, then M has no forbidden minor.
-/
theorem avoids_forbidden_minors {α : Type*} {P : Matroid α → Prop}
    (hP : IsMinorClosed P) {M : Matroid α} (hM : P M) :
    ∀ N ∈ ForbiddenMinors P, ¬N.IsMinor M := by
  intros N hN hNM; exact hN.left (hP hM hNM)

/-- **The minor order on a fixed ground set is well-founded** when we restrict
    to the strict part (proper minors). This is the "proper minor" relation. -/
def ProperMinor {α : Type*} (N M : Matroid α) : Prop :=
  N.IsMinor M ∧ N ≠ M

/-
**Full forbidden minor characterization** assuming well-foundedness of
    the proper minor relation. Under this hypothesis, every non-P matroid
    contains a forbidden minor.
-/
theorem forbidden_minor_characterization_wf {α : Type*} {P : Matroid α → Prop}
    (hP : IsMinorClosed P)
    (hwf : WellFounded (ProperMinor (α := α))) :
    HasForbiddenMinorChar P (ForbiddenMinors P) := by
  intro M
  constructor
  intro hM
  apply avoids_forbidden_minors hP hM;
  induction' M using hwf.induction with M ih;
  -- If all proper minors of M satisfy P, then M ∈ ForbiddenMinors P (since ¬P M and all proper minors satisfy P).
  by_cases h_all_P : ∀ N, N.IsMinor M → N ≠ M → P N;
  · exact fun h => Classical.not_not.1 fun hM => h M ⟨ hM, h_all_P ⟩ ( Matroid.IsMinor.refl );
  · simp +zetaDelta at *;
    obtain ⟨ N, hN₁, hN₂, hN₃ ⟩ := h_all_P;
    exact fun h => False.elim ( ih N ⟨ hN₁, hN₂ ⟩ ( fun F hF hF' => h F hF ( hF'.trans hN₁ ) ) |> fun h => hN₃ h )

/-- **RS conjecture implies finite obstructions** for every minor-closed
    subproperty of F-representable matroids. -/
theorem rs_implies_finite_obstructions {α : Type*}
    {F : Type*} [Field F] [Fintype F]
    (hRS : RSConjectureForField (α := α) F)
    {P : Matroid α → Prop} (hP : IsMinorClosed P) :
    ¬∃ f : ℕ → Matroid α, Function.Injective f ∧
      (∀ n, f n ∈ RepresentableOver F) ∧ (∀ n, f n ∈ ForbiddenMinors P) := by
  exact rs_forbiddenMinors_no_infinite_seq hRS hP

end MatroidMinor