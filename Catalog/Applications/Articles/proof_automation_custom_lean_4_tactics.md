# The Two-Number Secret of the Fibonacci Sequence

## A machine that proves Fibonacci identities

Pick a number. Add it to the number before it. Write down the answer. Repeat
forever. That single instruction generates the most famous sequence in
mathematics:

$$0,\ 1,\ 1,\ 2,\ 3,\ 5,\ 8,\ 13,\ 21,\ 34,\ 55,\ 89,\ \ldots$$

These are the **Fibonacci numbers**, $F_0 = 0$, $F_1 = 1$, and
$F_{n+2} = F_{n+1} + F_n$ for every $n$. They appear in the spirals of
sunflowers, the branching of trees, the ancestry of honeybees, the efficiency
of certain search algorithms, and the proportions that artists call the golden
ratio. For eight centuries mathematicians have collected *identities* about
them — surprising exact equations that hold for every value of $n$. There are
hundreds. Whole books are devoted to them.

This article is about a single, almost embarrassingly simple observation that
turns this sprawling zoo of identities into something a machine can churn
through automatically. The observation is this: **once you fix a starting
point, the entire Fibonacci sequence is determined by just two numbers, and it
depends on them in a perfectly linear way.** Everything else — Cassini's
500-year-old identity, the index-doubling formulas that let you leap from
$F_n$ to $F_{2n}$ in a single step, the convolution identities of Catalan and
d'Ocagne — falls out as ordinary high-school algebra in two unknowns.

## The coordinate trick

Here is the key idea, which we will call the **two-term basis principle**.

Fix some index $n$. Think of the pair $(F_n, F_{n+1})$ as a pair of
*coordinates*. Now ask: what is $F_{n+2}$? By the defining rule it is
$F_{n+1} + F_n$ — a combination of our two coordinates. What about $F_{n+3}$?
It is $F_{n+2} + F_{n+1} = (F_{n+1}+F_n) + F_{n+1} = F_n + 2F_{n+1}$. Again,
just a combination of the two coordinates. Push a little further and a
pattern of familiar numbers appears:

$$
\begin{aligned}
F_{n+2} &= 1\cdot F_n + 1\cdot F_{n+1},\\
F_{n+3} &= 1\cdot F_n + 2\cdot F_{n+1},\\
F_{n+4} &= 2\cdot F_n + 3\cdot F_{n+1},\\
F_{n+5} &= 3\cdot F_n + 5\cdot F_{n+1},\\
F_{n+6} &= 5\cdot F_n + 8\cdot F_{n+1},\\
F_{n+7} &= 8\cdot F_n + 13\cdot F_{n+1}.
\end{aligned}
$$

Look at the coefficients: $1,1,2,3,5,8,13$. The Fibonacci numbers are encoding
*themselves*. In general,

$$F_{n+k} = F_{k-1}\,F_n + F_{k}\,F_{n+1},$$

so every shifted value is a fixed whole-number combination of the two
coordinates $F_n$ and $F_{n+1}$. The coefficients never depend on $n$ — only
on how far you shift.

This is more powerful than it looks. It means that **any identity built out of
shifted Fibonacci numbers from a single base point is secretly an identity
about two free variables.** Replace $F_n$ by a symbol $x$, replace $F_{n+1}$ by
a symbol $y$, expand everything, and the original Fibonacci identity becomes an
ordinary polynomial equation in $x$ and $y$. If that polynomial equation is a
true algebraic identity — if both sides match term for term — then the
Fibonacci identity is true for every $n$, with no further work.

## A worked miracle

Take the elegant-looking claim

$$F_{n+2}^{\,2} = F_{n+1}^{\,2} + F_n\,F_{n+3}.$$

It is not obvious why this should hold. But run the coordinate trick. Using
$F_{n+2} = x + y$ and $F_{n+3} = x + 2y$ (with $x = F_n$, $y = F_{n+1}$), the
two sides become

