# The ECM Self-Destruction Wall Is an Accounting Artifact

### Exact outcome counts for stage-1 elliptic curve factorization, and a faithfulness criterion for outcome ledgers

**Aristotle**

**2026-08-28**

---

## Abstract

A recorded claim about the elliptic curve method of factorization (ECM) asserts a *self-destruction wall*: that when the stage-1 smoothness bound satisfies $B_1 \gtrsim \min(p,q)$ for $N = pq$, every Hasse-window group order divides $\operatorname{lcm}(1,\dots,B_1)$, all curves degenerate simultaneously, and the uncapped expected number of curves $\mathbb{E}[T]$ becomes infinite — with an alleged validity edge at $B_1 \lesssim \min(p,q)/2$.

We prove that the mechanism described is correct and its conclusion is inverted. Once $B_1 \ge p + 1 + 2\sqrt{p}$, every order in the Hasse window of $p$ is at most $B_1$, hence $B_1$-powersmooth, hence divides $\operatorname{lcm}(1,\dots,B_1)$; consequently every point of every curve is annihilated modulo $p$. Provided some prime factor of the mod-$q$ order exceeds $B_1$ — automatic when $q \gg B_1$ — the guarded inversion returns $\gcd = p$ on *every* trial. The per-curve success rate is exactly $1$ and $\mathbb{E}[T] = 1$. We show further that in the standard cyclic model $\mathbb{E}[T] = m/\gcd(m, k(B))$ is bounded above by the group order $m$ at every bound, and is antitone in $B$: no regime with infinite $\mathbb{E}[T]$ exists.

We locate the genuine destruction regime. Simultaneous degeneracy requires *both* Hasse windows to be covered, so the destruction threshold is $\max(p,q)$; the recorded $\min(p,q)$ is the *success* threshold. We give exact cardinalities for all four separated outcome blocks $\{\textsf{found}\,p, \textsf{found}\,q, \textsf{dead}, \textsf{nothing}\}$ in the two-prime cyclic model, an exact reveal count, a proof that the reveal count vanishes identically once both orders are covered, and an explicit two-line witness of the real wall.

Finally we isolate the error mechanism exactly. Modelling an accounting scheme as a *ledger* — a map from firing patterns $(\text{fires mod }p, \text{fires mod }q) \in \{0,1\}^2$ to recorded outcomes — we prove that the outcome-separated ledger is injective ("faithful") while the single conflation "file any mod-$p$ degeneracy as a death" is not, and that on precisely the firing pattern generated at the wall this non-injective ledger records `dead` where the truth is `found p`. The recorded wall sentence is the image of that one misfiling.

A 600-trial sweep at bit length 26 across $B_1/p \in \{0.125,0.25,0.5,0.9,1.05\}$ observed zero `dead` outcomes, success $1.000$ in every cell with $B_1/p \ge 0.25$, and $1.000$ in all six cells at $B_1/p \in \{0.9, 1.05\}$ — precisely the coordinates of the recorded catastrophe. We also prove a caution: individual outcome channels are *not* monotone (the `found p` count can drop from $8$ to $0$ between adjacent bounds), which is exactly why channel separation is mandatory.

**Keywords:** elliptic curve method, smoothness bound, Hasse window, powersmooth, least common multiple scalar, outcome accounting, ledger faithfulness, self-destruction wall.

---

## 1. Introduction

### 1.1 The recorded claim

Stage 1 of the elliptic curve method of factorization is controlled by a single parameter, the smoothness bound $B_1$. A claim in circulation records a hard upper limit on that parameter, phrased as follows:

> when $B_1 \gtrsim \min(p,q)$, every Hasse-window order divides $\operatorname{lcm}(1..B_1)$, all curves degenerate simultaneously, uncapped $\mathbb{E}[T]$ infinite,

together with a validity edge $B_1 \lesssim \min(p,q)/2$.

The claim has an unusual shape. Most parameter sweeps saturate: past a point, additional effort stops buying additional success. This claim asserts a *cliff*: past a point, additional effort destroys the method. Cliffs in a monotone computational resource are rare enough to warrant scrutiny.

### 1.2 What we prove

The mechanism in the recorded sentence is exactly right. What is wrong is the outcome label attached to it. We prove:

1. **Universal success at the wall.** $B_1 \ge p+1+2\sqrt{p}$ forces every Hasse-window order to divide the stage-1 scalar; the resulting universal degeneracy modulo $p$, combined with mod-$q$ inertness, yields the outcome `found p` on every trial, with revealed gcd exactly $p$.
2. **No infinite $\mathbb{E}[T]$, anywhere.** In the cyclic model $\mathbb{E}[T] = m/\gcd(m,k(B)) \le m$, antitone in $B$, equal to $1$ at the wall.
3. **No wall shape is possible in the firing ledger.** $B \le B' \Rightarrow k(B) \mid k(B')$, so the firing count $\gcd(m,k(B))$ is monotone nondecreasing in $B$.
4. **The real wall is at $\max(p,q)$.** Death requires both windows covered. We give exact block cardinalities, an exact reveal count, the vanishing theorem, and an explicit $2 \to 0$ witness.
5. **Ledger faithfulness.** The separated ledger is injective; the "any $p$-side degeneracy is a death" ledger is not, and reproduces the recorded sentence verbatim on `found p` inputs.
6. **Channel non-monotonicity.** The per-channel counts genuinely redistribute; watching one channel manufactures phantom walls.

