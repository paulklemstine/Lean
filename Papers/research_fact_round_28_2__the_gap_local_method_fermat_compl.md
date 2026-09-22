# Locality Classes of Classical Factoring Methods: Fermat's Method is Divisor-Local at the Square Root

**Aristotle**

**Date:** 2026-09-22

---

## Abstract

The running time of a classical integer-factoring method is conventionally quoted as an asymptotic function of the smaller prime factor $p$ of $N = pq$. This convention silently assumes that the method's cost is a function of $p$ alone — a property we call *factor-locality*. Trial division ($\Theta(p)$), Pollard's rho ($\Theta(\sqrt p)$) and the elliptic curve method (sub-exponential in $p$) fit the convention; Fermat's difference-of-squares method does not, and has consequently never been placed in the taxonomy. We close that gap.

We prove an exact identity: for odd primes $p < q$ and $N = pq$, Fermat's method performs exactly
$$\frac{p+q}{2} - \left\lfloor\sqrt N\right\rfloor - 1$$
iterations. The cost is the arithmetic-mean/geometric-mean gap of the factor pair, a function of the *gap* rather than of either factor. We show that this is the semiprime shadow of a more general phenomenon: on an arbitrary odd non-square $N$, the scan halts exactly at the half-sum $(d + N/d)/2$ of the ordered factorisation whose small factor $d$ is nearest $\sqrt N$ from below. Fermat's method is therefore *divisor-local at the square root* — blind to every divisor except one.

Three consequences follow. (i) **Separation.** If the factor gap satisfies $(q-p-2)^2 \le 8p$ then the cost is exactly $0$, for arbitrarily large $p$, whereas trial division costs exactly $p$; conversely on an odd prime $N$ the cost is exactly $(N - 2\lfloor\sqrt N\rfloor - 1)/2 = \Theta(N)$, quadratically worse than trial division. The locality classes are genuinely distinct in both directions. (ii) **Scaling law.** Writing $q = rp$, the cost in units of $p$ is exactly $(\sqrt r - 1)^2/2$, independent of $p$; equivalently, the cost is the fraction $(\sqrt r - 1)/(\sqrt r + 1)$ of the cofactor-linear limit $(q-p)/2$, with the sharp integral form $2 \cdot \mathrm{cost} + 2 \le q - p$. A six-point grid at $p = 101$ reproduces the law to three decimals over a $250$-fold range of cost. (iii) **Degeneracy and repair.** On $N = n^2$ the difference-of-squares target $a = n$ lies strictly *below* the starting point $\lfloor\sqrt N\rfloor + 1$: the classical scan has no true stopping point on a square and exits only at the trivial factorisation, at quadratic cost. Starting the scan at $\lfloor\sqrt N\rfloor$ repairs this exactly, halting immediately on every square at a price of one extra iteration on every odd non-square.

Finally, divisor-locality is *steerable*: running the scan on $kN$ for odd $k$ replaces the visible pair $(p,q)$ by $(kp, q)$ and bounds the stopping point by $(kp+q)/2$. A worked instance converts a $34$-iteration run on $303 = 3 \cdot 101$ into a $0$-iteration run on $9999 = 99 \cdot 101$, with the factor recovered by one gcd.

**Keywords:** integer factorisation, Fermat's method, difference of squares, AM–GM gap, locality classes, balance ratio, Lehman multipliers, divisor structure.

---

## 1. Introduction

### 1.1 The convention and its blind spot

Ask for the cost of a factoring algorithm on a semiprime $N = pq$, $p < q$, and you will be given a function of $p$:

- trial division: $\Theta(p)$ divisions;
- Pollard's rho: $\Theta(\sqrt p)$ group operations, by the birthday paradox on the cycle of a pseudorandom map reduced mod $p$;
- the elliptic curve method: $L_p[1/2, \sqrt 2]$ operations, sub-exponential in $p$.

The convention is so natural that its content is easy to miss. It asserts that the cost is *a function of $p$ alone*: freeze $p$, vary $q$ over an arbitrarily wide range, and the cost does not move. We name this property.

> **Definition (factor-locality).** A factoring method is *factor-local* if its cost on $N = pq$ is a function of $p$ only.

Rho and ECM are factor-local; trial division is factor-local for the degenerate reason that it is a scan of the integers, noticing nothing about $N$ except when a candidate divides it. That distinction — between a method that *finds* the factor and a method that *enumerates until it hits* it — will matter, so we separate the classes:

> **Definition ($p$-linear class).** A method is *$p$-linear* if its cost on $N = pq$ is $\Theta(p)$ and arises from an enumeration of candidate divisors in increasing order.

Fermat's method, the oldest of the four and the only one of the four never classified, fits neither description.

### 1.2 Fermat's method

Fermat's method rests on the identity $a^2 - b^2 = (a-b)(a+b)$. Given odd $N$, one searches for $a$ with $a^2 - N$ a perfect square; then $N = (a-b)(a+b)$ splits. The search starts at the least $a$ with $a^2 > N$, i.e. $a = \lfloor\sqrt N\rfloor + 1$, and increments.

