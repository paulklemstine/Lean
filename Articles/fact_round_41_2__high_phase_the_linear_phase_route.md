# The Signal That Cannot Be There

### Why a whole family of "phase" features was doomed before the first experiment ran — and where the missing structure actually hides

---

## A stubborn two percent

Here is a situation that anyone who has ever fit a model will recognise.

You have a quantity you want to predict. You have a bag of features — simple, cheap, interpretable numbers you can compute from your data. You add them to the model, and the fit improves by a whisker: two percent of the variance explained, give or take. Not nothing. Not much. Well inside the range where a hopeful researcher squints and says *maybe*, and a sceptical one says *noise*.

The particular version of this story that motivated the mathematics below involved *phases*: for each object in a dataset, you record the position of some distinguished landmark, reduce that position modulo a prime $p$, and turn the resulting residue into a feature — a one-hot indicator, a sine, a cosine, whatever you like. Do this for every prime from $3$ to $97$. Two hundred-odd features, all of them individually harmless, all of them cheap.

The measurement came back at $+0.0215$ in $R^2$, with a confidence interval of $[-0.0025,\, +0.0429]$ — an interval that comfortably fails to reach the $+0.05$ that had been declared in advance as the threshold for "real". And yet the gain was *stable*: it held up almost identically when the model was evaluated on a different window of data (a cross-window to same-window ratio of $0.92$). Stability is usually the hallmark of a genuine effect. Noise is not supposed to be reproducible.

So which is it?

The honest way to settle that question is not to run the experiment again with more data. It is to ask a sharper question: **could a feature of this kind ever have helped, even in principle, even with infinite data?** That question has an answer, and the answer is a theorem, not a p-value.

---

## The exact accounting of a fit

Start from scratch, with no probability theory at all — just averages over a finite list.

Let $I$ be a finite, nonempty index set (your sample). For a function $f : I \to \mathbb{R}$ write
$$\operatorname{avg} f = \frac{1}{|I|}\sum_{i \in I} f(i),$$
and define the *empirical covariance* and *variance* of $f, g : I \to \mathbb{R}$ by
$$\operatorname{Cov}(f,g) = \operatorname{avg}(fg) - (\operatorname{avg} f)(\operatorname{avg} g), \qquad \operatorname{Var} f = \operatorname{Cov}(f,f).$$
Given a *target* $y : I \to \mathbb{R}$ and a *predictor* $h : I \to \mathbb{R}$, the mean squared error is $\operatorname{MSE}(y,h) = \operatorname{avg}\big((y - h)^2\big)$, and the coefficient of determination is measured against the best constant baseline:
$$R^2(y,h) = 1 - \frac{\operatorname{MSE}(y,h)}{\operatorname{Var} y}.$$

Everything that follows rests on one identity, which is nothing more than expanding a square and collecting terms — but which, once written down, is startlingly informative.

> **Error Decomposition Theorem.** For every target $y$ and *every* predictor $h$ whatsoever,
> $$\operatorname{MSE}(y,h) \;=\; \operatorname{Var} y \;-\; 2\operatorname{Cov}(y,h) \;+\; \operatorname{Var} h \;+\; \big(\operatorname{avg} y - \operatorname{avg} h\big)^2 .$$

Read it slowly. The error of any predictor is: the variance you were trying to explain, *minus* twice the alignment between predictor and target, *plus* the noise the predictor injects on its own, *plus* the penalty for aiming at the wrong average. There is no remainder term, no approximation, no asymptotics. It is an equality on any finite sample.

And now the punchline drops out for free. Suppose your predictor happens to have $\operatorname{Cov}(y,h) = 0$. The middle term vanishes, and the two surviving terms are squares:

> **No-Gain and Strict-Harm Theorem.** If $\operatorname{Cov}(y,h) = 0$, then $\operatorname{MSE}(y,h) \ge \operatorname{Var} y$, with the excess given *exactly* by
> $$\operatorname{MSE}(y,h) - \operatorname{Var} y = \operatorname{Var} h + \big(\operatorname{avg} y - \operatorname{avg} h\big)^2 .$$
> In particular $R^2(y,h) \le 0$, and if $h$ is not constant the inequality is strict: an uncorrelated predictor is not merely useless, it is actively harmful, and the damage it does is precisely its own variance.

An uncorrelated feature is a liability, not a coin flip. That single observation is what turns a measurement question into a structural one: if we can prove that a whole family of features has covariance *identically zero* with the target, then no amount of data, tuning, or cleverness in fitting will ever extract a positive gain from them.

While we are here, the same identity yields the sharpest possible statement about a one-feature model. Fitting the best line $a f + b$ through a feature $f$ with $\operatorname{Var} f > 0$ gives error exactly $\operatorname{Var} y - \operatorname{Cov}(y,f)^2/\operatorname{Var} f$, attained by the familiar $a = \operatorname{Cov}(y,f)/\operatorname{Var} f$; hence the best attainable $R^2$ of any single-feature model is *exactly* the squared correlation, and no more. As a bonus, the fact that this error is nonnegative *is* the Cauchy–Schwarz inequality $\operatorname{Cov}(y,f)^2 \le \operatorname{Var} y \cdot \operatorname{Var} f$ — derived here from regression rather than assumed before it.

---

## Alignment: a target that lives between the coordinates

Now for the object at the centre of the story.

Take two finite sets $A$ and $B$ of the same size and a bijection $\sigma : A \to B$. On the product $A \times B$ define the **alignment indicator**
$$g_\sigma(a,b) = \begin{cases} 1 & \text{if } b = \sigma(a),\\ 0 & \text{otherwise.}\end{cases}$$

This is the mathematical skeleton of "the two readings agree". In the phase story, $a$ is a landmark's residue modulo one prime and $b$ its residue modulo another (or the same reading in a second window); the target fires exactly when the two are in the prescribed correspondence. It is the simplest possible *relational* quantity: it is not a property of $a$, and it is not a property of $b$; it is a property of the pair.

Its statistics are easy. With $m = |A|$, the target is $1$ on exactly $m$ of the $m^2$ cells, so
$$\operatorname{avg} g_\sigma = \frac{1}{m}, \qquad \operatorname{Var} g_\sigma = \frac{1}{m} - \frac{1}{m^2},$$
which is strictly positive as soon as $m \ge 2$. There is real variance to explain.

Against this target, put the most generous possible notion of a "phase feature". Call a predictor **additive** (or *singleton*) if it has the form
$$h(a,b) = u(a) + v(b)$$
for arbitrary real functions $u$ on $A$ and $v$ on $B$. This is far more general than one-hot dummies or sinusoids of a residue: $u$ and $v$ are completely unconstrained, and because sums of additive functions are additive, this single family also covers *any number* of per-coordinate features used simultaneously, with any coefficients, fit optimally.

> **Closure Theorem for Singleton Encodings.** For every bijection $\sigma$ and *all* functions $u : A \to \mathbb{R}$, $v : B \to \mathbb{R}$,
> $$\operatorname{Cov}\big(g_\sigma,\; u \oplus v\big) = 0,$$
> where $(u \oplus v)(a,b) = u(a) + v(b)$. Consequently no additive predictor beats the constant baseline; every nonconstant one is strictly worse; and in $R^2$ units the attainable gain satisfies $R^2 \le 0$.

The proof is a one-line computation once you see it. Summing $g_\sigma \cdot (u \oplus v)$ over the grid picks out exactly the graph of $\sigma$, giving $\sum_a u(a) + \sum_b v(b)$ divided by $m^2$; and $\operatorname{avg} g_\sigma \cdot \operatorname{avg}(u\oplus v)$ gives *the same number*, because $\operatorname{avg} g_\sigma = 1/m$ exactly compensates. The two terms cancel identically. Not approximately, not on average over random $\sigma$ — identically, for every $\sigma$, every $u$, every $v$.

