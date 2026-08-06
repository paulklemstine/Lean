# How Much Can a Machine Learn From Noise?

*A tour of Rademacher complexity — the measurement that explains why learning works, and why counting hypotheses is the wrong way to think about it.*

---

## A test you can fail on purpose

Here is a strange but revealing experiment. Take a data set of $n$ examples. Throw away the labels. Replace them with coin flips: for each example $i$, write down $\sigma_i = +1$ or $\sigma_i = -1$ with equal probability, independently. Now hand this deliberately meaningless data to your learning algorithm and ask it to do its best.

If your model can match those coin flips almost perfectly, something is wrong. It is not detecting structure; it is memorizing. If instead the best it can manage is a weak correlation with the noise, then the model class is *disciplined*: it does not have enough flexibility to chase arbitrary patterns, and when it does fit real data, that fit means something.

This experiment is not just a diagnostic heuristic. It is, essentially exactly, the definition of a quantity called the **empirical Rademacher complexity**, and it turns out to *control* how well a model that fits the training data will do on data it has never seen. That is the subject of this article: a precise account of that quantity, the exact values it takes on some fundamental hypothesis classes, and why it is a strictly sharper instrument than the older idea of counting how many different behaviours a model class can exhibit.

## The definition

Fix a sample $x_1, \dots, x_n$ and a class $\mathcal{F}$ of real-valued functions — think of $f(x)$ as a score, a margin, or a loss. Each $f \in \mathcal{F}$ restricted to the sample is just a vector of $n$ numbers, $(f(x_1), \dots, f(x_n))$. So without loss of generality we can work with a set $F \subseteq \mathbb{R}^n$ of vectors: the class *as seen through the sample*.

The empirical Rademacher complexity of $F$ is

$$\widehat{\mathcal{R}}(F) \;=\; \mathbb{E}_{\sigma}\left[\; \sup_{v \in F} \; \frac{1}{n}\sum_{i=1}^{n} \sigma_i\, v_i \;\right],$$

where $\sigma = (\sigma_1, \dots, \sigma_n)$ is uniform over the $2^n$ sign vectors in $\{-1, +1\}^n$. The expectation is a plain finite average over those $2^n$ patterns. Inside, the supremum asks: *of all the behaviours the class can produce on this sample, which correlates best with the noise?* Outside, the average asks: *and how well does it do on a typical noise pattern?*

Read that formula slowly and the coin-flip experiment is right there. The inner quantity $\frac1n\sum_i \sigma_i v_i$ is exactly the empirical correlation between the model's outputs and the random labels.

A few sanity checks fall out immediately, and they are worth stating because they are the grammar of the subject.

**A single hypothesis has zero complexity.** If $F = \{v\}$ consists of one vector, then $\widehat{\mathcal{R}}(F) = 0$. There is no supremum to exploit, and the average of $\frac1n\sum_i\sigma_i v_i$ over all sign patterns vanishes, because each coordinate's sign is $+1$ exactly as often as it is $-1$. A model with no choices cannot overfit.

**Complexity is monotone.** If $F \subseteq G$, then $\widehat{\mathcal{R}}(F) \le \widehat{\mathcal{R}}(G)$: a bigger menu of behaviours can only correlate better with noise.

**Complexity is nonnegative.** For any nonempty class, $\widehat{\mathcal{R}}(F) \ge 0$. The proof is a small gem: pair each sign pattern $\sigma$ with its negation $-\sigma$. Fix any $v \in F$; then the supremum at $\sigma$ is at least $\frac1n\langle \sigma, v\rangle$ and the supremum at $-\sigma$ is at least $-\frac1n\langle \sigma, v\rangle$. The two lower bounds sum to zero, and since the map $\sigma \mapsto -\sigma$ shuffles the sign patterns among themselves, averaging gives nonnegativity.

**Complexity respects uniform bounds.** If every coordinate of every vector in $F$ satisfies $|v_i| \le B$, then $\widehat{\mathcal{R}}(F) \le B$. You cannot correlate with noise more strongly than the size of your outputs allows.

