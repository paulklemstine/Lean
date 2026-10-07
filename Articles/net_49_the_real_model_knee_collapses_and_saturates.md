# Twenty-Four Keys Out of Two Thousand: How a Real Language Model Forgets Almost Everything — and Loses Almost Nothing

*A toy theory predicted that a 24-layer language model would need to remember over fifteen hundred tokens to answer faithfully. The real model needed twenty-four. Three short pieces of mathematics explain why.*

---

## The memory problem nobody can avoid

Every time a modern language model writes a word, it looks back. In the mechanism called **attention**, the model compares the current position with every earlier position in its context — every "key" — and builds a weighted average of what it finds there. The weights are probabilities: non-negative numbers that add up to one. A weight near one means "this earlier token matters enormously right now", and a weight near zero means "ignore it".

To make this fast, the model keeps a cache of every earlier token's key and value vectors, the so-called *KV cache*. That cache is the reason long conversations are expensive. At a context of $2048$ tokens, every new word means reading $2048$ rows of memory in every layer. Memory bandwidth, not arithmetic, is often the bottleneck.

So here is a natural question with real money attached:

> **If the model may only look at its $k$ highest-weighted keys, how small can $k$ be before its answers change?**

We call the smallest such $k$ the **knee**, written $k^\ast$. "Answers change" is made precise by a fixed rule: the pruned model must keep at least $98\%$ of the full model's next-token accuracy. We call that the *gate*, $g = 0.98$.

## A toy law, and a real model that ignores it

Before looking at a real network, an earlier series of experiments on small synthetic transformers had produced a tidy empirical rule. The knee grew in proportion to *both* the context length and the depth:

$$k^\ast_{\text{toy}} \approx \frac{d \cdot \text{ctx}}{32},$$

where $d$ is the number of layers. The intuition is that each layer throws away a little of its attention, and those small losses *compound* as information flows up the stack. More layers mean more compounding, so you need more keys to keep the total loss under $2\%$.

Then the same protocol was run on a real pretrained model: a 24-layer, 0.5-billion-parameter open-weight transformer, evaluated on held-out encyclopedia text, in full 32-bit precision. Before any measurement its forward pass was checked against the reference implementation, and the logits agreed to every printed digit. Here is what came out:

| context | full-model accuracy | measured knee $k^\ast$ | toy law $d\cdot\text{ctx}/32$ | ratio |
|---|---|---|---|---|
| 512 | 0.4460 | **16** | 384 | 1/24 |
| 1024 | 0.4612 | **32** | 768 | 1/24 |
| 2048 | 0.4787 | **24** | 1536 | 1/64 |

At a context of $2048$ the toy law asks for $1536$ keys. The real model clears the $98\%$ gate with **twenty-four**. That is $85$ times fewer cache reads than full attention and $64$ times fewer than the toy prediction.

Two things went wrong with the toy law at the same time:

1. **The factor $d$ disappeared.** The ratio of $1/24$ at the two shorter contexts is exactly $1/d$. Whatever compounding across layers the toy models suffered, the real model did not.
2. **The growth with context stalled.** Going from $512$ to $1024$ doubled the knee. Going from $1024$ to $2048$ did *not* double it again. The reported value even went down.

Each surprise has a clean mathematical explanation. One of them also comes with a warning about reading too much into the data.

## Piece one: depth losses add up, they don't multiply away

Suppose layer $l$ keeps a fraction $1-\delta_l$ of what matters, where $\delta_l$ is a number between $0$ and $1$ that we call that layer's **deficit**. If the losses compound, the whole stack keeps

$$R = \prod_{l=1}^{d} (1 - \delta_l).$$

Products are awkward to reason about. The first result says you don't have to, because a product of this kind is tightly squeezed by a *sum*:

> **Depth Sandwich Theorem.** If every deficit lies in $[0,1]$ and $D = \delta_1 + \cdots + \delta_d$ is the total deficit, then
> $$1 - D \;\le\; \prod_{l}(1-\delta_l) \;\le\; \frac{1}{1+D}.$$

The left inequality is the classical Weierstrass product inequality, proved by induction: adding one more layer multiplies the product by $1-\delta$ and subtracts at most $\delta$. The right inequality comes from showing, again by induction, that $R\,(1+D) \le 1$. Adding a layer turns $R(1+D)$ into $(1-\delta)R(1+D) + \delta(1-\delta)R$. Both pieces are bounded using $R \le 1$, and together they stay at most $1$.

Why does this matter? The gate $R \ge g$ becomes a statement about the *sum* of deficits:

