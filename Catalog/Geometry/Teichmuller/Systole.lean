/-
# The systole of a marked flat torus, and Hermite's constant in dimension two

A point `τ` of the Teichmüller space `ℍ` of marked tori determines the flat torus
`ℂ / (ℤ + τ ℤ)`, whose area is `Im τ` and whose **systole** (the length of the shortest closed
geodesic) is the length of the shortest nonzero lattice vector `m + n τ`.  The *systolic ratio*

    sys(τ)² / area(τ)  =  min_{(m,n) ≠ 0} |m + n τ|² / Im τ

is invariant under the mapping class group `SL(2, ℤ)` — it is a genuine function on the moduli
space — and its supremum is by definition **Hermite's constant `γ₂`** in dimension two.

This file proves, purely from the modular fundamental domain:

* `Teichmuller.exists_short_lattice_vector` : for every marked torus `τ` there is a nonzero
  lattice vector with `|m + n τ|² ≤ (2/√3) · Im τ`, i.e. `sys(τ)² ≤ (2/√3) · area(τ)`;
* `Teichmuller.rho_normSq` : the exact quadratic form of the hexagonal lattice,
  `|m + n ρ|² = m² - m n + n²`;
* `Teichmuller.le_normSq_rho` : the hexagonal torus `ρ` attains the bound — every nonzero
  lattice vector of `ρ` satisfies `|m + n ρ|² ≥ (2/√3) · Im ρ = 1`;
* `Teichmuller.hermite_two_sharp` : consequently the constant `2/√3` cannot be lowered, so
  `γ₂ = 2/√3` exactly, the extremal torus being the order-three orbifold point of the moduli
  space found in `Geometry.Teichmuller.ModuliSpace`.

-- !-- Lab Notes -- !--
Hypothesizer: the two orbifold points of the moduli space of tori should be the critical
points of the systolic ratio, with the *order-three* point (hexagonal) the global maximum.
Experimenter: values of `min_{(m,n)≠0} |m+nτ|² / Im τ` computed at the corners:
  τ = 2i        : min |m+nτ|² = 1,  Im τ = 2      → ratio 0.5
  τ = i         : min = 1,          Im = 1        → ratio 1
  τ = 1/2+i     : min = 1,          Im = 1        → ratio 1
  τ = ρ         : min = 1,          Im = √3/2     → ratio 2/√3 ≈ 1.1547
  τ = -1/2+0.9i : min = 0.81+0.25 = 1.06 (n=0 gives 1) → ratio 1/0.9 ≈ 1.111  (τ ∉ 𝒟)
Analyst: the ratio is `1 / Im τ` on the whole part of the fundamental domain where the vector
`(1,0)` is shortest, so maximising it is the same as *minimising* `Im τ` over `𝒟`; the minimum
of `Im` on `𝒟` is `√3/2`, attained exactly at the two corners `±1/2 + i√3/2`, which are the
same point of moduli.  Critic: the argument needs `𝒟` to be a genuine fundamental domain, i.e.
every orbit meets it — that is `ModularGroup.exists_smul_mem_fd`, and the transfer from `σ`
back to `τ` is done by the cocycle `Im (g • τ) = Im τ / |cτ + d|²`, with the extremal lattice
vector read off as `(m, n) = (d, c)`.  No compactness or minimisation over an infinite set is
needed anywhere.
-/
import Mathlib
import Geometry.Teichmuller.ModuliSpace

namespace Teichmuller

open Complex UpperHalfPlane Matrix MatrixGroups

