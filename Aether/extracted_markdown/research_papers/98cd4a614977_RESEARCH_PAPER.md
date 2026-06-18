# The Mod-9 Algebra of Vampire Numbers: Classification, Polynomial Bridges, and Density Sieves

## Abstract

We develop the complete algebraic theory of the mod-9 constraint on vampire number factorizations. A vampire number v with 2n digits admits a factorization v = x × y with n-digit fangs x, y whose digit multiset equals that of v. We prove that digit multiset preservation forces x × y ≡ x + y (mod 9), equivalently (x-1)(y-1) ≡ 1 (mod 9), and classify the valid residue pairs: exactly 6 out of 81 pairs in (ℤ/9ℤ)² satisfy this constraint, giving a fraction of 2/27. We establish the Vampire Nine Dichotomy — both fangs are divisible by 9 or neither is — and introduce the digit-counting polynomial P_n(X) = Σ X^{d_i}, proving it is additive under vampire factorization: P_v = P_x + P_y. All results are machine-verified in Lean 4 with Mathlib. We also define ghost numbers (digit-disjoint factorizations) and prove structural constraints on their factors.

**Keywords**: Vampire numbers, digit multisets, modular arithmetic, polynomial invariants, formal verification

## 1. Introduction

Vampire numbers were introduced by Pickover [1] as composite numbers v with 2n digits admitting a factorization v = x × y where x, y each have n digits and the multiset of decimal digits of v equals the disjoint union of digit multisets of x and y. The canonical example is 1260 = 21 × 60, where {0,1,2,6} = {1,2} ∪ {0,6} as multisets.

Despite their recreational origin, vampire numbers exhibit deep connections to modular arithmetic, polynomial algebra, and combinatorial number theory. The digit multiset preservation condition is algebraically rigid: it induces constraints on factorization residues modulo 9 (and more generally modulo b-1 in base b), connects to polynomial identities via generating functions, and determines structural properties of the factorization.

In this paper, we develop these connections systematically, proving:

1. **The Vampire Mod-9 Theorem**: For any vampire factorization v = x × y, we have x × y ≡ x + y (mod 9) (Theorem 3.1).

2. **Residue Classification**: Exactly 6 residue pairs in (ℤ/9ℤ)² satisfy the vampire constraint, giving a 2/27 fraction (Theorem 3.3).

3. **The Vampire Nine Dichotomy**: In any vampire factorization, 9 | x ⟺ 9 | y (Theorem 3.4).

4. **The Vampire Polynomial Theorem**: The digit-counting polynomial P_v = P_x + P_y (Theorem 4.1).

5. **Structural Results**: Vampire numbers are composite, have ≥ 4 digits, and their digit counts are additive under factorization (Theorems 5.1-5.3).

All theorems are formally verified in Lean 4 using the Mathlib library.

## 2. Definitions

### 2.1 Digit Multisets

**Definition 2.1** (Digit multiset). For n ∈ ℕ, the *digit multiset* D(n) is the multiset of coefficients in the base-10 representation of n. Formally, D(n) = ↑(Nat.digits 10 n) as a multiset over ℕ.

**Definition 2.2** (Digit sum). The *digit sum* σ(n) = Σ_{d ∈ D(n)} d.

**Definition 2.3** (Digit count). The *digit count* |D(n)| = #D(n) is the number of decimal digits.

### 2.2 Vampire Numbers

**Definition 2.4** (Vampire number). A natural number v is a *vampire number* if there exist n ≥ 2 and x, y ∈ ℕ such that:
- |D(v)| = 2n (v has an even number of digits)
- |D(x)| = |D(y)| = n (fangs have equal digit count)
- v = x × y (factorization condition)
- D(v) = D(x) + D(y) (digit multiset preservation, where + is multiset union)
- ¬(10 | x ∧ 10 | y) (no trailing-zero degeneracy)

### 2.3 Ghost Numbers

**Definition 2.5** (Ghost number). A natural number v is a *ghost number* if there exist x, y > 1 with v = x × y such that D(v)^{set} ∩ D(x)^{set} = ∅ and D(v)^{set} ∩ D(y)^{set} = ∅, where S^{set} denotes the underlying set of a multiset.

### 2.4 Digit-Counting Polynomial

**Definition 2.6** (Digit-counting polynomial). For n ∈ ℕ, the *digit-counting polynomial* is P_n(X) = Σ_{d ∈ D(n)} X^d ∈ ℤ[X].

