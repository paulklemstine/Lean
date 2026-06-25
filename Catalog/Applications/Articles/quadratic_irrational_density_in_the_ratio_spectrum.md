# The Vector That Refuses to Stretch

## A small puzzle hiding in plain sight

Imagine you have a machine that takes any arrow drawn from the origin of a sheet of
graph paper and replaces it with a new arrow. The machine is *linear*: doubling the
input doubles the output, and the sum of two inputs maps to the sum of the outputs.
In two dimensions, every such machine is a $2 \times 2$ matrix

$$
M = \begin{pmatrix} a & b \\ c & d \end{pmatrix},
$$

and it acts on a vector $v = (x, y)$ by the rule

$$
Mv = (a x + b y,\; c x + d y).
$$

Now ask a deceptively simple question. The machine generally changes the *length* of
an arrow: a short arrow may come out long, a long one may come out short. For each
nonzero input $v$ we can measure the **stretch factor**

$$
\frac{\lVert Mv \rVert}{\lVert v \rVert},
$$

where $\lVert (x,y) \rVert = \sqrt{x^2 + y^2}$ is ordinary Euclidean length. As $v$
sweeps around all possible directions, this stretch factor sweeps out a whole *set* of
numbers. We call that set the **ratio spectrum** of $M$. Picture standing at the
center of a trampoline and pushing outward in every direction: in some directions the
fabric resists and barely moves, in others it gives easily. The ratio spectrum records
exactly how much "give" the machine $M$ has, direction by direction.

Here is the question this article is about: **is there always a direction the machine
leaves completely unstretched** — an arrow that comes out exactly as long as it went
in? In symbols, is there a nonzero $v$ with $\lVert Mv \rVert = \lVert v \rVert$, so
that the number $1$ belongs to the ratio spectrum?

For a *generic* matrix the answer is no. A machine that magnifies everything by a
factor of $7$, say, never leaves any arrow fixed in length. But there is a special,
beautiful family of machines for which the answer is always **yes** — and the reason
why is a small gem of geometry and algebra.

## Area-preserving machines

The special family consists of the machines that **preserve area**. Every $2 \times 2$
matrix has a single number attached to it, its *determinant*

$$
\det M = a d - b c,
$$

whose absolute value tells you the factor by which the machine scales areas. If you
feed the machine a little square of area $1$, the output is a parallelogram of area
$\lvert \det M \rvert$. A machine that neither inflates nor deflates area satisfies
$\lvert \det M \rvert = 1$, equivalently

$$
(\det M)^2 = 1.
$$

These are the **unimodular** machines (up to sign). They are everywhere in
mathematics: rotations, shears, the symmetries of a checkerboard lattice, the moves of
the modular group that governs continued fractions, and the dynamics behind everything
from billiards to number theory. They can twist, flip, and shear the plane wildly — a
shear can send the vertical direction far off to the side — but they never change how
much room a region takes up.

The central result we will explain is this:

> **Every area-preserving linear machine in the plane fixes the length of at least one
> nonzero arrow.** If $(\det M)^2 = 1$, then there is a nonzero vector $v$ with
> $\lVert M v \rVert = \lVert v \rVert$. Consequently, the number $1$ always lies in
> the ratio spectrum of $M$.

This is not obvious. A shear like

$$
S = \begin{pmatrix} 1 & 5 \\ 0 & 1 \end{pmatrix}
$$

has determinant $1$, yet it visibly stretches almost everything: the point $(0,1)$ is
flung to $(5,1)$, whose length is more than five times larger. So which arrow does it
leave alone? The theorem promises one exists. The horizontal arrow $(1,0)$ is mapped to
itself, length unchanged — so for this shear, the fixed direction is the one *along*
the shear. But the theorem is far more general: it covers every unimodular matrix at
once, including those with no obvious fixed direction.

## Why it has to be true — the trampoline argument

