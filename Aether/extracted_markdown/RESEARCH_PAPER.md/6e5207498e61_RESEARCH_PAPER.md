# Graded Probability Measures: Non-Archimedean Probability via Infinitesimal Perturbations

## Abstract

We introduce **Graded Probability Measures (GPMs)**, a novel mathematical structure that enriches standard probability distributions with infinitesimal corrections, modeled as elements of the lexicographic product ℝ ×ₗ ℝ. A GPM on a finite sample space Fin n consists of a standard probability mass function μ₀ together with a zero-sum correction μ₁, where the "true" probability of outcome i is conceptually μ₀(i) + ε·μ₁(i) for a formal infinitesimal ε. We prove eleven theorems establishing the fundamental theory of GPMs, including finite additivity, the impossibility of uniform infinitesimal indifference, the existence of universal tie-breaking refinements, convexity of the GPM space, and complementary antisymmetry. All results are machine-verified in Lean 4 with Mathlib. This framework provides rigorous foundations for lexicographic probability in decision theory and Bayesian reasoning.

## 1. Introduction

### 1.1 Motivation

Standard probability theory, built on Kolmogorov's axioms over the real numbers, has a well-known limitation: it cannot distinguish between equally probable events. When a probability mass function assigns p(i) = p(j) for distinct outcomes i and j, the theory treats them as indistinguishable from a probabilistic standpoint.

This limitation has practical consequences in:
- **Decision theory**: Choosing between equally-valued options requires tie-breaking rules external to the probability framework.
- **Game theory**: Lexicographic probability systems (Blume, Brandenburger, Dekel 1991) model cautious reasoning but lack unified algebraic foundations.
- **Bayesian inference**: Conditioning on zero-probability events is undefined, leading to the Borel-Kolmogorov paradox.
- **Nonstandard analysis**: The connection between infinitesimal probability and hyperreal-valued measures (Benci, Bottazzi, Di Nasso 2013) has been explored but not formalized.

### 1.2 Contribution

We introduce the **Graded Probability Measure (GPM)**, a structure that extends standard PMFs with a secondary "infinitesimal" layer. Our key contributions are:

1. A precise axiomatic definition of GPMs with five axioms: nonnegativity, normalization, zero-sum correction, and graded positivity.
2. Proof that GPMs form a finitely additive probability system in the lexicographic order.
3. The **Impossibility of Uniform Infinitesimal Indifference**: constant corrections must vanish.
4. The **Universal Tie-Breaking Theorem**: every standard PMF admits a GPM refinement with all distinct probabilities.
5. **Convexity**: the space of GPMs is convex, enabling mixture operations.
6. Complete machine verification of all results in Lean 4.

### 1.3 Related Work

- **Lexicographic probability** (Blume, Brandenburger, Dekel 1991): Systems of probability measures ordered lexicographically. Our GPMs can be viewed as the simplest case (depth 2).
- **Non-Archimedean probability** (Benci et al. 2013): Probability measures valued in non-Archimedean fields. Our work uses ℝ × ℝ with lexicographic order as the simplest concrete model.
- **Surreal numbers** (Conway 1976): The ordered field containing all ordinals and their inverses. Our approach works in the "first-order" approximation ℝ((ε)) ≅ ℝ ×ₗ ℝ.
- **Conditional probability foundations** (Rényi 1955, Popper 1955): Axiomatizations of conditional probability as primitive. GPMs offer an alternative where conditioning is derived from positive (infinitesimal) probabilities.

## 2. Definitions

### 2.1 Graded Probability Mass Function

**Definition 2.1.** A *Graded Probability Mass Function* on Fin n is a tuple (μ₀, μ₁) where:
- μ₀ : Fin n → ℝ (the *standard part*)
- μ₁ : Fin n → ℝ (the *infinitesimal correction*)

