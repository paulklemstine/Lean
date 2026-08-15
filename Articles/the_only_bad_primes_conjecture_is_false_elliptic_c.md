# The Primes That Shouldn't Be There

## A tempting conjecture about elliptic curves, a small counterexample, and a theorem that closes the door on an entire approach to factoring

### A curve, a point, and a sequence of fractions

Take the equation

$$E_N : \quad y^2 = x^3 + N,$$

where $N$ is a whole number. Curves of this shape are called *Mordell curves*, and they have been studied since the nineteenth century. What makes them — and elliptic curves generally — special is that their rational solutions form a *group*: given two rational points on the curve you can produce a third by drawing the line through them and taking the third intersection point, then reflecting across the $x$-axis. Add a point to itself using the tangent line instead of a chord, and you can *double* a point. Doing this repeatedly gives you a sequence

$$P, \; 2P, \; 3P, \; 4P, \; \dots$$

of rational points, and each of them has an $x$-coordinate which is a fraction in lowest terms.

Here is the phenomenon that this article is about. Start with $N = 55$ and the point $P = (9, 28)$, which really is on the curve: $28^2 = 784 = 9^3 + 55$. Now double it. The tangent-line formula for these curves gives a beautifully compact recipe,

$$x(2P) = \frac{x^4 - 8Nx}{4y^2},$$

so

$$x(2P) = \frac{9^4 - 8 \cdot 55 \cdot 9}{4(9^3 + 55)} = \frac{6561 - 3960}{3136} = \frac{2601}{3136}.$$

The numbers grow fast; keep going and they explode. The interesting object is not the size but the *arithmetic* of the denominators:

$$\operatorname{den} x(P) = 1, \quad \operatorname{den} x(2P) = 3136 = 2^6 \cdot 7^2, \quad \operatorname{den} x(3P) = 3^6 \cdot 13^2 \cdot 73^2,$$
$$\operatorname{den} x(4P) = 2^8 \cdot 7^2 \cdot 827^2 \cdot 1583^2, \quad \operatorname{den} x(5P) = 5^2 \cdot 1785401475301^2 .$$

Two things jump out. The denominators are always perfect squares — that is a general fact, not an accident. And a shifting cast of primes appears and disappears: $7$, then $13$ and $73$, then $827$ and $1583$, then a thirteen-digit monster.

### The conjecture: only bad primes should appear

Every elliptic curve has a *discriminant*, a single integer that records where the curve degenerates. For $E_N$ it is

$$\Delta = -432 N^2 .$$

A prime $\ell$ is called *bad* for $E_N$ if $\ell \mid \Delta$ — equivalently, if $\ell \in \{2, 3\} $ or $\ell \mid N$ — and *good* otherwise. Reducing the curve modulo a good prime leaves a perfectly respectable elliptic curve over the finite field with $\ell$ elements; modulo a bad prime the reduced curve acquires a singularity.

Now suppose $N = pq$ is a *semiprime*, the product of two large unknown primes — the situation in cryptography, where recovering $p$ and $q$ from $N$ is the hard problem underlying much of public-key encryption. The bad primes of $E_{pq}$ are exactly $2, 3, p, q$. The prime factors of $N$ are *built into the geometry of the curve*. That makes the following guess almost irresistible:

> **The "only bad primes" conjecture.** For $N = pq$ and a rational point $P$ on $E_N$, the denominators of $x(nP)$ are divisible only by the primes $2, 3, p, q$.

If it were true, it would be spectacular: compute one denominator, factor out the powers of $2$ and $3$, and what remains hands you $p$ and $q$. Factoring, solved.

The very first example above already kills it. The denominator $3136 = 2^6 \cdot 7^2$ contains the prime $7$, and $7$ does not divide $\Delta = -432 \cdot 55^2 = -1306800$. The prime $7$ is a prime of *good* reduction. It has no business being there, and there it is.

**Theorem (Refutation).** *On $E_{55} : y^2 = x^3 + 55$ with $P = (9,28)$, one has $x(2P) = 2601/3136$ with $3136 = 2^6 \cdot 7^2$. The prime $7$ divides the denominator and does not divide the discriminant. The "only bad primes" conjecture is false.*

One might hope this is a fluke of a small example. It is not. It is the tip of a mechanism.

### Why good primes must appear

The reason denominators contain primes at all is a piece of local arithmetic that deserves to be better known.

Write a rational point in its canonical form
$$x = \frac{a}{e^2}, \qquad y = \frac{b}{e^3}, \qquad \gcd(a,e) = \gcd(b,e) = 1 .$$
(That the denominators are a square and a cube of the *same* integer $e$ is forced by the curve equation; substituting gives $b^2 = a^3 + N e^6$.) A prime $\ell$ divides the denominator of $x$ exactly when $\ell \mid e$.

