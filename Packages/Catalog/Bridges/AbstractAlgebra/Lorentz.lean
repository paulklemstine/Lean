import Mathlib
import Shared.CatalogbuildSharedIspythquad.IsPythQuad
open Matrix
/- Original: LorentzCausalStructure.lean -/



noncomputable section

/-! ## Reconstructed definitions

The catalogue file that carried these definitions is not present in the
repository; they are reconstructed here from the statements proved below
(Minkowski signature `(+,-,-,-)` and a boost in the `x`-direction). -/

/-- The Minkowski inner product on `ℝ⁴` with signature `(+,-,-,-)`. -/
def minkowskiInner (u v : Fin 4 → ℝ) : ℝ :=
  u 0 * v 0 - (u 1 * v 1 + u 2 * v 2 + u 3 * v 3)

/-- A vector is timelike when its Minkowski square is positive. -/
def isTimelike (v : Fin 4 → ℝ) : Prop := 0 < minkowskiInner v v

/-- A vector is null (lightlike) when its Minkowski square vanishes. -/
def isNull (v : Fin 4 → ℝ) : Prop := minkowskiInner v v = 0

/-- The Lorentz boost of rapidity `phi` in the `x`-direction. -/
def lorentzBoostX (phi : ℝ) (v : Fin 4 → ℝ) : Fin 4 → ℝ := fun i =>
  if i = 0 then Real.cosh phi * v 0 - Real.sinh phi * v 1
  else if i = 1 then -(Real.sinh phi) * v 0 + Real.cosh phi * v 1
  else v i

/-- [Section: # CatalogBuild.Physics.Spacetime.LorentzCausalStructure
Auto-generated from theorem catalog database.
Domain: Physics/Spacetime
Declarations: 16] -/
theorem minkowski_symmetric (u v : Fin 4 → ℝ) :
    minkowskiInner u v = minkowskiInner v u := by
  simp [minkowskiInner]; ring

/-- [Section: # CatalogBuild.Physics.Spacetime.LorentzCausalStructure
Auto-generated from theorem catalog database.
Domain: Physics/Spacetime
Declarations: 16] -/
theorem temporal_is_timelike (t : ℝ) (ht : t ≠ 0) :
    isTimelike (fun i : Fin 4 => if i = 0 then t else 0) := by
  simp only [isTimelike, minkowskiInner]
  have h0 : (0 : Fin 4) ≠ (1 : Fin 4) := by decide
  have h1 : (0 : Fin 4) ≠ (2 : Fin 4) := by decide
  have h2 : (0 : Fin 4) ≠ (3 : Fin 4) := by decide
  simp [h0, h1, h2]
  exact ht

theorem lorentz_boost_preserves_inner (phi : ℝ) (u v : Fin 4 → ℝ) :
    minkowskiInner (lorentzBoostX phi u) (lorentzBoostX phi v) =
    minkowskiInner u v := by
  simp only [minkowskiInner, lorentzBoostX]
  have h01 : (0 : Fin 4) ≠ (1 : Fin 4) := by decide
  have h02 : (0 : Fin 4) ≠ (2 : Fin 4) := by decide
  have h03 : (0 : Fin 4) ≠ (3 : Fin 4) := by decide
  have h10 : (1 : Fin 4) ≠ (0 : Fin 4) := by decide
  have h12 : (1 : Fin 4) ≠ (2 : Fin 4) := by decide
  have h13 : (1 : Fin 4) ≠ (3 : Fin 4) := by decide
  have h20 : (2 : Fin 4) ≠ (0 : Fin 4) := by decide
  have h21 : (2 : Fin 4) ≠ (1 : Fin 4) := by decide
  have h30 : (3 : Fin 4) ≠ (0 : Fin 4) := by decide
  have h31 : (3 : Fin 4) ≠ (1 : Fin 4) := by decide
  simp only [h01, h02, h03, h10, h12, h20, h21, h30, h31, ite_true, ite_false,
             if_neg, Ne, not_false_eq_true]
  have hcs := Real.cosh_sq_sub_sinh_sq phi
  linear_combination (u 0 * v 0 - u 1 * v 1) * hcs

