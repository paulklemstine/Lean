/-
Copyright (c) 2026.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# A specialization connector for tropical Brill--Noether theory

This file isolates the precise logical bridge between classical and tropical
Brill--Noether theory.  A `BNWorld` consists of classical divisors, tropical
divisors, and a tropicalization map satisfying the two conclusions of the
specialization lemma: degree is preserved and rank cannot decrease.

A `LiftData` supplies the converse geometric input: every tropical divisor can
be lifted without changing degree and without decreasing rank.  Under these
two hypotheses, existence of a classical `g^r_d` is equivalent to existence of
a tropical `g^r_d`.  Consequently the classical Brill--Noether criterion
transfers verbatim to the tropical side.

Here `HasSeries d r` means rank *at least* `r`, which is the standard meaning
of the notation `g^r_d` in an existence statement.
-/

namespace TropicalBrillNoetherConnector

/-- The Brill--Noether number `ρ(g,d,r) = g - (r+1)(g-d+r)`. -/
def rho (g d r : ℤ) : ℤ :=
  g - (r + 1) * (g - d + r)

/-- The alternative dimension-count formula for the Brill--Noether number. -/
theorem rho_dimension_formula (g d r : ℤ) :
    rho g d r = (r + 1) * (d - r) - g * r := by
  simp only [rho]
  ring

/-- The expected number of independent conditions defining a classical
Brill--Noether locus inside a genus-`g` Picard variety. -/
def expectedConditions (g d r : ℤ) : ℤ :=
  (r + 1) * (g - d + r)

/-- The Brill--Noether number is genus minus the expected codimension.  This is
the numerical bridge from linear-series determinantal geometry to tropical
existence. -/
theorem rho_eq_genus_sub_expectedConditions (g d r : ℤ) :
    rho g d r = g - expectedConditions g d r := by
  rfl

/-- Nonnegative Brill--Noether number says exactly that the expected number of
conditions does not exceed the dimension `g` of the Picard variety. -/
theorem rho_nonneg_iff_expectedConditions_le_genus (g d r : ℤ) :
    0 ≤ rho g d r ↔ expectedConditions g d r ≤ g := by
  simp only [rho_eq_genus_sub_expectedConditions]
  omega

/-- Numerical Serre duality: replacing `(d,r)` by the invariants of `K-D`
leaves the Brill--Noether number unchanged. -/
theorem rho_serre_duality (g d r : ℤ) :
    rho g d r = rho g (2 * g - 2 - d) (g - 1 - d + r) := by
  simp only [rho]
  ring

/-- The classical rank associated with a space of global sections of dimension
`h⁰` is `h⁰ - 1`. -/
def sectionRank (h0 : ℕ) : ℤ :=
  (h0 : ℤ) - 1

/-- The classical condition `rank ≥ r` is equivalent to the existence of at
least `r+1` linearly independent global sections. -/
theorem sectionRank_ge_iff {h0 r : ℕ} :
    (r : ℤ) ≤ sectionRank h0 ↔ r + 1 ≤ h0 := by
  simp only [sectionRank]
  omega

/-- Abstract data of a classical curve and a tropicalization of it.
The rank inequality is the divisor-specialization inequality. -/
structure BNWorld where
  ClassicalDivisor : Type
  TropicalDivisor : Type
  classicalDegree : ClassicalDivisor → ℤ
  classicalRank : ClassicalDivisor → ℤ
  tropicalDegree : TropicalDivisor → ℤ
  tropicalRank : TropicalDivisor → ℤ
  tropicalize : ClassicalDivisor → TropicalDivisor
  degree_tropicalize : ∀ D, tropicalDegree (tropicalize D) = classicalDegree D
  rank_specialization : ∀ D, classicalRank D ≤ tropicalRank (tropicalize D)

/-- Existence of a classical divisor of degree `d` and rank at least `r`. -/
def ClassicalHasSeries (W : BNWorld) (d r : ℤ) : Prop :=
  ∃ D : W.ClassicalDivisor, W.classicalDegree D = d ∧ r ≤ W.classicalRank D

/-- Existence of a tropical divisor of degree `d` and rank at least `r`. -/
def TropicalHasSeries (W : BNWorld) (d r : ℤ) : Prop :=
  ∃ D : W.TropicalDivisor, W.tropicalDegree D = d ∧ r ≤ W.tropicalRank D

