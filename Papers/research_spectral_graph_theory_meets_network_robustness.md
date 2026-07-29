# Spectral Connectivity, Gain Control, and Certified Robustness of Scalar Computation Networks

**Aristotle**  
**29 July 2026**

## Abstract

We establish a precise conditional connection between algebraic connectivity and certified robustness for a scalar computation network. The analysis separates four quantities that are often conflated: the graph spectral gap $\lambda$, an input-to-state gain $G$, a readout gain $K$, and the classification margin $m$. In the weighted two-node model, the Dirichlet energy is exactly $\lambda$ times the variance in the unique disagreement mode. More generally, if an internal scalar state $h$ satisfies the spectral variation inequality $\lambda(h(x)-h(y))^2\leq G^2(x-y)^2$, then $h$ is $G/\sqrt{\lambda}$-Lipschitz. Composition with a $K$-Lipschitz readout gives an end-to-end Lipschitz bound $KG/\sqrt{\lambda}$. At a point with positive margin $m$, this yields the certified open radius $m\sqrt{\lambda}/(KG)$. We also prove two uniform impossibility results: connectivity alone guarantees neither a positive robustness radius nor any finite Lipschitz upper bound. Explicit affine counterexamples show that gain control and output margin are indispensable. Algorithms for evaluating the certificate, checking finite samples of the defining inequality, and generating counterexamples are provided, together with numerical illustrations and a discussion of extensions to finite graphs and vector-valued networks.

## 1. Introduction

The computation performed by a neural or distributed system can be represented as a graph. Vertices carry intermediate states and edges record interactions or dependencies. Spectral graph theory then supplies a natural geometric descriptor: algebraic connectivity, the first positive eigenvalue of a graph Laplacian. A large spectral gap penalizes disagreement among node states and promotes coordination. It is therefore tempting to infer that high connectivity automatically makes the represented function insensitive to perturbations.

That inference is incomplete. A graph describes where amplification may occur, not how large the amplification is. Parameters can be rescaled on a fixed graph, producing arbitrarily steep functions. Moreover, even a gently varying score may be arbitrarily close to its decision boundary. Robustness therefore requires a quantitative bridge from topology to state variation and another bridge from score variation to decision stability.

This paper isolates those bridges in the scalar setting. The first is a spectral state-gain inequality. It states that the squared change of an internal state, weighted by connectivity, is bounded by a squared input gain. The second is a Lipschitz readout bound. The third is a positive classification margin. Together they yield a transparent certificate:

$$
r_{\mathrm{cert}}=\frac{m\sqrt{\lambda}}{KG}.
$$

The square-root dependence is forced by the passage from quadratic energy to ordinary distance. The formula is monotone in each variable but should not be interpreted causally without controlling the others. Increasing $\lambda$ improves the guarantee only if $G$, $K$, and $m$ remain fixed.

Our contributions are fivefold. First, we give an exact two-node spectral identity. Second, we prove the spectral-to-Lipschitz estimate. Third, we prove the multiplicative composition rule for state and readout gains. Fourth, we derive the margin-based certified radius. Fifth, we delimit the theorem by uniform counterexamples to connectivity-only claims.

## 2. Setting and definitions

All inputs, internal states, and scores are real-valued. This restriction makes the mechanism explicit without operator-norm notation. The results are global: inequalities are required for every pair of real inputs.

### Definition 2.1 (Global Lipschitz bound)

A function $f:\mathbb{R}\to\mathbb{R}$ has global Lipschitz bound $L$ if

$$
|f(x)-f(y)|\leq L|x-y|
$$

for every $x,y\in\mathbb{R}$.

When $L\geq 0$, this limits the steepness of $f$ in a metric sense. The formulation does not require differentiability.

### Definition 2.2 (Certified positive decision)

For a score $f:\mathbb{R}\to\mathbb{R}$, center $x_0\in\mathbb{R}$, and radius $r\in\mathbb{R}$, the positive decision is certified on the open radius $r$ when

$$
|y-x_0|<r \quad\Longrightarrow\quad f(y)>0
$$

