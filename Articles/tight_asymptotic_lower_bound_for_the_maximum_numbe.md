# Crowns, Cycles, and the Arithmetic of "Maybe": How Many Ways Can a Ranking Tangle Itself?

Imagine you are trying to merge a stack of unfinished rankings into one master list. A panel of movie critics has each given you a partial verdict — "this film beat that one," "this album outranks that one" — but nobody finished their ballot, and the ballots disagree. Your job is to find one global ranking that respects everything everyone said. Sometimes you can. Sometimes the verdicts loop back on themselves in a way that makes a single consistent ranking impossible, and you have to ask a deeper question: *how* tangled is this knot of opinions?

This is not a parlor game. It is the mathematics of **partial orders**, the structures that underlie scheduling, database query optimization, version control, preference aggregation, and the theory of "dimension" that measures how many simple rankings you must overlay to reconstruct a complicated one. And at the heart of that theory sits a stubborn, beautiful object called a **crown** — a ring of "I can't decide" relationships that refuses to be flattened.

This article is about a single sharp question concerning crowns, and a clean answer with a complete, machine-checked proof. The question is deceptively simple to state: *in a partial order whose "width" is fixed at some number $w$, how many of these irreducible tangles — called strict alternating cycles — can you cram in if the order has $n$ elements?* The answer turns out to be a precise power law. The number grows like $n^{2w}$, no faster and no slower. We will see why the ceiling is $n^{2w}$, and we will build, by hand, a family of orders that reaches it.

## The cast of characters

Let us fix vocabulary, because the whole story lives or dies on three words.

A **partial order** is a set together with a relation "$\le$" that is reflexive ($x \le x$), antisymmetric (if $x \le y$ and $y \le x$ then $x = y$), and transitive (if $x \le y$ and $y \le z$ then $x \le z$). The key word is *partial*: unlike the ordinary number line, two elements can be **incomparable** — neither $x \le y$ nor $y \le x$ holds. Incomparability is the mathematical encoding of "I genuinely can't tell you which is bigger." Write $x \parallel y$ when $x$ and $y$ are incomparable.

The **width** of a partial order is the size of the largest **antichain** — the biggest collection of elements that are *pairwise* incomparable. Width measures how much genuine indecision the order can hold at once. A total ranking (a single straight line) has width $1$: no two distinct elements are incomparable. The more parallel, unrankable stuff you pile up, the larger the width.

Finally, the star of the show. A **strict alternating cycle** of length $k$ is a cyclic list of pairs
$$(x_0, y_0), (x_1, y_1), \dots, (x_{k-1}, y_{k-1})$$
arranged so that each "lower" element sits below the *next* "upper" element and *no other* upper element:
$$x_i \le y_j \quad\text{if and only if}\quad j = i+1 \pmod{k},$$
while every pair $(x_i, y_i)$ is itself incomparable. Picture a circle of dominoes where each one can knock over only its clockwise neighbor, never itself, never anyone else. That single, rigid "if and only if" is the engine of the whole subject. It is exactly the obstruction that prevents you from collapsing the order into fewer linear rankings — it is the reason dimension exists.

## The smallest tangle: a crown

The cleanest example is the **standard crown** $S_w$. Take $2w$ elements split into a "lower deck" $a_0, a_1, \dots, a_{w-1}$ and an "upper deck" $b_0, b_1, \dots, b_{w-1}$. Decree that each lower element sits below every upper element *except* the one directly facing it; equivalently, in the cyclic version we use here, $a_i \le b_{i+1}$ wraps around the ring. Each $a_i$ is incomparable to its own partner $b_i$, and those $w$ incomparable pairs chase each other around in one unbreakable loop.

The crown $S_w$ is the canonical width-$w$, dimension-$w$ poset — the textbook witness that some orders genuinely need $w$ separate rankings to reconstruct. It is to dimension theory what the cycle graph is to graph coloring: the irreducible obstruction you keep bumping into.

But $S_w$ contains exactly *one* alternating cycle. We want many. The question is how to inflate a crown so that it sprouts an explosion of alternating cycles **without** changing its width. That tension — multiply the cycles, hold the width — is the entire difficulty.

## Why the ceiling is $n^{2w}$

Before building anything, let us understand the speed limit. An alternating cycle of length $k$ is *pinned down* by its $2k$ vertices: once you know the list $x_0, y_0, \dots, x_{k-1}, y_{k-1}$, the cycle is determined. So the number of cycles of length $k$ in an $n$-element order is at most the number of ways to choose $2k$ vertices, which is on the order of $n^{2k}$.

