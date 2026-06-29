# Theorem Trace (internal anti-hallucination ledger)

Every claim in `ARTICLE.md`, `RESEARCH_PAPER.md`, and `RESEARCH_PAPER.tex` maps to a
Lean name from the Phase A output. No theorem is invented or renamed into a grander claim.

## Definitions

| Lean name | Statement | Article | Paper |
|---|---|---|---|
| `xParam` | `xParam q := (q^2 + 1) / 2` (Bruen–Drudge parameter) | §"The magic number" | Def. 3.1 |
| `trivialParams` | `trivialParams q := {0, 1, 2, q^2-1, q^2, q^2+1}` | §"Six boring values" | Def. 3.2 |
| `ind` (Core.lean) | `ind pts p := fun ℓ => if p ∈ pts ℓ then 1 else 0` (point-pencil indicator) | §"Functions on lines" | Def. 2.1 |
| `IsDegLEOne` (Core.lean) | `∃ c w, ∀ ℓ, f ℓ = c + ∑_{p ∈ pts ℓ} w p` | §"Degree one" | Def. 2.2 |
| `IsBoolean` (Core.lean) | `∀ ℓ, f ℓ = 0 ∨ f ℓ = 1` | §"Yes/no functions" | Def. 2.3 |
| `BooleanDegOne` (Core.lean) | `IsBoolean f ∧ IsDegLEOne pts f` | §"The objects of study" | Def. 2.4 |
| `IsTrivialBDOFn` | constant / `ind pts p` / `ind dpts h` / complements | §"The official boring list" | Def. 3.3 |
| `qBinom` (Grassmann) | `q`-Pascal recurrence Gaussian binomial `[n,k]_q` | §"Counting subspaces" | Def. 2.5 |

## Theorems / Lemmas

| Lean name | Statement | Article | Paper |
|---|---|---|---|
| `two_mul_xParam` | `Odd q → 2 * xParam q = q^2 + 1` | §"The magic number" | Thm. 4.1 |
| `xParam_self_complementary` | `Odd q → xParam q = (q^2+1) - xParam q` | §"Its own mirror image" | Thm. 4.2 |
| `xParam_gt_two` | `3 ≤ q → 2 < xParam q` | §"Six boring values" | Lem. 4.3 |
| `xParam_lt_q2_sub_one` | `3 ≤ q → xParam q < q^2 - 1` | §"Six boring values" | Lem. 4.4 |
| `xParam_not_trivial` | `3 ≤ q → xParam q ∉ trivialParams q` | §"Six boring values" | Thm. 4.5 |
| `bruenDrudge_class_size` | size `= xParam q * (q^2+q+1)` | §"Exactly half" | Thm. 4.6 |
| `bruenDrudge_param_not_trivial` | `param = xParam q → param ∉ trivialParams q` | §"Six boring values" | Cor. 4.7 |
| `bruenDrudge_nontrivial_BDO` | conditional: BD indicator is a non-trivial Boolean degree-one function on `J_q(4,2)` | §"Putting it together" | Thm. 5.1 |
| `extend_nontrivial_BDO` | embedding to `J_q(n,2)` for `n ≥ 4` | §"Climbing to higher dimensions" | Thm. 5.2 |

## Supporting backbone (Core.lean / GrassmannDegreeOne.lean)

| Lean name | Statement | Used in |
|---|---|---|
| `const_zero_BDO`, `const_one_BDO` | constants are Boolean degree one | Paper §2 |
| `pencil_BDO` | each `ind pts p` is Boolean degree one | Paper §2 |
| `compl_BDO` | Boolean degree one closed under `f ↦ 1 - f` | Paper §2 |
| `two_pencils_not_boolean` | `ind p + ind p'` is not Boolean | Article §"Why you can't just add", Paper §2 |
| `const_weight_is_constant` | constant-weight degree-one ⇒ constant | Paper §2 |
| `exists_many_BDO` | at least `|P|+2` Boolean degree-one functions | Paper §2 |
| `qBinom_one_eq_geom` | `[n,1]_q = 1+q+⋯+q^{n-1}` | Paper §2 |
| `qBinom_symm` / `point_hyperplane_duality` | `[n,k]_q = [n,n-k]_q` | Paper §2 |
| `qBinom_strictMono_left` | schemes grow strictly in `n` for `q ≥ 2` | Paper §2 |

Note: the future-directions text uses alternative working names (`bd_two_mul`,
`bd_self_complement`, `bd_size_eq_half`, `lines_PG3`, `degOneSum_boolean_iff`) for the same
parameter facts; the canonical Lean names above are used throughout the prose.
