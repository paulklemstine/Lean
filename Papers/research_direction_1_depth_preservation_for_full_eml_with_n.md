# Depth Preservation for Full EML with Negation: A Differential Invariant for Exponential-Multiplicative Expressions

## Abstract

We define symbolic differentiation on the full EML (exponential-multiplicative language) grammar — including negation — and prove that the exponential nesting depth (`emlDepth`) is a differential invariant: differentiation never increases depth. This extends prior results on the positive fragment to the complete grammar, establishing that each depth stratum `{ e | emlDepth e ≤ k }` is closed under arbitrary iterated differentiation. We introduce the concept of *differential depth-boundedness* and prove a characterization theorem: an expression is differentially depth-bounded at level k if and only if its depth is at most k. We further prove semantic correctness of the symbolic derivative (agreement with the analytic derivative via `HasDerivAt`) and demonstrate the invariance of depth strata as forward-invariant sets under the derivative operator. All results are formalized and machine-verified in Lean 4 with Mathlib.

**Keywords:** differential algebra, Hardy fields, symbolic differentiation, expression complexity, formal verification, automatic differentiation, exponential circuits, machine learning expressivity, rewrite systems, depth invariant

---

## 1. Introduction

### 1.1 Motivation

The EML (exponential-multiplicative language) is a symbolic expression language whose transcendental content enters through a single primitive: `eml(a, b) = a · exp(b)`. This operation captures the fundamental structure of exponential growth — a coefficient modulated by an exponential phase — and generates, through field operations, a rich class of expressions that includes polynomials, exponentials, Gaussian functions, and iterated towers of exponentials.

The central question of this paper is: **does symbolic differentiation preserve the structural complexity of EML expressions?** Specifically, if we measure complexity by `emlDepth` — the maximum nesting depth of `eml` operations — does differentiation increase this measure?

### 1.2 Prior Work

The positive fragment of EML (without negation) was previously studied in the Catalog's `DiffClosure.lean`, which established:
1. Semantic correctness of symbolic differentiation for `PosEMLExpr`.
2. A depth bound `depth(deriv(e)) ≤ depth(e) + 1` for the positive fragment.
3. Hardy level classification: expressions of depth d have Hardy level d.

The `+1` bound in the positive fragment was an artifact of the product rule creating expressions whose depth could, in principle, exceed the original by one level. The present work shows that for the full `EmlExpr` grammar with the `eml` constructor (which combines multiplication and exponentiation in a single node), the bound is actually `≤` rather than `≤ +1`.

### 1.3 Main Contributions

1. **`EmlExpr.deriv`**: A symbolic differentiation operator on the full EML grammar, handling negation and the `eml` constructor directly.

2. **Depth preservation** (Theorem 3.1): `emlDepth(deriv(e)) ≤ emlDepth(e)` for all expressions `e`. This is strictly stronger than the positive-fragment bound.

3. **Iterated depth stability** (Theorem 3.2): `emlDepth(deriv^[n](e)) ≤ emlDepth(e)` for all n ∈ ℕ.

4. **Differential depth-boundedness characterization** (Theorem 3.3): An expression is differentially depth-bounded at level k iff `emlDepth(e) ≤ k`.

5. **Set-theoretic closure** (Theorem 3.4): `deriv` maps `{e | emlDepth(e) ≤ k}` into itself.

6. **Semantic correctness** (Theorem 3.5): The symbolic derivative agrees with the analytic derivative at every point.

7. **Computational verification**: An enumeration-based checker confirms the theorem for all expressions up to bounded size and depth.

---

## 2. Definitions and Notation

### 2.1 The EML Grammar

The full EML expression language is defined inductively:

```
EmlExpr ::= var              -- the variable x
          | const(c)         -- real constant c ∈ ℝ
          | add(a, b)        -- a + b
          | mul(a, b)        -- a · b
          | neg(a)           -- -a
          | eml(a, b)        -- a · exp(b)
```

**Evaluation** at a point x ∈ ℝ:
- `eval(var, x) = x`
- `eval(const(c), x) = c`
- `eval(add(a, b), x) = eval(a, x) + eval(b, x)`
- `eval(mul(a, b), x) = eval(a, x) · eval(b, x)`
- `eval(neg(a), x) = -eval(a, x)`
- `eval(eml(a, b), x) = eval(a, x) · exp(eval(b, x))`

