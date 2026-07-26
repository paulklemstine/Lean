/-
# Consequences of Fermat's Little Theorem for `p = 5`

This module builds directly on `Catalog.Logic.FermatLittleFive`, reusing the
catalog result `fermat_little_five : (5 : ℤ) ∣ a ^ 5 - a` to derive two further
statements:

* `pow_five_emod_five` — the congruence form `a ^ 5 ≡ a (mod 5)`, i.e.
  `a ^ 5 % 5 = a % 5`.
* `five_dvd_sum_pow_five_sub` — summed form: for every `n`, five divides
  `∑_{k<n} (k^5 - k)`, obtained by dividing each summand and using
  `Finset.dvd_sum`.

  -- !-- Lab Notes -- !--
  Hypothesis (Stage 1): the pointwise divisibility `5 ∣ a^5 - a` should upgrade to
    (i) a modular-arithmetic congruence and (ii) a statement about finite sums,
    without re-running any residue analysis.
  Experiment (Stage 2): checked `∑_{k<n}(k^5-k)` for small `n` — always a multiple
    of 5 — before formalising, matching the `Finset.dvd_sum` route.
  Analysis (Stage 3): the congruence follows from `Int.emod_emod_of_dvd`/
    `Int.ModEq`; the sum result is a one-line application of `Finset.dvd_sum` fed by
    the catalog lemma. No new case analysis was needed — the catalog theorem is the
    only arithmetic input.
  Critique (Stage 4): neither statement is a definitional restatement; both consume
    `fermat_little_five` nontrivially (a congruence rewrite and a sum-divisibility
    combinator respectively).
  Synthesis (Stage 5): a thin, reusable consequence layer demonstrating that the
    catalog result composes cleanly with Mathlib's modular and finite-sum API.
-/
import Catalog.Logic.FermatLittleFive

namespace Catalog.Logic.FermatLittleFive

open scoped BigOperators

/-- Congruence form of Fermat's Little Theorem for `p = 5`: `a ^ 5 ≡ a (mod 5)`. -/
theorem pow_five_emod_five (a : ℤ) : a ^ 5 % 5 = a % 5 := by
  have h : (5 : ℤ) ∣ a ^ 5 - a := fermat_little_five a
  omega

/-- Summed form: `5` divides `∑_{k < n} (k^5 - k)`. -/
theorem five_dvd_sum_pow_five_sub (n : ℕ) :
    (5 : ℤ) ∣ ∑ k ∈ Finset.range n, ((k : ℤ) ^ 5 - (k : ℤ)) := by
  refine Finset.dvd_sum ?_
  intro k _
  exact fermat_little_five (k : ℤ)

end Catalog.Logic.FermatLittleFive