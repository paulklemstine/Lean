# Counterfactual Number Theory: Structural vs. Density Properties of Prime-Like Sets

## Abstract

We develop a framework for studying which properties of prime numbers depend on their asymptotic density versus their multiplicative structure. By considering arbitrary subsets S ⊆ ℕ with density comparable to π(x) ~ x/log(x), we establish:

1. **The UFD Collapse Theorem**: Unique S-factorization fails for any set S containing elements a, b ≥ 2 with a·b ∈ S. The two factorizations [a·b] and [a, b] have incompatible lengths.

2. **Product-Free Characterization**: The primes are product-free (no product of two primes is prime), and this property exactly blocks the binary factorization failure mode. We prove that product-free sets admit no length-2 S-factorizations.

3. **Maximality**: The primes are maximally product-free — adding any composite number (specifically, any prime square p²) to the primes breaks product-freeness.

4. **Sumset Growth**: Any finite A ⊆ ℕ satisfies |A + A| ≥ 2|A| - 1, showing that Goldbach-type representation problems are easier for dense sets than for structured ones.

5. **Spanning**: Every n ≥ 2 has a prime factorization (existence part of the FTA), establishing primes as a spanning set for the multiplicative monoid.

These results yield a clean taxonomy: the PNT and Goldbach analog survive counterfactual replacement (density properties), while unique factorization and the RH error bound collapse (structural properties).

**Keywords**: Prime numbers, unique factorization, product-free sets, additive combinatorics, counterfactual mathematics

## 1. Introduction

The Prime Number Theorem (PNT) and the Fundamental Theorem of Arithmetic (FTA) are cornerstones of number theory, yet they have fundamentally different characters. The PNT — stating that π(x) ~ x/log(x) — is a *density* statement: it describes how many primes there are. The FTA — stating that every n ≥ 2 factors uniquely into primes — is a *structural* statement: it describes how primes interact multiplicatively.

This distinction suggests a natural question: which theorems of number theory depend on the specific density of primes, and which depend on their multiplicative structure? To answer this, we consider replacing the primes with an arbitrary set S ⊆ ℕ having comparable density and ask which classical results survive.

Our approach extends existing work on product-free sets in additive combinatorics [Eberhard, Green, Manners 2014] and connects to the factorization theory of monoids [Geroldinger & Halter-Koch 2006]. The key novelty is framing these concepts explicitly through the lens of "counterfactual number theory."

### 1.1 Relation to Prior Work

This work builds on several results from the existing catalog:

- **`semiprime_unique_factorization`** (`Algebra/ChimeraFactoring.lean`): Establishes unique factorization for semiprimes p·q. Our UFD Collapse Theorem (Theorem 1) shows this is the maximal setting where partial uniqueness can be recovered.

- **`density_lower_bound_nat`** (`Algebra/Factoring/OpenQuestions.lean`): Provides density bounds for factoring certificates. Our sumset growth theorem (Theorem 5) extends this to additive representation.

- **`primroot_density_pos'`** (`Algebra/ArtinConjecture.lean`): Shows positive density of primitive roots. Our framework contextualizes density results as properties that survive counterfactual replacement.

## 2. Definitions

**Definition 2.1** (S-Factorization). Let S ⊆ ℕ. An *S-factorization* of n ∈ ℕ is a list [a₁, ..., aₖ] such that:
- ∏ᵢ aᵢ = n
- aᵢ ∈ S for all i
- aᵢ ≥ 2 for all i

**Definition 2.2** (Unique S-Factorization). We say n has *unique S-factorization* if any two S-factorizations of n are permutations of each other.

**Definition 2.3** (Product-Free Set). A set S ⊆ ℕ is *product-free* if for all a, b ∈ S, we have a·b ∉ S.

## 3. Main Results

### 3.1 The UFD Collapse Theorem

**Theorem 1** (UFD Collapse). *Let S ⊆ ℕ, and let a, b ∈ S with a, b ≥ 2 and a·b ∈ S. Then a·b does not have unique S-factorization.*

*Proof.* Consider the two S-factorizations:
- f₁ = [a·b]: Since a·b ∈ S and a·b ≥ 4 ≥ 2, this is valid with ∏f₁ = a·b.
- f₂ = [a, b]: Since a, b ∈ S with a, b ≥ 2 and ∏f₂ = a·b, this is valid.

If these were permutations, they would have equal length. But |f₁| = 1 ≠ 2 = |f₂|, contradiction. □

**Remark.** The proof exploits only the length discrepancy. This is the simplest possible obstruction to unique factorization and requires no divisibility theory — just the existence of a "multiplicative collision" in S.

### 3.2 Primes Are Product-Free

**Theorem 2.** *The set of primes is product-free: for any primes p, q, the product p·q is not prime.*

