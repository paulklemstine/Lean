# The Four Keys That Code Doesn't Need

## How a tiny, stubborn integer turned a memory-budget puzzle into a piece of geometry

There is a moment, familiar to anyone who has tried to run a large language model on
hardware they actually own, when the arithmetic stops being abstract. Every token the model
has processed leaves behind a *key* and a *value* — a pair of vectors it consults when
deciding what to say next. Those pairs pile up, and the pile grows linearly with the
conversation. Double the context window and you double the memory bill.

So people truncate. Instead of attending to all $N$ keys in its history, the model keeps
only the $k$ heaviest — the ones carrying the most attention mass — and throws the rest
away. The question that decides whether your deployment fits in memory is simply: **how
small can $k$ be before the model gets noticeably worse?**

This article is about the answer, and about a surprise hidden inside it. The surprise is
not that the answer exists. It is that the answer has a *shape*: it is not a number, but a
point on a line with no origin.

---

## The knee

Start with the measurement. Fix a corpus, fix a context length, and sweep the budget $k$
across a grid — in the experiments described here, the grid was the multiples of four:
$4, 8, 12, 16, 20, 24$. For each budget, record the **retained accuracy**: the model's
next-token accuracy with only $k$ keys, divided by its accuracy with all of them. That
ratio starts low and climbs toward $1$ as you give the model more memory.

Then draw a horizontal line at $0.98$ — the acceptance bar — and ask where the accuracy
curve first crosses it. That crossing is the **knee**, $k^*$. If $\mathrm{acc}(j)$ is the
retained accuracy at grid index $j$ (budget $4j$ keys) and $\tau$ is the bar, the knee index
is

$$k^*_{\text{idx}} = \inf\{\, j : \tau \le \mathrm{acc}(j) \,\},$$

and the knee budget is $4 k^*_{\text{idx}}$.

That infimum looks bland. It is the source of everything that follows, because for a curve
that never gets worse when given more memory — a *monotone* sweep — it satisfies a clean
equivalence:

$$k^*_{\text{idx}} \le j \quad\Longleftrightarrow\quad \tau \le \mathrm{acc}(j).$$

Read left to right: if the knee is at or below $j$, then budget $j$ clears the bar. Read
right to left: if budget $j$ clears the bar, the knee is at or below $j$. This is a
*Galois connection* — the knee is the adjoint of the accuracy curve — and it is why knee
arithmetic behaves. Give a domain a uniformly better retention curve and its knee can only
move left. Raise the bar and it can only move right. Nothing needs arguing twice.

The second consequence matters for anyone who has ever been suspicious of a curve fit.
Suppose budget $j$ *fails* the bar and budget $j+1$ *clears* it. Then the knee is exactly
$j+1$ — no matter what the curve does anywhere else. **A knee claim rests on exactly two
measured points.** Every other point in the sweep is corroboration, not evidence; two
sweeps agreeing at their bracketing pair have the same knee even if they disagree
everywhere else.

A knee, in other words, is not a fit. It is a reading.

---

## The measurement, and the shift

Here is what was read. The reference domain was English prose; the new one was Python
source — ten files from the CPython standard library, run through a byte-identical harness:
same bar, same grid, same window count, held-out splits per corpus, fully deterministic.

At context length $512$, the code sweep went

$$4 \mapsto 0.930,\quad 8 \mapsto 0.969,\quad \mathbf{12 \mapsto 0.981},\quad 16 \mapsto 0.987,\quad 20 \mapsto 0.988,\quad 24 \mapsto 0.989,$$

so the bracketing pair is $(0.969, 0.981)$ and $k^* = 12$. At context $1024$,

$$8 \mapsto 0.960,\quad 12 \mapsto 0.976,\quad \mathbf{16 \mapsto 0.981},\quad 20 \mapsto 0.986,\quad 24 \mapsto 0.987,$$

bracketing pair $(0.976, 0.981)$, knee $k^* = 16$.

Prose, measured identically, needs $16$ keys at $512$ and $20$ at $1024$.

| context | code $k^*$ | prose $k^*$ | shift |
|---|---|---|---|
| $512$ | $12$ | $16$ | $-4$ |
| $1024$ | $16$ | $20$ | $-4$ |

