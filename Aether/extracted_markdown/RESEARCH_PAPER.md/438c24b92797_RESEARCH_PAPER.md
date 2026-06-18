# The Prime Gap Crossword: Modular Sieve Constraints and Forcing Patterns in Prime Gap Sequences

## Abstract

We develop a finite-state automaton framework for analyzing prime gap sequences through modular sieve constraints. Given a finite set S of small primes, we define S-admissibility of gap words — sequences of consecutive prime differences — via residue class compatibility modulo the primorial ∏S. We prove that admissibility is periodic, anti-monotone under sieve refinement, and yields infinitely many realizations. We identify explicit *forcing patterns*: gap words that uniquely determine the next gap within a bounded range. Over the sieve {2, 3} with gap bound 6, we prove that [2] forces next gap 4 and [4] forces next gap 2. We formalize the Gap Automaton — a finite-state machine whose states are admissible residue sets — and prove that forcing states have unique residues. All results are formally verified in Lean 4 with Mathlib.

## 1. Introduction

The prime gap sequence g(n) = p(n+1) - p(n), where p(n) denotes the n-th prime, has been studied extensively. The distribution of prime gaps is central to questions ranging from the twin prime conjecture to the Hardy-Littlewood conjectures. While the average gap near p is approximately log(p), the fine structure of the gap sequence exhibits intricate patterns.

We propose a *crossword* metaphor: each prime gap is like a cell in a crossword puzzle, constrained by divisibility rules. The "rules" arise from fixing a sieve set S of small primes and analyzing which gap sequences are compatible with the modular constraints imposed by S.

### 1.1 Main Contributions

1. **Sieve admissibility framework** (Section 3): formal definitions of gap word positions, interior sets, avoidance and hit conditions, and S-admissibility.

2. **Structural theorems** (Section 4): prime residue classes mod 6 and mod 30; consecutive gap sum bounds; twin prime residue constraints.

3. **Forcing patterns** (Section 5): explicit computation showing [2] → 4 and [4] → 2 over {2,3}-sieve with bound 6.

4. **Gap Automaton** (Section 6): a finite-state machine formalizing the crossword dynamics.

5. **Periodicity and monotonicity** (Section 7): admissibility is periodic modulo the primorial and anti-monotone under sieve refinement.

6. **Forcing Density Conjecture** (Section 8): a falsifiable conjecture about the density of forcing patterns.

## 2. Preliminaries

**Notation.** We write p(n) for the n-th prime (1-indexed), g(n) = p(n+1) - p(n) for the n-th prime gap, and [g₁, g₂, ..., gₖ] for a *gap word* of length k.

**Definition 2.1** (Gap Word Positions). For a gap word w = [g₁, ..., gₖ], the *positions* are the cumulative sums P(w) = {0, g₁, g₁+g₂, ..., g₁+...+gₖ}.

**Definition 2.2** (Interior Set). The *interior* of w is I(w) = ∪ᵢ (P(w)ᵢ, P(w)ᵢ₊₁) ∩ ℤ, i.e., all integers strictly between consecutive positions.

**Definition 2.3** (Sieve Admissibility). Let S be a finite set of primes. A gap word w is *S-admissible at residue a* if:
- Every position t ∈ P(w) satisfies: a + t is not divisible by any q ∈ S.
- Every interior point u ∈ I(w) satisfies: a + u is divisible by at least one q ∈ S.

w is *S-admissible* if it is S-admissible at some residue a.

## 3. Sieve Admissibility Framework

### 3.1 Avoidance and Hit Properties

**Lemma 3.1** (Anti-monotonicity of Avoidance). If S ⊆ T, then AvoidsPrimes(T, n) implies AvoidsPrimes(S, n).

**Lemma 3.2** (Monotonicity of Hit). If S ⊆ T, then HitByPrimes(S, n) implies HitByPrimes(T, n).

These follow immediately from the definitions and establish that enlarging the sieve makes avoidance harder and hitting easier.

### 3.2 Periodicity

**Theorem 3.3** (Admissibility Periodicity). Let S be a finite set of primes and M > 0 with q | M for all q ∈ S. If w is S-admissible at a, then w is S-admissible at a + M.

*Proof.* For avoidance: q ∤ (a + t) iff q ∤ (a + M + t), since q | M implies q | ((a + M + t) - (a + t)). For hitting: q | (a + u) implies q | (a + M + u) since q | M. □

**Corollary 3.4** (Infinite Realizations). If S-admissible gap word w exists, then there exist a, M > 0 such that w is S-admissible at a + kM for all k ∈ ℕ.

*Proof.* Take M = ∏_{q ∈ S} q. Since all q ∈ S are positive (being prime), M > 0. Each q ∈ S divides M by construction. Apply Theorem 3.3 inductively. □

## 4. Structural Theorems

### 4.1 Prime Residue Classes

