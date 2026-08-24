import Novelty.KneePhaseCoordinate
import Novelty.AttentionRetentionKnee

/-!
# What the narrowing means for attention rates (NET-87, round 31, cycle 3)

`Novelty.KneeDomainNarrowing` and `Novelty.KneePhaseCoordinate` treat the knee
laws as given.  This file pushes the NET-87 verdict down to the *attention decay
rate*, using the exact tail calculus of `Novelty.AttentionRetentionKnee`
(`kneeCts lam delta = log(1/delta) / lam`, exact by `exp_tail_le_iff`).

Three consequences, all elementary but all sharp.

* **The domain factor is an inverse rate ratio** (`domain_factor_eq_rate_ratio`):
  `K_code / K_prose = lam_prose / lam_code`.  So "code is protected" says exactly
  that code attention is *more peaked* than prose attention, and the narrowing
  `0.75 → 0.80` says the peakedness advantage of code is shrinking:
  `4/3 → 5/4` (`net87_peakedness_ratios`).  Permanent protection is the
  statement that the advantage never falls to `6/5`
  (`peakedness_advantage_permanent`).

* **The measured chain pins the rates** (`rates_from_code_chain`): with the code
  chain `12, 16, 32`, `4 lam₁ = 3 lam₀` and `8 lam₃ = 3 lam₀`.  Hence
  `lam₃ = (3/8) lam₀ < lam₀ / 2` (`acceleration_superharmonic`): the decay rate
  degrades strictly faster than the affine-knee (harmonic) prediction.

* **No generalised harmonic rate family fits** (`no_generalized_harmonic_rate`):
  no family `lam_j = C / (j + c)` — the class that `rate_of_increment` shows is
  equivalent to an additive keys-per-doubling law — reproduces `12, 16, 32`.
  The acceleration is a statement about the *shape* of rate degradation, not
  about its scale.
-/

namespace Catalog.Novelty.KneeRateAcceleration

open Catalog.Novelty.AttentionRetentionKnee Catalog.Novelty.KneeDilutionGrid

/-! ### 1. The domain factor is an inverse ratio of decay rates -/

/-- **The domain factor is the inverse ratio of decay rates.**  For exponential
tails with the same budget `delta`, the ratio of key requirements is the
*reciprocal* ratio of the decay rates: a cheaper domain is a more peaked one. -/
theorem domain_factor_eq_rate_ratio {lamc lamp delta : ℝ} (hc : lamc ≠ 0) (hp : lamp ≠ 0)
    (hL : Real.log (1 / delta) ≠ 0) :
    kneeCts lamc delta / kneeCts lamp delta = lamp / lamc := by
  simp only [kneeCts]
  field_simp

/-- **The peakedness advantage of code, measured.**  At ctx 512 the code/prose
factor `12/16` says code attention is `4/3` times as peaked; at ctx 4096 the
factor `32/40` says only `5/4`.  The advantage is shrinking — this is the
narrowing domain factor, read on the rates. -/
theorem net87_peakedness_ratios {lamc lamp delta : ℝ} (hc : lamc ≠ 0) (hp : lamp ≠ 0)
    (hL : Real.log (1 / delta) ≠ 0)
    (hkc : kneeCts lamc delta = 32) (hkp : kneeCts lamp delta = 40) :
    lamc / lamp = 5 / 4 ∧ (5 : ℝ) / 4 < 4 / 3 := by
  have hratio : kneeCts lamc delta / kneeCts lamp delta = lamp / lamc :=
    domain_factor_eq_rate_ratio hc hp hL
  rw [hkc, hkp] at hratio
  have hpc : lamp / lamc = 4 / 5 := by rw [← hratio]; norm_num
  have hinv : lamc / lamp = (lamp / lamc)⁻¹ := (inv_div lamp lamc).symm
  rw [hinv, hpc]
  norm_num

/-- **The peakedness advantage never closes.**  Under the measured fit the prose
knee always exceeds `6/5` times the code knee, i.e. code attention stays at least
`6/5` times as peaked as prose at every context — the rate-level form of
`protection_permanent`. -/
theorem peakedness_advantage_permanent {T : ℝ} (hT : 0 ≤ T) :
    6 / 5 < kneeLaw 16 24 T / kneeLaw 12 20 T := by
  have hcpos : 0 < kneeLaw 12 20 T := by
    have : 0 ≤ (20 : ℝ) * T := by positivity
    simp only [kneeLaw]; linarith
  have hppos : 0 < kneeLaw 16 24 T := by
    have : 0 ≤ (24 : ℝ) * T := by positivity
    simp only [kneeLaw]; linarith
  have hlt : domainRatio 12 20 16 24 T < 5 / 6 :=
    (net87_measured_fit.2.2.2.2.2.2.2.2) T hT
  rw [domainRatio, div_lt_div_iff₀ hppos (by norm_num)] at hlt
  rw [lt_div_iff₀ hcpos]
  linarith

/-! ### 2. The measured chain pins the decay rates -/

