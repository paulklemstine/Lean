# Identifiability and Fisher Degeneracy in a Normalized Exp–Log Model

**Aristotle**  
**29 July 2026**

## Abstract

We analyze a normalized exp–log statistical model on a finite sample space. Given sample values $x_i$, the unnormalized weight assigned to outcome $i$ is $w_i(a,b)=e^a\log(1+b x_i)$. Although this expression contains two real parameters, normalization removes the common exponential factor exactly. We prove that the partition function factors as $Z(a,b)=e^a A(b)$, where $A(b)=\sum_i\log(1+b x_i)$, and hence that $p_i(a,b)=\log(1+b x_i)/A(b)$ whenever $A(b)\ne0$. Under positive inputs and $b>0$, these normalized weights form a strictly positive probability distribution. The scale parameter $a$ is unidentifiable: its score vanishes, its Fisher information is zero, and every mixed Fisher pairing involving its direction is zero. Consequently the full two-parameter Fisher matrix has a zero row and column, has determinant zero for every choice of shape score, and fails to be positive definite. The proposed parameter plane therefore does not carry a nondegenerate two-dimensional Fisher metric and cannot, in this form, define a two-dimensional hyperbolic information geometry. We discuss the distinction between raw exponential sensitivity and statistical distinguishability, provide numerical diagnostics, and describe identifiable reformulations suitable for subsequent curvature analysis.

## 1. Introduction

Information geometry equips a differentiable family of probability distributions with metric and affine structures derived from statistical distinguishability. The Fisher information matrix is central: it measures the second-order response of divergence between nearby distributions and supplies the metric used by natural-gradient methods. These constructions require care when a parameterization is redundant. If distinct parameter values induce the same distribution, the Fisher form develops null directions and ceases to be a Riemannian metric on the stated parameter space.

This paper studies the simplest normalized exp–log neuron on a finite sample space. Its raw response combines an exponential scale with a logarithmic activation:

$$
w_i(a,b)=e^a\log(1+b x_i).
$$

The formula may suggest a two-dimensional geometry with pronounced sensitivity in the exponential coordinate. Yet probability models depend on relative weights, not their common magnitude. Since $e^a$ multiplies every outcome equally, it cancels under normalization. This elementary algebraic fact controls the entire geometry.

Our purpose is both specific and methodological. Specifically, we establish exact normalization, positivity, identifiability, score, and Fisher-degeneracy results for the exp–log family. Methodologically, we illustrate why identifiability must be checked before claims about Hessian metrics, curvature, dual flatness, geodesics, or natural-gradient convergence are considered. A common factor can create large variation in raw outputs and no variation whatsoever in the induced distribution.

The main conclusions are as follows.

1. The partition function factors into the exponential scale and a shape-dependent activation mass.
2. If the activation mass is nonzero, the normalized distribution is independent of $a$ and sums to one.
3. If the sample space is nonempty, $x_i>0$ for all $i$, and $b>0$, all normalized probabilities are strictly positive.
4. The scale score and all Fisher terms involving it vanish.
5. The two-parameter Fisher matrix is singular and its quadratic form vanishes on the nonzero scale vector.

The obstruction is exact rather than asymptotic. It persists for every finite sample size, every value of $a$, and every possible score assigned to the remaining coordinate. It can be repaired by removing the redundant parameter, introducing sample dependence into the exponential term, or taking a quotient by distributional equivalence.

## 2. Finite exp–log probability families

Let $I$ be a finite, nonempty index set and let $x:I\to\mathbb R$ assign a sample value $x_i$ to each outcome $i\in I$. For real parameters $a$ and $b$, define the logarithmic activation

$$
\ell_i(b)=\log(1+b x_i).
$$

The **activation mass** is

$$
A(b)=\sum_{i\in I}\ell_i(b),
$$

and the **raw exp–log weight** is

$$
w_i(a,b)=e^a\ell_i(b).
$$

The corresponding **partition function** is the total raw mass

$$
Z(a,b)=\sum_{i\in I}w_i(a,b).
$$

Whenever $Z(a,b)\ne0$, define the normalized weight

$$
p_i(a,b)=\frac{w_i(a,b)}{Z(a,b)}.
$$

For these quantities to describe an ordinary probability distribution, one needs $p_i(a,b)\ge0$ for all $i$ and $\sum_i p_i(a,b)=1$. Strict positivity is especially convenient in information geometry because it places the distribution in the interior of the probability simplex.

### Proposition 2.1 (Partition factorization)

For every finite sample family and all real $a,b$,

$$
Z(a,b)=e^a A(b).
$$

