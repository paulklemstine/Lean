# The Number 77: When Coloring a Ruler Becomes Impossible

## A game you can lose

Here is a game. Take a ruler marked with the whole numbers $1, 2, 3, \dots, N$.
You have three crayons — say red, green, and blue — and you must color every
tick mark on the ruler with one of the three colors. There are no rules about
*how* you color; stripes, blocks, chaos, anything goes.

But there is one pattern you are trying to avoid. Pick a starting point $b$ and a
step size $a$. Now look at three marks:

$$b, \qquad b + 2a, \qquad b + 5a.$$

These three positions form a scaled, shifted copy of the tiny template
$\{0, 2, 5\}$ — the first mark, then a jump of two steps, then a jump of three
more steps. Your enemy wins if they can find *any* such triple, for *any*
starting point and *any* positive step size, all three of whose marks wear the
**same color**. You win if you can color the whole ruler so that no monochromatic
copy of $\{0, 2, 5\}$ exists anywhere.

For a short ruler, winning is easy. For a long ruler, it turns out to be
*impossible* — and there is a precise, razor-sharp boundary between the two
regimes. That boundary is the number **77**.

- On a ruler of length **76**, a careful person can still win: there exists a
  three-coloring of $\{1, \dots, 76\}$ with no monochromatic $b, b+2a, b+5a$.
- On a ruler of length **77**, the game is unwinnable: *every* three-coloring of
  $\{1, \dots, 77\}$, no matter how clever, is forced to contain a monochromatic
  copy of $\{0, 2, 5\}$.

In the language of Ramsey theory, the quantity we have just described is called
the **Gallai homothety number** of the pattern $\{0, 2, 5\}$ for three colors,
written $G_3(\{0,2,5\})$. The headline result is a single, hard-won integer:

$$\boxed{\,G_3(\{0,2,5\}) = 77.\,}$$

This article is about what that number means, why such a number has to exist at
all, and why pinning down its *exact* value is far harder than proving it is
merely finite.

## Ramsey theory: order you cannot avoid

The deep intuition behind this whole subject is a slogan of Theodore Motzkin:
*complete disorder is impossible*. No matter how you try to scramble a large
enough structure, some island of perfect regularity survives. The most famous
example is **van der Waerden's theorem**: if you color the whole number line with
finitely many colors, one color class must contain arbitrarily long arithmetic
progressions — evenly spaced runs like $b, b+a, b+2a, b+3a, \dots$.

Our pattern $\{0, 2, 5\}$ is a cousin of the arithmetic progression, but a
mischievous one. An arithmetic progression $\{0, 1, 2\}$ has *equal* gaps. The
pattern $\{0, 2, 5\}$ has gaps of size $2$ and then $3$ — **unequal** gaps. As we
will see, this small asymmetry is exactly what makes the number $77$ so large.

The general guarantee that a number like $G_3(\{0,2,5\})$ even exists comes from
one of the crown jewels of the field, the **Hales–Jewett theorem**, and its
arithmetic consequence, the **Gallai–Witt theorem**. Together they promise:

> **Guaranteed regularity.** For any finite pattern $S$ of whole numbers and any
> number of colors $r$, there is a finite threshold $N$ such that every
> $r$-coloring of $\{1, \dots, N\}$ contains a monochromatic homothetic copy of
> $S$ — a set $\{b + a s : s \in S\}$ with genuine positive step size $a \ge 1$.

A "homothetic copy" is just a scaled-and-shifted replica: take the template,
blow it up by a factor $a$, and slide it over by $b$. Homothety is the geometry
of similar triangles applied to a finite set of points on a line.

So finiteness is a theorem of the abstract kind: it tells you the boundary
between "winnable" and "unwinnable" exists, but not where it is. The Hales–Jewett
machinery, run honestly, would place the threshold astronomically high — its
bounds grow at tower-of-exponentials speed. The story of $77$ is the story of
descending from that stratospheric guarantee to the true, tiny, exact value.

## Two halves of an exact answer

Proving an exact Ramsey number is always a two-front war. To establish
$G_3(\{0,2,5\}) = 77$ you must prove two inequalities that squeeze the answer
from both sides.

### The lower bound: a coloring that survives

To show $G_3(\{0,2,5\}) \ge 77$, it suffices to *win the game on a ruler of
length 76*. That is, we need a single explicit three-coloring of
$\{1, \dots, 76\}$ containing no monochromatic $b, b+2a, b+5a$. Its mere
existence proves that $76$ is not yet a forcing length, so the true threshold
must be at least $77$.

Here is such a coloring, written as a string of $76$ colors drawn from
$\{0, 1, 2\}$ (position $i$ gives the color of the tick mark $i$):

```
1 0 2 0 1 1 1 0 0 2 0 1 2 2 1 2 2 2 0 1 0 2 0 1 1 1 0 0 2 0 1 2 2 1 2 2
1 0 1 0 2 0 1 1 1 0 0 2 0 1 2 2 1 2 2 0 0 1 0 2 0 1 1 1 0 0 2 0 1 2 2 1
2 2 0 0
```

