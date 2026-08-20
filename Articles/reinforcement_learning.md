# The Thermodynamics of Alignment

*How a single line of algebra explains why fine-tuned language models behave the way they do*

---

## A tug of war with three ropes

Every modern instruction-following language model is the product of a
negotiation. On one side is a **reward model**: a scoring function, trained on
human preferences or on symbolic rules, that says how good a response is. On the
other side is the **reference model** — the plain, supervised fine-tuned system
you started with, the one that already speaks fluent English and knows how to
finish a sentence. Turn the reward all the way up and the model degenerates: it
learns to game the score, repeating whatever quirk the reward model happens to
love. Leave the reward off entirely and nothing improves.

The standard compromise, used in essentially every large-scale alignment
pipeline, is to write down a single objective and maximise it over the policy
$p$ — the probability distribution the model puts over possible responses $y$ to
a prompt $x$:

$$\mathrm{Objective}(p) \;=\; \underbrace{\mathbb{E}_{y \sim p}\big[R(y)\big]}_{\text{be good}} \;-\; \underbrace{\beta\, D_{\mathrm{KL}}\!\big(p \,\|\, \pi_{\mathrm{ref}}\big)}_{\text{but don't change too much}} \;+\; \underbrace{\gamma\, \mathbb{E}_{y \sim \mathcal{D}_{\mathrm{pre}}}\big[\log p(y)\big]}_{\text{and don't forget what you knew}}.$$

Three ropes, three directions. The first term pulls towards high reward. The
second, the *Kullback–Leibler penalty*, is an elastic band tethering the new
policy $p$ to the reference $\pi_{\mathrm{ref}}$; the coefficient $\beta$ sets
its stiffness. The third — the *pre-training mix-in*, folklore-known as PTX — is
a separate rope pulling the model back towards the raw text distribution
$\mathcal{D}_{\mathrm{pre}}$ it was originally trained on, inserted to stop
alignment from wrecking performance on ordinary language tasks.

This article is about what happens when you stop treating that objective as a
thing to be optimised numerically and instead *solve it exactly*. It turns out
you can. And the exact solution says a surprising number of true things about
alignment: how far a tuned model can drift, why sequential rounds of tuning
compose, why the reward model can only be recovered up to an additive constant,
and why the third rope is fundamentally at war with the first two.

## The answer, in closed form

Fix a prompt and let the possible responses form a finite set. Write
$\pi_{\mathrm{ref}}(i) > 0$ for the reference model's probability of response
$i$, and $R(i)$ for its reward. Define the **partition function**

$$Z \;=\; \sum_i \pi_{\mathrm{ref}}(i)\, e^{R(i)/\beta},$$

and the **tilted policy**

$$\pi^\star(i) \;=\; \frac{\pi_{\mathrm{ref}}(i)\, e^{R(i)/\beta}}{Z}.$$

This is the reference policy reweighted by an exponential in the reward — a
softmax at temperature $\beta$, applied *on top of* what the model already
believed. The central fact is an identity, and once you see it everything else
follows:

> **Three-Point Identity.** For every probability distribution $p$ over
> responses,
> $$\mathrm{Objective}_{\text{reward}+\text{KL}}(p) \;=\; \beta \log Z \;-\; \beta\, D_{\mathrm{KL}}\!\big(p \,\|\, \pi^\star\big).$$

Read it slowly. The left side is a complicated trade-off between two competing
terms. The right side is a *constant*, $\beta \log Z$, minus a penalty that is
nonnegative and vanishes exactly when $p = \pi^\star$. The whole optimisation
problem has collapsed into a statement about distance from a single point.

The proof is three lines of algebra: expand
$D_{\mathrm{KL}}(p\|\pi^\star) = \sum_i p(i)\log\frac{p(i)}{\pi^\star(i)}$,
substitute the definition of $\pi^\star$, and the reward term and the $\log Z$
term fall out of the logarithm of the quotient. Everything hard is hidden in a
single classical fact — **Gibbs' inequality**, that
$D_{\mathrm{KL}}(p\|q) \ge 0$ with equality only when $p = q$, which itself
follows from the elementary pointwise bound $a - b \le a\log(a/b)$.