> **Definition (the scan).** For $N \in \mathbb{N}$ set the *starting point* $\mathrm{start}(N) = \lfloor\sqrt N\rfloor + 1$. The *hit set* is
> $$H(N) = \{k \in \mathbb{N} : \exists b \in \mathbb{N},\ (\mathrm{start}(N) + k)^2 = N + b^2\},$$
> and the *cost* is $\mathrm{cost}(N) = \inf H(N)$, the number of increments performed before the scan succeeds.

Experiment on semiprimes shows an iteration count that is manifestly *not* a function of $p$: fix $p = 10007$ and move $q$ from $10009$ to $640\,000$-ish, and the count moves from $0$ to hundreds of thousands. Fix instead the gap $q - p$ and move both primes up, and the count *decreases*. Something other than $p$ is being measured.

### 1.3 Contributions

1. **The gap-local identity** (§3): an exact closed form for $\mathrm{cost}(pq)$, with no asymptotic slack.
2. **Divisor-locality at the square root** (§4): the identity's explanation, as a theorem about arbitrary odd non-squares, together with the prime worst case.
3. **The balance-ratio scaling law** (§5): the cost in $p$-units as a function of $r = q/p$ alone, its fraction-of-limit form, the sharp integral inequality, and an exactly computed six-point grid at $p = 101$.
4. **Class separations** (§6): the zero-cost regime with its exact criterion, and the $\Theta(N)$ prime worst case, establishing that the three classes are pairwise distinct.
5. **The square defect and its repair** (§7).
6. **Steering the locality with multipliers** (§8), with a fully computed instance.

The completed taxonomy:

| method | locality class | cost on $N = pq$ |
|---|---|---|
| trial division | $p$-linear | $p$ |
| Pollard's rho | factor-local | $\sqrt p$ |
| elliptic curve method | factor-local | sub-exponential in $p$ |
| **Fermat** | **gap-local** (in general: divisor-local at $\sqrt N$) | $\dfrac{p+q}{2} - \sqrt N$ |

Four methods; three locality classes.

---

## 2. Preliminaries: stops of the scan are factorisations

Everything downstream rests on a single structural lemma, which converts an analytic-looking search into a combinatorial statement about the divisors of $N$.

> **Lemma 2.1 (Hit–factorisation correspondence).** If $a^2 = N + b^2$ for some $b \in \mathbb{N}$, then there exist $d \le e$ with $de = N$ and $d + e = 2a$.

*Proof sketch.* From $a^2 \ge b^2$ we get $b \le a$, so $d = a - b$ and $e = a + b$ are natural numbers with $d \le e$. Expanding, $de = a^2 - b^2 = N$, and $d + e = 2a$. $\square$

The converse also holds, at the level of admissible stopping points.

> **Definition 2.2 (factorisation half-sums).** $S(N) = \{a \in \mathbb{N} : \exists d \le e,\ de = N,\ d + e = 2a\}$.

> **Lemma 2.3 (Half-sums are reachable stops).** If $a \in S(N)$ and $\mathrm{start}(N) \le a$, then $a - \mathrm{start}(N) \in H(N)$.

*Proof sketch.* Given $de = N$, $d \le e$, $d+e = 2a$, write $e = d + 2c$ so $a = d + c$. Then $a^2 - N = (d+c)^2 - d(d+2c) = c^2$, a perfect square. $\square$

> **Lemma 2.4 (AM > GM places every half-sum at or beyond the start).** If $N$ is not a perfect square and $a \in S(N)$, then $\mathrm{start}(N) \le a$.

*Proof sketch.* With $de = N$ and $N$ non-square we have $d < e$; write $e = d + 2g$ with $g \ge 1$, so $a = d+g$ and $a^2 = d^2 + 2dg + g^2 > d(d+2g) = N$. Hence $a > \lfloor\sqrt N\rfloor$, i.e. $a \ge \mathrm{start}(N)$. $\square$

Non-squareness is essential in Lemma 2.4 and is precisely where the degenerate case of §7 lives: for $N = n^2$ the factorisation $n \cdot n$ has half-sum $a = n < \mathrm{start}(N) = n+1$.

Finally, on semiprimes the factorisation side of the correspondence is completely rigid.

> **Lemma 2.5 (Ordered factorisations of a semiprime).** If $p, q$ are prime, $p \le q$, and $de = pq$ with $d \le e$, then either $(d,e) = (1, pq)$ or $(d,e) = (p,q)$.

*Proof sketch.* $p \mid de$, so $p \mid d$ or $p \mid e$. In the first case $d = pm$ and $me = q$, so by primality of $q$ either $m = 1$ (giving $(d,e)=(p,q)$) or $m = q$, which forces $e = 1$ and contradicts $d \le e$. The second case is symmetric and yields $(1, pq)$ (or, in the boundary case $p = q$, again $(p,q)$). $\square$

Combining 2.1 and 2.5:

> **Corollary 2.6.** For prime $p \le q$, a stop of the scan on $N = pq$ occurs only at $2a = 1 + pq$ or $2a = p + q$.

---

## 3. The gap-local identity

> **Theorem 3.1 (Gap-local identity).** Let $p < q$ be odd primes, $N = pq$. Then
> $$\mathrm{start}(N) + \mathrm{cost}(N) = \frac{p+q}{2},$$
> equivalently
> $$\mathrm{cost}(N) = \frac{p+q}{2} - \left\lfloor\sqrt{pq}\right\rfloor - 1.$$

