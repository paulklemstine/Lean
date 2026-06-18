# Future Directions: Tropical Music Theory

## Overview

This document outlines five concrete, breakthrough-level research directions opened by the formalization of tropical voice-leading optimization. Each direction includes specific hypotheses, proof strategies, and cross-domain connections.

---

## 1. Four-Part Chorale Writing via Tropical Hypergraph Optimization

### Vision
Extend the two-voice framework to four-part SATB (soprano, alto, tenor, bass) chorale writing, where vertical constraints become hyperedge penalties on 4-tuples and voice-leading costs form a layered tropical hypergraph.

### Specific Hypotheses
- **H1.1**: Bach chorale voice-leading can be characterized as shortest paths in a tropical hypergraph where nodes are 4-note chords and hyperedges encode simultaneous constraints (parallel fifths between any pair, voice spacing, voice crossing).
- **H1.2**: The four-voice generalization of the zero-cost theorem holds: legal SATB counterpoint = zero locus of a 6-component penalty (one per voice pair).
- **H1.3**: The exponential blowup in candidate space (P^4n vs P^n) can be managed via tropical tensor decomposition, factoring the 4-voice problem into coupled 2-voice subproblems.

### Proof Strategy
1. Define `Chorale (n : ℕ) := Fin 4 → Melody n` (four voices).
2. Extend `totalCost` to sum over all 6 voice pairs with additional spacing penalties.
3. Prove the zero-cost theorem by reduction to the two-voice case on each pair.
4. For DP, define a tropical tensor product `⊗_trop` and prove that 4-voice optimization decomposes as `min_{S,A,T,B} = min_S min_A (⊗_trop ...)`.

### Cross-Domain Connections
- **Constraint satisfaction**: Maps to arc consistency in a CSP with 6 binary constraints.
- **Tensor networks**: The tropical tensor decomposition connects to tensor network contraction in quantum computing.
- **Graph neural networks**: The layered hypergraph structure is exactly the architecture of a message-passing GNN over chord sequences.

---

## 2. Tropical Rate-Distortion Theory for Harmonic Variety

### Vision
Formalize the tradeoff between contrapuntal legality (distortion) and harmonic diversity (rate) as a tropical analogue of Shannon's rate-distortion function. The key theorem would be a tropical data-processing inequality: musical transformations (transposition, inversion, retrograde) cannot increase the rate-distortion-optimal variety.

### Specific Hypotheses
- **H2.1**: Define `R_trop(D)` = the maximum harmonic variety achievable with contrapuntal cost ≤ D. This is a non-increasing step function on ℝ≥0.
- **H2.2**: For any musical transformation T (transposition, inversion), `R_trop(D; T(u), T(v)) = R_trop(D; u, v)` (invariance under symmetries).
- **H2.3**: For any "channel" (surjective pitch-class map) φ, `R_trop(D; u, φ∘v) ≤ R_trop(D; u, v)` (tropical data-processing inequality).

### Proof Strategy
1. Prove that transposition preserves all penalty functions (vertical, melodic, parallel).
2. Show that the rate-distortion frontier is the upper envelope of the Pareto frontier, computable over finite candidate sets.
3. For the data-processing inequality, show that φ can only merge interval classes, reducing variety.

### Cross-Domain Connections
- **Information theory**: Direct analogue of classical rate-distortion; potential connection to Rényi entropy at q→∞.
- **Idempotent probability**: Maslov dequantization maps Shannon entropy to tropical support size.
- **Music cognition**: Models how human perception of harmonic richness degrades under pitch quantization.

---

## 3. Categorical Composition Operators on Tropical Style Spaces

### Vision
Define a category **TropStyle** whose objects are tropical cost functionals (representing musical styles) and whose morphisms are style transformations (parameter rescaling, constraint addition/relaxation). Prove that composition in this category corresponds to superposition of stylistic constraints.

### Specific Hypotheses
- **H3.1**: The collection of weighted cost functionals `{weightedTotalCost A B C | A, B, C ≥ 0}` forms a tropical semiring under pointwise min and addition.
- **H3.2**: Style transformations (adding new penalty terms, restricting pitch range) form a monoidal category with the identity functor being "no additional constraints."
- **H3.3**: The Pareto frontier functor `PF : TropStyle → Poset` is contravariant: adding constraints shrinks the Pareto frontier.

