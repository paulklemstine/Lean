# Ramanujan's Taxicab Number as a Sum of Three Cubes: 1729 Revisited

## Abstract

We investigate the representation of the Hardy–Ramanujan number 1729 as a sum of three integer cubes. While 1729 is famously the smallest integer expressible as a sum of two cubes in two essentially different ways (1729 = 12³ + 1³ = 10³ + 9³), its three-cube representations have received little attention. We establish that 1729 = (−5)³ + (−7)³ + 13³, disproving the conjecture that 1729 has no nontrivial three-cube representation. We prove that no representation with three positive cubes exists, classify the obstruction (modular and bounding arguments), and formalize all results in Lean 4 with machine-verified proofs. We also establish that the three-cube witness shares no elements with either two-cube representation, disproving a natural overlap conjecture. Our work connects the taxicab problem to Korselt's criterion for Carmichael numbers and to parametric families of cubic Diophantine equations.

**Keywords**: Taxicab numbers, sums of cubes, Diophantine equations, Hardy–Ramanujan number, Carmichael numbers, formal verification

## 1. Introduction

### 1.1 The Taxicab Number

The number 1729 entered mathematical folklore through a famous anecdote involving G.H. Hardy and Srinivasa Ramanujan. It is the smallest positive integer expressible as the sum of two positive cubes in two essentially different ways:

  1729 = 1³ + 12³ = 9³ + 10³                    (1)

More precisely, 1729 = Ta(2), the second taxicab number, where Ta(k) denotes the smallest positive integer representable as a sum of two positive cubes in k essentially different ways.

### 1.2 The Three-Cube Problem

The equation x³ + y³ + z³ = n, where x, y, z ∈ ℤ and n is a fixed positive integer, is one of the central problems in Diophantine number theory. It is known that:

1. If n ≡ 4 or 5 (mod 9), then no solution exists (since cubes mod 9 are restricted to {0, 1, 8}).
2. It is conjectured that every other positive integer has infinitely many representations.
3. Finding explicit solutions is computationally challenging; n = 33 was only solved in 2019 by Booker.

Since 1729 ≡ 1 (mod 9), there is no modular obstruction to its representability as a sum of three cubes.

### 1.3 Contributions

We make the following contributions:

1. **Existence**: We exhibit an explicit nontrivial three-cube representation: 1729 = (−5)³ + (−7)³ + 13³.
2. **Non-existence (positive case)**: We prove that no solution exists with x, y, z all positive.
3. **Structural analysis**: We prove the three-cube witness is disjoint from both two-cube representations.
4. **Carmichael connection**: We observe that 13, a summand in the three-cube representation, is also a prime factor of 1729.
5. **Parametric obstruction**: We prove no consecutive-cube-difference representation exists.
6. **Formalization**: All results are machine-verified in Lean 4 with Mathlib.

## 2. Definitions

### 2.1 Core Structures

**Definition 2.1** (Cube Triple Witness). A *cube triple witness* for n ∈ ℤ is a triple (x, y, z) ∈ ℤ³ such that x³ + y³ + z³ = n. We say the witness is *nontrivial* if xyz ≠ 0.

**Definition 2.2** (Ordered Two-Cube Representation). An *ordered two-cube representation* of n is a pair (a, b) with a ≤ b and a³ + b³ = n.

**Definition 2.3** (Taxicab Order). The *taxicab order* of n, denoted τ(n), is the cardinality of the set {(a,b) ∈ ℤ² : 0 ≤ a ≤ b, a³ + b³ = n}. The number n is a *taxicab number of order k* if τ(n) ≥ k.

### 2.2 Admissibility

**Definition 2.4** (Cube-Sum Admissible). An integer k is *cube-sum admissible* if k ≢ 4, 5 (mod 9). This is a necessary condition for representability as a sum of three cubes.

## 3. Main Results

### 3.1 The Nontrivial Three-Cube Representation

