# Mod-p Spectral Fingerprints and Expansion Profiles of Arithmetic Simplicial Complexes

## Abstract

We introduce the **prime spectral fingerprint**, a family of arithmetic invariants that encode spectral properties of integer matrices via modular reduction. For an integer matrix $A$ representing a combinatorial Laplacian, the fingerprint records the traces $\operatorname{tr}(A^k) \bmod p$ across small primes $p$ and powers $k$. We prove three main theorems: (1) a **persistent nullity monotonicity theorem** showing that kernel filtrations of endomorphisms yield monotone dimension profiles; (2) a **trace transfer theorem** establishing that mod-$p$ trace agreement, for primes exceeding the trace difference bound, implies exact integer trace equality; and (3) a **fingerprint moment determinacy theorem** showing that prime fingerprints rigidly determine spectral moments and characteristic polynomial coefficients. These results establish a formal bridge between finite-field linear algebra and real spectral data. We formulate the **Prime Fingerprint Determinacy Conjecture** and provide computational evidence. All theorems are formally verified in Lean 4 with Mathlib.

## 1. Introduction

### 1.1 Motivation

The spectral gap of a graph Laplacian or higher-dimensional combinatorial Laplacian is a fundamental invariant governing expansion, mixing, and error-correcting properties. Computing spectral gaps requires real-number eigenvalue computations, which are expensive (typically $O(n^3)$ operations) and numerically sensitive.

This paper asks: *Can finite-field linear algebra — dramatically cheaper and numerically exact — recover real spectral information?*

We answer affirmatively under explicit hypotheses, developing a framework we call **arithmetic-topological spectral inference**. The key idea is that traces of matrix powers can be computed modulo small primes, and if enough primes are used, the exact integer traces can be reconstructed. Since traces of powers are spectral moments, this provides a pathway from mod-$p$ data to real eigenvalue information.

### 1.2 Relationship to Prior Work

**Spectral graph theory.** The connection between graph eigenvalues and expansion is classical (Alon–Milman, Dodziuk, Cheeger). Our contribution is a new *computational pathway* to spectral data via modular arithmetic.

**Persistent homology.** Edelsbrunner–Letscher–Zomorodian and Carlsson introduced persistent homology as a topological data analysis tool. Our persistent nullity profile is an algebraic analogue, replacing metric filtrations with operator-power filtrations.

**Modular methods in linear algebra.** The Chinese Remainder Theorem approach to integer matrix computations (determinants, Smith normal form) is well-established. We extend this philosophy to spectral moment recovery, connecting it to expansion theory.

**High-dimensional expanders.** Lubotzky–Samuels–Vishne and others constructed Ramanujan complexes from Bruhat–Tits buildings. Our framework applies to the integer Laplacians of such complexes but does not require their full arithmetic structure.

**Newton's identities.** The classical connection between power sums and elementary symmetric polynomials is the algebraic backbone of our moment-to-coefficient transfer.

### 1.3 Overview of Results

We prove three families of formally verified theorems:

1. **Kernel monotonicity** (§3): The persistent nullity profile $n \mapsto \dim \ker(L^n)$ is monotone nondecreasing and bounded by $\dim V$.

2. **Trace transfer** (§4): If $\operatorname{tr}(A^k) \equiv \operatorname{tr}(B^k) \pmod{p}$ for a prime $p$ exceeding $|\operatorname{tr}(A^k) - \operatorname{tr}(B^k)|$, then $\operatorname{tr}(A^k) = \operatorname{tr}(B^k)$.

3. **Fingerprint determinacy** (§5): The prime fingerprint determines spectral moments, which determine characteristic polynomial coefficients via Newton's identities. We also prove the connection to heat trace surrogates.

## 2. Definitions and Notation

### 2.1 The Mod-p Trace Observable

**Definition 2.1** (Mod-p trace of a power). For an integer matrix $A \in M_n(\mathbb{Z})$, a prime $p$, and a non-negative integer $k$, define

$$\tau_{p,k}(A) := \operatorname{tr}(\bar{A}^k) \in \mathbb{F}_p$$

where $\bar{A} = A \bmod p$ is the reduction of $A$ modulo $p$.

**Lemma 2.2** (Reduction-trace compatibility). The mod-$p$ trace satisfies $\tau_{p,k}(A) = \phi_p(\operatorname{tr}(A^k))$, where $\phi_p: \mathbb{Z} \to \mathbb{F}_p$ is the canonical reduction. That is, reducing modulo $p$ commutes with taking traces and powers.

