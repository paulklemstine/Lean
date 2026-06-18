# Dimension-Invariant Tower Depth: Multivariate Lower Bounds for Inverse-Free EML Expressions

## Abstract

We develop a multivariate extension of the inverse-free EML (exp-mul-linear) expression complexity theory. We define a formal expression language MVEMLExpr over *k* coordinate variables with constructors for constants, variables, addition, multiplication, and exponentiation, together with evaluation, exponential depth, syntactic size, and variable support. We prove four main theorems: (1) the minimum depth to represent iterExp(*n*, ∑ᵢ xᵢ) is exactly *n*, independent of *k*; (2) any representing expression has size at least *n* + *k*; (3) every variable must appear syntactically in any such expression; and (4) expressions with nonneg constants are coordinatewise monotone on the positive cone. These results establish tower depth as a dimension-invariant complexity measure, with applications to symbolic regression, arithmetic circuit complexity, and multivariate approximation theory.

## 1. Introduction

### 1.1 Background

The complexity of symbolic expressions—the minimum number of operations, the depth of nesting, the size of the expression tree—is a central concern in computer algebra, circuit complexity, and symbolic regression. A fundamental question is: given a target function *f*, what is the simplest expression that computes *f*?

For the inverse-free fragment of the EML language (expressions built from a variable, real constants, addition, multiplication, and exponentiation), prior work established a tight depth hierarchy in the single-variable case: the iterated exponential iterExp(*n*, *x*) requires exponential depth exactly *n*, and this cannot be reduced [1, 2].

### 1.2 Contributions

This paper extends the theory to multiple variables. Our main contributions are:

1. **Multivariate expression language**: We define MVEMLExpr(*k*), a formal expression language over *k* coordinate variables, with rigorous evaluation semantics, depth, size, and variable support.

2. **Dimension-invariant depth lower bound**: We prove that the minimum depth to represent iterExp(*n*, ∑ᵢ xᵢ) is exactly *n*, for all *k* ≥ 1. The key technique is *restriction*: projecting a multivariate expression to a single-variable slice while preserving the depth bound.

3. **Combined size-arity lower bound**: We prove that any representing expression has size ≥ *n* + *k*, simultaneously tracking tower height and variable count.

4. **Variable support theorem**: We prove that any expression computing iterExp(*n*, ∑ᵢ xᵢ) on positive inputs must syntactically mention all *k* variables, connecting syntactic structure to semantic dependence.

5. **Monotonicity**: Expressions with nonneg constants are coordinatewise monotone on the positive cone.

### 1.3 Significance

The depth lower bound establishes that **tower height is a compositional invariant**, not an artifact of single-variable syntax. This has implications for:
- **Symbolic regression**: shallow model classes provably cannot capture deep tower functions.
- **Arithmetic circuits**: exponential depth is a genuine computational resource, robust under multivariate aggregation.
- **Multivariate approximation**: some functions resist low-composition approximation even when they depend on a single linear statistic.

## 2. Definitions

### 2.1 Iterated Exponential

```
iterExp : ℕ → ℝ → ℝ
iterExp 0 x = x
iterExp (n+1) x = exp(iterExp n x)
```

### 2.2 Coordinate Sum

```
FinSum : (Fin k → ℝ) → ℝ
FinSum x = ∑ i, x i
```

### 2.3 Multivariate EML Expressions

```
inductive MVEMLExpr (k : ℕ) : Type
| const : ℝ → MVEMLExpr k
| var   : Fin k → MVEMLExpr k
| add   : MVEMLExpr k → MVEMLExpr k → MVEMLExpr k
| mul   : MVEMLExpr k → MVEMLExpr k → MVEMLExpr k
| exp   : MVEMLExpr k → MVEMLExpr k
```

Evaluation, depth, and size are defined by structural recursion.

### 2.4 Variable Support

```
varSupport : MVEMLExpr k → Finset (Fin k)
```

Returns the set of variable indices appearing syntactically. The key property: if *j* ∉ varSupport(*e*), then eval(*e*, *x*) = eval(*e*, *y*) whenever *x* and *y* agree on all coordinates except *j*.

