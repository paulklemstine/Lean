# The Quiet Power of Sparse Neural Codes

## How a few spikes can name a world

Every moment, the brain faces an extravagant communication problem. A retina must report a shifting field of light; a motor system must specify the position and force of many muscles; memory must distinguish one face, place, or episode from countless alternatives. Yet neurons do not transmit elegant paragraphs. In a simplified but useful picture, each neuron contributes a binary answer during a short time window: active or silent.

That austere alphabet creates a striking combinatorial universe. With $N$ binary neurons, an activity pattern is a string of $N$ zeros and ones. There are exactly

$$
2^N
$$

such strings, because each position offers two independent choices. This is the elementary capacity theorem for binary population codes: no code using one binary state per neuron can contain more than $2^N$ distinct patterns, and the full collection attains that limit. Equivalently, the population carries at most $N$ bits when every pattern is available.

The number is enormous. A population of $100$ neurons has $2^{100}$ possible patterns, far beyond the number of seconds in the age of the universe. But this abundance hides a biological bill. A pattern full of ones asks many cells to fire at once. Spikes consume energy, and neural tissue must continually restore ion gradients, recycle transmitter, and maintain the machinery that makes signaling possible. Capacity alone is therefore the wrong currency. The better question is: how much distinguishable information can a population buy with a limited number of spikes?

## Energy as Hamming weight

Represent a neural pattern by $c=(c_1,\ldots,c_N)$ with each $c_i\in\{0,1\}$. Its spike cost, or Hamming weight, is

$$
w(c)=\sum_{i=1}^{N}c_i.
$$

A pattern of weight $k$ uses exactly $k$ active neurons. A sparse code restricts attention to low-weight patterns. This simple constraint transforms the capacity calculation.

To count patterns with exactly $k$ spikes, choose which $k$ of the $N$ neurons are active. The answer is the binomial coefficient

$$
\binom{N}{k}.
$$

This is the Exact-Energy Capacity Theorem: the complete layer of patterns costing exactly $k$ spikes contains precisely $\binom{N}{k}$ codewords. The proof is a direct bijection. Each pattern corresponds to its set of active neuron indices, and each $k$-element subset of the population determines one pattern.

If the energy rule allows at most $k$ spikes rather than exactly $k$, all layers from zero through $k$ become available. The Budget Capacity Theorem states that the number of admissible patterns is

$$
B(N,k)=\sum_{j=0}^{k}\binom{N}{j}.
$$

The layers are disjoint because a pattern cannot have two different weights. For four neurons, the successive budgets contain $1$, $5$, and $11$ patterns: with no spikes there is only silence; with at most one spike there are silence and four one-hot patterns; with at most two spikes, six two-spike patterns join them.

These exact formulas expose the central tradeoff. The unrestricted code grows exponentially with $N$, while a fixed-spike layer grows only polynomially. Yet sparse coding can still be remarkably efficient.

## The polynomial ceiling

The key bound is

$$
\binom{N}{k}\le N^k.
$$

One way to see it is to count ordered lists. A $k$-element active set can be listed in at least one order, and every such list is among the $N^k$ ordered $k$-tuples drawn from $N$ neurons. Ordered tuples overcount subsets—often dramatically—but overcounting is exactly what an upper bound permits.

The Sparse Capacity Theorem follows immediately: every collection whose codewords all use exactly $k$ spikes has at most $N^k$ members. It need not contain every pattern at that weight. Since it is a subset of the full weight-$k$ layer, its size is bounded first by $\binom{N}{k}$ and then by $N^k$.

This result corrects a tempting slogan. Sparse coding does not literally create $O(N\log N)$ distinct concepts per unit energy. Rather, its *information*, measured in bits, is logarithmic per spike. If a codebook has $M$ equally distinguishable entries, its information capacity is

$$
I(M)=\log_2 M.
$$

For the full exact-$k$ layer, provided $N\ge2$ and $1\le k\le N$,

$$
\frac{\log_2\binom{N}{k}}{k}\le\log_2 N.
$$

The proof takes base-two logarithms of $\binom{N}{k}\le N^k$ and divides by the positive cost $k$. Thus the population offers at most $\log_2 N$ bits per spike under this model. The phrase “per unit energy” becomes precise: the numerator is information, not the raw number of concepts.

The upper bound is not merely an artifact of a loose estimate. One-hot coding attains it exactly. Set $k=1$. There are $\binom{N}{1}=N$ possible patterns, one for each choice of the active neuron, so

$$
\frac{\log_2 N}{1}=\log_2 N
$$

bits are carried per spike. One-hot coding sacrifices total capacity to achieve the maximum rate guaranteed by this general ceiling.

## What one percent means

