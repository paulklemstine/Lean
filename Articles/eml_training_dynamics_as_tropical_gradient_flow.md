# The Median Is a Destination: Tropical Training in Three Data Points

Modern machine learning is often described in the language of smooth landscapes. A model sits somewhere on a rolling surface of error; training follows the downhill slope; and, with luck, the parameters settle into a valley. That picture is useful, but it is not universal. Some important models live in landscapes made not of rolling hills but of facets, ridges, and corners. Their natural geometry is **tropical geometry**, where maxima, minima, and addition replace much of ordinary curved algebra.

In this angular world, training can become startlingly transparent. For a single tropical neuron trained on three observations, the entire optimization problem reduces to a familiar act: finding the median. The training trajectory is not merely convergent in the distant limit. It marches directly toward the median at unit speed, arrives after a precisely known amount of time, and then stops forever.

That small model reveals a broad idea. Robust statistics, piecewise-linear dynamics, and neural optimization are not separate stories here. They are three descriptions of the same mechanism.

## From tropical neurons to three targets

A tropical neuron combines inputs through max-affine or min-affine operations. In a scalar projective chart, one remaining parameter can be represented by a real number $x$. After each fixed tropical feature value is subtracted from its corresponding label, three training observations become three reduced targets. Write them in increasing order as

$$
a\le m\le c.
$$

The letters suggest their roles: $a$ is the lower target, $c$ the upper target, and $m$ the middle target. Under absolute-error training, the empirical loss is

$$
L(x)=|x-a|+|x-m|+|x-c|.
$$

This is a continuous, convex, piecewise-linear function. Each absolute value contributes a V-shaped graph. Adding the three graphs produces a polygonal valley whose only lowest point is $m$.

This gives the first central result, the **Three-Point Median Theorem**: if $a\le m\le c$, then

$$
L(m)\le L(x)
$$

for every real $x$, and equality at the global minimum occurs only when $x=m$.

Why? The two outside observations already impose a basic toll. By the triangle inequality,

$$
|x-a|+|x-c|\ge c-a.
$$

At $x=m$, the outer distances exactly fill the interval from $a$ to $c$:

$$
|m-a|+|m-c|=(m-a)+(c-m)=c-a.
$$

The middle residual also vanishes there. Thus $L(m)=c-a$. Anywhere else, the middle term $|x-m|$ is positive, and a direct examination of the linear pieces shows strict increase away from $m$. To the left of $m$, moving right lowers the loss; to the right, moving left lowers it.

This is the classical robustness of the median appearing inside tropical training. A distant outlier can pull the mean dramatically, but among three ordered targets it cannot dislodge the absolute-loss optimum from the middle observation.

## A flow made of straight lines

Knowing the destination is not the same as understanding the journey. To describe training, choose a nonnegative elapsed time $t$ and define the clipped unit-speed flow

$$
\Phi_t(x)=
\begin{cases}
\min\{m,x+t\},&x<m,\\
\max\{m,x-t\},&x\ge m.
\end{cases}
$$

If the current parameter lies below the median, it increases at speed one. If it lies above the median, it decreases at speed one. The minimum and maximum prevent overshooting. This is a piecewise-linear subgradient flow adapted to the nonsmooth corner of the loss.

The formula can be read without calculus. Imagine $x$ as a bead on a wire and $m$ as a magnetic notch. The bead travels toward the notch at constant speed. Once it reaches the notch, the clipping rule locks it in place.

The **Finite-Time Arrival Theorem** says that whenever

$$
|x-m|\le t,
$$

we have

$$
\Phi_t(x)=m.
$$

The proof is embedded in the definition. If $x<m$, the condition says $x+t\ge m$, so $\min\{m,x+t\}=m$. If $x\ge m$, it says $x-t\le m$, so $\max\{m,x-t\}=m$. Consequently, a trajectory initialized at $x_0$ reaches its destination no later than time

$$
T=|x_0-m|.
$$

In fact the full trajectory for $t\ge0$ can be written as

$$
\Phi_t(x_0)=m+\operatorname{sgn}(x_0-m)\max\{|x_0-m|-t,0\}.
$$

Its distance to the optimum obeys the exact law

$$
|\Phi_t(x_0)-m|=\max\{|x_0-m|-t,0\}.
$$

There is no asymptotic tail, no slowing crawl, and no oscillation. The error decreases linearly until it becomes zero.

## When optimization and stationarity coincide

A fixed point is a state that training leaves unchanged. Here one must ask for invariance under every positive duration: a point $x$ is stationary when

$$
\Phi_t(x)=x
$$

for every $t>0$.

The **Fixed-Point Characterization Theorem** states that this happens exactly when $x=m$. One direction is immediate: starting at the median leaves nothing to change. Conversely, if $x\ne m$, choose more time than its distance from $m$. The finite-time arrival theorem sends it to $m$, which differs from $x$; therefore it cannot have been fixed.

