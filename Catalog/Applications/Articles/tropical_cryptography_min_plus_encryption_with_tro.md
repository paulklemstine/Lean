# The Secret That Counts Itself: How a "Tropical" Cipher Gives Away Its Own Key

Imagine a lock whose tumblers are made of shortest paths through a map of cities,
where every product is a sum and every sum is a minimum. For a few years, a small
but enthusiastic corner of cryptography believed that locks like this might be the
key to surviving the quantum era. They are built from **tropical arithmetic** — a
strange and beautiful algebra in which addition is replaced by "take the smaller of
two numbers," and multiplication is replaced by ordinary addition. The hope was
audacious: that this exotic algebra could hide secrets in a way that no quantum
computer could unravel.

This is the story of why one of those locks quietly leaks its key — and how the
leak turns out to be far more total than anyone first suspected. The secret
exponent does not merely slip out. The public data broadcasts the *entire
arithmetic structure* of the secret, like a sealed envelope that helpfully prints
all the factors of the number inside it on the outside.

## A new pair of glasses for arithmetic

Start with the rules. In ordinary arithmetic we have two operations, $+$ and
$\times$. Tropical (or **min-plus**) arithmetic keeps the symbols but swaps their
meaning:

$$a \oplus b = \min(a, b), \qquad a \otimes b = a + b.$$

So "tropical multiplication" is just regular addition, and "tropical addition" is
choosing the minimum. It looks like a typo, but it is a fully consistent algebra,
and it shows up everywhere shortest paths and scheduling and optimization live.

Here is the punchline that makes it interesting: the tropical product of two
matrices is exactly the recipe for combining distance tables. If $A$ and $B$ are
$n \times n$ matrices, their tropical product is

$$(A \otimes B)_{ij} = \min_{k}\,\big(A_{ik} + B_{kj}\big).$$

Read that slowly. It says: to get from $i$ to $j$, try every intermediate stop $k$,
add the cost $A_{ik}$ of getting to $k$ to the cost $B_{kj}$ of leaving $k$, and
keep the cheapest route. This is the **all-pairs shortest path** computation in
disguise. Computing it forward is easy — about $n^3$ operations. Running it
*backward* — recovering $A$ from the product — is the kind of tangled inverse
problem that cryptographers love, because easy-one-way, hard-the-other-way is the
raw material of every cipher.

## Building a lock out of powers

To build a key-exchange protocol you need a one-way *staircase*, not just a
one-way step. So fix a tropical matrix $A$ and multiply it by itself, tropically,
again and again. Write the result as a **tropical power**. In the formal
development this is indexed so that $A^{\otimes 1} = A$ and each step prepends one
more factor:

$$A^{\otimes (k+1)} = A \otimes A^{\otimes k}.$$

So $A^{\otimes t}$ is the $t$-fold tropical product of $A$ with itself. Crucially,
you can compute $A^{\otimes t}$ in about $n^3 \log t$ operations by *repeated
squaring* — the same trick that lets your phone compute enormous powers for RSA in
the blink of an eye. Doubling the exponent costs only one extra matrix multiply.

These powers obey exactly the laws you would want from exponents. Multiplying two
powers of the same matrix adds their exponents,

$$A^{\otimes a} \otimes A^{\otimes b} = A^{\otimes (a+b)},$$

and raising a power to a power multiplies them,

$$\big(A^{\otimes a}\big)^{\otimes b} = A^{\otimes (ab)}.$$

That second law is the heart of a **Diffie–Hellman key exchange**, the protocol
that lets two strangers agree on a shared secret over an open line. Alice picks a
secret exponent $a$ and publishes $A^{\otimes a}$. Bob picks a secret $b$ and
publishes $A^{\otimes b}$. Each then raises the *other's* matrix to their own
secret. Because the exponents multiply the same way regardless of order,

$$\big(A^{\otimes a}\big)^{\otimes b} = A^{\otimes (ab)} = \big(A^{\otimes b}\big)^{\otimes a},$$

both of them arrive at the identical shared key $A^{\otimes (ab)}$. An eavesdropper
sees $A$, $A^{\otimes a}$, and $A^{\otimes b}$ — but to reconstruct $A^{\otimes
(ab)}$ they would seemingly need one of the secret exponents. Finding $k$ from $A$
and $A^{\otimes k}$ is the **Tropical Discrete Logarithm Problem (TDLP)**, and the
whole edifice rests on it being hard.

It is not.

## The eigenvalue that keeps a tally

Every tropical matrix has a hidden number attached to it: its **tropical
eigenvalue**. In ordinary linear algebra, an eigenvector $v$ is a direction that a
matrix merely stretches: $Av = \lambda v$. The tropical analogue replaces stretch
with shift. A vector $v$ is a tropical eigenvector with eigenvalue $\lambda$ when
applying the matrix simply adds the same constant $\lambda$ to every coordinate:

$$(A \otimes v)_i = \min_k\big(A_{ik} + v_k\big) = v_i + \lambda \quad \text{for every } i.$$

Geometrically, $\lambda$ is the *minimum average cost of a cycle* in the network
$A$ describes — the cheapest loop you can run forever. It is an intrinsic
fingerprint of the matrix.

Now define the quantity an eavesdropper can actually *measure*. Given a published
matrix and a known reference vector $v$, look at how much the matrix shifts each
coordinate. We call this the **residual**:

$$\mathrm{res}(A, v)_i = (A \otimes v)_i - v_i.$$

