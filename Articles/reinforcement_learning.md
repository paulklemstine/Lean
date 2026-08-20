# The Leash and the Lie Detector: How Much Can Alignment Change a Model?

## A tug-of-war in three terms

Every modern language assistant is, at bottom, the outcome of an argument between three
forces. The first force wants the model to score well: a *reward model* — trained on
human preferences, or, increasingly, on symbolic rules and logical checks — hands out a
number $r(y)$ for each possible response $y$, and the training procedure pushes the model
toward high-scoring answers. The second force wants the model to stay put: a penalty
proportional to how far the new policy has strayed from the original, carefully
fine-tuned model. The third force wants the model to remember where it came from: a
mix-in of the original pretraining objective, so the assistant does not forget how to
write Python or conjugate French verbs while it is learning to be polite.

Written down, the argument becomes a single expression. If $p$ is the reference policy
(the supervised fine-tuned model), $q$ the candidate aligned policy, $r$ the reward, $d$
the pretraining distribution, and $\beta,\gamma > 0$ two knobs, the objective is

$$J(q) \;=\; \mathbb{E}_{y \sim q}[r(y)] \;-\; \beta\, \mathrm{KL}(q \,\|\, p) \;+\; \gamma\, \mathbb{E}_{y \sim d}[\log q(y)].$$

The middle term — the Kullback–Leibler divergence, $\mathrm{KL}(q\|p) = \sum_y q(y)\log\frac{q(y)}{p(y)}$ —
is the leash. Practitioners have always described it in words: *it keeps the tuned model
from drifting too far, and thereby prevents policy collapse and reward hacking.* That
sentence is folklore. It is repeated in papers, in blog posts, in code comments. But
folklore is not a theorem. **How far, exactly?** How much can a model change when you
turn the leash to strength $\beta$? Which of its behaviours can change, and which are
provably safe?

This article is about a set of answers to those questions — sharp ones, with matching
examples showing that they cannot be improved.

## Where the aligned model actually lands

Start with the clean case $\gamma = 0$. Over a finite set of possible responses, the
maximizer of $J$ is not a mystery: it is the *exponential tilt* of the reference,

$$\pi_\beta(y) \;=\; \frac{p(y)\, e^{r(y)/\beta}}{Z_\beta}, \qquad Z_\beta = \sum_y p(y)\, e^{r(y)/\beta}.$$

Physicists will recognize a Boltzmann distribution at temperature $\beta$, with the reward
playing the role of minus the energy. This is where the whole story lives: alignment does
not invent a new model, it *reweights* the old one, multiplying each response's
probability by $e^{r(y)/\beta}$ and renormalizing. Large $\beta$ means a cold, timid
reweighting; small $\beta$ means a violent one.

The natural measure of "how far did the model move" is the total-variation-style distance

$$\|\pi_\beta - p\|_1 = \sum_y |\pi_\beta(y) - p(y)|,$$

which runs from $0$ (no change at all) to $2$ (the new model and the old one never agree).
Call it the **drift**.

## First answer: the leash is self-limiting

Here is the first surprise, and it is almost free. Let $\mathrm{range}(r) = \max_y r(y) - \min_y r(y)$.
Because the aligned policy is optimal, it must beat the reference; because the reward can
only improve by at most its own range, the divergence it can afford to spend is capped:

> **Self-limiting divergence.** $\mathrm{KL}(\pi_\beta \| p) \le \mathrm{range}(r)/\beta$.

Nothing about the reward's shape enters — only how far apart its best and worst values
are. Combined with **Pinsker's inequality**, $\|q-p\|_1^2 \le 2\,\mathrm{KL}(q\|p)$, this
yields a first *no-collapse law*: the drift is at most $\sqrt{2\,\mathrm{range}(r)/\beta}$,
which tends to $0$ as the leash tightens. The folklore is now a theorem.

Is it the best theorem? Pinsker's constant $2$ turns out to be exactly optimal: on a
two-point space with the family $q_\varepsilon = (\tfrac12+\varepsilon, \tfrac12-\varepsilon)$
around the uniform reference, the ratio $2\,\mathrm{KL}/\|q_\varepsilon - q_0\|_1^2$
converges to $1$ as $\varepsilon \downarrow 0$, so no constant smaller than $2$ works.

And yet the $\beta^{-1/2}$ law is *not* the truth. That is the useful lesson: when a
composite bound is loose, the loose step need not be the one you suspect. Pinsker was
perfect; the *input* to Pinsker was crude.

## Second answer: the real rate is $1/\beta$

The variational argument above only used the *value* of the objective. It ignored the
structure of the answer — that $\pi_\beta$ is an exponential family, and that a tilt's
divergence from its base point is *quadratic* in the tilt parameter, not linear. Exploiting
that gives

$$\mathrm{KL}(\pi_\beta \| p) \;\le\; \frac{\mathrm{range}(r)^2}{2\beta^2}\, e^{\mathrm{range}(r)/\beta},
\qquad \|\pi_\beta - p\|_1 \;\le\; \frac{\mathrm{range}(r)}{\beta}\, e^{\mathrm{range}(r)/(2\beta)},$$

