# Exact Training Dynamics of Tropical $L^1$ Regression: Median Geometry, Finite Termination, Perturbation Radii, and a ReLU Width Dichotomy

**Author:** Aristotle
**Date:** 2026-08-09

---

## Abstract

We give a complete and exact theory of clipped subgradient descent for tropical $L^1$ regression. For a tropical monomial model with a single trainable parameter, the empirical absolute-error loss on $n$ reduced samples is $L(\theta) = \sum_{i<n} |\theta - x_i|$, and we derive all of its minimizer geometry from a single *counting* inequality: sliding the parameter across a pivot increases the loss at a rate equal to the imbalance between the sample blocks on the two sides, with equality on any slab that crosses no data point. From this one mechanism we obtain: (i) for odd sample size $2k+1$, the strengthened growth bound $L(x_k) + |\theta - x_k| \le L(\theta)$ and hence a unique minimizer at the sample median; (ii) for even sample size $2k+2$, the loss is constant on $[x_k, x_{k+1}]$ and grows with slope at least $2$ outside it, so the minimizer set is *exactly* that closed interval.

For the dynamics we show that the clipped update $\Phi_{m,t}$ forms a one-parameter semigroup, so the $n$-fold iterate of a step of size $\eta$ equals a single flow of duration $n\eta$; combined with the exact distance identity $|\Phi_{m,t}(x) - m| = \max(0, |x-m|-t)$ this yields finite termination at the exact optimum at time $\lceil |x_0-m|/\eta\rceil$, together with a matching lower bound (no earlier iterate is optimal) and an explicit excess-risk rate $\le n \max(0,|x_0-m| - n\eta)$ obtained from $n$-Lipschitzness of the loss. In the even case, the metric projection onto the optimal interval is a conserved quantity of the dynamics, which reduces interval descent to the scalar flow and gives finite termination at the projection of the initialization.

We then prove three extensions. **Robustness:** for per-step error at most $\varepsilon \le \eta$, the distance obeys $|u_n - m| \le \max(\varepsilon, |u_0-m| - n(\eta-\varepsilon))$; the trajectory enters the closed $\varepsilon$-ball in finite time and stays; and the saturation radius $\varepsilon$ is attained, so the naive bound with $\max(0,\cdot)$ is false. **Separability and boxes:** a general principle shows a separable objective is minimized exactly when each coordinate is, whence the $d$-parameter minimizer set is the coordinatewise median (odd samples) or a product box of central segments (even samples), and simultaneous descent halts at the projection onto that box in the maximum of the $d$ coordinatewise times. **Expressivity:** using a discrete second-difference (curvature) test we prove a kink-witness principle — a nonvanishing second difference over a window forces a rectified unit with its kink inside — and deduce exact ReLU widths for the training step itself: exactly two units when the optimum is a point, exactly four when it is a nondegenerate segment, both in the presence of an arbitrary affine skip connection. The width of the optimizer is thus a faithful invariant of the tropical minimizer geometry.

**Keywords:** tropical geometry, tropical regression, $L^1$ loss, sample median, subgradient descent, finite termination, ReLU networks, network width lower bounds, piecewise-linear maps.

---

## 1. Introduction

The tropical (max-plus) semiring $\mathbb{T} = (\mathbb{R}\cup\{-\infty\},\ \oplus,\ \otimes)$ with $a\oplus b = \max(a,b)$ and $a\otimes b = a+b$ is the algebraic home of a large family of piecewise-linear phenomena: shortest paths, scheduling, optimal transport, and — most relevant here — rectified neural networks. A network whose only nonlinearity is $\mathrm{relu}(x) = \max(x,0)$ computes a difference of tropical polynomials, and conversely; the two languages describe the same class of continuous piecewise-linear (CPL) maps.

This correspondence invites a question about *learning* rather than representation: what does a standard optimizer do when applied to a tropical model with a natural loss? The present work answers this completely for the smallest nontrivial case and for its immediate multi-parameter generalizations. The answers are unusually clean: every statement below is an identity or a two-sided bound with attained constants, rather than an asymptotic rate.

### 1.1 The model

A tropical monomial in one variable with a single parameter is
$$z \;\mapsto\; z \otimes \theta \;=\; z + \theta .$$
Given data $(z_j, y_j)_{j<n}$ and absolute-error loss, the $j$-th residual is $|(z_j+\theta) - y_j| = |\theta - x_j|$ with $x_j := y_j - z_j$. We call the $x_j$ the **reduced samples**; the entire one-parameter problem is thus equivalent to $L^1$ location estimation.

**Definition 1.1 (Tropical $L^1$ empirical loss).** For $n \in \mathbb{N}$, a sample $x : \mathbb{N}\to\mathbb{R}$ and $\theta\in\mathbb{R}$,
$$L_n(x;\theta) \;:=\; \sum_{i=0}^{n-1} |\theta - x_i| .$$

**Definition 1.2 (Sorted sample).** $x$ is *sorted up to $n$* if $x_i \le x_j$ whenever $i \le j < n$.

### 1.2 The optimizer

Subgradient descent on $L_n$ moves $\theta$ toward the median at a rate proportional to the block imbalance; the essential structural refinement is that the update be *clipped*, i.e. never overshoot the target.

**Definition 1.3 (Clipped tropical update / flow).** For target $m\in\mathbb{R}$ and time $t \ge 0$,
$$\Phi_{m,t}(x) \;:=\; \begin{cases} \min(m,\ x+t), & x < m,\\ \max(m,\ x-t), & x \ge m. \end{cases}$$

Two elementary identities drive everything:

**Proposition 1.4 (Exact distance law).** $\bigl|\Phi_{m,t}(x) - m\bigr| = \max\bigl(0,\ |x-m|-t\bigr)$, and $\Phi_{m,t}(x)=m$ if and only if $|x-m|\le t$.

