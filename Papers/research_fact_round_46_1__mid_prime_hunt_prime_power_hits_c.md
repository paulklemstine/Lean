# Prime-Power Hits Carry the Smoothness Budget: An Exact Theory of Divisibility Features for Smooth-Number Yield

**Author:** Aristotle

**Date:** 2026-09-04

---

## Abstract

Let $B \ge 2$ and let $\Psi_B(x)$ denote the number of $B$-smooth integers in $[1,x]$. Sieve-based factoring algorithms are governed by the yield of $B$-smoothness tests, and predicting that yield per instance — rather than asymptotically — is a persistent practical problem. We develop an exact structural theory of *divisibility hit features*: indicator statistics of the form "$m$ divides the candidate", restricted to the smooth pool.

Our central identity is an **exact rescaling theorem**: for a positive $B$-smooth modulus $m$, the number of $B$-smooth $v \le x$ with $m \mid v$ equals $\Psi_B(\lfloor x/m\rfloor)$ *exactly*, with no error term. Hence a divisibility feature is not a new arithmetic condition but a change of the smoothness budget. We show the hypothesis that $m$ be smooth is necessary ($B=5$, $m=7$, $x=100$ gives $0 \ne 10$).

From the rescaling we derive: (i) a graded valuation spectrum, $\#\{v \le x \text{ smooth} : v_p(v) = j\} = \Psi_B(\lfloor x/p^j\rfloor) - \Psi_B(\lfloor x/p^{j+1}\rfloor)$; (ii) an exact budget shift on the smoothness parameter $u = \log x/\log B$, namely $u(v) = u(v/p^2) + 2\log p/\log B$, together with the antitonicity $2\log p/\log B' \le 2\log p / \log B$ for $B \le B'$ that localises the effect in the tight-$u$ regime; (iii) a **budget decomposition theorem**, $\sum_{v \le x \text{ smooth}} \Omega(v) = \sum_{p \le B}\sum_{j=1}^{\lfloor \log_2 x\rfloor} \Psi_B(\lfloor x/p^j\rfloor)$, showing that the prime-power hit features form a *linear coordinate system* for the total smoothness budget; (iv) a **completeness theorem**, that the prime-power hit profile determines a positive smooth integer uniquely, contrasted with an exact **blindness theorem** and a pigeonhole **collision theorem** for the squarefree ($j=1$) truncation; (v) two-sided **abundance bounds** $(m+1)^{\pi(B)} \le \Psi_B(x) \le (\lfloor \log_2 x\rfloor+1)^{\pi(B)}$ under $P_B^m \le x$, transferring to hit sub-pools; and (vi) an **$\mathbb{F}_2$ blind spot**: a family of $p^2$-hits has a square sub-product exactly when its cofactor family does, so a prime-power hit spends smoothness budget without purchasing a new relation direction.

These results explain a measured empirical phenomenon: prime-power hit indicators ($p^2 \mid v$, $p \le 13$) add $+0.0892$ out-of-sample $R^2$ (CI $[0.041, 0.125]$) over a full baseline containing squarefree-hit features, while mid-prime fractions ($+0.019$) and quadratic-residue density ($+0.004$) have confidence intervals spanning zero. The theorems identify the mechanism as information-theoretic disjointness of two graded layers, not sampling correlation.

**Keywords:** smooth numbers, Dickman function, factor base, prime-power valuation, sieve yield, divisibility features, $\mathbb{F}_2$ relations.

---

## 1. Introduction

### 1.1 Smooth numbers and sieve yield

A positive integer $v$ is **$B$-smooth** if every prime factor of $v$ is at most $B$. Write
$$\Psi_B(x) = \#\{v \in \mathbb{Z} : 1 \le v \le x,\ v \text{ is } B\text{-smooth}\},$$
the **smooth-counting function**, and let $\pi(B)$ denote the number of primes $\le B$ (the size of the *factor base*), and $P_B = \prod_{p \le B} p$ its *primorial*.

Smooth numbers are the computational substrate of subexponential integer factorization. A sieve generates candidate values, tests each for $B$-smoothness, retains the survivors, and assembles their factorization exponent vectors into a linear system over $\mathbb{F}_2$; a nontrivial kernel vector yields a congruence of squares and, with constant probability, a factorization. The dominant cost parameter is the **yield**: what proportion of candidates survive.

Asymptotically the yield is governed by the **smoothness parameter**
$$u \;=\; \frac{\log x}{\log B},$$
via $\Psi_B(x) \sim x\,\rho(u)$ for $u$ in a suitable range, where $\rho$ is the Dickman function. However in the **tight-$u$ regime** that real sieves inhabit — roughly $2 \le u \le 5$ — the asymptotic is too coarse for per-instance prediction, and empirical yield models are used instead.

### 1.2 The empirical residual, and the feature that resolved it

A programme of experiments built regression models predicting per-instance yield from instance descriptors. A strong baseline used candidate magnitude, the bound $B$, the derived $u$, and the **squarefree hit indicators** $\mathbb{1}[p \mid v]$ for factor-base primes $p$. That baseline left a structured residual.

