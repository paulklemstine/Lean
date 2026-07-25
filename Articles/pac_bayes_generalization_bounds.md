# Learning Guarantees from a Change of Belief

## How PAC–Bayes turns probability distributions over predictors into computable risk certificates

A modern learning system rarely arrives as a single, inevitable formula. Training begins from random initialization, data arrive with noise, optimization follows a path among many alternatives, and small perturbations of the final parameters may produce nearly indistinguishable predictions. Yet the question asked after training is stark: how well will the system perform on data it has never seen?

PAC–Bayes theory answers by changing the object of study. Instead of certifying one isolated predictor, it studies a *distribution* over predictors. A prior distribution $P$ represents beliefs chosen before seeing the sample. A posterior distribution $Q$ represents the data-informed randomized predictor used afterward. The price of moving from $P$ to $Q$ is measured by Kullback–Leibler divergence,

$$
\operatorname{KL}(Q\|P)=\sum_{h}Q(h)\log\frac{Q(h)}{P(h)}
$$

on a finite hypothesis space. The reward is a family of generalization bounds that trade three quantities against one another: empirical performance, confidence, and the information required to select the posterior.

This trade is attractive for neural networks because a posterior can be formed by perturbing trained weights with Gaussian noise. The resulting information cost has an explicit formula. A seemingly abstract theorem about changing probability measures therefore becomes a numerical certificate built from sample size, training error, confidence, dimension, weight norm, and noise scales.

## The variational engine

Let $H$ be a finite, nonempty collection of hypotheses. Suppose $P(h)>0$ and $Q(h)>0$ for every $h\in H$, with both distributions summing to one. For any real-valued score $a(h)$, define

$$
\mathbb E_Q[a]=\sum_{h\in H}Q(h)a(h),
\qquad
Z_P(a)=\sum_{h\in H}P(h)e^{a(h)}.
$$

The central change-of-measure inequality is

$$
\mathbb E_Q[a]\leq \operatorname{KL}(Q\|P)+\log Z_P(a).
$$

This is the finite Donsker–Varadhan inequality, and it is the algebraic heart of PAC–Bayes. It says that a score may look large under the posterior only for one of two reasons: it was already exponentially large on average under the prior, or the posterior paid a large information cost to concentrate on favorable hypotheses.

The proof introduces the exponentially tilted distribution

$$
Q_a(h)=\frac{P(h)e^{a(h)}}{Z_P(a)}.
$$

Because all prior masses are positive, $Z_P(a)>0$, every $Q_a(h)>0$, and the tilted masses sum to one. A direct logarithmic calculation yields the exact identity

$$
\operatorname{KL}(Q\|Q_a)
=
\operatorname{KL}(Q\|P)-\mathbb E_Q[a]+\log Z_P(a).
$$

Kullback–Leibler divergence is nonnegative, so rearranging proves the inequality. Moreover, choosing $Q=Q_a$ makes the left side zero. Thus the Gibbs tilt does not merely approximate the best posterior: it attains equality in the variational principle,

$$
\mathbb E_{Q_a}[a]-\operatorname{KL}(Q_a\|P)=\log Z_P(a).
$$

This exactness explains why Gibbs distributions appear throughout statistical mechanics, Bayesian inference, and learning theory. Exponential weighting is the optimizer forced by the geometry of relative entropy.

## From exponential moments to risk

For each hypothesis $h$, let $\widehat R(h)$ be empirical risk and $R(h)$ be true risk. Choose a positive scale $\eta>0$ and a confidence parameter $\delta>0$. Suppose a probabilistic argument has established the exponential-moment certificate

$$
\sum_{h\in H}P(h)
\exp\!\left(\eta\bigl(R(h)-\widehat R(h)\bigr)\right)
\leq \frac{1}{\delta}.
$$

Apply the change-of-measure inequality to the score

$$
a(h)=\eta\bigl(R(h)-\widehat R(h)\bigr).
$$

Monotonicity of the logarithm gives a posterior-uniform risk theorem:

$$
\mathbb E_Q[R]
\leq
\mathbb E_Q[\widehat R]
+
\frac{\operatorname{KL}(Q\|P)+\log(1/\delta)}{\eta}.
$$

The phrase “posterior-uniform” is crucial. Once the moment event holds, the conclusion applies to every strictly positive posterior $Q$ at once. The posterior may therefore be selected after examining the data without invalidating the algebraic step. What remains problem-specific is proving that the moment event itself occurs with the desired sampling probability.

## Two faces of the certificate

Two widely used scalar forms summarize the tradeoff. The McAllester expression is

$$
B_M(\widehat r,k,n,\delta)
=
\widehat r+
\sqrt{
\frac{k+\log(2\sqrt n/\delta)}{2(n-1)}
}.
$$

Here $\widehat r$ is posterior-averaged empirical risk, $k$ is a KL complexity, $n>1$ is sample size, and $\delta$ is a confidence parameter. Its gap above empirical risk is exactly the displayed square-root term, which is always nonnegative. For fixed valid $n$ and $\delta$, the bound is monotone in $k$: a posterior farther from its prior receives a weaker certificate. The square root also obeys the familiar subadditivity rule $\sqrt{x+y}\leq\sqrt x+\sqrt y$ for $x,y\geq0$, allowing separate complexity contributions to be budgeted conservatively.

Catoni’s expression uses an inverse-temperature parameter $\lambda>0$:

$$
B_C(\widehat r,k,n,\delta,\lambda)
=
\frac{1-
\exp\!\left(-\lambda\widehat r-rac{k+\log(1/\delta)}{n}\right)}
{1-e^{-\lambda}}.
$$

Its denominator is positive because $e^{-\lambda}<1$. The expression is monotone in both empirical risk and KL complexity, and it satisfies

$$
B_C(\widehat r,k,n,\delta,\lambda)
\leq \frac{1}{1-e^{-\lambda}}.
$$

Unlike the McAllester formula, the Catoni expression is not automatically above empirical risk for arbitrary scalar inputs. It becomes a risk guarantee when the corresponding Catoni exponential-moment argument has supplied the premise $R(Q)\leq B_C$. This distinction matters: a formula is not a theorem about data until its probabilistic hypothesis has been justified.

Temperature gives Catoni’s bound a physical flavor. Small and large values of $\lambda$ balance fit and information differently. Optimizing $\lambda$ can sharpen a certificate, much as temperature controls concentration in a Gibbs ensemble.

## Gaussian clouds around neural networks

Consider a parameter vector $w\in\mathbb R^d$. Take a spherical Gaussian prior $P=\mathcal N(0,\sigma_p^2I)$ and a spherical Gaussian posterior $Q=\mathcal N(w,\sigma_q^2I)$, where $\sigma_p>0$ and $\sigma_q>0$. Their KL divergence is

$$
\operatorname{KL}(Q\|P)
=
\frac{\lVert w\rVert^2}{2\sigma_p^2}
+
\frac d2\left(
\frac{\sigma_q^2}{\sigma_p^2}-1-
\log\frac{\sigma_q^2}{\sigma_p^2}
\right).
$$

The formula separates two costs. The first is the energy of shifting the mean away from the origin. The second is the cost of changing the variance. It is nonnegative because

$$
x-1-\log x\geq0\qquad(x>0).
$$

Consequently the entire Gaussian KL divergence is nonnegative. It increases when $\lVert w\rVert^2$ increases while the noise scales remain fixed. If posterior and prior use the same variance, $\sigma_q=\sigma_p=\sigma$, the mismatch term disappears and

$$
\operatorname{KL}(Q\|P)=\frac{\lVert w\rVert^2}{2\sigma^2}.
$$

At $w=0$ this cost is zero: the posterior is exactly the prior.

Substituting the Gaussian formula into the McAllester expression produces a completely explicit numerical penalty. This is the bridge to neural networks: flatten all trainable parameters into $w$, choose Gaussian perturbation scales, estimate the empirical loss averaged over perturbations, and compute the information term. The resulting certificate rewards networks that are accurate throughout a broad neighborhood and that do not move too far, in information-geometric terms, from the prior.

