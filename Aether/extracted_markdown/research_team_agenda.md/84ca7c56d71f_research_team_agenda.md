# Harmonic Network Research Team: Frontier Expansion Program

## Mission

Expand the mathematical and practical frontiers of integer-parameterized neural networks through a continuous cycle of **hypothesis → experiment → update → iterate**.

---

## Team Structure

### Principal Investigators

1. **Number Theory Lead** — Investigates deeper connections between integer lattices, quadratic forms, and network expressivity
2. **Optimization & Learning Theory Lead** — Studies convergence guarantees for QAT training and snap operations
3. **Formal Verification Lead** — Extends the Lean 4 formalization to cover new results
4. **Systems & Hardware Lead** — Implements exact rational arithmetic accelerators
5. **Applications Lead** — Tests Harmonic Networks on frontier AI tasks (LLMs, vision, robotics)

### Research Scientists

- 2 postdocs in algebraic number theory / arithmetic geometry
- 2 postdocs in optimization theory / deep learning theory
- 1 postdoc in formal methods / interactive theorem proving
- 2 PhD students in ML systems / hardware design
- 2 PhD students in applied ML / computer vision / NLP

---

## Research Agenda: Hypotheses, Experiments, and Iterations

### Stream 1: Higher-Dimensional Projection Theory

**Hypothesis 1.1**: The stereographic projection from ℤᴺ to Sᴺ⁻¹ achieves ε-density with integer bound O(1/ε^{N-1}), matching the theoretical minimum.

**Experiment**: 
- Computationally enumerate all integer vectors with ‖m‖∞ ≤ B for B = 1,...,100 in dimensions N = 3,4,8,16
- Measure the maximum gap (Hausdorff distance) between projected points and Sᴺ⁻¹
- Compare to random float vectors of the same cardinality

**Update Protocol**: If density is suboptimal, investigate alternative integer-to-sphere maps (e.g., Cayley transform, higher-order rational parameterizations).

---

**Hypothesis 1.2**: In dimension N=4, the projection relates to quaternion arithmetic, enabling structured rotation representations.

**Experiment**:
- Formalize the quaternion interpretation: (a,b,c,d) → unit quaternion via 4D stereographic projection
- Verify that quaternion multiplication of two projected vectors equals the projection of the "Cayley product" of their integer seeds
- Test on 3D rotation prediction tasks

**Update Protocol**: If the quaternion structure holds, extend to octonions (N=8) and Clifford algebras.

---

### Stream 2: Training Dynamics & Convergence

**Hypothesis 2.1**: QAT with periodic snaps converges at the same rate as unconstrained SGD up to a constant factor.

**Experiment**:
- Prove a convergence theorem: if the continuous loss landscape is L-smooth and μ-strongly convex, QAT with snap period T converges at rate O(exp(-μT/L))
- Empirically measure convergence curves on CIFAR-10, ImageNet subsets
- Formally verify the convergence bound in Lean 4

**Update Protocol**: If convergence is slower, investigate adaptive snap schedules (snap more frequently as training progresses).

---

**Hypothesis 2.2**: The "snap" operation acts as implicit regularization, improving generalization.

**Experiment**:
- Compare test accuracy of Harmonic Networks vs. float networks with explicit L2 regularization matched to produce the same training loss
- Measure weight matrix condition numbers before and after snap
- Analyze the spectral distribution of snapped weight matrices

**Update Protocol**: If regularization effect is confirmed, quantify the effective regularization strength as a function of max_int parameter.

---

### Stream 3: Formal Verification Expansion

**Hypothesis 3.1**: The N-dimensional unit norm property can be formalized for vectors (using Fin n → ℤ) rather than lists, enabling cleaner Mathlib integration.

**Experiment**:
- Define `stereoProjectN : (Fin n → ℤ) → ℤ → (Fin n → ℚ) × ℚ` using the projection formula
- Prove `‖stereoProjectN m t‖² = 1` using `Finset.sum` and the generalized identity
- Integrate with Mathlib's `EuclideanDomain`, `InnerProductSpace`, and `UnitSphere` APIs

**Update Protocol**: Submit the formalization to Mathlib as a new file in `Mathlib.Analysis.InnerProductSpace.Projection`.

---

**Hypothesis 3.2**: The density result (rational points dense on Sⁿ⁻¹) can be formally proved using Mathlib's topology.

**Experiment**:
- State: `Dense (Set.range (fun m : Fin n → ℤ × ℤ => stereoProject m)) (Metric.sphere 0 1)`
- Prove using `Rat.isDenseEmbedding_coe_real` and continuity of stereographic projection
- Formalize the quantization error bound: ∀ ε > 0, ∃ m with ‖m‖∞ ≤ C/ε, ‖w - proj(m)‖ < ε

**Update Protocol**: If Mathlib lacks required sphere topology, build it from scratch and contribute upstream.

---

### Stream 4: Hardware & Systems

**Hypothesis 4.1**: Harmonic Network inference on integer-only hardware (no FPU) achieves 10× energy efficiency over float16 inference.

**Experiment**:
- Implement the projection computation on an FPGA using only integer multipliers and dividers
- Measure energy per inference on MNIST, CIFAR-10
- Compare to float16 inference on the same FPGA

**Update Protocol**: If division is the bottleneck, explore division-free approximations or lookup tables for the projection.

---

**Hypothesis 4.2**: Storing integer seeds instead of float weights achieves 4-8× compression with no accuracy loss.

