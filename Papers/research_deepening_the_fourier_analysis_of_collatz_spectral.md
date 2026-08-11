# The 2-adic Fourier Analysis of the Collatz Map: An Exact Spectral Gap and Density-One Descent

**Author:** Aristotle
**Date:** 2026-08-11

---

## Abstract

We develop a Fourier-analytic theory of the accelerated Collatz map $T(n) = n/2$ for even $n$ and $T(n) = (3n+1)/2$ for odd $n$, carried out on the finite groups $\mathbb{Z}/2^k\mathbb{Z}$ rather than on the real frequency line. The archimedean exponential sum attached to the Collatz map admits no spectral gap, for the elementary reason that it is a continuous function of the frequency taking the value $N$ at frequency zero. Replacing the archimedean frequency by a $2$-adic one repairs this completely.

Our central object is the **parity word** $w_k(n) \in \{0,\dots,2^k-1\}$ recording the parities of the first $k$ iterates of $T$. Using Terras' affine transport formula $T^{k}(n + 2^k m) = T^{k}(n) + 3^{\,s_k(n)} m$, where $s_k(n)$ is the number of odd steps, together with the observation that $3^{s}$ is odd, we prove that $n \mapsto w_k(n)$ is a **bijection** of $\mathbb{Z}/2^k\mathbb{Z}$. Consequently the discrete Fourier transform
$$F_k(j) = \sum_{n=0}^{2^k-1} e^{2\pi i\, j\, w_k(n)/2^k}$$
satisfies $F_k(0) = 2^k$ and $F_k(j) = 0$ for **every** nonzero frequency $j$ modulo $2^k$: an exact spectral gap, with total rather than square-root cancellation, and with Parseval identity $\sum_j |F_k(j)|^2 = 4^k$.

From this equidistribution we extract exact moment identities: the generating function $\sum_{n<2^k} x^{\,s_k(n)} = (1+x)^k$ holds in every commutative semiring, whence $s_k$ has mean exactly $k/2$ and variance exactly $k/4$, and $\sum_{n<2^k} 3^{\,s_k(n)} = 4^k$, so the arithmetic mean of the $k$-step multiplier $3^{s_k}/2^k$ is exactly $1$ while its geometric mean is exactly $(\sqrt3/2)^k$. Writing $\theta = \log 2/\log 3 \approx 0.63093$ for the critical odd-step density and $\delta = \theta - \tfrac12 \approx 0.13093$ for the spectral margin, Chebyshev's inequality yields a non-contracting density bound $\rho_k \le 1/(4\delta^2 k)$, and a Chernoff argument at the integral tilt $x = 2$ upgrades this to the exponential bound $\rho_k^{5} \le (243/256)^{k}$.

Finally, the transport formula converts these residue-class statements into arithmetic ones: every $n \ge 8^k$ whose residue mod $2^k$ has a contracting parity word satisfies $T^k(n) < n$; the descending residue classes have density at least $1 - 1/(4\delta^2 k)$; and for every $\varepsilon > 0$ there is a scale $k$ such that the natural density of integers failing $k$-step descent is eventually below $\varepsilon$. At $N = 64^k$ the failure density is at most $\rho_k + 2\cdot 8^{-k}$, hence exponentially small.

---

## 1. Introduction

### 1.1 The problem and the heuristic

The Collatz map $C:\mathbb{N}\to\mathbb{N}$ is defined by $C(n) = n/2$ for even $n$ and $C(n) = 3n+1$ for odd $n$. The Collatz conjecture asserts that the orbit of every positive integer eventually reaches the cycle $\{1,4,2\}$. It is unresolved.

The best-known heuristic in favour of the conjecture is probabilistic. Since $3n+1$ is even whenever $n$ is odd, it is convenient to work with the **accelerated map**
$$T(n) = \begin{cases} n/2, & n \equiv 0 \pmod 2, \\ (3n+1)/2, & n \equiv 1 \pmod 2, \end{cases}$$
which performs one classical step on even inputs and two on odd inputs, and which therefore has the same orbit structure. One step of $T$ multiplies $n$ by approximately $1/2$ or approximately $3/2$ according to parity. If parities behaved like independent fair coin flips, the expected logarithmic drift per step would be
$$\tfrac12 \log \tfrac12 + \tfrac12\log\tfrac32 = \log\frac{\sqrt3}{2} \approx -0.1438 < 0,$$
so a typical orbit would shrink geometrically at rate $\sqrt3/2 \approx 0.866$ per step, and would therefore descend to bounded values.

The difficulty is that $T$ is deterministic. The heuristic posits an ensemble that does not exist. The purpose of this paper is to show that, at every fixed $2$-adic scale, the ensemble *does* exist, exactly, and that the resulting statistics can be pushed into unconditional descent theorems of density one.

### 1.2 Why archimedean Fourier analysis fails

The natural formulation of "Collatz parities equidistribute" as an exponential-sum estimate is a spectral gap for a sum such as
$$F(\omega) = \sum_{n=1}^{N} e^{2\pi i \,\omega\, T(n)}, \qquad \omega \in \mathbb{R},$$
namely a bound $|F(\omega)| \le C\sqrt{N}$ valid for all $\omega$ outside a small set. No such bound can hold. The function $F$ is a finite sum of continuous functions, hence continuous, and $F(0) = N$. Continuity forces $|F(\omega)| > N/2$, say, on an entire interval around $0$, and that interval contains frequencies that no arithmetic condition excludes. The obstruction is structural: the frequency variable is archimedean, whereas every feature of the Collatz map — the halving, the parity, the $2$-adic valuation — is not.