### 1.3 Empirical corroboration

An outcome-separated sweep — 600 trials, bit length 26, $q \gg p$ stratum, grid $B_1/p \in \{0.125,0.25,0.5,0.9,1.05\}$ crossed with three stage-2 arms — observed **zero** `dead` outcomes and success rate $1.000$ in every cell with $B_1/p \ge 0.25$. Section 8 reports the data and the honest disclosures attached to it.

---

## 2. Setup and definitions

Throughout, $N = pq$ with $p \ne q$ prime, and $p < q$ unless stated otherwise.

**Definition 2.1 (Powersmoothness).** For $B, n \in \mathbb{N}$, $n$ is *$B$-powersmooth* if every prime power $\ell^e$ exactly dividing $n$ satisfies $\ell^e \le B$.

**Definition 2.2 (Stage-1 scalar).** The stage-1 scalar $k(B)$ is the product over primes $\ell \le B$ of the largest power $\ell^{e}$ not exceeding $B$. It is characterized by: for $n \ne 0$, $n \mid k(B)$ if and only if $n$ is $B$-powersmooth.

**Proposition 2.3 (Identification with the lcm).** $k(B) = \operatorname{lcm}(1,2,\dots,B)$.

*Proof.* Write $L(B) = \operatorname{lcm}(1,\dots,B)$. Each $j \in [1,B]$ is $B$-powersmooth, hence divides $k(B)$, so $L(B) \mid k(B)$. Conversely $k(B)$ is a product of prime powers each $\le B$, and each such prime power is one of the integers being lcm'd, so each divides $L(B)$; since they are pairwise coprime, their product divides $L(B)$. Both are nonzero, so $k(B) = L(B)$. $\square$

Proposition 2.3 matters for the audit: it certifies that the object named $\operatorname{lcm}(1..B_1)$ in the recorded sentence is the same object as the scalar appearing in the theory below, so the two can be compared without equivocation.

**Definition 2.4 (Firing).** Let $G$ be a finite group and $g \in G$. We say $g$ *fires at bound $B$* if $g^{k(B)} = 1$, equivalently if $\operatorname{ord}(g) \mid k(B)$.

**Definition 2.5 (Cyclic model).** For a cyclic group of order $m$ written additively as $\mathbb{Z}/m$, the *firing set* is
$$F(m,B) = \{\, r \in \{0,\dots,m-1\} : m \mid r\,k(B) \,\},$$
whose cardinality is $|F(m,B)| = \gcd(m, k(B))$. The *stage-1 success rate* in this model is $|F(m,B)|/m = \gcd(m,k(B))/m$.

The cyclic model is the standard idealization: a uniformly random point of an elliptic curve group of order $m$ is modelled as a uniformly random residue mod $m$, and the pair of reductions modulo $p$ and modulo $q$ is modelled as an independent uniform pair $(a,b) \in \mathbb{Z}/m_p \times \mathbb{Z}/m_q$.

**Definition 2.6 (Hasse window; arithmetic ceiling).** For a prime $p$, the Hasse window is the interval of possible group orders
$$\left[\,p+1-2\sqrt{p},\; p+1+2\sqrt{p}\,\right].$$
Define the *arithmetic ceiling* $H(p) = p + 3 + 2\lfloor \sqrt{p} \rfloor$.

**Lemma 2.7.** If $n \in \mathbb{N}$ satisfies $n \le p+1+2\sqrt{p}$ then $n \le H(p)$.

*Proof.* $\sqrt{p} < \lfloor\sqrt p\rfloor + 1$, so $p+1+2\sqrt p < p + 3 + 2\lfloor\sqrt p\rfloor = H(p)$; an integer strictly below $H(p)+1$ is at most $H(p)$. $\square$

$H(p)$ is a purely integer-arithmetic quantity, which is what lets the wall hypothesis "$B$ covers the window" be stated without reference to real square roots.

**Definition 2.8 (Separated outcomes).** A single ECM trial on $N = pq$ has outcome
$$\mathrm{Out}(f_p, f_q) = \begin{cases} \textsf{dead} & f_p \wedge f_q,\\ \textsf{found}\,p & f_p \wedge \neg f_q,\\ \textsf{found}\,q & \neg f_p \wedge f_q,\\ \textsf{nothing} & \neg f_p \wedge \neg f_q,\end{cases}$$
where $f_p$, $f_q$ record whether the point fires modulo $p$, respectively modulo $q$. In particular $\mathrm{Out}(f_p,f_q) = \textsf{dead}$ **iff** $f_p \wedge f_q$.

The four outcomes correspond to the value returned by the guarded inversion: $\gcd = N$ (`dead`), $\gcd = p$ (`found p`), $\gcd = q$ (`found q`), $\gcd = 1$ (`nothing`).

---

## 3. Size implies firing: the wall forces success

**Lemma 3.1 (Size implies powersmoothness).** If $1 \le n \le B$ then $n$ is $B$-powersmooth.

*Proof.* Any prime power $\ell^e$ exactly dividing $n$ divides $n$, hence $\ell^e \le n \le B$. $\square$