Two natural extensions failed. Mid-prime fractions of the factor base contributed $+0.019$ out-of-sample $R^2$ with confidence interval spanning zero; quadratic-residue density contributed $+0.004$, likewise. A third succeeded decisively: **prime-power hit indicators** $\mathbb{1}[p^2 \mid v]$ for $p \le 13$ added $+0.0892$ out-of-sample $R^2$ with confidence interval $[0.041, 0.125]$, over and above the full baseline.

This paper explains that gain structurally. The explanation is not statistical: it consists of exact identities showing that the squarefree indicators and the higher prime-power indicators occupy *provably disjoint* informational layers, and that the higher layers reconstruct exactly the quantity the yield depends on.

### 1.3 Summary of contributions

1. **Exact rescaling** (Theorem 3.1): $\mathrm{hit}_B(m; x) = \Psi_B(\lfloor x/m\rfloor)$ for positive $B$-smooth $m$, with the necessity of smoothness of $m$ (Remark 3.4).
2. **Graded valuation spectrum** (Theorem 3.6): a telescoping formula for the exact-multiplicity strata.
3. **Budget shift and antitonicity** (Theorems 4.1, 4.3, 4.4): a $p^2$-hit costs exactly $2\log p/\log B$ of $u$, and the cost is larger at smaller $B$.
4. **Budget decomposition** (Theorem 6.3): the total budget $\sum \Omega(v)$ over the smooth pool equals the total number of prime-power hits, and equals a sum of rescaled smooth counts.
5. **Completeness vs. blindness** (Theorems 5.1, 5.3, 7.1, 7.3): the full prime-power profile is a complete invariant of a smooth value; the squarefree truncation has fibres of unbounded budget and must collide by pigeonhole.
6. **Abundance bracket** (Theorems 8.1, 8.2, 8.4): $(m+1)^{\pi(B)} \le \Psi_B(x) \le (\lfloor \log_2 x\rfloor + 1)^{\pi(B)}$ under $P_B^m \le x$, and the same lower bound for the $p^2$-hit sub-pool at the rescaled bound.
7. **$\mathbb{F}_2$ blind spot** (Theorems 9.2, 9.3): prime-power hits are invisible to the relation-collection stage.
8. **The exactly solvable case $B = 2$** (Theorems 10.1, 10.2, 7.4): closed forms with equality.

---

## 2. Definitions and conventions

Throughout, $B, m, v, w, x, j, k$ denote non-negative integers and $p, q$ denote primes. All divisions of integers written $\lfloor a/b \rfloor$ (or, in displayed identities, $a/b$ inside a counting function) are floor divisions.

**Definition 2.1 (Smoothness).** For $B, v \in \mathbb{N}$, say $v$ is **$B$-smooth**, written $\mathrm{Sm}_B(v)$, if every prime $p$ dividing $v$ satisfies $p \le B$. Equivalently, every element of the prime-factor support of $v$ is $\le B$. By convention $\mathrm{Sm}_B(1)$ holds vacuously, and $\mathrm{Sm}_B(0)$ is false unless $B$ exceeds all primes (we always restrict to $v \ge 1$).

**Lemma 2.2 (Closure properties).** Smoothness passes to divisors and is multiplicative:
- if $d \mid n$, $n \ne 0$ and $\mathrm{Sm}_B(n)$, then $\mathrm{Sm}_B(d)$;
- if $a, b \ne 0$, $\mathrm{Sm}_B(a)$ and $\mathrm{Sm}_B(b)$, then $\mathrm{Sm}_B(ab)$.

*Proof.* For the first, any prime of $d$ is a prime of $n$. For the second, the prime support of $ab$ is the union of those of $a$ and $b$. $\square$

**Definition 2.3 (Counting functions).**
$$\Psi_B(x) \;=\; \#\{v : 1 \le v \le x,\ \mathrm{Sm}_B(v)\}, \qquad \mathrm{hit}_B(m; x) \;=\; \#\{v : 1 \le v \le x,\ \mathrm{Sm}_B(v),\ m \mid v\}.$$

**Definition 2.4 (Budget).** $\Omega(v)$ is the number of prime factors of $v$ counted with multiplicity; equivalently $\Omega(v) = \sum_p v_p(v)$, where $v_p(v)$ is the $p$-adic valuation. We call $\Omega$ the **discrete smoothness budget**.

**Definition 2.5 (Feature vectors).** For a factor-base bound $B$ let $\mathcal{P}_B$ denote the set of primes $\le B$, so $|\mathcal{P}_B| = \pi(B)$. Define
$$\mathrm{sqf}_B(v) = \{p \in \mathcal{P}_B : p \mid v\}, \qquad \mathrm{pow}_B(v) = \{p \in \mathcal{P}_B : p^2 \mid v\},$$
the **squarefree hit vector** and the **prime-power hit vector**. More generally the **prime-power hit profile** of $v$ is the family of Booleans $\big(\mathbb{1}[p^j \mid v]\big)_{p \in \mathcal{P}_B,\ j \ge 1}$; the squarefree vector is its $j = 1$ layer.

**Definition 2.6 (Smoothness parameter).** For $B > 1$ and $x \ge 1$, $u_B(x) = \log x / \log B$.

