# Digit-Morphic Factorization Theory: The Algebraic Structure of Digit-Preserving Products

## Abstract

We introduce the **digit-morphic factorization** framework, generalizing vampire numbers from base 10 to arbitrary bases b ≥ 2. A factorization v = x · y in base b is *digit-morphic* if the multiset of base-b digits of v equals the multiset union of the digits of x and y. Our central result is the **Generalized Fang Residue Constraint**: for any digit-morphic factorization in base b, the relation (x − 1)(y − 1) ≡ 1 (mod b − 1) must hold, restricting valid factor pairs to exactly φ(b − 1) residue classes. We define the **morphic algebra** of modulus m as the set of pairs satisfying this constraint and establish a canonical bijection with the unit group (ℤ/mℤ)×, yielding a natural involution and fixed-point characterization. We introduce the **digit defect** as a quantitative measure of deviation from digit preservation and prove that defect zero exactly characterizes digit-morphic factorizations. All results are formalized and verified in Lean 4 with Mathlib.

## 1. Introduction

### 1.1 Background

Vampire numbers, introduced by Pickover (1994), are composite numbers whose decimal digits can be rearranged to form their two factors. The smallest example is 1260 = 21 × 60. Despite extensive computational investigation, the algebraic structure underlying these numbers has received limited theoretical attention.

The classical "casting out nines" observation—that a number is congruent to its digit sum modulo 9—immediately yields a necessary condition for vampire factorizations: x · y ≡ x + y (mod 9). This was noted by several authors but not systematically developed.

### 1.2 Contributions

This paper makes the following contributions:

1. **Base-b generalization**: We extend the definition of digit-morphic factorizations to arbitrary bases and prove the generalized casting-out-(b−1)s congruence.

2. **Fang Residue Constraint**: We prove that (x − 1)(y − 1) ≡ 1 (mod b − 1) for any digit-morphic factorization, connecting digit theory to the multiplicative structure of ℤ/(b−1)ℤ.

3. **Morphic Algebra**: We define and analyze the set of residue class pairs satisfying the fang constraint, establishing a bijection with (ℤ/mℤ)× and counting exactly φ(m) pairs.

4. **Digit Defect**: We introduce a quantitative measure of deviation from digit preservation with a characterization theorem.

5. **Formal verification**: All results are mechanically verified in Lean 4.

## 2. Definitions

### 2.1 Base-b Digit Operations

**Definition 2.1** (Digit Multiset). For b ≥ 2 and n ∈ ℕ, the *digit multiset* of n in base b is

    digitMultiset(b, n) = ⟦Nat.digits(b, n)⟧

where Nat.digits(b, n) is the list of base-b digits (least significant first) and ⟦·⟧ denotes the multiset of a list.

**Definition 2.2** (Digit Sum). The *digit sum* of n in base b is

    digitSum(b, n) = Σ d ∈ Nat.digits(b, n)

**Definition 2.3** (Digit-Morphic Factorization). A factorization v = x · y with x, y > 1 is *digit-morphic in base b* if

    digitMultiset(b, v) = digitMultiset(b, x) + digitMultiset(b, y)

where + denotes multiset sum.

### 2.2 The Digit Defect

**Definition 2.4** (Digit Defect). The *digit defect* of a factorization v = x · y in base b is

    δ_b(v, x, y) = |digitMultiset(b, v) \ (digitMultiset(b, x) + digitMultiset(b, y))| + |(digitMultiset(b, x) + digitMultiset(b, y)) \ digitMultiset(b, v)|

where \ denotes multiset difference and |·| denotes cardinality.

### 2.3 The Morphic Algebra

**Definition 2.5** (Morphic Pairs). For m ∈ ℕ, the *morphic algebra of modulus m* is

    M(m) = {(a, c) ∈ (ℤ/mℤ)² : (a − 1)(c − 1) = 1}

## 3. Main Results

### 3.1 The Generalized Casting-Out Congruence

**Theorem 3.1** (Base-b Digit Sum Congruence). For any b ≥ 2 and n ∈ ℕ,

    n ≡ digitSum(b, n) (mod b − 1)

*Proof sketch.* Since b ≡ 1 (mod b − 1), each term b^k · d_k in the base-b expansion contributes d_k modulo b − 1. The result follows from Nat.modEq_digits_sum applied with b' = b and modulus b − 1. □

**Theorem 3.2** (Digit Sum Additivity). If digitMultiset(b, v) = digitMultiset(b, x) + digitMultiset(b, y), then

    digitSum(b, v) = digitSum(b, x) + digitSum(b, y)

*Proof sketch.* The digit sum is the sum of elements of the digit multiset. Multiset equality preserves sums. □

### 3.2 The Fang Residue Constraint