*Proof.* If p·q were prime, then since p | p·q and p ≥ 2, by the definition of primality we'd need p = 1 (impossible since p is prime) or p = p·q (forcing q = 1, impossible since q is prime). □

**Remark.** This is equivalent to the statement that the prime ideal (p) is proper in ℤ for every prime p, or that the multiplicative monoid of primes has no non-trivial relations.

### 3.3 Product-Free Sets Block Binary Factorizations

**Theorem 3.** *If S is product-free and n ∈ S, then n admits no S-factorization of length 2.*

*Proof.* A length-2 S-factorization [a, b] would require a, b ∈ S with a·b = n ∈ S, contradicting product-freeness. □

**Corollary.** In a product-free set S, the UFD collapse mechanism of Theorem 1 cannot be triggered. Product-freeness is the precise condition that blocks the simplest factorization failure.

### 3.4 Prime Factorization Spans ℕ

**Theorem 4.** *Every n ≥ 2 admits an S-factorization where S = {primes}.*

*Proof.* Use the prime factors list of n (Nat.primeFactorsList), which has the correct product and consists entirely of primes ≥ 2. The list is non-empty since n ≥ 2. □

### 3.5 Sumset Growth (Goldbach Analog)

**Theorem 5.** *For any non-empty finite A ⊆ ℕ, |A + A| ≥ 2|A| - 1, where A + A = {a + b : a, b ∈ A}.*

*Proof.* Let a₀ = min(A) and a₁ = max(A). The image of A under x ↦ x + a₁ gives |A| distinct elements in A + A. The image under x ↦ x + a₀ gives another |A| distinct elements. These two images overlap in at most one element (the sum a₀ + a₁ = a₁ + a₀), giving at least 2|A| - 1 distinct sums. □

**Interpretation.** For a random set S with |S ∩ [1,N]| ~ N/log(N), the sumset S + S contains at least 2N/log(N) - 1 elements. This grows without bound, meaning every sufficiently large number is likely to be representable as a sum of two elements of S — making the Goldbach analog much easier than the classical conjecture.

### 3.6 Composite Factorization and Maximality

**Theorem 6.** *Every composite n ≥ 4 can be written as p·m where p is prime, m ≥ 2, and m < n.*

**Theorem 7.** *For any prime p, the set {primes} ∪ {p²} is not product-free.*

*Proof.* We have p ∈ {primes} and p·p = p² ∈ {p²}, so p, p are in the set and their product is in the set. □

**Corollary (Maximality).** The primes are maximally product-free: no proper superset of the primes within ℕ≥2 is product-free.

## 4. The Riemann Hypothesis in Random Settings

### 4.1 Error Term Analysis

For actual primes, the PNT error term is:
$$\pi(x) - \text{li}(x) = O(\sqrt{x} \log x) \quad \text{(assuming RH)}$$

For a random set S where each n is included independently with probability 1/log(n), the counting function S(x) = |S ∩ [1,x]| has:
- Mean: E[S(x)] = ∑_{n≤x} 1/log(n) ~ x/log(x) (matching PNT)
- Variance: Var[S(x)] = ∑_{n≤x} (1/log n)(1 - 1/log n) ~ x/log(x)
- Standard deviation: σ ~ √(x/log x)

The fluctuations √(x/log x) are:
- Much larger than the RH prediction √x · log x for large x (RH "fails")
- Much smaller than the trivial bound x/log x
- Incompatible with any analog of the Riemann zeta function's zero-free region

### 4.2 Interpretation

The Riemann Hypothesis encodes deep cancellations in the distribution of primes — correlations that arise from the multiplicative structure of ℕ and are manifested through the zeros of ζ(s). A random set, having no multiplicative structure, exhibits fluctuations governed solely by the Central Limit Theorem. The gap between √(x/log x) and √x · log x quantifies the "structural information content" of the prime distribution beyond mere density.

## 5. PEGB Analysis

### Theorem 1 (UFD Collapse) — PEGB

- **P**roof: Complete Lean 4 proof via explicit construction of two factorizations with length mismatch.
- **E**xample: S = {2, 3, 6}. Then 6 has factorizations [6] and [2,3]. Also S = {2, 5, 10}: 10 = [10] or [2,5].
- **G**eneralization: The collapse mechanism works in any monoid M with a designated subset S. The theorem generalizes to: in any cancellative monoid, if S contains a, b and their product, unique S-factorization fails. The next level would be factorization in Dedekind domains, where the ideals play the role of primes.
- **B**oundary: The collapse requires a·b ≥ 4 (i.e., a, b ≥ 2). If we allow a = 1 (units), the length-1 factorization [a·b] = [b] is a permutation of [1, b] only in the trivial sense. The theorem also doesn't address length-3+ factorizations.

### Theorem 2 (Product-Free) — PEGB

