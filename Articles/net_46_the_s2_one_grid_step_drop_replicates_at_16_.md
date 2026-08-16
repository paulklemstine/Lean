# The Knee That Moved: What One Grid Step Can and Cannot Prove

## A number that costs four hours

Somewhere in a machine's memory a small language model is reading text, and each word it reads must be compared against every word that came before. That comparison — *attention* — is the engine of modern language models, and it is quadratic: double the amount of text the model can see at once, and the work quadruples.

The obvious fix is to be selective. Rather than let every position attend to all $\mathrm{ctx}$ predecessors, let it attend only to the $k$ most promising ones. The question is: how small can $k$ be before the model gets noticeably worse?

Call the answer the **knee**. Fix a quality bar — say, $98\%$ of the accuracy the unrestricted model achieves on held-out text — and define

$$k^{*} = \text{the smallest budget } k \text{ at which the pruned model still clears the bar.}$$

Each measurement of $k^{*}$ costs hours of training. So you sweep a coarse grid of candidate budgets — $\dots, 160, 192, 224, 256, \dots$, in steps of $s = 32$ — and report the first one that passes.

Over a series of experiments at depth $d = 4$, a beautifully simple pattern emerged. Across five doublings of the context window, $\mathrm{ctx} = 128, 256, 512, 1024, 2048$, the measured knee at the first random seed tracked a clean product law:

$$k^{*} = \frac{d \cdot \mathrm{ctx}}{32} \;=\; 16, \,32,\, 64,\, 128,\, 256 .$$

Five doublings, five exact hits. That is the kind of pattern that gets called a scaling law.

Then someone ran a second random seed.

## The drop

At $\mathrm{ctx} = 1024$ the second seed's knee came in at $96$ — one grid step below the predicted $128$. Interesting, possibly noise. So the experiment was repeated at sixteen times the base context, $\mathrm{ctx} = 2048$, where the law predicts $256$. The sweep read:

| $k$ | 96 | 128 | 160 | 192 | **224** | 256 | 288 | 384 |
|---|---|---|---|---|---|---|---|---|
| retained | 0.956 | 0.965 | 0.971 | 0.978 | **0.982** | 0.986 | 0.987 | 0.992 |

The bar sits at $0.980$. The knee is $224$ — again exactly one grid step below the prediction. Two cells, two drops, same size. The natural headline writes itself: *the second-seed drop replicates; the deviation is systematic.*

This article is about what happens when you take that headline seriously enough to ask what it would actually mean — and find that, on the programme's own numbers, it cannot mean what it says.

## Turning a grid reading into a window

Start with the single most useful observation, so simple it is easy to skip.

A sweep never measures the knee. It measures a *bracket*. If the sweep reports $k$ and the previously swept budget was $p$, then all you know is that the true, continuous crossing point $\kappa$ — the real number below which the curve never reaches the bar and at which it does — satisfies

$$p < \kappa \le k .$$

**The Window Lemma.** *Let $C$ be a monotone retained-quality curve, let $b$ be the bar, and suppose a sweep on a finite grid reports knee $k$, with $p$ a swept budget below $k$. If $\kappa$ is any real number with $b \le C(\kappa)$ and $C(x) < b$ for all $x < \kappa$, then $p < \kappa \le k$.*

The proof is two lines. If $\kappa \le p$, monotonicity gives $b \le C(\kappa) \le C(p)$, so $p$ would have cleared the bar and the sweep would have stopped earlier. If $\kappa > k$, then $C(k) < b$ by the defining property of $\kappa$, contradicting the fact that $k$ passed. Notice what is *not* used: no continuity, no differentiability, no model of the curve's shape. Only order.

So the reading "$k^{*} = 224$" is shorthand for "$\kappa \in (192, 224]$" — a window of width $32$.

## Windows on the amplitude

Now let the law speak. The product law says the knee grows in proportion to the context. Write $\mathrm{ctx} = 128 \cdot 2^{i}$ for the rung index $i = 0, 1, 2, 3, 4$; then the law's prediction is $A \cdot 2^{i}$, where $A$ is a single fitted constant — the *amplitude*, which the product law sets to $A = 16$.

Divide the Window Lemma's bracket by $2^{i}$, and each measured rung becomes a window on the amplitude:

| seed | $\mathrm{ctx}$ | rung $i$ | previous budget | reported knee | amplitude window |
|---|---|---|---|---|---|
| 1 | 1024 | 3 | 96 | 128 | $(12, 16]$ |
| 1 | 2048 | 4 | 224 | 256 | $(14, 16]$ |
| 2 | 1024 | 3 | 64 | 96 | $(8, 12]$ |
| 2 | 2048 | 4 | 192 | 224 | $(12, 14]$ |