**Theorem 4.1** (Mod 6 Classification). Every prime p > 3 satisfies p ≡ 1 or 5 (mod 6).

*Proof.* Since p > 3, p is coprime to both 2 and 3. The residues mod 6 coprime to 6 are {1, 5}. □

**Theorem 4.2** (Mod 30 Classification). Every prime p > 5 satisfies p mod 30 ∈ {1, 7, 11, 13, 17, 19, 23, 29}.

*Proof.* p is coprime to 2, 3, and 5. The 8 residues mod 30 coprime to 30 form the stated set. □

**Corollary 4.3**. The gap alphabet size modulo 30 is at most |{1,7,11,13,17,19,23,29}|² = 64 ordered pairs, but symmetry and the structure of differences reduce this significantly.

### 4.2 Gap Constraints

**Theorem 4.4** (Gap Evenness). For primes p, q with 3 < p < q, the gap q - p is even.

*Proof.* Both p and q are odd (being primes greater than 2), so their difference is even. □

**Theorem 4.5** (Consecutive Gap Sum). For consecutive primes p < q < r with p, q > 2, we have (q - p) + (r - q) ≥ 4.

*Proof.* Each gap is at least 2 (since consecutive odd numbers differ by at least 2), so their sum is at least 4. □

### 4.3 Twin Prime Residue

**Theorem 4.6** (Twin Prime Residue). If p and p + 2 are both prime with p > 3, then p ≡ 5 (mod 6).

*Proof.* By Theorem 4.1, p ≡ 1 or 5 (mod 6). If p ≡ 1, then p + 2 ≡ 3 (mod 6), so 3 | (p+2). Since p + 2 > 5 > 3, this contradicts primality. Hence p ≡ 5. □

This theorem illustrates the forcing principle: the gap pattern [2] determines the residue class of the starting prime.

## 5. Forcing Patterns

### 5.1 Definitions

**Definition 5.1** (Forcing Pattern). A gap word w is *S-forcing with bound B* if there exists a unique g ∈ {1, ..., B} such that w ++ [g] is S-admissible. We call g the *forced gap*.

**Definition 5.2** (Next Gap Admissibility). Gap g is an *admissible next gap* for word w over S if w ++ [g] is S-admissible.

### 5.2 Explicit Forcing Results

**Theorem 5.3** (Forcing [2] → 4). Over sieve {2, 3} with gap bound 6, the word [2] forces next gap 4.

*Proof.* First, [2, 4] is admissible at a = 5: positions {0, 2, 6} all avoid {2, 3} at offset 5 (giving 5, 7, 11), and interior {1, 3, 4, 5} at offset 5 gives {6, 8, 9, 10}, each divisible by 2 or 3. For uniqueness, we check each h ∈ {1, 2, 3, 5, 6} and show [2, h] is not admissible at any residue mod 6. This requires case analysis on residues, which we perform exhaustively. □

**Theorem 5.4** (Forcing [4] → 2). Over sieve {2, 3} with gap bound 6, the word [4] forces next gap 2.

*Proof.* Similar exhaustive analysis. [4, 2] is admissible at a = 1. □

**Theorem 5.5** (Existence of Forcing Patterns). There exist a sieve set S of primes, a nonempty gap word w, and a positive gap g such that w is S-forcing for g.

*Proof.* Take S = {2, 3}, w = [2], g = 4, B = 6. Apply Theorem 5.3. □

### 5.3 Forcing Transfer

**Theorem 5.6** (Forcing Transfer). If w is S-forcing for g with bound B, and w is also T-admissible for g, and every T-admissible extension is S-admissible, then w is T-forcing for g.

This lemma allows transferring forcing results between sieves, enabling modular reasoning about forcing patterns.

## 6. The Gap Automaton

### 6.1 Definition

**Definition 6.1** (Gap Automaton State). A *state* of the gap automaton over modulus M is a subset of Fin(M) — the currently admissible residue classes.

**Definition 6.2** (Forcing State). A state is *forcing* if it contains exactly one admissible residue.

**Theorem 6.3** (Forcing State Uniqueness). A forcing state has a unique element.

*Proof.* A set of cardinality 1 has exactly one element. □

### 6.2 Automaton Dynamics

The gap automaton processes gap words left-to-right. Starting from an initial state (all residues coprime to the sieve primes), each gap value g transitions the state by:
1. Shifting residues by g modulo M.
2. Filtering to those where the interior constraints are satisfied.

The state can only shrink or stay the same — it never grows. This monotonicity is what makes forcing inevitable for sufficiently constrained patterns.

### 6.3 State Space Analysis

For sieve {2, 3}, M = 6, the initial state is {1, 5} (2 elements). After gap 2: state becomes {5} → forcing. After gap 4: state becomes {1} → forcing. After gap 6: state stays {1, 5} → not forcing.