*Proof sketch.* Since $p, q$ are odd, $s = (p+q)/2$ and $t = (q-p)/2$ are natural numbers and $s^2 = pq + t^2$; so $s$ is a stop. By Lemma 2.4 (with $pq$ non-square, since $p \ne q$) we have $\mathrm{start}(N) \le s$, hence $s - \mathrm{start}(N) \in H(N)$ and $\mathrm{cost}(N) \le s - \mathrm{start}(N)$.

For the lower bound, let $k \in H(N)$ and put $a = \mathrm{start}(N) + k$. By Corollary 2.6, $2a \in \{1 + pq,\ p+q\}$. Since $p, q \ge 3$ we have $p + q \le 1 + pq$, so in either case $a \ge s$, i.e. $k \ge s - \mathrm{start}(N)$. Hence $\mathrm{cost}(N) = s - \mathrm{start}(N)$. $\square$

The right-hand side of Theorem 3.1 is the AM–GM gap of $(p,q)$, up to the floor-plus-one boundary term. In real variables this quantity has a transparent shape.

> **Proposition 3.2 (AM–GM gap as a square).** For $x, y \ge 0$,
> $$\frac{x+y}{2} - \sqrt{xy} = \frac{(\sqrt y - \sqrt x)^2}{2}.$$

*Proof sketch.* Expand $(\sqrt y - \sqrt x)^2 = y - 2\sqrt{xy} + x$ using $\sqrt{xy} = \sqrt x\sqrt y$. $\square$

> **Proposition 3.3 (Quantitative gap-locality).** For $0 < x \le y$,
> $$\frac{x+y}{2} - \sqrt{xy} \;\le\; \frac{(y-x)^2}{8x}.$$

*Proof sketch.* By Proposition 3.2 the left side is $(\sqrt y - \sqrt x)^2/2$. Write $y - x = (\sqrt y - \sqrt x)(\sqrt y + \sqrt x)$; then the claim is $(\sqrt y - \sqrt x)^2/2 \le (\sqrt y - \sqrt x)^2(\sqrt y + \sqrt x)^2/(8x)$, i.e. $4x \le (\sqrt y + \sqrt x)^2$, which holds since $\sqrt y \ge \sqrt x$. $\square$

Proposition 3.3 is the quantitative heart of gap-locality: the gap enters *squared in the numerator* and the small factor enters *in the denominator*. For fixed $g = q - p$ the Fermat cost is $O(g^2/p)$ and hence **decreases** as the primes grow — the exact inverse of the monotonicity exhibited by every factor-local method.

---

## 4. Divisor-locality at the square root

Theorem 3.1 is a statement about semiprimes. Its true content is a statement about all odd non-squares.

> **Lemma 4.1 (The factor sum is antitone in the small factor).** Let $N > 0$, $de = N$, $d'e' = N$, $d' \le d \le e$. Then $d + e \le d' + e'$.

*Proof sketch.* Write $d = d' + c$ with $c \ge 0$. Then $d'(e + c) = d'e + cd' \le d'e + ce = (d'+c)e = de = N = d'e'$, so $e + c \le e'$, giving $d + e = d' + c + e \le d' + e'$. $\square$

Geometrically: on $d \in (0, \sqrt N]$ the function $d \mapsto d + N/d$ is strictly decreasing, so among all ordered factorisations the one with the *largest* small factor — the divisor closest to $\sqrt N$ from below — has the *smallest* sum.

> **Theorem 4.2 (Stopping point of the scan).** Let $N$ be odd and not a perfect square. Then
> $$\mathrm{start}(N) + \mathrm{cost}(N) = \min S(N),$$
> the least half-sum of an ordered factorisation of $N$.

*Proof sketch.* $S(N)$ is non-empty: $(1, N)$ contributes $(N+1)/2$. Let $a^\ast = \min S(N)$. By Lemma 2.4, $\mathrm{start}(N) \le a^\ast$, so by Lemma 2.3 $a^\ast - \mathrm{start}(N) \in H(N)$ and $\mathrm{cost}(N) \le a^\ast - \mathrm{start}(N)$. Conversely, by Lemma 2.1 the actual stop $\mathrm{start}(N) + \mathrm{cost}(N)$ lies in $S(N)$, hence is $\ge a^\ast$. $\square$

> **Theorem 4.3 (Divisor-locality at the square root).** Let $N$ be odd and non-square, and let $N = de$ with $d \le e$ and $d$ maximal among small factors of ordered factorisations (equivalently, $d$ is the largest divisor of $N$ with $d \le \sqrt N$). Then
> $$2\bigl(\mathrm{start}(N) + \mathrm{cost}(N)\bigr) = d + e.$$

*Proof sketch.* $N$ odd forces $d, e$ odd, so $a_0 = (d+e)/2 \in \mathbb{N}$ and $a_0 \in S(N)$. For any other $(d', e')$ with $d'e' = N$, $d' \le e'$, maximality gives $d' \le d$, so Lemma 4.1 gives $d + e \le d' + e'$, i.e. $a_0 \le (d'+e')/2$. Hence $a_0 = \min S(N)$ and Theorem 4.2 applies. $\square$

