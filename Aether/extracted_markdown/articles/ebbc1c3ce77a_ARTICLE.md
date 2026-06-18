# One Map to Bind Them: How Softmax Secretly Unites Tropical Geometry, Pythagoras, and Probability

## A coincidence too good to be a coincidence

Three of the most familiar objects in all of mathematics rarely show up at the same party.

The first is **Pythagoras' theorem**, the 2,500-year-old promise that the squares on the two short sides of a right triangle add up to the square on the long one: \(a^2 + b^2 = c^2\). It is the first piece of "real" mathematics most of us ever meet.

The second is the **bell curve and its cousins** — the world of *probability*, where the only iron law is that the chances of all possible outcomes must add up to exactly one.

The third is the strangest guest of all: **tropical mathematics**, a parallel arithmetic in which addition is replaced by "take the maximum" and multiplication is replaced by ordinary addition. It sounds like a joke, but it is the natural language of optimization, of scheduling, of the cheapest route through a network, and — as we'll see — of the energy landscapes that physicists and machine-learning engineers stare at all day.

What could a right triangle, a coin flip, and the operation "take the bigger of two numbers" possibly have in common?

The answer, it turns out, is a single map — one humble formula that quietly turns out to be the **same machine** viewed from three different angles. Machine-learning practitioners already know this formula intimately and call it **softmax**. This article is the story of how softmax is the secret hinge connecting tropical geometry, the geometry of triangles, and the arithmetic of chance — and how each of those three worlds throws unexpected light on the other two.

## The normalizing machine

Start with a deceptively simple question. Suppose you have two numbers, \(a\) and \(b\). They could be the "scores" of two options, the log-prices of two assets, or the energies of two states of a physical system. You want to convert them into **probabilities**: two non-negative numbers that sum to one and that respect the ordering (a bigger score should get a bigger probability).

The softmax map does exactly this. For two inputs it is

\[
\mathrm{softmax}_2(a,b) \;=\; \frac{e^{a}}{e^{a}+e^{b}}.
\]

It exponentiates each score (making everything positive) and then divides by the total (making everything sum to one). The companion weight \(\mathrm{softmax}_2(b,a) = e^b/(e^a+e^b)\) is the probability assigned to the other option, and the two are guaranteed to partition the whole:

> **Partition of unity.** For all real \(a,b\): \(\;\mathrm{softmax}_2(a,b) + \mathrm{softmax}_2(b,a) = 1.\)

So softmax is, first and foremost, a **normalizing machine**: it takes raw scores and presses them onto the *probability simplex*, the set of probability vectors. Each output sits strictly between 0 and 1 — never a sure thing, never an impossibility, always a genuine wager.

The first sign that something deep is going on is what softmax *ignores*. If you add the same constant \(c\) to both scores — inflate both prices, shift both energies by a fixed amount, change the zero of your measuring stick — the output is utterly unchanged:

> **Shift invariance (functoriality).** For all \(a,b,c\): \(\;\mathrm{softmax}_2(a+c,\,b+c) = \mathrm{softmax}_2(a,b).\)

This is more than a convenience (though it is also the reason softmax is numerically stable in software). It is the statement that softmax is a **functor**: it does not care about the absolute level of the scores, only about their *differences*. The "diagonal shift action" \((a,b)\mapsto(a+c,b+c)\) is a symmetry, and softmax is the invariant. Hold that thought — symmetry under rescaling is exactly the bridge to Pythagoras.

Finally, softmax misses nothing. Any genuine pair of odds is reachable:

> **Surjectivity onto the open simplex.** For any positive weights \(p,q>0\), \(\;\mathrm{softmax}_2(\log p,\,\log q) = \dfrac{p}{p+q}.\)

Feed softmax the *logarithms* of any two positive weights and it hands back exactly their normalized ratio. Every interior point of the probability simplex is the softmax image of some pair of "log-coordinates." Softmax is a perfect dictionary between the additive world of log-scores and the multiplicative world of probabilities.

## The tropical twin

Where do those log-scores come from, and why exponentiate at all? Enter the tropical world.

Tropical mathematics replaces ordinary addition with the **maximum**. In that semiring, the "sum" of \(a\) and \(b\) is simply \(\max(a,b)\). This is the arithmetic of *worst cases* and *best cases*: the cost of the most expensive leg of a journey, the bottleneck in a pipeline, the dominant term in an exponential.

