# The Floor Beneath Alignment: Why a Little Pretraining Data Never Washes Out

## A dial that goes to infinity, and still doesn't reach zero

Imagine you are tuning a language model. You have a base model — call its output distribution $p$ — that has been trained to imitate human demonstrations. Now you want it to be *better*: more helpful, more truthful, less prone to inventing citations. You have a reward function $r$ that scores each possible output $y$ with a number $r(y)$, and you want the model to produce high-reward outputs.

The obvious move — just maximize the reward — is a disaster. A model told only to maximize a score will find the score's blind spots and live in them. The standard fix is a leash: penalize the new policy $q$ for straying from the old one $p$, measured by the Kullback–Leibler divergence $\mathrm{KL}(q \,\|\, p)$. The objective becomes

$$\max_q \; \mathbb{E}_q[r] - \beta \cdot \mathrm{KL}(q \,\|\, p),$$

where $\beta > 0$ is the strength of the leash. This problem has a beautiful closed-form answer, known since Gibbs: the optimum is an exponential tilt of the base model,

$$\pi_\beta(y) \;\propto\; p(y)\, e^{r(y)/\beta}.$$

The parameter $\beta$ behaves exactly as intuition demands. Small $\beta$ means a loose leash and aggressive reward-chasing. Large $\beta$ means a tight leash. And in the limit $\beta \to \infty$ the tilt $e^{r(y)/\beta} \to 1$ uniformly, so $\pi_\beta \to p$: crank the dial far enough and you get your original model back, unchanged. Nothing has been risked, and nothing has been gained.

An earlier result made this quantitative. Measuring distance by the $\ell^1$ (total variation) norm $\|f - g\|_1 = \sum_y |f(y) - g(y)|$, the aligned policy drifts away from the base policy at rate exactly $1/\beta$:

$$\|\pi_\beta - p\|_1 \;=\; \Theta\!\left(\frac{\sigma_p(r)}{\beta}\right),$$

where $\sigma_p(r)$ is the standard deviation of the reward under $p$. A flat reward moves nothing; a high-variance reward moves a lot; and the leash strength divides it all. Clean, and reassuring: the dial works.

**This article is about what happens when you add one more standard ingredient to the recipe, and the dial stops working.**

## The ingredient: pretraining mix-in

In production alignment pipelines — the InstructGPT recipe and its descendants — there is a well-known auxiliary trick called the **PTX pretraining mix-in**. Alignment training has a habit of degrading capabilities: a model tuned hard on a helpfulness reward may forget how to do arithmetic, or start writing in a strange flattened register. The fix is to fold a fraction of the original pretraining data back into the training objective. If a fraction $\gamma$ of each batch comes from the pretraining distribution $d$, the model is being simultaneously pulled toward $d$ and toward high reward.

The cleanest way to model this is to say the mix-in replaces the *anchor* of the leash. Instead of measuring divergence from $p$, we measure it from the mixture

$$p_\gamma \;=\; (1-\gamma)\,p \;+\; \gamma\, d,$$

and the objective becomes

$$\max_q \; \mathbb{E}_q[r] - \beta \cdot \mathrm{KL}(q \,\|\, p_\gamma),$$

whose optimum — and this is a genuine theorem, not a definition, established below — is

$$q^*_{\beta,\gamma}(y) \;\propto\; \bigl((1-\gamma)p(y) + \gamma d(y)\bigr)\, e^{r(y)/\beta}.$$

Every ingredient is standard. The question is what the dial does now.

## The answer: the drift splits into two scales

Here is the central result.

> **The two-scale drift law.** Suppose $p$ and $d$ are distributions on a finite output space, $0 \le \gamma \le 1$, and the reward satisfies $L \le r(y) \le M$ for all $y$. Then for every $\beta > 0$,
> $$\Bigl|\; \|q^*_{\beta,\gamma} - p\|_1 \;-\; \gamma\,\|d - p\|_1 \;\Bigr| \;\le\; e^{(M-L)/\beta}\, \frac{\sigma_{p_\gamma}(r)}{\beta}.$$

