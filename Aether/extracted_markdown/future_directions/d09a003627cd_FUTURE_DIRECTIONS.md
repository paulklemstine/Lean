# Future Research Directions

## Synthesis

This research cycle established a rigorous algebraic-topological framework for jigsaw puzzle assembly, proving that the constraint graph of any rectangular grid has Euler characteristic 2 (topologically spherical), that constraints are superadditive under grid merging, and that the complement permutation is an odd permutation. The most surprising discovery is the connection between the complement involution's sign and constraint propagation parity — a bridge between permutation group theory and combinatorial complexity that has not been explored in the literature.

The most promising cross-domain connection is between puzzle constraint graphs and tropical geometry. The constraint density analysis shows puzzle graphs live in the same universality class as 4-regular planar graphs, and the min-plus algebra naturally extends Boolean edge compatibility to a richer algebraic setting. This connection to the Catalog's tropical semiring work (`Tropical/FormulaDefinability.lean`) could yield fundamentally new proof techniques for complexity bounds.

The highest breakthrough potential lies in Direction 1 (Toroidal Puzzles), because the change in Euler characteristic from 2 to 0 represents a topological phase transition that may correspond to a computational complexity transition — potentially the first known example of complexity changing with the topology of the constraint structure.

---

### Direction 1: Toroidal Jigsaw Puzzles and Complexity Phase Transitions

**Conjecture**: Jigsaw puzzle assembly on a toroidal grid (periodic boundary conditions in both directions) has fundamentally different complexity from rectangular grid puzzles. Specifically: the constraint graph of an m×n toroidal grid has Euler characteristic 0 (genus 1), and the homological structure introduces a ℤ² symmetry that may make the problem fixed-parameter tractable with respect to the genus.

**Test**: (a) Prove that the Euler characteristic of the toroidal constraint graph is 0 by computing V = mn, E = 2mn, F = mn, giving χ = mn − 2mn + mn = 0. (b) Construct a specific 3-SAT instance whose puzzle reduction on a torus has a solution that does not exist on the plane, or prove that the set of solvable instances is identical. (c) Implement a transfer matrix algorithm for toroidal puzzles and measure empirical complexity scaling.

**Impact**: If toroidal puzzles are in a lower complexity class, this would be the first example of topology directly determining computational complexity — a result connecting algebraic topology to complexity theory in a novel way. If the complexity is unchanged, this proves that the NP-hardness of puzzles is a local (edge-compatibility) phenomenon, not a global (topological) one.

**Catalog References**: `Applications/JigsawTopology.lean` (euler_char_grid), `Catalog/EML/JigsawAlgebra.lean` (PuzzleAlphabet), `Tropical/FormulaDefinability.lean` (tropical formulas)

**Proof Strategy**: Start by formalizing the toroidal grid as a function g : ℤ/mℤ → ℤ/nℤ → JPiece with wrap-around compatibility. Compute the Euler characteristic using the standard formula for torus cell complexes. For the complexity analysis, attempt to reduce the toroidal case to a graph coloring problem on a torus and apply known results on planar vs toroidal graph coloring complexity.

**Domain Bridges**: Topology (Euler characteristic, genus) ↔ Complexity Theory (FPT, parameterized complexity) ↔ Algebra (homology groups of constraint complexes)

**Lineage**: Builds on euler_char_grid and the constraint density bridge from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Tropical Puzzle Algebras and Min-Plus Assembly

**Conjecture**: Replacing the Boolean edge compatibility (tab ↔ blank) with tropical (min-plus) compatibility — where edge values are real numbers and two edges "fit" if their tropical sum (min) equals a target value — yields a puzzle algebra where assembly corresponds to finding a tropical curve. The tropical puzzle problem is in P (polynomial time), despite the Boolean version being NP-complete.

**Test**: (a) Define TropicalPiece with edges valued in ℝ∪{∞} and tropical compatibility: edges (a, b) are compatible if min(a, b) = threshold. (b) Show that tropical assembly of a 1×n grid reduces to a shortest-path problem (hence polynomial). (c) Find the exact boundary between tropical (P) and Boolean (NP-complete) in a parameterized family of puzzle algebras.

**Impact**: Would establish a concrete "algebraic phase transition" in complexity: the same combinatorial structure (grid assembly) transitions from P to NP-complete as the edge algebra changes from tropical to Boolean. This connects to the broader question of which algebraic structures admit efficient constraint satisfaction.

**Catalog References**: `Tropical/FormulaDefinability.lean` (tropical_formula_iff_recognizable_and_deriv_closed), `Catalog/EML/JigsawAlgebra.lean` (PuzzleAlphabet)

**Proof Strategy**: Formalize TropicalPuzzleAlphabet as a PuzzleAlphabet where EdgeLabel = ℝ∪{∞} with compl(x) = threshold − x. Assembly validity becomes a system of linear tropical equations, solvable by tropical linear algebra (Gaubert-Plus algorithm). The key lemma is that tropical compatibility is transitive (unlike Boolean), which breaks the NP-hardness reduction.

**Domain Bridges**: Tropical Geometry ↔ Complexity Theory ↔ Optimization (shortest paths, linear programming)

