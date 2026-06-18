# Future Directions: Forbidden Minors in Proof Complexity

## Synthesis

The work presented here establishes a foundational bridge between structural graph theory (graph minors, pathwidth) and proof complexity (clause space, resolution). The key insight is that configuration graphs — the state-transition graphs of resolution proofs — carry combinatorial structure that constrains proof memory requirements. We have formalized the core definitions (literals, clauses, CNF formulas, configurations, resolution, configuration graphs, path minors, and resolution entropy) and proved fundamental structural results including the path minor vertex count theorem, inclusion-exclusion for clause sets, entropy monotonicity, and the self-MI identity.

The following five directions extend this framework toward a complete theory of "structural proof complexity via graph minors." Each direction is falsifiable, builds on our formalized results, and bridges multiple mathematical domains.

---

## Direction 1: Minor-Space Correspondence Conjecture

**Conjecture**: There exist absolute constants $c, d > 0$ such that for all unsatisfiable CNF formulas $F$:
$$\frac{1}{d} \cdot \text{clauseSpace}(F) \leq \text{maxPathMinorWidth}(\text{bConfGraph}(F, \text{clauseSpace}(F))) \leq c \cdot \text{clauseSpace}(F)$$

**Test**: For all non-isomorphic unsatisfiable CNF formulas over $n = 3, 4, 5$ variables:
1. Compute `clauseSpace(F)` by exhaustive resolution refutation search.
2. Compute `maxPathMinorWidth(bConfGraph(F, clauseSpace(F)))` by minor detection.
3. Plot `clauseSpace` vs. `maxPathMinorWidth` and fit the linear relationship.
4. If the ratio `maxPathMinorWidth / clauseSpace` grows or shrinks unboundedly with $n$, the conjecture fails.

**Impact**: This would establish that clause space — a proof complexity measure — is equivalent (up to constants) to a purely graph-theoretic parameter. This would import the entire machinery of Robertson-Seymour theory into proof complexity.

**Catalog References**: 
- `Pythagorean/ForbiddenMinor/Defs.lean`: `clauseSpace`, `bConfGraph`, `maxPathMinorWidth`, `PathMinorOfWidth`
- `Pythagorean/ForbiddenMinor/Theorems.lean`: `path_minor_total_vertices`
- `Catalog/Pythagorean/ConfigGraph/Theorems.lean`: `pathwidth_le_of_spaceBound`

**Proof Strategy**: 
- Upper bound ($\leq c \cdot \text{clauseSpace}$): Use the trace-to-pathwidth correspondence from `pathwidth_le_of_spaceBound`. Any refutation trace with interval property gives a path decomposition of width ≤ clauseSpace. Convert this to a path minor bound.
- Lower bound ($\geq \frac{1}{d} \cdot \text{clauseSpace}$): This is the harder direction. Use an information bottleneck argument: any path through the configuration graph must pass through a "bottleneck" where at least $\Omega(\text{clauseSpace})$ clauses are simultaneously in memory.

**Domain Bridges**: Graph Minor Theory ↔ Proof Complexity ↔ Information Theory

**Lineage**: Extends Ben-Sasson–Wigderson width-space relationship (2001) and Atserias–Dalmau space-pathwidth correspondence (2008).

**Ambition**: Grand challenge — would create the field of "structural proof complexity."

---

## Direction 2: Resolution DPI Tightness

**Conjecture**: The Resolution Data Processing Inequality holds for the set-theoretic mutual information `resMutualInfo`, and equality holds if and only if the resolution step is a bijection on clause sets (i.e., a renaming, not a proper resolution or erasure).

**Test**:
1. Enumerate all possible single-step transitions $C_1 \to C_2$ for small configurations.
2. For each transition, compute `resMutualInfo(C_1, C_3)` vs. `resMutualInfo(C_1, C_2)` for all reachable $C_3$.
3. Verify $I(C_1; C_3) \leq I(C_1; C_2)$ computationally.
4. Characterize when equality holds.

**Impact**: Would establish that resolution has its own information theory, with clause space playing the role of channel capacity.

**Catalog References**:
- `Pythagorean/ForbiddenMinor/Defs.lean`: `resMutualInfo`, `resEntropy`, `ConfigAdj`
- `Pythagorean/ForbiddenMinor/Theorems.lean`: `resolution_mutual_info_self`, `entropy_mono_add`

