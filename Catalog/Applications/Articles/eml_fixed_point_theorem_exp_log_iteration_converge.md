# The Knob That Never Lies: How a Single Dial Steers an Exp-Log Machine

## A machine that keeps folding a number back on itself

Imagine a tiny machine with one input slot and one output slot. You feed it a
number, it hands you back a different number, and then — this is the interesting
part — you feed *that* number straight back in. Over and over. Numbers in,
numbers out, the output of each round becoming the input of the next.

Machines like this are everywhere. They are the beating heart of how interest
compounds in a bank account, how a thermostat settles a room to a steady
temperature, how a population of rabbits stabilizes, and how the layers of a
neural network transform their signals. The mathematical name for "apply the
same rule again and again" is **iteration**, and the central question is always
the same: *where does it all end up?* Does the stream of numbers wander forever,
oscillate, blow up to infinity — or does it home in on a single, special value
and stay there?

That special value, the number the machine reproduces unchanged, is called a
**fixed point**. If you feed in the fixed point, you get the fixed point back.
It is the resting state of the machine, its equilibrium, the place where the
endless folding finally comes to rest.

This article is about one particular family of these machines — call them
**exp-log machines** — and about a beautiful, exact law that governs how their
resting state responds when you turn a single dial.

## The exp-log rule

Our machine implements a specific rule. Given an input $x$, it computes

$$f(x) = e^{a}\,\log(b\,x + c).$$

Three numbers, $a$, $b$, and $c$, are the machine's settings. The parameter $b$
scales the input, $c$ shifts it, the logarithm gently compresses large values,
and then $e^{a}$ — the exponential of the scaling dial $a$ — stretches the
result back out. The combination of a *compressing* logarithm and a *stretching*
exponential is what gives these machines their tame, well-behaved character.
They are a clean idealization of the kind of "squash-then-scale" operation that
appears inside learning systems, where it pays to know exactly how the output
behaves rather than to cross your fingers.

To make this concrete, set $b = 1$ and $c = 2$, so the rule becomes
$f(x) = e^{a}\,\log(x + 2)$. Start with the scaling dial at $a = 0$, so
$e^{0} = 1$ and the machine simply computes $f(x) = \log(x + 2)$. Begin the
iteration anywhere reasonable — say $x_0 = 1$ — and watch:

$$1 \;\to\; \log 3 \approx 1.0986 \;\to\; \log(3.0986) \approx 1.1310 \;\to\; \cdots \;\to\; 1.1462\ldots$$

The numbers march in and settle, quickly, onto $x^\* \approx 1.1462$, the unique
solution of $x = \log(x + 2)$. That number is the machine's fixed point. Feed it
in, get it back. The machine has found its rest.

## Why it always settles: the contraction principle

The reason the numbers converge — and don't, say, ricochet around forever — is
that the exp-log rule is a **contraction**. A contraction is a map that pulls
points closer together: if you run two different inputs through it, the gap
between the outputs is strictly smaller than the gap between the inputs. Apply a
contraction repeatedly and every pair of trajectories is squeezed together,
relentlessly, until they collapse onto a single point. That point is the fixed
point, and it is necessarily unique — there is no room for two.

How do we know our machine contracts? We look at its steepness. The derivative
of $f$ — the factor by which it magnifies tiny changes in the input — works out
to

$$f'(x) = \frac{e^{a}\,b}{b\,x + c}.$$

If this magnification factor stays below $1$ in absolute value across the whole
working range, then small differences shrink at every step, and the machine is a
contraction. In our example with $a = 0$, $b = 1$, $c = 2$, near the fixed point
we have $f'(x^\*) = 1/(x^\* + 2) \approx 1/3.15 \approx 0.32$, comfortably below
one. Each iteration cuts the remaining error to roughly a third. That is why the
convergence above looked so brisk: after $n$ steps the distance to the fixed
point is no larger than a constant times $0.32^{\,n}$ — geometric decay, the gold
standard of fast convergence.

This is the classical guarantee, made completely rigorous: the exp-log machine,
whenever its steepness stays below one on an interval it maps into itself, has
**exactly one** resting state, and the iteration **always finds it**, with the
error falling off like $\rho^{\,n}$ where $\rho < 1$ is the bound on the
steepness. The convergence even comes with a *certificate*: at every step you
can compute a guaranteed error bound,
$$|x_n - x^\*| \;\le\; |x_1 - x_0|\,\frac{\rho^{\,n}}{1 - \rho},$$
so you always know how close you are without knowing $x^\*$ in advance. And
because the rule is increasing when $b > 0$, you can do even better: run the
iteration from the *bottom* of the interval and from the *top* simultaneously,
and the two trajectories close in on the fixed point from both sides like a
vise — a lower estimate that rises, an upper estimate that falls, and a gap
between them that provably shrinks to zero. At any moment you hold a rigorous
bracket $[\ell_n, u_n]$ that is *guaranteed* to contain $x^\*$.

## The real story: turning the dial

All of that — guaranteed convergence, a unique resting state, a certified error
and a self-validating bracket — sets the stage. But it leaves the most practical
question unanswered. Suppose you want to *tune* the machine. You reach for the
scaling dial $a$ and nudge it. **What happens to the resting state?**

This is the question an engineer actually cares about. If the exp-log machine is
a component inside a larger system, $a$ is your control knob, and $x^\*$ is the
output you are trying to place. You need to know: is the knob trustworthy? When
you turn it up, does the output go up — predictably, every time? Or could a
small twist send the output lurching the wrong way, or jumping to some entirely
different equilibrium?

The headline result of this work is a clean and complete answer:

> **Turn the dial up, and the resting state rises. Always. Strictly.**

