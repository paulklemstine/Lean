/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Universal Support-Tutte Invariant: Full Universality and Cross-Domain Bridge

This file establishes the **universal factorization theorem** for
deletion–contraction invariants on M-convex supports, proves a cardinality
specialization, and provides a cross-domain bridge to matroid theory via
binary supports.

## Main Results

* `dc_invariant_factors_through_canonical` — Universal factorization (Theorem C)
* `dc_invariant_unique` — Uniqueness corollary (uses multi-step calc)
* `canonicalSupportEval_one_eq_card` — Cardinality specialization (Theorem B)
* `activity_partition` — Activity counting theorem
* `binary_support_card_recursion` — Bridge to matroid theory (Theorem D)

## References

* Murota, "Discrete Convex Analysis", SIAM, 2003
* Brylawski–Oxley, "The Tutte polynomial and its applications", 1992
-/

open Finset BigOperators Finsupp

attribute [local instance] Classical.propDecidable

namespace SupportTutteUniversality

variable {ι : Type*} [DecidableEq ι]

/-! ## Section 1: Core Definitions -/

def sDelete (S : Finset (ι →₀ ℕ)) (i : ι) : Finset (ι →₀ ℕ) :=
  S.filter (fun m => m i = 0)

noncomputable def sContract (S : Finset (ι →₀ ℕ)) (i : ι) : Finset (ι →₀ ℕ) :=
  (S.filter (fun m => 0 < m i)).image (fun m => m - Finsupp.single i 1)

def IsSLoop (S : Finset (ι →₀ ℕ)) (i : ι) : Prop :=
  ∀ m ∈ S, m i > 0

def IsOrdCoord (S : Finset (ι →₀ ℕ)) (i : ι) : Prop :=
  (∃ m ∈ S, m i = 0) ∧ (∃ m ∈ S, 0 < m i)

noncomputable def sTotalDeg (S : Finset (ι →₀ ℕ)) : ℕ :=
  S.sum (fun m => m.sum (fun _ v => v))

noncomputable def sMeasure (S : Finset (ι →₀ ℕ)) : ℕ :=
  sTotalDeg S + S.card

def IsBinarySupport (S : Finset (ι →₀ ℕ)) : Prop :=
  ∀ m ∈ S, ∀ i : ι, m i = 0 ∨ m i = 1

/-! ## Section 2: Basic Lemmas -/

theorem sDelete_subset (S : Finset (ι →₀ ℕ)) (i : ι) :
    sDelete S i ⊆ S :=
  filter_subset _ _

theorem mem_sDelete_iff {S : Finset (ι →₀ ℕ)} {i : ι} {m : ι →₀ ℕ} :
    m ∈ sDelete S i ↔ m ∈ S ∧ m i = 0 :=
  Finset.mem_filter

theorem sDelete_card_lt {S : Finset (ι →₀ ℕ)} {i : ι}
    (h : ∃ m ∈ S, 0 < m i) :
    (sDelete S i).card < S.card := by
  apply Finset.card_lt_card
  exact ⟨sDelete_subset S i, fun heq => by
    obtain ⟨m, hm, hmi⟩ := h
    have := heq hm; rw [mem_sDelete_iff] at this; omega⟩

theorem sContract_card_le (S : Finset (ι →₀ ℕ)) (i : ι) :
    (sContract S i).card ≤ S.card :=
  le_trans Finset.card_image_le (Finset.card_filter_le _ _)

omit [DecidableEq ι] in
theorem sTotalDeg_mono {S T : Finset (ι →₀ ℕ)} (h : S ⊆ T) :
    sTotalDeg S ≤ sTotalDeg T :=
  Finset.sum_le_sum_of_subset h

theorem sMeasure_delete_lt {S : Finset (ι →₀ ℕ)} {i : ι}
    (h : ∃ m ∈ S, 0 < m i) :
    sMeasure (sDelete S i) < sMeasure S := by
  unfold sMeasure
  have h1 := sTotalDeg_mono (sDelete_subset S i)
  have h2 := sDelete_card_lt h
  omega

