# Gluing Graphs Along a Clique: What Survives, What Breaks, and Exactly Why

## A tale of two halves

Suppose someone hands you a complicated network — a road map, a circuit, a molecule, a dependency graph — and tells you a comforting secret: it is really *two* smaller networks that have been welded together along a small shared piece. Can you understand the whole thing by understanding the pieces?

This is the oldest dream in combinatorics: **divide, conquer, and reassemble**. It works spectacularly well for some questions and fails catastrophically for others, and the difference between the two is subtle enough that folklore has repeatedly gotten it wrong.

This article is about a particularly clean version of the dream. The weld is a **clique** — a set of vertices in which *every* pair is joined by an edge. Gluing two graphs along a shared clique is called a **clique sum**, and it is one of the most important constructions in structural graph theory. Chordal graphs are exactly the graphs you can build by repeatedly clique-summing complete graphs. The Robertson–Seymour graph minor structure theorem describes minor-closed families as clique sums of almost-embeddable pieces. Tree decompositions, treewidth, junction trees in probabilistic inference, nested dissection in sparse linear algebra — they are all, at heart, clique sums.

So: which graph invariants are *compositional* under clique sums? Below, we settle this for the three most-studied invariants — the independence number $\alpha$, the clique number $\omega$, and the chromatic number $\chi$ — and, crucially, we pin down exactly where the naïve answers fail and what the corrected answers look like.

## The setup, precisely

Fix a finite vertex set $V$. A graph $G$ is a **clique sum** of $G_1$ and $G_2$ along the clique $K$ if there are two vertex sets $s, t \subseteq V$ (the two *sides*) such that:

- the sides cover everything: $s \cup t = V$;
- they overlap exactly in the weld: $s \cap t = K$;
- every edge of $G_1$ has both endpoints in $s$, and every edge of $G_2$ has both endpoints in $t$;
- $G$ is the union of the two: $G = G_1 \cup G_2$ (same vertex set, edges of either);
- **and $K$ is a clique in $G_1$ *and* a clique in $G_2$.**

Write $k = |K|$ for the size of the weld. The last bullet is the one that does all the work, and we will spend a good part of this article showing that if you weaken it — merely asking that $K$ be a clique of the *combined* graph $G$, with its edges allowed to be split between the two sides — then everything below collapses.

We will call that weaker notion a **weak clique sum**. The distinction sounds pedantic. It is not. It is the whole story.

## Warm-up: independence meets a clique at most once

Here is the humblest fact in the subject, and also the engine of everything that follows.

> **Lemma (One-Point Trace).** If $A$ is an independent set (no two of its vertices are adjacent) and $K$ is a clique, then $|A \cap K| \le 1$.

*Why:* if $A \cap K$ contained two distinct vertices $a \ne b$, they would be adjacent because $K$ is a clique, and non-adjacent because $A$ is independent. Contradiction.

Call $A \cap K$ the **trace** of $A$ on the weld. The lemma says a trace is either empty or a single vertex — one bit plus one address, no more. That tiny amount of information turns out to be *exactly* what the two halves of a clique sum need to exchange in order to reconstruct the global independence number. Everything else is local.

## The folklore bound, and why it is false

Let $\alpha_1$ be the largest independent set living inside side $s$ (as a subgraph of $G_1$), let $\alpha_2$ be the same for side $t$ and $G_2$, and let $\alpha(G)$ be the independence number of the glued graph.

The folklore reasoning goes: take a maximum independent set $A_1$ on the left and $A_2$ on the right; each meets $K$ at most once; so their union double-counts at most one vertex; hence
$$\alpha(G) \;\ge\; \alpha_1 + \alpha_2 - 1.$$

It is a beautiful argument, and it is **wrong**. The error is invisible until you look for it: $A_1$ and $A_2$ can each meet $K$ in one vertex, but in *different* vertices — and then their union is not independent at all, because those two distinct vertices of $K$ are adjacent. The union isn't merely over-counted; it isn't a legal candidate.

