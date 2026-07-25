import Mathlib

/-!
# Observation maps turn dynamical recurrence into arithmetic divisibility

A semiconjugacy `obs` satisfies `obs (f x) = g (obs x)`: it models observing a
state evolving under `f` through a possibly lossy measurement evolving under
`g`.  This file proves that observation induces an order map from pointwise
minimal periods to the divisibility poset.  No compactness, metrizability, or
finite-fiber assumption is needed.

The converse direction detects information loss.  If the observation is
injective, the arithmetic divisor cannot be proper, so exact periods are
preserved.  A prime-period corollary gives a sharp dichotomy: a lossy
observation of a prime cycle either retains the whole cycle or collapses it to
a fixed point.
-/

namespace ObservationPeriodDivisibility

open Function

variable {X Y : Type*} {f : X → X} {g : Y → Y} {obs : X → Y}

/-- Every semiconjugacy sends the minimal period of a state to a divisor of the
original minimal period.  This is stronger than the finite-to-one version:
finite fibers are not required. -/
theorem observed_minimalPeriod_dvd (hsem : Semiconj obs f g) (x : X) :
    minimalPeriod g (obs x) ∣ minimalPeriod f x := by
  apply IsPeriodicPt.minimalPeriod_dvd
  exact (isPeriodicPt_minimalPeriod f x).map hsem

/-- An injective observation reflects every periodicity equation. -/
theorem periodicPt_reflect_of_injective (hsem : Semiconj obs f g)
    (hinj : Injective obs) {x : X} {n : ℕ}
    (hperiodic : IsPeriodicPt g n (obs x)) : IsPeriodicPt f n x := by
  apply hinj
  rw [hsem.iterate_right n]
  exact hperiodic

/-- Faithful observations preserve pointwise minimal periods exactly. -/
theorem minimalPeriod_eq_of_injective (hsem : Semiconj obs f g)
    (hinj : Injective obs) (x : X) :
    minimalPeriod g (obs x) = minimalPeriod f x := by
  rw [minimalPeriod_eq_minimalPeriod_iff]
  intro n
  constructor
  · exact periodicPt_reflect_of_injective hsem hinj
  · intro h
    exact h.map hsem

/-- Consequently, an injective semiconjugacy preserves every exact-period
stratum pointwise. -/
theorem exact_period_transport_of_injective (hsem : Semiconj obs f g)
    (hinj : Injective obs) (x : X) (n : ℕ) :
    minimalPeriod f x = n ↔ minimalPeriod g (obs x) = n := by
  rw [minimalPeriod_eq_of_injective hsem hinj x]

/-- Arithmetic rigidity of prime cycles: a periodic state of prime minimal
period can only be observed as a fixed point or as a cycle of the same prime
period.  This explicitly connects recurrence under observation with the
number-theoretic divisor structure of a prime. -/
theorem prime_period_observation_dichotomy (hsem : Semiconj obs f g) (x : X)
    {p : ℕ} (hp : p.Prime) (hperiod : minimalPeriod f x = p) :
    minimalPeriod g (obs x) = 1 ∨ minimalPeriod g (obs x) = p := by
  have hdiv : minimalPeriod g (obs x) ∣ p := by
    rw [← hperiod]
    exact observed_minimalPeriod_dvd hsem x
  exact hp.eq_one_or_self_of_dvd _ hdiv

/-- A faithful observation rules out the collapse branch in the prime-period
dichotomy. -/
theorem prime_period_preserved_of_injective (hsem : Semiconj obs f g)
    (hinj : Injective obs) (x : X) {p : ℕ}
    (hperiod : minimalPeriod f x = p) :
    minimalPeriod g (obs x) = p := by
  rw [minimalPeriod_eq_of_injective hsem hinj x, hperiod]

end ObservationPeriodDivisibility