There is a famous, smooth bridge between ordinary arithmetic and this tropical arithmetic, discovered in the study of large deviations and of semiclassical physics: the **log-sum-exp** functional,

\[
\mathrm{lse}_2(a,b) \;=\; \log\!\left(e^{a}+e^{b}\right).
\]

In physics this is (up to sign and temperature) the **free energy** of a two-state system; in statistics it is the *cumulant generating function*; in optimization it is the *soft maximum*. And it is glued to softmax by an exact, beautiful relationship that is the analytic heart of the whole story:

> **The gradient of free energy is probability.** The derivative of \(a \mapsto \mathrm{lse}_2(a,b)\) is exactly \(\mathrm{softmax}_2(a,b)\).

Differentiate the tropical free energy and softmax falls out. The same object is simultaneously a max-plus functional *and* the generating function of a probability law. The free energy *knows* the odds; you just have to differentiate it to read them off.

Why is log-sum-exp a "soft" maximum? Because it is pinned tightly to the genuine maximum on both sides:

> **The Maslov dequantization sandwich.** For all \(a,b\):
> \[
> \max(a,b) \;\le\; \mathrm{lse}_2(a,b) \;\le\; \max(a,b) + \log 2.
> \]

The log-sum-exp never undershoots the true max, and never overshoots it by more than \(\log 2 \approx 0.693\). The lower bound says "the soft max is at least the hard max"; the upper bound says "the penalty for softness is at most one bit of entropy." On the diagonal the bound is achieved exactly: \(\mathrm{lse}_2(a,a) = a + \log 2\). This squeeze is what mathematicians call **Maslov dequantization** — the precise sense in which ordinary algebra, viewed through a logarithmic lens at low temperature, *degenerates* into tropical algebra. Crank a temperature parameter down toward zero and the soft maximum hardens into the true maximum; the bridge collapses onto the tropical world it came from.

And lse\(_2\) carries the same symmetry softmax does, but in an additive disguise:

> **Shift homomorphism.** For all \(a,b,c\): \(\;\mathrm{lse}_2(a+c,\,b+c) = \mathrm{lse}_2(a,b) + c.\)

Shift both inputs by \(c\) and the free energy shifts by exactly \(c\). softmax *erased* the shift; lse\(_2\) *records* it faithfully. They are two faces of one coin: differentiating the recorder gives the eraser.

This whole structure scales to any number of options. The general softmax \(\mathrm{softmax}(w)_i = e^{w_i}/\sum_j e^{w_j}\) is still strictly positive and still a partition of unity (the weights sum to one), and it is still shift invariant. It is the workhorse at the output layer of essentially every modern classifier — the layer that turns a neural network's raw scores into a probability distribution over labels. The first lesson of this article is that this everyday engineering tool is, on the nose, the dequantization map between tropical and ordinary mathematics.

## Pythagoras crashes the party

Now for the surprise guest. What does a right triangle have to do with any of this?

Take any Pythagorean relation \(a^2 + b^2 = c^2\) with \(c>0\) — the side lengths of a right triangle, or one of the classic integer triples like \((3,4,5)\) or \((5,12,13)\). Define two numbers:

\[
p = \left(\frac{a}{c}\right)^2, \qquad q = \left(\frac{b}{c}\right)^2.
\]

These are the squared, normalized legs. And here is the small miracle, which is nothing other than Pythagoras' theorem wearing a new hat:

> **Pythagorean partition.** If \(a^2+b^2=c^2\) and \(c \ne 0\), then \(p + q = 1\).

The squared normalized legs of *any* right triangle are automatically a probability distribution! Pythagoras' theorem, the rule about areas of squares, is secretly the statement that "the probabilities sum to one." A right triangle *is* a (Bernoulli) coin flip in disguise: the \((3,4,5)\) triangle is the biased coin with \(p = 9/25 = 0.36\) and \(q = 16/25 = 0.64\).

This new probability doesn't care how big you draw the triangle:

> **Scale invariance.** Multiplying \((a,b,c)\) by any positive constant \(t\) leaves \(p\) unchanged.

Dilate the triangle and the coin stays the same. This is *exactly* the shift invariance of softmax, only now the symmetry is dilation of a triangle instead of a shift of scores. And the two symmetries are literally the same map in different coordinates:

> **Pythagoras is softmax of log-squared coordinates.** For \(a,b>0\),
> \[
> \mathrm{softmax}_2\!\big(\log a^2,\ \log b^2\big) \;=\; \frac{a^2}{a^2+b^2} \;=\; \left(\frac{a}{c}\right)^2 = p.
> \]

