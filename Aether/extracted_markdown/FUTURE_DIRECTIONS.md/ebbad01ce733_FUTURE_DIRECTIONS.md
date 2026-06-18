# Future Directions: Hyperbolic Number Theory

## Synthesis

This research cycle established the foundational framework for arithmetic on the Poincaré disk, proving twelve theorems ranging from Möbius disk preservation to exponential growth bounds. The most surprising discovery was the **zeta summand reversal**: while classical zeta summands 1/n^s are ≤ 1, hyperbolic zeta summands ‖z‖^{-2s} are ≥ 1 for disk points, fundamentally altering the convergence theory. This reversal is a direct geometric consequence of negative curvature and suggests that the analytic number theory of hyperbolic spaces may have a qualitatively different character from its Euclidean counterpart.

The strongest cross-domain connection emerging from this cycle is the **Cayley graph ↔ hyperbolic geometry bridge**, where the combinatorial growth rate of words in a finitely generated group exactly mirrors the exponential volume growth of geodesic balls in hyperbolic space. This connection, formalized through the word length metric and the free group growth theorem, links discrete algebra to continuous Riemannian geometry and opens pathways to both the Selberg trace formula and modern geometric group theory. The Catalog's existing work on algebraic structures (`Algebra/Foundations.lean`, `Algebra/Advanced.lean`) and the `critical_line_implies_unit_disk` theorem provide natural anchor points for extending these results.

The direction with highest breakthrough potential is **Direction 1** (Ihara Zeta Rationality), because it connects our hyperbolic integer framework to finite graph theory, where computational verification is feasible and the algebraic structure (determinantal formulas) is rich enough to yield formally provable results. This would also bridge the `Speculative` and `Algebra` domains in the Catalog.

---

### Direction 1: Ihara Zeta Function for Finite Quotient Graphs

**Conjecture**: For a finite (q+1)-regular graph G with adjacency matrix A, the Ihara zeta function Z_G(u)^{-1} = (1 - u²)^{r-1} · det(I - Au + qu²I), where r = |E| - |V| + 1 is the cycle rank. This determinantal formula can be verified for specific small graphs and proved in general using linear algebra over matrices with entries in ℤ[u].

**Test**: Compute Z_G(u) for the Petersen graph (10 vertices, 15 edges, 3-regular) and verify the determinantal formula. The cycle rank is r = 15 - 10 + 1 = 6, so Z^{-1} should be a polynomial of degree 20 in u with integer coefficients.

**Impact**: If proved, this gives a computable, algebraic bridge between graph theory and number theory on curved spaces. The Ihara zeta function is the finite-dimensional shadow of the Selberg zeta function, and proving its rationality would validate the entire hyperbolic zeta framework for finite quotients.

**Catalog References**: `Algebra/Foundations.lean` (matrix trace formula), `Speculative/HyperbolicNumberTheory/Core.lean` (Cayley words, word length)

**Proof Strategy**: (1) Define the Ihara zeta function as a product over primitive cycles. (2) Express cycle counting in terms of traces of powers of the adjacency matrix: #{cycles of length n} = Tr(A^n). (3) Use the identity log Z_G(u) = Σ_n Tr(A^n)/n · u^n and exponentiate. (4) Apply the matrix identity det(I - Au + qu²I) via characteristic polynomial theory.

**Domain Bridges**: NumberTheory <-> Combinatorics, Algebra <-> Geometry

**Lineage**: Builds on `free_group_growth_rate`, `word_count_le_geometric`, and the Cayley word framework from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Quantitative Milnor-Švarc for PSL(2,ℤ)

**Conjecture**: For the modular group Γ = PSL(2,ℤ) acting on the Poincaré disk with standard generators S (inversion) and T (translation), the quasi-isometry constants are C₁ = log(1 + √2) ≈ 0.881 and C₂ = log(1 + √2), i.e., |d_H(0, γ·0) - C₁ · wordLength(γ)| ≤ C₂ for all γ ∈ Γ.

**Test**: Compute d_H(0, γ·0) for all γ with wordLength ≤ 10 and verify the inequality. The constant C₁ = log(1 + √2) is the displacement of the generator T in the upper half-plane model.

**Impact**: A quantitative quasi-isometry would provide explicit error bounds for approximating hyperbolic distances by word lengths, with applications to computational geometry on hyperbolic surfaces and to the analysis of quantum surface codes.

**Catalog References**: `Speculative/HyperbolicNumberTheory/Core.lean` (hypPseudoDist, wordLength, mobiusMap), `Algebra/Foundations.lean` (matrix theory)

**Proof Strategy**: (1) Compute the displacement d(0, S·0) and d(0, T·0) explicitly. (2) Use the triangle inequality for hyperbolic distance plus induction on word length to get the upper bound. (3) For the lower bound, use the fact that Möbius transformations are isometries and bound the maximum contraction. Key lemma: d_H(0, φ_a(0)) = 2·arctanh(|a|).

**Domain Bridges**: Geometry <-> Algebra, Computation <-> Geometry

**Lineage**: Builds on `mobius_preserves_disk`, `wordLength_append`, and `hypPseudoDist_symm` from this cycle.

**Ambition**: extension

