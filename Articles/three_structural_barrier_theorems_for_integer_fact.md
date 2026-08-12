# The Locked Room: Why Clever Formulas Will Never Factor Your RSA Key

## A number that keeps a secret

Take two large prime numbers, multiply them together, and publish the product. That is the whole of RSA, the encryption that still guards a large share of the world's banking, messaging, and software updates. The product $N = pq$ is public. The two primes $p$ and $q$ are the secret. Everything rests on one hope: that recovering $p$ and $q$ from $N$ is hard.

Nobody has ever proved that hope is justified. And so, for half a century, an enormous amount of ingenuity has been poured into the reverse direction: into finding some *structural* handle on $N$ that pops the lock open. Build a clever polynomial in $N$ and take a greatest common divisor. Run lattice reduction and extract a resultant. Cook up a determinant, a discriminant, a hyperdeterminant. Build an analytic function whose zeros sit exactly at $p$ and $q$ and then hunt for its zeros in the complex plane.

Each of these ideas has been proposed, often repeatedly, and each has quietly failed. The interesting question is not *whether* they failed but *why*. Is it bad luck, or is there something in the structure of the problem that guarantees failure in advance?

This article is about three theorems that answer that question. Each one takes a broad class of "structural" factoring strategies and proves — unconditionally, with no complexity-theoretic assumptions, no unproven conjectures — that the entire class is powerless. The three obstructions come from three different parts of mathematics: algebra, group theory, and complex analysis. They are independent of one another; none implies another. Together, they map out a locked room, and they tell you exactly where the one unlocked door is.

## Barrier I: the polynomial invariant that already knows the answer

Here is the strategy in its simplest form. Pick a polynomial with integer coefficients — say $f(x) = x^2 + 5x + 6$. Feed it your modulus: compute $f(N)$. Now compute $\gcd(f(N), N)$. If that greatest common divisor comes out strictly between $1$ and $N$, you have split $N$ and the secret is yours.

Try it. With $N = 15 = 3 \cdot 5$ you get $f(15) = 306$ and $\gcd(306, 15) = 3$. It worked! Factor found.

Now try $N = 91 = 7 \cdot 13$. You get $f(91) = 8742$ and $\gcd(8742, 91) = 1$. Nothing.

Sweep the polynomial across all $136$ semiprimes $N = pq$ with $p < q < 60$, and it splits exactly $30$ of them. But look at *which* primes it ever exposes: always $2$ or $3$, never anything else. Never $7$, never $13$, never $59$. And $2$ and $3$ are precisely the prime factors of $f(0) = 6$.

That is not an accident. It is a theorem.

> **The Polynomial Barrier (local form).** Let $f$ be any polynomial with integer coefficients, let $N$ be any integer, and let $p$ be a prime dividing $N$. Then $p$ divides $f(N)$ if and only if $p$ divides $f(0)$.

The proof takes one line, and once you see it you can never unsee it. For any integers $a$ and $b$, the difference $a - b$ divides $f(a) - f(b)$ — because every term $a^k - b^k$ has $a-b$ as a factor. Put $a = N$ and $b = 0$: then $N$ divides $f(N) - f(0)$. So $f(N) \equiv f(0) \pmod{N}$, and in particular modulo every prime factor $p$ of $N$. The polynomial cannot tell $N$ apart from $0$.

The consequence is stark. Since $f(N)$ and $f(0)$ are congruent modulo $N$,
$$\gcd(f(N), N) = \gcd(f(0), N).$$
The entire computation of $f$ at $N$ — all those degree-$100$ terms, all that arithmetic on thousand-digit numbers — cancels out. The witness you get is the witness you would have gotten by ignoring $N$ inside $f$ altogether and just computing $\gcd$ of the constant term with $N$. Your elaborate invariant is a very expensive way of writing down a fixed integer.

Two sharper statements follow, and they are the ones with teeth.

> **Reveal budget.** A fixed polynomial invariant $f$ can, over its entire lifetime and across all inputs, expose only the primes dividing $f(0)$ — at most $\log_2 |f(0)|$ of them.

> **Sharp failure in the cryptographic regime.** If $f$ splits the semiprime $N = pq$, then $\min(p, q) \le |f(0)|$.

Read that last one carefully, because it is the punchline. To split a balanced $2048$-bit RSA modulus — one whose two prime factors each have about $1024$ bits — your polynomial's *constant term* must be at least $1024$ bits long. But the constant term is a fixed integer that you have to write down before you ever see $N$. Writing down a $1024$-bit constant term divisible by the secret prime means already knowing the secret prime. The method never gives you anything you did not put in.

And you cannot escape by using many polynomials, or by choosing your polynomial after peeking at $N$ in a limited way.

> **No universal family.** For any finite collection of integer polynomials, there is a semiprime $N = pq$ on which every single member fails to produce a nontrivial factor. Indeed, the defeating modulus can be taken with both primes larger than all the constant terms in the collection — precisely the cryptographic regime.

> **No residue-adaptive witness.** Even an adversary allowed to *choose* the polynomial as a function of $N$'s residue class modulo a fixed number $M$ — a lookup table with infinitely many entries but finitely many polynomials — still fails on some semiprime.