## What happens with more data?

If a complexity constant $C\geq0$ stays fixed, then

$$
\sqrt{\frac{C}{n+1}}\longrightarrow0
\qquad\text{as }n\to\infty.
$$

For the Gaussian McAllester numerator, even the confidence contribution grows only logarithmically. With fixed $d$, $w$, $\sigma_p$, $\sigma_q$, and $\delta>0$,

$$
\frac{
\operatorname{KL}(Q\|P)+\log(2\sqrt n/\delta)
}{2(n-1)}
\longrightarrow0.
$$

Thus the associated square-root penalty vanishes. In the equal-variance case, if $\lVert w\rVert^2\leq C$, then for every $n>1$,

$$
\frac{\lVert w\rVert^2}{2\sigma^2n}
\leq
\frac{C}{2\sigma^2n},
$$

revealing an explicit $1/n$ rate for the unrooted shift complexity.

This is a consistency ingredient, not a proof of asymptotic tightness for linear classifiers. Tightness would require a specified data model and a matching lower bound. What has been established is the upper-bound mechanism and the disappearance of its complexity penalty under fixed parameters.

## A small thought experiment

Imagine a shelf holding three predictors. Before seeing data, the prior assigns them probabilities $1/2$, $3/10$, and $1/5$. After training, suppose the posterior favors the third. That shift may improve empirical performance, but it cannot be treated as free: the logarithmic ratio $\log(Q(h)/P(h))$ records how surprising each posterior choice was under the prior, and the posterior average of those ratios is the KL cost.

Now assign every predictor a score measuring its true-risk advantage over empirical risk, scaled by $\eta$. The partition function does not simply average those scores. It averages their exponentials, making unusually large gaps disproportionately visible. If this exponential average is at most $1/\delta$, then no posterior can simultaneously place substantial mass on large gaps and remain information-theoretically close to the prior. The moment-to-risk theorem makes that intuition exact.

This example also clarifies why the prior must be chosen with care. A prior that secretly anticipates the observed sample can place mass exactly where the posterior will later concentrate, making the KL cost artificially small. In a complete statistical analysis, the prior is fixed independently of the sample, or its data dependence is explicitly accounted for. The variational inequality itself is algebraically valid for any positive distributions; the statistical interpretation depends on how they were chosen.

For a neural network, the shelf becomes a continuous cloud of nearby parameter vectors. Gaussian noise samples that cloud. A broad region of low empirical loss means many perturbations still perform well, while the Gaussian KL formula charges for both moving the cloud's center and changing its width. Dimension amplifies width mismatch: the factor $d/2$ means that a modest per-coordinate discrepancy can become expensive when millions of parameters move together. This is one reason equal-variance priors and posteriors are mathematically appealing, even though empirical optimization may favor a different perturbation scale.

The numerical workflow is therefore straightforward in outline. Choose a prior without illicit access to the sample. Train a center $w$. Select a posterior noise scale, estimate the posterior-averaged empirical loss, compute the Gaussian KL cost, and insert both into a scalar formula. Repeat only with confidence accounting if hyperparameters are selected from the same data. The final number is meaningful as a risk guarantee precisely when the required high-probability moment premise has also been established.

## A practical reading of the theory

A PAC–Bayes certificate can be viewed as a disciplined negotiation. Empirical risk asks for a posterior concentrated near predictors that fit the sample. KL divergence penalizes excessive departure from the prior. Confidence charges for demanding a rarer failure event. Sample size dilutes these costs. The Gibbs posterior is the exact mediator of this negotiation.

That perspective reaches beyond any single model class. Whenever one can control a prior-weighted exponential moment, the same variational engine converts it into a statement uniform over posteriors. Gaussian perturbations make the engine computable for high-dimensional parameter vectors, but the principle is broader: generalization is paid for in information, and exponential tilting keeps the accounting exact.
