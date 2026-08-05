# Rotated Laplacians, Periodicity Ratios, and a Quantization Theorem for Nearly-Periodic Digraphs

**Author:** Aristotle
**Date:** 2026-08-05

---

## Abstract

We develop the structure theory of the *periodicity ratio* of a finite weighted digraph, a quantity defined through the spectrum of the family of *rotated Laplacian matrices* $D - A_\omega$, where $A_\omega$ is the arc-weight matrix scaled by a complex rotation $\omega$ of modulus one. The periodicity ratio at an integer $p \ge 1$ is the infimum, over nonzero vectors whose coordinates are $0$ or powers of the primitive $p$-th root of unity $\omega_p = e^{2\pi i/p}$, of the Rayleigh quotient
$$\frac{\sum_{u,v} w_{uv}\|x_v - \omega_p x_u\|^2}{\sum_v d_v \|x_v\|^2}.$$
For $p = 2$ this specializes to the bipartiteness ratio.

We prove four groups of results. **(i) Structure of the zero set.** For a strongly connected nonnegatively weighted digraph, a unimodular $p$-phase vector of zero rotated energy exists if and only if $p$ divides the length of every closed walk; consequently $\{p : \beta_p = 0\}$ is closed under divisors and under least common multiples, hence equals the set of divisors of the period. We also exhibit a strongly connected digraph — the directed $4$-cycle — with $\beta_2 = 0$ but no closed walk of length $2$, disproving the natural strengthening that a vanishing $p$-ratio identifies the period itself. **(ii) Normalization and symmetry.** The rotated Rayleigh quotient is bounded above by $2$ for every unimodular rotation, and the entire periodicity ratio is invariant under reversal of all arcs. **(iii) Markov chains.** For the chain weighting $w_{uv} = \pi_u P_{uv}$ induced by a stationary distribution $\pi$, right eigenvectors of $P$ with unimodular eigenvalue are exactly the zero-energy vectors (the converse requiring $\pi > 0$); the proof runs through the variance identity $\mathbb{E}\|Z-\mathbb{E}Z\|^2 = \mathbb{E}\|Z\|^2 - \|\mathbb{E}Z\|^2$. **(iv) Quantization.** If every nonzero arc weight is at least $1$ and $p \ge 2$, the rotated energy of a unimodular $p$-phase vector is either exactly $0$ or at least the root gap $g_p = 4\sin^2(\pi/p)$; hence energy strictly below $g_p$ *forces* exact $p$-periodicity. We show the weight hypothesis is necessary: rescaling the directed $4$-cycle yields nonnegatively weighted digraphs with arbitrarily small positive $3$-energy.

**Keywords:** rotated Laplacian, periodicity ratio, bipartiteness ratio, digraph period, Markov chain, roots of unity, spectral graph theory, quantization.

---

## 1. Introduction

### 1.1 Motivation

Spectral graph theory for *undirected* graphs is mature: the eigenvalues of the normalized Laplacian control connectivity, expansion, mixing, and bipartiteness, and Cheeger-type inequalities convert spectral quantities into combinatorial ones with provable loss. For *directed* graphs the situation has long been less satisfactory, since the natural adjacency operator is not self-adjoint and its spectrum is complex.

One productive response is to study a *family* of Hermitian operators attached to a digraph rather than a single non-Hermitian one. Given nonnegative arc weights $w_{uv}$ and a complex number $\omega$ with $|\omega| = 1$, the **rotated Laplacian** is
$$L_\omega = D - A_\omega, \qquad (A_\omega)_{uv} = \omega\, w_{uv} \text{ (suitably Hermitized)},$$
whose quadratic form we take as the primary object. Rotated Laplacians in this sense were introduced and studied by Lange, Liu, Peyerimhoff and Post; the case $\omega = 1$ is the usual Laplacian and $\omega = -1$ is the signless Laplacian. Recent work on spectral approximation of digraphs has renewed interest in extracting directed structure — in particular *periodic* structure — from such families.

The combinatorial invariant at stake is the **period** of a strongly connected digraph: the greatest common divisor of the lengths of its closed walks. Period $1$ means aperiodic (the generic case, and the case in which an associated Markov chain converges to its stationary distribution); period $p > 1$ means the vertex set partitions into $p$ classes cyclically permuted by every arc. Periodicity is a fragile, all-or-nothing property of the exact arc set, so for applications one wants a *robust* version: a real-valued score measuring how close a digraph is to having period $p$, computable in polynomial time, and tied to a spectrum.

### 1.2 The periodicity ratio

Trevisan's bipartiteness ratio provides the template at $p = 2$. There one minimizes $\sum_{uv} w_{uv}|x_u + x_v|^2$ over $x \in \{-1,0,1\}^V$, normalized by volume; the minimum is $0$ exactly for bipartite graphs, and small values certify near-bipartiteness in a form usable by a Cheeger-type rounding argument.

Replacing $\{-1,+1\}$, the square roots of unity, by the full group $\mu_p$ of $p$-th roots of unity, and replacing "flip sign across an edge" by "rotate by $\omega_p$ along an arc", yields the periodicity ratio $\beta_p$ studied here. It reduces to the bipartiteness ratio at $p=2$ and, for a strongly connected digraph representing a Markov chain, is a quantitative measure of the chain's proximity to periodicity $p$.

### 1.3 Contributions and organization

Section 2 fixes definitions. Section 3 records the basic analytic facts: nonnegativity, the exact characterization of zero energy as an arc-local condition, the universal upper bound $\beta_p \le 2$, and reversal invariance. Section 4 contains the main combinatorial characterization of vanishing periodicity ratio in terms of divisibility of closed-walk lengths, the resulting divisor-lattice structure of $\{p : \beta_p = 0\}$, and an explicit counterexample delimiting the theorem. Section 5 treats Markov chains and unimodular eigenvalues. Section 6 proves the quantization theorem and its rigidity corollary, and establishes the necessity of the weight hypothesis. Section 7 describes algorithms; Section 8 discusses applications, limitations and open problems.

---

## 2. Definitions

