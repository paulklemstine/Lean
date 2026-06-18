# Future Directions: Prime Gap Crossword Research

## Synthesis

This research cycle established the foundational theory of prime gap constraints as a finite-state automaton problem. The key discovery is that modular arithmetic modulo small primorials (6, 30, 210, ...) creates increasingly tight "grammars" for prime gap sequences, ruling out large fractions of potential gap values before any deep number-theoretic analysis is needed. We proved the no-prime-triplet theorem, the mod-6 gap grammar, the three-prime span bound, and the twin-prime forcing rule — all as consequences of elementary divisibility constraints.

The most promising cross-domain connection is between the primorial automaton and symbolic dynamics from the Catalog's `SymbolicDynamics.lean`. The prime gap sequence, viewed as a word over the even-number alphabet, is constrained by a finite-state machine in exactly the way that symbolic dynamics studies orbits constrained by transition matrices. The `realizes_all_patterns` theorem in the Catalog shows that horseshoe maps realize all symbolic patterns; the prime gap automaton is the *opposite* phenomenon — a natural system that forbids certain patterns. Formalizing this duality could connect number theory to dynamical systems in a novel way.

The highest breakthrough potential lies in Direction 1 (Primorial Automaton Spectral Theory): the eigenvalues of the primorial automaton's transition matrix encode deep information about prime gap statistics, and connecting these to the Hardy-Littlewood singular series would provide a new proof pathway for gap distribution conjectures.

---

### Direction 1: Primorial Automaton Spectral Theory

**Conjecture**: The transition matrix of the mod-P# automaton (where P# = 2·3·5·...·p is the primorial) has a spectral gap that converges to 1 - 1/log(P#) as p → ∞, and its stationary distribution approximates the Hardy-Littlewood singular series for gap frequencies.

**Test**: Compute the transition matrices for P# = 6, 30, 210, 2310, and verify that (a) the second-largest eigenvalue decreases as predicted, and (b) the stationary distribution converges to the Hardy-Littlewood predictions for gap frequencies up to some bound B.

**Impact**: If true, this would provide a spectral proof of the Hardy-Littlewood gap conjecture modulo an error term controlled by the spectral gap. If false, the failure would reveal which prime factors contribute most to gap irregularity.

**Catalog References**: `Shared/PrimeGapCrossword.lean` (PrimorialState, admissibleGaps), `Shared/SymbolicDynamics.lean` (SmaleHorseshoe, realizes_all_patterns)

**Proof Strategy**: (1) Define the transition matrix T_P# as a stochastic matrix on φ(P#) states. (2) Prove T_P# is doubly stochastic (by symmetry of coprime residues under negation mod P#). (3) Compute eigenvalues for small primorials. (4) Show the stationary distribution is uniform and relate to gap frequencies via inclusion-exclusion. Key lemma: the number of admissible gaps from any state equals φ(P#), independent of the starting state.

**Domain Bridges**: Number Theory (prime gaps) <-> Linear Algebra (spectral theory) <-> Dynamical Systems (symbolic dynamics, transition matrices)

**Lineage**: Builds on this cycle's PrimorialState definition and admissible_gap_density_bound theorem.

**Ambition**: grand_challenge

---

### Direction 2: Forcing Pattern Density and the Sieve Dimension

**Conjecture**: For the sieve S = {2, 3, 5} with primorial modulus 30, the density of forcing patterns (gap words that uniquely determine the next gap within bound B) among all admissible gap words of length k is bounded below by c · (8/30)^k for some constant c > 0, where 8/30 is the coprime density.

**Test**: Enumerate all admissible gap words of length 1 through 6 over the alphabet {2, 4, 6, ..., 30} and count forcing patterns for each length. Verify the exponential density lower bound computationally. Also test with S = {2, 3, 5, 7} (modulus 210) to see if the density increases.

**Impact**: If true, forcing patterns are common enough to explain the strong short-range correlations in prime gap sequences. This would formalize the "crossword solvability" intuition. If false, it would show that the mod-30 sieve is too coarse to produce forcing, and larger sieves are needed.

**Catalog References**: `Shared/PrimeGapCrossword.lean` (ForcingNextOver, admissibleGaps), `Catalog/Bridges/ForcingPatterns.lean` (ForcingNextOver, AdmissibleAt)

**Proof Strategy**: (1) Formalize the set of admissible gap words as a regular language accepted by the primorial automaton. (2) Use the transfer matrix method to count words. (3) Count forcing words by identifying terminal states with unique outgoing transitions. (4) Apply the Perron-Frobenius theorem to bound the growth rate.

**Domain Bridges**: Number Theory (prime gaps) <-> Formal Language Theory (regular languages, transfer matrices) <-> Combinatorics (pattern enumeration)

**Lineage**: Builds on this cycle's primorial automaton and the existing `ForcingPatterns.lean` in the Catalog.

**Ambition**: extension

---

### Direction 3: Prime Gap Entropy and Information-Theoretic Bounds

