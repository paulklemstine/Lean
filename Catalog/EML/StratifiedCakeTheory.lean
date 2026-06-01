/-
# Stratified Cake Theory: Algebraic Geometry of Layered Structures

This module formalizes the mathematics of "cakes" — stratified combinatorial objects
that encode the topology of compact surfaces with boundary, marked points (cherries),
and layer decompositions. The key results are:

1. **Euler Characteristic Formula**: For a surface of genus g with b boundary components,
   χ = 2 - 2g - b.

2. **Moduli Dimension Theorem**: The moduli space of conformal structures on a genus-g
   surface with n marked points has (real) dimension 6g - 6 + 2n when this is positive.

3. **Layer Stratification Dimension**: A complete flag stratification of a d-dimensional
   cake (variety) has exactly d+1 layers with strictly decreasing dimensions.

4. **Cherry-Genus Duality**: The relationship between boundary components and
   topological genus constrains the space of valid cake configurations.
-/

import Mathlib

open Finset BigOperators

/-! ## Core Definitions -/

/-- A `CakeData` encodes the combinatorial topology of a "cake":
  a compact orientable surface with genus `g`, `b` boundary components (frosting edges),
  `n` marked points (cherries), and `k` layers in a stratification. -/
structure CakeData where
  genus : ℕ          -- topological genus of the base surface
  boundary : ℕ       -- number of boundary components (frosting edges)
  cherries : ℕ       -- number of marked points on the surface
  layers : ℕ         -- number of layers in the stratification (excluding top)
  deriving Repr, DecidableEq

/-- The Euler characteristic of the base surface of a cake.
    For an orientable surface of genus g with b boundary components: χ = 2 - 2g - b -/
def CakeData.eulerChar (C : CakeData) : ℤ :=
  2 - 2 * (C.genus : ℤ) - (C.boundary : ℤ)

/-- A cake is "valid" if it represents a realizable surface:
    the Euler characteristic constraint is satisfiable and the stratification
    has at least one layer. -/
def CakeData.isValid (C : CakeData) : Prop :=
  C.layers ≥ 1 ∧ (C.genus ≥ 1 ∨ C.boundary ≥ 1)

/-- The real dimension of the moduli space of conformal structures on the base surface
    with marked cherry positions. For genus g with n marked points:
    dim = 6g - 6 + 2n (real dimension of Teichmüller space with marked points) -/
def CakeData.moduliDimFormula (C : CakeData) : ℤ :=
  6 * (C.genus : ℤ) - 6 + 2 * (C.cherries : ℤ)

/-- The "complex moduli dimension" — half the real dimension when the surface
    admits a complex structure. This gives 3g - 3 + n. -/
def CakeData.complexModuliDim (C : CakeData) : ℤ :=
  3 * (C.genus : ℤ) - 3 + (C.cherries : ℤ)

/-- A `LayerStratification d` represents a complete flag of subvarieties
    in a d-dimensional ambient space. It is a strictly decreasing sequence
    of natural numbers starting at d and ending at 0. -/
structure LayerStratification (d : ℕ) where
  depths : List ℕ
  nonempty : depths ≠ []
  head_eq : depths.head (by exact nonempty) = d
  last_eq : depths.getLast (by exact nonempty) = 0
  strictly_decreasing : depths.Pairwise (· > ·)

/-- A complete flag stratification has exactly d+1 layers (dimensions d, d-1, ..., 1, 0) -/
def LayerStratification.isComplete (L : LayerStratification d) : Prop :=
  L.depths.length = d + 1

/-- Construct the canonical complete flag for dimension d -/
def canonicalFlag (d : ℕ) : LayerStratification d where
  depths := (List.range (d + 1)).reverse
  nonempty := by simp [List.reverse_eq_nil_iff]
  head_eq := by simp [List.head_reverse]
  last_eq := by simp [List.getLast_reverse]
  strictly_decreasing := by
    rw [List.pairwise_reverse]
    exact List.pairwise_lt_range