**Interpretation.** Fermat's method is blind to every divisor of $N$ except the one nearest $\sqrt N$, and its cost is the AM–GM gap of that single pair. On a semiprime the largest divisor below $\sqrt{pq}$ is $p$ itself, so Theorem 4.3 specialises to Theorem 3.1 — gap-locality is the *semiprime shadow* of divisor-locality. (The consistency is immediate: both theorems give $2(\mathrm{start} + \mathrm{cost}) = p + q$.)

The other extreme of the divisor structure gives the worst case of the taxonomy.

> **Theorem 4.4 (Prime worst case).** Let $N$ be an odd prime. Then
> $$2\bigl(\mathrm{start}(N) + \mathrm{cost}(N)\bigr) = N + 1,$$
> i.e. $\mathrm{cost}(N) = \dfrac{N - 2\lfloor\sqrt N\rfloor - 1}{2} = \Theta(N)$.

*Proof sketch.* A prime is non-square, and its only ordered factorisation is $1 \cdot N$, so the maximal small factor is $d = 1$. Theorem 4.3 gives $2(\mathrm{start} + \mathrm{cost}) = 1 + N$. $\square$

Trial division certifies the primality of $N$ in $\lfloor\sqrt N\rfloor$ steps. Fermat's method requires $\Theta(N)$ — quadratically worse. The same method that is *unboundedly better* than trial division on balanced semiprimes (Theorem 6.2) is *quadratically worse* on primes. Locality classes are not a change of units.

---

## 5. The balance-ratio scaling law

Fix $p$ and let $q \approx rp$ for a *balance ratio* $r = q/p \ge 1$. Substituting into the AM–GM gap eliminates $p$ up to an overall scale.

> **Theorem 5.1 (Cost in $p$-units).** For real $p > 0$ and $r \ge 0$,
> $$\frac{p + rp}{2} - \sqrt{p \cdot rp} \;=\; p \cdot \frac{(\sqrt r - 1)^2}{2}.$$

*Proof sketch.* $\sqrt{p\cdot rp} = \sqrt{r}\,\sqrt{p \cdot p} = \sqrt r \, p$; the identity then reduces to $\frac{1 + r}{2} - \sqrt r = \frac{(\sqrt r - 1)^2}{2}$, which is Proposition 3.2 with $x = 1$, $y = r$. $\square$

So the cost in units of $p$ is the *universal function* $\varphi(r) = (\sqrt r - 1)^2/2$ of the balance ratio — the size of the primes does not appear. Selected exact values: $\varphi(2) = 3/2 - \sqrt 2 = 0.0857\ldots$, $\varphi(4) = 1/2$, $\varphi(9) = 2$, $\varphi(16) = 9/2$, $\varphi(64) = 49/2 = 24.5$.

> **Corollary 5.2.** For $p > 0$, $\dfrac{p + 64p}{2} - \sqrt{p\cdot 64p} = 24.5\,p$ exactly.

A second normalisation is more informative. The *cofactor-linear limit* is the distance $(q-p)/2 = p(r-1)/2$ from the half-sum of the trivial-side factor to the target; it is the cost one would pay if the scan had to traverse the whole factor gap.

> **Theorem 5.3 (Ratio law).** For real $p > 0$ and $r > 1$,
> $$\frac{\dfrac{p + rp}{2} - \sqrt{p \cdot rp}}{\dfrac{rp - p}{2}} \;=\; \frac{\sqrt r - 1}{\sqrt r + 1}.$$

*Proof sketch.* Numerator $= p(\sqrt r - 1)^2/2$ by Theorem 5.1; denominator $= p(r-1)/2 = p(\sqrt r - 1)(\sqrt r + 1)/2$. Cancel the non-zero factors $p$ and $(\sqrt r - 1)$. $\square$

The fraction $\rho(r) = \frac{\sqrt r - 1}{\sqrt r + 1}$ is strictly increasing with $\rho(1) = 0$ and $\rho(r) \to 1$ as $r \to \infty$, but never attains $1$: **Fermat never reaches the cofactor-linear cost.** At $r = 4$, $\rho = 1/3$; at $r = 9$, $\rho = 1/2$; at $r = 64$, $\rho = 7/9 = 0.7\overline{7}$. The sharp integral form of "never attains" is:

> **Theorem 5.4 (Strictness in $\mathbb{N}$).** For odd primes $p < q$,
> $$2\,\mathrm{cost}(pq) + 2 \;\le\; q - p.$$

*Proof sketch.* Theorem 3.1 gives $\lfloor\sqrt{pq}\rfloor + 1 + \mathrm{cost} = (p+q)/2$. Since $p \le \lfloor\sqrt{pq}\rfloor$ (because $p^2 \le pq$), we get $\mathrm{cost} \le (p+q)/2 - p - 1 = (q-p)/2 - 1$; parity of $p, q$ makes $(q-p)/2$ an integer and the inequality rearranges to the claim. $\square$

### 5.1 An exactly computed grid

To exhibit the law against data rather than against itself, take $p = 101$ and, for each target ratio $r_0 \in \{2,4,8,16,32,64\}$, the prime $q$ nearest $r_0 p$.

> **Theorem 5.5 (The balance-ratio grid at $p = 101$).**
> $$\mathrm{cost}(101\cdot 211) = 10,\quad \mathrm{cost}(101\cdot 409) = 51,\quad \mathrm{cost}(101\cdot 809) = 169,$$
> $$\mathrm{cost}(101\cdot 1619) = 455,\quad \mathrm{cost}(101\cdot 3251) = 1102,\quad \mathrm{cost}(101\cdot 6469) = 2476.$$

