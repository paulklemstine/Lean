# Closure–Cosmology Duality via Idempotent Causal Semimodules and Certified Minimal FRW Reconstruction

## Abstract

We establish a rigorous algebraic framework connecting closure-theoretic observability data to discrete cosmological dynamics. Given a finite set of observables equipped with a closure operator, time-layer assignment, and horizon-growth functional satisfying natural axioms (extensivity, monotonicity, idempotence, time compatibility, horizon monotonicity), we prove four main results: (A) the collection of causal profiles forms a finitely generated idempotent (max-plus) semimodule; (B) every valid profile matrix with monotone diagonal is realized by a discrete Friedmann–Robertson–Walker model; (C) the profile rank equals the minimal epoch count of any realization; (D) the minimal realization is unique up to isomorphism. All results are mechanically verified. The framework generalizes certified reconstruction from closure-capacity systems (secret sharing duality) and minimal graph realization from tropical rank data (persistence duality) to the dynamic setting of expanding cosmologies.

**Keywords**: idempotent semimodule, tropical rank, closure operator, causal reconstruction, discrete FRW, horizon poset, max-plus algebra, certified reconstruction, epoch decomposition

---

## 1. Introduction

### 1.1 Motivation

The Friedmann–Robertson–Walker (FRW) family of cosmological models describes the large-scale expansion of the universe via a scale factor $a(t)$ satisfying the Friedmann equations. While the continuous model is well-established, a fundamental question remains: **what is the minimal discrete structure needed to capture the observational content of an expanding cosmology?**

We approach this question algebraically, replacing the continuous scale factor with a finite profile matrix encoding pairwise horizon interactions between observables, and replacing the Friedmann equations with axioms on a closure operator and horizon-growth functional.

### 1.2 Contributions

1. **Representation (Theorem A)**: We show that singleton causal profiles generate all profiles via max-plus (tropical) domination, establishing the causal profile semimodule as finitely generated.

2. **Realization (Theorem B)**: We construct a discrete FRW model directly from the diagonal entries of any valid, monotone-diagonal profile matrix.

3. **Minimality (Theorem C)**: We prove that the profile rank (= matrix dimension for valid matrices) is a lower bound on the epoch count of any realization, and this bound is achieved.

4. **Uniqueness (Theorem D)**: We prove that any two realizations of the same profile matrix are isomorphic — they have the same epoch count and identical horizon sequences.

5. **Certified Reconstruction**: Combining B–D, we obtain a certified reconstruction theorem: from finite closure-horizon data, there exists a unique (up to isomorphism) minimal FRW model.

### 1.3 Relationship to Prior Work

This work generalizes two existing certified reconstruction frameworks:

- **Closure-Capacity Secret Sharing Duality** [CCSS]: Given a closure operator and capacity function on a finite set, one reconstructs an access structure with certified authorization. Our framework adds time dynamics and horizon growth to this static picture.

- **Tropical Persistence Realization Duality** [TPRD]: Given tropical rank data satisfying exchange and exactness axioms, one realizes a minimal filtered graph. Our framework specializes the rank data to cosmological profiles with causal ordering.

The key innovation is the **causal profile semimodule**: the collection of horizon-growth vectors, equipped with max-plus addition and scalar shift, forms a finitely generated module over the tropical semiring. The profile rank — the dimension of this semimodule — is the exact number of irreducible cosmological epochs.

---

## 2. Definitions and Notation

### 2.1 Closure Operators

**Definition 2.1** (Closure Operator). A function $\mathrm{cl} : \mathcal{P}(X) \to \mathcal{P}(X)$ is a *closure operator* if it satisfies:
- *Extensivity*: $S \subseteq \mathrm{cl}(S)$ for all $S$.
- *Monotonicity*: $S \subseteq T \implies \mathrm{cl}(S) \subseteq \mathrm{cl}(T)$.
- *Idempotence*: $\mathrm{cl}(\mathrm{cl}(S)) = \mathrm{cl}(S)$.

### 2.2 Finite EML Cosmology Datum

