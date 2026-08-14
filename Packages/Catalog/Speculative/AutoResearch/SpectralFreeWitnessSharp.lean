/-
# Sharpness, rigidity, and the arithmetic payload of the spectral free-witness

Adversarial follow-up to `Algebra.SpectralFreeWitness`:

* `heatReturn_injective` — **rigidity**: on the range `r ≤ N` the single heat-kernel
  value determines the order, so `r ↦ p_n(e)` is injective there.
* `heatReturn_approx_multiplicative` — an **honest correction** to the claim that the
  heat-kernel witness is "non-multiplicative": as a *function of the order* the witness
  value is multiplicative up to `1/N²`, since it is `1/r` to that accuracy.  Only the
  *mechanism* (a spectral aggregate) is non-multiplicative, not the witness value.
* `dyadicEigen_mersenne_ge`, `dyadic_gap_isTheta` — **sharpness**: for the Mersenne
  cycle length `r = 2^M - 1` the top nontrivial dyadic eigenvalue is at least
  `1 - 106/(M+1)`, so the spectral gap of the lacunary dyadic walk really is
  `Θ(1/M)`; the `O((log N)²)` mixing time cannot be improved to `O(log N)`
  by this generator set.
* `nontrivial_factor_of_sqrt_one`, `factor_from_even_order` — the **arithmetic
  payload**: a recovered even order with a non-trivial square root of `1` splits `N`.

No `sorry`, no `native_decide`.
-/

import Mathlib
import Algebra.SpectralFreeWitness

namespace SpectralFreeWitness

open Finset Real

/-! ## 1. Rigidity of the witness -/

/-- **Rigidity.** Two cycle lengths `≤ N` with the same heat-kernel value at
`n = 8 (M+1)^2` steps are equal. -/
theorem heatReturn_injective (N M r₁ r₂ : ℕ) (h1 : 0 < r₁) (h2 : 0 < r₂)
    (hr1 : r₁ ≤ N) (hr2 : r₂ ≤ N) (hM : N ≤ 2 ^ M)
    (heq : heatReturn r₁ M (8 * (M + 1) ^ 2) = heatReturn r₂ M (8 * (M + 1) ^ 2)) :
    r₁ = r₂ := by
  have e1 := heat_kernel_order_recovery N r₁ M h1 hr1 hM
  have e2 := heat_kernel_order_recovery N r₂ M h2 hr2 hM
  rw [heq, e2] at e1
  exact_mod_cast e1.symm

/-! ## 2. The witness value is (approximately) multiplicative -/