### 2.2 EML Depth

The depth function measures exponential nesting:

```
emlDepth(var) = 0
emlDepth(const(c)) = 0
emlDepth(add(a, b)) = max(emlDepth(a), emlDepth(b))
emlDepth(mul(a, b)) = max(emlDepth(a), emlDepth(b))
emlDepth(neg(a)) = emlDepth(a)
emlDepth(eml(a, b)) = 1 + max(emlDepth(a), emlDepth(b))
```

### 2.3 Symbolic Differentiation

We define `deriv : EmlExpr → EmlExpr` by structural recursion:

```
deriv(var) = const(1)
deriv(const(c)) = const(0)
deriv(add(a, b)) = add(deriv(a), deriv(b))
deriv(mul(a, b)) = add(mul(deriv(a), b), mul(a, deriv(b)))
deriv(neg(a)) = neg(deriv(a))
deriv(eml(a, b)) = eml(add(deriv(a), mul(a, deriv(b))), b)
```

The key clause is the `eml` case: differentiating `a · exp(b)` yields `(a' + a · b') · exp(b)`. The exponential shell `exp(b)` is preserved; new complexity enters only through the coefficient.

### 2.4 Differential Depth-Boundedness

**Definition.** An expression e is *differentially depth-bounded* at level k if:
```
DifferentiallyDepthBounded(k, e) ≡ ∀ n ∈ ℕ, emlDepth(deriv^[n](e)) ≤ k
```

**Definition.** The *depth-closed set* at level k is:
```
DepthClosed(k) = { e ∈ EmlExpr | emlDepth(e) ≤ k }
```

---

## 3. Main Results

### Theorem 3.1 (Depth Preservation)

**Statement.** For all `e : EmlExpr`, `emlDepth(deriv(e)) ≤ emlDepth(e)`.

**Proof.** By structural induction on e.

- **Case `var`:** `deriv(var) = const(1)`, depth 0 ≤ 0. ✓
- **Case `const(c)`:** `deriv(const(c)) = const(0)`, depth 0 ≤ 0. ✓
- **Case `add(a, b)`:** `deriv(add(a,b)) = add(deriv(a), deriv(b))`. By IH, `emlDepth(deriv(a)) ≤ emlDepth(a)` and `emlDepth(deriv(b)) ≤ emlDepth(b)`. Thus `max(emlDepth(deriv(a)), emlDepth(deriv(b))) ≤ max(emlDepth(a), emlDepth(b))`. ✓
- **Case `mul(a, b)`:** `deriv(mul(a,b)) = add(mul(deriv(a), b), mul(a, deriv(b)))`. The depth of `mul(deriv(a), b)` is `max(emlDepth(deriv(a)), emlDepth(b)) ≤ max(emlDepth(a), emlDepth(b))`. Similarly for the other summand. ✓
- **Case `neg(a)`:** `deriv(neg(a)) = neg(deriv(a))`, and `emlDepth(neg(·)) = emlDepth(·)`. ✓
- **Case `eml(a, b)`:** This is the critical case.
  ```
  deriv(eml(a, b)) = eml(add(deriv(a), mul(a, deriv(b))), b)
  ```
  The depth of the result is:
  ```
  1 + max(emlDepth(add(deriv(a), mul(a, deriv(b)))), emlDepth(b))
  ```
  We bound the coefficient depth:
  ```
  emlDepth(add(deriv(a), mul(a, deriv(b))))
    = max(emlDepth(deriv(a)), max(emlDepth(a), emlDepth(deriv(b))))
    ≤ max(emlDepth(a), max(emlDepth(a), emlDepth(b)))   [by IH]
    = max(emlDepth(a), emlDepth(b))
  ```
  Therefore:
  ```
  depth(result) = 1 + max(max(emlDepth(a), emlDepth(b)), emlDepth(b))
               = 1 + max(emlDepth(a), emlDepth(b))
               = emlDepth(eml(a, b))    ✓
  ```

### Theorem 3.2 (Iterated Depth Stability)

**Statement.** For all n ∈ ℕ and e : EmlExpr, `emlDepth(deriv^[n](e)) ≤ emlDepth(e)`.

