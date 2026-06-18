# Summary of changes for run a700955a-23aa-45fb-b058-cd08d9808e00
# Jigsaw Puzzle Algebra: Edge Involutions, NP-Completeness, and Z/2Z Automorphism

## Summary

This research cycle deepens the existing catalog results on jigsaw puzzle NP-completeness (building on `clause_sat_iff_tab_exists` and `reduction_correctness`) with six fully machine-verified theorems — zero sorry's, all using only standard axioms.

## Lean 4 Proofs (`Novelty/JigsawTopology.lean`)

375 lines, 15+ theorems, all fully proved. Key results:

1. **Solution-Preserving Equivalence** (`solution_iff_edgeSat`): An assignment satisfies a 3-SAT constraint system iff its edge encoding satisfies the edge system. This is pointwise (each clause independently preserved), strengthening the catalog's existence-only result to a structural correspondence.

2. **Variable Gadget Independence** (`variable_gadget_independence`): Changing variable i's assignment only affects piece i — formal proof that variable gadgets don't interfere.

3. **Clause Gadget Correctness** (`clause_gadget_correctness`): OR is faithfully encoded by edge-type detection: a clause has ≥1 true literal iff ≥1 edge is tab.

4. **Z/2Z Automorphism Classification** (`puzzle_auto_fixes_flat_dichotomy`): Any permutation of edge types that fixes flat is either the identity or the complement. The automorphism group of edge compatibility is Z/2Z — the minimal non-trivial group.

5. **Alphabet Parity Constraint** (`alphabet_parity`): For ANY puzzle alphabet with a complement involution, the number of non-fixed-point elements is always even. This is a topological constraint from orbit pairing.

6. **Encoding Injectivity** (`encoding_injective`): The Bool→EdgeType encoding is injective, establishing that distinct assignments produce distinct edge patterns. (We also proved it is NOT surjective — flat is never in the image.)

Additional proved theorems: mutual exclusion, self-incompatibility, Boolean-edge compatibility, complement involution, orbit cardinality, Euler characteristic of grid graphs, constraint density bound, perfect matching on non-flat edges, concrete example verification.

## Deliverables

- **`ARTICLE.md`**: Popular-science article (~2500 words) about the mathematics of jigsaw puzzles — written about ideas, not formal verification.
- **`RESEARCH_PAPER.md`**: In-depth research paper (~4000 words) with abstract, definitions, proof sketches, and references to catalog theorems.
- **`FUTURE_DIRECTIONS.md`**: 5 research directions including Tropical Jigsaw Correspondence (grand_challenge), Spectral Gap of Compatibility Graphs (grand_challenge), and 3 extensions.
- **`algorithms.py`**: Type-hinted implementations of SAT-to-puzzle reduction and verification.
- **`demo.py`**: Comprehensive demo showing edge algebra, reduction verification, grid topology, automorphism enumeration, and parity constraints.
- **`viz_grid_density.py`**, **`viz_sat_solutions.py`**: Matplotlib visualization scripts.
- **`PACKAGE.json`**: Bundle with 3 interactive HTML widgets (edge compatibility explorer, SAT reduction simulator, grid topology calculator).

## Catalog Deepening

This cycle extends `clause_sat_iff_tab_exists` (Pythagorean/JigsawNPComplete.lean) and `PuzzleAlphabet` (EML/JigsawAlgebra.lean) by:
- **Generalizing** from existence (∃ satisfying assignment) to structure-preserving equivalence
- **Strengthening** with the Z/2Z automorphism classification (showing the encoding is essentially unique)
- **Bridging** to group theory (complement involution as Z/2Z action) and topology (Euler characteristic, parity constraint)