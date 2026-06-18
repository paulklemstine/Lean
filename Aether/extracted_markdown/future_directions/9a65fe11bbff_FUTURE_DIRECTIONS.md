# Future Directions: Galois-Theoretic Deep Learning

## Breakthrough Opportunities (ranked by impact)

### 1. Tropical Galois-Neural Theory for ReLU Networks

- **Theorem Statement**: For a ReLU neural network f : ℝⁿ → ℝᵐ, the piecewise-linear structure defines a tropical polynomial in the min-plus semiring (ℝ ∪ {∞}, min, +). The number of linear regions of f is bounded by ∏ᵢ C(wᵢ, wᵢ₋₁) where wᵢ are layer widths.
- **Proof Strategy**:
  1. Formalize tropical polynomials as elements of `Tropical ℝ`
  2. Show that ReLU(x) = max(0, x) corresponds to tropical addition
  3. Prove the linear region count bound by induction on depth
- **Why This Is Revolutionary**: Extends our polynomial theory to the most widely-used activation function (ReLU), connecting tropical geometry to practical neural networks.
- **Catalog Leverage**: Build on `GaloisNeural.polynomial_growth_bernoulli`, `GaloisNeural.exponential_depth_degree`, existing Tropical catalog files
- **Research Mode**: prove
- **Estimated Depth**: 4

### 2. Galois Group Classification of Network Decomposability

- **Theorem Statement**: A polynomial neural network f : k^n → k^m is indecomposable (cannot be factored through any narrower intermediate layer) if and only if the automorphism group Aut(k(X)/k(f(X))) is a simple group.
- **Proof Strategy**:
  1. Formalize Aut(k(X)/k(f(X))) as the automorphism group of the fraction field extension
  2. Show that normal subgroups correspond to intermediate fields (fundamental theorem of Galois theory)
  3. Show that intermediate fields correspond to network factorizations
  4. Conclude: no proper normal subgroups ↔ no proper factorizations
- **Why This Is Revolutionary**: Provides a purely group-theoretic criterion for network minimality, enabling provably optimal architecture search.
- **Catalog Leverage**: Build on `GaloisNeural.featureSubring`, `GaloisNeural.composed_feature_containment`
- **Research Mode**: prove
- **Estimated Depth**: 5

### 3. Certified Robustness via Spectral Gap

- **Theorem Statement**: For a polynomial neural network f with Galois group G, the certified robustness radius on G-orbits is at least δ · |G| / (2L) where L is the Lipschitz constant and δ is the classification margin.
- **Proof Strategy**:
  1. Use orbit-stabilizer theorem: |Orb(x)| · |Stab(x)| = |G|
  2. Show feature map factors through orbit quotient
  3. Bound Lipschitz constant on quotient by L/|G|
  4. Derive robustness radius from Lipschitz bound
- **Why This Is Revolutionary**: Gives O(|G|) improvement in certified robustness for equivariant networks, with explicit Lipschitz constants.
- **Catalog Leverage**: Build on `GaloisNeural.symmetry_lipschitz_improvement`, `GaloisNeural.robustness_radius_positive`
- **Research Mode**: prove
- **Estimated Depth**: 3

### 4. Transcendence Degree as Expressivity Measure

- **Theorem Statement**: For a polynomial feature map f : k^n → k^m, the transcendence degree trdeg(k(f₁,...,fₘ)/k) equals the dimension of the Zariski closure of im(f), and is bounded by min(n, m).
- **Proof Strategy**:
  1. Formalize the transcendence degree of a finitely generated field extension
  2. Show trdeg = Krull dimension of k[f₁,...,fₘ]
  3. Prove trdeg ≤ min(n, m) by embedding arguments
  4. Show equality for generic weights via Jacobian rank theorem
- **Why This Is Revolutionary**: Gives a strictly finer expressivity measure than VC-dimension for polynomial activations.
- **Catalog Leverage**: Build on `GaloisNeural.matrix_expressivity_le_min`, `GaloisNeural.bottleneck_security_tradeoff`
- **Research Mode**: prove
- **Estimated Depth**: 5

### 5. Wreath Product Structure of Deep Network Symmetries

- **Theorem Statement**: For an L-layer polynomial network, the Galois group Gal(k(X)/k(f(X))) embeds into an iterated wreath product of the individual layer Galois groups.
- **Proof Strategy**:
  1. Apply the composition decomposition theorem iteratively
  2. Show each layer's Galois group acts on the next by conjugation
  3. Construct the wreath product embedding by induction on depth
  4. Prove the embedding is injective using separability
- **Why This Is Revolutionary**: Decomposes the symmetry structure of deep networks, enabling O(L·log|G|) symmetry verification.
- **Catalog Leverage**: Build on `GaloisNeural.linear_bottleneck_three_layer`, `GaloisNeural.composition_preserves_invariance`
- **Research Mode**: prove
- **Estimated Depth**: 5

## Under-explored Territory

### Polynomial Ideal Theory for Neural Networks
The feature subring we defined generates an ideal in k[X₁,...,Xₙ]. The Hilbert function of this ideal gives a finer expressivity measure than degree alone. Connection to Hilbert basis theorem could give finitary representations of infinite-width limits.

### Differential Galois Theory for Gradient Descent
The gradient flow of a neural network defines a differential equation. The differential Galois group of this equation captures the symmetries of the training dynamics. This could explain why certain architectures train faster than others.

### Algebraic K-Theory for Network Equivalences
Two networks are equivalent if they compute the same function. The K-theory of the category of polynomial neural networks could classify equivalences and provide obstructions to network compression.

## Cross-Domain Bridges

### Algebra → Cryptography
- Feature subring structure determines lattice attack complexity
- Polynomial bottleneck width gives Ω(d^w) security
- Simple Galois groups resist layerwise cryptanalysis

### Algebra → Machine Learning
- Rank bounds give information bottleneck bounds
- Degree bounds give Lipschitz constants
- Group invariance gives certified robustness

### Algebra → Physics
- Rank-nullity = information conservation (thermodynamics)
- Galois groups = symmetry groups (gauge theory)
- Feature fields = field extensions (quantum field theory)

## Open Problems Encountered

1. **Transcendence degree computation**: Mathlib lacks a computable transcendence degree for finitely generated extensions of infinite fields. Building this infrastructure would unlock the full expressivity bound theorem.

2. **Fraction field automorphisms**: The Galois group Aut(K/F) for K = k(X₁,...,Xₙ) and F = k(f₁,...,fₘ) requires formalizing automorphisms of fraction rings of multivariate polynomial rings, which is not directly available in Mathlib.

3. **Wreath product decomposition**: The iterated wreath product construction for deep networks requires careful universe management in Lean 4, as each layer's type lives in a different universe.

4. **Generic weights via Zariski topology**: Formalizing "for generic weights" requires Zariski topology on parameter spaces, which is partially available in Mathlib but not specialized to our setting.

5. **Differential privacy from orbits**: The conjecture that G-orbit structure provides ε-differential privacy with ε = log|G| requires connecting algebraic group theory to probability theory, which is a significant formalization challenge.
