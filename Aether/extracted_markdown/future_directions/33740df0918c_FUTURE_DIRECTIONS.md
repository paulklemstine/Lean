# Future Directions

## Synthesis

This research cycle established a rigorous topological framework for Dung's argumentation theory. The central discovery is a fundamental asymmetry: conflict-free sets form a simplicial complex (a geometric object) while admissible sets do not, meaning the "shape of compatibility" and the "shape of defensibility" are categorically different mathematical structures. The defense depth invariant — measuring how many rounds of justification separate an argument from uncontested truth — stratifies arguments into layers of epistemic certainty, connecting argumentation semantics to ordinal analysis. The nerve contractibility theorem shows that any consensus at all (non-empty grounded extension) collapses the topology of disagreement, confining non-trivial structure to frameworks of total controversy.

The most promising cross-domain connection is between defense depth and the filtration structures studied in persistent homology (Bridges domain) and the stratified complexity measures in the Computation domain (cf. `PadicValuationDepth.lean`). Defense depth is formally analogous to a valuation: it assigns a non-negative integer to each argument, is monotone with respect to the defense relation, and satisfies a sub-additivity-like bound. This suggests a bridge between argumentation theory and valuation theory that could yield new invariants for both fields.

The disproof of the Euler characteristic conjecture, while a negative result, opens the question of what the *correct* topological-semantic formula is. The nerve contractibility theorem constrains the search space: any such formula must account for the fact that non-trivial topology requires empty grounded extensions.

---

### Direction 1: Persistent Homology of the Defense Filtration

**Conjecture**: The defense chain F⁰(∅) ⊆ F¹(∅) ⊆ ... ⊆ Fⁿ(∅) induces a filtration on the argumentation complex K(AF) by sub-complexes Kₖ = {S ∈ K(AF) | S ⊆ Fᵏ(∅)}. The persistence diagram of this filtration — tracking which topological features (holes) are born and die at each defense depth — encodes information about the argumentation semantics that the Euler characteristic alone cannot capture. Specifically, conjecture: the number of bars in the 0-dimensional persistence diagram that persist to infinity equals the number of connected components of the grounded extension's conflict-free sub-complex.

**Test**: Implement the defense filtration for 1000 random argumentation frameworks with 5-8 arguments. Compute persistence diagrams using standard algorithms. Compare the count of infinite 0-bars with the connected components of the grounded sub-complex.

**Impact**: If true, this establishes persistent homology as a strictly more informative topological invariant for argumentation than the Euler characteristic, providing a richer "topological signature" of debate structure. If false, the specific failure mode reveals which topological information defense depth does and does not capture.

**Catalog References**: `Computation/PadicValuationDepth.lean` (valuation-based depth measures), `Bridges/MatroidCertificatePhaseTransition.lean` (phase transition phenomena in combinatorial structures)

**Proof Strategy**: (1) Define the sub-complex Kₖ formally as the restriction of K(AF) to vertices in Fᵏ(∅). (2) Show this is indeed a filtration (Kₖ ⊆ Kₖ₊₁ follows from defense chain monotonicity). (3) Prove that the inclusion-induced maps on H₀ track component merging. (4) Use the stabilization theorem (defenseChain_stabilizes) to show the filtration is finite.

**Domain Bridges**: Computation (valuation depth) <-> Novelty (defense depth) <-> Bridges (persistent homology)

**Lineage**: Builds on `defenseChain_stabilizes`, `defenseDepth_defender_bound`, and the filtration concept from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: The Admissibility Obstruction Complex

**Conjecture**: Define the **admissibility obstruction** of a conflict-free set S as the set of arguments that S fails to defend: Obs(S) = {a ∈ S | ¬Defends(S, a)}. The set {Obs(S) | S conflict-free, S not admissible} forms a simplicial complex — the "obstruction complex" O(AF). Conjecture: the Euler characteristic of O(AF) equals |A| minus the size of the largest admissible set (i.e., the size of the largest preferred extension).

**Test**: Compute O(AF) for all argumentation frameworks on ≤ 5 arguments. Verify or disprove the Euler characteristic formula.

**Impact**: If true, this gives a topological formula relating the shape of "what goes wrong" with admissibility to the size of the best achievable rational position. The obstruction complex would be a new mathematical object not previously studied. If false, understanding why reveals the geometric nature of the admissibility barrier.

**Catalog References**: `Novelty/ArgumentationTopology.lean` (admissible_not_simplicial), `Bridges/SubdIntegralityGap.lean` (obstruction-type bounds)

**Proof Strategy**: (1) Formalize the obstruction map Obs(S). (2) Show downward closure (removing arguments from S can only reduce Obs). (3) Compute χ(O) and compare with extension sizes. Key lemma: if S is conflict-free and T ⊆ S, then Obs(T) ⊇ Obs(S) ∩ T.

**Domain Bridges**: Novelty (argumentation obstruction) <-> Geometry (obstruction theory)

**Lineage**: Directly extends admissible_not_simplicial from this cycle.