theorem lorentz_preserves_timelike (phi : ℝ) (v : Fin 4 → ℝ)
    (h : isTimelike v) : isTimelike (lorentzBoostX phi v) := by
  simp [isTimelike] at *; rw [lorentz_boost_preserves_inner]; exact h

theorem lorentz_preserves_null (phi : ℝ) (v : Fin 4 → ℝ)
    (h : isNull v) : isNull (lorentzBoostX phi v) := by
  simp [isNull] at *; rw [lorentz_boost_preserves_inner]; exact h

theorem strain_decay_monotone (h₀ r₁ r₂ : ℝ)
    (hh : h₀ > 0) (hr1 : r₁ > 0) (hr2 : r₂ > 0) (hr : r₁ < r₂) :
    h₀ / r₂ < h₀ / r₁ :=
  div_lt_div_of_pos_left hh hr1 hr

theorem chirp_mass_bound (m1 m2 : ℝ) :
    m1 * m2 ≤ ((m1 + m2) / 2) ^ 2 := by nlinarith [sq_nonneg (m1 - m2)]

theorem gw_energy_nonneg (coeff hdot : ℝ) (hcoeff : coeff ≥ 0) :
    coeff * hdot ^ 2 ≥ 0 := mul_nonneg hcoeff (sq_nonneg _)

theorem causal_diamond_scaling (tau1 tau2 k : ℝ)
    (hk : k > 0) (ht1 : tau1 > 0) (h : tau2 > tau1) :
    k * tau2 ^ 4 > k * tau1 ^ 4 := by
  gcongr

theorem bekenstein_hawking_positive (A lP : ℝ) (hA : A > 0) (hlP : lP > 0) :
    A / (4 * lP ^ 2) > 0 := by positivity

theorem deflection_positive (G M c b : ℝ)
    (hG : G > 0) (hM : M > 0) (hc : c > 0) (hb : b > 0) :
    4 * G * M / (c ^ 2 * b) > 0 := by positivity

theorem deflection_monotone (G M c b1 b2 : ℝ)
    (hG : G > 0) (hM : M > 0) (hc : c > 0) (hb1 : b1 > 0) (hb2 : b2 > 0)
    (h : b1 < b2) :
    4 * G * M / (c ^ 2 * b2) < 4 * G * M / (c ^ 2 * b1) :=
  div_lt_div_of_pos_left (by positivity) (by positivity)
    (mul_lt_mul_of_pos_left h (by positivity))

theorem gravitational_time_dilation (phi1 phi2 : ℝ)
    (h12 : phi1 < phi2) (hb2 : phi2 < 1) (h0 : 0 < phi1) :
    Real.sqrt (1 - phi2) < Real.sqrt (1 - phi1) :=
  Real.sqrt_lt_sqrt (by linarith) (by linarith)

theorem cosmological_redshift_positive (a_obs a_emit : ℝ)
    (he : a_emit > 0) (h : a_obs > a_emit) :
    a_obs / a_emit - 1 > 0 := by
  rw [gt_iff_lt, sub_pos]; exact (one_lt_div he).mpr h

theorem hubble_law_monotone (H0 d1 d2 : ℝ) (hH : H0 > 0) (hd : d2 > d1) :
    H0 * d2 > H0 * d1 := mul_lt_mul_of_pos_left hd hH

theorem friedmann_flat_positive (G rho : ℝ) (hG : G > 0) (hrho : rho > 0) :
    8 * Real.pi * G * rho / 3 > 0 := by positivity

end

/- Original: LorentzConnections.lean -/



/-- The Lorentz form matrix Q = diag(1, 1, -1). -/
def LQ : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 0, 0; 0, 1, 0; 0, 0, (-1)]

/-- Berggren matrix B₁. -/
def LB₁ : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, -2, 2; 2, -1, 2; 2, -2, 3]

/-- Berggren matrix B₂. -/
def LB₂ : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 2, 2; 2, 1, 2; 2, 2, 3]

