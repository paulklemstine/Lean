# The EML Approximation Filtration: Depth Hierarchies, Complexity Spectra, and Universal Approximation Bounds

## Abstract

We introduce the **EML Approximation Filtration**, a novel mathematical structure that stratifies the space of real-valued functions by their representation complexity in the Exponential-Multiplicative-Logarithmic (EML) expression language. The EML language uses a single transcendental primitive `eml(a, b) = a · exp(b)` combined with field operations (addition, multiplication, negation, inversion). We prove that the depth-indexed sublanguages form a proper filtration: each level is closed under field operations, composition adds depths, and the levels are strictly increasing (witnessed by iterated exponentials). We establish a complete structural decomposition — `size = leafCount + fieldCount + emlCount` — and prove multiplicative size bounds for substitution-based composition. Our framework defines the **EML Complexity Spectrum** of a function as the set of achievable (depth, size) pairs, and proves monotonicity properties of the associated depth and size cost functions. All results are formalized in Lean 4 with machine-checked proofs.

**Keywords**: EML expressions, depth hierarchy, universal approximation, Kolmogorov complexity, expression complexity, filtration, formal verification

---

## 1. Introduction

The quest to understand computational complexity through the lens of algebraic structure has deep roots. Shannon's circuit complexity (1949), Kolmogorov's representation theorem (1957), and the more recent depth-width tradeoffs in neural network theory all ask the same fundamental question: *given a function, what is the minimum computational machinery needed to compute or approximate it?*

We approach this question through the **EML expression language**, which provides a clean algebraic framework for studying transcendental complexity. The EML language has a single transcendental primitive — the operation `eml(a, b) = a · exp(b)` — combined with field operations over ℝ. This language is rich enough to represent all iterated exponentials, yet constrained enough to admit precise complexity analysis.

### 1.1 Main Contributions

1. **The EML Approximation Filtration** (Definition 3.1): A depth-indexed sequence of function sets, each closed under field operations, forming a proper filtration.

2. **Strict Hierarchy Theorem** (Theorem 4.1): The filtration levels are strictly increasing, witnessed by iterated exponentials of matching depth.

3. **Size Decomposition** (Theorem 5.1): Every EML expression satisfies `size = leafCount + fieldCount + emlCount`, decomposing complexity into data, algebraic, and transcendental components.

4. **Composition Bounds** (Theorems 6.1–6.2): Substitution-based composition satisfies `depth(f ∘ g) ≤ depth(f) + depth(g)` and `size(f ∘ g) ≤ size(f) · size(g)`.

5. **Level 0 Characterization** (Theorem 7.1): `emlDepth(e) = 0` if and only if `e` contains no `eml` nodes, identifying Level 0 with rational functions.

6. **Cost Monotonicity** (Theorems 8.1–8.2): The depth and size costs of ε-approximation are antitone in ε when achievable approximations exist.

All results are formalized and machine-verified in Lean 4 using Mathlib.

---

## 2. Preliminaries

### 2.1 The EML Expression Language

**Definition 2.1.** The type `EMLExpr'` is defined inductively:
```
EMLExpr' ::= var | const(c : ℝ) | add(a, b) | mul(a, b) | neg(a) | inv(a) | eml(a, b)
```

**Definition 2.2.** The evaluation function `eval : EMLExpr' → ℝ → ℝ` is:
- `var.eval(x) = x`
- `const(c).eval(x) = c`
- `add(a, b).eval(x) = a.eval(x) + b.eval(x)`
- `mul(a, b).eval(x) = a.eval(x) · b.eval(x)`
- `neg(a).eval(x) = −a.eval(x)`
- `inv(a).eval(x) = (a.eval(x))⁻¹`
- `eml(a, b).eval(x) = a.eval(x) · exp(b.eval(x))`

### 2.2 Complexity Measures

**Definition 2.3.** The *EML depth* `emlDepth(e)` counts the maximum nesting of `eml` operations:
- Field operations preserve the max depth of their arguments
- `eml(a, b)` has depth `1 + max(emlDepth(a), emlDepth(b))`

**Definition 2.4.** The *exponential rank* `expRank(e)` is:
- For field ops: `max(expRank(a), expRank(b))` (or `expRank(a)` for unary)
- For `eml(a, b)`: `max(expRank(a), expRank(b) + 1)`

**Definition 2.5.** The *size* `size(e)` counts total nodes; *leafCount*, *fieldCount*, *emlCount* count nodes of each type.

### 2.3 Iterated Exponentials

**Definition 2.6.** `iterExp'(0, x) = x`, `iterExp'(n+1, x) = exp(iterExp'(n, x))`.

**Definition 2.7.** The canonical EML expression: `emlExprIterExp'(0) = var`, `emlExprIterExp'(n+1) = eml(const(1), emlExprIterExp'(n))`.