The smallest counterexample is a path on four vertices. Label them $2 - 1 - 0 - 3$. Take
- $s = \{0,1,2\}$ and $G_1$ the path $2 - 1 - 0$;
- $t = \{0,1,3\}$ and $G_2$ the path $1 - 0 - 3$;
- $K = s \cap t = \{0,1\}$, which is genuinely an edge — hence a $2$-clique — in *both* $G_1$ and $G_2$.

Their union is the path $2 - 1 - 0 - 3$. Now count: on the left, $\{0,2\}$ is independent, so $\alpha_1 = 2$. On the right, $\{1,3\}$ is independent, so $\alpha_2 = 2$. But the glued path has independence number $\alpha(G) = 2$ (for instance $\{2,3\}$; you cannot do better on $P_4$). So
$$\alpha_1 + \alpha_2 = 4 \quad\text{but}\quad \alpha(G) + 1 = 3.$$
The folklore bound fails, and it fails for the smallest possible reason: the two witnesses want *different* vertices of the weld, and the weld forbids compromise.

Notice exactly where the two witnesses disagree: the left one uses vertex $0$ of $K$, the right one uses vertex $1$. Each is individually optimal; together they are illegal.

## The correct uniform bound

What *is* true is one unit weaker, and it is sharp:

> **Theorem (Sharp Gluing Bound).** For every clique sum $G$ of $G_1$ and $G_2$ along a clique $K$ with $|K| = k$,
> $$\alpha_1 + \alpha_2 \;\le\; \alpha(G) + \min(k, 2).$$

The proof is a two-line accounting once you have the One-Point Trace lemma. Take maximum independent sets $A_1 \subseteq s$ and $A_2 \subseteq t$ and simply **delete the weld from both**: form $(A_1 \setminus K) \cup (A_2 \setminus K)$. This set is independent in $G$ — any edge of $G$ lies inside one of the two sides, and inside that side the relevant vertices form a subset of an independent set — and the two pieces are disjoint, because anything in both sides is in $K$ and was deleted. Each deletion cost at most one vertex, by the One-Point Trace lemma. Hence the union has size at least $\alpha_1 + \alpha_2 - 2$.

The three regimes of $\min(k,2)$ are all achieved, so nothing here can be improved:

- **$k = 0$** (a disjoint union): the independence numbers add exactly, $\alpha(G) = \alpha_1 + \alpha_2$. Take two isolated vertices glued along nothing.
- **$k = 1$** (a cut vertex): $\alpha_1 + \alpha_2 = \alpha(G) + 1$ is attained — take three isolated vertices, $s = \{0,1\}$, $t = \{0,2\}$, $K = \{0\}$: here $2 + 2 = 3 + 1$. And the bound $\alpha_1+\alpha_2 \le \alpha(G)+1$ is a *theorem* when $k \le 1$, because then the two traces cannot disagree: with at most one candidate vertex, either they are equal, or one of them is empty and can be glued directly.
- **$k \ge 2$**: the four-vertex path above attains $\alpha_1 + \alpha_2 = \alpha(G) + 2$.

So the folklore statement is not merely unproven; it is false precisely from $k = 2$ onward, and the truth is off by exactly one.

## The exact answer: bookkeeping by trace

Losing a unit feels unsatisfying. Can we compute $\alpha(G)$ *exactly* from the two sides? Yes — provided we ask the sides a slightly sharper question.

For a subset $T \subseteq K$, define the **traced independence number** $\alpha_1(T)$ to be the size of the largest independent set $A \subseteq s$ of $G_1$ whose intersection with $K$ is exactly $T$; define $\alpha_2(T)$ symmetrically. By the One-Point Trace lemma, only traces with $|T| \le 1$ are ever realisable, so there are at most $k+1$ relevant values of $T$: the empty set, and each single vertex of $K$.