This is the sense in which "the linear phase route is closed". A measured $+0.0215$ cannot be a population effect of this kind, because the population effect of this kind is $0$ at every modulus, and any deviation from perfect fit costs strictly more than doing nothing.

Nor can you rescue it by adding more of the same. If you enlarge the sample space with an independent block $C$ of nuisance coordinates — other primes, other windows, other measurement channels — and allow an arbitrary extra term $w(c)$, the covariance with the alignment target is still exactly zero. Independent blocks contribute independently; zero plus zero is zero.

---

## And yet the signal is completely there

Here is the twist that makes the negative result worth telling. The alignment target is not weakly predictable or noisily predictable. It is *perfectly* predictable — just not at degree one.

Write $\mathbf{1}_{a=c}$ for the one-hot indicator of the first coordinate and $\mathbf{1}_{b=d}$ for that of the second. Then, exactly and pointwise,
$$g_\sigma(a,b) \;=\; \sum_{c \in A} \mathbf{1}_{a=c}\,\cdot\,\mathbf{1}_{b=\sigma(c)} .$$

The target is a sum of $m$ *products of pairs* of the very same singleton features that individually told us nothing. Feeding those $m$ products into a linear model reproduces the target on the nose, so its error is $0$ and its $R^2$ is $1$.

> **Separation Theorem.** For an alignment target with $m \ge 2$: every singleton (degree-one) encoding attains $R^2 \le 0$, while the explicit degree-two interaction encoding attains $R^2 = 1$.

Zero versus one. Not a matter of statistical power, sample size, or regularisation strength. The entire signal sits one degree up, and the whole degree-one layer is blind to it in a way that no estimator can repair.

---

## Why: an exact budget for every target

The alignment example is vivid, but it is a special case of a general accounting identity that turns the whole discussion into arithmetic.

Take *any* target $f : A \times B \to \mathbb{R}$. Define its row means $r(a) = \operatorname{avg}_b f(a,b)$, its column means $c(b) = \operatorname{avg}_a f(a,b)$, and its grand mean $\mu = \operatorname{avg} f$. Split
$$f = f_{\mathrm{add}} + f_{\mathrm{int}}, \qquad f_{\mathrm{add}}(a,b) = r(a) + c(b) - \mu, \qquad f_{\mathrm{int}} = f - f_{\mathrm{add}} .$$
The first piece is additive by construction. The second has *every* row sum and *every* column sum equal to zero — it is pure interaction, invisible to any marginal.

> **Orthogonal Split Theorem.** The interaction part is uncorrelated with every additive predictor; in particular $\operatorname{Cov}(f_{\mathrm{add}}, f_{\mathrm{int}}) = 0$, so the variance budget is exact and cross-term-free:
> $$\operatorname{Var} f = \operatorname{Var} f_{\mathrm{add}} + \operatorname{Var} f_{\mathrm{int}} .$$
> The best possible additive predictor of $f$ has error exactly $\operatorname{Var} f_{\mathrm{int}}$, attained by $f_{\mathrm{add}}$ itself. Hence the **degree-one ceiling**
> $$\sup_{u,v} \; R^2\big(f, u \oplus v\big) \;=\; \frac{\operatorname{Var} f_{\mathrm{add}}}{\operatorname{Var} f},$$
> and the unreachable excess is $\operatorname{Var} f_{\mathrm{int}} / \operatorname{Var} f$, no matter which singleton features anyone tries.

This is a *diagnostic you can compute before you fit anything*. Two passes over the data give you the row means and column means; from them you get the ceiling exactly. If the ceiling is $0.03$, then no amount of feature engineering within the singleton family will ever explain more than three percent, and you can stop.

For the alignment indicator the computation is immediate: every row mean equals $1/m$ and every column mean equals $1/m$, so $f_{\mathrm{add}} \equiv 1/m$ is *constant*, its variance is $0$, and the ceiling is $0$ exactly. The closure theorem is a corollary of the budget. The excess is not a large fraction; it is one hundred percent.

