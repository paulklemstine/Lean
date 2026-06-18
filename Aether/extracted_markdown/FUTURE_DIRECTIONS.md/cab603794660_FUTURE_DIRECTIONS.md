# Future Directions: Derived Persistence Theory

## Synthesis

The secondary torsion obstruction theory developed here establishes the first rigorous layer of derived persistence—the phenomenon that filtered algebraic structures carry higher-order torsion invariants invisible to pointwise Tor₁ detection. The five directions below form a coherent research program: Direction 1 generalizes the foundation from two-step to multi-step filtrations, Direction 2 establishes the computational infrastructure needed for applications, Direction 3 connects to classical spectral sequence theory, Direction 4 bridges to topological data analysis, and Direction 5 pursues the deepest structural conjecture about primewise decomposition. Each direction builds on the catalog theorems `Tor1_ZMod_ZMod_equiv` and `Ext1_ZMod_ZMod_equiv` and the core results proven here (`split_implies_no_secondary_obstruction`, `torsion_lift_functorial`, `secondary_obstruction_Z4_nontrivial`).

---

## Direction 1: Multi-Step Filtration Obstructions (Extension)

**Conjecture**: For a bounded filtration $0 = F^0 C \subseteq F^1 C \subseteq \cdots \subseteq F^k C = C$ of a finitely generated abelian group, there exist secondary obstructions $\delta_i$ at each filtration step $i$, and these obstructions satisfy a *composition law*: the total obstruction of the composite filtration $F^0 \subseteq F^k$ is determined by the pairwise obstructions $\delta_1, \ldots, \delta_{k-1}$ together with correction terms arising from triple and higher interactions.

**Test**: Formalize the three-step filtration case $0 \subseteq A \subseteq B \subseteq C$ and compute: (a) the individual secondary obstructions for $A \subseteq B$ and $B \subseteq C$, and (b) the total obstruction for $A \subseteq C$. Test whether the total obstruction equals the sum/composition of individual obstructions for a systematic family of examples (e.g., $\mathbb{Z}/p\mathbb{Z} \subseteq \mathbb{Z}/p^2\mathbb{Z} \subseteq \mathbb{Z}/p^3\mathbb{Z}$ for primes $p \leq 13$). If the composition law fails, identify the correction term.

**Impact**: Establishes the full recursive structure of derived persistence for arbitrary filtrations—the backbone needed for spectral sequence convergence.

**Catalog References**: `Catalog/Algebra/Homology/DerivedFunctors/TorsionDetection.lean` (`torsion_persistence_functorial`), `Catalog/Algebra/Homology/DerivedFunctors/ExtTorBasic.lean` (`Ext1_ZMod_ZMod_equiv`).

**Proof Strategy**: Define the three-step obstruction as the composite of two connecting homomorphisms in the long exact Ext sequence. Use the octahedral axiom (or a direct algebraic argument in the abelian category setting) to establish the composition law. Formalize the connecting homomorphism explicitly for cyclic groups using the catalog's `Ext1_ZMod_ZMod_equiv`.

**Domain Bridges**: Homotopy theory (Postnikov tower obstructions), algebraic K-theory (filtration on K-groups).

**Lineage**: Directly extends `split_implies_no_secondary_obstruction` and `torsion_lift_functorial`.

**Ambition**: Extension — natural next step building on established foundations.

---

## Direction 2: Efficient Computation via Smith Normal Form (Extension)

**Conjecture**: For a two-step filtered chain complex of finitely generated free abelian groups (given by integer boundary matrices and an inclusion), the secondary torsion obstruction can be computed in $O(n^3)$ time (where $n$ is the matrix dimension) by composing Smith normal form computations for the subcomplex, total complex, and quotient complex, followed by an explicit connecting homomorphism computation.

**Test**: Implement the algorithm and test it on: (a) the cellular chain complex of lens spaces $L(p, 1)$ with the standard skeletal filtration, (b) random integer boundary matrices of size up to $100 \times 100$ with entries in $\{-2, -1, 0, 1, 2\}$, and (c) chain complexes arising from triangulations of mapping tori. Compare the computed obstruction against brute-force enumeration for small examples. If the algorithm fails, identify where the SNF composition breaks down.

