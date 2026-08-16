# The Missing Middle: Why Two Wires Are Enough, and Three Are Safe

## A single wire that carries the whole message

Imagine a machine that has learned to do something delicate — say, to know when a
sequence of symbols has ended and it is time to answer. Somewhere inside it, a
small handful of internal numbers do the announcing. Call them the *exclusive
coordinates*: the private wires along which the "we are done now" signal travels.
Everything else in the machine is busy with other work; these few numbers are the
channel.

Now do the obvious experiment. Reach inside the trained machine, set one of those
wires to zero, and re-run it. Does it still work?

This question is the whole story. Its answer turns out to depend, in an almost
comically clean way, on a single integer: how many wires there are. And the
transition happens at **two**.

The purpose of this article is to explain why. The surprising part is not the
experimental table — it is that the entire pattern in that table can be *derived*,
from two ingredients that have nothing to do with what the machine learned:
a counting argument, and the shape of a curve.

---

## The measurement that started it

Here is the observation that has to be explained. In a machine with exactly two
exclusive wires, carrying stored coefficients $c = (c_0, c_1)$, one can perform
five interventions and re-measure accuracy each time:

- **control**: leave $c$ alone;
- **single ablation** $\mathrm{zero}_i$: set $c_i$ to $0$, keep the other;
- **block ablation** $\mathrm{zero}_{\text{all}}$: set both to $0$;
- **sign flip** $\mathrm{flip}_i$: replace $c_i$ by $-c_i$;
- **rescaling** $\mathrm{scale}_\lambda$: replace $c$ by $\lambda c$.

For one particular trained machine — one particular random seed — the numbers came
back like this:

$$
\underbrace{0.9980}_{\text{control}} \quad
\underbrace{0.9961}_{\mathrm{zero}_0} \quad
\underbrace{0.9990}_{\mathrm{zero}_1} \quad
\underbrace{0.7544}_{\mathrm{zero}_{\text{all}}} \quad
\underbrace{0.7505}_{\mathrm{flip}_0} \quad
\underbrace{0.9067}_{\mathrm{scale}_{0.1}}
$$

Read that again. Deleting *either* wire on its own changes essentially nothing:
$0.9961$ and $0.9990$ both sit inside the noise band of $0.9980$. Deleting *both*
wires costs a catastrophic $0.244$. And merely *flipping the sign* of one wire —
which does not remove any information at all, it just reverses it — costs the
same $0.248$.

So each wire is individually dispensable, jointly indispensable, and yet one of
them is so far from dispensable that turning it upside down breaks everything.

This is a genuinely strange combination, and it has a name: **1-redundant but
block-dependent**. What follows is an account of exactly what such a signature
can, and cannot, mean.

---

## First lesson: the phenomenon is invisible with one wire

Before any mathematics about networks, there is a piece of pure bookkeeping that
is easy to overlook and that turns out to control the whole design.

**The one-wire collapse.** *If there is exactly one exclusive coordinate, then
"set the single coordinate to zero" and "set the whole block to zero" are the
same operation.*

That sounds trivial because it is trivial. But its consequence is not:

> **Theorem (the missing middle).** Let $F$ be *any* measurement whatsoever
> performed on the machine — accuracy, loss, the length of the longest correct
> output, anything at all; no continuity, linearity or structure is assumed. If
> every single-coordinate ablation leaves $F$ unchanged, while the whole-block
> ablation changes it, then the exclusive block has at least two coordinates.

The proof is one line: at $k = 0$ the block ablation is the identity map, so it
cannot change anything; at $k = 1$ the two interventions coincide, so they cannot
disagree; therefore $k \ge 2$.

This is worth pausing on, because it explains a piece of experimental history.
Earlier rounds of the same experiment had studied machines with exactly one
exclusive wire and had reported that ablating that wire sometimes mattered and
sometimes did not, in a pattern that seemed to track how good the machine was.
That reported pattern — "how internalized the channel is, is proportional to how
well the machine works" — did not survive fresh replication at a second set of
random seeds. And now we can see *why it could never have been tested there*: at
one wire, redundancy is not a measurable property. There is nothing to be
redundant with. The one-wire experiments were probing a distinction that does not
exist at that width.

The middle was missing because the middle **begins** at $k = 2$.