> **Theorem (Trace Decomposition).** For every clique sum $G$ of $G_1$ and $G_2$ along $K$,
> $$\alpha(G) \;=\; \max_{\substack{T \subseteq K \\ |T| \le 1}} \Big(\alpha_1(T) + \alpha_2(T) - |T|\Big).$$

Both directions are transparent once stated. Given a maximum independent set $A$ of $G$, split it as $A \cap s$ and $A \cap t$; both halves have the *same* trace $T = A \cap K$, their union is $A$, their intersection is exactly $T$, and inclusion–exclusion gives $|A| = |A\cap s| + |A \cap t| - |T| \le \alpha_1(T) + \alpha_2(T) - |T|$. Conversely, given any admissible $T$, pick optimal traced witnesses on each side: because their traces *agree*, their union really is independent in $G$ — this is the gluing lemma that the folklore argument needed and did not have — and inclusion–exclusion again gives the size.

That is the whole theory in one formula, and it explains the $-2$: the term $\alpha_i(T)$ can fall one below $\alpha_i$ (a maximum independent set of a side may be forced to abandon its favourite weld vertex), on each side, and the sharing bonus $|T| \le 1$ recovers at most one of those. The folklore was off by one because it assumed the two sides could always be made to agree for free.

The formula is also an **algorithm**: to compute the independence number of a clique sum, solve at most $k+1$ constrained problems on each side and take a maximum. For graphs assembled by many clique sums along a tree — the bounded-treewidth world — this is the dynamic program that makes the intractable tractable, and its state is astonishingly small: *which single weld vertex, if any, the solution uses*.

## Colours and cliques: perfect compositionality

For the other two classical invariants, the news is unambiguously good.

> **Theorem (Cliques Do Not Cross).** In a clique sum, every clique of $G$ lies entirely inside one side. Consequently $\omega(G) = \max(\omega_1, \omega_2)$.

*Why:* if a clique had a vertex $a \notin t$ and a vertex $b \notin s$, they would have to be adjacent, but every edge of $G$ lives inside $s$ or inside $t$, and this one can do neither.

> **Theorem (Colour Transfer).** If each side of a clique sum can be properly coloured with $n$ colours, then so can $G$. Consequently $\chi(G) = \max(\chi_1, \chi_2)$.

The proof is the prettiest argument in the subject. Take an $n$-colouring $c_1$ of $G_1$ and $c_2$ of $G_2$. Both restrict to *injective* maps on $K$, because $K$ is a clique on each side — this is where the strong hypothesis earns its keep. So $c_1|_K$ and $c_2|_K$ are two injections of the same $k$-element set into the same $n$-element palette; the assignment $c_2(v) \mapsto c_1(v)$ for $v \in K$ is therefore a well-defined bijection between two subsets of the palette of equal size, and can be extended to a **permutation $\sigma$ of all $n$ colours**. Recolour the right-hand side by $\sigma \circ c_2$. This is still a proper colouring of $G_2$ (permuting colours never breaks properness), and now it *agrees with $c_1$ on every vertex of $K$*. Glue: colour each vertex by $c_1$ if it is in $s$, and by $\sigma \circ c_2$ otherwise. Every edge lies in one side, so every edge sees a proper colouring. Done.

Since $G$ contains both sides as subgraphs, $\chi(G) \ge \max(\chi_1,\chi_2)$ trivially, and the equality follows.

There is a hidden bonus. The injectivity observation says something numerical: **if a side of a genuine clique sum is $n$-colourable, then $k \le n$.** The condition "at least as many colours as weld vertices" is not an extra hypothesis one must assume — it is automatic. And it is exactly the condition that fails in the weak world.

Combining the last two theorems: if each side satisfies $\chi = \omega$, then so does the clique sum, since $\chi(G) = \max(\chi_1,\chi_2) = \max(\omega_1,\omega_2) = \omega(G)$. This numerical identity is the engine behind the classical fact that clique sums of perfect graphs are perfect — the construction that makes chordal graphs perfect, and a standard tool in the theory surrounding the Strong Perfect Graph Theorem.

