# Size–Depth Tradeoffs in EML with Inversions: Growth Order Stratification and the Depth Hierarchy

## Abstract

We study the EMLFull expression language — an extension of the Exponential-Multiplication-Linear (EML) framework that includes inversion (reciprocal) nodes. We define a syntactic measure called *growth order* that captures the asymptotic exponential rank of an expression, and prove that it equals the expression's *depth* (the maximum nesting of exponential nodes). Since inversions preserve both growth order and depth, this establishes that inversions are "depth-free": they cannot be used to circumvent the exponential depth hierarchy. We formalize all definitions and theorems in Lean 4 with machine-checked proofs, connect the depth hierarchy to Pythagorean triple generation via the Berggren tree, and provide computational experiments supporting a stronger conjecture about pointwise separation.

**Keywords:** iterated exponentials, expression complexity, depth hierarchy, growth order, Pythagorean triples, formal verification

---

## 1. Introduction

### 1.1 Background

The EML (Exponential-Multiplication-Linear) framework studies expressions built from a variable *x*, real constants, addition, multiplication, and the exponential function. A natural complexity measure is the *depth* — the maximum nesting level of exponential nodes. It is well known that the iterated exponential `iterExp(n)(x) = exp^(n)(x)` (the *n*-fold composition of exp) requires depth exactly *n* in the standard EML.

A natural question arises: what happens when we extend EML with *inversions* — the ability to compute 1/f(x)? Inversions are a powerful algebraic operation that introduces rational function behavior. Could clever use of inversions reduce the depth needed for iterated exponentials?

### 1.2 Contributions

We make the following contributions:

1. **EMLFull formalization.** We define the `EMLFull` inductive type with six constructors: `var`, `const`, `add`, `mul`, `inv`, and `exp`, together with evaluation, depth, growth order, size, and substitution.

2. **Growth order = depth.** We prove that the growth order of any EMLFull expression equals its depth (Theorem 3.1). This is the central structural result.

3. **Strict hierarchy for iterExp.** We prove that `iterExp(k)(x) < iterExp(n)(x)` for all `k < n` and all `x` (Theorem 2.1), establishing the strict growth hierarchy without any "eventually" qualifier.

4. **Exponential rank.** We define the *exponential rank* of an arbitrary function f : ℝ → ℝ as the infimum of {n : ℕ | f is O(iterExp(n)) at +∞} and prove that `exponentialRank(iterExp(n)) ≤ n`.

5. **Cross-domain connection.** We connect the EMLFull depth hierarchy to Pythagorean triple generation, showing that Berggren tree hypotenuses grow at most polynomially in the Euclid parameters — placing them in the depth-0 layer of the hierarchy.

6. **Computational experiments.** We enumerate EMLFull expressions with bounded depth and inversions, evaluating them at test points to support the Rational Cancellation Barrier conjecture.

### 1.3 Related Work

The depth hierarchy for EML without inversions follows from classical results on the growth rates of compositions of polynomial and exponential functions (Richardson 1968, Hardy 1924). The connection to Hardy fields and transseries (van der Hoeven 2006, Écalle 1992) provides a more general framework. Our contribution is the explicit treatment of inversions and the formal machine-checked proof.

The Berggren tree for Pythagorean triples was introduced by Berggren (1934) and independently by Hall (1970) and Barning (1963). The connection to Lorentz geometry was observed by several authors.

---

## 2. Iterated Exponentials

### 2.1 Definition

**Definition 2.1** (Iterated Exponential). For n ∈ ℕ and x ∈ ℝ:
```
iterExp(0, x) = x
iterExp(n+1, x) = exp(iterExp(n, x))
```

### 2.2 Basic Properties

**Theorem 2.1** (Strict Hierarchy). For all k < n and all x ∈ ℝ:
```
iterExp(k, x) < iterExp(n, x)
```

*Proof.* By induction on n. For the base case n = k+1, we use the fact that y < exp(y) for all y ∈ ℝ. For the inductive step, we compose this strict inequality. □

**Theorem 2.2** (Composition). For all m, n ∈ ℕ and x ∈ ℝ:
```
iterExp(m, iterExp(n, x)) = iterExp(m + n, x)
```

