# The Invisible Parameter: What Normalization Erases in an Exp–Log Model

## A geometric promise meets an algebraic surprise

Information geometry begins with an appealing idea: a statistical model is not merely a formula but a curved space. Each point in that space represents a probability distribution, and the Fisher information tells us how distinguishable nearby points are. Directions in which the distribution changes rapidly are long; directions that barely change it are short. This geometric viewpoint supports natural-gradient optimization, uncertainty quantification, and a precise language for whether model parameters really encode independent effects.

Consider a finite collection of positive sample values $x_1,\ldots,x_n$ and the two-parameter exp–log weights

$$
w_i(a,b)=e^a\log(1+b x_i).
$$

At first sight the two parameters appear to do very different jobs. The parameter $a$ provides exponential scaling, while $b$ changes the logarithmic response to each sample. Because exponentials can be extremely sensitive, one might expect the $a$-direction to produce dramatic statistical motion and perhaps an interesting curved geometry.

Normalization changes the story completely.

To turn the weights into probabilities, define the partition function

$$
Z(a,b)=\sum_{j=1}^n e^a\log(1+b x_j)
$$

and probabilities

$$
p_i(a,b)=\frac{e^a\log(1+b x_i)}{Z(a,b)}.
$$

The central result is simple but decisive: the factor $e^a$ is common to every weight, so it disappears from every normalized probability. The supposedly two-dimensional family is statistically only one-dimensional.

## The cancellation theorem

Write

$$
A(b)=\sum_{j=1}^n \log(1+b x_j)
$$

for the total logarithmic activation. Factoring the common scale gives

$$
Z(a,b)=e^a A(b).
$$

Whenever $A(b)\ne 0$, cancellation yields the **Scale-Cancellation Theorem**:

$$
p_i(a,b)=\frac{\log(1+b x_i)}{A(b)}.
$$

In particular, for any two scale values $a_1$ and $a_2$,

$$
p_i(a_1,b)=p_i(a_2,b)
$$

for every sample $i$. Changing $a$ may multiply every raw weight by a huge factor, but after normalization it moves the probability distribution by exactly zero.

This is a general lesson. Probability normalization is blind to common positive scale. If all scores in a race are doubled, their shares of the total remain unchanged. If every unnormalized likelihood is multiplied by the same constant, posterior proportions remain unchanged. An exponential can look powerful in an unnormalized formula while being statistically invisible.

## When the formula really defines a probability distribution

For the most natural regime, assume the sample space is nonempty, every $x_i>0$, and $b>0$. Then $b x_i>0$, hence $1+b x_i>1$, and therefore

$$
\log(1+b x_i)>0.
$$

Every activation is positive, so their sum $A(b)$ is positive. It follows that each $p_i(a,b)>0$. Moreover,

$$
\sum_{i=1}^n p_i(a,b)
 =\frac{\sum_i\log(1+b x_i)}{A(b)}=1.
$$

Thus the model gives a strictly positive probability distribution under these assumptions. More generally, normalization still sums to one whenever $A(b)\ne0$, although positivity requires additional sign conditions.

These elementary facts matter because information geometry applies to distributions, not arbitrary arrays of numbers. Positivity also makes logarithmic scores and Fisher information well behaved.

## Identifiability: can data tell parameters apart?

A parameter is identifiable if different parameter values produce different observable distributions. Here the complete line

$$
\{(a,b):a\in\mathbb R\}
$$

maps to one and the same distribution when $b$ is fixed. No sample, however large, can distinguish $a=0$ from $a=100$ using this normalized model. The failure is structural, not a shortage of data.

An analogy is a map printed with two coordinate labels that secretly describe the same direction. The paper may display a two-dimensional grid, but one coordinate adds no new location. Before measuring curvature on such a map, one must remove the duplicate coordinate.

The same point appears through the score. For a parameter $\theta$, the score at outcome $i$ is the derivative of $\log p_i$ with respect to $\theta$. Since $p_i$ is independent of $a$, its scale score is zero. Directly, the raw weight contributes logarithmic derivative $1$, while the partition function contributes the same derivative $1$. Hence

$$
S_a(i)=1-\frac{Z(a,b)}{Z(a,b)}=0
$$

whenever normalization is defined.

The cancellation is therefore visible both globally, through equality of distributions, and infinitesimally, through the vanishing score.

## The Fisher matrix loses a dimension

The Fisher information matrix is the expected outer product of score vectors. If $S_b(i)$ denotes any candidate score in the shape direction, then the two-coordinate Fisher matrix has entries

$$
I_{jk}=\sum_{i=1}^n p_i S_j(i)S_k(i),
\qquad (S_1,S_2)=(S_a,S_b).
$$

Because $S_a(i)=0$, every entry involving the scale direction vanishes:

$$
I_{aa}=0,\qquad I_{ab}=0,\qquad I_{ba}=0.
$$

Thus the matrix necessarily has the form