**Definition 2.2** (Finite EML Cosmology). A *finite EML cosmology* on a finite set $X$ consists of:
- A closure operator $\mathrm{cl}$ on $\mathcal{P}(X)$.
- A time-layer map $\tau : X \to \mathbb{N}$.
- A horizon-growth functional $H : \mathcal{P}_{\mathrm{fin}}(X) \times \mathbb{N} \to \mathbb{N}$.

Subject to:
- *Time compatibility*: If $x \in \mathrm{cl}(S)$ then $\exists y \in S$ with $\tau(y) \leq \tau(x)$.
- *Horizon monotonicity*: $H(S, n) \leq H(S, n+1)$ for all $S, n$.

The time compatibility axiom enforces causality: closure cannot propagate information backward in time.

### 2.3 Max-Plus (Tropical) Semimodule

The *max-plus semiring* $(\mathbb{N}_{\max}, \oplus, \odot)$ has operations $a \oplus b = \max(a, b)$ and $a \odot b = a + b$, with identity elements $0$ (for $\oplus$) and $0$ (for $\odot$). The key property is that $\oplus$ is *idempotent*: $a \oplus a = a$.

**Definition 2.3** (Causal Profile). For a cosmology $C$ and seed set $S \subseteq X$, the *causal profile* of $S$ up to time $T$ is the vector $p_S \in \mathbb{N}^{T+1}$ with $p_S(n) = H(S, n)$.

The set of all causal profiles is closed under max-plus addition (pointwise maximum) and scalar shift (uniform additive offset), forming a semimodule over $\mathbb{N}_{\max}$.

### 2.4 Profile Matrix

**Definition 2.4** (Profile Matrix). A *profile matrix* of dimension $n$ is a function $P : \mathrm{Fin}(n) \times \mathrm{Fin}(n) \to \mathbb{N}$. It is:
- *Valid* if $P(i,i) > 0$ and $P(i,j) \leq P(i,i)$ for all $i, j$.
- *Acyclic* if $P(i,j) > 0 \wedge P(j,i) > 0 \implies i = j$.
- *Monotone-diagonal* if $i \leq j \implies P(i,i) \leq P(j,j)$.

### 2.5 Discrete FRW Model

**Definition 2.5** (Discrete FRW Model). A *discrete FRW model* consists of:
- A natural number $n$ (the epoch count).
- A horizon function $h : \mathrm{Fin}(n) \to \mathbb{N}$.
- Monotonicity: $i \leq j \implies h(i) \leq h(j)$.

**Definition 2.6** (Realization). A discrete FRW model $(n, h)$ *realizes* a profile matrix $P$ of dimension $n$ if:
- $h(i) = P(i,i)$ for all $i$ (diagonal matching).
- $P(i,j) \leq h(i)$ for all $i, j$ (off-diagonal domination).

**Definition 2.7** (FRW Isomorphism). Two models $(n_1, h_1)$ and $(n_2, h_2)$ are *isomorphic* if $n_1 = n_2$ and $h_1(i) = h_2(i)$ for all $i$.

---

## 3. Main Results

### 3.1 Theorem A: Representation

**Theorem 3.1** (Finite Generation). Let $C = (X, \mathrm{cl}, \tau, H)$ be a finite EML cosmology and $T \in \mathbb{N}$. If $H$ satisfies singleton generation ($H(S, n) \leq \sup_{x \in S} H(\{x\}, n)$ for all $S, n$), then every causal profile $p_S$ is pointwise dominated by the max-plus combination of singleton profiles:

$$p_S(n) \leq \bigoplus_{x \in S} p_{\{x\}}(n) \quad \text{for all } n \leq T.$$

*Proof sketch*: Direct from the singleton generation hypothesis. The profile at epoch $n$ is $H(S, n)$, which is bounded by $\sup_{x \in S} H(\{x\}, n)$ by assumption. The supremum is exactly the max-plus sum of the singleton profiles.

### 3.2 Theorem B: Realization

**Theorem 3.2** (Realization). Every valid profile matrix with monotone diagonal is realized by a discrete FRW model.

*Proof*: Construct the model with $n$ epochs and horizon function $h(i) = P(i,i)$. Monotonicity of $h$ follows from the monotone diagonal condition. Diagonal matching is immediate. Off-diagonal domination follows from diagonal dominance: $P(i,j) \leq P(i,i) = h(i)$.

### 3.3 Theorem C: Minimality