---

## Second lesson: no straight-line machine can do this

Two wires are necessary. Are they sufficient? Only if the machine bends.

Suppose, as a first model, that the boundary decision is read out *linearly*: some
baseline quantity $b$ plus a weighted sum of the wires,

$$ M(c) \;=\; b + \sum_{i} g_i\, c_i . $$

Then the entire intervention algebra collapses to one number per wire, namely
$g_i c_i$. Writing $D_i$ for the damage done by ablating wire $i$ and $D$ for the
damage done by ablating the whole block, one gets three exact laws:

$$
D \;=\; \sum_i D_i, \qquad
\text{(flip damage at } i) = 2 D_i, \qquad
\text{(damage from rescaling by } \lambda) = (1-\lambda) D .
$$

Additivity, the factor of two, and a perfectly straight scale curve.

Now feed the measurement in. Each $D_i$ is at most $0.002$ in absolute value.
Additivity then caps the block damage at $2 \times 0.002 = 0.004$. The measured
block damage is $0.2436$ — sixty times larger.

> **No-go theorem (linear form).** There is no linear boundary read-out on two
> coordinates whose single-coordinate damages are all at most $0.002$ and whose
> block damage is $0.2436$. Indeed, to be linear the arm would need at least
> $0.2436 / 0.002 = 122$ exclusive coordinates.

And the sign flip is even more damning, because the factor-of-two law does not
care about the width at all:

> **No-go theorem (sign form).** In any linear read-out, at any number of
> coordinates, a sign flip costs exactly twice an ablation. Since the measured
> ablation costs $\le 0.002$ and the measured flip costs $0.2475$, no linear
> read-out of any width fits.

So we know something real about the machine's internals without ever having
looked at its weights: **the boundary read-out is nonlinear.** But which way does
it bend?

---

## Third lesson: the direction of the bend is measurable

Here the story gets pretty. Model the read-out along the block ray as
$\varphi(S)$, where $S = \sum_i s_i$ is the total gain contributed by the
exclusive wires ($s_i \ge 0$ each) and $\varphi$ is an arbitrary scalar
nonlinearity — the trained cell's gate, whatever it happens to be. Then

$$
D \;=\; \varphi(S) - \varphi(0), \qquad
d_i \;=\; \varphi(S) - \varphi(S - s_i) .
$$

$D$ is what you lose by removing everything; $d_i$ is what you lose by removing
just wire $i$ from the top.

Everything now follows from one inequality about chords. If $\varphi$ is convex
(bending upward), then for $0 \le a \le S$,

$$ a \cdot \bigl(\varphi(S) - \varphi(0)\bigr) \;\le\; S \cdot \bigl(\varphi(S) - \varphi(S-a)\bigr), $$

which says exactly that the *last* stretch of the curve is at least as steep as
the whole. If $\varphi$ is concave (bending downward, i.e. **saturating**), the
inequality reverses. Summing the chord inequality over the wires gives the
dichotomy that organizes everything:

> **Convexity dichotomy.** With nonnegative gains $s_i$ and $S > 0$:
> - if $\varphi$ is **convex**, then $D \le \sum_i d_i$ — *the block cannot hide*;
> - if $\varphi$ is **concave**, then $\sum_i d_i \le D$ — *the block can hide*, and
>   the gap is unbounded;
> - if $\varphi$ is **affine**, both hold, so $D = \sum_i d_i$ exactly.

The convex half immediately reproduces the linear no-go and strengthens it: if
each single ablation costs at most $\varepsilon$ then any convex read-out has
$D \le k \varepsilon$. The measured arm violates this at $k = 2$,
$\varepsilon = 0.002$. So the read-out is not merely non-affine — it is
**strictly non-convex**. It saturates.

This suggests promoting the mismatch itself to an observable. Define the

$$ \textbf{redundancy defect} \qquad R \;=\; \Bigl(\sum_i d_i\Bigr) - D . $$

Then $R \ge 0$ for convex read-outs, $R = 0$ for affine ones, and $R \le 0$ for
saturating ones. **The sign of $R$ is a direct, model-free measurement of the
curvature of a hidden nonlinearity.** For the arm above,
$R \le 0.004 - 0.2436 = -0.2396$: a strict-concavity certificate, obtained from
three accuracy numbers.

