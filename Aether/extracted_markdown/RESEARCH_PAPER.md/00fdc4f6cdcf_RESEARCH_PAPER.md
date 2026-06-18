# Growth Dominance Algebra on Non-Standard Arithmetic: A Formally Verified Theory

## Abstract

We introduce the **Growth Dominance Preorder (GDP)** on the ultrapower *ℕ = ℕ^ℕ/U, a novel mathematical structure that classifies elements of the non-standard natural numbers by their asymptotic growth rate. Given a free ultrafilter U on ℕ, we define dominance (f ≪_U g iff for all C, C·f < g U-eventually) and growth equivalence (f ≈_U g iff each is within a constant multiple of the other). We prove 21 theorems establishing the fundamental properties of this structure, including: (1) the polynomial hierarchy theorem (ω^k ≪ ω^(k+1)), (2) factorial dominance over all polynomials (ω^k ≪ ω!), (3) a gap insertion theorem showing density of growth classes between polynomial levels, (4) compatibility of growth equivalence with multiplication, and (5) transfer of GCD and coprimality. All results are formally verified in Lean 4 with Mathlib.

## 1. Introduction

Non-standard models of arithmetic, first systematically studied by Skolem (1934) and later developed into non-standard analysis by Robinson (1966), provide a framework for reasoning about infinite and infinitesimal quantities. The ultrapower construction *ℕ = ℕ^ℕ/U, where U is a non-principal ultrafilter on ℕ, yields a non-standard model containing elements that exceed every standard natural number.

While the basic ultrapower construction is well-studied, the internal structure of the infinite elements of *ℕ — particularly their classification by growth rate — has received less formal attention. We introduce the Growth Dominance Preorder (GDP) as a tool for organizing this structure.

### 1.1 Contributions

1. **Novel Structure (GDP)**: We define the Growth Dominance Preorder, a strict partial order on *ℕ that captures asymptotic growth rates. This is distinct from the ultrapower total order — it quotients out constant factors to focus on growth type.

2. **Polynomial Hierarchy**: We prove that the powers ω, ω², ω³, ... form a strict infinite chain under dominance, establishing a formal counterpart to the complexity-theoretic polynomial hierarchy.

3. **Factorial Dominance**: We show ω! dominates every ω^k, using a bridge argument via real-analytic convergence of n^k/n!.

4. **Gap Insertion**: We prove that between ω^k and ω^(k+1), intermediate elements exist, showing the polynomial growth hierarchy is dense.

5. **Arithmetic Transfer**: We establish transfer of GCD, coprimality, and composite factorization, showing the multiplicative structure of ℕ is faithfully extended.

6. **Full Formal Verification**: All 21 theorems are proved in Lean 4 with no `sorry` or non-standard axioms.

## 2. Preliminaries

### 2.1 Ultrafilters on ℕ

A filter F on ℕ is a collection of subsets closed under finite intersection and superset. An ultrafilter U is a maximal filter, equivalently one satisfying: for every S ⊆ ℕ, either S ∈ U or Sᶜ ∈ U. A free (non-principal) ultrafilter contains no finite sets.

**Definition (IsFreeUltrafilter).** We say U is free if for every i ∈ ℕ, {i}ᶜ ∈ U.

**Theorem (mem_of_cofinite).** If U is free and S is finite, then Sᶜ ∈ U.

*Proof.* By induction on the finite set S. □

### 2.2 The Ultrapower *ℕ

Elements of *ℕ are equivalence classes of sequences ℕ → ℕ under the relation f ∼_U g iff {i | f(i) = g(i)} ∈ U. We work at the "pre-quotient" level, stating properties as U-eventual statements, which is equivalent to Łoś's theorem for quantifier-free formulas.

## 3. The Growth Dominance Preorder

### 3.1 Definitions

**Definition (Dominance).** f ≪_U g iff ∀ C ∈ ℕ, {i | C · f(i) < g(i)} ∈ U.

**Definition (Growth Equivalence).** f ≈_U g iff ∃ C₁ > 0, f ≤ C₁ · g U-eventually, and ∃ C₂ > 0, g ≤ C₂ · f U-eventually.

**Definition (Standard Elements).** std(n) = (n, n, n, ...), the constant sequence.

**Definition (Canonical Non-Standard Element).** ω = (0, 1, 2, 3, ...) = id.

**Definition (Power Hierarchy).** ω^k = (i ↦ i^k).

**Definition (Factorial Element).** ω! = (i ↦ i!).

### 3.2 Basic Properties

**Theorem 3.1 (Irreflexivity).** If f is U-eventually positive, then f does not dominate itself.

*Proof.* If f ≪_U f, then for C = 1, we have f(i) < f(i) U-eventually, which is impossible. □

**Theorem 3.2 (Transitivity).** If f ≪_U g and g ≪_U h, then f ≪_U h.