### 1.3 The fix and the results

We therefore move the frequency variable to the finite group $\mathbb{Z}/2^k\mathbb{Z}$ and Fourier-analyse the parity word rather than the iterate. The resulting transform has *perfect* cancellation at every nonzero frequency (Theorem 3.2). All subsequent results are consequences of that fact together with the affine transport formula.

The logical chain is:

1. the affine transport formula (Theorem 2.3), giving
$$T^{k}(n+2^k m) = T^{k}(n) + 3^{\,s_k(n)}m;$$
2. the parity-word bijection on $\mathbb{Z}/2^k\mathbb{Z}$ (Theorem 2.7);
3. the exact spectral gap $F_k(j) = 0$ for all $j \neq 0$ (Theorem 3.2);
4. the exact moments $\sum_{n<2^k} x^{\,s_k(n)} = (1+x)^k$ (Theorem 4.2);
5. the Chebyshev density bound $\rho_k \le 1/(4\delta^2 k)$ (Theorem 5.6) and the Chernoff bound $\rho_k^5 \le (243/256)^k$ (Theorem 6.4);
6. $k$-step descent above the explicit threshold $8^k$ (Theorem 7.4);
7. the natural-density descent statement about actual integers (Theorem 8.5).

---

## 2. The parity word and the transport formula

Throughout, $k$ denotes a $2$-adic scale and all variables range over $\mathbb{N} = \{0,1,2,\dots\}$.

**Definition 2.1 (Accelerated map, parity bits, parity word).**
Set $T(n) = n/2$ if $n$ is even and $T(n) = (3n+1)/2$ if $n$ is odd. For $j \ge 0$ define the $j$-th **parity bit** of $n$ by
$$b_j(n) = T^{j}(n) \bmod 2 \in \{0,1\},$$
and for $k \ge 0$ define the **parity word** and the **odd-step count** by
$$w_k(n) = \sum_{j=0}^{k-1} b_j(n)\,2^{j}, \qquad s_k(n) = \sum_{j=0}^{k-1} b_j(n).$$
Thus $0 \le w_k(n) < 2^k$ and $0 \le s_k(n) \le k$; $s_k(n)$ is the binary digit sum of $w_k(n)$.

**Remark 2.2.** $T$ is exactly the classical map with the forced even step folded in: $T(n) = C(n)$ for even $n$ and $T(n) = C(C(n))$ for odd $n$. In particular $T$ and $C$ have the same orbit closure, and descent statements for $T$ transfer to $C$.

The following identity is due in essence to Terras, and it is the arithmetic engine of everything below.

**Theorem 2.3 (Affine transport formula).** For all $k, n, m \ge 0$,
$$T^{k}\!\left(n + 2^k m\right) \;=\; T^{k}(n) \;+\; 3^{\,s_k(n)}\, m,$$
and $b_j(n + 2^k m) = b_j(n)$ for every $j < k$.

*Proof sketch.* Induct on $k$. The base case is trivial. For the inductive step, one first records the one-step perturbation rule
$$T(x + 2m) = \begin{cases} T(x) + m, & x \text{ even},\\ T(x) + 3m, & x \text{ odd},\end{cases}$$
which is immediate from the definition of $T$ (in the odd case, $x + 2m$ is odd and $(3(x+2m)+1)/2 = (3x+1)/2 + 3m$). Now write $n + 2^{k+1}m = n + 2^{k}(2m)$ and apply the inductive hypothesis with perturbation $2m$: it gives $T^{k}(n + 2^{k}\cdot 2m) = T^{k}(n) + 3^{s_k(n)}\cdot 2m$, a perturbation of $T^{k}(n)$ by an *even* number, and it gives agreement of the first $k$ parity bits. Since the perturbation is even, the $k$-th bit also agrees, so all $k+1$ bits agree; and applying the one-step rule to $x = T^{k}(n)$ with perturbation $2\cdot 3^{s_k(n)}m$ multiplies the perturbation by $1$ or $3$ according to the parity of $T^{k}(n)$, i.e. according to $b_k(n)$ — which is exactly the passage from $3^{s_k(n)}$ to $3^{s_{k+1}(n)}$. $\square$

**Corollary 2.4 (Periodicity).** For all $k, n, m$: $w_k(n + 2^k m) = w_k(n)$ and $s_k(n+2^k m) = s_k(n)$. Hence $w_k$ and $s_k$ descend to well-defined functions on $\mathbb{Z}/2^k\mathbb{Z}$.

**Interpretation.** Theorem 2.3 says that the $k$-fold iterate $T^{k}$, restricted to a single residue class $r + 2^k\mathbb{Z}$, is the affine map
$$r + 2^k m \;\longmapsto\; T^{k}(r) + 3^{\,s_k(r)}m,$$
i.e. a line of slope $3^{\,s_k(r)}/2^{k}$ in the variable $n$. The apparently chaotic Collatz dynamics decomposes, at each $2$-adic scale, into $2^k$ affine pieces whose slopes are pure ratios of powers of $3$ and $2$. The multiplicative behaviour of the map over $k$ steps is *entirely encoded* in the single integer $s_k(r)$.

**Lemma 2.5 (Bit flip).** For all $k, n$: $b_k(n + 2^k) \ne b_k(n)$.

*Proof.* By Theorem 2.3 with $m=1$, $T^{k}(n+2^k) = T^{k}(n) + 3^{\,s_k(n)}$. Since $3^{s}$ is odd, the two iterates have opposite parities. $\square$

