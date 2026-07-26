# Finite-Action Policy Gradients, Compatible Score Models, and Sharp Exploration Bounds

## Abstract

This paper develops a self-contained finite-action account of policy-gradient differentiation and the statistical cost of off-policy exploration. For a differentiable one-parameter family of probability vectors, we prove that coordinatewise score factorization converts the derivative of an expected action value into an expected score-weighted value. Differentiating policy normalization yields the mean-zero score identity, from which action-independent baseline invariance follows. For vector score features, an advantage function linear in those features produces a gradient equal to the score second-moment, or Fisher-type, matrix applied to the approximation weights. We then study scalar importance-weighted estimators. If a strictly positive behavior distribution dominates an $\varepsilon$ fraction of a nonnegative target distribution action by action, their second moment is at most $\varepsilon^{-1}$ times the target second moment of the signal. A two-action construction attains equality, proving that the inverse-$\varepsilon$ dependence is sharp. We give algorithms and numerical examples, explain the relation to natural-gradient methods, and distinguish these exact finite identities from convergence claims that require additional smoothness, stochastic-approximation, and landscape assumptions.

## 1. Introduction

Policy-gradient methods optimize randomized decision rules by differentiating expected performance. Their practical appeal comes from a score-function representation: rather than differentiating through a sampled action, one multiplies its observed value by the sensitivity of its log probability. This representation supports Monte Carlo estimation, baseline subtraction, actor–critic methods, compatible function approximation, and natural-gradient constructions.

A second issue arises when the distribution generating data differs from the target policy. Importance weighting restores the desired expectation by multiplying each observation by a target-to-behavior probability ratio. Yet unbiasedness alone does not guarantee a useful estimator. If behavior assigns very little mass to an action important under the target, the ratio can be large and the estimator can have a large second moment.

The purpose of this paper is to isolate the exact algebraic and differential statements underlying these mechanisms in a finite action space. This setting is elementary enough that all assumptions are explicit and all sums are finite, but rich enough to expose the main structures.

The contributions are as follows.

1. We state and prove a finite-action policy-gradient theorem under coordinatewise score factorization.
2. We derive the mean-zero score identity solely from normalization and use it to prove exact baseline invariance.
3. We prove the coordinatewise compatible-function-approximation identity $g=Fw$.
4. We establish an explicit importance-weighted second-moment bound under actionwise $\varepsilon$-coverage.
5. We exhibit a two-action equality case, showing that the $1/\varepsilon$ rate cannot be improved without stronger assumptions.
6. We explain precisely why these results do not, by themselves, establish convergence of policy-gradient iterates to local maxima.

The scope is intentionally finite and one-step. No Markov state dynamics, occupancy measures, or trajectories are assumed. This makes the distinction between proven identities and future convergence theory especially clear.

## 2. Finite expectations and differentiable policies

Let $\mathcal A=\{1,\ldots,n\}$ be a finite action set. For functions $p,f:\mathcal A\to\mathbb R$, define the finite weighted expectation

$$
\mathbb E_p[f]=\sum_{a\in\mathcal A}p(a)f(a).
$$

When $p(a)\ge 0$ and $\sum_a p(a)=1$, this is the ordinary expectation under the probability distribution $p$. Some algebraic identities below require only the displayed finite sum; probabilistic interpretations additionally use nonnegativity and normalization.

Let $I\subseteq\mathbb R$ be an open interval and let $p_\theta(a)$ be differentiable in the scalar parameter $\theta\in I$ for every action $a$. We assume that, at the parameter under consideration, there is a score function $\psi:\mathcal A\to\mathbb R$ satisfying

$$
\frac{d}{d\theta}p_\theta(a)=p_\theta(a)\psi(a).
$$

For positive $p_\theta(a)$, the score is the logarithmic derivative

$$
\psi(a)=\frac{d}{d\theta}\log p_\theta(a).
$$

The factorized derivative is the operative assumption. It avoids requiring logarithms at zero-probability actions and records exactly the relation used in the proofs.

Let $Q:\mathcal A\to\mathbb R$ be an action-value function that is fixed while differentiating. Define

