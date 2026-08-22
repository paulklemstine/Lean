# The Four-Bit Mirage

## Why "how many bits?" is the wrong question — and what the right one looks like

There is a number that circulates in the folklore of machine learning the way a
lucky charm circulates in a card room: **four bits**. Squeeze the weights of a
neural network down to four bits apiece — sixteen possible values per number,
down from the roughly four billion a 32-bit float can express — and, the folklore
says, the model barely notices. Four bits is where the free lunch ends. Four bits
is the floor.

The folklore is not baseless. On small networks trained from scratch for a
benchmark, four-bit rounding really does cost almost nothing. The trouble starts
when you take that number to a real, pretrained language model. We rounded every
linear weight of a half-billion-parameter model onto a four-bit grid, per output
channel, in the most straightforward way possible — pick the largest magnitude in
the channel, lay down sixteen evenly spaced levels between $-A$ and $+A$, snap
every weight to the nearest one. The model's cross-entropy loss rose by $0.79$
nats. The budget the folklore had allocated was $0.05$. We had missed by a factor
of sixteen.

This article is about what went wrong, and about the small piece of arithmetic
that explains it — arithmetic that turns out to have nothing to do with neural
networks at all, and a surprising amount to do with rounding, sawtooth waves, and
a classical theorem about triangle-free graphs.

---

## The cliff

First, the measurements. Here is what happened as we lowered the bit budget on the
same model, the same data, the same evaluation, changing nothing but the width of
the grid:

| bits per weight | increase in cross-entropy | fraction of accuracy retained |
|---|---|---|
| 8 | $+0.0044$ | $0.9985$ |
| 6 | $+0.0353$ | $0.9904$ |
| 5 | $+0.1281$ | $0.9620$ |
| **4** | **$+0.7879$** | **$0.7630$** |
| 3 | $+9.2262$ | $0.0367$ |
| 2 | $+14.0588$ | $0.0001$ |

Read it from the top and it looks gentle: eight bits is essentially free, six is
cheap, five is a rounding error in the everyday sense. Then four bits costs
sixteen times its predicted budget, three bits destroys the model, and two bits
produces something that has forgotten how to speak. The damage is not a smooth
ramp with a knee; it is a cliff, and the four-bit configuration is standing on the
lip of it.

Two further experiments sharpen the picture. Quantizing only the *first* half of
the network's layers cost $+0.3885$; quantizing only the *last* half cost
$+0.4054$. Deeper layers are worse, but only slightly — the effect is real and
small. And the single most effective repair had nothing to do with bit count:
instead of one shared scale per output channel, we used one scale per **group of
128 consecutive weights**. That change, at the same four bits, cut the damage from
$+0.7879$ to $+0.3180$ — it repaired about 60% of it. At three bits, grouping was
the difference between a broken model ($+9.23$) and a damaged but functioning one
($+2.72$).

So the practical picture is clear enough. But *why* does a four-bit floor
calibrated on toy models fail so badly on a real one? The answer is not that four
bits is subtler than we thought. The answer is that "four bits costs at most
$c$" is not the kind of statement that can be true.

---

## A floor with nothing under it

Here is the whole of the argument, and it fits in a paragraph.

When you quantize a tensor to $b$ bits by the absmax rule, you first find the
largest magnitude $A$ in the tensor, then lay a grid of spacing
$$\Delta = \frac{A}{2^{b}}$$
across the interval $[-A, A]$, and round each weight to the nearest grid point.
Rounding to the nearest point of a grid of spacing $\Delta$ moves a number by at
most half a spacing:
$$|\mathrm{round}_\Delta(x) - x| \le \frac{\Delta}{2},$$
and this is exactly attained — a weight sitting at the midpoint of a cell moves the
full $\Delta/2$. No constant smaller than $1/2$ will do: if $|\mathrm{round}_\Delta(x) - x| \le c\,\Delta$
holds for every $x$, then $c \ge 1/2$, because the midpoint says so.

Now notice what $\Delta$ contains. It contains $b$, yes — one extra bit exactly
halves it, $\Delta(b+1) = \Delta(b)/2$, so the mesh is strictly decreasing in the bit
budget and never reaches zero. But it also contains $A$. And $A$ is a property of
the *weights*, not of the encoding. Fix any bit budget $b$ you like and any damage
budget $c$ you like. Set the amplitude to
$$A = (|c| + 1)\cdot 2^{\,b+1},$$
put a single weight at the midpoint of a cell, and measure the damage with the
gentlest possible loss function — one whose output changes by no more than the
total change in its inputs. The damage is $\Delta/2 = |c| + 1 > c$.

