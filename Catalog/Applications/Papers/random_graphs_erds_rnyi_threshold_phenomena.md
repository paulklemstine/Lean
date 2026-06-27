# THEOREM TRACE — Erdős–Rényi threshold phenomena

Internal anti-hallucination map. Every result below appears verbatim in the
Phase A Lean output (files `Model.lean`, `Concrete.lean`, `SecondMoment.lean`,
and the threshold development `Threshold.lean`). No result is stated in the
prose that is not listed here.

## Model.lean — namespace `ErdosRenyi`

| Lean name | Mathematical statement | ARTICLE.md | RESEARCH_PAPER.md |
|---|---|---|---|
| `weight` (def) | `weight p g = ∏ e, (if g e then p else 1-p)` | yes | yes (Def 1) |
| `weight_nonneg` | `0 ≤ p ≤ 1 ⇒ 0 ≤ weight p g` | — | yes |
| `sum_weight` | `∑ g, weight p g = 1` | yes | yes (Prop 1) |
| `prob` (def) | `prob p A = ∑_{g∈A} weight p g` | yes | yes (Def 2) |
| `expectation` (def) | `E p X = ∑ g, weight p g · X g` | yes | yes (Def 2) |
| `allPresent`/`allAbsent` (def) | events that `S` is all-present / all-absent | yes | yes |
| `prob_allPresent` | `prob p (allPresent S) = p^{|S|}` | yes | yes (Thm 1) |
| `prob_allAbsent` | `prob p (allAbsent S) = (1-p)^{|S|}` | yes | yes (Thm 1) |
| `subgraphCount` (def) | number of copies present | yes | yes |
| `expectation_subgraphCount` | `E[#copies] = ∑_i p^{|S i|}` | yes | yes (Thm 2) |
| `expectation_subgraphCount_uniform` | uniform size `k`: `= #copies · p^k` | yes | yes (Thm 2) |
| `firstMoment` | `P(#copies ≥ 1) ≤ ∑_i p^{|S i|}` | yes | yes (Thm 3) |

## Concrete.lean — namespace `ErdosRenyiConcrete`

| Lean name | Mathematical statement | ARTICLE.md | RESEARCH_PAPER.md |
|---|---|---|---|
| `expectation_count` | `E[#events occurring] = ∑_i prob p (A i)` | yes | yes (Thm 4) |
| `card_edge` | `#edges = C(n,2)` | yes | yes |
| `expected_edges` | `E[#edges] = C(n,2)·p` | yes | yes (Thm 5) |
| `card_incident` | each vertex meets `n-1` edges | yes | yes |
| `expected_isolated` | `E[#isolated] = n·(1-p)^{n-1}` | yes | yes (Thm 6) |
| `card_triEdges` | a 3-set spans `3` edges | yes | yes |
| `expected_triangles` | `E[#triangles] = C(n,3)·p³` | yes | yes (Thm 7) |

## SecondMoment.lean — namespace `SecondMoment`

| Lean name | Mathematical statement | ARTICLE.md | RESEARCH_PAPER.md |
|---|---|---|---|
| `expect`/`variance` (def) | weighted mean / variance | yes | yes (Def 3) |
| `variance_nonneg` | `0 ≤ Var X` | — | yes (Prop 2) |
| `markov` | `a·P(X≥a) ≤ E X`, `X≥0` | yes | yes (Thm 8) |
| `chebyshev` | `P(|X-EX|≥a) ≤ Var X / a²` | yes | yes (Thm 9) |
| `second_moment_zero` | `P(X=0) ≤ Var X / (EX)²`, `EX>0` | yes | yes (Thm 10) |

## Threshold.lean — namespace `ErdosRenyiThreshold`

| Lean name | Mathematical statement | ARTICLE.md | RESEARCH_PAPER.md |
|---|---|---|---|
| `tendsto_expected_triangles` | `p=c/n ⇒ C(n,3)(c/n)³ → c³/6` | yes | yes (Thm 11) |
| `subcritical_triangles_vanish` | `n·pₙ→0 ⇒ C(n,3)pₙ³ → 0` | yes | yes (Thm 12) |
| `supercritical_triangles_blowup` | `n·pₙ→∞ ⇒ C(n,3)pₙ³ → ∞` | yes | yes (Thm 13) |
| `isolated_blowup_below_connectivity` | `p=c/n ⇒ n(1-p)^{n-1} → ∞` | yes | yes (Thm 14) |
