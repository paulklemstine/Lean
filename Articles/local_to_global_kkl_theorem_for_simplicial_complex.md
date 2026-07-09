# When the Small Picture Decides the Big One: A Local-to-Global Law for Influence

## A vote, a coin flip, and a surprising kind of power

Imagine a committee of $n$ people who must reach a single yes-or-no decision. Each
member holds one vote — a bit, $0$ or $1$ — and the committee's verdict is
computed by some fixed rule from all $n$ votes. That rule is just a function
$f$ that takes an assignment of votes and returns the collective answer.

A natural question is: *how much power does any single member wield?* Not power in
the sense of persuasion, but raw mathematical leverage: in how many situations
would flipping *only that member's vote* change the committee's decision? This
quantity has a name — the **influence** of a coordinate — and it is one of the
central objects in the analysis of Boolean functions, with deep consequences in
theoretical computer science, the design of error-correcting codes, hardness of
approximation, and the mathematics behind cryptographic robustness.

The celebrated Kahn–Kalai–Linial (KKL) theorem, proved in 1988, says something
counterintuitive and beautiful about influence. It guarantees that in any
reasonably "balanced" voting rule, *somebody* must be surprisingly powerful:
there is always a coordinate whose influence is at least on the order of
$\log n / n$ — much larger than the naive average of $1/n$ you might expect if
power were spread evenly. Democracy, it turns out, cannot be perfectly flat.

This article is about a different, and in some ways more structural, side of the
influence story. We ask a **local-to-global** question:

> If we only understand influence on *small pieces* of a system, what can we say
> about influence on the *whole* system?

The answer we develop is a clean averaging law — the engine that powers
local-to-global theorems across modern combinatorics and high-dimensional
expansion. It says that global power is literally the sum of the power visible in
the pieces, and that a lower bound on every piece forces a genuinely powerful
coordinate to exist globally.

## The geometry of votes: the cube and its slices

Let us make the picture concrete. The set of all possible vote profiles is the
**Boolean cube** $\{0,1\}^n$: each vertex is one assignment of votes, and two
vertices are joined by an edge when they differ in exactly one coordinate. An
edge "in direction $i$" connects two profiles that agree everywhere except at
member $i$.

The influence of member $i$ is then simply a count of edges:

$$\mathrm{Inf}(f, i) = \#\{\text{edges in direction } i \text{ on which } f \text{ changes value}\}.$$

Each such edge is a moment where member $i$ is decisive. The **total influence**
is the sum over all members, $\mathrm{TotInf}(f) = \sum_i \mathrm{Inf}(f, i)$, a
global measure of how "sensitive" the whole rule is.

Now comes the local structure. Pick one member $j$ and freeze their vote to a
value $b \in \{0,1\}$. What remains is a smaller committee — everyone except $j$ —
deciding under the rule $f$ with $j$'s vote nailed down. Geometrically, freezing
$j = b$ slices the cube into a **facet**: a copy of the $(n-1)$-dimensional cube.
In the language of complexes, this facet is a **link** of the frozen vertex.

Inside that link we can again ask how decisive each remaining member $i$ is. The
**link influence** $\mathrm{InfSub}(f, j, b, i)$ counts the direction-$i$ edges on
which $f$ changes *while $j = b$*. These are exactly the decisive edges of member
$i$ that happen to live in this particular slice.

## The bridge: influence is the sum of its slices

Here is the single fact that makes everything work. Take any member $i \ne j$.
Every direction-$i$ edge lies entirely inside one of the two slices $j = 0$ or
$j = 1$ — because moving along direction $i$ does not touch coordinate $j$. So the
decisive $i$-edges of the whole cube split cleanly, with no overlap and nothing
left out, between the two links. In symbols:

$$\mathrm{Inf}(f, i) = \mathrm{InfSub}(f, j, 0, i) + \mathrm{InfSub}(f, j, 1, i).$$

We call this the **influence self-averaging** identity, or simply *the bridge*.
It is almost embarrassingly simple, yet it is the whole ballgame: it says a
coordinate's global power is *exactly* the sum of the power it displays in the two
halves of the world obtained by freezing $j$.

Summing the bridge over all members $i \ne j$ gives the total-influence version.
If we write the **link total influence** as
$\mathrm{LinkTotInf}(f, j, b) = \sum_{i \ne j} \mathrm{InfSub}(f, j, b, i)$, then

$$\sum_{i \ne j} \mathrm{Inf}(f, i) = \mathrm{LinkTotInf}(f, j, 0) + \mathrm{LinkTotInf}(f, j, 1).$$

The global sensitivity (ignoring the frozen member) is the sum of the two slices'
sensitivities. Nothing is created or destroyed by slicing.

## From "every slice is busy" to "someone is powerful"

