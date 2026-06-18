# Future Research Directions: Gap Automaton Spectral Theory

## Synthesis

This research cycle formalized the spectral theory of the gap automaton — a finite-state machine whose states are residue classes modulo a primorial and whose transitions are prime gap values. We proved ten theorems establishing: (1) the ℤ-action structure of transitions, (2) the matrix-power path correspondence (T^n counts n-step admissible paths), (3) the Cayley-Hamilton identity and spectral recurrence for the sieve-6 transfer matrix, (4) submultiplicativity of path counts (enabling entropy existence via Fekete's lemma), (5) the Euler totient formula for admissible state counts, (6) entry-positivity (hence primitivity) of the sieve-6 transfer matrix, and (7) the forcing criterion for gap determination.

The most promising cross-domain connection discovered is between the **transfer matrix spectral theory** and the **Perron-Frobenius framework** for non-negative matrices. The gap automaton's transfer matrix is a concrete, number-theoretically motivated instance of a non-negative matrix whose spectral radius controls the growth of a combinatorial quantity (admissible gap words). This connects the prime gap combinatorics of classical analytic number theory to the ergodic theory of subshifts of finite type, opening pathways to equidistribution results for prime gap patterns. The framework bridges the Catalog's existing spectral gap results (`Tropical/SymbolicDynamics/Core.lean`) and prime gap infrastructure (`MachineLearning/PrimeGaps/Admissible.lean`) with new tools from matrix spectral theory.

Direction 1 (Deep Sieve Entropy Asymptotics) has the highest breakthrough potential because it would provide the first rigorous, sieve-depth-dependent entropy bound on prime gap patterns — potentially connecting to the Mertens constant and the Hardy-Littlewood singular series.

---

### Direction 1: Deep Sieve Entropy Asymptotics

**Conjecture**: For the primorial sieve automaton at depth k (sieving by primes {2, 3, ..., p_k} with modulus m_k = p_k#), the topological entropy h_k = log λ₁(T_k) satisfies:

h_k = log(φ(m_k)) − (1/2) log(m_k) + O(1)

as k → ∞, where φ is Euler's totient function. Equivalently, the spectral radius λ₁(T_k) of the transfer matrix grows as Θ(φ(m_k) / √m_k) with the alphabet Σ_k = {2, 4, ..., 2p_{k+1}}.

**Test**: Compute T_k for k = 1, 2, 3, 4 (moduli 2, 6, 30, 210) and compare log λ₁(T_k) against the predicted formula. The Perron-Frobenius eigenvalue can be found numerically via power iteration on the explicit transfer matrix.

**Impact**: If true, this gives a precise, sieve-depth-dependent entropy for the space of admissible gap patterns, connecting the automaton framework to Mertens' theorem (∏_{p ≤ k} (1 − 1/p) ~ e^{-γ}/log k). If false, the failure reveals unexpected correlations in the transfer matrix structure beyond what the totient formula predicts.

**Catalog References**: `MachineLearning/PrimeGaps/Admissible.lean`, `MachineLearning/PrimeGaps/Density.lean`

**Proof Strategy**: 
1. Construct the transfer matrix T_k explicitly for small k using the sieve construction.
2. Use the Perron-Frobenius theorem (to be formalized) to bound λ₁ between the minimum and maximum row sums.
3. Show that row sums concentrate around φ(m_k)/m_k · |Σ_k| using the Chinese Remainder Theorem structure.
4. Relate the concentration to Mertens' product formula.

**Domain Bridges**: Prime number theory <-> Symbolic dynamics, Transfer matrices <-> Markov chains, Sieve theory <-> Spectral theory

**Lineage**: Builds on this cycle's transfer matrix path correspondence (pathCount_eq_matPow), row sum bound (row_sum_le_alphabet), and totient formula (primorial_admissible_eq_totient).

**Ambition**: grand_challenge

---

### Direction 2: Perron-Frobenius Theorem for Gap Transfer Matrices

**Conjecture**: For any primorial sieve automaton with alphabet containing at least one even gap value, the transfer matrix restricted to admissible states is primitive (some power has all positive entries), and hence has a unique dominant real eigenvalue λ₁ > |λ_i| for all other eigenvalues λ_i.

**Test**: Verify primitivity computationally for sieve depths k = 1 through 5 by computing successive powers of the restricted transfer matrix and checking entry-positivity. For k = 1 (sieve-6), we already proved this (sieve6_entry_positive). For k = 2 (sieve-30), construct the 8×8 matrix and check.

**Impact**: If true, this provides the foundation for applying the full Perron-Frobenius machinery to gap automata — including the existence of a positive eigenvector (the "stationary distribution" of gap patterns), exponential mixing, and the spectral gap bound on correlations.

**Catalog References**: `Tropical/SymbolicDynamics/Core.lean`, `MachineLearning/QuantumCayleyWalk/Theorems.lean`

**Proof Strategy**:
1. Formalize the Perron-Frobenius theorem for non-negative integer matrices (or use existing Mathlib infrastructure if available).
2. Show that the gap automaton's transition graph is strongly connected: for any two admissible states s, t, there exists a sequence of gaps connecting them.
3. Strong connectivity + aperiodicity (which follows from the existence of a self-loop, i.e., a gap g with step(s, g) admissible and equal to s) implies primitivity.
4. For primorial sieves, show that gap g = m (the modulus) is always a self-loop for every admissible state.

**Domain Bridges**: Linear algebra (Perron-Frobenius) <-> Combinatorics (graph connectivity) <-> Number theory (coprimality)

**Lineage**: Builds on sieve6_entry_positive and step_modulus from this cycle.

**Ambition**: extension

---

### Direction 3: Dirichlet Character Decomposition of the Transfer Matrix

**Conjecture**: The eigenvalues of the primorial sieve transfer matrix T_k can be expressed in terms of Dirichlet characters modulo m_k = p_k#. Specifically, if χ ranges over the Dirichlet characters mod m_k, then the eigenvalues of T_k restricted to admissible states are:

λ_χ = ∑_{g ∈ Σ_k} χ(g) · [g leads to an admissible state]

and the spectral radius equals the eigenvalue for the principal character χ₀: λ₁ = λ_{χ₀}.

**Test**: For sieve-6 with characters mod 6, compute λ_{χ₀} and λ_{χ₁} (there are two characters mod 6: the principal character and the non-principal one). Verify that λ_{χ₀} = 3 and λ_{χ₁} = −1, matching our known eigenvalues. Extend to sieve-30 with its 8 characters and compare against numerical eigenvalues of the 8×8 matrix.

**Impact**: If true, this provides a direct bridge from the gap automaton spectral theory to L-functions and the analytic theory of primes. The spectral gap λ₁ − |λ₂| would be controlled by character sums, connecting to the Generalized Riemann Hypothesis.

**Catalog References**: `Algebra/ArtinPrimitiveRoot.lean`, `MachineLearning/ModPSpectralFingerprint.lean`

**Proof Strategy**:
1. Show that the transfer matrix commutes with the action of (ℤ/mℤ)× on admissible states (this is the translation equivariance property).
2. By Schur's lemma, the eigenspaces of T decompose along the irreducible representations of (ℤ/mℤ)×, which are exactly the Dirichlet characters.
3. Compute the eigenvalue for each character as a character sum over the alphabet.

**Domain Bridges**: Number theory (Dirichlet characters, L-functions) <-> Representation theory <-> Spectral theory

**Lineage**: Builds on the transfer matrix framework and totient formula from this cycle.

**Ambition**: grand_challenge

---

### Direction 4: Fekete's Lemma and Formal Entropy Existence

**Conjecture**: The gap entropy limit h = lim_{n→∞} (1/n) log W_n exists for any gap subshift with non-trivial transfer matrix (at least one admissible transition). Moreover, h = log λ₁(T) where λ₁ is the spectral radius.

**Test**: Formally verify that the sequence a_n = log W_n is subadditive (i.e., a_{m+n} ≤ a_m + a_n) using the submultiplicativity theorem already proved. Then formalize Fekete's lemma to obtain convergence. For sieve-6, verify numerically that (1/n) log W_n → log 3 as n increases.

**Impact**: If formalized, this would be the first machine-verified proof of entropy existence for a number-theoretically defined subshift. It would also provide a template for formalizing topological entropy in Lean more generally.

**Catalog References**: `MachineLearning/GapAutomaton/SpectralTheory.lean` (pathCount_submultiplicative)

**Proof Strategy**:
1. Formalize Fekete's lemma: if a_{m+n} ≤ a_m + a_n for all m, n, then lim a_n/n = inf a_n/n.
2. Apply to a_n = log W_n using pathCount_submultiplicative.
3. For the equality h = log λ₁, use the matrix-power path correspondence and the spectral radius formula ρ(T) = lim ||T^n||^{1/n}.

**Domain Bridges**: Analysis (Fekete's lemma) <-> Combinatorics (subadditivity) <-> Dynamics (topological entropy)

**Lineage**: Directly extends pathCount_submultiplicative from this cycle.

**Ambition**: extension

---

### Direction 5: Multi-Gap Correlations and Higher-Order Transfer Tensors

**Conjecture**: The gap automaton framework extends naturally to k-tuples of consecutive gaps by defining a higher-order transfer tensor T^(k) whose entries count k-step admissible paths with specified intermediate states. The "k-gap entropy" h^(k) = lim (1/n) log W_n^(k) (where W_n^(k) counts admissible n-step paths with k-tuple constraints) satisfies h^(k) ≤ h^(1) with equality if and only if the gap process is Markovian (memoryless).

**Test**: For sieve-6 with alphabet {2,4}, compute the 2-gap transfer tensor (a 2×2×2 array) and compare its entropy against the 1-gap entropy. Since the sieve-6 automaton with alphabet {2,4} is deterministic (forcing at every step), we expect h^(1) = 0 and h^(k) = 0 for all k. Test with the larger alphabet {2,4,6,8,10} where h^(1) = log 3.

**Impact**: If the inequality h^(k) < h^(1) for some k, this reveals non-Markovian structure in prime gap patterns — meaning that consecutive gaps are correlated beyond what the local sieve constraints predict. This would be a new structural result about prime gaps.

**Catalog References**: `MachineLearning/GapAutomaton/SpectralTheory.lean`, `Tropical/SymbolicDynamics/Core.lean`

**Proof Strategy**:
1. Define the k-gap transfer tensor as a function Fin(m)^{k+1} → ℕ.
2. Show that the 1-gap transfer matrix is a "marginal" of the 2-gap tensor.
3. Use the data processing inequality (or its combinatorial analog) to prove h^(k) ≤ h^(k-1).
4. Characterize equality as the Markov property.

**Domain Bridges**: Information theory (data processing inequality) <-> Ergodic theory (higher-order mixing) <-> Number theory (gap correlations)

**Lineage**: Extends the transfer matrix framework from this cycle to higher dimensions.

**Ambition**: extension
