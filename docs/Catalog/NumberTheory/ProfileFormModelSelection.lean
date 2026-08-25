import Mathlib
import Catalog.NumberTheory.ProfileFormPowerLaw

/-!
# Profile form III: the model-selection verdict is a theorem, not a judgement

Context (experiment 579, paper 229; V1 rule).  The power-law profile won the
pre-registered model comparison with reported Akaike weight `0.9866` against
three rivals at `ΔAICc = +9.2` (exponential), `+11.5` (logistic, degenerate)
and `+16.9` (linear).

The Akaike weight of the best model in a four-model set with gaps
`d₁, d₂, d₃ ≥ 0` is

`w(d₁,d₂,d₃) = 1 / (1 + exp(-d₁/2) + exp(-d₂/2) + exp(-d₃/2))`.

Everything about the verdict except the fitted numbers is deterministic, and
that part is proved here:

* `akaikeWeight_mem_Ioo` — the weight is a genuine probability;
* `akaikeWeight_monotone_left` (and the symmetric variants) — widening any gap
  can only strengthen the winner;
* `akaikeWeight_lt_of_zero_gap` — a tied rival caps the weight at `1/2`, so a
  large weight is *evidence*, not an artefact of the normalisation;
* `akaikeWeight_ge_of_gaps` — a uniform lower bound `1/(1+3e^{-d/2})` in terms
  of the smallest gap;
* `akaikeWeight_exp579_gt` — with the measured gaps the weight exceeds `0.98`,
  confirming the reported `0.9866` to the accuracy that rigorous exponential
  bounds allow;
* `akaikeWeight_tendsto_one` — the weight saturates at `1` as the gaps grow.

The numerical bounds rest only on `Real.exp_one_gt_d9` and `Real.add_one_le_exp`
(`exp_four_ge`, `exp_neg_le_inv`); the file shares the `ProfileForm` namespace
with `NumberTheory.ProfileFormPowerLaw`.
-/

namespace ProfileForm

open Real Filter Topology

/-- Akaike weight of the best model in a four-model comparison whose three
rivals sit at `ΔAICc = d₁, d₂, d₃`. -/
noncomputable def akaikeWeight (d₁ d₂ d₃ : ℝ) : ℝ :=
  1 / (1 + Real.exp (-d₁ / 2) + Real.exp (-d₂ / 2) + Real.exp (-d₃ / 2))

theorem akaikeWeight_denom_pos (d₁ d₂ d₃ : ℝ) :
    0 < 1 + Real.exp (-d₁ / 2) + Real.exp (-d₂ / 2) + Real.exp (-d₃ / 2) := by
  have h1 := Real.exp_pos (-d₁ / 2)
  have h2 := Real.exp_pos (-d₂ / 2)
  have h3 := Real.exp_pos (-d₃ / 2)
  linarith

/-- The Akaike weight is a probability, and never reaches `1`. -/
theorem akaikeWeight_mem_Ioo (d₁ d₂ d₃ : ℝ) :
    akaikeWeight d₁ d₂ d₃ ∈ Set.Ioo (0:ℝ) 1 := by
  have hd := akaikeWeight_denom_pos d₁ d₂ d₃
  have h1 := Real.exp_pos (-d₁ / 2)
  have h2 := Real.exp_pos (-d₂ / 2)
  have h3 := Real.exp_pos (-d₃ / 2)
  constructor
  · exact div_pos one_pos hd
  · rw [akaikeWeight, div_lt_one hd]
    linarith

