import Mathlib

/-! # CatalogBuild.Tropical.Langlands.LocalLanglands

Auto-generated from theorem catalog database.
Domain: Tropical/Langlands
Declarations: 22
-/

noncomputable section

/-- A tropical Weil-Deligne representation of dimension n -/
structure TropicalWDRep (n : ℕ) where
  frobeniusEigenvalues : Fin n → ℝ
  sorted : ∀ i j : Fin n, i ≤ j → frobeniusEigenvalues i ≤ frobeniusEigenvalues j
  monodromyRank : ℕ
  monodromy_bound : monodromyRank ≤ n

/-- A tropical smooth representation of GL_n(F) -/
structure TropicalSmoothRep (n : ℕ) where
  satakeParameters : Fin n → ℝ
  sorted : ∀ i j : Fin n, i ≤ j → satakeParameters i ≤ satakeParameters j
  conductor : ℕ

/-- The tropical local Langlands map -/
def tropicalLLC (n : ℕ) (rho : TropicalWDRep n) : TropicalSmoothRep n where
  satakeParameters := rho.frobeniusEigenvalues
  sorted := rho.sorted
  conductor := rho.monodromyRank

/-- LLC preserves parameters -/
theorem LLC_preserves_parameters (n : ℕ) (rho : TropicalWDRep n) :
    (tropicalLLC n rho).satakeParameters = rho.frobeniusEigenvalues := rfl

/-- LLC preserves sorting -/
theorem LLC_preserves_sorting (n : ℕ) (rho : TropicalWDRep n) (i j : Fin n) (h : i ≤ j) :
    (tropicalLLC n rho).satakeParameters i ≤ (tropicalLLC n rho).satakeParameters j :=
  rho.sorted i j h

/-- Tropical local L-factor -/
def tropicalLocalL (n : ℕ) (rho : TropicalWDRep n) (s : ℝ) : ℝ :=
  (∑ i : Fin n, rho.frobeniusEigenvalues i) * s

/-- L-factor vanishes at s = 0 -/
theorem localL_zero (n : ℕ) (rho : TropicalWDRep n) :
    tropicalLocalL n rho 0 = 0 := by
  simp [tropicalLocalL]

/-- L-factor is linear -/
theorem localL_linear (n : ℕ) (rho : TropicalWDRep n) (s t : ℝ) :
    tropicalLocalL n rho (s + t) = tropicalLocalL n rho s + tropicalLocalL n rho t := by
  simp [tropicalLocalL, mul_add]

/-- LLC preserves L-factors -/
theorem LLC_preserves_L (n : ℕ) (rho : TropicalWDRep n) (s : ℝ) :
    tropicalLocalL n rho s =
    (∑ i : Fin n, (tropicalLLC n rho).satakeParameters i) * s := by
  simp [tropicalLocalL, tropicalLLC]

/-- Tropical epsilon-factor -/
def tropicalEpsilon (n : ℕ) (rho : TropicalWDRep n) : ℝ :=
  (-1)^n * ∑ i : Fin n, rho.frobeniusEigenvalues i

/-- Local functional equation -/
theorem local_functional_equation (n : ℕ) (rho : TropicalWDRep n) (s : ℝ) :
    tropicalLocalL n rho s + tropicalLocalL n rho (1 - s) =
    (∑ i : Fin n, rho.frobeniusEigenvalues i) := by
  simp [tropicalLocalL]; ring

/-- Newton polygon point -/
def newtonPolygonPoint (n : ℕ) (rho : TropicalWDRep n) (k : Fin n) : ℝ × ℝ :=
  (k.val, ∑ i ∈ Finset.filter (· ≤ k) Finset.univ, rho.frobeniusEigenvalues i)

/-- Newton polygon starts at x = 0 -/
theorem newton_start (n : ℕ) [NeZero n] (rho : TropicalWDRep n) :
    (newtonPolygonPoint n rho ⟨0, NeZero.pos n⟩).1 = 0 := by
  simp [newtonPolygonPoint]

/-- Newton polygon is convex (slopes non-decreasing) -/
theorem newton_convex (n : ℕ) (rho : TropicalWDRep n) (i j : Fin n) (h : i ≤ j) :
    rho.frobeniusEigenvalues i ≤ rho.frobeniusEigenvalues j :=
  rho.sorted i j h

/-- A WD rep is unramified if monodromy rank = 0 -/
def isUnramified (n : ℕ) (rho : TropicalWDRep n) : Prop :=
  rho.monodromyRank = 0

/-- Unramified reps have conductor 0 -/
theorem unramified_conductor_zero (n : ℕ) (rho : TropicalWDRep n)
    (h : isUnramified n rho) :
    (tropicalLLC n rho).conductor = 0 := h

/-- Unramified WD rep with constant eigenvalues -/
def unramifiedWDRep (n : ℕ) (a : ℝ) : TropicalWDRep n where
  frobeniusEigenvalues := fun _ => a
  sorted := fun _ _ _ => le_refl _
  monodromyRank := 0
  monodromy_bound := Nat.zero_le _

/-- The constant rep is unramified -/
theorem unramifiedWDRep_is_unramified (n : ℕ) (a : ℝ) :
    isUnramified n (unramifiedWDRep n a) := rfl

/-- L-factor of a direct sum is sum of L-factors -/
theorem localL_add (m n : ℕ) (rho1 : TropicalWDRep m) (rho2 : TropicalWDRep n)
    (_hsort : ∀ i j : Fin (m + n), i ≤ j →
      (Fin.append rho1.frobeniusEigenvalues rho2.frobeniusEigenvalues) i ≤
      (Fin.append rho1.frobeniusEigenvalues rho2.frobeniusEigenvalues) j)
    (s : ℝ) :
    (∑ i : Fin (m + n), (Fin.append rho1.frobeniusEigenvalues rho2.frobeniusEigenvalues) i) * s =
    tropicalLocalL m rho1 s + tropicalLocalL n rho2 s := by
  simp [tropicalLocalL]
  rw [Fin.sum_univ_add]
  simp [Fin.append_left, Fin.append_right]
  ring

/-- Global-to-local restriction -/
def globalToLocal (n : ℕ) (globalParams : Fin n → ℝ)
    (hsorted : ∀ i j : Fin n, i ≤ j → globalParams i ≤ globalParams j) :
    TropicalWDRep n where
  frobeniusEigenvalues := globalParams
  sorted := hsorted
  monodromyRank := 0
  monodromy_bound := Nat.zero_le _

/-- Global-to-local gives unramified reps -/
theorem globalToLocal_unramified (n : ℕ) (globalParams : Fin n → ℝ)
    (hsorted : ∀ i j : Fin n, i ≤ j → globalParams i ≤ globalParams j) :
    isUnramified n (globalToLocal n globalParams hsorted) := rfl

/-- Local-global L-factor compatibility -/
theorem local_global_compatibility (n : ℕ) (globalParams : Fin n → ℝ)
    (hsorted : ∀ i j : Fin n, i ≤ j → globalParams i ≤ globalParams j)
    (s : ℝ) :
    tropicalLocalL n (globalToLocal n globalParams hsorted) s =
    (∑ i : Fin n, globalParams i) * s := by
  simp [tropicalLocalL, globalToLocal]

end