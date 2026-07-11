# The Topology of Impossible Objects: Escher Stairs and Klein Bottles

## A staircase that goes up forever

Look at M. C. Escher's lithograph *Ascending and Descending* and you will
see a troop of monks trudging endlessly upward around a square rooftop
staircase. Each flight climbs. And yet, after four flights, the monks are
back where they started — no higher than before. Every local step is
honest; only the global loop is a lie.

The same trick powers the Penrose triangle, that three-beam figure whose
corners each look perfectly solid while the whole refuses to exist in
three-dimensional space. And it powers Escher's *Waterfall*, where water
tumbles down a channel only to arrive, without ever climbing, back at the
top of the fall.

These "impossible figures" feel like optical jokes. But underneath the
joke lies a precise and beautiful piece of mathematics. The purpose of
this article is to explain exactly *why* such figures are impossible, and
to show that the impossibility is not vague or aesthetic but **measurable**
— captured by a single algebraic number that we will call the *holonomy*.
Even better, we will see that the collection of all impossible figures of a
given shape forms an algebraic object — a group — and that this group is a
perfect copy of the number system in which we measure depth. In the
language of topology, the impossible figure has a *first cohomology group*,
and we can compute it exactly.

## Local honesty, global contradiction

Start with the staircase. Walk around it and record, at each corner, how
much you *appear* to rise as you cross from one flight to the next. Call
these apparent rises $t_0, t_1, t_2, t_3$ — one number per corner of the
square loop. Each $t_i$ is perfectly plausible in isolation: a real
staircase can rise by any of these amounts.

Now demand consistency. If the figure is to depict a genuine object in
space, then there must be a well-defined *height* $h_i$ assigned to each
landing, and the apparent rise across corner $i$ must be exactly the
difference of heights,
$$t_i = h_{i+1} - h_i.$$
Go all the way around the loop of $n$ corners and add up the apparent
rises. The heights telescope and cancel:
$$\sum_{i=0}^{n-1} t_i = (h_1 - h_0) + (h_2 - h_1) + \cdots + (h_0 - h_{n-1}) = 0.$$

So a **realizable** figure — one that could be a real object — must have
its apparent rises summing to zero. Escher's staircase violates exactly
this: every corner rises, so the sum is strictly positive, and no
assignment of heights can ever be consistent. That leftover sum is the
holonomy, and it is the entire content of the impossibility.

## The holonomy: one number that measures the lie

Let us set the idea down precisely. A **cyclic figure** on $n$ patches,
valued in an abelian group $A$ (think of $A$ as the real numbers $\mathbb{R}$
for "depth," or the integers $\mathbb{Z}$, or the two-element group
$\mathbb{Z}/2$ for "orientation"), is simply a function
$$t : \{0, 1, \ldots, n-1\} \to A$$
that records the local increment across each overlap. The **holonomy** of
the figure is
$$\mathrm{hol}(t) = \sum_{i=0}^{n-1} t_i \in A.$$

A **gauge** is a choice of height $h_i \in A$ at each patch, and its
**coboundary** is the figure it forces,
$$(\delta h)_i = h_{i+1} - h_i.$$

With this vocabulary the fundamental dichotomy becomes a clean theorem.

> **Realizability Theorem.** A cyclic figure $t$ is realizable — that is,
> $t = \delta h$ for some assignment of heights $h$ — if and only if its
> holonomy vanishes: $\mathrm{hol}(t) = 0$.

One direction is the telescoping computation above: every coboundary has
zero holonomy. The converse is the interesting one, and it is a discrete
version of a classical fact called the *Poincaré lemma*: if the total goes
around to zero, then you can reconstruct consistent heights by *partial
summation*. Set $h_0 = 0$ and let
$$h_i = t_0 + t_1 + \cdots + t_{i-1}$$
be the running total of increments up to patch $i$. This clearly
reproduces $t_i = h_{i+1} - h_i$ at every interior step; the only danger is
at the seam where the loop closes, and there the requirement
$t_{n-1} = h_0 - h_{n-1}$ holds *precisely because* the grand total is
zero. Vanishing holonomy is exactly the permission slip that lets the
running total close up into a consistent height function.

## From a yes/no test to an algebraic invariant

So far we have a binary verdict: possible or impossible. The deeper story
is that the *degree* and *kind* of impossibility is itself structured.

Fix the shape (the number of patches $n$) and consider **all** figures at
once. Adding two figures increment-by-increment gives another figure, so
the figures form a group. The realizable ones — the coboundaries — form a
subgroup. The **impossibility classes** are what remain after we agree to
ignore realizable adjustments: two figures are declared **cohomologous**
if they differ by a coboundary,
$$t \sim s \quad\Longleftrightarrow\quad t - s = \delta h \text{ for some } h.$$
The set of cohomology classes is the **first cohomology group** $H^1$ of
the figure. It answers: *in how many genuinely different ways can a figure
fail to close up?*

