# The Number 36 and the Shape of Symmetry

## A puzzle hiding in plain sight

Some of the deepest questions in mathematics start with a childishly simple
observation: symmetry. Fold a shape in half and the two sides match. Read a
word backwards and it stays the same. Line up a row of numbers and find that it
reads identically from left to right and from right to left. These *palindromic*
patterns feel like they ought to be the end of a story — a clean, satisfying
regularity. But in the world of counting polytopes, palindromy turns out to be
just the beginning. Behind it lurks a stronger, subtler kind of symmetry, and
the gap between the two hides a startlingly specific number: **36**.

This is the story of that number — why it exists, what it measures, and how a
question about high-dimensional geometry collapses onto a piece of algebra about
polynomials you could explain to a curious teenager.

## From graphs to geometry

Start with a graph: a collection of dots (vertices) joined by lines (edges).
Graphs are the workhorses of applied mathematics — they model social networks,
molecules, road maps, neural connections. To each connected graph $G$ we can
attach a geometric object called its **symmetric edge polytope**, written $Q_G$.
The recipe is simple. Place the graph's vertices as coordinate axes in a
high-dimensional space. For every edge joining vertex $u$ to vertex $v$, drop in
*two* points: one that reads "$+1$ at $u$, $-1$ at $v$", and its mirror image
"$-1$ at $u$, $+1$ at $v$". The convex hull of all these points — the smallest
solid region containing them — is $Q_G$. Because every point comes paired with
its negative, the resulting polytope is perfectly balanced around the origin.

These polytopes are not idle curiosities. They surface in statistical physics
(where they encode the Kuramoto model of synchronizing oscillators), in
optimization, and in the algebra of lattice points. And attached to each of them
is a single polynomial that captures an enormous amount of information about how
the polytope interacts with the integer grid: its **$h^*$-polynomial**.

## Counting lattice points, and the polynomial that remembers

Imagine inflating a polytope by an integer factor $m$ — scaling it up to twice,
three times, ten times its size — and counting how many points of the integer
grid land inside. As $m$ grows, this count follows a polynomial rule (a
celebrated fact discovered by Eugène Ehrhart). Repackaging that rule produces
the $h^*$-polynomial, a finite list of nonnegative whole numbers,
$h^*_0, h^*_1, \dots, h^*_d$, that serves as a fingerprint of the polytope.

For symmetric edge polytopes, this fingerprint always has a beautiful property:
it is **palindromic**. The sequence of coefficients reads the same forwards and
backwards,
$$h^*_k = h^*_{d-k} \quad \text{for all } k.$$
This is a theorem, guaranteed for every connected graph, and it is a direct
geometric consequence of the polytope's balance about the origin. Palindromy is
comforting. It suggests order. It hints that these polynomials might be as
well-behaved as one could hope.

## The stronger symmetry: $\gamma$-positivity

Here is where the story deepens. There is a *stronger* form of good behavior
than palindromy, and it has a name: **$\gamma$-positivity**.

The idea is to change your vantage point. Ordinary polynomials are written in the
basis of powers $1, t, t^2, \dots$. But if a polynomial is going to be symmetric
about its center $n/2$, there is a far more natural set of building blocks —
each one *already* symmetric about that center:
$$t^i \,(1+t)^{\,n-2i}, \qquad i = 0, 1, 2, \dots, \lfloor n/2 \rfloor.$$
Every one of these blocks is a palindrome by construction: expanding
$(1+t)^{n-2i}$ gives a symmetric row of binomial coefficients, and multiplying
by $t^i$ simply recenters it. In fact one can write down the coefficients
exactly. The block $t^i(1+t)^{n-2i}$ has, in degree $k$, the value
$$\binom{n-2i}{\,k-i\,} \quad \text{when } i \le k, \text{ and } 0 \text{ otherwise},$$
and the binomial symmetry $\binom{n-2i}{k-i} = \binom{n-2i}{(n-2i)-(k-i)}$ is
exactly what makes each block palindromic about $n/2$.

A polynomial is called **$\gamma$-positive of order $n$** if it can be written as
a combination of these blocks using only *nonnegative* coefficients:
$$p(t) = \sum_{i=0}^{\lfloor n/2 \rfloor} \gamma_i \, t^i (1+t)^{\,n-2i},
\qquad \gamma_i \ge 0.$$
The numbers $\gamma_i$ are the polynomial's **$\gamma$-vector**.

Why does anyone care? Because $\gamma$-positivity is a powerful certificate.
Since every building block is palindromic, any nonnegative combination is too —
so **$\gamma$-positivity implies palindromy**. Since every block has nonnegative
coefficients, so does any nonnegative combination — so **$\gamma$-positivity
implies all coefficients are $\ge 0$**. And with a little more work,
$\gamma$-positivity implies **unimodality**: the coefficients rise to a peak in
the middle and fall again, never dipping and re-rising. Unimodality is a property
mathematicians fight hard to establish; $\gamma$-positivity hands it over for
free. A single nonnegative $\gamma$-vector packages symmetry, nonnegativity, and
unimodality all at once.

## The gap that will not close

So we have two properties. Palindromy is necessary for $\gamma$-positivity.
Is it *sufficient*? If every palindromic polynomial were $\gamma$-positive, the
whole subject would be trivial and the number 36 would never appear. It is not
sufficient — and the failures start almost immediately.

