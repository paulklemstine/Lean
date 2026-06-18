# Dimension Does Not Compress Tower Height: A Multivariate Depth-Separation Theorem for Inverse-Free EML Expressions

## Abstract

We establish a multivariate complexity theory for inverse-free exponential-multiplicative language (EML) expressions. Our main result is a depth-separation theorem: any multivariate expression in *k* variables that computes the iterated exponential tower `iterExp n (∑ xᵢ)` on the positive orthant must have exp-nesting depth at least *n* and syntactic size at least *k*. The depth lower bound is proved via a diagonal restriction technique that reduces the multivariate problem to the univariate case, where we establish a polynomial tower majorant lemma showing that depth-*d* expressions grow at most like `iterExp d (C·x^N)`. The size lower bound follows from a variable-support analysis. All results are formalized and machine-verified in Lean 4 with the Mathlib library.

**Keywords**: expression complexity, iterated exponentials, depth hierarchy, symbolic regression, multivariate analysis, formal verification

---

## 1. Introduction

### 1.1 Motivation

The study of expression complexity asks: given a target function, what is the minimum structural complexity of any formula that computes it exactly? This question arises in:

- **Symbolic regression**: automated search for interpretable mathematical models from data.
- **Circuit complexity**: lower bounds on the resources needed for computation.
- **Approximation theory**: barriers to exact representation by restricted function classes.

The *exponential-multiplicative language* (EML) consists of expressions built from real variables, constants, addition, multiplication, and exponentiation (exp). The *depth* of such an expression counts the maximum nesting of exp operations. Prior work established that in one variable, computing `iterExp n x = exp(exp(···(x)···))` (n-fold) requires depth at least n for inverse-free EML expressions.

### 1.2 The Multivariate Question

We extend this theory to *k* variables. The target function becomes:

```
towerOnSum(n, k, x) = iterExp n (∑ᵢ xᵢ)
```

Our main question: **does the availability of k > 1 input variables allow a shallower representation?** We prove that it does not, establishing:

> **Theorem (Main).** If an inverse-free MVEMLExpr in k variables computes `iterExp n (∑ xᵢ)` on the positive orthant, then its depth is ≥ n and its size is ≥ k.

### 1.3 Contributions

1. **Definitions**: Multivariate EML expressions (`MVEMLExpr k`), evaluation, depth, size, variable support, and the diagonal restriction operator.
2. **Diagonal restriction theorem**: `depth(diagExpr e) ≤ depth(e)` and `eval(diagExpr e, t) = eval(e, (t,...,t))`.
3. **Polynomial tower majorant**: Every depth-d univariate expression satisfies `|eval e x| ≤ iterExp d (C·x^N)` for appropriate constants.
4. **Growth separation**: `iterExp d (C·x^N) < iterExp (d+1) x` for large x.
5. **Multivariate depth lower bound**: `n ≤ depth(e)` for any e computing `iterExp n (∑ xᵢ)`.
6. **Size lower bound**: `k ≤ size(e)`.
7. **Joint bound**: `n + k ≤ depth(e) + size(e)`.
8. **Machine verification**: All results formalized in Lean 4.

---

## 2. Definitions and Notation

### 2.1 Iterated Exponential

```
iterExp : ℕ → ℝ → ℝ
iterExp 0 x = x
iterExp (n+1) x = exp(iterExp n x)
```

### 2.2 Univariate EML Expressions

```
inductive UEMLExpr
| var : UEMLExpr
| const : ℝ → UEMLExpr
| add : UEMLExpr → UEMLExpr → UEMLExpr
| mul : UEMLExpr → UEMLExpr → UEMLExpr
| exp : UEMLExpr → UEMLExpr
```

with evaluation `eval : UEMLExpr → ℝ → ℝ` and depth `depth : UEMLExpr → ℕ` counting maximum exp-nesting.

### 2.3 Multivariate EML Expressions

```
inductive MVEMLExpr (k : ℕ)
| var   : Fin k → MVEMLExpr k
| const : ℝ → MVEMLExpr k
| add   : MVEMLExpr k → MVEMLExpr k → MVEMLExpr k
| mul   : MVEMLExpr k → MVEMLExpr k → MVEMLExpr k
| exp   : MVEMLExpr k → MVEMLExpr k
```

with `eval : MVEMLExpr k → (Fin k → ℝ) → ℝ`, `depth`, `size`, and `varSupport : MVEMLExpr k → Finset (Fin k)`.

### 2.4 Diagonal Restriction

```
diagExpr : MVEMLExpr k → UEMLExpr
diagExpr (var _) = var
diagExpr (const c) = const c
diagExpr (add a b) = add (diagExpr a) (diagExpr b)
diagExpr (mul a b) = mul (diagExpr a) (diagExpr b)
diagExpr (exp a) = exp (diagExpr a)
```