for every $y\in\mathbb{R}$.

The strict inequality matches binary classification by the sign of the score. It also handles the possibility that the score is exactly zero at the boundary.

### Definition 2.3 (Two-node energy and variance)

For two scalar node states $u,v\in\mathbb{R}$ and a connectivity parameter $\lambda\in\mathbb{R}$, define

$$
E_\lambda(u,v)=\frac{\lambda}{2}(u-v)^2
$$

and

$$
V(u,v)=\frac{(u-v)^2}{2}.
$$

The common mode $(u+v)/2$ does not enter either quantity. The difference $u-v$ spans the unique disagreement mode.

### Definition 2.4 (Spectral state bound)

Let $h:\mathbb{R}\to\mathbb{R}$ be an internal state map. Given connectivity $\lambda$ and state gain $G$, we say that $h$ satisfies the spectral state bound if

$$
\lambda\bigl(h(x)-h(y)\bigr)^2
\leq
G^2(x-y)^2
$$

for all $x,y\in\mathbb{R}$.

The hypothesis combines graph geometry and parameter sensitivity. It is stronger than merely asserting that a computation graph has spectral gap $\lambda$; it explicitly requires that the gap control the state changes induced by inputs.

## 3. Exact spectral geometry of two nodes

### Theorem 3.1 (Exact two-node spectral identity)

For every $\lambda,u,v\in\mathbb{R}$,

$$
E_\lambda(u,v)=\lambda V(u,v).
$$

#### Proof sketch

Substitute the definitions:

$$
E_\lambda(u,v)=\frac{\lambda}{2}(u-v)^2
=\lambda\frac{(u-v)^2}{2}
=\lambda V(u,v).
$$

Thus the Poincaré relation is an equality in the unique disagreement direction. No positivity assumption is needed for the algebraic identity, although spectral interpretation ordinarily uses $\lambda>0$.

### Interpretation

The theorem is the minimal spectral model of consensus. If $u=v$, both energy and variance vanish. If $u\neq v$ and $\lambda>0$, a larger spectral gap assigns greater energy to the same variance. In a general connected graph, a Poincaré inequality compares Dirichlet energy with variance after removing the constant mode. Here the disagreement space is one-dimensional, so there is no slack.

## 4. From spectral energy to metric regularity

### Theorem 4.1 (Spectral-to-Lipschitz theorem)

Let $\lambda>0$ and $G\geq 0$. If $h:\mathbb{R}\to\mathbb{R}$ satisfies

$$
\lambda\bigl(h(x)-h(y)\bigr)^2\leq G^2(x-y)^2
$$

for all $x,y\in\mathbb{R}$, then $h$ has global Lipschitz bound

$$
L_h=\frac{G}{\sqrt{\lambda}}.
$$

Equivalently,

$$
|h(x)-h(y)|\leq\frac{G}{\sqrt{\lambda}}|x-y|
$$

for all $x,y\in\mathbb{R}$.

#### Proof sketch

Because $\lambda>0$, divide the assumed inequality by $\lambda$:

$$
\bigl(h(x)-h(y)\bigr)^2
\leq
\frac{G^2}{\lambda}(x-y)^2.
$$

Since $G\geq 0$ and $\sqrt{\lambda}>0$, the right side equals

$$
\left(\frac{G}{\sqrt{\lambda}}(x-y)\right)^2.
$$

Taking nonnegative square roots gives

$$
|h(x)-h(y)|
\leq
\left|\frac{G}{\sqrt{\lambda}}(x-y)\right|
=
\frac{G}{\sqrt{\lambda}}|x-y|.
$$

This proves the claim.

### Remark 4.2 (Origin of the square root)

The spectral bound compares squared variations. The Lipschitz estimate compares first powers of distance. Consequently, the spectral coefficient enters as $\lambda^{-1/2}$ rather than $\lambda^{-1}$. A fourfold increase in $\lambda$ halves the state Lipschitz upper bound when $G$ is unchanged.

### Remark 4.3 (Degenerate gain)

