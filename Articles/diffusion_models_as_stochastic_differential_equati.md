# How to Un-Stir a Drop of Ink: The Mathematics Behind Diffusion Models

Imagine you let a single drop of ink fall into a glass of still water. At first
the drop is sharp and structured — a little dark galaxy suspended in clear
liquid. But the water molecules never stop jostling, and within a minute the
drop has dissolved into a uniform gray haze. The structure is gone. If someone
handed you the gray glass and asked you to recover the exact shape of the
original drop, you would say it is impossible. Diffusion erases information.

And yet, the most powerful image generators in the world — the systems that
conjure photorealistic faces and impossible landscapes from a text prompt — work
by doing exactly this impossible thing *in reverse*. They take pure noise, a
glass of mathematical gray, and run diffusion *backwards in time* until a
coherent image crystallizes out of the static. This article is about the
beautiful and surprisingly classical mathematics that makes this possible, and
about a set of theorems that pin those ideas down with complete rigor.

## The drop of ink, written as an equation

To do mathematics with our ink drop, we need to describe its wandering
precisely. The cleanest model in all of probability theory is the
**Ornstein–Uhlenbeck process**, named after two physicists who introduced it in
1930 to describe the velocity of a particle buffeted by molecular collisions. It
is a stochastic differential equation, or SDE:

$$dX = -\theta\, X\, dt + \sigma\, dW.$$

Read it like a recipe for how a random point $X$ on the number line moves in a
tiny instant of time $dt$. There are two forces. The first, $-\theta X\,dt$, is a
*spring*: it always pulls $X$ back toward the origin, and the further out $X$ is,
the harder it is pulled. The strength of the spring is the number $\theta > 0$.
The second term, $\sigma\, dW$, is the *kick*: $dW$ is the increment of Brownian
motion — the mathematical embodiment of random molecular jostling — and $\sigma$
controls how violent the kicks are. The spring wants order; the kicks want chaos.
Their tug-of-war is the whole story.

If you start a whole cloud of points and let them all follow this rule, the cloud
spreads, drifts, and eventually settles into a steady, unchanging fuzz. In a
diffusion model, that cloud of points *is* your data — the pixels of an image,
say — and the OU process is the controlled way we destroy it.

## What the cloud looks like at every moment

Here is the first piece of magic, and the first thing our theorems make exact. If
you start the OU process from a Gaussian "bell curve," it stays a Gaussian bell
curve forever — only its center and width change with time. So to know the entire
cloud at time $t$, you only need to track two numbers: the **mean** $m(t)$ (where
the cloud is centered) and the **variance** $v(t)$ (how spread out it is).

These two numbers obey marvelously simple laws. The mean is

$$m(t) = m_0\, e^{-\theta t},$$

an honest exponential decay: whatever your data's average was, the spring drags it
exponentially fast toward zero. The variance is

$$v(t) = v_0\, e^{-2\theta t} + \frac{\sigma^2}{2\theta}\left(1 - e^{-2\theta t}\right),$$

which interpolates smoothly from the starting spread $v_0$ to a final, fixed value
$\sigma^2/2\theta$. We can verify these formulas by differentiating them, and they
satisfy the elegant ordinary differential equations

$$m'(t) = -\theta\, m(t), \qquad v'(t) = -2\theta\, v(t) + \sigma^2.$$

The first says the center relaxes toward zero; the second says the spread relaxes
toward $\sigma^2/2\theta$. As time runs to infinity, $m(t) \to 0$ and
$v(t) \to \sigma^2/2\theta$. The ink drop has become the gray haze: a single,
universal Gaussian $N(0, \sigma^2/2\theta)$ that has completely forgotten where it
started. Mathematicians call this the **stationary distribution**, the unique
resting state of the process.

## The law that governs the haze: Fokker–Planck

