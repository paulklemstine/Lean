/-! # CatalogBuild.Bridges.PythagoreanToPhysics.algebra_physics_bridge_theorem

Auto-generated from theorem catalog database.
Domain: Bridges/PythagoreanToPhysics
Declarations: 13
-/

import Mathlib

noncomputable section

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


/-- [Section: ## Null Cone Preservation] -/
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


/-- [Section: ## Cross Ratio: Möbius Invariance] -/
lemma mobius_diff (a b c d x y : ℝ) (hx : c * x + d ≠ 0) (hy : c * y + d ≠ 0) :
    (a * x + b) / (c * x + d) - (a * y + b) / (c * y + d) =
    (a * d - b * c) * (x - y) / ((c * x + d) * (c * y + d)) := by
  grind


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


/-- [Section: ## Stereographic Projection and Möbius Structure] -/
theorem stereoProj_berggren_U (v : Fin 3 → ℝ)
    (hcone : v 0 ^ 2 + v 1 ^ 2 = v 2 ^ 2)
    (h1 : v 2 - v 0 ≠ 0) (h2 : v 0 + v 2 ≠ 0) (h3 : v 1 ≠ 0) :
    stereoProj (BerggrenU *ᵥ v) =
    (2 * stereoProj v + (-1)) / (1 * stereoProj v + 0) := by
  unfold stereoProj;
  simp_all +decide;
  grind


theorem stereoProj_berggren_A (v : Fin 3 → ℝ)
    (hcone : v 0 ^ 2 + v 1 ^ 2 = v 2 ^ 2)
    (h1 : v 2 - v 0 ≠ 0) (h2 : v 0 + v 2 ≠ 0) (h3 : v 1 ≠ 0) :
    stereoProj (BerggrenA *ᵥ v) =
    (2 * stereoProj v + 1) / (1 * stereoProj v + 0) := by
  unfold stereoProj;
  simp +zetaDelta at *;
  grind


theorem stereoProj_berggren_D (v : Fin 3 → ℝ)
    (_hcone : v 0 ^ 2 + v 1 ^ 2 = v 2 ^ 2)
    (h1 : v 2 - v 0 ≠ 0) :
    stereoProj (BerggrenD *ᵥ v) =
    (1 * stereoProj v + 2) / (0 * stereoProj v + 1) := by
  unfold stereoProj;
  simp +zetaDelta at *;
  rw [ div_add', div_eq_div_iff ] <;> cases lt_or_gt_of_ne h1 <;> nlinarith


/-- [Section: ## The Main Theorem] -/
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
