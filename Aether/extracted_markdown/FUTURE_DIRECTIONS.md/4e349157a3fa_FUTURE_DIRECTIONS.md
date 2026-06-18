# Future Directions: Entropic Spectral Transport

## Breakthrough Opportunities (ranked by impact)

### 1. Extension from Finite Spectra to Compact Spectral Spaces

**Theorem Statement**: For a coherent closure proof semiring with compact Hausdorff prime spectrum, the entropic transport gap characterization extends to measure-theoretic marginals, with convergence of finite approximations.

**Proof Strategy**:
- Define `CompactSpectralTransport S` using `MeasureTheory.Measure` on `SpectralPoint S`
- Prove that finite-dimensional projections preserve the gap ↔ derivability equivalence
- Use Prokhorov's theorem for tightness and weak convergence of coupling measures
- Key lemma: finite spectral approximations converge in Wasserstein distance

**Why This Is Revolutionary**: Enables application to infinitary proof systems (e.g., infinitary logic, continuous model theory). Opens connections to geometric measure theory and Monge-Ampère equations on spectral varieties.

**Catalog Leverage**: Build on `ThermodynamicSanovCompleteness` (spectral completeness infrastructure), extend `IsSinkhornBalanced` to measure-theoretic setting.

**Research Mode**: formalize
**Estimated Depth**: 5

---

### 2. Tropical/Large-Deviation Degeneration of the Entropic Gap

**Theorem Statement**: As $\varepsilon \to 0^+$ with $\beta$ fixed, the entropic transport gap $T_{\varepsilon, \beta}(x, y)$ converges to the unregularized optimal transport cost, with rate $O(\varepsilon \log(1/\varepsilon))$.

**Proof Strategy**:
- Define `tropicalTransportGap β x y := sInf {∑ c(p,q) * π(p,q) | π has marginals a, b}`
- Prove Γ-convergence of the entropic functional to the linear program
- Key lemma: the Gibbs kernel concentrates on minimizers as ε → 0
- Use existing tropical semiring infrastructure for the limit object

**Why This Is Revolutionary**: Connects entropic OT to tropical geometry, providing a deformation-theoretic view of proof-theoretic separation. The tropical limit gives combinatorial certificates (matching, flow) that are algorithmically simpler.

**Catalog Leverage**: Tropical semiring definitions, `spectralGibbsKernel_pos`

**Research Mode**: formalize
**Estimated Depth**: 4

---

### 3. Certified Robustness for Differentiable Theorem Provers

**Theorem Statement**: For a differentiable theorem prover with Lipschitz-bounded gradient, the transport gap provides a certified radius $r > 0$ such that all proof attempts within distance $r$ of a non-derivable pair are also non-derivable.

**Proof Strategy**:
- Define `DifferentiableProver S` with Lipschitz bounds on the proof map
- Prove that `lipschitzCertifiedRobustnessScore L ε β x y > 0` implies stability
- Key lemma: the transport gap is Lipschitz in the cost metric
- Connect to neural network verification via the Lipschitz constant bound

**Why This Is Revolutionary**: First formal connection between entropic transport certificates and neural theorem prover robustness. Could lead to provably robust AI systems for mathematical reasoning.

**Catalog Leverage**: `lipschitz_certified_robustness_from_gap`, `certifiedSeparationRadius`

**Research Mode**: formalize
**Estimated Depth**: 3

---

### 4. Post-Quantum/Lattice Analogue of Spectral Transport Certificates

**Theorem Statement**: For lattice-based proof systems where the spectral points form a lattice in $\mathbb{Z}^n$, the transport gap provides a reduction from non-derivability to a lattice shortest vector problem, with the gap lower-bounded by the lattice minimum distance.

**Proof Strategy**:
- Define `LatticeSpectralPoint S` embedding spectral points into $\mathbb{Z}^n$
- Prove that the Gibbs kernel on lattice points concentrates on short vectors
- Key lemma: `transportGap ε β x y ≥ ε * β * exp(-β * λ₁(L))` where λ₁ is the shortest vector
- Use the Gaussian heuristic for lattice point counting

**Why This Is Revolutionary**: Creates a formal bridge between lattice cryptography and proof-theoretic separation, potentially enabling new worst-case to average-case reductions.

**Catalog Leverage**: `postQuantumSpectralAdvantage`, lattice crypto infrastructure

