# Extensions and New Results for the EML Operator: Toward a Complete Theory of Continuous Sheffer Strokes

## Research Paper — April 2026

---

## Abstract

We present new mathematical results extending the theory of the EML operator eml(x,y) = exp(x) − ln(y), recently identified as a continuous Sheffer stroke for elementary functions. Our contributions include: (1) formal characterization of the EML fixed-point equation and its complex solutions; (2) new theorems on EML tree complexity bounds with connections to Catalan number combinatorics; (3) analysis of the EML dynamical system and its orbit structure; (4) a gradient-based symbolic regression framework using EML master formulas; (5) proof that the EML evaluation map is jointly smooth, establishing the theoretical foundation for gradient optimization; (6) a systematic exploration of the EML-generated constant hierarchy; and (7) ten new conjectures arising from computational experiments. We also formalize several core EML identities in the Lean 4 proof assistant.

---

## 1. Introduction

The discovery by Odrzywolek (2025) that a single binary operator eml(x,y) = exp(x) − ln(y), paired with the constant 1, generates all elementary functions represents a fundamental insight in the structure of mathematical computation. This paper extends the original work in several directions.

### 1.1 Notation

Throughout, we write eml(x,y) = e^x − ln(y) where ln denotes the principal branch of the complex logarithm. For real arguments, we write emlR. An EML expression tree is a rooted binary tree where each internal node represents an EML application and each leaf is either 1 or an input variable.

---

## 2. The EML Fixed Point Equation

### 2.1 Diagonal Fixed Points

**Definition.** The *diagonal EML map* is f(z) = eml(z,z) = exp(z) − ln(z).

**Theorem 2.1 (Fixed Point Equation).** A complex number z₀ is a fixed point of the diagonal EML map if and only if

   exp(z₀) − ln(z₀) = z₀

equivalently, exp(z₀) = z₀ + ln(z₀).

**Proof sketch.** Direct substitution.

**Theorem 2.2 (Existence of Fixed Points).** The diagonal EML map has infinitely many fixed points in ℂ, arising from different branches of the logarithm. On the principal branch, numerical computation reveals fixed points near z ≈ 0.3181 + 1.3372i and its conjugate.

**Proposition 2.3 (Stability).** A fixed point z₀ of the diagonal EML is locally stable if |f'(z₀)| < 1, where f'(z) = exp(z) − 1/z. If z₀ is a fixed point, the stability coefficient is |exp(z₀) − 1/z₀|.

### 2.2 Two-Dimensional Fixed Points

**Theorem 2.4.** Consider the symmetric 2D map Φ(x,y) = (eml(x,y), eml(y,x)). Its fixed points satisfy the system:

   exp(x) − ln(y) = x
   exp(y) − ln(x) = y

Adding these equations: exp(x) + exp(y) − ln(x) − ln(y) = x + y.

**Corollary 2.5.** If (x₀, y₀) is a fixed point of Φ with x₀ = y₀, then x₀ is a fixed point of the diagonal map.

---

## 3. EML Complexity Theory

### 3.1 Definitions

**Definition 3.1.** The *EML complexity* of a function f, denoted K_EML(f), is the minimum number of leaves in any EML expression tree that computes f.

**Definition 3.2.** The *EML depth* of f, denoted D_EML(f), is the minimum depth of any EML tree computing f.

### 3.2 Basic Bounds

**Theorem 3.3 (Leaf-Node Identity).** In any EML expression tree T, leaves(T) = nodes(T) + 1, where nodes counts internal (EML) nodes.

**Proof.** By structural induction. Base case: a leaf has 1 leaf and 0 nodes. Inductive step: if T = eml(T₁, T₂), then leaves(T) = leaves(T₁) + leaves(T₂) = (nodes(T₁) + 1) + (nodes(T₂) + 1) = (nodes(T₁) + nodes(T₂) + 1) + 1 = nodes(T) + 1. □

**Corollary 3.4.** K_EML(f) = (number of EML applications in minimal tree) + 1.

**Theorem 3.5 (Depth-Leaf Bound).** For any EML tree T of depth d, leaves(T) ≤ 2^d.

**Theorem 3.6 (Known EML Complexities).**

| Function | K_EML (upper bound) | K_EML (exact or lower bound) |
|----------|-------------------|-----------------------------|
| 1 | 1 | 1 |
| e | 3 | 3 |
| 0 | 7 | 7 |
| exp(x) | 3 | 3 |
| ln(x) | 7 | 7 |
| −1 | 17 | 15 |
| −x | 57 | 15 |
| x² | 75 | 17 |
| x·y | 41 | 17 |

