# Peeling the Onion in High Dimensions

## How many layers of a ball are "too thick"? Fewer than anyone guessed — and the answer runs backwards in the dimension.

### An onion with equal layers

Take a ball of radius $R$ and cut it into $N$ layers, like an onion — but insist on one rule: every layer must contain **exactly the same volume**. One $N$-th of the ball each, no more, no less.

In the plane this is easy to picture. Draw circles of radii
$$r_0 = R,\quad r_1,\quad r_2,\ \ldots,\ r_N = 0,$$
chosen so that each annulus between consecutive circles has area $\pi R^2/N$. In $d$ dimensions the same demand has a single clean solution. Since the volume of a ball of radius $r$ scales like $r^d$, requiring the ball of radius $r_k$ to hold exactly a fraction $1 - k/N$ of the total volume forces

$$r_k \;=\; R\left(1 - \frac{k}{N}\right)^{1/d}, \qquad k = 0, 1, \dots, N.$$

We call this the **equal-volume peeling** of the ball. The $k$-th shell is the region between the spheres of radii $r_{k+1}$ and $r_k$, and its **thickness** — the distance you would travel walking straight through it towards the centre — is

$$t_k \;=\; r_k - r_{k+1}.$$

The layers all have equal volume, but they emphatically do not have equal thickness. In high dimensions the outer layers are gossamer-thin skins, and the inner ones are fat. That is not a defect of the construction; it is the geometry of high-dimensional space announcing itself. Almost all of the volume of a high-dimensional ball sits in a whisper-thin rind near the surface, so a layer that must hold a full $1/N$ of the volume can afford to be extremely thin out there — while near the centre, where there is hardly any volume to be had, the same quota demands a thick slab.

Here is the phenomenon in numbers, for a unit ball in dimension $4$ cut into $12$ equal-volume shells:

| shell $k$ | 0 | 1 | 2 | ... | 9 | 10 | 11 |
|---|---|---|---|---|---|---|---|
| thickness $t_k$ | 0.0215 | 0.0230 | 0.0248 | ... | 0.0682 | 0.1017 | **0.5373** |

The innermost shell is twenty-five times thicker than the outermost, and by itself it accounts for more than half the radius. Yet all twelve have exactly the same volume.

### A budget, and a question

Now suppose you are handed a **thickness budget** $\delta > 0$ and told: no layer may be thicker than $\delta$. Perhaps you are quantising a radial coordinate and $\delta$ is your resolution; perhaps $\delta$ is the tolerance of a manufacturing process; perhaps, as we will see, $\delta$ is the granularity of a random sampler and you need every cell of your partition to be small.

Two questions immediately present themselves.

1. **How many layers do you need** before *every* layer respects the budget?
2. If you use fewer, **how many layers break the budget**?

The first question has a startlingly clean answer. The second has an answer that is clean, surprising, and — as it turns out — the opposite of what one would naively guess.

### The thickest layer is the innermost one

Everything follows from a single structural fact, which is visible in the table above and true in general:

> **Monotonicity Theorem.** In every equal-volume peeling, thicknesses increase towards the centre: $t_0 \le t_1 \le \cdots \le t_{N-1}$.

Consequently the layers that break the budget are never scattered through the onion. They form a solid **terminal block**: there is a threshold index $k_0$ such that a layer is thick precisely when its index is at least $k_0$. An equal-volume peeling always looks the same — an outer stack of obedient thin skins, and an inner core of offenders.

The champion offender can be computed exactly. The innermost shell runs from radius $0$ up to $r_{N-1} = R\,N^{-1/d}$, so

> **Innermost Shell Theorem.** $t_k \le R\,N^{-1/d}$ for every $k$, with equality at $k = N-1$.

The upper bound comes from the *subadditivity* of the root function $x \mapsto x^{1/d}$: since $a^{1/d} \le b^{1/d} + (a-b)^{1/d}$ for $0 \le b \le a$, and consecutive shells differ by exactly $1/N$ in normalised volume, no single shell can be thicker than the shell that reaches all the way to the origin.

And that immediately answers the first question. Every layer respects the budget if and only if the worst one does, i.e. if and only if $R\,N^{-1/d} \le \delta$:

> **Threshold Theorem.** Every shell of the $N$-shell equal-volume peeling has thickness at most $\delta$ **if and only if**
> $$N \;\ge\; \left(\frac{R}{\delta}\right)^{d}.$$
> The least admissible number of shells is exactly $\max\{1, \lceil (R/\delta)^d\rceil\}$.

This is the "exponentially many skins" part of the story, and the base of the exponential is precisely $R/\delta$ — the ratio of the size of the object to the resolution you demand. Want millimetre layers in a metre ball in dimension $20$? You need $1000^{20} = 10^{60}$ of them.

Take the logarithm and the exponential turns into something a computer scientist recognises instantly. Writing $\log_2$ for the base-two logarithm,

> **Bit-Cost Theorem.** For $0 < \delta \le R$, the number of bits needed to index the shells of the smallest budget-respecting peeling satisfies
> $$d\log_2\!\frac{R}{\delta} \;\le\; \log_2 N_{\min} \;\le\; d\log_2\!\frac{R}{\delta} + 1 .$$

