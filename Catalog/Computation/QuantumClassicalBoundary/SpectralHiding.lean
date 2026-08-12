import Mathlib
import Computation.FourierTransformInversion
import Computation.QuantumClassicalBoundary.CoherentComb

/-!
# Spectral hiding: the value signal `x ↦ aˣ mod N` has no dominant fundamental

`CoherentComb.lean` showed that the Fourier transform of a *coherent comb* is a
perfect Dirac comb.  This file establishes the complementary, classical fact:
the signal a classical algorithm actually gets to see — the **value signal**
`x ↦ (aˣ mod N)` — is spectrally diffuse, and naive peak picking on it returns
the *wrong* period.

Main results (all with `N = 15`, `a = 7`, whose multiplicative order is `4` —
the textbook Shor instance):

* `modExpSignal_bins` — the four exact Fourier bins of the value signal;
* `fundamental_dominated_by_harmonic` — the fundamental bin `k = 1`, the one that
  encodes the true period `r = 4`, is **strictly smaller** than the second
  harmonic `k = 2`;
* `peak_picking_returns_wrong_period` — the largest non-DC bin is `k = 2`, whose
  naive reading is the period `4 / 2 = 2`, and `2` is *not* the order of `7`
  mod `15`.  So "take the largest peak" is not merely weak, it is wrong;
* `modExpSignal_spectrum_spread` — every bin is nonzero: no bin can be discarded;
* `two_bin_spectrum_is_affine_character` — a general structure theorem (proved
  from `FourierTransformInversion.idft_dft`): a signal whose spectrum is
  supported on `{0, k₀}` is exactly a constant plus one character.  Hence a
  genuinely single-peaked signal is a sinusoid;
* `modExpSignal_not_single_peak` — combining the two: the value signal is *not*
  single-peaked, so the period is hidden in the harmonics.

Contrast with `combDFT_offpeak`: the very same Fourier transform annihilates
`n - r` of the bins of the comb state.  The difference is the input state, not
the transform.

-- !-- Lab Notes -- !--

* Hypothesis (Hypothesizer): the classical spectrum of `aˣ mod N` is diffuse and
  the fundamental need not be the largest non-DC bin.
* Experiment (Experimenter): exhaustive search over all `(N, a)` with
  `ord_N(a) = 4`, `N < 400`, comparing `|V̂(1)|² = (v₀-v₂)² + (v₁-v₃)²` with
  `|V̂(2)|² = (v₀-v₁+v₂-v₃)²`.  Result: **478** pairs violate "fundamental is
  dominant", the smallest being exactly the textbook Shor instance
  `N = 15, a = 7`, with `|V̂(1)|² = 45 < 225 = |V̂(2)|²`.  These numbers are
  re-derived symbolically inside Lean below (`modExpSignal_bins`), not asserted.
* Analysis (Analyst): the failure mode is not noise but *aliasing of the digit
  structure*: the residues `1, 7, 4, 13` are near-antipodal in pairs, which
  cancels the fundamental while reinforcing the `k = 2` harmonic.  A classical
  peak-picker therefore reports `r = 2`, and `7² = 49 ≡ 4 ≢ 1 (mod 15)`, so the
  answer is simply false — the subsequent `gcd` step gets nothing.
* Critique (Critic): one instance does not prove a general theorem, and we do not
  claim one.  The Lean statement is an explicit, exactly computed
  counterexample to "the fundamental bin dominates", plus the general structure
  theorem `two_bin_spectrum_is_affine_character` which says what a single-peaked
  signal would have to look like.  Nothing here is `native_decide`: every bin is
  evaluated symbolically from `ζ₄ = i`.
* Synthesis (PI): Barrier 2 is a statement about the *value* signal; Barrier 1
  is about the number of samples.  Quantum coherence removes both at once
  because the QFT never sees the value signal — it sees the comb.
-/

namespace QuantumClassicalBoundary

open Finset FourierTransformInversion

/-! ## The fourth root of unity -/

theorem zeta_four : zeta 4 = Complex.I := by
  rw [zeta]
  have h : (2 * (Real.pi : ℂ) * Complex.I / (4 : ℕ)) = ((Real.pi / 2 : ℝ) : ℂ) * Complex.I := by
    push_cast; ring
  rw [h, Complex.exp_mul_I]
  simp

/-! ## The classical value signal -/

/-- The **value signal** of modular exponentiation: what a classical algorithm
observes when it evaluates `x ↦ aˣ mod N` at `x = 0, 1, …, r-1`. -/
noncomputable def modExpSignal (N a r : ℕ) : Fin r → ℂ := fun x => ((a ^ (x : ℕ) % N : ℕ) : ℂ)

/-- The order of `7` modulo `15` is `4`: the signal really does have period `4`. -/
theorem order_seven_mod_fifteen : 7 ^ 4 % 15 = 1 ∧ 7 ^ 2 % 15 ≠ 1 ∧ 7 ^ 1 % 15 ≠ 1 := by
  refine ⟨by norm_num, by norm_num, by norm_num⟩

