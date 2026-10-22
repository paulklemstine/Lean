# Counted and Uncounted Costs in Pollard's Rho: An Exact Boundary for Local Wins and the $\gcd(E, p-1) = 1$ Automorphism Cliff

**Author:** Aristotle

**Date:** 2026-10-22

---

## Abstract

Cycle-finding speedups for Pollard's rho method are usually quoted in a single currency, the number of group operations (modular multiplications). We show that this convention can mislead, and we state exactly when it does not. We model rho-shaped sequences with tail $\mu$ and period $\lambda$ and compute the exact costs of Floyd's and Brent's detectors in two channels: map *evaluations* (the counted channel) and *comparisons* (the uncounted channel, i.e. gcds). For every rho shape, Brent uses strictly fewer evaluations than Floyd, with the sharp inequality $B + 1 \le 2F + \lambda \le 3F$, where $F$ is Floyd's stopping index and $B$ is Brent's evaluation count. Also for every rho shape, Floyd uses no more comparisons than Brent. In the linear wall-clock model $W = a\cdot\text{evals} + b\cdot\text{comps}$ the comparison between the two is an exact identity, and the boundary is sharp: for every $b > 0$ and $a \ge 0$, Brent is strictly slower than Floyd on the pure cycle of length $2^m + 1$ once $m$ is large enough. This yields a *local-win law*: a local win survives into wall-clock time if and only if it reduces the counted operations without changing the cost per operation and without increasing the operations that are not counted. Experiments over three scales confirm Brent as a genuine survivor, with a $26.7\%$ cut in multiplications, and show that the uncounted channel absorbs $46\%$ of it, leaving a $13.8\%$ wall-clock gain. We then prove the *automorphism cliff*. For $E \ge 1$, the map $x \mapsto x^E + c$ permutes $\mathbb{Z}/p\mathbb{Z}$ if and only if $\gcd(E, p-1) = 1$. In that case every orbit is a pure cycle and Floyd's detector stops exactly at the cycle length. Otherwise every orbit closes within $(p-1)/\gcd(E,p-1) + 2$ steps. At $p = 65537$ the cubic map is a permutation for every $c$ and was measured to be $104.9\times$ slower than the quadratic map, so the folklore "exponent 2 is optimal" is an average that hides a discontinuity of roughly a factor of 100 depending on $p$.

---

## 1. Introduction

Pollard's rho method [Pollard 1975] finds a prime factor $p$ of a composite $N$ by iterating a map $f(x) = x^2 + c \bmod N$ from a seed $x_0$. The reduced sequence $x_i \bmod p$ is eventually periodic, and a collision $x_i \equiv x_j \pmod p$ shows up as a nontrivial $\gcd(x_i - x_j, N)$. Under the heuristic that $f$ behaves like a random map, the first collision modulo $p$ occurs after about $\sqrt{\pi p/2}$ steps.

Because the collision is not observable directly, one runs a *cycle detector* that stores $O(1)$ iterates. The two classical choices are Floyd's tortoise-and-hare (see [Knuth, Vol. 2, §3.1]) and Brent's power-of-two scheme [Brent 1980]. The standard comparison counts group operations, and on that measure Brent's method wins.

This paper looks closely at the gap between that statement and wall-clock time. Its contributions are:

1. **Exact two-channel analysis (Section 3).** For a general rho-shaped sequence we characterise exactly where each detector stops, and we prove that Brent beats Floyd in evaluations on *every* shape while Floyd beats Brent in comparisons on every shape.
2. **The local-win law and its sharpness (Section 4).** In a linear cost model the wall-clock comparison is an exact identity. For any positive comparison price, some shape reverses the verdict.
3. **The automorphism cliff (Section 5).** A complete characterisation of when the generalised rho map $x \mapsto x^E + c$ is a permutation, the resulting pure-cycle structure, and a compression bound in the complementary case.
4. **Empirical constants (Section 6).** Paired measurements of both channels across three scales, the decomposition of the wall-clock gain, validation of the instrument, and the cliff measured at $p = 65537$.

Throughout, $\mathbb{N} = \{0, 1, 2, \dots\}$, and for a map $f$ and seed $a$ we write $x_i = f^{i}(a)$ for the orbit.

---

## 2. Setting and definitions

### 2.1 Rho-shaped sequences