So: the aligned model *is* the exponentially tilted reference model, the optimal
value *is* $\beta \log Z$ — a quantity physicists call a **free energy** — and
the optimum is **unique**. No gradient descent, no approximation. Alignment, in
this idealised form, is statistical mechanics: the reward is minus an energy,
$\beta$ is a temperature, and the aligned policy is a Boltzmann distribution.

## Five things the formula knows

Once the closed form is in hand, quantitative facts about alignment stop being
empirical observations and start being theorems.

**1. You cannot get more than you asked for, and you never get less than you
had.** If the reward takes values in $[m, M]$, then

$$\mathbb{E}_{\pi_{\mathrm{ref}}}[R] \;\le\; \beta \log Z \;\le\; M.$$

The optimal value is sandwiched between the reward the untuned model already
achieves and the best reward available anywhere. Tuning never hurts the
objective, and no amount of it manufactures reward that does not exist. In fact
the aligned model's *expected reward* also beats the reference model's:
tilting never makes the model worse by its own scoring rule.

**2. The tuned model cannot run away.** Substituting $p = \pi^\star$ into the
identity and using the sandwich gives a hard leash:

$$\beta \, D_{\mathrm{KL}}\!\big(\pi^\star \,\|\, \pi_{\mathrm{ref}}\big) \;\le\; M - m.$$

The divergence between the aligned and reference policies is at most the *range*
of the reward divided by $\beta$. This is the mathematical content of the
intuition that a strong KL penalty keeps the model close to home — but it is
sharp, explicit, and free of any assumption about the reward beyond boundedness.

Two complementary pictures of that leash exist. A crude multiplicative one:
every single response keeps a probability between $e^{-(M-m)/\beta}$ and
$e^{(M-m)/\beta}$ times its original probability — so alignment can neither
extinguish a response nor conjure one out of nothing. Summing this yields a total
drift $\sum_i |\pi^\star(i) - \pi_{\mathrm{ref}}(i)| \le e^{(M-m)/\beta} - 1$,
which tends to $0$ as $\beta \to \infty$: crank the elastic band and the tuned
model converges to the reference.

But that exponential bound is useless in the regime that actually matters, where
$M - m$ is much bigger than $\beta$: $e^{10}-1$ is not a constraint on a total
variation distance that can never exceed $2$. The right geometry is Euclidean,
not multiplicative, and it is supplied by **Pinsker's inequality**,
$\|p - q\|_1^2 \le 2 D_{\mathrm{KL}}(p\|q)$. Combining it with the leash gives

$$\Big(\sum_i \big|\pi^\star(i) - \pi_{\mathrm{ref}}(i)\big|\Big)^2 \;\le\; \frac{2(M-m)}{\beta},$$

a **square-root drift law**: total drift grows like $\sqrt{(M-m)/\beta}$, not
exponentially. Whenever $M - m > \beta$ — that is, in practice — this is
strictly the better statement, and it is the correct scaling of the alignment
budget.

**3. Alignment rounds compose additively.** Suppose you tune with reward $R_1$,
then take the result as your new reference and tune again with $R_2$. The answer
is *exactly* what you would have got by tuning once with $R_1 + R_2$. In
algebraic language: exponential tilting is a group action of the additive group
of rewards on the open simplex of full-support policies. It is transitive — any
full-support policy is reachable from any other by a suitable reward — and its
stabiliser is precisely the constant rewards. So the space of aligned policies
is a *torsor* under rewards modulo constants: rewards act, they act freely once
you quotient by constants, and shifting a reward by a constant changes the
optimal value by that constant while leaving the policy untouched.