The theorem allows $G=0$. Then the spectral bound forces $h(x)=h(y)$ for every $x$ and $y$, because $\lambda>0$. Thus $h$ is constant and has Lipschitz bound $0$. The positive-radius formula later assumes $G>0$ to avoid division by zero; in the constant case, robustness should instead be assessed directly from the constant output.

## 5. Readout composition

### Theorem 5.1 (Multiplication of Lipschitz gains)

Let $h,q:\mathbb{R}\to\mathbb{R}$. Suppose $h$ has Lipschitz bound $A$, $q$ has Lipschitz bound $K$, and $K\geq 0$. Then the composition $f=q\circ h$ has Lipschitz bound $KA$:

$$
|q(h(x))-q(h(y))|\leq KA|x-y|
$$

for every $x,y\in\mathbb{R}$.

#### Proof sketch

Apply the readout inequality to $h(x)$ and $h(y)$, then use the state inequality:

$$
|q(h(x))-q(h(y))|
\leq K|h(x)-h(y)|
\leq K A|x-y|.
$$

Nonnegativity of $K$ preserves the inequality when multiplying the state bound.

### Corollary 5.2 (Spectral end-to-end Lipschitz bound)

Under the hypotheses of Theorem 4.1, if $q$ is $K$-Lipschitz with $K\geq 0$, then $f=q\circ h$ has Lipschitz bound

$$
L_f=\frac{KG}{\sqrt{\lambda}}.
$$

#### Proof sketch

Insert $A=G/\sqrt{\lambda}$ from Theorem 4.1 into Theorem 5.1.

This factorization separates three effects. The state gain $G$ measures input excitation, the readout gain $K$ measures output amplification, and $\sqrt{\lambda}$ supplies spectral attenuation.

## 6. Margin-based certification

### Theorem 6.1 (Margin-over-Lipschitz certificate)

Let $f:\mathbb{R}\to\mathbb{R}$ have Lipschitz bound $L>0$. Suppose that at a reference point $x_0$,

$$
f(x_0)=m
$$

with $m>0$. Then the positive decision is certified for every perturbation satisfying

$$
|y-x_0|<\frac{m}{L}.
$$

#### Proof sketch

The Lipschitz inequality gives

$$
|f(y)-f(x_0)|\leq L|y-x_0|.
$$

Since $f(y)-f(x_0)\geq-|f(y)-f(x_0)|$, it follows that

$$
f(y)\geq f(x_0)-L|y-x_0|
=m-L|y-x_0|.
$$

If $|y-x_0|<m/L$, positivity of $L$ yields $L|y-x_0|<m$, and hence $f(y)>0$.

### Theorem 6.2 (Spectral certified-radius theorem)

Let $\lambda,G,K,m$ be positive real numbers. Let $h:\mathbb{R}\to\mathbb{R}$ satisfy

$$
\lambda\bigl(h(x)-h(y)\bigr)^2\leq G^2(x-y)^2
$$

for all $x,y\in\mathbb{R}$. Let $q:\mathbb{R}\to\mathbb{R}$ satisfy

$$
|q(a)-q(b)|\leq K|a-b|
$$

for all $a,b\in\mathbb{R}$. If at $x_0$ the composed score has margin

$$
q(h(x_0))=m,
$$

then the positive decision of $f=q\circ h$ is certified throughout the open radius

$$
r_{\mathrm{cert}}
=
\frac{m\sqrt{\lambda}}{KG}.
$$

That is, every $y$ satisfying

$$
|y-x_0|<\frac{m\sqrt{\lambda}}{KG}
$$

also satisfies $q(h(y))>0$.

#### Proof sketch

By Theorem 4.1, $h$ has Lipschitz bound $G/\sqrt{\lambda}$. By Theorem 5.1, $q\circ h$ has positive Lipschitz bound

$$
L_f=K\frac{G}{\sqrt{\lambda}}.
$$

Apply Theorem 6.1. The resulting radius simplifies as

$$
\frac{m}{L_f}
=
\frac{m}{KG/\sqrt{\lambda}}
=
\frac{m\sqrt{\lambda}}{KG}.
$$

### Corollary 6.3 (Scaling laws)

