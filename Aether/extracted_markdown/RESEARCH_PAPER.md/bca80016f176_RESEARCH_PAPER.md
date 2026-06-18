# Covering Systems and the Sierpiński Problem: A Formalized Theory

## Abstract

We develop a formal theory of covering systems and their application to Sierpiński numbers, implemented and verified in Lean 4 with Mathlib. A **covering system** is a finite collection of arithmetic progressions that covers all natural numbers. A **Sierpiński number** is an odd integer *k* > 1 such that *k* · 2ⁿ + 1 is composite for every positive integer *n*. We formalize the key structural theorem connecting these concepts: if *k* admits a *Sierpiński witness* — a covering system paired with primes satisfying divisibility and multiplicative order conditions — then *k* is a Sierpiński number. We also prove that the density sum of any covering system is at least 1, that covering multiplicity is periodic, and that Selfridge's conjecture (78557 is the smallest Sierpiński number) implies minimality. Our formalization includes novel definitions of covering density and multiplicity that enable quantitative analysis of covering systems.

**Keywords**: Sierpiński numbers, covering systems, Chinese Remainder Theorem, Proth numbers, formal verification, Lean 4

## 1. Introduction

In 1960, Wacław Sierpiński proved a remarkable result: there exist infinitely many odd positive integers *k* such that *k* · 2ⁿ + 1 is composite for *every* positive integer *n*. Such integers are called **Sierpiński numbers**. The proof relies on an elegant combinatorial-algebraic construction involving **covering systems** — finite collections of arithmetic progressions that cover all integers.

Two years later, John Selfridge identified 78557 as a specific Sierpiński number and conjectured it to be the smallest. This conjecture — the **Sierpiński problem** — remains one of the most famous open problems in computational number theory, with the distributed computing project "Seventeen or Bust" (and its successor PrimeGrid) having eliminated all but five candidates below 78557.

In this paper, we develop a formal theory that:

1. Defines covering systems, Sierpiński numbers, and the witness structure connecting them.
2. Proves the main theorem: a valid witness implies the Sierpiński property.
3. Establishes structural results about covering systems, including the density bound ∑ 1/mᵢ ≥ 1.
4. Formalizes the connection between covering periodicity and the Chinese Remainder Theorem.

## 2. Covering Systems

### 2.1. Definition

A **covering system** is a finite collection {(*r*₁, *m*₁), ..., (*r*ₛ, *m*ₛ)} of pairs where each *mᵢ* > 0 and *rᵢ* < *mᵢ*, satisfying the **covering property**: for every natural number *n*, there exists some *i* with *n* ≡ *rᵢ* (mod *mᵢ*).

Our formalization captures this as a Lean structure:

```
structure CoveringSystem where
  size : ℕ
  size_pos : 0 < size
  residue : Fin size → ℕ
  modulus : Fin size → ℕ
  modulus_pos : ∀ i, 0 < modulus i
  residue_lt : ∀ i, residue i < modulus i
  covers : ∀ n : ℕ, ∃ i, n % modulus i = residue i
```

### 2.2. Density Sum

We define the **density sum** of a covering system as:

$$\delta(C) = \sum_{i=1}^{s} \frac{1}{m_i}$$

This quantity measures the total "coverage density." For an exact covering (where every integer is covered exactly once), δ = 1.

**Theorem 1** (Density Bound). *For any covering system C, δ(C) ≥ 1.*

