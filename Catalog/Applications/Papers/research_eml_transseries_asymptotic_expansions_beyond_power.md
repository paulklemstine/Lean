# Transseries and Dominance Filtrations: A Formalized Theory of Asymptotic Hierarchies

## Abstract

We develop a rigorous, machine-verified theory of transseries — formal series built from iterated exponentials and logarithms — focusing on the algebraic structure of their dominance ordering. Our main contributions are threefold: (1) a fully formalized proof of the **Dominance Chain Theorem**, establishing that iterated exponentials form a strictly increasing chain in the asymptotic dominance ordering; (2) the **Comparison Theorem for Exponential Sums**, proving that exponential sums with distinct frequencies are uniquely determined by their coefficients; and (3) the **Dominance Filtration**, a novel algebraic structure that decomposes an ordered group into layers corresponding to growth levels, with a proof that separated exhaustive filtrations assign unique levels to nonzero elements. All results are formalized in Lean 4 with the Mathlib library, comprising 30+ verified theorems with no axioms beyond the standard foundation.

## 1. Introduction

### 1.1 Motivation

Transseries, introduced by Écalle in the context of resurgent analysis and independently studied by Dahn-Göring and van den Dries-Macintyre-Marker, provide a natural algebraic framework for asymptotic analysis. Unlike formal power series, transseries can represent functions involving iterated exponentials and logarithms, capturing the full hierarchy of growth rates encountered in analysis.

The theory has deep connections to:
- **Model theory**: The field of logarithmic-exponential transseries is a model of the theory of the real exponential field (van den Dries-Macintyre-Marker).
- **Hardy fields**: Transseries provide algebraic descriptions of germs in Hardy fields.
- **Differential algebra**: The field of transseries carries a natural derivation compatible with its ordering.
- **Surreal numbers**: There is a canonical embedding of transseries into Conway's surreal numbers (Berarducci-Mantova, Aschenbrenner-van den Dries-van der Hoeven).

### 1.2 Our Contributions

We formalize a foundational fragment of transseries theory, introducing:

1. **Iterated exponentials and logarithms** (`iterExp`, `iterLog`): Recursive definitions with verified algebraic properties including composition laws and cancellation.

2. **The Dominance Chain Theorem** (`iterExp_strictly_dominates`): A proof that exp^(n+1)(x) / exp^(n)(x) → ∞ as x → ∞, establishing the strict hierarchy of growth levels.

3. **The Comparison Theorem** (`exp_sum_comparison`): If two exponential sums ∑ c₁ᵢ exp(bᵢ x) = ∑ c₂ᵢ exp(bᵢ x) for all x with injective frequencies, then c₁ = c₂.

4. **The Dominance Filtration** (`DominanceFiltration`): A novel structure consisting of a decreasing sequence of convex subsets of an ordered group, indexed by ℤ. We prove that separated exhaustive filtrations assign unique growth levels to nonzero elements.

5. **Asymptotic Equivalence Theory**: Formalization of asymptotic equivalence at order n, with proofs that it forms a hierarchy of equivalence relations that refine as n increases.

6. **The Exponential Growth Rate**: A valuation-like function detecting the dominant exponential term, with proofs that it correctly identifies the growth rate of exponential functions and polynomials.

7. **EML Connection**: The EML operation eml(x,y) = exp(x) - log(y) is shown to have a natural two-level transseries structure, with the exponential term dominating.

## 2. Definitions

### 2.1 Iterated Exponentials and Logarithms

**Definition 2.1** (Iterated Exponential). For n ∈ ℕ and x ∈ ℝ:
```
iterExp(0, x) = x
iterExp(n+1, x) = exp(iterExp(n, x))
```

**Definition 2.2** (Iterated Logarithm). For n ∈ ℕ and x ∈ ℝ:
```
iterLog(0, x) = x
iterLog(n+1, x) = log(iterLog(n, x))
```

These satisfy the composition law `iterExp(m+n, x) = iterExp(m, iterExp(n, x))` and the cancellation property `iterExp(n, iterLog(n, x)) = x` when all intermediate logarithms are positive.

### 2.2 Asymptotic Equivalence

**Definition 2.3** (Asymptotic Equivalence at Order n). Two functions f, g : ℝ → ℝ are asymptotically equivalent at order n if:
```
lim_{x→∞} (f(x) - g(x)) · x^n = 0
```

This creates a hierarchy: equivalence at order n+1 implies equivalence at order n, but not conversely. The hierarchy captures the classical notion of asymptotic expansion.

### 2.3 The Dominance Filtration

