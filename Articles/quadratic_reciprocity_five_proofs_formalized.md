# The Golden Theorem, Twice: How One Law Hides in Geometry and in Algebra

Some facts in mathematics are so important that their discoverers prove them
again and again, as if circling a mountain to photograph it from every angle.
Carl Friedrich Gauss called one such fact the *theorema aureum* — the **golden
theorem**. Over his lifetime he found eight different proofs of it. Today there
are more than two hundred. The statement they all converge on is the **Law of
Quadratic Reciprocity**, and it is one of the most beautiful surprises in all of
number theory.

This article tells the story of that law and then walks through two of its proofs
that could not look more different on the surface — one built from **counting dots
in a rectangle**, the other from a piece of **algebraic sorcery involving roots of
unity** — and shows how both arrive at exactly the same conclusion.

## A simple question with a strange answer

Start with a prime number $p$, say $p = 7$. Now ask: *which numbers are perfect
squares, if we only care about remainders after dividing by $7$?*

Squaring $1, 2, 3, 4, 5, 6$ and reducing modulo $7$ gives
$$1, 4, 2, 2, 4, 1.$$
So the nonzero "squares mod $7$" are exactly $\{1, 2, 4\}$. The numbers $3, 5, 6$
are *not* squares mod $7$. We call $1, 2, 4$ the **quadratic residues** of $7$,
and $3, 5, 6$ the **non-residues**.

Mathematicians compress this into a tidy symbol, the **Legendre symbol**, written
$\left(\frac{a}{p}\right)$. It equals $+1$ if $a$ is a nonzero square modulo $p$,
$-1$ if $a$ is a non-square, and $0$ if $p$ divides $a$. For example
$\left(\frac{2}{7}\right) = +1$ because $2$ is a square mod $7$, while
$\left(\frac{3}{7}\right) = -1$.

Here is the question that launched a thousand proofs. Take two different odd
primes, $p$ and $q$. There are two natural things to ask:

- Is $q$ a square modulo $p$? That is, what is $\left(\frac{q}{p}\right)$?
- Is $p$ a square modulo $q$? That is, what is $\left(\frac{p}{q}\right)$?

These look like two completely separate questions. Whether $q$ happens to be a
square in the world of remainders mod $p$ seems to have nothing to do with whether
$p$ is a square in the entirely different world of remainders mod $q$. And yet —
astonishingly — **the two answers are locked together**.

## The golden theorem

The Law of Quadratic Reciprocity says that for distinct odd primes $p$ and $q$,
$$\left(\frac{q}{p}\right)\left(\frac{p}{q}\right) = (-1)^{\frac{p-1}{2}\cdot\frac{q-1}{2}}.$$

Read that right-hand side carefully, because it is the whole secret. The exponent
is a product of two halves. If *either* $p$ or $q$ leaves remainder $1$ when
divided by $4$, then one of the two fractions $\frac{p-1}{2}$ or $\frac{q-1}{2}$
is even, the exponent is even, and the right side is $+1$. In that case the two
questions have the **same** answer: $q$ is a square mod $p$ exactly when $p$ is a
square mod $q$.

Only when **both** primes leave remainder $3$ mod $4$ does the exponent become
odd, making the right side $-1$. In that single case the two questions have
**opposite** answers.

Let's see it work. Take $p = 7$ and $q = 5$. We computed that the squares mod $7$
are $\{1,2,4\}$, so $5$ is *not* among them: $\left(\frac{5}{7}\right) = -1$.
Going the other way, the squares mod $5$ are $\{1, 4\}$, and $7 \equiv 2 \pmod 5$,
which is not a square mod $5$, so $\left(\frac{7}{5}\right) = -1$. Their product is
$(-1)(-1) = +1$. And the law predicts $+1$, because $5 \equiv 1 \pmod 4$. The
prophecy holds.

Now take two primes that are both $3$ mod $4$, say $p = 7$ and $q = 3$. The
squares mod $7$ are $\{1,2,4\}$, so $3$ is a non-residue:
$\left(\frac{3}{7}\right) = -1$. But mod $3$, the only nonzero square is $1$, and
$7 \equiv 1 \pmod 3$, so $\left(\frac{7}{3}\right) = +1$. The product is
$(-1)(+1) = -1$, exactly as the law demands when both primes are $3$ mod $4$.

This is the kind of statement that feels like a magic trick. Two independent-looking
worlds turn out to be reflections of each other. The remainder of this article is
about *why* — told through two utterly different explanations.

## Two warm-up laws

Before the main event, there are two smaller "supplementary" facts that the same
theory delivers as a bonus, and they have a clean elementary flavor.

