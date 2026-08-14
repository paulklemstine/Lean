# The Ghost in the Modulus

### What the greatest common divisor knows about factoring — and why knowing is not the same as getting

Take a number that is the product of two large primes, say $N = pq$. This is the object on which a great deal of the world's secrecy rests: the primes are the secret, the product is public, and the security of the arrangement is the belief that nobody can walk backwards from $N$ to $p$ and $q$.

Now do something almost childishly simple. Walk through every residue $x = 0, 1, 2, \dots, N-1$ and compute $\gcd(N, x)$, the greatest common divisor of $x$ with the modulus. Almost every answer is $1$ — the residues coprime to $N$ vastly outnumber the rest. Occasionally you hit a multiple of $p$ and the answer is $p$. Occasionally you hit a multiple of $q$ and the answer is $q$. Exactly once, at $x = 0$, the answer is $N$ itself.

Then add all those answers up:

$$M_1(N) \;=\; \sum_{x=0}^{N-1} \gcd(N, x).$$

This is a completely public computation: nothing in it uses a factor of $N$. And yet the answer is

$$M_1(N) \;=\; 4N - 2s + 1, \qquad s = p + q.$$

Read that again. The sum of a purely mechanical scan of gcd values is an exact linear expression in the one quantity you are not supposed to know: the *trace* $s = p+q$ of the hidden prime pair. Invert it — $2s = 4N + 1 - M_1(N)$ — and you have $p+q$. With $p+q$ and $pq$ in hand, the primes are the two roots of $t^2 - st + N$, and the discriminant $s^2 - 4N = (q-p)^2$ is even a perfect square, so the extraction is exact integer arithmetic. The scan factors the modulus.

So why is RSA still standing?

Because of the walk. The formula is exact, the inversion is trivial, and the price is $N$ greatest-common-divisor computations — one for every residue below the modulus. For a $2048$-bit modulus that is more steps than there are atoms in the observable universe, raised to a power. The secret is not hidden behind a wall. It is written in plain sight, in a ledger too long to read.

This article is about what happens when you try to read the ledger faster: by sampling it, by weighting it, by taking higher powers, by any of the natural moves an analyst would make. The answer is a clean and slightly surprising piece of arithmetic. Every such move produces a quantity that is *exactly* computable — and *exactly* as expensive. The family of statistics closes on itself.

---

## The whole family, at once

Instead of adding the gcd values, add their $k$-th powers:

$$M_k(N) \;=\; \sum_{x=0}^{N-1} \gcd(N,x)^k .$$

Raising to a power looks like a genuinely new experiment: it re-weights the rare large gcds against the common $1$s, and one might hope that some exponent $k$ shakes loose a piece of information the plain sum missed — the difference $q - p$, say, rather than the sum.

It does not. Group the residues by their gcd: exactly $\varphi(N/d)$ of them have gcd equal to $d$, where $\varphi$ is Euler's totient function counting integers below a bound and coprime to it. That immediately gives the divisor form

$$M_k(n) \;=\; \sum_{d \mid n} d^k \, \varphi(n/d),$$

valid for every modulus $n$. For a semiprime the divisors are just $1, p, q, pq$, and the sum has four terms:

$$M_k(pq) \;=\; (p-1)(q-1) \;+\; p^k(q-1) \;+\; q^k(p-1) \;+\; (pq)^k .$$

Everything here is symmetric in $p$ and $q$. And a symmetric expression in two numbers is always expressible in their sum and product. Concretely, let $P_j = p^j + q^j$ be the power sums. Newton's recursion computes them from the public data alone:

$$P_0 = 2, \quad P_1 = s, \quad P_{j+2} = s\,P_{j+1} - N\,P_j,$$

and the four-term formula collapses to a single clean identity:

$$\boxed{\,M_k(N) \;=\; N^k \;+\; N\,P_{k-1} \;-\; P_k \;+\; N \;-\; s \;+\; 1\,}$$

Every gcd moment of a semiprime is one fixed polynomial evaluated at $(N, s)$. The first four read:

$$M_1 = 4N - 2s + 1,$$
$$M_2 = N^2 + 3N + 1 + (N-1)s - s^2,$$
$$M_3 = N^3 - 2N^2 + N s^2 + 3Ns + N - s^3 - s + 1,$$
$$M_4 = N^4 - 3N^2 s - 2N^2 + N s^3 + 4N s^2 + N - s^4 - s + 1.$$

This is the first of the walls, and the most conceptual one. Call it the **symmetry wall**. The individual primes never appear in any moment; only $N$ and $s$ do. Two hidden pairs with the same product and the same sum produce identical moments at every exponent — which, since a pair is determined by its sum and product, is a tautology in disguise, but a revealing one. It says that the *ceiling* of what this family can carry is exactly one hidden number: the trace.