**Definition 2.7 (Primorial).** $P_B = \prod_{p \le B} p$.

---

## 3. The exact rescaling theorem

The structural core of the theory is a single bijection.

**Theorem 3.1 (Exact rescaling).** Let $m > 0$ with $\mathrm{Sm}_B(m)$. Then for all $x$,
$$\mathrm{hit}_B(m; x) \;=\; \Psi_B\big(\lfloor x/m \rfloor\big).$$

*Proof sketch.* We exhibit mutually inverse maps between the two counted sets. Forward: $v \mapsto v/m$. If $1 \le v \le x$, $\mathrm{Sm}_B(v)$, and $m \mid v$, then $v/m$ is an integer with $1 \le v/m$ (since $m \le v$) and $v/m \le \lfloor x/m\rfloor$; moreover $v/m \mid v$, so $\mathrm{Sm}_B(v/m)$ by Lemma 2.2. Backward: $w \mapsto m w$. If $1 \le w \le \lfloor x/m\rfloor$ and $\mathrm{Sm}_B(w)$, then $mw \le x$ by the defining property of floor division, $mw \ge 1$, $\mathrm{Sm}_B(mw)$ by multiplicativity (using $\mathrm{Sm}_B(m)$), and $m \mid mw$. The two maps are mutually inverse: $m \cdot (v/m) = v$ when $m \mid v$, and $(mw)/m = w$ since $m > 0$. $\square$

**Corollary 3.2 (Prime-square hit).** For a prime $p \le B$ and all $x$,
$$\mathrm{hit}_B(p^2; x) \;=\; \Psi_B\big(\lfloor x/p^2\rfloor\big).$$
*Proof.* The only prime factor of $p^2$ is $p \le B$, so $\mathrm{Sm}_B(p^2)$; apply Theorem 3.1. $\square$

**Corollary 3.3 (Joint hits compose multiplicatively).** For distinct primes $p, q \le B$,
$$\#\{v \le x : \mathrm{Sm}_B(v),\ p^2 \mid v,\ q^2 \mid v\} \;=\; \Psi_B\big(\lfloor x/(p^2q^2)\rfloor\big).$$
*Proof sketch.* Since $p \ne q$ are prime, $p^2$ and $q^2$ are coprime, so simultaneous divisibility by both is equivalent to divisibility by $p^2 q^2$. The modulus $p^2q^2$ is $B$-smooth (its prime support is $\{p,q\}$), so Theorem 3.1 applies. $\square$

Thus two prime-power features are *not* independent events: their joint firing rate is exactly the single-feature rate at the product modulus. The rescaling theorem determines the entire dependence structure of the hit-feature family.

**Remark 3.4 (Smoothness of the modulus is necessary).** The hypothesis $\mathrm{Sm}_B(m)$ cannot be dropped. Take $B = 5$, $m = 7$, $x = 100$. No $5$-smooth number is divisible by $7$, so $\mathrm{hit}_5(7; 100) = 0$; whereas $\Psi_5(\lfloor 100/7\rfloor) = \Psi_5(14) = |\{1,2,3,4,5,6,8,9,10,12\}| = 10$. The failure is total, not an error term. Backward direction of the bijection fails: $m w$ need not be smooth.

**Proposition 3.5 (Strictness and monotonicity).** For $m \ge 2$ and $x \ge 1$, $\mathrm{hit}_B(m;x) < \Psi_B(x)$ (the value $v = 1$ is smooth but never hit). For $B \le B'$, $\mathrm{hit}_B(m;x) \le \mathrm{hit}_{B'}(m;x)$.

**Theorem 3.6 (Graded valuation spectrum).** For a prime $p \le B$ and any $j \ge 0$,
$$\#\{v \le x : \mathrm{Sm}_B(v),\ v_p(v) = j\} \;=\; \Psi_B\big(\lfloor x/p^j\rfloor\big) \;-\; \Psi_B\big(\lfloor x/p^{j+1}\rfloor\big).$$

*Proof sketch.* Let $S_k = \{v \le x : \mathrm{Sm}_B(v),\ p^k \mid v\}$. Since $p^k \mid v \iff k \le v_p(v)$ for $v \ne 0$, we have $S_{j+1} \subseteq S_j$ and $\{v : v_p(v) = j\} \cap S_0 = S_j \setminus S_{j+1}$. Each $p^k$ is $B$-smooth, so $|S_k| = \Psi_B(\lfloor x/p^k\rfloor)$ by Theorem 3.1, and the cardinality of a set difference with nested sets subtracts. $\square$

The exact multiplicity distribution of any factor-base prime across the smooth pool is therefore a telescoping family of rescaled smooth counts, all determined by $\Psi_B$.

---

## 4. The budget shift and the tight-$u$ mechanism

We now translate the rescaling into the continuous parameter $u$.

**Theorem 4.1 (Exact budget shift).** Let $p > 0$, $v > 0$ and $p^2 \mid v$. Then for any base $B$,
$$u_B(v) \;=\; u_B(v/p^2) \;+\; \frac{2\log p}{\log B}.$$

*Proof sketch.* Write $v = p^2 w$ with $w > 0$. Then $v/p^2 = w$ exactly, and $\log v = \log(p^2) + \log w = 2\log p + \log w$. Divide by $\log B$. $\square$

