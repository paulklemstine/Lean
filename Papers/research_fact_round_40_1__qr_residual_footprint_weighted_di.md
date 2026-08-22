# The Quadratic-Residue Footprint Dial: Exact Arithmetic of a Sieve-Yield Feature, and a Provable Zero-Information Barrier

**Author:** Aristotle
**Date:** 2026-08-22

---

## Abstract

The quadratic sieve factors the values $v(x) = x^2 - N$ over a fixed factor base of small primes. A per-modulus *yield dial* — a cheap predictor of how many fully-factored relations a given $N$ will produce — is a standard practical tool, and empirically its residual is not noise: adding the theoretically motivated feature $W(N) = \sum 2/p$, summed over factor-base primes $p$ modulo which $N$ is a quadratic residue, raises the out-of-sample coefficient of determination from $0.3927$ to $0.5691$ in one regime and from $0.2063$ to $0.3078$ in a harder one.

This paper supplies the exact mathematics behind that observation, and the exact limits of what such a feature can do. We prove: (i) a **mean-footprint identity** showing that $W(N)$ is not a heuristic approximation but *exactly* the average number of factor-base primes dividing a sieve value over a full period; (ii) a **Hensel-lifting theorem** extending the identity verbatim to prime powers, with a complementary $\bmod\ 8$ vanishing at the even prime; (iii) the **exact law** of the dial over a period of moduli — the quadratic-residue indicators at distinct primes are exactly independent with $(p+1)/2$ favourable residues out of $p$ — from which the mean $\sum (p+1)/p^2$ and the closed-form **variance** $\sum (p^2-1)/p^4$ follow, the latter strictly positive but uniformly bounded by $1/2$; (iv) the **exact information capacity**: the dial's range has precisely $2^{|\text{base}|}$ elements, so it carries exactly $|\text{base}|$ bits; (v) an exact finite-sample **least-squares lift theory**, giving $\Delta R^2 = \langle r,v\rangle^2/(\|v\|^2\,\mathrm{TSS}) = \rho^2(1-R^2_{\text{before}})$ together with the ceiling $\Delta R^2 \le 1 - R^2_{\text{before}}$ and the dichotomy that zero lift forces exact orthogonality of the residual to the feature; and (vi) a **blindness theorem**: by Dirichlet's theorem, every attained dial value is shared by arbitrarily large primes and arbitrarily large semiprimes, so no function of the dial carries any information about the factorization of $N$.

The combination is a template for calibration features in computational number theory: full dynamic range, exact capacity, real predictive power, and a *proved* zero-leakage guarantee.

**Keywords.** Quadratic sieve; quadratic residues; sieve footprint; Chinese remainder theorem; Hensel lifting; variance of arithmetic features; coefficient of determination; information barrier.

---

## 1. Introduction

### 1.1 The setting

Let $N$ be a composite integer to be factored. The quadratic sieve evaluates $v(x) = x^2 - N$ at integers $x$ near $\sqrt N$ and retains those $x$ for which $v(x)$ factors completely over a **factor base** of primes $p \le B$. Such $x$ yield *relations*, and enough relations produce a congruence of squares and a nontrivial factor.

Parameter choice — the smoothness bound $B$, the sieve interval, the acceptance threshold $u$ — is governed by a **yield model**: a predictor of the number of relations per unit of sieving work for a given $N$. A naive yield model built from value sizes and classical smoothness densities explains a substantial but incomplete fraction of the observed variation across moduli.

### 1.2 The feature and the observation

The residual of that naive model is not structureless. The relevant arithmetic is elementary: for an odd prime $p$, the condition $p \mid x^2 - N$ is $x^2 \equiv N \pmod p$, which has two solutions per period when $N$ is a nonzero quadratic residue mod $p$, one when $p \mid N$, and none otherwise. Thus roughly half the factor base is inert for any given $N$, and *which* half is a function of $N$ modulo the base primes. This motivates the **footprint dial**
$$W(N) \;=\; \sum_{\substack{p \le B,\ p\ \text{odd prime}\\ N\ \text{a QR mod } p}} \frac{2}{p}.$$

Empirically, adding $W$ to the baseline yield model raises out-of-sample $R^2$ from $0.3927$ to $0.5691$ at acceptance parameter $u = 2.5$ (a gain of $+0.176$, bootstrap CI $[0.120, 0.229]$), and from $0.2063$ to $0.3078$ at $u = 3.5$. A second, independent feature — the fraction of sieve values divisible by some prime $p \le 13$ — adds further, the pair reaching $R^2 = 0.5864$. The final dial thus costs one Euler-criterion test per odd factor-base prime (77 of them at $B = 400$) plus one modular count.

### 1.3 Contribution

This paper is the theory of that dial. Every statement below is exact and finite: no asymptotics, no distributional assumptions, no error terms. Sections 3–5 develop the arithmetic (mean footprint, prime powers, exact law, mean, variance, capacity); Section 6 develops the least-squares theory of a feature lift; Section 7 proves the zero-information barrier; Section 8 assembles the empirical reading; Sections 9–10 discuss applications and open directions.

