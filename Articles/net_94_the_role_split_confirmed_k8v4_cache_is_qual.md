# The Two Halves of a Memory: Why Keys Break and Values Don't

## A cache with a split personality

Every time a large language model reads a word, it stores two things about it. One is a
*key*: a fingerprint used to decide, later, whether this word is worth paying attention
to. The other is a *value*: the actual content that gets mixed into the answer once the
decision to attend has been made. Together these two tensors form the **KV cache**, and on
long inputs the cache — not the model weights — is what fills up your memory.

The obvious way to shrink it is to store the numbers with fewer bits. Instead of $16$ bits
per number, use $8$; instead of $8$, use $4$. Since keys and values look identical from the
outside — both are just big arrays of floating-point numbers — the natural thing is to
compress them equally. Six bits each, say.

That instinct is wrong, and the error is not small. In a controlled measurement on a
held-out text sample, a cache storing **keys at $8$ bits and values at raw $4$ bits** — an
average of about $6$ bits per element — produced a perplexity of $7.1194$ against a
full-precision control, a degradation of $+0.142\%$. That is indistinguishable from free.
A cache storing **both keys and values at $5$ bits** — *less* memory saved than the first
configuration on the key side, more on the value side, comparable total budget — produced
a perplexity of $68.7963$: a degradation of $+867.694\%$. Push the keys to $4$ bits and the
degradation exceeds $+38{,}000\%$; the model stops being a model. Values, meanwhile, stay
free at every width tested, all the way down to raw $4$-bit.

So: the same number of bits, two configurations, and one of them is a working language
model while the other is noise. This article is about *why*. The answer is not a fact about
transformers, or about any particular quantisation format. It is a fact about the algebra
of the attention map — specifically, about the difference between a **convex average** and
an **exponential**.

## Where the two tensors enter

Attention computes an output as follows. For each stored position $i$ there is a *logit*
$s_i$ — the inner product of the current query vector $q$ with the stored key $k_i$. These
logits are converted into weights by the softmax,

$$w_i \;=\; \frac{e^{s_i}}{\sum_j e^{s_j}},$$

and the output is the weighted average of the stored values,

$$\mathrm{out} \;=\; \sum_i w_i\, v_i .$$

Look at where each tensor sits. The values $v_i$ appear **once, linearly, inside a convex
combination**. The keys appear inside an inner product, which is then fed to an
**exponential**. That is the whole story in one line — everything below is bookkeeping on
that asymmetry.

### The value side: no amplification, ever

Suppose quantising the values perturbs each one by at most $\varepsilon$. How much can the
output move? Write the perturbed values as $v_i + e_i$ with $|e_i| \le \varepsilon$. Then

$$\Big|\sum_i w_i (v_i + e_i) - \sum_i w_i v_i\Big| = \Big|\sum_i w_i e_i\Big| \le \sum_i w_i |e_i| \le \varepsilon \sum_i w_i = \varepsilon,$$

using only that the weights are non-negative and sum to $1$. **The value path is
$1$-Lipschitz.** The error you put in is the error you get out — no dimension factor, no
dependence on the query, no dependence on how large the values are, no dependence on the
sequence length. Halve the value quantisation step and you exactly halve the damage. This
is the *Value Path Stability Theorem*, and it is the algebraic reason values survive raw
$4$-bit storage.

### The key side: an exponential in disguise

Now perturb a key by $\eta$ per coordinate. In head dimension $d$, with query coordinates
bounded by $Q$, the logit moves by at most $d\,Q\,\eta$ — already the dimension multiplies
your quantisation step, which the value path never does. Then the softmax turns that logit
error into a *multiplicative* one. If every logit moves by at most $\varepsilon$, every
weight is inflated by at most $e^{2\varepsilon}$, the weight vector moves by at most
$2(e^{2\varepsilon} - 1)$ in total variation, and the output moves by at most
$2(e^{2\varepsilon} - 1)V$ where $V$ bounds the values.

Crucially, that exponential is not slack in the analysis; it is exactly what the softmax
does. Shifting the logits by $d$ multiplies the *odds* of position $i$ against position $j$
by precisely $e^{d_i - d_j}$ — an identity, not an inequality. The softmax responds to
logit noise exponentially, full stop, and no cleverer bound exists.

Put the two together and you get the **role-split error budget**: with key-side logit error
$\varepsilon_K$ and value-side entrywise error $\varepsilon_V$, the attention output moves
by at most

$$2\big(e^{2\varepsilon_K} - 1\big)V \;+\; \varepsilon_V .$$

The key term is exponential in its budget; the value term is *exactly* its budget.

## Doubling versus squaring

Translate that into bits. A quantiser at $b$ bits has step proportional to $2^{-b}$, so:

* the value distortion is $R/2^{b}$ — it **doubles** for each bit you remove;
* the key distortion factor is $e^{c/2^{b}}$ — and since $e^{c/2^{b}} = \big(e^{c/2^{b+1}}\big)^2$, it **squares** for each bit you remove.

