# The Projective Geometry of KL-Regularised Alignment

### Isometry, sharp total-variation contraction, free-energy duality, and the submodular lattice of symbolic constraints

**Author:** Aristotle
**Date:** 2026-08-20

---

## Abstract

We develop a complete metric geometry for the reinforcement-learning-from-human-feedback
(RLHF) objective with a pre-training mix-in,
$$
J_{\beta,\gamma}(p) \;=\; \mathbb{E}_{p}[r] \;-\; \beta\, \mathrm{KL}(p\|\mathrm{ref}) \;+\; \gamma\,\mathbb{E}_{\mathrm{pre}}[\log p],
$$
over policies on a finite output alphabet. Our central structural result is that,
for $\gamma = 0$, the alignment map $r \mapsto \pi_\beta(r)$ carrying a reward
model to its optimal KL-regularised policy is an **exact isometry** from the
space of rewards modulo additive constants, equipped with the oscillation
seminorm $\mathrm{osc}(f) = \max f - \min f$ scaled by $1/\beta$, onto the open
probability simplex equipped with Birkhoff's Hilbert projective metric
$d_H(p,q) = \mathrm{osc}\big(\log(p/q)\big)$:
$$
d_H\big(\pi_\beta(r_1), \pi_\beta(r_2)\big) \;=\; \frac{\mathrm{osc}(r_1-r_2)}{\beta}.
$$
Building on this we prove a **sharp** Hilbert-to-total-variation comparison,
$\|p-q\|_{TV} \le \tanh\!\big(d_H(p,q)/4\big)$, whose extremal structure reduces
to the single square $(vw-1)^2 \ge 0$. Combining the two yields the
misspecification bound
$\|\pi_\beta(r_1)-\pi_\beta(r_2)\|_{TV} \le \tanh\!\big(\mathrm{osc}(r_1-r_2)/4\beta\big) < 1$:
aligned policies for two reward models are never mutually singular, however
badly the reward models disagree. We further establish (i) an envelope/Danskin
duality identifying the aligned policy as the reward-gradient of the free energy
$F(\beta,r) = \beta \log \sum_i \mathrm{ref}_i e^{r_i/\beta}$, together with both
annealing limits *with explicit rates*; (ii) an **exact identity** for the
pre-training mix-in at the optimum, giving a necessary and sufficient criterion
for zero capability regression and a worst-case regression budget of
$\gamma\,\mathrm{osc}(r)/\beta$; (iii) a variational principle for hard symbolic
constraints, the commutation of symbolic filtering with alignment, and the
**monotonicity and submodularity** of the constrained value on the Boolean
lattice of admissible sets; and (iv) an additive **drift budget** for iterated
alignment, with a characterisation of its equality case and an explicit
demonstration of strictness. A $\beta$-independent Goodhart regret bound of
$2\|r-\hat r\|_\infty$ closes the picture.

**Keywords:** RLHF, Hilbert projective metric, Birkhoff contraction, exponential
tilting, free energy, total variation, submodularity, neurosymbolic constraints.

---

## 1. Introduction

### 1.1 The objective

Contemporary alignment of a generative model proceeds in two stages. A
supervised fine-tuned (SFT) model provides a *reference policy*
$\mathrm{ref}$; a learned reward model $r$ scores candidate outputs; and the
policy is then re-optimised for the composite objective

$$
J_{\beta,\gamma}(p) \;=\; \underbrace{\mathbb{E}_{p}[r]}_{\text{reward}} \;-\; \underbrace{\beta\, \mathrm{KL}(p\|\mathrm{ref})}_{\text{trust region}} \;+\; \underbrace{\gamma\,\mathbb{E}_{\mathrm{pre}}[\log p]}_{\text{pre-training mix-in}} .
$$

The KL term is a leash preventing reward hacking and mode collapse; the
mix-in term is a widely used device for preventing regression on general
capabilities. The coefficients $\beta > 0$ and $\gamma \ge 0$ are, in practice,
chosen empirically.

This paper asks what these coefficients *are*, mathematically, and answers with
a metric geometry in which $\beta$ is literally a scale factor.

### 1.2 Contributions

1. **Isometry (Theorem 4.1).** The alignment map is a distance-preserving
   bijection between $(\mathbb{R}^\iota/\mathbb{R}\mathbf{1},\ \mathrm{osc}/\beta)$
   and the open simplex under the Hilbert projective metric.
2. **Sharp contraction (Theorem 5.3).** $\|p-q\|_{TV}\le\tanh(d_H(p,q)/4)$,
   improving the naive $e^{d_H}-1$ to a bound that is always $<1$.
3. **Free-energy duality and annealing (Theorems 6.1, 6.3, 6.4).** Envelope
   theorem, cold limit $F \to \max r$ with rate $\beta\log\min\mathrm{ref}$, hot
   limit $F \to \mathbb{E}_{\mathrm{ref}}[r]$ with rate $\tfrac34 M^2/\beta$.
4. **Exact PTX law (Theorems 7.1–7.3).** An identity for the mix-in term at the
   optimum, an exact no-regression criterion, and a $\gamma\,\mathrm{osc}(r)/\beta$
   budget.
5. **Symbolic constraint lattice (Theorems 8.2–8.6).** Constrained variational
   principle, commutation of filtering and alignment, monotonicity,
   submodularity, and a price bound.
6. **Drift budget (Theorems 9.2–9.4).** Additive accounting for iterated
   alignment, sharp exactly in the absence of cancellation.
7. **Goodhart regret (Theorem 6.6).** Optimising a proxy reward within $M$ of
   the truth costs at most $2M$ of true regularised value, uniformly in $\beta$.

### 1.3 Related ideas

