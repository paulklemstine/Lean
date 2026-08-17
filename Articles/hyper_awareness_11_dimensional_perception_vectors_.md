# Eleven Dimensions, Twenty-Two Neurons: The Exact Price of Seeing Without Loss

## A machine that must not forget

Imagine building a perceptual system for a machine that senses the world in eleven
independent channels at once. Not three colours, not the two coordinates of a camera plane —
eleven. Perhaps it fuses lidar returns, temperature, pressure, three components of velocity,
three of angular rate, and a couple of chemical concentrations. Whatever the channels are,
one moment of experience is a single point $x \in \mathbb{R}^{11}$: an *eleven-dimensional
percept*.

The first thing almost every artificial neural network does with such a percept is push it
through a layer of rectified linear units. Each unit $i$ carries a weight vector
$w_i \in \mathbb{R}^{11}$ and a bias $b_i \in \mathbb{R}$, and it reports

$$\Phi(x)_i \;=\; \mathrm{relu}\big(\langle w_i, x\rangle + b_i\big), \qquad
\mathrm{relu}(t) = \max(t,0).$$

That $\max(t,0)$ is the whole story of this article. It is a diode. A ReLU unit fires in
proportion to how strongly the percept points along $w_i$, and it says exactly nothing when
the percept points the other way. Everything on the wrong side of the hyperplane
$\langle w_i, x\rangle + b_i = 0$ is crushed to the same output: zero.

So here is the design question, posed sharply. **How many rectified units must the first
layer have if the eleven-dimensional percept is to survive it intact — that is, if no two
distinct percepts may ever produce the same layer output?**

Practitioners answer this by folklore ("make it wide, a few hundred, you'll be fine") or by
a naive dimension count ("eleven numbers in, so eleven units out ought to do"). The naive
count is wrong, and the folklore is wasteful. The true answer is a clean, sharp integer:

> **Twenty-two.** A rectified layer on $\mathbb{R}^{11}$ is lossless if and only if it has at
> least $22$ units, and $22$ units genuinely suffice.

More generally, on $\mathbb{R}^n$ the threshold is exactly $2n$. The factor of two is not
slack, not a safety margin, not an empirical rule of thumb. It is a theorem, and this article
explains where it comes from, how tight the situation at the optimum turns out to be, and
what happens when you try to escape the cost through depth, through symmetry, or through
higher-order tensor percepts.

## Why eleven units cannot possibly be enough

Start with the intuition, which is almost embarrassingly simple once you see it. A single
ReLU unit is a half-space detector. Its output tells you something about $x$ only when $x$
lies on the firing side of its hyperplane; on the other side the unit is dark, and the
darkness of a unit is the same darkness no matter *how far* on the wrong side you are.

Now pick a generic straight line through percept space and walk far out along it in one
direction. Some units light up; the rest go dark and stay dark. Walk far out in the *opposite*
direction and exactly the complementary set lights up. The two lit sets are disjoint, because
a unit whose linear response to the direction is positive cannot also be positive when you
reverse the direction — provided you have gone far enough out that the biases no longer
matter.

Here is the crux: **at each of those two far-away vantage points, the units that are lit must
be able to determine the percept all on their own.** Why? Suppose the lit units at some
generic point $x$ spanned only a proper subspace of the directions — that is, suppose some
nonzero vector $v$ satisfied $\langle w_i, v \rangle = 0$ for every lit unit $i$. Then nudge
the percept from $x$ to $x + tv$ with $t$ small. Every lit unit is unaffected, since $v$ is
invisible to it. Every dark unit is still dark, because being dark is a strict inequality and
small nudges cannot break it. The layer's output is bit-for-bit identical at $x$ and at
$x + tv$. Two different percepts, one response: the layer has forgotten something.

So losslessness forces the lit weight vectors at every generic point to span all of
$\mathbb{R}^{11}$, which requires at least $11$ of them. Do this at both ends of the line and
you get two disjoint families of at least $11$ units each. Twenty-two units, minimum. In
$\mathbb{R}^n$: $2n$.