**Proof.** By induction on n.
- **Base (n = 0):** `deriv^[0](e) = e`, so `emlDepth(e) ≤ emlDepth(e)`. ✓
- **Step (n → n+1):** Using `Function.iterate_succ'`:
  ```
  deriv^[n+1](e) = deriv(deriv^[n](e))
  ```
  By Theorem 3.1: `emlDepth(deriv(deriv^[n](e))) ≤ emlDepth(deriv^[n](e))`.
  By IH: `emlDepth(deriv^[n](e)) ≤ emlDepth(e)`.
  By transitivity: `emlDepth(deriv^[n+1](e)) ≤ emlDepth(e)`. ✓

### Theorem 3.3 (Characterization of Differential Depth-Boundedness)

**Statement.** For all k ∈ ℕ and e : EmlExpr:
```
DifferentiallyDepthBounded(k, e) ↔ emlDepth(e) ≤ k
```

**Proof.**
- **(⇒):** Take n = 0: `emlDepth(deriv^[0](e)) = emlDepth(e) ≤ k`.
- **(⇐):** For all n, `emlDepth(deriv^[n](e)) ≤ emlDepth(e) ≤ k` by Theorem 3.2.

This characterization is significant: to determine whether an expression is differentially depth-bounded, one need only check the expression itself — not its infinitely many derivatives.

### Theorem 3.4 (Set-Theoretic Closure)

**Statement.** For all k ∈ ℕ, `deriv` maps `DepthClosed(k)` into `DepthClosed(k)`.

**Proof.** If `e ∈ DepthClosed(k)`, then `emlDepth(e) ≤ k`, so `emlDepth(deriv(e)) ≤ emlDepth(e) ≤ k` by Theorem 3.1, hence `deriv(e) ∈ DepthClosed(k)`. ✓

**Dynamical interpretation.** Viewing `deriv` as a discrete dynamical system on `EmlExpr`, each `DepthClosed(k)` is a forward-invariant region.

### Theorem 3.5 (Semantic Correctness)

**Statement.** For all e : EmlExpr and x ∈ ℝ:
```
HasDerivAt (fun y ↦ eval(e, y)) (eval(deriv(e), x)) x
```

**Proof.** By structural induction on e, using Mathlib's `HasDerivAt` combinators:
- Constants and variables: `hasDerivAt_const`, `hasDerivAt_id`.
- Addition: `HasDerivAt.add`.
- Multiplication: `HasDerivAt.mul` (product rule).
- Negation: `HasDerivAt.neg`.
- `eml(a, b)`: Decompose as `eval(a, ·) · exp(eval(b, ·))` and apply `HasDerivAt.mul` with `HasDerivAt.exp`. The algebraic identity `a' · exp(b) + a · (b' · exp(b)) = (a' + a · b') · exp(b)` closes the argument. ✓

### Theorem 3.6 (Negation Transparency)

**Statement.** For all e : EmlExpr:
```
emlDepth(deriv(neg(e))) = emlDepth(deriv(e))
```

**Proof.** `deriv(neg(e)) = neg(deriv(e))`, and `emlDepth(neg(·)) = emlDepth(·)`. ✓

---

## 4. Algorithms

### 4.1 Depth-Preserving Differentiation Algorithm

```
Algorithm: DERIV(e)
Input: EML expression e
Output: EML expression e' with emlDepth(e') ≤ emlDepth(e)
Guarantee: eval(e', x) = d/dx eval(e, x) for all x

match e with
| var        → const(1)
| const(c)   → const(0)
| add(a, b)  → add(DERIV(a), DERIV(b))
| mul(a, b)  → add(mul(DERIV(a), b), mul(a, DERIV(b)))
| neg(a)     → neg(DERIV(a))
| eml(a, b)  → eml(add(DERIV(a), mul(a, DERIV(b))), b)
```

**Time complexity:** O(|e|) — one pass over the expression tree.
**Space complexity:** O(|e|) — the output tree has at most a constant factor more nodes than the input per application. However, iterated application leads to exponential size growth (the product rule doubles terms).
**Depth guarantee:** `emlDepth(output) ≤ emlDepth(input)` (Theorem 3.1).

### 4.2 Bounded Enumeration and Verification