So the scale is set: complexity lives between $0$ and the magnitude of the predictions. The interesting question is where in that range a given class actually sits — and the answer is usually of order $1/\sqrt n$, which is precisely why learning from finite samples is possible at all.

## Why this number is the right one: symmetrization

The reason to care about noise-fitting is a theorem, and it is the load-bearing beam of the whole theory.

Suppose examples are drawn independently from some distribution, and let $\widehat{\mathbb{E}}_S f = \frac1n\sum_i f(x_i)$ denote the empirical average of $f$ on a sample $S$ and $\mathbb{E}f$ its true average. The thing we actually fear is *uniform* deviation: that **some** hypothesis in our class looks much better on the sample than it really is. Write

$$\mathrm{gap}(S) \;=\; \sup_{f \in \mathcal{F}} \big( \mathbb{E}f - \widehat{\mathbb{E}}_S f \big).$$

**The Symmetrization Theorem.** *The expected gap is at most twice the expected empirical Rademacher complexity:*

$$\mathbb{E}_S\big[\mathrm{gap}(S)\big] \;\le\; 2\,\mathbb{E}_S\big[\widehat{\mathcal{R}}_S(\mathcal{F})\big].$$

The proof is one of the most elegant arguments in all of statistics, and it takes two moves. First, the **ghost sample**: replace the unknown true mean $\mathbb{E}f$ by the empirical mean on a second, independent sample $S'$ of the same size — a sample that exists only in the proof. Because $\widehat{\mathbb{E}}_{S'} f$ is an unbiased estimate of $\mathbb{E}f$, and because the supremum of an average is at most the average of the supremum (Jensen's inequality), we get

$$\mathbb{E}_S\big[\mathrm{gap}(S)\big] \;\le\; \mathbb{E}_{S, S'} \Big[ \sup_f \tfrac1n \textstyle\sum_i \big( f(x_i') - f(x_i) \big) \Big].$$

Second, the **swap**: because $x_i$ and $x_i'$ are independent draws from the same distribution, exchanging them changes nothing about the joint distribution. So for any fixed pattern of signs $\sigma_i \in \{\pm 1\}$, we may insert $\sigma_i$ in front of the difference $f(x_i') - f(x_i)$ without changing the expected value — flipping the sign is the same as swapping the pair, and the swap is measure-preserving. Averaging over all $2^n$ sign patterns and splitting the difference into two halves via the triangle inequality yields exactly $2\,\mathbb{E}_S[\widehat{\mathcal{R}}_S(\mathcal{F})]$.

The consequence is the headline: **to bound how badly your class can be fooled by a finite sample, it suffices to bound how well it fits pure noise.** Generalization is noise-fitting, measured.

## Counting hypotheses: Massart's lemma

The oldest way to control a hypothesis class is to count. If the class produces only $N$ distinct behaviours on the sample, then the supremum in the definition is a maximum over $N$ things, and a maximum of $N$ sub-Gaussian quantities cannot be much larger than $\sqrt{2\log N}$ times their typical scale. Making that precise:

**Massart's Finite Class Lemma.** *If $F \subseteq \mathbb{R}^n$ consists of $N$ vectors, each of Euclidean length at most $r$, then*
$$\widehat{\mathcal{R}}(F) \;\le\; \frac{r\sqrt{2\log N}}{n}.$$

The proof is the classical Chernoff argument, run in four steps. Multiply by a parameter $\lambda > 0$, exponentiate, and use Jensen's inequality to pull the expectation inside: $\exp\big(\lambda\, \mathbb{E}_\sigma \max_v \langle\sigma,v\rangle\big) \le \mathbb{E}_\sigma \exp\big(\lambda \max_v \langle\sigma,v\rangle\big)$. Then bound the maximum of exponentials by the sum, which costs a factor of $N$. Then compute the moment generating function of a Rademacher sum exactly — it factorizes,
$$\mathbb{E}_\sigma \exp\Big(\lambda\sum_i \sigma_i v_i\Big) = \prod_i \cosh(\lambda v_i),$$
and $\cosh t \le e^{t^2/2}$ turns this into $\exp(\lambda^2 r^2/2)$. Taking logarithms leaves $\frac{\log N}{\lambda} + \frac{\lambda r^2}{2}$, and choosing $\lambda = \sqrt{2\log N}/r$ — the value that balances the two terms — gives $r\sqrt{2\log N}$ before normalizing by $n$.

