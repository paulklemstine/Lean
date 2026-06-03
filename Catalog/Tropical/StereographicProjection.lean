/-
  Tropical Stereographic Projection

  This file develops the theory of tropical Möbius transformations and
  tropical stereographic projection. The key insight is that tropical
  Möbius transformations, defined via max-plus 2×2 matrices acting on
  the tropical projective line TP¹, form a monoid under tropical matrix
  multiplication — and stereographic projection is a distinguished element
  of this monoid.

  Main results:
  - `TropMat.actHom_mul`: Composition of homogeneous actions equals the
    action of the tropical matrix product (the representation theorem).
  - `TropMat.eval_bounded`: The affine evaluation of any tropical Möbius
    transformation is bounded between min(a-c, b-d) and max(a-c, b-d).
  - `TropMat.mul_assoc`: Tropical matrix multiplication is associative.
  - `TropMat.stereo_linear`: On [0, p], the stereographic projection is linear.
  - `TropMat.eval_injective_on_active`: Injectivity on the active interval.
-/

import Mathlib

noncomputable section

open Real

/-! ## Tropical 2×2 Matrices and Max-Plus Algebra -/

/-- A tropical 2×2 matrix with entries in ℝ.
    Represents a tropical Möbius transformation on TP¹.
    The matrix [[a, b], [c, d]] acts on tropical homogeneous
    coordinates (x, y) as (max(a+x, b+y), max(c+x, d+y)). -/
structure TropMat where
  a : ℝ  -- entry (0,0)
  b : ℝ  -- entry (0,1)
  c : ℝ  -- entry (1,0)
  d : ℝ  -- entry (1,1)

namespace TropMat

/-! ### Tropical matrix multiplication -/

/-- Tropical matrix multiplication (max-plus product).
    (M ⊗ N)ᵢⱼ = max_k (Mᵢₖ + Nₖⱼ) -/
def mul (M N : TropMat) : TropMat where
  a := max (M.a + N.a) (M.b + N.c)
  b := max (M.a + N.b) (M.b + N.d)
  c := max (M.c + N.a) (M.d + N.c)
  d := max (M.c + N.b) (M.d + N.d)

/-! ### Homogeneous action on tropical projective coordinates -/

/-- The homogeneous action of a tropical matrix on a pair (x, y) ∈ ℝ².
    This is the tropical analog of matrix-vector multiplication:
    M · (x, y) = (max(a+x, b+y), max(c+x, d+y)) -/
def actHom (M : TropMat) (p : ℝ × ℝ) : ℝ × ℝ :=
  (max (M.a + p.1) (M.b + p.2), max (M.c + p.1) (M.d + p.2))

/-! ### Affine evaluation -/

/-- The affine evaluation of a tropical Möbius transformation.
    In the affine chart y = 0:
    φ_M(t) = max(a + t, b) - max(c + t, d)
    This is a piecewise-linear function with slopes in {-1, 0, 1}. -/
def eval (M : TropMat) (t : ℝ) : ℝ :=
  max (M.a + t) M.b - max (M.c + t) M.d

/-! ### Tropical determinant -/

/-- The tropical determinant: det⊕(M) = max(a + d, b + c).
    This is the tropical analog of ad + bc (replacing * with + and + with max). -/
def tropDet (M : TropMat) : ℝ := max (M.a + M.d) (M.b + M.c)

/-- A tropical matrix is non-degenerate when its tropical determinant
    has a unique maximum, i.e., a + d ≠ b + c. -/
def IsNondeg (M : TropMat) : Prop := M.a + M.d ≠ M.b + M.c

/-! ### Tropical stereographic projection -/

/-- The tropical stereographic projection from pole p.
    This is the tropical matrix [[0, 0], [0, p]], which gives the
    affine evaluation φ_p(t) = max(t, 0) - max(t, p).

    For p > 0, this maps:
    - t < 0 ↦ -p (constant, "southern hemisphere")
    - 0 ≤ t ≤ p ↦ t - p (linear, slope 1, "equatorial band")
    - t > p ↦ 0 (constant, "near the pole")

    The pole p is the "point at infinity" that gets removed. -/
def stereo (p : ℝ) : TropMat where
  a := 0
  b := 0
  c := 0
  d := p