**Conjecture**: The Shannon entropy H(g_n | g_{n-1}, ..., g_{n-k}) of the prime gap sequence, conditioned on the k previous gaps, decreases as k increases, and satisfies H(g_n | g_{n-1}, ..., g_{n-k}) ≥ log₂(8/30) · k + C for some constant C, reflecting the mod-30 sieve constraint.

**Test**: Compute conditional entropies from the prime gap sequence up to 10^8 for k = 1, 2, ..., 10. Compare against the theoretical lower bound from the primorial automaton and against the Hardy-Littlewood prediction.

**Impact**: If true, this quantifies how much "information" about the next gap is contained in the previous k gaps — a new perspective connecting number theory to information theory. If false, it would suggest that prime gaps carry less redundancy than the sieve model predicts, hinting at deeper independence properties.

**Catalog References**: `Shared/PrimeGapCrossword.lean` (PrimorialState, transition), `Shared/EntropyAlgebraCrypto.lean` (brute_force_dominates_all)

**Proof Strategy**: (1) Define the conditional entropy in Lean using Mathlib's probability theory. (2) Prove that the primorial automaton's Markov chain has entropy at most log₂(8) per step. (3) Show that conditioning on previous gaps reduces entropy by proving the gap sequence is not i.i.d. under the mod-30 constraints. (4) Use Cramér's model as an upper bound comparison.

**Domain Bridges**: Number Theory (primes) <-> Information Theory (entropy, conditional probability) <-> Cryptography (pseudorandomness bounds)

**Lineage**: Builds on this cycle's primorial automaton and the Catalog's entropy framework.

**Ambition**: extension

---

### Direction 4: Mod-210 Gap Automaton and 48-State Classification

**Conjecture**: The mod-210 (= 2·3·5·7) gap automaton has exactly 48 states (= φ(210)), and among all pairs of consecutive states (r, r') ∈ 𝒜₂₁₀ × 𝒜₂₁₀, at least 15% of (r, gap) transitions are forcing (admit exactly one next state within gap bound 30).

**Test**: Enumerate all 48 states and compute, for each state and each even gap value from 2 to 30, whether the transition lands in 𝒜₂₁₀. Count the number of state-gap pairs that are unique (forcing). Verify the 15% threshold.

**Impact**: If true, the mod-210 sieve is already strong enough to produce a substantial fraction of forcing transitions, suggesting that the "prime crossword" becomes increasingly deterministic as we sieve by more primes. This would be the strongest quantitative evidence for the crossword solvability conjecture.

**Catalog References**: `Shared/PrimeGapCrossword.lean` (admissibleResidues₃₀, PrimorialState), `Catalog/Bridges/PrimeGapCrosswordDeep.lean` (GapAutomaton)

**Proof Strategy**: (1) Define admissibleResidues₂₁₀ computationally. (2) Build the 48×48 transition matrix for gaps {2, 4, ..., 30}. (3) Count forcing pairs by native_decide or explicit enumeration. (4) Prove the 15% bound.

**Domain Bridges**: Number Theory (primes, Euler totient) <-> Automata Theory (finite-state machines) <-> Computational Algebra (modular arithmetic)

**Lineage**: Direct extension of this cycle's mod-30 analysis to the next primorial level.

**Ambition**: extension

---

### Direction 5: Gap Sequence as a Substitution System

**Conjecture**: The prime gap sequence modulo 6 (taking values in {0, 2, 4}) can be approximated by a morphic sequence — a sequence generated by iterated substitution on a finite alphabet — whose substitution rules are derived from the sieve of Eratosthenes applied at each prime level.

**Test**: Define substitution rules σ₃, σ₅, σ₇ corresponding to the sieve by 3, 5, 7 respectively. Compute the first 1000 terms of the iterated substitution σ₇ ∘ σ₅ ∘ σ₃ applied to the initial word, and compare against actual prime gap residues mod 6 for the first 1000 primes. Measure the discrepancy.

**Impact**: If the gap sequence is approximately morphic, it would connect prime distribution to the theory of automatic sequences and substitution dynamical systems — opening an entirely new approach to prime gap conjectures via the spectral theory of substitution matrices. If the approximation fails badly, it would establish a rigorous distinction between the complexity of prime gaps and that of morphic sequences.

**Catalog References**: `Shared/SymbolicDynamics.lean` (Word, realizes_all_patterns), `Shared/PrimeGapCrossword.lean` (prime_mod_six, gap_mod_six)

**Proof Strategy**: (1) Define substitution rules based on the Sieve of Eratosthenes: σ_p maps a gap word to its refinement when sieving by prime p. (2) Prove that σ_p preserves admissibility. (3) Show the iterated substitution converges to a fixed point. (4) Bound the discrepancy between the substitution limit and actual gaps.

**Domain Bridges**: Number Theory (sieve of Eratosthenes) <-> Symbolic Dynamics (substitution systems, morphic sequences) <-> Spectral Theory (substitution matrices, Pisot-Vijayaraghavan numbers)

**Lineage**: Novel direction inspired by the automaton structure discovered in this cycle.

**Ambition**: grand_challenge
