# Seed-Robustness of the Quadratic-Residue Variance Law: Exact Replication Identities and the $k$-Prime Euler Score

**Aristotle**

*October 2026*

---

## Abstract

Let $M = p_1 \cdots p_k$ be a product of distinct odd primes and let $r_M(N) = \#\{x \bmod M : x^2 \equiv N\}$ be the local square-root count, which is the local divisibility rate of $x^2 - N$ in sieve factoring. Over the units $N \bmod M$, $r_M$ has mean exactly $1$ and variance exactly $2^k - 1$. We call this the *variance law*: the quadratic-residue restriction never changes the mean local rate, it only redistributes it. This paper does two things. First, it gives an exact theory of how a Monte-Carlo estimate of this statistic changes when the random seed changes. Model a seed as $n$ independent uniform draws from $G = (\mathbb{Z}/M\mathbb{Z})^\times$. Then, as exact counting identities over the finite space of all seeds, the centred sample sum $S$ has total $0$ (no seed bias) and total square $n\,\varphi(M)^n(2^k-1)$, and two independent seeds have total squared drift exactly $2n\,\varphi(M)^{2n}(2^k-1)$. We also derive a Chebyshev tail bound for the drift and show that the plug-in variance estimator is unbiased up to the Bessel factor $(n-1)/n$. Second, it extends the two-prime predictor law of earlier work to every sieving depth: for any integer weights $w_i$, the Euler-criterion score $\sum_i w_i r_{p_i}(N)$ has mean exactly $\sum_i w_i$ and variance exactly $\sum_i w_i^2$ over the units mod $M$. Both results come from a single mechanism, the exact cancellation of cross terms between independent centred coordinates over a finite product. Together they explain why a fresh-seed replication experiment reproduced every headline figure of the variance law: seed-robustness is a consequence of the law, not an additional hypothesis.

**Keywords:** quadratic residues, Euler's criterion, Chinese remainder theorem, variance law, reproducibility, Monte-Carlo replication, sieve yield prediction, finite abelian groups.

---

## 1. Introduction

### 1.1 Motivation

Sieve factoring algorithms, from the quadratic sieve onward, look for values of $x^2 - N$ that are smooth, meaning they factor completely over a set of small primes. A small odd prime $p \nmid N$ divides $x^2 - N$ for exactly $r_p(N)$ residue classes of $x$ modulo $p$, where

$$r_p(N) = \#\{x \bmod p : x^2 \equiv N \pmod p\} = 1 + \left(\frac{N}{p}\right),$$

and $\left(\frac{N}{p}\right)$ is the Legendre symbol, computed by Euler's criterion $N^{(p-1)/2} \equiv \left(\frac{N}{p}\right) \pmod p$. The function $r_p$ is therefore the *local divisibility rate* at $p$. For a modulus $M = p_1\cdots p_k$ the Chinese Remainder Theorem gives $r_M(N) = \prod_i r_{p_i}(N)$.

A previous study established the *variance law* (restated as Theorem 2.3 below): over units mod $M$, $r_M$ has mean $1$ and variance $2^k - 1$. Its slogan was *"the QR bite is variance, not mean."* An unrestricted random integer has, on average, the same local rate as a value of $x^2 - N$. Restricting to quadratic residues concentrates that rate into rare jackpots of size $2^k$ and leaves most residues with nothing.

### 1.2 The replication audit

The same research programme had just retracted a result that came from seed luck. So the variance-law experiment was re-run with a fresh pseudo-random seed (20260826 instead of 20260821) and every headline was compared. All of them replicated:

| Quantity | Original seed | Fresh seed |
|---|---|---|
| Smoothness rate, squares vs random (cell 1) | — | $0.12859$ vs $0.12786$ |
| Smoothness rate, squares vs random (cell 2) | — | $0.02004$ vs $0.02023$ |
| Smoothness rate, squares vs random (cell 3) | — | $0.12854$ vs $0.12585$ |
| Smoothness rate, squares vs random (cell 4) | — | $0.02004$ vs $0.01869$ |
| QR-restricted random penalty | $21$–$56\times$ lower | $32$–$200\times$ lower |
| Per-$N$ correlation, yield vs QR count | $0.504/0.452/0.483/0.401$ | $0.503/0.415/0.480/0.403$ |
| Decile spread low/high, $u = 2.5$ | — | $0.076$–$0.082$ / $0.186$–$0.188$ |
| Decile spread low/high, $u = 3.5$ | — | $0.006$–$0.008$ / $0.039$–$0.043$ |

