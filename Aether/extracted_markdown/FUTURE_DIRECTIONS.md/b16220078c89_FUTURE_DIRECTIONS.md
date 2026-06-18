# Future Directions: Tropical Kernel Canonical Forms

## Synthesis

The canonical tropical kernel theory developed here reveals that harmonic functions on graph subsets, chip-firing equivalence classes, and Smith normal form arithmetic are three manifestations of a single canonical structure governed by the graph Laplacian. This synthesis opens multiple research fronts: extending the correspondence to richer geometric settings (metric graphs, tropical curves), deepening the connection to arithmetic invariants (Néron models, Jacobian varieties), and exploiting the computational structure for algorithmic applications. The directions below range from solid extensions of the current formal framework to paradigm-shifting conjectures connecting finite combinatorics to deep algebraic geometry.

---

## Direction 1: Full Group Isomorphism via Smith Normal Form Tracking

**Conjecture:** For every finite connected graph *G* and every nonempty separated subset *S*, there exists an explicit additive group isomorphism

```
CanonicalKernelSpan(G, S) / Constants ≅ ℤ^|S| / Im(L_S)
```

where the isomorphism is constructively given by the Smith normal form transition matrices.

**Test:** For all connected graphs with n ≤ 8, compute the canonical kernel generators and the SNF of L_S, verify that the transition matrix from generators to SNF basis is unimodular on the free part, and check that the quotient structures match as finite abelian groups.

**Impact:** This would complete the "tropical-critical correspondence" by providing an explicit, algorithmically computable isomorphism. It would give the first tropical-geometric proof of the structure theorem for critical groups.

**Catalog References:**
- `Catalog/Pythagorean/TropicalBridge/CanonicalKernelTheorems.lean` (harmonic kernel algebra, separation uniqueness)
- `Catalog/Pythagorean/TropicalBridge/Defs.lean` (graphLaplacian, firingIndependentOn)

**Proof Strategy:** Strategy A from the current work — quotient-lattice comparison. Define the map from canonical generators to cokernel elements via the Laplacian. Prove injectivity by contradiction using separation. Prove surjectivity by showing every cokernel element lifts to a harmonic representative.

**Domain Bridges:** Algebraic graph theory ↔ lattice theory, number theory (Smith normal form)

**Lineage:** Extends `harmonic_normalized_unique` and `firingEquiv_trans` to a full categorical equivalence.

**Ambition:** Solid extension — high confidence of success within 1–2 research cycles.

---

## Direction 2: Tropical Canonical Forms on Metric Graphs

**Conjecture:** The canonical kernel correspondence extends from finite graphs to metric graphs (tropical curves): for a compact metric graph Γ and a finite separated vertex set *S*, the normalized harmonic kernel generators on *S* generate a lattice whose quotient is isomorphic to the Jacobian J(Γ) restricted to *S*-supported divisors.

**The key insight is** that the continuous Laplacian on a metric graph has the same row-sum-zero and symmetry properties as the discrete Laplacian, and leaf rigidity extends verbatim to metric graphs (the maximum principle forces harmonic functions to be linear on pendant edges).

**Why now?** The Baker–Norine theory for metric graphs [BN07] and the tropical Jacobian construction [MZ08] provide the necessary continuous analogues. Our discrete formalization gives a template for the metric extension.

**Test:** Implement the correspondence for metric graphs discretized at varying resolutions. As resolution increases, the discrete canonical generators should converge to the continuous harmonic representatives on the metric graph. Test on genus-1 (cycle) and genus-2 (theta graph) metric graphs.

**Impact:** Would establish the first explicit computational bridge between finite graph chip-firing and tropical curve theory, opening the door to algorithmic tropical Jacobian computation.

**Catalog References:**
- `Catalog/Pythagorean/TropicalBridge/CanonicalKernelTheorems.lean` (harmonic_at_leaf_eq_neighbor, harmonic_tree_attachment_forces_unique_firing)
- `Catalog/Pythagorean/TropicalBridge/Defs.lean` (graphLaplacian)

**Proof Strategy:** Strategy C — inductive graph decomposition. Approximate the metric graph by increasingly fine finite graphs. Show the canonical generators converge under refinement using leaf rigidity as the stability mechanism.

**Domain Bridges:** Tropical geometry ↔ Berkovich analytic spaces, non-archimedean geometry

**Lineage:** Extends leaf rigidity from finite trees to continuous pendant edges.

**Ambition:** Grand challenge — requires new formalization infrastructure for metric graphs, but the mathematical path is clear.

---

## Direction 3: Self-Organized Criticality Mode Decomposition

**Conjecture:** In the Abelian sandpile model on a finite graph *G* with sink vertex *q*, the canonical tropical kernel generators on *S = V \ {q}* provide a complete mode decomposition of the recurrent configurations: each recurrent configuration can be uniquely expressed as an integer linear combination of canonical generators modulo the critical group relations.

**The key insight is** that recurrent configurations are exactly the elements of the critical group, and canonical generators are exactly the group generators — so the "mode decomposition" is simply the expression in terms of generators of a finitely generated abelian group.

**Why now?** The formal verification of the harmonic kernel algebra and firing equivalence structure provides the algebraic foundation. The computational experiments confirm the generator-count agreement for small graphs.

**Test:** For the Abelian sandpile on K_n (n ≤ 7), enumerate all n^{n-2} recurrent configurations, express each in terms of canonical generators, and verify that the decomposition is unique modulo the critical group relations.