**Ambition**: extension

---

### Direction 3: Argumentation Complexity and Graph Structure

**Conjecture**: The number of preferred extensions of an argumentation framework AF = (A, R) is bounded above by the number of maximal independent sets of the undirected graph underlying R. Furthermore, this bound is tight: for every undirected graph G, there exists an orientation of its edges (giving a digraph, hence an AF) that achieves the bound.

**Test**: Enumerate all orientations of small graphs (complete graphs K₃, K₄, K₅; cycles C₃, C₄, C₅; path graphs P₃, P₄, P₅) and compare the number of preferred extensions with the number of maximal independent sets.

**Impact**: This connects the complexity of argumentation semantics (how many rational positions exist) to the combinatorics of the underlying conflict graph. The Moon-Moser theorem gives that the maximum number of maximal independent sets in an n-vertex graph is 3^(n/3), so this would give a tight exponential bound on the number of preferred extensions. If the tightness claim is false, it reveals which orientations constrain the semantics beyond what the undirected structure determines.

**Catalog References**: `Bridges/SubdIntegralityGap.lean` (independent set bounds), `Novelty/ArgumentationBasic.lean` (preferred extension definition)

**Proof Strategy**: (1) Show that every preferred extension is contained in a maximal independent set of the undirected graph. (2) For tightness, construct orientations that make each maximal independent set admissible and maximal. The key insight: making all edges point "away" from an independent set makes it stable, hence preferred.

**Domain Bridges**: Novelty (preferred extensions) <-> Bridges (independent set combinatorics) <-> Algebra (graph theory)

**Lineage**: Builds on stable_is_preferred and the conflict-free complex from this cycle.

**Ambition**: extension

---

### Direction 4: Tropical Argumentation Semantics

**Conjecture**: The defense operator F can be expressed as a tropical polynomial map. Specifically, define a tropical semiring on argument "strengths" s : A → ℝ ∪ {−∞}, where the attack relation contributes tropical linear forms. Then the grounded extension corresponds to the tropical fixed point of a min-plus system, and the defense depth corresponds to the tropical valuation of the fixed point coordinates.

**Test**: For a 4-argument framework, write the defense operator as a system of min-max equations (max over defenders, min over attackers). Check whether the iteration of this system converges to the same fixed point as the classical defense chain for 100 random weight assignments.

**Impact**: If true, this creates a bridge between argumentation theory and tropical geometry, potentially importing deep results about tropical varieties (dimension, degree, Newton polytopes) into the analysis of debate structure. It would also provide continuous relaxations of the discrete defense operator, enabling gradient-based methods for finding extensions.

**Catalog References**: `Bridges/TropicalNormalization.lean` (tropical expression normalization), `Tropical/` (tropical optimization framework)

**Proof Strategy**: (1) Define argument strengths as a tropical vector. (2) Express "S defends a" as a tropical inequality: min_{b→a} max_{c∈S, c→b} s(c) ≥ s(a). (3) Show the defense operator becomes a piecewise-linear map. (4) Apply tropical fixed-point theory to prove convergence.

**Domain Bridges**: Novelty (defense operator) <-> Tropical (min-plus algebra) <-> Computation (fixed-point iteration)

**Lineage**: Builds on defenseOp_mono and the connection between monotone operators and tropical analysis.

**Ambition**: grand_challenge

---

### Direction 5: Categorical Argumentation

**Conjecture**: There exists a functor from the category of argumentation frameworks (with homomorphisms preserving attacks) to the category of simplicial complexes (with simplicial maps) that sends the conflict-free complex construction to a right adjoint of the "complete graph" functor. The preferred extension functor is NOT functorial — there exist AF homomorphisms that do not preserve preferred extensions.

**Test**: Construct explicit AF homomorphisms for 3-4 argument frameworks and verify whether the induced maps on conflict-free complexes are simplicial. Find a counterexample to functoriality of preferred extensions.

**Impact**: A categorical formulation would unify the topological and semantic perspectives and enable the use of categorical machinery (limits, colimits, Kan extensions) to construct new argumentation semantics from old ones. The non-functoriality of preferred extensions would be a fundamental negative result explaining why preferred semantics is "harder" than conflict-free semantics.

**Catalog References**: `Bridges/AlgebraEMLClosureComputation.lean` (closure system functoriality), `EML/EMLv17Core.lean` (categorical constructions)

**Proof Strategy**: (1) Define AF morphisms formally. (2) Show the conflict-free complex construction is functorial by checking that attack-preserving maps send conflict-free sets to conflict-free sets. (3) For the adjunction, show that the conflict-free complex of the complete graph on n vertices is the n-simplex. (4) For non-functoriality, find an AF morphism f: AF₁ → AF₂ and a preferred extension E of AF₁ such that f(E) is not preferred in AF₂.

**Domain Bridges**: Novelty (argumentation) <-> EML (categorical structures) <-> Geometry (simplicial maps)

**Lineage**: Builds on argComplex_simplicial and the categorical intuition from this cycle.

**Ambition**: extension