$$
J(\theta)=\mathbb E_{p_\theta}[Q]
=\sum_{a\in\mathcal A}p_\theta(a)Q(a).
$$

### Theorem 1 (Finite-action policy-gradient identity)

Suppose each coordinate $p_\theta(a)$ is differentiable at $\theta$ and satisfies

$$
p_\theta'(a)=p_\theta(a)\psi(a).
$$

Then $J$ is differentiable at $\theta$ and

$$
J'(\theta)=\mathbb E_{p_\theta}[\psi Q]
=\sum_{a\in\mathcal A}p_\theta(a)\psi(a)Q(a).
$$

#### Proof sketch

Because $\mathcal A$ is finite, differentiation commutes with summation. The values $Q(a)$ are constants with respect to $\theta$, so

$$
J'(\theta)=\sum_a p_\theta'(a)Q(a).
$$

Substitute the score factorization $p_\theta'(a)=p_\theta(a)\psi(a)$ and recognize the resulting finite expectation. No interchange of an infinite sum, integral, or limit is required.

### Example 1 (Two-action logistic policy)

Let $\mathcal A=\{1,2\}$ and

$$
p_\theta(1)=\sigma(\theta),\qquad p_\theta(2)=1-\sigma(\theta),
$$

where $\sigma(\theta)=(1+e^{-\theta})^{-1}$. Since $\sigma'(\theta)=\sigma(\theta)(1-\sigma(\theta))$, the scores are

$$
\psi(1)=1-p_\theta(1),\qquad \psi(2)=-p_\theta(1).
$$

For values $Q(1)$ and $Q(2)$, Theorem 1 gives

$$
J'(\theta)=p_\theta(1)(1-p_\theta(1))\bigl(Q(1)-Q(2)\bigr),
$$

which agrees with direct differentiation.

## 3. Normalization, mean-zero scores, and baselines

A policy is normalized for every parameter:

$$
\sum_{a\in\mathcal A}p_\theta(a)=1.
$$

The constancy of this sum imposes a key orthogonality condition.

### Theorem 2 (Mean-zero score identity)

Assume $p_\theta$ is normalized in a neighborhood of $\theta$ and each coordinate obeys the score factorization. Then

$$
\mathbb E_{p_\theta}[\psi]=\sum_a p_\theta(a)\psi(a)=0.
$$

#### Proof sketch

Differentiate normalization. The derivative of the constant $1$ is zero, while finite-sum differentiation gives

$$
0=\sum_a p_\theta'(a)=\sum_a p_\theta(a)\psi(a).
$$

The final sum is the expected score.

The mean-zero identity means that score functions are orthogonal, under the policy-weighted inner product, to all action-independent constants. It immediately permits control variates.

### Theorem 3 (Action-independent baseline invariance)

Let $p$ be a weight vector, let $\psi$ satisfy $\mathbb E_p[\psi]=0$, let $Q$ be any scalar action-value function, and let $b\in\mathbb R$ be independent of the action. Then

$$
\mathbb E_p[\psi(Q-b)]=\mathbb E_p[\psi Q].
$$

#### Proof sketch

Expand by linearity:

$$
\mathbb E_p[\psi(Q-b)]
=\mathbb E_p[\psi Q]-b\mathbb E_p[\psi].
$$

The final term vanishes by the mean-zero hypothesis.

The theorem concerns expectation, not necessarily variance. Different baselines produce estimators with the same mean but potentially very different dispersion. For a scalar score, one can minimize the second moment of $\psi(A)(Q(A)-b)$ over $b$. Provided $\mathbb E_p[\psi(A)^2]>0$, elementary differentiation yields

$$
b^*=\frac{\mathbb E_p[\psi(A)^2Q(A)]}
{\mathbb E_p[\psi(A)^2]}.
$$

This optimality formula is an application of the baseline identity rather than part of the identity itself. A convenient state-dependent baseline is also valid in a state–action model when it is constant across actions conditional on the state; the present one-step formulation uses a scalar $b$.

## 4. Vector scores and compatible function approximation

