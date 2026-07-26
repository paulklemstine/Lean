# Learning by Chance: Why Policy Gradients Work—and What Exploration Costs

A robot reaches for a cup. A recommendation system chooses which film to display. A traffic controller decides how long a light should stay green. In each case, an agent must act before it knows exactly what will happen. Reinforcement learning turns this predicament into mathematics: assign probabilities to possible actions, observe the consequences, and gradually shift probability toward decisions that earn larger returns.

The simple slogan—“make rewarding actions more likely”—conceals two difficult questions. First, how can one differentiate an expected reward when the action itself is sampled? Second, if data are gathered under an exploratory policy rather than the policy being optimized, how noisy does the correction become?

For a finite collection of actions, both questions admit clean answers. The derivative of expected return is an expectation involving a *score*, a measure of how sensitively each action probability responds to the policy parameter. Scores automatically average to zero. That cancellation permits baselines, which change the numerical signal without changing its mean. If an advantage model is linear in the score, its gradient is exactly a Fisher-type matrix times the model weights. Finally, importance weighting under sufficient exploration has second moment at most proportional to $1/\varepsilon$, and no uniformly better dependence on $\varepsilon$ is possible.

These results form a compact mathematical anatomy of policy-gradient estimation.

## A finite world of choices

Suppose an agent has $n$ actions, labeled $1,\ldots,n$. A scalar parameter $\theta$ controls a differentiable probability distribution

$$
p_\theta(1),\ldots,p_\theta(n),
$$

with $p_\theta(a)\ge 0$ and $\sum_a p_\theta(a)=1$. Let $Q(a)$ be the value attached to action $a$. The expected value is

$$
J(\theta)=\sum_{a=1}^n p_\theta(a)Q(a).
$$

The score $\psi(a)$ at the current parameter is defined through the factorization

$$
\frac{d}{d\theta}p_\theta(a)=p_\theta(a)\psi(a).
$$

When $p_\theta(a)>0$, this is the familiar logarithmic derivative $\psi(a)=\frac{d}{d\theta}\log p_\theta(a)$. The factorized equation is more fundamental here because it continues to state exactly what is needed without requiring a logarithm.

Now differentiate the finite sum. Each action contributes its probability derivative multiplied by its value:

$$
J'(\theta)=\sum_a \frac{d}{d\theta}p_\theta(a)Q(a)
=\sum_a p_\theta(a)\psi(a)Q(a).
$$

In expectation notation, this is

$$
J'(\theta)=\mathbb E_{a\sim p_\theta}[\psi(a)Q(a)].
$$

This is the finite-action policy-gradient theorem. It replaces the derivative of a sum over random choices with an average that can be estimated by sampling. Draw an action $A$ from the policy, observe or estimate $Q(A)$, and form $\psi(A)Q(A)$. Its mean is the desired derivative.

The theorem does not claim that every sampled update points uphill. Individual samples may be wildly misleading. It says something subtler and more useful: their average points in exactly the derivative direction.

## The zero hidden inside every normalized policy

A probability distribution always sums to one. Differentiate that unchanging total:

$$
0=\frac{d}{d\theta}\sum_a p_\theta(a)
=\sum_a p_\theta(a)\psi(a).
$$

Thus the score has mean zero:

$$
\mathbb E_{a\sim p_\theta}[\psi(a)]=0.
$$

This identity is the quiet engine behind one of reinforcement learning’s most practical tricks. Let $b$ be any number that does not depend on the sampled action. Then

$$
\mathbb E[\psi(A)(Q(A)-b)]
=\mathbb E[\psi(A)Q(A)]-b\mathbb E[\psi(A)]
=\mathbb E[\psi(A)Q(A)].
$$

Subtracting an action-independent baseline cannot bias the gradient estimate. It can, however, dramatically change its variance.

Imagine rewards clustered near $1000$, while the meaningful differences among actions are only a few units. Multiplying the score by the raw value forces the estimator to carry a large common offset that says nothing about which action is preferable. Subtracting a baseline near $1000$ removes this irrelevant bulk. The expected gradient remains unchanged because the score annihilates constants.

A baseline is therefore not a heuristic correction to the objective. It is an exact use of probability normalization.

## From scores to geometry

Real policies often depend on many parameters. Write the score as a vector $\psi(a)\in\mathbb R^d$. Suppose an advantage—the value of an action relative to a baseline—is represented exactly by a linear score model

$$
A(a)=\psi(a)^\top w
$$

for some coefficient vector $w\in\mathbb R^d$. Consider the score-weighted expected advantage:

$$
g=\mathbb E[\psi(A)A(A)].
$$

Substituting the model gives

$$
g=\mathbb E[\psi(A)\psi(A)^\top]w.
$$

Define the score second-moment matrix

$$
F=\mathbb E[\psi(A)\psi(A)^\top].
$$

Then $g=Fw$. Coordinate by coordinate, for every $j$,

$$
\mathbb E\left[\psi_j(A)\sum_{k=1}^d\psi_k(A)w_k\right]
=\sum_{k=1}^d\mathbb E[\psi_j(A)\psi_k(A)]w_k.
$$

This compatible-function-approximation identity links value modeling to policy geometry. The matrix $F$ records how policy probabilities react to parameter changes. When it is invertible, the compatible weights satisfy $w=F^{-1}g$, the algebraic heart of a natural-gradient direction.

The statement is exact but deliberately limited. Compatibility alone is an identity, not a convergence theorem. To conclude that iterative learning converges to stationary points, one also needs assumptions about smoothness, step sizes, noise, and stability or compactness. To promise convergence specifically to a local maximum requires still more information about the objective’s landscape. Distinguishing the exact identity from these additional analytic requirements prevents an appealing formula from being oversold.

## Learning from a different policy

