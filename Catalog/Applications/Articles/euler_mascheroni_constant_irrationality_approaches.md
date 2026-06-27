# Hitting the Bullseye: A Smarter Way to Corner the Euler–Mascheroni Constant

## A number that hides in plain sight

Add up the reciprocals of the whole numbers, one at a time:

$$H_n = 1 + \frac{1}{2} + \frac{1}{3} + \cdots + \frac{1}{n}.$$

This is the *harmonic sum*, and it is famously slow and famously stubborn. It
grows forever — push $n$ high enough and $H_n$ will eventually exceed any number
you name — but it grows at a glacial pace, creeping upward like the logarithm
$\ln n$. In fact, $H_n$ and $\ln n$ travel together so closely that their
*difference* settles down to a fixed number:

$$\gamma = \lim_{n \to \infty}\bigl(H_n - \ln n\bigr) = 0.5772156649\ldots$$

That number is the **Euler–Mascheroni constant**, $\gamma$. It is one of the
most quietly important constants in mathematics. It shows up when you count the
divisors of integers, when you analyze how long algorithms take to run, when
you study the Riemann zeta function and the distribution of prime numbers, and
in the special functions of physics. And yet, after more than two and a half
centuries, we still do not know something embarrassingly basic about it: nobody
has ever proved whether $\gamma$ is rational or irrational. It might be a clean
fraction $p/q$ in hiding; it might be irrational like $\pi$ or $e$. We simply
do not know.

When a number resists every theoretical attack, mathematicians do the next best
thing: they *pin it down numerically*, squeezing it between two sequences that
close in on it from opposite sides. The tighter and faster the squeeze, the
better. This article is about a small but genuinely useful improvement to that
squeeze — a trick that takes a centuries-old approximation and makes its error
shrink *quadratically* faster, just by aiming at the right target.

## The classic squeeze, and why it is slow

The definition $\gamma = \lim (H_n - \ln n)$ suggests an obvious recipe: compute
$H_n - \ln n$ for some large $n$ and call it an estimate of $\gamma$. This works,
but it is wasteful. It turns out that two very slightly different recipes bracket
$\gamma$ perfectly from both sides:

- The **lower approximant** $a_n = H_n - \ln(n+1)$ rises steadily *up* toward
  $\gamma$, always staying just below it.
- The **upper approximant** $b_n = H_n - \ln n$ falls steadily *down* toward
  $\gamma$, always staying just above it.

So for every $n$ we have the rigorous sandwich

$$a_n \;<\; \gamma \;<\; b_n,$$

and as $n$ grows, the two pieces of bread close in on the filling. This is the
classical picture, and it is completely rigorous.

The trouble is *speed*. Both $a_n$ and $b_n$ approach $\gamma$ only linearly:
their errors shrink like $1/n$. Concretely, the gap between the upper approximant
$b_n$ and $\gamma$ behaves like $1/(2n)$. To get one extra correct decimal digit,
you must compute roughly ten times as many terms. To get ten digits you need
billions of terms. The harmonic sum's legendary sluggishness is baked right into
the approximation.

The natural question is: can we do better *without* doing more work — using the
same harmonic sum $H_n$, just combining it more cleverly?

## The idea: stop aiming at the edges

Look again at the two recipes. The lower approximant subtracts $\ln(n+1)$; the
upper approximant subtracts $\ln n$. They differ only in *where the logarithm is
evaluated* — at the right edge $n+1$ of a unit step, or at the left edge $n$. One
overshoots, the other undershoots.

If one choice is too far right and the other too far left, an old instinct kicks
in: **aim for the middle**. Replace the edge with the midpoint $n + \tfrac12$.
This gives a new sequence, the heart of this work:

$$m_n = H_n - \ln\!\left(n + \tfrac{1}{2}\right).$$

This is the **midpoint approximant**. It costs exactly the same to compute as the
classical ones — the same harmonic sum, a single logarithm — but it is aimed at
the center of the step rather than at either end. The payoff is dramatic.

## Why the middle is magic

To see why the midpoint is special, picture the function $1/x$, whose graph is a
smooth downward-curving (convex) arc. The harmonic term $1/(n+1)$ that gets added
when you step from $H_n$ to $H_{n+1}$ can be compared to the area under that arc
over a unit-width interval. The logarithm differences are exactly such areas,
because $\ln(b) - \ln(a) = \int_a^b \frac{dx}{x}$.

Here is the geometric punchline, a classical fact called the *Hermite–Hadamard
inequality*: for a convex curve, the area under it over an interval is **larger**
than the rectangle whose height is the curve's value at the interval's *midpoint*.
Apply this to $1/x$ on the interval from $n+\tfrac12$ to $n+\tfrac32$, whose
midpoint is exactly $n+1$:

$$\ln\!\left(n+\tfrac32\right) - \ln\!\left(n+\tfrac12\right)
\;=\; \int_{n+1/2}^{n+3/2}\frac{dx}{x}
\;>\; \frac{1}{n+1}.$$

The left side is how much the logarithm term of $m_n$ grows in one step; the
right side, $1/(n+1)$, is how much the harmonic term grows in one step. Because
the logarithm grows *faster* than the harmonic sum at every step, the difference
$m_n = H_n - \ln(n+\tfrac12)$ *shrinks* at every step. In symbols, the per-step
inequality is

$$\frac{1}{n+1} \;<\; \ln\!\left(n+\tfrac32\right) - \ln\!\left(n+\tfrac12\right),$$

and this single inequality — proved cleanly and rigorously — is the engine of the
whole result.

