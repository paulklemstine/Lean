# When Squaring a Triangle Keeps Its Roots Real

## A number that counts the ways we can be surprised

Imagine you are reading a list of numbers one at a time — say a shuffled
deck, turned over card by card. Every so often the next card is *smaller*
than the one before it. Those moments, where the sequence suddenly steps
down, are called **descents**. They are the little surprises hidden inside
an ordering.

Mathematicians have been counting descents for centuries. Fix a length
$n$, and ask: among all $n!$ ways to arrange the numbers $1, 2, \ldots, n$,
how many arrangements have *exactly* $k$ descents? The answer is a whole
number written $A(n,k)$, and it is called an **Eulerian number**, after
Leonhard Euler, who stumbled onto these quantities while summing infinite
series in the eighteenth century.

The Eulerian numbers fall into a beautiful triangular pattern, one row for
each length $n$:

$$
\begin{array}{ccccccc}
1 \\
1 \\
1 & 1 \\
1 & 4 & 1 \\
1 & 11 & 11 & 1 \\
1 & 26 & 66 & 26 & 1 \\
\end{array}
$$

Each row is symmetric — reversing an arrangement turns a descent into an
ascent, so surprises come in balanced supply — and each row sums to $n!$,
because every arrangement lands in exactly one column. This is the
**Eulerian triangle**, one of the four "classical" triangles of
combinatorics, alongside Pascal's triangle (which counts subsets),
Stirling's triangle (which counts partitions), and the Narayana triangle
(which counts balanced parenthesizations).

## Turning a triangle into a polynomial

There is a time-honored trick for studying a row of numbers: hang them on
the powers of a variable $x$ and read off a **polynomial**. From row $n$
of the Eulerian triangle we get the *Eulerian polynomial*

$$
A_n(x) = \sum_k A(n,k)\, x^k.
$$

For example $A_3(x) = 1 + 4x + x^2$ and $A_4(x) = 1 + 11x + 11x^2 + x^3$.

Why bother? Because a polynomial has **roots** — the values of $x$ where it
equals zero — and the roots encode deep structure. A polynomial is called
**real-rooted** when *all* of its roots are ordinary real numbers, with no
imaginary parts hiding in the complex plane. Real-rootedness is not a
curiosity; it is a certificate of good behavior. It guarantees that the
coefficients are **log-concave** (each is at least the geometric mean of its
neighbors) and **unimodal** (they rise to a single peak and then fall),
two properties that combinatorialists prize because they say the counts are
smooth and bell-shaped rather than erratic. It is a classical theorem that
every Eulerian polynomial is real-rooted, and in fact all of its roots are
negative.

## Squaring the triangle

Here is where our story begins. A triangle of numbers is really a
lower-triangular **matrix**, and matrices can be *multiplied*. What happens
if we multiply the Eulerian triangle by itself — if we **square** it?

The rule for matrix multiplication says the entry in row $n$, column $k$ of
the square is

$$
C(n,k) = \sum_{j} A(n,j)\, A(j,k).
$$

You can read this as a two-step counting process: first record how many
descents an arrangement of length $n$ has (that is $A(n,j)$), then feed that
descent count $j$ back into the triangle and read off $A(j,k)$, summing over
all the intermediate values $j$. The result is a brand-new triangle — the
**square of the Eulerian triangle** — with its own rows and its own row
polynomials

$$
B_n(x) = \sum_k C(n,k)\, x^k.
$$

The first several of these polynomials are strikingly clean:

$$
\begin{aligned}
B_0 &= 1, & B_1 &= 1, & B_2 &= 2, \\
B_3 &= x + 6, & B_4 &= x^2 + 15x + 24, \\
B_5 &= x^3 + 37x^2 + 181x + 120, \\
B_6 &= x^4 + 83x^3 + 995x^2 + 2163x + 720, \\
B_7 &= x^5 + 177x^4 + 4613x^3 + 23739x^2 + 27133x + 5040.
\end{aligned}
$$

Two patterns leap out. Each polynomial is **monic** — its leading
coefficient is exactly $1$ — and each has **constant term $n!$**. The
constant term is no accident: setting $x = 0$ recovers $C(n,0) = \sum_j
A(n,j) = n!$, because every arrangement of length $n$ contributes to the
first column and the whole row sums to $n!$.

And now the real question. The individual Eulerian polynomials are
real-rooted. But squaring the triangle blends whole rows together in the
combination $B_n = \sum_j A(n,j)\, A_j(x)$. Blending real-rooted polynomials
is a dangerous business: a *sum* of real-rooted polynomials can easily
develop complex roots. So there is no free lunch here. **Does squaring the
Eulerian triangle preserve real-rootedness?**

## The answer, row by row

Compute the roots and a pattern emerges immediately. For every row we can
check, all the roots are **real, negative, and simple** (no repeats):

