import Tropical.SmoothSelfHintSymmetricClassification

/-!
# The exact size of the symmetric leak, for every modulus

`SmoothSelfHintSymmetricClassification` shows *that* the symmetric divisibility statistic
leaks (`miF_symJointG_pos_singleton`) and *exactly when* it does not.  This file computes
*how much* it leaks, in closed form, for the arithmetically relevant target `A = {1}`
(the event "`l ∣ x - 1`") in an arbitrary finite group.

* `SmoothSelfHint.symMI` — the closed form, a function of the group order `d` alone.
* `SmoothSelfHint.miF_symJointG_singleton_eq_symMI` — **the closed form is correct**:
  for every finite group with more than one element,
  `I(product ; "one factor is 1") = symMI |G|`.
* `SmoothSelfHint.mi_sym_units` — the arithmetic instance: for every odd prime `l`
  the leak of the symmetric event about `N mod l` is exactly `symMI (l - 1)`.
* `SmoothSelfHint.symMI_two` — consistency with the independently computed `l = 3`
  value `3/2 - (3/4) log₂ 3` of `SmoothSelfHintInformation`.
* `SmoothSelfHint.mi_sym_five_bounds` — the certified value at `l = 5`:
  `0.0355 < I < 0.036`, matching the measured `0.036` bits.

The closed form makes the decay of the leak visible: the `l = 3` value `0.313` is an
outlier caused by `d = 2`, and the leak is `O(1/d²)` afterwards.
-/

open Finset

namespace SmoothSelfHint

/-- Closed form for the symmetric mutual information as a function of the group order
`d = |G|`: the information that the product `a·b` carries about the event
"`a = 1` or `b = 1`". -/
noncomputable def symMI (d : ℝ) : ℝ :=
  (Real.logb 2 (d / (2 * d - 1))
      + (d - 1) * Real.logb 2 (d / (d - 1))
      + 2 * (d - 1) * Real.logb 2 (2 * d / (2 * d - 1))
      + (d - 1) * (d - 2) * Real.logb 2 (d * (d - 2) / (d - 1) ^ 2)) / d ^ 2

section Group

variable {G : Type*} [Group G] [Fintype G] [DecidableEq G]

private theorem symFiber_one_card_real (n : G) :
    ((symFiber ({1} : Finset G) n).card : ℝ) = if n = 1 then 1 else 2 := by
  rw [sym_fiber_card_one]
  by_cases h : n = 1 <;> simp [h]

private theorem symJointG_one_true (n : G) :
    symJointG ({1} : Finset G) n true
      = (if n = 1 then (1 : ℝ) else 2) / (Fintype.card G : ℝ) ^ 2 := by
  unfold symJointG
  simp only [Bool.cond_true, symFiber_one_card_real]

private theorem symJointG_one_false (n : G) :
    symJointG ({1} : Finset G) n false
      = ((Fintype.card G : ℝ) - if n = 1 then (1 : ℝ) else 2) / (Fintype.card G : ℝ) ^ 2 := by
  unfold symJointG
  simp only [Bool.cond_false, symFiber_one_card_real]

/-- The column mass of the symmetric event: `P(a = 1 ∨ b = 1) = (2d-1)/d²`. -/
theorem symJointG_one_col_true :
    ∑ n : G, symJointG ({1} : Finset G) n true
      = (2 * (Fintype.card G : ℝ) - 1) / (Fintype.card G : ℝ) ^ 2 := by
  have hsum : ∑ n : G, ((symFiber ({1} : Finset G) n).card : ℝ)
      = 2 * (Fintype.card G : ℝ) - 1 := by
    have hpt : ∀ n : G, ((symFiber ({1} : Finset G) n).card : ℝ)
        = 2 - (if n = 1 then (1 : ℝ) else 0) := by
      intro n
      rw [symFiber_one_card_real]
      by_cases h : n = 1 <;> norm_num [h]
    rw [Finset.sum_congr rfl (fun n _ => hpt n), Finset.sum_sub_distrib]
    simp [Finset.card_univ, mul_comm]
  rw [symJointG_col_true, hsum]