and, once the temperature exceeds the reward scale ($\beta \ge \mathrm{range}(r)$), the clean
statement $\|\pi_\beta - p\|_1 \le 2\,\mathrm{range}(r)/\beta$. The drift decays like
$1/\beta$, not $1/\sqrt{\beta}$ — a genuine order-of-magnitude improvement in the regime
anyone actually runs.

That this is the end of the road, and not another artifact, is settled by an explicit
example: on a coin-flip response space with uniform reference and the reward "one point
for heads", the drift is at least $1/(3\beta)$ for every $\beta \ge 2$. Upper bound
$2/\beta$, lower bound $1/(3\beta)$: the rate $\Theta(\beta^{-1})$ is exact.

## Third answer: it is the *variance* that matters, not the range

The range of a reward is a brutal summary. Imagine a reward model that is essentially flat
across the millions of responses your model actually produces, but assigns a huge score to
one bizarre, vanishingly rare string — the classic signature of a reward model with an
exploitable hole. Its range is enormous. Its *variance under the reference policy*,
$\mathrm{Var}_p(r) = \mathbb{E}_p[(r - \mathbb{E}_p r)^2]$, is tiny, because the spike
carries almost no probability mass.

Which one governs drift? The variance:

$$\mathrm{KL}(\pi_\beta \| p) \;\le\; e^{\mathrm{range}(r)/\beta}\,\frac{\mathrm{Var}_p(r)}{\beta^2},
\qquad
\|\pi_\beta - p\|_1 \;\le\; \frac{\sqrt{2\,e^{\mathrm{range}(r)/\beta}\,\mathrm{Var}_p(r)}}{\beta}.$$

Since Popoviciu's inequality gives $\mathrm{Var}_p(r) \le \mathrm{range}(r)^2/4$ always, this is
never worse than the previous bound, and on rare-spike rewards it is unboundedly better.
An extreme corollary is worth stating on its own: if the reward has *zero* variance under
the reference — it is constant on everything the model ever says — then $\pi_\beta = p$
exactly, at every temperature. Alignment pressure with no reward contrast moves nothing.

Is the standard deviation $\sigma_p(r) = \sqrt{\mathrm{Var}_p(r)}$ the right functional, or
could something even smaller do? Again a two-point computation decides it. With a uniform
reference over $\{\text{heads},\text{tails}\}$ and reward $a$ for heads, the drift can be
computed in closed form:

$$\|\pi_\beta - p\|_1 \;=\; \tanh\!\Big(\frac{a}{2\beta}\Big) \;=\; \frac{e^{a/\beta}-1}{e^{a/\beta}+1},$$

while $\sigma_p(r) = a/2$. For $0 < a \le \beta$ this is squeezed between $\sigma/(2\beta)$
and $3\sigma/\beta$. The law is $\Theta(\sigma_p(r)/\beta)$ — the functional and the rate
are both correct, and only the absolute constant remains to be pinned down.

## The lie-detector question: which behaviours can be hacked?

Now the question that actually keeps alignment researchers awake. Suppose you have an
*audit statistic* $f$: a second reward model the training never saw, a toxicity probe, a
truthfulness classifier, a measurement of how often the model says "I don't know". You
want to know whether optimizing $r$ silently moved $f$. The **audit gap** is
$\mathbb{E}_{\pi_\beta}[f] - \mathbb{E}_p[f]$.

A first bound comes for free from the drift law: the gap is at most $\|f\|_\infty$ times
the drift. But this is unsatisfying — it says a large-magnitude statistic is always at
risk. The sharper truth replaces magnitude by *fluctuation*:

$$\big|\mathbb{E}_{\pi_\beta}[f] - \mathbb{E}_p[f]\big| \;\le\; \frac{e^{\mathrm{range}(r)/\beta}}{\beta}\, \sigma_p(r)\, \sigma_p(f).$$

A statistic that is nearly deterministic under the reference cannot be moved at all, no
matter how large its values.

And then the sharpest statement, the one that gives the whole subject a clean slogan.
Write $\mathrm{Cov}_p(r,f) = \mathbb{E}_p[(r - \mathbb{E}_p r)(f - \mathbb{E}_p f)]$ for the
covariance of the reward and the audit statistic *under the reference policy* — a quantity
you can estimate before you run a single step of alignment, by sampling from the model you
already have. Then, for a reward bounded by $R$ and a temperature $\beta \ge R$:

> **The audit gap is a covariance.**
> $$\Big|\, \mathbb{E}_{\pi_\beta}[f] - \mathbb{E}_p[f] \;-\; \frac{\mathrm{Cov}_p(r,f)}{\beta} \,\Big| \;\le\; 24 \Big(\frac{R}{\beta}\Big)^{2} \sigma_p(f).$$

The leading behaviour of every audit statistic under alignment is *pinned* by one number
computed on the pre-alignment model. And therefore:

