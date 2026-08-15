# Power-Sum GCD Factor Revelation and Carmichael Periodicity

**Author:** Aristotle
**Date:** 2026-08-15

---

## Abstract

For a modulus $N$ and an exponent $k \ge 1$ let
$$F_N(k) \;=\; \sum_{a=1}^{N} a^{k}$$
be the $k$-th power sum of a complete residue system modulo $N$. We give a
complete, closed-form determination of the arithmetic function
$g_N(k) = \gcd\big(F_N(k),\, N\big)$ in three settings: semiprime moduli,
arbitrary squarefree moduli, and odd prime powers.

For $N = pq$ with $p \neq q$ prime and $k \ge 1$ we prove the **master formula**
$$g_N(k) \;=\; \big[\,(p-1) \mid k\,\big]^{\,\mathrm{c}}_{p} \cdot \big[\,(q-1) \mid k\,\big]^{\,\mathrm{c}}_{q},$$
meaning the product of $p$ (if $(p-1) \nmid k$, else $1$) and $q$ (if
$(q-1) \nmid k$, else $1$). Four immediate corollaries follow. (i) **Factor
reveal:** $g_N(p-1) = q$ whenever $(q-1) \nmid (p-1)$, a condition that is
automatic when $p < q$, so the reveal is unconditional at the smaller exponent.
(ii) **Base-freeness:** unlike Pollard's $p-1$ method, the power sum has no
base parameter and hence no bad base; we exhibit a base, $a = N-1$, that is bad
for Pollard at *every* exponent, and show the power sum succeeds at an exponent
where that base fails. (iii) **Carmichael periodicity:** $g_N$ is periodic with
least period $\lambda(N) = \operatorname{lcm}(p-1, q-1)$, and
$g_N(k) = 1 \iff \lambda(N) \mid k$, so $\lambda(N)$ is the position of the
first $1$ in the sequence. (iv) **Complexity:** the first nontrivial value
occurs exactly at $k^\ast = \min(p-1,q-1) < \sqrt{N}$, and within one period
exactly $\lambda/(p-1) + \lambda/(q-1) - 2$ exponents reveal a proper factor.

We further show that the widely quoted recovery step "$p + q = N - \lambda(N) + 1$"
is **false** in general — $p = 5$, $q = 13$ is a counterexample — because it
conflates $\lambda(N) = \operatorname{lcm}(p-1,q-1)$ with
$\varphi(N) = (p-1)(q-1)$. The correct identity is
$\gcd(p-1,q-1)\cdot\lambda(N) + (p+q) = N+1$, which reduces to the naive form
exactly under the guard $\gcd(p-1,q-1) = 1$; under that guard the factorization
is uniquely recovered from $\lambda(N)$.

Two extensions complete the picture. For squarefree $N$ the same divisibility
criterion holds at every prime factor, and $g_N(N-1) = 1$ if and only if $N$
satisfies Korselt's criterion — Carmichael numbers are exactly the squarefree
moduli on which the reveal at the natural exponent $k = N-1$ is blind. For an
odd prime power we prove
$\sum_{a<p^e} a^k \equiv -p^{e-1} \pmod{p^e}$ if $(p-1) \mid k$ and $\equiv 0$
otherwise, so that $\gcd(F_N(k), p^e) = p^{e-1}$ or $p^e$ accordingly. Notably
the governing condition is $(p-1) \mid k$, **not** $\lambda(p^e) \mid k$: the
$p$-part of the unit group is invisible to the power sum.

The total cost to reach the first hit is $O(N^{3/2})$, worse than trial
division. The value of the development is structural: it exhibits an explicit
integer sequence whose period is the Carmichael number and whose period
therefore determines the factorization — the same period-finding structure that
Shor's algorithm exploits — with the entire hardness concentrated in the
period-finding barrier.

**Keywords.** power sum, Fermat's little theorem, Carmichael function,
integer factorization, Pollard's $p-1$, Korselt criterion, period finding,
Gauss sum, lifting the exponent.

---

## 1. Introduction

### 1.1 Motivation

Classical factoring methods of the "algebraic group" family — Pollard's $p-1$,
Williams' $p+1$, Lenstra's elliptic curve method — all share a common
architecture. One chooses an element $a$ of some group defined modulo $N$,
raises it to a highly composite exponent $M$, and computes a gcd. The method
succeeds when the order of $a$ in the group modulo one prime factor divides $M$
while the order modulo another does not. Success therefore depends on two
independent gambles: the smoothness of the relevant group order, and the luck of
the chosen element $a$. The second gamble is the *bad base problem*.

This paper studies a base-free alternative. Rather than probing with a single
residue, we aggregate over the entire residue system:
$$F_N(k) \;=\; \sum_{a=1}^{N} a^{k}, \qquad g_N(k) \;=\; \gcd\big(F_N(k),\,N\big).$$
There is nothing to choose, and consequently nothing to choose badly. We show
that $g_N(k)$ admits an exact closed form, and that this closed form encodes the
factorization of $N$ in two distinct ways: through its *values* (which are
literally the prime factors) and through its *period* (which is the Carmichael
function $\lambda(N)$).

### 1.2 Contributions

1. **A master value table** (Theorem 3.5) determining $g_{pq}(k)$ for all
   $k \ge 1$, from which the factor reveal, the value $N$, the value $1$, and
   the periodicity all follow as special cases.
2. **An unconditional reveal** (Corollary 5.2): for $p < q$ no side condition is
   needed at exponent $k = p-1$.
3. **A robustness theorem** (Theorem 4.3) exhibiting a Pollard base that is bad
   at every exponent, together with the power sum's success at the same
   exponent.
4. **Exact Carmichael periodicity with sharpness** (Theorems 6.2–6.5).
5. **Correction of a false recovery formula** (Theorem 7.1) and its repair
   (Theorem 7.2), with a complete recovery statement under an explicit guard
   (Theorem 7.5).
6. **First-hit and density estimates** (Theorems 5.3–5.6) quantifying the
   period-finding barrier.
7. **Two extensions of the domain**: arbitrary squarefree moduli with a
   Korselt/Carmichael bridge (Section 8), and odd prime powers via a
   lift-the-exponent recursion (Section 9).

### 1.3 What this is not

This is not a factoring breakthrough. Section 10 records the honest complexity:
$O(N^{3/2})$ to the first hit, strictly worse than trial division's
$O(\sqrt{N})$. The development is a structure theory, and its interest lies in
the sharpness and completeness of the description, and in the light it sheds on
why the encoded information is inaccessible classically.

---

## 2. Definitions and notation

Throughout, $p$ and $q$ denote primes, $N$ a positive integer, and $k$ a
positive integer exponent. We write $[P]$ for the Iverson bracket.

