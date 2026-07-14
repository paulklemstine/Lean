# One Number That Decides Whether Counting Curves Up or Down

## A single knob for a whole zoo of sequences

Some of the most famous sequences in mathematics are, at heart, machines that
build each term from the one before by a simple rule. Powers of two double at
every step: $1, 2, 4, 8, 16, \dots$. Factorials multiply by an ever-growing
integer: $1, 1, 2, 6, 24, 120, \dots$. The Catalan numbers — the counts of
balanced parenthesizations, of triangulations of a polygon, of paths that stay
above a diagonal — run $1, 1, 2, 5, 14, 42, 132, \dots$. The central binomial
coefficients $\binom{2n}{n}$ go $1, 2, 6, 20, 70, \dots$.

At first glance these look like utterly different beasts. But they share a
hidden skeleton. Each of them satisfies a *first-order multiplicative
recurrence* of the shape

$$(\alpha\, n + \beta)\, a(n+1) = (\gamma\, n + \delta)\, a(n).$$

In words: to pass from one term to the next, you multiply by a ratio that is
itself a simple fraction of straight lines in $n$,

$$\frac{a(n+1)}{a(n)} = \frac{\gamma\, n + \delta}{\alpha\, n + \beta}.$$

For powers of two the ratio is the constant $2$. For factorials it is $n+1$.
For the Catalan numbers it is $\tfrac{2(2n+1)}{n+2}$. Four little numbers
$\alpha, \beta, \gamma, \delta$ encode the entire growth law.

This article is about a discovery that is almost embarrassingly clean: **a
single scalar built from those four numbers decides the entire "shape" of the
sequence's growth.** We call it the *Möbius discriminant*,

$$\Delta = \gamma\beta - \alpha\delta.$$

Its *sign* tells you whether the sequence curves upward, runs perfectly
straight, or curves downward when you plot its logarithm. And — the surprise of
this work — its *exact value* controls precisely *how much* it curves, term by
term, with no error and no approximation.

## Curving up, curving down: log-convexity

To see what "shape" means, take logarithms. A sequence of positive numbers is
called **log-convex** if the sequence of its logarithms is convex — if each term
sits *below* the average of its neighbours:

$$\log a(n+1) \le \tfrac{1}{2}\big(\log a(n) + \log a(n+2)\big).$$

Equivalently, in the original numbers, $a(n)\,a(n+2) \ge a(n+1)^2$: the product
of two neighbours dominates the square of the middle term. Log-convexity is the
signature of "accelerating" growth, and it is a prized property — it underlies
inequalities, unimodality of coefficients, and the good behaviour of generating
functions. The mirror image is **log-concavity**, $a(n)\,a(n+2) \le a(n+1)^2$,
the signature of growth that is tapering relative to a pure exponential. Dead
in the middle is **log-linearity**, where $a(n)\,a(n+2) = a(n+1)^2$ exactly and
the logarithm marches in a perfectly straight line — the fingerprint of a pure
geometric sequence like $2^n$.

The quantity that measures which side you are on is the **pointwise
discriminant**

$$D(n) = a(n)\, a(n+2) - a(n+1)^2.$$

Positive means log-convex at that spot; zero means log-linear; negative means
log-concave.

## The main theorem: sign, then size

Here is the first and central result.

> **Theorem (Exact discriminant identity).** For any sequence obeying the
> recurrence $(\alpha n + \beta)\,a(n+1) = (\gamma n + \delta)\,a(n)$, the
> pointwise discriminant satisfies the exact identity
> $$(\alpha n + \beta)\,(\alpha (n+1) + \beta)\, D(n) = \Delta \cdot a(n)\, a(n+1),
> \qquad \Delta = \gamma\beta - \alpha\delta.$$

Read this slowly, because a lot is packed into it. The left factor
$(\alpha n + \beta)(\alpha(n+1)+\beta)$ is the product of two of the linear
"denominators" of the growth ratio; when the sequence is genuinely positive with
positive denominators, this factor is positive. On the right, $a(n)\,a(n+1)$ is
a product of two positive terms. So the *entire sign of $D(n)$ is inherited from
$\Delta$, at every single index* — nothing about $n$ can ever flip it. And this
needs no cleverness about positivity to prove: it is a pure algebraic identity,
squeezed out of the recurrence written at $n$ and at $n+1$.

The immediate consequence is a crisp **trichotomy**:

- If $\Delta > 0$, then $D(n) > 0$ for all $n$: the sequence is **strictly
  log-convex** everywhere.
- If $\Delta = 0$, then $D(n) = 0$ for all $n$: the sequence is exactly
  **log-linear** — geometric.
- If $\Delta < 0$, then $D(n) < 0$ for all $n$: the sequence is **strictly
  log-concave** everywhere.

One number. Three regimes. No exceptions.

## The zoo, sorted

The beauty of a clean invariant is that you can compute it in your head and
instantly classify the classics.

| Sequence | Ratio $a(n+1)/a(n)$ | $(\alpha,\beta,\gamma,\delta)$ | $\Delta = \gamma\beta - \alpha\delta$ | Verdict |
|---|---|---|---|---|
| Powers of two $2^n$ | $2$ | $(0,1,0,2)$ | $0$ | log-linear |
| Reciprocal factorials $1/n!$ | $\tfrac{1}{n+1}$ | $(1,1,0,1)$ | $-1$ | log-concave |
| Factorials $n!$ | $n+1$ | $(0,1,1,1)$ | $+1$ | log-convex |
| Central binomials $\binom{2n}{n}$ | $\tfrac{2(2n+1)}{n+1}$ | $(1,1,4,2)$ | $+2$ | log-convex |
| Catalan $C_n$ | $\tfrac{2(2n+1)}{n+2}$ | $(1,2,4,2)$ | $+6$ | log-convex |