The exponential tilt and its free energy are the classical Gibbs variational
principle. The Hilbert projective metric and the associated contraction
constant $\tanh(d/4)$ originate in Birkhoff's work on positive operators, where
they are used to prove Perron–Frobenius-type theorems; the novelty here is not
the metric but its identification as *the* natural metric on the space of
aligned policies, in which alignment is an isometry with scale $1/\beta$, and the
consequences this identification has for misspecification, drift accounting,
and capability regression.

---

## 2. Setting and notation

Throughout, $\iota$ is a **finite, non-empty** set of outputs (responses to a
fixed prompt; all statements are pointwise in the prompt and can be averaged
over prompts afterwards).

**Definition 2.1 (Policies).** A *policy* is a vector $p \in \mathbb{R}^\iota$
with $p_i \ge 0$ and $\sum_i p_i = 1$. It is *strictly positive* if $p_i > 0$
for all $i$. We write $\Delta^\circ$ for the set of strictly positive policies.

**Definition 2.2 (Reference and reward).** The reference (SFT) policy
$\mathrm{ref} \in \Delta^\circ$ is fixed. A *reward model* is an arbitrary
function $r : \iota \to \mathbb{R}$. The *pre-training distribution*
$\mathrm{pre}$ is a policy (not necessarily strictly positive).

**Definition 2.3 (Relative entropy).** For a policy $p$ and $q\in\Delta^\circ$,
$\mathrm{KL}(p\|q) = \sum_i p_i \log (p_i/q_i)$, with $0\log 0 = 0$.

**Definition 2.4 (Objective).** For $\beta > 0$,
$$
J_\beta(p) \;=\; \sum_i p_i r_i \;-\; \beta\,\mathrm{KL}(p\|\mathrm{ref}),
\qquad
\mathrm{PTX}_\gamma(p) \;=\; \gamma \sum_i \mathrm{pre}_i \log p_i ,
$$
and the full objective is $J_{\beta,\gamma} = J_\beta + \mathrm{PTX}_\gamma$.

**Definition 2.5 (Partition function, tilt, free energy).**
$$
Z_\beta(r) \;=\; \sum_i \mathrm{ref}_i\, e^{r_i/\beta}, \qquad
\pi_\beta(r)_i \;=\; \frac{\mathrm{ref}_i\, e^{r_i/\beta}}{Z_\beta(r)}, \qquad
F(\beta,r) \;=\; \beta \log Z_\beta(r).
$$
$Z_\beta(r) > 0$ always, so $\pi_\beta(r) \in \Delta^\circ$ is well defined.

**Proposition 2.6 (Gibbs variational principle).** For every policy $p$,
$J_\beta(p) \le F(\beta, r)$, with equality if and only if $p = \pi_\beta(r)$.

*Proof sketch.* Write
$J_\beta(p) = F(\beta,r) - \beta\,\mathrm{KL}\big(p\,\|\,\pi_\beta(r)\big)$ by
substituting the definition of $\pi_\beta(r)$ into the relative entropy, and
apply non-negativity of relative entropy with its equality case. $\square$

Thus for $\gamma = 0$ the aligned policy is the exponential tilt and the optimal
value is the free energy. All later sections analyse these two objects.

---

## 3. Two metrics on rewards and policies

### 3.1 The oscillation seminorm

Since $\pi_\beta(r + c\mathbf{1}) = \pi_\beta(r)$ for every constant $c$, reward
models matter only modulo constants, and the correct norm on
$\mathbb{R}^\iota/\mathbb{R}\mathbf{1}$ is the spread.

**Definition 3.1.** $\displaystyle \mathrm{osc}(f) \;=\; \max_{i} f_i \;-\; \min_i f_i .$

**Proposition 3.2 (Seminorm axioms).** For all $f,g:\iota\to\mathbb{R}$, all
$c \in \mathbb{R}$ and all $\lambda > 0$:
(i) $\mathrm{osc}(f)\ge 0$, and $f_i - f_j \le \mathrm{osc}(f)$ for all $i,j$;
(ii) $\mathrm{osc}(f + c\mathbf{1}) = \mathrm{osc}(f)$;
(iii) $\mathrm{osc}(\lambda f) = \lambda\,\mathrm{osc}(f)$;
(iv) $\mathrm{osc}(f+g) \le \mathrm{osc}(f)+\mathrm{osc}(g)$;
(v) $\mathrm{osc}(-f) = \mathrm{osc}(f)$;
(vi) if $|f_i| \le M$ for all $i$ then $\mathrm{osc}(f) \le 2M$;
(vii) $\mathrm{osc}(f) = 0$ iff $f$ is constant.

*Proof sketch.* All are immediate from $\max$ and $\min$ manipulations; (iv)
uses $\max(f+g)\le \max f + \max g$ and $\min(f+g) \ge \min f + \min g$; (v)
uses $\max(-f) = -\min f$; (iii) uses positivity of $\lambda$ to commute scaling
past $\max$ and $\min$. $\square$

By induction, (iv) extends to finite families:
$\mathrm{osc}\big(\sum_{k<n} f^{(k)}\big) \le \sum_{k<n}\mathrm{osc}(f^{(k)})$,
which is the engine of the drift budget in Section 9.

### 3.2 The Hilbert projective metric

**Definition 3.3.** For strictly positive $p,q$,
$$
d_H(p,q) \;=\; \mathrm{osc}\!\left(\log \frac{p}{q}\right)
\;=\; \max_i \log\frac{p_i}{q_i} \;-\; \min_i \log\frac{p_i}{q_i}.
$$

**Proposition 3.4 (Pseudometric axioms).** On $\Delta^\circ$, $d_H \ge 0$,
$d_H(p,p)=0$, $d_H(p,q) = d_H(q,p)$, and
$d_H(p,q) \le d_H(p,t) + d_H(t,q)$.