**4. The reward is only ever knowable up to a constant — and that's fine.**
Preference data is typically modelled by the Bradley–Terry law: response $i$ is
preferred to $j$ with probability $1/(1 + e^{R(j)-R(i)})$. Two rewards induce
identical preference probabilities exactly when they differ by an additive
constant. Combined with the stabiliser computation, this closes a circle: the
optimal aligned policy is *well-defined on preference data*. Two reward models
fitted to the same preferences, however differently normalised, yield literally
the same tuned model. Conversely, two rewards giving the same tuned model give
the same preferences. The apparent non-identifiability of the reward is not a
defect; it is exactly the gauge freedom the aligned policy is blind to.

The same computation, read backwards, is the observation behind *direct
preference optimisation*: assign to any full-support policy $q$ its **implicit
reward** $R_q(i) = \beta \log\big(q(i)/\pi_{\mathrm{ref}}(i)\big)$. Then $q$ is
the aligned optimum of its own implicit reward, and the implicit reward of
$\pi^\star$ recovers $R$ up to a constant. Policies and rewards are two
coordinate systems on the same object; you may fit either.

**5. A mis-specified reward costs at most twice its error.** If your learned
reward $\hat R$ is uniformly within $\varepsilon$ of the true reward $R$, the
policy you get by optimising $\hat R$ achieves true objective value at least
$\beta\log Z(R) - 2\varepsilon$. The proof is a Lipschitz estimate: the free
energy is $1$-Lipschitz in the reward in the sup norm (and convex in it, being a
supremum of affine functionals — the variational principle read as a duality),
costing $\varepsilon$; evaluating the wrong policy on the right reward costs
another $\varepsilon$. Reward hacking, in this idealised setting, is bounded, and
the constant is $2$.

## The Pareto frontier: what $\beta$ buys you

The coefficient $\beta$ is the single dial an alignment engineer actually turns.
What does it control? Exactly a trade-off, and monotonically so:

> **Alignment Frontier.** If $0 < \beta_1 < \beta_2$, then the more weakly
> regularised policy is both further from the reference *and* higher in expected
> reward:
> $$D_{\mathrm{KL}}(\pi^\star_{\beta_2} \| \pi_{\mathrm{ref}}) \le D_{\mathrm{KL}}(\pi^\star_{\beta_1} \| \pi_{\mathrm{ref}}), \qquad \mathbb{E}_{\pi^\star_{\beta_2}}[R] \le \mathbb{E}_{\pi^\star_{\beta_1}}[R].$$

Both inequalities come from the same trick: evaluate each temperature's
objective at the *other* temperature's optimum and add the two resulting
inequalities. The cross terms cancel, and what survives is
$(\beta_2 - \beta_1)$ times the difference of the divergences.

The endpoints of the frontier are the two regimes people worry about. As
$\beta \to \infty$ the aligned model converges to the reference model in total
variation: infinite regularisation, no alignment. As $\beta \to 0^+$ the optimal
value $\beta \log Z$ converges to $\max_i R(i)$ and every strictly suboptimal
response is abandoned — its probability is at most
$\frac{\pi_{\mathrm{ref}}(i)}{\pi_{\mathrm{ref}}(i_0)}e^{-(R(i_0)-R(i))/\beta}$,
which decays exponentially fast in $1/\beta$. Zero regularisation gives you
mode collapse onto the arg-max of the reward model, which is precisely reward
hacking: the aligned policy becomes a delta on whatever the scorer likes best,
irrespective of whether it is good text.

## Many prompts, and the localised cost of not forgetting

Real alignment runs over a distribution $\mathcal{D}$ of prompts, each with its
own conditional policy. Nothing breaks: the prompt-averaged objective is
maximised exactly when *every* conditional policy is the tilted policy for its
own prompt (assuming every prompt has positive probability), and the optimal
value is the $\mathcal{D}$-average of the per-prompt free energies. Alignment
decouples across prompts. This is reassuring and slightly boring.