**Proof sketch.** The factor $e^a$ is independent of $i$ and can be pulled through the finite sum:

$$
\sum_i e^a\ell_i(b)=e^a\sum_i\ell_i(b)=e^aA(b).
$$

No positivity assumption is needed. $\square$

### Lemma 2.2 (Positive activations)

Suppose $b>0$ and $x_i>0$ for every $i\in I$. Then $\ell_i(b)>0$ for every outcome.

**Proof sketch.** The product $b x_i$ is positive, so $1+b x_i>1$. The natural logarithm is strictly positive on $(1,\infty)$. $\square$

### Corollary 2.3 (Positive activation mass)

If $I$ is nonempty, $b>0$, and every $x_i>0$, then $A(b)>0$.

**Proof sketch.** By Lemma 2.2, $A(b)$ is a nonempty finite sum of strictly positive numbers. $\square$

The nonemptiness requirement cannot simply be omitted: an empty sum is zero. The positivity hypotheses are sufficient rather than necessary; other sign configurations can also make $A(b)$ nonzero. They provide a clean domain on which every weight is positive.

## 3. Exact scale cancellation

### Theorem 3.1 (Scale-Cancellation Theorem)

If $A(b)\ne0$, then for every $i\in I$ and every real $a$,

$$
p_i(a,b)=\frac{\ell_i(b)}{A(b)}
=\frac{\log(1+b x_i)}{\sum_{j\in I}\log(1+b x_j)}.
$$

**Proof sketch.** Proposition 2.1 gives $Z(a,b)=e^aA(b)$. Since $e^a>0$ and hence is nonzero,

$$
p_i(a,b)=\frac{e^a\ell_i(b)}{e^aA(b)}=\frac{\ell_i(b)}{A(b)}.
$$

The assumption $A(b)\ne0$ ensures that the denominator is defined. $\square$

### Corollary 3.2 (Independence of exponential scale)

If $A(b)\ne0$, then for arbitrary real $a_1,a_2$,

$$
p_i(a_1,b)=p_i(a_2,b)
$$

for every $i\in I$.

**Proof sketch.** Both sides equal $\ell_i(b)/A(b)$ by Theorem 3.1. $\square$

This is the identifiability obstruction. The parameter-to-distribution map

$$
\Phi:\mathbb R^2\to\Delta(I),\qquad \Phi(a,b)=(p_i(a,b))_{i\in I},
$$

is constant in the $a$-direction. Here $\Delta(I)$ denotes the probability simplex whenever the weights are nonnegative and normalized. For each fixed admissible $b$, the whole line $\{(a,b):a\in\mathbb R\}$ lies in one fiber of $\Phi$.

### Proposition 3.3 (Normalization)

If $A(b)\ne0$, then

$$
\sum_{i\in I}p_i(a,b)=1.
$$

**Proof sketch.** Apply Theorem 3.1 and sum:

$$
\sum_i p_i(a,b)=\frac{\sum_i\ell_i(b)}{A(b)}=\frac{A(b)}{A(b)}=1.
$$

This statement is algebraic and does not by itself assert nonnegativity. $\square$

### Theorem 3.4 (Strictly positive probability regime)

Suppose $I$ is finite and nonempty, $b>0$, and $x_i>0$ for every $i\in I$. Then $A(b)>0$, each $p_i(a,b)>0$, and

$$
\sum_{i\in I}p_i(a,b)=1.
$$

Thus $(p_i(a,b))_{i\in I}$ is a strictly positive probability distribution.

**Proof sketch.** Lemma 2.2 gives $\ell_i(b)>0$, and Corollary 2.3 gives $A(b)>0$. Their quotient is positive. Proposition 3.3 supplies normalization. $\square$

## 4. Identifiability and score functions

A parameterization $\theta\mapsto p(\theta)$ is globally identifiable if distinct parameter values induce distinct distributions. Local identifiability requires, informally, that infinitesimal parameter directions produce independent infinitesimal changes in the distribution. In a regular positive model, this is reflected by the rank of the score vectors and the Fisher matrix.

For a coordinate $\theta^r$, its score at outcome $i$ is

$$
S_r(i;\theta)=\frac{\partial}{\partial\theta^r}\log p_i(\theta).
$$

For the scale coordinate $a$, one can compute the score in two equivalent ways. Theorem 3.1 shows directly that $p_i$ does not depend on $a$, so $S_a(i)=0$. Alternatively,

$$
\log p_i(a,b)=\log w_i(a,b)-\log Z(a,b).
$$

The logarithmic derivative of $w_i$ with respect to $a$ is $1$. Since $Z(a,b)=e^aA(b)$, the logarithmic derivative of $Z$ is also $1$. Their difference is zero.

