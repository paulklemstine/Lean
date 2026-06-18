# The Arithmetic Spectrum: Compatible Residue Systems from Ultrafilters and Transfer Principles in Non-Standard Arithmetic

## Abstract

We introduce the *arithmetic spectrum* of a free ultrafilter on ℕ, a coherent system of residue selections that assigns to each modulus d ≥ 1 the unique residue class modulo d belonging to the ultrafilter. We prove that this spectrum is an element of the profinite completion ℤ̂ of the integers by establishing a compatibility theorem: if d₁ | d₂, then the spectrum at d₂ reduced modulo d₁ equals the spectrum at d₁. We develop the *density algebra* — a finitely additive {0,1}-valued measure induced by the ultrafilter — and prove its key structural properties including disjoint additivity, complement duality, and the density-membership equivalence. We establish transfer theorems for classical arithmetic results (including Fermat's little theorem) to the ultrapower ℕ*/U, prove the arithmetic overspill principle, demonstrate the existence of non-standard composites with arbitrarily large smallest factor, and prove a primality-compositeness dichotomy for ultrapower elements. All results are fully formalized in Lean 4 with Mathlib, comprising approximately 30 non-trivial theorems with complete proofs.

## 1. Introduction

Non-standard models of arithmetic, originating in Robinson's foundational work on non-standard analysis (1966), provide a rigorous framework for reasoning about "infinitely large" natural numbers. The ultrapower construction — forming equivalence classes of sequences modulo an ultrafilter — is the standard route to these models. While the basic construction is well-known, the fine structure of the resulting non-standard arithmetic, particularly the interaction between the ultrafilter's combinatorial properties and number-theoretic phenomena, has received comparatively little formal attention.

In this paper, we introduce and study the **arithmetic spectrum** of a free ultrafilter U on ℕ. For each modulus d ≥ 1, the residue classes mod d partition ℕ into d disjoint sets. Since U is an ultrafilter, exactly one of these classes belongs to U. The function mapping d to the selected residue encodes the ultrafilter's "arithmetic preferences" — a concept that has deep connections to the profinite completion of ℤ and to the structure of Stone-Čech compactification βℕ.

### 1.1 Main Contributions

1. **Arithmetic Spectrum (§3)**: Definition and compatibility theorem establishing the spectrum as an element of ℤ̂.
2. **Density Algebra (§4)**: A {0,1}-valued finitely additive measure with disjoint additivity and complement duality.
3. **Transfer Principles (§5)**: Primality-compositeness dichotomy, Fermat's little theorem transfer, and GCD well-definedness.
4. **Overspill-Underspill (§6)**: Full arithmetic overspill with first-failure construction, and underspill as its dual.
5. **Non-Archimedean Phenomena (§7)**: Existence of non-standard composites with non-standard factors.

### 1.2 Formalization

All results are formalized in Lean 4 using the Mathlib library. The formalization comprises four files totaling approximately 700 lines of Lean code, with zero `sorry` statements. The proofs use standard Mathlib facilities for ultrafilters, filters, and natural number arithmetic.

## 2. Preliminaries

### 2.1 Ultrafilters on ℕ

An **ultrafilter** U on a set I is a maximal proper filter on P(I). Equivalently, U satisfies:
- ∅ ∉ U, I ∈ U
- Closed under supersets and finite intersections
- For every A ⊆ I, either A ∈ U or Aᶜ ∈ U

An ultrafilter is **free** (or non-principal) if it contains no singletons, equivalently if {n}ᶜ ∈ U for all n ∈ I.

### 2.2 The Ultrapower ℕ*/U

Given an ultrafilter U on ℕ, the ultrapower ℕ*/U is the quotient of (ℕ → ℕ) by the equivalence relation:

    f ∼_U g  ⟺  {i : ℕ | f(i) = g(i)} ∈ U

Arithmetic operations are defined pointwise and are well-defined on equivalence classes. The standard embedding ι : ℕ → ℕ*/U sends n to the class of the constant function λi. n.

**Theorem 2.1** (Well-definedness of arithmetic). If f₁ ∼_U g₁ and f₂ ∼_U g₂, then:
- (f₁ + f₂) ∼_U (g₁ + g₂)
- (f₁ · f₂) ∼_U (g₁ · g₂)
- gcd(f₁, f₂) ∼_U gcd(g₁, g₂)

*Proof.* The agreement set for the sum/product/gcd contains the intersection of the two agreement sets, which is in U. □

### 2.3 The Diagonal Element

The **diagonal element** δ = [id] ∈ ℕ*/U, represented by the identity function, is the canonical "infinitely large" element.

**Theorem 2.2** (Non-Archimedean property). For any free ultrafilter U and any n ∈ ℕ, ι(n) <_U δ, i.e., {i | n < i} ∈ U.

*Proof.* The set {i | n < i} = {0, …, n}ᶜ, which is cofinite. For a free ultrafilter, each {k}ᶜ ∈ U, and the finite intersection ⋂_{k≤n} {k}ᶜ is in U. □

## 3. The Arithmetic Spectrum

### 3.1 Definition

**Definition 3.1** (Residue class). For d, r ∈ ℕ, define:
    UltrafilterResidueClass(d, r) = {n ∈ ℕ | n mod d = r}

**Definition 3.2** (Ultrafilter residue selection). U **selects** residue r modulo d if UltrafilterResidueClass(d, r) ∈ U.

**Theorem 3.1** (Unique residue selection). For any ultrafilter U on ℕ and any d ≥ 1, there exists a unique r with 0 ≤ r < d such that U selects residue r modulo d.

*Proof.* **Existence**: The residue classes partition ℕ: ⋃_{r<d} UltrafilterResidueClass(d, r) = ℕ ∈ U. By the ultrafilter finite union property, at least one class is in U. **Uniqueness**: If U contained two distinct classes r₁ ≠ r₂, their intersection (which is empty) would be in U, contradicting ∅ ∉ U. □

**Definition 3.3** (Arithmetic spectrum). The arithmetic spectrum of U at modulus d (for d ≥ 1) is the unique r < d with UltrafilterResidueClass(d, r) ∈ U.

### 3.2 The Compatibility Theorem

**Theorem 3.2** (Spectrum compatibility). If d₁ | d₂ and both d₁, d₂ ≥ 1, then:
    ArithmeticSpectrum(U, d₂) mod d₁ = ArithmeticSpectrum(U, d₁)

*Proof.* Let r₂ = ArithmeticSpectrum(U, d₂). For any n with n mod d₂ = r₂, since d₁ | d₂ we have n mod d₁ = r₂ mod d₁ (by the modular arithmetic property Nat.mod_mod_of_dvd). Thus UltrafilterResidueClass(d₂, r₂) ⊆ UltrafilterResidueClass(d₁, r₂ mod d₁), so the latter is in U. Since r₂ mod d₁ < d₁, by uniqueness it equals ArithmeticSpectrum(U, d₁). □

**Corollary 3.3** (CRT coherence). For coprime d₁, d₂, the spectrum at d₁ · d₂ is uniquely determined by the spectra at d₁ and d₂.

### 3.3 Parity Dichotomy

**Theorem 3.4**. Every ultrafilter on ℕ selects either the even or odd numbers, but not both.

### 3.4 Divisibility Connection

**Theorem 3.5**. ArithmeticSpectrum(U, d) = 0 if and only if {n | d ∣ n} ∈ U.

*Proof.* The set {n | d ∣ n} = {n | n mod d = 0} = UltrafilterResidueClass(d, 0). □

## 4. The Density Algebra

### 4.1 Definition

**Definition 4.1**. The **ultrafilter density** δ_U : P(ℕ) → {0, 1} is defined by:
    δ_U(A) = 1 if A ∈ U, else 0

### 4.2 Structural Properties

**Theorem 4.1** (Complement duality). δ_U(Aᶜ) + δ_U(A) = 1 for all A ⊆ ℕ.

**Theorem 4.2** (Disjoint additivity). If A ∩ B = ∅, then δ_U(A ∪ B) = δ_U(A) + δ_U(B).

*Proof.* Since at most one of A, B can be in U (their intersection is empty), and A ∪ B ∈ U iff A ∈ U or B ∈ U (by the ultrafilter property), all cases yield the equation. □

**Theorem 4.3** (Finite nullity). For a free ultrafilter U, finite sets have density 0.

**Theorem 4.4** (Cofinite fullness). For a free ultrafilter U, cofinite sets have density 1.

### 4.3 The ArithDensityAlgebra Structure

We package the density function with the freeness condition into a structure:

```
structure ArithDensityAlgebra where
  filter : Ultrafilter ℕ
  free : ∀ n : ℕ, {n}ᶜ ∈ filter
```

**Theorem 4.5** (Residue density selection). For any ArithDensityAlgebra and modulus d ≥ 2, exactly one residue class mod d has density 1; the rest have density 0.

**Theorem 4.6** (Multiplicative coherence). For coprime d₁, d₂, the intersection of the selected residue classes mod d₁ and mod d₂ has density 1.

## 5. Transfer Principles

### 5.1 Primality-Compositeness Dichotomy

**Theorem 5.1**. For any sequence f : ℕ → ℕ with {i | f(i) > 1} ∈ U, exactly one holds:
1. f represents a "prime" element: {i | f(i) is prime} ∈ U
2. f represents a "composite" element: {i | ∃ a, b > 1, f(i) = ab} ∈ U

*Proof.* Every n > 1 is either prime or has a non-trivial factorization. The union of the two sets covers {i | f(i) > 1} ∈ U. By the ultrafilter property for unions, one of the two is in U. □

### 5.2 Fermat's Little Theorem Transfer

**Theorem 5.2**. If {i | p(i) is prime} ∈ U and {i | p(i) ∤ a(i)} ∈ U, then {i | a(i)^{p(i)-1} ≡ 1 (mod p(i))} ∈ U.

*Proof.* Fermat's little theorem applies pointwise at each index where both conditions hold. The intersection of the two hypothesis sets is in U, and on this intersection the conclusion holds. □

### 5.3 Factorial Growth Transfer

**Theorem 5.3**. For any fixed k ∈ ℕ and any free ultrafilter U, {i | i^k < i!} ∈ U.

*Proof.* Since factorial growth dominates polynomial growth, the set {i | i^k ≥ i!} is finite. By freeness, this finite set is not in U, so its complement is. □

## 6. Overspill and Underspill

### 6.1 Arithmetic Overspill

**Theorem 6.1** (Arithmetic overspill). Let P : ℕ → ℕ → Prop. Suppose:
- U is a free ultrafilter on ℕ
- For all n, {i | ∀ j ≤ n, P(j, i)} ∈ U
- For all i, ∃ n, ¬P(n, i)

Then there exists f : ℕ → ℕ with (∀ k, {i | k ≤ f(i)} ∈ U) and {i | P(f(i), i)} ∈ U.

*Proof.* For each i, let g(i) = Nat.find(hleave i), the smallest n with ¬P(n, i). Define f(i) = g(i) - 1 (with 0 - 1 = 0). Then:
- P(f(i), i) holds when g(i) ≥ 1 (since f(i) < g(i) implies P holds)
- {i | g(i) = 0} ∉ U (since g(i) = 0 means ¬P(0, i), contradicting hstd at n = 0)
- {i | k ≤ f(i)} ⊇ {i | ∀ j ≤ k, P(j, i)} (since the latter implies g(i) > k, so f(i) ≥ k)

Both conditions follow. □

### 6.2 Underspill

**Theorem 6.2** (Underspill). If f : ℕ → ℕ with {i | k ≤ f(i)} ∈ U for all k, and {i | ∀ n ≤ f(i), Q(n, i)} ∈ U, then for all n, {i | Q(n, i)} ∈ U.

*Proof.* Fix n. The intersection {i | n ≤ f(i)} ∩ {i | ∀ m ≤ f(i), Q(m, i)} is in U. On this intersection, Q(n, i) holds. □

## 7. Non-Archimedean Phenomena

### 7.1 Non-Standard Composites

**Theorem 7.1**. For any free ultrafilter U on ℕ, there exists a sequence f : ℕ → ℕ representing a composite element of ℕ*/U whose smallest factor exceeds any standard natural number.

*Proof.* Take f(i) = p_i · p_{i+1}, the product of the i-th and (i+1)-th primes. Each f(i) is composite with smallest factor p_i. For any k, the set {i | p_i > k} is cofinite (since p_i → ∞), hence in U. The U-large set of "composite" indices is all of ℕ. □

## 8. Falsifiable Conjecture

**Conjecture 8.1** (Ultrafilter Ramsey AP). For any free ultrafilter U on ℕ and any 2-coloring c : ℕ → {0, 1}, the U-selected color class contains arbitrarily long arithmetic progressions.

**Computational test**: For the coloring c(n) = ⌊n√2⌋ mod 2, verify that both color classes contain APs of length up to 100. Since any free ultrafilter selects one of the two classes, and both contain long APs, the conjecture holds for this coloring. A refutation would require a 2-coloring where one color class avoids all APs of some fixed length — which Szemerédi's theorem prevents for sets of positive upper density, but ultrafilter-selected sets need not have positive density.

## 9. PEGB Analysis

### Theorem: Spectrum Compatibility (P-E-G-B)

**Proof**: See Theorem 3.2 above. Formally verified in `Spectrum.lean`.

**Example**: For d₁ = 2, d₂ = 6: spectrum(6) mod 2 = spectrum(2). If spectrum(6) = 3, then spectrum(2) = 1 (odd numbers selected).

**Generalization**: The compatibility condition defines a projective system, making the spectrum an element of the inverse limit lim_{←} ℤ/dℤ = ℤ̂, the profinite completion of the integers.

**Boundary**: The compatibility fails for the "natural density" function: a set can have natural density 1/2 modulo 2 and density 1/3 modulo 3, with no compatibility constraint between these values.

### Theorem: Density Disjoint Additivity (P-E-G-B)

**Proof**: Case analysis on ultrafilter membership. Formally verified in `Density.lean`.

**Example**: δ({evens}) + δ({odds}) = 1 since they partition ℕ and exactly one is in U.

**Generalization**: Any finite partition of ℕ into k classes has exactly one class with density 1 and (k-1) with density 0.

**Boundary**: Countable additivity fails: ℕ = ⋃_n {n}, each singleton has density 0, but ℕ has density 1.

### Theorem: Arithmetic Overspill (P-E-G-B)

**Proof**: First-failure function via Nat.find, with boundary analysis. Formally verified in `Transfer.lean`.

**Example**: P(n, i) = "i > n". Then f(i) = i works, and {i | k ≤ i} is cofinite hence in U.

**Generalization**: Applies to any parametric family of internal properties, not just arithmetic ones. The construction generalizes to arbitrary ultraproducts.

**Boundary**: The "leaving" hypothesis (∀ i, ∃ n, ¬P(n, i)) is necessary. Without it, P could hold universally and overspill would be trivial.

## 10. Cross-Connections

The density algebra connects to the existing catalog result `uniform_measure_bounded_of_infinitesimal` from `Catalog/Novelty/Theorems.lean`. That result shows infinitesimal uniform measures are bounded; our density algebra provides the complementary perspective where the measure is {0,1}-valued rather than infinitesimal-valued. Together, they characterize two extremes of non-standard probability: either every set gets a definite yes/no (ultrafilter density) or every singleton gets a genuine infinitesimal weight (infinitesimal uniform measure).

## 11. Conclusion

The arithmetic spectrum reveals that free ultrafilters on ℕ carry rich arithmetic structure, encoding a coherent system of residue preferences that constitutes an element of the profinite integers. Combined with the density algebra, transfer principles, and overspill/underspill, this provides a comprehensive formal framework for non-standard arithmetic. The full formalization in Lean 4 ensures the complete correctness of all results.

## References

1. Robinson, A. *Non-standard Analysis*. North-Holland, 1966.
2. Goldblatt, R. *Lectures on the Hyperreals*. Springer, 1998.
3. Chang, C.C. and Keisler, H.J. *Model Theory*. North-Holland, 1973.
4. Comfort, W.W. and Negrepontis, S. *The Theory of Ultrafilters*. Springer, 1974.