### Proof Strategy
1. Formalize cost functionals as objects in a category enriched over the tropical semiring.
2. Define morphisms as pairs (f, g) where f maps cost parameters and g maps candidate sets.
3. Prove functoriality of the Pareto frontier construction.
4. Show that the "free counterpoint" style is initial and the "strict Palestrina" style is terminal.

### Cross-Domain Connections
- **Applied category theory**: Connects to Fong-Spivak's compositional frameworks for open systems.
- **Formal methods**: Style categories as refinement lattices for musical specifications.
- **Machine learning**: Categorical abstraction enables compositional transfer learning across musical styles.

---

## 4. Voice-Leading as Discrete Optimal Transport

### Vision
Formulate voice-leading cost as a discrete optimal transport problem: moving pitch mass from one chord configuration to another. Prove stability theorems showing that small perturbations of the cantus firmus produce bounded perturbations of optimal counterpoint.

### Specific Hypotheses
- **H4.1**: The voice-leading cost between two chords (as multisets of pitches) equals the Wasserstein-1 distance on ℤ with the contrapuntal cost as ground metric.
- **H4.2**: Transposition invariance: `W_1(u + k, v + k) = W_1(u, v)` for any constant transposition k.
- **H4.3**: Stability: if `‖u - u'‖_∞ ≤ δ`, then the optimal counterpoint voices v and v' satisfy `totalCost u v - totalCost u' v' ≤ C · δ` for a computable constant C.

### Proof Strategy
1. Encode chords as discrete measures on ℤ.
2. Use the Kantorovich dual formulation: the optimal transport cost equals the maximum over 1-Lipschitz functions.
3. Prove stability via the triangle inequality for Wasserstein distance.
4. For the tropical connection: optimal transport with min-plus cost is exactly tropical matrix multiplication.

### Cross-Domain Connections
- **Computational geometry**: Voice-leading polytopes as transport polytopes.
- **Mathematical biology**: Connects to Wasserstein distances in phylogenetics and evolutionary biology.
- **Computer graphics**: Shape matching via optimal transport has the same algebraic structure as voice matching.

---

## 5. Mod-12 Pitch-Class Counterpoint and Tropical Torus Geometry

### Vision
Reduce counterpoint from ℤ (unbounded pitches) to ℤ/12ℤ (pitch classes modulo octave), creating a tropical optimization problem on the discrete torus. Compare the register-sensitive and pitch-class theories, proving that pitch-class counterpoint is a quotient of the full theory.

### Specific Hypotheses
- **H5.1**: The pitch-class reduction map `π : ℤ → ℤ/12ℤ` induces a surjective homomorphism of tropical cost functionals: `totalCost_12(u, v) ≤ totalCost(u, v)` for any lifts.
- **H5.2**: The pitch-class zero-cost locus is strictly larger than the register-sensitive zero-cost locus (more melodies are "legal" when octave equivalence is imposed).
- **H5.3**: The dynamic programming on ℤ/12ℤ has fixed state space (12 pitch classes) regardless of melody length, giving O(144n) complexity vs O(P²n) for P pitches.

### Proof Strategy
1. Define `Melody12 (n : ℕ) := Fin n → ZMod 12`.
2. Redefine consonance, cost functions on `ZMod 12`.
3. Prove the quotient map preserves the tropical semiring structure.
4. Show that the pitch-class DP table has exactly 12 states per layer, proving the complexity bound.
5. Construct an explicit melody legal in pitch-class theory but illegal in register-sensitive theory.

### Cross-Domain Connections
- **Algebraic topology**: The torus ℤ/12ℤ × ℤ/12ℤ for two-voice pitch-class space connects to Mazzola's topos-theoretic music theory.
- **Cryptography**: Lattice problems on ℤ^n modulo M connect to the same algebraic structures.
- **Signal processing**: Pitch-class reduction is exactly the DFT modulo 12, connecting to Fourier analysis on finite groups.
- **Number theory**: Properties of consonance modulo 12 connect to quadratic residues and Gauss sums.

---

## Implementation Priority

| Direction | Difficulty | Impact | Dependencies |
|-----------|-----------|--------|-------------|
| 5. Mod-12 | Medium | High | Self-contained |
| 2. Rate-Distortion | Medium | Very High | Pareto theorem |
| 4. Optimal Transport | High | Very High | Self-contained |
| 1. Four-Part | High | Transformative | Two-voice theory |
| 3. Categorical | Very High | Foundational | All above |

**Recommended next step**: Direction 5 (mod-12), as it is self-contained, computationally concrete, and provides a test bed for all other directions. Direction 2 follows naturally from the Pareto machinery already formalized.
