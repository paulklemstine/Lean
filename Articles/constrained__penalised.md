# The Price of a Nat: Why "Stay Close" and "Pay a Fee" Are the Same Instruction

There are two ways to tell someone to be careful.

The first is a rule: *you may change your behaviour, but not by more than this much.* A budget, a leash, a hard constraint.

The second is a price: *change whatever you like, but every unit of change costs you.* A tax, a penalty, a soft nudge.

Intuitively these feel different. A budget is a wall; a price is a slope. And yet, across an astonishing range of mathematics — thermodynamics, portfolio theory, information theory, and, most recently, the fine-tuning of large language models — the two turn out to be *exactly the same instruction*, provided you set the price correctly. This article is about a precise version of that statement, its proof, and a surprising object hiding at the far edge of it: a hard ceiling on how far the leash can ever stretch, whose value is not an entropy, not a variance, but the negative logarithm of a single number — the probability mass that the original behaviour already placed on its very best outcome.

## The setup, in one paragraph

Fix a finite list of possible outcomes. A *policy* is a probability distribution over them: how likely each outcome is. We start with a reference policy $\pi_0$ — think of it as the behaviour we already have, before any tuning — and we assume it is strictly positive: $\pi_0(i) > 0$ for every outcome $i$, so nothing is ruled out from the start. We also have a *reward* $r$, a real number attached to each outcome saying how good it is. We want a new policy $p$ that scores well, $\mathbb{E}_p[r] = \sum_i p(i)\, r(i)$, without drifting too far from $\pi_0$.

"Far" is measured by relative entropy, or Kullback–Leibler divergence:
$$\mathrm{KL}(p \,\|\, \pi_0) \;=\; \sum_i p(i) \log \frac{p(i)}{\pi_0(i)}.$$
It is zero when $p = \pi_0$ and positive otherwise, and it has an operational meaning: it is the number of extra nats of surprise you suffer, per sample, if you model the world with $\pi_0$ while it actually behaves like $p$. It is the natural currency of "how much has this thing changed?"

Now the two instructions.

**Constrained.** Maximise $\mathbb{E}_p[r]$ subject to $\mathrm{KL}(p\|\pi_0) \le k$. Here $k$ is the leash length.

**Penalised.** Maximise $\mathbb{E}_p[r] - \beta\, \mathrm{KL}(p\|\pi_0)$. Here $\beta > 0$ is the price of a nat.

The penalised problem has a famous closed-form answer, the *exponential tilt* (statisticians call it an exponential family; physicists call it a Boltzmann distribution):
$$\pi^*_\beta(i) \;=\; \frac{\pi_0(i)\, e^{r(i)/\beta}}{Z(1/\beta)}, \qquad Z(t) \;=\; \sum_i \pi_0(i)\, e^{t\, r(i)}.$$
Good outcomes get exponentially up-weighted; the temperature $\beta$ says how aggressively. At $\beta = \infty$ you get $\pi_0$ back; as $\beta \to 0$ you get greed.

The claim we want is: *for every leash length $k$ that is achievable at all, there is exactly one price $\beta$ such that the priced solution sits precisely on the leash, and that solution is the unique winner of the leashed competition.*

## One identity to rule them all

The usual route to this claim runs through Lagrange multipliers, KKT conditions, and derivatives of the log-partition function $\log Z$. That works, but it obscures how *elementary* the truth is. Everything below follows from a single algebraic identity that involves no calculus whatsoever.

Write $t = 1/\beta$ for the *tilt parameter* (the inverse temperature), and write $p_t$ for the tilted policy $\pi^*_{1/t}$. Then for **any** probability vector $p$ at all:

> **Master decomposition.** $\displaystyle \mathrm{KL}(p \,\|\, p_t) \;=\; \mathrm{KL}(p\,\|\,\pi_0) \;-\; t\,\mathbb{E}_p[r] \;+\; \log Z(t).$