**Proof Strategy**: Case-analyze on the three types of resolution steps (axiom introduction, resolution, erasure). For each, show that the step acts as a "lossy channel" using the log-sum inequality and inclusion-exclusion.

**Domain Bridges**: Information Theory ↔ Proof Complexity

**Lineage**: Analogous to Shannon's Data Processing Inequality (1948), applied to the discrete setting of clause sets.

**Ambition**: Solid extension — would create "resolution information theory."

---

## Direction 3: Finite Obstruction Set for Clause Space

**Conjecture**: For each $k \geq 1$, the set of minor-minimal formulas with clause space $\geq k$ is finite.

**Test**:
1. For $k = 2, 3, 4$, enumerate all unsatisfiable CNF formulas with clause space $\geq k$.
2. Compute the minor order on their configuration graphs.
3. Find the minor-minimal elements.
4. Verify that the set is finite for each $k$.

**Impact**: Would import the Robertson-Seymour finite basis theorem into proof complexity, giving a finite "hardness certificate" for each clause space level.

**Catalog References**:
- `Pythagorean/ForbiddenMinor/Defs.lean`: `PathMinorOfWidth`, `clauseSpace`
- `Catalog/Pythagorean/ConfigGraph/Defs.lean`: `PathDecomposition`, `BoundedConfigAdj`

**Proof Strategy**: Define the appropriate minor order on CNF formulas via their configuration graphs. Show that this order is a well-quasi-order (by embedding into the graph minor order, which is a WQO by Robertson-Seymour). Apply the finite basis theorem.

**Domain Bridges**: Well-Quasi-Orders ↔ Proof Complexity ↔ Structural Graph Theory

**Lineage**: Directly imports Robertson-Seymour Graph Minor Theorem (1983-2004).

**Ambition**: Grand challenge — would give a completely new structural characterization of proof hardness.

---

## Direction 4: Tropical Dimension Equals Clause Space for Monotone Formulas

**Conjecture**: For monotone unsatisfiable CNF formulas (no negated literals), the clause space equals the tropical dimension of the configuration graph viewed as a tropical variety.

**Test**:
1. Define the tropical embedding: map each configuration to a point in $\mathbb{T}^N$ (tropical semiring).
2. Compute the tropical dimension of the configuration space for small monotone formulas.
3. Compare with the clause space.

**Impact**: Would connect proof complexity to tropical geometry, importing tools from algebraic geometry.

**Catalog References**:
- `Pythagorean/ForbiddenMinor/Defs.lean`: `Config`, `Clause`, `Literal`

**Proof Strategy**: Show that monotone formulas have configuration graphs whose tropical convex hulls have dimension equal to the maximum clause set size. The monotonicity constraint eliminates cancellations in the tropical semiring.

**Domain Bridges**: Tropical Geometry ↔ Proof Complexity

**Lineage**: Novel connection; builds on tropical geometry foundations.

**Ambition**: Speculative — would open an entirely new research direction.

---

## Direction 5: W[1]-Hard Formulas Contain Grid Minors

**Conjecture**: If deciding whether a parameterized CNF formula family has clause space $\leq k$ is W[1]-hard (parameterized by $k$), then the configuration graphs of formulas in the family contain $k \times k$ grid minors.

**Test**:
1. Identify known W[1]-hard formula families (e.g., certain constraint satisfaction problems).
2. Construct their configuration graphs for small instances.
3. Search for grid minors algorithmically.
4. Correlate grid minor size with the parameterized complexity.

**Impact**: Would connect the W-hierarchy of parameterized complexity to the minor hierarchy of structural graph theory.

**Catalog References**:
- `Pythagorean/ForbiddenMinor/Defs.lean`: `bConfGraph`, `PathMinorOfWidth`
- `Pythagorean/ForbiddenMinor/Theorems.lean`: `path_minor_total_vertices`

**Proof Strategy**: Use the Grid Minor Theorem (Robertson-Seymour-Thomas): graphs of treewidth $\geq f(k)$ contain $k \times k$ grid minors. Show that W[1]-hardness implies large treewidth of configuration graphs. The connection goes through the fixed-parameter tractability of bounded-treewidth problems.

**Domain Bridges**: Parameterized Complexity ↔ Graph Minor Theory ↔ Proof Complexity

**Lineage**: Connects Downey-Fellows parameterized complexity (1999) with Robertson-Seymour theory.

**Ambition**: Grand challenge — would unify three major areas of theoretical computer science.
