import Mathlib
import Catalog.NumberTheory.ProfileFormResidualPeak

/-!
# Profile form VII: even the Dickman surrogate humps — outside the window

Second Stage-4 (Critic) result of this cycle, sharper than the two-atom
counterexample of `ProfileFormMixturePeak`.

The mixture-Dickman baseline actually used in the analysis is the *uniform*
scale mixture `M(x) = (1 - e^{-x})/x`.  On the measured window `x ∈ [0,1]` the
residual `T/M` of a power law against it is decreasing, which is why the
observed hump looks like new physics.  But the crossing of the two competing
log-slopes `b/(1+x)` (from the profile) and `1/x - 1/(e^x - 1)` (from the
mixture) happens near `x ≈ 10`, and there the residual really does peak.

We prove this for the measured exponent `b = 11/10`:

`uniformResidual 3 < uniformResidual 10` and `uniformResidual 100 <
uniformResidual 10`,

hence `uniformResidual` attains an interior maximum on `[3, 100]` and is neither
monotone nor antitone there (`uniformResidual_peak`).

Consequence (`peak_is_window_dependent`): *peakedness of the residual is a
window-relative statement*, not an intrinsic property distinguishing the
baseline.  Combined with `ProfileFormResidualPeak.peak_forces_nonPowerLaw_baseline`,
the defensible reading of the experiment is: the measured hump at `x ≈ 0.59`
locates a feature *inside* the analysed window, and its interpretation must be
tied to that window.

The numerical work is done with the rational-exponent trick
`rpow_eleven_tenths_le` / `le_rpow_eleven_tenths`, which converts a bound on
`a ^ (11/10)` into an exact comparison of integer powers.
-/

namespace ProfileForm

open Set

/-! ## Interior maxima on a general window -/

theorem exists_interiorMax_of_gt_endpoints' {f : ℝ → ℝ} {p q c : ℝ} (hpq : p ≤ q)
    (hf : ContinuousOn f (Icc p q)) (hc : c ∈ Ioo p q)
    (hp : f p < f c) (hq : f q < f c) :
    ∃ m ∈ Ioo p q, IsMaxOn f (Icc p q) m := by
  obtain ⟨m, hm, hmax⟩ := (isCompact_Icc (a := p) (b := q)).exists_isMaxOn
    (Set.nonempty_Icc.mpr hpq) hf
  have hcmem : c ∈ Icc p q := Ioo_subset_Icc_self hc
  have hfc : f c ≤ f m := hmax hcmem
  refine ⟨m, ⟨?_, ?_⟩, hmax⟩
  · rcases lt_or_eq_of_le hm.1 with h | h
    · exact h
    · exfalso; rw [← h] at hfc; linarith
  · rcases lt_or_eq_of_le hm.2 with h | h
    · exact h
    · exfalso; rw [h] at hfc; linarith

theorem not_monotoneOn_of_peak' {f : ℝ → ℝ} {p q c : ℝ} (hpq : p ≤ q)
    (hc : c ∈ Ioo p q) (hq : f q < f c) : ¬ MonotoneOn f (Icc p q) := by
  intro hmono
  have := hmono (Ioo_subset_Icc_self hc) (right_mem_Icc.mpr hpq) hc.2.le
  linarith

theorem not_antitoneOn_of_peak' {f : ℝ → ℝ} {p q c : ℝ} (hpq : p ≤ q)
    (hc : c ∈ Ioo p q) (hp : f p < f c) : ¬ AntitoneOn f (Icc p q) := by
  intro hanti
  have := hanti (left_mem_Icc.mpr hpq) (Ioo_subset_Icc_self hc) hc.1.le
  linarith

/-! ## Rational exponents as integer power comparisons -/

