# When Wolfram Met Grothendieck: The Secret Geometry of Cellular Automata

## A universe on a strip of graph paper

Imagine a long row of cells, each one either black or white, stretching off to the
horizon. A single, rigid law tells every cell what color to become next, and it may
consult only itself and its two immediate neighbors. Then time ticks, all cells
update at once, and the row is reborn. Repeat forever.

This is an *elementary cellular automaton*, and despite the almost insulting
simplicity of the setup, these systems are one of the great surprises of modern
science. There are exactly $256$ possible laws — one for each way of assigning a
new color to every one of the eight possible three-cell patterns — and Stephen
Wolfram famously numbered them $0$ through $255$ and sorted them into four classes
of behavior. Some settle into a boring uniform field. Some produce stripes and
nested triangles. Some dissolve into what looks for all the world like noise. And a
rare few generate structures that drift, collide, and interact like particles in a
tiny physics.

One of those rare rules, **Rule 110**, is *Turing-complete*: with the right initial
row of black and white cells, it can compute anything any computer can compute. A
one-dimensional line of pixels, updated by a three-cell rule, is a universal
computer. That fact alone should make you suspicious that something deep is going
on beneath the surface.

This article is about a different — and, at first glance, wildly unrelated — way of
looking at these systems. It comes from *algebraic geometry*, the branch of
mathematics that studies shapes defined by polynomial equations: circles, spheres,
elliptic curves, and their higher-dimensional cousins called **varieties**. The
punchline is that every cellular automaton *is* such a shape. And chasing that idea
leads to a genuinely surprising discovery about where complexity really lives.

## Coloring by arithmetic

The first move is to stop thinking of black and white and start thinking of $0$ and
$1$. Not ordinary integers, but the two elements of the *binary field*, written
$\mathrm{GF}(2)$. In this field addition is the logical "exclusive or":
$$0+0 = 0, \quad 0+1 = 1, \quad 1+1 = 0.$$
That last equation — $1+1=0$ — is the whole magic. Multiplication is ordinary
(it is just the logical "and"). With these two operations, $\{0,1\}$ becomes a
bona fide number system in which we can add, subtract, and multiply exactly as in
high-school algebra.

Now here is the crucial observation. A local rule takes three inputs $a$, $b$, $c$
(the left neighbor, the cell itself, the right neighbor), each $0$ or $1$, and
returns a single output. But *any* function from $\{0,1\}^3$ to $\{0,1\}$ can be
written as a polynomial in $a$, $b$, $c$ over $\mathrm{GF}(2)$ — and because
$x^2 = x$ for $x \in \{0,1\}$, that polynomial uses each variable at most once, so
it has degree at most $3$. Every one of the $256$ rules is secretly a cubic
polynomial. For example:

- **Rule 0**, which paints everything white, is simply $g(a,b,c) = 0$.
- **Rule 204**, which leaves every cell alone, is $g(a,b,c) = b$.
- **Rule 90**, which produces the beautiful Sierpiński triangle, is $g(a,b,c) = a + c$.
- **Rule 150** is $g(a,b,c) = a + b + c$.
- **Rule 110**, the universal computer, is the genuine cubic
  $$g(a,b,c) = b + c + bc + abc.$$

A whole row of cells on a loop of length $n$ is then a vector
$s = (s_0, s_1, \dots, s_{n-1})$ over $\mathrm{GF}(2)$, and one tick of the clock
sends $s$ to a new vector whose $i$-th entry is $g(s_{i-1}, s_i, s_{i+1})$, with the
indices wrapping around the loop.

## The shape hiding inside a rule

Among all the configurations a rule can visit, the most special are those it leaves
*unchanged* — the **fixed points**, the still lifes of this pixelated world. A row
$s$ is fixed when applying the rule gives back exactly $s$, which is to say when
$$s_i = g(s_{i-1}, s_i, s_{i+1}) \quad \text{for every } i.$$
These are $n$ polynomial equations in $n$ unknowns over $\mathrm{GF}(2)$. The set of
all solutions is precisely what algebraic geometers call an **affine variety** — the
solution shape of a system of polynomial equations. We write it $V(g)$.

So each cellular automaton, that most combinatorial of objects, hands us a geometric
one: its fixed-point variety. And every variety has a **dimension**, a measure of
how many independent directions you can move within it while staying a solution. A
single isolated point has dimension $0$. A line has dimension $1$. The whole space
of configurations has dimension $n$. Over the binary field these dimensions are not
abstractions: a variety that happens to be a *linear* subspace of dimension $d$
contains exactly $2^d$ points, so we can count solutions and read off the dimension
directly.

This sets up an irresistible conjecture, and it was the starting point of the
investigation: **maybe the dimension of a rule's fixed-point variety measures its
complexity.** Wolfram's boring Class 1 rules would have tiny, zero-dimensional
varieties; his chaotic and computational Class 3 and 4 rules would have big,
high-dimensional ones. The Turing-complete Rule 110, the crown jewel, would sit at
the very top with the maximal dimension $n$. It is a beautiful idea: complexity as
geometric size.

## The beautiful idea is wrong

It is exactly wrong. And the way it fails is more interesting than the way it might
have succeeded.

