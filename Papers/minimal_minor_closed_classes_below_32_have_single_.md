# Theorem Trace (internal anti-hallucination ledger)

Every result below is taken verbatim from the Phase A Lean output. No theorem is
stated in ARTICLE.md / RESEARCH_PAPER.md that does not appear here.

## OrderFramework.lean (namespace `MinorTheory`, order `α` with `≤` = "is a minor of")

| Lean name | Mathematical statement | In ARTICLE | In PAPER |
|---|---|---|---|
| `MinorClosed` (def) | `C` downward closed: `x ≤ y → y ∈ C → x ∈ C` | yes | yes |
| `excl` (def) | `excl S = {x | ∀ s ∈ S, ¬ s ≤ x}` | yes | yes |
| `mem_excl` | membership unfolding of `excl` | — | yes |
| `excl_minorClosed` | `excl S` is minor-closed | yes | yes |
| `excl_anti` | `S ⊆ T → excl T ⊆ excl S` | — | yes |
| `minorClosed_univ` | `univ` is minor-closed | — | yes |
| `minorClosed_empty` | `∅` is minor-closed | — | yes |
| `MinorClosed.sInter` | intersection of minor-closed is minor-closed | — | yes |
| `MinorClosed.sUnion` | union of minor-closed is minor-closed | — | yes |
| `obstructions` (def) | `{m | m ∉ C ∧ ∀ x < m, x ∈ C}` | yes | yes |
| `SingleExcludedMinor` (def) | `∃ H, C = excl {H}` | yes | yes |
| `subset_excl_obstructions` | `MinorClosed C → C ⊆ excl (obstructions C)` | — | yes |
| `excl_obstructions_subset` | (WF) `excl (obstructions C) ⊆ C` | — | yes |
| `minorClosed_excl_obstructions` | (WF) `MinorClosed C → C = excl (obstructions C)` | yes | yes |
| `obstructions_excl_singleton` | (PO) `obstructions (excl {H}) = {H}` | yes | yes |
| `singleExcludedMinor_iff_obstructions_singleton` | (PO+WF) `SingleExcludedMinor C ↔ ∃ H, obstructions C = {H}` | yes | yes |

## ForestDensity.lean (namespace `MinorTheory.ForestDensity`, order = subgraph order on `SimpleGraph V`)

| Lean name | Mathematical statement | In ARTICLE | In PAPER |
|---|---|---|---|
| `acyclicClass` (def) | `{G | G.IsAcyclic}` | yes | yes |
| `acyclicClass_minorClosed` | forests are minor-closed (subgraph order) | yes | yes |
| `edgeDensity` (def) | `|E| / |V| : ℚ`, `0` if `V` empty | yes | yes |
| `IsAcyclic.card_edgeSet_add_one_le` | nonempty forest: `|E| + 1 ≤ |V|` | yes | yes |
| `IsTree.edgeDensity_lt_one` | tree: density `< 1` | yes | yes |
| `acyclic_edgeDensity_lt_threshold` | forest: density `< 3/2` | yes | yes |
| `acyclicClass_below_threshold` | whole forest class below `3/2` | yes | yes |

## BoundedDegreeBelowThreshold.lean (namespace `MinorTheory.Novelty.BoundedDegree`, subgraph order)

| Lean name | Mathematical statement | In ARTICLE | In PAPER |
|---|---|---|---|
| `MinorClosed` (def) | local copy: downward closed under `≤` on `SimpleGraph V` | yes | yes |
| `edgeDensity` (def) | `|E| / |V| : ℚ` | yes | yes |
| `boundedDegreeClass` (def) | `{G | G.maxDegree ≤ d}` | yes | yes |
| `maxDegree_mono` | `G ≤ G' → G.maxDegree ≤ G'.maxDegree` | yes | yes |
| `boundedDegreeClass_minorClosed` | `{G | maxDegree ≤ d}` minor-closed | yes | yes |
| `edgeFinset_card_le_of_maxDegree_two` | `maxDegree ≤ 2 → |E| ≤ |V|` | yes | yes |
| `maxDegree_two_edgeDensity_lt` | `maxDegree ≤ 2 → density < 3/2` | yes | yes |
| `boundedDegreeTwoClass_below_threshold` | whole degree-≤2 class below `3/2` | yes | yes |

## SingleForbiddenMinorLattice.lean (partial header only — truncated in source)

| Lean name | Status |
|---|---|
| `minorIdeal G` (def) | principal down-set `↓G = {x | x ≤ G}` — header confirmed |
| `excl_singleton_eq_sUnion_avoiding` | named in lab notes / future directions as proved this cycle (largest class avoiding `H`) — referenced narratively, not as a headline key_result |
| `obstructions_antichain` | named in lab notes / future directions as proved this cycle — referenced narratively, not as a headline key_result |

Headline `key_results` (all fully confirmed full proofs):
`singleExcludedMinor_iff_obstructions_singleton`, `minorClosed_excl_obstructions`,
`acyclicClass_below_threshold`, `boundedDegreeClass_minorClosed`,
`maxDegree_two_edgeDensity_lt`.