Two technical points make this argument airtight rather than merely persuasive. First, one
must know that a "generic" direction exists at all — a direction $u$ with
$\langle w_i, u\rangle \ne 0$ for every unit whose weight vector is nonzero. It does, and the
reason is pure algebra: attach to each nonzero weight row $w_i$ the one-variable polynomial
$\sum_j w_{ij} X^j$, which is not the zero polynomial; multiply these polynomials together;
pick any real number $t$ that is not a root of the product (there are only finitely many
roots); then $u = (1, t, t^2, \dots, t^{10})$ is transverse to every row at once. Second, one
must go far enough along $\pm u$ that the linear term dominates every bias; scaling by
$s > \max_i |b_i| / |\langle w_i, u\rangle|$ does it.

## Twenty-two really is enough

The lower bound would be a hollow victory if no $22$-unit layer worked. One does, and it is
the most natural construction imaginable: the **positive/negative split**. Give yourself two
units per input channel. Channel $j$'s positive unit computes $\mathrm{relu}(x_j)$ and its
negative unit computes $\mathrm{relu}(-x_j)$. No biases at all.

Reconstruction is a subtraction:

$$\mathrm{relu}(t) - \mathrm{relu}(-t) = t \quad \text{for every real } t,$$

so $x_j$ is recovered exactly as (positive unit) minus (negative unit). The percept is not
merely recoverable in principle; it is recoverable by a *linear* map, the cheapest kind of
decoder there is. The split layer is a perfect encoder of an eleven-dimensional percept into
twenty-two nonnegative numbers.

Combining the two halves: $22$ is the least width of a lossless rectified perception layer
on $\mathbb{R}^{11}$. Not "about $22$", not "$22$ in the generic case". Exactly $22$, always.

And the failure one step below is concrete rather than abstract. Take all eleven positive
detectors but only ten negative ones, omitting the negative detector of the eleventh channel
— a $21$-unit layer. Then the two percepts
$x_A = (0,\dots,0,-1)$ and $x_B = (0,\dots,0,-2)$ produce *identical* outputs: every unit is
dark on the eleventh channel's negative side, and no other channel is excited. The layer
cannot tell a mild negative reading from a reading twice as strong. One missing neuron, one
blind direction.

## Losslessness is not enough: the stability of the optimum

Injectivity is a set-theoretic virtue. It promises that distinct percepts have distinct
responses, but it does not promise that *nearby-in-response* implies *nearby-in-percept*. A
map can be injective and still crush a direction almost flat, so that decoding it amplifies
noise catastrophically. Engineers care about the second property, not the first.

The split layer passes this stronger test with a sharp constant. Writing $\Phi$ for the
$22$-unit split map, for all percepts $x, y$:

$$\tfrac{1}{2}\,\|x-y\|^2 \;\le\; \|\Phi(x)-\Phi(y)\|^2 \;\le\; \|x-y\|^2 .$$

The upper bound says the layer never magnifies a difference: it is $1$-Lipschitz, so input
noise is never amplified. (This is a general feature of rectification — $\mathrm{relu}$ is
$1$-Lipschitz, so *every* rectified layer contracts relative to its own linear part.) The
lower bound says the layer never squashes a difference by more than a factor $2$ in energy.
Together they say $\Phi$ is a **frame** with bounds $1/2$ and $1$, and hence a decoder exists
whose worst-case noise amplification — the condition number — is exactly $\sqrt{2}$.

The one-coordinate identity behind the lower bound is worth seeing. For real $a,b$,

$$\big(\mathrm{relu}(a)-\mathrm{relu}(b)\big) - \big(\mathrm{relu}(-a)-\mathrm{relu}(-b)\big)
= a-b,$$

and since $(u-v)^2 \le 2(u^2+v^2)$, we get
$(a-b)^2 \le 2\big[(\mathrm{relu}(a)-\mathrm{relu}(b))^2 + (\mathrm{relu}(-a)-\mathrm{relu}(-b))^2\big]$,
which is the coordinatewise form of the lower bound. The upper bound holds coordinatewise
too, because when $a$ and $b$ straddle zero the two rectified channels move in opposite
directions and their squared displacements add up to no more than $(a-b)^2$.

Both constants are attained, so neither can be improved. Compare a percept with the origin:
say $x = e_0$ and $y = 0$. Then $\|\Phi(x)-\Phi(y)\|^2 = 1 = \|x-y\|^2$; the upper constant
$1$ is exact. Now compare *antipodal* percepts $x = e_0$ and $y = -e_0$. The input distance
squared is $4$, but only one unit changes on each side, so the output distance squared is
$2$ — precisely half. **The worst case for a rectified layer is a sign flip**, and the loss
there is exactly a factor of two, no more and no less.