---

## Fourth lesson: concavity *manufactures* redundancy, at rate $1/k$

The concave half of the dichotomy has a sharper, quantitative form. Each wire's
individual damage is bounded by its *share* of the total:

$$ d_i \;\le\; \frac{s_i}{S}\, D . $$

And if the $k$ wires split the gain equally, this becomes

$$ d_i \;\le\; \frac{D}{k} \qquad \text{for every } i, \qquad \text{while } D \text{ stays } D. $$

Read that as a statement about experiments. Under any saturating read-out, the
apparent dispensability of a single wire improves like $1/k$ as you add wires,
*while the block remains exactly as indispensable as before*. The observed trend
— "single-wire self-sufficiency rises with the number of exclusive wires: about
half at one wire, five in six at two, five in six at three" — is not evidence
that the machine learned to distribute its representation more cleverly at larger
widths. Concavity alone forces it. No appeal to learning is needed.

That is a cautionary tale for interpretability at large. A great deal of ablation
evidence is read as "the network has internalized this computation, look, you can
delete a unit and nothing happens." Concavity produces the same evidence for
free.

---

## Fifth lesson: the design rule, derived rather than fitted

If the mechanism is a saturating gate, the mechanism should predict the
thresholds. Take the canonical channel: $k$ exclusive wires of equal gain
$g > 0$, summed, rectified (negatives clipped to zero) and saturated at the level
$1$ the downstream read-out needs. Write the gate as

$$ \Gamma(c) \;=\; \min\bigl(\max(\textstyle\sum_i c_i,\, 0),\; 1\bigr). $$

Then the interventions do arithmetic:

| intervention | surviving gain | gate still saturated iff |
|---|---|---|
| control | $k g$ | $kg \ge 1$ |
| single ablation | $(k-1) g$ | $(k-1) g \ge 1$ |
| sign flip | $(k-2) g$ | $(k-2) g \ge 1$ |
| block ablation | $0$ | never |

The flip line is the one to savour: flipping a wire does not subtract that wire's
gain, it subtracts *twice* it, because the wire goes from $+g$ to $-g$. So sign
robustness always costs one more wire than ablation robustness. At unit gain the
table becomes a ladder:

> **Design rule.** In a saturated unit-gain channel, single ablations are no-ops
> **if and only if** $k \ge 2$; sign flips are no-ops **if and only if**
> $k \ge 3$; and the whole block is never dispensable.

Compare the experiments. At one wire, ablation *is* block ablation and destroys
the channel — exactly the $k=1$ rows. At two wires, single ablations are no-ops
but the flip breaks everything, $0.9980 \to 0.7505$ — exactly the arm we started
with. At three wires, both are no-ops — exactly the earlier round's report that
"signs never matter", which we can now correctly downgrade to a statement about
three wires only. Sign-sensitivity is width-conditional, and the width at which
it switches off is one above the width at which ablation-sensitivity switches
off.

The design rule that comes out of this — **at least two exclusive dimensions for
a self-sufficient recovery, at least three for a sign-robust one** — was
previously an empirical fit. It is now a two-line consequence of a clipped sum.

---

## Sixth lesson: an explicit machine that does all six things at once

Negative results are cheap; a matching positive construction is the honest test.
Here is one, and it is small enough to check by hand.

Let the evaluation set consist of four groups of items, with masses
$0.7544$, $0.1523$, $0.0913$, $0.0020$, and difficulty thresholds $0$, $0.2$,
$0.5$, $2$ respectively: a group is answered correctly exactly when the gate
value reaches its threshold. Take two exclusive wires with $c = (1,1)$ and the
rectified-clipped gate $\Gamma$ above. Then:

- **control**: $\Gamma = \min(2,1) = 1$, accuracy $0.9980$;
- **ablate wire $0$ or wire $1$**: $\Gamma = \min(1,1) = 1$ — the gate is *still*
  saturated — accuracy $0.9980$, an exact no-op;
- **ablate the block**: $\Gamma = 0$, accuracy $0.7544$;
- **flip wire $0$**: the sum is $-1+1 = 0$, so $\Gamma = 0$, accuracy $0.7544$;
- **rescale by $0.1$**: the sum is $0.2$, $\Gamma = 0.2$, accuracy $0.9067$.

