/-! # CatalogBuild.Physics.Classical.HomingMissile

Auto-generated from theorem catalog database.
Domain: Physics/Classical
Declarations: 34
-/

import Mathlib

/-- A rational point on the unit circle, represented by a Pythagorean triple. -/
structure RatCirclePoint where
  a : ℤ  -- cos component
  b : ℤ  -- sin component
  c : ℤ  -- hypotenuse
  pyth : a ^ 2 + b ^ 2 = c ^ 2
  c_pos : 0 < c


/-- The "angular cross-product" = c₁·c₂·sin(θ₂ - θ₁). -/
def angularCross (p q : RatCirclePoint) : ℤ :=
  p.a * q.b - p.b * q.a


/-- The "angular dot-product" = c₁·c₂·cos(θ₂ - θ₁). -/
def angularDot (p q : RatCirclePoint) : ℤ :=
  p.a * q.a + p.b * q.b


/-- Angular cross-product is antisymmetric. -/
theorem angularCross_antisymm (p q : RatCirclePoint) :
    angularCross p q = -angularCross q p := by
  simp [angularCross]; ring


/-- Angular dot-product is symmetric. -/
theorem angularDot_symm (p q : RatCirclePoint) :
    angularDot p q = angularDot q p := by
  simp [angularDot]; ring


/-- The Pythagorean identity for cross and dot products:
(cross)² + (dot)² = (c₁·c₂)² -/
theorem angular_pythagorean (p q : RatCirclePoint) :
    (angularCross p q) ^ 2 + (angularDot p q) ^ 2 = (p.c * q.c) ^ 2 := by
  simp [angularCross, angularDot]
  nlinarith [p.pyth, q.pyth, sq_nonneg (p.a * q.a), sq_nonneg (p.b * q.b),
             sq_nonneg (p.a * q.b), sq_nonneg (p.b * q.a)]


/-- Squared angular distance (∝ sin²(θ₂ - θ₁)). The missile minimizes this. -/
def angularDistSq (p q : RatCirclePoint) : ℤ :=
  (angularCross p q) ^ 2


/-- Angular distance is zero iff cross-product is zero. -/
theorem angularDistSq_zero_iff (p q : RatCirclePoint) :
    angularDistSq p q = 0 ↔ angularCross p q = 0 := by
  constructor
  · intro h; simp [angularDistSq] at h; exact h
  · intro h; simp [angularDistSq, h]


/-- Angular distance is symmetric. -/
theorem angularDistSq_symm (p q : RatCirclePoint) :
    angularDistSq p q = angularDistSq q p := by
  simp [angularDistSq, angularCross]; ring


/-- Euclid parameters (m, n) with m > n > 0. -/
structure EuclidParams where
  m : ℤ
  n : ℤ
  m_pos : 0 < m
  n_pos : 0 < n
  m_gt_n : n < m


/-- Convert Euclid parameters to a Pythagorean triple. -/
def euclidToTriple (p : EuclidParams) : ℤ × ℤ × ℤ :=
  (p.m ^ 2 - p.n ^ 2, 2 * p.m * p.n, p.m ^ 2 + p.n ^ 2)


/-- Berggren branch M₂: (m,n) ↦ (2m+n, m) -/
def berggren_M2 (p : EuclidParams) : EuclidParams where
  m := 2 * p.m + p.n
  n := p.m
  m_pos := by linarith [p.m_pos, p.n_pos]
  n_pos := p.m_pos
  m_gt_n := by linarith [p.m_pos, p.n_pos]


/-- The hypotenuse of Euclid parameters. -/
def hypot (p : EuclidParams) : ℤ := p.m ^ 2 + p.n ^ 2


/-- M₂ strictly increases the hypotenuse. -/
theorem hypot_M2_gt (p : EuclidParams) : hypot p < hypot (berggren_M2 p) := by
  simp [hypot, berggren_M2]
  nlinarith [p.m_pos, p.n_pos, sq_nonneg p.m, sq_nonneg p.n,
             sq_nonneg (p.m + p.n), sq_nonneg (p.m - p.n)]


/-- M₃ strictly increases the hypotenuse. -/
theorem hypot_M3_gt (p : EuclidParams) : hypot p < hypot (berggren_M3 p) := by
  simp [hypot, berggren_M3]
  nlinarith [p.m_pos, p.n_pos, sq_nonneg p.m, sq_nonneg p.n,
             sq_nonneg (p.m + p.n)]


/-- The compass reading n/m = tan(θ/2). -/
def compassReading (p : EuclidParams) : ℚ :=
  p.n / p.m


/-- Root compass reading is 1/2. -/
theorem compass_root : compassReading ⟨2, 1, by omega, by omega, by omega⟩ = 1/2 := by
  simp [compassReading]


/-- Origin type for Berggren tree nodes. -/
inductive BerggrenOrigin where
  | root : BerggrenOrigin
  | fromM1 : BerggrenOrigin
  | fromM2 : BerggrenOrigin
  | fromM3 : BerggrenOrigin
  deriving Repr, DecidableEq