- if $D \le 1-g$, the gate is passed (sufficient);
- if the gate is passed, then $g\,D \le 1-g$ (necessary).

With $g = 0.98$, the total deficit must lie between $0.0200$ and $0.0204$. The two bounds are almost the same. **The whole stack has a budget of about $2\%$ of loss, and every layer spends from that one shared account.**

Now take the toy picture, where every one of the $d$ layers has the same heavy-tailed deficit $\delta(k) = c/(c+k)$ at key budget $k$. The total deficit is $d\,c/(c+k)$, and the sandwich pins the knee into a narrow window:

$$\frac{g\,d\,c}{1-g} - c \;\le\; k^\ast \;\le\; \left\lceil \frac{d\,c}{1-g} \right\rceil.$$

So the knee is linear in depth. That is the toy depth multiplier, and now it is derived rather than just observed.

But the real model's attention is *not* like that. When the effective number of keys each layer actually uses is measured, the median layer concentrates on about **10 to 12 keys**, and this number does not change between context $512$ and context $2048$. The sharpest layer uses about **3**. Only the last two layers (the 23rd and 24th of 24, which we call L22 and L23 by counting from zero) spread their attention widely.

The sandwich handles this situation directly:

> **Depth-Multiplier Collapse.** Suppose only $m$ of the layers carry a tail deficit at most $c/(c+k)$, and every other layer becomes lossless once $k \ge k_0$. Then
> $$k^\ast \;\le\; \max\!\Big(k_0,\; \Big\lceil \frac{m\,c}{1-g}\Big\rceil\Big)$$
> **for every depth $d$.**

The proof takes one line once the sandwich is in hand. At that budget the lossless layers contribute zero to $D$, and the $m$ tail layers contribute at most $1-g$ in total. The depth $d$ has dropped out of the bound. In a model with $24$ layers and two diffuse ones, the multiplier falls from $24$ to $2$. That is the measured collapse.

## Piece two: a knee can saturate, but it can never truly decline

The second surprise was that the knee went $16 \to 32 \to 24$. Can a knee go *down* when you give the model more context?

Picture one fixed list of attention weights, sorted from largest to smallest: $w_1 \ge w_2 \ge \cdots > 0$. Looking at a context of length $n$ means looking at the first $n$ of them. The fraction kept by the top $k$ is

$$\text{retained}(n,k) = \frac{w_1 + \cdots + w_{\min(k,n)}}{w_1 + \cdots + w_n}.$$

Lengthening the context only adds weight to the *denominator*, so the retained fraction can only shrink:

> **Context Monotonicity.** For a fixed positive profile, $\text{retained}(n,k)$ is non-increasing in $n$. Consequently the knee $k^\ast(n)$ is non-decreasing in $n$.

So a knee that *strictly declines* is a certificate that the profile itself changed: no single, fixed, context-extending profile can produce it. That is not absurd for a real model, since what it attends to genuinely depends on how much text it has seen. But it means "decline" is a strong claim. And here a careful look at the data deflates it.

The sweeps tested only a grid of budgets. At context $1024$ the budget $16$ failed and $32$ passed, and nothing in between was tried. At context $2048$, $16$ failed and $24$ passed. Monotone retention turns these fail/pass pairs into **brackets**:

$$k^\ast(1024) \in (16, 32], \qquad k^\ast(2048) \in (16, 24].$$

The two brackets overlap. The data are perfectly consistent with $k^\ast(1024) = k^\ast(2048) = 24$, a flat plateau and not a decline. The honest reading is **saturation**.

Is saturation actually expected? Yes, under a natural assumption. Say the sorted attention profile decays at least geometrically, $w_{i+1} \le r\,w_i$ for some fixed $r<1$. Then the mass beyond position $k$ is at most a fraction of order $r^k$ of the total, *no matter how long the context is*. So one fixed budget $B$ clears the gate at every length. A non-decreasing sequence of whole numbers that is bounded above must eventually stop moving:

> **Saturation Theorem.** If the sorted profile decays geometrically, the knee sequence $k^\ast(n)$ is eventually constant.

Compare a heavy power-law tail such as $w_i = i^{-1.1}$. There the knee keeps climbing with the context; in our numerical examples it goes from about $400$ at $512$ to about $1600$ at $2048$. The toy models looked like that. The pretrained model looks geometric.

## Piece three: why choosing *which* keys matters ten times more

The third striking measurement was about *selection*. Instead of keeping the $k$ highest-weighted keys, what if you kept $k$ keys at random? Or just the $k$ most recent ones, a "local window"?

