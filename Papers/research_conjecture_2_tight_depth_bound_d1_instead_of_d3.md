# Tight Depth Hierarchy for Inverse-Free EML Expressions

## Abstract

We prove an exact depth separation theorem for the EML (Exp-Multiply Language) expression language: no inverse-free EML expression of depth *D* can represent the iterated exponential `iterExp n` for any *n > D*. This sharpens the previously known bound of *n ≥ D + 3* to the optimal threshold *n > D*, establishing that `emlDepth` is the exact stratification parameter for iterated exponential complexity. The proof introduces a novel **polynomial-argument tower majorant** technique, showing that depth-*D* expressions are bounded by `iterExp D (C · x^N)` rather than the cruder `iterExp (D+1) (C · x)`, which eliminates the slack in previous comparison chains. All results are machine-verified.

## 1. Introduction

### 1.1 Motivation

Expression languages provide a natural framework for studying the representational power of symbolic computation. The EML language, featuring the combined primitive `eml(a, b) = a · exp(b)`, captures the essential tension between algebraic composition and exponential growth. The fundamental question is: how much exponential nesting is required to represent a given function?

The iterated exponential family `iterExp n x = exp^[n](x)` provides canonical target functions at each growth level. Previous work established that depth-*D* inverse-free expressions cannot represent `iterExp n` for *n ≥ D + 3*, demonstrating a non-collapsing hierarchy. However, the "+3" slack left open whether the hierarchy is exactly stratified.

### 1.2 Main Result

**Theorem (Tight Depth Hierarchy).** For all natural numbers *D < n*, there is no inverse-free EML expression *e* with `emlDepth(e) ≤ D` such that `e.eval(x) = iterExp(n, x)` for all *x > 0*.

This is equivalent to saying that the canonical construction `emlExprIterExp(n)` — which has depth exactly *n* — is depth-optimal among inverse-free expressions.

### 1.3 Proof Innovation

The key innovation is the **polynomial-argument tower majorant**:

**Definition.** An expression *e* has a polynomial-argument tower majorant at level *k* if there exist *C > 0*, *N ∈ ℕ*, and *X₀* such that for all *x ≥ X₀*:
$$|e(x)| \leq \text{iterExp}(k, C \cdot x^N)$$

**Main Technical Lemma.** Every inverse-free EML expression *e* satisfies `HasPolyTowerMajorant(emlDepth(e), e)`.

This is sharper than the previous bound `HasTowerMajorant(emlDepth(e) + 1, e)` (with linear argument). The improvement from `emlDepth + 1` to `emlDepth` is what eliminates the slack.

## 2. Definitions and Notation

### 2.1 EML Expression Language

```
EMLExpr ::= var | const(c) | add(a, b) | mul(a, b) | neg(a) | inv(a) | eml(a, b)
```

**Evaluation semantics:**
- `var.eval(x) = x`
- `const(c).eval(x) = c`
- `add(a, b).eval(x) = a.eval(x) + b.eval(x)`
- `mul(a, b).eval(x) = a.eval(x) · b.eval(x)`
- `neg(a).eval(x) = -a.eval(x)`
- `inv(a).eval(x) = 1/a.eval(x)`
- `eml(a, b).eval(x) = a.eval(x) · exp(b.eval(x))`

**EML depth:** Counts maximum nesting of `eml` operations, with field operations (add, mul, neg, inv) being transparent:
- `emlDepth(var) = emlDepth(const) = 0`
- `emlDepth(add(a,b)) = emlDepth(mul(a,b)) = max(emlDepth(a), emlDepth(b))`
- `emlDepth(neg(a)) = emlDepth(inv(a)) = emlDepth(a)`
- `emlDepth(eml(a,b)) = 1 + max(emlDepth(a), emlDepth(b))`

**Inverse-free predicate:** `noInv(e)` holds if `e` contains no `inv` nodes.

### 2.2 Iterated Exponential

```
iterExp(0, x) = x
iterExp(n+1, x) = exp(iterExp(n, x))
```

### 2.3 Growth Rank

**Definition.** The growth rank `growthRank(e)` is defined structurally:
- `growthRank(var) = growthRank(const) = 0`
- `growthRank(add/mul) = max of children`
- `growthRank(neg/inv) = same as child`
- `growthRank(eml(a,b)) = 1 + max(growthRank(a), growthRank(b))`

**Theorem.** `growthRank(e) ≤ emlDepth(e)` for all `e`.

## 3. Main Results

### 3.1 Absorption Lemmas

**Lemma (Increment absorption).** For *D ≥ 1* and *t ≥ 0*:
$$\text{iterExp}(D, t) + 1 \leq \text{iterExp}(D, t + 1)$$

*Proof.* By induction on *D*. For *D = 1*: `exp(t+1) = e · exp(t) ≥ exp(t) + 1` since `(e-1) · exp(t) ≥ e-1 > 1` when `t ≥ 0`.

**Lemma (Double absorption).** For *D ≥ 1* and *t ≥ 0*:
$$2 \cdot \text{iterExp}(D, t) \leq \text{iterExp}(D, t + 1)$$

*Proof.* For *D = 1*: `exp(t+1)/exp(t) = e > 2`. Inductive step uses `iterExp(D, t) ≥ 1`.

**Lemma (Sum absorption).** For *D ≥ 1*, *C₁, C₂ > 0*:
$$\text{iterExp}(D, C_1 x^{N_1}) + \text{iterExp}(D, C_2 x^{N_2}) \leq \text{iterExp}(D, C x^N)$$
for appropriate *C, N* and large *x*.

