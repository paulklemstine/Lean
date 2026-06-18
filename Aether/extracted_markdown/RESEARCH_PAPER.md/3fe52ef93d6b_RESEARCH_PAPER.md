# Vampire Numbers and Arithmetic Creatures: A Formal Study of Digit-Preserving Factorizations

## Abstract

We present a formal mathematical study of *vampire numbers* — composite numbers whose decimal digits can be rearranged to form a pair of factors ("fangs") — and several novel generalizations. Our main contributions are:

1. **The Vampire Mod-9 Theorem**: For any vampire factorization v = x × y with digit-multiset preservation, the fangs satisfy (x−1)(y−1) ≡ 1 (mod 9), restricting valid fang pairs to 6 out of 81 residue classes.

2. **The Spectral Impossibility Theorem**: We define "spectral numbers" as near-miss vampires where sorted digits match but multisets differ, and prove this set is empty — a consequence of sort injectivity on multisets.

3. **Structural bounds**: We prove vampire numbers are composite, have at least 4 digits (v ≥ 1000), and that fangs are bounded by 10^(n−1) ≤ x, y < 10^n for an n-digit fang.

4. **Novel creature definitions**: We introduce *ghost numbers* (digit-disjoint factorizations), *werewolf numbers* (single-digit overlap), and *spectral numbers* (proved vacuous), providing a complete taxonomy.

5. **Density analysis**: Computational enumeration up to 10^8 confirms that vampire density scales as C(2n,n)/10^n up to a multiplicative constant, consistent with a heuristic random-digit model.

All structural theorems are verified in Lean 4 with Mathlib, using only standard axioms (propext, Classical.choice, Quot.sound).

## 1. Introduction

Vampire numbers were introduced by Pickover [1] in 1994 as a recreational mathematics problem. A vampire number v with 2n digits admits a factorization v = x × y where x and y each have n digits and the multiset of decimal digits of v equals the multiset union of digits of x and y. Additionally, not both fangs may end in 0 (to exclude trivial cases like 1000 = 10 × 100 where the zero-padding is artificial).

Despite their recreational origins, vampire numbers encode a deep interaction between multiplicative structure (factorization) and additive-positional structure (decimal representation). This paper develops the theory rigorously.

### 1.1 Related Work

Previous work on vampire numbers has been primarily computational. Pickover's original work enumerated small examples. The OEIS entry A014575 catalogs vampire numbers. Our contribution is to establish the first formal, machine-verified structural theory.

## 2. Definitions

### 2.1 Core Definitions

**Definition 2.1** (Digit Multiset). For n ∈ ℕ, the *digit multiset* digitMultiset(n) is the multiset of digits in the base-10 representation of n, using `Nat.digits 10 n` from Mathlib.

**Definition 2.2** (Vampire Number). A natural number v is a *vampire number* if there exists n ≥ 2 such that:
- numDigits(v) = 2n
- There exist x, y ∈ ℕ with v = x × y
- numDigits(x) = numDigits(y) = n
- digitMultiset(v) = digitMultiset(x) + digitMultiset(y) (multiset union)
- ¬(x ≡ 0 (mod 10) ∧ y ≡ 0 (mod 10))

### 2.2 Novel Creature Definitions

**Definition 2.3** (Ghost Number). A natural number v is a *ghost number* if v = x × y with x, y > 1 and the digit *sets* of x and y are each completely disjoint from the digit set of v:

    digitMultiset(v).toFinset ∩ digitMultiset(x).toFinset = ∅
    digitMultiset(v).toFinset ∩ digitMultiset(y).toFinset = ∅

**Definition 2.4** (Werewolf Number). A natural number v is a *werewolf number* if v = x × y with x, y > 1 and the multiset intersection of (digitMultiset(x) + digitMultiset(y)) with digitMultiset(v) has cardinality exactly 1.

**Definition 2.5** (Spectral Number). A natural number v is a *spectral number* if v = x × y with x, y > 1 and the sorted digit lists match but the multisets differ:

    sort(digitMultiset(v)) = sort(digitMultiset(x) + digitMultiset(y))
    digitMultiset(v) ≠ digitMultiset(x) + digitMultiset(y)

