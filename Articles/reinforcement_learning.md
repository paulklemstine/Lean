# The Hidden Geometry of Aligning a Language Model

*How a nineteenth-century idea about projective distance explains why
reinforcement learning from human feedback behaves the way it does — and why
two models trained on wildly disagreeing notions of "good" can never become
complete strangers.*

---

## A knob, a fear, and a formula

Every modern language assistant is built in two acts. In the first, a network
is trained to imitate: absorb text, then absorb demonstrations of helpful
answers. Call the resulting model the *reference policy*. In the second act,
the model is nudged — a reward model scores its answers, and the policy is
retrained to score higher. This is reinforcement learning from human feedback.

The nudging is dangerous. Push too hard on the score and the model discovers
degenerate strategies: it flatters, it hedges, it repeats the phrases the
scorer happens to like. The standard defence is a leash. Instead of maximising
the reward $r$ alone, one maximises

$$
J(p) \;=\; \mathbb{E}_{p}[r] \;-\; \beta\, \mathrm{KL}(p \,\|\, \mathrm{ref}) \;+\; \gamma\, \mathbb{E}_{\mathrm{pre}}[\log p].
$$

The first term is the reward. The second is a penalty proportional to how far
the new policy $p$ has strayed, in relative entropy, from the reference. The
third — the "pre-training mix-in" — asks the new policy to keep assigning high
likelihood to ordinary text, so that fine-tuning does not amnesia away general
competence. The dial $\beta$ sets the length of the leash; $\gamma$ sets the
weight of the memory.

Practitioners tune $\beta$ by feel. This article is about what $\beta$
*actually is*. The answer, it turns out, is not a vague regularisation
strength. It is a **metric scale factor**: alignment is an exact isometry, and
$1/\beta$ is the conversion rate between disagreement about rewards and
distance between policies.

---

## Setting the stage

Fix a finite set of possible outputs $\iota$ — think of it as the (astronomical
but finite) set of responses under consideration for a given prompt. A policy
is a probability vector $p = (p_i)_{i \in \iota}$. The reference policy
$\mathrm{ref}$ is assumed strictly positive: the imitation-trained model assigns
*some* probability to everything. A reward model is just a function
$r : \iota \to \mathbb{R}$.

Ignore the pre-training term for a moment ($\gamma = 0$). Then the maximiser of
$J$ is a classical object — an exponential tilt of the reference:

$$
\pi_\beta(r)_i \;=\; \frac{\mathrm{ref}_i \, e^{r_i/\beta}}{Z}, \qquad
Z \;=\; \sum_{j} \mathrm{ref}_j\, e^{r_j/\beta},
$$

and the optimal value is the **free energy**

$$
F(\beta, r) \;=\; \beta \log Z \;=\; \max_p \Big[ \mathbb{E}_p[r] - \beta\,\mathrm{KL}(p\|\mathrm{ref})\Big].
$$

Physicists have known this shape since Gibbs. What is new here is the geometry
we hang on it.

---

## Two rewards that differ by a constant are the same reward

Notice something immediately: if you add $5$ to every reward score, nothing
changes. The tilt $e^{(r_i+5)/\beta}$ picks up a factor $e^{5/\beta}$ that
cancels in the normalisation. A reward model is only meaningful *modulo
constants*. The natural way to measure the size of a reward is therefore not
its norm but its **oscillation** — its spread:

$$
\mathrm{osc}(f) \;=\; \max_i f_i \;-\; \min_i f_i.
$$

This is a genuine seminorm: it is non-negative, subadditive
($\mathrm{osc}(f+g) \le \mathrm{osc}(f) + \mathrm{osc}(g)$), positively
homogeneous, unchanged by negation, and it vanishes precisely on constants. It
is the correct norm on the quotient space "rewards modulo constants".

Now, how should we measure the distance between two policies? Total variation
is the obvious choice, but it is the wrong one for this problem, and the reason
is instructive: total variation saturates. Once two distributions are nearly
disjoint, TV distance sits at $1$ and stops telling you anything. The right
notion here is older and stranger — the **Hilbert projective metric** of
Birkhoff:

$$
d_H(p,q) \;=\; \mathrm{osc}\!\left(\log \frac{p}{q}\right)
\;=\; \max_i \log\frac{p_i}{q_i} \;-\; \min_i \log\frac{p_i}{q_i}.
$$

It measures the *spread of the log-likelihood ratio*: the worst overstatement
minus the worst understatement that switching from $q$ to $p$ commits. It is
symmetric, satisfies the triangle inequality, and vanishes exactly when the two
policies coincide. Unlike TV it is unbounded — it can tell the difference
between "somewhat different" and "astronomically different".

---

## The isometry theorem

Here is the first main result, and the hinge of everything that follows.

> **Theorem (Alignment is an isometry).** For every $\beta > 0$, every strictly
> positive reference policy, and all rewards $r_1, r_2$,
> $$ d_H\big(\pi_\beta(r_1), \pi_\beta(r_2)\big) \;=\; \frac{\mathrm{osc}(r_1 - r_2)}{\beta}. $$

Not $\le$. Equality. The map from rewards-modulo-constants to policies is a
perfect, distance-preserving embedding, rescaled by $1/\beta$.

The proof is two lines once you have the right coordinates. The log-ratio of
two tilted policies at output $i$ is
$\log\frac{\pi_\beta(r_1)_i}{\pi_\beta(r_2)_i} = \frac{r_{1,i} - r_{2,i}}{\beta} + \log\frac{Z_2}{Z_1}$;
the partition functions contribute a *constant*, invisible to the oscillation,
and the oscillation of $(r_1-r_2)/\beta$ is $\mathrm{osc}(r_1-r_2)/\beta$ by
homogeneity.

Two corollaries are worth stating on their own. Taking $r_2 = 0$: the distance
the aligned model has travelled from the reference is exactly
$d_H(\pi_\beta(r), \mathrm{ref}) = \mathrm{osc}(r)/\beta$. And the aligned
policies for two reward models coincide if and only if the reward models differ
by an additive constant.

The interpretation is clean. **The KL coefficient $\beta$ is an exchange rate.**
One unit of reward spread buys $1/\beta$ units of policy displacement. Doubling
$\beta$ exactly halves the distance travelled, no approximation involved, no
dependence on the reference model or the shape of the reward. The leash is not
metaphorical; it has a length, and the length is $\mathrm{osc}(r)/\beta$.

---

## Why two aligned models can never be strangers

The isometry converts questions about *reward disagreement* into questions
about *policy distance*. But to say something a practitioner can act on, we
need to translate Hilbert distance back into something familiar, like total
variation.

A crude translation is easy: if $d_H(p,q) = d$, then every likelihood ratio
$p_i/q_i$ lies within a factor $e^{d}$ of $1$, and summing gives
$\|p - q\|_{TV} \le e^{d} - 1$. This is useless the moment $d > \log 2$, since
total variation never exceeds $1$ anyway.

The sharp answer is much prettier.

> **Theorem (Sharp Hilbert–total variation comparison).** For strictly positive
> probability vectors $p, q$ with $d = d_H(p,q)$,
> $$ \|p-q\|_{TV} \;\le\; \frac{e^{d/2}-1}{e^{d/2}+1} \;=\; \tanh\!\Big(\frac{d}{4}\Big). $$

Because $\tanh$ is bounded by $1$, this bound is *always* informative. Combined
with the isometry it yields the headline consequence for alignment:

> **Theorem (Reward-model misspecification).** For any two reward models,
> $$ \big\|\pi_\beta(r_1) - \pi_\beta(r_2)\big\|_{TV} \;\le\; \tanh\!\left(\frac{\mathrm{osc}(r_1-r_2)}{4\beta}\right) \;<\; 1. $$

