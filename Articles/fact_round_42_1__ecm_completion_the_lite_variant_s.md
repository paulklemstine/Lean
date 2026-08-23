# The Ladder That Went Nowhere

## How a factoring experiment produced a beautiful number — and why that number was a mirage

There is a particular kind of scientific pleasure in a measurement that lands
exactly where theory says it should. You run an experiment across a range of
problem sizes, you plot the cost against the logarithm of the input, you fit a
line, and the slope comes out at $0.48$ — within noise of the $1/2$ that a
"birthday" argument predicts. Four different methods, measured on the same
population of numbers, now sit on a single plane: trial division at $0.84$,
Pollard's rho at $0.52$, Fermat's method at $0.50$, and this new arm at
$0.48$. The picture is tidy. The picture is convincing.

The picture is wrong.

This is the story of how a stripped-down variant of the elliptic curve
factoring method appeared to obey a square-root scaling law, and how a careful
look at the underlying group theory shows that it cannot — that its true
exponent is $1$, that its apparent $0.48$ is an artifact of a four-bit
measurement window, and that the reason is a single, sharp, and rather elegant
theorem about what a sequence of point additions can possibly see.

Along the way we will meet a bug that killed an entire experiment on its first
line, a counting identity involving Euler's totient function, and an
exponential gap between two ways of climbing the same ladder.

---

## Factoring by accident

Every modern integer factoring method that is not simply trial division works
by the same beautiful trick: *you try to compute something, and you hope the
computation fails.*

Suppose you want to factor $N = pq$ where $p$ and $q$ are large unknown primes.
You pick an elliptic curve — a cubic equation like

$$y^2 = x^3 + ax + b$$

— and you work with its points *modulo $N$*. Points on an elliptic curve can be
added to each other by a geometric rule: draw the line through two points, find
the third intersection with the curve, reflect it across the $x$-axis. Written
out in coordinates, that rule requires a division, and division modulo $N$
means inverting a number modulo $N$.

Here is the trick. Modulo a prime, every nonzero number is invertible. Modulo a
composite $N$, some are not: the inversion fails precisely when the number you
are trying to invert shares a factor with $N$. And when that happens, the
extended Euclidean algorithm that was supposed to compute the inverse hands you
$\gcd(\text{denominator}, N)$ instead — a nontrivial factor of $N$, delivered
free of charge by the failure of the arithmetic.

So the entire method is: perform many curve additions and wait for a crash.

What makes a crash happen? Work modulo the hidden prime $p$. The points of the
curve modulo $p$ form a finite abelian group $E(\mathbb{F}_p)$, whose size lies
in the Hasse interval $[p + 1 - 2\sqrt p,\, p + 1 + 2\sqrt p]$ — so roughly $p$
points. A denominator vanishes modulo $p$ exactly when two of the points being
combined have the same $x$-coordinate. Because the curve is symmetric under the
*elliptic involution* $Q \mapsto -Q$, two points share an $x$-coordinate exactly
when they are equal or opposite.

The whole game, then, reduces to a question about a finite group: *given a
starting point $P$ and a schedule of multiples you intend to compute, when do
two of those multiples coincide up to sign?*

---

## Two ladders

Real ECM — the elliptic curve method as Hendrik Lenstra invented it in 1985 —
computes a single enormous multiple of $P$:

$$k \cdot P, \qquad k = \operatorname{lcm}(1, 2, 3, \dots, B).$$

This $k$ is astronomically large (for $B = 50$ it exceeds $10^{21}$), but it can
be computed with only about $B$ point operations by repeated doubling. Its
virtue is *smoothness*: $k \cdot P = 0$ in $E(\mathbb{F}_p)$ precisely when the
order of $P$ divides $\operatorname{lcm}(1,\dots,B)$ — that is, when the order
is **$B$-smooth**, built only from prime powers below $B$. Smooth numbers are
abundant, and this abundance is exactly why ECM works.

The "lite" variant — the object of this investigation — does something that
looks superficially similar and is in fact catastrophically different. It walks
the *sequential* multiples:

$$P,\ 2P,\ 3P,\ \dots,\ B \cdot P,$$

one step at a time, and watches for a failed inversion along the way. No lcm,
no smoothness, just counting.

The first theorem says what this buys you, and the answer is: almost nothing.

