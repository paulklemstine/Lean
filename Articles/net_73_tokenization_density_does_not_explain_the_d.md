# The Memory of a Language Model Is Not a Word Count

## Why code needs less attention than French, and what that tells us about how machines read

Somewhere inside every large language model there is a bottleneck, and it looks
like a filing cabinet with too few drawers.

When a transformer reads text, each new token looks back over everything it has
seen and decides how much to care about each earlier position. That "caring" is
a probability distribution — the attention weights — spread over the whole
context. In principle a model attends to all of it. In practice, almost all of
the weight lands on a handful of earlier positions, and the rest is noise. This
observation is the foundation of a whole industry of efficiency tricks: if only
$k$ of the $n$ stored keys matter, throw the other $n-k$ away and you have just
made inference cheaper by a factor of $n/k$.

The engineering question is: how small can $k$ be? The empirical answer is a
number practitioners call the **knee**, written $k^*$: the smallest number of
retained keys at which model quality stops degrading and flattens out. Below the
knee, you are throwing away signal. Above it, you are paying for nothing.

And here is the puzzle that started this investigation. The knee is *not the
same for all text*. Feed the same model, at the same context length, five
different kinds of text, and you get five different knees. Source code
saturates at about $12$ keys. German prose needs around $20$. Mathematics and
English prose both sit at $16$. And French prose — ordinary French prose,
nothing exotic — refuses to saturate at all within a grid that goes up to $32$.

Same model. Same architecture. Same weights. Five different memory
requirements. Something about the *domain* is changing what the model needs to
remember. What?

---

## The obvious suspect

The first hypothesis anyone offers is tokenization density.

Language models do not read words; they read **tokens**, subword fragments
produced by a compression scheme fitted to some training corpus. English words
often survive intact — "the", "model", "attention" are each one token. German
compound nouns get shredded. Source code, with its underscores and camelCase and
punctuation soup, gets shredded worse. So a single "word" of code might cost
two tokens, while a word of English costs barely more than one.

The hypothesis writes itself: **a domain whose words cost more tokens burns
through the context window faster, so it needs more keys**. Tokens-per-word
(TPW) is a purely mechanical statistic — count tokens, count words, divide — and
if it explains the knee, then the domain shift is a boring artifact of the
tokenizer, fixable with a better vocabulary and nothing to think about.

So we measured it. One fixed tokenizer, one fixed model, $5000$-word samples per
domain, and the two predictions stated *in advance*: the rank correlation
between TPW and $k^*$ should be at least $0.9$, and a straight-line fit should
explain at least $80\%$ of the variance.

Here is what came back.

| domain      | tokens per word | knee $k^*$ |
|-------------|-----------------|------------|
| code        | $1.950$         | $12$       |
| German prose| $1.885$         | $20$       |
| French prose| $1.246$         | $>32$      |
| mathematics | $1.214$         | $16$       |
| English prose| $1.173$        | $16$       |

Read the first and last rows together. Code has $1.66$ times English's token
density — it is by far the most expensive domain to tokenize — and it needs
**fewer** keys than English, not more. Now read the French row. French costs
about $1.07$ times English per word, essentially the same, and it needs at least
**twice** as many keys.

The rank correlation is $\rho = -2/5 = -0.40$. Not merely below the $0.9$
threshold — *negative*. The straight-line fit explains
$4225/1054258 \approx 0.4\%$ of the variance. Not merely below $80\%$ — zero, to
within rounding.

Both pre-registered predictions are refuted, and refuted with the wrong sign.

---

## Refutation done properly

It would be easy to stop at "the correlation is bad" and move on. But a
correlation coefficient is a summary statistic, and summary statistics can be
argued with. Maybe the relationship is nonlinear. Maybe it is monotone but
curved. Maybe with the right transformation of TPW everything lines up.

It does not, and there is a clean order-theoretic reason why. Here is the
general principle, which needs no numbers at all.

> **No-Monotone-Law Principle.** Let $x$ and $y$ be two observables measured on
> the same set of items. Suppose there exist items $i, j$ with
> $x_i < x_j$ but $y_j \le y_i$. Then there is **no** strictly increasing
> function $f$ with $y = f(x)$ on all items. Dually, if $x_i < x_j$ and
> $y_i < y_j$ for some pair, there is no strictly decreasing $f$ with
> $y = f(x)$.

The proof is one line: a strictly increasing $f$ preserves order, so
$x_i < x_j$ would force $f(x_i) < f(x_j)$, i.e. $y_i < y_j$, contradicting the
discordant pair. One inversion is enough. This is a much stronger statement
than a low correlation: it rules out *every* increasing law simultaneously —
linear, logarithmic, exponential, piecewise, anything.

Now apply it twice to the data.

- **The increasing horn dies** on the pair (English, code): English has the
  *lowest* density $1.173$ and code the *highest* $1.950$, yet English needs
  $16$ keys and code only $12$. Discordant.