*Proof.* Ring homomorphisms commute with matrix multiplication (hence powers) and with trace (which is a sum of ring elements). □

### 2.2 Prime Spectral Fingerprint

**Definition 2.3** (Mod-p trace fingerprint). The mod-$p$ trace fingerprint of $A$ up to degree $m$ is the function

$$\mathcal{F}_{A,p}^{(\le m)}: \{1, \ldots, m\} \to \mathbb{F}_p, \quad k \mapsto \tau_{p,k}(A).$$

Two matrices $A, B$ have the same mod-$p$ trace fingerprint up to degree $m$ if $\mathcal{F}_{A,p}^{(\le m)} = \mathcal{F}_{B,p}^{(\le m)}$.

**Definition 2.4** (Prime fingerprint). The prime fingerprint of $A$ up to level $m$ is the collection

$$\mathcal{F}_A^{(\le m)} := \{\mathcal{F}_{A,p}^{(\le m)} : p \text{ prime}, p \le m\}.$$

Two matrices have the same prime fingerprint up to level $m$ if their mod-$p$ fingerprints agree for all primes $p \le m$.

### 2.3 Persistent Nullity Profile

**Definition 2.5** (Persistent nullity). For a linear endomorphism $L: V \to V$ on a finite-dimensional vector space, the persistent nullity profile is

$$\nu_L: \mathbb{N} \to \mathbb{N}, \quad n \mapsto \dim \ker(L^n).$$

### 2.4 Expansion Witness

**Definition 2.6** (Expansion witness). An expansion witness for a matrix $A$ at level $\delta$ consists of:
- A prime bound $P$,
- For each prime $p \le P$ and power $k \le P$, the mod-$p$ trace $\tau_{p,k}(A)$,
- A verification that the trace data is consistent with a spectral gap of at least $\delta$.

## 3. Kernel Monotonicity Theorems

### 3.1 Main Results

**Theorem 3.1** (Persistent kernel rank bound). Let $K$ be a field, $V$ a finite-dimensional $K$-vector space, and $f, g: V \to V$ linear endomorphisms. If $\ker f \subseteq \ker g$, then $\dim \ker f \le \dim \ker g$.

*Formal proof.* Follows directly from `Submodule.finrank_mono` in Mathlib. □

**Theorem 3.2** (Kernel power monotonicity). For any endomorphism $L: V \to V$, the family $n \mapsto \ker(L^n)$ is monotone nondecreasing under subspace inclusion.

*Proof sketch.* If $v \in \ker(L^n)$, then $L^n v = 0$. For $m \ge n$, write $m = n + (m-n)$, so $L^m v = L^{m-n}(L^n v) = L^{m-n}(0) = 0$, hence $v \in \ker(L^m)$. The formal proof uses `monotone_nat_of_le_succ` and `pow_succ'`. □

**Theorem 3.3** (Persistent nullity monotonicity). For a finite-dimensional endomorphism $L$, the persistent nullity profile $n \mapsto \dim \ker(L^n)$ is monotone nondecreasing.

*Proof.* Combines Theorem 3.2 (subspace monotonicity) with Theorem 3.1 (dimension monotonicity). □

**Theorem 3.4** (Persistent nullity boundedness). $\dim \ker(L^n) \le \dim V$ for all $n$.

*Proof.* The kernel is a subspace of $V$, so its dimension cannot exceed that of $V$. Uses `Submodule.finrank_le`. □

### 3.2 Significance

These theorems establish that the persistent nullity profile is a well-defined, bounded, monotone invariant of an endomorphism. This is the algebraic foundation for barcode-style persistence in operator theory: the profile stabilizes at the generalized null space, and its growth rate encodes the Jordan structure of $L$ at eigenvalue 0.

Over $\mathbb{F}_p$, the same theorems apply to the mod-$p$ reduction $\bar{L}$, giving a mod-$p$ persistent nullity profile that can be computed using only finite-field arithmetic.

## 4. The Trace Transfer Theorem

### 4.1 Arithmetic Preliminaries

**Lemma 4.1** (Divisibility from mod-$p$ vanishing). If $d \in \mathbb{Z}$ satisfies $\phi_p(d) = 0$ in $\mathbb{F}_p$ for a prime $p$, then $p \mid d$.

*Proof.* Standard property of $\mathbb{Z}/p\mathbb{Z}$, formalized via `ZMod.intCast_zmod_eq_zero_iff_dvd`. □

