# Harmonic Network Research Team: Perpetual Discovery Engine

## Mission

To systematically expand the mathematical and empirical frontiers of integer-parameterized neural architectures through formal verification, experimental validation, and iterative hypothesis refinement.

---

## Team Structure

### Team Alpha — Algebraic Foundations (Lead: Algebraist)

**Role**: Discover and formally verify new algebraic identities and structural properties.

**Current Hypotheses**:

1. **H-A1: Higher Composition Identities.** The Degen eight-square identity (octonion norm) provides composition closure for 8D Harmonic Networks. *Status: Ready for formalization.*

2. **H-A2: Pfister Forms.** The sum-of-2ⁿ-squares property (Pfister's theorem) generalizes composition closure to power-of-2 dimensions. Harmonic Networks in dimensions 1, 2, 4, 8 have fundamentally different algebraic structure from other dimensions. *Status: Hypothesis stage.*

3. **H-A3: Modular Arithmetic Projection.** The stereographic projection can be computed modulo a prime p, yielding points on curves over 𝔽_p. This connects Harmonic Networks to elliptic curve cryptography. *Status: Exploring.*

4. **H-A4: Matrix Factorization via Gaussian Integers.** The Brahmagupta-Fibonacci identity is secretly the norm multiplicativity of ℤ[i]. Harmonic Network weight composition should be expressible as Gaussian integer multiplication, providing a fast composition algorithm. *Status: High priority.*

**Experiments**:
- Formalize Euler's 4-square identity in Lean (✅ DONE: `euler_four_square`)
- Formalize and prove the Degen 8-square identity
- Investigate whether composition closure fails in dimensions ≠ 1, 2, 4, 8
- Formalize the connection between stereographic projection and Gaussian integers

---

### Team Beta — Approximation Theory (Lead: Analyst)

**Role**: Quantify and optimize the approximation error of integer-parameterized networks.

**Current Hypotheses**:

1. **H-B1: Optimal Approximation Rate.** The quantization error of the snap operation decreases as O(1/N²) in the L² sense over the sphere, not just O(1/N) pointwise. *Status: Partially verified (Lipschitz bound proved, need sphere integration).*

2. **H-B2: Equidistribution.** Integer-parameterized rational points become equidistributed on Sⁿ⁻¹ as the integer bound grows. This implies the Harmonic Network can approximate any continuous function uniformly. *Status: Hypothesis stage. Needs Weyl equidistribution theory.*

3. **H-B3: Optimal Integer Selection.** For a given integer bound B, the optimal snap target is NOT the nearest integer to the inverse projection — there exist smarter selection algorithms using lattice reduction (LLL algorithm). *Status: Ready for experimentation.*

4. **H-B4: Adaptive Resolution.** Different layers of the network need different integer precision. Early layers (feature extraction) need high precision; later layers (classification) tolerate coarser approximation. *Status: Ready for experimentation.*

**Experiments**:
- Prove the O(1/N²) L² approximation rate (extend `rational_approx_error`)
- Implement LLL-based snap and compare accuracy to naive round-based snap
- Profile per-layer quantization sensitivity on MNIST and CIFAR-10
- Prove equidistribution of Pythagorean points on S¹ using Weyl's criterion

---

### Team Gamma — Architecture Engineering (Lead: ML Engineer)

**Role**: Design, train, and benchmark Harmonic Network architectures at scale.

**Current Hypotheses**:

1. **H-G1: Depth Over Width.** Harmonic Networks benefit more from depth than width because each layer adds exactly one rotation in the weight space. Deep narrow networks should outperform shallow wide ones. *Status: Ready for experimentation.*

2. **H-G2: Structured Initialization.** Initializing integer parameters as Berggren tree elements (generating Pythagorean triples systematically) gives better starting points than random integers. *Status: Hypothesis stage.*

3. **H-G3: Batch Normalization Compatibility.** Batch normalization with rational running statistics preserves the exact-arithmetic property. *Status: Needs investigation.*

4. **H-G4: Convolutional Harmonic Networks.** The projection can be applied column-wise to convolutional filter tensors, yielding exact-rational CNNs. *Status: High priority for scale-up.*

5. **H-G5: Attention Mechanism.** Self-attention with Harmonic Network query/key/value projections preserves rationality. The softmax needs rational approximation. *Status: Exploring.*

**Experiments**:
- Scale to CIFAR-10, CIFAR-100, ImageNet-subset
- Implement Harmonic Convolutional layers
- Compare random vs. Berggren-initialized parameters
- Profile depth-vs-width tradeoffs on benchmark tasks
- Investigate integer-arithmetic-only inference on microcontrollers (edge AI)

---

### Team Delta — Formal Verification (Lead: Proof Engineer)

**Role**: Extend the Lean formalization to cover new results as they emerge.

**Current Status** (✅ = proved, 🔬 = in progress):
- ✅ Pythagorean identity (2D)
- ✅ Generalized N-dimensional identity
- ✅ Unit norm in division form
- ✅ Surjectivity of stereographic parameterization
- ✅ Lipschitz continuity (both components)
- ✅ Projection boundedness
- ✅ Scale invariance
- ✅ Brahmagupta-Fibonacci identity
- ✅ Euler four-square identity
- ✅ ReLU rationality preservation
- ✅ Quantization error bound
- ✅ Sum of squares characterization
- ✅ Closure under complex multiplication
- ✅ Projection numerator identity (List and Fin n)
- 🔬 Degen eight-square identity
- 🔬 Equidistribution on S¹
- 🔬 Density of rational points on Sⁿ⁻¹
- 🔬 Gaussian integer factorization of projections
- 🔬 Universal approximation for rational networks

**Experiments**:
- Prove every new result from Teams Alpha, Beta, Gamma
- Maintain zero-sorry invariant across all files
- Verify only standard axioms are used
- Create comprehensive #print axioms audit

---

### Team Epsilon — Applications (Lead: Applied Scientist)

**Role**: Identify and develop real-world applications of exact-rational neural networks.

**Current Hypotheses**:

1. **H-E1: Verifiable AI for Safety-Critical Systems.** Harmonic Networks can produce formally certifiable predictions for autonomous vehicles, medical devices, and aerospace. The exact rationality enables symbolic verification of input-output properties. *Status: High potential.*

2. **H-E2: Deterministic Federated Learning.** Since Harmonic Networks use integer parameters, federated learning can exchange exact integers instead of lossy float gradients, eliminating aggregation drift. *Status: Ready for experimentation.*

3. **H-E3: Quantum-Compatible Weights.** Integer parameters can be directly encoded into quantum circuits using the Berggren-quantum gate synthesis framework (see `QuantumGateSynthesis.lean`). *Status: Connects to existing project work.*

4. **H-E4: Compressed Model Storage.** Integer parameters compress far better than float weights (entropy coding on integers vs. IEEE 754). Expected 4-8× model size reduction. *Status: Ready for experimentation.*

5. **H-E5: Homomorphic Encryption.** Exact rational weights enable meaningful computation on encrypted data using rational HE schemes. *Status: Exploring.*

**Experiments**:
- Benchmark inference latency with integer-only arithmetic vs. float32
- Implement federated Harmonic Network training
- Measure compression ratios vs. standard model formats
- Prototype a safety certification pipeline for a simple control task
- Explore compatibility with lattice-based HE schemes

---

## Iterative Research Protocol

### The Hypothesis-Experiment-Update Cycle

```
┌─────────────────────────────────────────────────┐
│                                                 │
│   1. HYPOTHESIZE                                │
│      Generate mathematical conjectures          │
│      from patterns in proved results            │
│                                                 │
│   2. FORMALIZE                                  │
│      State the conjecture in Lean 4             │
│      with sorry placeholder                     │
│                                                 │
│   3. EXPERIMENT                                 │
│      a) Try formal proof (subagent)             │
│      b) Test computationally (#eval)            │
│      c) Run ML experiments (Python)             │
│                                                 │
│   4. UPDATE                                     │
│      If proved: add to verified corpus          │
│      If disproved: refine hypothesis            │
│      If inconclusive: decompose further         │
│                                                 │
│   5. PROPAGATE                                  │
│      Share results across teams                 │
│      Generate new hypotheses from proved        │
│      results                                    │
│                                                 │
│   6. ITERATE (goto 1)                           │
│                                                 │
└─────────────────────────────────────────────────┘
```

### Priority Queue (Next 10 Research Actions)

| Priority | Team | Action | Expected Outcome |
|----------|------|--------|------------------|
| 1 | Delta | Prove Degen 8-square identity | Extend composition to 8D |
| 2 | Gamma | Implement Harmonic CNN | Scale to image classification |
| 3 | Beta | Prove O(1/N²) L² approximation | Sharper error bounds |
| 4 | Alpha | Formalize Gaussian integer connection | Fast composition algorithm |
| 5 | Epsilon | Integer-only inference benchmark | Quantify speed advantage |
| 6 | Gamma | CIFAR-10 experiments | Validate at larger scale |
| 7 | Beta | Implement LLL-based snap | Better integer selection |
| 8 | Alpha | Investigate non-2ⁿ dimensions | Map algebraic landscape |
| 9 | Delta | Prove density on Sⁿ⁻¹ | Universal approximation |
| 10 | Epsilon | Federated learning prototype | Exact aggregation |

### Convergence Criteria

A research direction is considered "mature" when:
1. The core mathematical claim is formally verified in Lean (zero sorry)
2. Computational experiments confirm the claim empirically
3. At least one real-world application is demonstrated
4. The result generates ≥ 2 new research hypotheses

### Divergence Triggers

Pivot to a new direction when:
1. A formal disproof is found (the subagent proves the negation)
2. Experiments consistently fail to reproduce theoretical predictions
3. The conjecture remains open after 5 decomposition attempts
4. A fundamentally better approach is discovered

---

## Knowledge Base (Living Document)

### Verified Facts (Lean-proved)
- Stereographic projection of any non-zero integer vector has exactly unit norm
- The parameterization covers all rational points on S¹ except (0, -1)
- Quantization error ≤ 1/N for parameter bound N
- Both projection components have Lipschitz constant ≤ 2
- Composition of unit projections preserves unit norm
- ReLU preserves rationality of all intermediate values

### Open Questions
1. What is the exact density of integer-parameterized rational points on S^(n-1) for n > 2?
2. Can the snap operation be made equivariant under permutation of coordinates?
3. Is there a gradient-free training algorithm that operates directly on integer parameters?
4. What is the minimum integer bound B needed to achieve ε-approximation of a given continuous weight matrix?
5. Can Harmonic Networks represent any piecewise-linear function exactly?
6. What is the VC dimension of a Harmonic Network with integer bound B?
7. Do Harmonic Networks have implicit regularization properties from the rational constraint?

### Connections to Other Fields
- **Number Theory**: Pythagorean triples, sums of squares, Gaussian integers, quadratic forms
- **Algebraic Geometry**: Rational points on varieties, stereographic projection, birational geometry
- **Quantum Computing**: Exact gate synthesis from integer parameters
- **Cryptography**: Elliptic curves, lattice problems, homomorphic encryption
- **Coding Theory**: Error-correcting codes from integer lattices
- **Dynamical Systems**: Integer-parameterized discrete rotations

---

*This document is a living research agenda. It should be updated after every significant result.*
*Last updated: Generated from formal verification of 35+ theorems in Lean 4.*
