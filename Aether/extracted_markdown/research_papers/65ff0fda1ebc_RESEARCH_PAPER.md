# EML Spectral Pairs: A Quantum-Classical Bridge for Neural Activation Functions

## Abstract

We introduce the **EML Spectral Pair**, a novel algebraic structure that formalizes the quantum-classical decomposition inherent in the EML (Exponential Minus Logarithm) activation function eml(x, y) = exp(x) − log(y). An EML Spectral Pair (θ, s) ∈ ℝ² encodes a quantum phase component exp(iθ) ∈ U(1) and a classical information component −s ∈ ℝ. We prove that:

1. **Spectral Gap Theorem**: The EML diagonal exp(x) − log(x) > 2 for all x > 0, establishing a universal lower bound on quantum-classical information exchange.

2. **Algebraic Structure**: EML Spectral Pairs form a group under componentwise addition, with the quantum channel acting as a group homomorphism to U(1) and the classical channel acting as a group homomorphism to (ℝ, +).

3. **Metric Structure**: The spectral distance d(p, q) = √((θ_p − θ_q)² + (s_p − s_q)²) is a genuine metric, and the EML diagonal is strictly convex on (0, ∞).

4. **Composition Law**: The EML value of a composed pair satisfies (p + q).value = p.amp · q.amp + p.info + q.info, revealing a multiplicative-additive duality between quantum and classical channels.

All results are formalized and verified in Lean 4 with Mathlib, using only standard axioms (propext, Classical.choice, Quot.sound).

## 1. Introduction

The EML function eml(x, y) = exp(x) − log(y) arises naturally in neural network theory as an activation function combining exponential growth with logarithmic compression [1]. Its diagonal restriction eml_diag(x) = exp(x) − log(x) appears in information-theoretic contexts as a measure combining amplitude (exp) and surprise (−log).

The central observation motivating this work is that the EML function admits a natural *quantum-classical decomposition*:

- The **exponential component** exp(x) generates unitary rotations exp(ix) on the complex unit circle, the fundamental building block of quantum gates.
- The **logarithmic component** −log(y) measures information content (Shannon surprise), the fundamental quantity in classical information theory.

This decomposition is not merely formal — it has algebraic content. The quantum channel is multiplicative (exp(i(θ₁+θ₂)) = exp(iθ₁)·exp(iθ₂)) while the classical channel is additive (−(s₁+s₂) = (−s₁) + (−s₂)). This multiplicative-additive duality mirrors the relationship between energy and entropy in thermodynamics.

### 1.1 Contributions

We make the following contributions:

1. **Novel structure**: The EML Spectral Pair, formalizing quantum-classical decomposition as an algebraic object with group structure, metric structure, and an intertwining composition law.

2. **Spectral Gap Theorem**: A strict lower bound exp(x) − log(x) > 2 for x > 0, with a proof exploiting the complementary convexity/concavity of exp and log.

3. **Strict convexity**: The EML diagonal is strictly convex on (0, ∞), implying uniqueness of the minimum and stability of the spectral gap.

4. **Complete formalization**: All definitions and theorems are verified in Lean 4 with Mathlib, providing the highest level of mathematical certainty.

## 2. Definitions

### 2.1 The EML Function

**Definition 2.1** (EML Function). For x, y ∈ ℝ with the convention log(y) = 0 for y ≤ 0:
$$\text{eml}(x, y) = e^x - \log y$$

**Definition 2.2** (EML Diagonal). The self-interaction term:
$$\text{eml}_{\text{diag}}(x) = e^x - \log x$$

### 2.2 EML Spectral Pair

**Definition 2.3** (EML Spectral Pair). An EML Spectral Pair is an element p = (θ, s) ∈ ℝ², where:
- θ is the **phase** parameter, generating the unitary gate exp(iθ) ∈ U(1)
- s is the **log-scale** parameter, encoding classical information content −s

The space of EML Spectral Pairs carries the following operations:

- **Addition**: (θ₁, s₁) + (θ₂, s₂) = (θ₁ + θ₂, s₁ + s₂)
- **Zero**: 0 = (0, 0)
- **Negation**: −(θ, s) = (−θ, −s)

**Definition 2.4** (Derived Quantities). For a spectral pair p = (θ, s):
- Quantum gate: Q(p) = exp(iθ) ∈ ℂ, with |Q(p)| = 1
- Classical information: I(p) = −s ∈ ℝ
- Quantum amplitude: A(p) = exp(θ) ∈ ℝ₊
- EML value: V(p) = exp(θ) − s = A(p) + I(p)

### 2.3 Quantum EML Neuron

**Definition 2.5** (Quantum EML Neuron). A quantum EML neuron N = (w₁, b₁, w₂, b₂) ∈ ℝ⁴ transforms input x ∈ ℝ to the spectral pair:
$$N(x) = (w_1 x + b_1,\; w_2 x + b_2)$$

producing quantum output Q(N(x)) = exp(i(w₁x + b₁)) and classical output V(N(x)) = exp(w₁x + b₁) − (w₂x + b₂).

### 2.4 Spectral Distance

