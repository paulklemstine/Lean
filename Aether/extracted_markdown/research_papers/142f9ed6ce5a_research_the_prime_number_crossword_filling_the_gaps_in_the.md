# Prime Gap Automata: Modular Constraints as Finite-State Machines

## Abstract

We develop a rigorous theory of prime gap sequences as outputs of deterministic finite-state automata arising from modular arithmetic constraints. Our central result establishes a 2-state automaton governing prime gaps modulo 6: for primes p > 3, the gap g = q - p to the next prime is constrained to g ≡ 0 or 4 (mod 6) when p ≡ 1 (mod 6), and g ≡ 0 or 2 (mod 6) when p ≡ 5 (mod 6). This eliminates one-third of candidate gap values from each state. We extend this to an 8-state automaton modulo 30 and prove several derived results: the twin prime state rule (twin primes start only from state 5 mod 6), the cousin prime state rule (cousin primes start only from state 1 mod 6), the gap-sum divisibility criterion, forbidden gap pattern classification, and a bridge connecting the automaton's state space to the group (ℤ/6ℤ)* ≅ ℤ/2ℤ. All results are formalized and machine-verified in Lean 4 with Mathlib.

**Keywords**: prime gaps, finite automaton, modular arithmetic, sieve theory, formal verification

## 1. Introduction

### 1.1 Background

The gaps between consecutive primes g_n = p_{n+1} - p_n form a sequence of fundamental importance in analytic number theory. The Hardy-Littlewood conjecture [1] provides precise asymptotic predictions for the frequency of each gap value, while celebrated results of Zhang [2], Maynard [3], and the Polymath project [4] have established that lim inf g_n ≤ 246.

Despite this progress, the *structural* constraints on prime gap sequences — which sequences of gaps can actually occur — are less thoroughly explored. The classical no-prime-triplet theorem (that p, p+2, p+4 cannot all be prime for p > 3) is perhaps the best-known example, but it is far from isolated.

### 1.2 Our Contribution

We systematically develop the theory of modular constraints on prime gap sequences, organizing them as a hierarchy of finite-state automata. Our approach yields:

1. **The mod-6 gap constraint theorem** (Theorems 1-2): A complete characterization of admissible gap residues from each of the two prime residue classes modulo 6.

2. **The 2-state automaton** (Theorem 3): A deterministic transition function that correctly predicts the mod-6 residue class of the next prime from the current prime and gap.

3. **Derived exclusion results** (Theorems 4-8): Including the twin prime state rule, cousin prime state rule, and post-twin-gap constraint.

4. **The gap-sum divisibility criterion** (Theorem 9): 6 | (p_{n+2} - p_n) if and only if p_n ≡ p_{n+2} (mod 6).

5. **Group-theoretic bridge** (Theorems 10-11): The automaton state space {1, 5} is isomorphic to (ℤ/6ℤ)* ≅ ℤ/2ℤ, with gap transitions corresponding to the group action.

6. **Mod-30 extension** (Theorems 12-14): An 8-state automaton with provably 8/30 ≈ 26.7% admissibility rate per state.

### 1.3 Relation to Prior Work

This work deepens the `gap_even_for_large_primes` theorem from the established catalog (files `Shared/PrimeGapCrossword.lean`, `Bridges/PrimeGapCrosswordDeep.lean`), which proves that prime gaps beyond 2→3 are even. Our mod-6 constraint is strictly stronger: not only are gaps even, but they satisfy state-dependent constraints that eliminate an additional one-third of candidates. We also build on the forcing pattern framework in `Bridges/ForcingPatterns.lean`.

## 2. Definitions

**Definition 1** (Prime residue state). For a prime p > 3, define the *state* of p as:
$$\sigma(p) = \begin{cases} 0 & \text{if } p \equiv 1 \pmod{6} \\ 1 & \text{if } p \equiv 5 \pmod{6} \end{cases}$$

This is well-defined because every prime > 3 satisfies p ≡ 1 or 5 (mod 6).

**Definition 2** (Automaton transition). Define the transition function T : {0, 1} × ℤ/6ℤ → {0, 1} by:
$$T(s, g) = \begin{cases} s & \text{if } g \equiv 0 \pmod{6} \\ 1 - s & \text{if } g \not\equiv 0 \pmod{6} \end{cases}$$

**Definition 3** (Admissible gap set). For state s ∈ {0, 1}, the *admissible gap residues* mod 6 are:
$$A(0) = \{0, 4\}, \quad A(1) = \{0, 2\}$$

