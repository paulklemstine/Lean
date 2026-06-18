# Prime Gap Crossword: Modular Constraints, Forcing Patterns, and the Sieve-Theoretic Structure of Consecutive Prime Differences

## Abstract

We develop a systematic framework for analyzing prime gap sequences through modular constraints imposed by small primes. We introduce the *Gap Constraint System*, an algebraic structure that captures how sieve primes restrict admissible gap patterns, and the *Residue Exclusion Chain*, which tracks the multiplicative composition of these restrictions. Our main results include: (1) a complete characterization of the gap pattern [2,2] as uniquely realized by the triple (3,5,7), via a pigeonhole argument modulo 3; (2) a proof that prime gaps beyond the first are constrained to residues {0, 2, 4} modulo 6; (3) a generalization showing that three-term arithmetic progressions of primes with common difference d require 3 | d unless a term equals 3; (4) a quantitative residue exclusion principle showing that coprime counts compose multiplicatively as predicted by Euler's totient function; and (5) a formalization of Bertrand's postulate for primes giving explicit gap upper bounds. All results are machine-verified in Lean 4 with Mathlib. We formulate the *Crossword Determinism Conjecture*, a falsifiable prediction about the bounded admissibility of next-gap values under sieve constraints.

## 1. Introduction

The prime gap sequence $g(n) = p_{n+1} - p_n$ has been studied since Euler, yet its fine structure remains mysterious. While the prime number theorem gives the asymptotic average gap as $\log p_n$, the distribution of individual gaps is governed by a web of modular constraints that are only partially understood.

We propose viewing the prime gap sequence as a *crossword puzzle*: each gap constrains its neighbors through shared modular arithmetic. The "cells" are the primes, the "clues" are the modular constraints imposed by small primes, and the "solutions" are the admissible gap sequences.

### 1.1 Main Contributions

1. **Gap Constraint System** (Definition 1): An algebraic framework capturing modular restrictions on gap sequences, parameterized by a modulus $M$ and a set of sieve primes dividing $M$.

2. **Prime Triple Theorem** (Theorem 1): The gap pattern [2,2] occurs exactly once, at the triple (3,5,7). This is proved by pigeonhole modulo 3.

3. **Gap Mod 6 Constraint** (Theorem 2): For primes $p > 3$, consecutive gaps satisfy $(q-p) \bmod 6 \in \{0, 2, 4\}$.

4. **Generalized Triple Constraint** (Theorem 3): If $p$, $p+2d$, $p+4d$ are all prime with $d > 0$, then $3 \mid d$ or one of the terms equals 3.

5. **Exclusion Composition** (Theorem 4): For distinct primes $p, q$, the number of residues mod $pq$ coprime to both equals $(p-1)(q-1)$, confirming the multiplicative sieve.

6. **Bertrand for Primes** (Theorem 5): Every prime $p$ has a prime strictly between $p$ and $2p$.

7. **Crossword Determinism Conjecture** (Conjecture 1): Under mod-30 sieve constraints, the number of admissible next-gap values is uniformly bounded.

## 2. Definitions

### Definition 1 (Gap Constraint System)
A *Gap Constraint System* of modulus $M$ consists of:
- A finite set $S$ of *sieve primes*, each dividing $M$
- The constraint that $M > 0$

This structure encodes which gap residues modulo $M$ are admissible from a given starting residue class.

### Definition 2 (Residue Exclusion Chain)
A *Residue Exclusion Chain* is a sequence of primes $q_1, q_2, \ldots, q_k$ together with a survival count function tracking how many residue classes survive after sieving by the first $i$ primes. For a single prime $q$, the survival count is $q - 1$ out of $q$ (Theorem 6). For two distinct primes $p, q$, it is $(p-1)(q-1)$ out of $pq$ (Theorem 4).

### Definition 3 (Primorial)
The *primorial* of $n$, denoted $n\#$, is the product of all primes up to $n$:
$$n\# = \prod_{\substack{p \leq n \\ p \text{ prime}}} p$$

