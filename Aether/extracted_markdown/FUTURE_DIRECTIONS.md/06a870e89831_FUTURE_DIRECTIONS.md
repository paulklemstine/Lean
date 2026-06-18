# Future Directions: Tropical Geometry of Learning Phase Transitions

## Overview

This document outlines five concrete research directions opened by the tropical grokking framework. Each direction includes specific hypotheses, proof strategies, and cross-domain connections.

---

## Direction 1: Tropical Scaling Laws for Grokking Time

### Hypothesis
The time to grokking is controlled by the **tropical distance** from the initial parameters to the nearest corner locus in the relevant tropical cell decomposition. Specifically:

$$T_{\text{grok}} \sim \frac{d_{\text{trop}}(\theta_0, \mathcal{C})^2}{\eta \cdot \lambda}$$

where η is the learning rate, λ is the weight decay, and d_trop is the min-plus distance to the corner locus C.

### Proof Strategy
1. Formalize the tropical distance to the corner locus as a well-defined quantity (infimum of ℓ∞ distance to the nearest point with |active set| ≥ 2).
2. Prove that gradient descent in a tropical cell moves at most O(η) per step (Lipschitz bound on parameter updates).
3. Derive a lower bound on grokking time from the distance-to-boundary divided by the step size.
4. Prove an upper bound by showing weight decay drives parameters toward the corner locus at rate O(λ).

### Cross-Domain Connections
- **Statistical mechanics:** Analogous to nucleation time in first-order phase transitions.
- **Complexity theory:** Relates to the mixing time of random walks on polyhedral complexes.

### Concrete Next Steps
- Formalize tropical distance to the corner locus in Lean.
- Prove lower and upper bounds for 1D (n=1) case.
- Empirically validate scaling law on modular arithmetic tasks for p = 5, 7, 11, 13.

---

## Direction 2: Stochastic Tropical Dynamics and Noise-Induced Corner Crossings

### Hypothesis
SGD noise can induce corner-locus crossings that deterministic gradient descent would miss. The probability of a noise-induced crossing depends on the **local geometry of the corner locus** (specifically, the angle between adjacent tropical cells).

### Proof Strategy
1. Model SGD as deterministic descent plus isotropic Gaussian noise: θ_{t+1} = θ_t - η∇L(θ_t) + σξ_t.
2. Within a tropical cell, ∇L is constant (the loss is affine), so the dynamics reduce to a biased random walk.
3. Compute the probability of crossing the corner locus as a first-passage-time problem for the random walk.
4. Show that the crossing probability depends on the normal distance to the boundary and the noise magnitude σ.

### Cross-Domain Connections
- **Kramers' escape rate theory** from chemical physics.
- **Langevin dynamics** on polyhedral complexes.
- **Metastability theory** in stochastic processes.

### Concrete Next Steps
- Formalize the biased random walk within a tropical cell.
- Prove first-passage-time bounds for 1D case (single boundary).
- Simulate and compare with empirical grokking time distributions.

---

## Direction 3: Ultrametric Mutual Information as a Grokking Precursor

### Hypothesis
Define a **tropical mutual information** between the network's internal representation and the target variable, using the min-plus semiring in place of the log-sum-exp. This quantity undergoes a discontinuous increase at grokking onset and can serve as an even earlier predictor than the degeneracy index.

### Proof Strategy
1. Define tropical entropy: H_trop(X) = -min_x log p(x) (min-plus version of Shannon entropy).
2. Define tropical mutual information: I_trop(X; Y) = H_trop(X) + H_trop(Y) - H_trop(X, Y).
3. Show that I_trop is invariant within a tropical cell (since the representation is affine in parameters).
4. Prove that a corner crossing can cause I_trop to jump discontinuously.
5. Connect to the p-adic/ultrametric information theory via the correspondence between tropical semirings and non-Archimedean valuations.

### Cross-Domain Connections
- **p-adic number theory:** Tropical semiring arises as the value group of a non-Archimedean field.
- **Information geometry:** Tropical Fisher information metric on the space of piecewise-linear distributions.
- **Neuroscience:** Ultrametric structure in cortical representations.

### Concrete Next Steps
- Formalize tropical entropy and mutual information in Lean.
- Prove cell-invariance of tropical MI.
- Compute tropical MI on toy grokking examples and compare with standard MI.

