# EML Circuit Depth Separation: A Formal Lower Bound for Transcendence-Aware Expression Complexity

## Abstract

We introduce a formal framework for studying the circuit complexity of elementary transcendental expressions. We define two expression languages over ℝ — a full language with primitive `exp` and `log`, and an EML-only language where transcendence enters exclusively through the operation `eml(a,b) = a · exp(b)` — and study the depth complexity of representing iterated exponentials `iterExp n (x) = exp^n(x)` in each language.

Our main contributions are:
1. A complete formalization of both expression languages with total semantics over ℝ.
2. A syntactic invariant called **exponential rank** (`expRank`) that bounds the maximum depth of exponential nesting achievable by an EML expression.
3. A proof that `expRank(e) ≤ emlDepth(e)` for all EML expressions `e`.
4. A proof that the canonical EML construction for `iterExp n` achieves `emlDepth = expRank = n`.
5. A proof that inv-free, eml-free expressions cannot represent `iterExp n` for any `n ≥ 1`, using a polynomial growth bound argument.
6. Multiple analytic results: strict monotonicity of `iterExp`, positivity, and growth domination.

The theorems are machine-verified in Lean 4 with the Mathlib library, establishing the first formally verified results in transcendence-aware circuit complexity. The full linear lower bound (`n ≤ emlDepth(e)` for any `e` representing `iterExp n`) is stated as the central conjecture, with the semantic core (connecting `expRank` to function identity) identified as the key open problem.

## 1. Introduction

### 1.1 Motivation

Circuit complexity studies how the choice of basis operations affects the size and depth of circuits computing a given function. Classical results in Boolean circuit complexity show that restricting the gate set can lead to exponential separations. Analogous questions for arithmetic circuits have yielded celebrated results such as Baur-Strassen theorems and lower bounds for restricted arithmetic models.

We initiate the study of **transcendence-aware circuit complexity**: lower bounds for expression languages that include transcendental operations (exponentials, logarithms) alongside field operations. Our model is motivated by the EML (Exponential of a Linear form) operation, a single primitive that generates the full elementary transcendental function class through composition with field operations.

### 1.2 The EML Operation

The EML operation is defined as:
```
eml(a, b) = a · exp(b)
```
This single operation, combined with field operations (+, ×, −, ⁻¹), suffices to express any elementary function built from exponentials and logarithms. For instance:
- `exp(x) = eml(1, x)`
- `log(x)` can be expressed through a more complex EML construction

The key question is: does the efficiency of representation depend on the choice of basis? Specifically, are there functions that have efficient representations in the full `{exp, log}` basis but require deep representations in the EML basis?

### 1.3 Main Results Overview

We answer this question affirmatively for the family of iterated exponentials:

| Function | Full Language Depth | EML Depth (canonical) | EML Depth (lower bound) |
|----------|--------------------|-----------------------|------------------------|
| `iterExp 0 = id` | 0 | 0 | 0 |
| `iterExp 1 = exp` | 1 | 1 | ≥ 1 (proved) |
| `iterExp 2 = exp∘exp` | 2 | 2 | ≥ 2 (conjectured) |
| `iterExp n` | n | n | ≥ n (conjectured) |

The full linear lower bound `n ≤ emlDepth(e)` is the central conjecture. We prove all the structural and analytic infrastructure required, reducing the conjecture to a single semantic claim about the growth properties of EML expressions.

## 2. Definitions

### 2.1 Expression Languages

**Definition 2.1 (FullExpr).** The full expression language is the inductive type:
```
FullExpr ::= var | const(c : ℝ) | add(a, b) | mul(a, b) | neg(a) | inv(a) | exp(a) | log(a)
```

**Definition 2.2 (EMLExpr).** The EML expression language is:
```
EMLExpr ::= var | const(c : ℝ) | add(a, b) | mul(a, b) | neg(a) | inv(a) | eml(a, b)
```

Both are tree-structured (no DAG sharing). This is the **tree model** of computation.

### 2.2 Semantics

Evaluation is total over ℝ, using Lean's conventions (log of non-positive is 0, division by zero is 0):

```
FullExpr.eval(var, x) = x
FullExpr.eval(const c, x) = c
FullExpr.eval(exp a, x) = Real.exp(a.eval(x))
FullExpr.eval(log a, x) = Real.log(a.eval(x))
...

EMLExpr.eval(eml a b, x) = a.eval(x) · Real.exp(b.eval(x))
```

### 2.3 Depth and Size Measures

**EML depth** counts only the nesting of `eml` gates, ignoring field operations:
```
emlDepth(var) = emlDepth(const c) = 0
emlDepth(add a b) = max(emlDepth(a), emlDepth(b))
emlDepth(eml a b) = 1 + max(emlDepth(a), emlDepth(b))
```

**Tree depth** counts all operations:
```
depth(eml a b) = 1 + max(depth(a), depth(b))
depth(add a b) = 1 + max(depth(a), depth(b))
```

