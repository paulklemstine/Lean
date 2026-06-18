# Prime Gap Constraints as Primorial Automata: A Finite-State Theory of Gap Grammars

## Abstract

We develop a systematic theory of prime gap constraints arising from modular arithmetic modulo primorials (products of initial primes). We prove that the residue classes of primes modulo 6 create a two-state automaton constraining gap sequences, and establish several fundamental results: the no-prime-triplet theorem, twin prime and cousin prime forcing rules, gap parity and mod-6 grammar constraints, and the three-prime span bound. We introduce the *primorial automaton* — a finite-state machine whose states are coprime residue classes and whose transitions are prime gaps — and prove that its state density strictly decreases as the primorial level increases. All results are machine-verified in Lean 4 with the Mathlib library. We propose testable conjectures connecting the spectral properties of primorial automaton transition matrices to the Hardy-Littlewood singular series.

**Keywords**: prime gaps, primorial, finite automaton, modular arithmetic, sieve theory, Euler totient

---

## 1. Introduction

The distribution of gaps between consecutive primes has been studied since Euclid, yet many fundamental questions remain open. While deep analytic methods (the circle method, sieve theory, the work of Zhang, Maynard, and Tao on bounded gaps) have produced remarkable results, the elementary modular constraints on prime gaps have received less systematic attention.

In this paper, we observe that the residue class structure of primes modulo primorials P# = 2·3·5·...·p creates a natural finite-state automaton that constrains prime gap sequences. This perspective unifies several classical observations — the impossibility of prime triplets, the parity of gaps, the forcing of twin prime residues — into a single framework.

### 1.1 Overview of Results

We establish the following theorems, all machine-verified:

1. **Prime Residue Classification** (Theorem 3.1): Every prime p > 3 satisfies p ≡ 1 or 5 (mod 6).
2. **No Prime Triplet** (Theorem 4.1): For p > 3, not all of p, p+2, p+4 can be prime.
3. **Twin Prime Forcing** (Theorem 5.1): If p > 3 and both p, p+2 are prime, then p ≡ 5 (mod 6).
4. **Cousin Prime Forcing** (Theorem 5.2): If p > 3 and both p, p+4 are prime, then p ≡ 1 (mod 6).
5. **Gap Parity** (Theorem 6.1): For primes p < q both > 2, we have 2 | (q − p).
6. **Gap Mod-6 Grammar** (Theorem 6.2): For primes p < q both > 3, (q−p) mod 6 ∈ {0, 2, 4}.
7. **Three-Prime Span Bound** (Theorem 7.1): Three consecutive primes > 3 span at least 6.
8. **Gap Impossibility** (Theorems 8.1–8.2): Gaps of 1 (for p > 2) and 3 (for p > 3) are impossible.
9. **State Density Decay** (Theorems 9.1–9.2): φ(30)/30 < φ(6)/6 and φ(210)/210 < φ(30)/30.
10. **Admissible Count** (Theorem 9.3): The number of coprime residues mod m equals φ(m).

### 1.2 Novel Contributions

The primary novel contribution is the **primorial automaton** framework (Definition 2.1), which reinterprets classical sieve constraints as a formal language theory problem. While individual results (e.g., the no-prime-triplet theorem) are well-known, their unification through finite automata theory appears to be new, and the connection to symbolic dynamics (where prime gap sequences are the "forbidden words" dual of horseshoe dynamics) provides a bridge between number theory and dynamical systems.

---

## 2. Definitions

