/-
# Penrose–Hameroff Orchestrated Objective Reduction (Orch OR): the scaling laws

This file formalizes the *quantitative core* of the Penrose–Hameroff "Orch OR"
hypothesis of quantum consciousness.  In the hypothesis a **conscious event** is
the objective (gravitational) self-collapse of a quantum superposition sustained
across `N` tubulin proteins in neuronal microtubules.

Penrose's objective-reduction (OR) principle states that a superposition
collapses after a time inversely proportional to the gravitational self-energy
`E` of the mass separation:
`τ = ħ / E`.
For a superposition distributed over `N` tubulins the mission specifies the
threshold energy in the form
`E = ħ / (t · √N)`,
equivalently the predicted reduction ("coherence") time is
`t = ħ / (E · √N)`.

We take `ħ, E, t, N > 0` as positive reals and prove:

* `thresholdEnergy_mul` / `cohTime_mul` — the defining `E · t · √N = ħ` identity;
* `cohTime_thresholdEnergy` / `thresholdEnergy_cohTime` — the two formulas are
  mutual inverses;
* `cohTime_strictAnti_N` — the predicted coherence time is strictly decreasing in
  the number of tubulins `N` (more tubulins ⇒ faster collapse);
* `cohTime_tendsto_zero` — as `N → ∞` the coherence time tends to `0`;
* `orchOR_too_short` — a **concrete rational numerical bound**: with physical
  constants `ħ ≈ 1.055·10⁻³⁴ J·s`, thermal energy `E ≈ 4.28·10⁻²¹ J` and
  `N = 10¹¹` tubulins, the predicted coherence time is below `10⁻¹⁸ s`, i.e. more
  than fifteen orders of magnitude shorter than the `≈ 0.5 s` gamma-synchrony
  timescale of a conscious moment.  This is the quantitative content of the
  standard (Tegmark-style) objection that microtubule superpositions decohere far
  too quickly at body temperature.

The physical numbers are the mission's; the mathematics is exact.
-/
import Mathlib

open Filter Topology

namespace OrchOR

/-- Penrose objective-reduction time `τ = ħ / E` for gravitational self-energy `E`. -/
noncomputable def orTime (hbar E : ℝ) : ℝ := hbar / E

/-- Orch OR threshold energy `E = ħ / (t · √N)` for a superposition of `N`
tubulins collapsing in time `t`. -/
noncomputable def thresholdEnergy (hbar t N : ℝ) : ℝ := hbar / (t * Real.sqrt N)

/-- Predicted coherence / reduction time `t = ħ / (E · √N)` at self-energy `E`
across `N` tubulins. -/
noncomputable def cohTime (hbar E N : ℝ) : ℝ := hbar / (E * Real.sqrt N)

section Basic
variable {hbar E t N : ℝ}

theorem orTime_pos (hb : 0 < hbar) (hE : 0 < E) : 0 < orTime hbar E :=
  div_pos hb hE

theorem thresholdEnergy_pos (hb : 0 < hbar) (ht : 0 < t) (hN : 0 < N) :
    0 < thresholdEnergy hbar t N :=
  div_pos hb (mul_pos ht (Real.sqrt_pos.mpr hN))

theorem cohTime_pos (hb : 0 < hbar) (hE : 0 < E) (hN : 0 < N) :
    0 < cohTime hbar E N :=
  div_pos hb (mul_pos hE (Real.sqrt_pos.mpr hN))

/-- The fundamental Orch OR identity `E · (t · √N) = ħ`. -/
theorem thresholdEnergy_mul (ht : 0 < t) (hN : 0 < N) :
    thresholdEnergy hbar t N * (t * Real.sqrt N) = hbar := by
  have hs : 0 < Real.sqrt N := Real.sqrt_pos.mpr hN
  unfold thresholdEnergy
  rw [div_mul_cancel₀]
  positivity

/-- The dual identity `t · (E · √N) = ħ` for the coherence-time formula. -/
theorem cohTime_mul (hE : 0 < E) (hN : 0 < N) :
    cohTime hbar E N * (E * Real.sqrt N) = hbar := by
  have hs : 0 < Real.sqrt N := Real.sqrt_pos.mpr hN
  unfold cohTime
  rw [div_mul_cancel₀]
  positivity

/-- The coherence-time and threshold-energy formulas are mutual inverses:
plugging the threshold energy into the coherence-time formula returns `t`. -/
theorem cohTime_thresholdEnergy (hb : 0 < hbar) (ht : 0 < t) (hN : 0 < N) :
    cohTime hbar (thresholdEnergy hbar t N) N = t := by
  have hs : 0 < Real.sqrt N := Real.sqrt_pos.mpr hN
  have hb0 : hbar ≠ 0 := ne_of_gt hb
  unfold cohTime thresholdEnergy
  field_simp

