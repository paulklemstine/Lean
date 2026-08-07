# Two Laws of Delayed Generalization: Sharp Constants for Relaxation and Saddle-Node Bottleneck Grokking

**Author:** Aristotle
**Date:** 2026-08-07

---

## Abstract

We develop a rigorous theory of *delayed transitions* in two-layer rectified-linear
networks and of the *scaling laws* governing the length of the delay. Three layers
of the theory are presented and proved.

First, a **structural layer**. For a two-layer ReLU network of hidden width $m$
with negative output bias, non-positive hidden biases and non-negative output
weights, probed along a ray $t \mapsto tp$, the worst-case classification margin
over a finite two-class test set has a *sharp and unique* threshold $\tau \ge 0$:
the margin is non-positive on $(-\infty,\tau]$ and strictly positive on
$(\tau,\infty)$. The threshold is sandwiched between $|c|/S$, with
$S = \sum_j a_j g_j$ the total signal, and a single-unit bound, and when the
hidden biases vanish the sandwich collapses to the exact identity
$\tau = |c|/S$. This yields an exact $1/m$ width law, $m\,\tau_m \to |c|/\mathbb{E}[Y]$
almost surely for i.i.d. hidden units with integrable signal $Y$ of positive mean.
Non-negativity of the output weights is shown to be *necessary*: it makes the
ramped output convex, so the failure set is an interval and relapse is impossible
("tropical rigidity"), whereas an explicit width-$3k$ network with signed output
weights has a failure set with at least $k+1$ connected components.

Second, a **dynamical layer**. The delay is *derived* rather than prescribed:
weight-decayed gradient flow on the ridge loss $L_\lambda(w) = \tfrac{\lambda}{2}w^2 - sw$
produces the exact crossing time
$\tau(\lambda) = \lambda^{-1}\log\frac{s/\lambda - w_0}{s/\lambda - \theta}$, and the
threshold is crossed at all if and only if the weight decay is subcritical,
$\lambda < \lambda_c = s/\theta$, i.e. iff the bifurcation parameter
$\mu(\lambda) = s/\lambda - \theta$ is positive. This is an explicit *connection
theorem* identifying a regularization hyperparameter with the unfolding parameter
of a saddle-node normal form; the discrete gradient-descent iteration obeys the
analogous logarithmic bound.

Third, the **asymptotic layer**, which is the main new contribution. We determine
the *leading constants* of both delay laws:
$$\tau(\lambda) \;\sim\; \frac{1}{\lambda_c}\,\log\frac{1}{\mu(\lambda)}
\quad (\lambda \uparrow \lambda_c),
\qquad
T_{\mathrm{pass}}(\mu, A) \;\sim\; \frac{\pi}{\sqrt{|\mu|}}
\quad (\mu \uparrow 0),$$
where $T_{\mathrm{pass}}$ is the time a solution of the saddle-node normal form
$\dot x = \mu - x^2$ needs to descend from $+A$ to $-A$ below the bifurcation. The
second constant is exactly $\pi$ and is *independent of the observation level $A$*.
Combining the two, the ratio of the logarithmic to the inverse-square-root delay
tends to zero at criticality, and every logarithmic delay $K\log(D/\mu)$ is
eventually strictly dominated by the bottleneck passage time. This converts a
qualitative dichotomy into two exact asymptotics with named constants
$1/\lambda_c$ and $\pi$, and makes the mechanism behind an observed grokking delay
experimentally identifiable by measuring an exponent.

**Keywords:** grokking, delayed generalization, ReLU networks, saddle-node
bifurcation, weight decay, scaling laws, tropical geometry, Riccati bottleneck.

---

## 1. Introduction

### 1.1 The phenomenon

*Grokking* denotes the empirical observation that a neural network trained past
the point of perfect training accuracy may remain at chance-level test accuracy
for a very long time and then, over a comparatively short window, transition to
near-perfect generalization. Two features of the phenomenon call for
explanation:

1. **Sharpness.** The transition is abrupt and, empirically, not repeated: the
   network does not oscillate between generalizing and not.
2. **Delay.** The waiting time can exceed the memorization time by orders of
   magnitude, and depends strongly on hyperparameters — in particular, on weight
   decay.

The purpose of this paper is to isolate mechanisms responsible for each feature
in models simple enough to admit complete proofs, and then to extract *quantitative
scaling laws with exact constants*, so that the mechanisms become distinguishable
by measurement rather than by narrative.

### 1.2 Contributions

- **Sharp thresholds survive worst-case aggregation** (Section 3): a minimum of
  finitely many monotone continuous signals inherits a unique sharp threshold, so a
  test-set margin transitions exactly once.
- **A closed-form delay and its collapse** (Section 4): the general sandwich
  $|c|/S \le \tau \le (|c|/a_{j_0} - b_{j_0})/g_{j_0}$ and the exact identity
  $\tau = |c|/S$ for zero hidden bias.
- **Width laws** (Section 5): $m\,\tau(m)$ constant in the symmetric model; a
  deterministic Cesàro width law; and its almost-sure form via the strong law of
  large numbers.
- **Tropical rigidity and its failure** (Section 6): convexity of the ramped output
  under non-negative output weights forces an interval failure set; a width-$3k$
  comb network with signed weights has $\ge k+1$ failure components.
- **Derived delay and the connection theorem** (Section 7): weight-decayed gradient
  flow, exact crossing time, criticality at $\lambda_c = s/\theta$, discrete analogue.
- **Local bifurcation theory** (Section 8): nondegeneracy, exchange of stability
  (linear and Lyapunov), cubic reduced loss, robustness of the whole diagram under
  uniform perturbations.
- **Sharp constants and the exponent dichotomy** (Sections 9–10): the two
  asymptotics with constants $1/\lambda_c$ and $\pi$, and the proof that the
  bottleneck law dominates near criticality.
- **Train/test separation** (Section 11): an exact grokking window $(1/2, 2]$ and
  an unbounded grokking ratio.

Throughout, $\mathrm{ReLU}(u) = \max(u, 0)$.

---

## 2. Setting and basic definitions

**Definition 2.1 (Two-layer ReLU network).**
For hidden width $m$ and input dimension $d$, given hidden weights
$W \in \mathbb{R}^{m\times d}$ (rows $W_j$), hidden biases $b \in \mathbb{R}^m$,
output weights $a \in \mathbb{R}^m$ and output bias $c \in \mathbb{R}$, define
$$N(x) \;=\; c + \sum_{j=1}^m a_j\,\mathrm{ReLU}\big(\langle W_j, x\rangle + b_j\big),
\qquad x \in \mathbb{R}^d.$$

