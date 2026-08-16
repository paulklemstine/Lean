# How Wide Must Attention Be? The Geometry Behind a 2× Speedup

## A budget problem hiding inside every language model

Imagine you are given a bag of $512$ numbered marbles. Each marble $i$ carries a weight $p_i \ge 0$, and the weights add up to one: $\sum_{i=1}^{512} p_i = 1$. You are allowed to keep only $k$ of them. Which do you keep, and how much weight do you save?

The answer to the first question is embarrassingly easy: keep the heaviest $k$. The answer to the second is where all the interesting mathematics lives, because it depends on the *shape* of the weights — whether they are spread evenly across the bag or piled onto a handful of marbles.

This toy problem is not a toy. It is exactly the computation performed, billions of times per second, inside the attention mechanism of a modern language model. When such a model reads a passage of text, each position produces a probability distribution over all the earlier positions — a row of weights $p_1, \dots, p_n$ summing to one — describing how much it "attends" to each of them. The expensive part of the model is that every one of the $n$ positions must consult every one of the $n$ candidates: a cost proportional to $n^2$.

The obvious economy is **top-$k$ attention**: instead of consulting everything, consult only the $k$ heaviest entries of each row. The cost drops from $n \cdot n$ to $n \cdot k$, a speedup of exactly $n/k$. The obvious risk is that the model gets worse. So the practical question becomes a single number:

> What is the smallest width $k$ at which the model's accuracy still clears a fixed bar?

Call that number the **knee**, written $k^{*}$. Everything below is about the mathematics that governs it — and about a measurement, on a $32$-layer transformer reading $512$ tokens of context, that pinned the knee at exactly $k^{*} = 256$, twice, at two independent random seeds.

## Two questions, two directions

The knee is squeezed between two very different kinds of argument, and the pleasant discovery is that both of them are elementary.

**From below: you cannot be too greedy.** Define the *effective support* of an attention row by
$$\mathrm{eff}(p) = \frac{1}{\sum_i p_i^2}.$$
This is a classical "how many things are really in play?" statistic — physicists call it a participation ratio. If the weight is spread uniformly over $n$ keys, $\mathrm{eff} = n$; if it is concentrated on a single key, $\mathrm{eff} = 1$.

Now let $M(k)$ denote the mass captured by the best possible width-$k$ selection — the sum of the $k$ largest weights. Cauchy–Schwarz applied to the chosen set $S$ gives
$$M(k)^2 \le |S| \sum_{i \in S} p_i^2 \le k \sum_i p_i^2,$$
and therefore the **concentration floor**
$$k \ge \tau^2 \cdot \mathrm{eff}(p) \quad\text{whenever } M(k) \ge \tau .$$
A row cannot be summarised by fewer keys than its own effective support allows. In the measured cell, the effective support came out at $\mathrm{eff} \approx 216.92$ and the top-$256$ mass at $0.922$. Plugging $\tau = 0.92$ into the floor forces $k > 183$: no width below $184$ could possibly have reached that mass, whatever selection rule you use. That is an *independent, purely mathematical* corroboration of a measured knee of $256$ — and a flat refutation of any claim that a width near $96$ would do.

Is the exponent $2$ in $\tau^2$ an artefact of a lazy proof? No. Take the five-key profile $(\tfrac12, \tfrac18, \tfrac18, \tfrac18, \tfrac18)$. Its effective support is $16/5 = 3.2$, and a single key already captures mass $\tau = \tfrac12$. The proved floor demands $k \ge \tau^2 \mathrm{eff} = 0.8$, which is satisfied; the tempting "improvement" $k \ge \tau \cdot \mathrm{eff} = 1.6$ would be *false*. The square is real.

**From above: tails are forgiving.** Suppose the sorted weights decay like a power law, $p_{(i)} \le c \, i^{-\alpha}$ with $\alpha > 1$. Then a discrete tangent-line estimate — Bernoulli's inequality $1 + \alpha s \le (1+s)^{\alpha}$ in disguise — sums the tail and yields
$$M(k) \ \ge\ 1 - \frac{c}{\alpha - 1} \, k^{1-\alpha},$$
so the width needed to reach mass $\tau$ never exceeds
$$k^{*} \ \le\ \Big(\frac{c}{(\alpha-1)(1-\tau)}\Big)^{1/(\alpha-1)}.$$
For $\alpha = 2$ this is the clean bound $k^{*} \le c/(1-\tau)$. Numbers: an inverse-square tail with constant $c = 20$ certifies top-$256$ mass at least $0.92$ at context $512$; so does the much heavier tail $\alpha = 3/2$ with $c = 0.6$. The measured value was $0.922$. Heavy tails do not destroy the story; they only change the rate.

