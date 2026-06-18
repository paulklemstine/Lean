# Future Directions: Generalization Bounds for Learning

The file `Core.lean` isolates the *analytic skeleton* shared by Occam, sample
compression, and norm-based capacity bounds, and composes them into a single
sample-complexity calculus (`union_bound_finite` → `occam_sample_complexity_correct`
→ `occam_pac_bound`; `compression_count_le` → `compression_sample_complexity`;
`normCapacity_*` for overparameterization). The probabilistic content is cleanly
factored out as per-hypothesis tail hypotheses, leaving deterministic real
inequalities that compose without measure theory. The following directions push
that skeleton toward genuinely new, falsifiable mathematics.

## 1. A Hoeffding tail layer feeding `occam_pac_bound`

Right now `occam_pac_bound` takes the per-hypothesis tail `q i ≤ e^{-ε n}` as a
hypothesis. The next cycle should *discharge* this hypothesis by formalizing
Hoeffding's inequality for `[0,1]`-bounded i.i.d. losses inside Mathlib's
`MeasureTheory`/`ProbabilityTheory` framework and instantiating
`q i = ℙ(|empRisk i − trueRisk i| > ε)`. The key insight is that the only place
probability enters the entire finite-class story is a single scalar exponential
tail per hypothesis — so a *single* concentration lemma, plugged into the already
proven deterministic composition, yields the full finite-class PAC theorem with
no further analysis. **Why now?** Mathlib now has martingale and conditional
expectation infrastructure (`MeasureTheory.Martingale`, Azuma/Hoeffding stubs)
mature enough that the bounded-difference inequality is within reach, and the
deterministic scaffold in `Core.lean` makes the integration target precise.

## 2. Quantitative gap between McAllester and Catoni at the optimal temperature

`PACBayes/Bounds.lean` proves monotonicity of both bounds but not their *ordering*.
Conjecture: for `0 ≤ kl` and `n` large, `catoniBound` evaluated at the optimal
`λ* = argmin` is strictly below `mcAllesterBound`, with an explicit
`Θ(kl / n)` versus `Θ(√(kl / n))` separation. The key insight is that the Catoni
denominator `1 − e^{−λ}` admits a tight two-sided bracket `λ(1−λ/2) ≤ 1−e^{−λ} ≤ λ`
on `(0,1]`, which converts the exponential bound into the second-order Bernstein
form and exposes the quadratic-vs-square-root gap analytically. **Why now?** The
monotonicity lemmas already in the catalog supply the convexity facts needed; the
missing piece is one elementary `exp` bracketing lemma, exactly the kind of real
inequality the present file shows is tractable.

## 3. Compression bounds that beat parameter counting on a concrete family

`compression_sample_complexity` shows sample complexity scales like `k log n`,
independent of ambient parameter count. The falsifiable next step: exhibit a
concrete hypothesis family (e.g. thresholded linear separators / 1-nearest-neighbor
with `k` support points) where the parameter count is `p` but the compression size
is provably `k ≪ p`, and prove `compression_sample_complexity` gives a strictly
smaller `m` than the VC/parameter-count bound `≈ p`. The key insight is that
compression size is an *intrinsic* description-length of the learned predictor,
decoupled from the redundant coordinates of an overparameterized representation —
so the same predictor reached by a huge net is certified by its tiny support set.
**Why now?** The counting lemma `compression_count_le` is proved, so only the
side-by-side numerical comparison against a VC bound remains, and it is purely
arithmetic.

## 4. Closing the loop: norm capacity ⇒ effective hypothesis count ⇒ Occam

`normCapacity` and `occamSampleComplexity` currently live side by side. Conjecture:
a margin-`γ` classifier with product-of-norms capacity `R = normCapacity layers`
behaves like a finite class of effective size `exp(C · R² / γ²)`, so plugging
`numHyp := exp(C R²/γ²)` into `occam_sample_complexity_correct` yields a fully
norm-based generalization bound whose sample complexity is `Θ(R²/(γ² ε))` and is
*invariant* under the norm-1 layer insertions proved in
`normCapacity_insert_unit_layer`. The key insight is that a covering-number
argument turns the continuous norm ball into a finite ε-net whose log-cardinality
is exactly `R²/γ²`, the single bridge converting Section 4's capacity into
Section 2's hypothesis count. **Why now?** Both endpoints are formalized in
`Core.lean`; the only gap is a covering-number lemma, and Mathlib's metric
`TotallyBounded`/`Metric.ball` API can express the net directly.

## 5. Double descent as nonmonotonicity of a two-regime risk functional

The catalog already contains `TropicalDoubleDescent.lean`. Conjecture: define a
risk functional `R(p) = approx(p) + occam-penalty(p)` where `approx` decreases and
the penalty switches from count-based (`∝ p`) below the interpolation threshold to
norm-based (`∝ normCapacity`, hence eventually decreasing) above it; then `R` is
provably *nonmonotone* with a local maximum exactly at the interpolation threshold.
The key insight is that double descent is not mysterious once capacity control
*changes basis* from parameter count to norm at interpolation — the second descent
is literally `normCapacity_append_le_one` (adding controlled-norm capacity cannot
hurt) overtaking the count term. **Why now?** With the norm-monotonicity lemma
proved here and the tropical double-descent phase diagram already in the catalog,
the two regimes can be glued into one piecewise functional and its critical points
analyzed with `deriv`/`StrictMonoOn` tools already used elsewhere in the project.