> **Definition 2.1 (Power sum).** For $N, k \ge 0$,
> $$F_N(k) \;=\; \sum_{a=1}^{N} a^{k} \;=\; 1^k + 2^k + \cdots + N^k.$$
> We also write $\mathrm{IP}_M(k) = \sum_{a=0}^{M-1} a^k$ for the power sum over
> $\{0, 1, \dots, M-1\}$ regarded as an integer.

Note $F_N(0) = N$. For $k \ge 1$ the two conventions agree modulo any divisor
$d$ of $N$, since $1^k+\cdots+N^k$ and $0^k+\cdots+(N-1)^k$ differ by
$N^k - 0^k \equiv 0 \pmod{d}$. We use whichever is convenient.

> **Definition 2.2 (Power-sum gcd sequence).**
> $$g_N(k) \;=\; \gcd\big(F_N(k),\, N\big).$$

> **Definition 2.3 (Carmichael function of a semiprime).** For distinct primes
> $p, q$,
> $$\lambda(pq) \;=\; \operatorname{lcm}(p-1,\, q-1).$$
> More generally, for squarefree $N$,
> $\lambda(N) = \operatorname{lcm}_{p \mid N} (p-1)$.
> This is the exponent of the unit group $(\mathbb{Z}/N\mathbb{Z})^\times$ for
> squarefree $N$.

> **Definition 2.4 (Pollard gcd).** For a modulus $N$, a base $a$, and an
> exponent $M$,
> $$\Pi_N(a, M) \;=\; \gcd\big(a^{M} - 1,\; N\big).$$
> Pollard's $p-1$ method succeeds precisely when $\Pi_N(a, M)$ is a proper
> divisor of $N$, i.e. neither $1$ nor $N$.

> **Definition 2.5 (Revealing exponent).** An exponent $k \ge 1$ is *revealing*
> for $N$ if $g_N(k) \notin \{1, N\}$; that is, if $g_N(k)$ is a proper
> nontrivial divisor of $N$.

---

## 3. The master formula for semiprimes

The determination of $g_{pq}$ proceeds in three steps: a Fermat evaluation of
the power sum over a prime field, a periodicity reduction from the interval
$[1, N]$ to a single residue system, and multiplicativity of the gcd.

### 3.1 Step one: the Fermat power sum

> **Lemma 3.1 (Fermat power sum).** Let $p$ be prime and $k \ge 1$. Then, in
> $\mathbb{Z}/p\mathbb{Z}$,
> $$\sum_{x \in \mathbb{Z}/p\mathbb{Z}} x^{k} \;=\; \begin{cases} -1, & (p-1) \mid k,\\ \phantom{-}0, & \text{otherwise.}\end{cases}$$

*Proof sketch.* Since $k \ge 1$, the term $x = 0$ contributes $0$, so the sum
runs over the unit group $(\mathbb{Z}/p\mathbb{Z})^\times$, a cyclic group of
order $p-1$. If $(p-1) \mid k$, then $x^k = 1$ for every unit by Fermat's little
theorem, and the sum is $p-1 \equiv -1$. Otherwise fix a generator $g$; then
$g^k \neq 1$, and $x \mapsto gx$ permutes the units, so
$S = \sum_x x^k$ satisfies $g^k S = S$, whence $(g^k - 1)S = 0$ and $S = 0$
since $\mathbb{Z}/p\mathbb{Z}$ is a field. $\square$

### 3.2 Step two: the periodicity reduction

> **Lemma 3.2 (Full-period summation).** Let $p \ge 1$ and let
> $f : \mathbb{Z}/p\mathbb{Z} \to \mathbb{Z}/p\mathbb{Z}$. Then
> $$\sum_{a=0}^{p-1} f(a \bmod p) \;=\; \sum_{x \in \mathbb{Z}/p\mathbb{Z}} f(x),$$
> and, for any $m \ge 0$,
> $$\sum_{a=0}^{pm-1} f(a \bmod p) \;=\; m \cdot \sum_{x \in \mathbb{Z}/p\mathbb{Z}} f(x).$$

*Proof sketch.* The first identity is the bijection $a \mapsto a \bmod p$
between $\{0,\dots,p-1\}$ and $\mathbb{Z}/p\mathbb{Z}$. The second follows by
induction on $m$, splitting $[0, pm+p)$ into $[0,pm)$ and a shifted copy of
$[0,p)$, and using $pm \equiv 0 \pmod p$ to see that the shift is invisible to
$f$. $\square$

> **Proposition 3.3 (Reduction of the power sum).** Let $p \ge 1$, $m \ge 0$,
> $k \ge 1$, $N = pm$. Then in $\mathbb{Z}/p\mathbb{Z}$
> $$F_N(k) \;\equiv\; m \cdot \sum_{x \in \mathbb{Z}/p\mathbb{Z}} x^{k} \pmod{p}.$$

*Proof sketch.* First replace the index set $[1,N]$ by $[0,N)$: the two sums
differ by $N^k - 0^k$, and $p \mid N$, $k \ge 1$ force this difference to vanish
mod $p$. Then apply Lemma 3.2 with $f(x) = x^k$ and the factorization
$N = p \cdot m$. $\square$

The intuition is the "residues march in formation" picture: the interval
$[1, pm]$ covers each residue class modulo $p$ exactly $m$ times, so the power
sum modulo $p$ is $m$ copies of the residue-system power sum, and Lemma 3.1
evaluates the latter.

### 3.3 Step three: the divisibility criterion and the gcd

> **Theorem 3.4 (Divisibility criterion).** Let $p$ be prime, $m \ge 1$ with
> $p \nmid m$, and $k \ge 1$. Then
> $$p \mid F_{pm}(k) \iff (p-1) \nmid k.$$

*Proof sketch.* Combining Proposition 3.3 and Lemma 3.1,
$F_{pm}(k) \equiv m \cdot \varepsilon \pmod p$ where $\varepsilon = -1$ if
$(p-1) \mid k$ and $\varepsilon = 0$ otherwise. Since $p \nmid m$, we have
$m \not\equiv 0$, so $m\varepsilon \equiv 0$ iff $\varepsilon = 0$ iff
$(p-1) \nmid k$. $\square$

> **Theorem 3.5 (Master formula).** Let $N = pq$ with $p \ne q$ prime, and let
> $k \ge 1$. Then
> $$g_N(k) \;=\; \gcd\big(F_N(k),\, N\big) \;=\; \Big( (p-1) \mid k \;?\; 1 : p \Big)\cdot\Big( (q-1) \mid k \;?\; 1 : q \Big).$$

