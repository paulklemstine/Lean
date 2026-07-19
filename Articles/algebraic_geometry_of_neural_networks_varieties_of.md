# When Neural Networks Become Tropical Landscapes

## A precise bridge between sharp decisions and smooth computation

A neural classifier divides space. In two dimensions, it may separate images represented by points in a plane; in a medical model, it may divide measurements into low-risk and high-risk populations; in a physical surrogate, it may distinguish stable from unstable regimes. Whatever the application, the classifier’s most consequential geometric object is its **decision set**: the collection of inputs where its score is exactly zero and its predicted label is poised to change.

For networks built from rectified linear units, or ReLUs, this geometry is often described as a mosaic of flat pieces. That description is correct but incomplete. A particularly important convex sector of these networks has a sharper mathematical identity: it is **max-affine**, meaning that its output is assembled by repeatedly taking maxima of affine functions. This is also the basic arithmetic of tropical geometry, a field in which ordinary addition is replaced by maximum and multiplication becomes ordinary addition.

The connection is more than a metaphor. It yields a quantitative theorem about replacing a sharp tropical maximum by a smooth logarithmic approximation. The theorem says exactly how much error smoothing introduces, how that error grows with network depth, and when the classification is guaranteed not to change. It also reveals where seductive geometric claims about arbitrary ReLU networks go too far.

## From a ReLU gate to tropical arithmetic

The scalar ReLU function is

$$
\operatorname{ReLU}(t)=\max(0,t).
$$

If $t$ is an affine function of an input $x$, then one ReLU gate takes the maximum of two affine functions: the zero function and $t(x)$. Repeating this operation naturally produces expressions with affine leaves and binary maximum nodes. Call such an expression a **max-affine expression**.

Its value $F(x)$ is defined recursively. An affine leaf $g$ evaluates to $g(x)$. If an expression joins two subexpressions $P$ and $Q$, then

$$
F(x)=\max(P(x),Q(x)).
$$

The **depth** $d$ is the largest number of maximum operations encountered along any root-to-leaf path. A single affine function has depth $0$; joining expressions of depths $d_1$ and $d_2$ produces depth $1+\max(d_1,d_2)$.

This is tropical algebra in action. A maximum of affine functions forms a convex, piecewise-linear landscape. Each affine leaf is a plane; the network output is their upper envelope. Boundaries between linear regions occur where competing planes tie. In low dimensions, those ties look like edges and vertices of a crystalline terrain.

Yet many numerical and physical models prefer smooth functions. Hard maxima create kinks, while smooth surrogates support gradients everywhere. The standard smooth replacement is the log-sum-exp operation. For inverse temperature $\beta>0$, replace $\max(a,b)$ by

$$
\operatorname{LSE}_\beta(a,b)
=\frac{1}{\beta}\log\left(e^{\beta a}+e^{\beta b}\right).
$$

Applying this replacement at every maximum node gives a smooth evaluation $F_\beta(x)$. Large $\beta$ corresponds to low temperature and a sharper approximation; small $\beta$ gives a softer blend.

## The depth-controlled dequantization theorem

The elementary inequality behind the story is

$$
\max(a,b)
\leq
\frac{1}{\beta}\log\left(e^{\beta a}+e^{\beta b}\right)
\leq
\max(a,b)+\frac{\log 2}{\beta}.
$$

The smooth maximum always lies above the hard maximum, but by no more than $\log 2/\beta$. The central result shows how this local error propagates through an entire binary expression.

**Depth-Controlled Dequantization Theorem.** Let $F$ be any max-affine expression of depth $d$, and let $F_\beta$ be obtained by replacing every binary maximum with log-sum-exp at inverse temperature $\beta>0$. Then, for every input $x$,

$$
0\leq F_\beta(x)-F(x)\leq \frac{d\log 2}{\beta}.
$$

The striking feature is what does **not** appear: the number of affine leaves. A large balanced expression may contain exponentially many leaves while having modest depth. The worst-case error accumulates only along a deepest computational path.

The proof follows the expression tree. At a leaf, sharp and smooth evaluations agree. At a maximum node, assume both children already obey their depth bounds. The two smoothed child values can each drift upward, but the larger inherited drift is controlled by the larger child depth. The new log-sum-exp operation contributes at most one additional $\log 2/\beta$. Induction then produces exactly $d\log 2/\beta$.

For a single ReLU gate, $d=1$, so the result specializes to

$$
\max(0,x)
\leq
\frac{1}{\beta}\log\left(1+e^{\beta x}\right)
\leq
\max(0,x)+\frac{\log 2}{\beta}.
$$

The middle expression is the familiar softplus function. Thus the theorem turns a standard engineering approximation into a network-level guarantee.

## A certified safe zone for decisions

Suppose a binary classifier predicts positive when $F(x)>0$ and negative otherwise. Smoothing raises the score, so one might worry that a negative point could cross the decision threshold. The error theorem identifies the exact uncertainty band.

