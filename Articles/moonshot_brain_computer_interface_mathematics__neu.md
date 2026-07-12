# The Arithmetic of Thought: How Many Ideas Can a Brain Hold?

Somewhere behind your eyes, roughly eighty-six billion neurons are
flickering on and off, and out of that shimmering static comes
*everything* — the memory of your first bicycle, the taste of coffee,
the face of someone you love. It is one of the oldest and strangest
questions in science: how does a lump of electrified tissue *represent*
the world? How does a pattern of firing cells become a thought?

For a long time this felt like a question only biology could answer.
But hidden underneath the wetware is something surprisingly clean and
countable — a mathematics of representation. If we are willing to
strip a neuron down to its barest cartoon, treating it as a switch that
is either *on* (firing) or *off* (silent), then the brain's coding
scheme becomes an object we can measure, bound, and prove theorems
about. This article is about those theorems. They are simple enough to
state on a napkin and deep enough to explain why your brain is wired the
way it is.

## A neuron is a bit, a thought is a pattern

Let us make the cartoon precise. Suppose we have $N$ neurons, and at any
instant each one is either active or silent. Then the state of the whole
population is a string of $N$ ones and zeros — a **neural code**. The
string $10110\ldots$ says "neuron 1 fires, neuron 2 is silent, neuron 3
fires," and so on. Every distinct thought, percept, or memory the brain
wants to represent must correspond to some such pattern.

Immediately a counting question presents itself. How many *different*
patterns are there? This is the first theorem, and it is the bedrock of
everything else.

> **Capacity Theorem.** A population of $N$ binary neurons can represent
> exactly $2^N$ distinct codes, and no more.

The proof is the proof every schoolchild rediscovers: the first neuron
has two choices, the second has two choices, and the choices multiply,
giving $2 \times 2 \times \cdots \times 2 = 2^N$. What makes it worth
stating formally is the little word *exactly*. There is no clever
encoding, no trick of biology or chemistry, that lets $N$ on/off units
distinguish more than $2^N$ situations. The number $2^N$ is not an
estimate; it is a ceiling welded to the sky.

And that ceiling rises with breathtaking speed. This is the second
result, the engine of the brain's power:

> **Doubling Law.** Adding a single neuron doubles the representational
> capacity: a population of $N+1$ neurons has capacity $2^{N+1} = 2
> \cdot 2^N$.

One extra cell doubles the number of representable ideas. Ten extra
cells multiply it by a thousand. Just **300** binary neurons — a
laughably tiny cluster by biological standards — can in principle label
more distinct states than there are atoms in the observable universe.
The brain's vault is not merely large; it is exponentially, absurdly
large. Storage is not the brain's problem. As we will see, its real
problem is *energy*.

## The price of a thought

Every spike costs metabolic fuel. A firing neuron burns glucose and
oxygen; the brain, though only about two percent of your body weight,
devours something like a fifth of your resting energy budget. So it is
not enough to ask *how many* thoughts a code can hold — we must ask how
*expensive* each pattern is, measuring cost by the number of neurons a
pattern switches on.

Here the naive scheme looks alarming. If the brain used its patterns
democratically — every one of the $2^N$ codes equally likely — how many
neurons would be lit up in a typical thought?

> **Dense Energy Law.** Averaged uniformly over all $2^N$ codes, the
> expected number of active neurons is exactly $N/2$.

The reasoning is elegant: by symmetry each individual neuron is active
in precisely half of all possible patterns, so on average half the
population — $N/2$ cells — is blazing away at any moment. For the human
brain that would mean tens of billions of neurons firing at once, a
metabolic catastrophe that would cook the skull. Real brains do nothing
of the sort. Recordings show that at any instant only a tiny
fraction — often around **one percent** — of neurons are active. The
brain has quietly refused the democratic code. Why? And what does it use
instead?

## Sparse coding: saying more with less

The answer is **sparse coding**: represent each concept with only a
*handful* of active neurons, keeping the vast majority silent. To study
it we count the patterns of a fixed weight.

> **Sparse Counting Theorem.** The number of neural codes on $N$ neurons
> that have exactly $k$ active cells is the binomial coefficient
> $$\binom{N}{k} = \frac{N!}{k!\,(N-k)!}.$$

This is the number of ways to choose *which* $k$ of the $N$ neurons
fire. And here the magic of combinatorics enters. Even a severe sparsity
budget leaves an enormous menu of patterns. With $N = 10{,}000$ neurons
and only $k = 100$ of them allowed to fire — a one-percent code — the
count $\binom{10000}{100}$ is a number with more than two hundred digits.
Sparsity barely dents capacity while slashing the energy bill.