**Proposition 1.5 (Semigroup law).** $\Phi_{m,0} = \mathrm{id}$ and, for $s \ge 0$, $\Phi_{m,s}\circ\Phi_{m,t} = \Phi_{m,t+s}$.

*Proof sketch.* Both are case analyses on the position of $x$ relative to $m$ and on which of the two arguments of $\min$/$\max$ is active; after expanding $\min$ and $\max$ by definition, every branch is a linear inequality. $\square$

**Corollary 1.6 (Discrete = continuous).** For $\eta\ge 0$ and $n\in\mathbb{N}$, $\Phi_{m,\eta}^{\,n} = \Phi_{m,\,n\eta}$.

Corollary 1.6 is the structural reason the theory is exact: the discretization of the clipped flow is *not* an approximation of it. There is no discretization error to control at any step size.

### 1.3 Contributions

1. A single **counting mechanism** (Theorems 2.1–2.3) from which all minimizer statements follow, with matching exact slab formulas showing no constant can be improved.
2. **Odd samples** (§3): a strengthened growth inequality, uniqueness of the median minimizer, finite termination at exactly $\lceil |x_0-m|/\eta\rceil$ steps with a matching lower bound, and an explicit excess-risk decay.
3. **Even samples** (§4): the minimizer set is *exactly* the central closed interval; the metric projection is conserved by interval descent, giving finite termination at the projection of the initialization.
4. **Robustness** (§5): a sharp perturbed-descent bound with saturation radius exactly $\varepsilon$, including a counterexample showing the radius is attained.
5. **Separability and boxes** (§6): a general separability principle; the $d$-dimensional minimizer set is a product box; simultaneous descent halts in the maximum of the coordinatewise times.
6. **Exact ReLU widths** (§7): a curvature/kink-witness method giving width lower bounds robust to affine skip connections, and a $2$-versus-$4$ dichotomy that reads the minimizer geometry off the architecture.

---

## 2. The counting mechanism

Fix $n$, a sample $x$, a pivot $p$ and a target $\theta$. Split the index range at $j$.

**Theorem 2.1 (Right-hand growth bound).** Let $j \le n$, $p \le \theta$, and suppose $x_i \le p$ for all $i < j$. Then
$$L_n(x;p) \;+\; \bigl(j - (n-j)\bigr)(\theta - p) \;\le\; L_n(x;\theta).$$

*Proof sketch.* Split $\sum_{i<n} = \sum_{i<j} + \sum_{j \le i < n}$. For $i<j$ we have $x_i \le p \le \theta$, so $|\theta-x_i| = |p-x_i| + (\theta-p)$ exactly, contributing $+j(\theta-p)$. For $i \ge j$ the reverse triangle inequality gives $|\theta - x_i| \ge |p-x_i| - |(p-x_i)-(\theta-x_i)| = |p-x_i| - (\theta-p)$, contributing at least $-(n-j)(\theta-p)$. Summing gives the claim. $\square$

**Theorem 2.2 (Left-hand growth bound).** Let $j \le n$, $\theta \le p$, and suppose $p \le x_i$ for all $j \le i < n$. Then
$$L_n(x;p) \;+\; \bigl((n-j) - j\bigr)(p - \theta) \;\le\; L_n(x;\theta).$$

The proof mirrors Theorem 2.1, with the roles of the two blocks exchanged.

**Theorem 2.3 (Exact slab formula).** If in addition to the hypotheses of Theorem 2.1 we have $\theta \le x_i$ for all $j \le i < n$ — that is, the move from $p$ to $\theta$ crosses no data point — then the inequality is an equality:
$$L_n(x;\theta) \;=\; L_n(x;p) + \bigl(j-(n-j)\bigr)(\theta-p).$$

*Proof sketch.* Under the extra hypothesis, the terms with $i \ge j$ satisfy $|\theta - x_i| = |p-x_i| - (\theta - p)$ exactly rather than merely $\ge$. $\square$

Theorem 2.3 is the sharpness statement behind every constant appearing below: on any slab between consecutive order statistics the loss is affine with slope exactly $j - (n-j)$, where $j$ is the number of samples below the slab.

Finally, a global regularity statement used for risk rates.

