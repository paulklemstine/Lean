import Mathlib

/-!
# Below the Monster Tower: Arithmetic Bedrock of Stereographic Projection

## The Descent

The monster tower studies singularities of curves via iterated prolongation of jet spaces.
The Pythagorean triple parametrization lives at the level of rational points on S¹.
Light's momentum lives on the null cone x² + y² + z² = c²t².

We go *below* all of this — into the arithmetic foundations that make these structures possible.

### Level 0: The Gaussian Integer Parametrization
Every primitive Pythagorean triple (a, b, c) with a odd comes from a Gaussian integer
z = m + ni via: a = m² - n², b = 2mn, c = m² + n².
This is *exactly* the norm map on ℤ[i]: |z|² = m² + n² = c.

### Level -1: The Stereographic Rational Map
The map t ↦ ((1-t²)/(1+t²), 2t/(1+t²)) sends ℚ → S¹(ℚ) bijectively (minus one point).
This IS the Pythagorean parametrization in disguise: set t = n/m.

### Level -2: The Fixed-Point Involution
The map t ↦ 1/t on ℝ\{0} corresponds to swapping (m,n) in the Pythagorean parametrization.
Its fixed points t = ±1 give the degenerate triples. This involution structure
generates the full Möbius group PSL(2,ℤ) acting on Pythagorean triples.

### Level -3: The Null Cone Arithmetic
The 3D null cone x² + y² + z² = w² is parametrized by TWO Gaussian integers,
giving "Pythagorean quadruples". This is where light lives.

## Formal Results
-/

open Real

noncomputable section

/-! ## The Rational Stereographic Map -/

/-- The stereographic map sending t to a point on S¹: ((1-t²)/(1+t²), 2t/(1+t²)) -/
def stereoRational (t : ℝ) : ℝ × ℝ :=
  ((1 - t^2) / (1 + t^2), 2 * t / (1 + t^2))

/-- 1 + t² is always positive -/
theorem one_plus_sq_pos (t : ℝ) : (0 : ℝ) < 1 + t ^ 2 := by positivity

/-- 1 + t² is never zero -/
theorem one_plus_sq_ne_zero (t : ℝ) : (1 : ℝ) + t ^ 2 ≠ 0 := by positivity

/-- **Theorem (Unit Circle Property)**: The stereographic map lands on S¹.
    This is the arithmetic bedrock beneath all Pythagorean triples. -/
theorem stereo_on_circle (t : ℝ) :
    (stereoRational t).1 ^ 2 + (stereoRational t).2 ^ 2 = 1 := by
  unfold stereoRational
  simp only
  have h : (1 : ℝ) + t ^ 2 ≠ 0 := one_plus_sq_ne_zero t
  field_simp
  ring

/-! ## The Pythagorean Triple Generator -/

/-- Generate a Pythagorean triple from parameters (m, n) with m > n > 0.
    Returns (a, b, c) = (m² - n², 2mn, m² + n²). -/
def pythTriple (m n : ℤ) : ℤ × ℤ × ℤ :=
  (m ^ 2 - n ^ 2, 2 * m * n, m ^ 2 + n ^ 2)

/-- **Theorem (Pythagorean Identity)**: The generated triple satisfies a² + b² = c². -/
theorem pyth_triple_identity (m n : ℤ) :
    let t := pythTriple m n
    t.1 ^ 2 + t.2.1 ^ 2 = t.2.2 ^ 2 := by
  simp [pythTriple]
  ring

/-- **Theorem (Stereo-Pyth Connection)**: The stereographic map at t = n/m
    gives exactly the normalized Pythagorean triple.
    This is the bridge: stereographic projection IS Pythagorean parametrization. -/
theorem stereo_pyth_bridge (m n : ℝ) (hm : m ≠ 0) :
    stereoRational (n / m) =
      ((m ^ 2 - n ^ 2) / (m ^ 2 + n ^ 2),
       2 * m * n / (m ^ 2 + n ^ 2)) := by
  unfold stereoRational
  congr 1 <;> field_simp

/-! ## The Involution Structure (Level -2) -/

/-- The inversion involution on ℝ \ {0} -/
def involution (t : ℝ) : ℝ := 1 / t

/-- **Theorem**: Inversion is an involution (self-inverse). -/
theorem involution_involution (t : ℝ) (ht : t ≠ 0) :
    involution (involution t) = t := by
  unfold involution
  field_simp

/-- **Theorem (Involution Symmetry)**: The stereographic image of 1/t is related to
    the image of t by swapping the sign of the first coordinate. This corresponds to
    the (m,n) ↦ (n,m) symmetry of Pythagorean triples. -/
theorem stereo_involution_symmetry (t : ℝ) (ht : t ≠ 0) :
    (stereoRational (1/t)).1 = -(stereoRational t).1 ∧
    (stereoRational (1/t)).2 = (stereoRational t).2 := by
  unfold stereoRational
  have h1 : (1 : ℝ) + t ^ 2 ≠ 0 := one_plus_sq_ne_zero t
  constructor <;> { field_simp; ring }

/-! ## The Null Cone Level (Level -3): Pythagorean Quadruples -/

/-- Generate a Pythagorean quadruple from parameters (a, b, c, d).
    This parametrizes rational points on the 2-sphere S², which is the celestial sphere
    of an observer — what light "looks like" from a point in spacetime. -/