> **The Lite Window Theorem.** Let $P$ be a point of finite order in an abelian
> group, and let $B \ge 2$. Some multiple $jP$ with $2 \le j \le B$ vanishes if
> and only if the order of $P$ is at most $B$.

The proof is one line in each direction. If $jP = 0$ then $\operatorname{ord}(P)$
divides $j \le B$, so the order is at most $B$. Conversely, if the order $d$ is
at most $B$ then $d$ itself is a legal choice of $j$ (or $j = 2$ if $d = 1$),
and $dP = 0$ by definition. Compare this with the corresponding statement for
true ECM — the order must merely be $B$-smooth — and the loss is stark.

How stark? Take the cyclic group $\mathbb{Z}/96$ and $B = 50$. Since
$96 = 2^5 \cdot 3$, and both $32$ and $3$ lie below $50$, the number $96$
divides $\operatorname{lcm}(1,\dots,50)$: true ECM annihilates the generator
instantly. The sequential run stops at $50$ and never sees an order-$96$ point
at all. The two arms are not variants of one another; one is strictly, and
badly, weaker.

---

## The sharp window, and the bug it explains

That first theorem is not quite the truth about the real algorithm, because a
real implementation does not only detect $jP = 0$. It detects any *repeated
$x$-coordinate* in the run, and the elliptic involution gives it a second
chance: $iP$ and $jP$ share an $x$-coordinate when $iP = jP$ (so the order
divides $j - i$) **or** when $iP = -(jP)$ (so the order divides $i + j$). The
sums reach further than the differences, and the window widens.

> **The Sharp Detection Window.** For $B \ge 3$ and a base point $P$ of finite
> order, the sequential run $P, 2P, \dots, BP$ produces a repeated
> $x$-coordinate if and only if
> $$\operatorname{ord}(P) \le 2B - 1.$$
> Moreover a point of order exactly $2B$ is invisible: the window cannot be
> widened.

Both endpoints are attained, and the proof is a small case analysis. If the
order $d$ is at most $B - 1$, the plain repetition $1 \cdot P = (1+d) \cdot P$
lies inside the run. If $d = B$, the involution pair $1 + (B-1) = d$ does the
job. If $B < d \le 2B - 1$, take the pair $(d - B) + B = d$, both indices legal.
Conversely, any collision forces $d$ to divide either $j - i \le B - 1$ or
$i + j \le 2B - 1$, and a positive divisor is at most its multiple.

This theorem does something rather satisfying: it explains a bug. The first
version of the experiment produced an *instant* factorization on every single
curve — a result too good to be true, and indeed false. Structurally, the
degenerate event is the bottom end of the window:

> **The Two-Torsion Degeneracy.** For a point of finite order, $2P = 0$ if and
> only if $\operatorname{ord}(P) \le 2$.

An implementation whose running point at step $j = 2$ has not actually been
advanced past the base point is comparing $P$ with $P$. It therefore
manufactures the "$\operatorname{ord} \le 2$" event artificially, on every
curve, and reports a vanishing denominator immediately. The fix was an explicit
doubling. The theorem tells you that the buggy behaviour was not random noise:
it was the algorithm faithfully reporting the one order it had been tricked into
seeing.

---

## Counting what can be seen

Now to the scaling question. A single random curve succeeds if its base point
happens to land in the *visible set* — the set of points whose order falls
inside the detection window. So: how big is that set?

> **The Visible-Set Bound.** Suppose that in a finite abelian group $G$, for
> every $d \ge 1$ the equation $d \cdot a = 0$ has at most $d^k$ solutions.
> Then the number of points of order at most $B$ is at most $B^{k+1}$.

The proof is a fibration: partition the low-order points by their exact order
$d \in \{1, \dots, B\}$; each fibre injects into the solution set of
$d \cdot a = 0$, of size at most $d^k \le B^k$; and there are $B$ fibres.

Cyclic groups have $k = 1$, so the visible set has size at most $B^2$. General
elliptic curve groups over $\mathbb{F}_p$ are of the form
$\mathbb{Z}/m \oplus \mathbb{Z}/n$, which gives $k = 2$ and a bound $B^3$ — still
polynomial in $B$, still independent of $p$. And in the cyclic case one can be
exact:

> **The Totient Count.** In a cyclic group $G$, the number of elements of order
> at most $B$ is exactly
> $$\sum_{\substack{d \mid |G| \\ d \le B}} \varphi(d),$$
> where $\varphi$ is Euler's totient function.