$$
I(a,b)=
\begin{pmatrix}
0&0\\
0&I_{bb}
\end{pmatrix}.
$$

This conclusion does not depend on how the second score is chosen. The **Fisher Singularity Theorem** states that, whenever $A(b)\ne0$, the determinant of the two-parameter Fisher matrix is zero for every possible shape score:

$$
\det I(a,b)=0.
$$

There is an equally geometric formulation. For the nonzero parameter-space vector $v=(1,0)$,

$$
v^{\mathsf T}I(a,b)v=0.
$$

A positive-definite metric must assign positive squared length to every nonzero vector. The Fisher form fails that test. It is positive semidefinite at best, with an entire null direction corresponding to changes in $a$.

## Why there is no two-dimensional hyperbolic geometry here

Hyperbolic geometry requires a genuine nondegenerate metric. Gaussian curvature, Levi–Civita geodesics, and metric natural gradients all presume that lengths and angles are defined in every tangent direction. A singular matrix cannot be inverted to form the usual natural-gradient update, and it does not determine a two-dimensional Riemannian geometry.

Consequently, this normalized single-neuron family cannot support a nondegenerate two-dimensional Hessian metric or a two-dimensional constant-negative-curvature geometry in the coordinates $(a,b)$. This does not prove that every exp–log model lacks interesting geometry. It shows that this particular parameterization contains a gauge-like redundancy that must be addressed first.

The distinction is important. Exponential sensitivity of raw outputs does not imply negative curvature of normalized probabilities. Curvature is a property of how distributions vary, and in the $a$-direction these distributions do not vary at all.

## Repairing the model

There are several principled ways forward.

The simplest is to remove $a$ and study the one-parameter family indexed by $b$. Its Fisher information is a scalar, and it is positive precisely when the $b$-score is not almost surely constant under the model. This is an identifiable curve of distributions rather than a degenerate surface.

A second option is to make the exponential sample-dependent, for example

$$
w_i(a,b)=\exp(a g_1(x_i))\log(1+b g_2(x_i)).
$$

Unless $g_1$ is constant across samples, the factor involving $a$ can no longer be pulled out of the partition function. Both parameters may then influence relative probabilities. The resulting Fisher matrix is a covariance matrix of the two scores, and its determinant is positive exactly when the centered scores are linearly independent in the weighted squared-integrable space.

A third option is conceptual: declare parameter pairs equivalent whenever they induce the same normalized distribution, then pass to the quotient space. In the present model, all values of $a$ at fixed $b$ belong to one equivalence class. Geometry should live on the space of these classes, not on the redundant coordinate plane.

Only after identifiability is established should one ask whether a corrected model is Hessian, dually flat, projectively flat, or negatively curved. These are separate geometric properties, not automatic consequences of an exponential appearing in a formula.

## A practical diagnostic for model builders

The exp–log example suggests a short audit that can save substantial effort:

1. Write the unnormalized weights explicitly.
2. Factor the partition function before differentiating.
3. Check whether any parameter occurs only as a common multiplier.
4. Simplify the normalized probabilities.
5. Compute scores and search for linear dependencies.
6. Test the Fisher matrix for null vectors before inverting it or computing curvature.

This audit applies far beyond exp–log networks. Mixture models, energy-based models, softmax classifiers, attention mechanisms, and Bayesian likelihoods all contain normalization. In each setting, a common offset or scale can become an unobservable gauge degree of freedom.

## A small example with a large dynamic range

Take four sample values $x=(0.5,1,2,4)$ and choose $b=0.8$. Their logarithmic activations are

$$
(\log 1.4,\log 1.8,\log 2.6,\log 4.2),
$$

which normalize to probabilities of approximately

$$
(0.1015,0.1773,0.2883,0.4329).
$$

Now let $a$ range from $-20$ to $20$. The total raw mass grows from about $6.8\times10^{-9}$ to $1.6\times10^9$, a change of more than seventeen orders of magnitude. Yet the four probabilities above do not change. This contrast captures the whole phenomenon: numerical magnitude and statistical information are different things.

In practical software, the cancellation is also a stability improvement. Computing $e^a$ needlessly can underflow for very negative $a$ or overflow for very positive $a$. Evaluating the reduced expression directly avoids both hazards. The structural analysis therefore improves not only interpretation but also numerical design.

## Geometry begins after redundancy ends

Information geometry can illuminate how learning systems respond to perturbations, but it measures changes in distributions rather than changes in arbitrary intermediate quantities. The first geometric question is consequently not “What is the curvature?” but “Which parameter directions are observable?”

The broader message is constructive. A singular Fisher matrix is not merely a failed calculation; it reveals how the model should be redesigned. Here it says that the exponential scale is not a statistical feature at all. Once that invisible parameter is removed, moved inside a sample-dependent term, or quotiented away, the genuine geometry can begin.
That order of operations matters in both theory and practice.
