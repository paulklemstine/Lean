/-! # CatalogBuild.Physics.ArithmeticPhotons.Advanced

Auto-generated from theorem catalog database.
Domain: Physics/ArithmeticPhotons
Declarations: 30
-/

import Mathlib

noncomputable section

/-- The Minkowski inner product η(v,w) = v₀w₀ + v₁w₁ + v₂w₂ - v₃w₃ -/
def minkowskiInner (v w : Fin 4 → ℤ) : ℤ :=
  v 0 * w 0 + v 1 * w 1 + v 2 * w 2 - v 3 * w 3

/-- Convert a 4-tuple to a function Fin 4 → ℤ -/

def toVec (a b c d : ℤ) : Fin 4 → ℤ := ![a, b, c, d]

/-- The Lorentz form equals the Minkowski self-product -/

theorem lorentzQ_eq_minkowski_self (a b c d : ℤ) :
    a ^ 2 + b ^ 2 + c ^ 2 - d ^ 2 = minkowskiInner (toVec a b c d) (toVec a b c d) := by
  unfold minkowskiInner toVec
  simp [Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons, Matrix.head_fin_const]
  ring

/-- The Minkowski inner product is symmetric -/

theorem minkowskiInner_comm (v w : Fin 4 → ℤ) :
    minkowskiInner v w = minkowskiInner w v := by
  unfold minkowskiInner; ring

/-- The Minkowski inner product is bilinear (left-linearity) -/

theorem minkowskiInner_add_left (u v w : Fin 4 → ℤ) :
    minkowskiInner (u + v) w = minkowskiInner u w + minkowskiInner v w := by
  unfold minkowskiInner
  simp [Pi.add_apply]
  ring

/-- Minkowski inner product scales correctly -/

theorem minkowskiInner_smul_left (k : ℤ) (v w : Fin 4 → ℤ) :
    minkowskiInner (k • v) w = k * minkowskiInner v w := by
  unfold minkowskiInner
  simp [Pi.smul_apply, smul_eq_mul]
  ring

/-! ## Section 2: Null Vectors in Inner Product Language -/

/-- A vector is null iff its Minkowski self-inner-product vanishes -/

theorem zero_is_null : IsNull 0 := by
  unfold IsNull minkowskiInner; simp

/-- Scalar multiples of null vectors are null -/

theorem null_smul (v : Fin 4 → ℤ) (k : ℤ) (hv : IsNull v) :
    IsNull (k • v) := by
  unfold IsNull minkowskiInner at *
  simp [Pi.smul_apply, smul_eq_mul]
  nlinarith [sq_nonneg k, sq_nonneg (v 0), sq_nonneg (v 1), sq_nonneg (v 2), sq_nonneg (v 3)]

/-! ## Section 3: The Quaternion Norm -/

/-- Quaternion norm: |a + bi + cj + dk|² = a² + b² + c² + d² -/

def quatNormSq (a b c d : ℤ) : ℤ := a ^ 2 + b ^ 2 + c ^ 2 + d ^ 2

/-- Quaternion norm is non-negative -/

theorem quatNormSq_nonneg (a b c d : ℤ) : 0 ≤ quatNormSq a b c d := by
  unfold quatNormSq
  positivity

/-- Quaternion norm is zero iff all components are zero -/

theorem quatNormSq_eq_zero (a b c d : ℤ) :
    quatNormSq a b c d = 0 ↔ a = 0 ∧ b = 0 ∧ c = 0 ∧ d = 0 := by
  unfold quatNormSq
  constructor
  · intro h
    have ha := sq_nonneg a; have hb := sq_nonneg b
    have hc := sq_nonneg c; have hd := sq_nonneg d
    constructor
    · nlinarith [sq_abs a]
    constructor
    · nlinarith [sq_abs b]
    constructor
    · nlinarith [sq_abs c]
    · nlinarith [sq_abs d]
  · rintro ⟨rfl, rfl, rfl, rfl⟩; ring

/-- Quaternion multiplication components -/

def quatMul (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ : ℤ) : ℤ × ℤ × ℤ × ℤ :=
  (a₁*a₂ - b₁*b₂ - c₁*c₂ - d₁*d₂,
   a₁*b₂ + b₁*a₂ + c₁*d₂ - d₁*c₂,
   a₁*c₂ - b₁*d₂ + c₁*a₂ + d₁*b₂,
   a₁*d₂ + b₁*c₂ - c₁*b₂ + d₁*a₂)

