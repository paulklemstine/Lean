# The Hump That Sat in the Wrong Place

## How a bump in a sieve's error curve was tracked to its source — and how that source turned out to have an alibi

There is a particular pleasure in a mystery where the suspect is guilty of *part* of the crime. Not the whole thing. Just enough to explain the fingerprints on the window and none of what happened inside the house.

This is a story about such a suspect. The crime scene is a curve; the curve is an error curve; and the error curve has a hump in it that nobody ordered.

---

## A curve with a bulge

Start with a very old kind of computation. You want to factor a large number $N$, or at least to find integers $j$ near $\sqrt{N}$ for which the quantity

$$v(j) = j^2 - N$$

happens to factor into small primes. This is the engine room of a whole family of factoring methods: sweep $j$ across a window just above $\sqrt{N}$, compute $j^2 - N$, and keep the values that crumble into small factors. The ones that crumble are called *hits*, and hits are the raw material out of which a factorization is eventually assembled.

Now, you do not sweep blind. You have a *model*: a heuristic prediction, based on how integers of a given size typically factor, of how many hits you expect at each position in the window. Divide reality by prediction and you get a ratio

$$R = \frac{\text{observed hits}}{\text{predicted hits}}.$$

If the model were perfect, $R$ would sit flat at $1$ across the whole window. It does not. Across a sweep of nearly ten thousand hits, chopped into $64$ equally spaced positional bins, the measured ratio traces out an unmistakable arch: it starts low at $R \approx 0.837$, climbs to a peak of $R \approx 1.223$ around the thirty-third bin, and falls away again to $R \approx 0.894$ at the far edge. Fit a parabola to it and the quadratic coefficient comes out negative — the curve is *concave*, it bulges upward in the middle — and the fitted apex sits at relative position $x \approx 0.5901$ along the window. A separate, independent run put the apex at $0.5896$. Four digits of agreement between two computations that did not talk to each other.

So there is a hump. It is about $\pm 20\%$ tall. It is reproducible. And it means the model is systematically wrong in a *shaped* way: too pessimistic in the middle of the window, too optimistic at the ends.

The question is: **what makes it?**

---

## Suspects, and how to eliminate them

There are only so many things that could shape such a curve.

**Suspect one: the size of the largest prime.** Perhaps the hits with a big "completing" prime factor behave differently from the hits with only small ones, and the hump is a mixture artifact — the average of two flat things that happen to be weighted differently across the window. This suspect died arithmetically. Sorting the hits by the size of their largest prime factor into the four natural size bands, the observed masses came out as
$$[\,0,\; 0,\; 0.0007,\; 0.9993\,],$$
against a theoretical prediction of $[\,0,\,0,\,0.0013,\,0.9987\,]$. Ninety-nine point ninety-three percent of all hits live in a *single* band. There is nothing to mix. A mixture story needs at least two ingredients, and here there is essentially one.

**Suspect two: structure inside that one band.** Fine — maybe the band is not homogeneous. Split it into thirds by largest-prime size and look again. All three thirds are concave: fitted curvatures of $-0.18$, $-0.25$, $-0.44$. The hump does not live *between* the strata; it lives *inside every one of them*.

**Suspect three: the small-prime combinatorics.** Sort instead by how many small primes divide the value. Same outcome: the conditioning fails to absorb the excess. Conditioned amplitudes wobble by $\pm 2\%$ where the pooled excess is $+4.8\%$.

**Control checks:** run the identical machinery on data engineered to have no hump, and the fit returns a curvature whose confidence interval straddles zero and a peak height of $1.005$. The pipeline is not manufacturing arches out of nothing.

Every carrier hypothesis that says "the hump is composition — some sub-population is over-represented in the middle" died. What survives is the last and most primitive possibility, the one you always hope is not the answer because it is the one you cannot condition away:

> **The hump is geometry.** It comes from the shape of the function $j^2 - N$ itself on the window, interacting with the sizes of the values being sieved.

This article is about what happens when you take that last suspect seriously and work out, exactly, what it can and cannot do.

---

## The shape of $j^2 - N$

Here is the crucial change of variable, and it is the whole story in one line.