Only divisors of the group order below the bound contribute. There is no lcm in
this formula, no smoothness, no cleverness: a truncated divisor sum, and nothing
more.

Here is the gap made concrete. Take a cyclic curve group of order
$1058400 = 2^5 \cdot 3^3 \cdot 5^2 \cdot 7^2$ — a perfectly ordinary $50$-smooth
number. True ECM at $B = 50$ annihilates *every one* of those $1058400$ points,
because the whole group order is $50$-smooth. The lite arm at the same bound
sees at most $2500$ of them. A loss of more than a factor of $400$, purchased
by nothing but the decision to count instead of to take a least common multiple.

---

## Why $0.48$ cannot be right

We can now do the scaling arithmetic that kills the headline.

A random curve's base point is essentially uniform among roughly $p$ points, of
which at most $B^2$ are visible. So the per-curve success probability $q$
satisfies $q \le B^2/p$. Over $C$ independent curves, the union bound (a
consequence of Bernoulli's inequality, $1 - (1-q)^C \le Cq$) gives:

> **The Curve-Budget Lower Bound.** If each curve succeeds with probability at
> most $B^2/p$, then any campaign of fewer than $p/(2B^2)$ curves has overall
> success probability below $1/2$.

With $B$ *fixed* — and $B_1 = 50$ was fixed throughout the experiment — the
required budget is $\Theta(p)$. It grows linearly in the hidden prime. And a
linear function eventually beats any constant multiple of a square root:

> **A Fixed Window Refutes Square-Root Scaling.** For every fixed bound $B$ and
> every constant $c$, there exists a prime size $p$ with
> $$c\sqrt{p} < \frac{p}{2B^2}.$$

So the exponent of the fixed-window lite arm is $1$, not $1/2$. The reported
slope of $0.48$ per bit of $p$ cannot be an asymptotic property of the method.
Indeed, an uncensored replication of the experiment over genuinely random
curves — one that does not discard the $3.1\%$ of targets on which the run
failed to finish — recovers a slope of $0.99$–$1.03$, exactly as the theorem
demands, and it does so on precisely the same $16$-to-$20$-bit range where the
original measurement read $0.48$.

Where, then, did $0.48$ come from? The exponent bookkeeping is transparent. If a
campaign's per-curve visible mass is $p^\alpha$, the budget is
$p / p^\alpha = p^{1-\alpha}$. Since the visible mass is $B^2$, a measured
budget exponent $1 - \alpha$ corresponds to an *effective* stage-one bound

$$B_{\mathrm{eff}} = p^{\alpha/2}.$$

A slope of $0.48$ means $\alpha = 0.52$ and $B_{\mathrm{eff}} \approx p^{0.26}$.
At $k = 16$ bits that is $2^{4.2} \approx 18$; at $k = 20$ bits it is
$2^{5.2} \approx 37$. The fixed bound actually used was $B_1 = 50 = 2^{5.6}$.
Over a four-bit range, a constant is numerically indistinguishable from a slowly
growing power. **The fixed window masqueraded as a growing one, and the
masquerade held for exactly as long as the measurement range was narrow.**

There is a genuine crossover, and it is worth naming: a bound growing like
$p^{1/4}$ produces exactly a $\sqrt p$ budget, since $p/(2 \cdot (p^{1/4})^2) =
\sqrt p / 2$. And the lite arm can match Pollard's rho — which costs $\sqrt p$
operations — if and only if its bound $B$ is already of order $\sqrt p$. At that
point the "smoothness bound" has stopped being a smoothness bound and has become
a birthday search wearing a curve as a costume.

---

## The addition-chain barrier

That is the negative half of the story. The positive half asks a sharper
question: forget the specific schedule; *per point operation*, how far can any
stage-one computation possibly reach?

The right abstraction is an **addition chain**: a sequence $m_0, m_1, m_2,
\dots$ of multiples with $m_0 = 1$, where each new entry is the sum of two
previously computed entries. That is exactly what a sequence of curve additions
can produce — you can add any two points you already have, but nothing else.

> **The Per-Operation Barrier.** In any addition chain, $m_t \le 2^t$.

The proof is a two-line strong induction: $m_0 = 1 = 2^0$, and
$m_{t+1} = m_i + m_j$ with $i, j \le t$, so $m_{t+1} \le 2^t + 2^t = 2^{t+1}$.

The bound is attained — by the doubling ladder $1, 2, 4, 8, \dots$, whose
$t$-th entry is exactly $2^t$. So $2^t$ is not merely an upper bound but the
precise optimum. And the sequential run? Its $t$-th entry is $t + 1$. Linear
against exponential.

Combining the barrier with the window theorem gives the general statement:

> **Bounded Reach Bounds Detection.** If a run only ever forms multiples of size
> at most $M$, then every order it can detect through an $x$-coordinate
> coincidence is at most $2M$ — regardless of *which* multiples they are.

And so the two ladders separate, spectacularly:

> **Exponential Versus Linear at Equal Cost.** For $t \ge 3$, the doubling
> ladder of length $t$ annihilates the generator of $\mathbb{Z}/2^t$, whose
> order $2^t$ lies far outside the detection window $[1,\, 2(t+1)-1]$ of the
> sequential run of the *same length*.

The arithmetic behind it is the elementary inequality $2t + 1 < 2^t$ for
$t \ge 3$. The consequence is that the lite arm does not merely forfeit
smoothness: at equal operation count it forfeits an exponential factor of raw
reach.

---

## The shape of the window matters, not just its size

The last movement of the piece is the prettiest, because it shows that even
among schedules of the same length, the sequential choice is a specific and bad
one.

Fix any finite set $J$ of multiples to visit. When does the run over $J$ detect
a base point of order $d$? Exactly when some pair $i < j$ in $J$ has
$d \mid j - i$ (a plain repetition) or $d \mid i + j$ (an involution pair). This
is a pure divisibility criterion — the group has been factored out entirely.

Now compare two visiting sets of the same size, both costing three additions:

- **Sequential:** $J = \{1, 2, 3, 4\}$. Its differences are $\{1,2,3\}$, its
  sums are $\{3,4,5,6,7\}$. It detects exactly the orders $1$ through $7$ — a
  perfect contiguous block, and nothing beyond.
- **Geometric:** $J = \{1, 2, 4, 8\}$. Its differences are $\{1,2,3,4,6,7\}$,
  its sums $\{3,5,6,9,10,12\}$. It detects the orders $9$, $10$ and $12$, every
  one of which the sequential set misses.

Concretely: a base point of order $12$ is found by the run over
$\{1, 2, 4, 8\}$ and missed by the run over $\{1, 2, 3, 4\}$, at identical cost
of three curve additions.

The sequential run is the schedule that *maximises the contiguous window and
minimises the reach*. It is optimal for a criterion nobody asked for.

---

## What the episode teaches

Three things, none of them about elliptic curves specifically.

**First: exponents measured over four bits are not exponents.** The apparent
birthday scaling of the lite arm was a real feature of the data and a false
feature of the world. Any fixed-parameter method will, over a narrow enough
range, mimic a method whose parameter grows — because a constant and a slowly
growing power are the same function on a short interval. The only defence is a
structural argument about what the exponent *must* be, and that is precisely
what the visible-set count and the budget bound supply.

**Second: "birthday scaling" needs a definition, and the obvious one is wrong
for curve methods.** Pollard's rho achieves its $\sqrt p$ because it
*accumulates* state: every point it has ever visited remains available to
collide with every future point, so after $n$ steps it has $\binom{n}{2}$
chances rather than $n$. The lite arm accumulates nothing across curves. Each
new curve starts a fresh, independent trial in a fresh group. That structural
fact — not any property of elliptic geometry — is why its exponent is $1$. A
birthday bound is a statement about a growing pool of pairs; there is no pool
here.

**Third: the cost of a factoring method is governed by a single integer** — the
largest multiple it ever forms. The addition-chain barrier says that integer is
at most $2^t$ after $t$ operations; the window theorem says that integer,
doubled, is the largest order you can detect. Everything else is an argument
about how efficiently you spend your way toward that ceiling. True ECM spends
brilliantly: it reaches $\operatorname{lcm}(1,\dots,B)$ in about $B$ operations
and cashes that reach in against the abundance of smooth numbers. The lite arm
walks up the same ladder one rung at a time, arrives at rung $t+1$ after $t$
steps, and wonders why it is not at the top.

The measurement said $0.48$. The mathematics says $1$. The gap between them is
four bits wide, and closing it required knowing exactly which points a sequence
of additions can see — a question with a completely sharp answer.