*Proof sketch.* Since $p \ne q$ are prime they are coprime, so
$\gcd(x, pq) = \gcd(x,p)\gcd(x,q)$. For a prime $r$, $\gcd(x, r) = r$ if
$r \mid x$ and $1$ otherwise. Apply Theorem 3.4 twice: with $m = q$ (legitimate
since $p \nmid q$) and with $m = p$. $\square$

The table of possible values is therefore complete:

| $(p-1) \mid k$ | $(q-1) \mid k$ | $g_N(k)$ | interpretation |
|:---:|:---:|:---:|:---|
| no | no | $N$ | trivial: sum divisible by $N$ |
| yes | no | $q$ | **factor revealed** |
| no | yes | $p$ | **factor revealed** |
| yes | yes | $1$ | trivial: sum coprime to $N$ |

> **Corollary 3.6 (Theorem 1: factor reveal).** If $p \ne q$ are prime and
> $(q-1) \nmid (p-1)$, then
> $$\gcd\Big(\sum_{a=1}^{pq} a^{\,p-1},\; pq\Big) \;=\; q.$$
> Dually, if $(p-1) \nmid (q-1)$ then $g_{pq}(q-1) = p$.

*Proof.* Take $k = p-1$ in Theorem 3.5. The first bracket is $1$ since
$(p-1) \mid (p-1)$; the second is $q$ by hypothesis. $\square$

> **Corollary 3.7 (Properness).** Under the hypotheses of Corollary 3.6, the
> revealed value $q$ is a proper nontrivial divisor: $q \neq 1$ and $q \neq pq$
> (the latter because $p > 1$).

---

## 4. Robustness: the power sum has no bad base

Pollard's $p-1$ method computes $\Pi_N(a, M) = \gcd(a^M - 1, N)$ and requires a
fortunate choice of base $a$. The power sum, having no base, cannot be defeated
this way. We make the contrast precise by exhibiting a base that is bad
*universally* — for every exponent, without exception.

> **Lemma 4.1.** Let $r$ be a prime with $r \mid N$ and $N \ge 2$. Then in
> $\mathbb{Z}/r\mathbb{Z}$, $(N-1)^M - 1 \equiv (-1)^M - 1$.

*Proof sketch.* $N \equiv 0 \pmod r$, so $N - 1 \equiv -1$; raise to the $M$-th
power and subtract $1$. (Care is required with truncated natural subtraction;
one first checks $(N-1)^M \ge 1$.) $\square$

> **Lemma 4.2.** Let $r$ be an odd prime dividing $N \ge 2$.
> (i) If $M$ is odd, $r \nmid (N-1)^M - 1$, because the quantity is
> $\equiv -2 \not\equiv 0 \pmod r$.
> (ii) If $M$ is even, $r \mid (N-1)^M - 1$, because the quantity is
> $\equiv 0 \pmod r$.

> **Theorem 4.3 (A universally bad Pollard base).** Let $N = pq$ with $p \ne q$
> distinct **odd** primes. Then for every exponent $M \ge 0$,
> $$\Pi_N(N-1,\, M) \;=\; \gcd\big((N-1)^M - 1,\ N\big) \;=\; \begin{cases} N, & M \text{ even},\\ 1, & M \text{ odd}.\end{cases}$$
> In particular $\Pi_N(N-1, M)$ is **never** a proper divisor of $N$, for any
> exponent whatsoever.

*Proof sketch.* Split $\gcd(\cdot, pq) = \gcd(\cdot,p)\gcd(\cdot,q)$ by
coprimality and apply Lemma 4.2 to each of $p, q$, according to the parity of
$M$. $\square$

> **Proposition 4.4 (The bad base is nontrivial).** With $p, q$ distinct odd
> primes and $N = pq \ge 15$, the base $a = N-1$ satisfies $1 < a < N$ and
> $\gcd(a, N) = 1$. It is therefore a base a practitioner would legitimately
> select.

> **Theorem 4.5 (Robustness: the power sum succeeds where the base fails).** Let
> $p \ne q$ be distinct odd primes with $(q-1) \nmid (p-1)$, and set $N = pq$.
> At the exponent $k = p-1$ (which is even):
> $$\Pi_N(N-1,\, p-1) = N \quad\text{(Pollard fails)}, \qquad g_N(p-1) = q \quad\text{(power sum succeeds)}.$$

*Proof sketch.* $p$ odd makes $p-1$ even, so Theorem 4.3 gives $\Pi_N = N$;
Corollary 3.6 gives $g_N(p-1) = q$. $\square$

> **Example 4.6.** $N = 35 = 5 \cdot 7$, $M = 4 = p-1$, base $a = 6 = N-1$. Then
> $6^4 - 1 = 1295 = 35 \cdot 37$, so $\gcd(1295, 35) = 35$: Pollard returns the
> whole modulus. The power sum at the same exponent returns
> $\gcd(F_{35}(4), 35) = 7$.

The conceptual content: Theorem 4.3 says the failure mode of a base-dependent
method can be *total and permanent* for a legitimate base, while Theorem 4.5
says the base-free aggregate does not share that failure mode, because it
averages over all residues at once and Fermat's theorem evaluates the average
exactly.

---

## 5. The first hit and the density of revealing exponents

### 5.1 Value-$N$ characterization

> **Proposition 5.1.** For $N = pq$, $p\ne q$ prime, $k \ge 1$:
> $$g_N(k) = N \iff \big( (p-1) \nmid k \ \text{ and } \ (q-1) \nmid k \big).$$

*Proof sketch.* Immediate from Theorem 3.5 and the observation that of the four
possible product values $N, p, q, 1$, only the first equals $pq$ (using
$p, q \ge 2$). $\square$

### 5.2 An unconditional reveal

> **Lemma 5.2a.** If $p < q$ are primes, then $(q-1) \nmid (p-1)$.

*Proof.* $p \ge 2$ so $p - 1 \ge 1 > 0$; a positive multiple of $q-1$ is at
least $q-1 > p-1$. $\square$

> **Corollary 5.2 (Unconditional factor reveal).** For distinct primes
> $p < q$,
> $$g_{pq}(p-1) \;=\; q,$$
> with no divisibility side condition required.

This strengthens Corollary 3.6: the hypothesis $(q-1) \nmid (p-1)$ in the
original statement is not an assumption but a consequence, once one works at the
*smaller* exponent.

### 5.3 The first hit

> **Theorem 5.3 (First hit).** Let $N = pq$, $p \ne q$ prime. Then
> $$k^\ast \;=\; \min(p-1,\, q-1)$$
> is the least positive exponent at which $g_N(k) \ne N$; i.e. $k^\ast$ is the
> minimum of $\{k \ge 1 : g_N(k) \ne N\}$.

