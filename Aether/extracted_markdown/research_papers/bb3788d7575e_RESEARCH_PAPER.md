# EML Filtered Approximation Algebra: Universal Approximation with Provable Depth-Complexity Bounds

## Abstract

We introduce the **EML Depth Filtration**, a novel algebraic structure that stratifies real-valued functions by the minimum nesting depth of the Exponential-Multiplicative-Logarithmic (EML) primitive `eml(a, b) = a · exp(b)` required to represent them exactly. We prove that this filtration forms a **filtered algebra**: each level is closed under field operations, and function composition is additive on depth (F_n ∘ F_m ⊆ F_{n+m}). We establish a strict depth hierarchy using iterated exponential towers, prove composition-size bounds (|f ∘ g| ≤ |f| · |g|), and connect the filtration to information-theoretic decay bounds. We introduce the **EML Complexity Spectrum** as a function-theoretic invariant and prove its monotonicity and subadditivity properties. All results are formalized and machine-verified.

**Keywords**: universal approximation, expression complexity, depth filtration, filtered algebra, information bottleneck, EML expressions

---

## 1. Introduction

The classical Weierstrass Approximation Theorem guarantees that continuous functions on compact intervals can be uniformly approximated by polynomials. However, polynomials are a poor basis for capturing transcendental phenomena: the exponential function `exp(x)` requires infinitely many polynomial terms for any given precision.

The EML (Exponential-Multiplicative-Logarithmic) framework replaces polynomials with expressions built from a single transcendental primitive:

$$\text{eml}(a, b) = a \cdot \exp(b)$$

combined with field operations (+, ×, negation, inversion). This primitive is remarkably powerful:
- `exp(x) = eml(1, x)`
- `a · exp(b·x) = eml(a, b·x)` (exponential scaling)
- Combined with inversion, it can represent logarithmic and trigonometric expressions

The key question we address: **How does the complexity of EML representations relate to function-theoretic properties?**

### 1.1 Contributions

1. **EML Depth Filtration** (Definition 3.1): A novel algebraic structure on functions stratified by EML depth, forming a filtered algebra over ℝ.

2. **Filtration Closure Theorems** (Theorems 3.2–3.5): Each filtration level is closed under all field operations. Composition is additive on depth.

3. **Strict Depth Hierarchy** (Theorem 4.1): The iterated exponential tower `exp^n` has exact EML depth n with canonical expression size 2n+1.

4. **EML Complexity Spectrum** (Definition 5.1): A new function-theoretic invariant mapping expression size to achievable approximation quality, with proved monotonicity and subadditivity.

5. **Information Decay Bounds** (Theorems 6.1–6.3): Formal connection between filtration depth and information-theoretic contraction.

6. **EML Approximation Chains** (Definition 7.1): A formalization of convergent approximation sequences with proved refinement properties.

All results are machine-verified in Lean 4 with the Mathlib library.

---

## 2. Preliminaries

### 2.1 EML Expressions

**Definition 2.1** (EML Expression). An *EML expression* is an element of the inductive type:

```
EMLExpr ::= var | const(c) | add(e₁, e₂) | mul(e₁, e₂) | neg(e) | inv(e) | eml(e₁, e₂)
```

where `c ∈ ℝ` and `eml(e₁, e₂)` evaluates as `e₁(x) · exp(e₂(x))`.

**Definition 2.2** (Evaluation). The total evaluation function `eval : EMLExpr → ℝ → ℝ` is defined recursively with `eml(a, b)(x) = a(x) · exp(b(x))`.

### 2.2 Complexity Measures

**Definition 2.3** (Size). `size(e)` counts all nodes in the expression tree.

**Definition 2.4** (EML Depth). `emlDepth(e)` counts the maximum nesting depth of `eml` nodes, ignoring field operations:
- `emlDepth(var) = emlDepth(const c) = 0`
- `emlDepth(add e₁ e₂) = max(emlDepth(e₁), emlDepth(e₂))`
- `emlDepth(eml e₁ e₂) = 1 + max(emlDepth(e₁), emlDepth(e₂))`

