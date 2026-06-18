# Future Directions: Tropical Activation Complexes

## Synthesis

This cycle established the **Tropical Activation Complex (TAC)** as a rigorous mathematical framework linking neural network architecture to decision boundary geometry. The key achievement is the **Fundamental Theorem of TACs**, a chain of inequalities — tropical degree ≤ region bound ≤ 2^(fold number), singularity budget ≤ (fold number)² — that connects four structural invariants of the decision boundary. This was proved alongside the **AM-GM depth-width trade-off** showing that balanced architectures maximize tropical degree.

The most promising cross-domain connection is between TACs and the existing catalog's tropical cryptographic work (`Cryptography/TropicalMinPlusOWF.lean`, `Cryptography/TropicalOneWayFoundations.lean`). Both share the min/max-plus semiring structure, suggesting that neural network decision boundaries and tropical one-way functions may share algebraic properties. Specifically, the non-invertibility results for tropical hash operations (`tropical_add_noninvertible` in `Catalog/Tropical/TropicalStructure.lean`) may generalize to show that recovering network weights from decision boundary geometry is computationally hard — a new angle on neural network privacy.

The direction with highest breakthrough potential is **Tropical Bézout for Network Composition** (Direction 1): proving that composing two TACs multiplies their tropical degrees, analogous to Bézout's theorem for algebraic varieties. This would give the first rigorous algebraic explanation for why deep networks are exponentially more expressive than shallow ones — not just in region count, but in algebraic complexity.

---

### Direction 1: Tropical Bézout Theorem for Network Composition

**Conjecture**: Let TAC₁ and TAC₂ be Tropical Activation Complexes with tropical degrees d₁ and d₂. When the corresponding networks are composed (stacked), the resulting TAC has tropical degree exactly d₁ · d₂. More precisely: if f₁ : ℝⁿ → ℝᵐ has tropical degree d₁ and f₂ : ℝᵐ → ℝᵖ has tropical degree d₂, then f₂ ∘ f₁ has tropical degree at most d₁ · d₂, and this bound is tight for generic weights.

**Test**: (1) Formalize the definition of "tropical degree of a piecewise linear map" as the number of maximal linear regions whose images are distinct affine subspaces. (2) Verify the multiplicativity bound for small examples (2-layer networks with 2-3 neurons each). (3) Construct explicit weight matrices achieving the bound.

**Impact**: This would establish a full Bézout-type theorem for tropical varieties arising from neural networks — a genuine contribution to tropical geometry. If tight, it explains the exponential advantage of depth. If the bound is not tight generically, understanding the "Bézout gap" would reveal which architectures are algebraically wasteful.

**Catalog References**: `MachineLearning/TropicalDecisionBoundary.lean` (tropical_degree_le_region_bound, composition_region_bound_multiplicative), `Catalog/Tropical/TropicalStructure.lean`

**Proof Strategy**: (1) Define the tropical degree of a piecewise linear map as a combinatorial invariant of its polyhedral complex. (2) Show that composition of polyhedral complexes satisfies a product formula. (3) Use the key lemma that each linear region of f₁ intersects at most d₂ linear regions of f₂. Key machinery: polyhedral geometry, tropical intersection theory.

**Domain Bridges**: Tropical Geometry <-> Deep Learning Theory <-> Algebraic Geometry

**Lineage**: Builds on this cycle's `tropical_degree_le_region_bound` and `network_region_bound_le_exp_width`.

**Ambition**: grand_challenge

---

### Direction 2: Tropical Persistent Homology of Decision Boundaries

**Conjecture**: The Betti numbers of the decision boundary B = {x : f(x) = 0} of a ReLU network with TAC invariants (τ, φ, σ, ρ) satisfy: β₀(B) ≤ τ (the tropical degree bounds connected components), β₁(B) ≤ σ (the singularity budget bounds 1-cycles), and more generally βₖ(B) ≤ C(ρ, k+1) for all k. In particular, the total Betti number ∑ βₖ(B) ≤ 2^ρ.

**Test**: (1) Compute the decision boundary of small ReLU networks (2D input, 1 hidden layer) for random weights. (2) Compute the persistent homology of the boundary using a sublevel set filtration. (3) Compare the measured Betti numbers against the TAC bounds.

**Impact**: This connects deep learning geometry to topological data analysis. If the bounds are tight, it means the TAC completely determines the topological complexity of the decision boundary. If not, the gap reveals which topological features are "cheap" vs "expensive" for neural networks to create.

**Catalog References**: `MachineLearning/TropicalDecisionBoundary.lean` (TropicalActivationComplex), `Catalog/MachineLearning/PersistentStableHomotopy/Defs.lean`

**Proof Strategy**: (1) Use Morse theory for piecewise linear functions to relate critical points to Betti numbers. (2) Show that each singularity in the polyhedral complex contributes at most one generator to homology. (3) Apply the Morse inequality chain. Key lemma: the number of critical points of f|_B is bounded by σ.

**Domain Bridges**: Topology <-> Deep Learning <-> Combinatorial Geometry

