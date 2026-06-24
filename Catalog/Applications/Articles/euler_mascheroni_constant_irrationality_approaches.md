# The Constant That Refuses to Confess

## A number born from the gap between sums and curves

Add up the reciprocals of the whole numbers, one after another:

$$H_n = 1 + \frac{1}{2} + \frac{1}{3} + \cdots + \frac{1}{n}.$$

This is the *harmonic sum*. Schoolchildren meet its first few terms; analysts know it grows without bound, but agonizingly slowly. By the time you have added a thousand terms, you have barely passed $7$. After a million terms you are not yet at $15$. The harmonic sum crawls to infinity at the pace of a logarithm: $H_n \approx \ln n$.

But "approximately" hides a secret. The difference between the harmonic sum and the natural logarithm does *not* fade away. It settles, with uncanny stubbornness, onto a single fixed number:

$$\gamma = \lim_{n \to \infty} \big( H_n - \ln n \big) = 0.5772156649\ldots$$

This is the **Euler–Mascheroni constant**, one of the most famous numbers in mathematics — and one of its deepest unsolved mysteries. We do not know whether $\gamma$ is rational or irrational. We do not know whether it is the ratio of two whole numbers, like $\tfrac{22}{7}$, or whether, like $\pi$ and $e$, it forever escapes such a description. After three centuries of effort, $\gamma$ has refused to confess.

This article tells the story of $\gamma$ from a particular angle: as a number that can be *built out of positive pieces*, pictured as the *area trapped between a staircase and a curve*, and squeezed between rational-flavored approximations from above and below. Each of these pictures is exact. Together they explain, with surprising clarity, *why* the irrationality question is so hard — and what a future proof would have to look like.

## Turning a difference into a sum of positive bricks

The definition of $\gamma$ as a *limit of differences* is awkward. Differences can be positive or negative; they wobble; they are hard to control. The first idea of our story is to rewrite $\gamma$ as a **sum of strictly positive terms**, each one a clean, self-contained brick.

Here is the brick. For each whole number $k = 0, 1, 2, \ldots$ define

$$g_k = \frac{1}{k+1} - \Big( \ln(k+2) - \ln(k+1) \Big).$$

The first part, $\frac{1}{k+1}$, is one term of the harmonic sum. The second part, $\ln(k+2) - \ln(k+1) = \ln\!\big(1 + \tfrac{1}{k+1}\big)$, is the slice of logarithm that "should" cancel it. The claim is that these bricks stack up exactly to $\gamma$:

$$\boxed{\ \gamma = \sum_{k=0}^{\infty} g_k = \sum_{k=0}^{\infty}\left( \frac{1}{k+1} - \ln\frac{k+2}{k+1}\right).\ }$$

Why does this work? The logarithms **telescope**. When you add up the first $n$ of them, almost everything cancels:

$$\sum_{k=0}^{n-1}\big(\ln(k+2) - \ln(k+1)\big) = \ln(n+1) - \ln 1 = \ln(n+1).$$

So the partial sum of the first $n$ bricks is *exactly*

$$\sum_{k=0}^{n-1} g_k = H_n - \ln(n+1),$$

which is precisely the kind of quantity whose limit defines $\gamma$. The series doesn't approximate $\gamma$ — it *is* $\gamma$, brick by brick.

The beauty of the bricks is that **every one of them is strictly positive**. This is not obvious from the formula, but it follows from one of the most reliable inequalities in analysis: for any positive $x \neq 1$,

$$\ln x < x - 1.$$

The logarithm always lies below its tangent line. Apply this with $x = \frac{k+2}{k+1}$, so that $x - 1 = \frac{1}{k+1}$, and you get $\ln\frac{k+2}{k+1} < \frac{1}{k+1}$ — exactly the statement that $g_k > 0$. Each brick has genuine, positive thickness.

That single fact transforms the character of $\gamma$. A constant once defined by a delicate cancellation is now an honest infinite sum of positive quantities, climbing monotonically toward its limit. The partial sums

