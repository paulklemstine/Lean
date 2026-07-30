# Three-Sample Tropical Training as Median-Seeking Piecewise-Linear Gradient Flow

**Aristotle**  
**July 30, 2026**

## Abstract

We analyze a scalar tropical neuron trained on three observations under absolute-error loss. After absorbing the fixed feature contributions into the labels, the problem is governed by three ordered reduced targets $a\le m\le c$ and the empirical objective

$$
L(x)=|x-a|+|x-m|+|x-c|.
$$

We prove that the middle target $m$ is the unique global minimizer. We then study the clipped unit-speed piecewise-linear flow

$$
\Phi_t(x)=
\begin{cases}
\min\{m,x+t\},&x<m,\\
\max\{m,x-t\},&x\ge m,
\end{cases}
$$

which is a canonical median-seeking subgradient dynamics. Every initialization $x_0$ reaches $m$ after time $|x_0-m|$ and remains there, so convergence is finite-time rather than merely asymptotic. A point minimizes the empirical loss if and only if it is fixed by every positive-time flow map. Thus statistical optimality, dynamical stationarity, and the median condition coincide exactly. We give complete proof sketches, executable algorithms, numerical examples, and a discussion of extensions to weighted samples, projective tropical parameter spaces, smooth approximations, multiple neurons, and discrete descent.

## 1. Introduction

Tropical models replace smooth algebraic combinations by max-affine or min-affine operations. Their parameter spaces are consequently divided into polyhedral regions on which model outputs and losses have simple affine descriptions. This geometry is especially relevant when a smooth architecture is examined in a large-scale or low-temperature limit: log-sum-exp expressions sharpen toward maxima, and smoothly varying gradients approach piecewise-constant subgradients.

The resulting nonsmoothness can complicate conventional differential analysis, but it may also expose exact dynamics that smooth models conceal. This paper develops the smallest nontrivial example. A one-parameter tropical neuron is trained on three reduced scalar observations using an $L^1$ objective. The loss is the sum of three absolute residuals, and the dynamics move directly toward their median.

Three features make the example useful. First, the optimizer is an order statistic rather than an average, connecting tropical learning to robust estimation. Second, the loss is convex but not differentiable at its data knots, so a piecewise-linear subgradient description is natural. Third, the proposed flow reaches equilibrium in an explicitly bounded finite time. The model therefore distinguishes ordinary limit convergence from the stronger property of eventual exact stationarity.

Our main statement is a connector theorem: for three ordered targets, global empirical-risk minimization is equivalent to invariance under every positive-time flow map; both conditions hold precisely at the median. In addition, every initial condition converges globally to that point and becomes equal to it once elapsed time covers the initial distance.

The scope should be stated carefully. The analysis concerns the reduced scalar tropical model itself. It does not by itself establish convergence from a finite-temperature smooth network to this limit, nor does it address arbitrary multidimensional tropical architectures. Those are natural extensions, discussed in Section 9.

## 2. Reduced three-sample model

### 2.1 Tropical reduction

Consider a scalar projective coordinate $x$ for a tropical neuron. For each observation, the fixed tropical feature contribution can be subtracted from its label. This produces a reduced target against which $x$ is compared directly. With three samples, sort the reduced targets and denote them by

$$
a\le m\le c.
$$

No strict inequality is required. Repeated targets are permitted. The center value $m$ is the median, including in degenerate cases such as $a=m$ or $m=c$.

### 2.2 Empirical loss

**Definition 2.1 (Three-point tropical absolute loss).** For ordered reduced targets $a\le m\le c$ and parameter $x\in\mathbb R$, define

$$
L_{a,m,c}(x)=|x-a|+|x-m|+|x-c|.
$$

The objective is continuous, convex, coercive, and piecewise affine, with possible breakpoints at $a$, $m$, and $c$. Coercivity follows because $L_{a,m,c}(x)$ grows linearly as $|x|\to\infty$.

For intuition, away from repeated knots its slopes are

$$
-3\quad(x<a),\qquad -1\quad(a<x<m),\qquad
1\quad(m<x<c),\qquad 3\quad(x>c).
$$

Thus the sign changes at $m$. The results below avoid relying on differentiability and remain valid when targets coincide.

### 2.3 Clipped median flow

**Definition 2.2 (Clipped unit-speed tropical flow).** For elapsed time $t\ge0$, target median $m$, and initial point $x\in\mathbb R$, define

$$
\Phi_t^m(x)=
\begin{cases}
\min\{m,x+t\},&x<m,\\
\max\{m,x-t\},&x\ge m.
\end{cases}
$$

