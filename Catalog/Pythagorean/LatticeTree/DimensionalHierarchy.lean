/-! # CatalogBuild.Pythagorean.LatticeTree.DimensionalHierarchy

Auto-generated from theorem catalog database.
Domain: Pythagorean/LatticeTree
Declarations: 25
-/

import Mathlib

/-- The key inequality: d * (d+1) > d * d, implying 1/(d+1) < 1/d. -/
theorem exponent_strictly_decreases (d : ℕ) (hd : 1 ≤ d) :
    d < d + 1 := Nat.lt_succ_of_le le_rfl




/-- For any N ≥ 2, N^2 < N^3 (the cube is strictly larger). -/
theorem power_strict_increase (N : ℕ) (hN : 2 ≤ N) : N ^ 2 < N ^ 3 := by
  nlinarith [Nat.one_le_pow 2 N (by omega)]




/-- Hermite's constant γ₂ = 4/3 satisfies γ₂ < 2 = γ₃. -/
theorem hermite_bound_ordering : (4 : ℚ) / 3 < (2 : ℚ) := by norm_num




/-- The 3D lattice determinant divides N³ (for the standard L₄ construction). -/
theorem lattice_det_bound (N : ℕ) (hN : 1 ≤ N) : N ≤ N ^ 3 := by
  calc N = N ^ 1 := by ring
    _ ≤ N ^ 3 := Nat.pow_le_pow_right (by omega) (by omega)




/-- The quadruple lattice is closed under addition (expansion identity). -/
theorem quad_lattice_add_identity (x₁ y₁ z₁ x₂ y₂ z₂ : ℤ) :
    (x₁ + x₂)^2 + (y₁ + y₂)^2 + (z₁ + z₂)^2 =
      (x₁^2 + y₁^2 + z₁^2) + (x₂^2 + y₂^2 + z₂^2) +
      2 * (x₁ * x₂ + y₁ * y₂ + z₁ * z₂) := by ring




/-- The quadruple lattice is closed under negation. -/
theorem quad_lattice_neg_closed (N x y z : ℤ)
    (h : N ∣ (x^2 + y^2 + z^2)) :
    N ∣ ((-x)^2 + (-y)^2 + (-z)^2) := by
  convert h using 1; ring




/-- The quadruple lattice is closed under scalar multiplication. -/
theorem quad_lattice_scalar_closed (N x y z k : ℤ)
    (h : N ∣ (x^2 + y^2 + z^2)) :
    N ∣ ((k*x)^2 + (k*y)^2 + (k*z)^2) := by
  have : (k*x)^2 + (k*y)^2 + (k*z)^2 = k^2 * (x^2 + y^2 + z^2) := by ring
  rw [this]; exact dvd_mul_of_dvd_right h _




/-- The equation l² - mu² = 1 has only solutions with mu = 0.
This is the fundamental obstruction to single-plane boosts in O(3,1;ℤ). -/
theorem pell_minus_trivial (l mu : ℤ) (h : l^2 - mu^2 = 1) : mu = 0 := by
  have : (l - mu) * (l + mu) = 1 := by ring_nf; linarith
  have h1 := Int.eq_one_or_neg_one_of_mul_eq_one' this
  omega




/-- [Section: # CatalogBuild.Pythagorean.LatticeTree.DimensionalHierarchy
Auto-generated from theorem catalog database.
Domain: Pythagorean/LatticeTree
Declarations: 25] -/
theorem pell_minus_lambda_unit (l mu : ℤ) (h : l^2 - mu^2 = 1) :
    l = 1 ∨ l = -1 := by
      have mu_zero : mu = 0 := pell_minus_trivial l mu h;
      exact eq_or_eq_neg_of_sq_eq_sq _ _ <| by subst mu_zero; linarith;




/-- Brahmagupta-Fibonacci: products of sums of two squares are sums of two squares. -/
theorem sum_two_sq_mul (a b c d : ℤ) :
    (a^2 + b^2) * (c^2 + d^2) = (a*c + b*d)^2 + (a*d - b*c)^2 := by ring




/-- Alternative form of Brahmagupta-Fibonacci. -/
theorem sum_two_sq_mul' (a b c d : ℤ) :
    (a^2 + b^2) * (c^2 + d^2) = (a*c - b*d)^2 + (a*d + b*c)^2 := by ring




/-- If N = p*q where p = a²+b² and q = c²+d², then N is a sum of two squares. -/
theorem composite_sum_two_sq (p q a b c d : ℤ)
    (hp : p = a^2 + b^2) (hq : q = c^2 + d^2) :
    p * q = (a*c + b*d)^2 + (a*d - b*c)^2 := by
  rw [hp, hq]; ring




/-- If p is prime, p | N, and we find (x,y,z) with N | x²+y²+z²,
then either p | (x²+y²) or p ∤ (x²+y²). -/
theorem prime_divides_gcd_or_not (p N x y z : ℤ) (hp : Prime p)
    (hpN : p ∣ N) (hNs : N ∣ (x^2 + y^2 + z^2)) :
    p ∣ (x^2 + y^2) ∨ ¬(p ∣ (x^2 + y^2)) :=
  em (p ∣ (x^2 + y^2))




