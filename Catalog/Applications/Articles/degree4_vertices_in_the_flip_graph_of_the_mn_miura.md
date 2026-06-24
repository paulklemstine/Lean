# The Hidden Cube Inside a Folded Sheet of Paper

Take a flat sheet of paper and crease it so that, when you press it together,
it collapses into a tidy zigzag that can be opened and shut with a single tug.
This is the **Miura-ori** — a folding pattern invented by the Japanese
astrophysicist Koryo Miura to pack solar panels for spacecraft. Fold it once on
the ground, launch it folded, and let it bloom open in orbit. The same pattern
now stiffens cardboard, shapes deployable shelters, and inspires self-folding
robots and stretchable electronics.

But beneath the engineering lies a quiet piece of mathematics that is every bit
as elegant as the fold itself. At the heart of the Miura-ori sits a humble
object: a single point where four creases meet. Understand that point, and you
understand a surprising amount about how the whole sheet behaves — and, as we
will see, you uncover a perfect geometric cube hiding inside the space of all
possible foldings.

This article tells the story of that cube. Along the way we will meet two famous
laws of origami, count the ways a corner of paper can fold flat, and discover
that the "4" in "degree-4 vertex" and the "4" in "every node has four neighbours"
are secretly the same number, born from the same four creases.

## Mountains, valleys, and a sheet that lies flat

Look closely at any flat-foldable origami and you will see that every crease is
one of two kinds. A **mountain** fold rises toward you, like the ridge of a roof.
A **valley** fold sinks away, like a gutter. That is the entire vocabulary:
mountain or valley, ridge or gutter, up or down. Nothing else.

Now zoom in on a single interior point of the Miura-ori where four creases
radiate outward, slicing the neighbourhood of that point into four pie-slice
sectors. We will call this a **degree-4 vertex** — "degree 4" simply because four
creases meet there. To describe how the paper folds at this point, we only need
to say, for each of the four creases, whether it is a mountain or a valley. That
is four yes/no choices, four bits of information.

It is tempting to think all $2^4 = 16$ combinations are possible. They are not.
For the paper to fold *flat* — to collapse into a stack with no buckling, no
tearing, no self-intersection — the four choices must obey strict rules. Two of
those rules have been known to origami mathematicians for decades, and they are
where our story really begins.

## Maekawa's law: the three-and-one rule

The first law was discovered by Jun Maekawa. **Maekawa's theorem** says that at
any flat-foldable vertex, the number of mountain creases and the number of valley
creases must differ by exactly two.

For a degree-4 vertex with four creases, this leaves only two possibilities: you
either have **three mountains and one valley**, or **one mountain and three
valleys**. A perfectly even split — two mountains, two valleys — is forbidden, as
is an all-mountain or all-valley star. The paper simply will not lie flat any
other way.

We can state this precisely. Encode an assignment as four bits, writing `true`
for a mountain and `false` for a valley, and let $\text{mountains}(a)$ count how
many of the four creases are mountains. Then for every *valid* degree-4 folding
$a$,

$$\text{mountains}(a) = 1 \quad \text{or} \quad \text{mountains}(a) = 3.$$

This is the three-and-one rule, and it is exactly the content of the theorem we
named `mountains_of_genericValid`.

## The big-little-big lemma, and exactly four foldings

Maekawa's law alone allows eight assignments: there are four ways to place the
single valley among three mountains, and four ways to place the single mountain
among three valleys. But the *geometry* of a real Miura-ori vertex narrows this
further, through a second principle origami theorists call the
**big-little-big lemma**.

The idea is intuitive. The four creases carve the neighbourhood into four sector
angles, and in a generic Miura-ori vertex one of those sectors is strictly the
smallest. When paper folds flat, the smallest sector gets "swallowed" between its
two neighbours — and the two creases bounding that smallest sector are forced to
fold in *opposite* directions. One must be a mountain, the other a valley. They
cannot agree.

Suppose, then, that the unique smallest sector lies between crease $0$ and crease
$1$. The big-little-big lemma forces these two to disagree:

$$a_0 \neq a_1.$$

Maekawa's three-and-one rule then does the rest. With one disagreement already
locked in between creases $0$ and $1$, the only way to reach a total imbalance of
three-versus-one across all four creases is for the *remaining* pair to agree:

$$a_2 = a_3.$$

These two conditions together — "the small-sector creases disagree, the other
pair agree" — are our working definition of a **generic valid** degree-4 vertex,
the property we called `GenericValid`. From it, Maekawa's law follows as a theorem
rather than an assumption.

How many foldings satisfy both conditions? The arithmetic is delightful. The
disagreeing pair $a_0 \neq a_1$ can be arranged in $2$ ways (mountain-then-valley
or valley-then-mountain). The agreeing pair $a_2 = a_3$ can also be arranged in
$2$ ways (both mountains or both valleys). Multiply, and you get

$$2 \times 2 = 4$$

valid foldings. Not sixteen, not eight — exactly **four**. This is the
combinatorial heart of Thomas Hull's classical count of flat-foldings at a
generic degree-4 vertex, and it is the content of our theorem `card_genericValid`:
the number of valid mountain/valley assignments is precisely $4$.

So a single corner of a Miura-ori, viewed as a tiny origami puzzle, has exactly
four solutions. Hold that number in mind. It is about to reappear from a
completely different direction.

## The flip graph: a map of all foldings

Counting foldings is one thing. Understanding how they relate to one another is
another, richer question. Imagine you have one valid folding and you want to reach
another. What is the most natural *move* that takes you from one to the next?

In the theory of reconfiguration — the branch of mathematics that studies how to
morph one solution of a puzzle into another by small legal steps — the natural
move is a **flip**: change one bit and see if you are still valid. This gives rise
to a **flip graph**, a vast map in which each node is a configuration and each
edge joins two configurations that differ by a single flip.

To study flip graphs in their cleanest form, imagine a system with $d$ independent
binary switches — $d$ choices, each of which can be toggled on or off without
disturbing the others. A configuration is a list of $d$ bits. Two configurations
are **neighbours** in the flip graph exactly when they differ in a single
coordinate: flip one switch, and you have a neighbour. Mathematicians call this
graph the **Boolean hypercube** $Q_d$.

For $d = 1$ the hypercube is just two points joined by an edge — one switch, two
states. For $d = 2$ it is a square. For $d = 3$ it is the familiar wire-frame cube
with eight corners. For $d = 4$ it is the **tesseract**, the four-dimensional
hypercube. And in general $Q_d$ has $2^d$ corners, one for each way to set the
$d$ switches.

We made this precise: in the flip graph $Q_d$, two configurations $a$ and $b$ are
adjacent exactly when the set of coordinates on which they disagree has size $1$.
Equivalently — and this is the lemma `flipGraph_adj_iff` — $b$ is a neighbour of
$a$ if and only if $b$ is obtained from $a$ by toggling one chosen coordinate and
leaving all the others alone.

## The main theorem: every corner has exactly $d$ neighbours

Here is the central result, and it is beautifully simple to state.

> **In the hypercube flip graph $Q_d$, every single configuration has exactly $d$
> neighbours.**

Why $d$? Because from any configuration you can flip switch number $1$, or switch
number $2$, or … or switch number $d$ — that is $d$ different moves, each landing
you on a distinct neighbour, and there are no others. No matter which of the
$2^d$ corners you stand on, you see exactly $d$ doors leading out. A graph with
this property — every vertex having the same number of neighbours — is called
**regular**, and so we say $Q_d$ is **$d$-regular**. This is the theorem
`flipGraph_degree`: the degree of every vertex equals $d$.

Now specialize to $d = 4$, the case tailored to a degree-4 origami vertex with its
four creases. The four-dimensional hypercube $Q_4$ is then **$4$-regular**: every
one of its $16$ corners has *exactly four* neighbours. That is our headline
corollary, `flipGraph_degree_four`:

$$\text{degree of every vertex in } Q_4 = 4.$$

And here is the unification promised at the start. The "$4$" in *degree-4 vertex*
— four creases meeting at a point — and the "$4$" in *every node has degree $4$*
in the flip graph are the *same four*. Both spring from a four-element index set:
four creases on the paper, four coordinates in the cube. Among all the hypercubes
$Q_1, Q_2, Q_3, Q_4, \dots$, the tesseract $Q_4$ is the unique one that is
simultaneously four-dimensional and four-regular. The geometry of the fold and the
geometry of the configuration space rhyme.

