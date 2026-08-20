# The Hidden Geometry of Aligning a Language Model

## A reward is a direction, a policy is a place

Every large language model that answers politely, refuses gracefully, and cites carefully has been through a second education. After the model has read the internet and learned to imitate, it is *aligned*: nudged toward answers that people (or a set of symbolic rules) actually prefer. The workhorse recipe for that nudge is a single formula. Written out, it says: make the model's answers score well under a reward model, don't let the model wander too far from where it started, and don't let it forget how to speak English.

In symbols, with $\Omega$ the (finite) set of possible responses, $q$ the tuned policy we are searching for, $p$ the starting "supervised fine-tuned" reference policy, $r$ the reward model, $d$ the pretraining distribution, and two knobs $\beta,\gamma>0$:

$$J_\gamma(q) \;=\; \underbrace{\sum_{y} q(y)\,r(y)}_{\text{score well}} \;-\; \underbrace{\beta \sum_y q(y)\log\frac{q(y)}{p(y)}}_{\text{stay near the reference}} \;+\; \underbrace{\gamma \sum_y d(y)\log q(y)}_{\text{don't forget}} .$$

The middle term is the Kullback–Leibler divergence $\mathrm{KL}(q\|p)$, a measure of how much information it takes to tell $q$ apart from $p$. The last term is the "pretraining mix-in": a bribe paid to the model to keep assigning respectable probability to ordinary text.

Practitioners treat this formula as an engineering compromise: three competing pressures, balanced by hand-tuned coefficients. What follows is the claim that it is not a compromise at all. It is a piece of geometry, and once you see the geometry, several practical facts about alignment — reward hacking, mode collapse, the "alignment tax", the fact that you can read a reward model off a tuned policy — stop being folklore and become theorems.

## The simplest case: alignment as a tilt

Drop the pretraining term for a moment ($\gamma=0$). Then the maximization has a closed-form answer that has been known since Gibbs studied gases: the best policy is the reference policy *tilted* by the reward,

$$\pi_r(y) \;=\; \frac{p(y)\,e^{r(y)/\beta}}{Z}, \qquad Z \;=\; \sum_z p(z)\,e^{r(z)/\beta}.$$

Responses the reward likes get multiplied up, responses it dislikes get multiplied down, and everything is renormalized. The temperature $\beta$ controls how violent the tilt is. The best value attainable is the *free energy*

$$F(r) \;=\; \beta \log Z \;=\; \beta \log \sum_y p(y)\, e^{r(y)/\beta}.$$

Now the first structural observation. Suppose you tilt by $r_1$, and then tilt the result by $r_2$. You get exactly the tilt by $r_1 + r_2$. Tilting by the zero reward changes nothing. And tilting by a *constant* reward — one that gives every response the same score — also changes nothing, because the constant cancels in the normalization. So rewards act on policies the way translations act on a plane: composably, invertibly, and with a subgroup (the constants) acting trivially.

Push this to its conclusion and you get a clean statement.

> **Alignment Torsor Theorem.** Fix $\beta>0$ and a strictly positive reference policy $p$. The additive group of reward models modulo constants acts on the set of strictly positive policies by exponential tilting, and this action is *simply transitive*: for any two such policies there is exactly one reward-modulo-constant taking one to the other.

A set on which a group acts simply transitively is called a *torsor* — a space that looks like the group but has forgotten where its origin is. That is precisely the situation in alignment: policies are rewards that have forgotten which reward was "zero". Choose an origin (the reference policy $p$) and the two become the same thing.

The explicit inverse map is famous in its own right. Given a policy $q$, the reward that produced it is

$$r_q(y) \;=\; \beta \log\frac{q(y)}{p(y)},$$

the *implicit reward*. This is the identity underlying direct preference optimization: you never need to train a separate reward model, because the policy already *is* one, written in different coordinates.

The correspondence is not merely a bijection of sets. Fix the gauge by insisting $\sum_y r(y)=0$, and the map from mean-zero rewards to strictly positive policies is a **homeomorphism**: nearby rewards give nearby policies, and nearby policies give nearby rewards. Small reward-model errors cause only small policy changes, and reward extraction from a policy is a stable operation. But — and this is where the mathematics earns its keep — the homeomorphism lives strictly on the *interior* of the probability simplex. As a policy pushes some response's probability toward zero, the implicit reward for that response diverges to $-\infty$. Policy collapse is not a numerical accident; it is the boundary of the coordinate chart.

## Two ways to say the same thing

There is a second, deeper duality hiding in the same formula. The free energy $F(r)$ is a convex function of the reward. Its supporting-hyperplane inequality,

$$F(s) \;\ge\; F(r) + \mathbb{E}_{\pi_r}[\,s - r\,],$$

is classical in statistical mechanics. What is pleasant here is that the *gap* in this inequality is not merely nonnegative; it has an exact identity:

$$F(s) - F(r) - \mathbb{E}_{\pi_r}[\,s-r\,] \;=\; \beta\,\mathrm{KL}\!\left(\pi_r \,\|\, \pi_s\right).$$

In words: the failure of the free energy to be linear in the reward is *exactly* the information distance between the corresponding aligned policies. Convexity, strict convexity, monotonicity, and continuity of the alignment value all fall out of this one identity, with no calculus at all.

From it comes the full Legendre duality:

> **Duality Theorem.** For $\beta>0$ and a strictly positive reference $p$:
> $$F(r) \;=\; \max_{q}\Big( \mathbb{E}_q[r] - \beta\,\mathrm{KL}(q\|p) \Big),$$
> the maximum attained uniquely at $q=\pi_r$; and dually,
> $$\beta\,\mathrm{KL}(q\|p) \;=\; \max_{r}\Big( \mathbb{E}_q[r] - F(r) \Big),$$
> the maximum attained at the implicit reward $r_q = \beta\log(q/p)$.

Read the second equation slowly. The KL penalty — the regularizer that alignment engineers add to keep a model from drifting — is not an arbitrary choice of leash. It is the *convex conjugate* of the alignment value. Rewards and policies are Legendre-dual coordinates on the alignment problem, and the tilting torsor is the gradient map between them. The accompanying Fenchel–Young inequality $\mathbb{E}_q[r]\le F(r)+\beta\,\mathrm{KL}(q\|p)$ holds always, with equality exactly on the graph of the tilting map: exactly when $q$ is the aligned policy for $r$.

## How much damage can a corrupted reward do?

Reward models are learned, and learned things are wrong. Suppose an adversary — or just a badly-fit neural network — perturbs the reward by at most $K$ at every response. How far can the attainable alignment value move? Convexity gives an immediate answer: at most $K$, exactly.

$$\bigl|F(r) - F(s)\bigr| \;\le\; \sup_y |r(y)-s(y)|.$$

A *reward-hacking budget*: corruption of size $K$ buys the attacker value at most $K$. The natural next question is whether the constant $1$ is pessimistic. It is not.

> **Sharpness Theorem.** For every $K\ge 0$ and every $\varepsilon>0$ there is a two-response space, a temperature, a reference policy, and a pair of reward models at sup-norm distance at most $K$ whose alignment values differ by more than $K-\varepsilon$. Consequently no constant $c<1$ satisfies $|F(r)-F(s)|\le c\sup_y|r-s|$ in general.

The witness is disarmingly simple: two responses, a uniform reference policy, one reward identically zero and the other paying $K$ for a single response. Then $F=\beta\log\frac{e^{K/\beta}+1}{2}\ge K-\beta\log 2$. As the temperature $\beta$ shrinks — that is, as the KL leash is loosened relative to the reward scale — the value gap converges to the entire budget $K$. Low temperature is precisely the regime in which reward hacking is observed empirically, and here it is, as a theorem.

There is a sharper, more uncomfortable companion. A tempting way to diagnose reward corruption is to measure it *where the model actually spends its probability*: use the reference-weighted energy $\|f\|^2_{L^2(p)} = \sum_y p(y) f(y)^2$, which discounts responses the base model almost never emits. That diagnostic is worthless.

> **No-Reference-Weighted-Bound Theorem.** For every constant $C$, however large, there is a temperature, a reference policy, and a pair of reward models with
> $$\bigl|F(r)-F(s)\bigr| \;>\; C \left(\sum_y p(y)\,(r(y)-s(y))^2\right)^{1/2}.$$

The construction places the corruption on a response of reference probability $\delta$ and then lowers the temperature: the weighted norm shrinks like $\sqrt{\delta}$ while the value gap stays of order $1$. Exponential tilting amplifies rare responses without limit, so an attack hidden in the tail of the reference distribution is invisible to any tail-discounting metric — which is exactly how reward hacking evades the obvious defenses.

## Putting the pretraining term back

Now restore $\gamma>0$. The pretraining mix-in destroys the closed form: the optimality condition becomes transcendental, and no Gibbs formula solves it. What replaces the formula?

First, the optimum exists and is unique. Uniqueness comes from strict concavity: for distinct positive policies $q_1\neq q_2$, the objective at their midpoint strictly exceeds the average of the two values. Existence needs a little care, because the objective diverges to $-\infty$ at the simplex boundary; the fix is to note that this divergence is a *good* thing — provided the pretraining distribution has full support ($d(y)\ge\delta>0$), any policy with a tiny coordinate has terrible value, so the search can be confined to a compact slice of the simplex where the objective is continuous.

Second, and more interestingly, the missing closed form is replaced by a *fixed-point* equation. Define the marginal value of putting mass on response $y$:

$$S(y) \;=\; r(y) \;-\; \beta\left(\log\frac{q(y)}{p(y)} + 1\right) \;+\; \gamma\,\frac{d(y)}{q(y)}.$$

> **Stationarity Theorem.** A strictly positive policy is the global optimum if and only if $S$ is constant across all responses. Equivalently, the optimum satisfies the self-consistent Gibbs equation
> $$q \;=\; \pi_{\,r + \gamma d/q}, \qquad\text{i.e.}\qquad q(y) \;=\; \frac{p(y)\exp\!\big((r(y)+\gamma\, d(y)/q(y))/\beta\big)}{\sum_z p(z)\exp\!\big((r(z)+\gamma\, d(z)/q(z))/\beta\big)}.$$

This is the most quotable consequence of the whole development: **the pretraining mix-in is a self-referential reward bonus**. The tuned model behaves exactly as if it were doing ordinary tilted alignment against an *augmented* reward $r + \gamma\, d/q$, where the bonus $\gamma d(y)/q(y)$ is large precisely on responses the pretraining distribution likes and the current policy has suppressed. It is an automatic, self-correcting subsidy for whatever the alignment process is in the act of forgetting.

That subsidy has teeth. Because the bonus blows up as $q(y)\to 0$, no response with pretraining mass can be starved:

> **Anti-Starvation Theorem.** If the reward is bounded above by $M$, then at the optimum every response satisfies
> $$q(y) \;\ge\; \frac{\gamma\, d(y)}{\beta \log\frac{1}{p(y)} + M + \gamma - r(y)}.$$

A hard, reward-independent probability floor. However badly a corrupted reward model scores a response, if the pretraining distribution likes it, the aligned model cannot suppress it below this level. Mode collapse under PPO-with-pretraining-mix-in is not just discouraged; it is bounded away.

## The price of not forgetting

How much does the pretraining term cost? Exactly what you would expect, and it is provable without ever differentiating anything, from the two optimality inequalities alone:

* Raising $\gamma$ *monotonically improves* the pretraining fit $\sum_y d(y)\log q(y)$ of the optimum. The bribe works.
* Raising $\gamma$ *monotonically degrades* the pure reward-minus-KL part. This is the **alignment tax**, and it is paid monotonically — no free lunches, no non-monotone surprises.
* The optimal value is a decreasing, **convex** function of $\gamma$ (an envelope theorem: it is a maximum of functions affine in $\gamma$).

And how far does the mix-in push the policy away from the clean Gibbs answer $\pi_r$? Here the geometry returns in its most elegant form:

> **Pythagorean Drift Theorem.** For the mix-in optimum $q^*$,
> $$\beta\,\mathrm{KL}(q^*\|\pi_r) \;+\; \gamma\,\mathrm{KL}(d\|q^*) \;\le\; \gamma\,\mathrm{KL}(d\|\pi_r).$$
> Hence $\mathrm{KL}(q^*\|\pi_r) \le (\gamma/\beta)\,\mathrm{KL}(d\|\pi_r)$, so as $\gamma\to 0^+$ the mix-in optimum converges in information to the Gibbs policy; and if $d=\pi_r$ exactly, the mix-in has no effect at all.

The two divergences are the legs of an information-geometric right triangle whose hypotenuse is $\mathrm{KL}(d\|\pi_r)$: the mix-in optimum sits *between* the aligned policy and the pretraining distribution, and the amount of drift it can cause is budgeted by how far apart those two were in the first place. If alignment did not move the model away from its pretraining distribution, the mix-in has nothing to correct and does nothing.

Finally, the reward-hacking analysis extends from values to policies. Strong concavity at the optimum gives, for reward models agreeing to within $K$ in sup-norm and their respective optima $q_1,q_2$,

$$\beta\Big(\mathrm{KL}(q_1\|q_2)+\mathrm{KL}(q_2\|q_1)\Big) \;\le\; \sum_y (q_1(y)-q_2(y))\,(r(y)-s(y)) \;\le\; 2K.$$

An *immunity band*: a bounded corruption of the reward model can move the aligned policy by only a bounded amount of information, and the band tightens as $\beta$ grows. The temperature $\beta$ is thus doing double duty — it is the leash length, and it is the inverse of the sensitivity to reward error. Turn it down to chase reward, and you buy both a bigger value swing (the sharpness theorem) and a bigger policy swing (this one). The two failure modes people report at low KL penalty are the same theorem viewed twice.

## What the geometry buys

None of this changes the training loop. What it changes is what the loop *is*. The three terms of the alignment objective are not three engineering hacks glued together; they are: a linear functional (the reward), the convex conjugate structure that makes rewards and policies dual coordinates (the KL penalty), and a barrier that keeps the policy inside the region where those coordinates are defined (the pretraining mix-in). The barrier's strength is a self-referential reward bonus. The dual coordinates degenerate exactly at collapse. The value's Lipschitz constant is exactly one, and no tail-discounting norm can improve it.

That is a satisfying amount of structure to find inside a formula that was written down to make a chatbot behave.
