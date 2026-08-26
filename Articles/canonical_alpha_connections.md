# The Geometry Hidden in a Coin Flip

## How a single number, $\alpha$, organizes every natural way to do calculus on a space of probability distributions

Suppose you are handed a family of probability distributions — say, all the biased coins, indexed by the probability $p$ of heads. This is a one-dimensional space of "points", each point a coin. Now ask an innocent-sounding question: **what is a straight line in this space?**

The question is not rhetorical. Every time a statistician runs gradient descent on a likelihood, interpolates between two models, or says that a maximum-likelihood estimate is "close to" the truth, they are quietly assuming an answer. And it turns out there is not one answer. There is a whole one-parameter family of answers, a pencil of geometries indexed by a real number $\alpha$, and the two most useful members of the family sit at $\alpha = 1$ and $\alpha = -1$ — the *exponential* and *mixture* geometries. Between them, exactly at the midpoint $\alpha = 0$, sits the geometry that a Riemannian geometer would have written down without thinking about statistics at all.

This article is about why that family exists, why its coefficients must be exactly $\frac{1-\alpha}{2}$ and nothing else, and what happens when you feed it combinatorial input: symmetric sample spaces, binary features, independent factors.

---

## Two ways to walk between two coins

Take two coins, one with $p = 0.2$ and one with $p = 0.8$. What is the coin "halfway between" them?

**Answer one.** Average the probability vectors. Halfway between $(0.2, 0.8)$ and $(0.8, 0.2)$ is $(0.5, 0.5)$. This is *mixture* interpolation: flip a fair auxiliary coin to decide which of the two coins you use. It is linear in the probabilities themselves.

**Answer two.** Average the *log-odds*. The log-odds of $p=0.2$ is $\log(0.2/0.8) = -\log 4$; of $p = 0.8$ it is $+\log 4$. Their average is $0$, giving $p = 0.5$ again — but only because this example is symmetric. Take $p=0.1$ and $p=0.5$: mixture interpolation gives $0.3$, log-odds interpolation gives $p \approx 0.25$. These are genuinely different notions of "straight".

Both are natural. Mixture straightness is what you want when you think of distributions as objects you can physically blend. Log-odds straightness — *exponential* straightness — is what you want when you think of distributions as members of an exponential family, the shape that maximum-entropy reasoning and sufficient statistics always produce.

Neither is more correct. What is remarkable is that they are the two endpoints of a continuum, and that the continuum is *forced*.

---

## The setup: finite exponential families

Fix a finite set $S$ of outcomes, a strictly positive weight $w(x) > 0$ on each outcome, and a *feature map* $T : S \to \mathbb{R}^d$ assigning to each outcome a vector of $d$ measurements. For a parameter vector $\theta \in \mathbb{R}^d$ — the *natural coordinates* — define

$$p_\theta(x) \;=\; \frac{w(x)\, e^{\langle \theta, T(x)\rangle}}{Z(\theta)}, \qquad Z(\theta) \;=\; \sum_{x \in S} w(x)\, e^{\langle \theta, T(x)\rangle}.$$

This is a finite exponential family. Every discrete model you have met is one: Bernoulli, binomial, categorical, Ising models on a graph, log-linear models in natural language processing, softmax layers in a neural network.

Two objects live on it. The first is the **Fisher information metric**

$$g_{ij}(\theta) \;=\; \mathrm{Cov}_{p_\theta}\big(T_i,\, T_j\big),$$

the covariance matrix of the features. It measures how distinguishable nearby distributions are: a direction in which the features have large variance is a direction in which the model changes fast, so a small parameter step is statistically large. The second is the **Amari–Chentsov cubic tensor**

$$C_{ijk}(\theta) \;=\; \mathbb{E}_{p_\theta}\Big[(T_i - \mathbb{E}T_i)(T_j - \mathbb{E}T_j)(T_k - \mathbb{E}T_k)\Big],$$

the third central moment — the *skewness* of the model. It is totally symmetric in its three indices, which is obvious from the formula but has real geometric weight.

The Fisher metric is famous. The cubic tensor is less so, and the first thing to understand is that it is not an optional extra: **it is the derivative of the Fisher metric.**

---

## The central identity

Here is the fact that makes everything else fall into place.

> **Theorem (Metric derivative law).** For a finite exponential family with strictly positive weights, the Fisher metric is differentiable in the natural coordinates and
> $$\frac{\partial g_{ij}}{\partial \theta^k} \;=\; C_{ijk}.$$

The proof is a chain of three elementary but load-bearing steps, each an "expectation differentiates into a covariance" statement.

