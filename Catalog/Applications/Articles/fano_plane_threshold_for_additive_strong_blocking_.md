# Six Out of Seven: The Hidden Rule of the Fano Plane

## A puzzle with seven dots

Imagine a tiny universe made of just seven points. They cannot be arranged on an
ordinary sheet of paper in the way you might expect, because this universe obeys a
stranger kind of geometry. Yet it is real, it is beautiful, and mathematicians have
been fascinated by it for over a century. It is called the **Fano plane**, and it is
the smallest possible *projective plane* — the smallest world in which the familiar
phrase "any two points determine a line" still holds, but where there are no parallel
lines at all. Every pair of lines meets, and every pair of points joins.

The Fano plane has seven points and seven lines. Each line contains exactly three
points, and each point lies on exactly three lines. The whole structure is perfectly
self-symmetric: points and lines play interchangeable roles. If you have ever seen a
triangle with its three midpoints marked, plus a circle through those midpoints, with
seven dots and seven "lines" (six straight, one curved), you have seen a picture of the
Fano plane.

In this article we explore a simple-sounding question about this little world that turns
out to connect to the frontier of modern coding theory:

> **How many of the seven points do you need to "cover" the plane robustly — so that
> every line is not merely touched, but firmly straddled?**

The answer, as we will see, is **six**. Not five. Not seven. Exactly six. And the way
this number arises reveals a deep principle that governs error-correcting codes used in
real communication systems.

## Blocking, and then blocking harder

Let us be precise about what "covering" means. A **blocking set** in a geometry is a
collection of points that meets every line — every line passes through at least one
chosen point. Blocking sets are the geometric heart of many combinatorial puzzles: think
of placing guards so that no corridor goes unwatched.

But ordinary blocking is a weak requirement. A more demanding and more useful notion is a
**strong blocking set** (sometimes called a *cutting blocking set*). Here we require that
the chosen points meet every line in a *spanning* way: the points of our set lying on any
given line must be enough to generate that entire line.

In a projective *plane*, a line is one-dimensional, and it is spanned by any two distinct
points on it. So in this setting the definition becomes vivid and concrete:

> A set of points is a **strong blocking set** of a projective plane if and only if it
> meets **every line in at least two points**.

This is exactly what is called a **double blocking set**: every line is hit at least
twice. We do not just touch each line; we pin it down at two places, enough to reconstruct
the whole line from our chosen points.

The central question is now sharp: *what is the smallest double blocking set of the Fano
plane?*

## A convenient way to name the seven points

To reason cleanly, it helps to label the seven points by the numbers $0, 1, 2, 3, 4, 5, 6$,
which we treat as the integers *modulo 7* — that is, we count in a circle, so that after
$6$ we wrap around to $0$. This is the so-called **cyclic** or **Singer** model of the
Fano plane.

The magic ingredient is the set $\{0, 1, 3\}$, a *perfect difference set* modulo $7$:
the six nonzero differences between its elements,
$$
1-0,\; 3-0,\; 0-1,\; 3-1,\; 0-3,\; 1-3 \pmod 7,
$$
which work out to $1, 3, 6, 2, 4, 5$, hit **every** nonzero residue modulo $7$ exactly
once. Because of this, if we "rotate" the triple $\{0,1,3\}$ around the circle, we obtain
exactly the seven lines of the Fano plane. Concretely, for each $i$ in $\{0,1,\dots,6\}$
define the line
$$
\ell_i = \{\, i,\; i+1,\; i+3 \,\} \pmod 7 .
$$
The seven lines are then
$$
\{0,1,3\},\;\{1,2,4\},\;\{2,3,5\},\;\{3,4,6\},\;\{4,5,0\},\;\{5,6,1\},\;\{6,0,2\}.
$$
You can check by hand that every pair of points appears together in exactly one of these
lines, and every pair of lines shares exactly one point. That is the Fano plane.