## The optimum has no slack anywhere

The story so far is about counting. The most striking results concern what an architecture
that *sits at* the threshold is forced to look like — and it turns out that operating at the
information-theoretic optimum leaves the designer no freedom at all.

**Balanced activation.** Suppose a rectified layer on $\mathbb{R}^n$ is lossless and has
exactly $2n$ units. Then there exist two percepts $x$ and $y$ whose sets of active units are
*disjoint*, each of size *exactly* $n$, and whose union is *all* $2n$ units. The layer
partitions itself, at a suitable antipodal pair of probes, into two perfectly balanced halves.
In the mission's dimension: a $22$-unit lossless eleven-dimensional perception layer splits
into two blocks of exactly $11$ active units.

The proof is a squeeze. We already know each of the two probes activates *at least* $n$ units
and that the two active sets are disjoint; if either set had $n+1$ or more members, the two
together would need more than $2n$ units, which the layer does not have. So both counts are
pinned to exactly $n$ and their union is everything. Nothing was assumed about the weights,
yet the layer is compelled to behave like the canonical positive/negative split — half the
units carry a "positive half" of the percept and half carry a "negative half".

**No dead units, no redundancy.** An immediate corollary: in a width-optimal lossless layer,
*every single unit* has a nonzero weight row. There are no constant detectors, no units that
merely echo their bias, nothing that could be deleted or pruned. Every unit appears in one of
the two blocks, and membership in a block requires genuine input dependence. Prune one neuron
from a $22$-unit lossless eleven-dimensional layer and losslessness is gone, because $21 < 22$.

For the canonical split layer this abstract balance is visible concretely: at any percept with
all coordinates strictly positive, the active units are exactly the eleven "positive half"
units, and the eleven negative units are all dark. Flip the percept and the roles reverse.

## Depth cannot rescue a narrow input layer

A natural hope: maybe a first layer with $11$ or $15$ units is acceptable if the network is
deep enough, with clever wide layers downstream reconstructing what was lost. It is not, and
the reason is a one-line observation with an uncomfortable moral.

**If the first hidden layer of a network on $\mathbb{R}^{11}$ has fewer than $22$ rectified
units, then the entire network — however deep, however wide its later layers, whatever
nonlinearity or attention or normalisation it uses — identifies two distinct percepts.**

The proof: if the composite $g \circ \Phi$ were injective, then $\Phi$ itself would have to be
injective (if $\Phi(x) = \Phi(y)$ then certainly $g(\Phi(x)) = g(\Phi(y))$, forcing $x=y$).
But a sub-$22$-unit $\Phi$ is not injective. Information destroyed at the input interface is
gone forever; no downstream computation can invent it. The **input interface is the only place
in the architecture where width is non-negotiable**.

Conversely, width at the interface costs nothing in depth. Stack an optimal split layer
$\mathbb{R}^n \to \mathbb{R}^{2n}$ on top of another optimal split layer
$\mathbb{R}^{2n} \to \mathbb{R}^{4n}$, and the composite remains lossless — as does any tower
of such layers, to any depth. Twenty-two units at the input are necessary, sufficient, and
perfectly compatible with arbitrarily deep processing.

## Higher-order percepts: the price of a matrix of sensations

Real perception is often not a vector but a tensor: an order-$2$ percept is an $11 \times 11$
array (say, pairwise channel correlations); an order-$3$ percept is an $11\times11\times11$
array. An order-$k$ eleven-dimensional percept lives in a space of dimension $11^k$.

The width law applies verbatim, because it was proved for arbitrary $n$: a lossless rectified
layer on order-$k$ eleven-dimensional tensor percepts requires at least $2 \cdot 11^k$ units,
and $2 \cdot 11^k$ units always suffice, via the coordinatewise positive/negative split.

$$k=1:\; 22 \qquad k=2:\; 242 \qquad k=3:\; 2662 .$$

The cost of lossless "hyper-aware" tensor processing is exactly twice the tensor dimension —
which is both reassuring (the constant is $2$, not something exponentially worse) and sobering
(the dimension itself grows as $11^k$).

## Two warnings about symmetry, and one gift from oddness

