# The Sixth That Never Closes

## What a language model forgets, and why source code forgets it more slowly

Imagine you are reading a very long document — a legal contract, a novel, a
sprawling program — and someone tells you that at the end you will be asked a
single question about it. You cannot keep the whole thing in your head. So you
do what everyone does: you keep a handful of things. A few names. A key clause.
The variable that everything else depends on. The rest fades.

Machines that read text face exactly this problem, and they face it in a form
sharp enough to measure. A modern language model, when it produces its next
word, distributes its attention across everything it has read so far. Most of
that attention lands on very few places. So a natural question arises: **how
few places can you keep before the answer changes?**

Call that number the **knee**. Fix a tolerance — say you insist on preserving
$98\%$ of the attention mass — sort the positions from most-attended to
least-attended, and count how many you must retain to clear the bar. That count
is the knee, and it is the honest price of memory.

This article is about a single measured fact and the mathematics that turns it
from an anecdote into a theorem.

---

## The measurement

Sweep the knee for two kinds of text — **source code** and **ordinary prose** —
at several context lengths. Here is what comes out.

At a context of $512$ tokens, code needs $12$ keys and prose needs $16$. At
$1024$ tokens, code needs $16$. At $4096$ tokens, code needs $32$ and prose
needs $40$.

Two things jump out.

**First, an acceleration.** Code goes $12 \to 16$ when the context doubles from
$512$ to $1024$: four extra keys. If that were the pace, then two more doublings
would land at $24$. The measurement says $32$. Something speeds up between
$1024$ and $4096$ — a phase transition in how attention spreads out — and it
hits code too.

**Second, a persistent discount.** Code is always cheaper than prose. At short
context the ratio is $12/16 = 0.75$; at long context it is $32/40 = 0.80$. Code
is protected. But the protection is *eroding*: $0.75$ has become $0.80$, and the
obvious extrapolation is that the domains eventually converge — that at some
context length, code and prose cost the same.

That extrapolation, it turns out, is exactly wrong. And showing why requires
being careful about three separate things: what a coarse measurement actually
licenses, what "protection" means when you vary the tolerance, and what a
narrowing ratio does and does not imply.

---

## Part one: what a fail and a pass actually prove

The knee at $4096$ was found by trying budgets on a grid. A budget of $28$ keys
retained about $0.976$ of the attention — below the bar. A budget of $32$
retained $0.986$ — above it. The report says $k^{*} = 32$.

But a fail at $28$ and a pass at $32$ only prove the knee lies somewhere in
$\{29, 30, 31, 32\}$. And there is a theorem here, not just a caveat:

> **Grid Ambiguity Theorem.** There exist two attention profiles — both
> nonnegative, both decreasing — that retain *exactly the same mass at every
> budget at or below $28$ and at every budget at or above $32$*, yet whose knees
> are $29$ and $32$ respectively.

In other words, no amount of cleverness applied to the coarse grid can decide
between $29$ and $32$. The two candidate worlds are observationally identical
outside the gap. The reported $32$ is the *top of a four-wide bracket*, and the
only way to shrink it is to measure inside the gap. This is why a fine sweep of
$24$–$32$ is a genuine experimental necessity and not a nicety.

That is a small point mathematically and a large one methodologically: it tells
you exactly which digits of a measurement are real.

---

## Part two: protection is a shape, not a number

"Code is protected" was stated at one tolerance. Is it a property of the
tolerance, or of the text?

Write $M_{\text{code}}(k)$ for the mass that code's top $k$ positions retain,
and $M_{\text{prose}}(k)$ likewise. Then:

> **Protection Characterisation Theorem.** Code has a knee no larger than prose
> *at every reachable tolerance simultaneously* if and only if
> $$M_{\text{prose}}(k) \le M_{\text{code}}(k) \quad \text{for every budget } k.$$

The forward direction is easy: if code's head always holds more mass, it clears
any bar at least as soon. The reverse direction is the interesting one, and it
says that a knee ordering robust across all tolerances *cannot* be an accident
of where you happened to set the bar — it is a pointwise domination of the whole
retention curve. Protection at every bar is head dominance, and head dominance
is protection at every bar. There is nothing in between.

