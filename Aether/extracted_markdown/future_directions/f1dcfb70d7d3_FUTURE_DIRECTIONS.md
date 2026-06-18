# Future Directions: Prime Gap Automaton Theory

## Synthesis

This research cycle established the foundational theory of prime gap constraints as a finite-state automaton problem. We introduced the **Residue Transition System** (RTS) — a structure capturing how modular arithmetic modulo primorials constrains prime gap sequences — and proved a suite of theorems demonstrating its power: the mod-6 automaton correctness, twin prime isolation, forbidden patterns [2,2] and [4,4], the cousin prime state theorem, and the forbidden sextuplet [2,4,2,4,2] via mod-5 analysis. We also proved the Bertrand gap bound (every prime gap is less than the prime itself) and the gap parity theorem. All proofs are machine-verified in Lean 4.

The most promising cross-domain connection is between the RTS and **symbolic dynamics**. The prime gap sequence, viewed as a word over the even-number alphabet, is constrained to lie in a *sofic shift* defined by the RTS automaton. This connects to the Catalog's `SymbolicDynamics.lean` and spectral theory results: the transition matrix of the RTS automaton has spectral properties (eigenvalues, spectral gap) that encode information about prime gap statistics. The existing `spectral_gap_forces_tropical_cycle_gap` theorem in the Catalog could be adapted to give tropical-algebraic bounds on prime gap run lengths. Direction 1 (Spectral Theory of Primorial Automata) has the highest breakthrough potential because it would connect the concrete finite-state machine we built to the deep conjectures of Hardy and Littlewood about prime gap distributions.

A key finding was the failure of the [2,4,2] forbidden pattern — the quadruplet (11, 13, 17, 19) witnesses that this pattern is allowed. This taught us that mod-6 analysis alone cannot capture all constraints; the mod-30 (and higher) automata are needed for deeper forbidden patterns. The successful proof of the [2,4,2,4,2] forbidden sextuplet demonstrates how climbing the primorial ladder yields progressively stronger results.

---

### Direction 1: Spectral Theory of Primorial Automata

**Conjecture**: The transition matrix $T_k$ of the mod-$P_k\#$ automaton (where $P_k\# = 2 \cdot 3 \cdot 5 \cdots p_k$ is the $k$-th primorial) has spectral gap $1 - \lambda_2/\lambda_1$ converging to $1 - 1/\log(P_k\#)$ as $k \to \infty$, and its stationary distribution approaches the Hardy-Littlewood singular series for gap frequencies.

