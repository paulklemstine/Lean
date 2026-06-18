# Future Directions: Neural Network Decision Surface Topology

## Synthesis

This research cycle established a rigorous mathematical framework connecting ReLU neural network architecture to the topology of decision surfaces. The key insight is that ReLU networks produce *piecewise linear* decision surfaces, which belong to the well-studied world of polyhedral complexes. In this world, the Hodge Conjecture becomes trivially true — every homology class is automatically a sum of flat, algebraically-defined faces — but the *quantitative bounds* on topological complexity yield genuine mathematical content.

We proved that the "neural complexity" (maximum number of linear regions) of a network with hidden widths $w_1, \ldots, w_L$ is at most $2^{w_1 + \cdots + w_L}$, that Euler characteristics are bounded by total face counts, and that the combinatorial Hodge numbers satisfy $h^{p,q} \leq \binom{w_1}{p} \cdot \binom{w_L}{q}$. These results connect the *algebra* of the network (its weight matrices and architecture) to the *topology* of its output (the shape of its decision boundary).

The most promising cross-domain connection is to **tropical geometry**, which already exists in the Catalog (`Catalog/Tropical/`). ReLU networks compute piecewise linear functions that are exactly the objects studied in tropical algebra. The Zaslavsky bound on hyperplane arrangements is a classical result, but its interaction with the tropical structure of deep networks — where layers compose multiplicatively — is unexplored territory. The direction with highest breakthrough potential is the **tropical Hodge theory** connection (Direction 1), because tropical Hodge theory is an active area of current mathematical research, and our bounds provide the first concrete computational predictions.

---

### Direction 1: Tropical Hodge Theory for Deep ReLU Networks

**Conjecture**: For a ReLU network $f : \mathbb{R}^n \to \mathbb{R}$ with $L$ hidden layers, the tropical variety $\text{trop}(V(f))$ is a balanced polyhedral complex whose tropical Hodge numbers $h^{p,q}_{\text{trop}}$ satisfy the symmetry $h^{p,q}_{\text{trop}} = h^{q,p}_{\text{trop}}$ (tropical Hodge symmetry). Moreover, the tropical Hodge numbers are bounded by the network architecture: $h^{p,q}_{\text{trop}} \leq \binom{w_1}{p} \cdot \binom{w_L}{q}$.

**Test**: Compute the tropical variety of a 2-layer ReLU network with widths $(2, 3, 1)$ in $\mathbb{R}^2$. Enumerate all possible tropical Hodge numbers $h^{p,q}_{\text{trop}}$ for $p + q \leq 1$ and verify that $h^{0,1} = h^{1,0}$ (symmetry) and both are $\leq 6$.

**Impact**: If true, this establishes ReLU networks as a natural computational model for tropical geometry, linking the expressivity theory of deep learning to tropical algebraic geometry. If the symmetry fails, it identifies a concrete obstruction to tropical Hodge theory in the non-compact setting.

**Catalog References**: `Catalog/Tropical/`, `Catalog/Bridges/old/Tropical/Canonical/Basic.lean` (contains `relu_network_has_canonical_tropical_rational`)

**Proof Strategy**: 
1. Define the tropical variety of a piecewise linear function as the locus where the function is non-differentiable (the "crease set").
2. Prove that for a ReLU network, this coincides with the boundary of the linear region decomposition.
3. Compute the tropical homology groups using the combinatorial structure.
4. Verify Hodge symmetry by showing the tropical complex has a duality involution.
Key lemma needed: tropical balancing condition for ReLU network decision surfaces.

**Domain Bridges**: Tropical Geometry ↔ Machine Learning ↔ Algebraic Topology

**Lineage**: Builds on `relu_network_has_canonical_tropical_rational` from Catalog and the Zaslavsky bounds proved in this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Phase Transitions in Topological Expressivity

**Conjecture**: For a ReLU network with architecture $(n; w, w, \ldots, w)$ ($L$ hidden layers of width $w$), there exists a critical width $w^*(n, L)$ such that:
- For $w < w^*(n, L)$, the decision surface can only realize topologies with Betti numbers $\beta_k \leq w^{O(k)}$.
- For $w \geq w^*(n, L)$, the decision surface can realize any topology achievable by a polyhedral complex with at most $2^{wL}$ faces.

Moreover, $w^*(n, L) = \Theta(n)$ — the critical width equals the input dimension up to constants.

**Test**: For $n = 2$, enumerate all possible topological types (number of connected components, loops) of decision curves for networks with $L = 2$ layers and widths $w = 1, 2, 3, 4, 5$. Verify that the achievable Betti numbers jump discontinuously at some critical $w^*$.

**Impact**: If true, this provides a rigorous foundation for the empirical observation that "wider is better" in neural network design — but with a precise threshold. If false, it suggests that topological expressivity increases smoothly with width, which would have different implications for architecture selection.

**Catalog References**: `Shared/NeuralHodge/Defs.lean` (neural complexity, Zaslavsky bound), `Shared/NeuralHodge/Bounds.lean` (deep network bounds)