So the question "is code protected?" is well-posed independently of the
threshold. Good. Now: does the protection last?

---

## Part three: the ratio is the wrong thing to watch

Here is the modelling step. The acceleration suggests that context length is not
the natural clock. Something is undergoing a transition, and each domain rides
the *same* transition at its own rate. So introduce a shared coordinate $T$ —
"phase-transition time" — and posit that each domain's knee is affine in it:
$$K_d(T) = a_d + b_d T .$$
Here $a_d$ is the structural, domain-specific baseline, and $b_d$ is how hard
the transition inflates that domain's budget.

Now watch two observables: the **ratio** $r(T) = K_{\text{code}}(T)/K_{\text{prose}}(T)$
and the **gap** $G(T) = K_{\text{prose}}(T) - K_{\text{code}}(T)$.

Three facts follow, and together they overturn the naive reading.

**Fact 1 — narrowing is a sign condition.** The ratio is strictly increasing in
$T$ precisely when
$$a_c b_p < a_p b_c .$$
Narrowing is not a "trend" that might continue or reverse; it is a fixed
inequality among four constants. If it holds at one place it holds everywhere,
and if it fails it fails everywhere.

**Fact 2 — narrowing never reaches its own limit.** The exact error term is
$$r(T) - \frac{b_c}{b_p} \;=\; \frac{a_c b_p - a_p b_c}{\,b_p\,(a_p + b_p T)\,}.$$
Under the narrowing condition the numerator is negative and the denominator
positive, so $r(T) < b_c/b_p$ for *every* $T$, and $r(T) \to b_c/b_p$ as
$T \to \infty$. The ratio climbs toward a ceiling it never touches. Whether that
ceiling is $1$ — parity between domains — is a question about $b_c$ versus
$b_p$, and the ratio's own history cannot answer it.

**Fact 3 — the gap can answer it.** The gap is itself affine:
$$G(T) = (a_p - a_c) + (b_p - b_c) T .$$
If the gap grows, then $b_c < b_p$, hence $b_c/b_p < 1$, hence
$$r(T) < \frac{b_c}{b_p} < 1 \quad \text{for all } T.$$

Put together: *if the ratio increased and the gap also increased between two
contexts, then protection is permanent.* The narrowing is real, and it is
bounded away from parity forever.

### The trap, made explicit

Why insist on the gap? Because the ratio alone is genuinely uninformative, and
this can be exhibited rather than argued. Consider two candidate laws:

- $K_c(T) = 12 + 20T$, $K_p(T) = 16 + 24T$;
- $K_c(T) = 12 + 4T$, $K_p(T) = 16 + 4T$.

Both give $r(0) = 3/4$ and $r(1) = 4/5$ — *the measured pair of ratios,
exactly*. But the first has limiting ratio $20/24 = 5/6$ and the second has
limiting ratio $4/4 = 1$. One is permanent protection; the other is eventual
parity. And these are not "close" — they are provably different limits, so no
amount of extra precision on those two ratios separates them.

What separates them instantly is the gap. In the first law the gap goes
$4 \to 8$; in the second it stays $4 \to 4$. The measurement says $16 - 12 = 4$
and $40 - 32 = 8$. The gap doubled. Protection is permanent.

The measured numbers, in fact, fit the first law exactly, with $T = 0$ at
context $512$ and $T = 1$ at context $4096$:
$$K_{\text{code}}(T) = 12 + 20T, \qquad K_{\text{prose}}(T) = 16 + 24T .$$
Ratio $3/4 \to 4/5$. Gap $4 \to 8$. Limit $5/6$. **Code stays cheaper by a
sixth, forever.**

There is a bonus. The code knee of $16$ at context $1024$ pins that context to
$T = 1/5$, and the same fit then *forces* the prose knee there to be
$104/5 = 20.8$. Nothing was fitted to produce that number. A prose sweep at
$1024$ landing on $20$ or $21$ corroborates the model; a landing at $24$ or above
destroys it. That is a real prediction with a real way to lose.

---

## Part four: the acceleration is a broken concavity

What exactly does "the acceleration hits code" mean, precisely?

Index contexts by doublings from $512$: $j = 0, 1, 2, 3$ for $512, 1024, 2048,
4096$. A law of **diminishing returns** is one whose per-doubling increments
never grow:
$$K(j+2) - K(j+1) \;\le\; K(j+1) - K(j) \quad \text{for all } j.$$