The superscript will be omitted when $m$ is clear. The trajectory moves toward $m$ at unit speed and clips at $m$ to prevent overshoot. Although the raw subgradient magnitude of $L_{a,m,c}$ varies by region, this normalized flow follows the loss-decreasing direction and retains only its orientation. It is therefore best viewed as a normalized subgradient flow or median-seeking tropical training dynamics.

An equivalent formula, valid for $t\ge0$, is

$$
\Phi_t^m(x)=m+\operatorname{sgn}(x-m)\max\{|x-m|-t,0\},
$$

where $\operatorname{sgn}(0)=0$. This representation makes the exact distance law transparent:

$$
|\Phi_t^m(x)-m|=\max\{|x-m|-t,0\}.
$$

## 3. Geometry of the loss

We first isolate the optimization facts needed later.

**Lemma 3.1 (Outer-distance bound).** For every $x\in\mathbb R$ and every $a\le c$,

$$
|x-a|+|x-c|\ge c-a.
$$

**Proof sketch.** The triangle inequality gives

$$
|c-a|=|(x-a)-(x-c)|\le |x-a|+|x-c|.
$$

Since $c-a\ge0$, one has $|c-a|=c-a$. At any $x\in[a,c]$, equality holds because the two distances partition the interval from $a$ to $c$. $\square$

**Theorem 3.2 (Median minimization).** Let $a\le m\le c$. Then for every $x\in\mathbb R$,

$$
L_{a,m,c}(m)\le L_{a,m,c}(x).
$$

**Proof sketch.** At the median,

$$
L_{a,m,c}(m)=|m-a|+0+|m-c|=(m-a)+(c-m)=c-a.
$$

For arbitrary $x$, Lemma 3.1 and nonnegativity of absolute value give

$$
L_{a,m,c}(x)
=|x-a|+|x-c|+|x-m|
\ge(c-a)+0
=L_{a,m,c}(m).
$$

Hence $m$ is a global minimizer. $\square$

That argument establishes minimality but not, by itself, uniqueness, because the outer-distance inequality is an equality throughout $[a,c]$. The middle residual supplies strictness.

**Lemma 3.3 (Strict increase away from the median).** If $a\le m\le c$, then

$$
x<m\implies L_{a,m,c}(m)<L_{a,m,c}(x),
$$

and

$$
m<x\implies L_{a,m,c}(m)<L_{a,m,c}(x).
$$

**Proof sketch.** Consider first $x<m$. If $a\le x<m$, then direct expansion of the absolute values gives

$$
L_{a,m,c}(x)=(x-a)+(m-x)+(c-x)=m+c-a-x,
$$

whereas $L_{a,m,c}(m)=c-a$. Their difference is $m-x>0$. If $x<a$, then

$$
L_{a,m,c}(x)=(a-x)+(m-x)+(c-x),
$$

and comparison with $c-a$ yields

$$
L_{a,m,c}(x)-L_{a,m,c}(m)=2(a-x)+(m-x)>0.
$$

The right side is analogous. If $m<x\le c$, expansion gives a difference $x-m>0$. If $x>c$, the difference may be written as $2(x-c)+(x-m)>0$. These cases include the possible equalities among $a$, $m$, and $c$. $\square$

**Corollary 3.4 (Unique empirical-risk minimizer).** For $a\le m\le c$ and $x\in\mathbb R$, the following are equivalent:

1. $L_{a,m,c}(x)\le L_{a,m,c}(y)$ for every $y\in\mathbb R$;
2. $x=m$.

**Proof sketch.** Theorem 3.2 proves that $m$ satisfies the first condition. Conversely, if a minimizing $x$ were smaller or larger than $m$, the corresponding part of Lemma 3.3 would show that $m$ has strictly lower loss, a contradiction. Trichotomy leaves only $x=m$. $\square$

This result is robust under repeated targets. If $a=m<c$, for example, two observations already occur at $m$, and $m$ remains uniquely optimal. The same is true when $a<m=c$ or all three values coincide.

## 4. Dynamics of the clipped flow

### 4.1 Exact arrival

**Theorem 4.1 (Finite-time arrival).** Let $m,x\in\mathbb R$ and $t\ge0$. If

$$
|x-m|\le t,
$$

then

$$
\Phi_t^m(x)=m.
$$

**Proof sketch.** If $x<m$, then $m-x=|x-m|\le t$, hence $m\le x+t$. The lower branch of the definition becomes $\min\{m,x+t\}=m$. If $x\ge m$, then $x-m=|x-m|\le t$, hence $x-t\le m$. The upper branch becomes $\max\{m,x-t\}=m$. $\square$

