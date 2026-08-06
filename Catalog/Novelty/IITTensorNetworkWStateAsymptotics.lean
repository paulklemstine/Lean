import Novelty.IITTensorNetworkWState

/-! # Monotonicity and asymptotics of the integrated information of the W state

The file `IITTensorNetworkWState.lean` computes the integrated information of
the `n`-qubit W state exactly,

`Φ(W_n) = 2 H₂(1/n)`,

where `H₂` is the binary entropy.  Here we analyse the resulting sequence.  The
W states form a family of matrix product states of *constant* bond dimension `2`
and *constant* Schmidt rank `2` across every cut, yet their integrated
information is strictly decreasing in `n` and tends to `0`; in fact

`2 log n / n ≤ Φ(W_n) ≤ 2 (log n + 1) / n`,  `n Φ(W_n) / (2 log n) → 1`.

This is the sharpest possible failure of the naive reading of the mission
conjecture ("`Φ` is determined by the Schmidt rank"): along this family the rank
data is frozen while `Φ` sweeps out a sequence converging to `0`.

Main results:

* `mul_binEntropy_inv` — the exact identity `x H₂(1/x) = log x + (x-1) log(x/(x-1))`;
* `phi_wState_strictAnti` — `Φ(W_m) < Φ(W_n)` for `2 ≤ n < m`;
* `phi_wState_lower_bound`, `phi_wState_upper_bound` — the two-sided estimate;
* `phi_wState_tendsto_zero` — `Φ(W_n) → 0`;
* `phi_wState_asymptotics` — `n Φ(W_n) / (2 log n) → 1`.
-/

open Filter Topology

namespace IITTensorNetwork

section BinaryEntropyAsymptotics

/-- Exact rewriting of `x · H₂(1/x)`:  `x H₂(1/x) = log x + (x-1) log (x/(x-1))`. -/
lemma mul_binEntropy_inv {x : ℝ} (hx : 2 ≤ x) :
    x * Real.binEntropy x⁻¹ = Real.log x + (x - 1) * Real.log (x / (x - 1)) := by
  have hx0 : (0:ℝ) < x := by linarith
  have hx1 : (0:ℝ) < x - 1 := by linarith
  rw [Real.binEntropy, inv_inv, show (1 - x⁻¹) = (x - 1) / x by field_simp, inv_div]
  field_simp

/-- The correction term in `mul_binEntropy_inv` is nonnegative. -/
lemma log_ratio_term_nonneg {x : ℝ} (hx : 2 ≤ x) :
    0 ≤ (x - 1) * Real.log (x / (x - 1)) := by
  have hx1 : (0:ℝ) < x - 1 := by linarith
  have hge : (1:ℝ) ≤ x / (x - 1) := by rw [le_div_iff₀ hx1]; linarith
  exact mul_nonneg hx1.le (Real.log_nonneg hge)

/-- The correction term in `mul_binEntropy_inv` is at most `1`, by `log t ≤ t - 1`. -/
lemma log_ratio_term_le_one {x : ℝ} (hx : 2 ≤ x) :
    (x - 1) * Real.log (x / (x - 1)) ≤ 1 := by
  have hx1 : (0:ℝ) < x - 1 := by linarith
  have h := Real.log_le_sub_one_of_pos (x := x / (x - 1)) (by positivity)
  rw [show x / (x - 1) - 1 = 1 / (x - 1) by field_simp; ring] at h
  calc (x - 1) * Real.log (x / (x - 1)) ≤ (x - 1) * (1 / (x - 1)) := by nlinarith
    _ = 1 := by field_simp

/-- Two-sided estimate for the binary entropy at `1/x`. -/
lemma binEntropy_inv_bounds {x : ℝ} (hx : 2 ≤ x) :
    Real.log x / x ≤ Real.binEntropy x⁻¹ ∧ Real.binEntropy x⁻¹ ≤ (Real.log x + 1) / x := by
  have hx0 : (0:ℝ) < x := by linarith
  have hid := mul_binEntropy_inv hx
  constructor
  · rw [div_le_iff₀ hx0, mul_comm]
    have := log_ratio_term_nonneg hx
    linarith [hid]
  · rw [le_div_iff₀ hx0, mul_comm]
    have := log_ratio_term_le_one hx
    linarith [hid]

