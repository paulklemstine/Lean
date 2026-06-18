# Future Directions: Prime Gap Transition Theory

## Synthesis

This research cycle established the Gap Transition System — a finite-state automaton framework for studying prime gap sequences — and proved its core structural theorems. The most powerful insight is that prime gaps are not random inputs to a memoryless process, but rather drive transitions in a deterministic finite-state machine whose states are residue classes modulo primorials. This perspective unifies the no-prime-triplet theorem, the gap rhythm theorem, gap sum divisibility, and the existence of forcing patterns into a single algebraic object.

The most promising cross-domain connection is between the Gap Transition System and symbolic dynamics. The gap sequence over the mod-30 automaton is a subshift of finite type: the allowed gap words are exactly those accepted by the 8-state automaton. This connects prime gap theory to the rich machinery of symbolic dynamics — entropy, mixing, zeta functions — already present in the Catalog (cf. `Shared/SymbolicDynamics.lean`, `realizes_all_patterns`). If the gap sequence can be shown to have positive topological entropy as a subshift, this would provide a new proof that infinitely many distinct gap values occur, and potentially connect to the Cramér conjecture.

The second key connection is to Hardy-Littlewood via the singular series. The transition probabilities of the mod-$M$ automaton, in the limit $M \to \infty$ through primorials, should converge to the Hardy-Littlewood singular series $\mathfrak{S}(g)$. Formalizing this limit would provide the first rigorous bridge between the algebraic (automaton) and analytic (singular series) perspectives on prime gaps.

---

### Direction 1: Gap Transition Entropy and Cramér's Conjecture

**Conjecture**: The topological entropy of the prime gap subshift over the mod-30 automaton is $h_{\mathrm{top}} = \log \phi(30) / \log 30 = \log 8 / \log 30 \approx 0.611$. More precisely, the number of admissible gap words of length $k$ with entries bounded by $B$ grows as $\Theta(\lambda^k)$ where $\lambda$ is the spectral radius of the transition matrix.

**Test**: Compute the transition matrix $T$ for the mod-30 gap automaton with gap bound $B = 30$. The matrix $T$ is $8 \times 8$, with $T_{ij}$ = number of even gaps $g \leq B$ such that state $i$ transitions to state $j$. Compute the spectral radius $\rho(T)$. If $\rho(T)^k$ matches the count of admissible words of length $k$ (up to polynomial corrections), the conjecture is confirmed.

**Impact**: If true, this provides a lower bound on the number of distinct gap patterns that can appear, which connects to the Cramér conjecture ($\limsup g_n / (\log p_n)^2 = 1$). The spectral radius determines the "capacity" of the gap channel and bounds how much information each gap carries.

**Catalog References**: `Shared/SymbolicDynamics.lean` (SmaleHorseshoe, realizes_all_patterns), `Bridges/PrimeGapCrosswordDeep.lean` (GapAutomatonState)

**Proof Strategy**: Define the transition matrix explicitly for mod-30 with bounded gaps. Use Perron-Frobenius theory to show the matrix is primitive (all entries eventually positive, by strong connectivity). The spectral radius then equals the growth rate. Strong connectivity follows from our mod-6 strong connectivity theorem lifted to mod-30.

**Domain Bridges**: Symbolic dynamics (subshift entropy) <-> Number theory (prime gap distribution) <-> Linear algebra (Perron-Frobenius)

**Lineage**: Builds on `mod6_strongly_connected`, `GapTransitionSystem`, and the existing `SymbolicDynamics.lean` framework.

**Ambition**: grand_challenge

---

### Direction 2: Forcing Pattern Density and the Sieve Limit

**Conjecture**: For the mod-30 sieve with gap bound $B = 30$, the fraction of gap words of length $k$ that are "forcing" (uniquely determine the next gap) converges to a positive constant $\delta_{30} > 0$ as $k \to \infty$. Computationally, $\delta_{30} \approx 0.08$.

**Test**: Enumerate all admissible gap words of length $k = 1, 2, \ldots, 15$ over the mod-30 automaton with gap entries in $\{2, 4, 6, \ldots, 30\}$. For each word, check if the next gap is uniquely determined. Plot the forcing fraction $F(k)/A(k)$ where $F(k)$ = number of forcing words and $A(k)$ = number of admissible words. If this fraction stabilizes above 0, the conjecture holds.

**Impact**: Positive forcing density would mean that, for a positive fraction of all possible gap histories, the next gap is deterministically known from the sieve alone — no probabilistic input needed. This would quantify the sense in which the prime gap crossword is "partially solvable."

**Catalog References**: `Bridges/PrimeGapCrosswordDeep.lean` (ForcingNextOver, explicit_forcing_23), `Shared/PrimeGapCrossword.lean` (admissibleGaps, forcingPatternConjecture)

**Proof Strategy**: Use the Markov chain formulation on the 8-state automaton. A word is forcing iff it drives the automaton into a state with exactly one admissible next transition. Compute the set of "pre-forcing states" (states from which the next gap is unique) and show the Markov chain hits this set with positive probability from any start state. This reduces to showing the pre-forcing set is non-empty and recurrent.

**Domain Bridges**: Automata theory (forcing states) <-> Sieve theory (admissible patterns) <-> Markov chains (recurrence)

**Lineage**: Builds on `explicit_forcing_23`, `explicit_forcing_23_alt`, `forcing_density_base`.

**Ambition**: extension

---

### Direction 3: Hardy-Littlewood Singular Series from Transition Limits

