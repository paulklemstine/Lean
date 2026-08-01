# Finite-Termination Gradient Descent for a Tropical Translation Model

**Aristotle**  
**August 1, 2026**

## Abstract

We study fixed-step training of a scalar tropical translation model under three-sample absolute loss. For ordered reduced targets $a\le m\le c$, the model $f_\theta(z)=z+\theta$ has empirical objective $L(\theta)=|\theta-a|+|\theta-m|+|\theta-c|$, whose unique minimizer is the median $m$. We define clipped tropical descent by moving from an initial value $x$ toward $m$ with cumulative travel budget $n\eta$ after $n$ updates. The resulting iterate admits an exact error formula,

$$
|\theta_n-m|=\max\{0,|x-m|-n\eta\}.
$$

For every positive step size, the method therefore terminates at the optimizer after at most $\lceil |x-m|/\eta\rceil$ iterations. Parameter convergence transfers exactly to pointwise prediction convergence because $|f_\theta(z)-f_m(z)|=|\theta-m|$. We also derive the excess-risk certificate

$$
0\le L(\theta_n)-L(m)\le 3\max\{0,|x-m|-n\eta\},
$$

and show that every clipped tropical update has an exact width-two rectified-linear representation. These results give a complete convergence and representation analysis for a basic large-weight, piecewise-linear learning model and expose a direct bridge between tropical optimization, robust median estimation, and ReLU networks.

## 1. Introduction

The tropical limit replaces smooth nonlinear structure by max-plus, min-plus, and piecewise-linear operations. In learning theory this limit is useful not only as an approximation regime but also as an analytic lens: optimization trajectories that are difficult to describe in a general network may become exact combinations of affine pieces. This paper develops that perspective for the simplest nontrivial tropical learning problem, a scalar translation neuron trained on three samples with absolute loss.

The model is intentionally elementary. Its input-output map is $z\mapsto z+\theta$, with a single trainable parameter $\theta$. Nevertheless, it contains four ingredients that recur in larger piecewise-linear systems: a nonsmooth empirical objective, a robust location statistic, a clipped descent rule, and a representation by rectified linear units. Because the system is one-dimensional, each ingredient can be characterized exactly.

Our first result is an identity for the distance remaining after a travel budget $t$ toward the median. It states that the initial distance $|x-m|$ is reduced by exactly $t$ until it reaches zero. Specializing $t$ to $n\eta$ yields a closed form for every discrete iterate. This provides both an exact rate and finite termination. Unlike estimates of the form $O(1/n)$ or $O(\rho^n)$, the formula predicts the complete trajectory and the first iteration after which no further change occurs.

Our second result transfers convergence from parameter space to function space. Translation by a scalar is an isometry with respect to pointwise output difference: changing the parameter by $\delta$ changes every prediction by exactly $|\delta|$. Hence the entire trained tropical rational function becomes equal to the optimal function at the same finite stopping time.

Our third result controls empirical risk. Absolute value is $1$-Lipschitz, so a sum of three absolute losses is $3$-Lipschitz. Combining this observation with median optimality and the exact parameter trajectory produces a nonnegative, explicit bound on excess loss.

Finally, we connect the tropical flow to ordinary ReLU networks. A signed pair of shifted rectifiers represents the clipped motion exactly. The tropical and ReLU descriptions are therefore not merely analogous; for this model they define the same real-valued map.

The remainder of the paper introduces the model, establishes the median characterization, derives the trajectory and convergence theorems, proves the loss bound and ReLU identity, presents algorithms and examples, and discusses extensions and limitations.

## 2. Tropical translation and empirical loss

### 2.1. Max-plus monomials

In max-plus algebra, tropical addition is maximum and tropical multiplication is ordinary addition. A one-variable max-plus monomial with coefficient $\theta$ acts on $z\in\mathbb R$ by ordinary addition.

