# The Self-Correcting Map: How an Exp-Log Loop Always Finds Its Center

Imagine a machine with a single dial. You feed it a number, it does a little
arithmetic, and out comes another number. You take that output, feed it back in,
and turn the crank again. And again. And again. For most machines built this way,
the results wander chaotically, blow up to infinity, or settle into stubborn
oscillations. But for a special family of machines — the ones we call **EML
operators** — something remarkable happens. No matter where you start, the numbers
march inexorably toward a single, predestined value: a *fixed point* the machine
was always going to find.

This article is about one of those machines, a map built from two of the most
fundamental functions in all of mathematics — the exponential and the logarithm —
and about a guarantee so strong that an engineer can stake a calculation on it. Not
"it probably converges." Not "it converges in our experiments." But: *here is the
answer, here is a box that provably contains it, and here is exactly how fast the
box shrinks.*

## The machine in question

The EML operator is the function

$$f(x) = e^{a} \cdot \log(b x + c).$$

Three knobs control it: $a$ scales the output exponentially, $b$ stretches the
input, and $c$ shifts it. The name "EML" stands for **Exp-Minus-Log**, a family of
building blocks studied as a more disciplined alternative to the activation
functions inside neural networks. The exponential factor $e^a$ amplifies; the
logarithm $\log(bx+c)$ compresses. Together they strike a balance: the logarithm
tames runaway growth, while the exponential keeps the output from collapsing.

To *iterate* the machine is to apply it over and over, producing a sequence

$$x_0, \quad x_1 = f(x_0), \quad x_2 = f(x_1), \quad x_3 = f(x_2), \ \ldots$$

The central question is simple to ask and surprisingly deep to answer: **where does
this sequence go?**

## The secret ingredient: contraction

The key to the EML operator's good behavior is a property called *contraction*. A
map is a contraction on some interval if it always pulls pairs of points closer
together. If $x$ and $y$ are two inputs, then their outputs $f(x)$ and $f(y)$ are
strictly nearer to each other than $x$ and $y$ were — by at least a fixed factor
$\rho < 1$:

$$|f(x) - f(y)| \le \rho \, |x - y|.$$

Why does the EML operator contract? The answer lives in its derivative — the
measure of how steeply the output changes as you nudge the input. A direct
calculation, formalized as the theorem `deriv_eq`, gives a clean closed form:

$$f'(x) = \frac{e^{a} \, b}{b x + c}.$$

This is the engine of everything that follows. Notice what it says: as $x$ grows,
the denominator $bx + c$ grows, so the slope $f'(x)$ *shrinks*. The logarithm
flattens out, and with it the whole map. If we can keep the parameters in a range
where this slope stays below $1$ in magnitude on some interval, the map is a
contraction there — it can only ever squeeze.

## Why a contraction always has exactly one home

Here is the beautiful logic. Suppose the machine had *two* different resting
points — two values $x_1^*$ and $x_2^*$, each unchanged by the map, so that
$f(x_1^*) = x_1^*$ and $f(x_2^*) = x_2^*$. Because $f$ is a contraction, applying
it to both must bring them closer:

$$|x_1^* - x_2^*| = |f(x_1^*) - f(x_2^*)| \le \rho \, |x_1^* - x_2^*|.$$

But $\rho < 1$, so this says a positive number is no larger than a fraction of
itself — an impossibility unless that number is zero. Therefore $x_1^* = x_2^*$.
There can be only one. This is the theorem `fixedPoint_unique`, and it is the
mathematical embodiment of destiny: a contraction has at most one fixed point, and
the iteration has no choice but to head for it.

That the point actually *exists* — that the marching sequence really does reach a
limit — is the content of `iterSeq_converges`. The argument shows the sequence is
*Cauchy*: its terms eventually crowd together so tightly that they must accumulate
somewhere, and by continuity that accumulation point is the fixed point. The
combination is the celebrated **Banach fixed-point theorem**, specialized and made
concrete for the exp-log map.

## Not just "it converges" — *how fast*

Knowing that a sequence converges is a comfort; knowing *how fast* is a tool.
Suppose your very first step moved you a distance $|x_1 - x_0|$. Then after $n$
steps you are guaranteed to be within

$$|x_n - x^*| \le \frac{|x_1 - x_0| \cdot \rho^{\,n}}{1 - \rho}$$

of the true answer $x^*$. This is the **a priori error estimate**, proved as
`iterSeq_error_bound`. Every quantity on the right is something you can measure
after a single step. The factor $\rho^n$ shrinks geometrically — each iteration
multiplies your worst-case error by $\rho$ — so the error doesn't just vanish, it
vanishes *exponentially*. The companion result `iterSeq_error_tendsto_zero`
confirms the bound genuinely collapses to zero, certifying honest $O(\rho^n)$
convergence rather than a hollow promise.