$$\ell_n = H_n - \ln(n+1)$$

form a **strictly increasing** sequence, every one of them a true *underestimate* of $\gamma$.

## A staircase, a curve, and the area between them

Positive bricks beg for a picture, and there is a gorgeous one. Each brick is literally an **area**.

Look at the function $f(x) = 1/x$ on the interval from $k+1$ to $k+2$ — a single unit-wide window. Over that window, draw two things: the flat horizontal line at height $\frac{1}{k+1}$ (the value of $1/x$ at the *left* edge of the window), and the descending curve $1/x$ itself. Because $1/x$ is decreasing, the curve dips below the flat line everywhere inside the window. The sliver of area trapped between them is exactly the brick:

$$g_k = \int_{k+1}^{k+2}\left(\frac{1}{k+1} - \frac{1}{x}\right)\,dx.$$

This is no coincidence; it is calculus. The integral of the constant $\frac{1}{k+1}$ over a unit interval is just $\frac{1}{k+1}$, and the integral of $\frac{1}{x}$ is the difference of logarithms $\ln(k+2) - \ln(k+1)$. Subtract, and you recover $g_k$ exactly. The integrand $\frac{1}{k+1} - \frac{1}{x}$ is nonnegative throughout the window precisely because $x \ge k+1$ forces $\frac{1}{x} \le \frac{1}{k+1}$ — the same positivity, now visible as a geometric fact about a curve sitting under a line.

Summing the slivers across every window gives the celebrated **integral representation**:

$$\gamma = \sum_{k=0}^{\infty}\int_{k+1}^{k+2}\left(\frac{1}{k+1} - \frac{1}{x}\right)dx = \int_1^\infty\left(\frac{1}{\lfloor x\rfloor} - \frac{1}{x}\right)dx.$$

Here $\lfloor x \rfloor$ is the *floor* function — the greatest integer not exceeding $x$. On each window $[k+1, k+2)$ it holds the constant value $k+1$, so the flat-line height is exactly $\frac{1}{\lfloor x\rfloor}$. The Euler–Mascheroni constant is, quite literally, the **total area trapped between the descending staircase $1/\lfloor x\rfloor$ and the smooth hyperbola $1/x$**, all the way out to infinity. A number that began as the residue of a stubborn limit is revealed as a tangible, shaded region of the plane.

## Trapping $\gamma$ from both sides

If the staircase uses the *left* edge of each window, it overshoots the curve and the gap is positive — that is the lower approximation $\ell_n = H_n - \ln(n+1)$. There is a twin construction using $\ln n$ instead of $\ln(n+1)$:

$$u_n = H_n - \ln n.$$

This sequence approaches $\gamma$ from *above*. Together the two sequences form a vise:

$$\ell_n = H_n - \ln(n+1) \;<\; \gamma \;<\; H_n - \ln n = u_n.$$

Both jaws are built from the same raw material: the harmonic number $H_n$, which is a perfectly ordinary *rational* number (a ratio of whole numbers), nudged by a logarithm. The width of the vise — the distance between the two jaws — can be computed exactly:

$$u_n - \ell_n = \ln(n+1) - \ln n = \ln\!\Big(1 + \frac{1}{n}\Big).$$

This width shrinks to zero as $n$ grows, so the trap closes and $\gamma$ is pinned. Moreover the trapping is *effective*: for any specific $n$ you can write down explicit numbers bracketing $\gamma$, with a guaranteed error smaller than $\ln(1 + 1/n)$. For instance, the lower approximant's error obeys

$$\big| \ell_n - \gamma\big| < \ln\!\Big(1 + \frac{1}{n}\Big),$$

a fully concrete, computable bound. With $n = 100$ the gap is already below $0.01$; the machinery hands you honest digits of $\gamma$ on demand.

## Why the constant keeps its secret