**Corollary 4.2 (Exact hitting time).** For an initialization $x_0$, the trajectory reaches $m$ by time

$$
T(x_0)=|x_0-m|.
$$

If $x_0\ne m$, no smaller nonnegative time reaches $m$. Thus $T(x_0)$ is the exact first hitting time.

**Proof sketch.** Arrival at time $T(x_0)$ is Theorem 4.1. For $0\le t<T(x_0)$, the equivalent signed-distance formula leaves positive residual distance $T(x_0)-t$, so the trajectory has not yet reached $m$. $\square$

The flow also has a semigroup interpretation.

**Proposition 4.3 (Semigroup law).** For $s,t\ge0$ and $x\in\mathbb R$,

$$
\Phi_s^m(\Phi_t^m(x))=\Phi_{s+t}^m(x).
$$

**Proof sketch.** The distance from $m$ after time $t$ is $\max\{|x-m|-t,0\}$ and the side of $m$ is unchanged unless the trajectory has arrived. Applying another duration $s$ subtracts $s$ and clips at zero:

$$
\max\{\max\{|x-m|-t,0\}-s,0\}
=\max\{|x-m|-(s+t),0\}.
$$

The sign is preserved before arrival and is zero afterward, giving the identity. $\square$

The semigroup law is useful conceptually, although finite-time convergence and the principal connector theorem require only the explicit clipped map.

### 4.2 Fixed points

**Theorem 4.4 (Fixed-point characterization).** For $m,x\in\mathbb R$, the following are equivalent:

1. $\Phi_t^m(x)=x$ for every $t>0$;
2. $x=m$.

**Proof sketch.** If $x=m$, both branches clip at $m$, so the point is fixed. Conversely, assume invariance for all $t>0$. Choose

$$
t=|x-m|+1.
$$

This is positive and exceeds the initial distance, so Theorem 4.1 gives $\Phi_t^m(x)=m$. Invariance also gives $\Phi_t^m(x)=x$, hence $x=m$. $\square$

Requiring every positive time is natural for a continuous flow. In fact, for this specific dynamics, invariance under any one positive duration already forces $x=m$: a nonmedian point must move by a positive amount or arrive at the distinct point $m$.

### 4.3 Global convergence

**Theorem 4.5 (Global finite-time convergence).** For every $m,x_0\in\mathbb R$,

$$
\lim_{t\to\infty}\Phi_t^m(x_0)=m.
$$

More strongly,

$$
\Phi_t^m(x_0)=m
$$

for every $t\ge |x_0-m|$.

**Proof sketch.** The second statement is exactly Theorem 4.1. An eventually constant trajectory converges to its eventual value, proving the limit. $\square$

This is stronger than a decay estimate. Many smooth gradient flows approach an equilibrium while never reaching it at finite time. Here the nonsmooth normalized dynamics give exact arrival.

## 5. The optimization–dynamics connector

The preceding results can now be assembled.

**Theorem 5.1 (Three-sample tropical training connector).** Let $a\le m\le c$. For every $x\in\mathbb R$, the following conditions are equivalent:

1. $x$ is a global empirical-risk minimizer, meaning

   $$
   L_{a,m,c}(x)\le L_{a,m,c}(y)
   $$

   for every $y\in\mathbb R$;

2. $x$ is dynamically stationary, meaning

   $$
   \Phi_t^m(x)=x
   $$

   for every $t>0$;

3. $x=m$.

Moreover, for every initialization $x_0\in\mathbb R$, the trajectory $t\mapsto\Phi_t^m(x_0)$ reaches this common point after time $|x_0-m|$ and converges to it as $t\to\infty$.

**Proof sketch.** Corollary 3.4 identifies the global minimizers exactly with $m$. Theorem 4.4 identifies points fixed by all positive-time maps exactly with $m$. Therefore conditions 1–3 are equivalent. The final assertion follows from Theorem 4.5. $\square$

The theorem supplies a precise bridge among order statistics, optimization, and dynamics. It also gives uniqueness without an assumption of strict convexity: the loss is piecewise linear and may contain linear stretches, but the odd number of observations makes the median residual enforce a unique optimum.

## 6. Algorithms

### 6.1 Direct median optimizer

Given three real reduced targets, the exact optimizer is obtained by sorting them and selecting the middle entry.

**Algorithm 6.1 (Three-sample tropical empirical-risk minimization).** Input three reduced targets $r_1,r_2,r_3$. Sort them as $a\le m\le c$ and return $m$.

