# The Three Numbers Everyone Calls $k^\*$

## How one overloaded symbol quietly inflates search budgets — and the exact arithmetic that untangles it

There is a particular kind of mistake that never announces itself. It doesn't crash a
program, doesn't produce an absurd number, doesn't trip any alarm. It just makes an
answer wrong by a small, plausible amount — one or two units — and then that answer gets
copied into the next document, and the next, until nobody remembers where it came from.

This is a story about one such mistake, hiding inside a single symbol: $k^\*$.

---

## A budget, a support, and a question

Start with the most familiar algorithm in computing: halving search. You are looking for
something inside a range of $W$ possibilities. Each query you make cuts the range in half.
After $k$ queries the surviving range — the *support* — has width $W/2^k$. Everyone knows
this. Everyone has drawn the picture.

The interesting question is not *how* to search. It is **when to stop**.

Queries are not free. Each one costs something: a round trip to a rate-limited oracle, a
block of proof-of-work, a measurement, a page fault, a bribe. At some point it becomes
cheaper to stop querying and simply sweep whatever range is left by brute force. The
budget $k$ that balances these two costs is the number people call $k^\*$.

And here is the trouble. In practice, three genuinely different numbers get written
$k^\*$, in three different accounting conventions, by people who all believe they are
talking about the same thing. They are not. Let us name them.

---

## The three budgets

**The pin.** Define
$$k_{\mathrm{pin}}(W) = \lceil \log_2 W \rceil.$$
This is the budget at which halving has run out of road: the support has collapsed to a
single point, and the marginal gain of one more query is *exactly zero*. It is the natural
answer to "how many queries does it take to finish?", and it is completely correct as an
answer to that question. The pin is a **saturation point**. It is not, and never was, an
optimum. Keep that word in mind — we will prove it in a moment.

**The census stop.** Now do honest accounting. You pay one unit per query, and when you
stop with a support of width $W/2^k$ remaining, you pay for the expected brute-force sweep
of it — half the remaining support, plus the endpoint you are standing on. Total cost:
$$V(W,k) \;=\; k \;+\; \frac{1}{2}\!\left(\frac{W}{2^k} + 1\right).$$
The census stop $k_{\mathrm{opt}}^{\mathrm{cost}}(W)$ is the budget minimising $V$.

**The economics optimum.** Finally, do the accounting the way an experimentalist does.
You have *measured* a baseline: without any search at all, the task takes $T_0$ steps.
Each query costs $c_q$ units, and you charge $k+1$ of them (the $+1$ is the query that
establishes the baseline). Total cost:
$$E(T_0, c_q, k) \;=\; c_q\,(1+k) \;+\; \frac{T_0 - 1}{2^k}.$$
The economics optimum $k_{\mathrm{opt}}^{\mathrm{econ}}(T_0, c_q)$ minimises $E$.

Three formulas. Three symbols in the literature, all of them $k^\*$. The obvious
questions: when do any two of them agree, and by how much do they differ when they don't?

The answers turn out to be startlingly clean — not "approximately", not "asymptotically",
but *exactly*, with constants you can write down.

---

## First surprise: two of the three are the same function

Look at $E$ with unit query price, $c_q = 1$:
$$E(T_0, 1, k) = 1 + k + \frac{T_0-1}{2^k}.$$
Now look at $V$ evaluated at the width $W = 2(T_0-1)$:
$$V\big(2(T_0-1),\,k\big) = k + \frac{1}{2}\!\left(\frac{2(T_0-1)}{2^k}+1\right) = k + \frac{T_0-1}{2^k} + \frac{1}{2}.$$
Subtract. The $k$ cancels. The $2^{-k}$ term cancels. What is left is a number:
$$\boxed{\;E(T_0,1,k) \;=\; V\big(2(T_0-1),\,k\big) \;+\; \tfrac{1}{2}\;}\qquad\text{for every }k.$$

That is not an approximation and not an asymptotic statement. It is a pointwise identity,
valid for every single budget $k$, and the discrepancy is the constant $\tfrac12$ — which
does not depend on $k$ at all.

Why does that matter so much? Because **adding a constant to a function does not move its
minimisers.** The two objectives are, for optimisation purposes, *the same objective*. Not
similar, not close — the same. Once you apply the anchor conversion
$$W \;\longleftrightarrow\; 2\,(T_0 - 1),$$
the census stop and the economics optimum have **identical minimiser sets**, exactly, at
every anchor.

So the two "serious" definitions of $k^\*$ were never in conflict. They differ only by a
factor of two in bookkeeping: the census convention prices the residual at *half* the
remaining support, while the economics convention charges the *full* expected scan
anchored at a measured baseline. Convert the anchor, and they agree on the nose.

---

## Second surprise: the "about one" was exactly one

Here is what actually happens in practice. Someone has a measured baseline $T_0$. They
have both formulas in front of them. They feed the same number, $T_0 - 1$, into both —
because it is the same quantity, isn't it? — and observe that the answers differ by
roughly one query. A note gets written in the margin: *"the two conventions differ by
about $+1$."*