/-- The antipodal stereographic projection: reversing the pole. -/
def stereoAnti (p : ℝ) : TropMat where
  a := p
  b := 0
  c := 0
  d := 0

/-! ## Main Theorems -/

/-
**Representation Theorem**: The homogeneous action respects tropical
    matrix multiplication. That is, (M ⊗ N) · p = M · (N · p).

    This is the key structural result: it shows that tropical 2×2 matrices
    form a faithful representation of the tropical Möbius monoid.

    The proof uses the fundamental distributivity law a + max(b, c) = max(a+b, a+c)
    and the associativity/commutativity of max.
-/
theorem actHom_mul (M N : TropMat) (p : ℝ × ℝ) :
    actHom (mul M N) p = actHom M (actHom N p) := by
  -- By definition of actHom, we can expand both sides.
  simp [TropMat.actHom, TropMat.mul];
  constructor <;> simp +decide only [max_def]; all_goals grind

/-
Tropical matrix multiplication is associative.
    This follows from the associativity/commutativity of max and +
    together with the distributivity of + over max.
-/
theorem mul_assoc (M N P : TropMat) :
    mul (mul M N) P = mul M (mul N P) := by
  have h_def : ∀ (M N : TropMat) (p : ℝ × ℝ), actHom (mul M N) p = actHom M (actHom N p) := by
    grind +locals;
  unfold TropMat.mul at *;
  simp +decide [ TropMat.actHom ] at *;
  exact ⟨ h_def M N P.a P.c |>.1, h_def M N P.b P.d |>.1, h_def M N P.a P.c |>.2, h_def M N P.b P.d |>.2 ⟩

/-! ### Boundedness of affine evaluation -/

/-
**Upper Bound**: The affine evaluation is bounded above by max(a-c, b-d).
-/
theorem eval_le_max (M : TropMat) (t : ℝ) :
    M.eval t ≤ max (M.a - M.c) (M.b - M.d) := by
  unfold TropMat.eval;
  grind

/-
**Lower Bound**: The affine evaluation is bounded below by min(a-c, b-d).
-/
theorem min_le_eval (M : TropMat) (t : ℝ) :
    min (M.a - M.c) (M.b - M.d) ≤ M.eval t := by
  unfold TropMat.eval;
  cases max_cases ( M.a + t ) M.b <;> cases max_cases ( M.c + t ) M.d <;> cases min_cases ( M.a - M.c ) ( M.b - M.d ) <;> linarith

/-! ### Asymptotic behavior -/

/-
The affine evaluation equals a - c for sufficiently large t.
-/
theorem eval_of_large (M : TropMat) (t : ℝ) (ht1 : M.b - M.a ≤ t) (ht2 : M.d - M.c ≤ t) :
    M.eval t = M.a - M.c := by
  unfold TropMat.eval; rw [ max_eq_left, max_eq_left ] <;> linarith;

/-
The affine evaluation equals b - d for sufficiently small t.
-/
theorem eval_of_small (M : TropMat) (t : ℝ) (ht1 : t ≤ M.b - M.a) (ht2 : t ≤ M.d - M.c) :
    M.eval t = M.b - M.d := by
  unfold TropMat.eval;
  rw [ max_eq_right, max_eq_right ] <;> linarith

/-! ### Stereographic projection properties -/

/-
**Stereographic Linearity**: On the "equatorial band" [0, p] (when p ≥ 0),
    the tropical stereographic projection is the affine-linear map t ↦ t - p.
-/
theorem stereo_linear (p t : ℝ) (_hp : 0 ≤ p) (h0 : 0 ≤ t) (ht : t ≤ p) :
    (stereo p).eval t = t - p := by
  unfold stereo TropMat.eval; aesop;

/-- The stereographic projection has tropical determinant max(p, 0). -/
theorem stereo_tropDet (p : ℝ) : tropDet (stereo p) = max p 0 := by
  simp [tropDet, stereo]

/-
Non-degeneracy of stereographic projection when p ≠ 0.
-/
theorem stereo_nondeg (p : ℝ) (hp : p ≠ 0) : IsNondeg (stereo p) := by
  exact fun h => hp <| by have := h; unfold stereo at this; linarith;