The bridge combines with an old friend — the pigeonhole principle — to yield the
flagship result. Suppose we have a *local* guarantee: **each** of the two slices
of member $j$ carries total influence at least $T$. Perhaps we know this because
each slice is itself a non-degenerate voting rule and some KKL-type lower bound
applies to it. What does this force globally?

By the total-influence bridge, the global sensitivity across the $n-1$ remaining
members is at least $2T$. But if $n-1$ numbers add up to at least $2T$, the
largest of them must be at least the average, $2T/(n-1)$. Hence:

> **Local-to-Global KKL (cube form).** Fix a member $j$ of an $n$-member committee
> with $n \ge 2$. If both slices of $j$ carry total influence at least $T$, then
> some other member $i \ne j$ has influence at least $2T/(n-1)$; equivalently,
> $(n-1)\,\mathrm{Inf}(f, i) \ge 2T$.

A uniform lower bound on every *piece* is upgraded, for free, into the existence
of a genuinely influential coordinate in the *whole*. This is the local-to-global
paradigm in miniature: control the links, and you control the complex.

## The abstract engine behind the curtain

The cube is vivid, but the argument never really used the cube. It used three
ingredients: a family of *pieces*, each with non-negative weight; a notion of
influence on each piece; and the bridge saying that global influence is a weighted
average of piece influences. Distilling this gives a machine that runs on any
weighted family of links.

Let the coordinates be indexed by a set, and let the pieces (links) be indexed by
another set $\kappa$, each link $\ell$ carrying a weight $w_\ell \ge 0$. Suppose
the global influence $I(i)$ of coordinate $i$ and the local influences
$I_\ell(i)$ satisfy the **bridge**

$$I(i) = \sum_{\ell} w_\ell \, I_\ell(i),$$

and suppose the **local KKL hypothesis** holds: every link $\ell$ has an
influential coordinate, some $i$ with $I_\ell(i) \ge \tau$. Then a two-line
averaging computation yields the **global total influence bound**

$$\sum_i I(i) \;\ge\; \tau \cdot \sum_\ell w_\ell.$$

And since the maximum is at least the average, some single global coordinate $i$
satisfies $|\text{coords}| \cdot I(i) \ge \tau \sum_\ell w_\ell$ — a globally
influential coordinate, produced purely from local ones.

The Boolean cube is then revealed to be *literally an instance*: take exactly two
links (the slices $j=0$ and $j=1$), each of weight one, and the abstract bridge
becomes the concrete identity $\mathrm{Inf}(f,i) = \mathrm{InfSub}(f,j,0,i) +
\mathrm{InfSub}(f,j,1,i)$. The general engine reproduces $2T \le \mathrm{TotInf}(f)$
with no extra work.

Two refinements round out the picture. First, a **faithful KKL conditional**: if
the local guarantee is stated in its true conditional form — *a link that is
non-degenerate (its variance proxy exceeds a threshold) must have an influential
coordinate* — then assuming every link is non-degenerate recovers the same global
bound. Second, an **exact law for regular systems**: if every link has the same
total influence $A$ and every weight is one, the global total influence is exactly
$|\kappa| \cdot A$, with no slack at all.

## Why anyone should care

The reason this simple averaging law matters is that it is the reusable heart of a
sweeping modern program: **high-dimensional expanders** and local-to-global
theorems. The dream of that program is to prove strong global properties of vast
combinatorial objects by checking only their tiny local neighborhoods — the links.
Expansion, mixing, sampling, and error-correction properties have all been shown
to propagate from links to the whole complex. Influence is one more citizen of
this world, and the bridge identity is its passport.

There is a concrete cryptographic resonance too. Influence measures how sensitive
an output is to any single input bit — precisely the kind of quantity one wants to
control when reasoning about the robustness of a function against tampering, the
diffusion of a hash or cipher, or the resilience of a shared-randomness protocol.
A local-to-global law says: to certify that no coordinate is *too* influential —
or to guarantee that *some* coordinate carries enough sensitivity to detect
tampering — it can suffice to understand the restricted sub-functions one obtains
by freezing individual bits.

Finally, the result is honest about its own limits, and that honesty points to the
horizon. The global conclusion here is an *averaging* bound: the best coordinate is
at least the average. The full KKL theorem promises far more — an influential
coordinate of size $\Omega(\mathrm{Var}(f)\,\log n / n)$, a genuine logarithmic
boost — even when the total influence is small. Reaching that peak requires the
heavier artillery of Fourier analysis on the cube and the hypercontractive
Bonami–Beckner inequality. Extending the local-to-global bridge all the way to the
logarithmic KKL bound, and onto true simplicial complexes and expanders, is the
grand open road ahead.

But the first, decisive step is the one told here: **global power is the sum of
local power, and a floor on every piece raises the ceiling of the whole.**
