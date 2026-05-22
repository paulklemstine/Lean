/-
Copyright (c) 2024 Thermodynamic Galois Duality Project. All rights reserved.
-/
import Bridges.ThermodynamicGalois.Defs

/-!
# Transfer Matrix Properties and Partition Sum Submultiplicativity

This module establishes fundamental properties of the weighted transfer matrix
and partition function for finite closure dynamical systems.

## Main Results

* `transferMatrix_nonneg` — All entries of the transfer matrix are nonneg
* `partitionSum_zero` — Z_0 = |X| (the identity matrix contributes one per state)
* `partitionSum_nonneg` — Z_n ≥ 0 for nonneg matrices
* `partitionSum_submultiplicative` — Z_{m+n} ≤ Z_m · Z_n (key for pressure existence)
* `partitionSum_one` — Z_1 equals the sum of all matrix entries

## Mathematical Overview

The partition function Z_n = Σ_{x,y} (A^n)(x,y) counts the total weighted mass
of all length-n paths in the closure dynamical system. Submultiplicativity
Z_{m+n} ≤ Z_m · Z_n is the key property ensuring that the thermodynamic
pressure P = lim_{n→∞} (1/n) log Z_n is well-defined (via Fekete's lemma).

The submultiplicativity proof uses the fact that for nonneg matrices,
expanding a constrained sum (over paths factoring through an intermediate
state z) to an unconstrained product of sums only increases the total.
-/

open Finset BigOperators Matrix

noncomputable section

variable {X : Type*} [Fintype X] [DecidableEq X]
variable {Gen : Type*} [Fintype Gen] [DecidableEq Gen]

/-! ### Transfer Matrix Nonnegativity -/

omit [Fintype X] [DecidableEq X] [DecidableEq Gen] in
/-- Every entry of the weighted transfer matrix is nonneg, since it is a sum
    of nonneg terms (each being either `exp(w g) > 0` or `0`). -/
theorem transferMatrix_nonneg (step : Gen → X → X → Prop)
    [∀ g x y, Decidable (step g x y)]
    (w : Gen → ℝ) (x y : X) :
    0 ≤ transferMatrix step w x y := by
  exact Finset.sum_nonneg fun _ _ => by positivity;

/-! ### Partition Sum Basic Properties -/

/-
Z_0 = |X|: at time zero, the identity matrix gives one path per state.
-/
theorem partitionSum_zero (A : Matrix X X ℝ) :
    partitionSum A 0 = Fintype.card X := by
  convert Finset.sum_const ( 1 : ℝ );
  convert Finset.sum_comm;
  · simp +decide [ Matrix.one_apply ];
  · simp +decide [ Finset.card_univ ]

/-
Z_1 equals the total sum of matrix entries.
-/
theorem partitionSum_one (A : Matrix X X ℝ) :
    partitionSum A 1 = ∑ x : X, ∑ y : X, A x y := by
  unfold partitionSum; aesop;

/-
Z_n is nonneg when A has nonneg entries.
-/
theorem partitionSum_nonneg {A : Matrix X X ℝ}
    (hA : ∀ x y : X, 0 ≤ A x y) (n : ℕ) :
    0 ≤ partitionSum A n := by
  -- Since each entry of A^n is non-negative, the sum of the entries of A^n is also non-negative.
  have h_nonneg : ∀ x y, 0 ≤ (A ^ n) x y := by
    induction' n with n ih;
    · simp +decide [ Matrix.one_apply ];
      exact fun x y => by split_ifs <;> norm_num;
    · exact fun x y => by rw [ pow_succ', Matrix.mul_apply ] ; exact Finset.sum_nonneg fun _ _ => mul_nonneg ( hA _ _ ) ( ih _ _ ) ;
  exact Finset.sum_nonneg fun x _ => Finset.sum_nonneg fun y _ => h_nonneg x y

/-! ### Matrix Power Entry Nonnegativity -/

/-
Powers of a nonneg matrix have nonneg entries.
-/
theorem matrix_pow_nonneg {A : Matrix X X ℝ}
    (hA : ∀ x y : X, 0 ≤ A x y) (n : ℕ) (x y : X) :
    0 ≤ (A ^ n) x y := by
  induction' n with n ih generalizing x y;
  · by_cases h : x = y <;> simp +decide [ h ];
  · simpa only [ pow_succ', Matrix.mul_apply ] using Finset.sum_nonneg fun z _ => mul_nonneg ( hA x z ) ( ih z y )

/-! ### Submultiplicativity -/

/-
**Partition Sum Submultiplicativity**: Z_{m+n} ≤ Z_m · Z_n.

    This is the key inequality ensuring the thermodynamic pressure exists.
    The proof uses the factorization of matrix powers through intermediate states:
    `(A^{m+n})(x,y) = Σ_z (A^m)(x,z) · (A^n)(z,y)`
    and the inequality `Σ_z a_z · b_z ≤ (Σ_z a_z) · (Σ_z b_z)` for nonneg terms.
-/
theorem partitionSum_submultiplicative {A : Matrix X X ℝ}
    (hA : ∀ x y : X, 0 ≤ A x y) (m n : ℕ) :
    partitionSum A (m + n) ≤ partitionSum A m * partitionSum A n := by
  unfold partitionSum;
  -- Apply the inequality `Σ_z a_z · b_z ≤ (Σ_z a_z) · (Σ_z b_z)` for nonneg terms `a_z` and `b_z`.
  have h_ineq : ∀ (f : X → X → ℝ) (g : X → X → ℝ), (∀ x y, 0 ≤ f x y) → (∀ x y, 0 ≤ g x y) → (∑ x : X, ∑ z : X, ∑ y : X, f x z * g z y) ≤ (∑ x : X, ∑ y : X, f x y) * (∑ x : X, ∑ y : X, g x y) := by
    intro f g hf hg
    have h_ineq : ∀ (x z : X), f x z * ∑ y : X, g z y ≤ f x z * ∑ x : X, ∑ y : X, g x y := by
      exact fun x z => mul_le_mul_of_nonneg_left ( Finset.single_le_sum ( fun x _ => Finset.sum_nonneg fun y _ => hg x y ) ( Finset.mem_univ z ) ) ( hf x z );
    simpa only [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul ] using Finset.sum_le_sum fun x _ => Finset.sum_le_sum fun z _ => h_ineq x z;
  convert h_ineq ( fun x y => ( A ^ m ) x y ) ( fun x y => ( A ^ n ) x y ) ( fun x y => matrix_pow_nonneg hA m x y ) ( fun x y => matrix_pow_nonneg hA n x y ) using 1;
  simp +decide only [pow_add, Matrix.mul_apply];
  exact Finset.sum_congr rfl fun _ _ => Finset.sum_comm

/-! ### Partition Sum as Matrix Trace of Augmented Matrix -/

/-
The partition sum Z_n can be expressed using the all-ones vector:
    Z_n = 1ᵀ · A^n · 1, where 1 is the all-ones vector.
    This connects path counting to linear algebra.
-/
theorem partitionSum_eq_vec_mul (A : Matrix X X ℝ) (n : ℕ) :
    partitionSum A n = ∑ x : X, (A ^ n).mulVec (fun _ => 1) x := by
  unfold partitionSum; simp +decide [ Matrix.mulVec, dotProduct ] ;

end