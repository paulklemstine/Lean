# The Cliff at Four Bits

## Why a language model's memory can be halved for free — and why halving it again destroys the model completely

There is a moment in every engineering discipline when a smooth trade-off turns
out not to be smooth at all. You shave a little weight off a bridge, and nothing
happens. You shave a little more, and nothing happens. You shave a little more,
and the bridge is on the riverbed.

Something very like this happens inside a large language model, in a place most
people never look: the **key–value cache**.

---

### The model's short-term memory

When a language model reads a passage of text, it does not re-read the whole
passage for every new word. Instead, for each token it has already seen, it
stores two vectors — a **key** and a **value** — and keeps them in a buffer
called the KV cache. When the model produces the next token, it forms a
**query** vector $q$, compares it against every stored key $k_1,\dots,k_n$ by an
inner product, and turns the resulting list of numbers, the *logits*
$s_i = \langle q, k_i\rangle$, into a probability distribution using the softmax
function

$$\sigma_i \;=\; \frac{e^{s_i}}{\sum_{j=1}^{n} e^{s_j}}.$$

Those probabilities are the model's attention: the fraction of its focus that
goes to each remembered position. The value vectors are then blended in these
proportions. That is the whole mechanism.

The cache is enormous — gigabytes at a few thousand tokens of context, growing
linearly with the conversation. So there is a strong temptation to store the
keys and values in fewer bits: instead of a $16$-bit floating point number per
entry, use an $8$-bit code, or a $4$-bit code. Half the memory. A quarter of the
memory.

Here is what actually happens. On a seven-billion-parameter instruction-tuned
model, evaluated on a held-out slice of about $62{,}000$ tokens at a context
window of $2048$, with perplexity as the measure of quality (lower is better):

| keys | values | perplexity | change |
|---|---|---|---|
| $16$-bit | $16$-bit | $7.1093$ | — |
| $8$-bit | $16$-bit | $7.0924$ | $-0.238\%$ |
| $16$-bit | $8$-bit | $7.1160$ | $+0.094\%$ |
| $8$-bit | $8$-bit | $7.1162$ | $+0.097\%$ |
| **$4$-bit** | **$4$-bit** | **$2714.6042$** | **$+38{,}084\%$** |

Read that last row twice. Going from $16$ bits to $8$ bits costs one tenth of
one percent — within measurement noise, and in one arm perplexity actually
*improved*. Going from $8$ to $4$ bits multiplies perplexity by $380$. That is
not a degraded model; it is a model that has stopped predicting text.

There is no gentle slope between these two rows. The question this article
answers is *why not*, and the answer is a piece of clean mathematics: a
pigeonhole argument, a homogeneity obstruction, and an exactly computable
exchange rate between bits of precision and length of context.

---

### Crowding: the enemy is not noise, it is company

The naive picture of quantization damage is *noise*: rounding a key to a coarser
grid perturbs its logit by some small $\varepsilon$, and small perturbations
should do small harm. The picture is wrong, because the harm depends not on
$\varepsilon$ alone but on $\varepsilon$ compared with the *spacing between
logits* — and that spacing is not something the model gets to choose.

Here is the key observation, nothing more than the pigeonhole principle applied
to a ruler.

> **The Crowding Lemma.** Suppose $n+1$ attention logits $s_0 \le s_1 \le \dots
> \le s_n$ all lie inside a window of total width $R$, meaning $s_n - s_0 \le R$.
> Then some *consecutive* pair is separated by at most $R/n$:
> $$\min_{0 \le k < n} \; (s_{k+1} - s_k) \;\le\; \frac{R}{n}.$$

The proof is one line: the $n$ consecutive gaps sum to $s_n - s_0 \le R$, so
they cannot all exceed $R/n$. But the consequence is not cosmetic. It says
**crowding is forced, not accidental**: however cleverly the model spreads its
attention scores, at context $n$ there is always a pair of remembered positions
whose scores differ by no more than $R/n$. Longer context means tighter
crowding, always, for every input, for every head.

Now suppose the quantizer's induced logit error is at most $\varepsilon$. Two
positions whose true logits differ by less than $2\varepsilon$ can be swapped:
push the lower one up by $\varepsilon$, push the upper one down by $\varepsilon$,
and their order is reversed. And a reversed order in the logits is a reversed
order in the softmax weights, because $\sigma_i < \sigma_j$ exactly when
$s_i < s_j$ — the softmax is strictly order-preserving. The model attends more
strongly to the wrong token.

This gives a clean criterion. Write the quantizer's logit error at $b$ bits as
$A/2^b$, where $A$ is the dynamic range that the $b$-bit grid has to cover,
amplified onto the logit axis. Call the setting **safe** when the noise cannot
bridge the forced gap:

