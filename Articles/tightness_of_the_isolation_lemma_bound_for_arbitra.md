# The Exact Price of a Unique Winner

## A tie-breaking spell

Imagine you are running an election with a strange rule. There are several
candidates, and instead of counting ballots, you assign each candidate a secret
random score. The winner is whoever has the *lowest* score. There is only one
catch: if two candidates tie for the lowest score, the whole election is void and
must be re-run. You would like to know — before you even start — how often your
random scoring produces a clean, unambiguous winner.

This little puzzle is a miniature of one of the most useful ideas in modern
theoretical computer science: the **Isolation Lemma**. Discovered in 1987 by
Ketan Mulmuley, Umesh Vazirani, and Vijay Vazirani, it is the mathematical
engine behind a surprising fact — that a computer facing a bewildering forest of
equally-good solutions can, just by sprinkling random weights, almost always
force a *single* solution to stand out. That single, isolated winner can then be
found and manipulated cleanly. The lemma quietly powers parallel algorithms for
matching problems, randomized methods that turn hard search problems into
tractable ones, and cornerstone results in complexity theory.

The lemma is usually stated as a *probabilistic guarantee*: random weights
isolate a unique winner with high probability. But behind every probability
lurks a **count** — an exact integer answer to the question "in how many ways can
this happen?" This article is about pinning that integer down exactly, and
discovering that a famous lower bound on it is not a loose estimate but the
literal truth, achieved on the nose by the simplest possible structure.

## The setup, precisely

Let us make the election picture exact. We have $n$ "vertices" — think of them as
the candidates, or the elements of a set — labelled $1, 2, \dots, n$. To each
vertex $i$ we assign a **weight** $w_i$ drawn from the set of allowed values
$\{0, 1, 2, \dots, d-1\}$. So a full assignment is a vector

$$w = (w_1, w_2, \dots, w_n) \in \{0,1,\dots,d-1\}^n,$$

and there are exactly $d^n$ of these in total.

We call an assignment $w$ **isolating** when a *single* vertex attains the strict
minimum weight — that is, there is exactly one index $i$ whose weight is smaller
than every other vertex's weight:

$$\text{there is a unique } i \text{ such that } w_i < w_j \text{ for all } j \neq i.$$

If two or more vertices tie for the lowest value, the assignment is *not*
isolating. This is precisely the "clean winner" condition from the election.

The general Isolation Lemma lives in a richer world of **hypergraphs**, where the
competitors are not single vertices but *subsets* of vertices, and the weight of
a subset is the sum of its members' weights (possibly shifted by a fixed offset
attached to each subset). A hypergraph is called **inclusion-free**, or a
*Sperner family*, when no competing subset is contained inside another — a
natural condition ensuring the competitors are genuinely incomparable. In 2018,
Vance Faber and David Harris proved a beautiful sharp lower bound: for *every*
inclusion-free hypergraph on $n$ vertices, no matter how its subsets are chosen,
the number of isolating assignments is always at least

$$n \cdot \sum_{j=0}^{d-1} j^{\,n-1}.$$

That formula looks mysterious. Where does it come from, and is it ever actually
achieved? The heart of this article is a clean, complete answer.

## The simplest arena: singletons

The friendliest hypergraph is the one whose competitors are the individual
vertices themselves — the **singleton hypergraph** $\{\{1\}, \{2\}, \dots,
\{n\}\}$. Each competitor is a single vertex, its weight is simply that vertex's
own weight, and "a unique competitor wins" collapses to exactly our clean-winner
condition: a unique vertex has the strict minimum weight. This is the election in
its purest form.

For this arena we can compute the number of isolating assignments *exactly*, and
the answer is startling in its precision:

> **Exact Count Theorem.** For $n$ vertices each weighted from
> $\{0, 1, \dots, d-1\}$, the number of assignments in which a single vertex
> attains the strict minimum is *exactly*
> $$n \cdot \sum_{j=0}^{d-1} j^{\,n-1}.$$

This is the Faber–Harris lower bound — but here it is not a bound at all. It is
an equality. The simplest inclusion-free hypergraph achieves the universal lower
bound term for term, proving that the bound cannot be improved: it is
**globally tight**.

## Why the formula is true

The proof is a small gem of combinatorial bookkeeping, and it explains every
symbol in the formula.

**Step 1 — Split by the winner.** In an isolating assignment there is exactly one
winning vertex. So we can sort all isolating assignments into $n$ piles, one for
each possible winner $i$. Because the winner is *unique*, no assignment lands in
two piles — the piles are disjoint, and the total is the sum of their sizes. By
symmetry, every pile has the same size, so the grand total is $n$ times the size
of a single pile. That is the leading factor of $n$.

