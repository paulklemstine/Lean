# Close Proofs: When a Tie-Breaking Bound Is Exactly Tight

## A coin flip that decides everything

Imagine you are running a huge computation and, at some crucial step, you must
pick out *one* special object from an enormous list — say, a single cheapest
route through a network, or a single perfect matching in a graph. The trouble is
that there may be many objects tied for "best," and a computer, faced with a tie,
has no principled way to choose. Ties are the enemy of clean algorithms.

In 1987, three computer scientists — Ketan Mulmuley, Umesh Vazirani, and Vijay
Vazirani — found a beautiful escape hatch now called the **Isolation Lemma**.
Their idea: sprinkle small *random weights* on the underlying elements. With high
probability, exactly one of the competing objects becomes strictly cheaper than
all the others. The tie is broken; a unique winner emerges; the algorithm can
proceed. This single trick underlies fast parallel algorithms for matching,
randomized methods in complexity theory, and much of what we know about the power
of randomness in computation.

But a probabilistic guarantee raises a sharper question. If we sprinkle weights
and count, *how many* weightings actually succeed in isolating a unique winner?
And can that count be pinned down not approximately, but **exactly**?

This article is about a precise answer to that question in a clean model, and
about a subtle twist that appears once you allow the objects to carry built-in
*offsets* — head starts and handicaps baked in before the random weights arrive.

## The setup, made concrete

Fix $n$ "vertices," think of them as the elements we weight, and let each vertex
receive an integer weight drawn from the palette $\{0, 1, \dots, d-1\}$. A full
choice of weights is a vector $w = (w_1, \dots, w_n)$, and there are $d^n$ of
them in total.

The simplest interesting family of competing objects is the **singleton
hypergraph**: the objects are just the individual vertices $\{1\}, \{2\}, \dots,
\{n\}$, each with "cost" equal to its own weight. A weighting $w$ is called
**isolating** if a *single* vertex attains the strict minimum cost — one clear
winner, no ties.

How many of the $d^n$ weightings are isolating? Counting is easy once you see the
structure. Suppose the winner is a specific vertex $i$ with winning value $m$.
Every other vertex must carry a value strictly larger than $m$, and there are
$d - 1 - m$ such values. Since $n-1$ other vertices each independently pick one,
that gives $(d-1-m)^{n-1}$ weightings. Sum over the possible winning values $m$
and over the $n$ possible winners, reindex, and you land on a strikingly clean
formula:

$$\#\{\text{isolating weightings}\} \;=\; n \sum_{j=0}^{d-1} j^{\,n-1}.$$

For $n = 3$ vertices and $d = 3$ values this is $3\,(0^2 + 1^2 + 2^2) = 15$; for
$d = 4$ it is $3\,(0 + 1 + 4 + 9) = 42$. These match direct enumeration exactly.

This number is not just any count. A general theorem of Vance Faber and Michael
Harris shows that for **every** inclusion-free family of objects on $n$ vertices —
every "Sperner family," where no object is contained in another — the number of
isolating weightings is *at least* $n \sum_{j=0}^{d-1} j^{\,n-1}$. The singleton
hypergraph does not merely satisfy this lower bound; it achieves it with
equality. The bound is **tight**, and the humble singleton family is the witness.

## Now add offsets — and watch the bound move

Real applications rarely start from a level playing field. Each object often
carries a fixed **offset**: a bias, a head start, a handicap known before the
random weights are drawn. In our language, vertex $i$ gets an integer offset
$f_i$, and its cost becomes $f_i + w_i$ instead of just $w_i$. A weighting is
isolating exactly when a single vertex attains the strict minimum of the
*shifted* costs.

Does the clean count survive? Here is where the story turns. Consider $n = 3$,
$d = 3$, and offsets $f = (0, 1, 5)$. Direct enumeration now gives **21**
isolating weightings — strictly more than the offset-free value of $15$. The
extremal bound is *not* an invariant of the objects alone; it can be pushed
upward by biasing them apart.

The reason is intuitive. Offsets that pull the vertices apart *break ties* that
would otherwise have occurred. Every tie broken in favor of a unique minimizer
turns a non-isolating weighting into an isolating one. Spreading the field can
only *increase* the number of clean winners, never decrease it.

## The master formula

The central result of this work is an exact accounting that holds for **any**
integer offset whatsoever. Fix the winning vertex $i$ and its shifted-minimum
value $m$. Every other vertex $j$ must satisfy $f_i + m < f_j + w_j$, i.e. its
weight must clear the *offset-shifted threshold*. The number of admissible values
for vertex $j$ is simply

