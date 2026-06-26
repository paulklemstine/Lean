# The Constant That Refuses to Be Pinned Down

There is a number that sits quietly at the crossroads of nearly every branch of mathematics. It governs how quickly the simplest infinite sum in the world piles up, it appears in the study of prime numbers, in the behavior of the Riemann zeta function, in physics, in probability, and in the analysis of algorithms. It has a name — the **Euler–Mascheroni constant**, written $\gamma$ — and a value that begins

$$\gamma = 0.5772156649015328606\ldots$$

And yet, after more than two and a half centuries of study, nobody on Earth knows whether $\gamma$ is a fraction.

That last sentence deserves a second reading. We know $\gamma$ to hundreds of billions of decimal places. We can compute it faster than almost any other "interesting" constant. But the most elementary question one can ask about a number — *is it a ratio of two whole numbers, or not?* — remains completely open for $\gamma$. By contrast, we have known for centuries that $\pi$ and $e$ are irrational (in fact transcendental). The constant $\gamma$ has stubbornly resisted.

This article is about what we *do* know — and it is a surprising amount. We will build $\gamma$ from scratch, watch it emerge as the sum of a tidy infinite series, see it reincarnated as an area under a staircase-shaped curve, measure exactly how fast our best approximations close in on it, meet its lesser-known siblings (the Stieltjes constants), and finally arrive at a precise statement of *what an irrationality proof would have to accomplish*. Every result described here has been verified down to the last logical step.

## Where $\gamma$ comes from

Start with the most familiar divergent sum in mathematics, the **harmonic series**:

$$H_n = 1 + \frac{1}{2} + \frac{1}{3} + \cdots + \frac{1}{n}.$$

Add up the reciprocals of the whole numbers, and the total grows without bound — slowly, but relentlessly. The eighteenth-century insight, due to Leonhard Euler, is that the harmonic numbers grow at almost exactly the rate of the natural logarithm. If you subtract $\ln n$ from $H_n$, the runaway growth cancels and you are left with a number that *settles down* to a finite limit:

$$\gamma = \lim_{n \to \infty} \big( H_n - \ln n \big).$$

Picture it as a race between two runners. The harmonic runner takes discrete steps of size $1, \tfrac12, \tfrac13, \dots$; the logarithm runner glides smoothly. They keep pace forever, but the discrete runner is always a fixed distance ahead — and that fixed distance, the eternal gap between the staircase and the ramp, is $\gamma$.

This is a beautiful definition, but it is a *limit*. A limit is a promise about the far future; it does not, by itself, hand you the number on a plate. The first thing we want is to convert this promise into something you can actually sum.

## A staircase of positive pieces

Here is the first key result. The constant $\gamma$ is not just a limit — it is an honest **convergent series of strictly positive terms**:

$$\gamma = \sum_{k=0}^{\infty} \left( \frac{1}{k+1} - \ln\frac{k+2}{k+1} \right).$$

Let us unpack the $k$-th term, which we will call $g_k$:

$$g_k = \frac{1}{k+1} - \big(\ln(k+2) - \ln(k+1)\big) = \frac{1}{k+1} - \ln\!\left(1 + \frac{1}{k+1}\right).$$

Why is each $g_k$ positive? Because of a single, evergreen inequality: the logarithm always lies below its tangent line at $1$, so $\ln(1+x) < x$ for every positive $x$. Setting $x = \tfrac{1}{k+1}$ gives exactly $g_k > 0$. Every term is a genuine positive contribution; nothing ever cancels.

The magic is in how the partial sums collapse. The logarithmic pieces *telescope*: when you add $\ln(k+2) - \ln(k+1)$ for $k = 0, 1, \dots, n-1$, almost everything cancels and you are left with just $\ln(n+1)$. Meanwhile the reciprocals add up to $H_n$. So the sum of the first $n$ terms is precisely

$$\sum_{k=0}^{n-1} g_k = H_n - \ln(n+1).$$