The first answers: *when is $-1$ a square modulo $p$?* The answer depends only on
$p$ modulo $4$:
$$\left(\frac{-1}{p}\right) = +1 \iff p \equiv 1 \pmod 4.$$
So $-1$ is a square mod $5$ (indeed $2^2 = 4 \equiv -1$) and mod $13$, but not mod
$7$ or mod $11$.

The second answers: *when is $2$ a square modulo $p$?* Here the deciding factor is
$p$ modulo $8$:
$$\left(\frac{2}{p}\right) = +1 \iff p \equiv \pm 1 \pmod 8.$$
So $2$ is a square mod $7$ (we saw $3^2 = 9 \equiv 2$) and mod $17$, but not mod
$3$, $5$, $11$, or $13$.

These two "supplementary laws" are the appetizers. The main course is reciprocity
itself.

## First proof: counting dots in a rectangle

The first proof, due to Gotthold Eisenstein, is so visual you can almost draw it
on graph paper. Its surprise is that a deep statement about squares and remainders
turns out to be, at heart, a problem of **counting lattice points** — the grid of
integer-coordinate dots in the plane.

The starting observation is a formula that converts a Legendre symbol into a
parity count. For distinct odd primes $p$ and $q$,
$$\left(\frac{q}{p}\right) = (-1)^{\,S}, \qquad S = \sum_{x=1}^{(p-1)/2} \left\lfloor \frac{xq}{p} \right\rfloor,$$
where $\lfloor \cdot \rfloor$ is the floor function (round down to the nearest
integer). In words: walk through the values $x = 1, 2, \dots, \frac{p-1}{2}$,
compute $\lfloor xq/p \rfloor$ for each, add them all up, and the *parity* of that
sum — even or odd — decides whether $q$ is a square mod $p$.

What does $\lfloor xq/p \rfloor$ actually count? Picture the straight line
$y = \frac{q}{p}x$ in the plane. For a fixed column $x$, the quantity
$\lfloor xq/p\rfloor$ is precisely the number of integer-height dots $(x, y)$ with
$1 \le y$ lying strictly **below** that line. So the sum $S$ counts all the lattice
points underneath the diagonal, inside the left half of a rectangle.

Now play the same game with the roles of $p$ and $q$ swapped. The companion
formula reads
$$\left(\frac{p}{q}\right) = (-1)^{\,T}, \qquad T = \sum_{y=1}^{(q-1)/2} \left\lfloor \frac{yp}{q} \right\rfloor,$$
and $T$ counts the lattice points to the **right** of the very same diagonal, in
the bottom half of the same rectangle.

Here is the punch line. Consider the rectangle whose interior integer points have
coordinates $1 \le x \le \frac{p-1}{2}$ and $1 \le y \le \frac{q-1}{2}$. It
contains exactly
$$\frac{p-1}{2}\cdot\frac{q-1}{2}$$
lattice points. Because $p$ and $q$ are distinct primes, the diagonal line
$y = \frac{q}{p}x$ never passes exactly through one of these grid points (that
would force $p$ to divide $x$, which is impossible in our range). So every single
point in the rectangle is either strictly below the diagonal or strictly above it —
no point sits on the fence. The points below are counted by $S$; the points above
are counted by $T$. Therefore
$$S + T = \frac{p-1}{2}\cdot\frac{q-1}{2}.$$

Multiply the two parity formulas together:
$$\left(\frac{q}{p}\right)\left(\frac{p}{q}\right) = (-1)^{S}(-1)^{T} = (-1)^{S+T} = (-1)^{\frac{p-1}{2}\cdot\frac{q-1}{2}}.$$
That is the golden theorem, falling out of nothing more than a rectangle cut by
its diagonal. The entire mystery of "why are these two worlds linked" becomes:
*because a rectangle splits into two triangular halves.* The formalized version of
this argument proves exactly the identity
$\left(\frac{q}{p}\right)\left(\frac{p}{q}\right) = (-1)^{\lfloor p/2\rfloor\lfloor q/2\rfloor}$,
with $\lfloor p/2\rfloor = \frac{p-1}{2}$ for odd $p$.

## Second proof: a magic square root of $\pm p$

The second proof abandons geometry entirely and reaches instead for one of the
most elegant objects in algebra: the **Gauss sum**. If Eisenstein's proof is a
draftsman's sketch, this one is a chemist's reaction.

Fix a prime $p$ and a primitive $p$-th root of unity $\zeta$ — a complex number
satisfying $\zeta^p = 1$ but $\zeta \neq 1$, sitting on the unit circle like one
vertex of a regular $p$-gon. Now form the weighted sum
$$g = \sum_{x} \left(\frac{x}{p}\right)\zeta^{x},$$
where $x$ runs over the residues mod $p$ and each term is the root of unity
$\zeta^x$ tagged with the sign $\left(\frac{x}{p}\right)$ that says whether $x$ is
a square. This is the **quadratic Gauss sum**. It looks like a chaotic jumble of
complex numbers pointing in all directions.