Read that last strict inequality slowly. *No matter how violently two reward
models disagree* — a factor of a billion in scale, opposite signs, adversarial
construction — the two KL-regularised policies they produce are never at total
variation distance $1$. They always overlap. The leash prevents not just
drift but *disjointness*. Reward hacking can distort a policy; it cannot make
it a different species.

Where does $\tanh$ come from? The argument is a small, self-contained
optimisation, and it is worth seeing because the constant falls out of a single
perfect square. Write $u = \max_i p_i/q_i$ and $v = \min_i p_i/q_i$, so that
$u/v = e^{d}$; put $w = e^{d/2}$, so $u = vw^2$. Since $p$ and $q$ are both
probability vectors, some coordinate has $p_i \le q_i$, forcing $v \le 1$, and
likewise $u \ge 1$. Split the space at $A = \{i : p_i \ge q_i\}$ and set
$a = p(A)$, $x = q(A)$; then $\|p-q\|_{TV} = a - x$. Two constraints survive:
from the upper ratio bound on $A$, $a \le u x$; from the lower ratio bound off
$A$, $1 - a \ge v(1-x)$. Eliminating $x$ from the pair of linear constraints
gives

$$
\|p-q\|_{TV} \;\le\; \frac{(u-1)(1-v)}{(u-1) + (1-v)}.
$$

Now substitute $u = vw^2$. The numerator satisfies
$(vw^2-1)(1-v) \le v(w-1)^2$, because the difference of the two sides is
exactly $(vw-1)^2 \ge 0$; the denominator is $v(w^2-1) = v(w-1)(w+1)$. Divide:
the bound collapses to $(w-1)/(w+1)$, which is $\tanh(d/4)$. The entire
constant is the square $(vw-1)^2$.

And the constant cannot be improved. For any $d > 0$, set $\theta = e^{d/2}$ and
take the two-output pair
$p = \big(\tfrac{\theta}{1+\theta}, \tfrac{1}{1+\theta}\big)$,
$q = \big(\tfrac{1}{1+\theta}, \tfrac{\theta}{1+\theta}\big)$. Its two
likelihood ratios are $\theta$ and $1/\theta$, so the Hilbert distance is exactly
$d$ and the total variation is exactly $(\theta-1)/(\theta+1) = \tanh(d/4)$ —
and this is precisely the configuration where the square $(vw-1)^2$ vanishes.
Since any two strictly positive policies arise as tilts of any strictly positive
reference, the alignment bound is attained too.

The earlier crude bound failed for a diagnosable reason: it used only the upper
ratio bound $p \le u q$ and threw away the lower bound $v q \le p$. Both
constraints are needed, and once both are used the answer is sharp.

---

## The free energy is the potential of the policy

Turn now to the value $F(\beta, r)$ itself. It has an elegant derivative.

> **Theorem (Envelope / duality).** Perturbing the reward model in a direction
> $s$ changes the optimal value at the rate given by the expectation of $s$
> under the *optimal policy*:
> $$ \left.\frac{d}{dt}\right|_{t=0} F(\beta,\, r + t s) \;=\; \mathbb{E}_{\pi_\beta(r)}[s]. $$

In other words, the aligned policy is literally the gradient of the alignment
value. This is Danskin's envelope theorem specialised to RLHF, and it is the
mathematical reason policy-gradient methods work here: the gradient of the
objective with respect to the reward does not require differentiating through
the optimiser, because the optimiser's own variation contributes nothing at the
optimum.

Companion facts follow easily: $F$ is monotone in the reward, shifts by $c$
when the reward shifts by $c$, and is $1$-Lipschitz in the supremum norm.

That last one has teeth. Suppose you train on a *proxy* reward $\hat r$ that is
within $M$ of the true reward $r$ everywhere. How much true value do you lose?

> **Theorem (Goodhart regret).** If $|r_i - \hat r_i| \le M$ for all $i$, then
> $$ F(\beta, r) \;-\; \Big[\mathbb{E}_{\pi_\beta(\hat r)}[r] - \beta\,\mathrm{KL}(\pi_\beta(\hat r)\|\mathrm{ref})\Big] \;\le\; 2M. $$