**Definition 2.1 (rho shape).** Let $\mu \in \mathbb{N}$ and $\lambda \ge 1$. A sequence $(x_i)_{i \in \mathbb{N}}$ is *rho-shaped with tail $\mu$ and period $\lambda$* if

1. (periodicity) $x_{i+\lambda} = x_i$ for all $i \ge \mu$, and
2. (injective prefix) $x_0, x_1, \dots, x_{\mu+\lambda-1}$ are pairwise distinct.

Every orbit of a self-map of a finite set is rho-shaped. So is every reduced Pollard-rho walk modulo $p$.

**Definition 2.2 (closure time).** For a self-map $f$ of a finite set and a seed $a$, the *closure time* $T(a, f)$ is the least $n$ such that $x_0, \dots, x_n$ are *not* pairwise distinct. If the orbit has tail $\mu$ and period $\lambda$, then $T(a,f) = \mu + \lambda$, which is the number of distinct points in the orbit.

### 2.2 The two detectors

**Floyd.** For $i = 1, 2, \dots$, compute $x_i$ and $x_{2i}$ (one step for the tortoise, two for the hare) and compare them. Stop at the first $i > 0$ with $x_i = x_{2i}$. Each index costs **3 evaluations and 1 comparison**.

**Brent (power-of-two variant).** For rounds $k = 0, 1, 2, \dots$, save $x_{2^k - 1}$ and compare it with $x_{2^k - 1 + j}$ for $j = 1, \dots, 2^k$. Stop at the first match. Each step costs **1 evaluation and 1 comparison**, and every iterate up to the stopping index is computed exactly once.

### 2.3 The two-channel cost model

**Definition 2.3.** The *counted channel* is the number of evaluations of $f$; for $f(x) = x^2 + c$ these are modular multiplications, or group operations. The *uncounted channel* is the number of comparisons; in factoring these are gcd computations, or subtractions folded into a batched gcd. For prices $a, b \in \mathbb{R}$ the *wall-clock cost* is
$$W_{a,b}(\text{evals}, \text{comps}) = a\cdot \text{evals} + b \cdot \text{comps}.$$

There is also a third channel, the *cost per evaluation*, which is fixed by the exponent $E$ in $f(x) = x^E + c$. It matters in Section 5.

---

## 3. Exact analysis of the detectors

Fix a rho-shaped sequence $(x_i)$ with tail $\mu$ and period $\lambda \ge 1$.

**Lemma 3.1 (exact collision law).** For $i \le j$,
$$x_i = x_j \iff i = j \ \text{ or } \ \big(\mu \le i \ \text{ and } \ \lambda \mid j - i\big).$$

*Proof sketch.* Define the reduction $r(i) = i$ for $i < \mu$ and $r(i) = \mu + ((i - \mu) \bmod \lambda)$ for $i \ge \mu$. Periodicity gives $x_i = x_{r(i)}$, and $r(i) < \mu + \lambda$ always. By the injective prefix, $x_i = x_j$ iff $r(i) = r(j)$. If $i < \mu$ then $r(i) = i < \mu$, which equals $r(j)$ only when $j = i$. If $\mu \le i \le j$, then $r(i) = r(j)$ iff $(i - \mu) \equiv (j - \mu) \pmod \lambda$, i.e. iff $\lambda \mid j - i$. $\square$

### 3.1 Floyd