### Definition 4 (Crossword Determinism)
We say the prime gap sequence exhibits *crossword determinism* if there exists a constant $C$ such that for every prime $p > 30$ and every gap history of length $\geq 5$, the number of even gaps $g \in [2, 30]$ with $\gcd(p+g, 30) = 1$ is at most $C$.

## 3. Main Results

### 3.1 The Prime Triple Theorem

**Theorem 1.** *If $p$, $p+2$, and $p+4$ are all prime, then $p = 3$.*

*Proof.* Among any three integers $n, n+2, n+4$, their residues modulo 3 are $n, n+2, n+1$ (modulo 3), which are three distinct residue classes. Therefore exactly one of $n, n+2, n+4$ is divisible by 3. If all three are prime, the one divisible by 3 must equal 3 (the only prime divisible by 3). This forces $n \in \{3, 1, -1\}$, and since $n$ is prime, $n = 3$. $\square$

**Corollary 1.** *The gap pattern [2, 2] uniquely identifies the prime triple $(3, 5, 7)$.*

### 3.2 Gap Mod 6 Constraint

**Theorem 2.** *For primes $p, q$ with $3 < p < q$, we have $(q - p) \bmod 6 \in \{0, 2, 4\}$.*

*Proof.* Since $p, q > 3$ are prime, they are odd and not divisible by 3, so $p \bmod 6 \in \{1, 5\}$ and $q \bmod 6 \in \{1, 5\}$. The difference $q - p$ modulo 6 is then one of $0 = 1-1$, $4 = 5-1$, $2 = 1-5+6$, or $0 = 5-5$, all of which lie in $\{0, 2, 4\}$. $\square$

### 3.3 Three-Prime Span Theorem

**Theorem 3 (Span Characterization).** *For primes $p < q < r$ with $p > 3$, the span $r - p \equiv 0 \pmod{6}$ if and only if $p \equiv r \pmod{6}$.*

*Proof.* Since both $p, r > 3$ are prime, $p \bmod 6, r \bmod 6 \in \{1, 5\}$. The equivalence $r - p \equiv 0 \iff r \equiv p$ follows from $p < r$. $\square$

**Theorem 4 (Gap Pair Bound).** *For three consecutive primes $p < q < r$ with $p > 3$, the span $r - p$ is even and $r - p \geq 4$.*

### 3.4 Generalized Triple Constraint

**Theorem 5.** *If $p$, $p + 2d$, $p + 4d$ are all prime with $d > 0$, then $3 \mid d$ or one of $\{p, p+2d, p+4d\} = 3$.*

*Proof.* If $3 \nmid d$, then $\{p \bmod 3, (p+2d) \bmod 3, (p+4d) \bmod 3\} = \{0, 1, 2\}$ by the same pigeonhole argument as Theorem 1 (since $2d \not\equiv 0 \pmod{3}$). One of the three terms is divisible by 3, hence equals 3 if prime. $\square$

### 3.5 Residue Exclusion Principle

**Theorem 6 (Coprime Count).** *For prime $q$, the number of residues in $\{0, \ldots, q-1\}$ coprime to $q$ is $q - 1$.*

This is equivalent to $\varphi(q) = q - 1$ for prime $q$.

**Theorem 7 (Exclusion Composition).** *For distinct primes $p, q$:*
$$|\{r \in \{0, \ldots, pq-1\} : \gcd(r, p) = 1 \text{ and } \gcd(r, q) = 1\}| = (p-1)(q-1)$$

*Proof.* The condition $\gcd(r, p) = 1 \wedge \gcd(r, q) = 1$ is equivalent to $\gcd(r, pq) = 1$ since $\gcd(p, q) = 1$. The count therefore equals $\varphi(pq) = \varphi(p)\varphi(q) = (p-1)(q-1)$. $\square$

### 3.6 Bertrand's Postulate for Primes

**Theorem 8.** *For every prime $p$, there exists a prime $q$ with $p < q < 2p$.*

*Proof.* By Bertrand's postulate, for $p \geq 1$ there exists a prime $q$ with $p < q \leq 2p$. If $q = 2p$, then $q$ is even and greater than 2, hence not prime — contradiction. So $q < 2p$. $\square$