To make this vivid: with the contraction ratio $\rho = 1/30$ from our worked
example below, every step buys you another factor of thirty in accuracy. Three
steps and you've gained more than four decimal digits. The convergence is not a
slow crawl; it is a freefall toward the answer.

## A guarantee you can hold in your hand

There is one more turn of the screw, and it is the part a numerical engineer loves
most. So far the guarantees are *one-sided*: they bound the distance to an answer
you cannot yet see. But suppose we add one natural assumption — that $b > 0$, which
makes the map *monotone increasing* (bigger inputs give bigger outputs). The
theorem `op_monotoneOn` establishes exactly this, as a direct consequence of the
logarithm being increasing.

Monotonicity unlocks something wonderful. Start two separate iterations: one from
the bottom of your interval, $\ell_0 = \text{lo}$, and one from the top,
$u_0 = \text{hi}$. Because the map is increasing and maps the interval into itself,
the bottom orbit can only *rise* (`iterSeq_lo_mono`) and the top orbit can only
*fall* (`iterSeq_hi_anti`). And crucially, the fixed point $x^*$ is sandwiched
between them at *every single step*:

$$\ell_n \le x^* \le u_n \quad \text{for all } n.$$

The two orbits are like a pair of hands slowly closing around the answer from below
and above. The gap between them, $u_n - \ell_n$, shrinks to zero. This is the
**certified two-sided enclosure**, `certified_enclosure`: at any moment you can
stop the computation and report a rigorous interval $[\ell_n, u_n]$ that is
*guaranteed* to contain the true fixed point. Not a point estimate with an
unverified error bar — an honest box with a mathematical seal on it.

This is precisely the form of answer that *interval arithmetic* and *verified
computing* demand. When the result of a calculation will be trusted by a control
system, a proof checker, or a safety-critical algorithm, "approximately $x^*$" is
not good enough. "$x^*$ lies in $[\ell_n, u_n]$, certified" is.

## A concrete machine, fully verified

Abstract guarantees are only as good as the examples that satisfy them, so consider
a specific machine: $f(x) = e \cdot \log(x + 100)$ on the interval $[0, 20]$.
Here $a = 1$, $b = 1$, $c = 100$. The derivative is $f'(x) = e/(x+100)$, which on
$[0,20]$ never exceeds $e/100 < 1/30$. So the contraction ratio is a comfortable
$\rho = 1/30$, and the map sends $[0,20]$ back into itself (since $e \cdot \log(x +
100) < 3 \cdot 5 = 15 < 20$). Every one of these facts is checked rigorously, down
to the numerical estimates $e < 3$ and $\log 120 < 5$.

The result, `concreteEML_certified`, is the whole theory delivered for this one
operator: from *any* starting point in $[0, 20]$, the iteration converges to a
fixed point $x^* \approx 12.85$, with error bounded by $|x_1 - x_0| \cdot
(1/30)^n / (1 - 1/30)$ at step $n$. You can run it on paper. After two iterations
from $x_0 = 0$ you are already correct to several digits.

## The edge of the map: a sharp threshold

The story has a frontier, and it is where the most tantalizing questions live. For
the case $b = 1$, whether the machine has a fixed point at all depends on a razor's
edge in the parameter $c$. The analysis pins down an exact threshold:

$$c_{\text{crit}}(a) = e^{a}(1 - a).$$

Above it, two fixed points exist; below it, none. Exactly at the threshold, the two
points collide and annihilate — and at that collision the derivative equals exactly
$1$, the neutral knife-edge between attraction and repulsion. This is the signature
of a *fold* (or *saddle-node*) *bifurcation*, the same universal phenomenon that
governs tipping points in climate models, the snapping of buckling beams, and the
sudden onset of laser light. Near the threshold the gap between the two fixed
points is conjectured to open like a square root, $x_+ - x_- \approx \kappa(a)
\sqrt{c - c_{\text{crit}}}$ — the universal fingerprint of a fold.

That two fixed points should appear, with the larger one attracting and the smaller
one repelling, and that the threshold itself slides monotonically from
$c_{\text{crit}}(0) = 1$ down to $c_{\text{crit}}(1) = 0$, are the open conjectures
this work sets up for the next expedition.

## Why it matters

It is tempting to dismiss a humble one-dimensional map as a curiosity. But the EML
operator is a microcosm of a much larger ambition: building computational primitives
whose behavior is not merely observed but *guaranteed*. Neural networks are stitched
together from millions of simple nonlinear units, and their unpredictability is the
source of both their power and their peril. The EML program asks a disciplined
question — what if each unit came with a certificate? What if "this loop converges"
were a theorem, not a hope?

The exp-log fixed-point map answers that question for one such unit, completely. It
converges. It converges to a unique point. It converges geometrically fast. And it
hands you, at every step, a provably correct box around the answer. In a world
increasingly run by iterative algorithms whose outputs we are asked to trust, that
combination — convergence, uniqueness, speed, and a certificate — is exactly the
kind of bedrock worth building on.