### Definition 2.1 (Primorial Automaton)
A *primorial automaton* at level k is the tuple A = (Q, Σ, δ, q₀) where:
- Q = {r ∈ {0, ..., P#−1} : gcd(r, P#) = 1} is the state set (coprime residues mod P#, where P# is the k-th primorial)
- Σ = {g ∈ 2ℕ : g > 0} is the input alphabet (positive even numbers)
- δ(r, g) = (r + g) mod P# is the transition function
- q₀ is determined by the first prime

### Definition 2.2 (Gap Word)
A *gap word* is a finite sequence (g₁, g₂, ..., gₙ) of positive even integers representing consecutive prime gaps.

### Definition 2.3 (Admissible Gap Word)
A gap word w = (g₁, ..., gₙ) is *admissible* for automaton A from state s if every prefix sum s + g₁ + ... + gᵢ (mod P#) lands in Q.

### Definition 2.4 (Gap Alphabet)
The *gap alphabet* of an automaton A is the set of gap values g such that there exists at least one state s ∈ Q with δ(s, g) ∈ Q.

---

## 3. Prime Residue Classification

**Theorem 3.1** (prime_mod6_residue). *Let p be a prime with p > 3. Then p ≡ 1 (mod 6) or p ≡ 5 (mod 6).*

*Proof.* The six residue classes modulo 6 are {0, 1, 2, 3, 4, 5}. If p ≡ 0 (mod 6), then 6 | p, hence 2 | p, contradicting primality for p > 2. If p ≡ 2 or p ≡ 4 (mod 6), then 2 | p, same contradiction. If p ≡ 3 (mod 6), then 3 | p, and since p > 3, p is composite. Only residues 1 and 5 remain. □

This theorem establishes that the mod-6 primorial automaton has exactly 2 states, corresponding to φ(6) = 2.

---

## 4. The No-Prime-Triplet Theorem

**Theorem 4.1** (no_prime_triplet). *For p > 3, it is impossible that p, p+2, and p+4 are all prime.*

*Proof.* Among any three integers p, p+2, p+4, at least one is divisible by 3 (Lemma 4.1). Since all three exceed 3, the one divisible by 3 has 3 as a proper divisor and cannot be prime. □

**Lemma 4.1** (three_consec_even_div3). *For any natural number p, 3 | p or 3 | (p+2) or 3 | (p+4).*

*Proof.* Case analysis on p mod 3:
- p ≡ 0: 3 | p
- p ≡ 1: p + 2 ≡ 0, so 3 | (p+2)
- p ≡ 2: p + 4 ≡ 0, so 3 | (p+4) □

---

## 5. Prime Forcing Rules

**Theorem 5.1** (twin_prime_forcing). *If p > 3 and both p, p+2 are prime, then p ≡ 5 (mod 6).*

*Proof.* By Theorem 3.1, p ≡ 1 or 5 (mod 6). If p ≡ 1 (mod 6), then p+2 ≡ 3 (mod 6), so 3 | (p+2). Since p+2 > 5 > 3, this contradicts the primality of p+2. □

**Theorem 5.2** (cousin_prime_forcing). *If p > 3 and both p, p+4 are prime, then p ≡ 1 (mod 6).*

*Proof.* By Theorem 3.1, p ≡ 1 or 5 (mod 6). If p ≡ 5 (mod 6), then p+4 ≡ 3 (mod 6), so 3 | (p+4). Since p+4 > 7 > 3, this contradicts the primality of p+4. □

These results demonstrate that the gap value (2 vs. 4) uniquely determines the residue class of the smaller prime. In the automaton framework, the transition from a given gap is deterministic with respect to residue class: a gap of 2 forces the starting state to be 5, and a gap of 4 forces it to be 1.

---

## 6. Gap Constraints

**Theorem 6.1** (consecutive_prime_gap_even). *If p, q are primes with p > 2, q > 2, and p < q, then 2 | (q − p).*

*Proof.* Both p and q are odd (primes > 2), so their difference is even. □

**Theorem 6.2** (gap_mod6_constraint). *If p, q are primes with p > 3, q > 3, and p < q, then (q − p) mod 6 ∈ {0, 2, 4}.*

*Proof.* By Theorem 3.1, p, q ∈ {1, 5} mod 6. The four cases give differences:
- (1, 1): q − p ≡ 0 (mod 6)
- (1, 5): q − p ≡ 4 (mod 6)
- (5, 1): q − p ≡ 2 (mod 6)
- (5, 5): q − p ≡ 0 (mod 6) □

This theorem shows that the mod-6 automaton reduces the gap alphabet from {all positive even integers} to {those ≡ 0, 2, or 4 mod 6}, eliminating one-third of the even gap values.

---

## 7. Three-Prime Span Bound

**Theorem 7.1** (three_prime_span_bound). *Let p < q < r be three consecutive primes, all greater than 3. Then r − p ≥ 6.*

*Proof.* By Theorem 6.1, both gaps q − p and r − q are even and positive, hence ≥ 2. If r − p < 6, then both gaps equal 2, giving p, p+2, p+4 all prime — contradicting Theorem 4.1. □

This bound is tight: the consecutive primes 5, 7, 11 have span 6, and 7, 11, 13 also have span 6.

---

## 8. Gap Impossibility Results

**Theorem 8.1** (gap_one_impossible). *If p > 2 and p, p+1 are both prime, this leads to a contradiction.*

*Proof.* Since p > 2, p is odd, so p+1 is even and > 2, hence not prime. □

**Theorem 8.2** (gap_three_impossible). *If p > 3 and p, p+3 are both prime, this leads to a contradiction.*

*Proof.* Since p > 3, p is odd (being prime and > 2), so p+3 is even and > 6 > 2, hence not prime. □

---

## 9. State Density Decay

**Theorem 9.1** (primorial_state_density_decay). *φ(30) · 6 < φ(6) · 30, i.e., φ(30)/30 < φ(6)/6.*

**Theorem 9.2** (primorial_density_decay_30_to_210). *φ(210) · 30 < φ(30) · 210, i.e., φ(210)/210 < φ(30)/30.*

These are verified computationally: φ(6) = 2, φ(30) = 8, φ(210) = 48, giving densities 1/3 ≈ 0.333, 4/15 ≈ 0.267, 8/35 ≈ 0.229.

**Theorem 9.3** (admissible_count_eq_totient). *The number of residues in {0, ..., m−1} coprime to m equals φ(m).*

This connects the automaton's state count to classical number theory. The general density decay follows from the formula:
$$\frac{\varphi(P_k\#)}{P_k\#} = \prod_{i=1}^{k} \left(1 - \frac{1}{p_i}\right)$$
which is strictly decreasing, converging to 0 by Mertens' theorem.

---

## 10. Algorithms

### Algorithm 1: Primorial Automaton Construction
```
Input: level k (number of primes)
Output: Automaton A = (Q, δ)

1. Compute P# = product of first k primes
2. Q ← {r ∈ {0, ..., P#-1} : gcd(r, P#) = 1}
3. δ(r, g) ← (r + g) mod P#
4. Return (Q, δ)
```

### Algorithm 2: Gap Word Validation
```
Input: Gap word w = (g₁, ..., gₙ), automaton A, start state s
Output: Accept/Reject

1. current ← s
2. For i = 1 to n:
   a. current ← δ(current, gᵢ)
   b. If current ∉ Q: return Reject
3. Return Accept
```

### Algorithm 3: Admissible Gap Enumeration
```
Input: Automaton A at level k
Output: Set of admissible gaps

1. gaps ← ∅
2. For each g ∈ {2, 4, 6, ..., P#}:
   For each s ∈ Q:
     If δ(s, g) ∈ Q:
       gaps ← gaps ∪ {g}
       break
3. Return gaps
```

---

## 11. Discussion

### 11.1 Connection to Symbolic Dynamics

The primorial automaton framework reveals a duality with symbolic dynamics. In classical symbolic dynamics, horseshoe maps realize *all* symbolic patterns — every finite word over a given alphabet appears as an orbit segment. The prime gap automaton represents the *opposite* phenomenon: a natural system that *forbids* certain patterns. The gap sequence (2, 2) is forbidden (no prime triplet), the gap 1 is forbidden (after 2, 3), and more generally, the automaton's transition structure eliminates large classes of gap words.

### 11.2 Connection to Sieve Theory

The primorial automaton is essentially a reformulation of the Eratosthenes sieve as a formal language. Each level of the sieve corresponds to a more refined automaton. The density decay theorem (Section 9) is a manifestation of the classical sieve bound, and the automaton's spectral properties may encode information equivalent to the Hardy-Littlewood singular series.

### 11.3 Limitations

Our results are purely elementary — they follow from modular arithmetic and do not access the deep analytic structure of prime distribution. The automaton constraints are *necessary* but not *sufficient*: many gap words that are admissible by the automaton do not correspond to actual prime gap sequences. Closing this gap between automaton-admissible and arithmetically-realizable gap sequences requires analytic number theory beyond the scope of this framework.

---

## 12. Conjectures and Future Work

**Conjecture 12.1** (Spectral Gap Convergence). The spectral gap of the transition matrix of the mod-P# automaton converges to a limit related to the twin prime constant C₂ ≈ 0.6601... as the primorial level increases.

**Conjecture 12.2** (Automaton Entropy). The topological entropy of the gap language accepted by the mod-P# automaton decreases monotonically with k and converges to a limit determined by the prime number theorem.

**Conjecture 12.3** (Spectral-Singular Series Connection). The eigenvalues of the mod-P# transition matrix approximate the singular series coefficients S(H) for admissible tuples H.

---

## 13. References

1. Hardy, G.H. and Littlewood, J.E. "Some problems of 'Partitio Numerorum' III: On the expression of a number as a sum of primes." *Acta Math.* 44 (1923), 1–70.
2. Maynard, J. "Small gaps between primes." *Ann. Math.* 181 (2015), 383–413.
3. Granville, A. "Harald Cramér and the distribution of prime numbers." *Scand. Actuarial J.* 1995, 12–28.
4. Mertens, F. "Ein Beitrag zur analytischen Zahlentheorie." *J. Reine Angew. Math.* 78 (1874), 46–62.
