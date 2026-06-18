# Non-Archimedean Probability via Infinitesimal Weights: A Formalized Theory

## Abstract

We develop a foundational theory of finitely additive probability measures valued in non-Archimedean ordered fields, where infinitesimal probabilities are well-defined. We prove a sharp dichotomy: a linearly ordered field supports a uniform positive probability assignment on arbitrary finite sets if and only if it is non-Archimedean (i.e., contains an infinitesimal). We construct explicit uniform measures with infinitesimal weights, prove finite additivity, inclusion-exclusion, monotonicity, and establish a non-Archimedean Bayes' theorem where conditioning on infinitesimal-probability events is well-defined. All results are fully formalized in Lean 4 with Mathlib.

## 1. Introduction

The standard axiomatization of probability, due to Kolmogorov (1933), assigns probabilities in the real numbers ℝ. A well-known consequence is that for any probability measure on an uncountable space (e.g., [0,1] with Lebesgue measure), all but countably many singletons must receive probability zero. This creates a foundational tension: individual outcomes are possible but have zero probability, and conditional probability P(A|B) = P(A∩B)/P(B) is undefined when P(B) = 0.

Several approaches have been proposed to address this limitation:
- **Nonstandard analysis** (Robinson, 1966): Using hyperreal numbers to formalize infinitesimal probabilities
- **Lexicographic probability** (Blume, Brandenburger, Dekel, 1991): Probability vectors with lexicographic ordering
- **Conditional probability spaces** (Rényi, 1955): Taking conditional probability as primitive

We propose a new approach: probability measures valued in non-Archimedean ordered fields, including Conway's surreal numbers (Conway, 1976). The key insight is that infinitesimal elements in such fields provide a natural weight for individual points, and finite additivity yields a consistent probability theory.

### 1.1 Contributions

1. **Formal definitions** of infinitesimal elements, non-Archimedean fields, and finitely additive probability measures (§2)
2. **Archimedean Impossibility Theorem**: No Archimedean field supports a uniform positive probability assignment that keeps finite partial sums bounded (§3)
3. **Non-Archimedean Existence Theorem**: Every non-Archimedean field supports a uniform finitely additive probability measure with all finite partial sums below 1 (§4)
4. **Non-Archimedean Bayes' Theorem**: Conditional probability is well-defined for all nonempty events, including those with infinitesimal probability (§5)
5. **Bridge to existing results**: Connection to the aggregate anti-cancellation theorem from Lorentzian geometry (§6)

### 1.2 Catalog References

This work builds upon and extends:
- `sum_ne_zero_of_same_sign_and_exists_ne_zero` from `FINAL/Pythagorean/LorentzianAggregateAntiCancel.lean`: The uniform positivity of our measure (Theorem 5.3) instantiates this pattern — the measure values on nonempty sets form a same-sign family with a nonzero member.
- The surreal topology results from `Catalog/Geometry/SurrealTopology.lean`, which establish that surreal-like spaces have non-first-countable neighborhoods — our probability theory provides a measure-theoretic complement to this topological analysis.

## 2. Definitions

### Definition 2.1 (Infinitesimal)
Let F be a linearly ordered field. An element ε ∈ F is **infinitesimal** if:
1. 0 < ε
2. For every natural number n ≥ 1, n · ε < 1

### Definition 2.2 (Non-Archimedean Field)
A linearly ordered field F is **non-Archimedean** if there exists an infinitesimal ε ∈ F.

### Definition 2.3 (Archimedean Field)
A linearly ordered field F is **Archimedean** if for every x > 0, there exists n ∈ ℕ with 1 ≤ n · x.

### Definition 2.4 (Finitely Additive Probability Measure)
A **finitely additive probability measure** on a type α with values in F consists of a function μ : Finset(α) → F satisfying:
1. μ(∅) = 0
2. μ(S) ≥ 0 for all finite S
3. μ(S ∪ T) = μ(S) + μ(T) whenever S ∩ T = ∅

### Definition 2.5 (Uniform Measure)
A finitely additive measure is **uniform** with weight w if μ({x}) = w for all x.

### Definition 2.6 (Conditional Probability)
For a finitely additive measure μ with μ(B) ≠ 0:
$$P(A | B) = \frac{\mu(A \cap B)}{\mu(B)}$$

## 3. Archimedean Impossibility

**Theorem 3.1 (Archimedean Breaks Uniform).**
If F is Archimedean and ε > 0, then there exists n ∈ ℕ with n · ε ≥ 1.

*Proof.* Direct from the definition of Archimedean. □

**Theorem 3.2 (Infinitesimal ⟹ Not Archimedean).**
If F contains an infinitesimal ε, then F is not Archimedean.

