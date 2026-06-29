# When Loops Can't Cancel: The One Forbidden Pattern Behind Cyclic Gain Graphs

## A puzzle about roads between two towns

Imagine two towns connected by several parallel roads. On each road we paint
a number — but not an ordinary number. We work on a *clock* with $n$ hours, so
the only available labels are $0, 1, 2, \dots, n-1$, and arithmetic wraps
around: on a $12$-hour clock, $10 + 5 = 3$. Mathematicians call this clock the
cyclic group $\mathbb{Z}/n$.

Now play a game. Drive out of the first town along one road and back along
another. As you go, add up the labels — but *subtract* a label whenever you
travel a road backwards. If a round trip ever sums to exactly $0$ on the clock,
we say that little loop is **balanced**. Balanced loops are the enemy: they are
coincidences, hidden symmetries, ambiguities that make the labelling useless
for telling roads apart.

So here is the question. With $k$ roads between the towns, can you always paint
the labels so that *no* round trip cancels — so that every two-road loop is
**unbalanced**?

The answer is beautifully crisp. You can do it **exactly when $k \le n$**, and
not a road more. With $n+1$ roads, failure is guaranteed no matter how cleverly
you paint. And that one failing configuration — call it $(n+1)K_2$, the
"$(n+1)$ parallel edges" pattern — turns out to be the *single, unavoidable
fingerprint* of impossibility across a whole world of more complicated
networks. This article is the story of that fingerprint.

## Gains, balance, and why coincidences matter

The roads-between-towns picture is a special case of a rich and old idea: the
**gain graph** (also called a voltage graph or, in its most general form, a
*biased graph*). The ingredients are simple:

- a graph — vertices and edges;
- a group of "gains" — here the clock $\mathbb{Z}/n$, where we can add and
  negate;
- a label $g(e)$ on each edge, drawn from the group.

Walk around any closed loop in the graph, adding the label of each edge you
traverse forwards and subtracting it when you traverse it backwards. The
running total is the **gain of the loop**. A loop is **balanced** when its gain
is the identity element $0$.

This abstract setup quietly models a surprising range of real situations.
Electrical engineers see *voltages*: a loop is balanced when Kirchhoff's law is
satisfied and no net potential builds up around it. Crystallographers and
physicists studying periodic structures see *frustration*: an unbalanced loop
is one where local rules can't be globally reconciled, the same phenomenon that
makes certain magnets "frustrated." Scheduling and frequency-assignment
problems see *conflicts*: a balanced loop is an unwanted collision of
assignments. In every case, the question "can I label things so the bad loops
never appear?" is the question of **gainability**.

We say a biased graph is **$\mathbb{Z}/n$-gainable** when there exists a clock
labelling that *realises its prescribed pattern of balance* — every loop the
design declares balanced really sums to $0$, and every loop it declares
unbalanced really does not. Gainability is the precise sense in which a
combinatorial blueprint can be implemented with honest clock arithmetic.

## The simplest obstruction is the deepest

Return to the two towns. A parallel class of $k$ roads has exactly one kind of
loop: a **digon**, the round trip out road $i$ and back road $j$, with gain
$g(i) - g(j)$. That digon is balanced precisely when $g(i) = g(j)$. To make
*every* digon unbalanced, the labels $g(1), \dots, g(k)$ must be **pairwise
distinct** points on the clock.

Now the whole problem collapses to counting. The clock $\mathbb{Z}/n$ has
exactly $n$ positions. You can place $k$ distinct markers on $n$ positions if
and only if $k \le n$. This is nothing more than the **pigeonhole principle**:
with $n+1$ roads and only $n$ clock positions, two roads must share a label,
and that pair instantly forms a balanced loop.

> **Theorem (Parallel-class threshold).** The parallel class of $k$ edges is
> $\mathbb{Z}/n$-gainable if and only if $k \le n$.

For $k \le n$ the construction is explicit and effortless: pick any injection
of the $k$ roads into the $n$ clock positions — say label road $i$ with $i$
itself — and every digon $i \ne j$ now has gain $i - j \ne 0$. For $k = n+1$
the pigeonhole forbids it absolutely.

What makes this small fact powerful is not the fact itself but its **stability**.
The pattern $(n+1)K_2$ doesn't just fail in isolation; it *infects* every
larger network that contains it.

## Minors: the right notion of "contains a pattern"

Graph theorists long ago discovered that the natural way to say "structure $B$
hides inside structure $G$" is the language of **minors**. A minor is obtained
by deleting edges and vertices and by merging (contracting) connected pieces.
The crowning achievement of the field — the Graph Minor Theorem of Robertson
and Seymour — shows that enormous families of graphs are characterised by a
*finite list of forbidden minors*. Planar graphs, famously, are exactly the
graphs that avoid two forbidden patterns. The forbidden minors are the
irreducible "reasons" a graph fails to have a property.

For gain graphs the right version is the **labelled minor**, which respects not
only the shape of the graph but its gains and balances: a labelled-minor
embedding carries each loop of the smaller pattern to a loop of the larger one,
matching balanced to balanced. The decisive structural fact is that
**gainability is preserved when you pass to a minor**.