**Definition 2.1 (Tropical translation model).** For a parameter $\theta\in\mathbb R$, define

$$
f_\theta(z)=z+\theta.
$$

This function is a tropical monomial. In particular, it belongs to the class of tropical polynomials and therefore to the broader class of tropical rational functions.

The model may be read as a residual correction: all inputs receive the same learned offset. If a raw supervised problem has observations $(z_i,y_i)$, then the reduced targets are $r_i=y_i-z_i$, and the absolute prediction error is $|f_\theta(z_i)-y_i|=|\theta-r_i|$. Thus training the translation parameter amounts to estimating a robust center of the residuals.

### 2.2. Three-point absolute loss

Fix three ordered reduced targets

$$
a\le m\le c.
$$

**Definition 2.2 (Three-point tropical absolute loss).** The empirical loss is

$$
L_{a,m,c}(\theta)=|\theta-a|+|\theta-m|+|\theta-c|.
$$

We often write $L(\theta)$ when the data are fixed. The objective is convex and piecewise affine, with possible corners at $a$, $m$, and $c$. Its slopes on the four open regions are $-3$, $-1$, $1$, and $3$, respectively, when repeated sample values are absent; coincident values merge adjacent regions without affecting the conclusions below.

**Lemma 2.3 (Median optimality and uniqueness).** If $a\le m\le c$, then

$$
L(m)\le L(\theta)
$$

for every $\theta\in\mathbb R$. Moreover, if a parameter $\theta$ globally minimizes $L$, then $\theta=m$. Hence $m$ is the unique empirical-risk minimizer.

**Proof sketch.** Consider the position of $\theta$ relative to $m$. If $\theta\ge m$, then

$$
|\theta-a|-|m-a|=\theta-m,
$$

and

$$
|\theta-m|=\theta-m.
$$

For the third term, the reverse triangle inequality gives

$$
|\theta-c|-|m-c|\ge-(\theta-m).
$$

Adding yields $L(\theta)-L(m)\ge\theta-m\ge0$, with strict positivity when $\theta>m$. The case $\theta\le m$ is symmetric and gives $L(\theta)-L(m)\ge m-\theta$, again strict away from $m$. Therefore $m$ is the unique minimizer. $\square$

This is the odd-sample median principle in its smallest informative form. The optimization target is determined by the data, not imposed externally.

## 3. Clipped tropical descent

### 3.1. Continuous travel-budget form

The nonsmooth loss points toward the median. To prevent a fixed step from crossing the optimizer, we clip the final movement at the median.

**Definition 3.1 (Clipped tropical flow).** For a target $m$, travel budget $t\in\mathbb R$, and starting point $x\in\mathbb R$, define

$$
G_m(t,x)=
\begin{cases}
\min\{m,x+t\},&x<m,\\
\max\{m,x-t\},&x\ge m.
\end{cases}
$$

For optimization we use $t\ge0$. The extension to arbitrary real $t$ is algebraically harmless, while nonnegative $t$ has the interpretation of elapsed time or cumulative step length.

If $x<m$, the flow moves right with unit speed until it reaches $m$. If $x\ge m$, it moves left with unit speed until it reaches $m$. The min and max operations enforce absorption at the target.

**Theorem 3.2 (Exact distance law).** For all real $m$, $t$, and $x$,

$$
|G_m(t,x)-m|=\max\{0,|x-m|-t\}.
$$

**Proof sketch.** Split according to whether $x<m$. In that case, either $x+t\ge m$, so the minimum is $m$ and both sides are zero, or $x+t<m$, so $G_m(t,x)=x+t$ and

$$
|G_m(t,x)-m|=m-x-t=|x-m|-t>0.
$$

If $x\ge m$, either $x-t\le m$, giving zero on both sides, or $x-t>m$, giving

$$
|G_m(t,x)-m|=x-m-t=|x-m|-t>0.
$$

The maximum combines the reached and unreached cases. $\square$