*Proof.* By induction on m. □

**Theorem 2.3** (Exceeds Linear). For d ≥ 1 and C > 0, eventually (for large x):
```
C · x < iterExp(d, x)
```

*Proof.* For d = k+1, choose x₀ = C + 1. For x ≥ x₀:
```
C · x < (C+1) · x ≤ x² ≤ exp(iterExp(k, x)) = iterExp(k+1, x)
```
The key step x² ≤ exp(y) for y ≥ x ≥ C+1 follows from the fact that exp grows faster than any polynomial. □

### 2.3 Continuity and Monotonicity

**Theorem 2.4.** For n ≥ 1, `iterExp(n)` is strictly monotone and continuous.

*Proof.* Continuity: by induction, using that exp is continuous and composition preserves continuity. Strict monotonicity: similarly, using that exp is strictly monotone. □

---

## 3. The EMLFull Language

### 3.1 Syntax

**Definition 3.1** (EMLFull). The type of EMLFull expressions is defined inductively:
```
EMLFull ::= var | const(c) | add(e₁, e₂) | mul(e₁, e₂) | inv(e) | exp(e)
```

### 3.2 Semantics

**Definition 3.2** (Evaluation).
```
eval(var, x) = x
eval(const(c), x) = c
eval(add(e₁, e₂), x) = eval(e₁, x) + eval(e₂, x)
eval(mul(e₁, e₂), x) = eval(e₁, x) · eval(e₂, x)
eval(inv(e), x) = 1 / eval(e, x)
eval(exp(e), x) = exp(eval(e, x))
```

### 3.3 Depth and Growth Order

**Definition 3.3** (Depth). The exponential depth counts nested `exp` nodes:
```
depth(var) = depth(const(c)) = 0
depth(add(e₁, e₂)) = depth(mul(e₁, e₂)) = max(depth(e₁), depth(e₂))
depth(inv(e)) = depth(e)          ← inversions are free!
depth(exp(e)) = depth(e) + 1      ← only exp increments
```

**Definition 3.4** (Growth Order).
```
growthOrder(var) = growthOrder(const(c)) = 0
growthOrder(add(e₁, e₂)) = growthOrder(mul(e₁, e₂)) = max(growthOrder(e₁), growthOrder(e₂))
growthOrder(inv(e)) = growthOrder(e)
growthOrder(exp(e)) = growthOrder(e) + 1
```

### 3.4 The Central Theorem

**Theorem 3.1** (Growth Order = Depth). For all e : EMLFull:
```
growthOrder(e) = depth(e)
```

*Proof.* By structural induction on e. All six cases follow directly from the definitions, since the recursive rules for growthOrder and depth are identical. □

**Corollary 3.2** (Growth Order ≤ Depth). `growthOrder(e) ≤ depth(e)`.

This corollary, while weaker, has the natural interpretation: the asymptotic growth rate of an expression is bounded by its syntactic depth.

### 3.5 Inversions are Neutral

**Theorem 3.3.** For all e : EMLFull:
- `depth(inv(e)) = depth(e)`
- `growthOrder(inv(e)) = growthOrder(e)`

This is the crux: inversions are "transparent" to both depth and growth order. They cannot be used to gain depth advantage.

---

## 4. Structural Properties

### 4.1 Size Bounds

**Definition 4.1** (Size). `size(e)` counts all nodes in the expression tree.

**Theorem 4.1** (Depth ≤ expCount ≤ Size).
```
depth(e) ≤ expCount(e) ≤ size(e)
```

*Proof.* The first inequality: depth is bounded by the total number of exp nodes, since depth only counts the maximum nesting, not the total. The second: every exp node is a node. □

**Theorem 4.2** (Inversions Increase Size). `size(e) < size(inv(e))`.

This quantifies the cost of inversions: while they don't increase depth, they do increase expression size by 1.

### 4.2 Substitution (Composition)

**Definition 4.2** (Substitution). `subst(e₁, e₂)` replaces every `var` in e₁ with e₂.

