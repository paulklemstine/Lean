import Mathlib
import Catalog.Shared.RainbowAPSpectrumAsymptotics

/-!
# The rainbow pair-spectrum threshold `T_k` and its exact `Θ(k² log k)` growth

Fix a palette of `k` colours.  A colouring of a block-decomposed interval realises the
*full pair spectrum* if every one of the `k²` ordered colour pairs `(i, j)` occurs on some
2-term arithmetic progression of the decomposition.  `T k` is the least number of blocks at
which a strict majority of colourings has full pair spectrum; formally it is the full-spectrum
threshold of the alphabet `Fin k × Fin k`.

Main results.

* `RainbowAP.T_lower_bound` : `2 k² log k - 2 log k ≤ T k`.
* `RainbowAP.T_upper_bound` : `T k ≤ 2 k² log k + k² log 2 + 1`.
* `RainbowAP.T_theta`       : explicit constants `c₁ = 1`, `c₂ = 4` with
  `0.1 ≤ c₁ ≤ c₂ ≤ 10` sandwiching `T k` between `c₁ k² log k` and `c₂ k² log k` for `k ≥ 2`.
* `RainbowAP.T_tendsto_two` : `T k / (k² log k) → 2`, so the optimal constants coincide,
  `c₁ = c₂ = 2`.
* `RainbowAP.T_liminf`, `RainbowAP.T_limsup` : the `lim inf` and the `lim sup` both equal `2`.
-/

open Finset Real Filter Topology

namespace RainbowAP

/-- The rainbow pair-spectrum threshold with `k` colours. -/
noncomputable def T (k : ℕ) : ℕ := spectrumThreshold (Fin k × Fin k)

lemma card_pair_alphabet (k : ℕ) : Fintype.card (Fin k × Fin k) = k ^ 2 := by
  simp [Fintype.card_prod, sq]

lemma card_pair_alphabet_ge (k : ℕ) (hk : 2 ≤ k) : 2 ≤ Fintype.card (Fin k × Fin k) := by
  rw [card_pair_alphabet]
  nlinarith