theorem sContract_card_lt_of_ordinary {S : Finset (ι →₀ ℕ)} {i : ι}
    (hzero : ∃ m ∈ S, m i = 0) (hpos : ∃ m ∈ S, 0 < m i) :
    (sContract S i).card < S.card := by
  calc (sContract S i).card
      ≤ (S.filter (fun m => 0 < m i)).card := Finset.card_image_le
    _ < S.card := by
        apply Finset.card_lt_card
        refine ⟨Finset.filter_subset _ _, fun h => ?_⟩
        obtain ⟨m, hm, hmi⟩ := hzero
        have := h hm; simp [Finset.mem_filter] at this; omega

/-! ## Section 3: Measure Descent -/

theorem sTotalDeg_sContract_le (S : Finset (ι →₀ ℕ)) (i : ι) :
    sTotalDeg (sContract S i) ≤ sTotalDeg S := by
  unfold sContract sTotalDeg;
  rw [ Finset.sum_image ];
  · refine' le_trans ( Finset.sum_le_sum_of_subset ( Finset.filter_subset _ _ ) ) ( Finset.sum_le_sum fun x hx => _ );
    rw [ Finsupp.sum_of_support_subset ];
    case s => exact x.support;
    · exact Finset.sum_le_sum fun j hj => by by_cases h : j = i <;> simp +decide [ h ] ;
    · intro j hj; contrapose! hj; aesop;
    · exact fun _ _ => rfl;
  · intro m hm m' hm' h; simp_all +decide [ Finsupp.ext_iff ] ;
    intro a; specialize h a; by_cases ha : a = i <;> simp_all +decide [ Finsupp.single_apply ] ; omega;

theorem sMeasure_contract_lt_of_ordinary {S : Finset (ι →₀ ℕ)} {i : ι}
    (hord : IsOrdCoord S i) :
    sMeasure (sContract S i) < sMeasure S := by
  unfold sMeasure
  have h1 := sTotalDeg_sContract_le S i
  have h2 := sContract_card_lt_of_ordinary hord.1 hord.2
  omega

theorem sMeasure_contract_lt_of_loop {S : Finset (ι →₀ ℕ)} {i : ι}
    (hloop : IsSLoop S i) (hne : S.Nonempty) :
    sMeasure (sContract S i) < sMeasure S := by
  -- Since i is a loop, every m ∈ S has m i > 0. The filter (fun m => 0 < m i) equals S itself. The contraction map subtracts 1 from coordinate i, so each element loses at least 1 from total degree.
  have h_total_deg : sTotalDeg (sContract S i) ≤ sTotalDeg S - S.card := by
    refine' Nat.le_sub_of_add_le _;
    have h_total_deg : ∀ m ∈ S, (m - Finsupp.single i 1).sum (fun _ v => v) + 1 ≤ m.sum (fun _ v => v) := by
      intro m hm; specialize hloop m hm; simp_all +decide [ Finsupp.sum_fintype ] ;
      rw [ Finsupp.sum_of_support_subset ];
      case s => exact m.support;
      · refine' Finset.sum_lt_sum _ _ <;> simp_all +decide [ Finsupp.single_apply ];
        grind +qlia;
      · intro j hj; contrapose! hj; aesop;
      · exact fun _ _ => rfl;
    convert Finset.sum_le_sum h_total_deg using 1;
    unfold sTotalDeg sContract;
    rw [ Finset.sum_add_distrib, Finset.sum_image ];
    · rw [ Finset.filter_true_of_mem fun x hx => hloop x hx ] ; simp +decide;
    · intro m hm m' hm' h; simp_all +decide [ Finsupp.ext_iff ] ;
      intro a; specialize h a; by_cases ha : a = i <;> simp_all +decide [ Finsupp.single_apply ] ;
      omega;
  refine' lt_of_le_of_lt ( add_le_add h_total_deg ( sContract_card_le S i ) ) _;
  rw [ tsub_add_cancel_of_le ] <;> norm_num [ sMeasure ];
  · exact hne;
  · refine' le_trans _ ( Finset.sum_le_sum fun m hm => show m.sum ( fun _ v => v ) ≥ 1 from _ );
    · simp +decide;
    · exact le_trans ( Nat.succ_le_of_lt ( hloop m hm ) ) ( Finset.single_le_sum ( fun a _ => Nat.zero_le ( m a ) ) ( Finsupp.mem_support_iff.mpr ( ne_of_gt ( hloop m hm ) ) ) )

