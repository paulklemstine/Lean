# The Curve That Forgets

## How a 225-year-old symmetry makes an elliptic curve predictable — and why that still doesn't help you break a code

### A number with a secret

Give me a large number $N$ and tell me it is the product of two primes, $N = pq$. Ask me what those primes are, and — if $N$ has a few hundred digits — I will not be able to tell you. Neither will anyone else. That failure is not an embarrassment; it is infrastructure. A large part of the world's encrypted traffic rests on it.

But here is a subtler question, and the one this article is about. I am not asking you to *find* $p$ and $q$. I am asking whether $N$ *leaks* anything about them. Suppose I whisper to you only the last digit of $N$, or its remainder when divided by $12$. Can you deduce anything about a hidden property of its unseen factors?

Sometimes, spectacularly, yes. Here is the classic example. The quantity $p - 1$ is central to one of the oldest factoring algorithms. Is $p-1$ divisible by $3$? That is a property of the hidden factor. But $3 \mid p - 1$ means $p \equiv 1 \pmod 3$, and if you know $N \bmod 3$ you know a great deal about $p \bmod 3$ and $q \bmod 3$: if $N \equiv 2 \pmod 3$ then exactly one of $p, q$ is $\equiv 2$, and the other is $\equiv 1$, so *one of the two factors definitely has $3 \mid p-1$*. Measured in bits, the residue $N \bmod 3$ carries about $0.315$ bits of information about the event "$3$ divides $p-1$ or $3$ divides $q-1$". That is a loud signal.

Now replace $p-1$ by something far more modern: the number of points on an elliptic curve over the field with $p$ elements. This is the quantity that drives the elliptic curve method of factorization, one of the most effective factoring algorithms ever designed. Ask the same question: does $N \bmod 3$ tell you anything about whether $3$ divides that point count?

For a curve chosen at random, the answer is a flat, uncompromising **no**. The measured information is $0.0000$ bits — indistinguishable from noise. The elliptic point count is *invisible* from the residue of $N$. This is the phenomenon of total residue-invisibility, and it is a genuine security feature: the arithmetic of a random elliptic curve is governed by a two-dimensional symmetry group so large and so unconstrained that no congruence condition on $p$ pins down the point count.

This article is about what happens when you *deliberately break* that symmetry — by choosing a very special curve — and about the strange, precise, and ultimately disappointing shadow that emerges.

### Counting points, and the number that measures the error

An elliptic curve over the field $\mathbb{F}_p$ of integers modulo a prime $p$ is the set of solutions $(x,y)$ to an equation like
$$y^2 = x^3 + Ax + B,$$
together with one extra "point at infinity." Write $\#E(\mathbb{F}_p)$ for the total number of points.

A first guess: for each of the $p$ possible values of $x$, the right-hand side is some number, and roughly half of all numbers mod $p$ are perfect squares. If the right-hand side is a nonzero square you get two points $(x, \pm y)$; if it is a non-square you get none; if it is zero you get one. Averaging, you expect about $p$ affine points, so about $p+1$ in total.

The deviation from that guess is called the **trace of Frobenius**:
$$a_p \;=\; p + 1 - \#E(\mathbb{F}_p).$$
Hasse's theorem says $|a_p| \le 2\sqrt{p}$ — the guess is never off by much. For a typical curve, $a_p$ jitters around inside that window in a way that looks, as $p$ varies, like a random draw from a semicircular distribution. It essentially never hits exactly zero. In a sample of thousands of primes, a generic curve had $a_p = 0$ about $0.4\%$ of the time.

Now watch what happens to the curve
$$E : y^2 = x^3 + x.$$

### The curve Gauss already knew

This is the most famous curve in elementary number theory, and Gauss was counting its points in 1801. It has an extra symmetry that a random curve does not: the map $(x,y) \mapsto (-x, \sqrt{-1}\, y)$ sends the curve to itself whenever $\sqrt{-1}$ exists. In modern language its endomorphism ring is the ring of Gaussian integers $\mathbb{Z}[i]$ — it has *complex multiplication*.

And its point counts obey a law of startling rigidity.