## 4. The Crossword Determinism Conjecture

**Conjecture 1.** *There exists a constant $C \leq 8$ such that for every prime $p > 30$ and every gap history of length $\geq 5$, the number of even values $g \in [2, 30]$ with $\gcd(p + g, 30) = 1$ is at most $C$.*

### 4.1 Testable Predictions

1. **Computational test**: For all primes $p$ up to $10^8$, compute the number of admissible next gaps modulo 30. The conjecture predicts this count is at most 8.

2. **Equidistribution test**: Among primes up to $10^8$, the fractions of gaps with residue 0, 2, and 4 modulo 6 should each be approximately $1/3$.

3. **Forcing frequency**: Among all primes up to $10^8$, what fraction have their next gap uniquely determined by mod-30 sieve constraints? The conjecture predicts this fraction is positive.

## 5. Algorithms

### Algorithm 1: Sieve-Based Gap Classification

```
Input: bound N
Output: gap classification table

1. Sieve primes up to N using Sieve of Eratosthenes
2. For each consecutive prime pair (p, q):
   a. Compute gap g = q - p
   b. Classify g mod 6 ∈ {0, 2, 4}
   c. Count admissible next gaps mod 30
3. Return frequency tables
```

### Algorithm 2: Forcing Pattern Detection

```
Input: sieve set S, gap bound B, history length k
Output: all forcing patterns of length k

1. Enumerate all gap words w of length k with entries in [2, B] ∩ 2ℤ
2. For each word w:
   a. For each candidate next gap g ∈ [2, B] ∩ 2ℤ:
      - Check if w ++ [g] is S-admissible (has a valid starting residue)
   b. If exactly one g passes: output w as forcing with forced gap g
3. Return all forcing patterns
```

## 6. Discussion

### 6.1 Connection to Cryptography

The structure of prime gaps has direct implications for cryptographic prime generation. In RSA key generation, one searches for primes of a specified bit length. The gap structure determines:

- **Expected search time**: proportional to the average gap, which is $O(\log p)$ by PNT.
- **Worst-case search time**: bounded by the maximum gap, conjectured to be $O((\log p)^2)$ by Cramér.
- **Exploitable patterns**: if gap sequences exhibit forcing, an adversary might predict the location of cryptographic primes from partial information.

### 6.2 Connection to the Hardy-Littlewood Conjecture

The Hardy-Littlewood conjecture predicts the density of prime $k$-tuples. Our results provide rigorous lower-level constraints that any valid prime tuple must satisfy. The Generalized Triple Constraint (Theorem 5) is a consequence of the Hardy-Littlewood admissibility condition restricted to three-term arithmetic progressions.

### 6.3 Limitations

Our results are *unconditional* — they follow from elementary number theory and Bertrand's postulate. The deeper questions about gap distribution (e.g., the twin prime conjecture, Cramér's conjecture) remain open and likely require analytic methods beyond our algebraic framework.

## 7. Future Work

1. Extend the forcing analysis to larger sieve sets ({2,3,5,7,...}) and characterize the growth rate of forcing patterns.
2. Connect the Gap Constraint System to the Hardy-Littlewood circle method for quantitative predictions.
3. Investigate the automaton-theoretic structure of gap sequences modulo primorials.
4. Explore applications to provably secure prime generation in post-quantum cryptography.

## References

1. Cramér, H. (1936). On the order of magnitude of the difference between consecutive prime numbers. *Acta Arithmetica*, 2(1), 23-46.
2. Green, B., & Tao, T. (2008). The primes contain arbitrarily long arithmetic progressions. *Annals of Mathematics*, 167(2), 481-547.
3. Hardy, G. H., & Littlewood, J. E. (1923). Some problems of 'Partitio numerorum'; III: On the expression of a number as a sum of primes. *Acta Mathematica*, 44, 1-70.
4. Maynard, J. (2015). Small gaps between primes. *Annals of Mathematics*, 181(1), 383-413.
5. Granville, A. (1995). Harald Cramér and the distribution of prime numbers. *Scandinavian Actuarial Journal*, 1, 12-28.