/-- The complementary column mass: `P(a ≠ 1 ∧ b ≠ 1) = (d-1)²/d²`. -/
theorem symJointG_one_col_false :
    ∑ n : G, symJointG ({1} : Finset G) n false
      = ((Fintype.card G : ℝ) - 1) ^ 2 / (Fintype.card G : ℝ) ^ 2 := by
  have hg : (0 : ℝ) < (Fintype.card G : ℝ) := card_pos_real
  have htot : ∑ n : G, ∑ e : Bool, symJointG ({1} : Finset G) n e = 1 :=
    symJointG_sum_one _
  rw [Finset.sum_comm, Fintype.sum_bool, symJointG_one_col_true] at htot
  have := htot
  field_simp at this ⊢
  linarith [this]

/-- **The closed form.**  For any finite group with more than one element the symmetric
statistic carries exactly `symMI |G|` bits about the product. -/
theorem miF_symJointG_singleton_eq_symMI (h : 1 < Fintype.card G) :
    miF (symJointG ({1} : Finset G)) = symMI (Fintype.card G) := by
  set D : ℝ := (Fintype.card G : ℝ) with hDdef
  have hD2 : (2 : ℝ) ≤ D := by
    have h2 : (2 : ℕ) ≤ Fintype.card G := h
    rw [hDdef]
    exact_mod_cast h2
  have hD0 : D ≠ 0 := by linarith
  have hDm1 : D - 1 ≠ 0 := by intro hc; linarith [hc]
  have h2Dm1 : 2 * D - 1 ≠ 0 := by intro hc; linarith [hc]
  have hrow' : ∀ n : G, symJointG ({1} : Finset G) n true
      + symJointG ({1} : Finset G) n false = 1 / D := by
    intro n
    have := symJointG_row ({1} : Finset G) n
    rwa [Fintype.sum_bool] at this
  have hcT : ∑ n : G, symJointG ({1} : Finset G) n true = (2 * D - 1) / D ^ 2 :=
    symJointG_one_col_true
  have hcF : ∑ n : G, symJointG ({1} : Finset G) n false = (D - 1) ^ 2 / D ^ 2 :=
    symJointG_one_col_false
  -- the four logarithms occurring in the answer
  set c1 : ℝ := Real.logb 2 (D / (2 * D - 1)) with hc1
  set c2 : ℝ := Real.logb 2 (D / (D - 1)) with hc2
  set c3 : ℝ := Real.logb 2 (2 * D / (2 * D - 1)) with hc3
  set c4 : ℝ := Real.logb 2 (D * (D - 2) / (D - 1) ^ 2) with hc4
  have hterm : ∀ n : G,
      symJointG ({1} : Finset G) n true
          * Real.logb 2 (symJointG ({1} : Finset G) n true / (1 / D * ((2 * D - 1) / D ^ 2)))
        + symJointG ({1} : Finset G) n false
          * Real.logb 2 (symJointG ({1} : Finset G) n false / (1 / D * ((D - 1) ^ 2 / D ^ 2)))
        = if n = 1 then (1 / D ^ 2) * c1 + ((D - 1) / D ^ 2) * c2
          else (2 / D ^ 2) * c3 + ((D - 2) / D ^ 2) * c4 := by
    intro n
    rw [symJointG_one_true, symJointG_one_false, ← hDdef]
    by_cases hn : n = 1
    · simp only [if_pos hn]
      have e1 : ((1 : ℝ) / D ^ 2) / (1 / D * ((2 * D - 1) / D ^ 2)) = D / (2 * D - 1) := by
        field_simp
      have e2 : ((D - 1) / D ^ 2) / (1 / D * ((D - 1) ^ 2 / D ^ 2)) = D / (D - 1) := by
        field_simp
      rw [e1, e2]
    · simp only [if_neg hn]
      have e3 : ((2 : ℝ) / D ^ 2) / (1 / D * ((2 * D - 1) / D ^ 2)) = 2 * D / (2 * D - 1) := by
        field_simp
      have e4 : ((D - 2) / D ^ 2) / (1 / D * ((D - 1) ^ 2 / D ^ 2)) = D * (D - 2) / (D - 1) ^ 2 := by
        field_simp
      rw [e3, e4]
  have hsplit : ∀ n : G,
      (if n = 1 then (1 / D ^ 2) * c1 + ((D - 1) / D ^ 2) * c2
        else (2 / D ^ 2) * c3 + ((D - 2) / D ^ 2) * c4)
      = ((2 / D ^ 2) * c3 + ((D - 2) / D ^ 2) * c4)
        + (if n = 1 then ((1 / D ^ 2) * c1 + ((D - 1) / D ^ 2) * c2)
            - ((2 / D ^ 2) * c3 + ((D - 2) / D ^ 2) * c4) else 0) := by
    intro n
    by_cases hn : n = 1 <;> simp [hn]
  rw [miF]
  simp only [Fintype.sum_bool, hrow', hcT, hcF]
  rw [Finset.sum_congr rfl (fun n _ => hterm n),
    Finset.sum_congr rfl (fun n _ => hsplit n), Finset.sum_add_distrib,
    Finset.sum_const, Finset.card_univ]
  rw [Finset.sum_ite_eq' Finset.univ (1 : G) (fun _ =>
    ((1 / D ^ 2) * c1 + ((D - 1) / D ^ 2) * c2) - ((2 / D ^ 2) * c3 + ((D - 2) / D ^ 2) * c4))]
  simp only [Finset.mem_univ, if_pos, nsmul_eq_mul, ← hDdef]
  rw [symMI, ← hc1, ← hc2, ← hc3, ← hc4]
  field_simp
  ring