On the real model, random selection at matched budget lost **68 to 82 accuracy points** relative to top-$k$. Across the entire earlier toy programme the corresponding gap had never exceeded about $12$ points. A local window of $256$ recent keys retained only $59.8\%$ of the full accuracy at context $2048$, while the top-$24$ retained $98.7\%$ with one-eighth as many keys.

The mathematics, stated in units of attention *mass* rather than accuracy, explains the shape of this inflation. A uniformly random $k$-subset of $n$ keys captures, on average, exactly the uniform share $k/n$ of the mass. Define the **selection gap** as the top-$k$ retained fraction minus $k/n$. Three facts:

> **Top-$k$ Beats Uniform.** For any positive sorted profile, the top-$k$ fraction is at least $k/n$. (The average of the largest $k$ weights is at least the average of the first $n$, a form of Chebyshev's inequality proved by induction on $n$.)

> **Flat Profiles Have Tiny Gaps.** If every weight lies in a band $[c, M]$, the selection gap is at most $\dfrac{k\,(M-c)}{n\,c}$, which vanishes as the context grows.

> **Knees Force Huge Gaps.** At the knee, the selection gap is at least $g - k^\ast/n$.

At the measured operating point, gate $0.98$ with $24$ keys out of $2048$, the third fact forces a gap above $0.98 - 24/2048 \approx 0.9683$. Any profile whose weights vary by at most a factor of $2$ has a gap below $24/2048 \approx 0.0117$. The real model sits at the first extreme. In short, **a tiny knee and a huge selection gap are the same phenomenon seen from two sides.** If $24$ keys out of $2048$ carry nearly everything, a random pick of $24$ will almost certainly miss them.

## A map of where attention lives

One more bridge connects the per-layer measurements to all of this. A layer's **effective support** is

$$N_{\text{eff}} = \frac{1}{\sum_i p_i^2},$$

the "number of keys it behaves as if it uses". It equals $n$ for perfectly uniform attention and $1$ for attention that is all on one key. The Cauchy–Schwarz inequality gives a sharp limit on what any small set $T$ of keys can carry:

$$\Big(\sum_{i\in T} p_i\Big)^2 \;\le\; \frac{|T|}{N_{\text{eff}}}.$$

Two concrete consequences follow:

- In the most diffuse layer, L22 at context $2048$, the measured $N_{\text{eff}} = 128.5$. So *any* $24$ keys capture at most $\sqrt{24/128.5} \approx 43.2\%$ of that layer's attention mass. At the accuracy knee this layer is throwing away **more than half** of its attention, yet the model's answers barely move.
- In a median layer with $N_{\text{eff}} = 12$, holding $98\%$ of the mass requires $|T| \ge 0.98^2 \times 12 \approx 11.5$, so at least **12** keys. That is the same order as the measured knee, and it does not depend on the context length.

So the knee is set by the concentrated majority of layers. The diffuse tail layers are being truncated hard in mass terms without hurting accuracy, which suggests that much of their spread-out attention is not doing essential work. Whether that is really so is the most interesting open question.

## What it means, and what it doesn't

The practical headline is real: at context $2048$, an oracle that knows which $24$ cache rows to read reaches the $98\%$ accuracy gate while touching **85 times fewer KV rows**, which the experiment reports as a 64-fold reduction in KV bytes per sequence. The broad idea of "keep the heavy hitters" is not new. Cache-eviction and sparse-attention methods have exploited it for years. What is new here are the measured *laws*: the disappearance of the depth multiplier, the plateau shape, the order-of-magnitude jump in the importance of selection, and the layer-by-layer map. There is also a small body of mathematics that says which of these behaviours are structurally forced and which are not.

There are limits as well. This is one model at one size, on one corpus. Two of the knees passed the gate by about half a standard error. The context-$1024$ knee is only known to lie in $(16,32]$. And an oracle is not a policy: an online method has to *guess* which keys will matter. The gap between the oracle and a cheap real selector is the next thing to measure.

The mathematics also tells us what to look for next. If larger models also have geometrically decaying attention, the Saturation Theorem predicts their knees will level off at a plateau. A knee that keeps growing would show that the decay is heavier than geometric. If the gate really depends only on the *sum* of per-layer deficits, then pruning just the two diffuse layers should reproduce the full-model knee. Both are now sharp, falsifiable predictions, and both are cheap to test.

The toy theory said a language model's memory must grow with its depth and its context. The real model kept two dozen keys and moved on.
