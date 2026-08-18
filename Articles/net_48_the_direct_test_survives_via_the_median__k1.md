# The Middle Value Knows Something the Averages Don't

## How a stubborn little piece of tropical algebra explains why the *median* is the only honest summary of a noisy experiment

### A prediction, four ways wrong

Imagine you are running an expensive experiment. Each run takes four hours. Before you start, you write down, in ink, four guesses for the number the experiment will produce: $192$, $224$, $240$, $256$. You run it. The answer comes back: $160$.

All four guesses are wrong. Not close-but-wrong — *categorically* wrong, outside the whole cluster you had in mind. In most accounts of science, this is where you concede and go back to the drawing board.

And yet, in the story we are about to tell, something remarkable happened. The four point predictions failed, but a *fifth*, structurally different prediction — a prediction not about any single measurement but about the **centre** of a family of measurements — landed exactly on the nose. The measured value $160$, combined with two earlier measurements $224$ and $256$, produced a three-point distribution whose median was exactly $224$: precisely the predicted value of $\tfrac{7}{8}$ of a certain reference quantity.

That is a curious kind of scientific success: $0$ out of $4$ on the points, $1$ out of $1$ on the structure. This article is about *why* that is not a fluke or a rhetorical trick, and about the beautiful, spiky, min-and-max flavoured algebra that makes the median — and only the median — capable of that sort of prediction.

### The setting: how much of a long context does a model actually need?

Here is the concrete experiment behind the numbers, stripped to its essentials.

A sequence model reads a *context* of $\mathrm{ctx}$ previous tokens, and for each new token it looks back at all of them. That "look at all of them" step is the expensive part; its cost grows with the square of the context length. A natural economy is to keep only the $k$ most relevant past positions and throw away the rest. If you keep too few, the model gets worse. If you keep enough, the model performs indistinguishably from the version that looks at everything.

So define a **retention curve**: for each budget $k$, let $c(k)$ be the model's accuracy at budget $k$, divided by its accuracy with the full context. It starts below $1$ and climbs. Fix a **bar** — here $0.98$, meaning "within $2\%$ of full performance". Then the **knee** $k^\*$ is the smallest budget on the tested grid at which the curve clears the bar:

$$k^\* = \min\{\,k \in G : c(k) \ge \mathrm{bar}\,\}.$$

The knee is the number you would quote to an engineer: *this is how much of the past you actually need.*

In the experiment at hand, with model width $d=4$ and context $\mathrm{ctx}=2048$, the measured retention curve for one particular random seed reads

| $k$ | 96 | 128 | 160 | 192 | 224 | 240 | 256 | 288 | 384 | 512 | 768 | 1024 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| $c(k)$ | 0.963 | 0.973 | **0.981** | 0.984 | 0.986 | 0.987 | 0.990 | 0.993 | 0.999 | 1.000 | 1.003 | 1.003 |

The bar is $0.980$. The curve first clears it at $k=160$, with the razor-thin margin $0.981 - 0.980 = 0.001$. So $k^\* = 160$: all four horns of the pre-registered prediction — $192, 224, 240, 256$ — *do* clear the bar, but none of them is the *first* budget that does. They are each safe and each wrong, simultaneously. It is a nice illustration that "my prediction passes the test" and "my prediction is the answer" are very different claims.

### The 7/8 law

Now zoom out. The same experiment has been run at two context lengths and, at each, with three different random seeds. There is a natural reference scale, the **product point** $P = d\cdot\mathrm{ctx}/32$: at $\mathrm{ctx}=1024$ that is $P_8 = 128$, and at $\mathrm{ctx}=2048$ it is $P_{16} = 256$. Normalising each measured knee by its product point gives:

| context | three knees | normalised | median |
|---|---|---|---|
| $1024$ | $\{96, 112, 128\}$ | $\{3/4,\ 7/8,\ 1\}$ | $7/8$ |
| $2048$ | $\{160, 224, 256\}$ | $\{5/8,\ 7/8,\ 1\}$ | $7/8$ |

