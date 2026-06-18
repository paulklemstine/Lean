# Future Directions: Arithmetic Statistics of Graph Jacobians

## Synthesis

The theorems proved in this work—the divisibility criterion, the prime-power moment identity, and the profile recovery theorem—establish the algebraic backbone for a new field at the intersection of random graph theory and arithmetic statistics. The key unifying insight is that the Smith normal form acts as a universal bridge: any random process that produces integer matrices yields, through its cokernel, a random finite abelian group whose statistics are governed by Cohen–Lenstra-type laws. The directions below extend this bridge in five ways: (1) proving the asymptotic conjecture itself, (2) extending to new random ensembles, (3) connecting to physics, (4) building higher-dimensional generalizations, and (5) extracting algorithmic applications.

---

## Direction 1: Prove the Cohen–Lenstra Conjecture for Dense Erdős–Rényi Graphs

**Conjecture.** For fixed p ∈ (0,1) and prime q, the q-primary part of Jac(G(n,p)) converges in distribution to the Cohen–Lenstra measure μ_{CL,q} as n → ∞.

**Test.** Compute empirical distributions of the q-primary partition type for G(n, 1/2) with n up to 1000 (using efficient SNF algorithms). Compare to CL predictions at the level of full partition distributions, not just moments. Measure the Kolmogorov–Smirnov distance and verify it decreases as O(1/n^α) for some α > 0.

**Impact.** This would be the first rigorous proof connecting random graph Jacobians to number-theoretic distributions, opening a new chapter in both graph theory and arithmetic statistics. It would validate the "universality principle" for cokernels of structured random integer matrices.

**Catalog References.** `Catalog/Pythagorean/GraphJacobians/ArithmeticStatistics.lean` (Theorems A–F), `Catalog/Pythagorean/CohenLenstra/Defs.lean` (CL distribution definitions).

**Proof Strategy.** Use Wood's universality theorem (2017) which shows that for sufficiently random integer matrices mod q^k, the cokernel distribution converges to CL. The key step is verifying that reduced Laplacians of G(n,p) satisfy Wood's moment conditions. Our Theorem C (profile recovery from moments) provides the exact framework: it suffices to show that E[M_{q,k}] → E_{CL}[M_{q,k}] for all k, which reduces to computing expectations of products of gcd's.

**Domain Bridges.** Random matrix theory → arithmetic statistics → graph theory.

**Lineage.** Builds directly on Theorems B and C of this work, and on Cohen–Lenstra/Defs.lean.

**Ambition.** Grand challenge. Would resolve a conjecture that has been open since 2015.

**The key insight is:** the profile recovery theorem (Theorem C) reduces the full distributional conjecture to moment convergence, and moment convergence can be attacked via random matrix moment methods.

**Why now?** Our formal framework provides the exact algebraic identities needed to connect moment computations to distributional convergence. Wood's universality results provide the asymptotic template; the missing piece is verifying the moment conditions for graph Laplacians specifically.

---

## Direction 2: Sparse Regime and Phase Transitions in Jacobian Statistics

**Conjecture.** At the connectivity threshold p ~ log(n)/n for G(n,p), the Jacobian statistics undergo a phase transition. Below threshold, the Jacobian is trivial (the graph is disconnected). At threshold, non-trivial q-primary structure first appears. Above threshold, statistics converge to CL—but the rate of convergence depends on how far above threshold p is.

**Test.** For p = c · log(n)/n with c ∈ {1.0, 1.5, 2.0, 3.0, 5.0}, compute Jacobian statistics for n up to 200. Identify the critical value of c at which the q-rank distribution transitions from degenerate to CL-like.

**Impact.** Would connect graph Jacobian arithmetic to the rich theory of phase transitions in random graphs, potentially identifying new universality classes at criticality.

**Catalog References.** `Catalog/Pythagorean/GraphJacobians/ArithmeticStatistics.lean`, `Catalog/Pythagorean/TropicalMorse/CycleBirth/Concentration.lean` (tropical phase transitions).

**Proof Strategy.** At the connectivity threshold, the reduced Laplacian has entries dominated by vertex degrees ~ log(n). The Smith normal form should be analyzable via a perturbation theory approach: write L* = (expected value) + (random fluctuation) and study how SNF changes under small perturbations.

**Domain Bridges.** Random graph theory (Erdős–Rényi phase transitions) → arithmetic statistics → statistical physics (criticality).

**Lineage.** Extends Direction 1 to the sparse regime.

**Ambition.** Paradigm-shifting. Would create a "phase diagram" for arithmetic statistics of random structures.

**The key insight is:** the connectivity threshold is where topological structure (cycles, genus) first appears, and cycles create the non-trivial part of the Jacobian. The arithmetic statistics at criticality should reveal a new universality class.

**Why now?** The Jacobian is trivial below connectivity threshold and well-behaved far above it. The critical window is where the interesting structure lives, and our moment framework provides the right observables to detect the transition.

---

## Direction 3: Sandpile Criticality and Jacobian Order Parameters

**Conjecture.** The prime-power moments M_{q,k} of the graph Jacobian serve as order parameters for self-organized criticality in the Abelian sandpile model. The sandpile's critical exponents can be expressed in terms of the scaling behavior of E[M_{q,k}] with system size n.