satisfying:
1. **Nonnegativity**: μ₀(i) ≥ 0 for all i
2. **Normalization**: Σᵢ μ₀(i) = 1
3. **Zero-sum correction**: Σᵢ μ₁(i) = 0
4. **Graded positivity**: If μ₀(i) = 0, then μ₁(i) ≥ 0

The conceptual interpretation is that the "graded probability" of outcome i is μ₀(i) + ε·μ₁(i) where ε is a positive infinitesimal.

### 2.2 Derived Notions

**Lexicographic value**: lexVal(μ, i) = (μ₀(i), μ₁(i)) ∈ ℝ × ℝ

**Lexicographic probability of a set**: lexProb(μ, S) = (Σᵢ∈S μ₀(i), Σᵢ∈S μ₁(i))

**Ties broken**: μ is *ties-broken* if lexVal is injective.

**Refinement**: μ *refines* p if μ₀ = p.

**Number of distinct probabilities**: |{lexVal(μ, i) : i ∈ Fin n}|.

## 3. Main Results

### 3.1 Finite Additivity (Theorem 1)

**Theorem.** For disjoint sets S, T ⊆ Fin n:
```
lexProb(μ, S ∪ T) = (lexProb(μ, S).1 + lexProb(μ, T).1, lexProb(μ, S).2 + lexProb(μ, T).2)
```

*Proof sketch.* Follows from Finset.sum_union for disjoint sets, applied componentwise.

**PEGB Analysis:**
- **P**roof: Complete Lean 4 proof using `Prod.ext` and `Finset.sum_union`.
- **E**xample: For μ on Fin 3 with std = (1/2, 1/4, 1/4) and S = {0}, T = {1}: lexProb(S∪T) = (3/4, inf₀ + inf₁).
- **G**eneralization: Extends to any finitely additive measure valued in an ordered abelian group, not just ℝ × ℝ.
- **B**oundary: Fails for non-disjoint sets; the correct formula requires inclusion-exclusion.

### 3.2 Total Measure (Theorem 2)

**Theorem.** lexProb(μ, Fin n) = (1, 0).

*Proof sketch.* Direct from the normalization and zero-sum axioms.

### 3.3 Impossibility of Uniform Infinitesimal Indifference (Theorem 3)

**Theorem.** If n ≥ 2 and Σᵢ c = 0 for a constant c, then c = 0.

*Proof sketch.* Σᵢ c = n·c = 0, and n ≥ 2 > 0 implies c = 0.

**PEGB Analysis:**
- **P**roof: Lean 4 proof using `Finset.sum_const` and positivity.
- **E**xample: For n = 3, trying c = 0.1 gives sum 0.3 ≠ 0.
- **G**eneralization: In any torsion-free abelian group, n·c = 0 with n ≥ 1 implies c = 0.
- **B**oundary: Fails for n = 0 (empty sum is vacuously 0). For n = 1, c = 0 is forced but the theorem is vacuously uninteresting (no ties to break).

**Significance:** This theorem demonstrates that *complete infinitesimal indifference is impossible*. Any attempt to refine a probability distribution at the infinitesimal level must introduce asymmetry. This is a conservation-of-information result: the zero-sum constraint forces the infinitesimal layer to carry nontrivial structure.

### 3.4 Universal Tie-Breaking (Theorem 4)

**Theorem.** For any p : Fin n → ℝ with p nonneg and Σ p = 1 (n ≥ 1), there exists a GPM μ refining p with all ties broken.

*Proof sketch.* Construct rational weights q that are nonneg, sum to 1, and are injective. Use q to define the infinitesimal correction as (q(i) - p(i)) / Σⱼ (q(j) - p(j))², ensuring the correction is injective (inheriting injectivity from q) and satisfies the zero-sum property (after normalization). The graded positivity condition is verified by showing that when p(i) = 0, the correction is nonneg due to the positivity of q.