And the family is *closed*. Because $M_1$ already determines $s$, and every $M_k$ is a polynomial in $N$ and $s$, every higher moment is an explicit function of the modulus and the first moment. Compute $M_1$ and you can write down $M_{17}$ without touching the modulus again. Compute $M_{17}$ the hard way and you learn nothing you did not already have. There is one secret in the family, and the cheapest member already tells it.

---

## The cost hierarchy: higher powers are strictly worse

If you cannot get new information from higher moments, could you at least get the old information *faster*? The natural idea is statistical. Rather than scanning all $N$ residues, sample a few at random and estimate the average $M_k(N)/N$ from the sample mean. Chebyshev's inequality then converts the variance of the sampled quantity into a sample count.

Here the arithmetic is brutally clear. Let $U$ be a uniformly random residue. The variance of $\gcd(N,U)^k$ satisfies

$$N^{2k-1} - 16\,N^{2k-2} \;\le\; \operatorname{Var}\big(\gcd(N,U)^k\big) \;\le\; 4\,N^{2k-1},$$

so it is of exact order $N^{2k-1}$. The reason is a single term. The residue $x=0$ contributes $N^k$ to the sum, so it contributes $N^{2k}$ to the second moment and, after dividing by $N$, a term of size $N^{2k-1}$ to the variance. The distribution of $\gcd(N,U)^k$ is a lottery: with probability $1 - (p+q-1)/N$ it pays $1$, with tiny probability it pays $p^k$ or $q^k$, and with probability exactly $1/N$ it pays the jackpot $N^k$. The mean is dominated by an event you will essentially never see.

The consequence is a genuine hierarchy — not of information, but of price. For every modulus above $32$ one has the clean comparison

$$\frac{N^2}{8}\,\operatorname{Var}\big(\gcd(N,U)\big) \;\le\; \operatorname{Var}\big(\gcd(N,U)^2\big),$$

so the second-moment estimator is worse than the first by a factor growing like $N^2$, the third by $N^4$, and so on. The plain gcd sum is not merely the simplest member of the family; it is provably the cheapest, and the whole hierarchy of "more sophisticated" statistics runs in the wrong direction. Numerically the effect is stark: for $N = 943$, matching the accuracy the first moment reaches in $10^5$ samples takes about $10^{11}$ samples at $k=2$ and about $10^{17}$ at $k=3$.

Even the cheap end is not cheap. A single random probe finds a nontrivial gcd — that is, actually meets a multiple of $p$ or of $q$ — with probability exactly

$$\frac{p+q-1}{N},$$

because precisely $p + q - 1$ of the $N$ residues share a factor with $N$. (The count is exact: subtract the $\varphi(N) = (p-1)(q-1)$ coprime residues from $N$.) For balanced primes of $1024$ bits each, that is a probability around $2^{-1023}$. Blind probing does not find a factor, and the aggregate statistic that *does* encode the factors needs every one of the $N$ probes to be assembled.

---

## Under the hood: a completely split object

So far this is a story about semiprimes. The structure behind it is more elegant, and it explains why every road leads back to the same place.

The gcd moment is a *multiplicative* function of the modulus: it is the Dirichlet convolution of $n \mapsto n^k$ with Euler's totient, so $M_k(mn) = M_k(m)M_k(n)$ whenever $m$ and $n$ are coprime. At a prime it takes the value

$$M_k(p) = p^k + p - 1,$$

and consequently, for any squarefree modulus, it is an honest Euler product:

$$M_k(n) \;=\; \prod_{p \mid n} \big(p^k + p - 1\big).$$

The four-term semiprime formula was nothing but this product with two factors, multiplied out.

Once you see the moment as a product of *local factors* $L_k(a) = a^k + a - 1$, one contributed by each prime, a whole geometry appears. Write down every way of factoring $n$ into parts $a_1 a_2 \cdots a_r = n$ with each $a_i \ge 2$, and to each such factorisation attach the number it *predicts*:

$$E_k(a_1,\dots,a_r) \;=\; \prod_{i=1}^r \big(a_i^k + a_i - 1\big).$$

These factorisations form a lattice ordered by refinement — you can always split a part into two — and the predicted moment respects the order in a strict way. For any $u, v \ge 2$ and any $k \ge 1$,

$$(uv)^k + uv - 1 \;<\; (u^k + u - 1)(v^k + v - 1),$$

so **splitting a part always strictly increases the prediction**. Iterating this from both ends pins the whole lattice inside a bracket:

$$n^k + n - 1 \;\le\; M_k(n) \;\le\; \Pi_k(n) := \prod_{p^e \,\|\, n} \big(p^k + p - 1\big)^e .$$

Both ends are sharp, and both are characterised exactly. The left equality $M_k(n) = n^k + n - 1$ holds **if and only if $n$ is prime** — the gcd moment is a primality test in disguise. The right equality $M_k(n) = \Pi_k(n)$ holds **if and only if $n$ is squarefree**; at a square the shortfall is explicit,

$$\big(p^k+p-1\big)^2 - M_k(p^2) \;=\; (p-1)(p^k-1),$$