Throughout, $V$ is a finite nonempty set of vertices and $w : V \times V \to \mathbb{R}$ is a weight function; unless stated otherwise $w_{uv} \ge 0$ for all $u,v$. We write $\mathbb{T} = \{z \in \mathbb{C} : |z| = 1\}$.

**Definition 2.1 (Rotated energy).** For $\omega \in \mathbb{C}$ and $x : V \to \mathbb{C}$, the *rotated energy* is
$$\mathcal{E}_w(\omega, x) \;=\; \sum_{u \in V} \sum_{v \in V} w_{uv} \, \bigl\| x_v - \omega\, x_u \bigr\|^2 .$$

This is the Hermitian quadratic form $x^* (D - A_\omega) x$ of the rotated Laplacian; for $\omega = 1$ it is the standard Dirichlet energy and for $\omega = -1$ the signless energy.

**Definition 2.2 (Degree, volume, Rayleigh quotient).** The *total degree* of $v$ is
$$d_v = \sum_{u \in V} (w_{vu} + w_{uv}),$$
the sum of out- and in-weights. The *volume* of $x$ is $\mathrm{vol}_w(x) = \sum_v d_v \|x_v\|^2$, and the *rotated Rayleigh quotient* is
$$\mathcal{R}_w(\omega, x) = \frac{\mathcal{E}_w(\omega, x)}{\mathrm{vol}_w(x)} .$$

**Definition 2.3 (Phase vector).** Fix $\omega \in \mathbb{T}$. A vector $x : V \to \mathbb{C}$ is a *phase vector* (for $\omega$) if for every $v$ either $x_v = 0$ or $x_v = \omega^k$ for some $k \in \mathbb{N}$. It is a *unimodular* phase vector if additionally $\|x_v\| = 1$ for every $v$, i.e. no coordinate is $0$.

For $\omega = -1$ the phase vectors are exactly the vectors in $\{-1,0,1\}^V$, recovering Trevisan's test class.

**Definition 2.4 (Periodicity ratio).** The set of achievable ratios is
$$\mathrm{PR}_w(\omega) = \bigl\{ \mathcal{R}_w(\omega, x) \;:\; x \text{ a phase vector}, \ x \ne 0 \bigr\},$$
and the *periodicity ratio* is $\beta_w(\omega) = \inf \mathrm{PR}_w(\omega)$. We write $\beta_p = \beta_w(\omega_p)$ where
$$\omega_p = \exp\!\left(\frac{2\pi i}{p}\right)$$
is the canonical primitive $p$-th root of unity.

**Definition 2.5 (Walks, reachability, period).** For $n \in \mathbb{N}$ we say $v$ is *reachable from $u$ in $n$ steps*, written $u \rightsquigarrow_n v$, if there is a sequence $u = z_0, z_1, \dots, z_n = v$ with $w_{z_{i}z_{i+1}} \ne 0$ for all $i$. Reachability in $0$ steps is equality. The digraph is *strongly connected* if for all $u,v$ there is some $n$ with $u \rightsquigarrow_n v$. Its *period* is $\gcd\{n \ge 1 : \exists v,\ v \rightsquigarrow_n v\}$.

**Definition 2.6 (Reversal).** The *reversal* of $w$ is $w^{\mathrm{op}}_{uv} = w_{vu}$.

**Definition 2.7 (Root gap).** For $p \ge 2$,
$$g_p \;=\; \min_{1 \le j \le p-1} \bigl\| \omega_p^{\,j} - 1 \bigr\|^2 \;=\; 4 \sin^2\!\left(\frac{\pi}{p}\right),$$
the least squared distance from $1$ to a nontrivial $p$-th root of unity. (We set $g_p = 0$ for $p < 2$.) Thus $g_2 = 4$, $g_3 = 3$, $g_4 = 2$, $g_6 = 1$, and $g_p \sim 4\pi^2/p^2$.

We record the standard facts about $\omega_p$ that we use freely: $\omega_p$ is a primitive $p$-th root of unity for $p \ne 0$; $\|\omega_p\| = 1$; and $\omega_p^n = 1$ if and only if $p \mid n$. Consequently $\omega_p^m = \omega_p^n$ if and only if $m \equiv n \pmod p$.

---

## 3. Basic properties

### 3.1 Nonnegativity and the zero-energy criterion

**Proposition 3.1 (Nonnegativity).** If $w_{uv} \ge 0$ for all $u,v$, then $\mathcal{E}_w(\omega, x) \ge 0$ for all $\omega, x$.

*Proof.* Each summand $w_{uv}\|x_v - \omega x_u\|^2$ is a product of nonnegative reals. $\square$

**Lemma 3.2 (Sufficiency of the arc condition).** If $x_v = \omega x_u$ for every pair $(u,v)$ with $w_{uv} \ne 0$, then $\mathcal{E}_w(\omega,x) = 0$. No sign condition on $w$ is needed.

*Proof.* Every summand vanishes: either $w_{uv} = 0$, or $x_v - \omega x_u = 0$. $\square$

**Theorem 3.3 (Zero energy is an arc-local condition).** Assume $w \ge 0$. Then
$$\mathcal{E}_w(\omega, x) = 0 \iff \bigl(\forall u,v:\ w_{uv} \ne 0 \Rightarrow x_v = \omega x_u\bigr).$$

*Proof sketch.* ($\Leftarrow$) is Lemma 3.2. For ($\Rightarrow$), a finite sum of nonnegative terms vanishes only if every term does. Applying this twice (to the outer and inner sums) gives $w_{uv}\|x_v - \omega x_u\|^2 = 0$ for all $u,v$; if $w_{uv} \ne 0$ then $\|x_v - \omega x_u\|^2 = 0$, hence $x_v = \omega x_u$. $\square$

Theorem 3.3 is the pivot of the whole development: it converts the analytic statement "the Rayleigh quotient vanishes" into the purely combinatorial statement "the phase advances by exactly one tick along every arc".

### 3.2 The universal upper bound

