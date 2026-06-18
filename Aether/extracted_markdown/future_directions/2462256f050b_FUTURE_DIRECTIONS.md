# Future Directions: Lorentzian Spectral Stability Theory

## Synthesis

The spectral eigengap theory for uniform matroids establishes a precise mechanism — the gap between the positive eigenvalue and the negative eigenvalue cluster of the quadratic leaf Hessian — as the controller of Lorentzian stability. This opens five interconnected research directions: extending the spectral principle to non-uniform matroids, connecting to random matrix theory for probabilistic stability, exploiting representation-theoretic structure for symmetric matroids, developing computational tools for general stability certification, and bridging to phase transition theory in statistical physics. Together, these directions aim to build a complete **Lorentzian condition number theory** analogous to the classical condition number theory of numerical linear algebra.

---

## Direction 1: Spectral Stability for Graphic Matroids via Graph Laplacian Gaps

**Conjecture:** For the graphic matroid of a connected graph G on n vertices with m edges, the Lorentzian stability radius of the spanning tree polynomial is controlled by the algebraic connectivity (Fiedler value) λ₂(G) of the graph Laplacian.

**The key insight is** that the quadratic leaves of the spanning tree polynomial correspond to edge-contracted minors, and their Hessians are submatrices of the weighted graph Laplacian, so the minimum spectral gap across leaves should reduce to the minimum Fiedler value across minors — a computable graph-theoretic invariant.

**Why now?** The uniform matroid result proves the principle works in the maximally symmetric case. Graphic matroids are the natural next family: they are well-studied, have rich spectral theory (via graph Laplacians), and include the uniform matroid as a special case (complete graph). Mathlib now has substantial graph theory and spectral gap infrastructure.

**Test:** For small graphs (n ≤ 8), compute the quadratic leaf Hessians of spanning tree polynomials explicitly, determine their spectral gaps, and verify that the minimum gap correlates with the Fiedler value. Falsification: find a graph where the stability radius is not proportional to the Fiedler value.

**Impact:** Would provide the first non-trivial Lorentzian stability bounds for a combinatorially defined polynomial family, with immediate applications to network reliability estimation.

**Catalog References:**
- `Catalog/Pythagorean/UniformMatroidLorentzian.lean` — the uniform matroid case as template
- `Catalog/Speculative/AutoResearch/LorentzianStability.lean` — generic stability framework

**Proof Strategy:** 
1. Compute quadratic leaves of spanning tree polynomials for cycle, path, and complete bipartite graphs.
2. Identify the Hessian-Laplacian connection via the matrix-tree theorem.
3. Use the Courant-Fischer minimax theorem to bound the minimum spectral gap.
4. Verify with formal proofs for small cases, then generalize.

**Domain Bridges:** Spectral graph theory → Lorentzian polynomial theory → Network reliability

**Lineage:** Direct extension of the uniform matroid spectral gap theorem

**Ambition:** Moderate — extends established framework to well-studied family

---

## Direction 2: Random Perturbation Universality and Tracy-Widom Thresholds

**Conjecture:** Under Gaussian random perturbations of the leaf Hessian, the Lorentzian stability threshold exhibits a phase transition governed by the Tracy-Widom distribution, with the critical perturbation scale being σ_c = 1/m^{2/3} times the spectral gap.

**The key insight is** that the transition from "Lorentzian" to "non-Lorentzian" under random perturbation is a rank-one versus rank-two transition for the positive-eigenvalue count, which is exactly the type of transition governed by Tracy-Widom statistics in random matrix theory. The BBP (Baik-Ben Arous-Péché) phase transition for spiked random matrices should apply directly.

**Why now?** The exact spectral gap determination for uniform matroids provides the deterministic baseline needed to apply random matrix perturbation theory. Recent advances in BBP-type transitions for finite-rank perturbations of Wigner matrices (Capitaine-Donati-Martin-Féral, 2009) give precise tools.

**Test:** For m = 50, 100, 200, add Gaussian random matrices with variance σ² to the leaf Hessian and empirically measure the probability that Lorentzianity is lost. Plot P(non-Lorentzian) vs σ and check for Tracy-Widom scaling. Falsification: if the transition width scales differently from m^{-2/3}.

**Impact:** Would connect Lorentzian polynomial theory to the deepest results in random matrix theory, and provide probabilistic stability guarantees for noisy computation.

**Catalog References:**
- `Catalog/Pythagorean/UniformMatroidLorentzian.lean` — base spectral gap
- `Catalog/Speculative/AutoResearch/LorentzianStability.lean` — perturbation framework

**Proof Strategy:**
1. Express the eigenvalue distribution of H_m + σW (Wigner) using known BBP results.
2. Identify the critical σ where the second-largest eigenvalue transitions from negative to positive.
3. Prove the Tracy-Widom fluctuation scaling at the critical point.

**Domain Bridges:** Random matrix theory → Lorentzian stability → Probabilistic algorithm analysis

**Lineage:** Builds on spectral gap determination; requires random matrix tools

**Ambition:** Grand challenge — connects two deep fields in a novel way

---

## Direction 3: Association Scheme Classification of Lorentzian Margins

**Conjecture:** For every matroid whose quadratic leaf Hessians decompose under an association scheme (including Johnson, Hamming, and q-analog schemes), the Lorentzian stability radius admits a closed-form expression in terms of the scheme's eigenmatrix.

**The key insight is** that the J - I Hessian for uniform matroids is the first non-trivial element of the Johnson scheme J(n, 1), and its eigengap comes from the scheme's eigenmatrix. For matroids whose symmetry group acts transitively on the quadratic leaves, the leaf Hessians should similarly decompose via an association scheme, giving exact spectral information.

