# Can Your Model Learn From Noise?

### A guided tour of Rademacher complexity, generalization, and why counting hypotheses is the wrong idea

---

## 0. The one-sentence version

> **A model class is safe exactly to the extent that it *cannot* fit random labels.**

Everything on this page is an elaboration of that sentence: how to turn it into a number, how to
compute that number exactly for the classes that matter, and why it beats the classical
"count the hypotheses" approach so decisively that the classical approach sometimes says nothing
at all.

No background beyond linear algebra and the phrase "expected value" is assumed. Dense material is
tucked behind expandable panels — open them if you want the full argument, skip them if you want
the story.

---

## 1. The experiment that defines everything

Take your training set of $n$ examples. **Throw away the labels.** Replace them with independent
coin flips $\sigma_1,\dots,\sigma_n \in \{-1,+1\}$. Now ask your model class to fit *those*.

If it can, your model is a memorizer. If it can't, and it still fits the real data, that fit means
something.

The **empirical Rademacher complexity** turns this into a number. Write $F \subseteq \mathbb{R}^n$
for the class as seen through the sample — each hypothesis $f$ contributes its vector of outputs
$(f(x_1),\dots,f(x_n))$. Then

$$\widehat{\mathcal{R}}(F) \;=\; \underbrace{\mathbb{E}_{\sigma}}_{\text{over all } 2^n \text{ coin-flip patterns}}\ \Big[\ \underbrace{\sup_{v\in F}}_{\text{the best the class can do}}\ \underbrace{\tfrac1n\textstyle\sum_i \sigma_i v_i}_{\text{correlation with the noise}}\ \Big].$$

Play with the definition directly. Below, the class is "all linear predictors with weight norm at
most $W$", the sample points are draggable, and the exact value — computed by enumerating *every
single one* of the $2^n$ sign patterns, no sampling — is shown next to the theoretical bounds.

{{interactive_demo:0}}

**Things worth discovering in the widget:**

- Slide $n$ upward. Capacity falls like $1/\sqrt n$. More data, less room to chase noise.
- Slide $W$ upward. Capacity grows *linearly*. This is what regularization buys you, quantitatively.
- Drag all the points into a tight cluster. The signed sums stop cancelling and the exact value
  climbs to meet the bound. Spread them out symmetrically and it plunges. **Cancellation is the
  mechanism.**

<details>
<summary><b>The four elementary facts that set the scale</b> (click to expand)</summary>

These follow from one observation: the map $\sigma \mapsto -\sigma$ shuffles the $2^n$ sign
patterns among themselves.

1. **A single hypothesis has complexity exactly $0$.** With $F=\{v\}$ there is no supremum to
   exploit, and averaging $\frac1n\sum_i \sigma_i v_i$ over all patterns gives zero because each
   coordinate is $+1$ as often as $-1$. *A class with no choices cannot overfit.*
2. **Monotonicity.** $F \subseteq G \Rightarrow \widehat{\mathcal{R}}(F) \le \widehat{\mathcal{R}}(G)$.
   A bigger menu correlates at least as well.
3. **Nonnegativity.** For nonempty $F$, $\widehat{\mathcal{R}}(F)\ge0$. Fix any $v\in F$: at $\sigma$
   the supremum is at least $\frac1n\langle\sigma,v\rangle$, at $-\sigma$ it is at least
   $-\frac1n\langle\sigma,v\rangle$, and the two lower bounds sum to zero.
4. **Uniform bound.** If $|v_i|\le B$ for all $v\in F$ and all $i$, then
   $\widehat{\mathcal{R}}(F)\le B$. You cannot correlate harder than your outputs allow.

So capacity lives in $[0, B]$, and the whole game is finding where in that interval a class sits.

</details>

---

## 2. Why the number matters: symmetrization

The definition would be a curiosity if it didn't *control* something. It does, and this is the
load-bearing theorem of the subject.

> **Symmetrization Theorem.** Let $\mathrm{gap}(S) = \sup_{f}\big(\mathbb{E}f - \widehat{\mathbb{E}}_S f\big)$
> be the worst overestimate of quality that the sample $S$ can produce, over the whole class. Then
> $$\mathbb{E}_S\big[\mathrm{gap}(S)\big] \;\le\; 2\,\mathbb{E}_S\big[\widehat{\mathcal{R}}_S(\mathcal{F})\big].$$

In words: **the expected amount by which a finite sample can fool you is at most twice the
expected ability of your class to fit noise.**

<details>
<summary><b>The proof — two beautiful moves</b> (click to reveal)</summary>

