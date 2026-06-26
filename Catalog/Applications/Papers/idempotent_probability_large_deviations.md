# THEOREM_TRACE.md (internal anti-hallucination ledger)

Every theorem/definition name below is taken verbatim from the Phase A Lean
output (`Catalog/Tropical/MeasureTheory/{Basic,LargeDeviations,DualityGap}.lean`
and the new `Contraction.lean` listing in the task prompt). Prose in ARTICLE.md
and RESEARCH_PAPER.md must only reference these.

## Basic.lean
| Lean name | Statement | Article | Paper |
|---|---|---|---|
| `MaxPlusMeasure` | structure: `weight : X → ℝ` | yes (informal) | Def 1 |
| `IsTropicalProbability` | `sup' w = 0` and `∀x, w x ≤ 0` | yes | Def 2 |
| `maxPlusIntegral` | `sup_x (f x + w x)` | yes | Def 3 |
| `maxPlusIntegral_attained` | sup attained at some `x₀` | — | Lemma |

## LargeDeviations.lean
| Lean name | Statement | Article | Paper |
|---|---|---|---|
| `idempotentRate` | `I(x) = -w(x)` | yes | Def 4 |
| `idempotentCGF` | `Λ(λ) = sup_x(λ val x + w x)` | yes | Def 5 |
| `idempotentCGF_convex` | `Λ` convex | yes | Thm |
| `idempotentCGF_add` | additive under product | yes | Thm |
| `idempotentCGF_walk` | `Λ_n = n·Λ` | yes | Thm |
| `idempotent_chernoff` | `w x ≤ Λ(λ) - λ a` for `λ≥0`, `a≤val x` | yes | Thm |
| `idempotent_ldp_sharp` | `-(sup_A w) = inf_A I` | yes | Thm (sharp LDP) |
| `fenchel_young_rate` | `λ val x - Λ(λ) ≤ I(x)` | — | Lemma |
| `lfBiconj` | `sup_λ(λa - Λ(λ))` | yes | Def |
| `lfBiconj_le_rate` | `I** ≤ I` | yes | Thm |
| `lfBiconj_eq_rate_of_support` | equality under supporting line | yes | Thm |

## DualityGap.lean
| Lean name | Statement | Article | Paper |
|---|---|---|---|
| `gapMeasure` | law on Fin 3, weights (0,-2,0) | yes | Example |
| `gapRate_nonconvex` | `(I0+I2)/2 < I1` | yes | Example |
| `strict_duality_gap` | `lfBiconj < I` at midpoint | yes | Thm |
| `duality_gap_value` | gap `= 2` | yes | Thm |

## Contraction.lean (Phase A new file, primary focus)
| Lean name | Statement | Article | Paper |
|---|---|---|---|
| `fiber` | `{x : T x = y}` | yes | Def |
| `preimageEvent` | `{x : T x ∈ B}` | yes | Def |
| `fiber_nonempty` | surjective ⇒ fiber nonempty | — | Lemma |
| `preimageEvent_eq_biUnion` | `T⁻¹B = ⋃_{y∈B} fiber y` | yes | Lemma |
| `inf'_fiber_eq` | `inf_{T⁻¹B} f = inf_{y∈B} inf_{fiber y} f` | yes | Lemma (core) |
| `pushforwardMeasure` | `w_Y(y) = sup_{T x=y} w(x)` | yes | Def |
| `le_pushforward_weight` | `w x ≤ w_Y(T x)` | — | Lemma |
| `pushforwardMeasure_isProb` | pushforward is tropical prob | yes | Thm |
| `pushforward_rate` | `I_Y(y) = inf_{T x=y} I_X(x)` | yes | Thm |
| `idempotent_contraction` | cost of B = cost of T⁻¹B | yes (main) | Thm (main) |
| `idempotent_contraction_measure` | `μ_Y(B) = μ_X(T⁻¹B)` | yes | Thm |

No theorem is referenced in prose that is not in this table.