Sparse activity is often described through a fraction of the population. Under a one-percent exact activity rule, set

$$
k=\left\lfloor\frac{N}{100}\right\rfloor.
$$

The number of patterns is exactly $\binom{N}{\lfloor N/100\rfloor}$ and obeys

$$
\binom{N}{\lfloor N/100\rfloor}
\le
N^{\lfloor N/100\rfloor}.
$$

For $N=1000$, exactly ten active neurons produce $\binom{1000}{10}$ possible patterns, approximately $2.63\times10^{23}$. The coarse ceiling $1000^{10}=10^{30}$ is much larger, but it makes the scaling transparent. The exact code carries about $77.8$ bits in ten spikes, or about $7.78$ bits per spike, below the ceiling $\log_2 1000\approx9.97$.

This distinction matters biologically. Sparsity can retain an astronomical repertoire while sharply reducing simultaneous activity, but there is no free lunch. Restricting energy removes most binary patterns. The design question is whether the remaining repertoire is large enough and sufficiently separated to resist noise.

## From codebooks to precision

Neural populations need not merely label discrete concepts. They also estimate continuous quantities: orientation, sound direction, limb angle, elapsed time. Suppose $N$ neurons provide independent, equally noisy measurements of a scalar signal, each with variance $\sigma^2$. The arithmetic mean has variance

$$
\operatorname{Var}(\bar X)=\frac{\sigma^2}{N},
$$

so its standard deviation is

$$
\frac{\sigma}{\sqrt N}.
$$

This is the familiar square-root law for population coding. If “precision” means inverse standard deviation, precision improves proportionally to $\sqrt N$. Quadrupling the population halves the typical estimation scale; obtaining ten times finer precision requires roughly one hundred times as many independent neurons. The law is powerful but conditional: correlations, unequal noise, nonlinear responses, and suboptimal decoding can change the effective gain.

Discrete sparse capacity and continuous population precision illuminate different tasks. The first asks how many codewords fit under an energy constraint. The second asks how accurately repeated noisy signals can be combined. Both show why distributed representations are attractive: adding neurons can increase representational resources even when no single neuron becomes more sophisticated.

## The geometry behind activity

Large populations create another puzzle. If a recording contains activity from thousands of neurons, does the brain’s state truly wander through a thousand-dimensional space? Often behavior has far fewer degrees of freedom. A reaching hand may be described by a modest collection of joint angles, velocities, and task variables.

A clean linear model captures the resulting dimension bound. Let behavioral state be $x\in\mathbb R^d$, and let neural activity be generated by

$$
y=Ax+b,
$$

where $A$ maps $d$ behavioral coordinates into $N$ neural coordinates. The set of possible activity vectors lies in the affine image $b+\operatorname{im}(A)$. Its dimension is the rank of $A$, and therefore

$$
\dim\bigl(b+\operatorname{im}(A)\bigr)=\operatorname{rank}(A)\le d.
$$

This is the Linear Neural Manifold Dimension Theorem: when neural states are generated from $d$ behavioral degrees of freedom by an affine map, their intrinsic affine dimension cannot exceed $d$, regardless of how large $N$ is. More recorded neurons provide a richer embedding and potentially better noise averaging, but they do not create new intrinsic coordinates in this model.

The nonlinear version is subtler. A curved image can bend through a high-dimensional neural space while remaining locally low-dimensional. Derivative rank, smoothness, and self-intersections then become central. The linear theorem should be read as a baseline, not as proof that biological activity is globally flat.

## A design triangle

Three quantities now frame the engineering of a neural code.

* **Capacity:** unrestricted binary populations offer $2^N$ patterns; exact-$k$ sparse populations offer $\binom{N}{k}$.
* **Energy:** Hamming weight counts simultaneous spikes, and fixed-$k$ information is bounded by $k\log_2N$ bits.
* **Geometry and precision:** averaging can improve scalar precision like $\sqrt N$, while a representation driven by $d$ linear behavioral coordinates remains at most $d$-dimensional.

No single theorem chooses the brain’s code. Real neural systems must also contend with timing, correlations, synaptic costs, noise, learning, and decoding speed. But these counting laws establish a disciplined starting point. They tell us what binary populations can represent, what sparse activity costs, and which claims need refinement.

The deepest lesson is not that silence limits the brain. It is that silence can be organized. A sparse pattern uses absence as part of its alphabet; the inactive majority helps identify the active minority. Combinatorics turns a handful of spikes into a vast address space, probability turns many noisy neurons into a more precise estimate, and geometry explains how a high-dimensional recording can express a low-dimensional act. The mathematics does not reduce thought to bits. It reveals how much structure can live between a spike and a silence.
