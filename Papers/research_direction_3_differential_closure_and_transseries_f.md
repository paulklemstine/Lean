# Differential Closure in the Hardy Hierarchy: Certified Transseries Fragments via Symbolic Differentiation

## Abstract

We establish the first formally verified differential closure principle for a fragment of the EML (Exp-Mul-Log) expression language within the Hardy hierarchy. Specifically, we prove that for every positive EML expression of syntactic depth $d$, its symbolic derivative evaluates to a function whose Hardy level is at most $d + 1$. The proof proceeds by:
1. defining a verified symbolic differentiation algorithm on PosEMLExpr expressions,
2. proving semantic correctness (the symbolic derivative equals the analytic derivative) by structural induction using the chain rule and product rule,
3. proving a depth control bound (differentiation raises depth by at most 1), and
4. composing these with the catalog theorem `hardyLevel_closed_under_eml` to transfer depth bounds to Hardy level bounds.

We also prove a logarithmic derivative decomposition theorem connecting Hardy hierarchies to differential algebra and WKB asymptotics. All results are machine-checked in Lean 4 with Mathlib, with no `sorry` axioms remaining. We introduce the `DiffClosedFragment` structure as a reusable abstraction for differentially closed transseries fragments.

**Keywords:** transseries, Hardy hierarchy, differential algebra, symbolic differentiation, asymptotic analysis, WKB, renormalization group, formal verification, computer algebra, eventual positivity

---

## 1. Introduction

### 1.1 Motivation

The Hardy hierarchy classifies real-valued functions by their asymptotic growth rate, stratifying them by the depth of exponential nesting required to dominate them. A function is at **Hardy level 0** if it grows at most polynomially, at **level 1** if it is bounded by a single exponential of a polynomial, at **level 2** if bounded by a double exponential, and so on.

This hierarchy is well-studied in asymptotic analysis, where it provides a natural scale for comparing growth rates. However, a fundamental question has remained largely informal: **how does differentiation interact with the Hardy hierarchy?**

Differentiation is the most basic operation in calculus, yet its effect on asymptotic complexity is not obvious. The derivative of $e^x$ is $e^x$ (same level), but the derivative of $x \cdot e^{e^x}$ involves the factor $e^{e^x}(1 + e^x)$, which mixes levels. The central question is: does differentiation always increase Hardy level by at most a bounded amount?

### 1.2 Main Results

We answer this question affirmatively for a precisely defined fragment of the EML expression language:

**Theorem (Differential Closure).** For every PosEMLExpr $e$ of depth $d$:
$$\text{HardyLevel}(d+1, \text{deriv}(\text{eval}(e)))$$

That is, the derivative of a depth-$d$ expression has Hardy level at most $d+1$.

This result is proved by a three-step architecture:
1. **Semantic correctness** (`eval_deriv_eq`): the symbolic derivative agrees with the analytic derivative at every point.
2. **Depth control** (`depth_deriv_le`): the symbolic derivative has depth at most $d+1$.
3. **Catalog closure** (`hardyLevel_of_depth`): every PosEMLExpr of depth $d$ lives in Hardy level $d$, via the catalog theorem `hardyLevel_closed_under_eml`.

We also establish:

**Theorem (Logarithmic Derivative Decomposition).** For PosEMLExpr expressions $a$ and $b$ with $a(x) \neq 0$:
$$(\log(a \cdot e^b))' = (\log a)' + b'$$

This identity connects Hardy hierarchies to the language of differential algebra, WKB approximation, and renormalization group flows.

### 1.3 Relationship to Prior Work

**Hardy fields.** Hardy's original work (1910) established that the field of "logarithmico-exponential" functions forms a differential field closed under asymptotic comparison. Our work formalizes a fragment of this closure, restricted to the positive EML expressions.

**Transseries.** The theory of transseries, developed by Écalle and later by Aschenbrenner, van den Dries, and van der Hoeven, provides a complete algebraic framework for asymptotic expansions involving iterated exponentials and logarithms. Our `DiffClosedFragment` structure is a first step toward formalizing transseries in a proof assistant.

