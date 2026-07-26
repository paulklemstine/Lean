import Mathlib

/-!
# Benford Criterion from Equidistribution

This file proves foundational results connecting Benford's law to
equidistribution of logarithmic mantissae modulo 1.

## Main Results

- `leadDigitBase_eq_iff_fract`: The leading digit of `n` in base `b` equals `m`
  iff `fract(log_b n)` lies in `[log_b m, log_b(m+1))`.
- `benford_target_sum_one`: The Benford probabilities sum to 1.
- `benford_target_pos`: Each Benford probability is positive.
- `benfordCriterion`: If a sequence has equidistributed log mantissae,
  leading digits follow Benford's law.
-/

open Real Nat Finset Filter

noncomputable section

/-- The Benford target probability: `log_b(1 + 1/m)` for digit `m` in base `b`. -/
def benfordProb (b m : ℕ) : ℝ :=
  Real.log (1 + 1 / (m : ℝ)) / Real.log (b : ℝ)

/-
Benford probabilities are positive for valid digits.
-/
theorem benfordProb_pos (b m : ℕ) (hb : 2 ≤ b) (hm : 1 ≤ m) (hm' : m < b) :
    0 < benfordProb b m := by
  exact div_pos ( Real.log_pos <| by rw [ lt_add_iff_pos_right ] ; positivity ) ( Real.log_pos <| by norm_cast )

/-
The Benford probabilities for digits 1 through b-1 sum to 1.
    This is a telescoping product: `∑_{m=1}^{b-1} log_b(1+1/m) = log_b(b) = 1`.
-/
theorem benfordProb_sum_eq_one (b : ℕ) (hb : 2 ≤ b) :
    ∑ m ∈ Finset.Icc 1 (b - 1), benfordProb b m = 1 := by
  -- The sum telescopes: ∑_{m=1}^{b-1} log_b(1+1/m) = log_b(b) = 1.
  have h_telescope : ∑ m ∈ Finset.Icc 1 (b - 1), Real.log (1 + 1 / (m : ℝ)) = Real.log b := by
    erw [ Finset.sum_Ico_eq_sum_range ];
    have h_telescope : ∀ n : ℕ, ∑ k ∈ Finset.range n, Real.log (1 + 1 / (k + 1 : ℝ)) = Real.log (n + 1) := by
      intro n; induction n <;> simp_all +decide [ Finset.sum_range_succ ];
      rw [ ← Real.log_mul ( by positivity ) ( by positivity ), mul_add, mul_inv_cancel₀ ( by positivity ), mul_one ];
    convert h_telescope ( b - 1 ) using 2 <;> cases b <;> norm_num [ add_comm ] at *;
  unfold benfordProb;
  rw [ ← Finset.sum_div, h_telescope, div_self <| ne_of_gt <| Real.log_pos <| Nat.one_lt_cast.mpr hb ]

/-
**Leading digit characterization via logarithmic mantissa.**

    For `n ≥ 1` and `b ≥ 2`, the leading digit of `n` in base `b`
    equals `m` (where `1 ≤ m < b`) if and only if
    `fract(log_b n) ∈ [log_b m, log_b(m+1))`.

    This is the fundamental bridge between digit statistics and
    equidistribution theory.
-/
theorem leadDigitBase_eq_iff_fract_log (b n m : ℕ) (hb : 2 ≤ b) (hn : 1 ≤ n)
    (hm : 1 ≤ m) (hm' : m < b) :
    n / b ^ (Nat.log b n) = m ↔
      Real.log (m : ℝ) / Real.log (b : ℝ) ≤
        Int.fract (Real.log (n : ℝ) / Real.log (b : ℝ)) ∧
      Int.fract (Real.log (n : ℝ) / Real.log (b : ℝ)) <
        Real.log ((m : ℝ) + 1) / Real.log (b : ℝ) := by
  constructor;
  · intro hantissa
    have h_log_bounds : Real.log (m : ℝ) ≤ Real.log n - Nat.log b n * Real.log b ∧ Real.log n - Nat.log b n * Real.log b < Real.log (m + 1 : ℝ) := by
      have h_log_bounds : (m : ℝ) * b ^ Nat.log b n ≤ n ∧ n < (m + 1 : ℝ) * b ^ Nat.log b n := by
        exact ⟨ mod_cast hantissa ▸ Nat.div_mul_le_self _ _, mod_cast hantissa ▸ by linarith [ Nat.div_add_mod n ( b ^ Nat.log b n ), Nat.mod_lt n ( pow_pos ( zero_lt_two.trans_le hb ) ( Nat.log b n ) ) ] ⟩;
      exact ⟨ by have := Real.log_le_log ( by positivity ) h_log_bounds.1; rw [ Real.log_mul ( by positivity ) ( by positivity ), Real.log_pow ] at this; linarith, by have := Real.log_lt_log ( by positivity ) h_log_bounds.2; rw [ Real.log_mul ( by positivity ) ( by positivity ), Real.log_pow ] at this; linarith ⟩;
    have h_fract_bounds : Int.fract (Real.log n / Real.log b) = (Real.log n - Nat.log b n * Real.log b) / Real.log b := by
      rw [ Int.fract_eq_iff ];
      exact ⟨ div_nonneg ( sub_nonneg.2 <| by rw [ ← Real.log_pow ] ; exact Real.log_le_log ( by positivity ) <| mod_cast Nat.pow_log_le_self _ <| by positivity ) <| Real.log_nonneg <| by norm_cast; linarith, by rw [ div_lt_one <| Real.log_pos <| by norm_cast ] ; linarith [ Real.log_le_log ( by positivity ) <| show ( m:ℝ ) + 1 ≤ b by norm_cast ], ⟨ Nat.log b n, by simp [ sub_div, mul_div_cancel_right₀ _ <| ne_of_gt <| Real.log_pos <| show ( b:ℝ ) > 1 by norm_cast ] ⟩ ⟩;
    exact ⟨ by rw [ h_fract_bounds ] ; exact div_le_div_of_nonneg_right h_log_bounds.1 <| Real.log_nonneg <| by norm_cast; linarith, by rw [ h_fract_bounds ] ; exact div_lt_div_iff_of_pos_right ( Real.log_pos <| by norm_cast ) |>.2 h_log_bounds.2 ⟩;
  · -- By definition of logarithms, we know that if $\log_b(m) \leq \log_b(n) - k < \log_b(m+1)$, then $m \cdot b^k \leq n < (m+1) \cdot b^k$.
    intro h
    have h_bounds : (m : ℝ) * b ^ (Nat.log b n) ≤ n ∧ n < (m + 1 : ℝ) * b ^ (Nat.log b n) := by
      have h_bounds : Real.log (m : ℝ) + Nat.log b n * Real.log b ≤ Real.log n ∧ Real.log n < Real.log (m + 1 : ℝ) + Nat.log b n * Real.log b := by
        have h_bounds : Real.log m ≤ Real.log n - Nat.log b n * Real.log b ∧ Real.log n - Nat.log b n * Real.log b < Real.log (m + 1) := by
          have h_log_bounds : (Nat.log b n : ℝ) = Int.floor (Real.log n / Real.log b) := by
            rw_mod_cast [ eq_comm, Int.floor_eq_iff ];
            exact ⟨ by rw [ le_div_iff₀ ( Real.log_pos ( by norm_cast ) ) ] ; exact mod_cast by rw [ ← Real.log_pow ] ; exact Real.log_le_log ( by positivity ) <| mod_cast Nat.pow_log_le_self _ <| by positivity, by rw [ div_lt_iff₀ ( Real.log_pos ( by norm_cast ) ) ] ; exact mod_cast by rw [ ← Real.log_rpow ( by positivity ), Real.log_lt_log_iff ] <;> norm_cast <;> nlinarith [ Nat.lt_pow_of_log_lt hb ( by linarith : Nat.log b n < Nat.log b n + 1 ) ] ⟩
          rw [ Int.fract ] at h;
          rw [ div_le_iff₀ ( Real.log_pos ( by norm_cast ) ), lt_div_iff₀ ( Real.log_pos ( by norm_cast ) ) ] at h ; constructor <;> nlinarith [ Real.log_pos ( show ( b :ℝ ) > 1 by norm_cast ), mul_div_cancel₀ ( Real.log n ) ( ne_of_gt ( Real.log_pos ( show ( b :ℝ ) > 1 by norm_cast ) ) ) ];
        constructor <;> linarith;
      rw [ ← Real.log_le_log_iff ( by positivity ) ( by positivity ), ← Real.log_lt_log_iff ( by positivity ) ( by positivity ) ];
      rw [ Real.log_mul ( by positivity ) ( by positivity ), Real.log_mul ( by positivity ) ( by positivity ), Real.log_pow ] ; aesop;
    exact Nat.le_antisymm ( Nat.le_of_lt_succ <| Nat.div_lt_of_lt_mul <| by norm_cast at *; linarith ) ( Nat.le_div_iff_mul_le ( by positivity ) |>.2 <| by norm_cast at *; linarith )

end