/-- **Lower bound**: `T k ≥ 2 k² log k - 2 log k`. -/
theorem T_lower_bound (k : ℕ) (hk : 2 ≤ k) :
    2 * (k : ℝ) ^ 2 * Real.log k - 2 * Real.log k ≤ (T k : ℝ) := by
  rw [T]
  have hbase := le_spectrumThreshold (α := Fin k × Fin k) (card_pair_alphabet_ge k hk)
  rw [card_pair_alphabet] at hbase
  have hkR : (2 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk
  have hk2 : (1 : ℝ) ≤ ((k : ℝ)) ^ 2 - 1 := by nlinarith
  have hlogk : (0 : ℝ) ≤ Real.log k := Real.log_nonneg (by linarith)
  have hlog : 2 * Real.log k ≤ Real.log (((k : ℝ) ^ 2) + 1) := by
    have h1 : Real.log ((k : ℝ) ^ 2) = 2 * Real.log k := by
      rw [Real.log_pow]
      push_cast
      ring
    have h2 : Real.log ((k : ℝ) ^ 2) ≤ Real.log (((k : ℝ) ^ 2) + 1) := by
      apply Real.log_le_log (by positivity)
      linarith
    linarith
  have hcast : ((((k ^ 2 : ℕ)) : ℝ)) = ((k : ℝ)) ^ 2 := by push_cast; ring
  rw [hcast] at hbase
  nlinarith [hbase, hlog, hk2, hlogk]

/-- **Upper bound**: `T k ≤ 2 k² log k + k² log 2 + 1`. -/
theorem T_upper_bound (k : ℕ) (hk : 2 ≤ k) :
    (T k : ℝ) ≤ 2 * (k : ℝ) ^ 2 * Real.log k + (k : ℝ) ^ 2 * Real.log 2 + 1 := by
  rw [T]
  have hbase := spectrumThreshold_le (α := Fin k × Fin k) (card_pair_alphabet_ge k hk)
  rw [card_pair_alphabet] at hbase
  have hkR : (2 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk
  have hcast : ((((k ^ 2 : ℕ)) : ℝ)) = ((k : ℝ)) ^ 2 := by push_cast; ring
  rw [hcast] at hbase
  have hsplit : Real.log (2 * (k : ℝ) ^ 2) = Real.log 2 + 2 * Real.log k := by
    rw [Real.log_mul (by norm_num) (by positivity), Real.log_pow]
    push_cast
    ring
  rw [hsplit] at hbase
  nlinarith [hbase]

/-- **The `Θ(k² log k)` theorem with explicit computable constants.**
For every `k ≥ 2` the threshold is sandwiched between `1 · k² log k` and `4 · k² log k`,
and the two constants lie in `[0.1, 10]`. -/
theorem T_theta :
    ∃ c₁ c₂ : ℝ, 0.1 ≤ c₁ ∧ c₁ ≤ c₂ ∧ c₂ ≤ 10 ∧
      (∀ k : ℕ, 2 ≤ k → c₁ * ((k : ℝ) ^ 2 * Real.log k) ≤ (T k : ℝ)) ∧
      (∀ k : ℕ, 2 ≤ k → (T k : ℝ) ≤ c₂ * ((k : ℝ) ^ 2 * Real.log k)) := by
  refine ⟨1, 4, by norm_num, by norm_num, by norm_num, ?_, ?_⟩
  · intro k hk
    have hlow := T_lower_bound k hk
    have hkR : (2 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk
    have hlogk : (0 : ℝ) ≤ Real.log k := Real.log_nonneg (by linarith)
    have hk2 : (0 : ℝ) ≤ (k : ℝ) ^ 2 - 2 := by nlinarith
    nlinarith [hlow, hlogk, mul_nonneg hk2 hlogk]
  · intro k hk
    have hup := T_upper_bound k hk
    have hkR : (2 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk
    have hlog2 : (0.6931471803 : ℝ) < Real.log 2 := Real.log_two_gt_d9
    have hlogk : Real.log 2 ≤ Real.log k := Real.log_le_log (by norm_num) hkR
    have hk4 : (4 : ℝ) ≤ (k : ℝ) ^ 2 := by nlinarith
    nlinarith [hup, hlog2, hlogk, hk4]

/-- The exact asymptotic constant: `T k / (k² log k) → 2`. -/
theorem T_tendsto_two :
    Tendsto (fun k : ℕ => (T k : ℝ) / ((k : ℝ) ^ 2 * Real.log k)) atTop (𝓝 2) := by
  have hnat : Tendsto (fun k : ℕ => (k : ℝ)) atTop atTop := tendsto_natCast_atTop_atTop
  have hsq : Tendsto (fun k : ℕ => (k : ℝ) ^ 2) atTop atTop := by
    have := hnat.atTop_mul_atTop₀ hnat
    simpa [sq] using this
  have hlog : Tendsto (fun k : ℕ => Real.log k) atTop atTop :=
    Real.tendsto_log_atTop.comp hnat
  have hprod : Tendsto (fun k : ℕ => (k : ℝ) ^ 2 * Real.log k) atTop atTop :=
    hsq.atTop_mul_atTop₀ hlog
  have hinvsq : Tendsto (fun k : ℕ => 2 / (k : ℝ) ^ 2) atTop (𝓝 0) := by
    simpa using hsq.const_div_atTop (2 : ℝ)
  have hinvlog : Tendsto (fun k : ℕ => Real.log 2 / Real.log k) atTop (𝓝 0) := by
    simpa using hlog.const_div_atTop (Real.log 2)
  have hinvprod : Tendsto (fun k : ℕ => 1 / ((k : ℝ) ^ 2 * Real.log k)) atTop (𝓝 0) := by
    simpa using hprod.const_div_atTop (1 : ℝ)
  have hlow : Tendsto (fun k : ℕ => 2 - 2 / (k : ℝ) ^ 2) atTop (𝓝 2) := by
    have := (tendsto_const_nhds (x := (2 : ℝ)) (f := atTop (α := ℕ))).sub hinvsq
    simpa using this
  have hupp : Tendsto
      (fun k : ℕ => 2 + Real.log 2 / Real.log k + 1 / ((k : ℝ) ^ 2 * Real.log k))
      atTop (𝓝 2) := by
    have h1 := (tendsto_const_nhds (x := (2 : ℝ)) (f := atTop (α := ℕ))).add hinvlog
    have h2 := h1.add hinvprod
    simpa using h2
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le' hlow hupp ?_ ?_
  · filter_upwards [eventually_ge_atTop 2] with k hk
    have hkR : (2 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk
    have hlogk : (0 : ℝ) < Real.log k := Real.log_pos (by linarith)
    have hD : (0 : ℝ) < (k : ℝ) ^ 2 * Real.log k := by positivity
    rw [le_div_iff₀ hD]
    have hlow := T_lower_bound k hk
    have hsq2 : (0 : ℝ) < (k : ℝ) ^ 2 := by positivity
    have hexp : (2 - 2 / (k : ℝ) ^ 2) * ((k : ℝ) ^ 2 * Real.log k)
        = 2 * (k : ℝ) ^ 2 * Real.log k - 2 * Real.log k := by
      field_simp
    rw [hexp]
    exact hlow
  · filter_upwards [eventually_ge_atTop 2] with k hk
    have hkR : (2 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk
    have hlogk : (0 : ℝ) < Real.log k := Real.log_pos (by linarith)
    have hD : (0 : ℝ) < (k : ℝ) ^ 2 * Real.log k := by positivity
    rw [div_le_iff₀ hD]
    have hup := T_upper_bound k hk
    have hexp : (2 + Real.log 2 / Real.log k + 1 / ((k : ℝ) ^ 2 * Real.log k))
        * ((k : ℝ) ^ 2 * Real.log k)
        = 2 * (k : ℝ) ^ 2 * Real.log k + (k : ℝ) ^ 2 * Real.log 2 + 1 := by
      field_simp
    rw [hexp]
    exact hup

/-- The `lim inf` of `T k / (k² log k)` equals `2`. -/
theorem T_liminf :
    liminf (fun k : ℕ => (T k : ℝ) / ((k : ℝ) ^ 2 * Real.log k)) atTop = 2 :=
  T_tendsto_two.liminf_eq

/-- The `lim sup` of `T k / (k² log k)` equals `2`. -/
theorem T_limsup :
    limsup (fun k : ℕ => (T k : ℝ) / ((k : ℝ) ^ 2 * Real.log k)) atTop = 2 :=
  T_tendsto_two.limsup_eq

end RainbowAP