Combined with symmetrization, this delivers a complete, self-contained generalization theorem:

**Generalization for Finite Classes.** *For a class of $N$ functions bounded in absolute value by $B$, the expected uniform deviation between empirical and true means over an i.i.d. sample of size $n$ satisfies*
$$\mathbb{E}_S \Big[\sup_{f} \big(\mathbb{E}f - \widehat{\mathbb{E}}_S f\big)\Big] \;\le\; 2B\sqrt{\frac{2\log N}{n}}.$$

That is the classical picture: *learning is possible because $\log N$ grows slowly.*

### How good is the counting bound?

Remarkably good — one can pin down the constant exactly. Take $F$ to be the **full sign cube**: all $2^n$ vectors in $\{-1,+1\}^n$. Every sign pattern is in the class, so each $\sigma$ finds its perfect match $v = \sigma$, giving correlation $\frac1n\sum_i \sigma_i^2 = 1$. Hence

$$\widehat{\mathcal{R}}\big(\{-1,+1\}^n\big) \;=\; 1 \quad \text{exactly.}$$

What does Massart predict here? The vectors have length $r = \sqrt n$ and there are $N = 2^n$ of them, so the bound reads
$$\frac{\sqrt n \cdot \sqrt{2\log 2^n}}{n} \;=\; \sqrt{2\log 2} \;\approx\; 1.1774.$$
The $n$'s cancel completely. So on the hardest possible class, Massart's lemma is off by the single absolute constant $\sqrt{2\log 2}$, and one can check that
$$1 \;\le\; \sqrt{2\log 2} \;<\; \tfrac{6}{5}.$$
The counting bound overestimates the truth by less than 18%, forever. It is not merely a bound; it is essentially the answer.

## Where counting fails completely

Now the twist. Classical learning theory measures a class by its **VC dimension** $d$ — the size of the largest sample the class can label in every possible way — and converts that into a count via combinatorial growth-function arguments, ultimately producing bounds of the shape $c\sqrt{d/n}$. Everything above suggests that counting is a fine instrument. It is not, and one can say precisely where it breaks.

Consider the **Euclidean ball** $\mathrm{Ball}_n(r) = \{ v \in \mathbb{R}^n : \sum_i v_i^2 \le r^2 \}$ — the class of all behaviour vectors of length at most $r$. Two facts about it stand in stark opposition.

**The complexity of the ball is exactly $r/\sqrt n$.** Not bounded by, not asymptotically — exactly. Both directions are elementary. Upper bound: by Cauchy–Schwarz, $\frac1n\sum_i\sigma_i v_i \le \frac1n \|\sigma\| \|v\| \le \frac{1}{n}\sqrt n\, r = r/\sqrt n$. Lower bound: the vector $v = \frac{r}{\sqrt n}\sigma$ lies in the ball (its length is exactly $r$) and achieves $\frac1n\sum_i \sigma_i \cdot \frac{r}{\sqrt n}\sigma_i = \frac{r}{\sqrt n}$. The supremum is attained, for *every* sign pattern, at the same value — so the average is that value too:
$$\widehat{\mathcal{R}}\big(\mathrm{Ball}_n(r)\big) \;=\; \frac{r}{\sqrt n}.$$

**The ball is an infinite class.** Obviously so: it contains the whole segment $\{(t,0,\dots,0) : 0 \le t \le r\}$, a continuum. Therefore $N = \infty$, every counting-based bound — Massart's lemma, growth functions, Sauer's lemma, VC bounds via covering the behaviours — is *vacuous* for it. It says $\widehat{\mathcal{R}} \le \infty$, which is true and useless.