This trivial-looking lemma is the injectivity engine.

**Theorem 2.6 (Injectivity).** If $w_k(n) = w_k(n')$ then $n \equiv n' \pmod{2^k}$.

*Proof sketch.* Induct on $k$. Since $w_{k+1}(n) = w_k(n) + b_k(n)2^{k}$ with $w_k(n) < 2^{k}$ and $b_k(n)\in\{0,1\}$, equality of the length-$(k+1)$ words forces both $w_k(n) = w_k(n')$ and $b_k(n)=b_k(n')$. The inductive hypothesis gives $n' = n + 2^{k}c$ for some $c$ (assuming without loss $n \le n'$). If $c$ is even, $n' \equiv n \pmod{2^{k+1}}$ and we are done. If $c$ is odd, write $n' = (n + 2^{k}) + 2^{k+1}d$; by Corollary 2.4 the $k$-th bit of $n'$ equals that of $n + 2^{k}$, which by Lemma 2.5 differs from that of $n$ — contradicting $b_k(n)=b_k(n')$. $\square$

**Theorem 2.7 (Parity-word bijection).** For every $k$, the map $w_k$ restricted to $\{0,1,\dots,2^k-1\}$ is a bijection onto $\{0,1,\dots,2^k-1\}$. Equivalently, every binary word of length $k$ is the parity prefix of exactly one residue class modulo $2^k$; equivalently, for each $w < 2^k$ the fibre $\{n < 2^k : w_k(n) = w\}$ has exactly one element.

*Proof.* $w_k$ maps $\{0,\dots,2^k-1\}$ into itself (as $w_k(n)<2^k$ always) and is injective there by Theorem 2.6; a self-injection of a finite set is a bijection. $\square$

**Corollary 2.8 (Reindexing).** For any commutative monoid $M$ and any $g:\mathbb{N}\to M$,
$$\sum_{n=0}^{2^k-1} g(w_k(n)) \;=\; \sum_{w=0}^{2^k-1} g(w).$$

**Corollary 2.9 (Extremal classes).** For every $k$ there exists $n < 2^k$ with $b_j(n)=1$ for all $j<k$ (hence $s_k(n)=k$), and there exists $n<2^k$ with $b_j(n)=0$ for all $j<k$ (hence $s_k(n)=0$).

*Proof.* Take the preimages under $w_k$ of $2^k-1$ and of $0$; identify $w_k(n) = \sum_{j<k}2^j$ forces every bit to be $1$, and $w_k(n)=0$ forces every bit to be $0$. $\square$

These two classes are the maximally expanding ($k$-step multiplier $(3/2)^k$) and maximally contracting ($2^{-k}$) residue classes; their existence at every scale shows that no pointwise contraction theorem is available and that only density statements can be true.

---

## 3. The exact spectral gap

**Definition 3.1 (Collatz parity transform).** For $k \ge 0$ and $j \in \mathbb{Z}$ set
$$F_k(j) \;=\; \sum_{n=0}^{2^k-1} \exp\!\left(\frac{2\pi i\, j\, w_k(n)}{2^{k}}\right) \in \mathbb{C}.$$
This is the discrete Fourier transform, on the group $\mathbb{Z}/2^k\mathbb{Z}$, of the pushforward of the uniform measure on residues under the parity word.

**Theorem 3.2 (Exact spectral gap).** $F_k(0) = 2^k$, and $F_k(j) = 0$ for every $j$ with $0 < j < 2^k$. More generally $F_k(j \bmod 2^k) = 0$ whenever $2^k \nmid j$.

*Proof.* Let $N = 2^k$, let $\mu = e^{2\pi i/N}$ be a primitive $N$-th root of unity and put $z = \mu^{j}$. Since $0 < j < N$, $z \ne 1$; and $z^{N} = 1$. Each summand equals $z^{\,w_k(n)}$. By Corollary 2.8,
$$F_k(j) = \sum_{n<N} z^{\,w_k(n)} = \sum_{w<N} z^{w} = \frac{z^{N}-1}{z-1} = 0 . \qquad\square$$

**Corollary 3.3 (Beyond square-root cancellation).** For every nonzero frequency $j$ mod $2^k$, $\|F_k(j)\| = 0 < \sqrt{2^k}$. Thus the transform strictly beats the square-root cancellation that a random phase would produce, in contrast with the archimedean transform, which admits no gap at all.

**Corollary 3.4 (Parseval).** $\displaystyle\sum_{j=0}^{2^k-1} |F_k(j)|^2 = 4^{k}$; the entire spectral mass sits at the DC frequency.

**Discussion.** Theorem 3.2 is the exact analogue, in the $2$-adic frequency world, of the estimate that fails archimedean-ly. It expresses a very strong equidistribution statement: the parity word is not merely approximately uniform on $\{0,1\}^k$; it is *exactly* uniform, with every fibre of size exactly $1$. What was in the heuristic an assumption ("parities are i.i.d. fair bits") is now a theorem about a finite abelian group, with zero error term at every scale.

Two caveats deserve emphasis. First, the uniformity is *at a fixed scale*: it says nothing about correlations between the parity word of $n$ and the parity word of $T^{k}(n)$, which is exactly the coupling one would need to iterate. Second, uniformity is a statement about the distribution of $s_k$ over residue classes; it does not weight classes by how many integers of a given size they contain in a nonuniform way, but neither does it survive conditioning on membership in an orbit.

---

## 4. Exact moments of the odd-step count

