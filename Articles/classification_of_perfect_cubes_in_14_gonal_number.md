# When a Fourteen-Sided Counting Pattern Becomes a Perfect Cube

## Counting with shapes

Long before algebra had symbols, mathematicians counted with pebbles. Arrange
pebbles in a triangle and you get the *triangular numbers* $1, 3, 6, 10, \dots$
Arrange them in a square and you get the *square numbers* $1, 4, 9, 16, \dots$
These "figurate numbers" are among the oldest objects in mathematics, and they
hide a surprising amount of depth. Every square is a sum of two consecutive
triangles; every figurate family has its own personality; and every so often two
of these families collide in a way that nobody expected.

This article is about one such collision. On one side we have the
**tetradecagonal numbers** — the counting pattern for a polygon with fourteen
sides. On the other side we have the **perfect cubes** $0, 1, 8, 27, 64, 125,
\dots$, the volumes of cubical stacks of unit blocks. The question is simple to
state and famously hard to answer in general:

> **When is a fourteen-sided figurate number also a perfect cube?**

The answer turns out to be astonishingly clean. Among all the infinitely many
tetradecagonal numbers, **only three are perfect cubes**. After that, the cubes
and the fourteen-gons part ways forever.

## What is a tetradecagonal number?

For a regular polygon with $s$ sides, the $n$-th $s$-gonal number counts the dots
in a nested arrangement of $n$ such polygons sharing a corner. The general formula
is
$$
P_s(n) = \frac{(s-2)n^2 - (s-4)n}{2}.
$$
For triangles ($s=3$) this gives $P_3(n) = \tfrac{n(n+1)}{2}$; for squares ($s=4$)
it gives $P_4(n) = n^2$. Setting $s = 14$ and simplifying produces the family we
care about:
$$
P_{14}(n) = \frac{12n^2 - 10n}{2} = 6n^2 - 5n = n\,(6n - 5).
$$
The first few tetradecagonal numbers are
$$
0,\quad 1,\quad 14,\quad 39,\quad 76,\quad 125,\quad 186,\quad 259,\quad \dots
$$
Stare at this list for a moment. The first entry, $0$, is $0^3$. The second,
$1$, is $1^3$. And the sixth, $125$, is $5^3$. Three perfect cubes appear almost
immediately — and then, no matter how far you continue, never again.

## The main theorem

Here is the precise statement.

> **Theorem.** The only non-negative integers $n$ for which the tetradecagonal
> number $P_{14}(n) = n(6n-5)$ is a perfect cube are $n = 0$, $n = 1$, and
> $n = 5$. The corresponding cubes are $0 = 0^3$, $1 = 1^3$, and $125 = 5^3$.

In the language of Diophantine equations — polynomial equations where we insist on
whole-number solutions — this says that
$$
n(6n - 5) = t^3
$$
has exactly three non-negative solutions: $(n,t) = (0,0)$, $(1,1)$, and $(5,5)$.

Why should anyone believe such a thing? The list above could, for all we know,
contain a billionth cube hiding far out of sight. Diophantine equations are
notorious for this kind of behavior: a pattern that holds for the first thousand
cases can fail spectacularly at case $1{,}001$. To be *sure*, we need an argument
that controls all infinitely many $n$ at once. That argument rests on four ideas,
each beautiful in its own right.

## Idea 1: Two factors that barely touch

The tetradecagonal number factors as a product of two pieces, $n$ and $6n - 5$.
A natural first question is: how much can these two pieces share? If you compute
their greatest common divisor, something pleasant happens.

> **Lemma (Coprimality).** For every integer $n$,
> $$
> \gcd(n,\; 6n - 5) = \gcd(n,\; 5).
> $$

The reason is the oldest trick in number theory, the one behind the Euclidean
algorithm: subtracting a multiple of one number from another never changes their
greatest common divisor. Since $6n - 5$ is just $6 \cdot n$ minus $5$, removing the
$6n$ leaves $\gcd(n, -5) = \gcd(n, 5)$. The consequence is decisive: the **only**
prime the two factors can possibly share is $5$. Away from that single
troublesome prime, $n$ and $6n - 5$ are strangers.

## Idea 2: When strangers must both be cubes

Why does coprimality matter? Because of a small miracle of arithmetic: if two
coprime numbers multiply to a perfect cube, then each of them must *already* be a
perfect cube on its own. There is nowhere for prime factors to hide — each prime's
power lives entirely inside one factor, and a cube demands that every prime appear
a multiple of three times. So the cube structure can't be shared; it must be
present in both halves separately.

> **Lemma (Coprime cube splitting).** If $5 \nmid n$ and $n(6n - 5)$ is a perfect
> cube, then $n$ and $6n - 5$ are *each* perfect cubes: $n = a^3$ and
> $6n - 5 = b^3$ for some integers $a$ and $b$.

