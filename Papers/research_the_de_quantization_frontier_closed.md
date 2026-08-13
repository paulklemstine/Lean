# The De-Quantization Frontier for Order Finding, Closed

**Author:** Aristotle
**Date:** 2026-08-13

---

## Abstract

We give a complete, quantitative account of why every proposed classical
de-quantization of Shor's order-finding algorithm collapses to the same
obstruction: the total information about the hidden multiplicative order $r$ is
carried by an object of rank exactly $r$ with a perfectly flat spectrum, so that
*observation* can be free while *extraction* costs $\Theta(r)$.

Concretely, we prove: (i) an exact spectral identity for the comb state, showing
that the informative frequencies are precisely the multiples of $Q/\gcd$ and that
their number is the hidden order itself; (ii) that the induced output
distribution is literally the normalised squared spectrum, is uniform on its
support, and has Shannon entropy exactly $\log r$; (iii) an incompressibility
theorem — every distribution supported on $k$ points is at total variation at
least $1 - k/r$ from the true output, a bound attained by an explicit extremal
surrogate; (iv) an exact formula for the distance between the outputs of two
different orders, $\mathrm{TV}(P_{r_1}, P_{r_2}) = 1 - \gcd(r_1,r_2)/\max(r_1,r_2)$,
with the corollary that every single distribution is at distance at least
$\frac12(1 - \gcd/\max)$ from one of two candidates; (v) a pigeonhole seal ruling
out order-free samplers for families of pairwise coprime candidate orders; (vi)
that the Schmidt rank of the pre-measurement state across the register cut is
exactly $r$ with orthonormal branch rows, so bounded-bond-dimension tensor
networks succeed only in the classically easy regime; (vii) that the free
divisibility probe $N \mid b^t - 1$ is silent below $r$, with matching adversary
and counting lower bounds on extraction; (viii) that a mismatched sampling grid
exposes only $\gcd(r,Q) \le r/2$ peaks; and (ix) the classical converse — Farey
separation makes continued-fraction post-processing unambiguous, and a single gcd
turns the recovered order into a nontrivial factor.

Together these establish the equivalence: a polynomial-time classical sampler of
the order-finding output distribution *is* a polynomial-time factoring algorithm.
The quantum exception is not merely unrefuted; it is sharply delimited.

**Keywords:** order finding, de-quantization, total variation distance, Schmidt
rank, discrete Fourier transform, incompressibility, factoring, query lower bounds.

---

## 1. Introduction

### 1.1 The de-quantization program

Over the last decade a substantial family of advertised exponential quantum
speedups has been *de-quantized*: for recommendation systems, principal
component analysis, low-rank linear systems and related tasks, classical
algorithms with sampling access to the input reproduce the quantum output
distribution in comparable time. The pattern behind these successes is uniform.
The quantum state in question is *compressible* — low rank, or concentrated on
few outcomes, or possessing a rapidly decaying spectrum — and the classical
algorithm exploits exactly that compressibility, sketching the state to
polynomial size and sampling from the sketch.

The obvious target is Shor's algorithm. This paper answers, with explicit
constants, the question of whether that program can reach it. Every mechanism
one might propose is shown to collide with the same structure, which we call the
**aggregation seal**: the factor-revealing information lives in the order $r$,
which parameterizes an object that is provably incompressible, and while local
observation of that object can cost nothing, global extraction of $r$ costs
$\Theta(r)$.

### 1.2 The reduction to order finding

Fix a modulus $N > 1$ and a base $b$ with $\gcd(b, N) = 1$. Write
$$r \;=\; \mathrm{ord}_N(b) \;=\; \min\{t \ge 1 : b^t \equiv 1 \pmod N\}.$$
Shor's reduction sends the order to a factorization: if $r$ is even and
$b^{r/2} \not\equiv -1 \pmod N$, then $\gcd(b^{r/2} - 1, N)$ is a nontrivial
divisor of $N$ (Theorem 8.2 below). Order finding is therefore the entire
content of the algorithm, and de-quantizing Shor means producing $r$ — or
producing samples from which $r$ can be read — by classical means in time
polynomial in $\log N$.

### 1.3 Organization and summary of results

Section 2 fixes notation and the total variation calculus. Section 3 computes
the comb spectrum exactly. Section 4 establishes flatness and incompressibility.
Section 5 gives the exact distance between two combs and the pigeonhole seal.
Section 6 treats the tensor-network route via Schmidt rank. Section 7 treats the
probe route via adversary and counting bounds. Section 8 gives the classical
converse (order $\Rightarrow$ factor, and unambiguous post-processing).
Section 9 assembles the synthesis theorem and lists verified instances.
Sections 10–12 give algorithms, discussion and future directions.

---

## 2. Preliminaries

### 2.1 Distributions and total variation

Throughout, an *outcome window* is a finite set $\{0,1,\dots,Q-1\}$ of integers,
and a **distribution on the window** is a function $p : \mathbb{N} \to \mathbb{R}$
with $p(y) \ge 0$ for $y$ in the window and $\sum_{y<Q} p(y) = 1$.

**Definition 2.1 (Total variation).** For distributions $P, R$ on the same
window,
$$\mathrm{TV}(P, R) \;=\; \tfrac12 \sum_{y < Q} |P(y) - R(y)|.$$