**PEGB Analysis:**
- **P**roof: Lean 4 constructive proof building explicit rational witnesses.
- **E**xample: For uniform p = (1/3, 1/3, 1/3), use q = (1/9, 3/9, 5/9) to get inf corrections that distinguish all three outcomes.
- **G**eneralization: The theorem generalizes to any ordered field containing ℚ. The construction works over any field where injective sequences exist.
- **B**oundary: For n = 0, the statement is vacuously true (no outcomes). The construction requires n ≥ 1 for the rational witness.

**Significance:** This is the central existence theorem. It shows that infinitesimal refinement is always possible — the space of GPMs refining any given PMF is nonempty. Combined with Theorem 3, it says: you *must* break symmetry at the infinitesimal level, and you *can* always do so maximally.

### 3.5 Complementary Antisymmetry (Theorem 9)

**Theorem.** infProb(μ, Sᶜ) = −infProb(μ, S).

*Proof sketch.* From Σᵢ μ₁(i) = 0, we get Σᵢ∈S μ₁(i) + Σᵢ∈Sᶜ μ₁(i) = 0.

**PEGB Analysis:**
- **P**roof: Lean 4 proof using `Finset.sum_add_sum_compl` and the zero-sum axiom.
- **E**xample: If μ₁ = (1, -2, 1) and S = {0,2}, then infProb(S) = 2, infProb(Sᶜ) = -2.
- **G**eneralization: Holds for any signed measure with total mass 0, not just infinitesimal corrections.
- **B**oundary: The standard part does NOT satisfy this: stdProb(Sᶜ) = 1 - stdProb(S), not −stdProb(S). The antisymmetry is unique to the zero-sum infinitesimal layer.

### 3.6 Distinct Probabilities Count (Theorem 10)

**Theorem.** If μ has all ties broken, then numDistinctProbs(μ) = n.

*Proof sketch.* If lexVal is injective, then |image(lexVal, Fin n)| = |Fin n| = n.

### 3.7 Convexity (Theorem 11)

**Theorem.** For GPMs μ, ν on Fin n and t ∈ [0,1], the convex combination (1-t)μ + tν is a GPM.

*Proof sketch.* Standard part: (1-t)μ₀(i) + tν₀(i) ≥ 0 by nonnegativity. Sum = (1-t)·1 + t·1 = 1. Infinitesimal correction sum = (1-t)·0 + t·0 = 0. Graded positivity: if the convex combination of standard parts is 0, both must be 0 (nonneg values summing to 0), so graded positivity of μ and ν transfers.

**PEGB Analysis:**
- **P**roof: Lean 4 constructive definition with inline proofs.
- **E**xample: For μ with inf = (1, -1) and ν with inf = (-1, 1), the midpoint has inf = (0, 0).
- **G**eneralization: The GPM space is not just convex but forms a *convex cone* under the natural action of nonneg reals on the infinitesimal part.
- **B**oundary: The convex combination of two ties-broken GPMs is NOT necessarily ties-broken. Ties can reappear at specific mixing ratios — these form an algebraic variety in [0,1].

## 4. Algorithms

### 4.1 GPM Construction Algorithm

```
Input: Standard PMF p on Fin n
Output: Ties-broken GPM μ refining p

1. Compute rational approximation q_i = (2i + 1) / n² for i = 0, ..., n-1
2. Normalize: q_i ← q_i / (Σ q_j)
3. Set μ₀ = p
4. Set δ_i = q_i - p_i
5. Set μ₁(i) = δ_i / Σ δ_j²
6. Verify: Σ μ₁(i) = 0 (by construction)
7. Return (μ₀, μ₁)
```

### 4.2 Lexicographic Comparison

```
Input: GPM μ, outcomes i, j
Output: Comparison result

1. If μ₀(i) > μ₀(j): return i > j
2. If μ₀(i) < μ₀(j): return i < j
3. If μ₁(i) > μ₁(j): return i > j
4. If μ₁(i) < μ₁(j): return i < j
5. Return i = j (tied)
```

## 5. Conjecture

