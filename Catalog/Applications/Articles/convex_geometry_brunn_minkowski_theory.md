# When Shapes Add Up: The Surprising Arithmetic of Size

Imagine you have two clouds of points scattered along a straight wire — say, two
piles of beads threaded on a string. Now perform a strange operation: take every
bead in the first pile, and every bead in the second pile, and for each pair slide
one bead along the wire by the position of the other. The set of all the new
landing spots is a brand-new pile of beads. Mathematicians call this the
**Minkowski sum** of the two piles.

Here is the question that turns out to have a beautiful answer: *how big is the new
pile?* If the first pile occupies a total length of $1$ centimeter, and the second
occupies a length of $2$ centimeters, how much wire does their sum occupy? Could
it be smaller than either? Larger than both? Is there a rule?

There is a rule, and it is one of the most far-reaching facts in all of geometry.
It says that **adding shapes can never lose size — in fact, it always gains at
least as much as you put in.** On a line, the precise statement is

$$\operatorname{vol}(A+B) \;\ge\; \operatorname{vol}(A) + \operatorname{vol}(B).$$

The length of the sum is at least the sum of the lengths. This is the
one-dimensional **Brunn–Minkowski inequality**, and it is the seed from which an
entire forest of modern mathematics grows.

## What is a Minkowski sum, really?

Let's be precise about the operation. Given two sets of real numbers $A$ and $B$,
their Minkowski sum is

$$A + B \;=\; \{\, a + b \;:\; a \in A,\; b \in B \,\}.$$

You take *every* element of $A$, add to it *every* element of $B$, and collect all
the answers. If $A = \{0, 10\}$ and $B = \{0, 1, 2\}$, then
$A + B = \{0, 1, 2, 10, 11, 12\}$ — two copies of $B$, one anchored at $0$ and one
anchored at $10$.

The most important special case is when $A$ and $B$ are **intervals**, solid
segments of the line. If $A = [0, 1]$ (every point from $0$ to $1$) and
$B = [0, 2]$, then their sum is $[0, 3]$: the smallest reachable point is
$0 + 0 = 0$ and the largest is $1 + 2 = 3$, and every value in between is hit. The
lengths are $1$, $2$, and $3$ — and indeed $3 = 1 + 2$. For intervals, the
inequality is an *equality*. Intervals are the "perfect adders," the shapes that
lose nothing and gain nothing.

What the Brunn–Minkowski inequality tells us is that intervals are the *worst
case*. No matter how jagged, scattered, or full of holes your sets $A$ and $B$
are, their sum is always **at least** as long as the interval case would predict.
Adding messy shapes can only help.

## Why isn't this obvious?

At first glance you might think: of course the sum is big — we're combining two
sets. But Minkowski addition is sneaky. Sets can overlap with themselves in the
sum, folding back on top of each other, and you might fear that all that folding
could *shrink* the total. After all, $A + B$ is built from many overlapping copies
of $B$ (one shifted copy for each point of $A$), and overlapping copies share
territory.

Consider a concrete worry. Let $A = \{0, 1\}$ — just two points, with total length
zero (single points are infinitely thin). Let $B = [0, 1]$, a unit interval. Then

$$A + B = [0,1] \cup [1,2] = [0,2],$$

an interval of length $2$. The inequality says
$\operatorname{vol}(A+B) \ge \operatorname{vol}(A) + \operatorname{vol}(B) = 0 + 1 = 1$,
and indeed $2 \ge 1$. The two thin points *spread* the interval out rather than
collapsing it. The folding fear is unfounded: spreading always wins.

So the content of the theorem is genuine. It is a statement that the operation of
addition, applied to *sizes*, behaves super-additively. And proving it rigorously
requires a genuinely clever idea.

## The trick: anchor the corners

Here is the elegant argument, valid whenever $A$ and $B$ are **compact** — closed
and bounded, with no points escaping to infinity and no missing boundary points.
Compactness guarantees that $A$ has a genuine largest element, call it $a$ (its
supremum, which it actually attains), and that $B$ has a genuine smallest element,
call it $b$ (its infimum).

Now form two specific shifted copies *inside* the sum $A + B$:

- **$U = A + \{b\}$**: the whole set $A$, slid to the right by $b$. Because $b$ is
  a member of $B$, every point of $U$ is a legitimate element of $A + B$. And
  sliding a set rigidly never changes its length, so
  $\operatorname{vol}(U) = \operatorname{vol}(A)$.

- **$V = \{a\} + B$**: the whole set $B$, slid to the right by $a$. Because $a$ is
  a member of $A$, every point of $V$ lies in $A + B$ too, and again
  $\operatorname{vol}(V) = \operatorname{vol}(B)$.

Both $U$ and $V$ live inside $A + B$, so their union does as well:
$U \cup V \subseteq A + B$. The decisive observation is *how little they overlap*.
The set $U = A + b$ consists of points no larger than $a + b$ (since the biggest
point of $A$ is $a$). The set $V = a + B$ consists of points no smaller than
$a + b$ (since the smallest point of $B$ is $b$). The two copies meet only where
they are squeezed against the single common value $a + b$:

$$U \cap V \subseteq \{a + b\}.$$

A single point has length zero. So the overlap is negligible, and the lengths
simply add:

$$\operatorname{vol}(A+B) \;\ge\; \operatorname{vol}(U \cup V)
   \;=\; \operatorname{vol}(U) + \operatorname{vol}(V)
   \;=\; \operatorname{vol}(A) + \operatorname{vol}(B).$$

That's the entire proof. We placed a copy of $A$ flush against the right end of the
sum and a copy of $B$ flush against the left end of the *same* sum, arranged so
they kiss at exactly one point, and let their lengths combine. The cleverness is
entirely in the *placement* — anchoring on the extreme corners $a = \sup A$ and
$b = \inf B$ so the two copies can't double-count any real length.

## A wider sky: why mathematicians care

In one dimension the inequality reads $\operatorname{vol}(A+B) \ge
\operatorname{vol}(A) + \operatorname{vol}(B)$. In $n$ dimensions it sharpens into
the form that gives the theorem its fame:

$$\operatorname{vol}(A+B)^{1/n} \;\ge\; \operatorname{vol}(A)^{1/n}
   + \operatorname{vol}(B)^{1/n}.$$

Take $n=1$ and the exponent $1/n$ becomes $1$, recovering exactly the statement we
proved. The higher-dimensional version says that the $n$-th *root* of volume — a
quantity with the units of length — is super-additive under Minkowski addition.
Equivalently, the map "shape $\mapsto$ (its volume)$^{1/n}$" is **concave**:
averaging two shapes geometrically produces something at least as voluminous as
averaging their root-volumes numerically.

This single inequality is a powerhouse:

- **The isoperimetric inequality.** Among all shapes of a given perimeter, the
  circle (in the plane) and the sphere (in space) enclose the most area or volume.
  This ancient optimization — the reason soap bubbles are round and raindrops tend
  toward spheres — falls out of Brunn–Minkowski by adding a tiny ball to a shape
  and watching how fast its volume grows. The rate of growth *is* the surface
  area, and Brunn–Minkowski controls it.

- **The shape of shadows.** Slice a convex body by a moving family of parallel
  planes and record the area of each cross-section. Brunn's original theorem says
  the *root* of that cross-sectional area, as a function of position, is a concave
  function — the body bulges in the middle and tapers smoothly, never pinching
  inward. A lemon is convex; an hourglass is not.

- **Information and probability.** Replace "volume" with "spread of a probability
  distribution" and Brunn–Minkowski morphs into the **entropy power inequality**,
  a cornerstone of information theory that governs how noise accumulates when
  independent signals are added. The same super-additivity that makes shapes grow
  makes uncertainty grow.

- **Additive number theory.** Replace continuous length with *counting* and you
  reach the discrete cousin: for finite sets of integers,
  $|A + B| \ge |A| + |B| - 1$, the Cauchy–Davenport phenomenon. Sumsets of
  numbers, like sumsets of shapes, refuse to be small. This bridge — from the
  geometry of measure to the combinatorics of counting — is one of the liveliest
  frontiers of modern mathematics.

## The meaning of "equality"

We saw that intervals add perfectly: $[0,1] + [0,2] = [0,3]$ with lengths
$1 + 2 = 3$. It turns out this is essentially the *only* way to achieve equality.
If $\operatorname{vol}(A+B)$ exactly equals $\operatorname{vol}(A) +
\operatorname{vol}(B)$, then — apart from negligible adjustments — both $A$ and $B$
must already be intervals (or one of them a single point). Any genuine
"raggedness," any gap of positive length inside one of the sets, forces the sum to
be *strictly* longer than the floor predicts.

You can feel this with a quick experiment. Take $A = [0,1] \cup [3,4]$, a set with
a hole in the middle, of total length $2$. Add $B = [0,1]$, of length $1$. The sum
is $[0,2] \cup [3,5]$, of total length $4$ — and $4 > 2 + 1 = 3$. The hole did not
shrink the answer; it *enlarged* it. Spreading wins again, and strictly so. Only
the gapless, hole-free intervals sit exactly on the boundary.

## A small theorem with a long reach

The one-dimensional Brunn–Minkowski inequality is, on its face, a modest claim
about lengths on a line. But it carries the full DNA of a vast theory. The corner-
anchoring proof we walked through — slide $A$ to the right edge, slide $B$ to the
left edge, let them touch at one point — is the cleanest possible glimpse of why
geometric addition is super-additive. The higher-dimensional theorem, the
isoperimetric inequality, the entropy power inequality, and the arithmetic of
sumsets are all, in a sense, echoes of this single line of reasoning.

There is something quietly profound in the lesson. When you combine two objects by
adding all their possibilities together, the result is never poorer than the parts
suggest. Mixing, in this geometric sense, is always at least fair and usually
generous. Shapes, like ideas, grow when you let them interact — and the
mathematics guarantees it.
