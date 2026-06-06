# Overspill Semirings: An Algebraic Axiomatization of Non-Standard Arithmetic

## Abstract

We introduce **Overspill Semirings**, a novel algebraic structure axiomatizing the key properties of non-standard models of arithmetic. An Overspill Semiring is a linearly ordered commutative semiring equipped with a standard/non-standard partition, a family of internal predicates, and the overspill axiom: any internal set containing all standard elements must contain some non-standard element. We prove that every Overspill Semiring is non-Archimedean (Theorem 1), establish the dual underspill principle (Theorem 2), and derive the existence of infinitely composite elements in concrete ultrapower models (Theorem 5). We further prove transfer theorems for primality (Theorem 6), Bezout's identity (Theorem 8), and the GCD operation (Theorem 9), and establish the existence of infinite primes in ultrapowers (Theorem 10). All results are formalized in Lean 4 with complete machine-checked proofs.

## 1. Introduction

Non-standard models of arithmetic, introduced by Skolem (1934) and developed extensively by Robinson (1966), provide a rich framework for studying arithmetic properties that survive extension beyond the standard naturals. The classical construction via ultraproducts (Łoś, 1955) yields models satisfying all first-order properties of ℕ while containing elements exceeding every standard natural.

Despite their fundamental importance, the algebraic essence of non-standard models has not been cleanly axiomatized as an algebraic structure. The existing approaches rely either on:
- Full first-order logic and the compactness theorem
- Explicit ultrapower constructions
- Nelson's Internal Set Theory (IST), which modifies the foundations of set theory

We propose an intermediate approach: an **algebraic axiom system** that captures the essential structure without requiring logical machinery or explicit constructions. The Overspill Semiring class identifies the minimal algebraic data — a standard predicate, an internal predicate family, and the overspill axiom — from which the core phenomena of non-standard arithmetic follow.

## 2. Definitions

### Definition 2.1 (Overspill Semiring)

An **Overspill Semiring** is a tuple (R, ≤, +, ·, 0, 1, IsStd, IsInternal) where:

- (R, ≤, +, ·, 0, 1) is a linearly ordered commutative semiring satisfying the strict ordered ring axioms
- IsStd : R → Prop is a predicate satisfying:
  - IsStd(0), IsStd(1)
  - IsStd(a) ∧ IsStd(b) → IsStd(a + b)
  - IsStd(a) ∧ IsStd(b) → IsStd(a · b)
  - ∃ x, ¬IsStd(x) (non-standard elements exist)
  - IsStd(x) ∧ ¬IsStd(y) → x ≤ y (standard elements form an initial segment)
- IsInternal : 𝒫(R) → Prop is a predicate on subsets satisfying:
  - ∀ a, IsInternal({x | a ≤ x}) (upper rays are internal)
  - IsInternal(S) ∧ IsInternal(T) → IsInternal(S ∩ T)
  - IsInternal(S) → IsInternal(Sᶜ)
  - ¬IsInternal({x | IsStd(x)}) (the standard predicate is external)
- **Overspill Axiom**: If IsInternal(S) and {x | IsStd(x)} ⊆ S, then ∃ y ∈ S, ¬IsStd(y)

### Definition 2.2 (Infinite Element)

An element x ∈ R is **infinite** if ∀ n : ℕ, n̄ < x, where n̄ denotes the image of n under the canonical semiring homomorphism ℕ → R.

### Definition 2.3 (UltraNat)

For an ultrafilter U on ℕ, the **ultrapower** UltraNat(U) is the quotient of (ℕ → ℕ) by the equivalence relation f ∼_U g ⟺ {i | f(i) = g(i)} ∈ U.

### Definition 2.4 (Free Ultrafilter)

An ultrafilter U on ℕ is **free** (non-principal) if {n}ᶜ ∈ U for every n ∈ ℕ.

## 3. Main Results

### 3.1 Structural Theorems for Overspill Semirings

**Theorem 1 (Non-Archimedean).** Every Overspill Semiring is non-Archimedean.

*Proof sketch.* Take a non-standard element x. By `nonstd_is_infinite`, x > n̄ for all n : ℕ. The Archimedean property requires ∃ n, x ≤ n · 1 = n̄, contradicting x > n̄. □

**Theorem 2 (Underspill).** If S is internal and contains all non-standard elements, then S contains some standard element.

*Proof sketch.* By contraposition. If no standard element is in S, then all standard elements are in Sᶜ. Since Sᶜ is internal (closure under complement), overspill gives a non-standard y ∈ Sᶜ, contradicting S containing all non-standard elements. □

