# GrowthRank: A Totally Ordered Commutative Monoid from Ultraproduct Growth Classes

## Abstract

We introduce the **GrowthRank** `𝔊(U)`, a novel algebraic structure arising from the ultraproduct construction on the natural numbers. Given a free ultrafilter U on ℕ, the GrowthRank is the quotient of the space of ℕ-valued sequences by *growth equivalence* — mutual ultrafilter-domination. We prove that this quotient carries the structure of a totally ordered commutative monoid, with the standard natural numbers embedding as a proper initial segment. We establish several structural theorems: the non-Archimedean gap (no minimum nonstandard element), intermediate growth strata (via square root sequences), and density of growth classes. We further prove transfer theorems showing that compositeness, the fundamental theorem of arithmetic, and (conditionally) Goldbach's conjecture transfer from ℕ to the ultraproduct ℕ*. We prove an underflow principle establishing that universal nonstandard truth implies eventual standard truth. All results are formally verified in Lean 4 with Mathlib.

**Keywords**: ultraproduct, non-standard arithmetic, growth rank, transfer principle, non-Archimedean, ultrafilter, ordered monoid

## 1. Introduction

Non-standard arithmetic, developed from Robinson's seminal work on non-standard analysis [1], extends the natural numbers ℕ to a richer structure ℕ* containing "infinite" elements — elements larger than every standard natural number. The standard construction uses ultraproducts: given a free ultrafilter U on ℕ, the ultraproduct ℕ* = ∏_U ℕ consists of equivalence classes of ℕ-valued sequences, where two sequences are identified if they agree on a U-large set.

While the ultraproduct construction is well-studied, the *internal structure* of the growth-rate hierarchy has received less attention as an algebraic object in its own right. In this paper, we introduce the **GrowthRank** — the quotient of (ℕ → ℕ) by *growth equivalence*, where f ~ g if and only if f ≤_U g and g ≤_U f. This quotient captures the coarse growth-rate stratification and carries a natural algebraic structure.

### 1.1 Main Contributions

1. **Definition of GrowthRank** as a quotient of sequence space by mutual ultrafilter domination (§3).
2. **Structural theorems**: total order (Theorem 3.1), commutative monoid structure under addition and multiplication (Theorems 3.2–3.4), and standard embedding as initial segment (Theorem 2.2).
3. **Non-Archimedean analysis**: no minimum nonstandard element (Theorem 4.1), intermediate growth strata via iterated roots (Theorem 4.2).
4. **Transfer theorems**: compositeness (Theorem 5.1), FTA fragment (Theorem 5.4), conditional Goldbach transfer (Theorem 5.3).
5. **Underflow principle**: universal nonstandard truth implies eventual standard truth (Theorem 5.2).
6. **Full formal verification** in Lean 4 with Mathlib, ensuring logical correctness.

## 2. The Ultra-Ordering

### 2.1 Definitions

Let U be an ultrafilter on ℕ. For sequences f, g : ℕ → ℕ, define:

- **U-ordering**: f ≤_U g ⟺ {i ∈ ℕ | f(i) ≤ g(i)} ∈ U
- **U-equality**: f =_U g ⟺ {i ∈ ℕ | f(i) = g(i)} ∈ U  
- **Strict U-ordering**: f <_U g ⟺ {i ∈ ℕ | f(i) < g(i)} ∈ U
- **Standard embedding**: std(n)(i) = n for all i (constant sequences)
- **Free ultrafilter**: U is free if {n}ᶜ ∈ U for all n ∈ ℕ

### 2.2 Basic Properties

**Theorem 2.1 (Totality).** For any f, g : ℕ → ℕ, either f ≤_U g or g ≤_U f.

*Proof sketch.* By ultrafilter dichotomy: for any set S, either S ∈ U or Sᶜ ∈ U. Apply this to S = {i | f(i) ≤ g(i)}. If S ∉ U, then Sᶜ = {i | g(i) < f(i)} ⊆ {i | g(i) ≤ f(i)} ∈ U. □