/-! ## Section 4: Support Classification -/

theorem support_classification (S : Finset (ι →₀ ℕ)) :
    S = ∅ ∨ S = {(0 : ι →₀ ℕ)} ∨
    (∃ i, IsOrdCoord S i) ∨ (∃ i, IsSLoop S i) := by
  by_cases hempty : S = ∅
  · exact Or.inl hempty
  · by_cases hall_zero : ∀ m ∈ S, m = 0
    · exact Or.inr (Or.inl (Finset.eq_singleton_iff_nonempty_unique_mem.mpr
        ⟨Finset.nonempty_iff_ne_empty.mpr hempty, hall_zero⟩))
    · push_neg at hall_zero
      obtain ⟨m, hm, hm_ne⟩ := hall_zero
      obtain ⟨i, hi⟩ := Finsupp.ne_iff.mp hm_ne
      by_cases hzero : ∃ m' ∈ S, m' i = 0
      · exact Or.inr (Or.inr (Or.inl ⟨i, hzero, m, hm, Nat.pos_of_ne_zero hi⟩))
      · push_neg at hzero
        exact Or.inr (Or.inr (Or.inr ⟨i, fun m' hm' =>
          Nat.pos_of_ne_zero (hzero m' hm')⟩))

/-! ## Section 5: Canonical Evaluation -/

noncomputable def canonicalSupportEval {R : Type*} [CommSemiring R]
    (xL : R) (S : Finset (ι →₀ ℕ)) : R :=
  if _h₁ : S = ∅ then 1
  else if _h₂ : S = {0} then 1
  else if h₃ : ∃ i, IsOrdCoord S i then
    have : sMeasure (sDelete S h₃.choose) < sMeasure S :=
      sMeasure_delete_lt h₃.choose_spec.2
    have : sMeasure (sContract S h₃.choose) < sMeasure S :=
      sMeasure_contract_lt_of_ordinary h₃.choose_spec
    canonicalSupportEval xL (sDelete S h₃.choose) +
      canonicalSupportEval xL (sContract S h₃.choose)
  else if h₄ : ∃ i, IsSLoop S i then
    have hne : S.Nonempty := Finset.nonempty_iff_ne_empty.mpr _h₁
    have : sMeasure (sContract S h₄.choose) < sMeasure S :=
      sMeasure_contract_lt_of_loop h₄.choose_spec hne
    xL * canonicalSupportEval xL (sContract S h₄.choose)
  else 1
termination_by sMeasure S

/-! ## Section 6: Theorem A — Base Cases -/

theorem canonicalSupportEval_empty {R : Type*} [CommSemiring R] (xL : R) :
    canonicalSupportEval xL (∅ : Finset (ι →₀ ℕ)) = 1 := by
  simp [canonicalSupportEval]

theorem canonicalSupportEval_singleton_zero {R : Type*} [CommSemiring R] (xL : R) :
    canonicalSupportEval xL ({(0 : ι →₀ ℕ)} : Finset (ι →₀ ℕ)) = 1 := by
  simp [canonicalSupportEval]

/-! ## Section 7: Theorem C — Universal Factorization -/

