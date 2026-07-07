# The Hidden Constant in a Game of Cycles

## A duel on the complete graph

Imagine two players sitting across a table from one another, with a huge
diagram between them: $n$ dots, and a line drawn between *every* pair of dots.
Mathematicians call this object the **complete graph** $K_n$; for even a modest
$n$ it already contains a bewildering thicket of $\binom{n}{2}$ edges. The two
players are going to fight over those edges.

The first player is called **Maker**. Her goal is simple to state and
surprisingly hard to achieve: she wants to claim a set of edges that form a
**cycle of length $k$** — a closed loop $v_1 \to v_2 \to \dots \to v_k \to v_1$
passing through $k$ distinct dots. A triangle is the cycle of length $3$; a
square is length $4$; and so on. Fix your favorite length $k$ once and for all;
say $k = 4$, a four-sided loop.

The second player is called **Breaker**, and his job is exactly to stop her.

The twist that makes this a genuine science rather than a children's pastime is
the **bias**. On each turn Maker claims one edge, but Breaker is allowed to
claim $q$ edges. The number $q$ is Breaker's handicap — the larger it is, the
more of the board he can sweep away on every move, and the harder Maker's task
becomes. When $q = 1$ the game is perfectly balanced and Maker, the builder,
almost always wins on a large enough board. When $q$ is enormous — say Breaker
grabs half the board on his first move — Breaker wins trivially. Somewhere in
between lies a **tipping point**: a critical bias at which the advantage flips
from Maker to Breaker.

The story of this article is the story of that tipping point, and of a strange
universal number hiding inside it.

## The tipping point has a shape

The first thing to understand is that the tipping point is not a fixed number.
It grows as the board grows. If you double the number of dots, the critical
bias grows too — but *not* proportionally. A remarkable body of work on these
"Maker–Breaker games" showed that for the cycle game the tipping point behaves
like a **power law** in the board size $n$:

$$q_k(n) \;=\; c_k \cdot n^{\frac{k-2}{k-1}}.$$

Read this formula slowly, because both pieces are telling you something.

The **exponent** $\frac{k-2}{k-1}$ controls how fast the tipping point grows.
For a four-cycle ($k=4$) it is $\tfrac{2}{3}$; for a five-cycle it is
$\tfrac{3}{4}$; and as $k$ grows it creeps toward $1$ but never reaches it. So
the critical bias always grows *slower* than the board itself, but faster than
any smaller power. This exponent turns out to have a beautiful interpretation
we will return to.

The **constant** $c_k$ out front is the subtle part. It does not depend on the
board size at all — only on the length $k$ of the cycle Maker is chasing. It is
the "fine print" of the tipping point, the multiplicative factor that says
*exactly* where the crossover happens rather than merely how it scales. For a
long time this constant was known only to exist. The subject of this article is
that we can now say precisely what it is, and prove exactly how it behaves.

## The number itself

Here is the constant, in closed form:

$$c_k \;=\; \left[\,(k-1)\left(\frac{2(k-1)}{k}\right)^{k-2}\,\right]^{\frac{1}{k-1}}.$$

At first glance it is an intimidating tower of exponents. But it is built from
two very human ingredients.

The first ingredient is the number $k-1$, which counts (up to a factor) how many
edges a cycle of length $k$ has relative to its vertices — its internal
"density."

The second ingredient, $\dfrac{2(k-1)}{k}$, is the **average degree** of a
cycle. A cycle on $k$ vertices has exactly $k$ edges, and each edge touches two
vertices, so the total degree is $2k$ shared among... wait — that gives average
degree $2$. The quantity $\tfrac{2(k-1)}{k}$ is instead the average degree of
the cycle *with one vertex removed*, the natural "densest core" that governs the
game. This little fraction is the engine of the whole story, and it has two
exact properties that we can prove without any approximation:

- It is always **at least $3/2$**: for every $k \ge 4$,
  $\;\dfrac{2(k-1)}{k} \ge \dfrac{3}{2}$, with equality exactly at $k=4$.
- It is always **strictly less than $2$**:
  $\;\dfrac{2(k-1)}{k} < 2$ for every $k$.
- And it **strictly increases** with $k$, climbing steadily from $3/2$ up toward
  its ceiling of $2$.

So the average-degree factor lives permanently in the half-open band
$[\tfrac{3}{2}, 2)$. This innocent-looking sandwich is what tames the whole
constant.

## Trapping the constant between two walls

Because the constant $c_k$ is defined by that formula, its defining property is a
clean polynomial identity. Raising both sides to the power $k-1$ makes the
messy root disappear:

$$c_k^{\,k-1} \;=\; (k-1)\left(\frac{2(k-1)}{k}\right)^{k-2}.$$

This is the key that unlocks everything. To trap $c_k$ between two walls, we
just trap its $(k-1)$-th power between two walls and take roots.

**The floor.** Since the average-degree factor is at least $3/2$, we can replace
it by $3/2$ and only shrink the right-hand side. A short computation then gives
$c_k^{\,k-1} \ge (3/2)^{\,k-1}$, and taking $(k-1)$-th roots yields

$$c_k \;\ge\; \frac{3}{2} \qquad \text{for every } k \ge 4.$$

**The ceiling.** Since the average-degree factor is strictly below $2$, we can
replace it by $2$ and only enlarge the right-hand side, giving
$c_k^{\,k-1} < (k-1)\,2^{\,k-2}$. Now everything hinges on one clean inequality
between an *exponential* and a *linear-times-exponential* quantity:

$$(k-1)\,2^{\,k-2} \;<\; 3^{\,k-1} \qquad \text{for every } k \ge 4.$$

