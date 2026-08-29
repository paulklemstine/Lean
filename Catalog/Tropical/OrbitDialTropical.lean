import Mathlib
import Tropical.OrbitDialCapLaw
import Tropical.OrbitDialWheel

/-!
# Tropicalisation of the dial calculus

Cycle 3 of the ORBIT-DIAL-CAP-TEST.  Dial speedups *multiply* when independent
structural exclusions are stacked, so their logarithms *add*: the natural home of the
dial calculus is the tropical semiring `Tropical ℝ`, where multiplication is addition of
weights and addition is `min`.

## Main results

* `OrbitDialCap.Trop.structural_speedup_mul` — stacking two sound (deterministic) dials
  multiplies their speedups: `1/(θ₁θ₂) = (1/θ₁)(1/θ₂)`.
* `OrbitDialCap.Trop.wheelSpeedup_mul` — for coprime moduli the wheel speedup is
  multiplicative, an instance of the Euler product `M/φ(M) = ∏ p/(p-1)`.
* `OrbitDialCap.Trop.tropWeight_mul` — the tropical weight `trop (log (M/φ(M)))` is a
  *monoid homomorphism* on coprime moduli: the Euler product becomes a tropical
  (additive) accounting.
* `OrbitDialCap.Trop.tropWeight_unbounded` — the structural weights are unbounded above.
* `OrbitDialCap.Trop.exchangeable_cap_closed_under_composition` and
  `OrbitDialCap.Trop.log_exchangeable_cap` — by contrast the *information-bearing*
  weights live in the bounded tropical window `[0, log (4/3)]`, and stacking exchangeable
  dials never leaves it.  This is the sharp form of the barrier-4 scope note.
-/

namespace OrbitDialCap
namespace Trop

open Wheel

/-- Stacking two independent sound exclusions multiplies the speedups. -/
theorem structural_speedup_mul (θ₁ θ₂ : ℝ) :
    dialSpeedup 1 (θ₁ * θ₂) = dialSpeedup 1 θ₁ * dialSpeedup 1 θ₂ := by
  rw [deterministic_speedup, deterministic_speedup, deterministic_speedup, mul_inv]

/-- **The cap is closed under composition.**  Stacking exchangeable dials produces
another exchangeable dial, whose speedup is still at most `4/3`: no amount of stacking
turns information-bearing filters into a barrier event. -/
theorem exchangeable_cap_closed_under_composition {θ₁ θ₂ : ℝ}
    (h₁ : 0 < θ₁) (h₁' : θ₁ ≤ 1) (h₂ : 0 < θ₂) (h₂' : θ₂ ≤ 1) :
    dialSpeedup (θ₁ * θ₂) (θ₁ * θ₂) ≤ 4 / 3 :=
  exchangeable_cap (mul_pos h₁ h₂) (by nlinarith)

/-- In logarithmic (tropical) coordinates the cap is the window `[0, log (4/3)]`. -/
theorem log_exchangeable_cap {θ : ℝ} (hθ : 0 < θ) (hθ1 : θ ≤ 1) :
    Real.log (dialSpeedup θ θ) ≤ Real.log (4 / 3) := by
  have hpos : 0 < dialCost θ θ := dialCost_pos hθ1 hθ.le hθ
  have hspos : 0 < dialSpeedup θ θ := by
    rw [dialSpeedup]; exact inv_pos.mpr hpos
  exact Real.log_le_log hspos (exchangeable_cap hθ hθ1)

/-- The wheel speedup is multiplicative on coprime moduli. -/
theorem wheelSpeedup_mul {M₁ M₂ : ℕ} (hcop : Nat.Coprime M₁ M₂) :
    wheelSpeedup (M₁ * M₂) = wheelSpeedup M₁ * wheelSpeedup M₂ := by
  rw [wheelSpeedup, wheelSpeedup, wheelSpeedup, Nat.totient_mul hcop]
  push_cast
  rw [div_mul_div_comm]

