# Future Directions: Tropical Moduli Spaces

## Synthesis

This research cycle established the combinatorial foundations of tropical moduli spaces $M_g^{\text{trop}}$ through machine-verified proofs. The key achievement is a complete formalization of the dimension formula $\dim M_g^{\text{trop}} = 3g - 3$, proved from first principles via the handshaking lemma and genus formula. We introduced two novel structures: the `TropicalModuliComplex` (a poset of combinatorial types) and the `CyclePairingMatrix` (the tropical Torelli invariant), both with multiple proved properties.

The most promising cross-domain connection is the bridge between the cycle pairing matrix and spectral graph theory. The tropical Laplacian — whose symmetry and conservation law we proved — governs both the Jacobian structure (via its kernel) and the spectral geometry of the curve (via its eigenvalues). This connects our tropical moduli theory to the existing catalog's spectral and Satake results (see `Tropical/TropicalSatake.lean`, `Tropical/SpectralTheory.lean`). The Euler characteristic formula $\chi = 1 - g$ also bridges to the topological results in `Geometry/EulerTopology.lean`.

The direction with highest breakthrough potential is the **Tropical Schottky Problem** (Direction 1): characterizing which positive definite matrices arise as cycle pairing matrices of graphs. This is a concrete, testable conjecture that connects combinatorics (graph theory), linear algebra (positive definite matrices), and geometry (moduli spaces). A resolution would be a significant result in tropical geometry.

---

### Direction 1: Tropical Schottky Problem for Small Genus

**Conjecture**: For $g \geq 4$, the image of the tropical Torelli map $t: M_g^{\text{trop}} \to A_g^{\text{trop}}$ (sending a metric graph to its cycle pairing matrix) is a proper closed subset of the cone of $g \times g$ positive definite symmetric matrices. Specifically, the image has codimension $\binom{g}{2} - (3g - 3) + g = \binom{g}{2} - 2g + 3$, which is positive for $g \geq 4$.

**Test**: For $g = 4$, enumerate all trivalent graph types (there are finitely many), compute the parametric form of their cycle pairing matrices as functions of edge lengths, and check whether these parametric families span a 9-dimensional subset of the 10-dimensional space of $4 \times 4$ positive definite matrices. The predicted codimension is 1: the Schottky locus should be a hypersurface.

**Impact**: If true, this gives a tropical analogue of the classical Schottky problem and provides explicit equations for the tropical Schottky locus. If false, it would mean tropical abelian varieties are less constrained than classical ones — itself a surprising structural result.

**Catalog References**: `Geometry/TropicalModuli/CyclePairing.lean`, `Geometry/TropicalModuli/Torelli.lean`, `Tropical/TropicalSatake.lean`

**Proof Strategy**: 
1. Enumerate trivalent graphs of genus 4 (approximately 17 types)
2. For each type, express the cycle pairing matrix entries as linear functions of edge lengths
3. Compute the dimension of the image by analyzing the rank of the Jacobian matrix
4. If codimension > 0, find explicit polynomial constraints on the matrix entries

**Domain Bridges**: Tropical Geometry <-> Linear Algebra (positive definite matrices) <-> Combinatorics (graph enumeration)

**Lineage**: Builds on `CyclePairingMatrix` structure and `torelli_fiber_edge_bound` from this cycle. Extends the classical Schottky problem (Riemann, Schottky, Igusa) to the tropical setting.

**Ambition**: grand_challenge

---

### Direction 2: Spectral Gap Monotonicity Under Edge Contraction

**Conjecture**: Let $\Gamma$ be a metric tropical curve and $\Gamma'$ the result of contracting an edge $e$ (setting $\ell(e) \to 0$). Then the smallest positive eigenvalue $\lambda_1$ of the Laplacian satisfies $\lambda_1(\Gamma') \geq \lambda_1(\Gamma)$. That is, contraction never decreases the spectral gap.

**Test**: Compute $\lambda_1$ for all trivalent graphs of genus $g \leq 5$ with random edge lengths, contract each edge, and compare. If any counterexample is found, the conjecture is false. If all examples pass, attempt a formal proof using the variational characterization of $\lambda_1$.

**Impact**: If true, this establishes a monotonicity principle for the moduli complex: moving toward lower-dimensional faces (by contraction) increases spectral connectivity. This would have applications to mixing time bounds for random walks on tropical curves and to the convergence of tropical theta functions.

**Catalog References**: `Geometry/TropicalModuli/Laplacian.lean` (laplacian_symmetric, laplacian_row_sum_zero), `Tropical/SpectralTheory.lean`, `Tropical/SpectralDynamics.lean`

**Proof Strategy**:
1. Express $\lambda_1$ via the Rayleigh quotient: $\lambda_1 = \min_{f \perp \mathbf{1}} \frac{f^T L f}{f^T f}$
2. Show that contracting an edge restricts the space of test functions (merge two coordinates)
3. Use the minimax principle to conclude $\lambda_1$ increases
4. Key lemma: the restriction map preserves orthogonality to constants

**Domain Bridges**: Spectral Graph Theory <-> Tropical Geometry <-> Analysis (Rayleigh quotient)

**Lineage**: Builds on Laplacian formalization from this cycle. Related to Cheeger inequality and expander graph theory.

**Ambition**: extension

---

### Direction 3: Tropical Curve Counting via Moduli Dimension

**Conjecture**: The number of trivalent graph types (combinatorial types of top-dimensional cells in $M_g^{\text{trop}}$) grows super-exponentially in $g$: specifically, $|\mathcal{T}_g| \sim C \cdot (6g-5)!! / (3g-3)!$ for some constant $C > 0$, matching the asymptotic count of trivalent graphs with $2g-2$ labeled vertices.