*Proof sketch.* Membership: at $k = k^\ast$, one of $(p-1), (q-1)$ equals
$k^\ast$ and hence divides it, so by Proposition 5.1 $g_N(k^\ast) \ne N$.
Minimality: if $g_N(k) \ne N$ with $k \ge 1$, Proposition 5.1 says
$(p-1) \mid k$ or $(q-1) \mid k$; either way that divisor is $\le k$, hence
$k^\ast \le k$. $\square$

> **Theorem 5.4 (The first hit is already a proper factor).** If $p < q$ then
> $g_N(k^\ast) = g_N(p-1) = q$, a proper nontrivial divisor.

> **Theorem 5.5 (First hit below the square root).** For primes $p, q$,
> $$\big(\min(p-1, q-1) + 1\big)^2 \;\le\; pq,$$
> i.e. $k^\ast < \sqrt{N}$.

*Proof sketch.* If $p \le q$ then $\min(p-1,q-1)+1 = p$, and $p^2 \le pq$. The
other case is symmetric. $\square$

### 5.4 Density of revealing exponents

> **Lemma 5.6a.** Inside $(0, \lambda]$ with $\lambda = \lambda(N)$, the set of
> multiples of $p-1$ and the set of multiples of $q-1$ intersect exactly in
> $\{\lambda\}$.

*Proof sketch.* $k$ is a common multiple iff $\operatorname{lcm}(p-1,q-1) = \lambda$
divides $k$; combined with $0 < k \le \lambda$ this forces $k = \lambda$. $\square$

> **Theorem 5.6 (Density inside one period).** Let $N = pq$ with $p \ne q$ prime
> and $\lambda = \lambda(N)$. The number of revealing exponents in $(0, \lambda]$
> — those $k$ with $g_N(k) \notin \{1, N\}$ — is exactly
> $$\frac{\lambda}{p-1} \;+\; \frac{\lambda}{q-1} \;-\; 2.$$

*Proof sketch.* By Theorem 3.5, $k$ is revealing iff exactly one of
$(p-1) \mid k$, $(q-1) \mid k$ holds. Writing $A$ and $B$ for the sets of
multiples of $p-1$ and $q-1$ inside $(0,\lambda]$, the revealing set is the
symmetric difference $(A \setminus B) \cup (B \setminus A)$, a disjoint union.
Now $|A| = \lambda/(p-1)$ and $|B| = \lambda/(q-1)$ (counting multiples in an
interval of length exactly $\lambda$), and $|A \cap B| = 1$ by Lemma 5.6a.
Hence $|A\setminus B| + |B \setminus A| = |A| + |B| - 2|A\cap B|$. $\square$

> **Example 5.7.** $N = 35$: $\lambda = 12$, and the count is
> $12/4 + 12/6 - 2 = 3 + 2 - 2 = 3$. The revealing exponents in $\{1,\dots,12\}$
> are indeed $k = 4, 6, 8$, with values $7, 5, 7$.

The proportion of revealing exponents in a period is
$$\frac{1}{p-1} + \frac{1}{q-1} - \frac{2}{\lambda},$$
which for cryptographic-size primes is negligible. This is the quantitative form
of the period-finding barrier: even with full knowledge of the structure, blind
search within a period is hopeless.

---

## 6. Carmichael periodicity

> **Definition 6.1.** $\lambda(pq) = \operatorname{lcm}(p-1, q-1)$; note
> $\lambda(pq) > 0$ whenever $p, q \ge 2$.

> **Theorem 6.2 (Periodicity).** Let $N = pq$, $p \ne q$ prime, $k \ge 1$. Then
> $$g_N\big(k + \lambda(N)\big) \;=\; g_N(k).$$

*Proof sketch.* Since $(p-1) \mid \lambda(N)$, we have
$(p-1) \mid (k + \lambda(N)) \iff (p-1) \mid k$; similarly for $q-1$. The master
formula depends on $k$ only through these two conditions. $\square$

> **Theorem 6.3 (Trivial values are exactly the multiples of $\lambda$).** For
> $k \ge 1$,
> $$g_N(k) = 1 \iff \lambda(N) \mid k.$$

*Proof sketch.* By Theorem 3.5, $g_N(k) = 1$ forces both bracket factors to be
$1$ (since $p, q > 1$, a product $\ne 1$ arises whenever either bracket
contributes its prime), i.e. $(p-1)\mid k$ and $(q-1)\mid k$, i.e.
$\operatorname{lcm}(p-1,q-1) \mid k$. Conversely both divisibilities give
$1 \cdot 1 = 1$. $\square$

> **Theorem 6.4 ($\lambda(N)$ is legible).** $\lambda(N)$ is the least element of
> $\{k \ge 1 : g_N(k) = 1\}$.

*Proof.* $\lambda(N)$ lies in the set (Theorem 6.3, $\lambda \mid \lambda$), and
any element $k$ of the set is a positive multiple of $\lambda(N)$, hence
$\ge \lambda(N)$. $\square$

> **Theorem 6.5 (Exact minimality of the period).** For every $d$ with
> $0 < d < \lambda(N)$ there is a $k \ge 1$ with $g_N(k+d) \ne g_N(k)$. Hence
> $\lambda(N)$ is the *least* period of $g_N$ on $k \ge 1$.

*Proof sketch.* Take $k = \lambda(N)$. Then $g_N(k) = 1$ by Theorem 6.3. But
$\lambda(N) \nmid \lambda(N) + d$, since otherwise $\lambda(N) \mid d$ and thus
$\lambda(N) \le d$, contradicting $d < \lambda(N)$. So
$g_N(\lambda(N) + d) \ne 1 = g_N(\lambda(N))$. $\square$

Together, Theorems 6.2–6.5 say: the sequence $g_N(1), g_N(2), \dots$ is exactly
periodic, its least period is the Carmichael number $\lambda(N)$, and that
period can be read off as the index of the sequence's first $1$.

**Worked sequences.**

$N = 15 = 3 \cdot 5$, $\lambda = \operatorname{lcm}(2,4) = 4$:

| $k$ | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 |
|:--|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:--:|:--:|:--:|
| $g_{15}(k)$ | 15 | 5 | 15 | 1 | 15 | 5 | 15 | 1 | 15 | 5 | 15 | 1 |

$N = 35 = 5 \cdot 7$, $\lambda = \operatorname{lcm}(4,6) = 12$:

| $k$ | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 |
|:--|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:--:|:--:|:--:|
| $g_{35}(k)$ | 35 | 35 | 35 | 7 | 35 | 5 | 35 | 7 | 35 | 35 | 35 | 1 |

---

## 7. Factor recovery from the period: a false formula and its repair