The regret from optimising the wrong reward is at most twice the reward error —
and crucially, **the bound does not involve $\beta$ at all**. KL-regularised
alignment degrades gracefully in reward-model error; it does not amplify it.

---

## Turning the temperature dial to its two extremes

What happens at the ends of the $\beta$ dial? Both limits are classical
thermodynamics wearing new clothes, and both come with rates.

**Cold ($\beta \to 0^+$): reward maximisation and policy collapse.** The free
energy is squeezed:
$$\max_i r_i + \beta \log\big(\min_i \mathrm{ref}_i\big) \;\le\; F(\beta,r) \;\le\; \max_i r_i,$$
so $F(\beta,r) \to \max_i r_i$ as $\beta \to 0^+$. With no leash, the policy
piles all its mass on the single highest-scoring output. This is exactly the
mode collapse that alignment engineers observe when the KL coefficient is set
too small — and the bound quantifies it: the error is at most $\beta$ times the
log of the rarest reference probability.

**Hot ($\beta \to \infty$): back to the reference model.** If $\|r\|_\infty \le M$
and $\beta \ge M$, then
$$0 \;\le\; F(\beta, r) - \mathbb{E}_{\mathrm{ref}}[r] \;\le\; \frac{3}{4}\,\frac{M^2}{\beta},$$
so $F(\beta,r) \to \mathbb{E}_{\mathrm{ref}}[r]$. An infinitely short leash
means no learning at all: the aligned model is the reference model, and the
value is just the reference model's average reward. The $M^2/\beta$ rate is the
familiar variance-scale first correction of a high-temperature expansion.

---

## The pre-training mix-in, exactly

The third term of the objective is folklore engineering: mix in some
pre-training loss so the model does not regress on general benchmarks. It turns
out that at the optimum this term is not a heuristic at all — it obeys an exact
identity.

> **Theorem (PTX identity).** For any pre-training distribution $\mathrm{pre}$,
> $$ \mathbb{E}_{\mathrm{pre}}\big[\log \pi_\beta(r)\big] \;=\; \mathbb{E}_{\mathrm{pre}}\big[\log \mathrm{ref}\big] \;+\; \frac{\mathbb{E}_{\mathrm{pre}}[r] \;-\; F(\beta,r)}{\beta}. $$

Everything about pre-training regression is visible in this one line. The
aligned model's pre-training log-likelihood differs from the reference model's
by a single scalar: how far the pre-training data's *average reward* falls
below the *free-energy level* $F(\beta,r)$, divided by $\beta$. Consequences:

* **Exact no-regression criterion.** Alignment does *not* degrade the
  pre-training objective if and only if
  $\mathbb{E}_{\mathrm{pre}}[r] \ge F(\beta,r)$. Regression is not caused by
  "forgetting" in any mysterious sense; it happens precisely when ordinary text
  scores below the level the reward model has been pushed to.
* **A worst-case budget.** The degradation is at most
  $\gamma\,\mathrm{osc}(r)/\beta$ — the same $1/\beta$ scale that governs the
  geometric drift of the policy. Capability regression and policy drift are the
  same phenomenon measured in two units.

---

## Symbolic rules: a lattice with diminishing returns

"Neurosymbolic" alignment adds a hard filter: a logical rule set declares some
outputs inadmissible, restricting the policy to a subset $S$ of the output
space. The corresponding value is the **constrained free energy**
$F_S(\beta, r) = \beta \log \sum_{i \in S} \mathrm{ref}_i e^{r_i/\beta}$, and
four things are true about it.

*It is attained, exactly.* The optimum of the objective over policies supported
in $S$ equals $F_S$, achieved by the $S$-conditioned tilted policy.