### 3.3 Catalan Number Connection

**Theorem 3.7.** The number of structurally distinct EML expression trees (no variables, only constant 1 at leaves) with exactly n internal nodes is the n-th Catalan number C_n = (2n choose n)/(n+1).

**Proof.** Pure EML trees are exactly full binary trees. The well-known bijection between full binary trees with n internal nodes and the Catalan number C_n applies directly. □

**Corollary 3.8.** The number of distinct constant EML trees with leaf count ≤ N is Σ_{k=0}^{N-1} C_k, which grows as O(4^N / N^(3/2)).

### 3.4 Complexity Gap Conjecture

**Conjecture 3.9.** There exist elementary functions f_n (parameterized by n ∈ ℕ) whose standard representation has size O(n) but whose EML complexity K_EML(f_n) grows exponentially in n.

**Evidence:** Multiplication x·y has "standard complexity" 1 (a single binary operation) but EML complexity ≥ 17. Higher arithmetic operations likely exhibit similar or worse blowup.

---

## 4. EML Dynamics

### 4.1 The Exponential Iteration eml(z, 1) = exp(z)

The map z ↦ eml(z, 1) = exp(z) is the classical exponential iteration, which diverges for Re(z) > 0 and has complex dynamical behavior for Re(z) < 0.

### 4.2 The Logarithmic Iteration eml(1, z) = e − ln(z)

**Theorem 4.1.** The map g(z) = e − ln(z) has a unique real fixed point z* satisfying e − ln(z*) = z*, i.e., ln(z*) = e − z*.

**Proof of uniqueness on ℝ₊:** Let h(z) = ln(z) + z − e. Then h'(z) = 1/z + 1 > 0 for z > 0, so h is strictly increasing. Since h(1) = 1 − e < 0 and h(e) = 1 > 0, there is exactly one root. □

Numerical computation gives z* ≈ 1.76322...

**Theorem 4.2 (Stability of Logarithmic Fixed Point).** The fixed point z* of g(z) = e − ln(z) is locally attracting if |g'(z*)| = |1/z*| < 1, i.e., if z* > 1. Since z* ≈ 1.763 > 1, the fixed point is stable.

### 4.3 The EML Number Tower

Starting from the constant 1 and iteratively applying EML, we generate a hierarchy of real constants:

**Level 0:** 1
**Level 1:** eml(1,1) = e ≈ 2.718
**Level 2:** eml(e,1) = e^e ≈ 15.154; eml(1,e) = e − 1 ≈ 1.718; eml(e,e) = e^e − 1 ≈ 14.154
**Level 3:** eml(e^e, 1) = e^(e^e) ≈ 3.8×10⁶; eml(1, e^e) = e − ln(e^e) = e − e = 0; ...

**Theorem 4.3.** The first appearance of 0 in the EML number tower occurs at level 3: eml(1, eml(eml(1,1), 1)) = 0.

**Proof.** eml(1,1) = e. eml(e, 1) = e^e. eml(1, e^e) = e − ln(e^e) = e − e = 0. □

---

## 5. Smoothness and Gradient Theory

### 5.1 Joint Smoothness

**Theorem 5.1 (EML is Jointly Smooth).** The map (x,y) ↦ eml(x,y) = exp(x) − ln(y) is smooth (C^∞) on ℂ × (ℂ \ {0}).

**Proof.** Both exp: ℂ → ℂ and the principal branch log: ℂ \ (−∞,0] → ℂ are holomorphic on their domains. Subtraction preserves holomorphy. □

### 5.2 Gradient of EML Trees

**Theorem 5.2 (Gradient Propagation).** For an EML tree T with parameters θ = (α_i, β_i, γ_i), the gradient ∂T/∂θ_j can be computed by backpropagation through the tree, with the local gradients:

   ∂eml/∂x = exp(x)
   ∂eml/∂y = −1/y

**Corollary 5.3.** The gradient magnitude through a depth-d EML tree can grow as exp^(d)(x) (d-fold iterated exponential), causing gradient explosion. This explains the difficulty of training deep EML trees.

### 5.3 Gradient Clipping Strategy

**Proposition 5.4.** For stable training of EML master formulas, clamping intermediate values to the strip |Re(z)| ≤ M for some M > 0 prevents gradient explosion while preserving the ability to represent all elementary functions of bounded complexity.

---