*Proof sketch.* Symmetry is Proposition 3.2(v) applied to
$\log(p/q) = -\log(q/p)$; the triangle inequality is subadditivity (3.2(iv))
applied to $\log(p/q) = \log(p/t) + \log(t/q)$. $\square$

On $\Delta^\circ$, $d_H(p,q) = 0$ forces $\log(p/q)$ constant, hence $p = q$
after normalisation, so $d_H$ is in fact a metric there.

**Definition 3.5 (Total variation).**
$\displaystyle \|p - q\|_{TV} \;=\; \tfrac12 \sum_i |p_i - q_i| \;=\; \max_{A\subseteq\iota} \big(p(A) - q(A)\big).$

---

## 4. Alignment is an isometry

**Lemma 4.0 (Log-ratio of tilts).** For all $r_1,r_2$ and all $i$,
$$
\log\frac{\pi_\beta(r_1)_i}{\pi_\beta(r_2)_i}
\;=\; \frac{r_{1,i}-r_{2,i}}{\beta} \;+\; \log\frac{Z_\beta(r_2)}{Z_\beta(r_1)} .
$$

*Proof sketch.* The reference factor $\mathrm{ref}_i$ cancels; the exponential
factors combine to $e^{(r_{1,i}-r_{2,i})/\beta}$; the partition functions
contribute the $i$-independent term. $\square$

**Theorem 4.1 (Exact isometry).** For every $\beta>0$, every
$\mathrm{ref}\in\Delta^\circ$, and all reward models $r_1, r_2$,
$$
\boxed{\;d_H\big(\pi_\beta(r_1),\pi_\beta(r_2)\big) \;=\; \frac{\mathrm{osc}(r_1-r_2)}{\beta}. \;}
$$

*Proof sketch.* By Lemma 4.0 the log-ratio function equals
$\beta^{-1}(r_1-r_2)$ plus a constant. Oscillation ignores constants
(Prop. 3.2(ii)) and is positively homogeneous (3.2(iii)), so the oscillation of
the log-ratio is $\mathrm{osc}(r_1-r_2)/\beta$. $\square$

**Corollary 4.2 (Displacement from the reference).**
$d_H(\pi_\beta(r), \mathrm{ref}) = \mathrm{osc}(r)/\beta$.

*Proof sketch.* Take $r_2 = 0$ and note $\pi_\beta(0) = \mathrm{ref}$. $\square$

**Corollary 4.3 (Kernel of alignment).** $\pi_\beta(r_1) = \pi_\beta(r_2)$ if
and only if $\mathrm{osc}(r_1-r_2)=0$, i.e. iff $r_1 - r_2$ is constant.

Theorem 4.1 upgrades a purely algebraic fact — that tilting is a transitive,
free action of $\mathbb{R}^\iota/\mathbb{R}\mathbf{1}$ on $\Delta^\circ$, i.e. a
torsor structure — to a metric one: the action is by isometries, with scale
$1/\beta$. Interpretively, $\beta$ is the exchange rate between reward spread
and policy displacement, and the equality means a drift target can be converted
into a KL coefficient with no slack.

---

## 5. From Hilbert distance to total variation: the sharp constant

### 5.1 The naive bound and why it fails

If $d_H(p,q) = d$, then for all $i$, $p_i \le e^{d} q_i$ (indeed
$p_i/q_i \le e^{d}\,\min_j p_j/q_j \le e^d$ using $\sum p = \sum q = 1$), whence
$$
\|p-q\|_{TV} \;\le\; e^{d} - 1 . \tag{5.1}
$$
This is vacuous for $d > \log 2$, since TV never exceeds $1$. The defect is
diagnosable: (5.1) uses only the *upper* ratio bound $p \le u q$ and discards
the *lower* bound $vq \le p$.

### 5.2 The two-constraint optimisation

**Lemma 5.2 (Birkhoff two-constraint bound).** Let $v \le 1$, $w \ge 1$,
$x \ge 0$ and suppose
$$
t \;\le\; (v w^2 - 1)\,x, \qquad t \;\le\; (1-v)(1-x).
$$
Then $\displaystyle t \le \frac{w-1}{w+1}$.

*Proof sketch.* If $vw^2 \le 1$ the first constraint gives $t \le 0 \le (w-1)/(w+1)$.
Otherwise both $1-v \ge 0$ and $vw^2-1 > 0$, and forming the positive
combination $(1-v)\cdot(\text{first}) + (vw^2-1)\cdot(\text{second})$ eliminates
$x$ and yields
$$
t\,\big[(1-v)+(vw^2-1)\big] \;\le\; (vw^2-1)(1-v).
$$
The bracket is $v(w^2-1) = v(w-1)(w+1)$. For the numerator, observe the exact
identity
$$
v(w-1)^2 \;-\; (vw^2-1)(1-v) \;=\; (vw-1)^2 \;\ge\; 0,
$$
so $(vw^2-1)(1-v) \le v(w-1)^2$. Note $vw^2>1$ and $v\le 1$ force $w>1$, so the
bracket is strictly positive and we may divide:
$$
t \;\le\; \frac{v(w-1)^2}{v(w-1)(w+1)} \;=\; \frac{w-1}{w+1}. \qquad \square
$$

The whole constant of the theory is the perfect square $(vw-1)^2$.

**Theorem 5.3 (Sharp Hilbert–TV comparison).** For $p,q \in \Delta^\circ$ with
$d = d_H(p,q)$,
$$
\boxed{\;\|p-q\|_{TV} \;\le\; \frac{e^{d/2}-1}{e^{d/2}+1} \;=\; \tanh\!\Big(\frac{d}{4}\Big).\;}
$$

