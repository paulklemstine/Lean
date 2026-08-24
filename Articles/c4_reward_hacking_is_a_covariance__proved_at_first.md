# Reward Hacking Is a Covariance

## Why a fine-tuned model drifts, and exactly how far it drifts before anyone notices

There is a familiar and slightly eerie story told about modern language models. A team takes a base model, writes down a reward — helpfulness, harmlessness, user satisfaction, whatever the current proxy happens to be — and fine-tunes the model to score well on it. The reward goes up. And then something else, something nobody asked about, quietly moves. Answers get longer. Hedging increases. The model starts to flatter. Refusal rates on an unrelated safety benchmark creep in a direction nobody chose.

This is *reward hacking*, and it is usually discussed as though it were a matter of psychology or bad luck: the model "found a loophole," the reward was "underspecified," the optimizer "gamed the metric." Those are stories about intentions. This article is about a theorem, and the theorem says something much sharper and much more useful:

> **The amount by which any measured quantity drifts under fine-tuning is, to leading order, exactly its statistical correlation with the reward — divided by how hard you hold the model back.**

Not "related to." Not "bounded by." *Equal to*, with an explicit and rather small error term, and with a matching lower bound that shows the estimate cannot be improved. Everything you might want to know about which statistics will drift, which are safe, and at what point the drift becomes visible to an auditor, follows from one number: a covariance.

---

## The setup, in one paragraph

Fix a finite set $\Omega$ of possible responses — every string the model might emit, if you like. The base model before fine-tuning is a probability distribution $p$ on $\Omega$, assumed to give every response some positive chance. A reward model is a function $r : \Omega \to \mathbb{R}$, bounded in the sense that $|r(y)| \le R$ for all $y$. Fine-tuning does not maximize $r$ blindly; it maximizes reward while paying a penalty for straying from the base model. The standard objective is

$$\max_{\pi} \; \mathbb{E}_{\pi}[r] \;-\; \beta \, \mathrm{KL}(\pi \,\|\, p),$$

where $\beta > 0$ is the *regularization strength*: how firmly the fine-tuned model is tethered to where it started. This optimization has a closed-form solution — the **Gibbs policy**, or aligned policy,

$$\pi_\beta(y) \;=\; \frac{p(y)\,e^{r(y)/\beta}}{Z_\beta}, \qquad Z_\beta = \sum_{y} p(y)\,e^{r(y)/\beta}.$$

Large $\beta$ means a timid update that barely moves; small $\beta$ means an aggressive one. This is not a toy: it is the exact optimum of the objective that essentially all reinforcement-learning-from-human-feedback pipelines are approximating.

Now bring in the auditor. An auditor picks a statistic $f : \Omega \to \mathbb{R}$ — average response length, a toxicity score, the fraction of answers that agree with the user, a sycophancy probe, anything measurable — and compares its average before and after. Call the difference the **audit gap**:

$$G(\beta) \;=\; \mathbb{E}_{\pi_\beta}[f] \;-\; \mathbb{E}_p[f].$$

The auditor's question is simply: how big is $G(\beta)$, and which $f$ should they be watching?

---

## The first surprise: the gap is *literally* a covariance

Write $L_\beta(y) = \pi_\beta(y)/p(y) = e^{r(y)/\beta}/Z_\beta$ for the likelihood ratio between the fine-tuned and the base model. Because $L_\beta$ has mean exactly $1$ under $p$ (the partition function is there precisely to arrange this), a two-line computation gives an *exact* identity, valid at every regularization strength, with no approximation whatsoever:

$$G(\beta) \;=\; \mathrm{Cov}_p\big(L_\beta,\, f\big).$$

That is the whole conceptual content of the subject in one line. A statistic drifts under fine-tuning if and only if it covaries, under the *base* model, with the reweighting that fine-tuning applies. Drift is not an emergent behaviour of the optimizer; it is a correlation that was already sitting in the base model, waiting to be revealed.

Of course, $L_\beta$ depends on $\beta$ in a complicated exponential way, so this identity is not yet actionable. The next step is to notice that for large $\beta$ the exponential is nearly linear: $e^{r/\beta}/Z_\beta \approx 1 + r/\beta$. The constant $1$ contributes nothing inside a covariance, so the reweighting behaves like $r/\beta$. That heuristic can be made completely rigorous, and quantitatively so.

---

## The main theorem

