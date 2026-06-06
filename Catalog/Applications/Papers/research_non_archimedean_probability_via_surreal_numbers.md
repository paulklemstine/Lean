# Non-Archimedean Probability Theory: Finitely Additive Measures with Infinitesimal Weights

## Abstract

We develop a rigorous framework for probability theory in non-Archimedean linearly ordered fields, where infinitesimal probabilities are first-class citizens. Our central construction is the **finitely additive probability measure** `FinAddProb Ω F` valued in an arbitrary linearly ordered field `F`, together with the **uniform infinitesimal probability space** `UniformInfProb Ω F` where every point receives equal positive infinitesimal probability. We prove that infinitesimal elements form a convex additive subgroup closed under bounded multiplication, that the standard measure-theoretic identities (complement rule, monotonicity, inclusion-exclusion) hold in the non-Archimedean setting, and that our framework enables well-defined conditional probability on singletons — recovering the Dirac delta as an honest conditional distribution rather than a limiting artifact. All results are formalized in Lean 4 with complete machine-checked proofs.

## 1. Introduction

Standard probability theory, as axiomatized by Kolmogorov, is built on real-valued measures. A fundamental consequence of countable additivity in ℝ is that in any uncountable probability space, "most" points must have probability zero. This creates well-known conceptual difficulties:

1. **Conditioning on null events**: P(A | B) is undefined when P(B) = 0, yet probabilists routinely condition on continuous random variables taking specific values.
2. **Uniform distributions on infinite sets**: There is no countably additive probability measure on ℕ that assigns equal probability to each number.
3. **Philosophical puzzles**: If a dart is thrown at [0,1], what is the probability of hitting exactly π/4? Standard theory says zero, yet the event is possible.

Non-standard analysis, pioneered by Robinson (1966) and applied to probability by Loeb (1975), provides one resolution using hyperreal numbers. However, the Loeb measure construction requires the transfer principle and ultrafilter technology, obscuring the underlying algebraic simplicity.

We propose a more elementary approach: work directly with finitely additive probability measures valued in an arbitrary linearly ordered field that may contain infinitesimal elements. This yields a clean algebraic theory that:
- Requires only finite additivity (not countable additivity)
- Works over any linearly ordered field (Archimedean or not)
- Enables positive probability for every point
- Provides well-defined conditional probability on singletons
- Recovers the Dirac delta as an honest conditional distribution

## 2. Infinitesimal Elements in Ordered Fields

### 2.1 Definition

Let F be a linearly ordered field. An element x ∈ F is **infinitesimal** if n · |x| < 1 for every positive natural number n. Equivalently, |x| < 1/n for every positive integer n.

**Definition (IsInfinitesimal)**: `IsInfinitesimal x ≡ ∀ n : ℕ, 0 < n → (n : F) * |x| < 1`

**Definition (HasInfinitesimals)**: A field F **has infinitesimals** if there exists x > 0 with `IsInfinitesimal x`.

### 2.2 Algebraic Closure Properties

**Theorem 1 (Additive Closure)**: *The sum of two infinitesimals is infinitesimal.*

*Proof sketch*: The key is the "2n trick." Given infinitesimals x, y and positive n, note that 2n is also positive, so (2n)|x| < 1 and (2n)|y| < 1, giving n|x| < 1/2 and n|y| < 1/2. By the triangle inequality, n|x+y| ≤ n|x| + n|y| < 1. □

This is more subtle than it appears: the naive bound n|x| < 1 and n|y| < 1 only gives n|x+y| < 2, which is insufficient. The factor-of-2 trick is essential.

**Theorem 2 (Multiplicative Absorption)**: *If x is infinitesimal and |y| ≤ M for some natural M, then xy is infinitesimal.*

*Proof sketch*: For positive n, n|xy| = n|x||y| ≤ nM|x| = (nM)|x| < 1 since nM is a positive natural. □

**Theorem 3 (Square Closure)**: *The square of an infinitesimal is infinitesimal.*