The largest per-$N$ correlation drift is $0.037$. Here $u$ is the usual smoothness parameter (log of the value over log of the smoothness bound). The fresh seed confirms that squares and unrestricted randoms have equal ensemble smoothness (the mean is unchanged), that QR-restricted randoms are much less smooth, and that the per-$N$ spread is stable.

### 1.3 Contributions

The aim of this paper is to explain the replication, not just record it. We prove:

1. **A generic replication layer** (Section 3). For any finite set $A$ and centred score $f : A \to \mathbb{Z}$, we give exact identities for the first and second moments of the sample sum over all seeds of length $n$, for the squared drift between two independent seeds, and for the plug-in variance. We also give a counting form of Chebyshev's inequality.
2. **The QR replication law** (Section 4). Specialising to $A = (\mathbb{Z}/M)^\times$ and $f = r_M - 1$ gives no seed bias, an exact single-seed spread $n\varphi(M)^n(2^k-1)$, an exact two-seed drift $2n\varphi(M)^{2n}(2^k-1)$, a drift tail bound, and unbiasedness of the measured variance. We also note a square-relabelling symmetry of the statistic.
3. **The $k$-prime Euler score** (Section 5). We prove a general orthogonality theorem over finite products and use the Chinese Remainder Theorem to show that $\sum_i w_i r_{p_i}(N)$ has mean $\sum w_i$ and variance $\sum w_i^2$ for every $k$. This generalises the two-prime case and describes the regressor of the per-$N$ yield predictor at every sieving depth.

All results are exact identities between integers. The space of seeds is finite, so "expectation over seeds" is a finite sum divided by the number of seeds, and nothing is asymptotic.

---

## 2. Preliminaries: the variance law

Throughout, $G$ denotes a finite abelian group written multiplicatively. $|G|$ is its order and $1$ its identity.

**Definition 2.1 (root count, two-torsion).** For $g \in G$, the *root count* is $r(g) = \#\{y \in G : y^2 = g\}$. The *two-torsion count* is $t(G) = r(1) = \#\{y \in G : y^2 = 1\}$. The *centred QR score* is $f(g) = r(g) - 1$.

**Lemma 2.2 (group layer).** For every finite abelian group $G$,
$$\sum_{g\in G} \bigl(r(g) - 1\bigr) = 0, \qquad \sum_{g \in G}\bigl(r(g) - 1\bigr)^2 = |G|\,\bigl(t(G) - 1\bigr).$$

*Proof.* The squaring map $\sigma(y) = y^2$ is a homomorphism because $G$ is abelian, and its kernel has $t = t(G)$ elements. Each fibre of $\sigma$ over its image is a coset of the kernel. So $r(g) = t$ if $g$ is a square and $r(g) = 0$ otherwise, and the image has $|G|/t$ elements. Hence $\sum_g r(g) = |G|$ (every $y$ is counted once, in the fibre of $y^2$) and $\sum_g r(g)^2 = (|G|/t)\,t^2 = t|G|$. Expanding $(r-1)^2 = r^2 - 2r + 1$ gives $t|G| - 2|G| + |G| = |G|(t-1)$. $\square$

**Theorem 2.3 (variance law).** Let $M = p_1\cdots p_k$ be a product of $k$ distinct odd primes and $G = (\mathbb{Z}/M\mathbb{Z})^\times$, so $|G| = \varphi(M)$. Then $t(G) = 2^k$. For a unit $N$, $r(N)$ coincides with $r_M(N) = \#\{x \bmod M: x^2 \equiv N\}$. Consequently, over the units $N \bmod M$,
$$\frac{1}{\varphi(M)}\sum_N r_M(N) = 1,\qquad \frac{1}{\varphi(M)}\sum_N \bigl(r_M(N) - 1\bigr)^2 = 2^k - 1.$$

