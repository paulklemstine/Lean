/-
# Exact prefactors for uniform coset guesswork

This development goes beyond logarithmic exponents.  For a uniform candidate list
of cardinality `b^k`, it computes the first two guesswork moments exactly and proves
their normalized limits.  Thus the exponent statement is refined by the leading
constants `1/2` and `1/3`.  It also derives the limiting normalized variance `1/12`
and squared coefficient of variation `1/3`.
-/
import Mathlib

open Real Filter Topology
open scoped BigOperators

namespace CosetGuessworkPrefactors

/-- The raw real power sum `1^ρ + ... + N^ρ`. -/
noncomputable def powSum (ρ : ℝ) (N : ℕ) : ℝ :=
  ∑ i ∈ Finset.range N, ((i : ℝ) + 1) ^ ρ

/-- Guesswork moment for a uniform list of `b^k` candidates. -/
noncomputable def uniformMoment (b k : ℕ) (ρ : ℝ) : ℝ :=
  (b : ℝ) ^ (-(k : ℝ)) * powSum ρ (b ^ k)

/-
Exact first moment: the average of ranks `1,...,b^k` is `(b^k+1)/2`.
-/
theorem uniformMoment_one_exact (b k : ℕ) (hb : 1 ≤ b) :
    uniformMoment b k 1 = ((b : ℝ) ^ k + 1) / 2 := by
  -- Rewrite real rpow at exponent 1 as identity.
  simp [uniformMoment, powSum];
  rw [ inv_mul_eq_div, div_eq_div_iff ] <;> norm_cast <;> norm_num;
  · exact Nat.recOn ( b ^ k ) ( by norm_num ) fun n ih => by rw [ Finset.sum_range_succ ] ; linarith;
  · grind +qlia

/-
Exact second moment of the uniform guessing rank.
-/
theorem uniformMoment_two_exact (b k : ℕ) (hb : 1 ≤ b) :
    uniformMoment b k 2 =
      (((b : ℝ) ^ k + 1) * (2 * (b : ℝ) ^ k + 1)) / 6 := by
  unfold uniformMoment powSum;
  rw [ Real.rpow_neg ( by positivity ) ];
  rw [ inv_mul_eq_div, div_eq_iff ];
  · exact mod_cast Nat.recOn ( b ^ k ) ( by norm_num ) fun n ih ↦ by norm_num [ Finset.sum_range_succ ] at * ; linarith;
  · positivity

/-
The first moment has not only exponent one in list size, but exact leading
constant `1/2`.
-/
theorem normalized_first_tendsto (b : ℕ) (hb : 2 ≤ b) (kn : ℕ → ℕ)
    (htop : Tendsto kn atTop atTop) :
    Tendsto (fun n => uniformMoment b (kn n) 1 / (b : ℝ) ^ (kn n))
      atTop (𝓝 (1 / 2 : ℝ)) := by
  -- Rewrite uniformMoment_one_exact pointwise.
  have h_pointwise : ∀ n, uniformMoment b (kn n) 1 / (b : ℝ) ^ (kn n) = (1 / 2) + (1 / 2) * (b : ℝ) ^ (-(kn n) : ℝ) := by
    intro n
    rw [uniformMoment_one_exact]
    ring;
    · norm_num [ Real.rpow_neg, show b ≠ 0 by positivity ];
    · grind;
  norm_num [ Real.rpow_neg, h_pointwise ];
  exact le_trans ( tendsto_const_nhds.add ( tendsto_const_nhds.mul ( tendsto_inv_atTop_zero.comp ( tendsto_pow_atTop_atTop_of_one_lt ( by norm_cast ) |> Filter.Tendsto.comp <| htop ) ) ) ) ( by norm_num )

