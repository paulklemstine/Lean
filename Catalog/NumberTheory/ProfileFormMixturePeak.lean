import Mathlib
import Catalog.NumberTheory.ProfileFormResidualPeak

/-!
# Profile form VI: a peaked residual does *not* certify a non-mixture baseline

Stage-4 (Critic) result of this cycle.  File `ProfileFormResidualPeak` proves
that an interior peak in `T / M` rules out a baseline `M` that is a *power-law*
rescaling of the profile.  It is tempting to strengthen this to "a peak rules
out any completely monotone (positive scale mixture of exponentials) baseline",
since the mixture-Dickman baseline is of that kind and the uniform mixture
cannot produce a hump.

**That strengthening is false, and this file disproves it.**  Take the
two-atom mixture baseline

`M(x) = (exp (-x/20) + exp (-8x)) / 2`

— a bona fide positive scale mixture of exponential regimes, with rates
`1/20` and `8` — together with the measured exponent `b = 11/10`.  Then
`R = T / M` satisfies `R(0) = 1`, `R(3/10) > 5/4` and `R(1) < 5/4`, hence has a
strict interior maximum on the window and is neither monotone nor antitone
(`twoAtomResidual_peak`).

Consequence for the experiment (`mixture_baseline_peak_possible`): peakedness of
the beyond-Dickman residual is evidence about *which* mixture, not evidence
against mixtures as such.  What the measured hump does certify is exactly the
statement proved in `ProfileFormResidualPeak`: the baseline is not a power-law
rescaling of the profile.  Whether the *uniform* mixture (the Dickman surrogate
actually used) can produce a hump remains open here; the numerics say it cannot.
-/

namespace ProfileForm

open Set

/-- A two-atom positive scale mixture of exponential regimes, rates `1/20` and
`8`. -/
noncomputable def twoAtomBaseline (x : ℝ) : ℝ :=
  (Real.exp (-(x / 20)) + Real.exp (-(8 * x))) / 2

theorem twoAtomBaseline_pos (x : ℝ) : 0 < twoAtomBaseline x := by
  unfold twoAtomBaseline
  positivity

@[simp] theorem twoAtomBaseline_zero : twoAtomBaseline 0 = 1 := by
  norm_num [twoAtomBaseline]

/-- The residual of the measured profile against the two-atom baseline. -/
noncomputable def twoAtomResidual (x : ℝ) : ℝ :=
  powerProfile 1 (11/10) x / twoAtomBaseline x

@[simp] theorem twoAtomResidual_zero : twoAtomResidual 0 = 1 := by
  simp [twoAtomResidual, powerProfile]

/-- `log (13/10) ≤ 27/100`. -/
theorem log_thirteen_tenths_le : Real.log (13/10) ≤ 27/100 := by
  have hstep : (1 + 27/800 : ℝ) ≤ Real.exp (27/800 : ℝ) := by
    have := Real.add_one_le_exp (27/800 : ℝ); linarith
  have hpow : Real.exp (27/100 : ℝ) = (Real.exp (27/800 : ℝ)) ^ (8:ℕ) := by
    rw [← Real.exp_nat_mul]; norm_num
  have hle : ((1 + 27/800 : ℝ)) ^ (8:ℕ) ≤ (Real.exp (27/800 : ℝ)) ^ (8:ℕ) :=
    pow_le_pow_left₀ (by norm_num) hstep 8
  have hnum : (13/10 : ℝ) ≤ ((1 + 27/800 : ℝ)) ^ (8:ℕ) := by norm_num
  have hfinal : (13/10 : ℝ) ≤ Real.exp (27/100 : ℝ) := by
    rw [hpow]; linarith
  have := Real.log_le_log (by norm_num : (0:ℝ) < 13/10) hfinal
  rwa [Real.log_exp] at this

