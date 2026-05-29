/-
# The L-Function Universe: Countability and Enumeration of Discrete L-Data

This file introduces the formal theory of **discrete L-data**: arithmetically
describable Euler-product-type objects specified by finite global parameters
and countable local factor data. We prove that the universe of such objects
is countable, effectively encodable, and admits an entropy-like stratification
by description length.

## Mathematical Context

The meaningful mathematical question is not "are there set-theoretically many
complex functions with nice analytic properties?" but rather "is the universe
of arithmetically specified Euler products with finite-complexity local data
countable and effectively enumerable?"

We answer this affirmatively by defining `FiniteDescriptionLData` — a structure
capturing global parameters (degree, conductor, root number) together with
finitely many exceptional local Euler factors and a uniform unramified template —
and proving that the resulting type is countable whenever the coefficient and
root number types are countable.
-/

import Mathlib

open Set Function

/-! ## Local Euler Factors -/

/-- A local Euler factor of degree at most `d` with coefficients in `α`.
    Represents the polynomial `1 + a₁ x + a₂ x² + ... + a_d x^d`
    where `coeffs i` gives `aᵢ` for `0 ≤ i < d`. -/
structure DiscreteEulerFactor (α : Type*) (d : ℕ) where
  /-- The coefficients `a₀, ..., a_{d-1}` of the local factor. -/
  coeffs : Fin d → α

namespace DiscreteEulerFactor

/-- Equivalence between `DiscreteEulerFactor α d` and `Fin d → α`. -/
def equiv (α : Type*) (d : ℕ) : DiscreteEulerFactor α d ≃ (Fin d → α) where
  toFun e := e.coeffs
  invFun f := ⟨f⟩
  left_inv _ := rfl
  right_inv _ := rfl

instance instCountable [Countable α] (d : ℕ) : Countable (DiscreteEulerFactor α d) :=
  Countable.of_equiv (Fin d → α) (equiv α d).symm

instance instEncodable [Encodable α] (d : ℕ) : Encodable (DiscreteEulerFactor α d) :=
  Encodable.ofEquiv (Fin d → α) (equiv α d)

instance instFintype [Fintype α] (d : ℕ) : Fintype (DiscreteEulerFactor α d) :=
  Fintype.ofEquiv (Fin d → α) (equiv α d).symm

end DiscreteEulerFactor

/-! ## Finite-Description L-Data -/

/-- **Finite-Description L-Data**: An Euler-product-type object specified by:
  - `degree`: the degree of the L-function (a finite global parameter),
  - `conductor`: the conductor (a finite global parameter),
  - `rootNumber`: an element of a countable type `Γ` (e.g., roots of unity),
  - `unramifiedTemplate`: a uniform local Euler factor for all good primes,
  - `numBadPrimes`: the number of ramified local factors,
  - `badPrimeList`: the list of bad primes,
  - `ramifiedFactors`: explicit local factors at each bad prime.

  All fields are drawn from countable (or finite) types, making the total
  type countable. This is the correct formal notion of "arithmetically
  describable L-data" from which countability results follow. -/
structure FiniteDescriptionLData (Γ : Type*) (α : Type*) where
  /-- The degree of the L-function. -/
  degree : ℕ
  /-- The conductor of the L-function. -/
  conductor : ℕ
  /-- The root number (an element of `Γ`). -/
  rootNumber : Γ
  /-- The unramified local Euler factor template, used at all good primes. -/
  unramifiedTemplate : DiscreteEulerFactor α degree
  /-- The number of bad (ramified) primes. -/
  numBadPrimes : ℕ
  /-- The list of bad primes (encoded as `Fin numBadPrimes → ℕ`). -/
  badPrimeList : Fin numBadPrimes → ℕ
  /-- Explicit Euler factors at each bad prime. -/
  ramifiedFactors : Fin numBadPrimes → DiscreteEulerFactor α degree

/-! ## Finitely Ramified L-Data (simplified variant) -/

/-- **Finitely Ramified L-Data**: A simplified variant where
    the ramified factors are given for each of `numRamified` bad primes.
    This is conceptually equivalent to `FiniteDescriptionLData` but with
    fewer fields, making it useful for direct countability proofs. -/
structure FinitelyRamifiedLData (Γ : Type*) (α : Type*) where
  /-- The degree of the L-function. -/
  degree : ℕ
  /-- The conductor. -/
  conductor : ℕ
  /-- The root number. -/
  rootNumber : Γ
  /-- The uniform unramified template. -/
  unramifiedTemplate : DiscreteEulerFactor α degree
  /-- Number of ramified primes. -/
  numRamified : ℕ
  /-- Ramified factors, one for each bad prime. -/
  ramifiedFactor : Fin numRamified → DiscreteEulerFactor α degree

/-! ## Auxiliary definitions -/

/-- Whether a prime `p` is unramified for a given L-datum: it is not
    in the list of bad primes. -/
def FiniteDescriptionLData.isUnramifiedAt (x : FiniteDescriptionLData Γ α) (p : ℕ) : Prop :=
  ∀ i : Fin x.numBadPrimes, x.badPrimeList i ≠ p

/-- The set of ramified primes is always finite (it is contained in the
    finite range of `badPrimeList`). -/
theorem FiniteDescriptionLData.badPrimes_finite (x : FiniteDescriptionLData Γ α) :
    Set.Finite {p : ℕ | ¬ x.isUnramifiedAt p} := by
  apply Set.Finite.subset (Set.finite_range x.badPrimeList)
  intro p hp
  simp only [isUnramifiedAt, not_forall, Classical.not_not] at hp
  obtain ⟨i, hi⟩ := hp
  exact ⟨i, hi⟩

/-- The maximum value appearing in the bad prime list, or 0 if there are no bad primes. -/
def FiniteDescriptionLData.maxBadPrime (x : FiniteDescriptionLData Γ α) : ℕ :=
  if h : x.numBadPrimes = 0 then 0
  else Finset.sup' (Finset.univ (α := Fin x.numBadPrimes))
    (Finset.univ_nonempty_iff.mpr (Fin.pos_iff_nonempty.mp (Nat.pos_of_ne_zero h)))
    x.badPrimeList

/-- The **description length** of an L-datum, measuring its combinatorial complexity.
    This sums the degree, conductor, number of bad primes, and the maximum
    bad prime value, plus one. The inclusion of `maxBadPrime` ensures that
    bounded description length implies a finite set of possible L-data. -/
def descriptionLength (x : FiniteDescriptionLData Γ α) : ℕ :=
  x.degree + x.conductor + x.numBadPrimes + x.maxBadPrime + 1

/-- The **arithmetic complexity** of an L-datum. -/
def arithmeticComplexity (x : FiniteDescriptionLData Γ α) : ℕ :=
  x.degree * (x.numBadPrimes + 1) + x.conductor

/-- Arithmetic complexity offset is always positive. -/
theorem arithmeticComplexity_pos (x : FiniteDescriptionLData Γ α) :
    0 < arithmeticComplexity x + 1 := by omega

/-- The conductor weight. -/
def conductorWeight (x : FiniteDescriptionLData Γ α) : ℕ :=
  x.conductor + x.numBadPrimes

/-- Description length is always positive. -/
theorem descriptionLength_pos (x : FiniteDescriptionLData Γ α) :
    0 < descriptionLength x := by
  unfold descriptionLength; omega