*Proof.* If $N$ is a unit then any $x$ with $x^2 \equiv N$ is a unit, so the two counts agree. By the Chinese Remainder Theorem, $G \cong \prod_i (\mathbb{Z}/p_i)^\times$. Each factor is cyclic of even order $p_i - 1$, so it has exactly two solutions of $y^2 = 1$, namely $\pm 1$. Hence $t(G) = 2^k$, and Lemma 2.2 finishes the proof. $\square$

For a single odd prime $p$ the variance is $1$, matching $r_p = 1 + \left(\frac{\cdot}{p}\right)$ with a $\pm1$-valued symbol of mean $0$.

---

## 3. The generic replication layer

Let $A$ be a finite set and $f : A \to \mathbb{Z}$ a score.

**Definition 3.1 (seed, sample sum).** A *seed of length $n$* is a tuple $x = (x_1,\dots,x_n) \in A^n$. The *sample sum* is $S_f(x) = \sum_{i=1}^n f(x_i)$. The score is *centred* if $\sum_{a \in A} f(a) = 0$.

Uniform sampling with replacement is the uniform distribution on $A^n$, which has $|A|^n$ points. Every statement below is a finite identity, and dividing by $|A|^n$ (or $|A|^{2n}$ for pairs) gives the corresponding expectation.

The basic tool is a decomposition of a seed of length $n+1$ into its first draw and the remaining $n$ draws:
$$\sum_{x \in A^{n+1}} F(x) = \sum_{a \in A}\ \sum_{y \in A^n} F(a, y_1, \dots, y_n), \qquad S_f(a, y) = f(a) + S_f(y). \tag{3.1}$$

**Theorem 3.2 (unbiasedness of the sample sum).** For every $n \ge 1$,
$$\sum_{x\in A^n} S_f(x) = n\,|A|^{n-1}\sum_{a\in A} f(a).$$
In particular, if $f$ is centred then $\sum_x S_f(x) = 0$ for every $n \ge 0$.

*Proof sketch.* By (3.1),
$$\sum_{x \in A^{m+1}} S_f(x) = |A|^m \sum_a f(a) + |A| \sum_{y\in A^m} S_f(y).$$
Induction on $m$ gives the closed form. $\square$

**Theorem 3.3 (exact replication variance).** If $f$ is centred then for every $n\ge1$,
$$\sum_{x\in A^n} S_f(x)^2 = n\,|A|^{n-1}\sum_{a \in A} f(a)^2.$$

*Proof sketch.* Expand $S_f(a,y)^2 = f(a)^2 + 2f(a)S_f(y) + S_f(y)^2$ and sum over $a \in A$, $y \in A^m$. The first term gives $|A|^m\sum f^2$. The cross term factors as $2\left(\sum_a f(a)\right)\left(\sum_y S_f(y)\right) = 0$, because $f$ is centred. The last term gives $|A|\sum_y S_f(y)^2$. So
$$\textstyle\sum_{A^{m+1}} S_f^2 = |A|^m \sum f^2 + |A|\sum_{A^m} S_f^2,$$
and induction finishes the proof. $\square$

Dividing by $|A|^n$ and by $n^2$: *the sample mean of $n$ draws has variance exactly $\mathrm{Var}(f)/n$.* The cancellation of the cross terms is exact, not asymptotic.

**Theorem 3.4 (two-seed drift law).** If $f$ is centred then for every $n \ge 0$,
$$\sum_{(x,y)\in A^n\times A^n}\bigl(S_f(x) - S_f(y)\bigr)^2 = 2\,|A|^n\sum_{x \in A^n} S_f(x)^2.$$

*Proof sketch.* Expand the square. The two diagonal terms each give $|A|^n\sum_x S_f(x)^2$. The cross term is $-2\left(\sum_x S_f(x)\right)\left(\sum_y S_f(y)\right) = 0$ by Theorem 3.2. $\square$

So two independent replications disagree, in mean square, by exactly twice the spread of one replication. Independent seeds have no covariance.

