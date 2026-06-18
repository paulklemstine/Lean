# How Many Friendships Can Avoid a Love Triangle?

## A puzzle about networks, drawn from a hundred-year-old theorem

Imagine a party with `n` guests. Some pairs of guests know each other; most are
strangers. We want the party to be as *connected* as possible — as many
acquaintances as we can arrange — but with one strict social rule:

> **No three guests may all know one another.**

In the language of networks, the guests are *vertices*, the acquaintances are
*edges*, and the forbidden configuration — three mutually-acquainted people —
is a **triangle**. The question is simple to state and surprisingly deep:

> **What is the maximum number of acquaintances we can have at the party if no
> triangle is allowed?**

This is not a riddle with a vague answer. It has a precise, beautiful solution,
discovered by the Hungarian mathematician Pál Turán in the 1940s and, in the
triangle case, by Willem Mantel decades earlier. The answer is exactly

$$
\left\lfloor \frac{n^2}{4} \right\rfloor.
$$

For a party of 100 people, that is 2500 acquaintances — and not one more. This
article tells the story of why that number is the ceiling, how to *reach* it,
and how the same circle of ideas connects friendship networks to number theory
and to fast algorithms for cleaning up messy data.

---

## The extremal mindset

Most of mathematics asks "is this true?" *Extremal* combinatorics asks a
sharper question: **"how much is possible before something is forced to
appear?"** Push a structure to its limit, and at some threshold a forbidden
pattern must crystallize, whether you like it or not.

The triangle problem is the gateway drug to this whole field. The forbidden
pattern is the smallest interesting one — a triangle — and yet the answer is
already non-obvious, and the *method* of proof generalizes to forbid any clique
of any size.

Let us first guess. If we put no edges at all, we trivially avoid triangles, but
that is a boring, empty party. If we connect *everyone* to *everyone*, we have
the maximum $\binom{n}{2}$ edges but a riot of triangles. The truth lives
between these extremes, and the optimal arrangement is shockingly clean.

## The champion: a complete bipartite party

Split the guests into two camps of nearly equal size — say `A` with
$\lfloor n/2 \rfloor$ people and `B` with $\lceil n/2 \rceil$ people. Now declare:

- Everyone in `A` knows everyone in `B`.
- Nobody knows anyone in their own camp.

Could there be a triangle? A triangle needs three people, all mutually
acquainted. By the pigeonhole principle, at least two of the three are in the
same camp — but same-camp guests are strangers. So **no triangle can form.**
This network is called the *complete bipartite graph*, and the number of
acquaintances it achieves is

$$
\left\lfloor \frac{n}{2} \right\rfloor \cdot \left\lceil \frac{n}{2} \right\rceil
= \left\lfloor \frac{n^2}{4} \right\rfloor.
$$

So we can *reach* $\lfloor n^2/4 \rfloor$ acquaintances. The hard part — the part
that makes this a theorem rather than a construction — is proving you can never
do **better**.

## Why you can never beat it: the degree-counting proof

Here is the argument that seals the bound. It is a small marvel of accounting.

For each guest `v`, let $\deg(v)$ be the number of people `v` knows. There are
two classical facts about these numbers.

**Fact 1 (the Handshake Lemma).** If you add up everyone's number of
acquaintances, you count every acquaintance exactly twice — once from each
side of the handshake. So

$$
\sum_{v} \deg(v) = 2|E|,
$$

where $|E|$ is the number of edges.

**Fact 2 (the triangle-free constraint).** Take any two *acquainted* guests `u`
and `v`. In a triangle-free network they can have **no common friend** — a
common friend `w` would complete the triangle `u–v–w`. So the friend-sets of `u`
and `v` are completely disjoint, and since both sets live inside the `n` guests,

$$
\deg(u) + \deg(v) \le n \qquad \text{for every edge } \{u,v\}.
$$

Now sum that last inequality over all edges. A clean bookkeeping identity shows
the left-hand side equals the **sum of squared degrees**, because each guest `v`
gets her degree added once for each of her $\deg(v)$ edges:

$$
\sum_{v} \deg(v)^2 \;=\; \sum_{\{u,v\}\in E}\big(\deg(u)+\deg(v)\big)
\;\le\; n\,|E|.
$$

Finally we invoke the **Cauchy–Schwarz inequality** — equivalently, the fact
that the average of squares is at least the square of the average. It tells us

$$
n \sum_{v} \deg(v)^2 \;\ge\; \Big(\sum_v \deg(v)\Big)^2 = (2|E|)^2.
$$

Chain the two displays together:

$$
(2|E|)^2 \;\le\; n \sum_v \deg(v)^2 \;\le\; n \cdot n\,|E| = n^2 |E|.
$$

Divide by $|E|$ (a party with edges) and you are left with the punchline:

$$
4|E| \le n^2.
$$

That is **Mantel's theorem**: no triangle-free network on `n` vertices can have
more than $n^2/4$ edges. Combined with the bipartite construction that *attains*
the bound, the problem is completely solved. The maximum is exactly
$\lfloor n^2/4 \rfloor$.

What I love about this proof is that it uses no cleverness about graphs at all
in its final move — just the inequality that the squares of numbers are at least
as spread out as their average. Extremal graph theory, again and again, turns
out to be analysis in disguise.

## Climbing the ladder: from triangles to cliques