Put the two together and the knee is *sandwiched*: concentration bounds it from below, tail decay from above. The measurement lands inside the sandwich.

## Is top-$k$ actually doing anything?

Here is the control experiment that any honest sparsification claim owes its reader. Instead of the $k$ heaviest keys, pick $k$ keys *uniformly at random*. If the model does just as well, then "top-$k$" was never the point — the point was merely "look at $k$ things".

The mathematics settles the mass-level version of this question exactly. Averaging the captured mass over all $\binom{n}{k}$ subsets of size $k$, each key $i$ appears in $\binom{n-1}{k-1}$ of them, so
$$\mathbb{E}\big[\textstyle\sum_{i \in R} p_i\big] = \frac{\binom{n-1}{k-1}}{\binom{n}{k}} \sum_i p_i = \frac{k}{n}.$$
The random control captures exactly the fraction $k/n$ — no more, no less, whatever the attention row looks like. This makes the **selection gap**
$$G(k) = M(k) - \frac{k}{n}$$
the right object to study: it is precisely the advantage that *choosing well* buys over *choosing blind*. At the measured cell, $M(256) = 0.922$ against a random baseline of $256/512 = 0.5$: a mass gap of at least $0.42$. In accuracy terms, the repaired control showed gaps of $+2.6$ at $k = 256$ and $+1.7$ at $k = 384$. Selection matters, and its importance dilutes as the budget widens — exactly as it must, since at $k = n$ both strategies select everything.

## The shape of the gap: an exchange argument

Why should the gap dilute *smoothly*? Because the mass curve $M$ is **concave**, and the proof is a single move.

Let $S$ be an optimal set of size at most $k+2$ and $T$ an optimal set of size at most $k$. Either $S$ already fits inside width $k+1$ — in which case both $M(k+2)$ and $M(k)$ are already at most $M(k+1)$ and we are done — or $S$ is strictly larger than $T$, so $S$ contains some key $x$ that $T$ misses. Move it: replace the pair $(S, T)$ by $(S \setminus \{x\},\ T \cup \{x\})$. Both new sets have size at most $k+1$, and their total mass is unchanged. Hence
$$M(k+2) + M(k) \ \le\ 2\, M(k+1).$$
That is concavity of a sequence, obtained by one exchange and no analysis at all.

Subtracting the straight line $k/n$ preserves concavity, so the selection gap $G$ is a concave sequence too. Concave sequences have antitone increments: once the curve starts to fall, it never rises again. This makes $G$ **unimodal** — for any $i \le j \le m$,
$$\min\big(G(i), G(m)\big) \le G(j).$$
And since $G(0) = 0$ and $G(n) = 0$ (at full width the "best" and the "random" selections coincide), unimodality hands back, for free, the fact that $G(k) \ge 0$ for every $k$: top-$k$ never loses to the random control. A fact first proved by double counting is re-derived from pure shape.

Concavity also makes a **falsifiable prediction**. A concave sequence cannot decay slower later than earlier, so the drop from $256$ to $384$ caps the drop from $384$ to $512$. With measured gaps $2.6$ and $1.7$, the chord comparison forces the gap at full width to be at most $+0.8$. A larger measured value would refute concavity of the accuracy gap — and the mass gap's concavity is unconditional.

## Where the peak sits, and what its height means

If the gap rises and then falls, it has a top. Where?

Say a key is **above average** if $p_i > 1/n$, and let $A$ be the set of such keys. Then the gap is maximised at exactly $k = |A|$, and its height there is
$$G(|A|) = \sum_i \Big(p_i - \frac{1}{n}\Big)^{+} = \tfrac12 \sum_i \Big| p_i - \frac{1}{n} \Big| = \mathrm{TV}(p, \text{uniform}),$$
the total-variation distance from the attention row to the uniform row. (The two expressions agree because the signed deviations sum to zero, so the positive part carries exactly half the $\ell^1$ mass.)

