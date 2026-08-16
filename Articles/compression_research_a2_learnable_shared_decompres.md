# The Model Is Free, the Model Delta Is Not

## A tale of two costs

Here is a fact that ought to be more famous than it is: a large language model is a
world-class file compressor.

Not metaphorically. Literally. Feed a language model the first half of a Wikipedia
article, ask it for its probability distribution over the next character, and hand that
distribution to an arithmetic coder. The coder spends about $-\log_2 p$ bits on the
character that actually occurred. If the model is good, those bits are few. Run this over
a whole corpus and you get compression ratios that leave `gzip`, `bzip2`, and even
hand-tuned context-mixing compressors far behind — and *losslessly*: the decoder, running
the identical model, reconstructs the original bytes exactly.

There is a catch, and it is the reason this article exists. The compressed file is small
only because the decompressor is enormous. A receiver who does not already possess the
multi-gigabyte model cannot decode anything at all. If you count the model as part of the
message, the "compression" is a fraud: you have shipped billions of bits of neural network
to save a few million bits of text.

So the honest question is not "how small is the file?" It is:

> **How do you pay for the decompressor — and when does that payment stop mattering?**

This article is about a precise, provable answer to that question. The answer turns out to
have a beautiful and slightly surprising shape. The one-off cost of *specializing* a
decompressor is not amortized by the length of your stream. It is amortized by something
subtler: the **coherence length** of your data. And the whole story is governed by an
algebra in which "add" means "take the minimum" and "multiply" means "add" — the tropical,
or min-plus, semiring.

## Separating the program from the data

Let us make the setup honest. Imagine a sender and a receiver who have already agreed, at
deployment time, on a shared decompressor: a big pretrained model burned into both
endpoints, negotiated once, never re-transmitted, the same for everybody. Because it is
universal and fixed, it is fair not to charge for it: it is infrastructure, like the TCP
stack.

What the sender *may* do, and what does get charged, is **steer** that shared decompressor
toward the domain at hand. Legal contracts, Python source, Portuguese poetry, DNA reads —
each has statistics the generic model handles adequately but not brilliantly. A small patch
to the parameters (a low-rank adapter, a sparse weight diff, a fine-tuned codebook, a
dictionary) can sharpen the model dramatically on one domain. That patch is a bitstring, it
travels down the wire, and it is part of the message. We call it the **model delta**, and
its length in bits we call $D$.

So the transmitted bits split into two species: **model deltas**, occasional and
expensive, costing $D$ bits to move the shared decoder from one state into another; and
**residuals**, constant and cheap, costing $c(m)$ bits to code a message when the decoder
happens to be in state $m$.