**Definition 2.6** (EML Spectral Distance).
$$d(p, q) = \sqrt{(\theta_p - \theta_q)^2 + (s_p - s_q)^2}$$

## 3. Main Results

### 3.1 The Spectral Gap Theorem

**Theorem 3.1** (EML Spectral Gap). *For all x > 0, exp(x) − log(x) > 2.*

*Proof sketch.* We use two classical inequalities:
1. exp(x) > 1 + x for x > 0 (strict convexity of exp at x ≠ 0)
2. log(x) ≤ x − 1 for x > 0 (concavity of log)

Subtracting: exp(x) − log(x) > (1 + x) − (x − 1) = 2. □

**Corollary 3.2.** *The EML diagonal is strictly positive on (0, ∞): eml_diag(x) > 0 for x > 0.*

**Theorem 3.3** (Amplitude Dominance). *For all x > 0, exp(x) > log(x) + 2.* This quantifies the sense in which quantum amplitude dominates classical information.

**Theorem 3.4** (EML Lower Bound). *For a > 0, b > 0: eml(a, b) ≥ 2 + a − b.*

### 3.2 Algebraic Structure

**Theorem 3.5** (Quantum Gate Unitarity). *For any spectral pair p, ‖Q(p)‖ = 1.*

**Theorem 3.6** (Quantum Homomorphism). *Q(p + q) = Q(p) · Q(q). The quantum gate map is a group homomorphism from (ℝ², +) to (U(1), ·).*

**Theorem 3.7** (Classical Additivity). *I(p + q) = I(p) + I(q). The classical information map is a group homomorphism from (ℝ², +) to (ℝ, +).*

**Theorem 3.8** (Amplitude Multiplicativity). *A(p + q) = A(p) · A(q). The quantum amplitude map is a group homomorphism from (ℝ², +) to (ℝ₊, ·).*

**Theorem 3.9** (Composition Law). *(p + q).value = A(p) · A(q) + I(p) + I(q).* The EML value of a composed pair decomposes into the product of amplitudes plus the sum of information contents. This reveals the fundamental multiplicative-additive duality: quantum effects compose multiplicatively, classical effects compose additively.

### 3.3 Metric Structure

**Theorem 3.10** (Spectral Metric). *The EML spectral distance d is a metric:*
- *Symmetry: d(p, q) = d(q, p)*
- *Identity of indiscernibles: d(p, q) = 0 ⟺ p.θ = q.θ ∧ p.s = q.s*
- *Triangle inequality: d(p, r) ≤ d(p, q) + d(q, r)*

*Proof sketch for triangle inequality.* We reduce to the Euclidean triangle inequality in ℝ². Setting u = (θ_p − θ_q, s_p − s_q) and v = (θ_q − θ_r, s_q − s_r), we need ‖u + v‖ ≤ ‖u‖ + ‖v‖. This follows from the Cauchy-Schwarz inequality: (u₁v₂ − u₂v₁)² ≥ 0 implies (u·v)² ≤ ‖u‖²‖v‖², from which the Minkowski inequality follows. □

### 3.4 Convexity and Stability

**Theorem 3.11** (Strict Convexity). *The EML diagonal is strictly convex on (0, ∞).*

*Proof sketch.* The second derivative of eml_diag(x) = exp(x) − log(x) is exp(x) + 1/x², which is strictly positive on (0, ∞). Strict positivity of the second derivative on a convex open set implies strict convexity. □

**Theorem 3.12** (Continuity). *The EML diagonal is continuous on (0, ∞).*

### 3.5 Bridge Theorems

**Theorem 3.13** (Bridge Identity). *V(p) = A(p) + I(p).* The EML value equals the quantum amplitude plus the classical information content.

**Theorem 3.14** (Quantum Amplitude Floor). *For p with θ ≥ 0: A(p) ≥ 1.*

**Theorem 3.15** (EML Value Lower Bound). *For p with θ ≥ 0: V(p) ≥ 1 + I(p).*

**Theorem 3.16** (Injectivity). *If V(p) = V(q) and θ_p = θ_q, then s_p = s_q.* The classical channel is fully determined by the EML value and the phase.

### 3.6 Quantum Phase Properties

**Theorem 3.17** (Phase Periodicity). *The quantum phase map θ ↦ exp(iθ) is periodic with period 2π.*

**Theorem 3.18** (Phase Continuity). *The quantum phase map is continuous.*

**Theorem 3.19** (Neuron Unitarity). *For any quantum EML neuron N and input x: ‖N.quantumOutput(x)‖ = 1.*

**Theorem 3.20** (Neuron Continuity). *The classical output of any quantum EML neuron is continuous.*

## 4. PEGB Analysis

### 4.1 Spectral Gap Theorem (PEGB)

**Proof**: Complete Lean 4 proof using Real.add_one_lt_exp and Real.log_le_sub_one_of_pos.

**Example**: At x = 1: exp(1) − log(1) = e − 0 ≈ 2.718 > 2. At x = 0.5: exp(0.5) − log(0.5) ≈ 1.649 + 0.693 = 2.342 > 2.