Read the two sides slowly. On the left is the total displacement of the aligned model from the base model, compared with a quantity that *does not contain $\beta$ at all*: $\gamma \|d - p\|_1$, the distance the mix-in alone drags the anchor. On the right is a familiar $\sigma/\beta$ envelope — the reward-induced part of the drift, which does vanish as the leash tightens.

Let the leash go to infinity and the envelope collapses:

> **The alignment floor.** As $\beta \to \infty$,
> $$\|q^*_{\beta,\gamma} - p\|_1 \;\longrightarrow\; \gamma\,\|d - p\|_1.$$
> In particular, if $\gamma > 0$ and $d \neq p$, then $\|q^*_{\beta,\gamma} - p\|_1$ does **not** tend to zero.

The dial no longer goes to zero. No matter how strongly you regularize, the model you end up with sits a fixed distance $\gamma\|d-p\|_1$ away from the model you started with. The reward's influence can be tuned away; the pretraining mix-in's influence cannot. It is a floor, and its height is the product of two entirely non-negotiable quantities: how much pretraining data you mixed in, and how different that data is from your supervised model.

This is not a subtle failure mode hidden in the tails. It is the leading-order behaviour. The $\Theta(\sigma/\beta)$ law from before is still true — but it now describes a *correction term* sitting on top of a constant.

## Why the floor is really there

The proof is short enough to sketch in words, which is a sign that the phenomenon is structural rather than accidental.

Write $q^*_{\beta,\gamma}$ as the exponential tilt of the anchor $p_\gamma$. Then the triangle inequality in $\ell^1$ gives, in both directions,

$$\bigl|\; \|q^*_{\beta,\gamma} - p\|_1 - \|p_\gamma - p\|_1 \;\bigr| \;\le\; \|q^*_{\beta,\gamma} - p_\gamma\|_1.$$

Two facts finish it. First, the anchor displacement is *exactly* computable, with no error term at all:

$$\|p_\gamma - p\|_1 \;=\; \sum_y \bigl|(1-\gamma)p(y) + \gamma d(y) - p(y)\bigr| \;=\; \sum_y \gamma\,|d(y) - p(y)| \;=\; \gamma\,\|d - p\|_1 .$$

Second, the distance from the tilt to its own anchor obeys the old law: for any anchor $m$ and any reward bounded between $L$ and $M$,

$$\|\text{tilt}_\beta(m) - m\|_1 \;\le\; e^{(M-L)/\beta}\,\frac{\sigma_m(r)}{\beta},$$

which goes to zero. So the total displacement is pinned to the anchor displacement, up to a vanishing error. The tilt is a $1/\beta$-sized perturbation; the anchor shift is not a perturbation at all.

The estimate on the tilt itself uses no calculus — no differentiating the free energy. It rests on a one-line convexity inequality, $|e^a - e^b| \le e^{\max(a,b)}|a-b|$, which converts the exponential tilt into a linear deviation, plus the variational fact that variance is the smallest mean squared deviation, $\mathrm{Var}(X) \le \mathbb{E}(X-c)^2$ for any constant $c$.

## It is not an artifact of how we modeled the mix-in

A reasonable objection: maybe the arithmetic mixture $p_\gamma = (1-\gamma)p + \gamma d$ is the wrong model. Perhaps a different way of folding in pretraining data — say, adding a $\mathrm{KL}(q\|d)$ term to the objective rather than mixing the data itself — behaves better.

It does not, and the reason is completely general.

> **The floor is exactly the anchor displacement.** For *any* anchor distribution $m$ and any bounded reward $r$, the exponential tilt satisfies $\|\text{tilt}_\beta(m) - p\|_1 \to \|m - p\|_1$ as $\beta \to \infty$. Consequently, $\|\text{tilt}_\beta(m) - p\|_1 \to 0$ **if and only if** $m = p$.