Tracking two numbers is convenient, but the deepest description of the cloud is
its full *density* — a function $p(x,t)$ that tells you how thickly the points are
packed at position $x$ and time $t$. For our Gaussian cloud the density has the
familiar bell shape, which we write in a slightly unusual but very powerful form:

$$p(x,t) = \exp\!\left(-\tfrac{1}{2}\log\big(2\pi v(t)\big) - \frac{\big(x - m(t)\big)^2}{2 v(t)}\right).$$

This "exp-log" way of writing the bell curve is not a gimmick. Because it is an
exponential of a real number, it is *automatically positive* — the density can
never accidentally go negative, a fact we record as a clean little theorem. And
when the variance is positive, this expression is exactly equal to the textbook
Gaussian $\frac{1}{\sqrt{2\pi v}}\, e^{-(x-m)^2/(2v)}$. The exp-log form is the key
that unlocks every calculation that follows, because it turns the awkward
square-root normalization into a friendly additive term.

Now comes the centerpiece. There is a single partial differential equation — the
**Fokker–Planck equation**, also called the forward Kolmogorov equation — that
governs how the *entire density* evolves in time. For the OU process it reads:

$$\frac{\partial p}{\partial t} = \theta\, \frac{\partial}{\partial x}\big(x\, p\big) + \frac{\sigma^2}{2}\, \frac{\partial^2 p}{\partial x^2}.$$

In words: the rate of change of the density in time is governed by two operators
in space. The first, $\theta\,\partial_x(x\,p)$, is the *drift* term — it is the
spring, herding probability back toward the origin. The second,
$\frac{\sigma^2}{2}\,\partial_{xx}p$, is the *diffusion* term — it is the kicks,
smearing probability out like heat spreading through a metal bar. The
Fokker–Planck equation is the bridge between the microscopic random walk of a
single particle and the smooth, deterministic flow of the whole probability cloud.

**The main theorem.** Our central result is that the Gaussian density built from
the OU mean and variance — the density $p(x,t)$ written above, with $m(t)$ and
$v(t)$ given by their explicit formulas — *actually solves this equation*, exactly,
for every position $x$ and every time $t$ (as long as the spring is real,
$\theta \neq 0$, and the variance is positive). This is not a numerical
approximation or a heuristic; it is an identity verified to the last symbol.

How is such a thing proved? The strategy is disarmingly concrete. You compute the
three derivatives that appear in the equation. The first spatial derivative turns
out to be the density times a simple factor:

$$\frac{\partial p}{\partial x} = p \cdot \left(-\frac{x - m}{v}\right).$$

That factor, $-(x-m)/v$, has a name we will meet again in a moment: it is the
**score**. Differentiating once more gives the second spatial derivative,

$$\frac{\partial^2 p}{\partial x^2} = p \cdot \frac{(x-m)^2 - v}{v^2},$$

and a careful application of the chain rule (the mean and variance both move in
time) gives the time derivative,

$$\frac{\partial p}{\partial t} = p \cdot \left(\frac{x-m}{v}\, m'(t) + \frac{(x-m)^2 - v}{2 v^2}\, v'(t)\right).$$

Now substitute the moment equations $m' = -\theta m$ and $v' = -2\theta v + \sigma^2$,
plug everything into the Fokker–Planck equation, and watch what happens: the
exponential density factors out of every term, and what remains is a pure algebraic
identity among the polynomials in $x$, $m$, $v$, $\theta$, and $\sigma^2$.
Everything cancels. The heart of that cancellation is the tidy fact
$-m(x-m) - \big((x-m)^2 - v\big) = v - x(x-m)$. The deep statement about an evolving
probability cloud reduces, in the end, to grade-school algebra — but algebra that
has to come out *exactly* right, which is precisely the kind of thing a formal
proof is built to guarantee.

A companion theorem checks the resting state. Plug the stationary Gaussian
$N(0, \sigma^2/2\theta)$ — the gray haze — into the right-hand side of the
Fokker–Planck operator, and you get exactly zero. The haze does not move; it is the
true fixed point. And the fixed point is genuinely $\sigma^2/2\theta$, not the
trivial value zero — the balance struck between spring and kicks.