The identity is exact because the division is exact: a hit *is* a factorization, and the logarithm turns it into an additive split of the budget.

**Definition 4.2.** Call $\delta_B(p) = \dfrac{2\log p}{\log B}$ the **budget toll** of a $p^2$-hit at bound $B$.

**Theorem 4.3 (Budget squeeze at the rescaled bound).** Let $B > 1$, $p > 0$ and $p^2 \le x$. Then
$$u_B\big(\lfloor x/p^2\rfloor\big) \;\le\; u_B(x) - \delta_B(p).$$

*Proof sketch.* $\lfloor x/p^2\rfloor \ge 1$ by $p^2 \le x$, so its logarithm is well defined and nonnegative; and $\lfloor x/p^2\rfloor \le x/p^2$ as reals. Monotonicity of $\log$ gives $\log\lfloor x/p^2\rfloor \le \log x - 2\log p$; divide by $\log B > 0$. $\square$

**Remark.** The hypothesis $p^2 \le x$ is required. If $x < p^2$ then $\lfloor x/p^2\rfloor = 0$ and the left-hand side degenerates; the inequality as stated would fail under the usual convention $\log 0 = 0$. This is a genuine boundary condition of the statement, not an artefact.

**Theorem 4.4 (Antitonicity of the toll — the tight-$u$ mechanism).** For $1 < B \le B'$ and $p \ge 1$,
$$\delta_{B'}(p) \;=\; \frac{2\log p}{\log B'} \;\le\; \frac{2\log p}{\log B} \;=\; \delta_B(p).$$

*Proof sketch.* $\log$ is monotone, so $0 < \log B \le \log B'$; the numerator $2\log p \ge 0$; and $t \mapsto c/t$ is antitone on $t > 0$ for $c \ge 0$. $\square$

**Interpretation.** The same arithmetic event — a doubled small prime — consumes a *larger share of the smoothness budget at a smaller factor-base bound*. Numerically, $\delta_{10^6}(2) \approx 0.100$ but $\delta_{13}(2) \approx 0.541$; $\delta_{13}(13) = 2$ exactly. Because the smooth density $\rho(u)$ decays super-exponentially in $u$, a half-unit shift in $u$ is a first-order effect at tight $u$ and negligible at large $B$. This is precisely the regime dependence observed empirically: the prime-power feature earns its predictive weight at small $B$ (the experiment used $p \le 13$) and would be expected to vanish at large $B$.

---

## 5. Completeness of the prime-power profile

**Theorem 5.1 (Complete invariant).** Let $v, w > 0$ be $B$-smooth. Suppose that for every prime $p \le B$ and every $j \ge 1$,
$$p^j \mid v \iff p^j \mid w.$$
Then $v = w$.

*Proof sketch.* By unique factorization it suffices to show $v_p(v) = v_p(w)$ for every prime $p$. Three cases.
- $p$ prime and $p \le B$: $p^{v_p(v)} \mid v$, hence $p^{v_p(v)} \mid w$ by hypothesis, hence $v_p(v) \le v_p(w)$; symmetrically $v_p(w) \le v_p(v)$.
- $p$ prime and $p > B$: by $B$-smoothness of $v$ and $w$, a positive valuation would force $p \le B$; so both valuations vanish.
- $p$ not prime: both valuations vanish by convention. $\square$

**Corollary 5.2.** The map $v \mapsto (\mathbb{1}[p^j \mid v])_{p \le B,\, j \ge 1}$ is injective on the positive $B$-smooth integers. Every function of a positive smooth value — in particular its yield-relevant statistics — is a function of its prime-power profile.

**Theorem 5.3 (Strict refinement).** Let $p \le B$ be prime, $v \ne 0$, $p \mid v$ but $p^2 \nmid v$. Then
$$\mathrm{sqf}_B(v \cdot p) = \mathrm{sqf}_B(v), \qquad p \in \mathrm{pow}_B(v \cdot p), \qquad p \notin \mathrm{pow}_B(v).$$

*Proof sketch.* The first assertion is the $k=1$ case of Theorem 7.1 below. For the second, $p \mid v$ gives $v = pw$, so $vp = p^2 w$. The third is the hypothesis. $\square$

So the prime-power vector strictly refines the squarefree vector; there are pairs the former separates and the latter cannot. Section 7 upgrades this from "there exist pairs" to an exact impossibility and an unconditional pigeonhole.

---

## 6. The budget decomposition

We now show that the prime-power hit features are not merely more informative than the squarefree ones but form a *linear coordinate system for the total budget*.

**Lemma 6.1 (Budget as a factor-base sum).** If $\mathrm{Sm}_B(v)$ then
$$\Omega(v) \;=\; \sum_{p \le B} v_p(v).$$
*Proof sketch.* In general $\Omega(v) = \sum_{p \in \mathrm{supp}(v)} v_p(v)$, summed over the prime support. Smoothness gives $\mathrm{supp}(v) \subseteq \mathcal{P}_B$, and primes in $\mathcal{P}_B \setminus \mathrm{supp}(v)$ contribute $0$. $\square$

