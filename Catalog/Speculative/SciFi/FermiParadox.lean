/-! # CatalogBuild.Speculative.SciFi.FermiParadox

Auto-generated from theorem catalog database.
Domain: Speculative/SciFi
Declarations: 6
-/

import Mathlib

/-- [Section: # CatalogBuild.Speculative.SciFi.FermiParadox
Auto-generated from theorem catalog database.
Domain: Speculative/SciFi
Declarations: 6] -/
theorem exponential_unbounded (N₀ : ℕ) (hN₀ : 0 < N₀) (r : ℕ) (hr : 1 < r) :
    ∀ M : ℕ, ∃ n : ℕ, M < N₀ * r ^ n := by
  exact fun M => by rcases pow_unbounded_of_one_lt ( M + 1 ) hr with ⟨ n, hn ⟩ ; exact ⟨ n, by nlinarith ⟩ ;



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