## Running the movie backwards

We have now described, with complete precision, how to destroy data: run the OU
process forward, and any starting distribution dissolves into the universal
Gaussian haze. But generation requires the reverse. We want to start from the
haze — which is easy to sample, just draw a random Gaussian number — and run the
movie *backwards* until structure reappears.

In 1982, the control theorist Brian Anderson proved something that sounds almost
paradoxical: a diffusion run backwards in time is *also* a diffusion, with its own
SDE. Time reversal does not turn the random process into something exotic; it
turns it into another OU-like process, but with a modified drift. And that
modified drift depends on one extra ingredient — the **score** of the density,
the quantity

$$\nabla_x \log p(x,t),$$

the gradient of the log-density. For our Gaussian, the score has the beautifully
simple closed form

$$\frac{\partial}{\partial x} \log p(x,t) = -\frac{x - m(t)}{v(t)},$$

which is exactly the factor that popped out when we differentiated the density.
The score is an arrow at every point that says "this way to higher probability" —
it points back toward the cloud's center, more steeply the further out you are.

Anderson's reverse-time equation says that if you run a new SDE whose drift is the
original spring *plus* a $\sigma^2$-weighted dose of the score,

$$b(x,t) = \theta x + \sigma^2\, \nabla_x \log p(x,t),$$

then the reversed process exactly reconstructs the forward process's
distributions, in reverse order. Start from the stationary haze at the final time,
follow this reverse drift, and you land — exactly — back on the original data
distribution. Our theorems verify that this reverse density satisfies its own
Fokker–Planck equation, and that the data distribution is recovered exactly.

This is the engine of every score-based image generator. The catch in practice is
that for real data — photographs, not Gaussians — nobody knows the score function
in closed form. So a neural network is trained to *estimate* it, learning the
arrows that point toward "more like real data." Once you have those arrows, you
run Anderson's reverse SDE, and images condense out of noise. The mathematics in
this article is the special, exactly-solvable case — the Gaussian skeleton on
which the whole edifice of modern generative AI is built. Because the Gaussian
case can be solved on paper and checked symbol by symbol, it serves as the
bedrock test: if your understanding of the reverse-time machinery is correct, it
*must* reproduce these exact formulas.

## Why bother making it exact?

It would be easy to wave one's hands through all of this. The OU process is
classical; the Fokker–Planck equation is in every textbook; Anderson's theorem is
forty years old. Why insist on proving, with zero gaps, that the Gaussian solves
the equation, that its score has this form, that the reverse process recovers the
data?

Because the modern application is unforgiving. When billions of dollars and
millions of users depend on a generative model, the difference between "the
reverse SDE approximately recovers the data" and "the reverse SDE *exactly*
recovers the data, here are the precise conditions" is the difference between a
heuristic and a guarantee. The exactly-solvable Gaussian case is where you check
that the whole logical chain — forward process, marginal densities, Fokker–Planck
equation, stationary law, score function, time reversal — fits together without a
single loose joint. Every derivative computed here is a genuine derivative; every
equation is a genuine equation; the stationary variance is the exact balance
point, not an approximation; the reverse process recovers the exact law, not a
nearby one.

There is a pleasing intellectual symmetry to the whole picture. The forward
process is run by physics — the blind spring and the blind kicks. The reverse
process is run by *information* — the score, the gradient of log-probability, the
mathematical embodiment of "which way is more likely." Diffusion destroys
structure by physics and recreates it by information. The drop of ink cannot
un-stir itself, because the water molecules know nothing. But a machine that has
learned the score knows which way the structure lay, and for it the gray haze is
not an ending but a beginning.

That is the quiet revolution hiding inside today's image generators: a
two-hundred-year-old equation for heat and a forty-year-old theorem about
reversing time, fused into a method for making the impossible — un-stirring the
ink — routine.
