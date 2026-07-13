# When Randomness Almost Never Ties: The Hidden Arithmetic of Breaking Ties

## A puzzle about picking a winner

Imagine you are refereeing a race between $n$ runners, but instead of timing them
you hand each runner a slip of paper with a number written on it, drawn at random
from the whole numbers $0, 1, 2, \dots, d-1$. The runner with the *smallest*
number wins. There is only one catch: if two runners tie for the smallest number,
the race is void — nobody wins.

How often does the race produce a clean winner? At first glance the answer feels
delicate. If everyone draws from a tiny range — say the numbers $0$ and $1$ only —
ties are everywhere. With two runners and two possible numbers there are four
equally likely outcomes: $(0,0)$, $(0,1)$, $(1,0)$, $(1,1)$. Two of these are
ties. So the race is decisive only half the time.

But something remarkable happens as we widen the range of numbers. Give the
runners more room — let them draw from $\{0, 1, \dots, d-1\}$ for larger and
larger $d$ — and the ties evaporate. Not slowly, not conditionally, but with
mathematical certainty: in the limit, *almost every* draw produces a unique
winner. This article is about why, and about the surprisingly clean piece of
arithmetic that governs it.

## The Isolation Lemma, in plain sight

This little race is a miniature of one of the most useful ideas in modern
algorithm design: the **Isolation Lemma**. In its general form, the lemma says
that if you have a large collection of competing "structures" — matchings in a
graph, satisfying assignments of a formula, paths through a network — and you
assign small random weights to the underlying elements, then with good
probability exactly *one* structure achieves the minimum total weight. Randomness
breaks ties for you. This single idea powers randomized parallel algorithms, and
it sits at the heart of celebrated results connecting the difficulty of counting
solutions to the difficulty of finding just one.

The version we study here is the cleanest possible case. The "structures" are the
individual runners themselves — in the language of combinatorics, the
**singleton edges** of a hypergraph. A weight assignment is called **isolating**
when one runner is a *strict* minimum: a single vertex whose number is smaller
than everyone else's. The question "how often is a random draw isolating?" becomes
a precise counting problem, and the answer turns out to be beautiful.

## Counting the clean races exactly

Let us count, exactly, how many of the $d^n$ possible number-slips-to-runners
assignments produce a unique winner. Here $n$ is the number of runners and $d$ is
the size of the number range, so a single assignment is a function
$w : \{1, \dots, n\} \to \{0, 1, \dots, d-1\}$, and there are $d^n$ of them in
total.

Fix a particular runner, say runner $i$, and ask: in how many assignments is
runner $i$ the strict winner? Suppose runner $i$ draws the number $m$. To make
$i$ the *unique* smallest, every one of the other $n-1$ runners must draw a
number strictly larger than $m$. The count of numbers strictly larger than $m$ in
the range $\{0, \dots, d-1\}$ is exactly $d-1-m$. So the other runners can be
filled in $(d-1-m)^{\,n-1}$ ways. Summing over all possible values $m$ that
runner $i$ might hold:

$$
\#\{\text{assignments where } i \text{ wins strictly}\}
= \sum_{m=0}^{d-1} (d-1-m)^{\,n-1}
= \sum_{j=0}^{d-1} j^{\,n-1}.
$$

The last equality is just a relabeling ($j = d-1-m$ runs over the same numbers).
Notice the answer does not depend on *which* runner we picked — by symmetry every
runner wins strictly equally often.

Now here is the crucial observation: two *different* runners can never both be the
strict minimum of the same assignment. A strict winner is unique by definition.
So the sets "runner $1$ wins," "runner $2$ wins," …, "runner $n$ wins" are
pairwise disjoint, and their union is exactly the set of decisive races. Adding up
the $n$ equal contributions gives the exact count.

> **The Exact Isolation Count.** Among the $d^n$ ways to assign numbers from
> $\{0, \dots, d-1\}$ to $n$ runners, the number of assignments producing a
> unique strict minimum is exactly
> $$
> n \cdot \sum_{j=0}^{d-1} j^{\,n-1}.
> $$

This clean formula is not an approximation. It is exact for every $n$ and every
$d$. And it matches, term for term, the classical lower bound for how often the
Isolation Lemma succeeds — the singleton case is as tight as the bound allows.

Let us sanity-check the opening puzzle: $n = 2$ runners, $d = 2$ numbers. The
formula gives $2 \cdot (0^1 + 1^1) = 2 \cdot 1 = 2$ decisive assignments out of
$2^2 = 4$. Exactly the two we found by hand: $(0,1)$ and $(1,0)$. Half the time.

## From counting to calculus: the ties vanish

Now widen the number range. The fraction of decisive races is

$$
R(n, d) = \frac{n \cdot \sum_{j=0}^{d-1} j^{\,n-1}}{d^n}.
$$

