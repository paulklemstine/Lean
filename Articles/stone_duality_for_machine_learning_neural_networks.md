# The Hidden Logic Inside a Neural Network

## A machine that draws lines

Picture the simplest interesting decision a machine can make: *yes* or *no*.
Is this photo a cat? Is this transaction fraud? Is this tumor malignant? A
neural network answers such questions by carving the space of all possible
inputs into regions and painting each region with an answer. Inside one region
the machine says *yes*; step across a boundary and it says *no*.

For the workhorse networks of modern machine learning — those built from the
humble *rectified linear unit*, or ReLU — these boundaries are not smooth,
mysterious curves. They are made of perfectly straight pieces: flat walls,
creases, and folds. Each artificial neuron computes a weighted sum of its
inputs and then "switches on" only when that sum crosses zero. The set of
points where a neuron sits exactly at its threshold is a flat hyperplane, and
the network's entire decision surface is assembled from these flat pieces.

This is a familiar picture to anyone who has studied deep learning. What is
far less familiar — and genuinely surprising — is that this geometric picture
has an exact *algebraic twin*. Every such network secretly carries around a
piece of pure logic: a **Boolean algebra**, the same kind of algebra that
governs *and*, *or*, and *not*. The geometry you can see (the regions and their
boundaries) and the logic you cannot (the algebra of yes/no combinations) turn
out to be two faces of a single object. The bridge between them is a classical
and beautiful theorem called **Stone duality**.

This article is about that bridge, and about a clean, fully rigorous account of
how it applies to a layer of a neural network.

## Two languages for one idea

In the 1930s, the mathematician Marshall Stone proved something that still
feels like a magic trick. On one side he placed **Boolean algebras** — abstract
systems of propositions closed under *and*, *or*, and *not*, obeying the laws
of ordinary logic. On the other side he placed certain **topological spaces**,
geometric objects made of points and neighborhoods. Stone showed that these two
worlds are *the same world*, seen from two angles.

More precisely, **every Boolean algebra is exactly the algebra of "clopen"
(simultaneously closed and open) sets of an associated space**, its *Stone
space*. The abstract propositions become concrete regions; logical *and*
becomes intersection, *or* becomes union, *not* becomes complement. Syntax — the
rules for manipulating symbols — becomes semantics — the actual shapes those
symbols describe. You can compute in whichever language is more convenient and
translate the answer back.

Stone duality is one of the great unifying results of twentieth-century
mathematics, quietly underlying logic, topology, and theoretical computer
science. The claim of this article is that it also lives, concretely and
usefully, inside a neural network.

## The syntax: patterns of firing neurons

Take a single layer of a network: $n$ neurons, each looking at the same input.
Feed the layer an input point $x$. Each neuron either fires or stays silent, so
the layer's response is a string of $n$ bits — an **activation pattern**. We
write it as a function
$$\mathrm{act}(x) : \{1, \dots, n\} \to \{\text{off}, \text{on}\},$$
recording, for each neuron, whether it is on or off at $x$.

There are exactly $2^n$ conceivable patterns — every combination of on/off
across $n$ neurons. This complete collection of $2^n$ possible patterns is our
**syntax**. Crucially, it is already a Boolean algebra: patterns can be
combined with *and*, *or*, and *not* bit by bit, exactly like propositions.
Nothing about the network is needed to see this; it is pure combinatorics of
bit strings.

But a given network, on a given collection of inputs, does not usually realize
all $2^n$ patterns. Some combinations of firing neurons are geometrically
impossible. The patterns that *do* occur are precisely the network's **linear
regions** — the flat cells into which the layer partitions its inputs. Two
inputs land in the same region exactly when every neuron treats them alike.

How many linear regions can there be? Our first results pin this down with two
complementary ceilings. First, since every region corresponds to a distinct
pattern, and there are only $2^n$ patterns, there can be **at most $2^n$
regions**. This is a bound imposed by the *syntax*: the algebra of bit strings
is only so big. Second, if we only ever test the layer on a finite sample of
$m$ input points, then obviously there can be **at most $m$ regions** — you
cannot have more cells than points to put in them. Combining these gives the
clean statement:

> **Region bound.** A layer of $n$ neurons, evaluated on a sample of $m$
> points, realizes at most $\min(2^n,\, m)$ linear regions.

## The semantics: decision regions

Now flip the picture around. A working classifier does not care about a single
pattern; it cares about *sets* of patterns. "Say *cat* whenever the pattern is
one of these; say *dog* otherwise." So fix any set $S$ of activation patterns
and collect all the input points whose pattern belongs to $S$:
$$\mathrm{region}(S) = \{\, x : \mathrm{act}(x) \in S \,\}.$$
This is a **decision region** — a genuine subset of the input space, the *shape*
that the abstract set of patterns $S$ carves out in reality. As $S$ ranges over
all possible sets of patterns, the decision regions form a family we call the
**decision algebra** of the layer. This is our **semantics**.

Here is the first half of the duality, made precise. The map that sends a set
of patterns $S$ to its decision region is a perfect **dictionary** between the
two languages:

> **The pattern-to-region map is a Boolean homomorphism.** The empty set of
> patterns maps to the empty region; the full set maps to the whole space;
> and for any sets $S$ and $T$,
> $$\mathrm{region}(S \cup T) = \mathrm{region}(S) \cup \mathrm{region}(T),\quad
> \mathrm{region}(S \cap T) = \mathrm{region}(S) \cap \mathrm{region}(T),$$
> with complements matching complements. Logical *or*, *and*, *not* on the
> syntax become union, intersection, complement on the geometry.

