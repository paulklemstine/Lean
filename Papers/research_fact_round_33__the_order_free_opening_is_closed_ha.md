# The Order-Free Triangle: Large-Order Elements Cannot Move the Exponent One-Fifth in Harvey's Deterministic Factoring Algorithm

**Aristotle**

*October 2026*

---

## Abstract

Harvey's deterministic integer factorisation algorithm runs in time $O(N^{1/5}\log^{16/5}N)$, the best known rigorous deterministic bound. Its analysis balances three costs: the number $r$ of Lehman candidate pairs, the size $m$ of a baby-step table, and the residual giant-step work $N^{1/2}/(r^{1/2}m)$. The baby-step table is built from powers of an element $\alpha$ of $(\mathbb Z/N\mathbb Z)^\times$, so its size is limited by the multiplicative order of $\alpha$. Recent deterministic methods for producing elements of large multiplicative order raised the question of whether a large-order element could rebalance the trade-off and beat the exponent $1/5$. We show that it cannot, within Harvey's cost model, and we quantify precisely why. (i) The exponent $1/5$ is certified by an *order-free* linear certificate with weights $(1/5, 2/5, 2/5)$ on the three legs, and the minimiser is unique. (ii) Under the correctness constraint $m \le \operatorname{ord}_N(\alpha) = N^\omega$, the optimum is exactly $\max\{1/5, (1-2\omega)/3\}$; the constraint has zero shadow price once $\omega \ge 1/5$. (iii) With all logarithmic factors retained, the running time $T(r,m) = (\sqrt N/(\sqrt r\, m) + r)L^4 + mL^2$ satisfies $T \ge F := N^{1/5}L^{16/5}$ for all $r,m>0$, with $T = 3F$ attained; adding any nonnegative order-dependent term leaves the lower bound intact. (iv) Producing an element of order $N^\omega$ at cost $N^{\omega/2}$ is dominated everywhere. (v) A filter on Lehman's pair family yields exactly $1/5 - 3\sigma/5$ if it is generative and $1/5 - 2\sigma/5$ if it must evaluate each pair, where $N^\sigma$ is the compression; a sound residue sieve on residue-uniform good pairs is trivial. (vi) We record the structured "large Euler gap" split: if $(p-1)\mid(q-1)$ then $\gcd(x^{pq-1}-1, pq) = p$ whenever $q \nmid x^{pq-1}-1$. Throughout, $N^{1/5}$ is an upper bound on the deterministic state of the art, not a proven lower bound for factoring.

---

## 1. Introduction

### 1.1 Deterministic factoring

Let $N = pq$ be a product of two primes. The fastest practical factoring algorithms (the quadratic and number field sieves) have heuristic subexponential running times, and rigorous randomised algorithms with subexponential expected running time are also known. If one insists on algorithms that are both *deterministic* and *rigorously analysed*, the picture is very different: the best known bounds are fully exponential in $\log N$, of the form $N^{c+o(1)}$.

For decades the record exponent was $c = 1/4$, achieved by the Pollard–Strassen method of fast polynomial evaluation, later improved by logarithmic factors. In 2020 D. Harvey obtained the exponent $c = 1/5$, with running time

$$O\!\left(N^{1/5}\log^{16/5} N\right).$$

His algorithm combines Lehman's method, which reduces factoring to a search over a family of small integer pairs $(a,b)$, with a baby-step giant-step search in the multiplicative group modulo $N$.

### 1.2 Where the multiplicative order enters

The baby-step table in Harvey's algorithm consists of consecutive powers $\alpha, \alpha^2, \dots, \alpha^m$ of an element $\alpha \in (\mathbb Z/N\mathbb Z)^\times$. These are pairwise distinct if and only if $m \le \operatorname{ord}_N(\alpha)$, and the bound is sharp: if $m > \operatorname{ord}_N(\alpha)$ then two baby steps collide. Hence the multiplicative order of $\alpha$ enters the algorithm in exactly two ways:

