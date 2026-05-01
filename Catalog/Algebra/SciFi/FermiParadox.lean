import Mathlib

/-! # CatalogBuild.Speculative.SciFi.FermiParadox

Auto-generated from theorem catalog database.
Domain: Speculative/SciFi
Declarations: 10
-/

/-- [Section: # CatalogBuild.Speculative.SciFi.FermiParadox
Auto-generated from theorem catalog database.
Domain: Speculative/SciFi
Declarations: 10] -/
theorem exponential_unbounded (N₀ : ℕ) (hN₀ : 0 < N₀) (r : ℕ) (hr : 1 < r) :
    ∀ M : ℕ, ∃ n : ℕ, M < N₀ * r ^ n := by
  exact fun M => by rcases pow_unbounded_of_one_lt ( M + 1 ) hr with ⟨ n, hn ⟩ ; exact ⟨ n, by nlinarith ⟩ ;

/-- [Section: # CatalogBuild.Speculative.SciFi.FermiParadox
Auto-generated from theorem catalog database.
Domain: Speculative/SciFi
Declarations: 10] -/
theorem exponential_strictly_monotone (r : ℝ) (hr : 1 < r) :
    StrictMono (fun n : ℕ => r ^ n) := by
  exact fun a b hab => pow_lt_pow_right₀ hr hab

theorem drake_linear_in_factor (a b c : ℝ) (ha : 0 < a) (hb : 0 < b) :
    2 * (a * b * c) = a * b * (2 * c) := by
  ring

theorem posterior_sums_to_one (p_H1 p_H2 p_E_H1 p_E_H2 : ℝ)
    (h_prior : p_H1 + p_H2 = 1) (h_pos : 0 < p_E_H1 * p_H1 + p_E_H2 * p_H2)
    (h_nonneg1 : 0 ≤ p_E_H1) (h_nonneg2 : 0 ≤ p_E_H2)
    (h_nonneg3 : 0 ≤ p_H1) (h_nonneg4 : 0 ≤ p_H2) :
    (p_E_H1 * p_H1) / (p_E_H1 * p_H1 + p_E_H2 * p_H2) +
    (p_E_H2 * p_H2) / (p_E_H1 * p_H1 + p_E_H2 * p_H2) = 1 := by
  rw [ ← add_div, div_self h_pos.ne' ]

theorem detection_probability_monotone (p : ℝ) (hp : 0 < p) (hp1 : p < 1) :
    StrictMono (fun n : ℕ => 1 - (1 - p) ^ n) := by
  exact fun n m hnm => sub_lt_sub_left ( pow_lt_pow_right_of_lt_one₀ ( by linarith ) ( by linarith ) hnm ) _

theorem detection_limit (p : ℝ) (hp : 0 < p) (hp1 : p < 1) (ε : ℝ) (hε : 0 < ε) :
    ∃ n : ℕ, (1 - p) ^ n < ε := by
  exact exists_pow_lt_of_lt_one hε ( by linarith )

noncomputable section

/-- [Section: # CatalogBuild.Speculative.SciFi.FermiParadox
Auto-generated from theorem catalog database.
Domain: Speculative/SciFi
Declarations: 10] -/
theorem exp_growth_increasing (r : ℝ) (hr : 0 < r) (N₀ : ℝ) (hN₀ : 0 < N₀) :
    StrictMono (fun t => N₀ * Real.exp (r * t)) := by
  exact fun t t' h => mul_lt_mul_of_pos_left ( Real.exp_lt_exp.mpr ( mul_lt_mul_of_pos_left h hr ) ) hN₀

/-- [Section: # CatalogBuild.Speculative.SciFi.FermiParadox
Auto-generated from theorem catalog database.
Domain: Speculative/SciFi
Declarations: 10] -/
theorem exp_growth_unbounded (r : ℝ) (hr : 0 < r) (N₀ : ℝ) (hN₀ : 0 < N₀)
    (M : ℝ) : ∃ t : ℝ, M < N₀ * Real.exp (r * t) := by
  exact ⟨ ( M / N₀ + 1 ) / r, by nlinarith [ Real.add_one_le_exp ( r * ( ( M / N₀ + 1 ) / r ) ), mul_div_cancel₀ ( M / N₀ + 1 ) hr.ne', mul_div_cancel₀ M hN₀.ne' ] ⟩

/-- The Drake equation: N is linear in L (civilization lifetime). -/
theorem drake_linear_in_L (R fp ne fl fi fc : ℝ) :
    ∀ L₁ L₂ : ℝ, (R * fp * ne * fl * fi * fc * (2 * L₁)) =
    2 * (R * fp * ne * fl * fi * fc * L₁) := by
  intro L₁ L₂
  ring

theorem great_filter_bayesian
    (p_behind p_ahead : ℝ)
    (p_silence_behind p_silence_ahead : ℝ)
    (h_prior : p_behind + p_ahead = 1)
    (h_nonneg_b : 0 ≤ p_behind) (h_nonneg_a : 0 ≤ p_ahead)
    (h_more_silent : p_silence_ahead > p_silence_behind)
    (h_pos_b : 0 < p_silence_behind) (h_pos_a : 0 < p_silence_ahead)
    (h_pos_behind : 0 < p_behind) (h_pos_ahead : 0 < p_ahead)
    (p_silence : ℝ)
    (h_total : p_silence = p_silence_behind * p_behind + p_silence_ahead * p_ahead)
    (h_pos_silence : 0 < p_silence) :
    p_silence_ahead * p_ahead / p_silence > p_ahead := by
  field_simp;
  nlinarith

end