A comparison sort uses constant storage and, for three elements, a constant number of comparisons. Expressed for a variable input size $n$, sorting costs $O(n\log n)$, while a selection algorithm can find a median in expected $O(n)$ time. Here $n=3$, so both time and space are $O(1)$.

### 6.2 Evaluation of the clipped flow

**Algorithm 6.2 (Exact tropical flow evaluation).** Given median $m$, elapsed time $t\ge0$, and initialization $x$, return $\min\{m,x+t\}$ if $x<m$; otherwise return $\max\{m,x-t\}$.

The algorithm uses one comparison and a constant number of arithmetic operations, hence $O(1)$ time and $O(1)$ auxiliary space. Unlike numerical integration, it incurs no time-discretization error because it evaluates the trajectory in closed form.

### 6.3 Trajectory sampling

For visualization, choose a time grid $0=t_0<t_1<\cdots<t_N$ and evaluate the closed-form flow at each time. This costs $O(N)$ time and $O(N)$ space if all samples are retained, or $O(1)$ space for streaming output. The exact hitting time $|x_0-m|$ should be included in the grid if one wants the plotted path to display the transition to the stationary phase precisely.

## 7. Numerical examples

Take

$$
a=-2,\qquad m=1,\qquad c=5.
$$

The loss at the optimizer is

$$
L(1)=|3|+|0|+|-4|=7.
$$

Two comparison points give

$$
L(-1)=|-1+2|+|-1-1|+|-1-5|=1+2+6=9
$$

and

$$
L(4)=|4+2|+|4-1|+|4-5|=6+3+1=10.
$$

For initialization $x_0=-2$, the hitting time is

$$
|-2-1|=3.
$$

At elapsed times $0,1,2,3,4$, the states are respectively

$$
-2,-1,0,1,1.
$$

For initialization $x_0=5$, the hitting time is $4$, and the states at integer times $0$ through $5$ are

$$
5,4,3,2,1,1.
$$

Large elapsed times do not create overshoot. For example,

$$
\Phi_{10}^1(5)=1.
$$

The examples illustrate both sides of the flow and the eventual constant phase.

## 8. Structural consequences of the exact formula

The closed-form distance law permits several deductions that sharpen the convergence theorem.

**Proposition 8.1 (Nonexpansiveness in the initial condition).** For fixed $m$ and $t\ge0$, the map $x\mapsto\Phi_t^m(x)$ is $1$-Lipschitz:

$$
|\Phi_t^m(x)-\Phi_t^m(y)|\le |x-y|
$$

for all $x,y\in\mathbb R$.

**Proof sketch.** The flow map is the projection toward $m$ after a translation of magnitude $t$. On each of the regions where both points remain below $m$, both remain above $m$, or both have arrived, its slope is respectively $1$, $1$, or $0$. If two points occupy different regions, monotonicity and continuity across the clipping boundaries show that their output separation cannot exceed their input separation. Equivalently, the graph is continuous, nondecreasing, and piecewise affine with slopes only $0$ and $1$, which implies the Lipschitz bound. $\square$

Thus perturbations in initialization are never amplified. Two trajectories may preserve their separation while traveling on the same side, but clipping can only reduce it.

**Proposition 8.2 (Monotone distance and eventual zero loss gap).** Along every trajectory, the distance to the optimizer is nonincreasing and obeys

$$
|\Phi_t^m(x_0)-m|=\max\{|x_0-m|-t,0\}.
$$

Furthermore, the empirical loss $L_{a,m,c}(\Phi_t^m(x_0))$ is nonincreasing in $t$ and equals its minimum value $c-a$ for every $t\ge|x_0-m|$.

**Proof sketch.** The distance identity follows by expanding the two branches of the clipped flow. Before arrival, the state moves toward $m$ without changing sides. Lemma 3.3 shows that movement toward $m$ strictly lowers loss whenever the state is not already $m$. After arrival, both state and loss are constant. At $m$, Theorem 3.2 gives the minimum value $L_{a,m,c}(m)=c-a$. $\square$

The loss can decrease at different linear rates as the trajectory crosses $a$ or $c$, because the number of residuals pulling in each direction changes. Nevertheless, the parameter distance always falls at the same unit rate. This distinction reflects normalization: the flow uses the sign of a descent direction, not the full magnitude of the loss subgradient.

**Proposition 8.3 (Translation equivariance).** If a common offset $q\in\mathbb R$ is added to all targets and to the initialization, then loss values and relative trajectories are unchanged:

$$
L_{a+q,m+q,c+q}(x+q)=L_{a,m,c}(x)
$$

and

$$
\Phi_t^{m+q}(x+q)=\Phi_t^m(x)+q.
$$