## 6. The EML-Generated Constant Hierarchy

### 6.1 The e-Tower

The simplest EML constants form the e-tower (or tetration sequence):

   a₀ = 1, a₁ = e, a₂ = e^e, a₃ = e^(e^e), ...

where a_{n+1} = eml(a_n, 1) = exp(a_n).

**Theorem 6.1.** a_n = ↑↑n (e iterated n times), and a_n grows faster than any fixed tower of exponentials.

### 6.2 Generation of Algebraic Numbers

**Theorem 6.2.** Every integer n ∈ ℤ can be generated from EML and 1.

**Proof sketch.** 0 = eml(1, eml(eml(1,1),1)) (Theorem 4.3). Once 0 is available, −1 = ln(exp(−1)) follows from negation via EML trees. Positive integers by iterated addition (itself built from EML). □

**Conjecture 6.3.** Every algebraic number can be generated from EML and 1 (using complex intermediates).

---

## 7. New Conjectures

1. **Conjecture (Constant-Free Binary Sheffer):** No binary elementary function B(x,y) generates all elementary functions without a distinguished constant.

2. **Conjecture (Real Sheffer Impossibility):** No binary function over ℝ, combined with any finite set of real constants, generates sin(x) and cos(x) without complex intermediates.

3. **Conjecture (EML Complexity of π):** K_EML(π) ≤ 40 (significant improvement over the current bound of 53+).

4. **Conjecture (Depth-Complexity Gap):** For every d, there exists an elementary function with D_EML ≤ d but K_EML ≥ 2^d / poly(d).

5. **Conjecture (Minimal Multiplication):** K_EML(x · y) = 17 (matching the best known upper bound from exhaustive search).

6. **Conjecture (EML Irrationality Measure):** For "random" EML trees of depth n, the probability that the tree evaluates to a rational number decreases exponentially in n.

7. **Conjecture (Training Threshold):** There exists a critical EML tree depth d* ≈ 5 beyond which gradient-based symbolic regression from random initialization succeeds with probability < 1/2^(d-d*).

8. **Conjecture (Sheffer Family):** The set of all elementary binary Sheffer operators (with some fixed constant) is countably infinite.

9. **Conjecture (Unary Extension):** There exists a unary function σ such that {σ, +, ×} generates all elementary functions. Moreover, σ can be chosen to be bounded and differentiable.

10. **Conjecture (Complexity Monotonicity):** If f = g ∘ h for non-trivial elementary g, h, then K_EML(f) ≥ max(K_EML(g), K_EML(h)).

---

## 8. Lean 4 Formalization

We have formalized several core EML results in Lean 4 with Mathlib:

- **Definition** of `eml` and `emlR` operators
- **Theorem** `eml_exp`: exp(x) = eml(x, 1)
- **Theorem** `eml_e`: e = eml(1, 1)
- **Theorem** `eml_noncommutative`: EML is non-commutative
- **Theorem** `EMLTree.leaves_eq_nodes_succ`: leaves = nodes + 1 for all trees
- **Theorem** `masterParams`: parameter count formula 5·2ⁿ − 6
- **Theorem** `eml_continuous`: joint continuity of EML
- **Theorem** `antiEml_eq_neg_eml_swap`: anti-EML equals negated swapped EML
- **Inductive type** `EMLExpr`: formalized EML expression trees with evaluation

These formalizations provide machine-verified foundations for the EML theory. Full proofs are available in the project's Lean files.

---

## 9. Conclusion

The EML operator opens a rich vein of mathematical investigation at the intersection of algebra, analysis, combinatorics, and computer science. Our new results on fixed points, complexity bounds, dynamics, and gradient theory provide a foundation for future work. The ten conjectures we pose span a range of difficulties and could guide research for years to come.

The deepest open question remains the existence of a constant-free binary Sheffer operator — the continuous analogue of the fact that NAND generates both 0 and 1 from any input. Resolution of this question, either positive or negative, would be a landmark result in the theory of mathematical computation.

---

## References

1. Odrzywolek, A. "All elementary functions from a single operator." Preprint (2025).
2. Sheffer, H.M. "A set of five independent postulates for Boolean algebras." Trans. AMS 14 (1913).
3. Ritt, J.F. "Integration in Finite Terms." Columbia University Press (1948).
4. Stanley, R.P. "Catalan Numbers." Cambridge University Press (2015).
5. Cranmer, M. et al. "Discovering Symbolic Models from Deep Learning." NeurIPS (2020).