$$\text{Safe}(A,R,n,b) \quad :\Longleftrightarrow \quad 2\cdot\frac{A}{2^{b}} \;<\; \frac{R}{n}.$$

Rearranged, this is $2An < R\,2^b$ — pure arithmetic in $2^b$.

---

### One bit per doubling: the exchange rate

And now the elegant part. Look at what happens when the context doubles.

> **The Crowding Law.** For every dynamic range $A$, every window $R$, every
> context $n$ and every bit width $b$,
> $$\text{Safe}(A,R,2n,\,b+1) \quad\Longleftrightarrow\quad \text{Safe}(A,R,n,\,b).$$

Not "roughly comparable". Not "asymptotically the same". *The same statement.*
Doubling the context halves the forced gap $R/n$; adding one bit halves the
noise $A/2^b$; the criterion compares exactly these two quantities, so the two
operations cancel identically. Iterating, $m$ context doublings cost exactly $m$
bits. And if one defines $b^*(n)$ to be the smallest safe bit width at context
$n$, then — provided the regime is nontrivial, i.e. zero bits are not already
safe at the doubled context — one gets the exact recursion

$$b^*(2n) \;=\; b^*(n) + 1.$$

This reframes the whole question. **The KV cliff is not located at a bit width.
It is located at $b - \log_2 n$.** "Is $8$-bit cache safe?" is not a
well-formed question; "is $8$-bit cache safe at context $2048$?" is.

Plug in the numbers. Take the reference scale $A = 1$ and a logit window of
$R = 32$ nats — a plausible spread for attention scores in a trained transformer
— at $n = 2048$. The forced gap is $32/2048 = 0.015625$. At $8$ bits the noise
is $2/256 = 0.0078$: safely below. At $4$ bits it is $2/16 = 0.125$: eight times
*above*. The criterion brackets the cliff in $(4, 8]$ — exactly where the
measurement found it, from an argument that never looked at the measurement.

And it makes a prediction that costs one afternoon to test: four context
doublings consume four bits, so at context $32768$ the same model should
*already* be damaged at $8$ bits, since $R/n \approx 0.00098$ is now below the
$8$-bit noise of $0.0078$. The comfortable $8$-bit operating point everybody
uses is a statement about the context length, not about the model.

---

### The certificate on the safe side

The crowding law explains why $4$ bits can break, not why $8$ bits is *free*.
For that we need a bound in the other direction, reaching all the way to
perplexity — the quantity the experiment measures.

Perplexity is $e^{H}$, where $H$ is the mean cross-entropy — the average number
of nats of surprise per token. The relevant stability fact is:

> **The Perplexity Certificate.** If every logit at every position is perturbed
> by at most $\varepsilon$, then every softmax weight is multiplied by a factor
> between $e^{-2\varepsilon}$ and $e^{2\varepsilon}$; hence the log-loss on the
> true token rises by at most $2\varepsilon$ nats, the mean cross-entropy rises
> by at most $2\varepsilon$ nats, and
> $$\text{PPL}_{\text{quantized}} \;\le\; e^{2\varepsilon}\cdot \text{PPL}_{\text{exact}}.$$

The proof is a two-sided sandwich on the softmax: shifting every logit by at
most $\varepsilon$ scales the numerator by a factor in
$[e^{-\varepsilon}, e^{\varepsilon}]$ and the denominator likewise, so the
quotient moves by at most $e^{2\varepsilon}$. Logarithms and averaging do the
rest.

Put in the numbers for an $8$-bit cache. A full-width $8$-bit code on a
well-scaled tensor injects on the order of half a milli-nat of logit error,
$\varepsilon \le 1/2000$. Then $e^{2\varepsilon} \le 1.0011$: perplexity can rise
by at most $0.11\%$. The measured arms were $-0.24\%$, $+0.09\%$ and $+0.10\%$
— comfortably inside the certificate. **Eight-bit cache is free, and provably
so.** The trade is memory versus speed (the measured pass-time tax was
$+16$–$26\%$), never memory versus quality.

Now run the same inequality *backwards*. Upper bounds are usually inert as
explanations; this one is not, because the measured damage was so violent that
it forces the perturbation to be enormous. The observed factor was above $380$,
so $e^{2\varepsilon} \ge 380 > e^{5}$, hence

$$\varepsilon \;\ge\; 2.5 \ \text{nats}.$$

That is not a rounding error: it is a factor of twelve in the unnormalized
attention weight. A softmax whose logits are wrong by $2.5$ nats is not a
degraded ranking; it is a *different* ranking. That single number is the cliff,
quantified.

