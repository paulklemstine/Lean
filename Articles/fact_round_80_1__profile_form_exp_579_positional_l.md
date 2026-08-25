# The Law Hiding in the Positions

## How a cloud of factorization "hits" turned out to obey a harmonic law — and what refused to be explained away

### A histogram that would not behave

Some datasets are shy. You plot them, you see a downward slope, you fit a curve, and the curve fits — but you never quite learn *why* that curve and not another. Then, occasionally, a dataset stops being shy. The slope turns out to be forced. Not fitted: forced.

This is the story of one such dataset. The setting is a search for the factors of semiprimes — numbers $N = pq$ that are products of two primes, the objects that sit under most of modern public-key cryptography. In the experiment behind this work, a search procedure sweeps across a range of candidate positions and occasionally registers a *hit*: a place where the search finds something useful. Across $128$ semiprimes of bit-length $96$, some $9594$ hits were recorded, each tagged with a rescaled position $x$ in a window $[0,2]$, where $x=0$ is the near end (small offsets, the "wall") and $x=2$ the far end.

Plot the hit counts against $x$ and you get a decline. Nothing shocking: everyone expects hits to thin out as you move away from the wall. The question is the *shape* of the thinning. The measured profile is well described by

$$T(x) \;\approx\; 0.0295\,(1+x)^{-1.104},$$

a power law in the shifted coordinate $1+x$, with an exponent close to one. The fit is not merely good; it is decisively better than the natural alternatives. Against an exponential decay, a logistic curve and a straight line, this power law carries essentially all of the statistical weight — about $98.7\%$ of it on the standard information-criterion scale.

But "the power law wins the fit contest" is a statement about a comparison of four families of curve. It is not a law of nature. The interesting question is whether something *forces* the power form. It turns out something does, and identifying it is the heart of this story.

### The multiplication that lives on the half-line

Here is the structural observation. On the half-line of positions, don't add — multiply the *shifted* coordinate. Define an operation

$$x \star y \;=\; (1+x)(1+y) - 1 .$$

This is just ordinary multiplication of $1+x$ and $1+y$, viewed back in the $x$-coordinate. It is associative, it has $0$ as an identity ($x\star 0 = x$), and it is the natural composition law whenever positions are measured in *relative* rather than absolute terms — when doubling the offset means the same thing wherever you start.

Now demand that the profile be *multiplicative* for this composition, normalised at the origin:

$$T(0)\,T(x\star y) \;=\; T(x)\,T(y)\qquad\text{for all } x,y > -1 .$$

In words: composing two relative offsets multiplies the corresponding hit densities, once you divide out the value at zero. The measured power law satisfies this exactly, because $(1+x\star y)^{-b} = (1+x)^{-b}(1+y)^{-b}$.

The theorem is the converse, and it is sharp.

> **Rigidity of the profile form.** Let $T$ be positive and continuous on $(-1,\infty)$ and satisfy $T(0)T(x\star y) = T(x)T(y)$ for all $x,y > -1$. Then there is a real number $b$ with
> $$T(x) \;=\; T(0)\,(1+x)^{-b}\qquad\text{for all } x > -1 .$$

There is one free parameter, the exponent, and nothing else. The amplitude is whatever the profile happens to be at the origin; the *shape* has no freedom left.

The proof is short and pretty. Substitute $x = e^u - 1$, so that $\star$ becomes plain addition of the $u$'s, and look at $g(u) = \log\bigl(T(e^u-1)/T(0)\bigr)$. Multiplicativity becomes $g(u+v) = g(u)+g(v)$: Cauchy's functional equation. Continuity — which the profile has, being a smoothly varying density — forces $g$ to be linear, $g(u) = u\,g(1)$. Undo the substitution and out comes the power law with exponent $b = -g(1)$. The exponent is also *identifiable*: two power laws with the same amplitude agreeing everywhere have the same exponent, so nothing is hidden in the parameterisation.

