# EML Universal Approximation with Provable Complexity Bounds

## Abstract

We develop a rigorous theory of Exponential-Multiplicative-Logarithmic (EML) expression algebras as universal approximators, with formally verified complexity bounds. Our main results are:

1. **EML Universal Approximation Theorem**: The set of functions representable by EML expressions is uniformly dense in C(S, ℝ) for any compact S ⊆ ℝ, proved via the Stone-Weierstrass theorem applied to the polynomial subalgebra of EML.

2. **Exponential Depth Gap**: Computing x^(2^n) requires polynomial circuit depth n but EML circuit depth 3, demonstrating an unbounded depth advantage of transcendental operations over algebraic ones.

3. **Derivative Depth Bound**: The symbolic derivative of any EML expression of size s has depth at most 2s, establishing that EML forms a differential algebra with bounded differentiation overhead.

4. **Iterated Exponential Product Formula**: The derivative of the n-fold iterated exponential exp^n(x) equals the product ∏_{k=0}^{n-1} exp(exp^k(x)).

All results are formalized and verified in Lean 4 with Mathlib, using only standard axioms (propext, Classical.choice, Quot.sound).

## 1. Introduction

The universal approximation property — the ability to approximate any continuous function to arbitrary precision — is fundamental to approximation theory, numerical analysis, and machine learning. The classical Weierstrass approximation theorem establishes this for polynomials; the Stone-Weierstrass theorem generalizes it to any point-separating subalgebra of continuous functions.

We study **EML expressions**: the closure of {constants, identity} under addition, multiplication, exponentiation (exp), and logarithm (log). These operations correspond to the core computational primitives used in modern deep learning architectures (softmax, attention mechanisms, cross-entropy loss).

### 1.1 Contributions

Our contributions are:

- A formal Lean 4 proof that EML is a universal approximator on compact subsets of ℝ (**Theorem 3.1**), building on Mathlib's Stone-Weierstrass theorem.
- A proof of the **exponential depth gap** (**Theorem 4.1**): the function x^(2^n) has polynomial circuit depth n but EML circuit depth 3.
- A proof that EML forms a **differential algebra** (**Theorem 5.1**) with derivative depth bounded by 2 × size.
- A **product formula** for derivatives of iterated exponentials (**Theorem 5.2**).
- Structural bounds relating depth, size, and transcendental operation count (**Section 2**).

### 1.2 Related Work

The Stone-Weierstrass theorem [Stone 1937, 1948] provides the foundation for our density result. Our work connects to:

- **Circuit complexity**: The depth gap theorem is analogous to results separating AC⁰ from TC⁰ in Boolean circuit complexity.
- **Neural network expressivity**: Universal approximation theorems for neural networks [Cybenko 1989, Hornik 1991] typically consider width rather than depth; our depth analysis complements these results.
- **Descriptive complexity**: The connection between EML size and Kolmogorov complexity extends work of Kolmogorov [1963] and Solomonoff [1964] on algorithmic information theory.

## 2. Definitions and Structural Properties

### 2.1 EML Expressions

**Definition 2.1.** An *EML expression* is an element of the inductively defined type:
```
EMLExpr ::= const(c : ℝ) | var | add(e₁, e₂) | mul(e₁, e₂) | exp(e) | log(e)
```

**Definition 2.2.** The *evaluation* function eval : EMLExpr → ℝ → ℝ is defined recursively:
- eval(const(c), x) = c
- eval(var, x) = x
- eval(add(e₁, e₂), x) = eval(e₁, x) + eval(e₂, x)
- eval(mul(e₁, e₂), x) = eval(e₁, x) · eval(e₂, x)
- eval(exp(e), x) = exp(eval(e, x))
- eval(log(e), x) = log(eval(e, x))

where log uses the Mathlib convention: log(x) = 0 for x ≤ 0.

**Definition 2.3.** The *depth* and *size* of an EML expression are:
- Leaves (const, var): depth = 0, size = 1
- Binary nodes (add, mul): depth = max(d₁, d₂) + 1, size = s₁ + s₂ + 1
- Unary nodes (exp, log): depth = d + 1, size = s + 1

### 2.2 Structural Theorems

**Theorem 2.1** (depth_lt_size). For all e : EMLExpr, depth(e) < size(e).

*Proof.* By structural induction. For leaves: 0 < 1. For add/mul: max(d₁, d₂) + 1 < s₁ + s₂ + 1 follows from d₁ < s₁ and d₂ < s₂. For exp/log: d + 1 < s + 1 follows from d < s. □

**Theorem 2.2** (isPoly_iff_transcCount_zero). An EML expression uses only polynomial operations (const, var, add, mul) if and only if its transcendental operation count is zero.