/-- **Critique of the "non-multiplicative" label.**  The heat-kernel witness value is
`1/r` up to `1/(4N²)`, hence as a function of the order it is multiplicative up to
`1/N²`.  What is non-multiplicative is the *mechanism* (a spectral aggregate over all
`r` eigenvalues), not the witness. -/
theorem heatReturn_approx_multiplicative (N M r₁ r₂ : ℕ) (h1 : 0 < r₁) (h2 : 0 < r₂)
    (hr1 : r₁ ≤ N) (hr2 : r₂ ≤ N) (hprod : r₁ * r₂ ≤ N) (hM : N ≤ 2 ^ M) :
    |heatReturn (r₁ * r₂) M (8 * (M + 1) ^ 2)
      - heatReturn r₁ M (8 * (M + 1) ^ 2) * heatReturn r₂ M (8 * (M + 1) ^ 2)|
      ≤ 1 / (N : ℝ) ^ 2 := by
  have hN : 0 < N := lt_of_lt_of_le h1 hr1
  have hN0 : (0 : ℝ) < N := by exact_mod_cast hN
  have hp : 0 < r₁ * r₂ := Nat.mul_pos h1 h2
  set n := 8 * (M + 1) ^ 2 with hn
  set ε : ℝ := 1 / (4 * (N : ℝ) ^ 2) with hε
  have hεpos : 0 < ε := by rw [hε]; positivity
  have hmix := beta_pow_le N M hN hM
  -- three instances of the two-sided estimate
  have key : ∀ r : ℕ, 0 < r → r ≤ N →
      1 / (r : ℝ) ≤ heatReturn r M n ∧ heatReturn r M n ≤ 1 / (r : ℝ) + ε := by
    intro r hr hrN
    refine ⟨heatReturn_lower r M n hr, ?_⟩
    have := heatReturn_upper r M n hr (le_trans hrN hM)
    linarith
  obtain ⟨l1, u1⟩ := key r₁ h1 hr1
  obtain ⟨l2, u2⟩ := key r₂ h2 hr2
  obtain ⟨lp, up⟩ := key (r₁ * r₂) hp hprod
  have hc1 : (0 : ℝ) < r₁ := by exact_mod_cast h1
  have hc2 : (0 : ℝ) < r₂ := by exact_mod_cast h2
  have hr1' : (r₁ : ℝ) ≤ N := by exact_mod_cast hr1
  have hr2' : (r₂ : ℝ) ≤ N := by exact_mod_cast hr2
  have hcp : ((r₁ * r₂ : ℕ) : ℝ) = (r₁ : ℝ) * r₂ := by push_cast; ring
  have hone1 : 1 / (r₁ : ℝ) ≤ 1 := by
    rw [div_le_one hc1]; exact_mod_cast h1
  have hone2 : 1 / (r₂ : ℝ) ≤ 1 := by
    rw [div_le_one hc2]; exact_mod_cast h2
  have hεle : ε ≤ 1 / (4 * (N : ℝ) ^ 2) := le_of_eq hε
  have h1N : (1 : ℝ) ≤ N := by exact_mod_cast hN
  have hεsmall : ε ≤ 1 / 4 := by
    rw [hε]
    exact one_div_le_one_div_of_le (by norm_num) (by nlinarith)
  -- products
  have hprodlow : 1 / (r₁ : ℝ) * (1 / (r₂ : ℝ)) ≤ heatReturn r₁ M n * heatReturn r₂ M n := by
    have hnn2 : (0 : ℝ) ≤ 1 / (r₂ : ℝ) := by positivity
    have hnn1 : (0 : ℝ) ≤ heatReturn r₁ M n := le_trans (by positivity) l1
    exact mul_le_mul l1 l2 hnn2 hnn1
  have hpu : heatReturn r₁ M n * heatReturn r₂ M n
      ≤ 1 / (r₁ : ℝ) * (1 / (r₂ : ℝ)) + 3 * ε := by
    have hstep : heatReturn r₁ M n * heatReturn r₂ M n
        ≤ (1 / (r₁ : ℝ) + ε) * (1 / (r₂ : ℝ) + ε) :=
      mul_le_mul u1 u2 (le_trans (by positivity) l2) (by positivity)
    nlinarith [hone1, hone2, hεsmall, hεpos]
  rw [abs_le]
  rw [hcp] at lp up
  have hfac : 1 / ((r₁ : ℝ) * r₂) = 1 / (r₁ : ℝ) * (1 / (r₂ : ℝ)) := by
    field_simp
  rw [hfac] at lp up
  have h4 : 4 * ε = 1 / (N : ℝ) ^ 2 := by
    rw [hε]; field_simp
  constructor
  · linarith
  · linarith

/-! ## 3. Sharpness of the spectral gap -/