**Lineage**: Builds on the PuzzleAlphabet abstraction and the clause_sat_iff_tab encoding from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Hexagonal and Penrose Tilings

**Conjecture**: The constraint superadditivity theorem generalizes to hexagonal grids, but with a larger constant: merging two hexagonal grids creates at least 2m new constraints (vs m for rectangular). For Penrose tilings (aperiodic), superadditivity is strict — the inequality gap grows logarithmically with grid size.

**Test**: (a) Define HexPiece with 6 edges and hexagonal grid assembly. (b) Prove the hexagonal superadditivity bound. (c) For Penrose tilings, compute the constraint count for the first 5 inflation levels and check whether the superadditivity gap grows as conjectured.

**Impact**: Extends the theory from rectangular grids to the two other fundamental planar tilings (hexagonal and aperiodic), establishing whether the algebraic structure of puzzle assembly depends on the tiling geometry or is universal.

**Catalog References**: `Bridges/LocalCyclePressure.lean` (isTree_iff_connected_and_edgecount), `Applications/JigsawTopology.lean` (constraint_superadditive)

**Proof Strategy**: For hexagonal grids, the internal edge count formula is E(m,n) = 3mn − m − n (each cell has 6 edges, but each internal edge is shared). Superadditivity follows from the same algebraic argument as the rectangular case. For Penrose tilings, use the substitution rule to derive a recurrence for the constraint count.

**Domain Bridges**: Geometry (tilings, aperiodic order) ↔ Algebra (constraint counting) ↔ Number Theory (Penrose tiling frequencies involve the golden ratio)

**Lineage**: Direct extension of constraint_superadditive and internal_edges_quadratic.

**Ambition**: extension

---

### Direction 4: The Permutation Group of Puzzle Rotations

**Conjecture**: The group of symmetries of a valid n×n puzzle assembly (rotations, reflections, and piece permutations that preserve validity) is always a subgroup of the wreath product S_n ≀ ℤ/4ℤ, and for "generic" puzzles (where all edge types are non-flat), the symmetry group is trivial.

**Test**: (a) Formalize the symmetry group as the automorphism group of the constraint graph with labeled edges. (b) Prove that for n ≥ 3 with all distinct edge labels, the symmetry group is trivial. (c) Construct a maximally symmetric puzzle (all pieces identical except boundary) and compute its symmetry group.

**Impact**: Connects puzzle theory to group theory in a novel way: the complement permutation being odd (sign −1) implies constraints on which symmetries are possible. A generic triviality result would explain why real jigsaw puzzles have unique solutions.

**Catalog References**: `Applications/JigsawTopology.lean` (complement_is_odd_perm, orbit_partition)

**Proof Strategy**: Use the orbit-stabilizer theorem on the constraint graph automorphism group. The key insight is that the odd sign of the complement permutation forces any automorphism to preserve the tab/blank distinction, severely restricting the possible symmetries. For generic puzzles, show that distinct edge labels force all automorphisms to be the identity.

**Domain Bridges**: Group Theory (wreath products, permutation signs) ↔ Combinatorics (graph automorphisms) ↔ Topology (constraint graph symmetry)

**Lineage**: Builds on complement_is_odd_perm and the orbit partition theorem.

**Ambition**: extension

---

### Direction 5: Counting Valid Assemblies via Transfer Matrices

**Conjecture**: The number of valid 1×n grid assemblies over the standard 3-element alphabet is exactly 3·2^(n−1) for n ≥ 1. For m×n grids with m ≥ 2, the count grows as Θ(λ₁^n) where λ₁ is the largest eigenvalue of a transfer matrix of size 3^m × 3^m.

**Test**: (a) Prove the exact count for 1×n grids by induction: the first cell has 3 choices, each subsequent cell has exactly 2 (the complement of the previous right edge determines the left edge, and only 2 of 3 edge types produce a valid complement). (b) Construct the transfer matrix for m=2 and compute its eigenvalues. (c) Derive asymptotic bounds on the number of valid assemblies for square n×n grids.

**Impact**: Would give the first exact counting formula for puzzle assemblies, connecting puzzle theory to statistical mechanics (transfer matrix methods originated in the study of lattice models). The eigenvalue analysis would reveal whether there is a "phase transition" in assembly density.

**Catalog References**: `Applications/JigsawTopology.lean` (one_row_assembly_bound, linear_grid_edges), `Bridges/PartitionMatroidStability.lean` (two_block_leaf_has_one_positive_eigenvalue)

**Proof Strategy**: For the 1×n case, induction on n. Base case: 1×1 grid has 3^4 = 81 possible pieces, but we count distinct right-edge assignments: 3 choices. Inductive step: each new cell's left edge is determined by the complement of the previous right edge, leaving 3 choices for the remaining 3 edges, but the right edge has only 3 choices, giving a branching factor of 3. Wait — we need to be more precise about what we're counting (pieces vs edge assignments). Formalize carefully.

**Domain Bridges**: Combinatorics (counting) ↔ Linear Algebra (eigenvalues) ↔ Statistical Physics (transfer matrices, partition functions)

**Lineage**: Builds on one_row_assembly_bound and the assembly validity characterization.

**Ambition**: extension