One can check, triple by triple, that no starting point $b$ and step $a \ge 1$
with $b + 5a \le 76$ produce three marks of a single color. The check is finite —
there are only about a thousand candidate triples — and it passes every one.
Finding such a coloring, on the other hand, is a needle-in-a-haystack search: the
number of three-colorings of a $76$-mark ruler is $3^{76}$, a number with more
than thirty digits. The coloring above was discovered by a constraint-solving
search that treats "avoid every monochromatic triple" as a giant logic puzzle and
returns a witness.

### The upper bound: nowhere left to hide

To show $G_3(\{0,2,5\}) \le 77$, we must prove the *opposite* kind of statement:
that on a ruler of length $77$, **no** coloring survives. This is a universal
claim over all $3^{77}$ colorings, and it cannot be established by exhibiting a
single example. Instead one shows that the corresponding logic puzzle at length
$77$ is *contradictory* — there is no assignment of three colors to
$\{1, \dots, 77\}$ that dodges every triple. The search that found the length-$76$
survivor, rerun at length $77$, exhausts all possibilities and certifies that
none works.

Put the two halves together and the answer is trapped exactly:

$$76 \text{ is survivable}, \quad 77 \text{ is not} \quad\Longrightarrow\quad G_3(\{0,2,5\}) = 77.$$

## Why "unequal gaps" inflate the number

It is worth savoring *why* $77$ is so much larger than one might guess. Compare
$\{0, 2, 5\}$ with the equally spaced pattern $\{0, 2, 4\}$ — an ordinary
three-term arithmetic progression. Equal-gap patterns have a hidden symmetry:
they are invariant under scaling in a way that meshes beautifully with periodic,
block-repeating colorings. If you color in a tidy repeating pattern with a
well-chosen period, arithmetic progressions tend to get chopped up predictably,
and you can hold them off with a short, regular recipe.

The pattern $\{0, 2, 5\}$ refuses this comfort. Its gaps, $2$ and $3$, are
coprime and unequal, so no single modular period neatly defends against all of
its homothetic copies at once. To avoid monochromatic copies you are pushed into
a genuinely *aperiodic* arrangement — and indeed the record length-$76$ coloring
above has no short period; it does not settle into any repeating block. The
irregularity of the gaps forces irregularity in the extremal coloring, and that
extra freedom is exactly what lets a survivor stretch all the way to length $76$.
The moral: for three-point patterns, it is the **gap structure**, not the number
of points, that governs the size of the Ramsey constant.

## Order at every scale, not just at the threshold

The threshold $77$ is a statement about a finite ruler. But the underlying
regularity is far more sweeping. If you color the *entire* infinite sequence of
whole numbers with three colors (or any finite number), then not only does one
monochromatic copy of $\{0,2,5\}$ appear — infinitely many do, with starting
points and step sizes as large as you like. There is no way to "use up" the
pattern and be free of it beyond some point. This is the infinite heart of the
matter, of which $77$ is the finite, quantitative shadow.

And the phenomenon persists as you add colors. With four crayons instead of
three, the analogous threshold $G_4(\{0,2,5\})$ is still a finite number — just a
larger one. A natural blow-up construction, overlaying an optimal coloring for
$r$ colors with an optimal coloring for $s$ colors on rescaled coordinates, shows
that these thresholds grow *super-multiplicatively*:

$$G_{r+s}(\{0,2,5\}) \;\ge\; \bigl(G_r(\{0,2,5\}) - 1\bigr)\bigl(G_s(\{0,2,5\}) - 1\bigr) + 1.$$

With the anchor $G_3 = 77$ in hand, this already forces the four- and
five-color numbers to be dramatically larger, hinting at least single-exponential
growth in the number of colors — vastly slower than the tower-type ceiling of the
general theory, but explosive nonetheless.

## Why exact values matter

It is tempting to shrug: who cares whether the number is $77$ or $78$? But exact
Ramsey-type constants are the load-bearing data points of combinatorics. Each one
is a fixed star against which we test our theories of *why* order emerges. General
theorems give wildly loose bounds; a single exact value tells us how far those
bounds are from the truth, and often reveals the hidden structure — here,
aperiodicity and gap-driven growth — that a purely asymptotic argument would
never expose. The value $77$ is one clean anchor in a vast, mostly uncharted table
of gap patterns, and it turns an isolated curiosity into the first entry of a law
relating the *shape* of a pattern to the *size* of the disorder it forbids.

There is also a broader lesson about how such truths are established. The lower
bound is a construction — a single, almost paradoxical object that threads
thousands of constraints simultaneously. The upper bound is an exhaustion — a
proof that beyond a hair's breadth further, the space of possibilities collapses
to nothing. Between the survivor at $76$ and the impossibility at $77$ lies the
entire drama of Ramsey theory: the moment where freedom runs out and structure
becomes inevitable.

Complete disorder, once again, is impossible. And for the pattern $\{0,2,5\}$
under three colors, the exact price of that impossibility is $77$.