/-- Baker's specialization inequality gives the forward bridge from a
classical linear series to a tropical linear series. -/
theorem specialize_series (W : BNWorld) {d r : ℤ} :
    ClassicalHasSeries W d r → TropicalHasSeries W d r := by
  rintro ⟨D, hdegree, hrank⟩
  refine ⟨W.tropicalize D, ?_, ?_⟩
  · exact (W.degree_tropicalize D).trans hdegree
  · exact hrank.trans (W.rank_specialization D)

/-- The lifting input needed for the reverse implication.  It deliberately
records only the two invariants relevant to Brill--Noether existence. -/
structure LiftData (W : BNWorld) where
  lift : W.TropicalDivisor → W.ClassicalDivisor
  degree_lift : ∀ D, W.classicalDegree (lift D) = W.tropicalDegree D
  rank_lift : ∀ D, W.tropicalRank D ≤ W.classicalRank (lift D)

/-- A rank-preserving lifting theorem supplies the reverse bridge. -/
theorem lift_series (W : BNWorld) (L : LiftData W) {d r : ℤ} :
    TropicalHasSeries W d r → ClassicalHasSeries W d r := by
  rintro ⟨D, hdegree, hrank⟩
  refine ⟨L.lift D, ?_, ?_⟩
  · exact (L.degree_lift D).trans hdegree
  · exact hrank.trans (L.rank_lift D)

/-- **Classical--tropical connector.**  Specialization together with lifting
identifies the two Brill--Noether existence predicates. -/
theorem classical_iff_tropical (W : BNWorld) (L : LiftData W) (d r : ℤ) :
    ClassicalHasSeries W d r ↔ TropicalHasSeries W d r := by
  constructor
  · exact specialize_series W
  · exact lift_series W L

/-- The classical Brill--Noether theorem, packaged as a property of a world. -/
def SatisfiesClassicalBrillNoether (W : BNWorld) (g : ℤ) : Prop :=
  ∀ d r : ℤ, ClassicalHasSeries W d r ↔ 0 ≤ rho g d r

/-- The tropical Brill--Noether theorem, packaged as a property of a world. -/
def SatisfiesTropicalBrillNoether (W : BNWorld) (g : ℤ) : Prop :=
  ∀ d r : ℤ, TropicalHasSeries W d r ↔ 0 ≤ rho g d r

/-- **Tropical Brill--Noether criterion transferred from classical geometry.**
For a specialization admitting rank-preserving lifts, a classical general
curve satisfies the Brill--Noether criterion if and only if its tropical model
does.  In particular, the tropical model has a divisor of degree `d` and rank
at least `r` exactly when `ρ(g,d,r) ≥ 0`. -/
theorem tropical_brill_noether_iff (W : BNWorld) (L : LiftData W) (g d r : ℤ)
    (hclassical : SatisfiesClassicalBrillNoether W g) :
    TropicalHasSeries W d r ↔ 0 ≤ rho g d r := by
  rw [← hclassical d r]
  exact (classical_iff_tropical W L d r).symm

/-- The connector is symmetric at the level of the complete theorem: under
lifting, classical generality and tropical generality are equivalent. -/
theorem classical_generality_iff_tropical_generality
    (W : BNWorld) (L : LiftData W) (g : ℤ) :
    SatisfiesClassicalBrillNoether W g ↔ SatisfiesTropicalBrillNoether W g := by
  constructor
  · intro h d r
    exact tropical_brill_noether_iff W L g d r h
  · intro h d r
    rw [classical_iff_tropical W L d r]
    exact h d r

/-- The full three-way connector: tropical divisors, classical linear series,
and the determinantal expected-codimension inequality describe the same
existence condition. -/
theorem tropical_iff_classical_iff_expected_dimension
    (W : BNWorld) (L : LiftData W) (g d r : ℤ)
    (hclassical : SatisfiesClassicalBrillNoether W g) :
    TropicalHasSeries W d r ↔
      ClassicalHasSeries W d r ∧ expectedConditions g d r ≤ g := by
  rw [classical_iff_tropical W L d r]
  constructor
  · intro htropical
    exact ⟨htropical,
      (rho_nonneg_iff_expectedConditions_le_genus g d r).mp
        ((tropical_brill_noether_iff W L g d r hclassical).mp htropical)⟩
  · exact fun h => h.1

/-- Negative Brill--Noether number is a certified nonexistence obstruction on
the tropical side. -/
theorem no_tropical_series_of_rho_negative
    (W : BNWorld) (L : LiftData W) (g d r : ℤ)
    (hclassical : SatisfiesClassicalBrillNoether W g)
    (hnegative : rho g d r < 0) :
    ¬ TropicalHasSeries W d r := by
  rw [tropical_brill_noether_iff W L g d r hclassical]
  omega

end TropicalBrillNoetherConnector