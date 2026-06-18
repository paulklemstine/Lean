# Future Directions: Overlap Class Theory for Tropical Kernels

## Synthesis

The overlap class framework established in this work provides the combinatorial infrastructure for a systematic investigation of tropical kernel structure beyond the disjoint-support regime. The five definitions (overlap graph, overlap classes, maximum intersection size, total overlap complexity, element nerve) and their equivalence theorems validate the framework by recovering the classical disjoint case as the zero-overlap base case. The natural next steps divide into two categories: (1) proving structural theorems about the overlap regime itself (factorization, uniqueness at low overlap degree), and (2) extending the framework to broader mathematical settings (matroids, codes, valuated matroids). Each direction below is formulated as a precise, falsifiable conjecture with a clear test methodology.

---

## Direction 1: Componentwise Factorization of Tropical Projective Classes

**Conjecture:** If the support overlap graph OG(F) of a minimal generating family F of the tropical kernel decomposes into connected components C₁, …, Cₖ, then the number of tropical projective equivalence classes factorizes as a product over components:

    tropProjEquivClassCount(G, q, S) = ∏ᵢ tropProjEquivClassCountOnComponent(G, q, S, Cᵢ)

**The key insight is** that overlap classes serve as the independent interaction sectors of tropical kernel generators, analogous to the factorization of partition functions over disconnected subsystems in statistical mechanics.

**Why now?** The base case (all components are singletons, i.e., pairwise disjoint supports) is already established in the catalog's disjoint rigidity theorem, and the definitions of overlap classes are now formalized. The inductive framework (overlap degree as descent parameter) is in place.

**Test:** Enumerate all connected graphs on n ≤ 8 vertices. For each (G, q, S), compute cycle supports, build the overlap graph, count components, and compare the product formula against direct enumeration of tropical projective classes.

**Impact:** Would establish overlap classes as the fundamental invariant of tropical kernel structure, reducing a global algebraic problem to independent local problems.

**Catalog References:** `Pythagorean/TropicalBridge/OverlapClassRigidity.lean` (overlapClassCount, SupportOverlapGraph), `Catalog/Pythagorean/TropicalBridge/DefectTheory.lean` (inducedCycleRank).

**Proof Strategy:** Strategy B from the main paper. Define restriction of a generating family to a subset of indices. Show that if indices i, j belong to different overlap components, the generators at i and j are algebraically independent. Conclude factorization by induction on the number of components.

**Domain Bridges:** Statistical physics (partition function factorization), coding theory (independent sectors of codeword supports).

**Lineage:** Extends `overlapClassCount_eq_card_of_pairwiseDisjoint` from the singleton-component case to arbitrary component structure.

**Ambition:** ★★★★☆ — Major theorem that would open the field.

---

## Direction 2: Uniqueness in the Overlap-Degree-One Regime

**Conjecture:** When every pair of distinct cycle supports intersects in at most one vertex (maxIntersectionSize ≤ 1), minimal generating families are unique up to tropical projective equivalence within each overlap class.

**The key insight is** that single-vertex overlaps create the weakest possible coupling between supports, and in this regime the interaction is "perturbative"—it constrains the generators but does not create new degrees of freedom.

**Why now?** The `maxIntersectionSize_eq_zero_iff` theorem validates the framework's base case (overlap degree zero = disjoint). The next natural step is overlap degree one, which corresponds to the simplest nontrivial interaction.

**Test:** For all connected graphs on n ≤ 7 vertices with maxIntersectionSize = 1, enumerate minimal generating families and check uniqueness of tropical projective class within each overlap component.

**Impact:** First genuinely new rigidity theorem beyond the disjoint case. Would demonstrate that weak interactions preserve uniqueness.

**Catalog References:** `Pythagorean/TropicalBridge/OverlapClassRigidity.lean` (maxIntersectionSize, intersection_card_le_maxIntersectionSize).

**Proof Strategy:** Strategy A (induction on overlap degree). When two supports share exactly one vertex v, show that the constraint imposed by v determines the relative scaling of the two generators. Use the element nerve to track which generators are coupled through each shared vertex.

**Domain Bridges:** Matroid theory (circuit elimination at single-element intersections), perturbation theory.

**Lineage:** Directly extends `overlapClassCount_eq_card_of_pairwiseDisjoint`.

**Ambition:** ★★★☆☆ — Substantial but focused result.

---

## Direction 3: Matroid-Circuit Overlap Theory (Grand Challenge)

**Conjecture:** The overlap class theory extends from graphic matroids to all regular matroids: for a regular matroid M with circuit family C, the tropical Bergman fan of M has a minimal generating structure controlled by the circuit intersection graph of C.

**The key insight is** that cycle supports in a graph are circuit supports in the graphic matroid, and the overlap graph is the circuit intersection graph. All our combinatorial results—edgelessness ↔ disjointness, class count bounds, nerve duality—hold for arbitrary finite set families and thus apply immediately to any matroid's circuits.