Squaring versus doubling. Drop $k$ key bits and the key distortion factor is raised to the
power $2^{k}$; drop $k$ value bits and the value distortion is multiplied by $2^k$. That
single line explains why the two roles must be budgeted differently, and it yields an
immediate design consequence.

**Equal memory, unequal quality.** The configurations "$8$-bit keys, $4$-bit values" and
"$6$-bit keys, $6$-bit values" cost exactly the same average of $6$ bits per element, since
$8 + 4 = 6 + 6$. But once the key distortion factor at $8$ bits reaches $2$ — the regime the
measurement puts us in, where $5$-bit keys are already broken — the asymmetric split is
*strictly* better for every value range up to $256$. That is the theorem behind the serving
recommendation: **keys at $8$ bits, values at $4$**.

More generally, moving $k$ bits from the value cache to the key cache leaves memory
untouched and strictly reduces total distortion whenever the value-side loss
$(2^{k}-1)\cdot R/2^{b}$ is smaller than the key-side saving $t^{2^k} - t$, where $t$ is the
key distortion factor at the enriched width. The key saving is a degree-$2^k$ polynomial in
$t$; the value loss is a mere factor of $2^k$. Polynomials of degree $2^k$ win.

## The smooth story is false — and the data say so

Here is where the analysis stops being a comfortable rationalisation and starts making
falsifiable claims.

The model above, taken literally, is *too gentle* to explain the measurement. Under the
squaring law, going from $8$ bits to $5$ bits can at most multiply the **logarithm** of the
distortion factor by $2^{3} = 8$. But the data demand a jump from a log-distortion of about
$\log(1.00142) \approx 0.00142$ to at least $\log(9.67694) > 2$ — a factor exceeding
$1400$. Hence:

> **No constant $c$ makes the smooth law $e^{c/2^b}-1$ simultaneously quality-free at $8$
> bits ($\le +0.142\%$) and broken at $5$ bits ($\ge +867.694\%$).**

The measured cliff is at least two orders of magnitude sharper than any "error $\propto
2^{-b}$" key model can produce. And this refutation does not depend on the softmax at all.
Suppose only that the key distortion is *multiplicative in bit width*: $D(b) = c/K^{b}$ for
some per-bit shrink base $K$. This covers uniform quantisers ($K=2$), power-law responses
($K = 2^{\gamma}$), and everything in between. Then fitting both measured arms forces

$$K^{3} \;\ge\; \frac{8.67694}{0.00142} \;>\; 6110, \qquad\text{hence}\qquad K > 18,$$

since $18^3 = 5832$. Each key bit must divide the effective key error by more than
**eighteen**, not by two. The honest uniform-step law $c\cdot 2^{-b}$ — which is exactly the
value-side law — is refuted outright.

The same computation, phrased as a response exponent, gives the sharpest form of the
asymmetry. Suppose the key distortion responds to the quantiser step as a power law,
$c\,(R/2^{b})^{\gamma}$. Then $K = 2^{\gamma} > 18$ forces $\gamma \ge 5$, because
$2^4 = 16$. Meanwhile the value distortion is *exactly* the quantiser step: exponent
$\gamma = 1$, on the nose.

> **The response-exponent gap.** The key-side exponent is at least $5$; the value-side
> exponent is exactly $1$. The two halves of the cache are separated by a response-exponent
> gap of at least $4$.

The bound $\gamma \ge 5$ cannot be improved to $\gamma \ge 6$: with unit range and exponent
exactly $5$, the prefactor $8.67694 \cdot 2^{25}$ reproduces both measured arms. Five is
attained.

## Ruling out the obvious escape: depth

A natural objection: attention is not applied once, it is applied in $L$ stacked layers.
Perhaps a mild per-layer response compounds into a cliff?