The reward washes out; the anchor never does. So the floor is not a property of the arithmetic mixture — it is a property of *having moved the anchor at all*. Regularizing with the convex combination $(1-\gamma)\mathrm{KL}(q\|p) + \gamma\,\mathrm{KL}(q\|d)$ produces the *geometric* mix-in anchor $p^{1-\gamma}d^{\gamma}/Z$, and the same theorem applies verbatim: the optimum returns to $p$ only if that log-linear blend happens to equal $p$, which for $\gamma>0$ requires $d=p$. Every mix-in mechanism that displaces the anchor pays the same kind of tax.

## The tax, denominated in reward

Total variation distance is an abstraction. Practitioners care about numbers on a scorecard, so it is worth dualizing the floor against the reward itself.

> **The reward-level alignment tax.** If $|r| \le C$ everywhere, then as $\beta \to \infty$,
> $$\mathbb{E}_{q^*_{\beta,\gamma}}[r] \;\longrightarrow\; \mathbb{E}_p[r] \;+\; \gamma\bigl(\mathbb{E}_d[r] - \mathbb{E}_p[r]\bigr).$$

Another $\beta$-independent shift. If the pretraining distribution scores worse on your reward than your supervised model does — which is the normal situation, since the supervised model was built precisely to score well — then $\mathbb{E}_d[r] < \mathbb{E}_p[r]$, and the limit sits *below* $\mathbb{E}_p[r]$. Mixing in pretraining data costs you a fixed number of reward points that no amount of tuning $\beta$ can recover. This is the honest price of the capability-preservation insurance policy, and now it has a formula: $\gamma$ times the reward gap between the pretraining corpus and the supervised model.

## A surprise inside the correction term

So far the story is that the reward-induced part of the drift is a vanishing $\Theta(\sigma/\beta)$ correction. Look at it closely, and two things turn out to be more interesting than expected.

### The sharp constant is not the standard deviation

The $\sigma/\beta$ upper bound is correct, but it is not tight. The exact first-order constant is a different statistic:

> **The sharp drift constant.** For any anchor $m$ and bounded reward $r$,
> $$\beta \cdot \|\text{tilt}_\beta(m) - m\|_1 \;\longrightarrow\; \mathbb{E}_m\bigl|r - \mathbb{E}_m r\bigr| \;=\; \mathrm{MAD}_m(r),$$
> the **mean absolute deviation** of the reward, not its standard deviation.

The reason is visible in one line. The rescaled drift $\beta(q_\beta(y) - m(y))$ converges pointwise to $m(y)(r(y) - \mathbb{E}_m r)$ — the centered reward, weighted by the anchor. Summing absolute values gives $\sum_y m(y)|r(y) - \mathbb{E}_m r|$, and that is the mean absolute deviation by definition. The $\ell^1$ norm sees $\mathbb{E}|X|$; only an $\ell^2$ norm would see $\sqrt{\mathbb{E}X^2}$. The standard deviation appeared in the earlier bound because a Cauchy–Schwarz step was used to control the sum, and Cauchy–Schwarz is lossy.

How lossy? Exactly as lossy as it needs to be, and the gap is fully characterized:

> **The sandwich.** For a reward with $L \le r \le M$ and $L < M$,
> $$\frac{\sigma_m(r)^2}{M-L} \;\le\; \mathrm{MAD}_m(r) \;\le\; \sigma_m(r).$$

The right inequality is Cauchy–Schwarz (or Jensen). The left one comes from $|x|^2 \le (M-L)|x|$ for any centered deviation $x$, since no deviation can exceed the reward's range. So the $\Theta(\sigma/\beta)$ reading of the law is legitimate, but only up to the dimensionless factor $\sigma/(M-L)$ — and it is not improvable to an equality. The honest constant is the MAD.

This is a small correction to the folklore, but it matters if you want to *predict* drift rather than merely bound it. For a reward that is a near-binary preference signal, MAD and $\sigma$ differ by a bounded factor; for a heavy-tailed reward with rare large values, they can differ substantially, and the standard deviation will systematically over-predict the drift.