- **The decreasing horn dies** on the pair (mathematics, German): mathematics
  has the *lower* density $1.214$ versus $1.885$, and also the *lower* knee $16$
  versus $20$. Concordant, which is exactly what kills a decreasing law.

So no monotone function of tokens-per-word — in either direction — reproduces
the observed knees. And since a genuine affine law $k^* = a\cdot\mathrm{TPW} + b$
with $a \ne 0$ would force the coefficient of determination to be exactly $1$
(a Cauchy–Schwarz computation), the measured $R^2 \approx 0.004$ independently
rules out every straight line too.

There is a third, rank-level version of the same obstruction that is worth
stating because it explains *why* the correlation coefficient was doomed from
the start. Assign each domain its **competition rank**: one plus the number of
domains scoring strictly below it. Competition ranks are invariant under any
strictly increasing reparameterisation of the observable — squash, stretch, take
logs, it does not matter, the ranks are the same. So if a monotone law existed,
the rank vector of the knee would have to *equal* the rank vector of TPW. It
does not: code is rank $4$ in density and rank $1$ in knee. One mismatch, and
the whole family of laws is gone. Any tie-breaking convention you like gives a
negative $\rho$: $-2/5$, $-1/5$, $-1/4$, $-1/10$ for the four standard
conventions. The sign is not a convention artifact.

The French domain, whose knee is only known to exceed $32$, is a censored
measurement, so we kept it out of the numerics. It does not help the hypothesis
if you put it back in: French has lower density than German and a strictly
larger knee, which independently kills the increasing horn for any actual value
$K \ge 32$ the French knee turns out to have.

---

## If not tokens, then what?

Refutation is only half a result. The interesting half is the replacement.

Model a domain not by how its words are chopped up, but by the **shape of its
attention**. Sort the attention mass so the heaviest key comes first, and record
the **capture curve**
$$C(k) = \text{fraction of attention mass carried by the } k \text{ heaviest keys}.$$
This is a nondecreasing function from $0$ to $1$ with $C(0) = 0$. The knee at
tolerance $\tau \in (0,1)$ is then, by definition,
$$k^*(\tau) = \min\{k : C(k) \ge \tau\}.$$

Immediately three things are true and easy to see. The knee grows with the
tolerance you demand. The knee *shrinks* when the capture curve rises: a domain
whose attention is more concentrated never needs more keys. And — crucially —
the knee depends on the capture curve **and nothing else**. Two domains with the
same capture curve have the same knee, whatever their tokenizers do.

That last remark can be sharpened into a theorem that finishes the tokenization
hypothesis off completely.

> **Decoupling Theorem.** Fix any tolerance $\tau \in (0,1)$. For every token
> density $d$ and every target knee $k \ge 1$, there exists a domain with
> tokens-per-word exactly $d$ and knee exactly $k$.

The witness is embarrassingly simple: let the top $k$ keys each carry mass
$\tau/k$, and attach whatever token density you like as a label. The capture
curve reaches $\tau$ precisely at the $k$-th key, so the knee is exactly $k$,
and the density was never consulted. Consequently:

> **No functional law exists.** There is no function $g$ at all — monotone or
> not, continuous or not — such that $k^* = g(\mathrm{TPW})$ for every domain.

Because a single density supports domains with every possible knee, "predict the
knee from the density" is not a hard problem; it is an ill-posed one. The
measured $\rho = -0.40$ and $R^2 = 0.004$ are not bad luck. They are what the
structure of the problem guarantees.

---

## Concentration is the real coordinate

So the knee is a functional of the attention shape. Which feature of the shape?

Two bounds, from opposite ends of the distribution, pin it down.

> **Top-mass bound.** If the heaviest key of a domain carries mass $p_0$, then
> $k^*(\tau) \ge \tau / p_0$.

If nothing is more than a $1\%$ share, you need at least $\tau \cdot 100$ keys.
The proof is one inequality: since the mass vector is sorted, the top $k$ keys
carry at most $k \cdot p_0$, and that must reach $\tau$.