**Theorem 3 (Standard Naturals).** For every n : ℕ, the image n̄ is standard.

*Proof.* Induction: 0̄ = 0 is standard by axiom; (n+1)̄ = n̄ + 1 is standard by closure under addition. □

### 3.2 Ultrafilter Model Properties

**Theorem 4 (Free Ultrafilter Cofinality).** For a free ultrafilter U, {i | n < i} ∈ U for every n : ℕ.

*Proof sketch.* {i | i ≤ n} is finite. If it were in U, some singleton {k} would be in U by the finite union property, contradicting freeness. Hence {i | i ≤ n} ∉ U, so its complement {i | n < i} ∈ U. □

**Theorem 5 (Infinitely Composite Elements).** For a free ultrafilter U, the element [i ↦ i!] ∈ UltraNat(U) is divisible by every standard k > 0.

*Proof.* For k > 0, {i | k ∣ i!} ⊇ {i | k ≤ i} which is cofinite, hence in U. □

**Theorem 6 (Primality Transfer).** If [f] = [a] · [b] in UltraNat(U) and f(i) is prime U-a.e., then a(i) = 1 U-a.e. or b(i) = 1 U-a.e.

*Proof sketch.* On U-many indices, f(i) is prime and f(i) = a(i) · b(i). By the prime factorization property, a(i) = 1 or b(i) = 1 for each such i. The ultrafilter prime property separates these into U-large classes. □

**Theorem 7 (Zero-Product Transfer).** If f(i) · g(i) = 0 U-a.e., then f(i) = 0 U-a.e. or g(i) = 0 U-a.e.

*Proof.* Immediate from ℕ having no zero divisors and the ultrafilter union property. □

### 3.3 Transfer and GCD Results

**Theorem 8 (Bezout Transfer).** For any f, g : ℕ → ℕ, there exist ℤ-valued coefficient functions a, b such that gcd(f(i), g(i)) = f(i) · a(i) + g(i) · b(i) for all i.

*Proof.* Pointwise application of the extended Euclidean algorithm. □

**Theorem 9 (GCD Well-Definedness).** The GCD operation on UltraNat is well-defined: if f₁ ∼_U f₂ and g₁ ∼_U g₂, then gcd ∘ (f₁, g₁) ∼_U gcd ∘ (f₂, g₂).

*Proof.* On the intersection of {i | f₁(i) = f₂(i)} and {i | g₁(i) = g₂(i)}, both in U, gcd values agree. □

**Theorem 10 (Infinite Primes).** For a free ultrafilter U, there exists p : ℕ → ℕ such that p(i) is prime for all i and p exceeds every constant U-a.e.

*Proof.* Let p(i) be the (i+1)-th prime. Then p(i) is always prime. Since primes grow without bound, for each n, {i | p(i) > n} is cofinite, hence in U. □

### 3.4 Additional Results

**Theorem 11 (Parity Transfer).** Every element of UltraNat has definite internal parity: either f(i) is even U-a.e. or odd U-a.e.

**Theorem 12 (Ultrafilter Coloring).** For any n-coloring of ℕ, exactly one color class belongs to U.

**Theorem 13 (Bounded Quantifier Transfer).** If P(i, k) holds U-a.e. for each k < n, then ∀ k < n, P(i, k) holds U-a.e. simultaneously.

**Theorem 14 (Finite Compactness).** If each axiom in a finite list is satisfied U-a.e., all are simultaneously satisfied U-a.e.

## 4. PEGB Analysis

### Theorem 1: Non-Archimedean

- **P**roof: Complete formal proof in Lean 4 using nsmul_eq_mul and Archimedean.arch
- **E**xample: In UltraNat, [id] > [const n] for all n (Theorem 4)
- **G**eneralization: Holds for ANY Overspill Semiring, not just UltraNat
- **B**oundary: Standard ℕ IS Archimedean — the overspill axiom is the minimal additional structure forcing non-Archimedean behavior

### Theorem 2: Underspill

- **P**roof: Contrapositive argument using internal_compl and overspill
- **E**xample: {x | x > 100} contains all non-standard elements; underspill gives a standard element > 100 (namely 101)
- **G**eneralization: Works for any Overspill Semiring, independent of model
- **B**oundary: Fails for external sets: {x | ¬IsStd(x)} contains all non-standard elements but no standard ones — this is exactly the "external" case excluded by the axioms

