# The Layer That Isn't There

## What a flat measurement really tells you about a deep network

There is a seductive experiment you can run on any deep network, and almost
everyone who works with one has run it. Take the trained model, pick a layer,
break it — prune it, quantise it, zero it out, restrict its attention to a
handful of keys — and watch what happens to the output. Then put it back,
break the next layer, and repeat. When you are done you have a *profile*: one
number per layer, a bar chart of blame. The tall bars are the layers that
matter. The short bars are the layers you can economise on.

Recently that experiment was run carefully on a 24-layer language model. For
each layer in turn, and only that layer, attention was restricted to an oracle
top-$k$ set of keys with $k = 16$; every other layer was left completely
intact. The result was a bar chart with essentially no bars at all.

The best layer scored $1.0013$ and the worst $0.9953$ — a total spread of
$0.6$ points across the entire stack, with every single layer above $0.995$.
And the layer that came out *best*, the one whose damage was smallest of all,
was $L_{23}$: the very last layer, the "identity tail" that four independent
prior experiments had flagged as the strangest, most idiosyncratic, least
portable part of the whole model.

The natural reading is: there is no bottleneck. No layer is more fragile than
any other. The hypothesis that the tail is critical is refuted; the hypothesis
that layer importance is non-uniform is refuted.

That reading is wrong — not because the measurement was sloppy, but because of
what the measurement *is*. This article is about a theorem, and a family of
exact counterexamples around it, which together say something uncomfortable
and precise:

> A flat solo-ablation profile carries **no information whatsoever** about the
> damage done by ablating several layers at once — in either direction. And
> flatness is exactly what you should expect to see even from a network in
> which some layer is doing all the work.

## Layers as channels, damage as distance

To say anything sharp we need a model stripped down to its bones. Forget
attention heads and residual streams. A layer is a device that takes a
probability distribution over states and returns another one. Formally, a
layer is a **Markov channel** $K$: for each input state $a$ it specifies an
output distribution $K(a)$, and it acts on a distribution $\mu$ by

$$(K_*\mu)(b) \;=\; \sum_a \mu(a)\, K(a)(b).$$

A **stack** $F = (f_0, f_1, \dots, f_{n-1})$ is a list of such channels applied
left to right. **Damage** is measured in total variation distance,

$$d_{\mathrm{TV}}(\mu,\nu) \;=\; \tfrac12 \sum_a |\mu(a) - \nu(a)|,$$

which is $0$ when two distributions agree and $1$ when they are as different
as distributions can be. Everything below lives in this model, with all
weights rational, so every number quoted is exact rather than simulated.

Now the three quantities the whole story turns on. Suppose we prune layer $j$,
replacing the intact channel $f_j$ by a damaged one $p_j$.

- The **point cost** of layer $j$ is the damage the layer does *to its own
  output*, measured immediately, before anything downstream sees it:
  $d_{\mathrm{TV}}\big((f_j)_*\nu, (p_j)_*\nu\big)$, where $\nu$ is the state
  arriving at layer $j$ in the intact network. This is the honest answer to
  "how much did this layer break?"
- The **solo cost** of layer $j$ is what the experiment actually measures: the
  damage visible *at the output of the whole stack* when layer $j$ alone is
  pruned.
- The **joint cost** is the damage at the output when the whole stack is
  pruned at once — which is what you care about when you deploy.

The experiment reports solo costs. The design decision needs joint costs. The
mechanistic story wants point costs. Almost everything interesting happens in
the gaps between these three.

## Layers only forget

The first structural fact is the oldest one in information theory, and in this
setting it has a two-line proof. Push two distributions through the *same*
channel and they cannot get further apart:

**Data-processing inequality.** For any channel $K$ and any $\mu, \nu$,
$$d_{\mathrm{TV}}(K_*\mu, K_*\nu) \;\le\; d_{\mathrm{TV}}(\mu,\nu).$$

Applied along a stack, this gives the fact that quietly destroys the naive
reading of the experiment:

**Masking (weak form).** The solo cost of layer $j$ never exceeds its point
cost.

Downstream layers can hide damage. They can never manufacture it. So a flat
solo profile is consistent with a wildly uneven point profile — the layers
after the one you broke simply washed the evidence away. The measurement can
only *under-report*, and it under-reports by an amount nobody measured.

How much can it under-report? Enough that "an order of magnitude below the
experiment's resolution" is the generic case, not a pathology. The quantitative
tool is the **Dobrushin coefficient** of a channel,

$$\delta(K) \;=\; \max_{a,b} \; d_{\mathrm{TV}}\big(K(a), K(b)\big),$$

a number between $0$ and $1$ measuring how much of the input the channel still
remembers. $\delta = 1$ means the channel is faithful; $\delta = 0$ means it
outputs the same law no matter what came in. The classical contraction theorem
sharpens data processing to