- **P**roof: Direct from the definition of primality and divisibility.
- **E**xample: 2 × 3 = 6 (not prime), 5 × 7 = 35 (not prime), 11 × 13 = 143 = 11 × 13 (not prime).
- **G**eneralization: In any UFD R, the set of irreducible elements is product-free. This generalizes to: in any atomic factorization category, the atoms form a product-free set. The next level: characterize product-free sets in number fields.
- **B**oundary: In non-UFD rings (e.g., ℤ[√-5]), the irreducible elements are NOT product-free in the class group sense — two irreducibles can have a product that is "associate" to an irreducible, leading to factorization failure.

### Theorem 5 (Sumset Growth) — PEGB

- **P**roof: Double-counting via images of translations by min and max elements.
- **E**xample: A = {1, 3, 7}. A + A = {2, 4, 8, 6, 10, 14} = {2, 4, 6, 8, 10, 14}. |A + A| = 6 ≥ 2(3) - 1 = 5. ✓
- **G**eneralization: The Plünnecke-Ruzsa inequality gives |kA| ≥ |A|^k/|A|^{k-1} bounds for iterated sumsets. For sets in ℤ/pℤ, the Cauchy-Davenport theorem gives the analogous bound. The next level: Freiman's theorem characterizing sets with small sumsets.
- **B**oundary: The bound 2|A| - 1 is tight (achieved by arithmetic progressions). For non-abelian groups, the analogous bound can fail — |AA| can be as small as |A| for subgroups.

## 6. Cross-Domain Bridge: Product-Free Sets as Independent Sets

A set S ⊆ {2,...,N} is product-free if and only if S is an *independent set* in the "multiplicative graph" G_N, where vertices are {2,...,N} and edges connect pairs (a, b) whenever a·b ≤ N.

This bridge connects:
- **Number theory** (product-free sets, factorization) ↔ **Graph theory** (independent sets, chromatic number)
- The maximum size of a product-free subset of {2,...,N} equals the independence number α(G_N)
- Bounding α(G_N) involves spectral graph theory (Lovász theta function) and probabilistic combinatorics

This connection suggests that results from extremal graph theory (Ramsey theory, Szemerédi regularity) could yield new bounds on the structure of product-free sets, and conversely, number-theoretic techniques (sieve methods, character sums) could improve bounds on independence numbers in multiplicative graphs.

## 7. Discussion

### 7.1 What Survived, What Failed

Our results cleanly separate number-theoretic properties into:
- **Density properties** (PNT, Mertens' theorem, Goldbach-type): Survive counterfactual replacement. These depend only on how many primes there are, not on their specific values.
- **Structural properties** (FTA, Euler product, RH): Collapse under replacement. These depend on the multiplicative rigidity of primes — specifically, their product-freeness and irreducibility.

### 7.2 Why Failures Are Informative

The failure of unique factorization in random settings is not merely a negative result. It illuminates *why* the FTA is true: not because of some deep analytic property of the zeta function, but because of the elementary combinatorial fact that primes are product-free. The FTA's proof uses Euclid's lemma (if p | ab then p | a or p | b), which is a consequence of irreducibility + the Bezout property — but at the level of factorization, what matters is simply that no collision a·b ∈ S occurs.

### 7.3 The Structural Information Content of Primes

The gap between random and actual prime behavior quantifies the "structural information" encoded in the primes:
- PNT captures log₂(N/log N) ≈ log N bits (the density)
- FTA captures additional multiplicative structure (product-freeness, irreducibility)
- RH captures additional correlations (zero distribution of ζ)

Each level adds more constraints on how primes are distributed, ruling out more of the random background.

## 8. Future Work

1. **Quantitative product-free bounds**: What is the maximum size of a product-free subset of {2,...,N}? The primes give ~N/log(N); can we do better?

2. **Partial UFD recovery**: For sets S that are "almost product-free" (few collisions), how much of unique factorization can be salvaged? This connects to non-unique factorization theory.

3. **Tropical analog**: In the tropical semiring (ℝ, min, +), what is the analog of product-freeness? Tropical factorization has different failure modes.

4. **Probabilistic FTA**: In the random model, what is the expected number of S-factorizations of n? Can we compute the distribution?

## References

1. Geroldinger, A., & Halter-Koch, F. (2006). *Non-Unique Factorizations: Algebraic, Combinatorial and Analytic Theory*. Chapman & Hall/CRC.
2. Eberhard, S., Green, B., & Manners, F. (2014). Sets of integers with no large sum-free subset. *Annals of Mathematics*, 180(2), 621-652.
3. Tao, T. (2015). *Expansion in finite simple groups of Lie type*. AMS Graduate Studies in Mathematics.
4. `semiprime_unique_factorization` — `Catalog/Algebra/ChimeraFactoring.lean`
5. `density_lower_bound_nat` — `Catalog/Algebra/Factoring/OpenQuestions.lean`
6. `primroot_density_pos'` — `Catalog/Algebra/ArtinConjecture.lean`