Take the simplest palindrome that is not just a power of $(1+t)$: the polynomial
$1 + t^2$. Its coefficients $(1, 0, 1)$ read the same both ways. Try to expand it
in the order-$2$ building blocks $\{(1+t)^2, \, t\}$. Matching the constant term
forces $\gamma_0 = 1$. But then matching the coefficient of $t$ gives
$2\gamma_0 + \gamma_1 = 0$, so $\gamma_1 = -2$. Negative. There is no way to write
$1+t^2$ with nonnegative $\gamma$'s. It is palindromic but *not* $\gamma$-positive.

One might object that $1 + t^2$ is a cheap example — with coefficients $(1,0,1)$
it dips in the middle, so it is not even unimodal. Surely if we insist on
unimodality the pathology disappears? It does not. Consider the flat, friendly
polynomial
$$1 + t + t^2 + t^3 + t^4,$$
whose coefficients are all equal to $1$. This sequence is palindromic. It is
nonnegative. It is unimodal (a flat plateau counts). It satisfies *every*
consequence of $\gamma$-positivity we listed. And yet it fails. Matching the
constant term forces $\gamma_0 = 1$; matching the linear term gives
$4\gamma_0 + \gamma_1 = 1$, so $\gamma_1 = -3$. Negative again. The building
blocks are simply too "peaked" to assemble a flat top out of nonnegative parts.

This is the crux of the whole subject in miniature. There is a strict hierarchy,
$$\text{$\gamma$-positive} \ \subsetneq \ \text{unimodal} \ \subsetneq \ \text{palindromic},$$
and both containments are strict already in tiny degrees. The pattern even
scales: the all-ones polynomial $1 + t + \cdots + t^n$ of degree $n$ always has
$\gamma_1 = 1 - n$, which marches off toward $-\infty$ as the degree grows. The
gap between palindromy and $\gamma$-positivity is not a rounding error. It is a
chasm, and it widens.

## Why 36?

Now we can appreciate the headline result. Every symmetric edge polytope has a
palindromic $h^*$-polynomial — that much is automatic. The real question is:
does that palindrome always achieve the stronger $\gamma$-positivity? For a long
time, every example anyone computed said yes. The graphs were small, the
polynomials cooperated, and $\gamma$-positivity held. It was natural to
conjecture it *always* holds.

But we have just seen that palindromy alone guarantees nothing. Somewhere out in
the space of graphs, there must be a first graph whose $h^*$-polynomial slips
through the gap — palindromic, as it must be, but no longer $\gamma$-positive.
The question is *when*. How large must a graph be before geometry finally
produces a genuine failure?

The answer is sharp and surprising:

> **The smallest dimension of a symmetric edge polytope whose $h^*$-polynomial
> fails to be $\gamma$-positive is exactly 36.** Equivalently, for every
> connected graph $G$ on at most $36$ vertices, the symmetric edge polytope
> $Q_G$ has a $\gamma$-positive $h^*$-polynomial — and $36$ is the first place
> this can break.

Thirty-six. Not a power of two, not a familiar constant — a specific threshold
where a global geometric property, guaranteed by high-dimensional balance,
finally loses its grip on the finer algebraic structure. Below it, symmetry is
strong enough to force $\gamma$-positivity for *every* connected graph. At it,
for the first time, a graph exists whose lattice-point fingerprint is symmetric
yet cannot be built from the natural symmetric blocks with nonnegative weights.

The little polynomials $1 + t^2$ and $1 + t + t^2 + t^3 + t^4$ are, in this
sense, the humble ancestors of that graph on 36 vertices. They exhibit in degree
two and degree four exactly the failure that geometry postpones until dimension
36: a perfectly symmetric sequence that the $\gamma$-basis rejects. The
difference is only one of disguise. In the toy examples we can see the negative
$\gamma$ by hand; in the geometric example it is hidden inside the lattice-point
count of an enormous polytope. But the mechanism is identical.

## What the number is really telling us

The moral runs deeper than a single integer. It is a lesson about the layers of
structure that "symmetry" can carry.

Palindromy is the visible symmetry — the one you can check by reading a sequence
backwards. $\gamma$-positivity is the *constructive* symmetry — the promise that
the object can actually be assembled from symmetric pieces without cancellation.
The two look alike from a distance, and for small, tame objects they coincide.
But they are genuinely different, and the number 36 is the precise measure of how
far geometry can keep the illusion going before the difference breaks through.

There is a growing dictionary connecting this algebra back to the wider world.
$\gamma$-positive polynomials form a well-behaved family — closed under addition
within a fixed order, and under multiplication across orders via the clean rule
$$t^i(1+t)^{m-2i} \cdot t^j(1+t)^{n-2j} = t^{i+j}(1+t)^{(m+n)-2(i+j)},$$
which simply *adds the indices*. This makes $\gamma$-positivity behave like an
honest notion of nonnegativity in a graded algebra, opening the door to
structural questions about generators and factorization. And there is a
constructive route in the other direction: a palindromic polynomial whose roots
are all real and nonpositive is automatically $\gamma$-positive, with its
$\gamma$-vector produced explicitly by pairing each root with its reciprocal.
The failures of $\gamma$-positivity are, in this light, exactly the places where
real roots give way to complex ones — where the polynomial can no longer be
factored into symmetric, root-paired pieces.

That is the quiet power of a well-chosen question. "What is the smallest
dimension where symmetry stops being enough?" sounds like a riddle. Its answer,
36, is a doorway into the architecture of positivity itself — the study of when
a mathematical object is not merely balanced, but buildable. And it all comes
back to a fact you can verify with a pencil: that the flat little polynomial
$1 + t + t^2 + t^3 + t^4$, for all its perfect symmetry, cannot be built from the
natural symmetric blocks without going negative.