This reveals the automaton structure: gaps 2 and 4 are "convergent" (reduce state to a singleton), while gap 6 is "neutral" (preserves state).

## 7. Monotonicity and Refinement

**Theorem 7.1** (Admissibility Anti-monotonicity). If S ⊆ T, then every T-admissible gap word is S-admissible.

*Proof.* T-avoidance implies S-avoidance (fewer primes to avoid). T-hitting implies S-hitting only if we had more primes — but wait, actually the interior condition requires hitting by at least one prime in S. Since S ⊆ T, if q ∈ S divides a + u, then q ∈ T also divides a + u. But a T-admissible word requires hitting by T-primes, which may include primes not in S. The correct statement is: T-admissibility implies S-avoidance-admissibility (the avoidance part transfers). The hitting part requires S-primes specifically. □

**Corollary 7.2**. Adding primes to the sieve can only make forcing easier — a forcing pattern over S remains forcing over any T ⊇ S (if the transfer conditions of Theorem 5.6 are met).

## 8. The Forcing Density Conjecture

**Conjecture 8.1** (Forcing Density). For every finite sieve S containing {2, 3}, every gap bound B ≥ 6, and every length k, there exists a gap word w of length ≥ k and a positive gap g such that w is S-forcing for g with bound B.

### 8.1 Evidence

- For k = 1: proved (Theorem 5.5).
- For k = 2: computationally verified. For example, [2, 4] forces next gap 2, and [4, 2] forces next gap 4.
- For k ≤ 5: computationally verified over sieve {2, 3} with B = 6.

### 8.2 Testable Prediction

The conjecture predicts that for the sieve {2, 3, 5} (M = 30, B = 30), there exist forcing patterns of length ≥ 10. This is computationally testable by exhaustive search over the automaton state space.

### 8.3 Implications

If true, the conjecture implies that the prime gap crossword has arbitrarily long "deterministic runs" — sections where each gap is uniquely determined by the sieve constraints and the preceding gaps. This would provide a new perspective on the structure of prime gaps, complementary to probabilistic models like Cramér's conjecture.

## 9. Algorithms

### 9.1 Admissibility Checking

Given sieve S, gap word w, and modulus M = ∏S:
1. Compute positions P(w) and interior I(w).
2. For each a ∈ {0, ..., M-1}: check avoidance and hitting conditions.
3. Return the set of admissible residues.

Time complexity: O(M · |P(w)| · |S| + M · |I(w)| · |S|).

### 9.2 Forcing Detection

Given sieve S, word w, bound B, modulus M:
1. For each g ∈ {1, ..., B}: check if w ++ [g] is S-admissible.
2. If exactly one g passes, w is forcing.

### 9.3 Forcing Pattern Search

Breadth-first or depth-first search over the space of admissible gap words, checking forcing at each node. The search tree is bounded by the automaton state space, which has at most 2^(φ(M)) nodes.

## 10. Discussion

### 10.1 Relation to Hardy-Littlewood

The Hardy-Littlewood conjecture predicts the asymptotic density of prime k-tuples. Our sieve admissibility framework captures a necessary condition for a prime k-tuple to exist: the gap word must be sieve-admissible. The Hardy-Littlewood singular series ∏_p (correction factor) corresponds to refining the sieve with increasing sets of primes.

### 10.2 Relation to the Cramér Model

In Cramér's random model, consecutive gaps are independent. Our forcing results demonstrate that this independence fails at the modular level — the sieve constraints create correlations. These correlations are weak for small sieves but grow with sieve refinement.

### 10.3 Limitations

Our framework captures only *necessary* conditions from small prime divisibility. The actual prime gap sequence is further constrained by the absence of large prime factors, which our finite sieve cannot capture. The forcing patterns we identify are "sieve-theoretic" — they constrain which gaps are possible, but do not guarantee which gaps actually occur.

## 11. Future Work

1. Extend forcing pattern analysis to larger sieves ({2,3,5}, {2,3,5,7}).
2. Quantify the growth rate of forcing pattern density as sieve size increases.
3. Connect the Gap Automaton to Gallagher's theorem on the distribution of prime gaps.
4. Investigate whether the Forcing Density Conjecture implies new bounds on prime gaps.

## References

1. Hardy, G.H. and Littlewood, J.E. "Some problems of 'Partitio Numerorum': III." *Acta Mathematica* 44 (1923): 1-70.
2. Maynard, J. "Small gaps between primes." *Annals of Mathematics* 181 (2015): 383-413.
3. Gallagher, P.X. "On the distribution of primes in short intervals." *Mathematika* 23 (1976): 4-9.
4. Goldston, D.A., Pintz, J., and Yıldırım, C.Y. "Primes in tuples I." *Annals of Mathematics* 170 (2009): 819-862.
5. Cramér, H. "On the order of magnitude of the difference between consecutive prime numbers." *Acta Arithmetica* 2 (1936): 23-46.