**Theorem 3.5 (unbiased variance estimation).** If $f$ is centred then for every $n\ge1$,
$$\sum_{x\in A^n}\Bigl(n\sum_{i=1}^n f(x_i)^2 - S_f(x)^2\Bigr) = n(n-1)\,|A|^{n-1}\sum_{a\in A} f(a)^2.$$

*Proof sketch.* Apply Theorem 3.2 to the score $f^2$ and Theorem 3.3 to $f$, then subtract. $\square$

The bracket is $n^2$ times the empirical (population-normalised) variance of the sample. Its mean over seeds is therefore $\frac{n-1}{n}\mathrm{Var}(f)$, the classical Bessel factor.

**Lemma 3.6 (Chebyshev, counting form).** Let $B$ be a finite set, $g : B\to\mathbb{Z}_{\ge0}$ and $c \in \mathbb{Z}$. Then
$$\#\{b \in B : g(b) \ge c\}\cdot c \le \sum_{b\in B} g(b).$$

*Proof.* Sum the inequality $c \le g(b)$ over the subset where it holds, then extend to all of $B$ using $g \ge 0$. $\square$

---

## 4. The QR replication law

We now take $A = G$ a finite abelian group and $f = r - 1$ the centred QR score. By Lemma 2.2, $f$ is centred and $\sum f^2 = |G|(t-1)$.

**Theorem 4.1 (QR replication, any finite abelian group).** Let $n \ge 1$ and $S(x) = \sum_{i=1}^n (r(x_i) - 1)$ for $x \in G^n$. Then:

1. *(No seed bias)* $\displaystyle\sum_{x\in G^n} S(x) = 0$.
2. *(Single-seed spread)* $\displaystyle\sum_{x\in G^n} S(x)^2 = n\,|G|^n\,(t-1)$.
3. *(Two-seed drift)* $\displaystyle\sum_{(x,y)\in G^n\times G^n} \bigl(S(x)-S(y)\bigr)^2 = 2n\,|G|^{2n}\,(t-1)$.
4. *(Drift tail)* For every integer $c$,
$$\#\bigl\{(x,y) : (S(x) - S(y))^2 \ge c^2\bigr\}\cdot c^2 \le 2n\,|G|^{2n}\,(t-1).$$
5. *(Measured variance is reproducible)* $\displaystyle\sum_{x\in G^n}\Bigl(n\sum_i (r(x_i)-1)^2 - S(x)^2\Bigr) = n(n-1)\,|G|^n\,(t-1)$.

*Proof.* Item 1 is Theorem 3.2. For item 2, Theorem 3.3 gives $n|G|^{n-1}\cdot|G|(t-1)$. Item 3 follows from Theorem 3.4 and item 2. Item 4 is Lemma 3.6 applied to $g(x,y) = (S(x) - S(y))^2$ together with item 3. Item 5 is Theorem 3.5 combined with Lemma 2.2. $\square$

**Theorem 4.2 (the QR variance law is seed-robust).** Let $M$ be the product of a finite set of $k$ distinct odd primes and $n \ge 1$. Over all seeds $x \in ((\mathbb{Z}/M)^\times)^n$ and all seed pairs:
$$\sum_x S(x) = 0,\qquad \sum_x S(x)^2 = n\,\varphi(M)^n\,(2^k - 1),\qquad \sum_{x,y}\bigl(S(x)-S(y)\bigr)^2 = 2n\,\varphi(M)^{2n}\,(2^k-1).$$
Equivalently, write $\bar r(x) = \frac1n\sum_i r_M(x_i)$ for the sample mean of the root count. Then
$$\mathbb{E}\bigl[\bar r\bigr] = 1, \qquad \mathbb{E}\bigl[(\bar r - 1)^2\bigr] = \frac{2^k-1}{n}, \qquad \mathbb{E}\bigl[(\bar r(x) - \bar r(y))^2\bigr] = \frac{2(2^k-1)}{n}.$$
Also, the fraction of seed pairs whose sample sums differ by at least $c$ is at most $2n(2^k - 1)/c^2$.

