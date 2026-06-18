# Future Directions: Transport Geometry of Counterpoint

## Overview

The certified bridge between voice-leading and discrete optimal transport opens several concrete research programs. Each direction below includes specific hypotheses, proof strategies, and cross-domain connections suitable for immediate pursuit.

---

## Direction 1: k-Voice Transport on Pitch Classes (ℤ/12ℤ)

### Hypothesis
The sorted matching optimality theorem extends to the quotient ℤ/12ℤ with the circular metric d(x,y) = min(|x-y|, 12-|x-y|), but the optimal matching is no longer always the identity — it becomes the *cyclic* permutation that minimizes total circular distance.

### Proof Strategy
1. Define circular distance on ℤ/12ℤ and show it satisfies a modified Monge property for "unwound" orderings.
2. Prove that the optimal matching among k atoms on a circle can be found in O(k²) time by checking all k cyclic shifts (when masses are equal).
3. Formalize the CDF-based W₁ formula on the circle: W₁ = min over shifts of ∫|F - G_shifted|.

### Cross-Domain Connections
- **Orbifold geometry** (Tymoczko): pitch-class voice-leading spaces are orbifolds; transport on orbifolds connects to equivariant optimal transport.
- **Circular statistics**: W₁ on the circle is used in directional statistics and phase comparison.
- **Cryptography**: circular distance metrics appear in lattice-based cryptography.

### Lean Target
```lean
theorem circular_matching_optimal (k : ℕ) (x y : Fin k → ZMod 12) ...
```

---

## Direction 2: Rhythmic Transport on Time-Pitch Product Spaces

### Hypothesis
Extending the pitch-only transport to a product space ℤ × ℚ (pitch × time) yields a 2D transport problem whose solution decomposes into a pitch transport plus a time-warping cost, under a separable metric.

### Proof Strategy
1. Define a product metric d((p₁,t₁),(p₂,t₂)) = α|p₁-p₂| + β|t₁-t₂| with tunable weights.
2. Show that for synchronized rhythms (same onset times), the 2D transport reduces to the 1D pitch transport proved here.
3. For general rhythms, formulate as a min-cost bipartite matching and prove structural results about optimal couplings.

### Cross-Domain Connections
- **Dynamic time warping**: the rhythmic component connects to DTW algorithms in speech recognition and MIR.
- **Unbalanced transport**: rests (silences) require unbalanced OT with creation/destruction costs.
- **Video analysis**: frame-to-frame transport in video is a 2D analogue.

### Lean Target
```lean
def productMetric (α β : ℚ) (a b : ℤ × ℚ) : ℚ := α * |a.1 - b.1| + β * |a.2 - b.2|
```

---

## Direction 3: Tropical Hamilton-Jacobi Formulations

### Hypothesis
The dynamic counterpoint optimization problem, viewed as a shortest-path problem on a time-expanded pitch graph, can be reformulated as a tropical (min-plus) Hamilton-Jacobi equation, where the value function satisfies a discrete tropical PDE.

### Proof Strategy
1. Define the value function V(t, p) = min cost to reach pitch p at time t from a given start.
2. Show V satisfies V(t+1, p) = min_{p'} [V(t, p') + c(p', p) + h(t+1, p)] (Bellman equation).
3. Interpret in the (min, +) semiring as a tropical convolution: V(t+1) = V(t) ⊕_trop K, where K is the cost kernel.
4. Connect to tropical geometry: the "wavefront" of optimal costs is a tropical hypersurface.

### Cross-Domain Connections
- **Tropical geometry**: valuations, Newton polytopes, and tropical curves.
- **Idempotent analysis / Maslov dequantization**: the DP equation is a dequantized Schrödinger equation.
- **Control theory**: the Bellman equation is the HJB equation of discrete-time optimal control.
- **Existing catalog**: `AlgebraEMLTropicalPressure.lean` provides tropical semiring infrastructure.

### Lean Target
```lean
theorem bellman_tropical_convolution (V : Fin n → ℤ → ℤ) (K : ℤ → ℤ → ℤ) ...
```

---

## Direction 4: Entropic Regularization and Sinkhorn Counterpoint

### Hypothesis
Adding an entropic regularization term ε·H(π) to the transport cost yields a "softened" voice-leading problem whose solution is a Gibbs measure over matchings. As ε → 0, this recovers the hard transport solution; for ε > 0, it produces probabilistic voice-leading distributions that model compositional uncertainty.

### Proof Strategy
1. Define the regularized transport problem: min_π Σᵢⱼ cᵢⱼ πᵢⱼ + ε Σᵢⱼ πᵢⱼ log πᵢⱼ.
2. Show the solution is πᵢⱼ ∝ exp(-cᵢⱼ/ε) · uᵢ · vⱼ (Sinkhorn scaling).
3. Prove convergence to the hard transport solution as ε → 0.
4. Interpret musically: ε controls the "creativity" of voice-leading, from rigid optimal to exploratory.

### Cross-Domain Connections
- **Machine learning**: Sinkhorn distances are widely used in generative models (Wasserstein GANs).
- **Statistical mechanics**: the regularized problem is a free-energy minimization.
- **Algorithmic composition**: sampling from the Gibbs measure generates musically plausible variations.

### Lean Target
```lean
theorem sinkhorn_convergence (c : Fin k → Fin k → ℝ) (ε : ℝ) (hε : 0 < ε) ...
```

---

## Direction 5: Orbifold Transport and Tymoczko Voice-Leading Spaces

### Hypothesis
Tymoczko's voice-leading orbifolds (quotients of ℝⁿ by the symmetric group and octave equivalence) can be equipped with an intrinsic W₁ metric that agrees with the standard voice-leading distance. The sorted matching theorem lifts to a statement about geodesics on these orbifolds.

### Proof Strategy
1. Define the orbifold ℝⁿ / (Sₙ × 12ℤⁿ) as a quotient space.
2. Show the quotient metric induced by ℓ¹ equals the minimum over all lifts: d([x],[y]) = min_{σ,k} Σᵢ |xᵢ - y_{σ(i)} - 12kᵢ|.
3. Prove that for "generic" voice-leadings, the optimal lift is computed by a greedy algorithm on the unwound lattice.

### Cross-Domain Connections
- **Riemannian geometry**: orbifold metrics, geodesics on quotient spaces.
- **Crystallography**: the pitch-class lattice is isomorphic to lattices studied in crystallography.
- **Topological data analysis**: persistent homology of voice-leading spaces.

### Lean Target
```lean
def voiceLeadingOrbifold (n : ℕ) := Quotient (voiceLeadingSetoid n)
```

---

## Meta-Direction: Automated Conjecture Generation

The formalized transport-counterpoint bridge enables a systematic program:

1. **Enumerate** structural properties of the pitch lattice (total order, group structure, metric).
2. **Generate** candidate theorems by instantiating general OT results to this specific lattice.
3. **Test** candidates computationally on musical examples.
4. **Prove** or disprove in Lean.

This creates a feedback loop between computational exploration and formal verification, potentially discovering new music-theoretic principles that were not anticipated by either tradition alone.

---

## Priority Ranking

| Priority | Direction | Difficulty | Impact | Dependencies |
|----------|-----------|------------|--------|-------------|
| 1 | Direction 1 (ℤ/12ℤ) | Medium | Very High | Current work |
| 2 | Direction 3 (Tropical HJ) | Medium | High | Tropical catalog |
| 3 | Direction 5 (Orbifolds) | Hard | Very High | Direction 1 |
| 4 | Direction 2 (Rhythmic) | Medium | High | Current work |
| 5 | Direction 4 (Entropic) | Hard | Medium | Analysis infra |