Write $r = \sqrt{N}$ and put $j = r + s$, so that $s$ measures how far into the window you have walked. Then

$$j^2 - N = (r+s)^2 - r^2 = s(s + 2r).$$

Let $M$ be the window's length and set $x = s/M$, the relative position running over $[0,1]$, and let

$$c = \frac{r}{M} = \frac{\sqrt N}{M}$$

be the window's *aspect ratio* — a single dimensionless number comparing the size of $\sqrt N$ to the length of the sweep. Then

$$j^2 - N = M^2 \cdot x\,(x + 2c).$$

Everything about the window's arithmetic is controlled by how *big* these values are, and size means logarithm. Dropping the irrelevant additive constant $2\log M$, the **log-size profile of the window** is

$$L_c(x) = \log x + \log(x + 2c).$$

This little function is the suspect, in person. And its first property is decisive.

> **Concavity of the log-size profile.** For every aspect ratio $c \ge 0$, the function $L_c(x)=\log x + \log(x+2c)$ is *strictly concave* on $x>0$.

The reason is immediate: it is a sum of two logarithms, each strictly concave, one of them merely shifted. Nothing deep — but everything downstream follows from it.

---

## Why concavity is a hump

The ratio $R$ is a measurement *against a straight-line reference*: the model is, on the scale that matters, affine across the window, so what you are really plotting is the deviation of the true profile from the straight line joining its two endpoint values. Call that straight line the *chord*, and call the deviation the *gap*:

$$G(x) = L_c(x) - \Big[L_c(a) + \tfrac{x-a}{b-a}\big(L_c(b) - L_c(a)\big)\Big],$$

on a window $0 < a < x < b$.

Concavity now hands you the entire qualitative shape for free.

> **The hump exists.** A strictly concave profile lies strictly *above* its endpoint chord at every interior point and exactly *on* it at both ends. Hence $G(a) = G(b) = 0$ and $G(x) > 0$ for all $a<x<b$.

That is: deficit at both edges, surplus throughout the middle, one sign throughout. Which is precisely the measured picture — $0.837$ at the left, $1.223$ in the middle, $0.894$ at the right.

> **The hump has exactly one peak.** There is a unique interior point $\xi$ where the profile's slope equals the chord's slope,
> $$\frac{1}{\xi} + \frac{1}{\xi + 2c} \;=\; \frac{L_c(b)-L_c(a)}{b-a},$$
> the gap rises strictly to the left of $\xi$ and falls strictly to the right of it, and $\xi$ is the location of the maximum.

Uniqueness is where the concavity earns its keep a second time: the slope $1/x + 1/(x+2c)$ is *strictly decreasing*, so it can cross any given level only once. Two peaks are impossible.

So the geometry does produce a hump: right sign, right edge behaviour, right number of peaks. The suspect is at the scene.

---

## But is the hump real, or is it the binning?