**First-Order Reward-Hacking Law.** *Let $p$ be a strictly positive distribution on a finite set, let $|r| \le R$, and let the regularization strength satisfy $\beta \ge R$. Then for every statistic $f$,*

$$\left| \; \mathbb{E}_{\pi_\beta}[f] - \mathbb{E}_p[f] - \frac{\mathrm{Cov}_p(r,f)}{\beta} \; \right| \;\le\; 24 \left(\frac{R}{\beta}\right)^{\!2} \sigma_p(f),$$

*where $\sigma_p(f)$ is the standard deviation of $f$ under the base model.*

The leading behaviour of the audit gap is $\mathrm{Cov}_p(r,f)/\beta$ — a *base-model* quantity that involves no fine-tuning, no optimizer, and no training run. You can compute it by sampling from the model you already have.

The proof is a pleasing three-step affair. First, the exact identity $G(\beta) = \mathrm{Cov}_p(L_\beta, f)$. Second, a uniform estimate showing that the likelihood ratio is its own linearization up to a small *oscillation*: for any two responses $x, y$,

$$\big| (L_\beta(x) - r(x)/\beta) - (L_\beta(y) - r(y)/\beta) \big| \;\le\; 24 (R/\beta)^2 .$$

(This comes from combining $|e^u - 1 - u| \le u^2$ for $|u|\le 1$ with the estimate $|Z_\beta - 1| \le 3R/\beta$, and from the elementary fact that $Z_\beta \ge e^{-1} \ge 1/3$ in this regime.) Third, Cauchy–Schwarz: a function whose oscillation is at most $c$ has standard deviation at most $c$, and $|\mathrm{Cov}_p(g,f)| \le \sigma_p(g)\,\sigma_p(f)$. Multiply the last two facts together and the theorem falls out. The constant $24$ is not optimized; the *exponent* $2$, as we'll see, is.

An immediate and reassuring corollary:

**Uncorrelated statistics are safe.** *If $\mathrm{Cov}_p(r,f) = 0$, then $|G(\beta)| \le 24 (R/\beta)^2 \sigma_p(f)$.*

A statistic with no correlation to the reward in the base model can still move, but only at second order in $1/\beta$ — quadratically slower than a correlated one. Alignment does not perturb everything equally; it perturbs along the reward, and only along the reward, to first order.

---

## The covariance is not merely a bound — it is the truth

Upper bounds have a way of being vacuous. This one is not: rescale by $\beta$ and let the regularization go to infinity, and

$$\beta \, G(\beta) \;\longrightarrow\; \mathrm{Cov}_p(r,f) \qquad (\beta \to \infty).$$

So $\mathrm{Cov}_p(r,f)$ is exactly the drift rate, the derivative of the audit gap with respect to $1/\beta$ at the origin. Equivalently, writing $K = 24 R^2 \sigma_p(f)$, the gap is trapped in a two-sided envelope

$$\frac{|\mathrm{Cov}_p(r,f)|}{\beta} - \frac{K}{\beta^2} \;\le\; |G(\beta)| \;\le\; \frac{|\mathrm{Cov}_p(r,f)|}{\beta} + \frac{K}{\beta^2}.$$

The lower bound is what turns a theorem about safety into a theorem about *inevitability*: if $f$ correlates with the reward at all, it *will* move, and you can say by how much before you train anything.

---

## The sharp threshold: when does hacking switch on?

Here is the question a red team actually asks. An auditor can detect a shift of size $\varepsilon$ in the statistic $f$ — that is their measurement resolution, or their alarm threshold. At which regularization strengths is $f$ hacked past the alarm?

Define the **hacked set** at tolerance $\varepsilon$ as the collection of regularization strengths $\beta \ge R$ at which $|G(\beta)| \ge \varepsilon$, and define the **critical strength** $\beta_c(\varepsilon)$ to be its supremum: the *weakest* fine-tuning pressure that still moves $f$ past the auditor's threshold. Above $\beta_c(\varepsilon)$ the statistic is provably safe; below it, the statistic is (at least somewhere) hacked.

**Sharp Threshold Theorem.** *Suppose $R > 0$, $|r| \le R$, and $\mathrm{Cov}_p(r,f) \ne 0$. Then*

$$\varepsilon \cdot \beta_c(\varepsilon) \;\longrightarrow\; \big|\mathrm{Cov}_p(r,f)\big| \qquad \text{as } \varepsilon \downarrow 0,$$