*Proof sketch.* Put $L_i = \log(p_i/q_i)$, $S = \max_i L_i$, $I = \min_i L_i$,
so $d = S - I$; set $u = e^{S}$, $v = e^{I}$, $w = e^{d/2}$, so that
$u = v w^2$ and $w \ge 1$. Since $p$ and $q$ are both probability vectors, there
is an index $j$ with $p_j \le q_j$, hence $I \le 0$ and $v \le 1$. Pointwise,
$$
v\,q_i \;\le\; p_i \;\le\; u\,q_i \qquad (i \in \iota).
$$
Let $A = \{i : q_i \le p_i\}$, $a = p(A)$, $x = q(A)$. Then
$\|p-q\|_{TV} = a - x$ (the positive part of $p-q$ is concentrated on $A$ and
$\sum_i (p_i-q_i)=0$). Summing the upper ratio bound over $A$ gives $a \le u x$,
i.e. $a - x \le (vw^2-1)x$; summing the lower bound over the complement gives
$v(1-x) \le 1-a$, i.e. $a - x \le (1-v)(1-x)$. Also $x \ge 0$. Lemma 5.2 with
$t = a-x$ delivers $\|p-q\|_{TV} \le (w-1)/(w+1) = \tanh(d/4)$. $\square$

**Theorem 5.4 (Reward-model misspecification, sharp form).** For all $r_1,r_2$,
$$
\big\|\pi_\beta(r_1)-\pi_\beta(r_2)\big\|_{TV} \;\le\; \tanh\!\left(\frac{\mathrm{osc}(r_1-r_2)}{4\beta}\right)
\;=\; \frac{e^{\mathrm{osc}(r_1-r_2)/2\beta}-1}{e^{\mathrm{osc}(r_1-r_2)/2\beta}+1}.
$$

*Proof sketch.* Compose Theorem 4.1 with Theorem 5.3. $\square$

**Proposition 5.4b (Sharpness).** The constant $\tanh(d/4)$ cannot be improved.
For every $d > 0$, set $\theta = e^{d/2}$ and take the two-point pair
$$
p \;=\; \left(\frac{\theta}{1+\theta},\ \frac{1}{1+\theta}\right), \qquad
q \;=\; \left(\frac{1}{1+\theta},\ \frac{\theta}{1+\theta}\right).
$$
The two likelihood ratios are $\theta$ and $\theta^{-1}$, so
$$
d_H(p,q) \;=\; 2\log\theta \;=\; d, \qquad
\|p-q\|_{TV} \;=\; \frac{\theta-1}{\theta+1} \;=\; \tanh\!\Big(\frac{d}{4}\Big).
$$
The extremal configuration satisfies $vw = 1$ in the notation of Lemma 5.2,
precisely the equality case of the square $(vw-1)^2 \ge 0$. Since any two
strictly positive policies are tilts of any strictly positive reference (take
$r_1 = \beta\log p$, $r_2 = \beta \log q$, up to constants), the bound of
Theorem 5.4 is attained as well.

*Proof sketch.* Maximise $a - x$ over two-point pairs with fixed odds ratio
$e^{d} = \frac{a(1-x)}{x(1-a)}$. Writing $u = x/(1-x)$ so that
$a = \frac{e^{d}u}{1+e^{d}u}$, the objective
$\frac{e^d u}{1+e^d u} - \frac{u}{1+u}$ is maximised at $u = e^{-d/2}$, giving
the stated pair and value. $\square$

**Corollary 5.5 (No mutual singularity).**
$\|\pi_\beta(r_1)-\pi_\beta(r_2)\|_{TV} < 1$ always.

*Proof sketch.* $(E-1)/(E+1) < 1$ for every $E > 0$. $\square$

Corollary 5.5 is a *qualitative* statement with no small-$\varepsilon$
hypothesis: KL-regularised policies produced from a common strictly positive
reference always overlap, whatever the reward models. Quantitatively,
$\tanh(\varepsilon/4\beta) \approx \varepsilon/(4\beta)$ for small
$\varepsilon/\beta$, so in the practically relevant regime the misspecification
sensitivity is linear in reward error with slope $1/(4\beta)$.

---

## 6. Free-energy duality, annealing, and Goodhart regret

### 6.1 The envelope theorem

**Theorem 6.1 (Danskin/envelope duality).** For $\beta>0$,
$\mathrm{ref}\in\Delta^\circ$ and any $r, s : \iota \to \mathbb{R}$, the map
$t \mapsto F(\beta, r + ts)$ is differentiable at $t=0$ with
$$
\left.\frac{d}{dt}\right|_{t=0} F(\beta, r+ts) \;=\; \sum_i \pi_\beta(r)_i\, s_i \;=\; \mathbb{E}_{\pi_\beta(r)}[s].
$$

*Proof sketch.* Differentiate $Z_\beta(r+ts) = \sum_i \mathrm{ref}_i e^{(r_i+ts_i)/\beta}$
term by term to get $\sum_i \mathrm{ref}_i e^{r_i/\beta} s_i/\beta$ at $t=0$;
then $\frac{d}{dt}\beta\log Z = \beta \dot Z / Z = \sum_i \pi_\beta(r)_i s_i$.
$\square$

The aligned policy is thus the reward-gradient of the alignment value: an
envelope theorem stating that the optimiser's own variation contributes nothing
at the optimum.

**Proposition 6.2 (Elementary properties of $F$).** For $\beta>0$:
(i) $F(\beta, r + c\mathbf{1}) = F(\beta,r)+c$;
(ii) $r_1 \le r_2$ pointwise implies $F(\beta,r_1)\le F(\beta,r_2)$;
(iii) if $|r_{1,i}-r_{2,i}|\le M$ for all $i$ then $F(\beta,r_1)-F(\beta,r_2)\le M$
(so $F$ is $1$-Lipschitz in the supremum norm);
(iv) $\mathbb{E}_{\mathrm{ref}}[r] \le F(\beta,r)$.

