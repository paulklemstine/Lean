# Non-Archimedean Probability Theory: Finitely Additive Measures with Infinitesimal Point Probabilities

## Abstract

We develop a rigorous framework for probability measures valued in non-Archimedean ordered fields, where infinitesimal probabilities can be assigned to individual points. We define `FinAddProb`, a finitely additive probability measure structure, and `NonArchProbSpace`, which extends it with the requirement that all singletons carry infinitesimal positive measure. Our main results include: (1) the **Singleton Conditional Probability Theorem**, showing that P(A|{ω}) = 1_{ω∈A} in any non-Archimedean probability space; (2) the **Non-Archimedean Exclusion Principle**, demonstrating that μ({ω}ᶜ) < 1 — unlike classical probability where singleton complements always have full measure; (3) **Bayes' Theorem** transfers without modification to the non-Archimedean setting; (4) the **Archimedean Exclusion Theorem**, proving that no Archimedean field (including ℝ) admits infinitesimal elements, establishing the necessity of non-Archimedean fields. All results are formalized and verified in Lean 4 with Mathlib.

## 1. Introduction

### 1.1 Motivation

In classical measure-theoretic probability, a probability measure μ on an uncountable space (Ω, Σ) must assign μ({ω}) = 0 to all but countably many singletons. This is a consequence of σ-additivity: if uncountably many singletons had positive measure, countable additivity would force μ(Ω) = ∞, contradicting normalization.

This creates several well-known difficulties:
- **Undefined conditioning**: P(A|{ω}) = P(A∩{ω})/P({ω}) = 0/0 is undefined for continuous distributions.
- **Information loss**: P({ω}ᶜ) = 1 = P(Ω) — removing a single point is undetectable by the measure.
- **Philosophical tension**: Events with probability zero are declared "almost impossible" but can occur.

### 1.2 Our Approach

We replace σ-additivity with finite additivity and the real-valued codomain with a general linearly ordered field. When this field is non-Archimedean (contains infinitesimals), singletons can carry positive but infinitesimal probability without violating normalization.

This approach has historical precedent in de Finetti's advocacy for finite additivity (1930s) and connections to Robinson's nonstandard analysis (1960s) and Loeb's construction (1975). Our contribution is a clean axiomatic framework with complete formal proofs.

### 1.3 Contributions

1. **Novel mathematical structures**: `FinAddProb` and `NonArchProbSpace`, parameterized over arbitrary linearly ordered fields.
2. **The Singleton Conditional Probability Theorem** (Theorem 3.1): Resolves the 0/0 conditioning problem.
3. **The Non-Archimedean Exclusion Principle** (Theorem 3.3): Shows information preservation for individual points.
4. **The Archimedean Exclusion Theorem** (Theorem 3.5): Proves ℝ fundamentally cannot support infinitesimal probability.
5. **Complete Lean 4 formalization** with 18 verified theorems and zero sorries.

## 2. Definitions

### 2.1 Infinitesimal Elements

**Definition 2.1** (IsInfinitesimal). Let V be a linearly ordered field. An element x ∈ V is *infinitesimal* if:
- x > 0, and
- For every positive natural number n: n · x < 1.

Equivalently, x is positive but less than 1/n for all n ∈ ℕ⁺. This directly negates the Archimedean property for x.

**Definition 2.2** (HasInfinitesimal). A field V *has infinitesimals* if ∃x ∈ V with IsInfinitesimal(x).

### 2.2 Finitely Additive Probability

**Definition 2.3** (FinAddProb). A *finitely additive probability measure* on Ω valued in V consists of a function μ: Set(Ω) → V satisfying:
1. **Non-negativity**: μ(A) ≥ 0 for all A ⊆ Ω
2. **Normalization**: μ(Ω) = 1
3. **Empty set**: μ(∅) = 0
4. **Finite additivity**: If A ∩ B = ∅, then μ(A ∪ B) = μ(A) + μ(B)

Note: We do not require σ-additivity, which is the key relaxation enabling infinitesimal point probabilities.

### 2.3 Non-Archimedean Probability Space

**Definition 2.4** (NonArchProbSpace). A *non-Archimedean probability space* on Ω valued in V is a FinAddProb together with:
- **Singleton positivity**: μ({ω}) > 0 for all ω ∈ Ω
- **Singleton infinitesimality**: IsInfinitesimal(μ({ω})) for all ω ∈ Ω

### 2.4 Conditional Probability

**Definition 2.5** (condProb). The *conditional probability* of A given B is:
  P(A|B) = μ(A ∩ B) / μ(B)
defined whenever μ(B) > 0.