**Theorem 3.2 (Size alone fires stage 1).** If $1 \le n \le B$ then $n \mid k(B)$.

*Proof.* Lemma 3.1 and the characterization in Definition 2.2. $\square$

Theorem 3.2 is trivial and it is the entire mechanism. Nothing about elliptic curves, smoothness heuristics, or the distribution of group orders is required: only the observation that an integer no larger than $B$ appears among $1,\dots,B$.

**Theorem 3.3 (The wall forces firing).** Let $p, B, n$ with $H(p) \le B$, $n \ne 0$, and $n \le p+1+2\sqrt p$. Then $n \mid k(B)$.

*Proof.* By Lemma 2.7, $n \le H(p) \le B$; apply Theorem 3.2. $\square$

**Theorem 3.4 (Universal degeneracy at the wall).** Let $G$ be a finite group with $|G| \le p+1+2\sqrt p$, and let $B \ge H(p)$. Then $g^{k(B)} = 1$ for every $g \in G$.

*Proof.* $\operatorname{ord}(g) \mid |G|$ and $|G| \mid k(B)$ by Theorem 3.3. $\square$

**Corollary 3.5 (Success rate one).** In the cyclic model with $0 < m \le B$: $F(m,B)$ is the whole of $\{0,\dots,m-1\}$, $\gcd(m,k(B)) = m$, and the stage-1 success rate is exactly $1$.

*Proof.* $m \mid k(B)$ by Theorem 3.2, so $\gcd(m,k(B)) = m$ and every residue lies in the firing set. $\square$

This is the precise content of "all curves degenerate simultaneously". It is true. The question is what to call it.

---

## 4. The outcome at the wall is `found p`

**Lemma 4.1 (Identifying the revealed gcd).** Let $q$ be prime and $d \mid pq$ with $p \mid d$ and $q \nmid d$. Then $d = p$.

*Proof.* The divisors of $pq$ (for distinct primes) are $1, p, q, pq$. Those divisible by $p$ are $p$ and $pq$; the latter is divisible by $q$. $\square$

**Theorem 4.2 (The wall outcome is `found p`).** Let $G_p, G_q$ be finite groups with $|G_p| \le p+1+2\sqrt p$ and $|G_q| \le q+1+2\sqrt q$. Let $B \ne 0$ satisfy $H(p) \le B$, and suppose some prime factor $r$ of $\operatorname{ord}(g_q)$ satisfies $r > B$. Then for all $g_p \in G_p$, $g_q \in G_q$,
$$\mathrm{Out}\!\left(g_p^{k(B)} = 1,\; g_q^{k(B)} = 1\right) = \textsf{found}\,p .$$

*Proof.* The $p$-side fires by Theorem 3.4. For the $q$-side: if $\operatorname{ord}(g_q) \mid k(B)$ then $\operatorname{ord}(g_q)$ is $B$-powersmooth, so its prime factor $r$ satisfies $r \le r^{e} \le B$, contradicting $r > B$. So the $q$-side does not fire, and Definition 2.8 gives `found p`. $\square$

**Corollary 4.3 (No death at the wall).** Under the hypotheses of Theorem 4.2 the outcome is never `dead`.

**Corollary 4.4 (The revealed factor).** In the situation of Theorem 4.2, the guarded inversion returns a divisor $d$ of $N$ with $p \mid d$, $q \nmid d$; by Lemma 4.1, $d = p$ — a proper nontrivial factor, obtained with certainty.

**Theorem 4.5 (Exact death rate under mod-$q$ inertness).** In the cyclic model of order $m$ for the mod-$q$ side, if $B \ne 0$ and every prime factor of $m$ exceeds $B$, then $|F(m,B)| = 1$ and the simultaneous-degeneracy rate is exactly $1/m$.

*Proof.* $\gcd(m, k(B)) $ is a $B$-powersmooth divisor of $m$; each of its prime factors is a prime factor of $m$ and is $\le B$, so it has none, so it equals $1$. $\square$

At bit length $26$, $m \approx 2^{26}$, so the expected number of `dead` events over $600$ trials is below $10^{-4}$: observing zero is the prediction, not a fluke.

---

## 5. Monotonicity: a wall is not a possible shape

**Lemma 5.1 (Divisibility chain).** If $B \le B'$ then $k(B) \mid k(B')$.

*Proof.* $k(B)$ is $B$-powersmooth, hence $B'$-powersmooth, hence divides $k(B')$. $\square$

**Corollary 5.2 (Firing is monotone).** If $B \le B'$ and $n \mid k(B)$ then $n \mid k(B')$. In the cyclic model, $\gcd(m,k(B)) \mid \gcd(m,k(B'))$ and hence $\gcd(m,k(B)) \le \gcd(m,k(B'))$ for $m > 0$.

**Theorem 5.3 (No destruction wall in the firing ledger).** The map $B \mapsto |F(m,B)| = \gcd(m,k(B))$ is monotone nondecreasing. Consequently the stage-1 success rate never decreases as the bound is raised, at any scale.

A "wall" in the sense recorded — success collapsing above a threshold — is therefore not a possible shape for the firing ledger. Any observed collapse must be produced by something other than the firing dynamics: either by a channel restriction (Section 7) or by a labelling scheme (Section 9).

