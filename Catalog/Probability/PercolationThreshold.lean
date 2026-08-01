import Mathlib

/-!
# A finite triangular percolation threshold calculation

This file separates a rigorously solvable local calculation from the open problem
of finding a closed analytic form for the infinite square-lattice site threshold.
For three independent Bernoulli sites, the probability that at least two are open
is `p³ + 3p²(1-p)`.  We prove that this increasing event is self-dual and has the
unique fair point `p = 1/2`.  The same polynomial describes the event that three
vertices are connected by open bonds in a triangular face.

This is the elementary local self-duality calculation underlying the exact
critical parameter for triangular-lattice site percolation.  It is deliberately
not presented as a proof of the infinite-volume theorem, which additionally
requires substantial planar percolation machinery.
-/

namespace PercolationThreshold

/-- The probability that at least two of three independent sites of density `p`
are open: either all three are open, or exactly two are open. -/
def triangleSiteCrossingProbability (p : ℝ) : ℝ :=
  p ^ 3 + 3 * p ^ 2 * (1 - p)

/-- Expanding the elementary three-site probability gives its standard cubic
form. -/
theorem triangleSiteCrossingProbability_eq_cubic (p : ℝ) :
    triangleSiteCrossingProbability p = 3 * p ^ 2 - 2 * p ^ 3 := by
  unfold triangleSiteCrossingProbability
  ring

/-- The local crossing probability is nonnegative for a genuine Bernoulli
parameter. -/
theorem triangleSiteCrossingProbability_nonneg {p : ℝ}
    (hp0 : 0 ≤ p) (hp1 : p ≤ 1) :
    0 ≤ triangleSiteCrossingProbability p := by
  unfold triangleSiteCrossingProbability
  exact add_nonneg (pow_nonneg hp0 3)
    (mul_nonneg (mul_nonneg (by norm_num) (pow_nonneg hp0 2)) (sub_nonneg.mpr hp1))

/-- Complementing all three sites exchanges crossing and non-crossing. -/
theorem triangleSiteCrossingProbability_complement (p : ℝ) :
    triangleSiteCrossingProbability (1 - p) =
      1 - triangleSiteCrossingProbability p := by
  rw [triangleSiteCrossingProbability_eq_cubic,
    triangleSiteCrossingProbability_eq_cubic]
  ring

/-- Consequently the local crossing probability is at most one on the unit
interval. -/
theorem triangleSiteCrossingProbability_le_one {p : ℝ}
    (hp0 : 0 ≤ p) (hp1 : p ≤ 1) :
    triangleSiteCrossingProbability p ≤ 1 := by
  have hnonneg := triangleSiteCrossingProbability_nonneg
    (p := 1 - p) (sub_nonneg.mpr hp1) (by linarith)
  rw [triangleSiteCrossingProbability_complement] at hnonneg
  linarith

/-- At density `1/2`, self-duality makes the crossing probability exactly
`1/2`. -/
theorem triangleSiteCrossingProbability_half :
    triangleSiteCrossingProbability (1 / 2 : ℝ) = 1 / 2 := by
  have h := triangleSiteCrossingProbability_complement (1 / 2 : ℝ)
  norm_num at h ⊢
  linarith

/-- Below density `1/2`, the local triangular crossing probability is strictly
below `1/2`. -/
theorem triangleSiteCrossingProbability_lt_half {p : ℝ}
    (hp0 : 0 ≤ p) (hp : p < 1 / 2) :
    triangleSiteCrossingProbability p < 1 / 2 := by
  rw [triangleSiteCrossingProbability_eq_cubic]
  have hfactor : 0 < p * (1 - p) + 1 / 2 := by
    have hp1 : p ≤ 1 := by linarith
    nlinarith [mul_nonneg hp0 (sub_nonneg.mpr hp1)]
  have hid :
      (3 * p ^ 2 - 2 * p ^ 3) - 1 / 2 =
        (2 * p - 1) * (p * (1 - p) + 1 / 2) := by ring
  have hneg : 2 * p - 1 < 0 := by linarith
  have hprod : (2 * p - 1) * (p * (1 - p) + 1 / 2) < 0 :=
    mul_neg_of_neg_of_pos hneg hfactor
  nlinarith [hid]

/-- Above density `1/2`, complementation converts the preceding strict lower-side
bound into a strict upper-side bound. -/
theorem triangleSiteCrossingProbability_gt_half {p : ℝ}
    (hp : 1 / 2 < p) (hp1 : p ≤ 1) :
    1 / 2 < triangleSiteCrossingProbability p := by
  have hbelow := triangleSiteCrossingProbability_lt_half
    (p := 1 - p) (by linarith) (by linarith)
  rw [triangleSiteCrossingProbability_complement] at hbelow
  linarith

/-- The fair crossing equation has a unique solution among Bernoulli
parameters. -/
theorem triangleSiteCrossingProbability_eq_half_iff {p : ℝ}
    (hp0 : 0 ≤ p) (hp1 : p ≤ 1) :
    triangleSiteCrossingProbability p = 1 / 2 ↔ p = 1 / 2 := by
  constructor
  · intro heq
    rcases lt_trichotomy p (1 / 2) with hlt | he | hgt
    · have := triangleSiteCrossingProbability_lt_half hp0 hlt
      linarith
    · exact he
    · have := triangleSiteCrossingProbability_gt_half hgt hp1
      linarith
  · intro hp
    simpa [hp] using triangleSiteCrossingProbability_half

/-- A local critical parameter is a Bernoulli parameter in `[0,1]` at which the
three-site crossing event is fair. -/
def IsTriangularSiteLocalCritical (p : ℝ) : Prop :=
  0 ≤ p ∧ p ≤ 1 ∧ triangleSiteCrossingProbability p = 1 / 2

/-- The local triangular site self-duality criterion has the exact and unique
critical parameter `1/2`. -/
theorem triangularSiteLocalCritical_iff (p : ℝ) :
    IsTriangularSiteLocalCritical p ↔ p = 1 / 2 := by
  constructor
  · rintro ⟨hp0, hp1, heq⟩
    exact (triangleSiteCrossingProbability_eq_half_iff hp0 hp1).mp heq
  · intro hp
    subst p
    refine ⟨by norm_num, by norm_num, triangleSiteCrossingProbability_half⟩

/-- For bond percolation on one triangular face, all three vertices are connected
exactly when either exactly two or all three of its bonds are open. -/
def triangleBondSpanningProbability (p : ℝ) : ℝ :=
  3 * p ^ 2 * (1 - p) + p ^ 3

/-- Site crossing of a three-site face and bond spanning of a three-edge face
have the same Bernoulli polynomial. -/
theorem triangleBondSpanningProbability_eq_site (p : ℝ) :
    triangleBondSpanningProbability p = triangleSiteCrossingProbability p := by
  unfold triangleBondSpanningProbability triangleSiteCrossingProbability
  ring

/-- Thus the local triangular bond spanning equation is also fair exactly at
`p = 1/2`. -/
theorem triangleBondSpanningProbability_eq_half_iff {p : ℝ}
    (hp0 : 0 ≤ p) (hp1 : p ≤ 1) :
    triangleBondSpanningProbability p = 1 / 2 ↔ p = 1 / 2 := by
  rw [triangleBondSpanningProbability_eq_site]
  exact triangleSiteCrossingProbability_eq_half_iff hp0 hp1

end PercolationThreshold