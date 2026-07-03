# Fan-Structure in Selmer Rank Distributions: Parity Rigidity and Gaussian-Binomial Layers

## Abstract

The statistical behavior of Selmer ranks of families of twisted elliptic curves — in $p$-cyclic towers and in families of quadratic twists — is governed by two independent structural mechanisms. First, along any tower in which the $p$-Selmer rank changes by exactly $\pm 1$ at each stage, the *parity* of the rank is rigidly determined by the starting rank and the number of steps; it cannot fluctuate. This parity rigidity is the combinatorial source of the observed disparity between even and odd Selmer ranks. Second, the raw counts of rank-$k$ subgroups of a finite $\mathbb{F}_q$-vector space — the Gaussian binomial coefficients $\binom{n}{k}_q$ — arrange themselves into a self-dual, unimodal "fan" of layers that degenerates to Pascal's triangle in the classical limit $q = 1$. We give precise statements and complete proof sketches of four results: a parity invariant for $\pm 1$ rank walks and its even-loop corollary; the finite support and dual recurrence of the Gaussian binomial coefficients; the self-duality $\binom{n}{k}_q = \binom{n}{n-k}_q$; and the classical limit $\binom{n}{k}_1 = \binom{n}{k}$, together with the $q$-integer formula for the rank-one layer. We situate these results within the heuristics of Klagsbrun–Mazur–Rubin and the Swinnerton-Dyer twist families, provide algorithms and numerical demonstrations, and outline conjectures on unimodality, two-point limiting laws, monotone $q$-interpolation, and disparity constants.

**Keywords:** Selmer group, elliptic curve, quadratic twist, parity rigidity, Gaussian binomial coefficient, $q$-Pascal recurrence, self-duality, subspace counting.

## 1. Introduction

Let $E$ be an elliptic curve over a number field, and for a prime $p$ let $\mathrm{Sel}_p(E)$ denote its $p$-Selmer group, a finite-dimensional vector space over $\mathbb{F}_p$. Its dimension, the *$p$-Selmer rank*, is an upper bound for the Mordell–Weil rank and is the computable proxy through which one studies the arithmetic of $E$ statistically. Two settings produce large families of curves whose Selmer ranks one wishes to understand distributionally:

1. **$p$-cyclic towers.** As one ascends a $\mathbb{Z}/p$-tower of field extensions, the Selmer rank evolves stage by stage.
2. **Quadratic-twist families.** Adding a ramified prime to a quadratic twist perturbs the Selmer group, as in the Swinnerton-Dyer twist heuristics.

In both settings, the theory of Klagsbrun, Mazur, and Rubin predicts a precise limiting distribution of Selmer ranks — one exhibiting a marked *disparity* between even and odd ranks. This paper isolates two mechanisms that, together, account for the shape of these distributions. The first is a rigidity phenomenon governing how a single rank moves; the second is a combinatorial model for how the population of ranks is distributed across a finite vector space.

Throughout, we work with elementary, self-contained objects: integer sequences with $\pm 1$ increments, and the Gaussian binomial coefficients defined by a $q$-deformed Pascal recurrence. All results are stated with full hypotheses and proof sketches.

## 2. Parity Rigidity of Rank Walks

### 2.1 Definition

**Definition 2.1 (Rank walk).** A *rank walk* is a sequence $w : \mathbb{N} \to \mathbb{Z}$ such that for every index $i$,
$$w(i+1) = w(i) + 1 \quad\text{or}\quad w(i+1) = w(i) - 1.$$
Equivalently, consecutive terms differ by exactly $\pm 1$.

A rank walk models a sequence of $p$-Selmer ranks along a tower or twist family, encoding the empirical fact — central to the disparity heuristics — that each elementary step changes the rank by a single unit. The definition is non-vacuous: for instance $w(i) = i$ is a rank walk, as is any sign pattern applied stepwise.

### 2.2 The parity invariant

**Theorem 2.2 (Parity rigidity).** Let $w$ be a rank walk. Then for every $n \in \mathbb{N}$,
$$w(n) \equiv w(0) + n \pmod 2.$$

*Proof sketch.* Induct on $n$. For $n = 0$ the statement is $w(0) \equiv w(0) \pmod 2$, which holds. Assume $w(n) \equiv w(0) + n \pmod 2$. By definition either $w(n+1) = w(n) + 1$ or $w(n+1) = w(n) - 1$. In both cases $w(n+1) \equiv w(n) + 1 \pmod 2$, because $-1 \equiv +1 \pmod 2$. Combining with the inductive hypothesis,
$$w(n+1) \equiv w(n) + 1 \equiv (w(0) + n) + 1 = w(0) + (n+1) \pmod 2. \qquad\square$$

