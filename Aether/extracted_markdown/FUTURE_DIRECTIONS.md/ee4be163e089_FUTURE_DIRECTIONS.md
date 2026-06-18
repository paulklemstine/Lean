# Future Directions — Generalization Bounds, from the `Core.lean` Skeleton

## Synthesis

`Core.lean` now provides a **sorry-free deterministic skeleton** for the three
classical capacity-control regimes of statistical learning, all under a single
`import Mathlib`:

* the **finite-class / Occam** chain `union_bound_finite → occam_pac_bound`, with
  the inversion `occam_sample_complexity_correct` and the consistency limit
  `occam_gap_tendsto_zero`;
* the **sample-compression** chain `compression_count_le →
  compression_sample_complexity` (the `k log n` description length); and
* the **norm-capacity** calculus for overparameterized models
  (`normCapacity_nonneg`, `normCapacity_insert_unit_layer`,
  `normCapacity_append_le_one`, `normCapacity_mono`).

The cross-domain bridge `compression_refines_param_count` ties compression to a
parameter-count baseline. Crucially, the file factors **all** probabilistic
content into per-hypothesis scalar tail hypotheses (`q i ≤ exp(-2 ε² n)`), so the
deterministic composition is reusable verbatim by any concentration result.
`Core.lean` is a deliberate sibling of the catalog's `PACBayes/Bounds.lean`
(McAllester/Catoni) and `PerturbedGeneralization.lean` (robustness ⊕ compression):
together they give the `MachineLearning` catalog one coherent generalization-theory
spine.

## Results Summary

| Theorem | Statement | Status |
|---|---|---|
| `union_bound_finite` | `∑ q i ≤ |H|·c` when each `q i ≤ c` | proved |
| `occam_sample_complexity_correct` | `n ≥ (C+log 1/δ)/(2ε²) ⟹ occamBound ≤ R+ε` | proved |
| `occam_pac_bound` | tails `≤ exp(-2ε²n)` and `|H|·exp ≤ δ ⟹ ∑ q i ≤ δ` | proved |
| `occam_gap_tendsto_zero` | `occamBound R C n δ → R` as `n → ∞` | proved |
| `compression_count_le` | `C(n,k) ≤ n^k` | proved |
| `compression_sample_complexity` | `log C(n,k) ≤ k log n` | proved |
| `normCapacity_*` | nonneg / unit-layer invariance / controlled append / monotone | proved |
| `compression_refines_param_count` | `k log n ≤ p log n` for `k ≤ p` | proved |

All main results are `sorry`-free; the file builds against Lean 4.28.0 / Mathlib
v4.28.0.

---

## Direction 1 — Discharge the tail: a Hoeffding layer feeding `occam_pac_bound`

Right now `occam_pac_bound` *assumes* the per-hypothesis tail
`q i ≤ exp(-2 ε² n)`. The next cycle should discharge that hypothesis by proving
Hoeffding's inequality for `[0,1]`-bounded i.i.d. losses inside Mathlib's
`MeasureTheory`/`ProbabilityTheory`, instantiating
`q i = ℙ(|empRisk i − trueRisk i| > ε)`, and feeding the result straight into the
existing deterministic composition to obtain the full finite-class PAC theorem.

**The key insight is** that probability enters the entire finite-class story in
exactly one scalar — the exponential tail per hypothesis — so a *single*
concentration lemma, dropped into the already-proven `union_bound_finite →
occam_pac_bound` pipeline, yields the measure-theoretic theorem with no further
analysis. **Why now?** The deterministic interface in `Core.lean` makes the
integration target a precise single lemma `q i ≤ exp(-2 ε² n)`, and Mathlib's
bounded-difference / martingale infrastructure is mature enough to attack the
`[0,1]` Hoeffding bound directly. Falsifiable: if a sub-Gaussian tail with the
stated `2 ε² n` rate cannot be produced for the empirical mean, the conjectured
plug-in fails and the constant must be weakened.

## Direction 2 — McAllester vs. Catoni: the quadratic-vs-square-root gap

`PACBayes/Bounds.lean` proves monotonicity of both bounds but not their ordering.
Conjecture: at the optimal temperature `λ*`, `catoniBound` is strictly below
`mcAllesterBound`, with an explicit `Θ(kl/n)` versus `Θ(√(kl/n))` separation.

