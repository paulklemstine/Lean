# Multiplicative Subadditivity of EML Description Complexity

## Abstract

We establish that the description complexity of finite products of bounded functions is multiplicatively subadditive: the minimum expression tree size needed to uniformly approximate a product is bounded by the sum of the complexities of the individual factors at a rescaled tolerance, plus the number of multiplication gates. Our main results include (1) a quantitative product perturbation bound showing that if each factor changes by at most δ, the product changes by at most k · B^(k-1) · δ, (2) a binary multiplicative subadditivity theorem, (3) its generalization to k-fold products, and (4) a power function complexity bound. All results are formalized and machine-verified in Lean 4 with Mathlib, using no axioms beyond the standard foundations (propext, Classical.choice, Quot.sound). These theorems establish the foundations of a compositional complexity calculus for function approximation.

## 1. Introduction

### 1.1 Motivation

The question of how efficiently a function can be approximated by structured expressions is central to approximation theory, computational complexity, and machine learning. While classical results (Stone-Weierstrass, Jackson's theorem, Kolmogorov's superposition theorem) address the *existence* of approximations, quantitative bounds on the *cost* of approximation under algebraic operations remain less developed.

In the context of scientific machine learning and neural network theory, functions are built compositionally from simpler components. Understanding how approximation cost propagates through composition — particularly through multiplication, which is inherently nonlinear — is essential for designing efficient architectures and establishing sample complexity bounds.

### 1.2 Related Work

Our work connects to several established areas:

- **Approximation theory:** The classical theory of best approximation (Chebyshev, Bernstein, Jackson) provides rate results for polynomial and trigonometric approximation. Our work extends this to *compositional* approximation with explicit tree-size bounds.

- **Arithmetic circuit complexity:** The study of algebraic computation through addition and multiplication gates (Valiant, Baur-Strassen) provides the computational model. Our expression trees are arithmetic circuits with approximation tolerance.

- **Neural network expressivity:** Recent work on the expressivity of neural networks (Telgarsky, Yarotsky, Lu-Pu-Wang-Anderson-Halpern) studies how network depth and width affect approximation power. Our results provide a compositional framework that complements depth-based analyses.

### 1.3 Contributions

1. **Expression tree complexity:** A formal definition of description complexity as minimum expression tree size (Definition 2.3).

2. **Product perturbation bounds:** Quantitative bounds on how finite products respond to perturbation of factors (Theorems 3.1-3.2).

3. **Binary multiplicative subadditivity:** The complexity of f·g is at most the sum of complexities of f and g at rescaled tolerance, plus one (Theorem 4.1).

4. **k-fold multiplicative subadditivity:** Extension to finite families of functions (Theorem 4.2).

5. **Power complexity bound:** The complexity of f^m is at most m times the complexity of f, plus m-1 (Theorem 4.3).

6. **Machine verification:** All results are formally verified in Lean 4 with the Mathlib library.

## 2. Definitions and Setup

### 2.1 Expression Trees

**Definition 2.1 (Expression Tree).** An expression tree is an element of the inductive type:
```
ExprTree ::= leaf(φ : ℝ → ℝ) | add(T₁, T₂) | mul(T₁, T₂)
```
where leaves hold arbitrary real-valued functions, and internal nodes represent pointwise addition or multiplication.

**Definition 2.2 (Evaluation and Size).**
- The evaluation `T.eval : ℝ → ℝ` is defined recursively:
  - `leaf(φ).eval = φ`
  - `add(T₁, T₂).eval = λ x, T₁.eval(x) + T₂.eval(x)`
  - `mul(T₁, T₂).eval = λ x, T₁.eval(x) · T₂.eval(x)`
- The size `T.size : ℕ` counts all nodes:
  - `leaf(φ).size = 1`
  - `add(T₁, T₂).size = T₁.size + T₂.size + 1`
  - `mul(T₁, T₂).size = T₁.size + T₂.size + 1`

**Definition 2.3 (EML Description Complexity).**
```
EMLComplexityOn(a, b, f, ε) = inf { n ∈ ℕ : ∃ T, T.size ≤ n ∧ ∀ x ∈ [a,b], |f(x) - T.eval(x)| ≤ ε }
```
This is the infimum (over ℕ, so the minimum when the set is nonempty) of tree sizes achieving ε-uniform approximation of f on [a,b].