*Step one.* For any observable $f : S \to \mathbb{R}$ and any direction $u \in \mathbb{R}^d$,
$$\frac{d}{dt}\bigg|_{t=0} \mathbb{E}_{p_{\theta + tu}}[f] \;=\; \mathrm{Cov}_{p_\theta}\big(f,\, \langle u, T\rangle\big).$$
This is the fundamental identity of exponential families. Differentiating $\mathbb{E}[f] = \tilde{\mathbb{E}}[f]/Z$ (unnormalized expectation over partition function) by the quotient rule produces exactly $\mathbb{E}[f \cdot s_u] - \mathbb{E}[f]\mathbb{E}[s_u]$, where $s_u(x) = \langle u, T(x)\rangle$ is the *directional score*.

*Step two.* Apply step one three times to $\mathrm{Cov}(f,g) = \mathbb{E}[fg] - \mathbb{E}[f]\mathbb{E}[g]$, and collect terms. Everything reorganizes into the third central moment:
$$\frac{d}{dt}\bigg|_{t=0} \mathrm{Cov}_{p_{\theta + tu}}(f, g) \;=\; \kappa_3\big(f, g, s_u\big).$$
The bookkeeping here is the only genuinely fiddly part, and it hinges on the polarization identity expanding a triple centred product into raw moments:
$$\kappa_3(f,g,h) = \mathbb{E}[fgh] - \mathbb{E}[fg]\mathbb{E}[h] - \mathbb{E}[fh]\mathbb{E}[g] - \mathbb{E}[gh]\mathbb{E}[f] + 2\,\mathbb{E}[f]\mathbb{E}[g]\mathbb{E}[h].$$

*Step three.* Take $f = T_i$, $g = T_j$, and $u$ the $k$-th coordinate direction, so that $s_u = T_k$. Done.

The same machinery, applied to the log-partition function $\psi(\theta) = \log Z(\theta)$, reproduces the classical statement that $\psi$ is a *cumulant generating function*: its first directional derivative is the mean of the score, its second is the variance (the Fisher metric), its third is the cubic tensor. The geometry and the cumulants are the same object seen twice.

---

## Where the $\alpha$ comes from

Now we can say what a connection is without ever using the word "manifold". A **connection** is a rule for differentiating vector fields; concretely it is a set of coefficients $\Gamma_{ij,k}$ telling you how the coordinate frame twists as you move. Two connections $\nabla$ and $\nabla^*$ are **dual** with respect to $g$ when they jointly account for the change in the metric:

$$\partial_k\, g_{ij} \;=\; \Gamma_{ki,j} \;+\; \Gamma^*_{kj,i}.$$

This is the Codazzi compatibility equation. It says: if you transport one vector with $\nabla$ and the other with $\nabla^*$, their inner product is preserved. Duality replaces metric-compatibility in information geometry, and it is the reason two geometries — not one — are needed.

The metric derivative law hands us the left-hand side on a plate: it is $C_{ijk}$. So the question "which pairs of connections are dual?" becomes the question "how can I split $C$ into two pieces?" And the canonical answer is a one-parameter split. Define the **canonical $\alpha$-connection** by its lower-index natural-coordinate coefficients

$$\Gamma^{(\alpha)}_{ij,k} \;=\; \frac{1-\alpha}{2}\, C_{ijk}.$$

Then, because $\frac{1-\alpha}{2} + \frac{1+\alpha}{2} = 1$, we get for free:

> **Theorem (Codazzi duality of the $\alpha$-pencil).** For every real $\alpha$,
> $$\partial_k\, g_{ij} \;=\; \Gamma^{(\alpha)}_{ij,k} + \Gamma^{(-\alpha)}_{ij,k}.$$
> That is, $\nabla^{(\alpha)}$ and $\nabla^{(-\alpha)}$ are dual with respect to the Fisher metric, for *every* $\alpha$ simultaneously.

Three members of the pencil stand out.

- **$\alpha = 1$: the exponential connection.** Here $\Gamma^{(1)}_{ij,k} = 0$ identically. The natural coordinates $\theta$ are *affine coordinates*: straight lines in $\theta$-space are geodesics. This is the precise sense in which log-odds interpolation is "straight". The entire derivative of the metric is carried by the dual partner.
- **$\alpha = -1$: the mixture connection.** Here $\Gamma^{(-1)}_{ij,k} = C_{ijk}$ — the whole metric derivative. In the *dual* coordinate system, the expectation coordinates $\eta_i = \mathbb{E}_{p_\theta}[T_i]$, this connection is the one that is flat, and mixture interpolation is straight.
- **$\alpha = 0$: Levi–Civita.** Here $\Gamma^{(0)}_{ij,k} = \tfrac12 C_{ijk}$, exactly the midpoint, and the connection is self-dual — it is the unique metric-compatible torsion-free connection of Riemannian geometry. The $\alpha$-family is a straight segment in the space of connections whose two ends are the statistician's geometries and whose centre is the geometer's.

