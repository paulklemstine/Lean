# Prime Gap Crossword: Modular Forcing and Admissibility Theory

## Abstract

We develop a systematic theory of prime gap constraints arising from modular arithmetic, viewing the sequence of prime gaps as a word over an alphabet governed by finite-state automata. We establish that every prime p > 3 has residue 1 or 5 modulo 6, creating a two-state machine that constrains admissible gap values. Extending to modulo 30 = 2·3·5, we obtain an 8-state automaton where over 73% of potential gap values are immediately ruled inadmissible. We prove the no-prime-triplet theorem (p, p+2, p+4 cannot all be prime for p > 3), the three-prime span bound (consecutive triples of primes > 3 span at least 6), and the twin-prime forcing rule (the gap after a twin prime pair exceeds 3). We define the primorial state machine and forcing patterns, and state the Hardy-Littlewood gap conjecture in formal terms suitable for future mechanized verification.

**Keywords**: Prime gaps, modular arithmetic, sieve theory, finite automata, Hardy-Littlewood conjecture, twin primes

## 1. Introduction

The sequence of prime gaps g(n) = p(n+1) - p(n) for n ≥ 1, where p(n) denotes the n-th prime, is one of the most studied objects in analytic number theory. The first few values are 1, 2, 2, 4, 2, 4, 2, 4, 6, 2, 6, 4, ... (OEIS A001223). Despite intense study, fundamental questions about this sequence remain open: the twin prime conjecture (g(n) = 2 infinitely often), Cramér's conjecture (g(n) = O((log p(n))²)), and the precise distribution of gap sizes.

In this paper, we take a different approach. Rather than studying the asymptotic distribution of individual gaps, we examine the *grammar* of gap sequences — the local constraints that determine which gap patterns are admissible. Our key insight is that fixing a set S of small primes induces a finite-state automaton on prime gap sequences, where the states are residue classes modulo ∏S and transitions correspond to gap values.

### 1.1 Main Results

1. **No-Prime-Triplet Theorem** (Theorem 3.1): For p > 3, the numbers p, p+2, p+4 cannot all be prime.

2. **Mod-6 Gap Grammar** (Theorems 4.1–4.3): The gap between consecutive primes > 3 is constrained to specific residue classes mod 6, depending on the starting prime's residue.

3. **Three-Prime Span Bound** (Theorem 5.1): For three consecutive primes p < q < r with p > 3, we have r - p ≥ 6.

4. **Twin-Prime Forcing Rule** (Theorem 6.1): After a twin prime pair (p, p+2) with p > 3, the next gap is at least 4.

5. **Primorial State Machine** (Definition 7.1): An 8-state automaton modulo 30 that tracks admissible prime positions.

6. **Admissibility Density Bound** (Theorem 7.2): At most 8 out of 30 gap values (mod 30) are admissible from any state.

## 2. Preliminaries

### 2.1 Notation

Let p(n) denote the n-th prime number (p(1) = 2, p(2) = 3, p(3) = 5, ...). Define the prime gap function g(n) = p(n+1) - p(n). We write a ≡ b (mod m) for congruence and a | b for divisibility.

### 2.2 Basic Properties

**Lemma 2.1** (Gap Parity). For primes p, q > 2 with p < q, the gap q - p is even.

*Proof.* Both p and q are odd (as primes greater than 2), so their difference is even. □

**Lemma 2.2** (Gap Telescoping). For natural numbers p ≤ q ≤ r, (q - p) + (r - q) = r - p.

*Proof.* Immediate from arithmetic. □

## 3. The No-Prime-Triplet Theorem

**Theorem 3.1.** For any integer p > 3, if p and p + 2 are both prime, then p + 4 is not prime.

*Proof.* Among the three integers p, p + 2, p + 4, we examine their residues modulo 3.

- If p ≡ 0 (mod 3): Then 3 | p. Since p > 3 and p is prime, this is a contradiction.
- If p ≡ 1 (mod 3): Then p + 2 ≡ 0 (mod 3), so 3 | (p + 2). Since p + 2 > 5 > 3, this contradicts the primality of p + 2.
- If p ≡ 2 (mod 3): Then p + 4 ≡ 0 (mod 3), so 3 | (p + 4). Since p + 4 > 7 > 3, this means p + 4 is composite.

In each case, the three numbers cannot all be prime. □

**Remark.** The triplet (3, 5, 7) is the unique prime triplet with common difference 2. The theorem shows this is an isolated phenomenon arising from the special role of 3.

## 4. The Mod-6 Gap Grammar

**Theorem 4.1** (Prime Residues mod 6). Every prime p > 3 satisfies p ≡ 1 or p ≡ 5 (mod 6).

*Proof.* The residues 0, 2, 4 mod 6 are even, hence divisible by 2. The residue 3 mod 6 is divisible by 3. Since p > 3 is prime, it avoids all four excluded residues. □