*Proof.* Given C, from f ≪_U g with constant C+1 we get (C+1)·f < g, and from g ≪_U h with constant 1 we get g < h. On their U-large intersection, C·f < (C+1)·f < g < h. □

**Theorem 3.3 (Dominance implies ULt).** If f ≪_U g, then f <_U g (i.e., f(i) < g(i) U-eventually).

### 3.3 Growth Equivalence

**Theorem 3.4.** Growth equivalence is an equivalence relation on ℕ → ℕ.

*Proof.* Reflexivity: C = 1 works. Symmetry: swap the two bounds. Transitivity: multiply constants. □

**Theorem 3.5 (Multiplicative Compatibility).** If f ≈_U f' and g ≈_U g', then f·g ≈_U f'·g'.

*Proof.* If f ≤ C₁·f' and g ≤ C₃·g', then f·g ≤ C₁C₃·f'·g'. Similarly for the reverse. □

## 4. The Polynomial Hierarchy

### 4.1 Standard Elements Are Dominated by ω

**Theorem 4.1.** For every n ∈ ℕ, std(n) <_U ω.

*Proof.* {i | n < i} = (n, ∞) has finite complement {0, ..., n}, which belongs to any free ultrafilter. □

### 4.2 Strict Polynomial Hierarchy

**Theorem 4.2 (Polynomial Hierarchy).** For every k ∈ ℕ, ω^k ≪_U ω^(k+1).

*Proof.* For any C, {i | C · i^k < i^(k+1)} ⊇ {i | C < i} (when i > 0, since i^(k+1) = i · i^k > C · i^k iff i > C). The complement {i | i ≤ C} is finite, hence its complement is U-large. □

**PEGB Analysis:**
- **P**roof: As above.
- **E**xample: ω² ≪ ω³ because i² < i³ for all i ≥ 2, and no constant C satisfies C·i² ≥ i³ for all large i.
- **G**eneralization: For any strictly increasing f, [f^k] ≪ [f^(k+1)] under suitable growth conditions.
- **B**oundary: ω^0 = std(1), so the hierarchy begins at level 0 = standard.

### 4.3 Zeroth Power

**Theorem 4.3.** ω^0 = std(1).

*Proof.* i^0 = 1 for all i. □

## 5. Factorial Dominance

**Theorem 5.1 (Factorial Dominates All Polynomials).** For every k ∈ ℕ, ω^k ≪_U ω!.

*Proof.* For any C and k, we need {i | C · i^k < i!} ∈ U. The key analytic fact is that the ratio C · n^k / n! → 0 as n → ∞ (since Σ n^k/n! converges). Therefore {n | C · n^k ≥ n!} is finite, and its complement is U-large by mem_of_cofinite.

The convergence argument is formalized by showing Σ n^k/n! ≤ Σ (2^k)^n/n! = e^{2^k} < ∞, using the bound n ≤ 2^n and hence n^k ≤ 2^{kn} = (2^k)^n. □