> **Theorem (the exact dichotomy).** Let $p$ be an odd prime. Then the trace of $E : y^2 = x^3 + x$ over $\mathbb{F}_p$ satisfies
> $$a_p = 0 \iff p \equiv 3 \pmod 4.$$
> Equivalently, $\#E(\mathbb{F}_p) = p+1$ exactly on the primes $p \equiv 3 \pmod 4$.

Not "usually," not "with probability tending to one" — *exactly*. On half of all primes the curve's point count collapses onto the naive guess $p+1$ with no error whatsoever. In a test over $2027$ primes congruent to $3 \bmod 4$, the trace vanished $2027$ times out of $2027$.

Half the primes give $a_p = 0$; the trace law is *atomic* rather than semicircular. Where a generic curve has probability $0.004$ of hitting zero, this curve has probability $0.507$.

Why? The proof is two lines and needs nothing beyond a sign.

When $p \equiv 3 \pmod 4$, $-1$ is not a square modulo $p$. The cubic $f(x) = x^3 + x$ is an *odd* function: $f(-x) = -f(x)$. So for any nonzero $x$, the two values $f(x)$ and $f(-x)$ differ by a factor of $-1$, and since $-1$ is a non-square, exactly one of them is a square and the other is not. Pair up the $x$-values into couples $\{x, -x\}$. Each couple contributes exactly two points: two from one member, zero from the other. There are $(p-1)/2$ couples, contributing $p-1$ points; add the single point over $x = 0$ (where $f(0)=0$, giving $y = 0$) and the point at infinity, and you get
$$\#E(\mathbb{F}_p) = (p-1) + 1 + 1 = p+1.$$

There is a second, equally elementary fact:

> **Theorem (universal divisibility by four).** For every odd prime $p$, $4$ divides $\#E(\mathbb{F}_p)$ for the curve $y^2 = x^3 + x$.

On the inert half this is automatic, since $p \equiv 3 \pmod 4$ makes $p+1$ divisible by $4$. On the other half, $p \equiv 1 \pmod 4$, the number $-1$ *is* a square, say $-1 = i^2$, and then the cubic factors completely: $x^3 + x = x(x-i)(x+i)$. Three distinct roots means three points of order two, which together with the point at infinity form a subgroup of order four sitting inside the curve's group. So $4 \mid \#E$. In a thousand-prime sample this held $1000$ times out of $1000$, against $458$ for a generic curve.

These two facts snap together into something rather beautiful. On the split half $p \equiv 1 \pmod 4$ we have $p+1 \equiv 2 \pmod 4$; but $4$ divides $\#E$; so $\#E \ne p+1$, so $a_p \ne 0$. **Ordinarity on one half is a corollary of a divisibility count on the other.** No deep theory of complex multiplication, no Deuring correspondence, no reciprocity law: one parity argument and one factorization give the exact dichotomy.

What *is* the trace on the split half? Gauss knew this too. Every prime $p \equiv 1 \pmod 4$ is a sum of two squares, $p = a^2 + b^2$, in essentially one way, and one can normalize $a$ to be the odd one. Then $|a_p| = 2a$. This too was confirmed on $1973$ out of $1973$ split primes. Moreover the fact that $a$ is odd follows from the divisibility above with no extra work: $4 \mid \#E$ and $p \equiv 1 \pmod 4$ force $a_p \equiv 2 \pmod 4$, i.e. $a_p/2$ is odd.

### The mirror at the sixth root of unity

There is exactly one other curve family with symmetry this rigid and this elementary, and it lives one step over:
$$E' : y^2 = x^3 + 1.$$
Its extra symmetry is $(x,y) \mapsto (\zeta x, y)$ where $\zeta$ is a primitive cube root of unity; its endomorphisms are the Eisenstein integers $\mathbb{Z}[\zeta]$.

Everything above repeats with $2$ replaced by $3$ and $4$ replaced by $3$.

> **Theorem (the Eisenstein dichotomy).** For a prime $p \notin \{2,3\}$, the trace of $y^2 = x^3+1$ over $\mathbb{F}_p$ vanishes exactly when $p \equiv 2 \pmod 3$. Moreover, when $p \equiv 2 \pmod 3$, *every* curve $y^2 = x^3 + B$ has exactly $p+1$ points, whatever $B$ is.