The triangle is just the first rung. A *clique* of size `r` is a group of `r`
guests who all know one another. Forbidding the triangle is forbidding the
3-clique; one can equally ask: how many edges if we forbid the `r`-clique?

The champion graph generalizes too. Instead of two camps, use `p = r - 1`
camps of nearly equal size, with edges between every pair of *different* camps
and none inside a camp. This is the **Turán graph** `T(n, p)`. The same
pigeonhole argument shows it contains no clique of size `p + 1`: among any
`p + 1` guests, two must share a camp and therefore be strangers.

There is a single, reusable engine that powers the whole induction up this
ladder: the **neighborhood lemma.** It says that if a network has no clique of
size `r`, then for any guest `v`, the people `v` knows — restricted to their
mutual acquaintances — form a network with no clique of size `r − 1`. The
reason is immediate: a forbidden `(r-1)`-clique sitting entirely inside `v`'s
friend-circle would, together with `v`, assemble a forbidden `r`-clique. This
lemma lets you peel off one vertex at a time and recurse, and it is exactly the
inductive backbone of the full Turán theorem.

## When triangles already exist: a repair algorithm

So far we have asked how to *avoid* triangles. A more practical cousin of the
problem asks: **given a messy network that already contains triangles, how few
edges must I delete to make it triangle-free?**

This is not idle. "Make this network triangle-free with minimal edits" is the
shape of real problems: removing conflicting constraints from a scheduling
system, breaking feedback loops in a circuit, or de-biasing a recommendation
graph. In full generality it is computationally hard. But there is a simple,
*provably correct* greedy guarantee:

> **Greedy Triangle Removal.** From any network, repeatedly find a triangle and
> delete one of its three edges. The result is triangle-free, and the total
> number of edges you deleted is at most the number of triangles you started
> with.

The proof is induction on the triangle count. If there are no triangles, you are
done having deleted nothing. Otherwise, pick a triangle, delete one edge — this
*destroys that triangle* and cannot create any new ones — so the triangle count
strictly drops and you recurse. Each deletion is charged to at least one
destroyed triangle, so the deletions never exceed the original triangle count.
It is a certificate: you can always reach triangle-freeness with edits bounded
by a quantity you can compute up front.

To even state "how far is this network from triangle-free?" we need a notion of
distance between two networks. The natural one is the **edge edit distance**:
the number of edges you would have to add or delete to turn one into the other —
the size of the symmetric difference of their edge sets. It behaves exactly as a
distance should: it is symmetric (turning `G` into `H` costs the same as turning
`H` into `G`), and a network's distance to itself is zero.

## A bridge to number theory

Here is where the story leaps to a different continent of mathematics. Consider
a classic question about the integers: how large a set of whole numbers can you
choose from $\{1, 2, \dots, N\}$ before you are *forced* to include three of
them in arithmetic progression — that is, three numbers `a`, `a+d`, `a+2d`
evenly spaced?

This sounds nothing like the party problem. But there is a translation, due in
spirit to Ruzsa and Szemerédi, that turns a *progression-free* set of numbers
into a graph with a very particular triangle structure. Each arithmetic
progression `a, a+d, a+2d` becomes a *triangle* in a cleverly layered graph;
absence of progressions becomes a scarcity of triangles. Bounds about
triangles in graphs then flow back to become bounds about arithmetic
progressions in the integers. This **3-AP-to-triangle bridge** is one of the
most celebrated connections in modern combinatorics, and it is the reason the
"triangle removal lemma" — a far-reaching strengthening of our greedy
certificate — is considered one of the deep results of the field.

## The shadow of a family

One more idea rounds out the toolkit. In extremal *set* theory, we study
families of sets rather than graphs. The **lower shadow** of a family is the
collection of all sets you obtain by deleting a single element from a member.
Picture all the 3-person committees a club might form; the shadow is all the
2-person sub-committees contained in them. A basic but essential fact is that
shadows are **monotone**: enlarge the family, and its shadow can only grow,
never shrink. This humble monotonicity underlies the Kruskal–Katona theorem,
the set-theoretic analogue of Turán's, which pins down exactly how small a
shadow a family of a given size can have.

## Why these results matter

The triangle problem looks like a parlor game, but the techniques it spawned —
degree counting, energy inequalities, extremal constructions, removal lemmas,
and cross-domain bridges — are load-bearing pillars of combinatorics, theoretical
computer science, and even additive number theory.

- **Networks and sociology.** "No triangle" is the simplest model of a network
  with no tight-knit cliques; Mantel's bound quantifies the trade-off between
  density and the absence of such clusters.
- **Algorithms.** The greedy removal certificate is a clean, verifiable bound on
  how much editing a network needs — the backbone of property-testing
  algorithms that decide, by sampling, whether a network is "close to" or "far
  from" triangle-free.
- **Number theory.** Through the AP-to-triangle bridge, triangle counts in graphs
  govern the existence of arithmetic progressions in the integers, a theme that
  culminates in some of the deepest theorems of the twentieth century.

The numbers $\lfloor n^2/4 \rfloor$, the bipartite champion, the disjoint
friend-sets, the Cauchy–Schwarz finish — these are the kind of compact, exact,
endlessly generalizable facts that make extremal combinatorics so addictive. A
party of 100 can host at most 2500 acquaintances without a love triangle. Not
2501. And we can prove it.
