# The Two-Thirds Rule: Why a Language Model Can Forget Most of What It Reads and Still Be Right

## A budget, a knee, and a surprise

Every time a modern language model reads a sentence, it does something extravagant. For each word it is about to produce, it looks back at *every* word it has already seen, scores them all for relevance, and blends them into a single summary vector. That is the attention mechanism, and it is the reason these models are slow: with a context window of $n$ tokens, the bookkeeping grows like $n^2$.

The obvious economy is to look at fewer things. Keep only the $k$ highest-scoring positions, renormalize, and throw the rest away. The question is: how small can $k$ be before the model starts making mistakes?

There is a natural way to measure the answer. Sweep $k$ upward and record the *retained accuracy* — the fraction of the full model's held-out prediction accuracy that survives truncation. The curve rises, flattens, and hits $1$. Define the **knee** $k^\ast$ as the smallest budget at which the curve reaches $0.98$: keep $k^\ast$ positions and you keep $98\%$ of what the model could do.

Measured across a grid of small causal transformers — depths $d \in \{4, 8, 16\}$, context lengths $\mathrm{ctx} \in \{128, 512\}$, trained on public-domain novels with a 4097-token vocabulary — the knee obeys a startlingly clean rule:

$$k^\ast(d, \mathrm{ctx}) \;=\; \frac{d \cdot \mathrm{ctx}}{32}.$$

At depth $4$ with a $128$-token window, $k^\ast = 16$. At depth $8$, $k^\ast = 32$. At depth $16$, $k^\ast = 64$. Stretch the window to $512$ tokens at depth $4$, and $k^\ast = 64$ again. Every one of these cells has now been hit at two independent random initializations, and every one lands *exactly* on the predicted integer — predictions registered before the runs.

Rearranged, the law says something a systems engineer can act on. The speedup from truncation is $\mathrm{ctx} / k^\ast = 32/d$. It depends only on the depth. Make the context eight times longer and the achievable speedup does not budge: at depth $4$, you can always look at one-eighth of the window. The lever is *context-invariant*.

But the real surprise is not the law. It is what happens when you ask *why* it holds — and discover that the most obvious explanation is provably wrong.

## The obvious explanation, and its obituary

Here is what everyone assumes. Attention is concentrated. A typical attention row — the vector of weights $p_1, \dots, p_n$ that one position assigns to all the others — is not spread evenly; it spikes on a handful of relevant tokens. If almost all the weight sits on a few positions, then keeping those few positions keeps almost all the weight, and the model barely notices.

You can even quantify how concentrated a row is. The standard statistic is the **effective support**

$$N_{\mathrm{eff}} \;=\; \frac{1}{\sum_i p_i^2},$$

the reciprocal of the *collision mass*. For a row spread uniformly over $m$ positions, $N_{\mathrm{eff}} = m$ exactly; for a row concentrated on a single spike, $N_{\mathrm{eff}} = 1$. It answers "how many positions is this row effectively using?"

For the long-context model — depth $4$, context $512$ — the measured effective support is $N_{\mathrm{eff}} = 152.11$. (It reproduces to five significant figures across seeds: $152.11$ and $152.11$. Concentration is a remarkably stable statistic.) The knee is $k^\ast = 64$. So the story would be: about $152$ positions matter, we keep $64$ of the best ones, and that catches nearly all the mass.

It does not. And you can prove it does not, in one line of Cauchy–Schwarz.

**The truncation bound.** For any probability vector $p$ and *any* set $T$ of retained positions,

$$\left(\sum_{i \in T} p_i\right)^2 \;\le\; |T| \cdot \sum_i p_i^2, \qquad\text{i.e.}\qquad \sum_{i \in T} p_i \;\le\; \sqrt{\frac{|T|}{N_{\mathrm{eff}}}}.$$

The proof is the Cauchy–Schwarz inequality applied to $p$ restricted to $T$ against the all-ones vector, followed by the observation that the sum of squares over $T$ is at most the sum of squares over everything. No assumption is needed: not that the weights are sorted, not that $T$ is the top-$k$ set, not even that the weights are positive (for the squared form). It is as hard a constraint as arithmetic allows.

Turn it around. If you want to keep a fraction $\rho$ of the attention mass, you *must* pay

$$|T| \;\ge\; \rho^2 \, N_{\mathrm{eff}}.$$

Now substitute the measured numbers. To retain $98\%$ of the *mass* at $N_{\mathrm{eff}} = 152.11$, you need at least $0.98^2 \times 152.11 > 146$ positions. The measured accuracy knee is $64$. It is not close. Truncation at $k^\ast$ is more than twice as cheap as any possible mass-preserving truncation.