**Definition 2.2 (Signal and ramp).**
For a direction $p \in \mathbb{R}^d$, the *signal* of hidden unit $j$ is
$g_j(p) = \langle W_j, p\rangle$. The *ramped output* is
$$R_p(t) \;=\; N(t p) \;=\; c + \sum_{j=1}^m a_j\,\mathrm{ReLU}\big(t\,g_j(p) + b_j\big),
\qquad t \in \mathbb{R}.$$
The identity follows from $\langle W_j, tp\rangle = t\,g_j(p)$.

The ramp parameter $t$ is a stand-in for whatever monotone quantity drives the
network towards competence — a growing weight, a growing feature magnitude, or
training time itself after reparametrization. Sections 7–10 replace it by an
explicitly derived training trajectory.

**Definition 2.3 (Signed score and margin).**
Given labelled test points $p_1,\dots,p_n \in \mathbb{R}^d$ with labels
$y_k \in \{+1,-1\}$, the *signed score* of point $k$ is $s_k(t) = y_k R_{p_k}(t)$,
which is positive exactly when $k$ is classified correctly. The *margin* is
$$M(t) = \min_{1\le k\le n} s_k(t).$$

**Definition 2.4 (Sharp threshold).**
A number $\tau$ is a *sharp threshold* of $f:\mathbb{R}\to\mathbb{R}$ if
$f(t) \le 0$ for all $t \le \tau$ and $f(t) > 0$ for all $t > \tau$.

---

## 3. Sharp thresholds and their stability under worst-case aggregation

**Theorem 3.1 (Existence of a sharp threshold).**
*Let $f : \mathbb{R} \to \mathbb{R}$ be monotone non-decreasing and continuous with
$f(0) < 0$, and suppose $f(T) > 0$ for some $T$. Then there exists $\tau \ge 0$ with
$f(t) \le 0$ for all $t \le \tau$ and $f(t) > 0$ for all $t > \tau$.*

*Proof sketch.* Let $F = \{t : f(t) \le 0\}$. By monotonicity $F$ is a down-set
containing $0$ and bounded above by $T$, so $\tau = \sup F$ exists and $\tau \ge 0$.
For $t < \tau$ there is $u \in F$ with $t < u$, so $f(t) \le f(u) \le 0$; continuity
gives $f(\tau) \le 0$ as a limit of such values. For $t > \tau$ we have $t \notin F$,
i.e. $f(t) > 0$. $\square$