*Proof sketch.* (i) The shift multiplies $Z$ by $e^{c/\beta}$. (ii) $Z$ is
monotone in $r$ and $\log$ is monotone. (iii) Apply (ii) to $r_1 \le r_2 + M$
and then (i). (iv) Jensen's inequality applied to $\log$, or Prop. 2.6 with
$p=\mathrm{ref}$. $\square$

### 6.2 Annealing limits with rates

**Theorem 6.3 (Cold limit; reward maximisation).** For $\beta > 0$,
$$
\max_i r_i \;+\; \beta \log\Big(\min_i \mathrm{ref}_i\Big) \;\le\; F(\beta,r) \;\le\; \max_i r_i,
$$
and consequently $F(\beta,r) \to \max_i r_i$ as $\beta \to 0^+$.

*Proof sketch.* Upper: every term satisfies
$\mathrm{ref}_i e^{r_i/\beta} \le \mathrm{ref}_i e^{\max r/\beta}$, so
$Z \le e^{\max r/\beta}$. Lower: keep the single maximising term,
$Z \ge (\min_j \mathrm{ref}_j)\,e^{\max r/\beta}$. Take $\beta\log$ of both and
squeeze. $\square$

This is exactly policy collapse: as the leash shortens, the optimum concentrates
on the argmax of the reward, and the deficit is at most
$\beta|\log \min_i \mathrm{ref}_i|$.

**Theorem 6.4 (Hot limit; return to the reference).** Suppose $|r_i| \le M$ for
all $i$, with $M > 0$, and $\beta \ge M$. Then
$$
0 \;\le\; F(\beta,r) \;-\; \mathbb{E}_{\mathrm{ref}}[r] \;\le\; \frac{3}{4}\,\frac{M^2}{\beta},
$$
hence $F(\beta,r) \to \mathbb{E}_{\mathrm{ref}}[r]$ as $\beta \to \infty$.

*Proof sketch.* The left inequality is Prop. 6.2(iv). For the right, on
$|u|\le 1$ Taylor's theorem gives $e^u \le 1 + u + \tfrac34 u^2$; applying this
with $u = r_i/\beta$ (legitimate since $\beta \ge M \ge |r_i|$) and summing
against $\mathrm{ref}$ yields
$Z \le 1 + \mathbb{E}_{\mathrm{ref}}[r]/\beta + \tfrac34 M^2/\beta^2$. Then use
$\log Z \le Z - 1$ and multiply by $\beta$. $\square$

### 6.3 Goodhart regret

**Theorem 6.6 (Proxy-reward regret).** Let $\hat r$ satisfy
$|r_i - \hat r_i| \le M$ for all $i$. Then the *true* regularised value of the
policy obtained by optimising the proxy satisfies
$$
F(\beta,r) \;-\; J_\beta\big(\pi_\beta(\hat r)\big) \;\le\; 2M ,
$$
where $J_\beta$ uses the true reward $r$. The bound is independent of $\beta$.

*Proof sketch.* Write $q = \pi_\beta(\hat r)$. By Prop. 2.6 applied to $\hat r$,
the proxy objective at $q$ equals $F(\beta,\hat r)$. Replacing $\hat r$ by $r$
inside the expectation changes the objective by at most
$\sum_i q_i |r_i - \hat r_i| \le M$. Finally
$F(\beta,r) - F(\beta,\hat r) \le M$ by Prop. 6.2(iii). Adding the two losses
gives $2M$. $\square$

Note the contrast with Theorem 5.4: reward misspecification changes the *policy*
by an amount that shrinks like $1/\beta$, but costs *value* at most $2M$
uniformly in $\beta$. Strong regularisation buys policy stability, not extra
value robustness — the value robustness was there all along.

---

## 7. The pre-training mix-in, exactly

Let $\mathrm{pre}$ be the pre-training distribution and recall
$\mathrm{PTX}_\gamma(p) = \gamma\sum_i \mathrm{pre}_i \log p_i$.

**Theorem 7.1 (Exact PTX identity).** For $\beta>0$,
$\mathrm{ref}\in\Delta^\circ$, and any policy $\mathrm{pre}$,
$$
\boxed{\;\sum_i \mathrm{pre}_i \log \pi_\beta(r)_i \;=\; \sum_i \mathrm{pre}_i \log \mathrm{ref}_i \;+\; \frac{\mathbb{E}_{\mathrm{pre}}[r] \;-\; F(\beta,r)}{\beta}.\;}
$$

*Proof sketch.* Pointwise,
$\log\pi_\beta(r)_i = \log\mathrm{ref}_i + r_i/\beta - \log Z_\beta(r)$. Average
against $\mathrm{pre}$, using $\sum_i \mathrm{pre}_i = 1$ to handle the constant
term, and substitute $\log Z_\beta(r) = F(\beta,r)/\beta$. $\square$

The identity says that the entire effect of alignment on the pre-training
objective is a single scalar: the gap between the pre-training data's mean
reward and the free-energy level, divided by $\beta$.

**Theorem 7.2 (Exact no-regression criterion).** For $\beta>0$ and $\gamma>0$,
$$
\mathrm{PTX}_\gamma(\mathrm{ref}) \;\le\; \mathrm{PTX}_\gamma\big(\pi_\beta(r)\big)
\quad\Longleftrightarrow\quad
F(\beta,r) \;\le\; \mathbb{E}_{\mathrm{pre}}[r].
$$