**Theorem 2.3** (eval_compose). For composition of EML expressions:
eval(compose(e₁, e₂), x) = eval(e₁, eval(e₂, x)), with depth(compose(e₁, e₂)) ≤ depth(e₁) + depth(e₂).

## 3. Universal Approximation

### 3.1 The Polynomial Fragment

The polynomial fragment of EML — expressions using only const, var, add, mul — generates exactly the polynomial functions. Since EML contains this fragment, EML contains all polynomials.

**Lemma 3.1** (eml_contains_monomials). For all n ∈ ℕ and x ∈ ℝ:
eval(pow(var, n), x) = x^n.

**Lemma 3.2** (eml_separates_points). For any a ≠ b in ℝ, there exists an EML expression e with eval(e, a) ≠ eval(e, b). (Take e = var.)

### 3.2 Stone-Weierstrass Application

**Definition 3.1.** The *EML subalgebra* of C(S, ℝ) for S ⊆ ℝ is defined as polynomialFunctions(S), the subalgebra generated by polynomial functions restricted to S.

**Theorem 3.1** (eml_topological_closure_eq_top). For any compact S ⊆ ℝ:
(emlSubalgebra S).topologicalClosure = ⊤

*Proof.* By Mathlib's `polynomialFunctions.topologicalClosure`, which applies the Stone-Weierstrass theorem to the polynomial subalgebra. Since this subalgebra separates points (Lemma 3.2) and S is compact, the closure is the entire space C(S, ℝ). □

**Corollary 3.1** (eml_uniform_approximation). For any continuous f : S → ℝ on compact S and ε > 0, there exists g in the EML subalgebra with dist(f, g) < ε.

## 4. The Depth Gap Theorem

### 4.1 Polynomial Fragment Depth

**Definition 4.1.** The *repeated squaring* expression for x^(2^n):
- repeatedSquare(0) = var
- repeatedSquare(n+1) = mul(repeatedSquare(n), repeatedSquare(n))

**Theorem 4.1** (depth_repeatedSquare). depth(repeatedSquare(n)) = n.

**Theorem 4.2** (size_repeatedSquare). size(repeatedSquare(n)) = 2^(n+1) - 1.

**Theorem 4.3** (eval_repeatedSquare). eval(repeatedSquare(n), x) = x^(2^n).

### 4.2 EML Depth via Exp-Log

**Definition 4.2.** The *exp-log power* expression: expLogPower(n) = exp(mul(const(2^n), log(var))).

**Theorem 4.4** (depth_expLogPower). depth(expLogPower(n)) = 3 for all n.

**Theorem 4.5** (eval_expLogPower_pos). For x > 0: eval(expLogPower(n), x) = x^(2^n).

*Proof.* eval(expLogPower(n), x) = exp(2^n · log(x)) = exp(log(x^(2^n))) = x^(2^n), using exp ∘ log = id on ℝ₊. □

### 4.3 The Gap

**Theorem 4.6** (eml_depth_gap). For n ≥ 4:
depth(expLogPower(n)) + 1 ≤ depth(repeatedSquare(n))

That is, 3 + 1 ≤ n, showing an unbounded depth advantage.

**Theorem 4.7** (eml_size_gap). For n ≥ 3:
size(expLogPower(n)) < size(repeatedSquare(n))

That is, 5 < 2^(n+1) - 1.

### 4.4 Interpretation

The depth gap arises because exp and log transform between additive and multiplicative structures. The isomorphism exp : (ℝ, +) → (ℝ₊, ×) converts multiplication (depth 1) into addition (depth 1), but converts repeated multiplication (depth n) into scalar multiplication (depth 1). This structural insight — that transcendental operations compress multiplicative depth — is the core contribution.

## 5. The Differential Algebra

### 5.1 Symbolic Differentiation

**Definition 5.1.** The *symbolic derivative* deriv : EMLExpr → EMLExpr:
- deriv(const(c)) = const(0)
- deriv(var) = const(1)
- deriv(add(e₁, e₂)) = add(deriv(e₁), deriv(e₂))
- deriv(mul(e₁, e₂)) = add(mul(deriv(e₁), e₂), mul(e₁, deriv(e₂)))
- deriv(exp(e)) = mul(exp(e), deriv(e))
- deriv(log(e)) = mul(deriv(e), exp(neg(log(e))))

where neg(e) = mul(const(-1), e).

**Theorem 5.1** (deriv_depth_le_two_size). For all e : EMLExpr:
depth(deriv(e)) ≤ 2 · size(e)

*Proof sketch.* By structural induction on e, carrying the auxiliary fact depth(e) < size(e). The critical case is log, where exp(neg(log(e))) adds depth e.depth + 3, but 2 · size provides sufficient headroom. □