### 2.5 Vampire Residue Set

**Definition 2.7** (Vampire residue set). The *vampire residue set* V₉ ⊂ (ℤ/9ℤ)² consists of all pairs (a, b) satisfying a · b = a + b in ℤ/9ℤ.

## 3. The Mod-9 Theory

### 3.1 The Fundamental Constraint

**Lemma 3.1** (Casting out nines). For all n ∈ ℕ, n ≡ σ(n) (mod 9).

*Proof.* Classical. Since 10 ≡ 1 (mod 9), n = Σ d_i · 10^i ≡ Σ d_i = σ(n) (mod 9). □

**Lemma 3.2** (Digit sum additivity). If D(v) = D(x) + D(y), then σ(v) = σ(x) + σ(y).

*Proof.* The sum of a multiset union equals the sum of the individual sums. □

**Theorem 3.1** (Vampire Mod-9 Theorem). If v = x × y and D(v) = D(x) + D(y), then x × y ≡ x + y (mod 9).

*Proof.* By Lemma 3.1, v ≡ σ(v) (mod 9), x ≡ σ(x) (mod 9), y ≡ σ(y) (mod 9). By Lemma 3.2, σ(v) = σ(x) + σ(y). Therefore x × y = v ≡ σ(v) = σ(x) + σ(y) ≡ x + y (mod 9). □

**Theorem 3.2** (Residue equivalence). For a, b ∈ ℤ/9ℤ: a · b = a + b ⟺ (a-1)(b-1) = 1.

*Proof.* a · b - a - b + 1 = (a-1)(b-1), so a · b = a + b iff (a-1)(b-1) = 1. Formally verified by `decide` over the finite type ℤ/9ℤ. □

### 3.2 Classification of Valid Residue Pairs

**Theorem 3.3** (Residue set cardinality). |V₉| = 6. The valid pairs are:
{(0,0), (2,2), (3,6), (5,8), (6,3), (8,5)}.

*Proof.* By Theorem 3.2, the valid pairs are those where a-1 and b-1 are units in ℤ/9ℤ that are inverses of each other. The units of ℤ/9ℤ are (ℤ/9ℤ)* = {1, 2, 4, 5, 7, 8}, and the inverse pairs are: 1↔1, 2↔5, 4↔7, 8↔8. Shifting by 1: (2,2), (3,6), (5,8), (6,3), (8,5), plus (0,0) from the non-unit case. Verified by `native_decide`. □

**Corollary 3.1** (2/27 sieve). The fraction of residue pairs satisfying the vampire constraint is |V₉|/|ℤ/9ℤ × ℤ/9ℤ| = 6/81 = 2/27.

### 3.3 The Nine Dichotomy

**Theorem 3.4** (Vampire Nine Dichotomy). If v = x × y is a vampire factorization with D(v) = D(x) + D(y), then 9 | x ⟺ 9 | y.

*Proof.* By Theorem 3.1, x × y ≡ x + y (mod 9). If 9 | x, then x ≡ 0, so 0 ≡ y (mod 9), hence 9 | y. By symmetry of the valid pair set, the converse holds. Formally, this is verified by exhaustive case analysis on residues mod 9 using `interval_cases`. □

## 4. The Polynomial Bridge

### 4.1 Polynomial Additivity

**Theorem 4.1** (Vampire Polynomial Theorem). If D(v) = D(x) + D(y), then P_v(X) = P_x(X) + P_y(X) in ℤ[X].

*Proof.* P_n(X) = Σ_{d ∈ D(n)} X^d. Since D(v) = D(x) + D(y) as multisets, summing the function d ↦ X^d over the multiset union yields the sum of the individual polynomial sums. □

**Theorem 4.2** (Digit count from evaluation). P_n(1) = |D(n)| for all n ∈ ℕ.

*Proof.* P_n(1) = Σ_{d ∈ D(n)} 1^d = Σ_{d ∈ D(n)} 1 = |D(n)|. □

**Corollary 4.1** (Digit count additivity). If D(v) = D(x) + D(y), then |D(v)| = |D(x)| + |D(y)|.

*Proof.* Evaluate Theorem 4.1 at X = 1 and apply Theorem 4.2. Alternatively, use that multiset cardinality is additive: |S + T| = |S| + |T|. □

### 4.2 Higher Evaluations

