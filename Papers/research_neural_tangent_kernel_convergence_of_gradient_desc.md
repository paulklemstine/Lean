# Neural Tangent Kernels: Gram Geometry, Stable Linearization, and Geometric Gradient-Descent Convergence

**Aristotle**  
**July 26, 2026**

## Abstract

This paper isolates a deterministic finite-sample mechanism underlying neural tangent kernel (NTK) descriptions of wide-network training. For a model evaluated on $n$ samples with $p$ parameters, the sample Jacobian $J\in\mathbb{R}^{n\times p}$ induces the kernel $K=JJ^{\mathsf T}$. We establish its symmetry and positive semidefiniteness through the exact energy identity $r^{\mathsf T}Kr=\lVert J^{\mathsf T}r\rVert_2^2$. We then show that a linearized parameter-gradient update acts on predictions exactly by $K$, so fixed-kernel gradient descent has residual recurrence $r_{t+1}=(I-\eta K)r_t$ and trajectory $r_t=(I-\eta K)^t r_0$. A uniform one-step squared-norm contraction with factor $q\ge0$ yields the finite-time estimate $\lVert r_t\rVert_2^2\le q^t\lVert r_0\rVert_2^2$. Finally, if two Jacobians are entrywise bounded by $B$ and differ entrywise by at most $\delta$, their kernels differ entrywise by at most $2pB\delta$. A Lipschitz Jacobian along a path of radius at most $t\eta G$ consequently gives kernel drift at most $2pBLt\eta G$. These results separate Gram positivity, optimization contraction, and kernel stability, thereby identifying the precise deterministic inputs needed to justify convergence toward a fixed-kernel or infinite-width regime.

## 1. Introduction

Neural-network training couples nonlinear function approximation to optimization in a high-dimensional parameter space. Even on a finite dataset, the predictions depend nonlinearly on the parameters, the parameter gradient depends on all samples, and the local geometry changes along the training path. The neural tangent kernel viewpoint reorganizes this complexity around a matrix of parameter sensitivities.

For each training example, the model Jacobian supplies a vector whose coordinates describe infinitesimal response to each parameter. Inner products of these vectors form a Gram matrix. This matrix is the neural tangent kernel on the sample. It simultaneously describes which examples respond similarly to parameter perturbations and how a parameter-space gradient is seen after projection back to prediction space.

The infinite-width interpretation is often stated as a single conclusion: wide-network gradient descent approaches kernel regression. Logically, however, that conclusion combines several components:

1. the neural tangent kernel has Gram structure and is therefore symmetric positive semidefinite;
2. linearized parameter descent induces an exact kernel action on sample predictions;
3. the fixed-kernel residual operator contracts under an appropriate spectral and learning-rate condition;
4. the empirical Jacobian, and hence the empirical kernel, changes little along training;
5. in a probabilistic wide-network model, the initial empirical kernel concentrates around a deterministic limit.

The first four items admit a self-contained deterministic treatment. That treatment is the subject of this paper. It does not assert probabilistic concentration for any particular architecture, nor does it infer strict convergence from positive semidefiniteness alone. Instead, it proves an exact algebraic core and makes the necessary contraction hypothesis explicit. This is useful because null directions and overly large learning rates are genuine obstructions that should not be hidden inside a broad slogan.

Our main contributions are as follows. First, we derive an energy identity that equates kernel energy with squared parameter-gradient norm. Second, we identify the exact residual trajectory of fixed-kernel training and prove a geometric error theorem from a one-step contraction. Third, we quantify the entrywise effect of Jacobian drift on the kernel. Fourth, we combine Lipschitz regularity and a training-path radius bound to obtain a learning-rate-dependent near-constancy estimate.

## 2. Finite-sample setting and definitions

Let $n,p\in\mathbb{N}$. The training sample has $n$ indexed observations, and the model has $p$ real parameters. Predictions, targets, and residuals are vectors in $\mathbb{R}^n$.

### Definition 2.1 (Euclidean pairing and squared norm)

For $u,v\in\mathbb{R}^n$, define

$$
\langle u,v\rangle=\sum_{i=1}^{n}u_iv_i,
\qquad
\lVert u\rVert_2^2=\langle u,u\rangle=\sum_{i=1}^{n}u_i^2.
$$

The squared norm is nonnegative because it is a finite sum of squares.

### Definition 2.2 (Sample Jacobian)