/-- The four exact Fourier bins of the value signal for `N = 15`, `a = 7`. -/
theorem modExpSignal_bins :
    DFT (zeta 4) (modExpSignal 15 7 4) 0 = 25 ∧
    DFT (zeta 4) (modExpSignal 15 7 4) 1 = -3 - 6 * Complex.I ∧
    DFT (zeta 4) (modExpSignal 15 7 4) 2 = -15 ∧
    DFT (zeta 4) (modExpSignal 15 7 4) 3 = -3 + 6 * Complex.I := by
  refine ⟨?_, ?_, ?_, ?_⟩ <;>
    simp [DFT, modExpSignal, Fin.sum_univ_four, zeta_four, pow_succ, Complex.I_mul_I] <;>
    ring_nf

/-- Moduli of the two competing bins. -/
theorem modExpSignal_bin_norms :
    ‖DFT (zeta 4) (modExpSignal 15 7 4) 1‖ = Real.sqrt 45 ∧
    ‖DFT (zeta 4) (modExpSignal 15 7 4) 2‖ = 15 := by
  obtain ⟨-, h1, h2, -⟩ := modExpSignal_bins
  constructor
  · rw [h1, Complex.norm_def, Complex.normSq_apply]
    norm_num
  · rw [h2]; norm_num

/-- **Barrier 2, concrete form.**  For the textbook Shor instance `N = 15`,
`a = 7` (multiplicative order `r = 4`), the *fundamental* Fourier bin — the one
carrying the period — is strictly dominated by the second harmonic. -/
theorem fundamental_dominated_by_harmonic :
    ‖DFT (zeta 4) (modExpSignal 15 7 4) 1‖ < ‖DFT (zeta 4) (modExpSignal 15 7 4) 2‖ := by
  obtain ⟨h1, h2⟩ := modExpSignal_bin_norms
  rw [h1, h2]
  calc Real.sqrt 45 < Real.sqrt 225 := by apply Real.sqrt_lt_sqrt <;> norm_num
    _ = 15 := by rw [show (225 : ℝ) = 15 ^ 2 by norm_num, Real.sqrt_sq]; norm_num

/-- The third bin is the mirror of the first, so it does not rescue peak picking. -/
theorem third_bin_dominated_by_harmonic :
    ‖DFT (zeta 4) (modExpSignal 15 7 4) 3‖ < ‖DFT (zeta 4) (modExpSignal 15 7 4) 2‖ := by
  obtain ⟨-, -, h2, h3⟩ := modExpSignal_bins
  have hn3 : ‖DFT (zeta 4) (modExpSignal 15 7 4) 3‖ = Real.sqrt 45 := by
    rw [h3, Complex.norm_def, Complex.normSq_apply]
    norm_num
  have hn2 : ‖DFT (zeta 4) (modExpSignal 15 7 4) 2‖ = 15 := by rw [h2]; norm_num
  rw [hn3, hn2]
  calc Real.sqrt 45 < Real.sqrt 225 := by apply Real.sqrt_lt_sqrt <;> norm_num
    _ = 15 := by rw [show (225 : ℝ) = 15 ^ 2 by norm_num, Real.sqrt_sq]; norm_num

/-- **Naive peak picking returns a false period.**  Among the non-DC bins the
strict maximum is `k = 2`; reading the period off that peak gives `4 / 2 = 2`,
but `7² ≢ 1 (mod 15)`, so `2` is not the period.  The classical spectral method
does not merely lose accuracy, it returns a wrong answer. -/
theorem peak_picking_returns_wrong_period :
    (∀ k : Fin 4, k ≠ 0 → k ≠ 2 →
        ‖DFT (zeta 4) (modExpSignal 15 7 4) k‖ < ‖DFT (zeta 4) (modExpSignal 15 7 4) 2‖) ∧
      7 ^ 2 % 15 ≠ 1 ∧ 7 ^ 4 % 15 = 1 := by
  refine ⟨?_, by norm_num, by norm_num⟩
  intro k hk0 hk2
  fin_cases k
  · exact absurd rfl hk0
  · exact fundamental_dominated_by_harmonic
  · exact absurd rfl hk2
  · exact third_bin_dominated_by_harmonic

/-- Every bin of the value signal is nonzero: the spectrum is genuinely spread
out, so no frequency can be discarded a priori. -/
theorem modExpSignal_spectrum_spread :
    ∀ k : Fin 4, DFT (zeta 4) (modExpSignal 15 7 4) k ≠ 0 := by
  obtain ⟨h0, h1, h2, h3⟩ := modExpSignal_bins
  intro k
  fin_cases k
  · show DFT (zeta 4) (modExpSignal 15 7 4) 0 ≠ 0
    rw [h0]; norm_num
  · show DFT (zeta 4) (modExpSignal 15 7 4) 1 ≠ 0
    rw [h1]
    intro h
    have := congrArg Complex.re h
    simp at this
  · show DFT (zeta 4) (modExpSignal 15 7 4) 2 ≠ 0
    rw [h2]; norm_num
  · show DFT (zeta 4) (modExpSignal 15 7 4) 3 ≠ 0
    rw [h3]
    intro h
    have := congrArg Complex.re h
    simp at this

