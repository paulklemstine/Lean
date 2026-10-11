# The Art of Rounding Badly on Purpose

*Why fixing your mistakes as you go makes a compressed language model twice as good — and the 19th-century matrix identity that explains it*

---

## A model that will not fit

Imagine you want to run a language model on a modest machine — a laptop with 6 GB of memory, say. The model's knowledge lives in its weights: hundreds of millions of real numbers, each normally stored with 16 bits of precision. To make it fit, you want to store each weight with only 4 bits, or even 3. Four bits give you exactly $2^4 = 16$ possible values per weight; three bits give you only $8$.

The obvious way to do this is called **round-to-nearest** (RTN). Lay down a ruler with 16 evenly spaced tick marks covering the range of the weights, and move every weight to its nearest tick. It is simple, fast, and — as anyone who has tried it knows — it can be surprisingly destructive.

In a recent series of experiments on a half-billion-parameter language model (Qwen2.5-0.5B), the damage was measured by the increase in *cross-entropy*, written $\Delta\mathrm{CE}$: how much more "surprised" the compressed model is by real text than the original. A $\Delta\mathrm{CE}$ of $0$ means no harm at all; a few tenths is tolerable; anything above $1$ means the model has lost much of its competence.

The results tell a story in three acts:

| Method | 4 bits | 3 bits |
|---|---|---|
| One ruler per output channel (per-channel RTN) | $+0.788$ | $+9.23$ |
| One ruler per group of 128 weights (grouped RTN) | $+0.318$ | $+2.72$ |
| Grouped rounding **with compensation** (GPTQ) | $+0.151$ | $+1.19$ |

At 3 bits, naive rounding wrecks the model ($+9.23$ — essentially gibberish). Using finer rulers helps a lot. But the final row, which adds an idea called **compensation**, roughly halves the damage again, bringing the 3-bit model back from the dead.

This article is about that last row: what compensation is, why it must work, exactly how much it can help, and what the numbers secretly reveal.

## The idea: if you must make an error, make the others fix it

Suppose you are packing a suitcase to an exact weight limit, and each item has to be swapped for a slightly heavier or lighter standard-size version. If you swap the first item and it comes out $200$ grams too heavy, you would not just carry on swapping the rest independently. You would choose the remaining items to *absorb* that $200$ grams.

Compensation does the same with weights. Process the weights one at a time (or one block at a time). Round the current weight — committing an error you can no longer undo — and then nudge all the *not-yet-rounded* weights so that the layer's output changes as little as possible. Then round the next one, nudge the rest again, and so on.

This is the core of an algorithm called **GPTQ**, published by Frantar and collaborators in 2022, which in turn descends from the "Optimal Brain Surgeon" of Hassibi and Stork from 1993. The algorithm itself is prior art. What is new here is a clean mathematical account of *why* it helps, *exactly how much*, and what that says about the measurements above.

## What "as little as possible" means

A neural network layer takes an input vector $x$ and produces $w \cdot x$ for each row of weights $w$. If we perturb the weights by a small error $\delta$, the output changes by $\delta \cdot x$. Averaging the squared change over a batch of real "calibration" inputs gives

$$
L(\delta) = \delta^{\top} H\, \delta, \qquad H = \frac{1}{N}\sum_{k} x_k x_k^{\top}.
$$

The matrix $H$ is the **curvature**: it tells us which directions of error matter. If two input features tend to fire together, their entries in $H$ are strongly linked, and an error in one weight can be cancelled by an opposite error in the other. That linkage is precisely what compensation exploits.

Now split the weights into two camps: the ones we are rounding right now (error $u$, fixed — we cannot change it), and the ones still free (adjustment $v$, ours to choose). The curvature splits into blocks:

$$
H = \begin{pmatrix} A & B \\ B^{\top} & D \end{pmatrix}.
$$

Here $A$ describes how the rounded weights interact with each other, $D$ how the free weights interact with each other, and $B$ — the crucial piece — how the two camps are coupled.

## The square that completes itself

The central fact is an identity every algebra student meets in a simple form: **completing the square.** Just as $a x^2 + 2bx + c$ can be rewritten as $a(x + b/a)^2 + (c - b^2/a)$, the loss can be rewritten exactly as

$$
L(u, v) \;=\; \underbrace{\big\| D^{-1}B^{\top}u + v \big\|_D^2}_{\text{depends on our choice } v}
\;+\; \underbrace{u^{\top}\big(A - B D^{-1}B^{\top}\big)u}_{\text{the unavoidable part}},
$$