### Theorem 4.1 (Vanishing scale score)

If $A(b)\ne0$, then the normalized score in the common scale direction is zero for every outcome:

$$
S_a(i;a,b)=0.
$$

Equivalently, using the common raw and partition derivatives,

$$
S_a(i;a,b)=1-\frac{Z(a,b)}{Z(a,b)}=0.
$$

**Proof sketch.** Since $A(b)\ne0$ and $e^a\ne0$, Proposition 2.1 implies $Z(a,b)\ne0$. Therefore $Z/Z=1$, or, equivalently, differentiate the scale-independent expression in Theorem 3.1. $\square$

The vanishing score is not a numerical approximation. It is an identity throughout the admissible domain. It means that observations drawn from the model contain zero information about $a$.

For completeness, in the positive regime the actual shape score may be written explicitly. Differentiating

$$
\ell_i(b)=\log(1+b x_i)
$$

gives

$$
\ell_i'(b)=\frac{x_i}{1+b x_i}.
$$

Hence

$$
S_b(i;b)=\frac{x_i}{(1+b x_i)\ell_i(b)}
-\frac{A'(b)}{A(b)},
$$

where

$$
A'(b)=\sum_j\frac{x_j}{1+b x_j}.
$$

The first term depends on the outcome; the second centers it by its expectation. The principal degeneracy results below are stronger than this formula requires: they hold for any candidate shape score whatsoever.

## 5. Fisher information and degeneracy

For a positive discrete model with score coordinates $S_r$, the Fisher information matrix is

$$
I_{rs}(a,b)=\sum_{i\in I}p_i(a,b)S_r(i;a,b)S_s(i;a,b).
$$

It is a weighted Gram matrix of the score functions, hence positive semidefinite. It is positive definite exactly when no nonzero parameter-space vector determines an almost surely zero linear combination of scores.

### Proposition 5.1 (Zero scale information)

If $A(b)\ne0$, then

$$
I_{aa}(a,b)=\sum_i p_i(a,b)S_a(i;a,b)^2=0.
$$

**Proof sketch.** Every summand contains $S_a(i)^2=0$ by Theorem 4.1. $\square$

### Proposition 5.2 (Vanishing mixed Fisher pairings)

Let $T:I\to\mathbb R$ be any function, interpreted as any candidate second score. If $A(b)\ne0$, then

$$
\sum_{i\in I}p_i(a,b)S_a(i;a,b)T(i)=0.
$$

**Proof sketch.** Each summand contains the factor $S_a(i)=0$. This applies in particular to the genuine shape score $S_b$. $\square$

### Theorem 5.3 (Zero scale row and column)

Form the two-coordinate Fisher-type matrix from the true scale score and an arbitrary shape score $T$:

$$
I_T(a,b)=\left(\sum_i p_i S_r(i)S_s(i)\right)_{r,s\in\{a,b\}},
$$

where $S_a(i)=0$ and $S_b(i)=T(i)$. If $A(b)\ne0$, then

$$
I_T(a,b)=
\begin{pmatrix}
0&0\\
0&\displaystyle\sum_i p_i(a,b)T(i)^2
\end{pmatrix}.
$$

In particular, the scale row and the scale column are both identically zero.

**Proof sketch.** Proposition 5.1 gives the upper-left entry, and Proposition 5.2 gives both mixed entries. The lower-right entry remains the weighted second moment of $T$. $\square$

### Corollary 5.4 (Fisher Singularity Theorem)

Under the assumptions of Theorem 5.3,

$$
\det I_T(a,b)=0
$$

for every candidate shape score $T$.

**Proof sketch.** A square matrix with a zero row, or a zero column, has determinant zero. More explicitly, the determinant of the displayed diagonal matrix is $0\cdot\sum_i p_iT(i)^2=0$. $\square$

### Theorem 5.5 (Failure of positive definiteness)

If $A(b)\ne0$, the two-parameter Fisher quadratic form vanishes on a nonzero vector. Specifically, for $v=(1,0)$,

$$
v^{\mathsf T}I_T(a,b)v=0.
$$

Consequently $I_T(a,b)$ is not positive definite on the proposed two-dimensional parameter space.

**Proof sketch.** Multiplication by $v$ selects the scale row and column, both of which vanish by Theorem 5.3. Since $v\ne0$, the defining condition for positive definiteness fails. $\square$

These results are independent of whether the shape information itself is positive. Even if $\sum_i p_iT(i)^2>0$, the full matrix has rank one rather than two. If the shape score also vanishes, its rank is zero.

## 6. Geometric consequences

A Fisher information matrix defines a Riemannian metric only when it is positive definite. In the present coordinates, it is degenerate along every tangent vector proportional to $\partial/\partial a$. Such vectors represent parameter changes with no distributional effect.

Several consequences follow.

First, the ordinary two-dimensional natural gradient is not defined by matrix inversion, because $I_T^{-1}$ does not exist. One may use a pseudoinverse, but doing so implicitly discards the null direction and should be understood as optimization on an identifiable quotient rather than on a genuine two-dimensional Fisher manifold.

Second, a two-dimensional Levi–Civita connection and Gaussian curvature cannot be obtained from this singular matrix by the standard Riemannian formulas. In particular, the model does not establish a constant-negative-curvature hyperbolic parameter geometry. Hyperbolicity requires a nondegenerate metric before curvature can even be posed in the conventional sense.

Third, exponential sensitivity of raw weights is distinct from sensitivity of normalized probabilities. Differentiating $w_i=e^a\ell_i$ with respect to $a$ gives $\partial_a w_i=w_i$, which may be large. Yet this variation is radial in the positive cone of raw measures: every component changes in the same proportion. Projection to the simplex by normalization removes precisely that radial direction.

Fourth, flatness notions must be separated. In regular exponential families, exponential and mixture connections may be flat while the Levi–Civita curvature of the Fisher metric is nonzero. Conversely, the appearance of exponential and logarithmic functions does not by itself establish dual flatness. Connection coefficients and potentials must be defined on an identifiable manifold and checked directly.

A useful geometric picture is the map from positive raw vectors to the probability simplex:

$$
(w_i)_i\longmapsto \left(\frac{w_i}{\sum_jw_j}\right)_i.
$$

Every positive ray $\{c w:c>0\}$ maps to a single probability point. The $a$-coordinate moves only along such a ray. It is therefore a gauge coordinate for scale, not a statistical coordinate.

## 7. Numerical diagnostics and algorithms

The structural proof is exact, but numerical experiments provide transparent diagnostics and guard against implementation errors.

### Algorithm 7.1 (Normalized exp–log evaluation)

Given positive samples $x_1,\ldots,x_n$, parameters $a,b$, compute

$$
\ell_i=\log(1+b x_i),\qquad A=\sum_i\ell_i,
$$

and return $p_i=\ell_i/A$. The direct formula avoids overflow from $e^a$ and makes scale independence explicit. It requires $O(n)$ time and $O(n)$ storage, or $O(1)$ auxiliary storage if probabilities overwrite activations.

### Algorithm 7.2 (Fisher degeneracy audit)

Given probabilities $p_i$ and any proposed shape scores $T_i$, construct

$$
I=
\begin{pmatrix}
0&0\\
0&\sum_i p_iT_i^2
\end{pmatrix}.
$$

Report its determinant and eigenvalues. The determinant is exactly zero in symbolic arithmetic and should be near machine zero numerically. The algorithm takes $O(n)$ time.

### Algorithm 7.3 (Scale-invariance sweep)

Fix $b$ and a sample vector, evaluate probabilities across a grid of scale values $a_1,\ldots,a_m$, and compare each vector with a reference. In exact arithmetic all differences vanish. Floating-point implementations using the reduced formula also return identical vectors; direct raw exponentiation may overflow for large $a$, demonstrating why algebraic simplification is computationally valuable. The sweep costs $O(mn)$ time.

As a concrete example, take $x=(0.5,1,2,4)$ and $b=0.8$. Then the activation vector is

$$
(\log 1.4,\log 1.8,\log 2.6,\log 4.2),
$$

and normalization gives a fixed probability vector independent of whether $a=-20$, $a=0$, or $a=20$. The raw masses differ by factors as large as $e^{40}$, while their normalized proportions coincide.

## 8. Identifiable reformulations

The degeneracy suggests several mathematically distinct repairs.

### 8.1 Remove the common scale

The most economical model retains only $b$:

$$
p_i(b)=\frac{\log(1+b x_i)}{\sum_j\log(1+b x_j)}.
$$

Its Fisher information is the scalar

$$
I_{bb}(b)=\sum_i p_i(b)S_b(i;b)^2.
$$

Because the score is centered, this is its variance. It is positive if and only if $S_b$ is not constant on the support. The resulting statistical family is a curve, so intrinsic Gaussian curvature is not a two-dimensional notion; nevertheless, Fisher length, geodesic distance along the curve, and one-dimensional natural-gradient flow remain meaningful.

### 8.2 Make the exponential sample-dependent

Consider instead

$$
w_i(a,b)=\exp(a g_1(x_i))\log(1+b g_2(x_i)).
$$

If $g_1(x_i)$ varies with $i$, the exponential cannot generally be extracted as a common factor. The normalized $a$-score becomes $g_1(x_i)-\mathbb E_p[g_1]$. The $b$-score is similarly centered. The Fisher matrix is their covariance matrix. It is positive definite exactly when no nontrivial linear combination of the centered scores vanishes on the support. This condition supplies a precise target for a nonsingularity theorem.

### 8.3 Quotient by distributional equivalence

Define

$$
(a,b)\sim(a',b')
$$

whenever the two parameter pairs induce the same normalized distribution. For the model studied here, $(a,b)\sim(a',b)$ for all $a,a'$. Under additional assumptions ensuring that distinct $b$ values induce distinct distributions, the quotient can be identified with the $b$-axis. More generally, quotienting isolates the identifiable parameter space without privileging a coordinate deletion.

## 9. Applications and modeling lessons

The cancellation phenomenon appears whenever normalized models contain common multiplicative factors. In softmax models, adding the same constant to every logit multiplies all exponentiated logits by a common factor and leaves probabilities unchanged. In energy-based models, an additive constant in the energy is unidentifiable. In Bayesian calculations, likelihoods specified only up to proportionality deliberately exploit the same invariance. Attention weights likewise ignore common shifts in attention logits.

These examples show that redundancy is not inherently a defect. It becomes a problem when one interprets redundant coordinates as independent geometric directions or attempts to invert a singular Fisher matrix without acknowledging the quotient. Gauge fixing, constrained parameterization, and pseudoinverse methods can all be appropriate, provided their geometric meaning is clear.

For optimization, the result explains why naive curvature-aware updates may be unstable or undefined. A gradient component along $a$ cannot be inferred from normalized likelihood because the objective is flat in that direction. Regularization may select a value of $a$, but that selection comes from the regularizer rather than the statistical model. Distinguishing data information from external preference is essential for interpreting learned parameters.

For architecture design, the analysis gives a direct prescription: if a parameter is intended to alter relative probabilities, it must interact with sample-dependent features before normalization. A common post-activation multiplier cannot do so.

## 10. Discussion

The original geometric motivation—understanding exp–log networks through Fisher information—remains valuable, but the single-neuron model must first pass an identifiability test. The analysis demonstrates that normalization is not a cosmetic final step. It can collapse dimensions, erase apparent sensitivity, and determine the rank of the statistical metric.

The strongest aspect of the result is its universality within the stated model. No special sample values are needed for scale cancellation. The activation mass need only be nonzero. Positivity assumptions enter only to guarantee an interior probability distribution, not to prove independence from $a$. Likewise, Fisher singularity does not depend on the detailed formula for the shape score. Once one score coordinate is identically zero, every Gram matrix containing it is singular.

The result also clarifies the logical order of future geometric work:

1. define a valid probability family;
2. identify and remove parameter redundancies;
3. prove Fisher nonsingularity;
4. then define connections, geodesics, and curvature;
5. finally analyze optimization consequences.

Skipping the second and third steps risks assigning geometric meaning to coordinates that do not move the distribution.

## 11. Future work

A complete theory can proceed in six directions. First, the reduced one-parameter family should be studied under explicit nonconstancy assumptions to characterize when its scalar Fisher information is positive. Second, a corrected two-parameter family with a sample-dependent exponential should be developed, with both scores derived exactly. Third, nonsingularity should be characterized through linear independence of centered scores in weighted $L^2$. Fourth, concrete finite-support models should be used to compute Levi–Civita connection coefficients and Gaussian curvature rather than inferring curvature from functional sensitivity. Fifth, exponential, mixture, and Levi–Civita connections should be distinguished carefully when examining dual or projective flatness. Sixth, a general quotient construction should identify parameter values that induce the same normalized distribution before any metric is introduced.

## 12. Conclusion

For the normalized finite exp–log weights

$$
w_i(a,b)=e^a\log(1+b x_i),
$$

the exponential scale $e^a$ cancels exactly. The resulting probabilities depend only on $b$. Under positive inputs and $b>0$, they form a strictly positive probability distribution, but the scale score is zero, all Fisher pairings with the scale direction vanish, and the two-parameter Fisher determinant is zero. The nonzero vector $(1,0)$ has zero Fisher length, so the proposed parameter plane does not carry a nondegenerate Fisher metric.

The mathematical lesson is concise: normalization records proportions, not common scale. The modeling lesson is broader: identifiability is a prerequisite for information geometry. Removing the redundant coordinate, making scale sample-dependent, or passing to a quotient transforms the obstruction into a blueprint for a sound statistical manifold.