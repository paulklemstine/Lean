# Ultrapower Arithmetic and Overflow Semirings: Formalized Non-Standard Models of ℕ

## Abstract

We present a formalized development of non-standard arithmetic via ultrapower constructions, together with a novel algebraic axiomatization called *Overflow Semirings* that captures the essential structure of non-standard models. Working in Lean 4 with the Mathlib library, we construct the ultrapower *ℕ = ℕ^ℕ/U for a free ultrafilter U and prove fundamental properties: the non-Archimedean property (existence of elements exceeding all standard numbers), universal divisibility of the non-standard factorial (ω! is divisible by every standard number while remaining nonzero), the power hierarchy (ω < ω² < ω³ < ...), the existence of non-standard primes, the overflow/overspill principle, transfer of first-order algebraic properties, and — crucially — the failure of well-ordering. All proofs are machine-verified with no axioms beyond the standard foundations (propext, Classical.choice, Quot.sound).

**Keywords**: Non-standard arithmetic, ultrapower construction, ultrafilter, transfer principle, overflow semiring, formal verification

## 1. Introduction

Non-standard models of arithmetic, first constructed by Skolem (1934) and systematically developed through Robinson's non-standard analysis (1960s), provide a rigorous framework for reasoning with "infinite" and "infinitesimal" elements. The ultrapower construction, due to Łoś (1955), remains the most common method for building such models.

Despite the mathematical maturity of this theory, formal machine-verified treatments are sparse. We present what we believe is the first comprehensive formalization of ultrapower arithmetic over ℕ in a modern proof assistant, together with a novel algebraic axiomatization.

### 1.1 Contributions

1. **Novel Structure (OverflowSemiring)**: We introduce and axiomatize *Overflow Semirings* — linearly ordered commutative semirings with a strictly monotone embedding of ℕ and an absorbing "infinite" element. We prove structural theorems about finite/infinite classification and absorption propagation.

2. **Ultrapower Construction**: We formalize the ultrapower *ℕ at the pre-quotient level using Filter.Eventually, proving:
   - Non-Archimedean property (Theorem 3.1)
   - Universal divisibility of ω! (Theorem 4.1)
   - Transfer of algebraic identities (Theorem 2.1)
   - Zero-product transfer / integral domain property (Theorem 2.2)
   - Power hierarchy (Theorem 6.1)
   - Non-standard primes (Theorem 7.1)
   - Failure of well-ordering (Theorem 8.1)
   - Overflow principle (Theorem 5.1)
   - Bounded universal transfer (Theorem 9.1)

3. **Cross-Connections**: We connect our results to the existing formalized ultraproduct library (Bridges/DependentUltraproduct) and the non-Archimedean computation framework (Bridges/NonArchimedeanComputation).

## 2. The OverflowSemiring Structure

### 2.1 Definition

**Definition 2.1** (OverflowSemiring). An *Overflow Semiring* over a type R is a structure (R, +, ·, ≤, std, ω) where:
- (R, +, ·) is a commutative semiring
- (R, ≤) is a linear order
- std : ℕ → R is a ring homomorphism (preserving 0, 1, +, ·)
- std is strictly monotone
- ω ∈ R satisfies std(n) < ω for all n ∈ ℕ
- ω absorbs standard additions: std(n) + ω = ω for all n

### 2.2 Basic Properties

**Theorem 2.1** (Injectivity). The standard embedding is injective.
*Proof*: Follows immediately from strict monotonicity.

**Theorem 2.2** (Non-Standard Separation). ω ∉ Im(std).
*Proof*: std(n) < ω for all n, so std(n) ≠ ω.

**Theorem 2.3** (Positivity). 0 < ω.
*Proof*: 0 = std(0) < ω.

### 2.3 Finite/Infinite Dichotomy

**Definition 2.2**. An element x ∈ R is *finite* if ∃n, x ≤ std(n). It is *infinite* if ∀n, std(n) < x.