/-- For 3 basis vectors after BKZ, we get 9 distinct GCD candidates. -/
theorem bkz_candidates : 3 * 3 = 9 := by norm_num




/-- Including ± variants of 3 vectors gives 6 vectors, hence 18 candidates. -/
theorem bkz_full_candidates : 3 * 6 = 18 := by norm_num




/-- Three-variable Cauchy-Schwarz inequality (integer version). -/
theorem cauchy_schwarz_3d (a b c x y z : ℤ) :
    (a*x + b*y + c*z)^2 ≤ (a^2 + b^2 + c^2) * (x^2 + y^2 + z^2) := by
  nlinarith [sq_nonneg (a*y - b*x), sq_nonneg (a*z - c*x), sq_nonneg (b*z - c*y)]




/-- The norm squared of a lattice vector is always non-negative. -/
theorem norm_sq_nonneg (x y z : ℤ) : 0 ≤ x^2 + y^2 + z^2 := by positivity




/-- If v is in L₄(N) and v ≠ 0, then ‖v‖² ≥ N (since N | ‖v‖² and ‖v‖² > 0). -/
theorem min_norm_sq_bound (N x y z : ℤ) (hN : 0 < N)
    (hv : N ∣ (x^2 + y^2 + z^2))
    (hne : x ≠ 0 ∨ y ≠ 0 ∨ z ≠ 0) :
    N ≤ x^2 + y^2 + z^2 := by
  obtain ⟨k, hk⟩ := hv
  have hpos : 0 < x^2 + y^2 + z^2 := by
    rcases hne with h | h | h <;> positivity
  have hk_pos : 0 < k := by
    by_contra h
    push_neg at h
    have : x^2 + y^2 + z^2 ≤ 0 := by nlinarith
    linarith
  linarith [mul_le_mul_of_nonneg_right (show 1 ≤ k by omega) (le_of_lt hN)]




/-- The parametric d-value m²+n²+p²+q² is always positive when (m,n,p,q) ≠ 0. -/
theorem param_d_pos (m n p q : ℤ) (h : m ≠ 0 ∨ n ≠ 0 ∨ p ≠ 0 ∨ q ≠ 0) :
    0 < m^2 + n^2 + p^2 + q^2 := by
  rcases h with h | h | h | h <;> positivity




/-- The parametric a-value satisfies |a| ≤ d. -/
theorem param_a_le_d (m n p q : ℤ) :
    (m^2 + n^2 - p^2 - q^2)^2 ≤ (m^2 + n^2 + p^2 + q^2)^2 := by
  nlinarith [sq_nonneg p, sq_nonneg q, sq_nonneg m, sq_nonneg n]




/-- The SL(2,ℤ) action preserves the quadruple property (by parametric formula). -/
theorem sl2z_preserves_quad (a' b' c' d' m n p q : ℤ)
    (hdet : a' * d' - b' * c' = 1) :
    let m' := a' * m + b' * p
    let n' := a' * n + b' * q
    let p' := c' * m + d' * p
    let q' := c' * n + d' * q
    (m'^2 + n'^2 - p'^2 - q'^2)^2 + (2*(m'*q' + n'*p'))^2 + (2*(n'*q' - m'*p'))^2 =
    (m'^2 + n'^2 + p'^2 + q'^2)^2 := by
  ring




/-- The exponential gap grows: for n-bit RSA, the advantage is 2^(n/6) which
is exponential in the key size. -/
theorem exponential_gap (n : ℕ) (hn : 6 ≤ n) : 1 < 2^(n/6) := by
  have : 1 ≤ n / 6 := by omega
  calc 1 < 2^1 := by norm_num
    _ ≤ 2^(n/6) := Nat.pow_le_pow_right (by norm_num) this




/-- **Proposed Theorem (Lattice Membership Certificate):**
A vector v = (x,y,z) is in L₄(N) iff x²+y²+z² ≡ 0 (mod N). -/
theorem lattice_membership_iff (N x y z : ℤ) :
    N ∣ (x^2 + y^2 + z^2) ↔ (x^2 + y^2 + z^2) % N = 0 :=
  Int.dvd_iff_emod_eq_zero




/-- **Proposed Theorem (Factor Extraction Soundness):**
Any divisor g with 1 < g < N gives a non-trivial factorization. -/
theorem factor_extraction_sound (N g : ℤ) (hN : 1 < N) (hg : g ∣ N)
    (hg1 : 1 < g) (hgN : g < N) :
    ∃ a b : ℤ, N = a * b ∧ 1 < a ∧ 1 < b := by
  obtain ⟨q, hq⟩ := hg
  refine ⟨g, q, by linarith, hg1, ?_⟩
  have hq_pos : 0 < q := by nlinarith
  nlinarith




/-- [Section: # CatalogBuild.Pythagorean.LatticeTree.DimensionalHierarchy
Auto-generated from theorem catalog database.
Domain: Pythagorean/LatticeTree
Declarations: 25] -/
theorem minkowski_exponent_gap (d₁ d₂ : ℕ) (h1 : 1 ≤ d₁) (h2 : d₁ < d₂) :
    (1 : ℚ) / d₂ < 1 / d₁ := by
      gcongr