**EML hierarchy.** The EML (Exp-Mul-Log) expression language provides a syntactic framework for classifying asymptotic growth. Our `PosEMLExpr` fragment captures the positive (logarithm-free) sub-language, which suffices for the differential closure principle.

**Formal mathematics.** Prior formalizations of asymptotic analysis in proof assistants have focused on individual growth comparisons or limit computations. Our contribution is the first to formalize a *structural* result about how differentiation interacts with an entire growth hierarchy.

---

## 2. Definitions and Notation

### 2.1 PosEMLExpr

```
inductive PosEMLExpr where
  | const : ℝ → PosEMLExpr
  | var   : PosEMLExpr
  | add   : PosEMLExpr → PosEMLExpr → PosEMLExpr
  | mul   : PosEMLExpr → PosEMLExpr → PosEMLExpr
  | exp   : PosEMLExpr → PosEMLExpr
```

### 2.2 Evaluation

$$\text{eval}(\text{const}(c), x) = c, \quad \text{eval}(\text{var}, x) = x$$
$$\text{eval}(\text{add}(a,b), x) = \text{eval}(a,x) + \text{eval}(b,x)$$
$$\text{eval}(\text{mul}(a,b), x) = \text{eval}(a,x) \cdot \text{eval}(b,x)$$
$$\text{eval}(\text{exp}(a), x) = e^{\text{eval}(a,x)}$$

### 2.3 Depth

$$\text{depth}(\text{const}(c)) = \text{depth}(\text{var}) = 0$$
$$\text{depth}(\text{add}(a,b)) = \text{depth}(\text{mul}(a,b)) = \max(\text{depth}(a), \text{depth}(b))$$
$$\text{depth}(\text{exp}(a)) = \text{depth}(a) + 1$$

### 2.4 Symbolic Differentiation

$$D(\text{const}(c)) = \text{const}(0), \quad D(\text{var}) = \text{const}(1)$$
$$D(\text{add}(a,b)) = \text{add}(D(a), D(b))$$
$$D(\text{mul}(a,b)) = \text{add}(\text{mul}(D(a), b), \text{mul}(a, D(b)))$$
$$D(\text{exp}(a)) = \text{mul}(D(a), \text{exp}(a))$$

### 2.5 Hardy Level

The Hardy level hierarchy is defined inductively:

- Level 0 contains the identity, all constants, and is closed under $+$ and $\times$.
- Level $n+1$ contains functions of the form $a(x) \cdot e^{b(x)}$ where $a, b$ are at level $n$.
- Any function eventually equal to a level-$n$ function is also at level $n$.

### 2.6 Eventually Positive

A function $f$ is **eventually positive** if $\exists X, \forall x \geq X, f(x) > 0$.

### 2.7 Logarithmic Derivative