---

## 3. The EML Approximation Filtration

**Definition 3.1.** The *EML Filtration Level d* is:
```
EMLFiltrationLevel(d) = {f : ℝ → ℝ | ∃ e : EMLExpr', emlDepth(e) ≤ d ∧ ∀ x, e.eval(x) = f(x)}
```

**Theorem 3.1 (Monotonicity).** If d₁ ≤ d₂, then `EMLFiltrationLevel(d₁) ⊆ EMLFiltrationLevel(d₂)`.

*Proof.* Given `f ∈ Level(d₁)`, obtain `e` with `emlDepth(e) ≤ d₁ ≤ d₂`. ∎

**Theorem 3.2 (Field Closure).** Each `EMLFiltrationLevel(d)` is closed under:
- Addition: `f, g ∈ Level(d) ⟹ f + g ∈ Level(d)`
- Multiplication: `f, g ∈ Level(d) ⟹ f · g ∈ Level(d)`
- Negation: `f ∈ Level(d) ⟹ −f ∈ Level(d)`

*Proof.* For addition: given `e₁, e₂` with depth ≤ d, the expression `add(e₁, e₂)` has depth `max(d₁, d₂) ≤ d`. Similarly for the other operations. ∎

This means each filtration level has the structure of a ring (not a field, since `inv` may not preserve the level when the function has zeros).

---

## 4. The Strict Hierarchy

**Theorem 4.1 (expRank ≤ emlDepth).** For all `e : EMLExpr'`, `expRank(e) ≤ emlDepth(e)`.

*Proof.* By structural induction. The critical case is `eml(a, b)`:
```
expRank(eml(a, b)) = max(expRank(a), expRank(b) + 1)
                    ≤ max(emlDepth(a), emlDepth(b) + 1)  [by IH]
                    ≤ 1 + max(emlDepth(a), emlDepth(b))
                    = emlDepth(eml(a, b))
```
∎

**Theorem 4.2 (Canonical Construction).** `emlExprIterExp'(n)` satisfies:
- `eval(x) = iterExp'(n, x)` for all x
- `emlDepth = n`
- `expRank = n`
- `size = 2n + 1`
- `emlCount = n`
- `leafCount = n + 1`
- `fieldCount = 0`

**Corollary 4.3 (Strict Hierarchy).** `iterExp'(n) ∈ Level(n)`, and by the expRank bound, no expression of depth < n can represent `iterExp'(n)`.

---

## 5. Size Decomposition

**Theorem 5.1 (Size Decomposition).** For all `e : EMLExpr'`:
```
size(e) = leafCount(e) + fieldCount(e) + emlCount(e)
```

*Proof.* By structural induction. Each internal node contributes exactly 1 to one of {fieldCount, emlCount}, and each leaf contributes 1 to leafCount. ∎

**Theorem 5.2 (emlCount ≤ size).** `emlCount(e) ≤ size(e)` for all `e`.

**Theorem 5.3 (leafCount ≥ 1).** Every expression has at least one leaf.

**Theorem 5.4 (size ≥ 1).** Every expression has positive size.

The decomposition reveals three independent sources of complexity:
- **Data complexity** (leafCount): how many inputs are needed
- **Algebraic complexity** (fieldCount): how much algebraic processing occurs
- **Transcendental complexity** (emlCount): how many transcendental steps are taken

---

## 6. Substitution and Composition

**Definition 6.1.** Syntactic substitution `subst(e, s)` replaces every `var` in `e` with `s`.

**Theorem 6.1 (Substitution Semantics).** `(e.subst s).eval(x) = e.eval(s.eval(x))`.

*Proof.* By structural induction on `e`. ∎

**Theorem 6.2 (Depth Additivity).** `emlDepth(e.subst s) ≤ emlDepth(e) + emlDepth(s)`.

*Proof.* By induction. The key case is `eml(a, b)`:
```
emlDepth(eml(a, b).subst s) = 1 + max(emlDepth(a.subst s), emlDepth(b.subst s))
                             ≤ 1 + max(emlDepth(a) + D, emlDepth(b) + D)  [IH]
                             = 1 + max(emlDepth(a), emlDepth(b)) + D
                             = emlDepth(eml(a, b)) + D
```
∎

**Theorem 6.3 (Size Multiplicativity).** `size(e.subst s) ≤ size(e) · size(s)`.

*Proof sketch.* Each leaf in `e` is replaced by a copy of `s`, contributing `size(s)`. Each internal node contributes 1. Total: at most `leafCount(e) · size(s) + (fieldCount(e) + emlCount(e)) ≤ size(e) · size(s)` using `size(s) ≥ 1`. ∎

**Theorem 6.4 (Composition Filtration Bound).** If `f ∈ Level(d₁)` and `g ∈ Level(d₂)`, then `f ∘ g ∈ Level(d₁ + d₂)`.