**Theorem 4.2** (Gap Residues mod 6). For primes p, q > 3 with p < q, the gap q - p satisfies (q - p) ≡ 0, 2, or 4 (mod 6).

*Proof.* By Theorem 4.1, p ≡ 1 or 5 and q ≡ 1 or 5 (mod 6). Computing all four cases:
| p mod 6 | q mod 6 | (q - p) mod 6 |
|---------|---------|---------------|
| 1       | 1       | 0             |
| 1       | 5       | 4             |
| 5       | 1       | 2             |
| 5       | 5       | 0             |

All outcomes lie in {0, 2, 4}. □

**Theorem 4.3** (State-Dependent Gap Grammar).
- (a) If p ≡ 1 (mod 6), the gap to the next prime is ≡ 0 or 4 (mod 6).
- (b) If p ≡ 5 (mod 6), the gap to the next prime is ≡ 0 or 2 (mod 6).

*Proof.* Immediate from the table above, restricting to the row corresponding to p's residue. □

**Corollary 4.4.** The mod-6 gap grammar defines a two-state Markov chain:
- State 1 → State 1 (gap ≡ 0 mod 6) or State 1 → State 5 (gap ≡ 4 mod 6)
- State 5 → State 1 (gap ≡ 2 mod 6) or State 5 → State 5 (gap ≡ 0 mod 6)

## 5. The Three-Prime Span Bound

**Theorem 5.1.** Let p < q < r be three consecutive primes with p > 3. Then r - p ≥ 6.

*Proof.* By Lemma 2.1, both gaps q - p and r - q are even. Since p < q < r, both gaps are positive, hence each is ≥ 2. If both gaps were exactly 2, we would have q = p + 2 and r = p + 4, contradicting Theorem 3.1. Therefore at least one gap is ≥ 4, giving r - p = (q - p) + (r - q) ≥ 2 + 4 = 6. □

**Remark.** The bound is tight: the triples (5, 7, 11), (11, 13, 17), (17, 19, 23), (29, 31, 37) all achieve r - p = 6.

## 6. The Twin-Prime Forcing Rule

**Theorem 6.1.** Let p, p + 2, r be consecutive primes with p > 3 and r > p + 2. Then r - (p + 2) ≥ 4.

*Proof.* By Theorem 3.1, p + 4 is not prime. The number p + 3 is even (since p is odd), hence not prime. So no prime lies in {p + 3, p + 4}. The next candidate is p + 5, but p + 5 has the same parity as p + 3 if p is even — however, p is odd (prime > 3), so p + 5 is even. Wait: p is odd, so p + 3 is even, p + 4 is odd but not prime (by Theorem 3.1), and p + 5 is even. So r ≥ p + 6, giving r - (p + 2) ≥ 4.

More precisely: r > p + 2 and r ≠ p + 3 (since p + 3 is even) and r ≠ p + 4 (by Theorem 3.1). So r ≥ p + 5. But r and p + 2 are both odd primes, so r - (p + 2) is even. Since r - (p + 2) ≥ 3 and even, r - (p + 2) ≥ 4. □

## 7. The Primorial State Machine

### 7.1 Definition

**Definition 7.1** (Primorial State). The *primorial state* of a prime p > 5 is its residue modulo 30 = 2 · 3 · 5. The set of admissible states is:

$$\mathcal{A}_{30} = \{1, 7, 11, 13, 17, 19, 23, 29\}$$

These are exactly the residues coprime to 30, and |𝒜₃₀| = φ(30) = 8.

**Theorem 7.1.** Every prime p > 5 has p mod 30 ∈ 𝒜₃₀.

*Proof.* A prime p > 5 is coprime to 2, 3, and 5, hence coprime to 30. The residues coprime to 30 are exactly 𝒜₃₀. □

### 7.2 Transition Rules

**Definition 7.2** (Admissible Gaps). For a state r ∈ 𝒜₃₀, the set of admissible gaps modulo 30 is:

$$G(r) = \{g \in \{0, 1, \ldots, 29\} : (r + g) \bmod 30 \in \mathcal{A}_{30}\}$$

**Theorem 7.2** (Admissibility Density Bound). For every r ∈ 𝒜₃₀, |G(r)| ≤ 8.

*Proof.* The map g ↦ (r + g) mod 30 is a bijection on ℤ/30ℤ, so |G(r)| = |𝒜₃₀| = 8 for every r. □

**Corollary 7.3.** The primorial automaton rules out at least 22 out of 30 potential gap values (mod 30) from any state, a rejection rate of over 73%.

### 7.3 Transition Table

The complete transition table for the 8-state automaton:

| From \ Gap mod 30 | 2 | 4 | 6 | 8 | 10 | 12 | 14 | 16 | 18 | 20 | 22 | 24 | 26 | 28 | 30≡0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | — | — | 7 | — | 11 | 13 | — | 17 | 19 | — | 23 | — | — | 29 | 1 |
| 7 | — | 11 | 13 | — | 17 | 19 | — | 23 | — | — | 29 | 1 | — | — | 7 |
| ... | ... | ... | ... | ... | ... | ... | ... | ... | ... | ... | ... | ... | ... | ... | ... |

