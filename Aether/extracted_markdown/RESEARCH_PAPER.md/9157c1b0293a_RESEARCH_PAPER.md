# The Collatz Affine Monoid: Algebraizing Collatz Dynamics via Orbit Composition

## Abstract

We introduce the **Collatz Affine Monoid (CAM)**, a monoid of affine-rational maps that algebraizes Collatz orbit dynamics. Each k-step Collatz orbit segment corresponds to an element (3^s, B, 2^e) where s is the count of odd steps, e the count of even steps, and B a combinatorially determined offset. We prove that this structure satisfies monoid laws under composition and establish several foundational theorems: (1) the Three-Two Separation Theorem (3^s = 2^e ⟹ s = e = 0), (2) a Fundamental Asymmetry Theorem showing no non-trivial orbit segment is neutral, (3) a density contraction criterion for orbit convergence, (4) offset positivity for orbits with odd steps, (5) coprimality of growth and decay factors, and (6) a modular periodicity result for 3^s mod 8. All results are formally verified in Lean 4 with Mathlib. The CAM framework reformulates the Collatz conjecture as a monoid reachability problem and connects it to the Oracle Closure Algebra through a termination hierarchy.

**Keywords:** Collatz conjecture, affine monoid, orbit encoding, Three-Two Separation, density contraction, parity words

## 1. Introduction

The Collatz conjecture (Lothar Collatz, 1937) states that iterating the map T(n) = n/2 if n is even, 3n+1 if n is odd, starting from any positive integer, eventually reaches 1. Despite its elementary statement, the conjecture has resisted proof for nearly nine decades. Conway (1972) showed that generalizations of this type of map can simulate arbitrary Turing machines, suggesting the conjecture may be inherently difficult.

Recent progress includes Tao's (2019) result that almost all orbits (in the sense of logarithmic density) achieve bounded values. However, the full conjecture remains open.

**Our contribution.** We introduce an algebraic framework that encodes Collatz orbit segments as elements of a monoid of affine-rational maps. This separates the predictable exponential growth/decay (governed by 3^s and 2^e) from the combinatorial complexity (the offset B), and reformulates the conjecture as a question about the reachability structure of this monoid.

### 1.1 Connection to the Catalog

This work builds on the **Oracle Closure Algebra** framework from the Catalog, which studies hierarchies where each level proves strictly more than the previous but no finite level suffices. Our **Termination Hierarchy** (Definition 6.1) is the iterative-function analog: T(k) = {n : collatz reaches 1 in ≤ k steps} forms a strictly increasing chain of decidable sets whose union is the (conjectural) set ℕ≥1. The CAM provides the algebraic machinery to study this hierarchy.

We also build on the existing formalization in `Algebra/CollatzUndecidable.lean` (Catalog Reference: `conjecture_iff_all_bounded`), which establishes structural theorems about generalized Collatz systems and parity exclusion.

**Catalog References:**
- `Algebra/CollatzUndecidable.lean`: Generalized Collatz Systems, Parity Exclusion Theorem
- `Algebra/ExponentBounds.lean`: Reciprocal bound techniques (`strict_reciprocal_bound_of_not_all_three`)

## 2. The Collatz Affine Monoid

### 2.1 Definition

**Definition 2.1** (CAM Element). A *CAM element* is a triple c = (a, b, d) ∈ ℕ × ℕ × ℕ>0 representing the affine-rational map x ↦ (ax + b)/d.

**Definition 2.2** (Composition). Given g = (a₂, b₂, d₂) and f = (a₁, b₁, d₁), their composition g ∘ f is:

g ∘ f = (a₂a₁, a₂b₁ + b₂d₁, d₁d₂)

representing g(f(x)) = (a₂(a₁x + b₁)/d₁ + b₂)/d₂ = (a₂a₁x + a₂b₁ + b₂d₁)/(d₁d₂).

**Theorem 2.3** (Monoid Laws). CAM composition is associative with identity (1, 0, 1).

*Proof.* Associativity follows by direct computation of all three components:
- Numerators: (a₃a₂)a₁ = a₃(a₂a₁) (associativity of multiplication)
- Denominators: (d₁d₂)d₃ = d₁(d₂d₃) (same)
- Offsets: a₃(a₂b₁ + b₂d₁) + b₃(d₁d₂) = a₃a₂b₁ + a₃b₂d₁ + b₃d₁d₂ (ring identity)

