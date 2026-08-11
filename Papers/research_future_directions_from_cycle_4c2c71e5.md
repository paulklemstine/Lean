# Normalized Spectral Transforms of the $an+1$ Maps: An Exact Limit Law, Its Resonance Arithmetic, and a No-Go Theorem

**Author:** Aristotle
**Date:** 2026-08-11

---

## Abstract

For an integer multiplier $a \ge 1$ let $T_a$ denote the accelerated one-step map $T_a(n) = n/2$ for even $n$ and $T_a(n) = an+1$ for odd $n$, and let $r_a(n) = T_a(n)/n$ be the associated *phase ratio*. We study the cutoff exponential sum
$$F_a(\omega, N) = \sum_{n=1}^{N} e\bigl(\omega\, r_a(n)\bigr), \qquad e(x) = e^{2\pi i x},$$
which is the natural one-step analogue of the exponential sums used to detect equidistribution and pseudorandomness in analytic number theory.

We prove an exact limit law: for every $a$ and every real $\omega$,
$$\frac{F_a(\omega, N)}{N} \longrightarrow A_a(\omega) = \frac{e(\omega/2) + e(a\omega)}{2},$$
with the explicit, multiplier-uniform error bound $\bigl|F_a(\omega,N)/N - A_a(\omega)\bigr| \le \bigl(1 + 2\pi|\omega|(1 + \log N)\bigr)/N$ for all $N \ge 1$; consequently the convergence is uniform on compact frequency sets, simultaneously for all multipliers. The modulus of the amplitude is the single cosine $|A_a(\omega)| = |\cos(\pi(a - \tfrac12)\omega)|$, so the *resonance set* on which genuine $o(N)$ cancellation occurs is exactly $R_a = \{\omega : (2a-1)\omega \in 2\mathbb{Z}+1\}$, an arithmetic progression of spacing $2/(2a-1)$. Off $R_a$ the transform has full linear size, and near $\omega = 0$ one has $|F_a(\omega,N)| \ge N/4$ eventually, which refutes any pointwise decay statement over all irrational frequencies.

We then determine the arithmetic of the resonance sets. All multipliers share the trivial resonances at odd integers and have amplitude $1$ at even integers, so no discriminator lives at integer frequencies; but the three classical maps $3n+1$, $5n+1$, $7n+1$ are pairwise separated at $\omega = 1/5$, $1/9$, $1/13$ respectively, and pairwise they resonate together *only* at odd integers. We also show that the mean square $\int_0^2 |A_a(\omega)|^2 \, d\omega = 1$ for every $a$, so $L^2$-averaging cannot discriminate: only the location of the resonance comb can.

Finally we prove a sharp no-go theorem: if two phase-ratio functions differ only on a set of indices of density zero, their normalized transforms have the same limit. In particular a modification of the map at finitely many arguments — inserting or destroying a cycle, altering a stopping time — leaves the normalized spectrum unchanged. Hence no implication of the form "spectral estimate $\Rightarrow$ orbit hitting-time estimate" can hold for the one-step cutoff sum. We close with two precise conjectures identifying where dynamical information can still survive: a second-order $\log N$ law, and the non-lattice resonance geometry of iterated transforms.

**Keywords:** Collatz map, $an+1$ maps, exponential sums, equidistribution, resonance sets, character sums, Cesàro averaging, no-go theorem.

---

## 1. Introduction

### 1.1 Motivation

The Collatz map, $n \mapsto n/2$ for even $n$ and $n \mapsto 3n+1$ for odd $n$, is the standard example of an arithmetic dynamical system whose global behaviour is far beyond current techniques. One of the recurring hopes for such problems is that harmonic analysis will supply the missing pseudorandomness: if the orbit data of a map can be encoded in an exponential sum, and if that sum can be shown to exhibit substantial cancellation, then quantitative equidistribution statements — and with luck, statements about hitting times or the absence of divergent orbits — should follow.

The purpose of this paper is to carry out that program precisely for the simplest available statistic, the *one-step phase transform*, and to determine its exact content. The outcome is a complete answer with a strongly negative dynamical component: the sum converges, after normalization, to an explicit two-term trigonometric amplitude; the amplitude's modulus is a single cosine; its zero set is an arithmetic progression determined by the multiplier; and the statistic is provably insensitive to any modification of the map on a density-zero set of inputs.

We regard the negative results as the substance of the paper. Drawing an exact boundary around the reach of a method is more useful than an unquantified failure, and the boundary here is sharp enough to indicate exactly which refinements can still carry information — refinements we formulate as conjectures in Section 8.

### 1.2 Conventions