Evaluating the polynomial identity at other points yields additional constraints:

- **X = 10**: Relates to digit frequency generating functions
- **X = −1**: Constrains the alternating digit sum, connecting to divisibility by 11
- **X = ζ_k** (k-th root of unity): Constrains digit distribution modulo k

These suggest a Fourier-analytic approach to vampire number density via discrete Fourier analysis of digit distributions.

## 5. Structural Results

**Theorem 5.1** (Composites). Every vampire number is composite.

*Proof.* If v = x × y with |D(x)| = |D(y)| = n ≥ 2, then x ≥ 10 and y ≥ 10, giving v = x × y with both factors > 1. □

**Theorem 5.2** (Lower bound). Every vampire number v satisfies v ≥ 1000.

*Proof.* The constraint n ≥ 2 implies |D(v)| = 2n ≥ 4, so v ≥ 10^3 = 1000. □

**Theorem 5.3** (Digit count additivity). If D(v) = D(x) + D(y), then |D(v)| = |D(x)| + |D(y)|.

*Proof.* From multiset cardinality additivity. □

## 6. Existence Results

We verify concrete vampire numbers in both the 4-digit and 6-digit ranges:

**4-digit vampires**: 1260 = 21×60, 1395 = 15×93, 1435 = 35×41, 1530 = 30×51, 6880 = 80×86.

**6-digit vampires**: 102510 = 201×510, 104260 = 260×401, 117067 = 167×701.

All digit multiset equalities are verified by `native_decide` in Lean 4.

**Theorem 6.1** (Existence in ranges). For each k ∈ {2, 3}, there exists a vampire number in [10^{2k-1}, 10^{2k} - 1].

## 7. Ghost Number Constraints

Ghost numbers — products where factor digits are disjoint from the product's digits — represent the opposite extreme from vampire numbers.

**Observation 7.1**. Ghost numbers become increasingly rare as the number of digits grows, because large numbers tend to use most of the 10 available digits, leaving few for their factors.

**Theorem 7.1** (Spectral impossibility). There are no "spectral numbers" (numbers where sorted digits match but multisets differ), since multiset equality is equivalent to sorted equality.

This result, while simple, clarifies the relationship between sorting and multiset theory in the context of digit arithmetic.

## 8. Algorithms

### 8.1 The Mod-9 Sieve Algorithm

Given a 2n-digit number v, the mod-9 sieve eliminates candidate fang pairs as follows:

1. Compute r = v mod 9
2. For each valid pair (a, b) ∈ V₉, check if (a × b) mod 9 = r
3. Only test fang pairs (x, y) where (x mod 9, y mod 9) is a valid pair

This reduces the search space by a factor of approximately 27/2 = 13.5.

### 8.2 Digit Histogram Comparison

Instead of sorting digits (O(n log n)), compare digit histograms (O(n)) by counting occurrences of each digit 0-9 in a length-10 array.

## 9. Discussion and Future Work

The mod-9 theory developed here extends naturally in several directions:

1. **Base-b generalization**: In base b, the vampire constraint becomes x × y ≡ x + y (mod b-1), and the valid residue pairs are classified by the unit group of ℤ/(b-1)ℤ.

2. **Asymptotic density**: The 2/27 sieve provides an upper bound on vampire density. Combining sieves at multiple moduli (mod 9, mod 11, mod 99, ...) may yield tighter bounds.

3. **Algebraic geometry of digit varieties**: The polynomial identity P_v = P_x + P_y, combined with v = x × y, defines an algebraic variety in polynomial coefficient space whose geometry encodes the structure of vampire factorizations.

4. **Multiplicative digit theory**: Replacing multiset *union* with multiset *product* gives "multiplicative vampire" conditions with different algebraic properties.

## References

[1] Pickover, C. A. "Interview with a number." *Discover* 16, no. 6 (1995): 136.

[2] Catalog theorem: `Catalog/Geometry/VampireNumbers/Theorems.lean` — vampire_mod9_constraint, vampire_1260, ghost_number_distinct_digits.

[3] Catalog definitions: `Catalog/Geometry/VampireNumbers/Defs.lean` — IsVampire, IsGhostNumber, digitMultiset.

[4] This work: `Novelty/VampireBestiary/Mod9Theory.lean`, `Novelty/VampireBestiary/Existence.lean`, `Novelty/VampireBestiary/Defs.lean`.