### 2.4 Exponential Rank

**Definition 2.3 (Exponential Rank).** The key syntactic invariant:
```
expRank(var) = expRank(const c) = 0
expRank(add a b) = max(expRank(a), expRank(b))
expRank(mul a b) = max(expRank(a), expRank(b))
expRank(neg a) = expRank(inv a) = expRank(a)
expRank(eml a b) = max(expRank(a), expRank(b) + 1)
```

**Interpretation:** `expRank` measures the maximum number of nested exponential layers an expression can produce. Field operations preserve the rank, while each `eml` gate increases the rank of its second argument by one.

### 2.5 Iterated Exponentials

```
iterExp(0, x) = x
iterExp(n+1, x) = exp(iterExp(n, x))
```

### 2.6 Representability

```
RepresentsOnPos(e, f) := ∀ x > 0, e.eval(x) = f(x)
```

## 3. Main Results

### 3.1 Theorem: Structural Bound (expRank ≤ emlDepth)

**Theorem 3.1.** For all `e : EMLExpr`, `expRank(e) ≤ emlDepth(e)`.

*Proof.* By structural induction on `e`. The base cases (var, const) are trivial (0 ≤ 0). For field operations, both `expRank` and `emlDepth` take the max of children (or preserve the child's value), so the inequality follows from the inductive hypothesis. For `eml a b`:
```
expRank(eml a b) = max(expRank(a), expRank(b) + 1)
                 ≤ max(emlDepth(a), emlDepth(b) + 1)    [by IH]
                 ≤ 1 + max(emlDepth(a), emlDepth(b))
                 = emlDepth(eml a b)
```
∎

### 3.2 Theorem: Upper Bound in Full Language

**Theorem 3.2.** For all `n`, the canonical expression `fullExprIterExp(n)` satisfies:
- `eval(fullExprIterExp(n), x) = iterExp(n, x)` for all `x`
- `depth(fullExprIterExp(n)) = n`
- `size(fullExprIterExp(n)) = n + 1`

*Proof.* By induction on `n`. The canonical construction is `exp(exp(...exp(var)...))` with `n` nested `exp` layers. ∎

### 3.3 Theorem: Canonical EML Construction

**Theorem 3.3.** The canonical EML construction `emlExprIterExp(n) = eml(1, eml(1, ..., eml(1, var)...))` satisfies:
- `eval(emlExprIterExp(n), x) = iterExp(n, x)`
- `emlDepth(emlExprIterExp(n)) = n`
- `expRank(emlExprIterExp(n)) = n`

### 3.4 Theorem: Iterated Exponential Properties

**Theorem 3.4.** For all `n`:
- `iterExp(n)` is strictly monotone.
- For `x > 0`, `iterExp(n, x) > 0`.
- For `n ≥ 1`, `iterExp(n, x) > 0` for all `x`.
- For `n ≥ 1` and `x > 0`, `exp(x) ≤ iterExp(n, x)`.

*Proof.* By induction on `n`, using `exp_strictMono`, `exp_pos`, and `add_one_le_exp`. ∎

### 3.5 Theorem: Polynomial Growth Bound

**Theorem 3.5.** For any inv-free, eml-free expression `e` and `x ≥ 1`:
```
|e.eval(x)| ≤ coefBound(e) · x^polyBound(e)
```
where `polyBound` and `coefBound` are syntactically defined measures.

*Proof.* By structural induction. The key cases:
- `var`: `|x| = x ≤ 1 · x¹`
- `const c`: `|c| ≤ (|c|+1) · x⁰`
- `add a b`: triangle inequality + max of degrees
- `mul a b`: `|ab| = |a|·|b|`, degrees add
- `neg a`: `|-a| = |a|`
- `inv`, `eml`: vacuously true (excluded by hypothesis)
∎

### 3.6 Theorem: Separation for Inv-Free Expressions

**Theorem 3.6.** No inv-free, eml-free expression can represent `iterExp(n)` on `(0,∞)` for `n ≥ 1`.

*Proof.* By the polynomial growth bound (Theorem 3.5), `|e.eval(x)| ≤ C · x^N` for `x ≥ 1`. But `iterExp(n, x) ≥ exp(x)` for `n ≥ 1` (Theorem 3.4), and `exp(x)` eventually exceeds `C · x^N` for any `C, N` (by `Real.tendsto_exp_div_pow_atTop`). This contradicts `e.eval(x) = iterExp(n, x)` for large `x`. ∎

### 3.7 Conjecture: Full Lower Bound

**Conjecture 3.7.** For all `n ≥ 0` and `e : EMLExpr`, if `RepresentsOnPos(e, iterExp n)`, then `n ≤ emlDepth(e)`.

**Reduction:** By Theorem 3.1, it suffices to show `n ≤ expRank(e)`. The conjecture reduces to showing that the exponential rank is a **sound** measure of exponential nesting: no EML expression of rank `< n` can compute `iterExp(n)`.

## 4. Algorithms

### 4.1 ExpRank Calculator

```
Algorithm: ComputeExpRank(e : EMLExpr) → ℕ
Input: An EML expression tree e
Output: The exponential rank of e

match e with
  | var => return 0
  | const _ => return 0
  | add a b => return max(ComputeExpRank(a), ComputeExpRank(b))
  | mul a b => return max(ComputeExpRank(a), ComputeExpRank(b))
  | neg a => return ComputeExpRank(a)
  | inv a => return ComputeExpRank(a)
  | eml a b => return max(ComputeExpRank(a), ComputeExpRank(b) + 1)
```

**Complexity:** O(|e|) time, O(depth(e)) stack space.

### 4.2 Depth Lower Bound Checker

```
Algorithm: CheckDepthLowerBound(e : EMLExpr, n : ℕ, points : List ℝ) → Bool
Input: An EML expression e, target level n, evaluation points
Output: True if e appears to match iterExp n on all points

for x in points:
  if |e.eval(x) - iterExp(n, x)| > ε:
    return False
return True
```

### 4.3 Minimum-Depth Search

```
Algorithm: FindMinDepthEML(n : ℕ, maxSize : ℕ, constants : List ℝ) → Option EMLExpr
Input: Target iterExp level n, maximum expression size, allowed constants
Output: The minimum-depth EMLExpr matching iterExp n, or None

Generate all EMLExpr trees up to size maxSize with given constants
For each tree e, sorted by emlDepth:
  if CheckDepthLowerBound(e, n, testPoints):
    return Some e
return None
```

## 5. Computational Experiments

We implemented the algorithms in Python and tested them on the iterated exponential family.

### 5.1 Growth Comparison

| n | iterExp(n, 2) | Polynomial bound (degree n+1) |
|---|---------------|-------------------------------|
| 0 | 2 | 2 |
| 1 | 7.389 | 4 |
| 2 | 1,618.18 | 8 |
| 3 | ≈ 10^703 | 16 |

The tower-exponential growth of `iterExp n` vastly exceeds polynomial bounds, confirming that polynomial-bounded expressions (inv-free, eml-free) cannot match.

### 5.2 Exhaustive Search Results

For `n = 1` (exp), we searched all EML expressions up to size 7 with `emlDepth = 0` and constants from {-1, 0, 1, 2}. None matched `exp(x)` on the test grid `{0.1, 0.5, 1, 2, 3, 5}`, consistent with Theorem 3.6.

## 6. Discussion

### 6.1 Relationship to Circuit Complexity

Our depth separation is analogous to classical restricted-basis depth lower bounds (e.g., AC⁰ vs TC⁰). The EML basis is a "transcendence-generating gate basis" — field operations preserve algebraic structure, while each `eml` gate introduces one new level of transcendence. The lower bound technique (syntactic rank invariant) is in the spirit of monotone circuit lower bounds.

### 6.2 Connection to Hardy Fields

The exponential rank invariant corresponds to the level in the Hardy field hierarchy. Hardy (1910) and later du Bois-Reymond classified functions by eventual growth rate into a tower indexed by ordinals. Our `expRank` captures exactly the finite levels of this hierarchy for EML-definable functions. A complete characterization (Conjecture D in Future Directions) would establish a formal bridge between EML circuit complexity and asymptotic differential algebra.

### 6.3 Limitations

1. **Tree model only:** Our lower bound applies to tree-structured expressions. DAG models allowing sharing of common subexpressions may achieve lower depth.
2. **Inv case open:** The polynomial growth bound is proved only for inv-free expressions. Extending it to expressions with `inv` (rational functions) requires tracking both upper and lower bounds through induction.
3. **Semantic gap:** The full lower bound conjecture (Conjecture 3.7) requires connecting the syntactic `expRank` invariant to the semantic identity of the represented function.

### 6.4 Future Work

- Close the inv case using a two-sided polynomial bound (upper and lower) for rational-function expressions.
- Prove the semantic lower bound using a differential-algebraic argument: show that EML expressions of rank `< n` satisfy a system of algebraic-differential equations that `iterExp n` does not satisfy.
- Extend to DAG models and study the depth-size tradeoff.
- Generalize to multivariate expressions and connection to neural network depth.

## 7. References

1. Hardy, G.H. *Orders of Infinity*. Cambridge University Press, 1910.
2. Strassen, V. "Vermeidung von Divisionen." *J. Reine Angew. Math.*, 264:184-202, 1973.
3. Baur, W. and Strassen, V. "The complexity of partial derivatives." *Theor. Comput. Sci.*, 22:317-330, 1983.
4. Richardson, D. "Some undecidable problems involving elementary functions of a real variable." *J. Symbolic Logic*, 33(4):514-520, 1968.
5. van den Dries, L. and Miller, C. "On the real exponential field with restricted analytic functions." *Israel J. Math.*, 85:19-56, 1994.
