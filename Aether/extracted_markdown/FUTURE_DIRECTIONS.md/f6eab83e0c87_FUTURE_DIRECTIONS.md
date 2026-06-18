# Future Research Directions

## Synthesis

This research cycle established the formal connection between ReLU neural network decision surfaces and tropical geometry through polyhedral combinatorics. The key discovery is that the topological complexity of decision boundaries — measured by Betti numbers — is strictly bounded by architecture-dependent combinatorial quantities derived from Zaslavsky's hyperplane arrangement theorem. The multiplicative composition principle (each layer multiplies the region count) combined with the Weak Morse Inequality (Betti numbers ≤ face counts) yields the main bound β_total ≤ n · ∏ Z(w_i, n).

The most promising cross-domain connection is between **tropical geometry** and **neural network expressiveness**. The identification relu(x) = max(x, 0) = x ⊕_trop 0 transforms questions about neural network topology into questions about tropical hypersurfaces, opening access to the substantial machinery of tropical intersection theory. The Hodge symmetry h(w₁, w_L, p, q) = h(w₁, w_L, w₁-p, w_L-q) is a concrete manifestation of this connection, mirroring classical Serre duality.

The direction with highest breakthrough potential is **Direction 1 (Tropical Betti Sparsity)**, because proving that bottleneck layers kill higher homology would give the first architecture-level explanation for why narrow layers improve generalization — a fundamental question in deep learning theory.

---

### Direction 1: Tropical Betti Sparsity Through Bottleneck Layers

**Conjecture**: For a ReLU network f: ℝⁿ → ℝ with first hidden layer width w₁, the Betti numbers of the decision surface V(f) = {x : f(x) = 0} satisfy β_k(V(f)) = 0 for all k > min(n-1, w₁). In other words, the bottleneck width acts as a topological dimension barrier: no k-dimensional "holes" can survive passage through a layer narrower than k.

**Test**: (1) Implement random ReLU network generation for architectures 4→w₁→8→1 with w₁ ∈ {1, 2, 3, 4}. (2) Compute the decision surface using marching cubes on a grid. (3) Compute persistent homology using Ripser. (4) Verify β_k = 0 for k > w₁ across 1000 random initializations for each architecture. A single counterexample disproves the conjecture.

**Impact**: If true, this explains why bottleneck architectures (autoencoders, U-nets) generalize well: the bottleneck constrains the topological complexity of internal representations, not just their information content. This would be the first rigorous connection between architecture topology and generalization bounds.

**Catalog References**: `Shared/NeuralHodge/Defs.lean` (NetworkArch, zaslavskyBound), `Shared/NeuralHodge/Bounds.lean` (chain_module_rank, hodge_bound_combinatorial)

**Proof Strategy**: For a single hidden layer, the decision surface is a hyperplane arrangement complement, and the Folkman-Lawrence topological representation theorem gives β_k = 0 for k ≥ w₁. For deep networks, establish that the composition f_L ∘ ... ∘ f_1 factors through ℝ^{w₁}, so the image of V(f) under projection has dimension ≤ w₁ - 1. Then use the Mayer-Vietoris sequence for the polyhedral decomposition to show higher Betti numbers vanish. Key lemma needed: if a PL map factors through ℝ^m, then β_k of the preimage of 0 vanishes for k ≥ m.

**Domain Bridges**: Tropical Geometry ↔ Neural Network Expressiveness; Algebraic Topology ↔ Generalization Theory

**Lineage**: Builds on weak_morse_inequality, hodgeBound_vanishing, and the chain complex framework from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Persistent Homology of Training Dynamics

**Conjecture**: During gradient descent training of a ReLU network on a classification task, the Betti numbers of the decision surface follow a characteristic trajectory: β_0 decreases monotonically (connected components merge) while β_1 first increases then decreases (loops form during early training to "surround" data clusters, then simplify). Formally, there exists a critical training time t* such that β_1(V(f_t)) achieves its maximum at t = t* and ∂β_0/∂t < 0 for all t > 0.