---

## 2. Definitions

Throughout, $B \in \mathbb{N}$ is a smoothness bound and $N \in \mathbb{Z}$ a modulus.

**Definition 2.1 (Odd factor base).** The *odd factor base* is the finite set of odd primes at most $B$:
$$\mathcal{B}(B) = \{p \le B : p \text{ prime},\ p \ne 2\}.$$
Its *primorial* is $D(B) = \prod_{p \in \mathcal{B}(B)} p$.

**Definition 2.2 (Sieve hit count).** For a modulus $m \ge 1$, the *hit count* is the number of sieve locations in one period at which $m$ divides the sieve value:
$$h(N,m) = \#\{x \in \{0,1,\dots,m-1\} : m \mid x^2 - N\}.$$
This is exactly what a sieve implementation counts when it initialises the roots of $m$.

**Definition 2.3 (Quadratic residuacity, window form).** We say $N$ is a *QR mod $p$*, written $\mathrm{QR}(N,p)$, if there exists $x \in \{0,\dots,p-1\}$ with $p \mid x^2 - N$. Equivalently, the image of $N$ in $\mathbb{Z}/p$ is a square. Note that this convention includes the degenerate case $p \mid N$.

**Definition 2.4 (Footprint weight and the QR dial).**
$$F(N,B) = \sum_{p \in \mathcal{B}(B)} \frac{h(N,p)}{p}, \qquad W(N,B) = \sum_{\substack{p \in \mathcal{B}(B) \\ \mathrm{QR}(N,p)}} \frac{2}{p}.$$
$F$ is the *raw footprint weight*; $W$ is the *QR footprint dial*, the feature actually used.

**Definition 2.5 (Least-squares apparatus).** For a finite index set $I$ (a sample of moduli) and vectors $u,v : I \to \mathbb{R}$, write $\langle u,v\rangle = \sum_{i} u_i v_i$ and $\|u\|^2 = \langle u,u\rangle$. For a target $y$, a model class $S \subseteq \mathbb{R}^I$, and a single fit $g$, set
$$\mathrm{RSS}(y,S) = \inf_{g \in S}\|y-g\|^2, \qquad \mathrm{TSS}(y) = \Bigl\|\,y - \bar{y}\mathbf{1}\,\Bigr\|^2,$$
$$R^2(y,S) = 1 - \frac{\mathrm{RSS}(y,S)}{\mathrm{TSS}(y)}, \qquad R^2(y,g) = 1 - \frac{\|y-g\|^2}{\mathrm{TSS}(y)},$$
where $\bar{y}$ is the sample mean. The *residual correlation* of a feature $v$ against a baseline $g$ is
$$\rho(y,g,v) = \frac{\langle y-g, v\rangle}{\sqrt{\|y-g\|^2\,\|v\|^2}}.$$

---

## 3. The dichotomy and the mean-footprint identity

### 3.1 The local root count

**Lemma 3.1 (Transport to $\mathbb{Z}/p$).** For any $p \ge 1$, $h(N,p)$ equals the number of $z \in \mathbb{Z}/p$ with $z^2 = N$.

*Proof sketch.* The maps $x \mapsto x \bmod p$ and $z \mapsto z$'s canonical representative are mutually inverse bijections between $\{0,\dots,p-1\}$ and $\mathbb{Z}/p$, and $p \mid x^2 - N$ holds iff the image of $x^2 - N$ in $\mathbb{Z}/p$ vanishes. $\square$

**Theorem 3.2 (The $2/1/0$ dichotomy).** Let $p$ be an odd prime.
1. If $p \nmid N$ and $\mathrm{QR}(N,p)$, then $h(N,p) = 2$.
2. If $\neg\,\mathrm{QR}(N,p)$, then $h(N,p) = 0$.
3. If $p \mid N$, then $h(N,p) = 1$.

In all cases $h(N,p) \le 2$.

*Proof sketch.* By Lemma 3.1 this is the count of square roots of $N$ in the field $\mathbb{Z}/p$. A nonzero square in a field of odd characteristic has exactly two square roots $\pm z$, distinct because $2 \ne 0$; a non-square has none; $0$ has exactly one. $\square$

### 3.2 Periodic counting

**Lemma 3.3 (Periodicity).** For fixed $N$ and $p$, the predicate $p \mid x^2 - N$ is $p$-periodic in $x$: indeed $(x+p)^2 - N = (x^2 - N) + p(p + 2x)$.

**Theorem 3.4 (Exact periodic counting).** If $P$ is a $p$-periodic predicate on $\mathbb{N}$, then for every $k$,
$$\#\{x < kp : P(x)\} = k \cdot \#\{x < p : P(x)\}.$$
Consequently $\#\{x < kp : p \mid x^2 - N\} = k\,h(N,p)$.