This is a satisfying answer. The best possible advantage of *any* top-$k$ selection over *any* random control, at *any* width, is a single classical statistical distance: how far the attention is from paying equal attention to everything. It also runs backwards as a second lower bound on the knee, complementary to the concentration floor:
$$k \ \ge\ n\big(\tau - \mathrm{TV}(p, \text{uniform})\big).$$
And it converts the measurement into a statement about distance: top-$256$ mass $0.922$ at $n = 512$ forces $\mathrm{TV} \ge 0.422$. The measured attention rows are, quantitatively, far from uniform.

One more transfer: if accuracy is any concave nondecreasing function of captured mass, the whole picture carries over — the accuracy-versus-width curve is itself concave, unimodal, with diminishing returns per unit of width; and if accuracy is $L$-Lipschitz in captured mass, then the accuracy gap against the random control is at most $L \cdot \mathrm{TV}$, uniformly in $k$. The single distance controls everything.

## Reading a knee off a grid — and reproducing it

A sweep measures accuracy at finitely many widths. Given that the pass criterion is upward closed (widening a passing budget still passes), the knee is the least passing width, and a fail at $a$ together with a pass at $b$ pins it to the half-open interval $(a, b]$. In the round in question the sweep grid was
$$\{96, 128, 160, 192, 224, 240, 256, 288, 320, 384, 512\},$$
width $240$ failed (accuracy ratio $0.978$ against a bar of $0.98$) and width $256$ passed ($0.982$), giving the bracket $(240, 256]$.

Now the pleasant combinatorial remark: that bracket contains exactly one grid point, namely $256$. So two seeds that both fail at $240$ and both pass at $256$ *must* report the same knee. "Exact reproduction" is, at this resolution, a theorem about the grid rather than a coincidence about the runs — and, correspondingly, honesty demands the residual uncertainty be stated. With local grid ratio $\rho = 256/240 = 16/15$, a knee reported as $256$ carries at most $(1 - 1/\rho)\cdot 256 = 16$ of absolute uncertainty, and two seeds bracketed together differ by strictly less than $16$. That bound is attained: a step-shaped accuracy curve that fails at $a$ and passes at $b$ can have its true knee anywhere down at $a+1$.

## The depth law and the payoff

Sweeping the knee across model depths $d$ produced a concave fit,
$$k^{*}(d) \approx 24.7 \, d^{2/3},$$
against two rival hypotheses: an affine law $8d + 32$ and a product law $k^{*} = \mathrm{ctx}$. At $d = 32$ the concave law predicts $24.7 \cdot 32^{2/3} \in (248.9, 249)$ — within $3\%$ of the measured $256$. The affine law predicts $288$, over-predicting by more than $11\%$; and this is not bad luck, since an affine model calibrated on shallower rungs of a genuinely concave curve *must* over-predict when extrapolated outward. The product law predicts $512$, wrong by a factor of two.

The $2/3$ exponent has a clean signature: doubling the depth should multiply the knee by $2^{2/3} \in (1.58, 1.59)$, comfortably below $2$, so the law is sub-linear and subadditive in depth. The three measured per-doubling ratios were $1.50$, $1.58$, $1.68$; their product $3.9816$ implies an empirical exponent $a$ with $2^{3a} = 3.9816$, hence $0.6 < a < 2/3$ — sub-linear, and just under the fitted envelope.

And the payoff is arithmetic. Top-$k$ causal attention at context $\mathrm{ctx}$ costs $\mathrm{ctx} \cdot k$, so the speedup over full attention is $\mathrm{ctx}/k$: the product-law prescription $k = \mathrm{ctx}$ gives a speedup of exactly $1.000$ — no saving at all — while the measured knee gives
$$\frac{512}{256} = 2.0\times,$$
reproduced at both seeds. Any knee at most half the context is worth at least a doubling.

## What the mathematics is for

None of the measured numbers can be proved; they are measurements. What can be proved — and is — are the structural laws that make the protocol *mean* something: that top-$k$ is optimal, that the random control's expected mass is exactly $k/n$, that the gap is concave, unimodal, nonnegative, peaked at the above-average keys with height equal to a total-variation distance, that concentration floors and tail ceilings sandwich the knee, that an exactly-reproducing knee on a coarse grid is a grid theorem with a stated resolution, and that a concave depth law forces affine extrapolation to over-predict.

That is the useful division of labour. The experiment supplies the numbers; the mathematics supplies the reasons the numbers can be trusted, the shape they must have, and the next prediction that could knock the whole picture down.