Two facts about this model are worth stating because everything hinges on them.

**Fact 1 (every line has three points).** Each $\ell_i = \{i, i+1, i+3\}$ contains exactly
three distinct points. (The offsets $0, 1, 3$ are distinct modulo $7$, so no two of the
three coincide.)

**Fact 2 (any two points are collinear).** Given any two distinct points $a \neq b$, there
is a line containing both of them. This is the defining incidence axiom of a projective
plane, and in the cyclic model it follows directly from the perfect-difference-set
property: the difference $b - a$ is some nonzero residue, and the difference set guarantees
a rotation of $\{0,1,3\}$ that contains both.

## Why the answer is six

Now we can solve the puzzle with a single elegant idea.

**The upper bound: six points are enough.** Take all seven points and remove just one — say,
remove the point $0$. This leaves a set $S$ of six points, the complement of a single point.
Does $S$ meet every line in at least two points? Each line has three points. Removing the
single point $0$ can delete at most one point from any given line. So every line still
retains at least two of its points inside $S$. Therefore $S$ is a strong blocking set, and
it has size six. We have exhibited a double blocking set of six points.

**The lower bound: five points are never enough.** Suppose $S$ is a strong blocking set, and
let $T$ be the set of points *not* in $S$ — its complement. The condition "$S$ meets every
line in at least two of its three points" translates exactly into "$T$ contains at most one
point of every line." In other words, $T$ never contains two points of the same line.

But here is the punchline, and it is Fact 2: in the Fano plane **any two distinct points lie
on a common line**. So if $T$ contained two distinct points, those two would share a line,
and $T$ would contain two points of that line — a contradiction. Hence $T$ can contain *at
most one point*. That means $T$ has size at most $1$, and so $S$ has size at least
$7 - 1 = 6$.

Putting the two halves together:

> **The Fano-plane threshold.** The minimum size of a strong blocking set of the Fano plane
> is exactly **six**.

What is more, the same argument tells us *which* sets achieve the minimum. A strong blocking
set of size six must have a complement $T$ of size exactly one — a single point. So the
smallest strong blocking sets are precisely the seven complements-of-a-point,
$$
\text{univ} \setminus \{p\}, \qquad p \in \{0,1,2,3,4,5,6\}.
$$
There are exactly **seven** of them, one for each point you might choose to leave out. The
extremal configurations are not exotic; they are simply "all but one."

## From dots and lines to error-correcting codes

So far this might look like a charming but isolated combinatorial fact. It is not. Strong
blocking sets are the geometric face of a central object in information theory: **minimal
linear codes**.

A *linear code* is a way of adding redundancy to data so that errors introduced in
transmission can be detected or corrected. A *codeword* is a particular encoded message.
A code is called **minimal** when none of its nonzero codewords is "covered" by another —
formally, no codeword's support (the set of positions where it is nonzero) is contained in
another's. Minimal codes are prized because they enable elegant *secret-sharing schemes*
and efficient decoding procedures: in a minimal code, the access structure of who-can-
recover-the-secret is determined directly by the codewords.

There is a precise dictionary, the **projective-system correspondence**, translating
between codes and geometry:

- A linear code of dimension $k$ corresponds to a multiset of points in the projective
  space $\mathrm{PG}(k-1, q)$, where $q$ is the size of the underlying alphabet.
- The *length* of the code equals the number of points.
- The code is **minimal** if and only if the corresponding point set is a **strong
  blocking set**.

Under this dictionary, *the shortest possible minimal code of a given dimension* becomes
*the smallest strong blocking set of a given projective space*. Our Fano-plane result
therefore reads, in coding language:

> The shortest nondegenerate minimal binary linear code of dimension $3$ has length $6$.

Here "binary" means the alphabet has $q = 2$ symbols, and "dimension $3$" corresponds to the
plane $\mathrm{PG}(2, 2)$ — the Fano plane. The number six is the optimal length, and our
seven extremal sets correspond to the essentially-unique shortest such codes.

