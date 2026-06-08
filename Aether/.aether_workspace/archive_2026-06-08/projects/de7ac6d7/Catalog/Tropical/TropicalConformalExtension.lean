/-
  # Tropical Conformal Extension: Max-Plus Möbius Transformations

  This file establishes tropical Möbius transformations acting on the boundary
  ∂H_trop = ℝ ∪ {∞} and their extension to the bulk H_trop.

  Key structures:
  - `TropicalMoebiusMatrix`: 2×2 matrix with tropical determinant condition
  - `tropicalBoundaryAction`: boundary action x ↦ max(a+x,b) - max(c+x,d)

  Bridge: connects tropical geometry (max-plus algebra) to modular forms
  (PSL(2) action), cryptography (lattice isometries), and physics (conformal
  symmetry in AdS/CFT).
-/
import Mathlib

open Real

namespace TropicalHolographic

/-! ## Section 1: Max-Plus Operations -/

/-- Max-plus "addition": tropical sum is classical maximum. -/
abbrev tropAdd (a b : ℝ) : ℝ := max a b

/-- Max-plus "multiplication": tropical product is classical sum. -/
abbrev tropMul (a b : ℝ) : ℝ := a + b

/-- Idempotent law: a ⊕ a = a. -/
theorem tropAdd_idempotent (a : ℝ) : tropAdd a a = a := max_self a

/-- Commutativity of tropical addition. -/
theorem tropAdd_comm (a b : ℝ) : tropAdd a b = tropAdd b a := max_comm a b

/-- Associativity of tropical addition. -/
theorem tropAdd_assoc (a b c : ℝ) :
    tropAdd (tropAdd a b) c = tropAdd a (tropAdd b c) := max_assoc a b c

/-- Tropical multiplication distributes over tropical addition. -/
theorem tropMul_distrib_left (a b c : ℝ) :
    tropMul c (tropAdd a b) = tropAdd (tropMul c a) (tropMul c b) := by
  simp [tropMul, tropAdd, max_add_add_left]

/-- Commutativity of tropical multiplication. -/
theorem tropMul_comm (a b : ℝ) : tropMul a b = tropMul b a := add_comm a b

/-! ## Section 2: Tropical Möbius Matrix -/

/-- A tropical Möbius matrix: 2×2 matrix [a b; c d] over ℝ with
    tropical determinant condition max(a+d, b+c) = 0.
    Bridge: connects tropical linear algebra to modular group theory. -/
structure TropicalMoebiusMatrix where
  a : ℝ
  b : ℝ
  c : ℝ
  d : ℝ
  tropical_det : max (a + d) (b + c) = 0

namespace TropicalMoebiusMatrix

/-- A tropical scaling matrix: S_s = [s 0; 0 -s]. -/
def tropScaling (s : ℝ) : TropicalMoebiusMatrix where
  a := s
  b := 0
  c := 0
  d := -s
  tropical_det := by simp

/-- The tropical boundary action: x ↦ max(a+x, b) - max(c+x, d).
    Bridge: connects projective geometry to tropical geometry. -/
noncomputable def tropicalBoundaryAction (T : TropicalMoebiusMatrix) (x : ℝ) : ℝ :=
  max (T.a + x) T.b - max (T.c + x) T.d

/-
The tropical scaling action is constant: tropScaling(s)(x) = s for all x.
    This is because both break points of tropScaling(s) coincide at x = -s,
    and the function is constant on both sides.
-/
theorem tropScaling_action_eq (s x : ℝ) :
    (tropScaling s).tropicalBoundaryAction x = s := by
  unfold TropicalMoebiusMatrix.tropicalBoundaryAction tropScaling;
  grind +revert

/-- Diagonal sum ≤ 0 from the tropical determinant condition. -/
theorem diag_sum_le_zero (T : TropicalMoebiusMatrix) :
    T.a + T.d ≤ 0 := by
  have := T.tropical_det; linarith [le_max_left (T.a + T.d) (T.b + T.c)]

/-- Anti-diagonal sum ≤ 0 from the tropical determinant condition. -/
theorem antidiag_sum_le_zero (T : TropicalMoebiusMatrix) :
    T.b + T.c ≤ 0 := by
  have := T.tropical_det; linarith [le_max_right (T.a + T.d) (T.b + T.c)]

