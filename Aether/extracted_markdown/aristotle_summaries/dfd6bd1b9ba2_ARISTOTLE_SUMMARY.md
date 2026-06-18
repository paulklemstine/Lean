# Summary of changes for run f2bf6f3f-33f3-4cbc-b181-786c824db6a8
Created a new, fully-proven Lean 4 development on the combinatorial types of tropical moduli curves.

**New files**
- `Tropical/MarkedModuli.lean` — a self-contained formalization (builds cleanly, zero `sorry`, only the standard `propext`/`Classical.choice`/`Quot.sound` axioms).
- `Tropical/FUTURE_DIRECTIONS.md` — five testable, falsifiable research conjectures, each with a "key insight" and a "Why now?" justification.

**The structure.** `MarkedCombType` models the combinatorial type of a stable tropical curve of genus `g` with `n` marked points (legs), recorded by the multiset of vertex valences `degs`, the edge count `numEdges`, and the leg count `n`, subject to stability (`deg ≥ 3`), the handshake identity `∑ deg(v) = 2|E| + n`, and connectivity `|V| ≤ |E| + 1`. Genus is the first Betti number `|E| − |V| + 1`.

**Theorems proved (all complete, no `sorry`):**
- `three_card_le_sum` — the handshake lower bound `3|V| ≤ ∑ deg(v)`.
- `marked_edge_bound` — the sharp dimension bound `|E| + 3 ≤ 3g + n` (i.e. `|E| ≤ 3g − 3 + n`).
- `unmarked_edge_bound` — the unmarked specialization `|E| + 3 ≤ 3g`.
- `genus_zero_iff_tree` — the tree characterization `g = 0 ↔ |E| + 1 = |V|`.
- `genus_contraction` — contracting a non-loop edge lowers `|E|` and `|V|` by one while preserving genus and leg count, realizing the boundary maps of the moduli face poset.
- `exists_tight_trivalent` — for every `g ≥ 2` there is an unmarked trivalent type with `|E| = 3g − 3`, proving the bound sharp.

A worked example (`theta2`, the genus-2 theta graph) and `example` blocks demonstrate the results on a concrete saturating type.

Each theorem carries a brief `-- !--` proof-sketch comment. The work is original (no pre-existing `MarkedModuli`/`MarkedCombType` in the catalog) and fits the existing `Tropical/` library conventions.