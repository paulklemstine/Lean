# The Dust at the End of the Pythagorean Tree

## What a random walk through all right triangles sees at infinity

### An old tree with three branches

Everyone meets $3, 4, 5$ in school. Rather fewer people meet the astonishing fact that *every*
primitive Pythagorean triple — every triple of whole numbers with $a^2 + b^2 = c^2$ and no common
factor — hangs from a single tree, and hangs there exactly once.

The tree is easiest to describe not on the triples themselves but on their *seeds*. Euclid's
parametrisation says that every primitive triple is
$$(a, b, c) = (m^2 - n^2,\; 2mn,\; m^2 + n^2)$$
for a unique pair of integers $m > n > 0$ that are coprime and of opposite parity. The seed of
$(3,4,5)$ is $(m,n) = (2,1)$. Now take any seed and apply the following three maps:
$$L(m,n) = (2m - n,\; m), \qquad M(m,n) = (2m + n,\; m), \qquad R(m,n) = (m + 2n,\; n).$$
Start at $(2,1)$ and iterate. You get an infinite ternary tree — three children per node, no
repetitions, no omissions — whose nodes are precisely the primitive Pythagorean triples. This is
the *Berggren tree*, and it is one of the few genuinely complete classifications in elementary
number theory: a single root, three moves, and all of Pythagoras.

From $(2,1)$, the move $L$ gives $(3,2) \to (5,12,13)$, the move $M$ gives $(5,2) \to
(21,20,29)$, and $R$ gives $(4,1) \to (15,8,17)$. Three children, three new triangles, forever.

So the tree is understood. The question this article is about is what happens if you stop
looking at the tree and start looking at *where the tree goes*.

### The boundary: a Cantor set made of triangles

Walk down from the root forever. At each step you choose $L$, $M$, or $R$; after infinitely many
steps you have chosen an infinite word such as $LMMRLRR\ldots$, and you have traced out an
infinite descending path — an *end* of the tree, a direction in which the triples run off to
infinity. The set of all such ends is the **boundary** of the Berggren tree. Because every node
has exactly three children and no path ever merges back, the boundary is exactly the set of
infinite words in a three-letter alphabet:
$$\partial \mathcal{T} \;=\; \{L, M, R\}^{\mathbb{N}}.$$

Give this set the natural notion of closeness: two ends are near each other when they agree for a
long time, i.e. when the two paths stay together deep into the tree before splitting. Concretely,
if the first $n$ letters agree, call the distance $3^{-n}$. The resulting space is what a
topologist calls a *Cantor space*, and one of the first results here is that this really is the
case:

> **Theorem (The boundary is a Cantor set).** With the "long common prefix" topology, the
> boundary of the Berggren tree is a nonempty, compact, metrizable, totally disconnected space
> with no isolated points. Every one of its basic neighbourhoods — the *cylinder* consisting of
> all ends passing through a fixed node — is simultaneously open and closed, and contains at
> least two distinct ends, so every subtree branches forever.

By Brouwer's classical characterisation, that quartet of properties pins the space down
completely: the boundary of the Pythagorean tree is homeomorphic to the middle-thirds Cantor set
you can build with scissors from an interval of paper. Dust, in other words. Structured dust,
made of directions in which right triangles can grow.

### Now roll dice

Here is where probability enters. Suppose that instead of choosing your path deliberately, you
choose it at random: at every node, take the left branch with probability $p_1$, the middle with
probability $p_2$, the right with probability $p_3$, where $p_1 + p_2 + p_3 = 1$ and all three
are strictly positive. Independently at every step. Your random walk descends forever, and in the
limit it lands somewhere on the boundary — on some grain of the Cantor dust.