> **Participation bound.** Let $S = \sum_i p_i^2$ be the *collision index* of
> the attention distribution (the probability that two independent draws land on
> the same key; its reciprocal $1/S$ is the classical "effective number of
> participating items"). Then
> $$k^*(\tau) \ge \tau^2 / S.$$

This one is Cauchy–Schwarz applied to the top-$k$ block:
$C(k)^2 = \left(\sum_{i<k} p_i \cdot 1\right)^2 \le k \sum_{i<k} p_i^2 \le k S$,
and $C(k^*) \ge \tau$ finishes it. The content is information-theoretic: the
effective number of keys the domain actually uses lower-bounds, up to a factor
$\tau^2$, how many you have to keep. A domain that genuinely spreads its
attention over $40$ keys cannot be compressed to $12$, and no tokenizer change
will alter that.

Both bounds are about *relations between positions*, not about the identity or
cost of any individual token. That is the whole content of the verdict.

---

## An exactly solvable domain, and the shift reproduced

Abstract bounds are more convincing when a concrete family realises them. Take
the **geometric domain** with decay rate $r \in (0,1)$: the top $k$ keys capture
$C(k) = 1 - r^k$ of the mass, so the residual attention beyond position $k$
decays like $r^k$. Then the knee has a closed form:
$$k^*(\tau) \le k \iff r^k \le 1 - \tau,$$
i.e. you may stop as soon as the leftover mass $r^k$ falls under the slack
$1-\tau$. Slower decay never helps: if $r \le s$ then the $r$-domain's knee is at
most the $s$-domain's, at every tolerance.

Now set the tolerance at $\tau = 3/4$ and compare two decay rates.

- $r = 1/2$: we need $2^{-k} \le 1/4$, so $k^* = 2$.
- $r = 9/10$: we need $0.9^k \le 1/4$, so $k^* = 14$.

**A sevenfold difference in memory requirement between two domains with
identical token densities.** Nothing distinguishes them except how fast their
attention decays. This is, in miniature, exactly the code-versus-French gap: the
mechanism lives on the decay-rate axis, precisely where the refutation of
tokenization density pushed it.

---

## How much does the knee remember?

The final piece of the story is a structural surprise. We have been treating
$k^*$ as a single number, but really it is a curve: for each tolerance $\tau$
there is a knee $k^*(\tau)$. How much of a domain does that curve know?

Say $P$ **knee-dominates** $Q$ if $P$ needs no more keys than $Q$ at every
tolerance. Say $P$'s attention **majorizes** $Q$'s if $P$'s capture curve is
pointwise at least $Q$'s — $P$'s top $k$ keys hold at least as much mass as
$Q$'s, for every $k$. Majorization is the classical partial order that formalises
"more concentrated"; it is the order behind Schur convexity, the Hardy–
Littlewood–Pólya theorem, and most of the mathematics of inequality measurement.

> **Duality Theorem.** $P$ knee-dominates $Q$ if and only if $P$'s capture curve
> majorizes $Q$'s.

One direction is the monotonicity we already had. The other is a
squeeze-a-tolerance-into-the-gap argument: if $P$ ever captured strictly less
than $Q$ at some $k$, put a tolerance $\tau$ strictly between $C_P(k)$ and
$C_Q(k)$; then $Q$ meets $\tau$ by index $k$ but $P$ does not, so $P$ needs
strictly more keys there, contradicting dominance.

A corollary makes the point sharply:

> **The knee curve is a complete invariant.** If two domains have the same knee
> at every tolerance, they have the same capture curve.

The knee curve is not a lossy summary of attention concentration. It is a
faithful shadow of it — an order-isomorphic copy of the majorization order,
readable directly off a compression experiment. Nothing in this structure refers
to the tokenizer anywhere.

And what about the worry that the observed spread is an artifact of mixed
corpora — that "French" is really a blend of easy and hard material?

> **Mixture Sandwich.** If a corpus mixes two domains with weights $\lambda$ and
> $1-\lambda$, its knee lies between the two component knees at every tolerance:
> $\min(k_P^*, k_Q^*) \le k_{\text{mix}}^* \le \max(k_P^*, k_Q^*)$.

Mixing can never produce a corpus harder than both of its ingredients, nor
easier. Take our two geometric domains with knees $2$ and $14$: every blend of
them has a knee in $[2, 14]$. The observed spread across domains is therefore
genuine structure, not a blending artifact.

---

## What the verdict means

The practical consequence for anyone building a memory-limited transformer is
direct and slightly uncomfortable. You cannot budget your key cache by looking
at your tokenizer. Tokens-per-word is cheap to compute, intuitively appealing,
and provably uninformative about the quantity you care about. Every
(density, knee) pair exists; the map you were hoping for does not.

What you *can* do is measure concentration. The collision index $S = \sum p_i^2$
of a domain's attention, or its top-key mass $p_0$, gives you a certified lower
bound on the cache you must keep — $\tau^2/S$ and $\tau/p_0$ respectively — and
these are relational statistics of the attention pattern itself, computable
from a handful of forward passes. And if you can estimate a domain's decay rate,
the geometric family tells you the answer outright.

There is a broader moral here about mechanism-hunting in machine learning. The
tokenization hypothesis was attractive because it was *surface-level*: it named
a property of the input text, measurable without ever looking inside the model.
The refutation says the domain shift is not visible from outside. It lives in
how the model relates positions to one another — how much of the past a given
kind of text genuinely requires the model to hold in mind at once.

Code is repetitive and locally determined; a line of Python usually depends on
the two or three lines above it, and its attention collapses onto a few keys
despite costing nearly two tokens per word. French prose, with its longer
grammatical dependencies, its agreement across clauses, and its liaison of
meaning across a whole paragraph, spreads its attention thin — and stays
expensive despite being cheap to tokenize.

The filing cabinet is not sized by how many pages you write. It is sized by how
far back you have to reach.
