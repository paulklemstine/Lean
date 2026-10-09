# The Quadratic-Residue Bite Is Variance, Not Mean: Exact Local Moments for Quadratic-Sieve Values

**Aristotle**

*October 2026*

---

## Abstract

In the quadratic sieve, the values $Q(x) = x^2 - N$ can only be divisible by primes $p$ for which $N$ is a quadratic residue modulo $p$. A natural heuristic holds that this exclusion of half the primes should depress the smoothness rate of sieve values relative to random integers of the same size, for example through an increased "effective $u$". We report an experiment (four cells in the smoothness parameter $u$, $100{,}000$ values per cell) that refutes this heuristic: averaged over $N$, sieve values are smooth exactly as often as unrestricted random integers, within noise, while random integers restricted to the quadratic-residue half of the factor base are $21$–$56$ times less often smooth. The surviving effect is a large *per-$N$* variance: the smooth rate correlates ($r \approx 0.40$–$0.50$) with the number of small primes that are quadratic residues of $N$, and the top-to-bottom decile spread grows from $2.4\times$ at $u = 2.5$ to $9.3\times$ at $u = 3.5$.

We then prove the exact arithmetic statements underlying both halves of this picture. For a finite abelian group $G$ let $r(g)$ be the number of square roots of $g$, and $t = r(1)$. We show $\sum_g r(g) = |G|$, $r(g) \in \{0, t\}$, and $\sum_g (r(g)-1)^2 = |G|(t-1)$. Specialised to the units modulo a product $M$ of $k$ distinct odd primes, where $r_M(N)$ counts the classes $x \bmod M$ with $M \mid x^2 - N$, this gives: the mean of $r_M$ over $N$ is exactly $1$ (the rate of a random integer) for every $k$, while its variance is exactly $2^k - 1$, with all the mass carried by a fraction $2^{-k}$ of the $N$. We also prove that local rates at coprime moduli have exactly zero covariance, so weighted Euler-criterion scores have additive variance. These results explain the experiment, retire the effective-$u$ explanation of an earlier yield anomaly (which used one $N$ per scale and thereby sampled the variance), and justify a cheap *a priori* predictor of per-$N$ relation yield.

---

## 1. Introduction

### 1.1 The quadratic sieve and its fuel

Let $N$ be an odd composite integer that is not a perfect power. The quadratic sieve searches for integers $x$ slightly larger than $\sqrt N$ such that

$$Q(x) = x^2 - N$$

is **$B$-smooth**, i.e. has all prime factors at most $B$. Each such $x$ yields a congruence $x^2 \equiv Q(x) \pmod N$ whose right-hand side factors over the *factor base* of small primes. Once more relations than factor-base primes have been collected, Gaussian elimination over $\mathbb F_2$ finds a subset whose product of right-hand sides is a perfect square, producing $a^2 \equiv b^2 \pmod N$ and, with probability at least $1/2$, a nontrivial factor $\gcd(a-b, N)$.

The cost of the method is governed by the **smoothness rate** of the values $Q(x)$. For random integers of size $X$, the probability of $B$-smoothness is approximately $\rho(u)$, where $u = \log X / \log B$ and $\rho$ is the Dickman–de Bruijn function. Whether, and how, the values $Q(x)$ deviate from this random-integer model is therefore a question of direct practical importance.

### 1.2 The quadratic-residue restriction

For an odd prime $p \nmid N$, $p \mid x^2 - N$ is possible only if $N$ is a quadratic residue modulo $p$. Writing $\left(\frac{N}{p}\right)$ for the Legendre symbol, only primes with $\left(\frac{N}{p}\right) = +1$ — roughly half of all primes — can appear in the factorisation of any sieve value. A frequently invoked heuristic treats this as a handicap: sieve values are "random integers with half a factor base", or equivalently random integers with a larger effective smoothness parameter $u_{\rm eff} > u$.

An earlier study in this series observed sieve yields at $0.54$–$0.76$ of a Dickman-based prediction and attributed the shortfall to precisely such an effective-$u$ mechanism. That study measured a single modulus $N$ at each scale.

### 1.3 Summary of this paper