Where does it land? Not at any particular point (each individual end has probability zero), but
with a certain *distribution*: a probability measure on the Cantor set that records how likely
each region of dust is to be hit. This distribution is what analysts call the **harmonic
measure** of the walk. It is the unique measure that is *self-reproducing* under the walk: if you
take one random step and then distribute the remaining mass by the same rule, you must get back
exactly what you started with. Written out, the harmonic measure $\nu$ must satisfy the
stationarity equation
$$\nu \;=\; p_1 \cdot L_*\nu \;+\; p_2 \cdot M_*\nu \;+\; p_3 \cdot R_*\nu,$$
where $L_*, M_*, R_*$ are the operations "prepend the letter $L$/$M$/$R$" pushed forward to
measures. This equation is a fixed-point condition, and fixed-point conditions on infinite spaces
are not usually kind. Here, they are:

> **Theorem (Harmonic measure of the Berggren walk).** For every strictly positive weight vector
> $(p_1, p_2, p_3)$ there is exactly one probability measure on the boundary satisfying the
> stationarity equation, and it is the Bernoulli product measure: the measure that assigns to the
> cylinder through the node labelled by the word $w = w_1 w_2 \cdots w_n$ the mass
> $$\nu[w] \;=\; p_{w_1} p_{w_2} \cdots p_{w_n}.$$

Existence *and* uniqueness. The random walk on the Pythagorean tree has no hidden stationary
states, no exotic invariant measure lurking in the dust: the harmonic measure is the plainest one
imaginable, the infinite coin-flip measure. When the three moves are equally likely, the mass of
a depth-$n$ cylinder is $3^{-n}$: the fair walk lands with exactly the natural Cantor measure of
the boundary, the same measure the middle-thirds construction carries.

The proof is a two-step argument that is worth stating because it is genuinely short. First, the
cylinders form a *$\pi$-system* — the intersection of two cylinders is either empty or one of
them, because two nodes of a tree are either nested or incomparable — and they generate all the
measurable structure on the boundary. So a probability measure is determined by its cylinder
masses. Second, feed a cylinder of depth $n+1$ into the stationarity equation: pulling it back
along "prepend $a$" kills it unless $a$ is its first letter, and shortens it by one letter when
it is. That is a recursion, and the recursion has exactly one solution: the product. Everything
else follows.

### How much information is in a random Pythagorean direction?

Once you know the measure, you can ask how *spread out* it is. The right currency is Shannon
entropy,
$$H(p_1,p_2,p_3) \;=\; -p_1 \log p_1 - p_2 \log p_2 - p_3 \log p_3,$$
the average number of nats of information you learn from one step of the walk. It measures how
unpredictable each choice of branch is, and it comes out of the tree as cleanly as one could
hope:

> **Theorem (Exact entropy of depth-$n$ nodes).** Summing over all $3^n$ nodes at depth $n$,
> weighted by their harmonic mass, the average information content of a depth-$n$ node is
> *exactly* $n\,H(p_1,p_2,p_3)$:
> $$\sum_{|w| = n} \nu[w] \cdot \bigl(-\log \nu[w]\bigr) \;=\; n\,H(p_1,p_2,p_3).$$

No error term, no asymptotics, no constants: an identity at every finite depth. And the pointwise
version — the Shannon–McMillan–Breiman theorem, here proved directly from the strong law of large
numbers applied to the letters of the random word — says that almost every single ray sees the
same rate: for almost every end $x$,
$$-\frac{1}{n}\log \nu(\text{cylinder of depth } n \text{ around } x) \;\longrightarrow\; H(p_1,p_2,p_3).$$

Divide by $\log 3$ — the logarithm of the branching number, which is also the exponent relating
$3^{-n}$ to the depth — and you get the **dimension** of the harmonic measure:
$$\dim \nu \;=\; \frac{H(p_1,p_2,p_3)}{\log 3}.$$
This is at most $1$, the dimension of the whole boundary in the 3-adic metric, with equality
precisely when $p_1 = p_2 = p_3 = 1/3$. Bias the walk in *any* way and the harmonic measure
collapses onto a fractal subset of the Cantor dust of strictly smaller dimension. Fairness is the
unique maximiser, and the loss is Gibbs' inequality made geometric.