What does $\ell \mid e$ mean geometrically? Divide the curve equation through and look modulo $\ell$: as $e$ becomes divisible by $\ell$, the point runs off to infinity in the reduction — it collides with the identity element of the group.

**Theorem (The local law).** *Let $\ell \geq 5$ be a prime not dividing $N$. A rational point $P$ of $E_N$ has $\ell \mid \operatorname{den} x(P)$ if and only if $P$ reduces to the identity of the group $E_N(\mathbb{F}_\ell)$ of points modulo $\ell$. Consequently, for a fixed point $P$ with integral coordinates, $\ell$ divides $\operatorname{den} x(nP)$ precisely when $n$ is a multiple of the order of $P$ modulo $\ell$.*

Suddenly the mystery cast of primes has a script. Reduce $P = (9,28)$ modulo $7$: the group $E_{55}(\mathbb{F}_7)$ has $4$ elements and the reduction of $P$ has order $2$ — so $7$ must appear at $n = 2$, and again at $n = 4$, $6$, $8$, and so on. Modulo $13$ the order is $3$, so $13$ appears first at $n = 3$; modulo $73$ the order is also $3$; modulo $827$ and modulo $1583$ the order is $4$. Every single prime in the list above is explained, and the explanation involves *nothing* about the factorization of $N$. Reduction modulo a good prime is a condition of codimension one: as $n$ grows, the point $nP$ is asked to hit a single specified target in a group of size about $\ell$, and it succeeds for infinitely many $(\ell, n)$. Good primes are not exceptions to be explained away; they are the generic content of the denominator.

And there is no shortage of them. There is a two-parameter machine that produces violations as large as you like:

**Theorem (Unbounded violations).** *Let $\ell \geq 5$ be prime and $t \geq 1$. Put*
$$N(\ell,t) = 4\ell^2 t^2 - 1 = (2\ell t - 1)(2\ell t + 1), \qquad P = (1, \, 2\ell t) .$$
*Then $N(\ell,t)$ is odd, is a product of two factors both bigger than $1$, and grows without bound in $t$; the point $P$ lies on $E_{N(\ell,t)}$; the curve has good reduction at $\ell$; and $\ell$ divides $\operatorname{den} x(2P)$, while **no** prime factor of $N(\ell,t)$ divides it.*

The construction is transparent once seen. At the point $(1, y)$ with $y^2 = 1 + N$, the duplication formula collapses to
$$x(2P) = \frac{1 - 8N}{4(N+1)},$$
so the denominator divides $4(N+1)$ — and $N+1 = 4\ell^2t^2$ is manifestly divisible by $\ell$ and manifestly coprime to the odd number $N$. Choosing $t$ so that $2\ell t \pm 1$ are twin primes gives genuine semiprimes:

- $\ell = 5$, $t = 3$: $N = 899 = 29 \cdot 31$, $x(2P) = -799/400$, denominator $400 = 2^4 \cdot 5^2$;
- $\ell = 7$, $t = 3$: $N = 1763 = 41 \cdot 43$, $x(2P) = -1567/784$, denominator $784 = 2^4 \cdot 7^2$;
- $\ell = 11$, $t = 9$: $N = 39203 = 197 \cdot 199$, $x(2P) = -34847/17424$, denominator $17424 = 2^4 \cdot 3^2 \cdot 11^2$.

In each case the conjecture fails twice over: a good prime is present, and both of the primes it predicted are absent.

### The real surprise: the factors are not merely rare, they are forbidden

That last observation is the heart of the story. The conjecture guessed the wrong primes appear. What is actually true is stronger and stranger: on a doubling orbit the *right* primes — the factors of $N$ — cannot appear at all.

Follow the algebra. In the coprime coordinates $x = a/e^2$, $y = b/e^3$, the duplication formula becomes
$$x(2P) = \frac{a\,(a^3 - 8Ne^6)}{4\,b^2 e^2}.$$
So the denominator of $x(2P)$ divides $4b^2e^2$: every prime of the new denominator divides $2be$. Now suppose $p$ is an odd prime dividing $N$ — a bad prime, one of the two we are hunting for — and suppose $p$ shows up in $\operatorname{den} x(2P)$. Then $p$ divides $2be$, hence $p \mid b$ or $p \mid e$. But if $p \mid b$, then reading $b^2 = a^3 + Ne^6$ modulo $p$ gives $p \mid a^3$, hence $p \mid a$. So the only way in is through the door marked "$p$ divides $e$" (the point was already $p$-singular) or the door marked "$p$ divides both $a$ and $b$" — which says exactly that $P$ reduces modulo $p$ to the point $(0,0)$, the *singular point* of the degenerate curve $y^2 = x^3$.