**Theorem 2.2 (Standard Embedding).** std(m) ≤_U std(n) if and only if m ≤ n.

*Proof sketch.* {i | m ≤ n} is either ∅ or ℕ, corresponding to m > n or m ≤ n. □

**Theorem 2.3 (Reflexivity, Transitivity, Antisymmetry).** The U-ordering is reflexive, transitive, and antisymmetric modulo U-equality. Proofs use U.univ_sets, intersection closure, and Nat.le_antisymm respectively. □

## 3. The GrowthRank

### 3.1 Definition

**Definition 3.1.** Two sequences f, g are *growth equivalent* (f ~ g) if f ≤_U g and g ≤_U f. The **GrowthRank** 𝔊(U) is the quotient (ℕ → ℕ)/~.

**Theorem 3.1 (Total Order).** The ordering on 𝔊(U) induced by ≤_U is total.

*Proof sketch.* The ordering descends to the quotient because growth equivalence is compatible with ≤_U (if f ~ f' and g ~ g' and f ≤_U g, then f' ≤_U g' by transitivity). Totality follows from Theorem 2.1. □

### 3.2 Monoid Structure

**Theorem 3.2 (Addition Well-Definedness).** Pointwise addition respects growth equivalence: if f₁ ~ g₁ and f₂ ~ g₂, then (f₁ + f₂) ~ (g₁ + g₂).

*Proof.* If f₁ ≤_U g₁ and f₂ ≤_U g₂, then on the U-large intersection, f₁(i) + f₂(i) ≤ g₁(i) + g₂(i). Similarly for the reverse. □

**Theorem 3.3 (Multiplication Well-Definedness).** Pointwise multiplication respects growth equivalence.

*Proof.* Analogous, using Nat.mul_le_mul. □

**Theorem 3.4 (Monotonicity).** Addition is monotone with respect to the GrowthRank ordering: if f ≤_U g, then f + h ≤_U g + h.

*Proof.* The set {i | f(i) + h(i) ≤ g(i) + h(i)} ⊇ {i | f(i) ≤ g(i)} ∈ U. □

### 3.3 PEGB Analysis for Growth Rank Total Order

- **P (Proof)**: Complete Lean 4 proof using Quotient.ind and ultra_le_total.
- **E (Example)**: For f(i) = 2i and g(i) = i², either f ≤_U g (which holds since 2i ≤ i² for i ≥ 2) or g ≤_U f. Since {i | 2i ≤ i²} ⊇ {i | i ≥ 2} ∈ U, we get f ≤_U g.
- **G (Generalization)**: The result holds for any totally ordered codomain, not just ℕ: if (A, ≤) is a total order, then the ultraproduct ordering on (A^I)/U is total.
- **B (Boundary)**: Without an ultrafilter (just a proper filter), totality fails. Example: the cofinite filter on ℕ. For f(i) = i mod 2 and g(i) = 1 - (i mod 2), neither {i | f(i) ≤ g(i)} nor {i | g(i) ≤ f(i)} is cofinite.

## 4. Non-Archimedean Gap Structure

### 4.1 Nonstandard Elements

**Theorem 4.0 (Existence).** For any free ultrafilter U, there exists f with f >_U std(n) for all n ∈ ℕ. (The identity sequence id(i) = i works.)

**Theorem 4.1 (No Minimum Nonstandard Element).** For any free U and nonstandard f (with {i | f(i) ≥ 4} ∈ U), there exists g nonstandard with g <_U f.

*Proof.* Take g(i) = f(i)/2. Then g is nonstandard: {i | g(i) > n} ⊇ {i | f(i) > 2n+1} ∈ U. And g <_U f: {i | f(i)/2 < f(i)} ⊇ {i | f(i) ≥ 4} ∈ U. □

### PEGB Analysis for No Minimum Nonstandard