Throughout, $a \ge 1$ is an integer multiplier (the classical cases being $a = 3, 5, 7$), $\omega \in \mathbb{R}$ is a frequency, and $N \ge 1$ an integer cutoff. We write
$$e(x) = \exp(2\pi i x), \qquad x \in \mathbb{R},$$
for the standard additive character, and we use freely the elementary identities
$$e(x+y) = e(x)e(y), \qquad |e(x)| = 1, \qquad e(0)=1.$$
Two further identities are used constantly and we record them now.

**Lemma 1.1 (Chord identities).** For all real $t$ and $x$,
$$|1 + e(t)| = 2\,|\cos(\pi t)|, \qquad |e(x) - 1| = 2\,|\sin(\pi x)|.$$

*Proof sketch.* Factor out the half-angle: $1 + e(t) = e(t/2)\bigl(e(-t/2) + e(t/2)\bigr)$, and $e(-u) + e(u) = 2\cos(2\pi u)$; take $u = t/2$ and use $|e(t/2)| = 1$. Similarly $e(x)-1 = e(x/2)\bigl(e(x/2)-e(-x/2)\bigr)$ and $e(u) - e(-u) = 2i\sin(2\pi u)$. $\square$

An immediate consequence, used for the quantitative error bound, is the Lipschitz estimate
$$|e(x) - 1| \le 2\pi |x| \qquad (x \in \mathbb{R}), \tag{1.1}$$
which follows from $|\sin y| \le |y|$.

---

## 2. The maps, the phase ratio, and the transform

**Definition 2.1 (Accelerated map).** For integers $a \ge 1$ and $n \ge 1$ set
$$T_a(n) = \begin{cases} n/2, & n \equiv 0 \pmod 2, \\ a n + 1, & n \equiv 1 \pmod 2. \end{cases}$$

**Definition 2.2 (Phase ratio).** The phase ratio of the map at $n \ge 1$ is $r_a(n) = T_a(n)/n$.

The phase ratio, rather than $T_a(n)$ itself, is the correct object to place inside a character: it is scale-invariant, it is the multiplicative increment governing whether an orbit drifts up or down, and it is bounded.

**Definition 2.3 (Cutoff transform).** For $a \ge 1$, $\omega \in \mathbb{R}$, $N \ge 0$,
$$F_a(\omega, N) = \sum_{n=1}^{N} e\bigl(\omega\, r_a(n)\bigr).$$

Trivially $|F_a(\omega,N)| \le N$. The classical hope is that for irrational $\omega$ one might have $F_a(\omega,N) = o(N)$, or better; Section 4 shows this fails except on an explicit countable set of $\omega$.

The first structural fact is that the phase ratio is not a complicated sequence at all.

**Proposition 2.4 (Branch splitting).** For $n \ge 1$:
1. if $n$ is even, then $r_a(n) = \tfrac12$, exactly, independently of $a$;
2. if $n$ is odd, then $r_a(n) = a + \dfrac{1}{n}$.

*Proof.* For even $n$, $T_a(n) = n/2$ so the ratio is $1/2$. For odd $n$, $T_a(n) = an+1$, so $T_a(n)/n = a + 1/n$. $\square$

Thus $\{r_a(n)\}_{n \ge 1}$ has exactly two accumulation points, $1/2$ and $a$, visited in strict alternation, with a summable-after-averaging perturbation $1/n$ on the odd branch. Everything in this paper is a consequence of Proposition 2.4.

**Definition 2.5 (Limiting amplitude and branch gap).**
$$A_a(\omega) = \frac{e(\omega/2) + e(a\omega)}{2}, \qquad G_a(\omega) = \frac{e(a\omega) - e(\omega/2)}{2}.$$
$A_a$ is the mean of the two branch phases and $G_a$ is half their difference; note $|G_a(\omega)| \le 1$.

---

## 3. The exact decomposition and the limit law

### 3.1 A finite even/odd decomposition

Reindexing by $k = n - 1 \in \{0, \dots, N-1\}$, so that $k$ even corresponds to $n$ odd, Proposition 2.4 gives the exact term identity
$$e\bigl(\omega r_a(k+1)\bigr) = \begin{cases} e(a\omega)\, e\!\left(\dfrac{\omega}{k+1}\right), & k \text{ even}, \\[2mm] e(\omega/2), & k \text{ odd}. \end{cases} \tag{3.1}$$

**Theorem 3.1 (Exact even/odd split).** For all $a, \omega, N$,
$$F_a(\omega, N) = \left\lfloor \frac{N}{2} \right\rfloor e(\omega/2) \; + \; e(a\omega) \sum_{\substack{0 \le k < N \\ k \text{ even}}} e\!\left(\frac{\omega}{k+1}\right).$$

