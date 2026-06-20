# The Memory of a Machine That Keeps Forgetting

## A story about composition, rank, and why things settle down

Imagine a long assembly line. At each station a worker takes whatever
arrives, transforms it in some fixed way, and passes it along. Some
workers are careful and lose nothing. Others are sloppy: they merge two
distinct items into one, and that distinction is gone forever — no
downstream worker can ever recover it. A natural question is: as a part
travels down a line of a thousand such stations, how much *information*
about the original survives at the end?

This is not really a question about factories. It is a question about
**linear maps**, and it turns out to have a clean and beautiful answer.
The amount of information that survives can only ever go *down* as the
line gets longer, never up — and because it cannot fall below zero, it
must eventually stop falling and settle at a constant value. The machine
keeps forgetting, but it cannot forget forever; at some point it reaches
a stable core of memory that it preserves no matter how many more
stations you add.

This article is about making that intuition exact. The central character
is an object we call the **transition endomorphism**, and the plot is
driven by a single structural law — a "concatenation" rule reminiscent
of the Chapman–Kolmogorov equation from probability theory — from which
everything else falls out almost for free.

## The cast: vector spaces and linear maps

Let us fix a field $K$ (think of the real numbers $\mathbb{R}$, or the
rationals $\mathbb{Q}$, or the field with two elements) and a vector
space $V$ over $K$. A *linear map* $g : V \to V$ is a transformation
that respects addition and scaling: $g(u+v) = g(u)+g(v)$ and
$g(c\,v) = c\,g(v)$. Such a self-map of $V$ is called an
**endomorphism**. Concretely, if $V$ is $n$-dimensional, an
endomorphism is just an $n \times n$ matrix.

The single most important number attached to a linear map is its
**rank**: the dimension of its image, i.e. the dimension of the set of
all outputs it can produce,
$$\operatorname{rank}(g) = \dim_K \big(\operatorname{im}\, g\big).$$
Rank is exactly the "information survival" counter from our assembly
line. A map of full rank loses nothing; every drop in rank is a
permanent collapse of some directions in the space.

Two facts about rank are classical and will be our only external inputs.
When you compose two maps, the output of the composite cannot be richer
than the output of *either* factor:
$$\operatorname{rank}(g \circ h) \le \operatorname{rank}(g),
\qquad
\operatorname{rank}(g \circ h) \le \operatorname{rank}(h).$$
The first holds because the image of $g \circ h$ sits inside the image
of $g$; the second because feeding $h$'s already-collapsed output into
$g$ cannot un-collapse it. These two submultiplicativity inequalities
are the seeds from which our whole story grows.

## The hero: the transition endomorphism

Now suppose we do not have a single map but a *stream* of them — one for
every station on the line. Formally, a sequence
$$f : \mathbb{N} \to (V \to V), \qquad f(0), f(1), f(2), \dots$$
of endomorphisms. We want to describe what happens to a vector that
enters at station $i$ and leaves just before station $j$. That is the
ordered composition of the maps in the window $[i, j)$:
$$\operatorname{trans}(f, i, j) \;=\; f(j-1) \circ f(j-2) \circ \cdots \circ f(i+1) \circ f(i).$$
We call this the **transition endomorphism** over the window $[i, j)$.
Read it right-to-left, the way function composition runs: the vector
meets $f(i)$ first and $f(j-1)$ last.

What if the window is empty or backwards, $j \le i$? Then nothing
happens — the part passes through untouched — so we set
$\operatorname{trans}(f, i, j)$ equal to the identity map. In particular
$\operatorname{trans}(f, i, i)$ is the identity: an empty journey
changes nothing.

This definition is best made by recursion on the upper endpoint. The
empty window gives the identity:
$$\operatorname{trans}(f, i, 0) = \mathrm{id}.$$
And extending a window by one station, when $i \le j$, simply tacks the
next worker $f(j)$ onto the front of the output:
$$\operatorname{trans}(f, i, j+1) = f(j) \circ \operatorname{trans}(f, i, j).$$
Those two clauses, plus the convention that a backwards window is the
identity, pin the object down completely.

## The engine of the plot: the concatenation law

Here is the structural heart of the matter. Suppose you split the
journey into two consecutive legs: first the window $[i, j)$, then the
window $[j, k)$, with $i \le j \le k$. Travelling the whole way is the
same as travelling the first leg and then the second:

> **Concatenation law (`transEndo_comp`).** For all $i \le j \le k$,
> $$\operatorname{trans}(f, i, k) \;=\; \operatorname{trans}(f, j, k) \circ \operatorname{trans}(f, i, j).$$

This is the linear-algebra cousin of the **Chapman–Kolmogorov
equation** for transition probabilities of a Markov process: to get
from time $i$ to time $k$, go from $i$ to $j$ and then from $j$ to $k$.
Here, instead of multiplying stochastic matrices, we compose
endomorphisms — but the bookkeeping is identical. The proof is an honest
induction on $k$ with a careful case split (does the middle point $j$
lie strictly below $k$, or has the second leg just shrunk to nothing at
$j = k$?), but the *meaning* is the obvious one: composition is
associative, and a journey is the concatenation of its legs.

Everything else in the theory is a corollary of this one equation.

## Consequence 1: information can only be lost

Apply the two rank inequalities to the concatenation law. Writing the
whole-journey map as the composite of two legs and using
$\operatorname{rank}(g \circ h) \le \operatorname{rank}(h)$, we get
immediately, for $i \le j \le k$:

> **Rank monotonicity (`rank_transEndo_le_right`, `rank_transEndo_antitone`).**
> $$\operatorname{rank}\big(\operatorname{trans}(f, i, k)\big)
> \;\le\;
> \operatorname{rank}\big(\operatorname{trans}(f, i, j)\big).$$