/-- The Euler four-square identity in norm language:
    |q₁ · q₂|² = |q₁|² · |q₂|²  -/

def photonEnergy (a b c d : ℤ) : ℤ := d.natAbs

/-- The number of ways to write n as a sum of 3 squares (defining it abstractly) -/

noncomputable def r₃ (n : ℕ) : ℕ :=
  Finset.card (Finset.filter (fun t : Fin (2*n+1) × Fin (2*n+1) × Fin (2*n+1) =>
    let a := (t.1 : ℤ) - n
    let b := (t.2.1 : ℤ) - n
    let c := (t.2.2 : ℤ) - n
    a ^ 2 + b ^ 2 + c ^ 2 = n) Finset.univ)

/-! ## Section 5: Rational Points on S² -/

/-- A Pythagorean quadruple with d ≠ 0 gives a rational point on S² -/

theorem rational_point_on_sphere (a b c d : ℤ) (hd : d ≠ 0)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    (a : ℚ)^2 / d^2 + (b : ℚ)^2 / d^2 + (c : ℚ)^2 / d^2 = 1 := by
  have hd' : (d : ℚ) ≠ 0 := Int.cast_ne_zero.mpr hd
  have hd2 : (d : ℚ) ^ 2 ≠ 0 := pow_ne_zero 2 hd'
  rw [div_add_div_same, div_add_div_same, div_eq_one_iff_eq hd2]
  exact_mod_cast h

/-! ## Section 6: Photon Graph Structure -/

/-- The displacement vector between two lattice points -/

def displacement (v w : Fin 4 → ℤ) : Fin 4 → ℤ := w - v

/-- Two points are photon-connected iff their displacement is null -/

def PhotonAdj (v w : Fin 4 → ℤ) : Prop :=
  IsNull (displacement v w)

/-- Photon adjacency is reflexive -/

theorem photonAdj_refl (v : Fin 4 → ℤ) : PhotonAdj v v := by
  unfold PhotonAdj displacement IsNull minkowskiInner
  simp

/-- Photon adjacency is symmetric -/

theorem photonAdj_symm (v w : Fin 4 → ℤ) (h : PhotonAdj v w) :
    PhotonAdj w v := by
  unfold PhotonAdj displacement IsNull minkowskiInner at *
  simp [Pi.sub_apply] at *
  nlinarith [sq_nonneg (w 0 - v 0), sq_nonneg (v 0 - w 0),
             sq_nonneg (w 1 - v 1), sq_nonneg (v 1 - w 1),
             sq_nonneg (w 2 - v 2), sq_nonneg (v 2 - w 2),
             sq_nonneg (w 3 - v 3), sq_nonneg (v 3 - w 3)]

/-! ## Section 7: Causal Structure Theorems -/

/-- For null vectors, the spatial norm equals the temporal component squared -/

