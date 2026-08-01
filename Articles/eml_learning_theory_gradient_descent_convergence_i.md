# When Learning Becomes a Journey to the Median

## A tropical model with an unusually transparent training path

Many machine-learning systems are difficult to understand for the same reason that a crowded city is difficult to understand from street level: too many interactions happen at once. Parameters push and pull one another, nonlinearities switch on and off, and a training algorithm winds through a landscape with millions of dimensions. Convergence may be visible on a plot while remaining obscure in principle.

A tropical limit offers a different view. In tropical mathematics, addition and maximum replace some of ordinary algebra’s familiar operations. Models that were smoothly nonlinear can become piecewise linear, and a tangled optimization landscape can turn into a small collection of straight slopes joined at corners. The simplification does not make learning trivial. It makes the mechanism visible.

Consider the one-parameter tropical model

$$
f_\theta(z)=z+\theta.
$$

Its parameter $\theta$ translates every input by the same amount. This is a max-plus monomial, hence a basic tropical polynomial and also a tropical rational function. Suppose three reduced training targets are ordered as

$$
a\le m\le c.
$$

Using absolute error, the empirical loss of a parameter $\theta$ is

$$
L(\theta)=|\theta-a|+|\theta-m|+|\theta-c|.
$$

The middle observation $m$ is the median. It is also the unique minimizer of $L$. That familiar fact from robust statistics is the anchor of the whole story: tropical training becomes a controlled trip from an initial parameter $x$ to the median $m$.

## The optimizer as motion with a speed limit

Choose a positive step length $\eta$. After $n$ updates, let the cumulative travel budget be $t=n\eta$. The clipped tropical descent trajectory is

$$
G_t(x)=
\begin{cases}
\min\{m,x+t\}, & x<m,\\
\max\{m,x-t\}, & x\ge m.
\end{cases}
$$

The $n$th trained parameter is $\theta_n=G_{n\eta}(x)$. If the starting point lies below the median, the parameter moves upward at unit speed and stops at $m$. If it lies above, it moves downward and stops at $m$. The word “clipped” matters: the final move is shortened when necessary, so the trajectory lands on the target rather than overshooting it.

Imagine a train running along a perfectly straight track toward a station. It may travel at most $\eta$ units per update. Once its remaining distance is less than $\eta$, it uses only the distance needed to reach the platform. There is no oscillation and no asymptotic hovering.

This picture is captured by an exact distance law:

$$
|G_t(x)-m|=\max\{0,|x-m|-t\}.
$$

Consequently,

$$
|\theta_n-m|=\max\{0,|x-m|-n\eta\}.
$$

This is stronger than a conventional convergence estimate. It is not merely an upper bound; it gives the error exactly at every update. Before arrival, each update removes precisely $\eta$ units of error. After arrival, the error is exactly zero.

The formula immediately yields a finite stopping time. For $\eta>0$, the first guaranteed arrival occurs after

$$
N=\left\lceil\frac{|x-m|}{\eta}\right\rceil
$$

updates. For every $n\ge N$, $\theta_n=m$. Thus the sequence converges to $m$, but “converges” understates what happens: it becomes constant after finitely many steps.

## From parameter convergence to model convergence

A learning algorithm ultimately matters through its predictions. Here the bridge from parameters to functions is exact. For every input $z$,

$$
|f_\theta(z)-f_m(z)|=|(z+\theta)-(z+m)|=|\theta-m|.
$$

The prediction error is independent of $z$. Therefore the trained models $f_{\theta_n}$ converge pointwise to

$$
f_m(z)=z+m,
$$

and they do so at exactly the same rate as the parameter. Indeed, once $n\eta\ge |x-m|$, the entire learned function—not merely its value on the three samples—is identical to the minimizing model.

This produces a compact learning theorem. For three ordered targets $a\le m\le c$, any initial parameter $x$, and any positive step $\eta$, clipped tropical descent reaches $m$ in finitely many updates. The resulting tropical rational models converge at every input to $z\mapsto z+m$. The limit uniquely minimizes the three-sample absolute-error loss.

The uniqueness is worth emphasizing. For an odd number of observations, absolute loss selects a single central point. Moving $\theta$ slightly away from $m$ increases the combined distance because two of the three samples oppose the move while only one can favor it. The median is not an arbitrary destination inserted into the algorithm; it is forced by the geometry of the objective.

## A loss certificate at every step

Distance to the optimum is useful, but practitioners usually monitor loss. The three absolute-value terms obey the reverse triangle inequality. Changing $\theta$ to $m$ changes each term by at most $|\theta-m|$, so

$$
L(\theta)-L(m)\le 3|\theta-m|.
$$

Because $m$ minimizes $L$, the left-hand side is nonnegative. Substituting the exact training trajectory gives the explicit certificate