with a corresponding closed formula at every prime power. The bracket collapses to a single point precisely at the primes.

At the level of *predictions* rather than actual moments, both extremes are attained exactly once. The trivial factorisation $[\,n\,]$ is the unique minimiser: as soon as a factorisation has two parts, its prediction is strictly larger. The prime factorisation is the unique maximiser: one composite part already makes the prediction strictly smaller than $\Pi_k(n)$.

---

## Can the prediction be read backwards?

This lattice picture answers the sharpest form of the question. Suppose an adversary is handed the *value* $M_k(N)$ of some gcd moment and nothing else — no scan, no factors, a free oracle. Can they identify the factorisation? Equivalently: can two different factorisations of the same modulus predict the same number?

At $k = 2$ they can, and there is an exact law saying when. For two factorisations $ab = cd$ of the same modulus,

$$E_2(a,b) = E_2(c,d) \iff a+b = c+d \ \text{ or } \ (a+b) + (c+d) = ab - 1 .$$

The second alternative is the reflection $s \mapsto N - 1 - s$, and it is not a phantom: at $N = 28$ the factorisations $2 \times 14$ and $4 \times 7$ predict the same second moment ($1045$), and at $N = 36$ so do $2 \times 18$ and $3 \times 12$ ($1705$). Remarkably, **these two moduli are the only ones in the entire number line** where a genuine two-part second-moment collision occurs. Above $36$ the collision equation has no solutions at all, and a finite check disposes of what is left.

At $k = 3$ and beyond, the ambiguity vanishes completely. The third and higher predictions are strictly monotone in the *spread* of a factorisation: if $ab = cd$ with $a < c \le d < b$ — that is, if $(a,b)$ is the more lopsided pair — then $E_k(c,d) < E_k(a,b)$ for every $k \ge 3$. The proof is an inequality with a small, sharp exceptional set: seven quadruples, namely $(2,6;3,4)$, $(2,8;4,4)$, $(2,9;3,6)$, $(2,10;4,5)$, $(2,12;3,8)$, $(2,12;4,6)$ and $(2,15;3,10)$, escape the main estimate and have to be checked by hand. They all obey the conclusion.

Combining the three regimes gives the clean statement: **for every $k \ge 1$, the observed $k$-th gcd moment of a semiprime is matched by exactly one candidate factorisation — the true one.** The trace argument handles $k=1$, the collision classification handles $k=2$ (where the two exceptional moduli $28$ and $36$ are not semiprime), and spread monotonicity handles $k \ge 3$.

The same machinery pushes past semiprimes. Since collisions can never involve an extremal factorisation, and since a factorisation into parts $\ge 2$ has at most $\Omega(n)$ parts (the number of primes of $n$ counted with multiplicity), with equality exactly when all parts are prime, one obtains: **if $\Omega(n) \le 2$ then the predicted moment determines the factorisation up to order, at every $k \ge 1$**; and **if $\Omega(n) \le 3$ then the same holds at $k = 1$ and at every $k \ge 3$**. Both bounds are sharp in the smallest possible way. The collision $28 = 2 \cdot 14 = 4 \cdot 7$ has $\Omega = 3$ and lives at $k = 2$. The smallest first-moment collision is $234 = 2 \cdot 9 \cdot 13 = 3 \cdot 3 \cdot 26$, and it has $\Omega = 4$.

---

## What the ledger teaches

Put the pieces together and a rather complete picture emerges of one natural avenue toward factoring, and of exactly why it is closed.

The gcd moments are as informative as a symmetric statistic of a semiprime can possibly be: they carry the trace $p+q$, and the trace is enough to factor. There is no ambiguity to complain about, no phantom root to worry about, and no exponent at which the signal degrades. In this sense the experiment *succeeds*.

And it fails, four times over, for four independent reasons. It fails by **symmetry**, because the hidden primes enter only through $N$ and $s$, so the trace is a ceiling and not a stepping stone: the family cannot carry anything finer. It fails by **aggregation**, because the value is a sum over all $N$ residues and no shortcut assembles it — sampling is defeated by a variance of order $N^{2k-1}$, dominated by a single jackpot residue. It fails by **circularity**, because the fast route to the value, the divisor form $\sum_{d \mid n} d^k \varphi(n/d)$, requires the factorisation you were trying to find. And it fails by being **already known**: the first moment $\sum_{d \mid n} d\,\varphi(n/d)$ is the classical gcd-sum function, and the whole family is a specialisation of standard arithmetic-function machinery.

There is something bracing about this. Cryptography is often described as hiding a secret. What the gcd ledger shows is that the secret can be entirely unhidden — expressible by an exact, elementary, public formula in a quantity anyone may compute — and still be perfectly safe, because the only known way to compute that quantity is to do as much work as breaking the problem outright. The trace $s = p + q$ is the *least hidden* thing about a semiprime. It is also, as the moment family proves, the *most* that any symmetric aggregate of this kind will ever hand you.

The ghost is in the modulus. You simply cannot afford to look at it.
