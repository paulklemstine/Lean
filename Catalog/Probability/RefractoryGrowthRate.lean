/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Catalog.Probability.NeuralCoding.RefractoryGeneralized

/-!
# The exact growth rate of refractory temporal codes

`RefractoryGeneralized.lean` proved the combinatorial half of the refractory
capacity problem: the number `c_r(n) = (trainsR r n).card` of admissible spike
trains in a window of `n` bins, for a neuron with an `r`-bin refractory period,
satisfies

`c_r(n) = n + 1` for `n ≤ r`,   `c_r(n + r + 1) = c_r(n + r) + c_r(n)`,

whose characteristic equation is `x ^ (r + 1) = x ^ r + 1`.  Only crude rate
bounds (`c_r((r+1)m) ≤ (2^r + 1)^m`) were available there.

This file settles the *analytic* half: the exponential growth rate of `c_r` is
exactly the root of the characteristic equation.

## Main definitions

* `lamR r` : the unique real `x ≥ 1` with `x ^ r * (x - 1) = 1`, equivalently
  `x ^ (r + 1) = x ^ r + 1`.  It lies in `(1, 2]`.

## Main results

* `lamR_unique` : uniqueness of the root, and `lamR_one_eq_goldenRatio`,
  `lamR_zero` : `λ_0 = 2`, `λ_1 = φ`.
* `card_trainsR_le_lamR`, `lamR_le_card_trainsR` : the two-sided bound
  `λ_r ^ n ≤ λ_r ^ r * c_r(n)` and `c_r(n) ≤ (r + 1) * λ_r ^ n`.
* `tendsto_log_card_trainsR` : `log c_r(n) / n → log λ_r`;
  `tendsto_card_trainsR_rpow` : `c_r(n) ^ (1/n) → λ_r`;
  `tendsto_temporal_rate` : the bit rate `log₂ c_r(n) / n → log₂ λ_r`.
* `lamR_strictAnti` : `λ_{r+1} < λ_r` — a longer refractory period strictly
  lowers the rate — and `tendsto_lamR_one` : `λ_r → 1`, so the rate tends to `0`.
* `lamR_two_bounds` : `1.46 < λ_2 < 1.47`, hence a rate of about `0.55` bits per
  bin, well below the `2/3` upper bound proved earlier.
-/

namespace Catalog.Probability.NeuralCoding.Temporal

open Filter Topology

/-! ## 1.  The characteristic root -/

/-- The characteristic function `x ↦ x ^ r * (x - 1)`; the refractory growth rate is
its unique solution of `f x = 1` on `[1, ∞)`. -/
noncomputable def charFn (r : ℕ) (x : ℝ) : ℝ := x ^ r * (x - 1)

theorem charFn_strictMonoOn (r : ℕ) : StrictMonoOn (charFn r) (Set.Ici (1 : ℝ)) := by
  intro x hx y hy hxy
  simp only [Set.mem_Ici] at hx hy
  have hx0 : (0 : ℝ) ≤ x := by linarith
  have hy0 : (0 : ℝ) < y := by linarith
  have h1 : x ^ r ≤ y ^ r := pow_le_pow_left₀ hx0 hxy.le r
  have hyr : (0 : ℝ) < y ^ r := pow_pos hy0 r
  have h2 : x - 1 < y - 1 := by linarith
  calc charFn r x = x ^ r * (x - 1) := rfl
    _ ≤ y ^ r * (x - 1) := by
        exact mul_le_mul_of_nonneg_right h1 (by linarith)
    _ < y ^ r * (y - 1) := by exact mul_lt_mul_of_pos_left h2 hyr
    _ = charFn r y := rfl

theorem continuous_charFn (r : ℕ) : Continuous (charFn r) := by
  unfold charFn
  fun_prop

