# The Half of Memory You Can Throw Away — and the Half You Can't

## A four-order-of-magnitude asymmetry hiding inside every language model

Every large language model that answers you word by word is dragging a suitcase
behind it. The suitcase is called the *KV cache*, and it holds, for every word
the model has already read, two vectors: a **key** and a **value**. The keys are
the labels on the model's filing cabinet; the values are the contents of the
folders. When the model generates its next word, it forms a **query**, compares
that query against every key, decides which folders matter, and then reads out a
weighted blend of the values.

The suitcase is heavy. For long conversations it can dwarf the model's own
weights, and it is the single biggest reason serving a chatbot at scale is
expensive. So engineers do the obvious thing: they compress it. Instead of
storing each number in 16 bits, store it in 4. The suitcase shrinks fourfold.
Everybody wins.

Except sometimes the model stops speaking English.

This article is about a measurement that pinned down *exactly where* the damage
comes from, and about the mathematics that explains why the answer had to be
what it was. The short version: **the entire catastrophe lives in the keys.**
Compressing the values to 4 bits is essentially free. Compressing the keys to 4
bits destroys the model. Not "degrades" — destroys.

---

## The numbers

The experiment is simple. Take a model, take a held-out slice of text, and
measure *perplexity*: roughly, how surprised the model is by the text it is
reading. Lower is better. A healthy model on this slice scores about $7.11$.
Now compress the cache four different ways and re-measure.

| what was compressed to 4 bits | perplexity | change vs. uncompressed |
|---|---|---|
| keys **and** values (scale-and-offset format) | $3{,}158.07$ | $+44{,}322\%$ |
| keys **and** values (nonuniform codebook) | $1{,}627.35$ | $+22{,}790\%$ |
| **keys only** (values left at full precision) | $2{,}537.80$ | $+35{,}597\%$ |
| **values only** (keys left at full precision) | $7.1211$ | $+0.166\%$ |

Read the last two rows again. Quantising the values alone costs one sixth of one
percent — statistical noise. Quantising the keys alone multiplies the perplexity
by roughly $357$. The ratio between the two damages is about $214{,}000$ to one.

And note what the first two rows say about the standard engineering reflex. When
a 4-bit format hurts, you reach for a *better* 4-bit format: add a per-block
offset so the grid can shift, or replace the uniform grid with a nonuniform
codebook tuned to the data distribution. Neither helped. The scale-plus-offset
format was, if anything, marginally *worse* than the crude uniform one. Three
different 4-bit representations, three collapses.

That pattern — richer formats not helping — is the fingerprint of a structural
obstruction rather than an engineering bug. So the question becomes: can we
prove it?

---

## Why values are free: attention is an average

Here is the whole argument for the values, and it fits in a paragraph.

Attention produces its output as
$$A(s,v) \;=\; \sum_{i} \sigma(s)_i \, v_i, \qquad \sigma(s)_i = \frac{e^{s_i}}{\sum_j e^{s_j}},$$
where $s_i$ is the score (or *logit*) of cached position $i$ and $v_i$ is its
value. The softmax weights $\sigma(s)_i$ are positive and sum to $1$. So the
output is a **convex combination** — a weighted average — of the values.

Now perturb every value by at most $\delta$. Then

$$\Big|\sum_i \sigma(s)_i v_i - \sum_i \sigma(s)_i w_i\Big| \;\le\; \sum_i \sigma(s)_i |v_i - w_i| \;\le\; \delta \sum_i \sigma(s)_i \;=\; \delta.$$

That's it. The output moves by at most $\delta$. This is a *theorem*, and its
strength lies in what it does **not** mention: it holds for every query, every
score vector, every context length, every head dimension, every layer. Averaging
never amplifies. And the constant $1$ cannot be improved — shifting every value
by exactly $\delta$ shifts the output by exactly $\delta$ — but it also never
degrades. Value error is local, linear, benign.

There is a corollary that kills half of the format debate on the spot: any value
quantiser whatsoever, of any codebook size and any shape, that moves each stored
number by at most $\delta$, moves the read-out by at most $\delta$. **Resolution
is the only property of a value codebook that matters.**

---

## Why keys are lethal: the query rescales your ruler

Keys do not enter the average. They enter the *scores*, through the inner
product $s_i = \langle q, k_i \rangle$, and the scores then pass through an
exponential.

Two things go wrong, and they compound.

**First: the query amplifies.** Perturb every key coordinate by at most
$\delta_K$. Then the logit moves by up to