Within the assumptions of Theorem 6.2, the certified radius is linear in $m$, inverse-linear in $G$ and $K$, and proportional to $\sqrt{\lambda}$. Thus multiplying $\lambda$ by $c^2$ multiplies the radius by $c$, provided all other quantities remain unchanged.

## 7. Necessity of gain and margin assumptions

The positive theorem does not support a connectivity-only conclusion. Two parametric counterexamples show why.

### Theorem 7.1 (No positive radius from connectivity alone)

For every proposed radius $R>0$, there exists a $1$-Lipschitz score $f:\mathbb{R}\to\mathbb{R}$ such that $f(0)>0$ but the positive decision is not certified on radius $R$ around $0$.

#### Proof sketch

Define

$$
f(x)=\frac{R}{2}-x.
$$

Then $f(0)=R/2>0$. Moreover,

$$
|f(x)-f(y)|=|y-x|=|x-y|,
$$

so $f$ is $1$-Lipschitz. Set $y=R/2$. Then $|y|=R/2<R$ while $f(y)=0$, which is not positive. Hence the radius-$R$ certificate fails. The construction makes no reference to connectivity and therefore defeats any uniform claim based on connectivity alone.

### Theorem 7.2 (No Lipschitz bound from connectivity alone)

For every proposed nonnegative number $B$, there exists a scalar score that does not have Lipschitz bound $B$.

#### Proof sketch

Take

$$
f(x)=(B+1)x.
$$

At $x=1$ and $y=0$,

$$
|f(1)-f(0)|=B+1>B=B|1-0|.
$$

Thus the Lipschitz inequality with bound $B$ fails. Since scalar gains can be made arbitrarily large without changing an abstract graph topology, connectivity alone cannot control functional steepness.

### Consequence

Theorem 7.1 identifies the role of margin: positivity at a point is insufficient unless its magnitude is compared with output variation. Theorem 7.2 identifies the role of gain: topology does not prevent arbitrary parameter scaling. Together they show that $G$, $K$, and $m$ are not decorative terms in Theorem 6.2; they are logically indispensable.

## 8. Algorithms and numerical evaluation

### Algorithm 8.1 (Spectral certificate evaluation)

Given positive $\lambda$, $G$, $K$, and $m$, compute

$$
L_h=\frac{G}{\sqrt{\lambda}},
\qquad
L_f=K L_h,
\qquad
r_{\mathrm{cert}}=\frac{m}{L_f}.
$$

The algorithm uses a constant number of arithmetic operations and one square root, so its time and auxiliary-space complexities are both $O(1)$.

For example, with $\lambda=4$, $G=2$, $K=3$, and $m=1.5$, one obtains $L_h=1$, $L_f=3$, and $r_{\mathrm{cert}}=0.5$.

### Algorithm 8.2 (Finite diagnostic for the spectral state inequality)

For a finite sample $x_1,\ldots,x_n$, evaluate every unordered pair and check

$$
\lambda\bigl(h(x_i)-h(x_j)\bigr)^2
\leq
G^2(x_i-x_j)^2+\varepsilon,
$$

where $\varepsilon\geq0$ is a numerical tolerance. This costs $O(n^2)$ state comparisons and $O(1)$ auxiliary space if failures are streamed. Passing the diagnostic is not a proof of the global hypothesis; failing it produces a concrete witness that the chosen $G$ is inadequate.

### Algorithm 8.3 (Uniform counterexample generation)

Given $R>0$, output $f_R(x)=R/2-x$ and witness $x=R/2$ to refute a radius-$R$ claim. Given $B\geq0$, output $g_B(x)=(B+1)x$ and witnesses $0,1$ to refute a Lipschitz bound $B$. Both constructions take $O(1)$ time and space.

## 9. Applications

### A certificate audit protocol

A deployment-oriented audit should record the provenance of every factor. The connectivity value should correspond to the graph and weighting convention actually used by the state estimate. The gain $G$ should apply on the claimed input domain, and the readout gain $K$ should cover all states reachable under certified perturbations. The margin $m$ should be evaluated at the stated reference input and with the same decision threshold used in operation. Once these conditions are aligned, the radius follows arithmetically; without alignment, combining individually valid numbers may still produce an invalid conclusion.

