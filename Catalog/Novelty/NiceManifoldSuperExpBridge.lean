import Mathlib
import Novelty.SuperExponential
import Novelty.NiceManifoldGoodCount

/-!
# A bridge: the good-manifold count is exponential but *not* super-exponential

This file connects the good-manifold sequence `goodCount` of
`Novelty.NiceManifoldGoodCount` to the growth hierarchy developed in
`Novelty.SuperExponential`.  The catalog notion `Novelty.SCD.SuperExp f` says
`f` eventually dominates *every* fixed exponential `c ^ n`; the factorial and the
count of permutations satisfy it.  The good-manifold count sits strictly below
this hierarchy: it is asymptotically the single exponential `2 ^ n`, hence it
cannot dominate, say, `3 ^ n`.

* `goodCount_eventuallyEq_pow` — the asymptotic law `goodCount =ᶠ[atTop] 2 ^ ·`;
* `goodCount_not_superExp` — the good-manifold count is **not** super-exponential.

Together these pin down the exact growth type of the sequence: purely
exponential with base `2`, one full level below the factorial regime.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer): the good-manifold count should occupy the exponential
tier, strictly below the super-exponential (factorial) tier of the catalog.  The
falsifiable prediction: `goodCount` fails `SuperExp` because its eventual base is
the *fixed* number `2`, and `SuperExp` demands overtaking `c^n` for arbitrarily
large `c` — in particular `c = 2` already forces `2^n < goodCount n = 2^n`.

EXPERIMENT (Experimenter): instantiate the catalog predicate at base `c = 2` and
evaluate at any tail index `n ≥ 7`; the closed form `goodCount n = 2^n` turns the
required strict inequality into `2^n < 2^n`, an immediate contradiction.

ANALYSIS (Analyst): the negative result is short but genuinely cross-domain — it
consumes the *definition* `Novelty.SCD.SuperExp` from a different catalog thread
(symmetric chain decompositions) and the closed form from this thread.  The
positive companion `goodCount_eventuallyEq_pow` records the matching upper/lower
envelope, so the sequence is neither sub- nor super-exponential but exactly
`Θ(2^n)`.

CRITIQUE (Critic): is the negation vacuous?  No — `Novelty.SCD.factorial_superexp`
exhibits sequences that *do* satisfy `SuperExp`, so the predicate is non-trivial
and the good-manifold count genuinely fails a satisfiable property.
-- !-- end Lab Notes -- !--
-/

namespace Novelty.NiceManifold

open scoped Filter

/-- **Asymptotic law.** Eventually (for `n ≥ 7`) the good-manifold count is
exactly the exponential `2 ^ n`; i.e. `goodCount` is `Θ(2 ^ n)`. -/
theorem goodCount_eventuallyEq_pow :
    goodCount =ᶠ[Filter.atTop] fun n => 2 ^ n := by
  filter_upwards [Filter.eventually_ge_atTop 7] with n hn
  exact goodCount_closedForm hn

/-- **The good-manifold count is not super-exponential.** Using the catalog
predicate `Novelty.SCD.SuperExp` (which the factorial *does* satisfy), the
good-manifold count fails it: at base `c = 2` any tail index would force
`2 ^ n < goodCount n = 2 ^ n`. -/
theorem goodCount_not_superExp : ¬ Novelty.SCD.SuperExp goodCount := by
  intro h
  obtain ⟨N, hN⟩ := h 2
  have hn := hN (max N 7) (le_max_left _ _)
  rw [goodCount_closedForm (le_max_right _ _)] at hn
  exact lt_irrefl _ hn

end Novelty.NiceManifold