That is the whole theorem, and it says something uncomfortable: **for every bit
budget and every damage budget, there is a tensor on which that bit budget exceeds
that damage budget.** A quantization floor stated in bits alone is not a
conservative claim, or a claim that needs more careful measurement. It is empty.
Whatever number the toy experiments measured, they were measuring a property of
the amplitudes and widths of *their own* weight tensors, and then reporting it as
if it were a property of the number four.

Pretrained transformers have outliers — a few weights per channel that are
enormously larger than their neighbours. Those outliers set $A$. Everyone else has
to live on the grid the outliers chose. This is why the sensible fix is not more
bits but *narrower scopes*: give each block of 128 weights its own amplitude, and
the outlier only poisons its own block.

That intuition, too, is a theorem with an exact constant. If a tensor is cut into
$n$ groups with amplitudes $A_1, \dots, A_n$, all at most the global amplitude $A$,
then the guaranteed damage improves from $nA/2^{b+1}$ to $\sum_i A_i/2^{b+1}$, and the
amount repaired is
$$\frac{1}{2}\sum_{i=1}^{n}\bigl(\Delta - \Delta_i\bigr),$$
exactly half the total amplitude deficit of the groups. Put another way: the
ungrouped bound is governed by the **maximum** amplitude, the grouped bound by the
**mean**. Grouping never hurts, and it strictly helps the moment a single group is
less extreme than the whole. The measured 60% repair at group-128 is precisely the
gap between a mean and a max on a real checkpoint.

---

## The sawtooth and the triangle

There is a second story hiding in the arithmetic, and it is prettier.

Rounding has a signature waveform. Define the *sawtooth*
$$s(x) = \mathrm{round}(x) - x,$$
the signed error you commit by rounding $x$. It repeats with period $1$, it never
exceeds $1/2$ in magnitude, and it hits exactly $1/2$ at $x = 1/2$, where the tie
is broken upwards.

Now take a full period of a grid with $q$ levels — the numbers $0/q, 1/q, \dots, (q-1)/q$ —
and add up the signed errors. Some round down, some round up; do they cancel? The
answer is an exact, slightly startling formula:
$$\sum_{j=0}^{q-1} s\!\left(\frac{j}{q}\right) = \left\lfloor \frac{q}{2}\right\rfloor - \frac{q-1}{2}
= \begin{cases} 0 & q \text{ odd},\\[2pt] \tfrac12 & q \text{ even}.\end{cases}$$

For an odd number of levels, the errors cancel perfectly. For an even number, they
leave behind exactly half a grid step — no more, no less, no matter how fine the
grid. And every grid a computer actually uses has $2^b$ levels. **Hardware grids
are always biased**, by exactly half a step per period, at every bit budget. The
individual errors shrink like $1/q$ as you add bits; the accumulated drift does
not shrink at all. It is a systematic tilt, not noise, and it is why error
*compensation* — feeding the signed residual of one weight into the rounding
decision for the next — is a different lever from choosing a better scale.

There is a rigidity result underneath. Replace the grid $j/q$ by an arithmetic
progression $kp/q$ with $p$ coprime to $q$ — a "scrambled" grid. Multiplication by
a unit permutes the residues, so the sum is unchanged: **the period bias is
invariant under any coprime multiplier.** The first moment of the rounding error
cannot be improved by any relabelling. Whatever a smarter quantizer buys, it must
buy at second order.

And the absolute error? Here the arithmetic wanders into extremal graph theory.
Summing $|s(j/q)|$ over a period amounts to summing, over each $j$, the distance to
the nearer endpoint of its cell, which in integer terms is $\min(j, q-j)$. That sum
has a closed form:
$$\sum_{j=0}^{q-1} \min(j, q-j) = \left\lfloor \frac{q^2}{4} \right\rfloor.$$

The right-hand side is not just a formula; it is a famous number. $\lfloor q^2/4 \rfloor$
is the **Mantel–Turán number**: the maximum number of edges a graph on $q$ vertices
can have without containing a triangle, achieved by the balanced complete bipartite
graph. The total absolute rounding energy of a $q$-level grid, measured in grid
units, is exactly the extremal size of a triangle-free graph on $q$ vertices. The
same "split into two halves as evenly as possible" optimization drives both.

