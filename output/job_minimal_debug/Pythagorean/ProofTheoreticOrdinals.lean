import Mathlib

/-!
# Proof-Theoretic Ordinal Analysis: Abstract Framework

This file formalizes the abstract framework of proof-theoretic ordinal analysis.
The central objects are **OrdinalTheory**s — formal theories characterized by
their set of *provably well-ordered* ordinals. The key structural theorems show
that proof-theoretic ordinals (PTOs) faithfully reflect the inclusion ordering
of theories.

## Main Definitions

* `OrdinalTheory` — a theory described by a downward-closed, bounded set of
  ordinals it can prove well-ordered.
* `OrdinalTheory.pto` — the proof-theoretic ordinal: `sSup provablyWO`.
* `depthDist` — an ordinal-valued quasi-metric measuring the "gap" between theories.

## Main Results

* `Iio_sSup_subset_initSeg` — everything below the PTO is provable (half-saturation).
* `pto_monotone` — PTO is monotone w.r.t. theory inclusion.
* `pto_le_of_not_mem` — ordinals outside provablyWO are ≥ PTO.
* `pto_sandwich` — elements in the difference are sandwiched between PTOs.
* `depthDist_self_eq_zero` — the quasi-metric vanishes on the diagonal.
* `pto_ofOrdinal_limit` — PTO of `ofOrdinal α` is α for limit ordinals.
-/

open Ordinal Set

noncomputable section

universe v

/-! ## Section 1: OrdinalTheory — Core Structure -/

/-- An `OrdinalTheory` models a formal theory by the set of ordinals it proves
well-ordered. The set is required to be an initial segment (downward-closed)
and bounded above. -/
structure OrdinalTheory where
  /-- The set of ordinals provably well-ordered by this theory. -/
  provablyWO : Set Ordinal.{v}
  /-- The set is bounded above. -/
  bddAbove : BddAbove provablyWO
  /-- The set is downward closed: an initial segment of ordinals. -/
  isInitSeg : ∀ ⦃α⦄, α ∈ provablyWO → ∀ ⦃β⦄, β < α → β ∈ provablyWO

/-- The proof-theoretic ordinal (PTO) of an OrdinalTheory. -/
def OrdinalTheory.pto (T : OrdinalTheory.{v}) : Ordinal.{v} :=
  sSup T.provablyWO

instance : LE OrdinalTheory.{v} where
  le T₁ T₂ := T₁.provablyWO ⊆ T₂.provablyWO

instance : LT OrdinalTheory.{v} where
  lt T₁ T₂ := T₁.provablyWO ⊂ T₂.provablyWO

/-- Construct an OrdinalTheory from an ordinal α, with provablyWO = Set.Iio α. -/
def OrdinalTheory.ofOrdinal (α : Ordinal.{v}) : OrdinalTheory.{v} where
  provablyWO := Set.Iio α
  bddAbove := ⟨α, fun _ h => le_of_lt h⟩
  isInitSeg := fun _ hβ _ hγβ => lt_trans hγβ hβ

/-! ## Section 2: Half-Saturation — Everything Below PTO is Provable -/

/-
!-- If β < sSup S, then β is not an upper bound of S, so ∃ γ ∈ S with
β < γ. By downward closure (hinit), β ∈ S. This is the "density" half
of saturation: there are no gaps below the PTO. -- !--

For a nonempty, bounded, downward-closed set of ordinals, every ordinal
strictly below the supremum belongs to the set.
-/
theorem Iio_sSup_subset_initSeg {S : Set Ordinal.{v}} (hne : S.Nonempty)
    (_hbdd : BddAbove S) (hinit : ∀ ⦃α⦄, α ∈ S → ∀ ⦃β⦄, β < α → β ∈ S)
    {β : Ordinal.{v}} (hβ : β < sSup S) : β ∈ S := by
  contrapose! hβ
  exact csSup_le hne fun α hα => le_of_not_gt fun hαβ => hβ <| hinit hα hαβ