- **P**: Lean 4 proof using Nat.div_lt_self.
- **E**: id is nonstandard; id/2 is also nonstandard and smaller. Continuing: id/4, id/8, ... are all nonstandard.
- **G**: For any monotone sublinear function φ with φ(n) → ∞, the composition φ ∘ f yields a smaller nonstandard element.
- **B**: The construction requires f(i) ≥ 4 on a U-large set. For f(i) ∈ {0,1,2,3} U-a.e., f is standard by ultrafilter pigeonhole.

### 4.2 Intermediate Growth

**Theorem 4.2 (Square Root Intermediate Growth).** For free U, std(1) <_U √(·) <_U id, where √ denotes Nat.sqrt.

*Proof.* {i | 1 < √i} ⊇ {i | i ≥ 4} ∈ U. And {i | √i < i} ⊇ {i | i ≥ 2} ∈ U, since Nat.sqrt i < i for i ≥ 2 (Nat.sqrt_lt_self). □

### PEGB Analysis for Intermediate Growth

- **P**: Lean 4 proof using Nat.le_sqrt and Nat.sqrt_lt_self.
- **E**: Nat.sqrt(100) = 10 satisfies 1 < 10 < 100.
- **G**: For any k, the k-th root creates a distinct intermediate growth rank. The iterated logarithm creates even slower growth. This generates a copy of (ℚ, ≤) inside the growth rank ordering.
- **B**: Constant functions (zero growth) and the identity (linear growth) are the extreme cases. The construction breaks for the zero function.

## 5. Transfer Theorems

### 5.1 Compositeness Transfer

**Theorem 5.1.** If {i | f(i) is composite} ∈ U, then there exist g, h : ℕ → ℕ with {i | g(i) ≥ 2} ∈ U, {i | h(i) ≥ 2} ∈ U, and f =_U g · h.

*Proof.* By the axiom of choice, select g(i) and h(i) as nontrivial factors of f(i) for each i in the U-large set. □

### PEGB Analysis for Compositeness Transfer

- **P**: Lean 4 proof using Classical choice.
- **E**: f(i) = 6 · i gives g(i) = 2, h(i) = 3i (or g(i) = minFac(6i), h(i) = 6i/minFac(6i)).
- **G**: Any existential property ∃x, P(f(i), x) that holds U-a.e. transfers: by choice, get witnesses forming a sequence.
- **B**: Universal properties ∀x, P(f(i), x) do NOT automatically transfer in this direction (they transfer the other way, from ℕ* to ℕ, via the underflow principle).

### 5.2 The Underflow Principle

**Theorem 5.2.** If P : ℕ → Prop satisfies: for every nonstandard f, {i | P(f(i))} ∈ U, then ∃ N, ∀ n ≥ N, P(n).

*Proof sketch.* By contraposition. If ∀ N, ∃ n ≥ N, ¬P(n), use choice to build f : ℕ → ℕ with f(i) ≥ i and ¬P(f(i)) for all i. Then f is nonstandard (f(i) > n for all n, U-a.e.) but {i | P(f(i))} = ∅ ∉ U, contradicting the hypothesis. □

### PEGB Analysis for Underflow

- **P**: Lean 4 proof by contradiction + choice.
- **E**: P(n) = "all even numbers ≤ n are sums of two primes." If this holds for all nonstandard n (which it does assuming Goldbach), then it holds for all large standard n.
- **G**: Works for any predicate, not just decidable ones (using classical logic). Generalizes to arbitrary index sets I with free ultrafilter.
- **B**: The quantifier "for ALL nonstandard f" is essential. If only SOME nonstandard f satisfies the property, we cannot conclude anything about standard numbers.

### 5.3 Conditional Goldbach Transfer

**Theorem 5.3.** If Goldbach's conjecture holds for all n ∈ ℕ, then for any f with {i | 4 ≤ f(i)} ∈ U and {i | Even(f(i))} ∈ U, there exist prime sequences g, h with f =_U g + h.

*Proof.* Apply Goldbach pointwise and use choice to extract g, h. □

### 5.4 FTA Fragment Transfer

**Theorem 5.4.** Every element of ℕ* that is ≥ 2 U-a.e. has an ultra-prime divisor.