Now let the score be vector-valued: $\psi(a)\in\mathbb R^d$. Write its coordinates as $\psi_j(a)$ for $j=1,\ldots,d$. Let $w\in\mathbb R^d$ and suppose an advantage function is represented exactly as

$$
A_w(a)=\psi(a)^\top w=\sum_{k=1}^d\psi_k(a)w_k.
$$

Define the score second-moment matrix $F\in\mathbb R^{d\times d}$ by

$$
F_{jk}=\mathbb E_p[\psi_j\psi_k]
=\sum_a p(a)\psi_j(a)\psi_k(a).
$$

For a normalized statistical model, this matrix is commonly called a Fisher information matrix under suitable regularity conventions. In the finite algebraic setting, only its displayed second-moment definition is needed.

### Theorem 4 (Compatible score-model identity)

For every coordinate $j$,

$$
\mathbb E_p[\psi_j A_w]
=\sum_{k=1}^d F_{jk}w_k.
$$

Equivalently, in vector notation,

$$
\mathbb E_p[\psi A_w]=Fw.
$$

#### Proof sketch

Substitute $A_w(a)=\sum_k\psi_k(a)w_k$ and distribute the finite sums:

$$
\begin{aligned}
\mathbb E_p[\psi_j A_w]
&=\sum_a p(a)\psi_j(a)\sum_k\psi_k(a)w_k\\
&=\sum_k\left(\sum_a p(a)\psi_j(a)\psi_k(a)\right)w_k\\
&=\sum_k F_{jk}w_k.
\end{aligned}
$$

All rearrangements are valid because both index sets are finite.

### 4.1 Geometric interpretation

The matrix $F$ is symmetric and positive semidefinite because, for every $v\in\mathbb R^d$,

$$
v^\top Fv
=\mathbb E_p[(v^\top\psi(A))^2]\ge 0.
$$

If $F$ is positive definite, then the compatible identity can be inverted:

$$
w=F^{-1}g,
\qquad
g=\mathbb E_p[\psi A_w].
$$

Thus a fitted compatible weight vector corresponds algebraically to a Fisher-preconditioned gradient. This motivates natural-gradient methods, whose direction adjusts the ordinary gradient by the local geometry of the policy distribution.

Positive definiteness is not automatic. Redundant parameters or policy symmetries can make $F$ singular. In that case one may restrict to an identifiable subspace, regularize $F$, or use a pseudoinverse, but each choice adds assumptions beyond Theorem 4.

### 4.2 What compatibility does not prove

The identity $g=Fw$ does not by itself imply that an iterative algorithm converges. A convergence theorem for stochastic policy-gradient ascent normally requires conditions such as smoothness of the objective, controlled estimator moments, a suitable step-size schedule, and boundedness or stability of the iterates. Convergence to a stationary point is weaker than convergence to a local maximum. The latter additionally requires landscape or dynamical-stability assumptions that exclude convergence to saddles, minima, or unstable sets. Accordingly, the compatible identity should be understood as an exact structural bridge, not as a standalone local-optimality theorem.

## 5. Importance weighting and exploration coverage

Let $b,t:\mathcal A\to\mathbb R$ denote behavior and target weights. For the probabilistic interpretation, assume $b$ and $t$ are distributions. Let $g:\mathcal A\to\mathbb R$ be a scalar signal. When $b(a)>0$, define the importance-weighted estimator

$$
X(a)=\frac{t(a)}{b(a)}g(a).
$$

If $A\sim b$, then

$$
\mathbb E_b[X(A)]
=\sum_a b(a)\frac{t(a)}{b(a)}g(a)
=\sum_a t(a)g(a)
=\mathbb E_t[g(A)].
$$

Thus importance weighting transfers expectations from the behavior distribution to the target distribution. Its second moment is

$$
M_2(b,t,g)
=\mathbb E_b[X(A)^2]
=\sum_a b(a)\left(\frac{t(a)}{b(a)}g(a)\right)^2.
$$

We impose an actionwise exploration or coverage condition. For a constant $\varepsilon>0$, assume

$$
b(a)\ge \varepsilon t(a)
$$