**Proposition 2.4 (Lipschitz control).** $\bigl|L_n(x;\theta) - L_n(x;\theta')\bigr| \le n\,|\theta - \theta'|$.

*Proof sketch.* Termwise, $\bigl||\theta-x_i| - |\theta'-x_i|\bigr| \le |\theta-\theta'|$; sum and apply the triangle inequality for sums. $\square$

---

## 3. Odd samples: a unique median and exact termination

Throughout this section $n = 2k+1$ and $x$ is sorted up to $n$; write $m := x_k$ for the sample median.

**Theorem 3.1 (Odd-sample linear growth).** For every $\theta \in \mathbb{R}$,
$$L_{2k+1}(x;m) + |\theta - m| \;\le\; L_{2k+1}(x;\theta).$$

*Proof sketch.* If $\theta \ge m$, apply Theorem 2.1 with pivot $p=m$ and $j = k+1$: the $k+1$ indices $i \le k$ satisfy $x_i \le x_k = m$ by sortedness, and the coefficient is $(k+1)-k = 1$. If $\theta \le m$, apply Theorem 2.2 with $j = k$: the indices $i \ge k$ satisfy $x_i \ge m$, and the coefficient is $(k+1)-k = 1$. In both cases the displacement equals $|\theta - m|$. $\square$

**Corollary 3.2 (Uniqueness).** $\theta$ minimizes $L_{2k+1}(x;\cdot)$ if and only if $\theta = m$.

*Proof sketch.* Sufficiency is immediate from Theorem 3.1 and $|\theta-m|\ge0$. For necessity, minimality at $\theta$ applied to the comparison point $m$ gives $L(\theta) \le L(m)$, while Theorem 3.1 gives $L(m)+|\theta-m| \le L(\theta)$; hence $|\theta-m|\le 0$. $\square$

**Theorem 3.3 (Sharpness of the growth constant).** For $m \le \theta \le x_{k+1}$,
$$L_{2k+1}(x;\theta) = L_{2k+1}(x;m) + (\theta - m).$$

*Proof sketch.* Theorem 2.3 with $j = k+1$; the extra hypothesis holds because $\theta \le x_{k+1} \le x_i$ for $i \ge k+1$. $\square$

### 3.1 Exact stopping time

**Theorem 3.4 (Termination criterion).** For $\eta>0$, $x_0 \in \mathbb{R}$, and $n\in\mathbb{N}$,
$$\Phi_{m,\eta}^{\,n}(x_0) = m \quad \Longleftrightarrow \quad |x_0 - m| \le n\eta.$$

*Proof sketch.* By Corollary 1.6 the left side equals $\Phi_{m,n\eta}(x_0)=m$, which by Proposition 1.4 holds iff $|x_0-m| \le n\eta$. $\square$

**Theorem 3.5 (Exact stopping time, with lower bound).** For $\eta>0$, with $N := \lceil |x_0-m|/\eta\rceil$,
$$\Phi_{m,\eta}^{\,N}(x_0) = m, \qquad \text{and} \qquad \Phi_{m,\eta}^{\,n}(x_0) \neq m \ \text{ for all } n < N.$$

*Proof sketch.* For the first claim, $N \ge |x_0-m|/\eta$ gives $N\eta \ge |x_0-m|$; apply Theorem 3.4. For the second, $n<N$ means $n < |x_0-m|/\eta$, so $n\eta < |x_0-m|$, and Theorem 3.4 forbids termination. $\square$

**Theorem 3.6 (Odd-sample training theorem).** Let $x$ be sorted up to $2k+1$, $\eta>0$, $x_0\in\mathbb{R}$, and $N = \lceil |x_0 - x_k|/\eta\rceil$. Then clipped subgradient descent reaches the parameter $x_k$ at step $N$ and at no earlier step, and $x_k$ is the unique minimizer of the tropical $L^1$ empirical loss.

**Theorem 3.7 (Excess-risk rate).** For $\eta \ge 0$ and every $n$, writing $\theta_n := \Phi_{x_k,\eta}^{\,n}(x_0)$,
$$0 \;\le\; L_{2k+1}(x;\theta_n) - L_{2k+1}(x;x_k) \;\le\; (2k+1)\,\max\bigl(0,\ |x_0-x_k| - n\eta\bigr).$$

*Proof sketch.* The lower bound is Corollary 3.2. For the upper bound, Proposition 2.4 with $\theta = \theta_n$, $\theta' = x_k$ and $n$-Lipschitz constant $2k+1$, combined with the exact distance law $|\theta_n - x_k| = \max(0, |x_0-x_k| - n\eta)$ from Proposition 1.4 and Corollary 1.6. $\square$

The bound is exactly zero from step $N$ onward, consistent with Theorem 3.5.

**Example 3.8.** For $x = (-3,-1,0,4,9)$ we have $k=2$, $m = 0$, $L(0)=17$, $L(1) = L(-1) = 18$, in agreement with Theorem 3.3 (slope $1$ on either side of the median in the central slabs). Descent from $x_0 = 5$ with $\eta = 2$ terminates at step $\lceil 5/2 \rceil = 3$: the iterates are $5 \to 3 \to 1 \to 0$.

---

## 4. Even samples: the minimizer set is a segment

Throughout this section $n = 2k+2$ and $x$ is sorted up to $n$; write $\ell := x_k$, $h := x_{k+1}$.

**Theorem 4.1 (Constancy on the central interval).** For $\ell \le \theta \le h$,
$$L_{2k+2}(x;\theta) \;=\; \sum_{i=k+1}^{2k+1} x_i \;-\; \sum_{i=0}^{k} x_i,$$
a value independent of $\theta$.

*Proof sketch.* Split at $k+1$. For $i \le k$, $x_i \le \ell \le \theta$, so $|\theta-x_i| = \theta - x_i$ and the lower block sums to $(k+1)\theta - \sum_{i \le k}x_i$. For $i \ge k+1$, $\theta \le h \le x_i$, so $|\theta-x_i| = x_i - \theta$ and the upper block sums to $\sum_{i \ge k+1}x_i - (k+1)\theta$. The $\theta$-terms cancel. $\square$

**Theorem 4.2 (Slope-two growth outside).** For $\theta \ge h$: $L(h) + 2(\theta - h) \le L(\theta)$. For $\theta \le \ell$: $L(\ell) + 2(\ell-\theta) \le L(\theta)$.

*Proof sketch.* Theorem 2.1 with pivot $h$ and $j = k+2$ gives coefficient $(k+2)-k = 2$; Theorem 2.2 with pivot $\ell$ and $j = k$ gives coefficient $(k+2)-k=2$. $\square$

**Theorem 4.3 (Even-sample minimizer interval).** $\theta$ minimizes $L_{2k+2}(x;\cdot)$ if and only if $\theta \in [\ell, h]$.

*Proof sketch.* By Theorem 4.1 the loss takes a common value $c$ on $[\ell,h]$; by Theorem 4.2 it is $\ge c$ strictly outside (with strict excess $2\,\mathrm{dist}(\theta,[\ell,h])$). Hence $[\ell,h]$ is exactly the argmin. $\square$

### 4.1 Descent onto a segment

**Definition 4.4.** The metric projection onto $[\ell,h]$ is $\pi_{\ell,h}(\theta) := \max(\ell, \min(h,\theta))$; the **interval update** with step $\eta$ is
$$S_{\ell,h,\eta}(\theta) := \Phi_{\pi_{\ell,h}(\theta),\ \eta}(\theta).$$

**Lemma 4.5.** If $\ell \le h$ then $\pi_{\ell,h}(\theta) \in [\ell,h]$; points of $[\ell,h]$ are fixed by $S_{\ell,h,\eta}$ (for $\eta\ge0$).

**Theorem 4.6 (Projection is conserved).** For $\eta\ge0$ and $\ell\le h$, $\pi_{\ell,h}\bigl(S_{\ell,h,\eta}(\theta)\bigr) = \pi_{\ell,h}(\theta)$, and hence $\pi_{\ell,h}\bigl(S^{\,n}_{\ell,h,\eta}(\theta)\bigr) = \pi_{\ell,h}(\theta)$ for all $n$.

*Proof sketch.* A case analysis: if $\theta<\ell$ the step moves right by $\eta$ but is clipped at $\ell$, so the image is still $\le \ell$ or equal to $\ell$, and projects to $\ell$; symmetrically on the right; inside the interval nothing moves. $\square$

**Theorem 4.7 (Closed form and exact distance).** For $\eta \ge 0$, $\ell\le h$, $n\in\mathbb{N}$,
$$S^{\,n}_{\ell,h,\eta}(\theta) = \Phi_{\pi_{\ell,h}(\theta),\ n\eta}(\theta), \qquad \bigl|S^{\,n}_{\ell,h,\eta}(\theta) - \pi_{\ell,h}(\theta)\bigr| = \max\bigl(0,\ |\theta - \pi_{\ell,h}(\theta)| - n\eta\bigr).$$

*Proof sketch.* Induction on $n$: the inductive step rewrites the target of the $(n{+}1)$-st update using Theorem 4.6 and then applies the semigroup law (Proposition 1.5). The distance identity is Proposition 1.4 applied to the closed form. $\square$

**Theorem 4.8 (Even-sample descent theorem).** Let $x$ be sorted up to $2k+2$, $\eta>0$, $\theta\in\mathbb{R}$. Then for all
$$n \;\ge\; \Bigl\lceil \bigl|\theta - \pi_{\ell,h}(\theta)\bigr| / \eta \Bigr\rceil$$
we have $S^{\,n}_{\ell,h,\eta}(\theta) = \pi_{\ell,h}(\theta)$, and this point is an exact minimizer of the tropical $L^1$ loss.

*Proof sketch.* The reach statement follows from Theorem 4.7 and $\lceil c\rceil \eta \ge c\eta$; optimality follows from $\pi_{\ell,h}(\theta) \in [\ell,h]$ (Lemma 4.5) and Theorem 4.3. $\square$

Thus in the even case the *initialization selects the optimum*: descent halts at the point of the optimal segment nearest to where it started, after a number of steps equal to that distance divided by $\eta$, rounded up.

**Example 4.9.** For $x = (-3,-1,2,5)$ we get $k=1$, $[\ell,h] = [-1,2]$, and $L(\theta) = 11$ for all $\theta\in[-1,2]$, while $L(3) = 13 = 11 + 2\cdot 1$ — precisely the slope-two growth of Theorem 4.2.

---

## 5. Perturbed descent: a sharp saturation radius

Real optimizers are noisy: gradients are estimated, arithmetic is rounded, updates are asynchronous. We model this by allowing an arbitrary bounded deviation from the ideal update.

**Definition 5.1 ($\varepsilon$-perturbed trajectory).** A sequence $u:\mathbb{N}\to\mathbb{R}$ is $\varepsilon$-perturbed for target $m$ and step $\eta$ if $|u_{n+1} - \Phi_{m,\eta}(u_n)| \le \varepsilon$ for all $n$.

**Lemma 5.2 (One-step contraction).** For an $\varepsilon$-perturbed trajectory, $|u_{n+1}-m| \le \varepsilon + \max(0, |u_n - m| - \eta)$.

*Proof sketch.* Triangle inequality through $\Phi_{m,\eta}(u_n)$, then Proposition 1.4. $\square$

**Theorem 5.3 (Perturbed tropical limit).** If $\varepsilon \le \eta$ then for every $n$,
$$|u_n - m| \;\le\; \max\Bigl(\varepsilon,\ |u_0 - m| - n(\eta - \varepsilon)\Bigr).$$

*Proof sketch.* Induction on $n$ using Lemma 5.2. Both the induction hypothesis and the one-step bound involve a $\max$; splitting into the four resulting cases, each is a linear (or, in one case, mildly nonlinear) arithmetic consequence of $\varepsilon \le \eta$. Intuitively: outside the $\varepsilon$-ball the ideal step gains $\eta$ and the noise can give back at most $\varepsilon$, so the net gain per step is at least $\eta - \varepsilon$; inside, the bound saturates at $\varepsilon$. $\square$

**Corollary 5.4 (Clean bound outside the ball).** If $\varepsilon \le \eta$ and $|u_n - m| > \varepsilon$, then $|u_n-m| \le |u_0-m| - n(\eta-\varepsilon)$.

**Theorem 5.5 (Absorption).** If $0 \le \varepsilon < \eta$ then there is $N$ with $|u_n - m| \le \varepsilon$ for all $n \ge N$; one may take any $N > |u_0-m|/(\eta-\varepsilon)$.

*Proof sketch.* For such $N$ the second argument of the maximum in Theorem 5.3 is $< \varepsilon$ for all $n \ge N$, so the maximum is $\varepsilon$. $\square$

**Theorem 5.6 (The radius $\varepsilon$ is attained; $\max(0,\cdot)$ is false).** For $0<\varepsilon\le\eta$ the constant sequence $u_n \equiv m+\varepsilon$ is an $\varepsilon$-perturbed trajectory with $|u_n - m| = \varepsilon$ for all $n$.

*Proof sketch.* $\Phi_{m,\eta}(m+\varepsilon) = \max(m, m+\varepsilon-\eta) = m$ because $\varepsilon \le \eta$; hence $|u_{n+1} - \Phi_{m,\eta}(u_n)| = |m+\varepsilon - m| = \varepsilon$, which is permitted. $\square$

Theorem 5.6 shows the guarantee of Theorem 5.3 is qualitatively optimal: the perturbed dynamics does *not* converge to the minimizer, only to its closed $\varepsilon$-neighbourhood, and that neighbourhood is exactly the right size. Together with Corollary 5.4, one obtains the complete picture: linear approach at effective speed $\eta - \varepsilon$ until the $\varepsilon$-ball, then permanent residence at radius at most $\varepsilon$, with radius exactly $\varepsilon$ achievable.

---

## 6. Many parameters: separability, medians and boxes

### 6.1 A separability principle

**Theorem 6.1 (Separability principle).** Let $F_1,\dots,F_d : \mathbb{R}\to\mathbb{R}$ and $\theta \in \mathbb{R}^d$. Then
$$\Bigl(\forall y \in \mathbb{R}^d:\ \sum_i F_i(\theta_i) \le \sum_i F_i(y_i)\Bigr) \quad \Longleftrightarrow \quad \Bigl(\forall i,\ \forall t\in\mathbb{R}:\ F_i(\theta_i) \le F_i(t)\Bigr).$$

*Proof sketch.* ($\Rightarrow$) Given $i$ and $t$, compare $\theta$ with the vector that agrees with $\theta$ except in coordinate $i$ where it takes the value $t$; all terms $j \ne i$ cancel, leaving $F_i(\theta_i)\le F_i(t)$. ($\Leftarrow$) Sum the coordinatewise inequalities. $\square$

Elementary as it is, this is the exact statement needed to lift every scalar result to $d$ parameters *without loss*, and it is the loss-side shadow of the fact that the dynamics also factors coordinatewise.

### 6.2 Odd samples in $d$ coordinates

**Definition 6.2.** For $k \in \mathbb{N}^d$ and samples $x^{(1)},\dots,x^{(d)}$, the separable loss and coordinatewise median are
$$L^{\mathrm{sep}}(\theta) := \sum_{i=1}^d L_{2k_i+1}\bigl(x^{(i)};\theta_i\bigr), \qquad m_i := x^{(i)}_{k_i};$$
simultaneous clipped descent is $V_\eta(\theta)_i := \Phi_{m_i,\eta}(\theta_i)$.

**Theorem 6.3.** If each $x^{(i)}$ is sorted up to $2k_i+1$, then
$$L^{\mathrm{sep}}(m) + \sum_i |\theta_i - m_i| \le L^{\mathrm{sep}}(\theta),$$
and $\theta$ minimizes $L^{\mathrm{sep}}$ if and only if $\theta = m$.

*Proof sketch.* Sum Theorem 3.1 over coordinates; for uniqueness, a vanishing sum of nonnegative terms has all terms zero. $\square$

**Theorem 6.4 (Vector termination time).** For $\eta>0$, $V_\eta^{\,n}(\theta) = m$ if and only if $|\theta_i - m_i| \le n\eta$ for all $i$. Consequently, with $N := \max_i \lceil |\theta_i - m_i|/\eta\rceil$, we have $V_\eta^{\,N}(\theta) = m$ and $V_\eta^{\,n}(\theta) \ne m$ for all $n<N$.

*Proof sketch.* Iterates act coordinatewise, so this is Theorem 3.4 applied in each coordinate; the maximum over coordinates of the scalar stopping times is the vector stopping time, and if $n$ is below the maximum then some coordinate has not yet arrived, by the scalar lower bound of Theorem 3.5. $\square$

Thus the *slowest coordinate sets the clock*, exactly.

### 6.3 Even samples in $d$ coordinates: the minimizer box

**Definition 6.5.** For even samples, $L^{\mathrm{box}}(\theta) := \sum_{i=1}^d L_{2k_i+2}(x^{(i)};\theta_i)$, with corners $\ell_i := x^{(i)}_{k_i}$, $h_i := x^{(i)}_{k_i+1}$, and the simultaneous interval update $B_\eta(\theta)_i := S_{\ell_i,h_i,\eta}(\theta_i)$.

**Theorem 6.6 (The minimizer set is a box).** If each $x^{(i)}$ is sorted up to $2k_i+2$, then $\theta$ minimizes $L^{\mathrm{box}}$ if and only if
$$\theta \in \prod_{i=1}^{d} \bigl[\ell_i,\ h_i\bigr].$$

*Proof sketch.* Theorem 6.1 reduces global minimality to coordinatewise minimality; Theorem 4.3 identifies each coordinate's minimizer set as $[\ell_i,h_i]$. $\square$

**Theorem 6.7 (Box descent terminates at the projection).** Let $\eta>0$ and $\ell_i \le h_i$ for all $i$. Then for all
$$n \;\ge\; \max_{i} \Bigl\lceil \bigl|\theta_i - \pi_{\ell_i,h_i}(\theta_i)\bigr|/\eta \Bigr\rceil,$$
we have $B_\eta^{\,n}(\theta) = \bigl(\pi_{\ell_i,h_i}(\theta_i)\bigr)_{i=1}^d$, the metric projection of $\theta$ onto the box.

*Proof sketch.* Iterates act coordinatewise (immediate induction), so apply Theorem 4.7 in each coordinate; membership of $n$ above the maximum of the ceilings gives $n\eta \ge |\theta_i - \pi_i(\theta_i)|$ for every $i$. $\square$

**Theorem 6.8 (Even-sample vector training theorem).** Under the hypotheses of Theorems 6.6 and 6.7, there exists $N$ such that for all $n \ge N$, the $n$-th iterate of simultaneous clipped descent equals the projection of the initialization onto the minimizer box *and* is an exact minimizer of $L^{\mathrm{box}}$.

*Proof sketch.* Combine Theorem 6.7 (the iterate is the projection) with Theorem 6.6 (the projection lies in the box, hence is optimal). $\square$

**Example 6.9.** Two coordinates with four-point samples $(-3,-1,2,5)$ and $(0,1,1,4)$ give the minimizer box $[-1,2]\times[1,1]$: a segment in the first coordinate, a degenerate point in the second (its two central order statistics coincide). Descent from any initialization lands on the nearest point of this box in finitely many steps.

---

## 7. Exact ReLU width of the training step

We now turn from dynamics to expressivity. Since every map considered is continuous piecewise linear, each *is* a small ReLU network; the question is how small, and the answer turns out to encode the minimizer geometry.

**Definition 7.1 (Width-$k$ network with affine skip).** For $a,b,c \in \mathbb{R}^k$ and $p,q \in \mathbb{R}$,
$$N_{a,b,c,p,q}(x) := \sum_{j=1}^{k} a_j\,\mathrm{relu}(b_j x + c_j) \;+\; px + q .$$

The affine skip term $px+q$ is included deliberately: lower bounds that survive it are considerably stronger, since a linear bypass can absorb global slope for free.

### 7.1 The curvature test

**Lemma 7.2 (A rectified unit is flat off its kink).** If $|v| \le |u|$ then $\mathrm{relu}(u+v)+\mathrm{relu}(u-v)-2\,\mathrm{relu}(u) = 0$.

*Proof sketch.* If $u \ge 0$ then $u\pm v \ge 0$ and all three rectifications are the identity; if $u \le 0$ then $u \pm v \le 0$ and all three vanish. $\square$

**Theorem 7.3 (Networks are affine off all kinks).** Let $h \ge 0$ and suppose $|b_j|\,h \le |b_j x + c_j|$ for every $j$ (no unit's kink lies strictly inside the window of radius $h$ at $x$). Then
$$N(x+h) + N(x-h) - 2N(x) = 0 .$$

*Proof sketch.* Apply Lemma 7.2 to each unit with $u = b_jx+c_j$, $v = b_jh$; the skip term $px+q$ has vanishing second difference identically. $\square$

**Corollary 7.4 (Kink-witness principle).** If $h \ge 0$ and $N(x+h)+N(x-h)-2N(x) \ne 0$, then some unit $j$ satisfies $|b_j x + c_j| < |b_j|\,h$, i.e. its kink $-c_j/b_j$ lies strictly inside $(x-h, x+h)$.

This is the contrapositive of Theorem 7.3, and it is remarkably cheap: it requires no convexity, no differentiability, and no sign conditions on the network parameters.

**Lemma 7.5 (Window separation).** If a single unit $(b,c)$ has its kink inside both the radius-$h$ window at $x$ and the radius-$h$ window at $y$, then $|x-y| < 2h$.

*Proof sketch.* From $|bx+c| < |b|h$ we get $b \ne 0$; then $|b|\,|x-y| = |(bx+c)-(by+c)| \le |bx+c|+|by+c| < 2|b|h$, and divide by $|b|>0$. $\square$

Corollary 7.4 plus Lemma 7.5 yields the general method: **exhibit $r$ points with pairwise distances at least $2h$ at which the target map has nonvanishing second difference over radius $h$; conclude $k \ge r$.**

### 7.2 The scalar update: width exactly two

**Theorem 7.6 (Lower bound two).** Let $t>0$. If $N_{a,b,c,p,q} = \Phi_{m,t}$ on all of $\mathbb{R}$, then $k \ge 2$.

*Proof sketch.* Take $h = t/2$. At $x = m-t$ the values of $\Phi_{m,t}$ at $x-h, x, x+h$ are $m-h, m, m$, so the second difference is $(m)+(m-h)-2m = -h \ne 0$. At $x = m+t$ they are $m, m, m+h$, giving second difference $h \ne 0$. The two centers are $2t = 4h \ge 2h$ apart, so by Corollary 7.4 and Lemma 7.5 the two witnessing units are distinct. $\square$

**Theorem 7.7 (Two units suffice).** For $t \ge 0$ and all $x$,
$$\Phi_{m,t}(x) = m + \mathrm{relu}(x-m-t) - \mathrm{relu}(m-x-t).$$
Equivalently $\Phi_{m,t} = N_{a,b,c,0,m}$ with $a = (1,-1)$, $b=(1,-1)$, $c = (-(m+t),\,m-t)$.

**Theorem 7.8 (Exact width two).** For $t>0$ the clipped tropical update is realized by a width-two network and by no narrower one, even allowing an arbitrary affine skip.

A complementary, weaker argument is also available and instructive: a single unit $x\mapsto a\,\mathrm{relu}(bx+c)+e$ is convex (if $a\ge0$) or concave (if $a\le0$), whereas $\Phi_{m,t}$ rises, is flat on $[m-t,m+t]$, and rises again — so it is neither. Formally, midpoint convexity of $\mathrm{relu}$ contradicts the sampled values at $m-2t, m-t, m$ in the convex case and at $m, m+t, m+2t$ in the concave case. This argument does not survive the addition of a skip term; the curvature method does.

### 7.3 The interval update: width exactly four

**Theorem 7.9 (Explicit four-unit form).** For $\ell \le h$ and $\eta \ge 0$, for all $\theta$,
$$S_{\ell,h,\eta}(\theta) = \theta + \eta - \mathrm{relu}\bigl(\theta - (\ell-\eta)\bigr) + \mathrm{relu}(\theta-\ell) - \mathrm{relu}(\theta - h) + \mathrm{relu}\bigl(\theta - (h+\eta)\bigr).$$

*Proof sketch.* Five regions, delimited by the four kinks $\ell-\eta < \ell \le h < h+\eta$. On each region, evaluate the update via its explicit piecewise form — $S(\theta) = \min(\ell, \theta+\eta)$ for $\theta \le \ell$, $S(\theta)=\theta$ for $\theta\in[\ell,h]$, $S(\theta)=\max(h,\theta-\eta)$ for $\theta \ge h$ — and evaluate each rectification as either $0$ or its argument. Each of the five identities is then a polynomial identity. $\square$

**Theorem 7.10 (Lower bound four).** Let $\ell<h$ and $\eta>0$. If $N_{a,b,c,p,q} = S_{\ell,h,\eta}$ on all of $\mathbb{R}$, then $k \ge 4$.

*Proof sketch.* Take $h_0 := \min(\eta,\,h-\ell)/2 > 0$, so that consecutive kinks among $\ell-\eta<\ell<h<h+\eta$ are at least $2h_0$ apart. Evaluate $S$ at the twelve points $c \pm h_0, c$ for $c \in \{\ell-\eta,\ \ell,\ h,\ h+\eta\}$:
at $\ell-\eta$ the values are $(\ell-h_0,\ \ell,\ \ell)$, second difference $+h_0$;
at $\ell$: $(\ell,\ \ell,\ \ell+h_0)$, second difference $+h_0$;
at $h$: $(h-h_0,\ h,\ h)$, second difference $-h_0$;
at $h+\eta$: $(h,\ h,\ h+h_0)$, second difference $+h_0$.
All four are nonzero, so Corollary 7.4 produces four witnessing units, pairwise distinct by Lemma 7.5 since the four centers are pairwise at least $2h_0$ apart. A set of four distinct indices in $\{1,\dots,k\}$ forces $k\ge4$. $\square$

**Theorem 7.11 (Exact width four).** For $\ell<h$, $\eta>0$: four units with an affine skip realize $S_{\ell,h,\eta}$ exactly (Theorem 7.9, with $a = (-1,1,-1,1)$, $b=(1,1,1,1)$, $c = (\eta-\ell,\,-\ell,\,-h,\,-(h+\eta))$, $p=1$, $q=\eta$), and no network of fewer units can.

### 7.4 The width dichotomy

The degenerate case unifies the two parities.

**Lemma 7.12.** $S_{m,m,\eta} = \Phi_{m,\eta}$: a degenerate interval reproduces the scalar clipped update.

**Theorem 7.13 (Width dichotomy).** Let $\ell \le h$ and $\eta>0$. One clipped descent step toward the tropical $L^1$ minimizer set $[\ell,h]$ has exact ReLU width (with an arbitrary affine skip permitted)
$$\mathrm{width}\bigl(S_{\ell,h,\eta}\bigr) = \begin{cases} 2, & \ell = h \ \ (\text{minimizer set is a point}),\\ 4, & \ell < h \ \ (\text{minimizer set is a nondegenerate segment}).\end{cases}$$

*Proof sketch.* If $\ell=h$, Lemma 7.12 and Theorem 7.8. If $\ell<h$, Theorem 7.11. $\square$

Since the parity of the sample size decides whether the minimizer set is a point or a segment (Corollary 3.2 versus Theorem 4.3), Theorem 7.13 says the minimal architecture implementing one training step *detects the parity structure of the data*. The width is an invariant of the tropical minimizer geometry, not an artifact of the particular formula used to write the update.

---

## 8. Algorithms

Three procedures summarize the constructive content.

**Algorithm A (Exact tropical training, odd samples).**
Given sorted reduced samples $x_0\le\cdots\le x_{2k}$, initialization $\theta_0$, step $\eta>0$:
compute $m := x_k$; compute $N := \lceil |\theta_0-m|/\eta\rceil$; return $m$ and $N$.
By Theorem 3.5 this is exactly what the iteration would produce, at exactly the step it would produce it. Cost: $O(n)$ after sorting (or $O(n)$ total via linear-time selection), versus $O(N)$ for naive iteration.

**Algorithm B (Exact tropical training, even samples / boxes).**
Given per-coordinate sorted samples of even sizes $2k_i+2$: set $\ell_i := x^{(i)}_{k_i}$, $h_i := x^{(i)}_{k_i+1}$; return the box $\prod_i[\ell_i,h_i]$, the projection $\theta^\star_i = \max(\ell_i,\min(h_i,\theta_{0,i}))$, and the stopping time $N = \max_i\lceil|\theta_{0,i}-\theta^\star_i|/\eta\rceil$. Justified by Theorems 6.6–6.8. Cost $O(\sum_i n_i)$ after sorting.

**Algorithm C (Width-optimal ReLU compilation of a training step).**
Given $\ell\le h$ and $\eta>0$: if $\ell=h$ emit the two-unit network of Theorem 7.7; else emit the four-unit network of Theorem 7.9. By Theorem 7.13 the emitted width is minimal.

---

## 9. Discussion

**Why everything is exact.** Three structural facts conspire. First, the loss is piecewise affine with integer slopes given by block imbalances (Theorems 2.1–2.3), so its minimizer set is a face of a subdivision — a vertex in the odd case, an edge in the even case. Second, the clipped update is a genuine one-parameter semigroup (Proposition 1.5), so iteration is time-reparametrization rather than approximation; there is no step-size restriction and no discretization error at any $\eta>0$. Third, the distance-to-target law is an identity (Proposition 1.4) rather than a contraction estimate, which is why both the upper bound *and* the matching lower bound on the stopping time come out for free.

**Comparison with classical subgradient theory.** For a general convex nonsmooth objective, subgradient descent with a fixed step converges only to an $O(\eta)$-neighbourhood of the optimum, and the standard rate is $O(1/\sqrt{n})$ in function value. Here, by contrast, the clipping makes the optimum an exact fixed point, and the theory delivers finite termination at an exact optimum for *every* positive step. Theorem 5.6 shows this is exactly as fragile as one would expect and no more: under $\varepsilon$-noise, the guarantee degrades to a terminal radius of exactly $\varepsilon$ and an effective speed of exactly $\eta-\varepsilon$.

**The role of parity.** Sample parity is usually a footnote in median estimation. In the tropical setting it becomes structural: it determines whether the argmin is $0$- or $1$-dimensional, whether the terminal parameter is initialization-independent or initialization-selected, and — via Theorem 7.13 — the exact width of the smallest network that computes the training step. The odd case has a unique optimum and a canonical answer; the even case has an optimal face and the algorithm performs an implicit *minimum-norm-change* selection on it.

**Kink counting as a width method.** Corollary 7.4 with Lemma 7.5 is a general-purpose lower-bound technique for shallow rectified networks representing a CPL map: any $r$ pairwise $2h$-separated points with nonvanishing radius-$h$ second difference force width $\ge r$. It is immune to affine skip connections and requires no global shape hypothesis. The two instances proved here, $r = 2$ and $r=4$, are the two smallest, and both are tight.

---

## 10. Future directions

**1. Width equals the number of curvature sites.** Conjecture: if $f:\mathbb{R}\to\mathbb{R}$ is continuous piecewise linear with exactly $r$ kinks, then the minimal width $k$ for which $f = N_{a,b,c,p,q}$ is exactly $r$. The kink-witness principle already converts a nonvanishing second difference into a *distinct* unit whenever the test windows are disjoint, so the lower bound $r \le k$ needs no convexity, differentiability, or sign pattern — only separation of kinks; the matching upper bound should follow from the telescoping construction used in Theorem 7.9. The two smallest instances ($r=2$ and $r=4$) are proved here by the same mechanism, and the dichotomy of Theorem 7.13 shows the width is a genuine invariant of the tropical minimizer geometry rather than an artifact of the formula.

**2. Tropical width spectrum of $d$-dimensional box descent.** Conjecture: for the separable box update on $d$ coordinates with $s := \#\{i : \ell_i < h_i\}$ nondegenerate coordinates, the total rectified width required to implement one simultaneous step as a map $\mathbb{R}^d\to\mathbb{R}^d$ built from scalar units with arbitrary affine skips is exactly $2d + 2s$. Separability makes the curvature test coordinatewise — the separability principle is the loss-side shadow of the same phenomenon — so the widths should add: $2$ per degenerate coordinate and $4$ per nondegenerate one. The $d$-dimensional dynamics is already known to factor exactly through the $d$ scalar ones, and the scalar widths $2$ and $4$ are theorems, so the only missing ingredient is the $d$-dimensional counting argument.

**3. Perturbed descent has a sharp asymptotic radius equal to $\varepsilon$.** Conjecture: for every $0\le\varepsilon<\eta$ and every $\varepsilon$-perturbed trajectory, $\limsup_n |u_n - m| \le \varepsilon$, with equality attained by some trajectory, so that the supremum over trajectories of $\limsup_n|u_n-m|$ equals $\varepsilon$; moreover the loss excess satisfies $\limsup_n\bigl(L(u_n)-L(m)\bigr) = n_{\text{samples}}\cdot\varepsilon$ for a sample whose median has full one-sided multiplicity.

**4. Odd-sample extension in full generality.** For every odd sample size $2k+1$, clipped unit-step subgradient descent on the scalar tropical $L^1$ empirical loss reaches the unique sample median after at most $\lceil|\theta_0-m|/\eta\rceil$ iterations for every $\eta>0$.

**5. Vector tropical monomials.** For a separable $d$-parameter tropical affine model with coordinatewise three-point losses, simultaneous clipped descent terminates after at most the maximum of the $d$ coordinatewise termination times.

**6. Perturbed tropical limit, quantitatively.** If each tropical update is perturbed by an error of magnitude at most $\varepsilon<\eta$, then the parameter distance after $n$ steps is at most $\max\bigl(0,\ |\theta_0-m|-n(\eta-\varepsilon)\bigr)$ until the trajectory enters the closed $\varepsilon$-neighbourhood of the minimizer.

**7. Even-sample minimizer interval in the perturbed and stochastic regimes.** For $2k$ ordered scalar residual targets the tropical $L^1$ minimizers form the interval between the two central order statistics and clipped descent reaches it in finite time for every positive step size; the corresponding statements under sampling noise, and the induced distribution of the terminal point on the optimal face, remain open.

---

## 11. Conclusion

For tropical $L^1$ regression, training is not an approximation process. A single counting inequality determines the entire minimizer geometry — a point for odd samples, a segment for even ones, a product box in the separable multi-parameter setting. A semigroup identity turns iterated clipped subgradient descent into an exactly solvable flow, giving finite termination at an exact optimum with a stopping time that is simultaneously an upper and a lower bound. Noise degrades this in a completely quantified way, with a saturation radius that is attained. And the same piecewise-linear rigidity that makes the dynamics solvable makes the *architecture* of the update rule an invariant: exactly two rectified units when the optimum is a point, exactly four when it is a segment. Optimization geometry and network width, in this setting, are two readings of the same combinatorial data.
