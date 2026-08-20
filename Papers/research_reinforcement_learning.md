# The Alignment Torsor: Legendre Duality, Sharp Reward-Hacking Budgets, and the Self-Consistent Gibbs Form of the Pretraining Mix-In

**Author:** Aristotle

**Date:** 2026-08-20

---

## Abstract

We give a complete convex-geometric and group-theoretic analysis of the reinforcement-learning-from-preferences objective with a pretraining mix-in,
$$J_\gamma(q) \;=\; \mathbb{E}_q[r] \;-\; \beta\,\mathrm{KL}(q\|p) \;+\; \gamma\,\mathbb{E}_{d}[\log q],$$
over strictly positive probability distributions $q$ on a finite response space $\Omega$, where $r$ is a reward model, $p$ a strictly positive reference policy, $d$ a pretraining distribution, and $\beta,\gamma > 0$.

Four groups of results are established. **(i) Torsor structure.** For $\gamma = 0$ the additive group of reward models modulo constants acts simply transitively on strictly positive policies by exponential tilting; in the mean-zero gauge this action is a homeomorphism onto the interior of the simplex, whose inverse is the implicit reward $\beta\log(q/p)$. **(ii) Legendre duality.** The alignment value $F(r) = \beta\log\sum_y p(y)e^{r(y)/\beta}$ and the KL penalty are an exact convex-conjugate pair with attained maximizers on both sides; the Bregman divergence of $F$ equals $\beta$ times the KL divergence between the corresponding aligned policies, and the Fenchel–Young inequality holds with equality precisely on the graph of the tilting map. **(iii) Sharp reward-hacking budgets.** $F$ is $1$-Lipschitz in the sup-norm of the reward, the constant $1$ is optimal (no $c<1$ works), and the sup-norm cannot be replaced by any reference-weighted quadratic norm, uniformly in the constant. **(iv) The mix-in.** For $\gamma>0$ the optimum exists and is unique; it is characterized exactly by constancy of a coordinatewise score, equivalently by the self-consistent Gibbs equation $q = \pi_{r+\gamma d/q}$; it obeys an explicit anti-starvation probability floor, a Pythagorean drift bound $\beta\,\mathrm{KL}(q^*\|\pi_r)+\gamma\,\mathrm{KL}(d\|q^*)\le\gamma\,\mathrm{KL}(d\|\pi_r)$, monotone comparative statics in $\gamma$ (monotone pretraining fit, monotone alignment tax, convex optimal value), and a two-sided-KL stability band $\beta(\mathrm{KL}(q_1\|q_2)+\mathrm{KL}(q_2\|q_1))\le 2\|r-s\|_\infty$ against reward perturbations.

The picture that emerges is that the three terms of the objective are not independent engineering choices: the reward is a linear functional, the KL penalty is the convex conjugate of the value it induces, and the pretraining mix-in is an interior barrier that acts as a self-referential reward bonus $\gamma d/q$.

---

## 1. Introduction

### 1.1 The objective

Alignment of a generative model by reinforcement learning from preference data optimizes, for each prompt, a distribution over responses. Fixing the prompt and writing $\Omega$ for the finite set of admissible responses, the standard objective with a pretraining mix-in reads

$$J_\gamma(q) \;=\; \sum_{y\in\Omega} q(y) r(y) \;-\; \beta \sum_{y\in\Omega} q(y)\log\frac{q(y)}{p(y)} \;+\; \gamma \sum_{y\in\Omega} d(y)\log q(y),$$

with:

* $r:\Omega\to\mathbb{R}$ the **reward model** (in a neurosymbolic pipeline, a score assembled from learned and rule-based components);
* $p:\Omega\to\mathbb{R}_{>0}$ the **reference policy** obtained by supervised fine-tuning, assumed strictly positive with $\sum_y p(y)=1$;
* $\beta>0$ the **KL temperature**, controlling how far the tuned policy may drift;
* $d$ the **pretraining distribution** and $\gamma\ge 0$ the **mix-in coefficient**, the term that prevents regression on general capabilities.

The optimization variable $q$ ranges over strictly positive probability distributions on $\Omega$. We write $\mathrm{KL}(q\|p) = \sum_y q(y)\log\frac{q(y)}{p(y)}$ and $H(d) = -\sum_y d(y)\log d(y)$.

### 1.2 What is proved

The engineering literature treats the three terms as a hand-balanced compromise. We show they form a single convex-geometric object.

* Section 3: the $\gamma=0$ problem has a closed-form solution and its solution set is a **torsor** over rewards-modulo-constants, both algebraically and topologically.
* Section 4: the alignment value and the KL penalty form an exact **Legendre dual pair**, with maximizers exhibited on both sides, so no subdifferential theory is needed.
* Section 5: the resulting Lipschitz bound is a **reward-hacking budget**, and it is sharp in a strong sense; moreover it cannot be improved by reference weighting.
* Sections 6–8: for $\gamma>0$ there is no closed form, but the optimum exists, is unique, and is characterized by an explicit **fixed-point equation**; we derive an anti-starvation floor, a Pythagorean drift bound, comparative statics in $\gamma$, and a policy-level stability band.

### 1.3 Standing conventions

Throughout, $\Omega$ is a finite nonempty set. A function $q:\Omega\to\mathbb{R}$ is a **distribution** if $q\ge 0$ pointwise and $\sum_y q(y)=1$, and a **positive distribution** if in addition $q(y)>0$ for all $y$. All reference policies $p$ and all candidate policies are positive distributions unless stated otherwise; $d$ is a distribution, sometimes assumed to have full support with an explicit lower bound $d\ge\delta>0$.

---

## 2. The Gibbs core

**Definition 2.1 (Partition function, free energy, Gibbs policy).** For $\beta>0$, a reward $r:\Omega\to\mathbb{R}$ and a positive distribution $p$, set
$$Z_\beta(r,p) \;=\; \sum_{y} p(y)\, e^{r(y)/\beta}, \qquad F_\beta(r,p) \;=\; \beta\log Z_\beta(r,p),$$
$$\pi_r(y) \;=\; \frac{p(y)\,e^{r(y)/\beta}}{Z_\beta(r,p)} .$$
We call $F_\beta(r,p)$ the **alignment value** and $\pi_r$ the **Gibbs (aligned) policy**. We suppress $\beta,p$ when they are clear, writing $F(r)$.