*Proof.* Lift both terms to `iterExp D (max(C₁,C₂) · x^{max(N₁,N₂)})` by monotonicity, apply double absorption, then absorb the "+1" into the polynomial coefficient.

### 3.2 Structural Growth Bound

**Theorem (Sharp majorization).** For any inverse-free EML expression *e*:
$$\exists C > 0, N \in \mathbb{N}, X_0: \forall x \geq X_0,\; |e(x)| \leq \text{iterExp}(\text{emlDepth}(e), C \cdot x^N)$$

*Proof.* By structural induction on *e*:

1. **var/const**: Bounded by polynomials (tower level 0). ✓
2. **neg**: Same bound as child. ✓
3. **add**: Sum of two tower-*D* terms with polynomial arguments stays at level *D* by sum absorption. For *D = 0*, direct polynomial addition. ✓
4. **mul**: Product of two tower-*D* terms stays at level *D*. For *D ≥ 1*, use `exp(s)·exp(t) = exp(s+t)` and sum absorption. For *D = 0*, multiply polynomials. ✓
5. **eml(a,b)**: The critical case. `|a·exp(b)| ≤ |a|·exp(|b|)`. By IH, `|a| ≤ iterExp(Dₐ, Cₐx^{Nₐ})` and `|b| ≤ iterExp(D_b, C_bx^{N_b})`. Lift to level *D = max(Dₐ, D_b)*. Then `|a|·exp(|b|) ≤ iterExp(D, ...)·exp(iterExp(D, ...))`. Use `t ≤ exp(t)` and `exp(s+t) = exp(s)·exp(t)` to bound the product by `exp(sum)`, then apply sum absorption to get `iterExp(D+1, C'x^{N'})`. Since `D + 1 = emlDepth(eml(a,b))`, done. ✓

### 3.3 Domination Lemma

**Theorem.** For any *C* and *N*:
$$\exists X_0: \forall x \geq X_0,\; \text{iterExp}(k, C \cdot x^N) < \text{iterExp}(k+1, x)$$

*Proof.* By induction on *k*. Base: `C·x^N < exp(x)` by polynomial-exponential domination. Step: apply `exp` monotonicity to the inductive hypothesis.

### 3.4 Tight Separation

**Theorem (Main).** For *D < n*, no inverse-free EML expression of depth ≤ *D* represents `iterExp(n)` on positive reals.

*Proof.* Suppose for contradiction that *e* is such an expression. By the sharp majorization theorem, `|e(x)| ≤ iterExp(D, C·x^N)` for large *x*. By the domination lemma, `iterExp(D, C·x^N) < iterExp(D+1, x)` for large *x*. Since *D+1 ≤ n*, by level monotonicity `iterExp(D+1, x) ≤ iterExp(n, x)`. But `e(x) = iterExp(n, x)` for *x > 0*, so `iterExp(n, x) ≤ |e(x)| < iterExp(n, x)`, contradiction.

## 4. Cross-Domain Connections

### 4.1 Circuit Complexity

The depth hierarchy theorem is the exact analogue of bounded-depth circuit lower bounds:

| Circuit Complexity | EML Depth Separation |
|---|---|
| AC⁰ circuits | Depth-bounded EMLExpr |
| Depth *d* circuits compute | Growth level *d* functions |
| PARITY escapes AC⁰ | `iterExp(n)` escapes depth *n-1* |
| Sharp: depth *d* ≠ depth *d+1* | Sharp: depth *D* ≠ depth *D+1* |

### 4.2 Fast-Growing Hierarchies

The iterated exponential `iterExp(n)` corresponds to level *ω·n* in the fast-growing hierarchy. Our theorem shows that EML depth precisely tracks this ordinal classification.

### 4.3 Symbolic Dynamics

Viewing `exp` as a dynamical system, our result proves that *n*-fold iteration of `exp` cannot be "symbolically compressed" below depth *n*, establishing an irreducibility result for iterated maps.

## 5. Computational Experiments

See `demo.py` for interactive demonstrations:
- Growth comparison of depth-*D* expressions vs. `iterExp(n)` for *n > D*
- Visualization of the separation gap
- Numerical verification of the absorption lemmas

## 6. Discussion

### 6.1 Sharpness

The bound *n > D* is exactly tight: `emlExprIterExp(n)` achieves depth *n* and computes `iterExp(n)`. No lower depth suffices, and no higher depth is needed.

### 6.2 Role of the Inverse-Free Hypothesis

The `noInv` hypothesis is essential. With inverses, expressions can compute rational functions, and the interaction between `1/exp(b)` and `exp(b)` could potentially cancel tower levels. Extending the result to expressions with controlled inverses is an important open problem.

### 6.3 Improvement over D+3

The old proof bounded depth-*D* expressions by `iterExp(D+1, C·x)` (linear argument at one level higher), then needed two additional level comparisons. Our polynomial-argument bound `iterExp(D, C·x^N)` (same level, polynomial argument) reduces this to a single comparison step.

## 7. Future Work

1. **Inverse extensions:** Prove the hierarchy for expressions allowing inverses away from zero.
2. **Size-depth tradeoffs:** Establish exponential size lower bounds for depth-bounded representations.
3. **DAG sharing:** Determine whether sharing subexpressions (DAG representations) can reduce depth.
4. **Higher-order analogues:** Extend to lambda calculus or higher-order expression languages.

## References

1. Sipser, M. "Borel Sets and Circuit Complexity." STOC 1983.
2. Ajtai, M. "Σ₁¹-Formulae on Finite Structures." Ann. Pure Appl. Logic, 1983.
3. Löb, M.H. and Wainer, S.S. "Hierarchies of number theoretic functions." Archiv für mathematische Logik, 1970.