Look at the last column and the whole argument falls out.

The two seed-1 windows overlap, in $(14,16]$, and that intersection contains the product law's own $A = 16$. Seed 1 is not just consistent with the law — it *identifies* the amplitude, two-sidedly, to within $12.5\%$.

The two seed-2 windows are **disjoint**. $(8,12]$ and $(12,14]$ share not a single point; they abut exactly at $A = 12$ and miss each other.

**The Amplitude Conflict Theorem.** *There is no real number $A$ with $64 < 8A \le 96$ and $192 < 16A \le 224$. Equivalently: no amplitude whatsoever reproduces both second-seed measurements.*

Again the proof is a single line of arithmetic: the first condition forces $A \le 12$, the second forces $A > 12$.

## Why this kills the headline

"The drop is systematic" is a claim about a mechanism. The mechanism on offer says: the knee is $A \cdot d \cdot \mathrm{ctx} / \delta$, and the constant $A$ — which comes from how heavily the attention mass concentrates on a few positions — is a property of the trained model and so can shift a little from seed to seed. Under that story, the second seed simply has a slightly smaller $A$.

The Amplitude Conflict Theorem says: no it doesn't. Not because $A$ shifted too much, but because *no single value of $A$, large or small, produces both $96$ at $\mathrm{ctx}=1024$ and $224$ at $\mathrm{ctx}=2048$.* At $8\times$ context the second seed behaves like an amplitude of at most $12$; at $16\times$ it behaves like an amplitude strictly greater than $12$. The two "identical" one-step drops are drops from *different laws*.

And the conflict is genuine, not an artefact of a model with no room in it:

**The One-Outlier Theorem.** *Each broken rung is separately explainable: $A = 10$ reproduces the $\mathrm{ctx} = 1024$ seed-2 reading, and $A = 13$ reproduces the $\mathrm{ctx}=2048$ one.*

So the data sit exactly one measurement away from consistency. Either the $1024$ cell is anomalous or the $2048$ cell is; the evidence as it stands cannot say which. This is precisely a two-point obstruction — and it converts an editorial judgement ("we should probably run a third seed") into a theorem ("a third seed at $\mathrm{ctx}=1024$ is the unique measurement that resolves the conflict").

It also settles a subtler question. Could more context fix it? No: at rung $i$ the window has width $32/2^{i}$, the best the design allows, and the two windows are *already* disjoint at that width. Longer runs at either seed sharpen windows that do not overlap. Only a new seed can adjudicate.

## The adversarial reading: was there even a drop?

Before believing any of this, one should ask whether the $224$ is real. The margin at the knee is $0.982 - 0.980 = 0.002$, and the deficit at the previous grid point $192$ is $0.980 - 0.978 = 0.002$ as well. So a perturbation of $0.002$ in either direction changes the answer: the reading is decided at exactly the resolution of the experiment, with nothing to spare. It is not a *robust* knee in any perturbation-stable sense.

Worse for the headline: at the deciding budget $224$, the first seed scored $0.976$, a deficit of $0.004$ from the bar, while the observed spread between the two seeds at that same budget was $0.006$. Since $0.004 < 0.006$, *any* upward perturbation of the first-seed curve of the size the experiment itself measures already pushes the knee to $224$ or below. The "replication" is what the recorded noise predicts, not evidence beyond it.

There is a general phenomenon lurking here, and it is worth stating cleanly.

**The Quantisation Lemma.** *For any grid step $s > 0$, any grid multiple $n$, and any $\varepsilon > 0$, there exist two continuous knees $\kappa_1, \kappa_2$ with $|\kappa_1 - \kappa_2| \le \varepsilon$ whose reported grid knees are $s(n+1)$ and $sn$ respectively — a full grid step apart.*

Take $\kappa_2 = sn$ and $\kappa_1 = sn + \tfrac{1}{2}\min(\varepsilon, s)$. With $s = 32$, the case $n = 3$ is the pair $(96, 128)$, and the case $n = 7$ is the pair $(224, 256)$. The two celebrated "independent replications" are two instances of one lemma about rounding. And under a fair coin flip per cell, seeing a drop at both broken rungs has probability $1/4$ — above any conventional significance threshold. Two cells cannot establish "systematic".

## What survives, and it is a lot

Demolition is cheap; the interesting part is what stands.