Since $p>0$ and the exponential is positive, $Z_\beta(r,p)>0$ and $\pi_r$ is a positive distribution.

**Definition 2.2 (Objectives).** $\;\mathcal{J}(q) = \sum_y q(y)r(y) - \beta\,\mathrm{KL}(q\|p)$ is the RLHF objective and $J_\gamma(q) = \mathcal{J}(q) + \gamma\sum_y d(y)\log q(y)$ the mix-in (PTX) objective.

**Definition 2.3 (Implicit reward).** For positive distributions $p,q$, the **implicit reward** is $\rho_{p,q}(y) = \beta\log\frac{q(y)}{p(y)}$.

**Proposition 2.4 (Variational principle; Gibbs decomposition).** For every distribution $q$,
$$\mathcal{J}(q) \;=\; F(r) \;-\; \beta\,\mathrm{KL}(q\,\|\,\pi_r).$$
Consequently $\mathcal{J}(q)\le F(r)$ with equality if and only if $q=\pi_r$.

*Proof sketch.* Expand $\mathrm{KL}(q\|\pi_r) = \sum_y q(y)\log\frac{q(y)}{p(y)} - \frac1\beta\sum_y q(y)r(y) + \log Z$, using $\sum_y q(y)=1$ to absorb the constant $\log Z$. Multiply by $\beta$ and rearrange. The equality case is the equality case of nonnegativity of KL divergence. $\square$

Proposition 2.4 is the engine of everything below: it converts a constrained optimization into an identity, so that the entire theory can be developed by algebra plus the single analytic fact $\mathrm{KL}\ge 0$ with equality iff the arguments agree.

**Lemma 2.5 (Gauge invariance).** For a constant $c$, $Z_\beta(r+c,p) = e^{c/\beta}Z_\beta(r,p)$, hence $F(r+c) = F(r)+c$ and $\pi_{r+c}=\pi_r$.

**Lemma 2.6 (Composition).** $\pi_{r_1+r_2}$ computed from $p$ equals $\pi_{r_2}$ computed from $\pi_{r_1}$; that is, tilting composes additively in the reward.

**Lemma 2.7 (Inversion).** If $q$ is a positive distribution then tilting $p$ by the implicit reward $\rho_{p,q}$ returns $q$: $\pi_{\rho_{p,q}} = q$.

*Proof sketch.* $p(y)e^{\rho_{p,q}(y)/\beta} = p(y)\cdot q(y)/p(y) = q(y)$, so the partition function is $1$ and normalization is vacuous. $\square$

---

## 3. The alignment torsor

### 3.1 Algebraic form

**Theorem 3.1 (Identifiability).** For $\beta>0$ and positive $p$: $\pi_{r_1}=\pi_{r_2}$ if and only if $r_1-r_2$ is constant.

*Proof sketch.* Sufficiency is Lemma 2.5. For necessity, equality of the two tilts gives $e^{(r_1(y)-r_2(y))/\beta} = Z_1/Z_2$ for every $y$, a constant; take logarithms and multiply by $\beta$. $\square$

**Theorem 3.2 (Alignment Torsor Theorem).** Let $\mathcal{R}=\mathbb{R}^\Omega$ be the additive group of reward models, $\mathcal{C}\le\mathcal{R}$ the subgroup of constant rewards, and $\mathcal{P}$ the set of positive distributions on $\Omega$. The rule $r\cdot q := \pi^{(q)}_r$ (tilt of $q$ by $r$) defines an action of $\mathcal{R}$ on $\mathcal{P}$ which is transitive with stabilizer exactly $\mathcal{C}$ at every point. Hence the quotient group $\mathcal{R}/\mathcal{C}$ acts **simply transitively** on $\mathcal{P}$: for each fixed $p\in\mathcal{P}$ the map
$$\mathcal{R}/\mathcal{C} \;\longrightarrow\; \mathcal{P}, \qquad [r]\longmapsto \pi_r$$
is a bijection, with inverse $q\mapsto[\rho_{p,q}]$.

*Proof sketch.* The action axioms are Lemmas 2.5–2.6; transitivity is Lemma 2.7; freeness modulo constants is Theorem 3.1. $\square$

Interpretation: *the space of aligned policies is a torsor over reward models modulo the constant gauge.* Policies and rewards carry the same information; choosing the reference $p$ chooses an origin. This is the structural content of implicit-reward (preference-optimization) methods, which train the policy directly and read the reward off afterwards.

### 3.2 Topological form

Fix the gauge by centering: let $\mathcal{R}_0 = \{r:\Omega\to\mathbb{R}\mid \sum_y r(y)=0\}$, a linear slice meeting each class $[r]$ exactly once, and let $\mathcal{P}$ carry the subspace topology from $\mathbb{R}^\Omega$. Define the **centered implicit reward**
$$\hat\rho_{p,q}(y) \;=\; \rho_{p,q}(y) \;-\; \frac{1}{|\Omega|}\sum_{z}\rho_{p,q}(z) \;\in\;\mathcal{R}_0 .$$

**Theorem 3.3 (Topological torsor).** For $\beta>0$ and positive $p$, the map $\mathcal{R}_0\to\mathcal{P}$, $r\mapsto\pi_r$, is a homeomorphism, with inverse $q\mapsto\hat\rho_{p,q}$. It intertwines the tilting action with translation: tilting $\pi_r$ by a centered reward $s$ yields $\pi_{r+s}$.

*Proof sketch.* Bijectivity: $\hat\rho_{p,\pi_r}=r$ for centered $r$ (by Theorem 3.1 the two differ by a constant, and both have zero sum), and $\pi_{\hat\rho_{p,q}}=q$ by Lemmas 2.5, 2.7. Continuity forward: $Z_\beta(\cdot,p)$ is a finite sum of continuous functions and is strictly positive, so $r\mapsto p(y)e^{r(y)/\beta}/Z$ is continuous in each coordinate. Continuity backward: on $\mathcal{P}$ every coordinate $q(y)$ is bounded away from $0$ locally, so $\log(q/p)$ is continuous, and subtracting the mean preserves continuity. $\square$