Two things jump out. First, the **top** of each distribution sits exactly at $1$: no seed ever needed more than the product point. Second, the **median** of each distribution sits exactly at $7/8$, in both contexts, even though the distributions themselves are different — the lower end sinks from $3/4$ to $5/8$ as the context doubles, widening the spread by a factor of exactly $3/2$.

So the picture is: a **pinned ceiling**, a **sinking floor**, and a **stationary centre**. And $7/8$ is not a fudge factor with wiggle room: it is the *unique* constant $a$ with $a\cdot P_8 = 112$ and $a \cdot P_{16} = 224$. There is no free parameter left to tune.

Here is the sharpest test of whether this is really about the median. Take the *mean* of each knee triple instead. At $\mathrm{ctx}=1024$ the mean is $112 = \tfrac78 P_8$, agreeing by accident. At $\mathrm{ctx}=2048$ the mean is $\tfrac{256+224+160}{3} = \tfrac{640}{3}$, which is $\tfrac56 P_{16}$, not $\tfrac78 P_{16}$. **No constant works for both rows under the mean.** The law is a statement about the median specifically, and one arithmetic line kills the alternative.

### Enter the tropics

Why would the median, of all summaries, be the one that laws attach themselves to? The answer is algebraic, and it belongs to a corner of mathematics called **tropical algebra**.

In tropical arithmetic, you throw away $+$ and $\times$ and replace them with $\max$ and $\min$ (or $\min$ and $+$, depending on the dialect). It sounds like vandalism, but $(\max, \min)$ on any linearly ordered set really is a perfectly good commutative *semiring*: both operations are associative and commutative, each distributes over the other, and both are idempotent — $a \vee a = a$, $a \wedge a = a$. Polynomials in this semiring are exactly the piecewise-linear, corner-riddled objects that show up wherever optimisation, scheduling, or combinatorial geometry live.

Now, the punchline. **The median is a tropical polynomial.** For three numbers,

$$\operatorname{med}(a,b,c) \;=\; (a \wedge b) \,\vee\, (b\wedge c)\,\vee\,(a \wedge c),$$

where $\wedge = \min$ and $\vee = \max$. Take pairwise minimums, then take the biggest of them. Try it: for $(256, 224, 160)$ you get $\max(224, 160, 160) = 224$. And there is a dual formula, min-of-maxes,

$$\operatorname{med}(a,b,c) \;=\; (a\vee b)\,\wedge\,(b\vee c)\,\wedge\,(a \vee c),$$

which gives the same answer — the median is *self-dual*: it does not care which way is up.

This is not an accident of three arguments. For any odd sample of size $2k+1$,

$$\operatorname{med}(x) \;=\; \bigvee_{|S| = k+1}\ \bigwedge_{i \in S} x_i,$$

the maximum, over all $(k+1)$-element subsets of the indices, of the minimum of the sample there. So the median is a *homogeneous tropical polynomial of degree $k+1$ in $2k+1$ variables*. A statistical quantity, revealed to be an algebraic normal form.

From this formula, the median's two magic properties fall out immediately.

**Threshold duality.** A value $v$ satisfies $v \le \operatorname{med}(x)$ exactly when at least $k+1$ of the samples satisfy $v \le x_i$; and $\operatorname{med}(x) \le v$ exactly when at least $k+1$ satisfy $x_i \le v$. In plain words: *thresholding the median is a majority vote.* Ask the median any yes/no question of the form "are you above $v$?", and it answers by polling the sample and taking the majority.

**Equivariance.** If you re-express your data in different units by any monotone transformation $f$ — say, divide every knee by the product point — then the median of the transformed data is the transform of the median. And, less obviously, the same holds for *order-reversing* transformations: convert each knee $k^\*$ into a speed-up $\mathrm{ctx}/k^\*$, which turns big into small, and the median of the speed-ups is still the speed-up of the median. The extremes do *not* have this property; order reversal swaps the min and the max.

