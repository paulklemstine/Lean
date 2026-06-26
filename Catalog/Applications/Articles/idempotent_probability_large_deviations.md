# When Probability Forgets How to Add: The Strange World of Max-Plus Luck

## A coin that only remembers its best moment

Imagine a probability theory that has lost the ability to add numbers together.
In its place, it has learned a single move: *take the maximum*. Two unlikely
things no longer combine their small chances into something even smaller — instead
the world simply remembers the more likely of the two and forgets the rest. Add a
constant cost to every outcome, and the theory dutifully shifts everything by that
cost. This is **max-plus probability**, also called *idempotent* or *tropical*
probability, and it is the natural language of a surprising number of real
problems: the slowest task in a chain of dependencies, the cheapest route through
a network, the most likely explanation behind a noisy signal, the dominant term
when temperatures drop to absolute zero.

The name *idempotent* comes from the fact that, in this arithmetic, $\max(a,a)=a$:
adding something to itself changes nothing. The name *tropical* is a piece of
mathematical folklore, a tribute to the Brazilian computer scientist Imre Simon
who pioneered the algebra. Whatever you call it, the rules are simple. The role
of "plus" is played by **maximum**, and the role of "times" is played by ordinary
**addition**. The number $0$ becomes the new multiplicative identity (adding zero
does nothing), and $-\infty$ becomes the new zero (it loses every maximum).

This article is about what happens when you push this strange arithmetic all the
way into one of the deepest parts of classical probability — the **theory of large
deviations**, which studies the probability of rare events — and discover that an
entire chapter of the theory becomes *exact, finite, and convexity-free*.

## Rare events and the price of surprise

Classical large-deviation theory asks: how unlikely is a rare event, and *how*
unlikely, precisely? Flip a fair coin a million times and you expect about half a
million heads. The probability of seeing 600,000 heads is astronomically small —
but it is not zero, and its size is governed by a beautiful law. The probability
decays like $e^{-n\,I(a)}$, where $n$ is the number of flips, $a$ is the
fraction of heads you are asking about, and $I$ is a function called the **rate
function**. The rate function is the "price of surprise": the larger $I(a)$, the
more exponentially punishing it is to witness an average of $a$.

The central miracle of the classical theory, **Cramér's theorem**, is that this
price of surprise is computable. It equals the *Legendre–Fenchel transform* of a
single auxiliary quantity, the cumulant generating function. In symbols, $I$ is
the convex conjugate of $\Lambda$, where $\Lambda$ packages the exponential
moments of a single coin flip.

Now here is the idempotent twist. In the max-plus world, a probability law is just
a **weight function** $w$ that assigns to each outcome $x$ a number $w(x) \le 0$,
normalized so that the best outcome has weight exactly $0$:
$$\max_x w(x) = 0, \qquad w(x) \le 0 \text{ for all } x.$$
You should read $w(x)$ as the logarithm of a probability after the "temperature"
has been sent to zero — the most likely outcome sits at $0$, and everything else
is penalized. The **rate function** is then simply the negative weight,
$$I(x) = -w(x) \ge 0,$$
the deviation cost of outcome $x$. The most likely outcomes cost nothing; rare
ones cost a lot.

And the "probability" of a whole event $A$ — a set of outcomes — is the weight of
its *best* member:
$$\mu(A) = \max_{x \in A} w(x).$$
Its cost is the cheapest deviation that lands you in $A$:
$$\text{cost}(A) = -\mu(A) = \min_{x \in A} I(x).$$

This last formula is already a complete large-deviation principle — and it holds
**exactly**, for finitely many outcomes, with no limits and no approximations. In
the classical world the analogous statement only emerges asymptotically, as the
number of trials marches to infinity. In the idempotent world there is no
$\log$, no $\exp$, no smoothing: the cost of a rare event is *literally* the
minimum cost over the ways it can happen. We call this the **sharp idempotent
LDP**, and it is the rock on which everything else is built.

## The contraction principle: rare events under a lens

Here is the question at the heart of this work. Suppose you have a max-plus
probability law on some space of detailed outcomes $X$, and you only get to
observe a *summary* of each outcome through a function $T : X \to Y$. Perhaps $X$
is the full microscopic configuration of a system and $Y$ is a single number you
can measure; perhaps $X$ is a pair of dice and $Y$ is their sum; perhaps $X$ is a
fine-grained path and $Y$ is its endpoint. The summary $T$ collapses many detailed
outcomes into one observed value — its **fibers**, the sets $T^{-1}(y) = \{x : T(x)=y\}$,
are the bundles of microstates that look identical from the outside.

