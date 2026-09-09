# Constrained = Penalised
### A guided tour of reward, divergence, and the ceiling you cannot climb past

There are two ways to tell a system to be careful.

**A budget:** *change your behaviour, but by no more than this much.*
**A price:** *change whatever you like, but every unit of change costs you.*

A budget is a wall; a price is a slope. They feel like different instructions. This page is about a precise sense in which — if you set the price correctly — they are the *same* instruction, and about a surprise waiting at the end of the leash: the budget cannot be made arbitrarily large, and the exact limit is decided before you start tuning.

---

## 1. The cast of characters

Fix a finite set of outcomes. A **policy** $p$ is a probability distribution over them. We begin with a **reference policy** $\pi_0$, strictly positive ($\pi_0(i) > 0$ for all $i$), and a **reward** $r$ assigning a real number to each outcome.

Distance from the reference is measured in **nats** of relative entropy:

$$\mathrm{KL}(p\,\|\,\pi_0) \;=\; \sum_i p(i)\,\log\frac{p(i)}{\pi_0(i)} \;\ge\; 0,$$

with equality exactly when $p = \pi_0$. The two problems are:

$$\textbf{penalised:}\quad \max_p\ \mathbb{E}_p[r] - \beta\,\mathrm{KL}(p\|\pi_0)
\qquad\qquad
\textbf{constrained:}\quad \max_{\mathrm{KL}(p\|\pi_0)\,\le\,k}\ \mathbb{E}_p[r].$$

The penalised problem has a closed-form answer, the **exponential tilt**:

$$\pi^*_\beta(i) \;=\; \frac{\pi_0(i)\,e^{r(i)/\beta}}{Z(1/\beta)}, \qquad Z(t) = \sum_i \pi_0(i)e^{t\,r(i)}.$$

Throughout we write $t = 1/\beta$ for the *tilt parameter* and $p_t = \pi^*_{1/t}$, so that $p_0 = \pi_0$ and cold temperatures ($\beta\to 0$) mean large $t$.

<details>
<summary><b>Why does the penalised problem have that answer?</b> (click to expand)</summary>

Everything follows from one line of bookkeeping. Since $\log p_t(i) = \log\pi_0(i) + t\,r(i) - \log Z(t)$, expanding $\mathrm{KL}(p\|p_t)$ for an arbitrary policy $p$ gives the **master decomposition**

$$\mathrm{KL}(p\|p_t) \;=\; \mathrm{KL}(p\|\pi_0) \;-\; t\,\mathbb{E}_p[r] \;+\; \log Z(t).$$

Rearranged with $\beta = 1/t$:

$$\mathbb{E}_p[r] - \beta\,\mathrm{KL}(p\|\pi_0) \;=\; \beta\log Z(1/\beta) \;-\; \beta\,\mathrm{KL}(p\|p_t).$$