> **Theorem (Minor-closedness).** If a biased graph is gainable over a group,
> then so is every one of its labelled minors. A working labelling of the whole
> can always be *pulled back* to a working labelling of any pattern inside it.

The proof is a one-line miracle once set up correctly: a minor embedding gives
a map of edges and a record of which were reversed; pulling the ambient
labelling back along that map (negating where an edge was flipped) reproduces
exactly the right gains, because the signed sum around a loop is preserved under
this pullback. Balance is matched on the nose, so a realisation upstairs becomes
a realisation downstairs.

Minor-closedness has a contrapositive that does all the work: **if a pattern is
*not* gainable, then nothing containing it can be gainable either.** Combine
this with the pigeonhole obstruction and we get a sweeping necessary condition.

> **Theorem (Universal obstruction).** Any $\mathbb{Z}/n$-gainable biased graph
> contains no $(n+1)K_2$ minor. The forbidden fingerprint can never appear in a
> success story.

## The clean dividing line

For the family of *parallel-class* graphs — any number of roads bundled between
two towns, with an arbitrary declared pattern of which roads are "the same"
(grouped into **balance classes**) — the obstruction is not merely necessary;
it is the *whole story*. Counting balance classes, one proves the perfectly
matched pair of facts:

> **Theorem (Excluded-minor characterisation).** A parallel-class biased graph
> is $\mathbb{Z}/n$-gainable **if and only if** it has no $(n+1)K_2$ minor —
> equivalently, if and only if its number of balance classes is at most $n$.

In one direction, a clock labelling that separates the classes injects the
balance classes into the $n$ clock positions, so there can be at most $n$ of
them, and no $(n+1)K_2$ can hide inside. In the other, whenever there are at
most $n$ classes we simply drop each class onto its own distinct clock position
and check that the construction realises every digon's balance correctly. The
two halves meet exactly at the threshold $n$.

The upshot is a statement of striking economy:

> **$(n+1)K_2$ is the *unique* excluded minor for $\mathbb{Z}/n$-gainability of
> parallel classes.** It is forbidden (it is not gainable), and it is *minimal*
> in being forbidden — delete any single one of its $n+1$ roads and the
> survivor $nK_2$ becomes gainable.

A single, explicit, human-sized pattern governs an entire infinite family.

## Bigger clocks are more forgiving

There is one more twist that turns a clean fact into a structured landscape.
How does gainability change as we change the clock? Replacing $\mathbb{Z}/m$ by
a larger clock can only *help* — but only in a precise arithmetic sense.

The key is that whenever $m$ divides $n$, the small clock sits faithfully
inside the big one: there is an injective, addition-preserving map
$\mathbb{Z}/m \hookrightarrow \mathbb{Z}/n$ sending the generator $1$ to
$n/m$, which has exact order $m$. Any working labelling on the small clock can
be transported through this embedding, and because the map is injective it never
accidentally creates a balanced loop. More generally, *any* injective
homomorphism between gain groups carries a realisation forward.

> **Theorem (Divisibility law).** If $m$ divides $n$, then every
> $\mathbb{Z}/m$-gainable biased graph is also $\mathbb{Z}/n$-gainable. Larger
> cyclic clocks gain a *superset* of the patterns the smaller ones can.

This factors the entire dependence on the modulus through the elegant lattice
of cyclic groups ordered by divisibility. The threshold $k \le n$ for parallel
classes is the visible shadow of this law: doubling the clock from $\mathbb{Z}/n$
to $\mathbb{Z}/2n$ doubles the number of roads you can keep mutually
unbalanced.

## Why primality is a red herring

A natural guess, when a counting obstruction lives in $\mathbb{Z}/n$, is that
the *prime* moduli are special — that the arithmetic of $n$ matters. Here it
emphatically does not. The pigeonhole argument and the digon characterisation
use only one fact about the clock: that $\mathbb{Z}/n$ has exactly $n$ elements.
Whether $n$ is prime, a prime power, or a product of many primes is completely
irrelevant to the parallel-class story. The threshold is always $n$, and the
excluded minor is always $(n+1)K_2$. What primality *does* affect lives deeper —
in richer obstructions built from triangles and tetrahedra (the signed-graph
phenomena $\pm K_3$ and $-K_4$) — but those require finer structure than the
loop-counting world of parallel classes can see.

## The shape of the result

Step back and the architecture is satisfying. A child's counting argument —
you can't put $n+1$ pigeons in $n$ holes — is promoted, by the structural
machinery of minors, into a complete classification. The lone forbidden pattern
$(n+1)K_2$ is

- **necessary**: it can never appear inside anything gainable;
- **sufficient**: avoiding it (for parallel classes) guarantees gainability;
- **minimal**: it is the smallest such forbidden pattern, irreducible;
- **uniform**: it works for every clock size $n \ge 1$, prime or not;
- **monotone**: it relaxes predictably as clocks grow along divisibility.

This is the recurring dream of structural mathematics: replace a property that
seems to require checking infinitely many cases with a finite, explicit list of
forbidden fingerprints. Here the list has length one. Two towns, $n+1$ roads,
a clock with $n$ hours — and an impossibility you can see, name, and never
escape.
