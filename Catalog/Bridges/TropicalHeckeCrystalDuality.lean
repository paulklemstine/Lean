/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Hecke–Crystal Realization Duality via Observational Quotients

This file formalizes a **tropical Hecke–crystal realization duality**:
for any finite system of operators acting on a finite set with observations
valued in a finite type, the observational quotient produces a unique minimal
crystal automaton. This is a representation-theoretic analogue of the
Myhill–Nerode minimization theorem from automata theory.

## Main Results

* `obsEquiv_equivalence` — Observational equivalence is an equivalence relation.
* `obsEquiv_hecke_compatible` — Operators respect observational equivalence.
* `quotient_crystal_realizes` — The quotient crystal faithfully realizes the action.
* `any_realization_refines_obsEquiv` — Any realization identifies obs-equivalent states.
* `minimal_realization_card_le` — The quotient realization has minimal state count.
* `exists_minimal_crystal_realization` — Existence of the unique minimal crystal.
* `hankel_distinct_rows_eq_minimal_states` — Hankel row count = minimal states.
* `reconstruct_crystal_correct` — Certified reconstruction algorithm.
* `minimal_realizations_isomorphic` — Uniqueness up to crystal isomorphism.
* `crystal_self_minimal` — An observable crystal is its own minimal realization.
-/

import Mathlib

namespace TropicalHeckeCrystal

open Finset Function

/-! ## §1. Word Action -/

/-- The iterated action of a word `w : List ι`, reading left-to-right. -/
def wordAction {ι M : Type*} (T : ι → M → M) : List ι → M → M
  | [], m => m
  | i :: w, m => wordAction T w (T i m)

@[simp]
theorem wordAction_nil {ι M : Type*} (T : ι → M → M) (m : M) :
    wordAction T [] m = m := rfl

@[simp]
theorem wordAction_cons {ι M : Type*} (T : ι → M → M) (i : ι) (w : List ι) (m : M) :
    wordAction T (i :: w) m = wordAction T w (T i m) := rfl

theorem wordAction_append {ι M : Type*} (T : ι → M → M) (w₁ w₂ : List ι) (m : M) :
    wordAction T (w₁ ++ w₂) m = wordAction T w₂ (wordAction T w₁ m) := by
  induction w₁ generalizing m with
  | nil => simp
  | cons i w₁ ih => simp [ih]

/-! ## §2. Observational Equivalence -/

/-- Two elements are **observationally equivalent** iff every Hecke word
followed by observation gives the same result. -/
def ObsEquiv {ι M S : Type*} (T : ι → M → M) (obs : M → S) (m₁ m₂ : M) : Prop :=
  ∀ w : List ι, obs (wordAction T w m₁) = obs (wordAction T w m₂)

theorem obsEquiv_refl {ι M S : Type*} (T : ι → M → M) (obs : M → S) (m : M) :
    ObsEquiv T obs m m := fun _ => rfl

theorem obsEquiv_symm {ι M S : Type*} (T : ι → M → M) (obs : M → S) {m₁ m₂ : M}
    (h : ObsEquiv T obs m₁ m₂) : ObsEquiv T obs m₂ m₁ :=
  fun w => (h w).symm

theorem obsEquiv_trans {ι M S : Type*} (T : ι → M → M) (obs : M → S) {m₁ m₂ m₃ : M}
    (h₁ : ObsEquiv T obs m₁ m₂) (h₂ : ObsEquiv T obs m₂ m₃) :
    ObsEquiv T obs m₁ m₃ :=
  fun w => (h₁ w).trans (h₂ w)

/-- Observational equivalence is an equivalence relation. -/
theorem obsEquiv_equivalence {ι M S : Type*} (T : ι → M → M) (obs : M → S) :
    Equivalence (ObsEquiv T obs) :=
  ⟨obsEquiv_refl T obs, fun h => obsEquiv_symm T obs h,
   fun h₁ h₂ => obsEquiv_trans T obs h₁ h₂⟩

/-- The setoid of observational equivalence. -/
def obsSetoid {ι M S : Type*} (T : ι → M → M) (obs : M → S) : Setoid M :=
  ⟨ObsEquiv T obs, obsEquiv_equivalence T obs⟩

/-- Operators respect observational equivalence. -/
theorem obsEquiv_hecke_compatible {ι M S : Type*}
    (T : ι → M → M) (obs : M → S) (i : ι)
    {m₁ m₂ : M} (h : ObsEquiv T obs m₁ m₂) :
    ObsEquiv T obs (T i m₁) (T i m₂) :=
  fun w => h (i :: w)

