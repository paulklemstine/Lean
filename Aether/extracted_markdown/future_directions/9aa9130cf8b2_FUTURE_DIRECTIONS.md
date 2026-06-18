# Future Directions: Arithmetic Statistics of Graph Jacobians

## Synthesis

The three theorems established in this work — the divisibility criterion, the moment identity, and the profile antitone property — provide the deterministic algebraic backbone for a new research program connecting random graph theory to arithmetic statistics. Each future direction below builds on this foundation, extending it toward asymptotic results, physical models, coding theory, and tropical geometry. The unifying theme is that the Smith normal form of the reduced Laplacian serves as a universal bridge: any domain that produces integer matrices (graphs, lattices, codes, dynamical systems) can be connected to Cohen-Lenstra-type predictions through the invariant factor machinery we have formalized. The five directions below form a coherent research arc from foundational theory (Direction 1) through computational methodology (Direction 2) to increasingly ambitious cross-domain applications (Directions 3-5).

---

## Direction 1: Finite-n Moment Convergence Rates for G(n, p) Jacobians

**Conjecture:** For fixed prime q and edge probability p ∈ (0,1), there exist explicit constants C(q, p) and α(q, p) > 0 such that for all n ≥ n₀:

$$\left|\mathbb{E}[M_{q,1}(\text{Jac}(G(n,p)))] - q\right| \leq C(q,p) \cdot n^{-\alpha(q,p)}$$

where α(q, p) ≥ 1/2 for p bounded away from 0 and 1.

**Test:** Compute E[M_{q,1}] for G(n, 1/2) at n = 10, 20, 50, 100, 200, 500 (with 10,000 samples each) and fit the decay exponent α by log-linear regression of |E[M_{q,1}] - q| vs n.

**Impact:** This would be the first quantitative convergence result for graph Jacobian statistics, upgrading the qualitative conjecture of Wood (2017) to a rate theorem. It would establish graph Jacobians as a model system for Cohen-Lenstra with computable error bounds.

**Catalog References:**
- `Pythagorean/GraphJacobians/ArithmeticStatistics.lean`: `primePowerTorsionCount_eq_prod_gcd`, `primePowerTorsionCount_mono`
- `Catalog/Pythagorean/CohenLenstra/Defs.lean`: `geomProb`, `cyclicWeight`

**Proof Strategy:** Use the moment formula from Theorem B to reduce to counting lattice points in the Smith normal form. The key step is bounding the contribution of large invariant factors using spectral gap estimates for the Laplacian of G(n, p). Combine with Nguyen-Wood universality for random integer matrix cokernels.

**Domain Bridges:** Random matrix theory → combinatorial probability → analytic number theory (Tauberian theorems for extracting rates from moment generating functions).

**Lineage:** Extends Theorem B from exact identity to asymptotic convergence.

**Ambition:** ★★★★☆ — Substantial but within reach using existing random matrix techniques.

---

## Direction 2: Algorithmic Smith Normal Form Certification in Lean

**Conjecture:** There exists a verified algorithm in Lean 4 that computes the Smith Normal Form of any n × n integer matrix in O(n³ · B) bit operations (where B = log(max|M_ij|)) and produces a certificate (unimodular matrices U, V and diagonal D with UMV = D) that can be checked in O(n² · B) bit operations.

**Test:** Implement the algorithm for matrices up to 50 × 50 from random graph Laplacians. Verify that the certificate check passes in all cases and that runtime scales as predicted.

**Impact:** This would close the formalization gap between our algebraic theorems (which assume invariant factor data as input) and the graph-theoretic source. It would also provide the first formally verified SNF algorithm, useful far beyond graph Jacobians.

**Catalog References:**
- `Pythagorean/GraphJacobians/ArithmeticStatistics.lean`: `InvariantFactorData`
- `Catalog/Pythagorean/TropicalBridge/Defs.lean`: `graphLaplacian`

**Proof Strategy:** Formalize the iterative pivot-reduction algorithm. Maintain invariants at each step: (1) the matrix at step k is Smith-equivalent to the original, (2) the submatrix M[0:k, 0:k] is already in diagonal form with divisibility. The certificate consists of the accumulated row/column operations.

**Domain Bridges:** Computer algebra → formal verification → computational number theory.

**Lineage:** Infrastructure for all future computational work in the Catalog involving integer matrix invariants.

**Ambition:** ★★★☆☆ — Standard algorithm, main challenge is Lean engineering.

---

## Direction 3: Cohen-Lenstra for Random Regular Graphs (Grand Challenge)

**Conjecture:** For random d-regular graphs on n vertices (d ≥ 3 fixed), the q-primary statistics of Jac(G) converge to the Cohen-Lenstra distribution, but with a different rate of convergence than G(n, p). Specifically, the rate α_d(q) should depend on d through the spectral gap of the random regular graph:

$$\alpha_d(q) = \frac{1}{2}\left(1 - \frac{2\sqrt{d-1}}{d}\right) + O(q^{-1})$$

**Test:** Sample random 3-regular and 4-regular graphs for n = 20, 50, 100 (using the configuration model), compute Jacobian moments, and compare convergence rates against the predicted formula.

