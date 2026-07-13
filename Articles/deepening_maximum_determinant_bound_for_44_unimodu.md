# How Big Can a Determinant Get? A Four-by-Four Detective Story

## A deceptively simple question

Picture a $4 \times 4$ grid of numbers. You get to choose each of the sixteen
entries freely, subject to a single rule: every number must lie between $-B$ and
$B$, where $B$ is some fixed size limit you agree on in advance. Now compute the
*determinant* of that grid — the single number that measures how much the grid,
viewed as a linear transformation, stretches or shrinks volume.

Here is the puzzle: **how large can that determinant possibly be?**

At first glance this sounds like a homework exercise. It is not. It is a corner
of one of the oldest and most stubborn problems in matrix theory — the *maximal
determinant problem* — and even the innocent-looking $4 \times 4$ case connects
to a famous unsolved conjecture that mathematicians have chased for over a
century. This article tells the story of what the answer is, why a beautiful and
symmetric matrix achieves it, and how a plausible-sounding formula that had been
circulating turned out to be spectacularly wrong.

## Why determinants care about the range

The determinant of a matrix has a geometric soul. If you think of the four rows
of a $4 \times 4$ matrix as four arrows (vectors) in four-dimensional space, the
absolute value of the determinant is exactly the *volume* of the four-dimensional
box (a "parallelepiped") that those arrows span.

That single fact tells us almost everything about our puzzle. To make the volume
of a box large, you want two things:

1. **Long edges.** Each arrow should be as long as possible. Since every entry is
   capped at $B$ in absolute value, the longest a row of four numbers can be is
   achieved by setting each entry to $\pm B$, giving a length of
   $\sqrt{B^2 + B^2 + B^2 + B^2} = \sqrt{4B^2} = 2B$.
2. **Right angles.** The edges should be mutually perpendicular. A box whose
   edges lean into one another is flatter, and therefore has less volume, than a
   box whose edges meet at clean right angles. The maximum volume for edges of
   fixed length happens precisely when they are all mutually orthogonal.

Put those two wishes together. If we could find four rows, each of length $2B$,
that are all mutually perpendicular, the resulting box would have volume
$$ (2B) \times (2B) \times (2B) \times (2B) = 16\,B^4. $$
That number, $16\,B^4$, is the star of our story.

## Building the perfect matrix

Can we actually build such a matrix — one whose entries are all $\pm B$ and whose
rows are genuinely perpendicular? Remarkably, yes. Here it is:
$$
H(B) =
\begin{pmatrix}
 B & B & B & B \\
 B & -B & B & -B \\
 B & B & -B & -B \\
 B & -B & -B & B
\end{pmatrix}.
$$
Every entry is either $+B$ or $-B$, so it obeys the size limit perfectly. And the
rows are mutually orthogonal, which is the magic ingredient. To check that two
rows are perpendicular, you take their *dot product* — multiply corresponding
entries and add — and confirm the answer is zero. Take rows one and two:
$$
(B)(B) + (B)(-B) + (B)(B) + (B)(-B) = B^2 - B^2 + B^2 - B^2 = 0.
$$
The same cancellation happens for every pair of distinct rows. Meanwhile, each
row dotted with *itself* gives $B^2 + B^2 + B^2 + B^2 = 4B^2$, confirming each
edge has length $2B$. In compact matrix language, if $H^{\mathsf T}$ denotes the
transpose (rows and columns swapped), then
$$
H(B)\, H(B)^{\mathsf T} = 4B^2 \, I,
$$
where $I$ is the identity matrix. This single equation is the *certificate of
perpendicularity*: it says the rows form a perfectly rectangular frame, each edge
of length $2B$.

What is the determinant of $H(B)$? Grinding through the arithmetic — or invoking
the perpendicularity certificate — gives exactly
$$
\det H(B) = 16\,B^4,
$$
matching the theoretical ceiling we computed above. The matrix $H(B)$ is a
*scaled Hadamard matrix*, named after Jacques Hadamard, who studied exactly these
"maximally perpendicular" sign patterns in the 1890s.

There is a slick way to see why orthogonality forces the determinant to be this
large, using one elegant identity. The determinant of a product is the product of
determinants, and a matrix and its transpose have the same determinant. So
$$
(\det H)^2 = \det H \cdot \det H^{\mathsf T} = \det\!\big(H H^{\mathsf T}\big)
= \det\!\big(4B^2 I\big) = (4B^2)^4 = 256\,B^8.
$$
Taking the square root gives $|\det H| = 16\,B^4$. The orthogonality collapses
the whole computation into a one-line miracle.

## The crude ceiling, and the honest bracket

We now know we can *reach* $16\,B^4$. But is that truly the maximum? To be sure,
we need an argument that *no* matrix in the family can beat it. Here the story
gets subtle.

There is a simple, universal ceiling that comes from the very definition of the
determinant. A determinant is an alternating sum of products; for a $4 \times 4$
matrix it is a sum over the $4! = 24$ ways of picking one entry from each row and
column, with alternating signs. Each of those $24$ products is a product of four
entries, so its absolute value is at most $B \cdot B \cdot B \cdot B = B^4$. Add
up $24$ terms, each no bigger than $B^4$, and you get the guaranteed bound
$$
|\det A| \le 24\,B^4
$$
for *every* matrix in the family. This is the *permutation bound*, and it is
rigorously true — but it is loose. It counts as if all $24$ terms could
simultaneously hit their maximum with the same sign, which the algebra of
determinants never actually permits.

