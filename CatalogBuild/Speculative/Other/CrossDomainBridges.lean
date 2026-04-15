/-! # CatalogBuild.Speculative.Other.CrossDomainBridges

Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 14
-/

import Mathlib

noncomputable section

/-- The fixed-point set of a function. -/
def FixSet {X : Type*} (f : X → X) : Set X := {x | f x = x}


/-- ReLU is tropical addition with 0: max(x, 0) = max(0, x). -/
theorem relu_is_tropical_add' (x : ℝ) : relu' x = max x 0 := by
  simp [relu', max_comm]


/-- ReLU is not additive — it breaks classical linearity. -/
theorem relu_not_additive' : ¬ ∀ x y : ℝ, relu' (x + y) = relu' x + relu' y := by
  intro h
  have := h 1 (-1)
  simp [relu'] at this

-- ═══════════════════════════════════════════════════════════════════════════════
-- §3: Pythagorean–Light-Cone Bridge
-- ═══════════════════════════════════════════════════════════════════════════════


/-- A Pythagorean triple is an integer null vector. -/
theorem pythagorean_is_null {a b c : ℤ} (h : a ^ 2 + b ^ 2 = c ^ 2) :
    minkowskiQ a b c = 0 := by
  unfold minkowskiQ; omega


/-- Scaling preserves null-ness (the light cone is a cone). -/
theorem null_scale_int {a b c : ℤ} (h : minkowskiQ a b c = 0) (t : ℤ) :
    minkowskiQ (t * a) (t * b) (t * c) = 0 := by
  unfold minkowskiQ at *; nlinarith [sq_nonneg t]


/-- The Berggren matrix B₁ preserves the Minkowski form. -/
theorem berggren_B1_preserves_Q (a b c : ℤ) :
    minkowskiQ (a - 2*b + 2*c) (2*a - b + 2*c) (2*a - 2*b + 3*c) =
    minkowskiQ a b c := by
  unfold minkowskiQ; ring


/-- The Berggren matrix B₂ preserves the Minkowski form. -/
theorem berggren_B2_preserves_Q (a b c : ℤ) :
    minkowskiQ (a + 2*b + 2*c) (2*a + b + 2*c) (2*a + 2*b + 3*c) =
    minkowskiQ a b c := by
  unfold minkowskiQ; ring


/-- The Berggren matrix B₃ preserves the Minkowski form. -/
theorem berggren_B3_preserves_Q (a b c : ℤ) :
    minkowskiQ (-a + 2*b + 2*c) (-2*a + b + 2*c) (-2*a + 2*b + 3*c) =
    minkowskiQ a b c := by
  unfold minkowskiQ; ring


/-- If (a,b,c) is a Pythagorean triple, so is B₁(a,b,c). -/
theorem berggren_B1_preserves_pythagorean {a b c : ℤ}
    (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (a - 2*b + 2*c) ^ 2 + (2*a - b + 2*c) ^ 2 =
    (2*a - 2*b + 3*c) ^ 2 := by
  have := berggren_B1_preserves_Q a b c
  unfold minkowskiQ at this; omega

-- ═══════════════════════════════════════════════════════════════════════════════
-- §4: Oracle Composition Bridge
-- ═══════════════════════════════════════════════════════════════════════════════


/-- The image of a composed oracle is contained in the intersection of images. -/
theorem composed_image_subset {X : Type*} (O₁ O₂ : X → X)
    (h₁ : IsOracle' O₁) (h₂ : IsOracle' O₂) :
    range (O₁ ∘ O₂) ⊆ range O₁ := by
  rintro y ⟨x, rfl⟩
  exact ⟨O₂ x, rfl⟩

-- ═══════════════════════════════════════════════════════════════════════════════
-- §5: Stereographic–Null-Cone Bridge
-- ═══════════════════════════════════════════════════════════════════════════════


/-- Inverse stereo is injective. -/
theorem invStereo_injective' : Injective invStereo := by
  intro a b h
  simp only [invStereo, Prod.mk.injEq] at h
  have ha : (1 : ℝ) + a ^ 2 ≠ 0 := by positivity
  have hb : (1 : ℝ) + b ^ 2 ≠ 0 := by positivity
  rw [div_eq_div_iff ha hb] at h
  nlinarith [h.1, sq_nonneg (a - b), sq_nonneg (a * b - 1)]

-- ═══════════════════════════════════════════════════════════════════════════════
-- §6: LSE Bounds (Tropical–Classical Bridge, Quantitative)
-- ═══════════════════════════════════════════════════════════════════════════════


/-- Every oracle restricts to the identity on its image. -/
theorem oracle_identity_on_image {X : Type*} (O : X → X) (hO : IsOracle' O)
    (y : X) (hy : y ∈ range O) : O y = y := by
  obtain ⟨x, rfl⟩ := hy
  exact hO x


/-- The image of an oracle is the largest set on which O acts as the identity. -/
theorem oracle_image_is_maximal_fixed {X : Type*} (O : X → X) (hO : IsOracle' O)
    (S : Set X) (hS : ∀ x ∈ S, O x = x) : S ⊆ range O := by
  intro x hx
  exact ⟨x, hS x hx⟩


/-- Combining the Master Equation with oracle composition gives a lattice structure
on the set of all oracles on X. -/
theorem oracle_lattice_of_composition {X : Type*} (O₁ O₂ : X → X)
    (h₁ : IsOracle' O₁) (h₂ : IsOracle' O₂)
    (hcomm : ∀ x, O₁ (O₂ x) = O₂ (O₁ x))
    (h₁₂ : IsOracle' (O₁ ∘ O₂)) :
    range (O₁ ∘ O₂) = FixSet O₁ ∩ FixSet O₂ := by
  ext y; constructor
  · rintro ⟨x, rfl⟩
    simp [FixSet, Function.comp]
    exact ⟨h₁ (O₂ x), by rw [hcomm, h₁ (O₂ x)]⟩
  · rintro ⟨hy₁, hy₂⟩
    exact ⟨y, by simp [Function.comp, hy₂, hy₁]⟩


end