**Conjecture**: Let $\mathcal{G}(M_k)$ be the gap transition system modulo the $k$-th primorial $M_k = \prod_{i=1}^{k} p_i$. For each even gap $g > 0$, define $\pi_k(g) = |\{s \in S_{M_k} : \delta(s, g) \in S_{M_k}\}| / |S_{M_k}|$ as the fraction of states admitting gap $g$. Then $\lim_{k \to \infty} \pi_k(g) \cdot |S_{M_k}| / |S_{M_k}| = \mathfrak{S}(g) / 2C_2$ where $\mathfrak{S}(g)$ is the Hardy-Littlewood singular series for gap $g$.

**Test**: Compute $\pi_k(g)$ for $k = 1, 2, \ldots, 8$ (moduli 2, 6, 30, 210, 2310, 30030, 510510, 9699690) and gap values $g = 2, 4, 6, 8, 10, 12$. Compare with the known values of $\mathfrak{S}(g)$.

**Impact**: This would provide a constructive, algebraic derivation of the Hardy-Littlewood singular series, replacing the analytic definition (infinite product over primes) with a finite-automaton limit. It would bridge the gap between sieve theory and analytic number theory.

**Catalog References**: `Algebra/Conditional.lean` (twin_primes_of_hardy_littlewood), `Cryptography/CramerPrimeGaps.lean`

**Proof Strategy**: Express $\pi_k(g)$ as a product $\prod_{i=1}^{k} (1 - \nu_i(g)/p_i)$ where $\nu_i(g)$ counts residue classes mod $p_i$ eliminated by gap $g$. For a prime $p$ not dividing $g$, exactly one class is eliminated (the class $-g$ mod $p$), giving factor $(p-1)/p \cdot p/(p-1) = 1$... The actual computation requires careful inclusion-exclusion. Use the Chinese Remainder Theorem to decompose $\pi_k(g)$ into local factors.

**Domain Bridges**: Algebraic number theory (Chinese Remainder Theorem) <-> Analytic number theory (singular series) <-> Automata theory (transition probabilities)

**Lineage**: Builds on `GapTransitionSystem`, `hardyLittlewoodSingularSeries`, `twinPrimeConstant`.

**Ambition**: grand_challenge

---

### Direction 4: Mod-30 Transition Graph Spectral Analysis

**Conjecture**: The transition matrix of $\mathcal{G}(30)$ with even gaps up to 30 has a simple dominant eigenvalue (Perron root), and the corresponding eigenvector has all components equal — reflecting the equidistribution of primes across residue classes (Dirichlet's theorem).

**Test**: Construct the $8 \times 8$ transition matrix explicitly. Compute its eigenvalues. Verify the dominant eigenvalue has multiplicity 1 and the corresponding eigenvector is $(1, 1, 1, 1, 1, 1, 1, 1)$ (up to normalization). Compare the second-largest eigenvalue modulus (mixing rate) with empirical convergence rates of mod-30 residue frequencies.

**Impact**: The spectral gap of the transition matrix controls the rate at which the gap sequence "forgets" its starting state — connecting to mixing times in the theory of Markov chains and potentially to error terms in the prime number theorem for arithmetic progressions.

**Catalog References**: `Shared/PrimeGapCrossword.lean` (PrimorialState, admissibleResidues₃₀, transition), `Shared/PrimeGapTransitions.lean` (GapTransitionSystem, gtsTransition)

**Proof Strategy**: Define the transition matrix as a `Matrix (Fin 8) (Fin 8) ℝ` in Lean. Verify it is doubly stochastic (or regular) using `native_decide` or `norm_num` for the finite entries. Apply Perron-Frobenius to conclude the dominant eigenvector is uniform. The spectral gap requires bounding the second eigenvalue, which may be computationally tractable for an 8×8 matrix.

**Domain Bridges**: Spectral graph theory <-> Markov chain theory <-> Prime distribution

**Lineage**: Builds on `mod6_strongly_connected`, `prime_in_admissible_mod30`, `gap_alphabet_size_mod30`.

**Ambition**: extension

---

### Direction 5: Gap Transition Monoid and Burnside Groups

**Conjecture**: The transition monoid of $\mathcal{G}(M)$ — the monoid generated by the transition maps $\delta_g : s \mapsto s + g$ restricted to units of $\mathbb{Z}/M\mathbb{Z}$ — is isomorphic to $(\mathbb{Z}/M\mathbb{Z})^\times$ for $M$ a primorial. In particular, for $M = 30$, the transition monoid is $(\mathbb{Z}/30\mathbb{Z})^\times \cong \mathbb{Z}/2\mathbb{Z} \times \mathbb{Z}/2\mathbb{Z} \times \mathbb{Z}/2\mathbb{Z}$.

**Test**: Compute the Cayley table of the transition monoid for $M = 30$ by composing all pairs of gap-induced permutations for gaps $g = 2, 4, 6, \ldots, 28$. Verify the resulting structure is $(\mathbb{Z}/2)^3$.

**Impact**: Understanding the algebraic structure of the transition monoid constrains which gap words are equivalent (produce the same net state transition). This could classify forcing patterns algebraically rather than computationally, and connect to Burnside's theorem on finite group actions.

**Catalog References**: `Shared/PrimeGapTransitions.lean` (GapTransitionSystem, gtsTransition, reachableFrom)

**Proof Strategy**: Show that the translation maps $\tau_g : s \mapsto s + g$ on $(\mathbb{Z}/M\mathbb{Z})^\times$ form a group isomorphic to $\mathbb{Z}/M\mathbb{Z}$ when $\gcd(g, M) = 1$. For gap values, only even $g$ appear, restricting to a subgroup. Compute this subgroup explicitly for $M = 30$.

**Domain Bridges**: Finite group theory <-> Automata theory <-> Sieve theory

**Lineage**: Builds on `GapTransitionSystem`, `mod6_strongly_connected`.

**Ambition**: extension
