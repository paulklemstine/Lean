# The Arithmetic of Wholeness: How to Measure When a System Is More Than Its Parts

## A number for togetherness

Imagine a flock of starlings wheeling across an evening sky. Each bird follows
its neighbors, and out of thousands of tiny local decisions something larger
appears — a shape that banks and folds as if it were a single creature. Now ask
a deceptively simple question: *how much* of that flock is genuinely one thing,
and how much is just a crowd of independent birds that happen to be near each
other?

This is not only a poetic question. It sits at the heart of neuroscience, where
researchers want to know when a tangle of firing neurons becomes an experience;
it appears in the study of complex networks, where we ask whether a system is
truly interconnected or merely adjacent; and it shows up in machine learning,
where "how integrated is this representation?" is a question about whether a
model has learned parts or a whole.

The grand theory that tries to answer this is called **Integrated Information
Theory**, and its central quantity is a single Greek letter: $\Phi$ ("phi").
Loosely, $\Phi$ is meant to measure *irreducibility* — how much a system would
lose if you cut it in two. A pile of sand has $\Phi$ near zero: split it and you
just get two smaller piles. A richly interconnected network has large $\Phi$:
any cut you make severs something essential.

The trouble is that the full definition of $\Phi$ is notoriously slippery and
hard to compute. This article is about a clean, honest, *fully computable*
cousin of $\Phi$ — a combinatorial surrogate that keeps the spirit of the idea
while being simple enough to reason about with pencil, paper, and, when the
systems get big, a computer. And it comes with a small, surprising theorem: for
the most tightly-bound systems, the answer to "how integrated are you?" is
governed by one of the oldest facts in combinatorics.

## From probabilities to a picture of "who moves with whom"

Start with a system of switches. Each switch — call them variables
$1, 2, \dots, n$ — is either **on** or **off**. Over time (or over many trials)
the system visits many configurations, and we summarize this by a probability
distribution: for each pattern of on/off values, how likely is it?

From this distribution we can read off two basic numbers for any pair of
switches $i$ and $j$:

- the **marginal** $m_i$: the probability that switch $i$ is on;
- the **joint** $J_{ij}$: the probability that switches $i$ and $j$ are *both*
  on.

If the two switches were completely independent — knowing one tells you nothing
about the other — then the probability of both being on would just be the
product of their individual chances: $m_i \cdot m_j$. So the comparison between
$J_{ij}$ and $m_i \cdot m_j$ is exactly a measure of *togetherness*. We say two
switches are **co-active** when

$$m_i \cdot m_j \le J_{ij},$$

that is, when they turn on together *at least as often as chance would
predict*. Co-activity is the atom of our whole story: it is the pairwise
signature of "these two move together."

Collect all the co-active pairs and you get a **co-activation graph**: draw the
$n$ switches as dots, and connect two dots whenever they are co-active. This
graph is a portrait of the system's internal cohesion. A sparse graph means a
loose confederation of nearly-independent parts; a dense graph means a system
laced together with correlations.

## Measuring integration by cutting

Now we make the leap from "who moves with whom" to "how integrated is the
whole." The philosophy of integration is about *cuts*: a system is integrated to
the extent that no matter how you split it into two nonempty teams, plenty of
the togetherness spans the divide.

So fix a way of splitting the switches into two disjoint, nonempty groups $A$
and $B$. Count the co-active pairs that *cross* the cut — one endpoint in $A$,
the other in $B$. Call this the **cross-score** of the split:

$$\mathrm{cross}(A, B) = \#\{\, (i,j) : i \in A,\ j \in B,\ i \text{ and } j \text{ co-active} \,\}.$$

A single cut, though, can be misleadingly generous or stingy. To capture
irreducibility we take the *best* cut — the one that keeps the most connections
intact — and define the surrogate integrated information as

$$\Phi = \max_{A, B}\ \mathrm{cross}(A, B),$$

the maximum cross-score over all ways of partitioning the switches into two
nonempty teams. Intuitively, $\Phi$ asks: *even at the most favorable place to
cut, how much cohesion still has to be severed?* If the answer is large, the
system is deeply woven together; if it is zero, the system falls apart cleanly.

Because everything here is finite counting, $\Phi$ is an honest natural number.
There is no infinity, no delicate limit, no ambiguity. You can compute it by
examining the finitely many ways to split the system. This is what makes the
surrogate so appealing: it is **decidable and computable**, an $O(2^n)$
enumeration over the ways of cutting an $n$-switch system.

## The punchline: perfect integration is old arithmetic

Here is where something beautiful happens. Consider the most tightly bound
system imaginable — one in which *every* pair of distinct switches is co-active.
Call this the **complete co-activation**. It models a system with nothing left
independent: total mutual entanglement.

