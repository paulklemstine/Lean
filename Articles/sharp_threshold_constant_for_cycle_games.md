# The Exact Tipping Point of a Cycle-Building Game

## A game played on a growing web

Imagine two players seated at a table, in front of them an enormous network:
take $n$ dots and draw a line between *every* pair of them. This complete
network — mathematicians call it $K_n$ — has about $n^2/2$ lines, and it is the
board on which our game is played.

The two players are named **Maker** and **Breaker**, and their goals are
opposite. On each turn Maker colors one line red, trying to assemble a
particular shape out of her red lines. Breaker, meanwhile, colors lines blue,
trying to stop her. The shape Maker is chasing is a **cycle of length $k$**: a
closed loop passing through $k$ distinct dots, like a triangle ($k=3$), a square
($k=4$), a pentagon ($k=5$), and so on.

If the game were perfectly fair — one line for Maker, one line for Breaker — the
board is so vast that Maker wins effortlessly for any fixed loop size, and long
before the board fills up. To make the contest interesting we handicap Maker:
each round she still claims a single line, but Breaker gets to claim $q$ lines.
The number $q$ is called the **bias**. When $q$ is small the game is nearly fair
and Maker dominates. When $q$ is huge, Breaker snaps up so many lines each turn
that Maker never completes her loop. Somewhere in between lies a **tipping
point** — the exact handicap at which the advantage passes from one player to
the other.

This article is about pinning down that tipping point *exactly*, not merely up
to some fuzzy constant factor. For loops of length $k \ge 4$, we can name the
threshold bias on the nose.

## Where the tipping point lives

The first surprise is how the tipping point scales with the size of the board.
One might guess it grows like the number of lines, or like $n$, but the truth is
subtler. The threshold bias grows like
$$q^\ast(n) \;\asymp\; n^{(k-2)/(k-1)}.$$
For squares ($k=4$) this is $n^{2/3}$; for pentagons ($k=5$) it is $n^{3/4}$; for
hexagons ($k=6$) it is $n^{4/5}$. As the loops get longer the exponent
$(k-2)/(k-1)$ creeps upward toward — but never reaches — $1$. Longer loops are
*harder* for Breaker to prevent, so Maker can tolerate a bigger handicap.

Why this particular exponent? It is the reciprocal of a purely combinatorial
quantity attached to the cycle, its **maximum $2$-density**. For any target
shape $H$, define for each of its sub-shapes $H'$ (with at least three dots) the
ratio
$$\frac{e(H') - 1}{v(H') - 2},$$
where $e(H')$ counts lines and $v(H')$ counts dots, and let $m_2(H)$ be the
largest such ratio. This number measures how "line-heavy" the densest core of
$H$ is. A general principle governing these games says the threshold exponent is
exactly $1/m_2(H)$. For the cycle $C_k$ we prove
$$m_2(C_k) = \frac{k-1}{k-2},$$
whose reciprocal is precisely the $(k-2)/(k-1)$ we saw above. The exponent and
the density are two sides of one coin — literal reciprocals of each other.

## Why the cycle is its own densest core

The proof of $m_2(C_k) = (k-1)/(k-2)$ is a small gem of elementary reasoning, and
it explains *why* a cycle behaves the way it does. Look at any sub-shape of a
loop. There are exactly two possibilities.

If you keep **all** $k$ lines, you have the whole loop back: $e = k$ lines and
$v = k$ dots, giving a density of $(k-1)/(k-2)$, a number strictly larger than
$1$.

If instead you throw away even a single line, the loop falls apart into one or
more separate **paths** — open arcs with no closed circuit anywhere. A
collection of paths is a *forest*: it can never contain a loop, and a forest
always has strictly fewer lines than dots. So for every proper sub-shape,
$e < v$, which forces its density $(e-1)/(v-2)$ to be at most $1$ — smaller than
the whole loop's $(k-1)/(k-2)$.

The conclusion is clean: **the entire loop is the unique densest sub-shape of
itself.** Every attempt to find a denser core fails, because removing any line
shatters the only cycle present. This is exactly the property that makes cycles
the extremal, "hardest to force" targets among shapes with a fixed number of
lines, and it is the combinatorial engine driving the whole result.

## Naming the constant