**The key insight is** that the Catoni denominator `1 − e^{−λ}` admits the tight
two-sided bracket `λ(1 − λ/2) ≤ 1 − e^{−λ} ≤ λ` on `(0,1]`, which converts the
exponential bound into a second-order Bernstein form and exposes the
quadratic-vs-square-root gap analytically. **Why now?** The monotonicity lemmas in
`PACBayes/Bounds.lean` already supply the convexity facts, and the only missing
ingredient is one elementary `exp` bracketing lemma — exactly the kind of
self-contained real inequality `Core.lean` shows is tractable (cf.
`occam_sample_complexity_correct`'s `nlinarith` closing argument). Falsifiable: a
numerical sweep where Catoni at `λ*` exceeds McAllester for some `kl, n` would
refute the strict ordering.

## Direction 3 — A concrete family where compression beats parameter counting

`compression_refines_param_count` shows `k log n ≤ p log n` whenever the
compression size `k` is below the parameter count `p`. The falsifiable next step is
to exhibit a *concrete* hypothesis family — thresholded linear separators, or
1-nearest-neighbor with `k` support points — where the parameter count is `p` but
the compression size is provably `k ≪ p`, and to prove that
`compression_sample_complexity` then gives a strictly smaller sample requirement
than the VC/parameter-count bound `≈ p log n`.

**The key insight is** that compression size is an *intrinsic* description length of
the learned predictor, decoupled from the redundant coordinates of an
overparameterized representation: the same predictor reached by a huge network is
certified by its tiny support set. **Why now?** With `compression_count_le` and
`compression_refines_param_count` proved, only the side-by-side instantiation on a
specific `(k, p)` family remains, and it is purely arithmetic. Falsifiable: if for
the chosen family the minimal compression set provably has size `Θ(p)`, the
separation collapses.

## Direction 4 — Covering numbers: norm capacity ⇒ effective hypothesis count

`normCapacity` and `occamSampleComplexity` currently live side by side in
`Core.lean`. Conjecture: a margin-`γ` classifier with product-of-norms capacity
`R = normCapacity layers` behaves like a finite class of effective size
`exp(C·R²/γ²)`, so plugging `numHyp := exp(C R²/γ²)` into
`occam_pac_bound`/`occam_sample_complexity_correct` yields a fully norm-based
generalization bound with sample complexity `Θ(R²/(γ² ε))` that is **invariant**
under the norm-1 layer insertions of `normCapacity_insert_unit_layer`.

**The key insight is** that a covering-number argument turns the continuous norm
ball into a finite ε-net whose log-cardinality is exactly `R²/γ²` — the single
bridge converting the Section 4 capacity into a Section 2 hypothesis count. **Why
now?** Both endpoints are already formalized in `Core.lean`; the only gap is a
covering-number lemma, expressible directly via Mathlib's `TotallyBounded` /
`Metric.ball` API. Falsifiable: if the covering number of the margin-normalized
norm ball scales worse than `exp(C R²/γ²)` (e.g. dimension-dependent), the clean
`Θ(R²/(γ²ε))` rate is false.

## Direction 5 — Double descent as nonmonotonicity of a two-regime risk functional

Define a risk functional `R(p) = approx(p) + penalty(p)` where `approx` decreases
in model size `p`, and the penalty switches from count-based (`∝ p`, governed by
`compression_refines_param_count`) below the interpolation threshold to norm-based
(`∝ normCapacity`, eventually decreasing via `normCapacity_append_le_one`) above
it. Conjecture: `R` is provably *nonmonotone*, with a local maximum exactly at the
interpolation threshold.

**The key insight is** that double descent stops being mysterious once capacity
control *changes basis* from parameter count to norm at interpolation: the second
descent is literally `normCapacity_append_le_one` (controlled-norm capacity cannot
hurt) overtaking the count term. **Why now?** With the norm-monotonicity lemmas of
`Core.lean` and the catalog's existing `TropicalDoubleDescent.lean` phase diagram,
the two regimes can be glued into one piecewise functional and its critical points
analyzed with the `deriv` / `StrictMonoOn` tooling already used elsewhere in the
project. Falsifiable: if the glued `R(p)` is monotone (no interior local maximum)
for every admissible choice of `approx` and penalty slopes, the double-descent
explanation via basis change fails.