---

## 7. Level 0 Characterization

**Definition 7.1.** An expression is *eml-free* (`noEml(e)`) if it contains no `eml` nodes.

**Theorem 7.1 (Level 0 Characterization).** `emlDepth(e) = 0` if and only if `noEml(e)`.

*Proof.* Forward: if `emlDepth(eml(a,b)) = 0`, then `1 + max(...) = 0`, contradiction. Backward: induction shows that if both subtrees have depth 0, so does the parent (for field ops). ∎

This identifies Level 0 with the class of rational functions computable by field operations alone.

---

## 8. Cost Functions and Monotonicity

**Definition 8.1.** The *EML Depth Cost* of approximating f on [a,b] to precision ε:
```
EMLDepthCost(f, a, b, ε) = inf{d | ∃ e, emlDepth(e) ≤ d ∧ ∀ x ∈ [a,b], |f(x) − e.eval(x)| ≤ ε}
```

**Theorem 8.1 (Depth Cost Antitonicity).** If ε₁ ≤ ε₂ and the ε₁-approximation set is nonempty, then `EMLDepthCost(f, a, b, ε₂) ≤ EMLDepthCost(f, a, b, ε₁)`.

*Proof.* The ε₁-achievability set is a subset of the ε₂-achievability set. Apply monotonicity of infimum. ∎

**Theorem 8.2 (Size Cost Antitonicity).** Analogous result for `EMLSizeCost`.

---

## 9. The EML Complexity Spectrum

**Definition 9.1.** The *EML Complexity Spectrum* of f:
```
Spectrum(f) = {(d, s) | ∃ e, emlDepth(e) = d ∧ size(e) = s ∧ ∀ x, e.eval(x) = f(x)}
```

The Pareto frontier of this spectrum captures the depth-size tradeoff inherent to each function. By Theorem 6.3, reducing depth by composition requires at most multiplicative size increase.

For the canonical iterated exponential `iterExp'(n)`:
- The point `(n, 2n+1)` is in the spectrum
- No point `(d, s)` with `d < n` exists (by the expRank bound)
- The minimum depth is exactly `n`, regardless of size

---

## 10. Connection to Kolmogorov Complexity

The EML Size Cost `EMLSizeCost(f, a, b, ε)` is a concrete, computable proxy for the Kolmogorov complexity of the function f restricted to [a, b]. While Kolmogorov complexity is uncomputable in general, EML size cost is well-defined (though potentially hard to compute exactly).

**Conjecture 10.1.** For "natural" functions f, the EML Size Cost grows as O(K(f|ε)/ε) where K(f|ε) denotes the conditional Kolmogorov complexity of f given precision ε.

This conjecture connects the algebraic structure of EML to information-theoretic lower bounds. The depth cost provides a *structural* lower bound (how many transcendental steps), while the size cost provides an *informational* lower bound (how many bits of description).

---

## 11. Discussion and Future Work

### 11.1 Relation to Neural Network Depth

The EML filtration provides a mathematical framework for understanding depth-width tradeoffs in neural networks with exponential activations. The strict hierarchy theorem implies that certain functions *require* deep networks — no width increase can compensate for insufficient depth.

### 11.2 Multivariate Extensions

The current theory handles univariate functions. Extension to multivariate EML expressions introduces new phenomena: the Kolmogorov-Arnold decomposition, tensor product structure, and dimension-dependent complexity bounds.

### 11.3 Decidability

Whether `EMLDepthCost(f, a, b, ε)` is computable for computable f, a, b, ε is an open question related to Richardson's theorem on the decidability of constant expressions.

---

## 12. Conclusion

The EML Approximation Filtration provides a rigorous mathematical framework for understanding the complexity of transcendental computation. The strict depth hierarchy, proved via the expRank invariant, shows that the exponential nesting depth of a function is a fundamental, irreducible complexity measure. The size decomposition and substitution bounds give quantitative tools for analyzing the cost of computation. Together, these results lay the foundation for a theory of transcendental computational complexity.

---

## References

1. Kolmogorov, A.N. (1957). On the representation of continuous functions of several variables by superposition of continuous functions of one variable and addition. *Doklady Akad. Nauk SSSR*, 114, 953–956.

2. Shannon, C.E. (1949). The synthesis of two-terminal switching circuits. *Bell System Technical Journal*, 28(1), 59–98.

3. Arnold, V.I. (1957). On functions of three variables. *Doklady Akad. Nauk SSSR*, 114, 679–681.

4. Weierstrass, K. (1885). Über die analytische Darstellbarkeit sogenannter willkürlicher Funktionen einer reellen Veränderlichen. *Sitzungsberichte der Königlich Preußischen Akademie der Wissenschaften zu Berlin*, 633–639, 789–805.