$$|s_i - s_i'| \;\le\; \|q\|_1 \,\delta_K,$$

where $\|q\|_1 = \sum_t |q_t|$ is the query's total absolute size. And that
factor is really attained: with an all-ones query in dimension $d$, a
$\delta$-perturbation of a key moves its logit by exactly $d\delta$. In a real
model $\|q\|_1$ can be in the tens or hundreds. The tiny error you carefully
budgeted at the storage layer arrives at the softmax multiplied by a large
number that you do not control.

**Second: the softmax is a selection device, not a smoothing device.** Its job
is to *pick*. Give it a logit gap of $2$ and it already commits: the read-out
crosses $3/4$ instead of the tie value $1/2$. So an $O(1)$ logit error is an
$O(1)$ output error, full stop.

Put the two together and you get a statement with no wiggle room:

> **The cliff.** For *every* key resolution $\delta > 0$ — no matter how fine —
> there exist a query and two key caches within $\delta$ of each other whose
> attention read-outs differ by at least $1/4$.

The construction is embarrassingly small: two cached positions, one-dimensional
keys $\delta$ and $0$ versus $0$ and $0$, and the query $q = 2/\delta$. The
exact scores are $(2,0)$; the perturbed ones are $(0,0)$. One attends decisively
to the first position, the other flips a coin.

The moral: the key path has **no Lipschitz constant at all**. There is no
constant $C$ with "key error $\delta$ costs at most $C\delta$", because the
query can always rescale the ruler. And so the measured damage ratio of
$214{,}000$ is not a ceiling — it is whatever this particular text slice
happened to produce. For any factor $M$ you name, there is a cache resolution at
which the worst-case key damage exceeds $M$ times that resolution, while the
worst-case value damage is still at most the resolution itself. **The ratio
between the two halves of the cache is unbounded.**

---

## No clever format can save the keys

The most striking consequence concerns the format hunt. Suppose you invent a
brand-new 4-bit key format. It may use per-block scales, offsets, learned
nonuniform codepoints, rotations, anything at all — we assume *nothing* about
its internal structure. All we use is that each block of keys is stored using a
codebook with at most $N$ entries.

Then, by the pigeonhole principle applied to the $N+1$ equally spaced probes
$0, \tfrac1N, \tfrac2N, \dots, 1$, two of them must receive the same code. Call
them $a \ne b$, separated by at least $1/N$ and **indistinguishable after
storage**. Now pick the query $q = 2/(a-b)$, whose size is at most $2N$. The
exact cache gives a logit gap of exactly $2$, hence a read-out above $3/4$; the
stored cache gives two identical logits, hence exactly $1/2$. The formats differ
by at least $1/4$ in output.

> **No codebook rescues the keys.** For any key quantiser whose per-block
> codebook has at most $N$ entries, there are two keys at distance $\ge 1/N$
> that it identifies, and a query of size $\le 2N$ for which the exact and
> quantised read-outs differ by at least $1/4$.

Nothing but the *cardinality* of the codebook enters. Scales, offsets, and
nonuniform codepoints are invisible to the argument. That is precisely why the
scale-plus-offset format came out marginally worse than the crude uniform grid
and the nonuniform codebook came out only relatively less catastrophic: they
were all competing on the wrong axis. Sixteen codes is sixteen codes.

And in case one hopes to escape by normalising: rescaling every key by $c$ and
the query by $1/c$ leaves the logits — and hence the entire attention output —
completely unchanged, while multiplying the key range by $c$ and dividing the
query size by $c$. The governing quantity $\|q\|_1 \cdot R / 2^b$ (query size
times key range divided by grid points) is **invariant**. No normalisation
scheme can buy a single key bit.

---

## Depth is the multiplier

One perturbation of $1/4$ in one head would not annihilate a model. The reason
the perplexity reaches four digits is that the key path *compounds*.

Model the two paths as recursions in the layer index $\ell$. The key path is
amplifying: each layer multiplies the perturbation by some factor $\gamma > 1$,
so $e_{\ell+1} \ge \gamma\, e_\ell$. The value path is averaging: each layer
re-mixes the perturbation, so $e_{\ell+1} \le \max(\varepsilon, e_\ell)$.

These two recursions have opposite fates, and a two-line induction each settles
them.