Here, at last, is the punchline of the whole story — and the reason $\gamma$'s rationality is still open.

To prove a number *irrational*, the classic strategy is to approximate it astonishingly well by fractions. The logic is a kind of trap of its own: if a number $x$ were rational, say $x = p/q$, then no fraction with a *smaller* denominator could get closer than $1/q$ without equalling it. So if you can produce fractions hugging $x$ closer than their denominators "allow," $x$ cannot be rational. This is exactly how Apéry stunned the world in 1978 by proving $\zeta(3) = \sum 1/n^3$ irrational: he built rational approximations that converged *geometrically* fast.

The vise around $\gamma$ looks tantalizingly similar — two sequences closing in from both sides. But it has a fatal flaw. **The jaws are not rational.** Each one is $H_n$ (rational) *minus a logarithm* (transcendental). The presence of $\ln n$ or $\ln(n+1)$ means we are not squeezing $\gamma$ between *fractions* at all; we are squeezing it between transcendental numbers. The irrationality argument never gets off the ground.

Worse, even the *speed* is wrong. The trap width $\ln(1 + 1/n)$ shrinks only like $1/n$ — a snail's pace compared to the geometric convergence that powers the irrationality proofs of $e$ and $\zeta(3)$. To crack $\gamma$, one would need approximations that are simultaneously *rational*, *fast*, and *controllably good* — a combination no one has found.

This is the genuine content of the mystery, made precise. One can show, using a classical result about how well any number can be approximated by rationals (Dirichlet's approximation theorem), that **$\gamma$ is irrational if and only if there exist arbitrarily good nonzero integer "linear forms"** $q\gamma - p$ — that is, if and only if some sequence of whole-number combinations of $\gamma$ and $1$ can be driven below any tolerance without ever hitting zero. The series and integral representations of this article supply an endless stream of excellent approximants — but they all carry that fatal logarithm. They are non-rational by construction. The obstruction to proving $\gamma$ irrational is *not* a shortage of formulas; it is the **non-rational nature of the approximants** the formulas produce.

## The staircase climbs forever

Step back and survey what these few clean facts accomplish. The Euler–Mascheroni constant, defined by a fragile cancellation between a divergent sum and a divergent logarithm, has been rebuilt three ways:

- as a **convergent series of positive bricks**, $\gamma = \sum_k \big(\tfrac{1}{k+1} - \ln\tfrac{k+2}{k+1}\big)$, climbing monotonically to its limit;
- as a **geometric area**, the shaded region trapped between the descending staircase $1/\lfloor x\rfloor$ and the smooth curve $1/x$ from $1$ to infinity;
- as the **center of a closing vise** $H_n - \ln(n+1) < \gamma < H_n - \ln n$, with an explicit, computable width $\ln(1 + 1/n)$.

And from these pictures emerges the sharpest possible statement of our ignorance. The reason $\gamma$ will not confess to being rational or irrational is now nameable: every natural approximation to it is a rational number contaminated by a transcendental logarithm, and the contamination is exactly what blocks every known proof technique.

This same machinery hints at a whole hidden hierarchy. The constant $\gamma$ is the *zeroth* of an infinite family — the **Stieltjes constants** — that arise from comparing sums like $\sum_{k\le n} \frac{(\ln k)^m}{k}$ against the matching integral $\int \frac{(\ln x)^m}{x}\,dx = \frac{(\ln x)^{m+1}}{m+1}$. The case $m = 0$ is precisely the staircase-versus-curve comparison that produced $\gamma$. The higher constants encode the fine structure of the Riemann zeta function near its pole, and almost nothing is known about their arithmetic either.

So the harmonic staircase climbs forever, always a hair's breadth above the logarithm, and the gap between them — that single number $0.5772156649\ldots$ — keeps its oldest secret. We have learned to draw it, to sum it, to trap it as tightly as we like. What we have not learned is whether it is, at heart, a fraction. The constant that refuses to confess is still waiting for someone to ask the right question.
