# Theorem Trace (internal anti-hallucination ledger)

Every result stated in ARTICLE.md and RESEARCH_PAPER.md maps to one of the
Lean declarations below. No grander claims are made than what these establish.

## Definitions

| Lean name | Statement | Article | Paper |
|---|---|---|---|
| `EMLIterOp` | `EMLIterOp a b c x = exp a * log (b * x + c)` | "the move", §1 | Def. 1 |
| `EMLIterOp.iterSeq` | `iterSeq a b c x₀ 0 = x₀`; `iterSeq … (n+1) = EMLIterOp a b c (iterSeq … n)` | §1 | Def. 2 |
| `EMLContractionData` | structure: `a b c lo hi rho` with `lo<hi`, `0≤rho<1`, `arg_pos`, `maps_to`, `deriv_bound` | §2 | Def. 3 |

## Convergence layer (FixedPointConvergence.lean)

| Lean name | Statement | Article | Paper |
|---|---|---|---|
| `EMLIterOp.hasDerivAt` / `deriv_eq` | `deriv (EMLIterOp a b c) x = exp a * b / (b*x+c)` for `b*x+c>0` | §2 | Lemma 1 |
| `EMLIterOp.fixedPoint_eq` | `f(x*)=x* ⇒ x* = exp a * log(b*x*+c)` | §2 | Lemma 2 |
| `EMLIterOp.fixedPoint_arg_gt_one` | positive fixed point with positive arg ⇒ `b*x*+c > 1` | §3 | Lemma 3 |
| `EMLIterOp.lipschitz_of_deriv_bound` | deriv bound by `rho` ⇒ `|f x - f y| ≤ rho*|x-y|` | §2 | Lemma 4 |
| `EMLIterOp.fixedPoint_unique` | contraction ⇒ ≤ one fixed point in `[lo,hi]` | §2 | Thm. 1 |
| `EMLIterOp.iterSeq_mem_Icc` | iterates stay in `[lo,hi]` | §2 | Lemma 5 |
| `EMLIterOp.iterSeq_geometric_decay` | `|x_{n+1}-x_n| ≤ rho^n |x_1-x_0|` | §2 | Lemma 6 |
| `EMLIterOp.iterSeq_cauchy` | iteration is Cauchy | §2 | Lemma 7 |
| `EMLIterOp.iterSeq_converges` | iteration → a fixed point in `[lo,hi]` | §2 | Thm. 2 |
| `EMLIterOp.fixedPoint_powerSeries_conjecture` | for `0<a<1/2`, `b=1,c=2`: ∃ positive fixed point | §4 | Prop. 1 |

## Rate layer (FixedPointRate.lean)

| Lean name | Statement | Article | Paper |
|---|---|---|---|
| `EMLIterOp.iterSeq_error_bound` | `|x_n - x*| ≤ |x_1-x_0| rho^n /(1-rho)` | §2 | Thm. 3 |
| `EMLIterOp.iterSeq_certified_rate` | existence + a priori bound packaged | §2 | Cor. 1 |
| `EMLIterOp.iterSeq_error_tendsto_zero` | the a priori bound → 0 | §2 | Cor. 2 |

## Bracket layer (FixedPointBracket.lean)

| Lean name | Statement | Article | Paper |
|---|---|---|---|
| `EMLIterOp.op_monotoneOn` | `b>0 ⇒ f` monotone on `[lo,hi]` | §3 | Lemma 8 |
| `EMLIterOp.iterSeq_lo_mono` | lower orbit `fⁿ(lo)` increases | §3 | Lemma 9 |
| `EMLIterOp.iterSeq_hi_anti` | upper orbit `fⁿ(hi)` decreases | §3 | Lemma 10 |
| `EMLIterOp.certified_enclosure` | bracket `ℓₙ ≤ x* ≤ uₙ`, width → 0 | §3 | Thm. 4 |

## Comparative-statics layer (FixedPointMonotoneParam.lean — Phase A)

| Lean name | Statement | Article | Paper |
|---|---|---|---|
| `EMLIterOp.op_le_op_of_a_le` | `a₁≤a₂`, `log(b*x+c)≥0 ⇒ f_{a₁}(x) ≤ f_{a₂}(x)` | §3 | Lemma 11 |
| `EMLIterOp.op_lt_op_of_a_lt` | `a₁<a₂`, `log(b*x+c)>0 ⇒ f_{a₁}(x) < f_{a₂}(x)` | §3 | Lemma 12 |
| `EMLIterOp.orbit_mono_of_subsolution` | `p ≤ f(p) ⇒` orbit from `p` increases | §3 | Lemma 13 |
| `EMLIterOp.fixedPoint_le_of_a_le` | `a₁≤D.a` ⇒ ∃ fixed point `x₂` with `x₁ ≤ x₂` | §3 (main) | Thm. 5 |
| `EMLIterOp.fixedPoint_lt_of_a_lt` | `a₁<D.a` ⇒ ∃ fixed point `x₂` with `x₁ < x₂` | §3 (main) | Thm. 6 |
| `EMLIterOp.fixedPoint_unique_le_of_a_le` | unique fixed point of larger `a` dominates | §3 | Thm. 7 |