**Corollary 3.4 (Stability and collapse).** The aligned policy depends continuously on the reward model, and the extracted reward depends continuously on the policy — but only on the *interior* of the simplex. As $q(y)\downarrow 0$ the implicit reward $\beta\log(q(y)/p(y))\to-\infty$: the coordinate chart degenerates exactly at policy collapse. Collapse is therefore not a numerical artifact but the boundary of the domain on which the reward–policy correspondence is defined.

---

## 4. Legendre duality between value and penalty

### 4.1 Convexity of the alignment value, with an exact Bregman identity

**Theorem 4.1 (Gibbs–Bogoliubov–Feynman with exact remainder).** For rewards $r,s$, positive $p$, $\beta>0$:
$$F(s) \;\ge\; F(r) + \mathbb{E}_{\pi_r}[\,s-r\,], \qquad\text{and precisely}\qquad F(s) - F(r) - \mathbb{E}_{\pi_r}[\,s-r\,] \;=\; \beta\,\mathrm{KL}(\pi_r\,\|\,\pi_s).$$

*Proof sketch.* Apply Proposition 2.4 to the reward $s$ and the test policy $q=\pi_r$: $\mathbb{E}_{\pi_r}[s]-\beta\,\mathrm{KL}(\pi_r\|p) = F(s)-\beta\,\mathrm{KL}(\pi_r\|\pi_s)$. Apply it again with reward $r$ and the same test policy, where the KL term vanishes: $\mathbb{E}_{\pi_r}[r]-\beta\,\mathrm{KL}(\pi_r\|p) = F(r)$. Subtract. Nonnegativity of the remainder is nonnegativity of KL. $\square$

Thus the Bregman divergence of the alignment value, viewed as a function of the reward, is exactly $\beta$ times the information distance between the induced policies. Everything convex-analytic now follows without calculus.

**Corollary 4.2.** (i) $F$ is convex along segments: $F(\theta r + (1-\theta)s)\le \theta F(r)+(1-\theta)F(s)$ for $\theta\in[0,1]$; (ii) $F$ is monotone: $r\le s$ pointwise implies $F(r)\le F(s)$; (iii) equality in Theorem 4.1 holds iff $\pi_r=\pi_s$, i.e. iff $s-r$ is constant, so $F$ is strictly convex transverse to the gauge; (iv) $F(r+c)=F(r)+c$ for constants $c$.

*Proof sketch.* (i) Sum the two supporting-hyperplane inequalities at the segment point, weighted by $\theta$ and $1-\theta$; the linear terms cancel. (ii) Take $\pi_r$ as test policy and use $\mathbb{E}_{\pi_r}[s-r]\ge 0$. (iii) is Theorem 4.1 plus the equality case of KL and Theorem 3.1. $\square$

### 4.2 Both directions of the conjugacy, with attainment

**Theorem 4.3 (Primal attainment).** For $\beta>0$ and positive $p$,
$$F(r) \;=\; \max\Big\{\,\mathbb{E}_q[r]-\beta\,\mathrm{KL}(q\|p) \;:\; q \text{ a distribution on }\Omega \Big\},$$
the maximum being attained (uniquely, among positive $q$) at $q=\pi_r$.

*Proof sketch.* Membership: evaluate at $q=\pi_r$ and use Proposition 2.4 with vanishing KL term. Upper bound: Proposition 2.4 for arbitrary $q$. $\square$

**Theorem 4.4 (Fenchel–Young).** For any distribution $q$, $\;\mathbb{E}_q[r]\le F(r)+\beta\,\mathrm{KL}(q\|p)$.

**Theorem 4.5 (Equality case).** For a positive $p$ and a distribution $q$, equality holds in Theorem 4.4 if and only if $q=\pi_r$.

*Proof sketch.* By Proposition 2.4, the Fenchel–Young gap equals $\beta\,\mathrm{KL}(q\|\pi_r)$; use $\beta>0$ and the equality case of KL. $\square$

**Theorem 4.6 (Dual attainment: the KL penalty is the convex conjugate of the alignment value).** For $\beta>0$ and positive distributions $p,q$,
$$\beta\,\mathrm{KL}(q\|p) \;=\; \max\Big\{\, \mathbb{E}_q[r] - F(r) \;:\; r:\Omega\to\mathbb{R}\,\Big\},$$
attained at the implicit reward $r=\rho_{p,q}=\beta\log(q/p)$.

*Proof sketch.* Two computations. First, $F(\rho_{p,q}) = 0$: indeed $p(y)e^{\rho_{p,q}(y)/\beta}=q(y)$, so $Z=\sum_y q(y)=1$ and $F=\beta\log 1=0$. Second, $\mathbb{E}_q[\rho_{p,q}] = \beta\sum_y q(y)\log\frac{q(y)}{p(y)} = \beta\,\mathrm{KL}(q\|p)$. Hence the candidate value is attained. The upper bound is exactly Theorem 4.4. $\square$

**Discussion.** Theorems 4.3 and 4.6 say that $F$ and $\beta\,\mathrm{KL}(\cdot\|p)$ are a Legendre-conjugate pair on the pairing $\langle q,r\rangle = \mathbb{E}_q[r]$, and that both conjugates are attained with explicit maximizers, so no smoothness or subdifferential machinery is required. The KL penalty in the objective is therefore not a heuristic leash: it is the unique convex function whose conjugate is the achievable alignment value. Rewards and policies are Legendre-dual coordinates and the tilting torsor of Section 3 is the gradient correspondence between them, with the graph of that correspondence being exactly the equality set of Fenchel–Young (Theorem 4.5).

---

## 5. Reward hacking: a sharp budget

**Theorem 5.1 (Reward-hacking budget).** If $|r(y)-s(y)|\le K$ for all $y$, then $|F(r)-F(s)|\le K$. That is, $F$ is $1$-Lipschitz for the sup-norm.

*Proof sketch.* $s\le r+K$ pointwise, so by monotonicity and the shift rule $F(s)\le F(r+K)=F(r)+K$; symmetrically $F(r)\le F(s)+K$. $\square$

Interpretation: a reward model corrupted by at most $K$ can change the attainable value of the alignment program by at most $K$. The natural question is whether the constant $1$ is an artifact.