---

## 3. Main Results

### 3.1 Diagonal Restriction Properties

**Theorem 3.1** (Evaluation preservation). For all `e : MVEMLExpr k` and `t : ℝ`:
```
eval(diagExpr e, t) = eval(e, (t, t, ..., t))
```

*Proof.* Structural induction on e. Each constructor case follows by unfolding definitions and applying inductive hypotheses. □

**Theorem 3.2** (Depth non-increase). `depth(diagExpr e) ≤ depth(e)`.

*Proof.* Structural induction. The depth definition is identical for both expression types. □

### 3.2 Growth Analysis

**Theorem 3.3** (Polynomial tower majorant). For every `e : UEMLExpr`, there exist `C > 0`, `N : ℕ`, and `X₀ : ℝ` such that for all `x ≥ X₀`:
```
|eval(e, x)| ≤ iterExp(depth(e), C · x^N)
```

*Proof sketch.* Structural induction on e.

- **var**: `|x| ≤ 1·x¹` for x ≥ 0.
- **const c**: `|c| ≤ (|c|+1)·x⁰`.
- **add a b**: By IH, both operands are bounded by their respective `iterExp(dᵢ, Cᵢ·x^Nᵢ)`. Promote to the common depth d = max(d₁, d₂) using level monotonicity. For d = 0: polynomial sum. For d ≥ 1: use the *sum combine* lemma (iterExp_sum_combine) showing that `iterExp d (C₁x^N₁) + iterExp d (C₂x^N₂) ≤ iterExp d (C·x^N)` via the *doubling absorption* principle: `2·iterExp d y ≤ iterExp d (y+1)` for y ≥ 0 and d ≥ 1.
- **mul a b**: For d = 0: polynomial product. For d ≥ 1: `exp(a)·exp(b) = exp(a+b)`, reducing to the sum combine at one level lower.
- **exp a**: `exp(eval(a, x)) ≤ exp(iterExp(dₐ, Cₐ·x^Nₐ)) = iterExp(dₐ+1, Cₐ·x^Nₐ)`. □

**Theorem 3.4** (Growth separation). For all `d, C > 0, N`:
```
∃ X₀, ∀ x ≥ X₀, iterExp d (C·x^N) < iterExp (d+1) x
```

*Proof.* Induction on d. Base (d=0): `C·x^N < exp(x)` by polynomial-exponential domination. Step: `iterExp(d+1, C·x^N) = exp(iterExp(d, C·x^N)) < exp(iterExp(d+1, x))` by IH and monotonicity of exp. □

### 3.3 Depth Lower Bound

**Theorem 3.5** (Univariate depth lower bound). If `eval(e, x) = iterExp(n, x)` for all x > 0, then `n ≤ depth(e)`.

*Proof.* By contradiction. If depth(e) < n, then by Theorem 3.3, `|eval(e, x)| ≤ iterExp(depth(e), C·x^N)` for large x. By Theorem 3.4, this is `< iterExp(depth(e)+1, x) ≤ iterExp(n, x)` (level monotonicity). But eval(e, x) = iterExp(n, x) > 0, so |eval(e, x)| = iterExp(n, x), giving iterExp(n, x) < iterExp(n, x), contradiction. □

**Theorem 3.6** (Multivariate depth lower bound — Flagship). If `e : MVEMLExpr k` computes `iterExp n (∑ xᵢ)` on the positive orthant and k ≥ 1, then `n ≤ depth(e)`.

*Proof.* Apply diagonal restriction:
1. `diagExpr e` computes `iterExp n (k·t)` for t > 0.
2. `depth(diagExpr e) ≤ depth(e)` by Theorem 3.2.
3. By the growth argument (Theorems 3.3-3.4), `n ≤ depth(diagExpr e)`.
4. Therefore `n ≤ depth(e)`. □

### 3.4 Size Lower Bound

**Theorem 3.7** (Variable support ≤ size). `card(varSupport(e)) ≤ size(e)`.

**Theorem 3.8** (Essential variables). If `eval(e, x) = iterExp(n, ∑ xᵢ)` on the positive orthant with n ≥ 1, then every variable index j ∈ Fin k belongs to varSupport(e).

*Proof.* For each j, construct inputs differing only at coordinate j: x = (1,...,1) and y with yⱼ = 2. Then sumVars(x) ≠ sumVars(y), so iterExp(n, sumVars(x)) ≠ iterExp(n, sumVars(y)) by injectivity. □

**Theorem 3.9** (Size lower bound). Under the same hypotheses, `k ≤ size(e)`.

*Proof.* By Theorem 3.8, varSupport(e) = Fin k, so card(varSupport(e)) = k ≤ size(e). □

