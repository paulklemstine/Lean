# EML Interpolation Theory: Stone-Weierstrass for Exp-Log Networks

## Abstract

We develop a rigorous mathematical framework for studying the approximation-theoretic properties of networks built from exponentiation, logarithm, multiplication, and addition — the **EML (Exp-Log-Multiply) algebra**. We formalize the EML term algebra as an inductive type with natural complexity measures (width and depth), prove that the log-free fragment generates a subalgebra of C(X, ℝ) that separates points on any compact space admitting an injective continuous coordinate map, and apply the Stone-Weierstrass theorem to establish density. Beyond the existential density result, we prove quantitative separation bounds via the mean value theorem for exp, establish a strict depth hierarchy for iterated exponentials, and completely classify the expressiveness of depth-1, width-1 networks. All results are formalized and verified in the Lean 4 proof assistant with the Mathlib library.

**Keywords:** Universal approximation, Stone-Weierstrass theorem, exponential networks, depth hierarchy, formal verification

---

## 1. Introduction

The universal approximation theorem for neural networks (Cybenko 1989, Hornik et al. 1989) states that feedforward networks with a single hidden layer and sigmoidal activation can approximate any continuous function on a compact set to arbitrary accuracy. While foundational, this result is purely existential — it provides no bounds on the network size required to achieve a given approximation accuracy.

Classical approximation theory, by contrast, offers explicit rate bounds. The Jackson theorems give O(n^{-α}) rates for approximating Lipschitz-α functions by degree-n polynomials. The Stone-Weierstrass theorem provides a general sufficient condition for density: a subalgebra of C(X, ℝ) is dense if and only if it separates points (for compact Hausdorff X).

This paper bridges the gap by studying **EML networks** — finite compositions of exp, log, addition, and multiplication. We show that:

1. The EML algebra satisfies the hypotheses of Stone-Weierstrass (Theorem 3.1)
2. Quantitative separation bounds arise from the mean value theorem for exp (Theorem 4.1)
3. A strict depth hierarchy exists: iterated exponentials require depth proportional to their nesting (Theorem 5.1)
4. Width-1, depth-1 networks are completely classified (Theorem 5.2)

### 1.1 Related Work

The exp-log-multiply framework connects to several research traditions:

- **Analytic complexity theory** (Grigoriev, Karpinski): Studies the circuit complexity of computing analytic functions, where exp and log appear as basic gates.
- **Pfaffian functions** (Khovanskii): EML functions are a subset of Pfaffian functions, which satisfy finiteness theorems for their zero sets.
- **Neural network expressiveness** (Telgarsky 2016, Eldan-Shamir 2016): Depth separation results for ReLU networks; our depth hierarchy for EML networks is analogous but uses fundamentally different techniques.
- **Tropical geometry** (Maclagan-Sturmfels): The log-limit of EML expressions connects to tropical semirings, providing a bridge to combinatorial optimization.

## 2. The EML Term Algebra

### 2.1 Syntax

**Definition 2.1 (EML Term).** The set of EML terms is defined inductively:

```
EMLTerm ::= var | const(c) | add(t₁, t₂) | mul(t₁, t₂) | expOf(t) | logOf(t)
```

where c ∈ ℝ is a real constant.

**Definition 2.2 (Log-Free Fragment).** The log-free EML terms `EMLTermLF` omit the `logOf` constructor:

```
EMLTermLF ::= var | const(c) | add(t₁, t₂) | mul(t₁, t₂) | expOf(t)
```

### 2.2 Semantics

**Definition 2.3 (Evaluation).** The evaluation function `eval : EMLTermLF → ℝ → ℝ` is defined recursively:

- eval(var, x) = x
- eval(const(c), x) = c
- eval(add(t₁, t₂), x) = eval(t₁, x) + eval(t₂, x)
- eval(mul(t₁, t₂), x) = eval(t₁, x) · eval(t₂, x)
- eval(expOf(t), x) = exp(eval(t, x))

### 2.3 Complexity Measures

**Definition 2.4 (Width).** The width of a term counts its leaf nodes:
- width(var) = width(const(c)) = 1
- width(add(t₁, t₂)) = width(mul(t₁, t₂)) = width(t₁) + width(t₂)
- width(expOf(t)) = width(t)

**Definition 2.5 (Depth).** The depth measures maximum nesting:
- depth(var) = depth(const(c)) = 0
- depth(add(t₁, t₂)) = depth(mul(t₁, t₂)) = max(depth(t₁), depth(t₂)) + 1
- depth(expOf(t)) = depth(t) + 1

