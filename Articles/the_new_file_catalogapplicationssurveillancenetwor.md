# The Price of Perfect Privacy

## What a camera that sees nothing can still tell you

Imagine a city that installs a network of sensors to monitor traffic between
$n$ intersections over $T$ time steps. At every step, for every ordered pair of
intersections, a bit is recorded: was there a vehicle moving from here to there,
or not? The complete record — the *history* — is a binary array of
$T \cdot n^2$ bits. It is exactly the kind of data that is enormously useful in
aggregate and enormously dangerous in detail.

Now suppose the city promises something very strong. Not "we anonymize", not
"we aggregate", not "we add a little noise": **perfect privacy**. Whatever the
sensor network reports, the report must be *statistically independent of what
actually happened*. Two different histories must produce literally the same
observable record, always. Nothing about the world leaks. Ever.

The question this article is about is deceptively simple:

> If a channel leaks nothing at all, how badly must it reconstruct the world?

The answer is a clean piece of combinatorics, and it turns out to have a
surprising amount of structure: the cost of perfect privacy is a *covering
radius*, it splits additively across components, it halves when you only care
about the world up to relabeling, it halves again when you are willing to be
wrong on average rather than always, and every one of these statements has an
exact closed form.

---

## The setup, stripped down

Let $S$ be the finite set of possible states of the world — for our city,
$S = \{0,1\}^{\alpha}$ where $\alpha$ is the index set of all
(time, source, target) triples, so $|\alpha| = T n^2$ and $|S| = 2^{T n^2}$.

An **observer** is a map $\mathrm{obs} : S \to M$ that turns the true state into
a record drawn from a finite alphabet $M$. A **decoder** is a map
$\mathrm{dec} : M \to S$ that turns the record back into a guess. The quality of
the guess is measured by a **distortion** $d(c, s)$, a nonnegative integer
saying how wrong the reconstruction $c$ is when the truth is $s$. Our running
example is Hamming distortion: $d(c,s)$ counts the coordinates where $c$ and $s$
disagree.

The **rate** of the observer is the number of distinct records it can ever
produce, $\mathrm{rate}(\mathrm{obs}) = |\mathrm{obs}(S)|$; the logarithm of the
rate is the number of bits the channel actually transmits.

**Perfect privacy** says $\mathrm{obs}$ is a constant map: the record is the same
whatever the world does. That is the strongest possible non-disclosure
guarantee, and it immediately forces $\mathrm{rate} = 1$.

Here is the first observation, and it is almost too simple to be called a
theorem, yet it is the hinge of everything: *a perfectly private channel gives
the decoder nothing to work with, so the decoder outputs a single fixed
reconstruction $c$, chosen in advance.* The whole design problem collapses from
"choose a channel and a decoder" to "choose one point $c \in S$".

---

## Worst case: the covering radius

If the decoder must be right — within distortion $D$ — for *every* possible
world, then the single reconstruction $c$ must satisfy $d(c,s) \le D$ for all
$s \in S$. In other words, the ball of radius $D$ around $c$ must swallow the
entire state space. The smallest such $D$ is the classical **covering radius of
the one-codeword code**,
$$
R(d) \;=\; \min_{c \in S} \, \max_{s \in S} \, d(c,s).
$$

**Theorem (sharp private threshold).** *A perfectly private observer — whether
deterministic or randomized — can guarantee worst-case distortion $D$ if and
only if $D \ge R(d)$.*

Randomization deserves a comment, because it is the natural thing to try when a
deterministic scheme fails. A randomized private channel emits a record drawn
from a distribution that does not depend on the state. But then the *decoder's*
output is a random point independent of the world, and the worst case over
states of a mixture is at least the worst case of one of its components. Coin
flips buy nothing.

For binary data this is brutal. In the cube $\{0,1\}^{\alpha}$ with Hamming
distortion, the antipode of any point is at distance $|\alpha|$, so
$$
R(\text{Hamming}) = |\alpha|,
$$
and for our city, the private worst-case distortion is $T n^2$ — the *entire*
ambient dimension. A perfectly private surveillance channel is, in the worst
case, exactly as good as a channel that outputs a constant guess and can be
wrong about every single bit. Perfect privacy and worst-case fidelity are not in
tension; they are mutually exclusive.