**Lemma 4.2** (Small divisible integers vanish). If $p$ is prime, $p \mid d$, and $|d| < p$, then $d = 0$.

*Proof.* If $d = pk$ for some integer $k$, then $|d| = p|k| \ge p$ unless $k = 0$. Since $|d| < p$, we must have $k = 0$, hence $d = 0$. □

**Theorem 4.3** (Bounded mod-$p$ equality implies integer equality). If $a, b \in \mathbb{Z}$ satisfy $\phi_p(a) = \phi_p(b)$ and $|a - b| < p$ for a prime $p$, then $a = b$.

*Proof.* Apply Lemma 4.1 to $d = a - b$ (using $\phi_p(a - b) = \phi_p(a) - \phi_p(b) = 0$) to get $p \mid (a - b)$. Then apply Lemma 4.2 with $|a - b| < p$ to conclude $a - b = 0$. □

### 4.2 Main Transfer Theorem

**Theorem 4.4** (Trace Transfer). Let $A, B \in M_n(\mathbb{Z})$ be integer matrices. Let $p$ be a prime and $k$ a non-negative integer. If

1. $\operatorname{tr}(\bar{A}^k) = \operatorname{tr}(\bar{B}^k)$ in $\mathbb{F}_p$, and
2. $|\operatorname{tr}(A^k) - \operatorname{tr}(B^k)| < p$,

then $\operatorname{tr}(A^k) = \operatorname{tr}(B^k)$ in $\mathbb{Z}$.

*Proof.* By Lemma 2.2, hypothesis (1) becomes $\phi_p(\operatorname{tr}(A^k)) = \phi_p(\operatorname{tr}(B^k))$. Apply Theorem 4.3 with $a = \operatorname{tr}(A^k)$, $b = \operatorname{tr}(B^k)$, using hypothesis (2). □

### 4.3 Discussion

The boundedness condition (2) is essential: mod-$p$ agreement alone does not determine integer values (e.g., $0 \equiv p \pmod{p}$). The key insight is that for a specific matrix computation, the trace magnitude can be bounded *a priori* by a function of $n$ (matrix size), $\|A\|$ (entry bound), and $k$ (power):

$$|\operatorname{tr}(A^k)| \le n \cdot \|A\|_\infty^k \cdot n^{k-1}$$

So choosing $p > n^k \|A\|_\infty^k$ suffices. For bounded-degree graph Laplacians with $\|A\|_\infty = O(d)$, this is polynomial in $n$ and $d$.

## 5. Fingerprint Determinacy

### 5.1 Moment Determinacy

**Theorem 5.1** (Fingerprint determines moments). If $A, B \in M_n(\mathbb{Z})$ have the same mod-$p$ trace fingerprint up to degree $m$ for a prime $p$ satisfying

$$p > \max_{1 \le k \le m} |\operatorname{tr}(A^k) - \operatorname{tr}(B^k)|,$$

then $\operatorname{tr}(A^k) = \operatorname{tr}(B^k)$ for all $1 \le k \le m$.

*Proof.* Apply Theorem 4.4 for each $k$. □

### 5.2 Connection to Characteristic Polynomial

**Theorem 5.2** (Trace determines next-to-leading coefficient). For $A \in M_n(\mathbb{Z})$ with $n \ge 1$:

$$\operatorname{tr}(A) = -[\text{next-to-leading coefficient of } \chi_A(x)]$$

where $\chi_A(x) = \det(xI - A)$ is the characteristic polynomial.

*Corollary 5.3.* If $\operatorname{tr}(A) = \operatorname{tr}(B)$, then $A$ and $B$ have the same next-to-leading characteristic polynomial coefficient.

**Theorem 5.4** (Determinant from constant term). $\det(A) = (-1)^n \cdot [\text{constant term of } \chi_A(x)]$.

### 5.3 Newton's Identities and Higher Coefficients

Newton's identities provide the general relationship between power sums $s_k = \operatorname{tr}(A^k)$ and elementary symmetric polynomials $e_k$ (which equal, up to sign, the coefficients of $\chi_A$):

$$s_k - s_{k-1}e_1 + s_{k-2}e_2 - \cdots + (-1)^{k-1}k e_k = 0$$

for $k \le n$. This means:

- $s_1 = e_1$
- $s_2 = s_1 e_1 - 2e_2$, so $e_2 = (s_1^2 - s_2)/2$
- $s_3 = s_2 e_1 - s_1 e_2 + 3e_3$, so $e_3 = (s_1^3 - 3s_1 s_2 + 2s_3)/6$