*Proof sketch.* By Theorem 7.1 the difference of the two mix-in terms is
$\gamma\big(\mathbb{E}_{\mathrm{pre}}[r]-F(\beta,r)\big)/\beta$; with
$\gamma,\beta>0$ its sign is the sign of $\mathbb{E}_{\mathrm{pre}}[r]-F(\beta,r)$.
$\square$

Capability regression is therefore not mysterious forgetting: it occurs exactly
when ordinary pre-training text scores, on average, *below* the free-energy
level to which the reward has pushed the policy. Since $F(\beta,r)\to\max_i r_i$
as $\beta\to 0$ (Theorem 6.3), aggressive alignment makes the criterion harder
to satisfy — a precise version of the folklore that small $\beta$ causes
regression.

**Theorem 7.3 (Regression budget).** For $\beta>0$, $\gamma\ge0$,
$$
\mathrm{PTX}_\gamma(\mathrm{ref}) \;-\; \mathrm{PTX}_\gamma\big(\pi_\beta(r)\big) \;\le\; \frac{\gamma\,\mathrm{osc}(r)}{\beta}.
$$

*Proof sketch.* By Theorems 6.3 and Prop. 3.2, $F(\beta,r)\le \max_i r_i$ and
$\mathbb{E}_{\mathrm{pre}}[r]\ge\min_i r_i$, so
$F(\beta,r)-\mathbb{E}_{\mathrm{pre}}[r]\le \mathrm{osc}(r)$; insert into the
identity of Theorem 7.1 and multiply by $\gamma/\beta \ge 0$. $\square$

The regression budget carries the same $\mathrm{osc}(r)/\beta$ that measures
geometric drift (Corollary 4.2): *capability regression and policy drift are the
same quantity in different units*, related by the factor $\gamma$.

---

## 8. Hard symbolic constraints: a submodular lattice

A neurosymbolic pipeline augments the learned reward with a *hard* logical
filter: a rule set declares an admissible subset $S \subseteq \iota$ and forbids
everything else.

**Definition 8.1 (Constrained objects).** For $\emptyset \ne S \subseteq \iota$,
$$
Z_S(\beta,r) = \sum_{i\in S}\mathrm{ref}_i e^{r_i/\beta}, \qquad
F_S(\beta,r) = \beta\log Z_S(\beta,r), \qquad
\pi_\beta^S(r)_i = \begin{cases} \dfrac{\mathrm{ref}_i e^{r_i/\beta}}{Z_S(\beta,r)}, & i \in S,\\[4pt] 0, & i \notin S.\end{cases}
$$

**Theorem 8.2 (Constrained variational principle).** For every policy $p$
supported in $S$, $J_\beta(p) \le F_S(\beta,r)$, and the bound is attained:
$J_\beta\big(\pi_\beta^S(r)\big) = F_S(\beta,r)$.

*Proof sketch.* Restricting all sums to $S$, the same completion-of-the-square
as in Prop. 2.6 gives
$J_\beta(p) = F_S(\beta,r) - \beta\,\mathrm{KL}\big(p\,\|\,\pi_\beta^S(r)\big)$;
non-negativity of relative entropy on $S$ gives the inequality, and $p =
\pi_\beta^S(r)$ gives equality. $\square$

**Theorem 8.3 (Filtering commutes with alignment).** For every $i \in S$,
$$
\pi_\beta^S(r)_i \;=\; \frac{\pi_\beta(r)_i}{\sum_{j\in S}\pi_\beta(r)_j}.
$$

*Proof sketch.* Both sides equal $\mathrm{ref}_i e^{r_i/\beta}/Z_S$ after
clearing the common factor $Z_\beta(r)$. $\square$

So one may align first and then apply the symbolic filter, or apply the filter
and then align inside it; the results agree exactly. This is a genuine
architectural licence for neurosymbolic systems: the order of the symbolic and
neural stages is immaterial at the optimum.

**Theorem 8.4 (Monotonicity).** If $\emptyset \ne S \subseteq T$, then
$F_S(\beta,r) \le F_T(\beta,r)$.

*Proof sketch.* $Z_S \le Z_T$ since all summands are positive; apply
$\beta\log(\cdot)$. $\square$

**Theorem 8.5 (Submodularity — diminishing returns).** For $S,T$ with
$S\cap T \ne \emptyset$,
$$
F_{S\cup T}(\beta,r) \;+\; F_{S\cap T}(\beta,r) \;\le\; F_S(\beta,r) \;+\; F_T(\beta,r).
$$

*Proof sketch.* The partition function is **modular**:
$Z_{S\cup T} + Z_{S\cap T} = Z_S + Z_T$ (inclusion–exclusion for sums). Also
$Z_{S\cap T} \le \min(Z_S, Z_T)$. Substituting
$Z_{S\cup T} = Z_S + Z_T - Z_{S\cap T}$ gives the exact factorisation
$$Z_S Z_T - Z_{S\cup T} Z_{S \cap T} \;=\; (Z_S - Z_{S\cap T})(Z_T - Z_{S\cap T}) \;\ge\; 0 .$$
Taking logarithms and multiplying by $\beta>0$ gives the claim. $\square$

Submodularity is the mathematical content of the informal claim that symbolic
rules have diminishing returns: relaxing one rule gains least when other rules
are already relaxed. Operationally, it is what makes greedy selection of a rule
set a principled procedure, since greedy maximisation of a monotone submodular
set function under a cardinality constraint enjoys the classical $1-1/e$
guarantee.

**Theorem 8.6 (Price of a rule set).** For $\emptyset \ne S \subseteq \iota$,
$$
F(\beta,r) \;-\; F_S(\beta,r) \;\le\; \mathrm{osc}(r) \;-\; \beta \log \mathrm{ref}(S),
\qquad \mathrm{ref}(S) = \sum_{i\in S}\mathrm{ref}_i .
$$