theorem rpow_eleven_tenths_le {a c : ℝ} (ha : 0 ≤ a) (hc : 0 ≤ c)
    (h : a ^ (11:ℕ) ≤ c ^ (10:ℕ)) : a ^ ((11:ℝ)/10) ≤ c := by
  have hpow : (a ^ ((11:ℝ)/10)) ^ (10:ℕ) = a ^ (11:ℕ) := by
    rw [← Real.rpow_natCast (a ^ ((11:ℝ)/10)) 10, ← Real.rpow_mul ha,
      ← Real.rpow_natCast a 11]
    norm_num
  have hnn : 0 ≤ a ^ ((11:ℝ)/10) := Real.rpow_nonneg ha _
  have hle : (a ^ ((11:ℝ)/10)) ^ (10:ℕ) ≤ c ^ (10:ℕ) := by rw [hpow]; exact h
  exact le_of_pow_le_pow_left₀ (by norm_num) hc hle

theorem le_rpow_eleven_tenths {a c : ℝ} (ha : 0 ≤ a)
    (h : c ^ (10:ℕ) ≤ a ^ (11:ℕ)) : c ≤ a ^ ((11:ℝ)/10) := by
  have hpow : (a ^ ((11:ℝ)/10)) ^ (10:ℕ) = a ^ (11:ℕ) := by
    rw [← Real.rpow_natCast (a ^ ((11:ℝ)/10)) 10, ← Real.rpow_mul ha,
      ← Real.rpow_natCast a 11]
    norm_num
  have hnn : 0 ≤ a ^ ((11:ℝ)/10) := Real.rpow_nonneg ha _
  have hle : c ^ (10:ℕ) ≤ (a ^ ((11:ℝ)/10)) ^ (10:ℕ) := by rw [hpow]; exact h
  exact le_of_pow_le_pow_left₀ (by norm_num) hnn hle

/-! ## The residual against the uniform (Dickman surrogate) mixture -/

/-- Residual of the measured power law against the uniform mixture baseline. -/
noncomputable def uniformResidual (x : ℝ) : ℝ :=
  powerProfile 1 (11/10) x / dickmanMixtureBaseline x

theorem uniformResidual_eq {x : ℝ} (hx : 0 < x) :
    uniformResidual x = (1 + x) ^ (-(11:ℝ)/10) * x / (1 - Real.exp (-x)) := by
  have h1 : (0:ℝ) < 1 - Real.exp (-x) := by
    have : Real.exp (-x) < 1 := by rw [Real.exp_lt_one_iff]; linarith
    linarith
  simp only [uniformResidual, powerProfile, dickmanMixtureBaseline, one_mul]
  rw [div_div_eq_mul_div]
  ring_nf

theorem exp_three_ge : (20 : ℝ) ≤ Real.exp 3 := by
  have h := Real.exp_one_gt_d9
  have hsplit : Real.exp 3 = Real.exp 1 * Real.exp 1 * Real.exp 1 := by
    rw [← Real.exp_add, ← Real.exp_add]; norm_num
  rw [hsplit]
  nlinarith [Real.exp_pos (1:ℝ)]

theorem exp_seven_ge : (1000 : ℝ) ≤ Real.exp 7 := by
  have h3 := exp_three_ge
  have h1 := Real.exp_one_gt_d9
  have hsplit : Real.exp 7 = Real.exp 3 * Real.exp 3 * Real.exp 1 := by
    rw [← Real.exp_add, ← Real.exp_add]; norm_num
  rw [hsplit]
  nlinarith [Real.exp_pos (1:ℝ), Real.exp_pos (3:ℝ)]

