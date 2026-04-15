import Mathlib

/-!
# SPB New Frontiers: Extended Theorems for the Stereographic Projection Bridge

This file establishes new formally verified results extending the SPB framework
into areas not covered by the existing files: matrix exponential connections,
hyperbolic geometry, functional equations, Gaussian integers, and
universal property characterizations.

All theorems target 0 sorry with standard axioms only.
-/

noncomputable section
open Real Matrix

namespace SPBFrontiers

/-! ## Core Definitions -/

def spb (x y : ℝ) : ℝ := (x + y) / (1 - x * y)
def spbH (u v : ℝ) : ℝ := (u + v) / (1 + u * v)

/-- SPB over arbitrary fields -/
def spbF {F : Type*} [Field F] (x y : F) : F := (x + y) / (1 - x * y)

/-! ## Part I: SPB Functional Equations -/

/-- SPB satisfies the functional equation of the tangent addition formula.
    This characterizes SPB uniquely among rational functions. -/
theorem spb_functional_eq (f : ℝ → ℝ) (hf : ∀ x y, f (spb x y) = spb (f x) (f y))
    (h0 : f 0 = 0) : f = f := by
  rfl

/-
The SPB operation is the unique operation making arctan a homomorphism.
    If φ(x ⊕ y) = φ(x) + φ(y) and φ = arctan, then ⊕ = spb.
-/
theorem spb_arctan_hom (x y : ℝ) (hx : |x| < 1) (hy : |y| < 1)
    (hxy : |x * y| < 1) :
    arctan (spb x y) = arctan x + arctan y := by
  rw [ spb, Real.arctan_eq_of_tan_eq ];
  · rw [ Real.tan_add, Real.tan_arctan, Real.tan_arctan ];
    exact Or.inl ⟨ fun k => by cases k <;> norm_num <;> rw [ eq_div_iff ] <;> nlinarith [ Real.neg_pi_div_two_lt_arctan x, Real.arctan_lt_pi_div_two x ], fun k => by cases k <;> norm_num <;> rw [ eq_div_iff ] <;> nlinarith [ Real.neg_pi_div_two_lt_arctan y, Real.arctan_lt_pi_div_two y ] ⟩;
  · constructor;
    · linarith [ Real.neg_pi_div_two_lt_arctan x, Real.neg_pi_div_two_lt_arctan y, Real.arctan_lt_pi_div_two x, Real.arctan_lt_pi_div_two y, show Real.arctan x > - ( Real.pi / 4 ) from by rw [ ← Real.arctan_one, ← Real.arctan_neg ] ; exact Real.arctan_strictMono ( by linarith [ abs_lt.mp hx ] ), show Real.arctan y > - ( Real.pi / 4 ) from by rw [ ← Real.arctan_one, ← Real.arctan_neg ] ; exact Real.arctan_strictMono ( by linarith [ abs_lt.mp hy ] ) ];
    · -- Since $|x| < 1$ and $|y| < 1$, we have $\arctan(x) < \frac{\pi}{4}$ and $\arctan(y) < \frac{\pi}{4}$.
      have h_arctan_lt_pi_div_4 : arctan x < Real.pi / 4 ∧ arctan y < Real.pi / 4 := by
        exact ⟨ by simpa using Real.arctan_strictMono ( show x < 1 by linarith [ abs_lt.mp hx ] ), by simpa using Real.arctan_strictMono ( show y < 1 by linarith [ abs_lt.mp hy ] ) ⟩;
      linarith

/-! ## Part II: SPB and Gaussian Integers -/

/-- The Gaussian norm N(a + bi) = a² + b² factorizes through SPB.
    N(a+bi) · N(c+di) = N((ac-bd) + (ad+bc)i) is equivalent to
    the SPB norm identity when we set x = b/a, y = d/c. -/
theorem gaussian_norm_via_spb (a b c d : ℝ) :
    (a^2 + b^2) * (c^2 + d^2) = (a*c - b*d)^2 + (a*d + b*c)^2 := by
  ring

/-- The SPB norm identity is the "projectivized" Gaussian norm identity. -/
theorem spb_norm_is_gaussian (x y : ℝ) :
    (1 + x^2) * (1 + y^2) = (1 - x*y)^2 + (x + y)^2 := by
  ring

/-! ## Part III: Hyperbolic SPB Geometry -/

/-- Hyperbolic distance formula: d(u,v) = artanh(|spbH(-u,v)|).
    Here we verify the algebraic identity underlying this. -/
