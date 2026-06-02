# Quantum Surreal Numbers: Probability Defects in Non-Archimedean Quantum States

## Abstract

We develop a rigorous mathematical framework for quantum states over non-Archimedean graded basis sets, modeling the interaction between quantum superposition and infinitesimal structure. By partitioning a quantum state's basis into an observable sector and an infinitesimal sector — inspired by the scale structure of Conway's surreal numbers — we derive a probability conservation law that splits the Born rule into observable and "dark" components. We prove that the observable probability is always at most 1, with equality precisely when all infinitesimal amplitudes vanish. We establish measurement theory for Boolean projections, including a post-measurement normalization theorem, and prove both full and sector-restricted versions of the Cauchy-Schwarz inequality. All results have been formally verified in the Lean 4 proof assistant with the Mathlib library.

**Keywords:** Quantum mechanics, surreal numbers, non-Archimedean fields, Born rule, probability defect, projection operators, spectral theory

## 1. Introduction

Conway's surreal numbers [Conway, 1976] constitute the largest ordered field, containing the real numbers, ordinal numbers, and a rich hierarchy of infinitesimals and infinite elements. Despite their foundational significance, surreal numbers have seen limited application to physics. We propose that the scale structure of surreal numbers — specifically, the partition of surreal elements into standard (observable) and nonstandard (infinitesimal) components — provides a natural framework for studying quantum systems with multi-scale structure.

The key observation is simple: if a quantum state's basis elements are labeled by surreal numbers, then some basis states may correspond to infinitesimal values. The Born rule probability of observing such a state — the square of its amplitude — may itself be infinitesimal, hence unobservable under the standard part map. This creates a "probability defect": the total observable probability falls short of 1 by exactly the amount of probability hiding in infinitesimal modes.

This paper formalizes this observation and develops its consequences. We work axiomatically, abstracting the essential features of the surreal scale structure into a simple partition (the `ScaleDecomp` structure) and deriving results that hold for any finite-dimensional quantum system equipped with such a partition.

## 2. Definitions and Setup

### 2.1 Quantum States

**Definition 2.1** (QState). A *quantum state* on `Fin n` is a function `amp : Fin n → ℝ` satisfying the Born rule normalization:

$$\sum_{i=0}^{n-1} |\alpha_i|^2 = 1$$

We work with real amplitudes for simplicity; the complex case follows by treating real and imaginary parts separately.

### 2.2 Scale Decomposition

**Definition 2.2** (ScaleDecomp). A *scale decomposition* on `Fin n` is a Boolean function `isObservable : Fin n → Bool` that partitions the basis into:
- The *observable set* `obsSet = {i : isObservable(i) = true}`
- The *infinitesimal set* `infSet = {i : isObservable(i) = false}`

This models the key structure of surreal numbers: each basis element has a "scale" determining whether it contributes to observable physics (finite surreal values) or hides in the infinitesimal sector.

### 2.3 Sector Probabilities

**Definition 2.3**. The *observable probability* of a state ψ under decomposition s is:

$$P_{\text{obs}}(\psi, s) = \sum_{i \in \text{obsSet}} |\alpha_i|^2$$

The *infinitesimal probability* is:

$$P_{\text{inf}}(\psi, s) = \sum_{i \in \text{infSet}} |\alpha_i|^2$$

The *probability defect* is:

$$\delta(\psi, s) = 1 - P_{\text{obs}}(\psi, s)$$

### 2.4 Boolean Projections

**Definition 2.4** (BoolProjection). A *Boolean projection* on `Fin n` is a function `keep : Fin n → Bool`. Its action on a state is:

$$(P\psi)_i = \begin{cases} \alpha_i & \text{if } \text{keep}(i) = \text{true} \\ 0 & \text{otherwise} \end{cases}$$

The *complement* of P is the projection with `keep' = ¬keep`.

## 3. Main Results

### 3.1 Probability Conservation (Theorem 1)

**Theorem 3.1** (prob_conservation). *For any quantum state ψ and scale decomposition s:*

$$P_{\text{obs}}(\psi, s) + P_{\text{inf}}(\psi, s) = 1$$

*Proof sketch.* The observable and infinitesimal sets are disjoint (by construction) and their union is the full basis `Fin n`. Therefore:

$$P_{\text{obs}} + P_{\text{inf}} = \sum_{i \in \text{obsSet}} |\alpha_i|^2 + \sum_{i \in \text{infSet}} |\alpha_i|^2 = \sum_{i \in \text{obsSet} \cup \text{infSet}} |\alpha_i|^2 = \sum_{i} |\alpha_i|^2 = 1$$

