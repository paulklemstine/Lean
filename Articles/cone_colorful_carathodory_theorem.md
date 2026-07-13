# The Rainbow at the Origin: A Colorful Theorem for Cones

## A puzzle about balance

Imagine you are holding a bundle of arrows, all emanating from a single point. Some
point up, some down, some to the sides. When can you attach weights to these arrows
— pulling harder on some than on others — so that the whole system balances
perfectly and the tugging cancels out to nothing?

This is not an idle question. It is the geometric heart of how forces balance in
mechanics, how prices clear in economics, and how solutions to systems of
inequalities are found in optimization. And it turns out to have a beautiful,
surprising answer that involves — of all things — *color*.

To make the puzzle precise, place the arrows in $d$-dimensional space, each one a
vector $v$. Attaching a nonnegative weight $w \ge 0$ to an arrow and adding
everything up, we ask: can we choose weights, not all zero, so that

$$\sum_i w_i\, v_i = 0?$$

When the answer is yes, we say the collection of arrows **captures the origin**.
Geometrically, the arrows together with all their nonnegative combinations sweep
out a *convex cone* — an infinite wedge opening out from the origin — and capturing
the origin means that wedge is "balanced" enough to wrap all the way around and
return home.

## From one bag to many: the colorful twist

The classical version of this story concerns a single bag of arrows. But
mathematics becomes far richer when we introduce color. Suppose we have not one bag
but several, each painted a distinct color: a red bag, a blue bag, a green bag, and
so on. Suppose further that *each individual bag* already captures the origin — red
arrows alone can be balanced, blue arrows alone can be balanced, and so forth.

Now we play a stricter game. We are allowed to keep exactly **one arrow of each
color** — a single red, a single blue, a single green — forming what combinatorial
geometers call a *colorful transversal* or *rainbow selection*. The question is
audacious:

> Can we always pick a rainbow selection that *still* captures the origin?

It is far from obvious that this should be possible. Each bag captures the origin
using potentially many of its arrows working in concert. Throwing away all but one
arrow per color is a drastic reduction. Why should any rainbow survive the cut?

For ordinary convex combinations — where weights must sum to one, so the balance
point is a genuine average rather than the origin — this is the celebrated
**Colorful Carathéodory Theorem**, discovered by Imre Bárány in 1982. It is one of
the load-bearing pillars of modern discrete geometry, underlying results on how
point sets can be partitioned and how deeply a point can be buried inside a cloud
of others.

Our story asks the analogous question for *cones* rather than *hulls*, and pins the
origin as the distinguished target. The results below settle the shape of the
answer.

## The magic of the origin: homogeneity

The first discovery is a small miracle that makes everything else possible. There
are two different-looking ways to ask that a set of vectors "captures the origin":

- **The conical way.** There exist nonnegative weights $w_i \ge 0$, *not all
  zero*, with $\sum_i w_i v_i = 0$.
- **The convex way.** There exist nonnegative weights $w_i \ge 0$ that *sum to
  one*, with $\sum_i w_i v_i = 0$.

The convex version is more demanding: the weights must form a genuine probability
distribution. The conical version only asks that at least one weight be strictly
positive. One might expect these to be genuinely different conditions.

**They are exactly the same.** This is the *homogeneity bridge*:

> **Homogeneity Bridge.** For any finite family of vectors, the origin is a
> nontrivial conical combination if and only if it is a convex combination.

The proof is a single elegant gesture. Given nonnegative weights $w_i$ that are not
all zero and satisfy $\sum_i w_i v_i = 0$, let $S = \sum_i w_i > 0$ be their total.
Divide every weight by $S$. The new weights $w_i / S$ are still nonnegative, they
still annihilate the vectors — because $\frac{1}{S}\sum_i w_i v_i = \frac{1}{S}
\cdot 0 = 0$ — and now they sum to exactly one. We have rescaled a conical balance
into a convex one. The reverse direction is even easier: weights summing to one are
certainly not all zero, so a convex balance is already a conical one.

Why does this work? Because the origin is *special*. Rescaling all weights by a
common positive factor slides the balance point along a ray from the origin — but
the origin is the one point that sits still under such rescaling. It is the fixed
point of homogeneity. This is the entire reason the conical world and the convex
world speak the same language *at the origin*, and it is the bridge across which
every classical result can be carried into the world of cones.

## Counting colors: the sharp threshold

