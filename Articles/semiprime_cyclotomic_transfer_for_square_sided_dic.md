# The Dice That Lie: How Cyclotomic Numbers Rebuild Chance

Imagine you sit down to play a game. On the table are two ordinary dice — but
not the cubes you know. One has $36$ faces, numbered $1$ through $36$. The other
has $4$ faces, numbered $1$ through $4$. You roll them, add the two numbers, and
read off a total somewhere between $2$ and $40$.

Now suppose a stranger hands you a *different* pair. The first die still has $36$
faces and the second still has $4$, but the numbers painted on them are scrambled
in a strange way. Some faces repeat; some numbers are missing entirely. You roll
this second pair, add them up — and the totals come out with **exactly the same
odds** as before. Total $17$ is just as likely. Total $31$ is just as likely.
Every single outcome lands with identical probability.

Are the two pairs the same? No. The faces are genuinely different. Yet they are
statistically indistinguishable. You could never tell them apart by playing the
game, only by turning the dice over and reading the labels.

This is not a parlor trick. It is a window into one of the most elegant bridges
in mathematics — the place where the geometry of *roots of unity* quietly governs
the arithmetic of chance. This article tells the story of a single, fully
worked-out example of that phenomenon, and the beautiful machinery that makes it
tick.

## Dice as polynomials

The first idea is old and powerful: **a die is a polynomial.**

Take a fair six-sided die. Its faces are $1, 2, 3, 4, 5, 6$. Encode it as

$$S_6 = x^1 + x^2 + x^3 + x^4 + x^5 + x^6.$$

Each face becomes a power of a placeholder variable $x$, and the coefficient in
front of $x^k$ counts how many faces show the number $k$. A standard $N$-sided die
with faces $1, 2, \dots, N$ becomes the polynomial

$$S_N = x^1 + x^2 + \dots + x^N = \sum_{i=1}^{N} x^i.$$

Why bother? Because of a small miracle. When you roll two dice and *add* their
results, the polynomial that describes the combined outcome is exactly the
*product* of the two individual polynomials. Multiplying

$$\big(x^{a_1} + x^{a_2} + \dots\big)\big(x^{b_1} + x^{b_2} + \dots\big)$$

produces a term $x^{a_i + b_j}$ for every way of choosing one face from each die.
Collect like terms, and the coefficient of $x^s$ counts precisely the number of
ways to roll a total of $s$. The distribution of sums *is* the product
polynomial.

So the question "do two pairs of dice produce the same totals with the same
frequencies?" becomes a crisp algebraic statement: *do the two products of
polynomials agree?* And suddenly the whole problem can be attacked with the
toolkit of factorization — the same toolkit we use to break integers into primes.

## The hidden factory inside a die

Here is where the magic begins. The die polynomial $S_N$ is not a random object;
it has a rigid internal skeleton. Watch:

$$S_N = x + x^2 + \dots + x^N = x \cdot \frac{x^N - 1}{x - 1}.$$

The fraction on the right is famous. The numerator $x^N - 1$ factors completely
into building blocks called **cyclotomic polynomials**, written $\Phi_d$, one for
each divisor $d$ of $N$:

$$x^N - 1 = \prod_{d \mid N} \Phi_d(x).$$

The cyclotomic polynomial $\Phi_d$ is the "irreducible atom" whose roots are
exactly the *primitive* $d$-th roots of unity — the complex numbers that you must
raise to the $d$-th power, and no smaller power, to get back to $1$. These atoms
are the prime factors of the algebra of rotations.

After cancelling the $\Phi_1 = x - 1$ that lives in the denominator, the die
polynomial reveals its true factored form:

$$S_N = x \prod_{\substack{d \mid N \\ d > 1}} \Phi_d(x).$$

A die, in other words, is a *product of cyclotomic atoms*, one for each divisor of
$N$ greater than $1$, with a lone factor of $x$ out front. The faces you see when
you hold the die are just the expanded surface of this deep factored structure.

