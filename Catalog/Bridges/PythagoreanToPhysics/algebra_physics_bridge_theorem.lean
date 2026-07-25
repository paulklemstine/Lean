import Mathlib

/-!
# Berggren–Lorentz Cross-Ratio Invariance

This module establishes that the three Berggren matrices — which generate all
primitive Pythagorean triples via a ternary tree — preserve the projective
cross ratio on the (2+1)-dimensional Minkowski null cone.

## Mathematical Background

The **Berggren tree** is a ternary tree rooted at (3, 4, 5) that generates every
primitive Pythagorean triple exactly once, using three integer matrices U, A, D
acting on column vectors (a, b, c) with a² + b² = c².

These matrices lie in SO⁺(2, 1), the connected component of the indefinite
orthogonal group preserving the Lorentzian form x₀² + x₁² − x₂² = 0. Via the
classical isomorphism SO⁺(2, 1) ≅ PSL(2, ℝ), each matrix induces a Möbius
(fractional linear) transformation on the stereographic parameter of the null cone.

## Stereographic Projection

The correct stereographic projection from the null cone {v | v₀² + v₁² = v₂²}
is the map

    π(v) = v₁ / (v₂ − v₀)

which projects from the "pole" (1, 0, 1) on the projective conic to the affine
line. For a Pythagorean triple (a, b, c) parameterized as a = m² − n², b = 2mn,
c = m² + n², this gives π(a, b, c) = 2mn / (2n²) = m/n, recovering the classical
generator ratio.

## Main Results

* `cross_ratio_mobius_invariant`: Möbius transformations preserve the cross ratio.
* `berggren_cone_preserve_U/A/D`: Each Berggren matrix preserves the null cone.
* `stereoProj_berggren_U/A/D`: Each matrix induces a specific Möbius transformation
  on the stereographic parameter.
* `berggren_lorentz_cross_ratio_invariant`: **The main theorem** — the cross ratio
  of stereographic parameters is invariant under any Berggren generator.
-/

noncomputable section

open Matrix

/-! ## Basic Definitions -/

/-- Cross ratio of four real numbers: CR(a,b,c,d) = (a−c)(b−d) / ((a−d)(b−c)).
This is the fundamental projective invariant of four collinear points. -/
def cross_ratio (a b c d : ℝ) : ℝ :=
  (a - c) * (b - d) / ((a - d) * (b - c))

/-- Stereographic projection from the null cone v₀² + v₁² = v₂² to the projective
line, mapping v ↦ v₁/(v₂ − v₀). This projects from the pole (1, 0, 1) on the
conic. For a Pythagorean triple (a, b, c) = (m²−n², 2mn, m²+n²), this gives
the classical generator ratio m/n. -/
def stereoProj (v : Fin 3 → ℝ) : ℝ :=
  v 1 / (v 2 - v 0)

/-! ## Berggren Matrices

The three generators of the Berggren tree, acting on (a, b, c) where a² + b² = c².
These are elements of SO⁺(2, 1) preserving the Lorentzian form x₀² + x₁² − x₂². -/

/-- Berggren matrix U: generates the "upward" branch.
Induces t ↦ (2t − 1)/t on the stereographic line. -/
def BerggrenU : Matrix (Fin 3) (Fin 3) ℝ :=
  !![1, -2, 2; 2, -1, 2; 2, -2, 3]

/-- Berggren matrix A: generates the "across" branch.
Induces t ↦ (2t + 1)/t on the stereographic line. -/
def BerggrenA : Matrix (Fin 3) (Fin 3) ℝ :=
  !![1, 2, 2; 2, 1, 2; 2, 2, 3]

/-- Berggren matrix D: generates the "downward" branch.
Induces t ↦ t + 2 on the stereographic line. -/
def BerggrenD : Matrix (Fin 3) (Fin 3) ℝ :=
  !![-1, 2, 2; -2, 1, 2; -2, 2, 3]

/-- The set of three Berggren generators in Lorentz form. -/
def BerggrenLorentzTransforms : Set (Matrix (Fin 3) (Fin 3) ℝ) :=
  {BerggrenU, BerggrenA, BerggrenD}

