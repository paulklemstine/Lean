# The Prime That Wasn't Supposed to Be There

*How a single fraction, $2601/3136$, demolished a beautiful conjecture about elliptic curves — and revealed what the arithmetic was really counting all along.*

---

## A conjecture worth wanting to be true

Some conjectures are believed because the evidence is overwhelming. Others are believed because they would be so *useful*. This is a story about the second kind.

Start with one of the oldest families of curves in number theory, studied by Louis Mordell a century ago:

$$E_N : \quad y^2 = x^3 + N.$$

Pick an integer $N$ and you get a curve. Points on it with whole-number coordinates are rare and precious — Mordell proved there are only finitely many for each $N$ — but they do exist. For $N = 55$, for instance, the point $(9, 28)$ works: $28^2 = 784$ and $9^3 + 55 = 729 + 55 = 784$.

Now here is the magic of elliptic curves. The points on such a curve form a *group*: you can add two points and get a third. The recipe is geometric. To add $P$ and $Q$, draw the line through them; it meets the curve in exactly one further point, and you reflect that point across the $x$-axis. To add a point to itself — to compute $2P$ — you use the tangent line at $P$ instead of a secant. Iterating gives you $2P, 3P, 4P, \dots$, an infinite orbit spilling out from a single starting point.

Whole-number coordinates almost never survive this process. Double the point $(9,28)$ on $y^2 = x^3 + 55$ and the tangent-line recipe hands you

$$x(2P) = \frac{9^4 - 8 \cdot 55 \cdot 9}{4(9^3 + 55)} = \frac{6561 - 3960}{3136} = \frac{2601}{3136}.$$

A fraction. And fractions have denominators, and denominators have prime factorisations, and *that* is where the conjecture lived.

Every elliptic curve carries a number called its **discriminant**, which measures where the curve degenerates. For the Mordell curve $E_N$ the discriminant is beautifully simple:

$$\Delta = -432\,N^2.$$

Since $432 = 2^4 \cdot 3^3$, the primes dividing $\Delta$ — the so-called **primes of bad reduction** — are exactly $2$, $3$, and the prime factors of $N$. Every other prime is a **good** prime: reduce the curve modulo it and you still get a perfectly healthy elliptic curve over a finite field.

The conjecture, in the folklore, said this:

> **The "only bad primes" conjecture.** When you double (or triple, or $n$-tuple) an integral point on $E_N$, the denominators that appear are divisible only by the bad primes: $2$, $3$, and the prime factors of $N$.

Read that once more with a cryptographer's eyes. Suppose $N = pq$ is a product of two large unknown primes — an RSA-style modulus. If the conjecture were true, then a single doubling of an integral point would produce a denominator whose prime factors are drawn from $\{2, 3, p, q\}$. Strip off the powers of $2$ and $3$, and the factorisation of $N$ falls into your lap.

That is the dream. And it is wrong.

## The fraction that kills it

Look again at the denominator of $x(2P)$ for $N = 55 = 5 \cdot 11$:

$$3136 = 2^6 \cdot 7^2.$$

There is a $7$ in there. And $7$ is not $2$, not $3$, not $5$, not $11$. Is $7$ a bad prime for $E_{55}$? The discriminant is $\Delta = -432 \cdot 55^2 = -1306800$, and $-1306800$ leaves remainder $2$ on division by $7$. So no: $7$ is a prime of *good* reduction. It is a prime at which absolutely nothing goes wrong with the curve. And yet there it sits, squared, in the denominator.

One fraction, two dozen characters wide, and the conjecture is finished.

You might hope this is a freak accident of a small example. It is not. Here is a second one, and this one was *built* rather than found. Note the algebraic identity $25m^2 - 1 = (5m-1)(5m+1)$: it manufactures numbers that factor for free. Take $m = 6$: then $N = 899 = 29 \cdot 31$, a product of twin primes, and the curve $y^2 = x^3 + 899$ has the obvious integral point $(1, 30)$, since $30^2 = 900 = 1 + 899$. Doubling gives

