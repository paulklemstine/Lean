# The Shorter Story: Why Compressible Models Generalize

A learning algorithm sees a finite training sample and returns a hypothesis: a classifier, a decision rule, or some other model. The central puzzle of learning theory is that the algorithm is judged not on the examples it has already seen, but on fresh data. Why should success on the past predict success on the future?

One answer begins with an apparently unrelated question: **how much does the returned model reveal about the training sample?** If the output carries a detailed fingerprint of the particular data set, it may have memorized accidents. If it can be described without recording much sample-specific detail, its behavior is more likely to persist.

This article develops that idea in a finite setting. The key bridge has three spans:

1. dependence between data and output is measured by mutual information;
2. a sufficiently long code bounds that information;
3. a square-root generalization radius grows with information, so shorter descriptions yield no worse guarantees.

The argument is elementary once the right quantities are placed side by side.

## A learner as a joint probability table

Let $\mathcal S$ be a finite set of possible training samples and $\mathcal H$ a finite set of possible hypotheses. Random variables $S\in\mathcal S$ and $H\in\mathcal H$ represent the observed sample and the learner's output. Their behavior is described by a strictly positive joint probability table

$$
p(s,h)=\Pr\{S=s,H=h\},
$$

with $p(s,h)>0$ for every pair and

$$
\sum_{s\in\mathcal S}\sum_{h\in\mathcal H}p(s,h)=1.
$$

Strict positivity avoids special conventions for impossible events. The sample and hypothesis marginals are

$$
p_S(s)=\sum_{h\in\mathcal H}p(s,h),\qquad
p_H(h)=\sum_{s\in\mathcal S}p(s,h).
$$

If $S$ and $H$ were independent, then $p(s,h)=p_S(s)p_H(h)$. The ratio

$$
\frac{p(s,h)}{p_S(s)p_H(h)}
$$

therefore measures how surprising the pair $(s,h)$ is compared with independence. Taking a natural logarithm gives the **information density**

$$
i(s;h)=\log\frac{p(s,h)}{p_S(s)p_H(h)}.
$$

A positive value says that the pair occurs more often than independence predicts; a negative value says it occurs less often. Averaging over the actual joint law gives the **mutual information**

$$
I(S;H)=\sum_{s,h}p(s,h)i(s;h).
$$

Measured with natural logarithms, this quantity is in nats. It summarizes how strongly the learner's output depends on the sample. An output independent of the sample carries no sample-specific information. A highly data-sensitive output can carry much more.

## Turning models into messages

Now assign each hypothesis $h$ a nonnegative or real-valued description length $\ell(h)$, also measured in nats. The average length of the model selected by the learner is

$$
L=\mathbb E[\ell(H)]
 =\sum_{s,h}p(s,h)\ell(h).
$$

The decisive assumption is pointwise: for every sample-output pair,

$$
i(s;h)\le \ell(h).
$$

This is stronger than merely asking for a short average message. It says that the description assigned to $h$ is long enough to dominate every information-density contribution associated with that hypothesis.

### Compression Inequality

**Theorem.** If $i(s;h)\le \ell(h)$ for every $s\in\mathcal S$ and $h\in\mathcal H$, then

$$
I(S;H)\le \mathbb E[\ell(H)].
$$

**Proof sketch.** Multiply each pointwise inequality by the nonnegative probability $p(s,h)$ and sum over all pairs. The left side becomes $I(S;H)$ and the right side becomes $\mathbb E[\ell(H)]$.

This one-line averaging argument is the heart of the compression connection. A code that dominates local dependence also dominates total dependence.

The theorem does not claim that every arbitrary short label is a valid information bound. The pointwise condition matters. Nor does it derive a physical prefix-free code from scratch. Rather, it identifies exactly what a proposed description scheme must certify to enter the generalization argument.

## The square-root radius

Information-theoretic PAC-Bayes bounds often contain a complexity term of the form

$$
R_n(C)=\sqrt{\frac{C}{2n}},
$$

where $n>0$ is the sample size and $C$ combines an information quantity with a confidence penalty. A typical penalty is $c=\log(1/\delta)$ for confidence level $1-\delta$, although the transfer argument only needs the same real number $c$ on both sides.

Suppose a generalization gap $g$ already satisfies the information-based premise

$$
g\le R_n\bigl(I(S;H)+c\bigr).
$$

Here $g$ can represent the difference between population performance and empirical performance in whichever application supplied the premise. The present argument is a transfer theorem: it converts that information-based guarantee into a description-based one.

### Radius Monotonicity

**Theorem.** Under the pointwise code condition,

$$
R_n\bigl(I(S;H)+c\bigr)
\le
R_n\bigl(\mathbb E[\ell(H)]+c\bigr).
$$

**Proof sketch.** The Compression Inequality gives $I(S;H)\le\mathbb E[\ell(H)]$. Adding the same confidence penalty preserves order. Division by the positive number $2n$ preserves order, and the square-root function is monotone.

Combining this result with the assumed PAC-Bayes premise yields the **Expected Description-Length Generalization Theorem**:

$$
g\le
\sqrt{\frac{\mathbb E[\ell(H)]+c}{2n}}.
$$

The message is practical. Mutual information is conceptually clean but may be difficult to estimate directly. A description scheme can provide a more tangible upper bound.

## From average length to a single budget