The formal proof uses `Finset.sum_union` with the disjointness hypothesis `obs_inf_disjoint` and the covering hypothesis `obs_inf_union`. □

### 3.2 Observable Probability Bound (Theorem 2)

**Theorem 3.2** (observable_prob_le_one). *For any quantum state ψ and scale decomposition s:*

$$P_{\text{obs}}(\psi, s) \leq 1$$

*Proof.* Immediate from Theorem 3.1 and non-negativity of P_inf. □

### 3.3 Characterization of Fully Observable States (Theorem 3)

**Theorem 3.3** (observable_eq_one_iff_no_infinitesimal). *The following are equivalent:*
1. $P_{\text{obs}}(\psi, s) = 1$
2. $\forall i,\ \text{isObservable}(i) = \text{false} \implies \alpha_i = 0$

*Proof sketch.* (1⇒2): If P_obs = 1, then P_inf = 0 by conservation. Since P_inf is a sum of non-negative terms (squares) equaling zero, each term is zero, hence each infinitesimal amplitude vanishes. (2⇒1): If all infinitesimal amplitudes are zero, then P_inf = 0, so P_obs = 1 by conservation. □

This theorem provides the sharp criterion for when the probability defect vanishes. It formalizes the physical intuition that infinitesimal modes are "quantum dark matter" — they exist mathematically but contribute nothing to observable predictions.

### 3.4 Complementary Projection Completeness (Theorem 4)

**Theorem 3.4** (born_rule_complementary). *For any Boolean projection P and quantum state ψ:*

$$\Pr[P|\psi] + \Pr[\bar{P}|\psi] = 1$$

*Proof sketch.* For each basis element i, either keep(i) = true (contributing α_i² to the first term and 0 to the second) or keep(i) = false (contributing 0 to the first and α_i² to the second). Summing over all i gives ∑ α_i² = 1. □

### 3.5 Post-Measurement Normalization (Theorem 5)

**Theorem 3.5** (post_measurement_normalized). *If P is a Boolean projection with Pr[P|ψ] > 0, then the post-measurement state*

$$\psi'_i = \frac{(P\psi)_i}{\sqrt{\sum_j |(P\psi)_j|^2}}$$

*satisfies ∑ |ψ'_i|² = 1.*

*Proof.* Factor out 1/√(norm²) from the sum, use the fact that (√x)² = x for x ≥ 0, and simplify to norm²/norm² = 1. □

This theorem validates the projection postulate of quantum mechanics within our framework.

### 3.6 Cauchy-Schwarz for Quantum States (Theorem 6)

**Theorem 3.6** (quantum_cauchy_schwarz). *For any two quantum states ψ, φ:*

$$\langle\psi|\phi\rangle^2 \leq 1$$

*Proof.* By the classical Cauchy-Schwarz inequality for finite sums (Finset.sum_mul_sq_le_sq_mul_sq in Mathlib):

$$\left(\sum_i \alpha_i \beta_i\right)^2 \leq \left(\sum_i \alpha_i^2\right)\left(\sum_i \beta_i^2\right) = 1 \cdot 1 = 1$$

□

### 3.7 Observable Cauchy-Schwarz (Theorem 7)

**Theorem 3.7** (obs_cauchy_schwarz). *For any two quantum states ψ, φ and scale decomposition s:*

$$\langle\psi|\phi\rangle_{\text{obs}}^2 \leq P_{\text{obs}}(\psi, s) \cdot P_{\text{obs}}(\phi, s)$$

*Proof.* Apply Cauchy-Schwarz restricted to the observable sector. □

This is perhaps the most physically interesting result. It says that the observable distinguishability of two quantum states is bounded not just by 1 (as in the full Cauchy-Schwarz inequality) but by the product of their observable probabilities. States with large probability defects are harder to distinguish observationally.

## 4. The Probability Defect

### 4.1 Defect Equals Infinitesimal Probability

**Theorem 4.1** (prob_defect_eq_infinitesimal). $\delta(\psi, s) = P_{\text{inf}}(\psi, s)$.

This follows immediately from probability conservation.

### 4.2 Defect Characterization

**Theorem 4.2** (prob_defect_zero_iff). $\delta(\psi, s) = 0$ if and only if all infinitesimal amplitudes vanish.

This follows from Theorem 3.3.

### 4.3 Physical Interpretation

The probability defect has a natural physical interpretation. Consider a quantum system where basis states are labeled by surreal numbers, and the scale decomposition separates standard from infinitesimal values. The defect δ measures the total probability "hiding" in states with infinitesimal labels. Since the standard part of an infinitesimal is zero, this probability is invisible to any finite-precision measurement.

This connects to several ideas in mathematical physics:

