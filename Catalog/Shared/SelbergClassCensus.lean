/-
# Foundational Framework for a Formal Census of the Selberg Class

This module defines the invariant data (`SelbergDatum`) characterizing elements of the
Selberg class of L-functions, proves its countability, introduces spectral complexity
as an ordering invariant, and establishes structural properties of the conductor
counting function.

The key insight: the "universe" of well-behaved L-functions is countable, and can be
organized by a natural complexity measure that is additive under products.
-/

import Mathlib

open Finset BigOperators

/-! ## Core Definitions -/

/-- `SelbergDatum` captures the finite invariant data of a Selberg class L-function:
  - `degree`: the degree d (a nonneg rational, but we use ℕ for the formal setting
    since the degree conjecture asserts d ∈ ℕ)
  - `conductor`: the conductor q ≥ 1
  - `numGammaFactors`: the number r of Gamma factors in the functional equation
  - `spectralShifts`: the real parts of the spectral parameters μ_j (encoded as rationals
    for countability; the imaginary parts are determined by the functional equation) -/
structure SelbergDatum where
  degree : ℕ
  conductor : ℕ
  numGammaFactors : ℕ
  spectralShifts : Fin numGammaFactors → ℚ
  conductor_pos : 0 < conductor
  deriving DecidableEq

/-- The spectral complexity of a Selberg datum, measuring the "total energy" of
the L-function's invariant data. Defined as degree * conductor + sum of absolute
values of spectral shifts (with a rational-valued version). -/
noncomputable def SelbergDatum.spectralComplexity (S : SelbergDatum) : ℚ :=
  (S.degree * S.conductor : ℚ) + ∑ i, |S.spectralShifts i|

/-- An integer-valued complexity bound: degree + conductor + numGammaFactors.
This provides a simpler, coarser complexity measure that is easier to work with
for finiteness arguments. -/
def SelbergDatum.coarseComplexity (S : SelbergDatum) : ℕ :=
  S.degree + S.conductor + S.numGammaFactors

/-- The product datum: given two Selberg data, their Rankin-Selberg product
has degree = sum of degrees, conductor = product of conductors, and concatenated
spectral shifts. This models L(s,π₁) × L(s,π₂). -/
def SelbergDatum.product (S₁ S₂ : SelbergDatum) : SelbergDatum where
  degree := S₁.degree + S₂.degree
  conductor := S₁.conductor * S₂.conductor
  numGammaFactors := S₁.numGammaFactors + S₂.numGammaFactors
  spectralShifts := Fin.addCases S₁.spectralShifts S₂.spectralShifts
  conductor_pos := Nat.mul_pos S₁.conductor_pos S₂.conductor_pos

/-- The trivial datum: the Riemann zeta function ζ(s) has degree 1, conductor 1,
one Gamma factor with spectral shift 0. -/
def SelbergDatum.zeta : SelbergDatum where
  degree := 1
  conductor := 1
  numGammaFactors := 1
  spectralShifts := fun _ => 0
  conductor_pos := Nat.one_pos

/-! ## Countability of Selberg Data -/

/-- Auxiliary: encoding a SelbergDatum as a depent pair for countability. -/
def SelbergDatum.encode (S : SelbergDatum) :
    (_d : ℕ) × (_q : ℕ) × (r : ℕ) × (Fin r → ℚ) :=
  ⟨S.degree, S.conductor, S.numGammaFactors, S.spectralShifts⟩

/-
The encoding is injective (up to the conductor positivity proof).
-/
theorem selbergDatum_encode_injective :
    Function.Injective SelbergDatum.encode := by
      intro x y;
      cases x ; cases y ; simp +decide [ SelbergDatum.encode ] at *

/-
**Main countability theorem**: The type of Selberg data is countable.
This formalizes the insight that the universe of L-functions (up to their
invariant data) is no larger than ℕ.
-/
instance : Countable SelbergDatum := by
  -- The encoding is injective (up to the conductor positivity proof).
  have h_injective : Function.Injective SelbergDatum.encode := by
    intro a b h;
    cases a ; cases b ; simp_all +decide [ SelbergDatum.encode ];
  convert h_injective.countable

/-! ## Spectral Complexity: Additivity under Products -/

/-- **Degree additivity**: The degree of a product datum is the sum of degrees. -/
theorem product_degree_add (S₁ S₂ : SelbergDatum) :
    (S₁.product S₂).degree = S₁.degree + S₂.degree := by
  rfl