**Impact**: Makes derived persistence computationally feasible for realistic TDA applications.

**Catalog References**: `Catalog/Algebra/Homology/DerivedFunctors/ExtTorBasic.lean` (`Tor1_ZMod_ZMod_equiv` for the cyclic case validation).

**Proof Strategy**: Express the connecting homomorphism $\delta: T_n(C) \to A/nA$ in terms of Smith normal form data. The key insight is that $\delta$ factors through the change-of-basis matrices of the SNF computation. Prove correctness by showing this agrees with the abstract definition.

**Domain Bridges**: Computational algebra, numerical topology, algorithmic algebraic topology.

**Lineage**: Builds on `no_obstruction_iff_torsion_surjective` (computationally checking the criterion).

**Ambition**: Extension — brings theory to practice.

---

## Direction 3: Persistent Exact Couple and Page-2 Identification (Grand Challenge)

**Conjecture**: For a bounded filtered chain complex $F$ of finitely generated abelian groups, the persistent exact couple $(D, E, i, j, k)$ constructed from the filtered homology gives rise to a convergent spectral sequence whose $E_2$ page satisfies:
$$E_2^{p,q} \cong \bigoplus_{d \mid \gcd(\text{inv. factors of } H_q(\mathrm{gr}^p F))} \left[\operatorname{Tor}_1^{\mathbb{Z}}(H_{q-1}(\mathrm{gr}^p F), \mathbb{Z}/d\mathbb{Z}) \oplus \operatorname{Ext}^1_{\mathbb{Z}}(H_q(\mathrm{gr}^p F), \mathbb{Z}/d\mathbb{Z})\right]$$
Moreover, the first nontrivial differential $d_2$ on this page is the secondary torsion obstruction of the present work.

**Test**: Formalize the exact couple construction for filtered chain complexes over $\mathbb{Z}$ in Lean 4. Compute $E_2$ explicitly for: (a) the mapping cone of multiplication by $n$ on $\mathbb{Z}$, (b) the skeletal filtration of $\mathbb{RP}^3$, (c) a random two-step filtration with 3-dimensional boundary matrices. Check whether the $E_2$ page matches the Tor/Ext decomposition. If the identification fails, the conjecture is false and we need to refine the formula.

**Impact**: This would be the first formally verified bridge between persistent homology and spectral sequence theory—opening "derived TDA" as a rigorous mathematical field.

**Catalog References**: Both `Tor1_ZMod_ZMod_equiv` and `Ext1_ZMod_ZMod_equiv` are needed to identify the page-2 terms.

**Proof Strategy**: Construct the exact couple from the long exact sequences of consecutive filtration pairs. Derive the derived couple. Identify the $E_2$ page with the universal coefficient theorem applied to the connecting homomorphisms. The key step is showing that the derived couple's differential factors through the Ext/Tor decomposition.

**Domain Bridges**: Spectral sequences in homotopy theory, persistent sheaf cohomology, derived categories in algebraic geometry.

**Lineage**: Directly generalizes `torsion_seq_exact_at_middle` (which is the exactness of the $E_1$ page in the two-step case).

**Ambition**: Grand Challenge — would establish a new subfield of mathematics.

---

## Direction 4: Torsion-Sensitive TDA Descriptors (Extension)

**Conjecture**: For point clouds sampled from spaces with non-trivial torsion in their integral homology (e.g., $\mathbb{RP}^2$, lens spaces, Klein bottles), the secondary torsion obstruction applied to the Vietoris-Rips filtration provides a topological descriptor that (a) is stable under small perturbations of the point cloud, (b) distinguishes spaces that ordinary persistent homology with field coefficients cannot distinguish, and (c) is computable in polynomial time.

**Test**: Generate point clouds (1000 points each) from: (a) $S^2$ vs $\mathbb{RP}^2$, (b) $S^1 \times S^1$ (torus) vs Klein bottle, (c) lens spaces $L(5,1)$ vs $L(5,2)$. Compute the Vietoris-Rips complex at multiple scales, extract the skeletal two-step filtration, and compute secondary obstruction profiles. Test whether the secondary obstruction distinguishes pairs that barcodes with $\mathbb{Q}$ coefficients fail to distinguish. If stability fails, identify the failure mode.

