# Counting Sign Changes: How a Line of Colored Dots Explains Why Games Have Solutions

## A staircase you cannot avoid

Imagine walking along a row of stepping stones numbered $0, 1, 2, \dots, n$. Each stone is painted one of two colors: black or white. You start on a black stone and you finish on a white one. Somewhere along the way, whether you like it or not, you must step from a black stone directly onto a white one. You cannot pass from black to white without crossing that boundary at least once.

This is almost embarrassingly obvious. And yet, this humble observation—dressed up properly—is the seed of one of the most celebrated results in twentieth-century mathematics: the fact that *every* game, no matter how complicated, has a stable strategy that no player can profitably abandon. The bridge from "a line of colored dots must change color" to "economic competition has equilibria" is the story of this article.

The classical version of the stepping-stone fact is a special case of **Sperner's Lemma**, a combinatorial gem from 1928. Sperner's Lemma is the discrete twin of **Brouwer's Fixed-Point Theorem**, which says that any continuous way of stirring a cup of coffee leaves at least one molecule exactly where it started. Brouwer's theorem, in turn, is the engine behind **Nash's Theorem**: John Nash's 1950 proof that finite games always possess equilibria—the work that reshaped economics and won a Nobel Prize.

What we present here is a sharpening of the first link in that chain. We do not merely prove that a color change *exists*. We count the changes *exactly*, keeping track of their direction, and show that the answer is forced by nothing more than the colors of the two endpoints.

## From "there is a crossing" to "here is the exact count"

Let us set the scene precisely. A **coloring** is a function $c$ that assigns to each stone $i$ a Boolean value: $c(i)$ is either `false` (call it $0$) or `true` (call it $1$). An edge is the little segment joining stone $i$ to stone $i+1$. We call an edge **fully colored** if its two endpoints disagree—one is $0$ and the other is $1$.

Now comes the crucial refinement. Not all crossings are alike. Some go *up* and some go *down*:

- An **up-edge** is a transition from $0$ to $1$: $c(i) = 0$ and $c(i+1) = 1$.
- A **down-edge** is a transition from $1$ to $0$: $c(i) = 1$ and $c(i+1) = 0$.

Let $U$ be the number of up-edges among the first $n$ steps and $D$ the number of down-edges. The old, coarse version of Sperner's Lemma only tells you something about $U + D$ modulo $2$. Our sharper result tells you about $U - D$ *on the nose*.

> **The Signed Sperner Count.** For any two-coloring $c$ of the stones $0, 1, \dots, n$,
> $$ U - D = c(n) - c(0), $$
> where we read the endpoint colors as the numbers $0$ and $1$.

The proof is a single, beautiful act of cancellation—a **telescoping sum**. Assign to each edge the number $c(i+1) - c(i)$. This is exactly $+1$ on an up-edge, $-1$ on a down-edge, and $0$ on an edge whose endpoints agree. So summing this quantity over every edge gives precisely $U - D$. But the same sum telescopes: consecutive terms cancel in a cascade,
$$ \sum_{i=0}^{n-1} \big(c(i+1) - c(i)\big) = c(n) - c(0), $$
because every interior value is added once and subtracted once. Setting the two evaluations of the same sum equal to each other yields the identity. That is the entire argument.

This little equation is what physicists and topologists would recognize as a **degree**: the net number of times an object winds around, counted with sign. The Signed Sperner Count is the one-dimensional discrete degree of a boundary map, and everything else in the theory falls out of it as effortlessly as the identity itself was proved.

## Everything else is a corollary

The power of finding the *right* exact statement is that all the familiar consequences become one-line deductions.

**The parity law.** Since $U + D$ counts all fully colored edges and $U - D = c(n) - c(0)$, the total number of color changes is odd exactly when the endpoints differ, and even when they match. This recovers the classical parity form of the lemma. (If $c(0) = c(n)$, the difference is $0$, so $U - D$ is even; since $U+D$ and $U-D$ have the same parity, the total is even.)

**Balanced crossings.** If the two endpoints share a color, then $U - D = 0$, so $U = D$: the path goes up exactly as many times as it goes down. Every ascent is eventually undone by a descent, and vice versa. This is a discrete conservation law.

**Existence, with direction.** If you start black ($c(0)=0$) and end white ($c(n)=1$), then $U - D = 1$, which forces $U \geq 1$. There is at least one genuine *up*-crossing—not just some color change, but specifically a step from $0$ to $1$. This is the oriented form of Sperner's existence statement, and it is strictly stronger than merely asserting a crossing exists.