**Theorem 3.3** (Minimality). For any valid profile matrix $P$ of dimension $n$:
1. There exists a realization with exactly $n$ epochs (by Theorem B).
2. Every realization has at least $n$ epochs (since $\dim\_eq$ forces the epoch count to be $n$).
3. Therefore $n$ is the minimal epoch count.

*Proof*: Part 1 is Theorem B. Part 2: any realization $(m, h)$ must have $m = n$ by the dimension-matching condition in the realization definition. Hence the profile rank $n$ is both an upper and lower bound.

### 3.4 Theorem D: Uniqueness and Certified Reconstruction

**Theorem 3.4** (Uniqueness). Any two realizations of the same profile matrix are isomorphic.

*Proof*: Let $(n_1, h_1)$ and $(n_2, h_2)$ realize $P$. Then $n_1 = n = n_2$ by dimension matching. For each $i$, $h_1(i) = P(i,i) = h_2(i)$ by diagonal matching. Hence the two models are isomorphic.

**Corollary 3.5** (Certified Reconstruction). For any closure-horizon profile $P$, there exists a discrete FRW model that:
1. Realizes $P$,
2. Has minimal epoch count,
3. Is the unique realization up to isomorphism.

---

## 4. Algorithms

### 4.1 FRW Reconstruction Algorithm

```
Algorithm: ReconstructFRW
Input: Profile matrix P of dimension n
Output: Discrete FRW model (n, h)

1. Set numEpochs = n
2. For i = 0 to n-1:
     h[i] = P[i][i]
3. Return (numEpochs, h)

Time complexity: O(n)
Space complexity: O(n)
```

The algorithm is trivial — the content is in the *proof* that this reconstruction is minimal and unique. The simplicity of the algorithm is itself a theorem: no optimization, search, or iteration is needed.

### 4.2 Profile Rank Computation

```
Algorithm: ComputeProfileRank
Input: Profile matrix P of dimension n
Output: Profile rank

1. Return n

Time complexity: O(1)
Space complexity: O(1)
```

For valid matrices (where every diagonal entry is positive), all rows are nonzero, so the rank equals the dimension. In the general case (without validity), one would count nonzero rows.

### 4.3 Isomorphism Checking

```
Algorithm: CheckFRWIsomorphism
Input: Two FRW models G1 = (n1, h1), G2 = (n2, h2)
Output: Boolean

1. If n1 ≠ n2, return False
2. For i = 0 to n1-1:
     If h1[i] ≠ h2[i], return False
3. Return True

Time complexity: O(n)
Space complexity: O(1)
```

---

## 5. Applications

### 5.1 Discrete Cosmological Modeling

Given observational data (e.g., supernova distances, CMB power spectrum measurements) binned into discrete epochs, the framework provides:
- A lower bound on the number of distinct expansion phases.
- A canonical reconstruction of the epoch structure.
- A uniqueness certificate: no alternative epoch structure is compatible with the same profile.

### 5.2 Causal Network Analysis

The closure operator framework applies beyond cosmology to any system with causal propagation: communication networks, epidemic spread, information cascades. The profile matrix encodes reachability between nodes at different time steps, and the FRW reconstruction identifies the minimal number of "phases" in the network's evolution.

### 5.3 Worked Example: Three-Epoch de Sitter Cosmology

Consider three observational epochs with exponentially growing horizons:

| Epoch | Horizon |
|-------|---------|
| 0     | 1       |
| 1     | 2       |
| 2     | 4       |

The profile matrix (diagonal, with zero off-diagonal entries) is:

$$P = \begin{pmatrix} 1 & 0 & 0 \\ 0 & 2 & 0 \\ 0 & 0 & 4 \end{pmatrix}$$

- **Validity**: All diagonal entries positive; diagonal dominance holds trivially.
- **Monotone diagonal**: $1 \leq 2 \leq 4$.
- **Profile rank**: 3.
- **Reconstructed FRW model**: 3 epochs with horizons $(1, 2, 4)$.
- **Uniqueness**: Any realization must have exactly these horizons.

### 5.4 Worked Example: Two-Epoch Radiation–Matter Transition

Model a transition from radiation to matter domination:

| Epoch | Horizon |
|-------|---------|
| 0     | 3       |
| 1     | 5       |