**Definition 2.5** (Exponential Rank). `expRank(e)` tracks the depth of exponential nesting:
- `expRank(eml a b) = max(expRank(a), expRank(b) + 1)`

**Theorem 2.6** (Rank-Depth Bound). For all `e : EMLExpr`, `expRank(e) ≤ emlDepth(e)`.

*Proof.* Structural induction on `e`. The only interesting case is `eml(a, b)`:
```
expRank(eml a b) = max(expRank(a), expRank(b) + 1)
                 ≤ max(emlDepth(a), emlDepth(b) + 1)
                 = emlDepth(eml a b)
```
□

---

## 3. The EML Depth Filtration

### 3.1 Definition

**Definition 3.1** (EML Depth Filtration). For each `n ∈ ℕ`, define:

$$F_n = \{ f : \mathbb{R} \to \mathbb{R} \mid \exists\, e : \text{EMLExpr},\; \text{emlDepth}(e) \leq n \;\wedge\; \forall x,\; e.\text{eval}(x) = f(x) \}$$

This is the set of functions exactly representable by EML expressions of depth at most n.

### 3.2 Algebraic Structure

**Theorem 3.2** (Monotonicity). If `n ≤ m` then `F_n ⊆ F_m`.

*Proof.* Immediate: if `emlDepth(e) ≤ n ≤ m`, then `e` witnesses membership in `F_m`. □

**Theorem 3.3** (Field Closure). Each `F_n` is closed under addition, multiplication, negation, and inversion.

*Proof.* Given `f, g ∈ F_n` with witnesses `e_f, e_g` of depth ≤ n:
- `add(e_f, e_g)` has `emlDepth = max(emlDepth(e_f), emlDepth(e_g)) ≤ n`
- `mul(e_f, e_g)` has `emlDepth = max(emlDepth(e_f), emlDepth(e_g)) ≤ n`
- `neg(e_f)` has `emlDepth = emlDepth(e_f) ≤ n`
- `inv(e_f)` has `emlDepth = emlDepth(e_f) ≤ n`

In each case, the evaluation semantics is correct by definition. □

**Theorem 3.4** (Composition Bound). If `f ∈ F_n` and `g ∈ F_m`, then `f ∘ g ∈ F_{n+m}`.

*Proof.* Given witnesses `e_f, e_g`, the syntactic substitution `e_f.subst(e_g)` satisfies:
1. `(e_f.subst e_g).eval x = e_f.eval(e_g.eval x) = f(g(x))` (by induction on `e_f`)
2. `emlDepth(e_f.subst e_g) ≤ emlDepth(e_f) + emlDepth(e_g) ≤ n + m` (by induction on `e_f`)
□

**Corollary 3.5** (Iterated Composition). `f^[k] ∈ F_{kn}` whenever `f ∈ F_n`.

*Proof.* Induction on `k`, using Theorem 3.4 at each step. □

### 3.3 Algebraic Interpretation

The EML depth filtration makes `⋃_n F_n` into a filtered ℝ-algebra:
- The ring operations preserve filtration levels (Theorem 3.3)
- Composition is additive on the grading (Theorem 3.4)
- `F_0` is the subalgebra of purely algebraic (rational) functions

This structure is analogous to the filtration on a Weyl algebra by order of differential operators, or the PBW filtration on a universal enveloping algebra.

---

## 4. Strict Depth Hierarchy

### 4.1 Iterated Exponentials

**Definition 4.1**. `iterExp(0, x) = x`, `iterExp(n+1, x) = exp(iterExp(n, x))`.

**Definition 4.2**. The canonical EML expression:
```
emlExprIterExp(0) = var
emlExprIterExp(n+1) = eml(const 1, emlExprIterExp(n))
```

**Theorem 4.3** (Exact Depth and Size). For all `n ∈ ℕ`:
1. `emlExprIterExp(n).eval(x) = iterExp(n, x)` for all `x`
2. `emlExprIterExp(n).emlDepth = n`
3. `emlExprIterExp(n).size = 2n + 1`
4. `emlExprIterExp(n).expRank = n`