So the rigorous, no-assumptions-needed conclusion is a *bracket*:
$$
16\,B^4 \;\le\; M(B) \;\le\; 24\,B^4,
$$
where $M(B)$ denotes the true maximum determinant over all $4 \times 4$ matrices
with entries bounded by $B$. The lower end is *achieved* — we built the matrix
that does it. The upper end is *guaranteed* — no matrix can exceed it. The truth
lives somewhere in this bracket.

And in fact the truth sits exactly at the bottom: the real maximum is $16\,B^4$.
Closing the gap from the crude $24$ down to the sharp $16$ requires one more
ingredient, a classical inequality about the geometry of boxes. It formalizes the
intuition we started with — that perpendicular edges maximize volume — into the
statement that the four-dimensional box can never have volume exceeding the
product of its edge lengths, each of which is at most $2B$. That refinement is a
genuine analytic theorem rather than mere bookkeeping, which is why the elementary
argument only delivers the looser $24\,B^4$. But the construction already tells us
where the answer lands, and the bracket rigorously traps it.

## The formula that wasn't

Now for the twist. A formula had been circulating as the supposed answer for a
closely related setup. Instead of a symmetric range $\{-B, \dots, B\}$, imagine
restricting to *odd* radii: entries drawn from $\{-(2k-1), \dots, 2k-1\}$ for a
positive integer $k$. The circulated claim was that the maximum determinant of a
$4 \times 4$ matrix on this range equals
$$
(2k-1)^4 - 2(2k-1)^2 + 1.
$$
It looks respectable. It is a clean polynomial in the radius. It even factors
nicely, as $\big((2k-1)^2 - 1\big)^2$. But it is wrong — and not by a little.

Set $B = 2k - 1$ (an odd number). Our Hadamard construction lives happily inside
this range, since all its entries are $\pm(2k-1)$, and it already achieves
$16\,(2k-1)^4$. Compare:
$$
(2k-1)^4 - 2(2k-1)^2 + 1 \;<\; 16\,(2k-1)^4
\qquad \text{for every } k \ge 1.
$$
The circulated formula is not merely a bad estimate of the maximum — **it is not
even an upper bound.** A concrete, fully explicit matrix blows past it for every
single value of $k$.

The most vivid failure happens at the smallest case, $k = 1$, where the range is
just $\{-1, 0, 1\}$. The circulated formula predicts a maximum of
$$
1^4 - 2 \cdot 1^2 + 1 = 1 - 2 + 1 = 0.
$$
A maximum determinant of *zero* would mean every $4 \times 4$ matrix of
$\{-1,0,1\}$ entries is singular — a claim that collapses the instant you write
down our matrix $H(1)$, a grid of $\pm 1$'s with determinant $16$. The formula
does not just underestimate; at $k=1$ it is off by an entire order of magnitude
and predicts exactly the wrong qualitative behavior.

This is a small parable about mathematical hygiene. A formula can look plausible,
factor beautifully, and still be false. The remedy is always the same: exhibit an
explicit object that violates it. One honest matrix outweighs a mountain of
suggestive algebra.

## The bigger picture: Hadamard's conjecture

Why should anyone outside pure algebra care how big a determinant can get?
Because these "maximally perpendicular" sign matrices — Hadamard matrices — are
everywhere in the applied world.

- **Error-correcting codes.** The rows of a Hadamard matrix are as different from
  one another as possible, which makes them ideal codewords. NASA used Hadamard
  codes to transmit photographs back from the Mariner and Voyager space probes,
  where every bit had to survive a journey across the solar system.
- **Signal processing.** The Walsh–Hadamard transform, built directly from these
  matrices, is a fast, multiplication-free cousin of the Fourier transform used
  in image compression and spread-spectrum communication.
- **Experimental design.** Statisticians use Hadamard matrices to plan
  experiments that extract the most information from the fewest trials, balancing
  every factor against every other.

Our $4 \times 4$ story is the first nontrivial rung of an infinite ladder. In
general, for a matrix of size $n$, the same volume reasoning gives a theoretical
ceiling of $n^{n/2} B^n$, and it is reached *exactly when* a Hadamard matrix of
size $n$ exists. For $n = 4$ we get $4^2 = 16$, matching our result. Hadamard
matrices are known to exist whenever $n$ is $1$, $2$, or a multiple of $4$ — at
least, that is the **Hadamard conjecture**, and whether one exists for *every*
multiple of $4$ remains an open problem after more than a hundred years. The
smallest size where nobody knows the answer has, over the decades, been steadily
pushed higher by explicit constructions, but the general question stands
unresolved.

So the modest puzzle we started with — how big can a $4 \times 4$ determinant be?
— is a scale model of a question that reaches into the frontier of combinatorics.
The four-by-four case we can settle completely and beautifully: the answer is
$16\,B^4$, achieved by a perfectly perpendicular sign pattern, and any formula
that says otherwise can be refuted with a single, concrete, four-by-four grid of
plus and minus ones.

## The moral

Three ideas carry the whole story. First, a determinant is a *volume*, and
volumes love right angles. Second, you prove a maximum is achievable by *building
the thing that achieves it* — and here the builder's blueprint is a Hadamard
matrix. Third, when a formula is in doubt, do not argue with it; *exhibit a
counterexample*. A grid of sixteen numbers, a few sign flips, and a determinant of
$16$ was all it took to overturn a plausible-looking claim and reveal the clean,
correct answer underneath.
