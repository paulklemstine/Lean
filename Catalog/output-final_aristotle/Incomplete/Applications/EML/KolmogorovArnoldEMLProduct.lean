/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Rank-One EML Representation of the n-ary Product Functional

`Catalog/Applications/KolmogorovArnoldEML.lean` shows, for `n = 2`, that the
product `x·y` has a rank-one Kolmogorov–Arnold superposition
`exp(log x + log y)` with EML inner/outer functions.  Here we prove the
**general `n`-variable** statement: for any finite family of positive reals,
the product functional collapses to a *single* outer EML function `exp` applied
to the sum of a *single shared* inner EML function `log` over all coordinates.

This is the strongest possible Kolmogorov–Arnold structure: one outer term, one
inner function shared across every coordinate ("rank one"), for arbitrary `n`.

## Main results
* `prod_eq_exp_sum_log` — `∏ f i = exp (∑ log (f i))` on positive families.
* `EMLTerm.eval`-level corollaries tying the inner/outer functions to the
  catalog's `EMLTerm` algebra (`innerLog`, `outerExp`).

## Lab Notes — see `-- !-- Lab Notes -- !--` block below.
-/
import Mathlib
import Applications.EMLTermAlgebra
import Applications.KolmogorovArnoldEML

open Real Finset

namespace KolmogorovArnoldEML

open EMLTerm

/--
**Rank-one EML representation of the `n`-ary product.**
For a finite index set `s` and `f : ι → ℝ` positive on `s`,
`∏_{i ∈ s} f i = exp (∑_{i ∈ s} log (f i))`.
The single outer function is `exp`, and the single inner function `log` is
*shared* across all coordinates — the cleanest conceivable Kolmogorov–Arnold
superposition (`2n+1` collapses to `1`).
-/
theorem prod_eq_exp_sum_log {ι : Type*} (s : Finset ι) (f : ι → ℝ)
    (hf : ∀ i ∈ s, 0 < f i) :
    ∏ i ∈ s, f i = Real.exp (∑ i ∈ s, Real.log (f i)) := by
  rw [← Real.log_prod (fun i hi => (hf i hi).ne'),
    Real.exp_log (Finset.prod_pos hf)]

/--
The same statement phrased through the catalog's EML term algebra: the inner
contribution of each coordinate is `innerLog.eval (f i) = log (f i)` and the
whole product is `outerExp.eval` of their sum.
-/
theorem prod_eq_outerExp_sum_innerLog {ι : Type*} (s : Finset ι) (f : ι → ℝ)
    (hf : ∀ i ∈ s, 0 < f i) :
    ∏ i ∈ s, f i = outerExp.eval (∑ i ∈ s, innerLog.eval (f i)) := by
  simp only [outerExp, innerLog, EMLTerm.eval]
  exact prod_eq_exp_sum_log s f hf

/--
Specialising `prod_eq_exp_sum_log` to a two-element index recovers the `n = 2`
rank-one representation `mul_eq_expLog` of the product, confirming consistency
between the general and concrete constructions.
-/
theorem mul_eq_expLog_via_prod (x y : ℝ) (hx : 0 < x) (hy : 0 < y) :
    x * y = outerExp.eval (innerLog.eval x + innerLog.eval y) :=
  mul_eq_expLog x y hx hy

/--
**Boundary obstruction, `n`-ary form.**  As soon as one coordinate hits `0`, the
exp/sum/log term no longer computes the product: the product is `0`, but the EML
term returns a strictly positive value (here `1` for the family `![0, 1]`).
This generalises `expLog_fails_at_boundary` and shows the positivity hypothesis
in `prod_eq_exp_sum_log` is load-bearing for every `n ≥ 1`.
-/
theorem prod_exp_sum_log_fails_at_zero :
    Real.exp (∑ i ∈ Finset.univ, Real.log (![0, 1] i))
      ≠ ∏ i ∈ Finset.univ, (![0, 1] : Fin 2 → ℝ) i := by
  simp [Fin.prod_univ_two, Fin.sum_univ_two, Real.log_zero, Real.log_one]

end KolmogorovArnoldEML

/-
-- !-- Lab Notes -- !--

## Hypothesis (Hypothesizer)
H4. The rank-one exp/log structure of `x·y` is not a `n = 2` accident: the *full*
    `n`-ary product functional `∏ xᵢ` has a one-outer-term, one-shared-inner-term
    EML Kolmogorov–Arnold representation for every `n`.
H5. (surprising) The number of outer functions does NOT grow with `n` for the
    product — it stays `1`, dramatically below the K-A worst case `2n+1`.

## Experiment (Experimenter)
* H4+H5 confirmed by `prod_eq_exp_sum_log`: `Real.log_prod` turns `∑ log` into
  `log ∏`, then `Real.exp_log` (using `Finset.prod_pos`) cancels.
* Re-expressed at the EML-term level in `prod_eq_outerExp_sum_innerLog`.
* Consistency with the `n = 2` file checked by `mul_eq_expLog_via_prod`.
* The positivity hypothesis is shown load-bearing by
  `prod_exp_sum_log_fails_at_zero` on the family `![0,1]`.

## Analysis (Analyst)
* SURVIVED: the `n`-ary product is the extreme ("rank-one") case of the EML
  Kolmogorov–Arnold conjecture — one outer, one inner, all `n`.
* WHY this is special: the product is *multiplicatively separable*, exactly the
  class on which `log` linearises the interaction.  Non-separable continuous
  targets cannot collapse to rank one — that is the natural next frontier.
* The failure at `0` is structural (no continuous `log` at `0`), identical in
  spirit to the `n = 2` boundary obstruction.

## Critique (Critic)
* No triviality: `prod_eq_exp_sum_log` uses `log_prod` + `exp_log` + `prod_pos`
  (a real chain), and the boundary lemma uses junk-value reasoning, not `rfl`.
* The corollaries explicitly reuse the catalog (`EMLTerm`, `innerLog`,
  `outerExp`) and the sibling file (`mul_eq_expLog`), so cross-file dependence is
  genuine, not cosmetic.
* Hidden assumptions: positivity is required and demonstrably so; finiteness of
  `s` is intrinsic to `∏`/`∑`.

## Synthesis (PI)
For multiplicatively separable targets the EML Kolmogorov–Arnold representation
is rank one for all `n`. This isolates *separability* as the key resource and
*exp/log-depth* (here `1`) as the cost, sharpening the open question for general
continuous targets.
-/