Let us actually compute the varieties. The trivial rules behave as expected at
first. Rule 0 fixes only the all-white row, so $V = \{0\}$, a single point of
dimension $0$. Rule 204, the do-nothing identity, fixes *every* row, so its variety
is the entire space of dimension $n$ — as large as a variety can be. The two shift
rules (**Rule 170** and **Rule 240**), which slide the pattern left or right, fix
exactly the *constant* rows (all-black or all-white), a line of dimension $1$.

The additive rules are where number theory sneaks in. A row is fixed by **Rule 90**
precisely when it obeys the Fibonacci-like recurrence
$$s_{i+1} = s_i + s_{i-1} \pmod 2.$$
The Fibonacci sequence modulo $2$ runs $0, 1, 1, 0, 1, 1, 0, \dots$ — it repeats
with period $3$. On a loop, the recurrence can close up consistently only when the
loop length is a multiple of that period. So Rule 90 has a nontrivial fixed
pattern *exactly when $3$ divides $n$*, in which case its variety jumps to
dimension $2$ (four solutions); otherwise it collapses to the lone point $0$. The
governing number, $3$, is the *Pisano period* of $2$ — the period of Fibonacci
modulo $2$ — and it can be seen as the multiplicative order of the tiny
$2\times 2$ companion matrix
$$T = \begin{pmatrix} 0 & 1 \\ 1 & 1 \end{pmatrix}$$
over the binary field, which satisfies $T^3 = I$ and nothing smaller. Linear
dynamics, cellular automata, and elementary number theory all meet on the number
$3$. **Rule 150** tells a parallel story with two-periodicity ($s_{i+2} = s_i$)
in place of Fibonacci: its variety has dimension $2$ on even loops and dimension
$1$ on odd ones.

And now the punchline. What of Rule 110, the universal computer, the rule that was
supposed to reign at maximal dimension? Compute its fixed-point variety and it
**collapses to a single point.** The only configuration Rule 110 leaves unchanged
is the all-white row. Its variety is $\{0\}$, dimension $0$ — the *smallest
possible*, the same as the utterly trivial Rule 0.

Here is why, and it is a lovely little argument. Suppose a row is fixed by Rule 110
and some cell is white ($s_i = 0$). Plugging $b = s_i = 0$ into the rule's
polynomial $b + c + bc + abc$, every term carrying a factor of $b$ vanishes, and
the fixed-point equation at that site reduces to forcing the *right neighbor* to be
white too. So a single white cell propagates its color rightward, one step at a
time, all the way around the loop — proving the whole row is white. The only other
possibility, the all-black row, one checks directly is not fixed by Rule 110. Hence
white everywhere is the *only* still life. The richest, most computationally
powerful rule in the entire catalog has the poorest possible landscape of stable
states.

## The moral: complexity is degree, not size

So the tempting slogan "complexity equals dimension" is false, and spectacularly
so — the ordering is inverted. The Turing-complete Rule 110 sits at dimension $0$;
the do-nothing identity Rule 204 sits at dimension $n$. On any loop of length two or
more, the identity's variety has exponentially more points than Rule 110's. If
dimension measured anything about dynamical richness, this could not happen.

But the failure points to the right answer. Look again at the rules whose varieties
are large and well-behaved: Rules 90, 150, 170, 240, 204. Every one of them is
**linear** (or affine) — its defining polynomial has degree $1$. Their fixed-point
sets are flat subspaces, their dimensions are controlled by clean arithmetic
(Pisano periods, parities, matrix orders), and they are precisely Wolfram's
tame, predictable rules. Rule 110, by contrast, is a *genuine cubic*: its
polynomial $b + c + bc + abc$ has that irreducibly nonlinear $abc$ term, and it is
that nonlinearity — not any largeness — that both collapses its variety and powers
its universal computation.

The true invariant separating the tame from the universal is therefore not the
*size* of the fixed-point shape but the *degree* of the polynomial that carves it
out — equivalently, whether the variety is linear or curved. Complexity does not
live in how big a rule's geometry is. It lives in how *bent* that geometry is.

## Why this is more than a curiosity

The dictionary "automaton $\leftrightarrow$ variety" is worth having in both
directions. It lets the vast machinery of algebra — linear algebra, the theory of
finite fields, companion matrices and their orders — be brought to bear on
questions about cellular automata that look, on their face, purely combinatorial.
The exact count of still lifes for every additive rule, on every loop length, falls
straight out of the order of a small matrix over $\mathrm{GF}(2)$; no simulation
required.

More broadly, it is a small, sharp instance of a recurring lesson in mathematics:
the interesting structure of a system is often not its most obvious quantitative
feature. Here the obvious feature — the dimension, the raw head-count of stable
states — is a red herring. The real signal is qualitative: is the defining
polynomial linear, or does it genuinely curve? That question separates the rules
that draw fractals from the one that runs programs, and it does so without a single
step of simulation. Two continents of mathematics that grew up worlds apart —
Wolfram's computational universe of blinking cells and Grothendieck's cathedral of
varieties and schemes — turn out to be describing the same landscape, and the view
from the border is worth the trip.
