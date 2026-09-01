# The Last Two Layers: Why Shrinking a Neural Network Should Not Be Democratic

## A compression story with a twist

Every large language model you have ever used has been squeezed. The weights that come
out of training are 32-bit floating-point numbers — roughly seven decimal digits of
precision each — and nobody ships that. Before a model reaches a phone, a laptop, or a
cheap inference server, its numbers are *quantized*: each weight is snapped to the
nearest value on a much coarser grid. Four bits per weight is now routine. That is
sixteen possible values per number, down from four billion. The model shrinks by a
factor of eight, and — this is the miracle that makes the whole industry run — it mostly
still works.

Mostly. Compression is never free, and the usual way to pay for it is uniformly: every
layer of the network gets the same coarse grid, because that is the simple thing to do
and because nobody has a principled reason to do otherwise. Democracy among layers.

This article is about why that democracy is a mistake, and about a small experiment
whose numbers turned out to be the visible tip of a rather pretty piece of mathematics.

## Three numbers

Take a 24-layer transformer — a small one, half a billion parameters, the kind that runs
comfortably on a laptop. Measure how often its compressed version agrees with the
original on a fixed set of prompts. Call that the *retained accuracy*: $1.0$ means the
compressed model behaves identically, $0$ means it has become a different model.

Three experiments:

| what was compressed to 4 bits | retained |
|---|---|
| every layer | $0.9081$ |
| every layer **except the last two** | $0.9261$ |
| **only** the last two layers | $0.9766$ |

The middle row is the headline. Leaving just two layers out of twenty-four at full
precision buys back $1.8$ percentage points of agreement — and the memory it costs is
about five percent of the compressed model. Two layers. Five percent. Nearly two points.

The third row is the diagnosis. Compressing *only* the tail pair — and nothing else —
already costs $2.34$ points. Those two layers, four percent of the depth, carry a
disproportionate share of the fragility.

The natural reaction is: fine, an empirical quirk of one model. The interesting
question is whether it is a quirk at all. It is not. There is a theorem underneath, and
in fact three of them.

## Where fragility lives: the sensitivity profile

Think of a network as a stack of functions applied one after another,
$$x \mapsto f_0(x) \mapsto f_1(f_0(x)) \mapsto \cdots \mapsto f_{n-1}(\cdots).$$
Each layer $f_j$ has a *Lipschitz constant* $L_j$: the largest factor by which it can
stretch a distance between two inputs. If $|f_j(x) - f_j(y)| \le L_j\,|x-y|$ for all
inputs, then $L_j$ measures how loudly layer $j$ shouts.

Now suppose you quantize. Layer $j$ is replaced by an approximate layer that differs
from it by at most $\delta_j$ at every input. What happens to the output?

The perturbation introduced at layer $j$ has to travel through every layer *after* it,
getting stretched or squashed on the way. So its contribution to the final error is
$\delta_j$ multiplied by the product of the downstream Lipschitz constants. Add up the
contributions and you get a certified end-to-end bound:
$$\text{error} \;\le\; \sum_{j=0}^{n-1} \delta_j \cdot s(j), \qquad
s(j) \;=\; \prod_{k > j} L_k .$$

That function $s(j)$ — the *sensitivity profile* — is the whole story. It says exactly
how much a unit of noise injected at depth $j$ is worth at the output.

And now the punchline, which is almost embarrassingly simple once you see it. Suppose
the network is **non-expansive**: every layer satisfies $L_j \le 1$, so no layer
amplifies distances. This is the normal regime for a trained transformer with
normalization layers; the whole architecture is built to keep activations from blowing
up. Then

$$s(j) = \prod_{k>j} L_k \quad\text{is a product of fewer and fewer numbers, each} \le 1,
\text{ as } j \text{ grows.}$$

Deleting factors that are at most $1$ from a product can only make it larger. So $s$ is
**monotone increasing in depth**, and it attains its maximum, exactly $1$, at the very
last layer — because the last layer has nothing downstream to damp it.

> **Tail-Dominance Theorem.** In a non-expansive stack, the sensitivity profile is
> non-decreasing in depth: $s(0) \le s(1) \le \cdots \le s(n-1) = 1$. Noise injected at
> the tail reaches the output undiminished; noise injected at the head is attenuated by
> everything that follows it.

Errors made early get filtered by the rest of the network. Errors made at the end go
straight out the door. That is why the last two layers are special, and it is not a
property of this model or this dataset — it is a property of composition.