So the quantity $d\log(R/\delta)$ — the natural guess for "how many thick layers there are" — really lives somewhere else entirely. It is not a count of anything geometric. It is the **bit cost of addressing** a budget-respecting peeling: $d$ coordinates, each to precision $R/\delta$, one bit of slack for the ceiling. That reinterpretation is one of the small pleasures of this subject: a formula that looks wrong as an answer to one question turns out to be exactly right as the answer to a different one.

### Counting the offenders

Now the second question: with $N$ layers, how many break the budget? Write
$$T(N) \;=\; \#\{\,k < N : t_k > \delta \,\}.$$

The naive expectation, given the exponential in the threshold theorem, is that $T$ should also carry a factor of $d$ — more dimensions, more pathology. The truth runs the other way.

The engine is a pair of two-sided per-shell estimates, and they are worth stating because they carry all the content.

> **Per-Shell Sandwich.** For every $k < N$,
> $$\frac{R}{dN} \;\le\; t_k, \qquad\text{and}\qquad t_k \;\le\; \frac{R}{d\,(N-k-1)} \quad\text{whenever } k+1 < N .$$

The lower bound says no shell is ever thinner than the "average" $R/(dN)$ predicted by the $1/d$ scaling law — the thin skins are thin, but not arbitrarily thin. The upper bound says a shell can only be thick when it is close to the centre: at inner depth $N-k$, the thickness cannot exceed $R/(d(N-k-1))$, a quantity that decays as you move outwards.

Both come from calculus in disguise. The derivative of $x \mapsto x^{1/d}$ is $x^{1/d}/(dx)$, and Bernoulli's inequality turns that infinitesimal statement into the exact finite-difference bounds
$$\frac{a-b}{d\,a}\,a^{1/d} \;\le\; a^{1/d} - b^{1/d} \;\le\; \frac{a-b}{d\,b}\,b^{1/d}, \qquad 0 < b \le a .$$
Feed in $a = (N-k)/N$ and $b = (N-k-1)/N$ and the sandwich falls out.

There is also a beautiful structural reason to expect such a thing, which is worth isolating:

> **Renormalisation Principle.** The tail of an equal-volume peeling is again an equal-volume peeling. Precisely, $r_{k+1}$ is the first sphere of the equal-volume peeling of the ball of radius $r_k$ into $N-k$ shells.

Every theorem about the *outermost* shell of a peeling therefore applies verbatim to every shell, once you rescale. The onion is self-similar: strip off any number of layers and what remains is a smaller onion, peeled the same way.

Now the counting argument writes itself. Set $c = \lfloor R/(d\delta)\rfloor + 1$. If a shell sits at least $c$ layers away from the centre, then $N - k - 1 \ge c$, so its thickness is at most $R/(dc) < \delta$: it is thin. Hence every thick shell lies in the last $c$ positions, and:

> **Counting Theorem.** Uniformly in $N$,
> $$T(N) \;\le\; 1 + \frac{R}{d\,\delta}.$$

Read the shape of that bound. It grows like $1/\delta$, not like $\log(1/\delta)$. And it **decreases** with the dimension. In high dimensions there are *fewer* thick layers, not more — a factor of $d$ in the denominator, exactly where intuition wanted it in the numerator.

Is the bound honest, or merely an artefact of a lossy argument? It is honest, and the proof of that is a one-liner: since every shell is at least $R/(dN)$ thick, choosing a budget below that value makes **all $N$ shells thick at once**. Taking $N \approx R/(2d\delta)$ produces a peeling with at least $R/(2d\delta) - 1$ offending layers. So the maximum of $T$ over all $N$ is $\Theta\big(R/(d\delta)\big)$: the bound is tight up to a factor of two.

The numbers confirm it on the nose. For the unit ball with budget $\delta = 0.01$, the largest thick-shell count over all $N$ is $50$ in dimension $2$, $20$ in dimension $5$, and $10$ in dimension $10$. The prediction $R/(d\delta) = 100/d$ gives $50$, $20$, $10$. Exact agreement.

### Two conjectures, refuted

The story began with two plausible guesses, and this analysis kills both.

The first guess was that the number of thick layers grows like $d\log(R/\delta)$. It does not. The true order, $\Theta(R/(d\delta))$, is polynomially large in $1/\delta$ rather than logarithmic, and it *falls* as the dimension rises. The refutation is concrete: fix any constant $C$ and any dimension $d$; take $N$ large and $\delta = 1/(2dN)$. Then every one of the $N$ shells is thick, while $C\,d\log(1/\delta) = C\,d\log(2dN)$ grows only logarithmically in $N$. No constant multiple of $d\log(R/\delta)$ can keep up.

The second guess was that the number of shells needed for a budget-respecting peeling grows like $(1 - \delta/R)^{-d}$. It does not; it grows like $(R/\delta)^d$. At $\delta = R/4$ the two candidate bases are $4$ and $4/3$, and $4^d$ outgrows every constant multiple of $(4/3)^d$. (The two agree only in the degenerate case $\delta = R/2$.)

