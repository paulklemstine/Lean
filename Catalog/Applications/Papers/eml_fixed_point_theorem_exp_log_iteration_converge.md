# THEOREM TRACE (internal — anti-hallucination)

Source files (ground truth):
- `Catalog/EML/FixedPointConvergence.lean`
- `Catalog/EML/FixedPointThreshold.lean`
- `Catalog/EML/FixedPointRate.lean`
- `Catalog/EML/FixedPointBracket.lean`
- `Catalog/EML/FixedPointConcreteInstance.lean`
- `Catalog/EML/FixedPointBracketInstance.lean`

| Lean name | Statement | Article | Paper |
|---|---|---|---|
| `EMLIterOp` (def) | `f(x) = exp a * log (b*x + c)` | yes | Def 1 |
| `EMLIterOp.iterSeq` (def) | `x_{n+1} = f(x_n)` | yes | Def 2 |
| `EMLContractionData` (struct) | packages a,b,c,lo,hi,rho + invariants | yes | Def 3 |
| `EMLIterOp.hasDerivAt` / `deriv_eq` | `f'(x) = exp a * b / (b*x + c)` | yes | Lem 1 |
| `EMLIterOp.fixedPoint_eq` | fix ⇒ `x* = exp a * log(b x* + c)` | yes | Lem 2 |
| `EMLIterOp.fixedPoint_arg_gt_one` | pos fix ⇒ `b x* + c > 1` | — | Lem 2b |
| `EMLIterOp.lipschitz_of_deriv_bound` | deriv ≤ ρ ⇒ ρ-Lipschitz | yes | Lem 3 |
| `EMLIterOp.fixedPoint_unique` | contraction ⇒ ≤1 fixed point | yes | Thm A |
| `EMLIterOp.iterSeq_mem_Icc` | maps_to ⇒ orbit stays in [lo,hi] | yes | Lem 4 |
| `EMLIterOp.iterSeq_geometric_decay` | `|x_{n+1}-x_n| ≤ ρ^n |x_1-x_0|` | yes | Lem 5 |
| `EMLIterOp.iterSeq_cauchy` | orbit Cauchy | — | Lem 6 |
| `EMLIterOp.iterSeq_converges` | orbit → fixed point in [lo,hi] | yes | Thm B |
| `EMLIterOp.special_b1_c1` | `f = exp a * log(x+1)` | — | Rmk |
| `EMLIterOp.at_a_zero` | `a=0 ⇒ f = log(b x + c)` | — | Rmk |
| `EMLIterOp.fixedPoint_powerSeries_conjecture` | b=1,c=2,0<a<1/2 ⇒ ∃ pos fix | yes | Prop |
| `residual_le` | `f(x)-x ≤ exp a (a-1) + c` (b=1) | yes | Lem 7 |
| `no_fixedPoint_of_subcritical` | `exp a (a-1)+c<0 ⇒` no fix | yes | Thm C |
| `no_fixedPoint_half_half` | a=c=1/2 ⇒ no fix (falsifies box) | yes | Cor |
| `fixedPoint_imp_c_ge_threshold` | fix ⇒ `c ≥ exp a (1-a)` | yes | Thm C |
| `threshold_fixedPoint_neutral` | at `c=exp a(1-a)`: fix at `x*=exp a -c`, `f'=1` | yes | Thm D |
| `iterSeq_dist_consecutive` | dist form of geometric decay | — | Lem 5' |
| `iterSeq_error_bound` | `|x_n-x*| ≤ |x_1-x_0| ρ^n/(1-ρ)` | yes | Thm E |
| `iterSeq_certified_rate` | existence + a priori error bound | yes | Thm E |
| `iterSeq_error_tendsto_zero` | error bound → 0 | — | Cor |
| `op_monotoneOn` | b>0 ⇒ f monotone on interval | yes | Lem 8 |
| `iterSeq_lo_mono` / `iterSeq_hi_anti` | lower orbit ↑, upper orbit ↓ | yes | Lem 9 |
| `iterSeq_lo_le_fixedPoint` / `iterSeq_fixedPoint_le_hi` | orbits bracket x* | yes | Lem 10 |
| `certified_enclosure` | two-sided enclosure, width→0 | yes | Thm F |
| `concreteEML` (def) | `f(x)=exp 1·log(x+100)` on [0,20], ρ=1/30 | yes | Ex |
| `concreteEML_apply` | unfolds to exp 1 log(x+100) | — | Ex |
| `concreteEML_nontrivial` | `exp 1 > 1` | — | Ex |
| `concreteEML_certified` | end-to-end certified convergence | yes | Thm G |