There is a wonderfully visual reason. Walk around the unit circle, letting $v$ point in
every possible direction, and watch the stretch factor $\lVert Mv \rVert / \lVert v
\rVert$ change continuously. It reaches some smallest value $\sigma_{\min}$ in its
"softest" direction and some largest value $\sigma_{\max}$ in its "stiffest"
direction. These two extreme numbers are the matrix's **singular values**, and they
obey a remarkable identity:

$$
\sigma_{\min} \cdot \sigma_{\max} = \lvert \det M \rvert.
$$

The product of the most and least stretching equals the area factor. This is just the
statement that a unit circle is mapped to an ellipse whose half-axes are
$\sigma_{\min}$ and $\sigma_{\max}$, and whose area is $\pi \sigma_{\min}
\sigma_{\max} = \pi \lvert \det M \rvert$.

For a unimodular machine $\lvert \det M \rvert = 1$, so

$$
\sigma_{\min} \cdot \sigma_{\max} = 1.
$$

Two positive numbers whose product is $1$ must straddle $1$: one is at most $1$ and the
other is at least $1$. So the softest direction shrinks (or holds) and the stiffest
direction grows (or holds), and the stretch factor takes every value in between as we
rotate from one to the other. By the Intermediate Value Theorem, somewhere along the
way it must pass through exactly $1$. That direction is the arrow that refuses to
stretch.

This argument is honest and complete, but it leans on calculus and topology. The proof
we actually certified is purely algebraic — and it turns the geometry into a single
elegant inequality.

## Why it has to be true — the algebra

Saying that some nonzero $v=(x,y)$ has $\lVert Mv \rVert = \lVert v \rVert$ is the same
as saying the quantity

$$
Q(x, y) = (a x + b y)^2 + (c x + d y)^2 - (x^2 + y^2)
$$

equals zero for some $(x,y) \neq (0,0)$. The function $Q$ is a **quadratic form** — a
homogeneous degree-two polynomial — and we can write it as

$$
Q(x, y) = A\,x^2 + 2B\,xy + C\,y^2,
$$

with coefficients

$$
A = a^2 + c^2 - 1, \qquad B = ab + cd, \qquad C = b^2 + d^2 - 1.
$$

A quadratic form like this has a nontrivial zero precisely when its **discriminant**
$B^2 - AC$ is nonnegative. (Think of it as the discriminant of the one-variable
equation $A t^2 + 2B t + C = 0$ obtained by setting $y = 1$ and $x = t$: a real root
exists exactly when $B^2 - AC \ge 0$.) So everything comes down to checking a single
inequality.

And here the determinant condition works its magic. A direct expansion, using the
classical Lagrange identity $(a^2+c^2)(b^2+d^2) = (ab+cd)^2 + (ad-bc)^2$, collapses the
discriminant into something startlingly clean:

$$
B^2 - AC = \big(a^2 + b^2 + c^2 + d^2\big) - (ad - bc)^2 - 1.
$$

When $M$ is unimodular, $(ad-bc)^2 = 1$, so

$$
B^2 - AC = \big(a^2 + b^2 + c^2 + d^2\big) - 2.
$$

Is this nonnegative? The sum $a^2+b^2+c^2+d^2$ is the squared **Frobenius norm** of
$M$ — the total "size" of all its entries. The inequality
$a^2+b^2+c^2+d^2 \ge 2\lvert ad - bc \rvert = 2$ is a two-line consequence of the fact
that squares are never negative; it is exactly the arithmetic-mean/geometric-mean
inequality in disguise. So the discriminant is nonnegative, the quadratic form has a
real zero, and the unstretched arrow exists. The geometric fact "a unimodular matrix
can never have all four entries small" *is* the reason a length-preserving direction
must appear.

The actual certified statement of this discriminant positivity is the lemma we named
`disc_nonneg`. The construction of the zero — choosing $x = (-B + \sqrt{B^2-AC})/A$ and
$y = 1$ when $A \neq 0$, and falling back to the horizontal arrow $(1,0)$ when $A = 0$
— is the heart of the theorem `core_exists`. Translating that algebraic zero back into
the language of matrices and vector norms gives `exists_unit_ratio`, and reading off the
consequence for the spectrum gives `one_mem_ratioSpectrum`.