$$d_{\mathrm{TV}}(K_*\mu, K_*\nu) \;\le\; \delta(K)\, d_{\mathrm{TV}}(\mu,\nu),$$

and iterating over a suffix of $m$ layers each with coefficient at most
$\delta$ gives the

**Masking Theorem.** $\;\text{solo cost of layer } j \;\le\; \delta^{\,m_j} \cdot \text{point cost of layer } j$, where $m_j$ is the number of layers after
$j$.

Put $\delta = \tfrac12$ — an utterly ordinary amount of forgetting — and a
layer sitting eleven layers before the output can destroy its own output law
*completely*, point cost $1$, the maximum possible, and still move the solo
measurement by less than $0.0005$. The reported spread of the whole 24-layer
experiment was $0.006$. The catastrophe is an order of magnitude below the
noise floor.

And this is not a bound that happens to be loose. In an explicit two-state
family of layers it is attained exactly: the solo cost is *precisely*
$\delta^m$ times the point cost, on the nose.

**So a flat solo profile is not evidence about which layers matter. It is
evidence about how much the stack forgets.** Those are different claims about
different objects, and the experiment cannot tell them apart.

## Where the measurement *is* honest

The theory is not uniformly bad news, and its good news lands in a suspicious
place. The exact converse of masking holds. Call a layer **lossless** if it
merely relabels the state by a bijection — a permutation channel, Dobrushin
coefficient $1$, the least forgetful thing there is. Then:

**Identifiability at a lossless suffix.** If every layer after $j$ is lossless,
the solo cost of layer $j$ equals its point cost *exactly*.

And there is one layer for which this hypothesis is free: the last one, whose
suffix is empty. For the final layer, solo cost and point cost coincide with no
loss at all. Between the two extremes the picture is completely controlled: if
the whole suffix after $j$ contracts by a factor $c$, then solo $\le c \cdot$
point, with the two endpoints $c=1$ (perfect faithfulness) and $c=0$ (total
masking) both attained. The entire range from "the measurement sees everything"
to "the measurement sees nothing" is a function of downstream contraction
alone, with no reference whatsoever to which layer is important.

Now recall which layer scored best in the experiment. $L_{23}$ — the final
layer, the one place where the measurement is provably faithful. Its small
number is real: the tail's own perturbation genuinely is small. What the
theory says is that this is entirely compatible with the tail being
indispensable, because its role need not live in its own output law. It can
live in the *interaction*.

## Two stacks the experiment cannot tell apart

Abstract inequalities are one thing; a counterexample you can write on a napkin
is another. Here is one, at exactly the measured depth of $24$.

Build a stack of $23$ transparent layers — each the identity channel, passing
its input through untouched — followed by one totally forgetful final layer
that outputs a fixed distribution no matter what it receives. Pruning any
transparent layer means replacing it by a constant $\mathrm{Bernoulli}(t)$
layer, which is as destructive as you like: at $t = 1$ it flips the state
outright.

Ablate any single layer of this stack, at any strength $t$, and the output does
not move at all. The solo cost is exactly $0$, at every one of the 24 layers.
The profile is not merely flat; it is *perfectly* flat, flatter than any real
measurement. If a transparent layer is broken, the forgetful tail erases the
evidence. If the tail itself is ablated — replaced by the identity — nothing
upstream was damaged, so there is nothing to see.

Prune the whole stack at once, however, and the joint cost is exactly $t$.

Take $t = 0.017$ and $t = 1$ and you have two prunings of one and the same
network with **identical, identically zero solo profiles**, whose joint costs
are the benignly measured $1.7\%$ and the catastrophic $1$ — total destruction
of the output law. No experiment of the form "break one layer, look at the
output" can distinguish them. This is the formal content of the claim that a
flat profile identifies nothing.

The failure is two-sided, too, which kills the other natural intuition. A
two-layer stack of transparent layers, pruned into two state-flips, has solo
cost $1$ at *each* layer — maximal damage, twice — and joint cost exactly $0$,
because the second flip undoes the first. So joint damage is not bounded below
by the largest solo cost, and not bounded above by their sum. There is no
inequality to be had in either direction.

## Why the real network looked sub-additive anyway

The same programme measured something else worth explaining. Pruning all $24$
layers together cost $1.7\%$, whereas summing the $24$ solo costs predicts
about $4.8\%$. Damage does not add up; interactions are *sub-additive*, and by
a factor of nearly three.

Sub-additivity is not a law — the counterexample above has all solo costs $0$
and joint cost $1$. So it must come from structure, and the structure is again
contraction. In a telescoping decomposition, damage created at layer $i$ still
has to travel through the intact layers after it, and each of those damps it by
$\delta$. Summing the geometric series gives:

**Geometric budget.** If every intact layer contracts by $\delta$ and every
pruned layer is within $c$ of its intact counterpart uniformly over inputs,
then the joint damage of pruning the entire stack is at most
$$c \sum_{i<n} \delta^{\,i} \;\le\; \frac{c}{1-\delta},$$
a bound **independent of the depth** $n$.

Against the naive additive prediction $n \cdot c$, that is a decisive
improvement, and it is sharp: an explicit family of affine two-state layers
attains it exactly, at every depth and every admissible $(\delta, c)$. Because
the bound is attained, the observed ratio stops being a curiosity and becomes
an *estimator*. Feeding in the measured depth $24$, an intact-layer contraction
of $\delta = 8/9$ and a uniform per-layer budget of $c = 1/500$ reproduce the
laboratory numbers exactly: additive prediction $24/500 = 4.8\%$, joint damage
provably between $1.69\%$ and $1.70\%$.

In that stack, all $24$ layers are *identical*. There is no hierarchy, no
special layer, no bottleneck — and the measured sub-additivity comes out right
on the nose. One number, the contraction coefficient, accounts for the whole
effect.

## How many layers must you break at once?

If solo ablation is blind, the obvious fix is to break two layers at a time.
That works, and beautifully, in the counterexample above: ablate a transparent
layer *together with* the forgetful tail, and the hidden damage is recovered
exactly. The general mechanism is clean — if ablating a later layer renders the
suffix lossless, then the differential pair cost equals the point cost exactly.
On the depth-$24$ witness, two prunings with identical, identically zero solo
profiles have pair costs $0.017$ and $1$ at *every* transparent layer: a
separation of $0.983$ achieved at arity $2$ where arity $1$ achieves $0$.

But the fix does not generalise, and the way it fails is the sharpest result in
the story. Spread the forgetting over *two* tail layers instead of one. Now
every single ablation costs $0$ — and so does every *pair*, because one
surviving forgetful layer is enough to erase everything upstream of it. Only at
arity $3$, breaking a transparent layer together with both maskers, does the
damage appear, and then it appears in full.

The pattern continues without end. With $m$ masking layers, *every* ablation
set of size at most $m$ leaves the output law exactly unchanged, while the
single experiment of arity $m+1$ returns the true per-layer damage exactly. The
argument is a pigeonhole: either a masker survives and resets the state, or
your ablation set is precisely the set of maskers, in which case you never
touched a transparent layer at all.

**No fixed-arity ablation protocol is sound for all stacks.** For any budget
you fix in advance, there is a 24-layer network on which every experiment
within that budget returns exactly zero while the true damage is total.

Between the extremes there is a smooth and computable version. With $m$ masking
layers each contracting by $\delta$, an experiment that ablates the layer under
study together with $k$ of its maskers reports exactly $\delta^{\,m-k}$ times
the point cost. The masking factor decays in the number of *surviving* maskers,
each additional ablation buying a factor $1/\delta$. So the minimal informative
arity is a quantity you can compute in advance from the contraction spectrum.
Concretely: $11$ masking layers at $\delta = 1/2$, a layer whose point damage
is $1/2$, and a resolution of $0.6$ points. Every experiment of arity at most
$5$ reports below the resolution — the solo measurement reports $1/4096$,
three orders of magnitude below the damage it is meant to detect — and the
arity-$6$ experiment finally reports above it. Nothing in that calculation
mentions importance. It is all contraction.

## What to conclude

The verdict "no single layer is the bottleneck" is true, and it is a statement
about the measurement rather than about the network. Solo ablation is a
*low-pass filter on depth*: it reports faithfully at the output end of the
stack and attenuates geometrically as you move upstream, at a rate set by how
much the network forgets. Feed it a network with a genuine bottleneck deep in
the stack and it will hand you back a flat profile and a clean conscience.

Three practical morals follow, and none of them require abandoning ablation.

First, **report the contraction, not just the profile.** The ratio between the
additive prediction and the measured joint cost is an estimator of the
network's contraction coefficient, and that coefficient is what determines how
much your profile could possibly have seen.

Second, **compute your resolution before you run the experiment.** Given a
contraction estimate and a target damage level, the minimal arity at which a
layer's damage becomes visible above your noise floor is a closed-form
quantity. Running below it is guaranteed to produce a flat chart regardless of
the truth.

Third, and most bluntly: **flatness is not a licence.** The design conclusion
that there is no per-layer budget hierarchy to exploit for mixed-precision
serving does follow from the data — but only because the joint cost was
*separately* measured at $1.7\%$. Had it not been, the same flat profile would
have been equally consistent with a stack that shatters completely the moment
you prune it everywhere at once.

The strangeness of the tail was never refuted. It was merely invisible to an
instrument that, provably, cannot see interaction.