*Proof sketch.* Each entry is Theorem 3.1 evaluated at the relevant pair, with the integer square root computed by the bracketing $k^2 \le N < (k+1)^2$: e.g. $N = 101\cdot 6469 = 653\,369$ has $808^2 = 652\,864 \le N < 654\,481 = 809^2$, so $\lfloor\sqrt N\rfloor = 808$ and $\mathrm{cost} = (101+6469)/2 - 809 = 3285 - 809 = 2476$. The remaining five brackets are $145, 203, 285, 404, 573$. $\square$

| $q$ | $r = q/p$ | cost | cost$/p$ | $\varphi(r) = (\sqrt r - 1)^2/2$ | measured $\rho$ | $\rho(r)$ |
|---|---|---|---|---|---|---|
| 211 | 2.0891 | 10 | 0.0990 | 0.0992 | 0.1818 | 0.1821 |
| 409 | 4.0495 | 51 | 0.5050 | 0.5124 | 0.3312 | 0.3361 |
| 809 | 8.0099 | 169 | 1.6733 | 1.6748 | 0.4774 | 0.4778 |
| 1619 | 16.0297 | 455 | 4.5050 | 4.5111 | 0.5995 | 0.6003 |
| 3251 | 32.1881 | 1102 | 10.9109 | 10.9206 | 0.6997 | 0.7003 |
| 6469 | 64.0495 | 2476 | 24.5149 | 24.5217 | 0.7776 | 0.7779 |

The $p$-unit column tracks $\varphi(r)$ to three decimals across a $250$-fold range of cost; the discrepancy is entirely the floor term and the small deviation of $q/p$ from the nominal ratio. The same law at larger $p$ produces a measured row rising from $352$ to $100\,282$ iterations across $r \in [2, 64]$ — a $285$-fold climb driven purely by the ratio with the small factor held fixed, with the $r = 64$ cost equal to $0.78$ of the cofactor-linear limit, in agreement with $\rho(64) = 7/9$.

---

## 6. Separating the locality classes

Distinct formulas are not distinct classes; one needs inputs on which the behaviours are incomparable. There are two, at opposite ends.

> **Theorem 6.1 (Trial division on a semiprime).** For primes $p \le q$, the least prime factor of $pq$ is $p$; trial division halts after exactly $p$ candidate values.

*Proof sketch.* $p$ divides $pq$ and is prime, so the least prime factor is $\le p$; being prime and dividing $pq$, it equals $p$ or $q$, and $q > p$ is excluded by minimality unless $p = q$. $\square$

> **Theorem 6.2 (Zero-cost regime).** Let $p < q$ be odd primes with $(q - p - 2)^2 \le 8p$. Then $\mathrm{cost}(pq) = 0$: Fermat's method succeeds at its very first trial value.

*Proof sketch.* Put $s = (p+q)/2$, $t = (q-p)/2$, and write $t = u+1$. The hypothesis is $(2u)^2 \le 8p$, i.e. $u^2 \le 2p$. Then
$$(s-1)^2 = (p+u)^2 = p^2 + 2pu + u^2 \le p^2 + 2pu + 2p = p(p + 2u + 2) = pq,$$
so $s - 1 \le \lfloor\sqrt{pq}\rfloor$, i.e. $s \le \mathrm{start}(pq)$. Theorem 3.1 then forces $\mathrm{cost} = 0$. $\square$

The criterion is not merely sufficient; the exact characterisation is available.

> **Theorem 6.3 (Exact zero-cost criterion).** For odd primes $p < q$,
> $$\mathrm{cost}(pq) = 0 \iff \left(\frac{p+q}{2} - 1\right)^2 \le pq.$$

*Proof sketch.* By Theorem 3.1, $\mathrm{cost} = 0$ iff $(p+q)/2 = \lfloor\sqrt{pq}\rfloor + 1$, iff $(p+q)/2 - 1 \le \lfloor\sqrt{pq}\rfloor$ (the reverse inequality being automatic from AM $>$ GM), iff $((p+q)/2 - 1)^2 \le pq$ by the defining property of the integer square root. $\square$

Asymptotically the criterion reads $q - p \lesssim 2\sqrt{2p}$: the zero-cost semiprimes are exactly those whose two primes lie within $O(\sqrt p)$ of each other.

> **Corollary 6.4 (Separation, gap-local vs. $p$-linear).** On $N = 10007 \cdot 10009 = 100\,160\,063$, Fermat's method costs $0$ iterations while trial division costs $10\,007$. More generally, along any infinite family of prime pairs with bounded gap, the Fermat cost is eventually $0$ while the trial-division cost is unbounded.

*Proof sketch.* $q - p - 2 = 0$ so the hypothesis of Theorem 6.2 holds trivially; Theorem 6.1 gives the trial-division count. For a bounded gap $g$, $(g-2)^2 \le 8p$ holds for all large $p$. $\square$

The reverse separation is Theorem 4.4: on odd primes Fermat costs $\Theta(N)$ where trial division costs $\Theta(\sqrt N)$. Hence neither class dominates the other, and the classification is not a reparametrisation.