Identity: (1, 0, 1) ∘ (a, b, d) = (1·a, 1·b + 0·d, d·1) = (a, b, d). ∎

### 2.2 Collatz Step Elements

The two basic Collatz steps correspond to specific CAM elements:
- **Even step** (x ↦ x/2): camEven = (1, 0, 2)
- **Odd step** (x ↦ 3x + 1): camOdd = (3, 1, 1)

### 2.3 Parity Words

**Definition 2.4** (Parity Word). A *parity word* is a finite sequence w = (w₁, ..., wₖ) ∈ {0, 1}^k encoding whether each step in an orbit segment encounters an odd (1) or even (0) value.

**Definition 2.5** (Parity Word CAM). The CAM element for w is the composition of step elements in order:

parityWordCAM(w) = stepCAM(wₖ) ∘ ··· ∘ stepCAM(w₁)

## 3. The Three-Two Separation Theorem

**Theorem 3.1** (Three-Two Separation, Strong Form). For natural numbers s, e: if 3^s = 2^e, then s = 0 and e = 0.

*Proof.* By contradiction. If s ≥ 1 and e ≥ 1, then 3^s is odd (as a power of an odd number) while 2^e is even, contradicting equality. If s = 0 and e ≥ 1, then 1 = 2^e ≥ 2, a contradiction. If s ≥ 1 and e = 0, then 3^s = 1 contradicts s ≥ 1. ∎

**Corollary 3.2** (Quantitative Separation). For s + e > 0, (3^s : ℤ) ≠ (2^e : ℤ).

**Theorem 3.3** (Growth-Decay Dichotomy). For s + e > 0, exactly one of 3^s < 2^e or 3^s > 2^e holds.

*Proof.* Trichotomy gives three cases. The equality case is excluded by Theorem 3.1. ∎

### 3.1 Significance

The Growth-Decay Dichotomy means that every non-trivial Collatz orbit segment either strictly contracts or strictly expands in its linear part. There are no "balanced" segments. This creates a fundamental asymmetry that drives the dynamics — the conjecture asserts that contraction wins over expansion in the long run.

## 4. Numerator and Denominator Structure

**Theorem 4.1** (Parity Word Numerator). For any parity word w:
parityWordCAM(w).num = 3^(count of true in w)

**Theorem 4.2** (Parity Word Denominator). For any parity word w:
parityWordCAM(w).denom = 2^(count of false in w)

*Proof.* Both by induction on the length of w. For the empty word, both sides equal 1. For w = b :: ws, the composition multiplies numerators and denominators by the step element's values (3 and 1 for odd, 1 and 2 for even). ∎

**Theorem 4.3** (Fundamental Asymmetry). For any non-empty parity word w, the numerator and denominator of its CAM element are never equal.

*Proof.* By Theorems 4.1 and 4.2, the numerator is 3^s and the denominator is 2^e where s + e = length(w) > 0. Apply Theorem 3.1. ∎

## 5. Density Contraction

**Theorem 5.1** (Density Contraction). For a parity word of length k with s odd steps where 3s ≤ k and s ≥ 1: 3^s < 2^(k-s).

*Proof.* Since 3s ≤ k, we have k - s ≥ 2s. Therefore:
3^s < 4^s = (2^2)^s = 2^(2s) ≤ 2^(k-s). ∎

**Remark.** The condition 3s ≤ k means that at least 2/3 of the steps are even (division by 2). When this holds, the orbit segment strictly contracts. The weaker condition 2s < k does NOT suffice — a counterexample is s = 2, k = 5: 3² = 9 > 8 = 2³.

**Theorem 5.2** (Double-Density Contraction). For s ≥ 1: 3^s < 2^(2s).

*Proof.* 3^s < 4^s = 2^(2s) since 3 < 4 and s ≥ 1. ∎

## 6. Offset Theory

**Theorem 6.1** (Offset Composition). For CAM elements g, f:
(g ∘ f).offset = g.num × f.offset + g.offset × f.denom

This formula shows that offsets accumulate *multiplicatively* through composition — earlier offsets are amplified by later numerators.

**Theorem 6.2** (Offset Positivity). For any parity word containing at least one odd step, the offset is strictly positive.

*Proof.* By induction on the word. If the first element is odd (true), the offset includes a term g.num × camOdd.offset = g.num × 1 ≥ 1 > 0 (since numerators are powers of 3, hence ≥ 1). If the first element is even (false), the offset is 2 × (inner offset), which is positive by the inductive hypothesis. ∎