end Group

/-! ## The arithmetic instance -/

/-- For every odd prime `l`, the symmetric divisibility event
`l ∣ p - 1 ∨ l ∣ q - 1` carries exactly `symMI (l - 1)` bits about `N mod l`. -/
theorem mi_sym_units (l : ℕ) [Fact (Nat.Prime l)] (hl : 2 < l) :
    miF (symJointG ({1} : Finset (ZMod l)ˣ)) = symMI ((l : ℝ) - 1) := by
  have hcard : Fintype.card (ZMod l)ˣ = l - 1 := card_units_zmod l
  have h1 : 1 < Fintype.card (ZMod l)ˣ := by rw [hcard]; omega
  have hcast : ((Fintype.card (ZMod l)ˣ : ℕ) : ℝ) = (l : ℝ) - 1 := by
    rw [hcard, Nat.cast_sub (by omega), Nat.cast_one]
  rw [miF_symJointG_singleton_eq_symMI h1, hcast]

/-! ## Numerical values -/

private theorem sym_logb2_four : Real.logb 2 4 = 2 := by
  have h : (4 : ℝ) = 2 ^ (2 : ℕ) := by norm_num
  rw [h, Real.logb_pow]
  simp

private theorem sym_logb2_eight : Real.logb 2 8 = 3 := by
  have h : (8 : ℝ) = 2 ^ (3 : ℕ) := by norm_num
  rw [h, Real.logb_pow]
  simp

private theorem sym_logb2_nine : Real.logb 2 9 = 2 * Real.logb 2 3 := by
  have h : (9 : ℝ) = 3 ^ (2 : ℕ) := by norm_num
  rw [h, Real.logb_pow]
  norm_num

/-- The `d = 2` value of the closed form agrees with the independently computed
`l = 3` mutual information `3/2 - (3/4) log₂ 3` of `SmoothSelfHintInformation`. -/
theorem symMI_two : symMI 2 = 3 / 2 - (3 / 4) * Real.logb 2 3 := by
  have h23 : Real.logb 2 ((2 : ℝ) / 3) = 1 - Real.logb 2 3 := by
    rw [Real.logb_div (by norm_num) (by norm_num)]
    simp
  have h43 : Real.logb 2 ((4 : ℝ) / 3) = 2 - Real.logb 2 3 := by
    rw [Real.logb_div (by norm_num) (by norm_num), sym_logb2_four]
  rw [symMI]
  norm_num [h23, h43]
  ring

/-- Consistency check of the two independent computations of the `l = 3` leak. -/
theorem symMI_two_eq_mi_sym_three : symMI 2 = miF Psym := by
  rw [symMI_two, mi_sym_three]

/-- The `d = 4` (i.e. `l = 5`) value of the closed form. -/
theorem symMI_four : symMI 4 = (44 - 7 * Real.logb 2 7 - 15 * Real.logb 2 3) / 16 := by
  have h47 : Real.logb 2 ((4 : ℝ) / 7) = 2 - Real.logb 2 7 := by
    rw [Real.logb_div (by norm_num) (by norm_num), sym_logb2_four]
  have h43 : Real.logb 2 ((4 : ℝ) / 3) = 2 - Real.logb 2 3 := by
    rw [Real.logb_div (by norm_num) (by norm_num), sym_logb2_four]
  have h87 : Real.logb 2 ((8 : ℝ) / 7) = 3 - Real.logb 2 7 := by
    rw [Real.logb_div (by norm_num) (by norm_num), sym_logb2_eight]
  have h89 : Real.logb 2 ((8 : ℝ) / 9) = 3 - 2 * Real.logb 2 3 := by
    rw [Real.logb_div (by norm_num) (by norm_num), sym_logb2_eight, sym_logb2_nine]
  rw [symMI]
  norm_num [h47, h43, h87, h89]
  ring