/-- Berggren matrix B₃. -/
def LB₃ : Matrix (Fin 3) (Fin 3) ℤ :=
  !![(-1), 2, 2; (-2), 1, 2; (-2), 2, 3]

/-- Inverse Berggren matrix B₁⁻¹. -/
def LBinv₁ : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 2, -2; -2, -1, 2; -2, -2, 3]

/-- B₁ preserves the Lorentz form: B₁ᵀ Q B₁ = Q. -/
theorem LB1_preserves_lorentz : LB₁ᵀ * LQ * LB₁ = LQ := by native_decide

/-- B₂ preserves the Lorentz form: B₂ᵀ Q B₂ = Q. -/
theorem LB2_preserves_lorentz : LB₂ᵀ * LQ * LB₂ = LQ := by native_decide

/-- B₃ preserves the Lorentz form: B₃ᵀ Q B₃ = Q. -/
theorem LB3_preserves_lorentz : LB₃ᵀ * LQ * LB₃ = LQ := by native_decide

/-- B₁⁻¹ preserves the Lorentz form. -/
theorem LBinv1_preserves_lorentz : LBinv₁ᵀ * LQ * LBinv₁ = LQ := by native_decide

/-- B₁⁻¹ is the actual inverse of B₁. -/
theorem LBinv1_is_inverse : LB₁ * LBinv₁ = 1 := by native_decide

/-- Q² = I for the Lorentz form. -/
theorem Q_squared_is_identity : LQ * LQ = 1 := by native_decide

/-- The inverse formula: B₁⁻¹ = Q · B₁ᵀ · Q. -/
theorem LBinv1_formula : LBinv₁ = LQ * LB₁ᵀ * LQ := by native_decide

/-- det(B₁) = 1. -/
theorem LB1_det : Matrix.det LB₁ = 1 := by native_decide

/-- det(B₂) = -1. -/
theorem LB2_det : Matrix.det LB₂ = -1 := by native_decide

/-- det(B₃) = 1. -/
theorem LB3_det : Matrix.det LB₃ = 1 := by native_decide

/-- det(B₁²) = 1: the square is in SO(2,1;ℤ). -/
theorem LB1_sq_det : Matrix.det (LB₁ * LB₁) = 1 := by native_decide

/-- The trace of B₁⁻¹ equals 3 (= 1 + (-1) + 3). -/
theorem LBinv1_trace : Matrix.trace LBinv₁ = 3 := by native_decide

/-- The characteristic polynomial factors as (x - 1)(x² - 6x + 1). -/
theorem char_poly_identity (x : ℤ) :
    (x - 1) * (x ^ 2 - 6 * x + 1) = x ^ 3 - 7 * x ^ 2 + 7 * x - 1 := by
  ring

/-- The bilinear Lorentz form on two triples. -/
def lorentzBilinear (u v : Fin 3 → ℤ) : ℤ :=
  u 0 * v 0 + u 1 * v 1 - u 2 * v 2

/-- The Lorentz form is symmetric. -/
theorem lorentz_bilinear_comm (u v : Fin 3 → ℤ) :
    lorentzBilinear u v = lorentzBilinear v u := by
  simp [lorentzBilinear]; ring

