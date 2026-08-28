# Smoothness of Shifted Squares at Band Nine: An Exact Theory of Cluster Inference, and the Dissolution of a Sub-Unit Drift

**Author:** Aristotle
**Date:** 2026-08-28

---

## Abstract

The running-time analysis of every practical integer-factorisation algorithm in the quadratic-sieve family rests on an unproved randomness heuristic: that the values $v = j^2 - N$ generated near $\sqrt N$ are $B$-smooth at approximately the rate of random integers of the same magnitude. A pilot study of $96$-bit balanced semiprimes reported a direction-stable *deficit* in the smooth rate of the candidates relative to size-matched controls — about $5\%$ at one threshold and $14\%$ at another — with every confidence interval covering the null value $1$ but every split-half agreeing in sign.

We report an independent-seed replication at $19.2$ million matched candidate/control pairs distributed over $128$ moduli, and, more substantially, we develop the exact finite-sample theory that the replication's inference requires. The measured ratio at the better-powered threshold is $r \approx 0.99$ with cluster-bootstrap interval $[0.919,\,1.0101]$; at the pre-registered primary threshold the interval is $[0.8571,\,1.1488]$. Both cover $1$, and the worst-case edge deliverable improves from the pilot's $0.137$ to $0.081$, with both of its components — precision and drift — improving independently.

The theoretical contributions are: (i) an exact decomposition of the interval deliverable into precision plus drift; (ii) the exact null price of $k$ agreeing split-halves, namely $2^{1-k}$; (iii) a Legendre-symbol computation showing that the candidate pool's local density at an odd prime $p$ is $2/p$ or $0$ against the control's $1/p$, yet averages to *exactly* $1/p$ over the two quadratic classes, together with the consequence that the between-modulus variance of the multiplicative bias is $2^k - 1$; (iv) exact — not heuristic — independence of the local congruence conditions at coprime moduli, via the Chinese Remainder Theorem, isolating the single remaining heuristic step; (v) an exact cluster-bootstrap variance law $\operatorname{Var}_{\mathrm{boot}} = \sigma^2/m$ valid at every finite $m$, derived from a marginalisation identity on the $m^m$-point resample space, whence the pair count is provably not a power lever; (vi) exact pooling theory in which the folkloric $\sqrt 2$ tightening is shown to be a *ceiling* attained only at matched precisions; and (vii) an exact analysis of degenerate resampling showing that a single event-bearing cluster forces a non-degenerate resample fraction of at least $1 - e^{-1}$.

Calibrating the $c/\sqrt m$ law by the run itself, we prove that $10\times$ the cluster count cannot resolve a $1\%$ deviation and $30\times$ can, with exact threshold $2656$ clusters. The pilot's drift does not replicate; we downgrade it from a banked tension to an open question at reduced weight.

**Keywords:** smooth numbers, quadratic sieve, Legendre symbol, cluster bootstrap, ANOVA decomposition, inverse-variance pooling, Dickman function, replication.

---

## 1. Introduction

### 1.1 The heuristic under test

Let $N$ be an odd composite, $s = \lceil\sqrt N\rceil$, and consider the *candidate values*

$$v_j = j^2 - N, \qquad j \in (s,\, 3s].$$

Such values are the raw material of the quadratic sieve and its variants: they are of magnitude $O(\sqrt N)$, they are congruent to $j^2$ modulo $N$, and a sufficiently large collection of $B$-smooth ones yields a congruence of squares and hence, with probability bounded away from zero, a nontrivial factor.

The complexity analysis of the method depends entirely on the density of $B$-smooth values among the $v_j$. That density is *assumed* to match the density of $B$-smooth integers among random integers of the same size, which by the Dickman–de Bruijn theory is $\rho(u)^{1+o(1)}$ with $u = \log v / \log B$ the smoothness parameter. No proof of this assumption is known, and it is not obviously true: the $v_j$ are shifted squares, and as we shall see their divisibility behaviour at each individual prime departs from that of random integers by a factor of $2$ or $0$.

We call the assumption the **shifted-square randomness heuristic**, and we call the empirical program of testing it the *scale–smoothness frontier*. The regime of interest is $u \in [6,14]$; the present work operates at $u \approx 9$ to $11.7$, referred to as *band 9*.

### 1.2 The pilot signal and the replication question

A pilot study at band 9 ($96$-bit balanced semiprimes) measured the ratio

$$r = \frac{\Pr[\,v_j \text{ is } B\text{-smooth}\,]}{\Pr[\,\text{size-matched control is } B\text{-smooth}\,]}$$

and found $r$ below $1$ at both of its measurement thresholds: $r \approx 0.947$ at the $10^6$ threshold and $r \approx 0.864$ at the $10^5$ threshold. Every reported confidence interval covered $1$, so no formal significance was claimed; but every split-half of the data pointed downward, and the effect was banked as a *tension* worth resolving.

The question addressed here: **does a fresh independent seed and population, at higher pair count, replicate the deficit downward?**

### 1.3 Design of the replication

- **Population.** $128$ distinct moduli $N$, freshly seeded and independent of the pilot's population.
- **Candidates.** $v = j^2 - N$ for $j \in (s, 3s]$, with $150{,}000$ samples per modulus: exactly $19.2 \times 10^6$ candidate/control pairs.
- **Controls.** *Paired per draw*: for each candidate, a control integer of identical bit length and identical top three mantissa bits, with uniformly random low bits, passed through the **identical** classification routine. Control integrity is thereby structural rather than statistical.
- **Classifier.** Cumulative segment-primorial gcd chains: strip all prime factors below $10^5$, then below $10^6$, and test the residue.
- **Inference.** Cluster bootstrap with $NB = 2000$ resamples over the $128$ modulus-clusters, percentile intervals, size-matched pseudo-clusters for the control arm.
- **Pre-registration.** The decision threshold is $10^5$; the $10^6$ threshold is secondary but better powered (higher event rate), with its reduced weight disclosed in advance.

### 1.4 Results in brief