Suppose an oracle hands us $\lambda(N)$. Can we factor $N$?

A recurring claim in informal treatments is that one may set
$p + q = N - \lambda(N) + 1$ and then solve the quadratic
$X^2 - (p+q)X + N$. The reasoning appeals to
$\varphi(N) = (p-1)(q-1) = N - (p+q) + 1$ and then silently replaces $\varphi(N)$
by $\lambda(N)$. This is invalid.

> **Theorem 7.1 (The naive recovery formula is false).** Take $p = 5$, $q = 13$,
> so $N = 65$. Then $\lambda(N) = \operatorname{lcm}(4, 12) = 12$, and
> $$N - \lambda(N) + 1 \;=\; 65 - 12 + 1 \;=\; 54 \;\ne\; 18 \;=\; p + q.$$

The discrepancy is exactly the factor $\gcd(p-1, q-1) = \gcd(4,12) = 4$, and the
general identity that governs it is:

> **Theorem 7.2 (Corrected recovery identity).** For all integers
> $p, q \ge 1$, writing $\lambda = \operatorname{lcm}(p-1, q-1)$,
> $$\gcd(p-1,\,q-1) \cdot \lambda \;+\; (p+q) \;=\; pq \;+\; 1.$$

*Proof sketch.* The identity $\gcd(m,n)\operatorname{lcm}(m,n) = mn$ with
$m = p-1$, $n = q-1$ turns the first term into $(p-1)(q-1)$. Writing $p = a+1$,
$q = b+1$ makes the claim $ab + (a+1) + (b+1) = (a+1)(b+1) + 1$, which is a
polynomial identity. $\square$

Equivalently: $\varphi(N) + (p+q) = N + 1$ with
$\varphi(N) = (p-1)(q-1) = \gcd(p-1,q-1)\cdot\lambda(N)$. The period alone gives
$\lambda$, not $\varphi$; recovering $\varphi$ requires the extra factor
$\gcd(p-1,q-1)$, which is not visible in the sequence.

> **Corollary 7.3 (Recovery under a coprimality guard).** If
> $\gcd(p-1, q-1) = 1$, then
> $$\lambda(N) + (p+q) \;=\; N + 1,$$
> i.e. the naive formula is correct exactly in this case.

> **Lemma 7.4 (Vieta uniqueness).** Let $s, N \ge 0$ and suppose
> $a + b = s = a' + b'$ and $ab = N = a'b'$ with $a \le b$ and $a' \le b'$
> (all in $\mathbb{Z}_{\ge 0}$). Then $a = a'$ and $b = b'$.

*Proof sketch.* Both $a$ and $a'$ satisfy $X(s - X) = N$, so
$(a - a')(a + a' - s) = 0$ over $\mathbb{Z}$. In the first case $a = a'$ and
then $b = b'$. In the second case $a' = s - a = b$ and $b' = s - a' = a$;
combined with $a \le b$ and $a' \le b'$ this forces $a = b$, hence again
$a = a'$, $b = b'$. $\square$

> **Theorem 7.5 (Full recovery from the period).** Let $N = pq$ with $p < q$
> distinct primes satisfying the guard $\gcd(p-1, q-1) = 1$. Let
> $\lambda = \lambda(N)$ be the least period read off the sequence $g_N$. If
> $a \le b$ are non-negative integers with
> $$ab = N \quad\text{and}\quad a + b = N + 1 - \lambda,$$
> then $a = p$ and $b = q$.

*Proof sketch.* By Corollary 7.3, $N + 1 - \lambda = p + q$. So the pair
$(a,b)$ and the pair $(p,q)$ have the same sum and the same product, and both
are ordered; Lemma 7.4 identifies them. $\square$

Thus, **under the guard $\gcd(p-1,q-1) = 1$, the period determines the
factorization.** Without the guard, one recovers only $\lambda(N)$, and
extracting $\varphi(N)$ requires the additional datum $\gcd(p-1,q-1)$.

> **Remark 7.6.** The guard is not vacuous but it is restrictive: if $p, q$ are
> both odd then $p-1$ and $q-1$ are both even, so $\gcd(p-1,q-1) \ge 2$ and the
> guard *fails*. It holds only when one of the primes is $2$. In cryptographic
> practice one therefore never gets the naive formula; the corrected identity
> and the extra gcd datum are essential. This makes the correction of Theorem
> 7.1 not a pedantic footnote but the substantive statement.

---

## 8. Arbitrary squarefree moduli and the Korselt bridge

Nothing in Section 3 used the number of prime factors of $N$.

> **Theorem 8.1 (Squarefree divisibility criterion).** Let $N$ be squarefree,
> $p$ a prime with $p \mid N$, and $k \ge 1$. Then
> $$p \mid F_N(k) \iff (p-1) \nmid k.$$

*Proof sketch.* Write $N = pm$. Squarefreeness gives $p \nmid m$ (otherwise
$p^2 \mid N$). Apply Theorem 3.4. $\square$

> **Definition 8.2.** For squarefree $N$,
> $\lambda(N) = \operatorname{lcm}_{p \mid N}\,(p-1)$, the lcm over the prime
> factors of $N$.

> **Theorem 8.3 (General Carmichael periodicity).** For squarefree $N \ge 1$ and
> $k \ge 1$,
> $$\gcd\big(F_N(k),\, N\big) = 1 \iff \lambda(N) \mid k.$$

*Proof sketch.* $\gcd(F_N(k), N) \ne 1$ iff some prime $p \mid N$ also divides
$F_N(k)$, iff (Theorem 8.1) some prime $p \mid N$ has $(p-1) \nmid k$. Negating,
coprimality holds iff $(p-1) \mid k$ for every $p \mid N$, iff the lcm divides
$k$. $\square$

### 8.1 Primes see themselves as $-1$

> **Proposition 8.4 (Fermat/Giuga direction).** For a prime $p$,
> $$\sum_{a=1}^{p} a^{\,p-1} \;\equiv\; -1 \pmod p,$$
> and consequently $\gcd(F_p(p-1),\, p) = 1$: a prime is never "revealed" by
> itself.

*Proof sketch.* Proposition 3.3 with $m = 1$ plus Lemma 3.1 with
$(p-1) \mid (p-1)$. $\square$

This is the power-sum shadow of Giuga's conjecture, which concerns exactly when
$\sum_{a=1}^{n-1} a^{\,n-1} \equiv -1 \pmod n$ can hold for composite $n$.

### 8.2 Carmichael numbers are the blind spot

Recall **Korselt's criterion**: a composite squarefree $N$ is a Carmichael
number (i.e. $a^{N} \equiv a \pmod N$ for all integers $a$) if and only if
$(p-1) \mid (N-1)$ for every prime $p \mid N$.