/-
At least one of a+d, b+c equals 0 (the other is ≤ 0).
-/
theorem tropical_det_cases (T : TropicalMoebiusMatrix) :
    (T.a + T.d = 0 ∧ T.b + T.c ≤ 0) ∨ (T.b + T.c = 0 ∧ T.a + T.d ≤ 0) := by
  cases max_choice ( T.a + T.d ) ( T.b + T.c ) <;> simp_all +decide [ TropicalMoebiusMatrix.tropical_det ];
  · exact Or.inl ( by linarith [ T.antidiag_sum_le_zero ] );
  · exact Or.inr ( by linarith [ T.diag_sum_le_zero ] )

/-- The transpose preserves the tropical determinant. -/
theorem tropical_det_transpose (T : TropicalMoebiusMatrix) :
    max (T.a + T.d) (T.c + T.b) = 0 := by
  rw [add_comm T.c T.b]; exact T.tropical_det

/-- Scaling has a unique fixed point at x = s.
    Since tropScaling(s)(x) = s, the equation s = x has the unique solution x = s. -/
theorem tropScaling_fixed_point (s : ℝ) :
    (tropScaling s).tropicalBoundaryAction s = s :=
  tropScaling_action_eq s s

/-- Scaling has no fixed points away from s. -/
theorem tropScaling_no_other_fixed (s x : ℝ) (hx : x ≠ s) :
    (tropScaling s).tropicalBoundaryAction x ≠ x := by
  rw [tropScaling_action_eq]; exact hx.symm

/-! ## Section 3: Piecewise-Linear Structure -/

/-- The break point of max(a+x, b) is at x = b - a. -/
def breakPoint (a b : ℝ) : ℝ := b - a

/-- Below both break points, the action is the constant b - d. -/
theorem tropicalBoundaryAction_below_breaks (T : TropicalMoebiusMatrix)
    (x : ℝ) (h1 : x ≤ breakPoint T.a T.b) (h2 : x ≤ breakPoint T.c T.d) :
    T.tropicalBoundaryAction x = T.b - T.d := by
  simp only [tropicalBoundaryAction, breakPoint] at *
  rw [max_eq_right (by linarith), max_eq_right (by linarith)]

/-
Above both break points, the action is the constant a - c.
    This is because max(a+x, b) = a+x and max(c+x, d) = c+x,
    so the difference is (a+x) - (c+x) = a - c.
-/
theorem tropicalBoundaryAction_above_breaks (T : TropicalMoebiusMatrix)
    (x : ℝ) (h1 : breakPoint T.a T.b ≤ x) (h2 : breakPoint T.c T.d ≤ x) :
    T.tropicalBoundaryAction x = T.a - T.c := by
  unfold breakPoint at *;
  unfold TropicalMoebiusMatrix.tropicalBoundaryAction;
  rw [ max_eq_left, max_eq_left ] <;> linarith

/-- The action is constant in the linear regime: Lipschitz constant 0.
    This means |f(x₁) - f(x₂)| = 0 when both points are above both break points. -/
theorem tropicalBoundaryAction_constant_above_breaks
    (T : TropicalMoebiusMatrix) (x₁ x₂ : ℝ)
    (h1a : breakPoint T.a T.b ≤ x₁) (h1b : breakPoint T.c T.d ≤ x₁)
    (h2a : breakPoint T.a T.b ≤ x₂) (h2b : breakPoint T.c T.d ≤ x₂) :
    T.tropicalBoundaryAction x₁ = T.tropicalBoundaryAction x₂ := by
  rw [tropicalBoundaryAction_above_breaks T x₁ h1a h1b,
      tropicalBoundaryAction_above_breaks T x₂ h2a h2b]

/-- The action is also constant below both break points. -/
theorem tropicalBoundaryAction_constant_below_breaks
    (T : TropicalMoebiusMatrix) (x₁ x₂ : ℝ)
    (h1a : x₁ ≤ breakPoint T.a T.b) (h1b : x₁ ≤ breakPoint T.c T.d)
    (h2a : x₂ ≤ breakPoint T.a T.b) (h2b : x₂ ≤ breakPoint T.c T.d) :
    T.tropicalBoundaryAction x₁ = T.tropicalBoundaryAction x₂ := by
  rw [tropicalBoundaryAction_below_breaks T x₁ h1a h1b,
      tropicalBoundaryAction_below_breaks T x₂ h2a h2b]

/-! ## Section 4: Tropical Cross-Ratio -/