where $\|z\|_D^2 = z^{\top} D z$ is a weighted length, always non-negative.

The matrix $S = A - BD^{-1}B^{\top}$ in the second term is famous: it is the **Schur complement**, named after Issai Schur, who used it in 1917, although the determinant identity behind it is older still. It is the curvature of the rounded weights *after* the free weights have done everything they can.

Everything follows from this one rewriting.

**The best you can do.** The first term is never negative, so no adjustment can push the loss below $u^{\top} S u$. *Compensation has a hard floor, and that floor is the Schur complement.*

**How to get there.** Choose $v^\star = -D^{-1}B^{\top}u$. This makes the first term exactly zero, and the floor is attained.

**There is only one way.** Because $D$ is positive definite, the first term is zero *only* when $v = v^\star$. The optimal correction is unique — there is no other set of nudges that does as well.

**Compensation never hurts.** Plain rounding corresponds to $v = 0$, whose loss is $u^{\top}Au$. Since the floor is the minimum over all $v$, it is at most this. More precisely, the gain is exactly

$$
u^{\top}Au \;-\; u^{\top}Su \;=\; \big\|D^{-1}B^{\top}u\big\|_D^2 .
$$

**When it helps strictly.** That gain is positive *if and only if* $B^{\top}u \neq 0$ — that is, exactly when the rounding error is correlated, through the curvature, with the weights still free to move. If the rounded and free weights never interact, there is nothing to compensate with. In real networks, input features are heavily correlated, so the coupling $B$ is large and the gain is real.

## One weight at a time: the GPTQ formula

Specialise to rounding a single weight $q$ with error $e$. The Schur complement is then just a number, and a classical fact about block matrices says the top-left entry of $H^{-1}$ is exactly $1/S$. So the cost of rounding weight $q$ with perfect compensation is

$$
\text{compensated cost} = \frac{e^2}{[H^{-1}]_{qq}}, \qquad \text{while plain rounding costs} \quad H_{qq}\, e^2 .
$$

This is exactly the quantity that the GPTQ algorithm uses at each step. Since compensation never hurts, comparing the two costs yields a neat inequality, valid for every positive definite matrix:

$$
H_{qq}\,\big[H^{-1}\big]_{qq} \;\ge\; 1 .
$$

The ratio $1/(H_{qq}[H^{-1}]_{qq})$ is precisely the fraction of a single weight's rounding cost that survives compensation. When features are independent, $H$ is diagonal, the product equals $1$, and compensation does nothing. The more correlated the features, the larger the product, and the more the error can be absorbed.

## Two more guarantees

**Wider windows never hurt.** Real implementations do not let every remaining weight participate in every correction; they work in blocks of columns aligned with the groups of 128 that share a ruler. Is a restricted window a loss? Only in one direction: allowing more free weights to participate can never increase the floor. Freezing some free weights at zero is just one particular (generally suboptimal) choice in the larger problem.

**The lever does not care about scale.** Going from 4 to 3 bits roughly doubles the spacing of the ruler. If that simply multiplied every rounding error by the same factor $t$, both the compensated and the uncompensated losses would be multiplied by $t^2$, and their *ratio* would not budge. The compensation lever — how many times better GPTQ is than plain rounding — is invariant under rescaling the error.

## What the numbers say

With the theory in hand, the measurements become a laboratory notebook to check against.

**The headline lever.** At 4 bits, grouped rounding gives $0.318$ and GPTQ gives $0.1512$: a ratio of about $2.10$. Compensation cancels a little over half of the damage.

**A pre-registered bar, honestly assessed.** Before the run, the experiment set a target: GPTQ at 4 bits should reach $\Delta\mathrm{CE} \le 0.15$. The measurement, $0.1512$, was originally reported as meeting the bar "at the boundary." In exact arithmetic it does not: $0.1512$ exceeds $0.15$ by $0.0012$. It is a near miss, and the honest verdict is that the bar was missed. A second, stricter target of $0.14$ was missed clearly.

**The tail is real but small.** Earlier work had suggested the final two of the model's 24 transformer layers carry a disproportionate share of the quantization damage. Quantizing only layers 0–21 with GPTQ gives $0.1235$; quantizing all layers gives $0.1512$. The last two layers therefore add $0.0277$ — about $18\%$ of the total, strictly between one sixth and one fifth, and well short of the predicted "more than a quarter." Compensation seems to have shrunk the tail's outsized cost.

There is a crisp algebraic criterion for when this can happen. Suppose the core and tail have plain-rounding costs $a$ and $b$, and compensation removes amounts $g_a$ and $g_b$. Then the tail's share of the total *drops* if and only if

