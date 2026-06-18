# Future Directions: Piecewise Linear Hodge Theory for Neural Networks

## Synthesis

This cycle established a rigorous foundation connecting ReLU neural network decision surfaces to combinatorial topology through what we call the *PL Hodge bound*. The key results are: (1) the Zaslavsky deletion-restriction recurrence, which gives the fundamental tool for counting linear regions; (2) the width-depth tradeoff theorem, showing that depth creates exponentially more regions than width; (3) PL Hodge symmetry, mirroring classical Hodge symmetry for architecturally balanced networks; and (4) Betti vanishing, showing that narrow networks cannot support high-dimensional topology.

The most promising cross-domain connection is between the PL Hodge diamond and tropical geometry. The Catalog already contains work on tropical structures (`Catalog/Tropical/TropicalStructure.lean`, `Catalog/Computation/BranchingPrograms.lean`). ReLU networks compute tropical rational functions (max of affine functions), and the decision surface $V(f)$ is a tropical hypersurface. Tropical Hodge theory has been actively developed by Itenberg, Katzarkov, Mikhalkin, and Zharkov, and our combinatorial bounds should correspond to tropical Hodge numbers. Bridging these would connect the Catalog's existing tropical framework directly to network topology.

The second major opportunity is connecting to the information-theoretic framework. The Catalog's `Computation/AffineDistortionComplexity.lean` and entropy bounds suggest that topological complexity (measured by Betti numbers or Hodge numbers) should relate to the information capacity of the network. The total Hodge number $\sum h^{p,q}$ is bounded by $2^{w_1} \cdot 2^{w_L} \cdot \prod w_i$, which has a natural interpretation as a capacity measure in bits.

---

### Direction 1: Tropical Hodge Theory for ReLU Networks

**Conjecture**: For a ReLU network computing a tropical rational function $f = \max(a_1 \cdot x + b_1, \ldots, a_m \cdot x + b_m)$, the tropical Hodge numbers of the tropical hypersurface $V(f)$ equal the PL Hodge bounds established in this cycle, i.e., $h^{p,q}_{\text{trop}}(V(f)) = \binom{w_1}{p} \cdot \binom{w_L}{q} \cdot \prod w_i$ for generic weights. Specifically, the tropical homology groups $H^{p,q}_{\text{trop}}(V(f))$ have rank exactly equal to the PL Hodge bound.

**Test**: For a single-layer network $f(x_1, x_2) = \max(a_1 x_1 + b_1 x_2 + c_1, \ldots, a_w x_1 + b_w x_2 + c_w)$ with random generic coefficients, compute the tropical homology of $V(f)$ using the Itenberg-Katzarkov-Mikhalkin-Zharkov framework. Verify that $h^{0,1} = h^{1,0} = w$ for input dimension 2.

**Impact**: This would establish a precise dictionary between neural network architecture and tropical algebraic geometry, opening the door to using tropical intersection theory for understanding network composition and training.

**Catalog References**: `Catalog/Tropical/TropicalStructure.lean`, `Catalog/Computation/BranchingPrograms.lean`, `Catalog/Tropical/HodgeShadow/TropicalCycleCorrespondence.lean`

**Proof Strategy**: 
1. Formalize the tropical hypersurface $V(f)$ as a polyhedral complex in Lean.
2. Define tropical Hodge numbers via the Itenberg-Katzarkov-Mikhalkin-Zharkov construction (cosheaves on the polyhedral complex).
3. Prove that for generic linear coefficients, the tropical Hodge numbers equal the combinatorial bounds from our PL Hodge diamond.
4. The key lemma is that generic hyperplane arrangements produce simplicial (non-degenerate) polyhedral complexes where all cosheaf cohomology is captured by face counts.

**Domain Bridges**: Computation <-> Tropical, MachineLearning <-> Algebra

**Lineage**: Builds on `plHodgeBound` and `zaslavsky_recurrence` from this cycle, and the tropical structures in the Catalog.

**Ambition**: grand_challenge

---

