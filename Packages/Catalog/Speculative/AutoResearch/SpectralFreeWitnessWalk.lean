/-
# The dyadic diffusion operator: heat kernel = return probability

`Algebra.SpectralFreeWitness` defines the heat-kernel value `p_n(e)` *spectrally*,
as `(1/r) ∑_k μ_k^n`.  This file shows that this spectral definition is the genuine
`n`-step return probability of the half-lazy lacunary dyadic random walk, by

* introducing the diffusion (transition) operator
  `W f (x) = f x / 2 + (∑_{t ≤ M} (f (x + 2^t) + f (x - 2^t))) / (4 (M+1))`
  acting on `r`-periodic functions on the cycle `Z/rZ` (realised as functions `ℤ → ℂ`),
* proving that the additive characters `χ_k (x) = e^{2πi k x / r}` are eigenvectors
  of `W` with eigenvalues exactly the `lazyEigen r M k` of the spectral file
  (`walkStep_chi`),
* proving the discrete Fourier expansion of the periodic delta function
  (`sum_chi`: character orthogonality on `Z/rZ`),
* concluding `W^[n] δ (0) = p_n(e)` (`walk_return_eq_heatReturn`), and hence the
  fully operational statement of heat-kernel order recovery
  (`walk_recovers_order`): the *measured* return probability of the diffusion,
  after `8 (M+1)^2` steps, determines the order `r` by a single rounding.

No `sorry`, no `native_decide`.
-/

import Mathlib
import Algebra.SpectralFreeWitness

namespace SpectralFreeWitness

open Finset Real

/-! ## 1. The additive characters of the cycle -/

/-- The additive character `χ_k (x) = exp (2π i k x / r)` of `Z/rZ`, realised as a
function on `ℤ` (it is `r`-periodic). -/
noncomputable def chi (r k : ℕ) (x : ℤ) : ℂ :=
  Complex.exp (2 * π * Complex.I * ((k : ℂ) * (x : ℂ)) / r)

lemma chi_add (r k : ℕ) (x y : ℤ) : chi r k (x + y) = chi r k x * chi r k y := by
  simp only [chi, ← Complex.exp_add]
  congr 1
  push_cast
  ring

lemma chi_zero_arg (r k : ℕ) : chi r k 0 = 1 := by
  simp [chi]