This identity is exact — not approximate, not "in the limit," but on the nose for every $n$. And because each term is positive, these partial sums climb *monotonically* toward $\gamma$ from below, never overshooting. We have turned a delicate cancellation between two diverging quantities into a clean, increasing staircase whose steps are all positive and whose summit is $\gamma$.

This is what mathematicians mean by a "series acceleration": the rational engine driving the approximation is the harmonic number $H_n$, gently corrected by a single logarithm $\ln(n+1)$.

## The same number, hidden under a curve

Series are one way to see a number; integrals are another. The second key result re-expresses each term of our series as an **area**.

Consider the function $\tfrac{1}{k+1} - \tfrac{1}{x}$ on the unit interval from $x = k+1$ to $x = k+2$. At the left endpoint, $x = k+1$, the two pieces are equal and the function is zero; as $x$ increases, $\tfrac{1}{x}$ shrinks and the function becomes positive. Integrating it across that one-unit window gives exactly our term:

$$g_k = \int_{k+1}^{\,k+2} \left( \frac{1}{k+1} - \frac{1}{x} \right) dx.$$

Summing over all the windows, the whole constant becomes a single sweeping integral:

$$\gamma = \sum_{k=0}^{\infty} \int_{k+1}^{\,k+2} \left( \frac{1}{k+1} - \frac{1}{x} \right) dx = \int_{1}^{\infty} \left( \frac{1}{\lfloor x \rfloor} - \frac{1}{x} \right) dx.$$

Here $\lfloor x \rfloor$ is the floor function — the largest whole number not exceeding $x$. So $\gamma$ is the total area trapped between two curves: the smooth hyperbola $\tfrac{1}{x}$ and the *staircase* $\tfrac{1}{\lfloor x \rfloor}$ that holds each reciprocal flat across each unit interval. The integrand is never negative (the staircase always sits on top of the hyperbola), which is the continuous mirror of the term-positivity we saw in the series. Two completely different pictures — a sum of discrete jumps and a continuous area — describe the very same number, term by term.

## How fast can we get there?

Knowing $\gamma$ is a sum is one thing; knowing *how quickly* the sum converges is what makes it useful. The third key result is an **effective error bound** — a guarantee, valid for every $n \geq 1$, that pins down how close the $n$-th approximation $H_n - \ln(n+1)$ gets to $\gamma$:

$$0 < \gamma - \big(H_n - \ln(n+1)\big) < \ln(n+1) - \ln n < \frac{1}{n}.$$

Read this from left to right. The first inequality says the approximation always *undershoots* — we are climbing from below. The middle quantity, $\ln(n+1) - \ln n = \ln\!\left(1 + \tfrac1n\right)$, is the exact width of the smallest interval we can currently trap $\gamma$ in. And the same tangent-line inequality as before, $\ln(1+x) < x$, collapses that width to the clean rational bound $\tfrac{1}{n}$.

In plain terms: to know $\gamma$ to within one part in a thousand, sum a thousand terms. The error shrinks like $1/n$ — steady, predictable, and fully certified. There is a companion two-sided approximant, $H_n - \ln n$, which *overshoots* $\gamma$ by the same margin. Together the pair forms a vise:

$$H_n - \ln(n+1) \;<\; \gamma \;<\; H_n - \ln n,$$

and the jaws of the vise close at rate $1/n$.

## The family $\gamma$ belongs to

Our constant turns out to be the eldest child in a whole dynasty of numbers called the **Stieltjes constants**, $\gamma_0, \gamma_1, \gamma_2, \dots$. They are defined by a pattern that generalizes the harmonic-minus-logarithm recipe:

$$\gamma_m = \lim_{n \to \infty} \left( \sum_{k=1}^{n} \frac{(\ln k)^m}{k} - \frac{(\ln n)^{m+1}}{m+1} \right).$$