*Proof sketch.* Let *L* = ∏ *mᵢ*. Each modulus divides *L*, so among {0, 1, ..., *L* − 1}, the class (*rᵢ*, *mᵢ*) covers exactly *L*/*mᵢ* elements. Since every element is covered, *L* ≤ ∑ *L*/*mᵢ*, giving 1 ≤ ∑ 1/*mᵢ*. □

### 2.3. Covering Multiplicity

The **covering multiplicity** at *n* is the number of congruence classes containing *n*:

$$\mu_C(n) = |\{i : n \equiv r_i \pmod{m_i}\}|$$

**Theorem 2** (Positive Multiplicity). *For any covering system C and any n ∈ ℕ, μ_C(n) ≥ 1.*

This follows immediately from the covering property.

### 2.4. Periodicity and the Chinese Remainder Theorem

**Theorem 3** (Coverage Periodicity). *Let C be a covering system and L a common multiple of all moduli. If n₁ ≡ n₂ (mod L), then n₁ and n₂ are covered by exactly the same classes.*

*Proof.* If *mᵢ* | *L* and *n*₁ ≡ *n*₂ (mod *L*), then *n*₁ ≡ *n*₂ (mod *mᵢ*). Hence *n*₁ ≡ *rᵢ* (mod *mᵢ*) iff *n*₂ ≡ *rᵢ* (mod *mᵢ*). □

**Corollary** (Multiplicity Periodicity). *Under the same conditions, μ_C(n₁) = μ_C(n₂).*

This periodicity is the structural manifestation of the Chinese Remainder Theorem: the covering pattern is completely determined by its behavior on one period [0, *L*), and the CRT decomposes this period into local conditions modulo each *mᵢ*.

## 3. Sierpiński Numbers

### 3.1. Definition

An odd integer *k* > 1 is a **Sierpiński number** if *k* · 2ⁿ + 1 is composite for all *n* ≥ 1.

### 3.2. The Witness Structure

A **Sierpiński witness** for *k* consists of:
- A covering system {(*rᵢ*, *mᵢ*)}
- Primes {*p*₁, ..., *p*ₛ} such that:
  1. *pᵢ* | *k* · 2^(*rᵢ*) + 1 (divisibility)
  2. ord_{*pᵢ*}(2) | *mᵢ* (order condition)
  3. *pᵢ* < *k* · 2 + 1 (bound)

### 3.3. Key Algebraic Lemma

**Theorem 4** (Power Periodicity). *If p is prime and ord_p(2) | m, then for all n, 2ⁿ ≡ 2^(n mod m) (mod p).*

*Proof.* Write *n* = *qm* + *r* where *r* = *n* mod *m*. Then 2ⁿ = 2^(*qm* + *r*) = (2^*m*)^*q* · 2^*r*. Since ord_*p*(2) | *m*, we have 2^*m* ≡ 1 (mod *p*), so 2ⁿ ≡ 1^*q* · 2^*r* = 2^*r* (mod *p*). □

### 3.4. Main Theorem

**Theorem 5** (Sierpiński Witness Theorem). *If k > 1 is odd and admits a Sierpiński witness, then k is a Sierpiński number.*

*Proof.* Given *n* ≥ 1, we show *k* · 2ⁿ + 1 is not prime.

1. By the covering property, there exists *i* with *n* ≡ *rᵢ* (mod *mᵢ*).
2. By Theorem 4, 2ⁿ ≡ 2^(*rᵢ*) (mod *pᵢ*).
3. Therefore *pᵢ* | *k* · 2ⁿ + 1 (transferring from the divisibility condition).
4. Since *pᵢ* < *k* · 2 + 1 ≤ *k* · 2ⁿ + 1 (as 2ⁿ ≥ 2 for *n* ≥ 1), the factor *pᵢ* is proper.
5. Since *pᵢ* is prime (hence > 1) and *pᵢ* < *k* · 2ⁿ + 1, the number *k* · 2ⁿ + 1 cannot be prime. □

## 4. The Sierpiński Problem

### 4.1. Selfridge's Conjecture

In 1962, Selfridge showed that 78557 is a Sierpiński number using the covering system:

| Class *i* | Residue *rᵢ* | Modulus *mᵢ* | Prime *pᵢ* | ord_{*pᵢ*}(2) |
|:---------:|:----------:|:----------:|:--------:|:------------:|
| 1         | 0          | 2          | 3        | 2            |
| 2         | 1          | 4          | 5        | 4            |
| 3         | 1          | 3          | 7        | 3            |
| 4         | 11         | 12         | 13       | 12           |
| 5         | 15         | 18         | 19       | 18           |
| 6         | 27         | 36         | 37       | 36           |
| 7         | 3          | 9          | 73       | 9            |

He conjectured that 78557 is the *smallest* Sierpiński number.

**Theorem 6** (Conditional Minimality). *If Selfridge's conjecture holds and 78557 is Sierpiński, then 78557 is the smallest Sierpiński number.*

### 4.2. Current Status

The distributed computing projects "Seventeen or Bust" and PrimeGrid have eliminated all but five candidates below 78557:

- **21181**: No prime *k* · 2ⁿ + 1 found for *n* ≤ 10⁷
- **22699**: No prime found
- **24737**: No prime found
- **55459**: No prime found
- **67607**: No prime found

Each candidate requires finding just one *n* making *k* · 2ⁿ + 1 prime to eliminate it.

## 5. Algorithms

### 5.1. Witness Verification

Given a candidate witness (*C*, {*pᵢ*}) for *k*, verification requires:
1. Checking the covering property (finite check over [0, lcm(*mᵢ*)))
2. Verifying primality of each *pᵢ*
3. Checking divisibility *pᵢ* | *k* · 2^(*rᵢ*) + 1
4. Computing and checking ord_{*pᵢ*}(2) | *mᵢ*
5. Verifying the bound *pᵢ* < 2*k* + 1

### 5.2. Covering System Construction

Constructing a covering system for a given *k* is more challenging:
1. Enumerate candidate primes *p* dividing some *k* · 2^*r* + 1
2. For each prime, compute ord_*p*(2) to determine the modulus
3. Use greedy or backtracking search to find a subset whose residue classes cover ℕ

This is related to set cover, which is NP-hard in general, though the structure of modular arithmetic provides significant constraints.

## 6. Discussion

### 6.1. Formalization Insights

The formalization revealed several subtle points:

1. **Type coercions**: The proof of Theorem 5 requires careful translation between ℕ divisibility and ZMod arithmetic. The key bridge is `ZMod.natCast_eq_zero_iff`.

2. **Order theory in ZMod**: The `orderOf` function in Lean operates on the multiplicative monoid of `ZMod p`. For prime *p*, this gives the correct multiplicative order.

3. **The bound condition**: The condition *pᵢ* < 2*k* + 1 is necessary to exclude the possibility that *k* · 2ⁿ + 1 = *pᵢ* (which would make it prime, not composite).

### 6.2. The Density Perspective

The density bound ∑ 1/*mᵢ* ≥ 1 has a beautiful probabilistic interpretation: if we select a random integer, each class (*rᵢ*, *mᵢ*) "captures" it with probability 1/*mᵢ*. The covering property requires the total capture probability to be at least 1.

For the 78557 covering system, the density sum is:
$$\frac{1}{2} + \frac{1}{4} + \frac{1}{3} + \frac{1}{12} + \frac{1}{18} + \frac{1}{36} + \frac{1}{9} ≈ 1.361$$

The excess over 1 indicates overlap between classes — about 36% of integers are covered by two classes simultaneously.

## 7. Future Work

1. **Constructive witness for 78557**: Formalize the specific covering system and primes that make 78557 Sierpiński.
2. **Lower bounds on covering system size**: Prove that any Sierpiński witness requires at least some minimum number of classes.
3. **Connections to Riesel numbers**: Develop parallel theory for *k* · 2ⁿ − 1.
4. **Hough's theorem**: Formalize the result that covering systems with distinct moduli have a bounded minimum modulus.

## 8. References

1. Sierpiński, W. "Sur un problème concernant les nombres k · 2ⁿ + 1." *Elem. Math.* 15 (1960), 73-74.
2. Selfridge, J. L. Solution of problem 4995. *Amer. Math. Monthly* 70 (1963), 101.
3. Erdős, P. "On integers of the form 2^k + p and some related problems." *Summa Brasil. Math.* 2 (1950), 113-123.
4. Hough, R. D. "Solution of the minimum modulus problem for covering systems." *Annals of Mathematics* 181 (2015), 361-382.
5. Filaseta, M., Finch, C., Kozek, M. "On powers associated with Sierpiński numbers, Riesel numbers and Polignac's conjecture." *J. Number Theory* 128 (2008), 1916-1940.