Every classical total lands exactly where the Möbius discriminant says it
should. The factorials, central binomials, and Catalan numbers are all
log-convex — and now we know *why*, and by *how much*: their discriminants are
$+1, +2, +6$. Reciprocal factorials, decaying faster than any geometric
sequence, come out log-concave with $\Delta = -1$. And the powers of two sit on
the knife-edge $\Delta = 0$, the only regime where the logarithm is a perfect
straight line.

For the Catalan numbers the general identity specializes to a concrete gem:

$$(n+2)(n+3)\,\big(C_n C_{n+2} - C_{n+1}^2\big) = 6\, C_n\, C_{n+1}.$$

The mysterious $6$ on the right is nothing but the Catalan discriminant
$\Delta = 6$, made flesh.

## Why "Möbius"? The ratio and its curvature

The name comes from the shape of the growth ratio itself. A *Möbius
transformation* is a fraction of two linear expressions,
$x \mapsto \tfrac{\gamma x + \delta}{\alpha x + \beta}$ — the same objects that
rotate the sphere in complex analysis and tile the hyperbolic plane. Our growth
ratio $\tfrac{\gamma n + \delta}{\alpha n + \beta}$ is exactly such a
transformation, evaluated at the integer $n$.

Möbius transformations have a rigid property: the difference between consecutive
values has a numerator that never depends on where you are. Sure enough, the
step-to-step change in the growth ratio is

$$\frac{a(n+2)}{a(n+1)} - \frac{a(n+1)}{a(n)}
= \frac{\Delta}{(\alpha n + \beta)(\alpha (n+1) + \beta)}.$$

The numerator is the *constant* $\Delta$; only the denominator moves. So the
discriminant is not merely a sign — it is the fixed "acceleration" of the growth
ratio, the amount by which the multiplier itself speeds up or slows down at
every step.

Push this one notch further and you get an exact formula for the curvature of
the logarithm. Define the log-curvature as the second difference

$$\log a(n) - 2\log a(n+1) + \log a(n+2).$$

Then

$$\frac{a(n)\, a(n+2)}{a(n+1)^2}
= 1 + \frac{\Delta}{(\gamma n + \delta)(\alpha (n+1) + \beta)},$$

and taking logarithms,

$$\log a(n) - 2\log a(n+1) + \log a(n+2)
= \log\!\left(1 + \frac{\Delta}{(\gamma n + \delta)(\alpha (n+1) + \beta)}\right).$$

This is a complete, closed-form description of how bent the graph of the
logarithm is, at every point. And it carries a punchline about the far future:
when $\alpha$ and $\gamma$ are positive, the denominator grows without bound, the
correction term dies away, and the log-curvature tends to $0$. In geometric
language, the "valuation" $-\log a(n)$ becomes **asymptotically a straight
line** — every one of these sequences eventually looks exponential, with a small
persistent bend whose entire strength is carried by the single number $\Delta$.

## The boundary of the miracle

A clean law invites a greedy question: does the same trick work one level up?
Many celebrated sequences — the Motzkin numbers, the Baxter numbers, the
Fibonacci numbers — do not satisfy a first-order rule but a *second-order* one,

$$p(n)\, a(n+2) = q(n)\, a(n+1) + r(n)\, a(n).$$

It is tempting to conjecture a "second discriminant" $\Delta_2$, built only from
the coefficients $p, q, r$, whose sign again governs log-convexity. This work
settles that hope — in the negative — with a single, decisive counterexample.

The Fibonacci numbers $1, 1, 2, 3, 5, 8, 13, \dots$ obey the simplest possible
second-order rule, $a(n+2) = a(n+1) + a(n)$, with *constant* coefficients
$p = q = r = 1$. Any discriminant built purely from those coefficients would
therefore be a single fixed number with a single fixed sign. But the Fibonacci
discriminant is the celebrated **Cassini identity**:

$$F_n\, F_{n+2} - F_{n+1}^2 = (-1)^{n+1}.$$

It equals $+1$ at odd indices and $-1$ at even indices — flipping sign forever,
infinitely often in each direction. No constant can be both positive and
negative, so **no coefficient-only second-order discriminant can exist.** The
first-order world, where one scalar rules everything, is genuinely special. The
miracle has a sharp edge, and we have found it.

## Why it matters

Log-convexity and log-concavity are not idle curiosities. They control whether a
sequence of coefficients is unimodal (rises then falls with a single peak),
whether associated probability distributions are well-behaved, whether
generating functions have the analytic properties combinatorialists rely on, and
whether classical inequalities hold. Traditionally each sequence is checked by
hand, with a bespoke argument. What this work offers instead is a *dictionary*:
read off four coefficients from the growth rule, compute one difference
$\gamma\beta - \alpha\delta$, and you know the shape immediately — not just its
sign, but its exact strength at every term and its precise decay into the
asymptotic straight line.

That a whole menagerie of counting sequences — parenthesizations, lattice paths,
factorials, binomials — should all bow to the sign of a single tiny determinant
is the kind of unification that makes mathematics feel less like a catalogue and
more like a landscape. And knowing exactly where that unification stops, at the
Fibonacci wall, is just as valuable as the unification itself.