/-! ## Matrix-Vector Multiplication Lemmas -/

@[simp] lemma berggrenU_mulVec_0 (v : Fin 3 → ℝ) :
    (BerggrenU *ᵥ v) 0 = v 0 - 2 * v 1 + 2 * v 2 := by
  simp [BerggrenU, mulVec, dotProduct, Fin.sum_univ_three, mul_comm]; try ring

@[simp] lemma berggrenU_mulVec_1 (v : Fin 3 → ℝ) :
    (BerggrenU *ᵥ v) 1 = 2 * v 0 - v 1 + 2 * v 2 := by
  simp [BerggrenU, mulVec, dotProduct, Fin.sum_univ_three, mul_comm]; try ring

@[simp] lemma berggrenU_mulVec_2 (v : Fin 3 → ℝ) :
    (BerggrenU *ᵥ v) 2 = 2 * v 0 - 2 * v 1 + 3 * v 2 := by
  simp [BerggrenU, mulVec, dotProduct, Fin.sum_univ_three, mul_comm]; try ring

@[simp] lemma berggrenA_mulVec_0 (v : Fin 3 → ℝ) :
    (BerggrenA *ᵥ v) 0 = v 0 + 2 * v 1 + 2 * v 2 := by
  simp [BerggrenA, mulVec, dotProduct, Fin.sum_univ_three, mul_comm]; try ring

@[simp] lemma berggrenA_mulVec_1 (v : Fin 3 → ℝ) :
    (BerggrenA *ᵥ v) 1 = 2 * v 0 + v 1 + 2 * v 2 := by
  simp [BerggrenA, mulVec, dotProduct, Fin.sum_univ_three, mul_comm]; try ring

@[simp] lemma berggrenA_mulVec_2 (v : Fin 3 → ℝ) :
    (BerggrenA *ᵥ v) 2 = 2 * v 0 + 2 * v 1 + 3 * v 2 := by
  simp [BerggrenA, mulVec, dotProduct, Fin.sum_univ_three, mul_comm]; try ring

@[simp] lemma berggrenD_mulVec_0 (v : Fin 3 → ℝ) :
    (BerggrenD *ᵥ v) 0 = -(v 0) + 2 * v 1 + 2 * v 2 := by
  simp [BerggrenD, mulVec, dotProduct, Fin.sum_univ_three, mul_comm]; try ring

@[simp] lemma berggrenD_mulVec_1 (v : Fin 3 → ℝ) :
    (BerggrenD *ᵥ v) 1 = -(2 * v 0) + v 1 + 2 * v 2 := by
  simp [BerggrenD, mulVec, dotProduct, Fin.sum_univ_three, mul_comm]; try ring

@[simp] lemma berggrenD_mulVec_2 (v : Fin 3 → ℝ) :
    (BerggrenD *ᵥ v) 2 = -(2 * v 0) + 2 * v 1 + 3 * v 2 := by
  simp [BerggrenD, mulVec, dotProduct, Fin.sum_univ_three, mul_comm]; try ring

/-! ## Null Cone Preservation -/

theorem berggren_cone_preserve_U (v : Fin 3 → ℝ)
    (hv : v 0 ^ 2 + v 1 ^ 2 = v 2 ^ 2) :
    (BerggrenU *ᵥ v) 0 ^ 2 + (BerggrenU *ᵥ v) 1 ^ 2 = (BerggrenU *ᵥ v) 2 ^ 2 := by
  simp only [berggrenU_mulVec_0, berggrenU_mulVec_1, berggrenU_mulVec_2]; nlinarith

theorem berggren_cone_preserve_A (v : Fin 3 → ℝ)
    (hv : v 0 ^ 2 + v 1 ^ 2 = v 2 ^ 2) :
    (BerggrenA *ᵥ v) 0 ^ 2 + (BerggrenA *ᵥ v) 1 ^ 2 = (BerggrenA *ᵥ v) 2 ^ 2 := by
  simp only [berggrenA_mulVec_0, berggrenA_mulVec_1, berggrenA_mulVec_2]; nlinarith