- **Key error is unbounded in depth.** From $e_L \ge \gamma^L e_0$ and
  $\gamma > 1$, for any threshold $M$ there is a depth $L$ with $e_L \ge M$. An
  error invisible in a single head passes every bound in a deep stack.
- **Value error never leaves its band.** From $e_0 \le \varepsilon$ and
  $e_{\ell+1} \le \max(\varepsilon, e_\ell)$, we get $e_L \le \varepsilon$ for
  *every* $L$. Depth does nothing.

So at sufficient depth the key error exceeds the value error by any prescribed
factor, while the value error is still sitting exactly where it started. That is
the four-order-of-magnitude gap, generated by nothing more exotic than the
difference between multiplying and averaging.

---

## The exact shape of the cliff

We can go further than "unbounded" and write down the functional form. If the
key error induces a logit error of at most $\eta$, then every attention weight
is multiplied by a factor in $[e^{-2\eta}, e^{2\eta}]$, and consequently the
whole attention distribution moves by at most $e^{2\eta} - 1$ in total variation.
With values bounded by $B$ and quantised at resolution $\delta_V$, the complete
budget is

$$\big| A_{\text{quantised}} - A_{\text{exact}} \big| \;\le\; \big(e^{2\eta} - 1\big)\, B \;+\; \delta_V, \qquad \eta = \|q\|_1\,\delta_K.$$

Stare at the two terms. **The key term is exponential; the value term is
linear.** Halving the value resolution halves the value damage. Halving the key
resolution *squares* the key tolerance factor. That single asymmetry of
functional form is the entire experiment, written as a formula.

---

## What to do on Monday morning

If the keys are exponentially sensitive and the values are linearly benign, then
the bits should not be split evenly. Model the guaranteed damage of a $b_K$-bit
key cache and a $b_V$-bit value cache as

$$D(b_K, b_V) \;=\; \frac{A}{2^{b_K}} + \frac{1}{2^{b_V}},$$

where $A$ is the key amplification factor. Then the arithmetic is exact and the
conclusion is sharp:

- **Move a bit to the keys** — transferring one bit from the value cache to the
  key cache strictly reduces damage whenever $2^{b_K} < A\cdot 2^{b_V}$;
- **and stop when you shouldn't** — once $A \cdot 2^{b_V} \le 2^{b_K}$, moving
  another bit no longer helps. The equilibrium is exactly where the amplified
  key term balances the value term.
- At the measured amplification scale $A = 16$ with a total budget of $12$ bits,
  the **unique** optimum is $b_K = 8$, $b_V = 4$. Every other split of the same
  twelve bits is strictly worse.
- In particular, at the same average of $6$ bits per cache element, the
  role-split allocation $K8/V4$ beats the uniform $K6/V6$ by more than a factor
  of two in guaranteed damage ($1/8$ against $17/64$), and beats the reversed
  split $K4/V8$ by more than a factor of **eight**.

A companion criterion says *how many* key bits are enough, and it is
reassuringly logarithmic. A $b$-bit key grid of range $R$ preserves every
attention decision whose logit margin exceeds $2\|q\|_1 R / 2^b$; so $b$ bits
suffice for all decisions of margin $m$ as soon as $2^b > 2\|q\|_1 R/m$. Each
extra key bit *doubles* the query norm you can tolerate. At a reference scale of
$\|q\|_1 = 64$, key range $R = 1$, margin $m = 1$, eight bits leave a factor-two
cushion. Four bits do not — and the failure is not asymptotic hand-waving: there
is an explicit two-position cache at that same scale whose exact scores have a
strict winner with margin $2$, and whose 4-bit rounding produces a dead tie. One
collapsed decision, and the softmax is guessing.

**The deployment rule:** *keys get at least 8 bits; values can take 4.* Since
$K8/V16$ costs $+0.09\%$ and $K16/V4$ costs $+0.17\%$ — both free — the combined
$K8/V4$, averaging about six bits per element, should also be free. That
combined arm is the immediate experiment to run.

---

## The honest limits

Three collapsed key formats triangulate the claim, but they share one
implementation family; the measurement itself does not prove fundamentality —
the theorems above are what carry that weight, and they are about the attention
functional, not about any one codebase. The measurement is a single text slice,
a single model, a single context length, and per-arm error bars were not
captured. The combined $K8/V4$ cell has not yet been run.

But the shape of the result is not in doubt, because it does not depend on the
measurement. Attention averages its values and *selects* on its keys. Averaging
forgives; selection does not. When you compress a model's memory, compress the
folders, not the labels.