Because holonomy is additive — $\mathrm{hol}(t+s) = \mathrm{hol}(t) +
\mathrm{hol}(s)$ — it defines a group homomorphism from figures to the
coefficient group $A$. Two facts now pin it down completely.

> **Surjectivity.** Every element $a \in A$ is the holonomy of some figure.
> (Put the entire increment $a$ on a single corner and zero elsewhere.)

> **Exactness.** A figure has zero holonomy if and only if it is a
> coboundary.

The second statement says the *kernel* of holonomy equals the *image* of
the coboundary. In homological language, the two-step sequence
$$(\text{gauges}) \xrightarrow{\ \delta\ } (\text{figures})
\xrightarrow{\ \mathrm{hol}\ } A$$
is **exact in the middle** and **surjective on the right**. Put together,
these say holonomy descends to an *isomorphism* between the impossibility
classes and the coefficient group:

> **Classification Theorem.** Two figures are cohomologous if and only if
> they have the same holonomy. Consequently the first cohomology group of a
> cyclic figure is canonically isomorphic to the coefficient group,
> $$H^1 \;\cong\; A,$$
> with holonomy realising the isomorphism.

This is the discrete twin of the classical computation $H^1(S^1; A) \cong A$
for the circle. Our loop of overlapping patches *is* a combinatorial
circle, its first cohomology is one-dimensional, and holonomy is the
coordinate on that line. The holonomy is not just *a* test for
impossibility; it is a **complete invariant** — it tells two impossible
figures apart exactly when they are genuinely, unfixably different.

## The Penrose triangle generates everything

Take the coefficient group to be the integers $\mathbb{Z}$ and the loop to
have three corners — the Penrose triangle. Assign a unit apparent depth
shift $+1$ at one corner and $0$ at the others. Its holonomy is $1 \neq 0$,
so:

> **The Penrose triangle is impossible.** Its holonomy is nonzero, hence it
> is not realizable.

And because $1$ generates $\mathbb{Z}$, the Penrose class **generates** the
whole impossibility group: every integer-valued impossibility on the
triangle is an integer multiple of the basic Penrose figure. There is, in
a strict sense, only *one* impossible triangle, appearing in all its
integer strengths.

## Möbius bands, Klein bottles, and orientation as a $\mathbb{Z}/2$ obstruction

Depth is not the only thing that can fail to close up. Consider
*orientation*. Walk around a loop and, at each overlap, record whether the
local sense of "clockwise" is preserved ($0$) or flipped ($1$). Now the
coefficient group is $\mathbb{Z}/2$, and the holonomy is the *parity* of
the total number of flips.

If the number of flips is even, the orientations glue up and the band is
two-sided — an ordinary cylinder. If the number of flips is odd, the
holonomy is the nonzero element of $\mathbb{Z}/2$, no consistent
orientation exists, and the band is **one-sided**: a Möbius strip.

> **Orientation Theorem.** A cyclic band with an odd number of orientation
> flips carries a nonzero class in $H^1(S^1; \mathbb{Z}/2)$, and is
> therefore non-orientable.

This is the same theorem as before, now heard in a different key. The
Möbius band's famous one-sidedness and the Escher staircase's endless
climb are two instances of a single phenomenon: a nonzero holonomy around a
loop. Glue two Möbius bands and you get a Klein bottle; its
non-orientability is again an odd-flip holonomy, an obstruction living in
the same $\mathbb{Z}/2$ cohomology.

## Why one number captures so much

The moral is that "impossibility" is not a defect of drawing but a genuine
topological invariant. Every local piece of an Escher figure is honest;
what is dishonest is the way the loop closes. That mismatch is measured by
holonomy, holonomy is additive, and additivity forces the impossibility
classes into a group that is a flawless copy of the coefficient system.
The Penrose triangle is the generator; the Escher staircase is a nonzero
integer class; the Möbius band and Klein bottle are the nonzero class over
$\mathbb{Z}/2$.

There is a natural next horizon. On a surface with more holes — a torus,
or a genus-$g$ surface — a figure can fail to close up along *several*
independent loops at once, one obstruction per independent cycle. The
first cohomology then has rank equal to the number of independent loops,
and Escher's *Waterfall*, drawn on a torus, needs *two* holonomies to
describe it. But whether on a circle, a torus, or a Klein bottle, the
principle is unchanged and unreasonably effective: **to know whether an
impossible object can be built, add up its increments around every loop and
ask whether the sum is zero.**