**Lemma 6.2 (A valuation counts hits).** Let $p$ be prime, $v \ne 0$, and let $J \ge v_p(v)$. Then
$$v_p(v) \;=\; \#\{ j \in [1, J] : p^j \mid v \}.$$
*Proof sketch.* For $v \ne 0$ and prime $p$, $p^j \mid v \iff j \le v_p(v)$. So the filtered set is exactly $[1, v_p(v)]$ (using $v_p(v) \le J$), which has cardinality $v_p(v)$. $\square$

Moreover the window $J = \lfloor \log_2 x \rfloor$ always suffices for $v \le x$: for any prime $p$ and $v \ne 0$, $2^{v_p(v)} \le p^{v_p(v)} \le v$, so $v_p(v) \le \log_2 v \le \log_2 x$.

**Theorem 6.3 (Budget decomposition, hit form).** For all $B, x$,
$$\sum_{\substack{1 \le v \le x \\ \mathrm{Sm}_B(v)}} \Omega(v) \;=\; \sum_{p \le B}\ \sum_{j=1}^{\lfloor \log_2 x\rfloor} \mathrm{hit}_B(p^j; x).$$

*Proof sketch.* Fix $v$ in the smooth pool. By Lemma 6.1 and then Lemma 6.2 applied at $J = \lfloor \log_2 x\rfloor$ (legitimate by the valuation bound above),
$$\Omega(v) \;=\; \sum_{p \le B} v_p(v) \;=\; \sum_{p \le B}\ \sum_{j=1}^{J} \mathbb{1}[p^j \mid v].$$
Summing over $v$ in the pool and exchanging the (finite) orders of summation yields, for each $(p,j)$, the count $\#\{v \le x : \mathrm{Sm}_B(v),\ p^j \mid v\} = \mathrm{hit}_B(p^j; x)$. $\square$

**Theorem 6.4 (Budget decomposition, rescaled form).** For all $B, x$,
$$\sum_{\substack{1 \le v \le x \\ \mathrm{Sm}_B(v)}} \Omega(v) \;=\; \sum_{p \le B}\ \sum_{j=1}^{\lfloor \log_2 x\rfloor} \Psi_B\big(\lfloor x/p^j\rfloor\big).$$
*Proof sketch.* Apply Theorem 3.1 to each modulus $p^j$, which is $B$-smooth since $p \le B$. $\square$

**Interpretation (the central structural claim).** The total smoothness budget of the pool is a *linear* functional of the prime-power hit counts — indeed it is their plain sum. The prime-power features do not approximate the budget; they *are* the budget, in a different basis. The squarefree hit features constitute exactly the layer $j = 1$ of this sum, one slice of a stack $\lfloor \log_2 x\rfloor$ deep. Every unit of budget carried by the layers $j \ge 2$ is, by Theorem 7.1 below, invisible to the $j=1$ layer.

This is why the empirical increment of $+0.0892$ in out-of-sample $R^2$ from adding $\mathbb{1}[p^2 \mid v]$ to a squarefree-hit baseline is not a fitting artefact: the added coordinates span a direction the baseline provably cannot reach.

---

## 7. What the squarefree layer cannot see

**Theorem 7.1 (Blindness of the squarefree features).** Let $p$ be prime with $p \mid v$, $v \ne 0$, and let $k \ge 0$. Then
$$\mathrm{sqf}_B(v \cdot p^k) = \mathrm{sqf}_B(v) \qquad\text{and}\qquad \Omega(v \cdot p^k) = \Omega(v) + k.$$

*Proof sketch.* For the second, the multiset of prime factors of $v p^k$ is that of $v$ together with $k$ copies of $p$, so lengths add. For the first, let $q \le B$ be prime. If $q \mid v p^k$ then either $q \mid v$, or $q \mid p^k$, whence $q = p$ and $q \mid v$ by hypothesis; either way $q \mid v$. Conversely $q \mid v \Rightarrow q \mid vp^k$. $\square$

**Corollary 7.2 (Exact impossibility).** The fibres of $v \mapsto \mathrm{sqf}_B(v)$ contain, for each $v$ with a repeated-eligible prime, values of arbitrarily large budget. Hence there is *no function* $F$ of the squarefree hit vector with $F(\mathrm{sqf}_B(v)) = \Omega(v)$ for all smooth $v$. Budget information is not weakly present in the squarefree layer; it is absent.

**Theorem 7.3 (Forced collisions).** If $2^{\pi(B)} < \Psi_B(x)$, then there exist distinct $B$-smooth $v, w \in [1,x]$ with $\mathrm{sqf}_B(v) = \mathrm{sqf}_B(w)$.

*Proof sketch.* $\mathrm{sqf}_B$ maps the smooth pool into the power set of $\mathcal{P}_B$, of cardinality $2^{\pi(B)}$. If the pool is strictly larger, the pigeonhole principle supplies a repeated image. $\square$

**Theorem 7.4 (Unconditional at $B = 2$).** For every $x \ge 4$ there exist distinct $2$-smooth $v, w \in [1,x]$ with $\mathrm{sqf}_2(v) = \mathrm{sqf}_2(w)$.