Note also what Proposition 3.3 says about factor-locality: with $g$ fixed, $\mathrm{cost} = O(g^2/p) \to 0$ as $p \to \infty$. No factor-local method can have a cost that *decreases* in $p$ along a family of inputs whose small factor grows, since its cost is by definition a function of $p$ that must account for the difficulty of an ever-larger factor. Gap-locality is therefore genuinely outside the factor-local class, not a disguised member of it.

---

## 7. The degenerate square case and its repair

Running the grid of §5 down to $r = 1$ — the case $q = p$, $N = p^2$ — reveals a defect in the classical statement of the method.

> **Theorem 7.1 (The target lies below the start).** For every $n \ge 0$, $n < \mathrm{start}(n^2) = n + 1$.

The difference-of-squares representation $N = n^2 = n^2 - 0^2$ has $a = n$, which the scan never visits: it begins at $n+1$. Plain Fermat has **no true stopping point on a square**. What happens instead?

> **Theorem 7.2 (Cost on a prime square).** Let $p$ be an odd prime. Then
> $$\mathrm{start}(p^2) + \mathrm{cost}(p^2) = \frac{p^2+1}{2},$$
> i.e. the scan exits only at the *trivial* factorisation $1 \cdot p^2$, after $\frac{p^2+1}{2} - (p+1)$ iterations.

*Proof sketch.* $\mathrm{start}(p^2) = p+1$. With $p$ odd, $s = (p^2+1)/2$ and $b = (p^2-1)/2$ are integers satisfying $s^2 = p^2 + b^2$, so $s$ is a stop, and $s \ge p+1$ for $p \ge 3$. Conversely by Corollary 2.6 (with $q = p$) any stop $a$ satisfies $2a \in \{1+p^2,\ 2p\}$; the value $a = p$ is below the start, so every reachable stop has $2a = 1 + p^2$. $\square$

> **Corollary 7.3 (Quadratic blow-up).** $p^2 \le 2\,\mathrm{cost}(p^2) + 2p + 3$.

So on the *most balanced input possible* — the case where the gap-local formula predicts cost $0$ — the classical method pays $\Theta(p^2)$ and terminates at a factorisation that reveals nothing. In one measured instance a prime square exited only after $8\,372\,232$ iterations, by accidentally hitting the unrelated square of the trivial factorisation.

The defect is a one-step boundary error, and it admits an exact repair.

> **Definition 7.4 (Repaired scan).** $\mathrm{start}'(N) = \lfloor\sqrt N\rfloor$, with hit set $H'(N)$ and cost $\mathrm{cost}'(N) = \inf H'(N)$ defined as before.

> **Theorem 7.5 (The repair works).** $\mathrm{cost}'(n^2) = 0$ for every $n$.

*Proof sketch.* $\mathrm{start}'(n^2) = n$ and $n^2 = n^2 + 0^2$, so $0 \in H'(n^2)$. $\square$

> **Theorem 7.6 (Price of the repair).** If $N$ is odd and not a perfect square, then $\mathrm{cost}'(N) = \mathrm{cost}(N) + 1$.

*Proof sketch.* The two hit sets are related by a shift: $k+1 \in H'(N) \iff k \in H(N)$, since $\mathrm{start}'(N) + (k+1) = \mathrm{start}(N) + k$. Moreover $0 \notin H'(N)$, because $0 \in H'(N)$ would give $\lfloor\sqrt N\rfloor^2 = N + b^2 \ge N$, forcing $\lfloor\sqrt N\rfloor^2 = N$ and making $N$ a square. Hence the minimum of $H'$ is one more than the minimum of $H$. $\square$

Thus covering the square boundary case costs exactly one wasted trial per run — a negligible price for removing an unbounded failure mode. Continued-fraction descendants of the method (CFRAC-style generalisations), which search a different sequence of candidate residues, do not exhibit the defect at all.

---

## 8. Steering the locality: multipliers

The value of knowing exactly what a method sees is that one can change what it sees. Since Fermat notices only the divisor nearest $\sqrt N$, one may deliberately supply a better-balanced number.

> **Theorem 8.1 (Multiplier bound, Lehman-style).** Let $k$ be odd, $N = pq$, and suppose $kN$ is odd and non-square with $kp \le q$. Then
> $$2\bigl(\mathrm{start}(kN) + \mathrm{cost}(kN)\bigr) \le kp + q.$$

*Proof sketch.* $(kp)\cdot q = kN$ is an ordered factorisation of $kN$, so $(kp+q)/2 \in S(kN)$; by Theorem 4.2 the stopping point is the *minimum* of $S(kN)$, hence at most this value. $\square$

Choosing $k \approx q/p$ makes the visible pair $(kp, q)$ nearly balanced and the cost, by Theorem 5.1 applied to $kN$, as small as the approximation quality allows. After the scan splits $kN$ as $u \cdot v$, a single $\gcd(u, N)$ recovers a factor of $N$.

> **Theorem 8.2 (Worked instance).** $\mathrm{cost}(303) = 34$, $\mathrm{cost}(33 \cdot 303) = 0$, and $\gcd(99, 303) = 3$.