Against the measured $0.9980 / 0.9961 / 0.9990 / 0.7544 / 0.7505 / 0.9067$, every
one of the six is matched to within $0.005$ — the reported no-op scale. One
population, one two-dimensional coefficient vector, six numbers, no free
parameters left over.

And the construction explains, rather than fits, the three qualitative facts that
made the arm look paradoxical: the single ablations are no-ops **because the gate
is still saturated at $1$** after removing one wire of two; the flip is not a
no-op **because it removes two wires' worth**; the rescaling is not a no-op
**because it drops the gate below every nonzero threshold but the lowest**. The
accuracy ordering
$\mathrm{zero}_{\text{all}} \le \mathrm{scale}_\lambda \le \mathrm{control}$
is a theorem of the model, and the data obey it: $0.7544 \le 0.9067 \le 0.9980$.

---

## Seventh lesson: when a no-op means nothing at all

There is one more result, and it is the one that should change how these
experiments are read.

Pooled across two independent rounds and twelve one-wire machines, ablating the
sole exclusive wire was a no-op **in every machine that had already failed the
task**. That looks, at first, like a positive finding: the failed machines had
internalized the boundary! They don't need the channel!

In the population model it is forced, and it means the opposite:

> **Boundary-free arms are intervention-proof.** If a machine's control accuracy
> already equals its zero-gate accuracy — i.e. none of the items it gets right
> depend on the boundary signal at all — then *every* gate-weakening intervention
> is an exact no-op. Conversely, that is the *only* way for all of them to be
> no-ops.

A universal no-op is therefore evidence that the channel was **never used**, not
evidence that its content has been absorbed elsewhere. It is the signature of an
unread wire, not an internalized one.

And the final blow to the proportionality story: at one wire, *every* admissible
pair of numbers is realizable. For any $0 \le \beta \le \alpha \le 1$ there is a
population whose control accuracy is $\alpha$ and whose ablation accuracy is
$\beta$. Full self-sufficient cures ($\beta = \alpha$ near $1$), no-ops at failed
machines ($\beta = \alpha$ near $0$), and marginal partial losses
($\beta < \alpha$) all live inside one model class. The one-wire table constrains
nothing. That, precisely, is why a law read off from it did not replicate.

---

## What is left over: the one thing the model gets wrong

An honest model should be falsifiable, and this one is — in a specific,
productive way.

At a fixed clip level, the model predicts that *larger* wires are *more*
self-sufficient: if the channel survives ablation at per-wire gain $g$, it
survives at every $g' \ge g$, because $(k-1)g' \ge (k-1)g \ge 1$. The data say the
reverse. The single machine that stayed boundary-dependent, at both two and three
wires, is the machine with the **largest** exclusive coordinates of its width
($0.701$ against at most $0.660$ for its siblings). It should have been the most
robust; it was the only fragile one.

There is one conservative repair, and it is a sharp prediction: the effective
clip level $T$ is not a constant across machines but scales with the coordinate
magnitude, $T \asymp g_{\max}$. If so, self-sufficiency is governed by the
*dimensionless* ratio $(k-1)g / T$ rather than by $(k-1)g$, and the apparent
seed-idiosyncrasy becomes a measurable scalar. That test costs no new training —
it re-uses arms already scheduled.

---

## The moral

Three things came out of a table of six accuracy numbers.

**Counting.** A redundancy phenomenon needs at least two channels to exist at
all; below that, the experiment measures a distinction that is not there. Whole
literatures of single-unit ablations are, structurally, unable to see it.

**Curvature.** The gap between "sum of the parts" and "the whole" — the
redundancy defect $R = \sum_i d_i - D$ — has a sign, and that sign is the
curvature of a nonlinearity you never observe directly. Positive means convex,
zero means linear, negative means saturating. Three accuracy measurements are
enough to read it off.

**Saturation manufactures the illusion of understanding.** Under a saturating
gate, single components look dispensable at rate $1/k$ for reasons of geometry
alone. When you delete a unit and nothing happens, you have learned something
about the shape of a curve, and possibly nothing whatsoever about what the
network knows.

The middle was never missing. It starts at two.