**Theorem (Singular-locus law).** *Let $p \neq 2$ be a prime dividing $N$, and let $P = (x,y)$ be a rational point of $E_N$ with $y \neq 0$. If $p$ divides $\operatorname{den} x(2P)$, then either $p$ already divides $\operatorname{den} x(P)$, or $P$ reduces modulo $p$ to the singular point $(0,0)$.*

Bad primes are confined to the singular locus. And for the moduli that matter, the singular locus is empty:

**Lemma.** *If $N$ is squarefree — in particular if $N = pq$ with $p \neq q$ prime — and $(x,y)$ is a point of $E_N$ with integer coordinates, then $x$ is automatically coprime to $N$.*

The proof is three lines: a common prime factor $p$ of $x$ and $N$ divides $y^2 = x^3 + N$, hence divides $y$, hence $p^2$ divides $y^2 - x^3 = N$, contradicting squarefreeness. The two hypotheses that make the theory bite — odd and squarefree — are exactly the hypotheses satisfied by a cryptographic modulus.

Putting the pieces together and iterating the doubling step gives the punchline.

**Theorem (Anti-factoring theorem).** *Let $N$ be odd and squarefree and let $P$ be any point of $E_N$ with integer coordinates. Then for every $k \geq 0$, the denominator of the $x$-coordinate of $2^k P$ is coprime to $N$. No prime factor of $N$ ever appears in the doubling orbit's denominators.*

Take the semiprime $N = 1763 = 41 \cdot 43$ with $P = (1,42)$. The denominators along $P, 2P, 4P, 8P, 16P$ are
$$1, \quad 784, \quad 2652193144304704, \quad \text{a 66-digit number}, \quad \text{a 266-digit number},$$
and every one of them is coprime to $1763$. It is not that $41$ and $43$ are hiding in the enormous later terms. They are structurally excluded, forever, for every integral starting point, on every odd squarefree modulus.

### What this means for factoring

There is a famous algorithm that *does* factor integers using elliptic curves: Lenstra's elliptic curve method. It is worth being precise about why that works and this does not, because the difference is instructive.

Lenstra's method never works over the rational numbers. It picks a *random* curve, works with coordinates modulo $N$ — pretending $\mathbb{Z}/N$ is a field — and waits for an inversion to fail. A failure means some intermediate quantity shares a factor with $N$, and a $\gcd$ then reveals $p$. The randomness is essential: one tries many curves until one of them has a group order modulo $p$ that is smooth, so that a modest amount of arithmetic reaches the identity modulo $p$ but not modulo $q$.

The approach refuted here is the opposite: fix the single curve $E_N$ built canonically from $N$, work honestly over the rationals, and read the factors out of the denominators. The theorems say the denominators are a very rich source of primes — every prime of good reduction whose local group order cooperates — but they are *never* a source of $p$ or $q$ along doubling orbits. The denominator sequence is a function of $N$, faithfully, and yet it tells you nothing about how $N$ splits. In the language of the research programme this closes off, it converts an empirical wall into a theorem: a survey of eleven semiprime moduli found the conjectural support condition holding in exactly $0\%$ of cases, the larger factor $q$ appearing in essentially none, and the smaller factor only sporadically — and the sporadic appearances, we now know, come from indices $n$ that are *not* powers of two.

That last point is where the story continues rather than ends. On $E_{55}$ the bad prime $5$ does eventually surface, at index $n = 5$: the denominator of $x(5P)$ is $5^2 \cdot 1785401475301^2$. The index and the prime coincide, and that is not a coincidence. Modulo a bad prime $p$, the degenerate curve $y^2 = x^3$ has a smooth part which is isomorphic to the additive group of the field with $p$ elements — and multiplication by $n$ on an additive group of order $p$ is injective exactly when $p \nmid n$. So a bad prime can only enter at indices divisible by itself. That is invisible in a doubling orbit for odd $p$, and it is useless for factoring, since you would have to guess $p$ to know where to look.

### The moral

The "only bad primes" conjecture is a good conjecture in the sense that matters: it is precise, it is natural, it would have been important, and its refutation teaches you the right way to think about the object. The denominators of an elliptic curve orbit are not reading off the singularities of the curve. They are reading off, prime by prime, the moment when the point's shadow in a finite field falls onto the identity. Good primes get infinitely many chances at this; bad primes get almost none, because at a bad prime the identity is guarded by a singular point that integral points on squarefree moduli can never reach.

Denominators know an enormous amount about the local behaviour of a curve. What they do not know — provably, permanently — is how to factor.
