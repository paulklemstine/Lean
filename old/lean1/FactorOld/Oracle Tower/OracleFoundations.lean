import Mathlib

/-!
# Oracle Foundations: Spectral Theory, Entropy, and Fixed Points

## Beyond Flatland Part III — New Oracle Theory

This file develops the foundational theory of mathematical oracles (idempotent operators)
including spectral decomposition, entropy quantification, and fixed-point characterization.

All theorems are machine-verified with zero sorries.
-/

open Finset Function

/-! ## Section 1: Oracle Basics and Spectral Theory -/

/-- An oracle is an idempotent function: applying it twice equals applying it once. -/
def IsOracle {α : Type*} (O : α → α) : Prop := ∀ x, O (O x) = O x

/-- The truth set of an oracle: points fixed by the oracle. -/
def truthSet {α : Type*} (O : α → α) : Set α := {x | O x = x}

/-- The illusion set of an oracle: points moved by the oracle. -/
def illusionSet {α : Type*} (O : α → α) : Set α := {x | O x ≠ x}


theorem truth_illusion_partition {α : Type*} (O : α → α) :
    truthSet O ∪ illusionSet O = Set.univ := by
  exact Set.eq_univ_iff_forall.mpr fun x => Classical.or_iff_not_imp_left.2 fun hx => by simpa [ Eq.symm ] using hx;


theorem truth_illusion_disjoint {α : Type*} (O : α → α) :
    truthSet O ∩ illusionSet O = ∅ := by
  exact Set.eq_empty_of_forall_notMem fun x hx => hx.2 hx.1


theorem oracle_maps_to_truth {α : Type*} (O : α → α) (hO : IsOracle O) (x : α) :
    O x ∈ truthSet O := by
  exact hO x

/-
Theorem 16.4: The identity function is an oracle with full truth set.
-/
theorem id_is_oracle {α : Type*} : IsOracle (id : α → α) := by
  exact fun x => rfl

/-
Theorem 16.5: The identity oracle's truth set is everything.
-/
theorem id_truth_set {α : Type*} : truthSet (id : α → α) = Set.univ := by
  exact Set.eq_univ_of_forall fun x => rfl

/-
Theorem 16.6: A constant function is an oracle.
-/
theorem const_is_oracle {α : Type*} (c : α) : IsOracle (fun _ => c) := by
  exact fun x => rfl

/-
Theorem 16.7: The constant oracle's truth set is a singleton.
-/
theorem const_truth_set {α : Type*} (c : α) :
    truthSet (fun _ : α => c) = {c} := by
  exact Set.eq_singleton_iff_unique_mem.mpr ⟨ rfl, fun x hx => hx.symm ▸ rfl ⟩

/-! ## Section 2: Oracle Spectral Theory

An oracle, viewed as a linear operator on a vector space, has a remarkable
spectral property: its only eigenvalues are 0 and 1. This is the algebraic
manifestation of the truth/illusion partition.
-/


theorem oracle_annihilates_correction {R : Type*} [CommRing R]
    (O : R → R) (hO : IsOracle O) (hlin : ∀ a b, O (a + b) = O a + O b)
    (hzero : O 0 = 0) (x : R) : O (O x - x) = 0 := by
  -- By linearity, we have $O(-x) = -O(x)$.
  have h_neg : ∀ x : R, O (-x) = -O x := by
    exact fun x => eq_neg_of_add_eq_zero_right ( by rw [ ← hlin, add_neg_cancel, hzero ] );
  simp +decide [ *, sub_eq_add_neg ];
  rw [ hO, add_neg_cancel ]


theorem idempotent_sq {R : Type*} [Ring R] (e : R) (he : e * e = e) :
    e ^ 2 = e := by
  rw [ sq, he ]


theorem one_sub_idempotent {R : Type*} [Ring R] (e : R) (he : e * e = e) :
    (1 - e) * (1 - e) = 1 - e := by
  simp +decide [ sub_mul, mul_sub, he ]


theorem idempotent_spectral_gap {R : Type*} [Ring R] (e : R) (he : e * e = e) :
    e * (1 - e) = 0 := by
  rw [ mul_sub, mul_one, he, sub_self ]


theorem int_idempotent_classification (e : ℤ) (he : e * e = e) :
    e = 0 ∨ e = 1 := by
  exact or_iff_not_imp_left.mpr fun h => mul_left_cancel₀ h <| by linarith;

/-! ## Section 3: Oracle Entropy on Finite Types

For an oracle on a finite type, we can quantify its "information content"
by the cardinality of its truth set. This gives a natural measure of how
much structure the oracle preserves.
-/

/-- The truth set of an oracle as a Finset, for decidable equality. -/
def truthFinset {α : Type*} [Fintype α] [DecidableEq α] (O : α → α) : Finset α :=
  Finset.univ.filter (fun x => O x = x)

/-- The entropy rank of an oracle: cardinality of its truth set. -/
def entropyRank {α : Type*} [Fintype α] [DecidableEq α] (O : α → α) : ℕ :=
  (truthFinset O).card


theorem id_entropy_rank {α : Type*} [Fintype α] [DecidableEq α] :
    entropyRank (id : α → α) = Fintype.card α := by
  unfold entropyRank truthFinset; aesop;


theorem const_entropy_rank {α : Type*} [Fintype α] [DecidableEq α] [Nonempty α] (c : α) :
    entropyRank (fun _ : α => c) = 1 := by
  unfold entropyRank truthFinset; simp +decide [ Finset.eq_singleton_iff_unique_mem ] ;
  rw [ Finset.card_filter ] ; aesop;


theorem entropy_rank_le_card {α : Type*} [Fintype α] [DecidableEq α] (O : α → α) :
    entropyRank O ≤ Fintype.card α := by
  exact Finset.card_le_univ _


theorem oracle_entropy_eq_range {α : Type*} [Fintype α] [DecidableEq α]
    (O : α → α) (hO : IsOracle O) :
    entropyRank O = (Finset.univ.image O).card := by
  refine' congr_arg Finset.card _;
  unfold truthFinset; ext x; aesop;

/-! ## Section 4: Oracle Fixed-Point Theory -/


theorem oracle_truth_eq_range {α : Type*} (O : α → α) (hO : IsOracle O) :
    truthSet O = Set.range O := by
  ext; aesop;


theorem oracle_iterate {α : Type*} (O : α → α) (hO : IsOracle O) (n : ℕ) (hn : n ≥ 1) :
    O^[n] = O := by
  induction hn <;> simp_all +decide [ Function.iterate_succ_apply' ];
  exact funext hO


theorem oracle_surj_onto_truth {α : Type*} (O : α → α) (hO : IsOracle O)
    (y : α) (hy : y ∈ truthSet O) : O y = y := by
  exact hy


theorem commuting_oracles_compose {α : Type*} (O₁ O₂ : α → α)
    (h1 : IsOracle O₁) (h2 : IsOracle O₂)
    (hcomm : ∀ x, O₁ (O₂ x) = O₂ (O₁ x))
    : IsOracle (O₁ ∘ O₂) := by
  unfold IsOracle at *; aesop;