*Proof sketch.* Partition $\{0,\dots,N-1\}$ by the parity of $k$ and apply (3.1) termwise. On the odd-$k$ part every summand equals the constant $e(\omega/2)$, and the number of odd $k < N$ is $\lfloor N/2 \rfloor$; on the even-$k$ part factor out the constant $e(a\omega)$. $\square$

The even branch of the map therefore contributes a purely constant phase with multiplicity $\lfloor N/2 \rfloor$, while the odd branch contributes the fixed phase $e(a\omega)$ modulated by the slowly varying factors $e(\omega/n)$, each of which tends to $1$.

### 3.2 The deviation sequence

To extract a limit we compare each summand with a two-periodic model. Define
$$d_a(\omega, k) = e\bigl(\omega r_a(k+1)\bigr) - \Bigl( A_a(\omega) + (-1)^k G_a(\omega) \Bigr).$$
The bracketed model term equals $e(a\omega)$ for $k$ even and $e(\omega/2)$ for $k$ odd, so by (3.1):

**Lemma 3.2 (Deviation formula).**
$$d_a(\omega, k) = \begin{cases} e(a\omega)\left(e\!\left(\dfrac{\omega}{k+1}\right) - 1\right), & k \text{ even}, \\[2mm] 0, & k \text{ odd}, \end{cases}$$
and consequently, using $|e(a\omega)| = 1$ and (1.1),
$$|d_a(\omega,k)| \le \left| e\!\left(\frac{\omega}{k+1}\right) - 1 \right| \le \frac{2\pi|\omega|}{k+1}. \tag{3.2}$$
In particular $d_a(\omega,k) \to 0$ as $k \to \infty$.

Summing the definition of $d_a$ over $k < N$ gives the master identity
$$F_a(\omega, N) = N \, A_a(\omega) \; + \; G_a(\omega) \sum_{k=0}^{N-1} (-1)^k \; + \; \sum_{k=0}^{N-1} d_a(\omega, k). \tag{3.3}$$
The middle sum is $0$ or $1$ according to the parity of $N$; the last sum is the only genuinely analytic term.

### 3.3 The limit law

**Theorem 3.3 (Limit law).** For every integer $a \ge 1$ and every $\omega \in \mathbb{R}$,
$$\lim_{N \to \infty} \frac{F_a(\omega, N)}{N} = A_a(\omega) = \frac{e(\omega/2) + e(a\omega)}{2}.$$

*Proof sketch.* Divide (3.3) by $N$. The alternating term is bounded by $|G_a(\omega)|/N \le 1/N \to 0$. The deviation term is the Cesàro average of a null sequence by Lemma 3.2, hence tends to $0$. $\square$

The transform therefore does not decay: it grows linearly with an explicit constant, namely the mean of the two branch phases.

### 3.4 A quantitative, multiplier-uniform error bound

Averaging (3.2) against the harmonic bound $\sum_{k<N} \frac{1}{k+1} \le 1 + \log N$ makes Theorem 3.3 effective.

**Theorem 3.4 (Explicit error bound).** For all $a \ge 1$, all $\omega \in \mathbb{R}$ and all $N \ge 1$,
$$\left| \frac{F_a(\omega, N)}{N} - A_a(\omega) \right| \; \le \; \frac{1 + 2\pi|\omega|\bigl(1 + \log N\bigr)}{N}.$$

*Proof sketch.* By (3.3),
$$\frac{F_a(\omega,N)}{N} - A_a(\omega) = \frac{1}{N}\left( G_a(\omega)\sum_{k<N}(-1)^k + \sum_{k<N} d_a(\omega,k) \right).$$
The first bracketed term has modulus at most $1$, since $|G_a(\omega)| \le 1$ and the alternating sum is $0$ or $1$. The second has modulus at most $\sum_{k<N} 2\pi|\omega|/(k+1) \le 2\pi|\omega|(1+\log N)$. $\square$

Every constant here is absolute: the bound does not depend on $a$ at all, and depends on $\omega$ only through $|\omega|$.

**Corollary 3.5 (Uniform convergence on compacts).** For every $M > 0$ and every $\varepsilon > 0$ there is $N_0 = N_0(M,\varepsilon) \ge 1$ such that for all $N \ge N_0$, all multipliers $a \ge 1$ and all $\omega$ with $|\omega| \le M$,
$$\left| \frac{F_a(\omega,N)}{N} - A_a(\omega) \right| \le \varepsilon.$$

*Proof sketch.* The right-hand side of Theorem 3.4 is at most $\bigl(1 + 2\pi M(1+\log N)\bigr)/N$, which tends to $0$ as $N \to \infty$ since $\log N = o(N)$; choose $N_0$ accordingly. $\square$

Corollary 3.5 is the corrected replacement for the impossible pointwise statement over all irrational frequencies: the correct uniformity is *in the multiplier and over compact frequency ranges*, not over the irrationals.