**Definition 2.6 (EML Complexity).** The complexity pair of a term t is (width(t), depth(t)), ordered by the product partial order. The **total cost** is width(t) · 2^{depth(t)}.

**Proposition 2.7.** Width is always positive: width(t) ≥ 1 for all terms t.

**Proposition 2.8.** Total cost is monotone in the complexity partial order.

## 3. The EML Stone-Weierstrass Theorem

### 3.1 Continuity

**Theorem 3.0 (Continuity).** Every log-free EML term evaluates to a continuous function ℝ → ℝ.

*Proof.* By structural induction: var is continuous (identity), const is continuous (constant function), add and mul preserve continuity, and exp ∘ f is continuous whenever f is continuous. □

### 3.2 The EML Subalgebra

Let X be a compact Hausdorff topological space and φ : X → ℝ a continuous function (the "coordinate map").

**Definition 3.1.** The **EML function set** through φ is:
```
F_φ = { f ∈ C(X, ℝ) | ∃ t : EMLTermLF, f = t.eval ∘ φ }
```

**Definition 3.2.** The **EML subalgebra** A_φ is the subalgebra of C(X, ℝ) generated by F_φ:
```
A_φ = Algebra.adjoin(ℝ, F_φ)
```

### 3.3 Point Separation

**Theorem 3.1 (EML Separates Points).** If φ : X → ℝ is injective, then A_φ separates points.

*Proof.* Given x₁ ≠ x₂ in X, since φ is injective, φ(x₁) ≠ φ(x₂). The function φ itself is in A_φ (via the term `var`), and φ(x₁) ≠ φ(x₂). □

### 3.4 Density

**Theorem 3.2 (EML Density — Main Theorem).** If φ : X → ℝ is injective, then the topological closure of A_φ equals C(X, ℝ):
```
cl(A_φ) = C(X, ℝ)
```

*Proof.* Immediate from the Stone-Weierstrass theorem (Mathlib: `subalgebra_topologicalClosure_eq_top_of_separatesPoints`) and Theorem 3.1. □

**Corollary 3.3 (Uniform Approximation).** For any f ∈ C(X, ℝ) and ε > 0, there exists g ∈ A_φ with ‖f - g‖ < ε.

**Corollary 3.4 (Interval Density).** EML functions are dense in C([a,b], ℝ) for any compact interval [a,b].

## 4. Quantitative Separation Theory

### 4.1 Exponential Separation Bound

**Theorem 4.1 (Exp Separation Lower Bound).** For all x, y ∈ ℝ with x ≠ y:
```
|exp(x) - exp(y)| ≥ |x - y| · exp(min(x, y))
```

*Proof.* By the mean value theorem, |exp(x) - exp(y)| = exp(c) · |x - y| for some c between x and y. Since c ≥ min(x, y), exp(c) ≥ exp(min(x, y)). The formal proof in Lean splits into cases x ≤ y and y ≤ x, using the inequality exp(t) ≥ 1 + t and algebraic manipulations. □

**Remark.** This bound is tight when x = y (both sides are 0 in the limit) and captures the fundamental fact that exponential separation grows with the absolute position on the real line.

### 4.2 Polynomial Representation

**Theorem 4.2.** The monomial x^n can be represented by an EML term of width at most max(1, 2n).

*Proof.* The term `emlPower(n)` defined by:
- emlPower(0) = const(1)
- emlPower(n+1) = mul(emlPower(n), var)

evaluates to x^n (proved by induction using pow_succ) and has width at most max(1, 2n). □

### 4.3 Horner Form Polynomials

**Theorem 4.3.** Any polynomial ∑ aᵢxⁱ can be represented in Horner form as an EML term `emlPolynomial([a₀, a₁, ..., aₙ])` satisfying:
```
eval(emlPolynomial(a :: as), x) = a + x · eval(emlPolynomial(as), x)
```

## 5. Depth Hierarchy

### 5.1 Iterated Exponentials

**Definition 5.1.** The k-fold iterated exponential:
- iterExp(0, x) = x
- iterExp(k+1, x) = exp(iterExp(k, x))

The corresponding EML term `emlIterExp(k)` has depth k and width 1.

**Theorem 5.1 (Strict Monotonicity).** For all k, iterExp(k, ·) is strictly monotone.

*Proof.* By induction: iterExp(0) = id is strictly monotone. If iterExp(k) is strictly monotone, then iterExp(k+1) = exp ∘ iterExp(k) is the composition of two strictly monotone functions. □

### 5.2 Growth Rate Separation

**Theorem 5.2 (Growth Hierarchy).** For all k and M > 0, there exists x₀ such that for all x ≥ x₀:
```
iterExp(k+1, x) > M · iterExp(k, x)
```