**Experiment**:
- For a trained Harmonic Network, compare storage: |M| integers vs |W| float32 values
- Measure bits-per-parameter for various max_int values
- Test variable-length encoding of the integer matrices (entropy coding)

**Update Protocol**: Combine with knowledge distillation to minimize max_int while maintaining accuracy.

---

### Stream 5: Frontier Applications

**Hypothesis 5.1**: Harmonic Networks enable formally verifiable neural network inference — a proof that the network's output satisfies a specification.

**Experiment**:
- Train a Harmonic Network classifier on a safety-critical task (e.g., obstacle detection)
- Since all weights are rational, the entire forward pass is a rational function
- Formalize the forward pass in Lean 4 and prove properties (e.g., "input in safe region → output class = safe")

**Update Protocol**: If verification is tractable for small networks, scale to larger models with compositional verification.

---

**Hypothesis 5.2**: The Pythagorean structure enables novel weight-sharing schemes inspired by number-theoretic symmetries.

**Experiment**:
- Use the Berggren tree structure to generate families of related integer vectors
- Share integer parameters across network layers using group-theoretic symmetries of the lattice
- Test parameter efficiency on large-scale tasks

**Update Protocol**: Explore connections to modular forms, automorphic representations, and the Langlands program for deeper structural constraints.

---

**Hypothesis 5.3**: Harmonic Networks scale to transformer architectures for language modeling.

**Experiment**:
- Replace attention weight matrices (Q, K, V, O) with Pythagorean-projected integer matrices
- Train on WikiText-103 and measure perplexity vs. float baseline
- Analyze attention patterns: do integer-constrained attention heads learn interpretable patterns?

**Update Protocol**: If attention is too constrained, allow mixed precision (integer projections for FFN layers, float for attention).

---

### Stream 6: Theoretical Depth

**Hypothesis 6.1**: The Harmonic Network weight space has a natural Riemannian geometry induced by the stereographic parameterization.

**Experiment**:
- Compute the pullback metric on ℤᴺ induced by the projection to Sᴺ⁻¹
- Analyze geodesics in integer parameter space (shortest paths between weight configurations)
- Relate to natural gradient descent and Fisher information geometry

**Update Protocol**: If the geometry is tractable, develop a "Riemannian SGD on integer lattices" algorithm.

---

**Hypothesis 6.2**: The approximation capacity of Harmonic Networks with max_int ≤ B grows polynomially in B.

**Experiment**:
- Prove a universal approximation theorem: for any continuous function f on [0,1]ᴺ and ε > 0, there exists a Harmonic Network with max_int ≤ poly(1/ε, N) that ε-approximates f
- The proof should use the density of rational points on spheres and the classical universal approximation theorem

**Update Protocol**: Quantify the dependence on N to understand the "curse of dimensionality" for rational networks.

---

## Iteration Protocol

### Monthly Cycle

1. **Week 1**: Each stream presents current hypothesis and preliminary results
2. **Week 2**: Cross-stream workshop — identify synergies and contradictions
3. **Week 3**: Focused experimentation and proof attempts
4. **Week 4**: Results review, hypothesis update, and planning for next cycle

### Quarterly Reviews

- Formal assessment of all hypotheses (confirmed / refined / falsified)
- Update the priority ranking of research streams
- Publish results (papers, Lean formalizations, open-source code)
- Recruit new team members for high-priority streams

### Annual Goals

**Year 1**: 
- Complete formal verification of N-dimensional density theorem
- Demonstrate Harmonic Networks on CIFAR-10 with <5% accuracy gap
- Prototype integer-only inference hardware
- Publish 3-5 papers

**Year 2**:
- Scale to transformer architectures (GPT-scale)
- Formally verify safety properties of trained networks
- Submit Lean formalization to Mathlib
- Publish 5-8 papers, including 1-2 in top ML venues (NeurIPS, ICML)

**Year 3**:
- Achieve state-of-the-art results on at least one benchmark with exact rational weights
- Deploy verified Harmonic Network in a safety-critical application
- Establish the field of "arithmetic deep learning" as a recognized research area
- Publish comprehensive monograph

---

## Open Questions for the Team

1. **Can we extend beyond stereographic projection?** Are there other algebraic maps from ℤᴺ to Sᴺ⁻¹ with better density/efficiency tradeoffs?

2. **What is the optimal snap schedule?** Should we snap every k iterations, or use an adaptive schedule based on the loss landscape?

3. **Can integer-parameterized networks be trained end-to-end?** I.e., can we define gradients with respect to the integer parameters (via straight-through estimators or relaxation)?

4. **What is the information-theoretic capacity of a Harmonic Network?** How many bits of "knowledge" can be stored in N integer parameters with max value B?

5. **Is there a connection to error-correcting codes?** The integer vectors form a lattice, and the projection maps them to a spherical code — can we use coding theory to optimize the integer parameterization?

6. **Can Harmonic Networks provide differential privacy guarantees?** Since the weight space is discrete, the sensitivity analysis might be cleaner than for continuous weights.

7. **What happens in the limit B → ∞?** Does the Harmonic Network converge to the continuous network, and if so, at what rate?

---

*This document is a living research agenda. All hypotheses are subject to experimental validation and iterative refinement. The team operates on the principle that falsified hypotheses are as valuable as confirmed ones — every experiment advances our understanding.*