That is the sense in which the positional layer "gets a law". The harmonic decline is not a convenient curve. It is the unique continuous positive shape compatible with a scale-composition rule, and the experiment's job is reduced to measuring one number.

### One invariant beats three rivals at once

Statistics told us the power law wins. Can we see *why* it must beat exponentials, logistics and lines, without appealing to any dataset at all?

Yes, and with a single quantity. For a positive profile $f$ and three equally spaced points $t-h < t < t+h$, consider the **log-midpoint defect**

$$D_f(t,h) \;=\; f(t-h)\,f(t+h) - f(t)^2 .$$

Its sign tells you whether $\log f$ curves up or down. And the three rival families all have the same sign, opposite to the power law's:

- **Power law**, $f(x)=A(1+x)^{-b}$ with $A>0$, $b>0$: $D_f > 0$ strictly, whenever $h>0$ and $t-h>-1$. The reason is elementary — $(1+t-h)(1+t+h) = (1+t)^2 - h^2$ is strictly *smaller* than $(1+t)^2$, and raising a smaller positive number to a negative power makes it strictly larger.
- **Exponential**, $f(x) = Ce^{-kx}$: $D_f = 0$ exactly. Exponentials are log-affine; midpoints are exactly on the line.
- **Logistic**, $f(x) = C/(1+e^{k(x-x_0)})$ with $C>0$: $D_f \le 0$. This reduces to the arithmetic–geometric mean inequality applied to $e^{\pm kh}$.
- **Line**, $f(x) = p + qx$: $D_f = -q^2h^2 \le 0$, an exact identity requiring no positivity at all.

So the power law is *strictly log-convex at midpoints* and each rival is log-concave there. One inequality, evaluated at a single triple of points, certifies that a genuine power law ($b>0$) simply is not a member of any of the three rival families. The model-comparison verdict is underwritten by a structural fact, not only by an information criterion.

That said, the information criterion also behaves exactly as advertised. If the three rivals sit at penalties $d_1,d_2,d_3 \ge 0$ behind the winner, the winner's Akaike weight is

$$w(d_1,d_2,d_3) \;=\; \frac{1}{1 + e^{-d_1/2} + e^{-d_2/2} + e^{-d_3/2}} .$$

This is always strictly between $0$ and $1$; it increases when any rival is pushed further away; it tends to $1$ as all rivals recede; and — the crucial sanity check — if even one rival is *tied*, the weight cannot exceed $1/2$. So a weight near one is genuine evidence rather than an artefact of normalisation. With the measured gaps $9.2$, $11.5$ and $16.9$, one can prove rigorously that $w > 0.98$, matching the reported $0.987$.

### The knife-edge at exponent one

The fitted exponent is $b \approx 1.104$, and resampling the data gives the interval $[0.991,\,1.218]$. That interval contains $1$ — and $1$ is not just any number here.

Integrate the profile across a window $[0,X]$ to get the total mass it accumulates. Away from the critical exponent,

$$\int_0^X (1+x)^{-b}\,dx \;=\; \frac{(1+X)^{1-b} - 1}{1-b},$$

while exactly at $b=1$ the integral collapses to $\log(1+X)$. As the window is widened without bound, the two behaviours separate cleanly:

- for $b > 1$ the total mass converges, to $\dfrac{1}{b-1}$;
- for $b \le 1$ it diverges.

So the exponent one is the threshold at which the profile's total mass changes from infinite to finite — from "hits keep accumulating forever" to "there is a finite budget of hits and most of it is already spent". And the measurement straddles it: within the interval $[0.991,1.218]$ there are exponents (e.g. $b=1$) whose mass diverges and exponents (e.g. the point estimate $1.104$) whose mass converges. The experiment pins the *shape* of the profile beautifully and yet cannot decide this qualitative question at all. That is a genuinely useful negative result: it tells you exactly what a follow-up experiment must be powered to resolve.