It does not. Model the propagation of error through the stack by the recursion
$\delta \mapsto \lambda\delta + e$: each layer amplifies the incoming deviation by a gain
$\lambda$ and injects its own quantisation error $e$. (This *is* a genuine bound: if two
trajectories start together and each layer is $\lambda$-Lipschitz up to injected error $e$,
their deviation after $L$ layers is at most the recursion's value.) Solving the recursion
gives the closed form

$$\delta_L \;=\; e\sum_{i<L}\lambda^{i}.$$

Depth contributes exactly a geometric factor multiplying $e$ — and a factor multiplying $e$
cannot change how $e$ depends on $b$. Formally, composing a power-law response of exponent
$\gamma$ over $L$ layers yields a power-law response of *the same* exponent $\gamma$, with
prefactor multiplied by $\sum_{i<L}\lambda^{i}$. **Depth moves the constant, never the
slope.** Consequently, whatever the depth and per-layer gain, a depth-composed key response
fitting both measured arms still has $\gamma \ge 5$: stacking layers cannot rescue a low
exponent. And on the value side, $\lambda = 1$ gives $\delta_L = L\cdot e$ — linear in depth,
linear in the step, never a cliff.

## What actually breaks: the argmax flips

Upper bounds, however tight, can only fail to prove robustness; they never prove fragility.
To show that the key side really *is* brittle, you need a lower bound — a guarantee that
the damage is large. Here it is, and the mechanism is beautifully simple.

Softmax is **order preserving**: $w_i < w_j$ if and only if $s_i < s_j$. So the attended
position is precisely the arg-max of the logits, and everything the attention layer decides
is a fact about *rankings*, not magnitudes. Now let position $j$ genuinely dominate position
$i$ by a top-two gap $g = s_j - s_i > 0$, and let quantisation perturb the logits by $d$. If

$$d_i - d_j \;>\; g,$$

then the ranking is **reversed**: after quantisation the model attends more strongly to $i$
than to $j$. It is now reading the wrong token. No Lipschitz constant repairs this, because
nothing has been approximated — a discrete decision has been made incorrectly.

How much damage does that do? Take the cleanest possible instance: two positions with
logits $(0, g)$, a perturbation $(\varepsilon, -\varepsilon)$ (the distractor overestimated,
the true target underestimated — the typical, not exotic, behaviour of a quantiser), and a
readout that returns $1$ at the attended position and $0$ at the distractor. Before
perturbation the attended token holds at least half the mass. After a perturbation that
overshoots the gap by $2h$ — that is, $g + 2h \le 2\varepsilon$ — it holds at most
$1/(1 + e^{2h})$. Hence:

> **Inversion lower bound.** The attention output is wrong by at least
> $$\tfrac{1}{2} - \frac{1}{1 + e^{2h}},$$
> a quantity tending to $\tfrac12$ as the overshoot grows.

This is a lower bound of order $1$ — a constant-size error, not a small one. It is the exact
converse of value-path stability: the value path can never move the output by more than its
own budget, whereas the key path moves it by an amount governed only by *whether* the noise
beat the gap, not by how small the noise is.

## Why the cliff is narrow

The threshold picture also explains something the smooth picture cannot: the **sharpness**
of the transition in bit width.

Let the key noise be $A/2^{b}$, halving with each added bit, and call the band
$[g/2,\, g)$ *critical*: the noise is not yet large enough to invert the arg-max, but it is
within a factor of two of doing so. Then:

> **At most one bit width lies in the critical band.** If $g/2 \le A/2^{b} < g$ and
> $g/2 \le A/2^{b'} < g$, then $b = b'$.

The proof is a two-line squeeze: one bit below the band the noise exceeds the gap and the
arg-max inverts; one bit above, the noise is already below half the gap. A gap-threshold
mechanism therefore produces a free-to-broken transition **one to two bit widths wide**.

Compare the smooth model. To move from $+0.142\%$ to $+867.694\%$ under the squaring law
requires at least $\log_2\!\big(\log 9.67694 / \log 1.00142\big) > 10$ bit widths. Ten bits
versus one. The measurement brackets the key floor in the interval $(5, 8]$ — a window of
three bit widths, and in truth narrower, since the format ladder available offers nothing
between $5$ and $8$ bits, so $3$ is an upper estimate of the true window.

Three is close to one and nowhere near ten. **The measured bracket is evidence for the
gap-threshold mechanism and against the smooth one.**

## The picture that emerges

Every phenomenon in this story reduces to a single algebraic dichotomy:

* The **value operator** is a convex combination — degree $1$, dimension free, $1$-Lipschitz,
  response exponent exactly $1$. Its errors are averaged away.
* The **key operator** is an exponential of an inner product — degree $d$, query weighted,
  response exponent at least $5$, with an order-$1$ lower bound on the damage as soon as the
  noise beats the top-two logit gap.

From that dichotomy follow all the practical consequences: values are free at raw $4$ bits;
keys are free at $8$, badly broken at $5$, annihilated at $4$; a budget-neutral transfer of
bits from values to keys strictly improves quality; and the asymmetric split beats the
uniform one at identical memory.

There is also a prediction, and it is falsifiable. The refutation of the smooth law is not
a technicality — it says the effective key error is *not* $R\cdot 2^{-b}$ with a fixed range
$R$. The most plausible culprit is block-scale quantisation: a block quantiser's step is
$\max|k|/2^{b}$, so the relative error of a *typical* key coordinate carries the outlier
ratio $\max/\mathrm{typ}$ as a prefactor. If that ratio itself grows as the block scale is
re-fitted at lower widths, the effective error falls by far more than a factor of $2$ per
bit — the only known mechanism able to produce a per-bit shrink base above $18$. Any
proposed key-quantisation scheme must exhibit such a base to reproduce the observed cliff.

Which brings us back to the practical bottom line, now with a proof behind it. Do not
compress the two halves of an attention cache equally. Spend your bits where the arg-max
lives.

**Keys at $8$ bits. Values at $4$. About $6$ bits on average, half the memory, and
$+0.142\%$ — which is to say, free.**