$$(x+y)^2 \quad\text{versus}\quad y^2 + x(x+2y).$$

Expand: the left side is $x^2 + 2xy + y^2$; the right side is
$y^2 + x^2 + 2xy$. They are *identical*. The identity is proved — for all $n$
at once — by nothing more than multiplying out a square.

This is the heart of the matter. We have replaced an infinite family of
numerical coincidences with a single act of algebra. A simple mechanical
recipe does the whole job:

1. Rewrite every $F_{n+k}$ in terms of the two coordinates $F_n$ and
   $F_{n+1}$.
2. Expand and compare both sides as ordinary polynomials.

If the polynomials agree, the identity is true. Call this recipe **the
expander**: it is a genuine *decision procedure* for the class of "single-base"
polynomial Fibonacci identities. Feed it a true one and it confirms it
instantly; feed it a false one and the polynomials fail to match.

## Where the trick needs a friend: parity

Not every famous Fibonacci identity is a pure polynomial in the two
coordinates. The most celebrated of them all, **Cassini's identity** from
1680, is

$$F_{n+1}^{\,2} - F_n\,F_{n+2} = (-1)^n.$$

In words: if you take any Fibonacci number, square it, and compare it to the
product of its two neighbours, the answer is always $\pm 1$ — and the sign
*alternates* as you walk along the sequence. Check it: for $n=3$ we have
$F_4^2 - F_3 F_5 = 9 - 2\cdot 5 = -1$; for $n=4$, $F_5^2 - F_4 F_6 =
25 - 3\cdot 8 = +1$. The sign keeps flipping.

That flipping sign $(-1)^n$ is the obstruction. It is *not* a polynomial in
$F_n$ and $F_{n+1}$, so the expander alone cannot finish the job: after the
algebra, a stubborn $(-1)^n$ remains. But the fix is tiny. The expander reduces
Cassini at step $n+1$ to Cassini at step $n$ with the opposite sign — exactly
the alternation we see in the numbers. So a single step of mathematical
induction, combined with the expander, nails it. Once you have proved Cassini
in one orientation, the mirror-image version

$$F_{n+2}\,F_n - F_{n+1}^{\,2} = (-1)^{n+1}$$

follows by a line of arithmetic. Cassini's identity says something deep in
disguise: the $2\times 2$ "Fibonacci window" $\begin{pmatrix} F_{n+1} & F_n \\
F_n & F_{n-1}\end{pmatrix}$ always has determinant $\pm 1$, which is why
Fibonacci numbers are so rigidly interlocked.

## Leaping by doubling

The two-coordinate viewpoint also explains one of the most practically useful
facts about Fibonacci numbers: you can *double the index* in a single step.
This is what lets a computer calculate, say, the millionth Fibonacci number
without grinding through a million additions. The formulas are

$$F_{2n+1} = F_{n+1}^{\,2} + F_n^{\,2}, \qquad
F_{2n} = F_n\,\bigl(2F_{n+1} - F_n\bigr).$$

The first says: the odd-indexed Fibonacci numbers are sums of two consecutive
squares. Check $n=3$: $F_7 = 13$ and $F_4^2 + F_3^2 = 9 + 4 = 13$. The second
lets you jump from index $n$ to index $2n$. Together they form a doubling
ladder: to reach index one million, you climb only about twenty rungs, each
rung doubling your position. This is the fast-doubling algorithm, and it is the
method of choice for computing enormous Fibonacci numbers.

Both formulas are, once again, instances of the same principle. Here the
"shift" pairs the base point $n$ with itself, so the general two-point version
of the coordinate trick,

$$F_{n+k} = F_{k-1}F_n + F_k F_{n+1},$$

does the work, and a single algebraic expansion finishes each one.

## The grand unification: convolution identities

The most satisfying payoff is that the harder, two-parameter identities turn
out to be Cassini's identity *wearing a costume*. Consider **Catalan's
identity**,