The protocol should also preserve inequalities in the conservative direction. Numerical lower bounds are appropriate for $\lambda$ and $m$, while numerical upper bounds are appropriate for $G$ and $K$. Rounding a spectral gap upward or a gain downward can overstate the certificate. Finally, the result should be reported as an open-radius guarantee: perturbations strictly smaller than the computed value preserve positivity. This reporting convention captures the exact logical content of the margin argument.


The certificate is relevant to graph-structured computation whenever an internal disagreement estimate can be established. In distributed sensing, $\lambda$ can summarize communication connectivity, $G$ can bound measurement-to-state sensitivity, and $K$ can quantify the sensitivity of an alarm statistic. In coordinated control, the same factors separate coupling strength from controller gain and safety margin. In graph neural networks, they suggest reporting not just a graph spectral statistic but also norm-based bounds for feature propagation and readout layers.

The formula is also useful for architecture comparison. Suppose two designs have tuples $(\lambda_1,G_1,K_1,m_1)$ and $(\lambda_2,G_2,K_2,m_2)$. Their certificates should be compared through

$$
\frac{m_1\sqrt{\lambda_1}}{K_1G_1}
\quad\text{and}\quad
\frac{m_2\sqrt{\lambda_2}}{K_2G_2},
$$

not through $\lambda_1$ and $\lambda_2$ alone. Added connectivity can coincide with increased gain, and training for a larger margin can alter readout sensitivity. The full ratio captures these tradeoffs.

## 10. Sensitivity analysis and sharpness

The certificate admits a direct logarithmic sensitivity analysis. For positive parameters,

$$
\log r_{\mathrm{cert}}
=
\log m+\frac{1}{2}\log\lambda-\log K-\log G.
$$

Hence a small relative change obeys

$$
\frac{\Delta r_{\mathrm{cert}}}{r_{\mathrm{cert}}}
\approx
\frac{\Delta m}{m}
+rac{1}{2}\frac{\Delta\lambda}{\lambda}
-rac{\Delta K}{K}
-rac{\Delta G}{G}.
$$

This expression makes the asymmetry among design interventions explicit. A one-percent increase in margin produces approximately a one-percent increase in radius. A one-percent reduction in either gain has the same first-order effect. A one-percent increase in connectivity produces only about a half-percent increase. Spectral improvement can still be valuable, especially when architectural changes raise $\lambda$ substantially, but the square-root law imposes diminishing returns.

The constants in the chain of inequalities can be attained by affine maps. Fix positive $\lambda$, $G$, $K$, and $m$, and choose a reference point $x_0=0$. Define

$$
h(x)=\frac{G}{\sqrt{\lambda}}x
$$

and

$$
q(a)=m-Ka.
$$

The state inequality holds with equality for every pair $x,y$, because

$$
\lambda\bigl(h(x)-h(y)\bigr)^2
=
G^2(x-y)^2.
$$

The readout has Lipschitz constant exactly $K$, and the composed score is

$$
f(x)=m-\frac{KG}{\sqrt{\lambda}}x.
$$

At $x_0=0$, its margin is $m$. It reaches zero at

$$
x=\frac{m\sqrt{\lambda}}{KG}.
$$

Therefore the certified open radius cannot in general be enlarged while retaining only the stated hypotheses. This affine construction simultaneously saturates the spectral state estimate, the composition estimate, and the margin argument. The strict-open formulation is consequently natural rather than an artifact of the proof.

This sharpness observation also distinguishes worst-case certification from average-case robustness. A nonlinear network may remain positive well beyond the certified radius in most directions or on most data points. The theorem does not estimate such typical behavior. It identifies the largest universal radius derivable from these four scalar quantities alone. Additional curvature, monotonicity, local slope, or distributional information may justify a larger certificate, but such information constitutes an additional hypothesis.

### Parameter uncertainty