*Proof.* Substitute $|G| = \varphi(M)$ and $t = 2^k$ (Theorem 2.3) into Theorem 4.1. $\square$

**Corollary 4.3 (single prime).** For an odd prime $p$ and $n \ge 1$:
$$\sum_{x} S(x)^2 = n(p-1)^n,\qquad \sum_{x,y}(S(x)-S(y))^2 = 2n(p-1)^{2n}.$$
The per-draw variance is exactly $1$.

**Proposition 4.4 (square-relabelling symmetry).** For all $y, g \in G$, $r(y^2 g) = r(g)$. Consequently, $S(y^2x_1,\dots,y^2x_n) = S(x_1,\dots,x_n)$ for every seed and every $y \in G$.

*Proof.* The maps $z\mapsto zy^{-1}$ and $z \mapsto zy$ are mutually inverse bijections between $\{z : z^2 = y^2 g\}$ and $\{z : z^2 = g\}$. $\square$

So the statistic sees a seed only up to the action of the subgroup of squares, which is one structural reason why "which seed" matters less than "how many draws".

**Interpretation.** The population quantities of the variance law (mean $1$, variance $2^k-1$) are exact constants. A seed enters only through a sample average, and its fluctuation is governed by that same variance divided by $n$. *Seed-robustness is a consequence of the variance law, not an extra hypothesis.* For instance, with $k = 4$ and $n = 10^5$ the predicted root-mean-square drift of $\bar r$ between two seeds is $\sqrt{30/10^5}\approx 0.0173$.

---

## 5. The $k$-prime Euler score

The replication also showed that the per-$N$ correlation between yield and the QR-prime count is stable. That correlation is the training target of a per-$N$ yield predictor. We now determine the exact distribution of the natural family of predictors at every depth $k$.

### 5.1 Orthogonality over finite products

Let $G_0,\dots,G_{k-1}$ be finite sets and $f_i : G_i\to\mathbb{Z}$. On the product $\prod_i G_i$, consider the additive score $x \mapsto \sum_i f_i(x_i)$.

**Theorem 5.1 (centring over a product).** If $\sum_{a\in G_i} f_i(a) = 0$ for each $i$, then
$$\sum_{x\in\prod_i G_i}\ \sum_{i} f_i(x_i) = 0.$$

**Theorem 5.2 (orthogonality over a product).** Suppose that for each $i$, $\sum_{a} f_i(a) = 0$ and $\sum_{a} f_i(a)^2 = |G_i|\,v_i$. Then
$$\sum_{x\in\prod_i G_i}\Bigl(\sum_i f_i(x_i)\Bigr)^2 = \Bigl(\prod_i |G_i|\Bigr)\sum_i v_i.$$

*Proof sketch of both.* Induct on $k$. Split $x = (a, y)$ with $a \in G_0$ and $y\in\prod_{i\ge1}G_i$, so that the score is $f_0(a) + T(y)$ with $T(y) = \sum_{i \ge 1} f_i(y_i)$. For Theorem 5.1, the sum is $|{\textstyle\prod_{i\ge1}}G_i|\sum_a f_0(a) + |G_0|\sum_y T(y) = 0 + 0$. For Theorem 5.2, expand
$$(f_0(a) + T(y))^2 = f_0(a)^2 + 2f_0(a)T(y) + T(y)^2.$$
Summing, the first term gives $\left(\prod_{i\ge1}|G_i|\right)|G_0|v_0$. The cross term factors as $2\left(\sum_a f_0(a)\right)\left(\sum_y T(y)\right) = 0$. The last term gives $|G_0|\left(\prod_{i\ge1}|G_i|\right)\sum_{i\ge1}v_i$ by the induction hypothesis. Adding these gives the claim. $\square$

These are the multi-coordinate analogues of Theorems 3.2 and 3.3. Theorem 3.3 is the special case where all $G_i$ equal $A$ and all $f_i$ equal $f$.

### 5.2 Weighted QR scores over products of groups

