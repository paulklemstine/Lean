# Alien Number Systems: Counting Beyond Base Ten

Imagine a spacecraft descends, a hatch opens, and out steps a civilization
that has never once counted on ten fingers. Perhaps they have eight limbs, like
an octopus, and think naturally in eights. Perhaps they measure the year in
twelve moons and prefer a dozen. Or perhaps — and this is where mathematics
gets genuinely strange — they long ago abandoned the idea that a "base" must be
a positive whole number at all. What would their arithmetic look like?

The surprising answer is that we can already write down, and rigorously prove
things about, several of these exotic systems. You can build a perfectly
consistent arithmetic on a *negative* base, on a *complex* base, or on an
*irrational* base. Each of these systems does something that ordinary base ten
cannot, and each is beautiful for a different reason. This article tells the
story of two of them in detail: **negabinary**, the number system built on the
base $-2$, and **phinary**, the system built on the golden ratio
$\varphi = \tfrac{1+\sqrt 5}{2}$.

## The problem with a minus sign

Ordinary positional notation is a wonderful invention. The string $1011$ in
base $2$ means
$$1\cdot 2^3 + 0\cdot 2^2 + 1\cdot 2^1 + 1\cdot 2^0 = 11.$$
Every digit sits above a power of the base, and you add up the pieces. But
ordinary bases have a blind spot: with digits $\{0,1\}$ and powers of $2$, every
value you can build is non-negative. To write $-11$ you must bolt on a separate
symbol, the minus sign, which is not really a digit at all — it is an
annotation that lives outside the number.

Negative numbers are, in a sense, second-class citizens of base ten. Alien
number systems can promote them. Consider what happens if we keep the digits
$\{0,1\}$ but change the base from $2$ to $-2$. Now the string $d_k \ldots d_1 d_0$
means
$$\sum_{i} d_i \,(-2)^i,$$
and because the powers of $-2$ alternate in sign
$$(-2)^0=1,\quad (-2)^1=-2,\quad (-2)^2=4,\quad (-2)^3=-8,\quad (-2)^4=16,\ \ldots$$
we suddenly have *negative building blocks for free*. For instance
$$11_{(-2)} = 1\cdot(-2) + 1\cdot 1 = -1,$$
so the number *negative one* is written with no minus sign at all. Similarly
$$110_{(-2)} = 1\cdot 4 + 1\cdot(-2) + 0 = 2, \qquad 111_{(-2)} = 4 - 2 + 1 = 3.$$

This system is called **negabinary**. Its central promise is a bold one, and it
turns out to be exactly true.

> **The Negabinary Representation Theorem.** *Every integer — positive,
> negative, or zero — has one and only one representation in base $-2$ using the
> digits $0$ and $1$.*

No sign bit. No special case for negatives. A single alphabet of two symbols
names all of $\mathbb{Z}$, each integer exactly once. That is something base ten
simply cannot do.

## Why the theorem is true (and why it is subtle)

There are two halves to prove: that *every* integer can be written, and that no
integer can be written *twice*. Both hinge on one humble observation about
parity.

Look at the last digit. Every power $(-2)^i$ for $i \ge 1$ is even, so the value
of any negabinary string has the *same parity as its final digit*. If the
number you are representing is even, the last digit is forced to be $0$; if odd,
it is forced to be $1$. There is no choice. Once you subtract off that last
digit and divide by $-2$, you are left with a smaller sub-problem of exactly the
same shape, and you repeat. Because the final digit is pinned down at every
step, the representation is **unique**: there is never a fork in the road.

Existence is where negative bases hide their one real difficulty. In ordinary
base $2$, you prove every number is representable by noting that dividing by the
base makes the number smaller, so the process must stop. In base $-2$ this
naive argument breaks. Watch what the "peel off a digit and divide" step does to
$-1$: it sends $-1 \mapsto 1 \mapsto -1 \mapsto 1 \mapsto \cdots$, ping-ponging
forever if you measure size by absolute value. The number never shrinks.

The fix is a clever way of *measuring* integers so that the base-$(-2)$ step
genuinely makes progress. Instead of ranking integers by magnitude, we
interleave the positive and negative half-lines into a single queue,
$$0,\ -1,\ 1,\ -2,\ 2,\ -3,\ 3,\ \ldots,$$
assigning each integer a position in this list. Under this ranking, one step of
the negabinary algorithm always moves you *strictly earlier* in the queue, so it
cannot ping-pong and must terminate. This interleaving is the whole secret of
negative bases: absolute value is the wrong ruler, and a zig-zag ruler is the
right one.

## A base that is not even a whole number

If a negative base feels exotic, an *irrational* one feels almost paradoxical.
Yet the most elegant alien system of all is built on the golden ratio
$$\varphi = \frac{1+\sqrt 5}{2} \approx 1.618\ldots,$$
the famous proportion that appears in sunflower seeds, pinecones, and the
rectangles beloved by Renaissance painters. In **phinary**, the string with
digits $d_i \in \{0,1\}$ means
$$\sum_i d_i \,\varphi^{\,i},$$
allowing positions both to the left and to the right of the "phinary point,"
just as ordinary decimals allow digits after the decimal point.

