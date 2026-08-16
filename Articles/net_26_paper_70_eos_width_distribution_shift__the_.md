# The Threshold That Wasn't

## How a single extra dimension turns luck into certainty

There is a particular kind of failure that anyone who has trained a recurrent
network on arithmetic knows by heart. You teach a small network to add numbers
digit by digit, right to left, carrying as it goes. On five-digit problems it is
flawless. On six digits it slips a little. On seven it is wrong more often than
right, and on eight it has essentially forgotten how to count. The accuracy
curve does not fall off a cliff; it slides. $1.0000 \to 0.9556 \to 0.1445 \to
0.0166$. The errors cluster in columns, as though the machine loses its place
somewhere in the middle of the sum and never recovers.

Call it the **carry wall**. And there is a folk remedy for it: feed the network
an explicit *boundary token* — a learned marker that says "the number ends
here." Append it, and the wall often disappears.

Often. Not always. And the story of *when* it works turns out to be a small,
sharp lesson about the difference between a threshold and a distribution — and
about a piece of geometry hiding inside a network's embedding table.

---

## The measurement that looked like a threshold

The boundary token is a learned vector of some width $E$, padded with zeros out
to the network's full input width of $384$. The digits themselves occupy the
first $D = 20$ coordinates. Everything else about the experiment is held fixed;
only $E$ varies.

Sweep $E$ across $\{20, 28, 64, 96, 128, 192, 256, 384\}$, two random
initialisations each, and a clean picture appears:

- $E = 20$: two runs, accuracies $0.9990$ and $0.0166$. Coin flip.
- $E \geq 28$: fourteen runs out of fourteen at $1.0000$. Perfect.

The tempting reading — and the one an earlier round of the investigation
actually adopted — is that there is a **width threshold** somewhere between $20$
and $28$. Below it, the cure fails; above it, the cure works. Clean, quotable,
and, as it happens, *false*.

The refutation is embarrassingly simple, and it requires no statistics at all.
Run more seeds at $E = 20$. Twelve arms in total give the accuracy sample

$$\{0.9990,\ 0.9990,\ 0.9990,\ 0.7440,\ 0.1240,\ 0.0580,\ 0.0310,\ 0.0260,\ 0.0170,\ 0.0110,\ 0.0060,\ 0.0050\}.$$

Three of those twelve are clean cures. Nine are not. But all twelve have exactly
the same width. A threshold model says the outcome is a *function of the width*:
there is some $E_0$ such that a run is cured if and only if $E \geq E_0$. Two
runs at width $20$ with opposite outcomes make that a logical impossibility — a
function cannot send one input to two different outputs. No threshold, of any
value whatsoever, fits this data.

**The No-Sharp-Boundary Theorem.** *If a collection of experimental runs
contains two runs of the same boundary width, one cured and one not, then no
width threshold reproduces the outcomes. The observed data contains such a
pair; hence no threshold model of the carry-wall cure is correct.*

That is a one-line proof of a claim that had been stated as an empirical law.
It is worth pausing on how cheap the refutation is once you have the right
framing: the mistake was not a statistical mistake, it was a *type* mistake.
Outcome is not a function of width. It is a random variable whose *distribution*
depends on width.

---

## What replaces the threshold

If width does not determine the outcome, what does it do? It shifts the odds,
and it shifts them in one direction only.

Pool everything. Twelve runs at $E = 20$: three clean cures, a cure rate of
$3/12 = 25\%$, with a median accuracy of $0.0445$. Twenty runs at $E \geq 28$:
twenty clean cures, a rate of $20/20 = 100\%$, with zero failures.

The correct statement compares the two *entire* accuracy distributions, not just
their cure rates. For every accuracy level $t$, the fraction of $E \geq 28$ runs
scoring at least $t$ is at least the fraction of $E = 20$ runs scoring at least
$t$. In the language of probability, the robust distribution **stochastically
dominates** the fragile one, and the domination is strict at the cure level:
$3/12 < 20/20$. Widening the boundary token never hurts and sometimes helps.
That is the whole law:

> **The One-Sided Distribution Shift.** Boundary width does not gate the cure
> deterministically. It gates the *probability* of the cure, monotonically and
> in one direction.

Two natural objections deserve answers, and both have them.

*Is $20/20$ really enough evidence for "probability one"?* Under an independent
Bernoulli model with per-run cure probability $p$, the chance of twenty
successes in twenty attempts is $p^{20}$. If $p \le 0.86$, then
$p^{20} \le 0.86^{20} < 0.05$. So the data rules out any cure probability at or
below $0.86$ at the usual one-sided $5\%$ level. The robust regime is not merely
"better"; it is at least $86\%$ reliable, and every observation is consistent
with exactly $1$.