## A bound that the Fano plane hits exactly

Researchers studying minimal codes — among them Alfarano, Borello and Neri, and
independently Davydov, Giulietti, Marcugini and Pambianco — established a general lower
bound on how short a minimal code (equivalently, how small a strong blocking set) can be.
For dimension $k$ over an alphabet of size $q$, every strong blocking set in
$\mathrm{PG}(k-1, q)$ must have at least
$$
(k-1)(q+1)
$$
points. This bound is one of the cornerstones of the theory.

For the Fano plane we have $k = 3$ and $q = 2$, so the bound predicts at least
$$
(k-1)(q+1) = (3-1)(2+1) = 2 \cdot 3 = 6
$$
points. And we proved the true minimum is *exactly* six. The Fano plane does not merely
*satisfy* the general bound — it **saturates** it, meeting it with perfect equality. The
smallest nontrivial projective plane is, in this precise sense, extremal: it is as efficient
as the general theory permits.

This tightness is the heart of the result. It is one thing to verify by brute force that six
points suffice and five do not; it is another to recognize that the number six is exactly the
value $(k-1)(q+1)$ handed down by a theorem about *all* minimal codes. The Fano plane is the
first and cleanest witness that this universal bound can be achieved.

## Why saturation is special

One might guess that all projective planes are this efficient. They are not. As soon as we
move to larger planes $\mathrm{PG}(2, q)$ with $q = 3, 4, 5, \dots$, the minimum size of a
double blocking set typically *exceeds* the general bound $2(q+1)$. The minimum tends to
grow more like $3q$, leaving a genuine gap between what the universal theory guarantees and
what the geometry actually requires. The Fano plane's exact saturation at $q = 2$ is, in
this light, a small miracle of the smallest case — an exceptional point of perfect
efficiency.

This raises a tantalizing research program. Do *binary* projective spaces of higher
dimension, $\mathrm{PG}(N, 2)$, also saturate the bound — does $\mathrm{PG}(3, 2)$ with its
fifteen points have minimum strong blocking set of size exactly $9 = 3 \cdot 3$? Does the
phenomenon of saturation belong to the alphabet $q = 2$ rather than to the plane dimension?
And what happens for the richer *additive* strong blocking sets, defined over larger fields
$\mathrm{GF}(q^h)$, of which the case studied here ($h = 1$) is the ordinary linear shadow?
Early reasoning suggests that the additive world may break the symmetry, allowing strong
blocking configurations *shorter* than six — a strict separation between additive and linear
codes already in the Fano configuration.

## The shape of the argument

Step back and admire how little machinery the proof needed. The entire result rested on a
single geometric truth — *any two points lie on a line* — combined with elementary counting.
The upper bound came from "removing one point spoils at most one point per line." The lower
bound came from "the complement cannot contain two collinear points, and everything is
collinear." Two short observations, dual to one another, pinned the answer to exactly six.

That economy is precisely why the Fano plane is such a beloved teaching example and such a
fertile testing ground. It is small enough to check every one of its $2^7 = 128$ subsets by
hand or by machine, yet structured enough to illustrate principles — minimality, duality,
extremal saturation — that reach all the way to the design of modern communication systems
and cryptographic secret-sharing.

## Conclusion: a perfect small world

The Fano plane teaches a lesson that recurs throughout mathematics: the smallest example of
a structure is often the place where its deepest features appear in their clearest form.
Seven points, seven lines, and a single rule — meet every line twice — together force the
number six. That six is not arbitrary; it is the exact value of a bound governing the most
efficient error-correcting codes, achieved here with equality for the very first time.

To cover the Fano plane robustly, you need six of its seven points — and the one you leave
behind can be any point you like. In that simple statement lives a whole world of geometry,
coding theory, and the elegant art of doing the most with the least.