> **Theorem 8.5 (Korselt bridge).** Let $N \ge 2$ be squarefree. Then
> $$\Big(\forall\, p \mid N \text{ prime},\ (p-1) \mid (N-1)\Big) \iff \gcd\big(F_N(N-1),\, N\big) = 1.$$

*Proof sketch.* Apply Theorem 8.3 at $k = N-1$: coprimality is equivalent to
$\lambda(N) \mid N-1$, which unfolds by the definition of lcm into
$(p-1) \mid (N-1)$ for all prime $p \mid N$. $\square$

**Interpretation.** Carmichael numbers are precisely the squarefree moduli on
which the power-sum reveal, evaluated at the natural exponent $k = N-1$, is
completely uninformative. The same divisibility condition that makes them fool
the Fermat primality test makes them defeat this method at that exponent.

> **Example 8.6.** $N = 561 = 3 \cdot 11 \cdot 17$, the smallest Carmichael
> number. $\lambda(561) = \operatorname{lcm}(2, 10, 16) = 80$ and $80 \mid 560$,
> so $\gcd(F_{561}(560), 561) = 1$.

Note that the failure is exponent-specific, not global: $\lambda(561) = 80$, so
by Theorem 8.3 the exponents $k$ that are *not* multiples of $80$ still leak
information about $561$. It is only the "natural" choice $k = N-1$ that is
blind.

---

## 9. Odd prime powers: lifting the exponent

Squarefreeness was used exactly once, to ensure $p \nmid m$ in $N = pm$. We now
remove it at odd primes.

The naive guess is that the governing divisibility condition at $p^e$ should be
$\lambda(p^e) = p^{e-1}(p-1)$, the exponent of $(\mathbb{Z}/p^e\mathbb{Z})^\times$.
It is not. For $p^e = 9$, one computes $\sum_{a<9} a^k \equiv 6 \equiv -3 \pmod 9$
for **every even** $k$, not merely for $k$ divisible by $\lambda(9) = 6$. The
$p$-part of the unit group is invisible to the power sum.

> **Lemma 9.1 (Block decomposition).** For any $M, t \ge 0$ and any function $f$
> into an abelian group,
> $$\sum_{a=0}^{Mt-1} f(a) \;=\; \sum_{j=0}^{t-1}\ \sum_{r=0}^{M-1} f(Mj + r).$$

> **Lemma 9.2 (Binomial with nilpotent increment).** In a commutative ring, if
> $y^2 = 0$ then for all $k \ge 0$,
> $$(x+y)^{k+1} \;=\; x^{k+1} + (k+1)\,x^{k}\,y.$$

*Proof sketch.* Induction on $k$, using $y^2 = 0$ to kill every higher binomial
term. $\square$

> **Theorem 9.3 (Lift-the-exponent step).** Let $p$ be an **odd** prime,
> $e \ge 2$, $k \ge 1$. Then, in $\mathbb{Z}/p^{e}\mathbb{Z}$,
> $$\sum_{a=0}^{p^{e}-1} a^{k} \;=\; p \cdot \sum_{r=0}^{p^{e-1}-1} r^{k}.$$

*Proof sketch.* Put $M = p^{e-1}$ and write each $a < p^e$ uniquely as
$a = Mj + r$ with $j < p$, $r < M$ (Lemma 9.1). Modulo $p^e$ we have $M^2 = 0$
and $Mp = 0$. Apply Lemma 9.2 with $x = r$, $y = Mj$ (legitimate since
$(Mj)^2 = M^2 j^2 = 0$):
$$(Mj + r)^{k} = r^{k} + k\,r^{k-1}\,Mj.$$
Summing over $r < M$ and then over $j < p$, the first part contributes
$p \sum_{r<M} r^{k}$, and the second contributes
$\big(k \sum_{r<M} r^{k-1}\big)\cdot M \cdot \sum_{j<p} j$. Now
$\sum_{j<p} j = p(p-1)/2$, which is an integer multiple of $p$ **because $p$ is
odd**; hence $M \cdot \sum_{j<p} j$ is a multiple of $Mp \equiv 0 \pmod{p^e}$
and the whole second part vanishes. $\square$

> **Theorem 9.4 (Prime-power Fermat sum).** Let $p$ be an odd prime, $e \ge 1$,
> $k \ge 1$. Then
> $$\sum_{a=0}^{p^{e}-1} a^{k} \;\equiv\; \begin{cases} -\,p^{\,e-1} \pmod{p^{e}}, & (p-1) \mid k,\\[2pt] \phantom{-}0 \pmod{p^{e}}, & \text{otherwise.}\end{cases}$$

*Proof sketch.* Induction on $e$. Base case $e = 1$: Lemma 3.1 (the sum is $-1$
or $0$, and $p^{0} = 1$). Inductive step: Theorem 9.3 gives
$\sum_{a<p^{e+1}} a^k \equiv p\sum_{a<p^{e}} a^k \pmod{p^{e+1}}$; the induction
hypothesis is a congruence modulo $p^{e}$, and multiplying a congruence mod
$p^{e}$ by $p$ yields a congruence mod $p^{e+1}$. The right-hand value
transforms as $p \cdot (-p^{e-1}) = -p^{e}$, as required. $\square$

> **Theorem 9.5 (Prime-power master formula).** Let $p$ be an odd prime,
> $e \ge 1$, $k \ge 1$, and let $N = p^{e} m$ with $p \nmid m$. Then
> $$\gcd\big(F_N(k),\; p^{e}\big) \;=\; \begin{cases} p^{\,e-1}, & (p-1) \mid k,\\ p^{e}, & \text{otherwise.}\end{cases}$$

*Proof sketch.* By the reduction of Proposition 3.3 in the ring
$\mathbb{Z}/p^e\mathbb{Z}$ combined with Theorem 9.4,
$F_N(k) \equiv -m\,p^{e-1}$ or $0$ modulo $p^e$ according to the condition. In
the second case $p^e \mid F_N(k)$ outright. In the first, $p^{e-1}$ divides
$F_N(k)$, but $p^{e}$ does not: that would force $p^e \mid m\,p^{e-1}$, i.e.
$p \mid m$, contradicting the hypothesis. Since every divisor of $p^e$ is a
power of $p$, the gcd is exactly $p^{e-1}$. $\square$

So a prime power $p^{e} \,\|\, N$ is revealed in full unless $(p-1) \mid k$, in
which case exactly one power of $p$ is lost — never more, never fewer.