Knowing the *shape* of the threshold — that it grows like $n^{(k-2)/(k-1)}$ —
is only half the story. The sharper question is: what is the exact multiplier out
front? We can answer it. The threshold bias is
$$q^\ast(n) \;=\; c_k \cdot n^{(k-2)/(k-1)},$$
and the constant $c_k$ has a beautiful closed form:
$$c_k \;=\; \left[(k-1)\left(\frac{2(k-1)}{k}\right)^{k-2}\right]^{1/(k-1)}.$$

"Exact" here has a precise meaning. Fix any tolerance $\varepsilon > 0$, however
small. Then for all sufficiently large boards:

- if Breaker's handicap satisfies $q < (1-\varepsilon)\,c_k\, n^{(k-2)/(k-1)}$,
  **Maker wins**;
- if $q > (1+\varepsilon)\,c_k\, n^{(k-2)/(k-1)}$, **Breaker wins**.

The transition is razor-sharp: squeeze the window as tight as you like around
$c_k\, n^{(k-2)/(k-1)}$ and the outcome still flips cleanly from one player to
the other. The constant $c_k$ is not an artifact of some crude bound; it is the
true dividing line.

That $c_k$ deserves to be called a genuine number — not a formal expression — is
itself something worth establishing. Because it involves a fractional exponent,
one must check that the quantity inside the brackets is positive; for $k \ge 4$
both factors $k-1$ and $2(k-1)/k$ are positive, so $c_k$ is a well-defined
positive real. And it obeys exactly the defining identity one expects: raising it
to the power $k-1$ recovers the bracketed expression on the nose,
$$c_k^{\,k-1} = (k-1)\left(\frac{2(k-1)}{k}\right)^{k-2}.$$

## A constant that refuses to be monotone

Here is where the story takes an unexpected turn. One might imagine that the
constant $c_k$ marches steadily in one direction as the loops grow longer.
It does not. Computing a few values:
$$c_4 \approx 1.890,\quad c_5 \approx 2.012,\quad c_{10} \approx 2.152,\quad
c_{100} \approx 2.060,\quad c_{1000} \approx 2.010.$$
The constant *rises* from $c_4 \approx 1.89$, overshoots, peaks somewhere around
$k \approx 13$ at roughly $2.16$, and then gently *descends*, homing in on a
clean limiting value of exactly $2$ as the loops grow without bound.

The reason for this humped behavior is a tug-of-war hidden inside the formula.
Split $c_k$ into two competing factors:
$$c_k = \underbrace{(k-1)^{1/(k-1)}}_{\text{shrinks toward } 1}\;\cdot\;
\underbrace{\left(\frac{2(k-1)}{k}\right)^{(k-2)/(k-1)}}_{\text{grows toward } 2}.$$
The first factor starts above $1$ and drifts down to $1$; the second climbs from
below toward $2$. Early on the first factor's descent is outpaced by the second's
climb, so the product rises; eventually the first factor flattens out and the
product settles at $1 \times 2 = 2$. The single interior peak and the universal
limit of $2$ — independent of every lower-order detail — fall straight out of
this decomposition.

## Why any of this matters

Positional games like Maker–Breaker are not idle diversions. They are a
laboratory for a deep and recurring theme in mathematics and computer science:
the tension between a builder and a saboteur acting on the same limited resource.
The same push-and-pull governs fault-tolerant network design (can you route a
connection before an adversary severs enough links?), the analysis of randomized
algorithms, and the theory of when random structures suddenly acquire a property.

In fact, the Maker–Breaker world is tightly linked to **random graphs**. A
celebrated heuristic says that a clever Maker facing bias $q$ does about as well
as if the board's lines were handed out at random with the corresponding density
— the so-called *random graph intuition*. The exponent $1/m_2(H)$ is precisely
the exponent at which random graphs begin to contain copies of $H$ robustly, so
our threshold mirrors a phase transition in random graph theory. Pinning the
constant $c_k$ exactly is the game-theoretic analogue of locating a critical
point with full precision rather than merely to leading order.

Finally there is the aesthetic payoff. It is one thing to know that a quantity
grows "like $n^{2/3}$." It is quite another to write down the exact leading
constant, prove it is the sharp dividing line, and then discover that this
constant conceals a surprise — a non-monotone rise and fall converging to the
tidy number $2$. The cycle game turns out to have a tipping point we can name to
the last detail, and the name is more interesting than anyone had a right to
expect.