$$
\frac{g_a}{a} < \frac{g_b}{b},
$$

that is, if and only if compensation helps the tail *proportionally more* than the core. The measured 18% is therefore evidence — testable by a single additional run of plain rounding on the core — that the final layers' errors are especially well correlated with their free weights.

**The ladder of levers.** Look at the table as a ladder:

- At 4 bits: $0.788 \to 0.318 \to 0.151$ (grouping gives about $2.5\times$, compensation about $2.1\times$).
- At 3 bits: $9.23 \to 2.72 \to 1.19$ (grouping about $3.4\times$, compensation about $2.3\times$).

Each structural lever multiplies the previous floor down. The combined lever is more than $5\times$ at 4 bits and more than $7.7\times$ at 3 bits.

## A detective's clue: the lever drifts

Here is where the scale-invariance theorem earns its keep. If going from 4 to 3 bits merely scaled every error by the same factor, the compensation lever would be identical at both bit widths. It is not: $2.10$ at 4 bits, $2.28$ at 3 bits — a drift of about $8\%$.

That small number carries a definite logical consequence: **there is no single quadratic model, with any curvature whatsoever, in which the 3-bit error vector is merely a rescaled copy of the 4-bit one and which reproduces both measured pairs.** The drift must come from a change in the *shape* of the error — which weights get rounded up versus down, how clipping at the extremes of each group behaves — or from the true loss bending away from its quadratic approximation.

The grouping lever drifts much more, by more than $35\%$ (from about $2.5$ to $3.4$). That too makes sense: grouping is fundamentally a shape-changing operation. By giving each block of 128 weights its own ruler, it stops a single outlier from stretching the ruler for everyone, so its benefit grows as the ruler gets coarser. Compensation, by contrast, is a linear correction applied after rounding, and its lever is nearly — but measurably not quite — scale-free.

## What it means on a real machine

For a 6 GB machine, the practical conclusions are blunt:

- Per-channel rounding is unusable below 6 bits (at 6 bits it costs only $+0.035$, but at 4 bits it costs $+0.788$).
- Grouped rounding is viable at 4 bits ($+0.32$).
- Grouped GPTQ is comfortable at 4 bits ($+0.15$) and *survivable* at 3 bits ($+1.19$) — a regime where naive rounding produces nonsense.

The experiment was deliberately honest about its limits: one model, a 512-token context, 16 calibration sequences, and no column reordering ("act-order"). The calibration data came only from the training side, and the baseline numbers were reproduced exactly before any comparison.

Getting there involved catching three silent bugs that would have quietly corrupted the science: hooks attached to container modules rather than the actual linear layers, a broadcasting error in per-column scales, and a Cholesky factorization that failed because partially quantized activations made the curvature numerically indefinite (fixed by a damping term that escalates on failure). A tiny regression test now guards the implementation: on a single matrix, GPTQ must beat plain rounding on the layer-output error. The theorem that compensation never hurts guarantees that each individual correction step cannot make things worse for the error it is correcting; because those corrections also shift the weights that are rounded later, the end-to-end win is something to check, and the test checks it.

## What comes next

The Schur-complement picture suggests sharp, testable questions.

- **Can the lever be predicted from the curvature alone?** Averaged over random rounding errors, per-column compensation costs scale like $1/[H^{-1}]_{qq}$ while plain rounding costs scale like $H_{qq}$, so the ratio $\sum_q 1/[H^{-1}]_{qq} \big/ \sum_q H_{qq}$ is a natural candidate predictor — up to corrections from the order in which columns are processed.
- **Does order matter, and which order is best?** Iterated Schur complements obey a "quotient" rule that should make the total cost of sequential compensation telescope into a sum of per-column pivot costs. Processing columns with the largest curvature first ("act-order") is the natural candidate optimum.
- **Mixed precision for the tail.** Keeping the last two layers at higher precision is cheap and directly targets that 18%.
- **Scale.** Does the $2\times$ lever survive on a model three times larger?

## The moral

Rounding is irreversible: once a weight is snapped to a grid point, that information is gone. But the *consequences* of an error are not fixed — they depend on what you do next. The completion-of-the-square identity makes this precise. Every rounding error has an unavoidable part, the Schur complement, and an avoidable part, which a unique correction of the remaining weights removes entirely. The more the weights talk to each other, the bigger the avoidable part, and the more there is to gain.

A century-old piece of matrix algebra, in other words, is the reason a 3-bit language model can still speak.