---

## The converse with a rate knob: how many bits do you actually need?

The threshold theorem is qualitative. The quantitative version comes from a
counting argument that is worth seeing, because everything later in this story
is a variation on it.

Fix any observer/decoder pair achieving distortion $D$ everywhere. Group the
states by the record they produce: the *fibre* $\mathrm{obs}^{-1}(m)$. Every
state in that fibre is reconstructed as the same point $\mathrm{dec}(m)$, hence
every state in the fibre lies in the ball of radius $D$ around
$\mathrm{dec}(m)$. So each fibre is no larger than the largest ball, and
therefore
$$
|S| \;\le\; \mathrm{rate}(\mathrm{obs}) \cdot \max_c |B(c,D)|.
$$
For binary Hamming data the ball volume is exact — it is the binomial tail
$\sum_{i \le D} \binom{|\alpha|}{i}$ — so
$$
2^{|\alpha|} \;\le\; \mathrm{rate} \cdot \sum_{i \le D} \binom{|\alpha|}{i}.
$$
Setting $\mathrm{rate} = 1$ (perfect privacy) recovers the threshold, because the
binomial tail is *strictly* below $2^{|\alpha|}$ whenever $D < |\alpha|$.

## Being allowed to fail: a Fano-type converse

Insisting on correctness for *every* world is a very pessimistic contract. Real
systems fail sometimes. So replace the requirement "correct everywhere" by
"correct except on an event of probability at most $\varepsilon$".

The fibre argument survives the change of currency almost verbatim, provided
one is careful about where positivity is used. Let $p$ be any nonnegative weight
on states — a source law. Suppose every distortion ball has $p$-mass at most
$\beta$: $p(B(c,D)) \le \beta$ for all $c$. Let $G$ be the *good set* on which the
decoder is correct within $D$.

**Theorem (measure fibre-covering converse).**
$$
p(G) \;\le\; \mathrm{rate}(\mathrm{obs}) \cdot \beta .
$$

The proof is the same decomposition — cut $G$ into its fibres, note each fibre
sits inside a ball, sum — but now the step "a subset has smaller mass than its
superset" needs $p \ge 0$. That hypothesis is not cosmetic: with signed weights
the statement is simply false.

If $p$ is a probability law and the failure event has mass at most
$\varepsilon$, then $p(G) \ge 1 - \varepsilon$ and we get the Fano-flavoured
inequality
$$
1 - \varepsilon \;\le\; \mathrm{rate} \cdot \beta .
$$
Here $\beta$ plays the role of "ball volume over ambient volume" and
$\log \mathrm{rate}$ the role of the number of transmitted bits — this is the
combinatorial skeleton of the classical rate–distortion converse, with the
entropy replaced by a count.

For the uniform source on binary tensors the ball mass is exactly the binomial
tail over $2^{|\alpha|}$, so the inequality becomes fully explicit:
$$
(1-\varepsilon)\, 2^{|\alpha|} \;\le\; \mathrm{rate} \cdot \sum_{i \le D}\binom{|\alpha|}{i},
$$
and for a perfectly private observer ($\mathrm{rate}=1$),
$$
(1-\varepsilon)\, 2^{|\alpha|} \;\le\; \sum_{i \le D}\binom{|\alpha|}{i}.
$$
Read the other way round, this is a lower bound on how often a private observer
must be wrong:
$$
\varepsilon \;\ge\; 1 - \frac{\sum_{i \le D}\binom{|\alpha|}{i}}{2^{|\alpha|}} .
$$
A private observer that promises Hamming accuracy $D$ fails with at least the
probability that a fair coin sequence of length $|\alpha|$ has more than $D$
heads. And at $\varepsilon = 0$ the strict binomial inequality
$\sum_{i\le D}\binom{n}{i} < 2^n$ for $D<n$ re-derives the sharp threshold
$D \ge |\alpha|$ — the qualitative theorem is exactly the zero-slack corner of
the quantitative one.