This theorem is the central identity. It says that clipping is precisely the positive-part operation applied to the remaining distance.

### 3.2. Fixed-step iterates

**Definition 3.3 (Discrete clipped descent).** Given a step size $\eta\in\mathbb R$, define the parameter after $n\in\mathbb N$ updates by

$$
\theta_n=G_m(n\eta,x).
$$

For $\eta\ge0$, this closed form agrees with repeatedly moving at most $\eta$ toward $m$. Equivalently, the recurrence is

$$
\theta_{n+1}=
\begin{cases}
\min\{m,\theta_n+\eta\},&\theta_n<m,\\
\max\{m,\theta_n-\eta\},&\theta_n\ge m,
\end{cases}
$$

with $\theta_0=x$. The closed form is preferable for analysis because it exposes cumulative progress directly.

**Corollary 3.4 (Exact discrete convergence rate).** For every $n\in\mathbb N$,

$$
|\theta_n-m|=\max\{0,|x-m|-n\eta\}.
$$

**Proof sketch.** Substitute $t=n\eta$ into Theorem 3.2. $\square$

**Corollary 3.5 (Capture criterion).** If

$$
|x-m|\le n\eta,
$$

then $\theta_n=m$.

**Proof sketch.** Under the stated inequality, the positive part in Corollary 3.4 is zero. Zero absolute distance implies equality. $\square$

### 3.3. Finite termination

**Theorem 3.6 (Finite termination).** Let $\eta>0$. Then there exists $N\in\mathbb N$ such that

$$
\theta_n=m
$$

for every $n\ge N$. More precisely, one may choose

$$
N=\left\lceil\frac{|x-m|}{\eta}\right\rceil.
$$

**Proof sketch.** Positivity of $\eta$ permits division by the step size. By the defining property of the ceiling,

$$
|x-m|\le N\eta.
$$

For $n\ge N$, one also has $N\eta\le n\eta$. The capture criterion then gives $\theta_n=m$. $\square$

**Corollary 3.7 (Convergence to the median).** If $\eta>0$, then

$$
\lim_{n\to\infty}\theta_n=m.
$$

**Proof sketch.** The sequence is eventually equal to $m$, which is stronger than ordinary convergence. $\square$

The positivity assumption is essential. If $\eta=0$, then $\theta_n=x$ for all $n$, so convergence occurs only when $x=m$. Negative step sizes move away from the target under the given formula and have no descent interpretation.

## 4. Convergence of the learned tropical function

Parameter convergence does not always imply a simple form of function convergence. For tropical translations, however, the relation is exact.

**Lemma 4.1 (Parameter-prediction isometry).** For all $\theta,m,z\in\mathbb R$,

$$
|f_\theta(z)-f_m(z)|=|\theta-m|.
$$

**Proof sketch.** The input cancels:

$$
f_\theta(z)-f_m(z)=(z+\theta)-(z+m)=\theta-m.
$$

Taking absolute values proves the claim. $\square$

The equality is uniform in $z$. Although the principal conclusion below is pointwise convergence, the same identity also shows uniform convergence over every subset of $\mathbb R$, because the supremum of the prediction difference is the same constant $|\theta-m|$.

**Theorem 4.2 (Pointwise convergence of trained tropical rational functions).** If $\eta>0$, then for every $z\in\mathbb R$,

$$
\lim_{n\to\infty}f_{\theta_n}(z)=f_m(z)=z+m.
$$

Moreover, for every $n$ and every $z$,

$$
|f_{\theta_n}(z)-f_m(z)|
=\max\{0,|x-m|-n\eta\}.
$$

**Proof sketch.** Apply Lemma 4.1 with $\theta=\theta_n$ and then use Corollary 3.4. Finite termination implies that the prediction difference vanishes for all $z$ once $n\ge\lceil|x-m|/\eta\rceil$. $\square$

Thus the learned object remains a tropical rational function throughout training, and its limit is the uniquely minimizing tropical translation.