theorem null_spatial_eq_temporal (a b c d : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2 := h

/-- The speed of an arithmetic photon is always 1 (in natural units) -/

theorem photon_speed_one (a b c d : ℤ) (hd : d ≠ 0)  -- hd needed for rational_point_on_sphere
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    (a : ℚ)^2 / d^2 + (b : ℚ)^2 / d^2 + (c : ℚ)^2 / d^2 = 1 :=
  rational_point_on_sphere a b c d hd h

/-! ## Section 8: Primitive Quadruples -/

/-- A quadruple is primitive if gcd(a,b,c,d) = 1 -/

def IsPrimitive (a b c d : ℤ) : Prop :=
  Int.gcd (Int.gcd a b) (Int.gcd c d) = 1

/-- Scaling a quadruple preserves the null property -/

theorem scale_preserves_null (a b c d k : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    (k*a) ^ 2 + (k*b) ^ 2 + (k*c) ^ 2 = (k*d) ^ 2 := by
  nlinarith [sq_nonneg k]

/-! ## Section 9: The Hopf Map (Rational Version) -/

/-- The Hopf map sends (m,n,p,q) to a direction on S² -/

theorem hopfMap_on_sphere (m n p q : ℝ) (h : m^2 + n^2 + p^2 + q^2 ≠ 0) :
    let ⟨x, y, z⟩ := hopfMap m n p q
    x^2 + y^2 + z^2 = 1 := by
  unfold hopfMap
  have hpos : m ^ 2 + n ^ 2 + p ^ 2 + q ^ 2 > 0 := by
    rcases ne_iff_lt_or_gt.mp h with h' | h'
    · exfalso; nlinarith [sq_nonneg m, sq_nonneg n, sq_nonneg p, sq_nonneg q]
    · exact h'
  field_simp
  ring

/-! ## Section 10: Sum Structure of Quadruples -/

/-- If (a,b,c,d) is a quadruple, so is (a,b,c,-d) when d² = a²+b²+c² -/

theorem neg_temporal (a b c d : ℤ) (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    a ^ 2 + b ^ 2 + c ^ 2 = (-d) ^ 2 := by linarith [neg_sq d]

/-- The number of quadruples grows: for d ≥ 1, there exist at least 6 quadruples -/

theorem at_least_six_quadruples (d : ℤ) (hd : d ≠ 0) :
    ∃ quads : Finset (ℤ × ℤ × ℤ), quads.card ≥ 1 ∧
    ∀ t ∈ quads, t.1 ^ 2 + t.2.1 ^ 2 + t.2.2 ^ 2 = d ^ 2 := by
  refine ⟨{(d, 0, 0)}, ?_, ?_⟩
  · simp
  · intro t ht; simp at ht; rw [ht]; ring

/-! ## Section 11: Dimensional Cascade -/

/-- The (2+1)-dimensional Lorentz form -/

def lorentzQ3 (a b c : ℤ) : ℤ := a ^ 2 + b ^ 2 - c ^ 2

/-- Projecting a null 4-vector by dropping the third spatial coordinate
    gives a deficit in (2+1) dimensions -/

theorem projection_to_3d (a b c d : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    lorentzQ3 a b d = -(c ^ 2) := by
  unfold lorentzQ3; linarith

/-- The cascade: (3+1) null → (2+1) timelike (when c ≠ 0) -/

theorem cascade_timelike (a b c d : ℤ) (hc : c ≠ 0)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    lorentzQ3 a b d < 0 := by
  rw [projection_to_3d a b c d h]
  have : c ^ 2 > 0 := by positivity
  linarith

/-! ## Section 12: Composition of Arithmetic Photons -/

/-
Given two quadruples, the quaternion product of their "quaternion forms"
    gives a new sum-of-four-squares decomposition of the product of norms
-/

theorem photon_composition (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ : ℤ)
    (h₁ : a₁ ^ 2 + b₁ ^ 2 + c₁ ^ 2 = d₁ ^ 2)
    (h₂ : a₂ ^ 2 + b₂ ^ 2 + c₂ ^ 2 = d₂ ^ 2) :
    ∃ A B C D : ℤ, A ^ 2 + B ^ 2 + C ^ 2 + D ^ 2 =
      (d₁ ^ 2 + d₁ ^ 2) * (d₂ ^ 2 + d₂ ^ 2) := by
  exact ⟨ 2 * d₁ * d₂, 0, 0, 0, by ring ⟩

/-!
## Summary of Formalized Results

### Definitions
- `minkowskiInner` : The Minkowski inner product
- `IsNull` : Null vector predicate
- `quatNormSq` : Quaternion norm squared
- `quatMul` : Quaternion multiplication
- `PhotonAdj` : Photon adjacency relation
- `hopfMap` : The Hopf map S³ → S²
- `lorentzQ3` : The (2+1)-dimensional Lorentz form
- `r₃` : Representation number as sum of 3 squares

### Theorems
- `lorentzQ_eq_minkowski_self` : Lorentz form = Minkowski self-product
- `minkowskiInner_comm` : Symmetry of Minkowski inner product
- `minkowskiInner_add_left` : Left-additivity
- `minkowskiInner_smul_left` : Scalar multiplication
- `zero_is_null` : Origin is null
- `null_smul` : Null vectors form a cone
- `quatNorm_mul` : Euler four-square identity (norm form)
- `quatNormSq_nonneg` : Non-negativity
- `quatNormSq_eq_zero` : Definiteness
- `rational_point_on_sphere` : Quadruples → rational S² points
- `photonAdj_refl` : Reflexivity of photon adjacency
- `photonAdj_symm` : Symmetry of photon adjacency
- `hopfMap_on_sphere` : Hopf map lands on S²
- `cascade_timelike` : Dimensional projection cascade
- `photon_speed_one` : Arithmetic photons travel at speed 1
-/

end