/-! ## What a genuinely single-peaked signal must look like -/

/-- **Structure theorem for two-bin spectra.**  If the spectrum of `v` is
supported on `{0, k₀}` with `k₀ ≠ 0`, then `v` is a constant plus a single
character — i.e. a pure sinusoid.  Proved from Fourier inversion
(`FourierTransformInversion.idft_dft`), so it holds over any field with a
primitive `n`-th root of unity; we state the complex case. -/
theorem two_bin_spectrum_is_affine_character {n : ℕ} [NeZero n] {ω : ℂ} (hω : IsPrimitiveRoot ω n)
    (v : Fin n → ℂ) (k0 : Fin n) (hk0 : k0 ≠ 0)
    (hsupp : ∀ j : Fin n, j ≠ 0 → j ≠ k0 → DFT ω v j = 0) (i : Fin n) :
    v i = (n : ℂ)⁻¹ * (DFT ω v 0 + DFT ω v k0 * (ω⁻¹) ^ (i.val * k0.val)) := by
  classical
  have hn : 0 < n := Nat.pos_of_ne_zero (NeZero.ne n)
  have hchar : (n : ℂ) ≠ 0 := Nat.cast_ne_zero.mpr hn.ne'
  have hinv := congrFun (idft_dft hω hn hchar v) i
  rw [IDFT] at hinv
  have hsum : ∑ j : Fin n, DFT ω v j * (ω⁻¹) ^ (i.val * j.val)
      = DFT ω v 0 * (ω⁻¹) ^ (i.val * (0 : Fin n).val)
        + DFT ω v k0 * (ω⁻¹) ^ (i.val * k0.val) := by
    refine Finset.sum_eq_add_of_mem 0 k0 (mem_univ _) (mem_univ _) (Ne.symm hk0) ?_
    intro c _ hc
    rw [hsupp c hc.1 hc.2, zero_mul]
  rw [hsum] at hinv
  simp only [Fin.val_zero, Nat.mul_zero, pow_zero, mul_one] at hinv
  exact hinv.symm

/-- **The value signal is not single-peaked.**  There is no frequency `k₀` that
carries the whole non-DC spectrum of `x ↦ 7ˣ mod 15`; the period is distributed
across the harmonics.  This is the exact opposite of the coherent comb, whose
spectrum vanishes off the peaks (`combDFT_offpeak`). -/
theorem modExpSignal_not_single_peak :
    ¬ ∃ k0 : Fin 4, ∀ j : Fin 4, j ≠ 0 → j ≠ k0 → DFT (zeta 4) (modExpSignal 15 7 4) j = 0 := by
  rintro ⟨k0, hk0⟩
  have hspread := modExpSignal_spectrum_spread
  -- among the three non-DC bins at most one can equal `k0`, so some bin is forced to vanish
  fin_cases k0
  · exact hspread 1 (hk0 1 (by decide) (by decide))
  · exact hspread 2 (hk0 2 (by decide) (by decide))
  · exact hspread 1 (hk0 1 (by decide) (by decide))
  · exact hspread 1 (hk0 1 (by decide) (by decide))

/-! ## The dichotomy -/

/-- **Coherence dichotomy.**  The same Fourier transform, two inputs:

* the coherent comb (quantum) has *identically vanishing* off-peak spectrum and
  attains the maximal possible modulus `m` on its peaks;
* the classical value signal `x ↦ 7ˣ mod 15` has *no* vanishing bin, and its
  largest non-DC bin points at a false period.

Sharpness is therefore a property of the prepared state, not of the transform. -/
theorem coherence_dichotomy {m r : ℕ} (hm : m ≠ 0) (hr : r ≠ 0) (x0 k : ℕ) (hk : ¬ m ∣ k) :
    combDFT m r x0 k = 0 ∧ ‖combDFT m r x0 (m * m)‖ = (m : ℝ) ∧
      (∀ j : Fin 4, DFT (zeta 4) (modExpSignal 15 7 4) j ≠ 0) ∧
      ‖DFT (zeta 4) (modExpSignal 15 7 4) 1‖ < ‖DFT (zeta 4) (modExpSignal 15 7 4) 2‖ :=
  ⟨combDFT_offpeak hm hr x0 k hk, combDFT_peak hm hr x0 m, modExpSignal_spectrum_spread,
    fundamental_dominated_by_harmonic⟩

end QuantumClassicalBoundary