# Future Directions: Tropical Hankel Duality and Cryptographic Hardness

## Overview

This document outlines breakthrough-level next steps opened by the formalization of tropical Hankel duality for min-plus one-way transducers. The central achievement — proving that finite tropical Hankel rank forces collision reconstructibility and therefore obstructs one-wayness — creates a foundation for an entirely new approach to cryptanalysis through semiring spectral invariants.

---

## Direction 1: Tropical Rank Lower Bounds for Explicit Hash Families

### Statement

For any candidate tropical hash family `F_n : {0,1}^* → ℝ^m` defined by min-plus matrix products, prove explicit lower bounds on the tropical Hankel rank as a function of the security parameter `n`.

### Specific Theorem Target

```lean
theorem exponential_rank_of_random_tropical_hash
    {n : ℕ} (hn : 10 ≤ n)
    (F : List Bool → Fin n → ℝ)
    (hF : ∀ u v, F (u ++ v) = tropMul hn (stateMatrix u) (outputMatrix v)) :
    tropicalHankelRank F ≥ 2 ^ (n / 2) ∨ ¬ TropicalCollisionResistant F
```

### Strategy

1. Exhibit a concrete family of min-plus matrices where rank growth can be tracked combinatorially.
2. Use tropical Vandermonde-type arguments to show that random min-plus matrices have full tropical rank with high probability.
3. Connect to classical communication complexity lower bounds via the rank method.

### Cross-Domain Impact

- **Complexity theory**: Tropical rank lower bounds would parallel classical matrix rigidity results.
- **Cryptography**: Would provide the first structural certificates for tropical hash security.
- **Combinatorics**: Connections to tropical Vandermonde determinants and permanent computation.

---

## Direction 2: Tropical Pseudorandom Generators vs Finite Hankel Complexity

### Statement

Define a notion of tropical pseudorandomness and prove that no function with bounded Hankel rank can be tropically pseudorandom.

### Specific Theorem Target

```lean
def TropicallyPseudorandom (G : List Bool → List ℝ) (ε : ℝ) : Prop :=
  ∀ (D : List ℝ → Bool),
    TropicallyComputable D →
    |Pr[D(G(x)) = 1] - Pr[D(U) = 1]| < ε

theorem bounded_rank_not_pseudorandom
    (G : List Bool → List ℝ)
    (hG : HasFiniteTropicalHankelRank G)
    (ε : ℝ) (hε : 0 < ε) :
    ¬ TropicallyPseudorandom G ε
```

### Strategy

1. Define tropical distinguishers as min-plus automata with binary output.
2. Show that the Hankel factorization exposes enough structure for a distinguisher to separate the generator's output from uniform random.
3. The distinguisher uses the spectral decomposition to compute invariants absent from random outputs.

### Cross-Domain Impact

- **Pseudorandomness theory**: New structural obstruction beyond the classical Nisan-Wigderson framework.
- **Learning theory**: Connections to PAC-learnability of tropical circuits.
- **Derandomization**: Tropical analogues of Impagliazzo-Wigderson hardness vs randomness.

---

## Direction 3: Canonical Minimal Tropical Spectral Models

### Statement

Prove uniqueness (up to tropical isomorphism) of the minimal tropical spectral decomposition of a finite-rank function, establishing a tropical analogue of the Nerode canonical automaton.

### Specific Theorem Target

```lean
structure MinimalSpectralModel {α : Type*} (f : List α → ℝ) extends
    EffectiveSpectralDecomposition f where
  minimal : ∀ (E' : EffectiveSpectralDecomposition f), n ≤ E'.n

theorem minimal_spectral_unique
    {α : Type*} [Fintype α] [DecidableEq α]
    (f : List α → ℝ)
    (M₁ M₂ : MinimalSpectralModel f) :
    TropicallyIsomorphic M₁.toEffectiveSpectralDecomposition
                          M₂.toEffectiveSpectralDecomposition
```

### Strategy

1. Define tropical isomorphism of spectral decompositions via a permutation-scaling equivalence on coefficients and bases.
2. Prove that any two minimal decompositions have the same rank by a dimension argument.
3. Construct the isomorphism via the Hankel row equivalence: both decompositions induce the same congruence on words.

### Cross-Domain Impact

