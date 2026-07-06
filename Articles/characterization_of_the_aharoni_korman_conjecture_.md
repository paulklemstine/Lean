# Chains, Antichains, and the Fishbone: A Cautionary Tale About Infinity

## A puzzle about order

Imagine a vast filing system in which some documents supersede others. A
patent might build on an earlier patent; a court ruling might overturn a
previous one. Whenever document $a$ is superseded by document $b$, we write
$a \le b$. Some pairs of documents are directly comparable in this way; many
are not, because they concern entirely unrelated matters. This is the everyday
picture of a **partially ordered set**, or **poset**: a collection of objects
with a notion of "comes before," where not every two objects need be
comparable.

Two shapes stand out inside any poset. A **chain** is a stack of documents
totally ordered by supersession: $a_1 \le a_2 \le a_3 \le \cdots$, a clean line
of descent. An **antichain** is the opposite: a family of documents no two of
which are comparable, a set of mutually independent items. Chains capture
*progress along a single thread*; antichains capture *simultaneous,
incomparable alternatives*.

A natural tension links the two. If you have a very wide poset — many pairwise
incomparable elements — you have a large antichain. If you have a very tall
poset — a long line of supersessions — you have a long chain. A recurring theme
of order theory is that you cannot escape both at once: forbidding one shape
forces structure on the other.

This article is about a beautiful conjecture that tries to make that intuition
exact, about a clean characterization someone proposed to settle it, and about
a small, stubborn counterexample that shows the characterization — as stated —
cannot be right. Along the way we will meet a surprisingly deep fact about
"one-directional" infinity.

## The fishbone conjecture

Call a poset **FAC** — for *finite antichain condition* — if it has no infinite
antichain: every family of pairwise-incomparable elements is finite. FAC posets
are "not too wide." They can still be enormously tall and intricate, but they
cannot spread out infinitely in the sideways direction.

Now the key players. A **maximal antichain** is an antichain that cannot be
enlarged: you cannot add a new element while keeping everything pairwise
incomparable. Maximal antichains are the natural "cross-sections" of a poset —
think of them as complete snapshots, each capturing one incomparable alternative
from every thread running through the order.

The **Aharoni–Korman conjecture**, affectionately known as the **fishbone
conjecture**, makes a striking claim:

> **Fishbone Conjecture.** Every FAC poset contains a single chain that meets
> every maximal antichain.

Picture the chain as the *spine* of a fish and the maximal antichains as the
*ribs*: the conjecture says one spine can be threaded through so that it touches
every rib. It is a statement of remarkable economy — one chain, chosen once,
simultaneously intersecting *all* of the poset's cross-sections. The conjecture
is easy to state, plainly true for finite posets, and genuinely hard in
general. It has resisted a full solution for decades and remains one of the
tantalizing open problems in the combinatorics of infinite orders.

## A proposed shortcut

Faced with a hard conjecture, mathematicians look for a **characterization**: a
concrete structural feature whose presence or absence decides the question. If
we could point to some identifiable "obstruction" $X$ and prove

> a countable FAC poset satisfies the fishbone property **if and only if** it
> contains no copy of $X$,

then the conjecture would reduce to understanding $X$. The proposal studied here
names a specific candidate obstruction. To state it we need two more ideas.

First, **co-wellfoundedness**. A chain is **well-founded** if it has no infinite
strictly *descending* sequence $a_1 > a_2 > a_3 > \cdots$ — every nonempty
subset has a least element, like the natural numbers $0 < 1 < 2 < \cdots$. It is
**co-wellfounded** if it has no infinite strictly *ascending* sequence
$a_1 < a_2 < a_3 < \cdots$. The prototypical co-wellfounded order is the
*reversed* natural numbers $\cdots < 3 < 2 < 1 < 0$, denoted $\mathbb{N}^{\mathrm{op}}$: you can
descend forever, but you cannot climb forever. Co-wellfoundedness is a
fundamentally *one-directional* form of infinity.

Second, a **direct sum** (or lexicographic sum) of chains. Given an indexed
family of chains $\{C_i\}$, laid out along an index order, we can weld them end
to end: put every element of an earlier block below every element of a later
block, and keep each block's internal order. The result, written
$\sum_{i} C_i$, is again a single chain. A **countable direct sum of infinite
co-wellfounded posets** is what you get by welding countably many infinite,
one-directional chains together in a line.

Finally, a **saturated chain** inside a poset is a chain that is *maximal as a
chain*: you cannot insert any new element between, above, or below its members
while keeping it a chain. Saturated chains are the poset's complete threads,
with no gaps left to fill.

The proposed characterization then reads:

> **Proposed characterization.** A countable FAC poset satisfies the fishbone
> property if and only if it does **not** contain a saturated chain $D$ such
> that either $D$ or its reverse is a countable direct sum of infinite
> co-wellfounded posets.

The candidate obstruction is exactly such a saturated chain. The "if and only
if" splits into two implications: the **obstruction direction** (if you contain
the obstruction, you fail the fishbone property) and the **reverse direction**
(if you avoid it, you succeed).

## The atom of one-directional infinity

Before testing the characterization, we established a foundational fact that
turns out to be the workhorse of the whole subject — and a genuinely pretty
result in its own right.

> **Descent Theorem.** Every *infinite* co-wellfounded chain contains an
> infinite strictly descending sequence — a faithful copy of the reversed
> natural numbers $\mathbb{N}^{\mathrm{op}}$.

In words: one-directional infinity, once it is genuinely infinite, always
points the *same* way. A co-wellfounded chain forbids infinite ascent by
definition; the theorem says that if it is infinite it must contain infinite
descent. There is no third option, no infinite co-wellfounded chain that somehow
stays finite in both directions.