/-- Lower bound at the crossing point `x = 10`. -/
theorem uniformResidual_ten_ge : (7/10 : ℝ) ≤ uniformResidual 10 := by
  have hbase : (1:ℝ) + 10 = 11 := by norm_num
  have hkey : (11:ℝ) ^ ((11:ℝ)/10) ≤ 100/7 := by
    apply rpow_eleven_tenths_le (by norm_num) (by norm_num)
    norm_num
  have hrpow : (7/100 : ℝ) ≤ (11:ℝ) ^ (-(11:ℝ)/10) := by
    have hpos : (0:ℝ) < (11:ℝ) ^ ((11:ℝ)/10) := Real.rpow_pos_of_pos (by norm_num) _
    have hinv : (11:ℝ) ^ (-(11:ℝ)/10) = ((11:ℝ) ^ ((11:ℝ)/10))⁻¹ := by
      rw [← Real.rpow_neg (by norm_num)]
      ring_nf
    rw [hinv, le_inv_comm₀ (by norm_num) hpos]
    calc (11:ℝ) ^ ((11:ℝ)/10) ≤ 100/7 := hkey
      _ ≤ (7/100 : ℝ)⁻¹ := by norm_num
  have hexp : Real.exp (-(10:ℝ)) ≤ 1/1000 := by
    have hmono : Real.exp (-(10:ℝ)) ≤ Real.exp (-(7:ℝ)) := by
      apply Real.exp_le_exp.mpr; norm_num
    have h7 : Real.exp (-(7:ℝ)) ≤ 1/1000 := by
      rw [Real.exp_neg, inv_le_comm₀ (Real.exp_pos _) (by norm_num)]
      linarith [exp_seven_ge]
    linarith
  have hden : (0:ℝ) < 1 - Real.exp (-(10:ℝ)) := by
    have := Real.exp_pos (-(10:ℝ)); linarith
  rw [uniformResidual_eq (by norm_num), hbase]
  rw [le_div_iff₀ hden]
  nlinarith [Real.exp_pos (-(10:ℝ))]

/-- Upper bound at the left end `x = 3`. -/
theorem uniformResidual_three_le : uniformResidual 3 ≤ 69/100 := by
  have hbase : (1:ℝ) + 3 = 4 := by norm_num
  have hkey : (229/50 : ℝ) ≤ (4:ℝ) ^ ((11:ℝ)/10) := by
    apply le_rpow_eleven_tenths (by norm_num)
    norm_num
  have hpos : (0:ℝ) < (4:ℝ) ^ ((11:ℝ)/10) := Real.rpow_pos_of_pos (by norm_num) _
  have hrpow : (4:ℝ) ^ (-(11:ℝ)/10) ≤ 50/229 := by
    have hinv : (4:ℝ) ^ (-(11:ℝ)/10) = ((4:ℝ) ^ ((11:ℝ)/10))⁻¹ := by
      rw [← Real.rpow_neg (by norm_num)]
      ring_nf
    rw [hinv, inv_le_comm₀ hpos (by norm_num)]
    calc (50/229 : ℝ)⁻¹ = 229/50 := by norm_num
      _ ≤ (4:ℝ) ^ ((11:ℝ)/10) := hkey
  have hexp : Real.exp (-(3:ℝ)) ≤ 1/20 := by
    have := exp_three_ge
    rw [Real.exp_neg, inv_le_comm₀ (Real.exp_pos _) (by norm_num)]
    linarith
  have hden : (19/20 : ℝ) ≤ 1 - Real.exp (-(3:ℝ)) := by linarith
  have hdenpos : (0:ℝ) < 1 - Real.exp (-(3:ℝ)) := by linarith
  rw [uniformResidual_eq (by norm_num), hbase, div_le_iff₀ hdenpos]
  have hrp : (0:ℝ) < (4:ℝ) ^ (-(11:ℝ)/10) := Real.rpow_pos_of_pos (by norm_num) _
  nlinarith

/-- Upper bound at the right end `x = 100`. -/
theorem uniformResidual_hundred_le : uniformResidual 100 ≤ 69/100 := by
  have hbase : (1:ℝ) + 100 = 101 := by norm_num
  have hkey : (146 : ℝ) ≤ (101:ℝ) ^ ((11:ℝ)/10) := by
    apply le_rpow_eleven_tenths (by norm_num)
    norm_num
  have hpos : (0:ℝ) < (101:ℝ) ^ ((11:ℝ)/10) := Real.rpow_pos_of_pos (by norm_num) _
  have hrpow : (101:ℝ) ^ (-(11:ℝ)/10) ≤ 1/146 := by
    have hinv : (101:ℝ) ^ (-(11:ℝ)/10) = ((101:ℝ) ^ ((11:ℝ)/10))⁻¹ := by
      rw [← Real.rpow_neg (by norm_num)]
      ring_nf
    rw [hinv, inv_le_comm₀ hpos (by norm_num)]
    calc ((1:ℝ)/146)⁻¹ = 146 := by norm_num
      _ ≤ (101:ℝ) ^ ((11:ℝ)/10) := hkey
  have hexp : Real.exp (-(100:ℝ)) ≤ 1/1000 := by
    have hmono : Real.exp (-(100:ℝ)) ≤ Real.exp (-(7:ℝ)) := by
      apply Real.exp_le_exp.mpr; norm_num
    have h7 := exp_seven_ge
    have : Real.exp (-(7:ℝ)) ≤ 1/1000 := by
      rw [Real.exp_neg, inv_le_comm₀ (Real.exp_pos _) (by norm_num)]
      linarith
    linarith
  have hden : (999/1000 : ℝ) ≤ 1 - Real.exp (-(100:ℝ)) := by linarith
  have hdenpos : (0:ℝ) < 1 - Real.exp (-(100:ℝ)) := by linarith
  rw [uniformResidual_eq (by norm_num), hbase, div_le_iff₀ hdenpos]
  have hrp : (0:ℝ) < (101:ℝ) ^ (-(11:ℝ)/10) := Real.rpow_pos_of_pos (by norm_num) _
  nlinarith

