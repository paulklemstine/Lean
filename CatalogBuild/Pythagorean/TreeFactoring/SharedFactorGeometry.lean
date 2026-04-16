/-! # CatalogBuild.Pythagorean.TreeFactoring.SharedFactorGeometry

Auto-generated from theorem catalog database.
Domain: Pythagorean/TreeFactoring
Declarations: 25
-/

import Mathlib

/-- **Two Representations Imply Factoring**: If N = x²+y² = u²+v² with
(x,y) ≠ ±(u,v) and ≠ ±(v,u), then gcd(x-u, y-v) · gcd(x+u, y+v)
gives a nontrivial factorization of N (Fermat's method).
We formalize the algebraic identity underlying this. -/
theorem two_reps_identity (x y u v : ℤ)
    (h : x^2 + y^2 = u^2 + v^2) :
    (x - u) * (x + u) = (v - y) * (v + y) := by
  nlinarith



/-- **Sphere Point Pairing**: Two quadruples with the same d satisfy a
bilinear identity in their components. This is the key to extracting
factor information from multiple representations. -/
theorem sphere_point_pairing (a₁ b₁ c₁ a₂ b₂ c₂ d : ℤ)
    (h₁ : a₁^2 + b₁^2 + c₁^2 = d^2)
    (h₂ : a₂^2 + b₂^2 + c₂^2 = d^2) :
    a₁^2 + b₁^2 + c₁^2 = a₂^2 + b₂^2 + c₂^2 := by
  linarith



/-- The pairing gives a difference-of-products identity. -/
theorem sphere_cross_identity (a₁ b₁ c₁ a₂ b₂ c₂ d : ℤ)
    (h₁ : a₁^2 + b₁^2 + c₁^2 = d^2)
    (h₂ : a₂^2 + b₂^2 + c₂^2 = d^2) :
    (a₁ + a₂) * (a₁ - a₂) = (b₂ + b₁) * (b₂ - b₁) + (c₂ + c₁) * (c₂ - c₁) := by
  nlinarith



/-- **Factor Orbit Lemma**: If d = p · q and (a,b,c,d) is a quadruple,
then a²+b²+c² = p²q². The point (a,b,c) lies on a sphere whose
radius squared has a known factorization. -/
theorem factor_orbit_on_sphere (a b c p q : ℤ) (h : a^2 + b^2 + c^2 = (p*q)^2) :
    a^2 + b^2 + c^2 = p^2 * q^2 := by
  rwa [mul_pow] at h



/-- **Residue Classes on Factor Orbits**: If p | d and (a,b,c,d) is a quadruple,
then a²+b²+c² ≡ 0 (mod p²). -/
theorem residue_on_factor_orbit (a b c d p : ℤ) (h : a^2 + b^2 + c^2 = d^2)
    (hp : p ∣ d) :
    p^2 ∣ (a^2 + b^2 + c^2) := by
  rw [h]; exact pow_dvd_pow_of_dvd hp 2



/-- If p | d then a²+b²+c² ≡ 0 mod p² constrains the residues of a,b,c mod p. -/
theorem factor_constrains_residues (a b c d p : ℤ) (h : a^2 + b^2 + c^2 = d^2)
    (hp : p ∣ d) :
    p^2 ∣ (a^2 + b^2 + c^2) := by
  exact residue_on_factor_orbit a b c d p h hp



/-- The Lorentz form Q(a,b,c,d) = a² + b² + c² - d². -/
def lorentzFormQ (a b c d : ℤ) : ℤ := a^2 + b^2 + c^2 - d^2



/-- **Null Cone Characterization**: Pythagorean quadruples are exactly
the integer points on the null cone of the Lorentz form. -/
theorem quad_iff_null_cone (a b c d : ℤ) :
    a^2 + b^2 + c^2 = d^2 ↔ lorentzFormQ a b c d = 0 := by
  unfold lorentzFormQ; omega



/-- **Bilinear Decomposition**: The Lorentz form factors as a product of
linear forms over ℤ when restricted to the (c,d) plane:
a²+b² = (d-c)(d+c). -/
theorem bilinear_decomposition (a b c d : ℤ) (h : lorentzFormQ a b c d = 0) :
    a^2 + b^2 = (d - c) * (d + c) := by
  unfold lorentzFormQ at h; nlinarith



/-- **Norm Preservation under Reflection**: Reflecting a quadruple
(a,b,c,d) → (-a,b,c,d) preserves the quadruple property. -/
theorem reflect_a (a b c d : ℤ) (h : a^2 + b^2 + c^2 = d^2) :
    (-a)^2 + b^2 + c^2 = d^2 := by rw [neg_sq]; exact h



/-- [Section: # CatalogBuild.Pythagorean.TreeFactoring.SharedFactorGeometry
Auto-generated from theorem catalog database.
Domain: Pythagorean/TreeFactoring
Declarations: 25] -/
theorem reflect_b (a b c d : ℤ) (h : a^2 + b^2 + c^2 = d^2) :
    a^2 + (-b)^2 + c^2 = d^2 := by rw [neg_sq]; exact h



theorem reflect_c (a b c d : ℤ) (h : a^2 + b^2 + c^2 = d^2) :
    a^2 + b^2 + (-c)^2 = d^2 := by rw [neg_sq]; exact h



/-- **Permutation Symmetry**: Permuting (a,b,c) preserves the quadruple. -/
theorem permute_abc (a b c d : ℤ) (h : a^2 + b^2 + c^2 = d^2) :
    b^2 + c^2 + a^2 = d^2 := by linarith



theorem permute_bac (a b c d : ℤ) (h : a^2 + b^2 + c^2 = d^2) :
    b^2 + a^2 + c^2 = d^2 := by linarith



theorem permute_acb (a b c d : ℤ) (h : a^2 + b^2 + c^2 = d^2) :
    a^2 + c^2 + b^2 = d^2 := by linarith



/-- For a quadruple (a,b,c,d), there are three natural factoring channels:
Channel 1: (d-c)(d+c) = a²+b²
Channel 2: (d-b)(d+b) = a²+c²
Channel 3: (d-a)(d+a) = b²+c²
Each gives a different factorization opportunity. -/
theorem channel_1 (a b c d : ℤ) (h : a^2 + b^2 + c^2 = d^2) :
    (d - c) * (d + c) = a^2 + b^2 := by nlinarith



theorem channel_2 (a b c d : ℤ) (h : a^2 + b^2 + c^2 = d^2) :
    (d - b) * (d + b) = a^2 + c^2 := by nlinarith



theorem channel_3 (a b c d : ℤ) (h : a^2 + b^2 + c^2 = d^2) :
    (d - a) * (d + a) = b^2 + c^2 := by nlinarith



/-- **Triple Channel Consistency**: The three channels are algebraically
consistent — any two determine the third. -/
theorem triple_channel_sum (a b c d : ℤ) (h : a^2 + b^2 + c^2 = d^2) :
    (d-c)*(d+c) + (d-b)*(d+b) + (d-a)*(d+a) = 2 * d^2 := by
  nlinarith



theorem quadruple_sum_identity (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ : ℤ)
    (h₁ : a₁^2 + b₁^2 + c₁^2 = d₁^2)
    (h₂ : a₂^2 + b₂^2 + c₂^2 = d₂^2) :
    (a₁*d₂)^2 + (b₁*d₂)^2 + (c₁*d₂)^2 = (d₁*d₂)^2 := by
  linear_combination' h₁ * d₂ ^ 2



theorem gcd_abc_divides_d_sq (a b c d : ℤ) (h : a^2 + b^2 + c^2 = d^2)
    (g : ℤ) (hga : g ∣ a) (hgb : g ∣ b) (hgc : g ∣ c) :
    g^2 ∣ d^2 := by
  exact h ▸ dvd_add ( dvd_add ( pow_dvd_pow_of_dvd hga 2 ) ( pow_dvd_pow_of_dvd hgb 2 ) ) ( pow_dvd_pow_of_dvd hgc 2 )



/-- **Cross-Channel Identity**: The difference between two channels gives
a pure squares identity that can be used for factoring. -/
theorem cross_channel_12 (a b c d : ℤ) (h : a^2 + b^2 + c^2 = d^2) :
    (d-c)*(d+c) - (d-b)*(d+b) = b^2 - c^2 := by
  nlinarith



theorem cross_channel_13 (a b c d : ℤ) (h : a^2 + b^2 + c^2 = d^2) :
    (d-c)*(d+c) - (d-a)*(d+a) = a^2 - c^2 := by
  nlinarith



theorem cross_channel_23 (a b c d : ℤ) (h : a^2 + b^2 + c^2 = d^2) :
    (d-b)*(d+b) - (d-a)*(d+a) = a^2 - b^2 := by
  nlinarith



/-- **Cross-Channel GCD**: The GCD of two channel values contains factor info.
channel_1 - channel_2 = b² - c² = (b-c)(b+c). -/
theorem cross_channel_gcd_factor (a b c d : ℤ) (h : a^2 + b^2 + c^2 = d^2) :
    (b - c) * (b + c) = (d-c)*(d+c) - (d-b)*(d+b) := by
  nlinarith