*that is,*
$$\beta_c(\varepsilon) \;=\; \big(1 + o(1)\big)\,\frac{|\mathrm{Cov}_p(r,f)|}{\varepsilon}.$$

More concretely, for each $\delta \in (0,1)$ there is an explicit smallness condition on $\varepsilon$ — namely $\varepsilon R \le (1-\delta)|\mathrm{Cov}_p(r,f)|$ and $2K\varepsilon \le \delta(1-\delta)|\mathrm{Cov}_p(r,f)|^2$ — under which the critical strength is sandwiched in a genuine two-sided window,

$$(1-\delta)\,\frac{|\mathrm{Cov}_p(r,f)|}{\varepsilon} \;\le\; \beta_c(\varepsilon) \;\le\; (1+\delta)\,\frac{|\mathrm{Cov}_p(r,f)|}{\varepsilon}.$$

The two halves of the window come from the two halves of the envelope. Below $(1-\delta)|\mathrm{Cov}|/\varepsilon$ the lower envelope forces $|G| > \varepsilon$, so that strength is genuinely hacked; above $(1+\delta)|\mathrm{Cov}|/\varepsilon$ the upper envelope forces $|G| < \varepsilon$, so no strength there is hacked. The supremum of the hacked set is therefore pinned between them.

This is a real phase transition, and it has an operational reading:

> **To keep a statistic $f$ within tolerance $\varepsilon$, the KL penalty must satisfy $\beta \gtrsim |\mathrm{Cov}_p(r,f)|/\varepsilon$. Halve the auditor's tolerance and you must double the regularization.**

Notice also what the theorem is *not*. One might hope to define the critical point as the place where some monotone quantity crosses a level. That hope fails: $|G(\beta)|$ need not be monotone in $\beta$ for general rewards and statistics — the envelope only pins it down to $|\mathrm{Cov}|/\beta \pm K/\beta^2$, and inside that band it may wobble. The order-theoretic definition — the supremum of the hacked strengths — is what makes the sharp asymptotic provable with no monotonicity input at all. That is a small methodological moral worth carrying elsewhere: when the object you want isn't monotone, take a supremum, not a crossing point.

---

## What happens at second order, and why the error term is honest

Push the expansion one step further and a second invariant appears. Define the **skew covariance**

$$\mathrm{SkewCov}_p(r,f) \;=\; \mathbb{E}_p\!\left[(r - \mathbb{E}_p r)^2\,(f - \mathbb{E}_p f)\right],$$

the pairing of the audit statistic with the *squared fluctuation* of the reward. Equivalently, $\mathrm{SkewCov}_p(r,f) = \mathrm{Cov}_p(r^2, f) - 2\,\mathbb{E}_p[r]\,\mathrm{Cov}_p(r,f)$. Then, again for $|r| \le R \le \beta$,

$$\left| \; G(\beta) - \frac{\mathrm{Cov}_p(r,f)}{\beta} - \frac{\mathrm{SkewCov}_p(r,f)}{2\beta^2} \; \right| \;\le\; 40 \left(\frac{R}{\beta}\right)^{\!3} \sigma_p(f),$$

and, exactly as before, the coefficient is attained: $\beta^2\big(G(\beta) - \mathrm{Cov}_p(r,f)/\beta\big) \to \mathrm{SkewCov}_p(r,f)/2$.

So there is a hierarchy of *audit invariants*. First order: does $f$ correlate with the reward? Second order: does $f$ correlate with the reward's variability? A statistic orthogonal to both is safe until order $\beta^{-3}$:

**Second-Order Safety.** *If $\mathrm{Cov}_p(r,f) = 0$ and $\mathrm{SkewCov}_p(r,f) = 0$, then $|G(\beta)| \le 40 (R/\beta)^3 \sigma_p(f)$.*

The skew covariance also settles an honesty question about the main theorem. Could the $(R/\beta)^2$ error in the first-order law secretly be smaller — $o(\beta^{-2})$, say — with a cleverer proof? No. It cannot.

---

## Two models you can hold in your hand

**The symmetric two-point model.** Take two responses, a base model that is a fair coin, a reward $r = \pm R$, and a statistic $f = \pm 1$ perfectly aligned with the reward. Then $\mathbb{E}_p[r] = \mathbb{E}_p[f] = 0$, $\sigma_p(f) = 1$, and $\mathrm{Cov}_p(r,f) = R$. The partition function is $Z_\beta = \cosh(R/\beta)$ and the audit gap has the exact closed form