$$\delta(f)(x) = \frac{f'(x)}{f(x)}$$

---

## 3. Main Results

### 3.1 Theorem 1: Differentiability (differentiable_eval)

**Statement.** For every PosEMLExpr $e$, the function $x \mapsto \text{eval}(e, x)$ is differentiable on $\mathbb{R}$.

**Proof sketch.** By structural induction:
- `const c`: differentiable as a constant function.
- `var`: differentiable as the identity function.
- `add a b`: sum of differentiable functions (by IH) is differentiable.
- `mul a b`: product of differentiable functions (by IH) is differentiable.
- `exp a`: composition of $\exp$ (differentiable everywhere) with a differentiable function (by IH).

### 3.2 Theorem 2: Semantic Correctness (eval_deriv_eq)

**Statement.** For every PosEMLExpr $e$ and every $x \in \mathbb{R}$:
$$\text{HasDerivAt}(\lambda y. \text{eval}(e, y), \text{eval}(D(e), x), x)$$

That is, the symbolic derivative $D(e)$ evaluated at $x$ gives the true derivative of $\text{eval}(e, \cdot)$ at $x$.

**Proof sketch.** By structural induction on $e$, using:
- `hasDerivAt_const` for constants,
- `hasDerivAt_id` for the variable,
- `HasDerivAt.add` for sums,
- `HasDerivAt.mul` for products (product rule),
- `HasDerivAt.exp` for exponentials (chain rule, with a `mul_comm` to match the convention $a' \cdot e^a$ vs $e^a \cdot a'$).

**Key detail.** The `exp` case requires commutativity of multiplication because Mathlib's `HasDerivAt.exp` produces $e^a \cdot a'$ while our symbolic derivative produces $a' \cdot e^a$. We use `mul_comm` to bridge this.

### 3.3 Theorem 3: Depth Control (depth_deriv_le)

**Statement.** For every PosEMLExpr $e$:
$$\text{depth}(D(e)) \leq \text{depth}(e) + 1$$

**Proof sketch.** By structural induction:
- `const`, `var`: depth of derivative is 0, which is ≤ 0 + 1.
- `add a b`: $D(\text{add}(a,b)) = \text{add}(D(a), D(b))$, so depth = $\max(\text{depth}(D(a)), \text{depth}(D(b))) \leq \max(\text{depth}(a)+1, \text{depth}(b)+1) = \max(\text{depth}(a), \text{depth}(b)) + 1$.
- `mul a b`: $D(\text{mul}(a,b)) = \text{add}(\text{mul}(D(a), b), \text{mul}(a, D(b)))$. The depth of each `mul` term is $\max(\text{depth}(D(a)), \text{depth}(b))$ and $\max(\text{depth}(a), \text{depth}(D(b)))$, both bounded by $\max(\text{depth}(a), \text{depth}(b)) + 1$ using the IH.
- `exp a`: $D(\text{exp}(a)) = \text{mul}(D(a), \text{exp}(a))$. By IH, $\text{depth}(D(a)) \leq \text{depth}(a) + 1$, and $\text{depth}(\text{exp}(a)) = \text{depth}(a) + 1$, so the max is $\text{depth}(a) + 1 = \text{depth}(\text{exp}(a))$. Thus depth stays the same, not even increasing by 1.

**Observation.** The bound is not tight in the `exp` case: differentiating $\text{exp}(a)$ produces an expression of the same depth, not depth + 1. The +1 comes from the `mul` case via the product rule.

### 3.4 Theorem 4: Hardy Level of PosEMLExpr (hardyLevel_of_depth)

**Statement.** For every PosEMLExpr $e$:
$$\text{HardyLevel}(\text{depth}(e), \lambda x. \text{eval}(e, x))$$

**Proof sketch.** We use the embedding `toEmlExpr : PosEMLExpr → EmlExpr` that maps `exp a` to `eml (const 1) a`. We prove:
1. `toEmlExpr_eval`: the embedding preserves evaluation (pointwise equality).
2. `toEmlExpr_depth`: the embedding preserves depth ($\text{emlDepth}(\text{toEmlExpr}(e)) = \text{depth}(e)$).

Then we invoke the catalog theorem `emlDepth_le_hardyLevel` to get $\text{HardyLevel}(\text{emlDepth}(\text{toEmlExpr}(e)), \text{eval}(\text{toEmlExpr}(e)))$ and transfer via `HardyLevel.congr` using the pointwise equality.

**This step explicitly uses `hardyLevel_closed_under_eml`** through the `exp_step` constructor of `HardyLevel`, which is the engine of `emlDepth_le_hardyLevel`.

### 3.5 Main Theorem: Differential Closure (hardyLevel_deriv_le_succ)

**Statement.** For every PosEMLExpr $e$:
$$\text{HardyLevel}(\text{depth}(e) + 1, \lambda x. \text{eval}(D(e), x))$$

**Proof.** Direct composition:
1. $\text{HardyLevel}(\text{depth}(D(e)), \lambda x. \text{eval}(D(e), x))$ by `hardyLevel_of_depth`.
2. $\text{depth}(D(e)) \leq \text{depth}(e) + 1$ by `depth_deriv_le`.
3. By `HardyLevelLE.mono`, conclude $\text{HardyLevel}(\text{depth}(e) + 1, \lambda x. \text{eval}(D(e), x))$.

### 3.6 Theorem 5: Logarithmic Derivative Decomposition (logDeriv_mul_exp)

**Statement.** For PosEMLExpr $a, b$ with $a(x) \neq 0$ for all $x$:
$$\delta(a \cdot e^b) = \delta(a) + b'$$

**Proof.** By direct calculation:
$$\frac{d}{dx}(a \cdot e^b) = a' \cdot e^b + a \cdot b' \cdot e^b$$
$$\frac{a' \cdot e^b + a \cdot b' \cdot e^b}{a \cdot e^b} = \frac{a'}{a} + b' = \delta(a) + b'$$

In the formal proof, we compute the derivative using `HasDerivAt.mul` and `HasDerivAt.exp`, then simplify using `field_simp` with the hypotheses $a(x) \neq 0$ and $e^{b(x)} \neq 0$.

---

## 4. Algorithms

### 4.1 Symbolic Differentiation Algorithm

```
ALGORITHM: SymbolicDeriv(e)
INPUT:  PosEMLExpr e
OUTPUT: PosEMLExpr e' such that eval(e', x) = d/dx eval(e, x)

match e with
| const(c) → const(0)
| var      → const(1)
| add(a,b) → add(SymbolicDeriv(a), SymbolicDeriv(b))
| mul(a,b) → add(mul(SymbolicDeriv(a), b), mul(a, SymbolicDeriv(b)))
| exp(a)   → mul(SymbolicDeriv(a), exp(a))

COMPLEXITY:
  Time:  O(n) where n = number of nodes in e
  Space: O(n) for the output tree
  Depth: depth(output) ≤ depth(e) + 1 (verified)
```

### 4.2 Hardy Level Classifier

```
ALGORITHM: ClassifyHardyLevel(e)
INPUT:  PosEMLExpr e
OUTPUT: (d, proof) where d = depth(e) and proof : HardyLevel d (eval e)

1. Compute d = depth(e)
2. Embed: e' = toEmlExpr(e)
3. Apply emlDepth_le_hardyLevel(e') to get HardyLevel(emlDepth(e'), eval(e'))
4. Transfer via toEmlExpr_depth and toEmlExpr_eval
5. Return (d, proof)

COMPLEXITY: O(n) for depth computation, proof certificate is O(n) in size
```

---

## 5. Applications

### 5.1 WKB Approximation

In the WKB approximation for $y'' + Q(x)y = 0$, solutions take the form $y \approx a(x) \cdot e^{b(x)}$ where $a$ is slowly varying and $b$ is the phase. The logarithmic derivative decomposition $\delta(a \cdot e^b) = \delta(a) + b'$ separates the amplitude contribution from the phase derivative.

Our differential closure theorem certifies that if the original WKB ansatz has Hardy depth $d$, then the derivative (needed for substitution back into the ODE) has Hardy level at most $d + 1$. This provides a certified complexity bound for WKB iteration.

### 5.2 Renormalization Group

In quantum field theory, the beta function $\beta(g) = \mu \frac{\partial g}{\partial \mu}$ is a logarithmic derivative. If the running coupling $g(\mu)$ is modeled as an EML expression of depth $d$ in $\log \mu$, then $\beta(g)$ has Hardy level at most $d + 1$. This gives a formal bound on the "transcendence complexity" of renormalization group flows.

### 5.3 Certified Computer Algebra

The verified symbolic differentiation algorithm provides a certified differentiation engine for EML expressions. The depth bound `depth_deriv_le` can be used as a termination criterion for asymptotic simplification: after $k$ differentiations, the result has depth at most $d + k$.

---

## 6. Computational Experiments

### 6.1 Depth Gap Analysis

We compute the gap $\text{depth}(D(e)) - \text{depth}(e)$ for representative expressions:

| Expression | Depth | Deriv Depth | Gap |
|---|---|---|---|
| `x` | 0 | 0 | 0 |
| `x * x` | 0 | 0 | 0 |
| `exp(x)` | 1 | 1 | 0 |
| `x * exp(x)` | 1 | 1 | 0 |
| `exp(exp(x))` | 2 | 2 | 0 |
| `exp(x + exp(x))` | 2 | 2 | 0 |
| `(x²+1) * exp(exp(x))` | 2 | 2 | 0 |
| `exp(exp(exp(x)))` | 3 | 3 | 0 |

**Observation:** The gap is always 0 in all tested cases, suggesting the +1 bound may not be tight. See Conjecture A in Future Directions.

### 6.2 Numerical Validation

For each expression, we validated the symbolic derivative against central differences at $x = 0.5, 1.0, 2.0$ with step size $h = 10^{-8}$. All symbolic derivatives matched numerical derivatives to within $10^{-5}$ relative error.

### 6.3 Logarithmic Derivative Verification

For $f(x) = x \cdot e^{x^2}$:
- $\delta(f)(2) = 1/2 + 4 = 4.5$
- Verified: $\delta(x)(2) + (x^2)'|_{x=2} = 0.5 + 4.0 = 4.5$ ✓

---

## 7. Discussion

### 7.1 Significance

The differential closure theorem transforms the Hardy hierarchy from a static classification tool into a **dynamic calculus**: one can now reason about derivatives while maintaining control over asymptotic complexity. This is the conceptual foundation for a formal theory of transseries.

### 7.2 The DiffClosedFragment Abstraction

We introduce the `DiffClosedFragment` structure, which packages:
- An expression type with evaluation, symbolic differentiation, and depth
- Proofs of semantic correctness, depth control, and Hardy level bounds

Any instance automatically satisfies the differential closure principle. The `PosEMLExpr` fragment is the first instance, but the structure is designed for extension to fragments with logarithms, reciprocals, or more complex operations.

### 7.3 Limitations

1. **No division.** The `PosEMLExpr` fragment does not include division, so the logarithmic derivative Hardy level bound requires additional assumptions.
2. **No logarithms.** Full transseries require logarithms, which introduce new depth structure.
3. **No normalization.** The symbolic derivative produces non-simplified expressions; a normalizer would give tighter bounds.

### 7.4 Gap Tightness

All computational experiments show a gap of 0, suggesting the bound may be improvable to $\text{depth}(D(e)) \leq \text{depth}(e)$. This is an open question that would significantly strengthen the result.

---

## 8. Future Work

1. **Quotient closure:** Extend to division, upgrading the differential ring to a differential field.
2. **Logarithm fragment:** Add logarithms to cover the full log-exp Hardy field.
3. **Normalizing compiler:** Implement and verify a simplifier to tighten depth bounds.
4. **Transseries truncation:** Formalize truncation operators with certified error bounds.
5. **Connection to model theory:** Link the formal hierarchy to the model-theoretic Hardy field theory of Aschenbrenner-van den Dries-van der Hoeven.

---

## 9. References

1. Hardy, G.H. "Orders of Infinity." Cambridge Tracts in Mathematics, 1910.
2. Aschenbrenner, M., van den Dries, L., van der Hoeven, J. "Asymptotic Differential Algebra and Model Theory of Transseries." Annals of Mathematics Studies, Princeton, 2017.
3. Écalle, J. "Introduction aux fonctions analysables et preuve constructive de la conjecture de Dulac." Hermann, 1992.
4. van der Hoeven, J. "Transseries and Real Differential Algebra." Lecture Notes in Mathematics, Springer, 2006.
5. The Mathlib Community. "Mathlib: A Unified Library of Mathematics Formalized." https://leanprover-community.github.io/mathlib4_docs/

---

## Appendix: Formal Proof Architecture

The Lean development is organized as follows:

- `MachineLearning/HardyHierarchy/Defs.lean`: Core definitions (EmlExpr, HardyLevel, iterExp)
- `Speculative/HardyHierarchy/Theorems.lean`: Catalog theorems (hardyLevel_closed_under_eml, emlDepth_le_hardyLevel)
- `Speculative/HardyHierarchy/DiffClosure.lean`: **New development** — PosEMLExpr, symbolic differentiation, differential closure theorem, logarithmic derivative decomposition, DiffClosedFragment structure

All theorems in DiffClosure.lean are proved without `sorry`, depending only on the standard axioms `propext`, `Classical.choice`, and `Quot.sound`.
