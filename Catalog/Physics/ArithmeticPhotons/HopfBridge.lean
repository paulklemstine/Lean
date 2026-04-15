/-! # CatalogBuild.Physics.ArithmeticPhotons.HopfBridge

Auto-generated from theorem catalog database.
Domain: Physics/ArithmeticPhotons
Declarations: 15
-/

import Mathlib

def zero : IntQuaternion := ⟨0, 0, 0, 0⟩


/-- The norm is multiplicative: |q₁q₂|² = |q₁|²|q₂|² -/
theorem sqNorm_mul (q₁ q₂ : IntQuaternion) :
    sqNorm (mul q₁ q₂) = sqNorm q₁ * sqNorm q₂ := by
  simp only [sqNorm, mul]; ring


/-- The norm of the conjugate equals the norm -/
theorem sqNorm_conj (q : IntQuaternion) :
    sqNorm (conj q) = sqNorm q := by
  simp only [sqNorm, conj]; ring


/-- The norm is non-negative -/
theorem sqNorm_nonneg (q : IntQuaternion) : 0 ≤ sqNorm q := by
  unfold sqNorm; positivity


/-- The norm is zero iff the quaternion is zero -/
theorem sqNorm_eq_zero (q : IntQuaternion) :
    sqNorm q = 0 ↔ q = zero := by
  constructor
  · intro h
    unfold sqNorm at h
    have hw : q.w = 0 := by nlinarith [sq_nonneg q.w, sq_nonneg q.x, sq_nonneg q.y, sq_nonneg q.z]
    have hx : q.x = 0 := by nlinarith [sq_nonneg q.w, sq_nonneg q.x, sq_nonneg q.y, sq_nonneg q.z]
    have hy : q.y = 0 := by nlinarith [sq_nonneg q.w, sq_nonneg q.x, sq_nonneg q.y, sq_nonneg q.z]
    have hz : q.z = 0 := by nlinarith [sq_nonneg q.w, sq_nonneg q.x, sq_nonneg q.y, sq_nonneg q.z]
    ext <;> simp_all [zero]
  · intro h; rw [h]; simp [sqNorm, zero]


/-- The Hopf map output satisfies the null condition -/
theorem hopfMap_is_null (m n p q : ℤ) :
    let ⟨a, b, c, d⟩ := hopfMap m n p q
    a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2 := by
  simp only [hopfMap]; ring


/-- The d-component of the Hopf map is the quaternion norm -/
theorem hopfMap_d_eq_sqNorm (m n p q : ℤ) :
    (hopfMap m n p q).2.2.2 = IntQuaternion.sqNorm ⟨m, n, p, q⟩ := by
  simp only [hopfMap, IntQuaternion.sqNorm]


def sameDirection (m₁ n₁ p₁ q₁ m₂ n₂ p₂ q₂ : ℤ) : Prop :=
  let ⟨a₁, b₁, c₁, d₁⟩ := hopfMap m₁ n₁ p₁ q₁
  let ⟨a₂, b₂, c₂, d₂⟩ := hopfMap m₂ n₂ p₂ q₂
  a₁ * d₂ = a₂ * d₁ ∧ b₁ * d₂ = b₂ * d₁ ∧ c₁ * d₂ = c₂ * d₁


/-- Scaling the parameters preserves direction -/
theorem scale_preserves_direction (m n p q k : ℤ) :
    sameDirection m n p q (k*m) (k*n) (k*p) (k*q) := by
  simp only [sameDirection, hopfMap]
  exact ⟨by ring, by ring, by ring⟩


/-- Negating all parameters preserves the quadruple -/
theorem neg_params_same (m n p q : ℤ) :
    hopfMap (-m) (-n) (-p) (-q) = hopfMap m n p q := by
  simp only [hopfMap]; ext <;> simp


theorem hopf_1_0_0_0 : hopfMap 1 0 0 0 = (1, 0, 0, 1) := by
  simp [hopfMap]


theorem hopf_1_1_1_0 : hopfMap 1 1 1 0 = (1, 2, -2, 3) := by
  simp only [hopfMap]; norm_num


theorem exists_primitive_divisor (a b c d : ℤ) (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    ∃ k a' b' c' d' : ℤ, k ≠ 0 ∧
      a = k * a' ∧ b = k * b' ∧ c = k * c' ∧ d = k * d' ∧
      a' ^ 2 + b' ^ 2 + c' ^ 2 = d' ^ 2 :=
  ⟨1, a, b, c, d, one_ne_zero, by ring, by ring, by ring, by ring, h⟩


def pureQuatNorm (a b c : ℤ) : ℤ :=
  a ^ 2 + b ^ 2 + c ^ 2


theorem pythQuad_is_quatNorm (a b c d : ℤ) :
    a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2 ↔ pureQuatNorm a b c = d ^ 2 := by
  simp [pureQuatNorm]