**Proposition 3.2 (Floyd's matching criterion).** For $i > 0$: $x_i = x_{2i} \iff \mu \le i$ and $\lambda \mid i$.

*Proof.* Apply Lemma 3.1 with $j = 2i$. The case $i = 2i$ would force $i = 0$. $\square$

**Definition 3.3.** Let $F = F(\mu,\lambda)$ be the least $i > 0$ with $\mu \le i$ and $\lambda \mid i$. Explicitly, $F = \lambda \cdot \max(1, \lceil \mu/\lambda \rceil)$.

**Theorem 3.4 (Floyd stops exactly at $F$).** We have $F > 0$ and $x_F = x_{2F}$, and $x_i \ne x_{2i}$ for every $0 < i < F$. Floyd's detector therefore performs exactly $3F$ evaluations and $F$ comparisons.

**Lemma 3.5 (bounds on $F$).** (a) $\lambda \le F$. (b) If $\mu > 0$, then $F + 1 \le \mu + \lambda$. (c) If $\mu = 0$, then $F = \lambda$.

*Proof sketch.* (a) $F$ is a positive multiple of $\lambda$. (b) Among $\mu, \mu+1, \dots, \mu+\lambda-1$ there is a multiple of $\lambda$, and it is positive because $\mu > 0$. (c) is immediate. $\square$

### 3.2 Brent

**Proposition 3.6 (Brent's matching criterion).** For $k \in \mathbb{N}$ and $j \ge 1$,
$$x_{2^k - 1} = x_{2^k - 1 + j} \iff \mu < 2^k \ \text{ and } \ \lambda \mid j.$$

*Proof.* Apply Lemma 3.1 to the indices $2^k - 1 \le 2^k - 1 + j$. Note that $\mu \le 2^k - 1$ is the same as $\mu < 2^k$. $\square$

**Definition 3.7.** Let $K = K(\mu, \lambda)$ be the least $k$ with $\mu < 2^k$ and $\lambda \le 2^k$.

**Theorem 3.8 (Brent stops exactly at round $K$, offset $\lambda$).** We have $x_{2^K - 1} = x_{2^K - 1 + \lambda}$. No test in an earlier round $k < K$ succeeds (for any $1 \le j \le 2^k$), and no test in round $K$ with $1 \le j < \lambda$ succeeds. Hence Brent performs
$$B := 2^K - 1 + \lambda \ \text{ evaluations, and } \ \sum_{k < K} 2^k + \lambda = B \ \text{ comparisons.}$$

*Proof sketch.* Proposition 3.6 with $j = \lambda$ and $k = K$ gives the match. In a round $k < K$ a match would require $\mu < 2^k$ and some $1 \le j \le 2^k$ with $\lambda \mid j$, hence $\lambda \le 2^k$, contradicting the minimality of $K$. In round $K$ a match at $j < \lambda$ would need $\lambda \mid j$ with $0 < j < \lambda$, which is impossible. The comparison count is the full rounds $k < K$ plus $\lambda$ tests in round $K$. The identity $\sum_{k<K}2^k + 1 = 2^K$ shows that comparisons equal evaluations. $\square$

### 3.3 The survivor and the other channel

**Theorem 3.9 (the survivor, sharp form).** For every rho shape,
$$B + 1 \ \le\ 2F + \lambda \ \le\ 3F.$$
In particular $B < 3F$: **Brent uses strictly fewer evaluations than Floyd on every rho shape.** The counted ratio Brent/Floyd never reaches $1$.

*Proof sketch.* If $K = 0$ then $\mu = 0$ and $\lambda = 1$, so $B = 1$ and $F = 1$, and $2 \le 3$. If $K \ge 1$, put $h = 2^{K-1}$, so $B + 1 = 2h + \lambda$, and it suffices to show $h \le F$. By minimality of $K$, round $K - 1$ fails, so either $\mu \ge h$ or $\lambda > h$. In the first case $F \ge \mu \ge h$ by the definition of $F$. In the second case $F \ge \lambda > h$ by Lemma 3.5(a). Finally $2F + \lambda \le 3F$ by Lemma 3.5(a). $\square$

**Theorem 3.10 (the uncounted channel moves the other way).** For every rho shape, Floyd's comparisons satisfy $F \le B$, i.e. Floyd never uses more comparisons than Brent.

*Proof sketch.* If $\mu = 0$ then $F = \lambda \le 2^K - 1 + \lambda$. If $\mu > 0$ then, by Lemma 3.5(b), $F \le \mu + \lambda - 1 \le (2^K - 1) + \lambda - 1 < B$, using $\mu < 2^K$. $\square$

So on the evaluation channel Brent spends one evaluation per new iterate, which is the minimum for any detector that must compute the iterates it compares, while Floyd spends three. On the comparison channel Floyd spends one comparison per three evaluations, while Brent spends one per evaluation.

---

## 4. The local-win law

**Theorem 4.1 (the boundary as an identity).** For all real prices $a, b$,
$$W_{a,b}(B, B) < W_{a,b}(3F, F) \iff b\,(B - F) < a\,(3F - B).$$

The left side compares wall-clock times. On the right, $3F - B > 0$ is the counted saving (Theorem 3.9) and $B - F \ge 0$ is the uncounted overrun (Theorem 3.10). The proof is a rearrangement of a linear inequality.

**Lemma 4.2 (pure cycles of length $2^m + 1$).** For $\mu = 0$ and $\lambda = 2^m + 1$: $K = m + 1$, Floyd uses $3(2^m + 1)$ evaluations and $2^m + 1$ comparisons, and Brent uses $3\cdot 2^m$ evaluations and $3 \cdot 2^m$ comparisons.

*Proof sketch.* $2^m < \lambda \le 2^{m+1}$ forces $K = m + 1$. Then $B = 2^{m+1} - 1 + 2^m + 1 = 3 \cdot 2^m$, and $F = \lambda$ by Lemma 3.5(c). $\square$

On these shapes the counted saving is exactly $3$ evaluations, while the uncounted overrun is $2^{m+1} - 1$ comparisons.

**Theorem 4.3 (the boundary is sharp).** For every $a \ge 0$ and $b > 0$ there is a tail-free rho shape (namely $\lambda = 2^m + 1$ for $m$ large) on which Brent uses strictly fewer evaluations than Floyd and yet
$$W_{a,b}(\text{Floyd}) < W_{a,b}(\text{Brent}).$$

*Proof sketch.* By Lemma 4.2, $W(\text{Brent}) - W(\text{Floyd}) = b(2^{m+1} - 1) - 3a$. This is positive as soon as $2^{m} > (3a + 3b)/b$, which holds for $m$ large because $2^m$ is unbounded. $\square$

For example, with $a = 1$ and $b = 0.05$, Floyd already wins on the clock at $\lambda = 2^6 + 1 = 65$ ($198.25$ against $201.60$ units).

**The local-win law.** Theorems 3.9, 3.10, 4.1 and 4.3 together justify the following principle, which we propose as the general rule for assessing algorithmic "local wins":

> *A local win survives into wall-clock time if and only if it reduces the counted operations, without changing what an operation costs, and without increasing the operations that are not in the count.*

Rho has three movable channels: (i) modular multiplications (counted); (ii) gcds and comparisons (uncounted, about $0.64\sqrt p$ in practice); and (iii) the cost per operation, set by $E$. Brent moves only channel (i), strongly in its favour, so it survives. But Theorem 3.10 says channel (ii) does not follow channel (i), and Theorem 4.3 says that with adversarial shapes channel (ii) can overturn the result. A claim stated in channel (i) alone describes only part of the cost.

**Floor.** Brent evaluates $f$ once per new iterate, the minimum for $x^2 + c$, so no further win of the same shape (fewer evaluations of the same map) is available.

---

## 5. The automorphism cliff

Let $p$ be prime and, for $E \ge 1$ and $c \in \mathbb{Z}/p\mathbb{Z}$, let $\rho_{E,c}(x) = x^E + c$ on $\mathbb{Z}/p\mathbb{Z}$.

### 5.1 Orbits of permutations

**Theorem 5.1 (first collision returns to the seed).** Let $f$ be an injective self-map of a finite set and $T = T(a, f)$. Then $x_T = a$.

*Proof sketch.* By minimality of $T$, the points $x_0, \dots, x_{T-1}$ are distinct, and some $x_i = x_j$ with $i \ne j$ and $i, j \le T$. Necessarily one index is $T$, say $x_i = x_T$ with $i < T$. If $i > 0$, then $f(x_{i-1}) = f(x_{T-1})$, and injectivity gives $x_{i-1} = x_{T-1}$, a collision among $x_0,\dots,x_{T-1}$, which is a contradiction. So $i = 0$. $\square$

**Corollary 5.2 (pure-cycle structure).** The orbit of an injective $f$ is rho-shaped with tail $0$ and period $T(a, f)$.

**Corollary 5.3 (Floyd is exact on permutations).** For injective $f$, Floyd's detector stops exactly at $T(a, f)$: $x_T = x_{2T}$ and $x_i \ne x_{2i}$ for $0 < i < T$. (In general one only has $T \le 2F$; on permutations the two coincide.)

*Proof.* Combine Corollary 5.2 with Lemma 3.5(c). $\square$

### 5.2 The criterion

**Theorem 5.4 (the cliff criterion).** For $E \ge 1$, the power map $x \mapsto x^E$ is injective on $\mathbb{Z}/p\mathbb{Z}$ if and only if $\gcd(E, p - 1) = 1$. Consequently, for every $c$,
$$\rho_{E,c} \text{ is a bijection of } \mathbb{Z}/p\mathbb{Z} \iff \gcd(E, p-1) = 1.$$

*Proof sketch.* ($\Leftarrow$) The unit group $(\mathbb{Z}/p\mathbb{Z})^\times$ has order $p - 1$. When $\gcd(E, p-1) = 1$, raising to the $E$-th power is an automorphism of it, with inverse $x \mapsto x^{E'}$ where $EE' \equiv 1 \pmod{p-1}$. Also $0^E = 0$ and $x^E \ne 0$ for $x \ne 0$. ($\Rightarrow$) If a prime $r$ divides $\gcd(E, p-1)$, Cauchy's theorem gives a unit $g$ of order $r$. Then $g^E = 1 = 1^E$ with $g \ne 1$, so the map is not injective. Translation by $c$ preserves injectivity, and on a finite set injective is the same as bijective. $\square$

**Remark.** For odd $p$, $\gcd(2, p-1) = 2$, so the textbook map $x^2 + c$ is *never* a permutation. This is the structural reason it works.

### 5.3 The compression side

**Lemma 5.5.** Let $d = \gcd(E, p-1)$. For every nonzero $x$, $(x^E)^{(p-1)/d} = 1$. Hence the image of $x \mapsto x^E$ lies in $S_E = \{0\} \cup \{\zeta : \zeta^{(p-1)/d} = 1\}$, which has at most $(p-1)/d + 1$ elements.

*Proof sketch.* $(x^E)^{(p-1)/d} = (x^{p-1})^{E/d} = 1$ by Fermat's little theorem. A polynomial of degree $(p-1)/d$ over a field has at most that many roots. $\square$

**Theorem 5.6 (compression bound).** For every $E \ge 1$, every $c$ and every seed $a$,
$$T(a, \rho_{E,c}) \le \frac{p-1}{\gcd(E, p-1)} + 2.$$

*Proof sketch.* Put $m = (p-1)/d$. The $m + 2$ points $x_1, \dots, x_{m+2}$ all lie in the translate $S_E + c$, which has at most $m + 1$ elements. By pigeonhole two of them coincide, so $x_0, \dots, x_{m+2}$ are not distinct and $T \le m + 2$. $\square$

### 5.4 The automorphism side reaches $p$

**Theorem 5.7 (the successor map).** For $E = 1$ and $c = 1$, every orbit has closure time exactly $p$.

*Proof sketch.* $x_i = a + i$. These are distinct for $0 \le i \le p - 1$ and $x_p = a$. $\square$

So among coprime exponents the closure time can reach the maximum value $p$, whereas a random map has closure time of order $\sqrt{p}$.

### 5.5 The dichotomy

**Theorem 5.8 (the automorphism cliff).** Let $E \ge 1$ and $c \in \mathbb{Z}/p\mathbb{Z}$.

1. If $\gcd(E, p-1) = 1$, then for every seed $a$ the orbit of $\rho_{E,c}$ is a pure cycle of length $T = T(a, \rho_{E,c})$ with $x_T = a$, and Brent uses at most $3T - 1$ evaluations against Floyd's $3T$.
2. In all cases, every orbit closes within $(p-1)/\gcd(E,p-1) + 2$ steps.

**Corollary 5.9 (the Fermat prime $65537$).** Since $65536 = 2^{16}$, we have $\gcd(3, 65536) = 1$, so $x \mapsto x^3 + c$ is a permutation of $\mathbb{Z}/65537\mathbb{Z}$ **for every $c$**. In contrast $x \mapsto x^2 + c$ is never a permutation there, and every one of its orbits closes within $32768 + 2 = 32770$ steps.

### 5.6 Interpretation

The map $x \mapsto x^E + c$ induces $x \mapsto x^E$ on $(\mathbb{Z}/p\mathbb{Z})^\times$. Rho needs the walk to *merge* paths: many-to-one behaviour is what drives birthday-type collisions after $\Theta(\sqrt p)$ steps. When $\gcd(E, p-1) = 1$ there is no merging at all, the walk lies on the cycles of a permutation, and these are typically of length comparable to $p$. A uniformly random permutation of $n$ points places a given point on a cycle of length uniformly distributed on $\{1, \dots, n\}$, so the expected cycle length is $(n+1)/2$. The resource rho consumes is thus the *structure of $(\mathbb{Z}/p\mathbb{Z})^\times$*, exactly what makes the walk random-like. Changing $E$ changes what an operation costs and also the dynamics, which violates clause two of the local-win law in its most severe form. "Exponent $k = 1$ in $x^{2^k} + c$ is optimal" is therefore an *average* over $p$ that hides a discontinuity of about $10^2$ governed by the arithmetic of $p - 1$.

---

## 6. Empirical study

### 6.1 Regime and protocol

Semiprimes $N < 2^{62}$ with the hidden prime $p \in [2^{19}, 2^{29}]$, at three sizes $b = 40, 46, 58$ bits of $N$ (a $32\times$ range in $\sqrt p$). Each row of the table uses one instance per run. Uncertainties are between-instance standard deviations. All arms were run on the *same* instances, so ratios are paired. Costs are reported as multiplications per $\sqrt p$.

### 6.2 Measured constants

| arm | $b=40$ | $b=46$ | $b=58$ |
|---|---|---|---|
| Floyd | $2.235 \pm 1.259$ ($1.78^*$) | $2.202 \pm 1.196$ | $2.281 \pm 1.237$ |
| **Brent** | $\mathbf{1.619 \pm 0.951}$ ($1.29^*$) | $\mathbf{1.581 \pm 0.865}$ | $\mathbf{1.617 \pm 0.906}$ |
| gcd-batched, $m = 32$ | $1.638$ | $1.587$ | $1.618$ |
| $x^4 + c$ / $x^8 + c$ | $2.460$ / $3.064$ | $2.396$ / $3.011$ | $2.420$ / $2.952$ |
| distinguished points | $2.500$ | $2.339$ | $2.273$ |
| negative control: $c = 0$ / $c = -2$ / $x^3 + c$ | $14.47$ / $12.26$ / $3.111$ | — | $19.46$ / $19.82$ / $2.900$ |
| mutation control: Brent's $r$ frozen | $1588/1600$ censored | $895/900$ | $900/900$ censored |

$^*$ normalised by $\sqrt{\pi/2}$. The negative controls behave as expected: $c = 0$ and $c = -2$ are the classically degenerate choices, since $x^2$ and $x^2 - 2$ are conjugate to monomial and Chebyshev dynamics. The mutation control (freezing the doubling of Brent's round length) is detected: nearly all runs hit the censoring limit.

### 6.3 The survivor, decomposed

- **Counted channel.** The paired ratio Brent/Floyd for multiplications is $0.7332 \pm 0.1499$, a cut of $26.7\%$, stable over three scales. The worst observed paired ratio was $0.9987$, so Brent essentially never loses in this channel, as Theorem 3.9 guarantees for every shape.
- **Uncounted channel.** Gcds fell by only $14.7\%$. Brent's detector index is $2.18\times$ Floyd's, so it buys its multiplication savings with a longer index and *more gcds per multiplication* ($0.636$ against $0.501$). (The measured implementations schedule gcds differently from the idealised model of Section 2.2, which is why the gcd channel fell somewhat rather than rising. In both cases it fails to follow the counted channel.)
- **Wall clock** ($b = 58$). Floyd $0.0062$ s and Brent $0.0052$ s per run, a paired ratio of $0.8623 \pm 0.1687$, i.e. a gain of $13.8\%$. **The uncounted channel absorbed $11.9$ of the $26.7$ points, or $46\%$.**
- **Gcd batching** ($m = 32$) relative to Brent: $0.9989$ (median $0.9930$). Removing $96.1\%$ of the gcds buys $0.11\%$ of wall-clock time.

So a claim that states only the counted channel overstates the practical gain by about $2\times$. Brent shows the first clause of the law at work: a large reduction of the expensive channel, with the cost per operation unchanged. Batching shows the converse: a large reduction of a channel that is already cheap is worth almost nothing.

### 6.4 First collision versus detection

A direct birthday simulator gives $1.2569\sqrt p$ for the first repeat, against $\sqrt{\pi/2} = 1.2533$, a ratio of $1.0029$, which validates the instrument. The rho orbit's own first collision gives $1.2423\sqrt p$ ($t = -0.63$, statistically indistinguishable from the birthday value). **Implementations, however, pay about $1.29\sqrt{\pi/2}$ rather than $\sqrt{\pi/2}$**, because a detector cannot stop at the first collision: Brent's stopping index is about $1.76\times$ the first-collision index and Floyd's about $2.43\times$.

The distribution of the cost is skewed to the right: for Brent the mean is $1.619$, the median $1.693$ and the 90th percentile $3.271$. Hence the "high-probability" constant (the median) sits $4.6\%$ *above* the expected one, the opposite of the hypothesis that motivated the experiment.

As an out-of-sample check, Cheon, Hong and Kim report measured rho constants of $1.244$–$1.325 \times \sqrt{\pi q/2}$ at 1024-bit primes. The value $1.292$ found here lies inside that band.

### 6.5 The cliff, measured

At $p = 65537$ the cubic walk ($\gcd(3, 65536) = 1$, so a permutation by Corollary 5.9) was **$104.9\times$ slower** than the quadratic walk. For $x^3 + c$ at $b = 40$, splitting instances by $\gcd(3, p - 1)$ gives median costs of $3.426\sqrt p$ (automorphism, $p \equiv 2 \bmod 3$), $2.204\sqrt p$ (compression, $p \equiv 1 \bmod 3$) and $1.696\sqrt p$ (quadratic baseline).

A small-scale rerun of the closure-time experiment, using fresh random seeds and constants at $p = 65537$, gives mean closure times of about $1.26\sqrt p$ for $E = 2$ and $E = 6$ ($d = 2$), $0.73\sqrt p$ for $E = 4$ ($d = 4$), and above $100\sqrt p$ for $E = 3$ and $E = 5$ (permutations). The ratio between cubic and quadratic closure times is about $100\times$, consistent with the measurement above.

### 6.6 Instrument validation

An oracle returning the exact $(\mu, \lambda)$ of each reduced walk makes both detectors' stopping indices available in closed form (Theorems 3.4 and 3.8). The measured index matched the analytic one on $1596/1596$ Floyd runs and $1595/1595$ Brent runs. The validation exposed four defects, all corrected before the final data were collected:

1. an accumulator initialisation that silently turned the "$x^2 + c$" arm into $x^3 + c$;
2. an off-by-one in Brent's comparison range;
3. silent truncation of inputs $N \ge 2^{64}$ during parsing, which invalidated an entire sweep (now rejected explicitly; a 330-bit RSA modulus is refused);
4. trivial collisions $g = N$ counted as successes in 24 runs. After the fix and full regeneration there were **0 bogus factors in 31 839 runs**.

### 6.7 Hazards and limits

- **"1.17" is not a rho constant.** It is a ratio of *parallel* costs in a published table of parallel rho variants. Using it as a sequential constant is a category error.
- **Montgomery's 14%** [Montgomery 1987] is a saving in the comparison channel. In group operations it is exactly neutral.
- **Scale.** No real RSA instance was attempted. For RSA-100 (330 bits), $\sqrt p \approx 6.2\times 10^{24}$, needing about $7.9 \times 10^{24}$ operations, roughly 17 orders of magnitude beyond feasible.
- **Distinguished points.** The distinguished-point arm over-charges relative to the backward walk-back of van Oorschot and Wiener, which is pessimistic for that challenger.
- **Falsifiers.** Brent/Floyd crossing $1.0$ in the counted channel (excluded on every shape by Theorem 3.9); a constant outside $1.24$–$1.33$; drift of the constant at $1024+$ bits. Results of Bridy and Garton show that the exact cycle structure of quadratic maps is not random, so the last possibility remains open.

---

## 7. Algorithms

**Algorithm 1 (Floyd's detector with two-channel accounting).**
```
input: map f, seed x0
x ← f(x0); y ← f(f(x0)); evals ← 3; comps ← 1; i ← 1
while x ≠ y:
    x ← f(x); y ← f(f(y)); evals ← evals + 3; comps ← comps + 1; i ← i + 1
return (i, evals, comps)        # i = F(μ, λ), evals = 3F, comps = F
```

**Algorithm 2 (Brent's power-of-two detector).**
```
input: map f, seed x0
saved ← x0; x ← x0; k ← 0; evals ← 0; comps ← 0
loop:
    for j = 1 .. 2^k:
        x ← f(x); evals ← evals + 1; comps ← comps + 1
        if x = saved: return (k, j, evals, comps)   # k = K, j = λ, evals = comps = 2^K − 1 + λ
    saved ← x; k ← k + 1
```

**Algorithm 3 (closed-form costs from $(\mu,\lambda)$).** $F = \lambda\max(1, \lceil\mu/\lambda\rceil)$; $K = \min\{k : \mu < 2^k,\ \lambda \le 2^k\}$; Floyd $= (3F, F)$; Brent $= (2^K - 1 + \lambda,\ 2^K - 1 + \lambda)$. This takes $O(\log(\mu + \lambda))$ time and serves as the oracle against which implementations are validated (Section 6.6).

**Algorithm 4 (cliff test).** Given $p$ and $E$: if $\gcd(E, p-1) = 1$, report "permutation: pure cycles, expected closure time of order $p$". Otherwise report "compressing with $d = \gcd(E,p-1)$: closure time at most $(p-1)/d + 2$". This takes $O(\log p)$ time.

---

## 8. Discussion

The main message is methodological. A cost claim for an algorithm is a claim about a vector of channels, not a scalar. Floyd and Brent lie on opposite sides of an evaluation–comparison trade-off. Brent spends one comparison per evaluation and Floyd one per three, and neither dominates on every shape and every price vector (Theorems 3.9, 3.10 and 4.3). On random instances the trade-off favours Brent clearly, but only by about half of what the counted channel suggests.

The cliff shows the third channel. A change that appears to touch only the cost per operation (using $x^3$ instead of $x^2$) can alter the dynamics completely. Whether it does is decided by an exact arithmetic criterion, $\gcd(E, p-1) = 1$, and when it does, the walk turns from a birthday process of order $\sqrt p$ into a permutation of order $p$.

The same accounting applies to any iterative algorithm whose speed is quoted in one unit, for example memory traffic versus arithmetic, or communication versus computation: the improvement survives only if the uncounted channels do not grow.

---

## 9. Future directions

1. **Evaluation–comparison Pareto frontier.** Conjecture: every detector storing $O(1)$ iterates satisfies $\text{evals} + \text{comps} \ge 2(\mu + \lambda) - O(1)$ on worst-case rho shapes, with Brent attaining the bound. The counted and uncounted channels trade off exactly (Brent: comps $=$ evals; Floyd: comps $=$ evals$/3$), so a single scalar "local win" is ill-posed.
2. **Averaged boundary under the uniform random map.** Conjecture: over all $n^n$ maps, $\mathbb{E}[\text{Brent evals}]/\mathbb{E}[\text{Floyd evals}]$ tends to a finite limit $< 1$, while $\mathbb{E}[\text{Brent comps}]/\mathbb{E}[\text{Floyd comps}] > 1$, so on average the counted win is never fully absorbed. The sharp wall-clock loss requires $\lambda$ just above a power of two *and* no tail, a set whose measure tends to $0$ under the birthday law.
3. **Cycle-length moments for coprime exponents.** Conjecture: for $\gcd(E,p-1)=1$, $\sum_a T(a, x^E + c) \ge p^2/(\#\text{cycles})$, and the number of cycles is $O(\log p)$ on average over $c$, so the mean closure time is $\Omega(p/\log p)$. On a permutation the seed-sum of closure times is the sum of squared cycle lengths, so the bound follows from Cauchy–Schwarz once the cycle count is controlled.
4. **Sharp compression constant.** Conjecture: for $d = \gcd(E, p-1) > 1$, the average closure time of $x^E + c$ is $\Theta(\sqrt{(p-1)/d})$. The walk lives in a translate of the $d$-fold compressed image, which is the true state space for the birthday argument.

---

## References

- R. P. Brent, *An improved Monte Carlo factorization algorithm*, BIT 20 (1980), 176–184.
- E. Bach, *Toward a theory of Pollard's rho method*, Information and Computation 90 (1991), 139–155.
- J. H. Cheon, J. Hong, M. Kim, *Speeding up the Pollard rho method on prime fields*, ASIACRYPT 2008.
- D. E. Knuth, *The Art of Computer Programming, Vol. 2: Seminumerical Algorithms*, §3.1.
- P. L. Montgomery, *Speeding the Pollard and elliptic curve methods of factorization*, Math. Comp. 48 (1987), 243–264.
- J. M. Pollard, *A Monte Carlo method for factorization*, BIT 15 (1975), 331–334.
- P. C. van Oorschot, M. J. Wiener, *Parallel collision search with cryptanalytic applications*, J. Cryptology 12 (1999), 1–28.