*Proof sketch.* Upper-bound the unconstrained value by $\max_i r_i$
(Theorem 6.3). Lower-bound the constrained one by replacing every $r_i$,
$i\in S$, with $\min_j r_j$: this gives
$Z_S \ge \mathrm{ref}(S)\,e^{\min r/\beta}$, hence
$F_S \ge \beta\log\mathrm{ref}(S) + \min_j r_j$. Subtract. $\square$

With $S = \iota$ the bound degenerates to $\mathrm{osc}(r)$; as the rules prune
more reference mass the price grows only logarithmically in the surviving mass,
weighted by $\beta$.

---

## 9. Iterated alignment and the drift budget

Real pipelines run alignment repeatedly, accumulating rewards
$r^{(0)}, r^{(1)}, \dots$. Because tilting is additive in the reward, the state
after $n$ rounds is $\pi_n = \pi_\beta\big(\sum_{k<n} r^{(k)}\big)$.

**Theorem 9.1 (One round is a translation).** For any accumulated reward $r$
and any new reward $s$,
$$
d_H\big(\pi_\beta(r+s),\, \pi_\beta(r)\big) \;=\; \frac{\mathrm{osc}(s)}{\beta},
$$
independently of $r$.

*Proof sketch.* Theorem 4.1 with $r_1 = r+s$, $r_2 = r$. $\square$

**Theorem 9.2 (Drift budget).** For any rewards $r^{(0)},\dots,r^{(n-1)}$,
$$
d_H(\pi_n, \mathrm{ref}) \;\le\; \frac{1}{\beta}\sum_{k=0}^{n-1}\mathrm{osc}\big(r^{(k)}\big),
$$
and therefore
$\|\pi_n - \mathrm{ref}\|_{TV} \le \tanh\Big(\frac{1}{4\beta}\sum_{k<n}\mathrm{osc}(r^{(k)})\Big)$.

*Proof sketch.* Corollary 4.2 gives
$d_H(\pi_n,\mathrm{ref}) = \mathrm{osc}\big(\sum_{k<n} r^{(k)}\big)/\beta$;
finite subadditivity of $\mathrm{osc}$ (Prop. 3.2(iv), by induction on $n$)
bounds the numerator. The TV form follows from Theorem 5.3. $\square$

**Theorem 9.3 (Equality case).** The budget is attained with equality precisely
when the oscillation is additive along the round sequence:
$\mathrm{osc}\big(\sum_{k<n}r^{(k)}\big) = \sum_{k<n}\mathrm{osc}(r^{(k)})$ —
that is, when successive rounds "pull in the same direction", sharing a common
argmax and a common argmin.

*Proof sketch.* Immediate from the equality in Corollary 4.2. $\square$

**Theorem 9.4 (Strictness in general).** For any $s$ with $\mathrm{osc}(s)>0$,
the two-round sequence $(s, -s)$ satisfies
$d_H(\pi_2,\mathrm{ref}) = 0$ while the budget
$\big(\mathrm{osc}(s)+\mathrm{osc}(-s)\big)/\beta = 2\,\mathrm{osc}(s)/\beta$ is
strictly positive.

*Proof sketch.* $s + (-s) = 0$ and $\pi_\beta(0) = \mathrm{ref}$; use
$\mathrm{osc}(-s)=\mathrm{osc}(s)$ (Prop. 3.2(v)). $\square$

Hence no drift-accounting scheme that inspects rounds individually can improve
on Theorem 9.2: the bound is exactly the best round-wise certificate, and
tightening it requires joint information about the rewards.

---

## 10. Algorithms

The theory is constructive and yields three small routines of independent
practical use.

**Algorithm A (Calibrating $\beta$ from a drift target).** Given a reward model
$r$ and a target Hilbert displacement $\delta$, Corollary 4.2 gives, with no
approximation,
$$
\beta^\star \;=\; \frac{\mathrm{osc}(r)}{\delta}.
$$
If instead the target is a total-variation budget $\tau \in (0,1)$, invert the
sharp bound of Theorem 5.4:
$\beta^\star = \mathrm{osc}(r)\big/\big(4\,\mathrm{artanh}\,\tau\big)$; this is
conservative (it certifies $\|\pi_\beta(r)-\mathrm{ref}\|_{TV}\le\tau$).
Complexity $O(|\iota|)$.

**Algorithm B (Greedy symbolic rule relaxation).** Given a budget of $m$ rules
to relax, exploit monotonicity and submodularity (Theorems 8.4, 8.5) to select
relaxations greedily by marginal gain in $F_S$. Each evaluation of $F_S$ costs
$O(|S|)$, so a greedy pass over $K$ candidate rules costs $O(mK|\iota|)$, and the
classical guarantee for monotone submodular maximisation applies.

**Algorithm C (Drift ledger for iterated alignment).** Maintain the running sum
$B_n = \beta^{-1}\sum_{k<n}\mathrm{osc}(r^{(k)})$ and the exact displacement
$D_n = \beta^{-1}\mathrm{osc}\big(\sum_{k<n}r^{(k)}\big)$. Then $D_n \le B_n$
always (Theorem 9.2), $D_n$ is the true drift, and the gap $B_n - D_n$ measures
inter-round cancellation. Cost $O(|\iota|)$ per round.

---

## 11. Discussion

**What $\beta$ is.** Theorem 4.1 replaces the intuition "$\beta$ controls how
far the policy may move" with an equality: the policy moves *exactly*
$\mathrm{osc}(r)/\beta$ in the Hilbert projective metric. Every downstream
statement inherits this scale — the misspecification bound
$\tanh(\mathrm{osc}(r_1-r_2)/4\beta)$, the regression budget
$\gamma\,\mathrm{osc}(r)/\beta$, and the drift ledger — so a single geometric
quantity organises phenomena that are usually discussed separately.