**Margin Stability Theorem.** Under the assumptions above, if

$$
|F(x)|>\frac{d\log 2}{\beta},
$$

then $F_\beta(x)>0$ if and only if $F(x)>0$.

In words, smoothing cannot change the label at any point whose hard score lies farther from zero than the depth-dependent error budget. The band

$$
\left[-\frac{d\log 2}{\beta},\frac{d\log 2}{\beta}\right]
$$

is therefore the only region of score space where disagreement can occur.

This has an immediate design interpretation. To guarantee label preservation at all inputs with margin at least $m>0$, it is enough to choose

$$
\beta>\frac{d\log 2}{m}.
$$

Deeper expressions require a colder, sharper approximation; larger margins permit a smoother one. In optimization, differentiable programming, statistical physics, and energy-based learning, this gives a transparent tradeoff between smoothness and fidelity.

## Counting budgets: algebra before geometry

A proposed layerwise region budget begins with $1$ and multiplies by $2w$ for each layer of width $w$. For widths $w_1,\dots,w_L$, define

$$
R([])=1,
\qquad
R([w_1,\dots,w_L])=2w_1R([w_2,\dots,w_L]).
$$

This recurrence has the exact closed form

$$
R=2^L\prod_{i=1}^{L}w_i.
$$

The proof is a direct induction on the list of widths: each new layer contributes one factor of $2$ and one factor of its width.

But this identity must be read carefully. It proves the algebraic solution of the recurrence; it does not prove that every network realizes that many geometric regions, nor even that the recurrence universally bounds realized regions. Width counts available gates, while actual cuts depend on input dimension, rank, degeneracy, and the arrangement inherited from previous layers. A formula can be exactly solved and still rest on a geometric premise that needs separate justification.

## Two small counterexamples with large consequences

The tropical picture is powerful precisely when its hypotheses are respected. Two elementary examples mark the boundary.

First, consider the scalar ReLU itself. Its zero set is

$$
\{x:\max(0,x)=0\}=(-\infty,0].
$$

This set contains the entire open half-line $(-\infty,0)$. It is not merely a thin codimension-one wall. Therefore the zero set of an arbitrary ReLU output cannot automatically be called a hypersurface. Nondegeneracy conditions are needed, or one must define the decision boundary as the interface between positive and negative label regions rather than the raw zero set.

Second, a proposed singularity estimate based on products of pair counts can vanish at width one because

$$
\binom{1}{2}=0.
$$

Yet the width-one ReLU has a genuine kink at the origin. For every $\varepsilon>0$,

$$
\operatorname{ReLU}(-\varepsilon)=0,
\qquad
\operatorname{ReLU}(\varepsilon)=\varepsilon.
$$

The slopes on the two sides differ. Thus a pair-count expression that returns zero need not detect even the simplest nonsmooth point. Singular behavior depends on active affine pieces and how they meet, not merely on choosing neuron pairs layer by layer.

## What survives of the tropical vision

The most defensible conclusion is both narrower and more useful than the sweeping claim that all neural decision boundaries are tropical hypersurfaces.

For convex max-affine networks, the tropical description is exact: the score is an upper envelope of affine functions. Replacing tropical maximum by log-sum-exp gives a smooth analytic model with a uniform error bounded by $d\log 2/\beta$. Outside that explicit score band, binary classifications agree. These statements are global, quantitative, and independent of the number of leaves.

For unrestricted signed networks, the situation changes. Negative combinations can destroy convexity, so a single max-affine expression is no longer adequate. A promising replacement is a difference of two max-affine expressions, analogous to a tropical rational function. Its decision set would be an equality locus between two tropical polynomials rather than the zero set of one convex tropical polynomial.

Likewise, singularity counting should focus on active-set incidence: which affine pieces actually reach the upper envelope and where several of them tie. Region counting should depend on the rank of induced hyperplane arrangements, not raw width alone. And topological comparison between hard and smooth decision sets will require more than a value bound: it needs a condition excluding critical values inside the uncertainty band.

The broader lesson is methodological. Neural networks invite grand geometric slogans, but small examples can distinguish a theorem from an analogy. Here, the durable bridge between tropical geometry and neural computation is not an unrestricted identification. It is a precise approximation principle: sharp max-affine landscapes can be smoothed, their error is controlled by depth, and their decisions remain stable wherever the margin exceeds that control. That is enough to turn a visual metaphor into mathematics—and enough to guide how smooth surrogates are chosen in real models.

There is also a practical virtue in knowing exactly what has been proved. A depth-dependent envelope can be tested point by point, plotted over data, and translated into a temperature choice before a model is deployed. The negative examples are equally constructive: they tell researchers which measurements to replace. Instead of counting nominal neuron pairs, inspect active affine pieces; instead of equating a zero plateau with a separating wall, examine the interface of label regions. Precision does not make the geometric vision smaller. It gives that vision solid ground from which to grow.