With the bridge in hand, we can attack the colorful question — and here a subtle
surprise emerges about *how many colors we need*.

A tempting first guess: in $d$-dimensional space, $d$ colors should suffice, one
per dimension. This guess is **wrong**, and it already fails in the simplest
possible setting: the number line, $d = 1$.

On the line, consider a single color class $\{1, -1\}$. These two numbers capture
the origin conically: take weight $1$ on each and $1\cdot 1 + 1\cdot(-1) = 0$. Yet
a rainbow selection from a *single* color must pick just one number — either $1$ or
$-1$ — and a lone nonzero number can never balance to zero. So one color is not
enough, even though the guess $d = 1$ predicted it would be.

The correct threshold is one higher:

> **Cone Colorful Carathéodory in Dimension One.** Given $r \ge 2$ color classes of
> real numbers, where each class captures the origin conically, there is a rainbow
> selection — one number chosen from each class — that also captures the origin.
> The threshold $r \ge 2$ is sharp.

The proof is a clean piece of sign-reasoning. First, a warm-up classification: a
finite set of real numbers captures the origin conically if and only if it either
**contains zero** outright, or **straddles** the origin — containing at least one
strictly positive and at least one strictly negative number. (If all numbers share
a sign, every nonnegative combination inherits that sign and can never vanish.)

Now the rainbow construction. If any color class contains $0$, pick that $0$ — a
single zero already balances by itself. Otherwise every class straddles the origin,
so each has a positive representative and a negative representative. Pick the
positive number $a$ from the first color and the negative number $b$ from the
second (the remaining colors can contribute anything). These two, $a > 0$ and
$b < 0$, straddle the origin, and we can balance them explicitly: weight $-b > 0$ on
$a$ and weight $a > 0$ on $b$ gives

$$(-b)\cdot a + a \cdot b = -ab + ab = 0.$$

The rainbow captures the origin. This is why the count must be at least two: we need
two colors to guarantee one that can supply a positive number and one that can
supply a negative number.

## How few arrows do you really need?

The final result rounds out the theory by answering an efficiency question. Suppose
the origin is captured by an enormous family of vectors in $d$-dimensional space.
How many of them are truly necessary?

> **Conic Carathéodory Bound.** In $d$-dimensional space, if the origin is a
> nontrivial conical combination of a finite family of vectors, then it is already a
> nontrivial conical combination of at most $d + 1$ of them.

This is the cone-shaped shadow of Carathéodory's original 1907 theorem, which says
any point inside the convex hull of a set in $\mathbb{R}^d$ lies in the hull of at
most $d+1$ of its points. Through the homogeneity bridge, capturing the origin
conically is the same as capturing it convexly, so we can lean on the classical
result — but the proof also reveals the underlying *pruning mechanism*.

Here is the idea. If our family has more than $d+1$ vectors, they are too crowded to
be independent: there must exist a nontrivial **affine dependence**, real
coefficients $u_i$ that sum to zero and satisfy $\sum_i u_i v_i = 0$, with at least
one $u_i \neq 0$. This dependence is a "free direction" we can add to our balancing
weights without disturbing the balance. By sliding along it just far enough, we
drive one of the weights down to exactly zero — eliminating a vector while
preserving both the balance and the sum-to-one condition. Repeat until only $d+1$
vectors remain. Each step is a controlled deflation; the total never loses its
equilibrium.

## Why it matters

These theorems are miniatures, but they illuminate a big theme: the deep unity
between *cones* and *hulls* at the origin, and the role of color in forcing
structure to survive drastic selection.

Colorful Carathéodory-type theorems are the engine behind some of the most striking
results in combinatorial geometry, including the First Selection Lemma (every large
point set has a point lying in a positive fraction of all the triangles it spans)
and Tverberg-type partition theorems. The conical viewpoint speaks directly to
optimization and to the theory of linear inequalities: capturing the origin in a
cone is precisely the condition under which a system of homogeneous inequalities has
no strictly feasible solution — a *certificate of infeasibility* in the language of
Farkas' lemma and linear programming duality.

The colorful refinement adds a scheduling flavor: if several independent "sources"
each individually force a balance, then a single representative drawn from each
still forces one. In applications where each color is a constraint block, a
resource, or an agent, this says that diversity is preserved under the balance — a
rainbow always survives.

And it all rests on a one-line miracle: at the origin, and only at the origin,
rescaling changes nothing. Homogeneity is the quiet fixed point around which the
whole colorful theory turns.
