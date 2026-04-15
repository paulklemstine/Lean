/-! # CatalogBuild.Tropical.Langlands.ShimuraVarieties

Auto-generated from theorem catalog database.
Domain: Tropical/Langlands
Declarations: 21
-/

import Mathlib

noncomputable section

/-- A tropical elliptic curve is a circle with a length parameter -/
structure TropicalEllipticCurve where
  length : ℝ
  length_pos : length > 0


/-- The j-invariant of a tropical elliptic curve is its length -/
def tropicalJInvariant (E : TropicalEllipticCurve) : ℝ := E.length


/-- Two tropical elliptic curves are isomorphic iff same length -/
theorem tropical_ec_iso_iff (E1 E2 : TropicalEllipticCurve) :
    tropicalJInvariant E1 = tropicalJInvariant E2 ↔ E1.length = E2.length := by
  simp [tropicalJInvariant]


/-- j-invariant is positive -/
theorem jInvariant_pos (E : TropicalEllipticCurve) :
    tropicalJInvariant E > 0 := E.length_pos


/-- A tropical abelian variety of dimension g -/
structure TropicalAbelianVariety (g : ℕ) where
  periodMatrix : Fin g → Fin g → ℝ
  symmetric : ∀ i j, periodMatrix i j = periodMatrix j i
  diagonal_pos : ∀ i, periodMatrix i i > 0


/-- Polarization degree -/
def polarizationDegree (g : ℕ) (A : TropicalAbelianVariety g) : ℝ :=
  ∑ i : Fin g, A.periodMatrix i i


/-- Polarization degree is positive -/
theorem polarization_pos (g : ℕ) [NeZero g] (A : TropicalAbelianVariety g) :
    polarizationDegree g A > 0 := by
  apply Finset.sum_pos
  · intro i _; exact A.diagonal_pos i
  · exact Finset.univ_nonempty


/-- The tropical Siegel upper half space -/
def TropicalSiegel (g : ℕ) : Set (Fin g → Fin g → ℝ) :=
  { M | (∀ i j, M i j = M j i) ∧ (∀ i, M i i > 0) }


/-- The tropical Siegel space is non-empty -/
theorem siegel_nonempty (g : ℕ) :
    (TropicalSiegel g).Nonempty := by
  refine ⟨fun i j => if i = j then 1 else 0, ?_, ?_⟩
  · intro i j; simp only; split_ifs with h1 h2 h2 <;> simp_all
  · intro i; simp


/-- The tropical Siegel space is convex -/
theorem siegel_convex (g : ℕ) :
    Convex ℝ (TropicalSiegel g) := by
  intro x hx y hy a b ha hb hab
  refine ⟨?_, ?_⟩
  · intro i j
    simp only [Pi.add_apply, Pi.smul_apply, smul_eq_mul]
    rw [hx.1 i j, hy.1 i j]
  · intro i
    simp only [Pi.add_apply, Pi.smul_apply, smul_eq_mul]
    by_cases hb0 : b = 0
    · subst hb0; simp at hab ⊢; rw [hab]; exact mul_pos one_pos (hx.2 i)
    · have hb_pos : b > 0 := lt_of_le_of_ne hb (Ne.symm hb0)
      exact add_pos_of_nonneg_of_pos (mul_nonneg ha (le_of_lt (hx.2 i)))
        (mul_pos hb_pos (hy.2 i))


/-- A tropical modular form of weight k -/
structure TropicalModularForm (k : ℤ) where
  eval : ℝ → ℝ


/-- The tropical Eisenstein series of weight k -/
def tropicalEisensteinSeries (k : ℤ) : TropicalModularForm k where
  eval := fun z => k * z


/-- Eisenstein series is linear -/
theorem eisenstein_linear (k : ℤ) (z1 z2 : ℝ) :
    (tropicalEisensteinSeries k).eval (z1 + z2) =
    (tropicalEisensteinSeries k).eval z1 + (tropicalEisensteinSeries k).eval z2 := by
  simp [tropicalEisensteinSeries, mul_add]


/-- Moduli dimension at level N -/
def moduliDimension (g : ℕ) (N : ℕ) : ℕ := g * (g + 1) / 2 + g^2 * (N - 1)


/-- At level 1, moduli dimension is Siegel dimension -/
theorem moduli_level_one (g : ℕ) :
    moduliDimension g 1 = g * (g + 1) / 2 := by
  simp [moduliDimension]


/-- A CM point on a tropical Shimura variety -/
structure TropicalCMPoint (g : ℕ) extends TropicalAbelianVariety g where
  cmField_degree : ℕ
  is_cm : cmField_degree = 2 * g


/-- CM points in dimension 1 have CM field degree 2 -/
theorem cm_dim1_degree (p : TropicalCMPoint 1) : p.cmField_degree = 2 := by
  have := p.is_cm; omega


/-- Tropical Hecke operator T_p on functions -/
def tropicalHeckeOperator (p : ℕ) (f : ℝ → ℝ) : ℝ → ℝ :=
  fun z => min (f (p * z)) (f z + p)


/-- Hecke operators are monotone -/
theorem hecke_monotone (p : ℕ) (f g : ℝ → ℝ)
    (h : ∀ z, f z ≤ g z) (z : ℝ) :
    tropicalHeckeOperator p f z ≤ tropicalHeckeOperator p g z := by
  simp only [tropicalHeckeOperator]
  apply min_le_min (h _)
  linarith [h z]


/-- The tropical Tate module of an abelian variety -/
def tropicalTateModule (g : ℕ) (A : TropicalAbelianVariety g) : Fin g → Fin g → ℝ :=
  A.periodMatrix


/-- Tate module is symmetric -/
theorem tateModule_symmetric (g : ℕ) (A : TropicalAbelianVariety g) (i j : Fin g) :
    tropicalTateModule g A i j = tropicalTateModule g A j i :=
  A.symmetric i j


end