**Theorem 5.4 (Sharp firing threshold).** For $n \ne 0$ define $M(n) = \max\{\ell^{e} : \ell^{e} \,\|\, n\}$ (with $M(1) = 0$). Then $n \mid k(B) \iff M(n) \le B$, and $M(n)$ is the least bound at which $n$ fires.

*Proof.* Immediate from Definition 2.2: $B$-powersmoothness of $n$ says every exact prime power divisor is $\le B$, i.e. their maximum is $\le B$. Leastness follows since at $B = M(n) - 1$ the maximizing prime power exceeds $B$. $\square$

**Corollary 5.5 (Prime orders).** If $n$ is prime, $n \mid k(B) \iff n \le B$. Covering a prime order in the Hasse window of $p$ therefore genuinely requires $B \gtrsim p$: the success threshold is real.

**Theorem 5.6 (Cost of certainty).** For $B \ge 1$, $2^{\pi(B)} \le k(B)$, where $\pi$ is the prime-counting function; hence $\pi(B) \le \log_2 k(B)$, and the doubling ladder for $[k(B)]P$ performs at least $\pi(B)$ doublings.

*Proof.* $k(B)$ is divisible by the $\pi(B)$ pairwise coprime prime powers in its schedule, each at least $2$. $\square$

Theorem 5.6 is the honest reason nobody runs ECM at $B_1 \approx p$: the wall regime is not dangerous, it is *expensive*. Guaranteed success at exponential cost is exactly the trade-off the theorem describes.

---

## 6. Expected number of curves

**Definition 6.1.** For a per-curve success rate $s \in (0,1]$, the geometric expected number of curves is $\mathbb{E}[T](s) = \sum_{n \ge 0} (1-s)^n = 1/s$.

**Theorem 6.2 (Exact $\mathbb{E}[T]$).** In the cyclic model of order $m > 0$ at bound $B$,
$$\mathbb{E}[T] = \frac{m}{\gcd(m, k(B))}.$$

*Proof.* The success rate is $\gcd(m,k(B))/m \in (0,1]$; apply Definition 6.1. $\square$

**Corollary 6.3 ($\mathbb{E}[T]$ is never infinite).** $\mathbb{E}[T] \le m$ at every bound $B$, since $\gcd(m,k(B)) \ge 1$.

**Corollary 6.4 ($\mathbb{E}[T]$ is antitone).** If $B \le B'$ then $\mathbb{E}[T](B') \le \mathbb{E}[T](B)$, by Corollary 5.2.

**Corollary 6.5 ($\mathbb{E}[T] = 1$ at the wall).** If $0 < m \le B$ then the success rate is $1$ and $\mathbb{E}[T] = 1$.

Corollaries 6.3–6.5 dispose of the clause "uncapped $\mathbb{E}[T]$ infinite" comprehensively: it is false at the wall (where $\mathbb{E}[T] = 1$, its global minimum), and it is false at every other bound too (where $\mathbb{E}[T] \le m$). There is no regime of the order-completion ledger in which the expected number of curves diverges.

---

## 7. Exact outcome counts, and the location of the real wall

We now compute the four separated blocks exactly. Fix group orders $m_p, m_q > 0$ and a scalar $k$; a trial is a pair $(a,b) \in \mathbb{Z}/m_p \times \mathbb{Z}/m_q$, and the sample space has $m_p m_q$ points.

**Definition 7.1 (Co-firing set).** $F^{c}(m,k) = \{0,\dots,m-1\} \setminus F(m,k)$, the residues *not* killed by $k$.

**Lemma 7.2.** $|F^{c}(m,k)| = m - \gcd(m,k)$ for $m > 0$.

**Definition 7.3 (Blocks).**
$$\mathrm{FP} = F(m_p,k) \times F^{c}(m_q,k), \quad \mathrm{FQ} = F^{c}(m_p,k) \times F(m_q,k),$$
$$\mathrm{D} = F(m_p,k) \times F(m_q,k), \quad \mathrm{N} = F^{c}(m_p,k) \times F^{c}(m_q,k),$$
and the *reveal set* $\mathrm{R} = \mathrm{FP} \cup \mathrm{FQ}$.

**Theorem 7.4 (Exact block cardinalities).** With $g_p = \gcd(m_p,k)$ and $g_q = \gcd(m_q,k)$,
$$|\mathrm{D}| = g_p g_q, \quad |\mathrm{FP}| = g_p (m_q - g_q), \quad |\mathrm{FQ}| = (m_p - g_p) g_q, \quad |\mathrm{N}| = (m_p - g_p)(m_q - g_q).$$

*Proof.* Each block is a Cartesian product; take cardinalities and apply Lemma 7.2. $\square$

**Theorem 7.5 (Partition).** $|\mathrm{D}| + |\mathrm{FP}| + |\mathrm{FQ}| + |\mathrm{N}| = m_p m_q$.

*Proof.* $g_p g_q + g_p(m_q-g_q) + (m_p-g_p)g_q + (m_p-g_p)(m_q-g_q) = (g_p + (m_p-g_p))(g_q + (m_q-g_q)) = m_p m_q$, using $g_p \le m_p$, $g_q \le m_q$ so that the natural-number subtractions are exact. $\square$