Here, then, is a class whose complexity is a small, exactly computable number, $r/\sqrt n$, and about which counting says literally nothing. The Rademacher measurement sees a geometric fact — the ball is *small in the right metric* even though it is enormous as a set — that combinatorics is blind to.

And this is not an exotic corner case. It is the *central* case of modern learning.

## The margin bound, and why kernels work

Let the hypothesis class be linear predictors $x \mapsto \langle w, x\rangle$ with $\|w\| \le W$, evaluated on sample points of norm at most $B$, in any real inner product space $E$ whatsoever. Then

**The Margin Bound.** $\displaystyle \widehat{\mathcal{R}} \;\le\; \frac{W B}{\sqrt n}.$

The proof is the classical three-step argument and repays being seen in full. Fix a sign pattern $\sigma$. Since $\frac1n\sum_i \sigma_i \langle w, x_i\rangle = \frac1n \big\langle w, \sum_i \sigma_i x_i \big\rangle$, Cauchy–Schwarz in the *feature space* gives
$$\sup_{\|w\|\le W} \frac1n \sum_i \sigma_i \langle w, x_i\rangle \;\le\; \frac{W}{n}\Big\| \sum_i \sigma_i x_i \Big\|.$$
Now average over $\sigma$. A second application of Cauchy–Schwarz — this time in the $2^n$-dimensional space of sign patterns — replaces the average of the norm by the square root of the average of its square. And that second moment is exactly computable:
$$\mathbb{E}_\sigma \Big\| \sum_i \sigma_i x_i \Big\|^2 = \sum_{i,j} \mathbb{E}_\sigma[\sigma_i\sigma_j]\,\langle x_i, x_j\rangle = \sum_i \|x_i\|^2,$$
because $\mathbb{E}_\sigma[\sigma_i\sigma_j] = 0$ for $i \ne j$ — flipping the single sign $\sigma_i$ is a fixed-point-free involution of the sign patterns that negates every off-diagonal term — while $\sigma_i^2 = 1$ always. With $\|x_i\| \le B$ the second moment is at most $nB^2$, so the average norm is at most $\sqrt n\,B$, and the whole chain collapses to $\frac{W}{n}\cdot \sqrt n B = WB/\sqrt n$.

Notice what does *not* appear anywhere in that argument: the dimension of $E$. The bound is **dimension-free**. It holds in $\mathbb{R}^3$ and it holds in an infinite-dimensional Hilbert space, with the same constant.

That single observation is the theoretical license for **kernel methods**. A kernel method implicitly maps data through a feature map $\varphi$ into a huge — often infinite-dimensional — space, and works with the kernel $K(y,z) = \langle \varphi(y), \varphi(z)\rangle$ without ever writing $\varphi$ down. The margin bound transfers verbatim:

**The Kernel Margin Bound.** *If $K(x,x) \le B^2$ for all sample points, then the class of kernel predictors $y \mapsto \langle w, \varphi(y)\rangle$ with $\|w\| \le W$ has empirical Rademacher complexity at most $WB/\sqrt n$.*

The bound depends on the kernel **only through the diagonal** $\sup_x K(x,x)$. Nothing else about the feature space matters. For a Gaussian kernel, $K(x,x)=1$ identically, so $B=1$: an infinite-dimensional hypothesis class with complexity at most $W/\sqrt n$. A dimension-counting theory cannot even begin to say this.

There is also a clean abstract statement in the background: **any** class contained in a ball of radius $r$ obeys $\widehat{\mathcal{R}} \le r/\sqrt n$, with equality for the ball itself. A bounded-norm linear class does sit inside such a ball — its behaviour vectors have Euclidean length at most $WB\sqrt n$ — but that route alone would only give $WB$, losing a factor of $\sqrt n$. The extra $\sqrt n$ in the margin bound is bought by the second-moment computation: instead of taking the worst case over sign patterns, we average, and the cancellation $\mathbb{E}_\sigma[\sigma_i\sigma_j]=0$ does the rest. Cancellation, not just size, is what makes linear classes learnable.