Push the same inequality in the other direction and it gets worse. At a budget of $k \le 64$ with $N_{\mathrm{eff}} = 152.11$, the retained mass is at most $\sqrt{64/152.11} < 0.65$. So at exactly the budget where the model retains $98.5\%$ of its accuracy, it has provably thrown away *at least a third of its attention mass*.

That is the headline. **Accuracy and attention mass decouple.** The model is not surviving truncation because it keeps the weight; it is surviving because accuracy simply does not care about the weight it loses. The gap is not a fitted number or a statistical trend — it is the distance between two theorems.

## The converse fails too — and spectacularly

One might hope to rescue the concentration story in reverse: perhaps a small $N_{\mathrm{eff}}$ at least *implies* a small knee, even if the constant is loose. It does not, and there is a clean family of counterexamples.

Consider the **spike-plus-uniform** row on $n+2$ positions: weight $1/2$ on the first position, and the remaining $1/2$ shared equally among the other $n+1$. Its collision mass is $\tfrac14 + (n+1)\cdot\big(\tfrac{1}{2(n+1)}\big)^2$, so

$$N_{\mathrm{eff}} \;=\; \frac{4(n+1)}{n+2} \;\longrightarrow\; 4 \quad\text{as } n \to \infty.$$

By the effective-support statistic, this row is "essentially four positions." Yet any set of $k$ positions catches at most $\tfrac12 + \tfrac{k}{2(n+1)}$ of its mass, which for fixed $k$ tends to $\tfrac12$. So: for every budget $k$ and every tolerance $\varepsilon > 0$, there is an attention row whose effective support is within $\varepsilon$ of $4$ and whose best $k$-position truncation retains barely more than half the mass.

No inequality of the form "top-$k$ mass $\ge F(k, N_{\mathrm{eff}})$" with $F(k,4) > 1/2$ can be true. The effective support is not a sufficient statistic for the knee. Whatever produces $k^\ast = d\cdot\mathrm{ctx}/32$, it is not concentration.

(The same family, incidentally, shows the Cauchy–Schwarz truncation bound is sharp: the ratio of the squared top-$1$ mass to the bound $1 \cdot \sum p_i^2$ tends to $1$. The inequality cannot be improved.)

## Where the law actually comes from

If concentration is out, what is in? Two ingredients, one for each variable in the law.

**The depth leg.** A transformer is a stack. Truncate the attention in every layer and the errors travel forward. If each exact layer is *nonexpansive* — it never increases the distance between two inputs, which is the regime a well-trained residual stack lives in — then a chain of $d$ layers, each perturbed by at most $\varepsilon$, moves the final output by at most $d \cdot \varepsilon$. The proof is a two-line induction: the triangle inequality splits the new error into "this layer's own perturbation" plus "the incoming error, transported"; nonexpansiveness makes the transport free; the errors add.

Errors adding, not multiplying, is the whole depth leg. If the end-to-end error budget is $\delta$, each layer gets $\delta/d$. Deeper stacks demand tighter per-layer truncation, hence bigger $k$, and the demand grows *linearly* in $d$.

**The context leg.** For the mass left outside the top $k$, assume a *scale-free* profile: the tail depends on $k$ only through the fraction $k/\mathrm{ctx}$, with the $1/x$ shape,

$$\mathrm{tail}(k) \;=\; \frac{A \cdot \mathrm{ctx}}{k}.$$

This is a Zipf tail — the same fat, self-similar decay that governs word frequencies and, apparently, attention weights.

Put the two together. The stack's total truncation error is $d \cdot A\,\mathrm{ctx}/k$, and it fits inside the budget $\delta$ precisely when

$$k \;\ge\; \frac{A \, d \, \mathrm{ctx}}{\delta}.$$

So the least sufficient budget is $\lceil A\,d\,\mathrm{ctx}/\delta \rceil$. Calibrate the single dimensionless ratio $A/\delta = 1/32$ — one fitted number, the entire empirical content of the calibration — and the least budget on any cell where $32$ divides $d\cdot\mathrm{ctx}$ is exactly $d\,\mathrm{ctx}/32$. The measured law, derived.

And the deployable consequence falls out: $\mathrm{ctx}/k^\ast = 32/d$, with no $\mathrm{ctx}$ in it.

## The mechanism is not a choice

A derivation is only as good as its assumptions, and one can reasonably worry that "nonexpansive layers plus a Zipf tail" was reverse-engineered to hit the answer. It was not — and this is the part of the story that most surprised me. Both ingredients are *forced* by the two qualitative facts the grid reports.

**The functional form is forced.** Suppose a budget law $K(d,\mathrm{ctx}) > 0$ has (i) a speedup $\mathrm{ctx}/K(d,\mathrm{ctx})$ depending only on depth, and (ii) a depth leg that is linear at unit context, $K(d,1) = d\cdot K(1,1)$. Then $K(d,\mathrm{ctx}) = d\cdot\mathrm{ctx}\cdot K(1,1)$ for all positive $d$ and $\mathrm{ctx}$. The bilinear form is not fitted; it is implied. Only the constant $K(1,1) = 1/32$ carries information.