/-- Real form of a conjugate pair of character values. -/
lemma chi_add_chi_neg (r k : ℕ) (m : ℤ) :
    chi r k m + chi r k (-m) = 2 * ((Real.cos (2 * π * ((k : ℝ) * (m : ℝ)) / r) : ℝ) : ℂ) := by
  have hz : (2 * π * Complex.I * ((k : ℂ) * (m : ℂ)) / r)
      = ((2 * π * ((k : ℝ) * (m : ℝ)) / r : ℝ) : ℂ) * Complex.I := by
    push_cast
    ring
  have hz' : (2 * π * Complex.I * ((k : ℂ) * ((-m : ℤ) : ℂ)) / r)
      = -(((2 * π * ((k : ℝ) * (m : ℝ)) / r : ℝ) : ℂ) * Complex.I) := by
    push_cast
    ring
  simp only [chi, hz, hz']
  rw [Complex.exp_mul_I, ← neg_mul, Complex.exp_mul_I, Complex.cos_neg, Complex.sin_neg]
  rw [Complex.ofReal_cos]
  ring

/-! ## 2. The diffusion operator -/

/-- One step of the half-lazy random walk with lacunary dyadic generators
`{± 2^t : t ≤ M}` on the cycle `Z/rZ`. -/
noncomputable def walkStep (M : ℕ) (f : ℤ → ℂ) : ℤ → ℂ := fun x =>
  f x / 2 + (∑ t ∈ range (M + 1), (f (x + 2 ^ t) + f (x - 2 ^ t))) / (4 * ((M : ℂ) + 1))

lemma walkStep_smul (M : ℕ) (c : ℂ) (f : ℤ → ℂ) :
    walkStep M (fun x => c * f x) = fun x => c * walkStep M f x := by
  funext x
  have hterm : ∀ t : ℕ, c * f (x + 2 ^ t) + c * f (x - 2 ^ t)
      = c * (f (x + 2 ^ t) + f (x - 2 ^ t)) := fun t => by ring
  simp only [walkStep, hterm, ← Finset.mul_sum]
  ring

lemma walkStep_sum (M : ℕ) (s : Finset ℕ) (F : ℕ → ℤ → ℂ) :
    walkStep M (fun x => ∑ k ∈ s, F k x) = fun x => ∑ k ∈ s, walkStep M (F k) x := by
  funext x
  simp only [walkStep]
  have e1 : ∑ k ∈ s, (F k x / 2
        + (∑ t ∈ range (M + 1), (F k (x + 2 ^ t) + F k (x - 2 ^ t))) / (4 * ((M : ℂ) + 1)))
      = (∑ k ∈ s, F k x / 2)
        + ∑ k ∈ s, (∑ t ∈ range (M + 1), (F k (x + 2 ^ t) + F k (x - 2 ^ t)))
            / (4 * ((M : ℂ) + 1)) := Finset.sum_add_distrib
  rw [e1, ← Finset.sum_div, ← Finset.sum_div, Finset.sum_comm]
  congr 2
  exact Finset.sum_congr rfl fun t _ => (Finset.sum_add_distrib).symm

/-- **Characters are eigenvectors.** The eigenvalue is exactly `lazyEigen r M k`, the
quantity whose spectral gap is proved in `Algebra.SpectralFreeWitness`. -/
theorem walkStep_chi (r M k : ℕ) :
    walkStep M (chi r k) = fun x => ((lazyEigen r M k : ℝ) : ℂ) * chi r k x := by
  funext x
  have hMne : ((M : ℂ) + 1) ≠ 0 := by
    have hc : ((M : ℂ) + 1) = ((M + 1 : ℕ) : ℂ) := by push_cast; ring
    rw [hc, Nat.cast_ne_zero]
    omega
  have hterm : ∀ t ∈ range (M + 1), chi r k (x + 2 ^ t) + chi r k (x - 2 ^ t)
      = chi r k x * (2 * ((Real.cos (2 * π * ((k * 2 ^ t : ℕ) : ℝ) / r) : ℝ) : ℂ)) := by
    intro t _
    have h1 : chi r k (x + 2 ^ t) = chi r k x * chi r k (2 ^ t) := chi_add r k x (2 ^ t)
    have h2 : chi r k (x - 2 ^ t) = chi r k x * chi r k (-(2 ^ t)) := by
      rw [sub_eq_add_neg]; exact chi_add r k x (-(2 ^ t))
    have h3 := chi_add_chi_neg r k ((2 : ℤ) ^ t)
    have h4 : ((2 * π * ((k : ℝ) * (((2 : ℤ) ^ t : ℤ) : ℝ)) / r : ℝ))
        = (2 * π * ((k * 2 ^ t : ℕ) : ℝ)) / r := by
      push_cast
      ring
    rw [h1, h2, ← mul_add, h3, h4]
  rw [walkStep, lazyEigen, dyadicEigen, Finset.sum_congr rfl hterm]
  simp only [← Finset.mul_sum]
  push_cast
  field_simp
  ring

lemma walkStep_iterate_smul (M n : ℕ) (c : ℂ) (f : ℤ → ℂ) :
    (walkStep M)^[n] (fun x => c * f x) = fun x => c * ((walkStep M)^[n] f) x := by
  induction n with
  | zero => simp
  | succ m ih =>
      have h1 : (walkStep M)^[m + 1] (fun x => c * f x)
          = walkStep M ((walkStep M)^[m] (fun x => c * f x)) :=
        Function.iterate_succ_apply' _ _ _
      have h2 : (walkStep M)^[m + 1] f = walkStep M ((walkStep M)^[m] f) :=
        Function.iterate_succ_apply' _ _ _
      rw [h1, h2, ih, walkStep_smul]

lemma walkStep_iterate_sum (M n : ℕ) (s : Finset ℕ) (F : ℕ → ℤ → ℂ) :
    (walkStep M)^[n] (fun x => ∑ k ∈ s, F k x)
      = fun x => ∑ k ∈ s, ((walkStep M)^[n] (F k)) x := by
  induction n with
  | zero => simp
  | succ m ih =>
      have h1 : (walkStep M)^[m + 1] (fun x => ∑ k ∈ s, F k x)
          = walkStep M ((walkStep M)^[m] (fun x => ∑ k ∈ s, F k x)) :=
        Function.iterate_succ_apply' _ _ _
      rw [h1, ih, walkStep_sum]
      funext x
      refine Finset.sum_congr rfl fun k _ => ?_
      rw [Function.iterate_succ_apply']

lemma walkStep_iterate_chi (r M k n : ℕ) :
    (walkStep M)^[n] (chi r k) = fun x => ((lazyEigen r M k : ℝ) : ℂ) ^ n * chi r k x := by
  induction n with
  | zero => simp
  | succ m ih =>
      rw [Function.iterate_succ_apply', ih, walkStep_smul, walkStep_chi]
      funext x
      ring

/-! ## 3. Fourier expansion of the delta function -/

/-- The periodic delta function at the identity of `Z/rZ`. -/
noncomputable def deltaPer (r : ℕ) : ℤ → ℂ := fun x => if (r : ℤ) ∣ x then 1 else 0

/-- **Character orthogonality** on `Z/rZ`. -/
theorem sum_chi (r : ℕ) (hr : 0 < r) (x : ℤ) :
    ∑ k ∈ range r, chi r k x = r * deltaPer r x := by
  have hr0 : (r : ℂ) ≠ 0 := by
    simp only [ne_eq, Nat.cast_eq_zero]
    omega
  set ω : ℂ := Complex.exp (2 * π * Complex.I * (x : ℂ) / r) with hω
  have hchi : ∀ k ∈ range r, chi r k x = ω ^ k := by
    intro k _
    rw [hω, ← Complex.exp_nat_mul, chi]
    congr 1
    ring
  rw [Finset.sum_congr rfl hchi]
  by_cases hdvd : (r : ℤ) ∣ x
  · obtain ⟨m, hm⟩ := id hdvd
    have hω1 : ω = 1 := by
      rw [hω, hm]
      rw [show (2 * (π : ℂ) * Complex.I * ((((r : ℤ) * m : ℤ)) : ℂ) / r)
            = (m : ℂ) * (2 * π * Complex.I) by push_cast; field_simp]
      exact Complex.exp_int_mul_two_pi_mul_I m
    have hd1 : deltaPer r x = 1 := by simp [deltaPer, hdvd]
    rw [hd1, hω1]
    simp
  · have hωr : ω ^ r = 1 := by
      rw [hω, ← Complex.exp_nat_mul]
      rw [show ((r : ℂ) * (2 * π * Complex.I * (x : ℂ) / r)) = (x : ℂ) * (2 * π * Complex.I) by
        field_simp]
      exact Complex.exp_int_mul_two_pi_mul_I x
    have hωne : ω ≠ 1 := by
      intro h
      rw [hω, Complex.exp_eq_one_iff] at h
      obtain ⟨m, hm⟩ := h
      apply hdvd
      refine ⟨m, ?_⟩
      have hπ : ((π : ℂ)) ≠ 0 := by
        simp only [ne_eq, Complex.ofReal_eq_zero]
        exact ne_of_gt Real.pi_pos
      have h2πI : (2 * (π : ℂ) * Complex.I) ≠ 0 := by
        simp [hπ, Complex.I_ne_zero]
      rw [div_eq_iff hr0] at hm
      have hx : (x : ℂ) = (r : ℂ) * (m : ℂ) := by
        apply mul_left_cancel₀ h2πI
        linear_combination hm
      exact_mod_cast hx
    have hgeom : ∑ k ∈ range r, ω ^ k = (ω ^ r - 1) / (ω - 1) :=
      geom_sum_eq hωne r
    rw [hgeom, hωr]
    simp [deltaPer, hdvd]

/-! ## 4. The return probability equals the spectral heat kernel -/

/-- **The heat kernel is the return probability.** After `n` steps of the half-lazy
lacunary dyadic diffusion started at the identity, the mass at the identity equals the
spectral expression `p_n(e) = (1/r) ∑_k μ_k^n`. -/
theorem walk_return_eq_heatReturn (r M n : ℕ) (hr : 0 < r) :
    (walkStep M)^[n] (deltaPer r) 0 = ((heatReturn r M n : ℝ) : ℂ) := by
  have hr0 : (r : ℂ) ≠ 0 := by
    simp only [ne_eq, Nat.cast_eq_zero]
    omega
  have hdelta : deltaPer r = fun x => ∑ k ∈ range r, ((r : ℂ)⁻¹ * chi r k x) := by
    funext x
    rw [← Finset.mul_sum, sum_chi r hr x, ← mul_assoc, inv_mul_cancel₀ hr0, one_mul]
  rw [hdelta]
  rw [show (fun x : ℤ => ∑ k ∈ range r, ((r : ℂ)⁻¹ * chi r k x))
      = (fun x : ℤ => ∑ k ∈ range r, (fun y : ℤ => (r : ℂ)⁻¹ * chi r k y) x) from rfl]
  rw [walkStep_iterate_sum]
  show ∑ k ∈ range r, ((walkStep M)^[n] (fun y : ℤ => (r : ℂ)⁻¹ * chi r k y)) 0
      = ((heatReturn r M n : ℝ) : ℂ)
  have hk : ∀ k ∈ range r,
      ((walkStep M)^[n] (fun y : ℤ => (r : ℂ)⁻¹ * chi r k y)) 0
        = (r : ℂ)⁻¹ * ((lazyEigen r M k : ℝ) : ℂ) ^ n := by
    intro k _
    rw [walkStep_iterate_smul, walkStep_iterate_chi]
    simp [chi_zero_arg]
  rw [Finset.sum_congr rfl hk, ← Finset.mul_sum]
  rw [heatReturn]
  push_cast
  ring

/-- **Operational heat-kernel order recovery.** The return probability of the
half-lazy lacunary dyadic diffusion on the cycle of length `r`, measured once after
`8 (M+1)^2` steps, determines `r` exactly, whenever `r ≤ N ≤ 2^M`. -/
theorem walk_recovers_order (N r M : ℕ) (hr : 0 < r) (hrN : r ≤ N) (hM : N ≤ 2 ^ M) :
    round (1 / (((walkStep M)^[8 * (M + 1) ^ 2] (deltaPer r) 0).re) : ℝ) = (r : ℤ) := by
  rw [walk_return_eq_heatReturn r M _ hr, Complex.ofReal_re]
  exact heat_kernel_order_recovery N r M hr hrN hM

end SpectralFreeWitness