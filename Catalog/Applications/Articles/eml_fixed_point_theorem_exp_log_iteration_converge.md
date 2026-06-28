# The Speed of a Settling Echo: How an exp-log Map Finds Its Center

Picture a microphone placed in front of the loudspeaker it feeds. You whisper,
the speaker amplifies, the microphone hears the amplified whisper, the speaker
amplifies *that*, and so on. Sometimes this loop screams — the runaway howl we
call feedback. But sometimes it does the opposite: the sound folds in on itself,
each round a little quieter, a little more settled, until it lands on a single
steady tone and stays there. That settling, and above all *how fast* it settles,
is the subject of this story.

We will follow one particularly elegant feedback loop built from two of
mathematics' most famous functions — the exponential and the logarithm — and we
will pin down, exactly, the speed at which it finds its resting point.

## A machine that squeezes and stretches

Consider the rule

$$f(x) = e^{a}\,\log(b\,x + c).$$

It has three dials: $a$ scales the output by the fixed factor $e^a$, while $b$
and $c$ shape the input fed into the logarithm. Mathematicians studying
neural-network-style building blocks call this the **EML operator** — short for
"exp-minus-log," because it threads an input through a logarithm and then blows
it back up with an exponential. The logarithm is a great compressor: it takes a
sprawling range of inputs and crushes them into a narrow band of outputs. The
exponential factor $e^a$ then re-stretches that band. The interplay of squeeze
and stretch is exactly what makes the map interesting.

Now turn $f$ into a feedback loop. Pick a starting number $x_0$, then iterate:

$$x_1 = f(x_0), \quad x_2 = f(x_1), \quad x_3 = f(x_2), \quad \dots$$

This is the loudspeaker-and-microphone idea in pure arithmetic form. Each step
feeds the previous output back as the next input. The question is the same one a
sound engineer asks: does the sequence run away, or does it settle?

## The resting point

If the sequence settles, it must settle on a number $x^\*$ that the map leaves
unchanged — a value where the output equals the input:

$$f(x^\*) = x^\*, \qquad \text{that is,} \qquad x^\* = e^{a}\,\log(b\,x^\* + c).$$

Such a number is called a **fixed point**. It is the steady tone of our feedback
loop, the place where amplification and compression exactly cancel. For a
concrete feel, take $a = 0.2$, $b = 1$, $c = 2$, so the rule is
$f(x) = e^{0.2}\log(x + 2)$. Start anywhere reasonable — say $x_0 = 3$ — and the
iteration marches:

$$3 \to 1.966 \to 1.683 \to 1.592 \to 1.562 \to \cdots \to 1.546116\ldots$$

The number $x^\* = 1.546116\ldots$ is the fixed point. And here is a striking
fact you can check for yourself: it does not matter where you start. Begin at
$1$, at $2.5$, at $3$ — every starting value inside a sensible window funnels to
the very same $1.546116\ldots$. The resting point is **unique**, and it is a
genuine attractor that pulls in its whole neighborhood.

## Why it settles: the contraction principle

The reason for this orderly behavior is one of the most useful ideas in all of
analysis: the **contraction principle**. A map is a *contraction* if it always
shrinks distances — if you take any two points and apply the map, the two images
are closer together than the originals were. Squeeze any two points repeatedly
and they are forced to converge to a single common destination. That destination
is the fixed point, and the squeezing guarantees it is the *only* one.

How do we know the EML map squeezes? We look at its steepness — its derivative.
A direct computation gives

$$f'(x) = \frac{e^{a}\,b}{b\,x + c}.$$

The size of the derivative is the local "stretch factor": where $|f'| < 1$ the
map pulls points together, and where $|f'| > 1$ it pushes them apart. The
logarithm's defining virtue is that its slope *decreases* as its input grows, so
on a suitable window $[\text{lo}, \text{hi}]$ — chosen so the map sends the
window back into itself — the derivative stays below some ceiling $\rho < 1$.
Once every step shrinks distances by at least the factor $\rho$, the whole
sequence is trapped into convergence. This is the rigorous backbone behind the
intuition of the settling echo.

The contraction ceiling $\rho$ even comes with a *guarantee on the books*: from
the very first step you can bound how far you still are from the target,

$$|x_n - x^\*| \;\le\; |x_1 - x_0|\,\cdot\,\frac{\rho^{\,n}}{1 - \rho}.$$

This is a remarkable kind of certificate. After a single step you already know,
with certainty, an upper limit on every future error. In our example the
interval ceiling is $\rho \approx 0.407$, and indeed the true error at every step
stays comfortably underneath the predicted envelope. The error shrinks
geometrically — it is multiplied by roughly $\rho$ each round — so the digits of
accuracy pile up at a steady linear pace.

## The real question: not *whether*, but *how fast*

That the loop settles is satisfying. But the sharper, more honest question is:
**how fast, exactly?** The contraction ceiling $\rho \approx 0.407$ is only an
upper bound — a worst-case promise computed over the entire window. The true
long-run speed could be anything below it. What is the *actual* asymptotic rate?

Here is the punchline of this work. Watch the ratio of consecutive errors — how
much smaller each error is than the one before:

$$\frac{|x_{n+1} - x^\*|}{|x_n - x^\*|}.$$

If the loop contracted by exactly $\rho$ every step, this ratio would sit at
$\rho \approx 0.407$. It does not. In our example it climbs steadily and locks
onto a *different*, smaller number:

$$0.289,\ 0.326,\ 0.338,\ 0.342,\ 0.3437,\ 0.34437,\ \dots \to 0.344434\ldots$$

And $0.344434\ldots$ is not $\rho$. It is precisely the steepness of the map
*at the fixed point itself*:

$$|f'(x^\*)| = \left|\frac{e^{a}\,b}{b\,x^\* + c}\right| = 0.344434\ldots$$

This is the central result, and it is exact:

> **The sharp asymptotic rate.** For a non-degenerate start $x_0 \ne x^\*$, the
> ratio of consecutive errors converges to the magnitude of the derivative at
> the fixed point:
> $$\frac{|x_{n+1} - x^\*|}{|x_n - x^\*|} \;\longrightarrow\; |f'(x^\*)| = \left|\frac{e^{a}\,b}{b\,x^\* + c}\right|.$$

The intuition is beautiful and clean. Far from the target, the map's slope
varies and the worst-case ceiling $\rho$ rules. But as the iterates crowd in on
$x^\*$, the only steepness that matters is the steepness *right there*. Near the
fixed point the curved map looks like a straight line with slope $f'(x^\*)$, and
multiplying an error by that slope each step is exactly what the data show. The
window-wide ceiling $\rho$ was a safe overestimate; the true long-run rate is the
local slope, and it is always at least as good:

$$|f'(x^\*)| \;\le\; \rho \;<\; 1.$$

The settling is therefore not just guaranteed — it is guaranteed to be *at least
as fast* as the headline promise, and we know the precise number it tends to.

## Why a tiny condition matters

There is one delicate ingredient, and it is worth pausing on because it shows how
careful mathematics must be. The sharp-rate statement insists the starting point
be *non-degenerate*: $x_0 \ne x^\*$. Why fuss over this? Because if you happen to
start *exactly* on the fixed point, the sequence never moves — every error is
zero, and the ratio becomes the meaningless $0/0$. The clean limit $|f'(x^\*)|$
genuinely requires that you start off-target, and then it requires something more
subtle: the iterates must *never accidentally land* on $x^\*$ either.

This is where the dial $b > 0$ earns its keep. When $b$ is positive the
derivative $f'(x) = e^{a} b / (bx + c)$ is positive throughout the window, which
means the map is strictly increasing — it never folds two different inputs onto
the same output. A strictly increasing map is **injective**: distinct inputs give
distinct outputs. So if you start away from $x^\*$, you stay away from $x^\*$
forever, the ratio is always a legitimate fraction, and the limit is honest. A
single sign condition on one parameter is what keeps the entire asymptotic story
from collapsing into $0/0$.

## A dial you can turn: faster convergence on demand

Once you know the true rate is $|f'(x^\*)| = e^a b / (bx^\* + c)$, you can ask how
to make the loop settle *faster*. The formula points to an answer: grow the
denominator. Increasing the shift $c$ does two things at once — it pushes the
fixed point $x^\*$ to a larger value *and* enlarges $bx^\* + c$ directly. Both
shrink the derivative, so larger $c$ means a smaller rate and quicker
convergence. The numbers bear this out cleanly:

| shift $c$ | fixed point $x^\*$ | rate $|f'(x^\*)|$ |
|-----------|--------------------|-------------------|
| $1.5$     | $1.224$            | $0.448$           |
| $2.0$     | $1.546$            | $0.344$           |
| $3.0$     | $1.955$            | $0.247$           |
| $5.0$     | $2.453$            | $0.164$           |
| $10.0$    | $3.147$            | $0.093$           |

Turn the shift dial up and the echo settles in a fraction of the rounds. This is
the practical payoff of knowing the *exact* rate rather than a loose bound: it
turns a qualitative "it converges" into a quantitative recipe for tuning how fast.

## The fixed point as a smooth function of its dial

A final flourish. As you nudge the scaling dial $a$ away from zero, the fixed
point $x^\*$ drifts smoothly. At $a = 0$ the equation collapses to
$x^\* = \log(x^\* + 2)$ with solution $x^\*(0) = 1.146193\ldots$. Turn $a$ up a
little and $x^\*$ moves along a predictable track whose initial slope is

$$\frac{dx^\*}{da} = \frac{x^\*}{1 - f'(x^\*)} = 1.6803\ldots$$

The denominator $1 - f'(x^\*)$ is positive *precisely because* $|f'(x^\*)| < 1$ —
the same contraction inequality that made everything settle in the first place
also guarantees the fixed point varies smoothly with the parameter. So a single
clean fact, "the local slope is below one," does triple duty: it forces
convergence, it sets the exact speed of that convergence, and it makes the
resting point itself a smooth, differentiable function of the dial you turn.

## Why this matters

It is tempting to dismiss all this as the careful accounting of a small example.
But the EML map is a stand-in for a whole class of building blocks used in
modern computation — squeeze-and-stretch units that appear, in various guises,
inside learning systems and iterative solvers. Most such building blocks are
wild: their feedback loops can oscillate, diverge, or behave unpredictably,
which is why iterating them is usually avoided. The EML map is different. It is
*tame*. Its loop is guaranteed to settle, to a unique point, at a rate we can
write down exactly and even tune at will.

That tameness is the real prize. An iterative algorithm built on the EML map
comes with a certificate: it will converge, you know to where, you know how fast,
and you know how to make it faster. In a computational world full of processes
that merely "seem to work," a map whose settling speed is pinned to a single
exact number — the slope at its own center — is a small but genuine piece of
certainty.