$$x(2P) = -\frac{799}{400}, \qquad 400 = 2^4 \cdot 5^2.$$

There is a $5$ — good, extraneous, uninvited, and once again squared.

Notice the pattern in the two examples: $28 = 2^2 \cdot 7$ contains a $7$; $30 = 2 \cdot 3 \cdot 5$ contains a $5$. The rogue primes were sitting in the $y$-coordinate of the starting point the whole time. That is the clue.

## What denominators are actually counting

Here is the theorem that explains everything.

> **Mechanism Theorem.** Let $(x,y)$ be a point with whole-number coordinates on $y^2 = x^3+N$, with $y \neq 0$, and let $\ell$ be any prime of good reduction — precisely, any prime not dividing $6N$. Then
> $$\ell \text{ divides the denominator of } x(2P) \quad\Longleftrightarrow\quad \ell \text{ divides } y.$$

Why? Substitute the curve equation into the doubling formula. Since $x^3 + N = y^2$, the formula $x(2P) = (x^4 - 8Nx)\big/\big(4(x^3+N)\big)$ becomes

$$x(2P) = \frac{x^4 - 8Nx}{4y^2}.$$

The denominator, before any cancellation, is $4y^2$. So the only primes that *could* appear are $2$ and the primes dividing $y$. The question is whether they cancel against the numerator. And they do not: if $\ell$ divides both $y$ and $x^4 - 8Nx = x(x^3-8N)$, then from $y^2 = x^3+N$ we get $x^3 \equiv -N$, so $x^3 - 8N \equiv -9N$; and $\ell$ can divide neither $x$ (that would force $\ell \mid N$) nor $9N$ (that would force $\ell \mid 3$ or $\ell \mid N$). Contradiction. No cancellation. The prime survives.

The argument is three lines long, and it says the conjecture was looking at the wrong object entirely. The denominator has *nothing to do with the discriminant*. It is a fingerprint of the **point**.

There is an even more revealing way to say this. The statement "$\ell$ divides $y$" has a geometric meaning. Reduce everything modulo $\ell$: the curve becomes a curve over the finite field $\mathbb{F}_\ell$, and $P$ becomes a point $\bar P$ on it, living in a finite group. On these curves, negating a point flips the sign of $y$. So $\bar y = 0$ says exactly $\bar P = -\bar P$, that is:

$$2\bar P = O.$$

The reduced point is **torsion**: doubling it kills it. So the Mechanism Theorem really says:

> $\ell$ appears in the denominator of $x(2P)$ **precisely when the reduced point $\bar P$ has order dividing 2 modulo $\ell$**.

Now the conjecture's error is laid bare. Bad primes are places where *the curve* misbehaves. Denominator primes are places where *the point* is torsion. Those are two completely different conditions, and there is no reason on earth for them to agree. A good prime $\ell$ is perfectly entitled to have $\bar P$ be a point of order $2$ in the group $E_N(\mathbb{F}_\ell)$ — and when it does, the doubled point falls into the "point at infinity" of the reduction, which is exactly what a denominator divisible by $\ell$ records.

## Not an accident: an inexhaustible supply

Once you know the mechanism, you stop hunting for counterexamples and start manufacturing them.

Want the prime $7$ to appear? Then you want an integral point whose $y$-coordinate is divisible by $7$, on a curve where $7$ is good. Here is a recipe that works for *every* prime:

> **Theorem (no prime is excluded).** Let $\ell \geq 5$ be any prime and $m \geq 1$ any integer. Set $N = \ell^2 m^2 - 1$. Then $(1, \ell m)$ is a whole-number point on $y^2 = x^3 + N$, the prime $\ell$ is a prime of good reduction, and $\ell$ divides the denominator of $x(2P)$.