Combining this statement with the median theorem produces the main bridge:

> For three ordered reduced targets, a parameter minimizes the tropical absolute-error loss if and only if it is fixed by every positive-time training map. Moreover, every initialization reaches this unique point in finite time and hence converges to it.

This equivalence joins three concepts that are often studied separately:

1. **Statistical optimality:** $x$ minimizes the sum of absolute residuals.
2. **Dynamical stationarity:** every positive-time flow leaves $x$ unchanged.
3. **Order geometry:** $x$ is the median of the three reduced targets.

For this model, these are not merely related properties. They select exactly the same real number.

## A numerical walk through the landscape

Take the reduced targets

$$
(a,m,c)=(-2,1,5).
$$

At the median, the loss is

$$
L(1)=|1+2|+|1-1|+|1-5|=3+0+4=7.
$$

At $x=-1$ it is

$$
L(-1)=1+2+6=9,
$$

and at $x=4$ it is

$$
L(4)=6+3+1=10.
$$

Now initialize at $x_0=-2$. The distance to the median is $3$, so the trajectory is $-2,-1,0,1$ at integer times from $0$ through $3$. At time $3$ it arrives exactly. Initialize instead at $x_0=5$ and allow time $10$; clipping prevents the point from crossing to the other side, so the result is still $1$.

These examples expose the whole geometry. The loss is polygonal, the optimum is the center target, and training follows a straight route to it.

## Why the tropical viewpoint matters

Large-scale or low-temperature limits often turn smooth functions such as log-sum-exp into maxima. Curved response surfaces sharpen into polyhedral ones. In that regime, a derivative may jump abruptly at a boundary, yet the resulting dynamics can become easier to describe because each region has a simple linear rule.

The three-sample model is the smallest setting in which several essential phenomena coexist: nonsmooth loss, an order-statistical optimum, a clipped subgradient trajectory, a fixed-point principle, and global convergence from arbitrary initialization. It functions as a clean laboratory for larger tropical networks, where activation patterns divide parameter space into many polyhedral cells.

There are practical lessons as well. Absolute loss protects against extreme labels. Exact arrival gives a stopping certificate: once elapsed continuous time covers the initial distance to the median, optimization is complete. The formula also makes perturbation intuitive. If the data change without changing which reduced target is in the middle, the destination moves exactly with that middle target rather than being dragged by both extremes.

## The edge of the simple picture

Three observations give a unique median, but richer data introduce new geometry. For any odd number of unweighted scalar observations, the absolute-loss optimizer is again the median. For an even number, every point in the interval between the two central observations minimizes the loss; the destination may no longer be unique. Weighted observations lead to weighted medians. Multiple tropical neurons create interacting max-affine pieces and higher-dimensional polyhedral landscapes.

Discrete optimization also differs from continuous flow. A constant-size update can leap across the median and oscillate, whereas the clipped flow never overshoots. Diminishing step sizes or an explicit clipping rule are natural ways to recover convergence.

Another frontier is to start from a smooth, finite-scale neuron and prove that both its loss and its training trajectories approach this polygonal model as the tropical scale grows. That would connect ordinary differentiable training to the exact median-seeking dynamics described here.

## A model one can audit by eye

There is another virtue in the example’s simplicity: every ingredient can be inspected directly. The loss at any proposed parameter is just the total walking distance to three marked points on a line. The optimizer is found by ordering those points. The state after time $t$ is obtained by subtracting $t$ from the initial distance and clipping the result at zero. These are not black-box calculations; they are geometric facts visible in a sketch.

That transparency makes the model useful for teaching and testing. A new optimization rule can be compared against the exact trajectory. A numerical implementation can check that it never crosses $m$, that distance falls at unit rate before arrival, and that the state remains constant afterward. More elaborate tropical systems will not always admit formulas this compact, but this solvable case supplies a benchmark: any approximation meant to capture median-seeking tropical training should reproduce its direction, stopping behavior, and fixed point.

## A small theorem with a broad message

The usual metaphor of learning as a ball rolling down a smooth hill hides what happens at corners. Tropical geometry offers a different image: a traveler crossing flat facets, changing direction at sharp walls, and sometimes reaching the destination in finite time.

For one neuron and three reduced observations, that destination is completely determined. It is the median. It is the unique minimizer of the absolute-error landscape. It is the unique state fixed by every positive training time. Every trajectory reaches it after traveling exactly its initial distance.

In one compact model, optimization becomes geometry, geometry becomes dynamics, and dynamics rediscovers one of statistics’ oldest robust estimators. The median is not just an answer computed after training. It is the place toward which the entire tropical system is built to move.