**The safe bound survives everything.** Every one of the four measured windows lies in $A \le 16$. So the product-law budget $d \cdot \mathrm{ctx}/32$ is never exceeded by the true knee, at either seed, at any rung. As a *deployment guarantee* — "this budget is enough" — the law is untouched. Likewise every window forces $A > 8$, so the certified band is $A \in (8, 16]$, and the band is sharp: the seed-2 $1024$ window reaches down towards $8$ and the seed-1 windows reach up to $16$. Translated into hardware terms, the pruned model does between $8\times$ and $16\times$ less attention work, with $8\times$ guaranteed.

**The deviation is vanishing, not growing.** At the broken rungs, the measured ratio of second-seed knee to predicted knee is $96/128 = 3/4$ and $224/256 = 7/8$. The deficit is a fixed $32$ against a knee that doubles, so the ratio is $1 - 2\cdot 2^{-i}$, which tends to $1$. If the deficit stays bounded by one grid step forever, the "systematic break" is an *asymptotically invisible correction to an exact law* — and the observed best-case speedup of about $9.1\times$ is a transient that decays to the guaranteed $8\times$.

**Whatever the second seed is doing, it is not a scaling law at all.** Fit any straight line $a \cdot \mathrm{ctx} + b$ to the second seed's five knees $16, 32, 64, 96, 224$: the two shortest cells force $a = 1/8$, $b = 0$, predicting $128$ at $\mathrm{ctx}=1024$, where the measurement is $96$. No affine law fits. And no doubling law fits either: a law with $f(2n) = 2f(n)$ pinned to $96$ at $1024$ predicts $192$ at $2048$, not $224$. The honest surviving invariant is the *bracket*: at every rung and both seeds, $\text{prediction} - 32 \le k^{*} \le \text{prediction}$.

## The knee is an adjoint

One structural remark explains why the analysis is so clean. Define the grid-free knee of a monotone curve $C$ at bar $b$ as $\mathrm{Knee}(b) = \inf\{k : b \le C(k)\}$. Then for every budget $k$,

$$\mathrm{Knee}(b) \le k \iff b \le C(k),$$

which is exactly the statement that $\mathrm{Knee}$ is left adjoint to $C$ — a Galois connection between bars and budgets. Read left to right: any budget above the knee passes. Read right to left: a passing budget bounds the knee. That second reading is the *only* kind of statement a sweep can ever certify, which is why every honest conclusion in this story is an upper bound or a window. Monotonicity of the knee in the bar, and the fact that a dominating curve has a smaller knee — the reason the higher second-seed curve *must* cross earlier — are formal consequences of the adjunction, not empirical findings.

The reported grid knee is then simply the rounding of $\mathrm{Knee}(b)$ up to the sweep grid. Every argument about one grid step is an argument about a rounding.

## How fast does a doubling ladder learn a constant?

Since each rung of the ladder pins the amplitude to a window of width $s/2^{i}$, two amplitudes explaining the same rung differ by less than $s/2^{i}$ — and two amplitudes explaining *every* rung of an unbounded ladder must be equal. A fixed-step grid, repeated at doubling context, identifies a real constant exactly in the limit.

That rate cannot be beaten. For every $N$ there is an amplitude $A = 16 - 16/2^{N}$, different from $16$, that reproduces the product law's reported knee at every rung up to $N$. So $N$ doublings pin the amplitude to within $32/2^{N}$ and no better than $16/2^{N}$: geometric convergence, with matching constants up to a factor of $2$. Concretely, the seed-1 window $(14,16]$ is exactly the width $32/2^{4} = 2$ that rung four allows — the experiment could not have done better — and telling $A = 16$ from $A = 15.5$ requires resolution below $1/2$, hence rung six, i.e. $\mathrm{ctx} = 8192$.

## The experiment that decides

Best of all, the analysis makes the next run decisive. Push to $\mathrm{ctx} = 4096$ (rung five) and each surviving hypothesis predicts a different reported knee on the step-$32$ grid:

- seed-1 amplitude $A \in (14,16]$ predicts a knee in $[480, 512]$;
- the "$1024$ cell is the law" hypothesis, $A \in (8,12]$, predicts a knee of at most $384$;
- the "$2048$ cell is the law" hypothesis, $A \in (12,14]$, predicts a knee in $[416, 448]$.

These three predictions are pairwise separated by at least one full grid step of $32$. Unlike the $224$-versus-$256$ reading, which the grid cannot robustly resolve, one run at $4096$ adjudicates all three at the grid's own resolution.

That is the shape of the thing. A pattern was announced as systematic; a two-line lemma about windows showed it could not be produced by a single constant; the same lemma turned the demolition into a sharp identifiability statement for the other seed, a certified deployment band of $8\times$ to $16\times$, a matched rate at which doubling ladders learn constants, and a single decisive experiment. The knee moved by one grid step. Reading that step carefully turned out to be worth more than the pattern it was supposed to confirm.