The verification is immediate: $(\ell m)^2 = 1 + N$ puts the point on the curve; if $\ell$ divided $6N = 6(\ell^2m^2-1)$ it would have to divide $6$, which it cannot; and $\ell$ obviously divides $y = \ell m$. So $\ell$ is extraneous. Every prime from $5$ upward is a counterexample waiting for its curve.

Greedier still: take *several* primes at once. Let $S = \{5, 7, 11, 13\}$, multiply them to get $K = 5005$, and set $N = K^2 - 1 = 25050024$ with the point $(1, 5005)$. Then

$$\text{denominator of } x(2P) = 2^2 \cdot 5^2 \cdot 7^2 \cdot 11^2 \cdot 13^2,$$

with four extraneous good primes in a single fraction. Choose $S$ as large as you like: the count is unbounded. And since the family $N = 25m^2-1$ gives a fresh failure for every $m$, there are infinitely many $N$ for which the conjecture breaks.

## What the true statement looks like

A dead conjecture should be replaced, not just buried. The correct statement is embarrassingly close to the false one — it just names the point instead of the curve:

> **Theorem (the repaired statement).** For any whole-number point $(x,y)$ on $y^2 = x^3+N$, the denominator of $x(2P)$ divides $4y^2$. In particular, every prime dividing that denominator divides $2y$.

And we can be perfectly precise about *how much* of each prime appears:

> **Theorem (exact exponent).** For a good prime $\ell$, the exponent of $\ell$ in the denominator of $x(2P)$ is exactly $2\,v_\ell(y)$, twice the exponent of $\ell$ in $y$.

Check it against our example: $y = 28 = 2^2 \cdot 7$, so $7$ appears in $y$ to the first power, and $7^2$ appears in $3136$. Exactly as promised.

## Triple instead of double, and the primes all change

If doubling is governed by $y$, what governs tripling? The answer comes from the classical **division polynomials**, a sequence $\psi_1, \psi_2, \psi_3, \dots$ attached to the curve whose vanishing at a point detects torsion. For $E_N$ the first few are

$$\psi_2 = 2y, \qquad \psi_3 = 3x^4 + 12Nx.$$

And the story repeats verbatim, with $\psi_3$ in the starring role: for a good prime $\ell$, $\ell$ divides the denominator of $x(3P)$ exactly when $\ell$ divides $\psi_3(P)$ — which happens exactly when the reduced point $\bar P$ has order dividing $3$ modulo $\ell$. (The underlying fact: on $y^2 = x^3+N$, a point satisfies $3P = O$ if and only if $x^4 + 4Nx = 0$.)

Now watch what this does to our counterexample. For $N = 55$ and $P = (9,28)$,

$$\psi_3(P) = 3\cdot 9^4 + 12\cdot 55\cdot 9 = 25623 = 3^3 \cdot 13 \cdot 73,$$

and, sure enough,

$$x(3P) = -\frac{2302089191}{656538129}, \qquad 656538129 = 3^6 \cdot 13^2 \cdot 73^2 = \psi_3(P)^2.$$

The denominator is *literally the square of the division polynomial value*. Two brand-new good primes, $13$ and $73$, have appeared. And the old intruder, $7$, is gone — it does not divide $\operatorname{den} x(3P)$ at all.

That is the death blow to any repair that tries to salvage a fixed list of allowed primes. The extraneous primes are not a set attached to $N$; they *move with $n$*, tracking the arithmetic of the point through the division polynomials.

## Doubling again and again: frozen and marching

What happens if you keep doubling — computing $x(4P)$, $x(8P)$, and on up the tower? Two sharply opposed behaviours emerge, and the contrast is the punchline of the whole story.

> **Persistence Theorem.** Let $\ell$ be any odd prime dividing the denominator of some $x$-coordinate along the way. Then doubling changes that denominator's $\ell$-exponent *not at all*. Once in, always in, at exactly the same power, forever.