**The tail shape is forced.** Model the per-layer tail as an arbitrary scale-free profile $t$, so the mass outside the top $k$ of a length-$\mathrm{ctx}$ row is $t(k/\mathrm{ctx})$. Every such profile makes the speedup context-invariant, so context-invariance says nothing about $t$. But suppose in addition that the least feasible fraction at depth $d$ is $d\cdot x_1$ — the depth-linear leg. Then continuity of $t$ pins it: at the least feasible point the constraint must be tight (otherwise a slightly smaller budget would also work), giving $d\cdot t(d x_1) = \delta$, hence

$$t(u) \;=\; \frac{\delta x_1}{u}$$

on the measured points. The Zipf $1/x$ tail is the *unique* scale-free profile compatible with a depth-linear knee.

**Nonexpansiveness is load-bearing, and testable without a sweep.** Redo the depth leg with $\Lambda$-Lipschitz layers and the accumulated error becomes $\varepsilon \sum_{i<d} \Lambda^i$. Two regimes:

- If $\Lambda \le 1 + c/d$ — near-isometric at the measured scale — then $\sum_{i<d}(1+c/d)^i \le d\,e^{c}$, so the law stays linear in depth, merely with the constant multiplied by $e^c$. The mechanism is robust to a little expansion.
- If instead $\Lambda = 1+x$ for a *fixed* $x > 0$, then $\sum_{i<d}(1+x)^i \ge d + x\,d(d-1)/2$ by Bernoulli's inequality, which eventually exceeds $M\cdot d$ for *every* constant $M$. The feasible budget grows superlinearly and $k^\ast = C\cdot d$ becomes impossible at large depth.

So a single spectral measurement — per-layer Jacobian norms bounded away from $1$ — would refute the depth leg without running a single top-$k$ sweep. That is a falsification test that costs nothing.

## Why accuracy is so much tougher than mass

We still owe an explanation for the decoupling. Why can the model afford to lose a third of its attention mass?

Follow the mass loss through the read-out. Truncating an attention row to a set $T$ carrying mass $\rho$ and renormalizing changes the layer's output vector by at most $2(1-\rho)B$, where $B$ bounds the value vectors: one factor $(1-\rho)B$ for the dropped tail, one for the renormalization inflation. Now, a prediction is an arg-max over class scores, and an arg-max survives *any* perturbation smaller than half its margin over the runner-up. If the score map is $L$-Lipschitz in the attention output, the prediction is preserved whenever

$$4L(1-\rho)B \;<\; m,$$

where $m$ is the held-out logit margin — equivalently, whenever the retained mass satisfies

$$\rho \;>\; 1 - \frac{m}{4LB}.$$

There it is. The threshold on retained mass is not $0.98$; it is $1 - m/(4LB)$, a number set by the *margin*, and for a healthy margin it sits far below $0.98$. The accuracy knee is permitted to undercut the mass knee, exactly as measured, and the two should converge as margins shrink.

Better: the mechanism pins the deficit two-sidedly. Let $k^\ast$ be the least budget whose Zipf tail fits under the threshold $m/(4LB)$. Because the true budget is a ceiling, it sits in the window $[x, 2x]$ with $x = 4LBA\,\mathrm{ctx}/m$, and therefore

$$\frac{m}{8LB} \;\le\; 1 - \rho(k^\ast) \;\le\; \frac{m}{4LB}.$$

The attention deficit at the knee is $\Theta\!\big(m/(LB)\big)$, with explicit constants $1/8$ and $1/4$. The knee is antitone in the margin — a model with a healthier margin never needs a *larger* budget — and the real budget scales exactly like $1/m$. The dimensionless quantity $k^\ast m / (4LBA\,\mathrm{ctx})$ is confined to $[1,2]$: a window fixed in advance, with no free constant.

And it makes a number. At the long-context cell, the certified mass ceiling $\rho \le 0.65$ combined with the retention threshold forces $m > 1.4\,LB$. If a measurement of the held-out logit margin came in below that, the margin-channel explanation would be dead. The prediction is on the table.

## Two settled sub-questions, and a control

Three more pieces close the picture.