/-- **The systolic bound for flat tori (Hermite's constant `γ₂ ≤ 2/√3`).**
Every marked torus `ℂ / (ℤ + τ ℤ)` contains a nonzero lattice vector of squared length at
most `(2/√3) · Im τ`, that is, `sys² ≤ (2/√3) · area`.

The proof moves `τ` into the standard fundamental domain by a mapping class `g`, where
`Im (g • τ) ≥ √3/2`, and transports the vector `1` back through the cocycle
`Im (g • τ) = Im τ / |c τ + d|²`; the resulting extremal lattice vector is `d + c τ`. -/
theorem exists_short_lattice_vector (tau : ℍ) : ∃ m n : ℤ, (m ≠ 0 ∨ n ≠ 0) ∧
    Complex.normSq ((m : ℂ) + (n : ℂ) * tau) ≤ 2 / Real.sqrt 3 * tau.im := by
  obtain ⟨g, hg⟩ := ModularGroup.exists_smul_mem_fd tau
  simp only [ModularGroup.fd, Set.mem_setOf_eq] at hg
  set sigma := g • tau with hs
  have hsq3pos : 0 < Real.sqrt 3 := Real.sqrt_pos.mpr (by norm_num)
  have him : Real.sqrt 3 / 2 ≤ sigma.im := by
    have h1 : 1 ≤ Complex.normSq (sigma : ℂ) := hg.1
    have h2 : |sigma.re| ≤ 1 / 2 := by simpa using hg.2
    have hns : Complex.normSq (sigma : ℂ) = sigma.re ^ 2 + sigma.im ^ 2 := by
      rw [Complex.normSq_apply, UpperHalfPlane.coe_re, UpperHalfPlane.coe_im]; ring
    rw [hns] at h1
    have h3 : sigma.re ^ 2 ≤ 1 / 4 := by nlinarith [abs_nonneg sigma.re, sq_abs sigma.re]
    nlinarith [sigma.im_pos, Real.sq_sqrt (show (0:ℝ) ≤ 3 by norm_num)]
  have hkey : sigma.im = tau.im / Complex.normSq (UpperHalfPlane.denom (g : GL (Fin 2) ℝ) tau) :=
    ModularGroup.im_smul_eq_div_normSq g tau
  have hden : UpperHalfPlane.denom (g : GL (Fin 2) ℝ) (tau : ℂ)
      = ((g : Matrix (Fin 2) (Fin 2) ℤ) 1 1 : ℂ) +
        ((g : Matrix (Fin 2) (Fin 2) ℤ) 1 0 : ℂ) * tau := by
    rw [ModularGroup.denom_apply]; ring
  have hpos : 0 < Complex.normSq (UpperHalfPlane.denom (g : GL (Fin 2) ℝ) (tau : ℂ)) := by
    rcases lt_or_eq_of_le (Complex.normSq_nonneg
        (UpperHalfPlane.denom (g : GL (Fin 2) ℝ) (tau : ℂ))) with h | h
    · exact h
    · rw [← h, div_zero] at hkey
      exact absurd hkey (ne_of_gt sigma.im_pos)
  refine ⟨(g : Matrix (Fin 2) (Fin 2) ℤ) 1 1, (g : Matrix (Fin 2) (Fin 2) ℤ) 1 0, ?_, ?_⟩
  · by_contra hcon
    push_neg at hcon
    have hdet := g.property
    rw [Matrix.det_fin_two, hcon.1, hcon.2] at hdet
    simp at hdet
  · rw [← hden]
    rw [hkey, le_div_iff₀ hpos] at him
    rw [div_mul_eq_mul_div, le_div_iff₀ hsq3pos]
    linarith

/-- The quadratic form of the hexagonal lattice: `|m + n ρ|² = m² - m n + n²`. -/
theorem rho_normSq (m n : ℤ) :
    Complex.normSq ((m : ℂ) + (n : ℂ) * rho) = (m : ℝ) ^ 2 - m * n + n ^ 2 := by
  have h3 : Real.sqrt 3 ^ 2 = 3 := Real.sq_sqrt (by norm_num)
  simp [Complex.normSq_apply, rho]
  ring_nf
  nlinarith [h3]

/-- Every nonzero value of the hexagonal quadratic form is at least `1`. -/
theorem one_le_hexagonal_form (m n : ℤ) (h : m ≠ 0 ∨ n ≠ 0) : 1 ≤ m ^ 2 - m * n + n ^ 2 := by
  have hx0 : 0 ≤ m ^ 2 - m * n + n ^ 2 := by nlinarith [sq_nonneg (2 * m - n), sq_nonneg n]
  have hxne : m ^ 2 - m * n + n ^ 2 ≠ 0 := by
    intro hx
    have hn : n = 0 := by nlinarith [sq_nonneg (2 * m - n), sq_nonneg n]
    have hm : m = 0 := by rw [hn] at hx; nlinarith
    rcases h with h | h
    · exact h hm
    · exact h hn
  omega

/-- **The hexagonal torus attains the systolic bound**: every nonzero lattice vector of `ρ`
has squared length at least `(2/√3) · Im ρ = 1`. -/
theorem le_normSq_rho (m n : ℤ) (h : m ≠ 0 ∨ n ≠ 0) :
    2 / Real.sqrt 3 * rho.im ≤ Complex.normSq ((m : ℂ) + (n : ℂ) * rho) := by
  have hpos : 0 < Real.sqrt 3 := Real.sqrt_pos.mpr (by norm_num)
  have hone : 2 / Real.sqrt 3 * rho.im = 1 := by
    show 2 / Real.sqrt 3 * (Real.sqrt 3 / 2) = 1
    field_simp
  rw [hone, rho_normSq]
  have := one_le_hexagonal_form m n h
  have hcast : (1 : ℝ) ≤ ((m ^ 2 - m * n + n ^ 2 : ℤ) : ℝ) := by exact_mod_cast this
  push_cast at hcast
  linarith

/-- **Hermite's constant in dimension two is exactly `2/√3`.**  The bound of
`exists_short_lattice_vector` holds for every marked torus, and no smaller constant works:
at the hexagonal torus `ρ` every nonzero lattice vector already has squared length exceeding
`c · Im ρ` for each `c < 2/√3`. -/
theorem hermite_two_sharp {c : ℝ} (hc : c < 2 / Real.sqrt 3) :
    ∃ tau : ℍ, ∀ m n : ℤ, (m ≠ 0 ∨ n ≠ 0) →
      c * tau.im < Complex.normSq ((m : ℂ) + (n : ℂ) * tau) := by
  refine ⟨rho, fun m n h => ?_⟩
  have him : (0 : ℝ) < rho.im := rho.im_pos
  calc c * rho.im < 2 / Real.sqrt 3 * rho.im := by
        exact (mul_lt_mul_iff_of_pos_right him).mpr hc
    _ ≤ _ := le_normSq_rho m n h

end Teichmuller