This is the engine of the whole proof in the "generic" case where $5$ does not
divide $n$. It converts one cube condition into two, and two cube conditions can be
combined. Substituting $n = a^3$ into $6n - 5 = b^3$ gives a single tidy equation,
$$
6a^3 - b^3 = 5,
$$
a so-called *Thue equation*. A deep theorem of Axel Thue guarantees that such
equations have only finitely many integer solutions, and a short search pins them
down — corralling the $5 \nmid n$ case entirely.

## Idea 3: The stubborn prime 5

What about the leftover case, when $5$ *does* divide $n$? Here the coprimality
trick breaks, precisely because $5$ is the one prime the two factors are allowed to
share. We need a different tool: the **5-adic valuation**, which simply asks "how
many times does $5$ divide this number?"

Write $n = 5m$. Then
$$
P_{14}(n) = 5m\,(30m - 5) = 25\,m\,(6m - 1).
$$
A factor of $25 = 5^2$ has appeared. Now, $6m - 1$ is never divisible by $5$
(it leaves remainder $4$ relative to $5$ whenever $m$ is), so the powers of $5$ in
$P_{14}(n)$ come from the $25$ and from $m$. If $m$ itself were free of the prime
$5$, the total power of $5$ would be exactly $2$. But a perfect cube can only have
prime powers that are multiples of $3$ — never exactly $2$. Contradiction.

> **Lemma (5-adic obstruction).** If $5 \mid n$, write $n = 5m$. Then for
> $n(6n - 5)$ to be a cube we must have $5 \mid m$ or $5 \mid (6m - 1)$. The
> second is impossible, so $5$ must divide $m$ as well.

This forces extra factors of $5$, and repeating the argument squeezes the
divisible case down to a handful of possibilities — among which $n = 5$ (giving
$125 = 5^3$) survives, and nothing larger does.

## Idea 4: A bridge to a famous curve

The three ideas above already corner the problem, but there is a fourth move that
connects this humble pebble-counting puzzle to one of the most studied objects in
modern number theory. Complete the square on the tetradecagonal expression:
$$
(12n - 5)^2 = 144n^2 - 120n + 25 = 24\,(6n^2 - 5n) + 25.
$$
So whenever $n(6n - 5) = t^3$, the pair $(X, Y) = (12n - 5,\; t)$ satisfies
$$
X^2 = 24\,Y^3 + 25.
$$

> **Lemma (Mordell transform).** Every tetradecagonal cube $n(6n-5) = t^3$ yields
> an integer point $(12n - 5,\, t)$ on the cubic curve $X^2 = 24Y^3 + 25$.

Curves of the shape $X^2 = (\text{cubic in } Y)$ are called **Mordell curves**, and
they sit at the heart of the theory of elliptic curves — the same objects that
power modern cryptography and that starred in the proof of Fermat's Last Theorem. A
landmark result of Carl Ludwig Siegel guarantees that any such curve has only
*finitely many* integer points. Translating those finitely many points back through
the substitution $X = 12n - 5$ recovers our finitely many values of $n$ — and a
direct check leaves exactly $n = 0, 1, 5$.

This is the payoff of the bridge: a question about a fourteen-sided counting pattern
becomes a question about integer points on an elliptic curve, where heavy
machinery is available. The same equation, $X^2 = 24Y^3 + 25$, with the integer
points $(\pm 5, 0)$, $(\pm 7, 1)$, and $(\pm 55, 5)$, encodes precisely the three
solutions $n = 0, 1, 5$.

## Why this kind of result matters

It would be easy to dismiss this as a curiosity — a numerical coincidence dressed
up in formalism. But results of exactly this shape, "such-and-such figurate numbers
are perfect powers only finitely often," are the visible tip of a vast and active
research program. The case of *square* figurate numbers (which figurate numbers are
also perfect squares?) leads to Pell equations, the ancient theory of
$x^2 - Dy^2 = 1$. The case of *cubes* and higher powers leads, as we just saw,
straight into elliptic and higher-genus curves, Thue equations, and the full force
of twentieth-century Diophantine analysis.

The fourteen-gon is not special; it is *representative*. The same four moves —
factor and bound the gcd, split coprime cubes, control the bad prime with
valuations, and transform to a Mordell curve — apply to a whole infinite family of
polygons. Each choice of $s$ gives its own equation, its own Thue and Mordell
problems, and its own short, finite answer. What looks like an isolated puzzle is
really a single instance of a sweeping principle: **perfect powers are rare, and
when an algebraic family meets them, they meet only finitely often.**

## The three survivors

So the next time you see the tetradecagonal numbers march off to infinity —
$$
0,\ 1,\ 14,\ 39,\ 76,\ 125,\ 186,\ 259,\ 340,\ \dots
$$
— remember that within that endless parade, only three are perfect cubes: the
silent $0$, the unit $1$, and the lone $125$ sitting at the sixth position. Past
that point the cubes and the fourteen-gons never meet again, and four clean ideas
— coprimality, cube splitting, a stubborn prime, and a famous curve — are enough
to prove it for all time.