The mechanism is that $+1$ and $-1$ are congruent modulo $2$, so both admissible steps advance the parity identically. The direction of each step is irrelevant to the parity; only the *number* of steps matters. This is a genuine parity argument (it uses case analysis on the $\pm 1$ step and the congruence $-1 \equiv 1$), not a numerical coincidence.

### 2.3 The even-loop obstruction

**Corollary 2.3 (Even-loop obstruction).** Let $w$ be a rank walk. If $w(n) = w(0)$ for some $n \in \mathbb{N}$, then $n$ is even.

*Proof sketch.* By Theorem 2.2, $w(n) \equiv w(0) + n \pmod 2$. The hypothesis $w(n) = w(0)$ gives $w(0) \equiv w(0) + n \pmod 2$, hence $n \equiv 0 \pmod 2$, i.e. $2 \mid n$, so $n$ is even. $\square$

**Interpretation.** A rank walk cannot return to its starting value in an odd number of steps: returning home requires equally many upward and downward steps, forcing an even total. In arithmetic terms, one residue class of ranks is structurally excluded once the parity and step count are fixed. This is precisely the rigidity underlying the even/odd *disparity* in Selmer ranks: the parity is deterministic, so all genuine randomness lives in the magnitude of the walk, and one parity class is systematically favored.

## 3. The Selmer Fan: Gaussian-Binomial Layers

We now model the *population* of ranks. Since the $p$-Selmer group is a finite $\mathbb{F}_p$-vector space, the relevant combinatorial datum is the number of rank-$k$ subspaces of $\mathbb{F}_q^n$, the Gaussian binomial coefficient.

### 3.1 Definition and elementary identities

**Definition 3.1 (Gaussian binomial coefficient).** For a natural number $q$ define $\binom{n}{k}_q$, also written $\mathrm{gaussBinom}(q,n,k)$, by the *forward $q$-Pascal recurrence*:
$$\binom{0}{0}_q = 1,\qquad \binom{0}{k+1}_q = 0,\qquad \binom{n+1}{0}_q = 1,$$
$$\binom{n+1}{k+1}_q = \binom{n}{k}_q + q^{\,k+1}\binom{n}{k+1}_q.$$

When $q$ is a prime power, $\binom{n}{k}_q$ equals the number of $k$-dimensional $\mathbb{F}_q$-subspaces of $\mathbb{F}_q^n$. For fixed $n$, the layer sequence $\bigl(\binom{n}{k}_q\bigr)_{k=0}^{n}$ is the **Selmer fan**.

**Lemma 3.2 (Boundary values).** For all $q, n$ we have $\binom{n}{0}_q = 1$, and for all $q, k$ we have $\binom{0}{k+1}_q = 0$. Moreover the recurrence
$$\binom{n+1}{k+1}_q = \binom{n}{k}_q + q^{\,k+1}\binom{n}{k+1}_q$$
holds definitionally.

*Proof sketch.* Immediate from Definition 3.1 by case analysis on $n$. $\square$

### 3.2 Finite support

**Theorem 3.3 (Finite support).** If $n < k$ then $\binom{n}{k}_q = 0$.

*Proof sketch.* Induct on $n$. For $n = 0$ and $k \ge 1$, the value is $0$ by definition. For the step, suppose the claim holds for $n$ and let $k > n+1$, so $k = k' + 2$ with $k' + 1 > n$. Then by the recurrence,
$$\binom{n+1}{k'+2}_q = \binom{n}{k'+1}_q + q^{\,k'+2}\binom{n}{k'+2}_q,$$
and both terms vanish by the inductive hypothesis, since $n < k'+1$ and $n < k'+2$. $\square$

Finite support reflects the fact that $\mathbb{F}_q^n$ has no subspace of dimension exceeding $n$. It is a prerequisite for the dual recurrence below, because natural-number subtraction truncates at zero and the dual recurrence must remain valid at the edges of the fan.

### 3.3 The dual recurrence

**Theorem 3.4 (Dual $q$-Pascal recurrence).** For all $q, n, k$,
$$\binom{n+1}{k+1}_q = q^{\,n-k}\binom{n}{k}_q + \binom{n}{k+1}_q.$$