**Proof sketch.** Every residual is unchanged because $(x+q)-(a+q)=x-a$, and similarly for $m$ and $c$. The inequalities determining the flow branch are also unchanged, while addition by $q$ commutes with the relevant minimum and maximum. $\square$

Translation equivariance explains why subtracting fixed feature contributions is natural: only relative positions matter. It also anticipates the projective viewpoint, in which common translations are treated as redundant descriptions of the same tropical state.

## 9. Interpretation and applications

### 9.1 Robustness

The optimizer depends on the ordering of the three reduced targets, not on their magnitudes through an average. If $c$ is moved farther to the right while $a\le m\le c$ remains true, the optimizer stays at $m$. This is the elementary source of the median's resistance to a single extreme observation.

The optimal value does change: $L(m)=c-a$ records the span of the outer points. Thus the parameter estimate is robust even though the achieved empirical loss reflects the outlier's distance.

### 9.2 Stopping certificates

The exact distance law provides a deterministic stopping criterion. If the median is known and training begins at $x_0$, then elapsed continuous time $t\ge|x_0-m|$ certifies that the parameter equals the optimizer. No tolerance parameter is required in the idealized model.

### 9.3 Polyhedral optimization

The scalar example is a single-cell prototype of higher-dimensional tropical learning. In larger models, active max-affine terms partition parameter space into polyhedra. Within each cell, residuals and descent directions can be affine or constant; crossing a wall changes the active pattern. The present flow demonstrates how clipping at a nonsmooth optimum can convert such regional rules into a globally convergent trajectory.

### 9.4 Projective interpretation

Tropical parameter vectors are often considered modulo common translation. A scalar coordinate can be regarded as a chart on this projective quotient after redundant translation has been removed. Extending the analysis intrinsically requires a projective metric and a proof that the dynamics do not depend on the chosen representative. The current model captures the chart-level median mechanism while leaving that quotient construction for future work.

## 10. Limitations and future work

The exact theorem relies on a scalar parameter, three unweighted observations, absolute loss, and a normalized clipped flow centered at the known median. Each assumption points to a concrete extension.

First, one may begin with a smooth log-sum-exp neuron depending on a scale parameter and prove that its losses and gradient trajectories converge to the piecewise-linear system as the scale tends to the tropical limit. Loss convergence alone is not enough; trajectory convergence must control behavior near moving nonsmooth boundaries.

Second, the scalar chart should be replaced by the tropical projective torus. Weight vectors would be quotiented by common translation, equipped with a projective metric, and the flow shown invariant under representatives.

Third, odd finite samples should yield the ordinary median, while positive weights yield a weighted median. For an even number of samples, the minimizer set is the interval between the two center order statistics. Dynamics may then possess a continuum of equilibria, and initialization or flow convention may determine which minimizer is selected.

Fourth, multiple tropical neurons produce sums and differences of max-affine terms. Their activation patterns form a polyhedral complex in parameter space. Convex subclasses may admit global convergence, while nonconvex cases will require local analysis, error bounds, or conditions excluding cycling among activation regions.

Fifth, practical training is discrete. An explicit constant-step subgradient method can overshoot the median repeatedly. Clipping, proximal updates, or diminishing step sizes may restore convergence. A useful comparison would quantify how closely an interpolated discrete trajectory shadows the continuous flow.

Sixth, perturbation theory should measure how changes in labels or tropical features alter the reduced median. This would connect training stability directly to robust statistics and provide finite-sample sensitivity bounds.

Finally, alternative losses change both estimators and dynamics. Squared loss selects the mean and leads to smooth contraction. Huber loss interpolates between mean-like and median-like behavior. Comparing their tropical-limit trajectories would clarify which finite-time and robustness properties are specific to $L^1$ geometry.

## 11. Conclusion

For three ordered reduced targets $a\le m\le c$, the scalar tropical absolute-error loss

$$
L(x)=|x-a|+|x-m|+|x-c|
$$

has the unique global minimizer $m$. The clipped unit-speed flow moves any initialization toward that point without overshoot and reaches it exactly after time $|x_0-m|$. The median is also the unique point fixed by every positive-time flow map. Consequently, empirical-risk minimization, dynamical stationarity, and the order-statistical median condition are equivalent.

The result is elementary enough to admit complete formulas, yet it captures characteristic features of tropical learning: polyhedral objectives, nonsmooth descent, robust estimators, and finite-time stabilization. It provides a base case for studying how smooth neural optimization degenerates into piecewise-linear tropical dynamics and how the same mechanism scales to weighted data, projective spaces, discrete algorithms, and multi-neuron networks.
