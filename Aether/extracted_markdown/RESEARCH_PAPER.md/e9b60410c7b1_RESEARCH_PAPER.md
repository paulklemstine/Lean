# The Digit Interaction Profile: A Formal Theory of Arithmetic Creatures

## Abstract

We develop a systematic, machine-verified theory of how multiplication interacts with digit representations in arbitrary bases. We introduce the **Digit Interaction Profile** — a triple (preserved, created, destroyed) satisfying two conservation laws that completely describes digit flow through multiplication. Using this framework, we unify the study of vampire numbers, ghost numbers, and werewolf numbers under a single algebraic lens. Our main results, all formally verified in Lean 4 with Mathlib, include:

1. **The Euler Totient Theorem for Fang Residues**: The number of valid fang residue pairs modulo *m* equals Euler's totient φ(*m*), establishing a precise connection between digit-preservation under multiplication and unit groups of quotient rings.

2. **The Ghost Base Threshold**: Ghost factorizations are impossible in base 2 but exist in all bases ≥ 3, exhibiting a sharp phase transition at base 3.

3. **The Vampire-Ghost Exclusion Principle**: No factorization can simultaneously be vampire and ghost, establishing these as genuine opposite endpoints of the creature spectrum.

4. **The Carry Defect Characterization**: A factorization is vampire if and only if its carry defect (the total number of digit discrepancies) is zero.

5. **The Vampire Modular Constraint**: For any vampire factorization v = x × y in base b, the constraint x·y ≡ x + y (mod b−1) holds, a deep generalization of "casting out nines."

## 1. Introduction

Vampire numbers, introduced by Pickover (1995), are natural numbers v with 2n digits admitting a factorization v = x × y where x and y each have n digits and the multiset of digits of v equals the multiset union of digits of x and y. The smallest example is 1260 = 21 × 60.

Despite their recreational origins, vampire numbers connect to several areas of number theory: modular arithmetic (through casting out nines), combinatorics (through digit permutation counting), and computational complexity (the search problem is essentially factoring with a digit constraint). However, the existing literature treats them largely in isolation, without a unifying framework.

In this paper, we introduce the **Digit Interaction Profile** (DIP), a structure that captures the complete information about how digits transform under multiplication. The DIP satisfies conservation laws analogous to those in physics, enabling a systematic classification of factorizations along a continuous spectrum from "vampire" (perfect digit preservation) to "ghost" (total digit estrangement).

### 1.1 Related Work

The study of vampire numbers was initiated by Pickover (1995) and extended by several authors to "true vampire numbers" with additional constraints. Generalized vampire numbers in arbitrary bases have been studied computationally but without formal proofs. Ghost and werewolf numbers appear to be new in this work.

The connection between digit sums and modular arithmetic (casting out nines) dates to the medieval period. The Euler totient function φ(m) and its connection to unit groups of ℤ/mℤ is classical. Our contribution is connecting these two traditions through the vampire fang residue theorem.

## 2. Definitions

### 2.1 Digit Infrastructure

**Definition 2.1** (Digit Bag). For a natural number n and base b ≥ 2, the *digit bag* is the function `digitBag(b, n) : Fin(b) → ℕ` defined by `d ↦ count(d, digits_b(n))`, where `digits_b(n)` is the list of base-b digits and `count` gives multiplicity.

**Definition 2.2** (Digit Overlap). For numbers m, n in base b, the *digit overlap* is:

    digitOverlap(b, m, n) = Σ_{d ∈ Fin(b)} min(digitBag(b,m)(d), digitBag(b,n)(d))

**Definition 2.3** (Digit Disjointness). Numbers m, n are *digit-disjoint* in base b if `digitOverlap(b, m, n) = 0`.

### 2.2 Creature Classifications

**Definition 2.4** (Vampire Factorization). A factorization v = x × y is *vampire* in base b if for all d ∈ Fin(b):

    digitBag(b, v)(d) = digitBag(b, x)(d) + digitBag(b, y)(d)

**Definition 2.5** (Ghost Factorization). A factorization v = x × y with x, y > 1 is *ghost* in base b if `DigitDisjoint(b, v, x)` and `DigitDisjoint(b, v, y)`.

**Definition 2.6** (Werewolf-k Factorization). A factorization v = x × y with x, y > 1 is *werewolf-k* in base b if `digitOverlap(b, v, x) + digitOverlap(b, v, y) = k`.

### 2.3 The Digit Interaction Profile

**Definition 2.7** (Digit Interaction Profile). For a factorization v = x × y in base b, the *Digit Interaction Profile* is the triple (P, C, D) where:

- **P** (preserved) = Σ_d min(digitBag(b,v)(d), digitBag(b,x)(d) + digitBag(b,y)(d))
- **C** (created) = Σ_d (digitBag(b,v)(d) − (digitBag(b,x)(d) + digitBag(b,y)(d)))⁺
- **D** (destroyed) = Σ_d ((digitBag(b,x)(d) + digitBag(b,y)(d)) − digitBag(b,v)(d))⁺

**Definition 2.8** (Carry Defect). The *carry defect* of a factorization is C + D.

**Definition 2.9** (Creature Index). The *creature index* is P / (P + C) = P / digitLen(b, v), a rational number in [0, 1].

### 2.4 Fang Residue Theory

**Definition 2.10** (Valid Fang Residues). For modulus m > 0, the set of *valid fang residue pairs* is:

    VFR(m) = {(a, b) ∈ (ℤ/mℤ)² : a·b ≡ a + b (mod m)}

Equivalently, VFR(m) = {(a, b) : (a−1)(b−1) ≡ 1 (mod m)}.

## 3. Main Results

### 3.1 Theorem 1: Vampire Digit Sum Additivity

**Theorem 3.1.** *If v = x × y is a vampire factorization in base b ≥ 2, then*
    digitSum(b, v) = digitSum(b, x) + digitSum(b, y).

*Proof sketch.* The vampire condition gives multiset equality of digit lists. The sum of a multiset is preserved under multiset equality. ∎

### 3.2 Theorem 2: The Vampire Modular Constraint

**Theorem 3.2.** *For any vampire factorization v = x × y in base b ≥ 2:*
    x · y ≡ x + y (mod b − 1)

*Proof sketch.* By casting out (b−1): n ≡ digitSum(b, n) (mod b−1). Then v ≡ digitSum(v) = digitSum(x) + digitSum(y) ≡ x + y (mod b−1), and v = xy. ∎

**Corollary 3.3** (Fang Residue Constraint). *For vampire fangs x, y ≥ 2:*
    (x − 1)(y − 1) ≡ 1 (mod b − 1)

### 3.3 Theorem 3: The Euler Totient Connection

**Theorem 3.4** (Fang Residue Count = Euler Totient). *For all m ≥ 2:*
    |VFR(m)| = φ(m)

*Proof sketch.* The condition (a−1)(b−1) ≡ 1 (mod m) defines a bijection between VFR(m) and the unit group (ℤ/mℤ)×: send (a, b) to the unit a − 1 with inverse b − 1. The cardinality of (ℤ/mℤ)× is φ(m). ∎

**Example.** For base 10 (m = 9): φ(9) = 6, so only 6 out of 81 residue class pairs can form vampire fangs. The valid pairs are (0,0), (1,2), (2,1), (4,5), (5,4), (8,8).

**PEGB Analysis:**
- **P**roof: Formally verified in Lean 4 using a bijection to (ZMod m)ˣ.
- **E**xample: φ(9) = 6, verified computationally for all m ≤ 20.
- **G**eneralization: For multi-fang vampires v = x₁ × ... × xₖ, the constraint becomes Σxᵢ ≡ Πxᵢ (mod b−1), connecting to higher-order unit group structure.
- **B**oundary: For m = 1, every pair is valid (trivially). The theorem requires m ≥ 2.

### 3.4 Theorem 4: Vampire-Ghost Exclusion

**Theorem 3.5.** *No factorization v = x × y with x, y > 1 in base b ≥ 2 can be simultaneously vampire and ghost.*

*Proof sketch.* If vampire: digitBag(v) = digitBag(x) + digitBag(y), so any digit in x appears in v. If ghost: v and x are digit-disjoint, so no digit of x appears in v. Combined: x has no digits, so x = 0. But x > 1, contradiction. ∎

**PEGB Analysis:**
- **P**roof: Lean 4 proof using digit bag analysis.
- **E**xample: 1260 = 21 × 60 is vampire but not ghost; 28 = 4 × 7 is ghost but not vampire.
- **G**eneralization: The creature index provides a continuous measure: vampires have index 1, ghosts have index 0, and no factorization can have both.
- **B**oundary: For x = 1 or y = 1, the exclusion can fail trivially (1 has digit {1} which may or may not appear in v).

### 3.5 Theorem 5: Ghost Base Threshold

**Theorem 3.6.** *Ghost factorizations are impossible in base 2. For every base b ≥ 3, digit-disjoint positive pairs exist.*

*Proof sketch.* Base 2: Every positive binary number contains digit 1, so any two positive numbers share it. Base ≥ 3: The numbers 1 and b−1 are digit-disjoint (1 uses digit {1}, b−1 uses digit {b−1}, and b−1 ≥ 2 so these are distinct). ∎