**Proof Strategy**:
1. Lower bound: construct explicit networks achieving each topology type for $w \geq w^*$.
2. Upper bound: show that for $w < w^*$, the Zaslavsky bound forces $\beta_k \leq Z(n,w)^L$.
3. The critical width emerges from the transition where $Z(n,w)$ changes from polynomial to exponential in $w$ (which happens at $w = n$).

**Domain Bridges**: Combinatorics ↔ Machine Learning ↔ Topology

**Lineage**: Builds on the Zaslavsky bound monotonicity (zaslavsky_mono_w) and neural complexity bound from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Effective Linear Region Counting via Activation Geometry

**Conjecture**: For a random ReLU network (weights drawn i.i.d. from $\mathcal{N}(0, 1/w)$), the expected number of linear regions in a bounded domain $B(0, R) \subset \mathbb{R}^n$ is $\Theta\left(\prod_{i=1}^L \binom{w_i}{\min(n, w_i)}\right)$, achieving the Zaslavsky bound to leading order.

**Test**: Generate 100 random ReLU networks with architecture $(2; 5, 5, 1)$ and count the number of distinct activation patterns in $[-10, 10]^2$ using a grid of $10^6$ points. Compare the mean count to $Z(2, 5)^2 = 16^2 = 256$.

**Impact**: If confirmed, this shows that random networks are "generic" in the hyperplane arrangement sense — their linear region counts match the Zaslavsky maximum. This would justify using the Zaslavsky bound as a practical (not just theoretical) measure of expressivity.

**Catalog References**: `Shared/NeuralHodge/Defs.lean` (zaslavskyBound), `card_activation_pattern`

**Proof Strategy**:
1. Show that random weight matrices produce hyperplanes in general position with probability 1.
2. Apply Zaslavsky's theorem to each layer.
3. Prove that layer compositions preserve genericity (the key technical challenge — hyperplanes in different layers are correlated through the weight matrices).

**Domain Bridges**: Probability ↔ Combinatorial Geometry ↔ Machine Learning

**Lineage**: Extends the Zaslavsky bound and activation pattern theory from this cycle.

**Ambition**: extension

---

### Direction 4: PL Morse Theory for Decision Surface Bifurcations

**Conjecture**: For a 1-parameter family of ReLU networks $f_t : \mathbb{R}^n \to \mathbb{R}$ (e.g., during gradient descent training), the topological type of the decision surface $V(f_t)$ changes only at finitely many critical values of $t$. At each critical value, exactly one of the following occurs: (a) two linear regions merge, (b) a linear region splits, or (c) a face of the decision surface collapses.

**Test**: Train a ReLU network on a 2D binary classification task and record the activation patterns at 1000 checkpoints during training. Count the number of topology-changing events and classify each as merge, split, or collapse.

**Impact**: If true, this provides a discrete Morse theory for neural network training, where the loss landscape is navigated through topological bifurcations. This would give a new perspective on training dynamics — understanding *when* and *how* the decision boundary changes its topology during learning.

**Catalog References**: `Shared/NeuralHodge/Defs.lean` (ActivationPattern, NetworkArch)

**Proof Strategy**:
1. Parameterize the weight space and show it intersects discriminant varieties transversally.
2. Classify the codimension-1 strata of the discriminant (where activation patterns change).
3. Prove each stratum corresponds to exactly one of the three event types.

**Domain Bridges**: Singularity Theory ↔ Machine Learning ↔ Optimization

**Lineage**: Builds on activation pattern theory from this cycle and classical PL Morse theory.

**Ambition**: extension

---

### Direction 5: Betti Number Certificates from Network Weights

**Conjecture**: Given a trained ReLU network with weight matrices $W_1, \ldots, W_L$ and bias vectors $b_1, \ldots, b_L$, there is a polynomial-time algorithm to compute the exact Betti numbers $\beta_0, \beta_1, \ldots, \beta_{n-2}$ of the decision surface $V(f)$, using only the activation pattern structure (without enumerating all $2^W$ patterns).

**Test**: Implement the algorithm for networks with architecture $(2; 4, 4, 1)$ and verify the computed Betti numbers against brute-force enumeration of the decision boundary cells.

**Impact**: If a polynomial-time algorithm exists, it transforms the study of neural network topology from theoretical to practical — one could routinely compute topological invariants of trained networks as a diagnostic tool. If no such algorithm exists (i.e., the problem is #P-hard), this establishes a fundamental computational barrier.

**Catalog References**: `Shared/NeuralHodge/Bounds.lean` (euler_char_abs_le_totalFaces, face_count_bound)

**Proof Strategy**:
1. Represent the decision boundary as a polyhedral complex using the hyperplane arrangement.
2. Exploit the layered structure: the complex decomposes along layers, with each layer contributing independently.
3. Use the Smith normal form of the boundary maps to compute Betti numbers.
4. Show the layered structure allows computing the Smith normal form in polynomial time.

**Domain Bridges**: Computational Topology ↔ Machine Learning ↔ Linear Algebra

**Lineage**: Builds on the face-count and Euler characteristic bounds from this cycle.

**Ambition**: extension