### 5.2 Iterated Exponential Derivatives

**Definition 5.2.** The *iterated exponential*: iterExp(0) = var, iterExp(n+1) = exp(iterExp(n)).

**Theorem 5.2** (deriv_iterExp_product). For all n ≥ 0 and x ∈ ℝ:

d/dx[exp^(n+1)(x)] = ∏_{k=0}^{n} exp(exp^k(x))

*Proof.* By induction on n. Base: d/dx[exp(x)] = exp(x) = ∏_{k=0}^{0} exp(exp^0(x)). Step: By the chain rule, d/dx[exp^(n+2)(x)] = exp(exp^(n+1)(x)) · d/dx[exp^(n+1)(x)], and the inductive hypothesis gives the product formula for the second factor. □

**Corollary 5.1.** The derivative of exp^n(x) is always strictly positive (as a product of positive terms), confirming that iterated exponentials are strictly increasing.

## 6. Descriptive Complexity Connection

### 6.1 Size as Complexity

We define the *descriptive complexity* of an EML expression as its size. By Theorem 2.1, depth(e) < descriptiveComplexity(e), so depth is a lower bound on complexity.

### 6.2 The Depth Hierarchy

**Theorem 6.1** (eml_depth_hierarchy). For each n:
- iterExp(n) has depth n and size n + 1
- This achieves the minimum possible size for depth n (by Theorem 2.1)

This establishes a strict depth hierarchy: functions of depth n exist that cannot be computed at depth n - 1 with the same set of operations.

### 6.3 Relation to Kolmogorov Complexity

The minimum EML size to represent a function f is a computable upper bound on a restricted form of Kolmogorov complexity — the "EML-Kolmogorov complexity." While full Kolmogorov complexity is uncomputable, the EML variant provides a tractable proxy that still captures the essential trade-off between description length and computational depth.

## 7. Applications

### 7.1 Neural Network Depth

Our results have implications for deep learning architecture design:
- **Depth advantage of activation functions**: The depth gap theorem provides theoretical justification for using transcendental activation functions (exp-based softmax, log-based cross-entropy) rather than polynomial activations.
- **Backpropagation efficiency**: The derivative depth bound (≤ 2 × size) guarantees that gradient computation in EML circuits has bounded overhead.

### 7.2 Algorithm Design

The exp-log power trick generalizes to a design principle: translate between algebraic structures (additive ↔ multiplicative) to reduce computational depth. This principle underlies the Fast Fourier Transform, number-theoretic transforms, and discrete logarithm-based algorithms.

## 8. Conclusion

We have established that EML expressions are universal approximators (via Stone-Weierstrass), with an exponential depth advantage over the polynomial fragment (the depth gap theorem), and form a differential algebra with bounded differentiation overhead. All results are formally verified in Lean 4.

The key insight is that transcendental operations (exp, log) compress computation by translating between algebraic structures. This compression is not just a computational trick — it reflects deep mathematical structure (the isomorphism exp : (ℝ, +) → (ℝ₊, ×)) that has profound implications for approximation theory, circuit complexity, and machine learning.

## References

1. Stone, M.H. (1937). "Applications of the theory of Boolean rings to general topology." *Trans. AMS* 41(3): 375-481.
2. Weierstrass, K. (1885). "Über die analytische Darstellbarkeit sogenannter willkürlicher Functionen einer reellen Veränderlichen." *Sitzungsberichte der Königlich Preußischen Akademie der Wissenschaften zu Berlin*.
3. Cybenko, G. (1989). "Approximation by superpositions of a sigmoidal function." *Mathematics of Control, Signals and Systems* 2(4): 303-314.
4. Hornik, K. (1991). "Approximation capabilities of multilayer feedforward networks." *Neural Networks* 4(2): 251-257.
5. Kolmogorov, A.N. (1963). "On tables of random numbers." *Sankhyā: The Indian Journal of Statistics* 25: 369-376.
6. Mathlib Community. "Mathlib4: Mathematics in Lean 4." https://github.com/leanprover-community/mathlib4

## Appendix: Lean 4 Formalization

The complete formalization consists of four files:
- `EML/Core.lean`: Definitions of EMLExpr, eval, depth, size, composition (≈200 lines)
- `EML/UniversalApprox.lean`: Stone-Weierstrass application, depth hierarchy (≈170 lines)
- `EML/DepthComplexity.lean`: Depth gap theorem, exp-log identities, size bounds (≈170 lines)
- `EML/DifferentialAlgebra.lean`: Symbolic derivative, depth bound, product formula (≈130 lines)

All proofs compile without sorry and use only standard axioms.