**Step 2 — Split by the winning value.** Fix the winner $i$ and ask: how many
assignments make $i$ the strict minimum? Group them by the value $m$ that the
winner takes, where $m$ ranges over $0, 1, \dots, d-1$. If the winner's value is
$m$, then the winner is fixed, and every *other* vertex must take a value
strictly greater than $m$. The number of values strictly greater than $m$ in
$\{0, \dots, d-1\}$ is $d - 1 - m$. Since there are $n-1$ other vertices, each
free to independently pick any of those larger values, the count for this group
is

$$(d - 1 - m)^{\,n-1}.$$

**Step 3 — Add up and re-index.** Summing over all possible winning values gives
the size of one pile:

$$\sum_{m=0}^{d-1} (d-1-m)^{\,n-1}.$$

As $m$ runs from $0$ up to $d-1$, the quantity $k = d-1-m$ runs from $d-1$ back
down to $0$ — it hits exactly the same set of numbers. So the sum is identical to

$$\sum_{k=0}^{d-1} k^{\,n-1},$$

which is precisely the sum in the theorem. Multiplying by the $n$ piles from Step
1 yields the exact count $n \cdot \sum_{j=0}^{d-1} j^{\,n-1}$. $\blacksquare$

Every factor now has meaning: the $n$ counts the choice of unique winner; the sum
counts the winner's value; and the exponent $n-1$ counts the free choices of the
$n-1$ losers, each of whom must climb strictly above the winner.

## A sanity check you can do by hand

Take $n = 3$ candidates and $d = 4$ possible scores $\{0,1,2,3\}$. The formula
predicts

$$3 \cdot \left(0^2 + 1^2 + 2^2 + 3^2\right) = 3 \cdot (0 + 1 + 4 + 9) = 3 \cdot 14 = 42$$

clean-winner assignments out of the $4^3 = 64$ total. A brute-force enumeration
over all $64$ score vectors confirms it: exactly $42$ have a unique lowest score.
Running the same check across a whole grid of values of $n$ and $d$ — for
instance producing the sequence $3, 15, 42, 90, \dots$ as $d$ grows with $n=3$ —
matches the formula every single time.

## The boundaries tell a story too

A good formula behaves gracefully at its edges, and this one does.

- **No candidates ($n=0$).** There is no vertex to win, so there are no isolating
  assignments — and indeed the leading factor $n = 0$ makes the formula vanish.
- **A single candidate ($n=1$).** Every assignment trivially has a unique minimum
  (the lone vertex always wins), so all $d$ assignments are isolating. The formula
  gives $1 \cdot \sum_{j=0}^{d-1} j^0 = d$, exactly right.
- **A single possible score ($d=1$), several candidates.** Everyone is forced to
  the same value, so there is never a strict winner; the count is $0$. The formula
  agrees, confirming the count is genuine and never vacuously inflated.

These edge cases matter: they certify that the theorem counts something real, not
an artifact of a convenient definition.

## Why this is more than a curiosity

The Isolation Lemma is a workhorse. It underlies the fastest parallel algorithms
for finding perfect matchings, it drives the celebrated reduction showing that
detecting *whether* a solution exists is essentially as hard as detecting a
*unique* one, and it appears throughout the theory of randomized computation.
Every one of those applications rests on the guarantee that random weights isolate
a unique winner *often enough*. Knowing the **exact** number of isolating
assignments — not just a bound — sharpens our understanding of exactly how much
randomness is needed and how efficient these methods can be.

The Exact Count Theorem does something subtle but important: it shows that the
Faber–Harris lower bound is the best possible statement of its kind. You cannot
prove a larger universal lower bound, because the singleton hypergraph sits
exactly on the line. The bound is not merely "at least this much" — for the right
structure, it is "exactly this much".

## The road ahead

Settling the simplest hypergraph exactly opens a tantalizing horizon. The natural
conjecture is one of **universal tightness**: for *every* inclusion-free
hypergraph, one can choose the fixed offsets on its competing subsets so cleverly
that the isolating count drops to exactly the same magic value
$n \cdot \sum_{j<d} j^{n-1}$. The intuition is that a well-chosen offset
"flattens" all the internal comparisons between overlapping subsets, so that
isolation is again governed by a single controlling vertex per assignment —
reproducing the singleton count.

Sharper still is the belief that the offsets achieving this minimum form a
well-behaved, positively-sized region of possibilities, and that *dropping* the
inclusion-free requirement — allowing one competitor to sit inside another —
strictly *increases* the count for large $d$, because a containment permanently
ties two competitors' fates and destroys the independence the extremal count
relies on. Each of these is a crisp, testable statement, and each is made precise
precisely because the singleton case is now nailed down exactly.

From a whimsical tie-breaking election to a sharp, universal counting law: the
lesson is that behind every probabilistic promise of a "unique winner" sits an
exact integer, and sometimes — beautifully — that integer is exactly the bound
everyone had hoped could be reached.