/-- **Theorem C (Universal Factorization).**
Any function satisfying the DC recurrence with loop weight `xL` equals
`canonicalSupportEval xL`. Proved by strong induction on `sMeasure`,
using `rcases` on the support classification at each step. -/
theorem dc_invariant_factors_through_canonical
    {R : Type*} [CommSemiring R] (xL : R)
    (f : Finset (ι →₀ ℕ) → R)
    (hf_empty : f ∅ = 1)
    (hf_zero : f {(0 : ι →₀ ℕ)} = 1)
    (hf_ord : ∀ S i, IsOrdCoord S i →
      f S = f (sDelete S i) + f (sContract S i))
    (hf_loop : ∀ S i, IsSLoop S i → S.Nonempty →
      f S = xL * f (sContract S i))
    (S : Finset (ι →₀ ℕ)) :
    f S = canonicalSupportEval xL S := by
  induction' n : sMeasure S using Nat.strong_induction_on with n ih generalizing S
  unfold canonicalSupportEval
  split_ifs with h₁ h₂ h₃ h₄
  · rw [h₁, hf_empty]
  · rw [h₂, hf_zero]
  · rw [hf_ord S _ h₃.choose_spec]
    congr 1
    · exact ih _ (n ▸ sMeasure_delete_lt h₃.choose_spec.2) _ rfl
    · exact ih _ (n ▸ sMeasure_contract_lt_of_ordinary h₃.choose_spec) _ rfl
  · have hne : S.Nonempty := Finset.nonempty_iff_ne_empty.mpr h₁
    rw [hf_loop S _ h₄.choose_spec hne]
    congr 1
    exact ih _ (n ▸ sMeasure_contract_lt_of_loop h₄.choose_spec hne) _ rfl
  · have := support_classification S; tauto

/-! ## Section 8: Uniqueness Corollary -/

/-- **Uniqueness corollary.** Two DC invariants with the same loop weight
    agree on all supports. Multi-step `calc` through the canonical evaluation. -/
theorem dc_invariant_unique
    {R : Type*} [CommSemiring R] (xL : R)
    (f g : Finset (ι →₀ ℕ) → R)
    (hf_empty : f ∅ = 1) (hg_empty : g ∅ = 1)
    (hf_zero : f {(0 : ι →₀ ℕ)} = 1) (hg_zero : g {(0 : ι →₀ ℕ)} = 1)
    (hf_ord : ∀ S i, IsOrdCoord S i →
      f S = f (sDelete S i) + f (sContract S i))
    (hg_ord : ∀ S i, IsOrdCoord S i →
      g S = g (sDelete S i) + g (sContract S i))
    (hf_loop : ∀ S i, IsSLoop S i → S.Nonempty →
      f S = xL * f (sContract S i))
    (hg_loop : ∀ S i, IsSLoop S i → S.Nonempty →
      g S = xL * g (sContract S i))
    (S : Finset (ι →₀ ℕ)) : f S = g S :=
  calc f S
      = canonicalSupportEval xL S :=
        dc_invariant_factors_through_canonical xL f hf_empty hf_zero hf_ord hf_loop S
    _ = g S :=
        (dc_invariant_factors_through_canonical xL g hg_empty hg_zero hg_ord hg_loop S).symm

/-! ## Section 9: Partition and Cardinality -/

theorem sContract_card_eq_filter (S : Finset (ι →₀ ℕ)) (i : ι) :
    (sContract S i).card = (S.filter (fun m => 0 < m i)).card := by
  rw [ sContract, Finset.card_image_of_injOn ];
  intro m hm n hn hmn; ext j; replace hmn := congr_arg ( fun f => f j ) hmn; by_cases hj : j = i <;> simp_all +decide [ Finsupp.single_apply ] ;
  omega