* **Empirically** (Section 6), the effective-$u$ hypothesis is refuted: averaged over $N$, sieve values are as smooth as unrestricted random integers. The large per-$N$ variance is what survives.
* **Theoretically** (Sections 2–5), we prove exact identities for the local divisibility counts $r_M(N)$: the mean over $N$ is exactly $1$ at every sieving depth, the variance is exactly $2^k - 1$ for $k$ sieving primes, local rates at distinct primes are exactly uncorrelated, and weighted Euler-criterion scores have exactly additive variance.
* **Practically** (Section 7), the per-$N$ yield is predictable from a handful of Euler-criterion evaluations, and the classical multiplier heuristic is reinterpreted as *variance harvesting*.

The guiding slogan: **the quadratic-residue bite is variance, not mean.**

---

## 2. Square-root counts in finite abelian groups

Throughout this section $G$ is a finite abelian group written multiplicatively.

**Definition 2.1 (root count, two-torsion count).** For $g \in G$ put

$$r(g) = \#\{x \in G : x^2 = g\}, \qquad t = t(G) = r(1) = \#\{y \in G : y^2 = 1\}.$$

The relevance to sieving is immediate: if $G = (\mathbb Z/M\mathbb Z)^\times$ and $N$ is a unit modulo $M$, then any $x$ with $x^2 \equiv N \pmod M$ is automatically a unit, so $r(N)$ is exactly the number of residue classes $x \bmod M$ with $M \mid x^2 - N$. Dividing by $M$, $r(N)/M$ is the probability that $M$ divides $x^2-N$ for $x$ uniformly random modulo $M$; for a uniformly random integer the corresponding probability is $1/M$. Thus **$r(N)$ is the local divisibility rate of the sieve values relative to random integers.**

**Theorem 2.2 (mean compensation).** $\displaystyle\sum_{g \in G} r(g) = |G|.$

*Proof.* The sets $\{x : x^2 = g\}$, $g \in G$, are the fibres of the squaring map $G \to G$; they partition $G$. Summing their sizes gives $|G|$. $\square$

Equivalently: if $g$ is uniform in $G$, then $\mathbb E[r(g)] = 1$.

**Lemma 2.3 (translation).** For every $x \in G$, $r(x^2) = t$.

*Proof.* The map $y \mapsto y x^{-1}$ is a bijection from $\{y : y^2 = x^2\}$ onto $\{z : z^2 = 1\}$, with inverse $z \mapsto zx$; this uses commutativity, $(yx^{-1})^2 = y^2 x^{-2}$. $\square$

**Corollary 2.4 (all-or-nothing law).** For every $g \in G$, either $r(g) = 0$ or $r(g) = t$.

*Proof.* If $r(g) \neq 0$, pick $x$ with $x^2 = g$ and apply Lemma 2.3. $\square$

**Theorem 2.5 (exact second moment).** $\displaystyle\sum_{g \in G} r(g)^2 = |G|\cdot t.$

*Proof.* For each $g$, write $r(g)^2 = \sum_{x : x^2 = g} r(g) = \sum_{x : x^2 = g} r(x^2)$. Summing over $g$ and using that the fibres partition $G$,
$$\sum_g r(g)^2 = \sum_{x \in G} r(x^2) = \sum_{x\in G} t = |G|\,t,$$
by Lemma 2.3. $\square$

**Corollary 2.6 (exact variance).** $\displaystyle\sum_{g \in G} \big(r(g) - 1\big)^2 = |G|\,(t - 1).$

*Proof.* Expand: $\sum (r-1)^2 = \sum r^2 - 2\sum r + |G| = |G|t - 2|G| + |G|$ by Theorems 2.2 and 2.5. $\square$

So for $g$ uniform in $G$, $\operatorname{Var}[r(g)] = t - 1$.

**Corollary 2.7 (concentration of the weight).** $\#\{g : r(g) \ne 0\}\cdot t = |G|.$

*Proof.* By Corollary 2.4, $|G| = \sum_g r(g) = \sum_{r(g)\ne 0} t$. $\square$

In probabilistic language: for $g$ uniform in $G$, $r(g)$ takes the value $t$ with probability $1/t$ and $0$ with probability $1 - 1/t$. Its mean is $1$ and its variance is $t^2\cdot\frac1t - 1 = t - 1$, consistent with the above.

**Lemma 2.8 (functoriality).** (a) If $e: G \to H$ is a group isomorphism, then $r_H(e(g)) = r_G(g)$ for all $g$, and $t(G) = t(H)$. (b) For $g\in G$, $h\in H$, $r_{G\times H}(g,h) = r_G(g)\, r_H(h)$; in particular $t(G\times H) = t(G)\,t(H)$.