### Direction 2: Persistent Topological Complexity Bounds

**Conjecture**: During gradient descent training of a ReLU network with architecture $(n, w_1, \ldots, w_L, 1)$, the Betti numbers of the decision surface $V(f_t)$ at time $t$ satisfy: (a) $b_k(V(f_0)) = 0$ for random initialization with high probability, (b) $b_k(V(f_t))$ is non-decreasing during the early phase of training (before overfitting), and (c) the maximum $b_k$ achieved during training satisfies $b_k^{\max} \leq \binom{m}{k+1}$ where $m$ is the total number of hidden neurons. The persistent homology diagram $\{(b_k(t), t)\}$ encodes the "topological learning curve" of the network.

**Test**: Train a ReLU network with architecture $(2, 8, 4, 1)$ on a synthetic dataset with known topology (e.g., two concentric circles) using SGD. At each epoch, compute the decision boundary in a bounding box and extract its Betti numbers using computational topology software (GUDHI or Ripser). Plot $b_0(t)$ and $b_1(t)$ versus epoch number. Verify monotonicity in early training and the upper bound from our theorems.

**Impact**: Would provide a formal theory of "topological learning curves" — how networks acquire topological structure during training. This could lead to early stopping criteria based on topology rather than validation loss.

**Catalog References**: `Computation/PLHodgeBound.lean` (this cycle), `Catalog/Computation/AffineDistortionComplexity.lean`

**Proof Strategy**:
1. Define a formal notion of "topological learning curve" as a function $t \mapsto (b_0(t), b_1(t), \ldots)$.
2. Prove that for ReLU networks, the decision surface changes combinatorial type only at finitely many training steps (when a data point crosses a hyperplane boundary).
3. Show that each combinatorial transition can change each $b_k$ by at most $\pm 1$ (analogous to Morse theory for PL functions).
4. The upper bound follows directly from the Betti vanishing theorem.

**Domain Bridges**: Computation <-> MachineLearning, Algebra <-> Physics

**Lineage**: Builds on `betti_vanishing` and `total_betti_le_exp` from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Information-Theoretic Interpretation of the Hodge Diamond

**Conjecture**: The total PL Hodge number $H_{\text{total}} = \sum_{p,q} h^{p,q}_{\text{PL}}$ equals $(1 + w_1)(1 + w_L) \cdot \prod w_i$ (by the binomial theorem), and this quantity bounds the *topological mutual information* between input and output: $I_{\text{top}}(X; Y) \leq \log_2(H_{\text{total}})$ bits, where $I_{\text{top}}$ measures the information carried by the topology of the decision surface (as opposed to its geometry).

**Test**: Define topological mutual information precisely as the number of bits needed to specify which connected component of $V(f)^c$ (complement of the decision surface) a point belongs to. For a network with architecture $(2, w, 1)$, this is $\log_2(R(w, 2))$ bits. Verify that $\log_2(R(w, 2)) \leq \log_2(H_{\text{total}}) = \log_2((1+w)^2) = 2\log_2(1+w)$ for $w = 1, \ldots, 100$.

**Impact**: Would establish the PL Hodge number as a fundamental capacity measure, complementing VC dimension (which counts shattering patterns) and Rademacher complexity (which measures function class richness) with a topological measure.

**Catalog References**: `Catalog/Computation/AffineDistortionComplexity.lean`, `rational_affine_encodable_gives_entropy_bound`

**Proof Strategy**:
1. Formalize topological mutual information as the log of the number of path-connected components of $\mathbb{R}^n \setminus V(f)$.
2. Relate this to $b_0$ of the complement, which equals the number of regions.
3. Use the Zaslavsky bound $R(m,n) \leq 2^m$ and the relationship $2^m \leq (1+w_1) \cdot (1+w_L) \cdot \prod w_i$ (to be established case-by-case).
4. The key insight is that the Hodge total counts *all* topological degrees of freedom, while regions count only $b_0$.

**Domain Bridges**: Computation <-> EML, MachineLearning <-> Cryptography

