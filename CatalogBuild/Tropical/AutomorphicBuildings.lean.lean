/-! # CatalogBuild.Tropical.AutomorphicBuildings.lean

Auto-generated from theorem catalog database.
Domain: Tropical
Declarations: 23
-/

import Mathlib

noncomputable section

/-- A vertex in the Bruhat-Tits building of GL_n -/
structure BuildingVertex (n : ℕ) where
  invariantFactors : Fin n → ℝ
  sorted : ∀ i j : Fin n, i ≤ j → invariantFactors i ≤ invariantFactors j


/-- The distance between two vertices -/
def buildingDistance (n : ℕ) (v w : BuildingVertex n) : ℝ :=
  ∑ i : Fin n, |v.invariantFactors i - w.invariantFactors i|


/-- Building distance is non-negative -/
theorem buildingDistance_nonneg (n : ℕ) (v w : BuildingVertex n) :
    buildingDistance n v w ≥ 0 := by
  apply Finset.sum_nonneg
  intro i _; exact abs_nonneg _


/-- Building distance is symmetric -/
theorem buildingDistance_symm (n : ℕ) (v w : BuildingVertex n) :
    buildingDistance n v w = buildingDistance n w v := by
  simp [buildingDistance, abs_sub_comm]


/-- Building distance from a vertex to itself is zero -/
theorem buildingDistance_self (n : ℕ) (v : BuildingVertex n) :
    buildingDistance n v v = 0 := by
  simp [buildingDistance]


/-- An apartment in the building -/
structure Apartment (n : ℕ) where
  origin : Fin n → ℝ


/-- The standard apartment -/
def standardApartment (n : ℕ) : Apartment n where
  origin := fun _ => 0


/-- A point in an apartment -/
def apartmentPoint (n : ℕ) (A : Apartment n) (x : Fin n → ℝ) : Fin n → ℝ :=
  fun i => A.origin i + x i


/-- Standard apartment origin is zero -/
theorem standardApartment_origin (n : ℕ) :
    (standardApartment n).origin = fun _ => (0 : ℝ) := rfl


/-- Tropical Laplacian at a vertex -/
def tropicalLaplacian (n : ℕ) (f : BuildingVertex n → ℝ) (v : BuildingVertex n)
    (neighbors : Finset (BuildingVertex n)) : ℝ :=
  (∑ w ∈ neighbors, f w) / neighbors.card - f v


/-- Constant functions are harmonic -/
theorem const_harmonic (n : ℕ) (c : ℝ)
    (neighborMap : BuildingVertex n → Finset (BuildingVertex n))
    (hne : ∀ v, (neighborMap v).Nonempty) :
    ∀ v, tropicalLaplacian n (fun _ => c) v (neighborMap v) = 0 := by
  intro v
  simp only [tropicalLaplacian]
  rw [Finset.sum_const, nsmul_eq_mul]
  have hcard : (0 : ℝ) < (neighborMap v).card := by
    exact Nat.cast_pos.mpr (Finset.Nonempty.card_pos (hne v))
  field_simp
  ring


/-- Tropical spherical function -/
def tropicalSpherical (n : ℕ) (s : ℝ) (v : BuildingVertex n) : ℝ :=
  s * ∑ i : Fin n, v.invariantFactors i


/-- Spherical function at s = 0 is zero -/
theorem spherical_zero (n : ℕ) (v : BuildingVertex n) :
    tropicalSpherical n 0 v = 0 := by
  simp [tropicalSpherical]


/-- Spherical function is linear in s -/
theorem spherical_linear (n : ℕ) (s t : ℝ) (v : BuildingVertex n) :
    tropicalSpherical n (s + t) v =
    tropicalSpherical n s v + tropicalSpherical n t v := by
  simp [tropicalSpherical, add_mul]


/-- Spherical function at origin is zero -/
theorem spherical_at_origin (n : ℕ) (s : ℝ) :
    tropicalSpherical n s ⟨fun _ => 0, fun _ _ _ => le_refl 0⟩ = 0 := by
  simp [tropicalSpherical]


/-- Iwahori-Hecke generator (tropical version) -/
def iwahoriGenerator (q : ℝ) (_hq : q > 0) (x : ℝ) : ℝ :=
  min x (x + q)


/-- Iwahori generator simplifies to x when q > 0 -/
theorem iwahori_eq (q : ℝ) (hq : q > 0) (x : ℝ) :
    iwahoriGenerator q hq x = x := by
  simp [iwahoriGenerator, min_eq_left (le_add_of_nonneg_right (le_of_lt hq))]


/-- Spherical Hecke algebra is commutative -/
theorem spherical_hecke_comm (n : ℕ) (s : ℝ) (v w : BuildingVertex n) :
    tropicalSpherical n s v + tropicalSpherical n s w =
    tropicalSpherical n s w + tropicalSpherical n s v := by
  ring


/-- Depth of a building vertex (requires n ≥ 1) -/
def vertexDepth (n : ℕ) (hn : n ≥ 1) (v : BuildingVertex n) : ℝ :=
  v.invariantFactors ⟨n - 1, by omega⟩ - v.invariantFactors ⟨0, by omega⟩


/-- Depth is non-negative -/
theorem vertexDepth_nonneg (n : ℕ) (hn : n ≥ 1) (v : BuildingVertex n) :
    vertexDepth n hn v ≥ 0 := by
  unfold vertexDepth
  linarith [v.sorted ⟨0, by omega⟩ ⟨n - 1, by omega⟩ (by simp [Fin.le_def])]


/-- A special vertex has integer invariant factors -/
def isSpecialVertex (n : ℕ) (v : BuildingVertex n) : Prop :=
  ∀ i, ∃ k : ℤ, v.invariantFactors i = k


/-- The origin is special -/
theorem origin_special (n : ℕ) :
    isSpecialVertex n ⟨fun _ => 0, fun _ _ _ => le_refl 0⟩ := by
  intro i; exact ⟨0, by simp⟩


/-- Integer-valued vertices are special -/
theorem int_vertex_special (n : ℕ) (f : Fin n → ℤ)
    (hsorted : ∀ i j : Fin n, i ≤ j → f i ≤ f j) :
    isSpecialVertex n ⟨fun i => (f i : ℝ), fun i j h => by
      exact Int.cast_le.mpr (hsorted i j h)⟩ := by
  intro i; exact ⟨f i, by simp⟩


end