### Every walk leaves a different fingerprint

Now take two different weight vectors, $(p_1,p_2,p_3)$ and $(q_1,q_2,q_3)$. Both walks live on
the same Cantor set. Both harmonic measures have full support — every node of the tree, however
far out, carries positive mass, so the two measures charge exactly the same open sets. And yet:

> **Theorem (Mutual singularity and ray rigidity).** If the two weight vectors differ, the two
> harmonic measures are *mutually singular*: there is a set carrying all the mass of one and none
> of the mass of the other. Moreover a single ray suffices to tell them apart. Define, for each
> boundary point $x$ and each letter $a$,
> $$\rho_a(x) \;=\; \limsup_{n\to\infty} \frac{\#\{i < n : x_i = a\}}{n},$$
> the asymptotic frequency of the move $a$ along $x$. Then $\rho(x) = (p_1,p_2,p_3)$ for almost
> every $x$, and for two walks the following are equivalent: the weight vectors are equal; some
> single ray is typical for both; the harmonic measures are equal; the harmonic measures are not
> mutually singular.

This is a strict dichotomy — equal or maximally different, with nothing in between. It also means
the harmonic measure is a *perfect* record of the walk: watch one typical infinite descent
through the Pythagorean triples, count how often each of the three moves is used, and you have
recovered the dice.

How fast? Exponentially fast, and by an amount that is now pinned from both sides. On one hand, a
Chernoff bound on the letter counts shows the frequency of a move deviates from its mean with
probability at most $e^{-n\,\mathrm{KL}(u \Vert p_a)}$, where $\mathrm{KL}$ is the binary relative
entropy; consequently, for any two distinct walks there is a constant $c > 0$ and, at each depth
$n$, a test depending only on the first $n$ moves that is right with probability $1 - e^{-cn}$
under one walk and wrong with probability at most $e^{-cn}$ under the other. Total-variation
separation at depth $n$ tends to $1$: the qualitative singularity is the shadow of an exponential
cutoff.

On the other hand, no test can do better than a specific exponent. Let
$$\beta \;=\; \sqrt{p_1 q_1} + \sqrt{p_2 q_2} + \sqrt{p_3 q_3}$$
be the Bhattacharyya coefficient of the two one-step laws — a number in $(0,1]$, and strictly
below $1$ precisely when the walks differ. Then for *every* event $A$ determined by the first $n$
moves, the two error probabilities obey
$$\nu_P(A) + \nu_Q(A^c) \;\ge\; \tfrac{1}{2}\,\beta^{2n}.$$
You cannot separate two Berggren walks at depth $n$ faster than the rate $-2\log\beta$. Together
with the Chernoff bound, the true cutoff rate is bracketed.

### The silver ratio, and a conjecture that turned out to be false

The Berggren tree also has a *geometry*. Send the seed $(m,n)$ to the point $z(m,n) = (n + i)/m$
in the hyperbolic upper half-plane. Then the hyperbolic distance from the base point $i$ to the
node $z(m,n)$ is $\log m$ to within $\log 2$ — the metric growth of the tree is the growth of the
first Euclid coordinate. And that growth is governed not by the branching number $3$ but by the
**silver ratio** $1 + \sqrt{2} = 2.4142\ldots$, because the quantity $\Phi(m,n) = m + (\sqrt{2} -
1)n$ multiplies by *at most* $1 + \sqrt{2}$ under each of the three moves, with equality exactly
for the middle move $M$. In terms of the word $w$ labelling a path,
$$\bigl(\#M(w) + 1\bigr)\log 2 \;\le\; d\bigl(i, z(w)\bigr) \;\le\; \bigl(|w| + 1\bigr)\log(1 + \sqrt{2}) + \log 2 .$$

Average this over the random walk. The expected number of middle moves in $n$ steps is exactly
$np_2$, so the expected hyperbolic displacement is sandwiched:
$$p_2 \log 2 \;\le\; \frac{\mathbb{E}\,d(i, z_n)}{n} \;\le\; \log(1 + \sqrt{2}) + \frac{\log(1+\sqrt 2) + \log 2}{n}.$$
Applying the strong law instead of the mean upgrades this to an almost sure statement: along
almost every ray, for every $\varepsilon > 0$ and all large $n$,
$$p_2 \log 2 - \varepsilon \;\le\; \frac{d(i, z_n)}{n} \;\le\; \log(1 + \sqrt{2}) + \varepsilon,$$
and in particular the distance tends to infinity. The harmonic measure really does live at
infinity, on the boundary, and not secretly on the tree.

The original conjecture was that the silver ratio would also govern the *spectral gap* of the
walk — the second eigenvalue of the associated averaging operator, the number that controls how
fast the walk forgets its past. This turns out to be false, and false in a clean way. The
averaging (transfer) operator is
$$(\mathcal{L}f)(x) \;=\; p_1 f(Lx) + p_2 f(Mx) + p_3 f(Rx),$$
prepending each letter and averaging. If $f$ depends only on the first $n+1$ letters of its
argument, then $\mathcal{L}f$ depends only on the first $n$: the operator *strictly forgets one
letter per application*. Iterating, $\mathcal{L}^n f$ is constant. So on locally constant
observables $\mathcal{L}$ is nilpotent modulo constants: its only eigenvalues are $0$ and $1$,
the eigenvalue $1$ belongs to the constants alone, and the spectral gap is $1$ — the largest it
could possibly be, independent of $(p_1, p_2, p_3)$. In particular $\log(1 + \sqrt{2}) \approx
0.8814$, being strictly between $0$ and $1$, is *not* an eigenvalue. Silver governs the drift,
not the spectrum.

And there is a second, sharper way in which silver and entropy refuse to meet. The metric
exponent of the hyperbolic embedding is $2\log(1 + \sqrt 2) = \log(3 + 2\sqrt 2) = 1.7627\ldots$,
while the largest possible entropy of any Berggren walk is $\log 3 = 1.0986\ldots$. These are
different numbers, and the metric one is bigger — indeed $3^3 = 27 < 33.97 = (1 + \sqrt 2)^4$
gives $\log 3 / (2\log(1+\sqrt 2)) \le 2/3$. So the dimension of the harmonic measure *as seen in
the hyperbolic metric*,
$$\dim_{\mathrm{hyp}} \nu = \frac{H(p_1,p_2,p_3)}{2\log(1 + \sqrt{2})},$$
is at most $0.6232\ldots \le 2/3$, uniformly over all choices of the dice. The harmonic measure
of a Berggren walk is *never* the conformal measure of the hyperbolic embedding. There is a
permanent dimension deficit, and it is a genuine feature of the arithmetic: the tree branches
three ways but stretches by $1 + \sqrt 2$ per unit depth, and three is not enough to catch up.

### What this buys

The Berggren tree is now a fully worked example in the theory of random walks on trees: a
concrete object from elementary number theory, with an explicit boundary, an explicitly
identified and unique harmonic measure, exact entropy, exact dimension, ergodicity, complete
rigidity of the family of harmonic measures, exponential separation rates bracketed from both
sides, and a proven drift sandwich linking the probabilistic picture to the hyperbolic geometry
of the upper half-plane.

There is also a piece of negative information here that is arguably as valuable as the positive
ones. The instinct to expect a single growth constant to govern everything — growth, drift,
spectrum, dimension — is wrong for this tree. The silver ratio controls how fast a random
Pythagorean path runs away in hyperbolic space. It has nothing to say about how fast the walk
mixes, and it deliberately outruns the entropy, leaving the harmonic measure permanently
dimension-deficient. Three constants, three roles: $\log 3$ for information, $\log(1 + \sqrt 2)$
for distance, $1$ for the spectral gap.

The dust at the end of the Pythagorean tree, it turns out, has exactly measurable texture.