## Counting the doors, and reaching every room

Two further facts round out the picture, and both follow from the regularity above.

First, **how many edges does $Q_d$ have?** There is a classic counting trick: add
up the number of neighbours over all vertices, and you have counted every edge
exactly twice (once from each end). Each of the $2^d$ vertices contributes $d$
neighbours, so the total is $d \cdot 2^d$, and dividing by two gives

$$\text{number of edges in } Q_d = d \cdot 2^{d-1}.$$

Our theorem `flipGraph_card_edges` records this in the clean integer form
$2 \cdot (\text{edges}) = d \cdot 2^d$. For the tesseract $Q_4$ this gives
$4 \cdot 2^3 = 32$ edges — thirty-two single flips knitting sixteen configurations
into one elegant lattice.

Second, **can you always get from any folding to any other?** Yes. The flip graph
is **connected**: starting from any configuration, you can reach any target by
flipping, one at a time, exactly the switches on which the two configurations
disagree. There is never a folding marooned on its own island. This is the theorem
`flipGraph_connected`, a clean instance of the *mixing* phenomenon that
reconfiguration theory cares about: the space of configurations is fully navigable
by small local moves.

## A concrete walk through the tesseract

Let us make the abstraction tangible with $d = 4$. Write a configuration as four
bits, say `1011`, meaning switches $1$, $3$, $4$ are on and switch $2$ is off.
Its four neighbours are obtained by toggling each bit in turn:

$$1011 \to 0011, \quad 1011 \to 1111, \quad 1011 \to 1001, \quad 1011 \to 1010.$$

Four neighbours, exactly as the theorem promises. To travel from `1011` to, say,
`0110`, compare bit by bit: they differ in positions $1$, $2$, and $4$. Flip those
three, in any order, and you arrive — a path of length three. The longest journey
in the whole tesseract is from a configuration to its exact opposite, flipping all
four bits, a path of length four. The cube is small, symmetric, and entirely
connected, with no corner more than four steps from any other.

## Why this matters beyond paper

It is easy to enjoy this as a piece of recreational mathematics, but the threads
reach much further. The Boolean hypercube is one of the most important graphs in
all of computer science: it is the natural arena for error-correcting codes, for
the analysis of Boolean functions, for parallel-computing network topologies, and
for the study of how randomized algorithms "mix." Reconfiguration graphs — flip
graphs in general — model everything from sliding-block puzzles to the rezoning of
electoral districts to the way physical systems relax toward equilibrium.

Origami sits squarely in this landscape. Engineers designing a deployable
structure need to know not only *whether* a fold pattern can lie flat, but *how
many* distinct flat states it admits and *how* one can be morphed into another —
precisely the questions of counting and connectivity that the flip graph answers.
The clean result here, that the independent-vertex flip graph is a perfect
hypercube, is the rigid skeleton on which the messier, *coupled* theory of the
real $m \times n$ Miura-ori is being built.

For in the true Miura-ori, the vertices are not independent. Creases are shared
between neighbouring vertices, so toggling one corner disturbs its neighbours, and
the pristine product structure of the hypercube is broken. The grand conjecture
motivating this work is that, for every grid of size $m \times n$ with
$m, n \ge 3$, the number of "most rigid" degree-4 nodes in the coupled flip graph
is exactly $(m-1)(n-1)$ — one for each interior vertex of the grid. The
independent case settled here is the first, cleanest rung of that ladder: it
isolates exactly *why* the number four keeps appearing, and gives a precise,
proven anchor against which the harder coupled theory can be measured.

## The number four, twice over

We began with a sheet of paper and ended inside a four-dimensional cube. The
journey turned on a single coincidence that turned out to be no coincidence at
all. A degree-4 origami vertex has four creases; those four creases admit, after
Maekawa's three-and-one law and the big-little-big lemma, exactly four valid
flat-foldings. Meanwhile the flip graph of four independent binary choices is the
tesseract $Q_4$, in which every corner has exactly four neighbours. The four
creases of the fold and the four neighbours of the cube are the same four,
glimpsed from two sides.

Mathematics is full of such echoes — the same small number surfacing in two
distant rooms, until you open the door between them and find it was one room all
along. A folded sheet of paper, it turns out, is one of those doors.
