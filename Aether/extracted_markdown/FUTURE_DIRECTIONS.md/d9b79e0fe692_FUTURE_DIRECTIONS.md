# Future Directions: Prime Gap Automata Theory

## Synthesis

This research cycle established the foundational theory of prime gap constraints as a finite-state automaton problem. We proved 16 theorems covering prime residue classification (mod 6), the no-prime-triplet theorem, twin and cousin prime forcing rules, gap parity and mod-6 grammar constraints, the three-prime span bound, gap impossibility results, and primorial state density decay. The central novel contribution is the **primorial automaton** — a finite-state machine whose states are coprime residue classes modulo a primorial and whose transitions are prime gaps.

The most promising cross-domain connection is between the primorial automaton and **symbolic dynamics**. The prime gap sequence, viewed as a word over the even-number alphabet, is constrained by a finite-state machine in precisely the way that symbolic dynamics studies orbits constrained by transition matrices. Classical horseshoe dynamics realizes *all* symbolic patterns; the prime gap automaton is the dual phenomenon — a natural system that *forbids* certain patterns. This duality connects number theory to ergodic theory and could be formalized using subshift machinery.

The highest breakthrough potential lies in **Direction 1** (Spectral Theory of Primorial Transition Matrices). The transition matrix of the mod-P# automaton has a stationary distribution that should approximate the Hardy-Littlewood singular series for gap frequencies. If the spectral gap of this matrix can be related to classical constants (twin prime constant, Mertens' constant), it would provide a new pathway from elementary sieve theory to analytic number theory. The density decay results we proved (φ(P#)/P# is strictly decreasing through primorials 6, 30, 210) are the first steps toward quantifying this spectral convergence.

---

### Direction 1: Spectral Theory of Primorial Transition Matrices

**Conjecture**: For the mod-P# automaton (P# = 2·3·5·...·pₖ), define the transition matrix M where M(i,j) = 1 if j = (i + 2) mod P# and gcd(j, P#) = 1, for each admissible gap value. The spectral gap (1 - |λ₂|) of the normalized transition matrix converges to a limit related to the twin prime constant C₂ = ∏(1 - 1/(p-1)²) ≈ 0.6601 as k → ∞.

**Test**: Compute the transition matrices for P# = 6, 30, 210, 2310 and extract their eigenvalues numerically. Plot the spectral gap as a function of k. If the spectral gap converges, fit the limit and compare to C₂. If the spectral gap diverges or oscillates, the conjecture is false.

**Impact**: If true, this provides a spectral-theoretic derivation of the Hardy-Littlewood singular series from elementary sieve theory, bypassing the circle method. If false, understanding *why* the spectral gap fails to converge would reveal which aspects of prime distribution cannot be captured by local modular constraints alone.

**Catalog References**: `Physics/SpectralTheory.lean` (spectral_gap_ratio_test), `Tropical/SpectralTheory.lean` (cycle_gap_spectral_bound_at)

**Proof Strategy**: (1) Define the transition matrix M_k for each primorial level k as a matrix over ℝ indexed by coprime residues. (2) Prove M_k is doubly stochastic (or identify its stationary distribution). (3) Compute eigenvalues for small k (native_decide or norm_num). (4) For the convergence result, use the Chinese Remainder Theorem decomposition of M_k and the multiplicativity of the totient function.

**Domain Bridges**: Number Theory (prime gaps, singular series) ↔ Spectral Theory (eigenvalues of transition matrices) ↔ Ergodic Theory (mixing rates of Markov chains)

**Lineage**: Builds on primorial_state_density_decay, euler_totient_30, admissible_count_eq_totient from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Forbidden Pattern Classification for Gap Sequences

**Conjecture**: The set of gap patterns (g₁, g₂, ..., gₙ) that are *globally* forbidden (never appear as consecutive prime gaps for sufficiently large primes) is exactly the set rejected by the primorial automaton at *every* level. That is, a gap pattern is forbidden if and only if it is rejected by the mod-P# automaton for some primorial P#.

**Test**: For each gap pattern of length 2 up to (g₁, g₂) with g₁, g₂ ∈ {2, 4, 6, 8, 10, 12}, check: (a) is it rejected by the mod-6 automaton? (b) the mod-30 automaton? (c) does it actually appear in the first 10⁶ prime gaps? Patterns that appear computationally but are automaton-rejected at some level would disprove the conjecture. Patterns that never appear but are never automaton-rejected would also disprove it (by showing the automaton misses some forbidden patterns).

**Impact**: If true, it would mean that all prime gap constraints are ultimately local (modular), which would be a profound statement about prime distribution. If false (as is more likely), the *specific* patterns that escape the automaton's grasp would identify exactly where deep analytic number theory is needed.

**Catalog References**: `Geometry/BabelLibrary/Theorems.lean` (symbolic pattern results)

**Proof Strategy**: (1) Formalize the notion of "eventually forbidden" gap pattern. (2) Prove that automaton-rejected patterns are indeed forbidden (straightforward from the Chinese Remainder Theorem). (3) For the converse, try to show that the Hardy-Littlewood conjecture predicts positive density for every automaton-admissible pattern, which would establish the equivalence conditionally on Hardy-Littlewood.

**Domain Bridges**: Number Theory (prime gaps) ↔ Formal Language Theory (forbidden words in subshifts) ↔ Combinatorics (admissible tuples)

**Lineage**: Builds on no_prime_triplet, gap_mod6_constraint, twin_prime_forcing from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Primorial Automaton Entropy and Prime Gap Information Content

