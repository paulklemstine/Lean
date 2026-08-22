import Physics.GradedTransitivityRootsOfUnity

/-!
# Grade counts periodic mod `m`: a residue at every `m`-th root of unity

`Physics.GradedTransitivityRootsOfUnity` computed the singularities of a partition function
whose coefficients are a finite exponential sum `aₙ = ∑ᵢ Aᵢ wᵢⁿ`.  This file supplies the
missing combinatorial input in the case of real interest: a grade count that is **periodic
mod `m`** is such an exponential sum, with the twists running over the `m`-th roots of unity
and the amplitudes given by the discrete Fourier transform of one period.

Consequently the partition function of a graded object whose grade counts are eventually
periodic mod `m` has a simple pole at **every** `m`-th root of unity, and the residue at the
pole `ζ^{-k}` is

  `-Âₖ / ζᵏ`,   `Âₖ = (1/m) ∑_{j<m} ζ^{-kj} c_j`.

At `k = 0` the pole is `q = 1` and the residue is `-(1/m) ∑_{j<m} c_j`, minus the *mean* of
one period — which recovers the residue `-c` of the eventually constant case and
`-(c₀+c₁)/2` of the two-periodic case proved earlier in this thread.

## Main results

* `Physics.GradedTransitivity.sum_pow_eq_zero_of_root_ne_one` — orthogonality of characters.
* `Physics.GradedTransitivity.periodic_eq_fourier_sum` — discrete Fourier inversion: a
  sequence periodic mod `m` is the exponential sum over the `m`-th roots of unity.
* `Physics.GradedTransitivity.circleIntegral_eventually_periodic_mod` — the residue of any
  analytic continuation at the pole `ζ^{-k}`.
* `Physics.GradedTransitivity.circleIntegral_periodic_mod_at_one` — at `q = 1` the residue is
  minus the mean of one period.
-/

namespace Physics.GradedTransitivity

open Finset Complex Filter Topology

/-- **Orthogonality of characters.**  A nontrivial `m`-th root of unity has vanishing
character sum. -/
theorem sum_pow_eq_zero_of_root_ne_one {m : ℕ} {u : ℂ} (hu : u ^ m = 1) (hne : u ≠ 1) :
    ∑ k ∈ range m, u ^ k = 0 := by
  rw [geom_sum_eq hne m, hu, sub_self, zero_div]

/-- The `k`-th discrete Fourier amplitude of one period `c 0, …, c (m-1)`. -/
noncomputable def fourierAmp (zeta : ℂ) (c : ℕ → ℂ) (m k : ℕ) : ℂ :=
  (m : ℂ)⁻¹ * ∑ j ∈ range m, (zeta ^ (k * j))⁻¹ * c j

theorem fourierAmp_zero (zeta : ℂ) (c : ℕ → ℂ) (m : ℕ) :
    fourierAmp zeta c m 0 = (m : ℂ)⁻¹ * ∑ j ∈ range m, c j := by
  rw [fourierAmp]
  congr 1
  refine Finset.sum_congr rfl fun j _ => ?_
  rw [Nat.zero_mul, pow_zero, inv_one, one_mul]