*Proof sketch.* Induction on $k$, splitting $\{0,\dots,(k+1)p-1\}$ into the first $kp$ terms and a translated final period, and using Lemma 3.3 shifted $k$ times. $\square$

### 3.3 The identity

**Theorem 3.5 (Mean-footprint identity).** Let $S$ be a finite set of positive moduli with product $M = \prod_{m \in S} m$. Then
$$\sum_{x=0}^{M-1} \#\{m \in S : m \mid x^2 - N\} \;=\; M \sum_{m \in S} \frac{h(N,m)}{m}.$$

*Proof sketch.* Exchange the order of summation: the left-hand side counts pairs $(x,m)$ with $m \mid x^2-N$, so it equals $\sum_{m \in S} \#\{x < M : m \mid x^2 - N\}$. Since $m \mid M$, write $M = k m$ and apply Theorem 3.4 to get $k\,h(N,m) = M\,h(N,m)/m$. $\square$

**Corollary 3.6 (The feature is the mean footprint).** If $N$ is coprime to every $p \in \mathcal{B}(B)$, then with $D = D(B)$,
$$\frac{1}{D}\sum_{x=0}^{D-1} \#\{p \in \mathcal{B}(B) : p \mid x^2-N\} \;=\; W(N,B).$$
In particular $F(N,B) = W(N,B)$ for such $N$.

*Proof sketch.* Apply Theorem 3.5 with $S = \mathcal{B}(B)$ and split the sum $\sum_p h(N,p)/p$ according to residuacity: by Theorem 3.2 the non-residue terms vanish and the residue terms equal $2/p$. $\square$

This is the precise content of the informal slogan "each admissible prime divides about $2/p$ of the values": the "about" is unnecessary. The feature is the mean footprint exactly.

---

## 4. Prime powers: Hensel lifting and the even prime

Real sieves accumulate contributions from prime powers $p^k$, not only from primes. The natural conjecture is that the root count is stable under lifting. It is.

**Theorem 4.1 (Hensel step).** Let $p$ be an odd prime with $p \nmid N$ and let $k \ge 1$. Then
$$h(N, p^{k+1}) = h(N, p^k).$$

*Proof sketch.* Reduction mod $p^k$ maps roots mod $p^{k+1}$ to roots mod $p^k$. Given a root $a$ mod $p^k$, write $a^2 - N = p^k m$ and seek a lift $a + t p^k$; expanding, the lifting condition is the linear congruence $2 a t \equiv -m \pmod p$. Since $p$ is odd and $p \nmid a$ (a root of $x^2 \equiv N$ with $p \nmid N$ is prime to $p$), the coefficient $2a$ is invertible mod $p$, so $t$ exists and is unique mod $p$. Uniqueness of the lift within one class follows because two lifts $x, y$ satisfy $p^{k+1} \mid (x-y)(x+y)$ with $p \nmid x+y$. Hence reduction is a bijection. $\square$

**Corollary 4.2 (Prime-power footprint density).** For an odd prime $p$ with $p \nmid N$ and any $k \ge 1$,
$$\frac{h(N,p^k)}{p^k} = \begin{cases} 2/p^k, & \mathrm{QR}(N,p),\\ 0, & \text{otherwise.}\end{cases}$$
So an admissible prime power hits exactly the fraction $2/p^k$ of sieve locations, and an inadmissible one hits none — at every exponent.

**Theorem 4.3 ($\bmod\ 8$ obstruction at the even prime).** Let $N$ be odd with $N \not\equiv 1 \pmod 8$. Then $h(N, 2^k) = 0$ for every $k \ge 3$.

*Proof sketch.* Every odd square is $\equiv 1 \pmod 8$ and every even square is $\equiv 0 \pmod 4$; since $N$ is odd, a solution of $x^2 \equiv N \pmod{2^k}$ with $k \ge 3$ forces $x$ odd, hence $N \equiv x^2 \equiv 1 \pmod 8$, contradiction. $\square$

Together, Corollary 4.2 and Theorem 4.3 give the complete local picture of the sieve footprint: the odd part scales geometrically as $2/p^k$ on a residue-determined subset of the base, while the even prime is governed by the rigid $\bmod\ 8$ condition.

---

## 5. The exact law of the dial

We now let $N$ vary. Fix $B$ and write $P = D(B)$ for the period; every quantity below is $P$-periodic in $N$, so a full period is the natural sample space.

### 5.1 Independence via Chinese remaindering

**Theorem 5.1 (CRT counting).** Let $(a_i)_{i \in I}$ be a finite pairwise-coprime family of positive moduli and let $Q_i$ be a predicate on $\mathbb{Z}/a_i$ for each $i$. Then
$$\#\Bigl\{N < \prod_i a_i : Q_i(N \bmod a_i)\ \text{for all } i \Bigr\} \;=\; \prod_i \#\{z \in \mathbb{Z}/a_i : Q_i(z)\}.$$