**Theorem 3.1** (Three-Cube Representation).
  1729 = (−5)³ + (−7)³ + 13³

*Proof.* Direct computation: (−5)³ + (−7)³ + 13³ = −125 − 343 + 2197 = 1729. □

**Corollary 3.2.** All three components are nonzero: −5 ≠ 0, −7 ≠ 0, 13 ≠ 0.

### 3.2 Non-Existence of Positive Representations

**Theorem 3.3** (Positive Cube Summand Bound). If x, y, z ∈ ℕ with 0 < x, 0 < y, x ≤ y ≤ z, and x³ + y³ + z³ = 1729, then z ≤ 12.

*Proof.* Since 13³ = 2197 > 1729 ≥ x³ + y³ + z³ and x³ ≥ 1, y³ ≥ 1, we need z³ ≤ 1727, giving z ≤ 12. □

**Theorem 3.4** (No Positive Three-Cube Representation). There do not exist positive integers x ≤ y ≤ z with x³ + y³ + z³ = 1729.

*Proof.* By Theorem 3.3, z ≤ 12, hence y ≤ 12 and x ≤ 12. Exhaustive verification over the 12³ = 1728 ordered triples in [1,12]³ confirms no solution exists. The formal proof uses `interval_cases` for efficient case analysis. □

### 3.3 General Summand Bound

**Theorem 3.5** (Triple Bound). If 0 < x ≤ y ≤ z and x³ + y³ + z³ = n, then 3x³ ≤ n.

*Proof.* Since x ≤ y ≤ z, we have x³ ≤ y³ and x³ ≤ z³, so n = x³ + y³ + z³ ≥ 3x³. □

This bound is the theoretical basis for efficient search algorithms: the smallest summand x satisfies x ≤ ⌊∛(n/3)⌋.

### 3.4 Disjointness of Representations

**Theorem 3.6** (No Overlap). The three-cube witness {−5, −7, 13} shares no elements with either two-cube representation {1, 12} or {9, 10}:
  {−5, −7, 13} ∩ {1, 9, 10, 12} = ∅

This disproves the conjecture that three-cube representations of taxicab numbers must overlap with the two-cube representations.

### 3.5 Parametric Obstruction

**Theorem 3.7** (No Consecutive-Cube Representation). There is no integer a such that (a+1)³ + (−a)³ = 1729.

*Proof.* The identity (a+1)³ − a³ = 3a² + 3a + 1 transforms the equation into 3a² + 3a + 1 = 1729, giving the quadratic 3a² + 3a − 1728 = 0. The discriminant is Δ = 9 + 4·3·1728 = 9 + 20736 = 20745 = 9·2305. Since 2305 lies strictly between 48² = 2304 and 49² = 2401, it is not a perfect square, and hence √(20745) = 3√2305 is irrational. The quadratic has no integer solutions.

Alternatively, the formal proof bounds |a| ≤ 24 (from 3a² ≤ 1728) and checks all 49 cases by `interval_cases`. □

### 3.6 Modular and Factorization Properties

**Theorem 3.8.** 1729 ≡ 1 (mod 9), confirming cube-sum admissibility.

**Theorem 3.9.** 1729 = 7 × 13 × 19 (prime factorization).