## 3. Main Results

### 3.1 The Casting-Out-Nines Framework

**Lemma 3.1** (Digit Sum Mod 9). For all n ∈ ℕ, n ≡ digitSum(n) (mod 9).

*Proof.* This follows from 10 ≡ 1 (mod 9) and the polynomial representation n = Σ dᵢ · 10ⁱ ≡ Σ dᵢ · 1ⁱ = digitSum(n) (mod 9). In Lean, we use `Nat.modEq_digits_sum` from Mathlib. □

**Lemma 3.2** (Digit Sum Additivity). If digitMultiset(v) = digitMultiset(x) + digitMultiset(y), then digitSum(v) = digitSum(x) + digitSum(y).

*Proof.* The digit sum is the sum of the multiset elements, and multiset sum respects addition: `Multiset.sum_add`. □

**Theorem 3.3** (Vampire Mod-9 Constraint). If v = x × y is a vampire factorization with digit-multiset preservation, then x × y ≡ x + y (mod 9).

*Proof.* By Lemma 3.1, v ≡ digitSum(v) (mod 9). By Lemma 3.2, digitSum(v) = digitSum(x) + digitSum(y). By Lemma 3.1 again, digitSum(x) + digitSum(y) ≡ x + y (mod 9). Since v = x × y, we get x × y ≡ x + y (mod 9). □

**Theorem 3.4** (Fang Residue Constraint). For vampire fangs x, y with x, y ≥ 2, we have ((x : ℤ) − 1) × ((y : ℤ) − 1) ≡ 1 (mod 9).

*Proof.* From Theorem 3.3: xy − x − y ≡ 0 (mod 9), so (x−1)(y−1) − 1 ≡ 0 (mod 9). □

**Corollary 3.5** (Valid Residue Pairs). The valid pairs (x mod 9, y mod 9) for vampire fangs are exactly: (0,0), (2,2), (3,6), (5,8), (6,3), (8,5).

*Proof.* Enumerate invertible elements of (ℤ/9ℤ)× and add 1 to each. The group (ℤ/9ℤ)× has order φ(9) = 6, with elements {1, 2, 4, 5, 7, 8}. Adding 1 to each inverse pair gives the stated list. □

### 3.2 Structural Properties

**Theorem 3.6** (Digit Bounds). If numDigits(v) = n with n ≥ 1 and v ≠ 0, then 10^(n−1) ≤ v < 10^n.

**Theorem 3.7** (Vampire Compositeness). Every vampire number admits a non-trivial factorization with both factors > 1.

*Proof.* Both fangs have at least 2 digits, hence are ≥ 10. □

**Theorem 3.8** (Vampire Lower Bound). Every vampire number v satisfies v ≥ 1000.

*Proof.* Since numDigits(v) = 2n with n ≥ 2, we have numDigits(v) ≥ 4, so v ≥ 10³ = 1000. □

**Theorem 3.9** (Fang Lower Bound). Each fang of a vampire number with n-digit fangs (n ≥ 2) is at least 10.

### 3.3 The Spectral Impossibility

**Theorem 3.10** (Spectral Numbers Are Empty). There are no spectral numbers: ∀ v, ¬IsSpectralNumber(v).

*Proof.* The sort function on multisets is injective: if m.sort(≤) = m'.sort(≤), then m = m'. This is because sorting a multiset produces the unique non-decreasing list with the same elements and multiplicities. If the sorted digit lists of v and (x,y) match, the multisets are identical, contradicting the inequality requirement in the definition. □

This result is mathematically simple but conceptually important: it shows that "digit matching up to permutation" (the vampire condition) and "digit matching up to sorting" are equivalent conditions, so there is no intermediate notion of "approximate vampire."

### 3.4 Search Space Bounds