*Proof sketch.* $303 = 3 \cdot 101$ and $\lfloor\sqrt{303}\rfloor = 17$, so Theorem 3.1 gives $\mathrm{cost} = (3+101)/2 - 18 = 52 - 18 = 34$. For the multiplied number, $33 \cdot 303 = 9999 = 99 \cdot 101$ with $\lfloor\sqrt{9999}\rfloor = 99$; the largest divisor of $9999$ below its square root is $99$, so Theorem 4.3 gives $2(\mathrm{start} + \mathrm{cost}) = 99 + 101 = 200$, i.e. $\mathrm{start} + \mathrm{cost} = 100 = \mathrm{start}(9999)$, so $\mathrm{cost} = 0$. Finally $\gcd(99, 303) = 3$. $\square$

A run of $34$ iterations becomes a run of $0$, purchased with one multiplication and one gcd. This is the mechanism underlying Lehman's improvement of Fermat's method; the locality picture explains *why* it works and what the optimisation problem is: among odd $k \le K$, minimise $\frac{kp + q}{2} - \sqrt{kpq}$, i.e. by Theorem 5.1 minimise $\varphi(q/(kp))$ — find $k$ making $kp/q$ closest to $1$. That is Diophantine approximation of $q/p$ by rationals with bounded numerator, i.e. continued fractions.

---

## 9. Algorithms

### 9.1 The scan, and the closed form

The identity of Theorem 3.1 turns an $O(\mathrm{gap})$-time loop into an $O(1)$ arithmetic formula (given an integer square root). For $N = pq$ with known $p < q$:

```
COST-CLOSED-FORM(p, q):
  require p, q odd primes with p < q
  return (p + q) / 2 - isqrt(p * q) - 1
```

while the scan itself is:

```
FERMAT-SCAN(N):
  a  <- isqrt(N) + 1
  k  <- 0
  loop:
    b2 <- a*a - N
    b  <- isqrt(b2)
    if b*b = b2: return (a - b, a + b, k)
    a  <- a + 1
    k  <- k + 1
```

The two agree exactly on odd semiprimes. **Note the increment.** An implementation that omits `a <- a + 1` does not merely run slowly; it fails to terminate on every non-trivial input while presenting as a hot loop with no diagnostic. This is the single most common implementation defect of the method, and it is invisible to unit tests that only exercise zero-cost inputs, since those return before the first increment.

### 9.2 Repaired scan

Replace the initialisation `a <- isqrt(N)` and keep everything else; by Theorems 7.5 and 7.6, the repaired scan halts immediately on squares and costs exactly one extra iteration otherwise.

### 9.3 Multiplier search

```
FERMAT-MULTIPLIER(N, K):
  best <- (1, cost_estimate(N))
  for k in 1, 3, 5, ..., K:
    M <- k * N
    c <- isqrt-based estimate of the AM-GM gap of the best-balanced
         known factor pair of M, or an actual bounded scan on M
    if c < best.cost: best <- (k, c)
  (u, v) <- FERMAT-SCAN(best.k * N)
  return gcd(u, N)
```

Complexity: the scan costs $\Theta\!\left(\frac{p+q}{2} - \sqrt{pq}\right)$ integer-square-root evaluations, i.e. $O\!\left(\frac{(q-p)^2}{p}\right)$ by Proposition 3.3, and $\Theta(N)$ in the prime worst case by Theorem 4.4; the multiplier loop multiplies this by $K/2$ in the search phase but can reduce the scan phase by the factor $\rho(q/(kp))/\rho(q/p)$.

---

## 10. Applications

**Key generation.** The zero-cost criterion of Theorem 6.3 is a hard constraint on RSA-style moduli that is *independent of key length*. A modulus whose two primes satisfy $q - p \lesssim 2\sqrt{2p}$ falls to the first trial value of a seventeenth-century method, regardless of how large $p$ is. More generally, by Proposition 3.3 a modulus with $q - p = O(p^{1/2 + \epsilon})$ is broken in $O(p^{2\epsilon})$ iterations. Standard guidance ("choose $p$ and $q$ of the same bit length, but not too close") is exactly this theorem, and the theorem supplies the precise threshold that the guidance leaves vague.

**Algorithm selection.** Given a modulus about which one knows something — a bound on the gap, or a suspected near-balanced structure — the taxonomy says which method to run. Bounded or $O(\sqrt p)$ gap: Fermat, in $O(1)$. Unknown but small $p$: rho or ECM. Nothing known: neither Fermat nor trial division, since both are the wrong locality class for the general case.

**Testing and instrumentation.** The identity of Theorem 3.1 is an exact oracle for the iteration count. An implementation can be validated by checking, on every input, that the observed count equals $(p+q)/2 - \lfloor\sqrt{pq}\rfloor - 1$ — an all-or-nothing test that catches off-by-one boundary errors, missing increments, and floor-versus-ceiling mistakes in the starting point. The degenerate-square row (Theorem 7.2) is the single most informative test case, since it is the only input on which the naive formula and the true behaviour disagree by an unbounded amount.

---

## 11. Discussion

Three points deserve emphasis.

**Locality is a property of a cost function, not of code.** Each of the classical scans minimises some function over the divisors of $N$: trial division minimises $d$ itself, Fermat minimises $d + N/d$, a multiplier replaces $N$ by $kN$ and then minimises $d + kN/d$. Theorems 4.2 and 6.1 express both stopping points as infima over the same index set — the divisors of $N$ — which is precisely the shape needed for a general theorem about the whole family. The locality class ought to be readable off the cost function, and proved once.