Sometimes one does not know the exact expected length, but every candidate output obeys a common budget. Suppose

$$
\ell(h)\le M\qquad\text{for every }h\in\mathcal H.
$$

Because the probabilities sum to one,

$$
\mathbb E[\ell(H)]
=\sum_{s,h}p(s,h)\ell(h)
\le \sum_{s,h}p(s,h)M=M.
$$

This gives the **Uniform Description-Length Generalization Theorem**:

**Theorem.** If the pointwise code condition holds, every hypothesis has length at most $M$, and

$$
g\le R_n\bigl(I(S;H)+c\bigr),
$$

then

$$
g\le \sqrt{\frac{M+c}{2n}}.
$$

A single compression budget can therefore replace the full output distribution. This may be looser than using the average length, but it is often easier to state and audit.

## Why shorter really is better

Suppose a refined representation reduces the uniform budget from $M_{\mathrm{long}}$ to $M_{\mathrm{short}}$, with

$$
M_{\mathrm{short}}\le M_{\mathrm{long}}.
$$

The corresponding radii obey

$$
\sqrt{\frac{M_{\mathrm{short}}+c}{2n}}
\le
\sqrt{\frac{M_{\mathrm{long}}+c}{2n}}.
$$

The **Shorter-Description Monotonicity Theorem** states the end-to-end consequence: if the pointwise code condition holds, all outputs fit within $M_{\mathrm{short}}$, and the information-based PAC-Bayes premise holds, then the gap is bounded by the short radius and hence by every looser radius using $M_{\mathrm{long}}\ge M_{\mathrm{short}}$.

This is a “no worse” statement, not automatically a strict improvement. Equality can occur, for example, when the two budgets agree. Strict gains require extra nondegeneracy assumptions.

## A small numerical picture

Imagine two possible samples and three possible hypotheses. Their six joint probabilities form a positive table. From that table one computes both marginals, then six information densities. For each hypothesis, choose a length slightly above the largest information density it attains across the two samples. The pointwise condition is then true by construction.

Weighting those six information densities by their probabilities produces $I(S;H)$. Weighting the three chosen lengths by the output marginal produces $L$. The theorem guarantees $I(S;H)\le L$. If $n=200$ and $\delta=0.05$, take $c=\log(20)$. The two radii are

$$
R_{200}(I+c)=\sqrt{\frac{I+\log 20}{400}},
\qquad
R_{200}(L+c)=\sqrt{\frac{L+\log 20}{400}}.
$$

The first cannot exceed the second. Replacing $L$ by a maximum code length $M$ can only enlarge the radius again. The resulting ladder is

$$
R_n(I+c)\le R_n(L+c)\le R_n(M+c).
$$

Each step trades sharpness for accessibility.

## What compression means in practice

Description length can represent many kinds of structure: a sparse list of nonzero coefficients, a pruned decision tree, a quantized parameter vector, a compact program, or an index into a small model family. The theorem does not choose among these representations. It says what any successful representation buys once it controls information density.

The square-root form also reveals two scaling laws. First, holding complexity fixed while multiplying the sample size by four halves the radius. Second, saving description length has diminishing returns because complexity sits under a square root. Compression still helps, but the greatest conceptual gain may be that it exposes which parts of a model are genuinely needed to explain the data.

There is also a warning. A tiny file produced by a decoder that secretly contains the training set is not evidence of low information. The description mechanism and all side information must be accounted for. The pointwise domination condition prevents the slogan “shorter is better” from becoming magic: the length must honestly cover the sample-output dependence.

## The full chain

The argument can now be read in one line:

$$
i(s;h)\le\ell(h)
\Longrightarrow
I(S;H)\le\mathbb E[\ell(H)]
\Longrightarrow
R_n(I+c)\le R_n(\mathbb E[\ell(H)]+c).
$$

With a uniform budget $\ell(h)\le M$, it continues as

$$
g\le R_n(I+c)
\Longrightarrow
g\le R_n(\mathbb E[\ell(H)]+c)
\Longrightarrow g\le R_n(M+c).
$$

The mathematics is modest; the viewpoint is powerful. Generalization is not only about how many parameters a model has. It is about how many nats of the particular training sample survive in the chosen hypothesis. Compression gives that abstract dependence a concrete price tag. When the price tag shrinks honestly, the guaranteed generalization radius cannot get worse.

## A design principle for learning systems

The chain suggests a constructive question for model builders: not only “How accurately does this model fit?” but also “What is the shortest complete account of the choice the algorithm made?” Regularization, pruning, quantization, and distillation can all be viewed through this lens when they produce an honest description certificate. The certificate must include structural choices as well as numerical values. A sparse model, for instance, must describe which coordinates are nonzero and what their values are; counting only the values understates the message.

This perspective also separates two roles that are sometimes blurred. Statistics supplies the premise connecting a generalization gap to mutual information and confidence. Coding supplies the inequality connecting information density to lengths. The transfer argument then composes them. Improving either side helps: a sharper statistical premise reduces the first radius, while a better code reduces the accessible upper bounds.

Most importantly, the result turns an intuition into an auditable chain of inequalities. One can inspect the probability model, inspect the description rule, verify pointwise domination, and calculate every radius. “Simple models generalize” is too vague to test. “This length function dominates every information density, so its expectation bounds mutual information” is a mathematical claim with clear assumptions. That precision is what allows compression to move from metaphor to generalization theory.