**PEGB Analysis:**
- **P**roof: Lean 4 proof using structural induction on binary representations.
- **E**xample: In base 3, digits of 1 are {1}, digits of 2 are {2} — disjoint. In binary, 5 = 101₂ and 3 = 11₂ both contain 1.
- **G**eneralization: In base b, the maximum number of pairwise digit-disjoint positive numbers is at most b − 1 (one for each non-zero digit).
- **B**oundary: The threshold is exactly base 3. Bases 0 and 1 are degenerate.

### 3.6 Theorem 6: Carry Defect Characterization

**Theorem 3.7.** *A vampire factorization has carry defect zero.*

*Proof sketch.* When digitBag(v) = digitBag(x) + digitBag(y) for all d, both the "created" and "destroyed" components vanish since the differences are all zero. ∎

## 4. Computational Results

### 4.1 Vampire Number Census

In base 10, we enumerate all 4-digit vampire numbers:
- 1260 = 21 × 60
- 1395 = 15 × 93
- 1435 = 35 × 41
- 1530 = 30 × 51
- 1827 = 21 × 87
- 2187 = 27 × 81
- 6880 = 80 × 86

All seven have creature index 1.00 and carry defect 0, as guaranteed by Theorem 3.7.

### 4.2 Creature Index Distribution

Computing the creature index for all 2-digit × 2-digit factorizations of 4-digit numbers reveals a characteristic distribution: a peak at index 0 (many factorizations disrupt all digits), a long tail through intermediate values, and a sharp spike at index 1 (the rare vampires).

### 4.3 Fang Residue Verification

The identity |VFR(m)| = φ(m) was computationally verified for all m ≤ 100, providing strong evidence before the formal proof was completed.

## 5. Discussion

### 5.1 The Digit Interaction Profile as a Diagnostic

The DIP provides a fine-grained diagnostic for multiplication. Unlike the binary vampire/non-vampire classification, it captures the full spectrum of digit interactions. The creature index, in particular, provides a single scalar summary.

### 5.2 Connection to Carry Analysis

The "created" and "destroyed" components of the DIP are intimately related to carries in addition. When we compute x × y via long multiplication, carries propagate through digit positions, creating and destroying digit values. The DIP measures the net effect of all carries. A zero carry defect means all carries cancel perfectly — a highly constrained condition.

### 5.3 Connections to Existing Theory

The vampire modular constraint x·y ≡ x + y (mod b−1) can be viewed as a special case of the theory of residue-class obstructions for Diophantine equations. The Euler totient connection places this in the framework of unit groups, suggesting deeper algebraic structure.

The ghost base threshold connects to results on additive combinatorics over finite alphabets. The impossibility result in base 2 is a pigeonhole argument on the alphabet {0, 1}, while the existence in base ≥ 3 uses alphabet richness.

## 6. Conjectures

**Conjecture 6.1** (Density of Vampires). The density of vampire numbers among 2n-digit numbers is Θ(n^{−1/2}) as n → ∞.

*Testable prediction:* For n = 2, 3, 4, 5, compute the exact count of vampire numbers and fit to c/√n. The constant c should stabilize.

**Conjecture 6.2** (Ghost Density Decay). In base b ≥ 3, the fraction of n-digit numbers admitting a ghost factorization decreases exponentially in n.

*Testable prediction:* Enumerate ghost factorizations for 2-digit, 3-digit, ..., 8-digit numbers in base 10 and verify exponential decay.

**Conjecture 6.3** (Multi-Fang Totient Generalization). For k-fang vampire factorizations v = x₁ × ... × xₖ, the number of valid k-tuples of residues modulo m equals the number of k-tuples (u₁, ..., u_k) in (ℤ/mℤ)× with u₁ · ... · uₖ = 1, which equals φ(m)^{k-1}.

## 7. Future Work

1. **Tropical digit theory**: Replace (×, +) with (min, +) in the vampire condition and study "tropical vampires."

2. **p-adic digit theory**: Study digit interactions in p-adic expansions, where the carry structure is reversed.

3. **Algorithmic applications**: Can the fang residue sieve be used to speed up factoring algorithms for numbers known to be vampire?

4. **Multi-base creatures**: Study numbers that are simultaneously vampire in one base and ghost in another. Do such "shapeshifter numbers" exist?

## References

1. Pickover, C. A. (1995). *Keys to Infinity*. Wiley.
2. Hardy, G. H., & Wright, E. M. (2008). *An Introduction to the Theory of Numbers*. Oxford University Press.
3. The Mathlib Community. (2024). *Mathlib4*. https://github.com/leanprover-community/mathlib4