Two natural laws now live on the observed space $Y$. First, the **push-forward**:
the most natural way to transport the law along $T$ is to give each observed value
$y$ the weight of its best preimage,
$$w_Y(y) = \max_{x \,:\, T(x) = y} w(x).$$
Second, on the cost side, every event $B \subseteq Y$ of observed values pulls
back to an event $T^{-1}(B) \subseteq X$ of detailed outcomes that produce it.

The **contraction principle** answers: how is the cost of a rare *observed* event
related to the cost of the detailed events behind it? The classical version of
this principle is one of the workhorses of large-deviation theory, and it is
usually proved with a delicate two-sided estimate that survives a limiting
procedure. The idempotent version proved here is razor-sharp and almost shockingly
clean.

**The main theorem, in plain language:** *the deviation cost of any observed event
equals the deviation cost of its preimage.* Symbolically, for any non-empty event
$B \subseteq Y$,
$$\min_{y \in B} I_Y(y) \;=\; \min_{x \in T^{-1}(B)} I_X(x).$$
There is no inequality to bridge, no $\varepsilon$ to chase to zero. The cheapest
way to deviate into $B$, measured upstairs in the observed world, is exactly the
cheapest way to deviate into the preimage of $B$, measured downstairs in the
detailed world. Equivalently, at the level of the max-plus measure itself, the
push-forward simply transports mass without loss: $\mu_Y(B) = \mu_X(T^{-1}(B))$.

Along the way the theorem delivers a clean formula for the transported rate
function. The cost of an observed value $y$ is the cheapest deviation among all
the microstates that produce it:
$$I_Y(y) = \min_{x \,:\, T(x) = y} I_X(x).$$
This is the idempotent **contraction of the rate function**, and it is exactly
what you would hope for: to make the summary $y$ happen, nature picks the least
costly microscopic story consistent with it.

## A worked example you can do by hand

Let the detailed world be three outcomes $X = \{a, b, c\}$, with weights
$$w(a) = 0, \qquad w(b) = -1, \qquad w(c) = -3,$$
so the deviation costs are $I_X(a)=0$, $I_X(b)=1$, $I_X(c)=3$. The best outcome
$a$ is free; $c$ is expensive. Now observe through a summary map $T$ that merges
$a$ and $b$ into a single label $0$ and sends $c$ to label $1$:
$$T(a) = 0, \quad T(b) = 0, \quad T(c) = 1.$$
The fiber over $0$ is $\{a,b\}$ and the fiber over $1$ is $\{c\}$.

The push-forward weights are the best weight in each fiber:
$$w_Y(0) = \max(0, -1) = 0, \qquad w_Y(1) = -3,$$
giving observed costs $I_Y(0) = 0$ and $I_Y(1) = 3$ — exactly the fiber-wise
minima of $I_X$, just as the contraction-of-rate formula promised.

Now test the main theorem on the event $B = \{1\}$. Upstairs, its cost is
$I_Y(1) = 3$. Downstairs, its preimage is $T^{-1}(B) = \{c\}$, whose cost is
$I_X(c) = 3$. They agree. Try the full event $B = \{0,1\}$: upstairs the cost is
$\min(0,3) = 0$; downstairs the preimage is everything, $\{a,b,c\}$, with cost
$\min(0,1,3) = 0$. They agree again. The bookkeeping is exact every time.

## Why no convexity is needed — and where it suddenly is

The most striking feature of the contraction principle is what it *doesn't*
require. The proof is purely about reordering minimizations: a minimum over a
preimage is the same number whether you compute it all at once or fiber by fiber
and then minimize across fibers. In the language of the formal development this is
the single combinatorial identity
$$\min_{x \in T^{-1}(B)} f(x) \;=\; \min_{y \in B}\;\min_{x \in T^{-1}(y)} f(x),$$
a statement of pure order theory. No averages, no straight lines, no convex sets.
The contraction half of the idempotent Cramér program is **convexity-free**.