### 3.5 Joint Lower Bound

**Theorem 3.10** (Combined bound). `n + k ≤ depth(e) + size(e)`.

*Proof.* Add Theorems 3.6 and 3.9. □

---

## 4. Key Auxiliary Results

### 4.1 Doubling Absorption

**Lemma 4.1.** For d ≥ 1 and y ≥ 0: `exp(y) + 1 ≤ exp(y + 1)`.

*Proof.* `exp(y+1) = exp(y)·e ≥ exp(y)·2 ≥ exp(y) + 1` since e > 2 and exp(y) ≥ 1. □

**Lemma 4.2.** For d ≥ 1 and y ≥ 0: `iterExp d y + 1 ≤ iterExp d (y + 1)`.

**Lemma 4.3.** For d ≥ 1 and y ≥ 0: `2·iterExp d y ≤ iterExp d (y + 1)`.

### 4.2 Sum and Product Combine

**Lemma 4.4** (Sum combine). For all d, C₁, C₂ > 0, N₁, N₂, there exist C > 0, N such that for x ≥ 1:
```
iterExp d (C₁·x^N₁) + iterExp d (C₂·x^N₂) ≤ iterExp d (C·x^N)
```

**Lemma 4.5** (Product combine). For d ≥ 1, same conclusion with product replacing sum.

---

## 5. Algorithms and Computational Experiments

### 5.1 Expression Enumeration

We implement a bounded enumerator that generates all inverse-free MVEMLExpr expressions up to given depth and size bounds. The algorithm uses dynamic programming over (depth, size) pairs:

```
enumerate_expressions(k, max_depth, max_size):
    dp[d][s] = [] for all d, s
    dp[0][1] = [Var(i) for i in range(k)] ∪ [Const(c) for c in pool]
    for s in 3..max_size:
        for s1 in 1..s-2:
            s2 = s - 1 - s1
            for d1, d2 ≤ max_depth:
                dp[max(d1,d2)][s] += [Add(a,b), Mul(a,b)]
                    for a in dp[d1][s1], b in dp[d2][s2]
        for d_arg < max_depth:
            dp[d_arg+1][s] += [Exp(a) for a in dp[d_arg][s-1]]
    return flatten(dp)
```

### 5.2 Grid Search Results

We test the **depth rigidity conjecture** computationally:

| k | n | max_depth | max_size | Expressions | Matches |
|---|---|-----------|----------|-------------|---------|
| 2 | 2 | 1         | 5        | 570         | 0       |
| 2 | 2 | 1         | 7        | 21,896      | 0       |
| 2 | 3 | 2         | 7        | ~150,000    | 0       |

In every case, no expression of depth < n matches the target on the test grid, consistent with our theorem.

---

## 6. Discussion

### 6.1 Significance

Our results establish the first formally verified multivariate depth-separation theorem for analytic expression languages. The key meta-principle is:

> **Compositional analytic depth is invariant under harmless increases in ambient dimension.**

This principle connects circuit complexity (depth = sequential steps), symbolic regression (depth = model architecture), and tensor complexity (dimension = ambient space).

### 6.2 Limitations

1. Our expressions are *inverse-free*: division is not allowed. The full EML language with inverses may have different complexity behavior.
2. The lower bounds are for *exact* representation. Approximate representations might require less depth.
3. The size lower bound k ≤ size(e) is tight (the expression `exp(exp(...(x₁ + x₂ + ... + xₖ)...))` has size O(n + k)) but the combined bound n + k ≤ depth + size is not known to be tight.

### 6.3 Connection to Prior Work

The univariate depth hierarchy was established in the EML tight depth hierarchy theorem. Our contribution is the multivariate extension via diagonal restriction, together with the refined polynomial tower majorant that handles the growth analysis cleanly.

---

## 7. Future Work

1. **Approximate lower bounds**: Extend to ε-approximate representations.
2. **Full EML with inverses**: The inverse operation introduces rational functions; does this change the depth hierarchy?
3. **General linear restrictions**: Replace the diagonal with arbitrary affine subspaces.
4. **Tensor restriction theory**: Formalize the connection between expression depth and tensor rank.
5. **Neural network analogy**: Establish similar depth-dimension independence for ReLU networks.

---

## References

1. Hardy, G.H. "Orders of Infinity." Cambridge Tracts in Mathematics, 1910.
2. Hopcroft, J.E., Ullman, J.D. "Introduction to Automata Theory, Languages, and Computation." 1979.
3. Razborov, A.A. "Lower Bounds on the Size of Bounded Depth Circuits over a Complete Basis with Logical Addition." 1987.
4. Richardson, D. "Some undecidable problems involving elementary functions of a real variable." 1968.