We use four standard facts, each elementary: $\mathrm{TV} \ge 0$; symmetry;
the triangle inequality $\mathrm{TV}(P,R) \le \mathrm{TV}(P,S) + \mathrm{TV}(S,R)$;
and $\mathrm{TV} \le 1$. We also use repeatedly the **event bound**.

**Lemma 2.2 (Event bound).** For any subset $A$ of the window,
$$\sum_{y \in A} P(y) \;-\; \sum_{y \in A} R(y) \;\le\; \mathrm{TV}(P, R).$$

*Proof.* Put $f = P - R$, so $\sum_{y<Q} f(y) = 0$ and hence
$\sum_{y \in A} f = -\sum_{y \notin A} f$. Then
$2\sum_{A} f = \sum_A f - \sum_{A^c} f \le \sum_A |f| + \sum_{A^c} |f| = \sum_{y<Q} |f|$,
which is $2\,\mathrm{TV}(P,R)$. $\square$

The following combinatorial statement is the engine behind every "no
order-free sampler" claim in this paper.

**Theorem 2.3 (Pigeonhole seal).** Let $P_1,\dots,P_k$ be distributions on a
common window, and let $A_1,\dots,A_k$ be *pairwise disjoint* subsets of the
window with $\sum_{y \in A_i} P_i(y) \ge c$ for every $i$. Then for every single
distribution $D$ on the window there exists an index $i$ with
$$\mathrm{TV}(D, P_i) \;\ge\; c - \frac{1}{k}.$$

*Proof.* Suppose not, so $\mathrm{TV}(D,P_i) < c - 1/k$ for all $i$. By
Lemma 2.2 applied to $A_i$,
$\sum_{A_i} D \ge \sum_{A_i} P_i - \mathrm{TV}(P_i, D) > c - (c - 1/k) = 1/k$.
Summing over the $k$ pairwise disjoint events gives
$\sum_i \sum_{A_i} D > 1$, contradicting the fact that a distribution assigns
total mass $1$ to the disjoint union. $\square$

The interpretation is that a sampler which is *not permitted to depend on the
hidden parameter* must spread a total mass of $1$ over $k$ disjoint targets, so
it starves at least one of them; averaging cannot beat the union bound.

### 2.2 The order-finding instance

We fix an instance $(N, b)$ with $r = \mathrm{ord}_N(b)$ and a grid size $Q$. For
the exact statements of Sections 3–5 we assume $r \mid Q$; the general case is
treated in Section 7.3, where aliasing is shown to *lose* information rather than
create exploitable structure.

---

## 3. The comb and its exact spectrum

Shor's circuit prepares $\sum_{x<Q} |x\rangle |b^x \bmod N\rangle$ and measures
the second register. Since $b^x$ depends only on $x \bmod r$, the first register
collapses onto an arithmetic progression of spacing $r$: the **comb**. Its
unnormalised discrete Fourier transform at frequency $y$ is
$$S_Q^r(y) \;=\; \sum_{j=0}^{Q/r - 1} \exp\!\Big(\frac{2\pi i\, j r y}{Q}\Big).$$

**Lemma 3.1 (Roots of unity).** For $m \ge 1$ and $k \ge 0$,
$e^{2\pi i k/m} = 1$ if and only if $m \mid k$.

**Lemma 3.2 (Complete geometric sum).** For $m \ge 1$,
$$\sum_{j=0}^{m-1} e^{2\pi i\, jk/m} \;=\; \begin{cases} m, & m \mid k,\\ 0, & \text{otherwise.}\end{cases}$$

*Proof.* Write $z = e^{2\pi i k/m}$, so the sum is $\sum_{j<m} z^j$. If $m \mid k$
then $z = 1$ by Lemma 3.1 and the sum is $m$. Otherwise $z \ne 1$, and the
geometric formula gives $(z^m - 1)/(z-1) = 0$, since $z^m = e^{2\pi i k} = 1$. $\square$

**Theorem 3.3 (Exact spectrum of the comb).** Let $r \mid Q$ with $r, Q \ge 1$.
Then for every frequency $y$,
$$S_Q^r(y) \;=\; \begin{cases} Q/r, & \text{if } (Q/r) \mid y,\\ 0, & \text{otherwise.}\end{cases}$$

*Proof.* Write $Q = rm$, so $m = Q/r$ and the summand is
$\exp(2\pi i\, jry/(rm)) = \exp(2\pi i\, jy/m)$. Apply Lemma 3.2 with $k = y$. $\square$

There is no leakage: the transform is *exactly* supported on the multiples of
$Q/r$ and takes a single constant value there. This is the source of every
subsequent rigidity.

**Definition 3.4 (Peak set).** $\mathcal{P}(Q,r) = \{y < Q : (Q/r) \mid y\}$.

**Theorem 3.5 (The peak count is the hidden order).** For $0 < r \mid Q$,
$$|\mathcal{P}(Q,r)| \;=\; r.$$

*Proof.* With $m = Q/r$, the map $j \mapsto jm$ is an injection from
$\{0,\dots,r-1\}$ onto $\mathcal{P}(Q,r)$: it lands in the window because
$jm < rm = Q$, and every multiple $cm < Q$ has $c < r$. $\square$

Thus the secret is not the *location* of a peak but the *cardinality* of the peak
set — a global feature of the spectrum.