This is in pointed contrast to the *other* half of the theory — the
Legendre–Fenchel duality that recovers the rate function from the cumulant
generating function. There, convexity is not a convenience; it is the whole game.
To see this, the development includes a deliberately adversarial counterexample.
Take three observed values $0, 1, 2$ with rate function $I = (0, 2, 0)$ — a
**spike** in the middle, the opposite of convex. The cumulant generating function
of this law turns out to satisfy $\lambda \le \Lambda(\lambda)$ for every slope,
which means no straight line can ever reach up to the tip of the spike. The double
Legendre–Fenchel transform — the best convex lower envelope of $I$ — flattens the
spike completely down to the chord joining the endpoints, collapsing the middle
value from $2$ all the way to $0$. The result is a genuine, exactly computed
**duality gap of size $2$**: convex duality reports a cost of $0$ where the true
cost is $2$.

The moral is sharp. Idempotent Cramér theory cleanly splits into two halves of
opposite character. One half — the contraction principle, the transport of rare
events through a summary map — needs no convexity at all and holds with perfect
exactness. The other half — recovering the rate function as a convex conjugate —
lives and dies by convexity, and fails by a measurable amount the moment the rate
function bends the wrong way. The same example that makes the duality gap concrete
also shows that the convexity hypothesis in the duality theorem is not a technical
blemish: it is load-bearing.

## The supporting cast: a self-contained toolkit

The contraction principle does not stand alone. It is the capstone of a small,
fully worked idempotent probability theory, and the surrounding results are worth
meeting because they make the whole picture self-supporting.

The **max-plus integral** of an observable $f$ against a law $w$ is
$\max_x\,(f(x) + w(x))$ — the best total score across outcomes. It is monotone, it
shifts by a constant when you shift $f$, and it always attains its maximum at some
concrete outcome. These mundane-sounding facts are exactly what make the theory
behave like genuine integration rather than a notational trick.

The **cumulant generating function** $\Lambda(\lambda) = \max_x(\lambda\,\mathrm{val}(x) + w(x))$
is the idempotent shadow of the classical exponential-moment function. It is
always **convex** (it is a maximum of straight lines in $\lambda$). It is
**additive over independent products** — the max-plus echo of the classical rule
that exponential moments of independent sums multiply. And for an $n$-step
**max-plus random walk**, whose path weight is the sum of its per-step weights,
the cumulant generating function is exactly $n$ times that of a single step. That
last identity is the engine that drives the scaling behind large deviations,
reproduced here without a single limit.

From the same function comes the idempotent **Chernoff bound**: for any
non-negative slope $\lambda$ and any outcome whose observable is at least $a$, the
weight is bounded by $\Lambda(\lambda) - \lambda a$. Optimizing over $\lambda$
gives the exponential-tail estimate familiar from classical probability — except
here the inequality is an exact, finite statement about weights.

Stitched together, these pieces form a complete idempotent retelling of Cramér's
program: a sharp finite large-deviation principle, a convex cumulant generating
function with the right additivity, an exact contraction principle for transporting
rare events through summaries, and a precise diagnosis of when — and by exactly how
much — convex duality can fail.

## Why it matters beyond the symbols

Max-plus thinking is not an exotic curiosity; it is how engineers and scientists
already reason about worst cases and dominant terms. In a manufacturing pipeline,
the time to finish is the *maximum* over parallel stages, not their sum, and the
cost of each stage adds along a path — that is max-plus arithmetic exactly. In
networks, shortest paths obey the cousin min-plus algebra. In statistical physics,
the zero-temperature limit replaces sums over states with a maximum over the
lowest-energy ones — the very "dequantization" that turns ordinary probability
into the idempotent kind. And in machine learning, the same collapse turns a
softmax into a hard max and turns log-likelihoods into tropical scores.

In every one of these settings, the contraction principle answers a recurring
practical question: *if I only observe a summary of my system, how does the
worst-case cost of a summary-level event relate to the worst-case cost downstairs?*
The answer proved here is the cleanest one imaginable — they are equal — and it
comes with an explicit recipe for the summary-level cost as a fiber-wise minimum.
That a rare-event theory usually built from careful asymptotic estimates becomes,
in the idempotent world, a matter of exact bookkeeping is a small but genuine piece
of mathematical good fortune. And knowing precisely where the good fortune
runs out — at the spike where convex duality opens a gap of exactly $2$ — is just
as valuable as knowing where it holds.
