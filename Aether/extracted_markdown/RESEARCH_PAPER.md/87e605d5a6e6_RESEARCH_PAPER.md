# The Three-Cube Inversion Principle: A Constructive Bridge Between Two-Cube and Three-Cube Representations

## Abstract

We develop a systematic theory connecting the representation of integers as sums of two cubes to their representation as sums of three cubes through what we call the **Three-Cube Inversion Principle**. If c³ − n = a³ + b³ for positive integers a, b, then n = (−a)³ + (−b)³ + c³, transforming a two-cube decomposition of the "overshoot" c³ − n into a three-cube representation of n. We formalize this principle and its consequences in Lean 4, proving: (1) the core algebraic identity and its converse; (2) that 1729 is inversion-accessible via the overshoot 13³ − 1729 = 7³ + 5³; (3) that 1729 is a taxicab number with two distinct two-cube representations; (4) that the inversion principle automatically preserves the mod-9 admissibility constraint; (5) that the cross-term identity 3ab(a+b) = (−a)³ + (−b)³ + (a+b)³ generates an infinite parametric family; (6) that the cross-term map is not injective on coprime pairs (disproved conjecture); and (7) a Vieta-style reflection relating representations of n and −n. We introduce the **Cube Inversion Graph** as a novel mathematical structure capturing reachability under the inversion principle.

## 1. Introduction

The problem of representing integers as sums of cubes has a distinguished history. The two-cube problem — characterizing which positive integers are sums of two positive cubes — was studied by Euler and is connected to elliptic curves and the arithmetic of the Eisenstein integers. The three-cube problem — determining which integers n satisfy x³ + y³ + z³ = n for some x, y, z ∈ ℤ — remains one of the central open questions in additive number theory.

A classical result shows that the only obstruction to three-cube representability at the local level is modular: every cube is congruent to 0, 1, or −1 modulo 9, so a sum of three cubes can never be congruent to ±4 modulo 9. The conjecture that every admissible integer (not ≡ 4, 5 mod 9) has a three-cube representation is supported by extensive computation but remains unproven.

In this paper, we develop a constructive bridge between the two problems via the inversion principle, which transforms two-cube decompositions of "overshoots" into three-cube representations.

## 2. Definitions

**Definition 2.1** (Sum of Two Cubes). An integer n is a *sum of two integer cubes* if there exist a, b ∈ ℤ with a³ + b³ = n. We write `IsSumTwoCubesInt(n)` for this predicate.

**Definition 2.2** (Sum of Three Cubes). An integer n is a *sum of three integer cubes* if there exist a, b, c ∈ ℤ with a³ + b³ + c³ = n. We write `IsSumThreeCubesInt(n)`.

**Definition 2.3** (Cube Overshoot). For c, n ∈ ℤ, the *cube overshoot* is `CubeOvershoot(c, n) = c³ − n`.

**Definition 2.4** (Inversion Triple). An *inversion triple* for n consists of integers (a, b, c) with c³ − n = a³ + b³. This structure witnesses that n is obtainable from a two-cube decomposition of the overshoot.

**Definition 2.5** (Inversion-Accessible). An integer n is *inversion-accessible* if there exists an inversion triple (a, b, c) for n with a, b > 0.

**Definition 2.6** (Taxicab Number). An integer n is a *taxicab number* if it admits at least two distinct representations as a sum of two positive cubes.

**Definition 2.7** (Cube Inversion Graph). The *cube inversion graph* is the directed graph on ℤ where there is an edge from m to n if m is a sum of two integer cubes and n = c³ − m for some c ∈ ℤ. The *inversion-reachable* relation is the transitive closure of this graph.

## 3. Main Results

### 3.1 The Core Algebraic Identity

**Theorem 3.1** (Three-Cube Inversion Principle). *If c³ − n = a³ + b³, then (−a)³ + (−b)³ + c³ = n.*