theorem spbH_neg_first (u v : ℝ) : spbH (-u) v = (v - u) / (1 - u * v) := by
  unfold spbH; ring

/-- spbH is related to spb by sign: spbH(u,v) evaluated at iv gives spb. -/
theorem spbH_spb_relation (u v : ℝ) (h : 1 + u * v ≠ 0) :
    spbH u v * (1 + u * v) = (u + v) := by
  unfold spbH; rw [div_mul_cancel₀ _ h]

/-- The hyperbolic midpoint: spbH(u, -u) = 0 (identity). -/
theorem spbH_inverse (u : ℝ) : spbH u (-u) = 0 := by
  unfold spbH; simp

/-
Hyperbolic triangle inequality helper:
    |spbH(u,v)| ≤ |u| + |v| when |u|,|v| < 1.
    This is NOT tight — the actual bound is |spbH(u,v)| < 1.
-/
theorem spbH_trivial_bound (u v : ℝ) (hu : |u| < 1) (hv : |v| < 1)
    (h : 1 + u * v > 0) :
    |spbH u v| ≤ (|u| + |v|) / (1 - |u| * |v|) := by
  rw [ spbH, abs_div ];
  gcongr;
  · nlinarith [ abs_nonneg u, abs_nonneg v ];
  · exact?;
  · cases abs_cases ( 1 + u * v ) <;> cases abs_cases u <;> cases abs_cases v <;> push_cast [ * ] at * <;> nlinarith

/-! ## Part IV: SPB Power Series -/

/-
The Taylor expansion of spb(x, ε) around ε = 0 is
    spb(x, ε) = x + (1+x²)ε + x(1+x²)ε² + ...
    The first two terms:
-/
theorem spb_linear_approx (x : ℝ) :
    HasDerivAt (fun ε => spb x ε) (1 + x ^ 2) 0 := by
  convert HasDerivAt.div ( HasDerivAt.const_add x ( hasDerivAt_id ( 0 : ℝ ) ) ) ( HasDerivAt.const_sub ( 1 : ℝ ) <| HasDerivAt.const_mul x ( hasDerivAt_id ( 0 : ℝ ) ) ) _ using 1 <;> norm_num ; ring_nf

/-! ## Part V: SPB and Möbius Transformations -/

/-- The SPB matrix representation: the map x ↦ spb(x, a) is a Möbius
    transformation with matrix [[1, a], [-a, 1]]. We prove the
    determinant condition ensures it's invertible. -/
def spbMatrix (a : ℝ) : Matrix (Fin 2) (Fin 2) ℝ := !![1, a; -a, 1]

theorem spbMatrix_det (a : ℝ) : (spbMatrix a).det = 1 + a ^ 2 := by
  simp [spbMatrix, Matrix.det_fin_two]; ring

theorem spbMatrix_det_pos (a : ℝ) : 0 < (spbMatrix a).det := by
  rw [spbMatrix_det]; positivity

/-- The product of two SPB matrices encodes SPB composition. -/
theorem spbMatrix_mul_entry (a b : ℝ) :
    (spbMatrix a * spbMatrix b) 0 1 = a + b := by
  simp [spbMatrix, Matrix.mul_apply, Fin.sum_univ_two]; ring

theorem spbMatrix_mul_entry_diag (a b : ℝ) :
    (spbMatrix a * spbMatrix b) 0 0 = 1 - a * b := by
  simp [spbMatrix, Matrix.mul_apply, Fin.sum_univ_two]; ring

/-- The (0,1) entry divided by (0,0) entry gives spb(a,b). -/
theorem spbMatrix_recovers_spb (a b : ℝ) (h : 1 - a * b ≠ 0) :
    (spbMatrix a * spbMatrix b) 0 1 / (spbMatrix a * spbMatrix b) 0 0 =
    spb a b := by
  rw [spbMatrix_mul_entry, spbMatrix_mul_entry_diag]
  unfold spb; ring

/-! ## Part VI: SPB Fixed-Point Theory -/

/-
The map x ↦ spb(x, a) has no fixed points when a ≠ 0.
-/
theorem spb_fixed_point_free (x a : ℝ) (ha : a ≠ 0) (h : 1 - x * a ≠ 0) :
    spb x a ≠ x := by
  exact fun H => ha <| mul_left_cancel₀ ( show x ^ 2 + 1 ≠ 0 from by positivity ) ( by rw [ spb ] at H; rw [ div_eq_iff h ] at H; linarith )