/-- The provablyWO set always contains Set.Iio (pto T) when nonempty. -/
theorem OrdinalTheory.Iio_pto_subset (T : OrdinalTheory.{v})
    (hne : T.provablyWO.Nonempty) :
    Set.Iio T.pto ⊆ T.provablyWO := by
  intro β hβ
  exact Iio_sSup_subset_initSeg hne T.bddAbove T.isInitSeg hβ

/-! ## Section 3: PTO of Canonical Theories -/

/-
!-- For a limit ordinal α, sSup (Set.Iio α) = α because α is the supremum
of all ordinals below it. We use Ordinal.isLimit to express this. -- !--

The PTO of `ofOrdinal α` equals α when α is a successor-limit ordinal
(i.e., a limit ordinal in the classical sense: not 0 and not a successor).
-/
theorem pto_ofOrdinal_limit (α : Ordinal.{v}) (hα : Order.IsSuccLimit α) :
    (OrdinalTheory.ofOrdinal α).pto = α := by
  convert hα.sSup_Iio

/-! ## Section 4: Monotonicity of PTO -/

-- !-- sSup is monotone on bounded sets: T₁ ⊆ T₂ implies sSup T₁ ≤ sSup T₂. -- !--

theorem pto_monotone (T₁ T₂ : OrdinalTheory.{v}) (h : T₁ ≤ T₂) :
    T₁.pto ≤ T₂.pto := by
  by_cases h_empty : T₁.provablyWO = ∅ <;> simp_all +decide [OrdinalTheory.pto]
  apply csSup_le_csSup
  · exact T₂.bddAbove
  · exact Set.nonempty_iff_ne_empty.mpr h_empty
  · exact h

/-! ## Section 5: Non-membership Bound and Strict Monotonicity -/

/-
!-- If α ∉ T.provablyWO and T is nonempty, then by contraposition of
Iio_sSup_subset_initSeg, we get T.pto ≤ α. -- !--

If an ordinal is not provably WO by a nonempty theory, it is at least
as large as the PTO. This is the contrapositive of half-saturation.
-/
theorem pto_le_of_not_mem (T : OrdinalTheory.{v})
    (hne : T.provablyWO.Nonempty) {α : Ordinal.{v}} (hα : α ∉ T.provablyWO) :
    T.pto ≤ α := by
  contrapose! hα; have := @Iio_sSup_subset_initSeg { x : Ordinal | x ∈ T.provablyWO } hne T.bddAbove T.isInitSeg; aesop;

/-
For two theories where T₁ ⊂ T₂, any element in the difference
  is sandwiched between the two PTOs: pto(T₁) ≤ α ≤ pto(T₂).
-/
theorem pto_sandwich (T₁ T₂ : OrdinalTheory.{v})
    (hne₁ : T₁.provablyWO.Nonempty) (_hsub : T₁.provablyWO ⊆ T₂.provablyWO)
    {α : Ordinal.{v}} (hα2 : α ∈ T₂.provablyWO) (hα1 : α ∉ T₁.provablyWO) :
    T₁.pto ≤ α ∧ α ≤ T₂.pto := by
  exact ⟨ pto_le_of_not_mem T₁ hne₁ hα1, le_csSup T₂.bddAbove hα2 ⟩

/- The original conjecture `pto_strict_mono_of_ssubset` (strict inclusion implies
   strict PTO increase) is FALSE: the counterexample is T₁ = {β | β < ω} and
   T₂ = {β | β ≤ ω}, where T₁ ⊂ T₂ but both have sSup = ω. The failure occurs
   because T₂ can contain its own supremum while T₁ does not. -/

/-! ## Section 6: Ordinal Quasi-Metric -/

/-- The depth distance between two theories, using ordinal subtraction. -/
def depthDist (T₁ T₂ : OrdinalTheory.{v}) : Ordinal.{v} :=
  T₁.pto - T₂.pto + (T₂.pto - T₁.pto)

theorem depthDist_self_eq_zero (T : OrdinalTheory.{v}) :
    depthDist T T = 0 := by
  unfold depthDist; aesop