**Lineage**: Builds on `zaslavsky_le_pow`, `sum_choose_eq_pow`, and the entropy bounds from the Catalog.

**Ambition**: extension

---

### Direction 4: Equivariant PL Hodge Theory

**Conjecture**: For a ReLU network with weight-sharing symmetry (e.g., a convolutional network with group $G$ acting on the input), the PL Hodge diamond decomposes into irreducible representations of $G$: $h^{p,q} = \sum_{\rho \in \hat{G}} m_\rho \cdot h^{p,q}_\rho$, where $h^{p,q}_\rho$ is the Hodge number restricted to the $\rho$-isotypic component. For the cyclic group $G = \mathbb{Z}/k\mathbb{Z}$ (circular convolution), $h^{p,q}_\rho \leq \binom{\lfloor w/k \rfloor}{p} \cdot \binom{\lfloor w/k \rfloor}{q}$.

**Test**: For a 1D convolutional network with kernel size 3, stride 1, and circular padding on input of length 6 (so $G = \mathbb{Z}/6\mathbb{Z}$), compute the Hodge diamond of the decision surface for random weights. Verify that the diagonal entries satisfy $h^{p,p} \leq \binom{\lfloor w/6 \rfloor}{p}^2$.

**Impact**: Would provide the first formal connection between symmetry in network architecture and symmetry in decision surface topology, potentially explaining why convolutional networks generalize better than fully-connected ones (they have "less topology" per parameter).

**Catalog References**: `Catalog/Algebra/MatrixGroupGeneration.lean`, `Computation/PLHodgeBound.lean`

**Proof Strategy**:
1. Define equivariant PL complexes where $G$ acts on the face lattice.
2. Decompose the face vector into representations: $f_k = \sum_\rho m_{k,\rho} \cdot \dim(\rho)$.
3. Apply the PL Hodge bound to each isotypic component separately.
4. The key lemma is that weight-sharing reduces the effective number of independent hyperplanes from $w$ to $\lfloor w/|G| \rfloor$.

**Domain Bridges**: Algebra <-> MachineLearning, Computation <-> Geometry

**Lineage**: Builds on `pl_hodge_symmetry` and `hodge_bound_mono_first_width` from this cycle.

**Ambition**: extension

---

### Direction 5: Certified Topological Complexity for Adversarial Robustness

**Conjecture**: A ReLU network with architecture $(n, w_1, \ldots, w_L, 1)$ is $\epsilon$-topologically robust if the decision surface $V(f)$ has no connected component with diameter less than $\epsilon$. The minimum $\epsilon$ for which the network is $\epsilon$-topologically robust satisfies $\epsilon \geq C \cdot \|W\|^{-1} \cdot (\text{vol}(\text{domain}))^{1/n} \cdot (b_0)^{-1/n}$, where $\|W\|$ is the spectral norm of the weight matrices, $b_0$ is the number of connected components, and $C$ is a universal constant depending only on $n$.

**Test**: For a trained ReLU network on MNIST (simplified to 2D via PCA), compute the minimum distance between distinct connected components of the decision surface. Compare to the predicted lower bound using the Betti number $b_0$ from our framework and the weight matrix norms.

**Impact**: Would provide architecture-level certificates of adversarial robustness based on topological complexity bounds, complementing existing Lipschitz-based certificates.

**Catalog References**: `Catalog/Computation/BarrierFramework.lean`, `Computation/PLHodgeBound.lean`

**Proof Strategy**:
1. Use the Betti bound to upper-bound $b_0 \leq \binom{m}{1} = m$, where $m$ is the number of hyperplanes.
2. The domain volume divided by $b_0$ gives the average volume per component.
3. Use the isoperimetric inequality for convex polytopes to convert volume to diameter.
4. The spectral norm controls the "aspect ratio" of each polytopic component.

**Domain Bridges**: Computation <-> Cryptography, MachineLearning <-> Geometry

**Lineage**: Builds on `betti_vanishing`, `total_betti_le_exp`, and barrier framework from the Catalog.

**Ambition**: extension