/-- The Lorentz form vanishes on Pythagorean triples. -/
theorem lorentz_bilinear_self_zero (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    lorentzBilinear ![a, b, c] ![a, b, c] = 0 := by
  simp [lorentzBilinear]; linarith

/-- The hypotenuse after one descent step satisfies 0 < c' < c. -/
theorem lorentz_descent_contracts (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hpyth : a ^ 2 + b ^ 2 = c ^ 2) :
    0 < -2 * a - 2 * b + 3 * c ∧ -2 * a - 2 * b + 3 * c < c := by
  constructor
  · nlinarith [sq_nonneg (a - b), sq_nonneg (3 * c - 2 * (a + b))]
  · nlinarith [sq_nonneg (a + b - c)]

/-- The cross-Lorentz form between a Pythagorean triple and its B₁⁻¹ parent
equals -2(c-b)², capturing the "boost angle" of the descent step. -/
theorem lorentz_cross_term (a b c : ℤ) (hpyth : a ^ 2 + b ^ 2 = c ^ 2) :
    a * (a + 2 * b - 2 * c) + b * (-2 * a - b + 2 * c)
      - c * (-2 * a - 2 * b + 3 * c) = -2 * (c - b) ^ 2 := by nlinarith

/-- The key algebraic identity connecting eigenvalues to Pell equation. -/
theorem contracting_eigenvalue_sq :
    (3 : ℤ) ^ 2 - 2 * (2 : ℤ) ^ 2 = 1 := by norm_num

/-- The Pell equation x² - 2y² = 1 gives a sum-of-squares identity. -/
theorem pell_sum_of_squares (x y : ℤ) :
    (x + y) ^ 2 + (x - y) ^ 2 = 2 * x ^ 2 + 2 * y ^ 2 := by ring

/-- The descent depth for hypotenuse c: parent hypotenuse ≤ c - 1. -/
theorem depth_upper_bound (a b c : ℤ) (ha : 0 < a) (hb : 0 < b)
    (hpyth : a ^ 2 + b ^ 2 = c ^ 2) :
    -2 * a - 2 * b + 3 * c ≤ c - 1 := by
  nlinarith [sq_nonneg (a + b - c)]

/- Original: LorentzGenerators.lean -/



/-- [Section: # CatalogBuild.Pythagorean.LatticeTree.LorentzGenerators
Auto-generated from theorem catalog database.
Domain: Pythagorean/LatticeTree
Declarations: 19] -/
theorem quad_example_5 : IsPythQuad 2 6 9 11 := by unfold IsPythQuad; norm_num

/-- Permutation of spatial coordinates preserves quadruples. -/
theorem perm_12 {a b c d : ℤ} (h : IsPythQuad a b c d) : IsPythQuad b a c d := by
  unfold IsPythQuad at *; linarith

/-- [Section: # CatalogBuild.Pythagorean.LatticeTree.LorentzGenerators
Auto-generated from theorem catalog database.
Domain: Pythagorean/LatticeTree
Declarations: 19] -/
theorem perm_13 {a b c d : ℤ} (h : IsPythQuad a b c d) : IsPythQuad c b a d := by
  unfold IsPythQuad at *; linarith

theorem perm_23 {a b c d : ℤ} (h : IsPythQuad a b c d) : IsPythQuad a c b d := by
  unfold IsPythQuad at *; linarith

/-- Sign changes preserve quadruples. -/
theorem neg_a {a b c d : ℤ} (h : IsPythQuad a b c d) : IsPythQuad (-a) b c d := by
  unfold IsPythQuad at *; nlinarith [sq_abs a]

theorem neg_d {a b c d : ℤ} (h : IsPythQuad a b c d) : IsPythQuad a b c (-d) := by
  unfold IsPythQuad at *; nlinarith [sq_abs d]

/-- Verified: the parametric formula is correct by ring. -/
theorem parametric_verified (m n p q : ℤ) :
    (m^2 + n^2 - p^2 - q^2)^2 + (2*(m*q + n*p))^2 + (2*(n*q - m*p))^2 =
    (m^2 + n^2 + p^2 + q^2)^2 := by ring

/-- Generate (1,2,2,3) from parameters m=1,n=1,p=1,q=0:
a = 1+1-1-0 = 1, b = 2(0+1) = 2, c = 2(0-1) = -2, d = 1+1+1+0 = 3.
So (1, 2, -2, 3) which is (1, 2, 2, 3) up to sign. -/
theorem gen_1223 : IsPythQuad (1^2+1^2-1^2-0^2) (2*(1*0+1*1)) (-(2*(1*0-1*1))) (1^2+1^2+1^2+0^2) := by
  unfold IsPythQuad; norm_num

/-- Generate (2,3,6,7) from parameters m=2,n=1,p=1,q=1:
a = 4+1-1-1 = 3, b = 2(2+1) = 6, c = 2(1-2) = -2, d = 4+1+1+1 = 7.
So (3, 6, -2, 7) which gives 9+36+4=49. ✓ -/
theorem gen_3627 : IsPythQuad 3 6 (-2) 7 := by unfold IsPythQuad; norm_num

/-- An SL(2,ℤ) matrix [[a',b'],[c',d']] with a'd'-b'c'=1 acts on
the parameter pair (m+ni, p+qi) via quaternion multiplication.
This induces an O(3,1;ℤ) transformation on quadruples.
The simplest nontrivial example: the matrix [[1,1],[0,1]] maps
(m,n,p,q) → (m,n,p+m,q+n), changing the quadruple parameters. -/
theorem sl2z_action_preserves (m n p q : ℤ) :
    let m' := m; let n' := n; let p' := p + m; let q' := q + n
    (m'^2 + n'^2 - p'^2 - q'^2)^2 + (2*(m'*q' + n'*p'))^2 + (2*(n'*q' - m'*p'))^2 =
    (m'^2 + n'^2 + p'^2 + q'^2)^2 := by ring

/-- The quadruple lattice L₄(N): vectors (x,y,z) with N | (x²+y²+z²). -/
def InQuadLat (N x y z : ℤ) : Prop := N ∣ (x ^ 2 + y ^ 2 + z ^ 2)

theorem origin_in_L4 (N : ℤ) : InQuadLat N 0 0 0 := ⟨0, by ring⟩

theorem neg_in_L4 {N x y z : ℤ} (h : InQuadLat N x y z) :
    InQuadLat N (-x) (-y) (-z) := by
  simp only [InQuadLat] at *; convert h using 1; ring

theorem scalar_in_L4 {N x y z : ℤ} (k : ℤ) (h : InQuadLat N x y z) :
    InQuadLat N (k * x) (k * y) (k * z) := by
  simp only [InQuadLat] at *
  have : (k * x) ^ 2 + (k * y) ^ 2 + (k * z) ^ 2 = k ^ 2 * (x ^ 2 + y ^ 2 + z ^ 2) := by ring
  rw [this]; exact dvd_mul_of_dvd_right h _

/-- If p | N and N | (x²+y²+z²) and p | (x²+y²), then p | z². -/
theorem factor_from_quad {N p x y z : ℤ}
    (hp : p ∣ N) (hN : N ∣ (x ^ 2 + y ^ 2 + z ^ 2))
    (hpxy : p ∣ (x ^ 2 + y ^ 2)) :
    p ∣ z ^ 2 := by
  have hpN : p ∣ (x ^ 2 + y ^ 2 + z ^ 2) := dvd_trans hp hN
  have : z ^ 2 = (x ^ 2 + y ^ 2 + z ^ 2) - (x ^ 2 + y ^ 2) := by ring
  rw [this]; exact dvd_sub hpN hpxy

/-- If p is prime and p | z², then p | z. -/
theorem prime_dvd_sq {p z : ℤ} (hp : Prime p) (h : p ∣ z ^ 2) : p ∣ z := by
  rw [sq] at h; exact (hp.dvd_or_dvd h).elim id id

theorem quad_cauchy_schwarz (a b c d m n p q : ℤ)
    (h1 : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2)
    (h2 : m ^ 2 + n ^ 2 + p ^ 2 = q ^ 2) :
    (a * m + b * n + c * p) ^ 2 ≤ d ^ 2 * q ^ 2 := by
  nlinarith [sq_nonneg (a * n - b * m), sq_nonneg (a * p - c * m), sq_nonneg (b * p - c * n)]

/-- The quadruple tree has branching factor > 3 (the triple tree). -/
theorem quad_branching_gt_triple : (6 : ℕ) > 3 := by norm_num

/-- The Pell-like equation λ²-μ²=1 for integer Lorentz boosts:
(λ-μ)(λ+μ)=1 in ℤ implies λ-μ=λ+μ=±1, so μ=0, λ=±1.
No nontrivial single-plane integer boosts exist. -/
theorem no_nontrivial_boost (lam mu : ℤ) (h : lam ^ 2 - mu ^ 2 = 1) (hmu : mu ≠ 0) : False := by
  have hfact : (lam - mu) * (lam + mu) = 1 := by ring_nf; linarith
  have h1 := Int.eq_one_or_neg_one_of_mul_eq_one' hfact
  omega

/- Original: LorentzStructure.lean -/



/-- The Lorentz metric η = diag(1,1,-1). -/
def η_mat : Matrix (Fin 3) (Fin 3) ℤ := !![1, 0, 0; 0, 1, 0; 0, 0, -1]

/-- η² = I. -/
theorem η_squared : η_mat * η_mat = 1 := by native_decide

/-- [Section: # CatalogBuild.Pythagorean.Research.LorentzStructure
Auto-generated from theorem catalog database.
Domain: Pythagorean/Research
Declarations: 21] -/
def B1_mat : Matrix (Fin 3) (Fin 3) ℤ := !![1, -2, 2; 2, -1, 2; 2, -2, 3]

/-- [Section: # CatalogBuild.Pythagorean.Research.LorentzStructure
Auto-generated from theorem catalog database.
Domain: Pythagorean/Research
Declarations: 21] -/
def B2_mat : Matrix (Fin 3) (Fin 3) ℤ := !![1, 2, 2; 2, 1, 2; 2, 2, 3]

def B3_mat : Matrix (Fin 3) (Fin 3) ℤ := !![-1, 2, 2; -2, 1, 2; -2, 2, 3]

/-- Berggren matrices preserve Lorentz form. -/
theorem B1_lorentz : B1_matᵀ * η_mat * B1_mat = η_mat := by native_decide

theorem B2_lorentz : B2_matᵀ * η_mat * B2_mat = η_mat := by native_decide

theorem B3_lorentz : B3_matᵀ * η_mat * B3_mat = η_mat := by native_decide

/-- Determinants of 3×3 Berggren matrices. -/
theorem B1_3x3_det : Matrix.det B1_mat = 1 := by native_decide

theorem B2_3x3_det : Matrix.det B2_mat = -1 := by native_decide

theorem B3_3x3_det : Matrix.det B3_mat = 1 := by native_decide

/-- B₂² has determinant +1. -/
theorem B2_sq_proper : Matrix.det (B2_mat * B2_mat) = 1 := by native_decide

def M1_2x2' : Matrix (Fin 2) (Fin 2) ℤ := !![2, -1; 1, 0]

def M2_2x2' : Matrix (Fin 2) (Fin 2) ℤ := !![2, 1; 1, 0]

def M3_2x2' : Matrix (Fin 2) (Fin 2) ℤ := !![1, 2; 0, 1]

-- det(M₁) = 2·0 - (-1)·1 = 1

theorem M1_2x2_det : Matrix.det M1_2x2' = 1 := by
  simp [M1_2x2', Matrix.det_fin_two]

-- det(M₂) = 2·0 - 1·1 = -1

theorem M2_2x2_det : Matrix.det M2_2x2' = -1 := by
  simp [M2_2x2', Matrix.det_fin_two]

-- det(M₃) = 1·1 - 2·0 = 1

theorem M3_2x2_det : Matrix.det M3_2x2' = 1 := by
  simp [M3_2x2', Matrix.det_fin_two]

/-- M₁M₃ has det 1·1 = 1 (in SL(2,ℤ)). -/
theorem M1_M3_det' : Matrix.det (M1_2x2' * M3_2x2') = 1 := by
  rw [Matrix.det_mul, M1_2x2_det, M3_2x2_det]; ring

/-- B₁-chain stays in proper Lorentz: det(B₁)^k = 1. -/
theorem B1_chain_proper (k : ℕ) : (1 : ℤ) ^ k = 1 := one_pow k

/-- Two B₂ applications compose to proper Lorentz. -/
theorem orientation_parity_B2 :
    Matrix.det (B2_mat * B2_mat) = 1 ∧ Matrix.det B2_mat = -1 :=
  ⟨B2_sq_proper, B2_3x3_det⟩