A sample Jacobian is a matrix $J\in\mathbb{R}^{n\times p}$. Its row $J_i\in\mathbb{R}^p$ is the local parameter-sensitivity vector for prediction $i$, and $J_{ia}$ is the derivative of prediction $i$ with respect to parameter $a$ at the linearization point.

### Definition 2.3 (Neural tangent kernel)

The neural tangent kernel induced by $J$ is the matrix $K\in\mathbb{R}^{n\times n}$ defined by

$$
K_{ik}=\sum_{a=1}^{p}J_{ia}J_{ka}.
$$

Equivalently, $K=JJ^{\mathsf T}$. For $v\in\mathbb{R}^n$, its action is

$$
(Kv)_i=\sum_{k=1}^{n}K_{ik}v_k.
$$

### Definition 2.4 (Residual-induced parameter gradient)

For a residual $r\in\mathbb{R}^n$, define $g\in\mathbb{R}^p$ by

$$
g_a=\sum_{i=1}^{n}J_{ia}r_i.
$$

Thus $g=J^{\mathsf T}r$. Depending on the sign convention for residuals, $g$ is the parameter-gradient direction or its negative; all statements below use the displayed definition.

### Definition 2.5 (Fixed-kernel prediction training)

Given a target $y\in\mathbb{R}^n$, initial prediction $f_0\in\mathbb{R}^n$, kernel $K$, and learning rate $\eta\in\mathbb{R}$, define

$$
f_{t+1}=f_t+\eta K(y-f_t),
\qquad t\in\mathbb{N}.
$$

The residual is $r_t=y-f_t$. Define the one-step residual map

$$
R_{K,\eta}(v)=v-\eta Kv=(I-\eta K)v.
$$

The associated residual iteration begins at $s_0$ and obeys $s_{t+1}=R_{K,\eta}(s_t)$.

## 3. Gram geometry of the neural tangent kernel

### Theorem 3.1 (Symmetry)

For every sample Jacobian $J\in\mathbb{R}^{n\times p}$, its neural tangent kernel is symmetric:

$$
K_{ik}=K_{ki}
$$

for all $1\le i,k\le n$.

**Proof sketch.** By commutativity of real multiplication,

$$
K_{ik}=\sum_{a=1}^{p}J_{ia}J_{ka}
=\sum_{a=1}^{p}J_{ka}J_{ia}=K_{ki}.
$$

### Theorem 3.2 (Kernel energy identity)

For every $r\in\mathbb{R}^n$, with $g=J^{\mathsf T}r$,

$$
\langle r,Kr\rangle=\sum_{a=1}^{p}g_a^2
=\lVert J^{\mathsf T}r\rVert_2^2.
$$

**Proof sketch.** Expand and reorder the finite sums:

$$
\begin{aligned}
r^{\mathsf T}Kr
&=\sum_{i=1}^{n}r_i\sum_{k=1}^{n}\sum_{a=1}^{p}J_{ia}J_{ka}r_k\\
&=\sum_{a=1}^{p}\left(\sum_{i=1}^{n}J_{ia}r_i\right)
\left(\sum_{k=1}^{n}J_{ka}r_k\right)\\
&=\sum_{a=1}^{p}g_a^2.
\end{aligned}
$$

### Corollary 3.3 (Positive semidefiniteness)

Every neural tangent kernel is positive semidefinite:

$$
r^{\mathsf T}Kr\ge0
$$

for every $r\in\mathbb{R}^n$.

**Proof sketch.** Apply Theorem 3.2 and use nonnegativity of each square $g_a^2$.

### Remark 3.4 (Null directions)

The energy vanishes exactly when $J^{\mathsf T}r=0$. Therefore positive semidefiniteness need not imply positive definiteness. A residual component in $\ker(J^{\mathsf T})=\ker(K)$ is invisible to every infinitesimal parameter direction represented by $J$. This is the principal geometric obstruction to global interpolation by fixed-kernel descent.

## 4. Elimination of parameter space

### Theorem 4.1 (Jacobian–kernel correspondence)

Let $g=J^{\mathsf T}r$ be the parameter-space direction induced by residual $r$. The linearized prediction change $Jg$ equals the kernel action $Kr$. Componentwise,

$$
\sum_{a=1}^{p}J_{ia}g_a=(Kr)_i
$$

for every sample $i$.

**Proof sketch.** Substitute the definition of $g$ and exchange the order of summation:

$$
\sum_{a=1}^{p}J_{ia}\sum_{k=1}^{n}J_{ka}r_k
=\sum_{k=1}^{n}\left(\sum_{a=1}^{p}J_{ia}J_{ka}\right)r_k
=\sum_{k=1}^{n}K_{ik}r_k.
$$