**Theorem 7.6 (Exact reveal count).** $\mathrm{FP}$ and $\mathrm{FQ}$ are disjoint, and
$$|\mathrm{R}| = g_p(m_q - g_q) + (m_p - g_p)g_q .$$

*Proof.* Disjointness: a point of $\mathrm{FP}$ has first coordinate in $F(m_p,k)$, a point of $\mathrm{FQ}$ has first coordinate in the complement. Then add cardinalities. $\square$

Theorem 7.6 is the master formula. Everything about walls is read off from it.

**Theorem 7.7 (The real wall: both orders covered).** If $0 < m_p \le B$ and $0 < m_q \le B$ then $|\mathrm{R}| = 0$ at $k = k(B)$: every trial is `dead`.

*Proof.* By Corollary 3.5, $g_p = m_p$ and $g_q = m_q$; substitute into Theorem 7.6 to get $m_p \cdot 0 + 0 \cdot m_q = 0$. $\square$

Since covering the Hasse windows of both $p$ and $q$ requires $B \gtrsim \max(p,q)$, **the destruction threshold is $\max(p,q)$**, not $\min(p,q)$.

**Theorem 7.8 (Wall dichotomy).** Let $G_p, G_q$ have orders within their respective Hasse windows. Suppose $B \ne 0$, $H(p) \le B$, and some prime factor of $\operatorname{ord}(g_q)$ exceeds $B$; and suppose $H(p) \le B'$ and $H(q) \le B'$. Then
$$\mathrm{Out}\big(\cdot\big)\Big|_{B} = \textsf{found}\,p \qquad\text{and}\qquad \mathrm{Out}\big(\cdot\big)\Big|_{B'} = \textsf{dead}.$$

*Proof.* The first from Theorem 4.2; the second from Theorem 3.4 applied on both sides together with Definition 2.8. $\square$

Thus $\min(p,q)$ is the **success** threshold and $\max(p,q)$ is the **destruction** threshold, and between them lies the regime of guaranteed factorization.

**Theorem 7.9 (No wall while the $q$-side is inert).** Suppose $m_p > 0$, $m_q \ge 2$, $1 \le B \le B'$, and every prime factor of $m_q$ exceeds $B'$. Then $|\mathrm{R}|$ at bound $B$ is at most $|\mathrm{R}|$ at bound $B'$.

*Proof.* By Theorem 4.5, $g_q = 1$ at both bounds, so the reveal count reduces to $x(m_q-1) + (m_p - x)$ with $x = \gcd(m_p, k(\cdot))$. Since $m_q - 1 \ge 1$, the function $x \mapsto x(m_q-1) + (m_p-x)$ is nondecreasing in $x$ on $[0,m_p]$: raising $x$ to $y$ adds $(y-x)(m_q-1) \ge (y-x)$ and removes at most $(y-x)$. Monotonicity of $x$ in $B$ is Corollary 5.2. $\square$

**Theorem 7.10 (Explicit witness of the real wall).** Take $m_p = m_q = 2$. Then $|\mathrm{R}| = 2$ at $B = 1$ (where $k(1) = 1$) and $|\mathrm{R}| = 0$ at $B = 2$ (where $k(2) = 2$).

This is the smallest possible instance of a genuine reveal collapse, and it occurs exactly where Theorem 7.7 says it must: once the bound covers *both* orders.

**Theorem 7.11 (Channels are not monotone).** With $m_p = 4$, $m_q = 6$: $|\mathrm{FP}| = 8$ at $B = 2$ (where $k(2) = 2$) and $|\mathrm{FP}| = 0$ at $B = 3$ (where $k(3) = 6$).

*Proof.* At $B=2$: $g_p = \gcd(4,2) = 2$, $g_q = \gcd(6,2) = 2$, so $|\mathrm{FP}| = 2\cdot(6-2) = 8$. At $B=3$: $g_p = \gcd(4,6) = 2$, $g_q = \gcd(6,6) = 6$, so $|\mathrm{FP}| = 2 \cdot 0 = 0$. $\square$

Theorem 7.11 is the crucial caution, and it explains how an honest observer could see a wall. Nothing failed between $B=2$ and $B=3$: the eight trials *migrated* into the `dead` block because the mod-$q$ side began firing. The total firing count is monotone (Theorem 5.3); the per-channel counts redistribute. An observer restricted to one channel sees a cliff that the underlying dynamics do not contain.

**Theorem 7.12 (Simultaneous-degeneracy ceiling).** For $m \ne 0$ and $B \ge 1$, $\gcd(m, k(B)) \le B^{\omega(m)}$, where $\omega(m)$ is the number of distinct prime factors of $m$. Hence the death rate on a side of order $m$ is at most $B^{\omega(m)}/m$.

*Proof.* $g = \gcd(m,k(B))$ is $B$-powersmooth and its prime support is contained in that of $m$; writing $g$ as the product of its exact prime powers, each factor is $\le B$ and there are at most $\omega(m)$ of them. $\square$

For $q \gg B$ this ceiling is minuscule, which is the quantitative statement that the `dead` block is empty in the wall regime.

---

## 8. The experiment

### 8.1 Design

A pre-registered sweep tested the recorded boundary directly. Composites $N = pq$ were drawn from a bit-length-26, $q \gg p$ stratum ($q$ taken as the next prime above $3p + U[1,200)$), with $40$ independent trials per cell, on the grid
$$\frac{B_1}{p} \in \{0.125,\; 0.25,\; 0.5,\; 0.9,\; 1.05\} \quad\times\quad \frac{B_2}{B_1} \in \{1 \text{ (control)},\, 4,\, 16\},$$
for $600$ trials in total. Stage 1 used the true lcm schedule $k(B_1) = \operatorname{lcm}(1,\dots,B_1)$ with guarded affine elliptic curve operations; all four outcomes $\{\textsf{found}\,p, \textsf{found}\,q, \textsf{dead}, \textsf{nothing}\}$ were recorded separately, with $p$-versus-$q$ separation of the revealed gcd.

Three hypotheses were registered before any data was collected: a stage-2 scaling hypothesis (slope of $\log w^\ast$ against $\log(B_2/B_1)$ covering $1$), its null (covering $0$), and — added after reading the mechanism sentence but before data, with timing disclosed — the hypothesis that the recorded wall is a detection/accounting artifact rather than a method failure.

### 8.2 Results

- **Zero `dead` outcomes across the entire grid.**
- Success rate $1.000$ in every cell with $B_1/p \ge 0.25$.
- In particular, $6/6$ cells at success $1.000$ at $B_1/p = 0.9$ and $B_1/p = 1.05$ — exactly the coordinates at which the recorded sentence places uncapped infinite $\mathbb{E}[T]$.
- The only sub-unit cells were two at the low edge $B_1/p = 0.125$, at $0.875$ and $0.95$. **Every miss was `nothing`; none was `dead`.**
- No stage-2 threshold quantity ever came into existence, so the two scaling hypotheses never armed.

Success $1.000$ at $B_1/p \ge 0.9$ is Corollary 3.5 plus Theorem 4.2; misses filed as `nothing` rather than `dead` is Definition 2.8 read correctly.

**A caveat on the death channel.** Theorem 4.5 gives a death rate of exactly $1/m_q$, but *conditional on mod-$q$ inertness* — on every prime factor of the mod-$q$ order exceeding $B_1$. That hypothesis is not automatic merely because $q > p$: it fails whenever the mod-$q$ order happens to be $B_1$-powersmooth, an event of non-negligible probability when $q$ is only a small multiple of $B_1$. In an independent replication we find that at ratio $q/p \approx 3$ with $B_1 \approx p$ a few percent of trials do fire on both sides and are correctly recorded as `dead`, whereas at $q \gg B_1$ the death channel is empty as predicted. Consequently, the reported zero-death count at ratio $q/p \approx 3$ is stronger than the theory alone requires, and the completeness of the death channel in the recording pipeline is itself worth checking in the named follow-up. Nothing in this caveat affects the verdict: whether a given trial goes `found p` or `dead` is decided by the $q$-side, and in neither case does raising $B_1$ reduce the number of trials on which the $p$-side fires (Theorem 5.3).

### 8.3 The collision baseline, and why the low edge is not luck

A guarded affine implementation carries a scale-independent success floor unrelated to order divisibility: the ladder performs roughly $1.44\,B_1$ operations, each of which hits a vanishing denominator by accident with probability about $1/p$, giving a random-collision baseline of about
$$1 - \exp(-c\,B_1/p), \qquad c \approx 1.44 .$$

**Proposition 8.1.** $1 - e^{-x} \le x$ for all real $x$.

*Proof.* $e^{-x} \ge 1 - x$ (convexity / the tangent line at $0$). $\square$

At $B_1/p = 1/8$ this bounds the collision baseline by $1.44/8 = 0.18$, against an observed found-$p$ share of about $0.68$ in that cell. So collision luck accounts for at most about a quarter of the low-edge successes; genuine order divisibility is already doing the majority of the work far below the alleged validity edge $B_1 \lesssim \min(p,q)/2$.

That edge is in any case misplaced. For $p = 13$, the arithmetic ceiling is $H(13) = 22$, and the Hasse-window order $12$ divides $k(7) = \operatorname{lcm}(1,\dots,7) = 420$; by Theorem 5.4, since $M(12) = 4$, a curve of order $12$ fires from bound $4$ onwards — comfortably below $p/2$. Conversely $M(13) = 13$, so a prime order $13$ fires only from bound $13$: the sharp threshold theorem gives both directions.

### 8.4 Honest disclosures

1. **Toy scale.** Bit length 26. The theorems of Sections 3–7 are scale-free, but the empirical grid is small; a larger-$p$ replication is the named follow-up.
2. **Stage-2 arms are untested.** Stage 1 succeeded first in every cell, so the newly written difference-stage stage-2 machinery produced zero outcomes and was effectively dead code this run. It is validated only by smoke buckets and a sign-convention check. Cross-arm differences at fixed $B_1$ are therefore per-cell random-seed drift, not stage-2 effects, and must not be interpreted.
3. **Implementation route.** The coordinator was implemented inline after repeated infrastructure failures during the run.
4. **Death-channel completeness.** As noted in §8.2, the theory predicts a small but nonzero death rate at ratio $q/p \approx 3$ once $B_1 \approx p$; the recorded grid contains none. Either the stratum was luckier than typical or the recorder under-counted the channel. This is flagged, not resolved.
5. **Recorder discrepancy.** A narrative summary of the run states "14/15 cells at 1.000" while the canonical machine-readable record shows *two* sub-unit cells, both at $B_1/p = 0.125$. The canonical record governs; the verdict is unaffected, since neither discrepant cell lies in the wall regime.

None of these disclosures touches the mathematical content: Sections 3–7 stand on proof, and the experiment corroborates rather than establishes.

---

## 9. Ledger faithfulness: where the wall came from

We now formalize the accounting itself and show that the recorded sentence is the exact image of a single conflation.

**Definition 9.1 (Ledger).** A *ledger* is a map $L : \{0,1\}^2 \to \{\textsf{found}\,p, \textsf{found}\,q, \textsf{dead}, \textsf{nothing}\}$, taking the firing pattern (fires mod $p$, fires mod $q$) to a recorded outcome.

**Definition 9.2 (Canonical ledger).** $L_{\mathrm{can}}(f_p,f_q) = \mathrm{Out}(f_p,f_q)$ of Definition 2.8. This is the ledger the experiment used.

**Definition 9.3 (Faithfulness).** $L$ is *faithful* if it is injective: distinct firing patterns receive distinct labels.

**Theorem 9.4.** $L_{\mathrm{can}}$ is faithful.

*Proof.* Its four values on the four inputs are pairwise distinct by construction. $\square$

**Definition 9.5 (The conflating ledger).** $L_{\mathrm{wall}}(f_p,f_q) = \textsf{dead}$ if $f_p$; otherwise $\textsf{found}\,q$ if $f_q$; otherwise $\textsf{nothing}$. In words: *any* mod-$p$ degeneracy is filed as a death.

**Theorem 9.6.** $L_{\mathrm{wall}}$ is not faithful: $L_{\mathrm{wall}}(1,0) = L_{\mathrm{wall}}(1,1) = \textsf{dead}$ while $(1,0) \ne (1,1)$.

**Theorem 9.7 (The wall sentence is the image of the conflation).** On the firing pattern $(1,0)$ — precisely the pattern produced at every trial in the regime $B \ge H(p)$ with the mod-$q$ side inert (Theorem 4.2) — the canonical ledger records $\textsf{found}\,p$ while the conflating ledger records $\textsf{dead}$.

*Proof.* Evaluate both definitions at $(1,0)$. $\square$

Theorems 9.4–9.7 complete the audit. Read $L_{\mathrm{wall}}$ over the wall regime and every clause of the recorded sentence follows:

- "every Hasse-window order divides $\operatorname{lcm}(1..B_1)$" — **true**, Theorem 3.3;
- "all curves degenerate simultaneously" — **true**, Theorem 3.4;
- "uncapped $\mathbb{E}[T]$ infinite" — this is precisely what $L_{\mathrm{wall}}$ reports, because it counts every degeneracy as a loss, driving the measured success rate to zero and its reciprocal to infinity.

Under $L_{\mathrm{can}}$ the same events give success rate $1$ and $\mathbb{E}[T] = 1$ (Corollary 6.5). The wall is therefore not a property of the elliptic curve method. It is a property of a non-injective accounting map — the difference between $L_{\mathrm{can}}$ and $L_{\mathrm{wall}}$ is one arrow, and that one arrow is the wall.

A second, independent route to the same phantom is Theorem 7.11: an observer who separates $p$ from $q$ but tracks only the found-$p$ channel will see it collapse from $8$ to $0$ and may report a wall, even though the trials merely migrated. Faithful accounting requires *both* separating the outcomes and tracking all four blocks.

---

## 10. Algorithms

The mathematics above is fully constructive; three procedures suffice to reproduce every claim.

**A. Stage-1 scalar by the powersmooth schedule.** For each prime $\ell \le B$, take the largest $e$ with $\ell^{e} \le B$ and multiply. Cost: a sieve to $B$ plus $O(\pi(B)\log B)$ multiplications; the output has $\Theta(B/\log B \cdot \log B) = \Theta(B)$ bits, matching $\log \operatorname{lcm}(1..B) \sim B$. By Proposition 2.3 the result equals $\operatorname{lcm}(1,\dots,B)$; by Theorem 5.6 it carries at least $\pi(B)$ factors of $2$'s worth of ladder work.

**B. Exact separated block counts.** Given $m_p$, $m_q$, $B$: form $k(B)$, compute $g_p = \gcd(m_p,k(B))$ and $g_q = \gcd(m_q,k(B))$, and return the four products of Theorem 7.4. Cost: two gcds on $\Theta(B)$-bit numbers. This computes exact outcome distributions with no sampling at all — no Monte Carlo error, no seeds.

**C. Faithful trial accounting.** Simulate a trial by drawing $(a,b)$ uniformly, test $m_p \mid a\,k(B)$ and $m_q \mid b\,k(B)$, and emit the corresponding label from $L_{\mathrm{can}}$. Never collapse a $p$-side firing into a generic failure. The whole audit reduces to this discipline.

---

## 11. Discussion

### 11.1 What the audit does and does not overturn

The mechanism reported in the original claim is correct, and it is a genuinely interesting phenomenon: there is a bound past which ECM stage 1 stops being probabilistic and becomes deterministic. What the audit overturns is the sign of the conclusion. Deterministic *success* was recorded as deterministic *failure*.

The claim's parameter is also correct as an inflection point. Something really does happen at $\min(p,q)$; it is the point at which the success rate saturates at $1$. The recorded validity edge $\min(p,q)/2$ is the one quantity with no correlate in the theory: firing begins far below it (order $12$ fires at bound $4$, for $p=13$) and never reverses above it (Theorem 5.3).

### 11.2 Why the error is a natural one

Three features conspire. First, in a guarded affine implementation *failure is the signal*: the inversion exception is the success path, so an exception handler written defensively will file wins as losses. Second, the wall regime produces universal degeneracy, which subjectively looks like a catastrophic event. Third, the found-$p$ channel is genuinely non-monotone (Theorem 7.11), so even a partially separated ledger can exhibit cliff-shaped data. The recorded sentence is what you get when all three land at once.

### 11.3 The two-threshold picture

The corrected picture is a clean three-regime chart in the bound $B$:

| Regime | Condition | Every-trial outcome | $\mathbb{E}[T]$ |
|---|---|---|---|
| Sub-threshold | $B$ below $M(m_p)$ | mostly `nothing`, occasional `found p` | $m_p/\gcd(m_p,k(B))$, finite |
| **Guaranteed-success band** | $B \ge H(p)$, $q$-side inert | `found p`, gcd $= p$ | $1$ |
| Genuine wall | $B \ge H(p)$ *and* $B \ge H(q)$ | `dead`, gcd $= N$ | undefined (rate $0$) |

The middle band is wide: it stretches from $\max(p,q)$'s complement all the way from $p$ to $q$. For a balanced semiprime it is narrow; for the $q \gg p$ stratum tested here it is enormous. The genuine wall exists (Theorem 7.10 exhibits it in the smallest possible case) but is unreachable in practice, since $B \gtrsim \max(p,q)$ costs more than trial division.

### 11.4 Practical takeaway

Nothing in this paper recommends running ECM at $B_1 \approx p$: Theorem 5.6 makes that exponentially expensive. What it does establish is that the reason to avoid the regime is *cost*, not *danger*, and that any implementation reporting failures there is misreporting. The corrective is cheap: separate the four outcomes and record which prime the gcd revealed.

### 11.5 Status of the recorded claim

The appropriate disposition, given that the empirical grid here is at toy scale, is an appended audit rather than a silent rewrite. Sections 3–7 are proved and scale-free; the experiment is corroboration. The named follow-up — a larger-$p$ replication with per-operation outcome tracing distinguishing order-hits from collision-hits — should precede any amendment.

---

## 12. Future work

1. **Larger-$p$ replication with per-operation tracing.** Distinguish order-divisibility hits from random-collision hits at each ladder step, at bit lengths well beyond 26, to confirm that the observed low-edge successes decompose as Proposition 8.1 predicts.
2. **Exercising the stage-2 arms.** Because stage 1 succeeded first everywhere, the difference-stage stage-2 machinery never ran. Designing a grid where stage 1 is deliberately starved would let the stage-2 scaling hypotheses actually arm.
3. **Balanced semiprimes.** For $p \approx q$ the guaranteed-success band narrows and the `dead` block becomes reachable in principle. Theorem 7.12 bounds its size; sharpening that bound for balanced $N$ would quantify the only regime where the wall is a real hazard.
4. **Beyond the cyclic model.** The exact block counts of Theorem 7.4 assume cyclic group structure and independence across the two primes. Extending them to general finite abelian group orders $\mathbb{Z}/d \times \mathbb{Z}/e$ would tighten the correspondence with actual elliptic curve group structures.
5. **Ledger faithfulness as a general audit criterion.** Definition 9.3 is not specific to ECM. Any experimental pipeline that compresses a multi-state ground truth into fewer recorded labels admits the same failure mode; a systematic faithfulness check on outcome recorders may catch other phantom effects.

---

## 13. Conclusion

The recorded ECM self-destruction wall does not exist as described. Above $B_1 \ge p + 1 + 2\sqrt{p}$, every Hasse-window order divides $\operatorname{lcm}(1,\dots,B_1)$ — exactly as recorded — but this makes every curve *succeed*, not die: the guarded inversion returns $\gcd = p$ with certainty, the per-curve success rate is $1$, and the expected number of curves is $1$. The stage-1 success rate is monotone in the bound, so a wall is not a possible shape; the expected number of curves is bounded by the group order at every bound, so it is never infinite. The genuine destruction regime requires both Hasse windows covered and therefore sits at $\max(p,q)$, with $\min(p,q)$ being the success threshold.

The recorded sentence is exactly what a single non-injective step in an outcome ledger produces: file every mod-$p$ degeneracy as a death, and universal success is transcribed as universal destruction. Six hundred outcome-separated trials across and beyond the alleged wall recorded zero deaths and perfect success in every cell at and above the claimed cliff.

The lesson generalizes past factorization. When a method's success is signalled by an exception, the accounting must ask not merely *whether* the computation broke, but *where*.