The bijection lets us compute the full distribution of $s_k$, since $s_k(n)$ is the digit sum of $w_k(n)$ and $w_k$ is a bijection onto $\{0,\dots,2^k-1\}$. It is instructive, however, to record a direct induction, because the same doubling pairing drives all the moment identities.

**Lemma 4.1 (Doubling pairing).** For every $k$ and every $i$, exactly one of the following holds:
$$\bigl(s_{k+1}(i) = s_k(i)\ \text{and}\ s_{k+1}(2^k+i) = s_k(i)+1\bigr) \quad\text{or}\quad \bigl(s_{k+1}(i) = s_k(i)+1\ \text{and}\ s_{k+1}(2^k+i) = s_k(i)\bigr).$$

*Proof.* $s_{k+1}(x) = s_k(x) + b_k(x)$. By Corollary 2.4, $s_k(2^k+i) = s_k(i)$; by Lemma 2.5, $b_k(2^k+i) \ne b_k(i)$, and both lie in $\{0,1\}$. $\square$

**Theorem 4.2 (Generating function).** For every commutative semiring $R$, every $x \in R$ and every $k \ge 0$,
$$\sum_{n=0}^{2^k-1} x^{\,s_k(n)} \;=\; (1+x)^{k}.$$
Equivalently, $\#\{n < 2^k : s_k(n) = s\} = \binom{k}{s}$ for every $0 \le s \le k$.

*Proof sketch.* Induct on $k$. Split $\{0,\dots,2^{k+1}-1\}$ into $\{i\} \sqcup \{2^k+i\}$ for $i < 2^k$. By Lemma 4.1 the two partners contribute $x^{s_k(i)} + x^{s_k(i)+1} = x^{s_k(i)}(1+x)$ in either case. Summing over $i$ and applying the inductive hypothesis gives $(1+x)^{k}(1+x) = (1+x)^{k+1}$. $\square$

**Corollary 4.3 (Total multiplier mass; criticality).** Taking $x=3$: $\displaystyle\sum_{n<2^k} 3^{\,s_k(n)} = 4^{k}$. Consequently the $k$-step multiplier $M_k(n) := 3^{\,s_k(n)}/2^{k}$ has arithmetic mean exactly $1$ over a complete residue system mod $2^k$:
$$\frac{1}{2^k}\sum_{n<2^k} \frac{3^{\,s_k(n)}}{2^{k}} \;=\; \frac{4^k}{4^k} \;=\; 1 .$$

**Corollary 4.4 (Exponential moment at the integral tilt).** Taking $x=2$: $\displaystyle\sum_{n<2^k} 2^{\,s_k(n)} = 3^{k}$.

**Theorem 4.5 (First moment).** $\displaystyle 2\sum_{n<2^k} s_k(n) = k\,2^{k}$, i.e. $\mathbb{E}[s_k] = k/2$ exactly.

*Proof sketch.* Induction using Lemma 4.1: the pair $(i, 2^k+i)$ contributes $s_{k+1}(i)+s_{k+1}(2^k+i) = 2s_k(i)+1$ in either case, so the total at scale $k+1$ is $2\sum_{i<2^k}s_k(i) + 2^k$, and the claim follows from the inductive hypothesis and $(k+1)2^{k+1} = 2(k2^k) + 2^{k+1}$. $\square$

**Theorem 4.6 (Exact variance).**
$$\sum_{n=0}^{2^k-1}\bigl(2 s_k(n) - k\bigr)^2 \;=\; k\,2^{k},$$
i.e. $\mathrm{Var}(s_k) = k/4$ exactly, the variance of $k$ fair coin flips.

*Proof sketch.* Induction with the same pairing. Fix $i < 2^k$ and write $u = 2s_k(i) - k$. In either branch of Lemma 4.1 the two centred values at scale $k+1$ are $\{u-1, u+1\}$ in some order, and
$$(u-1)^2 + (u+1)^2 = 2u^2 + 2 .$$
Summing over $i<2^k$: the scale-$(k+1)$ total is $2\bigl(k2^k\bigr) + 2\cdot 2^{k} = (k+1)2^{k+1}$. $\square$

**Remark 4.7.** Theorem 4.6 is the precise, unconditional form of the coin-flip heuristic. There is no error term and no averaging over an artificial ensemble: over any complete residue system modulo $2^k$, the number of odd Collatz steps in the first $k$ iterations is *exactly* a $\mathrm{Binomial}(k,\tfrac12)$ variable.

---

## 5. Contraction, criticality, and the Chebyshev bound

**Definition 5.1 (Contraction exponent, critical density, spectral margin).** For $k, s \ge 0$ put
$$\Lambda_k(s) \;=\; k\log 2 \;-\; s\log 3 ,$$
the **contraction exponent**; thus $\Lambda_k(s_k(n)) = -\log M_k(n)$ measures the logarithmic contraction of the $k$-step multiplier. Put
$$\theta = \frac{\log 2}{\log 3} \approx 0.6309297536, \qquad \delta = \theta - \frac12 \approx 0.1309297536 .$$
We call $\theta$ the **critical odd-step density** and $\delta$ the **spectral margin**. Note $\delta > 0$ precisely because $\log 3 < 2\log 2$, i.e. $3 < 4$.

**Theorem 5.2 (Exact mean drift).** For every $k$,
$$\frac{1}{2^k}\sum_{n<2^k}\Lambda_k(s_k(n)) \;=\; k\left(\log 2 - \tfrac12\log 3\right) \;=\; k\log\frac{2}{\sqrt3} \;>\;0 \quad (k \ge 1).$$
Equivalently, the **geometric** mean of the $k$-step multiplier over a complete residue system is exactly $(\sqrt3/2)^{k}$.