**Test**: Compute $|\mathcal{T}_g|$ for $g = 2, 3, 4, 5, 6$ by exhaustive enumeration of trivalent multigraphs (with labeled vertices, then divide by automorphisms). Compare with the asymptotic formula. Known values: $|\mathcal{T}_2| = 2$ (theta, dumbbell), $|\mathcal{T}_3| = 5$.

**Impact**: If the growth rate matches, it confirms that tropical moduli spaces become rapidly complex with genus — the "combinatorial explosion" of moduli. If the growth is slower (due to connectivity constraints or automorphism cancellation), it would reveal unexpected rigidity in the space of tropical curves.

**Catalog References**: `Geometry/TropicalModuli/Defs.lean` (trivalent_num_edges, trivalent_num_verts), `Geometry/TropicalModuli/Torelli.lean` (TropicalModuliComplex)

**Proof Strategy**:
1. Formalize the notion of isomorphism class of trivalent graphs of genus $g$
2. Use Burnside's lemma to count orbits under automorphisms
3. Establish upper and lower bounds using the matrix-tree theorem
4. Compare with OEIS sequence A005967 (number of 2-connected cubic graphs)

**Domain Bridges**: Combinatorics (graph enumeration) <-> Tropical Geometry <-> Asymptotic Analysis

**Lineage**: Builds on the vertex-edge formulas proved this cycle. Extends classical results of Wormald on random cubic graphs.

**Ambition**: extension

---

### Direction 4: Tropical Hodge Theory via the Cycle Pairing Matrix

**Conjecture**: The eigenvalues of the cycle pairing matrix $Q(\Gamma)$ satisfy a "tropical Hodge inequality": for any metric graph $\Gamma$ of genus $g$ with eigenvalues $\mu_1 \leq \cdots \leq \mu_g$, we have $\mu_k \geq k \cdot \ell_{\min}(\Gamma)$ where $\ell_{\min}$ is the shortest edge length. In particular, the smallest eigenvalue $\mu_1 \geq \ell_{\min}$.

**Test**: For 1000 random metric graphs of genus 3-5 (random trivalent graph + random edge lengths), compute the eigenvalues of $Q$ and check whether $\mu_1 \geq \ell_{\min}$. The linear growth bound $\mu_k \geq k \cdot \ell_{\min}$ is stronger and may fail — if so, determine the correct growth rate.

**Impact**: If true, this gives a quantitative lower bound on the "tropical periods" of a curve in terms of its shortest edge. This would be the tropical analogue of period estimates in classical Hodge theory (e.g., the Schottky-Jung relations). If the linear bound fails but $\mu_1 \geq \ell_{\min}$ holds, this is still a useful tropical Hodge-type result.

**Catalog References**: `Geometry/TropicalModuli/CyclePairing.lean` (CyclePairingMatrix, trace_pos, diag_entry_pos), `Tropical/HodgeTheory/`

**Proof Strategy**:
1. Express $Q$ in terms of edge lengths and cycle incidence
2. Use Gershgorin's circle theorem for eigenvalue bounds
3. The diagonal entry $Q_{ii} = \sum_{e \in C_i} \ell(e) \geq \ell_{\min} \cdot |C_i| \geq \ell_{\min} \cdot 1$
4. For the Gershgorin bound: $\mu_k \geq Q_{kk} - \sum_{j \neq k} |Q_{kj}|$

**Domain Bridges**: Tropical Geometry <-> Hodge Theory <-> Spectral Theory (eigenvalue estimates)

**Lineage**: Builds on CyclePairingMatrix structure from this cycle. Connects to the tropical Hodge decomposition program in `Tropical/HodgeTheory/`.

**Ambition**: grand_challenge

---

### Direction 5: Berkovich Skeleton Functor

**Conjecture**: There exists a functorial construction $\text{Sk}: \mathcal{M}_g^{\text{an}} \to M_g^{\text{trop}}$ from the Berkovich analytification of $\mathcal{M}_g$ to the tropical moduli space, such that $\text{Sk}$ is a strong deformation retract. Moreover, this functor commutes with the Torelli map: $\text{Sk} \circ t^{\text{an}} = t^{\text{trop}} \circ \text{Sk}$.

**Test**: For $g = 2$, construct the Berkovich analytification of $\mathcal{M}_2$ over $\mathbb{Q}_p$ (for a prime $p$) and verify that its skeleton is the known $M_2^{\text{trop}}$ (a graph with 2 vertices corresponding to theta and dumbbell types, connected by an edge). Check commutativity with the Torelli map on explicit genus-2 curves.

**Impact**: If formalized, this would be the first machine-verified proof of the Berkovich skeleton construction for a moduli space. It would connect non-Archimedean geometry to tropical combinatorics in a precise, verified way. This is a deep result that would significantly advance the formalization of modern algebraic geometry.

**Catalog References**: `Geometry/TropicalModuli/Torelli.lean` (TropicalModuliComplex, torelli_fiber_edge_bound), `Tropical/PAdicTropical.lean`

**Proof Strategy**:
1. Define Berkovich spaces as types with a valuation-theoretic topology
2. Construct the skeleton functor using the theory of semistable models
3. Prove the retraction property using the contractibility of Berkovich analytic domains
4. For commutativity: show that tropicalization of the period matrix gives the cycle pairing matrix

**Domain Bridges**: Non-Archimedean Geometry <-> Tropical Geometry <-> Algebraic Geometry (moduli theory)

**Lineage**: This is the ultimate goal of the tropical moduli program. Builds on all results from this cycle. Connects to Baker-Payne-Rabinoff's work on tropical curve theory.

**Ambition**: grand_challenge