The theorem has a mirror image that is worth stating, because it stops the result from
being a slogan. If instead every layer *expands*, $L_j \ge 1$, the ordering reverses
exactly: sensitivity is largest at the **head**. So "protect the tail" is not a
universal law of neural networks. It is a consequence of the contraction regime the
network happens to be in — and the correct universal statement is a dichotomy:

> **Precision Dichotomy.** Which end of a network deserves precision is decided by
> whether the layers contract or expand. Non-expansive: protect the tail. Expansive:
> protect the head.

## How many bits, exactly? A water-filling law

Knowing *which* layers are fragile is qualitative. The interesting engineering question
is quantitative: given a fixed total budget of bits, how should you spread them?

Model it. A $b$-bit uniform quantizer on a block of weights whose values span a range
$R$ produces a per-layer deviation of roughly $R \cdot 2^{-b}$ — each extra bit halves
the grid spacing. Combine that with the propagation bound and the certified error of an
allocation $b = (b_0, \dots, b_{n-1})$ becomes
$$\mathrm{cost}(b) = \sum_{i} c_i\, 2^{-b_i}, \qquad c_i = s(i)\, R_i > 0,$$
where $c_i$ packages "how sensitive is this block" together with "how wide is its
dynamic range". The budget constraint is $\sum_i b_i = B$.

This is a constrained optimization with a clean answer, and the tool is the
arithmetic–geometric mean inequality. For any allocation obeying the budget, the average
of the terms $c_i 2^{-b_i}$ is at least their geometric mean, and the geometric mean
factorizes beautifully because $\prod_i 2^{-b_i} = 2^{-B}$ is *fixed* by the budget. One
line of algebra later:

> **Bit-Budget Lower Bound.** Every allocation of a total budget $B$ across $n$ blocks
> satisfies
> $$\mathrm{cost}(b) \;\ge\; n \left(\prod_i c_i\right)^{1/n} 2^{-B/n}.$$
> The obstruction is the *geometric mean* of the sensitivities, and the budget enters
> only through the universal factor $2^{-B/n}$: one extra bit per block halves the
> achievable error, no matter how the sensitivities are arranged.

And the bound is attained — by an explicit, almost folkloric allocation:
$$b^\star_i \;=\; \frac{B}{n} \;+\; \log_2 c_i \;-\; \frac{1}{n}\sum_j \log_2 c_j .$$
Give every block an equal share of the budget, then add a correction equal to how far its
log-sensitivity sits above the average. Signal processing calls this shape *reverse
water-filling*. A direct computation shows two things: the allocation spends exactly the
budget, and every one of its terms $c_i 2^{-b^\star_i}$ collapses to the same value —
which is precisely the equality case of AM–GM.

> **Optimality.** The water-filling allocation $b^\star$ spends exactly $B$ bits and
> achieves $\mathrm{cost}(b^\star) = n(\prod_i c_i)^{1/n} 2^{-B/n}$; therefore no
> allocation of the same budget does better.

The consequence I find most striking is what happens when you subtract two entries:
$$b^\star_i - b^\star_j = \log_2 c_i - \log_2 c_j = \log_2 \frac{c_i}{c_j}.$$
Everything cancels — the budget, the number of blocks, the other layers. **The optimal
bit gap between two blocks is the logarithm of their sensitivity ratio, and nothing
else.** A block that is $4\times$ more fragile deserves exactly two more bits. A block
that is $1000\times$ more fragile deserves ten. Precision is the logarithm of
robustness.

Put this together with the Tail-Dominance Theorem and the tail-aware prescription stops
being a heuristic. If sensitivity increases with depth, then so does $b^\star$: *the
optimal allocation gives the tail the most bits*, derived rather than measured.

You can even read off the slope. Suppose every layer contracts by the same factor
$\lambda < 1$, so $s(k) = \lambda^{\,n-1-k}$. Then the gap between layer $i$ and a
deeper layer $j$ is
$$b^\star_j - b^\star_i = (j - i)\,\log_2\!\frac{1}{\lambda},$$
a straight line in depth. For a 24-layer stack with $\lambda = 0.9$, the last layer
deserves $23 \log_2(1/0.9) \approx 3.5$ more bits than the first. Four-bit body,
seven-or-eight-bit tail. That is not far from what practitioners have arrived at by
trial and error.

Hardware, of course, only implements integer bit widths. Rounding $b^\star$ down keeps
you inside the budget, and since each bit you drop can at most double a term, the
rounded allocation costs at most twice the ideal. A factor of two in a certified bound
is a cheap price for deployability.

## The tail is one thing, not two things

There is a second, quite different reason the last two layers travel together, and it
comes from thinking about *which prompts break* rather than about how big the error is.