theorem delete_contract_card_partition (S : Finset (ι →₀ ℕ)) (i : ι) :
    (sDelete S i).card + (sContract S i).card = S.card := by
  rw [ sContract_card_eq_filter, ← Finset.card_union_of_disjoint ];
  · congr with m ; by_cases hm : m i = 0 <;> simp +decide [ hm, sDelete ];
    exact fun _ => Nat.pos_of_ne_zero hm;
  · exact Finset.disjoint_filter.mpr fun _ _ _ _ => by linarith;

theorem sContract_card_eq_of_loop {S : Finset (ι →₀ ℕ)} {i : ι}
    (hloop : IsSLoop S i) :
    (sContract S i).card = S.card := by
  convert sContract_card_eq_filter S i using 1;
  rw [ Finset.filter_true_of_mem hloop ]

/-! ## Section 10: Theorem B — Cardinality Specialization -/

/-
**Theorem B (Cardinality specialization).**
    Evaluating at `xL = 1` recovers the support cardinality.
-/
theorem canonicalSupportEval_one_eq_card
    (S : Finset (ι →₀ ℕ)) (hne : S.Nonempty) :
    canonicalSupportEval (1 : ℕ) S = S.card := by
  convert dc_invariant_factors_through_canonical 1 ( fun T => if T = ∅ then 1 else T.card ) _ _ _ _ using 1;
  any_goals tauto;
  · constructor;
    · intro h S;
      apply Eq.symm; exact (by
        have := dc_invariant_factors_through_canonical 1 (fun T => if T = ∅ then 1 else T.card) (by
        simp +decide) (by
        simp +decide) (by
        intro S i hi; have := delete_contract_card_partition S i; simp_all +decide ;
        split_ifs <;> simp_all +decide [ IsOrdCoord ];
        · exact absurd this ( ne_of_lt ( Finset.card_pos.mpr ( Finset.nonempty_of_ne_empty ‹_› ) ) );
        · simp_all +decide [ Finset.ext_iff, sDelete ];
          exact absurd hi.1 ( by tauto );
        · unfold sContract at *; aesop;) (by
        intro S i hi hne; simp +decide [ hi, hne, sContract_card_eq_of_loop hi ] ;
        rw [ if_neg ( Finset.Nonempty.ne_empty hne ), if_neg ( Finset.Nonempty.ne_empty ( Finset.card_pos.mp ( by rw [ sContract_card_eq_of_loop hi ] ; exact Finset.card_pos.mpr hne ) ) ) ]) S;
        exact this.symm
      );
    · grind;
  · intro S i hi; by_cases hS : S = ∅ <;> simp +decide [ hS, delete_contract_card_partition ] ;
    · cases hi ; aesop;
    · split_ifs <;> simp_all +decide [ IsOrdCoord ];
      · simp_all +decide [ sDelete, sContract ];
      · simp_all +decide [ sDelete ];
        grind;
      · unfold sContract at *; aesop;
      · rw [ delete_contract_card_partition ];
  · intro S i hloop hne; simp +decide [ hloop, hne, sContract_card_eq_of_loop ] ;
    simp +decide [ sContract, hne.ne_empty ];
    exact fun h => absurd ( hloop _ hne.choose_spec ) ( by simp +decide [ h hne.choose_spec ] )

/-! ## Section 11: Theorem D — Binary Support Bridge -/

/-
For binary supports, ordinary coordinates correspond exactly to
    having both 0-valued and 1-valued elements.
-/
theorem binary_ordinary_iff {S : Finset (ι →₀ ℕ)} {i : ι}
    (hbin : IsBinarySupport S) :
    IsOrdCoord S i ↔ (∃ m ∈ S, m i = 0) ∧ (∃ m ∈ S, m i = 1) := by
  exact ⟨ fun h => ⟨ h.1, by obtain ⟨ m, hm₁, hm₂ ⟩ := h.2; exact ⟨ m, hm₁, by cases hbin m hm₁ i <;> linarith ⟩ ⟩, fun h => ⟨ h.1, by obtain ⟨ m, hm₁, hm₂ ⟩ := h.2; exact ⟨ m, hm₁, by linarith ⟩ ⟩ ⟩