theorem uniformResidual_continuousOn : ContinuousOn uniformResidual (Icc (3:ℝ) 100) := by
  have hfun : powerProfile 1 (11/10) = fun x : ℝ => (1 + x) ^ (-(11/10) : ℝ) := by
    funext x; simp [powerProfile]
  apply ContinuousOn.div
  · rw [hfun]
    intro x hx
    have hpos : (0:ℝ) < 1 + x := by have := hx.1; linarith
    exact (Real.continuousAt_rpow_const _ _ (Or.inl (ne_of_gt hpos))).continuousWithinAt.comp
      (by fun_prop : ContinuousWithinAt (fun x : ℝ => 1 + x) (Icc (3:ℝ) 100) x)
      (fun y _ => Set.mem_univ _)
  · intro x hx
    have hx0 : x ≠ 0 := by have := hx.1; intro h; rw [h] at this; linarith
    unfold dickmanMixtureBaseline
    have hnum : ContinuousWithinAt (fun x : ℝ => 1 - Real.exp (-x)) (Icc (3:ℝ) 100) x := by
      fun_prop
    exact hnum.div continuousWithinAt_id hx0
  · intro x hx
    have hx0 : (0:ℝ) < x := by have := hx.1; linarith
    exact ne_of_gt (dickmanMixtureBaseline_pos hx0)

/-- **The uniform mixture residual peaks too — near `x = 10`.** -/
theorem uniformResidual_peak :
    (∃ m ∈ Ioo (3:ℝ) 100, IsMaxOn uniformResidual (Icc (3:ℝ) 100) m) ∧
      ¬ MonotoneOn uniformResidual (Icc (3:ℝ) 100) ∧
      ¬ AntitoneOn uniformResidual (Icc (3:ℝ) 100) := by
  have hc : (10:ℝ) ∈ Ioo (3:ℝ) 100 := by constructor <;> norm_num
  have hmid := uniformResidual_ten_ge
  have h3 : uniformResidual 3 < uniformResidual 10 := by
    have := uniformResidual_three_le; linarith
  have h100 : uniformResidual 100 < uniformResidual 10 := by
    have := uniformResidual_hundred_le; linarith
  exact ⟨exists_interiorMax_of_gt_endpoints' (by norm_num) uniformResidual_continuousOn hc h3 h100,
    not_monotoneOn_of_peak' (by norm_num) hc h100,
    not_antitoneOn_of_peak' (by norm_num) hc h3⟩

/-- **Peakedness is window-relative.**  There is a power-law profile and the
uniform mixture-Dickman baseline whose residual is monotone on no window
containing `[3,100]` while being the standard, physics-free baseline: an
interior hump therefore locates a feature of the analysed window, and cannot by
itself be read as evidence that the baseline is wrong. -/
theorem peak_is_window_dependent :
    ∃ (b : ℝ), 0 < b ∧
      (∃ m ∈ Ioo (3:ℝ) 100,
        IsMaxOn (fun x => powerProfile 1 b x / dickmanMixtureBaseline x)
          (Icc (3:ℝ) 100) m) := by
  exact ⟨11/10, by norm_num, uniformResidual_peak.1⟩

end ProfileForm