In a NonArchProbSpace, this is defined for every non-empty B, including singletons.

## 3. Main Results

### 3.1 Basic Properties of FinAddProb

**Theorem 3.0** (Monotonicity). If A ⊆ B, then μ(A) ≤ μ(B).

*Proof sketch*: B = A ∪ (B\A) with A ∩ (B\A) = ∅. By additivity, μ(B) = μ(A) + μ(B\A). Since μ(B\A) ≥ 0, we get μ(A) ≤ μ(B). □

**Theorem 3.0'** (Complement). μ(Aᶜ) = 1 - μ(A).

**Theorem 3.0''** (Inclusion-Exclusion). μ(A ∪ B) + μ(A ∩ B) = μ(A) + μ(B).

**Theorem 3.0'''** (Upper Bound). μ(A) ≤ 1 for all A.

### 3.2 The Singleton Conditional Probability Theorem

**Theorem 3.1**. Let (Ω, V, P) be a NonArchProbSpace. For any A ⊆ Ω and ω ∈ Ω:

P(A | {ω}) = 1 if ω ∈ A, and P(A | {ω}) = 0 if ω ∉ A.

*Proof*: If ω ∈ A, then A ∩ {ω} = {ω}, so P(A|{ω}) = μ({ω})/μ({ω}) = 1 (using div_self and the fact that μ({ω}) > 0 gives μ({ω}) ≠ 0).

If ω ∉ A, then A ∩ {ω} = ∅, so P(A|{ω}) = μ(∅)/μ({ω}) = 0/μ({ω}) = 0. □

**PEGB Analysis**:
- **Example**: On {1,...,10} with uniform infinitesimal probability ε per point, P({1,2,3}|{2}) = 1, P({1,2,3}|{5}) = 0.
- **Generalization**: The theorem generalizes to conditioning on any finite set F: P(A|F) = |A∩F|/|F| when all points in F have equal probability.
- **Boundary**: When μ({ω}) = 0 (classical case), the conditional probability is undefined — this is the boundary where the theorem ceases to apply, precisely the classical setting.

### 3.3 The Non-Archimedean Exclusion Principle

**Theorem 3.2**. In any NonArchProbSpace, μ({ω}ᶜ) < 1 for all ω.

*Proof*: μ({ω}ᶜ) = 1 - μ({ω}). Since μ({ω}) > 0, we have 1 - μ({ω}) < 1. □

**PEGB Analysis**:
- **Example**: If μ({ω}) = ε, then μ({ω}ᶜ) = 1 - ε, which is strictly less than 1 in the non-Archimedean ordering.
- **Generalization**: For any finite F ⊆ Ω, μ(Fᶜ) < 1 - |F| · min_{ω∈F} μ({ω}).
- **Boundary**: In the Archimedean (real-valued) case, if we tried to have μ({ω}) > 0 for uncountably many ω, normalization would force a contradiction.

### 3.4 Infinitesimal Pair Bound

**Theorem 3.3**. For distinct a, b ∈ Ω in a NonArchProbSpace:
  μ({a, b}) < 2 · n⁻¹ for every positive natural number n.

*Proof*: By pair_eq, μ({a,b}) = μ({a}) + μ({b}). Each term satisfies n · μ({x}) < 1, i.e., μ({x}) < n⁻¹. Summing: μ({a,b}) < 2n⁻¹. □

**PEGB Analysis**:
- **Example**: With μ({a}) = μ({b}) = ε, we get μ({a,b}) = 2ε < 2/n for all n.
- **Generalization**: For a k-element set F, μ(F) < k · n⁻¹ for all n > 0.
- **Boundary**: This bound is tight: in a field with ε = 1/(n₀+1) for some fixed n₀, the bound fails for n > n₀. True infinitesimality (for ALL n) is essential.

### 3.5 Bayes' Theorem

**Theorem 3.4**. For any FinAddProb with μ(A) > 0 and μ(B) > 0:
  P(A|B) · μ(B) = P(B|A) · μ(A)

*Proof*: Both sides equal μ(A ∩ B), using div_mul_cancel and inter_comm. □

### 3.6 Conditional Probability as a Probability

**Theorem 3.4'**. For fixed B with μ(B) > 0, the function A ↦ P(A|B) satisfies:
- P(Ω|B) = 1
- P(∅|B) = 0
- P(A|B) ∈ [0, 1]

### 3.7 The Archimedean Exclusion Theorem

**Theorem 3.5**. If V is Archimedean, then HasInfinitesimal(V) is false.

*Proof*: Suppose x > 0 is infinitesimal: ∀n > 0, n · x < 1. By the Archimedean property, ∃n ∈ ℕ with 1 ≤ n · x. Since n · x ≥ 1 > 0, we have n > 0. But n · x < 1 by infinitesimality. Contradiction. □

**PEGB Analysis**:
- **Example**: In ℝ, take x = 10⁻¹⁰⁰. Then n = 10¹⁰⁰ gives n·x = 1 ≥ 1. Not infinitesimal.
- **Generalization**: More precisely, a linearly ordered field is Archimedean if and only if it admits an order-preserving embedding into ℝ (Hahn's theorem).
- **Boundary**: The hyperreals ℝ* and the surreal numbers No are non-Archimedean and do contain infinitesimals.

## 4. Discussion

### 4.1 Relationship to Nonstandard Analysis

Our framework is related to but distinct from Loeb's measure construction in nonstandard analysis. In the Loeb construction, one starts with an internal probability measure on a hyperfinite set (valued in *ℝ), then takes the standard part to obtain a genuine σ-additive measure on ℝ. Our approach stays in the non-Archimedean field throughout, preserving the infinitesimal information that the standard-part map discards.

### 4.2 The Role of Finite Additivity

Dropping σ-additivity is essential. If σ-additivity held and every singleton had positive probability ε, then for any countably infinite set S, μ(S) = Σ_{ω∈S} ε. In a non-Archimedean field, this series doesn't converge in the usual sense, and its "sum" would need to be carefully defined. Finite additivity avoids this issue entirely.

### 4.3 Connection to de Finetti

Our approach aligns with Bruno de Finetti's philosophy that finite additivity is the correct primitive for probability, with σ-additivity being an additional (sometimes convenient) assumption. De Finetti argued that finite additivity captures the operational meaning of probability (coherent betting), while σ-additivity is a mathematical convenience.

### 4.4 Cross-Domain Connection

The Archimedean Exclusion Theorem connects to the broader catalog of impossibility results, specifically the theme that structural constraints on number systems determine what mathematical structures are possible. The `sum_ne_zero_of_same_sign_and_exists_ne_zero` result from the Lorentzian aggregate theory provides a parallel: in any ordered structure, a finite sum of same-sign nonzero terms is nonzero — exactly the property underlying our monotonicity and pair-eq results.

## 5. Algorithms

### 5.1 Finite Computation

For finite sample spaces, non-Archimedean probability reduces to exact rational arithmetic: given Ω = {ω₁,...,ωₙ} with equal probabilities, μ({ωᵢ}) = 1/n.

### 5.2 Dual-Number Representation

For computational purposes, surreal-like probabilities can be represented as dual numbers a + bε ∈ ℝ[ε]/(ε²), with arithmetic defined by:
- (a + bε) + (c + dε) = (a+c) + (b+d)ε
- (a + bε) · (c + dε) = ac + (ad+bc)ε
- (a + bε) / (c + dε) = a/c + (bc-ad)/c²·ε (when c ≠ 0)

This gives a computationally efficient model of first-order infinitesimal probability.

## 6. Formal Verification

All definitions and theorems are formalized in Lean 4 with Mathlib 4.28.0. The formalization is parameterized over an arbitrary linearly ordered field V (using typeclasses `[Field V] [LinearOrder V] [IsStrictOrderedRing V]`), making the results applicable to any concrete non-Archimedean field.

**Theorem count**: 18 (6 basic properties + 5 non-Archimedean theorems + 5 conditional probability properties + inclusion-exclusion + Archimedean exclusion).

**Sorry count**: 0.

**Axioms used**: propext, Classical.choice, Quot.sound (standard).

## 7. Future Work

1. **Infinite additivity in non-Archimedean fields**: Define a suitable notion of convergence for non-Archimedean series and investigate when infinite sums of infinitesimals can equal finite values.

2. **Integration theory**: Develop a non-Archimedean Lebesgue-like integral for surreal-valued functions.

3. **Applications to Bayesian statistics**: Use infinitesimal probabilities as rigorous foundations for improper priors.

4. **Quantum probability**: Investigate whether non-Archimedean probability resolves measurement paradoxes in quantum mechanics.

## References

- Conway, J.H. (1976). *On Numbers and Games*. Academic Press.
- de Finetti, B. (1937). La prévision: ses lois logiques, ses sources subjectives.
- Loeb, P. (1975). Conversion from nonstandard to standard measure spaces. *Trans. AMS*.
- Nelson, E. (1977). Internal set theory. *Bull. AMS*.
- Robinson, A. (1966). *Non-standard Analysis*. North-Holland.