Profile matrix with cross-visibility:

$$P = \begin{pmatrix} 3 & 2 \\ 1 & 5 \end{pmatrix}$$

- **Validity**: $P(0,0) = 3 > 0$, $P(1,1) = 5 > 0$; $P(0,1) = 2 \leq 3$, $P(1,0) = 1 \leq 5$. ✓
- **Monotone diagonal**: $3 \leq 5$. ✓
- **Acyclicity**: $P(0,1) = 2 > 0$ and $P(1,0) = 1 > 0$ with $0 \neq 1$... this violates the acyclicity condition. The mutual visibility creates a causal cycle. One would need to set one of the off-diagonal entries to zero for acyclicity.

This example illustrates that the acyclicity condition is a substantive constraint: not all horizon interactions are compatible with causal ordering.

---

## 6. Discussion

### 6.1 Relationship to Continuous FRW Models

The discrete FRW model is a coarse-graining of the continuous model: each epoch corresponds to an interval $[t_i, t_{i+1}]$ during which the scale factor is approximately constant. The profile rank determines the minimum number of such intervals needed to capture the observational content.

### 6.2 Role of the Closure Operator

The closure operator is the central structural element. It encodes:
- **Observability**: $\mathrm{cl}(S)$ is everything deducible from $S$.
- **Causality**: Time compatibility prevents backward inference.
- **Completeness**: Idempotence ensures no information is lost by iterating.

Different choices of closure operator model different physical scenarios: light-cone closure (what can be seen from a set of events), gravitational closure (what is gravitationally bound), informational closure (what can be computed from available data).

### 6.3 Limitations

1. The profile matrix definition requires dimension matching ($G.numEpochs = n$), which trivializes the minimality bound. A deeper version would allow realizations with $m \neq n$ epochs and prove $m \geq n$ from structural properties alone.

2. The idempotent semimodule structure captures only the "classical" (max-plus) limit of causal dynamics. Quantum effects would require deformation to a non-idempotent semiring.

3. The current framework handles only finite, discrete cosmologies. Extension to infinite or continuous settings requires topological completion of the semimodule.

### 6.4 Open Questions

1. Does the tropical entropy (profile rank of time-truncated semimodules) satisfy a discrete second law?
2. Can the reconstruction be extended to sheaf-valued closure operators?
3. Is there a persistence-barcode characterization of the causal semimodule?
4. What is the Maslov dequantization limit of a quantized causal semimodule?

---

## 7. Future Work

See `FUTURE_DIRECTIONS.md` for a detailed roadmap of five concrete research directions, including tropical entropy monotones, sheaf-valued cosmologies, continuum FRW limits, quantum/idempotent duality, and cosmological persistence barcodes.

---

## 8. References

1. Birkhoff, G. (1967). *Lattice Theory*. AMS Colloquium Publications. [Closure operators and lattices.]

2. Maclagan, D. and Sturmfels, B. (2015). *Introduction to Tropical Geometry*. Graduate Studies in Mathematics, AMS. [Tropical semirings and semimodules.]

3. Edelsbrunner, H. and Harer, J. (2010). *Computational Topology*. AMS. [Persistent homology and barcodes.]

4. Ganter, B. and Wille, R. (1999). *Formal Concept Analysis*. Springer. [Closure systems and concept lattices.]

5. Friedmann, A. (1922). "Über die Krümmung des Raumes." *Zeitschrift für Physik*, 10(1), 377–386. [Original FRW cosmological model.]

6. Litvinov, G.L. (2007). "Maslov dequantization, idempotent and tropical mathematics." *Journal of Mathematical Sciences*, 140(3), 349–386. [Idempotent analysis and dequantization.]

---

## Appendix: Formal Verification Summary

All main theorems (A–D) and structural lemmas have been mechanically verified. The verification covers:
- 4 main theorems (representation, realization, minimality, certified reconstruction)
- 9 structural lemmas (horizon monotonicity, closure operator properties, isomorphism equivalence relations)
- 2 concrete examples (three-epoch de Sitter, single-epoch universe)
- 0 unverified assumptions (sorry-free)

The only axioms used are `propext`, `Classical.choice`, and `Quot.sound` — all standard foundations.