Retained accuracy is an agreement rate, so behind it is a set: for each collection $S$
of quantized layers, let $D(S)$ be the set of evaluation prompts on which the model with
$S$ compressed disagrees with the original. Damage is $|D(S)|$. Two structural
properties are natural:

* **Monotonicity**: compressing more layers breaks more prompts, $A \subseteq B
  \Rightarrow D(A) \subseteq D(B)$.
* **Coverage**: every prompt broken by a joint compression was already broken by one of
  the parts, $D(A \cup B) \subseteq D(A) \cup D(B)$.

Monotonicity is uncontroversial. Coverage is the interesting one, because it is exactly
the assumption that damage does not *interact*. Under both, damage is subadditive, and
you immediately get a sanity constraint on every protection scheme:

> **Protection Sandwich.** For any compressed set $U$ and any protected subset $T$,
> $$0 \;\le\; \text{gain}(T) \;=\; |D(U)| - |D(U \setminus T)| \;\le\; |D(T)|.$$
> Protecting layers never hurts, and it never buys back more than those layers destroy
> when they are the only thing compressed. Summing over $T$ gives a budget bound: the
> gain from protecting a set is at most the sum of its members' individual damages.

Check it against the measurement. The tail pair, compressed alone, costs $0.0234$. That
is the ceiling. The measured gain from protecting it is $0.0180$. Inside the sandwich —
and in fact it realizes exactly $\tfrac{10}{13} \approx 76.9\%$ of the theoretical
maximum. Tail protection is not merely positive, it is nearly saturating.

There is a converse with teeth. Suppose a measurement is *super-additive*: the joint
damage exceeds the sum of the parts. Then coverage must fail, and the proof tells you
what fails — there exist prompts in $D(A \cup B)$ that lie in neither $D(A)$ nor $D(B)$.
Call these **emergent** failures: outputs broken only because *both* perturbations were
applied. And you can count them.

> **Emergent Fraction.** If the joint damage is $r$ times the sum of the separate
> damages, then at least a fraction $\frac{r-1}{r}$ of all joint failures are emergent.

A companion experiment on the same tail pair found joint pruning to be $7\times$
super-additive. Plug in $r = 7$: **at least six sevenths of the failures caused by
disturbing both tail layers are caused by neither of them alone.** They exist only in the
interaction. No procedure that scores layers one at a time can ever see them.

Which brings us to the prescription. Define the interaction of two layers under
protection as
$$I(a,b) = E(U \setminus \{a\}) + E(U \setminus \{b\}) - E(U) - E(U \setminus \{a,b\}),$$
where $E$ is the damage functional. An exact algebraic identity — no hypotheses at all —
splits the joint gain into the two individual gains plus this interaction:
$$\text{gain}(\{a,b\}) = \text{gain}(\{a\}) + \text{gain}(\{b\}) + I(a,b).$$
And a *submodular* damage functional — one where overlapping perturbations interact
sub-additively — makes $I \ge 0$ automatically.

> **Tail-as-One-Unit Theorem.** If damage is submodular, protecting a pair of layers
> jointly recovers at least as much quality as the sum of protecting each separately;
> strictly more whenever the interaction is strictly positive.

The final piece closes the loop: the agreement-based damage $|D(S)|$ arising from any
monotone covering family *is* submodular. Submodularity is not a convenient assumption
imported from optimization theory. It is forced by the fact that retained accuracy
counts prompts.

Even the headline experiment, which is comfortably coverage-consistent — its slack is a
mere $0.0054$ — has a strictly positive block-level interaction of exactly that
$0.0054$. Joint protection strictly beats the sum of the separate protections. Two
layers, one unit.

## What survived contact with the data

Honesty demands recording where the theory and the measurement pull apart. Coverage and
super-additive interaction are mathematically *incompatible*: a single super-additive
measurement disproves coverage everywhere. The headline experiment is subadditive; the
pruning experiment on the same layer pair is $7\times$ super-additive. Both cannot be
covering. The honest reading is that they probe different regimes — quantization noise
is gentler and more nearly independent than outright deletion — and the theory supplies
the invariant that measures the gap: the cardinality of the emergent set, which is zero
in one regime and dominant in the other.

Three lines of evidence, then, converge on one operational rule. The last two layers are
the most sensitive place to inject noise, because nothing downstream damps it. They
should receive $\log_2$ of their sensitivity ratio in extra bits, because that is the
exact optimum of a hard constraint. And they should be protected together rather than
separately, because the damage they cause interacts and the interaction is provably
non-negative.

Compression, it turns out, should not be democratic. It should be logarithmic.