*Proof.* (a) $e$ restricts to a bijection between square roots of $g$ and of $e(g)$; take $g = 1$ for the second claim. (b) $(x,y)^2 = (g,h)$ iff $x^2 = g$ and $y^2 = h$, so the square-root set is a Cartesian product. $\square$

---

## 3. The prime layer: Euler's criterion decides the local rate

**Proposition 3.1.** For an odd prime $p$, $t\big((\mathbb Z/p\mathbb Z)^\times\big) = 2$.

*Proof.* In the field $\mathbb F_p$, $y^2 = 1$ iff $(y-1)(y+1) = 0$ iff $y = \pm 1$, and $1 \neq -1$ because $p \neq 2$. $\square$

**Theorem 3.2 (local law).** Let $p$ be an odd prime and $N$ an integer with $p \nmid N$. Then
$$r_p(N) = 1 + \left(\frac{N}{p}\right).$$

*Proof.* If $N$ is a nonzero square modulo $p$, Corollary 2.4 and Proposition 3.1 give $r_p(N) = 2$; otherwise $r_p(N) = 0$. These are exactly $1 \pm 1$. $\square$

By Euler's criterion, $\left(\frac{N}{p}\right) \equiv N^{(p-1)/2} \pmod p$, so the local rate is computable with one modular exponentiation.

**Corollary 3.3 (mean compensation and variance at one prime).** For an odd prime $p$,
$$\sum_{N=1}^{p-1}\Big(1 + \left(\tfrac{N}{p}\right)\Big) = p - 1, \qquad \sum_{N=1}^{p-1}\big(r_p(N) - 1\big)^2 = p - 1.$$

*Proof.* Theorem 2.2 and Corollary 2.6 with $|G| = p-1$, $t = 2$. $\square$

The per-prime variance is $1$ — as large as the square of the mean. "Double rate on half the pool" is not an approximation: the doubling *exactly* compensates the halving, on average, while making the rate maximally uneven.

**Example 3.4.** For $p = 7$ and $N = 1, \dots, 6$ the residues are $1, 2, 4$ and $r_7(N) = 2, 2, 0, 2, 0, 0$. Then $\sum r = 6$ and $\sum (r-1)^2 = 6$.

---

## 4. The CRT layer: many sieving primes

**Theorem 4.1 (multiplicativity).** For coprime positive integers $m, n$ and any unit $N$ modulo $mn$,
$$r_{mn}(N) = r_m(N)\, r_n(N).$$

*Proof.* The Chinese Remainder Theorem gives a ring isomorphism $\mathbb Z/mn \cong \mathbb Z/m \times \mathbb Z/n$, hence a group isomorphism of unit groups $(\mathbb Z/mn)^\times \cong (\mathbb Z/m)^\times \times (\mathbb Z/n)^\times$ sending $N$ to $(N \bmod m, N \bmod n)$. Apply Lemma 2.8. $\square$

**Proposition 4.2.** If $M = p_1 \cdots p_k$ is a product of $k$ distinct odd primes ($M = 1$ when $k = 0$), then $t\big((\mathbb Z/M)^\times\big) = 2^k$.

*Proof.* Induction on $k$. For $k=0$ the group is trivial and $t = 1$. For the inductive step, $p_1$ is coprime to $p_2\cdots p_k$, so by Lemma 2.8 and the CRT $t$ multiplies, and Proposition 3.1 contributes a factor $2$. $\square$

**Theorem 4.3 (the QR bite is variance, not mean).** Let $M$ be a product of $k$ distinct odd primes. Summing over the $\varphi(M)$ units $N$ modulo $M$,
$$\sum_{N} r_M(N) = \varphi(M), \qquad \sum_{N}\big(r_M(N) - 1\big)^2 = \varphi(M)\,\big(2^k - 1\big).$$

*Proof.* Theorem 2.2 and Corollary 2.6 with $|G| = \varphi(M)$ and $t = 2^k$ (Proposition 4.2). $\square$

**Theorem 4.4 (concentration).** With $M$ as above, every unit $N$ has $r_M(N) \in \{0, 2^k\}$, and
$$\#\{N : r_M(N) \neq 0\}\cdot 2^k = \varphi(M).$$

*Proof.* Corollaries 2.4 and 2.7 with Proposition 4.2. $\square$

