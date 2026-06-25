# When Counting Forces Structure: A Tour Through Extremal Graph Theory

Imagine you are designing a social network. You have $n$ people, and you draw a
line between any two who are friends. You want the network to be *busy* — lots
of friendships — but you also want to forbid a certain awkward pattern: maybe no
three people who are all mutually friends (no "triangle"), or no larger tight
clique of $r$ people who all know each other. How many friendships can you
possibly allow before such a forbidden pattern is unavoidable?

This deceptively simple question is the beating heart of **extremal graph
theory**, one of the most beautiful corners of modern combinatorics. Its central
insight is almost philosophical: *if a structure is large enough, it cannot
avoid having structure*. Pile on enough edges and a triangle appears whether you
like it or not. Pile on enough numbers and an arithmetic progression appears.
Abundance breeds order.

This article tells the story of four landmark results that make this slogan
precise — Turán's theorem, Mantel's theorem, the Kruskal–Katona theorem, and
the triangle removal lemma — and shows how they link together to prove one of
the crown jewels of additive combinatorics: **Roth's theorem** on arithmetic
progressions. Along the way we'll meet a surprising bridge that connects
counting cliques in graphs to counting subsets of a set, and another that ties
edge-counting to the famous "party problem" of Ramsey theory.

---

## Part I: Turán's Ceiling

Let's start with the simplest version of our question. A **triangle** is three
people who are all mutually friends. How many friendships can a triangle-free
network of $n$ people have?

The answer, discovered by Willhelm Mantel in 1907, is elegant: at most
$n^2/4$. And the bound is achieved exactly — split your $n$ people into two
equal groups and let everyone in one group befriend everyone in the other, but
nobody within their own group. This "complete bipartite" arrangement has
$\lfloor n/2 \rfloor \cdot \lceil n/2 \rceil \approx n^2/4$ edges and not a single
triangle, because any triangle would need two of its vertices in the same group.

**Mantel's theorem.** *A triangle-free graph on $n$ vertices has at most $n^2/4$
edges:*
$$ e(G) \le \frac{n^2}{4}. $$

In our formalization this appears as the result `mantel_real`, with a clean
integer companion `mantel_nat` stating the equivalent $4\,e(G) \le n^2$, avoiding
any rounding subtleties.

Mantel's theorem is the first case of a much grander result. Instead of
forbidding triangles ($K_3$, the complete graph on $3$ vertices), forbid the
complete graph $K_{r+1}$ on $r+1$ vertices — a clique of $r+1$ mutual friends.
In 1941 Pál Turán found the exact maximum number of edges.

**Turán's theorem.** *A graph on $n$ vertices containing no clique $K_{r+1}$ has
at most*
$$ e(G) \le \left(1 - \frac{1}{r}\right)\frac{n^2}{2} $$
*edges.*

The extremal example generalizes the bipartite construction: split the $n$
vertices into $r$ nearly-equal groups and join every pair of vertices in
*different* groups. This "Turán graph" contains no $K_{r+1}$ because a clique can
use at most one vertex per group. Setting $r = 2$ recovers Mantel's $n^2/4$.

Our formalization captures Turán's theorem in two flavours. The integer form
`turan_edge_bound_nat` states the rearranged inequality
$$ 2r \cdot e(G) \le (r-1)\, n^2, $$
which sidesteps division entirely and is the cleanest object to manipulate. The
real density form `turan_edge_bound_real` then upgrades this to the textbook
$\left(1 - \tfrac{1}{r}\right) n^2/2$. The translation between them hides a subtle
trap: with whole-number subtraction, $r - 1$ misbehaves when $r = 0$, so the
proof quietly rewrites $r$ as $m + 1$ to keep the arithmetic honest.

### A bridge to the party problem

Here is where the story takes its first surprising turn. Turán's theorem caps
the number of edges. Ramsey theory, by contrast, guarantees that certain
patterns *must* appear. The most famous Ramsey fact is the "theorem on
friends and strangers": **among any six people, there are always three mutual
friends or three mutual strangers.** In symbols, $R(3,3) = 6$.

Now combine the two viewpoints. Take a triangle-free network on at least six
people. Mantel says it has few edges (at most $n^2/4$). But Ramsey says that
among any six people there are three mutual friends *or* three mutual strangers
— and since there are no three mutual friends, there must be three mutual
*strangers*. In graph language: the **complement** of the network contains a
triangle.