To understand how this behaves as $d$ grows, recall a fact that connects sums to
areas. The sum $\sum_{j=0}^{d-1} j^{\,n-1}$ is a stack of rectangles under the
curve $y = x^{\,n-1}$, and its value is close to the area under that curve up to
$d$, namely $\int_0^d x^{\,n-1}\,dx = d^n / n$. Multiplying by $n$ and dividing by
$d^n$ suggests the fraction should march toward $1$. Ties should disappear.

To make this airtight without any hand-waving about areas, one can trap the sum
between two explicit walls using nothing more than algebra. The key is a discrete
cousin of the Mean Value Theorem. For any real $x \ge 0$ and any whole number
$k \ge 0$,

$$
(k+1)\,x^{k} \;\le\; (x+1)^{k+1} - x^{k+1} \;\le\; (k+1)\,(x+1)^{k}.
$$

In words: the jump in the function $t \mapsto t^{k+1}$ as $t$ steps from $x$ to
$x+1$ is squeezed between $k+1$ times the slope at the left end and $k+1$ times
the slope at the right end. Both inequalities follow by a short induction on $k$
(equivalently, by reading off the binomial expansion of $(x+1)^{k+1}$). These are
the honest, discrete stand-ins for the smooth statement that the derivative of
$t^{k+1}$ is $(k+1)t^k$.

Now sum these per-step inequalities as $x$ runs through $0, 1, \dots, d-1$. The
middle terms *telescope* — each $(x+1)^{k+1}$ cancels against the next
$x^{k+1}$ — collapsing the whole middle column to just $d^{k+1}$. Writing
$k = n-1$, the two walls become

$$
d^{\,n} - n\,d^{\,n-1}
\;\le\;
n \cdot \sum_{j=0}^{d-1} j^{\,n-1}
\;\le\;
d^{\,n}.
$$

Divide through by $d^n$. The right wall says the fraction of decisive races never
exceeds $1$ — which of course it cannot, since it is a fraction of all races. The
left wall says

$$
1 - \frac{n}{d} \;\le\; R(n, d) \;\le\; 1.
$$

As the number range $d$ grows with the number of runners $n$ held fixed, the term
$n/d$ shrinks to zero, and the fraction of decisive races is squeezed
inexorably to $1$.

> **The Vanishing-Ties Theorem.** For every fixed number of runners $n \ge 1$,
> the fraction of number assignments that produce a unique strict winner tends to
> $1$ as the number range $d \to \infty$:
> $$
> \frac{n \cdot \sum_{j=0}^{d-1} j^{\,n-1}}{d^{\,n}} \longrightarrow 1.
> $$
> Equivalently, if the $n$ weights are drawn independently and uniformly from
> $\{0, \dots, d-1\}$, the probability that some runner is a strict minimum tends
> to $1$. Ties become asymptotically negligible.

The bound $1 - n/d$ is not just a proof device; it is a usable guarantee. With
$n = 5$ runners and a range of $d = 1000$ numbers, at least $99.5\%$ of all draws
are decisive. Widen to a million numbers and the fraction of ties drops below one
in two hundred thousand.

## Why the two extremes tell the whole story

There is a pleasing symmetry lurking here. We built our count around the
*smallest* number winning. But by the same reasoning applied to the *largest*
number — a mirror reflection that swaps "minimum" for "maximum" — the
**co-singleton** structure (where a winner is a runner who is strictly largest)
attains the very same bound. The extremal cases of the Isolation Lemma bound come
in a matched pair: the singletons and their complements. Both are perfectly
tie-averse in the large-range limit, and both hit the classical bound exactly with
no offset needed.

This matched pair also marks the boundary of what is true. One might hope that
*every* tie-free family of structures (every "antichain," in the technical sense)
meets the Isolation bound exactly for a suitable choice of tie-breaking offsets.
It does not. A family consisting of a single all-encompassing edge makes *every*
assignment isolating — the count is the full $d^n$, strictly above the bound, for
every possible offset. Freedom to shift the weights cannot rescue a family that
over-counts. So the clean formula is a genuine feature of the singleton and
co-singleton structures, not a universal law.

## The bridge

What makes this story worth telling is not any single piece but the bridge it
builds. On one bank sits a purely *combinatorial* fact — a finite, exact count of
grids of numbers, $n \cdot \sum_{j<d} j^{n-1}$. On the other bank sits a
statement of *analysis* — a limit, a density, a probability approaching
certainty. The span connecting them is elementary and self-contained: a discrete
Mean Value Theorem, a telescoping sum, and a squeeze. No heavy machinery, no
appeals to authority — just the observation that a sum of powers is trapped
between two towers that both point at the same sky.

The next time a coin flip or a random draw is asked to break a tie, remember the
runners: give randomness enough room to work in, and ties don't just become
unlikely. They become, in the only sense that matters in the limit, impossible.