| Study | Threshold | Interval | Centre $c$ | Half-width $w$ | Edge $E$ |
|---|---|---|---|---|---|
| Pilot | $10^6$ | $[0.8630,\,1.0389]$ | $0.95095$ | $0.08795$ | $0.1370$ |
| Replication (primary) | $10^5$ | $[0.8571,\,1.1488]$ | $1.00295$ | $0.14585$ | $0.1488$ |
| Replication (secondary) | $10^6$ | $[0.919,\,1.0101]$ | $0.96455$ | $0.04555$ | $0.0810$ |

All three intervals cover $1$. The pre-registered $H_0$ branch is selected; no gate is armed. The secondary-threshold deliverable $0.081$ strictly tightens the pilot's $0.137$.

### 1.5 What is new here

The numerical outcome is a null. The substantive contribution is the *exact* theory of the reporting and inference scheme, developed at finite sample size with no asymptotics, and the audit of several folkloric claims that turn out to be false or imprecise as stated. Sections 3–8 present that theory; Section 9 audits the run's own defects.

---

## 2. Notation and standing definitions

Throughout, all statistical functionals are *empirical* (finite-population) functionals; no probability space beyond a finite uniform one is required.

**Definition 2.1 (Empirical functionals).** For $f, g : \{1,\dots,n\} \to \mathbb{R}$ put
$$\bar f = \frac{1}{n}\sum_i f(i), \qquad \operatorname{Var}(f) = \frac1n \sum_i (f(i) - \bar f)^2, \qquad \operatorname{Cov}(f,g) = \frac1n\sum_i (f(i)-\bar f)(g(i)-\bar g).$$

**Definition 2.2 (Interval).** A *confidence interval* is a pair $I = [\ell, h]$ with $\ell \le h$. Its **centre** is $c(I) = (\ell+h)/2$, its **half-width** $w(I) = (h-\ell)/2$, and it **covers** $x$ iff $\ell \le x \le h$. Its **edge deliverable** is
$$E(I) = \max\big(|\ell - 1|,\, |h - 1|\big).$$

**Definition 2.3 (Two-level design).** A *balanced two-level design* is an array $x : \{1,\dots,m\}\times\{1,\dots,n\} \to \mathbb{R}$: $m$ clusters of $n$ observations each. Write $\bar x_i$ for the $i$-th cluster mean and $\bar{\bar x}$ for the grand mean, and define
$$V_{\mathrm{within}} = \frac1m \sum_i \operatorname{Var}(x_i\cdot), \qquad V_{\mathrm{between}} = \operatorname{Var}(\bar x_\cdot), \qquad V_{\mathrm{total}} = \frac{1}{mn}\sum_{i,j}(x_{ij} - \bar{\bar x})^2.$$

**Definition 2.4 (Resample space).** The *cluster-bootstrap resample space* on $m$ clusters is the set of all $m^m$ maps $s : \{1,\dots,m\} \to \{1,\dots,m\}$, each equally likely. The resample mean of cluster values $c_1,\dots,c_m$ is $\bar c^{(s)} = \frac1m\sum_k c_{s(k)}$, and the *bootstrap variance* is
$$\operatorname{Var}_{\mathrm{boot}}(c) = \frac{1}{m^m}\sum_{s}\big(\bar c^{(s)} - \bar c\big)^2 .$$

---

## 3. The reporting scheme: exact anatomy of the deliverable

### 3.1 Coverage as a symmetric statement

**Lemma 3.1.** $I$ covers $x$ if and only if $|x - c(I)| \le w(I)$.

*Proof.* Both sides unfold to the conjunction $\ell \le x$ and $x \le h$ after substituting $\ell = c - w$, $h = c + w$ and splitting the absolute value. $\square$

### 3.2 The edge decomposition

**Theorem 3.2 (Edge Decomposition).** If $I$ covers $1$, then
$$E(I) = w(I) + |c(I) - 1|.$$

*Proof.* Write $c = c(I)$, $w = w(I)$, so $\ell = c-w$, $h = c+w$, and coverage gives $c - w \le 1 \le c+w$. If $c \ge 1$ then $|h-1| = c+w-1$ and $|\ell - 1| = 1-c+w \le c+w-1$, so $E = c + w - 1 = w + |c-1|$. If $c \le 1$ the roles exchange symmetrically. $\square$

**Interpretation.** A study's headline number is the sum of two logically independent virtues: precision (small $w$) and absence of drift (small $|c-1|$). Two studies can share an edge deliverable while being scientifically incomparable. The decomposition makes the comparison auditable.

**Corollary 3.3 (Domination).** If $I$ and $J$ both cover $1$, $w(I) \le w(J)$ and $|c(I)-1| \le |c(J)-1|$, then $E(I) \le E(J)$.

### 3.3 Application to the two runs

**Proposition 3.4.** The pilot interval $[0.8630, 1.0389]$ has $E = 0.1370$; the replication interval $[0.919, 1.0101]$ has $E = 0.0810$. Moreover
$$w(\text{rep}) = 0.04555 < 0.08795 = w(\text{pilot}), \qquad |c(\text{rep}) - 1| = 0.03545 < 0.04905 = |c(\text{pilot}) - 1|.$$
Hence the tightening of the deliverable is not an artefact of re-centring: both summands strictly improve.

*Proof.* Direct arithmetic from Definition 2.2 and Theorem 3.2. $\square$

**Proposition 3.5 (Null branch selected).** All three reported intervals — pilot at $10^6$, replication at $10^5$, replication at $10^6$ — cover $1$.

---

## 4. The price of direction stability

The pilot's persuasive feature was that four split-half analyses all pointed downward. We price this exactly.

**Definition 4.1.** For $k \ge 1$, a *sign pattern* is a map $e : \{1,\dots,k\}\to\{\pm\}$; the pattern is *constant* if all its values agree.

**Lemma 4.2.** Exactly $2$ of the $2^k$ sign patterns are constant.

*Proof.* A constant pattern is determined by its value at index $1$, and the two candidates $e \equiv +$ and $e\equiv -$ are distinct for $k \ge 1$. $\square$