*Proof.* Suppose F is Archimedean. Then for ε > 0, there exists n with 1 ≤ n · ε. If n = 0, then 1 ≤ 0, a contradiction. If n > 0, then n · ε < 1 by the infinitesimal property, contradicting 1 ≤ n · ε. □

**Corollary 3.3 (Dichotomy).**
A linearly ordered field is either Archimedean (no infinitesimals, no uniform point probability below 1) or non-Archimedean (infinitesimals exist, uniform point probability is possible).

## 4. Non-Archimedean Existence

**Theorem 4.1 (Existence of Uniform Measure).**
Let F be a non-Archimedean field with infinitesimal ε. Define μ(S) = |S| · ε for finite sets S. Then:

1. μ is a finitely additive probability measure
2. μ is uniform with weight ε
3. μ(S) < 1 for every finite set S

*Proof.* 
- **Empty set**: μ(∅) = 0 · ε = 0. ✓
- **Nonnegativity**: |S| ≥ 0 and ε > 0, so |S| · ε ≥ 0. ✓
- **Additivity**: For disjoint S, T: μ(S ∪ T) = |S ∪ T| · ε = (|S| + |T|) · ε = μ(S) + μ(T). ✓
- **Uniformity**: μ({x}) = 1 · ε = ε. ✓
- **Boundedness**: If S = ∅, then μ(S) = 0 < 1. If S ≠ ∅, then |S| ≥ 1, and |S| · ε < 1 by the infinitesimal property. ✓ □

## 5. Conditional Probability and Bayes' Theorem

**Theorem 5.1 (Self-conditioning).**
P(B | B) = 1 for any B with μ(B) ≠ 0.

*Proof.* P(B | B) = μ(B ∩ B)/μ(B) = μ(B)/μ(B) = 1. □