## The quantitative verdict on dimension

We can now make the comparison numerical rather than rhetorical. Any bound derived from the VC dimension of linear predictors in $\mathbb{R}^d$ — whose VC dimension is $d$ or $d+1$ — necessarily has the shape $c\sqrt{d/n}$ for some absolute constant $c > 0$. The margin bound has the shape $WB/\sqrt n$. Compare:

**Dimension-Dependence Is Eventually Fatal.** *For any constants $W, B, c > 0$ and any sample size $n \ge 1$, as soon as the dimension satisfies*
$$d > \left(\frac{WB}{c}\right)^2,$$
*we have the strict inequality*
$$\frac{WB}{\sqrt n} \;<\; c\sqrt{\frac{d}{n}}.$$

The proof is a one-liner — divide both sides by $1/\sqrt n$ and take square roots — but the content is decisive. **Whatever** constant $c$ a dimension-based analysis manages to achieve, there is a finite dimension threshold beyond which the margin bound is strictly better, and the gap grows like $\sqrt d$ without limit. Push $d \to \infty$, as every kernel method and every wide neural network does, and the dimension-based bound diverges while the margin bound does not move at all.

This is the resolution of a paradox that puzzled practitioners for decades: models with millions or billions of parameters, vastly more than their training sets, that nonetheless generalize. Parameter counting — dimension, VC dimension, degrees of freedom — is simply the wrong yardstick. The right yardstick is the *scale* of the hypothesis class: how far the weights are allowed to roam, how large the data vectors are, how tightly the class is squeezed into a small ball. Regularization, weight decay, margin maximization, and early stopping are all, in this light, doing one thing: keeping $W$ small so that $WB/\sqrt n$ stays small — no matter how many parameters there are.

## What the picture looks like

Assemble the results and a coherent landscape appears.

| Class on a sample of size $n$ | Complexity | Counting bound |
|---|---|---|
| A single hypothesis | $0$ | $0$ (with $N=1$) |
| $N$ vectors of length $\le r$ | $\le r\sqrt{2\log N}/n$ | tight |
| The full sign cube $\{\pm1\}^n$ | exactly $1$ | $\sqrt{2\log 2} \approx 1.177$ |
| Euclidean ball of radius $r$ | exactly $r/\sqrt n$ | vacuous (infinite class) |
| Linear/kernel, $\|w\|\le W$, $\|x\|\le B$ | $\le WB/\sqrt n$ | $c\sqrt{d/n}$, worse for large $d$ |

Two regimes, then. Where the class is genuinely finite and unstructured, counting is close to optimal — the cube shows it cannot be beaten by more than 18%. Where the class is continuous but geometrically constrained — the ball, linear predictors, kernel machines — counting is not merely loose but *infinitely* loose, and the geometric measurement is exact.

Rademacher complexity is what unifies the two regimes. It reduces, via Massart's lemma, to the counting bound when counting is the right thing to do, and it computes exact answers where counting fails. And in every regime it means the same concrete thing: *how well can this model fit random noise?*

## Closing: a number you can actually measure

The final virtue of this theory is not mathematical but practical. Unlike VC dimension — which for most interesting model classes is unknown, or known only to within wide bounds, or provably infinite — Rademacher complexity is an *estimable* quantity. Draw a handful of random sign vectors, fit your model to each, and average the correlations. What you get is a Monte Carlo estimate of $\widehat{\mathcal{R}}$, computed with exactly the training pipeline you were going to run anyway. Symmetrization then converts that number into a bound on how much your test error can exceed your training error, in expectation.

That is a striking state of affairs: a theoretical guarantee about unseen data, obtained by running the same code you already have on data that means nothing at all. The machine's inability to learn from noise is precisely the certificate that it has learned something from the signal.
