/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.

# Stereographic Persistence: Main Theorems

This file contains the main theorems of the stereographic persistence theory:

1. **Inner product formula** (`inner_stereoInvFun`): The inner product of two inverse
   stereographic images has a closed-form expression.

2. **Distance transport formula** (`stereoDist_eq`): The stereographic distance equals
   `arccos` of the closed-form inner product.

3. **Čech predicate equivalence** (`cech_simplex_stereoInvFun`): Čech simplex predicates
   are preserved exactly under inverse stereographic projection.

4. **Bi-Lipschitz bounds** (`stereoDist_biLipschitz_on_bounded`): On bounded subsets,
   the weighted distance is bi-Lipschitz equivalent to Euclidean distance.

## Proof strategy

**Strategy A (Direct metric identity → simplex predicate equivalence)**:
We prove the inner product formula by direct computation on `stereoInvFunAux`,
using properties of inner products in orthogonal complements. The Čech equivalence
follows by purely formal transport. Bi-Lipschitz bounds follow from bounding
the correction factor on compact sets, using the Jordan inequality and sin ≤ x.
-/

import Mathlib
import Geometry.StereographicPersistence.Defs

noncomputable section

open Real Metric Submodule Set Function

open scoped RealInnerProductSpace

open Classical in
attribute [local instance] propDecidable

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
variable {v : E} (hv : ‖v‖ = 1)

/-! ## Orthogonality lemmas -/

/-- `⟪w, v⟫ = 0` for `w` in the orthogonal complement of `v`. -/
theorem inner_orthogonal_eq_zero {v : E} (w : (ℝ ∙ v)ᗮ) :
    @inner ℝ E _ (w : E) v = 0 := by
  have := w.2
  rw [Submodule.mem_orthogonal_singleton_iff_inner_left] at this
  exact this

/-- `⟪v, w⟫ = 0` for `w` in the orthogonal complement of `v`. -/
theorem inner_orthogonal_eq_zero' {v : E} (w : (ℝ ∙ v)ᗮ) :
    @inner ℝ E _ v (w : E) = 0 := by
  rw [real_inner_comm]; exact inner_orthogonal_eq_zero w

omit [InnerProductSpace ℝ E] in
/-- Positivity of `‖w‖² + 4 > 0`. -/
theorem norm_sq_add_four_pos (w : E) : 0 < ‖w‖ ^ 2 + 4 := by positivity

omit [InnerProductSpace ℝ E] in
/-- `‖w‖² + 4 ≠ 0`. -/
theorem norm_sq_add_four_ne_zero (w : E) : ‖w‖ ^ 2 + 4 ≠ 0 := by positivity

/-! ## Inner product formula -/

/-- **Inner product formula for inverse stereographic images.**

For `w₁, w₂` in the orthogonal complement of a unit vector `v`:

  `⟪stereoInvFun(w₁), stereoInvFun(w₂)⟫ =
      1 - 8 * ‖w₁ - w₂‖² / ((‖w₁‖² + 4) * (‖w₂‖² + 4))`