The situation is sharp, not approximate:

> **Theorem (Sharp flatness criterion).** Fix $\alpha \neq 1$. The natural coefficient $\Gamma^{(\alpha)}_{ij,k}$ vanishes if and only if the corresponding component of the Fisher metric is stationary in the $k$-th direction, i.e. $\partial_k g_{ij} = 0$.

So $\alpha=1$ is flat for *structural* reasons — the coefficient function has a zero there — while every other $\alpha$ is flat only for *statistical* reasons, when the model's skewness happens to vanish.

---

## Why $\frac{1-\alpha}{2}$ and nothing else

At this point a sceptic should object. Any function $F$ with $F(\alpha) + F(-\alpha) = 1$ would give a dual pair. Why the affine one?

Because three modest axioms pin it down completely.

> **Theorem (Rigidity of the canonical family).** Let $F : \mathbb{R} \to \mathbb{R}$ be continuous and satisfy
> 1. *(e-flatness)* $F(1) = 0$;
> 2. *(duality)* $F(\alpha) + F(-\alpha) = 1$ for all $\alpha$;
> 3. *(affine increments)* $F(\alpha + \beta) = F(\alpha) + F(\beta) - F(0)$ for all $\alpha, \beta$.
>
> Then $F(\alpha) = \frac{1-\alpha}{2}$ for every $\alpha$.

The proof is a Cauchy functional equation in disguise. Setting $\alpha = 0$ in axiom (2) gives $2F(0) = 1$, so $F(0) = \tfrac12$: **the Levi–Civita midpoint value is not a convention, it is a theorem.** Now centre the function, $G(\alpha) := F(\alpha) - F(0)$. Axiom (3) says exactly $G(\alpha+\beta) = G(\alpha) + G(\beta)$ — $G$ is additive. A continuous additive function on the reals is linear, $G(\alpha) = \alpha\, G(1)$; and axiom (1) gives $G(1) = 0 - \tfrac12 = -\tfrac12$. Hence $F(\alpha) = \tfrac12 - \tfrac{\alpha}{2} = \frac{1-\alpha}{2}$.

The continuity hypothesis earns its keep. Drop it and additivity alone permits monstrous $\mathbb{Q}$-linear maps built from a Hamel basis of $\mathbb{R}$ over $\mathbb{Q}$ — everywhere discontinuous "connections" satisfying all the algebra and none of the geometry. Regularity is what separates the canonical pencil from a set-theoretic pathology.

And the pencil does not collapse:

> **Theorem (Degeneracy criterion).** For $\alpha \neq \beta$, the connections $\nabla^{(\alpha)}$ and $\nabla^{(\beta)}$ have identical natural coefficients if and only if $C \equiv 0$. Moreover, at any point where some component $C_{ijk} \neq 0$, the only self-dual member — the only $\alpha$ with $\Gamma^{(\alpha)} = \Gamma^{(-\alpha)}$ — is $\alpha = 0$.

The cubic tensor is thus the exact obstruction: **skewness is what makes the geometries differ.** A model with no third-order structure has only one geometry, and all the $\alpha$'s coincide.

---

## Combinatorics enters: three ways to kill the skewness

If skewness is the whole story, when does it vanish? Here the subject turns combinatorial, and three clean mechanisms appear.

### 1. Symmetry, via a sign-reversing involution

Suppose the sample space admits a permutation $\sigma$ that preserves the weights, $w(\sigma x) = w(x)$, and flips every feature, $T(\sigma x) = -T(x)$. (Think of $S = \{-1,+1\}^n$ with the global spin flip.) Then at the origin of natural coordinates, every odd observable has mean zero — pair each $x$ with $\sigma x$ and the contributions cancel — and since $T_iT_jT_k$ is odd, the polarization formula collapses term by term:

> **Theorem (Involution collapse).** If a weight-preserving sign-reversing involution exists, then $C_{ijk}(0) = 0$ for all $i,j,k$, and consequently $\Gamma^{(\alpha)}_{ij,k}(0) = 0$ for *every* $\alpha$: the entire pencil is flat at the symmetric point, and the exponential, mixture and Levi–Civita geometries coincide there.

This is a purely combinatorial hypothesis — a matching of the sample space — producing a differential-geometric conclusion. The smallest instance: the two-point Rademacher family, $S = \{0,1\}$ with $T(0) = -1$, $T(1) = +1$, uniform weights. At the origin one computes directly that the Fisher information is exactly $1$ and the cubic tensor is exactly $0$. Every $\alpha$-connection is flat there.