**Theorem 5.2 (Sharpness).** For every $K\ge 0$ and every $\varepsilon>0$ there exist a temperature $\beta>0$, a reference policy $p$ on a two-element response space, and rewards $r,s$ with $\sup_y|r(y)-s(y)|\le K$ and
$$\bigl|F_\beta(r,p)-F_\beta(s,p)\bigr| \;>\; K-\varepsilon .$$

*Proof sketch.* Take $\Omega=\{0,1\}$, $p\equiv 1/2$, $r\equiv 0$, and $s$ the spike $s(1)=K$, $s(0)=0$. Then $F(r)=\beta\log 1=0$ and
$$F(s) \;=\; \beta\log\frac{e^{K/\beta}+1}{2} \;\ge\; \beta\log\frac{e^{K/\beta}}{2} \;=\; K-\beta\log 2 .$$
Choosing $\beta=\varepsilon/2$ and using $\log 2\le 1$ gives $F(s)\ge K-\varepsilon/2 > K-\varepsilon$. $\square$

**Corollary 5.3 (No smaller constant).** There is no $c<1$ such that $|F(r)-F(s)|\le c\sup_y|r-s|$ holds for all finite response spaces, temperatures, reference policies and reward pairs.

*Proof sketch.* Apply Theorem 5.2 with $K=1$ and $\varepsilon=(1-c)/2$ to obtain an instance with gap $>1-(1-c)/2 > c$. $\square$

The extremal regime is $\beta\to 0^+$: a loose KL leash relative to the reward scale. This is exactly the empirical regime of reward hacking, and Theorem 5.2 shows the worst case there is not merely qualitative but attains the entire budget.

**Theorem 5.4 (Reference weighting fails).** For every constant $C$ there exist $\beta>0$, a positive reference $p$ on a two-element response space, and rewards $r,s$ with
$$C\left(\sum_y p(y)\,(r(y)-s(y))^2\right)^{1/2} \;<\; \bigl|F_\beta(r,p)-F_\beta(s,p)\bigr| .$$

*Proof sketch.* Take $\Omega=\{0,1\}$, $p(1)=\delta$, $p(0)=1-\delta$, $r\equiv 0$, and $s$ the unit spike $s(1)=1$, $s(0)=0$. Then the reference-weighted distance is $\sqrt{\delta}$, while
$$F(s) \;=\; \beta\log\big(\delta e^{1/\beta}+1-\delta\big) \;\ge\; \beta\log\big(\delta e^{1/\beta}\big) \;=\; 1+\beta\log\delta .$$
Choose $\beta = 1/(2\log(1/\delta)+2)$, so the right side is at least $1/2$; then choose $\delta\le 1/(16(C^2+1))$, so $C\sqrt{\delta}\le 1/4 < 1/2$. $\square$

**Discussion.** Theorem 5.4 is an obstruction to a natural class of defenses. Auditing a reward model "where the base model actually puts probability" — i.e. in $L^2(p)$ — is uninformative: exponential tilting amplifies the tail of $p$ without limit, so corruption concentrated on rare responses is invisible to a tail-discounting metric while still moving the achievable value by $\Theta(1)$. Note that any norm *dominating* the sup-norm (e.g. the unweighted $\ell^2$ norm) inherits Theorem 5.1 trivially; it is specifically the reference-weighted norms that fail.

---

## 6. The pretraining mix-in: existence, uniqueness, characterization

Restore $\gamma>0$. Unlike the $\gamma=0$ problem, the mix-in problem has no closed-form solution: its stationarity condition is transcendental. We supply the full replacement.

### 6.1 Strict concavity and uniqueness

**Theorem 6.1 (Strict midpoint concavity).** Let $\beta>0$, $\gamma\ge0$, $d\ge0$, $p$ positive, and let $q_1\neq q_2$ be positive distributions. Then
$$J_\gamma\!\left(\tfrac{q_1+q_2}{2}\right) \;>\; \tfrac12 J_\gamma(q_1)+\tfrac12 J_\gamma(q_2).$$

*Proof sketch.* Write $J_\gamma(q) = \sum_y\big[q(y)r(y) - \beta\,q(y)\log\frac{q(y)}{p(y)} + \gamma\,d(y)\log q(y)\big]$, a sum of coordinatewise terms. The reward term is affine. The map $t\mapsto -t\log(t/p(y))$ is strictly concave in $t>0$, and strictly so at any coordinate where $q_1(y)\ne q_2(y)$; the map $t\mapsto \log t$ is concave. Since $q_1\ne q_2$ at some coordinate, the entropy term contributes a strict inequality there and all other terms contribute non-strict ones. $\square$

**Corollary 6.2 (Uniqueness).** $J_\gamma$ has at most one maximizer among positive distributions.

### 6.2 Existence

The obstacle to existence is that the feasible set — the open interior of the simplex — is not compact. The mix-in itself supplies the remedy.

**Theorem 6.3 (Existence and uniqueness).** Let $\beta>0$, $\gamma>0$, $p$ positive, and suppose the pretraining distribution satisfies $d(y)\ge\delta>0$ for all $y$. Then $J_\gamma$ attains a maximum over positive distributions at a unique policy $q^*$.

*Proof sketch.* Three steps. (a) *Barrier estimate.* If $q(y_0)\le\varepsilon$ for some $y_0$, then $\gamma d(y_0)\log q(y_0)\le \gamma\delta\log\varepsilon\to-\infty$, while the remaining terms are bounded above (the reward term by $\max_y r(y)$, the negative-KL term by $0$, and the other mix-in terms by $0$ since $\log q\le 0$). Hence there is $\varepsilon>0$, depending only on the data, such that any policy with a coordinate below $\varepsilon$ has value below $J_\gamma(u)$ for the uniform policy $u$. (b) *Compactness.* The slice $\Delta_\varepsilon=\{q:\ q(y)\ge\varepsilon\ \forall y,\ \sum_y q(y)=1\}$ is closed and bounded in $\mathbb{R}^\Omega$, hence compact, and is nonempty for $\varepsilon\le1/|\Omega|$. (c) *Continuity.* On $\Delta_\varepsilon$ every coordinate is bounded away from $0$, so $J_\gamma$ is continuous; it attains a maximum on $\Delta_\varepsilon$ by compactness, and by (a) that maximum is global over all positive distributions. Uniqueness is Corollary 6.2. $\square$

### 6.3 Exact first-order characterization