/-
The second moment has exact leading constant `1/3`.
-/
theorem normalized_second_tendsto (b : ℕ) (hb : 2 ≤ b) (kn : ℕ → ℕ)
    (htop : Tendsto kn atTop atTop) :
    Tendsto (fun n => uniformMoment b (kn n) 2 / ((b : ℝ) ^ (kn n)) ^ 2)
      atTop (𝓝 (1 / 3 : ℝ)) := by
  -- Rewrite using uniformMoment_two_exact.
  have h_rewrite : ∀ n, uniformMoment b (kn n) 2 / ((b : ℝ) ^ (kn n)) ^ 2 = (1 / 3 : ℝ) + (1 / 2 : ℝ) * (1 / (b : ℝ) ^ (kn n)) + (1 / 6 : ℝ) * (1 / (b : ℝ) ^ (2 * (kn n))) := by
    intro n
    have h_rewrite : uniformMoment b (kn n) 2 = ((b : ℝ) ^ (kn n) + 1) * (2 * (b : ℝ) ^ (kn n) + 1) / 6 := by
      convert uniformMoment_two_exact b ( kn n ) ( by linarith ) using 1;
    -- Substitute the rewritten form of the second moment into the expression.
    rw [h_rewrite]
    field_simp
    ring;
  norm_num [ h_rewrite ];
  exact le_trans ( Filter.Tendsto.add ( tendsto_const_nhds.add ( tendsto_const_nhds.mul ( tendsto_inv_atTop_zero.comp ( tendsto_pow_atTop_atTop_of_one_lt ( by norm_cast ) |> Filter.Tendsto.comp <| htop ) ) ) ) ( tendsto_const_nhds.mul ( tendsto_inv_atTop_zero.comp ( tendsto_pow_atTop_atTop_of_one_lt ( by norm_cast ) |> Filter.Tendsto.comp <| Filter.tendsto_atTop_mono ( fun n => by linarith ) htop ) ) ) ) ( by norm_num )

/-
Exact variance of the uniform guessing rank, normalized by the square of the
list size.
-/
theorem normalized_variance_exact (b k : ℕ) (hb : 1 ≤ b) :
    (uniformMoment b k 2 - (uniformMoment b k 1) ^ 2) / ((b : ℝ) ^ k) ^ 2 =
      (1 - ((b : ℝ) ^ k)⁻¹ ^ 2) / 12 := by
  rw [ uniformMoment_two_exact, uniformMoment_one_exact ];
  · -- Combine and simplify the fractions in the numerator.
    field_simp
    ring;
  · linarith;
  · linarith

/-
Consequently, normalized variance tends to `1/12`.
-/
theorem normalized_variance_tendsto (b : ℕ) (hb : 2 ≤ b) (kn : ℕ → ℕ)
    (htop : Tendsto kn atTop atTop) :
    Tendsto
      (fun n => (uniformMoment b (kn n) 2 - (uniformMoment b (kn n) 1) ^ 2) /
        ((b : ℝ) ^ (kn n)) ^ 2)
      atTop (𝓝 (1 / 12 : ℝ)) := by
  rw [ Filter.tendsto_congr' ];
  any_goals filter_upwards [ htop.eventually_gt_atTop 0 ] with n hn; rw [ normalized_variance_exact ];
  · exact le_trans ( Filter.Tendsto.div_const ( tendsto_const_nhds.sub ( Filter.Tendsto.pow ( tendsto_inv_atTop_zero.comp ( tendsto_pow_atTop_atTop_of_one_lt ( by norm_cast ) |> Filter.Tendsto.comp <| htop ) ) _ ) ) _ ) ( by norm_num );
  · linarith

/-
The squared coefficient of variation tends to `1/3`; fluctuations therefore
remain of the same order as the mean even for exponentially large cosets.
-/
theorem squared_coefficient_variation_tendsto
    (b : ℕ) (hb : 2 ≤ b) (kn : ℕ → ℕ) (htop : Tendsto kn atTop atTop) :
    Tendsto
      (fun n => (uniformMoment b (kn n) 2 - (uniformMoment b (kn n) 1) ^ 2) /
        (uniformMoment b (kn n) 1) ^ 2)
      atTop (𝓝 (1 / 3 : ℝ)) := by
  convert Tendsto.div ( normalized_variance_tendsto b hb kn htop ) ( Tendsto.pow ( normalized_first_tendsto b hb kn htop ) 2 ) _ using 2 <;> norm_num;
  field_simp

end CosetGuessworkPrefactors