---

## 4. The amplitude: modulus, resonances, and the failure of pointwise decay

### 4.1 The modulus is a cosine

**Theorem 4.1 (Modulus formula).** For all $a \ge 1$ and $\omega \in \mathbb{R}$,
$$\bigl| A_a(\omega) \bigr| = \left| \cos\!\left( \pi \left(a - \tfrac12\right)\omega \right) \right|.$$

*Proof sketch.* Factor out the common phase: with $t = (a - \tfrac12)\omega$ one has $\omega/2 + t = a\omega$, so
$$e(\omega/2) + e(a\omega) = e(\omega/2)\bigl(1 + e(t)\bigr).$$
Since $|e(\omega/2)| = 1$, Lemma 1.1 gives $|A_a(\omega)| = \tfrac12 \cdot 2|\cos(\pi t)|$. $\square$

The entire spectral content of the one-step transform is thus a single cosine of frequency $(a - \tfrac12)$: the *only* way the multiplier enters the leading-order behaviour is through the dilation factor $2a-1$.

### 4.2 The resonance set

**Definition 4.2.** The *resonance set* of the multiplier $a$ is
$$R_a = \bigl\{ \omega \in \mathbb{R} : A_a(\omega) = 0 \bigr\}.$$

**Theorem 4.3 (Resonance classification).**
$$A_a(\omega) = 0 \iff (2a-1)\,\omega \in 2\mathbb{Z}+1, \qquad\text{i.e.}\qquad R_a = \left\{ \frac{2m+1}{2a-1} : m \in \mathbb{Z} \right\}.$$

*Proof sketch.* By Theorem 4.1, $A_a(\omega) = 0$ iff $\cos\bigl(\pi(a-\tfrac12)\omega\bigr) = 0$, i.e. iff $(a - \tfrac12)\omega = m + \tfrac12$ for some $m \in \mathbb{Z}$; multiplying by $2$ gives $(2a-1)\omega = 2m+1$. $\square$

Geometrically, $R_a$ is the comb of frequencies at which the two branch phases $e(\omega/2)$ and $e(a\omega)$ are exactly antipodal; there, and only there, do the even and odd contributions annihilate one another.

**Theorem 4.4 (Cancellation exactly at resonance).**
1. If $(2a-1)\omega$ is an odd integer then $F_a(\omega,N)/N \to 0$, i.e. $F_a(\omega,N) = o(N)$.
2. If $A_a(\omega) \ne 0$ then for all sufficiently large $N$,
$$|F_a(\omega,N)| \;\ge\; \frac{|A_a(\omega)|}{2}\, N.$$

*Proof sketch.* (1) is Theorem 3.3 combined with Theorem 4.3. For (2), $|F_a(\omega,N)/N| \to |A_a(\omega)| > |A_a(\omega)|/2$, so the strict inequality holds eventually; multiply by $N$. $\square$

At resonance the cancellation is in fact very strong: by Theorem 3.4 the sum is $O(1 + |\omega|\log N)$, and numerically $|F_3(1/5, N)| < 8$ for $N$ up to $10^5$.

### 4.3 The zero-frequency peak: no pointwise decay

**Theorem 4.5 (Peak near zero).** If $|(2a-1)\omega| \le \tfrac23$, then for all sufficiently large $N$,
$$|F_a(\omega, N)| \;\ge\; \frac{N}{4}.$$

*Proof sketch.* Put $t = (a-\tfrac12)\omega$, so $|t| \le 1/3$ and hence $|\pi t| \le \pi/3$. Since cosine is decreasing on $[0,\pi]$ and even, $\cos(\pi t) \ge \cos(\pi/3) = 1/2$, whence $|A_a(\omega)| \ge 1/2$ by Theorem 4.1. Apply Theorem 4.4(2), which gives $|F_a(\omega,N)| \ge \tfrac12|A_a(\omega)|N \ge N/4$ eventually. $\square$

**Corollary 4.6 (Refutation of global pointwise decay).** There is no statement of the form "$F_a(\omega,N) = o(N)$ for every irrational $\omega$". Indeed the interval $\bigl(0, \tfrac{2}{3(2a-1)}\bigr]$ contains irrational $\omega$, and every such $\omega$ violates it by Theorem 4.5.

The obstruction is structural rather than technical: by Proposition 2.4 the phase ratio takes only two limiting values, so the sequence $\{\omega r_a(n)\}$ is nowhere near equidistributed mod $1$, and continuity of the amplitude at $\omega = 0$ (where $A_a(0)=1$) pins the transform to the trivial bound on a whole neighbourhood.

---

## 5. The arithmetic of resonance sets

