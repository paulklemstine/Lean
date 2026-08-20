import Catalog.NumberTheory.RLHFPronySampling

/-!
# Exponential sums form a Chebyshev system: `n` arbitrary temperatures suffice

`RLHF.exp_sample_uniqueness` recovers the masses on `n` known reward levels from the
partition function at `n` *arithmetically spaced* inverse temperatures, by a Vandermonde
determinant.  This file removes the arithmetic-grid hypothesis: **any** `n` distinct
temperatures do.

The engine is the classical Descartes/Chebyshev fact, proved here by induction on the number
of exponents with Rolle's theorem supplying the inductive step:

* `RLHF.expPoly_eq_zero_of_zeros` — a real exponential polynomial `∑_{j<n} c_j e^{v_j x}`
  with `n` strictly increasing exponents that vanishes at `n` distinct points has all
  coefficients zero.  (Equivalently: a nonzero exponential polynomial with `n` exponents has
  at most `n − 1` real zeros.)
* `RLHF.exp_sample_uniqueness_general` — consequently two mass vectors on the same `n` known
  distinct levels are equal as soon as their exponential sums agree at `n` distinct
  temperatures.
* `RLHF.spectral_rigidity_sampled_general` — the RLHF audit statement: with `n` known
  candidate reward levels, `n` arbitrary distinct inverse temperatures determine the reward
  spectrum.

Combined with `RLHF.prony_three_samples_insufficient_spectra`, the picture for the sampling
question is complete in the known-level case, and provably different when the levels are
unknown.
-/

namespace RLHF

open Finset

/-- The derivative of an exponential polynomial, computed term by term. -/
theorem hasDerivAt_expPoly {n : ℕ} (c w : Fin n → ℝ) (x : ℝ) :
    HasDerivAt (fun x => ∑ j, c j * Real.exp (w j * x))
      (∑ j, c j * w j * Real.exp (w j * x)) x := by
  have h : ∀ j ∈ (univ : Finset (Fin n)),
      HasDerivAt (fun x => c j * Real.exp (w j * x)) (c j * w j * Real.exp (w j * x)) x := by
    intro j _
    have h1 : HasDerivAt (fun x : ℝ => w j * x) (w j) x := by
      simpa using (hasDerivAt_id x).const_mul (w j)
    have h2 : HasDerivAt (fun x : ℝ => Real.exp (w j * x)) (Real.exp (w j * x) * w j) x := h1.exp
    have h3 := h2.const_mul (c j)
    convert h3 using 1
    ring
  have hs := HasDerivAt.sum h
  have hfun : (∑ j ∈ (univ : Finset (Fin n)), fun x => c j * Real.exp (w j * x))
      = fun x => ∑ j, c j * Real.exp (w j * x) := by
    funext x
    simp [Finset.sum_apply]
  rw [hfun] at hs
  exact hs

