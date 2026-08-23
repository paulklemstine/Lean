# Fewer Keys for Code

### A guided tour of the domain-parameterised budget law for attention key retention

---

## 0. The question, in one paragraph

A language model reading a long document holds one key/value pair per token it has seen.
Memory grows linearly with the conversation, so people truncate: at each step the model
attends only to the $k$ heaviest keys and discards the rest. Everything here follows from
one question — **how small can $k$ be before the model gets noticeably worse?** — and from
one surprising discovery about the answer: it is not a number. It is a point on a line with
no origin.

By the end of this page you will have read every theorem in the development, watched each
one work in an interactive widget, and seen exactly which future measurement would kill
half of it.

---

## 1. The knee: where accuracy stops paying for memory

Fix a corpus and a context length, and sweep the retained-key budget $k$ across a grid — in
the experiments below, the multiples of four. At each budget, record the **retained
accuracy**: next-token accuracy under truncation, divided by accuracy with the full cache.
The curve climbs steeply and then flattens.

Draw a horizontal line at $\tau = 0.98$ — "within two percent of full performance" — and
ask where the curve first crosses it. That crossing is the **knee**:

$$k^*_{\text{idx}} \;=\; \inf\{\, j : \tau \le \mathrm{acc}(j) \,\}, \qquad k^* = 4\,k^*_{\text{idx}}.$$

Play with it before reading any further. Drag the readings, drag the bar, and watch which
two points the answer actually depends on.

{{interactive_demo:1}}

<details>
<summary><b>Why the knee behaves so well: it is an adjoint</b></summary>

For a sweep that never gets worse when given more memory, the definition above yields an
exact two-way equivalence:

$$k^*_{\text{idx}} \le j \quad\Longleftrightarrow\quad \tau \le \mathrm{acc}(j).$$

Left to right: if the knee is at or below $j$, then budget $j$ clears the bar (the knee
itself passes, and monotonicity carries this upward). Right to left: if budget $j$ clears
the bar, the knee is at or below $j$ — immediate from the infimum.