1. as a **correctness constraint** $m \le \operatorname{ord}_N(\alpha)$;
2. through the number of **spurious hash-table hits** during the search, which feed a product-tree computation. This contributes a nonnegative additive term to the running time. At the balanced parameters it is only polylogarithmic in $N$.

It does not enter the Lehman pair budget $r$, the baby-step budget $m$ itself, or the smoothness-sieve range $\lceil (N/r)^{1/2}\rceil$.

In 2025–2026 two lines of work gave deterministic methods for producing elements of large multiplicative order. Gao, Feng, Hu and Pan give a procedure that, given $N$ and a target $\delta$ in the range $N^{1/4}\log^8 N \le \delta \le N$, returns an element of order greater than $\delta$ (or a nontrivial factor of $N$, or a certificate that $N$ is prime) in time $O(\delta^{1/2}\log^2 N/(\log\log\delta)^{1/2})$. Harvey and Hittmeir gave further deterministic methods for finding elements of large multiplicative order. A natural question follows: *with hypothesis-free order-finding available, can the trade-off in Harvey's algorithm be rebalanced to beat $N^{1/5}$?*

### 1.3 Summary of results

We answer this negatively within Harvey's cost model, and we do so quantitatively.

- **Theorem 1 (order-free certificate).** The exponent cost $c(a,b) = \max\{a, b, \tfrac12 - \tfrac a2 - b\}$ satisfies $c(a,b) \ge 1/5$ for all real $a,b$, with equality if and only if $a = b = 1/5$.
- **Theorem 2 (order-constrained optimum).** Under $b \le \omega$, $\min c(a,b) = \max\{1/5, (1-2\omega)/3\}$. The constraint is slack if and only if $\omega \ge 1/5$.
- **Theorem 3 (polylogarithmic lower bound).** $T(r,m) \ge N^{1/5}L^{16/5}$ for all $r, m > 0$, with equality of all three summands, and hence $T = 3F$, at an explicit point.
- **Corollary 4 (free order-finding cannot help).** For any $P \ge 0$, $T(r,m) + P \ge F$.
- **Theorem 5 (production is dominated).** $\max\{c(a,b), b/2\} = c(a,b)$ for $b \ge 0$, and the joint optimum including production is $1/5$.
- **Theorem 6 (pair filters).** Generative compression $N^\sigma$ gives optimum $1/5 - 3\sigma/5$, evaluated compression gives $1/5 - 2\sigma/5$, and the target $1/6$ needs $\sigma = 1/18$ and $\sigma = 1/12$ respectively.
- **Proposition 7 (residue sieves are trivial).** A sound sieve modulo $\ell$ on residue-uniform good pairs accepts all $\ell$ classes.
- **Theorem 8 (large Euler gap).** If $(p-1)\mid(q-1)$, $p \nmid x$ and $q \nmid x^{pq-1}-1$, then $\gcd(x^{pq-1}-1, pq) = p$.