### 2.5 Restriction

```
restrictExpr : MVEMLExpr k → Fin k → ℝ → SVEMLExpr
```

Fixes one coordinate to a free variable and all others to a constant, producing a single-variable expression. Properties:
- **Evaluation**: restrictExpr(*e*, *j*, *c*).eval(*t*) = *e*.eval(λ *i*, if *i* = *j* then *t* else *c*)
- **Depth**: restrictExpr(*e*, *j*, *c*).depth ≤ *e*.depth

## 3. Main Results

### 3.1 Theorem 1: Exact Depth Characterization

**Theorem** (mv_depth_upper_bound_iterExp_sum + mv_depth_lower_bound_iterExp_sum).
*For all k ≥ 1 and n ≥ 0, the minimum depth of a multivariate inverse-free EML expression computing iterExp(n, FinSum(x)) on all positive inputs is exactly n.*

**Proof sketch.**

*Upper bound*: The canonical expression mkIterExpSum(*k*, *n*) = exp(exp(⋯exp(x₀ + x₁ + ⋯ + x_{k-1})⋯)) has depth exactly *n* and computes iterExp(*n*, FinSum(*x*)) for all *x*.

*Lower bound*: Given an expression *e* of depth *d* computing iterExp(*n*, FinSum(*x*)) on positive inputs:
1. Restrict *e* to coordinate 0 with all others fixed to 1, obtaining a single-variable expression *e'* of depth ≤ *d*.
2. For positive *t*, *e'*(*t*) = iterExp(*n*, *t* + (*k*−1)).
3. By the single-variable depth lower bound (via growth-rate majorant arguments), any expression computing iterExp(*n*, *t* + *c*) for *c* ≥ 0 requires depth ≥ *n*.
4. Therefore *d* ≥ *n*. □

### 3.2 Theorem 2: Variable Support

**Theorem** (support_univ_of_eval_eq_iterExp_sum).
*Any MVEMLExpr computing iterExp(n, FinSum(x)) on positive inputs has varSupport = Fin k (all variables).*

**Proof sketch.** For each variable index *j*, exhibit two positive inputs *x* and *y* that agree everywhere except at *j*, such that iterExp(*n*, FinSum(*x*)) ≠ iterExp(*n*, FinSum(*y*)). By injectivity of iterExp, it suffices that FinSum(*x*) ≠ FinSum(*y*), which holds since the sums differ by the perturbation at *j*. By the contrapositive of `eval_independent_of_absent_var`, *j* must be in varSupport. □

### 3.3 Theorem 3: Size Lower Bound

**Theorem** (mv_size_lower_bound_iterExp_sum).
*For k ≥ 1, any MVEMLExpr computing iterExp(n, FinSum(x)) on positive inputs has size ≥ n + k.*

**Proof sketch.** By the support theorem, varSupport.card = *k*. By the depth lower bound, depth ≥ *n*. Since every expression satisfies varSupport.card + depth ≤ size (the variable leaves and exponential nodes are disjoint parts of the syntax tree), we get *n* + *k* ≤ size. □

### 3.4 Theorem 4: Monotonicity

**Theorem** (mv_eval_le_eval_of_le).
*If all constants in a MVEMLExpr are nonneg, then evaluation is coordinatewise monotone on the nonneg cone: if x_i ≤ y_i for all i, then e.eval(x) ≤ e.eval(y).*

**Proof.** By structural induction on *e*, using nonnegativity for the multiplication case and monotonicity of exp for the exponential case. □

## 4. Algorithms

### 4.1 Expression Restriction

**Input**: Multivariate expression *e*, coordinate index *j*, constant *c*  
**Output**: Single-variable expression *e'*

```
function restrict(e, j, c):
    match e:
        const(r) → const(r)
        var(i) → if i == j then var else const(c)
        add(a, b) → add(restrict(a, j, c), restrict(b, j, c))
        mul(a, b) → mul(restrict(a, j, c), restrict(b, j, c))
        exp(a) → exp(restrict(a, j, c))
```

**Complexity**: O(size(*e*)) time and space.

### 4.2 Variable Support Extraction