### Theorem 6: Primality Transfer

- **P**roof: Uses Nat.Prime.eq_one_or_self_of_dvd and ultrafilter union property
- **E**xample: [i ↦ p_{i+1}] is an infinite prime in UltraNat
- **G**eneralization: Any first-order property of ℕ transfers — this is a special case of Łoś's theorem
- **B**oundary: Second-order properties do NOT transfer: "every non-empty subset has a least element" (well-ordering) fails in non-standard models

### Theorem 5: Infinitely Composite Elements

- **P**roof: Factorial divisibility + cofinite sets in free ultrafilters
- **E**xample: [i ↦ i!] is divisible by 1, 2, 3, 4, 5, ... simultaneously
- **G**eneralization: [i ↦ lcm(1, 2, ..., i)] gives a "minimal" infinitely composite element
- **B**oundary: No standard natural number can be divisible by all positive integers — this is a genuinely non-standard phenomenon

### Theorem 10: Infinite Primes

- **P**roof: nth-prime sequence + cofinite argument
- **E**xample: [i ↦ p_{i+1}] where pₖ is the k-th prime
- **G**eneralization: For any infinite set S ⊆ ℕ with S decidable, there exists an UltraNat element in the "internal closure" of S that exceeds all standard elements
- **B**oundary: Not every infinite element is prime — [i ↦ i!] is infinite but composite (even, in fact)

## 5. Falsifiable Conjecture

**Conjecture (Overspill Semiring Representation).** Every Overspill Semiring R with countable standard part admits an embedding into some UltraNat(U) as an ordered sub-semiring preserving the standard predicate.

**Computational Test:** For finite Overspill-Semiring-like structures (ordered semirings with a designated "standard" initial segment of size n and an "overspill element" ω > n), check whether they embed into ℕ^{n+1}/U for some ultrafilter U on {0,...,n}. Test for n = 5, 10, 20, 50.

**Status:** Open. A positive resolution would mean UltraNat is the "universal" Overspill Semiring. A negative resolution would show the axioms capture strictly more generality than ultrapowers.

## 6. Algorithms

### 6.1 Ultrafilter Approximation Algorithm

```
Input: Predicate P : ℕ → Bool, threshold T
Output: Boolean (approximately whether P is U-large)

1. Evaluate P(i) for i = 0, ..., N-1
2. If P holds on the tail [N-T, N): return True
3. Else: return |{i | P(i)}| > N/2
```

### 6.2 Transfer Verification Algorithm

```
Input: Property P, sequences f, g
Output: Whether P transfers through (f,g)

1. For i = 0, ..., N-1:
     Check P(f(i), g(i))
2. Return: density > threshold
```

## 7. Cross-Domain Connections

The Overspill Semiring connects to several existing results in the catalog:

- **DependentUltraproduct.lean** (`ultrafilter_transfer_and`): Our transfer principles extend the boolean transfer to arithmetic properties (divisibility, primality, GCD)
- **NonArchimedeanComputation.lean** (`padic_arithmetic_depth_bound`): The non-Archimedean property of Overspill Semirings parallels the non-Archimedean structure of p-adic fields, suggesting a unified framework
- **CollatzUndecidability.lean** (`conjecture_iff_all_bounded`): The bounded quantifier transfer theorem provides tools for analyzing statements of the form "∀ n, P(n)" in non-standard settings

## 8. Future Work

1. **Representation Theorem**: Characterize which Overspill Semirings arise as ultrapowers
2. **Higher-Order Transfer**: Formalize which second-order properties fail to transfer
3. **Non-Standard Induction**: Develop an induction principle for Overspill Semirings that extends beyond the standard part
4. **Tropical Non-Standard**: Investigate Overspill analogues in tropical semirings

## References

1. A. Robinson, *Non-Standard Analysis*, North-Holland, 1966.
2. J. Łoś, "Quelques remarques, théorèmes et problèmes sur les classes définissables d'algèbres," *Mathematical Interpretation of Formal Systems*, 1955.
3. E. Nelson, "Internal Set Theory: A New Approach to Nonstandard Analysis," *Bulletin of the AMS*, 1977.
4. T. Skolem, "Über die Nicht-charakterisierbarkeit der Zahlenreihe mittels endlich oder abzählbar unendlich vieler Aussagen," *Fundamenta Mathematicae*, 1934.
5. R. Goldblatt, *Lectures on the Hyperreals*, Springer, 1998.
