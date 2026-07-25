import Mathlib

/-!
# Hearing the integers (and locating the sign error)

This file formalizes rigorous statements about the elementary Fourier mechanism behind
Dirichlet polynomials.  With the Fourier convention in the prompt, `exp (-2π i w t)`,
the summand `n⁻¹/² exp (-i t log n)` resonates at the *negative* frequency
`-log n/(2π)`.  Moreover every integer `n ≥ 2`, not only every prime, occurs in the
Dirichlet series.  The unwindowed pure tones are not Lebesgue integrable, so their
Fourier transforms must be interpreted distributionally or after windowing.
-/

open scoped Real
open MeasureTheory Set

namespace HearingThePrimes

/-- The positive log-frequency customarily attached to an integer. -/
noncomputable def logFrequency (n : ℕ) : ℝ := Real.log n / (2 * Real.pi)

/-- The oscillatory part of `n ^ (-1/2-it)`. -/
noncomputable def dirichletTone (n : ℕ) (t : ℝ) : ℂ :=
  Complex.exp (-(Complex.I * (Real.log n * t)))

/-- Fourier kernel with the convention used in the research prompt. -/
noncomputable def fourierKernel (w t : ℝ) : ℂ :=
  Complex.exp (-(2 * Real.pi * Complex.I * (w * t)))

/-- A symmetric, finite-window Fourier transform. -/
noncomputable def windowedFourier (f : ℝ → ℂ) (T w : ℝ) : ℂ :=
  ∫ t in (-T)..T, f t * fourierKernel w t

/-
Every Dirichlet tone has constant modulus one.
-/
theorem norm_dirichletTone (n : ℕ) (t : ℝ) : ‖dirichletTone n t‖ = 1 := by
  convert Complex.norm_exp _ using 2 ; norm_num [ Complex.ext_iff ];
  norm_num [ Complex.log_im ]

/-
A pure Dirichlet tone has no ordinary Fourier integral over the whole real line.
-/
theorem dirichletTone_not_integrable (n : ℕ) :
    ¬ Integrable (dirichletTone n) := by
  intro h;
  convert h.norm.lintegral_lt_top.ne' _;
  simp +decide [ norm_dirichletTone ]

/-
Under the stated Fourier convention, the advertised positive frequency has the
wrong sign for every `n > 1`.
-/
theorem claimed_frequency_has_wrong_sign {n : ℕ} (hn : 1 < n) :
    -logFrequency n ≠ logFrequency n := by
  linarith [ show 0 < logFrequency n by exact div_pos ( Real.log_pos ( Nat.one_lt_cast.mpr hn ) ) ( by positivity ) ]

/-
At the correctly signed frequency, the two exponentials cancel pointwise.
-/
theorem tone_kernel_resonance (n : ℕ) (t : ℝ) :
    dirichletTone n t * fourierKernel (-logFrequency n) t = 1 := by
  unfold dirichletTone fourierKernel logFrequency;
  rw [ ← Complex.exp_add ] ; ring_nf ; norm_num [ Real.pi_ne_zero ];
  ring_nf; norm_num [ Real.pi_ne_zero ]

/-
Consequently a window of half-width `T` gives the exact resonant response `2T`.
-/
theorem windowedFourier_at_resonance (n : ℕ) (T : ℝ) :
    windowedFourier (dirichletTone n) T (-logFrequency n) = (2 * T : ℝ) := by
  unfold windowedFourier
  rw [intervalIntegral.integral_congr fun t _ => tone_kernel_resonance n t]
  norm_num
  ring

/-
Log-frequencies turn multiplication into addition.  Thus composite integers
produce frequencies that are sums of lower integer frequencies.
-/
theorem logFrequency_mul (m n : ℕ) (hm : 0 < m) (hn : 0 < n) :
    logFrequency (m * n) = logFrequency m + logFrequency n := by
  unfold logFrequency
  rw [Nat.cast_mul, Real.log_mul (by positivity) (by positivity), add_div]

/-
Positive integers have distinct log-frequencies.  Hence the integer tones do
not collide, although primality is not singled out by their locations.
-/
theorem logFrequency_injective_on_positive {m n : ℕ} (hm : 0 < m) (hn : 0 < n)
    (hfreq : logFrequency m = logFrequency n) : m = n := by
  exact_mod_cast Real.log_injOn_pos ( Set.mem_Ioi.mpr <| Nat.cast_pos.mpr hm ) ( Set.mem_Ioi.mpr <| Nat.cast_pos.mpr hn ) <| by unfold logFrequency at hfreq; rw [ div_eq_div_iff ] at hfreq <;> nlinarith [ Real.pi_pos ] ;

/-
In particular, the zeta Dirichlet polynomial has a nonzero tone at the composite
integer `4`; the elementary Fourier heuristic does not isolate primes.
-/
theorem composite_four_has_nonzero_weight :
    ¬ (1 / Real.sqrt 4 : ℝ) = 0 ∧ ¬ Nat.Prime 4 := by
  norm_num

/-
The correctly signed frequencies are strictly negative for all nontrivial
Dirichlet terms.
-/
theorem resonant_frequency_negative {n : ℕ} (hn : 1 < n) :
    -logFrequency n < 0 := by
  exact neg_neg_of_pos ( div_pos ( Real.log_pos ( Nat.one_lt_cast.mpr hn ) ) ( by positivity ) )

end HearingThePrimes