/-- The characteristic equation `x ^ r * (x - 1) = 1` has a solution in `[1, 2]`. -/
theorem exists_charFn_eq_one (r : ℕ) : ∃ x ∈ Set.Icc (1 : ℝ) 2, charFn r x = 1 := by
  have hcont : ContinuousOn (charFn r) (Set.Icc (1 : ℝ) 2) :=
    (continuous_charFn r).continuousOn
  have h1 : charFn r 1 = 0 := by simp [charFn]
  have h2 : charFn r 2 = 2 ^ r := by norm_num [charFn]
  have hmem : (1 : ℝ) ∈ Set.Icc (charFn r 1) (charFn r 2) := by
    rw [h1, h2]
    exact ⟨by norm_num, one_le_pow₀ (by norm_num)⟩
  have := intermediate_value_Icc (by norm_num : (1 : ℝ) ≤ 2) hcont hmem
  obtain ⟨x, hx, hxeq⟩ := this
  exact ⟨x, hx, hxeq⟩

/-- **The refractory growth rate** `λ_r`: the unique `x ≥ 1` solving
`x ^ r * (x - 1) = 1`, equivalently `x ^ (r + 1) = x ^ r + 1`. -/
noncomputable def lamR (r : ℕ) : ℝ := (exists_charFn_eq_one r).choose

theorem lamR_mem_Icc (r : ℕ) : lamR r ∈ Set.Icc (1 : ℝ) 2 :=
  (exists_charFn_eq_one r).choose_spec.1

theorem charFn_lamR (r : ℕ) : charFn r (lamR r) = 1 :=
  (exists_charFn_eq_one r).choose_spec.2

theorem lamR_spec (r : ℕ) : (lamR r) ^ r * (lamR r - 1) = 1 := charFn_lamR r

theorem one_lt_lamR (r : ℕ) : 1 < lamR r := by
  rcases lt_or_eq_of_le (lamR_mem_Icc r).1 with h | h
  · exact h
  · exfalso
    have := lamR_spec r
    rw [← h] at this
    norm_num at this

theorem lamR_le_two (r : ℕ) : lamR r ≤ 2 := (lamR_mem_Icc r).2

theorem lamR_pos (r : ℕ) : 0 < lamR r := lt_trans one_pos (one_lt_lamR r)

/-- The characteristic equation in the form used by the capacity recursion. -/
theorem lamR_pow_succ (r : ℕ) : (lamR r) ^ (r + 1) = (lamR r) ^ r + 1 := by
  have h := lamR_spec r
  have : (lamR r) ^ r * lamR r - (lamR r) ^ r = 1 := by rw [← h]; ring
  rw [pow_succ]
  linarith

/-- **Uniqueness of the characteristic root.** -/
theorem lamR_unique {r : ℕ} {x : ℝ} (hx : 1 ≤ x) (h : x ^ r * (x - 1) = 1) : x = lamR r :=
  (charFn_strictMonoOn r).injOn hx (lamR_mem_Icc r).1 (by rw [charFn, charFn, h, lamR_spec])

/-- With no refractory period the growth rate is `2`: the code is unconstrained. -/
theorem lamR_zero : lamR 0 = 2 := by
  refine (lamR_unique (by norm_num) ?_).symm
  norm_num

/-- A one-bin refractory period gives the golden ratio, matching the Fibonacci
capacity `c_1(n) = fib(n+2)` of `RefractoryGeneralized.card_trainsR_one`. -/
theorem lamR_one_eq_goldenRatio : lamR 1 = (1 + Real.sqrt 5) / 2 := by
  refine (lamR_unique ?_ ?_).symm
  · have h5 : Real.sqrt 5 ^ 2 = 5 := Real.sq_sqrt (by norm_num)
    have hnn : (0 : ℝ) ≤ Real.sqrt 5 := Real.sqrt_nonneg 5
    nlinarith
  · have h5 : Real.sqrt 5 ^ 2 = 5 := Real.sq_sqrt (by norm_num)
    have : ((1 + Real.sqrt 5) / 2) ^ 1 * ((1 + Real.sqrt 5) / 2 - 1)
        = (Real.sqrt 5 ^ 2 - 1) / 4 := by ring
    rw [this, h5]; norm_num

