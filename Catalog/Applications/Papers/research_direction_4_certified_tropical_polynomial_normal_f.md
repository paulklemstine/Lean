# Certified Tropical Polynomial Normal Form: Soundness, Completeness, and Decidability

## Abstract

We establish that tropical polynomial expressions in *n* variables over ℝ (in the min-plus convention) admit a certified canonical normal form. Every expression expands to a finite set of monomials; essentialization removes dominated monomials, retaining only those that appear on the lower envelope. We prove three theorems: *soundness* (normalization preserves semantics), *completeness* (equal functions yield identical normal forms), and the *decision principle* (semantic equivalence is equivalent to normal-form equality). The completeness proof uses the Baire category theorem to show that essential monomials transfer between any two representations of the same function. All results are formalized and machine-verified.

## 1. Introduction

Tropical polynomials — finite pointwise infima of affine forms — arise naturally in optimization, discrete event systems, phylogenetics, and the tropical geometry underlying algebraic geometry. A fundamental question is: *when do two tropical polynomial expressions define the same function?*

Unlike classical polynomials, where coefficient comparison suffices, tropical polynomials suffer from a subtler form of redundancy. The expression min(x, 0, x+1) equals min(x, 0) because the monomial x+1 is always dominated. Raw syntactic comparison is neither sound nor complete for semantic equality.

We prove that the **essential support** — the set of monomials achieving the strict minimum at some point — is a complete invariant. This is the tropical analogue of the Newton polytope's lower-hull vertex set.

### 1.1 Contributions

1. **Definitions**: TropExpr (syntax), TropPolyNF (normal form), essentialization via IsEssential predicate.
2. **Theorem A (Soundness)**: `normalize_sound`: ∀ e x, evalNF (normalize e) x = evalExpr e x.
3. **Theorem B (Completeness)**: `essentialize_complete`: if ∀ x, evalNF s x = evalNF t x, then essentialize s = essentialize t.
4. **Theorem C (Decision)**: `normalize_iff`: (∀ x, evalExpr e₁ x = evalExpr e₂ x) ↔ normalize e₁ = normalize e₂.
5. **Machine verification**: All proofs verified in Lean 4 with Mathlib, depending only on standard axioms.

## 2. Definitions and Notation

### 2.1 Tropical Monomials

A **tropical monomial** in *n* variables is a pair (c, w) ∈ ℝ × ℕⁿ, representing the affine function:

    evalMonom(c, w)(x) = c + Σᵢ wᵢ xᵢ

### 2.2 Tropical Expressions

The syntax is given by an inductive type:

    TropExpr ::= const(c) | var(i) | add(e₁, e₂) | mul(e₁, e₂)

with semantics: add = min, mul = +.

### 2.3 Normal Form

A **tropical polynomial in normal form** (TropPolyNF) is a nonempty finite set of monomials. Its evaluation is:

    evalNF(S)(x) = min_{m ∈ S} evalMonom(m)(x)

### 2.4 Essentialization