*Proof.* Linearity plus Theorem 4.5: the average of $k\log 2 - s_k(n)\log 3$ is $k\log 2 - (k/2)\log 3$. Positivity is $\log 3 < 2\log 2$. $\square$

**Remark 5.3 (Arithmetic versus geometric mean).** Corollary 4.3 and Theorem 5.2 together say: the arithmetic mean of the multiplier is exactly $1$, while its geometric mean is exactly $(\sqrt3/2)^k \to 0$. This is the AM–GM gap for a lognormal-like variable, and it is the honest mathematical content of "Collatz orbits shrink." The arithmetic mean is dominated by a negligible fraction of classes with enormous multipliers, and those classes exist: by Corollary 2.9 there is at every scale a class with $s_k = k$, whose multiplier is $(3/2)^k$ and whose contraction exponent $\Lambda_k(k) = k(\log 2 - \log 3) < 0$. Hence Theorem 5.2 admits no pointwise strengthening; the correct target is a density statement.

**Definition 5.4 (Non-contracting set).** Put
$$B_k \;=\; \{\,n < 2^k \;:\; \Lambda_k(s_k(n)) \le 0 \,\}, \qquad \rho_k \;=\; \frac{|B_k|}{2^{k}} .$$

**Lemma 5.5 (Deviation lower bound).** If $\Lambda_k(s_k(n)) \le 0$ then
$$2 s_k(n) - k \;\ge\; 2k\delta .$$

*Proof.* $\Lambda_k(s) \le 0$ means $k\log 2 \le s \log 3$, i.e. $s \ge k\theta$. Then $2s - k \ge 2k\theta - k = 2k(\theta - \tfrac12) = 2k\delta$. $\square$

**Theorem 5.6 (Chebyshev density bound).** For every $k \ge 1$,
$$\rho_k \;=\; \frac{|B_k|}{2^{k}} \;\le\; \frac{1}{4\delta^{2}k} \;\approx\; \frac{14.58}{k},$$
and hence $\rho_k \to 0$ as $k \to \infty$: **almost every residue class mod $2^k$ contracts over its first $k$ accelerated steps.**

*Proof.* By Lemma 5.5, each $n \in B_k$ contributes at least $(2k\delta)^2 = 4k^2\delta^2$ to the second moment. Since all summands are nonnegative and $B_k \subseteq \{0,\dots,2^k-1\}$,
$$|B_k| \cdot 4k^{2}\delta^{2} \;\le\; \sum_{n \in B_k}\bigl(2s_k(n)-k\bigr)^2 \;\le\; \sum_{n<2^k}\bigl(2s_k(n)-k\bigr)^2 \;=\; k\,2^{k}$$
by Theorem 4.6. Dividing by $4k^2\delta^2\,2^k$ gives the bound; letting $k\to\infty$ and squeezing between $0$ and $1/(4\delta^2 k)$ gives the limit. $\square$

Numerically $1/(4\delta^2) = 14.5836\ldots$, so the bound becomes nontrivial (i.e. $< 1$) for $k \ge 15$.

---

## 6. Chernoff: exponential decay of the failure density

The Chebyshev bound uses only the second moment. Theorem 4.2 provides *all* moments simultaneously, so an exponential-moment (Chernoff) argument is available. We deliberately run it at the tilt $x=2$, which keeps every inequality inside the integers.

**Lemma 6.1 (Integer Chernoff constraint).** If $2^{k} \le 3^{s}$ then $3k \le 5s$.

*Proof.* Suppose $5s < 3k$. Then $3^{5s} < 3^{3k} = 27^{k} \le 32^{k} = 2^{5k}$, while raising the hypothesis to the fifth power gives $2^{5k} \le 3^{5s}$ — a contradiction. $\square$

This is the arithmetic shadow of $\theta > 3/5$, i.e. of $27 \le 32$.

**Lemma 6.2 (Membership criterion).** $n \in B_k$ if and only if $2^{k} \le 3^{\,s_k(n)}$.

*Proof.* $\Lambda_k(s) \le 0 \iff k\log 2 \le s\log 3 \iff \log(2^k) \le \log(3^s) \iff 2^k \le 3^s$, by strict monotonicity of $\log$ on $(0,\infty)$. $\square$

**Theorem 6.3 (Arithmetic Chernoff bound).** For every $k$,
$$|B_k|^{5}\cdot 8^{k} \;\le\; 243^{k}.$$

*Proof sketch.* Let $q = \lceil 3k/5\rceil$, so that $5q \ge 3k$ and, by Lemmas 6.1 and 6.2, $s_k(n) \ge q$ for every $n \in B_k$. Then by monotonicity and Corollary 4.4,
$$|B_k|\cdot 2^{q} \;=\; \sum_{n\in B_k} 2^{q} \;\le\; \sum_{n \in B_k} 2^{\,s_k(n)} \;\le\; \sum_{n<2^k} 2^{\,s_k(n)} \;=\; 3^{k}.$$
Also $8^{k} = 2^{3k} \le 2^{5q}$. Therefore
$$|B_k|^{5}\cdot 8^{k} \;\le\; |B_k|^{5}\cdot 2^{5q} \;=\; \bigl(|B_k|\,2^{q}\bigr)^{5} \;\le\; \bigl(3^{k}\bigr)^{5} \;=\; 243^{k}. \qquad\square$$