**Lineage**: Builds on this cycle's `singularity_budget_le_fold_sq` and the TAC structure.

**Ambition**: grand_challenge

---

### Direction 3: Optimal Architecture via TAC Maximization

**Conjecture**: For fixed total parameter count P = n·w₁ + w₁·w₂ + ... + w_{L-1}·w_L + w_L (including weight matrices), the architecture maximizing the region bound satisfies wᵢ = Θ(√(P/L)) for all i, with optimal depth L* = Θ(log P). This predicts that the optimal depth grows logarithmically with parameter count.

**Test**: (1) For P ∈ {100, 1000, 10000}, enumerate architectures and compute region bounds. (2) Check whether the optimal depth matches Θ(log P). (3) Compare against empirically successful architectures (ResNet, Transformer layer counts).

**Impact**: A precise depth-width prescription from pure mathematics. If correct, this gives the first principled architectural recommendation from algebraic geometry, bypassing expensive architecture search.

**Catalog References**: `MachineLearning/TropicalDecisionBoundary.lean` (fold_depth_trade_off_prod_le_pow_avg, depth_advantage_concrete)

**Proof Strategy**: (1) Set up the optimization problem: maximize ∏ Z(wᵢ, n) subject to ∑ wᵢ · wᵢ₊₁ = P. (2) Use Lagrange multipliers (in the continuous relaxation). (3) Show the optimal solution has wᵢ ≈ √(P/L) and differentiate in L to find L*. Key lemma: the function L ↦ (P/L²)^{L/2} is maximized at L ∝ log P.

**Domain Bridges**: Optimization <-> Architecture Design <-> Combinatorial Geometry

**Lineage**: Builds on this cycle's depth advantage theorem and AM-GM trade-off.

**Ambition**: extension

---

### Direction 4: Tropical Non-Invertibility and Neural Network Privacy

**Conjecture**: Given only the decision boundary B = {x : f(x) = 0} of a ReLU network, recovering the weights is computationally hard (NP-hard or worse). More precisely, the "tropical inversion problem" — given a tropical hypersurface, find a ReLU network that produces it — requires time exponential in the tropical degree τ.

**Test**: (1) Formalize the tropical inversion problem. (2) Show that distinct weight matrices can produce identical decision boundaries (non-uniqueness). (3) Reduce a known NP-hard problem (e.g., satisfiability) to tropical inversion for networks with τ ≥ n.

**Impact**: This connects tropical geometry to cryptographic hardness. If true, it means decision boundaries are a "one-way function" from weights to geometry — you can efficiently compute the boundary from the weights, but not vice versa. This has implications for model privacy and intellectual property.

**Catalog References**: `Catalog/Tropical/TropicalStructure.lean` (tropical_add_noninvertible), `Cryptography/TropicalMinPlusOWF.lean` (tropical_owf_log_bound), `MachineLearning/TropicalDecisionBoundary.lean`

**Proof Strategy**: (1) Show that the tropical degree τ determines the "algebraic complexity" of inversion. (2) Construct a family of networks where inversion requires enumerating all τ activation patterns. (3) Reduce subset-sum to the pattern enumeration problem. Key connection: the noninvertibility of min/max (from `tropical_add_noninvertible`) is the fundamental mechanism.

**Domain Bridges**: Tropical Geometry <-> Cryptography <-> Computational Complexity <-> Deep Learning

**Lineage**: Builds on this cycle's TAC structure and existing catalog tropical cryptography results.

**Ambition**: grand_challenge

---

### Direction 5: TAC for Convolutional and Attention Architectures

**Conjecture**: Weight-sharing in convolutional neural networks reduces the effective tropical degree by a factor of the sharing ratio. Specifically, a convolutional layer with kernel size k, stride s, and c output channels on input of spatial size m has effective tropical degree c · ⌈m/s⌉ rather than c · m (the fully-connected degree). For attention layers, the tropical degree depends on the sequence length quadratically through the attention matrix.

**Test**: (1) Define the TAC for convolutional architectures by tracking weight-sharing constraints. (2) Compute region bounds for small ConvNets and compare against the fully-connected bound. (3) Verify that attention layers have quadratic tropical degree in sequence length.

**Impact**: Extends the TAC framework to modern architectures (CNNs, Transformers). If the effective tropical degree reduction from weight-sharing is significant, it explains why CNNs generalize better than fully-connected networks — they have lower algebraic complexity for the same parameter count.

**Catalog References**: `MachineLearning/TropicalDecisionBoundary.lean` (TropicalActivationComplex)

**Proof Strategy**: (1) Modify the TAC definition to account for linear constraints on weight matrices (weight sharing = affine subspace of weight space). (2) Show that the Zaslavsky bound with constrained hyperplanes gives a reduced count. (3) For attention: model the softmax as a tropical approximation and compute the resulting degree.

**Domain Bridges**: Deep Learning Architectures <-> Tropical Geometry <-> Representation Theory

**Lineage**: Builds on this cycle's TAC framework.

**Ambition**: extension