**Definition 4** (Admissible residues mod 30). The set of residues coprime to 30 is:
$$\mathcal{A}_{30} = \{1, 7, 11, 13, 17, 19, 23, 29\}$$

## 3. Main Results

### 3.1 The Mod-6 Gap Constraint

**Theorem 1** (Gap constraint from state 0). Let p, q be primes with p ≡ 1 (mod 6) and q ≡ 1 or 5 (mod 6), with p < q. Then (q - p) mod 6 ∈ {0, 4}.

*Proof.* If q ≡ 1 (mod 6), then q - p ≡ 1 - 1 = 0 (mod 6). If q ≡ 5 (mod 6), then q - p ≡ 5 - 1 = 4 (mod 6). □

**Theorem 2** (Gap constraint from state 1). Let p, q be primes with p ≡ 5 (mod 6) and q ≡ 1 or 5 (mod 6), with p < q. Then (q - p) mod 6 ∈ {0, 2}.

*Proof.* If q ≡ 5 (mod 6), then q - p ≡ 5 - 5 = 0 (mod 6). If q ≡ 1 (mod 6), then q - p ≡ 1 - 5 + 6 = 2 (mod 6). □

**Corollary** (Admissibility fraction). From each state, exactly 2 out of 6 residue classes mod 6 are admissible for the gap value, eliminating 2/3 of candidates.

### 3.2 Transition Correctness

**Theorem 3** (Automaton correctness). For consecutive primes p, q > 3:
$$\sigma(q) = T(\sigma(p), (q - p) \bmod 6)$$

*Proof.* Case analysis on the four combinations of σ(p) ∈ {0, 1} and σ(q) ∈ {0, 1}, using Theorems 1-2 to determine (q - p) mod 6 in each case. □

### 3.3 State Rules for Specific Gaps

**Theorem 4** (Twin prime state rule). If p > 3 is prime and p + 2 is prime, then p ≡ 5 (mod 6).

*Proof.* By Theorem 1, from state 0 the gap residue mod 6 must be 0 or 4. Since 2 mod 6 = 2, which is neither 0 nor 4, the gap of 2 cannot occur from state 0. □

**Theorem 5** (Cousin prime state rule). If p > 3 is prime and p + 4 is prime, then p ≡ 1 (mod 6).

*Proof.* Symmetric to Theorem 4: from state 1, admissible residues are {0, 2}, and 4 mod 6 = 4 ∉ {0, 2}. □

**Theorem 6** (Post-twin state). If p > 3 is prime and p + 2 is prime, then (p + 2) ≡ 1 (mod 6).

*Proof.* By Theorem 4, p ≡ 5 (mod 6), so p + 2 ≡ 7 ≡ 1 (mod 6). □

### 3.4 No-Prime-Triplet Theorem

**Theorem 7** (No prime triplet). For p > 3 prime with p + 2 prime, p + 4 is not prime.

*Proof.* By Theorem 6, (p + 2) ≡ 1 (mod 6), i.e., p + 2 is in state 0. From state 0, admissible gaps are {0, 4} mod 6. The gap from p + 2 to p + 4 is 2, with 2 mod 6 = 2 ∉ {0, 4}. □

This proof is more illuminating than the classical mod-3 argument because it reveals the *mechanism*: the automaton enters state 0 after a twin gap, and state 0 forbids gap 2.

### 3.5 Post-Twin Gap Constraint

**Theorem 8** (Post-twin constraint). If p > 3 and p + 2 are both prime, and r > p + 2 is the next prime after p + 2 with r > 3, then (r - (p + 2)) mod 6 ∈ {0, 4}.

*Proof.* By Theorem 6, p + 2 is in state 0. Apply Theorem 1. □

This means that after a twin prime pair, the next gap is constrained to ≡ 0 or 4 (mod 6). In particular, the next gap cannot be 2 (another twin), 8, 14, 20, etc.

### 3.6 Gap-Sum Divisibility

**Theorem 9** (Sum of two gaps mod 6). For primes p < q < r all greater than 3:
$$6 \mid (r - p) \iff p \equiv r \pmod{6}$$

*Proof.* Since p, r ∈ {1, 5} mod 6, we have r - p ≡ 0 mod 6 iff r mod 6 = p mod 6, and r - p ≡ ±4 mod 6 otherwise. □

This gives a parity-like conservation law: the automaton returns to its starting state after gaps summing to a multiple of 6.

### 3.7 State-Preserving Patterns

**Theorem 10** (Pattern [2, 4] preserves state). If p, p+2, p+6 are all prime with p > 3, then p mod 6 = (p + 6) mod 6.