### 2. Binary features and the skewness law

Contrast this with the asymmetric case. For a feature $f$ taking only the values $0$ and $1$ — equivalently, satisfying $f^2 = f$ — the third cumulant has a closed form:

> **Theorem (Skewness law of a binary feature).** If $f^2 = f$ pointwise and $p = \mathbb{E}_{p_\theta}[f]$, then
> $$\kappa_3(f,f,f) \;=\; p\,(1-p)\,(1-2p).$$

Three factors, three interpretations: $p(1-p)$ is the Fisher information of the Bernoulli feature, and $(1-2p)$ is the *bias*. Consequently, for a non-degenerate feature ($0 < p < 1$),

$$\frac{1-\alpha}{2}\,\kappa_3(f,f,f) = 0 \iff \alpha = 1 \ \ \text{or}\ \ p = \tfrac12.$$

A perfect dichotomy: flatness is either **geometric** (you chose the exponential connection) or **statistical** (your coin is fair). The fair coin is precisely the symmetric point of the previous mechanism, so the two stories meet exactly where they should — and nowhere else. A coin with $p = 0.9$ has genuinely different exponential and mixture geometries; a fair coin does not.

### 3. Independence and block diagonality

Finally, suppose the model factorizes: the sample space is a product $S_1 \times S_2$ and the tilted weights split, $w(z)e^{\langle\theta,T(z)\rangle} = W_1(z_1)W_2(z_2)$. Then expectations of product observables factorize — that is the definition of independence — and the third cumulant of a *mixed* triple collapses:

> **Theorem (Independence annihilates mixed cumulants).** For observables $f, g$ depending only on the first factor and $h$ only on the second, $\kappa_3(f,g,h) = 0$.

Geometrically: **the Amari–Chentsov tensor of a product model is block diagonal**, so the $\alpha$-connections of independent models are the direct sum of the factor connections. Independence in probability is orthogonal decomposition in geometry. This is what makes the whole framework scale to graphical models: the geometry of a large model with sparse dependence structure inherits that sparsity in its cubic tensor.

---

## Why any of this matters

The $\alpha$-family is not decoration. It is the reason a dozen apparently unrelated algorithms are the same algorithm.

**The EM algorithm** alternates between an *e-projection* (onto an exponential-flat submodel) and an *m-projection* (onto a mixture-flat one). Its convergence theory is the Pythagorean theorem for a dually flat pair, which exists precisely because $\nabla^{(1)}$ and $\nabla^{(-1)}$ are Fisher-dual.

**Natural gradient descent** replaces the Euclidean gradient with $g^{-1}\nabla$. That is a first-order statement; the second-order correction to a natural gradient step is governed by the connection you implicitly chose, i.e. by $\frac{1-\alpha}{2}C$. The skewness law says the correction is largest for badly imbalanced features ($p$ near $0$ or $1$) — exactly the regime where practitioners empirically observe optimization pathologies in classification with rare classes.

**Divergences.** Each $\alpha$ corresponds to an $\alpha$-divergence, interpolating from reverse KL at $\alpha = 1$, through the squared Hellinger distance at $\alpha = 0$, to forward KL at $\alpha = -1$. The variational-inference literature's long argument about which direction of KL to minimize is an argument about where to sit in this pencil.

**Model design.** The involution theorem is a design principle: build your parameterization so that the working point is symmetric, and all the geometries agree — no choice of $\alpha$ needs to be made, and second-order corrections vanish. Centring your features is not merely numerical hygiene; it is a move toward a point where the pencil collapses.

---

## The shape of the answer

Step back and look at what the argument actually is.

A finite exponential family carries exactly two natural tensors: the covariance $g$ and the skewness $C$. A one-line calculation shows they are not independent — $C$ is the derivative of $g$. Duality with respect to $g$ then requires splitting $C$ into two parts, and three axioms about how that split should behave force the split to be $\frac{1-\alpha}{2}$ against $\frac{1+\alpha}{2}$. The endpoints of the resulting segment are the exponential and mixture geometries; its midpoint, forced by duality alone, is the Levi–Civita connection of Riemannian geometry. And the segment is a single point exactly when the model has no skewness — which happens for a symmetric sample space, a fair binary feature, or a mixed triple of independent observables.

The whole of information geometry's canonical structure, in other words, is the answer to one question — *how does the metric change?* — asked of one object: the third moment.

That is a satisfying place for a theory to end up. It began with a coin, and the coin turns out to be the whole story: the fair coin is the flat point, the biased coin is the curved one, and the amount of bias, $1-2p$, is literally the coefficient that separates the geometries.