That last point has a very concrete operational reading. At $\mathrm{ctx}=2048$, the three speed-ups are $2048/256 = 8$, $2048/224 = 64/7 \approx 9.14$, and $2048/160 = 64/5 = 12.8$. Their median is $64/7$, the speed-up of the median knee, exactly as equivariance demands. But the *guaranteed* speed-up — the one you would put in a contract — is $8\times$, and it is the image of the *largest* knee. Order reversal sent the worst case to the top. The median and the guarantee are governed by different order statistics, and the algebra tells you which is which.

### The knee of the average is not the average of the knees — unless you average tropically

Here is the question a careful experimentalist should ask. You have three seeds. You could (A) read a knee off each curve, then take the median of the three knees; or (B) merge the three curves into one aggregate curve, then read a single knee off that. Do these agree?

For the arithmetic mean, **no**. Take three curves that jump from $0$ to $1$ at budgets $1$, $2$, $3$ respectively, with the bar at $1$. Their knees are $1, 2, 3$, whose median is $2$. But the mean curve is $0$ at budget $1$, $1/3$ at budget $2$, and only reaches $1$ at budget $3$. Its knee is $3$. Averaging the curves and averaging the knees give genuinely different answers, and the mean-curve answer is dragged to the worst seed.

For the median, **yes, exactly**. This is the central theorem of the story:

> **Median–Knee Commutation Theorem.** Let $c_0, c_1, c_2$ be non-decreasing retention curves on a grid $G$ with knees $k_0, k_1, k_2$ at a common bar. Then the pointwise median curve $t \mapsto \operatorname{med}(c_0(t), c_1(t), c_2(t))$ has a knee, and that knee is exactly $\operatorname{med}(k_0, k_1, k_2)$.

The proof is pure threshold duality, and it is short enough to give here. The median curve clears the bar at a budget $t$ precisely when at least two of the three curves do; and since the curves are non-decreasing, curve $i$ clears the bar at $t$ precisely when $k_i \le t$. So *the median curve clears the bar at $t$ if and only if at least two of the three knees are $\le t$* — which, by the other half of threshold duality, is exactly the statement $\operatorname{med}(k_0,k_1,k_2) \le t$. Two majority conditions, recognised as the same majority condition. The smallest such $t$ on the grid is therefore $\operatorname{med}(k_0,k_1,k_2)$, and that is the theorem.

The same argument works for any odd number of seeds, with "at least two of three" replaced by "at least $k+1$ of $2k+1$". Monotonicity of the curves cannot be dropped: a curve that clears the bar early and then falls back is counted by its own knee, but the median curve never sees it, and the identity fails.

Applied to the measured data: with knees $256$, $224$, $160$, the median curve of any three monotone retention curves realising them has knee exactly $224$. **The reported centre of the distribution is itself a knee — the knee of the median model.** It is not a bookkeeping average; it is an operating point.

### Why one bad seed cannot ruin your day

There is one more property that makes the median the right summary of an expensive, noisy experiment: robustness, and here too the tropical formula does the work.

The median of three is **$1$-Lipschitz for the sup-norm**: if every seed's reported knee wobbles by at most $\delta$, the median moves by at most $\delta$. This follows in two lines from monotonicity plus *tropical homogeneity of degree one* — the fact that adding a constant $t$ to all inputs adds $t$ to the median.

Better still is the **breakdown** statement. Suppose a majority of your seeds — $k+1$ out of $2k+1$ — are trustworthy, and the rest are corrupted arbitrarily. Then the median still lies between the smallest and the largest trustworthy value. It cannot be dragged out. For the measured data: with seeds $1$ and $2$ pinned at $256$ and $224$, *whatever* a re-measured third seed reports, the median stays in $[224, 256]$. And composing this with the commutation theorem gives the full pipeline statement: corrupt up to $k$ of the $2k+1$ seeds — curve and all, not just the reported knee — and the knee of the median curve still sits inside the interval spanned by the surviving seeds.