---

## Stability is not evidence

Return for a moment to the empirical puzzle: the small gain was *window-stable*, with cross-window to same-window ratio $0.92$. Doesn't reproducibility argue for reality?

Only if reproducibility discriminates. It does not, and here is the reason.

> **Relabelling Invariance.** Every quantity in this calculus — the mean, the covariance, the variance, the mean squared error, and therefore $R^2$ — is unchanged when the sample space is relabelled by an arbitrary bijection. If $e : J \to I$ is a bijection, then $R^2(y \circ e, h \circ e) = R^2(y, h)$.

A genuine population-level degree-one effect and a genuine population-level *null* are both perfectly window-stable: an exact zero transports to another window as an exact zero, with cross/same ratio $1$. So stability by itself cannot distinguish a small true effect from a small artefact of estimation. What discriminates is the *level* — and the level is provably zero. A ratio of $0.92$ around a value of $+0.02$ is a statement about the estimator's behaviour, not about the presence of degree-one structure.

---

## The ladder keeps going

Once the mechanism is clear — a target whose conditional mean stays flat when you condition on too few coordinates — you can climb.

Let $G$ be a finite abelian group (think of the integers modulo $p$), and on $G \times G \times G$ define the **three-way alignment target**
$$t(a,b,c) = \begin{cases}1 & \text{if } a + b + c = 0,\\ 0 &\text{otherwise.}\end{cases}$$
Its mean is $1/N$ and its variance is $1/N - 1/N^2$ where $N = |G|$, exactly as before. Now allow predictors built from arbitrary functions of *pairs* of coordinates:
$$h(a,b,c) = F(a,b) + H(b,c) + K(a,c),$$
a class that includes the entire interaction layer that cracked the two-coordinate problem.

> **Degree-Three Separation.** For $N \ge 2$: $\operatorname{Cov}(t, h) = 0$ for all $F, H, K$, so every degree-$\le 2$ encoding attains $R^2 \le 0$, while the degree-three encoding (the joint indicator itself) attains $R^2 = 1$.

The reason is the same one, one level up: fix any two of the three coordinates, and the third is uniformly free, so the conditional average of the target is the constant $1/N$ regardless. Nothing that omits a coordinate can see it.

This gives the programme a sharp, falsifiable prediction. **If the missing structure is a $k$-fold joint alignment, then every encoding of degree less than $k$ returns exactly zero population gain — not a small gain, not a gain that better estimation might sharpen, but exactly zero.** So the right experiment is not "try more primes" or "try more phases"; it is "raise the degree, and watch for a jump from nothing to everything".

---

## What was actually learned

The formal conclusion is stark, and it is worth stating without hedging. Across the entire scanned range of moduli $3 \le p \le 97$ — indeed for every $p \ge 2$ — the family of singleton phase encodings has *exactly zero* covariance with a diagonal alignment target, so the attainable same-window $R^2$ is at most $0$, and any nonconstant member of the family is strictly worse than predicting the mean. The two percent that was measured cannot be a degree-one effect at any modulus.

The unexplained excess in the original problem is therefore not hiding in a prime nobody tried. Three possibilities remain, and the mathematics narrows them cleanly: the structure is an interaction or joint-alignment phenomenon that only a degree-$\ge 2$ encoding can see; or it is intrinsic to the family of objects rather than to any positional readout; or it is not there at all.

There is a broader moral, and it is not about primes. Modern practice tends to answer "is this feature useful?" by fitting and measuring. But a feature class has a *reach* — the degree-one ceiling above is precisely that reach, and it is computable in two passes over the data, before a single model is trained. When the ceiling is zero, no measurement, however careful, can find anything above it; and every dollar of compute spent hunting is spent on estimator noise.

Sometimes the most valuable result an investigation can produce is a proof that the thing you were looking for was never in the place you were looking.