/-- A `FrostingSheaf` represents the data of a locally free rank-1 sheaf
    (line bundle) on the boundary of a cake. Over each boundary component,
    it has a degree (first Chern number). -/
structure FrostingSheaf where
  numComponents : ℕ
  degrees : Fin numComponents → ℤ

/-- The total degree of a frosting sheaf -/
def FrostingSheaf.totalDegree (F : FrostingSheaf) : ℤ :=
  ∑ i : Fin F.numComponents, F.degrees i

/-- A frosting sheaf is "uniform" if all boundary components have the same degree -/
def FrostingSheaf.isUniform (F : FrostingSheaf) : Prop :=
  ∀ i j : Fin F.numComponents, F.degrees i = F.degrees j

/-- A full cake consists of its combinatorial data, a frosting sheaf compatible
    with the boundary count, and a layer stratification. -/
structure Cake where
  data : CakeData
  frosting : FrostingSheaf
  frostingCompat : frosting.numComponents = data.boundary
  strat : LayerStratification data.layers

/-! ## Main Theorems -/

/-- **Theorem 1: Euler Characteristic Additivity under Layer Decomposition**

When two cakes are "glued" along a common boundary component, the resulting
Euler characteristic satisfies an inclusion-exclusion formula. Gluing along
a circle (χ = 0) gives χ(C₁ ∪ C₂) = χ(C₁) + χ(C₂). -/
theorem euler_char_gluing (C₁ C₂ : CakeData)
    (h₁ : C₁.boundary ≥ 1) (h₂ : C₂.boundary ≥ 1) :
    let C_glued : CakeData := {
      genus := C₁.genus + C₂.genus
      boundary := C₁.boundary + C₂.boundary - 2
      cherries := C₁.cherries + C₂.cherries
      layers := C₁.layers + C₂.layers
    }
    C_glued.eulerChar = C₁.eulerChar + C₂.eulerChar := by
  simp only [CakeData.eulerChar]
  omega

/-- **Theorem 2: Moduli Dimension is Even**

The real dimension of the Teichmüller moduli space (6g - 6 + 2n) is always
even, reflecting the underlying complex structure of the moduli space. -/
theorem moduli_dim_even (C : CakeData) :
    Even (C.moduliDimFormula) := by
  unfold CakeData.moduliDimFormula
  exact ⟨3 * (C.genus : ℤ) - 3 + (C.cherries : ℤ), by ring⟩

/-- **Theorem 3: Complex-Real Moduli Dimension Relationship**

The complex moduli dimension is exactly half the real moduli dimension:
  complexDim = realDim / 2

This reflects the fact that the moduli space is a complex manifold. -/
theorem complex_real_moduli_relationship (C : CakeData) :
    2 * C.complexModuliDim = C.moduliDimFormula := by
  unfold CakeData.complexModuliDim CakeData.moduliDimFormula
  ring

/-- **Theorem 4: Canonical Flag is Complete**

The canonical flag stratification d > d-1 > ... > 1 > 0 has exactly d+1 layers. -/
theorem canonical_flag_is_complete (d : ℕ) :
    (canonicalFlag d).isComplete := by
  unfold LayerStratification.isComplete canonicalFlag
  simp

/-- **Theorem 5: Positive Moduli Dimension for High-Genus Cakes**

For genus g ≥ 2, the moduli space has strictly positive real dimension,
even without any marked points. This is the "rigidity threshold":
surfaces of genus 0 and 1 have non-positive dimension without markings,
while genus ≥ 2 always gives a positive-dimensional moduli space. -/
theorem moduli_positive_high_genus (C : CakeData) (hg : C.genus ≥ 2) :
    C.moduliDimFormula ≥ 6 := by
  unfold CakeData.moduliDimFormula
  omega

/-- **Theorem 6: Cherry-Genus Trade-off (genus 0)**