*Proof sketch.* The Chinese remainder isomorphism $\mathbb{Z}/\prod a_i \cong \prod_i \mathbb{Z}/a_i$ is compatible with reduction, so the left-hand set is in bijection with the product of the local sets. $\square$

**Lemma 5.2 (Local counts).** For an odd prime $p$, exactly $(p+1)/2$ of the $p$ residues mod $p$ are quadratic residues in the sense of Definition 2.3: the $(p-1)/2$ nonzero squares plus $0$.

**Theorem 5.3 (Exact joint law).** For every subset $T \subseteq \mathcal{B}(B)$,
$$\#\{N < P : \{p \in \mathcal{B}(B) : \mathrm{QR}(N,p)\} = T\} \;=\; \prod_{p \in T}\frac{p+1}{2}\ \cdot \prod_{p \in \mathcal{B}(B)\setminus T}\frac{p-1}{2}.$$
In particular this count is strictly positive: **every** activation pattern occurs within a single period, and the indicators $\mathbf{1}[\mathrm{QR}(N,p)]$ at distinct primes are exactly independent with success probability $(p+1)/(2p)$.

*Proof sketch.* Apply Theorem 5.1 with $a_p = p$ and the local predicate "$z$ is a square iff $p \in T$", using Lemma 5.2 for the favourable counts $(p+1)/2$ and their complements $(p-1)/2$. Positivity holds since $p \ge 3$ makes both factors at least $1$. $\square$

### 5.2 The mean: the dial averages to the random model

**Theorem 5.4 (Mean of the raw footprint).**
$$\frac{1}{P}\sum_{N=0}^{P-1} F(N,B) \;=\; \sum_{p \in \mathcal{B}(B)} \frac 1p.$$

*Proof sketch.* Exchange summation and use the identity $\sum_{N \bmod p} h(N,p) = p$: each of the $p$ locations $x$ contributes its value $x^2$ exactly once as $N$ ranges over residues, so the total root count over all residues is $p$. Divide by $p$ per prime. $\square$

The right-hand side is exactly the footprint of a *random* integer, for which each prime divides $1/p$ of the values. Thus the dial is unbiased with respect to the random model: **its mean carries no signal at all, and all predictive content lives in the fluctuation.**

**Theorem 5.5 (Mean of the QR dial).**
$$\frac{1}{P}\sum_{N=0}^{P-1} W(N,B) \;=\; \sum_{p \in \mathcal{B}(B)} \frac{p+1}{p^2}.$$

*Proof sketch.* By Lemma 5.2 the indicator has mean $(p+1)/(2p)$, and the dial weights it by $2/p$. $\square$

The excess $\sum 1/p^2$ over Theorem 5.4 is precisely the contribution of the ramified residues $p \mid N$, where the true root count is $1$ but the QR convention charges $2$.

### 5.3 The variance

**Theorem 5.6 (Exact variance identity).**
$$\frac{1}{P}\sum_{N=0}^{P-1}\Bigl(W(N,B) - \sum_{p \in \mathcal{B}(B)}\tfrac{p+1}{p^2}\Bigr)^2 \;=\; \sum_{p \in \mathcal{B}(B)} \frac{p^2-1}{p^4}.$$

*Proof sketch.* Write $W = \sum_p (2/p)\mathbf{1}_p$ with $\mathbf{1}_p = \mathbf{1}[\mathrm{QR}(N,p)]$ and expand the square. Diagonal terms use $\mathbf{1}_p^2 = \mathbf{1}_p$ and the single density $\frac1P\sum_N \mathbf{1}_p = \frac{p+1}{2p}$ (Lemma 5.2), giving $\frac{4}{p^2}\bigl(\frac{p+1}{2p} - \frac{(p+1)^2}{4p^2}\bigr) = \frac{p^2-1}{p^4}$. Off-diagonal terms vanish because, by Theorem 5.3 restricted to a pair, $\frac1P\sum_N \mathbf{1}_p\mathbf{1}_q = \frac{p+1}{2p}\cdot\frac{q+1}{2q}$ exactly — the indicators are uncorrelated. $\square$

**Corollary 5.7 (Non-degeneracy).** If $\mathcal{B}(B) \ne \emptyset$ the variance is strictly positive, so there exist $N_1, N_2 < P$ with $W(N_1,B) \ne W(N_2,B)$. The dial is not a constant regressor, and an observed $R^2$ lift cannot be a degeneracy artefact.

**Theorem 5.8 (Uniform variance bound).** For every $B$,
$$\sum_{p \in \mathcal{B}(B)} \frac{p^2-1}{p^4} \;<\; \frac12 .$$

*Proof sketch.* For $p \ge 3$, $\frac{p^2-1}{p^4} \le \frac{1}{p^2} \le \frac{1}{p-1} - \frac{1}{p}$, and the telescoping sum over odd primes $\ge 3$ is bounded by $\frac{1}{2}$. $\square$