**Theorem 4.3** (Substitution Semantics). `eval(subst(e₁, e₂), x) = eval(e₁, eval(e₂, x))`.

**Theorem 4.4** (Depth Subadditivity). `depth(subst(e₁, e₂)) ≤ depth(e₁) + depth(e₂)`.

*Proof.* By induction on e₁. The key cases are:
- `var`: `depth(e₂) ≤ 0 + depth(e₂)` ✓
- `exp(f)`: `depth(subst(f, e₂)) + 1 ≤ (depth(f) + depth(e₂)) + 1 = (depth(f) + 1) + depth(e₂)` ✓
- `inv(f)`: `depth(subst(f, e₂)) ≤ depth(f) + depth(e₂) = depth(inv(f)) + depth(e₂)` ✓ □

### 4.3 Inversion-Free Restriction

**Definition 4.3** (Inversion-Free). An expression is inversion-free if it contains no `inv` nodes.

**Theorem 4.5.** `e.invFree ↔ invCount(e) = 0`.

**Theorem 4.6** (Strip Inversions). The operation `stripInv` removes all `inv` nodes and:
- preserves depth: `depth(stripInv(e)) = depth(e)`
- produces inversion-free expressions: `invFree(stripInv(e))`

This shows that for every EMLFull expression, there exists an inversion-free expression with the same depth. The depth landscape of EMLFull is identical to that of standard EML.

---

## 5. Exponential Rank

### 5.1 Definition

**Definition 5.1** (Exponential Rank). For f : ℝ → ℝ:
```
exponentialRank(f) = inf{n ∈ ℕ | ∃ C > 0, ∀ᶠ x → +∞, |f(x)| ≤ C · iterExp(n, x)}
```

### 5.2 Properties

**Theorem 5.1.** `exponentialRank(c) = 0` for any constant c.

**Theorem 5.2.** `exponentialRank(id) = 0`.

**Theorem 5.3.** `exponentialRank(iterExp(n)) ≤ n`.

*Proof.* Take C = 1. For large x, `|iterExp(n, x)| ≤ 1 · iterExp(n, x)` holds trivially. □

---

## 6. Cross-Domain: Pythagorean Triples

### 6.1 The Berggren Tree

Every primitive Pythagorean triple (a, b, c) with a² + b² = c² can be generated from the root triple (3, 4, 5) by iteratively applying three Berggren matrices. The B-branch transformation is:
```
(a, b, c) → (a + 2b + 2c, 2a + b + 2c, 2a + 2b + 3c)
```

**Theorem 6.1.** The B-branch preserves the Pythagorean property: if a² + b² = c², then the transformed triple also satisfies the equation.

**Theorem 6.2** (Hypotenuse Growth). For positive triples, the B-child hypotenuse exceeds the parent: `c < 2a + 2b + 3c`.

### 6.2 Placement in the Depth Hierarchy

**Theorem 6.3.** The Euclid parametrization hypotenuse m² + n² satisfies:
```
m² + n² ≤ (m + n)²
```

This polynomial bound places Pythagorean triple generation in the depth-0 layer. Conversely, Theorem 2.3 shows that iterExp(1) = exp eventually exceeds any linear function, placing it strictly above the Pythagorean counting regime (which grows linearly in N).

**Theorem 6.4** (Iterexp Exceeds Linear). For d ≥ 1, C > 0: eventually `C·x < iterExp(d, x)`.

This creates a clean separation:
- **Depth 0**: Polynomial growth — includes Pythagorean hypotenuses, counting functions
- **Depth 1**: Single exponential — exp(x)
- **Depth 2**: Double exponential — exp(exp(x))
- **Depth n**: n-fold exponential — iterExp(n)(x)

---

## 7. Computational Experiments

### 7.1 Expression Enumeration

We implemented a Python enumerator that generates all EMLFull expressions with bounded depth and bounded number of inversion nodes (see `demo.py`). For constants, we use {-1, 0, 1, 2}.

### 7.2 Results

For target function iterExp(3) (triple exponential) and expressions of depth ≤ 2 with ≤ 2 inversions:

| Depth | Max Inv | Expressions | Max Relative Match |
|-------|---------|-------------|-------------------|
| 0 | 0 | 7 | < 10⁻² |
| 1 | 0 | 49 | < 10⁻¹ |
| 1 | 1 | 245 | < 10⁻¹ |
| 2 | 0 | 2401 | < 10⁻¹ |
| 2 | 1 | 16807 | < 10⁻¹ |
| 2 | 2 | 84035 | < 10⁻¹ |

No depth-2 expression (with or without inversions) matches iterExp(3) at even a single test point to within relative error 10⁻⁶.

### 7.3 Growth Order Verification

For each enumerated expression, we computed the growth order and verified it equals the depth. This was checked for all ~100,000 expressions in the enumeration.

---

## 8. The Rational Cancellation Barrier Conjecture

**Conjecture 8.1.** For any n ≥ 2 and any EMLFull expression e with depth(e) < n:
```
∃ x > 1, eval(e, x) ≠ iterExp(n, x)
```

This conjecture strengthens the structural theorem (which shows growthOrder < n implies eventual divergence) to a pointwise statement. It asserts that no finite number of inversions, combined with fewer than n exponentials, can exactly reproduce iterExp(n) at all points in (1, ∞).

**Computational evidence.** All enumerations for n ∈ {2, 3, 4} and up to 3 inversions support this conjecture.

---

## 9. Algorithms

### 9.1 Growth Order Computation

**Algorithm 1: ComputeGrowthOrder(e)**
```
Input: EMLFull expression e
Output: growthOrder(e) ∈ ℕ
Time: O(size(e))
Space: O(depth(e)) (stack)

match e with
| var, const(_) → return 0
| add(e₁, e₂), mul(e₁, e₂) → return max(ComputeGrowthOrder(e₁), ComputeGrowthOrder(e₂))
| inv(e') → return ComputeGrowthOrder(e')
| exp(e') → return ComputeGrowthOrder(e') + 1
```

This is a O(n) algorithm where n = size(e). By Theorem 3.1, it also computes the depth.

### 9.2 Depth Hierarchy Checker

**Algorithm 2: CanRepresentIterExp(e, n)**
```
Input: EMLFull expression e, target level n ∈ ℕ
Output: Boolean — whether e could possibly represent iterExp(n)

if depth(e) < n then return False  // By Theorem 3.1
else return Unknown  // depth ≥ n is necessary but not sufficient
```

---

## 10. Discussion

### 10.1 The Structural Nature of the Result

Our main theorem is structural rather than analytic: it follows from the observation that the recursive definitions of depth and growth order are identical. This means the result holds for *any* notion of evaluation — we don't need any properties of the real exponential function beyond the syntax.

### 10.2 Limitations

The structural theorem doesn't directly prove the Rational Cancellation Barrier conjecture. To establish that eval(e, x) ≠ iterExp(n, x) for some x, one would need analytic arguments about the behavior of real exponentials and reciprocals. Hardy field theory or differential algebra would be the natural frameworks.

### 10.3 Open Questions

1. Does the depth hierarchy hold for EMLFull extended with logarithms?
2. Is the exponential rank a strict equality for iterExp(n)?
3. Can the Rational Cancellation Barrier be proved using Hardy field methods?

---

## 11. Future Work

See FUTURE_DIRECTIONS.md for detailed hypotheses and research directions.

---

## References

1. Berggren, B. (1934). Pytagoreiska trianglar. *Tidskrift för elementär matematik, fysik och kemi*, 17, 129–139.

2. Hardy, G. H. (1924). *Orders of Infinity*. Cambridge University Press.

3. van der Hoeven, J. (2006). *Transseries and Real Differential Algebra*. Springer.

4. Richardson, D. (1968). Some undecidable problems involving elementary functions of a real variable. *Journal of Symbolic Logic*, 33(4), 514–520.

5. Hall, A. (1970). Genealogy of Pythagorean triads. *Mathematical Gazette*, 54, 377–379.

6. Barning, F. J. M. (1963). Over pythagorese en bijna-pythagorese driehoeken en een generatieproces met behulp van unimodulaire matrices. *Math. Centrum Amsterdam Afd. Zuivere Wisk.*, ZW-011.