for every $a$, together with $b(a)>0$ and $t(a)\ge 0$. This condition says that behavior retains at least an $\varepsilon$ fraction of the target mass at each action. It is satisfied, for example, by the mixture $b=\varepsilon t+(1-\varepsilon)u$ for any distribution $u$, although the theorem applies more generally whenever the pointwise domination holds.

### Theorem 5 (Inverse-exploration second-moment bound)

Under the assumptions $\varepsilon>0$, $b(a)>0$, $t(a)\ge 0$, and $b(a)\ge\varepsilon t(a)$ for every action,

$$
M_2(b,t,g)
\le \frac{1}{\varepsilon}\mathbb E_t[g(A)^2].
$$

That is,

$$
\sum_a b(a)\left(\frac{t(a)}{b(a)}g(a)\right)^2
\le
\frac{1}{\varepsilon}\sum_a t(a)g(a)^2.
$$

#### Proof sketch

The coverage condition and positivity imply

$$
\frac{t(a)}{b(a)}\le\frac{1}{\varepsilon}.
$$

Rewrite each summand as

$$
b(a)\left(\frac{t(a)}{b(a)}g(a)\right)^2
=t(a)\frac{t(a)}{b(a)}g(a)^2.
$$

Because $t(a)$ and $g(a)^2$ are nonnegative, applying the ratio bound yields

$$
t(a)\frac{t(a)}{b(a)}g(a)^2
\le \frac{1}{\varepsilon}t(a)g(a)^2.
$$

Summing over actions proves the result.

### Corollary 6 (Variance bound)

Suppose a nonnegative variance quantity $V$ satisfies $V\le M_2(b,t,g)$ under the hypotheses of Theorem 5. Then

$$
V\le\frac{1}{\varepsilon}\mathbb E_t[g(A)^2].
$$

#### Proof sketch

Combine the assumed inequality $V\le M_2(b,t,g)$ with Theorem 5 by transitivity.

For the scalar random variable $X(A)$, the ordinary variance satisfies

$$
\operatorname{Var}_b(X)=\mathbb E_b[X^2]-\mathbb E_b[X]^2
\le\mathbb E_b[X^2],
$$

so the corollary applies directly whenever the relevant expectations are probabilistically defined.

## 6. Sharpness of the inverse-$\varepsilon$ rate

An upper bound may reflect either genuine behavior or a loose proof. Here the dependence on exploration is exact.

### Theorem 7 (Two-action sharpness)

Let $\mathcal A=\{1,2\}$, choose $\varepsilon\ne 0$, and define

$$
b=(\varepsilon,1-\varepsilon),\qquad
t=(1,0),\qquad g=(1,0).
$$

Then

$$
M_2(b,t,g)=\frac{1}{\varepsilon}.
$$

For the probabilistic interpretation, take $0<\varepsilon\le 1$.

#### Proof sketch

Only action $1$ contributes. Its behavior probability is $\varepsilon$, target probability is $1$, and signal is $1$. Hence

$$
M_2(b,t,g)
=\varepsilon\left(\frac{1}{\varepsilon}\right)^2
=\frac{1}{\varepsilon}.
$$

Also $\mathbb E_t[g^2]=1$, so equality holds in Theorem 5.

### Consequence

No bound of the form

$$
M_2(b,t,g)\le C(\varepsilon)\mathbb E_t[g^2]
$$

can hold under only the stated coverage assumptions with $C(\varepsilon)<1/\varepsilon$ for all admissible examples. In particular, the asymptotic order $O(1/\varepsilon)$ is optimal.

The mechanism is straightforward. Under behavior, the informative action occurs with probability $\varepsilon$, but its importance weight is $1/\varepsilon$. This preserves the first moment, since $\varepsilon(1/\varepsilon)=1$, while producing second moment $\varepsilon(1/\varepsilon)^2=1/\varepsilon$.

## 7. Algorithms

### 7.1 Exact finite policy-gradient evaluation

Given arrays $p(a)$, $\psi(a)$, and $Q(a)$, compute

$$
g=\sum_a p(a)\psi(a)Q(a).
$$