**Test.** Simulate the Abelian sandpile model on G(n, 1/2) for n up to 100. Measure the avalanche size distribution and compare its scaling exponent to the scaling of E[M_{2,1}] − 2 (the deviation from CL). Test whether log(E[M_{q,k}] − E_{CL}[M_{q,k}]) scales linearly with log(n).

**Impact.** Would provide the first rigorous connection between arithmetic invariants of the critical group and dynamical observables of self-organized critical systems. Could lead to new exactly solvable models in statistical physics.

**Catalog References.** `Catalog/Pythagorean/GraphJacobians/ArithmeticStatistics.lean` (moment monotonicity, Theorem E), `Catalog/Pythagorean/TropicalBridge/ChipFiringCorrespondence.lean` (chip-firing dynamics), `Catalog/Pythagorean/SandpileCriticality/` (sandpile models).

**Proof Strategy.** The key observation is that the recurrent configurations of the sandpile form a torsor for the Jacobian group. The avalanche sizes should be related to the orders of subgroups, which are in turn determined by the invariant factors. The moment M_{q,k} counts elements of bounded order, providing a direct link between group structure and dynamics.

**Domain Bridges.** Arithmetic statistics → statistical physics (SOC) → dynamical systems.

**Lineage.** Extends the sandpile/chip-firing correspondence in `ChipFiringCorrespondence.lean` with arithmetic tools from this work.

**Ambition.** Grand challenge. Would bridge two major fields that have been connected only informally.

**The key insight is:** the Jacobian group IS the symmetry group of the sandpile's recurrent sector, so arithmetic invariants of the Jacobian should be reflected in the system's dynamical universality class.

**Why now?** The chip-firing correspondence is already formalized in the catalog. Our moment framework provides the quantitative bridge from group-theoretic invariants to dynamical observables.

---

## Direction 4: Higher-Dimensional Jacobians of Random Simplicial Complexes

**Conjecture.** For random 2-dimensional simplicial complexes (the Linial–Meshulam model), the homology groups H₁(X; ℤ), which are the higher-dimensional analogues of graph Jacobians, also obey Cohen–Lenstra statistics.

**Test.** Generate random 2-complexes on n vertices with face probability p. Compute H₁(X; ℤ) via Smith normal form of the boundary matrix ∂₂. Compare q-primary statistics to CL predictions for q = 2, 3, 5.

**Impact.** Would extend the CL-graph bridge to higher dimensions, suggesting a universal principle: "topology produces Cohen–Lenstra statistics." This would connect to tropical Hodge theory and motivic cohomology.

**Catalog References.** `Catalog/Pythagorean/GraphJacobians/ArithmeticStatistics.lean` (moment framework), `Catalog/Pythagorean/DerivedPersistence/` (persistent homology).

**Proof Strategy.** The boundary matrix ∂₂ of a random 2-complex is a random integer matrix with entries in {0, ±1}. Apply Wood's universality theorem to show that its cokernel (= H₁) has CL-distributed q-primary parts. Our Theorem C provides the moment-to-distribution bridge.

**Domain Bridges.** Algebraic topology → arithmetic statistics → random matrix theory → tropical Hodge theory.

**Lineage.** Natural generalization from 1-dimensional (graphs) to higher-dimensional complexes.

**Ambition.** Solid extension with paradigm-shifting implications if successful.

**The key insight is:** the boundary matrices of random simplicial complexes are random integer matrices just like reduced Laplacians, so the same cokernel statistics should apply.

**Why now?** The Linial–Meshulam model has become a central object in random topology. Our framework provides the exact arithmetic tools (moments, profiles, recovery theorems) to analyze the number-theoretic structure of random homology groups.

---

## Direction 5: Coding Theory Applications — Jacobian-Optimized LDPC Codes

**Conjecture.** The error-correcting performance of graph-based LDPC codes is correlated with the q-primary profile of the underlying graph's Jacobian. Specifically, codes from graphs whose Jacobians have CL-like statistics at the relevant prime q (related to the channel characteristic) achieve near-optimal performance.

**Test.** Construct LDPC codes from Cayley graphs of known groups and from random Erdős–Rényi graphs. Measure bit error rates under AWGN channel simulation. Correlate performance with Jacobian invariant factors and q-profiles.

**Impact.** Would provide a number-theoretic design criterion for error-correcting codes, complementing the existing graph-theoretic criteria (girth, expansion) with arithmetic ones.

**Catalog References.** `Catalog/Pythagorean/GraphJacobians/ArithmeticStatistics.lean` (all theorems).

**Proof Strategy.** The connection is through the cycle space: the parity-check matrix of an LDPC code is related to the graph's Laplacian, and the code's minimum distance is related to the smallest non-trivial cycle. The Jacobian captures the algebraic structure of cycles. The q-primary profile at the relevant prime determines the code's resilience to errors in clusters of size q^k.

**Domain Bridges.** Arithmetic statistics → coding theory → telecommunications.

**Lineage.** Novel application direction inspired by the Jacobian-as-cokernel framework.

**Ambition.** Solid extension with high practical impact.

**The key insight is:** the Jacobian IS the cycle space of the graph modulo boundaries, so its arithmetic structure directly governs the error-correcting properties of graph-based codes.

**Why now?** 5G and 6G communication standards use LDPC codes whose design is still largely empirical. A number-theoretic design criterion could lead to systematic improvements.
