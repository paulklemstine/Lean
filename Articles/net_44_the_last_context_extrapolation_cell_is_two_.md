# The Knee That Moved

## What happens when a beautiful empirical law meets a second roll of the dice

There is a particular kind of pleasure in finding a clean formula hiding inside messy data. You run an experiment, you plot a curve, you notice that the interesting point on the curve sits at exactly $128$ — and $128$ is exactly $4 \times 1024 / 32$, a product of the two knobs you were turning. You double one knob and the special point doubles too. Four times in a row. At that moment the formula stops feeling like a fit and starts feeling like a fact.

This is the story of what happened when that formula was tested one more time, with nothing changed but the random seed — and of the small piece of mathematics that explains, exactly and permanently, why the outcome was not a surprise at all.

---

## The setup: how much of the past do you actually need?

Modern sequence models read a long window of text and, at every position, look back over everything they have read. That "looking back" is the expensive part: with a context of $\mathrm{ctx}$ tokens, a naive backward glance costs on the order of $\mathrm{ctx}$ operations per position per layer, and the whole thing scales quadratically. A natural economy is to keep only the $k$ most relevant past positions and throw away the rest.

Do that and you get a trade-off curve. Let $c(k)$ be the **retained accuracy**: the model's held-out accuracy when it is allowed to attend to only $k$ past positions, divided by its accuracy when allowed to see everything. By construction $c$ is increasing in $k$ — more memory never hurts — and $c(k) = 1$ once $k$ reaches the full context. Somewhere in between, the curve crosses a line you have drawn in advance: a **bar**, here $0.98$, meaning "I will accept losing two percent of my accuracy."

The crossing point is the interesting number. Call it the **knee**:

$$k^\star \;=\; \min\{\,k \in G : c(k) \ge \mathrm{bar}\,\},$$

where $G$ is the finite grid of budgets you actually tested — in this case $\{32, 64, 96, 112, 128, 192, 256, 384, 512, 768\}$. The knee is what you deploy. Divide the context length by it and you get your speedup: at $\mathrm{ctx} = 1024$ and $k^\star = 128$, an eightfold reduction in attention work.

## The law, and the chain that made it look inevitable

Across a grid of depths $d$ and contexts $\mathrm{ctx}$, the measured knees kept landing on
$$k^\star \;=\; \frac{d \cdot \mathrm{ctx}}{32}.$$
At depth $d = 4$, contexts $128, 256, 512, 1024$ gave knees $16, 32, 64, 128$: four consecutive doublings, exact each time.

Exactness along a chain of doublings is seductive, and there is a reason for that. If a law $f$ satisfies the doubling relation $f(2n) = 2 f(n)$ and is anchored at $f(128) = 16$, then by a one-line induction $f(128 \cdot 2^m) = 16 \cdot 2^m$ for every $m$, so $f(1024) = 128$ — forced, not fitted. The chain does not merely *suggest* the last value; given the relation, it *determines* it.

But that is the trap, and it is worth stating precisely. **The relation determines the prediction; the data does not.** The measured chain is three numbers and the knowledge that the curve is increasing. For *every* value $v > 64$ there is an increasing law reproducing $16, 32, 64$ at $\mathrm{ctx} = 128, 256, 512$ and taking the value $v$ at $\mathrm{ctx} = 1024$ — just take the step function that jumps to $v$ after $512$. The elegance of the doubling relation is doing all the predictive work, and elegance is not evidence.

## The test

The last cell of the grid, $(d = 4,\ \mathrm{ctx} = 1024)$, had been measured at exactly one random seed. So it was measured again at a second, with a byte-identical harness, and a prediction registered in advance: $k^\star = 128$.

The prediction failed.

| budget $k$ | 64 | 96 | 112 | 128 | 768 |
|---|---|---|---|---|---|
| retained, seed 1 | 0.968 | 0.977 | — | 0.986 | 1.000 |
| retained, seed 2 | 0.979 | 0.987 | 0.991 | 0.993 | 1.000 |

