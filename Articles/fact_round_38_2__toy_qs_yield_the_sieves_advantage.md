# Where the Quadratic Sieve Actually Wins

*A toy factoring machine, measured closely, shows that the sieve's speed comes from one clean trick, and that its supply of useful numbers is thinner than the textbook estimate.*

---

## A number, and two ways to break it

Take the number $N = 103\,764\,863$. It is the product of two primes, $9127 \times 11369$, but suppose you didn't know that. How would you find out?

Since the early 1980s, a standard answer has been the **quadratic sieve**, invented by Carl Pomerance. For numbers of up to roughly a hundred decimal digits it was the fastest general-purpose factoring method, and it is still the usual first example of the "collect relations, then do linear algebra" approach that also drives the number field sieve, the method that sets factoring records and bounds the key sizes used in RSA.

The idea is easy to state. Find several integers $x_1, x_2, \dots$ whose values $x_i^2 - N$ split completely into small primes. Such numbers are called *smooth*. Then choose a subset whose product is a perfect square. That gives two different squares that agree modulo $N$, and from them a factor of $N$ follows with one greatest-common-divisor computation.

This article is about the first step: actually finding those smooth numbers. We built a toy version of the sieve, instrumented it, and checked every figure it reported against a slow brute-force computation. Two questions came out of that work. Both have clean answers, and one of them corrects a model that is often used.

**Question 1.** The sieve beats the obvious method, which is to trial-divide every candidate by every small prime. *Why*, exactly, and by how much? Does the advantage grow as numbers get bigger, or is it a fixed factor?

**Question 2.** How many smooth numbers should we expect to find? The standard estimate uses Dickman's function $\rho(u)$, the classical density of smooth integers. Is that estimate right for the numbers $x^2 - N$?

---

## Part I: The sieve is a filter, not a factoring engine

### The obvious method

Fix a *smoothness bound* $B$, say $B = 60$. To test whether a value $v = x^2 - N$ is $B$-smooth, divide it by $2, 3, 5, 7, \dots$ up to $B$ and check whether $1$ is left over. That costs about $\pi(B)$ divisions per value, where $\pi(B)$ is the number of primes up to $B$. In our larger experiments this came to roughly a hundred divisions for every candidate, and nearly all of that work is wasted, because nearly all candidates are not smooth.

### The sieve's trick

The sieve turns the question around. It does not ask each number which primes divide it. It asks each prime which numbers it divides. The answer has a lot of structure:

> If $p$ divides $x^2 - N$, then $p$ also divides $(x + p)^2 - N$, $(x + 2p)^2 - N$, and so on.

The values of $x$ that a prime $p$ hits form a few arithmetic progressions, which we call *sieve lines*. To process $p$, find where the lines start and step along them, adding $\log p$ to a running total for each value you land on. When every prime has been processed, a value $v$ whose running total equals $\log v$ is a candidate for smoothness. These candidates are the *survivors*. Only the survivors are ever trial-divided.

The measurement was simple to describe. Across six test settings, with $N$ up to $2^{32}$, the sieve beat trial division by factors between $13.7\times$ and $20.5\times$. When we divided the advantage by the size of the factor base, the ratio stayed flat, between $0.12$ and $0.22$, with no sign of growing as $N$ grew. The mechanism showed up directly in the counts: about **a hundred divisions per value** became about **two logarithm additions per value**, plus trial division of the few survivors.

So the sieve's whole advantage is a constant: the cost of filtering out survivors. It does not become more efficient at larger sizes. It replaces an expensive test with a cheap one and pays the expensive price only for the rare numbers worth testing.

### Why the bookkeeping is honest

A filter is only useful if it is *exact*. If it rejected genuine smooth numbers, part of the "speed-up" would just be lost relations. If it let through false positives, the survivor divisions would grow. So we needed to know exactly which numbers the log-threshold test accepts.

The answer is a clean theorem. Suppose that for each prime $p$ in a set $S$ you sieve the lines for $p, p^2, \dots, p^K$ up to some height $K$. Then the total collected at $v$ is the logarithm of the part of $v$ that the sieve "sees":
$$\sum_{p \in S} \min\bigl(v_p(v),\,K\bigr)\,\log p,$$
where $v_p(v)$ is the exponent of $p$ in $v$. This equals $\log v$ **if and only if** $v$ is built only from primes in $S$ and no prime appears to a power above $K$. Once $K \ge \log_2 v$ the second condition holds automatically, so the survivors are exactly the $B$-smooth numbers, the same set trial division finds. Nothing is lost and nothing extra gets in.

### The bug that took a brute-force check to catch

