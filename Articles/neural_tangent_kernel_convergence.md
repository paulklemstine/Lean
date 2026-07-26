# When a Neural Network Becomes a Kernel Machine

## The quiet mathematics of lazy training

A modern neural network may contain millions or billions of adjustable parameters. During training, those parameters move through an immense landscape, guided by gradients computed from data. The usual picture is one of ceaseless internal change: features emerge, representations reorganize, and the network gradually discovers a useful way to see the world.

Yet there is another regime in which the network barely changes its internal geometry. Its parameters move, but the map from parameter motion to prediction motion remains essentially fixed. In this **lazy-training regime**, the apparent complexity of the network gives way to a remarkably simple law. On a finite training set, the errors follow a linear recurrence governed by a matrix called the **neural tangent kernel**, or NTK.

This reduction matters because linear dynamics can be understood exactly. It reveals when training converges, how quickly each component of the error disappears, and why very different architectures can follow precisely the same prediction trajectory. It also exposes the boundary of the conclusion: a positive semidefinite kernel is not enough by itself, because directions in its nullspace may never be corrected.

The central story is therefore not that every neural network is simple. It is that whenever the network’s tangent geometry freezes, its training behavior is controlled by a compact, architecture-independent dynamical principle.

## From predictions to residuals

Suppose a model is evaluated on a finite training set. Collect its predictions into a vector $f_n$ after $n$ gradient steps, and collect the desired outputs into a target vector $y$. Define the residual by

$$
r_n=f_n-y.
$$

The residual is the model’s signed error on the entire training set. Reaching perfect interpolation means $r_n\to 0$, which is equivalent to $f_n\to y$.

In the frozen-kernel regime, one gradient step acts on the residual as

$$
r_{n+1}=r_n-\eta K r_n=(I-\eta K)r_n,
$$

where $K$ is the empirical NTK, $I$ is the identity operator, and $\eta$ is the learning rate. The associated predictions are simply

$$
f_n=y+r_n.
$$

This is the decisive simplification. Instead of tracking every parameter, one studies repeated application of the fixed update operator $I-\eta K$.

The recurrence is meaningful in any normed vector space, not only in ordinary Euclidean coordinates. That abstraction strips the argument down to its real engine: contraction.

## The geometric contraction law

Call an update map $S$ a contraction with factor $q$ if

$$
\|S(r)\|\le q\|r\|
$$

for every residual $r$, where $0\le q<1$. If the residual trajectory is defined by $r_{n+1}=S(r_n)$, then repeated contraction gives the **Geometric Residual Bound**:

$$
\|r_n\|\le q^n\|r_0\| \qquad \text{for every } n\ge 0.
$$

The proof is a one-line idea repeated by induction. It is true at $n=0$. If it is true at step $n$, then

$$
\|r_{n+1}\|\le q\|r_n\|\le q\bigl(q^n\|r_0\|\bigr)=q^{n+1}\|r_0\|.
$$

Because $q^n\to 0$ whenever $0\le q<1$, the residual converges to zero. This yields the **Frozen-NTK Convergence Theorem**: if the operator $I-\eta K$ obeys

$$
\|r-\eta Kr\|\le q\|r\|
$$

for all $r$ and some $0\le q<1$, then the lazy-training predictions satisfy

$$
f_n\to y.
$$

Even better, the theorem provides a quantitative deadline. To guarantee $\|r_n\|\le \delta$, it suffices to choose $n$ so that $q^n\|r_0\|\le\delta$. For $0<q<1$ and $0<\delta<\|r_0\|$, one may take

$$
n\ge \frac{\log(\delta/\|r_0\|)}{\log q}.
$$

Both logarithms in this ratio are negative, so the bound is positive. The closer $q$ is to zero, the faster convergence occurs; the closer it is to one, the longer the tail.

## Every eigendirection has its own clock

The contraction factor summarizes the worst case, but the kernel’s spectrum gives a sharper picture. Suppose $v$ is an eigenvector of $K$ with eigenvalue $\lambda$, so that

$$
Kv=\lambda v.
$$

A single update sends this direction to

$$
(I-\eta K)v=(1-\eta\lambda)v.
$$

After $n$ steps, the **Exact Spectral Decay Theorem** states that

$$
(I-\eta K)^n v=(1-\eta\lambda)^n v.
$$

The proof again follows by induction: each step contributes one more factor of $1-\eta\lambda$.

This formula turns training into a collection of scalar clocks. A component aligned with a large positive eigenvalue can decay rapidly, while a component aligned with a small positive eigenvalue may linger. If $|1-\eta\lambda|<1$, that component converges to zero. If the factor is negative, the component alternates sign while shrinking. If its absolute value exceeds one, the component grows and training is unstable.

The equation also identifies a subtle failure mode. When $\lambda=0$, the factor equals $1$, regardless of the learning rate. The residual component in that null direction never moves. Thus positive semidefiniteness alone does not guarantee interpolation. Strict contraction requires every residual direction under consideration to be controlled.

For a positive eigenvalue, the scalar stability condition is

$$
0<\eta\lambda<2.
$$

In a finite-dimensional self-adjoint setting, checking all eigenvalues turns the global contraction question into a spectral one. The present convergence principle assumes the contraction explicitly; the exact eigenvector formula explains what that assumption means mode by mode.

## When architecture disappears