Exploration creates a second challenge. The target policy $t(a)$ describes the decisions whose performance we want to evaluate or improve, while the behavior policy $b(a)$ generates the data. If $b(a)>0$ wherever needed, the importance-weighted signal

$$
X(a)=\frac{t(a)}{b(a)}g(a)
$$

corrects the mismatch. Indeed, averaging under the behavior policy yields

$$
\mathbb E_{a\sim b}[X(a)]=\sum_a t(a)g(a).
$$

But a small behavior probability creates a large ratio. Unbiasedness can be purchased at the price of noise.

Assume an exploration guarantee: for some $\varepsilon>0$,

$$
b(a)\ge \varepsilon t(a)
$$

for every action. This covers a common mixture construction in which the behavior policy follows the target for an $\varepsilon$-controlled fraction of its mass, possibly with additional exploration. The guarantee implies

$$
\frac{t(a)}{b(a)}\le \frac{1}{\varepsilon}.
$$

The second moment of the estimator is

$$
\mathbb E_b[X(A)^2]
=\sum_a b(a)\left(\frac{t(a)}{b(a)}g(a)\right)^2
=\sum_a t(a)\frac{t(a)}{b(a)}g(a)^2.
$$

Applying the ratio bound action by action gives the explicit theorem

$$
\mathbb E_b[X(A)^2]
\le \frac{1}{\varepsilon}\sum_a t(a)g(a)^2
=\frac{1}{\varepsilon}\mathbb E_t[g(A)^2].
$$

Any variance known to be no larger than this second moment inherits the same upper bound. The message is operational: halving the exploration floor can double the worst-case second-moment guarantee. Exploration is not merely permission to visit unlikely actions; it controls the statistical conditioning of off-policy correction.

## Why the inverse law cannot be improved

Perhaps $1/\varepsilon$ is only an artifact of a loose inequality. A two-action example shows that it is exact.

Let the target always choose action $1$: $t=(1,0)$. Let the behavior policy choose action $1$ with probability $\varepsilon$ and action $2$ with probability $1-\varepsilon$: $b=(\varepsilon,1-\varepsilon)$. Let the signal be $g=(1,0)$. On the rare useful action, the importance-weighted value is $1/\varepsilon$; otherwise it is zero. Therefore

$$
\mathbb E_b[X(A)^2]
=\varepsilon\left(\frac{1}{\varepsilon}\right)^2
=\frac{1}{\varepsilon}.
$$

Meanwhile $\mathbb E_t[g(A)^2]=1$. The upper bound is attained exactly. No universal estimate with asymptotically smaller dependence on $\varepsilon$ can hold under only the exploration-floor assumptions.

This tiny example captures a universal tension. If the behavior policy almost never takes the action favored by the target, then the rare sample from that action must carry enormous weight to represent all the missing samples. Rarity and magnitude multiply to preserve the mean, but magnitude is squared in the second moment. The result is the inverse-exploration law.

## A small example with a large lesson

Consider a delivery drone choosing among three routes. Its policy assigns probabilities to the coastal, central, and mountain routes. Their values may combine travel time, energy use, and risk into one score. Raising one policy parameter shifts probability mass among the routes; the score records that shift action by action. The policy-gradient identity says that the value derivative can be recovered by weighting each route’s value with its score and probability.

Suppose weather adds the same large delay estimate to every route. That common offset can dominate the raw numerical values, yet it provides no information about which route should become more probable. A baseline removes the common part. Because the expected score is zero, the gradient is unchanged. If route values are approximated from score features, the compatible matrix describes how those features interact under the current route probabilities.

Now imagine that historical flights almost never used the coastal route even though the target policy favors it. Importance weighting can correct the historical imbalance, but every rare coastal observation must represent many missing flights. The coverage floor measures how severe that substitution can become. A floor of $\varepsilon=0.1$ permits a worst-case second-moment factor of $10$; a floor of $\varepsilon=0.01$ permits a factor of $100$. The law is not pessimistic bookkeeping: the two-action equality example proves that data can really behave this way.

The same story repeats across applications. Scores translate probability movement into derivatives, baselines remove irrelevant common levels, compatible features expose local geometry, and coverage determines whether off-policy evidence is statistically stable. Together they provide not a complete recipe for autonomous learning, but a reliable set of design constraints for any system that improves randomized choices from data.

## What the results mean in practice

The chain of ideas suggests a disciplined policy-gradient pipeline.

First, represent the derivative through scores and estimate $\psi(A)Q(A)$. Second, exploit the mean-zero score to subtract an action-independent baseline, choosing the baseline to reduce noise rather than to alter the objective. Third, if an advantage model is linear in score features, use the matrix identity $g=Fw$ to connect fitted coefficients with policy geometry. Fourth, when samples come from another policy, monitor the coverage constant $\varepsilon$: it is a direct certificate for second-moment growth.

These principles apply beyond robots and games. They appear whenever randomized decisions are tuned from sampled outcomes: online advertising, adaptive experiments, inventory control, communications, and personalized treatment policies. In every setting, a system must balance commitment to its current best decision against the need to gather informative data.

The mathematics also draws a boundary around what has and has not been established. Finite sums make the core identities transparent. They do not by themselves model evolving states, long trajectories, discounting, or the way a policy changes which states are visited. Nor does the compatible approximation identity alone guarantee convergence of an optimization algorithm. Those extensions require additional probability and analysis.

Still, the finite-action picture isolates something fundamental. Policy gradients work because differentiating probability mass produces a score-weighted expectation. Baselines work because normalized probability has zero derivative. Compatible approximations work because linearity turns score features into a second-moment matrix. Importance correction becomes noisy because insufficient exploration forces rare observations to carry reciprocal weight.

A learning agent may act by chance, but the structure governing how it learns is exact.