In precise terms: if $a_1 < a_2$ are two settings of the scaling dial (with the
other settings $b > 0$ and $c$ held fixed), and $x_1^\*$ is the resting state at
$a_1$ while $x_2^\*$ is the resting state at $a_2$, then

$$x_1^\* \;<\; x_2^\*.$$

A larger scaling parameter produces a strictly larger equilibrium. There is no
threshold, no reversal, no flat spot, no surprise jump to a different basin. The
response is **monotone**, and because it is *strictly* monotone, the map from
dial settings to resting states is **injective**: every distinct setting yields
its own distinct equilibrium. The knob is, in the most literal sense, an honest
control — it never lies about the direction it moves the output, and it never
sends two different settings to the same place.

Let us see it in our running example. With $b = 1$, $c = 2$:

| dial $a$ | rule | resting state $x^\*$ |
|---|---|---|
| $0.00$ | $\log(x+2)$ | $1.146$ |
| $0.10$ | $1.105\,\log(x+2)$ | $1.329$ |
| $0.30$ | $1.350\,\log(x+2)$ | $1.803$ |
| $0.49$ | $1.632\,\log(x+2)$ | $2.429$ |

Every increase in $a$ lifts the resting state. The column of equilibria climbs
in lockstep with the dial. Turn it up a little, the output rises a little; turn
it up more, the output rises more.

## The idea behind the proof: a clever head start

What makes the rising-equilibrium law *true* — and what makes it a genuine
theorem rather than a lucky pattern in a table — is an argument of disarming
elegance. It needs no heavy machinery, no calculus of how the fixed point
"moves" as a function of $a$, no implicit function theorem. It needs only three
facts you already believe: the exponential is increasing, the logarithm is
increasing, and the machine itself is increasing when $b > 0$.

Here is the whole idea in one breath.

Start at the *smaller* setting $a_1$ and let the machine settle to its resting
state $x_1^\*$. Now turn the dial up to the larger setting $a_2$ — but don't
restart from scratch. Instead, hand the larger machine the smaller machine's
resting state $x_1^\*$ as its starting point, and ask: what does the larger
machine do with it?

The larger machine multiplies by $e^{a_2}$ instead of $e^{a_1}$, and since
$a_2 > a_1$ that is a *bigger* stretch. At the point $x_1^\*$ the logarithm term
$\log(b\,x_1^\* + c)$ is positive — this is precisely where the positivity of
the resting state matters, because a positive fixed point forces
$b\,x_1^\* + c > 1$, and the log of something bigger than $1$ is positive.
Multiplying a positive quantity by a bigger number gives a bigger result. So the
larger machine, fed $x_1^\*$, returns something *strictly greater* than
$x_1^\*$:

$$f_{a_2}(x_1^\*) \;>\; x_1^\*.$$

In the language of dynamics, $x_1^\*$ is a **sub-solution** of the larger
machine — a point the machine pushes *upward*. And because the machine is
monotone increasing, once it starts pushing upward it keeps pushing upward: the
trajectory launched from $x_1^\*$ rises, step after step, never turning back.
A rising trajectory inside a contraction can only be heading toward one place —
the larger machine's resting state $x_2^\*$. And every point on a rising path
lies below where the path ends. So the starting point sits below the
destination:

$$x_1^\* \;<\; x_2^\*.$$

That is the entire proof. The smaller machine's equilibrium is a *head start*
for the larger machine — a launch pad it can only climb away from, upward, into
its own higher resting state. The contraction guarantees the climb has a single
destination; monotonicity guarantees the climb only goes up; positivity
guarantees the first step is strictly upward. Three honest facts, one inevitable
conclusion.

It is worth pausing on why the positivity of the resting state is not a
technicality but the load-bearing beam. If the resting state were negative,
the logarithm term could turn negative, the bigger stretch would make the
output *smaller*, and the whole argument would run in reverse. The theorem is
true exactly where it should be true, and the proof knows it.

## Why this matters

A control knob that always moves the output the right way, by a predictable
amount, with no hidden cliffs — that is the difference between a component you
can build on and one you have to babysit. Many of the nonlinear maps that
populate modern computational systems lack this courtesy: nudge a parameter and
the behavior can jump, fold, or destabilize without warning. The exp-log machine
is provably better behaved. Its scaling dial is a *monotone, injective* control:
turn it up and the equilibrium rises, turn it down and the equilibrium falls,
and no two settings ever collide on the same output.

Combine this with the earlier guarantees — a unique resting state, geometric
convergence to it, a computable error certificate, and a two-sided bracket that
provably traps the answer — and you get an iterative scheme that is genuinely
*engineerable*. You can certify that it converges, certify how fast, certify a
rigorous enclosure of the answer at any step, and now certify which way and how
reliably its output responds to tuning. The dial does exactly what a dial should
do.

## The frontier

The same head-start argument that tames the scaling dial $a$ applies, word for
word, to the shift dial $c$: increasing $c$ also strictly raises the resting
state. That immediately raises the prospect of a *two-knob* control surface in
which $a$ and $c$ both push the equilibrium the same way and never cancel — a
response surface that is monotone in every direction, never folded. Beyond the
qualitative picture lies a quantitative one: not just *that* the output rises but
*how much*, captured by an explicit sensitivity bound built from the same
geometric series that controls the convergence rate. And further still lies the
analytic dream — a genuine power-series formula for the resting state as a
function of the dial, valid precisely in the regime where the machine contracts.

But the foundation is laid, and it is solid. A machine that folds numbers back
on itself, settles to a single resting state, and responds to its control dial
with perfect honesty — turn it up, and it rises; every time, by just the right
amount, with never a lie. In a world of unpredictable nonlinear systems, that
kind of trustworthiness is rare, and it is worth celebrating.