For a scalar score this requires $O(n)$ arithmetic operations and $O(1)$ auxiliary space under streaming evaluation. For a $d$-dimensional score, computing the full vector requires $O(nd)$ time and $O(d)$ output space.

A numerically useful variant first selects an action-independent baseline $b$ and computes

$$
g=\sum_a p(a)\psi(a)(Q(a)-b).
$$

Under the mean-zero score condition, this is exactly the same gradient.

### 7.2 Compatible score-model evaluation

Given $p(a)$, score vectors $\psi(a)\in\mathbb R^d$, and weights $w$, one may compute either side of the identity. The direct route evaluates $A_w(a)=\psi(a)^\top w$ and accumulates $\sum_a p(a)\psi(a)A_w(a)$ in $O(nd)$ time. Constructing the full matrix

$$
F=\sum_a p(a)\psi(a)\psi(a)^\top
$$

costs $O(nd^2)$ time and $O(d^2)$ storage, after which multiplying $Fw$ costs $O(d^2)$. The direct route is preferable for one vector $w$; explicit construction is useful when many vectors will be applied or the geometry itself is needed.

### 7.3 Exploration-bound audit

Given $b$, $t$, $g$, and $\varepsilon$, verify positivity and coverage, then calculate

$$
M_2=\sum_a b(a)\left(\frac{t(a)}{b(a)}g(a)\right)^2
$$

and

$$
B=\frac{1}{\varepsilon}\sum_a t(a)g(a)^2.
$$

Both calculations take $O(n)$ time and constant auxiliary space. Reporting $M_2/B$ reveals how close the instance is to worst-case behavior. The two-action sharpness construction has ratio $1$.

## 8. Numerical illustrations

Consider the three-action softmax policy with logits $(0.2,-0.4,0.7)$ and values $(1.5,-0.5,2.0)$. For a selected logit coordinate $j$, the score is $\psi_j(a)=\mathbf 1\{a=j\}-p(j)$. The expected score is numerically zero up to floating-point error. Computing $\mathbb E_p[\psi_jQ]$ agrees with a centered finite difference of the expected value as the step size decreases. Replacing $Q$ by $Q-b$ for several baselines leaves the exact weighted sum unchanged.

For compatible approximation, choose score vectors in $\mathbb R^2$, a probability vector $p$, and weights $w$. Evaluating $\mathbb E_p[\psi(\psi^\top w)]$ directly agrees with $Fw$, where $F=\mathbb E_p[\psi\psi^\top]$. This is a finite matrix multiplication identity and should agree to roundoff.

For exploration, take $t=(0.6,0.3,0.1)$, choose a distribution $u$, and set $b=\varepsilon t+(1-\varepsilon)u$. Then $b\ge\varepsilon t$ coordinatewise. For any signal $g$, direct calculation confirms

$$
M_2\le\varepsilon^{-1}\mathbb E_t[g^2].
$$

As $u$ places less mass where $t(a)g(a)^2$ is concentrated, the ratio can approach the worst-case limit. In the deterministic two-action construction, it reaches that limit exactly.

## 9. Statistical consequences and design guidance

The second-moment theorem has an immediate sample-complexity interpretation. Let $X_1,\ldots,X_m$ be independent copies of the importance-weighted scalar estimator and let $ar X_m=m^{-1}\sum_iX_i$. Whenever the ordinary variance is defined,

$$
\operatorname{Var}(ar X_m)=rac{1}{m}\operatorname{Var}(X_1)
\le rac{1}{marepsilon}\mathbb E_t[g(A)^2].
$$

Thus maintaining a fixed variance guarantee in the worst case can require a sample count proportional to $1/arepsilon$. This conclusion follows from independence and the variance corollary; it does not assert a concentration inequality or a universal optimization rate. Stronger tail guarantees need boundedness, sub-Gaussian assumptions, truncation, or another form of moment control.

