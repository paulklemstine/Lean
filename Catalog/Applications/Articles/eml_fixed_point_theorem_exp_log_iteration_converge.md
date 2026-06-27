# The Self-Correcting Calculator: How an Exp-Log Loop Always Finds Its Center

Imagine a strange little machine. You feed it a number, it does some arithmetic,
and it spits out a new number. You feed *that* number back in, and out comes
another. Again and again. Most machines like this go haywire: the numbers blow up
to infinity, or thrash around forever without settling. But a few of them are
magical. No matter what number you start with, they march steadily toward a single
special value — a *fixed point* — and once you are close, every extra turn of the
crank slices your remaining error by a fixed fraction.

This article is about one such machine, built from two of the most important
functions in all of mathematics: the exponential and the logarithm. We will see
exactly when it behaves itself, prove that it settles to a unique answer, and
pin down — with a clean, computable formula — *how fast* it gets there.

## The machine

Our machine is a single formula with three knobs, $a$, $b$, and $c$:

$$f(x) = e^{a}\,\log(b\,x + c).$$

Here $e^{a}$ is the exponential of $a$ (a positive scaling factor), and $\log$ is
the natural logarithm. The name in the underlying research is the **EML operator**
— "exp-log." The exponential out front *stretches*; the logarithm inside
*compresses*. They pull in opposite directions, and the tension between them is
exactly what makes the machine tame.

To run the machine, pick a starting number $x_0$ and iterate:

$$x_{n+1} = f(x_n) = e^{a}\,\log(b\,x_n + c).$$

This produces a sequence $x_0, x_1, x_2, \dots$ The central question is simple to
ask and surprisingly deep to answer: **does this sequence settle down, and if so,
to what?**

## Fixed points: where the machine holds still

A *fixed point* is a number $x^\*$ that the machine leaves unchanged:

$$f(x^\*) = x^\*, \qquad \text{i.e.} \qquad x^\* = e^{a}\,\log(b\,x^\* + c).$$

If you ever land exactly on $x^\*$, you stay there forever. Fixed points are the
"centers of gravity" of iterative processes. They appear everywhere: the
equilibrium price in an economic model, the steady state of a feedback circuit,
the value that Newton's method hunts for, the rest position of a damped pendulum.
The whole game is to show that our sequence is *attracted* to such a center,
rather than repelled from it.

## The secret is the slope

Whether a fixed point attracts or repels comes down to a single number: the
*slope* of $f$ at that point. Calculus hands us the slope directly. The derivative
of the EML operator is

$$f'(x) = \frac{e^{a}\,b}{b\,x + c},$$

valid wherever the quantity inside the logarithm, $b x + c$, is positive (you
cannot take the logarithm of a non-positive number). Notice the shape: the
numerator $e^a b$ is fixed, while the denominator $bx + c$ *grows* as $x$ grows.
So the slope shrinks as $x$ increases. A big denominator means a gentle slope —
and a gentle slope is precisely what we want.

Here is the intuition. If $|f'| < 1$ everywhere on some interval, then $f$ never
stretches distances — it only shrinks them. Two nearby inputs always produce two
*even nearer* outputs. Such a map is called a **contraction**. Picture folding a
map of your country and laying it on the ground: the famous Banach fixed-point
theorem says there is exactly one point on the paper sitting directly above the
real place it represents. Contractions always have exactly one fixed point, and
repeated folding drives you straight to it.

## Packaging the good behaviour

For the machine to be a genuine contraction, three conditions must hold together
on a closed interval $[\,\mathrm{lo}, \mathrm{hi}\,]$:

1. **The logarithm is well-defined.** We need $b x + c > 0$ throughout the
   interval, so $\log(bx+c)$ always makes sense.
2. **The interval is a trap.** The machine must map the interval *into itself*:
   if $x$ lies in $[\mathrm{lo}, \mathrm{hi}]$, then $f(x)$ does too. Once you are
   in the trap, you never escape — so the whole sequence stays put.
3. **The slope is tame.** There is a number $\rho$ with $0 \le \rho < 1$ such that
   $|f'(x)| \le \rho$ everywhere on the interval. This $\rho$ is the
   **contraction ratio**, the fraction by which distances shrink each step.

Bundle these three guarantees together and you get what the formal development
calls a *contraction certificate*. From that certificate, everything else follows
mechanically.

## What we can prove

With the certificate in hand, here is the complete story, stated plainly.

**The mean value theorem turns the slope bound into a shrink rate.** Because
$|f'| \le \rho$ on the interval, the distance between any two outputs is at most
$\rho$ times the distance between the inputs:

$$|f(x) - f(y)| \le \rho\,|x - y|.$$

**There is at most one center.** Suppose two points $x_1$ and $x_2$ were both
fixed. Then $|x_1 - x_2| = |f(x_1) - f(x_2)| \le \rho\,|x_1 - x_2|$. Since
$\rho < 1$, the only way this can hold is $|x_1 - x_2| = 0$. So the fixed point,
if it exists, is **unique**.

**The center exists, and you are pulled to it.** Track the size of each step. The
gap between consecutive iterates shrinks geometrically:

$$|x_{n+1} - x_n| \le \rho^{n}\,|x_1 - x_0|.$$