/-- `log₂ 7 > 233/83` because `7⁸³ > 2²³³`. -/
theorem logb2_seven_lower : (233 : ℝ) / 83 < Real.logb 2 7 := by
  have hl2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have hnat : (2 : ℕ) ^ 233 < 7 ^ 83 := by norm_num
  have hR : ((2 : ℝ)) ^ (233 : ℕ) < (7 : ℝ) ^ (83 : ℕ) := by exact_mod_cast hnat
  have h : Real.log ((2 : ℝ) ^ (233 : ℕ)) < Real.log ((7 : ℝ) ^ (83 : ℕ)) :=
    Real.log_lt_log (by positivity) hR
  rw [Real.log_pow, Real.log_pow] at h
  rw [Real.logb, lt_div_iff₀ hl2]
  push_cast at h
  linarith

/-- `log₂ 7 < 73/26` because `7²⁶ < 2⁷³`. -/
theorem logb2_seven_upper : Real.logb 2 7 < (73 : ℝ) / 26 := by
  have hl2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have hnat : (7 : ℕ) ^ 26 < 2 ^ 73 := by norm_num
  have hR : ((7 : ℝ)) ^ (26 : ℕ) < (2 : ℝ) ^ (73 : ℕ) := by exact_mod_cast hnat
  have h : Real.log ((7 : ℝ) ^ (26 : ℕ)) < Real.log ((2 : ℝ) ^ (73 : ℕ)) :=
    Real.log_lt_log (by positivity) hR
  rw [Real.log_pow, Real.log_pow] at h
  rw [Real.logb, div_lt_iff₀ hl2]
  push_cast at h
  linarith

/-- `log₂ 3 > 84/53` because `3⁵³ > 2⁸⁴`. -/
theorem logb2_three_lower' : (84 : ℝ) / 53 < Real.logb 2 3 := by
  have hl2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have hnat : (2 : ℕ) ^ 84 < 3 ^ 53 := by norm_num
  have hR : ((2 : ℝ)) ^ (84 : ℕ) < (3 : ℝ) ^ (53 : ℕ) := by exact_mod_cast hnat
  have h : Real.log ((2 : ℝ) ^ (84 : ℕ)) < Real.log ((3 : ℝ) ^ (53 : ℕ)) :=
    Real.log_lt_log (by positivity) hR
  rw [Real.log_pow, Real.log_pow] at h
  rw [Real.logb, lt_div_iff₀ hl2]
  push_cast at h
  linarith

/-- `log₂ 3 < 149/94` because `3⁹⁴ < 2¹⁴⁹`. -/
theorem logb2_three_upper' : Real.logb 2 3 < (149 : ℝ) / 94 := by
  have hl2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have hnat : (3 : ℕ) ^ 94 < 2 ^ 149 := by norm_num
  have hR : ((3 : ℝ)) ^ (94 : ℕ) < (2 : ℝ) ^ (149 : ℕ) := by exact_mod_cast hnat
  have h : Real.log ((3 : ℝ) ^ (94 : ℕ)) < Real.log ((2 : ℝ) ^ (149 : ℕ)) :=
    Real.log_lt_log (by positivity) hR
  rw [Real.log_pow, Real.log_pow] at h
  rw [Real.logb, div_lt_iff₀ hl2]
  push_cast at h
  linarith