The single algebraic fact that makes the golden ratio special is the equation it
was born to satisfy:
$$\varphi^2 = \varphi + 1.$$
Read in the language of positions, this says something magical. It says that a
$1$ in place $n$ plus a $1$ in the next place up equals a single $1$ two places
higher:
$$\varphi^{\,n} + \varphi^{\,n+1} = \varphi^{\,n+2}.$$
In digit-string form, $011 = 100$. This is the **carry rule** of the golden-ratio
base, and it is entirely responsible for phinary's signature feature:

> **The No-Consecutive-Ones Property.** *Every positive integer can be written
> in base $\varphi$ using only the digits $0$ and $1$, arranged so that no two
> $1$s ever sit side by side.*

Whenever an expansion threatens to place two $1$s next to each other, the carry
rule collapses them upward, $011 \to 100$, and the adjacency disappears. The
rule can be applied over and over until every neighboring pair of ones is gone.
The "beautiful" number system, in which forbidden patterns melt away on
contact, owes its beauty to a single quadratic equation.

As a concrete taste, the number $3$ has the tidy phinary expansion
$$3 = \varphi^2 + \varphi^{-2} = 100.01_{(\varphi)},$$
one digit to the left of the point and one to the right — no two ones adjacent,
exactly as promised. (You can check it: $\varphi^2 = \varphi + 1 \approx 2.618$
and $\varphi^{-2} \approx 0.382$, and they sum to $3$ on the nose.)

## The hidden Fibonacci machinery

Why should an irrational base ever produce a clean whole number like $3$? The
answer reveals a beautiful bridge between the continuous world of $\varphi$ and
the discrete world of counting.

Every phinary value built from *non-negative* powers of $\varphi$ turns out to
live in the two-dimensional world of numbers of the form $a\varphi + b$ with $a$
and $b$ whole numbers. And the coordinates $a$ and $b$ are not random — they are
**sums of Fibonacci numbers**, the sequence $1, 1, 2, 3, 5, 8, 13, \ldots$ in
which each term is the sum of the two before it. Precisely, if you switch on the
digits in a set $S$ of positions, then
$$\sum_{i\in S}\varphi^{\,i+1} = \Big(\sum_{i\in S} F_{i+1}\Big)\varphi \;+\; \sum_{i\in S} F_i,$$
where $F_i$ is the $i$-th Fibonacci number. The golden ratio and Fibonacci
numbers are two faces of the same coin, and phinary is where they shake hands.

This also explains why $3$ needed a digit *after* the point. A value made only
from non-negative powers is a whole number precisely when its $\varphi$-coordinate
(the Fibonacci sum multiplying $\varphi$) cancels to zero — and for that you
generally need the *symmetric* combinations of $\varphi$ with its algebraic twin
$\psi = \tfrac{1-\sqrt5}{2}$. Those symmetric combinations are exactly the
**Lucas numbers**, cousins of the Fibonacci sequence, and they satisfy the clean
identity
$$\varphi^{\,n+1} + \psi^{\,n+1} = F_{n+2} + F_n,$$
whose right-hand side is always a whole number. To hit an arbitrary integer with
digits $\{0,1\}$, you must reach across the phinary point and use negative
powers too — which is precisely why $3 = \varphi^2 + \varphi^{-2}$ and not
something one-sided.

## Uniqueness, and the role of irrationality

There is one more twist that shows how delicately these systems are balanced.
The reason phinary coordinates are meaningful at all is that a number of the form
$a\varphi + b$ pins down $a$ and $b$ **uniquely** — but only when $a$ and $b$ are
rational.

> **Coordinate Uniqueness.** *If $a\varphi + b = c\varphi + d$ with $a,b,c,d$
> rational, then $a=c$ and $b=d$.*

The proof is a two-line gem. If $a \ne c$, rearranging gives
$\varphi = (d-b)/(a-c)$, a ratio of rationals — which would make $\varphi$
rational. But $\varphi = (1+\sqrt5)/2$ is irrational, because $\sqrt 5$ is. The
contradiction forces $a=c$, and then $b=d$ follows. Remarkably, the *analytic*
fact that $\varphi$ is irrational is exactly what guarantees the *algebraic*
well-definedness of phinary coordinates. Over the reals the statement collapses —
every real number can be written as $a\varphi + b$ in infinitely many ways — so
rationality is not a technicality but the load-bearing wall.

## So what would the aliens choose?

Return to our visitors. If they value *symmetry between positive and negative*,
they might well count in negabinary, where a minus sign is an unnecessary crutch
and every integer stands on equal footing. If they prize *aesthetic economy* and
delight in forbidden patterns that cannot occur, they might build their
arithmetic on the golden ratio, letting the equation $\varphi^2=\varphi+1$ do the
policing. A more practical species might simply have eight arms and settle on
base eight, or twelve moons and settle on a dozen — sensible, but far less
adventurous.

The deeper lesson is that base ten is a biological accident, not a mathematical
law. The rules of arithmetic are robust enough to survive being rebuilt on a
negative number, on the golden ratio, even on the complex number $i-1$ (where the
very same "residue fixes the next digit, quotient shrinks" recipe conjecturally
lets the Gaussian integers be written in binary). Counting, it turns out, is a
far larger country than our ten fingers ever let us see — and much of its
landscape is already mapped, waiting for anyone, human or otherwise, willing to
count a little differently.