/-
depthDist is symmetric.
-/
theorem depthDist_comm (T₁ T₂ : OrdinalTheory.{v}) :
    depthDist T₁ T₂ = depthDist T₂ T₁ := by
  unfold depthDist;
  by_cases h : T₂.pto ≤ T₁.pto;
  · rw [ Ordinal.sub_eq_zero_iff_le.mpr h, zero_add, add_zero ];
  · rw [ Ordinal.sub_eq_zero_iff_le.mpr ( le_of_not_ge h ), zero_add, add_zero ]

/-
depthDist is zero iff the PTOs are equal.
-/
theorem depthDist_eq_zero_iff (T₁ T₂ : OrdinalTheory.{v}) :
    depthDist T₁ T₂ = 0 ↔ T₁.pto = T₂.pto := by
  constructor <;> intro h;
  · -- By definition of depth distance, we have that $T₁.pto - T₂.pto + (T₂.pto - T₁.pto) = 0$.
    have h_eq : T₁.pto - T₂.pto = 0 ∧ T₂.pto - T₁.pto = 0 := by
      exact add_eq_zero_iff.mp h;
    rw [ Ordinal.sub_eq_zero_iff_le ] at h_eq;
    rw [ Ordinal.sub_eq_zero_iff_le ] at h_eq ; exact le_antisymm h_eq.1 h_eq.2;
  · unfold depthDist; aesop;

/-! ## Section 7: Theory Constructions -/

/-- The empty theory proves no ordinals are well-ordered. -/
def OrdinalTheory.empty : OrdinalTheory.{v} where
  provablyWO := ∅
  bddAbove := ⟨0, fun _ h => h.elim⟩
  isInitSeg := fun _ h => h.elim

theorem empty_pto : OrdinalTheory.empty.pto = (0 : Ordinal.{v}) := by
  convert csSup_empty

/-- Join of two theories: proves WO everything either theory proves WO. -/
def OrdinalTheory.join (T₁ T₂ : OrdinalTheory.{v}) : OrdinalTheory.{v} where
  provablyWO := T₁.provablyWO ∪ T₂.provablyWO
  bddAbove := by
    obtain ⟨b₁, hb₁⟩ := T₁.bddAbove
    obtain ⟨b₂, hb₂⟩ := T₂.bddAbove
    exact ⟨max b₁ b₂, fun x hx => hx.elim
      (fun h => le_trans (hb₁ h) (le_max_left _ _))
      (fun h => le_trans (hb₂ h) (le_max_right _ _))⟩
  isInitSeg := by
    intro α hα β hβα
    rcases hα with h | h
    · exact Or.inl (T₁.isInitSeg h hβα)
    · exact Or.inr (T₂.isInitSeg h hβα)

/-- Both component theories are weaker than their join. -/
theorem le_join_left (T₁ T₂ : OrdinalTheory.{v}) :
    T₁ ≤ OrdinalTheory.join T₁ T₂ := fun _ h => Or.inl h

theorem le_join_right (T₁ T₂ : OrdinalTheory.{v}) :
    T₂ ≤ OrdinalTheory.join T₁ T₂ := fun _ h => Or.inr h

/-
The join PTO equals the max of the component PTOs.
-/
theorem join_pto_eq_max (T₁ T₂ : OrdinalTheory.{v}) :
    (OrdinalTheory.join T₁ T₂).pto = max T₁.pto T₂.pto := by
  by_cases h₁ : T₁.provablyWO.Nonempty <;> by_cases h₂ : T₂.provablyWO.Nonempty <;> simp_all +decide [ OrdinalTheory.pto ];
  · rw [ OrdinalTheory.join, csSup_union ];
    · exact T₁.bddAbove;
    · assumption;
    · exact T₂.bddAbove;
    · assumption;
  · simp_all +decide [ Set.not_nonempty_iff_eq_empty.mp h₂, OrdinalTheory.join ];
  · simp_all +decide [ Set.not_nonempty_iff_eq_empty.mp h₁, OrdinalTheory.join ];
  · simp_all +decide [ Set.not_nonempty_iff_eq_empty.mp h₁, Set.not_nonempty_iff_eq_empty.mp h₂, OrdinalTheory.join ]

end