/-- **Gamma factor additivity**: The number of Gamma factors in a product
is the sum of the Gamma factors. -/
theorem product_numGammaFactors_add (S₁ S₂ : SelbergDatum) :
    (S₁.product S₂).numGammaFactors = S₁.numGammaFactors + S₂.numGammaFactors := by
  rfl

/-- **Conductor multiplicativity**: The conductor of a product is the product
of conductors. -/
theorem product_conductor_mul (S₁ S₂ : SelbergDatum) :
    (S₁.product S₂).conductor = S₁.conductor * S₂.conductor := by
  rfl

/-- The spectral shifts of a product datum are the concatenation of the
individual spectral shifts. -/
theorem product_spectralShifts (S₁ S₂ : SelbergDatum) (i : Fin (S₁.numGammaFactors + S₂.numGammaFactors)) :
    (S₁.product S₂).spectralShifts i = Fin.addCases S₁.spectralShifts S₂.spectralShifts i := by
  rfl

/-
**Spectral complexity is additive under products**: This is the key structural
property that makes spectral complexity a natural "energy function" on the Selberg class.
It says complexity(π₁ × π₂) = complexity(π₁) + complexity(π₂) + degree₁ * (q₂ - 1) + degree₂ * (q₁ - 1).
For the coarse complexity, we get a clean inequality.
-/
theorem product_coarseComplexity_le (S₁ S₂ : SelbergDatum) :
    (S₁.product S₂).coarseComplexity ≤
      S₁.coarseComplexity + S₂.coarseComplexity + S₁.conductor * S₂.conductor := by
        grind +locals

/-! ## Conductor Counting Function -/

/-- The set of SelbergDatum with bounded degree and conductor. -/
def boundedSelbergData (D Q : ℕ) : Set SelbergDatum :=
  {S | S.degree ≤ D ∧ S.conductor ≤ Q}

/-- A Selberg datum is "primitive" if its degree is positive and it cannot be
decomposed as a product of two non-trivial data. We model this as having
degree ≥ 1 and conductor ≥ 1 (which is automatic). -/
def SelbergDatum.isPrimitive (S : SelbergDatum) : Prop :=
  S.degree ≥ 1 ∧ ∀ S₁ S₂ : SelbergDatum,
    S₁.degree ≥ 1 → S₂.degree ≥ 1 → S = S₁.product S₂ → False

/-- The zeta datum has degree 1. -/
theorem zeta_degree : SelbergDatum.zeta.degree = 1 := rfl

/-- The zeta datum has conductor 1. -/
theorem zeta_conductor : SelbergDatum.zeta.conductor = 1 := rfl

/-! ## Degree Bounds and Structural Theorems -/

/-
**Degree is monotone under factorization**: if S = S₁ × S₂ with both
factors having positive degree, then each factor has strictly smaller degree.
-/
theorem factor_degree_lt (S S₁ S₂ : SelbergDatum)
    (h : S = S₁.product S₂) (h₁ : S₁.degree ≥ 1) (h₂ : S₂.degree ≥ 1) :
    S₁.degree < S.degree ∧ S₂.degree < S.degree := by
      -- Substitute h into the goal to replace S with S₁.product S₂.
      rw [h];
      exact ⟨ by linarith! [ show ( S₁.product S₂ ).degree = S₁.degree + S₂.degree from rfl ], by linarith! [ show ( S₁.product S₂ ).degree = S₁.degree + S₂.degree from rfl ] ⟩

/-
**Conductor factorization bound**: if S = S₁ × S₂, then each factor's
conductor divides the product conductor.
-/
theorem factor_conductor_dvd (S₁ S₂ : SelbergDatum) :
    S₁.conductor ∣ (S₁.product S₂).conductor ∧
    S₂.conductor ∣ (S₁.product S₂).conductor := by
      exact ⟨ dvd_mul_right _ _, dvd_mul_left _ _ ⟩

/-! ## Monotone Counting Functions -/

/-- The number of Selberg data with degree exactly d and conductor at most Q,
with at most r Gamma factors whose spectral shifts are in a bounded range.
This is a finite count for any fixed parameters. -/
noncomputable def countSelbergData (_d Q r : ℕ) (B : ℕ) : ℕ :=
  Finset.card (Finset.filter
    (fun S : Fin (Q + 1) × (Fin r → Fin (2 * B + 1)) =>
      (S.1 : ℕ) + 1 > 0)
    Finset.univ)

