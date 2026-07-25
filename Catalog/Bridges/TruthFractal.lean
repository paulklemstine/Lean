import Mathlib

/-!
# Truth languages, symbolic dimension, and binary reals

This file gives a precise connector between three areas:

* a toy language of mathematical statements, represented by infinite bit streams;
* symbolic fractal geometry, measured by exponential growth of admissible prefixes;
* binary real coding, in the style of a halting-probability real.

The predicate `pairedTruth` is a deliberately transparent model of a sparse but
non-negligible truth language: every even-positioned statement is true, while the
odd-positioned statements are free.  Thus exactly half the information remains.
The main counting theorem says that the square of the number of admissible
prefixes of length `2n` equals the number of all binary prefixes of that length.
This is an exact finite-scale formulation of symbolic dimension `1/2`.
-/

namespace TruthFractal

/-- An infinite formal theory, with `true` marking the statements it accepts. -/
abbrev Theory := ℕ → Bool

/-- Prefix distance: streams that first differ late are close.  This is the
standard binary prefix coding into the nonnegative reals. -/
noncomputable def prefixDistance (x y : Theory) : ℝ :=
  ∑' n : ℕ, (if x n = y n then 0 else 1 : ℝ) * (1 / 2 : ℝ) ^ (n + 1)

/-- Binary real coding of a truth stream. -/
noncomputable def truthReal (x : Theory) : ℝ :=
  ∑' n : ℕ, (if x n then 1 else 0 : ℝ) * (1 / 2 : ℝ) ^ (n + 1)

/-- The computable lower approximation obtained from the first `N` truth bits. -/
noncomputable def truthApprox (x : Theory) (N : ℕ) : ℝ :=
  ∑ n ∈ Finset.range N, (if x n then 1 else 0 : ℝ) * (1 / 2 : ℝ) ^ (n + 1)

/-
The prefix distance is nonnegative.
-/
theorem prefixDistance_nonneg (x y : Theory) : 0 ≤ prefixDistance x y := by
  exact tsum_nonneg fun n => by split_ifs <;> positivity;

/-
A stream has zero prefix distance from itself.
-/
theorem prefixDistance_self (x : Theory) : prefixDistance x x = 0 := by
  exact tsum_congr ( by aesop ) |> Eq.trans <| tsum_zero

/-
Prefix distance is symmetric.
-/
theorem prefixDistance_comm (x y : Theory) :
    prefixDistance x y = prefixDistance y x := by
  exact tsum_congr fun n => by aesop;

/-
Prefix distance satisfies the triangle inequality.
-/
theorem prefixDistance_triangle (x y z : Theory) :
    prefixDistance x z ≤ prefixDistance x y + prefixDistance y z := by
  -- Apply the triangle inequality to each term in the sums.
  have h_triangle : ∀ n, (if (x n) = (z n) then 0 else 1) * (1 / 2 : ℝ) ^ (n + 1) ≤ (if (x n) = (y n) then 0 else 1) * (1 / 2 : ℝ) ^ (n + 1) + (if (y n) = (z n) then 0 else 1) * (1 / 2 : ℝ) ^ (n + 1) := by
    intro n; split_ifs <;> norm_num;
    grind;
  refine' le_trans ( Summable.tsum_le_tsum h_triangle _ _ ) _;
  · exact Summable.of_nonneg_of_le ( fun n => by positivity ) ( fun n => mul_le_of_le_one_left ( by positivity ) ( by split_ifs <;> norm_num ) ) ( by simpa using summable_nat_add_iff 1 |>.2 <| summable_geometric_two );
  · exact Summable.add ( Summable.of_nonneg_of_le ( fun n => by positivity ) ( fun n => mul_le_of_le_one_left ( by positivity ) ( by aesop ) ) ( by simpa using summable_nat_add_iff 1 |>.2 <| summable_geometric_two ) ) ( Summable.of_nonneg_of_le ( fun n => by positivity ) ( fun n => mul_le_of_le_one_left ( by positivity ) ( by aesop ) ) ( by simpa using summable_nat_add_iff 1 |>.2 <| summable_geometric_two ) );
  · rw [ Summable.tsum_add ] <;> norm_num [ prefixDistance ]; all_goals exact Summable.of_nonneg_of_le ( fun n => by positivity ) ( fun n => by split_ifs <;> ring_nf <;> norm_num ) ( summable_geometric_two )