*Filtering and aligning commute.* Conditioning the aligned policy on the
admissible set gives the same thing as aligning within the constraint:
$\pi_\beta(r)$ restricted and renormalised to $S$ *is* the constrained
optimum. The symbolic and neural halves of a neurosymbolic system can be
applied in either order.

*The value is monotone and submodular in the rule set.* Relaxing rules can only
help, and for any two admissible sets,
$$F_{S \cup T} + F_{S \cap T} \;\le\; F_S + F_T.$$
This is a diminishing-returns law for symbolic constraints: relaxing a rule
buys you least when the other rules are already relaxed. Submodularity is the
structural property that makes greedy rule-set selection provably near-optimal,
so this is not idle taxonomy — it licenses an algorithm. The proof is a
one-liner in disguise: the *partition functions* are modular
($Z_{S\cup T} + Z_{S\cap T} = Z_S + Z_T$) and $Z_{S \cap T}$ is a lower bound on
both $Z_S$ and $Z_T$, which forces $Z_{S\cup T} Z_{S \cap T} \le Z_S Z_T$; take
logarithms.

*The price of a rule set is bounded.* Imposing $S$ costs at most
$$F(\beta,r) - F_S(\beta,r) \;\le\; \mathrm{osc}(r) \;-\; \beta \log \mathrm{ref}(S),$$
the reward spread plus a $\beta$-weighted penalty for the reference probability
mass the rules prune away. Rules that forbid rare things are nearly free; rules
that forbid half the model's output distribution cost about $\beta \log 2$.

---

## Alignment happens more than once

Real pipelines run RLHF repeatedly: new preference data, new reward model, new
round. The isometry makes iterated alignment trivial to account for, because
each round is a *translation*.

Applying an additional reward $s$ on top of an accumulated reward $r$ moves the
policy by exactly $\mathrm{osc}(s)/\beta$ — independently of $r$. Chaining
rounds with subadditivity of the oscillation gives a **drift budget**:

> **Theorem (Drift budget).** After $n$ rounds with rewards $r_0, \dots, r_{n-1}$,
> $$ d_H\big(\pi_n, \mathrm{ref}\big) \;\le\; \frac{1}{\beta}\sum_{k=0}^{n-1} \mathrm{osc}(r_k), $$
> with equality exactly when the accumulated reward's oscillation equals the sum
> of the per-round oscillations — that is, when successive rounds never cancel.

And the inequality is genuinely strict in general: two rounds with rewards $s$
and $-s$ return the policy exactly to the reference, spending a budget of
$2\,\mathrm{osc}(s)/\beta$ and travelling zero distance. So no drift-accounting
scheme that looks at rounds one at a time can beat this bound. A safety team
that wants to certify "our model has not moved more than $\delta$ from the
audited reference" now has a checkable, additive ledger — and knows exactly when
the ledger is tight.

---

## What the geometry buys you

Strip away the machinery and three sentences remain.

**$\beta$ is a length scale, not a vibe.** Alignment displaces the policy by
exactly $\mathrm{osc}(r)/\beta$ in the projective metric — an equality, not a
bound — so the KL coefficient can be set from a drift target rather than by
trial and error.

**Disagreement saturates.** Two reward models, however badly they conflict,
produce policies within total variation $\tanh(\mathrm{osc}(r_1-r_2)/4\beta)$,
always strictly below $1$, and the true-value regret from a proxy reward within
$M$ of the truth is at most $2M$ regardless of $\beta$.

**Capability regression is a level comparison.** The pre-training term at the
optimum is exactly the reference value plus
$(\mathbb{E}_{\mathrm{pre}}[r] - F(\beta,r))/\beta$: the model regresses on
ordinary text precisely when ordinary text scores below the free-energy level
the reward has been pushed to, and never by more than
$\gamma\,\mathrm{osc}(r)/\beta$.

The pleasant surprise is how little of this depends on language models. Nothing
above knows what a token is. It is the geometry of exponential families,
Birkhoff's projective metric, and one perfect square — applied to a problem
that happens to be the central engineering question of contemporary artificial
intelligence.