**Impact:** Would provide the first mathematically rigorous "mode decomposition" for self-organized critical systems, with potential applications to understanding avalanche dynamics and correlations.

**Catalog References:**
- `Catalog/Pythagorean/TropicalBridge/CanonicalKernelTheorems.lean` (restrictedLaplacianImage_add, firingEquiv_trans)
- `Catalog/Pythagorean/TropicalBridge/ChipFiringCorrespondence.lean` (chipFire_degree_preserved, principalDivisor_degree_zero)

**Proof Strategy:** Strategy B — Smith normal form through tropical normalization. Show the canonical generators map to SNF basis elements under the quotient map, giving a direct decomposition.

**Domain Bridges:** Statistical mechanics ↔ algebraic graph theory, dynamical systems

**Lineage:** Extends `harmonic_tree_attachment_forces_unique_firing` to the full graph setting.

**Ambition:** Solid extension — the algebraic content is well-understood; the novelty is the formal/computational realization.

---

## Direction 4: Discrete Hodge Theory and Higher-Dimensional Laplacians

**Conjecture:** The canonical kernel correspondence generalizes from graphs (1-dimensional complexes) to simplicial complexes of arbitrary dimension: for a finite simplicial complex *K* and an appropriate subcomplex *S*, the harmonic *p*-cochains on *S* provide canonical representatives of the *p*-th torsion homology group H_p(K; ℤ).

**The key insight is** that the combinatorial Laplacian Δ_p = δ_{p+1} δ_{p+1}^* + δ_p^* δ_p on *p*-cochains has the same formal properties (self-adjointness, non-negative spectrum, kernel = harmonic cochains) as the graph Laplacian, and the Smith normal form of the boundary matrices controls the torsion in homology.

**Why now?** Computational topology and persistent homology have made higher-dimensional Laplacians practically computable. The graph-level formalization provides a template for the higher-dimensional extension.

**Test:** Compute the correspondence for triangulated surfaces (torus, Klein bottle, projective plane) and verify that 1-dimensional canonical kernel generators match H_1 torsion generators.

**Impact:** Would extend the tropical-critical correspondence to a fundamental tool in computational topology, with applications to topological data analysis and materials science.

**Catalog References:**
- `Catalog/Pythagorean/TropicalBridge/CanonicalKernelTheorems.lean` (isHarmonicOn_add, harmonic_normalized_unique)

**Proof Strategy:** Generalize Strategy A to the higher-dimensional setting. The key challenge is formulating the appropriate "separation hypothesis" for subcomplexes.

**Domain Bridges:** Algebraic topology ↔ tropical geometry, computational topology ↔ materials science

**Lineage:** Generalizes the entire current framework from dimension 1 to arbitrary dimension.

**Ambition:** Grand challenge — requires substantial new formalization, but the mathematical framework exists in the literature.

---

## Direction 5: Arithmetic Geometry Bridge via Graph Jacobians

**Conjecture:** For a graph *G* arising as the dual graph of a semistable reduction of an algebraic curve *C* over a number field, the canonical tropical kernel generators on *G* correspond to reduction data of rational points on the Jacobian variety J(C).

**The key insight is** that the critical group of the dual graph is isomorphic to the component group of the Néron model of J(C), and canonical tropical generators should correspond to canonical sections of the Néron model.

**Why now?** Recent advances in arithmetic geometry (Amini–Baker [AB15], Caporaso [Ca12]) have made the graph-to-curve correspondence precise. Our formal framework provides the graph-theoretic side that can be matched to the algebraic-geometric side.

**Test:** For elliptic curves with split multiplicative reduction (Tate curves), verify that the canonical generators on the dual graph (a cycle) match the component group structure (cyclic of order equal to the valuation of the *j*-invariant).

**Impact:** Would establish a new computational tool for studying rational points on curves via tropical combinatorics, connecting to the Birch and Swinnerton-Dyer conjecture program.

**Catalog References:**
- `Catalog/Pythagorean/TropicalBridge/CanonicalKernelTheorems.lean` (full framework)
- `Catalog/Pythagorean/TropicalBridge/Defs.lean` (graphLaplacian)

**Proof Strategy:** Use the known isomorphism between the component group and the critical group (Lorenzini [Lo91]) and compose with the canonical generator correspondence.

**Domain Bridges:** Tropical geometry ↔ arithmetic geometry, algebraic number theory

**Lineage:** The most ambitious extension — would connect finite graph combinatorics to deep number-theoretic questions.

**Ambition:** Grand challenge — paradigm-shifting if successful, requiring deep expertise in both tropical and arithmetic geometry.

---

## References

- [AB15] Amini, O. and Baker, M. "Linear series on metrized complexes of algebraic curves." *Mathematische Annalen* 362 (2015), 55–106.
- [BN07] Baker, M. and Norine, S. "Riemann–Roch and Abel–Jacobi theory on a finite graph." *Advances in Mathematics* 215 (2007), 766–801.
- [Ca12] Caporaso, L. "Algebraic and tropical curves: comparing their moduli spaces." *Handbook of Moduli* (2012).
- [Lo91] Lorenzini, D. "A finite group attached to the Laplacian of a graph." *Discrete Mathematics* 91 (1991), 277–282.
- [MZ08] Mikhalkin, G. and Zharkov, I. "Tropical curves, their Jacobians and theta functions." *Curves and Abelian Varieties* (2008), 203–230.