The third rope is where it gets interesting. The pre-training mix-in term
$\gamma \, \mathbb{E}_{y \sim \mathcal{D}_{\mathrm{pre}}}[\log p(y)]$ is, as a
function of $p$, maximised uniquely at $p = \mathcal{D}_{\mathrm{pre}}$ — it is
the negative cross-entropy, and the gap between it and its maximum is exactly
$\gamma\, D_{\mathrm{KL}}(\mathcal{D}_{\mathrm{pre}} \| p)$. So we now have two
terms, each with its own unique maximiser: the reward-plus-KL part wants
$p = \pi^\star$, the mix-in wants $p = \mathcal{D}_{\mathrm{pre}}$. The full
objective decomposes exactly as

$$\mathrm{Objective}(p) \;=\; \Big[\beta \log Z + \gamma\,\mathbb{E}_{\mathcal{D}_{\mathrm{pre}}}[\log \mathcal{D}_{\mathrm{pre}}]\Big] \;-\; \beta\, D_{\mathrm{KL}}(p\|\pi^\star) \;-\; \gamma\, D_{\mathrm{KL}}(\mathcal{D}_{\mathrm{pre}}\|p),$$

which yields an exact obstruction theorem:

> **Alignment Tension.** For $\beta, \gamma > 0$, some policy attains the sum of
> the two individual maxima **if and only if**
> $\mathcal{D}_{\mathrm{pre}} = \pi^\star$. Otherwise *every* policy falls
> strictly short.

There is no free lunch and the theorem says so with an "if and only if". The
alignment tax of the pre-training mix-in is zero precisely in the degenerate case
where the pre-training distribution already is the aligned optimum; in every
other case it is strictly positive.

But it is also **local**. When the mix-in is coupled to the conditional policy at
one distinguished prompt $x_0$ — which is what happens when a separate
pre-training batch is folded into the update — the joint bound is attainable iff
$\mathcal{D}_{\mathrm{pre}}$ equals the tilted policy at $x_0$, and the optimal
conditionals at *every other prompt* are completely unaffected. The tax does not
leak. Anti-forgetting regularisation degrades the policy exactly where it
touches it.

Finally, even with all three terms in play, the objective still has **at most one
maximiser** among full-support policies. This does not follow from the
three-point identity — the mix-in term breaks it — but from convexity: the map
$x \mapsto x\log x$ is *strictly* convex, making $D_{\mathrm{KL}}(\cdot\|c)$
strictly convex in its first argument, while concavity of $\log$ makes
$D_{\mathrm{KL}}(a\|\cdot)$ convex in its second. The objective is therefore
strictly concave, and if two distinct policies both attained the maximum, their
midpoint would beat both. No derivatives, no first-order conditions, no
appeal to the smoothness of the parametrisation: just the shape of $x \log x$.

## Why this matters

None of this is a claim about neural networks. The theorems describe the
*idealised* optimisation problem — the one that gradient-based alignment methods
approximate over a parametric family, with sampled expectations and a learned
reward. But the idealised problem is the thing those methods are trying to
solve, and knowing its exact solution changes what you expect from them.

It tells you that the KL coefficient is a temperature and the achievable
alignment is a free energy. It tells you the drift budget scales like
$\sqrt{(M-m)/\beta}$, so halving $\beta$ buys only $\sqrt{2}$ times the drift.
It tells you that stacking alignment stages is the same as adding rewards, so
sequential fine-tuning cannot reach anything a single well-chosen reward could
not. It tells you the non-identifiability of reward models is harmless gauge
freedom. And it tells you, with an exact characterisation rather than a
heuristic, that the anti-forgetting term you added to protect general
capabilities is *provably* costing you alignment quality — unless your
pre-training distribution was already aligned, which it is not.

The pleasant surprise is how little machinery any of it needs. One inequality
about $a\log b$, one identity, and the rest is bookkeeping. Alignment, at its
mathematical core, is a Boltzmann distribution wearing a lab coat.