/-- Widening the first gap strengthens the winner. -/
theorem akaikeWeight_monotone_left {d₁ d₁' d₂ d₃ : ℝ} (h : d₁ ≤ d₁') :
    akaikeWeight d₁ d₂ d₃ ≤ akaikeWeight d₁' d₂ d₃ := by
  have hexp : Real.exp (-d₁' / 2) ≤ Real.exp (-d₁ / 2) := by
    apply Real.exp_le_exp.mpr; linarith
  have hd := akaikeWeight_denom_pos d₁' d₂ d₃
  simp only [akaikeWeight]
  gcongr

theorem akaikeWeight_monotone_mid {d₁ d₂ d₂' d₃ : ℝ} (h : d₂ ≤ d₂') :
    akaikeWeight d₁ d₂ d₃ ≤ akaikeWeight d₁ d₂' d₃ := by
  have hexp : Real.exp (-d₂' / 2) ≤ Real.exp (-d₂ / 2) := by
    apply Real.exp_le_exp.mpr; linarith
  have hd := akaikeWeight_denom_pos d₁ d₂' d₃
  simp only [akaikeWeight]
  gcongr

theorem akaikeWeight_monotone_right {d₁ d₂ d₃ d₃' : ℝ} (h : d₃ ≤ d₃') :
    akaikeWeight d₁ d₂ d₃ ≤ akaikeWeight d₁ d₂ d₃' := by
  have hexp : Real.exp (-d₃' / 2) ≤ Real.exp (-d₃ / 2) := by
    apply Real.exp_le_exp.mpr; linarith
  have hd := akaikeWeight_denom_pos d₁ d₂ d₃'
  simp only [akaikeWeight]
  gcongr

/-- A tied rival caps the weight at one half: a weight near `1` really does
require every rival to be beaten. -/
theorem akaikeWeight_lt_of_zero_gap (d₂ d₃ : ℝ) : akaikeWeight 0 d₂ d₃ < 1/2 := by
  have h2 := Real.exp_pos (-d₂ / 2)
  have h3 := Real.exp_pos (-d₃ / 2)
  have hd := akaikeWeight_denom_pos 0 d₂ d₃
  rw [akaikeWeight, div_lt_div_iff₀ hd (by norm_num)]
  simp only [neg_zero, zero_div, Real.exp_zero]
  linarith

/-- Uniform lower bound in terms of the smallest gap. -/
theorem akaikeWeight_ge_of_gaps {d d₁ d₂ d₃ : ℝ} (h1 : d ≤ d₁) (h2 : d ≤ d₂)
    (h3 : d ≤ d₃) :
    1 / (1 + 3 * Real.exp (-d / 2)) ≤ akaikeWeight d₁ d₂ d₃ := by
  have e1 : Real.exp (-d₁ / 2) ≤ Real.exp (-d / 2) := by
    apply Real.exp_le_exp.mpr; linarith
  have e2 : Real.exp (-d₂ / 2) ≤ Real.exp (-d / 2) := by
    apply Real.exp_le_exp.mpr; linarith
  have e3 : Real.exp (-d₃ / 2) ≤ Real.exp (-d / 2) := by
    apply Real.exp_le_exp.mpr; linarith
  have hd := akaikeWeight_denom_pos d₁ d₂ d₃
  have hpos : (0:ℝ) < 1 + 3 * Real.exp (-d / 2) := by
    have := Real.exp_pos (-d / 2); linarith
  rw [akaikeWeight, div_le_div_iff₀ hpos hd]
  linarith

/-- A rigorous numerical lower bound for `exp 4`. -/
theorem exp_four_ge : (54.59 : ℝ) ≤ Real.exp 4 := by
  have h : Real.exp 4 = (Real.exp 1) ^ (4:ℕ) := by
    rw [← Real.exp_nat_mul]; norm_num
  have he : (2.7182818283 : ℝ) < Real.exp 1 := Real.exp_one_gt_d9
  have hpow := pow_le_pow_left₀ (by norm_num : (0:ℝ) ≤ 2.7182818283) he.le 4
  rw [h]
  nlinarith [hpow]

/-- Turning a lower bound on `exp y` into an upper bound on `exp (-y)`. -/
theorem exp_neg_le_inv {y c : ℝ} (hc : 0 < c) (h : c ≤ Real.exp y) :
    Real.exp (-y) ≤ c⁻¹ := by
  rw [Real.exp_neg]
  exact inv_anti₀ hc h

/-- **The measured verdict.**  With `ΔAICc = 9.2, 11.5, 16.9` the Akaike weight
of the power law exceeds `0.98`. -/
theorem akaikeWeight_exp579_gt : 0.98 < akaikeWeight 9.2 11.5 16.9 := by
  have hd := akaikeWeight_denom_pos 9.2 11.5 16.9
  have he4 := exp_four_ge
  have b1 : Real.exp (-9.2 / 2) ≤ 0.0115 := by
    have hE : Real.exp (4.6 : ℝ) = Real.exp 4 * Real.exp (0.6 : ℝ) := by
      rw [← Real.exp_add]; norm_num
    have h06 : (1.6 : ℝ) ≤ Real.exp (0.6 : ℝ) := by
      have := Real.add_one_le_exp (0.6 : ℝ); linarith
    have hbig : (87 : ℝ) ≤ Real.exp (4.6 : ℝ) := by
      rw [hE]
      calc (87:ℝ) ≤ 54.59 * 1.6 := by norm_num
        _ ≤ Real.exp 4 * Real.exp (0.6:ℝ) :=
            mul_le_mul he4 h06 (by norm_num) (by positivity)
    have hrw : (-9.2 / 2 : ℝ) = -(4.6 : ℝ) := by norm_num
    rw [hrw]
    have := exp_neg_le_inv (by norm_num : (0:ℝ) < 87) hbig
    calc Real.exp (-(4.6:ℝ)) ≤ (87:ℝ)⁻¹ := this
      _ ≤ 0.0115 := by norm_num
  have b2 : Real.exp (-11.5 / 2) ≤ 0.0067 := by
    have hE : Real.exp (5.75 : ℝ) = Real.exp 4 * Real.exp (1.75 : ℝ) := by
      rw [← Real.exp_add]; norm_num
    have h175 : (2.75 : ℝ) ≤ Real.exp (1.75 : ℝ) := by
      have := Real.add_one_le_exp (1.75 : ℝ); linarith
    have hbig : (150 : ℝ) ≤ Real.exp (5.75 : ℝ) := by
      rw [hE]
      calc (150:ℝ) ≤ 54.59 * 2.75 := by norm_num
        _ ≤ Real.exp 4 * Real.exp (1.75:ℝ) :=
            mul_le_mul he4 h175 (by norm_num) (by positivity)
    have hrw : (-11.5 / 2 : ℝ) = -(5.75 : ℝ) := by norm_num
    rw [hrw]
    calc Real.exp (-(5.75:ℝ)) ≤ (150:ℝ)⁻¹ :=
          exp_neg_le_inv (by norm_num) hbig
      _ ≤ 0.0067 := by norm_num
  have b3 : Real.exp (-16.9 / 2) ≤ 0.00034 := by
    have hmono : Real.exp (-16.9 / 2) ≤ Real.exp (-(8:ℝ)) := by
      apply Real.exp_le_exp.mpr; norm_num
    have hE : Real.exp (8 : ℝ) = Real.exp 4 * Real.exp 4 := by
      rw [← Real.exp_add]; norm_num
    have hbig : (2980 : ℝ) ≤ Real.exp (8 : ℝ) := by
      rw [hE]
      calc (2980:ℝ) ≤ 54.59 * 54.59 := by norm_num
        _ ≤ Real.exp 4 * Real.exp 4 :=
            mul_le_mul he4 he4 (by norm_num) (by positivity)
    have := exp_neg_le_inv (by norm_num : (0:ℝ) < 2980) hbig
    calc Real.exp (-16.9 / 2) ≤ Real.exp (-(8:ℝ)) := hmono
      _ ≤ (2980:ℝ)⁻¹ := this
      _ ≤ 0.00034 := by norm_num
  rw [akaikeWeight, lt_div_iff₀ hd]
  linarith

/-- As every rival is pushed away the weight saturates at `1`. -/
theorem akaikeWeight_tendsto_one :
    Tendsto (fun d : ℝ => akaikeWeight d d d) atTop (𝓝 1) := by
  have hexp : Tendsto (fun d : ℝ => Real.exp (-d / 2)) atTop (𝓝 0) := by
    have h : Tendsto (fun d : ℝ => -d / 2) atTop atBot := by
      apply Filter.Tendsto.atBot_div_const (by norm_num)
      exact tendsto_neg_atTop_atBot
    exact Real.tendsto_exp_atBot.comp h
  have hden : Tendsto
      (fun d : ℝ => 1 + Real.exp (-d / 2) + Real.exp (-d / 2) + Real.exp (-d / 2))
      atTop (𝓝 1) := by
    have := ((tendsto_const_nhds (x := (1:ℝ)) (f := atTop)).add hexp).add hexp |>.add hexp
    simpa using this
  have := hden.inv₀ (by norm_num)
  simpa [akaikeWeight, one_div] using this

end ProfileForm