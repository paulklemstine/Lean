# Summary of changes for run 9ce5204f-1932-46bf-b812-3a3340f7fcdc
Added a new self-contained Lean development on the combinatorial frontier of tropical moduli of curves, plus its research roadmap.

**New files (under Catalog/Tropical/):**
- `ModuliCurves.lean` — formalizes combinatorial types of stable tropical curves with marked points. A type is modeled by its degree sequence `degs : Multiset ℕ` with the handshaking identity `∑ val(v) = 2E + n` and the connected-graph Euler relation `E + 1 = |V| + g`.
- `FUTURE_DIRECTIONS.md` — five testable, falsifiable research conjectures extending the work (graded face poset via contraction, vertex-weighted stability and the genus decomposition, enumeration of trivalent top cells, a bridge to Mathlib's graph theory `b₁ = 0 ⇔ forest`, and the integer balancing condition toward tropical subvarieties). Each includes a "key insight" and a "Why now?" justification.

**Theorems proved (no `sorry`; axioms limited to `propext` and `Quot.sound`):**
1. `StableGraph.edge_bound` — the marked dimension/edge bound `|E| ≤ 3g − 3 + n` (stated subtraction-free as `E + 3 ≤ 3g + n`), generalizing the classical `dim M_g^trop = 3g − 3` to n marked legs.
2. `StableGraph.unmarked_edge_bound` — the `n = 0` corollary `|E| + 3 ≤ 3g`.
3. `StableGraph.trivalent_eq` — sharpness: a trivalent type attains equality `|E| + 3 = 3g + n`.
4. `StableGraph.eq_bound_iff_trivalent` — equality in the bound holds iff the type is trivalent (the maximal cells of the moduli space are exactly the trivalent ones).
5. `genus_preserved_under_contraction` — contracting a non-loop edge lowers `|E|` and `|V|` by one while preserving genus `g` and leg count `n`, the arithmetic core of the cone-complex face-poset structure.
Supporting lemmas `three_card_le_sum`, `all_eq_three_of_sum`, and `sum_eq_three_card` are also fully proved.

The file type-checks cleanly against the project's Mathlib (verified via direct `lake env lean` compilation) with zero `sorry`/`admit`. Brief proof-sketch comments are included as `-- !-- ... -- !--` blocks. No prohibited prose/code artifacts were produced.