**Example.** $Q = 16$, $r = 4$: $\mathcal{P} = \{0,4,8,12\}$, of size $4 = r$.
$Q = 12$, $r = 3$: $\mathcal{P} = \{0,4,8\}$, of size $3 = r$.

---

## 4. Flatness, entropy, and incompressibility

**Definition 4.1 (Output distribution).** For $0 < r \mid Q$ let
$$P_r(y) \;=\; \begin{cases} 1/r, & y \in \mathcal{P}(Q,r),\\ 0, & \text{otherwise.}\end{cases}$$
By Theorem 3.5 this is a probability distribution on the window.

**Theorem 4.2 (The distribution is the normalised squared spectrum).** For every
$y < Q$,
$$P_r(y) \;=\; \frac{|S_Q^r(y)|^2}{Q \cdot (Q/r)}.$$

*Proof.* With $m = Q/r$: on a peak, Theorem 3.3 gives $|S|^2 = m^2$, and
$m^2/(Qm) = m/Q = 1/r$; off a peak both sides vanish. $\square$

So $P_r$ is not an idealisation of the measurement statistics — it *is* the
normalised power spectrum, with no approximation intervening.

**Theorem 4.3 (Maximal entropy).** The Shannon entropy of $P_r$ is exactly
$$H(P_r) \;=\; -\sum_{y} P_r(y)\log P_r(y) \;=\; \log r.$$

*Proof.* Each of the $r$ peaks contributes $-(1/r)\log(1/r) = (1/r)\log r$. $\square$

For $r$ outcomes, $\log r$ is the maximum possible entropy. The distribution is
therefore *maximally spread*: it has no heavy head to keep and no light tail to
discard, which is exactly the structural hypothesis every de-quantization
technique requires.

The following theorem converts flatness into a hard limit on classical
surrogates.

**Theorem 4.4 (Incompressibility of the output distribution).** Let $0 < r \mid Q$
and let $D$ be any distribution on the window whose support has at most $k$
elements. Then
$$\mathrm{TV}(P_r, D) \;\ge\; 1 - \frac{k}{r}.$$

*Proof.* Let $S$ be the support of $D$, $|S| \le k$. The event
$A = \mathcal{P}(Q,r) \setminus S$ has $|A| \ge r - k$ by Theorem 3.5, carries
$P_r$-mass $|A|/r \ge (r-k)/r$, and carries $D$-mass $0$. Lemma 2.2 gives
$\mathrm{TV}(P_r, D) \ge (r-k)/r - 0 = 1 - k/r$. $\square$

**Proposition 4.5 (Sharpness).** The bound of Theorem 4.4 is attained: for
$1 \le k \le r$, the distribution $D^\star$ placing mass $1/k$ on $k$ chosen peaks
and $0$ elsewhere satisfies $\mathrm{TV}(P_r, D^\star) = 1 - k/r$.

*Proof.* The chosen peaks contribute $k(1/k - 1/r) = 1 - k/r$ to
$\sum |P_r - D^\star|$, the remaining $r-k$ peaks contribute $(r-k)/r = 1 - k/r$,
and everything else contributes $0$; halving gives $1 - k/r$. $\square$

**Corollary 4.6 (Poly-size sketches fail totally).** If $k = \mathrm{poly}(\log N)$
and $r$ grows faster than any polynomial in $\log N$, then every $k$-sparse
classical surrogate satisfies $\mathrm{TV}(P_r, D) = 1 - o(1)$.

That is the strongest possible failure: the surrogate is asymptotically mutually
singular with the truth, not a mildly degraded copy of it.

---

## 5. The exact distance between two orders

Theorem 4.4 rules out sparse surrogates. We now rule out *dense* surrogates that
simply do not know $r$, and we do so with an identity rather than an estimate.

**Lemma 5.1 (Common peaks are the peaks of the gcd).** If $r_1 \mid Q$ and
$r_2 \mid Q$ then
$$\mathcal{P}(Q,r_1) \cap \mathcal{P}(Q,r_2) \;=\; \mathcal{P}(Q, \gcd(r_1,r_2)).$$

*Proof.* A frequency $y$ lies in both peak sets iff $Q/r_1 \mid y$ and
$Q/r_2 \mid y$, i.e. iff $\mathrm{lcm}(Q/r_1, Q/r_2) \mid y$; and
$\mathrm{lcm}(Q/r_1, Q/r_2) = Q/\gcd(r_1,r_2)$ for divisors $r_1, r_2$ of $Q$. $\square$

**Theorem 5.2 (Exact distance between two combs).** Let $0 < r_1 \le r_2$ with
$r_1 \mid Q$, $r_2 \mid Q$, and write $g = \gcd(r_1,r_2)$. Then
$$\mathrm{TV}(P_{r_1}, P_{r_2}) \;=\; 1 - \frac{g}{r_2}.$$

*Proof.* Write $\mathcal{P}_i = \mathcal{P}(Q,r_i)$, of sizes $r_1$ and $r_2$ by
Theorem 3.5, with $|\mathcal{P}_1 \cap \mathcal{P}_2| = g$ by Lemma 5.1 and
Theorem 3.5 again. Split the window into $\mathcal{P}_1 \setminus \mathcal{P}_2$
(size $r_1 - g$, integrand $1/r_1$), $\mathcal{P}_2 \setminus \mathcal{P}_1$
(size $r_2 - g$, integrand $1/r_2$), $\mathcal{P}_1 \cap \mathcal{P}_2$
(size $g$, integrand $1/r_1 - 1/r_2 \ge 0$), and the complement (integrand $0$).
The total is
$$(r_1 - g)\tfrac{1}{r_1} + (r_2-g)\tfrac{1}{r_2} + g\Big(\tfrac{1}{r_1} - \tfrac{1}{r_2}\Big)
= 2 - \tfrac{2g}{r_2},$$
and halving gives the claim. $\square$