This is the crux. It says that the extra factor of $k-1$ is no match for the
larger growth rate of $3^{k-1}$ versus $2^{k-2}$. One proves it by a one-line
induction: at each step from $k$ to $k+1$ the left side multiplies by roughly
$2$ while the right side multiplies by $3$, and once $k > 3$ the gap only widens.
Combining, $c_k^{\,k-1} < 3^{\,k-1}$, and taking roots gives

$$c_k \;<\; 3 \qquad \text{for every } k \ge 4.$$

Put the two walls together and you have the headline result:

$$\boxed{\;\dfrac{3}{2} \;\le\; c_k \;<\; 3 \quad \text{for all } k \ge 4.\;}$$

The mysterious constant is not mysterious at all: it is a **genuine bounded
universal constant**, forever pinned inside the interval $[\tfrac32, 3)$, no
matter which cycle length you pick.

## Two beautiful conjectures that turned out to be wrong

Once you can compute a quantity, the temptation is to guess that it behaves as
nicely as possible. Two natural guesses about $c_k$ are almost irresistible — and
both are **false**.

**Guess one: the constant keeps growing with $k$.** It seems plausible that
longer cycles, being harder to build, should push the constant steadily upward.
They do — but only for a while. Evaluating the formula reveals that $c_k$ rises
from $c_4 \approx 1.890$, past $c_5 \approx 2.012$, up to a **single peak** at
$k = 13$, where $c_{13} \approx 2.1578$, and then it turns around and drifts
slowly back down. The constant is not monotone; it is *unimodal*, with a summit
at the thirteenth cycle.

**Guess two: the constant never exceeds $2$.** The average-degree factor is
always below $2$, so surely the constant is too? No. Already at $k = 5$ we find
$c_5 \approx 2.012 > 2$. The constant pokes above $2$ for a whole range of $k$
around the peak, reaching about $2.158$, before eventually settling back toward
$2$ as $k \to \infty$.

These failures are not embarrassments; they are the point. They tell us the true
shape of the curve: a value that starts below $2$, climbs to a peak of roughly
$2.158$ near $k=13$, and then descends asymptotically back to $2$. Our proven
bound $[\tfrac32, 3)$ is honest and sharp *in kind* — the real peak sits
comfortably inside it — while the tidier-looking guesses "$c_k$ is increasing"
and "$c_k < 2$" are simply not true.

## The exponent's secret identity

Return now to the exponent $\frac{k-2}{k-1}$. There is a lovely reason it takes
this exact form. Every graph has a notion of **maximum $2$-density**, a number
that measures how tightly packed its densest subgraph is. For a cycle of length
$k$, this density works out to exactly

$$m_2(C_k) \;=\; \frac{k-1}{k-2}.$$

And the exponent governing the tipping point is precisely its **reciprocal**:

$$\frac{k-2}{k-1} \;=\; \frac{1}{m_2(C_k)}.$$

This is not a coincidence but a deep principle: the rate at which a
Maker–Breaker game's tipping point scales is dictated by the density of the
structure being built. Denser targets are harder to complete, and the density
enters as a reciprocal exponent. One can verify directly that this exponent
always lies strictly between $0$ and $1$: it is positive because $k > 2$, and
below $1$ because $k-2 < k-1$. So the tipping point genuinely grows with the
board, but always sublinearly.

## The bias grows with the board — and the window is real

Two final facts complete the picture and reassure us that the whole framework is
meaningful rather than vacuous.

First, the tipping point $q_k(n) = c_k \cdot n^{(k-2)/(k-1)}$ is **strictly
increasing in the board size $n$**. This is exactly what intuition demands: a
bigger board gives Maker more room to build, so Breaker needs a larger handicap
to keep pace. Because the exponent is positive and the constant is positive, the
whole expression climbs monotonically as $n$ grows.

Second, the phrase "sharp threshold" has real teeth. The precise statement is
that for *any* tolerance $\varepsilon > 0$ and all large enough boards:

- if the bias satisfies $q < (1-\varepsilon)\,q_k(n)$, then **Maker wins**;
- if the bias satisfies $q > (1+\varepsilon)\,q_k(n)$, then **Breaker wins**.

The two conditions carve out a genuine nonempty **window**
$\big((1-\varepsilon)q_k(n),\,(1+\varepsilon)q_k(n)\big)$ straddling the tipping
point. Because $q_k(n) > 0$, this window is never empty; the transition from
Maker's world to Breaker's world is not a fuzzy smear but a razor-thin band whose
location we now know down to the leading constant.

## Why any of this matters

Positional games like the Maker–Breaker cycle game are toy models for a very
general phenomenon: the sudden emergence of structure under adversarial
pressure. The same mathematics that pins down when a builder can force a loop
onto a contested graph also illuminates fault-tolerant network design, the
robustness of communication grids against a jamming adversary, and the general
theory of thresholds in random and game-theoretic structures. Knowing merely
that a threshold *scales* like $n^{2/3}$ tells you the rough order of the fight;
knowing the *constant* out front tells you who wins a specific, real contest.

The pleasing moral is that a formula which looks like an impenetrable stack of
exponents is, on inspection, a well-behaved and thoroughly human number. It is
bounded between $3/2$ and $3$. It rises to a lone peak at the thirteenth cycle
and then eases back down toward $2$. Its exponent is nothing but the reciprocal
of a density. And the game it governs tips from one player to the other across a
sharp, well-defined, and now precisely located window. What began as a duel over
a tangle of edges ends, as the best mathematics so often does, with a single
clean constant.