---

### Direction 3: Hyperbolic Surface Codes for Quantum Error Correction

**Conjecture**: A hyperbolic surface code based on a {p,q} tiling of the Poincaré disk (p-gons meeting q at each vertex, with 1/p + 1/q < 1/2) achieves a code rate R = 1 - 2/p - 2/q + 2/(pq) that is strictly positive, unlike Euclidean surface codes which have rate tending to 0 as the code size grows.

**Test**: For the {5,4} tiling (pentagons, 4 at each vertex), compute R = 1 - 2/5 - 2/4 + 2/20 = 1 - 0.4 - 0.5 + 0.1 = 0.2. Verify this by constructing the code explicitly on a finite quotient and counting logical qubits vs physical qubits.

**Impact**: If true, this would provide the first family of topological quantum codes with constant rate AND constant distance, a major open problem in quantum information. The key insight is that negative curvature allows tiles to grow exponentially while maintaining fixed local structure.

**Catalog References**: `Speculative/HyperbolicNumberTheory/Core.lean` (PDisk, exponential growth), `Computation/InfoEfficientAlgorithms.lean` (information-theoretic bounds)

**Proof Strategy**: (1) Formalize the {p,q} tiling as a CW-complex. (2) Compute the Euler characteristic χ = V - E + F using the tiling relations pF = 2E = qV. (3) The code rate is R = k/n where k = 2 - 2g = 2χ for genus g surface and n = number of edges. (4) Show R > 0 from the hyperbolic condition 1/p + 1/q < 1/2.

**Domain Bridges**: Geometry <-> Physics, NumberTheory <-> Computation

**Lineage**: Builds on `word_count_le_geometric` (exponential growth) and `mobius_preserves_disk` (disk geometry) from this cycle.

**Ambition**: grand_challenge

---

### Direction 4: Reduced Cayley Words and the Word Problem

**Conjecture**: The free reduction operation on Cayley words (canceling adjacent inverse pairs) satisfies: (a) reduction is confluent (any order of reductions gives the same result), (b) the reduced word length is a proper metric on the group, and (c) for the free group on n generators, the number of reduced words of length exactly k is 2n · (2n-1)^{k-1}.

**Test**: Enumerate all words of length ≤ 8 over {a, b, a⁻¹, b⁻¹}, reduce them, and verify the count formula. The reduced words of length 4 should number 2·2·(2·2-1)^3 = 4·27 = 108.

**Impact**: This extends the unreduced word theory to the mathematically correct reduced theory, where the word length truly represents the group-theoretic distance. It's a prerequisite for the quantitative Milnor-Švarc theorem (Direction 2).

**Catalog References**: `Speculative/HyperbolicNumberTheory/Core.lean` (CayleyLetter, CayleyWord, wordLength, exists_generator_factor)

**Proof Strategy**: (1) Define reduction as an iterated local operation. (2) Prove confluence using the diamond lemma (Newman's lemma for terminating rewrite systems). (3) Prove the count formula by induction: each new letter has 2n choices minus 1 forbidden (the inverse of the previous letter), giving 2n-1 choices.

**Domain Bridges**: Algebra <-> Computation, Logic <-> Algebra

**Lineage**: Direct extension of `wordLength_append`, `exists_generator_factor`, and the Cayley word framework.

**Ambition**: extension

---

### Direction 5: Tropical Hyperbolic Arithmetic

**Conjecture**: There exists a meaningful "tropical" version of hyperbolic arithmetic where addition is replaced by min and multiplication is replaced by addition, and the resulting tropical hyperbolic integers form a semifield. The tropical hyperbolic distance d_T(z,w) = -log(1 - |z-w|²/|1-z̄w|²) satisfies the tropical triangle inequality: d_T(x,z) ≤ max(d_T(x,y), d_T(y,z)).

**Test**: Verify the tropical triangle inequality numerically for 10,000 random triples in the disk. If it fails, characterize the failure set.

**Impact**: If true, this would bridge hyperbolic number theory with tropical geometry — two rapidly developing areas — and potentially connect the Catalog's `Tropical/` domain with `Speculative/HyperbolicNumberTheory/`. Tropical methods have been spectacularly successful in algebraic geometry (Mikhalkin's correspondence theorem), and a hyperbolic-tropical bridge could import these techniques into the study of Fuchsian groups.

**Catalog References**: `Tropical/` (tropical algebra framework), `Speculative/HyperbolicNumberTheory/Core.lean` (hypPseudoDist, PDisk), `Algebra/Foundations.lean`

**Proof Strategy**: (1) Define the tropical hyperbolic distance. (2) Express it in terms of the cross-ratio. (3) Use the ultrametric property of the boundary of the hyperbolic disk (which is a Cantor set with a natural ultrametric) to derive the tropical triangle inequality. Key insight: the boundary ∂𝔻 carries an ultrametric structure, and tropical geometry is the algebra of ultrametrics.

**Domain Bridges**: Tropical <-> Geometry, Algebra <-> Speculative

**Lineage**: Builds on `hypPseudoDist_symm`, `hypPseudoDist_origin`, and connects to the Catalog's tropical algebra infrastructure.

**Ambition**: extension