This is exactly the translation Stone promised: manipulate the symbols, or
manipulate the shapes; the answer is the same.

## The atoms: where geometry and logic meet

A Boolean algebra is built from its **atoms** — its smallest nonzero pieces,
the indivisible propositions from which everything else is assembled by *or*.
What are the atoms of a network's decision algebra?

The answer is as clean as one could hope: **the atoms are exactly the linear
regions.** Each individual pattern that actually occurs picks out one
indivisible cell of input space, and every decision region is a union of these
cells. Two different collections of realized patterns always produce two
different decision regions — no information is lost in translation, and nothing
collapses. In the language of the theory, the pattern-to-region dictionary is
*faithful*: distinct sets of realized patterns give distinct regions.

Two subtle points make this precise and honest. First, patterns that never
actually occur are simply invisible to the geometry — a decision region depends
only on the *realized* patterns, so we lose nothing by throwing the impossible
patterns away. Second, once we restrict to realized patterns, the dictionary
becomes not just a homomorphism but a genuine one-to-one correspondence.

Putting these together yields the centerpiece.

## Stone duality, counted exactly

Here is the punchline, a precise counting law that ties the whole story
together:

> **Stone Duality Theorem for a Neural Layer.** If a layer realizes exactly $r$
> linear regions on a sample, then its decision algebra contains exactly $2^r$
> decision regions.

Read it slowly, because it says something remarkable. The messy, continuous,
high-dimensional geometry of a neural network's decision surface — all its
folds and creases on a given dataset — is completely captured by a single
integer $r$, the number of linear regions. And the full Boolean algebra of
decisions the layer can express is then, on the nose, the algebra of *all
subsets* of those $r$ regions: a finite Boolean algebra with $2^r$ elements.
This is precisely the finite case of Stone duality: a finite Boolean algebra
with $r$ atoms is the algebra of clopen subsets of the $r$-point discrete
space. Here that $r$-point space *is* the set of linear regions, and its clopen
subsets *are* the decision regions. Syntax and semantics, counted and matched.

## Capacity, honestly

This structural picture immediately says something about *learning*. A central
question in machine learning is **capacity**: how complex a set of labelings
can a model express? The gold-standard measure is the *VC dimension* — the
largest number of points the model can *shatter*, meaning label in every one of
the $2^m$ possible yes/no ways.

The counting law gives a genuine capacity ceiling. To shatter a sample of $m$
points, a layer must realize a distinct pattern for every point (otherwise two
points share a fate and cannot be separated), and there are only $2^n$ patterns
to go around. Hence:

> **Capacity bound.** A layer of $n$ neurons can shatter a sample of at most
> $2^n$ points.

It is worth being candid about a tempting but *false* conjecture that this work
corrects. One might guess that the VC dimension of a network simply equals its
number of linear regions. It does not. A single affine neuron acting on
$d$-dimensional inputs has VC dimension $d+1$ — a number governed by the
*geometry of half-spaces*, not by any count of regions. The honest, provable
statements are the ones above: the atoms of the decision algebra are the linear
regions, the algebra has $2^r$ elements, and shattering $m$ points requires
$m \le 2^n$. Precision here matters more than a tidy slogan.

## From abstraction to real weights

None of this is confined to the abstract. A concrete ReLU layer is specified by
a matrix of weights $W$ and a vector of biases $b$: neuron $i$ fires at input
$x$ exactly when its pre-activation
$$\langle W_i, x\rangle + b_i$$
is positive. Plugging these explicit formulas into the activation-pattern map
turns every abstract theorem above into a statement about an actual network. In
particular, a real ReLU layer of $n$ neurons realizes at most $\min(2^n, m)$
linear regions on any sample of $m$ inputs, and its decision algebra has
exactly $2^r$ members where $r$ is the number of regions it actually cuts. The
accompanying numerical experiments confirm every one of these counts on small
networks, down to the last region.

## Why this is worth caring about

The romance of the result is the unification. Deep learning is usually told as
a story about geometry and optimization — surfaces, gradients, landscapes. Logic
and topology feel like a different subject entirely. Stone duality says they are
not. Inside every ReLU layer there is a Boolean algebra, and its geometric
realization is the decision surface you were looking at all along. The
activation patterns are the *syntax*; the decision regions are the *semantics*;
and a two-century-old thread of pure mathematics stitches them together
exactly.

There is also a practical undertone. Counting linear regions is a standard proxy
for a network's expressive power, and framing that count as *the number of atoms
of a Boolean algebra* connects it to the mature toolkit of logic and
combinatorics: growth functions, shattering, and the exact bookkeeping of Stone
duality. It suggests that questions about what a network *can express* might be
answered not only with calculus, but with the algebra of *and*, *or*, and
*not*.

The next steps write themselves. Assemble the decision algebra into an honest
topological Stone space and watch the linear regions become its points.
Stack many layers and track how the algebra grows. Trade the finite sample for
a full arrangement of hyperplanes in space and connect the region count to the
classical formulas of combinatorial geometry. Each is a bridge waiting to be
crossed — and each starts from the same quiet observation: a machine that draws
lines is also, secretly, doing logic.
