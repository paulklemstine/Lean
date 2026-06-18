# Max-Plus / Max-Times Stone–Weierstrass Bridge for EML Classes

## Abstract

We prove a universal approximation theorem showing that any family of continuous real-valued functions on a compact Hausdorff space that is closed under pointwise maximum, addition, negation, and contains all constant functions, and separates points, is uniformly dense in the space of all continuous functions. The proof is formally verified in Lean 4 with Mathlib. The key insight is that closure under maximum and negation implies closure under minimum via the identity $f \wedge g = -((-f) \vee (-g))$, converting a max-plus (tropical) algebraic structure into a lattice. Combined with a constructive two-point interpolation argument, this allows the application of the lattice Stone–Weierstrass theorem from Mathlib. We transport this result via the logarithm to obtain a max-times analogue for strictly positive function families, providing a rigorous semantic foundation for tropical neural networks and log-domain approximation architectures.

---

## 1. Introduction

The Stone–Weierstrass theorem is one of the most powerful tools in analysis and approximation theory, stating that subalgebras or sublattices of continuous functions on compact spaces that separate points are dense. In its algebraic form, it requires closure under multiplication—a condition not satisfied by many function classes arising in tropical mathematics and modern machine learning.

**Tropical (max-plus) algebra** replaces ordinary addition with maximum and ordinary multiplication with addition:
$$a \oplus b = \max(a, b), \quad a \odot b = a + b.$$
Function classes closed under these operations arise naturally in:
- Tropical geometry and optimization
- ReLU neural networks (which compute max-plus combinations of affine functions)
- Log-domain signal processing
- Idempotent analysis

The question arises: **do max-plus families have the same universal approximation power as classical subalgebras?**

We prove that the answer is yes, under mild conditions. The formal statement and proof are machine-verified in Lean 4.

## 2. Main Results

### 2.1 The Max-Plus Stone–Weierstrass Theorem

**Theorem** (Max-Plus Density). *Let $X$ be a compact Hausdorff space, and let $A \subseteq C(X, \mathbb{R})$ satisfy:*
1. *(Constants)* $\forall c \in \mathbb{R}, \; \text{const}_c \in A$
2. *(Max closure)* $\forall f, g \in A, \; f \vee g \in A$
3. *(Addition closure)* $\forall f, g \in A, \; f + g \in A$
4. *(Negation closure)* $\forall f \in A, \; -f \in A$
5. *(Point separation)* $\forall x \neq y \in X, \; \exists f \in A: f(x) \neq f(y)$

*Then $A$ is dense in $C(X, \mathbb{R})$ with respect to the supremum norm. Equivalently, for every $h \in C(X, \mathbb{R})$ and $\varepsilon > 0$, there exists $g \in A$ with $\|h - g\| < \varepsilon$.*

Note that **multiplication is not assumed**. This is the essential difference from the classical algebraic Stone–Weierstrass theorem.

### 2.2 The Max-Times Transport Theorem

**Theorem** (Max-Times Log-Domain Density). *Let $X$ be a compact Hausdorff space, and let $B$ be a family of strictly positive continuous functions on $X$ satisfying:*
1. *(Positive constants)* $\forall c > 0, \; \text{const}_c \in B$
2. *(Max closure)* $\forall f, g \in B, \; f \vee g \in B$
3. *(Multiplication closure)* $\forall f, g \in B, \; f \cdot g \in B$
4. *(Reciprocal closure)* $\forall f \in B, \; 1/f \in B$
5. *(Point separation)* $\forall x \neq y, \; \exists f \in B: f(x) \neq f(y)$

*Then the log-image $\{\log \circ f : f \in B\}$ is dense in $C(X, \mathbb{R})$.*

The log map converts max-times structure to max-plus structure:
- $\log(f \cdot g) = \log f + \log g$ (multiplication → addition)
- $\log(\max(f, g)) = \max(\log f, \log g)$ (max → max, by monotonicity)
- $\log(1/f) = -\log f$ (reciprocal → negation)
- $\log(c) = \text{const}_{\log c}$ (positive constants → all real constants)

