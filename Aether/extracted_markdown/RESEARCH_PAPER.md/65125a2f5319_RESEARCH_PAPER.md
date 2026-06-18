# Spectral Theory of the Gap Automaton: Connecting Prime Gap Combinatorics to Symbolic Dynamics

## Abstract

We develop the spectral theory of the *gap automaton*, a finite-state machine whose states are residue classes modulo a primorial and whose transitions are prime gap values. We prove that the transfer matrix of this automaton governs the growth rate of admissible gap patterns through a matrix-power path correspondence: the (s,t) entry of T^n exactly counts the number of admissible n-step paths from state s to state t. For the primorial sieve mod 6 with alphabet {2,4,6,8,10}, we compute the transfer matrix T = [[1,2],[2,1]], verify its Cayley-Hamilton identity T² − 2T − 3I = 0 yielding eigenvalues 3 and −1, and derive the spectral recurrence T^(n+2) = 2T^(n+1) + 3T^n. We establish that admissible word counts satisfy a submultiplicativity inequality, guaranteeing the existence of the topological entropy via Fekete's lemma. We prove that the number of admissible states of a primorial sieve equals Euler's totient function, bridging the automaton framework to classical analytic number theory. All results are formally verified in Lean 4 with the Mathlib library.

**Keywords**: prime gaps, finite automaton, transfer matrix, subshift of finite type, topological entropy, spectral gap, Euler totient, formal verification

---

## 1. Introduction

The study of prime gaps — the differences p_{n+1} − p_n between consecutive primes — is a central topic in analytic number theory with deep connections to the Riemann Hypothesis, the Hardy-Littlewood conjectures, and recent breakthroughs by Zhang, Maynard, and Tao on bounded gaps.

Most approaches to prime gaps rely on sieve methods or the distribution of zeros of L-functions. In this paper, we develop an alternative algebraic-dynamical framework based on **finite-state automata**. The key observation is that the Sieve of Eratosthenes, when applied modulo a primorial m = ∏_{p ≤ k} p, partitions residue classes into "admissible" (coprime to m) and "forbidden" (sharing a factor with m). The sequence of prime gaps then defines a trajectory through the admissible states, subject to local constraints.

This perspective transforms the study of prime gap distributions into a problem in **symbolic dynamics**: the gap automaton defines a subshift of finite type whose topological entropy equals the logarithm of the spectral radius of the transfer matrix. This connects the combinatorial sieve theory to the ergodic-theoretic machinery of mixing, entropy, and spectral gaps.

### 1.1 Related Work

The automaton-theoretic perspective on primes has precursors in the wheel sieve literature (Pritchard 1981) and in the study of admissible k-tuples (Hardy-Littlewood, Halberstam-Richert). The connection to symbolic dynamics is implicit in the work of Sarnak on Möbius randomness and subshifts (2012), and in the use of transfer matrices in analytic combinatorics (Flajolet-Sedgewick 2009). Our contribution is to make this connection explicit and to provide the first formal verification of the key structural theorems.

## 2. Definitions

### 2.1 Gap Automaton

**Definition 2.1** (Gap Automaton). A *gap automaton* is a tuple A = (m, F) where:
- m ∈ ℕ₊ is the modulus (typically a primorial),
- F ⊂ Fin(m) is the set of forbidden states,
- There exists at least one admissible state (s ∈ Fin(m) with s ∉ F).

The *transition function* is step : Fin(m) × ℕ → Fin(m) defined by step(s, g) = (s + g) mod m.

A state s is *admissible* if s ∉ F.

**Definition 2.2** (Gap Subshift). A *gap subshift* is a pair (A, Σ) where A is a gap automaton and Σ ⊂ ℕ is a finite, nonempty alphabet of allowed gap values. An *admissible path* of length n from state s is a sequence (g₁, ..., gₙ) ∈ Σⁿ such that each intermediate state step(s, g₁ + ... + gₖ) is admissible for k = 1, ..., n.

**Definition 2.3** (Transfer Matrix). The *transfer matrix* T of a gap subshift (A, Σ) is the m × m matrix with entries:

T_{s,t} = |{g ∈ Σ : step(s, g) = t and t is admissible}|

**Definition 2.4** (Gap Entropy). The *gap entropy* of a subshift at scale n is:

h_n = (1/n) · log W_n

where W_n = ∑_{s,t} pathCount(n, s, t) is the total number of admissible n-step paths.

### 2.2 Primorial Sieve

**Definition 2.5** (Primorial Sieve). A gap automaton A = (m, F) is a *primorial sieve* if F = {s ∈ Fin(m) : gcd(s, m) ≠ 1}. That is, the forbidden states are exactly the residues not coprime to the modulus.

## 3. Main Results

### 3.1 Algebraic Structure

