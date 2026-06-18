# Future Directions

## Synthesis

This research cycle established a rigorous combinatorial-topological framework for analyzing ReLU neural network decision surfaces, proving the Zaslavsky recurrence, depth amplification theorem, and Hodge-type bounds. The most promising cross-domain connection discovered is the **tropical geometry bridge**: since ReLU(x) = max(0, x) is precisely the tropical addition operation, composing layers of a ReLU network amounts to evaluating a tropical rational function. This connects our polyhedral complexity bounds to the well-developed theory of tropical varieties and Newton polytopes, potentially yielding much tighter bounds.

The depth amplification theorem ((w+1)^n)^L quantifies the exponential advantage of depth over width, but this is likely far from tight for typical network architectures. The Zaslavsky recurrence we proved is the key structural tool: it decomposes the complexity of adding one hyperplane into a lower-dimensional problem, suggesting that recursive decomposition strategies could yield architecture-specific tight bounds.

The highest breakthrough potential lies in Direction 1 (Tropical Newton Polytope Bounds), which could replace the exponential Zaslavsky bounds with polynomial bounds for structured networks, and Direction 2 (Persistent Homology of Training Trajectories), which bridges our static topological bounds with the dynamics of gradient descent.

---

### Direction 1: Tropical Newton Polytope Bounds for ReLU Networks

**Conjecture**: For a ReLU network f: ℝⁿ → ℝ with architecture (n, w₁, ..., w_L, 1), the number of vertices of the Newton polytope of the associated tropical polynomial is at most ∏_i w_i, and the number of linear regions of f is bounded by the normalized volume of this Newton polytope.

**Test**: Compute the tropical polynomial and its Newton polytope for small networks (2→3→2→1 and 2→4→4→1) with random weights. Verify that the Newton polytope volume matches the region count. Compare with the Zaslavsky bound ((w+1)^n)^L — the tropical bound should be significantly tighter.

**Impact**: If true, this gives architecture-specific bounds on decision surface complexity that are polynomial rather than exponential in the layer widths. This would be a fundamental improvement over Zaslavsky-type bounds and connect neural network theory to tropical intersection theory.

**Catalog References**: `Catalog/Algebra/NeuralHodge/Theorems.lean`, `Novelty/NeuralHodge/Bounds.lean`, `Catalog/Tropical/Canonical/Basic.lean`

**Proof Strategy**: (1) Formalize the tropical polynomial representation of a ReLU network (each ReLU layer applies a tropical linear map followed by tropical addition with 0). (2) Prove that the Newton polytope of the composition has vertices bounded by the product of layer widths. (3) Use the Bernstein–Kushnirenko theorem analog in tropical geometry to bound the number of roots (= linear regions) by the mixed volume.

**Domain Bridges**: Tropical Geometry ↔ Neural Network Theory ↔ Convex Geometry

**Lineage**: Builds on `depth_amplification` and `zaslavskyBound_le_pow_succ` from this cycle, and the tropical-neural connection in `Catalog/Tropical/Canonical/Basic.lean`.

**Ambition**: grand_challenge

---

### Direction 2: Persistent Homology of Decision Surface Evolution During Training

**Conjecture**: During gradient descent training of a ReLU network on a binary classification task, the Betti numbers β_k(V(f_t)) of the decision surface V(f_t) = {x : f_t(x) = 0} satisfy a monotonicity property: for each k, the persistence diagram of {V(f_t)}_{t≥0} has bars whose total length is bounded by C · (learning_rate) · (total_training_steps) · (total_neurons).

**Test**: Train small ReLU networks (2→10→10→1) on synthetic 2D classification tasks. At each training step, compute the decision boundary and its Betti numbers. Plot the persistence diagram and measure total bar length. Verify that it grows at most linearly in training steps × learning rate × neurons.

**Impact**: If true, this provides a quantitative theory of how the topology of the decision surface evolves during training, connecting our static architecture bounds to the dynamics of optimization. If false, understanding the failure mode reveals which aspects of training cause topological phase transitions.

**Catalog References**: `Novelty/NeuralHodge/FVector.lean` (Euler characteristic bounds), `Novelty/NeuralHodge/Bounds.lean` (architecture bounds)

**Proof Strategy**: (1) Show that at each gradient descent step, the weight change δW induces a bounded change in the hyperplane arrangement. (2) Use the Zaslavsky recurrence to bound the change in region count. (3) Apply the nerve theorem to relate the change in regions to the change in Betti numbers. (4) Sum over training steps.

**Domain Bridges**: Topological Data Analysis ↔ Neural Network Theory ↔ Optimization Theory

**Lineage**: Builds on `euler_char_triangle_bound`, `refines_euler_bound`, and `network_region_bound_mono_width` from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Tight Zaslavsky Bounds via Oriented Matroid Theory

