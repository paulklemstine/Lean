/-
# Round-11 Closures, Part IV: DRHO — a constant factor is not an asymptotic gain

Formal companion to the round-11 negative-results synthesis
(`29_Round11_Closures.md`, hypothesis **DRHO**).

The experiment measured a *mean ratio ≈ 1.95* between the Dickman-policy
(early-abort batch) rho and classic rho, and the paper prices this as "no
asymptotic gain".  The mathematical content of that pricing is a limit statement
about exponents, and that is what is proved here:

`Round11.drho_exponent_invariance` — if a policy `T` is squeezed between a
baseline `T'` and `C · T'` for a constant `C ≥ 1`, with `T' → ∞`, then
```
log (T n) / log (T' n) → 1 ,
```
so the two policies have the *same* running-time exponent.  In particular a
uniform speedup by the measured factor `1.95` leaves the exponent untouched
(`Round11.drho_no_gain_of_constant_speedup`).

The complementary sanity check `Round11.exponent_gain_of_power_speedup` shows the
statement is sharp in the right way: a genuinely sub-*polynomial* replacement
`T = (T')^θ` does move the exponent to `θ`.  So the DRHO closure is a real
dichotomy — constant factors are free, exponents are not — not an artefact of the
formulation.
-/
import Mathlib

namespace Round11

open Filter Topology

/-- **DRHO, priced.**  A policy within a constant factor of the baseline has the
same running-time exponent: `log T / log T' → 1`. -/
theorem drho_exponent_invariance (T T' : ℕ → ℝ) (C : ℝ) (hC : 1 ≤ C)
    (h1 : ∀ n, 1 < T' n) (hle : ∀ n, T' n ≤ T n) (hge : ∀ n, T n ≤ C * T' n)
    (hT' : Tendsto T' atTop atTop) :
    Tendsto (fun n => Real.log (T n) / Real.log (T' n)) atTop (𝓝 1) := by
  have hlogpos : ∀ n, 0 < Real.log (T' n) := fun n => Real.log_pos (h1 n)
  have hlog : Tendsto (fun n => Real.log (T' n)) atTop atTop :=
    Real.tendsto_log_atTop.comp hT'
  have hupper : Tendsto (fun n => 1 + Real.log C / Real.log (T' n)) atTop (𝓝 1) := by
    have h0 : Tendsto (fun n => Real.log C / Real.log (T' n)) atTop (𝓝 0) :=
      Filter.Tendsto.div_atTop tendsto_const_nhds hlog
    simpa using tendsto_const_nhds.add h0
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le tendsto_const_nhds hupper ?_ ?_
  · intro n
    rw [le_div_iff₀ (hlogpos n), one_mul]
    exact Real.log_le_log (lt_trans zero_lt_one (h1 n)) (hle n)
  · intro n
    have hne : Real.log (T' n) ≠ 0 := (hlogpos n).ne'
    rw [div_le_iff₀ (hlogpos n)]
    have hCT : Real.log (T n) ≤ Real.log C + Real.log (T' n) := by
      have h2 : Real.log (T n) ≤ Real.log (C * T' n) :=
        Real.log_le_log (lt_of_lt_of_le (lt_trans zero_lt_one (h1 n)) (hle n)) (hge n)
      rwa [Real.log_mul (by linarith) (by linarith [h1 n])] at h2
    have hexp : (1 + Real.log C / Real.log (T' n)) * Real.log (T' n)
        = Real.log (T' n) + Real.log C := by
      field_simp
    rw [hexp]
    linarith

/-- The measured Dickman-policy speedup (a uniform constant factor, `≈ 1.95` in
experiment 351) leaves the exponent equal to `1`: no asymptotic gain. -/
theorem drho_no_gain_of_constant_speedup (T' : ℕ → ℝ) (C : ℝ) (hC : 1 ≤ C)
    (h1 : ∀ n, 1 < T' n) (hT' : Tendsto T' atTop atTop) :
    Tendsto (fun n => Real.log (C * T' n) / Real.log (T' n)) atTop (𝓝 1) := by
  refine drho_exponent_invariance (fun n => C * T' n) T' C hC h1 (fun n => ?_)
    (fun _ => le_rfl) hT'
  nlinarith [h1 n]

/-- **Sharpness of the pricing.**  A genuine polynomial-strength speedup does
change the exponent: if `T = (T')^θ` then `log T / log T' → θ`.  Constant factors
are free; exponents are not. -/
theorem exponent_gain_of_power_speedup (T' : ℕ → ℝ) (theta : ℝ)
    (h1 : ∀ n, 1 < T' n) :
    Tendsto (fun n => Real.log ((T' n) ^ theta) / Real.log (T' n)) atTop (𝓝 theta) := by
  have : ∀ n, Real.log ((T' n) ^ theta) / Real.log (T' n) = theta := by
    intro n
    rw [Real.log_rpow (lt_trans zero_lt_one (h1 n))]
    field_simp [(Real.log_pos (h1 n)).ne']
  simp [this]

end Round11