The proof is one line of bookkeeping: $\log p_t(i) = \log \pi_0(i) + t\,r(i) - \log Z(t)$, so expanding $\sum_i p(i)\log\frac{p(i)}{p_t(i)}$ splits into exactly those three pieces. That is all.

Apply it once with $p = p_t$ itself — where the left side vanishes — and you learn the leash length of the tilted policy in closed form:
$$k(t) \;:=\; \mathrm{KL}(p_t \| \pi_0) \;=\; t\,\mathbb{E}_{p_t}[r] - \log Z(t).$$
Subtract the two statements and the log-partition function cancels, leaving the identity that carries the whole theory:

> **The duality identity.** For every probability vector $p$ and every $t \in \mathbb{R}$,
> $$t\left(\mathbb{E}_{p_t}[r] - \mathbb{E}_p[r]\right) \;=\; \mathrm{KL}(p_t\|\pi_0) \;-\; \mathrm{KL}(p\|\pi_0) \;+\; \mathrm{KL}(p\|p_t).$$

Stare at this for a moment, because it is the entire argument.

Suppose $t > 0$ and $p$ obeys the leash that $p_t$ itself sits on, i.e. $\mathrm{KL}(p\|\pi_0) \le \mathrm{KL}(p_t\|\pi_0)$. Then the right-hand side is a nonnegative number ($\mathrm{KL}(p_t\|\pi_0) - \mathrm{KL}(p\|\pi_0) \ge 0$) plus another nonnegative number ($\mathrm{KL}(p\|p_t) \ge 0$, which is Gibbs' inequality). So the left-hand side is nonnegative, and dividing by $t > 0$:
$$\mathbb{E}_p[r] \;\le\; \mathbb{E}_{p_t}[r].$$
**The tilted policy wins.** No multipliers, no derivatives, no convexity theory — just the observation that two things are nonnegative. And the argument comes with its own uniqueness proof for free: if some competitor $p$ *ties* with $p_t$, the left side is zero, both nonnegative terms must vanish, and $\mathrm{KL}(p\|p_t) = 0$ forces $p = p_t$ outright. The winner is unique.

## The leash tightens smoothly

Optimality is half the story. The other half is that the correspondence $\beta \leftrightarrow k$ is a genuine bijection: every achievable leash length is hit by exactly one price.

Run the duality identity twice — once with $p = p_s$ evaluated at $t$, once with $p = p_t$ evaluated at $s$ — and add. The reference terms cancel and you get a small gem:

> **Jeffreys identity.** $\displaystyle (t-s)\left(\mathbb{E}_{p_t}[r] - \mathbb{E}_{p_s}[r]\right) \;=\; \mathrm{KL}(p_s\|p_t) + \mathrm{KL}(p_t\|p_s).$

The right side is the *Jeffreys divergence*, a symmetrised distance between the two tilted policies, and it is nonnegative. So expected reward increases with the tilt: turning the temperature down never hurts your score. Keeping instead the single-sided version gives, for $0 \le s \le t$,
$$k(t) - k(s) \;\ge\; \mathrm{KL}(p_t \| p_s) \;\ge\; 0,$$
so the leash length $k(t)$ is nondecreasing — and *strictly* increasing unless the two tilts coincide, which (as a short argument shows) can only happen if the reward is constant across all outcomes. For any reward that actually distinguishes outcomes, $k$ is a strictly increasing, continuous function of $t$ on $[0,\infty)$, starting at $k(0) = 0$.

Strictly increasing and continuous means invertible. Which raises the question this article is really about: *what is the range?*

## The tropical ceiling

Here is the surprise. The leash length does **not** run off to infinity. It stops.

Let $M = \max_i r(i)$ be the best achievable reward, let $A = \{i : r(i) = M\}$ be the set of outcomes attaining it, and let
$$w \;=\; \pi_0(A) \;=\; \sum_{i \in A} \pi_0(i)$$
be the mass the *original* policy already assigned to its best outcomes. Define the **tropical ceiling**
$$L \;=\; -\log w.$$
Then the achievable range of KL budgets is exactly the half-open interval $[0, L)$ — every budget below the ceiling is realised by a unique temperature, and no budget at or above it is realised at all.

Why? Because of a two-sided estimate on the partition function which is, at heart, a statement about $\max$ masquerading as a statement about $\sum$. For $t \ge 0$, every term of $Z(t) = \sum_i \pi_0(i) e^{t r(i)}$ is at most $\pi_0(i)e^{tM}$, and the terms in $A$ alone contribute exactly $w\,e^{tM}$. Hence

> **Tropical sandwich.** $\;t\,M + \log w \;\le\; \log Z(t) \;\le\; t\,M$ for all $t \ge 0$.

Divide by $t$ and let $t \to \infty$: the sandwich collapses and
$$\frac{1}{t}\log Z(t) \;\longrightarrow\; \max_i r(i).$$
This is *Maslov dequantization*, the passage from ordinary arithmetic to **tropical** (max-plus) arithmetic, in which addition is replaced by maximum. As the temperature drops to zero, the smooth "soft-max" $\log Z$ degenerates into the hard $\max$, and the sum forgets everything except its largest term. The whole alignment problem tropicalises.

The ceiling now falls out of the sandwich in two lines. Since $\mathbb{E}_{p_t}[r] \le M$ always,
$$k(t) \;=\; t\,\mathbb{E}_{p_t}[r] - \log Z(t) \;\le\; tM - (tM + \log w) \;=\; -\log w \;=\; L,$$
with strict inequality whenever the reward is non-constant. And in the other direction, as $t \to \infty$ the tilted policy converges pointwise to $\pi_0$ *conditioned on the argmax set* — the zero-temperature policy that keeps only the best outcomes, in their original relative proportions — whose divergence from $\pi_0$ is precisely $\sum_{i \in A}\frac{\pi_0(i)}{w}\log\frac{1}{w} = -\log w = L$. So $k(t) \to L$ from below. The budget curve sweeps out $[0, L)$ and stops.

What makes this beautiful is *what the ceiling is not*. It is not the entropy of $\pi_0$. It is not a variance or a bound on the reward scale. It does not depend on the numerical values of the reward at all — only on **which** outcomes are best and **how much mass $\pi_0$ already gave them**. It is a purely max-plus quantity: the negative log-mass of the tropical support. Double every reward and the ceiling does not move. Make the best outcome twice as likely under the original policy and the ceiling drops by $\log 2$.

The interpretation is bracing. If your original behaviour already puts $10\%$ of its mass on optimal outcomes, then no amount of reward-chasing can ever push you more than $\log 10 \approx 2.30$ nats away from where you started — because the very best thing you could possibly do is *already only $2.30$ nats away*. A leash longer than the room available is not a constraint; it is a category error. Ask for a budget above the ceiling and the constrained problem simply has no temperature that realises it: the supremum of achievable reward is $\max_i r(i)$, and it is approached but never attained inside the ball.

## The headline

Assembling the pieces:

> **Constrained = Penalised.** Let $\pi_0$ be strictly positive on a finite outcome set and let the reward $r$ be non-constant, with tropical ceiling $L = -\log \pi_0(\arg\max r)$. Then for every budget $k$ with $0 < k < L$ there is a **unique** temperature $\beta > 0$ such that $\mathrm{KL}(\pi^*_\beta\|\pi_0) = k$; and for that $\beta$, the policy $\pi^*_\beta$ is the **unique** maximiser of $\mathbb{E}_p[r]$ over the ball $\{p : \mathrm{KL}(p\|\pi_0) \le k\}$.

A concrete instance makes it tangible. Two outcomes, a coin-flip reference $\pi_0 = (\tfrac12,\tfrac12)$, rewards $0$ and $1$. The best reward is $1$, attained by one outcome of mass $\tfrac12$, so the ceiling is $L = \log 2 \approx 0.693$ nats — exactly one bit, which is all the room a fair coin has. The tilted family is the logistic sweep $\pi^*_\beta = \bigl(\tfrac{1}{1+e^{1/\beta}}, \tfrac{e^{1/\beta}}{1+e^{1/\beta}}\bigr)$, running from the fair coin at $\beta = \infty$ to the deterministic policy at $\beta = 0$, and its budget sweeps $[0, \log 2)$ bijectively. Every budget in that window: exactly one price.

## The frontier, and the price of a nat

Plotting budget against reward — the parametric curve $t \mapsto (k(t), \mathbb{E}_{p_t}[r])$ — traces the Pareto frontier of the whole trade-off. Three facts pin it down, and all three come from the same identity.

First, the divergence between two members of the tilted family is exactly the **Bregman divergence** of the log-partition function:
$$\mathrm{KL}(p_s\|p_t) \;=\; \log Z(t) - \log Z(s) - (t-s)\,\mathbb{E}_{p_s}[r].$$
Since KL is nonnegative, $\log Z$ lies above every one of its tangent lines — which is to say $\log Z$ is convex, proved without a single derivative or an appeal to Hölder's inequality. The mean reward $\mathbb{E}_{p_s}[r]$ plays the role of the slope at $s$, as a cumulant generating function should.

Second, the **shadow price bracket**: for $0 < s \le t$,
$$s\left(V(t) - V(s)\right) \;\le\; k(t) - k(s) \;\le\; t\left(V(t)-V(s)\right), \qquad V(t) := \mathbb{E}_{p_t}[r].$$
Rearranged, the reward gained per nat spent lies between $1/t$ and $1/s$ — that is, between the two temperatures. The temperature $\beta$ is not merely a knob; it *is* the marginal exchange rate between reward and divergence, the shadow price of the constraint, in the exact sense that economists mean.

Third, since the bracket forces chord slopes to decrease, the frontier is **concave**: the first nat of drift buys you more reward than the tenth. Diminishing returns are not an empirical observation about tuning runs; they are a theorem. And the frontier terminates, as $\beta \to 0$, at the **tropical corner** $(L, \max_i r)$ — the point where the budget hits the ceiling and the reward hits the max-plus optimum simultaneously.

## Why this matters outside the page

Modern language-model alignment is literally this problem. A pre-trained model plays $\pi_0$; a learned reward model plays $r$; and the standard objective is the penalised one, $\mathbb{E}_p[r] - \beta\,\mathrm{KL}(p\|\pi_0)$, with $\beta$ hand-tuned. Practitioners speak of the "KL budget" of a run as if it were the primitive quantity, while the code optimises a penalty. The theorem above says they are entitled to that slippage — the two views are exchangeable, exactly, with a bijection between them. It also says something they may not expect: the achievable budgets stop at a ceiling determined by how much probability the base model already gives its best outputs, and that ceiling is invisible to the reward scale. If a run reports a KL divergence approaching $-\log \pi_0(\arg\max r)$, it is not drifting badly; it has simply arrived at the corner of the map.

The same skeleton is older than machine learning. In statistical mechanics, $\pi_0$ is the density of states, $r$ is minus the energy, $\beta$ is the inverse temperature, $\log Z$ is the free energy, the duality identity is the variational principle, and the tropical limit is the zero-temperature ground state. In finance, it is the entropic risk measure and the exponential change of measure. In large-deviations theory, it is the Gibbs conditioning principle and the Legendre duality between rate functions and cumulant generating functions. What the present treatment adds is the observation that all of these can be recovered from one line of algebra applied twice — and that the max-plus algebra hiding in the $\beta \to 0$ limit sets an exact, computable boundary on the whole enterprise.

A price and a leash. Set the price right and they are the same instruction. But the leash was never infinitely long, and how long it is was decided before you started tuning — by how much your original behaviour already loved its own best answer.
