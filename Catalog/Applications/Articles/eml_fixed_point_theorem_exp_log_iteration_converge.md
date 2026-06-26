# The Self-Finding Number: How an Exp-Log Loop Always Lands on Its Target

Imagine a machine with a single dial. You feed it a number, it spits out
another number, and you feed *that* back in. Round and round it goes. Most
machines like this behave wildly — small nudges to the input cause the output
to swing chaotically, and the sequence of numbers you get never settles down.
But a special few are tame. No matter where you start, they pull every input
toward one magic value and stay there. That value is called a **fixed point**,
and the machine *finds it for you*, automatically, just by running.

This is the story of one such machine: the **EML operator**, a deceptively
simple combination of an exponential and a logarithm that appears as a building
block inside a family of neural-network layers. We will see exactly why it is
tame, how fast it homes in on its target, and — crucially — how to know when to
stop the loop because you are already "close enough." Every claim here has been
checked down to the last epsilon.

## A function built from two opposites

The exponential function $e^x$ grows explosively. The logarithm $\log x$ grows
agonizingly slowly — it is the exponential run in reverse. The EML operator
marries them. For three real parameters $a$, $b$, and $c$, it is the function

$$f(x) = e^{a}\,\log(b x + c).$$

Read it left to right: take your input $x$, scale and shift it to $bx + c$,
compress that with a logarithm, then magnify the result by the constant $e^a$.
The logarithm tames large inputs; the exponential factor $e^a$ controls how
strongly the whole thing reacts. Two opposing forces, balanced.

The *iteration* is what happens when you let the machine run on its own output.
Starting from a seed $x_0$, define

$$x_{n+1} = f(x_n) = e^{a}\,\log(b x_n + c).$$

So $x_1 = f(x_0)$, then $x_2 = f(x_1)$, and so on forever. The question that
animates everything below is simple: **does this sequence settle down, and if
so, where?**

## The secret is in the slope

Whether an iteration converges or careens out of control comes down to a single
quantity: the **steepness** of $f$, that is, its derivative. A short
calculation — one of the first results we pinned down — gives a clean formula
for the slope of the EML operator at any point $x$ (wherever the logarithm's
argument is positive, so the function makes sense):

$$f'(x) = \frac{e^{a}\,b}{b x + c}.$$

Here is the intuition that makes the whole theory click. Suppose you take two
nearby inputs and run them both through $f$. The gap between the outputs is,
roughly, the gap between the inputs multiplied by the slope. If the slope is
bigger than $1$, the gap *grows* — errors amplify and the loop is unstable. But
if the slope stays *below* $1$ in absolute value everywhere on some interval,
then every pass through $f$ **shrinks** distances. Two points that start a
millimeter apart end up closer; run it again and they are closer still. A
function with this distance-shrinking property is called a **contraction**, and
it is the mathematical engine behind everything that follows.

Concretely, we proved that if $|f'(x)| \le \rho$ for some fixed ratio
$\rho < 1$ across an interval, then for *any* two points $x$ and $y$ in that
interval,

$$|f(x) - f(y)| \le \rho\,|x - y|.$$

Every application of $f$ multiplies the distance between points by at most
$\rho$. That single inequality is the seed from which the entire convergence
theory grows.

## One target, and only one

A contraction cannot have two different fixed points. The argument is almost
embarrassingly short, and we made it airtight. Suppose $x_1$ and $x_2$ were
*both* fixed — each unchanged by $f$. Then the distance between them equals the
distance between $f(x_1)$ and $f(x_2)$, because $f$ leaves each alone. But the
contraction property says that second distance is at most $\rho$ times the
first, with $\rho < 1$. A number that is at most a fraction of itself can only
be zero. So $x_1$ and $x_2$ were the same point all along. There is **at most
one** fixed point on the interval.

That settles uniqueness. What about existence — does a fixed point actually
*exist*? Here we need one more ingredient: the interval must be **invariant**,
meaning $f$ maps it into itself. If you start inside the interval, you never
leave it. Under that condition we proved the iterates form what mathematicians
call a *Cauchy sequence*: the terms eventually crowd arbitrarily close
together. On the real number line, such sequences always converge. The limit
$x^\star$ they converge to is, by continuity of $f$, exactly a fixed point:

$$x^\star = e^{a}\,\log(b x^\star + c),$$

and it lies inside the interval. Combine this with uniqueness, and the picture
is complete: **there is exactly one fixed point, and the iteration from any
starting seed in the interval marches straight to it.** This is a tailored,
fully verified incarnation of the celebrated Banach fixed-point theorem,
specialized to the exp-log world.

## How fast? Geometrically fast.