**Theorem 2.4** (Dichotomy). No element is simultaneously finite and infinite.
*Proof*: If x ≤ std(n) and std(n) < x, contradiction.

**Theorem 2.5** (Closure under Addition). The sum of two infinite elements is infinite, assuming covariant addition.
*Proof*: If x, y are infinite, then for any n: std(n) < x ≤ x + y (since y > 0).

**Theorem 2.6** (Absorption Propagation). For all k > 0 and n ∈ ℕ: std(n) + k·ω = k·ω.
*Proof*: By induction on k, using associativity and the absorption axiom.

### 2.4 Non-Archimedean Characterization

**Theorem 2.7**. An OverflowSemiring is never Archimedean: ¬(∀x, ∃n, x ≤ std(n)).
*Proof*: ω witnesses the failure.

## 3. The Ultrapower Construction

### 3.1 Setup

We work with sequences f, g : ℕ → ℕ modulo a free ultrafilter U on ℕ. Rather than forming the full quotient type, we work at the *pre-quotient* level: a property P holds "in *ℕ" if and only if {i ∈ ℕ | P(f(i))} ∈ U.

**Definition 3.1**.
- UEq(f, g) :⟺ ∀ᶠ i in U, f(i) = g(i)
- ULt(f, g) :⟺ ∀ᶠ i in U, f(i) < g(i)
- UDiv(f, g) :⟺ ∀ᶠ i in U, f(i) | g(i)
- std(n) := λi. n (constant sequence)
- diagonal := id (identity sequence, representing ω)
- factorial_seq := Nat.factorial (representing ω!)

### 3.2 The Non-Archimedean Theorem

**Theorem 3.1** (Non-Archimedean). For any free ultrafilter U and any n ∈ ℕ, ULt(std(n), diagonal).

*Proof*: The set {i | n < i} has complement {0, ..., n}, which is finite. Since U is free (no singleton belongs to U), no finite set belongs to U, hence {0, ..., n} ∉ U, so {i | n < i} ∈ U.

*Example*: For n = 100, {i | 100 < i} = {101, 102, ...} ∈ U.

*Generalization*: Any sequence f with {i | f(i) ≤ n} finite exceeds std(n).

*Boundary*: For a principal ultrafilter at point k, diagonal evaluates to k — a standard number. The theorem requires freeness.

### 3.3 Helper Lemma

**Lemma 3.2** (Cofinite Membership). If no singleton {i} belongs to U, then every set with finite complement belongs to U.

*Proof*: By induction on the size of the complement, using the ultrafilter union property.

## 4. Universal Divisibility

**Theorem 4.1** (Universal Divisibility). For any free ultrafilter U and any n > 0, UDiv(std(n), factorial_seq).

*Proof*: For any fixed n > 0, n | i! for all i ≥ n (since i! = 1·2·...·i contains n as a factor). So {i | ¬(n | i!)} ⊆ {0, ..., n-1}, which is finite. By Lemma 3.2, {i | n | i!} ∈ U.

**Theorem 4.2** (Nonzero). ¬UEq(factorial_seq, std(0)).

*Proof*: i! > 0 for all i, so {i | i! = 0} = ∅ ∉ U.

**Remark**. Theorems 4.1 and 4.2 together show that *ℕ contains a nonzero element divisible by every standard number — an impossibility in standard ℕ.

## 5. The Overflow Principle

**Theorem 5.1** (Overflow). If P holds for all but finitely many standard numbers, then ∀ᶠ i in U, P(i).

*Proof*: {i | ¬P(i)} is finite, so {i | P(i)} has finite complement, hence belongs to U by Lemma 3.2.

**Theorem 5.2** (Overspill). If P holds for all standard numbers, then ∀ᶠ i in U, P(i).

*Proof*: Immediate from Filter.Eventually.of_forall.

## 6. The Power Hierarchy

**Theorem 6.1** (Power Hierarchy). For any k ∈ ℕ, ULt(λi. i^k, λi. i^(k+1)).