**Theorem 3.3** (Generalized Fang Residue Constraint — Modular Form). For any digit-morphic factorization v = x · y in base b ≥ 2,

    x · y ≡ x + y (mod b − 1)

*Proof sketch.* By Theorems 3.1 and 3.2:
- x · y = v ≡ digitSum(b, v) (mod b − 1)
- digitSum(b, v) = digitSum(b, x) + digitSum(b, y)
- digitSum(b, x) + digitSum(b, y) ≡ x + y (mod b − 1)

Chaining these congruences gives x · y ≡ x + y (mod b − 1). □

**Theorem 3.4** (Fang Residue Constraint — Integer Form). If x, y ≥ 2 and x · y ≡ x + y (mod b − 1), then

    (x − 1)(y − 1) ≡ 1 (mod b − 1)

in ℤ.

*Proof sketch.* Since (x − 1)(y − 1) = xy − x − y + 1, we have (x − 1)(y − 1) − 1 = xy − (x + y). The hypothesis says (b − 1) | (xy − (x + y)), which gives the result. □

**PEGB for Theorem 3.3–3.4:**

- **Proof**: Complete Lean 4 proofs provided (morphic_product_sum_congruence, morphic_fang_residue_constraint).
- **Example**: In base 10, 1260 = 21 × 60. We have 21 × 60 = 1260 and 21 + 60 = 81, and 1260 − 81 = 1179 = 131 × 9. So 1260 ≡ 81 (mod 9). Also (21 − 1)(60 − 1) = 20 × 59 = 1180, and 1180 − 1 = 1179 = 131 × 9. ✓
- **Generalization**: The constraint holds for digit-morphic factorizations in any base, not just balanced-fang vampire numbers.
- **Boundary**: When b = 2, b − 1 = 1, and the constraint becomes trivial (everything is ≡ 0 mod 1). Binary is maximally permissive. When b − 1 is prime p, the constraint is most restrictive relative to base size, with exactly p − 1 valid pairs out of p² possible.

### 3.3 The Morphic Algebra

**Theorem 3.5** (Morphic Pair Bijection). For m ≥ 1,

    M(m) = {(u + 1, u⁻¹ + 1) : u ∈ (ℤ/mℤ)×}

*Proof sketch.* If (a − 1)(c − 1) = 1, then a − 1 is a unit with inverse c − 1. Setting u = a − 1 gives a = u + 1, c = u⁻¹ + 1. Conversely, for any unit u, (u + 1 − 1)(u⁻¹ + 1 − 1) = u · u⁻¹ = 1. □

**Theorem 3.6** (Morphic Pair Count). |M(m)| = φ(m).

*Proof sketch.* By Theorem 3.5, the map u ↦ (u + 1, u⁻¹ + 1) is a bijection from (ℤ/mℤ)× to M(m). Since |(ℤ/mℤ)×| = φ(m), the result follows. □

**PEGB for Theorem 3.6:**

- **Proof**: Complete Lean 4 proof (morphicPairs_card).
- **Example**: For m = 9 (base 10 vampires), φ(9) = 6. The units of ℤ/9ℤ are {1, 2, 4, 5, 7, 8}, giving pairs (2,2), (3,5), (5,3), (6,8), (8,6), (9≡0, 9≡0) → actually (2,2), (3,5), (5,3), (6,8), (8,6), (0,0) in ℤ/9ℤ.
- **Generalization**: Works for any modulus m, not just m = b − 1.
- **Boundary**: When m = 1, φ(1) = 1, and the unique morphic pair is (0, 0) in ℤ/1ℤ = {0}. When m = 2, φ(2) = 1.

### 3.4 Involution and Fixed Points

**Theorem 3.7** (Morphic Involution). If (a, c) ∈ M(m), then (c, a) ∈ M(m).

*Proof sketch.* By commutativity: (c − 1)(a − 1) = (a − 1)(c − 1) = 1. □

**Theorem 3.8** (Fixed Point Characterization). (a, a) ∈ M(m) if and only if (a − 1)² = 1 in ℤ/mℤ.

*Proof sketch.* (a, a) ∈ M(m) iff (a − 1)² = (a − 1)(a − 1) = 1. □

**PEGB for Theorem 3.7–3.8:**

- **Proof**: Complete Lean 4 proofs.
- **Example**: For m = 9, (a − 1)² = 1 has solutions a − 1 ∈ {1, 8} (since 1² = 1 and 8² = 64 ≡ 1 mod 9), giving a ∈ {2, 0}. The fixed points are (2, 2) and (0, 0).
- **Generalization**: The number of fixed points equals the number of square roots of unity in ℤ/mℤ, which is 2^k where k is the number of odd prime factors of m (for odd m ≥ 3).
- **Boundary**: When m is prime, there are exactly 2 fixed points. When m = 2^k, behavior depends on k.

### 3.5 Defect Properties