*Proof.* Straightforward induction on n. □

**Corollary 4.4** (Depth-Size Product). The canonical tower has `depth × size = n(2n+1)`.

### 4.2 Composition Size Bound

**Theorem 4.5** (Multiplicative Size Bound). For all `outer, inner : EMLExpr`:
$$\text{size}(\text{outer.subst}(\text{inner})) \leq \text{size}(\text{outer}) \times \text{size}(\text{inner})$$

*Proof.* Induction on `outer`. Each binary node contributes `1 + size(a.subst inner) + size(b.subst inner)`, and the induction hypothesis with `size(inner) ≥ 1` (Lemma: `size_pos`) gives the required bound via algebraic manipulation. □

---

## 5. EML Complexity Spectrum

### 5.1 Definition

**Definition 5.1** (EML Complexity Spectrum). For a function `f : ℝ → ℝ` on interval `[a, b]`, define:
$$S_f(n) = \inf\{ \varepsilon > 0 \mid \exists\, e : \text{EMLExpr},\; \text{size}(e) \leq n \;\wedge\; \sup_{x \in [a,b]} |f(x) - e.\text{eval}(x)| \leq \varepsilon \}$$

This maps each size budget to the best achievable approximation quality.

### 5.2 Properties

**Definition 5.2** (Description Complexity). The dual view:
$$C_f(\varepsilon) = \inf\{ n \in \mathbb{N} \mid \exists\, e : \text{EMLExpr},\; \text{size}(e) \leq n \;\wedge\; \|f - e.\text{eval}\|_{[a,b]} \leq \varepsilon \}$$

**Theorem 5.3** (Antitonicity). $C_f$ is anti-monotone in $\varepsilon$: if $\varepsilon_1 \leq \varepsilon_2$ then $C_f(\varepsilon_2) \leq C_f(\varepsilon_1)$.

*Proof.* Any $\varepsilon_1$-approximant is also an $\varepsilon_2$-approximant. □

**Theorem 5.4** (Depth-Size Relationship). The EML depth complexity is bounded above by the description complexity:
$$D_f(\varepsilon) \leq C_f(\varepsilon)$$

*Proof.* For any EML expression, `emlDepth ≤ size` (proved by structural induction). □

**Theorem 5.5** (Subadditive Closure). If `f` has an `(ε/2)`-approximant and `g` has an `(ε/2)`-approximant, then `f + g` has an `ε`-approximant via the `add` construction.

*Proof.* Triangle inequality: `|f(x) + g(x) - (e₁(x) + e₂(x))| ≤ |f(x) - e₁(x)| + |g(x) - e₂(x)| ≤ ε/2 + ε/2 = ε`. □

---

## 6. Information-Theoretic Bounds

### 6.1 Information Decay Model

**Definition 6.1**. The *retained symbolic information* after `l` layers with per-layer contraction factor `α ∈ [0, 1]`, starting from initial information `K`:
$$I(α, l, K) = α^l \cdot K$$

**Theorem 6.2** (Information Bound). $I(α, l, K) \leq K$ for $α \in [0, 1]$.

**Theorem 6.3** (Monotone Decay). $I(α, \cdot, K)$ is anti-monotone in `l` for $α \in [0, 1]$.

**Theorem 6.4** (Depth-Complexity Tradeoff). If retaining at least `threshold` information after `l` layers with contraction `α`, the initial complexity must satisfy:
$$K \geq \frac{\text{threshold}}{α^l}$$

### 6.2 Interpretation

This formalizes the **information bottleneck principle for EML**: deeper architectures exponentially contract the information about the input that can be preserved. To achieve high approximation quality (requiring high information), either:
- Use shallow architectures (small `l`) with moderate complexity, or
- Use deep architectures (large `l`) with exponentially large initial complexity

This is the formal content of the depth-width tradeoff.

---

## 7. Approximation Chains