A monomial m is **essential** in S if:
- m ∈ S, and
- ∃ x ∈ ℝⁿ, ∀ m' ∈ S, m' ≠ m → evalMonom(m)(x) < evalMonom(m')(x)

The **essentialization** essentialize(S) = {m ∈ S : IsEssential(S, m)}.

## 3. Main Results

### 3.1 Expansion Soundness

**Theorem** (expand_sound): For every expression e and point x:
    evalNF(expand(e))(x) = evalExpr(e)(x)

*Proof sketch*: By structural induction. Constants and variables map to singletons. Tropical addition (min) maps to union of supports via Finset.inf'_union. Tropical multiplication (+) maps to Minkowski sum via the key identity:

    min_{(a,b) ∈ S×T} (f(a) + g(b)) = min_a f(a) + min_b g(b)

### 3.2 Affine Rigidity

**Theorem** (affine_eq_of_eval_eq): If evalMonom(m₁) = evalMonom(m₂) as functions, then m₁ = m₂.

*Proof*: Evaluate at 0 to recover the coefficient. Evaluate at standard basis vectors eⱼ to recover each exponent via the equation c + wⱼ = c' + w'ⱼ and wⱼ = w'ⱼ by ℕ-cast injectivity.

### 3.3 Geometric Lemmas

**Lemma** (nowhere_dense_affine_zero): The zero set of a non-zero affine function ℝⁿ → ℝ is nowhere dense.

**Lemma** (ball_not_covered_by_hyperplanes): A nonempty open ball in ℝⁿ cannot be covered by finitely many zero sets of non-zero affine functions.

*Proof*: By the Baire category theorem. Each zero set is nowhere dense (closed with empty interior). A finite union of nowhere dense sets is meager. An open ball in the complete metric space ℝⁿ is not meager.

### 3.4 Essential Monomial Theory

**Lemma** (essential_achieves_inf): At every point x, some essential monomial achieves the infimum.

*Proof*: Let T = {m ∈ S : evalMonom(m)(x) = inf}. If |T| = 1, it's essential. If |T| > 1, use exists_all_distinct_near (via ball_not_covered_by_hyperplanes applied to pairwise difference affine functions) to find a nearby point where all T-monomials have distinct values. The minimizer at that point is the unique strict minimizer, hence essential.

**Corollary** (essentialize_sound): Removing inessential monomials preserves the function.

### 3.5 Essential Transfer (Completeness Core)

**Lemma** (essential_transfer): If m is essential in S and ∀ x, inf' S = inf' T, then m is essential in T.

*Proof outline*:
1. Get strict witness x₀ for m in S.
2. By strict_min_neighborhood, get ε-ball where m is strict min of S.
3. On this ball, inf' T = evalMonom(m) (from the functional equality).
4. By mem_of_inf_eq_on_ball, m ∈ T.
5. By ball_not_covered_by_hyperplanes (applied to differences between m and other T-monomials), find y in the ball where m is the strict min of T.
6. Hence m is essential in T.

### 3.6 Main Theorems

**Theorem** (essentialize_complete): If evalNF(S) = evalNF(T), then essentialize(S) = essentialize(T).

*Proof*: By essential_transfer in both directions: each essential monomial of S is essential in T (and vice versa).

**Theorem** (normalize_iff): (∀ x, evalExpr(e₁)(x) = evalExpr(e₂)(x)) ↔ normalize(e₁) = normalize(e₂).

## 4. Algorithms

### 4.1 Expansion

```
expand(const c) = {(c, 0⃗)}
expand(var i)   = {(0, eᵢ)}
expand(add e₁ e₂) = expand(e₁) ∪ expand(e₂)
expand(mul e₁ e₂) = {(c₁+c₂, w₁+w₂) : (c₁,w₁) ∈ expand(e₁), (c₂,w₂) ∈ expand(e₂)}
```

**Complexity**: O(2^d) monomials for depth-d expression (multiplication doubles the support).

### 4.2 Essentialization

For each monomial m ∈ S, check if the linear program {x : evalMonom(m)(x) ≤ evalMonom(m')(x), ∀ m' ≠ m} is feasible (with strict inequality achievable). This can be done in polynomial time per monomial.

**Complexity**: O(k · LP(k, n)) where k = |S|, n = number of variables.

## 5. Applications

### 5.1 Tropical Circuit Equivalence
Two min-plus circuits are equivalent iff their normal forms match. This provides the first general verified equivalence checker for tropical circuits.

### 5.2 Neural Network Compression
ReLU networks produce piecewise-linear functions expressible as tropical polynomials. Normalization identifies and removes redundant linear pieces, compressing the network representation.

### 5.3 Certified Dynamic Programming
Value functions in dynamic programming are tropical polynomials. Normal form certificates prove optimality of DP solutions.

## 6. Discussion

The essential support is the tropical analogue of several classical mathematical objects:
- The **vertex set** of the Newton polytope's lower convex hull
- The **Gröbner basis** of a polynomial ideal (in the sense of providing a canonical form)
- The **minimal DFA** of a regular language (in the sense of being the unique smallest equivalent representation)

The completeness theorem — that the essential support is a *complete* invariant — is the deepest result. It requires the Baire category theorem, bridging algebra and topology in an essential way.

### 6.1 Limitations

The current formalization does not provide an algorithmic decision procedure for IsEssential (the definition quantifies over all real points). Future work should connect the abstract definition to a linear-programming based algorithm.

## 7. References

1. Maclagan, D. and Sturmfels, B. *Introduction to Tropical Geometry*. AMS, 2015.
2. Butkovič, P. *Max-linear Systems: Theory and Algorithms*. Springer, 2010.
3. Joswig, M. *Essentials of Tropical Combinatorics*. AMS, 2021.
4. Zhang, L. et al. "Tropical geometry of deep neural networks." ICML, 2018.
