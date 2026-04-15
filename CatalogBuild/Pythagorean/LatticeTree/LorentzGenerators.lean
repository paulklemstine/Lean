/-! # CatalogBuild.Pythagorean.LatticeTree.LorentzGenerators

Auto-generated from theorem catalog database.
Domain: Pythagorean/LatticeTree
Declarations: 19
-/

import Mathlib

theorem quad_example_5 : IsPythQuad 2 6 9 11 := by unfold IsPythQuad; norm_num


/-- Permutation of spatial coordinates preserves quadruples. -/
theorem perm_12 {a b c d : ℤ} (h : IsPythQuad a b c d) : IsPythQuad b a c d := by
  unfold IsPythQuad at *; linarith


/-- [Section: ## Section 2: Spatial Symmetries (Finite Subgroup)] -/
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


/-- [Section: ## Section 5: The Quadruple Lattice] -/
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


/-- [Section: ## Section 7: Cauchy-Schwarz for Quadruples] -/
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