$$F_{n+r}^{\,2} - F_n\,F_{n+2r} = (-1)^n\,F_r^{\,2},$$

and **d'Ocagne's identity**,

$$F_{n+k}\,F_{n+1} - F_{n+k+1}\,F_n = (-1)^n\,F_k.$$

These look genuinely different and considerably more complicated. Yet when you
substitute the coordinate trick and grind the algebra, something beautiful
happens: each one collapses into a Fibonacci multiple of the Cassini quantity
$F_{n+1}^2 - F_n F_{n+2} = (-1)^n$. Schematically,

$$
\begin{aligned}
\text{d'Ocagne} &= F_k \cdot \bigl(F_{n+1}^2 - F_n F_{n+2}\bigr) = (-1)^n F_k,\\
\text{Catalan} &= F_r^2 \cdot \bigl(F_{n+1}^2 - F_n F_{n+2}\bigr) = (-1)^n F_r^2.
\end{aligned}
$$

So the whole family of signed "convolution" identities — d'Ocagne is the case
$k = 1$ side, Catalan the case where both shifts are equal — is one theorem,
the Cassini determinant, multiplied by the appropriate Fibonacci factor. The
deeper unifying statement, which contains both at once, is

$$F_{n+a}\,F_{n+b} - F_n\,F_{n+a+b} = (-1)^n\,F_a\,F_b.$$

A single identity governs the lot.

## Why this matters beyond Fibonacci

The real prize is not any one identity; it is the *method*. We took an open-
ended craft — discovering and checking Fibonacci identities, traditionally a
matter of cleverness and luck — and reduced its core to a turn-the-crank
procedure: change to two coordinates, expand, compare; if a sign appears, add
one induction step; if two base points appear, factor through Cassini.

And the very same scaffolding works far beyond Fibonacci. Replace the rule
$F_{n+2} = F_{n+1} + F_n$ with any rule of the form
$U_{n+2} = p\,U_{n+1} - q\,U_n$ and you get a whole universe of sequences — the
**Lucas sequences**. The Pell numbers ($p=2$, $q=-1$), the Jacobsthal numbers
($p=1$, $q=-2$), the Mersenne numbers ($p=3$, $q=2$), and infinitely many
others all obey their own two-term basis principle. The coordinate trick, the
expander, the single induction step for the signed identities — all of it
carries over essentially unchanged. Cassini's identity itself generalizes to

$$U_{n+1}^{\,2} - U_n\,U_{n+2} = q^{\,n},$$

with the alternating sign $(-1)^n$ revealed as the special case $q = -1$.

There is even a matrix viewpoint that explains *why* the whole structure is so
rigid. Define the tiny matrix $Q = \begin{pmatrix} 1 & 1 \\ 1 &
0\end{pmatrix}$. Then its powers read off the Fibonacci numbers directly:

$$Q^n = \begin{pmatrix} F_{n+1} & F_n \\ F_n & F_{n-1}\end{pmatrix}.$$

Because the determinant of a product is the product of determinants, and
$\det Q = -1$, we instantly get $\det(Q^n) = (-1)^n$ — which, read off the
matrix entries, is *exactly Cassini's identity*. Every polynomial Fibonacci
identity, single- or multi-parameter, signed or unsigned, is the entry of some
true matrix equation in powers of $Q$. The two-term basis principle is the
shadow this matrix structure casts on ordinary arithmetic.

## The moral

The Fibonacci numbers look like an inexhaustible source of small miracles. The
two-term basis principle reveals that almost all of those miracles are the same
miracle, seen from different angles: the sequence lives, at every moment, in a
two-dimensional world, and it moves through that world by a fixed linear rule.
Pin down two consecutive values and you have pinned down everything. Once you
see that, the hundreds of classical identities stop being a museum of
curiosities and become a single, navigable landscape — one a careful reader,
or a careful machine, can survey from end to end.
