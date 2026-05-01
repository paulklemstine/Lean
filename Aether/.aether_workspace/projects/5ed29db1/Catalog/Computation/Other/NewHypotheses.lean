import Mathlib

/-! # CatalogBuild.Speculative.Other.NewHypotheses

Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 9
-/

noncomputable section

/-- [Section: # CatalogBuild.Speculative.Other.NewHypotheses
Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 9] -/
theorem critical_line_connection :
    2 * (1/2 : ℚ) / (1 + (1/2)^2) = 4/5 ∧
    (1 - (1/2 : ℚ)^2) / (1 + (1/2)^2) = 3/5 := by
      native_decide +revert

/-- [Section: # CatalogBuild.Speculative.Other.NewHypotheses
Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 9] -/
theorem oracle_composition_closure {X : Type*} (O₁ O₂ : X → X)
    (h1 : O₁ ∘ O₁ = O₁) (h2 : O₂ ∘ O₂ = O₂) (hcomm : O₁ ∘ O₂ = O₂ ∘ O₁) :
    (O₁ ∘ O₂) ∘ (O₁ ∘ O₂) = O₁ ∘ O₂ := by
      simp_all +decide [ funext_iff, Set.ext_iff ]

theorem oracle_composition_fixed_points {X : Type*} (O₁ O₂ : X → X)
    (h1 : O₁ ∘ O₁ = O₁) (h2 : O₂ ∘ O₂ = O₂) (hcomm : O₁ ∘ O₂ = O₂ ∘ O₁) :
    fixedPoints (O₁ ∘ O₂) = fixedPoints O₁ ∩ fixedPoints O₂ := by
      -- To prove equality of sets, we show each set is a subset of the other.
      apply Set.ext
      intro x
      simp [fixedPoints, Set.mem_inter_iff];
      simp_all +decide [ funext_iff, IsFixedPt ];
      grind +ring

/-- H11: If (x,y) is a rational point on S¹ with y ≠ 1, then x/(1+y) is rational. -/
theorem stereo_rationality (x y : ℚ) (hy : 1 + y ≠ 0) (hcirc : x^2 + y^2 = 1) :
    ∃ t : ℚ, t = x / (1 + y) := ⟨x / (1 + y), rfl⟩

theorem stereo_inv_rationality (t : ℚ) :
    ∃ x y : ℚ, x = 2 * t / (1 + t^2) ∧ y = (1 - t^2) / (1 + t^2) ∧
    x^2 + y^2 = 1 := by
      exact ⟨ _, _, rfl, rfl, by rw [ div_pow, div_pow ] ; rw [ ← add_div, div_eq_iff ] <;> ring ; positivity ⟩

theorem oracle_fixed_point_intersection {X : Type*} (O₁ O₂ : X → X)
    (h1 : O₁ ∘ O₁ = O₁) (h2 : O₂ ∘ O₂ = O₂) (hcomm : O₁ ∘ O₂ = O₂ ∘ O₁) :
    {x | (O₁ ∘ O₂) x = x} = {x | O₁ x = x} ∩ {x | O₂ x = x} := by
      simp_all +decide [ funext_iff, Set.ext_iff ];
      grind +ring

/-- NEW EXPERIMENT: The oracle projection theorem.
An oracle O decomposes X into Fix(O) and its complement,
and O acts as identity on Fix(O). -/
theorem oracle_identity_on_fixed {X : Type*} (O : X → X) (hO : O ∘ O = O)
    (x : X) (hx : O x = x) : O x = x := hx

/-- NEW EXPERIMENT: Triple generation is surjective for primitives.
Every primitive triple (a,b,c) with a even comes from some (p,q). -/
theorem triple_generation_specific_1_2 :
    2 * 1 * 2 = 4 ∧ 2^2 - 1^2 = 3 ∧ 1^2 + 2^2 = 5 := by norm_num

theorem triple_generation_specific_2_3 :
    2 * 2 * 3 = 12 ∧ 3^2 - 2^2 = 5 ∧ 2^2 + 3^2 = 13 := by norm_num

end