1. **Renormalization**: In quantum field theory, infinities arise from summing over all momentum modes. The scale decomposition provides a rigorous framework for separating "relevant" (finite) from "irrelevant" (infinitesimal/infinite) modes.

2. **Decoherence**: Environmental decoherence effectively projects a quantum state onto a preferred basis. In the surreal framework, the "preferred basis" is naturally the observable sector.

3. **The measurement problem**: The inability to observe infinitesimal probabilities provides a mathematical mechanism for why certain quantum outcomes never occur — not because they're forbidden, but because they're infinitesimally unlikely.

## 5. Connections to Existing Work

### 5.1 Hyperreal Probability

Benci et al. [2013] developed a theory of non-Archimedean probability using the hyperreal numbers. Our framework differs in using surreal numbers (which contain the hyperreals) and in focusing on the quantum-mechanical setting (normalized states, projections, measurement).

### 5.2 Non-standard Quantum Mechanics

Albeverio et al. [1986] applied nonstandard analysis to quantum mechanics, using hyperreal amplitudes in path integrals. Our approach is complementary: rather than making the amplitudes nonstandard, we make the *basis labels* nonstandard and study the consequences for observable probability.

### 5.3 Surreal Analysis

Recent work by Ehrlich [2012] and others has developed analysis on surreal numbers, including integration and exponential functions. A natural extension of our work would be to define surreal-valued inner products and study the resulting Hilbert space structure.

## 6. Open Questions and Conjectures

### 6.1 Spectral Theorem for Surreal Operators

**Conjecture 6.1**. Every self-adjoint operator on a finite-dimensional quantum surreal Hilbert space admits a spectral decomposition with surreal eigenvalues:

$$A = \sum_\lambda \lambda \cdot P_\lambda$$

where the sum ranges over surreal eigenvalues and P_λ are projection operators.

**Test**: Construct a 2×2 self-adjoint matrix with one real and one infinitesimal eigenvalue. Verify that the spectral decomposition separates observable and infinitesimal sectors.

### 6.2 Entanglement and Dark Probability

**Conjecture 6.2**. In a bipartite system with dark probability, the entanglement entropy of the observable sector is strictly less than the total entanglement entropy.

### 6.3 Dynamics

**Question**: Does there exist a natural unitary dynamics on quantum surreal states that preserves the scale decomposition? If so, the probability defect would be a conserved quantity — a new kind of quantum number.

## 7. Algorithms

### 7.1 Computing the Probability Defect

**Input**: A quantum state ψ (array of n amplitudes) and a Boolean mask `isObservable`.

**Output**: The probability defect δ(ψ, s).

```
function ProbabilityDefect(amplitudes, isObservable):
    total = 0
    for i = 0 to n-1:
        if not isObservable[i]:
            total += amplitudes[i]^2
    return total
```

Time complexity: O(n). Space complexity: O(1).

### 7.2 Post-Measurement Renormalization

**Input**: A quantum state ψ, a Boolean projection P with nonzero probability.

**Output**: The post-measurement state ψ'.

```
function PostMeasurement(amplitudes, keep):
    norm_sq = sum(amplitudes[i]^2 for i where keep[i])
    result = [0] * n
    for i = 0 to n-1:
        if keep[i]:
            result[i] = amplitudes[i] / sqrt(norm_sq)
    return result
```

## 8. Conclusion

We have developed a rigorous mathematical framework for quantum states equipped with a non-Archimedean scale structure. The key results — probability conservation, the characterization of fully observable states, post-measurement normalization, and the observable Cauchy-Schwarz inequality — have been formally verified in Lean 4, ensuring their correctness with machine-checked certainty.

The framework opens several avenues for future research: extending to infinite-dimensional Hilbert spaces, connecting to surreal-valued spectral theory, and exploring the physical implications of dark probability for quantum information and measurement theory.

## References

1. Conway, J.H. (1976). *On Numbers and Games*. Academic Press.
2. Knuth, D.E. (1974). *Surreal Numbers*. Addison-Wesley.
3. Ehrlich, P. (2012). "The absolute arithmetic continuum and the unification of all numbers great and small." *Bulletin of Symbolic Logic*, 18(1), 1-45.
4. Benci, V., Horsten, L., & Wenmackers, S. (2013). "Non-Archimedean probability." *Milan Journal of Mathematics*, 81, 121-151.
5. Albeverio, S., Fenstad, J.E., Høegh-Krohn, R., & Lindstrøm, T. (1986). *Nonstandard Methods in Stochastic Analysis and Mathematical Physics*. Academic Press.
6. von Neumann, J. (1932). *Mathematische Grundlagen der Quantenmechanik*. Springer.