```
Algorithm: CHECK_DEPTH_PRESERVATION(max_size, max_depth, max_iters)
Input: size bound S, depth bound D, iteration count N
Output: PASS or counterexample

1. Generate all EmlExpr of size ≤ S and emlDepth ≤ D
   (bottom-up by size, filtering by depth)
2. For each expression e:
   a. Compute d₀ = emlDepth(e)
   b. For n = 1, ..., N:
      - Compute eₙ = deriv^n(e)
      - Compute dₙ = emlDepth(eₙ)
      - If dₙ > d₀: REPORT counterexample (e, n, d₀, dₙ)
3. If no counterexample found: PASS
```

**Time complexity:** O(E · N · |e_max|^N) where E is the number of expressions.
**Space complexity:** O(|e_max|^N) for the largest iterated derivative.

---

## 5. Computational Experiments

### 5.1 Enumeration Results

We ran the bounded enumeration checker with the following parameters:

| Parameter | Value |
|-----------|-------|
| max_size | 5 |
| max_depth | 3 |
| max_iters | 3 |
| Expressions generated | 1652 |
| Depth preserved (exactly) | 1652 |
| Depth strictly decreased | 0 |
| Counterexamples | 0 |

A larger run with max_size=6, max_depth=4, max_iters=5 on 654 expressions also found zero counterexamples.

### 5.2 Size Growth Under Iteration

| Expression | n=0 | n=1 | n=2 | n=3 | n=4 | n=5 |
|-----------|-----|-----|-----|-----|-----|-----|
| x·exp(x) depth | 1 | 1 | 1 | 1 | 1 | 1 |
| x·exp(x) size | 3 | 7 | 19 | 59 | 207 | 811 |
| exp(exp(x)) depth | 2 | 2 | 2 | 2 | 2 | 2 |
| exp(exp(x)) size | 5 | 15 | 57 | 257 | 1319 | 7513 |
| x² depth | 0 | 0 | 0 | 0 | 0 | 0 |
| x² size | 3 | 7 | 15 | 31 | 63 | 127 |

**Observation:** While depth is perfectly preserved, size grows roughly exponentially. For `exp(exp(x))`, the size growth factor is approximately 5-7× per derivative. For `x²`, it is exactly 2× (binary tree doubling from the product rule).

### 5.3 Depth Drop Classification

Among all 1652 expressions of size ≤ 5, no expression exhibited a strict depth drop under differentiation. This suggests:

**Observation:** For "generic" EML expressions without special cancellation patterns, depth is exactly preserved (not merely bounded) under differentiation.

The only mechanism for depth *decrease* would be an expression like `eml(const(0), b)` where the coefficient is zero — but this differentiates to `eml(const(0) + const(0)·deriv(b), b) = eml(add(const(0), mul(const(0), deriv(b))), b)`, which still has the same depth since the eml node is preserved. True depth decrease would require the `eml` node itself to disappear, which cannot happen with the `deriv` function as defined (it always produces an `eml` node from an `eml` input).

---

## 6. Applications

### 6.1 Certified Computer Algebra

The depth preservation theorem provides a certified complexity guarantee for symbolic differentiation engines. A CAS designed to handle expressions of depth ≤ k can safely perform arbitrary differentiation without exceeding its design bounds. This is relevant for specialized symbolic computation systems targeting specific expression classes.

### 6.2 Automatic Differentiation Resource Bounds

In automatic differentiation (AD), both forward-mode and reverse-mode AD compute derivatives by propagating through an expression graph. The depth preservation theorem guarantees that the derivative computation stays within the same "exponential complexity class" as the original function. For hardware implementations with a fixed number of exponential computation units, this means derivative computations are guaranteed to fit within the hardware's capabilities.

### 6.3 Machine Learning Architecture Analysis

Neural network architectures with exponential gating mechanisms (softmax, exponential linear units, attention mechanisms) can be modeled as EML expressions. The depth preservation theorem implies that gradient computations through such architectures do not create new levels of exponential nesting — the gradient's exponential complexity is bounded by the architecture's design depth.

### 6.4 Hardy Field Theory

The depth strata `DepthClosed(k)` form a differential filtration analogous to the log-exp filtration in Hardy fields. This provides a syntactic counterpart to the analytic theory of asymptotic growth rates, connecting combinatorial properties of expression trees to the asymptotic behavior of the functions they represent.

---

## 7. Discussion

### 7.1 Comparison with Positive Fragment