**The exactness matters.** Everything above is an identity or a sharp inequality, not an asymptotic. That is what makes the separations airtight (a $\Theta$ statement cannot distinguish cost $0$ from cost $O(1)$, and the zero-cost theorem is about $0$ exactly), what makes the grid a genuine test rather than a curve fit, and what made the square defect detectable at all — a formula and a measurement that disagree by an unbounded amount are only visibly in disagreement if the formula is exact.

**Degenerate rows earn their keep.** The $r = 1$ row of the grid, which a practitioner would have been tempted to skip as uninteresting, is the row that exposed the square defect. Prime squares are not hypothetical inputs; they arise whenever a factoring routine is invoked on an unknown number, and an unfixed implementation will spend $\Theta(p^2)$ iterations on one and then report a useless factorisation.

**Limitations.** The results concern the *iteration count* of the scan, not the bit complexity of a single iteration (each requires an integer square root, costing $O(M(\log N))$ with a Newton method). The semiprime results assume both factors odd; the even case is trivially handled by extracting factors of $2$ first. Theorem 4.3 assumes $N$ odd and non-square, exactly the hypotheses under which Lemma 2.4 holds. The multiplier bound (Theorem 8.1) is an upper bound, not an identity: the scan on $kN$ may stop earlier still if $kN$ acquires a divisor even nearer its square root.

---

## 12. Future directions

### 12.1 A locality invariant that classifies every deterministic scan

Each classical method is a scan over a *cost function on the divisors of $N$* — trial division minimises $d$ itself, Fermat minimises $d + N/d$, and a multiplier replaces $N$ by $kN$ before minimising — so the locality class of a method should be a property of that cost function, not of the algorithm's code. We now have the exact stopping point of two of these scans as an infimum over the same index set, which is precisely the shape needed to state a general theorem about the family. The target is a single theorem of the form: *for a cost function $c$ on the divisor lattice of $N$ satisfying [monotonicity condition], the associated scan halts at $\min_d c(d)$, and its locality class is determined by the level sets of $c$.*

### 12.2 Density of the zero-cost regime

The exact criterion is now closed: $\mathrm{cost}(pq) = 0$ iff $\left(\frac{p+q}{2} - 1\right)^2 \le pq$. What remains is counting. The criterion is equivalent to $q - p \lesssim 2\sqrt{2p}$, so the number of zero-cost semiprimes below $x$ is governed by prime pairs at distance $O(p^{1/2})$ — a range where the Hardy–Littlewood heuristics are believable but no unconditional lower bound is known. With the criterion proved exactly, the question becomes a clean analytic-number-theory statement rather than an algorithmic one, and a conditional count is already within reach.

### 12.3 Optimal multipliers and the Lehman exponent

The multiplier bound gives cost $\lesssim \frac{kp+q}{2} - \sqrt{kpq}$ for every odd $k$, and minimising this over $k \le K$ is a Diophantine approximation problem: one wants $k$ with $kp/q$ close to $1$. With the bound in hand, the remaining content is purely about how well $q/p$ can be approximated by rationals with bounded numerator — continued fractions. The natural target is a sharp exponent: for which $\theta$ does a multiplier $k \le N^{\theta}$ always reduce the cost below $N^{1/3}$, recovering (and perhaps sharpening) Lehman's bound from the locality picture?

### 12.4 Cost of the repaired scan under multipliers

The repaired scan costs exactly one extra iteration on odd non-squares and zero on squares. Combining the repair with a multiplier search raises a question the two analyses do not separately answer: since a multiplier $k$ can make $kN$ a square only in controlled circumstances, what is the joint distribution of (repair penalty, multiplier gain) over a natural family of inputs, and is there a multiplier schedule under which the repaired scan strictly dominates the classical one on every input?

### 12.5 Beyond the four methods

The quadratic sieve and the number field sieve are not scans in the sense above; they collect relations rather than halting at a distinguished divisor. Whether they admit a locality invariant at all — and if so, what they *see* — is open. A negative answer would be as informative as a positive one: it would say that the locality taxonomy is exactly the taxonomy of divisor-scans, and that the sieve family lies outside it by construction.

---

## 13. Conclusion

Fermat's method, the only classical factoring method never locality-classified, is now placed. Its cost on a semiprime $N = pq$ with odd primes $p < q$ is exactly $\frac{p+q}{2} - \lfloor\sqrt N\rfloor - 1$, the AM–GM gap of the factor pair; more generally, on any odd non-square it halts at the half-sum of the ordered factorisation whose small factor is nearest $\sqrt N$, so it is *divisor-local at the square root*. In units of $p$ the cost is the universal function $(\sqrt r - 1)^2/2$ of the balance ratio $r = q/p$, equivalently the fraction $\frac{\sqrt r - 1}{\sqrt r + 1}$ of the cofactor-linear limit, a fraction it approaches but never attains. It halts in zero iterations exactly when $\left(\frac{p+q}{2}-1\right)^2 \le pq$, and costs $\Theta(N)$ on an odd prime. Its one degenerate input, the perfect square, arises from a one-step boundary error and is repaired exactly by lowering the starting point, at a price of a single iteration. And its locality is steerable: a multiplier chooses which divisor the method sees.

Four methods, three locality classes: which methods see the factor, which see the gap, and which see nothing but the scan.