*Proof*: For i ≥ 2, i^k < i^(k+1) = i · i^k since i ≥ 2. So {i | i^k ≥ i^(k+1)} ⊆ {0, 1}, which is finite.

*Corollary*: ω < ω² < ω³ < ... in *ℕ. The non-standard world has infinitely many "levels of infinity."

**Theorem 6.2** (ω² exceeds standards). For all n, ULt(std(n), λi. i·i).

## 7. Non-Standard Primes

**Theorem 7.1**. There exists a sequence f such that UPrime(f) (f represents a prime) and f exceeds every standard prime.

*Proof*: Take f(i) = p_i (the i-th prime). Then p_i is prime for all i, giving UPrime(f). For any standard prime p, {i | p_i ≤ p} is finite (there are finitely many primes ≤ p), so ULt(std(p), f).

## 8. Failure of Well-Ordering

**Theorem 8.1** (Well-Ordering Fails). There exists a sequence s : ℕ → (ℕ → ℕ) such that ULt(s(k+1), s(k)) for all k.

*Proof*: Take s(k)(i) = i - k (natural subtraction). For k fixed, {i | i-(k+1) ≥ i-k} ⊆ {0, ..., k+1}, which is finite. So ULt(s(k+1), s(k)).

*Significance*: ℕ is well-ordered, but *ℕ is not. Well-ordering is a second-order property that does not transfer through the ultrapower (Łoś's theorem transfers only first-order sentences).

## 9. Transfer of Algebraic Properties

**Theorem 9.1** (Bounded ∀ Transfer). For any n and P : ℕ → ℕ → Prop, if ∀k < n, ∀ᶠ i, P(i,k), then ∀ᶠ i, ∀k < n, P(i,k).

*Proof*: By induction on n, using filter intersection.

**Theorem 9.2** (Zero-Product Transfer). If UEq(f·g, 0), then UEq(f, 0) or UEq(g, 0).

*Proof*: Since ℕ has no zero divisors, {i | f(i)·g(i) = 0} implies f(i) = 0 ∨ g(i) = 0 at each i. By the ultrafilter prime ideal property, one factor vanishes on a U-large set.

## 10. Falsifiable Conjecture

**Conjecture**: For any sequence p : ℕ → ℕ, the set {n | p(n) is prime} either belongs to U or its complement does.

**Status**: This is trivially true by the ultrafilter property — for ANY set S, S ∈ U or Sᶜ ∈ U. The deeper question is whether the specific structure of primes interacts nontrivially with the ultrafilter choice.

**Computational Test**: Verify that for p(n) = n² + 1, computations up to n = 10⁶ show roughly 5% prime density. A non-principal ultrafilter must select either the prime or composite side.

## 11. Connections to Catalog

Our work connects to:
- **Bridges/DependentUltraproduct.lean**: Our UEq is the special case of UltraEq for the constant family K(i) = ℕ
- **Bridges/NonArchimedeanComputation.lean**: Our ultrapower provides the canonical non-Archimedean arithmetic where p-adic depth bounds find their natural home
- **Bridges/SurrealTopologyDeep.lean**: The archimedean_bound theorem connects to our non-Archimedean characterization

## 12. Future Work

1. Formalize the full quotient construction (CommSemiring instance on *ℕ)
2. Define the standard part map for "finite" non-standard elements
3. Prove a full version of Łoś's theorem for bounded arithmetic formulas
4. Explore non-standard Ramsey theory
5. Connect to p-adic analysis through the non-Archimedean bridge

## References

1. Łoś, J. (1955). Quelques remarques, théorèmes et problèmes sur les classes définissables d'algèbres. *Mathematical Interpretation of Formal Systems*, 98-113.
2. Robinson, A. (1966). *Non-Standard Analysis*. North-Holland.
3. Goldblatt, R. (1998). *Lectures on the Hyperreals: An Introduction to Nonstandard Analysis*. Springer.
4. Schmerl, J.H. (1995). Models of Peano Arithmetic. *Handbook of Mathematical Logic*.