**Why $\tanh$, and why it matters.** The naive comparison $e^{d}-1$ is not merely
loose; it is qualitatively wrong, suggesting that large reward disagreement can
drive policies to mutual singularity. Theorem 5.3 shows the truth is the
opposite: total variation saturates strictly below $1$. In practice this means
that an aligned policy always retains support overlap with every other aligned
policy from the same reference — relevant for importance sampling between
alignment runs, for off-policy evaluation, and for the feasibility of comparing
two aligned checkpoints by reweighting.

**Regression as a level comparison.** The exact PTX identity (Theorem 7.1)
converts a heuristic ("mix in pre-training loss") into a testable criterion
(Theorem 7.2): compute the mean reward of pre-training data and compare it with
the free-energy level. Both quantities are directly estimable from samples.

**Limitations.** The framework is finite and per-prompt: $\iota$ is a finite
output set, and the results are stated for a fixed prompt (prompt-level averages
follow by integrating the bounds). Strict positivity of the reference is
essential — it is exactly what makes the Hilbert metric finite, and a reference
that assigns zero probability to an output makes $d_H$ infinite, which correctly
reflects that no amount of KL-regularised tilting can resurrect an impossible
output. The analysis is about *optima*, not about the optimisation dynamics of
policy-gradient methods; Theorem 6.1 is the bridge, since it says the gradient
signal at the optimum is exactly the aligned policy's expectation.

**An honest negative result.** One naturally hopes for a closed-form optimum of
the full objective with $\gamma>0$. There is none of the exponential-tilt form:
the stationarity condition for $J_{\beta,\gamma}$ mixes $\log p$ with
$\mathrm{pre}/p$, so the optimum is characterised as a fixed point rather than
as a Gibbs measure. This is a "needs a different object" obstruction, not a
false statement, and it is why Sections 4–6 are stated for $\gamma=0$ while
Section 7 evaluates the mix-in *at* the $\gamma=0$ optimum.

---

## 12. Future work

Several questions are immediate and falsifiable within the same finite
framework.

*Ensembles.* Averaging $m$ reward models should contract alignment disagreement
strictly: for rewards $r_1,\dots,r_m$ with mean $\bar r$, one expects
$$
\max_k d_H\big(\pi_\beta(\bar r), \pi_\beta(r_k)\big) \;\le\; \Big(1-\tfrac1m\Big)\max_{k,l} d_H\big(\pi_\beta(r_k),\pi_\beta(r_l)\big),
$$
with equality only when all rewards agree modulo constants. By Theorem 4.1 this
is a purely finite-dimensional statement about the oscillation seminorm on
$\mathbb{R}^\iota/\mathbb{R}\mathbf{1}$ — a convexity statement about a quotient
norm, with no probability in it.

*Fixed-point theory for $\gamma>0$.* Characterise the optimum of the full
objective as the unique fixed point of an explicit map, and bound its distance
from $\pi_\beta(r)$ in the Hilbert metric as a function of $\gamma$.

*Contraction of the alignment iteration.* Interpret repeated
reward-modelling-plus-alignment as an operator on $\Delta^\circ$ and ask when it
is a Birkhoff contraction, which would give convergence of an alignment
pipeline to a unique aligned fixed point.

*Continuous output spaces.* Replace $\iota$ by a compact space and
$\max/\min$ by essential supremum/infimum; every proof here is finite only in
its use of $\max$ and $\min$, so the extension should be routine but deserves
care where strict positivity is used.

---

## 13. Summary of results

| Result | Statement |
|---|---|
| Isometry | $d_H(\pi_\beta(r_1),\pi_\beta(r_2)) = \mathrm{osc}(r_1-r_2)/\beta$ |
| Displacement | $d_H(\pi_\beta(r),\mathrm{ref}) = \mathrm{osc}(r)/\beta$ |
| Sharp comparison | $\|p-q\|_{TV}\le\tanh(d_H(p,q)/4)$ |
| Misspecification | $\|\pi_\beta(r_1)-\pi_\beta(r_2)\|_{TV}\le\tanh(\mathrm{osc}(r_1-r_2)/4\beta)<1$ |
| Envelope | $\partial_t F(\beta,r+ts)|_{0}=\mathbb{E}_{\pi_\beta(r)}[s]$ |
| Cold limit | $\max r + \beta\log\min\mathrm{ref}\le F\le\max r$ |
| Hot limit | $0\le F-\mathbb{E}_{\mathrm{ref}}[r]\le \tfrac34 M^2/\beta$ for $\beta\ge M\ge\|r\|_\infty$ |
| Goodhart | $F(\beta,r)-J_\beta(\pi_\beta(\hat r))\le 2\|r-\hat r\|_\infty$ |
| PTX identity | $\mathbb{E}_{\mathrm{pre}}[\log\pi_\beta(r)]=\mathbb{E}_{\mathrm{pre}}[\log\mathrm{ref}]+(\mathbb{E}_{\mathrm{pre}}[r]-F)/\beta$ |
| No regression | iff $F(\beta,r)\le\mathbb{E}_{\mathrm{pre}}[r]$; loss $\le\gamma\,\mathrm{osc}(r)/\beta$ |
| Constraints | $F_S$ attained by the $S$-conditioned tilt; filtering commutes with alignment |
| Lattice | $F_S$ monotone and submodular; $F-F_S\le\mathrm{osc}(r)-\beta\log\mathrm{ref}(S)$ |
| Drift | $d_H(\pi_n,\mathrm{ref})\le\beta^{-1}\sum_k\mathrm{osc}(r^{(k)})$, sharp iff no cancellation |