**Move 1: the ghost sample.** The true mean $\mathbb{E}f$ is unknown, so replace it by the
empirical mean on a second, imaginary sample $S'$ drawn independently from the same distribution.
Since $\widehat{\mathbb{E}}_{S'}f$ is unbiased for $\mathbb{E}f$, and since the supremum of an
average is at most the average of the suprema (Jensen's inequality applied to $\max$),

$$\mathbb{E}_S[\mathrm{gap}(S)] \;\le\; \mathbb{E}_{S,S'}\Big[\sup_f \tfrac1n\textstyle\sum_i\big(f(x_i') - f(x_i)\big)\Big].$$

**Move 2: the swap.** Because $x_i$ and $x_i'$ are i.i.d., exchanging them changes nothing about
the joint distribution. Exchanging the $i$-th pair is *the same operation* as flipping the sign of
the $i$-th difference $f(x_i')-f(x_i)$. So for **every** sign pattern $\sigma$ we may insert
$\sigma_i$ in front of the $i$-th difference for free. Average over all $2^n$ patterns, split the
difference with $\max(a+b)\le\max a + \max b$, and each half is exactly an empirical Rademacher
complexity. Total: $2\,\mathbb{E}_S[\widehat{\mathcal{R}}_S]$. $\blacksquare$

The factor $2$ is the price of the split; the rate is untouched.

</details>

The consequence is the whole reason to care: **any bound on noise-fitting is a generalization
guarantee.** So: how do we bound noise-fitting?

---

## 3. Route one — counting. It's better than you'd think.

The oldest instinct is to count. If the class produces only $N$ distinct behaviours on the sample,
the supremum is a maximum over $N$ things, and a maximum of $N$ sub-Gaussian quantities is not
much bigger than $\sqrt{2\log N}$ times their scale.

> **Massart's Finite Class Lemma.** If $F$ consists of $N$ vectors, each of Euclidean length at
> most $r$, then
> $$\widehat{\mathcal{R}}(F) \;\le\; \frac{r\sqrt{2\log N}}{n}.$$

<details>
<summary><b>The Chernoff argument in four steps</b> (click to reveal)</summary>

Fix $\lambda > 0$ and write $M(\sigma) = \max_{v}\sum_i \sigma_i v_i$.

1. **Jensen.** $\exp\big(\lambda\,\mathbb{E}_\sigma M(\sigma)\big) \le \mathbb{E}_\sigma e^{\lambda M(\sigma)}$.
2. **Max $\le$ sum.** $e^{\lambda M(\sigma)} = \max_v e^{\lambda\langle\sigma,v\rangle} \le \sum_{v\in F} e^{\lambda\langle\sigma,v\rangle}$ — this is where the factor $N$ enters.
3. **Exact MGF.** Independence across coordinates factorizes the moment generating function:
   $$\mathbb{E}_\sigma \exp\Big(\lambda\sum_i \sigma_i v_i\Big) = \prod_i \cosh(\lambda v_i) \le \prod_i e^{\lambda^2 v_i^2/2} \le e^{\lambda^2 r^2/2},$$
   using $\cosh t \le e^{t^2/2}$ (compare Taylor coefficients: $\tfrac{1}{(2k)!}\le\tfrac{1}{2^kk!}$).
4. **Optimize.** Taking logs leaves $\frac{\log N}{\lambda} + \frac{\lambda r^2}{2}$; the balancing
   choice $\lambda = \sqrt{2\log N}/r$ yields $r\sqrt{2\log N}$. Divide by $n$.

</details>

### How good is it? Exactly this good.

Take the **hardest class imaginable**: the full sign cube $\{-1,+1\}^n$, every possible labelling
of the sample. Every $\sigma$ finds its perfect match $v = \sigma$, so
$\widehat{\mathcal{R}}(\{-1,+1\}^n) = 1$ **exactly**. And Massart, with $N=2^n$ and $r=\sqrt n$,
predicts

$$\frac{\sqrt n\,\sqrt{2\log 2^n}}{n} \;=\; \sqrt{2\log 2} \;\approx\; 1.1774,$$

for *every* $n$ — the $n$'s cancel completely. One can pin the constant precisely:
$1 \le \sqrt{2\log2} < \tfrac65$. **Counting overestimates the truth by under 18%, forever.**

So counting is not a crude tool. On unstructured classes it is essentially the right answer.

{{algorithm:0}}

Run the enumeration above on the cube for $n=1,\dots,10$ and you will get $1.000000000000$ every
time — no sampling, no approximation, just the definition.

---

## 4. Route two — geometry. And the moment counting dies.

Now the twist. Consider the **Euclidean ball** $\mathrm{Ball}_n(r) = \{v : \sum_i v_i^2 \le r^2\}$:
all behaviour vectors of length at most $r$. Two facts about it stand in flat opposition.

**Fact A — its complexity is exactly $r/\sqrt n$.** Not "at most". Exactly.

<details>
<summary><b>Both directions in three lines</b> (click to reveal)</summary>

*Upper:* Cauchy–Schwarz, $\frac1n\sum_i\sigma_i v_i \le \frac1n\|\sigma\|\|v\| \le \frac{\sqrt n\,r}{n} = \frac{r}{\sqrt n}$.

*Lower:* the vector $v^\sigma = \frac{r}{\sqrt n}\sigma$ lies **in** the ball (length exactly $r$)
and achieves $\frac1n\sum_i\sigma_i\cdot\frac{r}{\sqrt n}\sigma_i = \frac{r}{\sqrt n}$.

Since the supremum equals $r/\sqrt n$ for *every* sign pattern, the average is $r/\sqrt n$ too.
$\blacksquare$

</details>

**Fact B — the ball is an infinite class.** It contains the whole segment
$\{(t,0,\dots,0) : 0 \le t \le r\}$. So $N = \infty$, and *every* counting bound — Massart, growth
functions, [Sauer–Shelah](https://en.wikipedia.org/wiki/Sauer%E2%80%93Shelah_lemma), the standard
[VC route](https://en.wikipedia.org/wiki/Vapnik%E2%80%93Chervonenkis_dimension) — reads
"$\widehat{\mathcal{R}} \le \infty$". True. Useless.

Here is a class whose capacity is a small, *exactly computable* number, and about which counting
says literally nothing.

The picture below makes the exactness visible: for $n=2$ the maximizers sit on the boundary of the
circle, and the level sets of the correlation are tangent there. That tangency *is* Cauchy–Schwarz.

{{visualization:1}}

---

## 5. The margin bound: why kernel methods work

The ball result is abstract. Here is the concrete theorem that runs modern machine learning.

Let the class be linear predictors $x \mapsto \langle w, x\rangle$ with $\|w\| \le W$, on sample
points of norm at most $B$, in **any real inner product space whatsoever**.

> **Margin Bound.** $\displaystyle \widehat{\mathcal{R}} \;\le\; \frac{WB}{\sqrt n}.$
>
> **Kernel Margin Bound.** If $K(x,x) \le B^2$ on the sample, the class of kernel predictors
> $y \mapsto \langle w, \varphi(y)\rangle$ with $\|w\|\le W$ satisfies the same bound. It depends
> on the kernel **only through the diagonal** $\sup_x K(x,x)$.

<details>
<summary><b>The proof, and where the crucial $\sqrt n$ comes from</b> (click to reveal)</summary>

Fix $\sigma$. Since $\frac1n\sum_i\sigma_i\langle w,x_i\rangle = \frac1n\langle w, \sum_i\sigma_i x_i\rangle$,
Cauchy–Schwarz **in the feature space** gives
$$\sup_{\|w\|\le W}\frac1n\sum_i\sigma_i\langle w,x_i\rangle \le \frac{W}{n}\Big\|\sum_i\sigma_i x_i\Big\|.$$
Now average over $\sigma$. A second Cauchy–Schwarz — this time over the $2^n$ sign patterns —
replaces the average norm by the root-mean-square, and *that* is exactly computable:
$$\mathbb{E}_\sigma\Big\|\sum_i\sigma_i x_i\Big\|^2 = \sum_{i,j}\mathbb{E}_\sigma[\sigma_i\sigma_j]\langle x_i,x_j\rangle = \sum_i\|x_i\|^2 \le nB^2,$$
since $\mathbb{E}_\sigma[\sigma_i\sigma_j] = 0$ for $i \ne j$ (flip the single sign $\sigma_i$: a
fixed-point-free involution that negates every off-diagonal term). So the average norm is at most
$\sqrt n B$ and the chain collapses to $\frac{W}{n}\sqrt n B = WB/\sqrt n$.

**Where the $\sqrt n$ comes from.** Going through the ball bound instead would give only $WB$: the
behaviour vectors have length up to $WB\sqrt n$, so $r/\sqrt n = WB$. The extra factor $1/\sqrt n$
is bought *entirely* by the cancellation $\mathbb{E}_\sigma[\sigma_i\sigma_j]=0$. Linear classes
are learnable not merely because they are bounded, but because signed sums of data vectors cancel.

</details>

**The dimension never appears.** Not in the statement, not in the proof. That is the licence for
the kernel trick: an infinite-dimensional feature space costs nothing as long as the kernel
diagonal and the norm budget are controlled.

| Kernel | $K(x,x)$ | Feature dimension | Capacity bound |
|---|---|---|---|
| Linear, $\|x\|\le B$ | $\le B^2$ | $d$ | $WB/\sqrt n$ |
| Polynomial $(1+\langle x,y\rangle)^q$, $\|x\|\le1$ | $\le 2^q$ | $\binom{d+q}{q}$ | $W2^{q/2}/\sqrt n$ |
| Gaussian RBF | $= 1$ | **infinite** | $W/\sqrt n$ |

The Gaussian row is the punchline. Compute it yourself — from the Gram matrix alone, never
touching the feature map:

{{algorithm:1}}

---

## 6. The verdict on dimension

Linear predictors in $\mathbb{R}^d$ have VC dimension $d$ (or $d+1$), so any VC-derived bound has
the shape $c\sqrt{d/n}$. Compare that to $WB/\sqrt n$ and the outcome is decided by a one-line
inequality:

> **Dimension dependence is eventually fatal.** For any $W,B,c > 0$ and any $n$, as soon as
> $$d > \Big(\frac{WB}{c}\Big)^2, \qquad\text{we have}\qquad \frac{WB}{\sqrt n} \;<\; c\sqrt{\frac{d}{n}}.$$

Whatever constant $c$ a dimension-based analysis achieves, there is a finite dimension past which
the margin bound is strictly better — and the ratio grows like $\sqrt d$ without limit. Push
$d\to\infty$, as every kernel method and every wide network does, and the dimension bound diverges
while the margin bound doesn't move.

Move the sliders and watch the crossover:

{{interactive_demo:1}}

And here is the same story as a static, publication-quality figure — capacity against sample size
on the left, the dimension crossover on the right:

{{visualization:0}}

This resolves the paradox that puzzled practitioners for a decade: models with far more parameters
than training examples that nonetheless generalize. Parameter counting is simply the wrong
yardstick. The right one is **scale** — how far the weights may roam, how large the data are, how
tightly the class is squeezed into a small ball. See
[Zhang et al., *Understanding deep learning requires rethinking generalization*](https://arxiv.org/abs/1611.03530)
for the experiments that made this famous, and
[Bartlett & Mendelson's foundational paper](https://www.jmlr.org/papers/v3/bartlett02a.html) for
the theory's origin.

---

## 7. Putting it all together

Two regimes, one measurement.

| Class on a sample of size $n$ | Capacity | What counting says |
|---|---|---|
| A single hypothesis | exactly $0$ | $0$ |
| $N$ vectors of length $\le r$ | $\le r\sqrt{2\log N}/n$ | essentially tight |
| The full sign cube $\{\pm1\}^n$ | exactly $1$ | $\sqrt{2\log2}\approx1.177$ (under 18% off) |
| Euclidean ball of radius $r$ | exactly $r/\sqrt n$ | **vacuous** (infinite class) |
| Linear/kernel, $\|w\|\le W$, $\|x\|\le B$ | $\le WB/\sqrt n$ | $c\sqrt{d/n}$, worse for large $d$ |

The following routine takes a description of a class and returns the tightest guarantee available,
doubling it into a generalization bound via symmetrization:

{{algorithm:2}}

And the full numerical tour — every claim on this page checked against exact enumeration:

{{demo:0}}

---

## 8. The practical payoff

Here is what makes this theory unusual: **the number is measurable.** VC dimension is, for most
interesting model classes, unknown, or known only within wide bounds, or provably infinite.
Rademacher complexity is estimable with the training pipeline you already have:

1. Draw $m$ random sign vectors.
2. Train your model on each, and record the correlation it achieves.
3. Average.

That is a Monte Carlo estimate of $\widehat{\mathcal{R}}$, with error decaying like $1/\sqrt m$
independently of $n$, $N$, or the dimension. Symmetrization then converts it into a bound on how
much your test error can exceed your training error.

{{demo:1}}

**The final thought.** You obtain a guarantee about data you have never seen by running your code
on data that means nothing at all. A model's *inability* to learn from noise is precisely the
certificate that it has learned something from the signal.

---

### Where to go next

- **High-probability bounds.** Everything here is in expectation. Adding
  [McDiarmid's inequality](https://en.wikipedia.org/wiki/McDiarmid%27s_inequality) upgrades it to
  $\sup_f(\mathbb{E}f - \widehat{\mathbb{E}}_S f) \le 2\widehat{\mathcal{R}} + 3B\sqrt{\log(2/\delta)/(2n)}$
  with probability $1-\delta$.
- **Contraction.** Talagrand's lemma, $\widehat{\mathcal{R}}(\phi\circ\mathcal{F}) \le L\widehat{\mathcal{R}}(\mathcal{F})$
  for $L$-Lipschitz $\phi$, transfers the margin bound from scores to losses.
- **Lower bounds.** The cube and the ball are computed *exactly* here; a general
  [Sudakov minoration](https://en.wikipedia.org/wiki/Sudakov_minoration_inequality) would extend
  the matching lower bounds to arbitrary classes.