There is an equivalent way to package that engine that is worth stating, because
it is the exact form that gets proved. Writing $t = \frac{1}{2n+2}$, the per-step
inequality above is the same as the elegant statement

$$2t \;<\; \ln\!\left(\frac{1+t}{1-t}\right) \qquad \text{for every } t \in (0,1).$$

The right-hand side is twice the inverse hyperbolic tangent, $2\,\mathrm{artanh}(t)$,
whose Taylor series is $2t + \tfrac{2}{3}t^3 + \tfrac{2}{5}t^5 + \cdots$. The
strict inequality just says all those extra positive cubic-and-higher terms
really are positive — a fact equivalent to the strict convexity of $1/x$. From
this one inequality everything else follows.

## What the new approximant guarantees

Three clean, rigorous statements describe the midpoint approximant $m_n$.

**It always decreases.** Every step makes $m_n$ strictly smaller than the last:
$m_1 > m_2 > m_3 > \cdots$. The sequence marches steadily downward.

**It lands exactly on $\gamma$.** As $n \to \infty$, $m_n$ converges to the
Euler–Mascheroni constant. This is guaranteed because $m_n$ is forever trapped
between the two classical sequences $H_n - \ln(n+1)$ and $H_n - \ln n$, both of
which converge to $\gamma$; squeezed between two things heading to the same place,
$m_n$ has nowhere else to go.

**It always stays above $\gamma$.** Combining the two facts above — a decreasing
sequence that converges to $\gamma$ must approach from above — gives the headline
result:

$$\gamma \;<\; m_n \qquad \text{for every } n.$$

This is more subtle than it sounds. It is *not* automatic from the old fact that
$\gamma < b_n$. Knowing the midpoint sits below the old upper approximant only
tells you $m_n < b_n$; it does not by itself tell you $m_n$ stays above $\gamma$.
That guarantee genuinely requires the decreasing-sequence argument above.

Putting it together with the lower approximant gives a brand-new, strictly
tighter sandwich:

$$\underbrace{H_n - \ln(n+1)}_{a_n} \;<\; \gamma \;<\; \underbrace{H_n - \ln(n+\tfrac12)}_{m_n}.$$

And the new upper edge $m_n$ is a strict improvement: it sits strictly below the
classical lower approximant's mirror image and strictly below the old upper
approximant $b_n = H_n - \ln n$, so it is the best one-logarithm upper bound on
$\gamma$ in this family.

## How much faster? A factor that compounds

The improvement is not cosmetic. Recall the old upper approximant overshoots
$\gamma$ by roughly $1/(2n)$. The midpoint approximant overshoots by only about

$$m_n - \gamma \;\approx\; \frac{1}{24\,n^2}.$$

The error has gone from $1/n$ to $1/n^2$ — a *quadratic* acceleration. The
numbers tell the story vividly. Here is the actual overshoot $m_n - \gamma$, and
the same quantity multiplied by $n^2$, which should approach $1/24 = 0.041667$:

| $n$ | classic overshoot $\approx 1/(2n)$ | midpoint overshoot $m_n - \gamma$ | $n^2\,(m_n-\gamma)$ |
|----:|-----------------------------------:|----------------------------------:|--------------------:|
|   1 | 0.42278 | 0.01731923 | 0.017319 |
|   2 | 0.22964 | 0.00649360 | 0.025974 |
|   5 | 0.09668 | 0.00136958 | 0.034239 |
|  10 | 0.04917 | 0.00037733 | 0.037733 |
|  20 | 0.02479 | 0.00009911 | 0.039642 |
|  50 | 0.00997 | 0.00001634 | 0.040843 |
| 100 | 0.00499 | 0.00000413 | 0.041252 |
| 200 | 0.00250 | 0.00000104 | 0.041459 |

By $n = 100$ the classic recipe is still wrong in the third decimal place, while
the midpoint recipe is already correct to roughly six. And look at the last
column: $n^2(m_n - \gamma)$ is climbing steadily toward $0.041667 = 1/24$,
confirming the quadratic law with its precise leading constant. The same harmonic
sum, the same single logarithm — but a hundredfold better accuracy at $n=100$,
growing without bound as $n$ increases.

## Why this kind of improvement matters

There is a beautiful, slightly counterintuitive lesson hiding here. The
midpoint approximant uses *no new information*. It does not sum more terms, does
not invoke any deep theorem, does not require exotic special functions. It simply
evaluates the logarithm at the smartest possible point — the center of the
interval rather than an edge. That single change of aim cancels the dominant
source of error.

This is the same principle that powers the midpoint rule and Simpson's rule in
numerical integration, the centered-difference formulas in numerical
differentiation, and a whole philosophy of *symmetrization* in applied
mathematics: errors that are odd (anti-symmetric) about a center cancel when you
aim at that center, leaving only the smaller even errors behind. Here the odd
$1/n$ error cancels, exposing the even $1/n^2$ term — and that residual term, with
its tidy coefficient $1/24$, practically invites the next move: shift the target
by a further small amount to cancel *it* too, chasing $1/n^4$ accuracy. That is
exactly the kind of laddered refinement (Richardson extrapolation) that turns a
good approximation into a great one.

Will any of this finally settle whether $\gamma$ is rational? Not on its own.
Irrationality proofs are won by entirely different weapons — clever integral
representations, continued fractions, and Apéry-style constructions of rapidly
converging rational approximations. But every such program rests on a foundation
of sharp, rigorous, two-sided bounds, and the midpoint approximant supplies one:
a decreasing, provably-from-above estimate of $\gamma$ whose error melts away
quadratically. It tightens the cage around one of mathematics' most stubborn
constants — and it does so with nothing more than the wisdom of aiming for the
middle.
