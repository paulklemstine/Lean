# When a Neural Network Becomes a Kernel

## The hidden geometry of wide-network training

A modern neural network may contain millions or billions of adjustable parameters. During training, all of those numbers move, layer after layer, in response to errors on the data. From close up, the process looks impossibly complicated: a nonlinear function changes because a high-dimensional parameter vector follows a sequence of gradients, and each gradient depends on the current network.

Yet in an important regime, this turbulent picture has a remarkably calm mathematical core. A sufficiently wide network, moved by sufficiently small steps, can behave like a fixed linear machine in prediction space. Its effective engine is the **neural tangent kernel** (NTK): a matrix that records how similarly the network's outputs respond to infinitesimal changes in its parameters.

The idea is not that a neural network is linear in its inputs. It usually is not. The idea is that, near its initial parameters, it can be approximately linear in its *parameters*. If the parameter sensitivities barely change during training, then a single matrix computed from those sensitivities controls the whole trajectory. Training becomes kernel gradient descent, and convergence becomes a question about contraction by a positive semidefinite matrix.

This article develops that finite-data mechanism from beginning to end. It identifies what is always true, what needs an additional spectral assumption, and how bounded movement makes the fixed-kernel picture quantitatively plausible.

## From parameters to a geometry on examples

Suppose a model has $p$ real parameters and is evaluated on $n$ training examples. At the current parameter value, form an $n\times p$ Jacobian matrix $J$. Its entry $J_{ia}$ measures how the prediction on example $i$ changes when parameter $a$ is nudged.

The row $J_i$ is therefore a feature vector attached to example $i$, but its coordinates are not ordinary input features. They are *sensitivity features*: directions in which the model can change that example's prediction.

The neural tangent kernel is the Gram matrix of these rows:

$$
K_{ik}=\sum_{a=1}^{p}J_{ia}J_{ka}.
$$

If $K_{ik}$ is large and positive, examples $i$ and $k$ tend to move together under a parameter update. If it is negative, their local responses oppose one another. If it vanishes, their sensitivity vectors are orthogonal.

This definition immediately gives the **Symmetry Theorem**: for every pair of examples,

$$
K_{ik}=K_{ki}.
$$

More importantly, it gives positivity. For any residual vector $r\in\mathbb{R}^n$, define the kernel action by

$$
(Kr)_i=\sum_{k=1}^{n}K_{ik}r_k
$$

and the parameter-space gradient induced by $r$ by

$$
g_a=\sum_{i=1}^{n}J_{ia}r_i.
$$

Then the **Energy Identity** states

$$
r^{\mathsf T}Kr=\sum_{a=1}^{p}g_a^2=\lVert J^{\mathsf T}r\rVert_2^2.
$$

This is simply a rearrangement of finite sums, but it is the structural heart of the theory. The right side is a sum of squares, so it can never be negative. Thus the **Gram Positivity Theorem** says that every neural tangent kernel is positive semidefinite:

$$
r^{\mathsf T}Kr\ge 0\qquad\text{for every }r\in\mathbb{R}^n.
$$

Positivity is automatic; strict positivity is not. If the Jacobian cannot respond to some pattern of errors, then $J^{\mathsf T}r=0$ for a nonzero $r$, and the kernel has a null direction. This distinction will matter for convergence.

## The bridge from gradient descent to kernel motion

Why should this Gram matrix govern learning? Consider a residual vector $r$, for example target minus prediction. The associated parameter gradient is $g=J^{\mathsf T}r$. A linearized parameter step changes the prediction on example $i$ by the inner product of $J_i$ with $g$. The **Jacobian–Kernel Correspondence** states exactly that

$$
\sum_{a=1}^{p}J_{ia}g_a=(Kr)_i.
$$

In matrix notation, the statement is the familiar identity $J(J^{\mathsf T}r)=(JJ^{\mathsf T})r$. It explains the role of the kernel: parameters mediate the update, but after eliminating them, prediction space sees only $K=JJ^{\mathsf T}$.