theorem berggren_cone_preserve_D (v : Fin 3 → ℝ)
    (hv : v 0 ^ 2 + v 1 ^ 2 = v 2 ^ 2) :
    (BerggrenD *ᵥ v) 0 ^ 2 + (BerggrenD *ᵥ v) 1 ^ 2 = (BerggrenD *ᵥ v) 2 ^ 2 := by
  simp only [berggrenD_mulVec_0, berggrenD_mulVec_1, berggrenD_mulVec_2]; nlinarith

/-! ## Cross Ratio: Möbius Invariance -/

/-
The difference of two Möbius-transformed values factors through the determinant.
-/
lemma mobius_diff (a b c d x y : ℝ) (hx : c * x + d ≠ 0) (hy : c * y + d ≠ 0) :
    (a * x + b) / (c * x + d) - (a * y + b) / (c * y + d) =
    (a * d - b * c) * (x - y) / ((c * x + d) * (c * y + d)) := by
  grind

/-
**Möbius invariance of the cross ratio.**
-/
theorem cross_ratio_mobius_invariant (α β γ δ a b c d : ℝ)
    (hdet : α * δ - β * γ ≠ 0)
    (ha : γ * a + δ ≠ 0) (hb : γ * b + δ ≠ 0)
    (hc : γ * c + δ ≠ 0) (hd : γ * d + δ ≠ 0)
    (_had : a ≠ d) (_hbc : b ≠ c) :
    cross_ratio ((α * a + β) / (γ * a + δ)) ((α * b + β) / (γ * b + δ))
               ((α * c + β) / (γ * c + δ)) ((α * d + β) / (γ * d + δ)) =
    cross_ratio a b c d := by
  unfold cross_ratio;
  rw [ mobius_diff _ _ _ _ _ _ ha hc, mobius_diff _ _ _ _ _ _ hb hd, mobius_diff _ _ _ _ _ _ ha hd, mobius_diff _ _ _ _ _ _ hb hc ];
  field_simp

/-! ## Stereographic Projection and Möbius Structure -/

/-
Matrix U induces the Möbius transformation t ↦ (2t − 1)/t.
-/
theorem stereoProj_berggren_U (v : Fin 3 → ℝ)
    (hcone : v 0 ^ 2 + v 1 ^ 2 = v 2 ^ 2)
    (h1 : v 2 - v 0 ≠ 0) (h2 : v 0 + v 2 ≠ 0) (h3 : v 1 ≠ 0) :
    stereoProj (BerggrenU *ᵥ v) =
    (2 * stereoProj v + (-1)) / (1 * stereoProj v + 0) := by
  unfold stereoProj;
  simp_all +decide;
  grind

/-
Matrix A induces the Möbius transformation t ↦ (2t + 1)/t.
-/
theorem stereoProj_berggren_A (v : Fin 3 → ℝ)
    (hcone : v 0 ^ 2 + v 1 ^ 2 = v 2 ^ 2)
    (h1 : v 2 - v 0 ≠ 0) (h2 : v 0 + v 2 ≠ 0) (h3 : v 1 ≠ 0) :
    stereoProj (BerggrenA *ᵥ v) =
    (2 * stereoProj v + 1) / (1 * stereoProj v + 0) := by
  unfold stereoProj;
  simp +zetaDelta at *;
  grind

