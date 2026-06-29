# The Shape of Knowledge: How Geometry Measures What We Can Learn

Imagine you are trying to weigh a feather using a bathroom scale. No matter how
carefully you read the dial, the answer wobbles. Now imagine weighing the same
feather on a laboratory balance sensitive to micrograms. Same feather, same laws of
physics — but one instrument *tells you far more*. What separates the two is not luck
or skill. It is a precise, quantifiable thing: the amount of **information** the
instrument extracts from each measurement.

For more than a century, statisticians have known how to put a number on this. The
number is called **Fisher information**, and it answers a deceptively simple
question: *if I nudge the hidden parameter I am trying to estimate, how much does the
data I expect to see change?* A measurement that barely reacts to the parameter
carries little information; a measurement that swings wildly carries a lot.

What is surprising — and what this article is about — is that Fisher information is
not just a number. It is a **geometry**. The space of all possible probability
distributions has a natural notion of distance, curvature, and angle, and that
geometry is *exactly* the Fisher information. To learn statistics is, quite
literally, to do geometry on a curved surface whose shape encodes how hard each
question is to answer. This idea, known as **information geometry**, ties together
three subjects that look completely unrelated at first glance: probability theory,
Riemannian geometry (the mathematics of curved spaces that underlies Einstein's
relativity), and the practical limits of statistical estimation.

In what follows we build this bridge from the ground up, stating every result
precisely, and arrive at a chain of theorems that culminates in one of the most
beautiful facts in all of statistics: there is a hard, unbreakable floor on how
accurately *any* method can estimate a parameter, and that floor is the inverse of
the Fisher information. You cannot beat it with cleverness. It is geometry.

## A manifold made of guesses

Let us be concrete. Suppose an experiment can produce one of finitely many outcomes
— call them outcomes \(1, 2, \dots, n\). A **statistical model** is a recipe that, for
each setting of some hidden parameters \(\theta = (\theta_1, \dots, \theta_d)\), tells
you the probability \(p(x; \theta)\) of each outcome \(x\). As you turn the knobs
\(\theta\), the probabilities shift. The collection of all these probability
distributions, one for each value of \(\theta\), forms a *surface* — a manifold — and
the parameters \(\theta\) are coordinates on it.

The single most important quantity attached to a model is the **score**: the rate at
which the log-probability of an outcome changes as you nudge a parameter,
\[
  s_i(x;\theta) \;=\; \frac{\partial}{\partial \theta_i}\,\log p(x;\theta).
\]
The score is the model's "sensitivity dial." If outcome \(x\) becomes much more or
much less likely when you tweak \(\theta_i\), then \(s_i(x;\theta)\) is large; if \(x\)
is indifferent to \(\theta_i\), the score is near zero.

There is one fact about the score that does all the heavy lifting later: **its
average is always zero**. In symbols,
\[
  \sum_x p(x;\theta)\, s_i(x;\theta) \;=\; 0.
\]
This is not an accident of a particular model — it follows from the iron law that
probabilities sum to one. If the total probability is fixed at 1, then whatever
probability you add to some outcomes when nudging \(\theta\), you must subtract from
others, and on average it cancels. This "mean-zero score" property is the silent
engine behind nearly every theorem below.

## Fisher information as a metric

Now we can define the star of the show. The **Fisher information matrix** is the
expected outer product of the score with itself:
\[
  G_{ij}(\theta) \;=\; \sum_x p(x;\theta)\, s_i(x;\theta)\, s_j(x;\theta).
\]
It is a \(d \times d\) matrix, one entry for each pair of parameters. Intuitively
\(G_{ij}\) measures how much information the data carries about parameters \(i\) and
\(j\) jointly — and how those informations are correlated.

The claim of information geometry is that this matrix \(G(\theta)\) is a **Riemannian
metric**: a way of measuring lengths and angles of tangent vectors at each point of
the manifold of distributions. To deserve that name, \(G\) must satisfy three
axioms, and each one is a genuine theorem about the formula above.