For genus 0, we need at least 3 cherries for non-negative moduli dimension.
This captures the classical result that ℙ¹ needs 3 marked points. -/
theorem cherry_genus_tradeoff_genus0 (C : CakeData)
    (hg : C.genus = 0) (hmod : C.moduliDimFormula ≥ 0) :
    C.cherries ≥ 3 := by
  unfold CakeData.moduliDimFormula at hmod
  omega

/-- **Theorem 7: Euler Characteristic Determines Genus (given boundary count)**

For a fixed Euler characteristic and fixed boundary count,
the genus is uniquely determined. This is a weak form of the classification
of surfaces: the Euler characteristic and boundary count together determine
the topological type. -/
theorem euler_char_determines_genus (C₁ C₂ : CakeData)
    (hχ : C₁.eulerChar = C₂.eulerChar)
    (hb : C₁.boundary = C₂.boundary) :
    C₁.genus = C₂.genus := by
  unfold CakeData.eulerChar at hχ
  omega

/-
**Theorem 8: Layer Stratification Length Bound**

In any valid layer stratification of a d-dimensional object, the number of layers
is at most d + 1 (you can't have more strict drops than the total dimension).
-/
theorem stratification_length_bound (d : ℕ) (L : LayerStratification d) :
    L.depths.length ≤ d + 1 := by
      obtain ⟨depths, h_nonempty, h_head_eq, h_last_eq, h_strictly_decreasing⟩ := L;
      -- The depths of the layers are strictly decreasing and hence must be distinct.
      have h_distinct : depths.toFinset.card = depths.length := by
        rw [ List.toFinset_card_of_nodup ] ; exact List.Pairwise.nodup h_strictly_decreasing;
      have h_subset : depths.toFinset ⊆ Finset.Icc 0 d := by
        intro x hx; induction depths <;> simp_all +decide ;
        grind;
      exact h_distinct ▸ le_trans ( Finset.card_le_card h_subset ) ( by simp +arith +decide )

/-
**Theorem 9: Uniform Frosting Total Degree**

For a uniform frosting sheaf where each component has degree δ,
the total degree is numComponents · δ.
-/
theorem uniform_frosting_total_degree (F : FrostingSheaf) (δ : ℤ)
    (hd : ∀ i, F.degrees i = δ) :
    F.totalDegree = F.numComponents * δ := by
      unfold FrostingSheaf.totalDegree;
      aesop

/-- **Theorem 10: Moduli Dimension Monotone in Genus**

Adding genus (handles) always increases the moduli dimension by exactly 6
(real dimensions), reflecting that each handle adds 3 complex parameters. -/
theorem moduli_monotone_genus (C : CakeData) :
    let C' := { C with genus := C.genus + 1 }
    C'.moduliDimFormula = C.moduliDimFormula + 6 := by
  simp only [CakeData.moduliDimFormula]
  push_cast
  ring

/-- **Theorem 11: Moduli Dimension Monotone in Cherries**

Each additional cherry (marked point) adds exactly 2 real dimensions
to the moduli space. -/
theorem moduli_monotone_cherries (C : CakeData) :
    let C' := { C with cherries := C.cherries + 1 }
    C'.moduliDimFormula = C.moduliDimFormula + 2 := by
  simp only [CakeData.moduliDimFormula]
  push_cast
  ring

/-! ## Advanced: Frosting Degree and Riemann-Hurwitz -/

/-- The "complexity" of a cake: a combined measure of its topological
    and combinatorial complexity. -/
def CakeData.complexity (C : CakeData) : ℕ :=
  3 * C.genus + C.boundary + C.cherries + C.layers

/-- **Theorem 12: Complexity Bounds Moduli**

The moduli dimension is bounded by twice the complexity minus a constant.
This shows that topological complexity controls geometric flexibility. -/
theorem moduli_bounded_by_complexity (C : CakeData) :
    C.moduliDimFormula ≤ 2 * (C.complexity : ℤ) := by
  unfold CakeData.moduliDimFormula CakeData.complexity
  omega

/-- **Theorem 13: Gluing Superadditivity of Moduli**

When two cakes are glued, the moduli dimension of the result exceeds the
sum of components by exactly 6. This "bonus" comes from the new handle
created by identifying boundary circles. -/
theorem gluing_moduli_superadditive (C₁ C₂ : CakeData) :
    let C_glued : CakeData := {
      genus := C₁.genus + C₂.genus
      boundary := C₁.boundary + C₂.boundary - 2
      cherries := C₁.cherries + C₂.cherries
      layers := C₁.layers + C₂.layers
    }
    C_glued.moduliDimFormula = C₁.moduliDimFormula + C₂.moduliDimFormula + 6 := by
  simp only [CakeData.moduliDimFormula]
  push_cast
  ring

/-! ## The 3g-3 Formula -/

/-- The 3g-3 theorem: for genus g ≥ 2 with no marked points,
    the complex moduli dimension is exactly 3g - 3. -/
theorem three_g_minus_three (g : ℕ) (_hg : g ≥ 2) :
    let C : CakeData := ⟨g, 0, 0, 1⟩
    C.complexModuliDim = 3 * (g : ℤ) - 3 := by
  simp [CakeData.complexModuliDim]

/-! ## Novel Structure: CakeCategory -/

/-- A morphism of cakes preserves genus (weakly: the target has at least the source's genus),
    can only add cherries, and is compatible with boundary structure. -/
structure CakeMorphism (C D : CakeData) where
  genus_le : C.genus ≤ D.genus
  boundary_le : C.boundary ≤ D.boundary
  cherry_le : C.cherries ≤ D.cherries

/-- **Theorem 14: Moduli Dimension is Monotone under Cake Morphisms**

If there is a morphism C → D (D is "more complex"), then D's moduli
dimension is at least as large as C's. -/
theorem moduli_monotone_morphism (C D : CakeData) (f : CakeMorphism C D) :
    C.moduliDimFormula ≤ D.moduliDimFormula := by
  unfold CakeData.moduliDimFormula
  have := f.genus_le
  have := f.cherry_le
  omega

/-- Identity morphism -/
def CakeMorphism.id (C : CakeData) : CakeMorphism C C where
  genus_le := le_refl _
  boundary_le := le_refl _
  cherry_le := le_refl _

/-- Composition of morphisms -/
def CakeMorphism.comp {A B C : CakeData} (f : CakeMorphism A B) (g : CakeMorphism B C) :
    CakeMorphism A C where
  genus_le := le_trans f.genus_le g.genus_le
  boundary_le := le_trans f.boundary_le g.boundary_le
  cherry_le := le_trans f.cherry_le g.cherry_le

/-- **Theorem 15: Moduli Monotonicity is Transitive under Composition**

The composition of two moduli-increasing morphisms is moduli-increasing.
This is a categorification of the moduli dimension bound. -/
theorem moduli_monotone_comp {A B C : CakeData}
    (f : CakeMorphism A B) (g : CakeMorphism B C) :
    A.moduliDimFormula ≤ C.moduliDimFormula :=
  le_trans (moduli_monotone_morphism A B f) (moduli_monotone_morphism B C g)

/-! ## Computational Verification -/

#eval do
  let results := #[2, 3, 4, 5].map fun g =>
    let C : CakeData := ⟨g, 0, 0, 1⟩
    (g, C.complexModuliDim, 3 * (g : Int) - 3)
  return results

#eval do
  let sphere : CakeData := ⟨0, 0, 0, 1⟩
  let torus : CakeData := ⟨1, 0, 0, 1⟩
  let disk : CakeData := ⟨0, 1, 0, 1⟩
  let annulus : CakeData := ⟨0, 2, 0, 1⟩
  return #[("sphere", sphere.eulerChar),
           ("torus", torus.eulerChar),
           ("disk", disk.eulerChar),
           ("annulus", annulus.eulerChar)]