/-- The profile value at the peak location, from below. -/
theorem powerProfile_three_tenths_ge :
    (703/1000 : ℝ) ≤ powerProfile 1 (11/10) (3/10) := by
  have hbase : (1 : ℝ) + 3/10 = 13/10 := by norm_num
  have hpos : (0:ℝ) < 13/10 := by norm_num
  have hexp : powerProfile 1 (11/10) (3/10) = Real.exp (-(11/10 * Real.log (13/10))) := by
    simp only [powerProfile, hbase, one_mul]
    rw [Real.rpow_def_of_pos hpos]
    ring_nf
  have hlog := log_thirteen_tenths_le
  have hlogpos : 0 < Real.log (13/10) := Real.log_pos (by norm_num)
  have hmono : Real.exp (-(297/1000 : ℝ)) ≤ Real.exp (-(11/10 * Real.log (13/10))) := by
    apply Real.exp_le_exp.mpr
    nlinarith
  have hub : Real.exp (297/1000 : ℝ) ≤ (1 - 297/1000 : ℝ)⁻¹ :=
    exp_le_inv_one_sub (by norm_num)
  have hlow : (703/1000 : ℝ) ≤ Real.exp (-(297/1000 : ℝ)) := by
    rw [Real.exp_neg]
    rw [le_inv_comm₀ (by norm_num) (Real.exp_pos _)]
    calc Real.exp (297/1000 : ℝ) ≤ (1 - 297/1000 : ℝ)⁻¹ := hub
      _ ≤ (703/1000 : ℝ)⁻¹ := by norm_num
  rw [hexp]
  linarith

/-- The two-atom baseline at the peak location, from above. -/
theorem twoAtomBaseline_three_tenths_le : twoAtomBaseline (3/10) ≤ 11/20 := by
  have h1 : Real.exp (-((3/10 : ℝ) / 20)) ≤ 1 := by
    apply Real.exp_le_one_iff.mpr; norm_num
  have h2 : Real.exp (-(8 * (3/10 : ℝ))) ≤ 1/10 := by
    have he2 : (7.38 : ℝ) ≤ Real.exp 2 := by
      have h := Real.exp_one_gt_d9
      have : Real.exp 2 = Real.exp 1 * Real.exp 1 := by rw [← Real.exp_add]; norm_num
      rw [this]; nlinarith [Real.exp_pos (1:ℝ)]
    have he04 : (7/5 : ℝ) ≤ Real.exp (2/5 : ℝ) := by
      have := Real.add_one_le_exp (2/5 : ℝ); linarith
    have hbig : (10 : ℝ) ≤ Real.exp (12/5 : ℝ) := by
      have hsplit : Real.exp (12/5 : ℝ) = Real.exp 2 * Real.exp (2/5 : ℝ) := by
        rw [← Real.exp_add]; norm_num
      rw [hsplit]
      calc (10:ℝ) ≤ 7.38 * (7/5) := by norm_num
        _ ≤ Real.exp 2 * Real.exp (2/5 : ℝ) :=
            mul_le_mul he2 he04 (by norm_num) (by positivity)
    have hrw : (-(8 * (3/10 : ℝ))) = -(12/5 : ℝ) := by norm_num
    rw [hrw, Real.exp_neg]
    rw [inv_le_comm₀ (Real.exp_pos _) (by norm_num)]
    linarith
  unfold twoAtomBaseline
  linarith

/-- The peak value clears `5/4`. -/
theorem twoAtomResidual_three_tenths_gt : 5/4 < twoAtomResidual (3/10) := by
  have hT := powerProfile_three_tenths_ge
  have hM := twoAtomBaseline_three_tenths_le
  have hMpos := twoAtomBaseline_pos (3/10)
  rw [twoAtomResidual, lt_div_iff₀ hMpos]
  nlinarith

/-- The far end value stays below `5/4`. -/
theorem twoAtomResidual_one_lt : twoAtomResidual 1 < 5/4 := by
  have hT : powerProfile 1 (11/10) 1 ≤ 1/2 := by
    have hbase : (1 : ℝ) + 1 = 2 := by norm_num
    simp only [powerProfile, hbase, one_mul]
    have hlt : (2:ℝ) ^ (-(11/10) : ℝ) < (2:ℝ) ^ (-1 : ℝ) :=
      Real.rpow_lt_rpow_of_exponent_lt (by norm_num) (by norm_num)
    have : (2:ℝ) ^ (-1 : ℝ) = 1/2 := by
      rw [Real.rpow_neg_one]; norm_num
    linarith [hlt, this.le, this.ge]
  have hM : (19/40 : ℝ) ≤ twoAtomBaseline 1 := by
    have h1 : (19/20 : ℝ) ≤ Real.exp (-(1 / 20 : ℝ)) := by
      have hub : Real.exp (1/20 : ℝ) ≤ (1 - 1/20 : ℝ)⁻¹ := exp_le_inv_one_sub (by norm_num)
      rw [Real.exp_neg, le_inv_comm₀ (by norm_num) (Real.exp_pos _)]
      calc Real.exp (1/20 : ℝ) ≤ (1 - 1/20 : ℝ)⁻¹ := hub
        _ ≤ (19/20 : ℝ)⁻¹ := by norm_num
    have h2 : (0:ℝ) < Real.exp (-8 : ℝ) := Real.exp_pos _
    unfold twoAtomBaseline
    norm_num
    linarith
  have hMpos := twoAtomBaseline_pos 1
  rw [twoAtomResidual, div_lt_iff₀ hMpos]
  nlinarith