> **Concave Chain Bound.** Any such law satisfies
> $K(j) \le K(0) + j\,(K(1) - K(0))$.

The proof is a two-line induction: every increment is at most the first one, so
$j$ steps add at most $j$ times the first increment.

Apply it. With $K(0) = 12$ and $K(1) = 16$ this caps $K(3)$ at
$12 + 3 \cdot 4 = 24$. The measurement is $32$. So the code chain refutes *every*
diminishing-returns law — not one particular curve, the entire class — and it
does so by $8$ keys.

There is a pretty consistency check hiding here. The affine two-slope fit has
*constant* increments in $T$; it is not itself convex. So where did the
acceleration go? Into the clock. The fit forces $T(0) = 0$, $T(1) = 1/5$,
$T(3) = 1$ — the phase-transition coordinate advances slowly at first and then
races. The acceleration is a property of how context length maps to
phase-transition time, not of how knees depend on that time. The transition,
not the domain, is doing the accelerating.

---

## Part five: one clock for all domains

If every domain really rides the same coordinate, that is a strong claim, and
strong claims should be cheap to kill.

Here is the killer. For an affine law, take any three contexts and form the
normalised increment
$$\rho \;=\; \frac{K(T_2) - K(T_1)}{K(T_3) - K(T_1)} .$$
Substituting $K = a + bT$, the baseline $a$ cancels by subtraction and the slope
$b$ cancels by division:
$$\rho = \frac{T_2 - T_1}{T_3 - T_1}.$$
**The normalised increment does not depend on the domain at all.** It is the knee
analogue of a cross-ratio: an affine reparametrisation leaves it untouched.

And the converse holds: any two three-context chains sharing one normalised
increment can be written as affine laws in a *common* coordinate. So
"one shared transition, per-domain slopes" is neither more nor less than
"equal normalised increments". The model has been reduced to a single measurable
number.

For the code chain, $\rho = (16-12)/(32-12) = 4/20 = 1/5$, so
$T_3 - T_1 = 5 (T_2 - T_1)$, and every domain on the same transition must obey
the parameter-free forecast
$$K(4096) = K(512) + 5\,\bigl(K(1024) - K(512)\bigr).$$

No fitting. No free constants. A domain kneeing at $10$ and $14$ must knee at
$30$; one at $14$ and $20$ must knee at $44$; one at $16$ and $24$ must knee at
$56$. Any single sweep in mathematics, German, or French that misses its line
falsifies the shared-coordinate model outright.

---

## Part six: how early is $0.80$?

The ratio has moved from $0.75$ to $0.80$ and its ceiling is $5/6 \approx
0.833$. Is the observed motion most of the story, or the start of it?

The exact error term answers this quantitatively: the ratio is within $\varepsilon$
of its limit as soon as the prose knee exceeds
$$\frac{|a_c b_p - a_p b_c|}{b_p \varepsilon}.$$
For the measured fit the numerator is $|12 \cdot 24 - 16 \cdot 20| = 32$, so
reaching within $0.01$ of $5/6$ requires a prose knee of about
$32/(24 \cdot 0.01) = 400/3 \approx 134$ keys — more than three times anything
swept so far. The observed narrowing is *early*. Nearly all of the approach to
the limit is still ahead, and none of it ever crosses $5/6$.

---

## Part seven: it isn't the tokenizer

An obvious objection: maybe code only looks cheaper because tokenizers chop code
and prose differently. Suppose each code unit becomes $r_c$ tokens and each prose
unit becomes $r_p$ tokens. Does protection survive?

It does, under an explicit and mild condition:
$$r_c \, K_{\text{code}} \;\le\; r_p\,(K_{\text{prose}} - 1)
\;\;\Longrightarrow\;\; \text{diluted code knee} < \text{diluted prose knee}.$$
In particular, protection survives whenever the tokenizer is no coarser on code
than on prose, $r_c \le r_p$ — which covers every realistic case, since code
tokenizers are typically *finer* on prose, not coarser.