/-- The dual inverse relation: plugging the coherence time into the
threshold-energy formula returns `E`. -/
theorem thresholdEnergy_cohTime (hb : 0 < hbar) (hE : 0 < E) (hN : 0 < N) :
    thresholdEnergy hbar (cohTime hbar E N) N = E := by
  have hs : 0 < Real.sqrt N := Real.sqrt_pos.mpr hN
  have hb0 : hbar ≠ 0 := ne_of_gt hb
  unfold thresholdEnergy cohTime
  field_simp

end Basic

section Monotone
variable {hbar E : ℝ}

/-- **More tubulins collapse faster.**  For fixed `ħ, E > 0` the predicted
coherence time `ħ / (E·√N)` is strictly decreasing in the tubulin count `N`. -/
theorem cohTime_strictAnti_N (hb : 0 < hbar) (hE : 0 < E)
    {N M : ℝ} (hN : 0 < N) (hNM : N < M) :
    cohTime hbar E M < cohTime hbar E N := by
  unfold cohTime
  have hsN : 0 < Real.sqrt N := Real.sqrt_pos.mpr hN
  have hsM : Real.sqrt N < Real.sqrt M := Real.sqrt_lt_sqrt hN.le hNM
  apply div_lt_div_of_pos_left hb
  · positivity
  · nlinarith [hsN, hsM]

/-- **Coherence collapses at scale.**  As the number of tubulins `N → ∞` the
predicted Orch OR coherence time tends to `0`. -/
theorem cohTime_tendsto_zero (hE : 0 < E) :
    Tendsto (fun n : ℕ => cohTime hbar E n) atTop (𝓝 0) := by
  have h1 : Tendsto (fun n : ℕ => E * Real.sqrt n) atTop atTop := by
    apply Filter.Tendsto.const_mul_atTop hE
    exact (Real.tendsto_sqrt_atTop).comp tendsto_natCast_atTop_atTop
  simpa [cohTime] using h1.const_div_atTop hbar

end Monotone

/-- **The Orch OR timescale is far too short at body temperature.**

With the reduced Planck constant `ħ ≈ 1.055·10⁻³⁴ J·s`, the room-temperature
thermal energy scale `E ≈ 4.28·10⁻²¹ J` (`k_B · 310 K`), and `N = 10¹¹`
tubulins, the predicted coherence time is below `10⁻¹⁸ s` — dwarfed by the
`≈ 0.5 s` gamma-synchrony timescale associated with a conscious moment.  This is
the exact quantitative form of the standard objection to warm quantum
consciousness. -/
theorem orchOR_too_short :
    cohTime (1055 / 10 ^ 37) (428 / 10 ^ 23) (10 ^ 11) < 1 / 10 ^ 18 := by
  unfold cohTime
  have hsqrt : (3 * 10 ^ 5 : ℝ) ≤ Real.sqrt (10 ^ 11) := by
    rw [show (3 * 10 ^ 5 : ℝ) = Real.sqrt ((3 * 10 ^ 5) ^ 2) by
          rw [Real.sqrt_sq]; positivity]
    apply Real.sqrt_le_sqrt; norm_num
  have hden : (428 / 10 ^ 23 : ℝ) * (3 * 10 ^ 5) ≤ (428 / 10 ^ 23) * Real.sqrt (10 ^ 11) :=
    mul_le_mul_of_nonneg_left hsqrt (by norm_num)
  have hpos : (0 : ℝ) < (428 / 10 ^ 23) * (3 * 10 ^ 5) := by norm_num
  calc (1055 / 10 ^ 37 : ℝ) / ((428 / 10 ^ 23) * Real.sqrt (10 ^ 11))
      ≤ (1055 / 10 ^ 37) / ((428 / 10 ^ 23) * (3 * 10 ^ 5)) :=
        div_le_div_of_nonneg_left (by norm_num) hpos hden
    _ < 1 / 10 ^ 18 := by norm_num

/-- The predicted Orch OR coherence time at body temperature and `N = 10¹¹`
tubulins is far shorter than the `0.5 s` gamma-synchrony timescale of a conscious
moment: the microtubule superposition cannot survive long enough to
"orchestrate" anything. -/
theorem orchOR_shorter_than_gamma :
    cohTime (1055 / 10 ^ 37) (428 / 10 ^ 23) (10 ^ 11) < (1 / 2 : ℝ) := by
  have h := orchOR_too_short
  have : (1 / 10 ^ 18 : ℝ) < 1 / 2 := by norm_num
  linarith

end OrchOR