Now width enters. Each pair $(x_i, y_i)$ in a strict alternating cycle is an incomparable pair, and one can show these $k$ "lower" vertices form an antichain. In a width-$w$ order, no antichain exceeds $w$ elements, so a strict alternating cycle can have length at most $k \le w$. The longest — and therefore most numerous — cycles top out at length $w$, contributing at most about $n^{2w}$ configurations. That is the classical **upper bound**: a width-$w$ order on $n$ points has $O(n^{2w})$ strict alternating cycles. Nothing can beat $n^{2w}$.

The hard, open direction — the one this work settles — is the **lower bound**: that some order actually *achieves* this rate, that the $O(n^{2w})$ ceiling is no illusion but is touched from below by a real construction. Tightness, not the easy ceiling, is the prize.

## The blown-up crown

Here is the construction. Start with the crown $S_w$ and replace **every one of its $2w$ vertices by a chain of $m$ clones** — a little vertical stack of $m$ totally ordered copies. We call the result the **blown-up crown** $\mathrm{Crown}(w,m)$.

Concretely, an element of $\mathrm{Crown}(w,m)$ is a triple: a **column** $i \in \{0, 1, \dots, w-1\}$ telling you which of the $w$ crown-positions you sit in; a **side** (lower "$a$" or upper "$b$"); and a **clone index** $j \in \{0, 1, \dots, m-1\}$ telling you where in your little stack you live. The order has two rules:

1. **Inside a stack** (same side, same column), the clone indices order normally: clone $j$ sits below clone $j'$ exactly when $j \le j'$. Each stack is an honest chain of $m$ elements.
2. **Across the crown** (the cross relations), *every* lower clone $a(i, \cdot)$ sits below *every* upper clone $b(i+1, \cdot)$ in the next column, cyclically. This faithfully copies the crown's $a_i \le b_{i+1}$ pattern, now thickened into a full chain-to-chain relationship.

Crucially the cross relations are **one-directional** — only $a \to b$, never $b \to a$. That orientation is what makes antisymmetry work and keeps the structure a genuine partial order, not a tangle that collapses.

The total element count is immediate and verified: there are $w$ columns, $2$ sides, and $m$ clones, so
$$\#\,\mathrm{Crown}(w,m) = 2 \cdot w \cdot m.$$
(In the formalization this is the theorem `Crown.card`.) Setting $n = 2wm$ is our dictionary between the construction's parameter $m$ and the order's size $n$.

## Counting the cycles

Now watch the cycles bloom. To build one strict alternating cycle, walk once around the $w$ columns. In each column $t$, you get to make two **independent** choices: which clone $u(t)$ to use as the lower vertex on the $a$-side, and which clone $v(t)$ to use as the upper vertex on the $b$-side. So a full choice is a pair of functions
$$u, v : \{0,1,\dots,w-1\} \to \{0,1,\dots,m-1\},$$
and the resulting cyclic family of pairs is
$$\mathrm{cyc}(u,v)(t) = \big(\,a(t, u(t)),\; b(t, v(t))\,\big).$$

Two facts, both fully proved, finish the job.

**Every such family really is a strict alternating cycle** (the theorem `cyc_strict`). The cross relations guarantee that $a(t, u(t)) \le b(s, v(s))$ holds precisely when $s = t+1$ — exactly the "knock over only your clockwise neighbor" condition — and each facing pair $a(t,u(t)), b(t,v(t))$ is genuinely incomparable. The single biconditional is satisfied on the nose.

**Distinct choices give distinct cycles** (the theorem `cyc_injective`). If two choice-pairs $(u,v)$ and $(u',v')$ produce the same cyclic family, then reading off the clone indices forces $u = u'$ and $v = v'$. The map from choices to cycles is injective.

Counting choices: there are $m^w$ possibilities for $u$ and $m^w$ for $v$, hence
$$\#\{\text{strict alternating cycles}\} \;\ge\; m^{w} \cdot m^{w} \;=\; m^{2w}.$$
(This is the lower-bound theorem `crown_strictAltCycle_card_lower`.)

## Closing the loop: from $m$ to $n$