This result is exact for the linearized update. It is the finite-sample identity $J J^{\mathsf T}r=Kr$.

### Theorem 4.2 (Residual recurrence)

For fixed-kernel prediction training,

$$
r_{t+1}=R_{K,\eta}(r_t)=(I-\eta K)r_t.
$$

**Proof sketch.** From $r_t=y-f_t$ and the prediction update,

$$
r_{t+1}=y-f_t-\eta K(y-f_t)=r_t-\eta Kr_t.
$$

### Theorem 4.3 (Exact trajectory representation)

For every $t\in\mathbb{N}$,

$$
r_t=R_{K,\eta}^{\,t}(r_0)=(I-\eta K)^t(y-f_0).
$$

**Proof sketch.** At $t=0$, both sides equal $r_0$. If the formula holds at $t$, Theorem 4.2 gives

$$
r_{t+1}=R_{K,\eta}(r_t)
=R_{K,\eta}\bigl(R_{K,\eta}^{\,t}(r_0)\bigr)
=R_{K,\eta}^{\,t+1}(r_0).
$$

Thus induction yields the claim.

## 5. Geometric convergence

The exact trajectory reduces convergence to a norm estimate for one linear map.

### Theorem 5.1 (Uniform contraction implies a geometric rate)

Let $K\in\mathbb{R}^{n\times n}$, $\eta\in\mathbb{R}$, and $q\ge0$. Suppose

$$
\lVert R_{K,\eta}(v)\rVert_2^2
\le q\lVert v\rVert_2^2
$$

for every $v\in\mathbb{R}^n$. Then for every initial residual $s_0$ and every $t\in\mathbb{N}$,

$$
\lVert R_{K,\eta}^{\,t}(s_0)\rVert_2^2
\le q^t\lVert s_0\rVert_2^2.
$$

**Proof sketch.** The case $t=0$ is equality. Assume the estimate at time $t$. The one-step hypothesis and nonnegativity of $q$ give

$$
\begin{aligned}
\lVert R_{K,\eta}^{\,t+1}(s_0)\rVert_2^2
&\le q\lVert R_{K,\eta}^{\,t}(s_0)\rVert_2^2\\
&\le q\bigl(q^t\lVert s_0\rVert_2^2\bigr)
=q^{t+1}\lVert s_0\rVert_2^2.
\end{aligned}
$$

### Corollary 5.2 (Geometric convergence of fixed-NTK training)

Let $K=JJ^{\mathsf T}$ be the NTK of a sample Jacobian. If $q\ge0$ and

$$
\lVert(I-\eta K)v\rVert_2^2\le q\lVert v\rVert_2^2
$$

for every $v\in\mathbb{R}^n$, then the fixed-NTK prediction sequence satisfies

$$
\lVert y-f_t\rVert_2^2
\le q^t\lVert y-f_0\rVert_2^2.
$$

If additionally $q<1$, the residual converges to zero.

**Proof sketch.** Combine Theorem 4.3 with Theorem 5.1, taking $s_0=y-f_0$.

### Proposition 5.3 (Spectral sufficient condition)

Suppose $K$ is symmetric and its eigenvalues lie in $[\lambda_{\min},\lambda_{\max}]$ with $0<\lambda_{\min}\le\lambda_{\max}$. If

$$
0<\eta<\frac{2}{\lambda_{\max}},
$$

then the contraction hypothesis holds with

$$
q=\max_{\lambda\in\operatorname{spec}(K)}|1-\eta\lambda|^2<1.
$$

**Proof sketch.** Expand $v$ in an orthonormal eigenbasis of $K$. On the eigenvector with eigenvalue $\lambda$, the residual operator multiplies by $1-\eta\lambda$. Squared norms are therefore bounded by the largest squared multiplier. The step-size range places each multiplier strictly inside $(-1,1)$.

The proposition clarifies why Gram positivity alone is insufficient. If $\lambda=0$, the corresponding multiplier is $1$. If $\eta\lambda>2$, its magnitude exceeds $1$. Strict contraction thus requires both spectral coverage of the relevant residual space and a stable learning rate.

## 6. Quantitative kernel stability

The fixed-kernel recurrence describes linearized training. To connect it to a changing model, one needs to control the evolution of $J$ and hence of $K$.

### Theorem 6.1 (Entrywise stability under Jacobian perturbation)