## The boundary: what a *weak* clique sum destroys

Everything above rested on requiring $K$ to be a clique on each side. Suppose we relax to the weak version: $K$ is a clique of the combined graph $G$, but its edges may be *shared out* between $G_1$ and $G_2$, so that neither side sees the whole clique.

Take the triangle on $\{0,1,2\}$. Let $G_1$ consist of the single edge $0 - 1$, and $G_2$ of the two edges $0 - 2$ and $1 - 2$. Their union is the full triangle, and $K = \{0,1,2\}$ is a $3$-clique of it. But $G_1$ is one edge and $G_2$ is a path — each is bipartite, each needs only $n = 2$ colours, while $k = 3$. Here $n < k$, which we just proved impossible for a genuine clique sum.

The consequences are immediate and total:

- **Colouring breaks.** $\chi(G) = 3$, while $\max(\chi_1, \chi_2) = 2$. The colour-permutation trick fails at the first step: $c_1$ is not injective on $K$, so there is no bijection to extend.
- **Independence breaks — and not by one, by everything.** $\alpha_1 = 2$ (the set $\{0,2\}$ is independent in a single edge $0-1$), $\alpha_2 = 2$ (the set $\{0,1\}$ is independent in the path $0-2-1$), while $\alpha(G) = 1$, since the triangle has no two non-adjacent vertices. So $\alpha_1 + \alpha_2 = 4$ exceeds $\alpha(G) + 2 = 3$: even the corrected $-2$ bound is destroyed.

- **Cliques break as well.** The single edge has clique number $2$ and the path has clique number $2$, while the glued triangle has clique number $3$: a clique of the union can straddle the two sides once the sides no longer each realise the weld.

So the "$-2$" and the "$\max$" are not merely hard to prove in the weak setting; they are simply untrue.

So the picture is sharp on both sides. Ask that the weld be a clique *of the sum*, and you get nothing. Ask that it be a clique *of each summand* — equivalently, insist that each side already knows about every weld edge, equivalently, accept that each side must spend $k \le n$ colours on the weld — and you get exact compositionality for $\chi$ and $\omega$, and exact compositionality for $\alpha$ once you refine it by its one-point trace.

## Why this matters beyond graphs

The pattern that emerges deserves a name: a **trace calculus**. Gluing behaves well precisely for invariants that can be *relativised to the trace of a witness on the separator*, and the "loss" incurred by gluing is governed by how much trace information a witness can carry:

| invariant | what a witness can carry across the weld | gluing law |
|---|---|---|
| independence number $\alpha$ | at most one weld vertex | $\alpha(G) = \max_{|T|\le 1}(\alpha_1(T)+\alpha_2(T)-|T|)$ |
| clique number $\omega$ | the whole weld — but cliques never cross | $\omega(G) = \max(\omega_1,\omega_2)$ |
| chromatic number $\chi$ | nothing, after permuting colours | $\chi(G) = \max(\chi_1,\chi_2)$ |

This is the same principle that powers dynamic programming on tree decompositions, message passing in graphical models, and the sparse-matrix elimination trees behind large-scale scientific computing: the separator's *state space* is the price of composition, and here it is as small as it can possibly be — one bit and one address.

It is also a cautionary tale. A plausible-sounding inequality, $\alpha(G) \ge \alpha_1 + \alpha_2 - 1$, has an argument that reads correctly right up to the point where it silently assumes two optimisers can be made to agree. Four vertices are enough to expose it. The fix is not to weaken the claim vaguely, but to identify the exact quantity — the trace — whose disagreement caused the loss, and then to compute with it.

Divide, conquer, reassemble: it works. But the reassembly needs to know what the pieces are allowed to say to each other, and the whole art is in making that vocabulary small and getting it exactly right.