That note can be sharpened to an equality. Feed $T_0-1$ into the census formula and
compare to the economics cost one step higher:
$$E(T_0, 1, k+1) \;=\; V(T_0-1,\,k) \;+\; \tfrac{3}{2}.$$
Again a constant. Again independent of $k$. Consequently, if $j$ minimises the census cost
at width $T_0 - 1$, then $j+1$ minimises the economics cost — **exactly one query higher,
at every anchor, forever.**

The "$\approx +1$" was never an approximation error that might shrink with better data or
larger $T_0$. It is a structural offset, a fixed constant $\tfrac32$ sitting between two
objectives, converted into an integer shift of the minimiser. There is nothing to
estimate. There is only a conversion to remember.

---

## Third surprise: the pin is *never* right

Now the punchline, and the reason this taxonomy is worth writing down.

Take the increment of the census cost — how much one extra query changes the bill:
$$V(W, k+1) - V(W, k) \;=\; 1 \;-\; \frac{W}{2^{k+2}}.$$
Beautiful in its simplicity. The extra query costs $1$; it saves you $W/2^{k+2}$ worth of
residual sweep. So the extra query is worth making exactly while $W/2^{k+2} > 1$. Since
this increment is *increasing* in $k$ — each query saves less than the last, the classic
diminishing return — the objective is discretely convex, and the first $k$ at which the
increment turns nonnegative is the global optimum. Local minimality implies global
minimality; there is no need to search.

That gives the whole answer in one line: **$k$ is a census optimum if and only if**
$$2^{k+1} \;\le\; W \;\le\; 2^{k+2}$$
(with the lower inequality vacuous at $k=0$). In words: the optimal budget lives at offset
$-2$ or $-1$ relative to $\log_2 W$. Never at offset $0$.

But offset $0$ is precisely where the pin lives. The pin is $\lceil \log_2 W\rceil$, and
by definition of the ceiling, $W \le 2^{\lceil \log_2 W\rceil}$. Plug that into the
increment formula at $k = k_{\mathrm{pin}} - 1$:
$$V(W, k_{\mathrm{pin}}) - V(W, k_{\mathrm{pin}}-1) = 1 - \frac{W}{2^{k_{\mathrm{pin}}+1}} \;\ge\; 1 - \frac{2^{k_{\mathrm{pin}}}}{2^{k_{\mathrm{pin}}+1}} = \frac{1}{2} \;>\; 0.$$
The last, saturating query costs a full unit and can only ever save you at most half a
unit. **It is strictly a loss, at every integer width $W \ge 2$, without exception.**

So: the pin is never optimal. Not "rarely", not "for large $W$" — never. And the size of
the error is pinned down too. For every integer width $W \ge 2$ and every census optimum
$k$,
$$k_{\mathrm{pin}}(W) - k \;\in\; \{1, 2\}.$$

Which of the two? The intuitive guess — reading off the dyadic table, where $W = 2^m$ has
optimal budgets $\{m-2, m-1\}$ and pin $m$ — is that a gap of $1$ is the normal case and a
gap of $2$ is a dyadic quirk. **The truth is exactly backwards.** The gap equals $1$ *if
and only if* $W$ sits precisely on the power of two just above the optimum,
$W = 2^{k+1}$; at every other width the gap is $2$. Take $W = 3$: the unique optimal budget
is $k = 0$ — do not query at all, just sweep three items — while the pin is
$\lceil \log_2 3\rceil = 2$. Gap of two, at a thoroughly non-dyadic width.

So at almost every width, someone who computes $\lceil\log_2 W\rceil$ and calls it "the
optimal number of queries" is over-budgeting by **two full queries**. In a setting where a
query is a proof-of-work grind or a rate-limited oracle call, two queries is not a rounding
error; it is a factor of four in the effective search cost.

How bad is the overcharge in cost terms? Sharply bounded on both sides. For every integer
width $W \ge 2$,
$$\tfrac12 \;\le\; V(W, k_{\mathrm{pin}}) - V(W, k_{\mathrm{opt}}) \;<\; \tfrac54.$$
The floor $\tfrac12$ is attained exactly at the dyadic widths $W = 2^{k+1}$; the ceiling
$\tfrac54$ is approached but never reached as $W$ creeps just past a power of two.

---

## A perfect rational answer at the powers of two

One more thing falls out, and it is the kind of exactness that makes a result feel true.

At a dyadic width $W = 2^m$, the minimum of the census cost is not some messy real number.
It is
$$\min_k V(2^m, k) \;=\; m + \tfrac{1}{2}, \qquad\text{exactly},$$
attained on precisely the two-element tie set $\{m-2,\; m-1\}$ — and nowhere else. That is
$\log_2 W + \tfrac12$: an exact rational, at every power of two, forever.