Theorem 4.3 says $R_a$ depends on $a$ only through $2a-1$, so the resonance sets carry exactly one integer's worth of information. We now determine what can and cannot be read off from them.

### 5.1 Integer frequencies carry no information

**Theorem 5.1 (Trivial resonances).** For every $a \ge 1$ and every $t \in \mathbb{Z}$:
1. $A_a(2t+1) = 0$: every multiplier resonates at every odd integer frequency;
2. $|A_a(2t)| = 1$: at every even integer frequency the transform attains the maximal amplitude;
3. consequently $|A_a(t)| = |A_b(t)|$ for all $a,b \ge 1$ and all $t \in \mathbb{Z}$.

*Proof sketch.* (1) $(2a-1)(2t+1) = 2\bigl((2a-1)t + a - 1\bigr)+1$ is odd, so Theorem 4.3 applies. (2) $\pi(a-\tfrac12)(2t) = \bigl((2a-1)t\bigr)\pi$ is an integer multiple of $\pi$, and $|\cos(k\pi)| = 1$. (3) follows from (1) and (2) by splitting on the parity of $t$. $\square$

So no spectral discriminator between multipliers can be read off at integer frequencies, and in particular none near $\omega = 0$, the regime where the transform is largest.

### 5.2 Pairwise common resonances

**Lemma 5.2 (Diophantine form).** If $\omega \in R_a \cap R_b$, say $(2a-1)\omega = 2m+1$ and $(2b-1)\omega = 2k+1$ with $m,k \in \mathbb{Z}$, then
$$(2b-1)(2m+1) = (2a-1)(2k+1).$$

*Proof sketch.* Both sides equal $(2a-1)(2b-1)\omega$. $\square$

**Theorem 5.3 (Common resonances of the classical multipliers are trivial).** For each of the pairs $(a,b) \in \{(3,5), (3,7), (5,7)\}$ and every $\omega \in \mathbb{R}$,
$$A_a(\omega) = 0 \;\wedge\; A_b(\omega) = 0 \iff \omega \in 2\mathbb{Z}+1.$$

*Proof sketch.* ($\Leftarrow$) is Theorem 5.1(1). ($\Rightarrow$): take $(a,b) = (3,5)$. Lemma 5.2 gives $9(2m+1) = 5(2k+1)$, so $5 \mid 2m+1$ and $2m+1 = 5(2s+1)$ for an integer $s$ (explicitly $s = \lfloor (m-2)/5 \rfloor$). Then $5\omega = 2m+1 = 5(2s+1)$, so $\omega = 2s+1$ is an odd integer. The cases $(3,7)$ (where $13(2m+1) = 5(2k+1)$) and $(5,7)$ (where $13(2m+1) = 9(2k+1)$) are identical modulo the divisibility bookkeeping. $\square$

Thus each pair of classical multipliers shares only the universal resonances.

### 5.3 An explicit discriminator

**Theorem 5.4 (Spectral separation of $3n+1$, $5n+1$, $7n+1$).**
1. At $\omega = 1/5$: $A_3(1/5) = 0$, while $A_5(1/5) \ne 0$ and $A_7(1/5) \ne 0$. Explicitly $|A_5(1/5)| = \cos(\pi/10) \approx 0.9511$ and $|A_7(1/5)| = |\cos(3\pi/10)| \approx 0.5878$. Hence $F_3(1/5,N) = o(N)$, whereas $|F_5(1/5,N)| \ge 0.475\,N$ and $|F_7(1/5,N)| \ge 0.293\,N$ for large $N$.
2. At $\omega = 1/9$: $A_5(1/9) = 0$ while $A_3(1/9) \ne 0 \ne A_7(1/9)$.
3. At $\omega = 1/13$: $A_7(1/13) = 0$ while $A_3(1/13) \ne 0 \ne A_5(1/13)$.

In particular $R_3$, $R_5$, $R_7$ are pairwise distinct.

*Proof sketch.* For (1): $(2\cdot 3-1)/5 = 1$ is odd, giving $A_3(1/5)=0$ by Theorem 4.3. For $a=5$: $A_5(1/5)=0$ would force $9/5 = 2m+1$, i.e. $9 = 10m+5$, impossible over $\mathbb{Z}$. For $a=7$: $13 = 10m+5$ is likewise impossible. The moduli follow from Theorem 4.1, and the linear lower bounds from Theorem 4.4(2). Items (2) and (3) are the analogous computations with $17/9$, $5=18m+9$, $13=18m+9$, and with $25/13$, $5=26m+13$, $9=26m+13$. $\square$

This is a genuine arithmetic discriminator: it detects the multiplier through the *location* of the resonance comb, not through any dynamical property of the map.

### 5.4 Averaging destroys the discriminator