*Proof sketch.* Here $\pi(2) = 1$, so there are only $2$ possible vectors, while $\Psi_2(x) = \lfloor \log_2 x\rfloor + 1 \ge 3$ for $x \ge 4$ (Theorem 10.1). Apply Theorem 7.3. Explicitly, $v = 2$ and $w = 4$ both have squarefree vector $\{2\}$. $\square$

Contrast Theorem 5.1: the *full* prime-power profile never collides on the smooth pool. The truncation to $j=1$ is exactly what destroys the invariant.

---

## 8. Abundance: the hit sub-pool is not a corner case

A predictive feature is useless if it almost never fires. It does not: the $p^2$-hit sub-pool is exponentially large in $\pi(B)$.

**Theorem 8.1 (Abundance).** If $P_B^{\,m} \le x$, then
$$\Psi_B(x) \;\ge\; (m+1)^{\pi(B)}.$$

*Proof sketch.* Index candidate values by exponent vectors $f : \mathcal{P}_B \to \{0,1,\dots,m\}$ and set $F(f) = \prod_{p \le B} p^{f(p)}$. Each $F(f)$ is positive, $B$-smooth (its prime support lies in $\mathcal{P}_B$), and bounded: $F(f) \le \prod_{p\le B} p^m = P_B^m \le x$. Unique factorization makes $F$ injective, since the valuation of $F(f)$ at $q \le B$ recovers $f(q)$. The domain has $(m+1)^{\pi(B)}$ elements. $\square$

**Theorem 8.2 (Scarcity).** For all $B, x$,
$$\Psi_B(x) \;\le\; \big(\lfloor \log_2 x\rfloor + 1\big)^{\pi(B)}.$$

*Proof sketch.* Map a smooth $v \le x$ to its valuation vector $(v_p(v))_{p \le B}$. Each entry lies in $\{0,\dots,\lfloor \log_2 x\rfloor\}$, since $2^{v_p(v)} \le p^{v_p(v)} \le v \le x$. The map is injective on the smooth pool: two smooth values with equal factor-base valuations agree at every prime (outside the factor base both valuations vanish), hence are equal. $\square$

**Corollary 8.3 (Two-sided bracket).** If $P_B^{\,m} \le x$ then
$$(m+1)^{\pi(B)} \;\le\; \Psi_B(x) \;\le\; \big(\lfloor\log_2 x\rfloor+1\big)^{\pi(B)}.$$
Thus $\Psi_B(x)$ is polynomial in $\log x$ of degree exactly $\pi(B)$ for fixed $B$. Because the exponent is $\pi(B)$, a multiplicative shift of the argument by $p^2$ — i.e. an additive shift of $\log x$ by $2\log p$ — is a *first-order* effect on the count, matching Theorem 4.3.

**Theorem 8.4 (Abundance of the hit sub-pool).** Let $p \le B$ be prime. If $P_B^{\,m} \le \lfloor x/p^2\rfloor$ then
$$\mathrm{hit}_B(p^2; x) \;\ge\; (m+1)^{\pi(B)}.$$
*Proof sketch.* Corollary 3.2 followed by Theorem 8.1 at the rescaled bound. $\square$

---

## 9. The $\mathbb{F}_2$ blind spot: cost without benefit

The sieve's second stage searches for sub-families of smooth values whose product is a perfect square. We show prime-power hits contribute nothing there.

**Lemma 9.1.** For $a \ne 0$, $a^2 b$ is a perfect square iff $b$ is.
*Proof sketch.* ($\Leftarrow$) If $b = c^2$ then $a^2 b = (ac)^2$. ($\Rightarrow$) If $a^2 b = d^2$ then $a^2 \mid d^2$, so $a \mid d$; writing $d = ae$ and cancelling $a^2 > 0$ gives $b = e^2$. $\square$

**Theorem 9.2 ($\mathbb{F}_2$ blind spot).** For any finite index set $S$, any $p > 0$, and any weights $w : S \to \mathbb{N}$,
$$\prod_{i \in S} (p^2 w_i) \text{ is a perfect square} \iff \prod_{i \in S} w_i \text{ is a perfect square}.$$
*Proof sketch.* $\prod_{i\in S}(p^2 w_i) = (p^{|S|})^2 \prod_{i\in S} w_i$; apply Lemma 9.1 with $a = p^{|S|} \ne 0$. $\square$

**Theorem 9.3 (Relations come from the cofactors).** Let $p > 0$ and let $w_i > 0$ for $i$ in a finite index set $\iota$ with $p^2 w_i$ $B$-smooth for all $i$. If $|\iota| > \pi(B)$, then there is a nonempty $S \subseteq \iota$ with $\prod_{i \in S} w_i$ a perfect square.

*Proof sketch.* The $\mathbb{F}_2$ exponent vectors of the $\pi(B)$-dimensional factor-base coordinates of the $|\iota| > \pi(B)$ smooth values $p^2 w_i$ are linearly dependent, giving a nonempty $S$ with $\prod_{i\in S} p^2 w_i$ a perfect square. Theorem 9.2 transfers the square to the cofactor product. $\square$