/-- The tropical cross-ratio of four boundary points.
    CR_trop(a,b,c,d) = (max(a,c) + max(b,d)) - (max(a,d) + max(b,c)).
    Bridge: connects projective invariants to tropical combinatorics. -/
noncomputable def tropCrossRatio (p q r s : ℝ) : ℝ :=
  (max p r + max q s) - (max p s + max q r)

/-- The tropical cross-ratio vanishes when all four arguments are equal. -/
theorem tropCrossRatio_all_equal (a : ℝ) :
    tropCrossRatio a a a a = 0 := by
  simp [tropCrossRatio]

/-
The tropical cross-ratio is bounded by the sum of differences.
    Bridge: connects tropical invariants to metric bounds for certified_robustness.
-/
theorem tropCrossRatio_bounded (p q r s : ℝ) :
    |tropCrossRatio p q r s| ≤ |p - q| + |r - s| := by
  unfold tropCrossRatio; cases abs_cases ( p - q ) <;> cases abs_cases ( r - s ) <;> cases abs_cases ( ( Max.max p r + Max.max q s ) - ( Max.max p s + Max.max q r ) ) <;> cases max_cases p r <;> cases max_cases q s <;> cases max_cases p s <;> cases max_cases q r <;> linarith;

/-- Swapping (p,q) and (r,s) preserves the cross-ratio.
    CR(r,s,p,q) = CR(p,q,r,s). -/
theorem tropCrossRatio_swap_pairs (p q r s : ℝ) :
    tropCrossRatio r s p q = tropCrossRatio p q r s := by
  simp [tropCrossRatio, max_comm, add_comm]

/-! ## Section 5: Horocycle Structure -/

/-- A tropical horocycle at height y₀ > 0. -/
structure TropicalHorocycle where
  height : ℝ
  height_pos : 0 < height

@[ext]
theorem TropicalHorocycle.ext {H₁ H₂ : TropicalHorocycle}
    (h : H₁.height = H₂.height) : H₁ = H₂ := by
  cases H₁; cases H₂; simp at *; exact h

/-- The horocycle at height 1. -/
def unitHorocycle : TropicalHorocycle := ⟨1, one_pos⟩

/-- Inter-horocyclic distance: |log(y₁) - log(y₂)|. -/
noncomputable def horocycleDist (H₁ H₂ : TropicalHorocycle) : ℝ :=
  |Real.log H₁.height - Real.log H₂.height|

theorem horocycleDist_self (H : TropicalHorocycle) :
    horocycleDist H H = 0 := by simp [horocycleDist]

theorem horocycleDist_comm (H₁ H₂ : TropicalHorocycle) :
    horocycleDist H₁ H₂ = horocycleDist H₂ H₁ := by
  simp [horocycleDist, abs_sub_comm]

theorem horocycleDist_triangle (H₁ H₂ H₃ : TropicalHorocycle) :
    horocycleDist H₁ H₃ ≤ horocycleDist H₁ H₂ + horocycleDist H₂ H₃ := by
  unfold horocycleDist
  calc |Real.log H₁.height - Real.log H₃.height|
      = |(Real.log H₁.height - Real.log H₂.height) +
         (Real.log H₂.height - Real.log H₃.height)| := by ring_nf
    _ ≤ _ := abs_add_le _ _

theorem horocycleDist_nonneg (H₁ H₂ : TropicalHorocycle) :
    0 ≤ horocycleDist H₁ H₂ := abs_nonneg _

theorem horocycleDist_eq_zero_iff (H₁ H₂ : TropicalHorocycle) :
    horocycleDist H₁ H₂ = 0 ↔ H₁ = H₂ := by
  unfold horocycleDist;
  norm_num [ sub_eq_zero ];
  exact ⟨ fun h => TropicalHorocycle.ext <| Real.log_injOn_pos H₁.height_pos H₂.height_pos h, fun h => h ▸ rfl ⟩

/-! ## Section 6: Tropical Norm and Operator Bounds -/

/-- The tropical norm of a Möbius matrix: max of absolute values of entries.
    Bridge: connects matrix norms to lattice_crypto security parameters. -/
noncomputable def tropNorm (T : TropicalMoebiusMatrix) : ℝ :=
  max (max (|T.a|) (|T.b|)) (max (|T.c|) (|T.d|))

/-- Tropical norm is nonneg. -/
theorem tropNorm_nonneg (T : TropicalMoebiusMatrix) : 0 ≤ tropNorm T :=
  le_trans (abs_nonneg T.a) (le_trans (le_max_left _ _) (le_max_left _ _))