The conclusion is that the exponent $1/5$ is pinned by a triangle of three **order-free** legs, so the multiplicative order of $\alpha$ is not a lever. The frontier for a sub-$1/5$ deterministic method is therefore either to break the balance between the pair budget and the remaining legs (for instance by a generative filter on Lehman's pairs), or to leave the baby-step giant-step motif altogether.

---

## 2. The cost model

### 2.1 Harvey's running time

Let $L = \lg N$. For parameters $r$ (the Lehman pair budget) and $m$ (the number of baby steps per giant step), Harvey's analysis bounds the running time, up to a constant factor, by

$$T(r,m) \;=\; \left(\frac{N^{1/2}}{r^{1/2}\,m} + r\right)L^4 \;+\; m\,L^2. \tag{2.1}$$

The three summands have the following meanings.

- $X = rL^4$ is the **pair leg**. The pair family $\mathcal P_r = \{(a,b) \in \mathbb Z_{>0}^2 : ab \le r\}$ has $\Theta(r\log r)$ elements, and each requires polylogarithmic work.
- $Y = N^{1/2}L^4/(r^{1/2}m)$ is the **giant-step interior**: the residual search range, of size about $(N/r)^{1/2}$, divided by the baby-step stride $m$.
- $Z = mL^2$ is the **baby-step leg**.

### 2.2 The exponent model

Writing $r = N^a$ and $m = N^b$ and discarding logarithmic factors gives the exponent cost.

**Definition 2.1 (exponent cost).** For real $a, b$,
$$c(a,b) \;=\; \max\left\{\, a,\; b,\; \tfrac12 - \tfrac a2 - b \,\right\}.$$

**Definition 2.2 (order-constrained value).** For real $\omega$, with $\operatorname{ord}_N(\alpha) = N^\omega$,
$$V(\omega) \;=\; \max\left\{\tfrac15,\; \tfrac{1-2\omega}{3}\right\}.$$

**Definition 2.3 (filtered exponent costs).** For a compression exponent $\sigma$ (a filter keeping a $N^{-\sigma}$ fraction of pairs, still containing the good pair):
$$c^{\mathrm{gen}}_\sigma(a,b) = \max\left\{a - \sigma,\; b,\; \tfrac12 - \tfrac a2 - b - \sigma\right\}, \qquad c^{\mathrm{eval}}_\sigma(a,b) = \max\left\{a,\; b,\; \tfrac12 - \tfrac a2 - b - \sigma\right\}.$$

A *generative* filter outputs only the surviving pairs, in time proportional to their number, so both the pair leg and the per-pair interior sum shrink by $N^\sigma$. An *evaluated* filter must examine every pair before discarding it, so the pair leg is unchanged and only the interior shrinks.

---

## 3. The order-free triangle

**Theorem 1 (order-free certificate; unique minimiser).** For all real $a, b$,
$$c(a,b) \;\ge\; \tfrac15,$$
and $c(a,b) = \tfrac15$ if and only if $a = b = \tfrac15$.

*Proof.* The weighted combination of the three legs with weights $\tfrac15, \tfrac25, \tfrac25$ is identically constant:
$$\tfrac15 a + \tfrac25 b + \tfrac25\left(\tfrac12 - \tfrac a2 - b\right) = \tfrac15.$$
Since a maximum dominates every convex combination of its arguments, $c(a,b) \ge 1/5$. If $c(a,b) = 1/5$, then each leg is at most $1/5$ while their weighted average with positive weights is exactly $1/5$, so each leg equals $1/5$. In particular $a = b = 1/5$. Conversely, $c(1/5,1/5) = \max\{1/5, 1/5, 1/2 - 1/10 - 1/5\} = 1/5$. $\square$

The weights $(1/5, 2/5, 2/5)$ are the optimal dual variables of the linear program $\min\{t : t \ge a,\, t \ge b,\, t \ge \tfrac12 - \tfrac a2 - b\}$. **None of the three legs involves the order of $\alpha$**: the triangle that fixes $1/5$ is order-free.

---

## 4. The order is a constraint, not a lever

**Theorem 2 (order-constrained optimum).** For every real $\omega$:

1. (*lower bound*) for all $a$ and all $b \le \omega$, $V(\omega) \le c(a,b)$;
2. (*attainment*) there exist $a$ and $b \le \omega$ with $c(a,b) = V(\omega)$.

Consequently $\min_{b \le \omega} c(a,b) = V(\omega)$.

*Proof.* (1) By Theorem 1, $c(a,b) \ge 1/5$. Also $c(a,b) \ge a$ and $c(a,b) \ge \tfrac12 - \tfrac a2 - b$, so
$$3c(a,b) \ge a + 2\left(\tfrac12 - \tfrac a2 - b\right) = 1 - 2b \ge 1 - 2\omega,$$
using the weights $(1/3, 0, 2/3)$. Hence $c(a,b) \ge (1-2\omega)/3$.

(2) If $\omega \ge 1/5$, take $a = b = 1/5$: then $b \le \omega$ and $c = 1/5 = V(\omega)$, since $(1-2\omega)/3 \le 1/5$. If $\omega < 1/5$, take $b = \omega$ and $a = (1-2\omega)/3$. Then $\tfrac12 - \tfrac a2 - b = (1-2\omega)/3$ and $b = \omega < 1/5 < (1-2\omega)/3$, so $c(a,b) = (1-2\omega)/3 = V(\omega)$. $\square$

**Corollary 2.1 (threshold and zero shadow price).**
(a) $V(\omega) = 1/5$ if and only if $\omega \ge 1/5$.
(b) If $\omega < 1/5$ then $V(\omega) > 1/5$.
(c) If $\omega_1, \omega_2 \ge 1/5$ then $V(\omega_1) = V(\omega_2)$. In particular, an element of maximal order ($\omega = 1$) is worth exactly as much as one of order $N^{1/5}$.

**Corollary 2.2 (order is not a lever).** For all $a$, $b$, $\omega$ with $b \le \omega$: $c(a,b) \ge 1/5$, and if $c(a,b) = 1/5$ then $\omega \ge 1/5$.

*Proof.* The first claim is Theorem 1. If $c(a,b) = 1/5$, uniqueness gives $b = 1/5$, so $\omega \ge b = 1/5$. $\square$

So no order exponent whatsoever yields an admissible point below $1/5$. Attaining $1/5$ requires order at least $N^{1/5}$, and nothing beyond that helps.

---

## 5. Retaining the logarithmic factors

Exponent models can hide logarithmic factors. We now show that the conclusion survives with Harvey's full bound (2.1).

**Lemma 3.1 (weighted product identity).** For $N \ge 0$ and $r, m > 0$, with $X = rL^4$, $Y = \sqrt N L^4/(\sqrt r\, m)$ and $Z = mL^2$,
$$X\,Y^2\,Z^2 \;=\; N\,L^{16}.$$

*Proof.* $X Y^2 Z^2 = rL^4 \cdot \dfrac{N L^8}{r\,m^2}\cdot m^2 L^4 = N L^{16}$. $\square$

**Theorem 3 (polylogarithmic lower bound and attainment).** Let $F(N, L) = N^{1/5}L^{16/5}$.

1. For all $N \ge 0$, $L \ge 0$ and $r, m > 0$: $\;F(N,L) \le T(r,m)$.
2. Parametrise $N = u^{10}$, $L = \ell^5$ with $u, \ell > 0$, so that $F = u^2\ell^{16}$. At $r^\ast = u^2/\ell^4 = N^{1/5}L^{-4/5}$ and $m^\ast = u^2\ell^6 = N^{1/5}L^{6/5}$, all three summands of $T$ equal $F$, and therefore $T(r^\ast, m^\ast) = 3F$.

*Proof.* (1) By the weighted AM–GM inequality with weights $(1/5, 2/5, 2/5)$ and Lemma 3.1,
$$T = X + Y + Z \;\ge\; \tfrac15X + \tfrac25Y + \tfrac25Z \;\ge\; X^{1/5}Y^{2/5}Z^{2/5} = \left(XY^2Z^2\right)^{1/5} = \left(NL^{16}\right)^{1/5} = F.$$
(2) We have $\sqrt N = u^5$ and $\sqrt{r^\ast} = u/\ell^2$. Then $X = (u^2/\ell^4)\ell^{20} = u^2\ell^{16}$, $Z = u^2\ell^6\cdot\ell^{10} = u^2\ell^{16}$, and $Y = u^5\ell^{20}/\big((u/\ell^2)\,u^2\ell^6\big) = u^2\ell^{16}$. $\square$

**Corollary 4 (free order-finding cannot help).** Let $P \ge 0$ be any additional order-dependent cost, such as the product-tree work on spurious hash hits. Then for all $r, m > 0$,
$$F(N,L) \;\le\; T(r,m) + P.$$
In particular, with order-finding literally free ($P = 0$), the optimum over $r, m > 0$ lies in the window $[F, 3F]$, so the exponent of $N$ is exactly $1/5$, with the same power of $L$.

*Proof.* Immediate from Theorem 3 (1), since $P \ge 0$. The window follows from Theorem 3 (2). $\square$

**Remark (dimensional mismatch).** The only quantity that the order influences beyond the constraint $m \le \operatorname{ord}$ is the spurious hit count, which has $N$-exponent $0$. The quantity to be moved, the running-time exponent, is $1/5$. A lever acting on an $N^0$ quantity cannot move an $N^{1/5}$ quantity. Corollary 4 is the precise form of this observation.

---

## 6. Producing large-order elements is dominated

To use $m = N^b$ baby steps one needs $\operatorname{ord}_N(\alpha) \ge N^b$. Model the cost of producing an element of order $N^\omega$ as $N^{\omega/2}$, which matches the $\delta^{1/2}$ cost of the Gao–Feng–Hu–Pan procedure up to logarithmic factors.

**Theorem 5 (production is dominated).**

1. For all $a$ and all $b \ge 0$: $\max\{c(a,b),\, b/2\} = c(a,b)$.
2. For all $a, b, \omega$ with $b \le \omega$: $\max\{c(a,b), \omega/2\} \ge 1/5$. Moreover equality is attained, at $a = b = \omega = 1/5$.

*Proof.* (1) $b/2 \le b \le c(a,b)$ when $b \ge 0$. (2) The lower bound follows from Theorem 1. At $a = b = \omega = 1/5$, part (1) and Theorem 1 give $\max\{1/5, 1/10\} = 1/5$. $\square$

For instance, the instance $\delta = N^{1/3}$ costs $N^{1/6}$, and $1/6 < 1/5$. So the enabling sub-problem "deterministically produce an element of order at least $N^{1/3}$" is already solved below Harvey's cost, and solving it buys nothing. In the exponent picture the order sets an upper limit on $b$, while the exponent is set by the balance of all three legs. At the optimum the baby-step leg is $N^{1/4}r^{-1/4}$ (from $b = \tfrac12 - \tfrac a2 - b$), so the order and the pair budget are coupled only through this balance, never directly.

---

## 7. Filtering Lehman's pairs

The pair leg $X = rL^4$ is the only summand of (2.1) that is not divided by $m$. A compression of the pair family is therefore the most concrete target for improvement.

**Theorem 6 (filter values).** For every real $\sigma$:

1. (*generative*) $c^{\mathrm{gen}}_\sigma(a,b) \ge \tfrac15 - \tfrac{3\sigma}5$ for all $a,b$, with equality attained;
2. (*evaluated*) $c^{\mathrm{eval}}_\sigma(a,b) \ge \tfrac15 - \tfrac{2\sigma}5$ for all $a,b$, with equality attained.

Moreover $\tfrac15 - \tfrac{3\sigma}5 = \tfrac16 \iff \sigma = \tfrac1{18}$, and $\tfrac15 - \tfrac{2\sigma}5 = \tfrac16 \iff \sigma = \tfrac1{12}$.

*Proof.* Use the same certificate weights $(1/5, 2/5, 2/5)$. For the generative cost,
$$\tfrac15(a - \sigma) + \tfrac25 b + \tfrac25\left(\tfrac12 - \tfrac a2 - b - \sigma\right) = \tfrac15 - \tfrac{3\sigma}5.$$
This is a lower bound, and it is attained where the three legs coincide: $b = \tfrac15 - \tfrac{3\sigma}5$ and $a = b + \sigma$. For the evaluated cost the combination is
$$\tfrac15 a + \tfrac25 b + \tfrac25\left(\tfrac12 - \tfrac a2 - b - \sigma\right) = \tfrac15 - \tfrac{2\sigma}5,$$
attained at $a = b = \tfrac15 - \tfrac{2\sigma}5$. The last statements are linear equations in $\sigma$. $\square$

So a generative filter converts compression into exponent at rate $3/5$, while an evaluated filter does so only at rate $2/5$. Reaching $1/6$ needs compression $N^{1/18}$ in the first case and $N^{1/12}$ in the second.

### 7.1 Residue sieves

The simplest filters are congruence sieves: fix a small modulus $\ell$ and keep only pairs whose residue data (for example $ab \bmod \ell$, or the quadratic character of $a$) lie in an accepted set $A \subseteq \mathbb Z/\ell\mathbb Z$. Such a sieve is *sound* if it never rejects the good pair.

**Proposition 7 (sound residue sieves are trivial).** Let $\ell \ge 1$, let $I$ be an index set of instances, and let $g : I \to \mathbb Z/\ell\mathbb Z$ assign to each instance the residue class of its good pair. Suppose $g$ is surjective (*residue-uniformity*). If $A \subseteq \mathbb Z/\ell\mathbb Z$ satisfies $g(i) \in A$ for all $i$, then $A = \mathbb Z/\ell\mathbb Z$, so $|A| = \ell$ and the compression is $1$.

*Proof.* Every class $c$ equals $g(i)$ for some $i$, and $g(i) \in A$. $\square$

Numerically, over random balanced semiprimes, the residues of $ab$ for the Lehman good pair fill every class modulo $\ell = 3, 5, 7, 11$, so residue-uniformity holds empirically. A congruence sieve thus acts on the *right quantity*, namely Harvey's pair family rather than a range of values, but it is closed on cost: it compresses nothing.

---

## 8. A structured promise class: the large Euler gap

**Lemma 8.1 (exponent reduction).** Let $p$ be prime, $q \ge 1$, and $a \in \mathbb F_p^\times$. Then $a^{pq-1} = a^{q-1}$ in $\mathbb F_p$.

*Proof.* $pq - 1 = (q-1) + q(p-1)$, and $a^{p-1} = 1$ by Fermat's little theorem. $\square$

**Corollary 8.2 (collapse).** If moreover $(p-1) \mid (q-1)$, then $a^{pq-1} = 1$ for all $a \in \mathbb F_p^\times$.

**Theorem 8 (Euler-gap split).** Let $p, q$ be primes with $(p-1) \mid (q-1)$. Let $x$ be a positive integer with $p \nmid x$ and $q \nmid x^{pq-1} - 1$. Then
$$\gcd\left(x^{pq-1} - 1,\; pq\right) = p.$$

*Proof.* By Corollary 8.2, $p \mid x^{pq-1}-1$, so $p \mid g := \gcd(x^{pq-1}-1, pq)$. Write $g = pk$. Since $g \mid pq$, we get $k \mid q$, so $k \in \{1, q\}$. If $k = q$, then $q \mid g \mid x^{pq-1}-1$, which contradicts the hypothesis. Hence $g = p$. $\square$

*Example.* $341 = 11\cdot 31$ is the smallest base-$2$ Fermat pseudoprime, and $10 \mid 30$. Base $2$ fails the second hypothesis, since $2^{340} \equiv 1 \pmod{31}$ as well. Base $3$ satisfies it, and $\gcd(3^{340} - 1, 341) = 11$. The same happens for $481 = 13\cdot 37$ with base $2$, and for $60701 = 101 \cdot 601$ with base $3$. By contrast, for $N = 1019\cdot 1031$, where $\gcd(p-1,q-1) = 2$, no base below $50$ splits $N$.

More generally, a large $\gcd(p-1, q-1)$ makes the Fermat gcd reveal a factor after few bases. This is a genuine $O(\log^{O(1)} N)$ method on a promise class, but such semiprimes are sparse, and it is not a route to general factoring.

---

## 9. Algorithms

We record the computational procedures implicit in the results.

**Algorithm A (exact order-constrained optimiser).** Input: $\omega \in \mathbb R$. If $\omega \ge 1/5$ return $(a,b) = (1/5,1/5)$ and value $1/5$. Otherwise return $(a,b) = ((1-2\omega)/3,\, \omega)$ and value $(1-2\omega)/3$. Cost $O(1)$. Correctness is Theorem 2.

**Algorithm B (balanced parameters with logarithms).** Input: $N$. Set $L = \lg N$, $r^\ast = N^{1/5}L^{-4/5}$, $m^\ast = N^{1/5}L^{6/5}$. The three legs then equal $F = N^{1/5}L^{16/5}$, and $T(r^\ast, m^\ast) = 3F$. Correctness is Theorem 3.

**Algorithm C (filter planner).** Input: $\sigma$ and the filter type. For a generative filter return $b = \tfrac15 - \tfrac{3\sigma}5$, $a = b + \sigma$. For an evaluated filter return $a = b = \tfrac15 - \tfrac{2\sigma}5$. Inversely, for a target exponent $e$ return the required $\sigma = (1/5 - e)\cdot 5/3$ or $(1/5 - e)\cdot 5/2$.

**Algorithm D (Euler-gap splitter).** Input: $N$ and a base bound $B$. For $x = 2, \dots, B$, compute $g = \gcd(x^{N-1} - 1 \bmod N,\, N)$ by square-and-multiply. If $1 < g < N$, return $g$. Cost: $B$ modular exponentiations, i.e. $O(B\,\log N\cdot M(\log N))$ bit operations, where $M(k)$ is the cost of multiplying $k$-bit integers. Theorem 8 guarantees success on the promise class whenever some base $x \le B$ has $p \nmid x$ and $q \nmid x^{N-1}-1$.

---

## 10. Discussion

**What is and is not proved.** All results concern the cost structure of Harvey's algorithm and of natural modifications of it. They do not give a lower bound for factoring. No unconditional superpolynomial lower bound for integer factorisation is known in any standard model, and $N^{1/5}$ is the best *known upper bound* for rigorous deterministic factoring. What is ruled out is a specific mechanism: improving the order of the baby-step element.

**Correct quantity versus correct cost.** It is useful to separate two ways a proposed improvement can fail. It can act on the *wrong quantity*. The large-order lever is an instance: it acts on an $N^0$ hit count and on a constraint that is already slack. Or it can act on the *right quantity* but at no gain. Residue sieves on Lehman's pairs are an instance: they act on the pair family, the one leg not divided by $m$, but under residue-uniformity they compress by a factor $1$. Theorems 2–6 and Proposition 7 make both failure modes precise.

**Other directions.** Two further mechanisms are worth mentioning for context. *Rational base descent*, a recent deterministic method, splits $N = pq$ in $O(\log^3 N)$ time per run when $p$ is close to $c(a/b)^n$ for small rational bases. Precisely, writing $\Delta = p - \lfloor c(a/b)^n\rfloor$, a split occurs when $(a/b)^n > q$ and $|\Delta| < (a/b)^n/q$. This is a Diophantine-approximation promise on $p$, essentially never satisfied by a random prime, so it gives no new exponent for balanced semiprimes. A conjecture of a different kind, on pairs of sets $S, T$ of size $n^\beta$ with entries of magnitude at most $e^{n^\alpha}$ such that every $i \le n$ divides some difference $s - t$, would imply exponent $1/6$ for deterministic integer factoring. Its flagship consequence concerns polynomial factorisation. It acts on an index set, the right kind of quantity, and remains a conditional route outside the order lever.

---

## 11. Future work

1. **Generative pair-filter threshold.** *Conjecture:* any deterministic generator that outputs a subfamily of $\{(a,b): ab\le r\}$ guaranteed to contain Lehman's good pair, in time proportional to its output size, has output size at least $r^{1-o(1)}$ for worst-case balanced semiprimes. By Theorem 6, only a generative filter can reach $1/6$ at $s = N^{1/18}$; an evaluated filter needs $N^{1/12}$; and residue sieves are trivial (Proposition 7).
2. **Joint shadow prices of order and filter.** *Conjecture:* with a generative filter $\sigma$ and an order constraint $b \le \omega$, the optimum is exactly $\max\{1/5 - 3\sigma/5,\; (1-2\omega-3\sigma)/3\}$, so the order threshold drops to $\omega^\ast = 1/5 - 3\sigma/5$. (The second branch comes from balancing the filtered pair leg $a - \sigma$ against the filtered interior $\tfrac12 - \tfrac a2 - \omega - \sigma$ at $b = \omega$. It is the unique linear branch that agrees with $1/5 - 3\sigma/5$ at the threshold.) The order threshold always sits at the $b$-coordinate of the unconstrained optimum, so every filter gain lowers the order requirement.
3. **Hit-count polylogarithmic law.** *Conjecture:* in Harvey's search step the expected number of spurious hash hits is $\Theta(s m/D)$, polylogarithmic in $N$ at the balanced point, uniformly over elements of order at least $N^{1/5}$. By Corollary 4, any such nonnegative term leaves the window $[F,3F]$ unchanged. A counting proof via the pigeonhole bound on baby-step collisions appears within reach.
4. **Euler-gap density.** *Conjecture:* among balanced semiprimes $N \le X$, those with $\gcd(p-1,q-1) \ge N^\theta$ have density $X^{-\theta+o(1)}$, so the Euler-gap split covers a vanishing class. By Lemma 8.1 the split depends only on $\gcd(p-1,q-1)$, so what remains is analytic counting.

---

## 12. Conclusion

Harvey's exponent $1/5$ arises from balancing three legs: Lehman's pair budget, the baby-step table, and the giant-step interior. A linear certificate with weights $(1/5,2/5,2/5)$, and its multiplicative counterpart via weighted AM–GM with the identity $XY^2Z^2 = NL^{16}$, show that the balance is order-free. The multiplicative order of the baby-step element enters only as the constraint $b \le \omega$, which is slack beyond $\omega = 1/5$, and as a nonnegative additive term that cannot lower the bound. Producing large-order elements is cheap enough to be dominated everywhere. The lever for future progress is therefore not the order but the pair family. Its exact exchange rates are now known: $3/5$ per unit of generative compression and $2/5$ per unit of evaluated compression.

---

## References

1. D. Harvey, *An exponent one-fifth algorithm for deterministic integer factorisation*, Mathematics of Computation 90 (2021); arXiv:2010.05450.
2. D. Harvey and M. Hittmeir, *Deterministic methods for finding elements of large multiplicative order*, arXiv:2601.11131 (2026).
3. Gao, Feng, Hu and Pan, arXiv:2512.19076 (2025): deterministic production of elements of large multiplicative order.
4. R. S. Lehman, *Factoring large integers*, Mathematics of Computation 28 (1974).
5. J. M. Pollard, *Theorems on factorization and primality testing*, Proc. Cambridge Philos. Soc. 76 (1974); V. Strassen, *Einige Resultate über Berechnungskomplexität*, Jber. Deutsch. Math.-Verein. 78 (1976).
6. S. Blake, *Rational base descent: a deterministic algorithm for factoring structured semiprimes*, arXiv:2605.08846 (2026).
7. arXiv:2511.10851 (2025): a conjecture on divisibility of differences of sparse sets, with consequences for deterministic polynomial and integer factorisation.