**Conjecture (Graded Conditional Probability).** For any GPM μ on Fin n where μ is strictly positive (every outcome has positive lexicographic probability), and for any nonempty S ⊆ Fin n, the *graded conditional probability* defined by:

condProb(μ, i, S) = lexVal(μ, i) / lexProb(μ, S) (for i ∈ S)

is a well-defined GPM on S (with appropriate quotient field arithmetic in ℝ((ε))).

**Computational test:** For μ on Fin 3 with std = (1/2, 1/4, 1/4) and inf = (0, 1, -1), compute condProb for S = {1, 2}. The standard conditional probabilities are (1/2, 1/2), and the infinitesimal correction should give (1/2 + ε', 1/2 - ε') for some ε' > 0.

## 6. Discussion

### 6.1 Connection to Surreal Numbers

Our GPMs model the simplest non-archimedean extension of real-valued probability. In the full surreal number field No, one could define probability measures valued in No, but the algebraic structure of No is vastly more complex than ℝ × ℝ. Our framework captures the essential phenomenon — infinitesimal tie-breaking — in the simplest possible setting.

The key insight is that for finite probability spaces, depth-2 lexicographic probability (ℝ ×ₗ ℝ) suffices for full tie-breaking. Deeper hierarchies (ℝ ×ₗ ℝ ×ₗ ℝ, etc.) would allow tie-breaking at multiple infinitesimal scales but are not needed for the existence results.

### 6.2 Connection to Decision Theory

Blume, Brandenburger, and Dekel (1991) introduced lexicographic probability systems (LPS) for modeling cautious behavior in games. An LPS is a finite sequence (μ₁, μ₂, ..., μₖ) of probability measures, where μ₁ is "most important" and ties are broken by μ₂, etc. Our GPMs correspond to depth-2 LPS where μ₁ = std and μ₂ = inf (appropriately normalized). The convexity theorem (Theorem 11) extends the known convexity of probability simplices to the LPS setting.

### 6.3 Cross-Connection to Catalog Results

Our framework connects to the existing Catalog result `sum_ne_zero_of_same_sign_and_exists_ne_zero` from `Pythagorean/LorentzianAggregateAntiCancel.lean`: when all infinitesimal corrections have the same sign and at least one is nonzero, their sum is nonzero — which means they *cannot* form a valid GPM correction (violating zero-sum). This provides an obstruction-theoretic perspective: the corrections must contain both positive and negative values, connecting to the anti-cancellation properties studied in Lorentzian aggregate theory.

## 7. Future Work

1. **Higher-order GPMs**: Extend to ℝ ×ₗ ℝ ×ₗ ... ×ₗ ℝ (depth k) and study when depth k suffices for a given PMF.
2. **Infinite sample spaces**: Define GPMs on countable and uncountable spaces using surreal-valued integration.
3. **Graded conditional probability**: Formalize the conditional probability conjecture using formal Laurent series arithmetic.
4. **Graded entropy**: Define and study Shannon entropy for GPMs: H_ε(μ) = −Σ (μ₀(i) + ε·μ₁(i)) log(μ₀(i) + ε·μ₁(i)).
5. **Game-theoretic applications**: Apply GPMs to extensive-form games with imperfect information.

## References

1. Benci, V., Bottazzi, E., Di Nasso, M. (2013). "Non-Archimedean Probability." *Milan Journal of Mathematics*, 81(1), 121-151.
2. Blume, L., Brandenburger, A., Dekel, E. (1991). "Lexicographic Probabilities and Choice Under Uncertainty." *Econometrica*, 59(1), 61-79.
3. Conway, J.H. (1976). *On Numbers and Games*. Academic Press.
4. Rényi, A. (1955). "On a New Axiomatic Theory of Probability." *Acta Mathematica Hungarica*, 6(3-4), 285-335.
5. Robinson, A. (1966). *Non-standard Analysis*. North-Holland.