> **Example 9.6.** $N = 45 = 3^2 \cdot 5$, $k = 2$. Since $(3-1) \mid 2$, the
> $3$-part of the gcd drops from $9$ to $3$. And $(5-1) \nmid 2$, so the $5$-part
> is full. Prediction: $\gcd(F_{45}(2), 45) = 3 \cdot 5 = 15$. Direct
> computation confirms it.

> **Open (the prime $2$).** The prime $2$ is genuinely exceptional: the Gauss
> sum step in Theorem 9.3 requires $p$ odd. For $N = 8$, and $k \ge 2$, the gcd is $4$ for even $k$
> and $8$ for odd $k$. Determining the $2$-part of
> $\gcd(F_N(k), N)$ for $2^{e} \| N$, and assembling the local formulas by the
> Chinese Remainder Theorem into a master formula for arbitrary $N$, remains
> open.

---

## 10. Algorithms and complexity

### 10.1 The reveal algorithm

**Input:** semiprime $N$; **Output:** a proper factor.

1. For $k = 1, 2, 3, \dots$:
2. $\quad$ Compute $S \leftarrow \sum_{a=1}^{N} a^{k} \bmod N$.
3. $\quad$ Compute $d \leftarrow \gcd(S, N)$.
4. $\quad$ If $1 < d < N$, return $d$.

**Correctness.** By Theorem 5.3, the loop terminates at
$k = k^\ast = \min(p-1,q-1)$, and by Theorem 5.4 the value returned there is the
larger prime.

**Cost.** Each $F_N(k) \bmod N$ costs $N$ modular exponentiations, i.e.
$O(N \log k)$ modular multiplications, or $O(N)$ operations with the natural
incremental scheme. Since $k^\ast \approx \sqrt{N}$ (Theorem 5.5), the total is
$$O\big(N \cdot \sqrt{N}\big) \;=\; O\big(N^{3/2}\big).$$

By comparison trial division costs $O(\sqrt N)$ and Pollard's rho $O(N^{1/4})$.
**The power-sum method is asymptotically worse than trial division.** This is
stated plainly, not hedged: the interest of the development is structural.

### 10.2 The period-reading algorithm

**Input:** semiprime $N$ with $\gcd(p-1,q-1) = 1$; **Output:** $\{p, q\}$.

1. For $k = 1, 2, \dots$: compute $g \leftarrow \gcd(F_N(k) \bmod N, N)$.
2. $\quad$ If $g = 1$: set $\lambda \leftarrow k$ and break.
3. Set $s \leftarrow N + 1 - \lambda$.
4. Solve $X^2 - sX + N = 0$ over $\mathbb{Z}$; return the two roots.

**Correctness.** Step 2 finds $\lambda = \lambda(N)$ by Theorem 6.4. Step 3 is
Corollary 7.3. Step 4's roots are unique and equal $\{p,q\}$ by Theorem 7.5.
**Guard required:** without $\gcd(p-1,q-1) = 1$, step 3 is invalid — Theorem
7.1. In that case one obtains only $\lambda(N)$; recovering
$\varphi(N) = \gcd(p-1,q-1)\cdot\lambda(N)$ requires the extra gcd.

**Cost.** $\lambda(N)$ can be as large as $\Theta(N)$, so this is $O(N^2)$ in the
worst case: even more expensive.

### 10.3 The period-finding barrier

Both algorithms bottleneck on the same thing: locating a distinguished exponent
in a sequence whose period is $\lambda(N)$, sampled one expensive point at a
time. Theorem 5.6 quantifies why blind search fails — revealing exponents occupy
a $\big(\tfrac{1}{p-1} + \tfrac{1}{q-1}\big)$-fraction of a period.

This is the same architecture that Shor's algorithm dissolves. Shor extracts the
period of $x \mapsto a^{x} \bmod N$ in polynomial time via the quantum Fourier
transform, and converts that period to a factorization. Here we have a
*different* sequence, $k \mapsto \gcd(F_N(k), N)$, with the same signature: an
explicitly computable function of $k$ whose least period is $\lambda(N)$ and
whose period determines the factorization (under the guard of Theorem 7.5, or
with the correction of Theorem 7.2 in general). The mathematics isolates, in an
unusually clean setting, exactly which step is the hard one.

---

## 11. Numerical verification

The following values are direct computations of
$g_N(p-1) = \gcd\big(\sum_{a=1}^{N} a^{p-1},\, N\big)$ and $\lambda(N)$.

| $p$ | $q$ | $N = pq$ | $k = p-1$ | $g_N(k)$ | predicted | $\lambda(N)$ |
|--:|--:|--:|--:|--:|--:|--:|
| 3 | 5 | 15 | 2 | 5 | $q = 5$ | 4 |
| 5 | 7 | 35 | 4 | 7 | $q = 7$ | 12 |
| 7 | 11 | 77 | 6 | 11 | $q = 11$ | 30 |
| 11 | 13 | 143 | 10 | 13 | $q = 13$ | 60 |
| 13 | 17 | 221 | 12 | 17 | $q = 17$ | 48 |
| 17 | 19 | 323 | 16 | 19 | $q = 19$ | 144 |
| 23 | 29 | 667 | 22 | 29 | $q = 29$ | 308 |
| 89 | 97 | 8633 | 88 | 97 | $q = 97$ | 1056 |

All eight agree with Corollary 5.2.

Further checks:

- **Period tables.** $g_{15}$ over $k=1..12$ is
  $(15,5,15,1,15,5,15,1,15,5,15,1)$, period $4 = \lambda(15)$;
  $g_{35}$ over $k=1..12$ is $(35,35,35,7,35,5,35,7,35,35,35,1)$, period
  $12 = \lambda(35)$; first $1$ at $k = \lambda$ in both cases (Theorem 6.4).
- **Density.** For $N = 35$ the revealing exponents in $1..12$ are exactly
  $\{4, 6, 8\}$, three of them, matching $12/4 + 12/6 - 2 = 3$ (Theorem 5.6).
- **Bad base.** $\gcd(6^4 - 1, 35) = 35$ while $g_{35}(4) = 7$ (Theorem 4.5,
  Example 4.6).
- **Carmichael blind spot.** $\gcd(F_{561}(560), 561) = 1$ (Theorem 8.5,
  Example 8.6).
- **Non-squarefree.** $\gcd(F_{45}(2), 45) = 15$, i.e. the $3$-part is $3$ not
  $9$ (Theorem 9.5, Example 9.6).
- **Recovery counterexample.** For $p=5$, $q=13$: $\lambda = 12$ and
  $65 - 12 + 1 = 54 \ne 18$; the corrected identity gives
  $\gcd(4,12)\cdot 12 + 18 = 4\cdot 12 + 18 = 66 = 65+1$ (Theorems 7.1, 7.2).