Let $y\in\mathbb{R}^n$ be the target vector, $f_t\in\mathbb{R}^n$ the predictions after $t$ steps, and $\eta$ the learning rate. Fixed-kernel training is

$$
f_{t+1}=f_t+\eta K(y-f_t).
$$

Writing $r_t=y-f_t$, subtraction gives the **Residual Recurrence Theorem**:

$$
r_{t+1}=(I-\eta K)r_t.
$$

Consequently, the **Trajectory Representation Theorem** gives the complete solution

$$
r_t=(I-\eta K)^t r_0,
$$

where $r_0=y-f_0$. No approximation is involved in these two statements once fixed-kernel training has been defined. They expose the entire optimization problem as repeated application of one linear residual operator.

## Geometric convergence—and its real hypothesis

Define the squared error energy by $\lVert r\rVert_2^2=\sum_i r_i^2$. Suppose there is a number $q\ge 0$ such that every vector contracts in one step:

$$
\lVert(I-\eta K)v\rVert_2^2\le q\lVert v\rVert_2^2
\qquad\text{for every }v\in\mathbb{R}^n.
$$

Then the **Geometric Residual Theorem** states that

$$
\lVert r_t\rVert_2^2\le q^t\lVert r_0\rVert_2^2.
$$

The proof is induction in its purest form. The first step multiplies the energy by at most $q$; applying the same bound repeatedly multiplies it by at most $q^t$. When $0\le q<1$, the training error tends to zero geometrically.

For an NTK $K=JJ^{\mathsf T}$, this becomes the **NTK Training Theorem**: if the residual operator $I-\eta JJ^{\mathsf T}$ has the uniform squared-norm contraction factor $q$, then

$$
\lVert y-f_t\rVert_2^2\le q^t\lVert y-f_0\rVert_2^2.
$$

The wording matters. Positive semidefiniteness alone does not guarantee $q<1$. A zero eigenvalue preserves some residual component forever. An excessively large learning rate can make a positive eigenmode oscillate with increasing magnitude. If the relevant eigenvalues of $K$ lie between $\lambda_{\min}>0$ and $\lambda_{\max}$, then choosing $0<\eta<2/\lambda_{\max}$ yields

$$
q=\max_{\lambda\in\operatorname{spec}(K)}|1-\eta\lambda|^2<1.
$$

Thus the geometry of the Jacobian supplies nonnegative eigenvalues, while spectral coverage and step size supply strict convergence.

## Why the kernel can remain nearly frozen

A real neural network does not generally keep the same Jacobian. Its parameters move, so $J$ and $K$ move too. The fixed-kernel account needs a stability estimate.

Take two Jacobians $J^{(0)}$ and $J^{(1)}$. Assume every entry of both has magnitude at most $B$, and every entry changes by at most $\delta$:

$$
|J^{(0)}_{ia}|\le B,\qquad |J^{(1)}_{ia}|\le B,
\qquad |J^{(1)}_{ia}-J^{(0)}_{ia}|\le\delta.
$$

Then the **Entrywise NTK Stability Theorem** states that each kernel entry obeys

$$
|K^{(1)}_{ik}-K^{(0)}_{ik}|\le 2pB\delta.
$$

To see why, split the change in one product:

$$
J^{(1)}_{ia}J^{(1)}_{ka}-J^{(0)}_{ia}J^{(0)}_{ka}
=J^{(1)}_{ia}(J^{(1)}_{ka}-J^{(0)}_{ka})
+J^{(0)}_{ka}(J^{(1)}_{ia}-J^{(0)}_{ia}).
$$

Each term has magnitude at most $B\delta$, so each parameter coordinate contributes at most $2B\delta$. Summing over $p$ coordinates gives the bound.

