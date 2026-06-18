# Future Directions: Overlap Class Theory and Tropical Kernel Invariants

## Synthesis

The overlap class theory established here reveals that the interaction structure of tropical kernel generators decomposes naturally along the connected components of the support overlap graph. The key discovery — that supports from different overlap classes are provably disjoint — opens three distinct research frontiers: (1) determining whether overlap classes are *complete* invariants of tropical projective equivalence classes, (2) extending the theory from graphs to matroids, and (3) connecting the overlap signature to spectral and homological properties of networks. Each direction below is grounded in specific formally verified theorems and is designed to be both testable and falsifiable.

---

## Direction 1: Overlap Degree One Uniqueness Conjecture

**Conjecture:** When every pair of overlapping cycle supports in G[S] intersects in at most one vertex (MaxOverlapDeg ≤ 1), the tropical kernel generating family is unique up to TPE within each overlap class.

**Test:** Enumerate all connected graphs on n ≤ 9 vertices. For each (G, q, S) with MaxOverlapDeg(cycleSupportFamily(G, S)) ≤ 1, enumerate all minimal generating families and check uniqueness within overlap classes. A single instance with two inequivalent generators in the same overlap class under this constraint would refute the conjecture.

**Impact:** This would be the first genuinely new uniqueness theorem beyond the disjoint regime, establishing that "weakly overlapping" generators (sharing at most one vertex per pair) still exhibit the same rigidity as non-overlapping ones. It would define the boundary between the rigid and flexible regimes.

**Catalog References:**
- `Pythagorean/TropicalBridge/OverlapClassTheory.lean`: `overlapDegree_eq_zero_iff_pairwiseDisjoint`, `disjoint_of_different_overlap_class`
- `Catalog/Pythagorean/TropicalBridge/TropicalKernelRigidity.lean`: `disjoint_support_unique_up_to_tropProjEquiv`

**Proof Strategy:** Induction on the overlap degree. Base case (degree 0) is the existing disjoint theorem. For degree 1, the single shared vertex between overlapping supports acts as a "pinch point" — show that the constraint of harmonicity at this vertex forces the two generators to agree modulo TPE. Use the harmonic leaf rigidity theorem from TropicalKernelRigidity.lean to propagate values through the shared vertex.

**Domain Bridges:** Matroid theory (circuit elimination with single-element intersections), coding theory (support overlap in LDPC codes where parity checks share one variable).

**Lineage:** Extends `disjoint_support_unique_up_to_tropProjEquiv` from the disjoint case to the weakly interacting case.

**Ambition:** ★★★★☆ — Substantial extension of the rigidity theory, technically accessible via induction.

---

## Direction 2: Componentwise TPE Factorization (Grand Challenge)

**Conjecture:** For any graph G, basepoint q, and S ⊆ V \ {q}, the set of TPE classes of minimal generating families of the tropical kernel factorizes as a product over overlap classes:

TPEClassCount(G, q, S) = ∏_{C ∈ OverlapClasses} TPEClassCount_C(G, q, S)

**Test:** Compute TPE class counts for all connected graphs on n ≤ 7 by exhaustive enumeration of generating families. Compare the product formula to the actual count. A counterexample immediately reveals which overlap classes interact.

**Impact:** This would establish that overlap classes are the fundamental "interaction sectors" for tropical kernel generators — a decomposition analogous to the cluster decomposition in statistical mechanics. It would reduce the computation of TPE class counts from a global problem to a product of local problems.

**Catalog References:**
- `Pythagorean/TropicalBridge/OverlapClassTheory.lean`: `overlap_class_unions_disjoint`, `tropProjEquiv_preserves_varOverlapEquiv`
- `Catalog/Pythagorean/TropicalBridge/DefectTheory.lean`: `inducedCycleRank`

**Proof Strategy:** Strategy B (component factorization). Show that any minimal generating family restricts to a minimal generating family on each overlap component. Use the disjointness theorem (`overlap_class_unions_disjoint`) to decouple the components. Then show that TPE acts independently on each component.

**Domain Bridges:** Statistical physics (cluster decomposition theorem), topological data analysis (persistent homology of support complexes), algebraic K-theory (devissage along interaction strata).

**Lineage:** Builds on all the overlap class machinery plus the defect theory from `DefectTheory.lean`.

**Ambition:** ★★★★★ — Paradigm-shifting if true; even partial results (bounds relating product to actual count) would be highly valuable.

---

## Direction 3: Overlap Signature as Complete Invariant

**Conjecture:** The isomorphism type of the overlap graph together with the multiset of intersection sizes (the overlap signature) determines the TPE class count.

**Test:** Search for two instances (G₁, q₁, S₁) and (G₂, q₂, S₂) with isomorphic overlap graphs, identical overlap signatures, but different TPE class counts. This is computationally feasible for n ≤ 8.