*Could a single common cure probability explain both regimes, with the split
being luck?* No, and the margin is enormous. Under a pooled model the likelihood
of the data is proportional to $p^{23}(1-p)^{9}$ — twenty-three successes, nine
failures. That expression is maximised at $p = 23/32$, a fact one can prove by
hand with the exponential form of the arithmetic–geometric mean inequality,
$a \le c\,e^{a/c - 1}$, applied once to $p$ with $c = 23/32$ and once to $1 - p$
with $c = 9/32$; the two exponentials cancel exactly. Comparing that maximum
against the two-regime alternative, which attains
$(1/4)^3 (3/4)^9 \cdot 1^{20}$, gives

$$100000 \cdot p^{23}(1-p)^{9} \ \le\ (1/4)^3 (3/4)^9 \cdot 1^{20} \qquad \text{for all } p \in [0,1].$$

Uniformly in $p$, the homogeneous null is more than $10^5$ times less likely
than the two-regime picture. The regimes are genuinely different — and neither
of them is deterministic in width.

---

## Why: a boundary token needs a room of its own

Here is where the phenomenon stops being statistics and becomes geometry.

Networks of this kind compute, at heart, by taking maxima of sums. A layer looks
at each input coordinate, adds a weight, and keeps the largest result. That is
exactly arithmetic in the **max-plus** (or *tropical*) semiring: the operation
playing the role of addition is $\max$, and the operation playing the role of
multiplication is ordinary $+$. Its zero element is $-\infty$, meaning "this
coordinate is not used," and its one is $0$.

Model the digit tokens as the $D$ tropical unit vectors: digit $j$ carries the
value $0$ in coordinate $j$ and $-\infty$ everywhere else. A boundary token is
some other vector $x$. Say $x$ has an **exclusive dimension** if it is finite on
some coordinate $p \ge D$ that no digit ever touches.

Everything follows from one clean dichotomy.

**The Span Theorem.** *A boundary vector lies in the max-plus span of the digit
vectors if and only if it has no exclusive dimension.*

The proof is immediate in both directions. A max-plus combination of the digit
vectors is $-\infty$ outside the digit block, because every term is; conversely,
a vector that is $-\infty$ outside the block is reconstructed by taking its own
coordinates as the combination's coefficients.

Now let a *readout* be a max-plus linear functional: pick weights $w$ and score a
vector $x$ as $\mathrm{score}_w(x) = \max_i (w_i + x_i)$. What can a readout see?

**The Ambiguity Theorem.** *If a boundary vector $x$ has no exclusive dimension,
then for every readout $w$,*
$$\mathrm{score}_w(x) = \max_{j < D}\Big( x_j + \mathrm{score}_w(\text{digit } j)\Big).$$
*The boundary response is a fixed max-plus combination of the digit responses —
fixed in the sense that the coefficients depend only on the boundary token, not
on the readout.*

In plain words: the network has no channel that hears the boundary but not the
digits. Whatever it learns about the boundary, it learns through the digits, and
an immediate consequence bounds how far it can get:

**The Bounded-Margin Theorem.** *With no exclusive dimension,*
$$\mathrm{score}_w(x) \ \le\ \Big(\max_{j<D} x_j\Big) + \max_{j<D} \mathrm{score}_w(\text{digit } j)$$
*for every readout $w$. The boundary can beat the best digit by at most its own
largest coefficient — uniformly over all possible readouts.*

And this bound is not a lazy estimate. It is exactly attained: the readout that
listens to the single coordinate carrying the boundary's largest coefficient
realises the bound with equality. So the *best achievable margin* between the
boundary token and the digit tokens is precisely

$$\max_{i < D} c_i,$$

where $c$ is the vector of learned boundary coefficients inside the digit block.
Not approximately. Exactly.

Contrast this with the other side of the dichotomy. Give the boundary token a
single exclusive dimension $p$, and the readout that listens only to $p$ scores
every digit at $-\infty$ while scoring the boundary as high as you like: for any
target $M$ there is a readout achieving margin $M$. Better, the separation is
*stable* — perturb the readout gain by any $e$ with $|e| \le r$ and the boundary
still scores at least $M - r$ while the digits still score $-\infty$. One
exclusive dimension buys an unbounded, robust margin. Zero exclusive dimensions
cap the margin at a single learned number.

---

## The luck, located

Now the probabilistic law falls out, and the source of the randomness becomes
completely explicit.