It also yields a falsifiable statement about the network rather than the
quantizer. If the $4$-bit error really is the resolution $A/2^4$ of a uniform
grid over a logit range of $A$ nats, then $A/16 \ge 2.5$ forces $A \ge 40$ nats.
So: measure the per-head logit range. If it is nowhere near $40$ nats, the
uniform-resolution story is wrong and the collapse must be driven by a handful
of outlier keys that blow up the per-tensor range for everybody else.

---

### The folklore explanation, and why it fails

The story usually told about this collapse is *depth amplification*: a small key
error is multiplied through every softmax boundary of every layer until a tiny
perturbation becomes catastrophic. It is a good story, and as an explanation of
*this* cliff it is demonstrably insufficient — for a single structural reason.

Model the propagation honestly. Let each layer amplify the incoming error by a
factor $\kappa \ge 1$ and inject a fresh quantization error $\varepsilon$. Then
after $L$ layers the accumulated error is

$$E_L(\kappa,\varepsilon) \;=\; \varepsilon\,\frac{\kappa^{L}-1}{\kappa-1},$$

a geometric sum, genuinely exponential in depth: $E_{L+1} \ge \varepsilon
\kappa^{L}$. Depth really does amplify.

But look at the dependence on $\varepsilon$. It is *linear*. Exactly, identically
linear:

$$E_L(\kappa,\,c\,\varepsilon) \;=\; c\,E_L(\kappa,\varepsilon)
\quad\text{for every } c,\ \kappa,\ L.$$

This is the obstruction, and it is parameter-free — it holds for every
amplification factor and every layer count simultaneously. Going from $8$ bits
to $4$ bits multiplies the quantization step by exactly $16$, so *any* damage
model $D$ that is sub-homogeneous ($D(cx) \le c\,D(x)$ for $c \ge 1$) can
multiply the damage by at most $16$. The measurement demands more than $5000$:
the $8$-bit arm lost less than $1/1000$ of a nat of log-perplexity while the
$4$-bit arm lost more than $5$ nats. Sixteen against five thousand — the depth
story, calibrated on the $8$-bit arm, under-predicts the collapse by more than
two orders of magnitude.

**The cliff is a threshold phenomenon, not a gain.**

What the data *do* force is a steep power law. If the excess log-perplexity
behaves as $D(x) = Cx^{p}$ in the quantization step $x$, then the two measured
arms require $16^{p} > 4096 = 16^{3}$, that is

$$p \;>\; 3.$$

And a steep exponent bounds how wide the transition can be. Call a bit width
**intermediate** if the damage it produces is neither free ($\le \delta$) nor
annihilating ($\ge 5000\,\delta$) — the two regimes actually observed. With
$p \ge 3$, five extra bits shrink the damage by at least $2^{15} = 32768$, more
than the whole free-to-annihilated range of $5000$. Hence any two intermediate
widths differ by at most $4$.

This is the precise sense in which "there is no usable middle": the middle is
**at most four bit widths wide** — and the grid $\{4, 8\}$ is exactly four bits
apart. The experiment did not fail to find the middle; it stepped over it.

---

### The cliff fits inside a single softmax

If depth is not the mechanism, is depth even necessary? No: the whole
free-to-annihilated range can be manufactured in a *two-position* attention
head, with no layers at all.

Take a head with two cached positions whose logits are $0$ and $G = 12$ nats
apart, and let the quantizer perturb them adversarially — the lower one up by
$\varepsilon$, the higher one down by $\varepsilon$, which is the typical, not
the exotic, behaviour of an independent rounding scheme. At $\varepsilon = 13$
the log-loss on the correct token rises by more than $5$ nats, a perplexity
factor above $148$. At one sixteenth of that error, $\varepsilon/16 = 0.8125$,
the same head loses less than one thousandth of a nat, a perplexity factor
below $1.001$.

One softmax. One factor of $16$ in the step. Free on one side, annihilated on
the other. The cliff needs no depth to exist.

---

### Can block scaling rescue four bits?

The obvious engineering response is: don't quantize the whole tensor against one
scale. Split it into blocks of $32$ weights, each with its own scale and offset.
Does that rescue the cache? The answer splits into two halves that point in
opposite directions, and the split is the deepest thing in this story.

**Yes, on resolution — and by an exactly computable amount.** A block-scaled
quantizer is just a per-tensor quantizer applied to a smaller dynamic range. If
the per-block range is $2^m$ times smaller than the per-tensor range, then the
safety criterion at $b$ bits on the shrunken range is *literally the same
proposition* as the criterion at $b+m$ bits on the full range:

