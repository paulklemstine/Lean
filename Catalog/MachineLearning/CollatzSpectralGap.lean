import Mathlib

/-!
# A Fourier obstruction to the proposed Collatz spectral gap

For a finite cutoff, the Collatz exponential sum is continuous in frequency and
has value `N` at frequency zero. Since irrational frequencies are dense, its
norm is arbitrarily close to `N` at irrational frequencies. Consequently, no
uniform bound smaller than `N`—in particular no bound smaller than `√N` when
`N > 1`—can hold at every irrational frequency.
-/

namespace CollatzSpectralGap

open scoped ComplexConjugate
open Filter Set

/-- The usual unaccelerated Collatz map on natural numbers. -/
def collatz (n : ℕ) : ℕ := if Even n then n / 2 else 3 * n + 1

/-- The finite Collatz exponential sum with cutoff `N`, indexed by `1, …, N`. -/
noncomputable def collatzFourier (N : ℕ) (ω : ℝ) : ℂ :=
  ∑ k ∈ Finset.range N,
    Complex.exp
      (2 * Real.pi * Complex.I * (ω : ℂ) *
        ((collatz (k + 1) : ℂ) / (k + 1 : ℂ)))

/-- A continuous complex-valued function taking the value `N` at zero exceeds
any bound `C < N` at some irrational point. This is the topological mechanism
behind the obstruction. -/
theorem irrational_frequency_near_peak
    (f : ℝ → ℂ) (N : ℕ) (C : ℝ) (hf : Continuous f)
    (hzero : f 0 = N) (hC : C < N) :
    ∃ ω : ℝ, Irrational ω ∧ C < ‖f ω‖ := by
  obtain ⟨ε, hε, hball⟩ :
      ∃ ε > 0, ∀ x, abs x < ε → C < ‖f x‖ := by
    rcases Metric.mem_nhds_iff.mp
        (hf.norm.continuousAt.eventually
          (lt_mem_nhds (show C < ‖f 0‖ by simpa [hzero] using hC))) with
      ⟨ε, hε, hball⟩
    exact ⟨ε, hε, by aesop⟩
  obtain ⟨ω, hω, hωpos, hωε⟩ := exists_irrational_btwn hε
  exact ⟨ω, hω, hball ω (by rw [abs_of_pos hωpos]; exact hωε)⟩

/-- The finite Collatz Fourier sum is continuous in its real frequency. -/
theorem continuous_collatzFourier (N : ℕ) :
    Continuous (collatzFourier N) := by
  refine' continuous_finset_sum _ _
  fun_prop

/-- The triangle inequality gives the sharp global upper bound `N` for the
finite transform. Each exponential summand has norm one. -/
theorem collatzFourier_norm_le (N : ℕ) (ω : ℝ) :
    ‖collatzFourier N ω‖ ≤ N := by
  convert norm_sum_le _ _ using 2
  all_goals norm_num [Complex.norm_exp]
  norm_num [Complex.normSq, Complex.div_re, Complex.div_im,
    Complex.exp_re, Complex.exp_im]

/-- Irrational frequencies approach the zero-frequency peak arbitrarily
closely: for every positive error, some irrational frequency has magnitude
strictly greater than `N - ε`. -/
theorem irrational_frequencies_approach_peak
    (N : ℕ) {ε : ℝ} (hε : 0 < ε) :
    ∃ ω : ℝ, Irrational ω ∧ N - ε < ‖collatzFourier N ω‖ := by
  apply irrational_frequency_near_peak (collatzFourier N) N (N - ε)
  · exact continuous_collatzFourier N
  · simp [collatzFourier]
  · linarith

/-- For every cutoff `N > 1` and every `C < √N`, an irrational frequency has
Collatz Fourier magnitude greater than `C`. -/
theorem no_uniform_irrational_spectral_gap
    (N : ℕ) (C : ℝ) (hN : 1 < N) (hC : C < Real.sqrt N) :
    ∃ ω : ℝ, Irrational ω ∧ C < ‖collatzFourier N ω‖ := by
  apply irrational_frequency_near_peak (collatzFourier N) N C
  · exact continuous_collatzFourier N
  · simp [collatzFourier]
  · calc
      C < Real.sqrt N := hC
      _ < N := by
        have hs : 0 ≤ Real.sqrt (N : ℝ) := Real.sqrt_nonneg _
        have hs2 : (Real.sqrt (N : ℝ)) ^ 2 = N := by
          rw [Real.sq_sqrt]
          positivity
        have hNr : (1 : ℝ) < N := by exact_mod_cast hN
        nlinarith

/-- There is no constant below `√N` that strictly bounds the transform at all
irrational frequencies. This disproves the proposed finite-cutoff spectral-gap
assertion. -/
theorem proposed_spectral_gap_is_false (N : ℕ) (hN : 1 < N) :
    ¬ ∃ C : ℝ, C < Real.sqrt N ∧
      ∀ ω : ℝ, Irrational ω → ‖collatzFourier N ω‖ < C := by
  rintro ⟨C, hC, hbound⟩
  obtain ⟨ω, hω, hlower⟩ := no_uniform_irrational_spectral_gap N C hN hC
  linarith [hbound ω hω]

/-- Independently of Collatz arithmetic, every finite exponential sum with
`N` unit coefficients has irrational frequencies where its norm exceeds any
prescribed `C < N`. -/
theorem finite_phase_sum_no_global_gap
    (N : ℕ) (phase : ℕ → ℝ) (C : ℝ) (hC : C < N) :
    ∃ ω : ℝ, Irrational ω ∧
      C < ‖∑ k ∈ Finset.range N,
        Complex.exp (Complex.I * (ω * phase k : ℝ))‖ := by
  apply irrational_frequency_near_peak
    (fun ω : ℝ ↦ ∑ k ∈ Finset.range N,
      Complex.exp (Complex.I * (ω * phase k : ℝ))) N C
  · fun_prop
  · simp
  · exact hC

end CollatzSpectralGap