**Proposition 3.2 (Uniqueness).**
*A sharp threshold is unique: if $\tau$ and $\tau'$ are both sharp thresholds of
$f$ and $\tau < \tau'$, then $f(\tau') > 0$ (from $\tau$) and $f(\tau') \le 0$
(from $\tau'$), a contradiction.*

**Theorem 3.3 (Margins inherit sharp thresholds).**
*Let $g_1,\dots,g_n$ be monotone non-decreasing continuous functions, each
eventually positive, with $g_{k_0}(0) < 0$ for at least one $k_0$. Then
$M = \min_k g_k$ has a sharp threshold $\tau \ge 0$.*

*Proof sketch.* A finite minimum of monotone functions is monotone and a finite
minimum of continuous functions is continuous. $M(0) \le g_{k_0}(0) < 0$. Choosing
$T_k$ with $g_k(T_k) > 0$ and setting $T = \max_k T_k$, monotonicity gives
$g_k(T) \ge g_k(T_k) > 0$ for every $k$, hence $M(T) > 0$. Apply Theorem 3.1. $\square$

The content of Theorem 3.3 is that *worst-case aggregation does not smear the
transition*. Test accuracy over a finite set does not creep up point by point in
this model; the entire set flips at one instant.

**Theorem 3.4 (Delayed positivity of the network margin).**
*Let $N$ be as in Definition 2.1 with $c < 0$, $a_j \ge 0$ and $b_j \le 0$ for all
$j$. Let $(p_k, y_k)_{k\le n}$ be a two-class test set, $n \ge 1$, such that*

- *every negative-class point is silent: $y_k = -1 \Rightarrow g_j(p_k) \le 0$ for all $j$;*
- *every positive-class point is aligned: $y_k = +1 \Rightarrow g_j(p_k) \ge 0$ for all $j$;*
- *every positive-class point is active: $y_k = +1 \Rightarrow \exists j_0,\ a_{j_0} > 0$ and $g_{j_0}(p_k) > 0$;*
- *at least one point has $y_k = +1$.*

*Then there is a unique $\tau \ge 0$ with $M(t) \le 0$ for all $t \le \tau$ and
$M(t) > 0$ for all $t > \tau$.*

*Proof sketch.* Each signed score is monotone: for $y_k = +1$, non-negative signals
and non-negative output weights make $R_{p_k}$ non-decreasing (ReLU is monotone and
$t \mapsto t g_j + b_j$ is non-decreasing); for $y_k = -1$, all signals are
non-positive so $R_{p_k}$ is non-increasing and $-R_{p_k}$ is non-decreasing.
Each is continuous, being a finite sum of compositions of continuous maps. At
$t=0$ a positive-class point has all hidden units silent (since $b_j \le 0$), so its
score equals $c < 0$. Each score is eventually positive: for $y_k=-1$ the score is
$-c > 0$ for all $t \ge 0$; for $y_k = +1$ the active unit $j_0$ drives
$a_{j_0}\mathrm{ReLU}(t g_{j_0}(p_k) + b_{j_0})$ above $|c|$ once
$t > (|c|/a_{j_0} - b_{j_0})/g_{j_0}(p_k)$, and all other terms are non-negative.
Apply Theorem 3.3 and Proposition 3.2. $\square$

---

## 4. The delay: bounds and an exact formula

Fix a direction $p$ with signals $g_j = g_j(p)$ and write $S = \sum_j a_j g_j$ for
the *total signal*.

**Lemma 4.1 (Linear domination).**
*If $a_j \ge 0$, $b_j \le 0$ and $g_j \ge 0$ for all $j$, then for $t \ge 0$,*
$$R_p(t) \;\le\; c + t\,S.$$
*Proof.* $\mathrm{ReLU}(t g_j + b_j) \le t g_j$, because $t g_j \ge 0$ and
$t g_j \ge t g_j + b_j$. Multiply by $a_j \ge 0$ and sum. $\square$

**Theorem 4.2 (Lower bound on the delay).**
*Under the hypotheses of Lemma 4.1, with $c < 0$ and $S > 0$: if $\tau$ satisfies
$R_p(t) > 0$ for all $t > \tau$, then*
$$\tau \;\ge\; \frac{|c|}{S}.$$
*Proof sketch.* If $\tau < |c|/S$, pick $t$ with $\tau < t < |c|/S$ (necessarily
$t>0$). Then $R_p(t) > 0$ by hypothesis, but Lemma 4.1 gives
$R_p(t) \le c + tS < c + |c| = 0$. $\square$

**Theorem 4.3 (Upper bound on the delay).**
*Let $a_j \ge 0$ for all $j$, and suppose some unit $j_0$ has $a_{j_0} > 0$ and
$g_{j_0} > 0$. If $\tau$ satisfies $R_p(t) \le 0$ for all $t \le \tau$, then*
$$\tau \;\le\; \frac{|c|/a_{j_0} - b_{j_0}}{g_{j_0}}.$$
*Proof sketch.* Write $T$ for the right-hand side, so that
$T g_{j_0} + b_{j_0} = |c|/a_{j_0}$. If $\tau > T$, choose $T' \in (T,\tau]$. Then
$T' g_{j_0} + b_{j_0} > |c|/a_{j_0}$, hence
$a_{j_0}\mathrm{ReLU}(T' g_{j_0} + b_{j_0}) > |c|$, and all other summands are
non-negative, so $R_p(T') > c + |c| = 0$, contradicting $R_p(T') \le 0$. $\square$

**Corollary 4.4 (Delay sandwich).**
*Under the hypotheses of both theorems, any sharp threshold $\tau$ of $R_p$
satisfies*
$$\frac{|c|}{\sum_j a_j g_j} \;\le\; \tau \;\le\; \frac{|c|/a_{j_0} - b_{j_0}}{g_{j_0}}.$$

**Theorem 4.5 (Exact delay for vanishing hidden biases).**
*Assume $b_j = 0$ for all $j$, $g_j \ge 0$, $c < 0$ and $S = \sum_j a_j g_j > 0$.
Then the sharp threshold of $R_p$ is exactly*
$$\tau \;=\; \frac{|c|}{S}.$$
*Proof sketch.* With $b_j = 0$ and $t \ge 0$ we have
$\mathrm{ReLU}(tg_j) = t g_j$, hence $R_p(t) = c + tS$ exactly; for $t \le 0$ every
unit is silent and $R_p(t) = c < 0$. The affine formula gives $R_p(t) \le 0$ iff
$t \le |c|/S$, and $>0$ strictly beyond. $\square$

**Interpretation.** $\tau = |c|/S$ reads *delay = prior resistance / evidence rate*.
Doubling the output bias doubles the wait; doubling the total signal halves it.
Corollary 4.4 shows that non-zero hidden biases can only place $\tau$ between a
collective and an individual estimate.

---

## 5. Width laws

**Definition 5.1 (Symmetric network).**
Fix $A, g > 0$, $c<0$, take $d = 1$, $p = 1$, and $m$ identical hidden units with
weight $g$, bias $0$ and output weight $A$. Then $S = mAg$ and Theorem 4.5 gives the
sharp delay
$$\tau(m) \;=\; \frac{|c|}{m\,A\,g}.$$

**Theorem 5.2 (Exact $1/m$ width law).**
*For every $m \ge 1$, $\;m\,\tau(m) = |c|/(Ag)$, independent of $m$; consequently
$\tau(m) \to 0$ as $m \to \infty$.*

More generally, let the units be heterogeneous with per-unit signals
$u_j = a_j g_j \ge 0$ and let $S_m = \sum_{j<m} u_j$, so the delay of the
width-$m$ zero-bias network is $\tau_m = |c|/S_m$.

**Theorem 5.3 (Cesàro width law).**
*If $m^{-1}S_m \to L$ with $L > 0$, then $m\,\tau_m \to |c|/L$.*

*Proof sketch.* $m\,\tau_m = |c| \cdot m / S_m = |c| / (m^{-1}S_m)$ whenever
$S_m \neq 0$. Since $m^{-1}S_m \to L > 0$, eventually $m^{-1}S_m > L/2 > 0$, so the
quotient is eventually defined and converges to $|c|/L$ by continuity of division
away from zero. $\square$

**Theorem 5.4 (Almost-sure width law for i.i.d. units).**
*Let $(Y_j)_{j\ge 0}$ be pairwise independent, identically distributed, integrable
real random variables with $\mathbb{E}[Y_0] > 0$, interpreted as the per-unit
signals $u_j$. Then almost surely*
$$m\,\tau_m \;\longrightarrow\; \frac{|c|}{\mathbb{E}[Y_0]}.$$

*Proof sketch.* The strong law of large numbers gives
$m^{-1}\sum_{j<m}Y_j \to \mathbb{E}[Y_0]$ almost surely; apply Theorem 5.3 pathwise
on the full-measure event where the convergence holds. $\square$

Theorem 5.4 is the precise sense in which "wider networks grok sooner": not merely
monotonically, but with the exact rate $1/m$ and the identifiable constant
$|c|/\mathbb{E}[Y]$.

---

## 6. Tropical rigidity, and how to break it

**Theorem 6.1 (Convexity of the ramped output).**
*If $a_j \ge 0$ for all $j$, then $t \mapsto R_p(t)$ is convex on $\mathbb{R}$.*

*Proof sketch.* $t \mapsto t g_j + b_j$ is affine, hence convex; $\mathrm{ReLU}$ is
convex and non-decreasing, so $t \mapsto \mathrm{ReLU}(t g_j + b_j)$ is convex
(indeed it is $\max$ of two affine functions). A non-negative combination of convex
functions plus a constant is convex. $\square$

**Corollary 6.2 (The failure set is an interval).**
*If $a_j \ge 0$, then $\{t : R_p(t) \le 0\}$ is convex, i.e. an interval. In
particular the network cannot fail, succeed, and fail again along the ramp.*

This is a *tropical* (max-plus, piecewise-linear) rigidity statement: the
combinatorial structure of a positively-weighted ReLU layer forbids relapse. The
hypothesis $a_j \ge 0$ cannot be dropped.

**Theorem 6.3 (A network that groks twice).**
*Let*
$$H(t) \;=\; -\tfrac12 + \mathrm{ReLU}(t) - 2\,\mathrm{ReLU}(t-1) + \mathrm{ReLU}(t-2),$$
*a genuine width-$3$, one-dimensional two-layer ReLU network with hidden weights
$(1,1,1)$, hidden biases $(0,-1,-2)$, output weights $(1,-2,1)$ and output bias
$-1/2$. Then*
$$\{t : H(t) \le 0\} \;=\; (-\infty, \tfrac12] \,\cup\, [\tfrac32, \infty),$$
*which is not convex; in particular $H > 0$ exactly on the open window
$(\tfrac12, \tfrac32)$.*

*Proof sketch.* The three ReLU kinks at $0,1,2$ decompose $\mathbb{R}$ into four
pieces on which $H$ is affine: $H \equiv -1/2$ on $(-\infty,0]$; $H(t) = -1/2 + t$
on $[0,1]$; $H(t) = -1/2 + (2-t)$ on $[1,2]$; $H \equiv -1/2$ on $[2,\infty)$. So
$H$ is a triangular tent of height $1/2$ above zero, crossing $0$ upward at $1/2$
and downward at $3/2$. $\square$

**Theorem 6.4 (Linearly many relapses).**
*For $k \ge 1$ let $\beta_i(t)$ be the tent supported on $[2i, 2i+2]$ with peak $1$
at $2i+1$, realized as
$\beta_i(t) = \mathrm{ReLU}(t - 2i) - 2\,\mathrm{ReLU}(t-2i-1) + \mathrm{ReLU}(t-2i-2)$,
and let*
$$C_k(t) \;=\; -\tfrac12 + \sum_{i=0}^{k-1}\beta_i(t).$$
*Then $C_k$ is an honest two-layer ReLU network of hidden width $3k$ with signed
output weights, $C_k(2i) = -\tfrac12$ for every integer $i$, and
$C_k(2i+1) = +\tfrac12$ for every $0 \le i < k$. Consequently the failure set
$\{t : C_k(t) \le 0\}$ has at least $k+1$ connected components (the points
$0, 2, 4, \dots, 2k$ lie in pairwise distinct components), and for $k \ge 1$ it is
not convex.*

*Proof sketch.* Adjacent tents overlap only at their common endpoint, where both
vanish, so at every even integer all bumps are zero and $C_k = -1/2$; at $2i+1$ with
$i<k$ exactly one bump attains its peak $1$ and $C_k = 1/2$. Distinct even integers
$2i < 2j \le 2k$ are separated inside the failure set by the point $2i+1$, where
$C_k > 0$; hence they cannot lie in a common connected (equivalently, in
$\mathbb{R}$, interval) component. Injectivity of $i \mapsto$ (component of $2i$)
gives $\ge k+1$ components. Non-convexity follows since $0$ and $2k$ are in the
failure set but $1$ is not. $\square$

Theorems 6.1 and 6.4 together delimit the phenomenon exactly: with a positively
weighted output layer, grokking happens at most once; with signed output weights,
the number of grok/un-grok events can grow linearly in the width.

---

## 7. Deriving the delay from training dynamics

We now stop prescribing the ramp and derive it.

**Definition 7.1 (Ridge loss and gradient flow).**
For $\lambda > 0$ (weight decay) and $s > 0$ (data drive), let
$$L_\lambda(w) = \frac{\lambda}{2}w^2 - s\,w, \qquad L_\lambda'(w) = \lambda w - s.$$
Gradient flow $\dot w = -L_\lambda'(w) = s - \lambda w$ with $w(0) = w_0$ has the
explicit solution
$$w_\lambda(t) \;=\; \frac{s}{\lambda} + \Big(w_0 - \frac{s}{\lambda}\Big)e^{-\lambda t}.$$

**Proposition 7.2.** *$w_\lambda$ satisfies $w_\lambda(0)=w_0$ and
$\dot w_\lambda(t) = -L_\lambda'(w_\lambda(t))$ for all $t$. If $w_0 < s/\lambda$
then $w_\lambda$ is strictly increasing and $w_\lambda(t) < s/\lambda$ for all $t$.*

*Proof sketch.* Direct differentiation of the exponential;
$w_\lambda(t) - s/\lambda = (w_0 - s/\lambda)e^{-\lambda t}$ is negative and
strictly increasing when $w_0 < s/\lambda$ and $\lambda>0$. $\square$

**Definition 7.3 (Crossing time).**
For an activation threshold $\theta$ with $w_0 < \theta < s/\lambda$, put
$$\tau(\lambda) \;=\; \frac{1}{\lambda}\,
\log\!\left(\frac{s/\lambda - w_0}{s/\lambda - \theta}\right).$$

**Theorem 7.4 (Exact crossing law).**
*For $\lambda > 0$, $w_0 < \theta < s/\lambda$ and every $t \in \mathbb{R}$,*
$$w_\lambda(t) > \theta \iff t > \tau(\lambda).$$

*Proof sketch.* $w_\lambda(t) > \theta$ is equivalent to
$e^{-\lambda t} < \frac{s/\lambda - \theta}{s/\lambda - w_0}$, both sides positive;
taking logarithms and using
$\log\frac{s/\lambda-\theta}{s/\lambda-w_0} = -\log\frac{s/\lambda-w_0}{s/\lambda-\theta}$
gives $-\lambda t < -\lambda\tau(\lambda)$, i.e. $t > \tau(\lambda)$. $\square$

**Corollary 7.5 (Trained delayed transition).**
*Under the same hypotheses, $\mathrm{ReLU}(w_\lambda(t) - \theta) = 0$ for every
$t \le \tau(\lambda)$ and $\mathrm{ReLU}(w_\lambda(t)-\theta) > 0$ for every
$t > \tau(\lambda)$.* The delayed transition of Section 3 now has a delay produced
by optimization rather than assumed.

**Definition 7.6 (Bifurcation parameter and critical decay).**
$$\mu(\lambda) \;=\; \frac{s}{\lambda} - \theta, \qquad \lambda_c \;=\; \frac{s}{\theta}.$$

**Proposition 7.7.** *For $\lambda, \theta > 0$: $\mu(\lambda) > 0 \iff \lambda < \lambda_c$.*

**Theorem 7.8 (Connection theorem: regularization $\mapsto$ normal form).**
*For $\lambda, \theta > 0$ and $w_0 < \theta$,*
$$\big(\exists\, t \ge 0 : w_\lambda(t) > \theta\big) \iff \lambda < \lambda_c
\iff \mu(\lambda) > 0.$$

*Proof sketch.* ($\Leftarrow$) If $\mu > 0$ then $\theta < s/\lambda$ and Theorem 7.4
applies at any $t > \max(0,\tau(\lambda))$. ($\Rightarrow$) If $s/\lambda \le \theta$,
then since $e^{-\lambda t}\in(0,1]$ for $t \ge 0$ and $w_0 < \theta$, we get
$w_\lambda(t) = s/\lambda + (w_0 - s/\lambda)e^{-\lambda t} \le \theta$ for all
$t \ge 0$. $\square$

Theorem 7.8 identifies the *unfolding parameter of the saddle-node normal form*
studied in Section 8 with an explicit function of the regularization strength.
Above $\lambda_c$ the transition does not occur at all; below it, the transition
occurs, but the delay blows up as $\lambda \uparrow \lambda_c$:

**Theorem 7.9 (Divergence at criticality).**
*For $0 < \theta$, $w_0 < \theta$, $0 < s$:*
$$\frac{1}{\lambda}\log\frac{\theta - w_0}{\mu(\lambda)} \;\le\; \tau(\lambda),$$
*and $\tau(\lambda) \to +\infty$ as $\lambda \uparrow \lambda_c$; in particular for
every $T$ there is a subcritical $\lambda$ with $\tau(\lambda) > T$.*

*Proof sketch.* The lower bound follows from
$\frac{\theta-w_0}{\mu} \le \frac{s/\lambda - w_0}{s/\lambda-\theta}$ (increase the
numerator from $\theta$ to $s/\lambda$) and monotonicity of $\log$. Divergence:
given $T$, choose $\mu$ small enough that
$\log\frac{\theta-w_0}{\mu} > \lambda_c T$ and set $\lambda = s/(\theta+\mu) < \lambda_c$;
since $\lambda \le \lambda_c$ we have $1/\lambda \ge 1/\lambda_c$, and the lower
bound exceeds $T$. $\square$

**Theorem 7.10 (Discrete gradient descent).**
*Let $w_{k+1} = w_k - \eta(\lambda w_k - s)$ with $w_0$ given, $\eta>0$,
$\eta\lambda < 1$. Then*
$$w_k = \frac{s}{\lambda} + \Big(w_0 - \frac{s}{\lambda}\Big)(1-\eta\lambda)^k,$$
*and if $w_k > \theta$ for some $k$ with $w_0 < \theta < s/\lambda$, then*
$$k \;>\; \frac{\log\big((s/\lambda-\theta)/(s/\lambda-w_0)\big)}{\log(1-\eta\lambda)}.$$

*Proof sketch.* Induction gives the closed form. From $w_k > \theta$ one obtains
$(1-\eta\lambda)^k < \frac{s/\lambda-\theta}{s/\lambda-w_0}$; take logarithms and
divide by $\log(1-\eta\lambda) < 0$, reversing the inequality. $\square$

The discrete bound is again logarithmic in the gap $s/\lambda - \theta = \mu$, with
$1/|\log(1-\eta\lambda)| \approx 1/(\eta\lambda)$ in place of $1/\lambda$: the flow
and the iteration share an exponent.

---

## 8. Local saddle-node theory

**Definition 8.1 (Normal form).** $f_\mu(x) = \mu - x^2$, with flow $\dot x = f_\mu(x)$.

**Theorem 8.2 (Nondegeneracy).**
*At $(\mu,x) = (0,0)$: $f_0(0) = 0$, $\partial_x f_0(0) = 0$,
$\partial_\mu f_\mu(x) = 1 \ne 0$, and $\partial_x^2 f_\mu(x) = -2 \ne 0$.*
These are exactly the classical saddle-node conditions: a degenerate equilibrium
with non-vanishing quadratic term and transverse parameter dependence.

**Theorem 8.3 (Branches and exchange of stability).**
*For $\mu > 0$, $f_\mu(x) = 0$ iff $x = \pm\sqrt\mu$, and*
$$\partial_x f_\mu(\sqrt\mu) = -2\sqrt\mu < 0, \qquad
\partial_x f_\mu(-\sqrt\mu) = +2\sqrt\mu > 0.$$
*At $\mu=0$ the single equilibrium is linearly degenerate,
$\partial_x f_0(0) = 0$. For $\mu<0$ there is no equilibrium.*

Linear stability is complemented by a nonlinear (Lyapunov) statement.

**Theorem 8.4 (Nonlinear attraction and repulsion).**
*Let $\mu > 0$ and let $x(\cdot)$ solve $\dot x = \mu - x^2$.*

1. *If $x(t) > -\sqrt\mu$ and $x(t) \ne \sqrt\mu$, then
   $\frac{d}{dt}\big(x(t)-\sqrt\mu\big)^2 < 0$.*
2. *If $x(t) < \sqrt\mu$ and $x(t) \ne -\sqrt\mu$, then
   $\frac{d}{dt}\big(x(t)+\sqrt\mu\big)^2 > 0$.*

*Proof sketch.* $\frac{d}{dt}(x-\sqrt\mu)^2 = 2(x-\sqrt\mu)(\mu - x^2)
= -2(x-\sqrt\mu)^2(x+\sqrt\mu)$, using $(\sqrt\mu)^2 = \mu$; this is strictly
negative when $x \ne \sqrt\mu$ and $x > -\sqrt\mu$. Symmetrically
$\frac{d}{dt}(x+\sqrt\mu)^2 = -2(x+\sqrt\mu)^2(x-\sqrt\mu) > 0$ when
$x \ne -\sqrt\mu$ and $x < \sqrt\mu$. $\square$

**Theorem 8.5 (Cubic reduced loss).**
*Let $V_\mu(x) = \frac{x^3}{3} - \mu x$. Then $V_\mu'(x) = x^2 - \mu = -f_\mu(x)$,
so the normal form is the negative gradient flow of $V_\mu$; critical points of
$V_\mu$ are exactly the equilibria. For $\mu > 0$, $\sqrt\mu$ is a strict local
minimum of $V_\mu$ and $-\sqrt\mu$ a strict local maximum; for $\mu < 0$, $V_\mu$
has no critical point.*

*Proof sketch.* The identity $V_\mu(x) - V_\mu(\sqrt\mu)
= \frac{1}{3}(x-\sqrt\mu)^2(x + 2\sqrt\mu)$ is exact and shows non-negativity
near $\sqrt\mu$; the mirrored factorization gives the local maximum. For $\mu<0$,
$x^2 - \mu \ge -\mu > 0$. $\square$

**Theorem 8.6 (Robustness of the bifurcation diagram).**
*Let $g$ be continuous with $|g(x) - (\mu - x^2)| \le \varepsilon$ for all $x$.*

1. *If $0 < \varepsilon < \mu$, then $g$ has at least two zeros, one in
   $(-b, 0)$ and one in $(0, b)$, where $b = \sqrt{\mu+2\varepsilon}$.*
2. *Every zero $x$ of $g$ satisfies $|x^2 - \mu| \le \varepsilon$; hence it lies
   near one of the exact branches.*
3. *If $\mu < -\varepsilon$, then $g$ has no zero at all.*

*Proof sketch.* (1) $g(0) \ge \mu - \varepsilon > 0$ while
$g(\pm b) \le \mu - b^2 + \varepsilon = -\varepsilon < 0$; apply the intermediate
value theorem on $(0,b)$ and on $(-b,0)$. (2) $g(x)=0$ and the uniform bound give
$|\mu - x^2| \le \varepsilon$. (3) $g(x) \le \mu - x^2 + \varepsilon \le \mu + \varepsilon < 0$. $\square$

Thus the entire qualitative picture — two branches with opposite stability above
threshold, none below — is stable under uniform perturbations of the vector field,
and it is not an artifact of the exact quadratic.

---

## 9. The bottleneck: exact passage times below the saddle node

For $\mu < 0$ the flow has no equilibrium, but the *ghost* of the annihilated pair
slows it dramatically. Write $\mu = -k^2$ with $k = \sqrt{-\mu} > 0$.

**Theorem 9.1 (Exact Riccati solution).**
*The function $x_k(t) = -k\tan(kt)$ satisfies $\dot x_k(t) = -k^2 - x_k(t)^2$
wherever $\cos(kt) \ne 0$; i.e. it solves $\dot x = \mu - x^2$ with $\mu = -k^2$.*

*Proof sketch.* $\frac{d}{dt}\big(-k\tan(kt)\big) = -k^2\sec^2(kt)
= -k^2\big(1 + \tan^2(kt)\big) = -k^2 - x_k(t)^2$, using $\tan^2 u + 1 = \sec^2 u$. $\square$

**Definition 9.2 (Passage time).**
For an observation level $A > 0$,
$$T(k,A) \;=\; \frac{2\arctan(A/k)}{k}.$$

**Proposition 9.3 (Endpoints).**
*$x_k\big(-\arctan(A/k)/k\big) = A$ and $x_k\big(\arctan(A/k)/k\big) = -A$, so
$T(k,A)$ is exactly the time the solution needs to descend from $+A$ to $-A$.*

**Theorem 9.4 (Inverse-square-root lower bound).**
*If $0 < k \le A$ then $T(k,A) \ge \dfrac{\pi}{2k}$.*

*Proof sketch.* $A/k \ge 1$ gives $\arctan(A/k) \ge \arctan 1 = \pi/4$, hence
$T = 2\arctan(A/k)/k \ge \pi/(2k)$. $\square$

**Corollary 9.5.** *In terms of the bifurcation parameter, for $\mu < 0$ and
$A \ge \sqrt{-\mu}$,*
$$T\big(\sqrt{-\mu}, A\big) \;\ge\; \frac{\pi}{2}\,|\mu|^{-1/2},$$
*so the passage time diverges with exponent $1/2$ as $\mu \uparrow 0$; for every
target $T_0$ there is $k \in (0,A]$ with $T(k,A) > T_0$.*

---

## 10. Sharp constants and the exponent dichotomy

This section contains the main new asymptotic results. Both delay laws are pinned
down to their leading constants.

### 10.1 The logarithmic law

**Theorem 10.1 (Sharp constant of the relaxation delay).**
*Let $s > 0$, $\theta > 0$, $w_0 < \theta$, and let $\tau(\lambda)$, $\mu(\lambda)$,
$\lambda_c$ be as in Section 7. Then*
$$\lim_{\lambda \uparrow \lambda_c}\ \frac{\tau(\lambda)}{\log\big(1/\mu(\lambda)\big)}
\;=\; \frac{\theta}{s} \;=\; \frac{1}{\lambda_c},$$
*that is,*
$$\tau(\lambda) \;\sim\; \frac{1}{\lambda_c}\,\log\frac{1}{\mu(\lambda)}
\qquad (\lambda \uparrow \lambda_c).$$

*Proof sketch.* Work on a left neighbourhood $(\lambda_-, \lambda_c)$ of
$\lambda_c$, with $\lambda_- = s/(2\theta - w_0) < \lambda_c$, on which
$\theta < s/\lambda < 2\theta - w_0$, so $\mu(\lambda) \in (0, \theta-w_0)$ and both
logarithms below are defined. Split the crossing time:
$$\tau(\lambda) = \frac{1}{\lambda}\Big[\log\big(s/\lambda - w_0\big)
+ \log\big(1/\mu(\lambda)\big)\Big].$$
As $\lambda \uparrow \lambda_c$ we have $s/\lambda \to \theta$, hence
$\mu(\lambda) \to 0^+$ and $\log(1/\mu(\lambda)) \to +\infty$, while
$\log(s/\lambda - w_0) \to \log(\theta - w_0)$, a finite limit. Therefore
$$\frac{\tau(\lambda)}{\log(1/\mu(\lambda))}
= \frac{1}{\lambda}\left[\frac{\log(s/\lambda - w_0)}{\log(1/\mu(\lambda))} + 1\right]
\;\longrightarrow\; \frac{1}{\lambda_c}\,[\,0 + 1\,] = \frac{\theta}{s}. \qquad\square$$

The mechanism of the proof is worth naming: the delay is the sum of a *bounded*
contribution (how far the initial weight is from the threshold) and a *divergent*
contribution (how close the regularized optimum is to the threshold). Only the
second survives normalization, and its prefactor is the reciprocal critical decay.

### 10.2 The bottleneck law

**Theorem 10.2 (Sharp constant of the passage time).**
*For every fixed observation level $A > 0$,*
$$\lim_{k \downarrow 0} \; k\,T(k,A) \;=\; \pi.$$

*Proof sketch.* $k\,T(k,A) = 2\arctan(A/k)$ identically for $k>0$. As
$k \downarrow 0$, $A/k \to +\infty$ and $\arctan \to \pi/2$, so the product tends
to $2\cdot(\pi/2) = \pi$. $\square$

**Theorem 10.3 (Sharp inverse-square-root law).**
*For every $A > 0$,*
$$\lim_{\mu \uparrow 0}\ \sqrt{-\mu}\;T\big(\sqrt{-\mu}, A\big) \;=\; \pi,
\qquad\text{i.e.}\qquad
T\big(\sqrt{-\mu},A\big) \;\sim\; \pi\,|\mu|^{-1/2}.$$

*Proof sketch.* $\mu \mapsto \sqrt{-\mu}$ maps a left neighbourhood of $0$ into a
right neighbourhood of $0$ and tends to $0$ there; compose with Theorem 10.2. $\square$

Two features deserve emphasis.

- The **exponent** is $-1/2$, in contrast with the merely logarithmic divergence of
  Theorem 10.1: the bottleneck is a genuinely power-law slowdown.
- The **constant** is exactly $\pi$ and does **not depend on $A$**. All of the
  asymptotic time is spent in an arbitrarily small neighbourhood of the ghost
  equilibrium; enlarging the observation window adds only $O(1)$ time. This
  $A$-independence is the mathematical signature of a bottleneck: the answer
  forgets the boundary conditions.

### 10.3 The dichotomy

**Theorem 10.4 (The relaxation delay is asymptotically negligible).**
*For every $K \in \mathbb{R}$ and $D > 0$,*
$$\lim_{\mu \downarrow 0}\ \frac{K\log(D/\mu)}{\pi / (2\sqrt\mu)} \;=\; 0.$$

*Proof sketch.* The ratio equals
$\frac{2K}{\pi}\big[\sqrt\mu\,\log D + \sqrt\mu \log(1/\mu)\big]$. The first term
tends to $0$ trivially. For the second, $\sqrt\mu\,\log(1/\mu) \to 0$ as
$\mu \downarrow 0$, since $x^{r}\log x \to 0$ for every $r>0$ (take $r=1/2$). $\square$

**Theorem 10.5 (Quantitative dominance).**
*For every $K \in \mathbb{R}$, $D>0$ and $A>0$ there is $\delta > 0$ such that for
all $\mu \in (0,\delta)$,*
$$K\log(D/\mu) \;<\; T\big(\sqrt\mu, A\big).$$

*Proof sketch.* By Theorem 10.4 there is $\delta_1$ with
$K\log(D/\mu) < \pi/(2\sqrt\mu)$ for $\mu \in (0,\delta_1)$. Choose
$\delta_2$ with $\sqrt\mu \le A$ for $\mu < \delta_2$; then Theorem 9.4 gives
$\pi/(2\sqrt\mu) \le T(\sqrt\mu, A)$. Take $\delta = \min(\delta_1,\delta_2)$. $\square$

**Summary of the dichotomy.** Near a critical parameter value, a smooth
one-dimensional reduction of a training system slows down in one of two ways:

| Mechanism | Delay law | Sharp constant | Signature |
|---|---|---|---|
| Threshold relaxation | $\tau \sim \dfrac{1}{\lambda_c}\log\dfrac1\mu$ | $1/\lambda_c = \theta/s$ | no power-law slope; depends on $w_0$ only at $O(1)$ |
| Saddle-node bottleneck | $T \sim \pi\,\mu^{-1/2}$ | $\pi$ | log–log slope $-1/2$; independent of observation level |

and where both are present, Theorem 10.5 says the bottleneck dominates. This is
the precise sense in which the exponent, not the constant, is the identifying
observable, and the constants are what turn the identification into a
quantitative prediction.

---

## 11. Train/test separation and the grokking ratio

The delay theory above becomes a theory of *grokking* only once training and test
behaviour are separated in time. The following minimal example does exactly that.

**Definition 11.1.** Let $E(p, t) = -1 + \mathrm{ReLU}(t p)$ — the width-one,
one-dimensional network with hidden weight $1$, hidden bias $0$, output weight $1$
and output bias $-1$, probed along the ramp $t \mapsto tp$. Take a training set
consisting of a positive point with signal $2$ and a negative point with signal
$-1$, and a test point with weak signal $1/2$. Say the training set is *perfect* at
time $t$ if $E(2,t) > 0$ and $-E(-1,t) > 0$, and the test point is *correct* if
$E(1/2, t) > 0$.

**Theorem 11.2 (Exact grokking window).**
$$\{\,t \ge 0 : \text{training perfect and test incorrect}\,\} \;=\; \big(\tfrac12,\ 2\big].$$
*Moreover the window is sharp on both sides: the training set is not perfectly
classified for any $0 \le t \le 1/2$, and the test point is correctly classified
for every $t > 2$.*

*Proof sketch.* $E(2,t) = -1 + \max(2t,0) > 0$ iff $t > 1/2$. The negative training
point has $\mathrm{ReLU}(-t) = 0$ for $t \ge 0$, so $-E(-1,t) = 1 > 0$ always.
$E(1/2,t) = -1 + \max(t/2, 0) > 0$ iff $t > 2$. Intersecting gives $(1/2, 2]$. $\square$

On this window the training error is already zero while the test error is still
positive: a formal grokking window with computable endpoints. Its length is
governed entirely by the ratio of signal strengths, and that ratio is unbounded:

**Theorem 11.3 (Unbounded grokking ratio).**
*Let $u_\sigma(t) = -1 + \mathrm{ReLU}(t\sigma)$ be a single-unit score with signal
strength $\sigma > 0$; its sharp threshold is exactly $1/\sigma$. Fix a training
signal $\sigma_{\mathrm{train}} > 0$. Then for every $R$ there is
$\sigma_{\mathrm{test}} > 0$ such that both transitions are sharp with finite
thresholds $1/\sigma_{\mathrm{train}}$ and $1/\sigma_{\mathrm{test}}$, and*
$$\frac{1/\sigma_{\mathrm{test}}}{1/\sigma_{\mathrm{train}}}
= \frac{\sigma_{\mathrm{train}}}{\sigma_{\mathrm{test}}} \;>\; R.$$

*Proof sketch.* The threshold claim is immediate from
$\mathrm{ReLU}(t\sigma) \le 1 \iff t \le 1/\sigma$ for $\sigma > 0$. For the ratio,
take $\sigma_{\mathrm{test}} = \sigma_{\mathrm{train}} / (2(R+1))$ when $R + 1 > 0$
(and $\sigma_{\mathrm{test}} = \sigma_{\mathrm{train}}$ otherwise). $\square$

Thus the separation between memorization and generalization has **no universal
bound**; it is set by how weakly the test distribution excites the features that
the training data built.

**Theorem 11.4 (Robustness of the transition, with a sharp displacement).**
*Let $f$ satisfy $f(t) \le 0$ for $t \le \tau$ and $f(t) \ge \kappa(t-\tau)$ for
$t > \tau$, with $\kappa > 0$, and let $g$ satisfy $|g(t)-f(t)| \le \varepsilon$
for all $t$, $\varepsilon \ge 0$. Then $g(t) \le \varepsilon$ for all $t \le \tau$
and $g(t) > 0$ for all $t > \tau + \varepsilon/\kappa$. The displacement
$\varepsilon/\kappa$ is attained: for $f(t) = \kappa(t-\tau)$ and
$g = f - \varepsilon$, the sharp threshold of $g$ is exactly
$\tau + \varepsilon/\kappa$, strictly later than $\tau$ when $\varepsilon > 0$.*

*Proof sketch.* Before $\tau$: $g \le f + \varepsilon \le \varepsilon$. After
$\tau + \varepsilon/\kappa$: $f(t) \ge \kappa(t-\tau) > \varepsilon$, so
$g(t) \ge f(t) - \varepsilon > 0$. Sharpness: $\kappa(t-\tau) - \varepsilon > 0$ iff
$t > \tau + \varepsilon/\kappa$. $\square$

Noise therefore *delays* grokking by a computable amount and cannot abolish it.

---

## 12. Algorithms

The theory yields four immediately implementable procedures.

**A. Exact delay of a zero-bias network.** Given $c<0$ and per-unit signals
$u_j = a_j g_j \ge 0$, the sharp delay is $\tau = |c| / \sum_j u_j$ (Theorem 4.5).
Cost: $O(m)$.

**B. Sandwich certificate.** Given general $a, b, g, c$, return the interval
$\big[\,|c|/S,\ \min_{j : a_j, g_j>0}(|c|/a_j - b_j)/g_j\,\big]$ containing the
sharp delay (Corollary 4.4). Cost: $O(m)$. A width-zero interval certifies the
exact answer.

**C. Crossing time and criticality test.** Given $\lambda, s, w_0, \theta$: report
$\lambda_c = s/\theta$ and $\mu = s/\lambda - \theta$; if $\mu \le 0$, report "no
transition"; otherwise return $\tau = \lambda^{-1}\log\frac{s/\lambda - w_0}{\mu}$
(Theorems 7.4, 7.8). Cost: $O(1)$.

**D. Mechanism classifier.** Given a family of measured delays $\tau(\mu_i)$ over
a range of control parameters $\mu_i \downarrow 0$, fit both
$\tau \approx K_1\log(1/\mu)$ and $\tau \approx K_2 \mu^{-1/2}$ and compare
residuals; equivalently, regress $\log\tau$ against $\log(1/\mu)$ and test whether
the slope is near $1/2$ (bottleneck) or near $0$ with logarithmic curvature
(relaxation). Theorems 10.1 and 10.3 supply the predicted constants $1/\lambda_c$
and $\pi$, which upgrade the classification from a shape test to a calibrated one.
Cost: $O(n)$ in the number of samples.

---

## 13. Discussion

### 13.1 What the flat curve conceals

In every model treated here the *internal* state moves smoothly and monotonically
throughout the flat phase: a weight climbing an exponential toward its regularized
optimum, or a state crawling through the remnant of an annihilated equilibrium
pair. The observable is flat because a rectifier clips it, or because a margin has
not yet reached zero. The transition is not a change of internal dynamics but the
moment a monotone quantity crosses a level. This suggests that the correct
experimental object is not the test curve but a *pre-threshold observable* — a
margin, a weight norm, a feature alignment — whose motion is visible during the
plateau.

### 13.2 Two mechanisms, two fingerprints

The paper's central quantitative message is that only two divergence laws appear,
they are distinguishable by exponent, and both constants are computable:
$1/\lambda_c$ for relaxation and $\pi$ for the bottleneck. Because the second law
dominates the first arbitrarily close to criticality (Theorem 10.5), a system that
contains both will show a $-1/2$ log–log slope near its critical point. Observing a
logarithmic law therefore *excludes* a nearby saddle node in the reduced dynamics,
which is a falsifiable structural claim about the loss landscape.

### 13.3 Scope and limitations

The results are theorems about explicitly specified models, and their scope should
be stated plainly.

- The ramp $t \mapsto tp$ is a one-parameter probe, not a full training trajectory
  in weight space; Section 7 supplies an honest trajectory only for a scalar weight.
- The sign conditions ($c<0$, $a_j \ge 0$, $b_j \le 0$, class-dependent signal
  signs) are what make the margin monotone; Section 6 shows they are not
  cosmetic — dropping $a_j \ge 0$ permits arbitrarily many relapses.
- The connection between weight decay and the normal form is a *statement about
  parameters*, Theorem 7.8: it identifies when a transition happens, and it makes
  $\mu$ an explicit function of $\lambda$. It does not derive the quadratic vector
  field from a concrete network's loss.
- The width laws assume zero hidden biases (for exactness) or the sandwich (for
  bounds), and the probabilistic version assumes i.i.d. units.

### 13.4 Relation to the empirical picture

Three empirical regularities find quantitative counterparts here. *Weight decay
controls grokking*: Theorem 7.8 gives a genuine critical value $\lambda_c$ above
which the transition never occurs, and Theorem 10.1 gives the divergence rate just
below it. *Wider is faster*: Theorem 5.4 gives the exact rate $1/m$ and the constant
$|c|/\mathbb{E}[Y]$. *The transition is sudden and permanent*: Theorem 3.4 gives
sharpness and Corollary 6.2 gives permanence — with Theorem 6.4 identifying exactly
the structural ingredient (signed output weights) whose presence would allow the
phenomenon to repeat.

---

## 14. Future directions

1. **Vector-valued training dynamics.** Derive the ramp of Section 3 from gradient
   flow in the full weight space of a finite-width network, rather than for a
   scalar weight, and prove delayed margin positivity along the derived trajectory.
2. **From loss landscape to normal form.** Derive the quadratic vector field
   $\mu - x^2$ as the reduced dynamics of a concrete trained network near a
   degenerate critical point, making $\mu$ an optimizer or regularization parameter
   by *derivation* rather than by the parameter identification of Theorem 7.8.
3. **A classification theorem for exponents.** Prove (or refute) that logarithmic
   and $\mu^{-1/2}$ are the only delay laws attainable by generic smooth
   one-dimensional reductions — the exponent dichotomy conjecture. A falsification
   would be a smooth, nondegenerate family with delay $\sim \mu^{-1}$ or
   $\sim e^{1/\mu}$.
4. **Width laws beyond independence.** Extend Theorem 5.4 to weakly dependent or
   trained (hence correlated) hidden units, where $S_m/m$ need not converge to a
   deterministic limit.
5. **Counting relapses exactly.** Theorem 6.4 gives $\ge k+1$ components for width
   $3k$; determine the exact maximal number of connected components of the failure
   set of a width-$m$ two-layer ReLU network along a ray.
6. **Robustness in the bottleneck regime.** Combine Theorem 8.6 with Theorem 10.3 to
   show that the sharp constant $\pi$, and not merely the exponent $-1/2$, persists
   under uniform $\varepsilon$-perturbations of the vector field.

---

## 15. Conclusion

Delayed generalization, in the models analysed here, is a threshold-crossing
phenomenon with a computable threshold. Its sharpness comes from monotonicity and
survives worst-case aggregation over a test set; its permanence comes from the
convexity of a positively-weighted rectifier layer, and fails exactly when that
positivity fails. Its *length* obeys one of two laws. Threshold relaxation under
weight decay gives $\tau \sim \lambda_c^{-1}\log(1/\mu)$, with a genuine critical
decay $\lambda_c = s/\theta$ beyond which no transition occurs. A saddle-node
bottleneck gives $T \sim \pi\,|\mu|^{-1/2}$, with a constant independent of where
the passage is observed. Near criticality the second law dominates the first. Two
mechanisms, two exponents, two exact constants — $1/\lambda_c$ and $\pi$ — and a
measurement that tells them apart.