Convergence is reassuring, but engineers want a clock. How many steps until we
are close enough? The contraction ratio answers this too. Because each step
shrinks the distance to the target by a factor of at most $\rho$, after $n$
steps the distance has shrunk by a factor of at most $\rho^n$:

$$|x_n - x^\star| \le \rho^{\,n}\,|x_0 - x^\star|.$$

This is **geometric** (also called exponential) convergence. If $\rho = 0.3$,
then every step kills about $70\%$ of the remaining error. Ten steps shave the
error by a factor of roughly $\rho^{10} \approx 6\times10^{-6}$ — a millionfold.
The number of correct decimal digits grows *linearly* with the number of steps.
This is the gold standard of well-behaved iteration: predictable, fast, and
tunable through the single knob $\rho$.

## Knowing when to stop — without knowing the answer

There is a subtlety hiding in the bound above. It mentions $|x_0 - x^\star|$,
the distance from the start to the target — but we do not *know* the target;
finding it is the whole point! A bound you cannot evaluate is not much use for
deciding when to halt the loop. We resolved this with two practical estimates.

The first is the **a priori bound**. Before running a single full iteration, you
can predict your accuracy after $n$ steps using only the size of the very first
step, $|x_1 - x_0|$:

$$|x_n - x^\star| \le \frac{\rho^{\,n}}{1 - \rho}\,|x_1 - x_0|.$$

Take one step, measure how far you moved, and you immediately get a guaranteed
error budget for *all* future steps. Want six digits of accuracy? Solve for the
$n$ that makes the right-hand side small enough, and you know in advance how
many iterations to schedule.

The second, and more powerful in practice, is the **a posteriori bound**. It
uses only the two most recent iterates you have actually computed:

$$|x_{n+1} - x^\star| \le \frac{\rho}{1 - \rho}\,|x_{n+1} - x_n|.$$

This is the gem. As you run the loop, you watch consecutive outputs. The moment
two successive iterates are close together, this inequality *certifies* that you
are close to the true answer — with a precisely quantified margin. You never
needed to know $x^\star$ at all; the loop tells on itself.

From this we extracted a **stopping criterion** ready to drop into code: pick a
tolerance $\varepsilon$, and halt as soon as

$$\frac{\rho}{1 - \rho}\,|x_{n+1} - x_n| \le \varepsilon.$$

When that test passes, the current iterate $x_{n+1}$ is *guaranteed* to be
within $\varepsilon$ of the true fixed point. No guesswork, no heuristic
"looks converged to me" — a mathematical certificate of correctness, computed
from two numbers you already have in hand.

## A concrete example you can check

Abstract guarantees are nice, but let us make one tangible. Fix $b = 1$,
$c = 2$, and a small positive $a$ with $a < \tfrac12$. The operator becomes

$$f(x) = e^{a}\,\log(x + 2).$$

We proved that for every such $a$ there is a *positive* fixed point sitting
between $1$ and $3$. The proof is a clean application of the intermediate value
theorem: at $x = 1$, the function $f(1) = e^a \log 3$ exceeds $1$ (because
$\log 3 > 1$ and $e^a \ge 1$), so $f$ starts *above* the diagonal line
$y = x$; at $x = 3$, even the largest allowed scaling keeps
$e^{1/2}\log 5 \approx 2.65$ below $3$, so $f$ ends up *below* the diagonal.
A continuous curve that starts above a line and ends below it must cross it —
and the crossing point is precisely where $f(x) = x$, a fixed point.

When $a = 0$ this fixed point is the solution of $x^\star = \log(x^\star + 2)$,
which is about $x^\star \approx 1.146$. As $a$ ticks up from zero, the fixed
point drifts smoothly, and a first-order estimate predicts its motion with
error only on the order of $a^2$. The companion numerical demo runs this loop
for $a = 0.01, 0.1, 0.5$ and watches the a posteriori certificate tighten with
every step — a guarantee you can literally print to your screen.

## Why this matters

Most nonlinear maps you might bolt into an algorithm or a learning system are
mysterious: you run them and hope. The EML operator is different. We have shown,
with no loose ends, that within the right parameter window it is a contraction,
that it possesses exactly one fixed point, that iteration converges to it at a
clean geometric rate $\rho$, and — the practical payoff — that you can *certify
in advance and on the fly* how close you are, using only numbers the loop hands
you for free.

That combination is rare and valuable. It promotes the exp-log iteration from a
curiosity to a **certified numerical primitive**: a small, trustworthy gear you
can build larger machines around, confident it will always find its mark and
always tell you when it has. In a world increasingly run by opaque iterative
systems, a piece with a written, checkable warranty is worth a great deal.