**Theorem 5.3 (weighted QR score).** Let $G_0,\dots,G_{k-1}$ be finite abelian groups with two-torsion counts $t_i$, and let $w_0,\dots,w_{k-1}\in\mathbb{Z}$. Then
$$\sum_{x\in\prod_i G_i}\sum_i w_i\bigl(r(x_i) - 1\bigr) = 0,\qquad \sum_{x\in\prod_i G_i}\Bigl(\sum_i w_i\bigl(r(x_i)-1\bigr)\Bigr)^2 = \Bigl(\prod_i |G_i|\Bigr)\sum_i w_i^2\,(t_i - 1).$$

*Proof.* Apply Theorems 5.1 and 5.2 with $f_i = w_i(r - 1)$. These are centred, and $\sum f_i^2 = w_i^2|G_i|(t_i-1)$ by Lemma 2.2, so $v_i = w_i^2(t_i-1)$. $\square$

### 5.3 Transfer to residues modulo $M$

Let $p_0,\dots,p_{k-1}$ be pairwise distinct primes, hence pairwise coprime, and $M = \prod_i p_i$. The Chinese Remainder Theorem gives a ring isomorphism $\mathbb{Z}/M \cong \prod_i\mathbb{Z}/p_i$. Restricting it to unit groups gives a group isomorphism
$$\Psi : (\mathbb{Z}/M)^\times \xrightarrow{\ \sim\ } \prod_i (\mathbb{Z}/p_i)^\times,\qquad N \mapsto (N \bmod p_i)_i.$$
Because $\Psi$ is a bijection, sums over units mod $M$ can be computed coordinatewise, and $|(\mathbb{Z}/M)^\times| = \varphi(M) = \prod_i (p_i - 1)$.

**Theorem 5.4 (the $k$-prime Euler-criterion score).** Let $p_0,\dots,p_{k-1}$ be pairwise distinct odd primes, $M = \prod_i p_i$, and $w_0,\dots,w_{k-1}\in\mathbb{Z}$. Define, for units $N \bmod M$,
$$\mathcal{S}(N) = \sum_{i} w_i\, r_{p_i}(N \bmod p_i) = \sum_i w_i\left(1 + \left(\frac{N}{p_i}\right)\right).$$
Then
$$\sum_{N} \mathcal{S}(N) = \varphi(M)\sum_i w_i, \qquad \sum_N\Bigl(\mathcal{S}(N) - \sum_i w_i\Bigr)^2 = \varphi(M)\sum_i w_i^2.$$
That is, $\mathcal{S}$ has mean exactly $\sum_i w_i$ and variance exactly $\sum_i w_i^2$.

*Proof.* Write $\mathcal{S}(N) - \sum_i w_i = \sum_i w_i\,(r(\Psi(N)_i) - 1)$. Re-index the sum over $N$ through the bijection $\Psi$ and apply Theorem 5.3 with $G_i = (\mathbb{Z}/p_i)^\times$. Each $t_i = 2$ because $p_i$ is odd, so $w_i^2(t_i - 1) = w_i^2$. The product of the $|G_i|$ is $\varphi(M)$. The centred total is $0$, which rearranges to the mean statement. $\square$

**Corollary 5.5 (unweighted QR count).** With all $w_i = 1$, the QR-prime count $\sum_i r_{p_i}(N)$ (equivalently $k + \sum_i\left(\frac{N}{p_i}\right)$) has mean $k$ and variance $k$ over the units mod $M$.

**Remarks.**
1. *No mean shift at any depth.* Whatever the weights, the QR information never changes the predictor's mean. This matches the ensemble-equality finding at the level of the score.
2. *Additive dispersion.* Each prime adds exactly $w_i^2$ to the variance. There are no cross terms, so the Legendre symbols at distinct primes are pairwise uncorrelated over units mod $M$. This is the second-moment shadow of the independence given by the Chinese Remainder Theorem.
3. *Relation to the variance law.* The multiplicative statistic $r_M = \prod_i r_{p_i}$ has variance $2^k - 1 = \prod_i(1+1) - 1$, which grows exponentially in $k$. The additive score has variance $k$, which grows linearly. Both follow from the same orthogonality.

---

## 6. Algorithms and numerical checks