**Theorem 3.4 (Rayleigh quotient at most $2$).** Assume $w \ge 0$ and $\|\omega\| = 1$. Then for every $x$,
$$\mathcal{E}_w(\omega, x) \;\le\; 2\,\mathrm{vol}_w(x),$$
and hence $\mathcal{R}_w(\omega,x) \le 2$ whenever $\mathrm{vol}_w(x) > 0$. In particular $\beta_w(\omega) \le 2$.

*Proof sketch.* Termwise, the triangle inequality gives $\|x_v - \omega x_u\| \le \|x_v\| + \|x_u\|$ (using $\|\omega\| = 1$), and $(a+b)^2 \le 2a^2 + 2b^2$ yields
$$w_{uv}\|x_v-\omega x_u\|^2 \le w_{uv}\bigl(2\|x_v\|^2 + 2\|x_u\|^2\bigr).$$
Summing over all $(u,v)$, the first group contributes $2\sum_v \bigl(\sum_u w_{uv}\bigr)\|x_v\|^2$ (in-degree part) and the second $2\sum_u \bigl(\sum_v w_{uv}\bigr)\|x_u\|^2$ (out-degree part); their sum is exactly $2\sum_v d_v\|x_v\|^2 = 2\,\mathrm{vol}_w(x)$, since $d_v$ is the sum of in- and out-weights. $\square$

This mirrors the bound $\lambda \le 2$ for the normalized Laplacian and fixes the scale on which "small ratio" is meaningful: $\beta_p \in [0,2]$ always.

### 3.3 Reversal invariance

**Lemma 3.5 (Degrees and volumes are reversal-invariant).** $d_v(w^{\mathrm{op}}) = d_v(w)$ for all $v$, and $\mathrm{vol}_{w^{\mathrm{op}}}(\bar x) = \mathrm{vol}_w(x)$, where $\bar x$ is the coordinatewise complex conjugate.

*Proof.* $d_v$ is symmetric in in- and out-weights, and $\|\bar z\| = \|z\|$. $\square$

**Lemma 3.6 (Conjugates of roots of unity are powers).** If $\omega^N = 1$ with $N \ge 1$, then $\bar\omega = \omega^{N-1}$. Consequently the conjugate of a phase vector is a phase vector.

*Proof.* $\omega^N = 1$ forces $\|\omega\| = 1$, hence $\bar\omega\,\omega = |\omega|^2 = 1$; also $\omega \cdot \omega^{N-1} = \omega^N = 1$. Multiplying $\bar\omega$ by $1 = \omega\,\omega^{N-1}$ and cancelling gives $\bar\omega = \omega^{N-1}$. For a phase vector, $\overline{\omega^k} = \omega^{(N-1)k}$. $\square$

**Theorem 3.7 (Reversal invariance of the energy and the ratio).** Let $\|\omega\| = 1$. Then for all $w, x$,
$$\mathcal{E}_{w^{\mathrm{op}}}(\omega, \bar x) = \mathcal{E}_w(\omega, x).$$
If moreover $\omega^N = 1$ for some $N \ge 1$, then $\mathrm{PR}_{w^{\mathrm{op}}}(\omega) = \mathrm{PR}_w(\omega)$ and therefore
$$\beta_{w^{\mathrm{op}}}(\omega) = \beta_w(\omega).$$

*Proof sketch.* For the energy identity, swap the order of summation and compute the generic term. Using $\bar\omega\,\omega = 1$,
$$\bar x_u - \omega \bar x_v = \overline{\,x_u - \bar\omega\, x_v\,} = \overline{\,-\bar\omega\,(x_v - \omega x_u)\,},$$
and taking norms (with $\|\bar\omega\| = 1$) gives $\|\bar x_u - \omega\bar x_v\| = \|x_v - \omega x_u\|$. The weight attached in $w^{\mathrm{op}}$ to the pair $(v,u)$ is $w_{uv}$, so after the swap the two double sums agree termwise. For the ratio sets, conjugation is an involution mapping nonzero phase vectors to nonzero phase vectors (Lemma 3.6) and preserving both numerator and denominator (Lemma 3.5), so it induces a bijection $\mathrm{PR}_{w^{\mathrm{op}}}(\omega) \to \mathrm{PR}_w(\omega)$; applying the inclusion in both directions gives equality, and infima agree. $\square$

Periodicity is thus a property of the *undirected shape* of the arc set, invariant under global arrow reversal — as it must be, since reversing all arcs reverses every closed walk without changing its length.

---

## 4. The zero set of the periodicity ratio

We now identify precisely for which $p$ the periodicity ratio vanishes.

### 4.1 Phases propagate along walks

**Lemma 4.1 (Phase transport).** Suppose $x_v = \omega x_u$ for every arc $u \to v$ of nonzero weight. If $u \rightsquigarrow_n v$, then $x_v = \omega^n x_u$.

*Proof.* Induction on the walk length. Length $0$ is trivial; a walk of length $n+1$ is a walk of length $n$ to some $z$ followed by an arc $z \to v$, whence $x_v = \omega x_z = \omega\cdot\omega^n x_u$. $\square$

**Corollary 4.2 (Support is all-or-nothing).** Under the hypotheses of Lemma 4.1 with $\omega \ne 0$: if $x_u \ne 0$ and $u \rightsquigarrow_n v$, then $x_v \ne 0$. In a strongly connected digraph a nonzero zero-energy vector vanishes nowhere.

### 4.2 Necessity: zero energy forces divisibility

**Theorem 4.3.** Let $w \ge 0$, $p \ge 1$, and suppose $x$ satisfies $\mathcal{E}_w(\omega_p, x) = 0$ with $x_v \ne 0$ for some vertex $v$. Then every closed walk based at $v$ has length divisible by $p$.

*Proof.* By Theorem 3.3, $x$ advances by $\omega_p$ along each arc. If $v \rightsquigarrow_n v$ then Lemma 4.1 gives $x_v = \omega_p^{\,n} x_v$, i.e. $(\omega_p^{\,n} - 1)x_v = 0$. Since $x_v \ne 0$, $\omega_p^{\,n} = 1$, and primitivity gives $p \mid n$. $\square$

