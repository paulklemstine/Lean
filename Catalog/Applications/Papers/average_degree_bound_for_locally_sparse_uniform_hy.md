# Theorem Trace (internal anti-hallucination ledger)

Every prose claim in ARTICLE.md and RESEARCH_PAPER.md must map to one of the
items below, which are extracted verbatim from the Phase A Lean source. No
result outside this table may be asserted as proved.

## Definitions

| Lean name | Mathematical statement | In ARTICLE.md | In RESEARCH_PAPER.md |
|---|---|---|---|
| `edgeSet` | `edgeSet S = S.powerset`: edges of the complete hypergraph on `S` (all subsets of `S`). | "every subset is allowed" framing | Def. 2.1 |
| `containedEdges` | `containedEdges E S = E ∩ edgeSet S = { e ∈ E : e ⊆ S }`. | "edges trapped inside S" | Def. 2.2 |
| `IsIndependent` | `IsIndependent E I ↔ ∀ e ∈ E, e.Nonempty → ¬ e ⊆ I`: `I` contains no nonempty hyperedge. | "independent set" | Def. 2.3 |
| `deletedVertices` | `deletedVertices E S = ⋃_{e ∈ containedEdges E S} {min' e}` (empty edges contribute ∅). | "one hostage per edge" | Def. 2.4 |
| `deterministic_deletion` | `deterministic_deletion E S = S \ deletedVertices E S`. | "the survivors" | Def. 2.5 |
| `degree` | `degree E v = |{ e ∈ E : v ∈ e }|`. | "degree" | Def. 2.6 |
| `averageDegree` | `averageDegree E S = (∑_{v∈S} degree E v) / |S|`. | "average degree δ" | Def. 2.7 |

## Lemmas and theorems

| Lean name | Statement | In ARTICLE.md | In RESEARCH_PAPER.md |
|---|---|---|---|
| `mem_containedEdges` | `e ∈ containedEdges E S ↔ e ∈ E ∧ e ⊆ S`. | implicit | Lemma 3.1 |
| `min'_mem_deletedVertices` | `e ∈ containedEdges E S → e.min' hne ∈ deletedVertices E S`. | "the hostage is gone" | Lemma 3.2 |
| `deterministic_deletion_subset` | `deterministic_deletion E S ⊆ S`. | "survivors are inside S" | Thm 3.3 |
| `deletedVertices_card_le` | `|deletedVertices E S| ≤ |containedEdges E S|`. | "at most one per edge" | Lemma 3.4 |
| `deterministic_deletion_independent` | `IsIndependent E (deterministic_deletion E S)`. | Main, "no edge survives" | Thm 3.5 |
| `deterministic_deletion_card_ge` | `|S| − |containedEdges E S| ≤ |deterministic_deletion E S|`. | Main size bound | Thm 3.6 |
| `deterministic_deletion_spec` | conjunction of subset + independent + size bound. | "the package" | Thm 3.7 |
| `containedEdges_card_le_sum_degree` | `|containedEdges E S| ≤ ∑_{v∈S} degree E v` (when all edges nonempty). | "counting edges by their vertices" | Lemma 3.8 |
| `deterministic_deletion_card_ge_of_averageDegree` | if all edges nonempty and `averageDegree E S ≤ δ` then `(1 − δ)·|S| ≤ |deterministic_deletion E S|`. | Main theorem (plain language) | Thm 3.9 |

All theorem names referenced in PACKAGE.json `key_results` come from this table.
