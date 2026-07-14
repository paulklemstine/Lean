# The Number 120 That Modular Forms Left Behind

## A coincidence that isn't one

Add up the cubes of the divisors of $6$. The divisors are $1, 2, 3, 6$, so the sum is
$1 + 8 + 27 + 216 = 252$. Now add up the seventh powers of the same divisors:
$1 + 128 + 2187 + 279936 = 282252$. These two numbers look unrelated — one is small,
the other is enormous. But subtract them: $282252 - 252 = 282000$, and $282000 = 120 \times 2350$.
It divides evenly by $120$.

Try it again with any number you like. Take $n = 10$: the sum of cubes of divisors is
$1 + 8 + 125 + 1000 = 1134$, the sum of seventh powers is
$1 + 128 + 78125 + 10000000 = 10078254$, and their difference is $10077120 = 120 \times 83976$.
Again divisible by $120$. This is not luck. For *every* whole number $n$, the sum of the
seventh powers of its divisors and the sum of the cubes of its divisors differ by an exact
multiple of $120$. In the compact language of number theory, writing
$\sigma_k(n)$ for the sum of the $k$-th powers of the divisors of $n$,

$$\sigma_7(n) \equiv \sigma_3(n) \pmod{120} \quad \text{for all } n.$$

Where does the mysterious $120$ come from? The answer is a beautiful story that begins far
away, in the theory of highly symmetric functions on the complex plane, and ends with a
completely elementary fact that a curious student could rediscover with a pocket calculator.

## The rigidity of a symmetric world

There is a family of functions, called *modular forms*, that are so symmetric they are almost
impossible to build. A modular form is a function on the upper half of the complex plane that
repeats itself under a large group of transformations. These symmetry constraints are so severe
that, for each "weight" (a number measuring how the function scales), only a tiny, finite-dimensional
space of them exists.

The remarkable thing is what happens at weight $8$: there is essentially **only one** modular form,
up to scaling. That single degree of freedom has an immediate consequence. There is a natural
weight-$4$ form, traditionally called $E_4$, and a natural weight-$8$ form, called $E_8$. Squaring
$E_4$ doubles its weight to $8$ — so $E_4^2$ is also a weight-$8$ form. But since the space of
weight-$8$ forms is one-dimensional, and both $E_4^2$ and $E_8$ start with the constant term $1$,
they must be *the very same function*:

$$E_4^2 = E_8.$$

This is one of the most elegant identities in the subject. And it is not just an abstract equality —
each of these forms carries an explicit numerical fingerprint, a series expansion whose coefficients
are divisor sums.

## Reading the fingerprints

Both $E_4$ and $E_8$ can be written as power series in a variable $q$:

$$E_4 = 1 + 240\sum_{n\ge 1} \sigma_3(n)\, q^n, \qquad E_8 = 1 + 480 \sum_{n \ge 1}\sigma_7(n)\, q^n.$$

The coefficient of $q^n$ in $E_4$ is built from $\sigma_3$; the coefficient in $E_8$ is built from
$\sigma_7$. Now impose the identity $E_4^2 = E_8$. Squaring the series for $E_4$ multiplies it out
term by term; matching the coefficient of $q^n$ on both sides, and dividing through by $480$, produces
a startlingly clean equation:

$$\sigma_7(n) = \sigma_3(n) + 120 \sum_{i=1}^{n-1} \sigma_3(i)\, \sigma_3(n-i).$$

Read this carefully. It says the sum of seventh powers of divisors equals the sum of cubes of divisors,
*plus* $120$ times a self-interaction term — the "convolution" of $\sigma_3$ with itself. Because that
convolution is always a whole number, the correction is always a whole multiple of $120$. Strip away the
convolution and only the divisibility remains:

$$\sigma_7(n) \equiv \sigma_3(n) \pmod{120}.$$

So the elementary curiosity we noticed with a calculator is nothing less than the arithmetic shadow of a
deep symmetry principle. The $120$ is not arbitrary — it is the exact weight the theory of modular forms
assigns to the gap between two Eisenstein coefficient systems.

## Coming back down to earth

Here is the twist that makes the story satisfying: once you *know* the fact, you no longer need the modular
forms to prove it. The whole congruence collapses onto a single, humble observation about integers:

> For every integer $d$, the number $d^7 - d^3$ is divisible by $120$.

Why is this true? Factor it: $d^7 - d^3 = d^3(d^4 - 1) = d^3(d-1)(d+1)(d^2+1)$. Among any run of consecutive
integers you are guaranteed certain factors of $2$, $3$, and $5$; a short check confirms that the product is
always divisible by $8$, by $3$, and by $5$, hence by their product $120$. One can verify the statement once
and for all simply by checking every residue class modulo $120$ — a finite computation.

From here a single idea finishes everything. A divisor sum $\sigma_k(n)$ is just a sum of $k$-th powers, one
for each divisor $d$ of $n$. If $d^7 - d^3$ is divisible by $120$ *for each individual divisor*, then adding
these differences over all divisors keeps the divisibility intact:

$$\sigma_7(n) - \sigma_3(n) = \sum_{d \mid n} \left(d^7 - d^3\right),$$

and every summand is a multiple of $120$, so the total is too. This "transfer principle" — any pointwise power
congruence automatically becomes a divisor-sum congruence — is the real engine of the story. It turns a
one-line fact about integers into a statement about the intricate coefficients of modular forms, no advanced
machinery required.

## Why exactly 120, and not more?

A skeptic might ask: maybe the difference is *always* divisible by something bigger, like $240$, and $120$ is
just an undersell. It is not. The number $120$ is the sharpest possible modulus — the largest number that
divides $\sigma_7(n) - \sigma_3(n)$ for **all** $n$ simultaneously. The proof is a single example. Take $n = 2$:
its divisors are $1$ and $2$, so $\sigma_3(2) = 1 + 8 = 9$ and $\sigma_7(2) = 1 + 128 = 129$, giving a difference
of exactly $120$. Any modulus that divides the difference for all $n$ must in particular divide this value $120$,
so it can be at most $120$. The bound is achieved, and the constant is pinned down with no room to spare.

The same mechanism produces a whole family of siblings. Replace seventh powers with fifth powers and the magic
number changes to $24$:

$$\sigma_5(n) \equiv \sigma_3(n) \pmod{24}, \quad \text{and } 24 \text{ is sharp}.$$

Again the witness is $n = 2$: $\sigma_5(2) = 1 + 32 = 33$, and $33 - 9 = 24$. This weight-$6$ analogue is the
arithmetic shadow of another rigidity statement, one weight lower. The pattern strongly suggests an entire
hierarchy of such congruences, one for each odd exponent, with an optimal modulus governed by the same deep
constants — the Bernoulli numbers — that control Eisenstein series across all weights.

## A bridge to the geometry of space

The story has one more surprise. Multiply the congruence through by $240$ — the factor that normalizes the
$E_8$ series — and you obtain

$$240\,\sigma_7(n) - 240\,\sigma_3(n) \equiv 0 \pmod{28800}, \qquad 28800 = 240 \times 120.$$

Why would anyone care about $240 \cdot \sigma_7$ or $240 \cdot \sigma_3$? Because these are exactly the numbers
that count vectors in some of the most beautiful lattices in mathematics. In dimension $16$ there are precisely
two "even unimodular" lattices — the packing $E_8 \oplus E_8$ and a second one called $D_{16}^+$. Counting how many
lattice vectors have a given squared length produces sequences built from $\sigma_7$ and $\sigma_3$. Our purely
arithmetic congruence says these two lattices' vector counts must agree modulo $28800$ at every length — a
geometric fact about how densely one can pack spheres, deduced from nothing more than the divisibility of
$d^7 - d^3$.

## A family, not a coincidence

Once the mechanism is laid bare, the single congruence stops looking like an
isolated curiosity and starts looking like the first entry in a catalogue. Every
congruence of the form "$\sigma_j(n)$ and $\sigma_k(n)$ always differ by a
multiple of $M$" is *equivalent* to the purely local statement "$M$ divides
$a^j - a^k$ for every integer $a$." And that local statement has an answer we can
write down: the best possible $M$ is the greatest common divisor of all the
numbers $a^j - a^k$ as $a$ ranges over the integers,

$$M_{j,k} = \gcd_a\left(a^j - a^k\right).$$

For $j = 7, k = 3$ this gcd is $120$; for $j = 5, k = 3$ it is $24$; push to
$j = 9$ and it becomes $504$. These numbers are not random. They are governed by
the denominators that appear when one writes down Eisenstein series of increasing
weight — the denominators of the Bernoulli numbers, the same universal constants
that surface in the sum of $k$-th powers, in the values of the Riemann zeta
function at even integers, and in the geometry of high-dimensional spheres. The
humble observation about divisor sums is a window onto one of the deepest
recurring patterns in mathematics.

There is also something pleasing about the *economy* of the argument. To prove a
statement about the coefficients of modular forms — objects defined by infinitely
many symmetry constraints on the complex plane — we never had to leave the
integers. A finite check, a factorization, and one line about summing over
divisors did all the work. The transcendental identity supplied the *inspiration*;
elementary arithmetic supplied the *proof*, and even improved on it, by certifying
that the constant is the best possible.

## The moral of the number 120

What began as a calculator curiosity — two wildly different divisor sums always differing by a multiple of
$120$ — turns out to be a message in a bottle from the theory of modular forms. The rigidity of a symmetric
world forced an identity, $E_4^2 = E_8$; that identity left an arithmetic residue, $\sigma_7 \equiv \sigma_3
\pmod{120}$; and that residue can be recovered, sharpened, and generalized entirely by elementary means, then
carried back into the geometry of high-dimensional lattices. The number $120$ is small, but it remembers where
it came from.