$$\text{Safe}\!\left(\tfrac{A}{2^{m}},R,n,b\right) \iff \text{Safe}(A,R,n,b+m).$$

Block scaling is a bit shift, exactly. So one can price a rescue. Suppose a
block whose range is $\rho$ times the tensor range is safe at $4$ bits, while
the full range is not even safe at $8$. Then $\rho < 1/16$: block scaling must
shrink the dynamic range by *more than the four bits it is trying to replace*.
At the reference scale this is achievable — with a $16$-fold concentration, four
bits do satisfy the criterion at context $2048$, where raw four bits fail. The
prediction is sharp and cheap: measure the ratio of per-block to per-tensor key
range; the resolution axis is rescued exactly when it is below $1/16$. Two
riders: safety of a blocked cache is safety of *every* block, so the worst block
governs; and if even one block still spans the full tensor range — one outlier
key is enough — block scaling has bought precisely nothing.

**No, on distinctness — and no scaling scheme ever can.** Here is the wall. A
$4$-bit code has $16$ levels. A block holds $32$ weights. Sixteen boxes, thirty
two pigeons: in *every* block, two distinct keys must receive the same code,
independently of the scale, the offset and the shape of the quantizer. Replacing
$Q$ by the affinely rescaled
$x \mapsto \sigma\,Q\!\left(\frac{x-\mu}{\sigma}\right)$ does not change the
number of distinct outputs, so the collision survives every choice of $\sigma
\ne 0$ and $\mu$.

And a collision is not a small error. Two cache positions whose quantized logits
are *equal* receive **exactly equal** softmax weights. The attention ordering
between them carries no information at all — not a degraded amount, zero. Inside
every block of every layer, the ranking of some pair of remembered tokens has
been erased.

So the two halves are:

> **Block scaling rescues resolution, not distinctness.** It moves the
> resolution threshold by a computable number of bits; it cannot move the
> distinctness threshold at all. At $4$ bits, the two thresholds have already
> crossed.

That is the structural reason the cliff is a wall rather than a slope.

---

### The sandwich: how wide is the unexplained band?

We now have two certificates pointing in opposite directions. On the fragile
side: once the logit error $A/2^b$ exceeds half the forced crowding gap $R/n$,
some correctly ordered pair of positions is *provably* inverted. On the free
side: once the logit error is below $\delta/2$, perplexity is *provably*
multiplied by at most $e^{\delta}$.

Between them sits a band of bit widths where neither certificate applies. How
wide is it? Exactly

$$m \;=\; \left\lceil \log_2\!\frac{R}{n\,\delta} \right\rceil \ \text{bits}.$$

The reason is a one-line computation: $m$ extra bits divide the error by $2^m$,
and $2^m \ge R/(n\delta)$ is precisely the condition that turns "below the
crowding gap $R/n$" into "below the free tolerance $\delta$".

At the reference scale — window $R = 32$ nats, context $n = 2048$, free
tolerance $\delta = 1/1000$ nats — the width is

$$\log_2 \frac{32}{2048 \times 0.001} \;=\; \log_2 15.625 \;<\; 4.$$

**Four bits** — exactly the gap between the two arms the experiment ran. And the
formula tells you how to move the band: it *widens* by one bit for every tenfold
tightening of $\delta$, and *narrows* by one bit for every context doubling. Run
$5$, $6$, $7$ bits at context $2048$, and the middle becomes resolvable.

---

### What to take away

Three things, and none of them are about caches specifically.

**First: precision is relative to crowding.** The right question is never "how
many bits?" but "how many bits per decade of things that have to be told apart?"
Here the exchange rate is exact — one bit per context doubling, with equality.
Any system that resolves $n$ items inside a bounded window pays $\log_2 n$ bits
just to keep them in order.

**Second: thresholds are not gains.** A $38{,}000\%$ collapse cannot come from
any mechanism linear in the perturbation, no matter how many layers you stack,
because linearity is a homogeneity statement and homogeneity is parameter-free.
When the response ratio outruns the input ratio by orders of magnitude, you are
not looking at amplification; you are looking at something crossing a line.

**Third: some walls are informational, not numerical.** You can always buy more
resolution, and its price is computable to the bit. You cannot buy more
*distinctness*: sixteen codes will never separate thirty-two numbers. When your
error budget and your distinctness budget fail at the same operating point, the
failure is not steep. It is discontinuous.

Which is why, on the precision axis of a language model's memory, there is a
comfortable operating point at eight bits, a smoking ruin at four, and — at this
context length — essentially nothing usable in between.
