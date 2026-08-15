import Computation.CyclicTypeChannelValues

/-!
# Laws of the cyclic splitting-type channel

Consequences of the exact values in `Catalog.Computation.CyclicTypeChannelValues`:

* the binary-fork cap `1` bit is *exceeded* by every even cyclic order computed here and
  *not reached* by any odd one;
* the exact CRT-additivity law `I(mn) = I(m) + I(n)` for coprime `m, n` (instances);
* the doubling law `I(2m) = I(m) + 1` for odd `m` (instances);
* the 2-adic growth law `I(2^k) = (4/3)(1 - 4^{-k})` for `1 ≤ k ≤ 4`;
* strict lossiness of the root-count readout, `H(nr) < H(T)`.
-/

namespace CyclicType

/-! ## Numeric bounds on the logarithms that occur -/

lemma lb3_lower : (19 : ℝ) / 12 < Real.logb 2 3 := by
  have h1 := Real.logb_lt_logb (b := 2) (by norm_num) (x := (2:ℝ)^(19:ℕ)) (y := (3:ℝ)^(12:ℕ))
    (by positivity) (by norm_num)
  rw [Real.logb_pow, Real.logb_pow, lb_2] at h1
  norm_num at h1
  linarith

lemma lb3_upper : Real.logb 2 3 < (27 : ℝ) / 17 := by
  have h1 := Real.logb_lt_logb (b := 2) (by norm_num) (x := (3:ℝ)^(17:ℕ)) (y := (2:ℝ)^(27:ℕ))
    (by positivity) (by norm_num)
  rw [Real.logb_pow, Real.logb_pow, lb_2] at h1
  norm_num at h1
  linarith

lemma lb5_lower : (23 : ℝ) / 10 < Real.logb 2 5 := by
  have h1 := Real.logb_lt_logb (b := 2) (by norm_num) (x := (2:ℝ)^(23:ℕ)) (y := (5:ℝ)^(10:ℕ))
    (by positivity) (by norm_num)
  rw [Real.logb_pow, Real.logb_pow, lb_2] at h1
  norm_num at h1
  linarith

lemma lb5_upper : Real.logb 2 5 < (7 : ℝ) / 3 := by
  have h1 := Real.logb_lt_logb (b := 2) (by norm_num) (x := (5:ℝ)^(3:ℕ)) (y := (2:ℝ)^(7:ℕ))
    (by positivity) (by norm_num)
  rw [Real.logb_pow, Real.logb_pow, lb_2] at h1
  norm_num at h1
  linarith

lemma lb7_lower : (14 : ℝ) / 5 < Real.logb 2 7 := by
  have h1 := Real.logb_lt_logb (b := 2) (by norm_num) (x := (2:ℝ)^(14:ℕ)) (y := (7:ℝ)^(5:ℕ))
    (by positivity) (by norm_num)
  rw [Real.logb_pow, Real.logb_pow, lb_2] at h1
  norm_num at h1
  linarith

lemma lb7_upper : Real.logb 2 7 < 3 := by
  have h1 := Real.logb_lt_logb (b := 2) (by norm_num) (x := (7:ℝ)) (y := (2:ℝ)^(3:ℕ))
    (by positivity) (by norm_num)
  rw [Real.logb_pow, lb_2] at h1
  norm_num at h1
  linarith

lemma lb11_upper : Real.logb 2 11 < (7 : ℝ) / 2 := by
  have h1 := Real.logb_lt_logb (b := 2) (by norm_num) (x := (11:ℝ)^(2:ℕ)) (y := (2:ℝ)^(7:ℕ))
    (by positivity) (by norm_num)
  rw [Real.logb_pow, Real.logb_pow, lb_2] at h1
  norm_num at h1
  linarith

lemma lb13_upper : Real.logb 2 13 < (15 : ℝ) / 4 := by
  have h1 := Real.logb_lt_logb (b := 2) (by norm_num) (x := (13:ℝ)^(4:ℕ)) (y := (2:ℝ)^(15:ℕ))
    (by positivity) (by norm_num)
  rw [Real.logb_pow, Real.logb_pow, lb_2] at h1
  norm_num at h1
  linarith

