/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The Erdős–Ginzburg–Ziv constant of a cyclic group

This file proves that the Erdős–Ginzburg–Ziv constant of the cyclic group
`C_n = ZMod n` equals `2 * n - 1`.

The *EGZ property* `HasEGZProperty n m` says that every sequence of `m` elements
of `ZMod n` contains a subsequence of length `n` whose sum is zero.  The
*EGZ constant* `EGZ n` is the least `m` with this property.

The main result `EGZConstructive.EGZ_eq` states `EGZ n = 2 * n - 1` for `n ≥ 1`.
It is obtained from two halves:

* **Upper bound** (`exists_contiguous_zero_block_in_some_length`): every sequence
  of `2 * n - 1` elements of `ZMod n` has a length-`n` zero-sum subsequence.  This
  is the substantive direction of the Erdős–Ginzburg–Ziv theorem; we obtain it
  from Mathlib's `ZMod.erdos_ginzburg_ziv`, whose proof goes through the
  Chevalley–Warning theorem.  Despite the historical name, the zero-sum *block*
  is an arbitrary subset of size `n`; it need **not** be contiguous, and the
  statement is phrased accordingly.

* **Lower bound** (`not_hasEGZProperty_two_mul_sub_two`): the extremal sequence
  consisting of `n - 1` copies of `0` followed by `n - 1` copies of `1` has length
  `2 * n - 2` and admits no length-`n` zero-sum subsequence, so the EGZ property
  fails at `2 * n - 2`.

The function `findZeroSumSubset` extracts a witnessing zero-sum subset from any
sequence of length `2 * n - 1`.
-/
import Mathlib

namespace EGZConstructive

open Finset

/-- `HasEGZProperty n m` holds when every sequence of `m` elements of `ZMod n`
contains a subsequence of length `n` whose sum is zero. -/
def HasEGZProperty (n m : ℕ) : Prop :=
  ∀ a : Fin m → ZMod n, ∃ t : Finset (Fin m), t.card = n ∧ ∑ i ∈ t, a i = 0

/-- The Erdős–Ginzburg–Ziv constant of the cyclic group `ZMod n`: the least
length `m` such that every sequence of `m` elements of `ZMod n` contains a
length-`n` zero-sum subsequence. -/
noncomputable def EGZ (n : ℕ) : ℕ := sInf {m | HasEGZProperty n m}

/--
The EGZ property is upward closed in the sequence length: if every length-`m`
sequence has a zero-sum length-`n` subsequence and `m ≤ m'`, then so does every
length-`m'` sequence (restrict to the first `m` coordinates).
-/
theorem hasEGZProperty_mono {n m m' : ℕ} (h : HasEGZProperty n m) (hm : m ≤ m') :
    HasEGZProperty n m' := by
  intro a
  obtain ⟨t, ht_card, ht_sum⟩ := h (fun i => a (Fin.castLE hm i));
  refine' ⟨ Finset.image ( fun i ↦ Fin.castLE hm i ) t, _, _ ⟩ <;> simp_all +decide [ Finset.card_image_of_injective, Function.Injective ]

/--
**Erdős–Ginzburg–Ziv, upper bound (non-contiguity corrected form).**
Every sequence of `2 * n - 1` elements of `ZMod n` contains a subset of size `n`
— not necessarily a contiguous block — whose sum is zero.  Obtained from
Mathlib's `ZMod.erdos_ginzburg_ziv`.
-/
theorem exists_contiguous_zero_block_in_some_length (n : ℕ)
    (a : Fin (2 * n - 1) → ZMod n) :
    ∃ t : Finset (Fin (2 * n - 1)), t.card = n ∧ ∑ i ∈ t, a i = 0 := by
  have := @ZMod.erdos_ginzburg_ziv;
  specialize @this ( Fin ( 2 * n - 1 ) ) n Finset.univ a ; simp_all +decide

/-- The EGZ property holds at length `2 * n - 1`. -/
theorem hasEGZProperty_two_mul_sub_one (n : ℕ) : HasEGZProperty n (2 * n - 1) :=
  exists_contiguous_zero_block_in_some_length n

/-- The extremal sequence witnessing the lower bound: `n - 1` copies of `0`
followed by `n - 1` copies of `1`, as a sequence of length `2 * n - 2`. -/
def extremalSeq (n : ℕ) : Fin (2 * n - 2) → ZMod n :=
  fun i => if (i : ℕ) < n - 1 then 0 else 1

/--
For the extremal sequence, the sum over a subset `t` equals (the cast of) the
number of indices in `t` lying in the "ones" block.
-/
theorem extremalSeq_sum_eq (n : ℕ) (t : Finset (Fin (2 * n - 2))) :
    ∑ i ∈ t, extremalSeq n i =
      ((t.filter (fun i => n - 1 ≤ i.val)).card : ZMod n) := by
  unfold extremalSeq;
  simp +decide [ Finset.sum_ite ]