**Generalization**: For x > 0 and any k ∈ ℕ, exp(x) − log(x) > 2. The bound 2 is tight in the sense that the infimum approaches but never reaches it. The true infimum involves the Lambert W function: min = exp(W(1)) − log(W(1)) ≈ 2.3327.

**Boundary**: At x → 0⁺: eml_diag(x) → +∞ (log term dominates). At x → +∞: eml_diag(x) → +∞ (exp term dominates). The function is not defined at x = 0 (log singularity). For x < 0, log(x) is undefined (returns 0 in Lean's convention), so eml_diag(x) = exp(x) for x ≤ 0.

### 4.2 Composition Law (PEGB)

**Proof**: Complete Lean 4 proof using Real.exp_add and algebraic manipulation.

**Example**: p = (1.0, 0.5), q = (0.5, −0.3). Then p + q = (1.5, 0.2). V(p+q) = exp(1.5) − 0.2 ≈ 4.282. A(p)·A(q) + I(p) + I(q) = e · e^0.5 + (−0.5) + 0.3 = e^1.5 − 0.2 ≈ 4.282. ✓

**Generalization**: For n spectral pairs p₁, ..., pₙ: V(∑pᵢ) = ∏A(pᵢ) + ∑I(pᵢ). This extends to infinite products via convergence conditions.

**Boundary**: When all phases are 0: V(∑pᵢ) = 1 + ∑I(pᵢ) (pure classical). When all logScales are 0: V(∑pᵢ) = ∏A(pᵢ) (pure quantum amplitude).

### 4.3 Strict Convexity (PEGB)

**Proof**: Via second derivative test: eml_diag''(x) = exp(x) + 1/x² > 0 on (0, ∞).

**Example**: At x = 1: eml_diag''(1) = e + 1 ≈ 3.718. At x = 0.1: eml_diag''(0.1) = exp(0.1) + 100 ≈ 101.1.

**Generalization**: The EML diagonal is not just strictly convex but *superconvex*: its second derivative grows exponentially, meaning the function becomes increasingly convex for large x.

**Boundary**: At x → 0⁺: eml_diag''(x) → +∞ (dominated by 1/x²). At x → ∞: eml_diag''(x) → ∞ (dominated by exp(x)). The second derivative has a minimum at the unique x₀ where exp(x₀) = 2/x₀³, approximately x₀ ≈ 0.72.

## 5. Conjecture

**Conjecture 5.1** (Quantum EML Universality). *For any ε > 0 and any continuous function f: [0, 1] → ℝ, there exist quantum EML neurons N₁, ..., Nₖ and weights α₁, ..., αₖ ∈ ℝ such that*

$$\sup_{x \in [0,1]} \left| f(x) - \sum_{i=1}^k \alpha_i V(N_i(x)) \right| < \varepsilon$$

**Testable prediction**: For f(x) = sin(2πx), a network of k = 10 quantum EML neurons should achieve ε < 0.01 on [0, 1]. This can be verified computationally by gradient descent training.

**Status**: Open. The classical output V(N(x)) = exp(w₁x + b₁) − (w₂x + b₂) is a difference of an exponential and a linear function. Since exponentials with varying frequencies can approximate any continuous function (by the universality of neural networks with exp activations), this conjecture is plausible.

## 6. Cross-Connection to Existing Results

Our work connects to the existing catalog theorem `quantum_classical_bound` in `Bridges/EMLTropicalSemiring.lean`, which establishes bounds on quantum-classical information exchange in the tropical semiring setting. The spectral gap theorem provides a tighter, more structured bound specific to the EML function.

The `eml_chain_exp_log_cancel` theorem in `EML/KolmogorovArnoldEMLDeep.lean` shows that exp and log are inverse operations in the EML chain. Our spectral pair formalism extends this by showing that even when exp and log do not cancel (the general case), their interaction is governed by the strict lower bound of 2.

## 7. Discussion

The EML Spectral Pair reveals a deep structural pattern: the EML activation function is not merely a convenient nonlinearity for neural networks — it is the natural mathematical object connecting multiplicative (quantum) and additive (classical) information processing.

The composition law V(p + q) = A(p)·A(q) + I(p) + I(q) is particularly suggestive. In thermodynamics, the partition function Z = ∑ exp(−βEᵢ) is multiplicative across independent subsystems, while entropy S = −∑ pᵢ log pᵢ is additive. The EML value mirrors this exact pattern, with quantum amplitude playing the role of the Boltzmann weight and classical information playing the role of entropy.

## 8. Future Work

1. Extension to matrix-valued spectral pairs for multi-qubit systems
2. Computation of the exact spectral gap minimum via Lambert W formalization
3. Proof of the universality conjecture for quantum EML neural networks
4. Connection to tropical semiring geometry via the max-plus limit
5. Application to quantum error correction codes

## References

[1] EML activation function theory. Catalog: `EML/EMLv17Core.lean`.

[2] Quantum-classical bounds. Catalog: `Bridges/EMLTropicalSemiring.lean`.

[3] EML chain cancellation. Catalog: `EML/KolmogorovArnoldEMLDeep.lean`.