In practice, the quantities may be available only through conservative bounds. Suppose one knows a lower bound $\underline{\lambda}>0$ for connectivity, upper bounds $\overline{G}>0$ and $\overline{K}>0$ for the gains, and a lower bound $\underline{m}>0$ for the margin. Monotonicity then gives the conservative certificate

$$
\underline{r}
=
\frac{\underline{m}\sqrt{\underline{\lambda}}}
{\overline{K}\,\overline{G}}.
$$

Indeed, the true margin and connectivity can only increase the numerator relative to these bounds, while the true gains can only decrease the denominator. This interval-aware form is useful when spectral values are estimated numerically or gains are bounded by relaxations.

Care is required when lower bounds reach zero. If $\underline{m}=0$ or $\underline{\lambda}=0$, this formula yields no positive radius. If an upper gain bound is unavailable, replacing it by a sampled empirical slope does not establish a global certificate. The impossibility results explain why these failures cannot be repaired by topology alone.

### Diagnostic interpretation

The state inequality can be rearranged for $x\neq y$ as

$$
\frac{|h(x)-h(y)|}{|x-y|}
\leq
\frac{G}{\sqrt{\lambda}}.
$$

Thus a sampled pair with a larger quotient immediately refutes the proposed state gain. Conversely, finitely many passing pairs only provide evidence on those pairs. A global conclusion requires analytical structure, exhaustive coverage of a finite domain, or another rigorous bounding method. This distinction should be retained when the algorithms below are used in exploratory workflows.

## 11. Limitations and discussion

The model is scalar and global. Real networks have vector-valued inputs, intermediate tensors, nonlinear layers, and multiclass outputs. The scalar absolute value should then be replaced by a chosen norm, and gains by induced operator bounds. A multiclass certificate uses the margin between the winning score and every competing score, often introducing a Lipschitz bound for score differences.

The spectral state inequality is assumed rather than derived from a general graph Laplacian. This is deliberate: it makes clear exactly where graph structure enters and avoids claiming that algebraic connectivity alone controls a parameterized function. In larger graphs, a derivation must project away the constant mode and use a Rayleigh-quotient or Poincaré inequality. It must also connect layer dynamics to Dirichlet energy.

The bound can be conservative. Global Lipschitz constants may substantially exceed local slopes, and multiplication of layerwise bounds may accumulate slack. Nevertheless, the result has value as a compositional baseline. It states a sufficient condition with explicit dependencies and no hidden topological inference.

The open radius is also essential. At distance exactly $m/L$, a worst-case affine score may reach zero. Stronger conclusions at a closed boundary require additional information, such as a strict improvement in the Lipschitz estimate or a larger margin.

## 12. Future work

A first extension should derive the spectral state bound from a finite graph Laplacian. Let $L_G$ be the Laplacian of a connected weighted graph and let $z$ be orthogonal to the constant vector. The Poincaré inequality $\lambda_2\|z\|^2\leq z^\top L_Gz$ can supply the spectral step, provided the network dynamics furnish an upper bound on the energy difference induced by input changes.

A second extension should replace scalar spaces with finite-dimensional Euclidean spaces and use operator norms. This would permit layerwise estimates for matrices, nonlinear activations, and graph filters. A third direction is compositional derivation of $G$ from individual layer weights rather than treating it as an external assumption. Further work should investigate local spectral and Lipschitz bounds, data-dependent margins, multiclass score differences, and the optimization problem of improving $\sqrt{\lambda}/(KG)$ under architectural constraints.

## 13. Conclusion

Algebraic connectivity contributes to certified robustness through a precise but conditional mechanism. A spectral state-gain inequality yields a $G/\sqrt{\lambda}$ state Lipschitz bound; a $K$-Lipschitz readout yields an end-to-end bound $KG/\sqrt{\lambda}$; and a positive margin $m$ yields the certified radius $m\sqrt{\lambda}/(KG)$. Exact two-node geometry explains the spectral factor, while affine counterexamples show why connectivity cannot replace gain control or margin. The resulting framework is both constructive and restrictive: it provides a usable certificate and states exactly what topology alone cannot guarantee.