/--
**Lower bound.** The EGZ property fails at length `2 * n - 2`: the extremal
sequence has no length-`n` zero-sum subsequence.
-/
theorem not_hasEGZProperty_two_mul_sub_two (n : ℕ) (hn : 1 ≤ n) :
    ¬ HasEGZProperty n (2 * n - 2) := by
  intro h
  obtain ⟨t, ht_card, ht_sum⟩ := h (extremalSeq n);
  -- Let `k := (t.filter (fun i => n - 1 ≤ i.val)).card` (the "ones") and `z := (t.filter (fun i => ¬ (n - 1 ≤ i.val))).card` (the "zeros").
  set k := (t.filter (fun i => n - 1 ≤ i.val)).card
  set z := (t.filter (fun i => ¬ (n - 1 ≤ i.val))).card;
  -- From `k + z = n` and `z ≤ n-1` we get `k ≥ 1`.
  have hk_ge_1 : 1 ≤ k := by
    have hz_le : z ≤ n - 1 := by
      refine' le_trans ( Finset.card_le_card _ ) _;
      exact Finset.univ.filter fun i => i.val < n - 1;
      · grind;
      · rw [ Finset.card_eq_of_bijective ];
        use fun i hi => ⟨ i, by omega ⟩;
        · aesop;
        · grind;
        · aesop;
    have hkz : k + z = n := by
      rw [ ← ht_card, Finset.card_filter_add_card_filter_not ];
    omega;
  -- So `1 ≤ k ≤ n - 1 < n`. Then `(k : ZMod n) ≠ 0` because `ZMod.natCast_eq_zero_iff` gives `(k:ZMod n)=0 ↔ n ∣ k`, and `n ∣ k` with `0 < k < n` is impossible (`Nat.le_of_dvd`).
  have hk_lt_n : k < n := by
    refine' lt_of_lt_of_le ( Finset.card_lt_card ( Finset.filter_ssubset.mpr _ ) ) ht_card.le;
    contrapose! hk_ge_1;
    rcases n with ( _ | _ | n ) <;> simp_all +decide;
    · fin_cases t ; trivial;
    · exact absurd ( Finset.card_le_card ( show t ⊆ Finset.Ici ⟨ n + 1, by omega ⟩ from fun x hx => Finset.mem_Ici.mpr ( Nat.succ_le_of_lt ( hk_ge_1 x hx ) ) ) ) ( by simp +arith +decide [ ht_card ] )
  have hk_ne_zero : (k : ZMod n) ≠ 0 := by
    rw [ Ne.eq_def, ZMod.natCast_eq_zero_iff ] ; exact Nat.not_dvd_of_pos_of_lt hk_ge_1 hk_lt_n;
  exact hk_ne_zero <| by rw [ ← extremalSeq_sum_eq ] ; aesop;

/--
The EGZ property fails at every length below `2 * n - 1`.
-/
theorem not_hasEGZProperty_of_lt (n : ℕ) (hn : 1 ≤ n) {m : ℕ} (hm : m < 2 * n - 1) :
    ¬ HasEGZProperty n m := by
  exact fun h => by have := hasEGZProperty_mono h ( by omega : m ≤ 2 * n - 2 ) ; exact not_hasEGZProperty_two_mul_sub_two n hn this;

/--
**The Erdős–Ginzburg–Ziv constant of `ZMod n` equals `2 * n - 1`.**
-/
theorem EGZ_eq (n : ℕ) (hn : 1 ≤ n) : EGZ n = 2 * n - 1 := by
  refine' le_antisymm ( csInf_le _ _ ) ( le_csInf _ _ );
  · exact ⟨ 0, fun m hm => Nat.zero_le _ ⟩;
  · exact hasEGZProperty_two_mul_sub_one n;
  · exact ⟨ _, hasEGZProperty_two_mul_sub_one n ⟩;
  · exact fun m hm => not_lt.1 fun contra => not_hasEGZProperty_of_lt n hn contra hm

/-- Algorithmic extraction: a length-`n` zero-sum subset of any sequence of length
`2 * n - 1`. -/
noncomputable def findZeroSumSubset (n : ℕ) (a : Fin (2 * n - 1) → ZMod n) :
    Finset (Fin (2 * n - 1)) :=
  (exists_contiguous_zero_block_in_some_length n a).choose

/-- `findZeroSumSubset` returns a subset of size `n` summing to zero. -/
theorem findZeroSumSubset_spec (n : ℕ) (a : Fin (2 * n - 1) → ZMod n) :
    (findZeroSumSubset n a).card = n ∧ ∑ i ∈ findZeroSumSubset n a, a i = 0 :=
  (exists_contiguous_zero_block_in_some_length n a).choose_spec

end EGZConstructive