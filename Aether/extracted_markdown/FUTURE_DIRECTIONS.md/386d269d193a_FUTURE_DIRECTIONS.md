# Future Directions: Neural Hodge Theory

## Synthesis

This cycle established the **Activation Complex** as a rigorous combinatorial framework for studying the topology of ReLU decision surfaces. The key discovery is that the "Hodge conjecture" for PL varieties is resolved by the freeness of face chain complexes, but the *quantitative* content—bounding face counts via Zaslavsky-type inequalities—is where genuine mathematical depth lives. The Zaslavsky recursion $Z(m+1, n+1) = Z(m, n+1) + Z(m, n)$ was proved and used to derive both exponential ($\leq 2^m$) and polynomial ($\leq (m+1)^n$) bounds on region counts.

The most promising cross-domain connection is between the activation complex and **tropical geometry**. The Zaslavsky bound has a natural tropical interpretation: the regions of a hyperplane arrangement correspond to vertices of a tropical hypersurface. This suggests that the tropical Satake isomorphism (existing catalog result in `Tropical/`) could be extended to provide refined Hodge-type bounds. Separately, the composition bound $\text{RegionBound} \leq 2^{\text{totalNeurons}}$ connects to the `weighted_sum_bound'` results in the Logic catalog, providing a bridge between neural network expressiveness and information-theoretic bounds on proof complexity.

The direction with highest breakthrough potential is **Direction 1** (Tropical Activation Duality), because it would connect two independently rich structures—hyperplane arrangements and tropical varieties—through a concrete duality that could yield new bounds in both directions.

---

### Direction 1: Tropical Activation Duality

**Conjecture**: For a ReLU network $f : \mathbb{R}^n \to \mathbb{R}$, the activation complex $\mathcal{A}(f)$ is dual (in the sense of face lattice duality) to the Newton polytope subdivision of the tropical polynomial $\text{trop}(f)$. Specifically, there exists a bijection between codimension-$k$ faces of $\mathcal{A}(f)$ and $k$-dimensional cells of the tropical complex of $\text{trop}(f)$, preserving the face relation.

**Test**: For a 2-layer ReLU network $f(x) = \max(w_1 \cdot x + b_1, 0) + \max(w_2 \cdot x + b_2, 0) + c$, compute both the activation complex and the tropical complex. Verify the face lattice duality explicitly for networks with 2-5 neurons in $\mathbb{R}^2$. If the bijection fails for any example, the conjecture is false.

**Impact**: If true, this would provide a powerful bridge between neural network geometry and tropical algebraic geometry. It would allow importing tropical intersection theory tools to compute Betti numbers of decision surfaces, potentially giving sharper bounds than the Zaslavsky approach. If false, the failure mode would reveal which aspects of ReLU networks are genuinely non-tropical.

**Catalog References**: `Catalog/Bridges/old/Tropical/Canonical/Basic.lean` (theorem `relu_network_has_canonical_tropical_rational`), `Tropical/` catalog.

**Proof Strategy**: Start by formalizing the tropical polynomial associated to a ReLU network (building on `relu_network_has_canonical_tropical_rational`). Define the tropical complex as the codimension-$k$ loci of the tropical hypersurface. Construct the bijection explicitly using the max-plus algebra structure. Prove face-preservation by induction on network depth.

**Domain Bridges**: Tropical ↔ MachineLearning, Algebra ↔ Geometry

**Lineage**: Builds on this cycle's ActivationComplex definition and Zaslavsky bound proofs, plus existing tropical catalog.

**Ambition**: grand_challenge

---

### Direction 2: Persistent Homology of Training Dynamics

**Conjecture**: During gradient descent training of a ReLU network, the Euler characteristic $\chi(\mathcal{A}(f_t))$ of the activation complex is a piecewise constant function of training time $t$, with jumps occurring exactly at the times when the activation pattern of some training data point changes. The total number of jumps is bounded by $O(T \cdot m)$ where $T$ is the number of training steps and $m$ is the number of neurons.

**Test**: Train a 2-4-4-1 network on a synthetic 2D classification dataset for 10,000 gradient descent steps. At each step, compute the activation complex by evaluating on a dense grid. Track $\chi$ over time. Count the number of jumps and compare to $T \cdot m$. If the bound is violated, the conjecture is false.