For our story, the star atom is the **sixth cyclotomic polynomial**:

$$\Phi_6(x) = x^2 - x + 1.$$

Its two roots are the primitive sixth roots of unity, the complex numbers sitting
at $60$ degrees around the unit circle. This little quadratic is the engine of
everything that follows.

## The transfer: moving an atom from one die to another

Now we can describe the trick precisely. We start with two honest **square**
dice — square because their sizes are perfect squares. Take $m = 6$ and $n = 2$,
so the sizes are $m^2 = 36$ and $n^2 = 4$. The standard pair is

$$S_{36} = x + x^2 + \dots + x^{36}, \qquad S_4 = x + x^2 + x^3 + x^4.$$

Their product $S_{36} \cdot S_4$ encodes the joint distribution of totals.

Both factors are made of cyclotomic atoms. The big die $S_{36}$ contains the atom
$\Phi_6$ inside it (because $6$ divides $36$). The small die $S_4$ does *not* — the
divisors of $4$ greater than $1$ are just $2$ and $4$, so $S_4$ holds only
$\Phi_2$ and $\Phi_4$.

Here is the move. We **transfer** the atom $\Phi_6$ from the big die to the small
die:

- Divide it out of the big one: define $P = S_{36} / \Phi_6$.
- Multiply it into the small one: define $Q = S_4 \cdot \Phi_6$.

Because we removed exactly what we added, the product is untouched:

$$P \cdot Q = \frac{S_{36}}{\Phi_6} \cdot \big(S_4 \cdot \Phi_6\big) = S_{36} \cdot S_4.$$

The joint distribution of totals is *identical*. But are $P$ and $Q$ still
legitimate dice? That is the whole question — and it is not automatic. A genuine
die polynomial must have **nonnegative integer coefficients** (you cannot have
$-2$ faces showing a $7$), and the number of faces, found by setting $x = 1$,
must come out right. The transfer is only valid if both new polynomials pass this
test.

## Reading the new dice

Let us look at what the transfer actually produced.

The small die first. Multiply out $Q = \Phi_6 \cdot S_4$:

$$Q = (x^2 - x + 1)(x + x^2 + x^3 + x^4).$$

Carefully collecting terms — the negative middle term $-x$ does its delicate work
of cancellation — gives

$$Q = x + x^3 + x^4 + x^6.$$

Every coefficient is $0$ or $1$, all nonnegative. Setting $x = 1$ gives $4$, so it
is still a $4$-sided die. But its faces are no longer $1, 2, 3, 4$. They are

$$\boxed{\{\,1,\ 3,\ 4,\ 6\,\}}.$$

A perfectly ordinary-looking tetrahedron with peculiar labels.

Now the big die. The polynomial $P = S_{36} / \Phi_6$ has a gorgeous repetitive
structure. It is built from six identical "blocks," each one a shifted copy of a
single fixed pattern. Block number $j$ (for $j = 0, 1, 2, 3, 4, 5$) is

$$\text{block}(j) = x^{6j+1} + 2x^{6j+2} + 2x^{6j+3} + x^{6j+4},$$

and the full die is their sum:

$$P = \sum_{j=0}^{5} \text{block}(j).$$

Read off the faces: within each block of six consecutive values, the first and
fourth appear once, while the second and third appear *twice*. So this $36$-faced
die shows the numbers $1, 4, 7, 10, \dots$ once each, and the numbers
$2, 3, 8, 9, \dots$ twice each. Every coefficient is $1$ or $2$ — all nonnegative.
Setting $x = 1$ gives $6 \times (1 + 2 + 2 + 1) = 6 \times 6 = 36$ faces, exactly
as required.

Both new polynomials are legitimate dice. The transfer is valid. We have built a
nonstandard pair of square-sided dice — sizes $36$ and $4$ — that is provably
indistinguishable from the standard pair by any amount of play.

## Why the block pattern works

The single most satisfying part of the story is *why* the big die splits into
those tidy blocks. It comes down to one local identity. Multiply the fundamental
pattern by the cyclotomic atom:

$$\Phi_6 \cdot \big(x + 2x^2 + 2x^3 + x^4\big) = x + x^2 + x^3 + x^4 + x^5 + x^6.$$

Try it: the $x^2 - x + 1$ acting on the pattern $1, 2, 2, 1$ telescopes into six
consecutive ones. A clump of weights $1, 2, 2, 1$ is exactly what $\Phi_6$ turns
into a flat run of six. Shift this identity by multiples of six, and each block
$\text{block}(j)$ gets sent by $\Phi_6$ to the six consecutive monomials
$x^{6j+1} + \dots + x^{6j+6}$. Lay the six shifted runs end to end and they tile
the numbers $1$ through $36$ with no gaps and no overlaps:

$$\Phi_6 \cdot P = \Phi_6 \cdot \sum_{j=0}^{5}\text{block}(j) = \sum_{j=0}^{5}\big(x^{6j+1} + \dots + x^{6j+6}\big) = x + x^2 + \dots + x^{36} = S_{36}.$$

That is the heart of the matter, an identity you can check by hand in a minute,
and it certifies that $P$ really is $S_{36}/\Phi_6$ with honest nonnegative
coefficients.

## The bigger picture: a conjecture about primes

This worked example is the smallest case of a sweeping conjecture. The numbers
$6$ and $2$ are not arbitrary: $6 = 2 \times 3$ is a product of two distinct
primes — a *semiprime* — and the atom we transferred was $\Phi_6 = \Phi_{2\cdot 3}$.

The general conjecture says: pick two distinct primes $p < q$. Pick sizes $m$ and
$n$ so that the product $pq$ divides $m$, and so that $n$ is large enough (the
precise threshold being $n^2 \ge (p-1)(q-1) + 1$). Then the *cyclotomic transfer*

$$P = \frac{S_{m^2}}{\Phi_{pq}}, \qquad Q = S_{n^2}\cdot \Phi_{pq}$$

should always yield a valid nonstandard pair of square-sided dice of sizes $m^2$
and $n^2$: both polynomials nonnegative, $P(1) = m^2$, $Q(1) = n^2$, and the
product $P \cdot Q = S_{m^2}\cdot S_{n^2}$ preserved exactly. A *counterexample*
would be any admissible choice of $p, q, m, n$ for which one of these two explicit
polynomials sprouts a negative coefficient.

The case $p = 2$, $q = 3$, $m = 6$, $n = 2$ — the one we have walked through — is
the cornerstone. It is the first brick, fully laid and fully checked: the product
identity holds, the face counts are right, and not a single coefficient turns
negative. From here the natural questions cascade. Does the same block trick give
$\Phi_6 \cdot (\sum_{j<r}\text{block}(j)) = S_{6r}$ for *every* multiple of six,
not just $36$? Do other semiprimes — $\Phi_{10}, \Phi_{15}, \Phi_{21}$ — admit
their own block decompositions? Is there a clean, reusable principle that
guarantees $\Phi_d$ divides $S_N$ with a nonnegative quotient whenever $d$ divides
$N + 1$?

## The deeper resonance

What makes this story worth telling is not the dice. It is the *unreasonable
reach* of the cyclotomic atoms. These polynomials were invented to describe the
symmetry of a regular polygon — the way the corners of a hexagon map to one
another under rotation. They have nothing, on their face, to do with gambling or
probability. And yet here they are, silently dictating which relabelings of a die
preserve the odds and which destroy them.

This is a recurring theme in mathematics: a structure built for one purpose turns
out to be the secret grammar of something utterly unrelated. The integers factor
into primes; polynomials factor into cyclotomic atoms; and the act of *rearranging
those atoms* is the act of building dice that lie — dice that look different,
behave identically, and reveal, in their quiet impossibility, the unity beneath
arithmetic and chance.

The next time you pick up a die, remember: hidden inside those faces is a product
of roots of unity, waiting to be rearranged.