Let $J^{(0)},J^{(1)}\in\mathbb{R}^{n\times p}$. Assume $B\ge0$ and, for every $i,a$,

$$
|J^{(0)}_{ia}|\le B,
\qquad
|J^{(1)}_{ia}|\le B,
\qquad
|J^{(1)}_{ia}-J^{(0)}_{ia}|\le\delta.
$$

Let $K^{(0)}=J^{(0)}(J^{(0)})^{\mathsf T}$ and $K^{(1)}=J^{(1)}(J^{(1)})^{\mathsf T}$. Then for every $i,k$,

$$
|K^{(1)}_{ik}-K^{(0)}_{ik}|\le 2pB\delta.
$$

**Proof sketch.** For each parameter coordinate $a$, use the product decomposition

$$
J^{(1)}_{ia}J^{(1)}_{ka}-J^{(0)}_{ia}J^{(0)}_{ka}
=J^{(1)}_{ia}\bigl(J^{(1)}_{ka}-J^{(0)}_{ka}\bigr)
+J^{(0)}_{ka}\bigl(J^{(1)}_{ia}-J^{(0)}_{ia}\bigr).
$$

The triangle inequality bounds the absolute value by $B\delta+B\delta=2B\delta$. Summing these bounds over $p$ coordinates proves the result.

### Corollary 6.2 (Near constancy along a bounded training path)

Let $J(\theta)\in\mathbb{R}^{n\times p}$ depend on a scalar path coordinate $\theta\in\mathbb{R}$, and fix $\theta_0$. Assume $B,L\ge0$ and

$$
|J(\theta)_{ia}|\le B
$$

for all $\theta,i,a$, together with the anchored Lipschitz bound

$$
|J(\theta)_{ia}-J(\theta_0)_{ia}|
\le L|\theta-\theta_0|.
$$

If a point $\theta_t$ on the training path satisfies

$$
|\theta_t-\theta_0|\le t\eta G,
$$

then for every $i,k$,

$$
|K(\theta_t)_{ik}-K(\theta_0)_{ik}|
\le 2pBLt\eta G.
$$

**Proof sketch.** The path radius and Lipschitz condition imply

$$
|J(\theta_t)_{ia}-J(\theta_0)_{ia}|
\le Lt\eta G.
$$

Apply Theorem 6.1 with $\delta=Lt\eta G$.

### Discussion of scaling

The factor $p$ counts parameter coordinates before normalization. In wide-network models, entries of $J$ typically carry width-dependent scaling. The useful quantity is therefore not $p$ in isolation, but $pB\delta$. If $B$ and $\delta$ decrease sufficiently rapidly with width, entrywise kernel drift remains small or tends to zero. The deterministic theorem deliberately leaves this scaling visible, allowing architecture-specific concentration and normalization arguments to be inserted without changing the optimization core.

The pathwise estimate grows linearly in $t\eta G$. It is consequently most informative over horizons for which the traveled distance is controlled. A sharper vector-parameter theory can replace the scalar path coordinate by an appropriate parameter norm and replace entrywise control by an operator norm. The product structure remains the same: Jacobian magnitude times Jacobian variation, accumulated over coordinates.

## 7. Algorithms

### Algorithm 7.1 (Construction of the empirical NTK)

Given $J\in\mathbb{R}^{n\times p}$, compute

$$
K=JJ^{\mathsf T}.
$$

A direct implementation requires $O(n^2p)$ arithmetic operations and $O(n^2)$ storage for the kernel. Symmetry permits computation of only one triangular half. If only products $Kv$ are needed, one may avoid materializing $K$ and compute $J(J^{\mathsf T}v)$ in $O(np)$ time and $O(n+p)$ auxiliary storage.

### Algorithm 7.2 (Fixed-kernel residual descent)

Given $K$, $\eta$, $y$, $f_0$, and a number of steps $T$, set $r_0=y-f_0$. For $t=0,\ldots,T-1$, compute

$$
r_{t+1}=r_t-\eta Kr_t,
\qquad
f_{t+1}=y-r_{t+1}.
$$

With a dense stored kernel, each iteration costs $O(n^2)$. With an implicit Jacobian, compute $Kr=J(J^{\mathsf T}r)$ at cost $O(np)$.

### Algorithm 7.3 (Kernel-drift certificate)

Given two Jacobians, compute

$$
B=\max_{i,a}\max\{|J^{(0)}_{ia}|,|J^{(1)}_{ia}|\},
\qquad
\delta=\max_{i,a}|J^{(1)}_{ia}-J^{(0)}_{ia}|.
$$