---

## Average case: exactly a factor of two

Worst-case distortion is a harsh judge. Suppose instead we grade the private
observer by its *expected* distortion against a source law $p$. Because privacy
still collapses the design to a single reconstruction $c$, the optimum is the
**private rate–distortion function**
$$
D_{\mathrm{priv}}(p) \;=\; \min_{c \in S} \; \mathbb{E}_p\big[d(c, X)\big].
$$
Again randomization is useless, but now for a different reason: the expected
distortion of a randomized private channel is a *convex combination* of the
expected distortions $\mathbb{E}_p[d(\mathrm{dec}(m), X)]$ over records $m$, and a
convex combination is at least its smallest term. (This is a genuinely different
argument from the worst-case one, which was about supports rather than
averages.)

For Hamming distortion the minimization solves itself. Write
$\mathrm{mass}_i(b) = \mathbb{P}[X_i \ne b]$ for the source mass disagreeing with
bit $b$ in coordinate $i$. The expected distortion of a reconstruction $c$ splits
coordinatewise as $\sum_i \mathrm{mass}_i(c_i)$, so each coordinate can be
optimized on its own:

**Theorem (majority vote is optimal).** *The optimal private reconstruction is
the coordinatewise majority vote, and*
$$
D_{\mathrm{priv}}(p) \;=\; \sum_i \min\big(\mathrm{mass}_i(0),\, \mathrm{mass}_i(1)\big),
$$
*the total coordinatewise minority mass.*

For the uniform source every coordinate is an unbiased coin, every minority mass
is $1/2$, and
$$
D_{\mathrm{priv}}(\text{uniform}) = \frac{|\alpha|}{2},
$$
strictly below the worst-case value $|\alpha|$ as soon as there is at least one
coordinate. So for the city: a perfectly private observer of a $T$-step network
history suffers expected Hamming distortion exactly $T n^2 / 2$. Grading on
average instead of always buys back a factor of two — and, since $D_{\mathrm{priv}}
\le R(d)$ always, never more than the worst case.

That factor of two has a bleak interpretation. $T n^2/2$ is precisely what you
get by *guessing every bit at random*. Perfect privacy leaves the observer no
better than a coin.

---

## Forgetting who is who: another factor of two, and no more

Sometimes we do not care about the identities of the participants. A traffic
analyst may want to know *how much* activity there was, not *which* intersection
did it. Formally, let the symmetric group $S_\alpha$ act on binary tensors by
permuting coordinates, and judge reconstruction only up to that action:
$$
\mathrm{orb}(x,y) \;=\; \min_{g} \; d_{\text{Hamming}}(x \circ g,\, y).
$$

**Theorem (exact orbit distance).** *$\mathrm{orb}(x,y) = \big|\,\mathrm{wt}(x) - \mathrm{wt}(y)\,\big|$,
the gap between the Hamming weights.*

Both inequalities are real work. The lower bound is a support-counting
argument: relabeling cannot change the weight, and two tensors of different
weights differ in at least the weight gap. The upper bound is a construction:
given a target weight, one builds an explicit permutation moving the support of
$x$ into (or onto a superset of) the support of $y$, realizing the gap exactly.

Once the distortion depends only on weights, everything is one-dimensional. The
weights run over $\{0, 1, \dots, n\}$ with $n = |\alpha|$, and the best single
center is the middle one:

**Theorem (relabeled private threshold).** *The one-codeword covering radius for
orbit distortion is $\lceil n/2 \rceil$.*

Compare $n$ for plain Hamming: quotienting by the full relabeling group buys
back exactly a factor of two and no more. For the city's histories,
$\lceil T n^2/2 \rceil$.