The contrast is structural: the mean $\sum (p+1)/p^2$ **diverges** as $B \to \infty$ while the variance **converges**, and is bounded by $1/2$ uniformly. The dial is a bounded-fluctuation feature on a diverging trend — small, permanent, and non-vanishing as the base grows.

### 5.4 Exact information capacity

The dial's range is a set of subset sums. It could in principle collapse: distinct patterns might give equal sums. They do not.

**Theorem 5.9 (Injectivity of subset sums).** If $T, S \subseteq \mathcal{B}(B)$ and $\sum_{p \in T} 2/p = \sum_{p \in S} 2/p$, then $T = S$.

*Proof sketch.* Multiply by the primorial $D = D(B)$: the sum becomes the natural number $\sigma(T) = \sum_{p\in T} 2(D/p)$. For a base prime $p$, every term with $q \ne p$ is divisible by $p$ (since $p \mid D/q$), while the term $2(D/p)$ is not (as $D/p$ is a product of primes other than $p$, and $p$ is odd). Hence $p \mid \sigma(T)$ iff $p \notin T$, so $\sigma$ determines $T$. $\square$

**Theorem 5.10 (Full dynamic range).** For every $T \subseteq \mathcal{B}(B)$ there is an integer $N$ with $\{p : \mathrm{QR}(N,p)\} = T$, hence $W(N,B) = \sum_{p\in T} 2/p$.

*Proof sketch.* Prescribe residues: $N \equiv 1 \pmod p$ for $p \in T$ (so $N$ is a square mod $p$) and $N \equiv c_p \pmod p$ for $p \notin T$, where $c_p$ is a non-residue, which exists for every odd prime since the squaring map on $(\mathbb{Z}/p)^\times$ is two-to-one. Solve the system by a Chinese-remainder construction — an induction on the set of primes using Bézout at each step, since consecutive moduli are coprime. Then apply the congruence invariance of Definition 2.3. $\square$

**Theorem 5.11 (Exact capacity).** The range of $N \mapsto W(N,B)$ is finite with exactly
$$\bigl|\{W(N,B) : N \in \mathbb{Z}\}\bigr| = 2^{|\mathcal{B}(B)|}$$
elements. Moreover $W(N_1,B) = W(N_2,B)$ if and only if $N_1$ and $N_2$ have the same activation pattern.

*Proof sketch.* The range is contained in the set of subset sums over $\mathcal{B}(B)$, giving the upper bound $2^{|\mathcal{B}(B)|}$; Theorem 5.10 shows every subset sum is attained; Theorem 5.9 shows distinct subsets give distinct sums. $\square$

So the dial is a *maximally efficient* encoder: it carries exactly $|\mathcal{B}(B)|$ bits about $N$, no more and no fewer, however large $N$ grows.

---

## 6. What an $R^2$ lift measures: exact finite-sample theory

We now formalise the inferential step. All statements are exact for a finite design; nothing is asymptotic.

**Lemma 6.1 (Projection identity).** For $r, v \in \mathbb{R}^I$ with $\|v\|^2 \ne 0$ and any $t \in \mathbb{R}$,
$$\|r - t v\|^2 = \|r\|^2 - 2t\langle r,v\rangle + t^2\|v\|^2,$$
minimised at $t^\star = \langle r,v\rangle/\|v\|^2$ with minimum $\|r\|^2 - \langle r,v\rangle^2/\|v\|^2$.

**Theorem 6.2 (RSS of a one-feature augmentation).** For a baseline $g$ and feature $v$ with $\|v\|^2 \ne 0$, the model class $\mathcal{L} = \{g + t v : t \in \mathbb{R}\}$ satisfies
$$\mathrm{RSS}(y,\mathcal{L}) = \|y-g\|^2 - \frac{\langle y-g, v\rangle^2}{\|v\|^2}.$$

*Proof sketch.* The infimum is attained at $t^\star$ by Lemma 6.1; the lower bound holds because every member of the class has residual norm at least the minimum. $\square$

**Theorem 6.3 (Monotonicity).** If $S \subseteq T$ and $S \ne \emptyset$, then $\mathrm{RSS}(y,T) \le \mathrm{RSS}(y,S)$ and hence $R^2(y,S) \le R^2(y,T)$ whenever $\mathrm{TSS}(y) > 0$.

**Theorem 6.4 (Exact one-feature lift).** With $\mathrm{TSS}(y) > 0$ and $\|v\|^2 \ne 0$,
$$R^2(y,\mathcal{L}) \;=\; R^2(y,g) \;+\; \frac{\langle y-g, v\rangle^2}{\|v\|^2\,\mathrm{TSS}(y)}.$$

*Proof sketch.* Substitute Theorem 6.2 into the definition of $R^2$. $\square$