/-- `H₂(1/n)` is strictly decreasing in `n` for `n ≥ 2`. -/
lemma binEntropy_inv_strictAnti {n m : ℕ} (hn : 2 ≤ n) (hnm : n < m) :
    Real.binEntropy ((m : ℝ)⁻¹) < Real.binEntropy ((n : ℝ)⁻¹) := by
  have hn2 : (2:ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
  have hm2 : (2:ℝ) ≤ (m : ℝ) := by exact_mod_cast le_trans hn (le_of_lt hnm)
  have hnpos : (0:ℝ) < (n : ℝ) := by linarith
  have hmpos : (0:ℝ) < (m : ℝ) := by linarith
  have hlt : ((m : ℝ))⁻¹ < ((n : ℝ))⁻¹ := by
    rw [inv_lt_inv₀ hmpos hnpos]
    exact_mod_cast hnm
  refine Real.binEntropy_strictMonoOn ⟨by positivity, ?_⟩ ⟨by positivity, ?_⟩ hlt
  · rw [inv_le_inv₀ hmpos (by norm_num)]; exact hm2
  · rw [inv_le_inv₀ hnpos (by norm_num)]; exact hn2

/-- `H₂(1/n) → 0` as `n → ∞`. -/
lemma tendsto_binEntropy_inv_zero :
    Tendsto (fun n : ℕ => Real.binEntropy ((n : ℝ)⁻¹)) atTop (𝓝 0) := by
  have h : Tendsto (fun n : ℕ => ((n : ℝ))⁻¹) atTop (𝓝 0) := tendsto_inv_atTop_nhds_zero_nat
  simpa using (Real.binEntropy_continuous.tendsto 0).comp h

/-- `n H₂(1/n) / log n → 1` as `n → ∞`. -/
theorem tendsto_mul_binEntropy_inv_div_log :
    Tendsto (fun n : ℕ => (n : ℝ) * Real.binEntropy ((n : ℝ)⁻¹) / Real.log n) atTop (𝓝 1) := by
  have hlim : Tendsto (fun n : ℕ => (n : ℝ) * Real.binEntropy ((n : ℝ)⁻¹) / Real.log n - 1)
      atTop (𝓝 0) := by
    have hinv : Tendsto (fun n : ℕ => (Real.log n)⁻¹) atTop (𝓝 0) :=
      Filter.Tendsto.inv_tendsto_atTop (Real.tendsto_log_atTop.comp tendsto_natCast_atTop_atTop)
    refine tendsto_of_tendsto_of_tendsto_of_le_of_le' tendsto_const_nhds hinv ?_ ?_ <;>
    · filter_upwards [eventually_ge_atTop 3] with n hn
      have hx : (2:ℝ) ≤ (n:ℝ) := by exact_mod_cast le_trans (by norm_num) hn
      have hlogpos : 0 < Real.log n := Real.log_pos (by linarith)
      have hsplit : (n : ℝ) * Real.binEntropy ((n : ℝ)⁻¹) / Real.log n - 1
          = ((n:ℝ) - 1) * Real.log ((n:ℝ) / ((n:ℝ) - 1)) / Real.log n := by
        rw [mul_binEntropy_inv hx, add_div, div_self hlogpos.ne']
        ring
      rw [hsplit]
      first
      | exact div_nonneg (log_ratio_term_nonneg hx) hlogpos.le
      | · rw [div_le_iff₀ hlogpos, inv_mul_cancel₀ hlogpos.ne']
          exact log_ratio_term_le_one hx
  simpa using hlim.add (tendsto_const_nhds (x := (1:ℝ)) (f := atTop (α := ℕ)))

end BinaryEntropyAsymptotics

section WStateAsymptotics

/-- The integrated information of the `n`-qubit W state, as a total function of `n`.
For `n ≥ 2` this agrees with `Φ` of the W state (`phiWState_eq_phi`). -/
noncomputable def phiWState (n : ℕ) : ℝ := 2 * Real.binEntropy ((n : ℝ)⁻¹)

/-- `phiWState n` is the integrated information of the W state for every `n ≥ 2`. -/
theorem phiWState_eq_phi {n : ℕ} (hn : 2 ≤ n) :
    phiWState n = Phi (wState_normalized (n := n) (by omega)) hn :=
  (phi_wState hn).symm

/-- **Strict monotonicity**: the integrated information of the W state strictly
decreases with the number of sites. -/
theorem phi_wState_strictAnti {n m : ℕ} (hn : 2 ≤ n) (hnm : n < m) :
    Phi (wState_normalized (n := m) (by omega)) (by omega : 2 ≤ m)
      < Phi (wState_normalized (n := n) (by omega)) hn := by
  rw [← phiWState_eq_phi, ← phiWState_eq_phi hn]
  unfold phiWState
  have := binEntropy_inv_strictAnti hn hnm
  linarith

/-- Lower bound `Φ(W_n) ≥ 2 log n / n`. -/
theorem phi_wState_lower_bound {n : ℕ} (hn : 2 ≤ n) :
    2 * Real.log n / n ≤ Phi (wState_normalized (n := n) (by omega)) hn := by
  rw [← phiWState_eq_phi hn]
  have hx : (2:ℝ) ≤ (n:ℝ) := by exact_mod_cast hn
  have h := (binEntropy_inv_bounds hx).1
  unfold phiWState
  rw [div_le_iff₀ (by linarith : (0:ℝ) < (n:ℝ))]
  rw [div_le_iff₀ (by linarith : (0:ℝ) < (n:ℝ))] at h
  linarith

/-- Upper bound `Φ(W_n) ≤ 2 (log n + 1) / n`. -/
theorem phi_wState_upper_bound {n : ℕ} (hn : 2 ≤ n) :
    Phi (wState_normalized (n := n) (by omega)) hn ≤ 2 * (Real.log n + 1) / n := by
  rw [← phiWState_eq_phi hn]
  have hx : (2:ℝ) ≤ (n:ℝ) := by exact_mod_cast hn
  have h := (binEntropy_inv_bounds hx).2
  unfold phiWState
  rw [le_div_iff₀ (by linarith : (0:ℝ) < (n:ℝ))]
  rw [le_div_iff₀ (by linarith : (0:ℝ) < (n:ℝ))] at h
  linarith

/-- **The integrated information of the W state tends to `0`**, although the Schmidt
rank and bond dimension stay equal to `2` at every cut. -/
theorem phi_wState_tendsto_zero : Tendsto phiWState atTop (𝓝 0) := by
  have := tendsto_binEntropy_inv_zero.const_mul (2:ℝ)
  simpa [phiWState] using this

/-- **Exact decay rate**: `n Φ(W_n) / (2 log n) → 1`, i.e. `Φ(W_n) = (2 log n)/n (1+o(1))`. -/
theorem phi_wState_asymptotics :
    Tendsto (fun n : ℕ => (n : ℝ) * phiWState n / (2 * Real.log n)) atTop (𝓝 1) := by
  have h := tendsto_mul_binEntropy_inv_div_log
  refine h.congr ?_
  intro n
  unfold phiWState
  rw [mul_comm (2:ℝ) (Real.log n)]
  rw [show (n : ℝ) * (2 * Real.binEntropy ((n : ℝ)⁻¹))
      = 2 * ((n : ℝ) * Real.binEntropy ((n : ℝ)⁻¹)) by ring]
  rw [mul_comm (Real.log (n:ℝ)) 2, mul_div_mul_left _ _ (two_ne_zero)]

end WStateAsymptotics

end IITTensorNetwork