/-- Binary support deletion produces binary support. -/
theorem binary_sDelete {S : Finset (ι →₀ ℕ)} {i : ι}
    (hbin : IsBinarySupport S) :
    IsBinarySupport (sDelete S i) :=
  fun m hm => hbin m (mem_sDelete_iff.mp hm).1

/-
Binary support contraction produces binary support.
-/
theorem binary_sContract {S : Finset (ι →₀ ℕ)} {i : ι}
    (hbin : IsBinarySupport S) :
    IsBinarySupport (sContract S i) := by
  unfold IsBinarySupport; intro m hm;
  obtain ⟨ n, hn, rfl ⟩ := Finset.mem_image.mp hm;
  intro j; by_cases hj : j = i <;> simp_all +decide [ Finsupp.single_apply ] ;
  · cases hbin n hn.1 i <;> aesop;
  · exact hbin _ hn.1 _

/-- **Theorem D (Binary support bridge).**
    For binary supports, `|S| = |del(S,i)| + |con(S,i)|`. -/
theorem binary_support_card_recursion
    {S : Finset (ι →₀ ℕ)} {i : ι}
    (_hbin : IsBinarySupport S)
    (_hord : IsOrdCoord S i) :
    S.card = (sDelete S i).card + (sContract S i).card :=
  (delete_contract_card_partition S i).symm

/-- For binary supports, contraction at a loop preserves cardinality. -/
theorem binary_loop_contract_card {S : Finset (ι →₀ ℕ)} {i : ι}
    (_hbin : IsBinarySupport S) (hloop : IsSLoop S i) :
    (sContract S i).card = S.card :=
  sContract_card_eq_of_loop hloop

/-! ## Section 12: Activity Counting -/

/-- **Support activity data** for deletion–contraction decomposition. -/
structure SupportActivityData where
  loops : ℕ
  coloops : ℕ
  ordinaryDel : ℕ
  ordinaryCon : ℕ
  deriving Repr, DecidableEq

def SupportActivityData.total (d : SupportActivityData) : ℕ :=
  d.loops + d.coloops + d.ordinaryDel + d.ordinaryCon

noncomputable def loopCount (S : Finset (ι →₀ ℕ)) (ground : Finset ι) : ℕ :=
  (ground.filter (fun i => ∀ m ∈ S, 0 < m i)).card

noncomputable def ordinaryCount (S : Finset (ι →₀ ℕ)) (ground : Finset ι) : ℕ :=
  (ground.filter (fun i => (∃ m ∈ S, m i = 0) ∧ (∃ m ∈ S, 0 < m i))).card

noncomputable def trivialCount (S : Finset (ι →₀ ℕ)) (ground : Finset ι) : ℕ :=
  (ground.filter (fun i => ∀ m ∈ S, m i = 0)).card

/-
**Activity partition theorem.** Coordinates partition into loops,
    ordinary, and trivial, so their counts sum to `|ground|`.
-/
theorem activity_partition (S : Finset (ι →₀ ℕ)) (ground : Finset ι)
    (hne : S.Nonempty) :
    loopCount S ground + ordinaryCount S ground + trivialCount S ground
      = ground.card := by
  rw [ loopCount, ordinaryCount, trivialCount, ← Finset.card_union_of_disjoint, ← Finset.card_union_of_disjoint ];
  · congr with i;
    grind;
  · simp +contextual [ Finset.disjoint_left ];
    grind;
  · exact Finset.disjoint_filter.mpr fun _ _ _ _ => by obtain ⟨ m, hm, hm' ⟩ := ‹ ( ∃ m ∈ S, m _ = 0 ) ∧ ∃ m ∈ S, 0 < m _ ›.1; linarith [ ‹∀ m ∈ S, 0 < m _› m hm ] ;

end SupportTutteUniversality