This theorem also explains the most instructive bug we found. An early version of the toy sieve marked only the lines modulo $p$, not those modulo $p^2$, $p^3$, and so on. That is height $K = 1$. The theorem says what such a sieve accepts: **exactly the squarefree smooth numbers.** Every smooth number with a repeated prime factor is silently thrown away, and its log total falls short by a strictly positive amount.

How much does that cost? It depends on the threshold, but under an exact threshold the losses were large: between 54% and 91% of all relations in our test settings. The striking part is *how* the bug was found. The sieve's built-in self-check predicted its yield using the same simplification the code made, so the check and the code agreed with each other and both were wrong. Only an independent brute-force recount of the same range exposed the gap. (After the fix, a brute-force subrange matched the sieve on all 338 of 338 relations, with an advantage of $14.07\times$ against $15.29\times$ over the full window.) The lesson applies well beyond factoring: **a check that shares the code's assumptions cannot catch errors in those assumptions.**

### The lines modulo prime powers

To fix the bug you need the lines modulo $p^k$, so you need to know how many there are. Here classical number theory gives a tidy answer.

Let $p$ be an odd prime that does not divide $N$.

* If $N$ is a **quadratic residue** modulo $p$, meaning $N \equiv r^2 \pmod p$ for some $r$, then the congruence $x^2 \equiv N \pmod{p^k}$ has **exactly two** solutions for every $k \ge 1$. Each root modulo $p$ lifts uniquely, one power at a time. This is Hensel's lemma: from a root $x$ modulo $p^k$, the corrected value $x - (x^2 - N)/(2x)$ is a root modulo $p^{k+1}$. Two roots of the same congruence always agree up to sign, so there are never more than two.
* If $N$ is a **non-residue** modulo $p$, there are **no** solutions at any level. The prime $p$ never divides any value $x^2 - N$.

The prime $2$ behaves differently. Every odd square is $\equiv 1 \pmod 8$, so for odd $N$ the power of $2$ in $x^2 - N$ is limited by $N \bmod 8$. For our $N = 103\,764\,863 \equiv 7 \pmod 8$, no value $x^2 - N$ is ever divisible by $4$.

Counting hits along these lines gives the work bound directly. A window of $M$ consecutive integers contains at most $M/p^k + 1$ members of any residue class modulo $p^k$, so the total number of log additions is at most
$$\sum_{p \in S}\ \sum_{k=1}^{K} 2\left(\frac{M}{p^k} + 1\right).$$
Per value this is about $2\sum 1/p^k$, a small number. Trial division costs $|S|$ per value, and $|S|$ grows with $B$. That is the "hundred divisions become two additions" result, stated as a precise inequality.

---

## Part II: The relation pool is thinner than random

### The model that overshoots

For the second question, the textbook approach treats $v = x^2 - N$ as a *random* integer of its size. The probability that a random integer near $v$ is $B$-smooth is about $\rho(u)$, where
$$u = \frac{\ln v}{\ln B}$$
and $\rho$ is Dickman's function, defined by $\rho(u) = 1$ for $u \le 1$ and $u\,\rho'(u) = -\rho(u-1)$ after that. An earlier round of this project fitted the model $0.90\,\rho(u)$ and found it accurate in the range it tested ($u$ between $2$ and $3$, values up to $2^{23}$).

At larger sizes the model failed. At a median $u$ near $3$ it overpredicted the actual yield by about $1.55\times$, and all six test settings fell outside the predicted band.

### The reason is the quadratic-residue restriction

The explanation is the non-residue fact above. A prime $p$ can divide $x^2 - N$ only if $N$ is a square modulo $p$. In Legendre-symbol notation, $(N \mid p) = +1$ is **forced**. That cuts out about half of all primes. For our toy $N$, of the 17 primes up to 60 only 10 can ever appear:
$$\{2, 11, 17, 19, 23, 31, 37, 43, 47, 59\}.$$
The primes $3, 5, 7, 13, 29, 41, 53$ will never divide any value, however long you sieve.

So the numbers $x^2 - N$ are not "random integers" as far as smoothness goes. They are random among integers made from a **restricted pool**, the primes that are quadratic residues for $N$, with each such prime hitting twice as often as it would at random because there are two sieve lines per prime power.

A rough way to measure the effect is to say that with only half the primes available, the smoothness bound behaves like $B/2$ instead of $B$. Then the effective $u$ is
$$u_{\text{eff}} = \frac{\ln v}{\ln(B/2)} = u \cdot \frac{\ln B}{\ln B - \ln 2},$$
which is always strictly larger than $u$. Because $\rho$ falls steeply, a modest increase in $u$ produces a large drop in yield. In our settings this heuristic predicted yield ratios between $0.44$ and $0.52$ relative to the plain model. The observed ratios were between $0.54$ and $0.76$, and across settings the predictions and observations had a correlation of $0.72$. The direction and the trend match. The size is somewhat overcorrected, which is expected: the doubled hit rate per admissible prime partly makes up for the missing primes, and the crude "$B/2$" replacement ignores that.