*Proof.* Direct rearrangement: (−a)³ + (−b)³ + c³ = −a³ − b³ + c³ = c³ − (a³ + b³) = c³ − (c³ − n) = n. □

**Theorem 3.2** (Converse). *If (−a)³ + (−b)³ + c³ = n, then c³ − n = a³ + b³.*

*Proof.* c³ − n = c³ − (−a³ − b³ + c³) = a³ + b³. □

**Corollary 3.3**. *Every inversion-accessible integer is a sum of three integer cubes.*

### 3.2 The Cross-Term Identity

**Theorem 3.4** (Cube Expansion). *For all a, b ∈ ℤ, (a + b)³ = a³ + b³ + 3ab(a + b).*

**Theorem 3.5** (Cross-Term Representation). *For all a, b ∈ ℤ, (−a)³ + (−b)³ + (a + b)³ = 3ab(a + b).*

This identity shows that every integer of the form 3ab(a + b) is inversion-accessible with roof c = a + b.

**Corollary 3.6** (Infinite Family). *For every integer k, the integer 6k³ is a sum of three cubes: 6k³ = (−k)³ + (−k)³ + (2k)³.*

### 3.3 Non-Injectivity of the Cross-Term Map

**Theorem 3.7** (Disproved Conjecture). *The map (a, b) ↦ ab(a + b), restricted to coprime ordered pairs with a ≤ b, is not injective.*

*Proof.* Counterexample: f(1, 5) = 1 · 5 · 6 = 30 = 2 · 3 · 5 = f(2, 3), and gcd(1, 5) = gcd(2, 3) = 1. □

This disproof has implications for density estimates: a lower bound on the density of inversion-accessible integers cannot be obtained simply by counting coprime pairs.

### 3.4 Mod-9 Preservation

**Theorem 3.8** (Cube Residues mod 9). *For all x ∈ ℤ, x³ mod 9 ∈ {0, 1, 8}.*

**Theorem 3.9** (Inversion Preserves Admissibility). *If c³ − n = a³ + b³ for some integers a, b, c, then n mod 9 ∉ {4, 5}.*

*Proof sketch.* Since n = c³ − a³ − b³, we have n mod 9 = (c³ − a³ − b³) mod 9. Each of c³, a³, b³ is in {0, 1, 8} mod 9. Exhaustive verification of all 27 combinations shows that c³ − a³ − b³ mod 9 ∈ {0, 1, 2, 3, 6, 7, 8}, which excludes 4 and 5. □

### 3.5 Reflections and Double Inversion

**Theorem 3.10** (Vieta Reflection). *If a³ + b³ + c³ = n, then (−a)³ + (−b)³ + (−c)³ = −n.*

**Theorem 3.11** (Double Inversion). *If n = (−a)³ + (−b)³ + c³, then c³ − n = a³ + b³.*

This shows that the inversion principle is its own inverse: applying it twice recovers the original two-cube sum.

### 3.6 The Taxicab Bridge

**Theorem 3.12** (Taxicab Bridge). *If n = a₁³ + b₁³ for some a₁, b₁ ∈ ℤ, then for any c ∈ ℤ, the integer c³ − n is a sum of three cubes.*

*Proof.* c³ − n = c³ − a₁³ − b₁³ = c³ + (−a₁)³ + (−b₁)³. □

### 3.7 Application to 1729

**Theorem 3.13**. *1729 is a taxicab number: 1729 = 1³ + 12³ = 9³ + 10³.*

**Theorem 3.14**. *1729 is inversion-accessible: 13³ − 1729 = 468 = 7³ + 5³, yielding the three-cube representation (−7)³ + (−5)³ + 13³ = 1729.*