**Interpretation.** For $N$ uniform among the units modulo $M$, the local rate has mean exactly $1$, independently of $k$, but variance exactly $2^k - 1$, exponential in $k$. A fraction $2^{-k}$ of the moduli enjoy a jackpot rate $2^k$; all others have rate $0$ at $M$. Since $r_M(N) = \prod_i \big(1 + (N/p_i)\big)$, the jackpot $N$ are exactly those that are residues modulo every $p_i$.

**Example 4.5.** For $M = 105 = 3\cdot5\cdot7$, $\varphi(M) = 48$ and $k = 3$. Six residues have $r = 8$ and forty-two have $r = 0$. Then $\sum r = 48$ and $\sum (r-1)^2 = 6\cdot 49 + 42 = 336 = 48 \cdot 7$.

| $k$ | $M$ | $\varphi(M)$ | $\sum r_M$ | $\sum (r_M - 1)^2$ | $\varphi(M)(2^k-1)$ | #support $= \varphi(M)/2^k$ |
|---|---|---|---|---|---|---|
| 1 | 3 | 2 | 2 | 2 | 2 | 1 |
| 2 | 15 | 8 | 8 | 24 | 24 | 2 |
| 3 | 105 | 48 | 48 | 336 | 336 | 6 |
| 4 | 1155 | 480 | 480 | 7200 | 7200 | 30 |

---

## 5. The predictor layer: zero covariance and additive scores

A practical predictor of per-$N$ yield should combine information from several primes. The following results show that the per-prime pieces of information are exactly orthogonal.

**Lemma 5.1.** For any finite abelian group $G$, $\sum_{g\in G}\big(r(g) - 1\big) = 0$.

*Proof.* Immediate from Theorem 2.2. $\square$

**Theorem 5.2 (zero covariance).** For finite abelian groups $G, H$,
$$\sum_{(g,h)\in G\times H}\big(r_G(g) - 1\big)\big(r_H(h) - 1\big) = 0.$$

*Proof.* The sum factors as $\Big(\sum_g (r_G(g)-1)\Big)\Big(\sum_h (r_H(h)-1)\Big) = 0\cdot 0$. $\square$

Via the CRT isomorphism of Theorem 4.1, this says: **for coprime moduli $m, n$, the local rates $r_m(N)$ and $r_n(N)$ are exactly uncorrelated as $N$ ranges over the units modulo $mn$.**

**Theorem 5.3 (variance of a two-modulus score).** For integers $a, b$,
$$\sum_{(g,h)\in G\times H}\Big(a\big(r_G(g)-1\big) + b\big(r_H(h)-1\big)\Big)^2 = |G|\,|H|\,\Big(a^2\big(t(G)-1\big) + b^2\big(t(H)-1\big)\Big).$$

*Proof.* Expand the square. The cross term vanishes by Theorem 5.2. Each square term reduces, after summing out the other coordinate, to Corollary 2.6 multiplied by the order of the other group. $\square$

**Theorem 5.4 (two-prime Euler score).** Let $p \neq q$ be odd primes and $a, b$ integers. For a unit $N$ modulo $pq$ define the score
$$S(N) = a\, r_p(N) + b\, r_q(N) = a\Big(1 + \left(\tfrac{N}{p}\right)\Big) + b\Big(1 + \left(\tfrac{N}{q}\right)\Big).$$
Then, summing over the $\varphi(pq)$ units modulo $pq$,
$$\sum_N S(N) = \varphi(pq)\,(a+b), \qquad \sum_N \big(S(N) - (a+b)\big)^2 = \varphi(pq)\,\big(a^2 + b^2\big).$$

*Proof.* Transport the sums along the CRT isomorphism to $(\mathbb Z/p)^\times \times (\mathbb Z/q)^\times$. The first identity follows from Theorem 2.2 in each factor. For the second, note $S(N) - (a+b) = a(r_p - 1) + b(r_q - 1)$ and apply Theorem 5.3 with $t = 2$ for both factors. $\square$

So the score has mean $a+b$ — no quadratic-residue penalty — and variance $a^2 + b^2$: per-prime variances add with no cross term. By induction the same additivity holds for any finite set of distinct odd primes, so a score $\sum_p w_p\, r_p(N)$ has variance $\sum_p w_p^2$. The regression of yield on per-prime Euler bits is therefore *diagonal*.

---

## 6. Experimental evidence

### 6.1 Design

Four cells in the smoothness parameter $u$, each with $100{,}000$ values, were generated with a fixed random seed. Three populations were compared in each cell:

1. **Sieve values** $x^2 - N$ for $x$ just above $\sqrt N$, pooled over many randomly chosen $N$.
2. **Unrestricted random integers** of the same size distribution.
3. **QR-pool-restricted random integers**: random integers of the same size, counted as smooth only if they factor over the primes $p \le B$ with $\left(\frac{N}{p}\right) = +1$. This is the "half a factor base" model of the effective-$u$ hypothesis.

The pre-registered hypothesis H1 was that population 1 behaves like population 3 — that is, that the quadratic-residue restriction lowers the smoothness rate.

### 6.2 Ensemble results

* The smooth rates of populations 1 and 2 agreed within noise in every cell. Both were $0.87$–$0.99$ of the Dickman prediction $\rho(u)$. This is a previously documented finite-size factor that affects random integers equally.
* Population 3 was smooth **$21$–$56$ times less often** than population 1.

H1 is refuted. Theorem 4.3 explains why: the doubled local rate at residue primes exactly compensates for the missing non-residue primes, at every finite sieving modulus. Population 3 keeps the halving and drops the doubling.

### 6.3 Per-$N$ results

Grouping the sieve values by $N$ revealed large dispersion:

* The Pearson correlation between the per-$N$ smooth rate and $\#\{p \le 100 \text{ odd prime}: \left(\frac{N}{p}\right) = +1\}$ was $0.50$, $0.45$, $0.48$ and $0.40$ across the four cells.
* The ratio of the mean rate in the top decile of $N$ to that in the bottom decile was $2.4$ at $u = 2.5$ and $9.3$ at $u = 3.5$.

These match the qualitative content of Theorems 4.3 and 5.4. The variance is driven by the Legendre bits of $N$ at small primes, it accumulates additively over primes, and it grows with the number of primes that effectively matter — which increases with $u$.

### 6.4 Resolution of the earlier anomaly

The earlier yield ratios $0.54$–$0.76$ came from a design with *one* $N$ per scale. Given a per-$N$ decile spread of $2.4$–$9.3\times$, a single draw is dominated by the luck of that $N$'s residue pattern. Those ratios are consistent with draw-to-draw variation, not with a systematic deficit. The effective-$u$ explanation is retired: Theorem 4.3 shows the mean local rate carries no penalty at all.

### 6.5 A small-scale replication

The accompanying script reproduces the phenomenon at small scale: 40 moduli $N$ with 14 digits, 1,500 sieve values each, bound $B = 600$, mean $u \approx 3.8$. It finds a ratio $\approx 0.9$ between the mean sieve-value smooth rate and that of size-matched random integers, about a $26\times$ deficit for the QR-half-base model, a decile spread of about $10\times$, and a correlation of about $0.58$ with the small-prime residue count. These figures fluctuate with seed and size; they illustrate the phenomenon and do not replace the main experiment.

---

## 7. Algorithms and applications

### 7.1 Exact local-moment table

*Input:* distinct odd primes $p_1, \dots, p_k$. *Output:* the distribution of $r_M(N)$ over units $N$ modulo $M = \prod p_i$.

1. For each unit $N$ modulo $M$, compute $r_M(N) = \prod_i \big(1 + \left(\tfrac{N}{p_i}\right)\big)$ using Euler's criterion. This takes $O(k \log M)$ modular multiplications per $N$.
2. Tabulate $\sum r_M$ and $\sum (r_M-1)^2$, and check them against $\varphi(M)$ and $\varphi(M)(2^k - 1)$.

By Theorem 4.4 the output is always the two-point distribution $\{0 : 1 - 2^{-k},\ 2^k : 2^{-k}\}$. The table is therefore a consistency check, not new information.

### 7.2 A priori yield predictor

*Input:* $N$, a list of small odd primes $p_1 < \dots < p_P$ (for example the first $20$), and weights $w_p$. *Output:* a score predicting the relative relation yield of $N$.

1. For each $p_i$, compute $\epsilon_i = N^{(p_i-1)/2} \bmod p_i \in \{1, p_i - 1\}$, i.e. the Legendre symbol (or $0$ if $p_i \mid N$).
2. Return $S(N) = \sum_i w_{p_i}\big(1 + \epsilon_i\big)$.