Seed 2's curve sits about $0.010$ above seed 1's at every budget — and that is enough. At $k = 96$, seed 1 reads $0.977$, just under the bar of $0.98$; seed 2 reads $0.987$, comfortably over. The knee at seed 2 is $96$, not $128$. The product law over-predicts by exactly a quarter of its own value: $96 = 0.75 \times 128$.

The extra grid point at $112$ was added precisely so this could not be fudged. It passes too — but $96$ already passed, so the seed-2 knee is *pinned* at $96$, not merely bracketed somewhere in $(96, 128]$.

## Why it was never a fact — the margin criterion

Here is the piece of mathematics that turns a disappointing result into a permanent one. Ask: under what conditions is a knee measurement *stable*? Suppose you perturb the whole accuracy curve by at most $\eta$, keeping it increasing — the sort of wobble a different seed produces. When does the knee refuse to move?

**Robustness criterion.** *For an increasing curve $c$ with knee $k$ on a grid $G$, the claim "$k^\star = k$" survives every increasing perturbation of size at most $\eta$ if and only if*
$$\eta \;\le\; c(k) - \mathrm{bar} \qquad\text{and}\qquad \eta \;<\; \mathrm{bar} - c(j) \quad\text{for every grid point } j < k.$$

In words: the knee must clear the bar by at least $\eta$, and every budget below it must *miss* the bar by strictly more than $\eta$. Both directions are true, and the "only if" direction is proved by exhibiting the offending curves explicitly — the shifts $c - \eta$ and $c + \eta$. There is nothing probabilistic here and no appeal to error bars; it is an exact statement about an order relation on a finite chain. (The asymmetry between $\le$ and $<$ is forced by the bar being a non-strict threshold: a curve that lands exactly on the bar passes.)

Now apply it. Seed 1's margin at $96$ — the amount by which it misses the bar — is $0.98 - 0.977 = 0.003$. The observed spread between seeds is $0.010$. Since $0.003 < 0.010$, the criterion fails, and the failure is constructive: shifting seed 1's curve up by $0.010$ produces a legitimate increasing curve whose knee is $96$. That shifted curve is not a mathematical fiction — it reproduces the actual seed-2 measurements at $64$, $96$ and $128$ to within $0.001$.

So seed 1's agreement with the product law was **seed-luck**. It was sitting three thousandths above a cliff edge, in a landscape whose typical wobble is ten thousandths. Nobody had to run seed 2 to know the claim was unprotected; the seed-1 data alone contained the warning.

And the converse is just as informative. Seed 1's *deficit* at $k = 64$ is $0.98 - 0.968 = 0.012$, which is **larger** than the spread $0.010$. By the same criterion, no perturbation of that size can drag the knee down to $64$. The lower end of the bracket is protected; the upper end never was. This asymmetry — one number under the spread, one number over it — is the entire content of the round, and it was visible in the first seed's own margins.

## What survives

Three things survive, and they are worth more than the broken equality.

**First: the law is still a guarantee, just not an equality.** A sweep can only ever certify an *upper bound* on a knee. That is a triviality once you see it — the knee is by definition the *least* passing budget, so any budget you observe to pass is an upper bound for it — but it is the right triviality. Both seeds clear the bar at $128$ ($0.986$ and $0.993$). So $d \cdot \mathrm{ctx}/32$ remains a proven-safe deployment budget. What it is not is minimal.

**Second: the honest object is an interval, not a number.** No single value can be the knee at both seeds, so the correct statement of the law at this cell is the bracket
$$k^\star \in (64, 128].$$
This bracket is *sound* — both measured knees lie in it — and *sharp*: no narrower window with endpoints on the sweep grid contains both. Translated into deployment, the bracket becomes a speedup window: since speedup is $\mathrm{ctx}/k^\star$, every $k^\star \in (64,128]$ gives a speedup in $[8, 16)$, with the two measured seeds at $8\times$ and $32/3 \approx 10.67\times$. The eightfold guarantee is intact as a floor; the upside is real but not certified.