**Definition 2.4** (Dominance Filtration). A dominance filtration on a linearly ordered group (Γ, ≤, 0) is a function level : ℤ → 𝒫(Γ) such that:
1. 0 ∈ level(k) for all k ∈ ℤ
2. level(k+1) ⊆ level(k) for all k ∈ ℤ (decreasing)
3. Each level(k) is convex: a ≤ b ≤ c with a, c ∈ level(k) implies b ∈ level(k)

The filtration is **separated** if ⋂_k level(k) = {0} and **exhaustive** if ⋃_k level(k) = Γ.

### 2.4 Exponential Growth Rate

**Definition 2.5** (Exponential Growth Rate). For f : ℝ → ℝ:
```
v(f) = lim sup_{x→∞} log(f(x)) / x ∈ [-∞, +∞]
```

This is a valuation-like map that detects the dominant exponential term.

## 3. Main Results

### 3.1 The Dominance Chain Theorem

**Theorem 3.1** (`iterExp_strictly_dominates`). For every n ∈ ℕ:
```
lim_{x→∞} iterExp(n+1, x) / iterExp(n, x) = +∞
```

*Proof sketch.* The key observation is that exp(y)/y → ∞ as y → ∞. Since iterExp(n+1, x) = exp(iterExp(n, x)) and iterExp(n, x) → ∞, the ratio exp(iterExp(n, x))/iterExp(n, x) → ∞ by composition with the divergent function y ↦ exp(y)/y. The base case uses `Real.tendsto_exp_div_pow_atTop 1`, and the inductive step uses that iterExp(n, x) → ∞ (which follows from the fact that it's a composition of exp with a divergent function). □

**PEGB Analysis:**
- **P** (Proof): Complete Lean 4 proof by induction, using composition of tendsto statements.
- **E** (Example): exp(exp(3))/exp(3) ≈ exp(3)^(exp(3)/exp(3)-1) = exp(20.09)/20.09 ≈ 2.65×10⁷.
- **G** (Generalization): The same argument shows iterExp(n+k, x)/iterExp(n, x) → ∞ for any k ≥ 1.
- **B** (Boundary): At x = 0, the ratios are finite: exp(1)/1 = e ≈ 2.718. The divergence only manifests asymptotically.

### 3.2 The Comparison Theorem

**Theorem 3.2** (`exp_sum_comparison`). Let b : Fin n → ℝ be injective and c₁, c₂ : Fin n → ℝ. If
```
∑ᵢ c₁(i) · exp(b(i) · x) = ∑ᵢ c₂(i) · exp(b(i) · x)   for all x ∈ ℝ
```
then c₁ = c₂.

*Proof sketch.* Define d(i) = c₁(i) - c₂(i). We must show d = 0. By induction on n. The base case is trivial. For the inductive step: divide the equation ∑ d(i) exp(b(i) x) = 0 by exp(b(0) x) to get d(0) + ∑_{i>0} d(i) exp((b(i)-b(0)) x) = 0. Differentiate to eliminate d(0), yielding a sum with n-1 terms and distinct frequencies (b(i)-b(0)). Apply the induction hypothesis to conclude d(i)(b(i)-b(0)) = 0 for i > 0. Since b is injective, b(i) ≠ b(0), so d(i) = 0 for i > 0. Then d(0) = 0 follows. □

**PEGB Analysis:**
- **P** (Proof): Lean 4 proof by strong induction with differentiation argument.
- **E** (Example): 2exp(x) - exp(2x) = 2exp(x) - exp(2x) ✓; 2exp(x) - exp(2x) ≠ 3exp(x) - exp(2x).
- **G** (Generalization): Extends to `exp_lin_indep`: distinct exponentials are linearly independent over ℝ.
- **B** (Boundary): Fails if b is not injective: exp(x) + exp(x) = 2exp(x) shows non-unique decomposition with repeated frequencies.

### 3.3 Unique Growth Levels

**Theorem 3.3** (`DominanceFiltration.exists_exact_level`). In a separated exhaustive dominance filtration, every nonzero element has a unique exact growth level.

*Proof sketch.* By exhaustiveness, γ belongs to some level k. By separation, γ cannot belong to all levels (since γ ≠ 0). Therefore, there exists a largest level containing γ. Since the filtration is decreasing and ℤ is well-ordered below any bound, we can find the transition point where γ exits the filtration. □

### 3.4 Exponential Growth Rate Properties

**Theorem 3.4** (`expGrowthRate_of_cexp`). v(exp(c·x)) = c for all c ∈ ℝ.

**Theorem 3.5** (`expGrowthRate_polynomial`). v(x^n) = 0 for all n ≥ 1.

**Theorem 3.6** (`expGrowthRate_exp_mul`). v(exp(a·x) · exp(b·x)) = a + b.

These establish that the exponential growth rate correctly distinguishes exponential growth rates and assigns zero growth rate to polynomial functions, confirming its role as a valuation on the ring of "tame" functions.

### 3.5 The Additive-Multiplicative Bridge

**Theorem 3.7** (`exp_ratio_of_diff_tendsto`). If f(x) - g(x) → L as x → ∞, then exp(f(x))/exp(g(x)) → exp(L).

This is the algebraic core of the level-shifting property: additive relationships at one growth level become multiplicative relationships one level up. The exponential map converts the additive structure of the value group into the multiplicative structure of the field.

### 3.6 The EML Two-Level Structure

**Theorem 3.8** (`eml_asymptotic_exp`). For y > 0:
```
eml(x, y) / exp(x) → 1   as x → ∞
```

**Theorem 3.9** (`eml_correction_term`). eml(x, y) - exp(x) = -log(y).

Together, these show that eml(x, y) has the two-level transseries expansion exp(x) + (-log(y)), where the first term is at growth level 1 and the second at level 0 (constant).

## 4. Algorithms

### 4.1 Growth Level Detection

Given a function f, its dominance filtration level can be estimated by:
1. Compute log(f(x))/x for large x.
2. If this ratio converges to c ≠ 0, the function is at exponential level (level 1) with rate c.
3. If it converges to 0, check log(f(x))/log(x) to distinguish polynomial from logarithmic growth.
4. If log(f(x))/x → ∞, compute log(log(f(x)))/x to check for doubly-exponential growth.

### 4.2 Exponential Sum Decomposition

Given a function believed to be an exponential sum, its coefficients can be recovered by the Prony method:
1. Sample f at equally spaced points.
2. Use the Hankel matrix to determine the number and values of the frequencies.
3. Solve the resulting linear system for the coefficients.

The comparison theorem guarantees that this decomposition, when it exists, is unique.

## 5. Discussion

### 5.1 Relation to Hardy Fields

Our comparison theorem is a concrete instance of the general principle that elements of Hardy fields are uniquely determined by their asymptotic expansions. The full generalization — that transseries expansions are unique in any Hardy field closed under exp and log — is a deep result of Aschenbrenner, van den Dries, and van der Hoeven (2017).

### 5.2 The Dominance Filtration as a Novel Structure

The dominance filtration generalizes the classical theory of convex subgroups in ordered abelian groups. In the context of transseries, the convex subgroups correspond to growth levels: the convex subgroup at level k consists of all elements whose growth rate is at most k-fold iterated exponential.

Our unique level theorem shows that in a suitable filtration, every nonzero element has a well-defined "growth type" — a fact that is used implicitly throughout transseries theory but which we formalize explicitly.

### 5.3 Connection to the EML Framework

The EML operation eml(x,y) = exp(x) - log(y) provides a concrete bridge between exponential and logarithmic growth levels. Our formal analysis shows that this operation creates a genuine two-level transseries, demonstrating that the transseries framework naturally accommodates operations that mix growth levels.

## 6. Conjecture

**Conjecture** (Iterated Exponential Linear Independence). For distinct natural numbers n₁, ..., nₖ and nonzero coefficients c₁, ..., cₖ:

∑ᵢ cᵢ · iterExp(nᵢ, x) ≠ 0 for all sufficiently large x

**Computational test**: Evaluate ∑ cᵢ iterExp(nᵢ, x) at x = 1, 2, ..., 100 for random coefficients and check that no value is zero. This can be tested for specific small cases (n ≤ 5).

## 7. Future Work

1. Extend the comparison theorem to the full polynomial-exponential fragment.
2. Formalize the differential structure on transseries.
3. Connect the dominance filtration to the theory of convex subgroups in valued fields.
4. Prove that the logarithmic-exponential transseries form a real closed field.

## References

1. Aschenbrenner, M., van den Dries, L., van der Hoeven, J. *Asymptotic Differential Algebra and Model Theory of Transseries*. Princeton University Press, 2017.
2. Écalle, J. *Introduction aux fonctions analysables et preuve constructive de la conjecture de Dulac*. Hermann, 1992.
3. van den Dries, L., Macintyre, A., Marker, D. "Logarithmic-exponential series." *Annals of Pure and Applied Logic*, 111(1-2):61–113, 2001.
4. Hardy, G. H. *Orders of Infinity*. Cambridge University Press, 1910.