**It is symmetric.** \(G_{ij} = G_{ji}\), because the product \(s_i s_j\) does not
care about the order of its factors. A metric must treat the two directions
symmetrically, and Fisher information does.

**It is positive semidefinite.** For *any* direction \(v = (v_1, \dots, v_d)\), the
quadratic form
\[
  \sum_{i,j} v_i\, G_{ij}\, v_j \;=\; \sum_x p(x;\theta)\Big(\sum_i v_i\, s_i(x;\theta)\Big)^2 \;\ge\; 0.
\]
The middle step is the crucial collapse: the apparently complicated double sum over
parameter pairs reorganizes into a *single* sum of squares, weighted by
probabilities. Squares are never negative and probabilities are positive, so the
whole thing is nonnegative. Geometrically, this says lengths are never negative —
the bare minimum any sensible notion of distance must obey.

**It is positive definite when the model is identifiable.** If no nonzero direction
\(v\) is invisible to every outcome's score — a condition we call *score
nondegeneracy*, and which simply means the model genuinely depends on all its
parameters near \(\theta\) — then the quadratic form is *strictly* positive for every
nonzero \(v\). The proof is a clean argument by contradiction: if the form were zero,
then because every probability \(p(x;\theta)\) is strictly positive, each weighted
score \(\sum_i v_i s_i(x;\theta)\) would have to vanish, and nondegeneracy then forces
\(v = 0\). So a well-posed model has a genuine, non-degenerate geometry: every
direction has positive length.

These three theorems together are the precise statement that **the Fisher
information matrix is a Riemannian metric tensor** on the statistical manifold. The
abstract notion of "distance between nearby probability distributions" has been made
rigorous.

## Two faces of information, and the curvature of surprise

Fisher information wears two masks, and they are secretly the same face.

The first mask is the one we have seen: \(G\) is the **covariance of the score**.
Because the score has mean zero, its covariance \(\mathbb{E}[s_i s_j] -
\mathbb{E}[s_i]\mathbb{E}[s_j]\) reduces to just \(\mathbb{E}[s_i s_j]\), which is the
definition of \(G_{ij}\). Information is the spread of the sensitivity dial.

The second mask is curvature. Define the **Kullback–Leibler divergence** between two
distributions \(p\) and \(q\),
\[
  \mathrm{KL}(p \,\|\, q) \;=\; \sum_x p(x)\,\log\frac{p(x)}{q(x)}.
\]
This is the standard measure of how different two distributions are — how surprised
you would be, on average, to keep using model \(q\) when reality is \(p\). It has two
defining virtues, both of which are theorems. First, \(\mathrm{KL}(p\,\|\,p) = 0\): a
distribution is never surprised by itself. Second, **Gibbs' inequality**,
\(\mathrm{KL}(p\,\|\,q) \ge 0\): you are always at least a little surprised by the
wrong model. The proof of nonnegativity is a small marvel of economy. It uses the
single elementary inequality \(\log t \le t - 1\), applied to \(t = q(x)/p(x)\):
\[
  -\mathrm{KL}(p\,\|\,q) = \sum_x p(x)\log\frac{q(x)}{p(x)} \le \sum_x p(x)\Big(\frac{q(x)}{p(x)} - 1\Big) = \sum_x q(x) - \sum_x p(x) = 1 - 1 = 0.
\]
The normalization — that both distributions sum to 1 — is what makes the right-hand
side collapse to zero.