The overall picture is clear. The earlier model's fitted factor of $0.90$ held where it was measured. Beyond that range, the right reference population is *integers built from quadratic-residue primes*, not all integers.

---

## Part III: From relations to a factor

The last step turns relations into a factor. It rests on a few small facts that are pleasant to see together.

**Relations multiply to a congruence of squares.** For any set $T$ of abscissae $x_i$,
$$\Bigl(\prod_{i\in T} x_i\Bigr)^{2} \equiv \prod_{i\in T}(x_i^2 - N) \pmod N,$$
because each factor $x_i^2 - N$ is congruent to $x_i^2$.

**Enough relations force a square.** Record each smooth value by the *parities* of its prime exponents, as a vector over the two-element field $\mathbb F_2$. If you have more relations than admissible primes, these vectors must be linearly dependent, and a dependency is exactly a subset whose product is a perfect square $Y^2$.

**Squares that differ give a factor.** If $X^2 \equiv Y^2 \pmod N$ but $X \not\equiv \pm Y$, then $N$ divides $(X-Y)(X+Y)$ without dividing either factor, so $\gcd(X - Y, N)$ is a proper divisor of $N$.

**The coin flip.** When $N = pq$ with $p$ and $q$ distinct odd primes, the Chinese Remainder Theorem shows that a unit square has *exactly four* square roots modulo $N$: you can choose the sign independently modulo $p$ and modulo $q$. Two of the four are the trivial $\pm Y$. The other two are useful. So, heuristically, each dependency factors $N$ with probability one half.

Our toy run showed both outcomes. The first dependency it found used three relations,
$$x = 10342,\ 10749,\ 18185,$$
and the product of their values is $92\,360\,250\,334^2$. In that case $X \equiv Y \pmod N$, which is one of the two useless roots. The next dependency used four relations:

| $x$ | $x^2 - N$ |
|---|---|
| $10248$ | $19^2 \cdot 59^2$ |
| $10342$ | $11^2 \cdot 23 \cdot 31 \cdot 37$ |
| $10749$ | $2 \cdot 11 \cdot 17 \cdot 23 \cdot 37^2$ |
| $18185$ | $2 \cdot 11 \cdot 17 \cdot 23^2 \cdot 31 \cdot 37$ |

Every exponent in the combined product is even, so the product is $Y^2$ with $Y = 103\,535\,840\,624\,414$. With $X = 10248 \cdot 10342 \cdot 10749 \cdot 18185$ the dependency is non-trivial, and
$$\gcd(X - Y,\ N) = 9127.$$
The factorization $103\,764\,863 = 9127 \times 11369$ follows.

(There is a small bonus hidden in the first row. $19^2 \cdot 59^2 = 1121^2$ is already a perfect square on its own, so $N = 10248^2 - 1121^2 = (10248-1121)(10248+1121)$. That is Pierre de Fermat's seventeenth-century difference-of-squares trick, showing up inside the modern machine because the two prime factors of this $N$ happen to be close together.)

Look at the table again: **every one of the four relations has a repeated prime factor.** A sieve with the first-power bug would have rejected all four. The fix that the brute-force check forced was not a minor accuracy tweak. Without it, this run would not have factored $N$.

---

## What we learned

1. **The sieve's advantage is a constant-factor survivor filter.** Cheap log additions along arithmetic progressions replace expensive trial division, and the threshold test is provably exact once prime powers are sieved. The advantage did not grow with scale in our measurements.
2. **Prime powers matter a great deal.** A sieve that marks only first powers accepts exactly the squarefree smooth values and can lose most of its relations.
3. **The relation pool is restricted by quadratic residues.** Only primes with $(N\mid p) = +1$ can appear, and that thins the supply of smooth values well below the plain Dickman estimate.
4. **Checks must be independent.** Two real bugs were caught only because a brute-force recount did not share the sieve's assumptions.

Some questions remain open. Is there an exact "half-density" Dickman law for the numbers $x^2 - N$, one that accounts both for the missing primes and for the doubled hit rate of the remaining ones? What fraction of smooth values $x^2 - N$ are not squarefree, as a function of $u$? The structural ingredients are now in place: the support is exactly the residue primes, and every prime power has exactly two sieve lines. The asymptotic analysis has not been done yet.