/-- The exact tail calculus turns a knee value into a rate equation. -/
lemma log_eq_of_kneeCts {lam delta K : ℝ} (hlam : lam ≠ 0) (h : kneeCts lam delta = K) :
    Real.log (1 / delta) = K * lam := by
  rw [kneeCts, div_eq_iff hlam] at h
  exact h

/-- **The code chain pins the rate degradation.**  From `12, 16, 32` at
`j = 0, 1, 3` one gets `4 lam₁ = 3 lam₀` and `8 lam₃ = 3 lam₀`: the rate has
fallen to three eighths of its short-context value by ctx 4096. -/
theorem rates_from_code_chain {delta : ℝ} {lam : ℕ → ℝ}
    (h0 : lam 0 ≠ 0) (h1 : lam 1 ≠ 0) (h3 : lam 3 ≠ 0)
    (k0 : kneeCts (lam 0) delta = 12) (k1 : kneeCts (lam 1) delta = 16)
    (k3 : kneeCts (lam 3) delta = 32) :
    4 * lam 1 = 3 * lam 0 ∧ 8 * lam 3 = 3 * lam 0 := by
  have e0 := log_eq_of_kneeCts h0 k0
  have e1 := log_eq_of_kneeCts h1 k1
  have e3 := log_eq_of_kneeCts h3 k3
  constructor
  · have : (16 : ℝ) * lam 1 = 12 * lam 0 := by rw [← e1, ← e0]
    linarith
  · have : (32 : ℝ) * lam 3 = 12 * lam 0 := by rw [← e3, ← e0]
    linarith

/-- **The acceleration is super-harmonic degradation.**  An affine knee law would
put the ctx-4096 rate at `lam₀ / 2` (knee `24 = 2 × 12`); the measured knee `32`
forces `lam₃ = (3/8) lam₀`, strictly below that. -/
theorem acceleration_superharmonic {delta : ℝ} {lam : ℕ → ℝ}
    (hpos : 0 < lam 0) (h1 : lam 1 ≠ 0) (h3 : lam 3 ≠ 0)
    (k0 : kneeCts (lam 0) delta = 12) (k1 : kneeCts (lam 1) delta = 16)
    (k3 : kneeCts (lam 3) delta = 32) :
    lam 3 = 3 / 8 * lam 0 ∧ lam 3 < lam 0 / 2 := by
  obtain ⟨-, h8⟩ := rates_from_code_chain (ne_of_gt hpos) h1 h3 k0 k1 k3
  constructor
  · linarith
  · linarith

/-! ### 3. No generalised harmonic rate family fits the chain -/

/-- **The rate law is not of harmonic shape.**  `rate_of_increment` shows that an
additive keys-per-doubling law is *equivalent* to a rate family
`lam_j = C / (j + c)`.  The measured code chain `12, 16, 32` admits no such
family, for any `C` and any offset `c`: the acceleration rules out the whole
harmonic class, not merely a particular normalisation. -/
theorem no_generalized_harmonic_rate {delta : ℝ} {lam : ℕ → ℝ} (hlam : ∀ j, lam j ≠ 0)
    (k0 : kneeCts (lam 0) delta = 12) (k1 : kneeCts (lam 1) delta = 16)
    (k3 : kneeCts (lam 3) delta = 32) :
    ¬ ∃ C c : ℝ, ∀ j : ℕ, lam j = C / ((j : ℝ) + c) := by
  rintro ⟨C, c, hform⟩
  set L : ℝ := Real.log (1 / delta) with hLdef
  have e0 := log_eq_of_kneeCts (hlam 0) k0
  have e1 := log_eq_of_kneeCts (hlam 1) k1
  have e3 := log_eq_of_kneeCts (hlam 3) k3
  -- denominators cannot vanish, else the rate would be zero
  have hden : ∀ j : ℕ, ((j : ℝ) + c) ≠ 0 := by
    intro j hj
    have := hlam j
    rw [hform j, hj, div_zero] at this
    exact this rfl
  have hC : C ≠ 0 := by
    intro hC0
    have := hlam 0
    rw [hform 0, hC0, zero_div] at this
    exact this rfl
  -- from the three knee values, three equations on `C` and `c`
  have key : ∀ (j : ℕ) (K : ℝ), kneeCts (lam j) delta = K → L * ((j : ℝ) + c) = K * C := by
    intro j K hk
    have h := log_eq_of_kneeCts (hlam j) hk
    rw [hform j, ← hLdef] at h
    have hj := hden j
    field_simp at h
    linarith [h]
  have q0 := key 0 12 k0
  have q1 := key 1 16 k1
  have q3 := key 3 32 k3
  push_cast at q0 q1 q3
  -- subtracting: `L = 4 C` and `L = 8 C`, impossible for `C ≠ 0`
  have hL4 : L = 4 * C := by nlinarith [q0, q1]
  have hL8 : 2 * L = 16 * C := by nlinarith [q1, q3]
  have : C = 0 := by linarith
  exact hC this

end Catalog.Novelty.KneeRateAcceleration