/-- **Discrete Fourier inversion.**  A sequence that is periodic mod `m` is the exponential
sum over the `m`-th roots of unity with the Fourier amplitudes as coefficients. -/
theorem periodic_eq_fourier_sum {m : ℕ} (hm : 0 < m) {zeta : ℂ}
    (hz : IsPrimitiveRoot zeta m) (c : ℕ → ℂ) (n : ℕ) :
    c (n % m) = ∑ k : Fin m, fourierAmp zeta c m k * (zeta ^ (k : ℕ)) ^ n := by
  have hmC : (m : ℂ) ≠ 0 := Nat.cast_ne_zero.mpr hm.ne'
  have hzm : zeta ^ m = 1 := hz.pow_eq_one
  have hz0 : zeta ≠ 0 := by
    intro h
    rw [h, zero_pow hm.ne'] at hzm
    exact zero_ne_one hzm
  have hterm : ∀ k j : ℕ, (zeta ^ (k * j))⁻¹ * c j * (zeta ^ k) ^ n
      = c j * (zeta ^ n * (zeta ^ j)⁻¹) ^ k := by
    intro k j
    have h : (zeta ^ (k * j))⁻¹ * (zeta ^ k) ^ n = (zeta ^ n * (zeta ^ j)⁻¹) ^ k := by
      rw [mul_pow, ← pow_mul, ← inv_pow, ← pow_mul, Nat.mul_comm k j, Nat.mul_comm n k]
      ring
    calc (zeta ^ (k * j))⁻¹ * c j * (zeta ^ k) ^ n
        = ((zeta ^ (k * j))⁻¹ * (zeta ^ k) ^ n) * c j := by ring
      _ = c j * (zeta ^ n * (zeta ^ j)⁻¹) ^ k := by rw [h]; ring
  have hk : ∀ k : ℕ, fourierAmp zeta c m k * (zeta ^ k) ^ n
      = ∑ j ∈ range m, (m : ℂ)⁻¹ * (c j * (zeta ^ n * (zeta ^ j)⁻¹) ^ k) := by
    intro k
    rw [fourierAmp, mul_assoc, Finset.sum_mul, Finset.mul_sum]
    exact Finset.sum_congr rfl fun j _ => by rw [hterm k j]
  have hupow : ∀ j : ℕ, (zeta ^ n * (zeta ^ j)⁻¹) ^ m = 1 := by
    intro j
    have h1 : (zeta ^ n) ^ m = 1 := by rw [← pow_mul, Nat.mul_comm, pow_mul, hzm, one_pow]
    have h2 : (zeta ^ j) ^ m = 1 := by rw [← pow_mul, Nat.mul_comm, pow_mul, hzm, one_pow]
    rw [mul_pow, h1, inv_pow, h2, inv_one, mul_one]
  have hinner : ∀ j : ℕ, j < m → (∑ k ∈ range m, (zeta ^ n * (zeta ^ j)⁻¹) ^ k)
      = if j = n % m then (m : ℂ) else 0 := by
    intro j hjm
    by_cases hcase : j = n % m
    · have hone : zeta ^ n * (zeta ^ j)⁻¹ = 1 := by
        rw [hcase, pow_eq_pow_mod n hzm]
        field_simp
      rw [hone, if_pos hcase]
      simp
    · have hne : zeta ^ n * (zeta ^ j)⁻¹ ≠ 1 := by
        intro h
        have hpow : zeta ^ n = zeta ^ j := by
          field_simp at h
          exact h
        rw [pow_eq_pow_mod n hzm] at hpow
        exact hcase (hz.pow_inj (Nat.mod_lt n hm) hjm hpow).symm
      rw [sum_pow_eq_zero_of_root_ne_one (hupow j) hne, if_neg hcase]
  calc c (n % m)
      = ∑ j ∈ range m, (m : ℂ)⁻¹ * (c j * ∑ k ∈ range m, (zeta ^ n * (zeta ^ j)⁻¹) ^ k) := by
        rw [Finset.sum_eq_single (n % m)]
        · rw [hinner (n % m) (Nat.mod_lt n hm), if_pos rfl]
          field_simp
        · intro b hb hbne
          rw [hinner b (mem_range.mp hb), if_neg hbne]
          simp
        · intro h
          exact absurd (mem_range.mpr (Nat.mod_lt n hm)) h
    _ = ∑ j ∈ range m, ∑ k ∈ range m, (m : ℂ)⁻¹ * (c j * (zeta ^ n * (zeta ^ j)⁻¹) ^ k) := by
        refine Finset.sum_congr rfl fun j _ => ?_
        rw [Finset.mul_sum, Finset.mul_sum]
    _ = ∑ k ∈ range m, ∑ j ∈ range m, (m : ℂ)⁻¹ * (c j * (zeta ^ n * (zeta ^ j)⁻¹) ^ k) :=
        Finset.sum_comm
    _ = ∑ k : Fin m, fourierAmp zeta c m k * (zeta ^ (k : ℕ)) ^ n := by
        rw [Fin.sum_univ_eq_sum_range fun k => fourierAmp zeta c m k * (zeta ^ k) ^ n]
        exact (Finset.sum_congr rfl fun k _ => hk k).symm

/-! ### The residues of an eventually periodic grade count -/

section Periodic

variable {m : ℕ} {zeta : ℂ}

/-- Every root of unity is a legitimate twist: nonzero and of norm one. -/
theorem norm_root_pow_eq_one (hm : 0 < m) (hz : IsPrimitiveRoot zeta m) (k : ℕ) :
    ‖zeta ^ k‖ = 1 := by
  rw [norm_pow, Complex.norm_eq_one_of_pow_eq_one hz.pow_eq_one hm.ne', one_pow]

theorem root_pow_ne_zero (hm : 0 < m) (hz : IsPrimitiveRoot zeta m) (k : ℕ) : zeta ^ k ≠ 0 := by
  intro h
  have := norm_root_pow_eq_one hm hz k
  rw [h, norm_zero] at this
  exact zero_ne_one this

theorem zero_notMem_twistPoles_root (hm : 0 < m) (hz : IsPrimitiveRoot zeta m) :
    (0 : ℂ) ∉ twistPoles fun k : Fin m => zeta ^ (k : ℕ) := by
  rintro ⟨i, hi⟩
  exact root_pow_ne_zero hm hz (i : ℕ) (inv_eq_zero.mp hi)

/-- **The residue at every `m`-th root of unity.**  If the grade counts of a generating
function are eventually periodic mod `m` with period values `c 0, …, c (m-1)`, then every
analytic continuation off the `m`-th roots of unity has residue `-Âₖ/ζᵏ` at the pole
`ζ^{-k}`. -/
theorem circleIntegral_eventually_periodic_mod (hm : 0 < m) (hz : IsPrimitiveRoot zeta m)
    {c a : ℕ → ℂ} {N : ℕ} (hcoef : ∀ n, N ≤ n → a n = c (n % m)) {F : ℂ → ℂ}
    (hF : AnalyticOnNhd ℂ F (twistPoles fun k : Fin m => zeta ^ (k : ℕ))ᶜ)
    (hF0 : ∀ᶠ q in 𝓝 (0 : ℂ), F q = ∑' n : ℕ, a n * q ^ n)
    (k : Fin m) {ρ : ℝ} (hρ : 0 < ρ)
    (hsep : ∀ i : Fin m, i ≠ k → ρ < dist ((zeta ^ (k : ℕ))⁻¹) ((zeta ^ (i : ℕ))⁻¹)) :
    (∮ z in C((zeta ^ (k : ℕ))⁻¹, ρ), F z)
      = (-(fourierAmp zeta c m (k : ℕ)) / zeta ^ (k : ℕ)) * (2 * (Real.pi : ℂ) * I) := by
  have hcoef' : ∀ n, N ≤ n →
      a n = ∑ i : Fin m, (fun i : Fin m => fourierAmp zeta c m (i : ℕ)) i
        * ((fun i : Fin m => zeta ^ (i : ℕ)) i) ^ n := by
    intro n hn
    rw [hcoef n hn]
    exact periodic_eq_fourier_sum hm hz c n
  exact circleIntegral_eventually_exponential (ι := Fin m)
    (A := fun i : Fin m => fourierAmp zeta c m (i : ℕ))
    (w := fun i : Fin m => zeta ^ (i : ℕ))
    (fun i => root_pow_ne_zero hm hz (i : ℕ)) hcoef'
    (fun i => le_of_eq (norm_root_pow_eq_one hm hz (i : ℕ)))
    (zero_notMem_twistPoles_root hm hz) hF hF0 k hρ hsep

/-- **The residue at `q = 1` is minus the mean of one period.**  This unifies the residue `-c`
of the eventually constant case and `-(c₀+c₁)/2` of the two-periodic case. -/
theorem circleIntegral_periodic_mod_at_one (hm : 0 < m) (hz : IsPrimitiveRoot zeta m)
    {c a : ℕ → ℂ} {N : ℕ} (hcoef : ∀ n, N ≤ n → a n = c (n % m)) {F : ℂ → ℂ}
    (hF : AnalyticOnNhd ℂ F (twistPoles fun k : Fin m => zeta ^ (k : ℕ))ᶜ)
    (hF0 : ∀ᶠ q in 𝓝 (0 : ℂ), F q = ∑' n : ℕ, a n * q ^ n)
    {ρ : ℝ} (hρ : 0 < ρ)
    (hsep : ∀ i : Fin m, i ≠ (⟨0, hm⟩ : Fin m) →
      ρ < dist ((zeta ^ (0 : ℕ))⁻¹) ((zeta ^ (i : ℕ))⁻¹)) :
    (∮ z in C((1 : ℂ), ρ), F z)
      = -((m : ℂ)⁻¹ * ∑ j ∈ range m, c j) * (2 * (Real.pi : ℂ) * I) := by
  have hzero : ((⟨0, hm⟩ : Fin m) : ℕ) = 0 := rfl
  have hmain := circleIntegral_eventually_periodic_mod hm hz hcoef hF hF0 (⟨0, hm⟩ : Fin m) hρ
    (by simpa only [hzero] using hsep)
  rw [hzero, pow_zero, inv_one] at hmain
  rw [hmain, fourierAmp_zero]
  field_simp

end Periodic

end Physics.GradedTransitivity