**Theorem 3.1** (ℤ-Action). *The step function satisfies:*
*step(step(s, g₁), g₂) = step(s, g₁ + g₂)*

*Proof.* By the associativity and compatibility of modular arithmetic:
((s + g₁) mod m + g₂) mod m = (s + g₁ + g₂) mod m. □

This theorem establishes that the gap automaton is a ℤ-module action on Fin(m), making it amenable to the tools of group representation theory.

**Corollary 3.2.** step(s, 0) = s (identity) and step(s, m) = s (periodicity).

### 3.2 Transfer Matrix Path Correspondence

**Theorem 3.3** (Matrix-Path Correspondence). *For the transfer matrix T (viewed over ℤ), the (s,t) entry of T^n equals the number of admissible n-step paths from s to t:*

*(T^n)_{s,t} = pathCount(n, s, t)*

*Proof.* By induction on n. The base case n = 0 follows from T⁰ = I and pathCount(0, s, t) = δ_{s,t}. The inductive step uses the recurrence pathCount(n+1, s, t) = ∑_u pathCount(n, s, u) · T_{u,t}, which matches the matrix multiplication (T^n · T)_{s,t} = ∑_u (T^n)_{s,u} · T_{u,t}. □

**Theorem 3.4** (Row Sum Bound). *Each row sum of T is bounded by the alphabet size:*

*∑_t T_{s,t} ≤ |Σ|*

*Proof.* Each gap g ∈ Σ can contribute to at most one column t = step(s, g), so the filters {g ∈ Σ : step(s, g) = t ∧ t admissible} are pairwise disjoint subsets of Σ. □

### 3.3 Spectral Theory of the Sieve-6 Automaton

For the primorial sieve with m = 6 (sieving by {2, 3}), the admissible states are {1, 5}, and with the extended alphabet Σ = {2, 4, 6, 8, 10}, the 2×2 admissible transfer matrix is:

T = [[1, 2], [2, 1]]

**Theorem 3.5** (Spectral Data). *The transfer matrix has trace 2 and determinant −3, giving characteristic polynomial λ² − 2λ − 3 = (λ − 3)(λ + 1) = 0 with eigenvalues λ₁ = 3 and λ₂ = −1.*

**Theorem 3.6** (Cayley-Hamilton). *T² − 2T − 3I = 0.*

This is verified computationally and yields:

**Theorem 3.7** (Spectral Recurrence). *T^(n+2) = 2T^(n+1) + 3T^n for all n ≥ 0.*

*Proof.* From T² = 2T + 3I (Cayley-Hamilton), multiply both sides on the left by T^n:
T^n · T² = T^n · (2T + 3I), giving T^(n+2) = 2T^(n+1) + 3T^n. □

**Corollary 3.8.** The entries of T^n satisfy the linear recurrence a_{n+2} = 2a_{n+1} + 3a_n with characteristic roots 3 and −1. The dominant growth is Θ(3^n).

### 3.4 Primitivity and Mixing

**Definition 3.9.** A non-negative matrix M is *entry-positive* if all entries are strictly positive. It is *primitive* if some power M^k is entry-positive.

**Theorem 3.10.** *The sieve-6 transfer matrix T_nat = [[1,2],[2,1]] is entry-positive (hence primitive with k = 1).*

By the Perron-Frobenius theorem, this implies the associated subshift is topologically mixing.

### 3.5 Totient Formula

**Theorem 3.11** (Totient Formula). *For a primorial sieve A with modulus m, the number of admissible states equals Euler's totient:*

*numAdmissible(A) = φ(m)*

*Proof.* By definition, admissibleStates = {s ∈ Fin(m) : s ∉ F} = {s ∈ Fin(m) : gcd(s, m) = 1} (using the primorial sieve condition). This is exactly the set counted by Euler's totient function. We establish a bijection between the admissible states and the elements of {0, ..., m−1} coprime to m. □

**Corollary 3.12.** sieve6 has φ(6) = 2 admissible states.

### 3.6 Submultiplicativity and Entropy

**Theorem 3.13** (Submultiplicativity). *The total path count satisfies:*

*W_{m+n} ≤ W_m · W_n*

*Proof.* Using the path decomposition pathCount(m+n, s, t) = ∑_u pathCount(m, s, u) · pathCount(n, u, t), we sum over all (s, t) and apply the inequality ∑_u a_u b_u ≤ (∑_u a_u)(∑_u b_u) for non-negative sequences to obtain the bound. □

By Fekete's lemma, the sequence h_n = (1/n) log W_n converges, and the limit h = lim h_n is the topological entropy of the gap subshift.

### 3.7 Forcing Criterion

**Theorem 3.14** (Forcing). *If the set of admissible gaps from state s is a singleton {g_forced}, then any admissible continuation from s must use gap g_forced.*