### 6.1 Exact enumeration of the replication identities

**Algorithm A (exhaustive seed moments).** *Input:* modulus $M$, seed length $n$.
1. Tabulate $r_M(N)$ for every unit $N$ by squaring every $x \bmod M$ ($O(M)$).
2. Form the multiset of deviations $f(N) = r_M(N) - 1$.
3. Compute the distribution of $S$ on $G^n$ by $n$-fold convolution of the distribution of $f$. Since $f$ takes only the two values $t-1$ and $-1$, $S$ is a shifted binomial variable, so this costs $O(n^2)$.
4. Read off $\sum S$, $\sum S^2$, the pair drift $2|G|^n\sum S^2 - 2(\sum S)^2$, and the tail counts.

The two-valuedness makes the law fully explicit. $f = t-1$ with probability $1/t$ and $f = -1$ otherwise, so $S = t\cdot B - n$ with $B \sim \mathrm{Binomial}(n, 1/t)$. This gives $\mathrm{Var}(S) = t^2\cdot n\cdot\frac1t\left(1-\frac1t\right) = n(t-1)$, in agreement with Theorem 4.2.

Exhaustive enumeration confirms, for example:

| $M$ | $n$ | $\varphi(M)$ | $t$ | $\sum S^2$ | $\sum (S_x - S_y)^2$ |
|---|---|---|---|---|---|
| $7$ | $2$ | $6$ | $2$ | $72 = 2\cdot6^2\cdot1$ | $5184 = 2\cdot 6^2\cdot 72$ |
| $15$ | $2$ | $8$ | $4$ | $384 = 2\cdot 8^2\cdot 3$ | $49152$ |
| $15$ | $3$ | $8$ | $4$ | $4608 = 3\cdot 8^3\cdot 3$ | $4718592$ |
| $105$ | $2$ | $48$ | $8$ | $32256 = 2\cdot 48^2\cdot 7$ | $148635648$ |

For $M = 105$, $n = 1$: $\sum(r-1)^2 = 48\cdot7 = 336$.

### 6.2 Exact enumeration of the $k$-prime score

**Algorithm B (Euler score moments).** For each unit $N \bmod M$, evaluate $\left(\frac{N}{p_i}\right)$ by fast modular exponentiation $N^{(p_i-1)/2} \bmod p_i$ ($O(\log p_i)$ multiplications). Accumulate $\mathcal{S}(N)$ and $(\mathcal{S}(N) - \sum w)^2$. The total cost is $O(\varphi(M)\sum_i\log p_i)$. Examples:

| primes | weights | mean | $\sum w$ | variance | $\sum w^2$ |
|---|---|---|---|---|---|
| $3,5$ | $2,-1$ | $1$ | $1$ | $5$ | $5$ |
| $3,5,7,11$ | $3,1,-2,5$ | $7$ | $7$ | $39$ | $39$ |
| $3,7,11,13,17$ | $1,2,3,4,5$ | $15$ | $15$ | $55$ | $55$ |

### 6.3 Chebyshev versus truth

For $M = 15$ and $n = 3$, the exact fraction of seed pairs with $|S_x - S_y| \ge c$ is $0.624, 0.145, 0.0132$ for $c = 4, 8, 12$. The bound $2n(t-1)/c^2$ gives $1, 0.281, 0.125$. The bound holds and is conservative by up to an order of magnitude, which motivates the exponential bounds discussed in Section 8.

### 6.4 Monte-Carlo with the two seeds

Drawing $n = 10^5$ uniform units with the two seeds 20260821 and 20260826 gives sample means of $r_M$ of $1.0077$ and $1.0016$ for $M = 1155$ ($t = 16$). The drift is $0.0061$, against a predicted root-mean-square drift of $\sqrt{2\cdot15/10^5} = 0.0173$. For $M = 15015$ ($t = 32$) the sample means are $0.9850$ and $0.9894$, a drift of $0.0045$ against $0.0249$.

---

## 7. Discussion