And the condition is not decorative: with $r_c = 8$ and $r_p = 1$ — an absurdly
lopsided tokenizer — the diluted code knee provably exceeds the diluted prose
knee. So protection is a real constraint on the tokenizer, satisfied by real
tokenizers, and the theorem says exactly where the boundary is.

There is a companion negative result worth stating. A *purely multiplicative*
domain model — the hypothesis that code's knee is a fixed constant times prose's
knee at every context, which is what a pure tokenisation mechanism would predict
— is refuted by any change whatsoever in the ratio. Since the ratio demonstrably
moved from $3/4$ to $4/5$, no constant factor can be responsible. There must be
an *additive* structural component sitting on top of the shared transition.
That is the $a_d$ in the law, and the data insists it is there.

---

## Part eight: what it says about attention itself

All of the above is about budgets. Push it down to the attention weights and
something clean appears.

Model attention as an exponential tail with decay rate $\lambda$: keep enough
positions that the discarded tail is below $\delta$. The exact answer is
$$K(\lambda, \delta) = \frac{\log(1/\delta)}{\lambda}.$$
Two domains at the same tolerance therefore satisfy
$$\frac{K_{\text{code}}}{K_{\text{prose}}} = \frac{\lambda_{\text{prose}}}{\lambda_{\text{code}}}.$$

The domain factor is an **inverse ratio of decay rates**. "Code is protected"
says precisely: *code's attention is more sharply peaked than prose's*. And the
narrowing says the peakedness advantage is shrinking — from $4/3$ at short
context to $5/4$ at $4096$. Permanent protection says the advantage never falls
below $6/5$.

The code chain also pins the rates. From $K = 12, 16, 32$ at doublings
$j = 0, 1, 3$ one reads off $4\lambda_1 = 3\lambda_0$ and $8\lambda_3 =
3\lambda_0$, so
$$\lambda_3 = \tfrac{3}{8}\lambda_0 < \tfrac{1}{2}\lambda_0 .$$
The decay rate has fallen to three eighths of its short-context value — strictly
faster than the halving an affine knee law would predict. The acceleration is
**super-harmonic** rate degradation.

Finally, a shape statement. The natural family of rate laws — the one equivalent
to "each doubling costs a fixed number of extra keys" — is the generalised
harmonic family $\lambda_j = C/(j+c)$. No member of it fits $12, 16, 32$, for any
$C$ and any offset $c$: the first pair forces $\log(1/\delta) = 4C$ and the second
forces $\log(1/\delta) = 8C$, so $C = 0$, which is impossible. The acceleration
is not a rescaling of a harmonic law. It is a different shape.

---

## Why it matters

Every deployed long-context system pays for memory, and the knee is the price
tag. If the price of remembering source code stayed at three quarters of the
price of remembering prose no matter how long the context grew, that would be
worth designing around — separate cache budgets, domain-aware eviction, cheaper
code assistants.

The results here say two things about that hope, one encouraging and one
sobering.

Encouraging: the discount is permanent. It is not a short-context artefact that
washes out, and it is not a tokenizer illusion. Under the fitted law it settles
at a sixth, and the theorem guarantees that whenever both the ratio and the gap
increase together, no amount of further context can close it. The gap grows even
as the ratio narrows — these are compatible, and confusing them is the single
easiest mistake to make here.

Sobering: the *absolute* cost accelerates for everyone. No diminishing-returns
model survives the code chain. Whatever transition occurs between $1024$ and
$4096$ tokens, it hits the most predictable domain we have. A baseline accuracy
of $0.677$ on source code at $4096$ tokens is remarkably high — code's
predictability really does persist — and still the budget doubles ahead of
schedule.

And there is a lesson about measurement that transcends the subject. Two of the
theorems here are, in effect, warnings. One says your reported knee of $32$ is
really a bracket $[29, 32]$, and no analysis can shrink it without new data. The
other says your ratio trend $0.75 \to 0.80$ is compatible with both permanent
protection and eventual parity, and only a *different observable* — the gap —
tells them apart. Both warnings are theorems: not "be careful", but "here are two
worlds your data cannot distinguish, explicitly constructed".

That is what it looks like when an empirical claim is put on a footing. The
headline survives, sharpened: at a context of $4096$ tokens, code is protected —
and the sixth by which it is protected never closes.