That is the whole model. It is deliberately austere — no neural networks appear in it, no
gradient descent, no floating point — and that austerity is exactly what lets us prove
things. Let $M$ be a finite set of possible decoder states (the pretrained model as
shipped, plus every state reachable by patching it). Let $\delta(m, m')$ be the number of
bits needed to move the decoder from state $m$ to state $m'$; naturally $\delta(m,m) = 0$,
since staying put is free. And for each message in the stream let $c_i(m)$ be the bits
needed to code message $i$ with the decoder in state $m$.

A **schedule** is the sender's plan: which state to put the decoder in for each message.
Its total cost is

$$\delta(p, m_1) + c_1(m_1) \;+\; \delta(m_1, m_2) + c_2(m_2) \;+\; \cdots \;+\; \delta(m_{n-1}, m_n) + c_n(m_n),$$

where $p$ is the state the decoder starts in. The protocol optimum $V$ is the minimum of
this over all schedules. That's it. That's the object of study.

## Why this is secretly tropical geometry

Look at the two operations that build the optimum. Along a single schedule, costs **add**.
Across competing schedules, you take the **minimum**. Add and min: these are precisely
multiplication and addition in the *min-plus semiring*, the arithmetic of tropical
mathematics, where $a \oplus b := \min(a,b)$ and $a \otimes b := a + b$.

This is not a cute analogy; it is an identity. Assemble the costs into a matrix $A$ whose
$(i,j)$ entry is $\delta(i,j) + c(j)$ — "the bits to move to state $j$ and then code one
message there." Then the optimal cost of a stream of $n$ identical messages, starting in
state $p$, is exactly the $p$-th coordinate of the $n$-th **tropical matrix power**
applied to the tropical all-ones vector,

$$A^{\otimes n} \otimes \mathbf{1}.$$

Ordinary matrix powers count paths; tropical matrix powers find shortest ones. Compression
scheduling is a shortest-path problem in disguise.

This identification tells you immediately what the long-run bits-per-message must be: the
growth rate of tropical matrix powers, the min-plus analogue of the spectral radius. In
min-plus algebra the "eigenvalue" of a matrix is its **minimum cycle mean** — the cheapest
average cost of a closed loop in the state graph. So the asymptotic cost of any streaming
adaptation protocol is the cheapest sustainable *cycle* of decoder states.

## The sharp law: $n r + \min(D, n)$

Start with the scenario that models the real use case, "I have a big pile of documents
from one domain."

Two decoder states. The **generic** one is the pretrained model as shipped; it costs
$r + 1$ bits per message. The **specialized** one is the domain-adapted model; it costs
$r$ bits per message — one bit better. Getting from generic to specialized requires
transmitting the $D$-bit patch. Falling back is free, and staying put is free. The stream
has $n$ messages, all from the domain.

The sender has two sensible strategies: *never patch*, at $n(r+1) = nr + n$ bits, or
*patch immediately and then coast*, at $D + nr$ bits. Which is better depends on whether
$n$ or $D$ is smaller. It is intuitively clear that nothing cleverer can help — but
"intuitively clear" is where compression papers go to die, because the space of schedules
is exponentially large and adaptive protocols are notorious for hiding cleverness in the
corners. So here is the theorem, proved and not merely asserted.

> **Sharp Amortization Theorem.** Suppose every message costs at least $r$ bits in every
> decoder state; that any state achieving the optimal rate $r$ can only be entered from a
> non-optimal state by paying at least $D$ bits; that there is a specialized state
> reachable for exactly $D$ bits; and that the starting state costs $r+1$ bits per
> message. Then for a stream of $n$ identical messages the optimal number of transmitted
> bits — deltas included — is exactly
> $$V(n) \;=\; n\,r \;+\; \min(D, n).$$

Both halves are real content. The upper bound is the "patch once and coast" protocol. The
lower bound is the interesting one: it says no schedule can do better, and its proof is a
clean induction that captures a genuine dichotomy. At each message the sender either moves
into a specialized state — and then it has already paid $D$, and the remaining stream
still costs at least the rate floor $nr$ — or it does not, and it pays one surplus bit on
this message and inherits the same dilemma for the rest of the stream. Either you pay the
delta, or you pay a bit per message, forever. There is no third option.

Three corollaries fall out immediately, and each is a design rule.

**Break-even is exactly at the length of the patch.** The adaptive protocol strictly beats
the never-patch protocol if and only if $n > D$. Not "roughly", not "up to constants":
exactly. A $10\,000$-bit LoRA patch that buys you one bit per message pays for itself on
the $10\,001$st message and not a message sooner.

**Short streams should not adapt at all.** For $n \le D$ the optimum equals $n(r+1)$: the
cost of the delta-free generic protocol, precisely. Sending a patch for a short stream is
never merely suboptimal — it is strictly wasteful, and the optimal protocol declines to do
it.

**In the limit the model delta is free.** The amortized bits per message,
$V(n)/n = r + \min(D,n)/n$, converges to $r$ as $n \to \infty$, no matter how astronomically
large $D$ is. A gigabyte-sized patch still washes out — eventually. This is the precise
form of the slogan in the title: the model is free, the model delta is not, but the delta
becomes free too if you are patient enough.

The optimum is also **concave** in stream length, $V(n) + V(n+2) \le 2V(n+1)$: the marginal
cost of one more message never increases. Amortized compression has economies of scale.

## The floor nobody crosses

An upper bound on a compressor is a promise; a lower bound is a law. The law here is
counting, and it is completely indifferent to how sophisticated the decompressor is.

Count the bitstrings of length at most $t$: there are exactly $2^{t+1} - 1$ of them. A
lossless encoder is one whose map from source to transmitted bitstring is injective —
otherwise two sources decode to the same thing and information is lost — so the number of
sources you can squeeze into $t$ bits or fewer is at most $2^{t+1} - 1$. Compressible
objects are exponentially rare, and this holds whether your decompressor is a gzip table,
a context mixer, or sixteen gigabytes of transformer weights. Pigeons, holes.

> **Streaming Counting Floor.** For a stream of $n$ messages drawn from an alphabet of
> $2^s$ symbols, every lossless transmission scheme — shared decompressor, transmitted
> delta, arithmetic-coded residuals, all of it — must spend at least $n\,s$ bits on some
> stream.

Put this next to the amortized protocol, which spends $D + n s$ bits, and you get the
sandwich that makes the whole enterprise honest:

$$n\,s \;\le\; \text{(amortized protocol)} \;=\; D + n\,s.$$

The protocol is within $D$ bits of the information-theoretic optimum, **uniformly in
$n$** — the gap does not grow. And the losslessness is not a hope but a construction: for
any domain that fits in $2^s$ codewords there is a codec whose stream decoder returns the
input exactly, message for message, established by induction along the stream. The
falsifiability gate of this line of work — *beat the classical baselines losslessly, with
the decoder fixed at deploy time, and count every delta bit as part of the message* — is
met by an explicit object, not by an optimistic estimate.

## The twist: coherence length, not stream length

The amortization theorem says the delta is free in the limit of long streams. It is
tempting to conclude: *just batch more data*. That conclusion is wrong, and here is how
wrong. Take two domains instead of one, and a stream that **alternates** between them at
every single message: legal, Python, legal, Python. Each message costs $r$ bits if the
decoder is specialized to its domain and $r+1$ bits otherwise; swapping the decoder costs
$D \ge 1$ bits. The stream is as long as you like.

> **Incoherent Stream Theorem.** For the alternating stream of $n$ messages the optimum is
> exactly $n r + \lceil n/2 \rceil$ bits (or $nr + \lfloor n/2 \rfloor$ if the decoder
> happens to start in the right state). In particular the answer does not depend on $D$ at
> all: the optimal protocol never switches. The amortized rate is $r + \tfrac{1}{2}$ bits
> per message, forever.

Stream length did nothing. You can send a trillion messages and still lose half a bit on
every one of them. Whatever the delta buys, it is not bought by volume.

What *is* it bought by? Interpolate. Let the stream consist of $B$ blocks of $L$
consecutive messages, the domain flipping from block to block. Now $L$ is a tunable
**coherence length**: $L = 1$ is the alternating disaster above, $L = \infty$ is the single
coherent domain of the sharp theorem. The exact optimum, for every $B$ and $L$, is

$$V \;=\; B\,L\,r \;+\; \Big\lfloor \tfrac{B}{2} \Big\rfloor \cdot \min(2D, L) \;+\; (B \bmod 2)\cdot \min(D, L).$$

Behind that formula is a three-way competition inside each pair of blocks. To serve a
block of the wrong domain the sender may (i) never switch and eat $L$ surplus bits,
(ii) switch in and stay, paying $D$, or (iii) switch in and back out again, paying $2D$.
The optimum takes the minimum, and the min-plus recursion propagates it down the stream.
Dividing by the total message count $BL$ gives the punchline.

> **Coherence-Length Law.** The amortized rate of a block-alternating stream converges to
> $$r + \frac{\min(2D, L)}{2L} \quad \text{bits per message}.$$

That formula contains the design rule for every practical scheme in this space. If
$L \ge 2D$ — blocks longer than twice the patch — the excess is $D/L$ per message: the
delta amortizes against the block and shrinks as blocks grow. If $L < 2D$, the excess is
$\tfrac{1}{2}$ per message *independent of $D$*: the patch is simply never worth sending
and you pay the generic-model surcharge forever. Setting $L = 1$ recovers the half-bit loss
of the alternating stream; letting $L \to \infty$ recovers the vanishing overhead of the
coherent stream.

So the quantity to maximize is not how much data you have. It is **how long your data
stays on-topic**. A petabyte of thoroughly shuffled multi-domain text is, for the purposes
of model-delta amortization, worthless; a modest corpus sorted by domain is gold. This is,
incidentally, a theorem about why *clustering before compressing* works, and how much it
is worth.

## How many bits is a domain, anyway?

One more counting argument closes the loop, and it is the one that bites hardest in
practice. Suppose your shared decompressor serves $K$ different domains, each selected by
its own transmitted patch. Distinct domains must get distinct patches — if two shared a
patch, the deployed decoder would be in the same state for both, contradicting that each
has its own optimal state. So the patches form an injective map from $K$ domains into
bitstrings, and the pigeonhole principle applies *to the patch alphabet itself*: whenever
$2^{t+1} \le K$, some domain's patch is longer than $t$ bits. Feed that back into the
break-even law and you get an unavoidable **warm-up delay**.

> **Logarithmic Warm-Up.** If a shared decompressor is steerable to $K$ domains, there is a
> domain for which the optimal adaptive protocol coincides *exactly* with the generic,
> never-patch protocol for every stream of at most $t \approx \log_2 K$ messages, and whose
> break-even stream length exceeds $t$.

For that unlucky domain the specialized decoder is not merely a poor deal during the
warm-up — it is worth precisely nothing, and the optimal protocol ignores it. If you want
more domains, you pay for the address space in which to name them. Rank tricks, sparsity
patterns, and quantization all reparametrize the patch; none of them repeal the logarithm.

## The shape of the answer

Two structural facts round out the picture. First, the optimum is **superadditive**:
coding a concatenated stream costs at least the optimum of the prefix plus the best
achievable cost of the suffix over all splice states. This is the min-plus counterpart of
submultiplicativity of matrix norms, and it says the only thing the encoder gains from
seeing the whole stream at once is the freedom to choose the decoder state where the
pieces meet.

Second, **there is no free lunch in routing patches.** You might hope to reach a distant
model state cheaply by hopping through an intermediate one, composing two small patches
instead of one big one. The min-plus self-composition of the delta matrix asks exactly
this question, and it equals the original matrix precisely when the delta cost satisfies
the triangle inequality $\delta(i,j) \le \delta(i,k) + \delta(k,j)$. Under that condition —
which any sane patch format satisfies, since you can always concatenate two patches into
one — multi-hop patching leaves the optimum completely unchanged. Triangle inequality is
min-plus idempotence.

## Why it matters

Four rules a compression engineer can act on today.

1. **Sort your stream by domain.** Coherence length, not corpus size, amortizes
   adaptation; the avoidable loss is exactly $\min(2D, L)/(2L)$ bits per message.
2. **Do not adapt below break-even.** If the coherent run is shorter than the patch, the
   patch is strictly wasted, and the optimal schedule refuses to send it.
3. **Budget a logarithmic warm-up.** Serving $K$ domains costs at least $\log_2 K$ bits of
   patch somewhere, and some domain sees no benefit for its first $\log_2 K$ messages.
4. **Count the delta.** A compression result that does not charge for the transmitted
   patch is not a compression result. Every bound above includes it.

And the conceptual upshot is larger. The old picture of compression is a single number: the
entropy of the source. The picture here is two numbers in tension — the residual rate $r$
you can reach with the right program, and the price $D$ of shipping that program — mediated
by a third, the coherence length $L$ over which the program stays right. Minimum
description length has always said that the best model is the one minimizing model bits
plus data bits. What the min-plus analysis adds is the *dynamics*: when the right model
changes over time, the optimal schedule of model changes is a shortest path, its long-run
rate is a tropical eigenvalue, and the break-even points are exactly where the
piecewise-linear kinks fall.

That last image is a good one to end on. The optimum $n r + \min(D, n)$ is a piecewise
linear function of stream length with a single kink at $n = D$, and piecewise linear
functions with kinks are what tropical geometry is made of. The break-even point of a
compression protocol and the corner of a tropical curve turn out to be the same phenomenon
wearing different clothes.