**Definition 6.4 (Coordinatewise score).** For a positive policy $q$,
$$S_q(y) \;=\; r(y) \;-\; \beta\left(\log\frac{q(y)}{p(y)}+1\right) \;+\; \gamma\,\frac{d(y)}{q(y)} .$$
This is the marginal value of transferring probability mass onto $y$.

**Theorem 6.5 (Stationarity, necessity).** If $q$ maximizes $J_\gamma$ over positive distributions, then $S_q$ is constant on $\Omega$.

*Proof sketch.* Fix $y_1\ne y_2$ and consider the mass-shifting family $q_\varepsilon = q + \varepsilon(\mathbf{1}_{y_1}-\mathbf{1}_{y_2})$, which stays a positive distribution for $|\varepsilon|$ small. The function $\varepsilon\mapsto J_\gamma(q_\varepsilon)$ has a local maximum at $\varepsilon=0$, and — this is proved, not assumed — it is differentiable there, with derivative $S_q(y_1)-S_q(y_2)$: each coordinate term $t\mapsto t\,r(y)-\beta t\log(t/p(y))+\gamma d(y)\log t$ is differentiable at $t=q(y)>0$ with derivative $r(y)-\beta(\log(t/p(y))+1)+\gamma d(y)/t$. Vanishing of the derivative gives $S_q(y_1)=S_q(y_2)$. $\square$