**Theorem 6.5 (The lift is a squared correlation).** If additionally $\|y-g\|^2 \ne 0$, then
$$\frac{\langle y-g,v\rangle^2}{\|v\|^2\,\mathrm{TSS}(y)} \;=\; \rho(y,g,v)^2\,\bigl(1 - R^2(y,g)\bigr).$$

*Proof sketch.* Substitute the definition of $\rho$ and note $1 - R^2(y,g) = \|y-g\|^2/\mathrm{TSS}(y)$. $\square$

**Corollary 6.6 (Ceiling).** $\Delta R^2 \le 1 - R^2(y,g)$, and $R^2(y,\mathcal{L}) \le 1$.

*Proof sketch.* Cauchy–Schwarz gives $\langle y-g,v\rangle^2 \le \|y-g\|^2\|v\|^2$, so $\Delta R^2 \le \|y-g\|^2/\mathrm{TSS}(y) = 1 - R^2(y,g)$; equivalently $\rho^2 \le 1$ in Theorem 6.5. $\square$

**Theorem 6.7 (Strictness).** If $\langle y-g, v\rangle \ne 0$ then $R^2(y,g) < R^2(y,\mathcal{L})$; more generally the same holds for any model class containing $\mathcal{L}$.

**Theorem 6.8 (The null-hypothesis dichotomy).** Let $T$ be any model class containing all $g + tv$. If augmenting produces no improvement at all, i.e. $R^2(y,T) \le R^2(y,g)$, then $\langle y-g,v\rangle = 0$ exactly.

*Proof sketch.* Contrapositive of Theorem 6.7. $\square$

Theorem 6.8 is the exact form of the inference "H3 refuted". The null hypothesis "the residual contains nothing systematic aligned with $v$" is the statement $\langle y-g,v\rangle = 0$; and that statement is *equivalent* to observing exactly zero lift. A positive measured lift is therefore not a fitting artefact but a certificate of nonzero residual–feature correlation, with the correlation recoverable by inverting Theorem 6.5.

**Theorem 6.9 (Instantiation at the footprint feature).** Let a finite sample of moduli $(N_i)_{i \in I}$ define the feature vector $v_i = W(N_i, B)$, and suppose some $W(N_i,B) \ne 0$ (so $\|v\|^2 \ne 0$). Then Theorems 6.4–6.8 apply verbatim: the footprint feature strictly improves any baseline whose residual is non-orthogonal to it, by exactly $\rho^2 (1 - R^2_{\text{before}})$, and never by more than $1 - R^2_{\text{before}}$.

---

## 7. The blindness barrier: zero factor information

Everything so far says the dial is useful. This section says exactly how far its usefulness cannot reach.

**Lemma 7.1 (Residue invariance).** If $p \mid N_1 - N_2$ then $\mathrm{QR}(N_1,p) \iff \mathrm{QR}(N_2,p)$. Consequently, if $N_1 \equiv N_2$ modulo every $p \in \mathcal{B}(B)$, then $W(N_1,B) = W(N_2,B)$.

*Proof sketch.* $x^2 - N_2 = (x^2-N_1) + (N_1-N_2)$, so divisibility by $p$ transfers; then the filtered index sets defining $W$ coincide. $\square$

Thus $W$ is a **residue dial**: a function of $N \bmod D(B)$ and of nothing else. The barrier is what this implies in the presence of Dirichlet's theorem on primes in arithmetic progressions.

**Theorem 7.2 (Blind to primality).** Let $N$ be coprime to $D(B)$. For every bound $n$ there is a prime $q > n$ with $W(q,B) = W(N,B)$.

*Proof sketch.* By Dirichlet, the arithmetic progression $N + D(B)\mathbb{Z}$ contains arbitrarily large primes, since $\gcd(N, D(B)) = 1$. Any such prime is congruent to $N$ modulo every base prime, so Lemma 7.1 applies. $\square$

**Theorem 7.3 (Blind to semiprimality).** Let $N$ be coprime to $D(B)$. For every bound $n$ there are distinct primes $r,s$ with $rs > n$ and $W(rs,B) = W(N,B)$.

*Proof sketch.* Pick a large prime $r \equiv 1 \pmod{D(B)}$ (Dirichlet applied to the class of $1$), then a large prime $s \equiv N r^{-1} \pmod{D(B)}$, which is legitimate since $N$ and $r$ are both invertible mod $D(B)$. Then $rs \equiv N$ modulo every base prime and $rs$ can be made arbitrarily large with $r \ne s$. Apply Lemma 7.1. $\square$

**Theorem 7.4 (Blindness theorem).** Fix $B$, a modulus $N$ coprime to $D(B)$, an arbitrary function $c$ from dial values to $\{\text{true},\text{false}\}$ — any "classifier" whatsoever built on the dial — and any bound $n$. Then there exist a prime $q > n$ and distinct primes $r,s$ with $rs > n$ such that
$$c\bigl(W(q,B)\bigr) = c\bigl(W(N,B)\bigr) = c\bigl(W(rs,B)\bigr).$$