This follows from Theorem 2 with M = 1, since |x| < 1 for any infinitesimal x.

### 2.3 Archimedean Dichotomy

**Theorem 4**: *In an Archimedean field, the only infinitesimal is zero.*

*Proof*: If x ≠ 0, then |x| > 0. By the Archimedean property, there exists n with n|x| ≥ 1, contradicting infinitesimality. □

This is the fundamental boundary result: non-Archimedean fields are precisely those where our theory becomes non-trivial.

## 3. Finitely Additive Probability Measures

### 3.1 The Structure

**Definition (FinAddProb)**: A *finitely additive probability measure* on Ω valued in F consists of:
- A function μ : Set Ω → F
- Non-negativity: μ(S) ≥ 0 for all S
- Null empty set: μ(∅) = 0
- Normalization: μ(Ω) = 1
- Finite additivity: μ(A ∪ B) = μ(A) + μ(B) when A ∩ B = ∅

### 3.2 Derived Properties

**Theorem 5 (Complement Rule)**: μ(Sᶜ) = 1 - μ(S).

**Theorem 6 (Monotonicity)**: A ⊆ B ⟹ μ(A) ≤ μ(B).

**Theorem 7 (Inclusion-Exclusion)**: μ(A ∪ B) = μ(A) + μ(B) - μ(A ∩ B).

**Theorem 8 (Sub-additivity)**: μ(A ∪ B) ≤ μ(A) + μ(B).

All four follow by standard algebraic manipulations from the axioms.

### 3.3 Conditional Probability

**Definition**: P(A | B) = μ(A ∩ B) / μ(B), defined whenever μ(B) ≠ 0.

In the non-Archimedean setting, μ(B) can be a positive infinitesimal — still nonzero, so division is well-defined. This is the crucial advantage over real-valued probability.

**Theorem 9 (Conditional Probability Bounds)**: 0 ≤ P(A | B) ≤ 1 when μ(B) > 0.

## 4. Uniform Infinitesimal Probability Spaces

### 4.1 The Construction

**Definition (UniformInfProb)**: A *uniform infinitesimal probability space* is a `FinAddProb` equipped with:
- A weight ε > 0 with `IsInfinitesimal ε`
- Each singleton has measure ε: μ({x}) = ε for all x ∈ Ω

### 4.2 Anti-Concentration

**Theorem 10 (Finset Measure)**: *For a finite set S with |S| = n, μ(S) = nε.*

*Proof*: By induction on the Finset structure, using finite additivity and singleton measure. □

**Theorem 11 (Anti-Concentration)**: *The measure of any finite set is infinitesimal.*

*Proof*: μ(S) = |S| · ε. Since ε is infinitesimal and |S| is a natural number bound, |S| · ε is infinitesimal by the multiplicative absorption theorem. □

**Theorem 12 (No Finite Exhaustion)**: *μ(S) < 1 for every finite set S.*

This is an immediate corollary: infinitesimals have absolute value less than 1.

### 4.3 The Dirac Recovery Theorem

**Theorem 13 (Dirac Recovery)**: *In a uniform infinitesimal probability space,*
$$P(A \mid \{x\}) = \begin{cases} 1 & \text{if } x \in A \\ 0 & \text{if } x \notin A \end{cases}$$

*Proof*: If x ∈ A, then A ∩ {x} = {x}, so P(A | {x}) = μ({x})/μ({x}) = 1. If x ∉ A, then A ∩ {x} = ∅, so P(A | {x}) = 0/μ({x}) = 0. □

**Significance**: This theorem shows that in non-Archimedean probability, conditioning on a singleton is always well-defined and yields exactly the Dirac delta measure. In standard probability, one needs regular conditional distributions (which require σ-algebra structure and the Radon-Nikodym theorem) to make sense of conditioning on null events. Here, it follows immediately from the algebraic structure — no measure theory machinery required.

## 5. Connections and Context

### 5.1 Relationship to Nonstandard Analysis