/-! ## 2.  Two-sided bounds on the capacity -/

/-- **Upper bound.**  `c_r(n) ≤ (r + 1) · λ_r ^ n`. -/
theorem card_trainsR_le_lamR (r : ℕ) :
    ∀ n : ℕ, ((trainsR r n).card : ℝ) ≤ (r + 1) * (lamR r) ^ n := by
  intro n
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    by_cases hn : n ≤ r
    · rw [card_trainsR_small r n hn]
      have hpow : (1 : ℝ) ≤ (lamR r) ^ n := one_le_pow₀ (one_lt_lamR r).le
      have : ((n : ℝ) + 1) ≤ ((r : ℝ) + 1) := by
        have : (n : ℝ) ≤ (r : ℝ) := by exact_mod_cast hn
        linarith
      calc ((n : ℕ) + 1 : ℕ) = ((n : ℝ) + 1) := by push_cast; ring
        _ ≤ ((r : ℝ) + 1) := this
        _ = ((r : ℝ) + 1) * 1 := by ring
        _ ≤ ((r : ℝ) + 1) * (lamR r) ^ n := by
            apply mul_le_mul_of_nonneg_left hpow (by positivity)
    · obtain ⟨m, hm⟩ : ∃ m, n = m + r + 1 := ⟨n - r - 1, by omega⟩
      subst hm
      have h1 := ih (m + r) (by omega)
      have h2 := ih m (by omega)
      have hrec := card_trainsR_recursion r m
      have hcast : ((trainsR r (m + r + 1)).card : ℝ)
          = ((trainsR r (m + r)).card : ℝ) + ((trainsR r m).card : ℝ) := by
        exact_mod_cast congrArg (fun k : ℕ => (k : ℝ)) hrec
      rw [hcast]
      have hkey : ((r : ℝ) + 1) * (lamR r) ^ (m + r) + ((r : ℝ) + 1) * (lamR r) ^ m
          = ((r : ℝ) + 1) * (lamR r) ^ (m + r + 1) := by
        have : (lamR r) ^ (m + r + 1) = (lamR r) ^ m * (lamR r) ^ (r + 1) := by
          rw [← pow_add]; ring_nf
        rw [this, lamR_pow_succ]
        have : (lamR r) ^ (m + r) = (lamR r) ^ m * (lamR r) ^ r := by rw [← pow_add]
        rw [this]; ring
      linarith

/-- **Lower bound.**  `λ_r ^ n ≤ λ_r ^ r · c_r(n)`. -/
theorem lamR_le_card_trainsR (r : ℕ) :
    ∀ n : ℕ, (lamR r) ^ n ≤ (lamR r) ^ r * ((trainsR r n).card : ℝ) := by
  intro n
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    by_cases hn : n ≤ r
    · rw [card_trainsR_small r n hn]
      have hmono : (lamR r) ^ n ≤ (lamR r) ^ r :=
        pow_le_pow_right₀ (one_lt_lamR r).le hn
      have hone : (1 : ℝ) ≤ ((n : ℕ) + 1 : ℕ) := by
        have : (1 : ℕ) ≤ n + 1 := by omega
        exact_mod_cast this
      have hpos : (0 : ℝ) < (lamR r) ^ r := pow_pos (lamR_pos r) r
      calc (lamR r) ^ n ≤ (lamR r) ^ r := hmono
        _ = (lamR r) ^ r * 1 := by ring
        _ ≤ (lamR r) ^ r * ((n + 1 : ℕ) : ℝ) := by
            exact mul_le_mul_of_nonneg_left hone hpos.le
    · obtain ⟨m, hm⟩ : ∃ m, n = m + r + 1 := ⟨n - r - 1, by omega⟩
      subst hm
      have h1 := ih (m + r) (by omega)
      have h2 := ih m (by omega)
      have hrec := card_trainsR_recursion r m
      have hcast : ((trainsR r (m + r + 1)).card : ℝ)
          = ((trainsR r (m + r)).card : ℝ) + ((trainsR r m).card : ℝ) := by
        exact_mod_cast congrArg (fun k : ℕ => (k : ℝ)) hrec
      rw [hcast]
      have hsplit : (lamR r) ^ (m + r + 1) = (lamR r) ^ (m + r) + (lamR r) ^ m := by
        have e1 : (lamR r) ^ (m + r + 1) = (lamR r) ^ m * (lamR r) ^ (r + 1) := by
          rw [← pow_add]; ring_nf
        have e2 : (lamR r) ^ (m + r) = (lamR r) ^ m * (lamR r) ^ r := by rw [← pow_add]
        rw [e1, e2, lamR_pow_succ]; ring
      rw [hsplit]
      nlinarith [h1, h2]