This is the content of `mantel_ramsey_bridge`: on at least six vertices, a
triangle-free graph $G$ simultaneously obeys Mantel's edge bound *and* forces a
triangle into its complement $G^c$. Extremal theory caps one side; Ramsey theory
fills the other. The same six people, seen through two lenses, tell a complete
story.

---

## Part II: Shadows — From Cliques to Edges

Our second landmark, the **Kruskal–Katona theorem**, lives at first glance in a
different universe: the world of *set systems*. But it turns out to speak
directly about graphs, and the translation is one of the most satisfying in the
subject.

Picture a family $\mathcal{A}$ of sets, all of the same size $r$. Its **shadow**,
written $\partial \mathcal{A}$, is the collection of all sets you can make by
deleting a single element from a member of $\mathcal{A}$. For instance, the
shadow of $\{1,2,3\}$ contains $\{1,2\}$, $\{1,3\}$, and $\{2,3\}$. The
Kruskal–Katona theorem answers: if $\mathcal{A}$ is large, how small can its
shadow be? You can't have many $r$-sets sharing only a few $(r-1)$-subsets.

**Kruskal–Katona (shadow lower bound).** *If $\mathcal{A}$ is a family of
$r$-element subsets with at least $\binom{k}{r}$ members, then its shadow has at
least $\binom{k}{r-1}$ members:*
$$ |\mathcal{A}| \ge \binom{k}{r} \;\Longrightarrow\; |\partial \mathcal{A}| \ge \binom{k}{r-1}. $$

The extremal families are the "colex-initial" ones — and the cleanest example is
simply *all subsets of a fixed $k$-element set*. This is the form we package as
`kk_shadow_lower`. We also prove a structural companion, `kk_iterated_shadow_nonempty`:
a large enough $r$-uniform family has the property that its shadow, the shadow of
its shadow, and so on, never die out — the chain of shadows descends all the way
to the empty set.

### The geometric heart

Now watch the magic. In any graph, a **triangle is a set of three vertices**, and
an **edge is a set of two vertices**. What happens when you delete one vertex
from a triangle? You get an edge — and not just any pair, but a genuine edge of
the graph, because all three pairs in a triangle are connected.

This means: **the shadow of the family of triangles sits inside the family of
edges.** We capture this as `shadow_triangles_subset_edges`. It is a one-line
structural truth with enormous consequences, because now Kruskal–Katona applies.

Feed the family of triangles ($3$-element cliques) into the shadow bound. If a
graph has at least $\binom{k}{3}$ triangles, Kruskal–Katona guarantees its
triangle-shadow has at least $\binom{k}{2}$ members. And since that shadow is
contained in the edges, the graph must have at least $\binom{k}{2}$ edges.

**Kruskal–Katona for graphs.** *A graph on $n$ vertices with at least
$\binom{k}{3}$ triangles (where $3 \le k \le n$) has at least $\binom{k}{2}$
edges:*
$$ \#\{\text{triangles}\} \ge \binom{k}{3} \;\Longrightarrow\; \#\{\text{edges}\} \ge \binom{k}{2}. $$

This is `card_edgeFinset_ge_of_triangles` (with an intermediate clique-counting
version `card_cliqueFinset_two_ge_of_triangles` and a bookkeeping lemma
`card_cliqueFinset_two_eq_edgeFinset` confirming that "$2$-cliques" really are
edges). The slogan: **many triangles force many edges.** A network can't be rich
in tight little triangles while staying sparse overall — abundance of small
structure forces abundance of the building blocks.

---

## Part III: The Removal Lemma and the Magic of Regularity

Our third act introduces the most powerful tool in the modern combinatorial
arsenal, and the engine that drives everything toward Roth's theorem: the
**triangle removal lemma**.

Its statement sounds almost too good to be true. Suppose a graph has *very few*
triangles — not zero, but a tiny fraction of what's possible. Then you can make
it completely triangle-free by deleting only a tiny fraction of its edges.

**Triangle removal lemma.** *For every $\varepsilon > 0$ there is a $\delta > 0$
such that every graph on $n$ vertices with fewer than $\delta n^3$ triangles can
be made triangle-free by deleting fewer than $\varepsilon n^2$ edges.*

We package this as `triangle_removal_lemma`. Why is this remarkable? Because the
number of triangles ($\sim n^3$) and the number of edges ($\sim n^2$) live on
completely different scales. The lemma says that "few triangles" (a
*cubic*-scale condition) translates into "few edges to delete" (a
*quadratic*-scale conclusion). Squeezing out a cubic number of triangles costs
only a quadratic number of edge deletions.

