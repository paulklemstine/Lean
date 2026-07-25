# The Greedy Sequence That Finds a Hidden Rhythm

## A small change with a large consequence

Begin with the number $1$. At every stage, look for the smallest whole number larger than the current term that cannot be written as the sum of two terms already chosen at two different positions. Append that number and repeat.

This sounds like the recipe for a disorderly sequence. Each new term changes the collection of forbidden sums, so the next choice appears to depend on an ever-growing memory of the past. Yet the process quickly settles into one of the simplest rhythms imaginable:

$$
1,2,4,7,10,13,16,19,\ldots
$$

After two exceptional steps, the sequence advances by exactly $3$ forever. Its complete formula is

$$
a_0=1,\qquad a_1=2,\qquad a_n=3n-2\quad(n\ge 2).
$$

The surprise is not merely that a pattern appears. The pattern is forced. No matter how far the construction is continued, the greedy rule has only this trajectory. The reason combines two complementary ideas: a local obstruction created by the first two terms, and a global protection supplied by arithmetic modulo $3$.

This is a miniature example of a broad phenomenon in discrete mathematics. A rule defined by avoidance may look computational and history-dependent, but a good invariant can expose a rigid geometric skeleton underneath it. Similar ideas occur in scheduling, coding theory, additive combinatorics, and the design of collision-free resources.

## What “distinct” really changes

The word *different* in the rule is decisive. A forbidden sum must use values from two distinct earlier indices. Thus $1+2$ is allowed as a forbidden representation once both terms exist, but $2+2$ is not available unless the value $2$ occurs at two different positions. In this sequence it occurs only once.

Let us calculate the opening moves carefully.

* From $1$, there is no pair of distinct earlier positions at all. The smallest larger number is therefore $2$.
* With $1$ and $2$ available, the number $3$ is forbidden because $3=1+2$.
* The next candidate is $4$. Although $4=2+2$, that expression reuses the same position, so it does not count. Hence $4$ is chosen.
* Above $4$, the candidates $5$ and $6$ are forbidden: $5=1+4$ and $6=2+4$. The number $7$ survives.

The same last maneuver seems ready to repeat. Once the current term is $x$, the initial values $1$ and $2$ immediately forbid $x+1$ and $x+2$. If $x+3$ is always safe, the sequence must march by threes. The whole problem is therefore concentrated in one question: why can $x+3$ never be a sum of two distinct earlier terms?

## Three colors on the number line

Color every nonnegative integer according to its remainder after division by $3$. There are three colors, represented by the residue classes $0$, $1$, and $2$ modulo $3$.

Apart from the exceptional term $2$, every value in our proposed sequence has color $1$:

$$
1,4,7,10,13,\ldots \equiv 1 \pmod 3.
$$

Now inspect the possible sums of two distinct earlier terms.

If both summands come from the stable color-$1$ class, their sum has color $2$, because

$$
1+1\equiv 2\pmod 3.
$$

If one summand is the exceptional value $2$ and the other has color $1$, their sum has color $0$, because

$$
2+1\equiv 0\pmod 3.
$$

Could the exceptional term be paired with itself? No: there is only one index carrying the value $2$, and the rule insists on distinct indices. Consequently every permitted pair sum has color $0$ or $2$, never color $1$.

That is the global certificate of safety. Every proposed stable successor $4,7,10,\ldots$ has color $1$, so none can be a forbidden distinct-index pair sum.

The local and global arguments now lock together. If the current stable term is $x$, then $x+1=1+x$ and $x+2=2+x$ are forbidden using two distinct positions. Meanwhile $x+3$ has remainder $1$ modulo $3$ and is safe. Therefore the least admissible successor is exactly $x+3$.

The seeds $1$ and $2$ act like two sentries blocking the nearest candidates; modular arithmetic opens the third gate.

## The classification theorem

We can state the central result without referring to an experiment.

**Distinct-Summand Classification Theorem.** Let $(a_n)_{n\ge 0}$ be a sequence of natural numbers with $a_0=1$. Suppose that, for every $n$, the term $a_{n+1}$ is the least natural number larger than $a_n$ that is not equal to $a_i+a_j$ for any indices $0\le i<j\le n$. Then

$$
a_0=1,\qquad a_1=2,\qquad a_n=3n-2\quad(n\ge 2).
$$

**Why the theorem holds.** The first two transitions are checked directly: the absence of an initial pair gives $a_1=2$, and the sole pair sum $1+2=3$ forces $a_2=4$. From then on, assume the sequence has followed the displayed formula so far. Every earlier term except $2$ is congruent to $1$ modulo $3$. Distinct pair sums are therefore congruent to either $2$ or $0$ modulo $3$, so the proposed next term, congruent to $1$, is admissible. The two smaller numbers above the current term are the current term plus $1$ and plus $2$, and they are forbidden by pairing the current term with the initial terms $1$ and $2$. Thus the proposed term is the least admissible choice. Induction proves the formula at every index.