**Impact**: This would provide a rigorous topological perspective on neural network training. The jump times could serve as a natural "curriculum" for the network—indicating when qualitative changes in the decision boundary occur. This connects to the broader question of whether topological complexity is a useful regularizer.

**Catalog References**: `Applications/PoincareData/SimplicialComplex.lean` (Euler characteristic computation), `Computation/InfoEfficientAlgorithms.lean` (training bound framework).

**Proof Strategy**: Formalize the piecewise-constancy by showing that the sign vector of each data point is a continuous function of the weights (except at the measure-zero set where some neuron's pre-activation is exactly zero). The jump bound follows from a counting argument: each training step perturbs at most $m$ neurons' activations.

**Domain Bridges**: MachineLearning ↔ Computation, Topology ↔ Optimization

**Lineage**: Builds on this cycle's Euler characteristic bounds and activation complex definition.

**Ambition**: extension

---

### Direction 3: Tight Polynomial Bounds via Inclusion-Exclusion

**Conjecture**: For $m$ hyperplanes in general position in $\mathbb{R}^n$ with $m > n$, the exact number of faces of codimension $k$ is:
$$f_k = \binom{m}{k} \cdot 2^{m-k} \cdot \mathbb{1}[k \leq n]$$
and consequently the Euler characteristic satisfies $\chi = (-1)^n$. This is a strengthening of our $f_k \leq 3^m$ bound by a factor of $(3/2)^m$.

**Test**: Compute $f_k$ for random hyperplane arrangements with $m \in \{3, 4, 5, 6, 7\}$ in $\mathbb{R}^2$ and $\mathbb{R}^3$. Verify the formula. For the Euler characteristic, check $\chi = 1$ in even dimensions and $\chi = -1$ in odd dimensions.

**Impact**: A tight formula for face counts would upgrade the Zaslavsky bound from an upper bound to an exact computation in the generic case. This would give precise "Hodge numbers" for generic ReLU networks, analogous to the Hodge diamond in algebraic geometry.

**Catalog References**: This cycle's `zaslavsky_bound_succ`, `ActivationComplex.faceCount_le_pow`, `signVector_card`.

**Proof Strategy**: Use the inclusion-exclusion principle on the face lattice of the arrangement. The general position assumption means every $k$-fold intersection of hyperplanes has codimension exactly $k$, which gives the binomial coefficient. The factor $2^{m-k}$ counts the sign assignments to the remaining hyperplanes. Formalize using Finset.card of appropriate filters.

**Domain Bridges**: Algebra ↔ MachineLearning, Combinatorics ↔ Topology

**Lineage**: Direct extension of this cycle's Zaslavsky bound and face count theorems.

**Ambition**: extension

---

### Direction 4: Betti Number Bounds via Discrete Morse Theory

**Conjecture**: For any activation complex $\mathcal{A}$ with $m$ hyperplanes, the $k$-th Betti number $\beta_k$ satisfies:
$$\beta_k \leq f_k(\mathcal{A}) - f_{k-1}(\mathcal{A}) + f_{k-2}(\mathcal{A}) - \cdots$$
(the alternating sum of face counts, truncated). Furthermore, for generic arrangements, $\beta_k = 0$ for $k > 0$ (the complement is contractible).

**Test**: Compute the homology of the activation complex for small examples using the boundary operator. Verify that $\beta_k \leq f_k$ (the weak Morse inequality). Check contractibility for random arrangements in $\mathbb{R}^2$ with $m \leq 6$ hyperplanes.

**Impact**: Converting face count bounds to Betti number bounds would be the key step toward a genuine "Hodge number bound" for neural networks—bounding the topological complexity of decision surfaces in terms of architecture parameters. This is the deepest open question in neural network topology.

**Catalog References**: `Applications/PoincareData/SimplicialComplex.lean` (simplicial homology), this cycle's face count and Euler characteristic theorems.

**Proof Strategy**: Define the boundary operator on the face chain complex of the activation complex. Prove the chain complex property $\partial^2 = 0$. Apply the weak Morse inequality $\beta_k \leq f_k$ (which holds for any CW complex). For the generic contractibility claim, use the shellability of the face lattice of a hyperplane arrangement complement.

**Domain Bridges**: Topology ↔ MachineLearning ↔ Algebra

**Lineage**: Builds on this cycle's ActivationComplex, face counts, and Euler characteristic bounds.

**Ambition**: grand_challenge