The miracle — the engine of the whole proof — is that when you **square** this
chaotic sum, almost everything cancels and you are left with something astonishingly
clean:
$$g^2 = \left(\frac{-1}{p}\right) p.$$
In words: the square of the Gauss sum is just $\pm p$, with the sign decided by
that first supplementary law. The wild combination of roots of unity is secretly a
*square root of $\pm p$*. (More generally, for any non-trivial quadratic character
$\chi$ of a finite field $F$ paired with a primitive additive character $\psi$,
the corresponding Gauss sum $g$ satisfies $g^2 = \chi(-1)\,|F|$, where $|F|$ is the
number of elements in the field — that is the exact identity the formal proof rests
on.)

This single fact is the bridge between the two primes. Here is the idea. To compare
$p$ and $q$, we don't work in the ordinary complex numbers; we work **modulo $q$**,
in a finite field of characteristic $q$. In that world there is a wonderful
shortcut called the Frobenius map: raising to the $q$-th power. Crucially, raising
a sum to the $q$-th power modulo $q$ behaves like applying it term-by-term — the
cross terms vanish — so the Frobenius map acts on our Gauss sum in a way that is
completely controlled by how the root of unity $\zeta$ gets permuted.

Chase the consequences. On one hand, raising $g$ to the $q$-th power shuffles the
exponents of $\zeta$ and pulls out a factor of $\left(\frac{q}{p}\right)$ — that is
how the question "is $q$ a square mod $p$?" enters. On the other hand, because
$g^2 = \pm p$, raising $g$ to the $q$-th power is the same as multiplying $g$ by
$(\pm p)^{(q-1)/2}$, and by an old result of Euler this power is exactly
$\left(\frac{\pm p}{q}\right)$ — that is how the *reverse* question "is $p$ a square
mod $q$?" enters. Setting the two computations of $g^q$ equal to each other, and
untangling the sign coming from the $\left(\frac{-1}{p}\right)$ factor, the
relationship between the two Legendre symbols pops out as precisely
$$\left(\frac{q}{p}\right)\left(\frac{p}{q}\right) = (-1)^{\frac{p-1}{2}\cdot\frac{q-1}{2}}.$$

Same destination, completely different vehicle. There are no rectangles, no lattice
points, no floors. Instead there is a single algebraic object — the Gauss sum —
that simultaneously "knows" about both primes and forces them into agreement.

## Why the two proofs together matter

It would be reasonable to ask: if we already have one airtight proof, why bother
with a second? The answer is that different proofs see different things.

Eisenstein's lattice-counting proof is *elementary and concrete*. It needs nothing
beyond floors, sums, and the observation that a rectangle has two triangular
halves. It explains reciprocity as a conservation law: the points below the
diagonal plus the points above equal the whole rectangle, and the rectangle's size
$\frac{p-1}{2}\cdot\frac{q-1}{2}$ is the source of the famous sign.

The Gauss-sum proof is *structural and far-reaching*. The object it builds, the
quadratic Gauss sum, is a square root of $\pm p$ living inside the world of $p$-th
roots of unity. That observation is the seed of a vast modern theory — it is the
degree-two shadow of what number theorists call class field theory and Artin
reciprocity, the framework that governs how primes split in algebraic number
fields. From this vantage point, quadratic reciprocity is not a curiosity about
squares and remainders; it is the simplest visible case of one of the deepest
organizing principles in mathematics.

That these two roads — pure counting and pure algebra — arrive at the identical
formula is itself a kind of meta-theorem. It tells us the golden theorem is not an
accident of any one technique. It is a genuine feature of the integers, robust
enough to be discovered from the geometry of a rectangle and from the algebra of
roots of unity alike. Gauss proved it eight times because each proof was a new
window onto the same landscape. Here we have opened two of those windows side by
side, and the view from both is the same: the squares modulo $p$ and the squares
modulo $q$ are, against all first impressions, two faces of a single coin.

## Try it yourself

Pick any two odd primes you like — $11$ and $13$, or $19$ and $23$ — and check the
law by hand. Compute the squares modulo each, read off the two Legendre symbols,
multiply them, and compare against $(-1)^{\frac{p-1}{2}\cdot\frac{q-1}{2}}$. The
prediction never fails. And when you tire of small cases, remember that the same
formula governs primes with hundreds of digits, the kind used in cryptography,
where deciding whether a number is a square modulo a prime is a routine but
indispensable computation. The golden theorem is more than two centuries old, and
it still does honest work every day.