A sceptic has a good objection at this point. The measured curve is not a curve at all — it is $64$ bin averages, and both of the headline numbers (the negative fitted curvature and the peak's location) are computed from that discretization. Change the bin width, shift the grid a little, and might not the arch simply evaporate, or split into two, or appear where there was nothing?

This is exactly the right thing to worry about, and it has a completely satisfying answer: **no, at any bin width, at any offset.**

> **Binning preserves concavity.** Sample a concave profile on any arithmetic grid of points $a + \delta i$, and average consecutive blocks of $w$ samples into bins. Then for every bin width $w$, every grid offset $a$, and every sample spacing $\delta$, the resulting sequence of bin averages $b_0, b_1, b_2, \dots$ satisfies the discrete concavity inequality
> $$b_k + b_{k+2} \;\le\; 2\,b_{k+1},$$
> with strict inequality when the profile is strictly concave, $w \ge 1$ and $\delta \ne 0$.

The proof is one observation repeated $w$ times. Sample number $(k+1)w+i$ sits *exactly halfway* between sample $kw+i$ and sample $(k+2)w+i$ — that is the whole content of "the grid is arithmetic and the bins are equal." Concavity says a function at a midpoint is at least the average of its values at the two ends. Sum that over the $w$ positions inside a bin, divide by $w$, and you have the inequality.

The companion statement is the control:

> **Binning creates nothing.** An affine profile bins to an exactly affine sequence: $b_k + b_{k+2} - 2b_{k+1} = 0$ identically, at every bin width and offset.

Together these are a licence to trust the picture. Concavity survives binning; flatness survives binning; so a measured curvature that is not zero cannot be an artifact of the grid.

And there is a bonus, which kills a whole class of alternative explanations:

> **Discrete concavity forces a single peak.** If a sequence satisfies $b_k + b_{k+2} \le 2 b_{k+1}$ for all $k$, then once it goes down it never comes back up: $b_{k+1} \le b_k$ implies $b_{k+j+1} \le b_{k+j}$ for every $j \ge 0$.

So the binned profile is unimodal. No permutation of bin widths can split the measured peak into two, and none can manufacture a peak in a flat landscape.

---

## The curvature number is a certificate, not a coincidence

The other headline number is the fitted quadratic coefficient — the $c = -0.18, -0.25, -0.44$ that made "concave in all three strata" a defensible sentence. But that number is not the second derivative of anything. It is an inner product: you project the measured profile onto a quadratic that has been arranged to be orthogonal to constants and to the linear trend on your grid, and read off the coefficient. Could that inner product come out negative for a reason having nothing to do with concavity — some accident of the grid?

It could not, and here is why.

> **Sign theorem.** Let $g$ be concave, let $t_0,\dots,t_{n-1}$ be any finite set of sample points in its domain, and let $q(y) = (y - r_1)(y - r_2)$ be a quadratic with two real roots which is orthogonal, on that sample set, to constants and to the identity — that is, $\sum_i q(t_i) = 0$ and $\sum_i t_i\, q(t_i) = 0$. Then
> $$\sum_{i} g(t_i)\, q(t_i) \;\le\; 0,$$
> strictly if $g$ is strictly concave and some sample point avoids both roots.

The proof is a small gem. Subtract from $g$ the chord through the two *roots* of $q$. Orthogonality means the chord — being affine — contributes exactly nothing to the sum, so the sum is unchanged. But the residual $g - (\text{chord through } r_1, r_2)$ has a completely rigid sign pattern for a concave $g$: it is $\ge 0$ between the roots, and $\le 0$ outside them, on both sides. And $q$ itself has *exactly the opposite* pattern: negative between its roots, positive outside. So every single term of the sum is a product of opposite signs, hence $\le 0$. Add them up.

Two consequences make this practically useful. First, the equal-width bin grid actually used in measurement really does carry such a quadratic, explicitly: with $n$ bins of width $h$ centred at $m$, the quadratic
$$q(y) = (y-m)^2 - h^2 V(n), \qquad V(n) = \frac{1}{n}\sum_{i=0}^{n-1}\Big(i - \frac{n-1}{2}\Big)^2,$$
is orthogonal to constants and to the identity for **every** $h$ and **every** $m$ — the odd moments of a symmetric grid vanish by the reflection $i \mapsto n-1-i$, and the mean-square offset is subtracted off by construction. Second, an affine profile scores exactly $0$ against it.

Putting it together with the concavity of $L_c$:

> **The geometric channel predicts a strictly negative fitted curvature, at every bin count $n\ge 3$, every bin width $h>0$ and every grid centre $m$ with the grid inside the window.**

That is the pre-registered robustness probe — permute the bin widths, shift the grid — passed, not empirically but as a theorem. The measured negative curvature in every stratum is a genuine certificate of concavity of $\log(j^2-N)$, and cannot be a grid accident.

At this point the suspect looks guilty. Then you ask about the peak's location.

---

## The alibi

Where does the geometric hump peak? Not where it was measured. And not by a little.

> **The vertex is always left of centre.** For every aspect ratio $c \ge 0$ and every window $0 < a < b$, the vertex $\xi$ of the chord-referenced hump of $\log(j^2-N)$ satisfies
> $$\xi < \frac{a+b}{2}.$$
> Equivalently, its relative position $(\xi - a)/(b-a)$ is strictly less than $1/2$.

The analytic engine behind this is a sharp and classical inequality, worth stating on its own: for $t > 1$,
$$\frac{2(t-1)}{t+1} < \log t,$$
which one proves by noting that the difference $\log t - 2(t-1)/(t+1)$ vanishes at $t=1$ and has derivative $(t-1)^2/\big(t(t+1)^2\big) > 0$. Rescaled, it says that the *logarithmic mean* of two distinct positive numbers,
$$\mathrm{LM}(p,q) = \frac{q-p}{\log q - \log p},$$
is strictly below their arithmetic mean. Apply that to both logarithmic factors of $L_c$, and the slope of the profile at the window's midpoint turns out to be strictly *less* than the chord slope. Since the slope is strictly decreasing, the point where the two agree — the vertex — must lie strictly to the left of the midpoint.

The measurement says $0.5901$. To the *right* of centre. So:

> **The measured vertex is not producible by the window geometry.** No choice of $N$, of window, or of aspect ratio yields a chord-referenced geometric vertex at relative position $0.5901$.

You might hope for a near miss — geometry predicting, say, $0.49$, and the discrepancy being noise. It is not a near miss. In the degenerate aspect ratio the vertex is exactly the logarithmic mean of the window's endpoints, and its relative position is at most $1/\log(b/a)$. In the sieve's own regime, where the window spans from $1/M$ up to $1$, this is roughly $1/\log M$ — which *collapses onto the left edge* as the window grows. The geometry does not merely fail to reach $0.59$; it runs the other way, and faster the larger the problem.

And the vertex is not free to wander, either. There is a rigidity statement that explains a striking numerical observation — that the vertex barely moves when the aspect ratio is varied across nine orders of magnitude:

> **Two-sided pin.** The vertex satisfies
> $$\mathrm{LM}(a,b) \;\le\; \xi \;\le\; \mathrm{LM}(a+2c,\,b+2c) - 2c \;<\; \frac{a+b}{2}.$$

The lower bound involves no $c$ at all. That is the theorem behind the observed insensitivity. Both bounds come from a single monotonicity — *shift rigidity of the logarithmic mean*, $\mathrm{LM}(a,b) + t \le \mathrm{LM}(a+t, b+t)$ for $t \ge 0$: translating both endpoints raises the logarithmic mean by *more* than the translation. That in turn rests on the classical inequality that the geometric mean lies below the logarithmic mean,
$$\sqrt{pq}\,\big(\log q - \log p\big) < q - p \qquad (0 < p < q),$$
which itself reduces, after substituting $s = \sqrt{q/p}$, to the elementary $\log s < \tfrac{1}{2}\big(s - 1/s\big)$ for $s>1$.

One last control closes off the obvious alternative: if the window profile had been a plain quadratic with no logarithm in it, the chord-referenced deviation would be $-(x-a)(x-b)$, whose maximum sits *exactly* at the midpoint. So $0.5901$ is not that either.

---

## What a split verdict is worth

The verdict on the geometric channel is therefore not "yes" and not "no". It is:

**It explains the sign. It cannot place the vertex.**

The concavity of $\log(j^2 - N)$ across the window forces a one-signed interior surplus with deficits at both edges and a single peak; it forces the measured curvature to be negative at every bin width and grid offset; controls fit to exactly zero. Every one of those measured features is a genuine signature of the polynomial's shape. But the same geometry, with total rigidity and across every possible parameter setting, puts the apex left of centre and drives it toward the left edge as windows grow — while the measurement, replicated to four digits, puts it right of centre.

It is tempting to see this as a disappointment. It is the opposite. In an investigation of this kind the expensive mistake is not failing to find the answer; it is *finding a plausible one and building on it*. The composition suspects died on counting grounds. The geometric suspect has now been shown to be responsible for the shape and demonstrably innocent of the location. What remains is a much sharper question than the one we started with — not "what makes the hump?" but "what moves a vertex that all the available geometry pins to the left edge, over to $0.59$?"

That is a question about an interaction not yet in the model. And it is a far better question to have, because unlike the one we started with, we now know exactly what an answer to it has to do.

The suspect had a hand in it. The suspect has an alibi. And the case is now narrow enough to be worth reopening.
