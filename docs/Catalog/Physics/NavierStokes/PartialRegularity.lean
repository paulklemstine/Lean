/-
# An abstract ε-regularity reduction for Navier–Stokes

The full three-dimensional existence-and-smoothness problem is open.  This file
therefore does not assert global smoothness.  It isolates, in a form reusable by
a future analytic formalization of suitable weak solutions, the final
measure-theoretic mechanism in an ε-regularity/partial-regularity argument.

`excess` represents a scale-invariant local quantity (in the CKN setting, a
combination of velocity and pressure integrals over parabolic cylinders).
An ε-regularity hypothesis says that small excess at one scale implies
regularity.  The results below prove that every singular point has excess at
least ε at every scale, and transfer any null-set estimate for that
concentration set to the singular set.
-/

import Mathlib

open Set MeasureTheory

namespace NavierStokes
namespace PartialRegularity

variable {Z : Type*}

/-- Data entering an abstract epsilon-regularity criterion.  The strict
positivity of `epsilon` records that this is a genuine threshold. -/
structure Criterion (Z : Type*) where
  regularAt : Z → Prop
  excess : Z → ℝ → ℝ
  epsilon : ℝ
  epsilon_pos : 0 < epsilon
  regular_of_small : ∀ z : Z,
    (∃ r : ℝ, 0 < r ∧ excess z r < epsilon) → regularAt z

/-- The singular set associated with a regularity predicate. -/
def Criterion.singularSet (C : Criterion Z) : Set Z := {z | ¬ C.regularAt z}

/-- Points where the scale-invariant excess remains concentrated at every
positive scale. -/
def Criterion.concentrationSet (C : Criterion Z) : Set Z :=
  {z | ∀ r : ℝ, 0 < r → C.epsilon ≤ C.excess z r}

/-- Contrapositive core of epsilon regularity: at a singular point, no
positive scale can have excess below the regularity threshold. -/
theorem Criterion.singular_excess_lower_bound (C : Criterion Z) {z : Z}
    (hz : z ∈ C.singularSet) {r : ℝ} (hr : 0 < r) :
    C.epsilon ≤ C.excess z r := by
  by_contra h
  have hsmall : C.excess z r < C.epsilon := lt_of_not_ge h
  exact hz (C.regular_of_small z ⟨r, hr, hsmall⟩)

/-- The singular set is contained in the concentration set.  This is the
set-theoretic bridge used in covering proofs of partial regularity. -/
theorem Criterion.singularSet_subset_concentrationSet (C : Criterion Z) :
    C.singularSet ⊆ C.concentrationSet := by
  intro z hz r hr
  exact C.singular_excess_lower_bound hz hr

/-- Abstract partial regularity conclusion: if the concentration set is null
for a measure, then the singular set is null for that measure as well.  In a
CKN development the measure supplied here is the relevant parabolic Hausdorff
measure after the analytic covering estimate has been established. -/
theorem Criterion.singularSet_measure_zero [MeasurableSpace Z]
    (C : Criterion Z) (μ : Measure Z)
    (hconcentration : μ C.concentrationSet = 0) :
    μ C.singularSet = 0 := by
  exact measure_mono_null C.singularSet_subset_concentrationSet hconcentration

/-- A localized version: a null estimate for concentrated points inside a
region immediately gives partial regularity in that region. -/
theorem Criterion.singularSet_inter_measure_zero [MeasurableSpace Z]
    (C : Criterion Z) (μ : Measure Z) (region : Set Z)
    (hconcentration : μ (C.concentrationSet ∩ region) = 0) :
    μ (C.singularSet ∩ region) = 0 := by
  apply measure_mono_null _ hconcentration
  exact inter_subset_inter_left region C.singularSet_subset_concentrationSet

/-- Almost-everywhere formulation of the same partial regularity statement. -/
theorem Criterion.regularAt_ae [MeasurableSpace Z]
    (C : Criterion Z) (μ : Measure Z)
    (hconcentration : μ C.concentrationSet = 0) :
    ∀ᵐ z ∂μ, C.regularAt z := by
  rw [ae_iff]
  simpa [Criterion.singularSet] using C.singularSet_measure_zero μ hconcentration

end PartialRegularity
end NavierStokes