The proof — far beyond what we restate here — rests on **Szemerédi's regularity
lemma**, perhaps the single most influential result in extremal combinatorics.
Roughly, it says any large graph can be partitioned into a bounded number of
pieces so that the connections between almost every pair of pieces look
*pseudorandom*. Once a graph is carved into these well-behaved chunks, counting
triangles becomes a matter of probability, and the removal lemma follows.

It is often more useful to flip the lemma around. The contrapositive,
`not_farFromTriangleFree_of_few_triangles`, says: a graph that is *far* from
triangle-free (you'd need to delete $\ge \varepsilon n^2$ edges) must contain a
*cubic* number of triangles, at least $\delta n^3$. Combining this with the fact
that being far from triangle-free guarantees many triangle copies yields a sharp
**dichotomy**, `triangle_count_dichotomy`:

> **Every graph either has cubically many triangles, or is edge-close to
> triangle-free.** There is no middle ground.

A graph can't hover in between — it is either triangle-rich or essentially
triangle-free. This all-or-nothing behavior is exactly the leverage needed for
the final act.

---

## Part IV: Roth's Theorem — Order in the Integers

We arrive at the destination. Forget graphs for a moment and think about plain
numbers. A **3-term arithmetic progression** is three numbers equally spaced,
like $4, 7, 10$ or $a, b, c$ with $a + c = 2b$. A set of integers is
"3AP-free" if it contains no such triple.

How large can a 3AP-free subset of $\{0, 1, \dots, N-1\}$ be? You can certainly
get a positive fraction — clever constructions reach about $N / e^{c\sqrt{\log N}}$.
But can you keep a *constant* fraction, say $1\%$ of all the numbers, while
avoiding every arithmetic progression, no matter how large $N$ grows?

Klaus Roth proved in 1953 that you cannot. This won him the Fields Medal.

**Roth's theorem.** *The largest 3AP-free subset of $\{0, 1, \dots, N-1\}$ has
size $o(N)$ — a vanishing fraction as $N \to \infty$.*

Writing $r_3(N)$ for that largest size, we package the density statement as
`rothNumberNat_density_tendsto_zero`:
$$ \frac{r_3(N)}{N} \longrightarrow 0. $$

How does triangle-counting prove a fact about numbers? Through a gorgeous
translation. Given a set $A$ of integers, one builds a graph whose triangles
correspond exactly to 3-term arithmetic progressions in $A$. A 3AP-free set
yields a graph with very few triangles. The removal lemma then says you can
delete few edges to kill all triangles — but a counting argument shows the
"trivial" progressions (where $a=b=c$) already form too many triangles to
remove cheaply. Contradiction, unless $A$ was small to begin with. The dichotomy
of Part III becomes the dichotomy between a set being sparse and a set being
arithmetically structured.

The truly useful form of Roth's theorem is qualitative, and we capture it as
`exists_threeAP_of_freq_dense`:

> **Any set of natural numbers whose density stays bounded below by a positive
> constant — infinitely often — must contain a genuine 3-term arithmetic
> progression.**

In other words, you cannot maintain even $1\%$ density forever without
accidentally creating three equally-spaced numbers. Structure is inescapable.
The proof is a clean contradiction: density "frequently $\ge c$" collides with
Roth's "eventually $\le c/2$" upper bound at a single value of $N$, and the two
inequalities cannot both hold.

---

## The Grand Arc

Step back and admire the architecture. Four classical theorems, each a gem in
its own right, assemble into a single tower:

- **Turán and Mantel** establish the prototype: forbidding a small pattern caps
  the number of edges, and the cap is achieved by a beautifully symmetric
  construction.
- **Kruskal–Katona** reveals that counting cliques is really counting subsets,
  and that small structure (triangles) forces large structure (edges) through
  the geometry of shadows.
- **The triangle removal lemma**, powered by Szemerédi regularity, delivers the
  all-or-nothing dichotomy: triangle-rich or triangle-free, nothing in between.
- **Roth's theorem** cashes everything in, proving that the integers themselves
  cannot escape arithmetic structure once they are dense enough.

The unifying message echoes across every level: **largeness forces structure.**
Whether you are counting friendships in a network, subsets of a set, triangles
in a graph, or numbers in a progression, the same law applies. Cross a threshold
of abundance and order appears, unbidden and unavoidable.

This is the quiet wonder of extremal combinatorics. It does not merely describe
what *can* happen; it pins down, exactly and provably, what *must*. And in a
mathematical world that can feel boundlessly free, there is something deeply
reassuring about discovering its hard, unbreakable limits.
