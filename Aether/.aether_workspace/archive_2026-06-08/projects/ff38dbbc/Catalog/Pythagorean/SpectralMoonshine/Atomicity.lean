/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Spectral Atomicity: Unit Energy Forces Irreducibility

This file proves that nonneg-integer-valued vectors with unit squared norm
must be supported on exactly one coordinate. This is the combinatorial core
of the **Spectral Atomicity Theorem** for class functions: a nonneg-integer
class function whose spectral energy equals 1 must be a single irreducible
character.

## Main Results

* `Finset.sq_sum_eq_one_of_nonneg` — if nonneg integers square-sum to 1,
  exactly one equals 1 and the rest are 0.
* `Finset.unique_nonzero_of_sq_sum_one` — uniqueness of the nonzero index.
* `support_card_eq_one_of_sq_sum_one` — the support has cardinality exactly 1.

## Application to Representation Theory

In the representation-theoretic setting, if `f` is a nonneg-integer-valued class
function with `∑ᵢ ⟨f, χᵢ⟩² = 1` (unit spectral energy), then `f = χⱼ` for a
unique irreducible character `χⱼ`. The spectral multiplicities `⟨f, χᵢ⟩` are
nonneg integers by hypothesis, so this theorem applies directly.
-/

open Finset BigOperators

/-! ## Core Atomicity Lemma -/

/-
**Spectral Atomicity (Combinatorial Core).** If a finitely-supported function
from a finite index set to `ℕ` has squared sum equal to 1, then exactly one index
has value 1 and all others have value 0. This is the combinatorial heart of the
theorem that unit-energy nonneg-integer class functions are irreducible characters.
-/
theorem nonneg_sq_sum_eq_one_implies_unique {ι : Type*} [Fintype ι] [DecidableEq ι]
    (a : ι → ℕ) (h : ∑ i, a i ^ 2 = 1) :
    ∃ j, a j = 1 ∧ ∀ i, i ≠ j → a i = 0 := by
  -- First show j with a j ≠ 0 (otherwise sum is 0).
  obtain ⟨j, hj⟩ : ∃ j, a j ≠ 0 := by
    contrapose! h; aesop;
  -- For any i ≠ j, a � i� ^ 2 + a j ^ 2 ≤ ∑ a_k² = 1, so a i ^ 2 ≤ 0, giving a i = 0.
  have h_zero : ∀ i ≠ j, a i = 0 := by
    intro i hi; have := h ▸ Finset.single_le_sum ( fun x _ => Nat.zero_le ( a x ^ 2 ) ) ( Finset.mem_univ i ) ; have := h ▸ Finset.single_le_sum ( fun x _ => Nat.zero_le ( a x ^ 2 ) ) ( Finset.mem_univ j ) ; simp_all +decide ;
    interval_cases _ : a i <;> interval_cases _ : a j <;> simp_all +decide;
    exact absurd h ( by rw [ Finset.sum_eq_add_sum_diff_singleton ( Finset.mem_univ i ) ] ; exact ne_of_gt ( lt_add_of_le_of_pos ( by simp +decide [ * ] ) ( lt_of_lt_of_le ( by simp +decide [ * ] ) ( Finset.single_le_sum ( fun x _ => Nat.zero_le ( a x ^ 2 ) ) ( Finset.mem_sdiff.mpr ⟨ Finset.mem_univ j, by aesop ⟩ ) ) ) ) );
  rw [ Finset.sum_eq_single j ] at h <;> aesop

/-
The support of a function with unit squared sum has exactly one element.
-/
theorem support_card_eq_one_of_sq_sum_one {ι : Type*} [Fintype ι] [DecidableEq ι]
    (a : ι → ℕ) (h : ∑ i, a i ^ 2 = 1) :
    (Finset.univ.filter (fun i => a i ≠ 0)).card = 1 := by
  -- Use nonneg_sq_sum_eq �_one�_implies_unique to get j with a j = 1 and ∀ i ≠ j, a i = 0.
  obtain ⟨j, hj⟩ : ∃ j, a j = 1 ∧ ∀ i, i ≠ j → a i = 0 := by
    convert nonneg_sq_sum_eq_one_implies_unique a h;
  rw [ Finset.card_eq_one ] ; use j ; ext i ; by_cases hi : i = j <;> aesop

/-
**Spectral Atomicity (Integer version).** If nonneg integers have squared sum
equal to 1, the function equals the Kronecker delta at the unique nonzero index.
-/
theorem sq_sum_one_eq_indicator {ι : Type*} [Fintype ι] [DecidableEq ι]
    (a : ι → ℕ) (h : ∑ i, a i ^ 2 = 1) :
    ∃ j, a = fun i => if i = j then 1 else 0 := by
  -- By nonneg_sq_sum_eq_one_implies_unique �,� we get $j$ with $a j = 1$ and $\forall i \neq j, a i = 0$.
  obtain ⟨j, hj⟩ := nonneg_sq_sum_eq_one_implies_unique a h;
  exact ⟨ j, funext fun i => by by_cases hi : i = j <;> simp +decide [ * ] ⟩

/-
The squared sum of a function with at most one nonzero value is the square
of that value. This is the converse direction: Kronecker deltas have unit energy.
-/
theorem sq_sum_of_indicator {ι : Type*} [Fintype ι] [DecidableEq ι]
    (j : ι) : ∑ i, (if i = j then 1 else 0 : ℕ) ^ 2 = 1 := by
  simp +zetaDelta at *

/-! ## Generalization to ℤ with absolute value -/

/-
**Spectral Atomicity for Integers.** If integers have squared sum equal to 1,
then exactly one has absolute value 1 and the rest are 0.
-/
theorem int_sq_sum_eq_one_implies_unique {ι : Type*} [Fintype ι] [DecidableEq ι]
    (a : ι → ℤ) (h : ∑ i, a i ^ 2 = 1) :
    ∃ j, |a j| = 1 ∧ ∀ i, i ≠ j → a i = 0 := by
  have := nonneg_sq_sum_eq_one_implies_unique ( fun i => Int.natAbs ( a i ) ) ?_;
  · simpa [ ← Int.natCast_inj ] using this;
  · simp +decide [ ← Int.natCast_inj, ← h ]

/-
If nonneg integers have squared sum equal to 1, their sum also equals 1.
-/
theorem sum_eq_one_of_sq_sum_one {ι : Type*} [Fintype ι] [DecidableEq ι]
    (a : ι → ℕ) (h : ∑ i, a i ^ 2 = 1) :
    ∑ i, a i = 1 := by
  have := nonneg_sq_sum_eq_one_implies_unique a h;
  grind +splitImp

/-! ## Two-term bound -/

/-
If two nonneg integers have squares summing to at most 1, at most one is nonzero.
-/
theorem at_most_one_nonzero_of_sq_sum_le_one {a b : ℕ} (h : a ^ 2 + b ^ 2 ≤ 1) :
    a = 0 ∨ b = 0 := by
  rcases a with ( _ | _ | a ) <;> rcases b with ( _ | _ | b ) <;> simp_all +arith +decide only [ sq ];
  · grind;
  · contradiction;
  · grind

/-
A nonneg integer whose square is at most 1 is either 0 or 1.
-/
theorem eq_zero_or_one_of_sq_le_one {n : ℕ} (h : n ^ 2 ≤ 1) : n = 0 ∨ n = 1 := by
  cases n <;> simp_all +decide [ sq ]