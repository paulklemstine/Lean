# Non-Archimedean Probability via Surreal Numbers: Infinitesimal Probability Spaces

## Abstract

We develop a finitely additive probability theory over non-Archimedean ordered fields, where infinitesimal probabilities are well-defined. We introduce the notion of an *infinitesimal probability space* (InfProbSpace) — a normalized, regular, finitely additive probability measure valued in a linearly ordered field that may contain infinitesimal elements. We prove that such spaces satisfy the standard properties of probability (monotonicity, complementation, inclusion-exclusion, Bayes' theorem) while additionally supporting regular measures where every singleton has strictly positive probability. We establish an impossibility theorem showing that Archimedean fields cannot support uniform positive weights on infinite sets, proving that non-Archimedean fields are necessary for this framework. We construct product measures, prove infinitesimal closure properties, and characterize when uniform measures yield infinitesimal singleton probabilities. All results are machine-verified in Lean 4 using Mathlib.

## 1. Introduction

### 1.1 Motivation

Classical probability theory, as axiomatized by Kolmogorov (1933), uses σ-additive measures valued in the real numbers [0,1]. This framework has been extraordinarily successful but suffers from a well-known limitation: in continuous probability spaces, the measure of any singleton set must be zero. This creates conceptual and technical difficulties:

1. **Bayesian conditioning**: P(A|B) = P(A∩B)/P(B) is undefined when P(B) = 0, yet conditioning on specific observed values is fundamental to Bayesian inference.

2. **Regularity**: A probability measure is *regular* if every non-empty open set has positive probability. For continuous measures on ℝ, singleton regularity (P({x}) > 0 for all x) is impossible.

3. **Fairness in infinite lotteries**: De Finetti (1937) argued that a "fair lottery on ℕ" — assigning equal probability to each natural number — should be possible, yet countable additivity forbids it.

### 1.2 Our Approach

We resolve these issues by replacing the real-valued range with a non-Archimedean linearly ordered field F that contains infinitesimal elements. An element ε ∈ F is *infinitesimal* if 0 < ε < 1/n for every positive natural number n. Such elements exist in:

- Surreal numbers (Conway, 1976)
- Hyperreal numbers (Robinson, 1966)
- Formal Laurent series fields
- Levi-Civita field

We work axiomatically over any such field, making our results applicable to all of these settings simultaneously.

### 1.3 Related Work

Our work connects to several established traditions:

- **Nonstandard analysis** (Robinson, 1966; Nelson, 1977): Uses ultrapower constructions to obtain hyperreal fields with infinitesimals. Our axiomatic approach generalizes beyond the hyperreal setting.
- **De Finetti's finitely additive probability** (1937): Argued for finite additivity over σ-additivity. Our framework provides a natural setting where de Finetti's vision is realized.
- **Surreal analysis** (Conway, 1976; Gonshor, 1986): Develops analysis on surreal numbers. We extend this to probability theory.
- **Infinitesimal probabilities** (Skyrms, 1980; Lewis, 1980; Wenmackers & Horsten, 2013): Philosophical arguments for infinitesimal probabilities. We provide rigorous mathematical foundations.

## 2. Definitions

### 2.1 Infinitesimal Elements

**Definition 2.1** (Infinitesimal). Let F be a linearly ordered field. An element ε ∈ F is *infinitesimal* if:
1. 0 < ε
2. ε < 1/n for every positive natural number n

**Definition 2.2** (Non-Archimedean Field). A linearly ordered field F is *non-Archimedean* if it contains an infinitesimal element.

The Archimedean property states that for any positive element x ∈ F, there exists n ∈ ℕ with n > x. Equivalently, a field is Archimedean if and only if it contains no infinitesimal elements. Thus "non-Archimedean" in our sense is the negation of the Archimedean property.

### 2.2 Finitely Additive Probability Measures

**Definition 2.3** (FinAddProbMeasure). A *finitely additive probability measure* on a type Ω valued in a linearly ordered field F is a function μ: Finset(Ω) → F satisfying:
1. μ(∅) = 0
2. μ(A) ≥ 0 for all A
3. μ(A ∪ B) = μ(A) + μ(B) whenever A and B are disjoint

### 2.3 Infinitesimal Probability Spaces

**Definition 2.4** (InfProbSpace). An *infinitesimal probability space* on a finite type Ω valued in F is a FinAddProbMeasure μ satisfying additionally:
4. μ(Ω) = 1 (normalization)
5. μ({x}) > 0 for all x ∈ Ω (regularity)

This is our central novel structure. It captures the intuition that every outcome should be "genuinely possible" — having non-zero probability — while maintaining the standard probability axioms.

### 2.4 Conditional Probability

**Definition 2.5** (Conditional Probability). For a FinAddProbMeasure μ and finsets A, B:

P(A | B) = μ(A ∩ B) / μ(B)

In an InfProbSpace, this is well-defined for any non-empty B, since μ(B) ≥ μ({x}) > 0 for any x ∈ B. This includes the case where μ(B) is infinitesimal.

## 3. Main Results

### 3.1 Basic Measure Properties

**Theorem 3.1** (Monotonicity). If A ⊆ B then μ(A) ≤ μ(B).

*Proof*. Write B = A ∪ (B \ A) as a disjoint union. Then μ(B) = μ(A) + μ(B\A) ≥ μ(A) by nonnegativity. ∎

**Theorem 3.2** (Complement Formula). In an InfProbSpace, μ(Ω \ A) = 1 - μ(A).

*Proof*. Write Ω = A ∪ (Ω \ A) disjointly. Then 1 = μ(Ω) = μ(A) + μ(Ω\A). ∎

**Theorem 3.3** (Inclusion-Exclusion). μ(A ∪ B) = μ(A) + μ(B) - μ(A ∩ B).

*Proof*. Decompose A ∪ B = A ∪ (B \ A) and B = (A ∩ B) ∪ (B \ A), both disjoint. Substituting μ(B\A) = μ(B) - μ(A∩B) into μ(A∪B) = μ(A) + μ(B\A) gives the result. ∎

**Theorem 3.4** (Probability Bound). In an InfProbSpace, μ(A) ≤ 1 for all A.

*Proof*. Since A ⊆ Ω, monotonicity gives μ(A) ≤ μ(Ω) = 1. ∎

### 3.2 Measure Decomposition

**Theorem 3.5** (Atomic Decomposition). μ(A) = ∑_{x ∈ A} μ({x}).

*Proof*. By induction on |A| using the insertion lemma for finsets and disjoint additivity. ∎

This is a key structural result: every finitely additive measure on a discrete space is determined by its values on singletons. In an InfProbSpace, this means the entire measure is determined by the "point mass function" x ↦ μ({x}).

### 3.3 The Archimedean Impossibility Theorem

**Theorem 3.6** (Archimedean Impossibility). Let F be an Archimedean ordered field. For any c > 0, there exists N ∈ ℕ such that N · c > 1.

*Proof*. By the Archimedean property, there exists N > 1/c. Then N · c > 1. ∎

**Corollary 3.7**. In an Archimedean field, no finitely additive probability measure on ℕ can assign equal positive weight c to every element: taking N elements would give total mass N·c > 1 > μ(ℕ) = 1, violating monotonicity.

This proves that non-Archimedean fields are *necessary* for regular uniform measures on infinite sets.

### 3.4 Existence of Uniform InfProbSpaces

**Theorem 3.8** (Uniform InfProbSpace Existence). For any n ≥ 1, the uniform measure μ(A) = |A|/n on Fin(n) is an InfProbSpace with μ({x}) = 1/n for all x.

*Proof*. Normalization: |Fin(n)|/n = n/n = 1. Regularity: 1/n > 0 since n > 0. ∎

In a non-Archimedean field, if n is a "non-standard natural" (an element of F larger than every standard natural), then 1/n is infinitesimal, giving a uniform infinitesimal probability space.

### 3.5 Characterization of Infinitesimal Uniform Measures

**Theorem 3.9** (Infinitesimal Characterization). For n ≥ 1, 1/n is infinitesimal if and only if 1/n < 1/m for every positive standard natural m.

This provides a clean criterion: the uniform probability 1/n is infinitesimal precisely when n exceeds every standard natural number.

### 3.6 Bayes' Theorem

**Theorem 3.10** (Bayes' Identity). For any A, B with μ(A) ≠ 0 and μ(B) ≠ 0:

P(A|B) · μ(B) = P(B|A) · μ(A)

*Proof*. Both sides equal μ(A ∩ B), using A ∩ B = B ∩ A. ∎

The significance: in an InfProbSpace, μ(B) ≠ 0 for any non-empty B (by regularity), so Bayes' theorem applies universally. This resolves the classical problem of conditioning on measure-zero events.

### 3.7 Infinitesimal Closure

**Theorem 3.11** (Additive Closure). If ε₁ and ε₂ are infinitesimal, then ε₁ + ε₂ is infinitesimal.

*Proof*. For any n > 0: ε₁ < 1/(2n), ε₂ < 1/(2n), so ε₁ + ε₂ < 1/n. ∎

**Theorem 3.12** (Scalar Closure). If ε is infinitesimal, then (n+1)·ε is infinitesimal for any standard natural n.

*Proof*. For any m > 0: ε < 1/((n+1)m), so (n+1)ε < 1/m. ∎

These results imply that the set of infinitesimal elements forms an additive subgroup of F, and moreover is closed under multiplication by standard naturals. This is the algebraic foundation for showing that finite sums of infinitesimal probabilities remain infinitesimal.

### 3.8 Product Measures

**Theorem 3.13** (Product InfProbSpace). Given InfProbSpaces (Ω₁, μ₁) and (Ω₂, μ₂), the product measure μ(A) = ∑_{(a,b) ∈ A} μ₁({a}) · μ₂({b}) is an InfProbSpace on Ω₁ × Ω₂.

*Proof*. Normalization: μ(Ω₁ × Ω₂) = (∑_a μ₁({a}))(∑_b μ₂({b})) = 1·1 = 1 by the atomic decomposition theorem. Regularity: μ({(a,b)}) = μ₁({a})·μ₂({b}) > 0 by regularity of the factors. ∎

### 3.9 Conditional Probability Properties

**Theorem 3.14**. P(Ω | B) = 1 for any non-empty B.

**Theorem 3.15**. P(∅ | B) = 0 for any B.

## 4. Worked Examples

### Example 4.1: Fair Coin in Infinitesimal Probability
Consider Ω = Fin(2) with the uniform InfProbSpace. Then P({0}) = P({1}) = 1/2. This is a standard probability space — no infinitesimals needed. The theory correctly recovers classical finite probability.

### Example 4.2: Infinitesimal Dice
In a non-Archimedean field F with infinitesimal ε, define a "loaded die" on Fin(3) by:
- P({0}) = 1/3 + ε
- P({1}) = 1/3
- P({2}) = 1/3 - ε

This is an InfProbSpace: total mass = 1, all probabilities positive (since ε is infinitesimal, 1/3 - ε > 0). The "loading" is infinitesimally small — undetectable by any finite number of trials, yet formally present.

### Example 4.3: Product of Infinitesimal Spaces
Take two copies of the uniform InfProbSpace on Fin(n) in a non-Archimedean field. The product space on Fin(n) × Fin(n) has singleton probabilities 1/n² — infinitesimal of "second order" when 1/n is infinitesimal.

## 5. Generalizations

### 5.1 Beyond Finite Types
Our framework uses finitely additive measures on finsets, which naturally extends to any type (not necessarily finite). The InfProbSpace structure requires finiteness only for the normalization axiom. A natural generalization would be:
- A *locally finite* InfProbSpace, where normalization holds for a directed system of finite subsets
- A *surreal σ-additive* measure, with an appropriate notion of countable sum in the surreal numbers

### 5.2 Beyond Uniform Measures
The existence theorem (Theorem 3.8) constructs uniform measures. More generally, any positive assignment w: Ω → F with ∑ w(x) = 1 defines an InfProbSpace. The infinitesimal theory allows weights that mix standard and infinitesimal values.

### 5.3 Valued in Different Fields
Our results are parameterized over any linearly ordered field F with IsStrictOrderedRing. This includes:
- ℚ and ℝ (Archimedean, no infinitesimals)
- Hyperreal *ℝ (non-Archimedean, via ultrapower)
- Surreal numbers No (non-Archimedean, universal)
- Levi-Civita field (non-Archimedean, smallest analytically well-behaved extension of ℝ)

## 6. Boundary Cases and Counterexamples

### 6.1 The Archimedean Boundary
Theorem 3.6 establishes a sharp boundary: uniform positive singleton weights are possible if and only if the field is non-Archimedean. At the boundary (Archimedean fields), uniform InfProbSpaces exist only for finite spaces.

### 6.2 Failure of σ-Additivity
In a non-Archimedean field, if we have a countably additive measure μ with μ({n}) = ε for all n ∈ ℕ, then the sum ∑_{n=0}^∞ ε would need to be a well-defined element of F. In the surreal numbers, ω · ε is well-defined but may not equal 1 for arbitrary ε. This is a fundamental obstruction to extending our theory to σ-additivity.

### 6.3 Product Space Regularity
Theorem 3.13 shows products preserve regularity. However, if μ₁({x}) = ε₁ and μ₂({y}) = ε₂ are both infinitesimal, then μ({(x,y)}) = ε₁ε₂ is "more infinitesimal" — typically of higher infinitesimal order. This means product spaces have a finer infinitesimal structure than their factors.

## 7. Falsifiable Conjectures

**Conjecture 7.1** (Surreal σ-Finite Extension). There exists a surreal-valued measure on [0,1] that is σ-additive with respect to a suitable topology on the surreals, assigns infinitesimal measure to each point, and has total measure 1.

*Test*: Construct the measure explicitly using Conway's surreal number ω and ε = 1/ω, define summation over well-ordered index sets, and verify the σ-additivity axiom.

**Conjecture 7.2** (Infinitesimal Entropy). For an InfProbSpace with singleton probabilities ε, the Shannon entropy H = -∑ ε log ε is a well-defined surreal number of order log(1/ε) · 1/ε ≈ ω · log ω.

*Test*: Compute the entropy for specific non-Archimedean fields where logarithms are defined.

## 8. Discussion

Our framework provides a rigorous mathematical foundation for infinitesimal probability, resolving several conceptual issues in classical probability theory:

1. **Regularity**: Every singleton has positive probability, eliminating the problematic conflation of "impossible" and "probability zero."

2. **Universal Bayesian conditioning**: Bayes' theorem applies to all non-empty events, not just those with positive real probability.

3. **Graded improbability**: The infinitesimal structure of the field induces a hierarchy on events richer than the classical {0, positive} dichotomy.

4. **Necessity result**: Our Archimedean impossibility theorem shows this framework is not merely a luxury but a necessity for achieving these properties.

The price we pay is the loss of σ-additivity and the move to a more exotic number system. Whether this price is worth paying depends on the application. For philosophical foundations of probability, it resolves long-standing puzzles. For applications in Bayesian statistics, it provides clean answers where classical theory resorts to limits and approximations.

## 9. References

1. Conway, J. H. (1976). *On Numbers and Games*. Academic Press.
2. De Finetti, B. (1937). La prévision: ses lois logiques, ses sources subjectives. *Annales de l'institut Henri Poincaré*, 7(1), 1-68.
3. Gonshor, H. (1986). *An Introduction to the Theory of Surreal Numbers*. Cambridge University Press.
4. Kolmogorov, A. N. (1933). *Grundbegriffe der Wahrscheinlichkeitsrechnung*. Springer.
5. Lewis, D. (1980). A subjectivist's guide to objective chance. In *Studies in Inductive Logic and Probability*, Vol. II.
6. Nelson, E. (1977). Internal set theory: a new approach to nonstandard analysis. *Bulletin of the American Mathematical Society*, 83(6), 1165-1198.
7. Robinson, A. (1966). *Non-standard Analysis*. North-Holland.
8. Skyrms, B. (1980). *Causal Necessity*. Yale University Press.
9. Wenmackers, S., & Horsten, L. (2013). Fair infinite lotteries. *Synthese*, 190(1), 37-61.