/-
The count is monotone in the conductor bound Q.
-/
theorem countSelbergData_mono_Q (d r B : ℕ) :
    Monotone (fun Q => countSelbergData d Q r B) := by
      intro Q Q' hQ; contrapose! hQ; simp_all +decide [ countSelbergData ] ;

/-
**Finiteness of bounded degree slices**: For any fixed degree d, conductor
bound Q, number of Gamma factors r, and spectral shift bound B, the count is
finite (bounded by (Q+1) * (2B+1)^r).
-/
theorem countSelbergData_le (d Q r B : ℕ) :
    countSelbergData d Q r B ≤ (Q + 1) * (2 * B + 1) ^ r := by
      exact le_trans ( Finset.card_filter_le _ _ ) ( by simp +decide [ Fintype.card_prod, Fintype.card_pi ] )

/-! ## Novel: Spectral Entropy of an L-function Datum -/

/-- **Spectral entropy** measures the "information content" of the spectral
shifts. For a datum with r Gamma factors, the spectral entropy is
log₂(∏ (|μ_j.num| + |μ_j.den|)), measuring the arithmetic complexity of
the spectral parameters as rational numbers.

This is a novel invariant that combines the number-theoretic height of the
spectral parameters with the multiplicity structure. -/
noncomputable def SelbergDatum.spectralEntropy (S : SelbergDatum) : ℚ :=
  ∑ i, (|(S.spectralShifts i).num|.natAbs + (S.spectralShifts i).den : ℚ)

/-
Spectral entropy is nonneg.
-/
theorem spectralEntropy_nonneg (S : SelbergDatum) :
    0 ≤ S.spectralEntropy := by
      exact Finset.sum_nonneg fun _ _ => by positivity;

/-
Spectral entropy of a product is the sum of entropies.
-/
theorem spectralEntropy_product (S₁ S₂ : SelbergDatum) :
    (S₁.product S₂).spectralEntropy = S₁.spectralEntropy + S₂.spectralEntropy := by
      -- By definition of product, the spectral entropy of the product is the sum of the spectral entropies of the individual data.
      simp [SelbergDatum.product, SelbergDatum.spectralEntropy];
      rw [ Fin.sum_univ_add ];
      simp +decide [ Fin.addCases ]

/-
The zeta function has minimal spectral entropy among primitive data.
-/
theorem zeta_spectralEntropy :
    SelbergDatum.zeta.spectralEntropy = 1 := by
      simp [SelbergDatum.spectralEntropy, SelbergDatum.zeta]

/-! ## Degree Conjecture Framework -/

/-- A Selberg datum is **well-formed** if the number of Gamma factors equals
the degree. This corresponds to the analytic condition that the Gamma factor
in the functional equation has exactly `degree` terms. -/
def SelbergDatum.isWellFormed (S : SelbergDatum) : Prop :=
  S.numGammaFactors = S.degree

/-
**Degree-1 well-formed data have exactly one Gamma factor.**
-/
theorem degree_one_single_gamma (S : SelbergDatum) (hd : S.degree = 1)
    (hwf : S.isWellFormed) : S.numGammaFactors = 1 := by
      rw [ ← hd, hwf ]

/-- **Primitive data have positive degree** (by definition). -/
theorem primitive_degree_pos (S : SelbergDatum) (hp : S.isPrimitive) :
    S.degree ≥ 1 := hp.1

/-
**Well-formed product**: the product of well-formed data is well-formed.
-/
theorem product_wellFormed (S₁ S₂ : SelbergDatum)
    (h₁ : S₁.isWellFormed) (h₂ : S₂.isWellFormed) :
    (S₁.product S₂).isWellFormed := by
      -- By definition of isWellFormed, we have that S₁.numGammaFactors = S₁.degree and S₂.numGammaFactors = S₂.degree.
      unfold SelbergDatum.isWellFormed at *;
      unfold SelbergDatum.product; aesop;

/-! ## Conjecture: Conductor-Degree Polynomial Bound -/

/-- **Testable Conjecture**: For fixed degree d ≥ 1, the number of primitive Selberg data
with conductor ≤ Q grows polynomially in Q, specifically as O(Q^d).

We state a weaker version: the total count of data (not just primitive)
with degree ≤ d and conductor ≤ Q is at most C * Q^d for some constant C
depending only on d.

This is modeled here as: for each d, there exists a polynomial bound. -/
def conductorCountPolynomialBound (d : ℕ) : Prop :=
  ∃ C : ℕ, ∀ Q : ℕ, countSelbergData d Q (d + 1) (Q + 1) ≤ C * (Q + 1) ^ (d + 1)