/-- **Exponential sums are a Chebyshev system.**  If the exponents `v₀ < ⋯ < v_{n-1}` are
distinct and the exponential polynomial `x ↦ ∑_j c_j e^{v_j x}` vanishes at `n` distinct
points, then every coefficient vanishes.  Proved by induction on `n`: dividing by `e^{v₀ x}`
and applying Rolle's theorem on each of the `n − 1` consecutive intervals produces `n − 1`
zeros of an exponential polynomial with `n − 1` exponents. -/
theorem expPoly_eq_zero_of_zeros :
    ∀ (n : ℕ) (v c t : Fin n → ℝ), StrictMono v → StrictMono t →
      (∀ i, ∑ j, c j * Real.exp (v j * t i) = 0) → ∀ j, c j = 0 := by
  intro n
  induction n with
  | zero => intro _ _ _ _ _ _ j; exact j.elim0
  | succ n ih =>
    intro v c t hv ht h
    -- the shifted polynomial `g x = e^{-v₀ x} f x`
    set g : ℝ → ℝ := fun x => ∑ j, c j * Real.exp ((v j - v 0) * x) with hgdef
    set G : ℝ → ℝ := fun x => ∑ j, c j * (v j - v 0) * Real.exp ((v j - v 0) * x) with hGdef
    have hgderiv : ∀ x, HasDerivAt g (G x) x := fun x =>
      hasDerivAt_expPoly c (fun j => v j - v 0) x
    have hgzero : ∀ i, g (t i) = 0 := by
      intro i
      have hfac : ∀ j, c j * Real.exp ((v j - v 0) * t i)
          = Real.exp (-(v 0) * t i) * (c j * Real.exp (v j * t i)) := by
        intro j
        have hexp : Real.exp ((v j - v 0) * t i)
            = Real.exp (-(v 0) * t i) * Real.exp (v j * t i) := by
          rw [← Real.exp_add]
          congr 1
          ring
        rw [hexp]
        ring
      rw [hgdef]
      simp only
      rw [Finset.sum_congr rfl (fun j _ => hfac j), ← Finset.mul_sum, h i, mul_zero]
    -- Rolle on each consecutive pair of zeros
    have hrolle : ∀ i : Fin n, ∃ s ∈ Set.Ioo (t i.castSucc) (t i.succ), G s = 0 := by
      intro i
      have hlt : t i.castSucc < t i.succ := ht (Fin.castSucc_lt_succ (i := i))
      refine exists_hasDerivAt_eq_zero hlt ?_ ?_ (fun x _ => hgderiv x)
      · exact (fun x _ => (hgderiv x).continuousAt.continuousWithinAt)
      · rw [hgzero i.castSucc, hgzero i.succ]
    choose s hs hsG using hrolle
    have hsmono : StrictMono s := by
      intro i i' hii
      have h1 : s i < t i.succ := (hs i).2
      have h2 : t i'.castSucc < s i' := (hs i').1
      have h3 : t i.succ ≤ t i'.castSucc := by
        refine ht.monotone ?_
        rw [Fin.le_def]
        simp only [Fin.val_succ, Fin.val_castSucc]
        omega
      linarith
    -- apply the inductive hypothesis to the derivative
    have hv' : StrictMono (fun j : Fin n => v j.succ - v 0) := by
      intro j k hjk
      have : v j.succ < v k.succ := hv (Fin.succ_lt_succ_iff.mpr hjk)
      simpa using this
    have hzeros : ∀ i : Fin n,
        ∑ j : Fin n, (c j.succ * (v j.succ - v 0)) * Real.exp ((v j.succ - v 0) * s i) = 0 := by
      intro i
      have hG := hsG i
      rw [hGdef] at hG
      simp only at hG
      rw [Fin.sum_univ_succ] at hG
      simpa using hG
    have hc' := ih (fun j : Fin n => v j.succ - v 0) (fun j => c j.succ * (v j.succ - v 0)) s
      hv' hsmono hzeros
    have hcsucc : ∀ j : Fin n, c j.succ = 0 := by
      intro j
      have hpos : 0 < v j.succ - v 0 := by
        have : v 0 < v j.succ := hv (by
          rw [Fin.lt_def]
          simp only [Fin.val_succ, Fin.val_zero]
          omega)
        linarith
      rcases mul_eq_zero.mp (hc' j) with h1 | h1
      · exact h1
      · exact absurd h1 (ne_of_gt hpos)
    have hc0 : c 0 = 0 := by
      have h0 := h 0
      rw [Fin.sum_univ_succ] at h0
      have hzero : ∑ j : Fin n, c j.succ * Real.exp (v j.succ * t 0) = 0 := by
        refine Finset.sum_eq_zero (fun j _ => ?_)
        rw [hcsucc j, zero_mul]
      rw [hzero, add_zero] at h0
      rcases mul_eq_zero.mp h0 with h1 | h1
      · exact h1
      · exact absurd h1 (Real.exp_ne_zero _)
    intro j
    refine Fin.cases ?_ ?_ j
    · exact hc0
    · exact hcsucc

/-- **Prony sampling at arbitrary temperatures.**  Two mass vectors on the same `n` known
strictly increasing levels that give the same exponential sum at `n` distinct temperatures
are equal.  This removes the arithmetic-grid hypothesis of
`RLHF.exp_sample_uniqueness`. -/
theorem exp_sample_uniqueness_general {n : ℕ} {v : Fin n → ℝ} (hv : StrictMono v)
    {t : Fin n → ℝ} (ht : StrictMono t) {a b : Fin n → ℝ}
    (h : ∀ i, ∑ j, a j * Real.exp (v j * t i) = ∑ j, b j * Real.exp (v j * t i)) :
    a = b := by
  have hzero : ∀ i, ∑ j, (a j - b j) * Real.exp (v j * t i) = 0 := by
    intro i
    have hsplit : ∑ j, (a j - b j) * Real.exp (v j * t i)
        = (∑ j, a j * Real.exp (v j * t i)) - ∑ j, b j * Real.exp (v j * t i) := by
      rw [← Finset.sum_sub_distrib]
      exact Finset.sum_congr rfl (fun j _ => by ring)
    rw [hsplit, h i, sub_self]
  have := expPoly_eq_zero_of_zeros n v (fun j => a j - b j) t hv ht hzero
  funext j
  have hj := this j
  simpa [sub_eq_zero] using hj

/-- **Finite-sample spectral rigidity at arbitrary temperatures.**  With `n` known candidate
reward levels, the reward spectrum of an RLHF problem is determined by the partition function
at any `n` distinct inverse temperatures. -/
theorem spectral_rigidity_sampled_general {Ω₁ Ω₂ : Type*} [Fintype Ω₁] [Fintype Ω₂]
    {r₁ p₁ : Ω₁ → ℝ} {r₂ p₂ : Ω₂ → ℝ} {n : ℕ} {v : Fin n → ℝ} (hv : StrictMono v)
    (h₁ : image r₁ univ ⊆ image v univ) (h₂ : image r₂ univ ⊆ image v univ)
    {t : Fin n → ℝ} (ht : StrictMono t)
    (h : ∀ i, ∑ y, p₁ y * Real.exp (r₁ y * t i) = ∑ y, p₂ y * Real.exp (r₂ y * t i)) :
    ∀ w : ℝ, rewardMass r₁ p₁ w = rewardMass r₂ p₂ w := by
  classical
  have hre₁ : ∀ i, ∑ y, p₁ y * Real.exp (r₁ y * t i)
      = ∑ j, rewardMass r₁ p₁ (v j) * Real.exp (v j * t i) := by
    intro i
    rw [sum_exp_eq_rewardMass_sum h₁ (t i),
      Finset.sum_image (fun j _ k _ hjk => hv.injective hjk)]
  have hre₂ : ∀ i, ∑ y, p₂ y * Real.exp (r₂ y * t i)
      = ∑ j, rewardMass r₂ p₂ (v j) * Real.exp (v j * t i) := by
    intro i
    rw [sum_exp_eq_rewardMass_sum h₂ (t i),
      Finset.sum_image (fun j _ k _ hjk => hv.injective hjk)]
  have hsample : ∀ i, ∑ j, rewardMass r₁ p₁ (v j) * Real.exp (v j * t i)
      = ∑ j, rewardMass r₂ p₂ (v j) * Real.exp (v j * t i) := by
    intro i
    rw [← hre₁ i, ← hre₂ i]
    exact h i
  have hmass := exp_sample_uniqueness_general hv ht hsample
  intro w
  by_cases hw : w ∈ image v univ
  · obtain ⟨j, _, hj⟩ := Finset.mem_image.mp hw
    have := congrFun hmass j
    rwa [hj] at this
  · have hw₁ : w ∉ image r₁ univ := fun hmem => hw (h₁ hmem)
    have hw₂ : w ∉ image r₂ univ := fun hmem => hw (h₂ hmem)
    rw [rewardMass_eq_zero hw₁, rewardMass_eq_zero hw₂]

end RLHF