**Conjecture**: For a ReLU network with architecture (n, w₁, ..., w_L, 1) and generic weights, the number of linear regions equals exactly ∏_i Z(w_i, min(n, w_i)) (i.e., the Zaslavsky bound with the dimension capped by the layer width). In particular, for wide networks (w_i ≥ n for all i), the bound ∏_i Z(w_i, n) is tight.

**Test**: Enumerate linear regions of random ReLU networks with architectures (2,3,1), (2,4,1), (2,3,3,1), (2,4,4,1). Compare the observed count with ∏ Z(w_i, min(n, w_i)). If the bound is tight for "almost all" weight matrices, this supports the conjecture.

**Impact**: Tightness of the Zaslavsky bound would mean our architectural complexity bounds are best possible, establishing them as the correct measure of network expressivity.

**Catalog References**: `Novelty/NeuralHodge/FVector.lean` (zaslavsky_recurrence), `Novelty/NeuralHodge/Bounds.lean` (depth_amplification)

**Proof Strategy**: (1) Formalize oriented matroids for hyperplane arrangements. (2) Show that generic weight matrices produce arrangements in general position. (3) Apply Zaslavsky's theorem that the region count of a generic arrangement equals Z(m, n).

**Domain Bridges**: Oriented Matroid Theory ↔ Neural Network Theory ↔ Algebraic Geometry (generic position)

**Lineage**: Builds on `zaslavsky_recurrence` and `zaslavskyBound_mono_left` from this cycle.

**Ambition**: extension

---

### Direction 4: Dehn-Sommerville Relations for Neural Decision Surfaces

**Conjecture**: For a ReLU network whose decision surface is a simplicial complex (which occurs generically), the f-vector satisfies the Dehn-Sommerville relations: h_i = h_{d-i} for all i, where h is the h-vector transform of the f-vector and d is the dimension. This symmetry constrains the f-vector to a (⌊d/2⌋ + 1)-dimensional family.

**Test**: Compute the f-vector and h-vector for decision surfaces of random 3→w→1 networks. Verify the Dehn-Sommerville symmetry h_i = h_{d-i}. Check whether the symmetry breaks for non-generic weight matrices.

**Impact**: The Dehn-Sommerville relations would halve the number of independent face-count parameters, giving much stronger constraints on the possible topologies of decision surfaces. Combined with the Upper Bound Theorem, this would give tight upper bounds on individual Betti numbers.

**Catalog References**: `Novelty/NeuralHodge/Defs.lean` (FVectorData), `Catalog/Shared/NeuralHodge/Bounds.lean`

**Proof Strategy**: (1) Define the h-vector transform h_j = Σ (-1)^{j-i} C(d-i, j-i) f_i. (2) Prove that for Eulerian posets (which include simplicial complexes with sphere-like link), h_i = h_{d-i}. (3) Show that decision surfaces of generic ReLU networks are Eulerian.

**Domain Bridges**: Enumerative Combinatorics ↔ Neural Network Theory ↔ Commutative Algebra (Stanley-Reisner rings)

**Lineage**: Builds on `FVectorData` and `euler_char_triangle_bound` from this cycle.

**Ambition**: extension

---

### Direction 5: Information-Theoretic Lower Bounds on Decision Surface Complexity

**Conjecture**: Any ReLU network that correctly classifies a dataset of N points in ℝⁿ with margin γ must have decision surface with at least C · N / (γⁿ · vol(convex_hull)) faces of dimension n-1, where C is an absolute constant. In particular, the total face count satisfies f_{n-1} ≥ Ω(N/γⁿ).

**Test**: Generate random point clouds in ℝ² with two interleaved classes. Train networks of varying width and depth. Compute the number of (n-1)-dimensional faces of the decision boundary. Verify the lower bound f_{n-1} ≥ C · N / (γ² · area).

**Impact**: This would provide matching lower bounds for our upper bounds, showing that the architecture bounds are not just sufficient but necessary conditions for correct classification of complex datasets.

**Catalog References**: `Novelty/NeuralHodge/Bounds.lean` (network_region_bound_pos, depth_amplification)

**Proof Strategy**: (1) Use a packing argument: if the decision boundary has few faces, it cannot separate closely packed points. (2) Bound the number of connected components of the complement using the Euler characteristic bound. (3) Apply the Borsuk-Ulam theorem to show that separating N points requires Ω(N/γⁿ) faces.

**Domain Bridges**: Information Theory ↔ Neural Network Theory ↔ Geometric Measure Theory

**Lineage**: Builds on `network_region_bound_pos` and `euler_char_triangle_bound` from this cycle.

**Ambition**: extension