**Impact:** If true, the overlap signature is a *complete* combinatorial invariant for TPE class enumeration — reducing an algebraic problem to a purely combinatorial one. If false, the counterexample reveals what additional data (e.g., the intersection lattice, the matroid structure) is needed.

**Catalog References:**
- `Pythagorean/TropicalBridge/OverlapClassTheory.lean`: `OverlapSignature`, `overlapSignature_pos`, `CrossOverlapCount`

**Proof Strategy:** If the signature is insufficient, strengthen to the **intersection lattice** (the partial order on all intersections F(i₁) ∩ ... ∩ F(iₖ)). The lattice is strictly finer than the signature and may suffice.

**Domain Bridges:** Matroid theory (circuit intersection lattice), combinatorial topology (nerve of the support cover), information theory (interaction information and multivariate mutual information).

**Lineage:** Refines the overlap class theory from Section 9 of the Lean formalization.

**Ambition:** ★★★☆☆ — Computationally testable, and either outcome advances the theory.

---

## Direction 4: Matroid-Circuit Generalization

**Conjecture:** The overlap class theory generalizes from graphic matroids to all regular matroids: for any regular matroid M, the circuit overlap graph controls the tropical kernel generators of M's representation matrix.

**The key insight is** that cycle supports in G[S] are precisely the circuit supports of the graphic matroid M(G)|S, and the overlap graph is exactly the circuit intersection graph. Regular matroids are representable over every field, so the tropical theory should apply.

**Why now?** Mathlib now has substantial matroid theory, including circuit characterizations and matroid operations, making formalization feasible.

**Test:** Formalize the circuit intersection graph for matroids in Lean 4. Verify that for graphic matroids, it agrees with the support overlap graph. Then test the factorization conjecture for non-graphic regular matroids (e.g., R₁₀, the non-Fano matroid dual).

**Impact:** This would elevate overlap class theory from a graph-specific result to a matroid-theoretic principle, applicable to any context where matroids arise (network flows, linear codes, algebraic geometry).

**Catalog References:**
- `Pythagorean/TropicalBridge/OverlapClassTheory.lean`: all definitions and theorems
- `Catalog/Pythagorean/TropicalBridge/TropicalKernelRigidity.lean`: `SameInducedStructure`, `same_induced_structure_same_laplacian`

**Proof Strategy:** Define the circuit overlap graph for abstract matroids. Show that it specializes to the support overlap graph for graphic matroids. Use the matroid circuit elimination axiom to control how generators interact at overlap points.

**Domain Bridges:** Algebraic combinatorics, tropical geometry (valuated matroids), optimization (matroid intersection algorithms).

**Lineage:** Extends the matroidal invariance theorem from TropicalKernelRigidity.lean.

**Ambition:** ★★★★★ — Grand challenge that would unify graph-theoretic and matroid-theoretic approaches to tropical algebra.

---

## Direction 5: Defect-Overlap Duality

**Conjecture:** The structural defect from DefectTheory.lean is bounded by a function of the overlap degree and cycle rank:

structuralDefect(G, q, S) ≤ f(OverlapDegree(cycleSupportFamily(G, S)), inducedCycleRank(G, S))

for a computable function f.

**The key insight is** that both the defect (measuring the gap between Laplacian rank and divisor rank) and the overlap degree (measuring support interactions) are controlled by the cycle structure of G[S]. High overlap degree means cycles share vertices, which should constrain the defect.

**Why now?** Both the defect theory and overlap theory are now formalized, enabling a precise bridge.

**Test:** Compute both quantities for all (G, q, S) on n ≤ 7. Fit the function f. Check if the bound is tight.

**Impact:** Would provide the first quantitative link between the algebraic defect (a Laplacian invariant) and the combinatorial overlap structure (a support invariant), unifying two independently developed theories.

**Catalog References:**
- `Pythagorean/TropicalBridge/OverlapClassTheory.lean`: `OverlapDegree`, `overlapDegree_eq_zero_iff_pairwiseDisjoint`
- `Catalog/Pythagorean/TropicalBridge/DefectTheory.lean`: `structuralDefect`, `inducedCycleRank`

**Proof Strategy:** Case analysis. When overlap degree is 0, the defect should be controlled by cycle rank alone (existing theory). For each additional overlapping pair, bound the defect increase using the cycle elimination principle.

**Domain Bridges:** Spectral graph theory (Laplacian eigenvalue bounds vs. cycle structure), algebraic topology (Betti numbers vs. intersection patterns).

**Lineage:** Bridges the two main Lean files in the TropicalBridge directory.

**Ambition:** ★★★☆☆ — Solid extension building directly on existing catalog theorems.