/-- For the Mersenne cycle length `r = 2^M - 1` the first nontrivial dyadic
eigenvalue is at least `1 - 106/(M+1)`: the `Θ(1/M)` spectral gap of the lacunary
dyadic walk is attained up to an absolute constant. -/
theorem dyadicEigen_mersenne_ge (M : ℕ) (hM : 1 ≤ M) :
    1 - 106 / ((M : ℝ) + 1) ≤ dyadicEigen (2 ^ M - 1) M 1 := by
  have hpow : (1 : ℕ) ≤ 2 ^ M := Nat.one_le_two_pow
  have h2M : (2 : ℝ) ≤ 2 ^ M := by
    have : (2 : ℝ) ^ 1 ≤ 2 ^ M := by
      apply pow_le_pow_right₀ (by norm_num) hM
    simpa using this
  set R : ℝ := ((2 ^ M - 1 : ℕ) : ℝ) with hR
  have hRc : R = (2 : ℝ) ^ M - 1 := by
    rw [hR, Nat.cast_sub hpow]
    push_cast
    ring
  have hRpos : 0 < R := by rw [hRc]; linarith
  have hR2 : (2 : ℝ) ^ M ≤ 2 * R := by rw [hRc]; linarith
  have hRsq : (4 : ℝ) ^ M ≤ 4 * R ^ 2 := by
    have h4 : (4 : ℝ) ^ M = ((2 : ℝ) ^ M) ^ 2 := by
      rw [← pow_mul, mul_comm, pow_mul]; norm_num
    have hpos : (0 : ℝ) < 2 ^ M := by positivity
    nlinarith
  have hpi := Real.pi_pos
  have hpi2 : π ^ 2 ≤ 9.9225 := by
    nlinarith [Real.pi_lt_d2, Real.pi_pos]
  -- termwise quadratic lower bound for the cosine
  have hterm : ∀ t ∈ range (M + 1),
      1 - 2 * π ^ 2 * (4 : ℝ) ^ t / R ^ 2
        ≤ Real.cos (2 * π * ((1 * 2 ^ t : ℕ) : ℝ) / R) := by
    intro t _
    have hcos := Real.one_sub_sq_div_two_le_cos (x := 2 * π * ((1 * 2 ^ t : ℕ) : ℝ) / R)
    have hcast : ((1 * 2 ^ t : ℕ) : ℝ) = (2 : ℝ) ^ t := by push_cast; ring
    have hsq : (2 * π * ((1 * 2 ^ t : ℕ) : ℝ) / R) ^ 2 / 2 = 2 * π ^ 2 * (4 : ℝ) ^ t / R ^ 2 := by
      rw [hcast]
      have h4t : ((2 : ℝ) ^ t) ^ 2 = (4 : ℝ) ^ t := by
        rw [← pow_mul, mul_comm, pow_mul]; norm_num
      field_simp
      nlinarith [h4t]
    linarith [hsq ▸ hcos]
  have hsum : ∑ t ∈ range (M + 1), (1 - 2 * π ^ 2 * (4 : ℝ) ^ t / R ^ 2)
      ≤ ∑ t ∈ range (M + 1), Real.cos (2 * π * ((1 * 2 ^ t : ℕ) : ℝ) / R) :=
    Finset.sum_le_sum hterm
  -- evaluate the geometric sum
  have hgeom : ∑ t ∈ range (M + 1), (4 : ℝ) ^ t = ((4 : ℝ) ^ (M + 1) - 1) / 3 := by
    rw [geom_sum_eq (by norm_num)]
    norm_num
  have hleft : ∑ t ∈ range (M + 1), (1 - 2 * π ^ 2 * (4 : ℝ) ^ t / R ^ 2)
      = ((M : ℝ) + 1) - 2 * π ^ 2 * (((4 : ℝ) ^ (M + 1) - 1) / 3) / R ^ 2 := by
    rw [Finset.sum_sub_distrib, ← hgeom]
    congr 1
    · simp
    · rw [← Finset.sum_div, ← Finset.mul_sum]
  have hbound : 2 * π ^ 2 * (((4 : ℝ) ^ (M + 1) - 1) / 3) / R ^ 2 ≤ 106 := by
    have hR2pos : (0 : ℝ) < R ^ 2 := by positivity
    rw [div_le_iff₀ hR2pos]
    have h41 : (4 : ℝ) ^ (M + 1) = 4 * 4 ^ M := by ring
    have hkey : (4 : ℝ) ^ M ≤ 4 * R ^ 2 := hRsq
    nlinarith [pow_pos (by norm_num : (0:ℝ) < 4) M, sq_nonneg π]
  have hMpos : (0 : ℝ) < (M : ℝ) + 1 := by positivity
  rw [dyadicEigen, le_div_iff₀ hMpos]
  have hrhs : (1 - 106 / ((M : ℝ) + 1)) * ((M : ℝ) + 1) = ((M : ℝ) + 1) - 106 := by
    field_simp
  rw [hrhs]
  linarith [hsum, hleft, hbound]