## 7. Modular Arithmetic Bridge

**Theorem 7.1** (Coprimality). For all s, e ∈ ℕ: gcd(3^s, 2^e) = 1.

*Proof.* Since gcd(3, 2) = 1, coprimality is preserved under taking powers. ∎

**Theorem 7.2** (Three-Power Periodicity mod 8). For all s ∈ ℕ:
3^s mod 8 = 1 if s is even, 3 if s is odd.

*Proof.* By the Chinese Remainder Theorem structure: 3² = 9 ≡ 1 (mod 8), so 3^s mod 8 depends only on s mod 2. ∎

**Corollary 7.3.** The map n ↦ 3^s · n is a bijection on ℤ/2^e for every e, since 3^s is a unit in ℤ/2^e by Theorem 7.1.

This connects the CAM framework to the rich theory of p-adic analysis: the orbit structure of the Collatz map is determined by the 2-adic properties of the offsets.

## 8. Termination Hierarchy

**Definition 8.1.** T(k) = {n ∈ ℕ : collatz reaches 1 within k steps}.

**Theorem 8.2** (Monotonicity). T(k) ⊆ T(k+1).

**Theorem 8.3** (Reformulation). The Collatz conjecture holds if and only if ⋃ₖ T(k) ⊇ {n ∈ ℕ : n ≥ 1}.

**Theorem 8.4** (Strictness, Small Cases). T(0) ⊊ T(1) ⊊ T(2): the value 2 ∈ T(1) \ T(0), and 4 ∈ T(2) \ T(1).

This hierarchy connects to the Oracle Closure Algebra: each T(k) represents a decidable approximation to the Π₂-complete full conjecture, and the CAM provides the algebraic parameterization of each level.

## 9. Reachability Reformulation

The CAM framework enables the following reformulation:

**Conjecture 9.1** (CAM Reachability). For every n ≥ 1, there exists a parity word w such that:
3^s · n + B = 2^e
where s = count of odd steps in w, e = count of even steps, and B = offset(w).

This separates the conjecture into:
1. **The exponential part**: Understanding which (s, e) pairs are compatible with a given n.
2. **The offset part**: Understanding which offsets B actually arise from valid parity words.
3. **The covering part**: Showing that every n ≥ 1 is captured by some valid (s, B, e).

## 10. Discussion and Future Work

### 10.1 What the CAM Framework Reveals

The CAM decomposition shows that the Collatz conjecture's difficulty is localized in the **offset structure** — the combinatorial complexity of how "+1" terms accumulate through different parity patterns. The exponential factors (3^s and 2^e) are completely predictable; the Three-Two Separation Theorem ensures they create a strict asymmetry; and the coprimality theorem ensures the growth factor acts as a bijection modulo the decay factor.

### 10.2 2-Adic Embedding (Future Direction)

The natural next step is to embed the CAM into the ring of 2-adic affine maps. Each CAM element (3^s, B, 2^e) defines a map on ℤ₂ (the 2-adic integers), and the set of valid offsets for signature (s, e) should have a well-defined 2-adic measure. If this measure decays appropriately as s + e → ∞, it would provide a measure-theoretic approach to the conjecture, potentially connecting to Tao's "almost all" result.

### 10.3 Limitations

The CAM framework does not by itself resolve the conjecture. The reachability problem over the monoid is at least as hard as the original conjecture. However, the algebraic structure provides new handles for attack — in particular, the modular arithmetic of offsets and the 2-adic structure of the monoid.

## 11. Formal Verification

All theorems in this paper have been formally verified in Lean 4 (v4.28.0) using the Mathlib library. The formalization is contained in `Algebra/CollatzAffineMonoid.lean` and comprises approximately 280 lines of verified code with zero uses of `sorry`. Key features of the formalization:

- The CAM composition and identity are defined as concrete structures, not via typeclasses, to maintain computational transparency.
- Parity words are represented as `List Bool`, enabling direct computation of examples via `native_decide`.
- The Three-Two Separation Theorem is proved from first principles using oddness of powers of 3.

## References

1. Lagarias, J.C. (2010). *The Ultimate Challenge: The 3x+1 Problem*. American Mathematical Society.
2. Tao, T. (2019). "Almost all orbits of the Collatz map attain almost bounded values." *arXiv:1909.03562*.
3. Conway, J.H. (1972). "Unpredictable iterations." *Proceedings of the 1972 Number Theory Conference*, pp. 49-52.