$$
0\le L(\theta_n)-L(m)
\le 3\max\{0,|x-m|-n\eta\}.
$$

The excess loss therefore falls beneath a linear envelope and vanishes after finitely many updates. The factor $3$ records the number of samples: each absolute-error term can change at unit rate with respect to the scalar parameter.

Take a concrete run with $m=1$, $x=-4$, and $\eta=2$. The parameters are

$$
-4,\;-2,\;0,\;1,\;1,\ldots
$$

The initial gap is $5$. Two full updates remove $4$ units, and the third update is clipped to the remaining unit. At input $z=7$, the trained model then returns $f_1(7)=8$. Every number in this example is predicted before the run begins by the exact error formula.

## The hidden ReLU network

Tropical piecewise-linear dynamics and rectified linear units are close relatives. Define the rectifier by

$$
\operatorname{ReLU}(u)=\max\{0,u\}.
$$

The entire clipped trajectory can be written as

$$
G_t(x)=m+\operatorname{ReLU}(x-m-t)
-\operatorname{ReLU}(m-x-t),
$$

for $t\ge0$. One shifted ReLU detects whether $x$ remains more than $t$ above the median; the other detects whether it remains more than $t$ below. Their signed difference reconstructs the central plateau at $m$ and the two outer linear branches.

At discrete time $n$, this becomes

$$
\theta_n=m+\operatorname{ReLU}(x-m-n\eta)
-\operatorname{ReLU}(m-x-n\eta).
$$

Thus every iterate of the tropical training process is represented exactly by a width-two ReLU expression. This is not an approximation or a similarity of shape. The outputs agree for every real starting point $x$.

The identity creates a clean comparison between two languages for piecewise-linear learning. Tropical notation describes motion toward a median through min and max operations. ReLU notation describes the same map through two hinges. The tropical view makes optimization and finite termination immediate; the ReLU view makes network realization immediate.

## Reading the geometry

The loss graph gives another way to see why the method is so decisive. Far to the left of all three observations, increasing $\theta$ shortens all three distances, so the graph descends steeply. Between $a$ and $m$, two distances are still shrinking while one is growing, and the graph continues downward with a gentler slope. Immediately after $m$, the balance reverses: two distances grow while one shrinks. The graph rises, first gently and then, beyond $c$, steeply. The sole bottom corner is therefore located at $m$.

This geometry also distinguishes clipping from an ordinary fixed-magnitude subgradient step. A rule that always moves exactly $\eta$ could jump from one side of $m$ to the other forever. Clipping replaces that last jump by a landing. In optimization language, $m$ is an absorbing state. In dynamical language, the interval of starting points that have reached $m$ by time $t$ is $[m-t,m+t]$, and this capture interval expands linearly. The two ReLU hinges sit exactly at its moving boundaries.

There is an appealing practical consequence. The optimizer needs no vague stopping tolerance in exact arithmetic. Before training begins, one can calculate the number of updates needed from the initial gap and the step length. One can also certify every intermediate prediction and bound its excess loss. The training log is not merely evidence of progress; it is the realization of a formula known in advance.

## Why this small model matters

A one-parameter translation neuron is not a modern large network in miniature. Its value lies elsewhere: it isolates a mechanism that is usually hidden. The median arises from absolute loss; clipping prevents overshoot; piecewise linearity turns convergence into a distance identity; and two rectifiers encode the complete dynamical map.

These ingredients occur in robust estimation, quantile methods, signal correction, and architectures designed for max-plus or large-weight regimes. Whenever a complicated model separates into scalar coordinates or local linear regions, this analysis suggests what to seek: an exact residual law rather than only an asymptotic rate, a finite active-set transition rather than endless decay, and a direct translation between tropical and rectifier descriptions.

The result also clarifies what assumptions do the work. The positivity of $\eta$ ensures progress. The ordered triple makes $m$ the unique median. The clipping rule guarantees capture rather than oscillation. The translation form makes parameter error equal prediction error. Remove any one of these features and the conclusion may change.

Several extensions beckon. With any odd number of samples, absolute loss again has a unique median, suggesting the same finite-arrival picture. For an even number, the minimizers form the interval between the two central observations, so the natural destination is a plateau rather than a point. In multiple dimensions with separable losses, coordinates can travel independently and the slowest coordinate sets the total stopping time. Small perturbations should replace exact capture by entry into a controlled neighborhood. Finally, the two-ReLU formula raises a sharp expressivity question: the two-sided clipped map has two hinges, suggesting that one ordinary ReLU cannot represent it when the plateau has positive width.

The broader lesson is that a limit can reveal structure rather than merely discard detail. In the tropical regime, training is no longer a mysterious descent through a curved landscape. It is a measured journey along a line, aimed at the robust center of the data, with an odometer that tells us exactly how far remains.