Coverage can also be read as a design variable. If behavior is chosen as a mixture $b=arepsilon t+(1-arepsilon)u$, increasing $arepsilon$ improves the theorem’s bound relative to the target but reduces the mass available for the auxiliary exploration distribution $u$. Different conventions sometimes call the auxiliary mass, rather than the target-retention mass, the exploration rate. The unambiguous mathematical condition is the pointwise inequality $b(a)\gearepsilon t(a)$; all conclusions in this paper refer to that coverage constant.

Baseline selection and coverage address different sources of noise. A baseline changes the signal from $Q$ to $Q-b$ while preserving its score-weighted expectation. Coverage controls the probability ratio used to transfer expectations between distributions. They can be combined: if $g(a)=\psi(a)(Q(a)-b)$ in a scalar-coordinate calculation, then the importance theorem bounds the second moment using the target expectation of $\psi(a)^2(Q(a)-b)^2$. A well-chosen baseline may reduce this target-side factor, while a larger coverage constant reduces the reciprocal multiplier. Neither mechanism subsumes the other.

The equality construction also guides diagnostics. An average importance ratio near one does not rule out instability, because a small subset of actions can carry very large ratios. A useful audit should inspect the actionwise ratios, verify the pointwise coverage floor, compute the exact second moment when the finite model is known, and compare it with the theorem bound. The ratio of the exact moment to the bound separates slack caused by benign signal placement from the unavoidable worst case. This makes the audit both a theorem check and a practical conditioning diagnostic for finite decision systems.

## 10. Applications and interpretation

The finite policy-gradient identity applies directly to contextual bandits after conditioning on a context. In larger sequential problems, it becomes a local component of trajectory-level derivations. The mean-zero score identity supports baselines and control variates in both settings.

The compatible score-model identity explains why a critic using score features has a special relationship with the actor’s geometry. It is not merely another linear approximation: its normal directions are built from the same sensitivities that define policy change. When the associated matrix is well conditioned, this can produce a geometry-aware update. When it is nearly singular, the same identity diagnoses unstable directions and motivates damping.

The exploration theorem applies to off-policy evaluation, policy optimization from logged data, adaptive experiments, and any finite importance-sampling problem with pointwise coverage. It turns a qualitative coverage condition into a quantitative second-moment certificate. The sharpness theorem shows that no algebraic refinement can remove inverse dependence on the coverage floor without exploiting additional structure, such as bounded ratios smaller than $1/\varepsilon$, signal–ratio anticorrelation, clipping with controlled bias, stratification, or stronger overlap.

## 11. Limitations and future work

The finite one-step model omits state visitation. In a discounted Markov decision process, changing a policy changes not only action probabilities conditional on states but also the distribution of visited states. A full policy-gradient theorem must account for that occupancy measure.

The scalar parameter theorem should also be lifted to gradients in finite-dimensional parameter spaces using Fréchet derivatives. The coordinatewise vector-score identity indicates the expected form, but a single multivariate theorem would provide a cleaner foundation.

Convergence remains a separate analytic program. A complete result should state smoothness, step-size, bounded-noise, and compactness or stability assumptions, then prove convergence of stochastic iterates to stationary points. Claims of convergence to local maxima require additional hypotheses on the objective landscape or on dynamical stability.

The variance analysis can likewise be extended. A probability-space treatment of vector estimators would define covariance directly and derive the second-moment premise rather than assuming it abstractly. State-dependent exploration and finite trajectories would introduce horizon and discount-factor constants. Such results would reveal how the actionwise $1/\varepsilon$ cost compounds—or can be controlled—over time.

## 12. Conclusion

Finite policy gradients rest on a short chain of exact statements. Score factorization turns derivatives of action probabilities into a score-weighted expectation. Policy normalization forces the score to have mean zero, making action-independent baselines unbiased. Linear advantage models built from score features produce the matrix identity $g=Fw$, connecting approximation with policy geometry. Under pointwise $\varepsilon$-coverage, importance weighting has second moment at most $\varepsilon^{-1}$ times the target signal’s second moment, and a two-action example attains equality.

Together these results clarify both the power and the limits of common policy-gradient techniques. They justify central estimators and transformations exactly, quantify the price of exploration sharply, and identify the additional assumptions needed before structural identities can become convergence theorems.