Neural networks can look radically different. One may be deep and narrow, another shallow and wide; one may have redundant parameters, another a highly symmetric representation. In the lazy regime, however, prediction dynamics depend on the architecture only through the frozen kernel, together with the learning rate, targets, and initialization.

This gives the **Equal-Kernel Universality Theorem**. Consider two models with kernels $K_1$ and $K_2$, the same learning rate $\eta$, the same target $y$, and the same initial prediction. If

$$
K_1=K_2,
$$

then their residuals and predictions are identical at every training step.

The reason is exact rather than asymptotic. Both models begin from the same residual and apply the same update map $I-\eta K$ repeatedly. Consequently, there is no opportunity for their prediction paths to diverge.

An even more economical result is possible. Global equality of the two kernels is stronger than necessary. Suppose the two residual paths are $r_n^{(1)}$ and $r_n^{(2)}$, and assume that at every step their kernel actions agree:

$$
K_1r_n^{(1)}=K_2r_n^{(2)}.
$$

Then the **Pathwise Kernel Universality Theorem** says

$$
r_n^{(1)}=r_n^{(2)}
$$

for every $n$, provided the initial residual is shared. Indeed, if the residuals agree at step $n$ and the kernel actions also agree, subtracting $\eta$ times those actions produces equal residuals at step $n+1$.

This pathwise version changes the conceptual unit of comparison. Two architectures need not implement the same operator everywhere in prediction space. They need only be indistinguishable on the states that training actually visits.

## Tropical cells as rooms with fixed dynamics

Where might an exactly frozen kernel come from? One concrete mechanism arises in piecewise-linear or tropical geometry. Parameter space can be divided into cells according to an activation or combinatorial pattern. Within one cell, the relevant Jacobian structure—and therefore the kernel matrix—may remain constant.

Let $c(\theta)$ denote the cell containing a parameter vector $\theta$, let $K(\theta)$ be the associated kernel matrix, and let $\theta(t)$ be a training trajectory over $0\le t<T$. Assume the kernel is **cellwise constant**, meaning

$$
c(\theta)=c(\theta') \quad\Longrightarrow\quad K(\theta)=K(\theta').
$$

If the trajectory remains in its initial cell,

$$
c(\theta(t))=c(\theta(0)) \qquad \text{for all } 0\le t<T,
$$

then the **Tropical Cell Freezing Theorem** concludes that

$$
K(\theta(t))=K(\theta(0)) \qquad \text{for all } 0\le t<T.
$$

The argument is direct: every point on the path has the same cell label, and the kernel is constant on each cell. But its interpretation is powerful. A geometric condition—remaining inside one chamber—certifies an analytic condition—a frozen linear training law.

This suggests picturing training as motion through a building. Inside a room, the floor is flat and the rules of motion are fixed. Crossing a wall changes the active pattern and may change the kernel. Lazy training is the period spent inside one room; feature learning begins when the trajectory encounters the architecture’s walls.

## What the principle does—and does not—say

The combined picture has three layers.

First, geometry can freeze the kernel. Tropical cell confinement is one exact certificate.

Second, the frozen kernel creates a linear residual recursion. Its eigenvalues determine the decay or growth of individual modes.

Third, strict contraction makes the residual vanish geometrically and makes prediction converge to the target. Models sharing the same effective kernel action share the same trajectory.

The result concerns predictions on a finite training set. It does not claim that the model parameters converge, that every positive semidefinite kernel contracts, or that an infinite-width or probabilistic limit has been established. These distinctions are essential. A model may possess parameter symmetries that allow movement without changing predictions, and a singular kernel may leave some errors untouched.

Nor does universality mean that architecture never matters. Architecture determines the kernel, the initial predictions, whether the kernel remains frozen, and what happens away from the training set. The theorem says something more precise: once the frozen kernel, learning rate, target, and initialization are fixed, the training-set prediction trajectory is fixed as well.

## A practical diagnostic

For a finite dataset, the principle suggests a clean workflow:

1. Form the initial residual $r_0=f_0-y$.
2. Determine whether the kernel remains constant over the time interval of interest.
3. Study the operator $I-\eta K$ or, when appropriate, the eigenvalues of $K$.
4. Estimate a contraction factor $q<1$.
5. Use $\|r_n\|\le q^n\|r_0\|$ to forecast convergence.
6. Compare architectures through their kernel actions along the realized trajectories.

These steps transform a large parameter-space problem into matrix dynamics on the training examples. In numerical experiments, one can directly plot $\|r_n\|$ beside the envelope $q^n\|r_0\|$, decompose the initial residual into eigenvectors, and watch each spectral component decay at its predicted rate.

## The larger lesson

The neural tangent kernel is often introduced as a bridge between neural networks and classical kernel methods. The frozen-dynamics viewpoint makes that bridge concrete. It says that a network can retain an elaborate parameterization while its observable training behavior collapses to repeated multiplication by one operator.

The most striking consequence is universality through effective dynamics. Two architectures can be different in every visible engineering detail and still become the same learning system on a given dataset. Conversely, a tiny uncontrolled direction in the kernel can prevent exact interpolation no matter how impressive the architecture appears.

Lazy training is therefore a study in mathematical compression. Geometry decides whether the kernel freezes. Spectrum decides how error modes evolve. Contraction decides convergence. And kernel action, rather than architectural appearance, decides the prediction path.