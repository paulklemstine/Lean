# The Tamest Wild Function: How Exp-Log Iteration Always Finds Its Center

## A machine that eats numbers

Imagine a little machine. You feed it a number, it does some arithmetic, and
out comes another number. Then you take *that* number and feed it back in. And
again. And again. Most machines like this behave badly: feed them almost the
same number twice and the outputs fly apart; let them run and the numbers
explode to infinity or crash to nothing. Chaos is the rule, not the exception —
the same mathematics that makes weather unpredictable lives inside even the
simplest feedback loops.

This article is about a machine that refuses to misbehave. Its rule is

$$f(x) = e^{a}\,\log(b\,x + c),$$

where $a$, $b$, and $c$ are fixed dials you set before you start. It first
stretches the input by the linear map $x \mapsto bx+c$, then *compresses* it
violently with a logarithm, then *re-expands* it by the constant factor $e^a$.
Stretch, squash, scale. We call this an **EML operator** — short for
*exponential–minus–logarithm* — because it is built from the same exponential
and logarithmic atoms that appear in nearly every model in science, from
radioactive decay to the activation functions inside neural networks.

The central discovery is that, for the right settings of the dials, this
machine is profoundly, provably tame. No matter where you start, the sequence
of numbers it produces homes in on a single special value — a *fixed point* —
and it does so at a guaranteed, computable speed. Even better, we can pin down
*exactly* which dial settings make this happen, and we can prove that just
outside that region the good behavior collapses in a precise and beautiful way.

Every claim in what follows has been verified down to the last logical step.
There are no hand-waves.

## Fixed points: where the machine stands still

A **fixed point** of the machine is a number $x^\*$ that the machine leaves
unchanged: feed in $x^\*$ and you get $x^\*$ back. In symbols,

$$x^\* = e^{a}\,\log(b\,x^\* + c).$$

Fixed points are the secret skeletons of any iterative process. If a sequence
$x_0, x_1, x_2, \dots$ produced by repeatedly applying $f$ ever settles down to
a limit, that limit *must* be a fixed point — there is nowhere else for it to
go. So the whole story of long-run behavior is really a story about fixed
points: do they exist, how many are there, and does the machine actually march
toward them?

## The secret of the slope

Here is the single idea that controls everything. Ask how sensitive the machine
is to small nudges of its input. That sensitivity is the *slope* (the
derivative) of $f$, and for the EML operator it has a clean closed form:

$$f'(x) = \frac{e^{a}\,b}{b\,x + c}.$$

Read this formula like a dial gauge. The numerator $e^a b$ is fixed; the
denominator $bx+c$ grows as $x$ grows. So as we move to larger inputs, the slope
*shrinks*. When the slope is smaller than $1$ in size, the machine is a
**contraction**: it pulls any two inputs strictly closer together every time it
runs. Two travelers who start a mile apart end up half a mile apart, then a
quarter, then an eighth — squeezed inexorably toward each other.

This is the mechanism behind one of the most useful theorems in all of
mathematics, the *contraction mapping principle*. If a process always shrinks
distances by at least a fixed factor $\rho < 1$, then it has exactly one fixed
point, and every starting value rushes toward it. Our machine inherits this
power whenever its slope stays below $1$ on the working interval.

Concretely, suppose on some interval $[\text{lo}, \text{hi}]$ the slope never
exceeds a number $\rho < 1$ in absolute value, and suppose the machine never
sends a point in that interval outside of it. Then three things are true, and
all three have been proved:

1. **At most one fixed point.** Two fixed points $x_1, x_2$ in the interval
   would satisfy $|x_1 - x_2| \le \rho\,|x_1 - x_2|$ with $\rho < 1$, which
   forces $|x_1-x_2| = 0$. They must coincide.

2. **The orbit converges.** Starting from any $x_0$ in the interval, the
   sequence $x_{n+1} = f(x_n)$ is a Cauchy sequence and therefore converges to
   a genuine fixed point inside the interval.

3. **You can watch it happen at a known speed.** The gaps between consecutive
   steps shrink geometrically, $|x_{n+1} - x_n| \le \rho^n\,|x_1 - x_0|$, and
   the distance to the limit obeys the explicit error bound
   $$|x_n - x^\*| \;\le\; \frac{|x_1 - x_0|\;\rho^n}{1 - \rho}.$$

That last inequality is the prize. It is not a vague promise that "things
converge eventually." It is a certificate: *before you run a single step*, it
tells you exactly how many iterations you need to reach any accuracy you want.
If $\rho = 1/30$, every step buys you roughly another factor of thirty in
precision. This is what turns a curiosity into an algorithm.

## A worked example you can trust

Set the dials to $a = 1$, $b = 1$, $c = 100$, so the machine is

$$f(x) = e^{1}\,\log(x + 100) \approx 2.718\,\log(x + 100),$$

and let it run on the interval $[0, 20]$. On this interval the denominator
$x + 100$ is enormous compared with the numerator $e^1 \approx 2.718$, so the
slope is tiny — never larger than $1/30$. One can check (and it has been
checked) that $f$ keeps every point of $[0,20]$ inside $[0,20]$.