The mechanism this time is even simpler than a sign flip. When $p \equiv 2 \pmod 3$, the map $x \mapsto x^3$ is a *bijection* of $\mathbb{F}_p$ — cubing has an inverse, namely raising to the power $(2p-1)/3$. So as $x$ runs over the field, $x^3 + B$ runs over the whole field too, and the tally of squares versus non-squares among all field elements is perfectly balanced. The error term vanishes identically, giving $p+1$ points for the entire family at once.

On the other half, $p \equiv 1 \pmod 3$, the cube root of unity $\zeta$ genuinely exists in $\mathbb{F}_p$, and the map $(x,y) \mapsto (\zeta x, y)$ shuffles the points of the curve in cycles of length three. Its only fixed points are the two points $(0, \pm 1)$ sitting over $x = 0$ and the point at infinity — three of them. Everything else is partitioned into three-element orbits. Therefore
$$\#E'(\mathbb{F}_p) \equiv 3 \equiv 0 \pmod 3.$$
And since $p \equiv 1 \pmod 3$ gives $p+1 \equiv 2 \pmod 3$, the count cannot equal $p+1$, so the trace is nonzero. Again, ordinarity is a corollary of a divisibility, produced by a symmetry of order three instead of an involution.

The two dichotomies are *independent*: one is a condition mod $4$, the other a condition mod $3$. At $p = 5$ the Gaussian curve is ordinary and the Eisenstein curve is degenerate to $p+1$; at $p = 7$ the reverse. There is no single "complex multiplication shadow" — the visible congruence depends on which curve you picked.

### The shadow, and why it is worthless

Return to the original question. We now have a curve whose point count, on half of all primes, is *literally the number $p+1$*. Surely now something leaks?

It does. And the leak is real, measurable, and — this is the punchline — completely useless.

Here is a clean instance you can check by hand.

> **Theorem (the symmetric leak).** Let $N = pq$ with $p, q \equiv 3 \pmod 4$ and $N \equiv 5 \pmod{12}$. Then $3$ divides $\#E(\mathbb{F}_p)$ or $3$ divides $\#E(\mathbb{F}_q)$.

The argument is pure bookkeeping. Both factors are $\equiv 3 \pmod 4$, so each is $3$, $7$, or $11$ mod $12$. Multiply out all nine possibilities: the only ones giving $5 \bmod 12$ involve at least one factor $\equiv 11 \pmod{12}$. And a factor $\equiv 11 \pmod{12}$ is inert (so its point count is $p+1$) and satisfies $p \equiv 2 \pmod 3$ (so $3 \mid p+1$). Done. Knowing only $N \bmod 12$, you have deduced something certain about the hidden elliptic geometry of an unseen prime.

This is the *first positive residue signal ever measured on an elliptic point count*. Quantitatively, on six thousand random semiprimes, the residue $N \bmod \ell$ carried $0.0048$ bits about the symmetric event at $\ell = 3$ and $0.0062$ bits at $\ell = 5$ — each about $4.8$ times the noise floor, statistically solid. A generic curve on the same semiprimes gave $0.0000$ and $0.0003$: nothing. Restoring the symmetry restored the shadow.