### 2.3 Key Intermediate Results

**Lemma** (Inf from Sup and Negation). *For any $f, g \in C(X, \mathbb{R})$:*
$$f \wedge g = -((-f) \vee (-g)).$$
*Hence closure under $\sup$ and negation implies closure under $\inf$.*

**Theorem** (Strong Two-Point Interpolation). *Under the hypotheses of the max-plus theorem, $A$ satisfies the strong separation property: for any $x, y \in X$ and any target values $a, b \in \mathbb{R}$, there exists $g \in A$ with $g(x) = a$ and $g(y) = b$.*

This last result is the main technical contribution. It is proved constructively via a truncation trick: given a nonneg function $h \in A$ with $h(x) = 0$ and $h(y) = d > 0$, the function
$$g_s = \max(n \cdot h, \text{const}(nd - s)) - \text{const}(nd - s),$$
where $n = \lceil s/d \rceil$, satisfies $g_s(x) = 0$ and $g_s(y) = s$ for any $s \geq 0$.

## 3. Proof Architecture

The proof proceeds in five stages:

### Stage 1: Lattice closure
From max closure and negation closure, derive min closure via the identity $f \wedge g = -((-f) \vee (-g))$.

### Stage 2: Nonneg separating functions
Given $x \neq y$, use the separating function $f$ to construct $h \in A$ with $h(x) = 0$, $h(y) > 0$, and $h \geq 0$ pointwise. This uses translation by constants and the max with zero.

### Stage 3: Arbitrary nonneg interpolation
Given $h$ as above and any target $s \geq 0$, construct $g \in A$ with $g(x) = 0$ and $g(y) = s$. This is the truncation trick: scale $h$ up by $n = \lceil s/d \rceil$, then subtract the excess via max with a constant.

### Stage 4: Full two-point interpolation
For arbitrary target values $a, b$ at points $x, y$:
- Construct $g_1$ with $g_1(x) = 0$, $g_1(y) = \max(b-a, 0)$
- Construct $g_2$ with $g_2(y) = 0$, $g_2(x) = \max(a-b, 0)$
- Set $g = g_1 + g_2 + \text{const}(\min(a, b))$

This gives $g(x) = a$ and $g(y) = b$.

### Stage 5: Apply lattice Stone–Weierstrass
The family $A$ is nonempty, closed under sup and inf, and satisfies strong point separation. By Mathlib's `ContinuousMap.sublattice_closure_eq_top`, the closure of $A$ equals the whole space.

### Log transport (for max-times)
The log-image inherits all max-plus properties from the max-times structure, so the max-plus theorem applies directly.

## 4. Formal Verification

The complete proof is formalized in Lean 4 with Mathlib, contained in the file `Catalog/EML/MaxPlusStoneWeierstrass.lean`. The key formal declarations are:

| Theorem | Lean Name |
|---------|-----------|
| Inf from sup+neg | `closedUnder_inf_of_sup_neg` |
| Nonneg separation | `exists_mem_zero_pos` |
| Nonneg interpolation | `exists_mem_zero_nonneg_target` |
| Strong separation | `separatesPointsStrongly_of_maxPlus` |
| Max-plus density | `dense_of_maxPlus` |
| Max-plus ε-approx | `approx_of_maxPlus` |
| Log-mul = add | `logPosC_mul` |
| Log-max = max | `logPosC_sup` |
| Max-times log density | `dense_of_maxTimes_log` |
| Max-times log ε-approx | `approx_of_maxTimes_log` |

The proof uses no axioms beyond the standard Lean/Mathlib axioms (`propext`, `Classical.choice`, `Quot.sound`). The file compiles without `sorry` or `axiom` declarations.

## 5. Applications

### 5.1 ReLU Neural Networks
A ReLU network computes functions of the form $\max(0, w \cdot x + b)$. The max-plus closure of affine functions and ReLU activations generates all piecewise linear functions. Our theorem provides a formal proof that this class is dense in $C(X, \mathbb{R})$ for compact $X$—a rigorous foundation for the universal approximation property of ReLU networks.