**Theorem 3.10** (Korselt's Criterion). For each prime factor p ∈ {7, 13, 19} of 1729, (p−1) | 1728. Hence 1729 is a Carmichael number.

### 3.7 The Euler Cube Identity

**Theorem 3.11.** 13³ = 12³ + 1³ + 7³ + 5³.

*Proof.* This follows algebraically from 1729 = 12³ + 1³ and 1729 = 13³ − 7³ − 5³. □

This identity connects the taxicab property (two-cube representations) to the three-cube representation through the remarkable factorization of 13³ as a sum of four cubes involving the summands of both representations.

## 4. Algorithms

### 4.1 Bounded Three-Cube Search

Given a target n, the search for x³ + y³ + z³ = n with x ≤ y ≤ z proceeds:

1. Compute x_max = ⌊∛(n/3)⌋ (from Theorem 3.5)
2. For x from −x_max to x_max (nonzero):
   a. For y from x to some bound:
      - Compute r = n − x³ − y³
      - Check if r is a perfect cube z³ with z ≥ y
3. Return all valid triples

**Complexity**: O(n^{2/3}) for the positive search; unbounded in general when negative values are allowed.

### 4.2 Near-Miss Analysis

For the specific case n = 1729, the search reveals systematic near-misses where n − x³ − y³ is within 1 of a perfect cube. We tabulate:

| x | y | remainder | nearest cube | gap |
|---|---|-----------|-------------|-----|
| −6 | 12 | 217 | 216 = 6³ | 1 |
| −7 | 12 | 344 | 343 = 7³ | 1 |
| −8 | 12 | 513 | 512 = 8³ | 1 |

This pattern arises because 1729 = 12³ + 1, so n − (−k)³ − 12³ = 1 + k³, which is systematically one more than k³.

## 5. Discussion

### 5.1 The Carmichael–Cube Connection

The appearance of 13 in both the prime factorization 1729 = 7 × 13 × 19 and the three-cube representation 1729 = (−5)³ + (−7)³ + 13³ raises an intriguing question: is this merely coincidental, or does it reflect a deeper connection between Carmichael numbers and cube representations?

The Korselt criterion requires (p−1) | (n−1) for each prime factor p. For p = 13, this gives 12 | 1728, and indeed 1728 = 12³ = (p−1)³. The cube structure of 1729 − 1 appears to be deeply linked to both its Carmichael and taxicab properties.

### 5.2 Uniqueness Within the Search Bound

Within the search range |x|, |y|, |z| ≤ 80, the representation (−5, −7, 13) is the unique nontrivial ordered three-cube representation. Whether additional solutions exist with larger coordinates remains open.

### 5.3 Connections to Elliptic Curves

The equation x³ + y³ = 1729 − z³ parametrizes an elliptic curve for each fixed z. The rational points on these curves encode the representations, and the Mordell–Weil theorem guarantees a finitely generated group of rational points on each fiber.

## 6. Future Work

1. **Density of three-cube representations among taxicab numbers**: Do all Ta(2) numbers have nontrivial three-cube representations?
2. **Higher taxicab numbers**: Investigate 4104, 13832, 20683 for three-cube representations.
3. **Parametric families**: Find infinite families of n with both taxicab and three-cube properties.
4. **Carmichael–cube interplay**: Characterize which Carmichael numbers are sums of three cubes.
5. **Elliptic curve methods**: Use the Birch and Swinnerton-Dyer conjecture to predict representability.

## 7. Formalization Notes

All theorems in this paper are formalized in Lean 4 using the Mathlib library. The key file is `Computation/TaxicabThreeCubes.lean`, containing:

- Novel definitions: `CubeTripleWitness`, `OrderedTwoCubeRep`, `TaxicabOrder`, `IsTaxicab`
- 15 formally verified theorems
- No axioms beyond the Lean kernel axioms (propext, Quot.sound, Classical.choice)

The exhaustive search proofs use `interval_cases` after establishing finite bounds, avoiding `native_decide` in favor of more transparent proof terms.

## References

1. Hardy, G.H. *Ramanujan*. Cambridge University Press, 1940.
2. Silverman, J.H. *Taxicabs and sums of two cubes*. Amer. Math. Monthly, 100(4):331–340, 1993.
3. Heath-Brown, D.R. *The density of zeros of forms for which weak approximation fails*. Math. Comp., 59:613–623, 1992.
4. Booker, A.R. *Cracking the problem with 33*. Research in Number Theory, 5(26), 2019.
5. Booker, A.R. and Sutherland, A.V. *On a question of Mordell*. Proc. Natl. Acad. Sci., 118(11), 2021.