**Test**: Compute the transition matrices $T_k$ for $k = 1, 2, 3, 4$ (moduli 6, 30, 210, 2310). For each, compute the eigenvalues and stationary distribution. Compare the stationary distribution to the Hardy-Littlewood predicted gap frequencies. Measure how the spectral gap scales with $\log(P_k\#)$.

**Impact**: If true, this provides a new proof pathway for prime gap distribution conjectures via spectral methods, connecting number theory to Markov chain mixing theory. If false, the failure mode reveals which aspects of prime gap statistics are NOT captured by modular constraints alone.

**Catalog References**: `Tropical/SpectralTheory.lean` (cycle_gap_spectral_bound_at), `Tropical/MixingTheory.lean` (two_state_spectral_gap_bound), `Tropical/SymbolicDynamics/Core.lean` (tropical_spectral_gap_symbolic_disagreement_bound)

**Proof Strategy**: (1) Define the $\phi(P_k\#) \times \phi(P_k\#)$ adjacency matrix of the RTS transition graph. (2) Prove it is a doubly stochastic matrix (each row and column sums to $\phi(P_k\#)$ transitions). (3) Compute eigenvalues for small cases. (4) Connect the second eigenvalue to gap correlations via standard Markov chain theory. (5) Compare stationary distribution to Hardy-Littlewood predictions.

**Domain Bridges**: Number Theory (prime gaps) ↔ Spectral Graph Theory (adjacency matrix eigenvalues) ↔ Symbolic Dynamics (sofic shift entropy) ↔ Tropical Algebra (cycle mean bounds)

**Lineage**: Builds on this cycle's RTS definition, mod6_transition_correct theorem, and mod6_two_transitions structural result. Extends the Catalog's spectral theory infrastructure.

**Ambition**: grand_challenge

---

### Direction 2: Primorial Chinese Remainder Composition

**Conjecture**: The RTS at modulus $m_1 \cdot m_2$ (with $\gcd(m_1, m_2) = 1$) is isomorphic to the product automaton of the RTS at $m_1$ and the RTS at $m_2$. Formally, $\text{RTS}(m_1 m_2) \cong \text{RTS}(m_1) \times \text{RTS}(m_2)$ as finite-state machines, where the product automaton has state set $S_1 \times S_2$ and transition function $\delta((s_1, s_2), g) = (\delta_1(s_1, g), \delta_2(s_2, g))$.

**Test**: Verify the isomorphism explicitly for $m_1 = 6, m_2 = 5$ (giving $m = 30$). The RTS(6) has 2 states, RTS(5) has 4 states, so the product has 8 states = $\phi(30)$. Check that the transition structure of RTS(30) matches the product.

**Impact**: If true, this gives a decomposition theorem: any primorial automaton factors into independent automata for each prime factor. This would allow parallel analysis — the mod-2 constraint (parity), mod-3 constraint (triplet exclusion), mod-5 constraint (quintuplet bounds) all operate independently. It also gives a formula for the number of forbidden patterns at each primorial level.

**Catalog References**: `Bridges/PrimeGapAutomaton.lean` (ResidueTransitionSystem, RTS6, RTS30)

**Proof Strategy**: (1) Define a morphism from $\text{RTS}(m_1 m_2)$ to $\text{RTS}(m_1) \times \text{RTS}(m_2)$ using the Chinese Remainder Theorem isomorphism $\mathbb{Z}/m_1 m_2 \cong \mathbb{Z}/m_1 \times \mathbb{Z}/m_2$. (2) Show it maps coprime residues to pairs of coprime residues. (3) Show it preserves transitions. (4) Prove bijectivity. The key Mathlib lemma is `ZMod.chineseRemainder`.

**Domain Bridges**: Number Theory (CRT) ↔ Automata Theory (product construction) ↔ Abstract Algebra (group isomorphisms)

**Lineage**: Extends this cycle's RTS definition. The RTS6 and RTS30 definitions provide concrete test cases.

**Ambition**: extension

---

### Direction 3: Forbidden Pattern Enumeration via Automaton Complement

**Conjecture**: The number of forbidden gap words of length $n$ over the mod-$P_k\#$ automaton grows as $\Theta(c_k^n)$ where $c_k = \phi(P_k\#) - \lambda_1(T_k)$ and $\lambda_1$ is the largest eigenvalue of the transition matrix. For the mod-6 automaton, $c_1 = 4$ (since 6 gap residues minus 2 admissible = 4 forbidden per state).

**Test**: Enumerate all forbidden words of length 1 through 6 for the mod-6 and mod-30 automata. Compute the growth rate and compare to the predicted formula. A forbidden word is one where NO starting state leads to all transitions being valid.

**Impact**: This quantifies the "restrictiveness" of the prime gap grammar. If the growth rate follows the predicted formula, it gives a closed-form expression for the information content of prime gap sequences — how many bits per gap are determined by modular constraints alone.

**Catalog References**: `Bridges/PrimeGapAutomaton.lean` (mod6Transition, mod6_two_transitions, forbidden_pattern_22, forbidden_pattern_44)

**Proof Strategy**: (1) Define the "complement automaton" that accepts forbidden words. (2) Compute its transition matrix. (3) Apply the transfer matrix method to count words of length $n$. (4) Extract the growth rate as the spectral radius. (5) Compare to the predicted formula involving $\phi(P_k\#)$.

**Domain Bridges**: Combinatorics on Words (forbidden patterns) ↔ Spectral Graph Theory (transfer matrix) ↔ Information Theory (entropy of constrained sequences)

**Lineage**: Direct extension of this cycle's forbidden_pattern_22, forbidden_pattern_44, and forbidden_pattern_24242 theorems.

**Ambition**: extension

---

### Direction 4: Gap Arithmetic Progression Bound via Covering Systems

**Conjecture**: For any even $g > 0$, the maximum run length of consecutive gaps equal to $g$ among primes $> g$ is at most $g/2 + 1$. More precisely, a run of $k$ consecutive gaps equal to $g$ produces $k+1$ primes in arithmetic progression $p, p+g, p+2g, \ldots, p+kg$. Among these $k+1$ numbers, if $k+1 > g/2 + 1$, then they cover all residue classes modulo some prime $q \leq g$, forcing one to be divisible by $q$.

**Test**: For each $g \in \{2, 4, 6, 8, 10, 12, 14, 16, 18, 20\}$, search for the longest run of consecutive equal gaps among primes up to $10^{10}$. Compare the observed maximum run length to the conjectured bound $g/2 + 1$.

**Impact**: If true, this gives a universal bound on prime arithmetic progressions localized to consecutive primes, extending the Green-Tao theorem's perspective. It would also validate the Gap AP Bound Conjecture stated in this cycle's Lean formalization.

**Catalog References**: `Bridges/PrimeGapAutomaton.lean` (GapAPBoundConjecture, no_consecutive_gap2, no_consecutive_gap4)

**Proof Strategy**: (1) For a run of $k$ consecutive gaps equal to $g$, the primes form an AP with common difference $g$. (2) By the pigeonhole principle, among $k+1$ terms of an AP with difference $g$, if $k+1 > q$ for any prime $q$ dividing... wait, this needs care. The AP $p, p+g, p+2g, \ldots$ modulo a prime $q$ covers $\min(k+1, q)$ distinct residues if $\gcd(g, q) = 1$. If $q \leq k$, all residues are covered, so one term is divisible by $q$. For this to force a composite, need $q \leq k$ and $q$ not dividing $g$. Choose $q$ to be the smallest prime not dividing $g$ and $\leq k+1$.

**Domain Bridges**: Number Theory (covering systems, Green-Tao) ↔ Combinatorics (pigeonhole principle) ↔ Automata Theory (RTS forbidden patterns)

**Lineage**: Extends the gap AP bound cases proved in this cycle ($g=2, g=4$) to general $g$.

**Ambition**: grand_challenge

---

### Direction 5: Tropical Geometry of the Gap Automaton

**Conjecture**: The tropical semiring version of the RTS transition matrix — where addition is replaced by min and multiplication by addition — has a cycle mean (tropical eigenvalue) that equals the minimum average gap achievable under modular constraints. For the mod-6 automaton, this tropical eigenvalue is 2 (the minimum average gap for primes > 3).

**Test**: Compute the tropical eigenvalue of the mod-6 transition matrix (with edge weights equal to the minimum admissible gap for each transition). Verify it equals 2. Repeat for mod-30 and mod-210, comparing to the known average prime gap at those scales.

**Impact**: This connects prime gap minimization to tropical geometry, potentially yielding new lower bounds on prime gaps via the max-plus algebra framework already developed in the Catalog's tropical theory.

**Catalog References**: `Tropical/SpectralTheory.lean` (cycle_gap_spectral_bound_at), `Tropical/WeightedTraceSemantics.lean` (cycle_mean_bound_of_potential), `Tropical/ComplexityTransfer.lean` (spectral_gap_forces_tropical_cycle_gap)

**Proof Strategy**: (1) Assign edge weights to the mod-6 automaton: each transition $(s, g \bmod 6)$ has weight equal to $g$ (the actual gap value). The minimum weight for each transition class is the smallest positive even number with the correct residue mod 6. (2) Compute the tropical eigenvalue as the minimum cycle mean. (3) Prove this equals 2 for mod-6 using explicit computation. (4) For higher moduli, develop bounds using the Catalog's tropical spectral theory.

**Domain Bridges**: Tropical Geometry (max-plus algebra) ↔ Number Theory (prime gaps) ↔ Optimization (minimum cycle mean) ↔ Automata Theory (weighted automata)

**Lineage**: Connects this cycle's RTS framework to the Catalog's extensive tropical algebra infrastructure.

**Ambition**: extension