These constants are the genetic code of the **Riemann zeta function** — the central object of analytic number theory, woven into the deepest unsolved problem in mathematics, the Riemann Hypothesis. Near its singular point at $s = 1$, the zeta function unfolds in a series whose coefficients are exactly the Stieltjes constants:

$$\zeta(s) = \frac{1}{s-1} + \sum_{m=0}^{\infty} \frac{(-1)^m}{m!}\,\gamma_m\,(s-1)^m.$$

The fourth key result is that the very first of these, the zeroth Stieltjes constant, *is* the Euler–Mascheroni constant: $\gamma_0 = \gamma$. When you set $m = 0$ in the recipe, the powers $(\ln k)^0$ all equal $1$, the sum becomes $H_n$, and the correction term becomes $\ln n$ — recovering $H_n - \ln n$, the upper approximant we just met. There is one tiny corner to handle carefully (the formula misbehaves at $n = 0$, where $\ln 0$ is undefined), but for every $n \geq 1$ the identity is exact, and the limit lands precisely on $\gamma$. So $\gamma$ is not an isolated curiosity; it is the anchor of an infinite tower of constants that the zeta function is built from.

## And finally: the question we cannot answer

We now return to the mystery. Is $\gamma$ rational or irrational? Rather than throw up our hands, mathematics gives us a way to state *exactly what a proof would have to deliver*.

The tool is a clean characterization of irrationality through how well a number can be approximated by fractions. The intuition is this: a rational number $a/b$ is "rigid." If you take any whole-number combination $q \cdot \tfrac{a}{b} - p$ that is not exactly zero, it cannot be tiny — it is at least $1/b$ in size, because it is a nonzero multiple of $1/b$. There is a hard floor. An irrational number has no such floor: you can find whole numbers $q \geq 1$ and $p$ making $q x - p$ as close to zero as you like, while never actually hitting zero. This is the content of a classical result of Dirichlet, and it gives a crisp test:

> A real number $x$ is irrational **if and only if** for every tolerance $\varepsilon > 0$ there exist whole numbers $q \geq 1$ and $p$ with
> $$0 < \lvert q x - p \rvert < \varepsilon.$$

Specialized to our constant, this says: $\gamma$ is irrational precisely when arbitrarily small but never-zero integer combinations $q\gamma - p$ exist. That is the exact target. An irrationality proof of $\gamma$ must manufacture such combinations.

So why is it so hard? Here lies the crux, and it is genuinely illuminating. Our best approximations to $\gamma$ trap it between $H_n - \ln(n+1)$ and $H_n - \ln n$, and that interval shrinks to a single point. You might think we are done — the trap closes perfectly. But look at the endpoints: each one carries a *logarithm*. They are not fractions. The rigid, rational data the irrationality test demands is exactly what our logarithm-laden approximants fail to provide. The trap is beautiful and it works, but it is built from the wrong material.

This is the structural reason $\gamma$ has resisted while $e$ and $\zeta(3)$ (the latter cracked by Apéry in 1978) fell. It is not that $\gamma$ is approximated *slowly* — though at rate $1/n$ it is far slower than the geometric rates that power famous irrationality proofs. It is that the approximants are transcendental mixtures of reciprocals and logarithms, not the clean ratios of integers an irrationality argument can grip.

## What we are left with

The Euler–Mascheroni constant is a humbling object. It is utterly concrete — a sum of positive terms, an area under a staircase, a number you can compute to a trillion digits over lunch. We can bracket it as tightly as we please, and we know exactly how fast our brackets close. We know its place in the grand architecture of the zeta function. And yet the single most basic question about it stands open, with a clear diagnosis of *why*.

Sometimes mathematics advances by answering a question. Sometimes it advances by understanding, with total precision, the shape of the wall in front of it. Everything above — the positive series, the integral over the staircase, the certified $1/n$ error, the link to the Stieltjes family, and the exact Diophantine target for irrationality — is a map of that wall, drawn with full rigor. The door in it has not yet been found. But we now know precisely what the key must look like.