A modern instinct when facing an eleven-channel percept is to impose symmetry: if the eleven
channels are interchangeable, why not require the layer to be equivariant under permuting
them? And if positive and negative readings are interchangeable, why not require equivariance
under flipping signs too? Symmetry reduces parameters, and fewer parameters means better
generalisation. What does symmetry cost here?

**Permutation equivariance.** A linear layer $x \mapsto Mx$ on $\mathbb{R}^n$ ($n \ge 2$)
commutes with all permutations of the axes if and only if its matrix has one value $a$ on the
diagonal and a single other value $b$ everywhere off it — equivalently, if and only if it acts
as
$$x \;\longmapsto\; (a-b)\,x + b\Big(\textstyle\sum_j x_j\Big)\mathbf{1}.$$
That is the classical *Deep Sets* form: **two** learnable parameters, no matter that the
percept has eleven dimensions. And the two parameters are unique — there is exactly one pair
$(a,b)$ realising a given equivariant layer.

**Adding sign equivariance is fatal.** If in addition the layer commutes with all coordinate
sign flips, then every off-diagonal weight must vanish. The argument is one probe: feed the
layer the basis vector $e_j$, and compare with feeding it $e_j$ after flipping the sign of
channel $j$. Equivariance forces $M_{ij} = -M_{ij}$ for $i \ne j$. Combining, a layer
equivariant for the full hyperoctahedral group — all permutations *and* all reflections of the
eleven axes — is a scalar multiple of the identity: **one** parameter, a global gain control.
Such a layer performs no cross-channel computation whatsoever. It cannot even swap two
channels: a scalar map sends $e_1$ to $a\,e_1$, whose first coordinate is $0$, while a channel
swap must return $1$ there.

The moral is a genuine design constraint, not a curiosity. Impose the full hypercube symmetry
on an eleven-dimensional perception layer and you have destroyed every genuinely
eleven-dimensional computation it could have performed. If the eleven channels really are
interchangeable and sign-symmetric, the *linear* part of your architecture must be trivial —
all the interesting processing must live in the nonlinearity, or in a deliberately broken
symmetry.

**And a gift.** Eleven is odd, and oddness pays a dividend that even dimensions do not enjoy.
Every real $11 \times 11$ matrix has a real eigenvalue, because its characteristic polynomial
has odd degree $11$, hence real coefficients and an odd-degree monic shape, so it must cross
zero. Consequently:

> Every linear perception layer on $\mathbb{R}^{11}$ — with no hypothesis whatsoever on its
> weights — has a nonzero **invariant percept direction**: a percept $v \ne 0$ and a gain
> $a$ with $Mv = a v$. If the layer is injective, the gain is nonzero.

There is always a mode of experience that the layer merely rescales rather than rotates: a
stable perceptual axis, guaranteed by parity. And parity really is the reason. In dimension
$2$ the quarter-turn layer $M = \begin{pmatrix} 0 & -1 \\ 1 & 0\end{pmatrix}$ has no invariant
direction at all — it rotates every percept by ninety degrees. Even-dimensional perception
systems can be entirely mode-free; odd-dimensional ones cannot.

## What it all adds up to

Take the eleven-dimensional design question seriously and it answers itself with unusual
precision:

- **Width at the sensory interface: exactly $22$.** Fewer is provably lossy; $22$ suffices,
  with a linear decoder.
- **Stability: condition number exactly $\sqrt{2}$.** Antipodal percepts are the worst case,
  and they lose exactly a factor of two in energy.
- **Rigidity: no slack at the optimum.** The $22$ units split into two balanced blocks of
  $11$; every unit is essential; pruning is impossible.
- **Depth: no rescue.** A narrow first layer poisons a network of any depth. Width at the
  interface is compatible with unlimited depth.
- **Tensors: exactly twice the dimension.** $22$, $242$, $2662$ for orders $1$, $2$, $3$.
- **Symmetry: expensive.** Permutation equivariance leaves two parameters; adding reflections
  leaves one, and kills cross-channel processing outright.
- **Parity: a free stable axis.** Odd dimension guarantees an invariant percept direction;
  even dimension does not.

None of this depends on training data, optimisation, or architecture search. It is a statement
about what a diode can and cannot transmit, sharpened until the answer is an integer. The
number is $22$, and the reason is that a rectifier sees only half of the world at a time — so
to see all of an eleven-dimensional world, you need two complete looks.