The right way to see the win is to measure **information per spike**. A
population firing $k$ neurons can select among $\binom{N}{k}$ patterns,
carrying up to $\log_2 \binom{N}{k}$ bits of information at a cost of $k$
spikes. The efficiency is the ratio
$$\frac{\log_2 \binom{N}{k}}{k} \quad\text{bits per spike}.$$
Push sparsity to its extreme — the **one-hot code**, where a single
neuron fires ($k = 1$) — and each spike carries $\log_2 N$ bits.

> **Sparse Efficiency Theorem.** In the one-hot regime the information
> per spike grows like $\log_2 N$; sparse coding therefore enjoys a
> $\Theta(\log N)$ advantage in bits per spike over dense coding, whose
> efficiency stays bounded by a constant.

This is the theorem that explains the one-percent brain. A dense code
squanders energy: it fires $N/2$ neurons to carry $N$ bits, a fixed two
bits per spike no matter how large the brain grows. A sparse code gets
*better* with scale — the bigger the brain, the more each precious spike
is worth. Evolution, facing a metabolic ceiling, chose the code whose
efficiency rises without bound. Sparsity is not a bug or a limitation;
it is the optimal answer to the question "how do I think the most
thoughts on the least fuel?"

## Precision from the crowd

There is a puzzle lurking here. If only a few noisy, unreliable neurons
are firing, how does the brain represent smooth, *continuous*
quantities — the exact angle of your wrist, the precise pitch of a note,
the fine gradation of a color — with such accuracy? A single neuron is a
sloppy instrument, its firing rate jittering from moment to moment. The
resolution is **population coding**: let many neurons vote, and average
their opinions.

Suppose each of $N$ neurons offers an independent, noisy estimate of the
same underlying quantity, each with the same error variance $v$.
Averaging them yields a population estimate, and the mathematics of
averaging independent noise is exact.

> **Population Precision Theorem.** The variance of the pooled estimate
> from $N$ independent neurons is $v/N$; equivalently, the error (the
> standard deviation) shrinks like $\sqrt{v}/\sqrt{N}$.

Precision scales as $\sqrt{N}$. To halve your uncertainty you need four
times as many neurons; to gain a decimal place, a hundredfold. This is
the same law that makes political polls of a few thousand people
predict a nation of millions, the same $1/\sqrt{N}$ that governs every
average in science. The brain, it turns out, is running an internal poll
of its own neurons, and by pooling their scattered guesses it
manufactures a precision no single cell could ever deliver. Continuous
experience is a democracy of imprecise voters.

## The shape of activity: the neural manifold

Our final theorem answers the most modern question of the four. When
neuroscientists record hundreds of neurons at once, they get a point
wandering through a very high-dimensional space — one axis per neuron. In
principle that point could roam anywhere in the $N$-dimensional cube of
possible activity. In practice it does not. Instead, the activity is
found clinging to a thin, low-dimensional sheet — a **neural manifold** —
buried inside the enormous ambient space. Why should billions of degrees
of freedom collapse onto so few?

The answer is that neural activity does not exist for its own sake; it
exists to *drive behavior*, and behavior has only so many independent
knobs. A reaching arm, a moving eye, a walking gait — each is described
by a modest number of **behavioral degrees of freedom**. If the neural
population is producing activity in the service of $d$ behavioral
variables, then the activity can vary in at most $d$ independent ways.

> **Neural Manifold Theorem.** If the population activity is generated
> from $d$ underlying behavioral variables, the dimension of the neural
> manifold is at most $d$ — the number of behavioral degrees of freedom.

The proof, in its cleanest form, is a fact about linear maps: the image
of a $d$-dimensional space of behavioral commands can span no more than
$d$ dimensions of neural activity, because a map cannot manufacture
dimensions out of nothing — its rank is bounded by the dimension of its
source. However tangled the wiring, the *shape* of what the brain does
is corseted by the shape of what the body can do. This is why the
seemingly hopeless high-dimensional tangle of neural recordings so often
flattens, under analysis, into a few interpretable axes: the manifold
was never allowed to be big in the first place.

## The moral of the arithmetic

Step back and the four theorems tell a single story. The brain is handed
an exponential gift — $2^N$ possible thoughts — but also an exponential
temptation to squander energy. It resolves the tension with sparsity,
firing few neurons and reaping $\log N$ bits from every spike. It buys
precision not from perfect cells but from the crowd, extracting
$\sqrt{N}$ accuracy from noisy voters. And the tangle of its activity
stays organized, pinned to a low-dimensional manifold by the limited
repertoire of the body it must move.

None of this required knowing the chemistry of a synapse or the biology
of an ion channel. It followed from treating a neuron as a bit and a
thought as a pattern, and then counting carefully. That is the quiet
promise of a mathematics of the mind: that beneath the wet, warm chaos
of the brain lie laws as sharp and as certain as any in physics — laws
that say, in the end, how many ideas a fistful of neurons can hold, how
much they cost, how sharp they can be, and what shape they must take.