The first term on the right does not depend on $p$ and the second is $\le 0$, vanishing exactly when $p = p_t$. So the tilt is the unique maximiser, with optimal value $\beta\log Z(1/\beta)$. This is the [Gibbs variational principle](https://en.wikipedia.org/wiki/Gibbs_measure).
</details>

---

## 2. Play with it first

Before any theorems: drive the trade-off yourself. Move the temperature and watch the mass migrate toward high-reward outcomes; then switch to *budget mode* and name a divergence instead — the widget finds the unique temperature that realises it. Push the budget slider toward $1$ and watch the headroom collapse.

{{interactive_demo:0}}

Three things to try:

1. **Set a budget, read off a price.** In budget mode the reported $\beta$ is the *only* temperature realising that budget. The orange tangent on the frontier has slope exactly $\beta$.
2. **Throw challengers.** The green cloud is thousands of random policies inside the divergence ball. None of them ever rises above the blue arc.
3. **Change the mass on the best outcome.** Increase $\pi_0$ at the highest-reward outcome and the red ceiling line marches left. Change the *reward values* while keeping the argmax fixed and the ceiling does not move at all.

---

## 3. One identity does all the work

Apply the master decomposition to $p = p_t$ itself, where the left-hand side is zero, and you get the budget in closed form,

$$k(t) \;:=\; \mathrm{KL}(p_t\|\pi_0) \;=\; t\,V(t) - \log Z(t), \qquad V(t) := \mathbb{E}_{p_t}[r].$$

Subtracting the two statements cancels $\log Z$ and leaves the engine of the whole theory.

> **The duality identity.** For every policy $p$ and every $t$,
> $$t\bigl(V(t) - \mathbb{E}_p[r]\bigr) \;=\; k(t) \;-\; \mathrm{KL}(p\|\pi_0) \;+\; \mathrm{KL}(p\|p_t).$$

That single line, read with $t > 0$ and a feasible $p$, says: the right-hand side is a nonnegative number plus a nonnegative number, so $\mathbb{E}_p[r] \le V(t)$.

> **Constrained optimality.** If $\mathrm{KL}(p\|\pi_0) \le k(t)$ and $t>0$, then $\mathbb{E}_p[r] \le V(t)$; and if equality holds then $p = p_t$.

<details>
<summary><b>The uniqueness argument in full</b></summary>

Suppose $\mathbb{E}_p[r] = V(t)$. The left-hand side of the identity is then $0$, so
$$\underbrace{\bigl(k(t)-\mathrm{KL}(p\|\pi_0)\bigr)}_{\ge\,0\ \text{by feasibility}} \;+\; \underbrace{\mathrm{KL}(p\|p_t)}_{\ge\,0\ \text{by Gibbs}} \;=\; 0 .$$
Both terms vanish. In particular $\mathrm{KL}(p\|p_t) = 0$, and the equality case of [Gibbs' inequality](https://en.wikipedia.org/wiki/Gibbs%27_inequality) — itself a one-line consequence of $\log x \le x - 1$ — forces $p = p_t$. No Lagrange multipliers were harmed.
</details>

Applying the identity *twice*, at $s$ and at $t$, and adding, gives a second gem:

> **Jeffreys identity.** $(t-s)\bigl(V(t)-V(s)\bigr) = \mathrm{KL}(p_s\|p_t) + \mathrm{KL}(p_t\|p_s) \ \ge 0.$

So colder tilts never score worse, and (keeping only one side) $k(t) - k(s) \ge \mathrm{KL}(p_t\|p_s)$ for $0 \le s \le t$: the budget curve is strictly increasing whenever the reward actually distinguishes outcomes. Strictly increasing and continuous means **invertible** — which is exactly what "one budget, one temperature" needs.

---

## 4. The ceiling: where the leash runs out

Now the surprise. Let

$$M = \max_i r(i), \qquad A = \{i : r(i) = M\}, \qquad w = \pi_0(A),$$

and define the **tropical ceiling** $L = -\log w$. Then the achievable budgets are exactly $[0, L)$.

The reason is a two-sided estimate that is really a statement about $\max$ wearing the costume of $\sum$:

> **Tropical sandwich.** For $t \ge 0$: $\quad t\,M + \log w \;\le\; \log Z(t) \;\le\; t\,M.$

Divide by $t$ and let $t \to \infty$: $\;\frac{1}{t}\log Z(t) \to \max_i r(i)$. This is [Maslov dequantization](https://en.wikipedia.org/wiki/Tropical_geometry) — the passage from ordinary arithmetic to the **max-plus (tropical) semiring**, in which addition *is* maximum. The smooth soft-max hardens into the hard max, and the uniform error of the approximation is the single constant $|\log w| = L$.

<details>
<summary><b>Deriving the ceiling from the sandwich — two lines</b></summary>

Since $\mathbb{E}_p[r] \le M$ for every policy,
$$k(t) \;=\; t\,V(t) - \log Z(t) \;\le\; t\,M - (t\,M + \log w) \;=\; -\log w \;=\; L,$$
strictly whenever $r$ is non-constant (because then $V(t) < M$). Conversely, as $t\to\infty$ the tilt converges pointwise to $\pi_0$ *conditioned on the argmax set*, $p_\infty(i) = \pi_0(i)/w$ for $i\in A$ and $0$ otherwise, whose divergence is
$$\mathrm{KL}(p_\infty\|\pi_0) \;=\; \sum_{i\in A}\frac{\pi_0(i)}{w}\log\frac{1}{w} \;=\; -\log w \;=\; L .$$
So $k(t)\to L$ from below: the range is exactly $[0,L)$.
</details>

The ceiling is **not** an entropy, **not** a variance, and **not** sensitive to the reward scale: replace $r$ by $\lambda r + c$ with $\lambda>0$ and $L$ does not move. It depends only on *which* outcomes are best and *how much mass the reference already gave them* — a purely max-plus invariant. If the reference already places $10\%$ of its mass on optimal outcomes, nothing can ever be pushed more than $\log 10 \approx 2.30$ nats away, because the best conceivable policy is *already* only $2.30$ nats away.

{{visualization:0}}

Read the three panels left to right: the concave frontier with its tangents of slope $\beta$ and its terminal corner; the budget curve saturating at $L$, for references differing *only* in the mass they give the best outcome; and the dequantization limit with the explicit error band.

---

## 5. The headline

> **Constrained = Penalised.** Let $\pi_0 > 0$ on a finite outcome set, let $r$ be non-constant, and let $L = -\log\pi_0(\arg\max r)$. For every budget $k$ with $0 < k < L$ there is a **unique** temperature $\beta > 0$ with $\mathrm{KL}(\pi^*_\beta\|\pi_0) = k$, and for that $\beta$ the policy $\pi^*_\beta$ is the **unique** maximiser of $\mathbb{E}_p[r]$ over $\{p : \mathrm{KL}(p\|\pi_0)\le k\}$.

The proof is now assembly: strict monotonicity plus continuity plus $k(t)\to L$ give existence and uniqueness of the temperature by the intermediate value theorem; the duality identity gives optimality and uniqueness of the optimum.

Here is the calibration itself, as an algorithm. It is nothing more than bracket-and-bisect — but its *correctness* is exactly the monotonicity theorem, and its *termination condition* is exactly the ceiling theorem.

{{algorithm:0}}

---

## 6. The frontier, and the price of a nat

Plot the parametric curve $t \mapsto (k(t), V(t))$: the Pareto frontier of the trade-off. Three facts, all from the same identity.

**Bregman.** $\mathrm{KL}(p_s\|p_t) = \log Z(t) - \log Z(s) - (t-s)V(s)$. Since divergences are nonnegative, $\log Z$ lies above all its tangent lines — a derivative-free proof that the [cumulant generating function](https://en.wikipedia.org/wiki/Cumulant) is convex.

**Shadow price.** For $0 < s \le t$,
$$s\bigl(V(t)-V(s)\bigr) \;\le\; k(t)-k(s) \;\le\; t\bigl(V(t)-V(s)\bigr),$$
so every chord slope $\Delta V/\Delta k$ lies between $1/t$ and $1/s$. The temperature *is* the marginal price of one nat — the Lagrange multiplier, obtained without ever writing a Lagrangian.

**Concavity.** Because the bracket forces chord slopes to decrease, the frontier is concave: **diminishing returns are a theorem.** And the arc terminates at the **tropical corner** $(L, \max r)$.

{{algorithm:1}}

---

## 7. See the numbers

Talk is cheap; here is the arithmetic. The script below verifies the master decomposition and the duality identity to machine precision on thousands of random inputs, pits the tilt against tens of thousands of random feasible challengers, tabulates the sandwich and the dequantization limit, calibrates temperatures from budgets and checks the realised divergence, and confirms the shadow-price bracket and concavity numerically.

{{demo:0}}

<details>
<summary><b>What to look for in the output</b></summary>

* Identity residuals of order $10^{-15}$: the algebra is exact, the arithmetic is floating point.
* "best random feasible" always strictly below the tilt's value — thousands of times, in every ball.
* $L - k(t)$ shrinking geometrically as $t$ grows, never hitting zero.
* Calibration returning a realised divergence that matches the requested budget to ten decimals.
* Chord slopes $\Delta V/\Delta k$ decreasing monotonically, and $\Delta k/\Delta V$ landing inside $[s,t]$ every time.
</details>

---

## 8. Why anyone should care

The same skeleton keeps reappearing:

* **Aligning generative models.** A base model plays $\pi_0$, a learned reward plays $r$, and the training objective is the penalised one — while practitioners reason in terms of the "KL budget" of a run. The theorem licenses that translation exactly, and adds a caution the penalised view hides: the achievable budgets stop at $-\log \pi_0(\arg\max r)$, fixed by the base model alone.
* **Statistical mechanics.** With $r = -E$, the tilt is the [Boltzmann distribution](https://en.wikipedia.org/wiki/Boltzmann_distribution), $\log Z$ the free energy, the master decomposition the variational principle, and the $\beta \to 0$ limit the ground state; $L$ is the residual entropy of the ground-state manifold.
* **Large deviations.** A finite, non-asymptotic sibling of the [Gibbs conditioning principle](https://en.wikipedia.org/wiki/Large_deviations_theory): conditioning on a rare high-reward event is tilting, and the divergence budget is the rate.
* **Risk and robust control.** $\beta\log Z(1/\beta)$ is the entropic risk measure, here recast as the value of a divergence-ball robust optimisation.

---

## 9. Open questions

**Countable alphabets.** Conjecturally, for a reference on a countably infinite alphabet with $\sup_i r(i) = M < \infty$, the achievable range is $[0,L)$ with $L = -\log \pi_0(\arg\max r)$ *if and only if* the argmax set has positive mass; if that mass is zero — in particular if the supremum is not attained — the range should be all of $[0,\infty)$ and no finite ceiling exists. The ceiling would then be exposed as a genuinely tropical object: it degenerates precisely when the max-plus argmax cell becomes null. A natural falsifying test: a geometric reference with $r(i) = 1 - 2^{-i}$.

**A sharp alignment tax.** The shadow-price bracket already brackets every chord slope; integrating it should give two-sided bounds on the value function $V(k)$, with marginal price $dV/dk = 1/t(k)$ decaying from a $\mathrm{Var}_{\pi_0}(r)^{1/2}$ scale at $k \to 0$ to $0$ at $k \to L$.

**Vector rewards.** With several constraints the tilt becomes multi-temperature, $\propto \pi_0\exp(\sum_j t_j r_j)$, and the ceiling should become the negative log-mass of a tropical polyhedral *cell* rather than a single argmax set — the natural home for a fully tropical-geometric statement.

---

### The one-sentence version

A price and a leash are the same instruction, provided the price is right; the leash was never infinitely long; and how long it is was decided before you started, by how much your original behaviour already loved its own best answer.