**The concentration drift is not tail drift.** The measured $N_{\mathrm{eff}}$ creeps upward with depth at fixed context: $46.6 \to 50.2 \to 52.7$ across $d = 4, 8, 16$. The tempting reading is that the Zipf amplitude $A$ drifts with depth. It cannot. A depth-linear knee forces $A = \delta/32$ *at every depth* — no freedom is left — so $A(d)\cdot d$ grows linearly rather than staying constant, refuting the conjectured form. What survives is a *ceiling*: a scale-free tail of amplitude $A$ caps the effective support at $N_{\mathrm{eff}} \le 8A\,\mathrm{ctx} + 4$, which with $A = \delta/32$ becomes the depth-independent bound $N_{\mathrm{eff}} \le \delta\,\mathrm{ctx}/4 + 4$. All three drifting numbers must live under one ceiling. Feeding the deepest cell's $N_{\mathrm{eff}} = 52.73$ at $\mathrm{ctx}=128$ backwards gives $\delta \ge 1.52$: the end-to-end error budget implicit in the fitted $1/32$ cannot be small.

**Long context is predicted, not extrapolated.** If the effective support keeps pace with context, $N_{\mathrm{eff}} \ge \alpha\cdot\mathrm{ctx}$, then at the law's own budget $k = d\,\mathrm{ctx}/32$ the retained mass is at most $\sqrt{d/(32\alpha)}$ — a bound with *no context in it*. At $d=4$, $\alpha=1$ it reads $0.354 < 1/2$. So the pre-registered claim for the untested $\mathrm{ctx}=1024$ cell: at the predicted knee $k^\ast = 128$, the retained mass is at most $0.36$. A run reporting $\ge 0.98$ retained accuracy there certifies a mass/accuracy separation of at least $2.7\times$; a run reporting more than $0.36$ retained mass refutes the linear growth of $N_{\mathrm{eff}}$. Either way the experiment is decisive.

**The control is fair.** Every sweep is paired with a random-$k$ control: keep $k$ positions chosen uniformly at random instead of the top $k$. Averaged over all $k$-subsets, the random control retains exactly the fraction $k/\mathrm{ctx}$ of the mass — a clean double-counting identity, since each position lies in the same number of subsets. Selection, by the Cauchy–Schwarz bound, retains at most $\sqrt{k/N_{\mathrm{eff}}}$. So the mass advantage of selection over the control is at most $\mathrm{ctx}/\sqrt{k\,N_{\mathrm{eff}}}$, which at the long-context cell ($\mathrm{ctx}=512$, $k=64$, $N_{\mathrm{eff}}=152.11$) is at most $5.2$. Selection cannot be buying more than $5.2\times$ the control's mass — yet the measured accuracy gaps between selection and control are $+7.6$ and $+5.2$ points. The gap is about *which* positions are kept, not how much bulk weight they carry.

## The knee is stable, and the grid is complete

One last worry: is the knee just noise? Rerun with a different random seed and does it move?

No, and there is a stability theorem. If a rerun's retained-accuracy curve stays within $\eta$ of the measured curve at every swept budget, and the measured curve clears the $0.98$ threshold at $k$ with margin $\eta$ while failing at every smaller swept budget with margin $\eta$, then the rerun reports the *same* knee.

Apply it to the measured curves. The depth-$16$ cell passes at $64$ with $0.996$ and fails at $32$ with $0.970$: both margins exceed $0.005$, so the knee is immune to seed perturbations up to $\eta = 0.005$. The long-context cell passes at $64$ with $0.985$ and fails at $32$ with $0.976$: margins of $0.005$ and $0.004$, so it tolerates $\eta = 0.003$. The observed seed-to-seed spread is $\pm 0.002$ — strictly inside both windows. *No seed could have moved either knee.*

That closes the grid. Every measured cell of the depth-by-context grid has now been confirmed at two independent seeds, and every one lands exactly on $d\cdot\mathrm{ctx}/32$. An earlier worry — that the long-context margin was eroding — turns out to be a $\pm 0.002$ seed fluctuation rather than a trend: the pass margin was $0.003$ at one seed and $0.005$ at the next.

## What to take away

Three things.

First, an engineering rule with a proof behind it: at depth $d$, a transformer can restrict its attention to $\mathrm{ctx}\cdot d/32$ positions per row and keep $98\%$ of its accuracy, for a speedup of $32/d$ that does not degrade as the context grows.

Second, a correction to the folklore. "Attention is sparse, so truncation is cheap" is not the mechanism. At the measured concentration, the budget that keeps the accuracy provably throws away over a third of the mass, and no concentration statistic can predict the knee — a distribution can look like it uses four positions while stubbornly hiding half its mass from every fixed budget. What actually explains the law is the interaction between how truncation errors accumulate through a nonexpansive stack and how much slack the decision margin leaves at the read-out.

Third, and most interesting to me: the empirical grid turned out to contain more information than it appeared to. Two qualitative observations — the speedup depends only on depth, and the budget grows linearly with depth — are enough to force the entire functional form $k^\ast \propto d\cdot\mathrm{ctx}$ *and* the $1/x$ shape of the attention tail. Everything else in the story reduces to one fitted number, $1/32$. That is unusual. Most empirical scaling laws are curves through points. This one is a theorem with a constant attached.
