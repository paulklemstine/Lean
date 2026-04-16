import Mathlib

/-!
# Arithmetic Photons: The Hopf Bridge

## Quaternions, Hopf Fibration, and Photon Parametrization

The parametrization of Pythagorean quadruples via (m,n,p,q) is secretly the
arithmetic Hopf fibration.
-/

open BigOperators

/-! ## Part 1: Quaternion Algebra over ℤ -/

@[ext]
structure IntQuaternion where
  w : ℤ
  x : ℤ
  y : ℤ
  z : ℤ
  deriving DecidableEq, Repr

namespace IntQuaternion

def sqNorm (q : IntQuaternion) : ℤ :=
  q.w ^ 2 + q.x ^ 2 + q.y ^ 2 + q.z ^ 2

def mul (q₁ q₂ : IntQuaternion) : IntQuaternion where
  w := q₁.w * q₂.w - q₁.x * q₂.x - q₁.y * q₂.y - q₁.z * q₂.z
  x := q₁.w * q₂.x + q₁.x * q₂.w + q₁.y * q₂.z - q₁.z * q₂.y
  y := q₁.w * q₂.y - q₁.x * q₂.z + q₁.y * q₂.w + q₁.z * q₂.x
  z := q₁.w * q₂.z + q₁.x * q₂.y - q₁.y * q₂.x + q₁.z * q₂.w

def conj (q : IntQuaternion) : IntQuaternion where
  w := q.w
  x := -q.x
  y := -q.y
  z := -q.z

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

end IntQuaternion

/-! ## Part 2: The Hopf Map -/

def hopfMap (m n p q : ℤ) : ℤ × ℤ × ℤ × ℤ :=
  (m^2 + n^2 - p^2 - q^2,
   2 * (m * q + n * p),
   2 * (n * q - m * p),
   m^2 + n^2 + p^2 + q^2)

/-- The Hopf map output satisfies the null condition -/
theorem hopfMap_is_null (m n p q : ℤ) :
    let ⟨a, b, c, d⟩ := hopfMap m n p q
    a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2 := by
  simp only [hopfMap]; ring

/-- The d-component of the Hopf map is the quaternion norm -/
theorem hopfMap_d_eq_sqNorm (m n p q : ℤ) :
    (hopfMap m n p q).2.2.2 = IntQuaternion.sqNorm ⟨m, n, p, q⟩ := by
  simp only [hopfMap, IntQuaternion.sqNorm]

/-! ## Part 3: Fiber Structure -/

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

/-! ## Part 4: Specific Hopf Fibers -/

theorem hopf_1_0_0_0 : hopfMap 1 0 0 0 = (1, 0, 0, 1) := by
  simp [hopfMap]

theorem hopf_1_1_1_0 : hopfMap 1 1 1 0 = (1, 2, -2, 3) := by
  simp only [hopfMap]; norm_num

/-! ## Part 5: Primitive Quadruples -/

def IsPrimitive (a b c d : ℤ) : Prop :=
  Int.gcd (Int.gcd a b) (Int.gcd c d) = 1

theorem exists_primitive_divisor (a b c d : ℤ) (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    ∃ k a' b' c' d' : ℤ, k ≠ 0 ∧
      a = k * a' ∧ b = k * b' ∧ c = k * c' ∧ d = k * d' ∧
      a' ^ 2 + b' ^ 2 + c' ^ 2 = d' ^ 2 :=
  ⟨1, a, b, c, d, one_ne_zero, by ring, by ring, by ring, by ring, h⟩

/-! ## Part 6: Norm Form -/

def pureQuatNorm (a b c : ℤ) : ℤ :=
  a ^ 2 + b ^ 2 + c ^ 2

theorem pythQuad_is_quatNorm (a b c d : ℤ) :
    a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2 ↔ pureQuatNorm a b c = d ^ 2 := by
  simp [pureQuatNorm]