Code needs four fewer keys. At both contexts. Exactly one step of the grid, twice.

Three predictions had been registered in advance. **P1**: the knees transfer across the
domain jump to within one grid step — confirmed. **P2**: the gap is exactly one grid step
at *both* contexts — confirmed. **P3**: the domain the model finds easier to predict will
need at least as many keys, not fewer — **refuted**, decisively, because code is the
*easier* corpus (full accuracy $0.6296$ at context $512$ and $0.6520$ at $1024$, above
prose in both cells) and yet it is the corpus needing less memory.

Easier to predict. Cheaper to remember. Those are supposed to be the same fact. They are
not.

---

## The law, and why the repetition matters

The natural way to organise four numbers is a law. Let $d$ count context doublings, so
$d = 0$ is context $512$ and $d = 1$ is $1024$. Then posit

$$k^*(\text{domain}, d) \;=\; \mathrm{base}(\text{domain}) \;+\; \mathrm{inc} \cdot d.$$

Two parameters: a **base** depending on the domain, an **increment** depending on the
scale. Fit it: code gets base $12$, prose base $16$, both increment $4$.

That fit is not a choice. An affine function is pinned by any two distinct evaluations, so
the two measured contexts determine each domain's law uniquely. Symmetrically — and this is
why the experiment *had* to be run twice — a single context never can: the law with base
reduced by $d$ and increment raised by $1$ agrees with any given law at context $d$ and
nowhere else.

But the deeper point is what the *repetition* of the $-4$ buys:

> **For two budget laws $A$ and $B$, the difference $A(d) - B(d)$ is independent of $d$
> if and only if $A$ and $B$ have the same increment.**

The forward direction is the interesting one. A constant gap forces equal increments; and
had the increments differed, the gap would not merely have drifted — it would eventually
have *changed sign*, at a context you can compute. So P2 was genuinely falsifiable: had
code's increment been $5$ rather than $4$, the shift at $1024$ would have read $-3$.

It read $-4$. That is the evidence that the two-parameter factorisation is real: **the
domain enters only through the base, the scale only through the increment.** Nature was
under no obligation to be that tidy.

---

## A line with no origin

Now the part that reframes the whole thing.

Fix the increment at $4$. Every remaining law is determined by a single integer, its base.
Define an action: given $t \in \mathbb{Z}$, translate a law by replacing its base $b$ with
$b + t$. Every predicted budget then rises by exactly $t$, at every context.

This action has two properties that together have a name. It is **transitive**: any two
laws with the same increment are connected by some translation. And it is **free**: that
translation is *unique*. A set carrying a free transitive action of the integers is a
**$\mathbb{Z}$-torsor** — a copy of the integer line that has forgotten where zero is.

So the domains at a fixed scale form a torsor, and the observable is the translation
connecting two of them,

$$\mathrm{shift}(A, B) = \mathrm{base}(B) - \mathrm{base}(A),$$

which behaves as it should: zero from a domain to itself, antisymmetric, and — the cocycle
law — **additive along chains**,

$$\mathrm{shift}(A,B) + \mathrm{shift}(B,C) = \mathrm{shift}(A,C).$$

Domain gaps compose; a ladder of domains is generated by its consecutive rungs.

And here is the punchline. Translate *every* domain by the same $t$ and every shift is
unchanged. Given any target value you like, some translation puts a chosen domain's base
exactly there while fixing all shifts. The base of a single domain is **not an
observable**. Only differences are.

The experiment did not measure that code sits at $12$ and prose at $16$. It measured that
code sits four below prose. Those two numbers are a coordinate chart on a line with no
marked origin — useful, conventional, and not a fact about the world. The fact about the
world is the $-4$. It is the move physics makes about potential energy: you may name
coordinates, but the theory only ever cashes out differences.

---

## Sizing a mixed workload — and the fine print

Deployments serve prose and code and everything else, interleaved. So: what budget covers a
mixture?

Inside a single increment class the answer is as clean as possible. The pointwise order on
laws is the order on bases, and the upper envelope of a finite family sharing an increment
is *again a law*, whose base is the largest in the family:

$$\max_i \big(b_i + \mathrm{inc}\cdot d\big) \;=\; \big(\max_i b_i\big) + \mathrm{inc}\cdot d.$$