The total distance still to travel is a geometric series that converges, so the
sequence cannot wander forever — it is *Cauchy*, the precise mathematical word for
"the terms eventually huddle arbitrarily close together." A Cauchy sequence of
real numbers always has a limit, and because $f$ is continuous and the trap is
closed, that limit $x^\*$ lies inside the interval and satisfies $f(x^\*) = x^\*$.
The center exists, lives in the interval, and every starting point in the interval
converges to it.

**And here is the headline — we know exactly how fast.** This is the result that
turns a qualitative "it converges" into a quantitative engineering guarantee. From
the very first step you take, you can bound *all* future error:

$$\boxed{\,|x_n - x^\*| \;\le\; |x_1 - x_0|\cdot\frac{\rho^{n}}{1 - \rho}\,}$$

Read this carefully. The right-hand side uses only two things you can measure
immediately: the size of your first step $|x_1 - x_0|$, and the contraction ratio
$\rho$. Every term shrinks by the factor $\rho$ per iteration, so the error decays
like $\rho^n$ — exponentially fast. Want ten correct decimal digits? Just solve
for the $n$ that makes the bound smaller than $10^{-10}$. No guessing, no luck:
a *certificate* of accuracy you can compute before you even start. This is the
classical Banach *a priori* error estimate, made completely explicit for the EML
machine.

## A concrete machine you can run by hand

Abstract guarantees are only convincing if a real example satisfies all of them at
once. So here is a fully worked-out instance with no loose ends. Take

$$f(x) = e^{1}\,\log(x + 100) \qquad \text{on the interval } [0, 20],$$

that is, $a = 1$, $b = 1$, $c = 100$. Let us check the three conditions with
honest arithmetic.

- **Logarithm well-defined?** On $[0,20]$ we have $x + 100 \ge 100 > 0$. Yes.
- **Slope tame?** The slope is $f'(x) = e/(x+100) \le e/100$. Since $e < 3$, this
  is below $3/100$, comfortably under $\rho = 1/30 \approx 0.0333$. Yes — and with
  room to spare.
- **The trap holds?** The output is $e\,\log(x+100)$. The logarithm is at least
  $\log(100) > 0$, so the output is positive. And it is at most
  $e\,\log(120) < 3 \times 5 = 15 < 20$, because $\log(120) < 5$ (one checks
  $e^5 = (e)^5 > 2.7^5 > 120$). So $f$ maps $[0,20]$ into roughly $[4.6, 15]$,
  safely inside. Yes.

All three conditions hold, with a contraction ratio of just $\rho = 1/30$. The
machine is a *genuine* exp-log map, not a disguised straight line: since $a = 1$,
the scaling factor $e^1 = e > 1$ really matters. Plug in the master formula and you
learn that, starting anywhere in $[0,20]$, the iteration converges to a unique
fixed point $x^\* \approx 12.85$ in the interval, with the explicit error bound

$$|x_n - x^\*| \le |x_1 - x_0|\cdot\frac{(1/30)^n}{1 - 1/30}.$$

Each step kills more than ninety-six percent of the remaining error. After just a
handful of iterations you are correct to machine precision. Try it: start at
$x_0 = 0$, and within five or six steps you will be staring at $12.85$ and it will
refuse to budge.

## When the machine misbehaves

The story has a flip side, and it is just as instructive. The good behaviour
hinges on choosing the knobs wisely — in particular, on making the translation $c$
large relative to the interval. Why? Because a large $c$ keeps the denominator
$bx + c$ big, which keeps the slope small, which keeps the contraction strong. It
also keeps $bx + c$ comfortably above $1$, so the logarithm stays positive and the
trap closes neatly.

Push $c$ down toward zero and the magic evaporates. With $b = 1$ and a small
$c \in (0,1)$, the logarithm can dip *negative* (since $\log$ of anything below $1$
is negative), the outputs can fall out of any candidate interval, and the slope
near the left edge can exceed $1$. The contraction breaks. This is not a defect of
the proof; it is the genuine geometry of exp-log maps. It explains why the original
conjecture's literal "small $c$" test case is hard, and why the right move is
*slack engineering*: give yourself a large $c$ and the dynamics become beautifully
well-behaved.

There is still good news in a middle regime. Even without a slope bound, a fixed
point can be shown to *exist* by a pure existence argument — the intermediate value
theorem. For $b = 1$, $c = 2$, and any modest $a$ with $0 < a < \tfrac12$, the
function $f(x) - x$ is positive at $x = 1$ and negative at $x = 3$, so somewhere
between them it must cross zero. That crossing is a positive fixed point. As $a$
varies, this fixed point moves smoothly, tracing a curve $x^\*(a)$ that begins, at
$a = 0$, at the solution of $x^\* = \log(x^\* + 2)$, namely $x^\* \approx 1.146$.

## Why this matters

The exp-log operator is not a toy. Compositions of exponentials and logarithms are
the raw material of many machine-learning activation functions, of
information-theoretic transforms, and of numerical schemes that compress and
rescale data. A recurring worry with such nonlinear maps is that iterating them is
unpredictable. What we have shown is that, in the right parameter regime, the
exp-log machine is the *opposite* of unpredictable. It is a contraction with a
unique attracting center and a convergence rate you can certify in advance, down
to the last decimal place.

That is the difference between hoping an iterative algorithm works and *knowing* it
does. The slope tells you everything; the exponential and the logarithm, those two
ancient adversaries, hold each other in a perfect, self-correcting balance; and the
sequence, wherever it starts, walks home.