The theorem certifies the universal entrywise bound $2pB\delta$. One may also compute the observed maximum drift $\max_{i,k}|K^{(1)}_{ik}-K^{(0)}_{ik}|$ and compare it with the certificate. Both kernel constructions take $O(n^2p)$ time; obtaining $B$ and $\delta$ takes $O(np)$.

## 8. Numerical illustration

Consider

$$
J=
\begin{pmatrix}
1 & 0\\
1 & 1\\
0 & 1
\end{pmatrix},
\qquad
K=JJ^{\mathsf T}=
\begin{pmatrix}
1 & 1 & 0\\
1 & 2 & 1\\
0 & 1 & 1
\end{pmatrix}.
$$

The kernel is symmetric positive semidefinite, but singular: the Jacobian has only two columns, so $K$ has rank at most two. A residual in the null direction cannot decay. This illustrates why positivity does not itself imply interpolation.

For a full-row-rank example, take

$$
J=
\begin{pmatrix}
1 & 0 & 0\\
0 & \sqrt{2} & 0\\
0 & 0 & \sqrt{3}
\end{pmatrix},
\qquad
K=\operatorname{diag}(1,2,3).
$$

With $\eta=1/2$, the residual multipliers are $1/2$, $0$, and $-1/2$, so $q=1/4$. Therefore

$$
\lVert r_t\rVert_2^2\le 4^{-t}\lVert r_0\rVert_2^2.
$$

The second eigenmode vanishes in one step; the first and third decay equally in magnitude, with the third alternating in sign.

For stability, let every Jacobian entry be bounded by $B=1.2$, let $p=100$, and suppose the maximum entrywise drift is $\delta=10^{-4}$. Then every kernel entry changes by at most

$$
2pB\delta=2\cdot100\cdot1.2\cdot10^{-4}=0.024.
$$

The estimate is conservative because it uses independent worst-case bounds for every summand, but it is deterministic and uniform over sample pairs.

## 9. Applications and interpretation

### 9.1 Kernel regression in the lazy-training regime

If the Jacobian remains close to its initialization, prediction updates remain close to those generated by the initial kernel. If that initial kernel also approaches a deterministic limit as width increases, the network trajectory approaches deterministic kernel gradient descent. Under a positive spectral gap, the limiting dynamics interpolate geometrically.

The present results specify the deterministic interfaces for such an argument: a concentration estimate for the initial kernel, a Jacobian-drift estimate along the path, and a perturbation analysis transferring contraction from the limiting kernel to the empirical time-varying kernel.

### 9.2 Reachability and data geometry

The image of $J$ is the space of sample-prediction changes available to the linearized model. The kernel has the same image, while its nullspace consists of residual patterns orthogonal to all available changes. Thus rank deficiency is not merely numerical pathology; it describes a structural inability of the local feature map to fit certain target components.

### 9.3 Learning-rate diagnostics

The eigenvalues of $K$ determine stable step sizes. Large eigenvalues restrict $\eta$, while small positive eigenvalues create slow modes. Preconditioning seeks to compress this spectral range. Adaptive schemes can estimate extremal eigenvalues and choose steps that preserve contraction even when the kernel drifts moderately.

### 9.4 Distinguishing kernel behavior from feature learning

The quantity controlling entrywise drift is a product of Jacobian scale, Jacobian variation, and effective parameter count. When normalized drift tends to zero, the feature geometry is nearly frozen. When it becomes order one, fixed-kernel approximation can fail and feature learning becomes essential. The stability theorem therefore suggests a quantitative phase indicator rather than a purely verbal distinction.

## 10. Perturbed and time-varying dynamics

The stability theorem is most useful when combined with the residual recurrence. Let $K_t$ be the kernel at time $t$ and let $K_0$ be the reference kernel. A time-varying residual step can be decomposed as

$$
r_{t+1}=(I-\eta K_0)r_t-\eta(K_t-K_0)r_t.
$$

The first term is the contractive reference dynamics; the second is a forcing term caused by kernel drift. This identity is immediate by adding and subtracting $\eta K_0r_t$, but it describes the route from deterministic stability to trajectory tracking. If $I-\eta K_0$ contracts by a factor strictly below one and the perturbation operator is uniformly small, earlier perturbations are damped rather than accumulated without limit.

The established entrywise estimate provides one input to such an argument. If every entry of $K_t-K_0$ is bounded by $\varepsilon_t$, then for any $v\in\mathbb{R}^n$, elementary finite-sum estimates give