The deployment rule follows: **size the cache by the largest-base domain present.** For a
prose/code mixture that means size by prose; sizing by code under-provisions by exactly one
grid step at every context. And note it is a genuinely falsifiable prediction, because it
says the mixed budget is the *maximum* of the individual bases, never a weighted average.
Interleave 90% code with 10% prose and you still pay prose's price.

Now the fine print, which is the strongest result here. The envelope rule *depended on the
shared increment*, and that dependence is not decoration. Suppose two domains have
**different** increments and their bases **cross** — the one with the smaller increment
starts higher. Then:

> **No budget law computes the mixed envelope.** There is no base and no increment
> whatsoever for which $\mathrm{base} + \mathrm{inc}\cdot d$ equals
> $\max(A(d), B(d))$ for every $d$.

The proof is two lines. Past the crossover the envelope agrees with the steeper law $B$
forever; a candidate law agreeing with $B$ at two distinct contexts *is* $B$, by affine
rigidity; and then at context $0$ it reads $B$'s base, whereas the envelope reads $A$'s
larger base. Contradiction.

Concretely, base $16$ with increment $2$ against base $12$ with increment $6$ gives the
envelope $16, 18, 24, 30, 36, \dots$ — a genuine kink that no two-parameter law can
straighten. The tidy single-formula sizing rule engineers would like to assume is a
*privilege*, not a default — one that the constancy of the measured $-4$ is precisely what
earns.

---

## Why "easier" tells you nothing

Return to the refuted prediction. It felt plausible: if a model predicts code better than
prose, surely code's attention is doing less work, and less work means fewer keys. The data
said no. The mathematics says something sharper than "no on this data".

Model a domain as a pair: a full-accuracy number, and an attention profile — the
distribution of mass over the sorted keys — which is what actually determines the knee.
Then, for any tolerance strictly between $0$ and $1$:

> **Every pair (full accuracy $a$, knee $k \ge 1$) is realised by an actual domain.**

The two coordinates are independent, and the construction is explicit: a uniform attention
profile spread over exactly $k$ keys does the job, whatever accuracy number you bolt onto
it.

The consequence is total. **No function of full accuracy predicts the knee.** If some $g$
satisfied $\text{knee} = g(\text{accuracy})$, take two domains with accuracy $\tfrac12$ and
knees $1$ and $2$; then $g(\tfrac12)$ is both. Nor does a monotone version survive: one can
exhibit a strictly more accurate domain needing strictly fewer keys (the observed pattern)
*and* one needing strictly more.

So P3 was not merely false. It was **unprovable** — no accuracy data of any kind could ever
have established it. The refutation was structurally guaranteed; the experiment only told
us which way the actual corpora fell. Accuracy level and knee position are separate
quantities, and there was never a theorem connecting them.

---

## What a small base actually certifies

If the base is not about difficulty, what is it about? The answer is **concentration**.

Let the attention profile's cumulative mass over the top $j$ keys be $\mathrm{cum}(j)$, so
the mass of the $j$-th key is $\mathrm{cum}(j+1) - \mathrm{cum}(j)$. If a domain meets
tolerance $\tau$ with only $k$ keys, then:

> **Some single key carries more than $\tau/(k+1)$ of the attention mass.**

The argument is a contrapositive: if *every* key's mass were at most $m$, accumulating
$\tau$ would take at least $\tau/m$ keys, so a knee of $k$ forces $m > \tau/(k+1)$.

Apply it. Code meets the bar at $12$ keys where prose needs $16$, so the code corpus must
contain a key carrying more than $\tau/13$ of the mass — its attention profile *cannot* be
flat at that level, while for prose no such guarantee arises below $\tau/17$. The $-4$ is
not a claim about how hard code is. It is a measurable claim about the **shape** of code
attention: code has heavier heads.

Which is exactly the intuition, once you look at code the right way. Prose refers back
diffusely — a pronoun leans on a whole paragraph. Code refers back *sharply*: this
identifier was bound on line 40, this brace matches that one, this call resolves to that
definition. Sharp reference makes a heavy key, and a heavy key buys a small base.

---

## Being honest about what two points can't decide