This is the master formula from which all distance and filtration results follow. -/
theorem inner_stereoInvFun (w₁ w₂ : (ℝ ∙ v)ᗮ) :
    @inner ℝ E _ (stereoInvFun hv w₁ : E) (stereoInvFun hv w₂ : E) =
      1 - 8 * ‖(w₁ : E) - (w₂ : E)‖ ^ 2 /
        ((‖(w₁ : E)‖ ^ 2 + 4) * (‖(w₂ : E)‖ ^ 2 + 4)) := by
  simp +decide [inner_add_left, inner_add_right, inner_smul_left, inner_smul_right,
    inner_orthogonal_eq_zero, inner_orthogonal_eq_zero']
  rw [@norm_sub_sq ℝ]; norm_num [hv, inner_sub_left, inner_sub_right]; ring
  field_simp
  ring

/-! ## Main theorems -/

/-- **Theorem 1: Exact distance transport under stereographic projection.**

The stereographic distance equals `arccos` of the closed-form expression. -/
theorem stereoDist_eq (w₁ w₂ : (ℝ ∙ v)ᗮ) :
    stereoDist hv w₁ w₂ =
      Real.arccos (1 - 8 * ‖(w₁ : E) - (w₂ : E)‖ ^ 2 /
        ((‖(w₁ : E)‖ ^ 2 + 4) * (‖(w₂ : E)‖ ^ 2 + 4))) := by
  unfold stereoDist sphereDist
  congr 1
  exact inner_stereoInvFun hv w₁ w₂

/-- **Theorem 2: Čech simplex predicate equivalence via inverse stereographic.**

A finite set forms a weighted Čech simplex iff its inverse stereographic image
forms a spherical Čech simplex at the same scale. -/
theorem cech_simplex_stereoInvFun
    (σ : Finset ((ℝ ∙ v)ᗮ)) (ε : ℝ) :
    CechSimplexWeighted hv σ ε ↔
      CechSimplexSphere (σ.image (stereoInvFun hv)) ε := by
  unfold CechSimplexWeighted
  unfold CechSimplexSphere stereoDist
  grind

/-! ## Bi-Lipschitz bounds: helper lemmas -/

/-
The norm-squared difference of inverse stereographic images. From the inner product
formula: `‖stereoInvFun(w₁) - stereoInvFun(w₂)‖² = 16‖w₁-w₂‖²/((‖w₁‖²+4)(‖w₂‖²+4))`.
This is derived from `‖p-q‖² = 2(1-⟪p,q⟫)` for unit vectors.
-/
theorem norm_sub_stereoInvFun_sq (w₁ w₂ : (ℝ ∙ v)ᗮ) :
    ‖(stereoInvFun hv w₁ : E) - (stereoInvFun hv w₂ : E)‖ ^ 2 =
      16 * ‖(w₁ : E) - (w₂ : E)‖ ^ 2 /
        ((‖(w₁ : E)‖ ^ 2 + 4) * (‖(w₂ : E)‖ ^ 2 + 4)) := by
  convert congr_arg ( fun x : ℝ => 2 * ( 1 - x ) ) ( inner_stereoInvFun hv w₁ w₂ ) using 1;
  · rw [ @norm_sub_sq ℝ ];
    have h_norm_sq : ∀ w : ↥(ℝ ∙ v)ᗮ, ‖(stereoInvFun hv w : E)‖ ^ 2 = 1 := by
      intro w
      have h_norm_sq : ‖(stereoInvFun hv w : E)‖ = 1 := by
        convert mem_sphere_zero_iff_norm.mp ( stereoInvFun hv w |>.2 ) using 1
      rw [h_norm_sq]
      norm_num;
    rw [ h_norm_sq w₁, h_norm_sq w₂ ] ; ring;
    rfl;
  · ring

/-
For unit vectors `p, q` on the sphere, `‖p - q‖ ≤ sphereDist p q`.
This is the geometric fact that chord length ≤ arc length, equivalent to `sin x ≤ x`.
-/
theorem norm_sub_le_sphereDist (p q : sphere (0 : E) 1) :
    ‖(p : E) - (q : E)‖ ≤ sphereDist p q := by
  -- By definition of $sphereDist$, we have $sphereDist p q = \arccos(⟪p, q⟫)$.
  rw [show sphereDist p q = Real.arccos (@inner ℝ E _ (p : E) (q : E)) from rfl];
  -- Using the fact that $‖p - q‖ = 2 \sin(\theta / 2)$ and $\theta = \arccos(⟪p, q⟫)$, we get $‖p - q‖ = 2 \sin(\arccos(⟪p, q⟫) / 2)$.
  have h_norm_sin : ‖(p : E) - (q : E)‖ = 2 * Real.sin (Real.arccos (@inner ℝ E _ (p : E) (q : E)) / 2) := by
    have h_norm_sin : ‖(p : E) - q‖ ^ 2 = 4 * Real.sin (Real.arccos (@inner ℝ E _ (p : E) (q : E)) / 2) ^ 2 := by
      rw [ Real.sin_sq, Real.cos_sq ] ; ring;
      rw [ @norm_sub_sq ℝ ] ; norm_num [ real_inner_comm, real_inner_self_eq_norm_sq ] ; ring;
      rw [ Real.cos_arccos ];
      · exact neg_le_of_abs_le ( by simpa [ abs_mul, abs_of_nonneg ( norm_nonneg _ ) ] using abs_real_inner_le_norm ( p : E ) ( q : E ) );
      · exact le_of_abs_le ( by simpa [ mem_sphere_zero_iff_norm.mp p.2, mem_sphere_zero_iff_norm.mp q.2 ] using abs_real_inner_le_norm ( p : E ) ( q : E ) );
    rw [ ← sq_eq_sq₀ ] <;> first | positivity | linarith [ Real.sin_nonneg_of_nonneg_of_le_pi ( show 0 ≤ Real.arccos ⟪ ( p : E ), ( q : E ) ⟫ / 2 by exact div_nonneg ( Real.arccos_nonneg _ ) zero_le_two ) ( by linarith [ Real.pi_pos, Real.arccos_le_pi ⟪ ( p : E ), ( q : E ) ⟫ ] ) ] ;
  by_cases h : Real.arccos ⟪ ( p : E ), ( q : E ) ⟫ = 0 <;> simp_all +decide [ Real.sin_arccos ];
  · exact Real.arccos_nonneg _;
  · exact le_of_lt ( by have := Real.sin_lt ( show 0 < arccos ⟪ ( p : E ), ( q : E ) ⟫ / 2 from div_pos ( Real.arccos_pos.mpr h ) zero_lt_two ) ; linarith )

/-
For unit vectors, `sphereDist p q ≤ (π/2) * ‖p - q‖`.
This uses the Jordan inequality: `sin x ≥ 2x/π` for `x ∈ [0, π/2]`.
-/
theorem sphereDist_le_pi_div_two_mul_norm_sub (p q : sphere (0 : E) 1) :
    sphereDist p q ≤ (π / 2) * ‖(p : E) - (q : E)‖ := by
  -- By definition of $sphereDist$, we have $sphereDist p q = \arccos(⟪p, q⟫)$.
  have h_sphereDist_def : sphereDist p q = Real.arccos (inner ℝ (p : E) (q : E)) := by
    rfl;
  -- Let $\theta = \text{arccos}(\langle p, q \rangle)$. Then $\cos(\theta) = \langle p, q \rangle$ and $\sin(\theta/2) = \frac{\|p - q\|}{2}$.
  set θ := Real.arccos (inner ℝ (p : E) (q : E))
  have h_cos : Real.cos θ = inner ℝ (p : E) (q : E) := by
    rw [ Real.cos_arccos ];
    · exact ( abs_le.mp ( abs_real_inner_le_norm ( p : E ) ( q : E ) ) ) |>.1 |> le_trans ( by norm_num [ show ‖ ( p : E )‖ = 1 from by simp, show ‖ ( q : E )‖ = 1 from by simp ] );
    · exact le_of_abs_le ( by simpa [ mem_sphere_zero_iff_norm.mp p.2, mem_sphere_zero_iff_norm.mp q.2 ] using abs_real_inner_le_norm ( p : E ) ( q : E ) )
  have h_sin : Real.sin (θ / 2) = ‖(p : E) - (q : E)‖ / 2 := by
    have h_sin : ‖(p : E) - (q : E)‖ ^ 2 = 2 * (1 - Real.cos θ) := by
      rw [ @norm_sub_sq ℝ ] ; simp +decide [ *, real_inner_comm ] ; ring;
    rw [ ← sq_eq_sq₀ ];
    · rw [ Real.sin_sq, Real.cos_sq ] ; ring_nf at * ; linarith;
    · exact Real.sin_nonneg_of_nonneg_of_le_pi ( by linarith [ Real.pi_pos, Real.arccos_nonneg ⟪ ( p : E ), ( q : E ) ⟫ ] ) ( by linarith [ Real.pi_pos, Real.arccos_le_pi ⟪ ( p : E ), ( q : E ) ⟫ ] );
    · positivity;
  have h_jordan : θ / 2 ≤ Real.pi / 2 * Real.sin (θ / 2) := by
    have := Real.mul_le_sin ( show 0 ≤ θ / 2 by exact div_nonneg ( Real.arccos_nonneg _ ) zero_le_two ) ( show θ / 2 ≤ Real.pi / 2 by linarith [ Real.pi_pos, Real.arccos_le_pi ⟪ ( p : E ), ( q : E ) ⟫ ] );
    rw [ div_mul_eq_mul_div, div_le_iff₀ ] at this <;> linarith [ Real.pi_pos ];
  nlinarith [ Real.pi_pos ]

/-
**Theorem 3: Bi-Lipschitz equivalence on tame hemispheres.**

On a bounded region of stereographic coordinates, the weighted stereographic
distance is bi-Lipschitz equivalent to Euclidean distance with explicit constants.
C₁ = 4/(R²+4), C₂ = 2π.
-/
theorem stereoDist_biLipschitz_on_bounded {R : ℝ} (hR : 0 < R) :
    ∃ C₁ C₂ : ℝ, 0 < C₁ ∧ 0 < C₂ ∧
      ∀ (w₁ w₂ : (ℝ ∙ v)ᗮ),
        ‖(w₁ : E)‖ ≤ R → ‖(w₂ : E)‖ ≤ R →
          C₁ * ‖(w₁ : E) - (w₂ : E)‖ ≤ stereoDist hv w₁ w₂ ∧
          stereoDist hv w₁ w₂ ≤ C₂ * ‖(w₁ : E) - (w₂ : E)‖ := by
  refine' ⟨ 4 / ( R^2 + 4 ), Real.pi / 2, div_pos zero_lt_four ( by positivity ), by positivity, _ ⟩;
  intro w₁ w₂ hw₁ hw₂constructor;
  constructor;
  · refine' le_trans _ ( norm_sub_le_sphereDist _ _ );
    rw [ div_mul_eq_mul_div, div_le_iff₀ ];
    · have := norm_sub_stereoInvFun_sq hv w₁ w₂;
      rw [ eq_div_iff ( by positivity ) ] at this;
      nlinarith [ show 0 ≤ ‖ ( stereoInvFun hv w₁ : E ) - ( stereoInvFun hv w₂ : E )‖ * ( R ^ 2 + 4 ) by positivity, show 0 ≤ ‖ ( w₁ : E ) - ( w₂ : E )‖ by positivity, show ( ‖ ( w₁ : E )‖ ^ 2 + 4 ) * ( ‖ ( w₂ : E )‖ ^ 2 + 4 ) ≤ ( R ^ 2 + 4 ) ^ 2 by nlinarith [ show ‖ ( w₁ : E )‖ ^ 2 ≤ R ^ 2 by gcongr, show ‖ ( w₂ : E )‖ ^ 2 ≤ R ^ 2 by gcongr ] ];
    · positivity;
  · refine' le_trans ( sphereDist_le_pi_div_two_mul_norm_sub _ _ ) _;
    gcongr;
    have := norm_sub_stereoInvFun_sq hv w₁ w₂;
    rw [ ← Real.sqrt_sq ( norm_nonneg _ ), this ];
    rw [ Real.sqrt_le_left ] <;> try positivity;
    rw [ div_le_iff₀ ] <;> nlinarith only [ show 0 ≤ ‖ ( w₁ : E ) - w₂‖ ^ 2 by positivity, show ( ‖ ( w₁ : E )‖ ^ 2 + 4 ) * ( ‖ ( w₂ : E )‖ ^ 2 + 4 ) ≥ 16 by nlinarith only [ show 0 ≤ ‖ ( w₁ : E )‖ ^ 2 by positivity, show 0 ≤ ‖ ( w₂ : E )‖ ^ 2 by positivity ] ]

/-! ## Persistence module equivalence -/

/-- **Persistence equivalence**: The filtration of Čech simplex predicates is
preserved under stereographic transport. -/
theorem filtration_equivalence
    (σ : Finset ((ℝ ∙ v)ᗮ)) :
    ∀ ε : ℝ, 0 ≤ ε →
      (CechSimplexWeighted hv σ ε ↔
        CechSimplexSphere (σ.image (stereoInvFun hv)) ε) :=
  fun ε _ => cech_simplex_stereoInvFun hv σ ε

/-! ## Monotonicity of filtrations -/

theorem cechSphere_filtration_mono (σ : Finset (sphere (0 : E) 1)) {ε₁ ε₂ : ℝ}
    (hε : ε₁ ≤ ε₂) (h : CechSimplexSphere σ ε₁) : CechSimplexSphere σ ε₂ :=
  CechSimplexSphere_mono hε h

theorem cechWeighted_filtration_mono (σ : Finset ((ℝ ∙ v)ᗮ)) {ε₁ ε₂ : ℝ}
    (hε : ε₁ ≤ ε₂) (h : CechSimplexWeighted hv σ ε₁) : CechSimplexWeighted hv σ ε₂ :=
  CechSimplexWeighted_mono hε h

end