### 4.3 Sufficiency: divisibility yields a phase vector

**Theorem 4.4.** Let $V \ne \emptyset$, $p \ge 1$, and let $w$ be strongly connected. If every closed walk has length divisible by $p$, then there is a unimodular $p$-phase vector $x$ (all $\|x_v\| = 1$) with $\mathcal{E}_w(\omega_p, x) = 0$.

*Proof sketch.* Fix a root $r$. By strong connectivity choose for each $v$ a walk $r \rightsquigarrow_{N(v)} v$ and set $x_v = \omega_p^{\,N(v)}$; each $\|x_v\| = 1$ since $\|\omega_p\| = 1$.

It remains to check the arc condition. Let $w_{uv} \ne 0$. Choose (strong connectivity again) a walk $v \rightsquigarrow_k r$. Concatenation yields two closed walks at $r$:
$$r \rightsquigarrow_{N(v)} v \rightsquigarrow_k r \quad\text{of length } N(v)+k, \qquad r \rightsquigarrow_{N(u)} u \to v \rightsquigarrow_k r \quad\text{of length } N(u)+1+k.$$
By hypothesis $p$ divides both, so $\omega_p^{N(v)+k} = 1 = \omega_p^{N(u)+1+k}$. Cancelling the nonzero factor $\omega_p^{\,k}$ gives $\omega_p^{N(v)} = \omega_p^{N(u)+1}$, i.e. $x_v = \omega_p x_u$. Lemma 3.2 concludes. $\square$

Note the proof produces the *canonical* certificate: the phase of a vertex is the length, modulo $p$, of any walk from the root to it — well defined precisely because of the divisibility hypothesis.

### 4.4 The main characterization and its consequences

**Theorem 4.5 (Characterization of vanishing periodicity ratio).** Let $V \ne \emptyset$, let $w \ge 0$ be strongly connected, and let $p \ge 1$. Then the following are equivalent:

1. There exists a unimodular $p$-phase vector $x$ with $\mathcal{E}_w(\omega_p, x) = 0$.
2. $p$ divides the length of every closed walk of the digraph.
3. $p$ divides the period of the digraph.

Moreover (1) implies $\beta_p = 0$, since such an $x$ has $\mathrm{vol}_w(x) > 0$ whenever some degree is positive.

*Proof.* (1) $\Rightarrow$ (2) is Theorem 4.3 applied at any vertex (unimodularity gives $x_v \ne 0$). (2) $\Rightarrow$ (1) is Theorem 4.4. (2) $\Leftrightarrow$ (3) is the definition of the period as the gcd of closed-walk lengths. $\square$

**Corollary 4.6 (Closure under divisors).** If $\beta_p$ vanishes (in the sense of (1)) and $q \mid p$ with $q \ge 1$, then $\beta_q$ vanishes.

*Proof.* Each closed-walk length is divisible by $p$, hence by $q$; apply Theorem 4.5. $\square$

**Corollary 4.7 (Closure under least common multiples).** If $\beta_p$ and $\beta_q$ both vanish then so does $\beta_{\mathrm{lcm}(p,q)}$.

*Proof.* Each closed-walk length is divisible by $p$ and by $q$, hence by $\mathrm{lcm}(p,q)$; apply Theorem 4.5. $\square$

**Corollary 4.8 (Divisor-lattice structure).** For a strongly connected digraph with period $P$,
$$\{p \ge 1 : \beta_p = 0 \text{ via a unimodular certificate}\} \;=\; \{p : p \mid P\}.$$

*Proof.* The set is nonempty ($1$ belongs), closed under divisors and lcm's; a subset of $\mathbb{N}_{\ge 1}$ with these closure properties and a maximum element $P$ is exactly the divisor set of $P$. Theorem 4.5 identifies $P$ with the period. $\square$

Thus the *entire* exact-periodicity content of the rotated Laplacian family is the divisor lattice of the period. Scanning $p$ from $2$ upward and testing $\beta_p = 0$ recovers the period as the largest $p$ passing the test.

### 4.5 A counterexample: vanishing $\beta_p$ does not mean period $p$

It is natural to hope for the stronger statement that $\beta_p = 0$ implies the digraph "has period $p$" in the naive sense of possessing a closed walk of length $p$. This fails.

**Theorem 4.9 (Disproof of the bold converse).** There is a strongly connected nonnegatively weighted digraph on four vertices admitting a unimodular phase vector of zero $2$-rotated energy, in which no closed walk has length $2$. Consequently it is false that
$$\bigl[\ w \ge 0,\ \text{strongly connected},\ \exists\,x \text{ unimodular with } \mathcal{E}_w(\omega_2, x) = 0\ \bigr] \Rightarrow \exists v: v \rightsquigarrow_2 v .$$

*Proof.* Let $V = \mathbb{Z}/4$ and let $C_4$ be the directed cycle with $w_{u,u+1} = 1$ and all other weights $0$. It is strongly connected: $u \rightsquigarrow_k u+k$ for every $k$, so $u \rightsquigarrow_{(v-u)} v$.

*Every closed walk has length divisible by $4$.* An easy induction shows $u \rightsquigarrow_n v$ implies $v = u + n$ in $\mathbb{Z}/4$; taking $v = u$ gives $n \equiv 0 \pmod 4$.

*A zero-energy $2$-phase vector exists.* Here $\omega_2 = e^{\pi i} = -1$. Put $x_v = (-1)^{v}$ (using the representative $v \in \{0,1,2,3\}$). Then $\|x_v\| = 1$ and each $x_v$ is a power of $-1$, so $x$ is a unimodular $2$-phase vector. Every arc is of the form $u \to u+1$, and $(-1)^{u+1} = -\,(-1)^u = \omega_2 x_u$ — one checks the four cases directly, the only subtlety being the wraparound arc $3 \to 0$, where $(-1)^0 = 1 = -(-1)^3$. By Lemma 3.2 the energy is $0$.

Finally, a closed walk of length $2$ would need $4 \mid 2$, which is false; so no closed walk of length $2$ exists. $\square$

