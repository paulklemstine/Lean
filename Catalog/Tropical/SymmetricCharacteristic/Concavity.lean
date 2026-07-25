import Mathlib
import Tropical.Core.TropicalSemiringProperties

/-!
# Concavity Certificates for Tropical Characteristic Coefficients

For a max-plus matrix, the coefficient of degree complementary to `k` is the
largest tropical permanent of a `k × k` principal submatrix.  The central
combinatorial issue is therefore not polynomial manipulation but exchange
between principal index sets.  This file isolates that mechanism.

A `PrincipalCoefficientSystem` records principal weights, attained coefficient
maxima, and the symmetric two-set exchange inequality.  Its main theorem says
that the coefficient sequence is discretely concave.  Further results turn the
local inequalities into global monotonicity of slopes, linking tropical matrix
coefficients with discrete convex analysis.
-/

open Finset

namespace TropicalSymmetricCharacteristic

variable {α : Type*} [Fintype α] [DecidableEq α]

/-- Tropical addition commutes with translation.  This elementary max-plus law
explains why a uniform matrix-weight shift acts affinely on coefficients. -/
theorem translate_tropical_sum (a x y : ℝ) :
    a + max x y = max (a + x) (a + y) := by
  exact TropicalSemiringProperties.tropical_scalar_distrib a x y

/-- Data sufficient to recognize the principal-permanent coefficient sequence.
`weight S` is intended to be the tropical permanent of the principal submatrix
on `S`, while `coeff k` is its maximum among sets of cardinality `k`.

The exchange field is the symmetric-matrix input: a smaller and a larger
principal set can be modified to two intermediate-size sets without decreasing
the total weight. -/
structure PrincipalCoefficientSystem (α : Type*) [Fintype α] [DecidableEq α] where
  weight : Finset α → ℤ
  coeff : ℕ → ℤ
  upper : ∀ S, weight S ≤ coeff S.card
  attained : ∀ k, k ≤ Fintype.card α → ∃ S : Finset α, S.card = k ∧ weight S = coeff k
  exchange : ∀ (S T : Finset α), S.card + 2 = T.card →
    ∃ U V : Finset α,
      U.card = S.card + 1 ∧ V.card = S.card + 1 ∧
      weight S + weight T ≤ weight U + weight V

/-- Discrete concavity at index `k`: the middle term lies above the midpoint
of its two neighbors. -/
def DiscretelyConcaveAt (c : ℕ → ℤ) (k : ℕ) : Prop :=
  c k + c k ≥ c (k - 1) + c (k + 1)

/-- Discrete concavity on every interior index of a finite coefficient vector. -/
def DiscretelyConcaveThrough (c : ℕ → ℤ) (n : ℕ) : Prop :=
  ∀ k, 1 ≤ k → k < n → DiscretelyConcaveAt c k