/-! ## Breaking the one-bit binary-fork cap

The binary symmetric semiprime fork is capped at `1.0` bit.  The cyclic splitting type is
multi-state, and its type-pair channel strictly exceeds that cap for every even cyclic order
computed here, while every odd cyclic order stays strictly below it.
-/

/-- The quadratic (binary) fork sits exactly at the cap: `I_pair(C₂) = 1`. -/
theorem Ipair_two_at_cap : Ipair 2 = 1 := Ipair_two

theorem one_lt_Ipair_four : 1 < Ipair 4 := by rw [Ipair_four]; norm_num

theorem one_lt_Ipair_six : 1 < Ipair 6 := by
  rw [Ipair_six]; have := lb3_lower; linarith

theorem one_lt_Ipair_eight : 1 < Ipair 8 := by rw [Ipair_eight]; norm_num

theorem one_lt_Ipair_ten : 1 < Ipair 10 := by
  rw [Ipair_ten]; have := lb3_lower; have := lb5_lower; linarith

theorem one_lt_Ipair_twelve : 1 < Ipair 12 := by
  rw [Ipair_twelve]; have := lb3_lower; linarith

theorem one_lt_Ipair_fourteen : 1 < Ipair 14 := by
  rw [Ipair_fourteen]
  have h3 := lb3_upper; have h5 := lb5_lower; have h7 := lb7_lower
  linarith

theorem one_lt_Ipair_sixteen : 1 < Ipair 16 := by rw [Ipair_sixteen]; norm_num

/-- Odd cyclic orders stay strictly below the binary-fork cap. -/
theorem Ipair_three_lt_one : Ipair 3 < 1 := by
  rw [Ipair_three]; have := lb3_upper; linarith

theorem Ipair_five_lt_one : Ipair 5 < 1 := by
  rw [Ipair_five]; have := lb3_upper; have := lb5_upper; linarith

theorem Ipair_seven_lt_one : Ipair 7 < 1 := by
  rw [Ipair_seven]
  have h3 := lb3_lower; have h5 := lb5_upper; have h7 := lb7_upper
  linarith

theorem Ipair_eleven_lt_one : Ipair 11 < 1 := by
  rw [Ipair_eleven]
  have h3 := lb3_upper; have h5 := lb5_lower; have h11 := lb11_upper
  linarith

theorem Ipair_thirteen_lt_one : Ipair 13 < 1 := by
  rw [Ipair_thirteen]
  have h3 := lb3_lower; have h11 := lb11_upper; have h13 := lb13_upper
  linarith

theorem Ipair_fifteen_lt_one : Ipair 15 < 1 := by
  rw [Ipair_fifteen]; have := lb3_upper; have := lb5_upper; linarith

/-! ## The exact CRT-additivity law

For coprime factorisations the type-pair channel splits additively; this is verified here
as an exact identity between independently computed closed forms.
-/

/-- `I(12) = I(4) + I(3)`. -/
theorem Ipair_crt_twelve : Ipair 12 = Ipair 4 + Ipair 3 := by
  rw [Ipair_twelve, Ipair_four, Ipair_three]; ring

/-- `I(10) = I(2) + I(5)`. -/
theorem Ipair_crt_ten : Ipair 10 = Ipair 2 + Ipair 5 := by
  rw [Ipair_ten, Ipair_two, Ipair_five]; ring

/-- `I(15) = I(3) + I(5)`. -/
theorem Ipair_crt_fifteen : Ipair 15 = Ipair 3 + Ipair 5 := by
  rw [Ipair_fifteen, Ipair_three, Ipair_five]; ring

/-- `I(14) = I(2) + I(7)`. -/
theorem Ipair_crt_fourteen : Ipair 14 = Ipair 2 + Ipair 7 := by
  rw [Ipair_fourteen, Ipair_two, Ipair_seven]; ring

/-! ### The doubling law: doubling an odd order adds exactly one bit -/