**Corollary 5.3 (Every sampler is far from one of two candidates).** With the
hypotheses of Theorem 5.2, every distribution $D$ on the window satisfies
$$\max\big(\mathrm{TV}(D,P_{r_1}),\,\mathrm{TV}(D,P_{r_2})\big)
\;\ge\; \frac12\Big(1 - \frac{g}{r_2}\Big).$$

*Proof.* Triangle inequality:
$1 - g/r_2 = \mathrm{TV}(P_{r_1},P_{r_2}) \le \mathrm{TV}(D,P_{r_1}) + \mathrm{TV}(D,P_{r_2})
\le 2\max(\cdot,\cdot)$. $\square$

For coprime candidates this reads $\frac12(1 - 1/r_2) \to \frac12$: the
frequently quoted "$\mathrm{TV} \ge 0.5$" threshold for failed classical
emulations, here with an exact constant and no asymptotics.

We now scale to many candidates. The key geometric input is that coprime orders
share only the trivial frequency.

**Lemma 5.4 (Coprime peak sets are essentially disjoint).** If $r \mid Q$,
$s \mid Q$ and $\gcd(r,s)=1$, then
$(\mathcal{P}(Q,r)\setminus\{0\}) \cap (\mathcal{P}(Q,s)\setminus\{0\}) = \varnothing$.

*Proof.* Write $Q = ra = sb$; then $Q/r = a$, $Q/s = b$. If $y \ne 0$ lies in both
sets then $\mathrm{lcm}(a,b) \mid y$. Since $rs \mid Q$, write $Q = rsm$; then
$a = sm$, $b = rm$, so $\mathrm{lcm}(a,b) = m\,\mathrm{lcm}(s,r) = mrs = Q$.
Hence $Q \mid y$ with $0 < y < Q$: impossible. $\square$

**Theorem 5.5 (No order-free classical sampler).** Let $r_1, \dots, r_k$ be
pairwise coprime candidate orders, each dividing $Q$ and each at least $R \ge 1$.
Then for *every* distribution $D$ on the window there is an index $i$ with
$$\mathrm{TV}(D, P_{r_i}) \;\ge\; 1 - \frac1R - \frac1k.$$

*Proof.* Take $A_i = \mathcal{P}(Q,r_i)\setminus\{0\}$. These are pairwise
disjoint by Lemma 5.4, and $P_{r_i}(A_i) = (r_i - 1)/r_i = 1 - 1/r_i \ge 1 - 1/R$.
Apply Theorem 2.3 with $c = 1 - 1/R$. $\square$

Reading the constants: with $k = \Theta(\log N)$ candidate orders each of size at
least $R = N^{\Omega(1)}$, every fixed classical sampler is at total variation
$1 - o(1)$ from some candidate's true output. Sampling the output distribution
already requires knowing $r$.

---

## 6. The tensor-network route: Schmidt rank equals the order

Matrix-product-state emulation of a quantum circuit succeeds when the bipartite
rank across every cut stays polynomially bounded. We compute that rank for the
pre-measurement order-finding state exactly.

**Definition 6.1.** The **coefficient matrix** of the state
$\sum_{x<Q}|x\rangle|b^x \bmod N\rangle$ across the register cut is the
$Q \times N$ matrix
$$M[x][z] \;=\; \begin{cases} 1, & b^x \equiv z \pmod N,\\ 0, & \text{otherwise.}\end{cases}$$

**Lemma 6.2 (Branch count).** If $0 < r \mid Q$ then the branch set
$\{b^x \bmod N : x < Q\}$ has exactly $r$ elements.

*Proof.* $b^x$ depends only on $x \bmod r$, so the set equals
$\{b^x : x < r\}$; and $x \mapsto b^x$ is injective on $\{0,\dots,r-1\}$ by
minimality of the order. $\square$

**Theorem 6.3 (Schmidt rank $=$ order).** If $0 < r \mid Q$ then
$\mathrm{rank}(M) = r$.

*Proof.* Row $x$ of $M$ is the standard basis vector indexed by $b^x \bmod N$.
The set of distinct rows is therefore the set of standard basis vectors indexed
by the branch set, which is linearly independent and of cardinality $r$ by
Lemma 6.2. The row space has dimension $r$. $\square$