### 2.2 Finite Products

**Definition 2.4 (Interval Product).**
```
intervalProd(f)(x) = ∏ᵢ f_i(x)    for f : Fin(k) → (ℝ → ℝ)
```

**Definition 2.5 (Error Budget).**
```
prodErrorBudget(k, B, ε) = ε / (2k(B+1)^(k-1))    for k ≥ 1
```
The (B+1) factor (rather than B) accounts for the fact that approximants may exceed the original bound B by up to the approximation error δ.

### 2.3 Bounded Approximability

**Definition 2.6 (EMLBoundedApprox).** A function f is EML-bounded-approximable with bound B on [a,b] if:
- |f(x)| ≤ B for all x ∈ [a,b]
- For every ε > 0, the approximation set { n : ∃ T, T.size ≤ n ∧ ... } is nonempty

## 3. Product Perturbation Bounds

### 3.1 Finite Product Bound

**Theorem 3.1 (abs_finprod_le_pow).** *For any k ∈ ℕ, u : Fin(k) → ℝ, and B ≥ 0, if |u_i| ≤ B for all i, then |∏ᵢ u_i| ≤ B^k.*

*Proof sketch.* Rewrite |∏ u_i| = ∏ |u_i| (by `Finset.abs_prod`), then bound each factor by B and use `Finset.prod_const`. □

### 3.2 Uniform Perturbation Bound

**Theorem 3.2 (abs_prod_sub_prod_le_of_uniform).** *For any k ∈ ℕ, sequences u, v : Fin(k) → ℝ, and constants B ≥ 0, δ ≥ 0, if |u_i| ≤ B, |v_i| ≤ B, and |u_i - v_i| ≤ δ for all i, then:*
```
|∏ᵢ u_i - ∏ᵢ v_i| ≤ k · B^(k-1) · δ
```

*Proof.* By induction on k.

**Base case (k = 0):** Both products are empty (value 1), so the difference is 0 ≤ 0.

**Inductive step (k → k+1):** Using the Fin.prod decomposition ∏_{Fin(k+1)} u = (∏_{Fin(k)} u∘castSucc) · u(last), we apply the Leibniz product rule:
```
|P_u · u_last - P_v · v_last| ≤ |u_last| · |P_u - P_v| + |P_v| · |u_last - v_last|
```
where P_u = ∏_{i<k} u_i and P_v = ∏_{i<k} v_i.

By the induction hypothesis: |P_u - P_v| ≤ k · B^(k-1) · δ.
By boundedness: |u_last| ≤ B, |P_v| ≤ B^k, |u_last - v_last| ≤ δ.

So:
```
|P_u · u_last - P_v · v_last| ≤ B · k · B^(k-1) · δ + B^k · δ = (k+1) · B^k · δ
```
This completes the induction. □

**Remark.** This bound is tight: equality holds when u_i = B and v_i = B - δ for all i (for small δ).

### 3.3 Functional Version

**Theorem 3.3 (intervalProd_approx).** *If f_i and g_i are families of functions on [a,b] with |f_i(x)| ≤ B and |g_i(x)| ≤ B and |f_i(x) - g_i(x)| ≤ δ for all i and x ∈ [a,b], then:*
```
|intervalProd(f)(x) - intervalProd(g)(x)| ≤ k · B^(k-1) · δ    for all x ∈ [a,b]
```

*Proof.* Apply Theorem 3.2 pointwise with u_i = f_i(x) and v_i = g_i(x). □

## 4. Main Theorems

### 4.1 Binary Multiplicative Subadditivity

**Theorem 4.1 (emlComplexity_mul_le).** *Let f, g : ℝ → ℝ be bounded by B ≥ 0 on [a,b], and let ε > 0 with ε ≤ 2(B+1). Set δ = ε/(2(B+1)). If both f and g are δ-approximable (i.e., the approximation sets at tolerance δ are nonempty), then:*
```
EMLComplexityOn(a, b, f·g, ε) ≤ EMLComplexityOn(a, b, f, δ) + EMLComplexityOn(a, b, g, δ) + 1
```

*Proof.* Extract optimal trees T_f and T_g witnessing the complexities of f and g. Construct T = mul(T_f, T_g) with size(T) = size(T_f) + size(T_g) + 1.