theorem Ipair_double_three : Ipair 6 = Ipair 3 + 1 := by
  rw [Ipair_six, Ipair_three]; ring

theorem Ipair_double_five : Ipair 10 = Ipair 5 + 1 := by
  rw [Ipair_ten, Ipair_five]; ring

theorem Ipair_double_seven : Ipair 14 = Ipair 7 + 1 := by
  rw [Ipair_fourteen, Ipair_seven]; ring

/-! ### The 2-adic growth law `I(2^k) = (4/3)(1 - 4^{-k})` -/

/-- For `1 ≤ k ≤ 4` the type-pair channel of the cyclic 2-group obeys the exact law
`I_pair(2^k) = (4/3)(1 - 4^{-k})`, an increasing sequence with supremum `4/3`. -/
theorem Ipair_two_pow_law {k : ℕ} (h1 : 1 ≤ k) (h4 : k ≤ 4) :
    Ipair (2 ^ k) = 4 / 3 * (1 - (4 : ℝ) ^ (-(k : ℤ))) := by
  interval_cases k
  · rw [show (2:ℕ)^1 = 2 by norm_num, Ipair_two]; norm_num
  · rw [show (2:ℕ)^2 = 4 by norm_num, Ipair_four]; norm_num
  · rw [show (2:ℕ)^3 = 8 by norm_num, Ipair_eight]; norm_num
  · rw [show (2:ℕ)^4 = 16 by norm_num, Ipair_sixteen]; norm_num

/-- The 2-adic tower is strictly increasing and stays below its limit `4/3`. -/
theorem Ipair_two_pow_strict_mono :
    Ipair 2 < Ipair 4 ∧ Ipair 4 < Ipair 8 ∧ Ipair 8 < Ipair 16 ∧ Ipair 16 < 4 / 3 := by
  rw [Ipair_two, Ipair_four, Ipair_eight, Ipair_sixteen]
  norm_num

/-! ## Root-count lossiness

The number-of-roots readout `nr` only distinguishes "splits completely" from "does not",
so it is a *binary* coarsening of the multi-state type. Its entropy is strictly smaller.
-/

theorem Hnr_lt_HT_four : Hnr 4 < HT 4 := by
  rw [Hnr_four, HT_four]; have := lb3_lower; linarith

theorem Hnr_lt_HT_six : Hnr 6 < HT 6 := by
  rw [Hnr_six, HT_six]; have := lb5_lower; linarith

/-- The splits-completely face of `C₄` is pinned at the binary entropy
`H(1/4) = 2 - (3/4) log₂ 3`. -/
theorem quartic_pinning : Hnr 4 = 2 - 3 / 4 * Real.logb 2 3 := by
  rw [Hnr_four]; ring

/-! ### Further instances of the cap, additivity and doubling laws -/

theorem Ipair_nine_lt_one : Ipair 9 < 1 := by
  rw [Ipair_nine]; have := lb3_upper; linarith

theorem one_lt_Ipair_eighteen : 1 < Ipair 18 := by
  rw [Ipair_eighteen]; have := lb3_lower; linarith

theorem one_lt_Ipair_twenty : 1 < Ipair 20 := by
  rw [Ipair_twenty]; have := lb3_lower; have := lb5_lower; linarith

/-- `I(18) = I(9) + 1`: doubling the odd order `9` adds exactly one bit. -/
theorem Ipair_double_nine : Ipair 18 = Ipair 9 + 1 := by
  rw [Ipair_eighteen, Ipair_nine]; ring

/-- `I(20) = I(4) + I(5)`: CRT additivity across the coprime factorisation `20 = 4 · 5`. -/
theorem Ipair_crt_twenty : Ipair 20 = Ipair 4 + Ipair 5 := by
  rw [Ipair_twenty, Ipair_four, Ipair_five]; ring

/-- `I(18) = I(2) + I(9)`: CRT additivity across `18 = 2 · 9`. -/
theorem Ipair_crt_eighteen : Ipair 18 = Ipair 2 + Ipair 9 := by
  rw [Ipair_eighteen, Ipair_two, Ipair_nine]; ring

end CyclicType