/-- **The dyadic spectral gap is `Θ(1/M)`.**  For `r = 2^M - 1` (`M ≥ 2`) the top
nontrivial eigenvalue lies between `1 - 106/(M+1)` and `1 - 1/(M+1)`. -/
theorem dyadic_gap_isTheta (M : ℕ) (hM : 2 ≤ M) :
    1 - 106 / ((M : ℝ) + 1) ≤ dyadicEigen (2 ^ M - 1) M 1 ∧
      dyadicEigen (2 ^ M - 1) M 1 ≤ 1 - 1 / ((M : ℝ) + 1) := by
  have hpow : (4 : ℕ) ≤ 2 ^ M := by
    calc (4 : ℕ) = 2 ^ 2 := by norm_num
      _ ≤ 2 ^ M := Nat.pow_le_pow_right (by norm_num) hM
  refine ⟨dyadicEigen_mersenne_ge M (by omega), ?_⟩
  have hr : 0 < 2 ^ M - 1 := by omega
  have hmod : 1 % (2 ^ M - 1) ≠ 0 := by
    rw [Nat.mod_eq_of_lt (by omega)]
    omega
  exact dyadicEigen_le (2 ^ M - 1) M 1 hr hmod (by omega)

/-! ## 4. Arithmetic payload: a recovered order splits `N` -/

/-- A non-trivial square root of `1` modulo `N` yields a non-trivial divisor. -/
theorem nontrivial_factor_of_sqrt_one (N : ℕ) (x : ℤ) (hN : 2 ≤ N)
    (hsq : (N : ℤ) ∣ (x - 1) * (x + 1)) (h1 : ¬ (N : ℤ) ∣ (x - 1))
    (h2 : ¬ (N : ℤ) ∣ (x + 1)) :
    Int.gcd (x - 1) (N : ℤ) ∣ N ∧ 1 < Int.gcd (x - 1) (N : ℤ) ∧
      Int.gcd (x - 1) (N : ℤ) < N := by
  set d : ℕ := Int.gcd (x - 1) (N : ℤ) with hd
  have hdvdN : d ∣ N := by
    have : (d : ℤ) ∣ (N : ℤ) := Int.gcd_dvd_right _ _
    exact_mod_cast this
  have hdvdx : (d : ℤ) ∣ (x - 1) := Int.gcd_dvd_left _ _
  have hdne1 : d ≠ 1 := by
    intro h
    have hcop : IsCoprime (x - 1) (N : ℤ) := Int.isCoprime_iff_gcd_eq_one.mpr (by rw [← hd, h])
    exact h2 (hcop.symm.dvd_of_dvd_mul_left hsq)
  have hdneN : d ≠ N := by
    intro h
    apply h1
    rw [← h]
    exact hdvdx
  have hdne0 : d ≠ 0 := by
    intro h
    rw [hd, Int.gcd_eq_zero_iff] at h
    have : (N : ℤ) = 0 := h.2
    have : N = 0 := by exact_mod_cast this
    omega
  have hdleN : d ≤ N := Nat.le_of_dvd (by omega) hdvdN
  exact ⟨hdvdN, by omega, by omega⟩

/-- **From a recovered order to a factorisation.**  If the heat-kernel witness returns
an even order `2m` for the base `b`, and `b^m` is not `±1` mod `N`, then `N` has a
non-trivial divisor, computed by one gcd. -/
theorem factor_from_even_order (N b m : ℕ) (hN : 2 ≤ N)
    (hord : (N : ℤ) ∣ ((b : ℤ) ^ (2 * m) - 1))
    (h1 : ¬ (N : ℤ) ∣ ((b : ℤ) ^ m - 1)) (h2 : ¬ (N : ℤ) ∣ ((b : ℤ) ^ m + 1)) :
    ∃ d : ℕ, d ∣ N ∧ 1 < d ∧ d < N := by
  refine ⟨Int.gcd ((b : ℤ) ^ m - 1) (N : ℤ), ?_⟩
  have hsq : (N : ℤ) ∣ ((b : ℤ) ^ m - 1) * ((b : ℤ) ^ m + 1) := by
    have hfac : ((b : ℤ) ^ m - 1) * ((b : ℤ) ^ m + 1) = (b : ℤ) ^ (2 * m) - 1 := by
      rw [two_mul, pow_add]; ring
    rw [hfac]
    exact hord
  exact nontrivial_factor_of_sqrt_one N ((b : ℤ) ^ m) hN hsq h1 h2

end SpectralFreeWitness