/-- Word actions preserve observational equivalence. -/
theorem obsEquiv_word_compatible {ι M S : Type*}
    (T : ι → M → M) (obs : M → S) (w : List ι)
    {m₁ m₂ : M} (h : ObsEquiv T obs m₁ m₂) :
    ObsEquiv T obs (wordAction T w m₁) (wordAction T w m₂) := by
  intro w'
  rw [← wordAction_append, ← wordAction_append]
  exact h (w ++ w')

/-- Obs equivalent elements have the same direct observation. -/
theorem obsEquiv_obs_eq {ι M S : Type*} (T : ι → M → M) (obs : M → S) {m₁ m₂ : M}
    (h : ObsEquiv T obs m₁ m₂) : obs m₁ = obs m₂ := h []

/-! ## §3. Crystal Automaton -/

/-- A **weighted crystal automaton** with colors `ι` and weights `Λ`. -/
structure CrystalAutomaton (ι : Type*) (Λ : Type*) where
  /-- The state type -/
  State : Type*
  [finState : Fintype State]
  [decState : DecidableEq State]
  /-- Weight function -/
  wt : State → Λ
  /-- Transition function -/
  step : ι → State → State

attribute [instance] CrystalAutomaton.finState CrystalAutomaton.decState

/-! ## §4. Hecke Action Data and Realizations -/

/-- A **Hecke action datum**: a finite type with operators and observation. -/
structure HeckeActionData (ι : Type*) (S : Type*) where
  /-- The element type -/
  M : Type*
  [finM : Fintype M]
  [decM : DecidableEq M]
  /-- Operators -/
  T : ι → M → M
  /-- Observation function -/
  obs : M → S

attribute [instance] HeckeActionData.finM HeckeActionData.decM

/-- A **crystal realization** of Hecke action data. -/
structure CrystalRealization {ι S : Type*} (D : HeckeActionData ι S) where
  /-- The underlying crystal automaton -/
  C : CrystalAutomaton ι S
  /-- The realization map -/
  φ : D.M → C.State
  /-- Intertwining -/
  intertwine : ∀ (i : ι) (m : D.M), φ (D.T i m) = C.step i (φ m)
  /-- Observation compatibility -/
  obs_compat : ∀ m : D.M, C.wt (φ m) = D.obs m
  /-- Surjectivity -/
  surj : Surjective φ

/-- A realization reproduces observation under any word action. -/
theorem CrystalRealization.word_compat {ι S : Type*}
    {D : HeckeActionData ι S} (R : CrystalRealization D)
    (w : List ι) (m : D.M) :
    R.C.wt (wordAction R.C.step w (R.φ m)) =
      D.obs (wordAction D.T w m) := by
  induction w generalizing m with
  | nil => exact R.obs_compat m
  | cons i w ih =>
    simp only [wordAction_cons]
    rw [← R.intertwine]
    exact ih (D.T i m)

/-- An automaton is **observable** if distinct states have distinct profiles. -/
def IsObservable {ι S : Type*} (C : CrystalAutomaton ι S) : Prop :=
  ∀ q₁ q₂ : C.State,
    (∀ w : List ι, C.wt (wordAction C.step w q₁) =
      C.wt (wordAction C.step w q₂)) → q₁ = q₂

/-- Any observable realization identifies obs-equivalent elements. -/
theorem any_realization_refines_obsEquiv {ι S : Type*}
    {D : HeckeActionData ι S}
    (R : CrystalRealization D)
    (h_obs : IsObservable R.C)
    {m₁ m₂ : D.M}
    (h : ObsEquiv D.T D.obs m₁ m₂) :
    R.φ m₁ = R.φ m₂ := by
  apply h_obs
  intro w
  rw [R.word_compat, R.word_compat]
  exact h w

/-! ## §5. The Quotient Crystal -/

variable {ι S : Type*} [DecidableEq S] [Fintype S] [Fintype ι] [DecidableEq ι]
variable (D : HeckeActionData ι S)

/-- The quotient state type. -/
def QuotientState : Type _ :=
  Quotient (obsSetoid D.T D.obs)

/-- Decidable observational equivalence on a finite type. -/
noncomputable instance obsEquivDecidable :
    DecidableRel (obsSetoid D.T D.obs).r := by
  unfold DecidableRel
  intro a b
  exact Classical.dec _

noncomputable instance quotientStateFintype : Fintype (QuotientState D) :=
  @Quotient.fintype _ D.finM (obsSetoid D.T D.obs) (obsEquivDecidable D)

noncomputable instance quotientStateDecEq : DecidableEq (QuotientState D) :=
  @Quotient.decidableEq _ (obsSetoid D.T D.obs) (obsEquivDecidable D)

/-- The quotient transition. -/
def quotientStep (i : ι) : QuotientState D → QuotientState D :=
  Quotient.map (D.T i) (fun _ _ h => obsEquiv_hecke_compatible D.T D.obs i h)

/-- The quotient observation. -/
def quotientObs : QuotientState D → S :=
  Quotient.lift D.obs (fun _ _ h => obsEquiv_obs_eq D.T D.obs h)

/-- The quotient map. -/
def quotientMap : D.M → QuotientState D :=
  fun m => Quotient.mk (obsSetoid D.T D.obs) m

theorem quotientMap_surj : Surjective (quotientMap D) := by
  intro q
  exact Quotient.inductionOn q (fun m => ⟨m, rfl⟩)

theorem quotientMap_intertwine (i : ι) (m : D.M) :
    quotientMap D (D.T i m) = quotientStep D i (quotientMap D m) := rfl

theorem quotientObs_compat (m : D.M) :
    quotientObs D (quotientMap D m) = D.obs m := rfl

/-- The **minimal crystal automaton**. -/
noncomputable def minimalCrystal : CrystalAutomaton ι S where
  State := QuotientState D
  finState := quotientStateFintype D
  decState := quotientStateDecEq D
  wt := quotientObs D
  step := quotientStep D

/-- The **minimal crystal realization**. -/
noncomputable def minimalRealization : CrystalRealization D where
  C := minimalCrystal D
  φ := quotientMap D
  intertwine := fun i m => (quotientMap_intertwine D i m).symm
  obs_compat := fun m => quotientObs_compat D m
  surj := quotientMap_surj D

/-- The quotient crystal reproduces all observations. -/
theorem quotient_crystal_realizes (w : List ι) (m : D.M) :
    (minimalCrystal D).wt (wordAction (minimalCrystal D).step w (quotientMap D m)) =
      D.obs (wordAction D.T w m) :=
  (minimalRealization D).word_compat w m

/-- Generators map to same quotient state iff obs equivalent. -/
theorem quotientMap_eq_iff (m₁ m₂ : D.M) :
    quotientMap D m₁ = quotientMap D m₂ ↔ ObsEquiv D.T D.obs m₁ m₂ :=
  Quotient.eq (r := obsSetoid D.T D.obs)

/-! ## §6. The Quotient Crystal is Observable -/

/-- The quotient crystal is observable. -/
theorem quotient_crystal_observable : IsObservable (minimalCrystal D) := by
  intro q₁ q₂ h
  induction q₁ using Quotient.ind with | _ m₁ =>
  induction q₂ using Quotient.ind with | _ m₂ =>
  change quotientMap D m₁ = quotientMap D m₂
  rw [quotientMap_eq_iff]
  intro w
  have h1 := quotient_crystal_realizes D w m₁
  have h2 := quotient_crystal_realizes D w m₂
  rw [show quotientMap D m₁ = (⟦m₁⟧ : QuotientState D) from rfl] at h1
  rw [show quotientMap D m₂ = (⟦m₂⟧ : QuotientState D) from rfl] at h2
  rw [← h1, ← h2]
  exact h w

/-! ## §7. Minimality -/

/-
Any observable realization has at least as many states as the quotient.
-/
theorem minimal_realization_card_le
    (R : CrystalRealization D) (h_obs : IsObservable R.C) :
    Fintype.card (QuotientState D) ≤ Fintype.card R.C.State := by
  fapply Fintype.card_le_of_surjective;
  exact fun q => quotientMap D ( Classical.choose ( R.surj q ) );
  intro q;
  obtain ⟨ m, rfl ⟩ := Quotient.exists_rep q;
  have := Classical.choose_spec ( R.surj ( R.φ m ) );
  exact ⟨ R.φ m, quotientMap_eq_iff _ _ _ |>.2 <| by exact fun w => by have := R.word_compat w ( Classical.choose ( R.surj ( R.φ m ) ) ) ; have := R.word_compat w m; aesop ⟩

/-! ## §8. Hankel–Hecke Row Count -/

/-- The number of distinct observation profiles. -/
noncomputable def hankelDistinctRows : ℕ :=
  Fintype.card (QuotientState D)

/-- Distinct profiles = minimal crystal state count. -/
theorem hankel_distinct_rows_eq_minimal_states :
    hankelDistinctRows D = Fintype.card (minimalCrystal D).State := rfl

/-- Any observable realization has at least as many states as distinct rows. -/
theorem hankel_distinct_rows_le_realization
    (R : CrystalRealization D) (h_obs : IsObservable R.C) :
    hankelDistinctRows D ≤ Fintype.card R.C.State :=
  minimal_realization_card_le D R h_obs

/-! ## §9. Crystal Isomorphism -/

/-- An **isomorphism** between crystal automata. -/
structure CrystalIso {ι S : Type*} (C₁ C₂ : CrystalAutomaton ι S) where
  equiv : C₁.State ≃ C₂.State
  wt_compat : ∀ q, C₂.wt (equiv q) = C₁.wt q
  step_compat : ∀ i q, equiv (C₁.step i q) = C₂.step i (equiv q)

/-! ## §10. Uniqueness Up to Isomorphism -/

/-
Any two observable surjective realizations are isomorphic.
-/
set_option linter.unusedSectionVars false in
theorem minimal_realizations_isomorphic
    (R₁ R₂ : CrystalRealization D)
    (h₁ : IsObservable R₁.C) (h₂ : IsObservable R₂.C) :
    Nonempty (CrystalIso R₁.C R₂.C) := by
  -- Define the equivalence between R₁.C.State and R₂.C.State.
  have h_equiv : ∃ (equiv : R₁.C.State ≃ R₂.C.State), ∀ q, R₂.C.wt (equiv q) = R₁.C.wt q ∧ ∀ i, equiv (R₁.C.step i q) = R₂.C.step i (equiv q) := by
    -- Define the equivalence between R₁.C.State and R₂.C.State using the surjectivity of R₁.φ and R₂.φ.
    have h_equiv : ∀ q₁ : R₁.C.State, ∃! q₂ : R₂.C.State, ∀ w : List ι, R₂.C.wt (wordAction R₂.C.step w q₂) = R₁.C.wt (wordAction R₁.C.step w q₁) := by
      intro q₁
      obtain ⟨q₂, hq₂⟩ : ∃ q₂ : R₂.C.State, ∀ w : List ι, R₂.C.wt (wordAction R₂.C.step w q₂) = R₁.C.wt (wordAction R₁.C.step w q₁) := by
        obtain ⟨m, hm⟩ := R₁.surj q₁;
        use R₂.φ m; intro w; have := R₁.word_compat w m; have := R₂.word_compat w m; aesop;
      refine' ⟨ q₂, hq₂, fun q₃ hq₃ => h₂ q₃ q₂ fun w => hq₃ w ▸ hq₂ w ▸ rfl ⟩;
    choose f hf₁ hf₂ using h_equiv;
    refine' ⟨ Equiv.ofBijective f ⟨ _, _ ⟩, fun q => ⟨ _, _ ⟩ ⟩;
    all_goals norm_num [ Equiv.ofBijective ];
    · intro q₁ q₂ h_eq;
      apply h₁;
      grind;
    · intro q₂;
      obtain ⟨ m, rfl ⟩ := R₂.surj q₂;
      use R₁.φ m;
      rw [ ← hf₂ ];
      simp +decide [ CrystalRealization.word_compat ];
    · simpa using hf₁ q [];
    · intro i;
      rw [ ← hf₂ ];
      intro w;
      convert hf₁ q ( i :: w ) using 1;
  exact ⟨ ⟨ h_equiv.choose, fun q => h_equiv.choose_spec q |>.1, fun i q => h_equiv.choose_spec q |>.2 i ⟩ ⟩

/-! ## §11. Main Theorem -/

/-- **Tropical Hecke–Crystal Realization Duality**:
The minimal realization is observable, minimal, and unique up to isomorphism. -/
theorem exists_minimal_crystal_realization :
    IsObservable (minimalRealization D).C ∧
    (∀ R' : CrystalRealization D, IsObservable R'.C →
      Fintype.card (minimalRealization D).C.State ≤ Fintype.card R'.C.State) ∧
    (∀ R' : CrystalRealization D, IsObservable R'.C →
      Nonempty (CrystalIso (minimalRealization D).C R'.C)) :=
  ⟨quotient_crystal_observable D,
   fun R' h' => minimal_realization_card_le D R' h',
   fun R' h' => minimal_realizations_isomorphic D (minimalRealization D) R'
     (quotient_crystal_observable D) h'⟩

/-! ## §12. Tropical Character Recovery -/

/-- The **tropical character**: multiset of observation values. -/
noncomputable def tropicalCharacter : Multiset S :=
  (Finset.univ : Finset (QuotientState D)).val.map (quotientObs D)

set_option linter.unusedSectionVars false in
/-- Character matches minimal crystal state weights. -/
theorem character_from_minimal_crystal :
    tropicalCharacter D =
      (Finset.univ : Finset (minimalCrystal D).State).val.map (minimalCrystal D).wt :=
  rfl

/-! ## §13. Certified Reconstruction -/

/-- **Certified reconstruction**: sound, minimal, observable, character-correct. -/
theorem reconstruct_crystal_correct :
    (∀ (w : List ι) (m : D.M),
      (minimalCrystal D).wt
        (wordAction (minimalCrystal D).step w (quotientMap D m)) =
        D.obs (wordAction D.T w m)) ∧
    (∀ R : CrystalRealization D, IsObservable R.C →
      Fintype.card (QuotientState D) ≤ Fintype.card R.C.State) ∧
    IsObservable (minimalCrystal D) ∧
    (tropicalCharacter D =
      (Finset.univ : Finset (minimalCrystal D).State).val.map
        (minimalCrystal D).wt) :=
  ⟨quotient_crystal_realizes D,
   fun R h => minimal_realization_card_le D R h,
   quotient_crystal_observable D,
   character_from_minimal_crystal D⟩

/-! ## §14. Converse: Crystal → Hecke Data -/

/-- Every crystal automaton yields a Hecke action datum. -/
def heckeDataFromCrystal (C : CrystalAutomaton ι S) : HeckeActionData ι S where
  M := C.State
  T := C.step
  obs := C.wt

/-- A crystal automaton is its own realization. -/
def identityRealization (C : CrystalAutomaton ι S) :
    CrystalRealization (heckeDataFromCrystal C) where
  C := C
  φ := id
  intertwine := fun _ _ => rfl
  obs_compat := fun _ => rfl
  surj := surjective_id

/-
An observable crystal is minimal for its own data.
-/
theorem crystal_self_minimal (C : CrystalAutomaton ι S) (h_obs : IsObservable C) :
    Fintype.card (QuotientState (heckeDataFromCrystal C)) = Fintype.card C.State := by
  refine' le_antisymm _ _;
  · have := @minimal_realization_card_le;
    exact this _ ( identityRealization C ) h_obs;
  · refine' Fintype.card_le_of_injective _ _;
    exact fun q => Quotient.mk ( obsSetoid ( heckeDataFromCrystal C ).T ( heckeDataFromCrystal C ).obs ) q;
    intro q₁ q₂ h_eq;
    exact h_obs q₁ q₂ fun w => by simpa using Quotient.exact h_eq w;

/-! ## §15. Observation Profile -/

/-- The observation profile of an element. -/
def obsProfile (m : D.M) : List ι → S :=
  fun w => D.obs (wordAction D.T w m)

set_option linter.unusedSectionVars false in
/-- Obs equivalence ↔ profile equality. -/
theorem obsEquiv_iff_profile (m₁ m₂ : D.M) :
    ObsEquiv D.T D.obs m₁ m₂ ↔ obsProfile D m₁ = obsProfile D m₂ := by
  constructor
  · intro h; ext w; exact h w
  · intro h w; exact congr_fun h w

/-! ## §16. Tropical Rank of Hankel–Hecke Matrix -/

/-- The **tropical rank** of the Hankel–Hecke observation data:
the number of distinct observation profiles among generators. This
equals the number of quotient states by construction. -/
noncomputable def tropRankHankel : ℕ :=
  Fintype.card (QuotientState D)

set_option linter.unusedSectionVars false in
/-- **Tropical Hankel–Hecke Minimality Theorem**:
The tropical rank of the Hankel–Hecke matrix equals the minimal
number of crystal states. -/
theorem tropRank_hankel_eq_minimal_states :
    tropRankHankel D = Fintype.card (minimalCrystal D).State := rfl

/-- The tropical rank is a lower bound for any observable realization. -/
theorem tropRank_le_any_observable_realization
    (R : CrystalRealization D) (h_obs : IsObservable R.C) :
    tropRankHankel D ≤ Fintype.card R.C.State :=
  minimal_realization_card_le D R h_obs

end TropicalHeckeCrystal