/-! ## 3.  The growth rate -/

theorem card_trainsR_pos_real (r n : ℕ) : (0 : ℝ) < ((trainsR r n).card : ℝ) := by
  exact_mod_cast card_trainsR_pos r n

/-- The logarithmic form of the two-sided bound:
`n log λ_r - r log λ_r ≤ log c_r(n) ≤ log (r+1) + n log λ_r`. -/
theorem log_card_trainsR_bounds (r n : ℕ) :
    (n : ℝ) * Real.log (lamR r) - r * Real.log (lamR r)
      ≤ Real.log ((trainsR r n).card) ∧
    Real.log ((trainsR r n).card) ≤ Real.log (r + 1) + n * Real.log (lamR r) := by
  have hpos := card_trainsR_pos_real r n
  have hlpos : (0 : ℝ) < lamR r := lamR_pos r
  constructor
  · have h := lamR_le_card_trainsR r n
    have hL : Real.log ((lamR r) ^ n) ≤ Real.log ((lamR r) ^ r * ((trainsR r n).card : ℝ)) :=
      Real.log_le_log (by positivity) h
    rw [Real.log_mul (by positivity) (ne_of_gt hpos), Real.log_pow, Real.log_pow] at hL
    linarith
  · have h := card_trainsR_le_lamR r n
    have hL : Real.log ((trainsR r n).card) ≤ Real.log (((r : ℝ) + 1) * (lamR r) ^ n) :=
      Real.log_le_log hpos h
    rw [Real.log_mul (by positivity) (by positivity), Real.log_pow] at hL
    linarith

/-- **The exponential growth rate of the refractory capacity is `λ_r`** (log form). -/
theorem tendsto_log_card_trainsR (r : ℕ) :
    Tendsto (fun n : ℕ => Real.log ((trainsR r n).card) / n) atTop
      (𝓝 (Real.log (lamR r))) := by
  set L := Real.log (lamR r) with hL
  have hlow : Tendsto (fun n : ℕ => L - ((r : ℝ) * L) / (n : ℝ)) atTop (𝓝 L) := by
    have h0 : Tendsto (fun n : ℕ => ((r : ℝ) * L) / (n : ℝ)) atTop (𝓝 0) :=
      tendsto_const_div_atTop_nhds_zero_nat _
    simpa using tendsto_const_nhds.sub h0
  have hhigh : Tendsto (fun n : ℕ => L + Real.log ((r : ℝ) + 1) / (n : ℝ)) atTop (𝓝 L) := by
    have h0 : Tendsto (fun n : ℕ => Real.log ((r : ℝ) + 1) / (n : ℝ)) atTop (𝓝 0) :=
      tendsto_const_div_atTop_nhds_zero_nat _
    simpa using tendsto_const_nhds.add h0
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le' hlow hhigh ?_ ?_
  · filter_upwards [eventually_gt_atTop 0] with n hn
    have hn' : (0 : ℝ) < n := by exact_mod_cast hn
    have h := (log_card_trainsR_bounds r n).1
    have hEq : L - ((r : ℝ) * L) / (n : ℝ) = ((n : ℝ) * L - (r : ℝ) * L) / n := by
      field_simp
    rw [hEq]
    gcongr
  · filter_upwards [eventually_gt_atTop 0] with n hn
    have hn' : (0 : ℝ) < n := by exact_mod_cast hn
    have h := (log_card_trainsR_bounds r n).2
    have hEq : L + Real.log ((r : ℝ) + 1) / (n : ℝ)
        = (Real.log ((r : ℝ) + 1) + (n : ℝ) * L) / n := by
      field_simp; ring
    rw [hEq]
    gcongr