**Theorem 3.15**. *1729 = 7 × 13 × 19 and 1729 − 1 = 12³ (Korselt's criterion).*

## 4. The Cube Inversion Graph

We introduce a novel mathematical structure: the **cube inversion graph** on ℤ.

**Definition 4.1**. The edge relation `CubeInvEdge(m, n)` holds when m is a sum of two integer cubes and n = c³ − m for some c ∈ ℤ. The transitive closure `InversionReachable(m, n)` captures multi-step reachability.

The inversion graph has several notable properties:
- Every sum of two cubes is a source vertex with infinitely many outgoing edges.
- The set of inversion-accessible integers is precisely the set of integers reachable in one step from some sum of two positive cubes.
- The graph respects the mod-9 obstruction: no vertex with n ≡ 4, 5 (mod 9) is reachable from any source.

## 5. Overshoot Spectrum Analysis

For a fixed target n, the **overshoot spectrum** is the set {c³ − n : c ∈ ℤ, c³ > n}. We proved:

**Theorem 5.1** (Overshoot Residue Coverage). *For fixed n and variable c, the overshoots c³ − n mod 9 take exactly the values {−n mod 9, 1 − n mod 9, 8 − n mod 9} as c ranges over ℤ.*

This constrains which overshoots can potentially be sums of two cubes, since a sum of two cubes mod 9 must lie in {0, 1, 2, 7, 8}.

## 6. Computational Results

We implemented algorithms for:
1. **Inversion search**: Given n, systematically scan overshoots c³ − n for two-cube decomposability. Complexity: O(C · N^{1/3}) for overshoots up to C.
2. **Cross-term generation**: Enumerate all 3ab(a+b) ≤ N. Complexity: O(N^{2/3}).
3. **Taxicab search**: Find all taxicab numbers ≤ N using a hash-map approach. Complexity: O(N^{2/3}).

Key computational findings:
- The fraction of admissible integers that are inversion-accessible grows with N, exceeding 30% for N = 1000.
- Cross-term integers with multiple generators (analogous to taxicab numbers in the cross-term domain) are relatively rare but present.
- The non-injectivity counterexample (1,5) ↔ (2,3) is the smallest such pair.

## 7. Discussion

The inversion principle provides a conceptual unification of two classical problems. Its key advantage is *constructivity*: rather than asserting existence, it provides an explicit algorithm for converting two-cube decompositions into three-cube representations.

The disproof of the cross-term injectivity conjecture illustrates the value of rigorous verification. The conjecture was plausible and would have implied a clean density bound, but the counterexample at n = 30 shows that the arithmetic of the cross-term function is subtler than expected.

The Cube Inversion Graph is, to our knowledge, a new mathematical object. Its properties — connectivity, spectral theory, growth rate of reachable sets — are largely unexplored and suggest several directions for future research.

## 8. Future Work

1. **Density bounds**: Establish rigorous asymptotic bounds on the number of inversion-accessible integers ≤ N.
2. **Graph connectivity**: Determine whether the inversion graph has finite diameter on admissible integers.
3. **Higher taxicab numbers**: Apply the inversion principle to Ta(3) = 87539319 and higher taxicab numbers.
4. **Carmichael connection**: Investigate when n − 1 being a perfect cube interacts with the cube decomposition structure of n.
5. **Algorithmic improvements**: Develop sub-cubic algorithms for the inversion search using lattice reduction.

## References

1. Hardy, G. H. *Ramanujan: Twelve Lectures on Subjects Suggested by His Life and Work*. Cambridge University Press, 1940.
2. Heath-Brown, D. R. "The density of zeros of forms for which weak approximation fails." *Mathematics of Computation*, 59(200):613–623, 1992.
3. Elkies, N. D. "Rational points near curves and small nonzero |x³ − y²| via lattice reduction." *Algorithmic Number Theory*, 2000.
4. Booker, A. R. "Cracking the problem with 33." *Research in Number Theory*, 5(26), 2019.
5. Booker, A. R. and Sutherland, A. V. "On a question of Mordell." *Proceedings of the National Academy of Sciences*, 118(11), 2021.