The Pythagorean probability is *literally* the softmax of the log-squared side lengths. The triangle's legs, run through a logarithm and then through softmax, reproduce the squared-leg distribution exactly. So the "dilation of a triangle" and the "additive shift of scores" are one symmetry seen in two coordinate systems, and softmax is the functor that translates between them. Tropical, geometric, probabilistic — one machine, three dialects.

## The hidden Pythagorean theorem inside every coin flip

The bridge runs both ways, and the return trip is just as striking. Every biased coin hides a right triangle, and that triangle measures the coin's **uncertainty**.

Recall the variance of a Bernoulli (two-outcome) law with probabilities \(p\) and \(q=1-p\): it is \(\mathrm{Var} = pq = p(1-p)\). Variance is the quantitative measure of how unpredictable a coin is — zero for a two-headed coin, largest for a perfectly fair one. Now watch what happens when we write down the most basic fact, "the probabilities sum to one," and *polarize* it:

\[
1 = (p+q)^2 = (p-q)^2 + 4pq.
\]

Since \(pq\) is exactly the variance, this rearranges into a genuine sum of two squares:

> **The Pythagorean probability identity.** For any Bernoulli law with \(p+q=1\),
> \[
> (p-q)^2 + 4\,\mathrm{Var} = 1, \qquad \text{equivalently}\qquad (p-q)^2 + \big(2\sigma\big)^2 = 1,
> \]
> where \(\sigma = \sqrt{\mathrm{Var}}\) is the standard deviation.

There it is: \(a^2 + b^2 = c^2\), reborn inside probability. The "long side" is \(c=1\), the total probability. One "leg" is the **polarization** \(p - q\), the imbalance of the coin — how far it leans toward one outcome. The other leg is \(2\sigma\), twice the standard deviation — the coin's intrinsic randomness. A perfectly biased coin (\(p=1\)) is the degenerate triangle with all of its length in the polarization leg and none in the noise leg. A perfectly fair coin (\(p=q=\tfrac12\)) is the opposite degenerate triangle: no polarization, maximal noise, \(2\sigma = 1\). Every coin in between is a genuine right triangle whose two legs trade off bias against uncertainty, always conspiring to keep the hypotenuse at exactly one.

And because Pythagorean triples *are* coins, this identity holds verbatim for the triangle itself: the squared-leg distribution \(p=(a/c)^2\), \(q=(b/c)^2\) satisfies \((p-q)^2 + 4pq = 1\), and its standard deviation \(\sigma = \sqrt{pq} = ab/c^2\) is exactly half the normalized area \(2ab/c^2\) of the right triangle. **A Bernoulli coin's noise is the area of its triangle.** Randomness, made geometric.

## Why this matters

It would be enough if this were merely pretty. But the dictionary does real work.

In **machine learning**, the output layer of a classifier is softmax, and training minimizes a log-sum-exp loss. The identity "gradient of free energy = probability" is the reason backpropagation through a softmax layer is so clean, and the "variance = second derivative" companion fact (the curvature of the free energy is the variance of the predicted label) is the engine behind natural-gradient and second-order optimization. The Maslov sandwich is precisely the statement that as a network grows "confident" (low temperature), softmax hardens into the argmax — the soft decision becomes a hard one, with a controlled, one-bit penalty along the way.

In **physics**, lse\(_2\) is the free energy and softmax is the Gibbs distribution. The dequantization sandwich is the rigorous form of the everyday intuition that at low temperature a system collapses into its lowest-energy state — the tropical limit of statistical mechanics.

In **optimization and computer science**, the max-plus semiring governs shortest paths, scheduling, and dynamic programming. Softmax is the smooth surrogate that makes these discrete problems differentiable, and the bridge tells us exactly how much smoothing costs.

And running through all of it is the oldest theorem in the book. Pythagoras' \(a^2+b^2=c^2\) turns out to be not a fact about triangles but a fact about *normalization* — the same normalization that softmax performs, the same partition of unity that probability demands. The right triangle was a probability distribution all along; the coin flip was a right triangle all along; and softmax is the translator that lets each one speak the other's language, with tropical free energy as the grammar that makes the translation exact.

Mathematics is full of these secret family resemblances. What makes this one special is how *elementary* its ingredients are — a triangle, a coin, a maximum — and how cleanly they snap together once you find the single map that was binding them all along.