/-! ### Piecewise linear structure -/

/-
**Active Interval Theorem**: When a + d > b + c (the "positive" non-degenerate case),
    on the interval [b - a, d - c] the tropical Möbius transformation equals the
    affine-linear map t ↦ a + t - d with slope +1.

    This is the region where both max expressions "switch" — outside this interval,
    the function is constant.
-/
theorem eval_active_interval (M : TropMat) (t : ℝ)
    (_hnd : M.a + M.d > M.b + M.c)
    (h1 : M.b - M.a ≤ t) (h2 : t ≤ M.d - M.c) :
    M.eval t = M.a + t - M.d := by
  unfold TropMat.eval;
  rw [ max_eq_left, max_eq_right ] <;> linarith

/-
**Injectivity on Active Interval**: The tropical Möbius transformation is
    injective when restricted to its active interval. This is the key bijectivity
    result that makes tropical stereographic projection a valid "coordinate chart".
-/
theorem eval_injective_on_active (M : TropMat) (s t : ℝ)
    (_hnd : M.a + M.d > M.b + M.c)
    (hs1 : M.b - M.a ≤ s) (hs2 : s ≤ M.d - M.c)
    (ht1 : M.b - M.a ≤ t) (ht2 : t ≤ M.d - M.c)
    (heq : M.eval s = M.eval t) : s = t := by
  unfold TropMat.eval at heq;
  grind

/-! ### Breakpoint theory -/

/-- The left breakpoint of a tropical Möbius transformation. -/
def leftBreak (M : TropMat) : ℝ := min (M.b - M.a) (M.d - M.c)

/-- The right breakpoint of a tropical Möbius transformation. -/
def rightBreak (M : TropMat) : ℝ := max (M.b - M.a) (M.d - M.c)

/-
Below the left breakpoint, the function is constant at b - d.
-/
theorem eval_below_leftBreak (M : TropMat) (t : ℝ) (ht : t ≤ M.leftBreak) :
    M.eval t = M.b - M.d := by
  unfold TropMat.eval TropMat.leftBreak at *;
  grind

/-
Above the right breakpoint, the function is constant at a - c.
-/
theorem eval_above_rightBreak (M : TropMat) (t : ℝ) (ht : M.rightBreak ≤ t) :
    M.eval t = M.a - M.c := by
  unfold TropMat.rightBreak at ht;
  convert TropMat.eval_of_large M t _ _ using 1 <;> aesop

/-! ### Tropical width and degree -/

/-- The "tropical width" of a Möbius transformation: the length of the
    interval on which it is non-constant. This measures the "tropical degree"
    of the transformation. -/
def tropWidth (M : TropMat) : ℝ := M.rightBreak - M.leftBreak

/-
The tropical width is non-negative.
-/
theorem tropWidth_nonneg (M : TropMat) : 0 ≤ M.tropWidth := by
  exact sub_nonneg_of_le ( min_le_max )

/-
**Width of Stereographic Projection**: The tropical width of the stereographic
    projection from pole p equals |p|.

    This confirms that the stereographic projection has "tropical degree" |p| —
    the tropical analog of the classical statement that stereographic projection
    is conformal with a specific magnification factor.
-/
theorem stereo_width (p : ℝ) : tropWidth (stereo p) = |p| := by
  unfold TropMat.tropWidth TropMat.rightBreak TropMat.leftBreak; norm_num [ stereo ] ;
  cases max_cases ( 0 : ℝ ) p <;> cases min_cases ( 0 : ℝ ) p <;> cases abs_cases p <;> linarith

/-! ### Tropical determinant inequality -/

/-
The tropical determinant satisfies a super-multiplicativity inequality:
    det⊕(M ⊗ N) ≥ det⊕(M) + det⊕(N).
    This is the tropical analog of |det(MN)| ≥ |det(M)| · |det(N)| ... wait,
    classically det(MN) = det(M)det(N), but tropically we only get an inequality
    because max-plus "loses information" compared to the ring structure.
-/
theorem tropDet_mul_le (M N : TropMat) :
    tropDet M + tropDet N ≤ tropDet (mul M N) := by
  unfold TropMat.tropDet TropMat.mul;
  grind

end TropMat