**Theorem 6.4 (Exponential decay).** For every $k$,
$$\rho_k^{\,5} \;=\; \left(\frac{|B_k|}{2^{k}}\right)^{5} \;\le\; \left(\frac{243}{256}\right)^{k}.$$
Since $243/256 < 1$, the non-contracting density decays exponentially in $k$, at rate at most $(243/256)^{1/5} \approx 0.98963$ per unit scale. This is strictly stronger than the polynomial Chebyshev bound of Theorem 5.6.

*Proof.* Divide Theorem 6.3 by $(2^k)^5 \cdot 8^k = 32^k\cdot 8^k = 256^k$. $\square$

**Remark 6.5 (Sharpness).** The tilt $x=2$ is convenient, not optimal. The classical Chernoff optimisation for a $\mathrm{Binomial}(k,\tfrac12)$ variable exceeding $k\theta$ gives rate $e^{-D(\theta\|1/2)}$ with
$$D(\theta\|\tfrac12) = \theta\log(2\theta) + (1-\theta)\log\bigl(2(1-\theta)\bigr) \approx 0.034703,$$
so the true rate should be $e^{-D} \approx 0.96590$, attained at the tilt $x^{*} = \theta/(1-\theta) \approx 1.7095$. Since Theorem 4.2 holds for real $x$, obtaining this only requires the one-variable optimisation $\min_{x>0}(1+x)/x^{\theta}$.

---

## 7. From residue classes to descent of integers

We now convert the density statements into statements about actual integers, using the affine structure of Theorem 2.3.

**Theorem 7.1 (Contraction is an exact arithmetic inequality).** $\Lambda_k(s) > 0 \iff 3^{s} < 2^{k}$.

*Proof.* $k\log 2 > s\log 3 \iff \log(2^k) > \log(3^s) \iff 2^k > 3^s$. $\square$

**Lemma 7.2 (Crude uniform growth bound).** For $x \ge 1$, $T(x) \le 2x$ and $T(x) \ge 1$; hence $T^{k}(x) \le 2^{k}x$ for all $k$.

*Proof.* If $x$ is even, $T(x) = x/2 \le 2x$. If $x$ is odd, $T(x) = (3x+1)/2 \le 2x$ since $3x+1 \le 4x$ for $x\ge1$. Positivity is immediate, and the iterate bound follows by induction. $\square$

**Theorem 7.3 (Affine descent).** Let $r, m \ge 0$ with $3^{\,s_k(r)} < 2^{k}$ and $m > T^{k}(r)$. Then
$$T^{k}\!\left(r + 2^{k}m\right) \;<\; r + 2^{k}m .$$

*Proof.* By Theorem 2.3, $T^{k}(r+2^k m) = T^{k}(r) + 3^{\,s_k(r)}m$. Since $3^{\,s_k(r)} \le 2^k - 1$,
$$T^{k}(r) + 3^{\,s_k(r)}m \;\le\; T^{k}(r) + (2^{k}-1)m \;=\; 2^{k}m + \bigl(T^{k}(r) - m\bigr) \;<\; 2^k m \;\le\; r + 2^k m,$$
using $m > T^{k}(r)$. $\square$

**Theorem 7.4 (Uniform descent threshold).** Let $n \ge 2^{k}\cdot 4^{k} = 8^{k}$ and suppose $r = n \bmod 2^{k}$ satisfies $3^{\,s_k(r)} < 2^{k}$. Then $T^{k}(n) < n$.

*Proof sketch.* Write $n = r + 2^k m$ with $m = \lfloor n/2^k\rfloor$. The hypothesis $n \ge 2^k 4^k$ gives $m \ge 4^k$. By Lemma 7.2, $T^{k}(r) \le 2^{k}r < 2^{k}\cdot 2^{k} = 4^{k} \le m$ (the case $r = 0$ being handled separately since $T^k(0)=0$). Theorem 7.3 applies. $\square$

**Definition 7.5 (Descending classes).** Let $D_k = \{0,\dots,2^k-1\}\setminus B_k$ be the set of contracting residues. By Theorems 7.1 and 7.4, every $n \ge 8^k$ with $n \bmod 2^k \in D_k$ satisfies $T^{k}(n) < n$.

**Theorem 7.6 (Density-one descent among residue classes).** For every $k \ge 1$,
$$\frac{|D_k|}{2^{k}} \;\ge\; 1 - \frac{1}{4\delta^{2}k} \;\xrightarrow[k\to\infty]{}\; 1 .$$
Combining instead with Theorem 6.4, $|D_k|/2^k \ge 1 - (243/256)^{k/5}$.

*Proof.* $|D_k| = 2^k - |B_k|$; apply Theorem 5.6 (resp. Theorem 6.4). $\square$

---

## 8. Natural density of non-descending integers

Density among residue classes is not, a priori, density among integers counted by size. The conversion is elementary but must be done carefully; the two error sources are the boundary effects of intersecting an arithmetic progression with $[1,N]$, and the finitely many integers below the threshold $8^k$.

**Definition 8.1.** For $k, N \ge 0$ let
$$\mathcal{N}_k(N) \;=\; \bigl\{\, n \in [1,N] \;:\; T^{k}(n) \not< n \,\bigr\}$$
be the set of integers up to $N$ that fail to descend in $k$ accelerated steps.

**Lemma 8.2 (Counting a residue class).** For every $r$, $\#\{n \in [1,N] : n \equiv r \pmod{2^k}\} \le N/2^{k} + 1$.

*Proof.* The map $n \mapsto \lfloor n/2^{k}\rfloor$ is injective on the class and lands in $\{0,1,\dots,\lfloor N/2^k\rfloor\}$. $\square$