The lesson is that $\beta_p = 0$ certifies exactly $p \mid P$ and nothing more — consistent with Corollary 4.8, and the reason that periodicity detection must search for the *largest* passing $p$ rather than any passing $p$.

---

## 5. Markov chains and unimodular eigenvalues

Let $P : V \times V \to \mathbb{R}$ be a stochastic matrix: $P_{uv} \ge 0$ and $\sum_v P_{uv} = 1$ for each $u$. Let $\pi : V \to \mathbb{R}$ be a stationary distribution: $\sum_u \pi_u P_{uv} = \pi_v$ for each $v$. The natural weighting of the digraph of the chain is the *stationary flow*
$$w_{uv} = \pi_u P_{uv} \ \ (\ge 0 \text{ when } \pi \ge 0).$$

### 5.1 A variance identity

**Lemma 5.1 (Row variance identity).** Fix $u$ with $\sum_v P_{uv} = 1$, let $x : V \to \mathbb{C}$, and let $c = \sum_v P_{uv} x_v$ be the mean next-phase. Then
$$\sum_v P_{uv}\,\|x_v - c\|^2 \;=\; \Bigl(\sum_v P_{uv}\|x_v\|^2\Bigr) - \|c\|^2 .$$

*Proof sketch.* Expand $\|x_v - c\|^2 = \|x_v\|^2 + \|c\|^2 - 2\,\mathrm{Re}(x_v \bar c)$ and sum against $P_{uv}$. Since the row sums to $1$, the middle term contributes $\|c\|^2$, and the cross term contributes $2\,\mathrm{Re}\bigl( (\sum_v P_{uv} x_v)\bar c\bigr) = 2\,\mathrm{Re}(c\bar c) = 2\|c\|^2$. Combining, the total is $\sum_v P_{uv}\|x_v\|^2 + \|c\|^2 - 2\|c\|^2$. $\square$

This is $\mathbb{E}\|Z - \mathbb{E}Z\|^2 = \mathbb{E}\|Z\|^2 - \|\mathbb{E}Z\|^2$ for the random variable $Z = x_{V_1}$ under one step of the chain from $u$.

### 5.2 Unimodular eigenvectors have zero energy

**Theorem 5.2.** Let $P$ be stochastic with stationary $\pi$, let $\|\omega\| = 1$, and suppose $x$ is a right eigenvector:
$$\sum_v P_{uv}\,x_v = \omega\, x_u \qquad \text{for all } u.$$
Then $\mathcal{E}_w(\omega, x) = 0$ for $w_{uv} = \pi_u P_{uv}$.

*Proof.* Fix $u$ and apply Lemma 5.1 with $c = \omega x_u$; since $\|\omega\| = 1$ we have $\|c\|^2 = \|x_u\|^2$, so
$$\sum_v \pi_u P_{uv}\|x_v - \omega x_u\|^2 = \pi_u \sum_v P_{uv}\|x_v\|^2 - \pi_u\|x_u\|^2 .$$
Summing over $u$, the first part is $\sum_u \sum_v (\pi_u P_{uv})\|x_v\|^2 = \sum_v \bigl(\sum_u \pi_u P_{uv}\bigr)\|x_v\|^2 = \sum_v \pi_v \|x_v\|^2$ by stationarity, which exactly cancels the second part $\sum_u \pi_u \|x_u\|^2$. Hence $\mathcal{E}_w(\omega, x) = 0$. $\square$

The mechanism deserves emphasis: the eigenvector equation says the next phase is correct *in expectation*; stationarity says the aggregate variance is zero; and zero variance of a nonnegative quantity forces the next phase to be correct *pointwise*, on every arc of positive probability.

### 5.3 The converse

**Theorem 5.3.** Let $P$ be stochastic with $P \ge 0$ and let $\pi_v > 0$ for every $v$. If $\mathcal{E}_w(\omega, x) = 0$ for $w_{uv} = \pi_u P_{uv}$, then $x$ is a right eigenvector of $P$ with eigenvalue $\omega$:
$$\sum_v P_{uv}\,x_v = \omega\,x_u \quad \text{for all } u.$$

*Proof.* By Theorem 3.3, $\pi_u P_{uv} \ne 0 \Rightarrow x_v = \omega x_u$. Since $\pi_u > 0$, this reads $P_{uv} \ne 0 \Rightarrow x_v = \omega x_u$. Hence for every $v$, $P_{uv} x_v = P_{uv}(\omega x_u)$ (trivially when $P_{uv} = 0$). Summing over $v$ and using $\sum_v P_{uv} = 1$ gives the claim. $\square$

**Corollary 5.4 (Peripheral spectrum forces divisibility).** Let $P \ge 0$ be stochastic with nonnegative stationary distribution $\pi$, let $p \ge 1$, and suppose $x$ is a right eigenvector of $P$ with eigenvalue $\omega_p$, with $x_v \ne 0$ for some $v$. Then every closed walk of the flow-weighted digraph $w_{uv} = \pi_u P_{uv}$ based at $v$ has length divisible by $p$.

*Proof.* Theorem 5.2 gives $\mathcal{E}_w(\omega_p, x) = 0$; Theorem 4.3 concludes. $\square$

Corollary 5.4 recovers, from the energy viewpoint, the Perron–Frobenius statement that the eigenvalues of modulus $1$ of an irreducible stochastic matrix are the $P$-th roots of unity, $P$ the period. Together, Theorems 5.2 and 5.3 say that for a chain with everywhere-positive stationary distribution, *unimodular eigenvalues and zero rotated energy are the same phenomenon*. Consequently the rotated spectrum near $0$ is a robust surrogate for the peripheral spectrum of $P$, which is the operational content of "near-periodicity" for Markov chains.

---

## 6. Quantization of the periodicity energy

The results above concern the exact case $\beta_p = 0$. We now analyse the near-miss regime and find, surprisingly, that on a natural class of digraphs the near-miss regime is empty.

### 6.1 Separation of roots of unity