/-- The symmetric principal-exchange inequality forces midpoint concavity of
all interior coefficients. -/
theorem principal_coefficients_concave
    (P : PrincipalCoefficientSystem α) :
    DiscretelyConcaveThrough P.coeff (Fintype.card α) := by
  intro k hk hkn
  obtain ⟨S, hScard, hSmax⟩ := P.attained (k - 1) (by omega)
  obtain ⟨T, hTcard, hTmax⟩ := P.attained (k + 1) (by omega)
  have hgap : S.card + 2 = T.card := by omega
  obtain ⟨U, V, hUcard, hVcard, hex⟩ := P.exchange S T hgap
  have hUcard' : U.card = k := by omega
  have hVcard' : V.card = k := by omega
  have hU : P.weight U ≤ P.coeff k := by
    simpa [hUcard'] using P.upper U
  have hV : P.weight V ≤ P.coeff k := by
    simpa [hVcard'] using P.upper V
  dsimp [DiscretelyConcaveAt]
  rw [← hSmax, ← hTmax]
  linarith

/-- Midpoint concavity is equivalent to nonincreasing consecutive slopes. -/
theorem concaveAt_iff_slope_antitone (c : ℕ → ℤ) (k : ℕ) (_hk : 1 ≤ k) :
    DiscretelyConcaveAt c k ↔
      c (k + 1) - c k ≤ c k - c (k - 1) := by
  unfold DiscretelyConcaveAt
  omega

/-- Local coefficient concavity makes all later slopes no larger than all
 earlier slopes.  This is the global discrete-convexity consequence used by
Newton-polygon arguments. -/
theorem slopes_antitone_of_concave
    {c : ℕ → ℤ} {n i j : ℕ}
    (hc : DiscretelyConcaveThrough c n)
    (hi : 1 ≤ i) (hij : i ≤ j) (hj : j < n) :
    c (j + 1) - c j ≤ c i - c (i - 1) := by
  induction j, hij using Nat.le_induction with
  | base => exact (concaveAt_iff_slope_antitone c i hi).mp (hc i hi hj)
  | succ j hij ih =>
      have hj1 : 1 ≤ j + 1 := by omega
      have hlocal := (concaveAt_iff_slope_antitone c (j + 1) hj1).mp
        (hc (j + 1) hj1 (by omega))
      have hpred : j + 1 - 1 = j := by omega
      rw [hpred] at hlocal
      exact le_trans hlocal (ih (by omega))

/-- Any coefficient sequence represented by a principal exchange system has
nonincreasing slopes across arbitrary index gaps. This is a global necessary
condition for symmetric tropical characteristic polynomials. -/
theorem necessary_global_slope_order
    (P : PrincipalCoefficientSystem α) {i j : ℕ}
    (hi : 1 ≤ i) (hij : i ≤ j) (hj : j < Fintype.card α) :
    P.coeff (j + 1) - P.coeff j ≤
      P.coeff i - P.coeff (i - 1) := by
  exact slopes_antitone_of_concave
    (principal_coefficients_concave P) hi hij hj

/-! ## Concrete examples and boundary tests -/

/-- The quadratic profile is a strict model of the coefficient inequalities. -/
def quadraticProfile (k : ℕ) : ℤ := -((k : ℤ) ^ 2)

example (k : ℕ) (hk : 1 ≤ k) :
    DiscretelyConcaveAt quadraticProfile k := by
  unfold DiscretelyConcaveAt quadraticProfile
  push_cast
  have : (k - 1 : ℕ) + 1 = k := by omega
  nlinarith

/-- Concavity is invariant under tropical scaling: adding an affine function
of the index changes every slope by a constant. -/
theorem concavity_affine_invariant
    {c : ℕ → ℤ} {a b : ℤ} {n : ℕ}
    (hc : DiscretelyConcaveThrough c n) :
    DiscretelyConcaveThrough (fun k => c k + a * (k : ℤ) + b) n := by
  intro k hk hkn
  specialize hc k hk hkn
  unfold DiscretelyConcaveAt at hc ⊢
  have hpred : ((k - 1 : ℕ) : ℤ) = (k : ℤ) - 1 := by omega
  push_cast
  rw [hpred]
  nlinarith

/-- Boundary case: a single failed midpoint inequality rules out every
principal-exchange realization of the proposed coefficient sequence. -/
theorem obstruction_of_midpoint_failure
    (c : ℕ → ℤ) (n k : ℕ) (hk : 1 ≤ k) (hkn : k < n)
    (hfail : c k + c k < c (k - 1) + c (k + 1)) :
    ¬ DiscretelyConcaveThrough c n := by
  intro hc
  have := hc k hk hkn
  unfold DiscretelyConcaveAt at this
  omega

example : ¬ DiscretelyConcaveThrough (fun k => if k = 2 then (10 : ℤ) else 0) 4 := by
  apply obstruction_of_midpoint_failure _ _ 1 (by omega) (by omega)
  norm_num

-- !-- Lab Notes -- !--
-- Hypothesis (Hypothesizer): Symmetric principal-permanent exchange should imply
-- not merely adjacent midpoint inequalities, but all-gap slope inequalities;
-- affine tropical rescaling should preserve the hierarchy. Bold extensions
-- considered were ultrametric reconstruction and valuated-matroid realization.
--
-- Experiment (Experimenter): The exchange axiom was separated from matrix
-- notation and tested against a strict quadratic profile and a spike profile.
-- The spike supplies a concrete counterexample to unrestricted realizability.
--
-- Analysis (Analyst): Attainment plus two-set exchange is exactly the local
-- engine. Adjacent concavity is equivalent to decreasing slopes, and induction
-- transports this comparison across arbitrary gaps.
-- This connects tropical permanents, discrete convex analysis, and Newton
-- polygons without imposing positivity assumptions on matrix entries.
--
-- Critique (Critic): The exchange property is a genuine hypothesis, not proved
-- here for every possible notion of symmetric tropical matrix. Thus the result
-- is a recognition theorem for systems carrying the paper's exchange mechanism,
-- not an unconditional matrix theorem. Endpoints are excluded because no two
-- neighboring coefficients exist there. The examples are non-definitional and
-- the main arguments use attained witnesses, induction, and ordered arithmetic.
--
-- Synthesis (Principal Investigator): Local exchange, global slope monotonicity,
-- affine invariance, and an explicit obstruction form one
-- reusable hierarchy. The arXiv signal specifically motivated treating leading
-- principal-permanent coefficients as maxima over cardinality layers.
-- Generalization: the same proof works for any ordered additive coefficient
-- group with suitable finite-sum arithmetic; a broader extension should derive
-- the exchange field directly from cycle decompositions of symmetric matrices.
-- Boundary: nonsymmetric weights need not admit the two-set exchange, and a
-- midpoint spike is the minimal falsifying pattern.
-- !-- End Lab Notes -- !--

end TropicalSymmetricCharacteristic