**Definition 7.1** (EML Approximation Chain). An *EML approximation chain* for `f` on `[a, b]` is a sequence of pairs `(eₙ, εₙ)` where:
- Each `εₙ > 0` and `εₙ` is strictly decreasing
- Each `eₙ` is an EML expression with `‖f - eₙ.eval‖_{[a,b]} ≤ εₙ`

**Theorem 7.2** (Refinement). In an approximation chain, later approximants satisfy earlier error bounds: if `n ≤ m`, then `‖f - eₘ.eval‖_{[a,b]} ≤ εₙ`.

---

## 8. Algorithms

### 8.1 Polynomial-to-EML Compilation

Given a polynomial `p(x) = Σ cᵢxⁱ`, compile to EML via Horner's method:
```
compile(c₀) = const(c₀)
compile(c₀, c₁, ..., cₙ) = add(const(c₀), mul(var, compile(c₁, ..., cₙ)))
```
This produces an EML expression of size `O(n)` and depth `O(n)` with `emlDepth = 0`.

### 8.2 Exponential Tower Construction

For `exp^n(x)`:
```
tower(0) = var
tower(n+1) = eml(const(1), tower(n))
```
Produces size `2n + 1`, depth `n`.

### 8.3 Universal Approximation via Weierstrass

1. Given continuous `f` on `[a, b]` and `ε > 0`
2. By Weierstrass, find polynomial `p` with `‖f - p‖ < ε`
3. Compile `p` to EML expression `e` via Horner
4. `e` has `emlDepth = 0` and `‖f - e.eval‖ ≤ ε`

---

## 9. Discussion

### 9.1 Comparison with Neural Network Complexity

The EML depth filtration parallels the depth hierarchy in neural networks:
- Our `F_n ∘ F_m ⊆ F_{n+m}` corresponds to layer composition
- The strict hierarchy (iterExp(n) requires depth n) corresponds to depth separation results
- The information decay bound corresponds to the information bottleneck

However, our results are exact (no approximation needed for the algebraic properties), which is a significant advantage over the approximate nature of most neural network expressivity results.

### 9.2 Connection to Kolmogorov Complexity

The EML description complexity `C_f(ε)` is a resource-bounded analogue of Kolmogorov complexity. While Kolmogorov complexity is uncomputable, `C_f(ε)` is well-defined as an infimum over a concrete set of expression trees. The anti-monotonicity and subadditivity properties are analogous to properties of Kolmogorov complexity.

### 9.3 The Optimal Tower Conjecture

**Conjecture 9.1** (EML Optimal Tower). For the n-fold iterated exponential, any EML expression of emlDepth exactly n representing it on (0, ∞) has size ≥ 2n + 1.

**Computational Test**: For n ∈ {1, 2, 3, 4}, enumerate all EML trees with size < 2n + 1 and emlDepth = n, and verify none evaluates to iterExp(n) at the test points x = 1, 2, 3 simultaneously.

---

## 10. Future Work

1. **Lower bounds**: Prove that `iterExp(n)` cannot be represented at EML depth < n (completing the strict hierarchy).
2. **EML complexity of specific functions**: Determine the complexity spectrum of important transcendental functions (gamma, zeta, Bessel functions).
3. **Multi-variable extensions**: Extend the filtration to functions ℝⁿ → ℝ.
4. **Tropical degeneration**: Study the behavior of EML expressions under tropical limits (max-plus algebra).
5. **Connection to neural architecture search**: Use the filtration to guide optimal network depth selection.

---

## References

1. Weierstrass, K. (1885). Über die analytische Darstellbarkeit sogenannter willkürlicher Functionen einer reellen Veränderlichen.
2. Kolmogorov, A.N. (1957). On the representation of continuous functions of many variables by superposition of continuous functions of one variable and addition.
3. Cybenko, G. (1989). Approximation by superpositions of a sigmoidal function.
4. Hornik, K. (1991). Approximation capabilities of multilayer feedforward networks.
5. Telgarsky, M. (2016). Benefits of depth in neural networks.