### 5.2 Tropical Neural Networks
In the tropical semiring, neural network layers compute max-plus combinations of inputs. The max-times variant applies to multiplicative architectures operating in log-domain. Our theorem shows that such tropical architectures are universal approximators after log-coordinate transport.

### 5.3 Log-Domain Signal Processing
In audio and speech processing, log-domain representations (mel-spectrograms, log-power spectra) are ubiquitous. Operations in log-domain correspond to max-times operations in the original domain. Our theorem guarantees that max-times families can approximate any positive signal in log-domain.

### 5.4 Certified Robustness
The formal verification ensures that the approximation guarantee is mathematically airtight. This is relevant for safety-critical applications where the approximation properties of neural network architectures must be certified.

## 6. Discussion: Why Max-Plus is Enough

### A Scientific American-style explanation

Imagine you're an architect designing buildings using only two tools: a ruler that can add lengths, and a stencil that picks the larger of two measurements. Classical mathematics tells us that to approximate any shape, we need multiplication—the ability to scale measurements. This is the content of the Stone–Weierstrass theorem, one of the great theorems of 19th-century analysis.

Our result overturns this conventional wisdom. We show that addition and maximum—without multiplication—are already sufficient for universal approximation. The key insight is beautifully simple: if you can compute maximums and flip signs, you can compute minimums too. The minimum of two values equals the negative of the maximum of their negatives: $\min(a, b) = -\max(-a, -b)$.

This transforms our "tropical" toolkit (max + add + negate) into a complete lattice toolkit (max + min), which the lattice version of Stone–Weierstrass already tells us is universal. The formal proof fills in the technical gap: we need to show that max-plus operations can achieve arbitrary two-point interpolation, which requires a clever "truncation trick" where we scale a function up and then clip it using max with a constant.

The practical significance is profound. Modern AI systems like deep neural networks with ReLU activations compute exactly these operations: addition of weighted inputs and taking the maximum with zero. Our theorem provides a rigorous mathematical guarantee that such architectures can approximate any continuous function—and this guarantee is machine-verified to mathematical certainty.

### Historical context
The original Stone–Weierstrass theorem (1937) requires a subalgebra (closed under multiplication). The lattice version, due to Kakutani (1941) and later refined by others, relaxes this to sublattice closure but requires strong point separation. Our contribution is showing that max-plus structure—which naturally arises in tropical mathematics and neural networks—implies strong separation, completing the bridge.

### Connection to tropical geometry
In tropical geometry, the "tropical semiring" $(\mathbb{R} \cup \{-\infty\}, \max, +)$ replaces the usual field $(\mathbb{R}, +, \times)$. Our theorem shows that the functional analysis of the tropical semiring is as powerful as classical analysis for approximation purposes. This suggests deep connections between tropical geometry and approximation theory that deserve further exploration.

## 7. Future Directions

1. **Quantitative bounds**: The Stone–Weierstrass theorem is inherently non-constructive in terms of approximation rates. Deriving explicit approximation rates for specific max-plus families (e.g., tropical polynomials of bounded degree) would be valuable.

2. **Non-compact domains**: Extending the result to locally compact or σ-compact spaces with appropriate growth conditions.

3. **Higher-order structure**: Investigating the interplay between max-plus closure and Sobolev-type smoothness constraints.

4. **Computational complexity**: Characterizing the complexity of max-plus approximation (number of operations needed to achieve ε-approximation) as a function of the target function's regularity.

5. **Tropical deep learning**: Using the formal framework to verify properties of tropical neural network architectures, including depth-width tradeoffs.

## References

- M.H. Stone, "The Generalized Weierstrass Approximation Theorem," *Mathematics Magazine*, 1948.
- S. Kakutani, "Concrete Representation of Abstract (L)-Spaces and the Mean Ergodic Theorem," *Annals of Mathematics*, 1941.
- Mathlib Contributors, "Mathlib: A Unified Library of Mathematics Formalized in Lean 4," https://leanprover-community.github.io/mathlib4_docs/

---

*This paper accompanies the Lean 4 formal verification in `Catalog/EML/MaxPlusStoneWeierstrass.lean`.*