For the error bound, use the Leibniz estimate:
```
|f(x)g(x) - T_f.eval(x)·T_g.eval(x)| ≤ (2B + 1) · δ ≤ 2(B+1) · δ = ε
```
The key estimate is that under δ ≤ 1 (guaranteed by ε ≤ 2(B+1)):
- |f(x)| ≤ B
- |T_g.eval(x)| ≤ B + δ ≤ B + 1
- |f(x) - T_f.eval(x)| ≤ δ
- |g(x) - T_g.eval(x)| ≤ δ

So the product error is bounded by B·δ + (B+1)·δ = (2B+1)·δ ≤ 2(B+1)·δ = ε. □

### 4.2 k-fold Multiplicative Subadditivity

**Theorem 4.2 (emlComplexity_prod_le).** *Let f : Fin(k) → (ℝ → ℝ) with each f_i bounded by B ≥ 1 on [a,b]. Let ε > 0 with ε ≤ 2k(B+1)^(k-1). Set δ = prodErrorBudget(k, B, ε) = ε/(2k(B+1)^(k-1)). If each f_i is δ-approximable, then:*
```
EMLComplexityOn(a, b, intervalProd(f), ε) ≤ (∑ᵢ EMLComplexityOn(a, b, f_i, δ)) + (k - 1)
```

*Proof.* Extract trees t_i for each f_i. Build the product tree T = buildProdTree(t) using left-to-right chaining of mul nodes.

**Tree size:** size(T) ≤ (∑ᵢ size(t_i)) + (k-1). This follows from the buildProdTree construction: k factors require k-1 multiplication nodes.

**Error bound:** Since δ ≤ 1 and |f_i(x)| ≤ B, the approximants satisfy |t_i.eval(x)| ≤ B + δ ≤ B + 1. Both the original functions and the approximants are bounded by B + 1.

By the product perturbation bound (Theorem 3.3 with B+1):
```
|intervalProd(f)(x) - intervalProd(t.eval)(x)| ≤ k · (B+1)^(k-1) · δ = ε/2 ≤ ε
```

Since T evaluates to the product of the t_i evaluations (by buildProdTree_eval), the complexity bound follows by applying EMLComplexityOn_le_of_tree to T. □

### 4.3 Power Complexity Bound

**Theorem 4.3 (emlComplexity_power_le).** *Under the same conditions as Theorem 4.2 with the constant family f_i = f:*
```
EMLComplexityOn(a, b, f^m, ε) ≤ m · EMLComplexityOn(a, b, f, δ) + (m - 1)
```
*where δ = prodErrorBudget(m, B, ε).*

*Proof.* Apply Theorem 4.2 with f_i = f for all i ∈ Fin(m). The product ∏ᵢ f(x) = f(x)^m (by Finset.prod_const), and the sum of complexities is m times the complexity of f (by Finset.sum_const). □

### 4.4 Polynomial Complexity

**Theorem 4.4 (emlComplexity_polynomial_eval_le).** *Any polynomial has finite EML description complexity on [a,b], assuming the identity function is approximable.*

This is a trivial existence result; the interesting content is the quantitative bound obtainable by combining the power complexity bound with the addition rule and Horner's method:

For a polynomial p(x) = a_d x^d + ... + a_1 x + a_0 evaluated via Horner form:
```
p(x) = (...((a_d · x + a_{d-1}) · x + a_{d-2}) · x + ...) · x + a_0
```
The description complexity is O(d · C_id), where C_id is the complexity of the identity function at the appropriate tolerance.

## 5. Algorithms

### 5.1 Product Approximation Algorithm

**Input:** Functions f_1, ..., f_k, each with an ε-approximation tree T_i, bound B, target tolerance ε.

**Algorithm:**
1. Compute δ = ε / (2k(B+1)^(k-1))
2. For each i, obtain T_i approximating f_i within δ
3. Build T = mul(mul(...mul(T_1, T_2), T_3)..., T_k)
4. Return T

**Output:** Tree T with size ≤ (∑ size(T_i)) + (k-1) approximating ∏ f_i within ε.

**Complexity:** O(k) tree construction operations after the individual approximations.

### 5.2 Power Approximation Algorithm