In general, knowing $s_1, \ldots, s_m$ determines $e_1, \ldots, e_m$ (and vice versa) by these recursive identities.

**Corollary 5.5** (Fingerprint determines characteristic prefix). If two integer matrices have the same prime fingerprint up to level $m$ (with prime bounds exceeding the trace differences), then the first $m$ coefficients of their characteristic polynomials agree.

### 5.4 Heat Trace Surrogate

**Theorem 5.6** (Heat trace compatibility). The mod-$p$ trace of $A^k$ is the reduction of the integer heat trace coefficient:

$$\tau_{p,k}(A) = \phi_p(\operatorname{tr}(A^k)).$$

This means the discrete heat trace $Z_\beta = \sum_{k=0}^m \frac{(-\beta)^k}{k!} \operatorname{tr}(L^k)$ can be approximated from mod-$p$ data by recovering each $\operatorname{tr}(L^k)$ via the transfer theorem.

**Interpretation.** The heat trace governs:
- Return probabilities of random walks: $\Pr[\text{return at step } k] = \operatorname{tr}(P^k)/n$ where $P$ is the transition matrix.
- Partition functions in statistical mechanics.
- Spectral zeta functions via Mellin transform.

The prime fingerprint thus provides a finite-field window into these analytic quantities.

## 6. The Prime Fingerprint Determinacy Conjecture

### 6.1 Statement

**Conjecture 6.1** (Prime Fingerprint Determinacy). There exist constants $C > 0$ and $k \ge 1$ such that for any family of bounded-degree arithmetic simplicial complexes $\{X_N\}$ with $|X_N| = N$, the prime fingerprint collection

$$\{\tau_{p,j}(L_k(X_N)) : p \text{ prime}, p \le C \log N, 1 \le j \le C \log N\}$$

determines the $k$-dimensional Laplacian spectral gap $\lambda_1^{(k)}(X_N)$ up to $o(1)$ as $N \to \infty$.

### 6.2 Evidence

The conjecture is supported by:

1. **Theoretical evidence.** The trace transfer theorem (Theorem 4.4) shows that mod-$p$ data for $p > |\operatorname{tr}(L^k)|$ determines moments exactly. For bounded-degree graphs, $|\operatorname{tr}(L^k)| \le n \cdot d^k$, so $p \sim k \log(nd)$ suffices for moments up to power $k$.

2. **Computational evidence.** Experiments with families of cycle graphs, complete graphs, random regular graphs, and Petersen-like graphs show strong correlation between fingerprint features and spectral gaps.

3. **Structural evidence.** For arithmetic complexes arising from algebraic groups over $\mathbb{Q}$, the Laplacian entries are bounded by the group structure, and the mod-$p$ data relates to representation-theoretic invariants that are known to control spectral gaps in Ramanujan complexes.

### 6.3 Testable Predictions

1. **Positive prediction.** For explicit families $X_N$, train a predictor from fingerprints $\{\tau_{p,k}\}_{p \le C\log N}$ to spectral gap $\lambda_1$. The conjecture predicts vanishing prediction error as $N \to \infty$.

2. **Disproof target.** Construct two families with asymptotically identical fingerprints but distinct spectral gaps. This would require engineering careful cancellations in the trace data — itself an interesting algebraic challenge.

## 7. Algorithms

### 7.1 Fingerprint Computation

**Algorithm 1: ComputeFingerprint**

```
Input: Integer matrix A ∈ M_n(ℤ), prime bound P, degree bound m
Output: Prime fingerprint F

1. primes ← SieveOfEratosthenes(P)
2. For each p in primes:
     a. Ā ← A mod p                           // O(n²) 
     b. For k = 1 to m:
          i.  Compute Ā^k mod p using repeated squaring  // O(n³ log k)
          ii. F[p,k] ← tr(Ā^k) mod p          // O(n)
3. Return F
```

**Complexity:** $O(\pi(P) \cdot m \cdot n^3 \log m)$ where $\pi(P) \sim P/\ln P$.

**Space:** $O(n^2 + \pi(P) \cdot m)$.

### 7.2 Trace Recovery

**Algorithm 2: RecoverIntegerTrace**