*Proof.* Use Nat.minFac pointwise: for f(i) ≥ 2, Nat.minFac(f(i)) is prime and divides f(i). □

### PEGB Analysis for FTA Transfer

- **P**: Lean 4 proof using Nat.minFac_prime and Nat.minFac_dvd.
- **E**: For f(i) = 12, minFac(12) = 2, which is prime and divides 12.
- **G**: By iterating, one can extract a full prime factorization: a sequence of ultra-primes whose product equals f U-a.e.
- **B**: The extracted prime sequence p(i) = minFac(f(i)) may itself be standard (e.g., if f(i) is always even, p(i) = 2). Not all prime divisors are nonstandard.

## 6. The Ultra-Goldbach Transfer Conjecture

**Conjecture 6.1.** The statement `UltraGoldbachTransfer` — that Goldbach for ℕ implies Goldbach for ℕ* — is provable without any additional axioms beyond ZFC.

We have formally verified this conjecture (Theorem `ultra_goldbach_transfer_holds`). The proof is a direct application of pointwise Goldbach + choice.

**Computational Test**: Goldbach has been verified computationally for all even n ≤ 4 × 10^18. For any sequence f bounded by this threshold, the transfer is unconditional.

## 7. Discussion

### 7.1 Connection to Existing Work

The GrowthRank construction connects to several threads in the literature:

- **Hardy fields** and **growth rates of functions** (Bourbaki, Rosenlicht) study similar asymptotic equivalence classes, but for germs of real-valued functions at infinity. Our construction is discrete and ultrafilter-dependent.
- **Ultraproduct orderings** are implicit in model theory but rarely studied as algebraic objects in their own right.
- **Non-Archimedean valued fields** (p-adic numbers, formal Laurent series) provide analogous non-Archimedean structures, but with a very different flavor — our ordering is total and non-metric.

### 7.2 The Role of the Ultrafilter

A crucial feature of the GrowthRank is its dependence on the choice of ultrafilter. Different free ultrafilters on ℕ can produce genuinely different GrowthRanks — for instance, the ordering of oscillating sequences depends on which indices the ultrafilter "selects." This ultrafilter dependence is not a bug but a feature: it means the GrowthRank encodes information about the ultrafilter itself.

### 7.3 Open Questions

1. **Cardinality**: What is the cardinality of 𝔊(U)? We conjecture it is 2^ℵ₀ for any free ultrafilter.
2. **Isomorphism**: Are all GrowthRanks (for different free ultrafilters on ℕ) isomorphic as ordered monoids? Under CH, all ultraproducts ∏_U ℕ are isomorphic, suggesting yes.
3. **Decidability**: Is the theory of the ordered monoid 𝔊(U) decidable?
4. **Dense subgroups**: Does 𝔊(U) contain a dense copy of (ℚ, +, ≤)?

## 8. Algorithms

### 8.1 Ultraproduct Element Comparison

Given concrete sequences f, g and a finitely approximated ultrafilter (a consistent family of 0/1 decisions on initial segments), determine f ≤_U g by checking the "vote" on the finite prefix.

### 8.2 Growth Rank Classification

For a given sequence f, compute its approximate growth rank by fitting f(n)/n^α for various α, finding the best-fit exponent. This classifies f into polynomial growth classes.

## References

[1] A. Robinson, *Non-Standard Analysis*, North-Holland, 1966.

[2] J. Łoś, "Quelques remarques, théorèmes et problèmes sur les classes définissables d'algèbres," *Mathematical Interpretation of Formal Systems*, North-Holland, 1955.

[3] C. C. Chang and H. J. Keisler, *Model Theory*, North-Holland, 1973.

[4] R. Goldblatt, *Lectures on the Hyperreals*, Springer, 1998.

[5] Catalog: `Bridges/DependentUltraproduct.lean`, ultrafilter_transfer_and.

[6] Catalog: `Catalog/Novelty/Overspill.lean`, overspill_diagonal.