For such a system, the cross-score of a split into groups $A$ and $B$ is easy to
compute. Every switch in $A$ is co-active with every switch in $B$, so every one
of the $|A| \cdot |B|$ cross-pairs counts:

$$\mathrm{cross}(A, B) = |A| \cdot |B|.$$

This is a clean fact worth stating on its own — call it the **Cross-Score
Lemma**: for a completely co-active system, the cohesion crossing any cut is
exactly the product of the two team sizes.

To find $\Phi$ we now maximize this product over all ways of writing
$n = |A| + |B|$ with both parts nonempty. And *that* is a classical problem with
a classical answer. The product $|A| \cdot |B|$ of two numbers with a fixed sum
is largest when the two numbers are as equal as possible — the same principle
that says a rectangle of fixed perimeter has the most area when it is a square.
Splitting $n$ as evenly as you can gives

$$\Phi = \left\lfloor \frac{n^2}{4} \right\rfloor.$$

We call this the **Complete Integration Formula**: the surrogate integrated
information of a maximally-integrated system on $n$ switches is exactly
$\lfloor n^2/4 \rfloor$. For $n = 2$ it is $1$; for $n = 3$ it is $2$; for
$n = 4$ it is $4$; for $n = 5$ it is $6$. The same expression, $\lfloor
n^2/4\rfloor$, is famous in graph theory as the largest number of edges a
triangle-free graph on $n$ vertices can have (Mantel's theorem) and as the size
of the biggest "complete bipartite" graph — the densest possible collection of
crossing connections. That the ceiling of a system's integration should be this
exact quantity is a small, satisfying bridge between a question about wholeness
and a cornerstone of combinatorics.

## Two sanity checks you can feel

Numbers earn trust by behaving the way intuition demands. The surrogate passes
two basic tests.

**Perfect correlation is maximal integration.** Take three switches that are
locked together — they are always all-on or all-off, each pattern half the time,
and nothing in between. Every pair turns on together exactly as often as either
one turns on, which comfortably clears the co-activity bar, so all three pairs
are co-active. This is precisely the complete co-activation on three switches,
and its integration is the balanced-split value $\lfloor 3^2/4 \rfloor = 2$. The
formula and the concrete example agree.

**Independence is zero integration.** Now take two switches that flip like two
fair coins, with no relationship whatsoever. Then $J_{ij} = m_i \cdot m_j$
exactly — they are co-active only in the borderline, correlation-free sense — and
if we ask for *strictly* better-than-chance togetherness, no pair qualifies. The
co-activation graph has no edges, every cut severs nothing, and $\Phi = 0$. A
system of independent parts is, correctly, not integrated at all.

## Growth: adding a bystander can't shrink the whole

One more property makes the surrogate trustworthy as a measure of integration.
Suppose you take a system and bolt on a brand-new switch that is co-active with
nothing — a pure bystander, correlated with no existing part. What should happen
to $\Phi$?

It should not *decrease*. Adding an inert component might contribute nothing, but
it cannot make an already-integrated system less integrated: the old cuts are
still available, and the best of them still severs exactly as much cohesion as
before. The surrogate obeys exactly this **monotonicity under independent
extension**: enlarging the system by an uncorrelated variable never lowers
$\Phi$. This is the discrete echo of a principle we expect of any honest measure
of wholeness — you cannot destroy the integration a system already has simply by
placing something unrelated beside it.

## Why a computable surrogate matters

The full $\Phi$ of Integrated Information Theory is a beautiful idea trapped
behind a wall of intractability: computing it exactly is astronomically
expensive, and even defining it precisely has kept researchers busy for years.
The surrogate described here trades some of that ambition for something rare in
this corner of science — *certainty*. Every claim above is a finite,
checkable statement about counting co-active pairs across cuts.

That certainty buys three things. First, **worked examples**: we can point to a
correlated triple and say, without hedging, that its integration is $2$, and to
an independent pair and say it is $0$. Second, **structural theorems**: the
Complete Integration Formula and the monotonicity property are not empirical
observations but proven facts, true for every system of the relevant kind.
Third, a **computational recipe**: give the model any system as a table of
configuration probabilities — even messy, real-world ones expressed as exact
fractions — and it will build the co-activation graph and return $\Phi$ as a
definite number.

There is a broader lesson here, one that reaches past neuroscience. Big,
qualitative ideas — consciousness, complexity, wholeness — often feel too
vaporous to pin down. But frequently, hidden inside the fog, there is a small
combinatorial skeleton: a graph, a cut, a product of two numbers. Find that
skeleton and you can prove things. The surrogate integrated information is one
such skeleton, and its spine turns out to be the humble, ancient fact that the
most balanced split of a whole is the one that binds it most tightly:
$\lfloor n^2/4 \rfloor$. Sometimes the deepest questions about togetherness come
down to arithmetic.