The divergence is not an artefact of passing to a continuum, either. At the critical exponent the counted hits are harmonic, and the harmonic sums satisfy the classical bound

$$\log(n+1) \;\le\; \sum_{j=0}^{n-1} \frac{1}{j+1},$$

so the accumulation without bound is visible already in raw counts.

### Subtracting the expected, and finding a hump

Now for the part that started as a fitting exercise and turned into a small drama.

Number theorists have a well-known heuristic for how "smooth-number"-style quantities decline; in the crude but effective form used here, the expected background is a *uniform scale mixture of exponential regimes*,

$$M(x) \;=\; \int_0^1 e^{-xs}\,ds \;=\; \frac{1-e^{-x}}{x},$$

the average of decaying exponentials with every rate between $0$ and $1$. This mixture is itself an "exponent-one" object: for $x \ge 1$ it is squeezed between $1/(2x)$ and $1/x$.

The natural question is whether the observed profile is *just* this background. Divide and see: the residual $R = T/M$. Because $M$ sits between $1/(2x)$ and $1/x$, the residual satisfies

$$A\,x\,(1+x)^{-b} \;\le\; R(x) \;\le\; 2A\,x\,(1+x)^{-b},$$

an exact two-sided squeeze. The consequence is striking: across the window, the residual declines by at most **two-thirds** of the raw decline of the profile, for every amplitude and every exponent. The background genuinely eats the harmonic gradient. Quantitatively, the measured background falls by a factor $3.64$ across the window while the raw profile falls by $3.25$: the mixture explains essentially all of the decline, and slightly over-explains it.

So what is left? Not a flat line, and not a residual slope. What is left is a **hump**.

The residual, pinned at the measured end values $R(0)=0.80$ and $R(1)=0.90$ and fitted with a concave quadratic, is

$$\widehat R(x) \;=\; \frac{4}{5} + \frac{59}{90}x - \frac{5}{9}x^2 ,$$

whose exact concavity identity $\widehat R(0.59)-\widehat R(x) = \tfrac59(x-0.59)^2$ makes everything transparent. Its apex sits at $x = 0.59$, strictly inside the window, at height $17881/18000 \approx 0.9934$. That apex is at least $20\%$ above the near-end value and at least $10\%$ above the far-end value, and *both* ends are below $1$: the background over-predicts at the wall and over-predicts again at the far end, while under-predicting in the middle. A peaked residual is neither increasing nor decreasing across the window, and — since any power law is monotone — it is not itself of profile form. The two layers are therefore separate objects: the positional layer has a law, the leftover layer is something else.

Is the hump an artefact of one particular fit? No. Replace the single fitted parabola by the entire one-parameter family of endpoint-pinned parabolas

$$R_c(x) \;=\; \frac45 + \Bigl(\frac1{10}-c\Bigr)x + c\,x^2, \qquad c<0,$$

and a sharp threshold appears. The apex sits at $x_c = \frac{1/10-c}{-2c}$, which lies strictly inside the window — in fact in the right half $(1/2,1)$ — exactly when $c < -1/10$; at $c=-1/10$ the apex slides onto the right endpoint and for weaker curvature the fit is simply increasing across the window, with no peak at all. The measured curvature interval is $[-0.62,\,-0.14]$. Every member of it lies on the peaked side, clearing the threshold by $0.04$. The hump verdict is invariant across the reported uncertainty — and the threshold is explicit, so anyone can see how far from the edge the data sit.

### Two corrections that made the result honest

A result is only as good as the strongest objection it survives, and two objections landed.

**First objection: doesn't a hump prove the background model is wrong?** The tempting claim is that no positive mixture of decaying exponentials could ever produce an interior peak when divided into a power law. That claim is false, and the counterexample is embarrassingly simple. Take the two-atom mixture

$$M_2(x) \;=\; \tfrac12 e^{-x/20} + \tfrac12 e^{-8x}$$