$$\#\{\,k \in \{0,\dots,d-1\} : f_i + m < f_j + k\,\}.$$

Because the other coordinates move independently, the counts multiply. Summing
over the winner $i$ and the winning value $m$ gives the exact isolating count for
an arbitrary offset $f$:

$$I(n, d, f) \;=\; \sum_{i=1}^{n}\; \sum_{m=0}^{d-1}\; \prod_{j \neq i}
\#\{\,k \in \{0,\dots,d-1\} : f_i + m < f_j + k\,\}.$$

This one identity contains the whole landscape. It matches brute-force
enumeration on every offset tested, and — more importantly — it lets us read off
the two extremes of the entire spectrum of possible counts.

## Two extremes, cleanly pinned

**Constant offsets recover the extremal value.** If every vertex gets the *same*
offset $c$, the shift $f_i + m < f_j + k$ collapses to $m < k$ — exactly the
offset-free condition. Each factor becomes $d - 1 - m$, the product is
$(d-1-m)^{n-1}$, and the whole formula returns to

$$I(n, d, \text{const}) \;=\; n \sum_{j=0}^{d-1} j^{\,n-1}.$$

A uniform bias changes nothing: the level playing field, tilted uniformly, is
still level. For $n = 3$, $d = 4$ this is $42$ for *every* constant offset,
matching enumeration.

**Widely separated offsets isolate everything.** At the opposite extreme, choose
offsets that spread the vertices far apart — for instance $f_i = i \cdot d$. Now
one vertex is so cheap that it wins under *every* weighting: with $f_1 = 0$ its
cost never exceeds $d-1$, while every other vertex starts at cost at least $d$.
There is always a unique strict minimum, so **every** one of the $d^n$ weightings
is isolating:

$$I(n, d, \text{separated}) \;=\; d^n.$$

For $n = 3$, $d = 4$ this is $4^3 = 64$ — the largest count possible, and again a
perfect match with enumeration.

So the isolating count for the singleton hypergraph is not a single magic number.
It lives in a band whose floor is the Faber–Harris extremal value
$n \sum_{j<d} j^{n-1}$, reached by the symmetric (constant) offsets, and whose
ceiling is the trivial maximum $d^n$, reached by the fully separated offsets. The
offset is the dial that moves the count between them.

## Why the exactness matters

It is one thing to know a bound holds; it is another to know precisely *when* it
is met and by how much any deviation overshoots. Three features make this picture
satisfying.

First, it is **genuine, not vacuous**. For separated offsets the isolating set is
literally all of $[d]^n$; for constant offsets it coincides, weighting for
weighting, with the offset-free isolating set. Nothing is hidden behind a
degenerate special case.

Second, it settles a natural misconception. One might guess that the extremal
value $n \sum_{j<d} j^{n-1}$ is an intrinsic feature of the object family,
immune to offsets. The witness $f = (0,1,5)$ with its count of $21 > 15$ refutes
that cleanly: **offsets genuinely move the count.**

Third, it turns a global extremal statement into a *local, checkable* one. The
whole behavior is now governed by a single quantity — the "above-threshold"
cardinality $\#\{k : f_i + m < f_j + k\}$ — that one can compute term by term.
Questions about the global minimum, the maximum, and everything in between reduce
to comparing these little counts against their symmetric baseline.

## A wider view

The Isolation Lemma is one of those rare tools whose usefulness is inversely
proportional to how complicated it looks. It says: to break ties, add noise. The
counting refinement asks the accountant's question behind the magician's trick —
exactly how much noise succeeds, and the answer, at least for the cleanest family,
is a formula you can write on an index card.

Adding offsets is where theory meets practice. Real systems come pre-biased, and
the natural worry is that a pretty extremal bound might shatter under those
biases. What the master formula shows is the opposite of chaos: the count moves,
yes, but it moves *predictably*, sweeping a well-understood interval between a
symmetric floor and a fully-separated ceiling, with each endpoint carrying a
transparent combinatorial meaning.

There is more to chase. Is the constant offset always the unique minimizer of the
count, so that any bias strictly increases isolation? Does the count sweep through
*every* integer between the floor and the ceiling as the offset varies? Do more
elaborate object families always admit *some* offset that pushes them down to the
extremal value? And does allowing real-valued offsets, rather than integer ones,
ever produce a count unreachable by integers? Each of these is a concrete
conjecture with a concrete plan of attack, and each begins from the same anchor:
one exact, hand-computable formula for how a single tie-breaking dial reshapes the
space of clean winners.