> **Dichotomy at 2.** By contrast, if $2$ divides the denominator, then each doubling adds exactly $2$ to its exponent — linear, relentless growth.

The proofs are a one-line valuation count. Writing $v = v_\ell(x)$ for a negative valuation, the numerator $x^4 - 8Nx$ has valuation $4v$ and the denominator $4(x^3+N)$ has valuation $v_\ell(4) + 3v$. For an odd prime $v_\ell(4) = 0$ and the two cancel down to $4v - 3v = v$: unchanged. For $\ell = 2$, $v_2(4) = 2$, and you get $v - 2$ instead: the denominator gains a factor $4$ every single time.

Let us watch this happen. For $N = 55$, $P = (9,28)$:

| level | denominator of the $x$-coordinate | power of $7$ | power of $2$ |
|---|---|---|---|
| $2P$ | $2^6 \cdot 7^2$ | $2$ | $6$ |
| $4P$ | $2^8 \cdot 7^2 \cdot 827^2 \cdot 1583^2$ | $2$ | $8$ |

The intruding prime $7$ is frozen at exponent $2$, exactly as predicted. The bad prime $2$ has climbed from $6$ to $8$, exactly $+2$, exactly as predicted. And two enormous new good primes, $827$ and $1583$, have joined the party — neither of them anywhere near the divisors of $\Delta = -432 \cdot 55^2$.

So the conjecture is not merely false but *inverted*: the primes it forbids are the stable, permanent ones, while the prime it most confidently permits, $2$, is the one that will not sit still.

## So can you factor $N$ this way?

No — and now we can say precisely why not, rather than merely observing that it does not work.

We surveyed semiprimes $N = pq$ with small factors, taking every whole-number point with $|x| \le 200$ and inspecting the denominators of both $x(2P)$ and $x(3P)$. Of the eleven semiprimes tried, eight have such a point. Among those eight:

* the "only bad primes" property survived in **zero** cases;
* an extraneous good prime appeared in **all eight**;
* the smaller factor $p$ turned up in only two of the eight;
* the larger factor $q$ turned up in **none**.

For $N = 91 = 7 \cdot 13$ the primes appearing are $\{2, 3, 337\}$ — an intruder larger than $N$ itself, and not a whisper of $7$ or $13$. For $N = 15 = 3 \cdot 5$ the collection is $\{2, 3, 61, 109, 569, 1295089\}$.

The reason is structural. Up to the harmless primes $2$, $3$ and the divisors of $N$, the denominator of $x(nP)$ *is* the square of $\psi_n(P)$. That is an integer determined by $N$ and by the chosen point, and factoring it is exactly as hard as factoring any other integer of its size. It is not a hidden window onto $p$ and $q$; it is just another big number.

Lenstra's celebrated elliptic curve factorisation method really does extract factors from elliptic curves, but by a different door: it computes with a curve *modulo the composite $N$* and watches for an inversion to fail, which reveals a factor through a greatest common divisor. The asymmetry it exploits lies in the differing sizes of the groups $E(\mathbb{F}_p)$ and $E(\mathbb{F}_q)$, not in the denominators of rational multiples. Our results say the denominator route was never a route at all.

## The moral

Mathematics is full of quantities that look like they should measure the same thing. Bad primes measure where a curve degenerates. Denominator primes measure where a point falls into the void at infinity after reduction. Both feel like "places where the arithmetic goes wrong," and that shared feeling was enough to sustain a conjecture that a single doubling of a single point refutes.

The corrected picture is arguably more beautiful than the conjecture it replaces. The denominators are not noise and they are not a factoring oracle: they are a precise ledger of when a rational point becomes torsion modulo each prime. The $n$-th division polynomial evaluated at $P$ *is* that ledger, and squaring it gives the denominator on the nose. Good primes are welcome in it; bad primes are almost beside the point.

And it all fits in one fraction. $2601/3136$. Look at the $7$.