**Third: ensembles have an exact epistemic content.** Run $n$ seeds and you get $n$ knees. What may you deploy? Exactly $\max_i k_i^\star$: at that budget every seed clears the bar, and it is the *least* grid budget with that property. Two consequences follow immediately, and both are uncomfortable. Adding seeds can only push the certified budget *up* — evidence degrades guarantees, monotonically, and a law fitted at a single seed is the most optimistic reading a sweep can ever produce. And no number of seeds can rescue $k^\star = 128$ here: as long as some seed's curve comes within the spread of the bar below its knee, an admissible curve with a smaller knee always exists.

There is also a pleasingly algebraic way to say what the certified budget *is*. For an increasing curve the set of budgets clearing the bar is an "up-set" of the grid — closed upward — and the knee is its minimum. Take two seeds and form their pointwise minimum curve (the worst case) and pointwise maximum (the best case). Then the worst-case curve has knee $\max(k_1^\star, k_2^\star)$ and the best-case curve has knee $\min(k_1^\star, k_2^\star)$. The knee, in other words, is an order-*reversing* lattice homomorphism from curves to budgets. The certified budget is not an ad hoc "take the worst" convention: it is literally the knee of the worst-case curve. Here that is $128$; the best case is $96$; and the price of insisting on the worst case is the over-provisioning factor $128/96 = 4/3$.

## The grid itself is a liar (a little)

One more caution, and it is a subtle one. A sweep with step $s$ can only report multiples of $s$. If the true, continuous crossing point is $\kappa$, the reported grid knee is $s\lceil \kappa/s \rceil$, which never under-reports and over-reports by strictly less than one step. So the reported value $128$ really means "the true knee is somewhere in $(96, 128]$", and a reported $96$ means "somewhere in $(64, 96]$".

This cuts both ways. On one hand, an "exact" match to a formula carries a built-in uncertainty of a full grid step: for any $\varepsilon > 0$ one can write down two true knees within $\varepsilon$ of each other whose step-$32$ grid knees are $96$ and $128$. A one-step difference between seeds can be manufactured out of nothing. On the other hand — and this is why the result stands — the two windows $(96, 128]$ and $(64, 96]$ are **disjoint**. The seeds genuinely differ; this particular one-step move is not a quantisation artefact of one shared underlying value.

## The mechanism, unbothered

Where does a knee come from in the first place? The working model is that attention weights follow a heavy tail: the mass beyond rank $k$ behaves like an amplitude $A$ times a decaying function of $k$, and the budget is feasible when the total dropped mass, summed over $d$ layers, stays under a tolerance $\delta$. That gives a least feasible budget of the form $\kappa = A \cdot d \cdot \mathrm{ctx} / \delta$ — linear in depth, linear in context, which is exactly the shape of the product law.

Notice what that means for the fluctuation. If two seeds have least feasible budgets $\kappa_1$ and $\kappa_2$ with amplitudes $A_1$ and $A_2$, then $\kappa_2/\kappa_1 = A_2/A_1$: depth, context and tolerance cancel completely. The move from $128$ to $96$ is *exactly* a factor $3/4$ in the tail amplitude. The mechanism is untouched; only its single fitted constant wobbled. And feasibility at the law's budget is monotone in that constant — any seed with amplitude at or below the calibrated one is safe at $d\cdot\mathrm{ctx}/32$ — which is the mechanistic reason the upper bound holds up while the equality does not.

## The moral

Empirical laws in computational science are usually reported with a decimal point and no collar. This round says: report the collar. A knee claim is worth exactly the size of its smallest margin, and that number is already in your data — you do not need a second seed to compute it, only to confirm what it told you.

Seed 1's margin was $0.003$ in a world of $0.010$ wobbles. The law was never a fact. It was, and remains, an excellent upper bound: deploy $d \cdot \mathrm{ctx}/32$ and you will keep $98\%$ of your accuracy for an eighth of the attention cost. Just do not tell anyone it is the smallest budget that works. Sometimes it is three quarters of it.
