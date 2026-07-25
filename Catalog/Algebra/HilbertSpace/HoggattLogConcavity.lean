/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Log-concavity of Hoggatt total sequences

This file studies the (infinite) log-concavity of two representative "total
`d`-Hoggatt" sequences:

* `d = 1`: the geometric sequence `n ↦ r ^ n` (in particular `r = 2`, the row
  sums of Pascal's triangle). This sequence is *infinitely* log-concave.
* `d = 2`: the Catalan numbers, defined here through the ratio recurrence
  `C₀ = 1`, `C_{n+1} = 2 (2n+1) / (n+2) · Cₙ`. These are not even log-concave;
  in fact they are strictly log-convex.

The log-concavity operator is `Lop a n = a (n+1) ^ 2 - a n * a (n+2)`. A sequence
is log-concave when `Lop a ≥ 0` pointwise, and infinitely log-concave when every
iterate of `Lop` stays nonnegative.
-/

namespace HoggattLogConcavity

open Real

/-- The log-concavity operator sending a sequence `a` to
`n ↦ a (n+1) ^ 2 - a n * a (n+2)`. -/
def Lop (a : ℕ → ℝ) : ℕ → ℝ := fun n => (a (n + 1)) ^ 2 - a n * a (n + 2)

/-- A sequence is log-concave when its log-concavity operator is nonnegative. -/
def IsLogConcave (a : ℕ → ℝ) : Prop := ∀ n, 0 ≤ Lop a n

/-- A sequence is log-convex when its log-concavity operator is nonpositive. -/
def IsLogConvex (a : ℕ → ℝ) : Prop := ∀ n, Lop a n ≤ 0

/-- A sequence is infinitely log-concave when every iterate of `Lop` is
nonnegative (equivalently, log-concave). -/
def IsInfLogConcave (a : ℕ → ℝ) : Prop := ∀ k : ℕ, IsLogConcave (Lop^[k] a)

/-- Real-valued Catalan numbers via the ratio recurrence. -/
noncomputable def catalan : ℕ → ℝ
  | 0 => 1
  | (n + 1) => 2 * (2 * (n : ℝ) + 1) / ((n : ℝ) + 2) * catalan n

/-! ### Easy lemmas -/

/-- The `Lop` of a geometric sequence vanishes. -/
lemma Lop_geometric (r : ℝ) : Lop (fun n => r ^ n) = fun _ => 0 := by
  funext n
  simp only [Lop]
  ring

/-- The `Lop` of the zero sequence is the zero sequence. -/
lemma Lop_zero : Lop (fun _ => (0 : ℝ)) = fun _ => 0 := by
  funext n
  simp [Lop]

/-- The zero sequence is log-concave. -/
lemma zero_isLogConcave : IsLogConcave (fun _ => (0 : ℝ)) := by
  intro n
  simp [Lop]

/-- Iterating `Lop` on the zero sequence keeps the zero sequence. -/
lemma Lop_iterate_zero (k : ℕ) : Lop^[k] (fun _ => (0 : ℝ)) = fun _ => 0 := by
  induction k with
  | zero => rfl
  | succ m ih => rw [Function.iterate_succ_apply', ih, Lop_zero]

/-- The zero sequence is infinitely log-concave. -/
lemma zero_isInfLogConcave : IsInfLogConcave (fun _ => (0 : ℝ)) := by
  intro k
  rw [Lop_iterate_zero]
  exact zero_isLogConcave

/-- Geometric sequences are infinitely log-concave. -/
lemma geometric_infLogConcave (r : ℝ) : IsInfLogConcave (fun n => r ^ n) := by
  intro k n
  cases k with
  | zero =>
      simp [Function.iterate_zero, congrFun (Lop_geometric r) n]
  | succ m =>
      rw [Function.iterate_succ_apply, Lop_geometric, Lop_iterate_zero]
      simp [Lop]

/-! ### Catalan number results -/

/-- Recurrence unfolding for the real Catalan numbers. -/
lemma catalan_succ_eq (n : ℕ) :
    catalan (n + 1) = 2 * (2 * (n : ℝ) + 1) / ((n : ℝ) + 2) * catalan n := by
  rfl

/-- The Catalan numbers are strictly positive. -/
lemma catalan_pos : ∀ n, 0 < catalan n := by
  -- We'll use induction to prove that the Catalan numbers are positive.
  intro n
  induction' n with n ih;
  · exact zero_lt_one;
  · exact mul_pos ( by positivity ) ih

/-- Key algebraic identity behind strict log-convexity. -/
lemma catalan_key_identity (n : ℕ) :
    (2 * (n : ℝ) + 3) * ((n : ℝ) + 2) - (2 * (n : ℝ) + 1) * ((n : ℝ) + 3) = 3 := by
  ring

/-- The `Lop` operator applied to Catalan numbers is strictly negative. -/
lemma catalan_Lop_neg : ∀ n, Lop catalan n < 0 := by
  intro n;
  have h1 : catalan (n + 1) = 2 * (2 * (n : ℝ) + 1) / ((n : ℝ) + 2) * catalan n := catalan_succ_eq n
  have h2 : catalan (n + 2) = 2 * (2 * (n : ℝ) + 3) / ((n : ℝ) + 3) * catalan (n + 1) := by
    convert catalan_succ_eq ( n + 1 ) using 1 ; push_cast ; ring;
  simp_all +decide [ Lop ];
  field_simp;
  nlinarith only [ show 0 < catalan n ^ 2 by exact sq_pos_of_pos ( catalan_pos n ) ]

/-- The Catalan numbers are log-convex. -/
lemma catalan_logConvex : IsLogConvex catalan := by
  intro n
  exact le_of_lt (catalan_Lop_neg n)

/-- The Catalan numbers are not log-concave. -/
lemma catalan_not_logConcave : ¬ IsLogConcave catalan := by
  intro h
  have h0 := h 0
  have h0' := catalan_Lop_neg 0
  linarith

/-- The Catalan numbers are not infinitely log-concave. -/
lemma catalan_not_infLogConcave : ¬ IsInfLogConcave catalan := by
  intro h
  exact catalan_not_logConcave (by simpa using h 0)

/-! ### Main theorem -/

/-- The total `d`-Hoggatt sequences illustrated for the two smallest values of
`d`: for `d = 1` (the geometric row sums `2 ^ n`) the sequence is infinitely
log-concave, whereas for `d = 2` (the Catalan numbers) it fails to be even
log-concave. Hence infinite log-concavity holds for `d = 1` but not for `d = 2`. -/
theorem hoggatt_logConcavity :
    IsInfLogConcave (fun n => (2 : ℝ) ^ n) ∧ ¬ IsLogConcave catalan :=
  ⟨geometric_infLogConcave 2, catalan_not_logConcave⟩

end HoggattLogConcavity