There is also a conceptual uniqueness argument. A finite history determines its set of forbidden pair sums. For any fixed history, two numbers cannot both be “the least admissible successor” unless they are equal. Since the explicit sequence obeys the rule at every step, every sequence obeying the same rule must agree with it term by term.

Notice what was *not* assumed. We did not begin by demanding that the terms increase by $3$, occupy a residue class, or even exhibit a periodic increment. Strict growth is built into the successor rule, while the arithmetic progression emerges as a theorem.

## A transient followed by perfect regularity

The sequence has increments

$$
1,2,3,3,3,\ldots
$$

More precisely, for every $n\ge 0$,

$$
a_{n+3}=a_{n+2}+3.
$$

The opening term $1$ has no pair-sum constraints behind it. The transition to $2$ is therefore unusually free. The next transition feels the first available pair, and only after $4$ appears do the two seeds cooperate to block both intervening candidates. This is a finite transient: a short startup phase before stable dynamics take over.

Transients appear throughout applied mathematics. A control system may wobble before reaching steady operation; a numerical iteration may pass through irregular values before entering a regular regime; a communication protocol may spend several rounds establishing synchronization. Here the transient is not noise. It is exactly describable and structurally necessary.

## The exact set of values

The formula gives more than a way to predict the next term. It identifies the entire range.

**Range Theorem.** The values attained by the sequence are exactly

$$
\{2\}\cup\{3k+1:k\ge 0\}.
$$

In words, the sequence contains the exceptional value $2$ together with every nonnegative integer congruent to $1$ modulo $3$. It misses every positive multiple of $3$, and it misses every integer congruent to $2$ modulo $3$ except $2$ itself.

The proof runs in both directions. The explicit formula shows that every sequence value lies in the displayed set. Conversely, $2$ occurs at index $1$; the value $1=3\cdot0+1$ occurs at index $0$; and for $k\ge1$, the number $3k+1$ occurs at index $k+1$.

This description also reveals the long-run scale. Among each three consecutive large integers, exactly one belongs to the stable range. The isolated value $2$ does not affect asymptotic proportions, so the sequence occupies one third of the natural numbers in the intuitive density sense. An exact finite counting formula can be read directly from the range: among $0,1,\ldots,N$, the number of attained values is

$$
\left(\left\lfloor\frac{N-1}{3}\right\rfloor+1\right)+\mathbf{1}_{N\ge2}
$$

for $N\ge1$, where $\mathbf{1}_{N\ge2}$ equals $1$ when $N\ge2$ and $0$ otherwise. Dividing by $N+1$ tends to $1/3$.

## Why this tiny theorem travels

The proof uses a pattern that extends far beyond this sequence.

First, identify a few early objects that create *local minimality*. Here $1$ and $2$ forbid the two nearest numbers above the current term. Second, find an invariant that gives *global admissibility*. Here a three-coloring prevents any distinct pair sum from entering the protected residue class. Together these certificates prove that the greedy choice is neither too small nor too large: all closer candidates fail, and the claimed candidate succeeds.

In a scheduling interpretation, imagine assigning increasing time slots while avoiding a slot equal to the combined times of two distinct earlier jobs. The first two assignments block nearby collisions, while a modular class provides a protected channel. In coding theory, residue classes can separate desired symbols from sums that model interference. In additive combinatorics, the sequence is a sparse set shaped by restrictions on its sumset. The details vary, but the architecture—local blockers plus a global coloring—remains recognizable.

Greedy algorithms are often criticized as shortsighted: they make the best immediate choice without planning ahead. This example turns that weakness into a source of rigidity. Once the right modular structure appears, short-sightedness has no freedom left. The smallest legal move is always the move that preserves the pattern.

## What comes next

The classification opens several natural directions. One can ask for the exact shape and cardinality of all pair sums generated by a finite prefix. One can forbid sums of $r$ distinct earlier terms instead of two and search for new protected residue classes. One can replace the initial seed $1$ by another positive integer and study which startups settle into arithmetic progressions. Or one can relax greediness, allowing a choice within a fixed error of the least admissible value, and ask whether the modular skeleton survives.

The most immediate analytic question is to turn the visible one-third proportion into a general framework for natural density. The most immediate combinatorial question is whether higher-order distinct-summand rules retain the same division of labor: finitely many seeds enforcing local minimality and a coloring enforcing global safety.

A sequence generated by all its previous pairwise interactions might have been chaotic. Instead it becomes a ruler marked every three units, with one exceptional notch near the origin. The lesson is simple and powerful: when an avoidance rule remembers the entire past, the right congruence can make that memory almost disappear.