**Input:** Function f with ε-approximation tree T_f, bound B, power m, target tolerance ε.

**Algorithm (linear):**
1. Compute δ = ε / (2m(B+1)^(m-1))
2. Obtain T_f approximating f within δ
3. Build T = mul(mul(...mul(T_f, T_f)..., T_f)) (m copies)
4. Return T

**Output:** Tree of size ≤ m · size(T_f) + (m-1).

**Alternative (balanced):** Use a balanced binary tree of multiplications, potentially reducing depth from m-1 to ⌈log₂ m⌉. This gives the same size bound but may have better parallel evaluation properties.

## 6. Computational Experiments

See `demo.py` for interactive demonstrations including:

1. **Error propagation visualization:** Showing how the product perturbation bound k · B^(k-1) · δ tracks the actual error for various k and B.

2. **Complexity growth comparison:** Comparing the theoretical bound (∑ c_i) + (k-1) with empirical complexity estimates for random bounded function families.

3. **Error budget allocation:** Visualizing how the budget δ = ε/(2k(B+1)^(k-1)) shrinks with k and B, demonstrating the cost of multiplicative composition.

4. **Balanced vs. linear tree comparison:** Empirical comparison of left-to-right and balanced tree strategies for product construction.

## 7. Discussion

### 7.1 Significance

The multiplicative subadditivity theorem transforms EML description complexity from an isolated metric into a compositional calculus. Key implications:

1. **Compositional guarantee:** The cost of describing a product is controlled by the costs of describing the factors, with explicit, computable bounds.

2. **Algebraic structure:** Description complexity behaves like a subadditive cost function on the algebra of bounded functions, analogous to circuit size in arithmetic complexity.

3. **Error budget as resource:** The error tolerance is a consumable resource, and the budget allocation formula prescribes how to distribute it optimally among factors.

### 7.2 Limitations

1. **Error budget conservatism:** The budget δ = ε/(2k(B+1)^(k-1)) grows exponentially in k, making the bound impractical for large products unless B is close to 1.

2. **Left-to-right construction:** The current construction uses left-to-right chaining, which may not be depth-optimal.

3. **Leaf model:** The current definition allows arbitrary real-valued functions as leaves. A more refined theory would restrict leaves to specific function classes (exponentials, monomials, etc.) to capture the "EML" in EML complexity.

4. **No lower bounds:** We prove only upper bounds. Matching lower bounds would establish that the subadditivity is tight.

### 7.3 Connection to Arithmetic Circuit Complexity

Expression trees are arithmetic circuits. The multiplicative subadditivity theorem is the approximation-theoretic analogue of the basic composition principle for circuits: the size of a composed circuit is the sum of its components plus the connecting gates.

The key difference is error control: in exact computation, there is no error budget to manage. The introduction of approximation tolerance creates a richer theory where the "cost" of composition includes both structural cost (tree size) and analytical cost (error propagation).

## 8. Future Work

1. **Balanced tree improvement:** Can the multiplicative depth k-1 be reduced to O(log k) with the same total size bound? This would connect to parallel circuit complexity.

2. **Lower bounds:** Establish matching lower bounds showing that some function families require Ω(∑ c_i + k) complexity for their products.

3. **Extended operations:** Develop the calculus for division (f/g on bounded-away-from-zero functions), composition (f ∘ g), and maximum (max(f, g)).

4. **Refined leaf models:** Restrict leaves to specific function classes and establish complexity hierarchies based on the permitted primitives.

5. **Applications to neural network theory:** Use the compositional calculus to derive approximation guarantees for specific network architectures with multiplicative interactions (attention, gating, polynomial activations).

## References

1. Chebyshev, P. L. (1854). "Théorie des mécanismes connus sous le nom de parallélogrammes."
2. Weierstrass, K. (1885). "Über die analytische Darstellbarkeit sogenannter willkürlicher Functionen einer reellen Veränderlichen."
3. Valiant, L. (1979). "Completeness Classes in Algebra." ACM STOC.
4. Baur, W. and Strassen, V. (1983). "The Complexity of Partial Derivatives." Theoretical Computer Science.
5. Yarotsky, D. (2017). "Error Bounds for Approximations with Deep ReLU Networks." Neural Networks.
6. Telgarsky, M. (2016). "Benefits of Depth in Neural Networks." COLT.