**Impact**: Creates the first torsion-sensitive topological descriptor for data science applications—a new invariant for TDA beyond barcodes.

**Catalog References**: `Catalog/Algebra/Homology/DerivedFunctors/TorsionDetection.lean` (`tor1_persistent_detects_ptorsion`, `prime_selectivity`).

**Proof Strategy**: Stability follows from the functoriality theorem (`torsion_lift_functorial`): small perturbations induce SES morphisms, which map liftable torsion to liftable torsion. The discriminating power follows from the nontriviality theorem: spaces like $\mathbb{RP}^2$ have torsion that creates secondary obstructions absent in $S^2$.

**Domain Bridges**: Topological data analysis, computational topology, machine learning with topological features.

**Lineage**: Applies `torsion_lift_functorial` to the persistence setting from `TorsionDetection.lean`.

**Ambition**: Extension — high-impact application of existing theory.

---

## Direction 5: Primewise Collapse Criterion (Grand Challenge)

**Conjecture** (Primewise Secondary Vanishing ⟹ Page-2 Collapse): For any bounded finite filtered chain complex $F$ over $\mathbb{Z}$, if the $p$-primary secondary torsion obstruction vanishes for every prime $p$, then the total torsion of $H_*(F)$ is completely determined by the page-2 Ext/Tor data of the associated graded.

More precisely: the natural map
$$\bigoplus_p T_{p^k}(B) \to T_{p^k}(B)$$
from primewise torsion to total torsion is an isomorphism when all primewise secondary obstructions vanish, and the page-2 spectral sequence collapses.

**Test**: Search over all cyclic SES $0 \to \mathbb{Z}/a\mathbb{Z} \to \mathbb{Z}/(ac)\mathbb{Z} \to \mathbb{Z}/c\mathbb{Z} \to 0$ with $ac \leq 100$. For each, compute whether all primewise secondary obstructions vanish and whether the torsion of $B$ equals the predicted page-2 value. If a counterexample exists (all primewise obstructions zero but total torsion differs from prediction), the conjecture is false.

The key test case is mixed-prime extensions: $a = 6, c = 6, b = 36$. Here $\gcd(2, 6)^2 = 4$, $\gcd(2, 36) = 4$ and $\gcd(3, 6)^2 = 9$, $\gcd(3, 36) = 9$, so both 2-primary and 3-primary components have obstructions. But does the total obstruction decompose as the sum of primewise obstructions?

**Impact**: Would establish a complete local-to-global principle for derived persistence, analogous to the Chinese Remainder Theorem for torsion obstruction theory.

**Catalog References**: `Catalog/Algebra/Homology/DerivedFunctors/ExtTorBasic.lean` (both `Tor1_ZMod_ZMod_equiv` and `Ext1_ZMod_ZMod_equiv`), `Catalog/Algebra/Homology/DerivedFunctors/TorsionDetection.lean` (`prime_selectivity`).

**Proof Strategy**: For cyclic groups, reduce to the Chinese Remainder Theorem: $\mathbb{Z}/n\mathbb{Z} \cong \prod_p \mathbb{Z}/p^{v_p(n)}\mathbb{Z}$. Show that the secondary obstruction respects this decomposition. The main difficulty is showing that the connecting homomorphism $\delta$ in the long exact Ext sequence commutes with the CRT decomposition. This should follow from the naturality of the CRT isomorphism.

**Domain Bridges**: Number theory (p-adic methods, local-global principles), algebraic topology (chromatic homotopy theory, where similar primewise decompositions govern the Adams spectral sequence).

**Lineage**: Builds on all main theorems, especially `secondary_obstruction_Z4_nontrivial` (the paradigm example) and `no_obstruction_iff_torsion_surjective` (the criterion to check).

**Ambition**: Grand Challenge — would establish a fundamental structural principle for derived persistence, connecting to deep themes in number theory and homotopy theory.