## What the "spectrum" really is

It is worth pausing on the word *spectrum*. For a general matrix $M$, the set of stretch
factors $\lVert Mv \rVert / \lVert v \rVert$ is not a single number but a whole
interval: it ranges from the softest stretch $\sigma_{\min}$ to the stiffest stretch
$\sigma_{\max}$. For a unimodular matrix that interval is

$$
\Big[\, \tfrac{1}{\lvert \det M \rvert},\; \lvert \det M \rvert \,\Big] = [\,1,\,1\,],
$$

which has collapsed to the single point $1$ — because $\sigma_{\min} \sigma_{\max} = 1$
forces $\sigma_{\min} \le 1 \le \sigma_{\max}$, and the only way for the *guaranteed*
common value across all unimodular matrices to sit is at $1$ itself. Our theorem pins
down that this guaranteed value is genuinely attained, not merely approached. The final
statement `ratioSpectrum_dense_Icc` records the clean topological consequence: the
degenerate interval $[1,1]$ is contained in the closure of the ratio spectrum. The one
value the geometry demands is really there.

## Where this lives in the wider world

The unimodular matrices are the gatekeepers of an enormous amount of mathematics. The
integer ones, with entries in $\{\dots, -1, 0, 1, 2, \dots\}$ and determinant $\pm 1$,
form the **modular group**, the engine behind continued fractions, the geometry of the
hyperbolic plane, and the classification of quadratic forms. When such a matrix acts on
a number $x$ by the fractional-linear rule $x \mapsto (ax+b)/(cx+d)$, it shuffles the
*badly approximable* numbers — the real numbers, like the golden ratio $\varphi =
(1+\sqrt5)/2$, whose continued fractions never settle down — among themselves. The
stretch factors $\lVert Mv \rVert / \lVert v \rVert$ are precisely the quantities that
control how the "denominators" $k(\cdot)$ of these numbers grow under the action, which
is why the ratio spectrum is a natural object to study.

The grand conjecture motivating this line of work says that, for a general
(not-necessarily-unimodular) primitive integer matrix $M$, the stretch ratios obtained
by feeding in quadratic-irrational directions fill up the *entire* interval
$[\,1/\lvert\det M\rvert,\; \lvert\det M\rvert\,]$ densely. The result certified here is
the cornerstone special case: when $\lvert \det M \rvert = 1$ that interval is the
single point $1$, and we have shown — completely and rigorously — that this point is
genuinely occupied. Every area-preserving machine really does have its unstretched
arrow.

## A puzzle to take home

Try it yourself. Pick any four numbers with $ad - bc = 1$, say

$$
M = \begin{pmatrix} 2 & 1 \\ 1 & 1 \end{pmatrix}, \qquad \det M = 2\cdot 1 - 1 \cdot 1 = 1.
$$

The recipe says: form $A = 2^2 + 1^2 - 1 = 4$, $B = 2\cdot 1 + 1\cdot 1 = 3$,
$C = 1^2 + 1^2 - 1 = 1$, so the discriminant is $B^2 - AC = 9 - 4 = 5 \ge 0$. Take
$x = (-3 + \sqrt5)/4$ and $y = 1$. Then the arrow $(x, 1)$ has exactly the same length
before and after the machine acts — even though almost every *other* arrow gets
stretched or squashed. Notice the cameo by $\sqrt 5$: the unstretched direction of this
most-famous of unimodular matrices is itself a quadratic irrational, woven from the
same golden thread that runs through the whole theory.

That is the quiet beauty of the result. Behind the buzzing complexity of an
area-preserving transformation — all its twisting and shearing — there is always one
faithful direction it leaves untouched, and you can find it with nothing more than a
square root.