(Each "—" represents an inadmissible transition where the target is divisible by 2, 3, or 5.)

## 8. Forcing Patterns

### 8.1 Definition

**Definition 8.1.** A gap word w = (g₁, ..., gₖ) is *forcing with bound B* over sieve S if there exists a unique positive integer g ≤ B such that the extended word (g₁, ..., gₖ, g) is S-admissible.

### 8.2 The Forcing Pattern Conjecture

**Conjecture 8.1** (Forcing Pattern Conjecture). For every bound B ≥ 2, there exists a gap word w and a gap value g such that w is forcing with bound B over the sieve {2, 3, 5}. Equivalently, the mod-30 automaton has paths that lead to states where only one transition is possible within the bounded gap alphabet.

**Computational Evidence.** For B = 6, the word [6, 4, 2] starting from state 1 leads to state 13. The admissible gaps from 13 within {2, 4, 6} are: 13 + 4 = 17 ∈ 𝒜₃₀ and 13 + 6 = 19 ∈ 𝒜₃₀. So this is not forcing (two options). For B = 2, from state 29, the only admissible gap in {2} is 2 (29 + 2 = 31 ≡ 1 mod 30 ∈ 𝒜₃₀), which IS forcing.

## 9. Connection to Hardy-Littlewood

The Hardy-Littlewood conjecture on prime gaps predicts that the number π₂(N; g) of primes p ≤ N such that p + g is also prime satisfies:

$$\pi_2(N; g) \sim \mathfrak{S}(g) \cdot \frac{N}{(\log N)^2}$$

where the singular series 𝔖(g) is:

$$\mathfrak{S}(g) = 2C_2 \prod_{\substack{p | g \\ p \text{ prime} \\ p \geq 3}} \frac{p - 1}{p - 2}$$

and C₂ = ∏_{p≥3} (1 - 1/(p-1)²) ≈ 0.6601618 is the twin prime constant.

Our mod-30 automaton provides a finite approximation to this singular series: the admissibility constraints from {2, 3, 5} account for the leading factors in 𝔖(g). The automaton's transition probabilities (treating each admissible transition as equally likely) approximate the Hardy-Littlewood prediction at the level of the first three primes in the Euler product.

## 10. Algorithms

### 10.1 Gap Admissibility Check

```
INPUT: sieve primes S, gap word w, bound B
OUTPUT: set of admissible next gaps

for g = 2 to B step 2:
    admissible = true
    for each starting residue r coprime to ∏S:
        if (r + sum(w) + g) mod ∏S is coprime to ∏S:
            and all interior positions r + sum(w) + k (0 < k < g) are hit by some s ∈ S:
                record g as admissible from r
    if g is admissible from some r: output g
```

### 10.2 Forcing Pattern Search

```
INPUT: sieve primes S, max word length L, gap bound B
OUTPUT: forcing patterns

for each word w of length 1 to L over even alphabet ≤ B:
    A = admissible_next_gaps(S, w, B)
    if |A| = 1:
        output (w, A[0]) as forcing pattern
```

## 11. Discussion

The prime gap crossword framework reveals that much of the apparent randomness in prime gaps is illusory — it arises from the interaction of simple modular constraints. The mod-6 grammar eliminates 50% of potential gap values; the mod-30 automaton eliminates over 73%. Extending to modulo 210 = 2·3·5·7 would eliminate approximately 77%, and so on.

The key insight is that these constraints are *compositional*: the admissibility of a gap pattern is determined by the tensor product of constraints from each small prime. This algebraic structure underlies the Hardy-Littlewood singular series and explains why the product formula works so well.

## 12. Future Work

1. **Extend to larger primorials**: Analyze the automaton modulo 210 (8 × 48 = 48 states) and characterize its forcing patterns.
2. **Quantitative forcing density**: Prove that forcing patterns occur with positive density among all gap words.
3. **Connection to Maier's theorem**: Relate the automaton's structure to the irregular distribution of primes in short intervals.
4. **Computational verification**: Test Hardy-Littlewood predictions against the automaton's transition frequencies up to 10^10.

## References

1. Hardy, G.H. and Littlewood, J.E. "Some problems of 'Partitio numerorum'; III: On the expression of a number as a sum of primes." *Acta Mathematica* 44 (1923): 1–70.
2. Cramér, H. "On the order of magnitude of the difference between consecutive prime numbers." *Acta Arithmetica* 2 (1936): 23–46.
3. Maier, H. "Primes in short intervals." *Michigan Mathematical Journal* 32.2 (1985): 221–225.
4. Goldston, D.A., Pintz, J., and Yıldırım, C.Y. "Primes in tuples I." *Annals of Mathematics* 170.2 (2009): 819–862.