But look at the size. The $p-1$ control on the same data gave $0.3167$ bits. The elliptic signal is *forty times smaller*. And when you trace where the dilution comes from, you see the whole story:
$$\Pr[3 \mid \#E(\mathbb{F}_p)] \;=\; \underbrace{0.515 \times 0.515}_{\text{inert, then } 3 \mid p+1} \;+\; \underbrace{0.484 \times 0.117}_{\text{split, then a deep condition}}.$$
The first term is visible; the second is not. Half the primes contribute a term governed by whether $p+1$ is divisible by $3$ — an ordinary congruence. The other half contribute a term governed by the trace $a_p$, which depends on the decomposition $p = a^2 + b^2$ in a way no congruence on $p$ can capture. And even the visible half is *diluted*, because the condition is a conjunction: "the factor is $\equiv 3 \pmod 4$ **and** $\equiv -1 \pmod 3$." The residue $N \bmod 3$ cannot see the mod-$4$ part at all.

Then comes the fatal blow. A factoring algorithm needs to know *which* factor to chase. That is the asymmetric bit: "does $3$ divide the point count of the **smaller** factor?" Measured on the same data, the asymmetric information is $0.0000$, $0.0005$, $0.0009$ bits at $\ell = 3, 5, 7$ — flat noise.

And it is not merely small; it is provably zero, in the sharpest possible sense. Consider:
$$77 = 7 \cdot 11, \qquad 209 = 11 \cdot 19.$$
Both are $\equiv 5 \pmod{12}$. For both, the symmetric event holds. But $\#E(\mathbb{F}_7) = 8$, not divisible by $3$, while $\#E(\mathbb{F}_{11}) = 12$, which is. So the "smaller factor" bit is **false** for $77$ and **true** for $209$ — two numbers with identical residues and opposite answers. No function of $N \bmod 12$, however cleverly designed, can distinguish them. The which-factor channel is not weak. It is empty.

The reason is embarrassingly simple, and it generalizes: multiplication is commutative. Any statistic of $N \bmod M$ is blind to which of the two factors is smaller, so the asymmetric bit is destroyed at the source. The symmetric bit survives; the useful bit does not.

Even the symmetric bit is only partial: $133 = 7 \cdot 19$ and $253 = 11 \cdot 23$ are both $\equiv 1 \pmod{12}$, yet the symmetric event fails for the first and holds for the second.

And for the Eisenstein curve at $\ell = 5$, even the symmetric channel dies. Products of two inert primes land in the four residues $1, 4, 7, 13 \bmod 15$, and each of those four is realized both with and without the event. The residues form a multiplicative coset closed under negation, and that closure erases the signal entirely.

### The last hope, closed

One could still hope the point count offers a *practical* advantage. It does not, and the reason is almost funny.

> **Theorem.** On the inert half $p \equiv 3 \pmod 4$, for any integer $M$, the elliptic method's stage-one test "$\#E(\mathbb{F}_p) \mid M$" is *literally identical* to the test "$(p+1) \mid M$".

Because $\#E = p+1$ there. So on exactly the primes where the special curve has a visible shadow, the algorithm you are running is not a new elliptic method at all — it is Williams's $p+1$ method from 1982, a technique that is entirely abelian, entirely known, and whose own residue channel was already closed.

The four-way experimental contrast confirms it with brutal clarity. On inert primes where $p+1$ is smooth, the curve fires $40$ times out of $40$ — and so does the plain $p+1$ method, because they are the same test. On split primes where the CM order is smooth but $p+1$ is not, the curve fires $40/40$ — this is the genuinely new territory, and it is exactly the region where no residue signal exists. And on split primes where the $p+1$ method succeeds but the CM order is not smooth, the curve manages $4$ out of $40$: *the special curve misses the very primes the $p+1$ method catches.*

The verdict is a confirmed null. Even choosing a curve so extreme that its geometry degenerates to arithmetic on half of all primes, all you can extract from the residue of $N$ is a channel that was already open, already known, and already useless.

### What is left standing

It would be a mistake to read this as a purely negative story.

What survives is a piece of mathematics of unusual cleanliness: an exact, if-and-only-if classification of when two classical curves lose their arithmetic randomness, proved by a sign flip and an order-three shuffle, with the "hard" half of each statement falling out as a corollary of a counting congruence on the other half. Two structural mechanisms — rational two-torsion at the Gaussian discriminant, an order-three automorphism at the Eisenstein one — produce the same shape of theorem for entirely different reasons, and they cut the primes along independent congruences.

And the negative half has real content too. The invisibility of the elliptic point count from the residue of $N$ is not a lucky accident of generic curves. It survives the most aggressive attempt to break it. Complex multiplication restores a shadow, but the shadow is precisely the abelian part — the part that was never elliptic to begin with. What is genuinely elliptic, the trace on the split half, stays hidden.

That is a reassuring thing to know about the arithmetic your encryption rests on. Some doors are locked. And some, when you finally get them open, turn out to lead into the corridor you were already standing in.