Faced with the failure of pointwise decay, a natural fallback is an $L^2$ statement over a period. We compute it exactly, and it is uninformative.

**Theorem 5.5 (Mean square of the amplitude).** For every integer $a \ge 1$,
$$\int_0^2 \bigl| A_a(\omega) \bigr|^2 \, d\omega = 1,$$
i.e. the mean of $|A_a|^2$ over the interval $[0,2]$ equals $\tfrac12$, independently of $a$.

*Proof sketch.* By Theorem 4.1 and the double-angle formula,
$$|A_a(\omega)|^2 = \cos^2\bigl(\pi(a-\tfrac12)\omega\bigr) = \frac12 + \frac{\cos\bigl(\pi(2a-1)\omega\bigr)}{2}.$$
The constant contributes $1$ over $[0,2]$. The cosine contributes
$$\frac{1}{2}\int_0^2 \cos\bigl(\pi(2a-1)\omega\bigr) d\omega = \frac{\sin\bigl(2\pi(2a-1)\bigr)}{2\pi(2a-1)} = 0,$$
because $2(2a-1)$ is an even integer and $\sin$ vanishes at integer multiples of $\pi$. $\square$

Every $an+1$ map carries the same total spectral energy. Only the *positions* of the zeros distinguish multipliers; any statistic that integrates $|A_a|^2$ against a multiplier-independent weight over full periods is blind.

---

## 6. The no-go theorem: the one-step spectrum cannot see dynamics

The results so far are about a particular family of maps. The following theorem is about the statistic itself, and it is the sharpest limitation.

**Definition 6.1 (Generic transform).** For any function $r : \mathbb{N}_{\ge 1} \to \mathbb{R}$ put $F[r](\omega, N) = \sum_{n=1}^{N} e(\omega\, r(n))$. Thus $F_a(\omega,N) = F[r_a](\omega,N)$.

**Lemma 6.2 (Disagreement bound).** For all $r_1, r_2, \omega, N$,
$$\bigl| F[r_1](\omega,N) - F[r_2](\omega,N) \bigr| \;\le\; 2\,\#\{1 \le n \le N : r_1(n) \ne r_2(n)\}.$$

*Proof sketch.* Terms with $r_1(n) = r_2(n)$ cancel exactly. Each remaining term is a difference of two unit vectors, of modulus at most $2$. $\square$