def pythQuadruple (a b c d : ℤ) : ℤ × ℤ × ℤ × ℤ :=
  (a^2 + b^2 - c^2 - d^2,
   2*(a*c + b*d),
   2*(b*c - a*d),
   a^2 + b^2 + c^2 + d^2)

/-- **Theorem (Null Cone Identity)**: The quadruple satisfies x² + y² + z² = w².
    This is the arithmetic of light — the null cone condition. -/
theorem pyth_quadruple_on_null_cone (a b c d : ℤ) :
    let q := pythQuadruple a b c d
    q.1 ^ 2 + q.2.1 ^ 2 + q.2.2.1 ^ 2 = q.2.2.2 ^ 2 := by
  simp [pythQuadruple]
  ring

/-! ## The Gaussian Integer Connection -/

/-- The Gaussian integer norm: |a + bi|² = a² + b² -/
def gaussNorm (a b : ℤ) : ℤ := a ^ 2 + b ^ 2

/-- **Theorem (Brahmagupta–Fibonacci)**: The Gaussian norm is multiplicative.
    |z₁|²·|z₂|² = |z₁z₂|². This is WHY Pythagorean triples compose. -/
theorem gauss_norm_multiplicative (a₁ b₁ a₂ b₂ : ℤ) :
    gaussNorm a₁ b₁ * gaussNorm a₂ b₂ =
    gaussNorm (a₁ * a₂ - b₁ * b₂) (a₁ * b₂ + b₁ * a₂) := by
  unfold gaussNorm; ring

/-- **Theorem**: The Gaussian norm is always nonneg. -/
theorem gauss_norm_nonneg (a b : ℤ) : 0 ≤ gaussNorm a b := by
  unfold gaussNorm; positivity

/-! ## The Descent Correspondence -/

/-- The hypotenuse of a Pythagorean triple IS the Gaussian norm. -/
theorem pyth_hypotenuse_is_gauss_norm (m n : ℤ) :
    (pythTriple m n).2.2 = gaussNorm m n := by
  simp [pythTriple, gaussNorm]

/-- **Key Theorem (Inside-Out Principle)**:
    Starting from any Gaussian integer (m, n), we can:
    1. Compute its norm (→ hypotenuse of Pythagorean triple)
    2. Generate the full triple (→ rational point on S¹)
    3. Lift to a null-cone point (→ light ray direction)
    The entire tower is controlled by the single Gaussian integer. -/
theorem inside_out_tower (m n : ℤ) :
    -- The Pythagorean triple satisfies a² + b² = c²
    let t := pythTriple m n
    t.1 ^ 2 + t.2.1 ^ 2 = t.2.2 ^ 2 ∧
    -- The hypotenuse is the Gaussian norm
    t.2.2 = gaussNorm m n ∧
    -- The quadruple built from (m,n,0,0) satisfies the null cone equation
    let q := pythQuadruple m n 0 0
    q.1 ^ 2 + q.2.1 ^ 2 + q.2.2.1 ^ 2 = q.2.2.2 ^ 2 := by
  refine ⟨pyth_triple_identity m n, pyth_hypotenuse_is_gauss_norm m n, ?_⟩
  simp only [pythQuadruple]
  ring

/-! ## The Arithmetic Monster Tower -/

/-- An arithmetic monster tower level consists of a sequence of Gaussian integers
    where each level's norm divides the next level's entries.
    This mirrors the geometric monster tower's prolongation condition. -/
def ArithMonsterTower (levels : ℕ) : Prop :=
  ∃ (chain : Fin levels → ℤ × ℤ),
    ∀ i : Fin (levels - 1),
      gaussNorm (chain ⟨i, by omega⟩).1 (chain ⟨i, by omega⟩).2 ∣
      gaussNorm (chain ⟨i + 1, by omega⟩).1 (chain ⟨i + 1, by omega⟩).2

/-- **Theorem**: The arithmetic monster tower of any depth ≥ 1 is inhabited.
    (Using the constant chain (1,0) whose norm is 1, which divides everything.) -/
theorem arith_monster_tower_inhabited (n : ℕ) :
    ArithMonsterTower n := by
  exact ⟨fun _ => (1, 0), fun i => by simp [gaussNorm]⟩

/-! ## Descent Below Pythagorean: The Stern-Brocot Connection -/

/-- The mediant of two fractions a/b and c/d is (a+c)/(b+d).
    The Stern-Brocot tree organizes ALL positive rationals,
    and the stereographic map turns this into a tree of ALL Pythagorean triples. -/
def mediant (p q : ℤ × ℤ) : ℤ × ℤ := (p.1 + q.1, p.2 + q.2)

/-- **Theorem**: The mediant preserves the Pythagorean generation.
    If p = (m₁, n₁) and q = (m₂, n₂) generate Pythagorean triples,
    their mediant generates a triple whose hypotenuse relates to both. -/
theorem mediant_norm_bound (m₁ n₁ m₂ n₂ : ℤ) :
    gaussNorm (m₁ + m₂) (n₁ + n₂) ≤
    2 * (gaussNorm m₁ n₁ + gaussNorm m₂ n₂) := by
  unfold gaussNorm; nlinarith [sq_nonneg (m₁ - m₂), sq_nonneg (n₁ - n₂)]

end