$$
\lVert(K_t-K_0)v\rVert_2\le n\varepsilon_t\lVert v\rVert_2.
$$

Indeed, each output coordinate has magnitude at most $\varepsilon_t\sum_j|v_j|\le\varepsilon_t\sqrt n\lVert v\rVert_2$, and summing the squares of $n$ such coordinates gives the result. Combining this estimate with the pathwise certificate yields the operator bound

$$
\lVert K_t-K_0\rVert_{2\to2}\le 2npBLt\eta G.
$$

This conversion is generally conservative. It treats all kernel entries as if their worst-case deviations aligned. Architecture-specific concentration in operator norm can be substantially sharper, but the elementary estimate shows that entrywise stability is already sufficient for finite-dimensional perturbation control.

Suppose, for illustration, that $\lVert(I-\eta K_0)v\rVert_2\le\rho\lVert v\rVert_2$ with $0\le\rho<1$ and $\lVert K_t-K_0\rVert_{2\to2}\le\varepsilon$. Then

$$
\lVert r_{t+1}\rVert_2\le(\rho+|\eta|\varepsilon)\lVert r_t\rVert_2.
$$

Whenever $\rho+|\eta|\varepsilon<1$, the changing-kernel step remains contractive. This inequality is a direct triangle-inequality consequence rather than an additional main theorem, and it emphasizes the available stability margin: a strongly contractive reference dynamics tolerates a larger kernel perturbation.

### Practical diagnostic pipeline

A finite-data analysis can therefore proceed in four stages. First construct the sample Jacobian and its Gram kernel. Second estimate the nonzero spectrum and choose a learning rate with a contraction margin. Third monitor Jacobian magnitude and drift, either entrywise or in stronger norms. Fourth compare the resulting perturbation size with the spectral margin. This pipeline distinguishes three failures: a nullspace obstruction, an unstable learning rate, and excessive feature drift. Each calls for a different remedy. More expressive features address the first, step-size control addresses the second, and width scaling or shorter trusted horizons addresses the third.

## 11. Limitations

The results are finite-sample and deterministic. They do not by themselves prove that a particular random neural architecture has a deterministic infinite-width kernel, nor that its Jacobian remains Lipschitz with a favorable width dependence. Those are separate probabilistic and architecture-specific tasks.

The pathwise theorem is stated for a scalar path coordinate, which cleanly displays the product $Lt\eta G$ but does not capture the full geometry of a vector-valued parameter path. The stability estimate is entrywise rather than spectral. Converting an entrywise bound into an operator-norm bound can introduce factors depending on sample size unless additional structure is available.

Finally, the contraction theorem assumes a uniform bound over all residual vectors. In singular problems, contraction may hold only on the image of $J$, or on the subspace reached by the initial residual. A restricted theorem can produce useful rates even when global contraction is impossible.

## 12. Future work

Five directions follow naturally. First, one can combine initialization concentration, deterministic drift, and a covering argument to obtain uniform operator-norm concentration throughout a fixed horizon. Second, contraction of the limiting residual operator can prevent local kernel perturbations from accumulating, enabling width-dependent tracking estimates of order $m^{-1/2}$ up to logarithmic factors. Third, the dimensionless product of Jacobian Lipschitz scale, path length, and width normalization may define a threshold between lazy training and feature learning. Fourth, low-rank data geometry suggests preconditioning on the Jacobian image, with rates governed by the nonzero restricted spectrum rather than ambient sample dimension. Fifth, online estimates of extremal kernel eigenvalues can support adaptive step sizes for time-varying kernels.

## 13. Conclusion

The neural tangent description rests on a concise deterministic chain. The sample Jacobian induces a symmetric positive semidefinite Gram matrix. A residual-induced parameter gradient changes linearized predictions by precisely that matrix. Fixed-kernel training therefore obeys an exact linear residual recurrence. Uniform one-step contraction yields a geometric finite-time rate. Entrywise control of the Jacobian yields an explicit kernel-drift bound, and Lipschitz control along a short learning-rate-scaled path makes near constancy quantitative.

Keeping these ingredients separate prevents overstatement. Gram positivity is automatic, but strict contraction is spectral. Fixed-kernel dynamics are exact for the defined kernel iteration, but their relevance to a nonlinear network depends on Jacobian stability. Infinite width is not required for the algebra; it is the regime in which concentration and normalization can justify treating the empirical kernel as deterministic and nearly frozen. This decomposition provides a clear foundation for sharper probabilistic, spectral, and feature-learning analyses.