*Proof sketch.* If $n < k$ then both sides reduce to $\binom{n}{k+1}_q$ using Theorem 3.3 (the first term on the right vanishes because $\binom{n}{k}_q = 0$, and on the left $\binom{n+1}{k+1}_q = \binom{n}{k+1}_q$ since the forward recurrence's first summand $\binom{n}{k}_q$ also vanishes). Otherwise $k \le n$, and we induct on $n$. The base case $n = 0$ forces $k = 0$ and both sides equal $\binom{0}{0}_q + \binom{0}{1}_q$ appropriately. For the inductive step, apply the forward recurrence to $\binom{n+1}{k+1}_q$, invoke the inductive hypothesis on $\binom{n}{k}_q$ and $\binom{n}{k+1}_q$, and reconcile the powers of $q$ via $q^{\,n-k}\cdot q = q^{\,n+1-k}$ and $q^{\,(n-1)-(k-1)} = q^{\,n-k}$, with careful bookkeeping of the truncated subtraction using $\mathrm{Nat.succ\_sub}$-style identities. $\square$

The dual recurrence advances the same coefficient with the weight attached to the *first* rather than the second summand. Having both recurrences available is what makes the self-duality proof possible.

### 3.4 Self-duality of the fan

**Theorem 3.5 (Self-duality).** For every $q$ and all $k \le n$,
$$\binom{n}{k}_q = \binom{n}{n-k}_q.$$

*Proof sketch.* Strong induction on $n$. The cases $n = 0$, $k = 0$, and $k = n$ are handled directly using the boundary values and finite support (Theorem 3.3). For the generic case $0 < k < n$, write the left side with the forward recurrence and the right side with the dual recurrence (Theorem 3.4):
$$\binom{n}{k}_q = \binom{n-1}{k-1}_q + q^{\,k}\binom{n-1}{k}_q,$$
$$\binom{n}{n-k}_q = q^{\,(n-1)-(n-k)}\binom{n-1}{n-k-1}_q + \binom{n-1}{n-k}_q.$$
Now apply the inductive hypothesis on $\mathbb{F}_q^{n-1}$ to identify $\binom{n-1}{k-1}_q = \binom{n-1}{(n-1)-(k-1)}_q = \binom{n-1}{n-k}_q$ and $\binom{n-1}{k}_q = \binom{n-1}{n-1-k}_q = \binom{n-1}{n-k-1}_q$. The exponent matches because $(n-1)-(n-k) = k-1$, so $q^{\,(n-1)-(n-k)} = q^{\,k-1}$, and after the substitution both expressions coincide. The rewriting $n - k = (n-k-1)+1$ is used to expose the recurrence on the dual side. $\square$

Self-duality expresses the bijection between a $k$-dimensional subspace and its $(n-k)$-dimensional orthogonal complement. It pins the axis of symmetry of the fan at $k = n/2$.

### 3.5 Classical limit and the rank-one layer

**Theorem 3.6 (Classical limit).** At $q = 1$,
$$\binom{n}{k}_1 = \binom{n}{k},$$
the ordinary binomial coefficient.

*Proof sketch.* At $q = 1$ the forward recurrence becomes
$$\binom{n+1}{k+1}_1 = \binom{n}{k}_1 + \binom{n}{k+1}_1,$$
which is exactly Pascal's rule, with the same boundary values $\binom{n}{0}_1 = 1$ and $\binom{0}{k+1}_1 = 0$. By induction on $n$ (with the usual $\mathrm{Nat.succ\_sub}$ bookkeeping at the boundary), $\binom{n}{k}_1$ satisfies the defining recurrence of $\binom{n}{k}$ and hence equals it. $\square$

**Corollary 3.7 (Rank-one layer is the $q$-integer).** For all $n \ge 1$,
$$\binom{n}{1}_q = 1 + q + q^2 + \dots + q^{\,n-1} = \frac{q^n - 1}{q - 1}\quad (q \ne 1),$$
the $q$-integer $[n]_q$.

*Proof sketch.* Induct on $n$ using the forward recurrence with $k = 0$:
$$\binom{n+1}{1}_q = \binom{n}{0}_q + q^{1}\binom{n}{1}_q = 1 + q\binom{n}{1}_q,$$
starting from $\binom{1}{1}_q = 1$. The recurrence $a_{n+1} = 1 + q\,a_n$ with $a_1 = 1$ solves to $a_n = 1 + q + \dots + q^{\,n-1}$. $\square$

The rank-one layer counts the lines through the origin in $\mathbb{F}_q^n$; at $q = 1$ it degenerates to $n$, consistent with Theorem 3.6 since $\binom{n}{1} = n$.

## 4. Numerical Illustrations

The fan and its properties are readily verified numerically. For $q = 2$, $n = 4$:
$$\binom{4}{\cdot}_2 = 1,\ 15,\ 35,\ 15,\ 1,$$
manifestly self-dual (Theorem 3.5). For $q = 3$, $n = 3$:
$$\binom{3}{\cdot}_3 = 1,\ 13,\ 13,\ 1.$$
At $q = 1$, $\binom{4}{\cdot}_1 = 1, 4, 6, 4, 1 = \binom{4}{\cdot}$ (Theorem 3.6). The rank-one layer $\binom{4}{1}_3 = 1 + 3 + 9 + 27 = 40$ (Corollary 3.7). The four rank walks of length $2$ starting at $0$ — namely $0\to1\to0$, $0\to1\to2$, $0\to-1\to0$, $0\to-1\to-2$ — all terminate at a value $\equiv 0 \pmod 2$, illustrating Theorem 2.2 with $n = 2$.

## 5. Algorithms

**Gaussian-binomial table.** The forward $q$-Pascal recurrence yields a straightforward dynamic program computing the entire fan $\bigl(\binom{n}{k}_q\bigr)_{k=0}^{n}$ in $O(n^2)$ arithmetic operations (with big-integer costs for large $q^k$). The dual recurrence provides an independent cross-check.

**Rank-walk parity oracle.** Given a starting rank $r$ and a step count $n$, the terminal parity is computed in $O(1)$ as $(r + n) \bmod 2$, independent of the step directions — a direct application of Theorem 2.2.

**Self-duality verifier.** For fixed $q, n$, comparing $\binom{n}{k}_q$ with $\binom{n}{n-k}_q$ across all $k$ confirms Theorem 3.5 for concrete parameters and stress-tests the recurrences.

## 6. Applications

- **Disparity heuristics.** Parity rigidity (Theorem 2.2, Corollary 2.3) provides the deterministic skeleton behind the even/odd Selmer-rank disparity: since parity is fixed by the starting rank and step count, statistical fluctuation is confined to magnitude, and one parity class dominates.
- **Rank-distribution models.** The Selmer fan (Section 3) supplies the combinatorial mass function for rank distributions over finite $\mathbb{F}_p$-vector spaces, with self-duality guaranteeing the symmetry observed in twist families.
- **Interpolation of heuristics.** The single parameter $q$ bridges the naive binomial heuristic ($q = 1$, Theorem 3.6) and the exact arithmetic subspace count ($q = p$), making precise the sense in which the two predictions are the same object at different values of $q$.

## 7. Discussion

The two mechanisms are complementary. Parity rigidity constrains the *support* of a rank distribution to a single parity lattice; the Gaussian fan describes the *shape* of the mass on the surviving lattice. Neither result is deep in isolation, but their conjunction turns qualitative heuristics into exact statements: a $\pm 1$ walk cannot change parity, and subspace counts form a symmetric, binomial-limiting fan. The subtlety in the proofs is concentrated in the interaction of the two Pascal recurrences (needed for self-duality) and in the truncated-subtraction bookkeeping that makes the dual recurrence valid across the entire fan, including its boundary.

## 8. Future Directions

**Unimodality with a sharp central plateau.** For every prime power $q$ and every $n$, the layer sequence $\binom{n}{0}_q, \dots, \binom{n}{n}_q$ is conjectured strictly unimodal — increasing up to $\lfloor n/2 \rfloor$ and decreasing after — with the central-layer-to-total-mass ratio tending to $0$ at an explicit polynomial-in-$q$ rate. Self-duality already fixes the axis at $n/2$, reducing unimodality to log-concavity of one half, expressible via the dual recurrence as positivity of $q$-integers.

**Two-point limiting law under parity conditioning.** In any family with balanced $\pm 1$ steps, conditioning on the rigidly determined parity is conjectured to yield a limiting distribution supported on exactly two adjacent ranks with masses $\to 1/2$. Parity rigidity removes an entire residue class, leaving a balanced walk on a single parity lattice whose local limit concentrates on neighbours of the drift.

**Monotone $q$-interpolation of heuristics.** For fixed $n, k$, the normalized weight $\binom{n}{k}_q / \sum_j \binom{n}{j}_q$ is conjectured monotone in $q$ on $[1,\infty)$, interpolating between the binomial heuristic at $q = 1$ and the arithmetic count at $q = p$ with no crossings between distinct $k$. The dual recurrence expresses $\partial/\partial q$ of a layer as a nonnegative combination of lower layers.

**Disparity constant as a fan-boundary defect.** The asymptotic excess of one Selmer parity over the other is conjectured to equal an explicit product determined solely by the boundary layers of the fan.