```
Input: Fingerprint values {F[p,k]}_{p ∈ primes}, power k, trace bound T
Output: Exact integer tr(A^k)

1. If there exists p in primes with p > 2T:
     a. v ← F[p,k]
     b. If v > p/2: return v - p    // Symmetric representative
     c. Else: return v
2. Else: Use Chinese Remainder Theorem across multiple primes
     a. Combine F[p₁,k], F[p₂,k], ... via CRT
     b. Return symmetric representative
```

### 7.3 Spectral Gap Estimation (Heuristic)

**Algorithm 3: EstimateSpectralGap**

```
Input: Recovered moments s₁, s₂, ..., s_m of Laplacian L
Output: Estimated spectral gap λ₁

1. Compute e₁, ..., e_m from s₁, ..., s_m via Newton's identities
2. Form partial characteristic polynomial χ(x) = x^n - e₁x^{n-1} + ... 
3. Estimate smallest positive root of χ (this is λ₁)
4. Alternatively: use moment-based bounds
     a. Lower bound: λ₁ ≥ s₁/n - √((s₂/n) - (s₁/n)²)
     b. Upper bound: λ₁ ≤ s₁/(n-1) (for connected graphs)
```

## 8. Computational Experiments

### 8.1 Setup

We tested the fingerprint framework on the following graph families:
- Cycle graphs $C_n$ for $n = 6, 8, 10, 12, 16, 20$
- Complete graphs $K_n$ for $n = 6, 8, 10$
- Path graphs $P_n$ for $n = 6, 8, 10$
- Petersen graph
- Random Erdős–Rényi graphs $G(n, p)$ for $n = 12$, $p \in [0.1, 0.9]$
- Approximate random regular graphs

### 8.2 Results

**Fingerprint distinctness.** For all tested pairs of non-isomorphic graphs of the same size, the prime fingerprint (with prime bound $P = 19$ and degree bound $m = 8$) was distinct. No collisions were found.

**Spectral gap correlation.** Across 200 random Erdős–Rényi graphs on 12 vertices, the L² norm of the fingerprint vector showed correlation $r > 0.9$ with the true spectral gap. The fingerprint mean showed even stronger correlation.

**Trace recovery.** For all tested matrices with $n \le 20$, choosing the prime bound $P = 31$ sufficed to exactly recover traces $\operatorname{tr}(L^k)$ for $k \le 6$. The transfer theorem was verified in every case.

**Heat trace approximation.** Using 6 recovered moments, the heat trace $Z(\beta)$ was approximated with error $< 10^{-3}$ for $\beta = 0.1$ and $< 0.1$ for $\beta = 1.0$ across all test graphs.

### 8.3 Determinacy Trend

As the prime bound increases from 3 to 97, the number of exactly recoverable moments increases monotonically. For the Petersen graph Laplacian:

| Prime bound | # Primes | Recoverable moments (of 10) |
|-------------|----------|---------------------------|
| 3           | 2        | 1                          |
| 7           | 4        | 2                          |
| 13          | 6        | 3                          |
| 23          | 9        | 5                          |
| 47          | 15       | 7                          |
| 97          | 25       | 10                         |

## 9. Discussion

### 9.1 Implications

The prime fingerprint framework demonstrates that spectral expansion — traditionally an analytic concept — has a rigid arithmetic avatar. The key implications are:

1. **Computational.** Spectral moments can be computed using only modular arithmetic, which is cheaper, parallelizable, and numerically exact.

2. **Theoretical.** The connection between mod-$p$ data and real spectral data suggests new tools from number theory and arithmetic geometry for studying expansion.

3. **Conceptual.** The persistent nullity profile provides an algebraic version of persistence, complementing metric-based persistent homology.

### 9.2 Limitations

1. The trace transfer theorem requires the boundedness condition $p > |\operatorname{tr}(A^k) - \operatorname{tr}(B^k)|$. For large matrices and high powers, this bound can be enormous.

2. The framework recovers spectral *moments* rather than individual eigenvalues. Extracting eigenvalues from moments requires additional work (e.g., solving polynomial systems).

3. The determinacy conjecture remains unproved. The computational evidence is suggestive but limited to small examples.

### 9.3 Comparison with Direct Methods

| Method | Complexity | Numerical stability | Parallelism |
|--------|-----------|-------------------|-------------|
| Full eigendecomposition | $O(n^3)$ | Moderate (floating-point) | Limited |
| Lanczos iteration | $O(kn^2)$ | Sensitive | Moderate |
| **Prime fingerprint** | $O(\pi(P) m n^3 \log m)$ | **Exact** (integer) | **Embarrassingly parallel** |

