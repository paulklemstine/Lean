# Future Directions: Empirical Rademacher Complexity

The file `Catalog/MachineLearning/RademacherComplexity.lean` builds a rigorous,
computation-first account of empirical Rademacher complexity: the `±1`-sign
correlation `radSum`, the averaged capacity `empRad`, the core cancellation
`sum_radSign`, and an *exact* formula for the symmetric pair `{f, -f}`. Each
result is exact rather than an inequality, which makes the development an ideal
substrate for the next, harder layer of learning theory. The directions below are
falsifiable: each names a concrete Lean statement whose truth (or refutation by a
counterexample) can be settled mechanically.

## 1. Massart's finite-class bound

Conjecture: for a class `F` whose every member satisfies `radSum f σ ≤ B`
uniformly, `empRad F hF ≤ (B / m) * sqrt (2 * Real.log F.card) / sqrt (2^m … )`,
the textbook `sqrt(2 log N)` scaling that converts cardinality into capacity.
**The key insight is** that the maximal-correlation supremum can be controlled by
the moment-generating-function (Jensen / Hoeffding-on-the-hypercube) argument,
where `sum_radSign` already supplies the exact first-moment vanishing that the MGF
bound is built on top of. **Why now?** We have an exact `empRad` with the
zero-mean property proven (`radSum_sum_zero`); the only missing analytic ingredient
is a sub-Gaussian tail for `radSum`, which is a self-contained hypercube estimate
rather than new infrastructure.

## 2. Contraction / Talagrand's lemma for 1-Lipschitz post-composition

Conjecture: if `φ : ℝ → ℝ` is `1`-Lipschitz with `φ 0 = 0`, then
`empRad (F.image (fun f => φ ∘ f)) ≤ empRad F`. **The key insight is** that the
absorption-into-the-supremum already made explicit in `empRad_symmetric_pair`
(`max a (-a) = |a|`) is the `φ = |·|` instance of the general contraction
principle, so the symmetric-pair formula is literally the base case of an
induction over coordinates. **Why now?** `empRad_symmetric_pair` gives the exact
one-coordinate contraction identity; the pending work is the coordinate-wise
peeling that mathlib's `Finset.sup'` API now supports cleanly.

## 3. Homogeneity and translation invariance

Conjecture: `empRad (c • F) = |c| * empRad F` for scalars `c`, and
`empRad (F + {b}) = empRad F` for a fixed shift vector `b`. **The key insight is**
that `radSum` is linear in `f` and that `radSum b` averages to zero
(`radSum_sum_zero`), so an additive shift is invisible to the averaged supremum
exactly as a constant feature is invisible to a learning algorithm. **Why now?**
Both reduce to pushing scalars/shifts through `Finset.sup'` and reusing
`radSum_sum_zero`; no new probabilistic content is required, only `Finset.image`
bookkeeping.

## 4. Bridge to the algebraic capacity theory of `Foundations.lean`

Conjecture: for the evaluation class `evaluationHypothesisClass` of `Foundations.lean`,
the analytic `empRad` is bounded by the algebraic `spectralComplexityBound`,
realizing the `8/3` Rademacher-to-PAC constant of `algebraicSampleComplexityBound`
as a genuine inequality between the two capacity measures. **The key insight is**
that VC-shattering (already formalized as `field_shattering_card_le_finrank`)
upper-bounds the number of distinct sign patterns `σ ↦ sign (radSum f σ)`, and the
distinct-pattern count is exactly what converts a supremum over `F` into a
`sqrt(VC)` Rademacher bound. **Why now?** The VC side exists in `Foundations.lean`
and the Rademacher side now exists here; the bridge is the missing Sauer–Shelah
counting step, the single most-cited cross-domain link in learning theory.

## 5. Generalization (uniform deviation) certificate

Conjecture: with `empRad` as defined, the expected supremum of the empirical
process `sup_{f∈F} (population mean f − sample mean f)` is bounded by
`2 * empRad F`, the symmetrization inequality. **The key insight is** that the
ghost-sample symmetrization introduces precisely the Rademacher signs `σ` we sum
over, so the deviation bound is `empRad` plus a concentration tail. **Why now?**
This is the theorem that turns all of the above into an actual generalization-error
guarantee; with the exact `empRad` object and `radSum_sum_zero` in place, the
remaining step is a single application of Jensen's inequality over the symmetrized
process, well within mathlib's current measure-theory reach.
