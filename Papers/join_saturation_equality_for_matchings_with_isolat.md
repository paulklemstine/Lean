# THEOREM TRACE (internal anti-hallucination ledger)

Source of truth: `Catalog/Applications/ExtremalGraph/Saturation.lean` (Phase A output).
Every claim in ARTICLE.md and RESEARCH_PAPER.md must map to one of the entries below.
No theorem is paraphrased into a grander claim; the open conjecture is labeled as open.

| Lean name | Kind | Mathematical statement | In ARTICLE.md | In RESEARCH_PAPER.md |
|---|---|---|---|---|
| `edgeCount` | def | `edgeCount G = G.edgeSet.ncard`, the number of edges of `G`. | "counting edges" | Def. 1 |
| `IsSaturated` | def | `G` is `H`-saturated: `H` does not embed in `G`, and for all `a ≠ b` with `¬G.Adj a b`, `H ⊑ G ⊔ {ab}`. | "saturated graph" definition | Def. 2 |
| `exNum` | def | `exNum H n = sup` of `edgeCount` over all `H`-free `G` on `Fin n` (Turán/extremal number). | "extremal number ex(n,H)" | Def. 3 |
| `satNum` | def | `satNum H n = sInf {m | ∃ H-saturated G on Fin n with edgeCount G = m}` (saturation number). | "saturation number sat(n,H)" | Def. 4 |
| `free_bot_of_adj` | thm | If `H.Adj a b` then `H` is free over the empty graph `⊥`. | (background, empty graph) | Lemma 1 |
| `edgeCount_lt_addEdge` | thm | For finite `V`, `a ≠ b`, `¬G.Adj a b`: `edgeCount G < edgeCount (G ⊔ {ab})`. | "adding an edge strictly increases the count" | Lemma 2 |
| `exists_isSaturated` | thm | If `H` has an edge, then for every `n` there exists an `H`-saturated graph on `Fin n`. | "saturated graphs always exist" | Theorem 1 |
| `satNum_le_exNum` | thm | If `H` has an edge, `satNum H n ≤ exNum H n`. | "sat(n,H) ≤ ex(n,H)" | Theorem 2 |
| `cone` | def | `cone H` = apex join `K₁ ∨ H` on `Option V`: apex `none` adjacent to all `some _`, `H` on `some _`. | "cone / apex join" | Def. 5 |
| `edgeCount_cone` | thm | `edgeCount (cone H) = Fintype.card V + edgeCount H`, i.e. `e(K₁∨H) = m + e(H)`. | "joining an apex adds exactly m edges" | Theorem 3 |
| `matchingPlusIsolated` | def | `tK₂ ∪ qK₁` on `Fin (2t+q)`: edges between `i,j < 2t` with `i/2 = j/2`, `i ≠ j`; vertices `≥ 2t` isolated. | "the graph F = tK₂ ∪ qK₁" | Def. 6 |
| `CameronPuleoEquality` (conjecture) | Prop | For `t ≥ 1, q ≥ 1, n > 2t+q`: `sat(n, K₁∨(tK₂∪qK₁)) = (n−1) + sat(n−1, tK₂∪qK₁)`. Proved `t=1,2`; open in general. | main "headline" (labeled open) | Conjecture C1 / Sec. main |
| `satNum_clique_le_turan` | thm (companion file) | `sat(n, K_{r+1}) ≤ e(T(n,r))` (Turán bridge). Referenced in future directions. | (future directions) | Sec. future work |

Notes:
- `CameronPuleoEquality` is stated in Lean only as a `Prop` and is **open** for general `t`
  (the source paper proves `t = 1` and `t = 2`). It must NOT be presented as proved.
- The fully proved formal contributions are: `exists_isSaturated`, `satNum_le_exNum`,
  `edgeCount_cone` (plus the supporting `free_bot_of_adj`, `edgeCount_lt_addEdge`), and the
  two family/operation definitions `cone`, `matchingPlusIsolated`.