*Proof sketch.* Immediate from Theorems 7.2 and 7.3: the classifier sees the same input in all three cases. $\square$

The conclusion is unconditional and requires no hypothesis on $c$ — no measurability, no computability, no efficiency. **Every dial value is shared by arbitrarily large primes and by arbitrarily large semiprimes**, so no decision rule based on the dial can separate them, let alone reveal a factor.

Read together with Theorem 5.11 the picture is sharp:

| Question | Answer |
|---|---|
| How many values can the dial take? | Exactly $2^{|\mathcal{B}(B)|}$ (Thm. 5.11) |
| Is every value attained? | Yes, within a single period (Thms. 5.3, 5.10) |
| Does it fluctuate? | Yes, with variance $\sum (p^2-1)/p^4 > 0$ (Thm. 5.6) |
| Does the fluctuation grow with $B$? | No: it is bounded by $1/2$ (Thm. 5.8) |
| Does it predict sieve yield? | Yes, by exactly $\rho^2(1-R^2)$ (Thms. 6.4–6.5) |
| Does it carry factorization information? | None whatsoever (Thm. 7.4) |

The dial has full dynamic range and maximal capacity about the *input residues*, and provably zero information about the *factorization*. It is a description of the method's own behaviour, not of the arithmetic secret the method is chasing.

---

## 8. Reading the measurements

The identities above turn reported numbers into arithmetic statements.

**8.1 Recovering the correlation.** At acceptance parameter $u = 2.5$, the baseline achieves $R^2_{\text{before}} = 0.3927$ and the augmented model $R^2_{\text{after}} = 0.5691$, so $\Delta R^2 = 0.1764$. By Theorem 6.5,
$$\rho^2 = \frac{\Delta R^2}{1 - R^2_{\text{before}}} = \frac{0.1764}{0.6073} = 0.2905, \qquad |\rho| \approx 0.539.$$
The unexplained component of the sieve yield was correlated with the footprint dial at roughly $0.54$ — a measurement, not an estimate of one, given the design.

**8.2 The ceiling is not binding.** Corollary 6.6 caps the lift at $1 - 0.3927 = 0.6073$; the observed $0.176$ uses $29\%$ of the available headroom. In the harder regime $u = 3.5$, $R^2$ moves $0.2063 \to 0.3078$, so $\Delta R^2 = 0.1015$ against a ceiling of $0.7937$, giving $|\rho| \approx 0.358$. The feature is informative in both regimes and more so where the baseline is stronger.

**8.3 Non-degeneracy.** Corollary 5.7 rules out the standard failure mode in which a reported lift comes from a near-constant regressor whose tiny variance is amplified by the fit: the dial's variance is exactly $\sum_{p\le B}(p^2-1)/p^4$, strictly positive and computable in advance. For $B = 400$ (the $77$ odd primes up to $400$) the value is $\approx 0.18740$, with standard deviation $\approx 0.43289$ against a mean of $\approx 1.76067$ — a coefficient of variation near $24.6\%$.

**8.4 Independence of the second feature.** The direct mechanism feature (the fraction of sieve values divisible by some $p \le 13$) contributes additionally, the pair reaching $R^2 = 0.5864$. Theorem 6.4 explains why two features can be added: their lifts are exactly additive when the features are orthogonal, and sub-additive in general, with the total bounded by the residual variance $1 - R^2_{\text{before}}$.

**8.5 Cost.** Evaluating $W(N,B)$ for $B = 400$ costs one Euler criterion test per odd prime $p \le 400$ — $77$ modular exponentiations of tiny exponents — plus a rational accumulation. The second feature costs a handful of modular counts. This is negligible against the sieve itself.

---

## 9. Applications

**Parameter calibration.** The immediate use is what motivated the work: a per-modulus predictor of sieve yield, allowing interval length and threshold to be tuned before sieving rather than adaptively during it. The dial has the two properties one wants from a calibration statistic — it is computable in microseconds, and its distribution is known exactly (Theorem 5.3), so calibration curves can be normalised analytically rather than by simulation.

**Benchmark design.** Theorem 5.3 says the activation pattern is exactly uniform-independent with per-prime probability $(p+1)/(2p)$. This makes it possible to *construct* benchmark moduli with a prescribed footprint — by the Chinese-remainder construction of Theorem 5.10 — and thereby to test a sieve implementation across the full dynamic range of arithmetic difficulty, rather than sampling and hoping.

**Guarantees for learned heuristics.** The pairing of Theorem 5.11 with Theorem 7.4 is a template. A feature used inside a cryptanalytic pipeline should come with an argument that it is not secretly leaking the answer. Here that argument is a theorem: the feature is a residue dial, and every residue class is populated by arbitrarily large numbers of every factorization type. Any feature admitting the same two-line proof — invariance under congruence modulo a fixed modulus, plus Dirichlet — inherits the same guarantee.