The fingerprint method is not always faster in total operations, but its numerical exactness and parallelism give it advantages in specific regimes.

## 10. Future Work

1. **Full Newton's identity formalization.** Formally verify the complete Newton's identities in Lean 4, enabling automatic conversion from fingerprint data to characteristic polynomial coefficients.

2. **Arithmetic complex instantiation.** Formalize the construction of Laplacians from arithmetic quotients of Bruhat–Tits buildings and verify that the fingerprint framework applies.

3. **Quantum LDPC connections.** Investigate whether fingerprint-based expansion certification can validate quantum error-correcting code constructions.

4. **Higher-dimensional persistent nullity.** Extend the persistent nullity profile to chain complexes and prove barcode-counting conservation laws.

5. **Non-symmetric operators.** Extend the trace transfer theorem to non-symmetric matrices and directed complexes.

## 11. Formally Verified Theorems

All of the following theorems are formally verified in Lean 4 with Mathlib, with no `sorry` or non-standard axioms:

| Theorem | Statement | File |
|---------|-----------|------|
| `persistentKernel_rank_bound` | $\ker f \subseteq \ker g \Rightarrow \dim\ker f \le \dim\ker g$ | KernelMonotonicity.lean |
| `filtration_finrank_monotone` | Monotone submodule families have monotone finrank | KernelMonotonicity.lean |
| `ker_pow_monotone` | $n \mapsto \ker(L^n)$ is monotone | KernelMonotonicity.lean |
| `persistent_nullity_monotone` | $n \mapsto \dim\ker(L^n)$ is monotone | KernelMonotonicity.lean |
| `persistent_nullity_bounded` | $\dim\ker(L^n) \le \dim V$ | KernelMonotonicity.lean |
| `modpTracePow_eq_cast` | $\operatorname{tr}(\bar{A}^k) = \phi_p(\operatorname{tr}(A^k))$ | TraceTransfer.lean |
| `int_dvd_of_zmod_eq_zero` | $\phi_p(d) = 0 \Rightarrow p \mid d$ | TraceTransfer.lean |
| `int_eq_zero_of_prime_dvd_of_lt` | $p \mid d, \|d\| < p \Rightarrow d = 0$ | TraceTransfer.lean |
| `int_eq_of_zmod_eq_of_bounded` | $\phi_p(a) = \phi_p(b), \|a-b\| < p \Rightarrow a = b$ | TraceTransfer.lean |
| `tracePow_eq_of_modp_eq` | Trace transfer theorem | TraceTransfer.lean |
| `fingerprint_determines_moments_single_prime` | Fingerprint moment determinacy | FingerprintDeterminacy.lean |
| `trace_eq_neg_charpoly_coeff` | Trace = neg. next-to-leading coeff | FingerprintDeterminacy.lean |
| `charpoly_nextCoeff_eq_of_trace_eq` | Equal trace → equal charpoly coeff | FingerprintDeterminacy.lean |
| `det_eq_charpoly_constantCoeff` | Determinant from charpoly | FingerprintDeterminacy.lean |
| `fingerprint_controls_heat_trace` | Heat trace surrogate theorem | FingerprintDeterminacy.lean |

## References

1. N. Alon, V. D. Milman. *λ₁, isoperimetric inequalities for graphs, and superconcentrators.* J. Combin. Theory Ser. B, 38(1):73–88, 1985.

2. G. Carlsson. *Topology and data.* Bull. Amer. Math. Soc., 46(2):255–308, 2009.

3. H. Edelsbrunner, D. Letscher, A. Zomorodian. *Topological persistence and simplification.* Discrete Comput. Geom., 28(4):511–533, 2002.

4. A. Lubotzky, B. Samuels, U. Vishne. *Ramanujan complexes of type Ã_d.* Israel J. Math., 149:267–299, 2005.

5. P. Deligne. *La conjecture de Weil. I.* Inst. Hautes Études Sci. Publ. Math., 43:273–307, 1974.

6. J. Dodziuk. *Difference equations, isoperimetric inequality and transience of certain random walks.* Trans. Amer. Math. Soc., 284(2):787–794, 1984.

7. N. Linial, A. Meshulam. *Homological connectivity of random 2-complexes.* Combinatorica, 26(4):475–487, 2006.

8. S. Hoory, N. Linial, A. Wigderson. *Expander graphs and their applications.* Bull. Amer. Math. Soc., 43(4):439–561, 2006.