**Research Mode**: formalize
**Estimated Depth**: 4

---

### 5. Donsker–Varadhan Dual Characterization of the Transport Gap

**Theorem Statement**: The transport gap admits a dual variational characterization:
$$T_{\varepsilon, \beta}(x, y) = \sup_{f, g} \left\{ \sum_p f(p) a(p) + \sum_q g(q) b(q) - \varepsilon \sum_{p,q} \mu(p) \mu(q) \exp\left(\frac{f(p) + g(q) - \beta c(p,q)}{\varepsilon}\right) \right\}$$

**Proof Strategy**:
- Define the dual functional on pairs of potentials
- Prove weak duality (dual ≤ primal) via Jensen's inequality
- Prove strong duality via the Sinkhorn factorization (the balanced potentials achieve equality)
- Key lemma: the Sinkhorn potentials $(\log u, \log v)$ are the dual optimizers

**Why This Is Revolutionary**: Connects the Donsker-Varadhan variational principle from large deviations to proof-theoretic separation, enabling importance-sampling algorithms for non-derivability detection.

**Catalog Leverage**: `sinkhorn_row_update_exact`, `gauge_uniqueness_from_equal_coupling`, `balanced_pair_total_mass_agreement`

**Research Mode**: formalize
**Estimated Depth**: 5

---

## Under-explored Territory

### Definitions with Few Deep Theorems
- **`entropicObjective`**: Defined but no optimization theorems proved about it yet. The strict convexity of KL divergence should yield existence/uniqueness of the optimizer.
- **`sinkhornIterationBound`**: Defined but the complexity bound theorem is currently stated conditionally. Proving the geometric rate for specific kernel classes would make this unconditional.
- **`kernelProjectiveDiameter`** (from the problem statement, not yet formalized): The Birkhoff-Hopf contraction coefficient for positive kernels, which gives the optimal convergence rate.

### Structural Similarities
- The gauge invariance of Sinkhorn scaling mirrors the gauge invariance of Yang-Mills theory. Both can be formalized via principal bundles with structure group $\mathbb{R}_{>0}$.
- The convergence of Sinkhorn iterates mirrors the convergence of Picard iteration for ODEs. Both are contraction mapping arguments in complete metric spaces.

---

## Cross-Domain Bridges

### Proof Theory ↔ Statistical Mechanics
- **Conjecture**: The partition function $Z(\beta) = \sum_{p,q} K(p,q) \mu(p) \mu(q)$ of the spectral Gibbs kernel satisfies a Lee-Yang type theorem: its zeros in the complex $\beta$-plane avoid the positive real axis.
- **Implication**: Phase transitions in derivability detection correspond to zeros of $Z(\beta)$.

### Optimal Transport ↔ Quantum Information
- **Conjecture**: The spectral coupling $\pi^*$ can be lifted to a quantum channel between spectral Hilbert spaces, with the transport gap bounding the diamond-norm distance between derivable and non-derivable channels.

### Sinkhorn Scaling ↔ Neural Network Training
- **Conjecture**: Sinkhorn-normalized attention layers (already used in practice) implement a form of spectral coupling matching, with the transport gap providing a convergence certificate.

---

## Open Problems Encountered

1. **Full Sinkhorn existence/uniqueness**: The existence of a balanced pair $(u, v)$ for arbitrary positive kernels and probability marginals requires a fixed-point argument or convex optimization. This is a standard result but has not been formalized in Mathlib.

2. **Optimal contraction rate**: The Birkhoff-Hopf theorem gives the optimal geometric rate $\rho = \tanh(\Delta/4)$ where $\Delta$ is the projective diameter of $K$. Formalizing this requires the Hilbert projective metric, which is not in Mathlib.

3. **Complexity lower bounds**: Is there a proof system where the transport gap computation is NP-hard? This would connect the framework to computational complexity theory.

4. **Infinite-dimensional extension**: Extending the Sinkhorn factorization to continuous spectral spaces requires Fenchel-Rockafellar duality in infinite dimensions, which is partially available in Mathlib but not in the form needed.

5. **Connections to PAC-Bayes**: The `pac_bayes_prime_spectral_bound_of_mgf` theorem from the catalog suggests a connection between PAC-Bayes bounds and transport gap bounds. Making this precise could yield new generalization bounds for learning algorithms.