**Test**: Train 100 random 2→10→10→1 networks on the two-moons dataset. At each training epoch, compute the decision boundary on a grid and compute persistent homology. Plot β_0(t) and β_1(t) trajectories. Check monotonicity of β_0 and unimodality of β_1 statistically (Kendall's tau test for monotonicity with p < 0.01).

**Impact**: If true, this gives a topological characterization of the "phases of training" — the initial rapid decrease in β_0 is the network "finding" the clusters, the rise and fall of β_1 is the network first overfitting (complex boundary) then regularizing (simplified boundary). This would complement existing loss-curve analyses with geometric information.

**Catalog References**: `MachineLearning/NeuralHodge/Core.lean` (ReLUArchitecture, BettiData, weak_morse_inequality)

**Proof Strategy**: For the β_0 monotonicity, use the observation that gradient descent on cross-entropy loss drives the network toward larger margins, which merges connected components of the decision boundary. Formalize using the polyhedral complex structure and show that small perturbations of weights can only merge, not split, connected components (use continuity of the weight → decision boundary map). For the β_1 unimodality, this may require a different approach — possibly through the lens of Morse theory applied to the loss landscape.

**Domain Bridges**: Topological Data Analysis ↔ Optimization Theory; Polyhedral Geometry ↔ Neural Network Training

**Lineage**: Builds on the chain complex and Betti data framework from this cycle. Extends the static topology bounds to dynamic (training-time) topology.

**Ambition**: grand_challenge

---

### Direction 3: Refined Zaslavsky Bounds via Activation Patterns

**Conjecture**: For a ReLU network with L hidden layers of width w and input dimension n, the number of *realizable* activation patterns (activation patterns that occur for at least one input x ∈ ℝⁿ) is at most ∏_{i=1}^{L} min(2^{w}, Z(w, n)) ≤ Z(w, n)^L, and this bound is tight: there exist weight matrices achieving this count.

**Test**: For architectures (2, w, 1) with w ∈ {2, 3, 4, 5, 6, 7, 8}, enumerate all realizable activation patterns by exhaustive search over a fine grid of inputs. Compare the count to Z(w, 2) = 1 + w + C(w,2). Check whether equality is achieved for some weight configuration found by optimization.

**Impact**: Tightness of the Zaslavsky bound for neural networks is currently open. If tight, this validates the Zaslavsky bound as the correct quantity for expressiveness analysis. If not tight for deep networks, the gap reveals a "depth discount" in topological complexity.

**Catalog References**: `Shared/NeuralHodge/Defs.lean` (ActivationPattern, card_activation_pattern, zaslavskyBound), `Shared/NeuralHodge/Bounds.lean` (zaslavsky_le_pow)

**Proof Strategy**: For tightness in the single-layer case, construct explicit weight matrices placing hyperplanes in general position (use the theory of generic hyperplane arrangements). For deep networks, use the composition principle: if each layer's hyperplanes are in general position relative to the previous layer's regions, the product bound is achieved. Formalize "general position" as a Zariski-open condition on the weight space.

**Domain Bridges**: Combinatorial Geometry ↔ Neural Network Capacity; Algebraic Geometry (generic position) ↔ Weight Space Geometry

**Lineage**: Extends zaslavskyBound_poly and zaslavskyBound_mono from this cycle. Tests the optimality of the main compositional bound.

**Ambition**: extension

---

### Direction 4: Tropical Hodge Numbers and Intersection Theory

**Conjecture**: The Hodge bound h(w₁, w_L, p, q) = C(w₁, p) · C(w_L, q) is achieved by a ReLU network if and only if the first and last hidden layers have hyperplanes in general position AND p + q ≤ n - 1 (the codimension constraint). Moreover, the "tropical Hodge diamond" — the matrix [h(w₁, w_L, p, q)]_{p,q} — satisfies tropical analogs of the Lefschetz hyperplane theorem: h(w₁, w_L, p, q) = h(w₁, w_L, p-1, q-1) for p + q < n/2.

**Test**: For architecture (3, 4, 4, 1): compute the full Hodge diamond [C(4,p) · C(4,q)]_{p,q} for 0 ≤ p,q ≤ 4. Verify symmetry (already proved) and check the Lefschetz property by comparing diagonal entries. For random networks with this architecture, compute the actual "Hodge numbers" (dimensions of tropical cohomology groups) using the software polymake or TOPCOM.

**Impact**: A tropical Lefschetz theorem for neural networks would constrain not just the total Betti numbers but their distribution across bidegrees — giving much finer control over the topology of decision surfaces.

**Catalog References**: `MachineLearning/NeuralHodge/Core.lean` (hodgeBound, hodge_symmetry, hodgeBound_vanishing)

**Proof Strategy**: Use the hard Lefschetz theorem in tropical geometry (established by Adiprasito-Huh-Katz for matroids). The neural network's polyhedral complex has the structure of a tropical linear space, and the Hodge-Riemann relations should apply. Formalize the tropical intersection pairing on the face lattice and verify the signature conditions.

**Domain Bridges**: Tropical Geometry ↔ Matroid Theory (Adiprasito-Huh-Katz); Hodge Theory ↔ Neural Network Architecture

**Lineage**: Directly extends hodge_symmetry and hodgeBound_le_pow from this cycle.

**Ambition**: grand_challenge

---

### Direction 5: Euler Characteristic as a Training Objective

**Conjecture**: Regularizing a neural network by penalizing |χ(V(f))| (the absolute Euler characteristic of the decision surface) produces smoother decision boundaries and better generalization than L2 weight decay alone. Specifically, for classification on standard benchmarks, adding λ · |χ_estimate| to the loss function with λ chosen by cross-validation improves test accuracy by at least 1% over L2 regularization.

**Test**: Implement a differentiable Euler characteristic estimator for 2D decision surfaces (compute χ from a triangulation of the decision boundary on a grid, use straight-through estimator for gradients). Train 2→20→20→1 networks on MNIST (projected to 2D via PCA) with: (a) no regularization, (b) L2 regularization, (c) Euler characteristic regularization, (d) L2 + Euler. Compare test accuracies and decision boundary smoothness (measured by total variation of the boundary curve).

**Impact**: This would be the first practical application of topological regularization derived from the Morse inequality framework. Even if the specific conjecture fails, the experiment reveals whether topological complexity is a useful inductive bias.

**Catalog References**: `MachineLearning/NeuralHodge/Core.lean` (ChainComplexData.eulerChar, euler_poincare_betti_bound)

**Proof Strategy**: No formal proof is expected — this is an empirical conjecture. However, the theoretical justification comes from our bounds: lower |χ| implies fewer topological features, which by the Weak Morse Inequality implies a simpler polyhedral decomposition.

**Domain Bridges**: Topology ↔ Regularization Theory; Polyhedral Geometry ↔ Optimization

**Lineage**: Applies euler_poincare_betti_bound from this cycle as theoretical motivation.

**Ambition**: extension