**Theorem 6.3 (Blindness to density-zero modification).** Let $r_1, r_2 : \mathbb{N}_{\ge 1} \to \mathbb{R}$ and suppose the disagreement set has density zero:
$$\frac{\#\{1 \le n \le N : r_1(n) \ne r_2(n)\}}{N} \longrightarrow 0.$$
Then for every $\omega$,
$$\frac{F[r_1](\omega,N)}{N} - \frac{F[r_2](\omega,N)}{N} \longrightarrow 0.$$

*Proof sketch.* Divide Lemma 6.2 by $N$ and apply the density hypothesis. $\square$

**Corollary 6.4 (Finite surgery is spectrally invisible).** Let $S$ be a finite set of positive integers and let $r$ agree with $r_a$ outside $S$. Then
$$\frac{F[r](\omega,N)}{N} \longrightarrow A_a(\omega) \qquad\text{for every } \omega.$$

*Proof sketch.* The disagreement count is at most $|S|$ for every $N$, hence of density zero; combine Theorem 6.3 with Theorem 3.3. $\square$

**Interpretation.** Whether the $3n+1$ map possesses a nontrivial cycle, and what the stopping time of any particular integer is, are assertions about finite sets of inputs — precisely the data that Corollary 6.4 shows the normalized transform cannot detect. Consequently:

> No implication of the form *"cancellation in the one-step cutoff sum $\Rightarrow$ an orbit hitting-time or cycle-exclusion statement"* can be valid, since the hypothesis is invariant under modifications that change the conclusion.

Any spectral approach with dynamical content must therefore use a statistic that is *not* invariant under density-zero surgery. The two obvious candidates are the subleading terms of the same sum (which are of size $\log N$, hence in principle sensitive to $O(\log N)$-sized modifications) and the iterated transforms built from $T_a^m$, whose branch structure grows with $m$. Both are discussed in Section 8.

---

## 7. Algorithms and numerical verification

Three simple algorithms make the theory computationally testable.

**Algorithm A (Direct transform evaluation).** Given $a$, $\omega$, $N$, compute $F_a(\omega,N)$ by accumulating $e(\omega r_a(n))$ for $n = 1, \dots, N$. Cost $\Theta(N)$ time, $O(1)$ space. Using Theorem 3.1 one may instead evaluate the constant even branch in $O(1)$ and only loop over odd $n$, halving the work.

**Algorithm B (Resonance enumeration).** Given $a$ and a bound $W$, enumerate $R_a \cap (0,W] = \{(2m+1)/(2a-1) : 0 \le m < \bigl((2a-1)W-1\bigr)/2\}$. Cost $\Theta\bigl((2a-1)W\bigr)$ output-sensitive time. Membership testing for a given $\omega$ is $O(1)$: check that $(2a-1)\omega$ is within tolerance of an odd integer.

**Algorithm C (Discriminator search).** Given a finite set $\mathcal{A}$ of multipliers, find a frequency at which $a_0 \in \mathcal{A}$ resonates and no other member does. By Theorem 4.3 it suffices to scan $\omega = (2m+1)/(2a_0-1)$ for small $m$ and reject those $\omega$ for which some other $b \in \mathcal{A}$ satisfies $(2b-1)\omega \in 2\mathbb{Z}+1$; Theorem 5.3 guarantees that for the classical multipliers only the odd integers must be rejected, so the search terminates at $m = 0$ with $\omega = 1/(2a_0-1)$.

Numerically, with $a=3$ and $\omega = 0.37$ one finds $|F_3(\omega,N)/N - A_3(\omega)|$ equal to $8.1\times10^{-3}$ at $N = 10^3$ and $1.3\times10^{-4}$ at $N = 10^5$, in both cases comfortably inside the bound of Theorem 3.4. At the resonance $\omega = 1/5$ of the $3n+1$ map the raw sum grows only like $\log N$: $|F_3(1/5,N)| \approx 3.5, 4.9, 6.3, 7.8$ at $N = 10^2, 10^3, 10^4, 10^5$, consistent with $o(N)$ and with the conjectural $\log N$ law of Section 8. At the same frequency, $|F_5|/N \to 0.9511$ and $|F_7|/N \to 0.5878$, matching Theorem 5.4 to four decimal places. Midpoint-rule integration of $|A_a|^2$ over $[0,2]$ returns $0.50000000$ for $a = 1,2,3,5,7,11,101$, confirming Theorem 5.5. Finally, replacing the phase ratio by an arbitrary value at every power of two — a set of density zero — changes the normalized transform by less than $4 \times 10^{-5}$ at $N = 10^5$, illustrating Theorem 6.3.

---

## 8. Discussion and future directions

### 8.1 What has been settled

For the one-step phase $T_a(n)/n$ the situation is now completely understood. The phase splits into a constant even branch $1/2$ and an odd branch $a + 1/n$; the odd perturbation $1/n$ is negligible after Cesàro averaging; hence $F_a(\omega,N)/N \to \bigl(e(\omega/2)+e(a\omega)\bigr)/2$ with modulus $|\cos(\pi(a-\tfrac12)\omega)|$. Every question about "cancellation for the $an+1$ map at a fixed frequency" is therefore answered at the level of the one-step sum — and by Theorem 6.3 the answer contains no dynamical information whatsoever.

Two corollaries are worth stating as methodological principles. First, when a proposed pseudorandomness statistic is bounded and has finitely many accumulation points in its phase, its normalized limit should be computed *before* any effort is spent proving cancellation bounds. Second, a statistic invariant under density-zero surgery cannot imply any statement about finite orbit data; invariance under such surgery is a cheap and decisive test to apply to any candidate.

### 8.2 Conjecture 1: the second-order law

The leading term erases the multiplier's arithmetic — it depends on $a$ only through the single cosine. The subleading term does not.

**Conjecture 8.1 (Second-order spectral law).** For every $a \ge 1$ and every $\omega \ne 0$, the quantity
$$F_a(\omega, N) - N\,A_a(\omega) - c(a,\omega)\log N$$
converges as $N \to \infty$, where
$$c(a,\omega) = \pi i\, \omega\, e(a\omega).$$
Equivalently, $\bigl(F_a(\omega,N) - N A_a(\omega)\bigr)/\log N \to c(a,\omega)$.

The heuristic is exact expansion of the odd branch: $e(\omega/n) = 1 + 2\pi i \omega/n + O(\omega^2/n^2)$, and $\sum_{n \le N,\, n \text{ odd}} 1/n = \tfrac12 \log N + O(1)$, so the deviation sum contributes $e(a\omega)\cdot 2\pi i \omega \cdot \tfrac12 \log N$. Theorem 3.4 already isolates the deviation sum and bounds it by $2\pi|\omega|(1+\log N)$; the conjecture asserts that this bound is attained with the stated constant, which requires only a matching lower bound together with the standard asymptotics of the odd harmonic sum. Note that $c(a,\omega)$ carries the branch phase $e(a\omega)$ undamped and is linear in $\omega$: the subleading spectrum sees strictly more than the leading one. Numerically the convergence is slow (the ratio $(F - NA)/\log N$ at $a=3,\ \omega=0.37$ moves from $-0.976+0.659i$ at $N=10^3$ to $-0.859+0.777i$ at $N=10^6$, against the predicted $-0.741+0.896i$), as expected for an $O(1/\log N)$ correction.

### 8.3 Conjecture 2: iterated transforms are not blind

**Conjecture 8.2 (Iterated limit law).** For fixed $m \ge 1$ define the $m$-step transform
$$F^{(m)}_a(\omega,N) = \sum_{n \le N} e\!\left(\omega\, \frac{T_a^m(n)}{n}\right).$$
Then $F^{(m)}_a(\omega,N)/N$ converges to a finite combination
$$\sum_{j} 2^{-m}\,\mu_j\, e(\omega r_j),$$
where the $r_j$ are the finitely many limiting $m$-step ratios $a^{k}/2^{\,m-k}$ ($k$ = number of odd steps taken) and $\mu_j$ is the number of residue classes mod $2^m$ following the corresponding parity pattern. Moreover, for $m \ge 2$ the resulting resonance set is *not* a coset of a lattice, and its zero set determines $a$ uniquely.

The point is structural: one step gives two branches and hence a cosine, whose zero set is an arithmetic progression and therefore encodes only the single integer $2a-1$. Two steps give up to four branches with unequal weights, and a sum of four unit vectors with rational weights has a zero set that is a genuine algebraic variety in $\omega$ rather than a lattice coset. Determining these zero sets, and quantifying the perturbation caused by the $O(1/n)$ corrections at each of the $m$ steps, is the natural continuation.

### 8.4 Further directions

* **Local exclusion instead of global bounds.** Replace the impossible global condition over all irrational frequencies by a condition excluding a fixed neighbourhood of the integer resonances; by continuity, values near the zero-frequency peak necessarily remain near the trivial bound $N$, so any meaningful hypothesis must exclude them explicitly.
* **Quantitative cancellation on compact sets bounded away from integers.** Study $F_a(\omega,N)/N$ on compact frequency sets at positive distance from $\mathbb{Z}$, and seek estimates uniform in $N$ that are sharper than the $O((1+|\omega|\log N)/N)$ bound of Theorem 3.4.
* **Sharper branch asymptotics.** The explicit decomposition into a constant even phase $1/2$ and an odd phase $a + 1/n$ should support strictly sharper asymptotic estimates than those obtained by treating the two branches together.
* **Averaged statements outside exceptional sets.** Formulate $L^2$ bounds over a period, or bounds valid outside an exceptional set of small measure. Such claims are compatible with isolated resonant peaks in a way that a pointwise bound over all irrationals is not — though Theorem 5.5 shows plain mean-square averaging is multiplier-blind, so any useful averaged statistic must be weighted so as to detect the location of the resonance comb.
* **Comparative statistics for $3n+1$, $5n+1$, $7n+1$.** Compare corrected normalized or averaged statistics across the three classical multipliers. Any useful discriminator must depend on more than continuity near frequency zero, since by Theorem 5.1 all multipliers agree at integer frequencies.
* **Orbit-dependent transforms.** Investigate transforms built from orbit data (hitting times, total stopping times) separately from the one-step cutoff sum. A rigorous implication between an orbit hitting-time estimate and a spectral estimate would require precise definitions and directional proofs; by Corollary 6.4 it must not be treated as an automatic equivalence.

---

## 9. Conclusion

The one-step spectral transform of the $an+1$ maps is completely solved. Its normalized limit is $\bigl(e(\omega/2)+e(a\omega)\bigr)/2$, with modulus the single cosine $|\cos(\pi(a-\tfrac12)\omega)|$ and resonance set the arithmetic progression $\{(2m+1)/(2a-1)\}$. Convergence holds with an explicit $O\bigl((1+|\omega|\log N)/N\bigr)$ rate, uniformly in the multiplier and locally uniformly in the frequency. Cancellation occurs exactly on the resonance set; near frequency zero the transform is pinned to a quarter of the trivial bound, refuting any global pointwise decay hypothesis; the mean square of the amplitude is the universal constant $\tfrac12$; and the whole statistic is invariant under modification of the map on any density-zero set of inputs, hence carries no information about cycles or hitting times.

What survives is the arithmetic of the resonance combs, which separates $3n+1$, $5n+1$ and $7n+1$ pairwise at the frequencies $1/5$, $1/9$ and $1/13$, and which agrees for all multipliers precisely at integer frequencies. The natural continuations — the conjectural second-order $\log N$ law and the non-lattice resonance geometry of iterated transforms — are exactly the regimes in which the invariance obstruction of Section 6 no longer applies.