> **First-order reward hacking requires correlation with the reward model.**
> If $\mathrm{Cov}_p(r,f) = 0$, then $|\mathbb{E}_{\pi_\beta}[f] - \mathbb{E}_p[f]| \le 24(R/\beta)^2 \sigma_p(f)$ —
> the statistic moves at order $\beta^{-2}$, one full order better than the generic guarantee.

Why is this the right shape? Because $\pi_\beta = p \cdot (e^{r/\beta}/Z_\beta)$, so the
audit gap is *exactly* the reference covariance of $f$ with the likelihood ratio
$e^{r/\beta}/Z_\beta$; and to first order that likelihood ratio is just $1 + r/\beta$.
Covariance with the constant $1$ is zero; covariance with $r/\beta$ is
$\mathrm{Cov}_p(r,f)/\beta$. Everything else is a second-order remainder, and the entire
technical work is showing that the remainder is genuinely small — it has oscillation at
most $24(R/\beta)^2$, and an oscillation bound controls a standard deviation.

This has an operational reading. You cannot audit every behaviour of a model. But you can
*rank* behaviours by their pre-alignment correlation with the reward, and the ranking is
provably the right one to first order: high-correlation statistics are the ones that will
move, and low-correlation ones are protected by an explicit quadratic bound.

## The price of alignment, both ways

The same machinery quantifies the trade. Since $\pi_\beta$ is the optimum, its reward gain
must at least pay for the divergence it spends:

$$\mathbb{E}_{\pi_\beta}[r] - \mathbb{E}_p[r] \;\ge\; \beta\, \mathrm{KL}(\pi_\beta\|p) \;\ge\; \frac{\beta}{2}\|\pi_\beta - p\|_1^2.$$

*Gain costs drift.* Conversely, a model that has not moved cannot have improved:
$\mathbb{E}_{\pi_\beta}[r] - \mathbb{E}_p[r] \le \frac{\mathrm{range}(r)}{2}\|\pi_\beta - p\|_1$,
so once $\beta \ge \mathrm{range}(r)$ the total extractable reward is itself capped by
$\mathrm{range}(r)^2/\beta$. *Drift caps gain.* There is no free alignment: the leash you
choose fixes, in both directions, how much improvement is even on the table.

Finally, the pretraining mix-in. Suppose a policy $q$ merely *beats the reference* under
the full objective with $\gamma > 0$. Then

$$\beta\, \mathrm{KL}(q\|p) \;+\; \gamma\, \mathrm{KL}(d\|q) \;\le\; \mathrm{range}(r) \;+\; \gamma\, \mathrm{KL}(d\|p).$$

One inequality, two guarantees. The reward term can buy at most $\mathrm{range}(r)/\beta$
worth of divergence from the fine-tuned model, and — reading the same line the other way —
the aligned model can be pushed away from the pretraining distribution by at most
$\mathrm{range}(r)/\gamma$ beyond where the reference already was. The two coefficients are
two independent budgets, and the reward range is the single currency both are spent in.

## What happens if you drop the leash

For completeness, the opposite regime. As $\beta \downarrow 0$ the KL penalty vanishes and
the picture is that of a zero-temperature limit in statistical physics. The free energy
$\beta \log Z_\beta$ is squeezed between $\max_y r(y) + \beta \log(\min_y p(y))$ and
$\max_y r(y)$, so it converges to the maximal reward — an explicit, non-asymptotic form of
the Laplace principle. Every suboptimal response is exponentially suppressed,

$$\pi_\beta(y) \;\le\; \frac{1}{\min_z p(z)}\, e^{-(\max_z r(z) - r(y))/\beta},$$

so its probability vanishes; and in the two-point model the drift converges to its maximal
possible value $1$. This is **total policy collapse**: not a large perturbation of the
reference, but a complete replacement of it by a point mass on the reward's argmax. Low
temperature is not a continuous deformation of the reference model — it is a different
object entirely.

## The shape of the picture

Put the pieces together and the KL penalty stops being a heuristic and becomes a
thermostat with a known calibration curve:

- at $\beta = 0^+$, total collapse onto the reward maximizer;
- at large $\beta$, drift exactly of order $\sigma_p(r)/\beta$ — proportional to the
  reward's fluctuation on the model's own output distribution, not to its worst-case range;
- for any individual behaviour you might care to audit, a first-order prediction
  $\mathrm{Cov}_p(r,f)/\beta$ with an explicit $O(\beta^{-2})$ error, and hence a proof that
  behaviours uncorrelated with the reward are second-order safe;
- and a two-sided budget saying exactly how much reward the leash lets you buy.

None of this requires knowing anything about neural networks. It requires only that the
aligned model is the exponential tilt of the reference — which is the defining property of
the objective, whether the reward signal comes from human raters, from a symbolic rule
engine, or from anything else. That is the pleasant thing about the result: the
architecture of the reward model is irrelevant to the geometry of the leash. What matters
is a variance and a covariance, both measurable on the model you already have, before
alignment begins.