**Theorem 11** (Pattern [4, 2] preserves state). If p, p+4, p+6 are all prime with p > 3, then p mod 6 = (p + 6) mod 6.

*Proof of both.* The total gap is 6, and 6 ≡ 0 (mod 6), so the state is preserved. □

### 3.8 Group-Theoretic Structure

**Theorem 12** (Multiplicative closure). The set {1, 5} is closed under multiplication mod 6. Moreover, every element is self-inverse: a² ≡ 1 (mod 6) for a ∈ {1, 5}.

This establishes that ({1, 5}, × mod 6) ≅ ℤ/2ℤ, the cyclic group of order 2.

**Theorem 13** (QR bridge). 1 is a quadratic residue mod 6 (since 1² ≡ 1) while 5 is not a quadratic residue mod 6. The automaton states correspond to {QR, non-QR} in (ℤ/6ℤ)*.

### 3.9 Mod-30 Extension

**Theorem 14** (Prime residues mod 30). Every prime p > 5 satisfies p mod 30 ∈ A₃₀ = {1, 7, 11, 13, 17, 19, 23, 29}.

**Theorem 15** (|A₃₀| = 8 = φ(30)). The set has exactly 8 elements, equal to Euler's totient of 30.

**Theorem 16** (Uniform admissibility). From each state r ∈ A₃₀, exactly 8 gap values in [0, 30) land on another admissible state. This gives an admissibility rate of 8/30 ≈ 26.7%.

## 4. PEGB Analysis

### 4.1 Mod-6 Gap Constraint (Theorems 1-2)

**Proof**: Complete formal proof in Lean 4, using omega tactic after establishing the mod-6 residues.

**Example**: p = 7 (≡ 1 mod 6), next prime q = 11, gap = 4 ≡ 4 mod 6 ✓. p = 11 (≡ 5 mod 6), next prime q = 13, gap = 2 ≡ 2 mod 6 ✓. p = 13 (≡ 1 mod 6), next prime q = 17, gap = 4 ≡ 4 mod 6 ✓.

**Generalization**: Extends naturally to mod m# for any primorial m#. The mod-30 automaton (8 states) is the next level. The mod-210 automaton would have 48 states.

**Boundary**: The constraint breaks down at the boundary: for p = 2, the gap to 3 is 1 (odd), and for p = 3, the gap to 5 is 2 but 3 mod 6 = 3 ∉ {1, 5}. The automaton requires p > 3.

### 4.2 Twin Prime State Rule (Theorem 4)

**Proof**: Contradiction with admissible gap set from state 0.

**Example**: Twin primes (5,7): 5 ≡ 5 mod 6 ✓. (11,13): 11 ≡ 5 mod 6 ✓. (17,19): 17 ≡ 5 mod 6 ✓. (29,31): 29 ≡ 5 mod 6 ✓.

**Generalization**: Extends to "k-prime state rules" — for any specific gap g, there is a unique starting state from which g is admissible.

**Boundary**: Does not predict *which* primes have twin prime gaps, only constrains the starting state.

### 4.3 No-Prime-Triplet via Automaton (Theorem 7)

**Proof**: Automaton-based proof using state transitions, more illuminating than the classical mod-3 argument.

**Example**: (3, 5, 7) is the unique prime triplet because 3 is the only prime where the mod-6 constraint doesn't apply.

**Generalization**: The same automaton argument shows [2, 2, ...] patterns of any length ≥ 2 are impossible.

**Boundary**: The singleton (3, 5, 7) is the unique counterexample; the automaton handles all p > 3.

### 4.4 Gap-Sum Divisibility (Theorem 9)

**Proof**: Direct from the residue class membership.

**Example**: Primes 7, 11, 13: 7 ≡ 1, 13 ≡ 1, and 13 - 7 = 6, so 6 | 6 ✓. Primes 7, 11, 17: 7 ≡ 1, 17 ≡ 5, and 17 - 7 = 10, and 6 ∤ 10 ✓.

**Generalization**: Extends to sums of k gaps: 6 | (p_{n+k} - p_n) iff p_n and p_{n+k} have the same mod-6 state.

**Boundary**: Requires all primes involved to be > 3.

### 4.5 QR Bridge (Theorem 13)

**Proof**: Exhaustive check that x² mod 6 ∈ {0, 1, 3, 4} for x ∈ {0,...,5}, so 5 is not a QR.

