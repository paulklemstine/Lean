# Theorem Trace — SparseThresholdFractionalIndependence.lean

Internal anti-hallucination ledger. Every name below is taken **verbatim** from the
Phase A Lean output. No theorem appears in ARTICLE.md / RESEARCH_PAPER.md that is not
listed here.

| Lean name | Kind | Mathematical statement | In ARTICLE.md | In RESEARCH_PAPER.md |
|---|---|---|---|---|
| `FracIndepFeasible` | def | `x : V → ℝ` is feasible iff `∀v, 0 ≤ x v ≤ 1` and `∀ uv ∈ E, x u + x v ≤ 1` | yes (the "budget" rules) | yes (Def. 2.1) |
| `fracIndepValue` | def | `fracIndepValue x = ∑_v x v` | yes (the "score") | yes (Def. 2.2) |
| `fracIndepValueSet` | def | `{ s : ℝ | ∃ x, FracIndepFeasible G x ∧ s = fracIndepValue x }` | implicit | yes (Def. 2.3) |
| `alphaStar` | def | `α*(G) = sSup (fracIndepValueSet G)` | yes (the headline quantity) | yes (Def. 2.4) |
| `fracIndepValueSet_nonempty` | lemma | the value set is nonempty (witnessed by `x = 0`) | no | yes (Lem. 3.1) |
| `fracIndepValue_le_card` | lemma | feasible `x` ⇒ `∑_v x v ≤ |V|` | implicit | yes (Lem. 3.2) |
| `fracIndepValueSet_bddAbove` | lemma | the value set is bounded above by `|V|` | no | yes (Lem. 3.3) |
| `alphaStar_le_card` | theorem | `α*(G) ≤ |V|` | yes | yes (Thm. 3.4) |
| `half_feasible` | lemma | the constant assignment `x ≡ 1/2` is feasible | yes (the "all-half certificate") | yes (Lem. 3.5) |
| `half_card_le_alphaStar` | theorem | `|V|/2 ≤ α*(G)` | yes (main lower bound) | yes (Thm. 3.6) |
| `alphaStar_le_card_sub_one_of_edge` | theorem | `G.Adj a b ⇒ α*(G) ≤ |V| − 1` | yes (one edge breaks the ceiling) | yes (Thm. 3.7) |
| `alphaStar_completeGraph` | theorem | `2 ≤ |V| ⇒ α*(⊤) = |V|/2` | yes (complete-graph exact value) | yes (Thm. 3.8) |

Notes:
- The "sandwich" `|V|/2 ≤ α*(G) ≤ |V|` is exactly `half_card_le_alphaStar` + `alphaStar_le_card`.
- The complete-graph upper bound uses the double-count `(2n−2)·∑x ≤ n(n−1)`; the lower bound
  direction of `alphaStar_completeGraph` is `half_card_le_alphaStar` specialised to `⊤`.
- No closed form `C_T(s) = (1−1/s)·s^{−1/(s−1)}` is *proved* in this file; it appears only in the
  Phase A future-directions section and is presented as a conjecture everywhere it is mentioned.
