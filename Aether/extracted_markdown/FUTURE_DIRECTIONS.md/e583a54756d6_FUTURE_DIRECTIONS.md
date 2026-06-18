# Future Directions: E-Graph Extraction as Approximate Quotient Section

## Synthesis

The formal verification of e-graph extraction as a quotient section opens a rich landscape of research directions connecting compiler optimization, universal algebra, computational complexity, and information theory. The five directions below form a coherent program: Direction 1 extends the algebraic foundations to handle real-world term languages; Direction 2 connects the lattice-theoretic framework to tropical geometry; Direction 3 attacks the central open problem of extraction complexity; Direction 4 bridges to type theory and certified compilation; and Direction 5 explores the information-theoretic limits of term compression. Together, they constitute a program to build a complete mathematical theory of equality saturation — from foundational algebra through computational complexity to practical verified compilation.

---

## Direction 1: Graded Congruence Lattices and Saturation Dynamics

**Conjecture**: The congruence lattice of an e-graph under iterative rule application has a natural *grading* by saturation depth, and the extraction cost function is monotonically non-increasing along chains in this graded lattice. Formally: if `C_0 ⊆ C_1 ⊆ ... ⊆ C_k` is the sequence of congruences obtained by `k` rounds of saturation, then `opt_cost(C_{i+1}) ≤ opt_cost(C_i)` where `opt_cost(C)` is the minimum total extraction cost.

**Test**: Implement iterative saturation for the equational theory of commutative monoids over terms of depth ≤ 5 with 10 constants. Track `opt_cost(C_i)` for `i = 0, ..., 20`. If the conjecture holds, the sequence is non-increasing. Disproof: exhibit a saturation step where `opt_cost` increases — this would mean that merging more equivalences sometimes makes the *cheapest* representatives more expensive.

**Impact**: If true, this would provide a stopping criterion for equality saturation: terminate when `opt_cost` stabilizes. If false, it would reveal a fundamental limitation of greedy saturation strategies.

**Catalog References**: `Pythagorean/EGraph/Extraction.lean` → `extraction_preserves_eval`, `cost_extraction_never_increases`

**Proof Strategy**: Use the cost-optimality property of `CostExtractionSection` and show that coarsening the congruence (adding more equivalences) can only increase the pool of candidates for each class, potentially decreasing the minimum.

**Domain Bridges**: Combinatorial optimization (monotone submodular functions), order theory (graded lattices), dynamical systems (convergence of iterative maps)

**Lineage**: Extends `cost_extraction_never_increases` from single-step to multi-step saturation.

**Ambition**: Solid extension — builds directly on verified theorems with clear computational tests.

---

## Direction 2: Tropical Geometry of Extraction Cost

**Conjecture**: The cost function on the congruence lattice has a *tropical* structure: if we define cost using the min-plus semiring `(ℕ ∪ {∞}, min, +)`, then the optimal extraction cost is a tropical polynomial in the individual term costs, and the set of optimal extractions forms a tropical variety.

**Test**: For the theory of commutative semigroups with 4 generators and terms of depth ≤ 3, compute the optimal extraction cost as a function of the 4 generator costs `c₁, c₂, c₃, c₄`. If the conjecture holds, this function is piecewise-linear and convex (a tropical polynomial). Visualize the "tropical hypersurface" where the optimal extraction changes — this is the phase boundary between different optimal strategies.

**Impact**: Would connect equality saturation to tropical algebraic geometry, potentially enabling the use of tropical methods (Newton polytopes, Gröbner fans) for efficient extraction.

**Catalog References**: `Pythagorean/EGraph/Defs.lean` → `CostExtractionSection`, `Pythagorean/EGraph/Extraction.lean` → `extraction_exponential_choices`

**Proof Strategy**: Express the extraction cost as `min over representatives r_i in class C_i of Σ cost(r_i)`. This is a sum of minima, which is a tropical polynomial. The tropical variety is where the minimum is achieved by multiple representatives.

**Domain Bridges**: Tropical geometry (tropical varieties, Newton polytopes), optimization (LP duality), algebraic combinatorics (matroid theory)

**Lineage**: Bridges the `extraction_exponential_choices` theorem to tropical algebraic geometry.

**Ambition**: Grand challenge — paradigm-shifting connection between compiler optimization and algebraic geometry.

---

## Direction 3: Complexity Classification of Optimal Extraction

**Conjecture**: For the equational theory of commutative rings with at least 2 constants, the problem of cost-optimal extraction from a fully saturated e-graph is NP-hard, even when the cost function is the term size (AST node count).