What *does* survive is the qualitative picture that motivated the guesses: **exponentially many skins, boundedly many thick layers**. The collapse of an equal-volume peeling onto the boundary sphere is real. It is just governed by $(R/\delta)^d$ skins and $\Theta(R/(d\delta))$ offenders, not by the conjectured expressions.

### How the thick core dissolves

One more refinement completes the picture, and it is the most satisfying part. The counting theorem is uniform in $N$, but it is attained only for one special value of $N$. What happens in between?

> **Decay Theorem.** If at least two shells violate the budget — say $m = T(N) \ge 2$ — then
> $$(m-1)^{\,d-1}\,N \;\le\; \left(\frac{R}{d\delta}\right)^{d} .$$
> Conversely, if $j^{\,d-1} N < (R/(d\delta))^d$ for some $j \ge 1$, then at least $j$ shells are thick.

Together these two inequalities **pin the count to within one**: if
$$j^{\,d-1} N \;<\; \left(\frac{R}{d\delta}\right)^{d} \;<\; (j+1)^{\,d-1} N,$$
then $T(N)$ is either $j$ or $j+1$. For every dimension $d \ge 2$ and every $N$, the number of thick layers is determined, to within a single layer, by one number: the ratio $(R/(d\delta))^d / N$.

Qualitatively: as you cut the ball into more and more layers, the thick core shrinks like $N^{-1/(d-1)}$ — and it vanishes completely, all at once, at $N = (R/\delta)^d$, exactly where the threshold theorem said it must. In dimension $1$ the exponent $d-1$ degenerates to $0$ and the inequality reads $N \le R/\delta$, which is right: in one dimension the peeling is perfectly uniform ($t_k = R/N$ for every $k$), so either every shell is thick or none is. Both extremes of the terminal-block dichotomy are attained.

Numerically, for the unit disc with $\delta = 0.01$, so that $(R/(d\delta))^d = 2500$:

| $N$ | 50 | 100 | 200 | 400 | 1000 |
|---|---|---|---|---|---|
| thick shells $m$ | 50 | 25 | 13 | 6 | 3 |
| $(m-1)N$ | 2450 | 2400 | 2400 | 2000 | 2000 |

Every entry sits below $2500$, and near the peak it is within two percent. The inequality is not merely a bound; in the interesting range it is very nearly an identity.

### Why anyone should care

Equal-volume peelings are how you turn a continuous ball into a finite object without biasing volume — and that is a task that shows up wherever randomness meets geometry.

Consider sampling a point uniformly from a high-dimensional ball, an operation at the heart of lattice-based cryptography, randomised algorithms, and Monte Carlo integration. A natural strategy is to sample a shell index uniformly from $\{0, \dots, N-1\}$ — cheap, because the shells have equal volume, so uniform on indices is the right marginal — and then sample uniformly within the chosen shell. The quality of this sampler is governed by exactly one quantity: the thickness of the fattest shell. If every shell is thinner than $\delta$, the radial coordinate is known to precision $\delta$ and the discretisation error is controlled.

The theory above then says three concrete things to anyone building such a thing.

First, **the price of resolution is exponential and unavoidable**: you need $(R/\delta)^d$ shells, no fewer, and the threshold is exact, not an estimate. Equivalently — and this is the practical statement — the shell index costs $d\log_2(R/\delta)$ bits to store, plus at most one. That is the true home of the expression $d\log(R/\delta)$.

Second, **if you cannot afford that many shells, the damage is localised and small**. At most $1 + R/(d\delta)$ shells break the budget, they are consecutive, and they are the innermost ones. You always know where the problem is: it is a ball of radius $r_{k_0}$ around the origin, and everything outside is fine. A sampler can simply treat that inner core separately — recursively, in fact, since the tail of a peeling is a peeling.

Third, **the problem gets easier, not harder, in high dimensions**. The thick core contains at most $1 + R/(d\delta)$ of the shells, a count that shrinks as $d$ grows, and by volume it is utterly negligible: it holds a fraction $T/N$ of the ball. This is the concentration of measure phenomenon appearing in a new guise. High-dimensional geometry is often described as counterintuitive and hostile; here it is an ally, and the theorem says by exactly how much.

### The shape of the answer

Strip away the estimates and what remains is a clean structural description of an equal-volume peeling under a thickness budget:

- The layers get thicker inwards, monotonically, always.
- The offenders form a solid block at the centre, never scattered.
- There are at most $1 + R/(d\delta)$ of them, and that order is achieved.
- Their number is pinned to within one by the single ratio $(R/(d\delta))^d/N$.
- They disappear entirely, and abruptly, at $N = (R/\delta)^d$.
- Indexing a budget-respecting peeling costs $d\log_2(R/\delta) + O(1)$ bits.

Two natural conjectures fell along the way, both of them by getting the dependence on the dimension backwards. That is the recurring lesson of high-dimensional geometry: the intuitions trained in three dimensions are not merely imprecise, they frequently point the wrong way. The remedy is not better intuition but sharper inequalities — here, one convexity estimate for the $d$-th root function, applied twice, from both sides.

The onion, peeled correctly, has exactly the layers you would want, and — happily — fewer bad ones the higher you go.
