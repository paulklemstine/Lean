/-! # CatalogBuild.Pythagorean.Quadruples.QuaternionDescent

Auto-generated from theorem catalog database.
Domain: Pythagorean/Quadruples
Declarations: 30
-/

import Mathlib

/-- An integer quaternion (a + bi + cj + dk) -/
structure IntQuat where
  re : ℤ
  im_i : ℤ
  im_j : ℤ
  im_k : ℤ
  deriving Repr, DecidableEq

namespace IntQuat


/-- The conjugate of a quaternion -/
def conj' (q : IntQuat) : IntQuat :=
  ⟨q.re, -q.im_i, -q.im_j, -q.im_k⟩


/-- Quaternion multiplication -/
def qmul (p q : IntQuat) : IntQuat :=
  ⟨p.re * q.re - p.im_i * q.im_i - p.im_j * q.im_j - p.im_k * q.im_k,
   p.re * q.im_i + p.im_i * q.re + p.im_j * q.im_k - p.im_k * q.im_j,
   p.re * q.im_j - p.im_i * q.im_k + p.im_j * q.re + p.im_k * q.im_i,
   p.re * q.im_k + p.im_i * q.im_j - p.im_j * q.im_i + p.im_k * q.re⟩


/-- Quaternion addition -/
def qadd (p q : IntQuat) : IntQuat :=
  ⟨p.re + q.re, p.im_i + q.im_i, p.im_j + q.im_j, p.im_k + q.im_k⟩


/-- Negation -/
def qneg (q : IntQuat) : IntQuat :=
  ⟨-q.re, -q.im_i, -q.im_j, -q.im_k⟩