**Lemma 6.1 (Powers depend only on the exponent mod $p$).** For $p \ge 1$, $\omega_p^m = \omega_p^n$ if and only if $m \equiv n \pmod p$.

*Proof.* Assume without loss $n \le m$; then $\omega_p^m = \omega_p^n$ iff $\omega_p^{m-n} = 1$ iff $p \mid m - n$. $\square$

**Lemma 6.2 (Uniform separation).** For $p \ge 2$ the root gap $g_p$ of Definition 2.7 is strictly positive, and for all $a,b \in \mathbb{N}$ with $\omega_p^a \ne \omega_p^b$,
$$\bigl\| \omega_p^a - \omega_p^b \bigr\|^2 \;\ge\; g_p .$$

*Proof sketch.* Positivity: $g_p$ is a minimum over the finite nonempty set $\{1,\dots,p-1\}$ of the quantities $\|\omega_p^j - 1\|^2$, each strictly positive because $\omega_p^j = 1$ would force $p \mid j$, impossible for $0 < j < p$.

Separation: let $j \in \{0,\dots,p-1\}$ be the residue of $a - b$ modulo $p$. If $j = 0$ then $\omega_p^a = \omega_p^b$ by Lemma 6.1, contrary to assumption; so $1 \le j \le p-1$. By Lemma 6.1, $\omega_p^a = \omega_p^b\,\omega_p^{\,j}$, hence
$$\omega_p^a - \omega_p^b = \omega_p^b\bigl(\omega_p^{\,j} - 1\bigr),$$
and $\|\omega_p^b\| = 1$ gives $\|\omega_p^a - \omega_p^b\| = \|\omega_p^{\,j} - 1\|$, which is at least $\sqrt{g_p}$ by definition of the minimum. $\square$

The closed form $g_p = 4\sin^2(\pi/p)$ follows because $\|\omega_p^j - 1\|^2 = 2 - 2\cos(2\pi j/p) = 4\sin^2(\pi j/p)$, minimized over $1 \le j \le p-1$ at $j = 1$ (and $j = p-1$).

### 6.2 The dichotomy

**Theorem 6.3 (Quantization of the rotated energy).** Let $w$ satisfy the *unit-scale condition*: for all $u,v$, either $w_{uv} = 0$ or $w_{uv} \ge 1$. Let $p \ge 2$ and let $x$ be a unimodular $p$-phase vector, i.e. $x_v = \omega_p^{k_v}$ for some exponents $k_v \in \mathbb{N}$. Then
$$\mathcal{E}_w(\omega_p, x) = 0 \qquad\text{or}\qquad \mathcal{E}_w(\omega_p, x) \ \ge\ g_p = 4\sin^2(\pi/p).$$

*Proof.* The unit-scale condition implies $w \ge 0$. Suppose first that $x_v = \omega_p x_u$ for every arc with $w_{uv} \ne 0$; then $\mathcal{E}_w(\omega_p,x) = 0$ by Lemma 3.2 and we are in the first case.

Otherwise there are $u, v$ with $w_{uv} \ne 0$ and $x_v \ne \omega_p x_u$. Write $x_u = \omega_p^{k_u}$, $x_v = \omega_p^{k_v}$; then $\omega_p x_u = \omega_p^{k_u + 1}$, so $\omega_p^{k_v} \ne \omega_p^{k_u+1}$ and Lemma 6.2 gives
$$\|x_v - \omega_p x_u\|^2 = \|\omega_p^{k_v} - \omega_p^{k_u+1}\|^2 \ \ge\ g_p .$$
Since $w_{uv} \ne 0$, the unit-scale condition gives $w_{uv} \ge 1$, so this single summand is at least $g_p$. All other summands are nonnegative, so the double sum dominates it:
$$\mathcal{E}_w(\omega_p, x) \ \ge\ \sum_{z} w_{uz}\|x_z - \omega_p x_u\|^2 \ \ge\ w_{uv}\|x_v - \omega_p x_u\|^2 \ \ge\ g_p . \qquad \square$$

The theorem asserts that a phase vector's energy is *quantized away from* the interval $(0, g_p)$. It is a discreteness phenomenon: the target alphabet $\mu_p$ is a finite set of uniformly separated points, and the weights are bounded below, so a single mistake is expensive.

### 6.3 Rigidity below the threshold

**Corollary 6.4 (Rigidity).** Let $w$ satisfy the unit-scale condition, let $p \ge 2$, and let $x$ be a unimodular $p$-phase vector with
$$\mathcal{E}_w(\omega_p, x) < g_p .$$
Then $\mathcal{E}_w(\omega_p,x) = 0$, and every closed walk of the digraph has length divisible by $p$.

*Proof.* Theorem 6.3 forces the energy to be $0$. Each $x_v$ is a power of $\omega_p$, hence nonzero, so Theorem 4.3 applies at every vertex. $\square$

In words: on a unit-scale digraph, observing *any* phase assignment with energy below $4\sin^2(\pi/p)$ is a proof of exact $p$-periodicity. There is no such thing as being strictly, slightly, nearly $p$-periodic. Approximate structure below the threshold upgrades itself to exact structure.

Two remarks on scope. First, the threshold degrades as $p$ grows: $g_p \approx 4\pi^2/p^2$, so certifying large periods requires proportionally finer energy resolution — an unavoidable feature, since large-$p$ roots of unity really are close together. Second, the corollary applies to *phase* vectors, not to arbitrary complex vectors; a general low-energy eigenvector of the rotated Laplacian need not be quantized, which is precisely why a rounding step is needed in the algorithms of Section 7.

### 6.4 The unit-scale hypothesis is necessary

**Theorem 6.5 (No universal dichotomy without a scale).** For every $\varepsilon > 0$ there exist a strongly connected nonnegatively weighted digraph on four vertices and a unimodular $3$-phase vector $x$ with
$$0 \;<\; \mathcal{E}(\omega_3, x) \;<\; \varepsilon .$$

