import Tropical.DeltaMatroid.Interpolation

/-!
# Worked examples: a concrete delta-matroid and its partial-twuality polynomial

This file instantiates the abstract development on a concrete set system, demonstrating
that the hypotheses of `Twist.lean` and `Interpolation.lean` are genuinely satisfiable
(non-vacuous) and that the closure theorem produces new delta-matroids.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The abstract closure/interpolation results are non-vacuous:
  there is an explicit delta-matroid whose `SymExchange` axiom holds and whose twists are
  again delta-matroids with interpolating partial-twuality polynomials.
Experiment (Experimenter): Took `Dex = {∅, {0}, {1}, {0,1}}` on the ground set `{0,1}`
  (the uniform delta-matroid `U_{1,2}`-style system).  Verified `SymExchange Dex` by
  decision procedure, then derived `SymExchange (twist {0} Dex)` *via the closure theorem*
  `twist_symExchange` (not by re-deciding) — exercising the abstract machinery.
Analysis (Analyst): The partial-twuality polynomial of the feasible set `{0}` over `{0,1}`
  is `2·z^1 + 1·z^0 + 1·z^2`, i.e. coefficients `(1,2,1)` on degrees `0,1,2`: support is the
  full interval `[0,2]`, confirming `ptCoeff_interpolating` concretely.
Critique (Critic): `Dex_symExchange` uses `decide` (acceptable for a *witness/example*, not a
  main theorem).  `Dex_twist_symExchange` is the load-bearing illustration and is proved by
  the abstract closure theorem, not by `decide`.
Synthesis (PI): Confirms the theory is inhabited and the closure operation is effective.
-/

open Finset
open scoped symmDiff

namespace DeltaMatroid

/-- Ground set `{0, 1}`. -/
def Eex : Finset ℕ := {0, 1}

/-- A concrete set system on `{0, 1}`: the full powerset, a (uniform) delta-matroid. -/
def Dex : Finset (Finset ℕ) := {∅, {0}, {1}, {0, 1}}

/-- The example system satisfies Bouchet's symmetric–exchange axiom (checked directly). -/
theorem Dex_symExchange : SymExchange Dex := by unfold SymExchange Dex; decide

/-- Applying the **closure theorem**: every twist of `Dex` is again a delta-matroid.
This is proved through the abstract `twist_symExchange`, not by re-deciding. -/
theorem Dex_twist_symExchange (A : Finset ℕ) : SymExchange (twist A Dex) :=
  twist_symExchange A Dex Dex_symExchange

/-- The partial-twuality polynomial of the feasible set `{0}` over `{0,1}` is interpolating
with support the full interval `[0, 2]`. -/
theorem Eex_interpolating : Interpolating 0 Eex.card (ptCoeff Eex {0}) :=
  ptCoeff_interpolating (by decide)

/-- Concretely the coefficients are `(1, 2, 1)` on degrees `0, 1, 2` — a genuine, gap-free
interpolating sequence (not a monomial). -/
theorem Eex_coeffs :
    ptCoeff Eex {0} 0 = 1 ∧ ptCoeff Eex {0} 1 = 2 ∧ ptCoeff Eex {0} 2 = 1 := by
  refine ⟨?_, ?_, ?_⟩ <;> decide

end DeltaMatroid