/-
Distinct streams are separated by positive prefix distance.
-/
theorem prefixDistance_pos_of_ne {x y : Theory} (h : x ≠ y) :
    0 < prefixDistance x y := by
  obtain ⟨ n, hn ⟩ := Function.ne_iff.mp h;
  refine' lt_of_lt_of_le _ ( Summable.le_tsum _ n _ );
  · aesop;
  · exact Summable.of_nonneg_of_le ( fun n => by positivity ) ( fun n => by split_ifs <;> norm_num ) ( summable_geometric_two.comp_injective ( Nat.succ_injective ) );
  · intro j hj; split_ifs <;> positivity;

/-- A half-free language: one bit in each pair is fixed and one is free. -/
def pairedTruth (x : Theory) : Prop := ∀ k, x (2 * k) = true

/-- Finite descriptions of all admissible length-`2n` prefixes.  Only the odd
bits need to be stored, so the type is exactly `Fin n → Bool`. -/
abbrev PairedPrefix (n : ℕ) := Fin n → Bool

/-- All unrestricted binary prefixes of a given length. -/
abbrev BinaryPrefix (n : ℕ) := Fin n → Bool

/-- Extend a finite half-free description to an infinite truth stream.  Its
`n` stored bits occupy the first `n` odd positions; every other bit is true. -/
noncomputable def pairedCompletion {n : ℕ} (p : PairedPrefix n) : Theory :=
  fun i => if h : ∃ k : Fin n, i = 2 * (k : ℕ) + 1 then p h.choose else true

/-
Every finite description really extends to a stream in `pairedTruth`.
-/
theorem pairedCompletion_truth {n : ℕ} (p : PairedPrefix n) :
    pairedTruth (pairedCompletion p) := by
  intro k;
  unfold pairedCompletion;
  grind

/-
Completion recovers each stored bit at its odd position.
-/
theorem pairedCompletion_odd {n : ℕ} (p : PairedPrefix n) (k : Fin n) :
    pairedCompletion p (2 * (k : ℕ) + 1) = p k := by
  unfold pairedCompletion; simp +decide ;
  grind +qlia

/-
Distinct finite descriptions give distinct completed truth streams.
-/
theorem pairedCompletion_injective (n : ℕ) :
    Function.Injective (@pairedCompletion n) := by
  intro p q; by_contra h; exact h (by
  intro h_eq; ext k; have := congr_fun h_eq ( 2 * k.val + 1 ) ; simp_all +decide [ pairedCompletion_odd ] ;)

/-
Exact prefix count for the half-free truth language.
-/
theorem card_pairedPrefix (n : ℕ) : Fintype.card (PairedPrefix n) = 2 ^ n := by
  norm_num

/-
Exact prefix count for the full binary statement space.
-/
theorem card_binaryPrefix (n : ℕ) : Fintype.card (BinaryPrefix n) = 2 ^ n := by
  simp +zetaDelta at *

/-
**Connector theorem (symbolic dynamics ↔ fractal dimension).**
At every even scale, the square of the number of admissible truth prefixes is
exactly the number of all statement prefixes.  Equivalently, its finite-scale
symbolic dimension is exactly `1/2`, hence strictly between zero and one.
-/
theorem pairedTruth_exact_half_dimension (n : ℕ) :
    (Fintype.card (PairedPrefix n)) ^ 2 =
      Fintype.card (BinaryPrefix (2 * n)) := by
  rw [card_pairedPrefix, card_binaryPrefix]
  rw [pow_two, ← pow_add]
  congr
  omega

/-
The dimension value certified by `pairedTruth_exact_half_dimension` is
strictly between zero and one.
-/
theorem half_dimension_strict : (0 : ℚ) < 1 / 2 ∧ (1 / 2 : ℚ) < 1 := by
  norm_num