For a genuine eigenpair this residual is exactly $\lambda$, identically, in every
coordinate. No averaging, no statistics, no noise: read off any single entry and
you have the eigenvalue on the nose.

Here is where the lock springs open. Watch what the eigenvalue does as you climb
the staircase of powers. The defining property of an eigenvector is that the matrix
shifts it by $\lambda$ — so applying the matrix $t$ times shifts it by $\lambda$
exactly $t$ times. In residual language, the central cryptanalytic fact is:

$$\mathrm{res}\big(A^{\otimes t}, v\big)_i = t\,\lambda \quad \text{for every coordinate } i.$$

**The tropical eigenvalue is additive under powering.** The public matrix
$A^{\otimes t}$ doesn't just contain a faint shadow of the secret exponent $t$ — it
broadcasts $t\lambda$ at *every single coordinate*, a number that grows in perfect
lockstep with the secret. If you know $\lambda = \lambda(A)$ (which you do, because
$A$ is public), recovering the secret is a single division:

$$t = \frac{\mathrm{res}\big(A^{\otimes t}, v\big)_i}{\lambda}.$$

The "discrete logarithm" that was supposed to be hard collapses into grade-school
arithmetic. There is exactly one escape hatch: if $\lambda = 0$, then the residual
is identically zero no matter what $t$ is, and the side channel goes silent. But a
zero eigenvalue means the network has a free cycle — a loop you can traverse at no
cost — which is a fragile, non-generic condition. For a randomly built tropical
matrix it essentially never happens. The lock is open for almost every key.

## The leak is worse than a stolen key

You might think that recovering the secret exponent is the end of the story — the
worst that can happen. It isn't. The deeper discovery in this work is that the
public data leaks not just the *value* of the secret, but its entire **divisibility
structure**.

To see this, freeze the matrix and stare only at the leaked numbers. As the secret
exponent $t$ ranges over $1, 2, 3, \dots$, the leaked eigenvalue traces out the
sequence

$$t \;\longmapsto\; c \cdot t, \qquad \text{where } c = \lambda(A).$$

Call this the **tropical eigenvalue sequence**. It is the simplest possible
sequence — a constant times the index — and that simplicity is precisely the
weapon. This sequence has a remarkable property shared by famous sequences like the
Fibonacci numbers and the Mersenne numbers: it is a **strong divisibility
sequence**. That means two things hold together: the sequence vanishes at index
$0$, and the greatest common divisor of two terms is the term at the greatest
common divisor of the indices:

$$\gcd\big(c\cdot m,\; c\cdot n\big) = c \cdot \gcd(m, n).$$

That single identity is a powerhouse. It implies that one secret exponent divides
another **if and only if** the corresponding leaked eigenvalues divide each other.
Formally, for any positive eigenvalue $c$,

$$(m+1) \mid (k+1) \quad\Longleftrightarrow\quad c(m+1) \mid c(k+1).$$

Translate that out of symbols. Suppose an eavesdropper has watched several past
sessions and harvested their public matrices and leaked eigenvalues. They can now
read off statements like "Tuesday's secret divides Friday's secret" or "this key
is a prime number of steps long" — purely from the public transcript, without ever
recovering the raw exponents. The envelope doesn't just leak the number inside; it
prints the number's complete factorization lattice on the outside. A side channel
that was supposed to be, at worst, a single number, turns out to expose an entire
web of arithmetic relationships.

## Nesting doesn't help

A natural last-ditch defense is to make the problem harder by *nesting*: raise $A$
to a secret power, then raise the result to another secret power, hoping the
compounded difficulty foils the attacker. The shared key in the Diffie–Hellman
exchange is exactly such a nested object. But the eigenvalue arithmetic follows
along obediently. With Alice's exponent $a$ and Bob's exponent $b$, the shared
key's eigenvalue satisfies a clean factorization in terms of the *public*
eigenvalues alone:

$$c \cdot \lambda(\text{shared}) = \lambda(\text{Alice's public}) \cdot \lambda(\text{Bob's public}).$$

Every quantity on the right is visible to the eavesdropper. The shared secret's
fingerprint is computable from public data, so nesting multiplies a public
invariant rather than hiding a private one. There is no hardness amplification to
be had: the multiplicative shadow of the additive eigenvalue law tracks every move.

## What the wreckage teaches

It is tempting to read this as a purely negative result — another candidate
post-quantum cipher consigned to the scrapheap. That is the headline, and it is
true: tropical Diffie–Hellman, in this matrix-power form, is broken for essentially
every key, and broken *thoroughly*. But the more durable lesson is a positive one
about how to *audit* cryptography.

The fatal flaw was not a clever attack; it was a structural inevitability. The
public transcript was a strong divisibility sequence in the secret, and **any**
scheme whose transcript is a strong divisibility sequence cannot hide the secret's
divisibility lattice. That gives designers a sharp, reusable question to ask of any
new proposal: *Is my public transcript, viewed as a function of the secret, a
strong divisibility sequence?* If the answer is yes, the scheme leaks — no
simulation, no statistics, just algebra. The same framework that unifies the
Fibonacci and Mersenne sequences now doubles as a security litmus test.

Tropical arithmetic remains genuinely beautiful and genuinely useful, from
scheduling theory to the geometry of optimization. What this episode shows is that
beauty is not security. A cipher's safety lives in the structure it *fails* to
expose, and min-plus powering exposes too much: an eigenvalue that faithfully
counts the secret, coordinate by coordinate, and a sequence so well-behaved that
its arithmetic is an open book. Sometimes the most dangerous thing a secret can do
is keep a perfect tally of itself.