Since resultants, discriminants, hyperdeterminants, and the integers extracted by lattice reduction from a fixed construction are all polynomial functions of $N$, the whole family is dead on arrival.

## Barrier II: multiplication forgets which one came first

The second obstruction is so simple it can be explained to a child, and yet it is a complete characterization rather than a mere necessary condition.

Multiplication is commutative. $N = pq$ and $N = qp$ are the same number. The map that takes the secret pair $(p, q)$ to the public modulus $N$ therefore *forgets* the order. Anything you compute from $N$ — anything at all, computable or not, fast or slow — is blind to which prime was called $p$ and which was called $q$.

Say a quantity $D(p,q)$ attached to pairs of primes is **recoverable from the modulus** if there is some function $G$ of a single number with $G(pq) = D(p,q)$ for all primes $p, q$.

> **The Symmetry Dichotomy.** A quantity $D(p, q)$ is recoverable from the modulus if and only if it is symmetric: $D(p,q) = D(q,p)$ for all primes $p, q$.

One direction is the observation above: if $G(pq) = D(p,q)$, then $D(p,q) = G(pq) = G(qp) = D(q,p)$. The other direction is unique factorization: the product $pq$ pins down the *unordered* pair $\{p, q\}$ exactly, with the transposition as the only ambiguity, so any quantity that ignores the ordering is a well-defined function of the product.

The immediate casualties are the antisymmetric quantities. The gap $p - q$ flips sign under the transposition; over the integers, a number equal to its own negative is zero, so the gap simply cannot be a function of $N$. Neither can "return the left factor," since it would have to return both $3$ and $5$ when handed $N = 15$. In general, any nonzero quantity satisfying $D(q,p) = -D(p,q)$ (in a group where $x = -x$ forces $x = 0$) is unrecoverable. The torsion condition is not decoration: over the two-element group, $D(p,q) = p+q$ is simultaneously symmetric and antisymmetric, and nothing is lost.

Now for the part that keeps this theorem honest, and that most informal versions of "the symmetry argument" get wrong. The symmetry barrier is **not** a hardness theorem.

> **Sharpness.** The smaller prime $\min(p,q)$ is a symmetric quantity. Hence, by the dichotomy, it *is* a genuine function of $N$ — in the abstract, set-theoretic sense — and so is the sum $p + q$.

Of course it is. Factoring is a function; it just may be an expensive one. What the symmetry barrier forbids is *well-definedness* of antisymmetric targets, not efficiency of symmetric ones. It says: stop looking for a formula that outputs "the first factor," because that phrase is meaningless as a function of $N$. Aim at symmetric targets like $\min(p,q)$ or $p+q$, which at least have a chance of existing.

Behind it lies a principle worth stating on its own, because it recurs across cryptography: if the map producing your public data is invariant under a symmetry of the secret space, then every quantity derived from the public data is invariant under that symmetry too. The secret's antisymmetric component is destroyed at encoding time, before any adversary gets a chance to be clever.

## Barrier III: an analytic device is the answer in disguise

The third strategy is the most seductive, because complex analysis is powerful and its theorems feel like magic. The plan: from $N$, construct some function $F_N$ of a complex variable, holomorphic on the whole plane (an *entire* function), whose zeros are exactly the primes $p$ and $q$. Then find the zeros — by contour integration, by Newton's method, by argument-principle counting — and read off the factors.

Three separate things go wrong, and each is fatal on its own.

**Rigidity.** Complex analysis is not forgiving about zeros the way real analysis is. If an entire function $F$ vanishes at a point $a$, then $F(z) = (z-a)G(z)$ for some entire $G$ — the removable-singularity theorem says the difference quotient is not merely defined but holomorphic. Apply this twice:

> **Holomorphic Rigidity.** If an entire function $F$ vanishes at two distinct points $a \ne b$, then there is an entire function $G$ with
> $$F(z) = (z-a)(z-b)\,G(z)$$
> for all $z$. If moreover the zero set of $F$ is *exactly* $\{a, b\}$, then $G$ never vanishes off $\{a,b\}$.

Apply it with $a = p$, $b = q$. Your beautiful analytic device is literally the factor polynomial $(z-p)(z-q)$ multiplied by a nonvanishing function — a unit, in every sense that matters. The quadratic $(z-p)(z-q) = z^2 - (p+q)z + N$ has the factorization encoded in its middle coefficient. So writing down $F_N$ is *at least as hard as factoring*: you cannot produce the device without already possessing the answer it is supposed to give you. This is not an obstruction to the device existing. It is an obstruction to constructing it from $N$ alone.

**The null set.** Suppose someone hands you the device anyway and tells you to find its zeros numerically. Here the geometry of the plane works against you.

> **Zero sets are negligible.** The zero set of an entire function that is nonzero somewhere is countable, and has planar Lebesgue measure zero. Consequently, in any region of positive area, the non-vanishing points have *full* measure: sampling points and testing for a zero succeeds with probability zero.