Dividing by $q$ gives the honest accounting:
$$\frac{q}{4} - \frac{1}{4q} \;\le\; \sum_{j=0}^{q-1}\left|s\!\left(\frac{j}{q}\right)\right| \;\le\; \frac{q}{4},$$
so the *mean* absolute error per weight is a quarter of a grid step, always. Signed
error is $\Theta(1/q)$ in total and cancels almost perfectly; absolute error is
$\Theta(1)$ per weight and never cancels at all. The gap between those two
statements is the entire operating budget of a quantization algorithm.

---

## Depth, and why deeper is worse (but not because it is deeper)

The measurement showed that quantizing the back half of a network hurts slightly
more than the front half. It is tempting to read this as a law of depth. It is not.

Model a chain of $n$ layers as a product $w_1 w_2 \cdots w_n$. If each factor has
magnitude at most $M$ and is perturbed by at most $\delta$, then the product moves
by at most
$$(M + \delta)^n - M^n,$$
and this is attained, when every weight sits at $M$ and every error at $+\delta$.
For $M \ge 1$ this grows without bound in $n$: for any damage budget $c$, some depth
exceeds it. There is no depth-uniform floor either.

But the informative statement is the exact one. Perturb only layer $k$, by $t$. The
product changes by exactly
$$t \prod_{i \neq k} w_i.$$
A layer's sensitivity is the product of *everyone else's* weights. So if layer $a$
has a smaller weight than layer $b$, then $a$'s complementary product is *larger*,
and $a$ is the more sensitive layer. Sensitivity is **antitone** in a layer's own
magnitude: small-weight layers are fragile, large-weight layers are robust.

A measured depth gradient is therefore a measurement of the depth profile of weight
magnitudes in that particular checkpoint — not a fact about depth. Which is exactly
the same lesson as the four-bit floor, arriving from a different direction: the
quantity that governs the damage is an amplitude, and amplitudes are properties of
the model you have, not of the scheme you chose.

---

## Where to spend the bits

If amplitudes are what matter, then a fixed total bit budget should not be spread
uniformly. Suppose you have $n$ tensors with amplitudes $A_1, \dots, A_n$ and $B$
bits to distribute, and the worst-case damage of tensor $i$ at $b_i$ bits is
proportional to $A_i 2^{-b_i}$. Minimizing the total,
$$\sum_{i=1}^n A_i 2^{-b_i} \quad \text{subject to} \quad \sum_i b_i = B,$$
is a one-line application of the arithmetic–geometric mean inequality. Every
allocation satisfies
$$\sum_i A_i 2^{-b_i} \;\ge\; n \left(\prod_i A_i\right)^{1/n} 2^{-B/n},$$
and equality holds for the **water-filling allocation**
$$b_i = \frac{B}{n} + \log_2 A_i - \frac{1}{n}\sum_j \log_2 A_j,$$
which spends exactly $B$ bits and gives each tensor a number of extra bits equal to
its log-amplitude excess over the average.

Two things worth noticing. First, the invariant that governs a memory budget is the
**geometric mean** of the amplitudes — not their maximum, not their sum. Second,
uniform precision is strictly suboptimal the instant amplitudes differ. Two tensors
with amplitudes $1$ and $4$ and a net budget of zero extra bits: uniform allocation
costs $1 + 4 = 5$; moving one bit from the small tensor to the large one costs
$2 + 2 = 4$. Twenty percent, for free, from an allocation decision that no bit-count
folklore would ever suggest.

---

## What to take away

The four-bit floor was never a floor. It was a measurement of the amplitudes of a
particular family of small networks, wearing the costume of a universal constant.
On a pretrained transformer, whose channels contain outliers that toy models do not
have, the costume comes off: the true cost is sixteen times the predicted one, and
no amount of more careful measurement would have saved the prediction, because the
prediction was of a form that cannot be true.

What survives is more useful than what fell. The damage of a rounding grid is
governed by an *amplitude divided by a power of two*, with an exactly sharp
constant of $1/2$. Narrowing the scope of that amplitude — grouping — repairs
exactly half the amplitude deficit you create, which is why every serious
quantizer in production is group-wise. Signed rounding error on a hardware grid
carries an irreducible half-step bias per period that no relabelling can remove,
which is why compensation, not scale selection, is the next lever. Absolute
rounding energy is a Turán number, a quarter step per weight, always. And a fixed
bit budget should be spread by log-amplitude, not evenly.

Practically, for the model we measured: below six bits, plain round-to-nearest is
not deployable; group-wise four-bit is the entry point; and anything beyond that
requires compensating for the error you make, not choosing a cleverer scale.

The number four was never doing any work. The amplitude was doing all of it.