/-- Wheel speedups are at least `1`. -/
theorem one_le_wheelSpeedup {M : ℕ} (h : 0 < M) : 1 ≤ wheelSpeedup M := by
  have hφ : 0 < Nat.totient M := Nat.totient_pos.mpr h
  have hle : (Nat.totient M : ℝ) ≤ (M : ℝ) := by exact_mod_cast Nat.totient_le M
  rw [wheelSpeedup, le_div_iff₀ (by exact_mod_cast hφ), one_mul]
  exact hle

/-- The **tropical weight** of a wheel dial: its log-speedup, viewed in `Tropical ℝ`
where multiplication is addition of weights. -/
noncomputable def tropWeight (M : ℕ) : Tropical ℝ := Tropical.trop (Real.log (wheelSpeedup M))

/-- **Tropicalisation of the Euler product.**  On coprime moduli the tropical weight is
multiplicative in `Tropical ℝ`, i.e. log-speedups add. -/
theorem tropWeight_mul {M₁ M₂ : ℕ} (h₁ : 0 < M₁) (h₂ : 0 < M₂) (hcop : Nat.Coprime M₁ M₂) :
    tropWeight (M₁ * M₂) = tropWeight M₁ * tropWeight M₂ := by
  have hs₁ : 0 < wheelSpeedup M₁ := lt_of_lt_of_le zero_lt_one (one_le_wheelSpeedup h₁)
  have hs₂ : 0 < wheelSpeedup M₂ := lt_of_lt_of_le zero_lt_one (one_le_wheelSpeedup h₂)
  rw [tropWeight, tropWeight, tropWeight, wheelSpeedup_mul hcop,
    Real.log_mul hs₁.ne' hs₂.ne', Tropical.trop_add]

/-- Tropical addition of dial weights is the pessimistic (`min`) combination. -/
theorem tropWeight_add (M₁ M₂ : ℕ) :
    tropWeight M₁ + tropWeight M₂ =
      Tropical.trop (min (Real.log (wheelSpeedup M₁)) (Real.log (wheelSpeedup M₂))) := rfl

/-- Tropical weights of structural dials are nonnegative. -/
theorem tropWeight_nonneg {M : ℕ} (h : 0 < M) : 0 ≤ Tropical.untrop (tropWeight M) := by
  simpa [tropWeight] using Real.log_nonneg (one_le_wheelSpeedup h)

/-- **The structural window is unbounded.**  For every bound `B` some wheel has tropical
weight beyond `B`, while every information-bearing dial is confined to
`[0, log (4/3)]` by `log_exchangeable_cap`.  The two regimes are genuinely different
objects, not two points of one scale. -/
theorem tropWeight_unbounded (B : ℝ) :
    ∃ M : ℕ, 0 < M ∧ B < Tropical.untrop (tropWeight M) := by
  obtain ⟨s, hs, hlt⟩ := wheel_speedup_unbounded (Real.exp B)
  refine ⟨wheelModulus s, wheelModulus_pos hs, ?_⟩
  have hpos : 0 < wheelSpeedup (wheelModulus s) := lt_trans (Real.exp_pos B) hlt
  have : Real.log (Real.exp B) < Real.log (wheelSpeedup (wheelModulus s)) :=
    Real.log_lt_log (Real.exp_pos B) hlt
  rwa [Real.log_exp] at this

/-- **The scope note in tropical form.**  The exchangeable (information-bearing) dials
occupy the bounded weight window `[0, log (4/3)]`; the structural dials form an
unbounded set of weights; and the ORBIT arm's parity skip sits at weight `log 2`, above
the window yet with zero information. -/
theorem tropical_scope_note :
    (∀ θ : ℝ, 0 < θ → θ ≤ 1 → Real.log (dialSpeedup θ θ) ≤ Real.log (4 / 3)) ∧
    (∀ B : ℝ, ∃ M : ℕ, 0 < M ∧ B < Tropical.untrop (tropWeight M)) ∧
    Tropical.untrop (tropWeight 2) = Real.log 2 := by
  refine ⟨fun θ h h1 => log_exchangeable_cap h h1, tropWeight_unbounded, ?_⟩
  have h2 : wheelSpeedup 2 = 2 := (wheel_small_values).1
  simp [tropWeight, h2]

end Trop
end OrbitDialCap