In words: **widening the window from the same starting point can never
increase the rank.** The longer the line, the less can survive. There is
a twin statement using the other inequality
($\operatorname{rank}(g \circ h) \le \operatorname{rank}(g)$),
`rank_transEndo_le_left`, comparing the long window to its *outer* leg
$[j, k)$. And the one-step special case,
`rank_transEndo_succ_le`, says adding a single station never helps:
$$\operatorname{rank}\big(\operatorname{trans}(f, i, j+1)\big)
\le
\operatorname{rank}\big(\operatorname{trans}(f, i, j)\big),
\qquad i \le j.$$

So the sequence of ranks, as the window grows, is **non-increasing** —
"antitone," in the technical term. It is a staircase that only ever
steps down.

## Consequence 2: the constant line is just repeated multiplication

What if every worker on the line is the *same* worker $g$? Then the
transition map over a window of length $\ell = j - i$ is simply $g$
applied $\ell$ times:

> **Constant stream (`transEndo_const`).** For $i \le j$,
> $$\operatorname{trans}(f, i, j) = g^{\,j-i} \quad\text{when } f(n) = g \text{ for all } n.$$

This little identity is a bridge. It connects the brand-new
"transition" object to the oldest object in the book — the iterates
$g, g^2, g^3, \dots$ of a single map. And through that bridge, our
monotonicity result instantly tells us something about *powers*:

> **Iterates lose rank (`rank_pow_succ_le`).** For every endomorphism
> $g$ and every $n$,
> $$\operatorname{rank}(g^{\,n+1}) \le \operatorname{rank}(g^{\,n}).$$

Each time you apply $g$ again, the image can only shrink or hold steady.
This is the familiar descending chain
$$V \supseteq \operatorname{im}(g) \supseteq \operatorname{im}(g^2)
\supseteq \operatorname{im}(g^3) \supseteq \cdots,$$
seen through the single lens of rank. It is the linear-algebraic shadow
of how a repeated process grinds a space down toward its stable core —
the heart of what is classically called the **Fitting decomposition**.

## Consequence 3: forgetting cannot last forever

Now restrict to a **finite-dimensional** space $V$, say of dimension
$n = \dim_K V$. The rank of any map is an integer between $0$ and $n$.
Read the transition rank as a plain natural number,
$$\operatorname{rankSeq}(f, i, j) = \operatorname{rank}\big(\operatorname{trans}(f, i, j)\big) \in \{0, 1, \dots, n\}.$$
We have just shown two things about the window-from-zero sequence
$m \mapsto \operatorname{rankSeq}(f, 0, m)$:

- it is **bounded** — never exceeds $n$ (`rankSeq_le_finrank`);
- it is **antitone** — never increases (`rankSeq_antitone`).

A sequence of natural numbers that only ever decreases cannot decrease
forever; it would run out of room below zero. So it must eventually
freeze:

> **Eventual constancy (`rankSeq_eventually_const`).** There is an index
> $N$ beyond which $\operatorname{rankSeq}(f, 0, m)$ takes one and the
> same value for all $m \ge N$.

The clean way to see this is a small, reusable fact about order, true of
*any* non-increasing sequence of natural numbers
(`antitone_nat_eventually_const`): such a sequence is eventually
constant, because the natural numbers are well-founded — there is no
infinite strictly descending chain. The machine keeps forgetting only up
to a point. After finitely many genuine collapses, it reaches a stable
core of memory that it preserves forever after.

## Why this is more than bookkeeping

The pleasure of this little theory is how a single combinatorial law —
*a journey is the concatenation of its legs* — organizes a cluster of
facts that, stated separately, look like they need separate proofs. Rank
monotonicity, the identification of constant streams with powers, the
rank decay of iterates, and the eventual stabilization of the rank
sequence are all corollaries of `transEndo_comp` together with the two
classical submultiplicativity inequalities. We did not re-derive a
Sylvester-type rank theorem from scratch; we *reused* the standard one
and let the concatenation law do the structural work.

The viewpoint also has reach. The transition endomorphism is a
**transfer operator** — exactly the kind of object that appears, under
different names, all over mathematics and its applications:

- In **probability**, replace endomorphisms by stochastic matrices and
  the concatenation law becomes Chapman–Kolmogorov for a
  time-inhomogeneous Markov chain.
- In **dynamical systems** and **ergodic theory**, transfer operators
  push densities forward in time; composing them over a window is
  literally evolving the system, and rank collapse measures loss of
  resolution.
- In **control theory** and **linear time-varying systems**, the
  product $f(j-1)\cdots f(i)$ is the state-transition matrix, and its
  rank governs reachability and observability.
- In **the study of a single operator**, the constant-stream case is the
  descending chain of iterate images whose stable limit is the Fitting
  (generalized-image) component — the backbone of the theory of
  nilpotent-plus-invertible decompositions.

What unifies them is the same humble truth our assembly line taught us:
**composition can only lose, finiteness forces it to stop losing, and
the resting place is a structural invariant of the stream.**

## The shape of the argument, in one breath

Define the transition endomorphism by recursion. Prove that a long
window is the composite of two short ones. Quote the fact that composing
maps cannot raise rank. Conclude that growing the window cannot raise
rank. Notice that a bounded, never-increasing integer sequence must
level off. That is the entire arc — five sentences — and yet it captures
something genuinely true about every repeated linear process: it has a
memory, that memory only erodes, and the erosion always ends.

Sometimes the most satisfying mathematics is not the theorem with the
longest proof, but the one definition that makes a dozen scattered facts
snap into a single line. The transition endomorphism is one of those
definitions.
