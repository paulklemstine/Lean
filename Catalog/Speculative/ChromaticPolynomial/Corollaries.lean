import Mathlib
import Speculative.ChromaticPolynomial.Defs

/-!
# Chromatic Polynomial — Counting Corollaries

This file extends `Speculative.ChromaticPolynomial.Defs` (in particular the
fundamental evaluation theorem `SimpleGraph.eval_chromaticPolynomial`) with a
small, coherent layer of consequences that turn the *Whitney rank formula* into
usable counting and decision statements.

The unifying idea of the catalog's chromatic-polynomial package is that the
single algebraic object `chromaticPolynomial` simultaneously encodes:

* a *combinatorial counting function* (`numColorings`), and
* a *decision predicate* (`Colorable`, i.e. graph colourability).

Here we make both bridges precise and `sorry`-free, building only on top of the
catalog's `eval_chromaticPolynomial` rather than reproving any of it.

## Main Results

* `SimpleGraph.numColorings_eq_eval` — the count equals the polynomial evaluation
  (the catalog theorem, re-oriented for downstream use).
* `SimpleGraph.chromaticPolynomial_eval_nonneg` — evaluations at naturals are `≥ 0`.
* `SimpleGraph.exists_polynomial_numColorings` — `k ↦ numColorings k` is the
  restriction of a single integer polynomial (the *polynomiality* of the count).
* `SimpleGraph.colorable_iff_eval_pos` — graph colourability is detected by a
  strict sign condition on the chromatic polynomial.
* `SimpleGraph.numColorings_eq_of_chromaticPolynomial_eq` — chromatically
  equivalent graphs have identical colour counts at every `k`.
-/

-- !-- Lab Notebook -- !--
--
-- Hypothesis:  The fundamental evaluation theorem `eval_chromaticPolynomial`
--   (catalog: `Speculative.ChromaticPolynomial.Defs`) is strong enough to
--   recover, with no further graph-theoretic work, both the *polynomiality*
--   of the colour-counting function and a *spectral/sign* criterion for
--   colourability.  In other words, the Whitney rank formula should already
--   "contain" the decision problem.
--
-- Result:  Confirmed.  All five corollaries below reduce, by `rw`/`exact_mod_cast`,
--   to `eval_chromaticPolynomial` together with `numColorings_eq_card_coloring`
--   and `Fintype.card_pos_iff`.  No inclusion–exclusion is re-run.
--
-- Insight:  Casting between `ℕ`-valued cardinalities and `ℤ`-valued polynomial
--   evaluations is the only genuine friction; once the count is pinned as a
--   cast of `Fintype.card`, nonnegativity and the `0 < ·` ⇔ `Nonempty` step
--   are immediate.  The decision criterion `colorable_iff_eval_pos` is the
--   conceptual payoff: it converts a search ("is there a proper colouring?")
--   into an evaluation ("is `χ_G(k) > 0`?").
--
-- Failure analysis:  Stating nonnegativity directly over `ℤ` without first
--   re-expressing the evaluation as a cardinality cast loses the `positivity`
--   handle; the working route is always `← numColorings_eq_eval` first.
--
-- !-- Lab Notebook -- !--

open Polynomial Finset

namespace SimpleGraph

variable {V : Type*} [Fintype V] [DecidableEq V]

-- !-- The count is, by definition, the evaluation of the chromatic polynomial;
-- we just reorient the catalog's `eval_chromaticPolynomial`. -- !--
/-- The number of proper `k`-colourings, viewed in `ℤ`, is exactly the chromatic
polynomial evaluated at `k`. -/
theorem numColorings_eq_eval (G : SimpleGraph V) [DecidableRel G.Adj] (k : ℕ) :
    (G.numColorings k : ℤ) = Polynomial.eval (k : ℤ) G.chromaticPolynomial :=
  (G.eval_chromaticPolynomial k).symm

/-
!-- The evaluation is a cast of a natural-number cardinality, hence ≥ 0. -- !--

The chromatic polynomial takes nonnegative values at every natural number,
since each such value counts proper colourings.
-/
theorem chromaticPolynomial_eval_nonneg (G : SimpleGraph V) [DecidableRel G.Adj]
    (k : ℕ) : 0 ≤ Polynomial.eval (k : ℤ) G.chromaticPolynomial := by
      rw [ ← numColorings_eq_eval ];
      exact Nat.cast_nonneg _

-- !-- Witness the polynomial explicitly: `chromaticPolynomial` itself works,
-- by `eval_chromaticPolynomial`. -- !--
/-- **Polynomiality of the colour count.** There is a single integer polynomial
whose values at the naturals are the colour-counting function `k ↦ numColorings k`. -/
theorem exists_polynomial_numColorings (G : SimpleGraph V) [DecidableRel G.Adj] :
    ∃ p : Polynomial ℤ, ∀ k : ℕ, (G.numColorings k : ℤ) = p.eval (k : ℤ) :=
  ⟨G.chromaticPolynomial, fun k => (G.eval_chromaticPolynomial k).symm⟩

/-
!-- `Colorable k` ↔ `Nonempty (Coloring (Fin k))` ↔ `0 < card` ↔ `0 < numColorings k`
↔ `0 < eval k`, chaining `numColorings_eq_card_coloring`, `Fintype.card_pos_iff`,
and `numColorings_eq_eval`. -- !--

**Colourability criterion.** A finite graph is `k`-colourable iff its
chromatic polynomial is strictly positive at `k`.
-/
theorem colorable_iff_eval_pos (G : SimpleGraph V) [DecidableRel G.Adj] (k : ℕ) :
    G.Colorable k ↔ 0 < Polynomial.eval (k : ℤ) G.chromaticPolynomial := by
      rw [ ← numColorings_eq_eval ];
      norm_cast;
      constructor;
      · rintro ⟨ c, hc ⟩;
        exact Fintype.card_pos_iff.mpr ⟨ ⟨ c, fun u v huv => by simpa using hc huv ⟩ ⟩;
      · exact fun h => by rw [ numColorings_eq_card_coloring ] at h; exact Fintype.card_pos_iff.mp h;

/-
!-- Both counts equal the (now-equal) evaluations, so they agree; cast back to ℕ. -- !--

Two graphs on the same vertex type with equal chromatic polynomials have the
same number of proper `k`-colourings for every `k`.
-/
theorem numColorings_eq_of_chromaticPolynomial_eq (G H : SimpleGraph V)
    [DecidableRel G.Adj] [DecidableRel H.Adj]
    (h : G.chromaticPolynomial = H.chromaticPolynomial) (k : ℕ) :
    G.numColorings k = H.numColorings k := by
      have := SimpleGraph.numColorings_eq_eval G k; have := SimpleGraph.numColorings_eq_eval H k; simp_all +decide [ ← @Nat.cast_inj ℤ ] ;

end SimpleGraph