## 5. Explicit empirical-loss rate

### 5.1. Lipschitz control

**Lemma 5.1 (Three-sample loss stability).** For every $a,m,c,\theta\in\mathbb R$,

$$
L_{a,m,c}(\theta)-L_{a,m,c}(m)\le3|\theta-m|.
$$

No ordering assumption is required for this upper bound.

**Proof sketch.** For any fixed $r\in\mathbb R$, the reverse triangle inequality gives

$$
|\theta-r|-|m-r|\le|\theta-m|.
$$

Apply this inequality with $r=a$, $r=m$, and $r=c$, then sum the three estimates. $\square$

The constant $3$ follows directly from the number of summands. The argument generalizes to a sum of $q$ unweighted absolute losses with Lipschitz constant $q$.

### 5.2. Excess-risk certificate

**Theorem 5.2 (Explicit tropical training-loss rate).** Suppose $a\le m\le c$. For every initial value $x$, step size $\eta$, and iteration $n$,

$$
0\le L_{a,m,c}(\theta_n)-L_{a,m,c}(m)
\le3\max\{0,|x-m|-n\eta\}.
$$

For $\eta>0$, the excess loss is exactly zero for every

$$
n\ge\left\lceil\frac{|x-m|}{\eta}\right\rceil.
$$

**Proof sketch.** Median optimality supplies the nonnegative lower bound. Lemma 5.1 gives

$$
L(\theta_n)-L(m)\le3|\theta_n-m|.
$$

Substitute the exact distance formula from Corollary 3.4. The finite-termination statement follows when the positive part vanishes. $\square$

The upper bound need not equal the actual excess loss at every point; it is a certificate obtained from global Lipschitz continuity. By contrast, the underlying parameter and prediction error formulas are exact.

## 6. Exact representation by two ReLU units

Define the standard rectified linear unit by

$$
\operatorname{ReLU}(u)=\max\{0,u\}.
$$

A clipped map has a central plateau and two affine tails. Two shifted hinges are exactly sufficient to describe this shape.

**Theorem 6.1 (Two-ReLU representation of the tropical flow).** For $t\ge0$ and all $m,x\in\mathbb R$,

$$
G_m(t,x)=m+\operatorname{ReLU}(x-m-t)
-\operatorname{ReLU}(m-x-t).
$$

**Proof sketch.** There are three regions. If $x>m+t$, then the first rectifier equals $x-m-t$ and the second is zero, so the expression is $x-t$, matching motion from above. If $m-t\le x\le m+t$, both rectifiers vanish and the output is $m$, matching capture by the target. If $x<m-t$, then the first rectifier is zero and the second equals $m-x-t$, so the expression is $x+t$, matching motion from below. These regions exhaust the real line. $\square$

**Corollary 6.2 (ReLU realization of every iterate).** If $\eta\ge0$, then for every $n\in\mathbb N$,

$$
\theta_n=m+\operatorname{ReLU}(x-m-n\eta)
-\operatorname{ReLU}(m-x-n\eta).
$$

**Proof sketch.** Apply Theorem 6.1 with $t=n\eta$, which is nonnegative. $\square$

The two units have equal positive input slope before their output weights are applied, opposite shifts around $m$, and output weights $+1$ and $-1$. The representation supplies an exact bridge between a max/min optimizer and a width-two piecewise-linear network.

## 7. Main learning theorem

The preceding results combine into a single statement.

**Theorem 7.1 (Convergence and optimality of tropical translation training).** Let $a,m,c,x,\eta\in\mathbb R$ satisfy $a\le m\le c$ and $\eta>0$. Define $f_\theta(z)=z+\theta$, define $L(\theta)=|\theta-a|+|\theta-m|+|\theta-c|$, and set $\theta_n=G_m(n\eta,x)$. Then:

1. for every $z\in\mathbb R$, $f_{\theta_n}(z)$ converges to $f_m(z)$;
2. the convergence is finitely terminating, with $f_{\theta_n}=f_m$ for every $n\ge\lceil|x-m|/\eta\rceil$;
3. $m$ minimizes $L$, so $L(m)\le L(\theta)$ for every $\theta$;
4. $m$ is the unique global minimizer of $L$;
5. the parameter, prediction, and excess-loss bounds are

$$
|\theta_n-m|=|f_{\theta_n}(z)-f_m(z)|
=\max\{0,|x-m|-n\eta\},
$$

and

$$
0\le L(\theta_n)-L(m)
\le3\max\{0,|x-m|-n\eta\};
$$

6. every iterate has the exact two-ReLU representation in Corollary 6.2.

**Proof sketch.** Statements 1 and 2 follow from finite parameter termination and the parameter-prediction isometry. Statements 3 and 4 are the median optimality lemma. Statement 5 combines the exact distance theorem with loss stability. Statement 6 is the two-ReLU identity at cumulative time $n\eta$. $\square$

## 8. Algorithms and complexity

### 8.1. Iterative clipped descent

Given ordered targets $a\le m\le c$, an initial parameter $x$, a positive step $\eta$, and an iteration count $K$, the direct algorithm initializes $\theta\leftarrow x$ and repeats the following operation $K$ times: if $\theta<m$, replace $\theta$ by $\min(m,\theta+\eta)$; otherwise replace it by $\max(m,\theta-\eta)$. Each update uses constant time and constant memory. Computing $K$ iterates costs $O(K)$ time and $O(1)$ auxiliary space, or $O(K)$ storage if the complete trajectory is retained.

### 8.2. Closed-form evaluation

When only the $n$th iterate is needed, compute $t=n\eta$ and evaluate $G_m(t,x)$ directly. This costs $O(1)$ arithmetic operations and $O(1)$ space. The closed form also permits immediate calculation of the exact parameter error, the uniform prediction error, and the loss upper bound.

### 8.3. Stopping rule

The exact stopping time is obtained without running the optimizer:

$$
N=\left\lceil\frac{|x-m|}{\eta}\right\rceil.
$$

This has constant arithmetic complexity in a real-RAM model. In floating-point software, the iterative implementation should snap to $m$ through min and max operations, while a tolerance can guard against representation error in user-facing diagnostics.

## 9. Numerical examples

### 9.1. Finite capture from below

Let $a=-2$, $m=1$, $c=5$, $x=-4$, and $\eta=2$. The initial distance is $5$, so

$$
N=\left\lceil\frac{5}{2}\right\rceil=3.
$$

The trajectory is

$$
\theta_0=-4,\qquad
\theta_1=-2,\qquad
\theta_2=0,\qquad
\theta_3=1,
$$

and $\theta_n=1$ thereafter. The exact distance sequence is $5,3,1,0,0,\ldots$. At $z=7$, the predictions are $3,5,7,8,8,\ldots$, converging in finite time to $f_1(7)=8$.

The losses are

$$
L(-4)=20,\quad L(-2)=14,\quad L(0)=10,\quad L(1)=8.
$$

The excess losses $12,6,2,0$ remain below the certificates $15,9,3,0$.

### 9.2. Capture from above

Let $a=-3$, $m=0$, $c=4$, $x=5.5$, and $\eta=1.5$. Then

$$
N=\left\lceil\frac{5.5}{1.5}\right\rceil=4.
$$

The iterates are $5.5$, $4$, $2.5$, $1$, and $0$. The fourth movement is clipped from length $1.5$ to length $1$. The two-ReLU formula reproduces each value without branching.

### 9.3. A large step

If $x=-4$, $m=1$, and $\eta=100$, then $N=1$. Ordinary un-clipped signed steps could overshoot dramatically, but clipped descent lands at $m$ in one update. Thus no upper restriction on the positive step size is required for convergence in this model.