/-
**Connector theorem (logic ↔ analysis).**  A truth stream determines a real
number, and its first `N` truth values approximate that real from below with a
geometrically shrinking error.  This is the rigorous part of the analogy with
Chaitin-style halting-probability reals; no undecidability assumption is hidden.
-/
theorem truthReal_approximable (x : Theory) (N : ℕ) :
    0 ≤ truthReal x - truthApprox x N ∧
      truthReal x - truthApprox x N ≤ (1 / 2 : ℝ) ^ N := by
  constructor;
  · exact sub_nonneg_of_le <| Summable.sum_le_tsum ( Finset.range N ) ( fun _ _ => by positivity ) <| by exact Summable.of_nonneg_of_le ( fun _ => by positivity ) ( fun n => mul_le_of_le_one_left ( by positivity ) <| by aesop ) <| by simpa using summable_nat_add_iff 1 |>.2 <| summable_geometric_two;
  · -- The tail of the series from N to infinity is bounded by the geometric series with ratio 1/2.
    have h_tail_bound : ∑' n : ℕ, (if x (N + n) then 1 else 0 : ℝ) * (1 / 2 : ℝ) ^ (N + n + 1) ≤ ∑' n : ℕ, (1 / 2 : ℝ) ^ (N + n + 1) := by
      refine' Summable.tsum_le_tsum _ _ _;
      · intro i; split_ifs <;> norm_num;
      · exact Summable.of_nonneg_of_le ( fun n => by positivity ) ( fun n => mul_le_of_le_one_left ( by positivity ) ( by aesop ) ) ( by simpa using summable_geometric_two.comp_injective ( by aesop_cat ) );
      · exact Summable.comp_injective ( summable_geometric_two ) fun a b h => by simpa using h;
    convert h_tail_bound using 1;
    · unfold truthReal truthApprox;
      rw [ ← Summable.sum_add_tsum_nat_add N ];
      · grind;
      · exact Summable.of_nonneg_of_le ( fun n => by positivity ) ( fun n => mul_le_of_le_one_left ( by positivity ) ( by aesop ) ) ( by simpa using summable_nat_add_iff 1 |>.2 <| summable_geometric_two );
    · ring_nf;
      rw [ tsum_mul_right, tsum_mul_left, tsum_geometric_of_lt_one ] <;> ring <;> norm_num

/-
Prefix closeness controls binary-real closeness: agreement on the first
`N` statements forces the represented reals to lie within `2⁻ᴺ`.
-/
theorem truthReal_close_of_prefix_eq (x y : Theory) (N : ℕ)
    (h : ∀ n < N, x n = y n) :
    |truthReal x - truthReal y| ≤ (1 / 2 : ℝ) ^ N := by
  exact abs_sub_le_iff.mpr ⟨ by linarith [ show truthApprox x N = truthApprox y N from Finset.sum_congr rfl fun i hi => by aesop, truthReal_approximable x N, truthReal_approximable y N ], by linarith [ show truthApprox x N = truthApprox y N from Finset.sum_congr rfl fun i hi => by aesop, truthReal_approximable x N, truthReal_approximable y N ] ⟩

/-- **Connector theorem (truth ↔ computability).**  Truth of halting statements
for any fixed input is not a computable predicate on program codes.  This is
the exact undecidability result underlying the Chaitin-Ω analogy; it does not
claim that the elementary half-free language above is itself uncomputable. -/
theorem haltingTruth_uncomputable (input : ℕ) :
    ¬ComputablePred (fun c : Nat.Partrec.Code => (c.eval input).Dom) := by
  exact ComputablePred.halting_problem input

/-- Nevertheless, halting truth is recursively enumerable: positive facts can
be discovered by running programs.  Thus it is approximable from below in the
standard computability-theoretic sense, despite being undecidable. -/
theorem haltingTruth_approximable (input : ℕ) :
    REPred (fun c : Nat.Partrec.Code => (c.eval input).Dom) := by
  exact ComputablePred.halting_problem_re input

end TruthFractal