This captures a fundamental constraint: at certain states, the automaton has no freedom, and the next gap is completely determined by the sieve. For sieve-6 with alphabet {2, 4}, state 1 is forced to use gap 4 (since gap 2 leads to forbidden state 3).

## 4. Algorithms

### 4.1 Transfer Matrix Construction

```
Input: modulus m, forbidden set F, alphabet Σ
Output: m × m transfer matrix T

for s in 0..m-1:
  for g in Σ:
    t = (s + g) mod m
    if t not in F:
      T[s][t] += 1
```

Time complexity: O(m · |Σ|). Space: O(m²).

### 4.2 Path Counting via Matrix Exponentiation

```
Input: transfer matrix T, length n
Output: total path count W_n

Compute T^n by repeated squaring
W_n = sum of all entries of T^n
```

Time complexity: O(m³ log n) using repeated squaring.

### 4.3 Entropy Estimation

```
Input: transfer matrix T, precision ε
Output: entropy h ± ε

Find largest eigenvalue λ₁ of T (e.g., via power iteration)
h = log(λ₁)
```

## 5. Discussion

### 5.1 Connections to Existing Theory

The gap automaton framework unifies several threads in prime number theory:

1. **Wheel sieves**: The automaton states correspond to the "spokes" of the wheel sieve. Our transfer matrix generalizes the wheel sieve to track multi-step gap patterns.

2. **Admissible tuples**: An admissible k-tuple (h₁, ..., hₖ) in the Hardy-Littlewood sense corresponds to an admissible path in the gap automaton. The transfer matrix counts these admissible tuples efficiently.

3. **Sarnak's Möbius conjecture**: The gap automaton provides a concrete dynamical system against which to test the orthogonality of the Möbius function.

### 5.2 Spectral Gap and Equidistribution

The spectral gap λ₁ − |λ₂| controls the rate of equidistribution of gap patterns. For sieve-6, the spectral gap is 3 − 1 = 2 (in absolute value, |λ₂| = 1), giving rapid mixing. This suggests that prime gap patterns, when viewed through the automaton lens, exhibit strong equidistribution properties modulo small primorials — consistent with the Hardy-Littlewood conjectures.

### 5.3 Limitations

The gap automaton captures only the *local* constraints imposed by the sieve. It does not account for the *global* distribution of primes (governed by the Prime Number Theorem and its refinements). The actual frequency of gap patterns among primes is determined by a combination of the automaton constraints and the singular series from the Hardy-Littlewood circle method.

## 6. Future Work

1. **Deep sieve asymptotics**: Study the behavior of the entropy h_k as the sieve depth k → ∞. Conjecture: h_k ~ log(φ(p_k#)/p_k#) + correction terms involving Mertens' constant.

2. **Perron-Frobenius formalization**: Formalize the Perron-Frobenius theorem in Lean to obtain the spectral radius interpretation of the entropy.

3. **Connection to L-functions**: Relate the eigenvalues of the transfer matrix to Dirichlet characters mod m, potentially connecting the spectral theory to the zeros of L-functions.

4. **Higher-dimensional analogs**: Extend the framework to tuples of consecutive gaps, obtaining higher-dimensional subshifts.

## 7. Formalization Notes

All theorems in this paper have been formally verified in Lean 4 using the Mathlib library. The formalization consists of approximately 300 lines of Lean code, organized in the `MachineLearning.GapAutomaton.SpectralTheory` module. Key design choices:

- Gap automata are represented as structures with a modulus, forbidden set, and existence witness.
- The transfer matrix uses `Finset.filter` and `Finset.card` for constructive counting.
- Matrix powers use Mathlib's `Matrix` type with its ring structure.
- The totient formula uses `Nat.totient` from Mathlib and establishes a bijection via `Finset.card_bij`.

The complete formal proofs are available in the accompanying Lean files.

## References

1. Flajolet, P., & Sedgewick, R. (2009). *Analytic Combinatorics*. Cambridge University Press.
2. Hardy, G. H., & Littlewood, J. E. (1923). Some problems of 'Partitio Numerorum' III. *Acta Mathematica*, 44, 1–70.
3. Lind, D., & Marcus, B. (1995). *An Introduction to Symbolic Dynamics and Coding*. Cambridge University Press.
4. Mertens, F. (1874). Ein Beitrag zur analytischen Zahlentheorie. *Journal für die reine und angewandte Mathematik*, 78, 46–62.
5. Pritchard, P. (1981). A sublinear additive sieve for finding prime numbers. *Communications of the ACM*, 24(1), 18–23.
6. Sarnak, P. (2012). Mobius randomness and dynamics. *Notices of the AMS*, 59(4), 530–538.