## 10. Applications and interpretation

The model represents robust offset calibration. Given residuals $r_i=y_i-z_i$, minimizing absolute prediction loss chooses their median. This is useful when a minority of observations may be corrupted, because the median is less sensitive to extreme values than the mean. The three-point analysis makes this robustness geometric: one observation lies on each side of the central target, and their directional effects ensure a unique balance at $m$.

The tropical formulation is relevant when large-weight limits or max-plus structures turn smooth computations into piecewise-affine maps. In such settings, the active affine region can encode a discrete combinatorial state. Here the states are “below the capture interval,” “captured,” and “above the capture interval.” Training consists of moving through at most one outer state before entering the central absorbing state.

The ReLU representation gives a second interpretation. A pair of shifted hinges builds the exact optimizer map, so one may regard the training trajectory itself as a shallow network whose biases depend on elapsed optimization time. This does not claim that arbitrary ReLU training behaves identically. Rather, it identifies an exact common primitive shared by tropical dynamics and rectified-linear computation.

## 11. Limitations

The conclusions rely on a scalar parameter and a translation model. Coupled parameters can generate trajectories that are not coordinatewise clipped. The loss uses three unweighted absolute deviations; different losses can replace the median by another statistic and can destroy finite termination. The target $m$ is assumed available from the ordered reduced samples. In a streaming setting, computing or tracking the median becomes an additional algorithmic problem.

The loss-rate upper bound is global and simple rather than always sharp. Exact excess loss can be computed piecewise from the positions of $\theta_n$, $a$, $m$, and $c$, but the $3|\theta_n-m|$ certificate is more portable and suffices to prove finite vanishing.

Finally, this analysis concerns the tropical limit itself. A finite-weight model may only approximate the piecewise-linear dynamics. Quantifying that approximation requires a perturbation theory that tracks accumulated update errors.

## 12. Discussion and future work

Several extensions preserve the central geometry. For $2k+1$ ordered scalar residuals, the absolute-loss minimizer is the unique central order statistic. A clipped unit-direction method should reach it after at most $\lceil|x-m|/\eta\rceil$ iterations. For $2k$ samples, the minimizer set is the closed interval between the two central order statistics; the correct analogue of finite termination is capture by that interval.

For a separable $d$-parameter model, each coordinate can follow its own scalar flow. Simultaneous descent should terminate when the last coordinate arrives, giving a total stopping time equal to the maximum coordinatewise stopping time. Nonseparable tropical rational functions are a more substantial challenge because changes in the active max-plus pieces couple the coordinates.

Perturbed updates form another natural direction. If each intended movement suffers an error bounded by $\varepsilon<\eta$, the effective guaranteed progress per step is $\eta-\varepsilon$ while the iterate remains outside an error neighborhood. This suggests a robust bound of the form

$$
|\theta_n-m|\le\max\{0,|x-m|-n(\eta-\varepsilon)\}
$$

until entry into a closed $\varepsilon$-neighborhood of $m$.

The exact two-ReLU realization also invites a minimal-width result. The clipped flow with $t>0$ has two breakpoints, at $m-t$ and $m+t$. A single ordinary ReLU has at most one breakpoint, whereas two shifted units suffice by Theorem 6.1. Formalizing the corresponding lower bound would characterize the representation sharply.

## 13. Conclusion

Clipped fixed-step descent for a tropical translation model admits a complete solution. Three-sample absolute loss selects the median uniquely. The optimizer moves toward that median at an exactly known rate, reaches it after finitely many updates, and remains there. Parameter error equals prediction error at every input, excess loss has an explicit vanishing certificate, and the full trajectory is represented by two shifted ReLU units.

The analysis illustrates the explanatory value of tropical limits. Piecewise-linear structure turns convergence from a qualitative statement into an exact distance identity and exposes a direct correspondence between robust statistics, optimization dynamics, and neural-network representation.