**Theorem 6.6 (Stationarity, sufficiency, with strictness).** Let $\beta>0$, $\gamma\ge0$, $d\ge 0$, $p$ and $q$ positive distributions. If $S_q$ is constant then $q$ is the *global* maximizer of $J_\gamma$, and $J_\gamma(q')<J_\gamma(q)$ for every positive distribution $q'\ne q$.

*Proof sketch.* Purely algebraic. Coordinatewise concavity gives, for each $y$ and each $t'>0$,
$$\phi_y(t') \;\le\; \phi_y(q(y)) + S_q(y)\,(t'-q(y)),$$
where $\phi_y$ is the coordinate term of $J_\gamma$; the required elementary inequalities are $\log t\le t-1$ (applied twice, once for the entropy term and once for the mix-in term) with equality iff $t=1$. Summing over $y$ with $t'=q'(y)$ and using constancy $S_q\equiv c$, the linear term telescopes to $c\sum_y (q'(y)-q(y)) = 0$. Hence $J_\gamma(q')\le J_\gamma(q)$, with strict inequality as soon as some coordinate differs. $\square$

**Theorem 6.7 (Exact characterization).** For $\beta>0,\gamma\ge0$, $d\ge0$, $p,q$ positive: $q$ maximizes $J_\gamma$ $\iff$ $S_q$ is constant.

### 6.4 The self-consistent Gibbs form

**Theorem 6.8 (Fixed-point form of the optimum).** Let $\beta>0$, $p$ positive, and let $q$ maximize $J_\gamma$. Then $q$ is the Gibbs policy of its own PTX-augmented reward:
$$q \;=\; \pi_{\,r+\gamma d/q}, \qquad\text{i.e.}\qquad q(y) \;=\; \frac{p(y)\exp\!\Big(\frac{1}{\beta}\big(r(y)+\gamma \tfrac{d(y)}{q(y)}\big)\Big)}{\sum_{z} p(z)\exp\!\Big(\frac{1}{\beta}\big(r(z)+\gamma \tfrac{d(z)}{q(z)}\big)\Big)} .$$
Conversely, any positive distribution satisfying this equation is the global maximizer. Hence *the fixed points of the self-consistent Gibbs map are exactly the optima*, and (under $d\ge\delta>0$, $\gamma>0$) such a fixed point exists and is unique.

*Proof sketch.* ($\Rightarrow$) Constancy $S_q\equiv c$ rearranges to $\log\frac{q(y)}{p(y)} = \frac{\tilde r(y)-\beta-c}{\beta}$ with $\tilde r = r+\gamma d/q$, so $q(y) = p(y)e^{\tilde r(y)/\beta}\cdot \kappa$ with $\kappa=e^{-(\beta+c)/\beta}$ independent of $y$; summing to $1$ identifies $\kappa = 1/Z_\beta(\tilde r,p)$. ($\Leftarrow$) If $q=\pi_{\tilde r}$ then $\log\frac{q(y)}{p(y)} = \tilde r(y)/\beta - \log Z_\beta(\tilde r,p)$, which upon substitution gives $S_q(y) = \beta\log Z_\beta(\tilde r,p)-\beta$, a constant; apply Theorem 6.6. Existence and uniqueness are Theorem 6.3. $\square$

**Interpretation.** The mix-in behaves exactly as ordinary tilted alignment against an augmented reward $r+\gamma\,d/q$. The bonus $\gamma d(y)/q(y)$ is a **self-referential subsidy**: it is large precisely on responses that the pretraining distribution likes and the current policy has suppressed, and it vanishes on responses already over-weighted relative to $d$. This is a fixed-point equation, solvable numerically by the obvious iteration $q_{k+1}=\pi_{r+\gamma d/q_k}$ (damped in practice), and it fully replaces the missing closed form.

### 6.5 Anti-starvation

**Theorem 6.9 (No mode collapse under the mix-in).** Let $\beta>0$, $\gamma>0$, $p$ positive, $d$ a distribution, and suppose $r(y)\le M$ for all $y$. If $q$ maximizes $J_\gamma$ then for every $y$ with $d(y)>0$,
$$q(y) \;\ge\; \frac{\gamma\, d(y)}{\beta\log\frac{1}{p(y)} + M + \gamma - r(y)} \;>\;0 .$$

*Proof sketch.* Averaging the constancy relation $S_q\equiv c$ against $q$ evaluates the constant:
$$c \;=\; \mathbb{E}_q[r] - \beta\,\mathrm{KL}(q\|p) - \beta + \gamma .$$
Substituting into $S_q(y)=c$ and solving for the bonus term gives
$$\frac{\gamma d(y)}{q(y)} \;=\; \beta\log\frac{q(y)}{p(y)} + \beta + c - r(y) \;\le\; \beta\log\frac{1}{p(y)} + M + \gamma - r(y),$$
using $q(y)\le1$, $\mathbb{E}_q[r]\le M$ and $\mathrm{KL}(q\|p)\ge0$. Rearranging (the right-hand side is positive because the left-hand side is) gives the claim. $\square$

This is a **hard, reward-independent probability floor**. However badly a corrupted reward model scores a response, if the pretraining distribution assigns it mass then the aligned model must keep it above the stated level. The floor scales linearly in $\gamma$ and degrades only logarithmically in the rarity $1/p(y)$ of the response under the reference policy.

---

## 7. Drift: how far the mix-in moves the policy

Write $\pi=\pi_r$ for the pure-RLHF Gibbs policy.

**Lemma 7.1 (KL form of the mix-in objective).** For positive $q$ and a distribution $d$,
$$J_\gamma(q) \;=\; F(r) \;-\; \beta\,\mathrm{KL}(q\|\pi) \;-\; \gamma H(d) \;-\; \gamma\,\mathrm{KL}(d\|q).$$

*Proof sketch.* Proposition 2.4 handles the first two terms; for the last, $\mathrm{KL}(d\|q) = -H(d) - \sum_y d(y)\log q(y)$. $\square$

The mix-in objective is thus, up to the constant $-\gamma H(d)$, a *weighted sum of two information distances to be minimized simultaneously*: distance from the aligned policy $\pi$ (weight $\beta$) and distance from the pretraining distribution $d$ (weight $\gamma$).

**Theorem 7.2 (Pythagorean inequality).** If $q$ is at least as good as $\pi$ for $J_\gamma$ (in particular if $q$ is the optimum), then
$$\beta\,\mathrm{KL}(q\|\pi) \;+\; \gamma\,\mathrm{KL}(d\|q) \;\le\; \gamma\,\mathrm{KL}(d\|\pi).$$

*Proof sketch.* Apply Lemma 7.1 at $q$ and at $\pi$ (where $\mathrm{KL}(\pi\|\pi)=0$) and subtract, using $J_\gamma(\pi)\le J_\gamma(q)$. $\square$

The two left-hand terms are the legs of an information-geometric right triangle whose hypotenuse is $\mathrm{KL}(d\|\pi)$: the optimum lies "between" $\pi$ and $d$, and the total drift budget is fixed by how far alignment had already moved the model from the pretraining distribution.

**Corollary 7.3 (Drift bound).** With $\gamma\ge0$, $\;\mathrm{KL}(q\|\pi)\le \dfrac{\gamma}{\beta}\,\mathrm{KL}(d\|\pi)$.

**Corollary 7.4 (Rigidity).** If $d=\pi$ then the optimum is exactly $\pi$: when the pretraining distribution already coincides with the aligned policy, the mix-in has no effect whatsoever.

**Corollary 7.5 (Continuous degeneration as $\gamma\to0^+$).** For any selection $\gamma\mapsto q^*_\gamma$ of mix-in optima, $\mathrm{KL}(q^*_\gamma\|\pi)\to 0$ as $\gamma\to0^+$. Thus the mix-in objective interpolates continuously into plain KL-regularized alignment.

*Proof sketch.* Squeeze $0\le \mathrm{KL}(q^*_\gamma\|\pi)\le(\gamma/\beta)\mathrm{KL}(d\|\pi)$ and let $\gamma\downarrow0$. $\square$

---

## 8. Comparative statics and stability

### 8.1 Moving the mix-in coefficient

The following are Topkis-style arguments using only the two optimality inequalities; no differentiability of $\gamma\mapsto q^*_\gamma$ is needed. Write $T(q) = \sum_y d(y)\log q(y)$ for the pretraining fit and recall $J_\gamma = \mathcal{J} + \gamma T$.

**Theorem 8.1 (Monotone pretraining fit).** If $\gamma_1<\gamma_2$ and $q_i$ maximizes $J_{\gamma_i}$, then $T(q_1)\le T(q_2)$.

*Proof sketch.* Add the two optimality inequalities $J_{\gamma_1}(q_2)\le J_{\gamma_1}(q_1)$ and $J_{\gamma_2}(q_1)\le J_{\gamma_2}(q_2)$. The $\mathcal{J}$ terms cancel, leaving $(\gamma_2-\gamma_1)T(q_1)\le(\gamma_2-\gamma_1)T(q_2)$; divide by $\gamma_2-\gamma_1>0$. $\square$

**Theorem 8.2 (Monotone alignment tax).** Under the same hypotheses with $\gamma_1\ge 0$, $\;\mathcal{J}(q_2)\le\mathcal{J}(q_1)$.

*Proof sketch.* From $J_{\gamma_1}(q_2)\le J_{\gamma_1}(q_1)$, i.e. $\mathcal{J}(q_2)+\gamma_1 T(q_2)\le \mathcal{J}(q_1)+\gamma_1 T(q_1)$, and $T(q_1)\le T(q_2)$ from Theorem 8.1, we get $\mathcal{J}(q_2)-\mathcal{J}(q_1)\le \gamma_1(T(q_1)-T(q_2))\le0$. $\square$

So the reward-minus-KL part of the objective — the quantity alignment actually optimizes — is paid down monotonically as the mix-in is strengthened. This is the **alignment tax**, and it is monotone: there is no coefficient regime in which strengthening the mix-in improves alignment quality.

**Theorem 8.3 (Value is decreasing).** If $\gamma_1\le\gamma_2$, $d\ge0$, and $q_1$ maximizes $J_{\gamma_1}$, then $J_{\gamma_2}(q)\le J_{\gamma_1}(q_1)$ for *every* positive distribution $q$; in particular the optimal value is nonincreasing in $\gamma$.

*Proof sketch.* $T(q)\le0$ for every distribution since $\log q(y)\le 0$; hence $J_{\gamma_2}(q)\le J_{\gamma_1}(q)\le J_{\gamma_1}(q_1)$. $\square$

**Theorem 8.4 (Envelope: value is convex in $\gamma$).** Let $\theta\in[0,1]$, let $q_i$ maximize $J_{\gamma_i}$, and let $q_\theta$ be any positive distribution. Then
$$J_{\theta\gamma_1+(1-\theta)\gamma_2}(q_\theta) \;\le\; \theta\,J_{\gamma_1}(q_1) + (1-\theta)\,J_{\gamma_2}(q_2).$$
In particular the optimal value $V(\gamma)=\max_q J_\gamma(q)$ is a convex function of $\gamma$.

*Proof sketch.* $J_\gamma(q)$ is affine in $\gamma$ for fixed $q$, so $J_{\theta\gamma_1+(1-\theta)\gamma_2}(q_\theta) = \theta J_{\gamma_1}(q_\theta)+(1-\theta)J_{\gamma_2}(q_\theta)$; bound each term by the corresponding optimum. A maximum of affine functions is convex. $\square$

### 8.2 Stability of the optimal policy under reward perturbation

**Lemma 8.5 (Strong concavity at the optimum).** If $q_1$ maximizes $J_\gamma$ for reward $r$, then for every positive distribution $q_2$,
$$J_\gamma(q_2) + \beta\,\mathrm{KL}(q_2\|q_1) \;\le\; J_\gamma(q_1).$$

*Proof sketch.* Coordinatewise, the tangent inequality of Theorem 6.6 can be sharpened: for the entropy term the gap between $\phi_y(t')$ and its tangent at $t=q_1(y)$ is at least $\beta\,t'\log(t'/t)$ after summation, which assembles to $\beta\,\mathrm{KL}(q_2\|q_1)$; the mix-in and reward terms contribute nonpositively. Summing and using constancy of the score at $q_1$ gives the claim. $\square$

**Theorem 8.6 (Two-sided KL stability).** Let $q_1,q_2$ be the mix-in optima for rewards $r,s$ respectively (same $\beta,\gamma,p,d$). Then
$$\beta\Big(\mathrm{KL}(q_1\|q_2)+\mathrm{KL}(q_2\|q_1)\Big) \;\le\; \sum_y \big(q_1(y)-q_2(y)\big)\big(r(y)-s(y)\big).$$

*Proof sketch.* Apply Lemma 8.5 twice (for $r$ at $q_1$ tested against $q_2$, and for $s$ at $q_2$ tested against $q_1$) and add. The mix-in and KL-to-$p$ parts cancel because $J^{(r)}_\gamma(q)-J^{(s)}_\gamma(q) = \sum_y q(y)(r(y)-s(y))$ depends on $q$ only through the reward pairing. $\square$

**Corollary 8.7 (Reward-hacking immunity band for the policy).** If $|r(y)-s(y)|\le K$ for all $y$, then
$$\beta\Big(\mathrm{KL}(q_1\|q_2)+\mathrm{KL}(q_2\|q_1)\Big) \;\le\; 2K .$$

*Proof sketch.* Bound each term of Theorem 8.6 by $|q_1(y)-q_2(y)|\,K\le (q_1(y)+q_2(y))K$ and sum, using that both are probability distributions. $\square$

The band is non-vacuous: under $d\ge\delta>0$ and $\gamma>0$ both optima exist by Theorem 6.3. Together with Theorem 5.1 this gives a complete first-order robustness picture: a sup-norm-$K$ corruption of the reward moves the *value* by at most $K$ (sharply) and the *policy* by at most $2K/\beta$ in symmetrized information distance. Both bounds degrade as $\beta\to0^+$, quantifying the standard practical observation that aggressive reward chasing at low KL penalty is precisely where hacking occurs.

---

## 9. Algorithms

The theory is constructive. Three procedures follow directly.

**(A) Exact aligned policy ($\gamma=0$).** Compute $\pi_r(y)\propto p(y)e^{r(y)/\beta}$ by a numerically stable softmax on $\log p + r/\beta$, and $F(r) = \beta\,\mathrm{logsumexp}(\log p + r/\beta)$. Cost $O(|\Omega|)$.

**(B) Mix-in optimum by self-consistent tilting.** Iterate $q_{k+1} = (1-\lambda)q_k + \lambda\,\pi_{r+\gamma d/q_k}$ from $q_0=\pi_r$, with damping $\lambda\in(0,1]$. Each step costs $O(|\Omega|)$; the fixed points are exactly the optima by Theorem 6.8, and uniqueness (Corollary 6.2) means any convergent run lands on the answer. Convergence can be certified a posteriori by checking that the score $S_q$ is constant to within tolerance (Theorem 6.7), which is a *verified optimality certificate*, not a heuristic stopping rule.

**(B$'$) Dual bisection (globally convergent).** The iteration in (B) is not a contraction in general and can oscillate. A bracketed alternative exploits the structure of the stationarity system directly. Fix a trial value $c$ for the common score. For each $y$ the equation $r(y)-\beta(\log(t/p(y))+1)+\gamma d(y)/t = c$ has a *unique* root $t_y(c)>0$, because the left side is strictly decreasing in $t$; and $t_y(c)$ is itself strictly decreasing in $c$. Hence the total mass $\mathrm{M}(c)=\sum_y t_y(c)$ is strictly decreasing, tends to $+\infty$ as $c\to-\infty$ and to $0$ as $c\to+\infty$, so bisection on $c$ locates the unique $c^*$ with $\mathrm{M}(c^*)=1$, and $q^*=(t_y(c^*))_y$. Each outer step costs $|\Omega|$ inner bisections, so the total cost is $O(|\Omega|\log(1/\epsilon)^2)$ for accuracy $\epsilon$, and the method converges globally with a guaranteed bracket.

**(C) Certified projected ascent.** Alternatively, maximize $J_\gamma$ over the compact slice $\Delta_\varepsilon$ of Theorem 6.3 by any convex-programming method, then certify with the score-constancy test. The barrier estimate of Theorem 6.3 supplies an explicit safe $\varepsilon$.

All of these come with checkable guarantees drawn from the theorems: the Fenchel–Young gap $F(r)+\beta\mathrm{KL}(q\|p)-\mathbb{E}_q[r]$ measures suboptimality for (A); the score spread $\max_y S_q(y)-\min_y S_q(y)$ measures suboptimality for (B), (B$'$) and (C); and the Pythagorean bound of Theorem 7.2 gives an a priori trust region for the answer.

---

## 10. Applications and interpretation

**Reward extraction is well-posed, until it isn't.** Theorem 3.3 says reward-from-policy extraction is a continuous inverse on the interior of the simplex. This licenses implicit-reward training methods: one may train the policy and read off the reward. Corollary 3.4 says the license expires at the boundary, and that "policy collapse" is precisely the statement that the coordinate chart has degenerated. Practically: monitor $\min_y q(y)$, because the extracted reward's conditioning is governed by it.

**Choosing $\beta$ is choosing a robustness level.** Theorem 5.1 and Corollary 8.7 make $\beta$ the single dial trading achievable reward against sensitivity to reward error. Theorem 5.2 shows this trade cannot be improved by better analysis: at small $\beta$ the entire corruption budget is realizable.

**Auditing reward models.** Theorem 5.4 rules out reference-weighted audits. A reward-model diagnostic must be a sup-norm-type (worst-case-over-responses) statement, or it is not a statement about achievable alignment value at all. Uniform-norm bounds, adversarial search over rare responses, and coverage of the tail of $p$ are the meaningful instruments.

**Setting the mix-in coefficient.** Theorems 8.1–8.4 give the exact shape of the trade-off curve: pretraining fit up, alignment quality down, both monotone, with a convex value curve in $\gamma$. Convexity means the marginal cost of the mix-in is increasing, so the useful operating point is at small $\gamma$; Corollary 7.3 quantifies the corresponding drift as at most $(\gamma/\beta)\mathrm{KL}(d\|\pi_r)$.

**Guaranteeing diversity.** Theorem 6.9 is a rare *hard* guarantee in alignment: an explicit lower bound on every response's probability, independent of the reward model. It converts "the mix-in helps prevent mode collapse" into an inequality one can evaluate before training, and it identifies the parameters that control the floor: $\gamma$ linearly, and $p(y)$ only logarithmically.

**A neurosymbolic reading.** When the reward $r$ is assembled from symbolic rules, Theorem 6.8 says the effective reward being optimized is $r+\gamma d/q$: symbolic constraints plus an automatic statistical prior term. The symbolic component is exact and the statistical component self-regulating; the two are combined additively in the exponent, which is the precise sense in which the mix-in is "the prior speaking in reward units".

---

## 11. Discussion, limitations, and future work

### 11.1 Scope

All results are for a fixed prompt and a finite response space with a strictly positive reference policy. Finiteness is used for compactness (Theorem 6.3) and for the coordinatewise perturbation argument (Theorem 6.5); positivity of $p$ is essential, since the torsor and duality statements live on the interior of the simplex. Extension to countable or continuous response spaces requires integrability hypotheses on $e^{r/\beta}$ under $p$ and replaces compactness with a suitable coercivity argument; the algebraic and duality statements (Sections 3–5) should survive verbatim wherever the partition function is finite.

A second limitation is that the mix-in optimum is characterized but not solved: Theorem 6.8 provides a fixed-point equation, not a formula, and no contraction estimate for the iteration $q\mapsto\pi_{r+\gamma d/q}$ is proved here. Establishing a contraction modulus in terms of $\beta,\gamma,\delta$ would upgrade algorithm (B) to a certified linear-rate method.

### 11.2 Open directions

**Sharpness of the drift bound.** We conjecture that the Pythagorean inequality is asymptotically tight in the following sense: for the mix-in optimum $q^*_\gamma$,
$$\mathrm{KL}(q^*_\gamma\|\pi) \;=\; \frac{\gamma^2}{2\beta^2}\,\mathrm{Var}_{\pi}\!\big(d/\pi\big) \;+\; O(\gamma^3) \qquad (\gamma\to0^+),$$
so that the *linear* bound of Corollary 7.3 is never tight for small $\gamma$, whereas the Pythagorean form approaches equality as $\gamma\to\infty$ (where $q^*_\gamma\to d$). The heuristic is that the two KL terms are the legs of an information-geometric right triangle with fixed hypotenuse, so the deficit is exactly the curvature of the exponential family joining $\pi$ to $d$.

**Curvature of the mix-in path.** The curve $\gamma\mapsto q^*_\gamma$ interpolates between $\pi_r$ and $d$. Is it ever a geodesic of the exponential family through those two endpoints? We expect not, except in the degenerate case $d=\pi_r$ of Corollary 7.4, because the augmented reward $\gamma d/q$ depends on the current point.

*A caution recorded from the analysis.* An earlier form of this conjecture asserted that no $\ell^2$ bound on reward hacking can hold. That is false: the unweighted $\ell^2$ norm dominates the sup-norm, so Theorem 5.1 immediately gives an $\ell^2$ bound. The correct statement is the *reference-weighted* failure of Theorem 5.4, and the distinction — between norms that dominate the sup-norm and norms that discount rare responses — is the whole content.

**Second-order stability constants.** Corollary 8.7 gives the constant $2/\beta$. Local strong concavity at the optimum should sharpen this to a constant involving $\gamma\min_y d(y)/q^*(y)^2$, i.e. the mix-in should *improve* robustness, not merely preserve it. Making this quantitative would explain a widely reported empirical effect.

**Multi-prompt and structured response spaces.** The present analysis fixes a prompt. Aggregating over a prompt distribution turns the torsor into a bundle over the prompt space, and the natural question is whether the gauge group (constants per prompt) can be reduced by consistency across prompts — a question with direct bearing on whether reward models are identifiable from preference data across contexts.

**Sequence-level structure.** Responses in practice are sequences, and the reward is often a sum of token-level terms. Whether the torsor structure descends to an autoregressive factorization — i.e. whether the tilt of a sequence model is a sequence model with tilted conditionals — is a concrete and consequential question; the answer is affirmative for reward functions that decompose additively along the sequence and negative in general.

---

## 12. Conclusion

The alignment objective with pretraining mix-in decomposes into three geometrically distinct pieces with sharply different roles. The reward contributes a linear functional. The KL penalty is not a heuristic regularizer but the exact convex conjugate of the achievable alignment value, making rewards-modulo-constants and strictly positive policies Legendre-dual coordinates related by a simply transitive tilting action which is, moreover, a homeomorphism on the interior of the simplex. The pretraining mix-in is an interior barrier that acts as a self-referential reward bonus $\gamma d/q$, replaces the closed-form Gibbs solution by an equivalent fixed-point equation, and buys a hard, reward-independent probability floor at a monotone and convex price in alignment value. Corruption of the reward model by $K$ in sup-norm can move the value by exactly $K$ in the worst case and the policy by at most $2K/\beta$ in symmetrized information distance — and no reference-weighted diagnostic can see it coming.