**Why now?** The uniform matroid result demonstrates the scheme-to-gap pipeline for the simplest (Johnson) case. The classification of association schemes with few classes is well-established (Bannai-Ito theory), providing a catalog of candidate matroid families.

**Test:** Compute quadratic leaf Hessians for partition matroids (direct product of Johnson schemes) and q-analog matroids. Verify that the spectral gaps match predictions from the eigenmatrix. Falsification: find a symmetric matroid where the scheme decomposition fails to predict the stability radius.

**Impact:** Would create a systematic theory of "exactly solvable" Lorentzian stability problems, analogous to exactly solvable models in statistical mechanics.

**Catalog References:**
- `Catalog/Pythagorean/UniformMatroidLorentzian.lean` — Johnson scheme case
- `Catalog/Pythagorean/LorentzianSpectralGap.lean` — spectral gap framework

**Proof Strategy:**
1. Classify matroids with transitive automorphism groups on quadratic leaves.
2. For each, identify the underlying association scheme.
3. Extract eigenmatrix entries as spectral gaps.
4. Prove stability radius formulas from scheme theory.

**Domain Bridges:** Association schemes → Matroid theory → Lorentzian stability → Coding theory

**Lineage:** Generalizes uniform matroid result via algebraic combinatorics

**Ambition:** Grand challenge — requires deep algebraic combinatorics

---

## Direction 4: Algorithmic Certification for General Matroid Stability

**Conjecture:** There exists a polynomial-time algorithm that, given an oracle for the matroid M on n elements, certifies a lower bound on the Lorentzian stability radius of its generating polynomial with multiplicative approximation factor (1 - ε) for any ε > 0.

**The key insight is** that the stability radius equals the minimum spectral gap across all quadratic leaves, and while the number of leaves is exponential, the spectral gap can be approximated by sampling random leaves and using concentration inequalities. The uniform matroid case shows that the minimum equals the average (by symmetry), suggesting that for "almost symmetric" matroids, random sampling suffices.

**Why now?** The exact formula for uniform matroids provides ground truth for algorithm validation. Recent work on matroid polytope sampling (Anari et al.) provides efficient sampling of bases, which can be adapted to sample quadratic leaves.

**Test:** Implement the sampling-based algorithm for graphic matroids on random graphs with n ≤ 20. Compare the estimated stability radius to the exact value (computed by brute force). Falsification: if the approximation factor degrades worse than 1/poly(n).

**Impact:** Would make Lorentzian stability certification practical for real-world matroid optimization, enabling certified robustness in supply chain and network design applications.

**Catalog References:**
- `Catalog/Pythagorean/UniformMatroidLorentzian.lean` — exact computation template
- `Catalog/Speculative/AutoResearch/LorentzianStability.lean` — certification framework

**Proof Strategy:**
1. Develop a random leaf sampling strategy with provable coverage.
2. Use matrix concentration (Tropp's inequality) to bound the error from sampling.
3. Prove that the algorithm's output is within (1-ε) of the true minimum gap.
4. Analyze complexity: polynomial in n, 1/ε, and matroid rank.

**Domain Bridges:** Algorithm design → Matroid theory → Operations research → Certified computation

**Lineage:** Computational extension of the theoretical stability framework

**Ambition:** Moderate — algorithmic contribution building on theoretical foundations

---

## Direction 5: Phase Transitions in Lorentzian Partition Functions

**Conjecture:** For the canonical partition function Z_β = Σ_{|I|=r} exp(β · Σ_{i∈I} h_i) on the uniform matroid with random fields h_i, the Lorentzian phase (at most one positive eigenvalue in all quadratic leaf Hessians) persists if and only if β < β_c where β_c = 1/√(r(n-r)) · (1 + o(1)) as n → ∞.

**The key insight is** that the exponential weighting exp(β·h) introduces a coefficient perturbation whose magnitude grows with β and the field distribution. The Lorentzian phase boundary is a genuine thermodynamic phase transition: below β_c, the system is in a "log-concave" phase with good sampling properties; above β_c, correlations become non-Lorentzian, potentially creating sampling barriers.

**Why now?** The exact spectral gap for uniform matroids provides the zero-field (β = 0) reference point. Statistical physics of log-concave distributions is an active area (following Eldan's stochastic localization), and the Lorentzian phase boundary provides a concrete model for study.

**Test:** For n = 10, r = 5 with Gaussian random fields, simulate Z_β for β ∈ [0, 5], compute all quadratic leaf Hessians, and measure the fraction that remain Lorentzian. Plot the order parameter (minimum spectral gap) vs β and identify the critical temperature. Falsification: if the transition is smooth (crossover) rather than sharp (phase transition) at the predicted β_c.

**Impact:** Would connect Lorentzian polynomial theory to statistical mechanics and potentially explain sampling barriers in high-temperature expansions of combinatorial partition functions.

**Catalog References:**
- `Catalog/Pythagorean/UniformMatroidLorentzian.lean` — zero-field spectral gap
- `Catalog/Speculative/AutoResearch/LorentzianStability.lean` — perturbation theory

**Proof Strategy:**
1. Model exp(β·h) coefficient perturbation as a multiplicative perturbation of the leaf Hessian.
2. Use the quadratic form bound to translate field strength into spectral perturbation.
3. Apply concentration of measure for the random field to identify β_c.
4. Prove sharpness of the transition using second-moment methods.

**Domain Bridges:** Statistical physics → Lorentzian stability → Sampling algorithms → Phase transitions

**Lineage:** Physical interpretation of the mathematical stability theory

**Ambition:** Grand challenge — requires bridging pure mathematics and statistical physics