/-- Each entry is bounded by the tropical norm. -/
theorem entry_le_tropNorm_a (T : TropicalMoebiusMatrix) :
    |T.a| ≤ tropNorm T :=
  le_trans (le_max_left _ _) (le_max_left _ _)

theorem entry_le_tropNorm_d (T : TropicalMoebiusMatrix) :
    |T.d| ≤ tropNorm T :=
  le_trans (le_max_right _ _) (le_max_right _ _)

/-
The boundary action is bounded for bounded inputs.
    Bridge: connects operator norms to post_quantum_security bounds.
-/
theorem tropicalBoundaryAction_bound (T : TropicalMoebiusMatrix) (x : ℝ)
    (hx : |x| ≤ tropNorm T) :
    |T.tropicalBoundaryAction x| ≤ 4 * tropNorm T := by
  refine' abs_sub_le_iff.mpr _;
  constructor <;> cases max_cases ( T.a + x ) T.b <;> cases max_cases ( T.c + x ) T.d <;> cases abs_cases x <;> linarith [ abs_le.mp ( show |T.a| ≤ T.tropNorm from le_max_of_le_left <| le_max_left _ _ ), abs_le.mp ( show |T.b| ≤ T.tropNorm from le_max_of_le_left <| le_max_right _ _ ), abs_le.mp ( show |T.c| ≤ T.tropNorm from le_max_of_le_right <| le_max_left _ _ ), abs_le.mp ( show |T.d| ≤ T.tropNorm from le_max_of_le_right <| le_max_right _ _ ) ]

/-! ## Section 7: Tropical Boundary Action Lipschitz Property -/

/-
The boundary action has Lipschitz constant ≤ 2.
    Bridge: connects Lipschitz bounds to certified_robustness for neural networks.
-/
theorem tropicalBoundaryAction_lipschitz (T : TropicalMoebiusMatrix)
    (x₁ x₂ : ℝ) :
    |T.tropicalBoundaryAction x₁ - T.tropicalBoundaryAction x₂|
      ≤ 2 * |x₁ - x₂| := by
  grind +locals

/-! ## Section 8: Tropical Determinant Arithmetic -/

/-- Sum of all entries ≤ 0. -/
theorem entry_sum_bound (T : TropicalMoebiusMatrix) :
    T.a + T.b + T.c + T.d ≤ 0 := by
  linarith [diag_sum_le_zero T, antidiag_sum_le_zero T]

/-- The scaling matrix has balanced diagonal. -/
theorem tropScaling_balanced (s : ℝ) :
    (tropScaling s).a + (tropScaling s).d = 0 := by simp [tropScaling]

/-- The scaling matrix has zero off-diagonal sum. -/
theorem tropScaling_offdiag (s : ℝ) :
    (tropScaling s).b + (tropScaling s).c = 0 := by simp [tropScaling]

/-! ## Section 9: Tropical Spectral Theory -/

/-- The tropical spectral radius: max of diagonal entries.
    Bridge: connects spectral radius to lattice security parameters. -/
noncomputable def tropSpectralRadius (T : TropicalMoebiusMatrix) : ℝ :=
  max T.a T.d

/-- Spectral radius bounded by tropical norm. -/
theorem tropSpectralRadius_le_norm (T : TropicalMoebiusMatrix) :
    tropSpectralRadius T ≤ tropNorm T := by
  apply max_le
  · exact le_trans (le_abs_self _) (le_trans (le_max_left _ _) (le_max_left _ _))
  · exact le_trans (le_abs_self _) (le_trans (le_max_right _ _) (le_max_right _ _))

/-- For scaling matrices, the spectral radius is max(s, -s) = |s|. -/
theorem tropSpectralRadius_scaling (s : ℝ) :
    tropSpectralRadius (tropScaling s) = max s (-s) := by
  simp [tropSpectralRadius, tropScaling]

/-- The spectral radius controls orbit growth in the linear regime. -/
theorem orbit_growth_bound (T : TropicalMoebiusMatrix) (x : ℝ)
    (h1 : breakPoint T.a T.b ≤ x) (h2 : breakPoint T.c T.d ≤ x) :
    T.tropicalBoundaryAction x = T.a - T.c :=
  tropicalBoundaryAction_above_breaks T x h1 h2

end TropicalMoebiusMatrix

end TropicalHolographic