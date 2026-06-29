# Theorem Trace — Degree-normalized linked tree-cut decompositions

Internal anti-hallucination ledger. Every name below is taken verbatim from the
Phase A Lean output (`Catalog/Novelty/DegreeNormalizedTreeCut/Core.lean`,
`Catalog/Novelty/DegreeNormalizedTreeCut/SequenceLemmas.lean`) and the imported
`Catalog/Bridges/TreeCut/Decomposition.lean`. No other results are claimed in the
prose deliverables.

| Lean name | Kind | Mathematical statement | In ARTICLE.md | In RESEARCH_PAPER.md |
|---|---|---|---|---|
| `displayedEdgeDegree` | def | `displayedEdgeDegree e := ⨅ₙ \|F_{e_n}\|`, the infimum of adhesion sizes along a ray | "the displayed edge-degree" | Def. 5 |
| `degreeNormalized_finite` | thm | If adhesions are nested (`F_{e_{n+1}} ⊆ F_{e_n}`) then `∃ N₀, ∀ n ≥ N₀, \|F_{e_n}\| = displayedEdgeDegree e` | "exact stabilization" example | Thm. 1 |
| `degreeNormalized_finite_minCut` | thm | If `Linked` and adhesions nested then `∃ N₀, ∀ n ≥ N₀, minCut(side(e_n)) = displayedEdgeDegree e` | "the bottleneck settles" | Thm. 2 |
| `degreeNormalized_infinite` | thm | If `n ↦ \|F_{e_n}\|` is monotone and unbounded then `∀ k, ∃ N₀, ∀ n ≥ N₀, k ≤ \|F_{e_n}\|` | "divergence to infinity" | Thm. 3 |
| `degreeNormalization_dichotomy` | thm | If `n ↦ \|F_{e_n}\|` is monotone or antitone then either it is eventually constant `= d`, or it diverges | "the great dichotomy" | Thm. 4 |
| `antitone_nat_eventually_eq_iInf` | thm | An antitone `f : ℕ → ℕ` satisfies `∃ N, ∀ n ≥ N, f n = ⨅ k, f k` | "an antitone count must settle" | Lem. 1 |
| `monotone_nat_eventually_const_of_bddAbove` | thm | A bounded monotone `f : ℕ → ℕ` is eventually constant | implicit (finite case) | Lem. 2 |
| `monotone_nat_unbounded_eventually_ge` | thm | A monotone unbounded `f : ℕ → ℕ` eventually exceeds every `k` | "monotone unbounded diverges" | Lem. 3 |
| `eventually_const_or_diverges` | thm | A monotone-or-antitone `f : ℕ → ℕ` is eventually constant or diverges | "the great dichotomy" | Lem. 4 |
| `linked_adhesion_eq_minCut` | thm (imported) | For a `Linked` decomposition, `\|adhesion e\| = minCut(side e)` | "the adhesion is the bottleneck" | Thm. 2 / Prop. A |
| `adhesion_card_antitone_of_nested` | thm (imported) | Nested adhesions along a ray give antitone sizes | "nesting forces shrinking" | Prop. B |

Counterexample recorded (NOT a theorem, used only as a cautionary remark):
the oscillating sequence `1,2,1,2,…` is neither eventually constant nor
divergent, witnessing that monotonicity is load-bearing in
`degreeNormalization_dichotomy`.