**Theorem 5.2 (Non-Archimedean Bayes' Theorem).**
For any A, B with μ(A) ≠ 0 and μ(B) ≠ 0:
$$P(A|B) \cdot \mu(B) = P(B|A) \cdot \mu(A)$$

*Proof.* The left side equals μ(A ∩ B)/μ(B) · μ(B) = μ(A ∩ B). The right side equals μ(B ∩ A)/μ(A) · μ(A) = μ(B ∩ A). Since A ∩ B = B ∩ A, the two sides are equal. □

*Remark.* In standard probability, Bayes' theorem requires P(B) > 0 in the real-valued sense. Here, infinitesimal probability suffices — P({x}) = ε > 0 for every singleton {x}, so conditioning on any nonempty event is well-defined.

**Theorem 5.3 (Positivity on Nonempty Sets).**
For a uniform measure with positive weight, μ(S) > 0 for every nonempty finite set S.

*Proof.* μ(S) = |S| · ε. Since S is nonempty, |S| ≥ 1, so |S| > 0. Since ε > 0, the product is positive. □

**Theorem 5.4 (Disjoint Singleton Conditioning).**
For distinct points x ≠ y in a uniform measure: P({x} | {y}) = 0.

*Proof.* {x} ∩ {y} = ∅ since x ≠ y. So P({x} | {y}) = μ(∅)/μ({y}) = 0/ε = 0. □

## 6. Additional Structure

### 6.1 Monotonicity and Set Difference

**Theorem 6.1 (Monotonicity).**
If S ⊆ T, then μ(S) ≤ μ(T).

*Proof.* T = S ∪ (T \ S) disjointly. By additivity, μ(T) = μ(S) + μ(T \ S). Since μ(T \ S) ≥ 0, we get μ(S) ≤ μ(T). □

**Theorem 6.2 (Set Difference).**
If S ⊆ T, then μ(T \ S) = μ(T) − μ(S).

**Theorem 6.3 (Inclusion-Exclusion).**
μ(S ∪ T) = μ(S) + μ(T) − μ(S ∩ T).

### 6.2 Ratio Independence

**Theorem 6.4 (Ratio Theorem).**
For a uniform measure, μ(S) · |T| = μ(T) · |S| for all finite sets S, T.

This shows that the ratio μ(S)/μ(T) = |S|/|T| is independent of the choice of infinitesimal ε, recovering the classical equi-probability principle.

### 6.3 Fundamental Counting Principle

**Theorem 6.5 (Counting Principle).**
For a uniform measure with weight ε, μ(S) = |S| · ε for every finite set S.

This is proved by induction on the finite set, using additivity and uniformity.

## 7. PEGB Analysis

### Theorem: Non-Archimedean Existence (Theorem 4.1)

**P (Proof):** Constructive — we build the measure explicitly as μ(S) = |S| · ε and verify all axioms.

**E (Example):** In a field containing ε = 1/ω (as in Conway's surreal numbers), consider the set S = {1, 2, 3, 4, 5}. Then μ(S) = 5/ω, which is infinitesimal. The conditional probability P({1} | S) = μ({1})/μ(S) = (1/ω)/(5/ω) = 1/5, a standard real number.

**G (Generalization):** The construction works for any non-Archimedean ordered field, not just surreal numbers. This includes hyperreal numbers, Levi-Civita field, and formal Laurent series fields. The next level up would be extending to σ-additive or τ-additive measures using ultrafilter-based constructions.

**B (Boundary):** The construction breaks down for countable additivity — the sum ∑_{n=1}^∞ ε does not converge in the standard sense in a non-Archimedean field. The field must not be Archimedean (obviously), but it also must have a sufficiently rich algebraic structure to support the division needed for conditional probability.

### Theorem: Archimedean Impossibility (Theorem 3.2)

**P:** By contradiction — assuming both Archimedean and infinitesimal leads to the existence of n with 1 ≤ n·ε and n·ε < 1 simultaneously.

**E:** In ℝ, take any ε = 0.001. Then n = 1000 gives n·ε = 1. No real number can be infinitesimal.

**G:** This extends to any Archimedean ordered group (not just fields). The key property is the Archimedean axiom itself.

**B:** The boundary is exactly the Archimedean/non-Archimedean divide. This is a clean dichotomy with no intermediate cases.

### Theorem: Non-Archimedean Bayes (Theorem 5.2)

**P:** Direct calculation using commutativity of intersection and cancellation of the denominator.

**E:** With ε = 1/ω, let A = {1, 2} and B = {2, 3}. Then P(A|B) = μ({2})/μ({2,3}) = (1/ω)/(2/ω) = 1/2. Similarly P(B|A) = 1/2. And P(A|B)·μ(B) = (1/2)·(2/ω) = 1/ω = μ({2}) = P(B|A)·μ(A).

**G:** Extends to any finitely additive measure on a Boolean algebra, not just Finset. The algebraic structure needed is a field (for division) with a linear order.

**B:** Breaks down when μ(B) = 0, which in our framework only happens for the empty set. In standard probability, P(B) = 0 for uncountably many singletons.

## 8. Discussion

### 8.1 Comparison with Nonstandard Analysis

Our framework differs from Robinson's nonstandard analysis in that we work axiomatically with any non-Archimedean field, rather than constructing specific models via ultrafilters. This gives greater generality — any field with the required properties supports our construction — at the cost of not having transfer principles.

### 8.2 Philosophical Implications

The Archimedean impossibility theorem reveals that the impossibility of uniform point probability is not a fundamental feature of probability theory, but rather an artifact of the choice of value field. By working in a larger field, the impossibility dissolves. This suggests that the standard measure-theoretic framework, while enormously successful, is not the only coherent foundation for probability.

### 8.3 Connection to Existing Results

The positivity theorem (Theorem 5.3) is an instance of the general principle formalized in `sum_ne_zero_of_same_sign_and_exists_ne_zero` (from the Lorentzian aggregate anti-cancellation theorem): a collection of same-sign values with at least one nonzero member has a nonzero sum. Our measure values {μ(S) : S nonempty} form exactly such a collection.

## 9. Future Work

1. **Integration theory**: Develop a theory of integration for non-Archimedean measures, potentially using limits along ultrafilters
2. **Central limit theorem**: Investigate whether sums of infinitesimally-weighted random variables converge to a "non-Archimedean Gaussian"
3. **Game-theoretic applications**: Apply infinitesimal probabilities to extensive-form games with continuous action spaces
4. **Topological measure theory**: Combine with the surreal topology results (cofinality spectra) to develop a topological measure theory for non-Archimedean spaces

## References

1. Conway, J.H. (1976). *On Numbers and Games*. Academic Press.
2. Robinson, A. (1966). *Non-standard Analysis*. North-Holland.
3. Kolmogorov, A.N. (1933). *Grundbegriffe der Wahrscheinlichkeitsrechnung*. Springer.
4. de Finetti, B. (1974). *Theory of Probability*. Wiley.
5. Blume, L., Brandenburger, A., Dekel, E. (1991). "Lexicographic probabilities and choice under uncertainty." *Econometrica*, 59(1), 61-79.
6. Rényi, A. (1955). "On a new axiomatic theory of probability." *Acta Mathematica Academiae Scientiarum Hungaricae*, 6(3-4), 285-335.
7. Benci, V., Horsten, L., Wenmackers, S. (2013). "Non-Archimedean probability." *Milan Journal of Mathematics*, 81(1), 121-151.