**What is proved and what is not.** All theorems concern the idealised local-rate statistic $r_M$, with draws uniform on the units mod $M$. Actual smoothness yields of $x^2 - N$ also depend on archimedean size, through the Dickman function $\rho(u)$. The link between local rates and yields is the empirical content of the replication experiment and is not claimed here as a theorem. What the theory guarantees is that the arithmetic part of the experiment, namely the mean-one and variance-$(2^k-1)$ structure that the ensemble-equality and per-$N$ findings reflect, is a population constant with an exactly quantified seed noise.

**Hypotheses.** The primes must be odd and distinct. These conditions give $t = 2^k$ and the coprimality needed for the Chinese Remainder Theorem. The generic layers (Sections 3, 5.1, 5.2) need no arithmetic at all: they hold for arbitrary finite sets, or for arbitrary finite abelian groups.

**One mechanism.** Every main result rests on the same step. Expand a square, observe that the cross term factors as a product of two centred sums, and conclude that it vanishes. Over seeds the centred coordinates are the draws; over residues mod $M$ they are the primes, made independent by the Chinese Remainder Theorem. The replication law and the $k$-prime score law are two readings of this one identity.

**Not covered.** Draws without replacement, non-squarefree moduli, and the prime $2$.

**Methodological lesson.** A fresh-seed replication is an empirical check of a mathematical fact: the claimed quantity is a population constant whose sampling noise is controlled. When the claim is an exact law, the law also predicts the exact distribution of disagreements between replications, so the replication becomes a test of that prediction rather than a hope.

---

## 8. Future work

1. **Fourth-moment law.** Since $f = r - 1$ takes only the values $-1$ and $t-1$, its moments are explicit polynomials in $t$. We conjecture
$$\sum_{x\in G^n} S(x)^4 = n\,\varphi^n(t-1)(t^2 - 3t + 3) + 3n(n-1)\,\varphi^n(t-1)^2,$$
which would give sharper, sub-Gaussian-type tails. Enumeration agrees for $(M,n) \in \{(7,2),(15,2),(15,3),(21,3),(105,2)\}$.
2. **Hoeffding-type bound.** Because $f\in[-1,t-1]$ is bounded, the exponential moment of $S$ factorises over draws. This should give $\#\{x: |S(x)|\ge c\} \le 2\varphi^n\exp(-2c^2/(nt^2))$, turning seed-robustness into an exponentially small failure probability.
3. **Non-squarefree moduli and the prime $2$.** For $M = 2^e\prod p_i^{a_i}$, Lemma 2.2 already gives variance $t(M) - 1$. Only the two-torsion count $t(M) = 2^{k + \delta(e)}$ remains to be computed, with $\delta(0) = \delta(1) = 0$, $\delta(2) = 1$, $\delta(e \ge 3) = 2$.
4. **Optimal predictor weights.** For a target $Y(N) = \sum_i c_i r_{p_i}(N)$, orthogonality gives $\mathrm{Cov}(\mathcal{S}, Y) = \sum_i w_ic_i$. Under the normalisation $\sum w_i^2 = 1$, Cauchy–Schwarz shows that $w \propto c$ is optimal.

---

## Appendix: a worked example ($M = 15$)

$G = (\mathbb{Z}/15)^\times = \{1,2,4,7,8,11,13,14\}$. Squaring sends $1, 4, 11, 14 \mapsto 1$ and $2, 7, 8, 13 \mapsto 4$. So $r(1) = r(4) = 4$ and $r(N) = 0$ for the other six units, and $t = 4 = 2^2$. The deviations are $3,3,-1,-1,-1,-1,-1,-1$, with sum $0$ and sum of squares $24 = 8\cdot 3$, so the mean is $1$ and the variance is $3$.

Euler score with primes $3, 5$ and weights $(1,1)$: $\mathcal{S}(N) = 2 + \left(\frac{N}{3}\right) + \left(\frac{N}{5}\right)$ takes the values $4$ (for $N=1,4$), $0$ (for $N=2,8$), and $2$ (for $N = 7,11,13,14$). The mean is $(8 + 0 + 8)/8 = 2$ and the variance is $(2\cdot 4 + 2\cdot 4 + 0)/8 = 2$, as Corollary 5.5 predicts.