/-- The fundamental theorem: |pq|² = |p|²·|q|² (Euler's four-square identity) -/
theorem IntQuat.sqNorm_qmul (p q : IntQuat) :
    (p.qmul q).sqNorm = p.sqNorm * q.sqNorm := by
  simp only [IntQuat.sqNorm, IntQuat.qmul]; ring


/-- q · conj(q) has zero imaginary parts -/
theorem IntQuat.qmul_conj_im (q : IntQuat) :
    (q.qmul q.conj').im_i = 0 ∧ (q.qmul q.conj').im_j = 0 ∧ (q.qmul q.conj').im_k = 0 := by
  simp only [IntQuat.qmul, IntQuat.conj']
  refine ⟨by ring, by ring, by ring⟩


/-- q · conj(q) = |q|² (as real quaternion) -/
theorem IntQuat.qmul_conj_re (q : IntQuat) :
    (q.qmul q.conj').re = q.sqNorm := by
  simp only [IntQuat.qmul, IntQuat.conj', IntQuat.sqNorm]; ring


/-- The Euler parametrization: given quaternion α = (m, n, p, q),
produce the Pythagorean quadruple components -/
def eulerFromQuat (α : IntQuat) : Fin 4 → ℤ := fun i =>
  match i with
  | 0 => α.re ^ 2 + α.im_i ^ 2 - α.im_j ^ 2 - α.im_k ^ 2
  | 1 => 2 * (α.re * α.im_k + α.im_i * α.im_j)
  | 2 => 2 * (α.im_i * α.im_k - α.re * α.im_j)
  | 3 => α.sqNorm


/-- The Euler parametrization always gives a Pythagorean quadruple -/
theorem eulerFromQuat_is_pyth (α : IntQuat) :
    (eulerFromQuat α 0) ^ 2 + (eulerFromQuat α 1) ^ 2 + (eulerFromQuat α 2) ^ 2 =
    (eulerFromQuat α 3) ^ 2 := by
  unfold eulerFromQuat IntQuat.sqNorm; ring


/-- The hypotenuse of the Euler quadruple equals the quaternion norm squared -/
theorem euler_hyp_eq_sqNorm (α : IntQuat) :
    eulerFromQuat α 3 = α.sqNorm := rfl


/-- |σ|² = 4 -/
theorem sigma_sqNorm : sigma.sqNorm = 4 := by
  simp [sigma, IntQuat.sqNorm]


/-- The Minkowski norm η(s,s) = 2 for s = (1,1,1,1) relates to |σ|² = 4 by factor 2 -/
theorem minkowski_vs_quaternion_norm :
    (1:ℤ)^2 + 1^2 + 1^2 - 1^2 = 2 ∧ sigma.sqNorm = 4 := by
  exact ⟨by norm_num, sigma_sqNorm⟩


/-- The R₁₁₁₁ reflection matrix -/
def R1111' : Matrix (Fin 4) (Fin 4) ℤ :=
  !![0, -1, -1, 1; -1, 0, -1, 1; -1, -1, 0, 1; -1, -1, -1, 2]


/-- The Lorentz form Q₄(v) = v₀² + v₁² + v₂² − v₃² -/
def Q4' (v : Fin 4 → ℤ) : ℤ :=
  v 0 ^ 2 + v 1 ^ 2 + v 2 ^ 2 - v 3 ^ 2


/-- R₁₁₁₁ is an involution -/
theorem R1111'_involution : R1111' * R1111' = (1 : Matrix (Fin 4) (Fin 4) ℤ) := by
  native_decide


/-- The descent identity: R₁₁₁₁ preserves the quadruple equation -/
theorem descent_preserves_pyth (a b c d : ℤ) (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    (d - b - c) ^ 2 + (d - a - c) ^ 2 + (d - a - b) ^ 2 = (2*d - a - b - c) ^ 2 := by
  nlinarith [sq_nonneg (a - b), sq_nonneg (b - c), sq_nonneg (a - c)]


/-- The descent strictly reduces the hypotenuse -/
theorem descent_reduces_hyp (a b c d : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2)
    (ha : 0 ≤ a) (hb : 0 < b) (hc : 0 < c) (hd : 0 < d) :
    0 < 2 * d - (a + b + c) ∧ 2 * d - (a + b + c) < d := by
  constructor
  · nlinarith [sq_nonneg (a - b), sq_nonneg (b - c), sq_nonneg (a - c)]
  · nlinarith [mul_pos hb hc]


/-- The four-square identity is exactly norm multiplicativity of quaternions -/
theorem four_square_is_norm_mult (p q : IntQuat) :
    p.sqNorm * q.sqNorm = (p.qmul q).sqNorm := by
  rw [IntQuat.sqNorm_qmul]


/-- The identity quaternion (1,0,0,0) maps to (1,0,0,1): the root -/
theorem identity_quat_gives_root :
    eulerFromQuat ⟨1, 0, 0, 0⟩ = ![1, 0, 0, 1] := by
  ext i; fin_cases i <;> simp [eulerFromQuat, IntQuat.sqNorm]


/-- The quaternion (1,1,1,0) maps to the first non-trivial quadruple with d=3 -/
theorem quat_1110_gives_d3 :
    eulerFromQuat ⟨1, 1, 1, 0⟩ 3 = 3 := by
  simp [eulerFromQuat, IntQuat.sqNorm]


/-- Full components of (1,1,1,0) → (1, 2, -2, 3) -/
theorem quat_1110_components :
    eulerFromQuat ⟨1, 1, 1, 0⟩ = ![1, 2, -2, 3] := by
  ext i; fin_cases i <;> simp [eulerFromQuat, IntQuat.sqNorm]


/-- The quaternion (1,1,0,1) → (1, 2, 2, 3): the standard (1,2,2,3) -/
theorem quat_1101_components :
    eulerFromQuat ⟨1, 1, 0, 1⟩ = ![1, 2, 2, 3] := by
  ext i; fin_cases i <;> simp [eulerFromQuat, IntQuat.sqNorm]


/-- The squared norm of σ·α is 4·|α|² -/
theorem sigma_qmul_norm (α : IntQuat) :
    (sigma.qmul α).sqNorm = 4 * α.sqNorm := by
  rw [IntQuat.sqNorm_qmul, sigma_sqNorm]


/-- The Euler parametrization gives a²+b²+c² = d² by ring identity.
This is the same as saying the quaternion norm form decomposes the
sum of four squares into a difference of two sums of two squares
plus cross terms. -/
theorem euler_ring_identity (m n p q : ℤ) :
    (m^2 + n^2 - p^2 - q^2)^2 + (2*(m*q + n*p))^2 + (2*(n*q - m*p))^2
    = (m^2 + n^2 + p^2 + q^2)^2 := by ring


/-- Verify: quaternion (1,1,1,0) has norm 3 and Euler gives d=3 -/
theorem descent_chain_norm_3 :
    (IntQuat.mk 1 1 1 0).sqNorm = 3 ∧ eulerFromQuat ⟨1, 1, 1, 0⟩ 3 = 3 := by
  simp [IntQuat.sqNorm, eulerFromQuat]


/-- Verify: quaternion (1,1,0,0) has norm 2 and Euler gives d=2 -/
theorem descent_chain_norm_2 :
    (IntQuat.mk 1 1 0 0).sqNorm = 2 ∧ eulerFromQuat ⟨1, 1, 0, 0⟩ 3 = 2 := by
  simp [IntQuat.sqNorm, eulerFromQuat]


/-- A quadruple (a,b,c,d) is primitive -/
def IsPrimitiveQuad' (a b c d : ℤ) : Prop :=
  Int.gcd (Int.gcd a b) (Int.gcd c d) = 1


/-- [Section: ## Section 12: Parity and Quaternion Structure] -/
theorem quad_hyp_odd (a b c d : ℤ) (h : a^2 + b^2 + c^2 = d^2)
    (hprim : IsPrimitiveQuad' a b c d) (hd_pos : 0 < d) :
    ¬ (2 ∣ d) := by
  contrapose! hprim; simp_all +decide [ ← even_iff_two_dvd, parity_simps ] ;
  -- If $d$ is even, then $a$, $b$, and $c$ must also be even.
  have h_even_abc : Even a ∧ Even b ∧ Even c := by
    replace h := congr_arg ( · % 4 ) h ; rcases hprim with ⟨ k, rfl ⟩ ; rcases Int.even_or_odd' a with ⟨ m, rfl | rfl ⟩ <;> rcases Int.even_or_odd' b with ⟨ n, rfl | rfl ⟩ <;> rcases Int.even_or_odd' c with ⟨ o, rfl | rfl ⟩ <;> ring_nf at * <;> norm_num [ Int.add_emod, Int.mul_emod ] at *;
  exact fun h => absurd ( h ▸ Int.dvd_coe_gcd ( Int.dvd_coe_gcd ( even_iff_two_dvd.mp h_even_abc.1 ) ( even_iff_two_dvd.mp h_even_abc.2.1 ) ) ( Int.dvd_coe_gcd ( even_iff_two_dvd.mp h_even_abc.2.2 ) ( even_iff_two_dvd.mp hprim ) ) ) ( by decide ) ;


/-- The descent is well-founded: it terminates because d ∈ ℕ₊ strictly decreases -/
theorem descent_well_founded' :
    WellFounded (fun (x y : ℕ) => x < y) :=
  Nat.lt_wfRel.wf