The volumes also become exact. The set of tensors of weight $m$ is one orbit and
has $\binom{n}{m}$ elements, so an orbit ball of radius $D$ around a center of
weight $k$ has exactly
$$
\sum_{m = k-D}^{k+D} \binom{n}{m}
$$
elements — the promised replacement of Hamming ball volume by an orbit-counting
volume. Since each binomial coefficient is at most the central one, an orbit
ball has at most $(2D+1)\binom{n}{\lfloor n/2\rfloor}$ elements, and the fibre
argument survives the quotient:
$$
2^{n} \;\le\; \mathrm{rate} \cdot (2D+1)\binom{n}{\lfloor n/2\rfloor}.
$$
Since $\binom{n}{\lfloor n/2\rfloor} \approx 2^n/\sqrt{n}$, an observer that is
accurate up to relabeling at bounded radius still needs about
$\sqrt{n}/(2D+1)$ distinct records — the quotient softens the geometry but does
not make anonymity free.

---

## Privacy budgets add up

Finally, what happens when the world factors — one component per time step, say?
Let the state space be a product $\prod_i \sigma_i$ and let the distortion be
additive, $d(c,s) = \sum_i d_i(c_i, s_i)$.

**Theorem (tensorization of the private threshold).**
$$
R\Big(\sum_i d_i\Big) \;=\; \sum_i R(d_i).
$$

Neither direction is formal. For "$\le$", assemble a product center out of
componentwise optimal centers. For "$\ge$", from any product center extract, in
each component, a state at distance at least $R(d_i)$ — such a state must exist,
or that component's covering radius would be smaller — and glue those witnesses
into a single bad state. The consequence is operational: for a product system a
perfectly private observer meets budget $D$ iff $D \ge \sum_i R(d_i)$. The
privacy budget must be split across components and **no cross-component trade is
possible**. For a $T$-step history read as $T$ snapshots with additive
per-snapshot distortion, the threshold is $\sum_{t<T} n^2$: the per-step
thresholds simply add along the timeline, which is why a per-step privacy budget
costs nothing extra relative to a global one.

Tensorization also gives an independent re-derivation of the binary Hamming
threshold: a single bit has covering radius $1$ (no single bit covers both
values), Hamming distortion is the additive product of $|\alpha|$ copies of the
one-bit distortion, so $R = |\alpha|$. Two structurally different proofs of the
same constant.

The average-case version is, if anything, sharper:

**Theorem (average-case tensorization).** *For an additive distortion on a
product, $D_{\mathrm{priv}}(p) = \sum_i D_{\mathrm{priv}}(\text{$i$-th marginal of } p)$ —
with no independence assumption on the source.*

That is a striking statement. Correlations across components can be arbitrary —
the source may be maximally entangled across time — and the private optimum
still sees only the marginals. The reason is that a private decoder has just one
reconstruction to offer, an additive distortion evaluates it component by
component, and expectation of a sum is a sum of expectations that only ever
touches one coordinate at a time. Correlation is exactly the resource a private
channel cannot exploit.

---

## What it all says

Strip away the machinery and the story is this. Perfect privacy converts a
communication problem into a geometry problem: *place one point so as to be near
everything*. The cost of that placement is a covering radius, and the four
theorems above are four ways of measuring it.

- Demand correctness always, and the cost is the full ambient dimension: $T n^2$.
- Allow failure with probability $\varepsilon$, and the cost is governed by a
  binomial tail: $(1-\varepsilon)2^{n} \le \sum_{i \le D}\binom{n}{i}$.
- Grade on average, and the cost halves to $T n^2/2$ — no better than guessing.
- Forget the identities of the participants, and it halves again to
  $\lceil T n^2/2\rceil$ — but not further.
- Split the world into pieces, and the costs add exactly, with no interaction
  term, and with correlations across pieces contributing nothing.

Each relaxation of the contract buys a factor of two, and the arithmetic is
exact. That is the real content: there is no clever encoding, no randomization
trick, no correlation to exploit. When a channel truly leaks nothing, the best
it can do is publish a guess it decided on before the world happened — and every
one of these theorems is just a precise measurement of how bad that guess must
be.