We now have an order on $n = 2wm$ points carrying at least $m^{2w}$ strict alternating cycles. Translating back, $m = n/(2w)$, so the cycle count is at least
$$\left(\frac{n}{2w}\right)^{2w} \;=\; \frac{1}{(2w)^{2w}}\; n^{2w} \;=\; c_w \, n^{2w},$$
with the positive constant $c_w = (2w)^{-2w}$. This matches the $O(n^{2w})$ ceiling, so the true growth rate is
$$\boxed{\;\Theta\!\left(n^{2w}\right)\;}$$
— the conjectured tightness, now confirmed.

## The one fact everything hangs on: the width really is $w$

It would all be worthless if blowing up the crown secretly inflated its width. After all, we now have $2w$ separate chains; a careless reading suggests $2w$ pairwise-incomparable elements and hence width $2w$. The whole construction is admissible only if the width stays *exactly* $w$. It does, and the reason is a single elegant trick.

Define a **column-folding** map that sends each element to a single number: a $b$-element in column $i$ folds to $i$, and an $a$-element in column $i$ folds to $i+1$. (In the formalization this is `Crown.fold`.) Look at what happens to a conflicting cross pair: the lower vertex $a(i)$ and the upper vertex $b(i+1)$ it sits below both fold to the *same* value $i+1$. The folding deliberately collapses each comparable cross pair to one point.

The payoff: **the fold is injective on any antichain.** If two distinct elements of an antichain folded to the same value, chasing the definitions shows they would have to be comparable — contradicting antichain-ness. Since the fold lands in a set of only $w$ possible values (the $w$ columns), any antichain has at most $w$ elements. So the width is at most $w$. And it is at least $w$, because the $w$ lower vertices $a(0,0), a(1,0), \dots, a(w-1,0)$ are pairwise incomparable — a witnessing antichain of size exactly $w$. (Both halves are recorded in `Crown.hasWidth`.) The width is pinned to $w$ exactly, and the construction is legitimate.

That fold is the soul of the argument. The naive count of chains is $2w$, but the cross relations $a(i) \le b(i+1)$ are precisely the "extra" comparabilities that the fold detects and discounts, halving the apparent width back down to the true $w$.

## Why this matters

Strict alternating cycles are not a curiosity. They are the combinatorial fuel of **poset dimension theory** — the measure, due to Dushnik, Miller, and developed extensively by Trotter, of how many linear extensions you must intersect to reconstruct a partial order. Crowns are the standard examples that force dimension up, and understanding how densely cycles can pack tells you how robustly an order resists being flattened into rankings. The same alternating-cycle machinery surfaces in scheduling (where incomparable tasks are those with no forced precedence), in the analysis of preference and voting structures (where cycles are the formal cousins of Condorcet paradoxes), and in the extremal combinatorics of "Turán-type" problems, where one asks for the maximum count of a substructure subject to a global constraint — here, the constraint being fixed width.

What makes the result satisfying is its shape. Extremal problems usually leave a frustrating gap between the easy upper bound and the achievable lower bound. Here the two ends meet: the counting ceiling of $n^{2w}$ is reached by an explicit, hand-built, fully verified object. The blown-up crown is not an existence proof conjured from probabilistic dust; it is a concrete machine you can draw, and every clone you add multiplies the cycle count by the right amount.

There is even an aesthetic moral. The whole edifice balances on the difference between $2w$ and $w$ — between the number of chains you see and the width you actually have. A single fold, collapsing each $a$ onto the $b$ it dominates, accounts for that factor of two and certifies the construction. The hardest direction of an extremal theorem can rest on a trick you could explain on a napkin.

## What comes next

Three natural questions remain, each within reach. First, the **sharp constant**: our $c_w = (2w)^{-2w}$ comes from splitting $n$ into $2w$ equal chains, and an averaging argument (AM–GM on the chain lengths) suggests that equal splitting is genuinely optimal — pinning down the exact leading coefficient of $n^{2w}$. Second, a **length spectrum**: the same construction, restricted to $k$ of the $w$ columns, should show that cycles of each length $k \le w$ appear $\Theta(n^{2k})$ times, with none of length exceeding $w$ (Dilworth's theorem forbids them). Third, **dimension transfer**: the blown-up crown ought to have order dimension exactly $w$ for every clone-length $m$, because fattening a vertex into a chain is a structure-preserving operation that neither raises nor lowers the dimension of the underlying crown.

But the core is settled. Ask how tangled a fixed-width ranking can become, and the answer is a clean power law — $\Theta(n^{2w})$ — touched from above by a counting argument and from below by a crown wearing $m$ coats.