**Conjecture**: The topological entropy h(Σ_k) of the subshift defined by the mod-P_k# automaton (the set of bi-infinite gap sequences accepted by the automaton) satisfies h(Σ_k) = log(φ(P_k#)) + O(1/log(P_k#)), and the limit of h(Σ_k)/log(P_k#) equals 1 as k → ∞.

**Test**: Compute the topological entropy of the mod-6, mod-30, and mod-210 gap subshifts by finding the spectral radius of their adjacency matrices. The entropy equals log of the largest eigenvalue. Compare h(Σ_k)/log(P_k#) for k = 2, 3, 4 and check for convergence toward 1.

**Impact**: This would quantify the "information content" of prime gap constraints at each sieve level, measuring how much the automaton reduces the space of possible gap sequences. The entropy ratio approaching 1 would mean that the automaton constraints become increasingly weak relative to the growing alphabet — most of the constraint comes from the first few levels.

**Catalog References**: `Computation/InfoEfficientAlgorithms.lean` (information-theoretic bounds), `Physics/ProofSearchInformation.lean` (theorem_proof_duality)

**Proof Strategy**: (1) Define topological entropy for the primorial subshift using the standard formula (growth rate of admissible words of length n). (2) Relate the adjacency matrix to the transition matrix from Direction 1. (3) Use Perron-Frobenius theory to bound the spectral radius. (4) Apply Mertens' theorem for the asymptotic.

**Domain Bridges**: Number Theory (prime gaps) ↔ Information Theory (entropy of constrained sequences) ↔ Dynamical Systems (subshift entropy)

**Lineage**: Builds on primorial_state_density_decay, mod6_automaton_two_states from this cycle.

**Ambition**: extension

---

### Direction 4: Higher-Order Gap Correlations via Automaton Transfer Matrices

**Conjecture**: The mod-30 automaton's transition matrix, when restricted to gap values ≤ 30, has exactly 8 distinct eigenvalues (matching the 8 states = φ(30)), and the second-largest eigenvalue in absolute value has modulus less than 0.9, implying rapid decorrelation of gap residues.

**Test**: Explicitly construct the 8×8 transition matrix for the mod-30 automaton with gap alphabet {2, 4, 6, 8, ..., 28, 30}. Compute its eigenvalues. Check that there are 8 distinct eigenvalues and that |λ₂| < 0.9. If the eigenvalues are degenerate or |λ₂| ≥ 0.9, the conjecture is false.

**Impact**: Rapid decorrelation (small |λ₂|) would explain why prime gap distributions appear approximately independent over short ranges — the automaton "forgets" its state quickly. This is the modular-arithmetic analog of the mixing time for a Markov chain and could provide a new proof of the equidistribution of primes in residue classes.

**Catalog References**: `Physics/SpectralTheory.lean`, `Tropical/SpectralTheory.lean` (cycle_gap_spectral_bound_at)

**Proof Strategy**: (1) Build the transition matrix as a Lean matrix (Fin 8 → Fin 8 → ℝ). (2) Map coprime residues mod 30 to indices 0–7. (3) For each pair (i, j), count the number of gap values g ∈ {2, 4, ..., 30} such that (residue_i + g) mod 30 = residue_j. (4) Normalize and compute eigenvalues either symbolically (for small matrices) or verify eigenvalue bounds.

**Domain Bridges**: Number Theory (prime residue equidistribution) ↔ Linear Algebra (matrix eigenvalues) ↔ Probability Theory (Markov chain mixing)

**Lineage**: Builds on euler_totient_30, admissible_count_eq_totient from this cycle.

**Ambition**: extension

---

### Direction 5: Automaton-Symbolic Dynamics Duality

**Conjecture**: There exists a topological conjugacy between the prime gap subshift (restricted to gaps ≤ N) and a sofic shift defined by the primorial automaton, in the limit as the primorial level k → ∞ and N → ∞ in a coordinated fashion (specifically, N = P_k#).

**Test**: For the mod-6 automaton, enumerate all length-3 admissible gap words with gaps in {2, 4, 6} and compare to the actual length-3 gap patterns appearing in the first 10⁴ consecutive primes > 3. Compute the ratio of realized/admissible patterns. Repeat for mod-30 with gaps ≤ 30. If the ratio approaches 1 as the primorial level increases, this supports the conjecture.

**Impact**: A formal conjugacy would mean that prime gap statistics are *completely determined* by modular constraints in the limit — a radical reductionist thesis. Even partial results would quantify how much of prime gap behavior is "explained" by local divisibility.

**Catalog References**: `Geometry/BabelLibrary/Theorems.lean` (symbolic dynamics results), `Physics/ShadowingLemma.lean`

**Proof Strategy**: (1) Formalize the sofic shift associated to the primorial automaton (the set of bi-infinite sequences accepted by the automaton). (2) Define a projection map from actual prime gap sequences to the sofic shift. (3) Prove the projection is injective (easy: different gap sequences have different images). (4) For surjectivity, invoke the Hardy-Littlewood conjecture (conditional result).

**Domain Bridges**: Number Theory (prime gaps) ↔ Symbolic Dynamics (sofic shifts, topological conjugacy) ↔ Automata Theory (finite-state acceptors)

**Lineage**: Builds on all results from this cycle, especially the PrimorialAutomaton definition and gap_mod6_constraint.

**Ambition**: grand_challenge