### Reward optimization can partially *repay* the tax

The second surprise concerns the total drift from $p$ rather than from the anchor. Naively one might guess that the $1/\beta$ correction simply adds to the floor: pretraining pushes you a distance $\gamma\|d-p\|_1$, and reward pushes you a bit further. That is wrong, and the reason is a change of geometry.

Once the mix-in has moved every coordinate — that is, once $p_\gamma(y) \ne p(y)$ for every output $y$ — the sign of $q^*_{\beta,\gamma}(y) - p(y)$ is *frozen* for all large $\beta$, because the tilt is a small perturbation of an anchor already strictly on one side of $p$. The absolute values in $\|\cdot\|_1$ therefore become linear functions, and everything collapses:

> **The exact $1/\beta$ correction.** If $p_\gamma(y) \ne p(y)$ for every $y$, then
> $$\beta\Bigl(\|q^*_{\beta,\gamma} - p\|_1 - \gamma\|d-p\|_1\Bigr) \;\longrightarrow\; \sum_y \operatorname{sgn}\bigl(p_\gamma(y) - p(y)\bigr)\, p_\gamma(y)\,\bigl(r(y) - \mathbb{E}_{p_\gamma} r\bigr).$$

This is a **signed covariance** between the reward and the direction in which the mix-in displaced the anchor. Unlike the mean absolute deviation, it can be negative. Concretely: if the reward happens to be high exactly on those outputs where the mix-in *decreased* the probability relative to $p$, then tilting toward the reward pushes those coordinates back up, back toward $p$ — and the total drift shrinks.

In other words, the alignment tax is not always paid in full. Reward optimization can partially cancel it, when the reward and the pretraining mixture are anticorrelated in the right sense. The floor $\gamma\|d-p\|_1$ is unmovable, but the approach to it from above can turn into an approach from below.

## What this means

Three practical readings, each a direct restatement of a theorem.

**The KL coefficient is not a safety dial once you mix in pretraining data.** The mental model "large $\beta$ means the model stays close to the reference" is exactly true when $\gamma = 0$ and exactly false when $\gamma > 0$. The residual displacement $\gamma\|d-p\|_1$ is set entirely by hyperparameters of the *data* pipeline, not the *optimization* pipeline. If you want a bound on how far the aligned model can be from the supervised model, tuning $\beta$ will not give you one; only reducing $\gamma$, or making the pretraining mixture closer to $p$, will.

**The floor is measurable before training.** Both $\gamma$ and $\|d - p\|_1$ are known or estimable quantities. You can compute the floor — and the reward-units version, $\gamma(\mathbb{E}_d[r] - \mathbb{E}_p[r])$ — before you spend a single GPU-hour, and decide whether the capability insurance is worth the premium.

**The mechanism is universal across mix-in designs.** Because the limit of $\|\text{tilt}_\beta(m) - p\|_1$ is exactly $\|m - p\|_1$ for every anchor $m$, no clever reformulation of the mix-in avoids the floor. Arithmetic mixture, geometric mixture, a second KL term — all displace the anchor, all pay. The only escape is to leave the anchor at $p$.

## Coda

There is a satisfying inevitability to the result. The KL leash and the exponential tilt live at scale $1/\beta$: they are perturbative, and perturbations can be turned off. The anchor lives at scale $1$: it is where the optimization problem *starts*, and no amount of pulling on the leash changes where the post is planted.

That the total drift then splits cleanly into a constant plus a $1/\beta$ term — with the constant computed exactly, and the $1/\beta$ coefficient identified as a mean absolute deviation from the anchor and a signed covariance from the base policy — is what turns a slogan into mathematics. Alignment pipelines are full of small auxiliary tricks added for good empirical reasons. This one, examined closely, turns out to change the asymptotics of the whole procedure.

The leash still works. It is just tied to a different post.