---

## 12. Discussion

### 12.1 What the master formula buys

The distinguishing feature of Theorem 3.5 relative to the classical
group-theoretic methods is *completeness*. Pollard's $p-1$ admits a success
criterion but no closed form for its output. Here every value is determined,
and the entire behaviour of $g_N$ reduces to two Boolean predicates. That
completeness is what makes the downstream results — exact least period, exact
first-hit index, exact density count, exact Korselt equivalence — possible at
all. Nothing in Sections 5–8 is an estimate.

### 12.2 The correction matters

Remark 7.6 deserves emphasis. For $N$ a product of two odd primes, the guard
$\gcd(p-1,q-1) = 1$ *always fails*, since $2$ divides both $p-1$ and $q-1$. So
the naive recovery formula is not merely occasionally wrong; it is wrong in
every case of practical interest. Theorem 7.2 supplies the correct relation and
identifies the missing datum as $\gcd(p-1,q-1)$, which is not readable from the
period. This narrows the gap between "know the period" and "know the
factorization" to exactly one additional invariant.

### 12.3 Carmichael numbers, twice

Carmichael numbers appear here in two distinct roles. As *moduli*, they are the
squarefree $N$ on which the natural exponent $k=N-1$ is blind (Theorem 8.5). As
a *function*, the Carmichael $\lambda$ is the least period (Theorem 6.4). The
coincidence is not accidental: both statements are the assertion
$\lambda(N) \mid k$, once at the specific $k = N-1$ and once as a general
divisibility condition. Korselt's criterion, viewed this way, is a statement
about a power-sum sequence.

### 12.4 The prime-power surprise

Theorem 9.4's condition is $(p-1) \mid k$, not $\lambda(p^e) = p^{e-1}(p-1) \mid k$.
That the $p$-Sylow part of the unit group is invisible to the power sum is a
real phenomenon with a clean mechanism: the lift-the-exponent recursion of
Theorem 9.3 multiplies the sum by $p$ at each level without touching the
$k$-dependence, so the base-case condition $(p-1)\mid k$ propagates unchanged.
The Gauss sum $\sum_{j<p} j = p(p-1)/2$ is the pivot, and its divisibility by
$p$ is exactly the oddness hypothesis — which is why $2$ is exceptional.

### 12.5 Relation to the quantum picture

We stress this is a classical structure theorem, not a quantum algorithm. But
the shape is instructive. The factorization of $N$ is not concealed in the
sequence $g_N$; it is *displayed* — the prime factors literally appear as
values. The barrier is the cost of sampling ($O(N)$ per point) combined with
the sparsity of informative points (Theorem 5.6). Both are exactly the
obstacles a period-finding subroutine removes. Making the barrier this explicit
is, we think, the main pedagogical value of the development.

---

## 13. Future directions

### 13.1 The prime $2$ and a global master formula

Theorem 9.4 covers odd prime powers. The prime $2$ behaves differently: for
$N = 8$, and $k \ge 2$, the gcd $\gcd(F_8(k), 8)$ is $4$ for even $k$ and $8$
for odd $k$, and the Gauss-sum step fails since $2(2-1)/2 = 1$ is not divisible
by $2$. **Problem:** determine the $2$-part of $\gcd(F_N(k), N)$ for $2^{e} \| N$,
and combine the odd-prime-power formula of Theorem 9.5 with it via the Chinese
Remainder Theorem to obtain a master formula valid for arbitrary $N$.

### 13.2 Giuga's conjecture in power-sum form

Proposition 8.4 states that a prime $p$ satisfies
$\sum_{a=1}^{p-1} a^{\,p-1} \equiv -1 \pmod p$. Giuga's conjecture asserts no
composite $n$ satisfies $\sum_{a=1}^{n-1} a^{\,n-1} \equiv -1 \pmod n$. The
squarefree machinery of Section 8 gives a partial handle: for squarefree $n$,
the condition decomposes prime by prime via Theorem 8.1. **Problem:** determine
exactly which squarefree $n$ satisfy the local conditions
$\sum_{a<n} a^{n-1} \equiv -1 \pmod p$ for each $p \mid n$, and characterize the
resulting obstruction; separately, use Theorem 9.5 to rule out non-squarefree
$n$.

### 13.3 Sharper density and first-hit statistics

Theorem 5.6 counts revealing exponents in one period exactly. **Problem:**
average this count over semiprimes $N \le X$, using the distribution of
$\gcd(p-1,q-1)$ and $\operatorname{lcm}(p-1,q-1)$, to obtain the expected
proportion of revealing exponents and hence the expected cost of a randomized
exponent search.

### 13.4 Weighted and twisted power sums

The power sum $\sum_a a^k$ is the trivial-character case of
$\sum_a \chi(a) a^k$. **Problem:** for a Dirichlet character $\chi$ modulo $N$,
determine $\gcd\big(\sum_{a=1}^{N} \chi(a) a^{k},\, N\big)$ and ask whether a
nontrivial twist can shift the revealing exponents to smaller values, reducing
the first-hit index $k^\ast$ below $\min(p-1,q-1)$.

### 13.5 Fast evaluation of $F_N(k)$

The $O(N)$ per-evaluation cost is the dominant term. $\sum_{a=1}^{N} a^k$ is a
polynomial in $N$ of degree $k+1$ (Faulhaber), computable in $O(k)$ operations
given Bernoulli numbers — but $k \approx \sqrt N$ and Bernoulli numbers modulo
$N$ have their own difficulties (von Staudt–Clausen denominators). **Problem:**
determine whether $F_N(k) \bmod N$ can be evaluated in time $\mathrm{polylog}(N)$
for $k \approx \sqrt N$, which would bring the reveal algorithm to
$\tilde O(\sqrt N)$ and make it competitive with trial division.

---

## 14. Conclusion

We have given a complete closed-form description of the arithmetic function
$k \mapsto \gcd\big(\sum_{a=1}^{N} a^{k},\, N\big)$ for semiprime, squarefree,
and odd-prime-power moduli. The description is exact: it determines every value,
the least period (the Carmichael function $\lambda(N)$), the exact first
nontrivial index $\min(p-1,q-1) < \sqrt{N}$, the exact count of informative
exponents per period, and the exact class of moduli on which the natural
exponent $k = N-1$ is uninformative (the Carmichael numbers). Along the way we
correct a false factor-recovery formula and supply the identity that replaces
it.

As a factoring procedure the method costs $O(N^{3/2})$ and is beaten by trial
division. As mathematics, it exhibits an integer sequence in which the
factorization of $N$ is fully and explicitly encoded, twice over — in its values
and in its period — and thereby isolates period-finding as the sole locus of
difficulty.