The factor $p$ is not a defect; it reveals the need for width normalization. In common wide-network parameterizations, individual Jacobian entries shrink with width, and the combination $pB\delta$ may remain bounded or vanish.

A pathwise version makes the learning-rate dependence explicit. Suppose a scalar parameter coordinate $\theta$ starts at $\theta_0$, the Jacobian entries are bounded by $B$, and they satisfy the Lipschitz estimate

$$
|J(\theta)_{ia}-J(\theta_0)_{ia}|\le L|\theta-\theta_0|.
$$

If after $t$ steps the path remains within

$$
|\theta_t-\theta_0|\le t\eta G,
$$

then the **Near-Constancy Along Training Theorem** gives

$$
|K(\theta_t)_{ik}-K(\theta_0)_{ik}|
\le 2pBLt\eta G.
$$

Small steps, short paths, smooth Jacobians, and appropriate width scaling therefore keep the kernel close to its initial value.

## A small spectrum with a large lesson

A three-coordinate example makes the convergence mechanism visible. Imagine that the sensitivity directions have been chosen so that the kernel has eigenvalues $1$, $2$, and $3$. Along these three special residual patterns, multiplication by $K$ simply scales by the corresponding eigenvalue. Choose learning rate $\eta=1/2$. The residual update then has multipliers $1/2$, $0$, and $-1/2$.

The three modes tell different stories. The first shrinks by half at every step. The second disappears immediately because the step lands exactly on its target. The third also shrinks by half in magnitude, but flips sign each time: an overshoot, then a smaller overshoot in the opposite direction. Since squared magnitude ignores the sign, every surviving mode loses at least three quarters of its energy per step. Thus $q=1/4$, and the total squared residual obeys

$$
\lVert r_t\rVert_2^2\le 4^{-t}\lVert r_0\rVert_2^2.
$$

Now add a fourth thought experiment: a zero eigenvalue. Its residual multiplier is $1$, regardless of how small the positive learning rate is. That error component never changes. This is why a singular kernel may fit part of a target perfectly while leaving another part untouched. The relevant question is not merely whether the kernel is nonnegative, but whether the target residual lies in the range that the sensitivity features can reach.

The example also suggests how practitioners can diagnose training. Estimate the largest kernel eigenvalue to avoid unstable steps, examine the smallest nonzero eigenvalues to identify slow directions, and test whether the target has a component in the numerical nullspace. These are statements about an $n\times n$ matrix on examples, even when the original model has vastly more than $n$ parameters. The kernel converts parameter abundance into sample geometry.

## What the infinite-width slogan really means

The often-heard slogan “an infinitely wide neural network is a kernel method” compresses several logically distinct facts.

First, the Jacobian always creates a symmetric positive semidefinite Gram kernel. Second, linearized gradient descent always projects to the kernel residual recurrence. Third, contraction of that recurrence yields geometric convergence. Fourth, bounded Jacobian drift controls how far the changing empirical kernel can move from its initial value.

Infinite width enters not into the finite-dimensional algebra, but into the probabilistic and scaling arguments that can make drift small and the initial random kernel close to a deterministic limit. Once those ingredients hold, network predictions track kernel regression. The deterministic core tells us exactly what such a limit theorem must supply.

This separation also clarifies the boundary between “lazy” learning and feature learning. In the lazy regime, the sensitivity features $J_i$ barely rotate or stretch, so training mainly adjusts coefficients in an almost fixed feature space. Beyond that regime, kernel drift becomes order one, and representation change is no longer a perturbation—it is the phenomenon.

The NTK lens therefore does more than simplify a difficult dynamical system. It gives a diagnostic language. Gram positivity says which motions cannot increase energy infinitesimally. The residual spectrum predicts speed and identifies unreachable error patterns. The drift bound measures when yesterday's geometry remains useful tomorrow. Together, these ideas turn a vast parameter update into a comprehensible story: a geometry on examples, a linear recurrence, a contraction rate, and a controlled departure from the frozen world.