*Proof.* Let $C_4$ be the directed $4$-cycle of Theorem 4.9 and, for $t > 0$, let $C_4(t)$ have weights $t \cdot (C_4)_{uv}$. Scaling is linear in the energy: $\mathcal{E}_{C_4(t)}(\omega, x) = t\,\mathcal{E}_{C_4}(\omega,x)$ for all $\omega, x$.

Take $x \equiv 1$, a unimodular $3$-phase vector ($1 = \omega_3^0$). Each of the four arcs contributes $\|1 - \omega_3\|^2 = 2 - 2\cos(2\pi/3) = 3$, and each row of $C_4$ sums to $1$, so
$$E := \mathcal{E}_{C_4}(\omega_3, x) = 4\|1-\omega_3\|^2 = 12 > 0,$$
strictly positive because $\omega_3 \ne 1$. Now choose $t = \min\{1, \varepsilon/(2E)\} > 0$. Then $C_4(t)$ has nonnegative weights, is strongly connected (scaling by $t > 0$ preserves the nonzero pattern hence all reachability), and
$$\mathcal{E}_{C_4(t)}(\omega_3, x) = tE > 0, \qquad tE \le \frac{\varepsilon}{2E}\cdot E = \frac{\varepsilon}{2} < \varepsilon . \qquad\square$$

So the unit-scale condition in Theorem 6.3 cannot be dropped, only replaced by an equivalent normalization. Since the failure is caused by global rescaling, which also rescales $\mathrm{vol}_w$, the natural repair for algorithmic purposes is to work with the *ratio* $\mathcal{E}/\mathrm{vol}$ rather than the raw energy: the ratio is scale-invariant, and a quantization statement for it takes the form $\mathcal{R} = 0$ or $\mathcal{R} \ge g_p/\mathrm{vol}_w(x)$, with the denominator controlled by the maximum degree.

---

## 7. Algorithms

The theory above yields a computational pipeline for detecting near-periodic structure. We describe it in the natural order of use.

### 7.1 Exact period by phase propagation

Theorem 4.5 turns period computation into breadth-first search. Fix a root $r$ in a strongly connected digraph, run BFS assigning to each vertex $v$ the length $N(v)$ of the discovered walk $r \rightsquigarrow v$, and for every arc $u \to v$ record the *discrepancy* $\delta = N(u) + 1 - N(v)$. The period is $\gcd$ of all discrepancies (with $\gcd$ of the empty set interpreted as $0$, meaning no cycle). This is correct precisely because Theorem 4.4's construction of the certificate $x_v = \omega_p^{N(v)}$ succeeds if and only if $p$ divides every discrepancy. Complexity: $O(|V| + |E|)$ arithmetic operations plus $O(|E|)$ gcd's.

### 7.2 Rotated Laplacian spectrum

For a candidate $p$, form the Hermitian matrix $L_{\omega_p} = D - A_{\omega_p}$ whose quadratic form is $\mathcal{E}_w(\omega_p,\cdot)$. Its smallest eigenvalue $\lambda_{\min}(p)$ satisfies
$$\lambda_{\min}(p) \;\le\; \beta_p \;\le\; 2,$$
because the phase vectors are a subset of all vectors, so $\beta_p$ is a constrained minimum of the same Rayleigh quotient. The eigenvalue is thus a computable *lower bound certificate*: $\lambda_{\min}(p) > 0$ proves $\beta_p > 0$, hence (by Theorem 4.5) that $p$ does not divide the period. Complexity: $O(|V|^3)$ dense, or $O(|E|)$ per matrix–vector product with iterative methods.

### 7.3 Rounding: from eigenvector to phase vector

The eigenvector $y$ realizing $\lambda_{\min}(p)$ is a general complex vector. Round it to a phase vector by
$$x_v = \begin{cases} 0, & \|y_v\| < \tau, \\ \omega_p^{\,k}, \ k = \mathrm{round}\!\left(\dfrac{p \arg y_v}{2\pi}\right) \bmod p, & \|y_v\| \ge \tau, \end{cases}$$
for a threshold $\tau$. Every rounded vector yields an *upper bound certificate* $\beta_p \le \mathcal{R}_w(\omega_p, x)$. Sweeping $\tau$ over the sorted magnitudes $\|y_v\|$ and returning the best ratio is the periodicity analogue of the classical spectral sweep cut. Complexity: $O(|V|\log|V| + |E|)$ per sweep after the eigenvector computation.

### 7.4 Extracting many nearly-periodic components

To recover several nearly-periodic components rather than one, iterate: compute the best sweep set $S$, record it as a component with its ratio, remove $S$ (or down-weight it), and repeat on the residual digraph until the achievable ratio exceeds a target. Randomization in the choice of the starting eigenvector, and in the sweep threshold, yields a randomized polynomial-time procedure that outputs many components each of small periodicity ratio — the practical goal that motivates the theory.

### 7.5 Certification by rigidity

On a unit-scale digraph (all nonzero weights $\ge 1$), Corollary 6.4 supplies a decisive test: if a rounded phase vector achieves energy $< 4\sin^2(\pi/p)$, then the digraph is *exactly* $p$-periodic and the phase vector is a proof. Since the energy of a phase vector is computable exactly in $O(|E|)$ time, this converts an approximate spectral computation into an exact combinatorial certificate whenever the answer is below threshold.

---

## 8. Discussion

### 8.1 What the theory says and does not say

The results delineate a clean picture. The zero set of $p \mapsto \beta_p$ is exactly the divisor lattice of the period (Corollary 4.8), so the rotated Laplacian family sees periodicity through divisibility. It does not see the period as an *attained* cycle length: the directed $4$-cycle has $\beta_2 = 0$ with no closed walk of length $2$ (Theorem 4.9). The ratio is normalized ($\beta_p \le 2$, Theorem 3.4) and symmetric under arrow reversal (Theorem 3.7), so it is a genuine invariant of the weighted arc structure. For Markov chains the same quantity is the peripheral spectrum in disguise (Theorems 5.2, 5.3).