When $E \le D$, the boundary token lives entirely inside the digit block. Its
coefficients $c_1, \dots, c_E$ are *learned*, which is to say they depend on the
random initialisation — the seed. And we have just seen that the best possible
boundary-vs-digit margin equals $\max_i c_i$. So:

**The Separability Criterion.** *A boundary token supported inside the digit
block can be separated from every digit by some readout if and only if at least
one of its coefficients is strictly positive.*

That is the whole coin flip. It is not about capacity, not about width, not
about how many parameters the token has. It is a *sign event* on a maximum of
learned coordinates. Some seeds land with a positive coefficient and the network
finds a boundary channel; some do not, and it never does.

Because a random coefficient vector satisfies the criterion sometimes and not
others, the cure probability in the fragile regime is strictly between $0$ and
$1$: if some seed can produce an all-nonpositive coefficient vector the
probability is below $1$, and if some seed can produce a positive coefficient it
is above $0$. Meanwhile, when $E > D$ the token automatically owns coordinate
$D$, which no digit uses, so *every* seed is separable and the cure probability
is exactly $1$. Put together, that is the formal law:

**The One-Sided Distribution Shift Theorem.** *In the fragile regime $E \le D$
the cure probability lies strictly inside $(0, 1)$; in the robust regime $E > D$
it equals $1$; and widening the boundary token can never destroy separability,
because a readout that separates a token also separates any token that dominates
it coordinatewise.*

The simplest instance is a two-seed model on a one-dimensional digit block, one
seed learning coefficient $+1$ and the other $-1$: the cure probability is
exactly $1/2$. The measured $3/12 = 1/4$ is the same kind of number — interior,
not a $0$ and not a $1$.

---

## And why the collapse is smooth

One loose end. If the fragile regime simply lacks a channel, why does accuracy
*slide* with sequence length instead of dropping at once?

Because a max-plus layer cannot amplify a gap. Such a layer is monotone, and it
commutes with tropical scalars: if $x_i \le c + y_i$ for all $i$ before the
layer, then the same inequality holds after it, with the same $c$. Iterate the
layer any number of times and $c$ is still $c$. Since the fragile boundary token
is dominated by $\max_i c_i$ plus the all-digit token, at *every* unroll depth
the boundary trajectory stays within $\max_i c_i$ of the all-digit trajectory.
There is no depth at which the boundary suddenly becomes loudly distinguishable
— and, symmetrically, no depth at which the gap catastrophically explodes. The
margin the seed granted at step one is the margin you have forever. What
degrades with depth is not the margin but the number of chances to lose,
producing exactly the slow, monotone slide observed.

The robust regime has the opposite invariance: an exclusive dimension is
preserved by the recurrence at every depth, so the unbounded separation remains
available however far you unroll.

---

## Diagnostics, corrections, and the moral

The mechanism predicts an observable signature, and the signature is there. In
the cured runs the hidden-state norm is flat across the unroll — drift below
$0.2$ — and the maximum output confidence sits at $1.000$. In the failing runs
the norm drifts by $+2.2$ and confidence dips into the $0.945$–$0.984$ band.
That is what "the state left its training distribution" looks like from the
outside.

Two earlier claims had to be withdrawn along the way, and both withdrawals are
instructive. The first: "$28$-dimensional boundaries fail." They do not; the
observation came from a *different network architecture*, and on the shared
$384$-dimensional cell $E = 28$ cures every time. The second: "$20$-dimensional
boundaries fail, $0$ out of $2$." That was two unlucky draws from a distribution
with cure probability about $1/4$ — an event of probability roughly $9/16$, which
is to say, not evidence of anything. A control experiment that was supposed to
prove two configurations shared identical weights turned out to be invalid,
because the two configurations drew different random-number streams; but the
invalidity was immaterial, since the direct construction-order check reproduced
$0.9990$ byte-identically both before and after reseeding.

What survived is the underlying mechanism — a dense boundary input keeps the
hidden state in-distribution at depth — and it survived on far better evidence
than it was originally claimed on: $20/20$ against $3/12$.

The moral is compact enough to carry away. When an intervention seems to have a
threshold, ask first whether the outcome is really a function of the knob you
turned. If two identical settings disagree, it is not. What you have is a
distribution shift, and the honest question becomes: what is the *event* whose
probability the knob controls? Here the answer is unusually crisp. The knob is
width; the event is "at least one learned coefficient is positive"; the reason
width matters is that widening past $D$ hands the boundary token a dimension of
its own, and a token with a room of its own does not have to compete for
attention. Distinctness, not size, is the control variable — and the number
$28$ was never a threshold at all, only the first place we happened to look on
the safe side of $20$.