/-- **The `n`-th root form.**  `c_r(n) ^ (1/n) → λ_r`. -/
theorem tendsto_card_trainsR_rpow (r : ℕ) :
    Tendsto (fun n : ℕ => (((trainsR r n).card : ℝ)) ^ ((n : ℝ)⁻¹)) atTop (𝓝 (lamR r)) := by
  have hcomp : Tendsto (fun n : ℕ => Real.exp (Real.log ((trainsR r n).card) / n)) atTop
      (𝓝 (Real.exp (Real.log (lamR r)))) :=
    (Real.continuous_exp.tendsto _).comp (tendsto_log_card_trainsR r)
  rw [Real.exp_log (lamR_pos r)] at hcomp
  refine hcomp.congr (fun n => ?_)
  rw [Real.rpow_def_of_pos (card_trainsR_pos_real r n)]
  ring_nf

/-- **Bit rate.**  The information rate of an `r`-refractory temporal code converges to
`log₂ λ_r` bits per time bin. -/
theorem tendsto_temporal_rate (r : ℕ) :
    Tendsto (fun n : ℕ => Real.logb 2 ((trainsR r n).card) / n) atTop
      (𝓝 (Real.logb 2 (lamR r))) := by
  have h := (tendsto_log_card_trainsR r).div_const (Real.log 2)
  simp only [Real.logb]
  refine h.congr (fun n => ?_)
  ring

/-! ## 4.  Monotonicity in the refractory period -/

/-- **A longer refractory period strictly lowers the growth rate.** -/
theorem lamR_strictAnti (r : ℕ) : lamR (r + 1) < lamR r := by
  have hmono := charFn_strictMonoOn (r + 1)
  have hr1 : (1 : ℝ) ≤ lamR (r + 1) := (lamR_mem_Icc (r + 1)).1
  have hr : (1 : ℝ) ≤ lamR r := (lamR_mem_Icc r).1
  have hval : charFn (r + 1) (lamR r) = lamR r := by
    have := lamR_spec r
    simp only [charFn, pow_succ]
    calc (lamR r) ^ r * lamR r * (lamR r - 1)
        = lamR r * ((lamR r) ^ r * (lamR r - 1)) := by ring
      _ = lamR r * 1 := by rw [this]
      _ = lamR r := by ring
  have hlt : charFn (r + 1) (lamR (r + 1)) < charFn (r + 1) (lamR r) := by
    rw [charFn_lamR (r + 1), hval]
    exact one_lt_lamR r
  exact hmono.lt_iff_lt hr1 hr |>.mp hlt

theorem lamR_antitone {r s : ℕ} (h : r ≤ s) : lamR s ≤ lamR r := by
  induction s with
  | zero => simp_all
  | succ s ih =>
      rcases Nat.lt_or_ge r (s + 1) with hlt | hge
      · have : lamR (s + 1) < lamR s := lamR_strictAnti s
        exact le_trans this.le (ih (by omega))
      · have : r = s + 1 := by omega
        subst this; exact le_rfl