The cost is $P$ modular exponentiations with tiny moduli — negligible next to sieving. By Theorem 5.4 and its extension, over random $N$ the score has mean $\sum w_p$ and variance $\sum w_p^2$. The unweighted version ($w_p = 1$, primes up to $100$) already correlates at $0.40$–$0.50$ with realised yield. A natural weighting, motivated by the contribution of $p$ to the expected logarithmic size of the smooth part, is $w_p = \log p / (p-1)$.

### 7.3 Multiplier selection as variance harvesting

The classical multiplier technique sieves $kN$ instead of $N$ for a small squarefree $k$, choosing $k$ to maximise a weighted count of small primes $p$ with $\left(\frac{kN}{p}\right) = +1$. Theorem 4.3 shows that, averaged over moduli, no choice can raise the mean local rate. A multiplier helps because it *selects a favourable draw* from a distribution with large variance. The predictor of Section 7.2 is a score of exactly this kind, and the zero-covariance theorem makes its statistics transparent.

---

## 8. Discussion

**What is exact and what is empirical.** Sections 2–5 are exact statements about local divisibility counts over complete residue systems of $N$. Section 6 is empirical. The bridge between them — from local rates at a modulus $M$ to the smoothness probability at a given $u$ — is heuristic. It would require a transfer principle of Dickman type, incorporating the finite-size correction factor, and we do not claim one.

**Why the mean is robust.** Theorem 2.2 holds in every finite abelian group, for the simple reason that the fibres of a map partition its domain. Nothing about primes, residues or sizes enters. This explains why the experiment found no penalty "at every cell": the identity is insensitive to the depth of sieving.

**Why the variance grows.** The variance $t - 1$ equals $2^k - 1$ for $k$ primes, so it is governed by the size of the two-torsion subgroup. Each additional prime doubles the jackpot and halves its probability. On the logarithmic scale this is the familiar picture of a sum of independent, mean-zero $\pm1$ contributions, which suggests a log-normal law for yields (Conjecture 9.1).

**Limitations.** Our formulas treat $N$ as uniform over units modulo $M$. Actual factoring targets are fixed integers, and "random $N$" is a modelling device that the experiment implements by sampling. The prime $2$ and prime powers are excluded from the clean statements; they contribute bounded corrections.

---

## 9. Future work and conjectures

**Conjecture 9.1 (log-normal yield law).** For fixed $u$, the logarithm of the per-$N$ smooth yield is asymptotically Gaussian over random $N$, with mean equal to the unrestricted Dickman value (with its finite-size correction) and variance asymptotic to $c(u)\sum_{p\le B}\big(\log p/(p-1)\big)^2$. Heuristic support: each prime contributes an independent mean-zero Legendre bit (Theorem 5.2) with exactly computed variance. The two decile spreads ($2.4\times$, $9.3\times$) provide calibration points for $c(u)$.

**Conjecture 9.2 (variance–$u$ monotonicity).** The per-$N$ decile spread is strictly increasing in $u$ and exceeds $30\times$ at $u = 4.5$. Heuristic: the effective number of relevant primes grows with $u$, and the local variance $2^k - 1$ is exponential in $k$.

**Conjecture 9.3 (optimal Euler predictor).** Among linear scores $\sum_{p\le P} w_p \left(\frac{N}{p}\right)$, the best linear predictor of yield has $w_p \propto \log p/(p-1)$, and $P = 20$ primes recover at least $85\%$ of the achievable correlation. Zero covariance makes the regression diagonal, so the optimal weights are the per-prime covariances with yield.

**Direction 9.4 (multiplier selection as variance harvesting).** Quantify the expected gain of the best multiplier among the first $K$ squarefree candidates as an extreme-value statistic of the yield distribution of Conjecture 9.1.

**Direction 9.5 (transfer principle).** Prove a Dickman-type transfer from local moments to smoothness probabilities, turning Theorem 4.3 into a rigorous ensemble statement about smooth counts.

---

## 10. Conclusion

The quadratic-residue condition, often treated as a handicap of the quadratic sieve, imposes no penalty on average. At every sieving modulus the local divisibility rate of $x^2 - N$, averaged over $N$, equals exactly that of a random integer. This is a consequence of the fact that the fibres of the squaring map partition a finite abelian group. What the condition does produce is a variance that grows exponentially with the number of sieving primes, built additively from exactly uncorrelated per-prime Legendre bits. This variance is visible in experiment as a $2.4$–$9.3\times$ spread in per-$N$ yield. It accounts for an earlier anomaly, and it can be predicted cheaply in advance from Euler's criterion. The bite is variance, not mean.