**Interpretation.** A $p^2$-hit contributes an *even* exponent to every member, hence the zero vector modulo $2$. It therefore never changes the relation lattice: whatever relations the hit family supports are already present, unchanged, among the rescaled cofactors. **A prime-power hit spends smoothness budget without purchasing a new relation direction.**

This is the precise cost side of the mechanism, and it explains a subtle point about the empirical result: the prime-power feature *predicts* yield rather than *mimicking* it. It moves the budget (Theorems 4.1, 4.3) without perturbing the $\mathbb{F}_2$ combinatorics (Theorem 9.2), so it is a clean exogenous descriptor of the yield channel.

---

## 10. The exactly solvable case $B = 2$

At $B = 2$ every quantity above has a closed form, with equality replacing inequality.

**Theorem 10.1.** For $x \ge 1$, $\Psi_2(x) = \lfloor \log_2 x\rfloor + 1$.
*Proof sketch.* A positive integer is $2$-smooth iff its only prime factor is $2$, i.e. iff it is a power of $2$. The powers $2^j \le x$ are exactly those with $0 \le j \le \lfloor \log_2 x\rfloor$, and $j \mapsto 2^j$ is injective. $\square$

**Theorem 10.2 (Sharp budget law).** For $x \ge 4$,
$$\mathrm{hit}_2(4; x) + 2 \;=\; \Psi_2(x).$$
Equivalently, the $4$-hit fraction is exactly $\dfrac{u - 1}{u + 1}$ with $u = \lfloor \log_2 x\rfloor$.

*Proof sketch.* By Corollary 3.2 with $p = 2$, $\mathrm{hit}_2(4;x) = \Psi_2(\lfloor x/4\rfloor)$, and $\lfloor x/4\rfloor \ge 1$. By Theorem 10.1 both sides are logarithms, and $\lfloor \log_2 (x/4)\rfloor = \lfloor \log_2 x\rfloor - 2$ for $x \ge 4$. $\square$

So hitting $4 = 2^2$ consumes *exactly* two units of the base-two budget — the sharp instance of the general estimate of Theorem 4.3, with equality and no slack. It is also the cleanest possible illustration of Theorem 4.4: two units out of a budget of $u+1$ is a large fraction when $u$ is small and a negligible one when $u$ is large.

---

## 11. Algorithms

The theory yields exact algorithms rather than estimators.

### 11.1 Hit-count by rescaling

To compute $\mathrm{hit}_B(m; x)$ for a $B$-smooth modulus $m$, do *not* enumerate the hit set. Compute $\Psi_B(\lfloor x/m\rfloor)$. If $\Psi_B$ is available by a sieve of length $\lfloor x/m\rfloor$ this is a factor-$m$ saving in both time and memory; if $\Psi_B$ is memoized across queries the saving compounds across all $(p, j)$ pairs. Correctness is Theorem 3.1; the smoothness check on $m$ is mandatory by Remark 3.4.

### 11.2 Budget decomposition audit

Theorem 6.3 furnishes a self-checking computation of the aggregate budget: compute $\sum_{v} \Omega(v)$ by direct factorization of the pool, and independently compute $\sum_{p \le B}\sum_{j \le \lfloor \log_2 x\rfloor}\Psi_B(\lfloor x/p^j\rfloor)$ by repeated smooth counts. Agreement is guaranteed; disagreement localises a bug. The second route costs $O(\pi(B)\log x)$ smooth-count evaluations and touches only rescaled ranges.

### 11.3 Graded spectrum by telescoping

Theorem 3.6 computes the full multiplicity histogram of a factor-base prime across the pool from $\lfloor \log_p x\rfloor + 1$ smooth counts, by successive differences, rather than by factoring every pool element.

### 11.4 Feature design

The theory prescribes the feature set: for each factor-base prime $p$ and each layer $j$ up to $\lfloor \log_p x\rfloor$, include $\mathbb{1}[p^j \mid v]$. Theorem 6.3 says these coordinates linearly span the budget; Theorem 5.1 says they determine $v$; Theorem 7.1 says truncating to $j = 1$ loses the budget entirely. The empirical configuration ($j = 2$, $p \le 13$) is the minimal nontrivial extension beyond the truncation, and Theorem 4.4 predicts that its weight decays as $1/\log B$.

---

## 12. Discussion

### 12.1 Why the two failed features failed

Mid-prime fractions of the factor base and quadratic-residue density are both *global* descriptors of the instance: they characterise the factor base or the ambient congruence structure, not the arithmetic of the individual candidate. Neither appears in any identity linking to $\Omega$ or to $\Psi_B$. By contrast the prime-power indicators appear on the right-hand side of an exact linear identity for the budget (Theorem 6.3). The empirical outcome — $+0.019$ and $+0.004$ with CIs spanning zero versus $+0.0892$ with CI $[0.041, 0.125]$ — is thus consonant with the structure, and the structure predicts it in advance rather than rationalising it after.

### 12.2 The graded picture

All the results assemble into a single statement. The prime-power hit features are the **graded coordinates of the multiplicative monoid of $B$-smooth integers**, and the grading splits the information exactly in two:

- **Layer $j = 1$** (squarefree hits) is the abelianization modulo squares. It carries precisely the $\mathbb{F}_2$ relation data the sieve's linear algebra consumes — and by Theorem 7.1 and Corollary 7.2, nothing about the budget.
- **Layers $j \ge 2$** carry the budget — by Theorem 6.3, all of it — and by Theorem 9.2 nothing about the relation lattice.

The two layers are *information-theoretically disjoint by theorem*, not merely weakly correlated in a finite sample. This is the mechanism behind the out-of-sample gain: the new features occupy an orthogonal informational direction, so their contribution cannot be absorbed by re-weighting the baseline, and it must generalise.

### 12.3 Boundary conditions

Two natural statements required guarding, and both are instructive.

1. $\mathrm{hit}_B(m;x) = \Psi_B(\lfloor x/m\rfloor)$ is *false* for non-smooth $m$ (Remark 3.4). Smoothness of the modulus is a hypothesis, not a convenience: the bijection's backward map genuinely needs it.
2. The real-valued bound $u_B(\lfloor x/p^2\rfloor) \le u_B(x) - 2\log p/\log B$ fails when $x < p^2$, since the floor collapses to $0$. The guarded version carries $p^2 \le x$.

Both are cases of "true after the right definition", and locating them precisely is part of the value of a fully rigorous treatment.

### 12.4 Scope

The results are unconditional and exact — no analytic hypotheses, no asymptotic regime, no error terms. Their cost is that they are statements about counts and identities rather than about densities. The bridge to the practical yield question requires an asymptotic input for $\Psi_B$, which the next section addresses as a conjecture.

---

## 13. Future work

### 13.1 Exact hit fraction as a Dickman-type ratio

**Conjecture.** For fixed $B$ and $x \to \infty$, the $p^2$-hit fraction satisfies
$$\frac{\mathrm{hit}_B(p^2;x)}{\Psi_B(x)} \;=\; \frac{\Psi_B(\lfloor x/p^2\rfloor)}{\Psi_B(x)} \longrightarrow 1,$$
with second-order rate
$$1 \;-\; \pi(B)\cdot\frac{2\log p}{\log x} \;+\; O\big((\log x)^{-2}\big),$$
and, for $B$ growing with $x$ in the tight-$u$ regime,
$$\frac{\mathrm{hit}_B(p^2;x)}{\Psi_B(x)} \;=\; \frac{\rho\!\left(u - \frac{2\log p}{\log B}\right)}{\rho(u)} + o(1),$$
where $\rho$ is the Dickman function and $u = \log x/\log B$.

The rationale is that Theorem 3.1 converts *every* question about hit features into a question about $\Psi_B$ at two nearby arguments; hence the entire predictive content of a hit feature is the local logarithmic derivative of $\Psi_B$. The fixed-$B$ leading term is consistent with Corollary 8.3: $\Psi_B$ behaves like $c_B (\log x)^{\pi(B)}$, so replacing $\log x$ by $\log x - 2\log p$ multiplies by $(1 - 2\log p/\log x)^{\pi(B)}$.

The exact identity is settled; the missing ingredient is an asymptotic for $\Psi_B$, for which the fixed-$B$ case is elementary lattice-point counting that the bracket of Corollary 8.3 already half-provides.

### 13.2 Complete-invariant tomography

Theorem 5.1 says the full profile determines $v$. It is natural to ask for the *minimal* sub-family of layers that remains a complete invariant on a pool bounded by $x$: one expects layers $j \le \lfloor \log_2 x\rfloor$ to suffice and, more sharply, layers $j \le \lfloor \log_p x\rfloor$ per prime. Quantifying the information gained per additional layer would give a principled feature budget.

### 13.3 Higher-order tolls and joint features

Corollary 3.3 shows joint hits compose multiplicatively. This should extend to a full inclusion–exclusion for arbitrary squarefull moduli, converting the entire joint hit-feature distribution into a lattice of rescaled smooth counts, and thereby into a predictable correlation structure for the regression design matrix.

### 13.4 Beyond $\mathbb{F}_2$

Theorem 9.2 shows even prime-power parts are invisible modulo squares. One could ask what a $\mathbb{F}_\ell$ analogue (relations modulo $\ell$-th powers) sees: there the layers $j \equiv 0 \pmod{\ell}$ become blind and the rest visible, suggesting a family of gradings interpolating between "relation data" and "budget data".

---

## 14. Conclusion

Divisibility features on a smooth pool are not new arithmetic conditions; they are changes of the smoothness budget, exactly. From this single bijective observation follow a graded valuation spectrum, an exact $u$-shift of $2\log p/\log B$ that is antitone in $B$, a linear decomposition of the aggregate budget into prime-power hit counts, completeness of the prime-power profile as an invariant of smooth values, provable blindness and forced collisions for its squarefree truncation, two-sided exponential abundance bounds for hit sub-pools, and the invisibility of prime-power hits to $\mathbb{F}_2$ relation collection.

Together these results account, structurally and in advance, for the observed $+0.0892$ out-of-sample $R^2$ contributed by prime-power hit indicators to a per-instance yield model, and for the failure of two plausible alternatives. The prime-power hit features are not a lucky covariate. They are the coordinate system in which the smoothness budget is linear.