The proof is a small gem built on the classical **Erdős–Szekeres** philosophy
that every infinite sequence hides an infinite monotone subsequence. Pick any
injection $f : \mathbb{N} \to \alpha$ listing infinitely many distinct elements
of the chain. Ramsey-type reasoning extracts a subsequence that is either
strictly increasing or strictly decreasing. An infinite strictly *increasing*
subsequence is exactly the infinite ascent that co-wellfoundedness forbids — so
that case is impossible. What remains is an infinite strictly *decreasing*
subsequence: precisely the copy of $\mathbb{N}^{\mathrm{op}}$ we sought.

From this single atom, a clean corollary drops out:

> **Finiteness Theorem.** A chain that is *both* well-founded and co-wellfounded
> is finite.

Indeed, an infinite such chain would, by the Descent Theorem, contain an
infinite strictly descending sequence — contradicting well-foundedness. So
"bounded in both directions of infinity" collapses to "finite." A linear order
is finite exactly when it forbids both infinite ascent and infinite descent.

These two facts explain *why* co-wellfounded blocks are the natural building
material for the proposed obstruction: each infinite block secretly carries a
$\mathbb{N}^{\mathrm{op}}$, a reservoir of infinite descent that a welding
construction can exploit.

## Where wide posets come from

A second foundational observation pins down the boundary of the FAC condition.

> **Width Threshold.** A countably infinite *disjoint* sum of nonempty posets —
> where elements from different summands are always incomparable — is never
> FAC.

The proof is almost a picture. Choose one element from each of the infinitely
many summands. Because elements in different summands are mutually incomparable,
this **transversal** is an infinite antichain. So the moment you place infinitely
many nonempty pieces side by side with no comparisons between them, an infinite
antichain appears for free. This is the canonical way width is manufactured, and
it marks the exact threshold beyond which the finite antichain condition must
fail.

## The counterexample: a chain that is its own obstruction

Now to the twist. We tested the obstruction direction — *if a countable FAC
poset contains the obstruction, it should fail the fishbone property* — and found
that it is **false**.

The refutation is disarmingly simple, and it hinges on a fact about chains that
is easy to overlook. First, **every chain is FAC**. In a totally ordered set any
two elements are comparable, so an antichain can contain at most one element;
there are certainly no infinite antichains. Second, **every nonempty chain
satisfies the fishbone property**. Take the whole chain as your spine. Any
maximal antichain in a linear order is a single point (you cannot have two
incomparable elements), and that point already lies on the spine. So the entire
chain meets every maximal antichain trivially. Chains are the *easy* case of the
fishbone conjecture — they always win.

But here is the catch: **a chain can itself be the proposed obstruction.**
Consider

$$ D \;=\; \sum_{k \in \mathbb{N}} \mathbb{N}^{\mathrm{op}}, $$

the direct sum of countably many copies of the reversed natural numbers, welded
end to end along $\mathbb{N}$. Concretely, its elements are pairs $(k, n)$ with
$k, n \in \mathbb{N}$, ordered so that a smaller block index $k$ comes first,
and within a block the order is reversed:

$$ (k, n) \le (k', n') \iff k < k' \ \text{ or } \ (k = k' \ \text{and}\ n \ge n'). $$

Each block $\mathbb{N}^{\mathrm{op}}$ is infinite and co-wellfounded, and there are
countably many of them. So $D$ is, by construction, a countable direct sum of
infinite co-wellfounded posets. As the (necessarily saturated) chain inside
itself, $D$ is therefore a bona fide instance of the proposed obstruction.

And yet $D$ is a chain. So it is countable, it is FAC, it is an AK obstruction —
**and it satisfies the fishbone property**. All four hold at once. The
obstruction direction claims the obstruction forces *failure*; here the
obstruction sits inside a poset that *succeeds*. The implication cannot be true.

The moral is instructive. The obstruction was designed to describe how a chain
can be "bad" — welded from one-directional pieces so that ascending sequences
sneak across the welding seams and spoil the order's structure. That intuition
is real and valuable. But it describes a property of the *chain as an ambient
poset situated among antichains*, not of the chain in isolation. When the chain
is the *entire* poset, there are no nontrivial antichains to obstruct, and the
fishbone property becomes automatic. The proposed statement conflated two
different roles a chain can play.

## What survives, and what remains open

Refuting one direction of a proposed characterization is not a defeat — it is
progress. It tells us precisely how to repair the statement: the obstruction
must be constrained to genuinely interact with the poset's antichains, rather
than being allowed to constitute the whole order. The **reverse direction** —
that a countable FAC poset which *avoids* the obstruction *does* satisfy the
fishbone property — is untouched by the counterexample and remains a live,
attractive form of the still-open conjecture.

The structural atoms we isolated point the way forward. Because every infinite
co-wellfounded chain carries a hidden $\mathbb{N}^{\mathrm{op}}$, one can imagine welding
countably many such chains along a second axis to manufacture, at the seams, the
very ascending sequences co-wellfoundedness forbids inside any single block —
turning a family of one-directional orders into a genuinely two-directional
obstruction. Because disjoint sums of infinitely many pieces always create
infinite antichains, the finite antichain condition has a sharp threshold whose
positive side (finitely many pieces, with widths that simply add) is ripe for a
clean additivity theorem. And because the finiteness theorem already tames the
linear case with a two-way monotone dichotomy, adding a third "incomparable"
colour promises a Ramsey-style chain-or-antichain dichotomy for *all* posets.

The fishbone conjecture endures. But the terrain around it is now better mapped:
we know one tempting shortcut is blocked, we know exactly why, and we hold in
hand the small, sharp facts about one-directional infinity from which the next
attempt can be built.
