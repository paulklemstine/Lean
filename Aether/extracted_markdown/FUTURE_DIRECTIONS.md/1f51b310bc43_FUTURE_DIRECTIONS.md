# Future Directions: Algebraic Neural Architecture Research Roadmap

## Breakthrough Opportunities (ranked by impact)

### 1. Module Universal Approximation Theorem (Full Proof)

**Theorem Statement**: For a Noetherian commutative ring R, finitely generated R-module M, and activation σ transcendental on proper ideals: every continuous function R^n → M is ε-approximable by a module neural network with width bounded by the prime-spectral function.

**Proof Strategy**:
- **Approach A (Localization)**: Reduce to local rings R_p via primary decomposition of M. At each minimal prime, apply classical universal approximation over the residue field κ(p).
- **Approach B (Stone-Weierstrass)**: Show that compositions of R-linear maps and transcendental activations generate a dense subalgebra of C(K, M) for compact K ⊂ R^n.
- Key lemma needed: `transcendental_activation_localizes` — localization preserves the transcendence condition.

**Why Revolutionary**: First universal approximation theorem over arbitrary Noetherian rings. Opens algebraic deep learning.

**Catalog Leverage**: `relu_non_polynomial`, `non_polynomial_of_transcendental`, `deep_linear_collapse`

**Research Mode**: prove | Estimated Depth: 5

---

### 2. Tropical Neural Network = Tropical Rational Function (Characterization)

**Theorem Statement**: The set of functions computable by tropical neural networks (max-plus linear layers + tropical ReLU) equals exactly the set of tropical rational functions (differences of tropical polynomials).

**Proof Strategy**:
- Forward: By induction on depth, show each tropical layer preserves tropical rationality. Use `tropical_degree_one_is_relu` as the base case.
- Reverse: Show every tropical polynomial can be constructed as a tropical neural network by decomposing into max-of-affine pieces.
- Key lemma: `tropical_relu_generates_tropical_polynomial` — tropical ReLU plus affine maps generate all tropical polynomials.

**Why Revolutionary**: Exact algebraic characterization of tropical network expressivity. Enables certified collision-resistance for tropical hash functions.

**Catalog Leverage**: `tropical_degree_one_is_relu`, `tropical_relu_idempotent`, `max_of_affine_is_piecewise_linear`

**Research Mode**: prove | Estimated Depth: 4

---

### 3. Hilbert-Samuel Width Recovery

**Theorem Statement**: When R is a field K, the prime-spectral width bound recovers the classical bound: width = O(n · log(1/ε)), where n = dim_K(M).

**Proof Strategy**:
- MinSpec(K) = {(0)}, κ(0) = K, M ⊗ K ≅ M
- Hilbert-Samuel function of (0) ⊂ K is constant = 1
- Direct computation: total spectral width = n · 1 · ⌈log(1/ε)⌉

**Why Revolutionary**: Sanity check confirming algebraic generalization is correct. First formal verification of classical width bounds.

**Catalog Leverage**: `field_spectral_constant`, `field_finrank_fin`, `log_width_positive`

**Research Mode**: prove | Estimated Depth: 2

---

### 4. Compositional Lipschitz Tightness

**Theorem Statement**: The L^d Lipschitz bound for d-layer networks is tight: there exist networks achieving exactly L^d.

**Proof Strategy**:
- Construct explicit example: each layer is scalar multiplication by L
- Composition is multiplication by L^d, which is exactly L^d-Lipschitz
- Verify construction in Lean

**Why Revolutionary**: Shows L^d bound cannot be improved in general. Informs architectural choices for robust networks.

**Catalog Leverage**: `deep_lipschitz_bound`, `lipschitz_compose`

**Research Mode**: prove | Estimated Depth: 1

---

### 5. Sheaf-Theoretic Universal Approximation

**Theorem Statement**: The approximation bound is a global section of a constructible sheaf on Spec(R). The width function p ↦ dim_{κ(p)}(M ⊗ κ(p)) · H_R(p, ⌈log(1/ε)⌉) defines a section of a coherent sheaf.

**Proof Strategy**:
- Define the width sheaf on Spec(R) using the fiber dimension function
- Show constructibility using the upper semicontinuity of fiber dimension
- Prove the global section property using Noetherian descent

**Why Revolutionary**: Opens sheaf-theoretic machine learning, connecting to algebraic geometry and potentially quantum field theory.

**Catalog Leverage**: `spectral_width_monotone`, `field_spectral_constant`

**Research Mode**: formalize | Estimated Depth: 5

---

## Under-explored Territory

### Tropical Lipschitz Theory
Many definitions (TropicalNeuron, TropicalLayer, TropicalNetwork) but no deep theorems connecting tropical network depth to Lipschitz constants in the tropical metric. The `max_plus_order_preserving` theorem is a starting point, but full tropical Lipschitz bounds require developing the tropical metric theory.

### Non-Commutative Extensions
All current results assume commutativity of R. Extending to non-commutative rings (e.g., matrix algebras, quaternions) would connect to quantum neural networks and noncommutative geometry. The key obstacle is that primary decomposition fails in the non-commutative case.

### Computational Bounds vs. Existence
Most approximation results are existential. Constructive versions — computing the actual network weights for ε-approximation — would have direct algorithmic impact but require effective versions of Stone-Weierstrass and primary decomposition.

## Cross-Domain Bridges

### Algebra ↔ Cryptography
- **Tropical hash functions**: tropical neural networks as hash functions, with collision resistance bounded by tropical degree (from `tropical_degree_one_is_relu`)
- **Lattice-based security**: the spectral width lower bound gives minimum parameter counts, connecting to lattice problem hardness
- **Homomorphic evaluation**: can module neural networks evaluate under FHE?

### Analysis ↔ Combinatorics
- **Region counting**: the `linear_regions_bound` (w^d) connects network capacity to combinatorial complexity
- **Betti numbers**: tropical homology of the decision boundary encodes topological expressivity

### Module Theory ↔ Information Theory
- **Bottleneck theorems**: the `width_one_bottleneck` is the extreme case; general rank bounds give information-theoretic limits on compression through hidden layers
- **Channel capacity**: fiber dimensions at each prime give "algebraic channel capacities"

## Open Problems Encountered

1. **Effective Stone-Weierstrass over rings**: Does a constructive version of Stone-Weierstrass hold for module-valued functions over Noetherian rings? Requires developing effective approximation theory in Lean.

2. **Tropical Hilbert function bounds**: For a tropical polynomial of degree d in n variables, how many monomials are needed? This controls the approximation rate O(d · log(1/ε)).

3. **Activation design over finite fields**: What is the correct analogue of "non-polynomial" for activation functions over F_p? Every function F_p → F_p is polynomial (by Lagrange interpolation), so the classical condition is vacuous.

4. **Quantum module neural networks**: Define and study neural networks where R is a C*-algebra and modules are Hilbert modules. What replaces ReLU in the quantum setting?

5. **Primary decomposition ↔ network factorization**: Does the primary decomposition M = ⊕ M_p correspond to a factorization of the optimal network into independent sub-networks? This would give a structural explanation for modularity in trained networks.