**Impact:** This would be paradigm-shifting: it would show that the Cohen-Lenstra universality extends beyond Erdős-Rényi to a fundamentally different graph ensemble, and would connect the convergence rate to spectral theory (the Alon-Boppana bound 2√(d-1) appears in the formula). It would establish arithmetic statistics as a probe for random graph spectral properties.

**Catalog References:**
- `Pythagorean/GraphJacobians/ArithmeticStatistics.lean`: all main theorems
- `Catalog/Pythagorean/CohenLenstra/Defs.lean`: CL distribution definitions

**Proof Strategy:** The key insight is that the reduced Laplacian of a random d-regular graph has much more structure than a general random matrix: its row sums are constrained, and its spectral gap is known (Friedman's theorem). Use the trace method to bound moments of the SNF, exploiting the spectral gap to control error terms.

**Domain Bridges:** Spectral graph theory ↔ arithmetic statistics ↔ random matrix theory ↔ representation theory (via Friedman's proof).

**Lineage:** Extends the entire framework from G(n,p) to random regular graphs.

**Ambition:** ★★★★★ — Grand challenge; if solved, would open a new subfield.

---

## Direction 4: Sandpile Dynamics and Arithmetic Order Parameters

**Conjecture:** For the abelian sandpile model on G(n, p), the correlation length of the avalanche size distribution is controlled by the largest invariant factor of the Jacobian:

$$\xi(G) \sim \log(\text{exp}(\text{Jac}(G)))$$

Under the Cohen-Lenstra conjecture, this predicts:

$$\mathbb{E}[\xi(G(n,p))] \sim c_p \cdot n$$

for an explicit constant c_p depending on p.

**Test:** Simulate the sandpile model on G(n, 1/2) for n = 20, 50, 100. Measure the avalanche correlation length and compare against log(exponent) of the Jacobian. Test the linear scaling prediction.

**Impact:** This would establish the first formal bridge between self-organized criticality (statistical physics) and arithmetic statistics (number theory). The invariant factors of the Jacobian would become order parameters for sandpile dynamics, providing number-theoretic explanations for physical phenomena.

**Catalog References:**
- `Pythagorean/GraphJacobians/ArithmeticStatistics.lean`: `exponent_eq_largest_factor`, `primePow_dvd_exponent_iff_dvd_largest`
- `Catalog/Pythagorean/ArithmeticSandpile/Defs.lean`: sandpile definitions

**Proof Strategy:** The key insight is that the relaxation time of the sandpile is controlled by the spectral gap of the Laplacian, while the *algebraic* relaxation is controlled by the exponent of the Jacobian (the order of the slowest-decaying mode in the group algebra). Theorem A connects the exponent to the largest invariant factor, which is in turn related to the smallest eigenvalue of the reduced Laplacian.

**Domain Bridges:** Statistical physics (self-organized criticality) ↔ arithmetic statistics ↔ spectral graph theory.

**Lineage:** Extends Theorem A into the physics domain.

**Ambition:** ★★★★☆ — Bold but testable; the sandpile-Jacobian connection is well-established.

---

## Direction 5: Tropical Hodge Theory and Jacobian Fibrations

**Conjecture:** For a family of graphs G_t parameterized by a tropical parameter t (e.g., edge weights in the tropical semiring), the invariant factor profile of Jac(G_t) varies semicontinuously in t, and the jumps in the profile correspond to tropical critical points of a natural height function.

More precisely: define the *tropical Jacobian fibration* as the map t ↦ InvariantFactorProfile(q, G_t). Then:
1. The levels λ_{q,j}(G_t) are upper semicontinuous in t.
2. The set of t where the profile changes is a tropical hypersurface.

**Test:** Consider weighted complete graphs K_n with edge weights drawn from {0, 1, 2, ..., M} (tropical integers). Compute invariant factor profiles as weights vary and verify semicontinuity. Plot the "phase diagram" of profile types.

**Impact:** This would connect tropical geometry (Baker-Norine Riemann-Roch, tropical abelian varieties) to arithmetic statistics, creating a new field of "tropical arithmetic statistics." The semicontinuity result would be analogous to the semicontinuity of fiber dimensions in algebraic geometry.

**Catalog References:**
- `Pythagorean/GraphJacobians/ArithmeticStatistics.lean`: `InvariantFactorProfile`, `qPrimaryCount_antitone`
- `Catalog/Pythagorean/TropicalBridge/Defs.lean`: tropical matrix definitions
- `Catalog/Pythagorean/TropicalBridge/ChipFiringCorrespondence.lean`: chip-firing/tropical bridge

**Proof Strategy:** The key insight is that the Smith invariant factors of an integer matrix are semicontinuous in the Zariski topology on matrix entries. For tropical deformations (which correspond to valuations of matrix entries), the divisibility conditions defining the profile are open, giving semicontinuity. The tropical critical points are where the rank of the SNF changes — exactly the tropical analogue of degeneration loci in algebraic geometry.

**Domain Bridges:** Tropical geometry ↔ arithmetic statistics ↔ algebraic geometry (degeneration theory) ↔ combinatorics (matroid theory, since tropical rank is matroid rank).

**Lineage:** Extends the profile structure (Theorem C) into the tropical/geometric domain.

**Ambition:** ★★★★★ — Grand challenge; would unify tropical geometry and arithmetic statistics.