The most unexpected finding is the quantization theorem. On unit-scale digraphs, the energy of a phase vector cannot lie strictly between $0$ and $4\sin^2(\pi/p)$, so the very notion of a "strictly nearly periodic" configuration is vacuous below the threshold. Approximate periodicity, as measured by phase vectors on this class, is not a continuum but a discrete phenomenon with a gap.

### 8.2 Where the gap comes from, and where it goes

Two ingredients drive the gap: (a) the finiteness and uniform separation of $\mu_p$, and (b) a lower bound on nonzero weights. Removing (b) destroys the conclusion (Theorem 6.5), and by inspection the failure mode is pure rescaling. Removing (a) — allowing arbitrary unimodular coordinates rather than roots of unity — also destroys it, since a continuously varying phase produces continuously varying energy. Both extremes are informative: the gap is exactly the interaction of a discrete alphabet with a fixed scale.

### 8.3 Comparison with the bipartite case

At $p = 2$ everything specializes to familiar territory: $\omega_2 = -1$, phase vectors are $\{-1,0,1\}$-vectors, $\beta_2$ is the bipartiteness ratio, $g_2 = 4$. The rigidity statement then reads: on a graph with all nonzero weights at least $1$, a $\{-1,+1\}$ labelling with signless energy below $4$ has signless energy $0$ and the graph is bipartite. This is transparent in hindsight — a single monochromatic edge costs $|1-(-1)|^2 = 4$ — and the general theorem is the correct extension of that one-line observation to all $p$.

### 8.4 Limitations

Three limitations bear noting. First, the rigidity threshold $g_p$ decays quadratically in $p$, so certifying large periods needs correspondingly precise energy computations. Second, the quantization theorem constrains *phase* vectors only; the eigenvector of the rotated Laplacian is unconstrained and can have arbitrarily small positive Rayleigh quotient, so the gap does not close the analytic-to-combinatorial gap by itself — a rounding step, with its attendant loss, remains necessary. Third, the results here are structural (exact characterizations and a dichotomy); a two-sided Cheeger-type inequality relating $\beta_p$ to $\lambda_{\min}(p)$ with explicit constants is a separate matter, addressed in the literature by rounding arguments of Trevisan type.

---

## 9. Future directions

**A Cheeger inequality for the periodicity ratio.** Prove a two-sided bound $\lambda_{\min}(p) \le \beta_p \le C\sqrt{\lambda_{\min}(p)}$ with explicit $C = C(p)$, generalizing Trevisan's bipartite Cheeger inequality; the easy direction is immediate and the hard direction should follow a sweep-cut analysis over phase-rounded eigenvectors.

**Higher-order and multi-component versions.** Analyse the periodicity-ratio variant of the higher-order spectral algorithm that extracts $k$ nearly-periodic components simultaneously, with guarantees depending on the $k$-th smallest rotated eigenvalue.

**Sharp scale-free quantization.** Replace the unit-scale hypothesis by a normalized statement: determine the exact function $F(p, \Delta)$ such that on digraphs of maximum degree $\Delta$, the *ratio* of a phase vector is either $0$ or at least $F(p,\Delta)$, and show the bound is attained.

**Robustness of rigidity.** Quantify how the dichotomy degrades when the weight lower bound $1$ is replaced by $w_{\min} > 0$: the threshold becomes $w_{\min} g_p$, and it would be interesting to characterize the extremal digraphs achieving equality.

**Spectral gaps and mixing.** Relate $\beta_p$ for small $p$ to quantitative mixing bounds for the underlying chain, converting near-periodicity scores into explicit slow-mixing certificates for Markov chain Monte Carlo diagnostics.

**Beyond cyclic groups.** Replace $\mu_p$ by an arbitrary finite subgroup of the unitary group (or a finite group acting on a vector space) and ask which combinatorial invariants the corresponding "twisted Laplacians" detect; the divisor-lattice theorem should generalize to a statement about the image of the fundamental-group holonomy of the digraph.

---

## 10. Summary of results

| Result | Statement |
|---|---|
| Zero-energy criterion | $\mathcal{E}_w(\omega,x) = 0$ iff $x_v = \omega x_u$ on every arc of nonzero weight ($w \ge 0$) |
| Universal bound | $\mathcal{E}_w(\omega,x) \le 2\,\mathrm{vol}_w(x)$ for $\|\omega\|=1$, hence $\beta_p \le 2$ |
| Reversal invariance | $\mathcal{E}_{w^{\mathrm{op}}}(\omega,\bar x) = \mathcal{E}_w(\omega,x)$ and $\beta_{w^{\mathrm{op}}} = \beta_w$ |
| Main characterization | For strongly connected $w \ge 0$: a unimodular zero-energy $p$-phase vector exists iff $p$ divides every closed-walk length |
| Divisor lattice | $\{p : \beta_p = 0\}$ is closed under divisors and lcm, hence equals the divisors of the period |
| Counterexample | The directed $4$-cycle has $\beta_2 = 0$ yet no closed walk of length $2$ |
| Markov chains | For $w_{uv} = \pi_u P_{uv}$: unimodular right eigenvectors of $P$ have zero energy; conversely if $\pi > 0$ |
| Quantization | Unit-scale weights, $p \ge 2$, phase vector $x$: $\mathcal{E} = 0$ or $\mathcal{E} \ge 4\sin^2(\pi/p)$ |
| Rigidity | Energy $< 4\sin^2(\pi/p)$ forces exact $p$-periodicity |
| Sharpness | Rescaled directed $4$-cycles achieve arbitrarily small positive $3$-energy |

---

## References

- L. Trevisan, *Max cut and the smallest eigenvalue*, SIAM Journal on Computing, 2012.
- A. Louis, P. Raghavendra, P. Tetali, S. Vempala, *Many sparse cuts via higher eigenvalues*, STOC 2012.
- C. Lange, S. Liu, N. Peyerimhoff, O. Post, *Frustration index and Cheeger inequalities for discrete and continuous magnetic Laplacians*, Calculus of Variations and PDE, 2015.
- F. R. K. Chung, *Spectral Graph Theory*, AMS, 1997.
- E. Seneta, *Non-negative Matrices and Markov Chains*, Springer, 2006.