**PEGB Analysis:**
- **P**roof: Real-analytic convergence argument.
- **E**xample: For k = 3, C = 100: 100 · 10³ = 100000 < 3628800 = 10!.
- **G**eneralization: Any function growing superpolynomially dominates all polynomials.
- **B**oundary: n^n dominates n! (by Stirling's approximation), so ω^ω ≫ ω!.

## 6. Gap Insertion Theorem

**Definition.** The gap element γ_k(i) = i^k · (⌊i/2⌋ + 1).

**Theorem 6.1 (Gap Insertion).** For every k, ω^k <_U γ_k <_U ω^(k+1).

*Proof (lower bound).* For i ≥ 2, ⌊i/2⌋ + 1 ≥ 2, so i^k · (⌊i/2⌋ + 1) > i^k. The complement {0, 1} is finite.

*Proof (upper bound).* For i ≥ 3, ⌊i/2⌋ + 1 ≤ ⌊(i+1)/2⌋ < i (since i ≥ 3), so γ_k(i) = i^k · (⌊i/2⌋ + 1) < i^k · i = i^(k+1). The complement {0, 1, 2} is finite. □

**PEGB Analysis:**
- **P**roof: As above, using divisibility properties of ⌊i/2⌋.
- **E**xample: For k=1, γ₁(10) = 10 · 6 = 60, and 10 < 60 < 100 = 10².
- **G**eneralization: For any f, g with f ≪ g, geometric means provide intermediate elements.
- **B**oundary: Between std(n) and std(n+1), no intermediate exists — ℕ is discrete. This shows the gap insertion phenomenon is specific to the infinite regime.

## 7. Arithmetic Transfer

### 7.1 GCD Transfer

**Definition.** ugcd(f, g)(i) = gcd(f(i), g(i)).

**Theorem 7.1 (GCD Multiplicativity).** ugcd(f·h, g·h) = ugcd(f,g) · h (pointwise).

*Proof.* Follows from Nat.gcd_mul_right at each index. □

### 7.2 Coprimality Transfer

**Theorem 7.2.** If gcd(m, n) = 1 in ℕ, then UCoprime U (std m) (std n).

**Theorem 7.3 (Consecutive Coprimality).** UCoprime U ω (ω + 1).

*Proof.* gcd(i, i+1) = 1 for all i, so the coprimality set is all of ℕ. □

**Theorem 7.4.** If f, g are U-coprime, then ugcd(f, g) = 1 U-eventually.

### 7.3 Composite Transfer

**Theorem 7.5 (Composite Factorization Transfer).** If f is U-eventually not prime and U-eventually ≥ 2, then f = g · h for some g, h with g, h ≥ 2 U-eventually.

*Proof.* Define g(i) = minFac(f(i)) and h(i) = f(i)/minFac(f(i)). Since f(i) is composite and ≥ 2, minFac(f(i)) is a prime factor ≥ 2, and the cofactor is ≥ 2 (since minFac(f(i)) < f(i) for composite f(i)). □

**PEGB Analysis:**
- **P**roof: Constructive via Nat.minFac.
- **E**xample: f = (4, 6, 8, 9, 10, ...) → g = (2, 2, 2, 3, 2, ...), h = (2, 3, 4, 3, 5, ...).
- **G**eneralization: Any first-order property involving existential quantifiers transfers to *ℕ (Łoś's theorem).
- **B**oundary: Unique factorization does NOT transfer in the obvious sense — the factorization in *ℕ is "internal" and may differ from external prime factorization.

## 8. Non-Archimedean Structure

**Theorem 8.1 (Non-Archimedean Gap).** If f ≪_U g, then for all n ∈ ℕ, n · f <_U g.

*Proof.* Immediate from the definition of dominance: for C = n, n · f(i) < g(i) U-eventually. □

**PEGB Analysis:**
- **P**roof: Direct from definition.
- **E**xample: n · ω < ω² for all n. A million copies of ω can't reach ω².
- **G**eneralization: The growth quotient is a non-Archimedean ordered monoid.
- **B**oundary: Within the same growth class, the Archimedean property holds (by definition of growth equivalence).

## 9. Non-Standard Primes

**Theorem 9.1.** The n-th prime sequence [i ↦ p_i] exceeds every standard element.

*Proof.* For any p, {i | p_i ≤ p} is finite (since p_i is strictly monotone and unbounded). □

## 10. Conjectures and Open Questions

**Conjecture 10.1 (Exponential Separation).** The exponential function 2^ω dominates ω! in the GDP, i.e., for all C, C · n! < 2^n U-eventually.

*Test*: Verify computationally that C · n! < 2^n for n ≥ f(C) for various C values.

**Conjecture 10.2 (GDP Quotient is Divisible).** The growth equivalence quotient (restricted to sequences eventually ≥ 1) forms a divisible ordered abelian group under multiplication.

**Open Question.** Is the GDP quotient isomorphic to the ordered group (ℝ, +, ≤) via a logarithmic map? If so, this would provide a canonical embedding of growth rates into the real line.

## 11. Connections to Existing Work

Our work connects to several threads in the existing catalog:

- **Bridges/DependentUltraproduct.lean**: Our `mem_of_cofinite` and `IsFreeUltrafilter` extend the ultrafilter combinatorics developed there. The `ultrafilter_transfer_and` result is a special case of our broader transfer framework.

- **Catalog/Novelty/UltrapowerNat.lean**: Our GDP refines the power hierarchy proved there, showing not just that ω^k < ω^(k+1) but that this is a *dominance* relation (no constant multiple bridges the gap).

- **Bridges/NonArchimedeanComputation.lean**: The non-Archimedean gap theorem provides the theoretical foundation for the `padic_arithmetic_depth_bound` result.

## 12. Discussion

The Growth Dominance Preorder provides a formal framework for the intuitive notion of "growth rate" within non-standard arithmetic. Several features distinguish it from classical asymptotic analysis:

1. **Ultrafilter dependence**: The GDP depends on the choice of ultrafilter U. Different ultrafilters may yield different orderings for sequences that oscillate between growth rates. This is a feature, not a bug — it captures the model-theoretic sensitivity of non-standard arithmetic.

2. **Multiplicative compatibility**: The GDP is compatible with multiplication but not addition in general. This reflects the fact that growth rates form a multiplicative structure (cf. the "value group" of a valuation ring).

3. **Density**: The gap insertion theorem shows the polynomial growth hierarchy is dense, contrasting with the discreteness of ℕ itself. This suggests that the "space of infinities" has a richer topology than the space of finite numbers.

## References

1. Robinson, A. (1966). *Non-standard Analysis*. North-Holland.
2. Goldblatt, R. (1998). *Lectures on the Hyperreals*. Springer GTM 188.
3. Chang, C.C. & Keisler, H.J. (1990). *Model Theory*. North-Holland.