- **Automata theory**: Tropical Myhill-Nerode uniqueness theorem.
- **Representation theory**: Canonical forms for tropical semimodules.
- **Machine learning**: Minimal state representations for tropical neural networks.

---

## Direction 4: Average-Case One-Wayness vs Worst-Case Hankel Growth

### Statement

Prove that average-case one-wayness (hardness of inversion on random inputs) requires not just unbounded Hankel rank, but Hankel rank that grows on average over the input distribution.

### Specific Theorem Target

```lean
theorem avgCase_oneWay_requires_avgRank_growth
    {α : Type*} [Fintype α]
    (F : ℕ → (List α → ℝ))
    (D : ℕ → Distribution (List α))
    (hOW : AverageCaseOneWayFamily F D) :
    ∀ c : ℝ, ∃ n₀, ∀ n ≥ n₀,
      E_{x ~ D n} [localHankelRank (F n) x] ≥ n ^ c
```

### Strategy

1. Define local Hankel rank at a point as the rank of the Hankel submatrix in a neighborhood.
2. Show that if average local rank is bounded, the spectral decomposition can be computed efficiently on average, enabling average-case inversion.
3. Use probabilistic argument: if most inputs have low local rank, the reconstruction algorithm succeeds with non-negligible probability.

### Cross-Domain Impact

- **Cryptography**: First average-case/worst-case connection for tropical one-wayness.
- **Complexity theory**: Tropical analogue of Levin's theory of average-case complexity.
- **Information theory**: Entropy-rank duality in tropical semimodules.

---

## Direction 5: Tropical Analogues of Linear and Differential Cryptanalysis

### Statement

Develop tropical versions of classical linear and differential cryptanalysis, where tropical linear approximations (min-plus affine functions) and tropical differentials (perturbation propagation through min-plus circuits) replace their classical counterparts.

### Specific Theorem Target

```lean
/-- Tropical linear approximation probability -/
def tropLinApproxBias (f : Fin n → ℝ → ℝ) (a b : Fin n → ℝ) : ℝ :=
  E_{x uniform} |tropCombine a (f x) - tropCombine b x|

/-- Piling-up lemma for tropical linear approximations -/
theorem tropical_piling_up
    (f g : Fin n → ℝ → ℝ)
    (a b c : Fin n → ℝ)
    (hf : tropLinApproxBias f a b ≤ εf)
    (hg : tropLinApproxBias g b c ≤ εg) :
    tropLinApproxBias (g ∘ f) a c ≤ εf + εg
```

### Strategy

1. Define tropical linear approximation as the best min-plus affine approximation to a tropical circuit.
2. Prove that tropical approximation errors compose additively (tropical piling-up lemma) rather than multiplicatively as in the classical case.
3. Show that low Hankel rank implies the existence of good tropical linear approximations, connecting structural weakness to attack efficiency.

### Cross-Domain Impact

- **Symmetric-key cryptanalysis**: New attack framework for min-plus block ciphers.
- **Tropical geometry**: Approximation theory for tropical polynomials.
- **Optimization**: Error propagation in min-plus dynamic programming.

---

## Prioritization

| Direction | Difficulty | Impact | Dependencies |
|-----------|-----------|--------|-------------|
| 1. Rank Lower Bounds | Hard | Very High | Current work |
| 2. Pseudorandomness | Medium | High | Direction 1 |
| 3. Canonical Models | Medium | High | Current work |
| 4. Average-Case | Hard | Very High | Directions 1, 3 |
| 5. Tropical Cryptanalysis | Medium | High | Current work |

**Recommended order**: 3 → 1 → 5 → 2 → 4

Direction 3 (canonical models) is the natural next step from the current formalization and provides essential infrastructure for all other directions. Direction 1 (rank lower bounds) is the most impactful but requires new techniques. Direction 5 (tropical cryptanalysis) can proceed in parallel and has immediate practical relevance.

---

## Meta-Direction: Building a Tropical Cryptanalysis Toolkit

The ultimate goal is a verified toolkit where:
1. A user inputs a tropical hash specification (transition matrices, initial/final vectors).
2. The system computes the Hankel factorization rank.
3. If rank is bounded, it extracts a certified collision algorithm with complexity bounds.
4. If rank appears unbounded, it reports structural evidence for security.

This would be the first machine-verified cryptanalysis framework based on algebraic structure theory rather than ad hoc attack discovery.