— a perfectly legitimate positive mixture, with a very slow and a very fast regime — and divide the power law with $b=1.1$ by it. The result equals $1$ at $x=0$, exceeds $5/4$ at $x=0.3$, and is below $5/4$ at $x=1$: a strict interior peak. So a hump is evidence about *which* mixture, not evidence against mixtures. What the hump does certify, rigorously, is the weaker and true statement: the background is not a power-law rescaling of the profile.

**Second objection: is the hump even outside the window?** Sharper still. The *actual* uniform-mixture background produces a hump too — just not where anyone was looking. For $b = 1.1$ one can prove that the residual at $x=10$ exceeds its values at both $x=3$ and $x=100$, so on the window $[3,100]$ it has a strict interior maximum. Peakedness, it turns out, is a *window-relative* statement.

And once you know that, you want the location law. Write the residual exactly as

$$\frac{T(x)}{M(x)} \;=\; \frac{x\,(1+x)^{-b}}{1-e^{-x}} .$$

The denominator tends to $1$, so far from the origin the shape is governed by the elementary factor $x(1+x)^{-b}$, whose logarithmic derivative is

$$\frac1x - \frac{b}{1+x} \;=\; \frac{1-(b-1)x}{x(1+x)} .$$

That changes sign exactly once, giving a clean closed form:

> **Hump-location law.** For every $b>1$ the function $x(1+x)^{-b}$ has a unique maximiser on $[0,\infty)$, at
> $$x^\star \;=\; \frac{1}{b-1},$$
> increasing strictly before it and decreasing strictly after. For $b \le 1$ it is strictly increasing throughout, and no maximiser exists.

At the measured exponent $b = 1.1$ this predicts $x^\star = 10$ — exactly where the hump was found numerically. And notice which threshold governs the dichotomy: exponent one again, the very threshold the measurement straddles.

There is a second, subtler threshold. The *exact* logarithmic derivative of the true residual is

$$\frac1x - \frac{b}{1+x} - \frac{1}{e^x-1},$$

a competition between the algebraic part, positive up to $x^\star = 1/(b-1)$, and an exponential correction that blows up near the origin. As $b$ grows, $x^\star$ retreats into the region where the correction dominates, and the hump is destroyed. Using the classical Padé bound $e^x < \frac{2+x}{2-x}$ on $(0,2)$ — which yields $\frac1x - \frac12 < \frac{1}{e^x-1}$ for all $x>0$ — one proves that for **every $b \ge 3/2$ the residual is strictly decreasing on all of $(0,\infty)$**: no hump, anywhere. Combined with the proved hump at $b=1.1$, this brackets a critical exponent strictly between $1.1$ and $1.5$; numerically it is about $1.16$. And the measured interval $[0.991,1.218]$ straddles that too — a second, independent way in which the data pin the shape but not the qualitative regime.

### What the episode teaches

Three things, I think, and none of them is about semiprimes specifically.

**Fits can be upgraded to laws.** "The data like a power law" became "any continuous positive profile respecting relative-offset composition *is* a power law". That is a different kind of statement, and it changes what a follow-up experiment should measure: one number, to whatever precision the question at hand demands.

**Model comparison can be underwritten structurally.** A single midpoint-convexity inequality separates the winner from all three rivals simultaneously, with no data. When an information criterion and a structural invariant agree, the verdict is much harder to argue with.

**The interesting part of a residual is where it fails to be boring.** Subtracting a good background usually leaves noise. Here it left a shape — an interior hump, robust across the reported uncertainty — but the honest accounting also showed that humps are cheap: a two-atom mixture makes one, and the very background being used makes one, ten units to the right of the window. What survives all of that is precise and modest: the hump is real inside the window, it is not explained by a power-law rescaling, its location obeys the law $x^\star = 1/(b-1)$ whenever the exponent exceeds one, and whether a hump exists at all is decided by an exponent threshold that the current data straddle.

That last sentence is the shape of good empirical mathematics. Not "we found the answer", but "here is exactly which question remains, and here is the number you must measure to settle it".