**Why now?** The formalization is already parametric over arbitrary finite set families (indexed by a type ι over a ground set α), not specific to graphs. The matroid extension requires only connecting our definitions to the circuit family of a matroid.

**Test:** Implement circuit enumeration for small matroids (uniform matroids U(2,n), graphic matroids of small graphs, the Fano matroid). Compare overlap class structure across matroid types. Look for matroids where the overlap class count diverges from the number of tropical projective classes.

**Impact:** Paradigm-shifting. Would establish overlap classes as a universal invariant in tropical combinatorics, not limited to graph theory.

**Catalog References:** `Pythagorean/TropicalBridge/OverlapClassRigidity.lean` (all definitions are matroid-ready by parametericity).

**Proof Strategy:** Strategy C. Reformulate cycle-space arguments using matroid circuit axioms. Use the circuit elimination axiom (if C₁, C₂ are circuits and e ∈ C₁ ∩ C₂, there exists a circuit C₃ ⊆ (C₁ ∪ C₂) \ {e}) as the key tool for analyzing how overlap modifies generators.

**Domain Bridges:** Matroid theory, tropical geometry (Bergman fans, valuated matroids), algebraic combinatorics.

**Lineage:** Generalizes the entire overlap class framework from graphs to matroids.

**Ambition:** ★★★★★ — Grand challenge, potentially multi-paper program.

---

## Direction 4: Support Nerve Homology and Higher-Order Overlap Invariants

**Conjecture:** The element nerve N_F defines a simplicial complex whose Betti numbers provide strictly finer invariants than the overlap graph alone. Specifically, there exist families F₁, F₂ with isomorphic overlap graphs but different nerve Betti numbers, and the nerve Betti numbers predict the number of tropical projective classes when the overlap graph does not.

**The key insight is** that the overlap graph captures only pairwise interactions, while higher-order overlaps (three or more supports sharing a vertex) contribute additional algebraic constraints. The nerve complex captures all orders of interaction simultaneously.

**Why now?** The element nerve is already formalized. Computing its homology for small examples is computationally feasible and would immediately test whether higher-order information is needed.

**Test:** Find two families with identical overlap graphs but different triple (or higher) overlaps. Check whether the number of tropical projective classes differs. If so, compute nerve homology and check correlation.

**Impact:** Would reveal the correct invariant hierarchy: overlap graph (pairwise) < nerve complex (all orders) < ??? for controlling tropical kernel structure.

**Catalog References:** `Pythagorean/TropicalBridge/OverlapClassRigidity.lean` (elementNerve, overlap_iff_nerve).

**Proof Strategy:** Compute explicit counterexamples using small graphs (n = 6–8). Use persistent homology tools to analyze the nerve complex. If higher-order invariants matter, formalize the nerve complex as a simplicial complex in Lean and prove the refined bound.

**Domain Bridges:** Computational algebraic topology (persistent homology), topological data analysis, combinatorial Hodge theory.

**Lineage:** Extends `overlap_iff_nerve` from a characterization of pairwise overlap to a theory of higher-order overlap.

**Ambition:** ★★★★☆ — Conceptually deep, computationally testable.

---

## Direction 5: Algorithmic Classification of Graphs by Overlap Signature

**Conjecture:** Two connected graphs G₁, G₂ with isomorphic overlap signatures (overlap graph isomorphism type + intersection size multiset) have the same number of tropical projective equivalence classes for all choices of basepoint and subset.

**The key insight is** that the overlap signature is a complete invariant of the interaction pattern, and if tropical kernel structure depends only on the interaction pattern, then overlap-equivalent graphs should have identical algebraic behavior.

**Why now?** The overlap signature is computable, and exhaustive search over small graphs (n ≤ 9) is feasible. A counterexample would reveal exactly what additional information is needed beyond the overlap signature.

**Test:** Compute overlap signatures for all connected graphs on n ≤ 9 vertices and all (q, S) pairs. Group by signature. Within each group, compute tropical projective class counts and check uniformity.

**Impact:** If true, provides a polynomial-time algorithm for predicting tropical kernel structure from the overlap signature. If false, the first counterexample identifies the missing invariant.

**Catalog References:** `Pythagorean/TropicalBridge/OverlapClassRigidity.lean` (SupportOverlapGraph, maxIntersectionSize, totalOverlapComplexity).

**Proof Strategy:** Empirical-first. Run the computational search. If no counterexample is found up to n = 9, formulate a refined conjecture and attempt proof by induction on graph size.

**Domain Bridges:** Graph isomorphism testing, network fingerprinting, chemical graph theory (molecular descriptors).

**Lineage:** Builds on all overlap measures defined in the current work.

**Ambition:** ★★★☆☆ — Concrete and testable, with clear algorithmic payoff.