---

## Direction 4: Chamber-Complexity Bounds for Modular Arithmetic Tasks

### Hypothesis
For a ReLU network learning addition mod p, the number of tropical cells scales polynomially in p but exponentially in depth, and the grokking time is controlled by the **combinatorial diameter** of the tropical cell complex (the minimum number of corner crossings needed to reach a generalizing cell from initialization).

### Proof Strategy
1. Analyze the tropical cell structure of 2-layer ReLU networks on one-hot encoded inputs.
2. Count the number of distinct activation patterns (tropical cells) as a function of p and hidden dimension h.
3. Prove that the generalizing solution lies in a cell with specific combinatorial properties (related to the group structure of ℤ/pℤ).
4. Lower-bound the combinatorial diameter by the minimum number of neuron activations that must change.
5. Connect to the empirical observation that grokking time scales as O(p^α) for some α.

### Cross-Domain Connections
- **Combinatorial optimization:** Diameter of polytopes and the Hirsch conjecture.
- **Group theory:** Structure of modular arithmetic groups constrains the tropical cell complex.
- **Circuit complexity:** Tropical cells correspond to circuits; diameter bounds correspond to circuit transformation costs.

### Concrete Next Steps
- Enumerate tropical cells for small networks (h = 4, p = 5) computationally.
- Formalize the cell count bound in Lean for 1-hidden-layer networks.
- Compare predicted vs. observed grokking times.

---

## Direction 5: Tropical Renormalization Flow for Deep ReLU Networks

### Hypothesis
Composing tropical polynomials (corresponding to composing network layers) defines a **tropical renormalization group flow** on the space of piecewise-linear functions. Under this flow, the number of tropical cells (linear regions) can either grow or shrink, and grokking corresponds to a flow from a high-complexity fixed point to a low-complexity one.

### Proof Strategy
1. Define the tropical composition operator: given tropical polynomials f and g, the composition f ∘ g is again piecewise-linear but with potentially more pieces.
2. Prove that the number of cells under composition is at most multiplicative: |cells(f ∘ g)| ≤ |cells(f)| · |cells(g)|.
3. Define a tropical "effective complexity" as the minimal number of affine forms needed to represent the composed function.
4. Show that training with weight decay acts as a renormalization that reduces effective complexity.
5. Prove that the flow from high to low complexity must pass through corner-locus crossings.

### Cross-Domain Connections
- **Renormalization group** in quantum field theory and statistical mechanics.
- **Tropical intersection theory** for computing the complexity of composed tropical polynomials.
- **Neural network pruning:** Removing neurons corresponds to removing affine forms, simplifying the tropical polynomial.

### Concrete Next Steps
- Formalize tropical polynomial composition in Lean.
- Prove the multiplicative cell bound.
- Implement the complexity measure and track it during training.

---

## Research Program Summary

| Direction | Difficulty | Impact | Dependencies |
|-----------|-----------|--------|-------------|
| Scaling laws | Medium | High | Current framework |
| Stochastic dynamics | Hard | Very High | Direction 1 |
| Ultrametric MI | Medium-Hard | High | p-adic theory |
| Chamber complexity | Hard | Very High | Combinatorics |
| Renormalization | Very Hard | Transformative | Directions 1, 4 |

### Recommended Execution Order
1. **Immediate (1-3 months):** Scaling laws (Direction 1) — most accessible, direct extension of current work.
2. **Near-term (3-6 months):** Chamber complexity (Direction 4) — provides concrete predictions testable on existing grokking benchmarks.
3. **Medium-term (6-12 months):** Stochastic dynamics (Direction 2) and Ultrametric MI (Direction 3) — require additional mathematical infrastructure.
4. **Long-term (12+ months):** Renormalization (Direction 5) — most ambitious, requires all prior directions as foundation.

### Team Structure
- **Tropical geometer:** Directions 1, 4, 5 (cell decomposition, corner loci, composition)
- **Probabilist:** Direction 2 (stochastic analysis, first-passage times)
- **Information theorist:** Direction 3 (ultrametric MI, p-adic connections)
- **ML experimentalist:** All directions (empirical validation, benchmarking)
- **Formal verification specialist:** All directions (Lean formalization)