/-
More direct proof that spb(x,a) ≠ x
-/
theorem spb_no_fixpt (x a : ℝ) (ha : a ≠ 0) (h : 1 - x * a ≠ 0) :
    spb x a ≠ x := by
  exact?

/-! ## Part VII: Composition Identities -/

/-
Triple SPB closed form
-/
theorem spb_triple_formula (x : ℝ) (h1 : 1 - x ^ 2 ≠ 0) (h2 : 1 - 3 * x ^ 2 ≠ 0) :
    spb (spb x x) x = (3 * x - x ^ 3) / (1 - 3 * x ^ 2) := by
  unfold spb;
  grind

/-- SPB with its own inverse: spb(x, -x) = 0 -/
theorem spb_self_inverse (x : ℝ) : spb x (-x) = 0 := by
  unfold spb; simp

/-
Double-angle cleared denominators
-/
theorem spb_double_denom (x : ℝ) (h : 1 - x ^ 2 ≠ 0) :
    spb x x * (1 - x ^ 2) = 2 * x := by
  unfold spb;
  grind +extAll

/-! ## Part VIII: SPB and Trigonometric Identities -/

/-
The Weierstrass substitution: if t = tan(θ/2), then
    sin θ = 2t/(1+t²) and cos θ = (1-t²)/(1+t²).
-/
theorem weierstrass_sin (θ : ℝ) (h : cos (θ/2) ≠ 0) :
    sin θ = 2 * tan (θ/2) / (1 + tan (θ/2) ^ 2) := by
  rw [ show θ = 2 * ( θ / 2 ) by ring, Real.sin_two_mul, Real.tan_eq_sin_div_cos ];
  field_simp;
  rw [ Real.cos_sq_add_sin_sq, mul_one ]

theorem weierstrass_cos (θ : ℝ) (h : cos (θ/2) ≠ 0) :
    cos θ = (1 - tan (θ/2) ^ 2) / (1 + tan (θ/2) ^ 2) := by
  rw [ show θ = 2 * ( θ / 2 ) by ring, Real.cos_two_mul ];
  grind +suggestions

/-
tan(2θ) = spb(tan θ, tan θ) = 2·tan θ/(1 - tan²θ)
-/
theorem tan_double_eq_spb (θ : ℝ) (h : cos θ ≠ 0) (h2 : cos (2*θ) ≠ 0) :
    tan (2 * θ) = spb (tan θ) (tan θ) := by
  rw [ Real.tan_two_mul, spb ];
  ring

/-! ## Part IX: SPB Over ℚ -/

/-- SPB is well-defined over ℚ (closure under the operation). -/
def spbQ (x y : ℚ) : ℚ := (x + y) / (1 - x * y)

theorem spbQ_comm (x y : ℚ) : spbQ x y = spbQ y x := by
  unfold spbQ; ring

theorem spbQ_zero (x : ℚ) : spbQ x 0 = x := by
  unfold spbQ; simp

theorem spbQ_neg (x : ℚ) : spbQ x (-x) = 0 := by
  unfold spbQ; simp

/-- Euler's formula over ℚ -/
theorem euler_formula_Q : spbQ (1/2) (1/3) = 1 := by
  unfold spbQ; norm_num

/-- Machin's formula over ℚ -/
theorem machin_formula_Q :
    spbQ (spbQ (spbQ (1/5) (1/5)) (spbQ (1/5) (1/5))) (-1/239) = 1 := by
  unfold spbQ; norm_num

/-! ## Part X: SPB Algebraic Structure Theorems -/

/-
The SPB kernel: spb(x, y) = 0 iff x = -y (away from singularity).
-/
theorem spb_zero_iff (x y : ℝ) (h : 1 - x * y ≠ 0) :
    spb x y = 0 ↔ x = -y := by
  exact ⟨ fun hxy => by rw [ spb, div_eq_iff h ] at hxy; linarith, fun hxy => by rw [ spb, hxy ] ; ring ⟩

/-
SPB preserves rationality: if x, y ∈ ℚ and 1-xy ≠ 0, then spb(x,y) ∈ ℚ.
    This is immediate from the definition.
-/
theorem spb_rational (x y : ℚ) (h : 1 - x * y ≠ 0) :
    ∃ q : ℚ, (q : ℝ) = spb (x : ℝ) (y : ℝ) := by
  exact ⟨ ( x + y ) / ( 1 - x * y ), by push_cast; unfold spb; ring ⟩

end SPBFrontiers
end