**Theorem 4.3 (Direction-stability $p$-value).** Under the null hypothesis that each split-half sign is an independent fair coin, the probability that $k$ split-halves all agree is
$$p_k = \frac{2}{2^k} = 2^{1-k}.$$

**Corollary 4.4.** $p_4 = 1/8 > 1/20$: four agreeing split-halves are not significant at the $5\%$ level.

**Corollary 4.5 (Depth needed).** $2^{1-k}\le 1/20$ if and only if $k \ge 6$.

*Proof.* For $k \le 5$, $2/2^k \ge 2/32 = 1/16 > 1/20$; for $k\ge 6$, $2^k \ge 64$ so $2/2^k \le 1/32 < 1/20$. $\square$

This retires the pilot's most rhetorically powerful evidence. It is not a criticism of the pilot's honesty — direction stability is genuinely the correct diagnostic to look at — but of its weight at shallow depth.

---

## 5. Arithmetic of the candidate pool: why the null is structural

### 5.1 Local densities

Let $p$ be an odd prime and $N$ an integer. Let $\left(\frac{N}{p}\right)$ be the Legendre symbol.

**Theorem 5.1 (Local density).** The number of residues $j \bmod p$ with $p \mid j^2 - N$ equals $1 + \left(\frac{N}{p}\right)$. Hence the *candidate local density*
$$\delta_p(N) := \frac{\#\{j \bmod p : p \mid j^2 - N\}}{p} = \frac{1 + \left(\frac{N}{p}\right)}{p}.$$

*Proof.* The equation $x^2 = N$ in the field $\mathbb{F}_p$ ($p$ odd) has $2$, $1$, or $0$ solutions according as $N$ is a nonzero square, zero, or a non-square; the count is $1 + \left(\frac Np\right)$ in all three cases since the symbol takes values $+1$, $0$, $-1$ respectively. $\square$

**Corollary 5.2 (Extreme local deviation).** For $p \nmid N$,
$$\delta_p(N) = \begin{cases} 2/p, & \left(\tfrac Np\right) = +1,\\[2pt] 0, & \left(\tfrac Np\right) = -1,\end{cases}$$
against the control density $1/p$. The relative deviation is $\pm 100\%$ at *every* prime: there is no small-perturbation regime.

**Theorem 5.3 (Two-class average).** If $\left(\frac{N_1}{p}\right) = +1$ and $\left(\frac{N_2}{p}\right) = -1$, then
$$\tfrac12\big(\delta_p(N_1) + \delta_p(N_2)\big) = \frac 1p,$$
exactly the control density.

*Proof.* $\frac12\left(\frac2p + 0\right) = \frac1p$. $\square$

This is the structural content of the null hypothesis. The candidate pool is *not* random at any prime, but its non-randomness is a rearrangement across the population of moduli, with exact first-order cancellation. Any global drift must come from a higher-order or non-local mechanism.

### 5.2 The multiplicative bias and its exponential variance

Model the aggregate bias of a single modulus across $k$ small primes by

$$\Pi(e) = \prod_{i=1}^{k}\big(1 + \varepsilon_i\big), \qquad \varepsilon_i = \pm 1,$$

with the $2^k$ sign vectors $e$ equally likely. (By Theorem 5.1, $\varepsilon_i$ is the Legendre symbol at the $i$-th prime, and $1 + \varepsilon_i$ is the ratio $\delta_{p_i}(N)/(1/p_i)$.)

**Theorem 5.4 (Moments of the bias).**
$$\sum_e \Pi(e) = 2^k, \qquad \sum_e \Pi(e)^2 = 4^k,$$
hence the population mean is $\mathbb{E}[\Pi] = 1$, the second moment is $\mathbb{E}[\Pi^2] = 2^k$, and
$$\operatorname{Var}(\Pi) = 2^k - 1.$$

*Proof.* Both sums factor over coordinates: $\sum_e \prod_i (1+\varepsilon_i) = \prod_i \big((1+1)+(1-1)\big) = 2^k$, and $\sum_e \prod_i (1+\varepsilon_i)^2 = \prod_i (4 + 0) = 4^k$. Divide by $2^k$ and subtract the squared mean. $\square$

**Corollary 5.5 (Effective sample size is the cluster count).** The variance-to-mean-square ratio of the per-modulus bias is $2^k - 1$, which grows exponentially in $k$. Consequently a bootstrap that treats the $19.2\times 10^6$ pairs as exchangeable understates the spread by that exponentially large factor; only resampling whole $N$-clusters is consistent.

Note the mechanism concretely: $\Pi$ equals $2^k$ on a single sign pattern (all residues) and $0$ on the other $2^k - 1$. The bias distribution is maximally heavy-tailed — a lottery, not a jitter.

---

## 6. Exact local independence, and the isolation of the remaining heuristic

The multiplicative model of Section 5.2 assumes the conditions at distinct primes are independent. For the *local* (residue-counting) part this is not a heuristic.

**Definition 6.1.** For $p \ge 1$ and $N \in \mathbb{Z}$, the *survivor count* is
$$M_p(N) = \#\{\,j \bmod p : p \nmid j^2 - N\,\},$$
and the *survival density* is $\mu_p(N) = M_p(N)/p$.

**Lemma 6.2.** For $p$ an odd prime, $M_p(N) = p - \big(1 + \left(\tfrac Np\right)\big)$, so $\mu_p(N) = 1 - \delta_p(N)$.

*Proof.* Immediate from Theorem 5.1, complementing within the $p$ residues. $\square$

**Theorem 6.3 (Exact splitting of paired congruence conditions).** Let $a, b \ge 1$ be coprime and let $P$ be any predicate on residues mod $a$ and $Q$ any predicate on residues mod $b$. Then
$$\#\{\,j \bmod ab \;:\; P(j \bmod a) \text{ and } Q(j \bmod b)\,\} \;=\; \#\{x \bmod a : P(x)\}\cdot \#\{y \bmod b : Q(y)\}.$$

*Proof.* The Chinese Remainder Theorem gives a ring isomorphism $\mathbb{Z}/ab \cong \mathbb{Z}/a \times \mathbb{Z}/b$ whose two components are precisely the reduction maps. It therefore carries the set on the left bijectively onto $\{x : P(x)\}\times\{y:Q(y)\}$, and the cardinality of a product is the product of cardinalities. $\square$

**Corollary 6.4 (Exact local independence).** For coprime $a, b$,
$$\#\{\,j \bmod ab : a \nmid j^2 - N \text{ and } b \nmid j^2 - N\,\} \;=\; M_a(N)\,M_b(N),$$
with no error term, and more generally, for any finite set $P$ of pairwise coprime moduli with product $\Pi_P$,
$$\#\Big\{\,j \bmod \Pi_P \;:\; p \nmid j^2 - N \text{ for all } p \in P\,\Big\} \;=\; \prod_{p\in P} M_p(N).$$
Equivalently, writing $\mu$ for the corresponding densities, the survival densities multiply exactly.

*Proof.* The two-modulus case is Theorem 6.3 applied to $P(x) : a \nmid x^2 - N$ and $Q(y) : b\nmid y^2 - N$, the divisibility of $j^2 - N$ by a divisor of $ab$ being determined by the corresponding component. The general case follows by induction on $|P|$, coprimality of each $p$ to the running product being supplied by pairwise coprimality. $\square$

**Proposition 6.5 (Per-prime discrepancy).** For $p$ an odd prime,
$$\mu_p(N) - \Big(1 - \tfrac1p\Big) = -\frac{\left(\frac Np\right)}{p},$$
of magnitude exactly $1/p$ and of either sign.

**Discussion.** The Dickman-style argument for the shifted-square heuristic has two steps: (i) multiplicativity of the local survival conditions across primes; (ii) the passage from a finite prime set to full $B$-smoothness (an inclusion of the tail behaviour, where the Dickman function enters). Theorem 6.3 and Corollary 6.4 establish (i) *exactly*. The only heuristic step remaining is (ii). Any failure of the shifted-square heuristic must therefore be a failure of the finite-to-full passage, not of local independence — a genuine sharpening of the target.

---

## 7. Cluster inference: the exact variance theory

### 7.1 Why pairing is the right control design

**Theorem 7.1 (Contrast variance).** For empirical sequences $X, Y$ over $n$ units,
$$\operatorname{Var}(X - Y) = \operatorname{Var}(X) + \operatorname{Var}(Y) - 2\operatorname{Cov}(X,Y),$$
and $\operatorname{Cov}(X,Y)^2 \le \operatorname{Var}(X)\operatorname{Var}(Y)$ (Cauchy–Schwarz).

*Proof.* Expand $(X - \bar X) - (Y - \bar Y)$ squared and average; Cauchy–Schwarz applied to the centred sequences gives the bound. $\square$

**Corollary 7.2.** Pairing strictly beats independent sampling exactly when the induced empirical covariance is positive.

**Proposition 7.3 (Indicator case).** If $X, Y$ are $\{0,1\}$-valued with means $p, q$, then $\operatorname{Var}(X) = p(1-p)$ and
$$\operatorname{Cov}(X,Y) = \tfrac1n\#\{i : X_i = Y_i = 1\} - pq.$$
Hence the paired contrast of two rare events (here $p, q \approx 3\times10^{-5}$) has variance essentially $p + q - 2\cdot(\text{joint hit rate})$: pairing helps precisely to the extent that a candidate's smoothness predicts its matched control's smoothness. In the degenerate extreme of a perfectly predictive pairing, $\operatorname{Var}(X - X) = 0$.

Matching on bit length and on the top three mantissa bits, and running both arms through the identical classifier, is designed to maximise exactly this covariance.

### 7.2 The ANOVA floor

**Lemma 7.4 (Shift identity).** For any $f$ on $n$ units and any $c \in \mathbb{R}$,
$$\sum_j (f(j) - c)^2 = \sum_j (f(j) - \bar f)^2 + n\,(\bar f - c)^2 .$$
Consequently $\operatorname{Var}(f) \le \frac1n\sum_j (f(j)-c)^2$ for every $c$: the empirical variance is the minimum over centres.

**Theorem 7.5 (Balanced ANOVA decomposition).** For a balanced two-level design,
$$V_{\mathrm{total}} = V_{\mathrm{within}} + V_{\mathrm{between}}.$$

*Proof.* Apply Lemma 7.4 inside each cluster with $c = \bar{\bar x}$, sum over clusters, and divide by $mn$. $\square$

**Corollary 7.6 (Between-cluster floor).** $V_{\mathrm{between}} \le V_{\mathrm{total}}$; hence for any target $t \le V_{\mathrm{between}}$ one also has $t \le V_{\mathrm{total}}$. **Whatever the number of pairs per cluster, the dispersion of the design is bounded below by the between-cluster variance.**

Combined with Theorem 5.4 ($V_{\mathrm{between}} \asymp 2^k - 1$), this makes cluster inference forced rather than stylistic.

### 7.3 The exact bootstrap variance law

We now prove the central structural theorem: the $1/m$ in the bootstrap variance is an identity, not an asymptotic.

**Theorem 7.7 (Resample marginalisation).** For any array $F : \{1,\dots,m\}^2\to\mathbb{R}$,
$$\sum_{s : [m]\to[m]} \ \prod_{i=1}^m F(i, s(i)) \;=\; \prod_{i=1}^m \ \sum_{j=1}^m F(i,j).$$

*Proof.* This is the distributive expansion of a product of sums indexed over the full function space: expanding $\prod_i \sum_j F(i,j)$ produces exactly one term per choice function $s$. $\square$

This is the exact finite-sample statement that "the resample coordinates are independent".

**Corollary 7.8 (One coordinate).** For any $g$ and any index $k$,
$$\sum_s g(s(k)) = m^{\,m-1}\sum_j g(j).$$

*Proof.* Apply Theorem 7.7 to $F(i,j) = g(j)$ if $i=k$ and $F(i,j)=1$ otherwise. The left side collapses to $\sum_s g(s(k))$; the right side is $\big(\sum_j g(j)\big)\cdot m^{m-1}$, the factor $m$ arising once for each of the $m-1$ other coordinates. $\square$

**Corollary 7.9 (Two coordinates).** For $k \ne l$,
$$\sum_s g(s(k))\,h(s(l)) = m^{\,m-2}\Big(\sum_j g(j)\Big)\Big(\sum_j h(j)\Big).$$

*Proof.* As above with $F(i,\cdot) = g$ at $i = k$, $=h$ at $i = l$, $\equiv 1$ elsewhere. $\square$

**Lemma 7.10 (Recentring).** $\bar c^{(s)} - \bar c = \frac1m \sum_k \big(c_{s(k)} - \bar c\big)$.

**Theorem 7.11 (Exact bootstrap variance law).** For any cluster values $c_1,\dots,c_m$ and every $m \ge 1$,
$$\boxed{\ \operatorname{Var}_{\mathrm{boot}}(c) \;=\; \frac{\operatorname{Var}(c)}{m}.\ }$$

*Proof sketch.* Write $d_i = c_i - \bar c$, so $\sum_i d_i = 0$ and $\sum_i d_i^2 = m\operatorname{Var}(c)$. By Lemma 7.10,
$$m^m \operatorname{Var}_{\mathrm{boot}}(c) = \frac{1}{m^2}\sum_s\Big(\sum_k d_{s(k)}\Big)^2 = \frac{1}{m^2}\Big[\sum_k \sum_s d_{s(k)}^2 + \sum_{k\ne l}\sum_s d_{s(k)}d_{s(l)}\Big].$$
By Corollary 7.8 the diagonal term is $m \cdot m^{m-1}\sum_i d_i^2 = m^m\sum_i d_i^2$. By Corollary 7.9 each off-diagonal term is $m^{m-2}\big(\sum_i d_i\big)^2 = 0$. Hence
$$\operatorname{Var}_{\mathrm{boot}}(c) = \frac{1}{m^2}\sum_i d_i^2 = \frac{\operatorname{Var}(c)}{m}. \qquad\square$$

**Theorem 7.12 (Applied to the two-level design).** With $c_i = \bar x_i$ the cluster means of a two-level design,
$$\operatorname{Var}_{\mathrm{boot}}(\bar x_\cdot) = \frac{V_{\mathrm{between}}}{m}.$$
The within-cluster dispersion — hence the pair count $n$ — does not appear.

**Corollary 7.13.** $\operatorname{Var}_{\mathrm{boot}}(\bar x_\cdot) \le V_{\mathrm{total}}/m$, with equality exactly when the design has no within-cluster dispersion.

**Theorem 7.14 (Design rule).** For any target standard error $t$,
$$\operatorname{Var}_{\mathrm{boot}}(c) \le t^2 \iff \operatorname{Var}(c) \le m\,t^2 \iff m \ge \frac{\operatorname{Var}(c)}{t^2}.$$
The pair count is irrelevant to this inequality; reducing the standard error by a factor $\rho$ costs a factor $\rho^2$ in clusters.

**Theorem 7.15 (Non-degeneracy).** $\operatorname{Var}_{\mathrm{boot}}(c) > 0$ as soon as two clusters carry different values, and $\operatorname{Var}_{\mathrm{boot}}(c) = 0$ for a constant cluster population. The criterion is sharp.

*Proof.* By Theorem 7.11 it suffices to characterise $\operatorname{Var}(c) = 0$, which holds iff all centred residuals vanish, i.e. iff $c$ is constant. $\square$

Theorem 7.15 is a guard against a specific failure mode: an inference scheme that could report an arbitrarily tight interval from a heterogeneous population would be reporting an artefact. This one cannot.

### 7.4 Stratification: removing the between-cluster variance exactly

Can the exponential between-modulus variance of Theorem 5.4 be *designed away*? Yes, and exactly.

**Definition 7.16.** For a finite population $\Omega$, a statistic $f : \Omega \to \mathbb{Q}$ and a stratifying map $\kappa : \Omega \to K$, write $\Omega_c = \kappa^{-1}(c)$, $\bar f_c$ for the mean of $f$ on $\Omega_c$, $\bar f$ for the population mean, and
$$\mathrm{SS}_{\mathrm{tot}} = \sum_{\omega}(f(\omega)-\bar f)^2, \quad \mathrm{SS}_{\mathrm{within}} = \sum_{c}\sum_{\omega\in\Omega_c}(f(\omega)-\bar f_c)^2, \quad \mathrm{SS}_{\mathrm{between}} = \sum_c |\Omega_c|\,(\bar f_c - \bar f)^2.$$

**Theorem 7.17 (General one-way decomposition).** For an arbitrary finite population, an arbitrary real-valued statistic and an arbitrary stratifying map whose image is contained in the index set,
$$\mathrm{SS}_{\mathrm{tot}} = \mathrm{SS}_{\mathrm{within}} + \mathrm{SS}_{\mathrm{between}}.$$
No balance assumption is needed; fibres may have any sizes, including zero.

*Proof.* Apply the block form of Lemma 7.4 fibre by fibre with centre $\bar f$, and sum over fibres. $\square$

**Corollary 7.18.** $\mathrm{SS}_{\mathrm{within}} \le \mathrm{SS}_{\mathrm{tot}}$ and $\mathrm{SS}_{\mathrm{between}} \le \mathrm{SS}_{\mathrm{tot}}$: stratification never increases residual dispersion. If $f$ is constant on each fibre then $\mathrm{SS}_{\mathrm{within}} = 0$ and $\mathrm{SS}_{\mathrm{between}} = \mathrm{SS}_{\mathrm{tot}}$.

Now apply this to the bias $\Pi$ of Section 5.2, stratified by the **quadratic-class count**
$$\kappa(e) = \#\{i : \varepsilon_i = +1\} \in \{0,1,\dots,k\}.$$

**Lemma 7.19.** $\Pi(e) = 2^k$ if $\kappa(e) = k$ and $\Pi(e) = 0$ otherwise; in particular $\Pi$ is a function of $\kappa$ alone.

*Proof.* Each factor $1 + \varepsilon_i$ is $2$ or $0$; the product is nonzero iff every factor is $2$. $\square$

**Proposition 7.20.** $\mathrm{SS}_{\mathrm{tot}}(\Pi) = 2^k(2^k - 1)$, consistent with $\operatorname{Var}(\Pi) = 2^k - 1$ over a population of size $2^k$.

**Theorem 7.21 (Quadratic-class stratification is exact).** Stratifying by $\kappa$ leaves
$$\mathrm{SS}_{\mathrm{within}} = 0, \qquad \mathrm{SS}_{\mathrm{between}} = 2^k(2^k-1).$$
The class-count stratification therefore accounts for the *entire* between-modulus variance.

*Proof.* Lemma 7.19 makes $\Pi$ fibre-wise constant; apply Corollary 7.18 and Proposition 7.20. $\square$

**Proposition 7.22 (Non-vacuity).** For the trivial one-stratum design, $\mathrm{SS}_{\mathrm{between}} = 0$ and $\mathrm{SS}_{\mathrm{within}} = 2^k(2^k-1) > 0$ for $k \ge 1$. The class-count stratification therefore removes a strictly positive — indeed exponentially large — amount of dispersion that the coarse design leaves unexplained.

**Design implication.** A future run can stratify its modulus population on the number of small primes at which $N$ is a quadratic residue, and thereby remove the dominant variance component before any resampling occurs. Within the idealised sign model this is not a partial gain; it is complete.

---

## 8. Power arithmetic, and pooling

### 8.1 The $\sqrt m$ law and the cost of the next run

**Definition 8.1.** For a calibration constant $c > 0$, the cluster-bootstrap half-width on $m$ clusters is $H(c,m) = c/\sqrt m$.

**Lemma 8.2.** For $c, \delta > 0$ and $m \ge 1$: $H(c,m) < \delta \iff m > (c/\delta)^2$. Moreover $H$ is antitone in $m$ and $H(c, 4m) = H(c,m)/2$.

**Calibration.** The realised run has $m = 128$ and half-width $0.04555$; hence $c_{\mathrm{cal}} = 0.04555\sqrt{128}$, with $c_{\mathrm{cal}}^2 = 0.04555^2\cdot 128 \approx 0.26561$. To resolve a $1\%$ deviation at the replication's own point estimate $0.99$, the half-width must fall below $0.01$.

**Theorem 8.3 (Ten times is not enough).** For $1 \le m \le 1280$, $H(c_{\mathrm{cal}}, m) \ge 0.01$.

**Theorem 8.4 (Thirty times suffices).** For $m \ge 3840$, $H(c_{\mathrm{cal}}, m) < 0.01$.

**Theorem 8.5 (Exact threshold).** $H(c_{\mathrm{cal}}, 2656) < 0.01$ and $H(c_{\mathrm{cal}}, 2655) \not< 0.01$. The least sufficient cluster count is $2656$, i.e. $20.75\times$ the realised $128$.

*Proof of 8.3–8.5.* By Lemma 8.2 the criterion is $m > c_{\mathrm{cal}}^2/10^{-4} = 0.04555^2\cdot 128\cdot 10^4 = 2655.6\ldots$, so the least integer is $2656$; $1280 < 2656 \le 3840$ gives the two bracketing statements. $\square$

Thus the informally quoted "$10\!-\!30\times$ power run" is arithmetically exactly right, and $[10\times, 30\times]$ is the narrowest decade-scale bracket consistent with the $\sqrt m$ law.

**Proposition 8.6 (Diagnostic on the pilot effect size).** For any $c_0 \le 0.947$, $c_0 + 0.04555 < 1$. Had the true ratio been at the pilot's point estimate, the replication — at its realised precision — would have produced an interval excluding $1$. It did not.

This is the sense in which the replication is informative despite being a null: it had the resolution to see the pilot's claimed effect, and saw nothing of that size.

### 8.2 Inverse-variance pooling

**Definition 8.7.** For variances $v_1, v_2 > 0$, set $V(v_1,v_2) = \dfrac{v_1v_2}{v_1+v_2}$ and $w^\star = \dfrac{v_2}{v_1+v_2}$.

**Theorem 8.8 (Optimality).** For every $w\in\mathbb{R}$, the combination $w x_1 + (1-w)x_2$ of independent estimates has variance $w^2v_1 + (1-w)^2v_2 \ge V(v_1,v_2)$, with equality if and only if $w = w^\star$.

*Proof.* $w^2v_1 + (1-w)^2v_2 - V(v_1,v_2) = (v_1+v_2)\,(w - w^\star)^2 \ge 0$, by direct expansion. $\square$

**Corollary 8.9.** $V(v_1,v_2) < \min(v_1,v_2)$: pooling is a strict gain over either input.

In half-width form (a $95\%$ half-width being a fixed multiple of the standard error), define
$$\mathcal{H}(h_1,h_2) = \frac{h_1h_2}{\sqrt{h_1^2+h_2^2}}, \qquad \text{pooled point } P = \lambda p_1 + (1-\lambda)p_2, \ \ \lambda = \frac{h_2^2}{h_1^2+h_2^2}.$$

**Theorem 8.10 (Matched precisions give exactly $\sqrt 2$).** $\mathcal H(h,h) = h/\sqrt2$.

**Theorem 8.11 (The $\sqrt2$ ceiling).** For all $h_1,h_2 > 0$,
$$\frac{\min(h_1,h_2)}{\sqrt 2}\ \le\ \mathcal H(h_1,h_2),$$
with equality if and only if $h_1 = h_2$; the inequality is strict whenever $h_1 \ne h_2$.

*Proof sketch.* Assume w.l.o.g. $h_2 = \min$. Squaring, the claim is $h_2^2/2 \le h_1^2h_2^2/(h_1^2+h_2^2)$, i.e. $h_1^2 + h_2^2 \le 2h_1^2$, i.e. $h_2 \le h_1$ — true, with equality iff $h_1 = h_2$. $\square$

So $\sqrt 2$ is the *best attainable* pooling gain, not a generic one. This corrects a folk claim.

### 8.3 The pooled verdict for the two runs

With $p_1 = 0.95095$, $h_1 = 0.08795$ (pilot) and $p_2 = 0.96455$, $h_2 = 0.04555$ (replication):

**Theorem 8.12 (Pooling does not resurrect the drift).** $|1 - P| \le \mathcal H(h_1,h_2)$: the inverse-variance pooled $95\%$ interval still covers $1$.

**Theorem 8.13 (But only just).** $P + \mathcal H(h_1,h_2) < 1.0022$; numerically $P \approx 0.96167$ and $\mathcal H \approx 0.04045$, so the upper edge sits at $\approx 1.0021$.

**Theorem 8.14 ($\sqrt 2$ is not realised here).** Since $h_1/h_2 \approx 1.93 \ne 1$, Theorem 8.11 gives $h_2/\sqrt2 < \mathcal H(h_1,h_2)$ strictly.

**Theorem 8.15 (The realised gain is small).** $0.88\,h_2 < \mathcal H(h_1,h_2)$: pooling with the noisier pilot improves on the replication alone by under $12\%$.

**Theorem 8.16 (The quoted joint point is the equal-weight one).** With reported point estimates $0.947$ (pilot) and $0.99$ (replication):
$$\tfrac12(0.947+0.99) = 0.9685, \qquad 0.98 < P_{\mathrm{pts}} < 0.9810,$$
where $P_{\mathrm{pts}}$ is the inverse-variance pooled point. Consequently $|1 - P_{\mathrm{pts}}| < |1 - 0.9685|$: the widely-quoted "$\approx 0.97$" is the equal-weight average, and precision weighting moves the joint point strictly closer to the null.

**Summary of the pooled verdict.** The joint interval covers $1$; the realised pooling gain is under $12\%$, far short of $\sqrt2$; and the precision-weighted joint point is $\approx 0.981$, not $\approx 0.97$. The residual tension is *smaller* than banked, in the direction of the null. Downgrading it from a banked tension to an open question at reduced weight is the correct call.

---

## 9. Audit of two run defects

Honest reporting requires that the run's own failures be analysed rather than footnoted. Both admit exact treatment.

### 9.1 The round-to-four display defect

The output writer stored the candidate smooth rate rounded to four decimal places: $\mathrm{store}_4(x) = \lfloor 10^4 x + \tfrac12\rfloor/10^4$. The true rate is of order $3\times10^{-5}$.

**Proposition 9.1 (The stored zero is information-free).** For $0 \le x < 5\times 10^{-5}$, $\mathrm{store}_4(x) = 0$. Hence $\mathrm{store}_4$ is not injective on the range in which the candidate rate lives, and the stored value $0.0$ carries no information beyond membership in $[0, 5\times 10^{-5})$.

The raw hit counts were not persisted, so the loss is not recoverable directly. It is recoverable *indirectly*, from the ratio interval and the control rate.

**Proposition 9.2 (CI-implied recovery).** If $r$ lies in an interval $I$ and the control rate is $\rho \ge 0$, then the candidate rate $r\rho$ lies in $[\rho\,\ell(I),\ \rho\,h(I)]$. With $I = [0.8571, 1.1488]$ (primary threshold) and $\rho = 3.1\times 10^{-5}$,
$$r\rho \in [\,2.65701\times10^{-5},\ 3.56128\times10^{-5}\,].$$
In particular $r\rho > 0$, so the stored $0.0$ is provably not the measured value.

**Proposition 9.3 (The circulated bracket is not an enclosure).** The bracket $[2.66\times 10^{-5},\ 3.56\times 10^{-5}]$ has both endpoints rounded *inwards* and therefore fails to contain the CI-implied range: $2.65701 < 2.66$ and $3.56128 > 3.56$. The outward-rounded bracket $[2.65\times 10^{-5},\ 3.57\times10^{-5}]$ is a valid enclosure.

This is a small point with a sharp moral: a correction for a rounding defect must itself round in the safe direction.

### 9.2 The degenerate smoke-leg bootstrap

A small smoke-test leg produced an uninterpretable verdict field, attributed to a "starved-regime bootstrap": fewer than $100$ of the $2000$ resamples were non-degenerate, so the percentile bounds were undefined and the exclusion test trivially passed. We test that explanation.

Call a cluster an **event cluster** if it carries at least one smooth hit. A resample is *degenerate* exactly when it selects no event cluster, since then both tallies vanish and the ratio is $0/0$.

**Theorem 9.4 (Exact count).** For any set $H$ of clusters with $|H| = h$, exactly $(m - h)^m$ of the $m^m$ resamples avoid $H$.

*Proof.* The resamples avoiding $H$ are exactly the functions $[m] \to [m]\setminus H$, of which there are $(m-h)^m$. $\square$

**Corollary 9.5.** The degenerate fraction is exactly $\big(1 - h/m\big)^m$.

**Theorem 9.6 (Uniform exponential bound).** $\big(1 - h/m\big)^m \le e^{-h}$, uniformly in $m$.

*Proof.* $1 - t \le e^{-t}$ with $t = h/m$; raise to the $m$-th power. $\square$

**Corollary 9.7 (One event cluster suffices).** If $h \ge 1$, the non-degenerate fraction is at least $1 - e^{-1} \approx 0.632$, whatever the cluster count.

**Theorem 9.8 (Diagnosis).** Observing fewer than $100$ non-degenerate resamples out of $2000$ (a fraction below $0.05 \ll 0.632$) is impossible with even one event cluster. Hence the smoke-leg population contained **no smooth hit at all**: $h = 0$, and the degenerate fraction is exactly $1$.

The smoke-leg interval therefore carries no information about the ratio, rather than carrying a wide one. Discarding it as non-canonical and letting the full-run verdict govern is the correct ruling — and now a derived one rather than a judgement call.

---

## 10. Verdict and interpretation

**Verdict: the null branch, with no gate armed.**

1. At the pre-registered primary threshold ($10^5$), the interval $[0.8571, 1.1488]$ covers $1$.
2. At the better-powered secondary threshold ($10^6$), $r \approx 0.99$ with interval $[0.919, 1.0101]$ over $128$ clusters and $19.2\times10^6$ pairs — the tightest interval obtained in this regime. The edge deliverable $0.081$ strictly tightens the pilot's $0.137$, with both precision and drift improving.
3. Pooled with the pilot at matched conditions, the joint interval still covers $1$, with upper edge below $1.0022$; the precision-weighted joint point is $\approx 0.981$, closer to the null than the equal-weight $0.9685$.
4. The pilot's direction stability across four split-halves has null probability $1/8$.

The sub-unit drift does not replicate downward. We downgrade it from a banked tension to an open question at reduced weight. Decisive resolution requires $2656$ clusters — about $20.75\times$ the present run.

**Barrier framing.** No barrier is breached and no complexity constant is shaved. What the null does is *strengthen* the randomness heuristic for shifted squares into the Dickman approach zone through $u \approx 11.7$, at the scale–smoothness frontier $u \in [6,14]$. That is a positive result for the standing complexity analysis of sieve-based factoring: the heuristic is, so far as $19.2$ million matched pairs can say, holding.

**Methodological content.** The theory developed here is reusable well beyond this experiment:

- The Edge Decomposition (Theorem 3.2) gives a principled, auditable way to report a null.
- The direction-stability price (Theorem 4.3) prices a diagnostic that is routinely over-weighted.
- The exact bootstrap variance law (Theorem 7.11) turns a piece of practitioner folklore into an identity, and yields a hard design rule (Theorem 7.14): clusters, not observations.
- The pooling ceiling (Theorem 8.11) replaces a false generic claim with the correct sharp one.
- The degenerate-resample analysis (Theorems 9.4–9.8) converts an anomalous output into a determination about the underlying population.

---

## 11. Limitations

1. **Power.** The realised throughput ($76.4\,\mu\text{s}$ per value; wall time $1467$ s against a $1104$ s estimate, the candidate strips being slower than random strips) capped this run at approximately $1\times$ the pilot's power rather than the aspirational $10\!-\!30\times$. Its role was reframed in advance as scoping and as the fresh-seed replication gate, not as decisive resolution.
2. **Model idealisation.** The exponential between-modulus variance $2^k - 1$ is derived within an idealised sign model in which the quadratic characters at $k$ primes are independent fair signs. Genuine Legendre symbols across a fixed modulus population are not literally that; the model captures the mechanism and the order of magnitude, and the exact independence result (Corollary 6.4) supports the multiplicativity, but the numerical constant should be read as a scaling statement.
3. **The finite-to-full passage.** Corollary 6.4 removes the independence heuristic; it does not remove the passage from a finite prime set to full $B$-smoothness. That step remains the live heuristic.
4. **Data loss.** The candidate hit rate is reconstructed from the ratio interval rather than measured, owing to the display defect of Section 9.1. The reconstruction is exact given the interval, but the raw counts are gone.
5. **Two thresholds.** The pre-registered primary threshold is $10^5$; the tighter conclusion comes from the $10^6$ threshold, whose reduced weight was declared in advance and is maintained here.

---

## 12. Future directions

**A. The decisive run.** Theorem 8.5 gives the price: $2656$ clusters. Because the pair count is provably not a power lever (Theorem 7.12), the entire budget should go into distinct moduli, at whatever per-modulus sample size keeps the classifier throughput efficient.

**B. Stratified design.** Theorem 7.21 shows that stratifying the modulus population by the quadratic-class count removes the whole between-modulus dispersion in the idealised model. Implementing this stratification — and measuring how much of the real dispersion it removes — is the cheapest available power multiplier, and is orthogonal to increasing $m$.

**C. Sharpening the correct pooling statement.** Theorem 8.11 identifies $\sqrt 2$ as the ceiling. A companion question: given a fixed total budget split between a new run and re-analysis of an old one, what allocation minimises the pooled half-width? The answer is immediate from Theorem 8.8 but has not been used to plan a run.

**D. Attacking the remaining heuristic.** The one unproved step is the finite-to-full passage. Establishing a rigorous version of it for shifted squares — even a one-sided bound — would convert the sieve complexity analysis from heuristic to conditional-on-nothing in this regime.

**E. Higher $u$.** The frontier extends to $u \approx 14$. Each additional unit of $u$ costs event rate exponentially, which by Theorem 7.14 costs clusters quadratically in the target precision. Mapping that cost curve is a prerequisite for planning the frontier program.

---

## 13. Conclusion

A rumour of non-randomness in the smoothness of $j^2 - N$ at band 9 has been tested against an independent population of $128$ moduli and $19.2$ million matched pairs, and has not survived. The measured ratio is $0.99$ with the tightest interval yet obtained in this regime; pooling with the original pilot leaves the joint interval covering the null; the pilot's most persuasive diagnostic is worth $1/8$; and the arithmetic reason for the null is visible at the level of a single prime, where the candidate density $\big(1 + \left(\frac Np\right)\big)/p$ averages to exactly $1/p$ over the two quadratic classes.

Around that null we have built exact finite-sample infrastructure: an identity that separates what an interval delivers into precision and drift; an exact variance law for cluster resampling proved from a marginalisation identity on the full $m^m$-point resample space; an exact ANOVA accounting that makes cluster inference forced and makes quadratic-class stratification complete; the correct sharp form of the pooling gain; and an exact degeneracy analysis that reads an anomalous output as a statement about the population.

The single most useful number produced is $2656$: the cluster count at which this question stops being open.