/-- **The rate vanishes for long refractory periods**: `λ_r → 1`. -/
theorem tendsto_lamR_one : Tendsto (fun r : ℕ => lamR r) atTop (𝓝 1) := by
  rw [Metric.tendsto_atTop]
  intro ε hε
  set e : ℝ := min ε 1 with he
  have he0 : 0 < e := lt_min hε one_pos
  have hele : e ≤ ε := min_le_left _ _
  -- for `r` large, `(1 + e)^r * e > 1`, so `λ_r < 1 + e`
  obtain ⟨R, hR⟩ := exists_nat_gt (1 / e ^ 2)
  refine ⟨R + 1, fun r hr => ?_⟩
  have hrpos : (1 : ℝ) / e ^ 2 < r := by
    have : (R : ℝ) ≤ r := by exact_mod_cast (by omega : R ≤ r)
    linarith
  have hbig : (1 : ℝ) < charFn r (1 + e) := by
    have hpow : (1 : ℝ) + r * e ≤ (1 + e) ^ r := by
      have := one_add_mul_le_pow (a := e) (by linarith) r
      linarith
    have hkey : 1 < (1 + (r : ℝ) * e) * e := by
      have hr2 : 1 / e ^ 2 < (r : ℝ) := hrpos
      rw [div_lt_iff₀ (by positivity : (0 : ℝ) < e ^ 2)] at hr2
      nlinarith [he0]
    have hcf : charFn r (1 + e) = (1 + e) ^ r * e := by simp [charFn]
    rw [hcf]
    have : (1 + (r : ℝ) * e) * e ≤ (1 + e) ^ r * e := by
      exact mul_le_mul_of_nonneg_right hpow he0.le
    linarith
  have hlt : lamR r < 1 + e := by
    have hmono := charFn_strictMonoOn r
    have h1 : (1 : ℝ) ≤ lamR r := (lamR_mem_Icc r).1
    have h2 : (1 : ℝ) ≤ 1 + e := by linarith
    have : charFn r (lamR r) < charFn r (1 + e) := by rw [charFn_lamR r]; exact hbig
    exact (hmono.lt_iff_lt h1 h2).mp this
  have hge1 : (1 : ℝ) ≤ lamR r := (lamR_mem_Icc r).1
  rw [Real.dist_eq, abs_of_nonneg (by linarith)]
  linarith

/-! ## 5.  Numerics for the two-bin refractory period -/

/-- `1.46 < λ_2 < 1.47`: a two-bin refractory period allows about `0.5515` bits per
bin, strictly below the `2/3` bound of `temporal_rate_two_le`. -/
theorem lamR_two_bounds : 1.46 < lamR 2 ∧ lamR 2 < 1.47 := by
  have hmono := charFn_strictMonoOn 2
  have hlam : (1 : ℝ) ≤ lamR 2 := (lamR_mem_Icc 2).1
  constructor
  · have hlow : charFn 2 1.46 < charFn 2 (lamR 2) := by
      rw [charFn_lamR 2]; norm_num [charFn]
    exact (hmono.lt_iff_lt (by norm_num) hlam).mp hlow
  · have hhigh : charFn 2 (lamR 2) < charFn 2 1.47 := by
      rw [charFn_lamR 2]; norm_num [charFn]
    exact (hmono.lt_iff_lt hlam (by norm_num)).mp hhigh

/-- The `r = 2` rate is strictly below the `2 / 3` bits-per-bin bound proved in
`RefractoryGeneralized.temporal_rate_two_le`. -/
theorem logb_lamR_two_lt : Real.logb 2 (lamR 2) < 2 / 3 := by
  have h : lamR 2 < 1.47 := lamR_two_bounds.2
  have hpos : (0 : ℝ) < lamR 2 := lamR_pos 2
  have h1 : Real.logb 2 (lamR 2) < Real.logb 2 1.47 :=
    Real.logb_lt_logb (by norm_num) hpos h
  have h2 : Real.logb 2 1.47 < 2 / 3 := by
    have hcube : Real.log ((1.47 : ℝ) ^ (3 : ℕ)) < Real.log 4 :=
      Real.log_lt_log (by norm_num) (by norm_num)
    rw [Real.log_pow, show (4 : ℝ) = 2 ^ (2 : ℕ) by norm_num, Real.log_pow] at hcube
    have hl2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
    rw [Real.logb, div_lt_iff₀ hl2]
    push_cast at hcube
    linarith
  linarith

end Catalog.Probability.NeuralCoding.Temporal