The mean, by contrast, has breakdown point zero. Two clean step curves with knee $1$ plus a single corrupted step curve with knee $N$ produce a mean curve whose knee is $N$, for any $N$ you like. One bad seed out of three, and the aggregate can be sent anywhere.

### But the median is not infinitely forgiving

Robustness has an exact boundary, and it is worth being precise about it, because it is easy to overstate. With two seeds pinned at $224$ and $256$, which third-seed values leave the median at $224$?

$$\operatorname{med}(x, 224, 256) = 224 \iff x \le 224.$$

Exactly the ray $x \le 224$ — no more. So $160$, $192$ and $224$ all keep the centre where it is, as one would hope. But a tempting looser claim — "only a third seed of $256$ or more would shift the median" — is **false**: a third seed at $240$ lies strictly below $256$ and already moves the centre to $240$. The stability region is a half-line with a sharp endpoint at the current median, not a fuzzy neighbourhood extending to the next data point. It is precisely the sort of statement that sounds right and isn't, and pinning it down is part of the value of doing the algebra rather than the arm-waving.

### What pins down the median? Five axioms, one of them tropical

Finally: is there something special about the median, or would any reasonable "centre" have done? There is a clean answer. Consider a summary $F$ of three numbers, and ask it to satisfy five requirements:

1. **Monotone** — if a seed reports a larger value, the summary does not decrease.
2. **Symmetric** — the seeds are interchangeable; their labels carry no information.
3. **Conservative** — the summary is one of the measured values, not a value nobody observed.
4. **Translation-equivariant** — shifting all three measurements by $t$ shifts the summary by $t$. (This is tropical homogeneity of degree one: a change of the zero point of your scale.)
5. **Self-dual** — measuring "cost" instead of "benefit", i.e. negating all inputs, negates the summary.

> **Characterisation Theorem.** A ternary aggregator on the reals satisfying all five axioms *is* the median.

The proof is a small tropical gem. Self-duality plus translation gives the identity $F(0,0,d) = d - F(0,d,d)$; monotonicity gives $F(0,0,d) \le F(0,d,d)$; combining them yields $2F(0,0,d) \le d$; and conservativity — the summary must be $0$, $0$, or $d$ — then forces $F(0,0,d) = 0$ whenever $d\ge 0$. That is the **majority property**: two equal votes win. Translating, $F(a,a,c) = a$ and $F(a,c,c)=c$ for $a \le c$, and monotonicity squeezes $F(a,b,c)$ between them onto $b$. Sorted case done; symmetry does the rest.

And the axioms are tight in an instructive place. Drop *only* translation-equivariance and the theorem dies: consider the **sum-sign aggregator**, which returns the maximum of the three inputs if they sum to a positive number, the minimum if they sum to a negative one, and the median on the zero-sum wall. It is monotone, symmetric, conservative and self-dual — and it is not the median, since it returns $1$ on the input $(0,0,1)$ where the median returns $0$. So the median's status as *the* canonical centre is not a soft order-theoretic fact. It is a **tropical** fact: it requires the axiom that says the median behaves linearly with respect to shifts, which is precisely the min-plus notion of degree-one homogeneity.

### The moral

The four point predictions failed. The structural prediction held. That is not special pleading, because the two kinds of claim have provably different characters, and the difference is algebraic.

A single seed's knee is an extreme-order quantity, sensitive to the last decimal of a noisy curve — in this run, decided by a margin of $0.001$. The median is a tropical polynomial in the seeds: majority-determined, unit-independent under any monotone or antitone change of coordinates, $1$-Lipschitz, immune to a minority of corrupted runs, and — the fact that ties the whole story together — commuting with the very act of reading a knee, so that the reported centre is itself an operating point of a real aggregate model rather than a statistician's fiction.

If you want to predict where the individual points land, you need a theory of the noise. If you want to predict where the *centre* lands, you need the right notion of centre. Tropical algebra tells you which notion that is, and, gratifyingly, it is the one everybody already uses when they stop and think: the middle value.