Now the punchline. Because \(\mathrm{KL}(p\,\|\,p) = 0\) is the *minimum* of the
divergence, the surface \(\theta' \mapsto \mathrm{KL}(p_\theta \,\|\, p_{\theta'})\) has
a valley floor at \(\theta' = \theta\), with zero slope. Its **curvature** there — the
matrix of second derivatives, the Hessian — is exactly the Fisher information. We
capture this with the identity
\[
  G_{ij}(\theta) \;=\; -\,\mathbb{E}_\theta\!\big[\partial_i\partial_j \log p\big],
\]
the famous "two forms of Fisher information." It says the average curvature of the
log-likelihood *is* the Fisher metric. So the Fisher metric is, almost literally, the
**curvature of surprise**: the steeper the valley of divergence around the truth, the
more sharply the data distinguishes nearby parameters, the more information you have.

For readers who like a concrete number: the humble **Bernoulli model** — a single
coin with success probability \(\sigma(\theta)\) — has Fisher information
\[
  G(\theta) \;=\; \frac{\sigma'(\theta)^2}{\sigma(\theta)\,(1-\sigma(\theta))}.
\]
The factor \(\sigma(1-\sigma)\) in the denominator is the variance of the coin flip;
information is largest when the coin is most predictable (near \(\sigma = 0\) or
\(\sigma = 1\)) and the parameter moves the odds quickly. This closed form falls out
of the general definition in two lines of computation.

## Information adds up

Here is a fact every experimenter relies on, perhaps without knowing its name. If you
collect two **independent** observations from the same model, your total information
*doubles*. More generally, if you combine two independent experiments \(M\) and \(N\)
that share the same parameter \(\theta\), the Fisher information of the combined
experiment is the *sum*:
\[
  G_{M \times N}(\theta) \;=\; G_M(\theta) + G_N(\theta).
\]
This **tensorization** (or additivity) theorem is why gathering more data helps in a
predictable way, and it is the statistical bedrock of consistency — the guarantee
that estimates converge to the truth as data accumulates. The proof is a satisfying
piece of bookkeeping: when you write out the squared score of the joint experiment,
it expands into four terms; the two "diagonal" terms reproduce \(G_M\) and \(G_N\)
(using that probabilities sum to one in the other factor), and the two "cross" terms
factor into products of *mean-zero scores* and therefore vanish. The mean-zero score
property, once again, does the work. The special case \(N = M\) gives the clean
statement that \(k=2\) i.i.d. observations carry exactly twice the information.

## A metric is a tensor

There is one more axiom hiding in the phrase "Riemannian metric." A true metric must
not depend on the coordinates you happen to use. If you reparametrize the manifold —
switching from coordinates \(\theta\) to new coordinates \(\eta\) related by a Jacobian
matrix \(J\) — the metric must transform by the **congruence law**
\[
  G'(\eta) \;=\; J^{\mathsf T}\, G(\theta)\, J.
\]
This is precisely the transformation rule of a \((0,2)\)-tensor, the mathematical
object that geometers mean by "metric." We prove it directly: under reparametrization
the score transforms by the chain rule, \(s'_a = \sum_i J_{ai}\, s_i\), and
substituting this into the definition of \(G'\) and pulling the constant Jacobian
entries out of the expectation yields the congruence. The upshot is that the Fisher
metric is not an artifact of a coordinate choice — it is intrinsic to the geometry of
the model itself.

## The unbreakable floor: Cramér and Rao

Everything so far has built the geometry. Now we cash it in for the single most
consequential inequality in estimation theory.

Suppose you want to estimate some quantity from your data using a **statistic** \(T\)
— any function of the observed outcome. Let \(\psi(\theta) = \mathbb{E}_\theta[T]\) be
its average value, and suppose this average tracks the parameter smoothly, with
derivative \(\psi'(\theta)\). The **Cramér–Rao bound** says the variance of \(T\) —
how much it jitters from sample to sample — can never be smaller than
\[
  \mathrm{Var}_\theta(T) \;\ge\; \frac{\psi'(\theta)^2}{G(\theta)}.
\]
Stated without dividing, our theorem reads \(\psi'(\theta)^2 \le \mathrm{Var}_\theta(T)
\cdot G(\theta)\). For an **unbiased estimator** of the parameter itself — one whose
average is exactly \(\theta\), so \(\psi' = 1\) — this becomes the iconic
\[
  \mathrm{Var}_\theta(T) \;\ge\; \frac{1}{G(\theta)}.
\]
The variance of any honest estimator is at least the **inverse Fisher information**.
More information, lower achievable variance; less information, and no estimator on
Earth can pin the parameter down tightly. This is the precise, quantitative sense in
which the Fisher metric *measures what is learnable*.

The proof is a single application of the **Cauchy–Schwarz inequality**, the same
inequality that says the dot product of two vectors is at most the product of their
lengths — applied here to the inner product weighted by the probabilities, the very
inner product whose Gram matrix is the Fisher information. The two "vectors" are the
centered statistic \(T - \mathbb{E}[T]\) and the score \(s\). Their inner product is
exactly \(\psi'\) (again because the score has mean zero), their squared lengths are
the variance and the Fisher information, and Cauchy–Schwarz delivers the bound. The
geometry was the inequality all along.

## When the floor is reached

A lower bound is most illuminating when you know exactly when it is *tight*. Our final
theorem characterizes **efficiency** — equality in Cramér–Rao. The bound is achieved,
\[
  \psi'(\theta)^2 = \mathrm{Var}_\theta(T)\cdot G(\theta),
\]
**if and only if** the centered statistic is *proportional to the score*: there is a
constant \(c\) with
\[
  T(x) - \mathbb{E}_\theta[T] \;=\; c\, s(x;\theta) \quad \text{for every outcome } x.
\]
This is the equality case of Cauchy–Schwarz — two vectors saturate the inequality
exactly when they are parallel. Statistically, it singles out a special and famous
class of models: the **one-parameter exponential families**, for which \(T\) is the
"natural" sufficient statistic and is an *efficient* estimator that meets the
information floor with no waste. When your statistic points in the same direction as
the score, you have squeezed every drop of information out of the data; otherwise,
you have left some on the table.

## A sandwich for divergence

The geometry also yields sharp *global* control of the KL divergence, not just its
infinitesimal curvature. For the categorical model — distributions \(p, q\) on a
finite set with positive entries summing to one — the Fisher quadratic form at the
displacement \(p - q\) is
\[
  g_q(p-q,\,p-q) \;=\; \sum_i \frac{(p_i - q_i)^2}{q_i},
\]
which is exactly the **Pearson \(\chi^2\)-divergence**. We prove the two-sided sandwich
\[
  \tfrac{1}{2}\Big(\sum_i |p_i - q_i|\Big)^2 \;\le\; \mathrm{KL}(p\,\|\,q) \;\le\; \sum_i \frac{(p_i-q_i)^2}{q_i}.
\]
The right-hand inequality realizes the slogan "Fisher metric = Hessian of KL" not as
an infinitesimal statement but as an honest global bound: KL is controlled from above
by the Fisher (\(\chi^2\)) quadratic form. The left-hand inequality is the celebrated
**Pinsker inequality**, bounding KL below by the squared total-variation distance —
the simplest, most robust measure of how far apart two distributions are. Together
they pin the divergence between the \(L^1\) world and the Fisher world, two faithful
companions hugging it from both sides.

## Why it matters

It would be easy to file all this under "elegant but abstract." It is anything but.
The Cramér–Rao bound tells engineers the smallest error a GPS receiver, a gravitational-wave
detector, or a particle physics experiment can possibly achieve, *before a single
instrument is built*. The additivity of Fisher information tells a clinical
trialist how many patients are needed for a drug study. The Fisher metric is the
natural geometry behind the optimization algorithms (natural gradient descent) that
train modern machine-learning models, because moving "the same distance" in parameter
space should mean moving the same distance in the space of *behaviors*, and that is
exactly what the Fisher metric measures. The reparametrization-invariance we proved is
why these methods do not depend on arbitrary modeling choices.

But beyond the applications there is the sheer pleasure of the bridge itself. A
statistician asking "how well can I estimate this?" and a geometer asking "how curved
is this surface?" turn out to be asking the *same question*, in different languages.
The dictionary between them is the Fisher information — symmetric, positive, additive,
tensorial, the curvature of surprise and the floor of knowledge, all at once. To
measure information is to measure shape. That two such different intuitions converge
on one matrix is, to this writer, as close to magic as rigorous mathematics gets.