The positive fragment result (`PosEMLExpr.depth_deriv_le`) established a bound of `depth(deriv(e)) ≤ depth(e) + 1`, using an `exp` constructor rather than the combined `eml` constructor. The `+1` arises because `deriv(exp(a)) = mul(deriv(a), exp(a))`, and the `mul` node's depth is `max(depth(deriv(a)), depth(a) + 1)` which can be up to `depth(a) + 1 = depth(exp(a))`.

In contrast, the full EML grammar uses `eml(a, b) = a · exp(b)` as a single node. Differentiating produces `eml(a' + a·b', b)` — another `eml` node with the same `b`. The coefficient `a' + a·b'` has depth at most `max(depth(a), depth(b))`, so the result's depth is exactly `1 + max(depth(a), depth(b)) = depth(eml(a, b))`. The bound is *tight* — there is no `+1` slack.

### 7.2 Why the eml Constructor Matters

The `eml` constructor is mathematically natural because it encapsulates the product-exponential pattern that generates the Hardy hierarchy. By making this a primitive operation (rather than composing `mul` and `exp`), the grammar aligns with the differential structure: the derivative of an `eml` is another `eml` with the same exponent. This "shape preservation" is the engine of depth preservation.

### 7.3 Limitations

1. **Size growth:** While depth is preserved, expression size can grow exponentially under iterated differentiation. Practical implementations would need simplification or sharing-based representations to control this.

2. **No simplification:** The `deriv` function produces unsimplified expressions. Expressions like `add(const(0), mul(const(0), e))` are semantically zero but syntactically non-trivial. A simplification pass would reduce size without affecting depth.

3. **Decidability questions:** Whether a given EML expression evaluates to zero is undecidable in general (related to Richardson's theorem). This limits our ability to determine when depth *semantically* decreases.

---

## 8. Future Work

1. **Tight size bounds.** Determine the exact growth rate of expression size under iterated differentiation. The computational data suggests approximately geometric growth with factor depending on the expression.

2. **Simplification with depth guarantees.** Design a certified simplification algorithm that reduces size while provably preserving depth. This would combine depth preservation with practical expression management.

3. **Extension to logarithms.** The natural next step is to add `log` to the grammar and investigate whether depth preservation extends to the full log-exp Hardy field.

4. **Exact depth preservation classification.** Characterize exactly when `emlDepth(deriv(e)) = emlDepth(e)` (rather than merely `≤`). Our computations suggest this holds for all "generic" expressions.

5. **Connection to transseries.** The EML grammar generates a fragment of the field of transseries. Investigate how depth preservation relates to the well-ordered structure of transseries support sets.

---

## 9. Formal Verification

All theorems in this paper are machine-verified in Lean 4 (v4.28.0) using Mathlib. The formalization is located in:

- `Catalog/Pythagorean/HardyHierarchy/FullEMLDiffClosure.lean` — main development
- `Catalog/MachineLearning/HardyHierarchy/Defs.lean` — EML grammar definitions
- `Catalog/Speculative/HardyHierarchy/Theorems.lean` — Hardy hierarchy theorems

The formalization includes 6 major theorems:
1. `EmlExpr.depth_deriv_le_self` (Theorem 3.1)
2. `EmlExpr.depth_iteratedDeriv_le_self` (Theorem 3.2)
3. `EmlExpr.differentiallyDepthBounded_iff` (Theorem 3.3)
4. `EmlExpr.deriv_maps_depthClosed` (Theorem 3.4)
5. `EmlExpr.eval_hasDerivAt` (Theorem 3.5)
6. `EmlExpr.depth_neg_deriv` (Theorem 3.6)

All proofs compile without `sorry` and use only the standard axioms (`propext`, `Classical.choice`, `Quot.sound`).

---

## 10. References

1. Hardy, G. H. *Orders of Infinity*. Cambridge University Press, 1910.
2. Boshernitzan, M. "An extension of Hardy's class L of 'orders of infinity'." *Journal d'Analyse Mathématique*, 39(1):235–255, 1981.
3. van den Dries, L., Macintyre, A., and Marker, D. "Logarithmic-exponential power series." *Journal of the London Mathematical Society*, 56(3):417–434, 1997.
4. Aschenbrenner, M., van den Dries, L., and van der Hoeven, J. *Asymptotic Differential Algebra and Model Theory of Transseries*. Princeton University Press, 2017.
5. Richardson, D. "Some undecidable problems involving elementary functions of a real variable." *Journal of Symbolic Logic*, 33(4):514–520, 1968.
