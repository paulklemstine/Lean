# Future Directions: Algebraic–EML Thermodynamic Formalism

## Breakthrough Opportunities (ranked by impact)

### 1. Variational Principle for Finite Closure Pressure

- **Theorem Statement**: For any finite type α with [Fintype α] [Nonempty α], inverse temperature β > 0, and potential φ : α → ℝ, the closure pressure equals the supremum over probability distributions μ of the entropy-plus-energy functional: `closurePressure β φ = sup_μ (closureEntropy μ + β * closureEnergy φ μ)`, where the supremum is over all normalized nonneg functions μ with ∑ μ = 1.
- **Proof Strategy**:
  1. Show the Gibbs state is a critical point of the entropy-plus-energy functional via Lagrange multipliers on the simplex.
  2. Use strict concavity of entropy (−∑ μ log μ is strictly concave) to show the Gibbs state is the unique maximizer.
  3. Evaluate the functional at the Gibbs state to recover log Z.
- **Why This Is Revolutionary**: Establishes the first formally verified variational principle for closure-based thermodynamic formalism, bridging information theory, statistical mechanics, and algebraic semantics in a single identity.
- **Catalog Leverage**: Build on `closurePressure_lower_energy`, `closureGibbsWeight_sum_one`, `closureEntropy`, `closureEnergy`.
- **Research Mode**: prove
- **Estimated Depth**: 4

### 2. Perron–Frobenius Theorem for Positive Closure Kernels

- **Theorem Statement**: For any `ClosureKernel α` with all entries strictly positive (∀ a b, 0 < K.step a b) and row-stochastic, there exists a unique invariant probability distribution μ with ∀ a, 0 < μ a, and for any initial distribution ν, the iterates K^n ν converge to μ.
- **Proof Strategy**:
  1. Formalize Birkhoff's contraction coefficient for stochastic matrices.
  2. Show the map ν ↦ K*ν is a contraction on the probability simplex under the Hilbert projective metric.
  3. Apply Banach fixed-point theorem (available in Mathlib).
- **Why This Is Revolutionary**: Extends our doubly-stochastic fixed-point result to arbitrary positive kernels, enabling non-uniform Gibbs state construction at any temperature.
- **Catalog Leverage**: Build on `IsClosureInvariant`, `ClosureKernel`, `closureGibbs_fixed_point_uniform_of_zero_potential`.
- **Research Mode**: formalize
- **Estimated Depth**: 5

### 3. Tropical Free Energy and Min-Plus Entropy

- **Theorem Statement**: Define tropical closure pressure as `tropicalPressure β φ = max_a (β * φ a)` (the β → ∞ limit). Prove that `lim_{β→∞} closurePressure β φ / β = max_a φ a` and that the Gibbs state concentrates on the maximizer(s) of φ.
- **Proof Strategy**:
  1. Show log(∑ exp(β * φ a)) / β → max φ a as β → ∞ using squeeze theorem.
  2. Upper bound: log(n * exp(β * max φ)) / β = max φ + log(n)/β → max φ.
  3. Lower bound: log(exp(β * max φ)) / β = max φ.
- **Why This Is Revolutionary**: Creates a formal bridge between thermodynamic formalism and tropical geometry, connecting Gibbs states to tropical varieties and min-plus algebra.
- **Catalog Leverage**: Build on `closurePressure`, `exists_closurePressure_upper_witness`, `closurePressure_lower_energy`.
- **Research Mode**: formalize
- **Estimated Depth**: 3

### 4. Cryptographic Channel Capacity via Closure Pressure

- **Theorem Statement**: For a closure kernel K interpreted as a noisy channel, define channel capacity C(K) = max_μ I(μ; K) where I is mutual information. Prove that C(K) ≤ log(card α) and that equality holds iff K is a permutation matrix.
- **Proof Strategy**:
  1. Express mutual information as H(output) - H(output|input).
  2. Use the entropy upper bound closureEntropyUpperBound.
  3. Characterize equality case via strict concavity.
- **Why This Is Revolutionary**: Provides formally verified cryptographic capacity bounds derived from the closure-thermodynamic framework, directly applicable to post-quantum security analysis.
- **Catalog Leverage**: Build on `closureEntropy`, `closureEntropyUpperBound`, `ClosureKernel`, `IsRowStochastic`.
- **Research Mode**: formalize
- **Estimated Depth**: 4

### 5. Detailed Balance and Reversible Closure Dynamics

- **Theorem Statement**: For a closure kernel K and potential φ, define detailed balance as: ∀ a b, μ a * K.step a b = μ b * K.step b a. Prove that if K satisfies detailed balance w.r.t. the Gibbs state at inverse temperature β, then the Gibbs state is invariant.
- **Proof Strategy**:
  1. Sum detailed balance over a to show invariance.
  2. Show that detailed balance implies row-stochasticity iff column-stochasticity.
  3. Connect to the existing doubly-stochastic result as a special case.
- **Why This Is Revolutionary**: Formalizes the physical principle of microscopic reversibility in the closure-algebraic setting, enabling equilibrium thermodynamics for non-symmetric kernels.
- **Catalog Leverage**: Build on `IsClosureInvariant`, `closureGibbsState`, `algebraicEML_closurePressure_gibbsFixedPoint`.
- **Research Mode**: prove
- **Estimated Depth**: 3

## Under-explored Territory

- **Closure pressure on infinite closure systems**: Extend from Fintype to countable or continuous state spaces using measure-theoretic Gibbs states.
- **Non-commutative closure pressure**: Replace the abelian sum with a trace over operator algebras, connecting to quantum statistical mechanics.
- **Closure pressure and computational complexity**: Interpret closure pressure as a partition function and connect its computational hardness to #P-completeness.

## Cross-Domain Bridges

- **Thermodynamics ↔ Algebraic Geometry**: Closure pressure on algebraic varieties as a Weil-height analog.
- **ML Robustness ↔ Cryptography**: Pressure Lipschitz bounds as both certified adversarial robustness radii and channel distinguishability bounds.
- **Tropical Geometry ↔ Statistical Physics**: Zero-temperature limit of closure pressure as tropical optimization.

## Open Problems Encountered

1. Can the Lipschitz constant |β| be improved for specific classes of closure potentials (e.g., submodular)?
2. Does the pressure functional on FiniteClosureSystem satisfy a chain rule under composition of closure operators?
3. Is there a natural Riemannian metric on the space of Gibbs states that makes the pressure a Kähler potential?