$$
\begin{aligned}
B_3:&\quad -6, \\
B_4:&\quad -1.82,\ -13.18, \\
B_5:&\quad -0.79,\ -4.86,\ -31.35, \\
B_6:&\quad -0.41,\ -2.28,\ -11.28,\ -69.04, \\
B_7:&\quad -0.23,\ -1.28,\ -4.87,\ -23.98,\ -146.64.
\end{aligned}
$$

These are not tidy rational numbers. Starting from $B_4$, whose roots are
$(-15 \pm \sqrt{129})/2$, the roots are genuinely **irrational**. So there
is no cheap way to "see" the factorization; the real-rootedness has to be
earned.

**The main result of this work is a rigorous proof that $B_n$ is
real-rooted — that it factors completely into real linear pieces — for every
$n$ up to $7$.**

The proof rests on one clean structural idea, which we might call the
*saturation principle*. Any polynomial of degree $m$ has **at most** $m$
roots. So if you can *find* $m$ genuinely different real numbers, each of
which makes the polynomial vanish, you have used up the entire root budget:
there is no room left for a stray complex root. The polynomial must factor
into $m$ real linear pieces. Real-rootedness — a statement about *all*
roots, including invisible complex ones — collapses into the concrete task
of **locating enough real roots**.

How do we locate them without solving the equation? With the
**Intermediate Value Theorem**, the humble but powerful fact that a
continuous curve which is negative at one point and positive at another
*must* cross zero somewhere in between. Evaluate $B_n$ at a ladder of
integer inputs $\ldots, -3, -2, -1, 0$ and watch the sign flip. Each flip
traps a root inside a unit interval. For the rows up to $B_7$, the
consecutive integers separate the roots perfectly: enough sign changes
appear to catch every root, the budget saturates, and real-rootedness
follows.

The quadratic case, $B_4 = x^2 + 15x + 24$, gets an even more elementary
treatment: its **discriminant** is $15^2 - 4\cdot 24 = 129 > 0$, and the
familiar rule that a quadratic with positive discriminant has two real
roots seals it.

## The wall at $n = 8$

Every good story about a pattern needs the moment the pattern gets *hard* —
the place where the easy argument runs out of road. For the squared
Eulerian triangle, that place is $n = 8$.

The eighth row polynomial is
$$
B_8 = x^6 + 367x^5 + 19563x^4 + 204247x^3 + 546551x^2 + 364395x + 40320,
$$
and numerically its roots are still all real, negative, and simple:
approximately $-0.14$, $-0.79$, $-2.72$, $-9.12$, $-49.19$, and $-305.04$.
The mathematics is still true. But look at the two smallest: $-0.14$ and
$-0.79$ **both lie between $-1$ and $0$**. Two roots have crowded into a
single unit interval. The ladder of consecutive integers can no longer tell
them apart — one interval, two roots, only one sign change. The
elementary separation argument, so effective through $B_7$, breaks exactly
here. Finer, fractional brackets would be needed to pry the two roots apart,
and pinning down such brackets for *every* $n$ at once is precisely the
obstruction that keeps the general problem open.

This is the honest state of affairs, and it is what makes the subject
alive. We can prove the theorem for each concrete row we test, and the
numerical evidence marches on far beyond where our elementary proof
reaches — yet a single argument covering *all* $n$ remains a conjecture.

## Why anyone should care

Real-rootedness is a bridge between three worlds that rarely meet so
cleanly. In **combinatorics** it certifies that a sequence of counts is
unimodal and log-concave — smooth, single-peaked, well-behaved. In
**algebra** it says a polynomial factors as far as it possibly can over the
real numbers. In **analysis** it is caught by nothing more exotic than the
sign of a continuous function.

The larger vision is a *closure property*. The Pascal, Stirling, and
Narayana triangles are already known to have real-rooted squares. If the
Eulerian triangle — historically the most stubborn of the four — joins
them, it suggests a unifying law: that squaring, and more generally
multiplying, preserves real-rootedness for a whole class of well-structured
combinatorial triangles. The engine behind such a law would be
**interlacing**: the roots of consecutive rows are conjectured to alternate,
each root of one row nestled between two roots of the next. Interlacing is
the hidden scaffolding that would let real-rootedness *propagate* by
induction from one row to the next, upgrading a stack of individually
verified cases into a single clean theorem.

There is even a whisper of asymptotics in the data. Because the negated
roots always multiply to exactly $n!$, and the largest of them drifts
steadily toward zero while the smallest plunges roughly like $-n^2$, the
roots spread themselves across an enormous dynamic range in a way that
seems governed by a precise, still-unproven law.

So the square of the Eulerian triangle sits at a frontier: proven where we
can reach, conjectured where we cannot yet, and pointing toward a general
principle about why counting the surprises in an ordering should produce
polynomials whose roots are all, remarkably, real.