/-
Matrix D induces the Möbius transformation t ↦ t + 2.
-/
theorem stereoProj_berggren_D (v : Fin 3 → ℝ)
    (_hcone : v 0 ^ 2 + v 1 ^ 2 = v 2 ^ 2)
    (h1 : v 2 - v 0 ≠ 0) :
    stereoProj (BerggrenD *ᵥ v) =
    (1 * stereoProj v + 2) / (0 * stereoProj v + 1) := by
  unfold stereoProj;
  simp +zetaDelta at *;
  rw [ div_add', div_eq_div_iff ] <;> cases lt_or_gt_of_ne h1 <;> nlinarith

/-! ## The Main Theorem -/

/-
**Berggren–Lorentz cross-ratio invariance.**

For any Berggren generator B ∈ {U, A, D} and any four forward null vectors
on the cone v₀² + v₁² = v₂² with well-defined stereographic projections,
the cross ratio of their stereographic parameters is invariant under B:

    CR(π(v₁), π(v₂), π(v₃), π(v₄)) = CR(π(B·v₁), π(B·v₂), π(B·v₃), π(B·v₄))

This establishes that the discrete monoid of Berggren matrices acts by conformal
symmetries on the projective line of the null cone, providing a rigorous
bridge between the combinatorial tree of Pythagorean triples and the continuous
Lorentz group SO⁺(2,1).
-/
theorem berggren_lorentz_cross_ratio_invariant
    (B : Matrix (Fin 3) (Fin 3) ℝ)
    (hB : B ∈ BerggrenLorentzTransforms)
    (v₁ v₂ v₃ v₄ : Fin 3 → ℝ)
    (hv₁ : v₁ 0 ^ 2 + v₁ 1 ^ 2 = v₁ 2 ^ 2)
    (hv₂ : v₂ 0 ^ 2 + v₂ 1 ^ 2 = v₂ 2 ^ 2)
    (hv₃ : v₃ 0 ^ 2 + v₃ 1 ^ 2 = v₃ 2 ^ 2)
    (hv₄ : v₄ 0 ^ 2 + v₄ 1 ^ 2 = v₄ 2 ^ 2)
    (hne₁ : v₁ 2 - v₁ 0 ≠ 0) (hne₂ : v₂ 2 - v₂ 0 ≠ 0)
    (hne₃ : v₃ 2 - v₃ 0 ≠ 0) (hne₄ : v₄ 2 - v₄ 0 ≠ 0)
    (hne₁' : (B *ᵥ v₁) 2 - (B *ᵥ v₁) 0 ≠ 0)
    (hne₂' : (B *ᵥ v₂) 2 - (B *ᵥ v₂) 0 ≠ 0)
    (hne₃' : (B *ᵥ v₃) 2 - (B *ᵥ v₃) 0 ≠ 0)
    (hne₄' : (B *ᵥ v₄) 2 - (B *ᵥ v₄) 0 ≠ 0)
    (ht₁ : v₁ 1 ≠ 0) (ht₂ : v₂ 1 ≠ 0) (ht₃ : v₃ 1 ≠ 0) (ht₄ : v₄ 1 ≠ 0)
    (h₁₄ : stereoProj v₁ ≠ stereoProj v₄)
    (h₂₃ : stereoProj v₂ ≠ stereoProj v₃) :
    cross_ratio (stereoProj v₁) (stereoProj v₂) (stereoProj v₃) (stereoProj v₄) =
    cross_ratio (stereoProj (B *ᵥ v₁)) (stereoProj (B *ᵥ v₂))
                (stereoProj (B *ᵥ v₃)) (stereoProj (B *ᵥ v₄)) := by
  cases' hB with hB hB;
  · rw [ hB ];
    rw [ stereoProj_berggren_U, stereoProj_berggren_U, stereoProj_berggren_U, stereoProj_berggren_U ] <;> try assumption;
    · rw [ cross_ratio_mobius_invariant ];
      all_goals norm_num;
      all_goals unfold stereoProj; aesop;
    · grind;
    · grobner;
    · grind;
    · grind;
  · rcases hB with ( rfl | rfl );
    · -- Apply the stereoProj_berggren_A theorem to each of the four vectors.
      have hA₁ := stereoProj_berggren_A v₁ hv₁ hne₁ (by
      grind) ht₁
      have hA₂ := stereoProj_berggren_A v₂ hv₂ hne₂ (by
      grind +splitIndPred) ht₂
      have hA₃ := stereoProj_berggren_A v₃ hv₃ hne₃ (by
      grind) ht₃
      have hA₄ := stereoProj_berggren_A v₄ hv₄ hne₄ (by
      grind) ht₄;
      convert cross_ratio_mobius_invariant 2 1 1 0 ( stereoProj v₁ ) ( stereoProj v₂ ) ( stereoProj v₃ ) ( stereoProj v₄ ) _ _ _ _ _ _ using 1 <;> norm_num;
      all_goals simp_all +decide [ stereoProj ];
      exact eq_comm;
    · simp_all +decide [ cross_ratio, stereoProj_berggren_D ]

end