# Theorem Trace (internal anti-hallucination ledger)

Every result below is taken verbatim from the Phase A Lean output. No theorem is
invented or renamed into a grander claim.

## From `Catalog/EML/FixedPointConvergence.lean`

| Lean name | Mathematical statement | In ARTICLE | In PAPER |
|---|---|---|---|
| `EMLIterOp` (def) | `f(x) = exp(a) · log(b·x + c)` | yes | Def. 1 |
| `EMLIterOp.iterSeq` (def) | `x₀ given; x_{n+1} = f(x_n)` | yes | Def. 2 |
| `EMLContractionData` (struct) | bundle: `lo<hi`, `0≤ρ<1`, `arg_pos`, `maps_to`, `deriv_bound` | yes | Def. 3 |
| `EMLIterOp.hasDerivAt` / `EMLIterOp.deriv_eq` | `f'(x) = exp(a)·b/(b·x+c)` when `b·x+c>0` | yes | Prop. 1 |
| `EMLIterOp.fixedPoint_eq` | a fixed point satisfies `x* = exp(a)·log(b·x*+c)` | yes | Prop. 2 |
| `EMLIterOp.fixedPoint_arg_gt_one` | if `x*>0` fixed then `b·x*+c>1` | — | Prop. 2 (remark) |
| `EMLIterOp.lipschitz_of_deriv_bound` | `|f(x)-f(y)| ≤ ρ·|x-y|` on `[lo,hi]` | yes | Lemma 1 |
| `EMLIterOp.fixedPoint_unique` | at most one fixed point on the contracting interval | yes | Thm. 1 |
| `EMLIterOp.iterSeq_mem_Icc` | iterates stay in `[lo,hi]` | — | Lemma 2 |
| `EMLIterOp.iterSeq_geometric_decay` | `|x_{n+1}-x_n| ≤ ρ^n·|x_1-x_0|` | yes | Lemma 3 |
| `EMLIterOp.iterSeq_cauchy` | the iteration is Cauchy | — | Lemma 4 |
| `EMLIterOp.iterSeq_converges` | `∃ x*`: limit, fixed, in `[lo,hi]` | yes | Thm. 2 |
| `EMLIterOp.fixedPoint_powerSeries_conjecture` | for `0<a<1/2`, `b=1,c=2`: `∃ x*>0` fixed (IVT) | yes | Thm. 3 |

## From `Catalog/EML/FixedPointRate.lean` (Phase A)

| Lean name | Mathematical statement | In ARTICLE | In PAPER |
|---|---|---|---|
| `EMLIterOp.iterSeq_dist_consecutive` | `dist(x_n,x_{n+1}) ≤ |x_1-x_0|·ρ^n` | yes | Lemma 3' |
| `EMLIterOp.iterSeq_error_bound` | a priori `|x_n-x*| ≤ |x_1-x_0|·ρ^n/(1-ρ)` | yes | Thm. 4 |
| `EMLIterOp.iterSeq_certified_rate` | packaged: fixed point + explicit geometric error bound | yes | Thm. 5 |
| `EMLIterOp.iterSeq_error_tendsto_zero` | the error bound `→ 0` (genuine `O(ρ^n)`) | yes | Cor. 1 |

## From `Catalog/EML/FixedPointConcreteInstance.lean` (Phase A)

| Lean name | Mathematical statement | In ARTICLE | In PAPER |
|---|---|---|---|
| `EMLIterOp.concreteEML` (def) | `a=1,b=1,c=100,lo=0,hi=20,ρ=1/30`; `f(x)=e·log(x+100)` | yes | §6 |
| `EMLIterOp.concreteEML_apply` | the instance is exactly `f(x)=e·log(x+100)` | yes | §6 |
| `EMLIterOp.concreteEML_nontrivial` | `1 < exp(a)` with `a=1` (not a bare log) | yes | §6 |
| `EMLIterOp.concreteEML_certified` | end-to-end: fixed point in `[0,20]`, convergence, `(1/30)^n` rate | yes | Thm. 6 |