**Example**: The QR character χ(p mod 6) assigns +1 to state-0 primes and -1 to state-1 primes. Gaps that are multiples of 6 preserve χ; gaps of 2 or 4 flip it.

**Generalization**: Connects to Legendre symbols and Dirichlet characters mod 6.

**Boundary**: The connection to deeper QR theory (Gauss, Eisenstein) requires working with actual Legendre symbols rather than the simplified mod-6 version.

## 5. Algorithms

### 5.1 Gap Classification Algorithm

```
Input: A prime p > 3
Output: The set of admissible gap residues mod 6

1. Compute s = p mod 6
2. If s = 1, return {0, 4}
3. If s = 5, return {0, 2}
```

Time complexity: O(1). This allows O(1) filtering of candidate gaps.

### 5.2 Mod-30 Sieve Algorithm

```
Input: A prime p > 5
Output: Candidate next primes up to bound B

1. Compute r = p mod 30
2. For g = 2, 4, 6, ..., B-p:
   a. If (r + g) mod 30 ∈ A₃₀:
      b. Output p + g as candidate
3. For each candidate c, test primality
```

This reduces primality testing by a factor of 30/8 ≈ 3.75×.

## 6. Discussion

### 6.1 Connections to Hardy-Littlewood

The Hardy-Littlewood conjecture predicts that the number of prime pairs (p, p+g) with p ≤ N is asymptotic to C₂ · S(g) · N/(log N)², where S(g) is the singular series for gap g. Our automaton provides the *structural skeleton* for this prediction: the admissibility constraint is a necessary (but not sufficient) condition for a gap value to occur, and the admissibility fraction 2/6 is consistent with the leading term of the Hardy-Littlewood prediction.

### 6.2 Limitations

Our results are deterministic constraints, not probabilistic predictions. The automaton tells us which gaps are *impossible* from each state, but cannot predict which of the admissible gaps will actually occur. The distribution among admissible gaps is governed by the deeper analytic machinery of sieve theory and the Hardy-Littlewood circle method.

### 6.3 The Hierarchy of Automata

The mod-6 automaton is the first in a hierarchy indexed by primorials:
- Mod 6: 2 states, 2/6 ≈ 33.3% admissible per state
- Mod 30: 8 states, 8/30 ≈ 26.7% admissible per state
- Mod 210: 48 states, 48/210 ≈ 22.9% admissible per state
- Mod 2310: 480 states, 480/2310 ≈ 20.8% admissible per state

Each level gives tighter constraints, converging (by Mertens' theorem) to an admissibility rate of O(1/(log P)) where P is the primorial.

## 7. Formalization Details

All theorems are formalized in Lean 4 using the Mathlib library. The formalization comprises two modules:

- `Novelty/PrimeGapAutomaton.lean`: 17 theorems covering the core automaton theory, gap constraints, state transitions, no-prime-triplet, Pigeonhole principle, group theory bridge, and mod-30 extension.

- `Novelty/GapPatternExclusion.lean`: 17+ theorems covering pattern exclusion, twin-cousin bridges, state-preserving patterns, inadmissible triples, admissibility density bounds, and the QR bridge.

Total: 34+ formally verified theorems with zero sorries.

## 8. Future Work

1. **Higher primorial automata**: Formally verify the mod-210 (48-state) automaton and prove the Mertens-style density bound for the admissibility rate.

2. **Gap pattern enumeration**: Classify all admissible gap k-tuples for small k using the automaton, connecting to the Hardy-Littlewood k-tuple conjecture.

3. **Ergodic theory bridge**: Interpret the automaton as a topological dynamical system and study its ergodic properties.

4. **Connection to Dirichlet characters**: Formalize the relationship between the automaton states and Dirichlet characters mod 6.

## References

1. G. H. Hardy and J. E. Littlewood, "Some problems of 'Partitio Numerorum'; III: On the expression of a number as a sum of primes," *Acta Math.* 44 (1923), 1–70.

2. Y. Zhang, "Bounded gaps between primes," *Ann. of Math.* 179 (2014), 1121–1174.

3. J. Maynard, "Small gaps between primes," *Ann. of Math.* 181 (2015), 383–413.

4. D.H.J. Polymath, "Variants of the Selberg sieve, and bounded intervals containing many primes," *Res. Math. Sci.* 1 (2014), Art. 12.

5. Catalog results: `Shared/PrimeGapCrossword.lean` (gap_even_for_large_primes), `Bridges/ForcingPatterns.lean` (prime_gap_even), `Bridges/PrimeGapCrosswordDeep.lean` (gap_even_for_large_primes).