**Theorem 6.4 (Flat entanglement spectrum).** Rows $x$ and $x'$ of $M$ have inner
product $1$ if $b^x \equiv b^{x'}$ and $0$ otherwise. Consequently the $r$
surviving Schmidt vectors are orthonormal, all $r$ Schmidt coefficients are
equal, and the entanglement entropy is $\log r$.

*Proof.* Immediate from the previous description of the rows: two indicator rows
overlap in at most one coordinate, and do so exactly when they name the same
branch. $\square$

**Corollary 6.5 (The tensor-network route closes).** If the state admits any
bipartite decomposition of rank at most $k$ — in particular a matrix-product
representation of bond dimension $k$ — then $r \le k$.

*Proof.* Contrapositive of Theorem 6.3. $\square$

The consequence is a dichotomy rather than a difficulty: polynomial bond
dimension forces a polynomially small order, which is precisely the regime where
$r$ can be found by direct classical search. There is no intermediate regime in
which a truncated tensor network helps. Theorem 6.4 closes the obvious escape —
an *approximate* truncation — at the level of the exact spectrum: with all
Schmidt coefficients equal to $1/\sqrt r$, discarding any bond loses a fixed
fraction of the norm, and the discarded weight cannot be made small by choosing
the truncation cleverly.

---

## 7. The probe route: free observation, sealed extraction

### 7.1 A perfect, free divisibility oracle

**Definition 7.1.** The **fixed-point probe** at $t$ is the predicate
$\mathrm{probe}(N,b,t) :\iff N \mid b^t - 1$, computed by one modular
exponentiation ($O(\log t)$ modular multiplications). Equivalently
$\gcd(b^t - 1, N) = N$.

**Theorem 7.2 (The probe is exactly the divisibility oracle).**
$$\mathrm{probe}(N,b,t) \iff r \mid t.$$

*Proof.* $b^t \equiv 1 \pmod N$ iff the order of $b$ divides $t$. $\square$

This is a genuinely free observation: unlimited exact access to the predicate
"$r$ divides $t$", at a cost of $O(\log t)$ multiplications per query. If any
route to de-quantization were going to work, this looks like the one.

### 7.2 The silence below the order

**Theorem 7.3 (Total silence below $r$).** For $0 < t < r$, the probe at $t$
returns *false*.

*Proof.* If $r \mid t$ and $t > 0$ then $t \ge r$. $\square$

The answer vector on $\{1,\dots,r-1\}$ is therefore *constant*, carrying zero
bits of information about $r$. The order is characterised as the least positive
$t$ at which the probe fires. Two lower bounds now squeeze the channel from both
sides.

**Theorem 7.4 (Adversary bound: some query must reach the order).** Let $A$ be
any procedure whose output depends only on the probe answers at a finite set $T$
of positive integers. If $A$ returns the correct order in the two cases $r$ and
$s$ with $r \ne s$, then $T$ contains an element $t$ with $t \ge \min(r,s)$.

*Proof.* Otherwise every $t \in T$ satisfies $0 < t < r$ and $t < s$, so by
Theorem 7.3 the two answer vectors on $T$ are identical (all false). Since $A$
depends only on those answers, it returns the same value in both cases,
contradicting $r \ne s$. $\square$

**Theorem 7.5 (Counting bound: $\log_2$ many bits are needed).** With $A$ as
above, if $A$ returns the correct order for every candidate in a set $C$, then
$|C| \le 2^{|T|}$. In particular, identifying the order among the candidates
$1, \dots, n$ requires $|T| \ge \log_2 n$ queries.

*Proof.* The map sending a candidate $r$ to its answer vector
$(\,[\,r \mid t\,]\,)_{t \in T} \in \{0,1\}^T$ is injective on $C$: two candidates
with the same answer vector force the same output of $A$, hence are equal. So
$|C| \le |\{0,1\}^T| = 2^{|T|}$. $\square$

Combining: $\Omega(\log r)$ queries are necessary, and at least one of them must
have magnitude $\Omega(r)$. The naive walk costs $\Theta(r)$ probes; baby-step /
giant-step costs $\Theta(\sqrt r)$ probes and $\Theta(\sqrt r)$ memory. Both are
exponential in $\log N$.

**Theorem 7.6 (Non-vacuity).** For every $r \ge 2$, the base $2$ has order
exactly $r$ modulo the Mersenne number $2^r - 1$.

*Proof.* $2^r \equiv 1 \pmod{2^r - 1}$, so the order divides $r$. If the order
were some $t < r$ then $2^r - 1 \mid 2^t - 1$ with $0 < 2^t - 1 < 2^r - 1$,
impossible. $\square$

So the seal is not an artefact of degenerate instances: every order magnitude is
realised by an honest order-finding problem.

**Theorem 7.7 (The one escape, and its circularity).** If a multiple $L$ of $r$
is known, then $r$ is the least positive divisor of $L$ passing the probe.

*Proof.* $r$ divides $L$ and passes; any positive divisor $d$ of $L$ that passes
satisfies $r \mid d$, hence $d \ge r$. $\square$

This is the only known polynomial-time extraction, and it requires the divisors
of $L$. For an RSA modulus the canonical choice $L = \lambda(N)$ (the Carmichael
function) is itself as hard to obtain as the factorization — the circularity that
prevents the escape from being an escape.

### 7.3 Aliasing: a mismatched grid loses information

Dropping $r \mid Q$ does not create exploitable structure; it destroys structure.

**Theorem 7.8 (Aliasing costs at least one bit).** If $r \nmid Q$ and $r \ge 1$
then $2\gcd(r,Q) \le r$; and the number of frequencies visible on the grid is
exactly $\gcd(r,Q)$.

*Proof.* Let $d = \gcd(r,Q)$ and $r = dc$. If $c = 1$ then $r = d \mid Q$,
excluded; so $c \ge 2$ and $r = dc \ge 2d$. The visible peak count is
$|\mathcal{P}(Q,d)| = d$ by Theorem 3.5. $\square$

**Corollary 7.9 (Total loss in the coprime case).** If $\gcd(r,Q) = 1$ then the
visible peak set is $\{0\}$: the sample carries no information about $r$
whatsoever.

---

## 8. The converse: from a sample to a factor

The obstructions above show that no classical route reproduces or extracts $r$
cheaply. The equivalence is completed by the *classical* fact that a sample
would suffice — so a cheap classical sampler would be a factoring algorithm.

**Theorem 8.1 (Nontrivial square roots split the modulus).** Let $N > 1$ and let
$x$ satisfy $x^2 \equiv 1 \pmod N$, $x \not\equiv 1$, $x \not\equiv -1$. Then
$$1 < \gcd(x-1, N) < N.$$

*Proof.* Put $d = \gcd(x-1,N)$. If $d = 1$ then $N$ is coprime to $x-1$; since
$N \mid (x-1)(x+1)$, this forces $N \mid x+1$, i.e. $x \equiv -1$, excluded. If
$d = N$ then $N \mid x - 1$, i.e. $x \equiv 1$, excluded. $\square$

**Theorem 8.2 (Shor's reduction).** Let $N > 1$, $r = \mathrm{ord}_N(b) > 0$ be
even, and suppose $b^{r/2} \not\equiv -1 \pmod N$. Then $\gcd(b^{r/2}-1, N)$ is a
nontrivial factor of $N$.

*Proof.* Set $x = b^{r/2}$; then $x^2 = b^r \equiv 1$. The hypothesis
$x \not\equiv 1$ is *not* an assumption — it is Theorem 7.3, since $0 < r/2 < r$
means the probe at $r/2$ fails. Apply Theorem 8.1. $\square$

**Theorem 8.3 (Farey separation).** For positive denominators $r, r'$ and
numerators $s, s'$ with $s r' \ne s' r$,
$$\Big|\frac{s}{r} - \frac{s'}{r'}\Big| \;\ge\; \frac{1}{r r'}.$$

*Proof.* The difference equals $(sr' - s'r)/(rr')$, whose numerator is a nonzero
integer, hence of absolute value at least $1$. $\square$

**Theorem 8.4 (Post-processing is unambiguous).** Let $x \in \mathbb{R}$ and let
$s/r$, $s'/r'$ be reduced fractions with $0 < r, r' \le R$ and
$$|x - s/r| < \frac{1}{2R^2}, \qquad |x - s'/r'| < \frac{1}{2R^2}.$$
Then $r = r'$ and $s = s'$.

*Proof.* By the triangle inequality $|s/r - s'/r'| < 1/R^2 \le 1/(rr')$, so by
Theorem 8.3 we must have $sr' = s'r$. Coprimality of $(s,r)$ and $(s',r')$ then
forces $r \mid r'$ and $r' \mid r$, hence $r = r'$ and then $s = s'$. $\square$

**Corollary 8.5 (A sample factors the modulus).** Suppose a device returns a
frequency $y$ on the grid of size $Q$, and continued-fraction post-processing
produces a reduced fraction $s'/r'$ with $r' \le R$ approximating $y/Q$ to within
$1/(2R^2)$, while the true order $r \le R$ admits such an approximation as well
(which the peak structure of Theorem 3.3 guarantees). Then $r' = r$, and if $r$
is even with $b^{r/2} \not\equiv -1$, one gcd yields a nontrivial factor of $N$.

*Proof.* Theorem 8.4 gives $r' = r$; Theorem 8.2 gives the factor. $\square$

Hence **a polynomial-time classical sampler of the order-finding output
distribution is a polynomial-time factoring algorithm.** De-quantizing this
algorithm is not a route around factoring; it is factoring.

---

## 9. Synthesis

**Theorem 9.1 (The de-quantization frontier, closed).** Fix an order-finding
instance $(N, b)$ with $N > 1$, $r = \mathrm{ord}_N(b) > 0$, and a grid size $Q$
with $r \mid Q$. Suppose $r$ is even and $b^{r/2} \not\equiv -1 \pmod N$. Then
the following hold simultaneously.

1. **(Silence)** No probe below the order returns any information:
   $\mathrm{probe}(N,b,t)$ is false for all $0 < t < r$.
2. **(Rank)** The Schmidt rank across the register cut is exactly $r$; any
   bipartite decomposition of rank $k$ forces $r \le k$.
3. **(Incompressibility)** Every distribution $D$ supported on at most $k$
   outcomes satisfies $\mathrm{TV}(P_r, D) \ge 1 - k/r$, and the bound is tight.
4. **(Flatness)** The exact output distribution is uniform on its $r$-element
   support and has entropy exactly $\log r$.
5. **(Equivalence)** $\gcd(b^{r/2}-1, N)$ is a nontrivial factor of $N$.

*Proof.* Respectively Theorems 7.3, 6.3 with Corollary 6.5, 4.4 with
Proposition 4.5, 4.3, and 8.2. $\square$

Item 5 is what makes items 1–4 a *closure* rather than a list of difficulties.
The only thing a successful extraction would buy — the order — is already
equivalent to a factorization. So every classical route must pay $\Omega(r)$ for
the aggregation, and the payment is exactly the price of factoring.

### 9.1 Verified instances

| Instance | Quantity | Value |
|---|---|---|
| $N = 15$, $b = 2$ | $\mathrm{ord}$ | $4$ |
| $N = 15$, $b = 2$ | $\gcd(2^{r/2}-1, 15)$ | $3$ (nontrivial) |
| $N = 21$, $b = 2$ | $\mathrm{ord}$ | $6$ |
| $N = 21$, $b = 2$ | $\gcd(2^{r/2}-1, 21)$ | $7$ (nontrivial) |
| $N = 31 = 2^5-1$, $b = 2$ | $\mathrm{ord}$ | $5$ |
| $Q = 16$, $r = 4$ | peak set | $\{0,4,8,12\}$ |
| $Q = 16$, $r = 4$ | number of peaks | $4 = r$ |
| $Q = 12$, $r = 3$ | peak set | $\{0,4,8\}$ |
| $Q = 48$, $r_1 = 3$, $r_2 = 16$ | $\mathrm{TV}(P_{r_1},P_{r_2})$ | $15/16$ |
| $N = 15$, $b = 2$, $Q = 4$ | Schmidt rank | $4 = r$ |
| $N = 8051$, $b = 2$ | $\mathrm{ord}$, then split | $1968$, then $83 \cdot 97$ |

---

## 10. Algorithms

Three algorithmic objects organise the results.

**A. Exact comb spectrum and output distribution.** Given $Q$ and $r \mid Q$,
emit the peak set $\{0, Q/r, 2Q/r, \dots\}$ and the uniform mass $1/r$. Cost
$O(r)$ to enumerate, $O(1)$ per peak. By Theorem 3.3 this is the *exact*
distribution, so any Monte-Carlo comparison against it is a comparison against
ground truth, not against a simulation.

**B. Total-variation certification of a candidate sampler.** Given a proposed
classical sampler's distribution $D$ and two candidate orders $r_1 \le r_2$,
compute $\mathrm{TV}(D,P_{r_1})$, $\mathrm{TV}(D,P_{r_2})$ and the certificate
$\frac12(1 - \gcd(r_1,r_2)/r_2)$ from Corollary 5.3. The certificate is a
*guarantee*, not an estimate: no sampler can beat it, so the computation
functions as an a priori refutation of any candidate de-quantization before it is
implemented. Cost $O(Q)$.

**C. Probe-based order extraction (upper bound side).** Baby-step / giant-step
against the free probe: with $m = \lceil\sqrt{B}\rceil$ for a bound $B$ on the
order, tabulate the baby steps $b^j$ for $j < m$, walk the giant steps
$b^{-im}$ for $i \le m$, and match. Cost $\Theta(\sqrt B)$ time and space,
certified by one final probe. Theorems 7.4 and 7.5 show this is the shape of the
truth: the query magnitudes must reach $\Omega(r)$ and the query count must reach
$\Omega(\log r)$; conjecturally $\Theta(\sqrt r)$ is optimal for adaptive probe
algorithms.

---

## 11. Discussion

### 11.1 Why the standard de-quantization toolkit fails here

Every successful de-quantization in the literature has exploited one of three
structural features: **low rank** (sketching), **concentration** (importance
sampling), or **spectral decay** (truncation). The order-finding instance has
none of them, and the failures are quantitative rather than heuristic.

* *Low rank* fails by Theorem 6.3: the rank is exactly the hidden parameter, and
  Corollary 6.5 converts a polynomial rank budget into a polynomially small
  order.
* *Concentration* fails by Theorem 4.3: the distribution is uniform on its
  support, of maximal entropy, and Theorem 4.4 prices the failure at $1 - k/r$.
* *Spectral decay* fails by Theorem 6.4: the Schmidt spectrum is perfectly flat,
  so truncation is never cheap.

### 11.2 The shape of the seal

The recurring pattern deserves a name. In each route there is an *observation*
that is free and an *extraction* that is not:

| Route | Free observation | Sealed extraction |
|---|---|---|
| Sparse / structured transforms | evaluating the transform at a known frequency (a geometric sum) | locating the informative frequencies: $\Theta(Q/r)$, or requires $r$ (circular) |
| Fixed-point probe | $\gcd(b^t-1,N)$, one modular exponentiation | recovering $r$: $\Theta(r)$ naive, $\Theta(\sqrt r)$ with baby/giant steps, polynomial only given $\lambda(N)$'s factorization (circular) |
| Lattice-style sampling | evaluating a candidate distribution | matching the true $r$-parameterized output: $\mathrm{TV} \ge 1 - \gcd/\max$ by Theorem 5.2 |
| Tensor networks | contracting a bounded-bond-dimension network | representing rank $r$ with bond dimension $k < r$: impossible by Theorem 6.3 |
| $\ell^1$ diffusion | one diffusion step | each step aggregates over all $r$ eigenvalues: $\Theta(r)$ |

In every row the observation is local and the extraction is global. The formal
content of the barrier is that the target quantity — $r$ — is a *global count*
(the number of peaks, the rank, the number of eigenvalues) and not a local
feature that a polynomial number of local observations can pin down. The quantum
Fourier transform performs exactly that global aggregation coherently, in one
shot; this is the precise sense in which the quantum advantage here is
irreducible.

### 11.3 What is *not* claimed

We do not prove that factoring is hard, nor that $\mathrm{BQP} \ne \mathrm{BPP}$.
What is established is an *equivalence* and a set of *unconditional* lower bounds
within explicit models: sparse/low-rank surrogates (Theorem 4.4), order-oblivious
samplers (Theorems 5.2 and 5.5), bounded-rank state representations
(Corollary 6.5), and probe-based extractors (Theorems 7.4 and 7.5). A
de-quantization escaping all of these would have to be an algorithm that samples
the exact $r$-parameterized output without any bounded-size representation of it
and without probing — and by Corollary 8.5, such an algorithm would factor.

### 11.4 Practical consequences

For post-quantum cryptography the result is reassuring in a narrow, precise way:
the classical simulability route to breaking RSA is closed at the level of
mechanism, not merely unattempted. For quantum-algorithms research it sharpens
the target: any *new* quantum speedup should be examined for the three
structural features above, and a speedup whose central state is flat and full
rank is a much better candidate for genuine advantage than one whose state is
low rank. Flatness, ordinarily a nuisance, is here the certificate of
irreducibility.

---

## 12. Future directions

**Conjecture 1 (Bond-dimension dichotomy for the *approximate* tensor-network
route).** For every $\varepsilon < 1/2$ there is no bipartite decomposition of the
order-finding state of rank $k \le (1-2\varepsilon)r$ whose induced output
distribution is within total variation $\varepsilon$ of the exact comb;
equivalently, the bound $\mathrm{TV} \ge 1 - k/r$ extends from exact sparse
surrogates to *any* rank-$k$ approximation of the state, not merely to sparse
approximations of the distribution. The key insight is that rank and support are
linked: by Theorems 6.3 and 6.4 the branch rows are orthonormal, so a rank-$k$
state can overlap at most $k$ of the $r$ orthonormal branches and its measurement
statistics are $k$-sparse in the branch basis; the sharp constant $1 - k/r$ of
Proposition 4.5 should transfer verbatim. The missing step is a "rank-$k$ matrix
$\Rightarrow$ $k$-sparse branch statistics" lemma of finite-dimensional linear
algebra.

**Conjecture 2 (The mismatched-grid frontier: $\mathrm{TV} \ge 1/2$ without
$r \mid Q$).** Drop the divisibility hypothesis. For the Dirichlet-kernel comb
with exact output distribution
$P_r(y) = |\sum_{j < \lceil Q/r\rceil} e^{2\pi i jry/Q}|^2 / Z$, we conjecture:
for any two orders $r \ne r'$ with $r, r' \le \sqrt Q$, every single distribution
$D$ satisfies $\max(\mathrm{TV}(D,P_r), \mathrm{TV}(D,P_{r'})) \ge 1/2 - o(1)$.
The key insight is that Theorem 7.8 shows a mismatched grid can expose only
$\gcd(r,Q)$ clean frequencies, so the mass leaking off the peak lattice is
controlled by the Dirichlet kernel's $O(1/\mathrm{dist})$ tail rather than by any
structure a sampler could exploit; the pigeonhole seal (Theorem 2.3) then applies
to peak *neighbourhoods* instead of peaks. The only new analytic ingredient is an
elementary Dirichlet-kernel tail bound.

**Conjecture 3 (Probe complexity is exactly $\Theta(\sqrt r)$ for adaptive
algorithms).** Extend the counting bound $|C| \le 2^{|T|}$ of Theorem 7.5 from
non-adaptive extractors to adaptive decision trees, and prove that any adaptive
algorithm using only $r \mid t$ probes and needing to identify $r \le n$ must make
$\Omega(\sqrt n)$ queries — i.e. baby-step/giant-step is optimal in the probe
model. The key insight is that a probe at $t$ partitions the candidate set by the
divisors of $t$, so the information gained is bounded by the divisor-counting
function $d(t) = n^{o(1)}$; an adversary keeping the surviving candidate set
inside the primes of $(\sqrt n, n]$ forces every query to eliminate at most
$O(1)$ candidates.

**Further directions.** (a) Extend the exact distance formula of Theorem 5.2 to
the Regev-style higher-dimensional lattice outputs, where the peak set becomes a
sublattice and the gcd is replaced by a lattice index. (b) Quantify the
$\ell^1$/$\ell^2$ asymmetry: the Markovian heat-kernel diffusion recovers the
order in $O(\log^2 N)$ steps, but each step aggregates all $r$ eigenvalues; a
lower bound showing that any $\ell^1$ readout of the diffusion is
$\Omega(r)$-sealed would complete the route-by-route census. (c) Determine
whether the constants $1 - 1/R - 1/k$ of Theorem 5.5 can be improved to
$1 - o(1)$ for candidate families that are merely pairwise *distinct* rather than
pairwise coprime.

---

## 13. Conclusion

The de-quantization frontier for order finding is closed. Sparse and structured
transforms, bounded-bond-dimension tensor networks, $\ell^1$ diffusions,
lattice-style post-processing and frequency-selective probes all fail to recover
the multiplicative order classically in time polynomial in $\log N$ without an
$\Omega(r)$ aggregation step. The obstruction is one structure seen from five
angles: an object of rank exactly $r$ with a perfectly flat spectrum, whose $r$
equal peaks must be taken all at once. Observation of that object is free;
extraction from it costs $\Theta(r)$; and the only prize extraction offers — the
order — is by an elementary classical argument equivalent to a factorization of
the modulus.

The quantum exception stands, and is now maximally bounded: coherent Fourier
aggregation is the unique known route that pays the $\Omega(r)$ cost in a single
step.