/-- Parent computation — the "course correction" operation. -/
def berggrenParent (m n : ℤ) : ℤ × ℤ × BerggrenOrigin :=
  if m = 2 ∧ n = 1 then (2, 1, .root)
  else if n ≥ m then (m, n, .root)
  else if m > 2 * n then (n, m - 2 * n, .fromM2)
  else if 2 * n > m ∧ m > n then (n, 2 * n - m, .fromM1)
  else (m - 2 * n, n, .fromM3)


/-- Gaussian integer multiplication. -/
def gaussMul (a b c d : ℤ) : ℤ × ℤ := (a*c - b*d, a*d + b*c)


/-- Gaussian norm is multiplicative. -/
theorem gaussNorm_mul (a b c d : ℤ) :
    gaussNorm (gaussMul a b c d).1 (gaussMul a b c d).2 =
    gaussNorm a b * gaussNorm c d := by
  simp [gaussNorm, gaussMul]; ring


/-- Target acquisition: found (a,b,c) with c | N. -/
def targetAcquired (N : ℤ) (a b c : ℤ) : Prop :=
  a ^ 2 + b ^ 2 = c ^ 2 ∧ c ∣ N


theorem compass_M3_lt_M2 (p : EuclidParams) :
    compassReading (berggren_M3 p) < compassReading (berggren_M2 p) := by
  unfold compassReading;
  rw [ div_lt_div_iff₀ ] <;> norm_cast;
  · -- By definition of berggren_M3 and berggren_M2, we have:
    simp [berggren_M3, berggren_M2];
    nlinarith [ p.m_pos, p.n_pos, p.m_gt_n ];
  · exact add_pos p.m_pos ( mul_pos two_pos p.n_pos );
  · exact add_pos ( mul_pos two_pos p.m_pos ) p.n_pos


theorem compass_M3_decreases (p : EuclidParams) :
    compassReading (berggren_M3 p) < compassReading p := by
  unfold compassReading berggren_M3;
  gcongr <;> norm_num [ EuclidParams ];
  · exact p.n_pos;
  · exact p.m_pos;
  · exact p.n_pos


theorem compass_in_unit_interval (p : EuclidParams) :
    0 < compassReading p ∧ compassReading p < 1 := by
  exact ⟨ div_pos ( mod_cast p.n_pos ) ( mod_cast p.m_pos ), div_lt_one ( mod_cast p.m_pos ) |>.2 ( mod_cast p.m_gt_n ) ⟩


/-- Gate composition: Gaussian norm is multiplicative. -/
theorem gate_composition_norm (a₁ b₁ a₂ b₂ : ℤ) :
    gaussNorm (a₁*a₂ - b₁*b₂) (a₁*b₂ + b₁*a₂) =
    gaussNorm a₁ b₁ * gaussNorm a₂ b₂ := by
  simp [gaussNorm]; ring


/-- M₂ hypotenuse formula. -/
theorem M2_hypot_formula (p : EuclidParams) :
    hypot (berggren_M2 p) = 5 * p.m ^ 2 + 4 * p.m * p.n + p.n ^ 2 := by
  simp [hypot, berggren_M2]; ring


/-- M₃ hypotenuse formula. -/
theorem M3_hypot_formula (p : EuclidParams) :
    hypot (berggren_M3 p) = p.m ^ 2 + 4 * p.m * p.n + 5 * p.n ^ 2 := by
  simp [hypot, berggren_M3]; ring


theorem compass_M2_lt_one (p : EuclidParams) :
    compassReading (berggren_M2 p) < 1 := by
  convert div_lt_one _ |>.2 _;
  · infer_instance;
  · exact_mod_cast ( by linarith [ p.m_pos, p.n_pos ] : 0 < ( 2 * p.m + p.n : ℤ ) );
  · norm_cast;
    exact show p.m < 2 * p.m + p.n from by linarith [ p.m_pos, p.n_pos ] ;


theorem compass_M2_bounded (p : EuclidParams) :
    compassReading (berggren_M2 p) < 1/2 := by
  norm_num [ compassReading, berggren_M2 ];
  rw [ div_lt_div_iff₀ ] <;> norm_cast <;> linarith [ p.m_pos, p.n_pos ]


/-- Compass M₂ explicit value. -/
theorem compass_M2_value (p : EuclidParams) :
    compassReading (berggren_M2 p) = p.m / (2 * p.m + p.n) := by
  simp [compassReading, berggren_M2]


/-- Compass M₃ explicit value. -/
theorem compass_M3_value (p : EuclidParams) :
    compassReading (berggren_M3 p) = p.n / (p.m + 2 * p.n) := by
  simp [compassReading, berggren_M3]


/-- M₃ always decreases AND M₃ is less than M₂. -/
theorem compass_M3_bracket (p : EuclidParams) :
    compassReading (berggren_M3 p) < compassReading (berggren_M2 p) ∧
    compassReading (berggren_M3 p) < compassReading p :=
  ⟨compass_M3_lt_M2 p, compass_M3_decreases p⟩


theorem factor_from_pyth_triple (a b c : ℤ) (hpyth : a ^ 2 + b ^ 2 = c ^ 2)
    (hc : 0 < c) (ha : 0 < a) (hb : 0 < b) :
    a < c := by
  nlinarith