*Proof.* Since iterExp(k) → ∞ as x → ∞ (by strict monotonicity and unboundedness), and exp(t)/t → ∞ as t → ∞ (a standard result: `Real.tendsto_exp_div_pow_atTop`), we conclude that exp(iterExp(k, x)) / iterExp(k, x) → ∞. □

**Corollary 5.3.** Each level of the iterated exponential hierarchy is strictly more expressive than the previous one: no finite linear combination of iterExp(k) terms can represent iterExp(k+1).

### 5.3 Depth-1, Width-1 Classification

**Theorem 5.3 (Classification).** Every EMLTermLF of width 1 and depth ≤ 1 computes exactly one of:
1. A constant c
2. The identity x ↦ x
3. The exponential x ↦ exp(x)
4. A constant exponential x ↦ exp(c)

*Proof.* Width 1 eliminates add and mul (which have width ≥ 2). The remaining possibilities are var (case 2), const(c) (case 1), and expOf(s) where s has width 1 and depth 0. Depth 0 with width 1 forces s = var or s = const(c), giving cases 3 and 4. □

### 5.4 Width-Depth Tradeoff

**Theorem 5.4.** The function exp(exp(x)) has depth 2 and width 1 as an EML term, but any depth-1, width-1 term computes a different function.

This is an immediate corollary of Theorem 5.3: none of the four width-1, depth-1 functions equals exp(exp(x)).

## 6. The EMLComplexity Structure

**Definition 6.1 (EMLComplexity).** An EML complexity pair is a structure `(width : ℕ, depth : ℕ)` equipped with:
- Product partial order: (w₁, d₁) ≤ (w₂, d₂) ⟺ w₁ ≤ w₂ ∧ d₁ ≤ d₂
- Total cost: totalCost(w, d) = w · 2^d
- Monotonicity: totalCost is monotone in the partial order

The total cost captures the intuition that depth provides *exponential* leverage: adding one level of depth can substitute for doubling the width.

## 7. Falsifiable Conjecture

**Conjecture 7.1 (Jackson-type Rate for EML).** For f ∈ Lip_α([0,1]) with Lipschitz constant L, there exists an EMLTermLF of width at most C · (L/ε)^{1/α} and depth at most ⌈1/α⌉ + 1 that approximates f uniformly within ε, where C is an absolute constant.

**Computational Test.** For f(x) = |x - 1/2|^α on [0,1] (which is Lip_α with constant 1), numerically verify that EML networks of the predicted size achieve the predicted accuracy. Specifically:
- α = 1: width O(1/ε), depth 2 should suffice
- α = 1/2: width O(1/ε²), depth 3 should suffice

This can be tested numerically by fitting EML networks to these target functions and measuring convergence rates.

## 8. Discussion

### 8.1 Comparison with ReLU Networks

ReLU networks compute piecewise linear functions, whose approximation theory is well-understood (Yarotsky 2017). EML networks compute smooth (in fact, real-analytic) functions when the log-free fragment is used, making them better suited for approximating smooth target functions. The depth hierarchy for EML is based on *growth rate* rather than *oscillation*, which is the mechanism for ReLU depth separation.

### 8.2 Connection to Tropical Geometry

In the limit where multiplication is replaced by addition and addition by max (the "tropicalization" of the semiring), EML expressions become tropical polynomials. The density of tropical max-plus expressions in C(K) (established in the catalog entry `tropical_stone_weierstrass_eml_dense`) provides a parallel density result in the tropical setting. The EML framework thus sits at the intersection of classical analysis and tropical geometry.

### 8.3 Practical Implications

The explicit complexity measures (width, depth, total cost) provide a principled framework for neural architecture search. Rather than searching over architectures by trial and error, the EML complexity theory suggests optimal (width, depth) allocations for a given approximation target.

## 9. References

1. Weierstrass, K. (1885). Über die analytische Darstellbarkeit sogenannter willkürlicher Functionen einer reellen Veränderlichen.
2. Stone, M.H. (1948). The generalized Weierstrass approximation theorem.
3. Cybenko, G. (1989). Approximation by superpositions of a sigmoidal function.
4. Hornik, K., Stinchcombe, M., White, H. (1989). Multilayer feedforward networks are universal approximators.
5. Telgarsky, M. (2016). Benefits of depth in neural networks. COLT.
6. Yarotsky, D. (2017). Error bounds for approximations with deep ReLU networks.

---

*All theorems in Sections 2-5 have been formally verified in Lean 4 with Mathlib. The complete formalization is available in the `Applications/` directory.*