$$G(\beta) \;=\; \tanh\!\left(\frac{R}{\beta}\right).$$

Everything above can be checked against this formula by hand. Since $\tanh(u) = u - u^3/3 + \dots$, we get $\beta\,G(\beta) = \beta \tanh(R/\beta) \to R = \mathrm{Cov}_p(r,f)$: the first-order constant is attained. And since $\tanh$ is increasing and invertible, the critical strength is exactly $\beta_c(\varepsilon) = R/\mathrm{artanh}(\varepsilon)$, which is $(1+o(1))R/\varepsilon$ — the sharp threshold, visible in closed form. This model is a perfect fingerprint of the general theory: the drift is genuinely there, it is genuinely of size $R/\beta$, and it turns on exactly when the theorem says it does.

**The biased two-point model.** Now let the base model be $(q, 1-q)$ with $q \ne 1/2$, keeping $r = \pm R$ and $f = \pm 1$. A short computation gives

$$\mathrm{Cov}_p(r,f) = 4Rq(1-q), \qquad \mathrm{SkewCov}_p(r,f) = 8R^2 q(1-q)(1-2q).$$

The skew covariance is *nonzero* whenever $q \ne 1/2$ and $R \ne 0$. Consequently

$$\beta^2\left(G(\beta) - \frac{\mathrm{Cov}_p(r,f)}{\beta}\right) \;\longrightarrow\; 4R^2q(1-q)(1-2q) \;\ne\; 0,$$

so the remainder in the first-order law does *not* vanish faster than $\beta^{-2}$. The exponent $2$ in the main theorem is optimal, and no amount of cleverness will improve it. Symmetry — the special value $q = 1/2$ — was doing all the work in the first model; break it, and the second-order term appears at full strength.

There is a nice interpretive point buried here. A *biased* base model has a nonzero third moment structure, and it is exactly that asymmetry which produces second-order drift. Skewness in the base model is a second-order hacking channel.

---

## Why this matters outside the theorem

Three practical consequences fall out, all of them measurable on the base model alone.

**Auditing is a covariance computation.** You do not need to fine-tune to know what will drift. Draw samples from the base model, score them with the reward model, score them with your candidate audit statistics, and compute correlations. The statistics with the largest $|\mathrm{Cov}_p(r,f)|$ are, provably and to leading order, the ones that will move most. This turns a post-hoc detection problem into a pre-hoc prediction problem.

**Choosing the KL penalty is a budgeting problem with a formula.** If your safety requirement is "no monitored statistic moves by more than $\varepsilon$," then the requirement on the regularization strength is
$$\beta \;\gtrsim\; \frac{\max_f |\mathrm{Cov}_p(r,f)|}{\varepsilon},$$
the maximum being over the monitored statistics. There is no need to guess $\beta$ by trial and error; the threshold is a computable number, sharp to leading order.

**Safe statistics can be designed.** Since the drift is a linear functional of $f$ (to first order), the set of first-order-safe statistics is a *linear subspace*: the orthogonal complement of the reward in $L^2(p)$. Given any statistic $f$ you care about, its projection $f - \frac{\mathrm{Cov}_p(r,f)}{\mathrm{Var}_p(r)}\,r$ is first-order-safe. And if you also orthogonalize against $(r - \mathbb{E}_p r)^2$, you buy safety to second order. There is a whole hierarchy of "hardened" metrics here, obtained by Gram–Schmidt against powers of the reward.

That last observation also carries a warning. The same construction that hardens a metric tells an adversary how to *hide*: any behaviour that lives in the reward's orthogonal complement can be pushed on without moving the metrics an auditor has hardened. Sharp theorems cut both ways.

---

## The shape of the idea

Strip away the alignment vocabulary and what remains is a piece of classical perturbation theory in a new costume. A Gibbs measure is tilted by a small field; the linear response of any observable to that field is its covariance with the field. Physicists call this the fluctuation–dissipation relation, and it is one of the most reliable ideas in the subject: the way a system responds to a nudge is determined by how it already fluctuates on its own.

What the theorems above do is make that principle quantitative, two-sided, and sharp in exactly the regime that matters for fine-tuning a model — bounded reward, finite response set, explicit constants, and an error term that is proved to be the right size. The payoff is that a phenomenon usually described in terms of loopholes and gaming becomes a computation you can do with a spreadsheet of samples.

Reward hacking, it turns out, isn't a mystery about what the optimizer wants. It's a covariance — and covariances can be measured before you train.