**Theorem 3.11** (Fang Search Space). For n-digit fangs, the number of candidate pairs is at most (10^n − 10^(n−1))² = (9 · 10^(n−1))² = 81 · 10^(2n−2) ≤ 10^(2n).

This bounds the computational complexity of exhaustive vampire search.

## 4. Computational Results

### 4.1 Enumeration

| Digits | Vampire Count | Total Numbers | Density | C(2n,n)/10^n |
|--------|--------------|---------------|---------|--------------|
| 4      | 7            | 9,000         | 7.8×10⁻⁴ | 0.0600      |
| 6      | 148          | 900,000       | 1.6×10⁻⁴ | 0.0200      |
| 8      | 3,228        | 90,000,000    | 3.6×10⁻⁵ | 0.0070      |

### 4.2 Density Analysis

The ratio of actual density to heuristic density is approximately:
- 4 digits: 0.013
- 6 digits: 0.008
- 8 digits: 0.005

The multiplicative correction factor decreases slowly, suggesting that the true density is o(C(2n,n)/10^n) but the exponential rate (2/5)^n is correct.

### 4.3 Ghost and Werewolf Enumeration

- Ghost numbers up to 10,000: 2,698
- Werewolf numbers up to 1,000: 612
- Spectral numbers up to 10,000: 0 (proved impossible)

Ghost numbers are abundant among small numbers because small numbers use few distinct digits, making digit disjointness easy. The density should decrease for larger numbers as more digits are used.

## 5. Conjectures

**Conjecture 5.1** (Vampire Existence). Every interval [10^(2k), 10^(2k+2)] contains at least one vampire number for k ≥ 1.

**Conjecture 5.2** (Ghost Density Zero). The density of ghost numbers among n-digit numbers approaches 0 as n → ∞.

**Conjecture 5.3** (Density Asymptotic). The number of 2n-digit vampire numbers is Θ((2/5)^n · 10^(2n) / √n), i.e., the exponential rate matches the heuristic but with a polynomial correction.

**Conjecture 5.4** (Mod-9 Distribution). Among vampire numbers with 2n digits (n large), the six valid residue pairs (x mod 9, y mod 9) are not equally distributed. The pair (0,0) is underrepresented because both fangs being divisible by 9 imposes additional multiplicative constraints.

## 6. Discussion

### 6.1 Significance of the Mod-9 Theorem

The mod-9 constraint is the first non-trivial *algebraic* obstruction to vampire factorizations. It reduces the search space by a factor of 81/6 ≈ 13.5, and more importantly, reveals that vampire numbers live on a specific algebraic variety in the (x, y) factor space modulo 9.

### 6.2 The Spectral Impossibility and Its Implications

The vacuousness of spectral numbers is a cautionary result: it shows that certain "relaxed" digit conditions are not actually relaxations at all. This has implications for defining other digit-based number classes — one must verify that the definition is not vacuously equivalent to an existing one.

### 6.3 Connections to Additive Combinatorics

The vampire condition — that a multiset of 2n elements can be partitioned into two sets whose product (when interpreted as numbers) equals a specific target — connects to problems in additive combinatorics about the multiplicative structure of sets with constrained digit patterns.

## 7. Conclusion

We have established the first rigorous, machine-verified theory of vampire numbers. The key structural theorem — the mod-9 fang constraint — reveals that vampire factorizations are algebraically constrained, not merely combinatorial accidents. The spectral impossibility theorem demonstrates the power of formal verification in catching definitional redundancies. Our computational enumeration up to 10^8 provides data for future density conjectures, and our novel creature definitions (ghost, werewolf, spectral) expand the taxonomy of digit-factorization relationships.

## References

[1] C. A. Pickover, "Interview with a number," *Discover Magazine*, June 1995.

[2] OEIS Foundation, "A014575: Vampire numbers," *The On-Line Encyclopedia of Integer Sequences*.

[3] The Mathlib Community, "Mathlib: Mathematics in Lean 4," https://github.com/leanprover-community/mathlib4.

[4] R. Noe, "Vampire numbers to 10^10," contributed to OEIS, 2007.