Two isolated points in a plane. You could sample forever. In the numerical demonstration accompanying this work, two hundred thousand random complex points drawn from a $200 \times 200$ square around a device with zeros at $61$ and $97$ produced exactly zero hits — as the theorem guarantees. Zeros must be *hunted*, by methods (contour integrals, argument counting) that require evaluating $F_N$, and evaluating $F_N$ requires having built it, which requires the factors. The circularity closes.

**The arithmetic cost of a zero.** When the device is an integer polynomial, Barrier III collapses into Barrier I and becomes quantitative:

> **Device size lower bound.** If an integer polynomial $f$ with $f(0) \ne 0$ vanishes at a prime $p$, then $p$ divides $f(0)$; hence $p \le |f(0)|$. A fixed integer polynomial can have at most $\log_2|f(0)|$ primes among its roots.

Encoding a prime as a zero costs you as many bits as the prime itself. There is no compression, no free lunch, no clever encoding.

Finally — and this is what stops the barrier from over-claiming — the analytic device *does* exist:

> **Sharpness.** For any two distinct primes $p, q$, there is a nonzero entire function whose zero set is exactly $\{p, q\}$: namely $(z-p)(z-q)$ itself.

So Barrier III is not "no such object exists." It is "every such object is the factorization wearing a costume."

## Where the door is

A barrier programme that proves too much proves nothing, so the honest question is: what escapes?

Pollard's $p-1$ method escapes — sort of. It takes a base $a$ and an exponent $m$ and computes $\gcd(a^m - 1, N)$. This genuinely works: if $p - 1$ divides $m$, if $p$ does not divide $a$, and if $q$ does not divide $a^m - 1$, then Fermat's little theorem makes $p$ divide $a^m - 1$ while $q$ does not, and the greatest common divisor is exactly $p$. With $N = 35$, $a = 2$, $m = 4$: $\gcd(15, 35) = 5$. Factored.

It also has a second failure mode that shows how narrow the window is. If $m$ happens to be a multiple of *both* $p-1$ and $q-1$, then both primes divide $a^m - 1$, the greatest common divisor returns all of $N$, and you learn nothing. With $N = 15$, $a = 2$, $m = 4$: the answer is $15$. Too much smoothness is as useless as too little.

But now hold the exponent fixed. For a fixed $a$ and $m$, the quantity $a^m - 1$ is a *constant*: an integer that does not depend on $N$ in any way. It is the constant polynomial $f(x) = a^m - 1$, and Barrier I applies word for word. So:

> **Escape requires a growing exponent.** The $p-1$ strategy splits some semiprimes; yet for every fixed exponent there is a semiprime it fails on. All of the method's power comes from letting the exponent grow with the input.

Take $a = 2$, $m = 12$: then $a^m - 1 = 4095 = 3 \cdot 3 \cdot 5 \cdot 7 \cdot 13$, and the method can only ever reveal the primes $3, 5, 7, 13$. Hand it $N = 4099 \cdot 4111$ and the greatest common divisor is $1$. Every time.

This is the one door in the locked room, and it is exactly the door that all successful factoring algorithms walk through. The quadratic sieve, the number field sieve, elliptic-curve factorization: none of them is a fixed formula evaluated at $N$. They are *unbounded processes* whose descriptions grow with the input — searching for smooth relations, varying over elliptic curves, building relation matrices whose size scales with $N$. The barriers say that this is not a stylistic choice. It is forced.

## What three barriers buy you

It is worth being precise about what has and has not been established, because the temptation to over-read a barrier is strong.

These theorems do **not** say factoring is hard. That remains open, and these methods say nothing about it. What they say is that three enormous, recurrent, intuitively appealing classes of *shortcut* are provably empty, and that each is empty for a different reason:

- The **algebraic** reason: polynomial evaluation at $N$ is congruent to evaluation at $0$ modulo $N$, so an invariant's yield is a property of the invariant, never of the input.
- The **group-theoretic** reason: the transposition of the two factors is a symmetry of the public data, so the antisymmetric half of the secret is destroyed at encoding time.
- The **analytic** reason: holomorphic functions are rigid, so encoding the factors in a zero set requires already possessing them, and the zero set is invisible to search.

They are complementary, not redundant. The smaller prime $\min(p,q)$ passes Barrier II — it is symmetric, hence an abstract function of $N$ — yet no polynomial witness ever computes it, so Barrier I kills it. Conversely a gcd witness is automatically a function of $N$, hence automatically symmetric, so Barrier I methods are a strict sub-world of the symmetric world Barrier II delimits. And the analytic devices of Barrier III, when they happen to be integral, pay the arithmetic price of Barrier I. Three fences around the same field, none of them parallel.

There is a broader lesson here, one that reaches past factoring. Impossibility results are often treated as the disappointing part of mathematics — the part that tells you to stop. But a good barrier theorem is a map. It says: this whole region is empty, do not waste your years there; and *that* narrow corridor, the one where your object's description is allowed to grow with the input, is where all the room is. Half a century of failed factoring proposals now has an explanation that is not "people were not clever enough." It is that no amount of cleverness inside those classes could have worked.

The one door remains open. Nobody knows what is behind it.