theorem twoAtomResidual_continuousOn : ContinuousOn twoAtomResidual (Icc (0:ℝ) 1) := by
  have hfun : powerProfile 1 (11/10) = fun x : ℝ => (1 + x) ^ (-(11/10) : ℝ) := by
    funext x; simp [powerProfile]
  apply ContinuousOn.div
  · rw [hfun]
    intro x hx
    have hpos : (0:ℝ) < 1 + x := by have := hx.1; linarith
    have hc : ContinuousWithinAt (fun x : ℝ => (1 + x) ^ (-(11/10) : ℝ)) (Icc (0:ℝ) 1) x :=
      (Real.continuousAt_rpow_const _ _ (Or.inl (ne_of_gt hpos))).continuousWithinAt.comp
        (by fun_prop : ContinuousWithinAt (fun x : ℝ => 1 + x) (Icc (0:ℝ) 1) x)
        (fun y _ => Set.mem_univ _)
    exact hc
  · apply Continuous.continuousOn
    unfold twoAtomBaseline
    fun_prop
  · intro x _
    exact ne_of_gt (twoAtomBaseline_pos x)

/-- **A completely monotone baseline can produce a peaked residual.** -/
theorem twoAtomResidual_peak :
    (∃ m ∈ Ioo (0:ℝ) 1, IsMaxOn twoAtomResidual (Icc (0:ℝ) 1) m) ∧
      ¬ MonotoneOn twoAtomResidual (Icc (0:ℝ) 1) ∧
      ¬ AntitoneOn twoAtomResidual (Icc (0:ℝ) 1) := by
  have hc : (3/10 : ℝ) ∈ Ioo (0:ℝ) 1 := by constructor <;> norm_num
  have h0 : twoAtomResidual 0 < twoAtomResidual (3/10) := by
    rw [twoAtomResidual_zero]
    linarith [twoAtomResidual_three_tenths_gt]
  have h1 : twoAtomResidual 1 < twoAtomResidual (3/10) := by
    linarith [twoAtomResidual_one_lt, twoAtomResidual_three_tenths_gt]
  exact ⟨exists_interiorMax_of_gt_endpoints twoAtomResidual_continuousOn hc h0 h1,
    not_monotoneOn_of_peak hc h1, not_antitoneOn_of_peak hc h0⟩

/-- **Critic's correction.**  There exist a genuine power-law profile and a
genuine positive two-atom scale mixture of exponential regimes whose residual is
peaked inside the window.  So an interior peak, by itself, is not evidence
against a mixture baseline; the certification proved in
`ProfileFormResidualPeak` is exactly the weaker (and true) statement that the
baseline is not a power-law rescaling of the profile. -/
theorem mixture_baseline_peak_possible :
    ∃ (b : ℝ) (w₁ s₁ w₂ s₂ : ℝ), 0 < b ∧ 0 < w₁ ∧ 0 < s₁ ∧ 0 < w₂ ∧ 0 < s₂ ∧
      (∀ x, twoAtomBaseline x
        = w₁ * Real.exp (-(s₁ * x)) + w₂ * Real.exp (-(s₂ * x))) ∧
      (∃ m ∈ Ioo (0:ℝ) 1,
        IsMaxOn (fun x => powerProfile 1 b x / twoAtomBaseline x) (Icc (0:ℝ) 1) m) := by
  refine ⟨11/10, 1/2, 1/20, 1/2, 8, by norm_num, by norm_num, by norm_num, by norm_num,
    by norm_num, ?_, ?_⟩
  · intro x
    unfold twoAtomBaseline
    rw [show -((1/20 : ℝ) * x) = -(x / 20) by ring]
    ring
  · exact twoAtomResidual_peak.1

end ProfileForm