Four measured knees, two parameters — a critic is entitled to ask whether an additive fit
of two points is worth anything. It is a fair objection, so the law was pushed against a
*mechanistic* rival.

Suppose attention decays geometrically: the residual mass past $k$ keys is $r^k$, so the
knee is the least $k$ with $r^k \le \rho$, where $\rho = 1 - \tau$. That knee is exactly

$$\text{knee} = \left\lceil \frac{\log \rho}{\log r} \right\rceil.$$

Call $X = \log\rho / \log r$ the **continuous knee** — the real number that the measured
integer is the ceiling of. Now: what does it mean for code to have "the same attention
shape, decaying faster"? It means $r_{\text{code}} = r_{\text{prose}}^{\,a}$ for some
$a > 1$. And raising the decay rate to the power $a$ **divides** the continuous knee by
$a$:

$$\text{knee for } r^a = \left\lceil X / a \right\rceil.$$

So the rival is multiplicative where ours is additive. Does it fit? Perfectly. Take
$a = 251/200 = 1.255$ and prose continuous knees $15.05$ at context $512$ and $20.00$ at
$1024$. Then $\lceil 15.05 \rceil = 16$, $\lceil 15.05/a \rceil = 12$,
$\lceil 20 \rceil = 20$, $\lceil 20/a \rceil = 16$. All four cells, exactly — and honest
geometric profiles with those continuous knees exist.

**Two contexts cannot distinguish an additive base shift from a rescaling of the decay
rate.** That is the honest limit of the round, stated as a theorem rather than hidden in a
caveat.

But the failure is *removable*, and the ceiling function removes it. A knee reading of $n$
brackets the continuous knee: $n - 1 < X \le n$. Feed the context-$512$ cell through it —
$\lceil X \rceil = 16$ gives $X > 15$, and $\lceil X/a \rceil = 12$ gives $X \le 12a$ — and
you get $a > 5/4$.

Now extrapolate. The additive law predicts $28$ keys for prose at context $4096$ and
exactly $24$ for code. The rescaling model, with $X \le 28$ and $a > 5/4$, predicts
$X/a < 22.4$, hence **at most $23$**. The two disagree, at a single cell, by a margin the
grid can see.

Sharper: no exponent reproduces both the $512$ cell and a $24$-reading at $4096$. The first
forces $a > 5/4$, the second $a < 28/23 \approx 1.217$; the window is empty. If the $4096$
measurement reads $24$, the rescaling mechanism is not disfavoured, it is **dead**. If it
reads $23$ or less, the additive law is. Either way something dies — and $4096$ is the
*first* context that decides, since the same witness $a = 1.255$ also reproduces the
additive prediction at $2048$.

---

## The grid is the instrument

A final observation, easy to miss, that is really a lesson about experimental design.

The whole result is a shift of size $4$. Suppose the sweep had used a grid of step $8$ — a
reasonable choice, halving the compute. Round each knee up to the next multiple of $8$:
code's $12$ becomes $16$, prose's $16$ becomes $16$. **Identical readings.** The entire
effect vanishes, silently, with no warning in the data.

An effect of size $s$ is observable only on a grid finer than $s$. Not more windows, not a
bigger corpus, not a tighter bar — *resolution*. No amount of statistical power substitutes
for it.

---

## What it adds up to

Strip away the apparatus and the story is this. A quantity everyone treats as a single
number — "how many keys do I need?" — factors. One parameter belongs to the domain, one to
the scale. The domain parameter is not a number but a point on a line with no origin, so
only gaps are ever measured, and gaps compose additively along chains. Within one scale
class the mixed-workload budget is the maximum of the individual budgets and is itself a
law; step outside and the envelope stops being a law at all.

The domain parameter is not a measure of difficulty — no function of accuracy can predict
it, and code proves the point by being both easier and cheaper. It is a measure of
concentration: a small base certifies a heavy attention head, and code's sharp, pointed
references are what produce one.

And the honest coda: two contexts cannot tell an additive shift from a multiplicative
rescaling, but three can, and the deciding measurement has been named in advance along with
the number that will settle it. Twenty-four keys, at context $4096$. One of two mechanisms
will not survive the reading.

That is what it looks like when a memory-sizing table stops being a table and becomes a
theory.