Why exactly two minimisers? Because on the tie set both bracketing inequalities
$2^{k+1} \le W \le 2^{k+2}$ become equalities at the two adjacent budgets. The proof that
*nothing else* ties reduces to a small, satisfying fact: $2^j = j+1$ has exactly two
solutions in the natural numbers, $j = 0$ and $j = 1$, because $2^j$ overtakes $j+1$ for
good at $j = 2$. Two solutions, two minimisers.

And the tie phenomenon is exactly dyadic. Two consecutive budgets are both optimal **if
and only if** $W = 2^{k+2}$. Off the powers of two, the optimum is a unique integer, so
"the" census optimum is a well-defined number everywhere except on the dyadic locus — where
it is genuinely a set, and honesty demands you say so.

Meanwhile the *continuous* optimum — minimise over real $k$ rather than integer $k$ — sits
at $\log_2(W\ln 2) - 1 = \log_2 W - 1.5288\ldots$, comfortably inside the bracket
$[\log_2 W - 2, \log_2 W - 1]$, exactly where it should be. That the continuous location
is a genuine global minimiser, and not merely a stationary point, follows from the single
exponential inequality $1 - u \le e^{-u}$ applied at the displacement from the optimum.

---

## Does the price change anything?

You might expect that making queries more expensive breaks the correspondence — that a
costly-query regime needs its own theory. It does not. For any query price $c_q > 0$,
$$E(T_0, c_q, k) \;=\; c_q\left(V\!\left(\frac{2(T_0-1)}{c_q},\,k\right) + \tfrac{1}{2}\right).$$
The economics cost at price $c_q$ is a *positive multiple* of a census cost at a rescaled
anchor, plus a constant. Positive scaling and additive shifts both leave minimisers
untouched. So the economics optimum at price $c_q$ is exactly the census optimum at anchor
$2(T_0-1)/c_q$.

The two-parameter family $(T_0, c_q)$ collapses entirely onto the one-parameter census
family. Price is not a new degree of freedom — it is a change of anchor, and nothing more.
Doubling the price of a query is *identical*, as an optimisation problem, to halving the
support you are searching. Which, once you see it, is exactly what it should be.

---

## Grounding it in real numbers

Two measured runs make this concrete.

A *balanced* workload with measured baseline $\bar T_0 = 1072.425$. The continuous
optimum is $\log_2(1071.425 \times \ln 2) = 9.536549$, and the discrete optimum is the
integer $10$. The matched-anchor census, at width $2(\bar T_0 - 1) = 2142.85$, returns the
same unique optimum $10$ — as the identity guarantees it must. And the pin? At that width
it is $12$. Two queries of pure overshoot.

An *unbalanced* workload with $\bar T_0 = 286205.89$. Continuous optimum $17.597922$,
discrete optimum $18$, matched-anchor census optimum $18$, pin $20$. Again exactly two
queries of overshoot, and again the discrete optimum is the ceiling of the continuous one.

What deserves emphasis is that the discrete claims here are not spot checks over a finite
range of budgets. Because both objectives are discretely convex, verifying that $10$ beats
$9$ and $11$ *proves* that $10$ beats every natural number. Convexity turns a two-point
check into a universally quantified theorem.

---

## The moral: ban the bare symbol

None of the mathematics above is difficult. Every identity in this article is two lines of
algebra; every optimality claim is one increment formula plus a convexity argument. That
is precisely the point. The difficulty was never in the mathematics. It was in the
*notation*.

Three distinct quantities wearing the same symbol $k^\*$ is an accident waiting to compound,
and the compounding is silent, because all three numbers are within two of each other and
all three look plausible in a table. The remedy is boring and effective: retire the bare
symbol. Write

- $k_{\mathrm{pin}}(W)$ when you mean saturation — and never call it an optimum, because it
  provably isn't one;
- $k_{\mathrm{opt}}^{\mathrm{cost}}(W)$ when you mean the census stop — and state the width $W$;
- $k_{\mathrm{opt}}^{\mathrm{econ}}(T_0, c_q)$ when you mean the economics optimum — and state
  both the anchor $T_0$ and the price $c_q$.

With the names in place, everything that used to be a source of confusion becomes a
one-line conversion. The two optima coincide under $W \leftrightarrow 2(T_0-1)$. The naive
same-number comparison is off by exactly $+1$. The pin is high by $1$ or $2$, and by $2$
unless the width is exactly a power of two, and it costs between half a query and
$\tfrac54$ of a query to make that mistake.

There is a broader lesson here about how quantitative fields accumulate error. The
dangerous mistakes are not the ones that produce nonsense — those get caught the same
afternoon. The dangerous ones produce numbers that are *nearly right*: right order of
magnitude, right shape, wrong by a small integer. They survive review, propagate through
citation, and calcify into folklore.

The cure is not more cleverness. It is the discipline of naming your quantities precisely
enough that two different things cannot share a symbol. Do that, and the mathematics —
which was always simple — is finally allowed to be simple.