The conclusion is airtight: from *any* starting value in $[0,20]$, the iteration
converges to the unique fixed point $x^\* \approx 12.85$, with the explicit error
guarantee

$$|x_n - x^\*| \;\le\; |x_1 - x_0|\,\frac{(1/30)^n}{1 - 1/30}.$$

After just five steps the error is below one part in twenty million. The machine
finds its center almost instantly, and we can prove the bound without ever
running it.

## The sharp edge of order

Now the deepest part of the story. The original hope was that the machine would
be tame for a whole rectangular block of dial settings — say $a$ between $0$ and
$1$, $b = 1$, and $c$ between $0$ and $1$. That hope is *false*, and the way it
fails is exquisitely precise.

The key is a single inequality about how far the machine can push a point
forward. With $b = 1$, the "gain" $f(x) - x$ can never exceed a value that
depends only on the dials:

$$f(x) - x \;\le\; e^{a}(a - 1) + c.$$

The reason is a classic one-line fact about the logarithm: $\log s \le s - 1$
for every positive $s$. Applied with $s = (x+c)/e^a$, this pins the maximum
possible gain, and the maximum is reached exactly when $x + c = e^a$.

Stare at the right-hand side. If $e^a(a-1) + c$ is **negative**, then
$f(x) - x < 0$ for *every* admissible $x$ — the machine always pushes points to
the *left*, so it can never stand still. There is **no fixed point at all**.
This gives a sharp law:

> **A fixed point exists only if** $\;c \ge e^{a}(1 - a).$

This single threshold demolishes the naive rectangle. Take $a = 1/2$ and
$c = 1/2$ — squarely inside the hoped-for box. Then
$e^{1/2}(1 - 1/2) = \tfrac{1}{2}e^{1/2} \approx 0.824$, which is *bigger* than
$c = 0.5$. The threshold is violated, and so — provably — the machine
$f(x) = e^{1/2}\log(x + 1/2)$ has **no fixed point whatsoever**. Run it from
anywhere and the orbit simply marches off without ever settling. The pretty
rectangle was a mirage.

## The knife's edge

What happens *exactly* on the boundary, when $c = e^a(1 - a)$? Here the
mathematics performs a perfect balancing act. At this critical setting the point
$x^\* = e^a - c$ is a genuine fixed point — but the slope there equals *exactly*
$1$:

$$f'(x^\*) = \frac{e^a}{x^\* + c} = \frac{e^a}{e^a} = 1.$$

A slope of exactly $1$ is the razor's edge between contraction and expansion.
The fixed point is *neutral*: the machine neither pulls toward it nor pushes
away, and the contraction guarantee evaporates. So the boundary of the region
where fixed points *exist* is also the boundary of the region where the machine
is *tame*. The two frontiers coincide — a striking and exact correspondence
between two questions that, at first glance, seem unrelated.

This is the heart of the matter: order does not fade gradually as you turn the
dials. It ends at a sharp wall, defined by the elegant curve $c = e^a(1-a)$, and
on that wall the dynamics hang in perfect, neutral balance.

## Two hands closing on the answer

There is one more pleasing twist. When $b > 0$ the machine is *monotone*:
larger inputs give larger outputs, with no folding or crossing. This lets us
trap the fixed point between two converging sequences, like two hands closing on
a coin in the dark.

Start one orbit at the bottom of the interval, $\ell_0 = \text{lo}$, and another
at the top, $u_0 = \text{hi}$. Monotonicity guarantees the bottom orbit climbs
steadily upward, the top orbit descends steadily downward, and the true fixed
point is *always* sandwiched between them:

$$\ell_n \;\le\; x^\* \;\le\; u_n \quad \text{for every } n.$$

Both sequences converge to $x^\*$, and the width of the bracket $u_n - \ell_n$
shrinks to zero. At every single step the machine hands you not just an estimate
but a *guaranteed interval* containing the true answer. It is self-validating
arithmetic: the computation certifies its own accuracy as it runs.

## Why this matters

The exponential and the logarithm are the workhorses of quantitative science,
and lately they have become the building blocks of machine-learning models,
where functions are stitched together by the millions. The trouble is that most
such building blocks come with no behavioral guarantees at all — feed them into
a feedback loop and anything can happen.

The EML operator is different. We now know, with complete certainty:

- **exactly when** it has a fixed point (the sharp law $c \ge e^a(1-a)$);
- that when it does behave, it converges from *anywhere* in its working range;
- the **precise speed** of that convergence, as a formula you can evaluate in
  advance;
- and a **self-certifying bracket** that boxes in the answer at every step.

A function this well-understood is a safe foundation. It can serve as a
certified iterative solver, a trustworthy layer in a learning system, or a
textbook-clean illustration of how the abstract contraction principle plays out
in a concrete, real-world map. And the lesson it teaches is larger than itself:
that even in a world where feedback usually breeds chaos, there are islands of
perfect, provable order — and we can draw their coastlines exactly.