Our framework can be seen as a simplification of the Loeb measure construction. Loeb (1975) showed how to convert a hyperfinite counting measure (which is *-finitely additive) into a genuine σ-additive measure via the standard part map. Our approach stops before taking standard parts, working directly with the infinitesimal-valued measure. This preserves information that the Loeb construction discards.

### 5.2 Connection to de Finetti's Probability

De Finetti (1974) advocated for finitely additive probability as more fundamental than countably additive probability. Our framework vindicates this view in a new way: finite additivity is not merely a weakening of countable additivity, but enables qualitatively new phenomena (positive probability for all points) when the value field is enlarged.

### 5.3 Cross-Domain Bridge

The Anti-Concentration Theorem (Theorem 11) provides a bridge to existing catalog results. The `sum_ne_zero_of_same_sign_and_exists_ne_zero` theorem from the Lorentzian aggregate anti-cancellation work establishes that sums of same-sign elements don't cancel to zero. Our result is a probability-theoretic analogue: sums of infinitesimal probabilities remain infinitesimal (and hence nonzero and less than 1), preventing any finite collection from "exhausting" the measure.

## 6. Falsifiable Conjectures

**Conjecture 1 (Infinitesimal Kolmogorov Extension)**: There exists a non-Archimedean linearly ordered field F and a uniform infinitesimal probability measure on [0,1]_F (the unit interval in F) that is finitely additive and assigns weight ε to each point, where ε is infinitesimal and the measure of the whole interval is exactly 1.

**Computational Test**: Construct F as the field of formal Laurent series ℝ((t)) with t infinitesimal. Define μ({x}) = t for each x ∈ [0,1] ∩ ℝ. Verify that μ is finitely additive on finite unions and that μ([0,1]) can be consistently defined as 1.

**Status**: Our `UniformInfProb` structure axiomatizes exactly this scenario. The existence question reduces to whether a consistent assignment μ : Set([0,1]) → ℝ((t)) satisfying the axioms exists. By our `finset_measure_lt_one` theorem, any such measure must assign infinitesimal measure to every finite set.

**Conjecture 2 (Infinitesimal Bayes)**: For any uniform infinitesimal probability space, the posterior distribution obtained by conditioning on a finite set S recovers the classical uniform distribution on S.

## 7. Algorithms

### 7.1 Infinitesimal Arithmetic

For computational purposes, represent infinitesimals as formal power series in an indeterminate ε:
```
a₀ + a₁ε + a₂ε² + ... (finite truncation)
```
with standard polynomial arithmetic. Probability computations then reduce to polynomial arithmetic.

### 7.2 Conditional Probability

Given a uniform infinitesimal measure with weight ε:
1. Compute μ(A ∩ B) by counting: |A ∩ B| · ε
2. Compute μ(B) by counting: |B| · ε
3. P(A|B) = |A ∩ B| / |B| (the ε cancels)

This recovers the classical counting formula for conditional probability on finite sets.

## 8. Discussion and Future Work

Our formalization demonstrates that non-Archimedean probability theory has a clean algebraic foundation that can be fully machine-verified. The key structural insight is that infinitesimal elements in ordered fields satisfy exactly the closure properties needed for probability measure theory.

Future directions include:
1. Developing non-Archimedean expectation and integration
2. Proving a non-Archimedean strong law of large numbers
3. Connecting to game-theoretic probability via surreal numbers
4. Exploring applications to Bayesian epistemology (fair lotteries on infinite sets)

## References

1. Conway, J.H. *On Numbers and Games*. Academic Press, 1976.
2. de Finetti, B. *Theory of Probability*. Wiley, 1974.
3. Kolmogorov, A.N. *Foundations of the Theory of Probability*. Chelsea, 1933/1956.
4. Loeb, P.A. "Conversion from nonstandard to standard measure spaces." *Trans. AMS*, 211:113-122, 1975.
5. Robinson, A. *Non-standard Analysis*. North-Holland, 1966.