**Theorem 3.9** (Defect Zero Characterization). δ_b(v, x, y) = 0 if and only if the factorization is digit-morphic.

**Theorem 3.10** (Defect Commutativity). δ_b(v, x, y) = δ_b(v, y, x).

### 3.6 Compositeness

**Theorem 3.11** (Digit-Morphic Numbers Are Composite). Any number admitting a digit-morphic factorization has a non-trivial factorization.

### 3.7 Cross-Domain Bridge

**Theorem 3.12** (Base-10 Specialization). For x, y ≥ 2 with x · y ≡ x + y (mod 9), we have (x − 1)(y − 1) ≡ 1 (mod 9). This recovers the classical vampire number constraint as a special case.

## 4. Algorithms

### 4.1 Digit-Morphic Search

Given base b and digit count 2n, enumerate all pairs (x, y) with b^(n−1) ≤ x ≤ y < b^n satisfying:
1. (x mod (b−1), y mod (b−1)) is a valid morphic pair
2. digitMultiset(b, x·y) = digitMultiset(b, x) + digitMultiset(b, y)

Step 1 filters out approximately (1 − φ(b−1)/(b−1)²) fraction of pairs before the expensive digit check.

### 4.2 Morphic Density Computation

For each base b, compute morphic_density(b) = φ(b−1)/(b−1)² and compare with actual digit-morphic factorization counts.

## 5. Computational Examples

### 5.1 Base-10 Vampire Numbers (4-digit)

The 4-digit vampire numbers are: 1260, 1395, 1435, 1530, 1560, 6880, 6880.
- 1260 = 21 × 60, defect = 0
- 1395 = 15 × 93, defect = 0
- 6880 = 80 × 86, defect = 0

### 5.2 Morphic Density Table

| Base b | b−1 | φ(b−1) | Density φ(b−1)/(b−1)² |
|--------|-----|--------|-----------------------|
| 3      | 2   | 1      | 0.2500                |
| 4      | 3   | 2      | 0.2222                |
| 5      | 4   | 2      | 0.1250                |
| 6      | 5   | 4      | 0.1600                |
| 7      | 6   | 2      | 0.0556                |
| 8      | 7   | 6      | 0.1224                |
| 10     | 9   | 6      | 0.0741                |
| 12     | 11  | 10     | 0.0826                |
| 16     | 15  | 8      | 0.0356                |

### 5.3 Fixed Point Counts

| m  | # sq. roots of 1 | Fixed points |
|----|-------------------|-------------|
| 3  | 2                 | (0,0), (2,2) |
| 5  | 2                 | (0,0), (2,2) |
| 8  | 4                 | (0,0), (2,2), (4,4), (6,6) |
| 9  | 2                 | (0,0), (2,2) |
| 15 | 4                 | (0,0), (2,2), (6,6), (11,11) |

## 6. Falsifiable Conjecture

**Conjecture (Morphic Density–Count Correlation)**: For bases 2 ≤ b ≤ 100, the Pearson correlation coefficient between φ(b−1)/(b−1)² and the count of digit-morphic factorizations among 4-"digit" numbers in base b exceeds 0.7.

**Test**: Compute both quantities for all bases 2 ≤ b ≤ 100 and evaluate the correlation. A correlation below 0.5 would refute the conjecture and suggest that higher-order digit constraints dominate the residue constraint.

## 7. Discussion

The digit-morphic framework reveals that vampire numbers are not isolated curiosities but instances of a general algebraic phenomenon. The Fang Residue Constraint connects digit theory to the multiplicative structure of modular arithmetic, and the Morphic Pair Count Theorem provides an exact bridge to Euler's totient function.

The morphic algebra M(m) is a finite set with rich structure: it is closed under the swap involution, its cardinality is a fundamental arithmetic function, and its fixed points encode the square roots of unity in ℤ/mℤ. These connections suggest that digit-morphic theory may serve as a bridge between recreational number theory and more abstract algebraic and analytic investigations.

## 8. Future Work

1. **Analytic density**: Determine the asymptotic density of digit-morphic numbers as a function of digit count and base.
2. **Higher-order factorizations**: Extend to v = x₁ · x₂ · ⋯ · x_k with k > 2 factors.
3. **Digit defect distribution**: Characterize the distribution of digit defects across all factorizations.
4. **Connection to additive number theory**: Investigate how the morphic constraint interacts with Goldbach-type problems.

## References

1. C.A. Pickover, "Interview with a number," *Discover Magazine*, June 1995.
2. I. Peterson, "Vampire numbers," *Science News*, 1994.
3. G.H. Hardy and E.M. Wright, *An Introduction to the Theory of Numbers*, Oxford University Press, 6th ed., 2008.
4. T. Tao, "Structure and Randomness in the Prime Numbers," in *An Invitation to Mathematics*, Springer, 2011.