**Test**: Attempt a reduction from MAX-CUT. Given a graph `G = (V, E)`, encode each edge `(i,j)` as the term `x_i · x_j` and build an e-graph with commutativity and distributivity applied to depth ≤ 3. If optimal extraction (minimizing total term size) solves MAX-CUT, the reduction proves NP-hardness. Computational test: for random graphs with `|V| ≤ 20`, compare the extraction cost with the known MAX-CUT value. Disproof: exhibit a polynomial-time algorithm for optimal extraction in commutative ring e-graphs, or show the reduction fails by finding a graph where extraction cost does not correlate with cut size.

**Impact**: Would establish the first computational complexity lower bound for e-graph extraction, explaining why practical tools use heuristic extraction and motivating the study of approximation algorithms.

**Catalog References**: `Pythagorean/EGraph/Extraction.lean` → `extraction_exponential_choices`, `extraction_image_card_le`

**Proof Strategy**: Use the exponential choices theorem as a starting point — it shows the search space is exponential, but does not prove hardness. The key is to show that the cost function couples the choices across classes, preventing independent per-class optimization.

**Domain Bridges**: Computational complexity (NP-hardness reductions), graph theory (MAX-CUT), approximation algorithms (LP relaxation, SDP)

**Lineage**: Extends `extraction_exponential_choices` from existence of multiple optima to hardness of finding the best one.

**Ambition**: Grand challenge — would resolve a central open problem in equality saturation theory.

---

## Direction 4: Type-Theoretic Extraction and Certified Compilation

**Conjecture**: The extraction-as-section framework extends to *typed* term algebras (simply-typed lambda calculus with constants), where the extraction section must preserve not only semantics but also types. The key additional condition is that the congruence must be *type-respecting*: related terms must have the same type.

**Test**: Formalize a simply-typed term algebra in Lean 4, define type-respecting congruences, and prove the extraction-preserves-evaluation theorem in this setting. Verify computationally by building typed e-graphs for simple functional programs (map, fold, compose) and checking that extraction preserves both semantics and well-typedness. Disproof: find a sound, type-respecting congruence where no extraction section exists that preserves types — this would indicate a fundamental obstacle.

**Impact**: Would provide the theoretical foundation for integrating equality saturation into verified compilers (CompCert, CakeML), where type preservation is essential.

**Catalog References**: `Pythagorean/EGraph/Defs.lean` → `SoundCongruence`, `ExtractionSection`; `Pythagorean/EGraph/Extraction.lean` → `extraction_preserves_eval`

**Proof Strategy**: Extend `SoundCongruence` with a type index, and show that the section property can be strengthened to type preservation. Use the existing Galois connection to lift to a typed setting.

**Domain Bridges**: Type theory (simply-typed lambda calculus), category theory (Cartesian closed categories), verified compilation (CompCert, CakeML)

**Lineage**: Direct extension of the main theorem to a richer algebraic setting.

**Ambition**: Solid extension — technically challenging but with a clear path from existing results.

---

## Direction 5: Information-Theoretic Limits of Term Compression

**Conjecture**: For an equational theory `E` over a signature with `k` binary operations and `n` constants, the maximum compression ratio achievable by an e-graph (ratio of equivalence classes to terms at depth ≤ d) is bounded by:

$$\frac{\text{classes}}{\text{terms}} ≥ \frac{1}{|E|^d}$$

where `|E|` is the number of equations in the theory. In information-theoretic terms: each equation can compress the term space by at most a constant factor per depth level.

**Test**: For the theories of (a) commutative semigroups (`xy = yx`, 1 equation), (b) commutative monoids (2 equations), and (c) commutative rings (8 equations), enumerate all terms of depth ≤ 5 and compute the exact compression ratio via canonical form computation. Plot `log(classes/terms)` vs `d` — if the conjecture holds, the slope should be bounded by `log(1/|E|)`. Disproof: exhibit a theory where the compression ratio decreases faster than the predicted exponential bound.

**Impact**: Would establish fundamental limits on how much optimization equality saturation can achieve, connecting compiler optimization to Shannon's source coding theorem.

**Catalog References**: `Pythagorean/EGraph/Extraction.lean` → `extraction_image_card_le`, `extraction_image_nonempty`

**Proof Strategy**: Use a counting argument: each equation at depth `d` can merge at most a fraction of the classes. The bound follows from bounding the number of applicable rewrite instances at each depth.

**Domain Bridges**: Information theory (rate-distortion theory, source coding), enumerative combinatorics (Catalan numbers, term enumeration), computational complexity (circuit complexity)

**Lineage**: Extends `extraction_image_card_le` from a simple bound to a quantitative, theory-dependent bound.

**Ambition**: Solid extension with potential for paradigm-shifting results if the bound is tight.