**Lemma 8.3 (Master counting bound).** Every $n \in \mathcal{N}_k(N)$ either lies in a non-contracting class ($n \bmod 2^k \in B_k$) or satisfies $n < 8^{k}$. Consequently
$$|\mathcal{N}_k(N)| \;\le\; |B_k|\left(\frac{N}{2^{k}}+1\right) + 8^{k}.$$

*Proof.* The dichotomy is Theorem 7.4 in contrapositive form. Then apply Lemma 8.2 to each of the $|B_k|$ bad classes and bound the sub-threshold integers trivially. $\square$

**Theorem 8.4 (Density bound at scale $k$).** For all $k \ge 1$ and $N \ge 1$,
$$\frac{|\mathcal{N}_k(N)|}{N} \;\le\; \rho_k \;+\; \frac{|B_k| + 8^{k}}{N} \;\le\; \frac{1}{4\delta^{2}k} \;+\; \frac{|B_k| + 8^{k}}{N}.$$

*Proof.* Divide Lemma 8.3 by $N$ and apply Theorem 5.6. $\square$

**Theorem 8.5 (Natural-density descent).** For every $\varepsilon > 0$ there exists a scale $k \ge 1$ such that, for all sufficiently large $N$,
$$\frac{|\mathcal{N}_k(N)|}{N} \;<\; \varepsilon .$$
In words: for every $\varepsilon$, there is a fixed number of steps $k$ after which all but an $\varepsilon$-fraction of the integers have strictly decreased.

*Proof sketch.* Choose $k$ with $1/(4\delta^2 k) < \varepsilon/2$ (possible since $\delta>0$). With $k$ now fixed, the quantity $C_k = |B_k| + 8^{k}$ is a constant, so $C_k/N < \varepsilon/2$ for all $N$ beyond an explicit threshold. Theorem 8.4 completes the proof. $\square$

**Theorem 8.6 (Exponentially small failure density at matched scale).** Taking $N = 64^{k}$,
$$\frac{|\mathcal{N}_k(64^{k})|}{64^{k}} \;\le\; \rho_k \;+\; \frac{2}{8^{k}}, \qquad\text{hence}\qquad \left(\frac{|\mathcal{N}_k(64^{k})|}{64^{k}} - \frac{2}{8^{k}}\right)^{5} \;\le\; \left(\frac{243}{256}\right)^{k}.$$

*Proof sketch.* In Lemma 8.3 with $N = 64^k = 8^k\cdot 8^k$, the correction term is $(|B_k| + 8^{k})/64^{k}$; using $|B_k|\le 2^k \le 8^k$ this is at most $2\cdot 8^{k}/64^{k} = 2/8^{k}$. The second display follows by raising the resulting inequality to the (odd, hence monotone) fifth power and applying Theorem 6.4. $\square$

Thus both the spectral term $\rho_k$ and the boundary correction $2\cdot 8^{-k}$ are exponentially small in $k$: at scale $k$ and horizon $64^k$, the proportion of integers that fail to descend is exponentially small.

---

## 9. Algorithms

The theory is entirely constructive, and each ingredient corresponds to a short algorithm.

**Algorithm A (Parity word and odd-step count).** Given $k, n$: iterate $T$ $k$ times, recording $n \bmod 2$ at each step and accumulating the word and the count. Cost: $O(k)$ arithmetic operations on integers of size $O(\log n + k)$ bits.

**Algorithm B (Verification of the bijection at scale $k$).** Compute $w_k(n)$ for all $n < 2^k$ and check that the multiset of outputs is $\{0,\dots,2^k-1\}$. Cost: $O(k\,2^{k})$. This exhibits Theorem 2.7 concretely and, by counting digit sums, verifies the binomial law $\#\{n : s_k(n)=s\} = \binom{k}{s}$.

**Algorithm C (Direct evaluation of the parity transform).** Compute $F_k(j) = \sum_{n<2^k} e^{2\pi i j w_k(n)/2^k}$ numerically for all $j$. Cost $O(4^{k})$ naively, or $O(k2^k)$ via the fast Fourier transform applied to the indicator vector of the word distribution. The output is $2^k$ at $j=0$ and (numerically) zero elsewhere, confirming Theorem 3.2.

**Algorithm D (Non-contracting density).** For each $s$, the number of residues with $s_k(n)=s$ is $\binom{k}{s}$ (Theorem 4.2), so
$$\rho_k = 2^{-k}\!\!\sum_{s\,:\,3^{s}\ge 2^{k}}\!\!\binom{k}{s} = 2^{-k}\!\!\sum_{s \ge \lceil k\theta\rceil}\!\!\binom{k}{s},$$
computable in $O(k)$ big-integer operations — with *no enumeration of residues at all*. This is a striking practical consequence of the exact spectral gap: an intrinsically $2^k$-sized statistic collapses to a closed-form binomial tail.

**Algorithm E (Descent certification).** Given $k$ and $n$, compute $r = n \bmod 2^k$, then $s_k(r)$ by Algorithm A; if $3^{\,s_k(r)} < 2^{k}$ and $n \ge 8^{k}$, output "descends", certified by Theorem 7.4 with no need to iterate $n$ itself. Cost: $O(k)$.

---

## 10. Discussion

### 10.1 What has been established

The results above give an unconditional, quantitative, error-term-free version of the Collatz coin-flip heuristic at every fixed $2$-adic scale, and convert it into genuine descent statements of density one, with explicit constants throughout:

- the critical odd-step density $\theta = \log 2/\log 3 \approx 0.63093$;
- the spectral margin $\delta = \theta - \tfrac12 \approx 0.13093$;
- the Chebyshev constant $1/(4\delta^2) \approx 14.58$;
- the geometric-mean drift $\log(2/\sqrt3) \approx 0.1438$ per step;
- the Chernoff decay rate $(243/256)^{1/5} \approx 0.98963$ per scale;
- the descent threshold $8^{k}$.

### 10.2 What is not established

Nothing here proves the Collatz conjecture, and the gap is structural rather than technical.

**Non-composability.** Each theorem controls the *first $k$ steps* of an integer. After those $k$ steps the integer has moved to a new position whose residue mod $2^k$ is not controlled by the original residue. Chaining $k$-step descents requires knowing that the image of a large-density set is again largely inside the good set, i.e. a mixing statement for the induced map on $\mathbb{Z}/2^k\mathbb{Z}$. The exact spectral gap says nothing about this coupling, because it is a statement about a single scale.

**Density is not "all".** A single exceptional orbit — an integer whose residues at every scale conspire to lie in the exponentially shrinking bad set — would refute the conjecture without contradicting any theorem above. Indeed, Corollary 2.9 guarantees that at every scale such classes exist; what is not known is whether a single integer can lie in them coherently at all scales.

**The measure is dyadic, not archimedean.** Theorem 8.5 converts dyadic density to natural density at a fixed scale, but the two orders of quantifiers ("for each $\varepsilon$ there is a $k$" versus "for each $k$, eventually in $N$") do not commute for free.

### 10.3 Relation to known results

The affine transport formula and the parity-vector bijection are classical (Terras; Everett). What the present development adds is: (i) the explicitly Fourier-analytic formulation, with the exact vanishing $F_k(j)=0$ isolated as the organising theorem and contrasted with the provable failure of the archimedean analogue; (ii) the exact second-moment identity $\sum_{n<2^k}(2s_k(n)-k)^2 = k2^k$ and the exact criticality $\sum_{n<2^k}3^{s_k(n)}=4^k$ in a form usable as input to concentration; and (iii) an explicit, elementary path from those identities to an $8^{k}$-threshold descent theorem and a natural-density statement, with every constant computed. Density-one descent results for Collatz are known by other routes; the point here is the completeness and explicitness of the chain, and the identification of the exact spectral gap as its single source.

### 10.4 Broader lesson

The negative and positive results together make a methodological point. An exponential-sum approach to an arithmetic dynamical system can fail not because the system is unstructured but because the *dual group is wrong*. The Collatz map is a $2$-adic object: its natural characters are the characters of $\mathbb{Z}/2^k\mathbb{Z}$, not of $\mathbb{R}/\mathbb{Z}$. When the correct dual group is used, the cancellation is not merely square-root but total. One expects the same phenomenon in other maps defined by congruence-dependent affine branches — for instance the generalised $qn+r$ maps — where the same bijection argument should apply verbatim whenever the odd-branch multiplier is coprime to the modulus base.

---

## 11. Future work

1. **Sharp large-deviation rate.** Replace the integral tilt $x=2$ by the optimal tilt $x^{*} = \theta/(1-\theta) \approx 1.7095$ to obtain $\rho_k \le C\,e^{-kD(\theta\|1/2)}$ with $D(\theta\|1/2)\approx 0.034703$, i.e. rate $\approx 0.96590$, and prove the matching lower bound $\rho_k \asymp k^{-1/2}e^{-kD}$ from Stirling. Since $\sum_{n<2^k}x^{s_k(n)}=(1+x)^k$ holds for all real $x$, only the one-variable optimisation $\min_{x>0}(1+x)x^{-\theta}$ is missing.

2. **An $O(1)$ descent threshold.** Conjecturally, if $r = n\bmod 2^k$ satisfies $3^{\,s_k(r)}<2^{k}$ then $T^{k}(n)<n$ already for every $n \ge 2^{k}$ — equivalently $T^{k}(r) \le r+2$ for every contracting $r<2^k$. The crude bound $T^{k}(r)\le 2^{k}r$ used above is exponentially lossy; solving the affine recursion exactly gives $2^{k}T^{k}(r) = 3^{s}r + c(w)$ with an intercept $c(w)=\sum_i 3^{\,s-i}2^{\,j_i}$ that is itself controlled by the contraction condition. Exhaustive search finds $T^{k}(r)-r \le 2$ for every contracting $r<2^k$ with $k\le 13$.

3. **A spectral characterisation of cycles.** A cycle of length $k$ with $s$ odd steps corresponds to a fixed point of the affine branch, forcing $2^{k}-3^{s}$ to divide the intercept $c(w)$. Formulating cycle-existence as a vanishing condition for a twisted parity transform, and combining it with transcendence bounds on $|2^{k}-3^{s}|$, is the natural next target.

4. **Multi-scale coupling.** The decisive open problem is to control the joint distribution of $(w_k(n), w_k(T^{k}n))$. Any nontrivial mixing bound here would allow the $k$-step density results to be iterated, which is the only visible route from these methods towards the full conjecture.

5. **Generalised $qn+r$ maps.** The bijection argument uses only that the odd-branch multiplier $3$ is odd. The same theory should therefore give exact spectral gaps, exact binomial moments, and density-one descent for all maps $n \mapsto (qn+r)/2$ on odd inputs with $q$ odd, with critical density $\log 2/\log q$ and margin $\log 2/\log q - 1/2$, contracting exactly when $q < 4$.