This is a [Galois connection](https://en.wikipedia.org/wiki/Galois_connection), and it
does all the work. *Raise the bar, and the knee can only move right.* *Improve the whole
retention curve, and the knee can only move left.* Neither needs a separate argument.

</details>

<details>
<summary><b>The consequence that matters for evidence: two points decide</b></summary>

**Theorem (data determination).** Let the sweep be monotone, and let index $j$ satisfy
$\mathrm{acc}(j) < \tau \le \mathrm{acc}(j+1)$. Then the knee index is exactly $j+1$.

*Proof.* The upper bound is the infimum applied at $j+1$. For the lower bound, if the knee
were at or below $j$, the equivalence above would give $\tau \le \mathrm{acc}(j)$,
contradicting the bracket. $\blacksquare$

So a knee claim commits to exactly two numbers: the last failure and the first success.
Two sweeps agreeing at their bracketing pair have the same knee *even if they disagree
everywhere else*. That is what the "scramble" button in the widget above demonstrates. A
knee is a reading, not a fit.

</details>

The algorithm that turns a sweep into a certified reading — and refuses to certify when
the data does not determine the answer — is this one:

{{algorithm:0}}

---

## 2. The measurement: code needs four fewer keys

Now the experiment. Hold the harness, the bar, the grid, the window count and the split
protocol byte-identical, and swap the corpus: English prose out, Python source in (ten
files of the CPython standard library).

At context $512$ the code sweep reads
$4 \mapsto 0.930$, $8 \mapsto 0.969$, $\mathbf{12 \mapsto 0.981}$, $16 \mapsto 0.987$,
$20 \mapsto 0.988$, $24 \mapsto 0.989$ — bracketing pair $(0.969, 0.981)$, so $k^* = 12$.
At context $1024$: $8 \mapsto 0.960$, $12 \mapsto 0.976$, $\mathbf{16 \mapsto 0.981}$,
$20 \mapsto 0.986$, $24 \mapsto 0.987$ — so $k^* = 16$.

| context | code $k^*$ | prose $k^*$ | shift |
|---|---|---|---|
| $512$ | $12$ | $16$ | $-4$ |
| $1024$ | $16$ | $20$ | $-4$ |

Four fewer keys. At both contexts. Exactly one step of the grid, twice.

And here is the twist that motivates everything below. Code is the corpus the model
predicts **better** — full accuracy $0.6296$ at context $512$ and $0.6520$ at $1024$,
above prose in both cells. The easier corpus is the cheaper one to remember. Those two
facts are supposed to be the same fact. They are not.

{{visualization:1}}

---

## 3. The law: base for the domain, increment for the scale

Let $d$ count context doublings ($d=0$ is context $512$). Posit

$$k^*(\text{domain}, d) \;=\; \mathrm{base}(\text{domain}) \;+\; \mathrm{inc}\cdot d.$$

Fitting gives code $(12, 4)$ and prose $(16, 4)$. But "fitting" is the wrong word: an
affine function is pinned by any two distinct evaluations, so the two measured contexts
determine each law *uniquely* — and symmetrically, one context never can.

The real content is the *repetition* of the $-4$.

<details>
<summary><b>Theorem: a constant shift is equivalent to a shared increment</b></summary>

For budget laws $A$ and $B$, the difference $A(d)-B(d)$ is independent of $d$ **if and
only if** $A$ and $B$ have the same increment.

*Proof.* ($\Leftarrow$) Equal increments cancel, leaving $\mathrm{base}_A -
\mathrm{base}_B$ at every $d$. ($\Rightarrow$) Evaluate the constant-shift hypothesis at
$d=0$ and $d=1$ and subtract; the bases cancel and the increments must agree.
$\blacksquare$

Its counterpart makes the measurement falsifiable. **If $\mathrm{inc}_A <
\mathrm{inc}_B$, there is a computable context $D$ beyond which $A(d) < B(d)$ forever** —
unequal increments do not merely let the gap drift, they force it to change sign. Had
code's increment been $5$ rather than $4$, the context-$1024$ shift would have read $-3$.

So the constancy is the finding: **the domain enters only through the base, the scale only
through the increment.**

</details>

---

## 4. A line with no origin

Fix the increment. Every remaining law is one integer — its base. Translating a base by
$t \in \mathbb{Z}$ is a group action, and it is both *transitive* (any two such laws are
connected) and *free* (the connecting translation is unique). A set with a free transitive
$\mathbb{Z}$-action is a
[torsor](https://en.wikipedia.org/wiki/Torsor_(algebraic_geometry)): a copy of the integer
line that has forgotten where zero is.

The observable is the connecting translation, $\mathrm{shift}(A,B) = \mathrm{base}(B) -
\mathrm{base}(A)$. It is zero from a domain to itself, antisymmetric, and — the cocycle
law — **additive along chains**: $\mathrm{shift}(A,B) + \mathrm{shift}(B,C) =
\mathrm{shift}(A,C)$. Domain ladders are generated by their consecutive gaps.

And the punchline: translate *every* domain by the same $t$, and every shift is unchanged.
Given any target, some translation puts a chosen domain's base exactly there while fixing
all shifts. **An individual base is not an observable. Only differences are.** The
experiment measured that code sits four below prose; it did not measure $12$ and $16$.

This is the central widget of the page. Drag the re-basing slider and watch the bases move
while the shift refuses to.

{{interactive_demo:0}}

<details>
<summary><b>The envelope rule, and the price of assuming it</b></summary>

Deployments serve mixtures, so the operational object is the envelope $\max_i L_i(d)$.
Inside one increment class it is as clean as possible: the pointwise order on laws is the
order of bases, and

$$\max_i \big(b_i + \mathrm{inc}\cdot d\big) \;=\; \big(\max_i b_i\big) + \mathrm{inc}\cdot d,$$

because adding $\mathrm{inc}\cdot d$ is an order isomorphism of $\mathbb{Z}$ and therefore
commutes with finite maxima. **Deployment rule: size the cache by the largest-base domain
present.** For prose/code that means size by prose; sizing by code under-provisions by
exactly one grid step, at every context. Note how falsifiable this is — it says the mixed
base is the *maximum*, never a weighted mean. Interleave 90% code with 10% prose and you
still pay prose's price.

Now the sharp negative result. Suppose two domains have **different** increments and their
bases **cross**. Then *no budget law whatsoever* computes the envelope.

*Proof.* Past the crossover the envelope equals the steeper law $B$ forever, so a candidate
law $C$ agrees with $B$ at two distinct contexts, whence $C = B$ by affine rigidity. But
then $C(0)$ is $B$'s base, while the envelope at $0$ is $A$'s larger base. $\blacksquare$

Concretely: $(16,2)$ and $(12,6)$ have envelope $16, 18, 24, 30, 36, \dots$, a kink no
two-parameter formula can straighten. Try it in the widget with the "envelope breaks"
preset. Single-formula sizing is a *privilege* — and the measured constancy of the $-4$ is
precisely what earns it.

</details>

Both halves of that story — the join rule and its collapse — are implemented here:

{{algorithm:1}}

---

## 5. Why "easier" tells you nothing

Return to the refuted prediction: surely a corpus the model predicts well is one it can
afford to forget? The data said no. The mathematics says something stronger.

Model a domain as a pair: a full-accuracy number, and an attention profile (the cumulative
mass over sorted keys) which is what actually determines the knee.

<details>
<summary><b>Theorem: every (accuracy, knee) pair is realisable — so no accuracy law exists</b></summary>

For any tolerance $0 < \tau < 1$, any accuracy value $a$, and any $k \ge 1$, there is a
domain with full accuracy exactly $a$ and knee exactly $k$. *Construction:* the uniform
profile placing mass $\tau/k$ on each of the first $k$ keys has cumulative mass
$\tau\min(j,k)/k$, hence knee exactly $k$; the accuracy coordinate is a free label.

**Consequence.** There is no function $g$ with $\text{knee} = g(\text{accuracy})$: take two
domains with accuracy $\tfrac12$ and knees $1$ and $2$, and $g(\tfrac12)$ would be both.
Nor does a monotone version survive — one can exhibit a strictly more accurate domain
needing strictly fewer keys (the observed pattern) *and* one needing strictly more.

So the prediction was not merely false. It was **unprovable**: no accuracy data of any kind
could ever have established it.

</details>

<details>
<summary><b>What the base does measure: concentration</b></summary>

**Theorem.** If a domain meets tolerance $\tau$ with $k$ keys, some single key carries more
than $\tau/(k+1)$ of the attention mass.

*Proof.* Contrapositive of a concentration bound: if every key's mass were at most $m$,
accumulating $\tau$ would need at least $\tau/m$ keys; putting $m = \tau/(k+1)$ would give
$k \ge k+1$. $\blacksquare$

Code meets the bar at $12$ keys where prose needs $16$, so the code corpus contains a key
heavier than $\tau/13$ — its profile *cannot* be flat at that level, while prose gets no
such guarantee below $\tau/17$. The $-4$ is a statement about the **shape** of code
attention, not its difficulty.

Which is exactly right, intuitively. Prose refers back diffusely — a pronoun leans on a
paragraph. Code refers back *sharply*: this identifier bound on line 40, this brace
matching that one, this call resolving to that definition. Sharp reference makes a heavy
key; a heavy key buys a small base.

</details>

---

## 6. Being honest about what two points cannot decide

Four numbers, two parameters — a critic is entitled to be unimpressed. So the additive law
was pushed against a *mechanistic* rival.

Suppose attention decays geometrically: residual mass $r^k$, so the knee is the least $k$
with $r^k \le \rho$ where $\rho = 1-\tau$. That knee is exactly $\lceil \log\rho/\log r
\rceil$. Call $X = \log\rho/\log r$ the **continuous knee**. Now let code's attention decay
$a$ times faster, $r_{\text{code}} = r_{\text{prose}}^{\,a}$: this multiplies $\log r$ by
$a$, so it **divides** the continuous knee by $a$. Multiplicative, where our law is
additive.

Does it fit? Perfectly. With $a = 251/200 = 1.255$ and prose continuous knees $15.05$ and
$20$: $\lceil 15.05\rceil = 16$, $\lceil 15.05/a\rceil = 12$, $\lceil 20\rceil = 20$,
$\lceil 20/a\rceil = 16$. All four measured cells, exactly — and honest geometric profiles
with those continuous knees exist.

**Two contexts cannot distinguish an additive base shift from a rescaled decay rate.** That
is the honest limit, stated as a theorem rather than buried in a caveat.

But it is *removable*, and the ceiling function removes it. Explore that yourself:

{{interactive_demo:2}}

<details>
<summary><b>The two bounds that close the window</b></summary>

A reading of $n$ brackets the continuous knee: $n-1 < X \le n$.

*Lower bound.* The context-$512$ cell gives $X > 15$ from $\lceil X\rceil = 16$, and
$X \le 12a$ from $\lceil X/a\rceil = 12$. Hence $15 < 12a$, i.e. $\boxed{a > 5/4}$.

*Upper bound.* The additive law predicts $28$ keys for prose at context $4096$ and exactly
$24$ for code. Reproducing a $24$-reading needs $X_3/a > 23$ with $X_3 \le 28$, hence
$23a < 28$, i.e. $\boxed{a < 28/23 \approx 1.217}$.

These are incompatible. So a $4096$ reading of $24$ kills the multiplicative mechanism
outright; any reading $\le 23$ kills the additive law. Either way, something dies.

And $4096$ is the *first* deciding context: the same witness $a = 1.255$ also reproduces
the additive prediction at $2048$ (continuous knee $24$, code reading $20$). One doubling
short and the models still agree.

</details>

The window arithmetic, as an algorithm that reports whether a proposed probe cell is
decisive:

{{algorithm:2}}

---

## 7. The grid is the instrument

One last observation, easy to miss, and really a lesson about experimental design.

The whole result is a shift of size $4$. Suppose the sweep had used a grid of step $8$ — a
perfectly reasonable choice that halves the compute. Round each knee up to the next
multiple of $8$: code's $12$ becomes $16$; prose's $16$ becomes $16$. **Identical
readings.** The effect vanishes silently, with no warning anywhere in the data.

An effect of size $s$ is observable only on a grid whose cells do not straddle both knees.
Not more windows, not a bigger corpus, not a tighter bar — *resolution*.

{{visualization:0}}

---

## 8. Run everything yourself

Every claim on this page is checked, cell by cell, in the script below: the knee readings
and their certificates, the constancy of the shift, the torsor axioms, the envelope law and
its failure, the accuracy/knee decoupling, the concentration bound, the mechanism
separation, and the grid collapse. A clean run is a confirmation, not a printout.

{{demo:0}}

---

## 9. What it adds up to

A quantity everyone treats as a single number — *how many keys do I need?* — factors. One
parameter belongs to the domain, one to the scale. The domain parameter lives on a line
with no origin, so only gaps are ever measured, and gaps compose additively along chains.
Within one scale class the mixed budget is the maximum and is itself a law; step outside and
the envelope stops being a law at all.

The domain parameter is not difficulty — no function of accuracy predicts it, and code
proves the point by being both easier and cheaper. It is concentration: a small base
certifies a heavy attention head, and code's sharp, pointed references are what produce one.

And the coda is honest: two contexts cannot tell an additive shift from a multiplicative
rescaling, but three can, and the deciding measurement has been named in advance along with
the number that settles it. **Twenty-four keys, at context 4096.** One of two mechanisms
will not survive the reading.