/-- Certified numerical value of the `l = 5` symmetric leak: between `0.0355` and `0.036`
bits.  The experiment measured `0.036`. -/
theorem symMI_four_bounds : 0.0355 < symMI 4 ∧ symMI 4 < 0.036 := by
  rw [symMI_four]
  constructor
  · linarith [logb2_seven_upper, logb2_three_upper']
  · linarith [logb2_seven_lower, logb2_three_lower']

/-- The arithmetic form of the previous bound: at `l = 5` the symmetric divisibility event
leaks between `0.0355` and `0.036` bits about `N mod 5` — an order of magnitude less than
the `0.31` bits at `l = 3`, yet still strictly positive. -/
theorem mi_sym_five_bounds :
    0.0355 < miF (symJointG ({1} : Finset (ZMod 5)ˣ))
      ∧ miF (symJointG ({1} : Finset (ZMod 5)ˣ)) < 0.036 := by
  haveI : Fact (Nat.Prime 5) := ⟨by norm_num⟩
  have h : miF (symJointG ({1} : Finset (ZMod 5)ˣ)) = symMI 4 := by
    rw [mi_sym_units 5 (by norm_num)]
    norm_num
  rw [h]
  exact symMI_four_bounds

/-! ## Decay of the symmetric leak -/

/-- **Upper bound.**  The symmetric leak is `O(1/d²)`: the numerator of the closed form is
bounded by `2 log₂ e - 1 < 2` uniformly in the group order.  The large `l = 3` value
`0.313` is therefore a small-group artefact. -/
theorem symMI_lt_two_div_sq {d : ℝ} (hd : 2 ≤ d) : symMI d < 2 / d ^ 2 := by
  have hd0 : (0:ℝ) < d := by linarith
  have hd1 : (0:ℝ) < d - 1 := by linarith
  have h2d1 : (0:ℝ) < 2 * d - 1 := by linarith
  have hl2 : (0.6931471803:ℝ) < Real.log 2 := Real.log_two_gt_d9
  have hl2pos : (0:ℝ) < Real.log 2 := by linarith
  have hc1 : Real.logb 2 (d / (2 * d - 1)) = Real.logb 2 (2 * d / (2 * d - 1)) - 1 := by
    have hrw : d / (2 * d - 1) = (2 * d / (2 * d - 1)) / 2 := by field_simp
    rw [hrw, Real.logb_div (by positivity) (by norm_num)]
    simp
  have hc2 : Real.logb 2 (d / (d - 1)) ≤ (1 / (d - 1)) / Real.log 2 := by
    have hlog : Real.log (d / (d - 1)) ≤ 1 / (d - 1) := by
      have h := Real.log_le_sub_one_of_pos (x := d / (d - 1)) (by positivity)
      have hh : d / (d - 1) - 1 = 1 / (d - 1) := by field_simp; ring
      linarith [h, hh.ge, hh.le]
    rw [Real.logb]
    gcongr
  have hc3 : Real.logb 2 (2 * d / (2 * d - 1)) ≤ (1 / (2 * d - 1)) / Real.log 2 := by
    have hlog : Real.log (2 * d / (2 * d - 1)) ≤ 1 / (2 * d - 1) := by
      have h := Real.log_le_sub_one_of_pos (x := 2 * d / (2 * d - 1)) (by positivity)
      have hh : 2 * d / (2 * d - 1) - 1 = 1 / (2 * d - 1) := by field_simp; ring
      linarith [h, hh.ge, hh.le]
    rw [Real.logb]
    gcongr
  have hc4 : Real.logb 2 (d * (d - 2) / (d - 1) ^ 2) ≤ 0 := by
    apply Real.logb_nonpos (by norm_num) (div_nonneg (by nlinarith) (by positivity))
    rw [div_le_one (by positivity)]
    nlinarith
  have t2 : (d - 1) * Real.logb 2 (d / (d - 1)) ≤ 1 / Real.log 2 := by
    have hmul := mul_le_mul_of_nonneg_left hc2 hd1.le
    calc (d - 1) * Real.logb 2 (d / (d - 1)) ≤ (d - 1) * ((1 / (d - 1)) / Real.log 2) := hmul
      _ = 1 / Real.log 2 := by field_simp
  have t3 : (2 * d - 1) * Real.logb 2 (2 * d / (2 * d - 1)) ≤ 1 / Real.log 2 := by
    have hmul := mul_le_mul_of_nonneg_left hc3 h2d1.le
    calc (2 * d - 1) * Real.logb 2 (2 * d / (2 * d - 1))
        ≤ (2 * d - 1) * ((1 / (2 * d - 1)) / Real.log 2) := hmul
      _ = 1 / Real.log 2 := by field_simp
  have t4 : (d - 1) * (d - 2) * Real.logb 2 (d * (d - 2) / (d - 1) ^ 2) ≤ 0 :=
    mul_nonpos_of_nonneg_of_nonpos (by nlinarith) hc4
  have hinv : 1 / Real.log 2 < 1.4429 := by
    rw [div_lt_iff₀ hl2pos]; nlinarith
  have hnum : Real.logb 2 (d / (2 * d - 1)) + (d - 1) * Real.logb 2 (d / (d - 1))
      + 2 * (d - 1) * Real.logb 2 (2 * d / (2 * d - 1))
      + (d - 1) * (d - 2) * Real.logb 2 (d * (d - 2) / (d - 1) ^ 2) < 2 := by
    have key : Real.logb 2 (d / (2 * d - 1)) + (d - 1) * Real.logb 2 (d / (d - 1))
        + 2 * (d - 1) * Real.logb 2 (2 * d / (2 * d - 1))
        + (d - 1) * (d - 2) * Real.logb 2 (d * (d - 2) / (d - 1) ^ 2)
        = -1 + (d - 1) * Real.logb 2 (d / (d - 1))
          + (2 * d - 1) * Real.logb 2 (2 * d / (2 * d - 1))
          + (d - 1) * (d - 2) * Real.logb 2 (d * (d - 2) / (d - 1) ^ 2) := by
      rw [hc1]; ring
    rw [key]
    linarith
  rw [symMI]
  have hsq : (0:ℝ) < d ^ 2 := by positivity
  exact (div_lt_div_iff_of_pos_right hsq).mpr hnum

/-- **Lower bound.**  Symmetrically, the closed form never drops below `-3/d²`; together
with `symMI_lt_two_div_sq` this pins the leak to a window of width `O(1/d²)`. -/
theorem neg_lt_symMI {d : ℝ} (hd : 3 ≤ d) : -(3 / d ^ 2) < symMI d := by
  have hd0 : (0:ℝ) < d := by linarith
  have hd1 : (0:ℝ) < d - 1 := by linarith
  have hd2 : (0:ℝ) < d - 2 := by linarith
  have h2d1 : (0:ℝ) < 2 * d - 1 := by linarith
  have hl2 : (0.6931471803:ℝ) < Real.log 2 := Real.log_two_gt_d9
  have hl2pos : (0:ℝ) < Real.log 2 := by linarith
  have hc1 : Real.logb 2 (d / (2 * d - 1)) = Real.logb 2 (2 * d / (2 * d - 1)) - 1 := by
    have hrw : d / (2 * d - 1) = (2 * d / (2 * d - 1)) / 2 := by field_simp
    rw [hrw, Real.logb_div (by positivity) (by norm_num)]
    simp
  have hc2 : 0 ≤ Real.logb 2 (d / (d - 1)) := by
    apply Real.logb_nonneg (by norm_num)
    rw [le_div_iff₀ hd1]; linarith
  have hc3 : 0 ≤ Real.logb 2 (2 * d / (2 * d - 1)) := by
    apply Real.logb_nonneg (by norm_num)
    rw [le_div_iff₀ h2d1]; linarith
  have hc4 : -((1 / (d * (d - 2))) / Real.log 2) ≤ Real.logb 2 (d * (d - 2) / (d - 1) ^ 2) := by
    have h := Real.log_le_sub_one_of_pos (x := (d - 1) ^ 2 / (d * (d - 2))) (by positivity)
    have hinv : Real.log ((d - 1) ^ 2 / (d * (d - 2)))
        = - Real.log (d * (d - 2) / (d - 1) ^ 2) := by
      rw [← Real.log_inv]
      congr 1
      field_simp
    have hval : (d - 1) ^ 2 / (d * (d - 2)) - 1 = 1 / (d * (d - 2)) := by
      field_simp; ring
    rw [hinv, hval] at h
    have hstep : -(1 / (d * (d - 2))) ≤ Real.log (d * (d - 2) / (d - 1) ^ 2) := by linarith
    rw [Real.logb]
    calc -(1 / (d * (d - 2)) / Real.log 2) = (-(1 / (d * (d - 2)))) / Real.log 2 := by ring
      _ ≤ Real.log (d * (d - 2) / (d - 1) ^ 2) / Real.log 2 := by gcongr
  have t4 : -(1 / Real.log 2) ≤ (d - 1) * (d - 2) * Real.logb 2 (d * (d - 2) / (d - 1) ^ 2) := by
    have hcoef : (0:ℝ) ≤ (d - 1) * (d - 2) := by nlinarith
    have hmul := mul_le_mul_of_nonneg_left hc4 hcoef
    refine le_trans ?_ hmul
    rw [mul_neg]
    have hval : (d - 1) * (d - 2) * (1 / (d * (d - 2)) / Real.log 2)
        = ((d - 1) / d) / Real.log 2 := by
      have h1 : d ≠ 0 := ne_of_gt hd0
      have h2 : d - 2 ≠ 0 := ne_of_gt hd2
      field_simp
    rw [hval, neg_le_neg_iff, div_le_div_iff_of_pos_right hl2pos, div_le_one hd0]
    linarith
  have hinv : 1 / Real.log 2 < 1.4429 := by
    rw [div_lt_iff₀ hl2pos]; nlinarith
  have hnum : -3 < Real.logb 2 (d / (2 * d - 1)) + (d - 1) * Real.logb 2 (d / (d - 1))
      + 2 * (d - 1) * Real.logb 2 (2 * d / (2 * d - 1))
      + (d - 1) * (d - 2) * Real.logb 2 (d * (d - 2) / (d - 1) ^ 2) := by
    have hA : 0 ≤ (d - 1) * Real.logb 2 (d / (d - 1)) := mul_nonneg (by linarith) hc2
    have hB : 0 ≤ 2 * (d - 1) * Real.logb 2 (2 * d / (2 * d - 1)) :=
      mul_nonneg (by linarith) hc3
    rw [hc1]
    linarith
  rw [symMI, show -(3 / d ^ 2) = (-3 : ℝ) / d ^ 2 from by ring]
  have hsq : (0:ℝ) < d ^ 2 := by positivity
  exact (div_lt_div_iff_of_pos_right hsq).mpr hnum

/-- **The symmetric leak vanishes in the limit.**  Even the visible half of the dichotomy
fades: `symMI d → 0` as the group order grows, at rate `O(1/d²)`. -/
theorem symMI_tendsto_zero : Filter.Tendsto symMI Filter.atTop (nhds 0) := by
  have hup : Filter.Tendsto (fun d : ℝ => 2 / d ^ 2) Filter.atTop (nhds 0) := by
    apply Filter.Tendsto.div_atTop tendsto_const_nhds
    exact Filter.tendsto_pow_atTop (by norm_num)
  have hlow : Filter.Tendsto (fun d : ℝ => -(3 / d ^ 2)) Filter.atTop (nhds 0) := by
    have h3 : Filter.Tendsto (fun d : ℝ => 3 / d ^ 2) Filter.atTop (nhds 0) := by
      apply Filter.Tendsto.div_atTop tendsto_const_nhds
      exact Filter.tendsto_pow_atTop (by norm_num)
    simpa using h3.neg
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le' hlow hup ?_ ?_
  · filter_upwards [Filter.eventually_ge_atTop (3:ℝ)] with d hd using (neg_lt_symMI hd).le
  · filter_upwards [Filter.eventually_ge_atTop (2:ℝ)] with d hd using (symMI_lt_two_div_sq hd).le

/-- The arithmetic form of the decay: for every odd prime `l` the symmetric leak is
strictly positive but smaller than `2/(l-1)²` bits. -/
theorem mi_sym_decay (l : ℕ) [Fact (Nat.Prime l)] (hl : 2 < l) :
    0 < miF (symJointG ({1} : Finset (ZMod l)ˣ)) ∧
      miF (symJointG ({1} : Finset (ZMod l)ˣ)) < 2 / ((l : ℝ) - 1) ^ 2 := by
  refine ⟨miF_symJointG_pos_units l hl, ?_⟩
  have hl3 : (3 : ℝ) ≤ (l : ℝ) := by exact_mod_cast hl
  rw [mi_sym_units l hl]
  exact symMI_lt_two_div_sq (by linarith)

/-- **The dichotomy with an exact rate.**  For every odd prime `l` the asymmetric event
carries exactly `0` bits about `N mod l`, while the symmetric event carries exactly
`symMI (l-1) > 0` bits. -/
theorem dichotomy_with_rate (l : ℕ) [Fact (Nat.Prime l)] (hl : 2 < l) :
    miF (jointAsym ({1} : Finset (ZMod l)ˣ)) = 0 ∧
      miF (symJointG ({1} : Finset (ZMod l)ˣ)) = symMI ((l : ℝ) - 1) ∧
      0 < symMI ((l : ℝ) - 1) := by
  refine ⟨miF_asym_zero _, mi_sym_units l hl, ?_⟩
  rw [← mi_sym_units l hl]
  exact miF_symJointG_pos_units l hl

end SmoothSelfHint