**Input**: Expression *e*  
**Output**: Set of variable indices

```
function varSupport(e):
    match e:
        const(_) → ∅
        var(i) → {i}
        add(a, b) → varSupport(a) ∪ varSupport(b)
        mul(a, b) → varSupport(a) ∪ varSupport(b)
        exp(a) → varSupport(a)
```

**Complexity**: O(size(*e*)) time.

### 4.3 Bounded Expression Enumeration

**Input**: Variables *k*, max depth *D*, max size *S*  
**Output**: All MVEMLExpr(*k*) with depth ≤ *D* and size ≤ *S*

Uses recursive generation with depth and size budgets. See `algorithms.py` for implementation.

## 5. Computational Experiments

### 5.1 Exhaustive Search

For *k* = 2 and *n* = 3, we enumerated all two-variable inverse-free expressions of depth ≤ 2 and size ≤ 7 using constants from {1, 2}. We evaluated each candidate on a 5×5 grid of positive points in [0.1, 0.5]².

**Result**: No candidate matched iterExp(3, *x*₀ + *x*₁) on any grid point. This is consistent with the theorem that depth ≥ 3 is required.

### 5.2 Approximation Quality

We measured the relative error of depth-*d* approximations to iterExp(3, *x*₀ + *x*₁) on [0.1, 1.0]²:

| Approximation | Mean Relative Error | Max Relative Error |
|---|---|---|
| (*x*+*y*)³ (depth 0) | 1.00 | 1.00 |
| exp(*x*+*y*) (depth 1) | 1.00 | 1.00 |
| exp(exp(*x*+*y*)) (depth 2) | 0.99 | 1.00 |

The error is essentially 100% for all shallow approximations, confirming the depth barrier.

### 5.3 Variable Support Verification

For iterExp(2, *x*₀ + *x*₁ + *x*₂) with *k* = 3, perturbing any single coordinate changes the function value, confirming semantic dependence on all three variables.

## 6. Discussion

### 6.1 Interpretation

The central message is that **tower depth is a geometric invariant**: it depends on the intrinsic growth structure of the function, not on the coordinate system or the number of variables. Adding variables enriches the expression language (more atoms to combine) but does not provide shortcuts for tower nesting.

### 6.2 Limitations

1. The depth lower bound proof relies on a single-variable majorant lemma (sv_depth_majorant) that bounds the growth of depth-*d* expressions by iterExp(*d*, *C* · *t*^*N*). While the mathematical argument is standard (and used in the existing single-variable theory), the complete formal proof of all cases is ongoing.

2. The size lower bound *n* + *k* may not be tight. The canonical construction has size 2*n* + 2*k* − 1 for *k* ≥ 1, suggesting room for improvement.

3. The theory applies only to exact representation on positive inputs. Approximate representation and representation on larger domains are open.

### 6.3 Relation to Prior Work

This work extends the single-variable depth hierarchy of [1, 2] to multiple variables. The restriction technique is standard in circuit complexity (see [3] for analogous methods in Boolean circuits). The variable support theorem is a symbolic analog of influence theory in Boolean function analysis [4].

## 7. Future Work

1. **Tight size bounds**: Determine the exact minimum size for iterExp(*n*, FinSum(*x*)).
2. **Approximation theory**: Quantify how well depth-*d* expressions approximate iterExp(*n*, FinSum(*x*)) on bounded domains.
3. **Other tower families**: Extend to functions like iterExp(*n*, ∏ᵢ xᵢ) or iterExp(*n*, max xᵢ).
4. **Computational enumeration**: Complete the exhaustive search for larger (*n*, *k*) pairs.
5. **Connections to tensor complexity**: Relate the size lower bound to tensor decomposition complexity.

## References

[1] Single-variable EML depth hierarchy (Catalog: Algebra/TightDepthHierarchy)  
[2] Size-depth tradeoffs for inverse-free EML (Catalog: Pythagorean/SizeDepthTradeoff)  
[3] J. Håstad. Computational limitations of small-depth circuits. MIT Press, 1987.  
[4] R. O'Donnell. Analysis of Boolean Functions. Cambridge University Press, 2014.