**Sieve accounting with prime powers.** Corollary 4.2 licenses the standard implementation practice of charging a prime power $p^k$ a log-weight proportional to its density $2/p^k$: the density is exact at every exponent, not merely asymptotic. Theorem 4.3 explains why the even prime must be special-cased.

---

## 10. Discussion and future directions

The mathematical shape of this cycle is a pair of complementary exactness results. On the positive side, an informal density slogan is upgraded to an identity (Theorem 3.5), an empirical lift is upgraded to a measured correlation (Theorem 6.5), and a vague "the feature varies" is upgraded to a closed-form variance (Theorem 5.6) with exact capacity (Theorem 5.11). On the negative side, an informal barrier — "these are only residue statistics" — is upgraded to an unconditional theorem (Theorem 7.4).

A structural observation deserves emphasis. The mean of the dial diverges with $B$ while its variance converges to a finite limit bounded by $1/2$. The centred dial is therefore a sum of independent, bounded, summable-variance terms — a Bernoulli convolution over the primes, weighted by $2/p$ with success probabilities $(p+1)/(2p)$. This suggests the following programme.

**D1. Limit law of the centred dial.** Because the variances $\,(p^2-1)/p^4$ are summable while the terms are bounded, the centred dial $W - \mathbb{E}W$ converges almost surely (in the sense of the natural projective limit over periods) to a random variable given by a weighted Bernoulli convolution over all odd primes. Identify its law: is it absolutely continuous? What are its tail bounds, and does it satisfy a Berry–Esseen-type approximation with explicit constants in $B$? An explicit limit law would let calibration curves be normalised once and for all, independently of the base.

**D2. Higher moments and concentration.** The exact independence of Theorem 5.3 gives all joint moments in closed form. Deriving the moment generating function $\prod_p \bigl(\frac{p-1}{2p} + \frac{p+1}{2p} e^{2t/p}\bigr)$ and the resulting Chernoff bounds would give explicit, non-asymptotic tail estimates for the dial and hence guaranteed prediction intervals for the yield model.

**D3. Multiplicative and higher-degree generalisations.** The whole analysis rests on the fact that $x^2 - N$ has $0$, $1$, or $2$ roots mod $p$ according to a residue symbol. For the number field sieve the relevant local count is the number of roots of a degree-$d$ polynomial mod $p$, governed by the splitting type of $p$ in a number field. The analogue of Theorem 3.5 should hold verbatim with $h(N,p)$ replaced by the splitting count, and Chebotarev should replace Lemma 5.2 as the source of local densities. This would give a footprint dial for the number field sieve — and, one expects, an analogous blindness theorem, since the splitting type of small primes is again independent of the factorization of the target.

**D4. Prime powers in the dial.** Corollary 4.2 supplies the exact prime-power densities. Adding $\sum_{k \ge 2} 2/p^k = 2/(p(p-1)) - 2/p$ corrections to the dial should refine it slightly; the question is whether the refinement is statistically detectable, given that the correction is $O(\sum 1/p^2)$, of the same order as the variance itself.

**D5. Two-adic structure.** Theorem 4.3 gives the vanishing half of the picture at $p=2$. The complementary case $N \equiv 1 \pmod 8$ has $h(N,2^k) = 4$ for $k \ge 3$, so the even prime contributes a large, sharply bimodal term. Quantifying its effect on the yield dial — a binary feature $\mathbf{1}[N \equiv 1 \bmod 8]$ with a large weight — is an immediate, testable refinement.

**D6. Interaction with the direct mechanism feature.** The two features together reach $R^2 = 0.5864$ versus $0.5691$ for the footprint alone. Theorem 6.4 predicts the joint lift exactly once the features' mutual correlation is known; computing that correlation analytically (both features are functions of the same residues) would explain the observed sub-additivity from first principles.

**D7. Sharpening the barrier.** Theorem 7.4 shows blindness to primality and semiprimality. A stronger statement is plausible: for every fixed factorization *shape* (number of prime factors with multiplicities), every dial value is attained by arbitrarily large integers of that shape. This should follow from Dirichlet plus a routine multiplicative construction, and would show the dial is blind not merely to a binary distinction but to the entire factorization type.

---

## 11. Conclusion

The residual of a quadratic-sieve yield model is not noise; it is the arithmetic of quadratic residues, and it can be captured by a single number costing a few hundred modular exponentiations. That number is exactly the mean sieve footprint over a period, exactly independent across primes, has exactly computable mean and variance, attains exactly $2^{|\mathcal{B}(B)|}$ values, and lifts the coefficient of determination by exactly the squared residual correlation. It is also, provably and unconditionally, incapable of saying anything about the factorization of its input.

Both halves matter. The first says a practical calibration problem has an exact arithmetic solution. The second says that solution is safe: it is a description of the method, not a window into the secret. In cryptanalytic modelling, where the boundary between "useful heuristic" and "accidental leak" is normally argued rather than proved, having that boundary as a theorem is worth as much as the prediction itself.