**The discrete intermediate value theorem.** Replace colors by the sign of a function. Suppose $f$ is any integer-valued function on the stones with $f(0) \le 0$ and $f(n) > 0$. Color stone $i$ white if $f(i) > 0$ and black otherwise. Then the guaranteed up-crossing is a place where $f$ passes from non-positive to positive: an index $i$ with $f(i) \le 0$ and $f(i+1) > 0$. This is the combinatorial heart of the classical Intermediate Value Theorem, stripped of all its analytic machinery. The mirror-image statement handles downward crossings.

## The leap to fixed points

Here is where the row of dots begins to talk about games. Consider a function $g$ that maps the stones $\{0, 1, \dots, n\}$ back into themselves—a *self-map* of the discrete interval. Suppose it nudges the left endpoint strictly upward, $g(0) > 0$, and keeps the right endpoint from overshooting, $g(n) \le n$. Apply the discrete intermediate value theorem to the "displacement" $f(i) = g(i) - i$, which measures how far $g$ pushes each stone. At the left end the displacement is positive; at the right end it is non-positive. So somewhere the displacement must cross zero:

> **Discrete Brouwer fixed point.** Under the conditions above, there is an index $i < n$ where $i < g(i)$ but $g(i+1) \le i+1$: the map $g$ crosses the diagonal. Near this index, $g$ has an approximate fixed point—a stone that $g$ leaves essentially in place.

This is the combinatorial skeleton of Brouwer's Fixed-Point Theorem. A continuous self-map of an interval, sampled on a fine enough grid of stones, must satisfy exactly these endpoint conditions, and the crossing our theorem locates converges, as the grid gets finer, to a true fixed point where $g(x) = x$. The stirred coffee has its stationary molecule; the discrete crossing found it.

## Why games must have equilibria

Nash's Theorem concerns *strategies*. In a finite game each player picks probabilities over their available moves—a *mixed strategy*. A **Nash equilibrium** is a profile of strategies where no player can do better by unilaterally changing their own, given what everyone else is doing. The astonishing claim is that such a self-consistent standoff always exists.

Nash's proof works like this. Bundle all the players' strategies into one big point in a high-dimensional space of probability distributions. Define a "best-response" adjustment that shifts each player's strategy toward their most profitable option. A fixed point of this adjustment—a profile that maps to itself—is precisely a state where nobody wants to move: a Nash equilibrium. The existence of that fixed point is delivered by Brouwer's theorem (in Nash's refined version, its set-valued cousin due to Kakutani). And Brouwer's theorem, as we have just seen, is the continuous shadow of a purely combinatorial fact about crossings.

So the chain is complete:
$$ \text{a line of colored dots must change color} \;\Longrightarrow\; \text{Sperner's Lemma} \;\Longrightarrow\; \text{Brouwer} \;\Longrightarrow\; \text{Nash}. $$

To make the destination concrete, consider the simplest games. In **Matching Pennies**, two players each secretly show heads or tails; one wins if they match, the other if they differ. There is no stable pure choice—whatever you pick, your opponent wants to react, and then you want to re-react. The only equilibrium is for each player to randomize, flipping a fair coin, choosing heads and tails with probability $1/2$ each. In **Rock–Paper–Scissors**, the same logic forces each player to the uniform strategy: each of the three throws with probability $1/3$.

These are not accidents. They are instances of a general principle: whenever every row of one player's payoff table and every column of the other's sums to the same constant, playing all options with equal probability is an equilibrium. For a symmetric $n$-move cyclic game—where move $k$ beats some moves and loses to others in a perfectly balanced rotation—the uniform strategy over all $n$ moves is always in equilibrium. Matching Pennies is the case $n = 2$; Rock–Paper–Scissors is $n = 3$; and the pattern continues forever. Each of these equilibria is, at bottom, a fixed point—and each fixed point traces back to the impossibility of walking from a black stone to a white one without ever changing color.

## The moral of the story

Mathematics prizes the moment when a difficult, continuous, infinite-dimensional truth is revealed to rest on a finite, discrete, almost childish observation. The existence of economic equilibria—a statement about the behavior of rational agents in arbitrarily complex competitions—reduces, layer by layer, to counting the sign changes along a row of two-colored dots.

By upgrading that count from a statement about parity to an *exact* signed identity, we expose the mechanism in its purest form. The number $U - D$ is a discrete degree; it is conserved, it is computable, and it is forced by the endpoints alone. From this one telescoping equation flow intermediate value theorems, fixed-point theorems, and ultimately the guarantee that every game can be played to a standstill. Sometimes the deepest bridges are built from the simplest stones.
